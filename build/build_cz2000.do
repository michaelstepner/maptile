*! 29jul2017  Maithreyi Gopalan (smgopala@indiana.edu) and Michael Stepner (stepner@mit.edu)

* merges 2000 County shapefile into a 2000 CZ shapefile

/*******************************

** INPUT FILES ** 
- cz00_eqv_v1.xls
	Downloaded on 2017-07-29 from https://www.ers.usda.gov/data-products/commuting-zones-and-labor-market-areas/
	
*******************************/

*** Step 0: Initialize

* Check if run using -project-
return clear
capture project, doinfo
if (_rc==0 & !mi(r(pname))) global root `r(pdir)'  // run using -project-
else {  // running directly

	global root "/Users/michael/Documents/git_repos/maptile_geo_templates/build"

	* Disable project (since running do-files directly)
	cap program drop project
	program define project
		di "Project is disabled, skipping project command. (To re-enable, run -{stata program drop project}-)"
	end
	
}

* Specify subdirectories
global raw "$root/raw_data/cz2000"
global out "$root/geo_templates/cz2000"
global test "$root/tests/cz2000"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

* Tell -project- that we use -mergepoly- (obtained from SSC)
project, original("$root/util/mergepoly.ado")
project, original("$root/util/mergepoly.hlp")


*** Step 1: Use 2000 County -> 2000 CZ crosswalk to merge CZ variable onto county database
project, original("$raw/cz00_eqv_v1.xls")
import excel using "$raw/cz00_eqv_v1.xls", clear firstrow
keep FIPS CommutingZoneID2000
destring FIPS, replace
rename FIPS county
rename CommutingZoneID2000 cz

project, original("$root/geo_templates/county2000/county2000_database.dta") preserve
merge 1:m county using "$root/geo_templates/county2000/county2000_database.dta", assert(3) nogen
compress


*** Step 2: Merge county polygons into CZs

project, original("$root/geo_templates/county2000/county2000_coords.dta") preserve
mergepoly id using "$root/geo_templates/county2000/county2000_coords.dta", ///
	coordinates("$out/cz2000_coords.dta") ///
	by(cz) replace
save12 "$out/cz2000_database.dta", replace
project, creates("$out/cz2000_database.dta")

* Resave coords in Stata 12 format
use "$out/cz2000_coords.dta", clear
save12 "$out/cz2000_coords.dta", replace
project, creates("$out/cz2000_coords.dta")


*** Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/cz2000_maptile.ado")
project, relies_on("$out/cz2000_maptile.md")
project, relies_on("$out/cz2000_maptile.smcl")

*** Test geo-specific options
use "$out/cz2000_database.dta", clear
rename id test

maptile test, geo(cz2000) geofolder($out) ///
	savegraph("$test/cz2000_noopt.png") resolution(0.25) replace
project, creates("$test/cz2000_noopt.png") preserve
	
maptile test, geo(cz2000) geofolder($out) ///
	conus ///
	savegraph("$test/cz2000_conus.png") resolution(0.25) replace
project, creates("$test/cz2000_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(cz2000) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/cz2000_stoutline.png") resolution(0.25) replace
project, creates("$test/cz2000_stoutline.png") preserve

maptile test, geo(cz2000) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/cz2000_conus_stoutline.png") resolution(0.25) replace
project, creates("$test/cz2000_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
