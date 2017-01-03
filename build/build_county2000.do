*! 16sep2016, Chieko Maene (cmaene@uchicago.edu) and Michael Stepner (stepner@mit.edu)

* imports 2000 County shapefile into Stata format


/*******************************

** INPUT FILES ** 
- co99_d00_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html

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
global raw "$root/raw_data/county2000"
global out "$root/geo_templates/county2000"
global test "$root/tests/county2000"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/co99_d00_shp.zip")
cd "$raw"
unzipfile "$raw/co99_d00_shp.zip", replace

shp2dta using "$raw/co99_d00", database("$out/county2000_database_temp") ///
	coordinates("$out/county2000_coords_temp") genid(id) replace


*** Step 2: Clean database

use "$out/county2000_database_temp", clear
rename STATE statefips
rename COUNTY county
destring statefips county, replace
replace county=county+statefips*1000
keep statefips county id
drop if statefips>56
save12 "$out/county2000_database.dta", replace
project, creates("$out/county2000_database.dta")

*** Step 3: Clean coordinates
use "$out/county2000_coords_temp", clear
gen id=_ID
merge m:1 id using "$out/county2000_database", assert(1 3) keep(3) nogen

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/county2000_coords.dta", replace
project, creates("$out/county2000_coords.dta")

*** Step 4: Clean up extra files
erase "$out/county2000_database_temp.dta"
erase "$out/county2000_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/county2000_maptile.ado")
project, relies_on("$out/county2000_maptile.smcl")

*** Step 6: Test geo-specific options
use "$out/county2000_database.dta", clear
rename id test
duplicates drop county, force

maptile test, geo(county2000) geofolder($out) ///
	savegraph("$test/county2000_noopt.png") resolution(0.25) replace
project, creates("$test/county2000_noopt.png") preserve
	
maptile test, geo(county2000) geofolder($out) ///
	conus ///
	savegraph("$test/county2000_conus.png") resolution(0.25) replace
project, creates("$test/county2000_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(county2000) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/county2000_stoutline.png") resolution(0.25) replace
project, creates("$test/county2000_stoutline.png") preserve

maptile test, geo(county2000) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/county2000_conus_stoutline.png") resolution(0.25) replace
project, creates("$test/county2000_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
