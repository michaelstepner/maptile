*! version 0.70dev  XXjan2014  Michael Stepner, stepner@mit.edu

/*** "Unlicence"
This is free and unencumbered software released into the public domain.
It is provided "AS IS", without warranty of any kind.

For the full legal text of the Unlicense, see <http://unlicense.org>
*/

* Why did I include a formal license? Jeff Atwood gives good reasons: http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html


/* XX put in help file:
* geoid() info
* restrict_map doesn't affect quantile computation
* r(breaks) output
*/

/* XX to test in a test suite program:
* rangecolor()
*/

* XX add if/in
* XX actually specify filename, not just prefix/suffix?

* XX fix map scaling

* XX add d3map option?

program define maptile, rclass
	version 11
	
	set more off

	syntax varlist(numeric), shapefolder(string) GEOgraphy(string) [ ///
		FColor(string) RANGEColor(string asis) REVcolor PROPcolor SHRINKcolorscale(real 1) NDFcolor(string) ///
		LEGDecimals(string) LEGFormat(string) ///
		Nquantiles(integer 10) cutpoints(varname numeric) CUTValues(numlist ascending) ///
		hasdatabase OUTputfolder(string) FILEPrefix(string) FILESuffix(string) RESolution(real 1) ///
		restrict_map(string) ///
		*]
	
	preserve

	
	* Load the code for the specified geography
	cap confirm file `"`shapefolder'/`geography'_maptile.ado"'
	if (_rc!=0) {
		di as error `"geography(`geography') specified, but "`geography'_maptile.ado" is not in the shapefolder"'
		exit 198
	}
	cap program drop _maptile_`geography'
	run `"`shapefolder'/`geography'_maptile.ado"'
	
	cap program list _maptile_`geography'
	if (_rc!=0) {
		di as error `""`geography'_maptile.ado" was loaded from the shapefolder, but it does not define a program named _maptile_`geography'"'
		exit 198
	}	
	
	* Set defaults & perform checks
	
	if ("`fileprefix'"!="") local fileprefix `fileprefix'_
	if ("`filesuffix'"!="") local filesuffix _`filesuffix'
	
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
	else if ("`legformat'"=="") local legformat %12.2fc /* XX customize # of decimals to data? */
	
	if "`cutvalues'"!="" & "`cutpoints'"!="" {
		di as error "cannot specify both cutvalues() and cutpoints()"
		exit 198
	}
	
	if "`cutvalues'"!="" & `nquantiles'!=10 {
		di as error "cannot specify both cutvalues() and nquantiles()"
		exit 198
	}
		
	if (`resolution'<=0) {
		di as error "resolution() must be a number greater than 0"
		exit 198
	}
	
	if ("`revcolor'"!="") & ("`fcolor'"!="") {
		di as error "cannot specify revcolor with fcolor()"
		exit 198
	}
	
	if ("`ndfcolor'"=="") local ndfcolor gs12
	
	if (`shrinkcolorscale'>1) | (`shrinkcolorscale'<=0) {
		di as error "shrinkcolorscale() must be greater than 0 and less than or equal to 1"
		exit 198
	}
	
	if (`"`restrict_map'"'!="") local map_restriction & (`restrict_map')
	
	
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
	else if "`fcolor'"!="" {
		di as error "cannot specify rangecolor() with fcolor()"
		exit 198
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
			gr_setscheme , `scheme' refscheme /* XX do I need to add option for scheme? */
			color_load ``i'_color'
			local `i'_r : word 1 of `s(rgb)'
			local `i'_g : word 2 of `s(rgb)'
			local `i'_b : word 3 of `s(rgb)'
		}
	}

	
	tempname clbreaks
	
	* If cutvalues are specified, parse and store them
	if ("`cutvalues'"!="") {
	
		* parse numlist
		numlist "`cutvalues'"
		
		* update nquantiles
		local nquantiles=wordcount(`"`r(numlist)'"')+1
		
		* Store quantile boundaries in list
		matrix `clbreaks'=J(`=`nquantiles'-1',1,.)
		forvalues i=1/`=`nquantiles'-1' {
			matrix `clbreaks'[`i',1]=real(word("`r(numlist)'",`i'))
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
	if ("`hasdatabase'"=="") qui _maptile_`geography', mergedatabase shapefolder(`shapefolder') `options'


	* Map each variable
	local qcount=1
	foreach var of varlist `varlist' {
		
		* Calculate boundaries /* XX is epsfloat still necessary with numeric bounds? */
		tempname min max
		qui sum `var'
		scalar `min'=min(r(min),`clbreaks'[1,`qcount']-epsfloat())
		scalar `max'=max(r(max),`clbreaks'[`=`nquantiles'-1',`qcount']+epsfloat())
		
		* Prepare legend
		forvalues i=1/`nquantiles' {
			local labelnum=`i'+1
			
			local lb string(`clbreaks'[`i'-1,`qcount'],"`legformat'")
			local ub string(`clbreaks'[`i',`qcount'],"`legformat'")
			
			if (`i'==1)					local legend_labels `"label(`labelnum' "< `=`ub''")"'
			else if (`i'==`nquantiles') local legend_labels `"`legend_labels' label(`labelnum' "> `=`lb''")"'
			else						local legend_labels `"`legend_labels' label(`labelnum' "`=`lb'' {&minus} `=`ub''")"'
		}
	
			
		* Place each bin appropriately on the color gradient, if colors not manually specified
		if (`"`fcolor'"'=="") {
			local mapcolors ""
				
			* If doing proportional color scaling, calculate mean value within each quantile
			if ("`propcolor'"!="") {
				tempname quantile_vals QV_length QV_min
				matrix `quantile_vals'=J(`nquantiles',1,.)
			
				forvalues i=1/`nquantiles' {					
					if (`i'==1) 						qui sum `var' if `var'<=`clbreaks'[1,`qcount'], d
					else if (`i'==`nquantiles')			qui sum `var' if `var'>`clbreaks'[`=`nquantiles'-1',`qcount'], d
					else 								qui sum `var' if `var'>`clbreaks'[`i'-1,`qcount'] & `var'<=`clbreaks'[`i',`qcount'], d
					
					if (r(N)>0) matrix `quantile_vals'[`i',1]=r(p50)
					else { /*XX is this the right choice?*/
						if (`i'==1) 					matrix `quantile_vals'[`i',1]=`clbreaks'[1,`qcount']
						else if (`i'==`nquantiles')		matrix `quantile_vals'[`i',1]=`clbreaks'[`=`nquantiles'-1',`qcount']
						else 							matrix `quantile_vals'[`i',1]=(`clbreaks'[`i'-1,`qcount']+`clbreaks'[`i',`qcount'])/2
					}
				}

				scalar `QV_min'=`quantile_vals'[1,1]
				scalar `QV_length'=`quantile_vals'[`nquantiles',1]-`QV_min'
			}
			
			* Reverse color order if needed
			if ("`revcolor'"!="") local flipweights="1 -"
			
			* Compute RGB color values
			forvalues i=1/`nquantiles' {
				if ("`propcolor'"!="") local weight_high=( `flipweights' (`quantile_vals'[`i',1]-`QV_min')/`QV_length' ) * `shrinkcolorscale' + (1-`shrinkcolorscale')/2
				else local weight_high=( `flipweights' (`i'-1)/(`nquantiles'-1) ) * `shrinkcolorscale' + (1-`shrinkcolorscale')/2
				
				local cos_weight_high=1 - cos( `weight_high' * c(pi) / 2 )
				local intensity_weight_high=(`weight_high'+`cos_weight_high')/2
				
				foreach component in r g b {
					local cur_`component'=round(`low_`component''*(1-`cos_weight_high')+`high_`component''*`cos_weight_high')
				}
				local cur_intensity=`low_intensity'*(1-`intensity_weight_high')+`high_intensity'*`intensity_weight_high'
				
				/* XX is this doing equalspacecolors correctly? */
			
				local mapcolors `"`mapcolors' "`cur_r' `cur_g' `cur_b'*`cur_intensity'""'
				
			}
			
		}
		else local mapcolors `fcolor'
		
		
		* Convert clbreaks matrix to string
		local clbreaks_str ""
		forvalues i=1/`=`nquantiles'-1' {
			local clbreaks_str `clbreaks_str' `=`clbreaks'[`i',`qcount']'
		}
		
		* Make maps
		_maptile_`geography', map shapefolder(`shapefolder') ///
			var(`var') ///
			legend_labels(`legend_labels') ///
			min(`=`min'') clbreaks(`clbreaks_str') max(`=`max'') ///
			mapcolors(`"`mapcolors'"') ndfcolor(`ndfcolor') ///
			outputfolder(`outputfolder') fileprefix(`fileprefix') filesuffix(`filesuffix') ///
			resolution(`resolution') ///
			map_restriction(`"`map_restriction'"') ///
			`options'
			
		if ("`cutvalues'"=="") & ("`cutpoints'"=="") local ++qcount
			
	}
	
	* Return objects
	
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

