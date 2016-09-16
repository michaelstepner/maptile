*! 16sep2016, Michael Stepner, stepner@mit.edu

program define _maptile_zip5
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				stateoutline(string) conus ///
			 ]
	
	if ("`mergedatabase'"!="") {
		novarabbrev merge 1:m zip5 using `"`geofolder'/zip5_database"', nogen update replace
		exit
	}
	
	if ("`map'"!="") {

		if ("`conus'"=="conus") {
			* Hide AK and HI from stateoutline
			local polygon_select select(drop if inlist(_ID,27,8))
			
			* Hide AK and HI from main map (using _polygonid, because AK & HI contain missing zip5 values)
			if ("`map_restriction'"=="") local map_restriction if !inrange(_polygonid,48501,50080) & !inrange(_polygonid,46602,46742)
			else local map_restriction `map_restriction' & !inrange(_polygonid,48501,50080) & !inrange(_polygonid,46602,46742)
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
	
		spmap `spmapvar' using `"`geofolder'/zip5_coords"' `map_restriction', id(_polygonid) ///
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

