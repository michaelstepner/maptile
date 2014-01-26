*! 6jul2013, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_county1990
program define _maptile_county1990
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map noconus ak hi var(varname) legend_labels(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					outputfolder(string) fileprefix(string) filesuffix(string) resolution(string) map_restriction(string) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		merge 1:m county using `"`shapefolder'/county1990_database_clean"', nogen update replace
		exit
	}
	
	if ("`map'"!="") {
	
		if "`conus'"!="noconus" {
			spmap `var' using `"`shapefolder'/county1990_coords_clean"' if statefips!=2 & statefips!=15 `map_restriction', id(id) ///
				oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png"', width(`=round(3200*`resolution')') replace
		}

		if "`ak'"=="ak" {
			spmap `var' using `"`shapefolder'/county1990_coords_clean"' if statefips==2 `map_restriction', id(id) legenda(off) ///
				oc(black) os(vthin ...) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png"', width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
		}
	
		if "`hi'"=="hi" {
			spmap `var' using `"`shapefolder'/county1990_coords_clean"' if statefips==15 `map_restriction', id(id) legenda(off) ///
				oc(black) os(vthin ...) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png"', replace
		}

	}
	
end
