*! 20Mar2019  Chigusa Okamoto(okamoto.chigusa.econ@gmail.com, okamoto-chigusa546@g.ecc.u-tokyo.ac.jp) 
* and Michael Stepner (stepner@mit.edu, michaelstepner@gmail.com)


program define _maptile_jpn_mun2015 
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				compressed ///
				district ///
			 ]

			 
	if ("`district'" == "") local unit _city
	if ("`district'" == "district") local unit _district
	if ("`compressed'" == "compressed") local polygon _compressed


	if ("`mergedatabase'"!="") {

		novarabbrev merge 1:1 mun using `"`geofolder'/jpn_mun2015_database`unit'.dta"', nogen
		exit
	}
	
	if ("`map'"!="") {
		
		spmap `spmapvar' using `"`geofolder'/jpn_mun2015_coords`unit'`polygon'.dta"' `map_restriction', id(_ID) /// 
			`clopt' ///
			`legopt' ///
			legend(pos(5) size(*1.3)) /// 
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vvthin ...) nds(vthin) ///
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

