*! 2.0.5 21aug2013 
*! Robert Picard   picard@netbox.com
*! Michael Stepner michaelstepner@gmail.com
program define mergepoly

	version 9.2
	
	cap syntax varlist(min=3 max=3), [Generate(name)]
	if !_rc {
		dis as err "warning: you are using old syntax; see {help mergepoly:help mergepoly}"
		
		mergepoly_old `0'
		
		exit
	}

	syntax [varname(default=none)] [if] [in] using/ ,		///
		COORdinates(string)			///
		[							///
		by(varlist)					///
		Fail(name) 					///
		replace						///
		]
		
	if "`fail'" == "" local fail _fail
	local id = cond("`varlist'" == "","_ID","`varlist'")
	
	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000 
	
	preserve
	
	quietly {
	
		keep if `touse'
		
		tempfile dbf
		save "`dbf'"
		
		keep `id' `by'
		sort `id'
		cap by `id': assert _n == 1
		if _rc {
			noi dis as err "`id' does not uniquely identify features"
			exit 459
		}
		if "`id'" != "_ID" rename `id' _ID
		tempfile target
		save "`target'"
		
		use "`using'", clear
		cap confirm numeric variable _ID _X _Y
		if _rc {
			noi dis as err `"was expecting numeric variables _ID _X _Y in "`using'""'
			exit _rc
		}
		
		tempvar order
		gen `order' = _n
		sort _ID `order'
		merge _ID using "`target'"
		cap assert _merge != 2
		if _rc {
			noi dis as err "missing coordinates for some features identified by `id'"
			exit _rc
		}
		keep if _merge == 3
		drop _merge
	
		gen byte `fail' = 0
		
		// create new id in case there are multipart polygons
		// each polygon starts with a missing lat/lon
		sort _ID `order'
		tempvar newid
		gen `newid' = sum(mi(_X,_Y))
		sort `newid' `order'
		by `newid': drop if _n == 1
		
		
		// each polygon should start and end at the same lat/lon
		cap by `newid': assert _X[1] == _X[_N] & _Y[1] == _Y[_N]
		if _rc {
			noi dis as err "coordinates include shapes that are not polygons"
			exit _rc
		}
		
		// this should not happen but remove identical consecutive points if any
		by `newid': drop if _X[_n] == _X[_n-1] & _Y[_n] == _Y[_n-1]
		replace `order' = _n
			
		// drop features that are points or lines
		by `newid': drop if _N < 3
		replace `order' = _n
		qui count
		if r(N) == 0 {
			noi dis as err "features are not polygons"
			error 2000 
		}
			
		if "`by'" == "" {
			tempvar by
			gen `by' = 1
		}
		
		sort `by' `order'
		tempvar one genid
		by `by': gen `one' = _n == 1
		gen `genid' = sum(`one')
		drop `one'
		local nby = `genid'[_N]
		
		tempfile main
		save "`main'"
			
		local lastgen 0
		local nfail 0
		
		if `nby' > 1 nois _dots 0, title(Looping over `nby' by-groups:)
		
		forvalues i = 1/`nby' {
			use "`main'", clear
			keep if `genid' == `i'
			noi doit `order' `newid' _X _Y `fail'
			replace `genid' = `i'
			tempfile group`i'
			save `group`i''
			
			count if `fail'
			if r(N) local ++nfail
			if `nby' > 1 {
				if r(N) nois _dots `i' x
				else nois _dots `i' 0		
			}
		}
		
		use `group1', clear
		forvalues i = 2/`nby' {
			append using `group`i''
		}
		
		if `nfail' {
			if `nby' == 1 noi dis as err "warning: failed to connect all line segments"
			else noi dis as err _n "failed to connect all line segments in `nfail' by-group(s)"
		}
		
		sort `genid' `order'
		keep `genid' _X _Y `fail'
		order `genid' _X _Y `fail'
		count if `fail'
		if r(N) == 0 drop `fail'
		
		rename `genid' _ID
		
		save "`coordinates'", `replace'
		
		use "`dbf'"
		cap confirm var `by'
		if _rc {
			tempvar by
			gen `by' = 1
		}
		unab vlist : *
		local vkeep `by' `id'
		local vdata : list vlist - vkeep
		foreach v of varlist `vdata' {
			sort `by' `v'
			cap by `by': assert `v'[1] == `v'[_N]
			if _rc drop `v'
		}
		sort `by'
		by `by': keep if _n == 1
		replace `id' = _n
		
	}
	
	restore, not

end


program define mergepoly_old

	version 9.2

	syntax varlist(min=3 max=3), ///
		[ ///
		Generate(name) ///
		]
		
	tokenize `varlist'
	confirm numeric var `1' `2' `3'
	
	if "`generate'" == "" local generate _ID_merged
	if "`fail'" == "" local fail _fail
	
	qui count
	if r(N) == 0 error 2000 
	
	
	preserve
	
	keep `1' `2' `3'
	
	gen byte `fail' = 0
	
	// create new id in case there are multipart polygons
	// each polygon starts with a missing lat/lon
	tempvar order newid
	gen `order' = _n
	gen `newid' = sum(mi(`2',`3'))
	sort `newid' `order'
	qui by `newid': drop if _n == 1
	
	// each polygon should start and end at the same lat/lon
	cap by `newid': assert `2'[1] == `2'[_N] & `3'[1] == `3'[_N]
	if _rc {
		dis as err "data contains shapes that are not polygons"
		exit _rc
	}
	
	// polygons cannot be split between two original id
	cap by `newid': assert `1' == `1'[1]
	if _rc {
		dis as err "polygon split over multiple values of `1'"
		exit _rc
	}
	
	doit `order' `newid' `2' `3' `fail'
	qui count if `fail'
	if r(N) {
		dis as err "warning: failed to connect all line segments"
	}
	
	drop `order'
	qui count if `fail'
	if r(N) == 0 drop `fail'
	
	
	gen `generate' = sum(mi(`2',`3'))
	
	restore, not

