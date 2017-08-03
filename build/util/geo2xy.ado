*! version 1.0.1  20jan2017 Robert Picard, picard@netbox.com
program define geo2xy, rclass

	version 9.2
	
	syntax varlist(min=2 max=2 numeric) [if] [in], 	///
		[ ///
		GENerate(namelist min=2 max=2) ///
		PROJection(string) ///
		TIssot ///
		replace ///
		]
		
	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000
	
	tokenize `varlist'
	local lat `1'
	local lon `2'
	
	sum `lat' if `touse', meanonly
	if r(max) > 90 | r(min) < -90 {
		dis as err "latitude `lat' must be between -90 and 90"
		exit 198
	}	

	sum `lon' if `touse', meanonly
	if r(max) > 180 | r(min) < -180 {
		dis as err "longitude `lon' must be between -180 and 180"
		exit 198
	}
	
	if "`generate'" == "" & "`replace'" == "" {
		dis as err "you must either specify the -replace- option or " ///
			"use the -generate()- option for the x,y coordinates variables"
		exit 198
	}
	
	if "`generate'" == "" {
		local yvar `lat'
		local xvar `lon'
	}
	else {
		tokenize `generate'
		local yvar `1'
		local xvar `2'
	}

	if "`tissot'" != "" geo2xy_tissot `touse' `lat' `lon'

	if "`projection'" == "" local projection "web_mercator"

	gettoken which_proj proj_options : projection, parse(",")
	gettoken comma proj_options : proj_options, parse(",")
	
	geo2xy_`which_proj' `touse' `lat' `lon' `yvar' `xvar' `proj_options'
	
	return add

end


program geo2xy_tissot

	args touse lat lon
			
	tempname d2r r2d
	scalar `d2r' = _pi / 180
	scalar `r2d' = 180 / _pi
	
	// get coordinates of map bounds
	sum `lat' if `touse', meanonly
	tempname latmin latmax
	scalar `latmin' = r(min) * `d2r'
	scalar `latmax' = r(max) * `d2r'
	
	sum `lon' if `touse', meanonly
	tempname lonmin lonmax ratio
	scalar `lonmin' = r(min) * `d2r'
	scalar `lonmax' = r(max) * `d2r'
	
	
	// get the map ratio at mid-latitude
	scalar `ratio' = (`latmax' - `latmin') / ///
		(cos((`latmax' + `latmin') / 2) * (`lonmax' - `lonmin'))
	
	
	// decide on a number of indicatrix, use odd numbers to align
	// with mid-latitude and mid-longitude
	local nlat = 5
	local nlon = 2 * floor(`nlat' / `ratio' / 2) + 1
	
	preserve
	
	qui {
	
	drop _all
	
		// coordinates of indicatrix
		tempvar ylat xlon
		set obs `nlat'
		gen double `ylat' = `latmin' + _n * (`latmax' - `latmin') / (`nlat' + 1)
		expand `nlon'	
		bys `ylat': gen double `xlon' = `lonmin' + _n * (`lonmax' - `lonmin') / (`nlon' + 1)
		
		// the radius to use is in proportion to the number of points
		local r = cos((`latmax' + `latmin') / 2) * (`lonmax' - `lonmin') / (`nlon' + 1) / 3

		// create a polygon of 200 points; first is missing, last loops back to first
		expand 202
		
		tempvar bearing
		bysort `ylat' `xlon': gen double `bearing' = 2 * _pi * (_n - 2) / (_N-2) if _n > 1
		
		/*
		The equation for calculating a destination point using an initial bearing and
		distance comes from www.movable-type.co.uk/scripts/latlong.html by Chris Veness
		*/
		gen double `lat' = asin(sin(`ylat') * cos(`r') + ///
							cos(`ylat') * sin(`r') * cos(`bearing'))
							
		gen double `lon' = `xlon' + atan2(sin(`bearing') * sin(`r') * cos(`ylat'), ///
											cos(`r') - sin(`ylat') * sin(`lat')) 
		
		replace `lat' = `lat' * `r2d'
		replace `lon' = `lon' * `r2d'
		
		replace `lon' = `lon' - 360 if `lon' > 180
		replace `lon' = `lon' + 360 if `lon' < -180
		
		keep `lat' `lon'
		tempfile hold
		qui save "`hold'"
		
		restore
		
		append using "`hold'"
	
	}
	
