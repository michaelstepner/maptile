*! 25aug2014, Michael Stepner, stepner@mit.edu

program define _maptile_can_er
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
				provoutline(string) mapifprov legendoffset(real -9999.9) ///
			 ]
	
	if ("`mergedatabase'"!="") {
		novarabbrev merge 1:1 er using `"`geofolder'/can_er_database"', nogen keepusing(er _polygonid)
		exit
	}
	
	if ("`map'"!="") {
	
		* Check invalid legendoffset()
		if `legendoffset'!=-9999.9 & `legendoffset'<0 {
			di as error "legendoffset() must be a positive number"
			exit 198
		}
	
		* Outline on provincial boundaries (undocumented because Stata graph makes it look ugly on jagged borders)
		if ("`provoutline'"!="") {
			cap confirm file `"`geofolder'/can_prov_coords.dta"'
			if (_rc==0) local polygon polygon(data(`"`geofolder'/can_prov_coords"') ocolor(black) osize(`provoutline' ...))
			else if (_rc==601) {
				di as error `"provoutline() requires the {it:can_prov} geography to be installed"'
				di as error `"--> can_prov_coords.dta must be present in the geofolder"'
				exit 198				
			}
			else {
				error _rc
				exit _rc
			}
		}
		
		* Only map provinces, not territories
		if ("`mapifprov'"=="mapifprov") {
		
			* Map restriction
			if (`"`map_restriction'"'!="") local map_restriction `map_restriction' & er<6000
			else local map_restriction if er<6000

			* Calculate legend offset
			if `legendoffset'==-9999.9 { /* automatically calculate legend offset */
				if ("`spmapvar'"=="`binvar'") {
					qui tab `binvar'
					local nq=r(r)
				}
				else local nq : word count `min' `clbreaks'
				if (`nq'>=5) local legendoffset=1+(`nq'-5)*2.26
				else local legendoffset=0
			}

			* Legend size (keep fixed text size, because in Stata sizes are relative)
			local legendstyle size(`=6*(35.720543/(35.720543+`legendoffset'))')
		}
		else {
		
			* Calculate legend offset
			if `legendoffset'==-9999.9 { /* automatically calculate legend offset */
				if ("`spmapvar'"=="`binvar'") {
					qui tab `binvar'
					local nq=r(r)
				}
				else local nq : word count `min' `clbreaks' 
				if (`nq'>=4) local legendoffset=2.7+(`nq'-4)*2.75
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
		spmap `spmapvar' using `"`geofolder'/can_er_coords"' `map_restriction', id(_polygonid) ///
			`clopt' ///
			`legopt' ///
			legend(pos(8) ring(0) `legendstyle') ///
			`legendshift' ///
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

