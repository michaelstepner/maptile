*! 6feb2014, Michael Stepner, michaelstepner@gmail.com

program define _maptile_state
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map var(varname) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				geoid(varname) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		if ("`geoid'"=="state" | "`geoid'"=="") merge 1:1 state using `"`geofolder'/state_database_clean"', nogen keepusing(state id)
		else if ("`geoid'"=="statefips") merge 1:1 statefips using `"`geofolder'/state_database_clean"', nogen update replace
		else if ("`geoid'"=="statename") merge 1:1 statename using `"`geofolder'/state_database_clean"', nogen update replace
		else {
			di as error "with geography(state), geoid() must be 'state', 'statefips', 'statename', or blank"
			exit 198
		}
		exit
	}
	
	if ("`map'"!="") {

		spmap `var' using `"`geofolder'/state_coords_clean"' `map_restriction', id(id) ///
			`legopt' legend(pos(5) size(*1.8)) ///
			clmethod(custom) ///
			clbreaks(`min' `clbreaks' `max') ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vthin ...) nds(vthin) ///
			`spopt'

		* Save graph
		if `"`savegraph'"'!="" {
			* check file extension using a regular expression
			if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
			
			* deal with different filetypes appropriately
			if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
			else if inlist(`"`graphextension'"',".ps",".eps") graph export `"`savegraph'"', mag(`=round(100*`resolution')') `replace'
			else if (`"`graphextension'"'==".png") graph export `"`savegraph'"', width(`=round(3200*`resolution')') `replace'
			else if (`"`graphextension'"'==".tif") graph export `"`savegraph'"', width(`=round(1600*`resolution')') `replace'
			else graph export `"`savegraph'"', `replace'
		}
		
	}
	
end
