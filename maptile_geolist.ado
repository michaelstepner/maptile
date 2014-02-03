*! version 0.70beta1  3feb2014  Michael Stepner, stepner@mit.edu

/*** Unlicence (abridged):
This is free and unencumbered software released into the public domain.
It is provided "AS IS", without warranty of any kind.

For the full legal text of the Unlicense, see <http://unlicense.org>
*/

* Why did I include a formal license? Jeff Atwood gives good reasons:
*  http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html


program define maptile_geolist
	version 11
	
	* Set directory
	if (`"`0'"'=="") {
		local geofolder `c(sysdir_personal)'maptile_geographies
	}
	else local geofolder `0'
	
	* Check that the specified directory exists (uses confirmdir.ado code by Dan Blanchette)
	local current_dir `"`c(pwd)'"'
	quietly capture cd `"`geofolder'"'
	if _rc!=0 {
		di as error `"Unable to load directory `geofolder'"'
		exit 198
	}
	quietly cd `"`current_dir'"'
	

	* Store all relevant files in local
	local geos : dir `"`geofolder'"' files "*_maptile.ado"
	
	* Output geo_names
	if (`"`geos'"'=="") di as text "no geography templates found"
	else {
		di `: subinstr local geos "_maptile.ado" "   ", all'
	}
	
end
