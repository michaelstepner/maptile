*! 6aug2016, Meru Bhanot, meru@uchicago.edu

program define _maptile_msapmsa2000
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) nostateoutline conus]
	
	if ("`mergedatabase'"!="") {
		novarabbrev merge 1:m msapmsa2000 ///
			using `"`geofolder'/msapmsa2000_database.dta"', nogen
		exit
	}
	
	if ("`stateoutline'" != "nostateoutline") {
		local borderscode `"polygon(data("`geofolder'/msapmsa2000_stateborders.dta") ocolor(gs7) osize(medthin ...))"'
	}

	if ("`conus'"=="conus") {
		drop if inlist(msapmsa2000,3320,380)  // Drop Hawaii and Alaska: http://www.census.gov/population/estimates/metro-city/99mfips.txt
		local legopt2 = "legend(pos(8) size(small))"
	}

	else {
		local legopt2 = "legend(size(small) ring(1) position(6) cols(3) colfirst)"
	}

	if ("`stateoutline'" != "nostateoutline") & ("`conus'"=="conus") {
		local borderscode `"polygon(data("`geofolder'/msapmsa2000_stateborders_noAKHI.dta") ocolor(gs7) osize(medthin ...))"'
	}

	if ("`map'"!="") {
		spmap `spmapvar' using `"`geofolder'/msapmsa2000_coords.dta"' `map_restriction', id(_ID) ///
			`clopt' ///
			`legopt' ///
			`legopt2' /// 
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vvthin ...) nds(vvthin) mos(vvthin) ///
			`borderscode' ///
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

