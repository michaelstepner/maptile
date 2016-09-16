*! 16sep2016, Chieko Maene (cmaene@uchicago.edu) and Michael Stepner (stepner@mit.edu)

* imports 2014 County shapefile into Stata format


/*******************************

** INPUT FILES ** 
- cb_2014_us_county_20m.zip
	Provided by U.S. Census Bureau at https://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html

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
global raw "$root/raw_data/county2014"
global out "$root/geo_templates/county2014"
global test "$root/tests/county2014"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/cb_2014_us_county_20m.zip")
cd "$raw"
unzipfile "$raw/cb_2014_us_county_20m.zip", replace

shp2dta using "$raw/cb_2014_us_county_20m", database("$out/county2014_database_temp") ///
	coordinates("$out/county2014_coords_temp") genid(id) replace


*** Step 2: Clean database

use "$out/county2014_database_temp", clear
rename STATEFP statefips
rename COUNTYFP county
destring statefips county, replace
replace county=county+statefips*1000
keep statefips county id
drop if statefips>56
save12 "$out/county2014_database.dta", replace
project, creates("$out/county2014_database.dta")

*** Step 3: Clean coordinates
use "$out/county2014_coords_temp", clear
gen id=_ID
merge m:1 id using "$out/county2014_database", assert(1 3) keep(3) nogen

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/county2014_coords.dta", replace
project, creates("$out/county2014_coords.dta")

*** Step 4: Clean up extra files
erase "$out/county2014_database_temp.dta"
erase "$out/county2014_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/county2014_maptile.ado")
project, relies_on("$out/county2014_maptile.smcl")

*** Step 6: Test geo-specific options
use "$out/county2014_database.dta", clear
rename id test

maptile test, geo(county2014) geofolder($out) ///
	savegraph("$test/county2014_noopt.png") replace
project, creates("$test/county2014_noopt.png") preserve
	
maptile test, geo(county2014) geofolder($out) ///
	conus ///
	savegraph("$test/county2014_conus.png") replace
project, creates("$test/county2014_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(county2014) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/county2014_stoutline.png") replace
project, creates("$test/county2014_stoutline.png") preserve

maptile test, geo(county2014) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/county2014_conus_stoutline.png") replace
project, creates("$test/county2014_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
