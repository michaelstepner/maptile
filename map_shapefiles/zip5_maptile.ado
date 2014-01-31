*! 31jan2014, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_zip5
program define _maptile_zip5
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map var(varname) legend_labels(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					outputfolder(string) fileprefix(string) filesuffix(string) resolution(string) map_restriction(string) ///
					stateoutline ///
			 ]
	
	if ("`mergedatabase'"!="") {
		merge 1:m zip5 using `"`shapefolder'/zip5_database_clean"', nogen update replace
		exit
	}
	
	if ("`map'"!="") {
	
		if ("`stateoutline'"!="") {
			cap confirm file `"`shapefolder'/state_coords_clean.dta"'
			if (_rc==0) local polygon polygon(data(`"`shapefolder'/state_coords_clean"') ocolor(black) osize(thin ...))
			else if (_rc==601) {
				di as error `"stateoutline option requires 'state_coords_clean.dta' in the shapefolder"'
				exit 198				
			}
			else {
				error _rc
				exit _rc
			}
		}
	
		spmap `var' using `"`shapefolder'/zip5_coords_clean"' `map_restriction', id(id) ///
			legend(`legend_labels' pos(5) size(*1.8)) ///
			clmethod(custom) ///
			clbreaks(`min' `clbreaks' `max') ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vvthin ...) nds(vvthin) ///
			`polygon'
		if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'`filesuffix'.png"', width(`=round(3200*`resolution')') replace

	}
	
end