end


program define doit
/*
To merge polygons, we start by removing adjacent line segments. The remaining
line segments are part of the outer polygon. We reconnect consecutive line
segments into polylines that are subsets of the original polygons. Finally, we
reconnect the polylines into a final polygon. 
*/

	args obs id lat lon fail
	
	qui {
		
		// make line segments from consecutive points
		tempvar lat2 lon2
		sort `id' `obs'
		by `id': gen `:type `lat'' `lat2' = `lat'[_n+1]
		by `id': gen `:type `lon'' `lon2' = `lon'[_n+1]
		by `id': drop if _n == _N
		
		// calculate the mid-point of each line segment; outer segments
		// do not share a common mid-point with any other segment
		tempvar midlat midlon outer
		gen `:type `lat'' `midlat' = (`lat' + `lat2') / 2
		gen `:type `lon'' `midlon' = (`lon' + `lon2') / 2
		sort `midlat' `midlon'
		by `midlat' `midlon': gen `outer' = _N == 1
		drop `midlat' `midlon'

		// reduce to segments that form the outer polygon(s)
		keep if `outer'
		
	
		// connect consecutive line segments within a polygon into polylines
		tempvar polyline pstart
		sort `id' `obs'
		by `id': gen `pstart' = `obs' != `obs'[_n-1] + 1
		gen `polyline' = sum(`pstart')
		sort `polyline' `obs'
		
		// if a polyline loops back to its starting point, we have an island
		// and we are done with those
		tempvar island one
		by `polyline': gen `one' = _n == 1
		by `polyline': gen `island' = `lat'[1] == `lat2'[_N] & `lon'[1] == `lon2'[_N]
		tempvar polygon_id
		gen `polygon_id' = sum(`one' & `island')
		replace `polygon_id' = . if !`island'
		drop `one' `island'
				
		// make a master list of polylines starting points and merge back
		sort `lat2' `lon2'
		tempfile main
		save "`main'"
		keep if `pstart' & mi(`polygon_id')
		keep `polyline' `lat' `lon'
		tempvar next_pline
		rename `polyline' `next_pline'
		rename `lat' `lat2'
		rename `lon' `lon2'
		
		// can't deal with multiple exterior line segments starting from the same point
		sort `lat2' `lon2'
		by `lat2' `lon2': drop if _N > 1
		sort `lat2' `lon2'
		merge `lat2' `lon2' using "`main'"
		keep if _merge != 1	// end points find no matching polyline start points
		drop _merge
		replace `next_pline' = . if !mi(`polygon_id') // done with these
		
		// reorder polylines by travelling the linked list of polylines.
		sort `polyline' `obs'
		sum `polyline' if !mi(`next_pline'), meanonly
		local current = r(min)
		tempvar pline_order
		gen `pline_order' = .
		sum `polygon_id', meanonly
		local genid = cond(mi(r(max)),1,r(max)+1)
		local i 0
		while !mi(`current') {
			local ++i
			replace `pline_order' = `i' if `polyline' == `current'
			replace `polygon_id' = `genid' if `polyline' == `current'
			sum `next_pline' if `polyline' == `current', meanonly
			replace `next_pline' = . if `polyline' == `current'
			local current = r(min)
			if mi(`current') {
				local ++genid
				sum `polyline' if !mi(`next_pline'), meanonly
				local current = r(min)
			}
		}
		
		// check for incomplete polygons
		sort `polygon_id' `pline_order' `obs'
		by `polygon_id': replace `fail' = ///
			!(`lat'[1] == `lat2'[_N] & `lon'[1] == `lon2'[_N])
				
		// check for orphan polylines
		replace `fail' = 1 if mi(`polygon_id')
		replace `polygon_id' = -`polyline' if mi(`polygon_id')
		
		// convert line segments to points
		tempvar one last
		sort `polygon_id' `pline_order' `obs'
		by `polygon_id': gen `one' = _n == 1
		by `polygon_id': gen `last' = _n == _N
		expand 2 if (`one' | `last')
		sort `polygon_id' `pline_order' `obs'
		by `polygon_id': replace `lat' = `lat'[1] if _n == _N
		by `polygon_id': replace `lon' = `lon'[1] if _n == _N
		by `polygon_id': replace `lat' = . if _n == 1
		by `polygon_id': replace `lon' = . if _n == 1
		replace `obs' = _n
		sort `polygon_id' `obs'

	}
end


/*
-------------------------------------------------------------------------------
The following is an adaptation of the undocumented undocumented _dots.ado
distributed with Stata. 

version 1.1.0  03may2007
-------------------------------------------------------------------------------
*/

program _dots
	version 8.2
	
	syntax [anything] [, title(string)]
	tokenize `anything'
	args i rc
	if "`i'" == "0" {
		if `"`title'"' != "" {
			di as txt "`title'"
		}
		di as txt "{hline 4}{c +}{hline 3} 1 "	///
			  "{hline 3}{c +}{hline 3} 2 "	///
			  "{hline 3}{c +}{hline 3} 3 "	///
			  "{hline 3}{c +}{hline 3} 4 "	///
			  "{hline 3}{c +}{hline 3} 5 "
	}
	else {

		if "`rc'" == "0" dis as txt "." _c
		else dis as err "`rc'" _c
		
		if mod(`i',50) == 0 {
			di as txt " " %5.0f `i'
		}
	}

end


