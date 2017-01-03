*! 15sep2016  Michael Stepner, stepner@mit.edu

* imports 1990 County shapefile into Stata format


/*******************************

** INPUT FILES ** 
- co99_d90_shp.zip
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
global raw "$root/raw_data/county1990"
global out "$root/geo_templates/county1990"
global test "$root/tests/county1990"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/co99_d90_shp.zip")
cd "$raw"
unzipfile "$raw/co99_d90_shp.zip", replace

shp2dta using "$raw/co99_d90", database("$out/county1990_database_temp") ///
	coordinates("$out/county1990_coords_temp") genid(id) replace


*** Step 2: Clean database

use "$out/county1990_database_temp", clear
rename ST statefips
rename CO county
destring statefips county, replace
replace county=county+statefips*1000
keep statefips county id
drop if statefips>56
save12 "$out/county1990_database.dta", replace
project, creates("$out/county1990_database.dta")

*** Step 3: Clean coordinates
use "$out/county1990_coords_temp", clear
gen id=_ID
merge m:1 id using "$out/county1990_database", assert(3) nogen

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/county1990_coords.dta", replace
project, creates("$out/county1990_coords.dta")

*** Step 4: Clean up extra files
erase "$out/county1990_database_temp.dta"
erase "$out/county1990_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/county1990_maptile.ado")
project, relies_on("$out/county1990_maptile.md")
project, relies_on("$out/county1990_maptile.smcl")

*** Step 6: Test geo-specific options
use "$out/county1990_database.dta", clear
rename id test
duplicates drop county, force

maptile test, geo(county1990) geofolder($out) ///
	savegraph("$test/county1990_noopt.png") resolution(0.25) replace
project, creates("$test/county1990_noopt.png") preserve
	
maptile test, geo(county1990) geofolder($out) ///
	conus ///
	savegraph("$test/county1990_conus.png") resolution(0.25) replace
project, creates("$test/county1990_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(county1990) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/county1990_stoutline.png") resolution(0.25) replace
project, creates("$test/county1990_stoutline.png") preserve

maptile test, geo(county1990) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/county1990_conus_stoutline.png") resolution(0.25) replace
project, creates("$test/county1990_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