end


program define geo2xy_web_mercator, rclass

/*
-------------------------------------------------------------------------------

Web Mercator
============

Google Maps and other web mapping application use a spherical mercator
projection (http://en.wikipedia.org/wiki/Web_Mercator).

This implementation follows Google's implementation (haven't checked what
the others do), where the projected map's origin (0,0) is the top-left
corner and the projected latitudes are truncated so that whole world fits, 
at a zoom level of 0, in a 256x256 tile, i.e. an aspect ratio of 1.
(https://developers.google.com/maps/documentation/ios/tiles)

By default, the map coordinates are returned at zoom level 0 (zoom level
does not matter unless you are trying to overlay tiles with Google's tiles).

If a zoom level is specified, the xtile and ytile identifier are also
returned.


Projection arguments:

  zoom  = zoom level
  xtile = x tile id
  ytile = y tile id
  

Defaults if no projection arguments supplied

  zoom  = 0
  xtile = 
  ytile = 

-------------------------------------------------------------------------------
*/

	args touse lat lon y x zoom xtile ytile whatsthis
	
	if !mi("`whatsthis'") {
		dis as err "expected arguments are: lon0"
		exit 198
	}
	
	// default zoom level
	if "`zoom'" == ""  local zoom 0
	
	// at zoom level 0, the world fits in a single 256x256 pixel tile
	// an increase of 1 for zoom level doubles x and doubles y
	tempname zoomfactor
	scalar `zoomfactor' = 256 / (2 * _pi) * 2^`zoom'
	
	// offset that will shift geodetic longitudes so that -180 == 0
	local lon0 -180

	// start with a regular spherical Mercator projection
	geo2xy_mercator_sphere `touse' `lat' `lon' `y' `x' `lon0'

	qui {
	
		// truncate to maintain Google's 1 to 1 aspect ratior at zoom level 0
		// where x == 2 * _pi so -_pi <= y <= _pi
		replace `y' = . if abs(`y') > _pi
	
		// shift the projected latitude so that top-left == 0,0 and scale
		replace `y' = `zoomfactor' * (`y' - _pi)  if `touse'
		
		// the longitudes have already been shifted
		replace `x' = `zoomfactor' * `x'  if `touse'
		
		// if arguments are specified, generate tile identifiers
		if "`xtile'" != "" {
		
			gen long `xtile' = int(`x'/256)
			gen long `ytile' = int(-`y'/256)
			
		}
		
	}

	return local zoom `zoom'
	return local pname = "Web Mercator"
	return local model = "Unit Sphere"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))
	
end


program define geo2xy_mercator_sphere, rclass

/*
-------------------------------------------------------------------------------

Mercator (sphere)
=================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 41. Certified using numerical example at pp. 266

Projection arguments:

  lon0  = projection's origin

Defaults if no projection arguments supplied

  lon0  = relative; set to mid longitude range

-------------------------------------------------------------------------------
*/

	args touse lat lon y x lon0 whatsthis
	
	if !mi("`whatsthis'") {
		dis as err "expected arguments are: lon0"
		exit 198
	}

	if "`lon0'" == "" {
	
		sum `lon' if `touse', meanonly
		local lon0 =  (r(min) + r(max)) / 2
		
	}

	tempname d2r
	scalar `d2r' = _pi / 180
	
	tempname lambda0 
	scalar `lambda0' = `lon0' * `d2r'

	qui nobreak {

		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		// Snyder, p. 41, equation 7-1; R = 1
		`genrep' `x' = (`lon' * `d2r' - `lambda0') if `touse'
		
		// Snyder, p. 41, equation 7-2; R = 1
		`genrep' `y' = log(tan(_pi / 4 + `lat' * `d2r' / 2)) if `touse'
		
	}
	
	return local lon0 `lon0'
	return local pname = "Mercator"
	return local model = "Unit Sphere"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))
	
end


program define geo2xy_mercator, rclass

/*
-------------------------------------------------------------------------------

Mercator (ellipsoid)
====================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 44. Certified using numerical example at pp. 267

Projection arguments:

a     = semi-major axis of reference ellipsoid
f     = inverse flattening of reference ellipsoid
lon0  = projection's origin

Defaults if no projection arguments supplied

a     = 6378137 semi-major axis of WGS84
f     = 298.257223563 inverse flattening of WGS84
lon0  = relative; set to mid longitude range

-------------------------------------------------------------------------------
*/

	args touse lat lon y x a f lon0 whatsthis
	
	if !mi("`whatsthis'") | (!mi("`a'") & mi("`lon0'")) {
		dis as err "expected arguments are: a f lon0"
		exit 198
	}

	if "`a'" == "" {
	
		local a 6378137
		local f 298.257223563
	
		sum `lon' if `touse', meanonly
		local lon0 =  (r(min) + r(max)) / 2
		
	}
	
	// semi-minor axis
	tempname b
	scalar `b' = `a' - `a' / `f'
	
	// eccentricity, see Snyder, p. 13
	tempname e e2
	scalar `e2' = 2 * (1/`f') - (1/`f')^2
	scalar `e' = sqrt(`e2') 
	
	tempname d2r
	scalar `d2r' = _pi / 180
	
	tempname lambda0 
	scalar `lambda0' = `lon0' * `d2r'

	qui nobreak {
	
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		// Snyder, p. 44, equation 7-6
		`genrep' `x' = `a' * (`lon' * `d2r' - `lambda0')  if `touse'
		
		// Snyder, p. 44, equation 7-7
		`genrep' `y' = `a' * log( ///
			tan(_pi / 4 + `lat' * `d2r' / 2) * ///
			((1 -`e' * sin(`lat' * `d2r')) / ///
			(1 + `e' * sin(`lat' * `d2r')))^(`e' / 2)) if `touse'
		
	}

	return local a `a'
	return local f `f'
	return local lon0 `lon0'
	return local pname = "Mercator"
	return local model = "Ellipsoid (`a',`f')"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end


