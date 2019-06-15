*! 7Mar2019  Chigusa Okamoto(okamoto.chigusa.econ@gmail.com, okamoto-chigusa546@g.ecc.u-tokyo.ac.jp) 
* and Michael Stepner (stepner@mit.edu, michaelstepner@gmail.com)


program define _maptile_jpn_pref 
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				simple /// 
				compressed ///
				geoid(varname) ///
			 ]

			 
	if ("`simple'" == "simple" & "`compressed'" == "") local polygon _simple
	if ("`simple'" == "" & "`compressed'" == "compressed") local polygon _compressed
	if ("`simple'" == "simple" & "`compressed'" == "compressed") local polygon _simple_compressed		 
			 

	if ("`mergedatabase'"!="") {
		if ("`geoid'"=="") local geoid pref
		
		if inlist("`geoid'", "pref", "prefname", "prefname_jpn") novarabbrev merge 1:1 `geoid' using `"`geofolder'/jpn_pref_database.dta"', nogen keepusing(`geoid' _ID)
		else{
			di as error "with geography(jpn_pref), geoid() must be 'pref', 'prefname', 'prefname_jpn', or blank"
			exit 198
		}
		
		exit
	}
	
	if ("`map'"!="") {		
		
		spmap `spmapvar' using `"`geofolder'/jpn_pref_coords`polygon'.dta"' `map_restriction', id(_ID) /// 
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

