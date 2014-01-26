*! 15jul2013, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_cz
program define _maptile_cz
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map noconus ak hi var(varname) legend_labels(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					outputfolder(string) fileprefix(string) filesuffix(string) resolution(string) map_restriction(string) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		merge 1:m cz using `"`shapefolder'/cz_database_clean"', nogen
		exit
	}
	
	if ("`map'"!="") {

		if "`conus'"!="noconus" /* XX & (`bigcz'==0) */ {
			spmap `var' using `"`shapefolder'/cz_coords_clean"' if !inrange(cz,34101,34115) & !inlist(cz,34701,34702,34703,35600) `map_restriction', id(id) ///
				oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
				polygon(data(`"`shapefolder'/state_coords_clean"') select(keep if _X>-128) ocolor(black) osize(medthin ...))
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png"', width(`=round(3200*`resolution')') replace
		}
		
		if "`ak'"=="ak" {
			spmap `var' using `"`shapefolder'/cz_coords_clean"' if inrange(cz,34101,34115) `map_restriction', id(id) ///
				oc(black) os(vthin ...) legenda(off) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png"', width(`=round(600*`resolution')') height(`=round(600*`resolution')') replace
		}
			
		if "`hi'"=="hi" {
			spmap `var' using `"`shapefolder'/cz_coords_clean"' if (inrange(cz,34701,34703) | cz==35600) `map_restriction', id(id) ///
				oc(black) os(vthin ...) legenda(off) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png"', replace
		}

	}
	
end