program define geo2xy_equidistant_cylindrical, rclass

/*
-------------------------------------------------------------------------------

Equidistant Cylindrical
=======================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 90-91.

No certification as "Numerical examples are omitted in the appendix, due to 
simplicity" (p. 91)

Projection arguments:

lat1  = standard parallel
lon0  = projection's origin

Defaults if no projection arguments supplied

lat1  = relative; mid-latitude
lon0  = relative; set to mid-longitude range

-------------------------------------------------------------------------------
*/

	args touse lat lon y x lat1 lon0 whatsthis
	
	if !mi("`whatsthis'") | (!mi("`lat1'") & mi("`lon0'")) {
		dis as err "expected arguments are: lat1 lon0"
		exit 198
	}

	// if no standard parallel is specified, use mid-latitude
	if "`lat1'" == "" {
	
		sum `lat' if `touse', meanonly
		local lat1 = (r(min) + r(max)) / 2
		
		sum `lon' if `touse', meanonly
		local lon0 =  (r(min) + r(max)) / 2
		
	}
	
	tempname d2r
	scalar `d2r' = _pi / 180
	
	tempname phi1 lambda0 
	scalar `lambda0' = `lon0' * `d2r'
	scalar `phi1' = `lat1' * `d2r'
		
	qui nobreak {
	
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		// Snyder, p. 91, equation 12-1; R = 1
		`genrep' `x' = (`lon' * `d2r' - `lambda0') * cos(`phi1') if `touse'
		
		// Snyder, p. 91, equation 12-2; R = 1
		`genrep' `y' = `lat' * `d2r' if `touse'
		
		
	}
	
	return local lat1 `lat1'
	return local lon0 `lon0'
	return local pname = "Equidistant Cylindrical"
	return local model = "Unit Sphere"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end


program define geo2xy_albers_sphere, rclass

