*! 29jul2017  Maithreyi Gopalan (smgopala@indiana.edu) and Michael Stepner (stepner@mit.edu)

program define _maptile_cz2000
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				stateoutline(string) conus ///
			 ]
	
	if ("`mergedatabase'"!="") {
		novarabbrev merge 1:m cz using `"`geofolder'/cz2000_database"', nogen
		exit
	}
	
	if ("`map'"!="") {
	
		if ("`conus'"=="conus") {
			* Hide AK and HI from stateoutline
			local polygon_select select(drop if inlist(_ID,27,8))
			
			* Hide AK and HI from main map
			if ("`map_restriction'"=="") local map_restriction if !inlist(cz,103,171,290,378,638,639,645,649,660,667,668,679,692,696,701,702,706,707,901)
			else local map_restriction `map_restriction' & !inlist(cz,103,171,290,378,638,639,645,649,660,667,668,679,692,696,701,702,706,707,901)
		}

		if ("`stateoutline'"!="") {
			cap confirm file `"`geofolder'/state_coords_clean.dta"'
			if (_rc==0) local polygon polygon(data(`"`geofolder'/state_coords_clean"') ocolor(black) osize(`stateoutline' ...) `polygon_select')
			else if (_rc==601) {
				di as error `"stateoutline() requires the {it:state} geography to be installed"'
				di as error `"--> state_coords_clean.dta must be present in the geofolder"'
				exit 198				
			}
			else {
				error _rc
				exit _rc
			}
		}

		spmap `spmapvar' using `"`geofolder'/cz2000_coords"' `map_restriction', id(id) ///
			`clopt' ///
			`legopt' ///
			legend(pos(5) size(*1.8)) ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vvthin ...) nds(vvthin) ///
			`polygon' ///
			`spopt'
			
		* Save graph
		if (`"`savegraph'"'!="") __savegraph_maptile, savegraph(`savegraph') resolution(`resolution') `replace'
		
	}
	
end

* Save map to file
cap program drop __savegraph_maptile
program define __savegraph_maptile

	syntax, savegraph(string) resolution(string) [replace]
	
	* check file extension using a regular expression
	if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
	
	* deal with different filetypes appropriately
	if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
	else if inlist(`"`graphextension'"',".ps",".eps") graph export `"`savegraph'"', mag(`=round(100*`resolution')') `replace'
	else if (`"`graphextension'"'==".png") graph export `"`savegraph'"', width(`=round(3200*`resolution')') `replace'
	else if (`"`graphextension'"'==".tif") graph export `"`savegraph'"', width(`=round(1600*`resolution')') `replace'
	else graph export `"`savegraph'"', `replace'

end

