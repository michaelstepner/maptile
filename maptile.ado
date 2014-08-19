*! version 0.70beta4  XXaug2014  Michael Stepner, stepner@mit.edu

/*** Unlicence (abridged):
This is free and unencumbered software released into the public domain.
It is provided "AS IS", without warranty of any kind.

For the full legal text of the Unlicense, see <http://unlicense.org>
*/

* Why did I include a formal license? Jeff Atwood gives good reasons:
*  http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html

/* XX should rename cutpoints() to QVar(), and actually implement a conventional cutpoints option */

program define maptile, rclass
	version 11
	
	set more off

	syntax varname(numeric) [if] [in], GEOgraphy(string) [ ///
		Nquantiles(integer 6) CUTpoints(varname numeric) CUTValues(numlist ascending) ///
		FColor(string) RANGEColor(string asis) REVcolor PROPcolor SHRINKColorscale(real 1) NDFcolor(string) ///
		LEGDecimals(string) LEGFormat(string) ///
		SAVEgraph(string) replace RESolution(real 1) ///
		mapif(string) spopt(string) geofolder(string) hasdatabase ///
		*]
	
	preserve
	
	if (`"`geofolder'"'=="") {
		local geofolder `c(sysdir_personal)'maptile_geographies
	}

	* Load the code for the specified geography
	cap confirm file `"`geofolder'/`geography'_maptile.ado"'
	if (_rc!=0) {
		di as error "geography(`geography') specified, but it is not installed."
		
		if ("`geofolder'"=="`c(sysdir_personal)'maptile_geographies") di as text `"To see a list of installed geographies run: {stata maptile_geolist}"'
		else {
			di as text `"To see a list of installed geographies run:"'
			di as text `"   {stata maptile_geolist, geofolder(`geofolder')}"'
			di as text ""
		}
		exit 198
	}
	
	cap program drop _maptile_`geography'
	run `"`geofolder'/`geography'_maptile.ado"'
	cap program list _maptile_`geography'
	if (_rc!=0) {
		di as error `""`geography'_maptile.ado" was loaded from the geofolder, but it does not define a program named _maptile_`geography'"'
		exit 198
	}	
	
	* Set defaults & perform checks
	
	if ("`replace'"=="") & (`"`savegraph'"'!="") {
		if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") confirm new file `"`savegraph'"'
		else confirm new file `"`savegraph'.gph"'
	}

	if ("`legdecimals'"!="") {
		if real("`legdecimals'")<0 | missing(real("`legdecimals'")) | int(real("`legdecimals'"))!=real("`legdecimals'") {
			di as error "legdecimals() must be an integer >=0"
			exit 198
		}
		if ("`legformat'"!="") {
			di as error "Cannot specify both legdecimals() and legformat()"
			exit 198
		}
		local legformat %12.`legdecimals'fc
	}
	
	if "`cutvalues'"!="" & "`cutpoints'"!="" {
		di as error "cannot specify both cutvalues() and cutpoints()"
		exit 198
	}
	
	if "`cutvalues'"!="" & `nquantiles'!=6 {
		di as error "cannot specify both cutvalues() and nquantiles()"
		exit 198
	}
		
	if (`resolution'<=0) {
		di as error "resolution() must be a number greater than 0"
		exit 198
	}
	
	if ("`fcolor'"!="") {
		if ("`revcolor'"!="") {
			di as error "cannot specify revcolor with fcolor()"
			exit 198
		}
		if ("`propcolor'"!="") {
			di as error "cannot specify propcolor with fcolor()"
			exit 198
		}
		if (`shrinkcolorscale'!=1) {
			di as error "cannot specify shrinkcolorscale() with fcolor()"
			exit 198
		}
		if (`"`rangecolor'"'!="") {
			di as error "cannot specify rangecolor() with fcolor()"
			exit 198
		}	
	}
	
	if ("`ndfcolor'"=="") local ndfcolor gs12
	
	if (`shrinkcolorscale'>1) | (`shrinkcolorscale'<=0) {
		di as error "shrinkcolorscale() must be greater than 0 and less than or equal to 1"
		exit 198
	}
	
	if (`"`mapif'"'!="") local map_restriction if (`mapif')
	
	* If legstyle isn't set in spopt(), set the default legend style
	if strpos("`spopt'","legstyle(")==0 {
		local legopt legstyle(2) legjunction(" {&minus} ")
	}
	
	
	* Specify color gradient boundaries
	if `"`rangecolor'"'=="" {
	
		* default: yellow*0.1 -> red*1.65
		local low_r=255
		local low_g=255
		local low_b=0
		
		local high_r=255
		local high_g=0
		local high_b=0
		
		local low_intensity=.1
		local high_intensity=1.65
		
	}
	else if `:word count `rangecolor''!=2 {
		di as error `"rangecolor() must contain exactly two colorstyles, e.g. <yellow red> or <"255 255 0" "255 255 0">"'
		exit 198
	}
	else {
		local low_str : word 1 of `rangecolor'
		local high_str : word 2 of `rangecolor'
		
		foreach i in low high {
			local starpos = strpos("``i'_str'","*")
			if `starpos'>0 {
				local `i'_color=substr("``i'_str'",1,`starpos'-1)
				local `i'_intensity=substr("``i'_str'",`starpos'+1,.)
			}
			else {
				local `i'_color ``i'_str'
				local `i'_intensity=1
			}
			
			* Check intensity is valid
			if !inrange(real("``i'_intensity'"),0,255) {
				di as error `"'``i'_intensity'' is not a valid color intensity. Must be a number between 0 and 255."'
				exit 198
			}
			
			* Convert colorstyle to RGB
			gr_setscheme , refscheme
			color_load ``i'_color'
			local `i'_r : word 1 of `s(rgb)'
			local `i'_g : word 2 of `s(rgb)'
			local `i'_b : word 3 of `s(rgb)'
		}
	}


	* Restrict sample
	if `"`if'`in'"'!="" {
		marksample touse
		foreach var of varlist `varlist' {
			qui replace `var'=. if !`touse'
		}
	}

	
	* If cutvalues are specified, parse and store them
	tempname clbreaks

	if ("`cutvalues'"!="") {
	
		* parse numlist
		numlist "`cutvalues'"
		
		* update nquantiles
		local nquantiles : word count `r(numlist)'
		local ++nquantiles
		
		* Store quantile boundaries in list
		matrix `clbreaks'=J(`=`nquantiles'-1',1,.)
		forvalues i=1/`=`nquantiles'-1' {
			matrix `clbreaks'[`i',1]=real(`: word `i' of `r(numlist)'')
		}
		
		matrix colnames `clbreaks' = cutvalues
		
	}
	
	else { /* compute quantiles */
	
		* If a cutpoint variable is specified, calculate cutpoints for that var
		if ("`cutpoints'"!="") local pctilevars `cutpoints'
		* If no cutpoint variable or cutvalues were specified, calculate cutpoints for each var separately
		else local pctilevars `varlist'
		
		* Prepare clbreaks matrix
		matrix `clbreaks'=J(`=`nquantiles'-1',`:word count `pctilevars'',.)
		
		* Compute and store quantiles
		local varcount=1
		foreach var of varlist `pctilevars' {

			* Compute quantile boundaries
			_pctile `var', nq(`nquantiles')
			
			* Store quantile boundaries in list
			forvalues i=1/`=`nquantiles'-1' {
				matrix `clbreaks'[`i',`varcount']=r(r`i')
			}

			local ++varcount
		}
		
		matrix colnames `clbreaks' = `pctilevars'
		
	}
	
	* Merge in database
	if ("`hasdatabase'"=="") qui _maptile_`geography', mergedatabase geofolder(`geofolder') `options'


	* Map each variable
	local qcount=1
	foreach var of varlist `varlist' {
		
		* Calculate boundaries
		tempname min max
		qui sum `var', meanonly
		scalar `min'=min(r(min),`clbreaks'[1,`qcount']-epsfloat())
		scalar `max'=max(r(max),`clbreaks'[`=`nquantiles'-1',`qcount'])
		
		* Choose legend format
		if ("`legformat'"=="") {
		
			* Define locals that point to first and last breakpoint
			local rfirst `clbreaks'[1,`qcount']
			local rlast `clbreaks'[`=`nquantiles'-1',`qcount']
			local rsmall min(abs(`rfirst'),abs(`rlast'))
			local rbig max(abs(`rfirst'),abs(`rlast'))
			
			* Check if all breakpoints are integers
			local rinteger=1
			forvalues i=1/`=`nquantiles'-1' {
				if (`clbreaks'[`i',`qcount']!=int(`clbreaks'[`i',`qcount'])) local rinteger=0
			}
			
			* Choose a nice format for decimals
			if (`rbig'>=10^7) format `var' %12.1e
			else if (`rinteger'==1) format `var' %12.0fc
			else if (`rbig'>=1000) format `var' %12.0fc
			else if (`rbig'>=100) format `var' %12.1fc
			else if (`rbig'>=1) format `var' %12.2fc
			else if (`rsmall'>=0.01) format `var' %12.3fc
			else if (`rsmall'>=0.001) & (`rlast'-`rfirst'>=0.001*`nquantiles'*2) format `var' %12.3fc
			else if (`rsmall'>=0.0001) & (`rlast'-`rfirst'>=0.0001*`nquantiles'*2) format `var' %12.4fc
			else format `var' %12.1e
		}
		else format `var' `legformat'
	
			
		* Place each bin appropriately on the color gradient, if colors not manually specified
		if (`"`fcolor'"'=="") {
			local mapcolors ""
				
			* If doing proportional color scaling, calculate median value within each quantile
			if ("`propcolor'"!="") {
				tempname quantile_vals
				matrix `quantile_vals'=J(`nquantiles',1,.)
			
				forvalues i=1/`nquantiles' {					
					if (`i'==1) 					qui _pctile `var' if `var'<=`clbreaks'[1,`qcount'], percentiles(50)
					else if (`i'==`nquantiles')		qui _pctile `var' if `var'>`clbreaks'[`=`nquantiles'-1',`qcount'], percentiles(50)
					else 							qui _pctile `var' if `var'>`clbreaks'[`i'-1,`qcount'] & `var'<=`clbreaks'[`i',`qcount'], percentiles(50)
					
					if !mi(r(r1)) matrix `quantile_vals'[`i',1]=r(r1)
					else { /* no data, so pick the midpoint of the interval */
						if (`i'==1) 					matrix `quantile_vals'[`i',1]= `clbreaks'[1,`qcount']
						else if (`i'==`nquantiles')		matrix `quantile_vals'[`i',1]= `clbreaks'[`=`nquantiles'-1',`qcount']
						else 							matrix `quantile_vals'[`i',1]= (`clbreaks'[`i'-1,`qcount']+`clbreaks'[`i',`qcount'])/2
					}
				}

				tempname QV_min QV_length
				scalar `QV_min'=`quantile_vals'[1,1]
				scalar `QV_length'=`quantile_vals'[`nquantiles',1]-`QV_min'
			}
			
			* Reverse color order if needed
			if ("`revcolor'"!="") local flipweights="1 -"
			
			* Compute RGB color values
			local cl_lag=.
			forvalues i=1/`nquantiles' {
			
				* Skip this quantile if it is a duplicate
				if (`i'!=`nquantiles' & `clbreaks'[min(`i',`nquantiles'-1),`qcount']==`cl_lag') continue
				else if (`i'==`nquantiles' & `max'==`cl_lag') continue
				local cl_lag `clbreaks'[`i',`qcount']
			
				* Set the spacings between each color
				if ("`propcolor'"!="") local weight_high=( `flipweights' (`quantile_vals'[`i',1]-`QV_min')/`QV_length' ) * `shrinkcolorscale' + (1-`shrinkcolorscale')/2
				else local weight_high=( `flipweights' (`i'-1)/(`nquantiles'-1) ) * `shrinkcolorscale' + (1-`shrinkcolorscale')/2
				
				* Stretch the color spectrum as desired. In default colour space, this is expanding the yellows, shrinking the reds.
				local cos_weight_high=1 - cos( `weight_high' * c(pi) / 2 )
				local mixed_weight_high=(3*`weight_high'+`cos_weight_high')/4
				

				* Compute color components
				foreach component in r g b {
					local cur_`component'=round(`low_`component''*(1-`cos_weight_high')+`high_`component''*`cos_weight_high')
				}
				local cur_intensity=`low_intensity'*(1-`mixed_weight_high')+`high_intensity'*`mixed_weight_high'
			
				* Store this color in the list
				local mapcolors `"`mapcolors' "`cur_r' `cur_g' `cur_b'*`cur_intensity'""'
				
			}
			
		}
		else local mapcolors `fcolor'
		
		
		* Convert clbreaks matrix to string
		local clbreaks_str ""
		local cl_str_lead `clbreaks'[1,`qcount']
		forvalues i=1/`=`nquantiles'-1' {
		
			local cl_str_cur `cl_str_lead'
			if (`i'<`nquantiles'-1) local cl_str_lead `clbreaks'[`i'+1,`qcount']
			else local cl_str_lead `max'
			
			* Only output non-duplicate quantiles
			if (`cl_str_cur'!=`cl_str_lead') local clbreaks_str `clbreaks_str' `=`cl_str_cur''
		}
		
		* Make maps
		_maptile_`geography', map geofolder(`geofolder') ///
			var(`var') ///
			legopt(`"`legopt'"') ///
			min(`=`min'') clbreaks(`clbreaks_str') max(`=`max'') ///
			mapcolors(`"`mapcolors'"') ndfcolor(`ndfcolor') ///
			savegraph(`savegraph') `replace' resolution(`resolution') ///
			map_restriction(`"`map_restriction'"') ///
			spopt(`spopt') ///
			`options'
			
		if ("`cutvalues'"=="") & ("`cutpoints'"=="") local ++qcount
			
	}
	
	* Return objects
	
	cap confirm matrix `quantile_vals'
	if (_rc==0) return matrix midpoints= `quantile_vals'
	
	return matrix breaks=`clbreaks'
		
end


*** Helper programs

* color_load, borrowed from palette.ado version 1.0.11  26jan2012
program color_load , sclass
	tempname mycolor
	.`mycolor' = .color.new , style(`0')
	sret local rgb "`.`mycolor'.setting'"
	sret local color `""`0'""'
end

