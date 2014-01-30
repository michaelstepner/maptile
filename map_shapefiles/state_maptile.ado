*! 6jul2013, Michael Stepner, michaelstepner@gmail.com

capture program drop _maptile_state
program define _maptile_state
	syntax , [  shapefolder(string) ///
				mergedatabase ///
				map noconus ak hi var(varname) legend_labels(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					outputfolder(string) fileprefix(string) filesuffix(string) resolution(string) map_restriction(string) ///
				geoid(varname) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		if ("`geoid'"=="state" | "`geoid'"=="") merge 1:1 state using `"`shapefolder'/state_database_clean"', nogen keepusing(state id)
		else if ("`geoid'"=="statefips") merge 1:1 statefips using `"`shapefolder'/state_database_clean"', nogen update replace
		else if ("`geoid'"=="statename") merge 1:1 statename using `"`shapefolder'/state_database_clean"', nogen update replace
		else {
			di as error "with geography(state), geoid() must be 'state', 'statefips', 'statename', or blank"
			exit 198
		}
		exit
	}
	
	if ("`map'"!="") {
	
		if "`conus'"!="noconus" {
			spmap `var' using `"`shapefolder'/state_coords_clean"' if state!="AK" & state!="HI" `map_restriction', id(id) ///
				oc(black) os(vthin ...) legend(`legend_labels' pos(5) size(*1.8)) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_continental`filesuffix'.png"', width(`=round(3200*`resolution')') replace
		}

		if "`ak'"=="ak" {
			spmap `var' using `"`shapefolder'/state_coords_clean"' if state=="AK" `map_restriction', id(id) legenda(off) ///
				oc(black) os(vthin ...) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_AK`filesuffix'.png"', width(`=round(600*`resolution')') replace
		}

		if "`hi'"=="hi" {
			spmap `var' using `"`shapefolder'/state_coords_clean"' if state=="HI" `map_restriction', id(id) legenda(off) ///
				oc(black) os(vthin ...) ///
				clmethod(custom) ///
				clbreaks(`min' `clbreaks' `max') ///
				fcolor(`mapcolors') ndfcolor(`ndfcolor')
			if (`"`outputfolder'"'!="") graph export `"`outputfolder'/`fileprefix'`var'_HI`filesuffix'.png"', replace
		}

	}
	
end
