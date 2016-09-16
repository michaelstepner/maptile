*! 16sep2016  Michael Stepner, stepner@mit.edu

* imports 2010 State shapefile into Stata format


/*******************************

** INPUT FILES ** 
- gz_2010_us_040_00_20m.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
- state_fips_abbrev.dta
	Contains a mapping between State FIPS codes and State standardized 2-letter abbreviations

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
global raw "$root/raw_data/state"
global out "$root/geo_templates/state"
global test "$root/tests/state"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/gz_2010_us_040_00_20m.zip")
cd "$raw"
unzipfile "$raw/gz_2010_us_040_00_20m.zip", replace

shp2dta using "$raw/gz_2010_us_040_00_20m", database("$out/state_database_temp") ///
	coordinates("$out/state_coords_temp") genid(_polygonid) replace


*** Step 2: Clean database

use "$out/state_database_temp", clear
rename STATE statefips
rename NAME statename
keep statefips statename _polygonid
destring statefips, replace
project, original("$raw/state_fips_abbrev.dta") preserve
merge 1:1 statefips using "$raw/state_fips_abbrev.dta", assert(2 3) keep(3) nogen
drop if statefips>56
save12 "$out/state_database_clean.dta", replace
project, creates("$out/state_database_clean.dta")

*** Step 3: Clean coordinates
use "$out/state_coords_temp.dta", clear
gen _polygonid=_ID
merge m:1 _polygonid using "$out/state_database_clean.dta", assert(1 3) keep(3) nogen

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/state_coords_clean.dta", replace
project, creates("$out/state_coords_clean.dta")

*** Step 4: Clean up extra files
erase "$out/state_database_temp.dta"
erase "$out/state_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/state_maptile.ado")
project, relies_on("$out/state_maptile.md")
project, relies_on("$out/state_maptile.smcl")

*** Step 6: Test geo-specific options
use "$out/state_database_clean.dta", clear
rename _polygonid test

maptile test, geo(state) geofolder($out) ///
	savegraph("$test/state_noopt.png") replace
project, creates("$test/state_noopt.png") preserve
