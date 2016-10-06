*! 5oct2016 Paul Goldsmith-Pinkham (paulgp@gmail.com) and Michael Stepner (stepner@mit.edu)

program define _maptile_statehex
	syntax , [  geofolder(string) ///
				mergedatabase ///
				map spmapvar(varname) var(varname) binvar(varname) clopt(string) legopt(string) min(string) clbreaks(string) max(string) mapcolors(string asis) ndfcolor(string) ///
					savegraph(string) replace resolution(string) map_restriction(string) spopt(string) ///
				/* Geography-specific options */ ///
                geoid(varname) labelhex(varname) nolabel ///
			 ]
	
	if ("`mergedatabase'"!="") {
		if ("`geoid'"=="") local geoid state
		
		if inlist("`geoid'","state","statefips","statename") novarabbrev merge 1:1 `geoid' using `"`geofolder'/statehex_database"', nogen keepusing(`geoid' state _polygonid __label_X __label_Y)
		else {
			di as error "with geography(statehex), geoid() must be 'state', 'statefips', 'statename', or blank"
			exit 198
		}
		exit
	}
	
	if ("`map'"!="") {

		* Avoid having a "No Data" legend item just because DC is missing (just drop it from the map)
		sum `spmapvar' if _polygonid==6, meanonly
		if (r(N)==0) {
			* add map restriction
			if (`"`map_restriction'"'!="") local map_restriction `map_restriction' & _polygonid!=6
			else local map_restriction if _polygonid!=6
		}
		
		if ("`label'"!="nolabel") {
			qui gen __label_X2 = __label_X `map_restriction'
			qui gen __label_Y2 = __label_Y `map_restriction'
			
			if ("`labelhex'"=="") local labelhex state
			
			local hexlabels label(label(`labelhex') xcoord(__label_X2) ycoord(__label_Y2))
		}
		else if ("`labelhex'"!="") {
			di as error "cannot specify 'nolabel' and labelhex() simultaneously"
			exit 198
		}
		
		spmap `spmapvar' using `"`geofolder'/statehex_coords"' `map_restriction', id(_polygonid) ///
			`clopt' ///
			`legopt' ///
			legend(pos(5) size(*1.6)) ///
			fcolor(`mapcolors') ndfcolor(`ndfcolor') ///
			oc(black ...) ndo(black) ///
			os(vthin ...) nds(vthin) ///
			`hexlabels' `spopt'
				
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

