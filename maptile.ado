*! version 0.70beta4  XXaug2014  Michael Stepner, stepner@mit.edu

/*** Unlicence (abridged):
This is free and unencumbered software released into the public domain.
It is provided "AS IS", without warranty of any kind.

For the full legal text of the Unlicense, see <http://unlicense.org>
*/

* Why did I include a formal license? Jeff Atwood gives good reasons:
*  http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html

/* XX
- change docs to reflect renaming cutpoints() to QVar()
- actually implement a conventional cutpoints option
*/

program define maptile, rclass
	version 11
	
	set more off

	syntax varname(numeric) [if] [in], GEOgraphy(string) [ ///
		Nquantiles(integer 6) QVar(varname numeric) CUTValues(numlist ascending) ///
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
	
	if "`cutvalues'"!="" & "`qvar'"!="" {
		di as error "cannot specify both cutvalues() and qvar()"
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


	* If cutvalues specified, calculate number of categories
	if ("`cutvalues'"!="") {
	
		* parse numlist
		numlist "`cutvalues'"
		
		* update nquantiles
		local nquantiles : word count `r(numlist)'
		local ++nquantiles
		
	}
	
	* Prepare empty matrix of break points
	tempname clbreaks
	
	if ("`cutvalues'"!="") | ("`qvar'"!="") matrix `clbreaks'=J(`=`nquantiles'-1',1,.)
	else matrix `clbreaks'=J(`=`nquantiles'-1',`:word count `varlist'',.)

	* Prepare empty matrix of indicators for whether a bin is non-empty
	tempname binexists
	matrix `binexists'=J(`nquantiles',`:word count `varlist'',0)


	* Create quantile category var, store quantile boundaries in matrix, create indicators for non-empty bins
	tempname binnums
	local varcount=1
	foreach var of varlist `varlist' {

		* Create quantile category var
		tempvar qcat`varcount'
		if ("`cutvalues'"!="") fastxtile `qcat`varcount''=`var', cutvalues(`cutvalues')
		else fastxtile `qcat`varcount''=`var', nq(`nquantiles')
		
		* Store quantile boundaries in list
		forvalues i=1/`=`nquantiles'-1' {
			matrix `clbreaks'[`i',`varcount']=r(r`i')
		}
		
		* Fill indicators for non-empty bins
		qui tab `qcat`varcount'', matrow(`binnums')
		forvalues i=1/`r(r)' {
			matrix `binexists'[`binnums'[`i',1],`varcount']=1
		}

		local ++varcount
	}
	
	if ("`cutvalues'"!="") matrix colnames `clbreaks' = cutvalues
	else if ("`qvar'"!="") matrix colnames `clbreaks' = `qvar'
	else matrix colnames `clbreaks' = `varlist'
	

	
	* Merge in database
	if ("`hasdatabase'"=="") qui _maptile_`geography', mergedatabase geofolder(`geofolder') `options'


	* Map each variable
	local qcount=1
	foreach var of varlist `varlist' {
		
		* Calculate min/max
		tempname min max
		qui sum `var', meanonly
		scalar `min'=r(min)
		scalar `max'=r(max)
		
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
			if (`rbig'>=10^7) local legformat %12.1e
			else if (`rinteger'==1) local legformat %12.0fc
			else if (`rbig'>=1000) local legformat %12.0fc
			else if (`rbig'>=100) local legformat %12.1fc
			else if (`rbig'>=1) local legformat %12.2fc
			else if (`rsmall'>=0.01) local legformat %12.3fc
			else if (`rsmall'>=0.001) & (`rlast'-`rfirst'>=0.001*`nquantiles'*2) local legformat %12.3fc
			else if (`rsmall'>=0.0001) & (`rlast'-`rfirst'>=0.0001*`nquantiles'*2) local legformat %12.4fc
			else local legformat %12.1e
		}
		format `var' `legformat'
	
			
		* Place each bin appropriately on the color gradient, if colors not manually specified
		if (`"`fcolor'"'=="") {
			local mapcolors ""
				
			* If doing proportional color scaling, calculate median value within each quantile
			if ("`propcolor'"!="") {
				tempname quantile_vals
				matrix `quantile_vals'=J(`nquantiles',1,.)
			
				forvalues i=1/`nquantiles' {
					* Skip this bin if it is empty
					if (`binexists'[`i',`qcount']==0) continue
				
					if (`i'==1) 					qui _pctile `var' if `var'<=`clbreaks'[1,`qcount'], percentiles(50)
					else if (`i'==`nquantiles')		qui _pctile `var' if `var'>`clbreaks'[`=`nquantiles'-1',`qcount'], percentiles(50)
					else 							qui _pctile `var' if `var'>`clbreaks'[`i'-1,`qcount'] & `var'<=`clbreaks'[`i',`qcount'], percentiles(50)
					
					if !mi(r(r1)) matrix `quantile_vals'[`i',1]=r(r1)
					else { /* no data, so pick the midpoint of the interval -- this should no longer happen because we skip empty bins */
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
			forvalues i=1/`nquantiles' {
			
				* Skip this bin if it is empty
				if (`binexists'[`i',`qcount']==0) continue
			
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
		
		
		* Convert clbreaks matrix to string without duplicate values
		local clbreaks_str ""
		forvalues i=1/`=`nquantiles'-1' {
		
			if (`i'==1 & `clbreaks'[`i',`qcount']==`min') continue
			else if (`clbreaks'[`i',`qcount']==`clbreaks'[`=`i'-1',`qcount']) continue
			else if (`i'==`=`nquantiles'-1' & `clbreaks'[`i',`qcount']==`max') continue
			
			local clbreaks_str `clbreaks_str' `=`clbreaks'[`i',`qcount']'
		
		}
		
		* Prepare legend
		local leglabels ""
		local llcount 2
		forvalues i=1/`nquantiles' {
		
			* Skip this bin if it is empty
			if (`binexists'[`i',`qcount']==0) continue
		
			
			if (`i'==1) local leglabels `leglabels' label(`llcount' "`:display string(`min',"`legformat'")' {&minus} `:display string(`clbreaks'[`i',`qcount'],"`legformat'")'")
			else if (`i'==`nquantiles') local leglabels `leglabels' label(`llcount' "`:display string(`clbreaks'[`i'-1,`qcount'],"`legformat'")' {&minus} `:display string(`max',"`legformat'")'")
			else local leglabels `leglabels' label(`llcount' "`:display string(`clbreaks'[`i'-1,`qcount'],"`legformat'")' {&minus} `:display string(`clbreaks'[`i',`qcount'],"`legformat'")'")
			
			local ++llcount
		}
		
		local legopt legorder(hilo) legend(`leglabels')

		
		* Make maps
		_maptile_`geography', map geofolder(`geofolder') ///
			var(`var') ///
			binvar(`qcat`qcount'') ///
			clopt(clmethod(unique)) ///
			legopt(`"`legopt'"') ///
			min(`=`min'') clbreaks(`clbreaks_str') max(`=`max'') ///
			mapcolors(`"`mapcolors'"') ndfcolor(`ndfcolor') ///
			savegraph(`savegraph') `replace' resolution(`resolution') ///
			map_restriction(`"`map_restriction'"') ///
			spopt(`spopt') ///
			`options'
			
		if ("`cutvalues'"=="") & ("`qvar'"=="") local ++qcount
			
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

* fastxtile version 1.22  24jul2014  Michael Stepner, stepner@mit.edu
program define fastxtile, rclass
	version 11

	* Parse weights, if any
	_parsewt "aweight fweight pweight" `0' 
	local 0  "`s(newcmd)'" /* command minus weight statement */
	local wt "`s(weight)'"  /* contains [weight=exp] or nothing */

	* Extract parameters
	syntax newvarname=/exp [if] [in] [,Nquantiles(integer 2) Cutpoints(varname numeric) ALTdef ///
		CUTValues(numlist ascending) randvar(varname numeric) randcut(real 1) randn(integer -1)]

	* Mark observations which will be placed in quantiles
	marksample touse, novarlist
	markout `touse' `exp'
	qui count if `touse'
	local popsize=r(N)

	if "`cutpoints'"=="" & "`cutvalues'"=="" { /***** NQUANTILES *****/
		if `"`wt'"'!="" & "`altdef'"!="" {
			di as error "altdef option cannot be used with weights"
			exit 198
		}
		
		if `randn'!=-1 {
			if `randcut'!=1 {
				di as error "cannot specify both randcut() and randn()"
				exit 198
			}
			else if `randn'<1 {
				di as error "randn() must be a positive integer"
				exit 198
			}
			else if `randn'>`popsize' {
				di as text "randn() is larger than the population. using the full population."
				local randvar=""
			}
			else {
				local randcut=`randn'/`popsize'
				
				if "`randvar'"!="" {
					qui sum `randvar', meanonly
					if r(min)<0 | r(max)>1 {
						di as error "with randn(), the randvar specified must be in [0,1] and ought to be uniformly distributed"
						exit 198
					}
				}
			}
		}

		* Check if need to gen a temporary uniform random var
		if "`randvar'"=="" {
			if (`randcut'<1 & `randcut'>0) { 
				tempvar randvar
				gen `randvar'=runiform()
			}
			* randcut sanity check
			else if `randcut'!=1 {
				di as error "if randcut() is specified without randvar(), a uniform r.v. will be generated and randcut() must be in (0,1)"
				exit 198
			}
		}

		* Mark observations used to calculate quantile boundaries
		if ("`randvar'"!="") {
			tempvar randsample
			mark `randsample' `wt' if `touse' & `randvar'<=`randcut'
		}
		else {
			local randsample `touse'
		}

		* Error checks
		qui count if `randsample'
		local samplesize=r(N)
		if (`nquantiles' > r(N) + 1) {
			if ("`randvar'"=="") di as error "nquantiles() must be less than or equal to the number of observations [`r(N)'] plus one"
			else di as error "nquantiles() must be less than or equal to the number of sampled observations [`r(N)'] plus one"
			exit 198
		}
		else if (`nquantiles' < 2) {
			di as error "nquantiles() must be greater than or equal to 2"
			exit 198
		}

		* Compute quantile boundaries
		_pctile `exp' if `randsample' `wt', nq(`nquantiles') `altdef'

		* Store quantile boundaries in list
		local maxlist 248
		forvalues i=1/`=`nquantiles'-1' {
			local cutvallist`=ceil(`i'/`maxlist')' `cutvallist`=ceil(`i'/`maxlist')'' r(r`i')
		}
	}
	else if "`cutpoints'"!="" { /***** CUTPOINTS *****/
	
		* Parameter checks
		if "`cutvalues'"!="" {
			di as error "cannot specify both cutpoints() and cutvalues()"
			exit 198
		}		
		if "`wt'"!="" | "`randvar'"!="" | "`ALTdef'"!="" | `randcut'!=1 | `nquantiles'!=2 | `randn'!=-1 {
			di as error "cutpoints() cannot be used with nquantiles(), altdef, randvar(), randcut(), randn() or weights"
			exit 198
		}

		* Find quantile boundaries from cutpoints var
		mata: process_cutp_var("`cutpoints'")

		* Store quantile boundaries in list
		if r(nq)==1 {
			di as error "cutpoints() all missing"
			exit 2000
		}
		else {
			local nquantiles = r(nq)
			
			local maxlist 248
			forvalues i=1/`=`nquantiles'-1' {
				local cutvallist`=ceil(`i'/`maxlist')' `cutvallist`=ceil(`i'/`maxlist')'' r(r`i')
			}
		}
	}
	else { /***** CUTVALUES *****/
		if "`wt'"!="" | "`randvar'"!="" | "`ALTdef'"!="" | `randcut'!=1 | `nquantiles'!=2 | `randn'!=-1 {
			di as error "cutvalues() cannot be used with nquantiles(), altdef, randvar(), randcut(), randn() or weights"
			exit 198
		}
		
		* parse numlist
		numlist "`cutvalues'"
		local maxlist=-1
		local cutvallist1 `"`r(numlist)'"'
		local nquantiles : word count `r(numlist)'
		local ++nquantiles
	}

	* Pick data type for quantile variable
	if (`nquantiles'<=maxbyte()) local qtype byte
	else if (`nquantiles'<=maxint()) local qtype int
	else local qtype long

	* Create quantile variable
	local cutvalcommalist : subinstr local cutvallist1 " " ",", all
	qui gen `qtype' `varlist'=1+irecode(`exp',`cutvalcommalist') if `touse'
	
	forvalues i=2/`=ceil((`nquantiles'-1)/`maxlist')' {
		local cutvalcommalist : subinstr local cutvallist`i' " " ",", all
		qui replace `varlist'=1 + `maxlist'*(`i'-1) + irecode(`exp',`cutvalcommalist') if `varlist'==1 + `maxlist'*(`i'-1)
	}

	label var `varlist' "`nquantiles' quantiles of `exp'"

	* Return values
	if ("`samplesize'"!="") return scalar n = `samplesize'
	else return scalar n = .
	
	return scalar N = `popsize'
	
	local c=`nquantiles'-1
	forvalues j=`=max(ceil((`nquantiles'-1)/`maxlist'),1)'(-1)1 {
		tokenize `"`cutvallist`j''"'
		forvalues i=`: word count `cutvallist`j'''(-1)1 {
			return scalar r`c' = ``i''
			local --c
		}
	}

end


version 11
set matastrict on

mata:

void process_cutp_var(string scalar var) {

	// Load and sort cutpoints	
	real colvector cutp
	cutp=sort(st_data(.,st_varindex(var)),1)
	
	// Return them to Stata
	stata("clear results")
	real scalar ind
	ind=1
	while (cutp[ind]!=.) {
		st_numscalar("r(r"+strofreal(ind)+")",cutp[ind])
		ind=ind+1
	}
	st_numscalar("r(nq)",ind)
	
}

end