/*
-------------------------------------------------------------------------------

Albers Equal-Area Conic Projection (sphere)
===========================================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 100-101. 

Certified using numerical example at pp. 291

Projection arguments:

lat1  = 1st standard parallel
lat2  = 2nd standard parallel
lat0  = projection's origin
lon0  = central meridian

Defaults if no projection arguments supplied

lat1  = relative; minlat + (maxlat - minlat) / 6
lat2  = relative; maxlat - (maxlat - minlat) / 6
lat0  = 0
lon0  = relative; set to mid-longitude range

-------------------------------------------------------------------------------
*/

	args touse lat lon y x lat1 lat2 lat0 lon0 whatsthis
	
	if !mi("`whatsthis'") | (!mi("`lat1'") & mi("`lon0'")) {
		dis as err "expected arguments are: lat1 lat2 lat0 lon0"
		exit 198
	}
	
	if "`lat1'" == "" {

		// follow Deetz & Adams 1/6 suggestion, Snyder, p. 99
		sum `lat' if `touse', meanonly
		local lat1 = r(min) + (r(max) - r(min)) / 6
		local lat2 = r(max) - (r(max) - r(min)) / 6
		
		sum `lon' if `touse', meanonly
		local lon0 =  (r(min) + r(max)) / 2

		local lat0 0
		
	}
			

	tempname d2r
	scalar `d2r' = _pi / 180
	
	tempname phi0 phi1 phi2 lambda0 
	scalar `phi0' = `lat0' * `d2r'
	scalar `lambda0' = `lon0' * `d2r'
	scalar `phi1' = `lat1' * `d2r'
	scalar `phi2' = `lat2' * `d2r'
	
	qui {
	
		// Snyder, p. 100, equation 14-6
		tempname n
		scalar `n' = (sin(`phi1') + sin(`phi2')) / 2
		
		// Snyder, p. 100, equation 14-5
		tempname C
		scalar `C' = cos(`phi1')^2 + 2 * `n' * sin(`phi1')
		
		// Snyder, p. 100, equation 14-3a
		tempname rho0
		scalar `rho0' = sqrt(`C' - 2 * `n' * sin(`phi0')) / `n'
		
		// Snyder, p. 100, equation 14-4
		tempvar theta
		gen double `theta' = `n' * (`lon' * `d2r' - `lambda0')
		
		// Snyder, p. 100, equation 14-3
		tempvar rho
		gen double `rho' = sqrt(`C' - 2 * `n' * sin(`lat' * `d2r')) / `n'
		
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		nobreak {
		
			// Snyder, p. 100, equation 14-1
			`genrep' `x' = `rho' * sin(`theta') if `touse'
			
			// Snyder, p. 100, equation 14-2
			`genrep' `y' = `rho0' - `rho' * cos(`theta') if `touse'
			

		}
	}
	
	return local lat0 `lat0'
	return local lat1 `lat1'
	return local lat2 `lat2'
	return local lon0 `lon0'
	return local pname = "Albers Equal-Area Conic Projection"
	return local model = "Unit Sphere"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end


program define geo2xy_albers, rclass

/*
-------------------------------------------------------------------------------

Albers Equal-Area Conic Projection (ellipsoid)
==============================================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 101-102. 

Certified using numerical example at pp. 292-293

Projection arguments:

a     = semi-major axis of reference ellipsoid
f     = inverse flattening of reference ellipsoid
lat1  = 1st standard parallel
lat2  = 2nd standard parallel
lat0  = projection's origin
lon0  = central meridian

Defaults if no projection arguments supplied

a     = 6378137 semi-major axis of WGS84
f     = 298.257223563 inverse flattening of WGS84
lat1  = relative; minlat + (maxlat - minlat) / 6
lat2  = relative; maxlat - (maxlat - minlat) / 6
lat0  = 0
lon0  = relative; set to mid-longitude range

-------------------------------------------------------------------------------
*/

	args touse lat lon y x a f lat1 lat2 lat0 lon0 whatsthis
	
	if !mi("`whatsthis'") | (!mi("`a'") & mi("`lon0'")) {
		dis as err "expected arguments are: a f lat1 lat2 lat0 lon0"
		exit 198
	}
	
	if "`a'" == "" {
		local a 6378137
		local f 298.257223563
	
		// follow Deetz & Adams 1/6 suggestion, Snyder, p. 99
		sum `lat' if `touse', meanonly
		local lat1 = r(min) + (r(max) - r(min)) / 6
		local lat2 = r(max) - (r(max) - r(min)) / 6
		
		sum `lon' if `touse', meanonly
		local lon0 =  (r(min) + r(max)) / 2

		local lat0 0
	}
	
	// semi-minor axis
	tempname b
	scalar `b' = `a' - `a' / `f'
	
	// eccentricity, see Snyder, p. 13
	tempname e e2
	scalar `e2' = 2 * (1/`f') - (1/`f')^2
	scalar `e' = sqrt(`e2') 

	tempname d2r
	scalar `d2r' = _pi / 180
	
	tempname phi0 phi1 phi2 lambda0 
	scalar `phi0' = `lat0' * `d2r'
	scalar `phi1' = `lat1' * `d2r'
	scalar `phi2' = `lat2' * `d2r'
	scalar `lambda0' = `lon0' * `d2r'
	
	qui {
		tempvar phi
		gen double `phi' = `lat' * `d2r'
		
		// Snyder, p. 101, equation 3-12 with subscripts 0, 1, 2, and none
		foreach i in 0 1 2 {
			tempname q`i'
			scalar `q`i'' = (1 - `e2') * ///
				(sin(`phi`i'') / (1 - `e2' * sin(`phi`i'')^2) - ///
				log((1 - `e' * sin(`phi`i'')) / (1 + `e' * sin(`phi`i''))) / (2 * `e'))
		}
		tempvar q
		gen double `q' = (1 - `e2') * ///
			(sin(`phi') / (1 - `e2' * sin(`phi')^2) - ///
			log((1 - `e' * sin(`phi')) / (1 + `e' * sin(`phi'))) / (2 * `e'))
			
		// Snyder, p. 101, equation 14-15 with subscripts 1 and 2
		tempname m1 m2
		scalar `m1' = cos(`phi1') / sqrt(1 - `e2' * sin(`phi1')^2)
		scalar `m2' = cos(`phi2') / sqrt(1 - `e2' * sin(`phi2')^2)
		
		// Snyder, p. 101, equation 14-14
		tempname n
		scalar `n' = (`m1'^2 - `m2'^2) / (`q2' - `q1')
		
		// Snyder, p. 101, equation 14-13
		tempname C
		scalar `C' = `m1'^2 + `n' * `q1'
		
		// Snyder, p. 101, equation 14-12a
		tempname rho0
		scalar `rho0' = `a' * sqrt(`C' - `n' * `q0') / `n'
		
		// Snyder, p. 101, equation 14-4
		tempvar theta
		gen double `theta' = `n' * (`lon' * `d2r' - `lambda0')
		
		// Snyder, p. 101, equation 14-12
		tempvar rho
		gen double `rho' = `a' * sqrt(`C' - `n' * `q') / `n'
		
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		nobreak {
		
			// Snyder, p. 101, equation 14-1
			`genrep' `x' =  `rho' * sin(`theta') if `touse'
			
			// Snyder, p. 101, equation 14-2
			`genrep' `y' = `rho0' - `rho' * cos(`theta') if `touse'
			
	
		}
	}
	
	return local a `a'
	return local f `f'
	return local lat0 `lat0'
	return local lat1 `lat1'
	return local lat2 `lat2'
	return local lon0 `lon0'
	return local pname = "Albers Equal-Area Conic Projection"
	return local model = "Ellipsoid (`a',`f')"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end


program define geo2xy_picard, rclass

/*
-------------------------------------------------------------------------------

picard
======

The geographic coordinates remain unchanged. The aspect ratio is computed
using the distance at the standard parallel between min and max longitude.
When plotting the geographic coordinates using this aspect ratio will 
produce exactly the same map as would be produced if the Equidistant 
Cylindrical was used. The advantage is that you can add plot features
based on coordinates (lines, coordinates, etc.).

Projection arguments:

lat1  = standard parallel

Defaults if no projection arguments supplied

lat1  = relative; mid-latitude

-------------------------------------------------------------------------------
*/

	args touse lat lon y x lat1 whatsthis
	
	if !mi("`whatsthis'") {
		dis as err "expected arguments are: lat1"
		exit 198
	}
	
	if "`lat'" != "`y'" {
		qui clonevar `y' = `lat'
		qui clonevar `x' = `lon'
	}
	else {
		dis as txt "note: this projection does not change the coordinates" 
	}
	
	// if no standard parallel is specified, use mid-latitude
	if "`lat1'" == "" {
	
		sum `lat' if `touse', meanonly
		local lat1 = (r(min) + r(max)) / 2
		
	}
	
	tempname d2r
	scalar `d2r' = _pi / 180
		
	return local lat1 `lat1'
	return local pname = "Picard"
	return local model = "Geographic Latitude & Longitude"
	
	sum `lat' if `touse', meanonly
	tempname height
	scalar `height' = (r(max) - r(min)) * `d2r'
	
	sum `lon' if `touse', meanonly
	return local aspect = `height' / (cos(`lat1' * `d2r') * (r(max) * `d2r' - r(min) * `d2r'))
	
end














