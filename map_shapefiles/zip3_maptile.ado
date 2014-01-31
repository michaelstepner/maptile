*! 6jul2013, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_zip3
program define _maptile_zip3
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map var(varname) legend_labels(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					outputfolder(string) fileprefix(string) filesuffix(string) resolution(string) map_restriction(string) ///
					stateoutline ///
			 ]
	
	if ("`mergedatabase'"!="") {
		merge 1:m zip3 using `"`shapefolder'/zip3_database_clean"', nogen
		exit
	}
	
	if ("`map'"!="") {
	
		if ("`stateoutline'"!="") {
			local oc gs2 ...
			local polygon polygon(data(`"`shapefolder'/state_coords_clean"') ocolor(black) osize(thin ...))
		}
		else {
			local oc black ...
		}
	
		spmap `var' using `"`shapefolder'/zip3_coords_clean"' `map_restriction', id(id) ///
			oc(`oc') os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
			clmethod(custom) ///
			clbreaks(`min' `clbreaks' `max') ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			`polygon'
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'`filesuffix'.png"', width(`=round(3200*`resolution')') replace

	}
	
end
