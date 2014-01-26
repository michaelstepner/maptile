/*
usmaptile, version 0.70, XX July 2013.
Created by Michael Stepner. For assistance, e-mail michaelstepner@gmail.com
Edited by Shelby Lin - added geo(cz), BIGcz(), geo(zip5) and REVcolor options
*/


capture program drop usmaptile
program define usmaptile

	version 11
	
	set more off

	syntax varlist(numeric), shapefolder(string) GEOgraphy(string) [ ///
		fcolor(string) REVcolor EQUalspacecolors SHRINKcolorscale(real 1) NDFcolor(string) ///
		LEGDecimals(string) LEGFormat(string) ///
		Nquantiles(integer 10) cutpoints(varname numeric) cutvalues(numlist ascending) ///
		hasdatabase OUTPUTfolder(string) FILEPrefix(string) FILESuffix(string) RESolution(real 1) ///
		restrict_map(string) ///
		*]
	
	preserve
	
	* Set defaults & perform checks
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
		local legformat="%12.`legdecimals'fc"
	}
	else if ("`legformat'"=="") local legformat="%12.2fc"
	
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
	
	if ("`ndfcolor'"=="") local ndfcolor="gs12"
	
	if (`shrinkcolorscale'>1) | (`shrinkcolorscale'<=0) {
		di as error "shrinkcolorscale() must be greater than 0 and less than or equal to 1"
		exit 198
	}
	
	if (`"`restrict_map'"'!="") local map_restriction `"& (`restrict_map')"'
	
	/* XX
	if (`bigcz'!=0) & "`geography'"!="cz" {
		di as error "cannot specify bigcz() with a geography() other than cz"
		exit 198
	}
	
	if (`bigcz'!=50) & (`bigcz'!=100) & (`bigcz'!=0) {
		di as error "bigcz() must be either 50 or 100"
		exit 198
	}
	*/

	
	* If a cutpoint variable is specified, calculate and store
	if ("`cutpoints'"!="") {
		local clbreaks=""
		local nqm1=`nquantiles'-1
		_pctile `cutpoints', nq(`nquantiles')
		forvalues i=1/`nqm1' {
			local clbreaks `clbreaks' `r(r`i')'
		}

		local rfirst=`r(r1)'
		local rlast=`r(r`nqm1')'
	}
	* If cutvalues are specified, parse and store them
	else if ("`cutvalues'"!="") {
		* parse numlist
		numlist "`cutvalues'"
		local nquantiles=`: word count `r(numlist)''
		local clbreaks `r(numlist)'
		local rfirst=real(word("`r(numlist)'",1))
		local rlast=real(word("`r(numlist)'",-1))
	}
	* If no cutpoint variable or cutvalues were specified, calculate cutpoints for each var separately
	else {
		local nqm1=`nquantiles'-1
		foreach var of varlist `varlist' {
			local cl_`var'=""
			_pctile `var', nq(`nquantiles')
			forvalues i=1/`nqm1' {
				local cl_`var' `cl_`var'' `r(r`i')'
			}
		}
	}

	* Specify color gradient boundaries (Yellow -> Red)
	local low_r=255
	local low_g=255
	local low_b=0
	
	local high_r=255
	local high_g=0
	local high_b=0
	
	local low_intensity=.1
	local high_intensity=1.65	
	
	* Merge in database
	if ("`hasdatabase'"=="") qui _maptile_`geography', mergedatabase shapefolder(`shapefolder') `options'
		/*	
		if ("`geography'"=="zip3") qui merge 1:m zip3 using `"`shapefolder'/zip3_database_clean"', nogen
		else if ("`geography'"=="zip5") qui merge 1:1 zip5 using `"`shapefolder'/zip5_database_clean"', nogen
		else if ("`geography'"=="county") qui merge 1:m county using `"`shapefolder'/county_database_clean"', nogen update replace
		else if ("`geography'"=="state") qui merge 1:1 state using `"`shapefolder'/state_database_new"', nogen keepusing(state id)
		else if ("`geography'"=="statename") {
			qui merge 1:1 statename using `"`shapefolder'/state_database_new"', nogen update replace
			local geography="state"
		}
		else if ("`geography'"=="statefips") {
			qui merge 1:1 statefips using `"`shapefolder'/state_database_new"', nogen update replace
			local geography="state"
		}
		else if ("`geography'"=="cz") qui merge 1:m cz using `"`shapefolder'/cz_database_clean"', nogen
		*/

	* Map each variable
	foreach var of varlist `varlist' {
	
		/* XX If bigCZ() is specified, generate temporary big variable and cutpoint variable just for big areas		if ("`bigcz'"!="") & ("`bigscale'"!="") {			local origvar `var'			qui gen origvar = `var'			replace `var' = . if big`bigcz' != 1			sum `var'		}
		else if ("`bigcz'"!="") local origvar `var'
		*/
	
		* If no cutpoint variable or cutvalues were specified, import the cutpoints calculated for this var
		if ("`cutpoints'"=="") & ("`cutvalues'"=="") {
			local clbreaks `cl_`var''
			local rfirst= real(word("`clbreaks'",1))
			local rlast=  real(word("`clbreaks'",-1))
		}
		
		* Calculate boundaries
		qui sum `var'
		local min=min(`r(min)',`rfirst'-0.0000001)
		local max=max(`r(max)',`rlast'+0.0000001)
		
		* Prepare legend
		forvalues i=1/`nquantiles' {
			local labelnum=`i'+1
			local lb=string(real(word("`min' `clbreaks' `max'",`i')),"`legformat'")
			local ub=string(real(word("`min' `clbreaks' `max'",`i'+1)),"`legformat'")
			
			if (`i'==1)					local legend_labels `"label(`labelnum' "< `ub'")"'
			else if (`i'==`nquantiles') local legend_labels `"`legend_labels' label(`labelnum' "> `lb'")"'
			else						local legend_labels `"`legend_labels' label(`labelnum' "`lb' {&minus} `ub'")"'
		}
			
		* Place each bin appropriately on the color gradient, if colors not manually specified
		if (`"`fcolor'"'=="") {
				
			* Calculate mean values within quantiles
			if ("`equalspacecolors'"=="") {
				forvalues i=1/`nquantiles' {
					local q_lb=real(word("`min' `clbreaks' `max'",`i'))
					local q_ub=real(word("`min' `clbreaks' `max'",`i'+1))
					
					if (`i'==1) qui sum `var' if `var'>=`q_lb' & `var'<=`q_ub'
					else qui sum `var' if `var'>`q_lb' & `var'<=`q_ub'
					
					local q_mean=r(mean)					
					local quantile_means `quantile_means' `q_mean'
				}
				local min_QM=word("`quantile_means'",1)
				local length_QM=real(word("`quantile_means'",-1))-`min_QM'
			}
			
			if ("`revcolor'"!="") local flipweights="1 -"
			
			forvalues i=1/`nquantiles' {
				if ("`equalspacecolors'"=="") local weight_high=( `flipweights' (real(word("`quantile_means'",`i'))-`min_QM')/`length_QM' ) * `shrinkcolorscale' + (1-`shrinkcolorscale')/2
				else local weight_high=( `flipweights' (`i'-1)/(`nquantiles'-1) ) * `shrinkcolorscale' + (1-`shrinkcolorscale')/2
				
				local cos_weight_high=1 - cos( `weight_high' * c(pi) / 2 )
				local intensity_weight_high=(`weight_high'+`cos_weight_high')/2
				
				foreach component in r g b {
					local cur_`component'=round(`low_`component''*(1-`cos_weight_high')+`high_`component''*`cos_weight_high')
				}
				local cur_intensity=`low_intensity'*(1-`intensity_weight_high')+`high_intensity'*`intensity_weight_high'
			
				local mapcolors `"`mapcolors' "`cur_r' `cur_g' `cur_b'*`cur_intensity'""'
				
			}
			
		}
		else local mapcolors `fcolor'
		
		* Make maps
		_maptile_`geography', map shapefolder(`shapefolder') ///
			var(`var') ///
			legend_labels(`legend_labels') ///
			min(`min') clbreaks(`clbreaks') max(`max') ///
			mapcolors(`"`mapcolors'"') ndfcolor(`ndfcolor') ///
			outputfolder(`outputfolder') fileprefix(`fileprefix') filesuffix(`filesuffix') ///
			resolution(`resolution') ///
			map_restriction(`"`map_restriction'"') ///
			`options'
		
		
		/*
		if `"`geography'"'=="zip3" {
			if "`conus'"!="noconus" {
				spmap `var' using "`shapefolder'/zip3_coords_clean" if !((zip3>=995 & zip3<=999) | (zip3>=967 & zip3<=968) | (zip3>=006&zip3<=009)), id(id) ///
					oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png"', width(`=round(3200*`resolution')') replace
			}

			if "`ak'"=="ak" {
				spmap `var' using "`shapefolder'/zip3_coords_clean" if (zip3>=995 & zip3<=999) & !(zip3==995&id>130), id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png", width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
			}

			if "`hi'"=="hi" {
				spmap `var' using "`shapefolder'/zip3_coords_clean" if (zip3>=967 & zip3<=968), id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png", replace
			}
		}
		else if `"`geography'"'=="zip5" {
			if "`conus'"!="noconus" {
				spmap `var' using "`shapefolder'/zip5_coords_clean" if (STATE!="AK") & (STATE!="HI") & (`var'!=.), id(id) ///
					oc(black) os(vthin ...) legend(pos(5) size(*1)) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png"', width(`=round(3200*`resolution')') replace
			}

			if "`ak'"=="ak" {
				spmap `var' using "`shapefolder'/zip5_coords_clean" if (STATE=="AK") & (`var'!=.), id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png", width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
			}

			if "`hi'"=="hi" {
				spmap `var' using "`shapefolder'/zip5_coords_clean" if (STATE=="HI") & (`var'!=.), id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png", replace
			}
		}
		else if `"`geography'"'=="county" {
			if "`conus'"!="noconus" {
				spmap `var' using "`shapefolder'/county_coords_clean" if statefips!=2 & statefips!=15, id(id) ///
					oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png", width(`=round(3200*`resolution')') replace
			}

			if "`ak'"=="ak" {
				spmap `var' using "`shapefolder'/county_coords_clean" if statefips==2, id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png", width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
			}
		
			if "`hi'"=="hi" {
				spmap `var' using "`shapefolder'/county_coords_clean" if statefips==15, id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png", replace
			}
		}
	
		else if `"`geography'"'== "state" {
			
			if "`conus'"!="noconus" {
				spmap `var' using "`shapefolder'/state_coords_new" if state!="AK" & state!="HI", id(id) ///
					oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png", width(`=round(3200*`resolution')') replace
			}

			if "`ak'"=="ak" {
				spmap `var' using "`shapefolder'/state_coords_new" if state=="AK", id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png", width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
			}

			if "`hi'"=="hi" {
				spmap `var' using "`shapefolder'/state_coords_new" if state=="HI", id(id) legenda(off) ///
					oc(black) os(vthin ...) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png", replace
			}
		}
		
		else if `"`geography'"'== "cz" {

			if "`conus'"!="noconus" & (`bigcz'==0) {
				spmap `var' using "`shapefolder'/cz_coords_clean" if (cz<34101 | cz>34115) & cz~=34701 & cz~=34702 & cz~=34703 & cz~=35600, id(id) ///
					oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png", width(`=round(3200*`resolution')') replace
			}
			
			if "`conus'"!="noconus" & (`bigcz'!=0) {
				local sz = max(.9,(51-`bigcz')*1)
				local lineop
				if (`bigcz'==50) {
					local lineop "line(data(`shapefolder'/cz_labellines.dta))"
				}
				spmap `var' using "`shapefolder'/cz_coords_clean" if big`bigcz'==1 & (cz<34101 | cz>34115) & cz~=34701 & cz~=34702 & cz~=34703 & cz~=35600, id(id) ///
					label(l(czname) x(xmean`bigcz') y(ymean`bigcz') length(30) size(*`sz') select(drop if state=="HI" | big`bigcz'==0)) ///
					polygon(data("`shapefolder'/usoutline_coords.dta")) `lineop' ///
					oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')	
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`origvar'_big`bigcz'`filesuffix'.png", width(`=round(3200*`resolution')') replace
			}
		
			if "`ak'"=="ak" {
				spmap `var' using "`shapefolder'/cz_coords_clean" if inrange(cz,34101,34115), id(id) ///
					oc(black) os(vthin ...) legenda(off) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png", width(`=round(3200*`resolution')') replace
			}
			
			if "`hi'"=="hi" {
				spmap `var' using "`shapefolder'/cz_coords_clean" if inrange(cz,34701,34703) | cz==35600, id(id) ///
					oc(black) os(vthin ...) legenda(off) ///
					clmethod(custom) ///
					clbreaks(`min' `clbreaks' `max') ///
					fcolor(`fcolor') ndfcolor(`ndfcolor')
				if (`"`outputfolder'"'!="") graph export "`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png", width(`=round(3200*`resolution')') replace
			}
			
			if ("`bigcz'"!="") & ("`bigscale'"!="") {				qui replace `var' = origvar				qui drop origvar			}
		}
		*/
	}
end

