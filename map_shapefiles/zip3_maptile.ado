*! 6jul2013, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_zip3
program define _maptile_zip3
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map noconus ak hi var(varname) legend_labels(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					outputfolder(string) fileprefix(string) filesuffix(string) resolution(string) map_restriction(string) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		merge 1:m zip3 using `"`shapefolder'/zip3_database_clean"', nogen
		exit
	}
	
	if ("`map'"!="") {
	
		if "`conus'"!="noconus" {
			spmap `var' using `"`shapefolder'/zip3_coords_clean"' if !inrange(zip3,995,999) & !inlist(zip3,967,968) `map_restriction', id(id) ///
				oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png"', width(`=round(3200*`resolution')') replace
		}

		if "`ak'"=="ak" {
			spmap `var' using `"`shapefolder'/zip3_coords_clean"' if inrange(zip3,995,999) `map_restriction', id(id) legenda(off) ///
				oc(black) os(vthin ...) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png"', width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
		}

		if "`hi'"=="hi" {
			spmap `var' using `"`shapefolder'/zip3_coords_clean"' if inlist(zip3,967,968) `map_restriction', id(id) legenda(off) ///
				oc(black) os(vthin ...) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png"', replace
		}

	}
	
end
