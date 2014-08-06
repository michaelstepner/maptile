*! 06aug2014, Michael Stepner, stepner@mit.edu

program define _maptile_can_prov
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map var(varname) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				geoid(varname) legendoffset(real -9999.9) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		if ("`geoid'"=="") local geoid prov
		
		if inlist("`geoid'","prov","provcode","provcode_old","provname") {
			merge 1:1 `geoid' using `"`geofolder'/can_prov_database"', nogen keepusing(`geoid' polygonid)
		}
		else {
			di as error "with geography(can_prov), geoid() must be 'prov', 'provcode', 'provcode_old', 'provname', or blank"
			exit 198
		}
		exit
	}
	
	if ("`map'"!="") {
	
		* This is a crude hack that avoids the legend overlapping the map.
			* ---> Have a better suggestion? I'd love to hear it. E-mail me at stepner@mit.edu
			
		if `legendoffset'==-9999.9 { /* automatically calculate legend offset */
			local nq : word count `min' `clbreaks' 
			if (`nq'>=4) local legendoffset=(`nq'-3)*3.55
			else local legendoffset=0
		}
		else if `legendoffset'<0 {
			di as error "legendoffset() must be a positive number"
			exit 198
		}
		
		if `legendoffset'>0 {
			preserve
			clear
			qui set obs 1
			gen x=-141
			gen y=72.95-`legendoffset'
			tempfile legendpoint
			qui save `legendpoint'.dta, replace
			restore
			
			local legendshift point(data("`legendpoint'") xcoord(x) ycoord(y) shape(i))			
		}

		* Draw map
		spmap `var' using `"`geofolder'/can_prov_coords"' `map_restriction', id(polygonid) ///
			`legopt' ///
			legend(pos(8) ring(0) size(*1.8)) ///
			`legendshift' ///
			clmethod(custom) ///
			clbreaks(`min' `clbreaks' `max') ///
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

