*! 25nov2015, Arash Farahani

/*XX update the date above. change the author and e-mail address to be your own. */
/*XX choose a name for your new geography and change the name of this ado-file to be: geoname_maptile.ado */

program define _maptile_msa2000 /*XX change "demo" to your chosen geoname. ex: _maptile_state */
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				/*XX you can add new options specific to your geography here (or delete XXexampleoption).
					 when a user includes options in their maptile command that aren't mentioned
					 in the maptile help file, they are passed to this program. */ ///
				XXexampleoption(string) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		/* XX make sure the geographic ID variable you choose is contained in geoname_database.dta */
		novarabbrev merge 1:m msa  ///
			using `"`geofolder'/msa2000_database_clean.dta"', nogen /*XX change "geoname_database.dta" to the name of your shapefile database file*/
			rename id _ID
		exit
	}
	
	if ("`map'"!="") {
		/* XX make sure the polygon ID variable in your geoname_database.dta matches the variable name in id() */
		spmap `spmapvar' using `"`geofolder'/msa2000_coords_clean.dta"' `map_restriction', id(_ID) /// /*XX change "geoname_coords.dta" to the name of your shapefile coordinates file*/
			`clopt' ///
			`legopt' ///
			legend(pos(5) size(*1.8)) /// /*XX change the default placement and size of the legend as appropriate for your map*/
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vthin ...) nds(vthin) ///
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

