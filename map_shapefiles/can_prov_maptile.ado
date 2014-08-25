*! 25aug2014, Michael Stepner, stepner@mit.edu

program define _maptile_can_prov
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				geoid(varname) mapifprov legendoffset(real -9999.9) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		if ("`geoid'"=="") local geoid prov
		
		if inlist("`geoid'","prov","provcode","provcode_old","provname") {
			novarabbrev merge 1:1 `geoid' using `"`geofolder'/can_prov_database"', nogen keepusing(`geoid' _polygonid)
		}
		else {
			di as error "with geography(can_prov), geoid() must be 'prov', 'provcode', 'provcode_old', 'provname', or blank"
			exit 198
		}
		exit
	}
	
	if ("`map'"!="") {
	
		* Check invalid legendoffset()
		if `legendoffset'!=-9999.9 & `legendoffset'<0 {
			di as error "legendoffset() must be a positive number"
			exit 198
		}
		
		* Only map provinces, not territories
		if ("`mapifprov'"=="mapifprov") {
		
			* Map restriction
			if (`"`map_restriction'"'!="") local map_restriction `map_restriction' & !inlist(_polygonid,6,10,3)
			else local map_restriction if !inlist(_polygonid,6,10,3)

			* Calculate legend offset
			if `legendoffset'==-9999.9 { /* automatically calculate legend offset */
				qui tab `binvar'
				if (r(r)>=5) local legendoffset=1+(r(r)-5)*2.26
				else local legendoffset=0
			}

			* Legend size (keep fixed text size, because in Stata sizes are relative)
			local legendstyle size(`=6*(35.720543/(35.720543+`legendoffset'))')
		}
		else {
		
			* Calculate legend offset
			if `legendoffset'==-9999.9 { /* automatically calculate legend offset */
				qui tab `binvar'
				if (r(r)>=4) local legendoffset=2.7+(r(r)-4)*2.75
				else local legendoffset=0
			}
		
			* Legend size (keep fixed text size, because in Stata sizes are relative)
			local legendstyle size(`=3.75 * 70.845001 / min(70.845001+`legendoffset',88.398665) ')
		}

		* Create legendoffset() data
			* Note: This is a crude hack that avoids the legend overlapping the map.
			* ---> Have a better solution? I'd love to hear it. E-mail me at stepner@mit.edu
		if `legendoffset'>0 {
			preserve
			clear
			qui set obs 1
			gen x=-82.12147
			gen y=71.23357-`legendoffset'
			tempfile legendpoint
			qui save `legendpoint'.dta, replace
			restore
			
			local legendshift point(data("`legendpoint'") xcoord(x) ycoord(y) shape(i))			
		}

		* Draw map
		spmap `binvar' using `"`geofolder'/can_prov_coords"' `map_restriction', id(_polygonid) ///
			`clopt' ///
			`legopt' ///
			legend(pos(8) ring(0) `legendstyle') ///
			`legendshift' ///
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

