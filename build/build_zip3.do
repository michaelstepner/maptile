*! 16sep2016  Michael Stepner, stepner@mit.edu

* imports 2000 Census 3-digit ZCTA shapefile into Stata format


/*******************************

** INPUT FILES ** 
- z399_d00_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/prev_cartbndry_names.html
	  Under "3-Digit ZIP Code Tabulation Areas"

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
global raw "$root/raw_data/zip3"
global out "$root/geo_templates/zip3"
global test "$root/tests/zip3"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/z399_d00_shp.zip")
cd "$raw"
unzipfile "$raw/z399_d00_shp.zip", replace

shp2dta using "$raw/z399_d00", database("$out/zip3_database_temp") ///
	coordinates("$out/zip3_coords_temp") genid(id) replace


*** Step 2: Clean database

use "$out/zip3_database_temp", clear
keep ZCTA3 id
rename ZCTA3 zip3
destring zip3, replace
drop if inrange(zip3,006,009)  // drop Puerto Rico
save12 "$out/zip3_database.dta", replace
project, creates("$out/zip3_database.dta")

*** Step 3: Clean coordinates
use "$out/zip3_coords_temp", clear
gen id=_ID
merge m:1 id using "$out/zip3_database", assert(1 3) keep(3) nogen

** Generate state variable for AK and HI
gen statefips=2 if inrange(zip3,995,999)
replace statefips=15 if inlist(zip3,967,968)

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/zip3_coords.dta", replace
project, creates("$out/zip3_coords.dta")

*** Step 4: Clean up extra files
erase "$out/zip3_database_temp.dta"
erase "$out/zip3_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/zip3_maptile.ado")
project, relies_on("$out/zip3_maptile.md")
project, relies_on("$out/zip3_maptile.smcl")

*** Step 6: Test geo-specific options
use "$out/zip3_database.dta", clear
rename id test
duplicates drop zip3, force

maptile test, geo(zip3) geofolder($out) ///
	savegraph("$test/zip3_noopt.png") replace
project, creates("$test/zip3_noopt.png") preserve
	
maptile test, geo(zip3) geofolder($out) ///
	conus ///
	savegraph("$test/zip3_conus.png") replace
project, creates("$test/zip3_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(zip3) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/zip3_stoutline.png") replace
project, creates("$test/zip3_stoutline.png") preserve

maptile test, geo(zip3) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/zip3_conus_stoutline.png") replace
project, creates("$test/zip3_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
