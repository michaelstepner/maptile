*! version 1.0.0  24dec2016 Michael Stepner <stepner@mit.edu>
program define geo2xy_lambert_sphere, rclass

/*
-------------------------------------------------------------------------------

Lambert Conformal Conic Projection (sphere)
===========================================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 106-107. 

Certified using numerical example at pp. 295

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
	
		// Snyder, p. 107, equation 15-3
		tempname n
		scalar `n' = ln(cos(`phi1')/cos(`phi2')) / ln( tan(_pi/4 + `phi2'/2) / tan(_pi/4 + `phi1'/2) )
		
		// Snyder, p. 107, equation 15-2
		tempname F
		scalar `F' = cos(`phi1') * tan(_pi/4 + `phi1'/2)^`n' / `n'
		
		// Snyder, p. 106, equation 15-1a
		tempname rho0
		scalar `rho0' = `F' / (tan(_pi/4 + `phi0'/2)^`n')
		
		// Snyder, p. 106, equation 14-4
		tempvar theta
		gen double `theta' = `n' * (`lon' * `d2r' - `lambda0')
		
		// Snyder, p. 106, equation 15-1
		tempvar rho
		gen double `rho' = `F' / (tan(_pi/4 + (`lat' * `d2r')/2)^`n')
		
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		nobreak {
		
			// Snyder, p. 106, equation 14-1
			`genrep' `x' = `rho' * sin(`theta') if `touse'
			
			// Snyder, p. 106, equation 14-2
			`genrep' `y' = `rho0' - `rho' * cos(`theta') if `touse'
			

		}
	}
	
	return local lat0 `lat0'
	return local lat1 `lat1'
	return local lat2 `lat2'
	return local lon0 `lon0'
	return local pname = "Lambert Conformal Conic Projection"
	return local model = "Unit Sphere"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end
