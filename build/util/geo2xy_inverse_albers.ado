*! version 1.0.0  30jul2017 Michael Stepner <stepner@mit.edu>
program define geo2xy_inverse_albers, rclass

/*
-------------------------------------------------------------------------------
Albers Equal-Area Conic Projection (ellipsoid), Inverse
=======================================================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 101-102. 

Certified using numerical example at pp. 293-294

Projection arguments:

a     = semi-major axis of reference ellipsoid
f     = inverse flattening of reference ellipsoid
lat1  = 1st standard parallel
lat2  = 2nd standard parallel
lat0  = projection's origin
lon0  = central meridian

All projection arguments are must be supplied

-------------------------------------------------------------------------------
*/

	args touse y x lat lon a f lat1 lat2 lat0 lon0 whatsthis
	
	if !mi("`whatsthis'") | mi("`a'","`f'","`lat1'","`lat2'","`lat0'","`lon0'") {
		dis as err "expected arguments are: a f lat1 lat2 lat0 lon0"
		exit 198
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
		
		// Snyder, p. 101, equation 3-12 with subscripts 0, 1, 2, and none
		foreach i in 0 1 2 {
			tempname q`i'
			scalar `q`i'' = (1 - `e2') * ///
				(sin(`phi`i'') / (1 - `e2' * sin(`phi`i'')^2) - ///
				log((1 - `e' * sin(`phi`i'')) / (1 + `e' * sin(`phi`i''))) / (2 * `e'))
		}
		
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
		
		// Snyder, p. 102, equation 14-10
		tempvar rho
		gen double `rho' = sqrt(`x'^2 + (`rho0'-`y')^2)
		
		// Snyder, p. 102, equation 14-11
		tempvar theta
		gen double `theta' = atan(`x' / (`rho0'-`y'))

		// Snyder, p. 102, equation 14-19
		tempvar q
		gen double `q' = (`C' - `rho'^2 * `n'^2 / `a'^2) / `n'
		
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		nobreak {
		
			// Snyder, p. 102, equation 3-16
			tempvar lastlat curlat latdiff
			gen double `lastlat' = asin(`q'/2) if `touse'
			gen double `curlat' = .
			gen double `latdiff' = .

			forvalues iter=1/50 {
			
				replace `curlat' = `lastlat' + (1 - `e2' * sin(`lastlat')^2)^2 / (2*cos(`lastlat')) * ///
								( ///
									(`q' / (1-`e2')) ///
									- (sin(`lastlat') / (1-`e2'*sin(`lastlat')^2)) ///
									+ (1/(2*`e')) * ln( (1-`e'*sin(`lastlat')) / (1+`e'*sin(`lastlat')) ) ///
								) if `touse'
				replace `latdiff' = reldif(`curlat'/`d2r',`lastlat'/`d2r')
			
				* If accurate to 8 sig figs, stop iterating
				sum `latdiff', meanonly
				if (r(max)<1e-8) continue, break
				
				* Otherwise, swap the pointers for curlat and lastlat
				local nextlat `lastlat'
				local lastlat `curlat'
				local curlat `nextlat'
				
				* Warn if doesn't converge
				if (`iter'==50) {
					di as error "Computation of latitudes did not converge (tol=1e-8) after 50 iterations."
					exit 430
				}
			
			}
			`genrep' `lat' = `curlat'/`d2r' if `touse'
			
			// Snyder, p. 102, equation 14-9
			`genrep' `lon' = (`lambda0' + `theta'/`n') / `d2r'  if `touse'
			
	
		}
	}
	
	return local a `a'
	return local f `f'
	return local lat0 `lat0'
	return local lat1 `lat1'
	return local lat2 `lat2'
	return local lon0 `lon0'
	return local pname = "Inverse Albers Equal-Area Conic Projection"
	return local model = "Ellipsoid (`a',`f')"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end
