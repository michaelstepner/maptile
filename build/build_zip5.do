*! 16sep2016  Michael Stepner, stepner@mit.edu

* imports 2000 Census 5-digit ZCTA shapefile into Stata format


/*******************************

** INPUT FILES ** 
- zt99_d00_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/prev_cartbndry_names.html
	  Under "5-Digit ZIP Code Tabulation Areas"

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
global raw "$root/raw_data/zip5"
global out "$root/geo_templates/zip5"
global test "$root/tests/zip5"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/zt99_d00_shp.zip")
cd "$raw"
unzipfile "$raw/zt99_d00_shp.zip", replace

shp2dta using "$raw/zt99_d00", database("$out/zip5_database_temp") ///
	coordinates("$out/zip5_coords_temp") genid(id) replace


*** Step 2: Clean database

use "$out/zip5_database_temp", clear
keep ZCTA id
rename ZCTA zip5

* Generate a new polygon id that is sorted by zip5 (useful for selecting AK & HI, which is complicated by missing zip5 values)
egen _polygonid=group(zip5 id)

* Destring zip5
gen zip3=substr(zip5,1,3)
destring zip3, replace
destring zip5, replace force

* Missing values of zip5:
* --> Either had 3 digits followed by XX, which indicates a large sparsely-populated land area that doesn't map to a 5-digit ZIP
* 	  Or had 3 digits followed by HH, which indicates a body of water.
* 	  Source: websites about ZCTAs, referenced above.

* Drop Puerto Rico
drop if inrange(zip3,006,009)

save12 "$out/zip5_database_temp2.dta", replace

*** Step 3: Clean coordinates
use "$out/zip5_coords_temp", clear
rename _ID id
merge m:1 id using "$out/zip5_database_temp2", assert(1 3) keep(3) nogen

** Test that new _polygonid has one-to-one mapping with old ID
*egen testid=sd(id), by(_polygonid)
*assert testid==0

** Generate state variable for AK and HI
gen statefips=2 if inrange(zip3,995,999)
replace statefips=15 if inlist(zip3,967,968)

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Save coords dataset
rename _polygonid _ID
keep _ID _X _Y
order _ID _X _Y
sort _ID, stable
save12 "$out/zip5_coords.dta", replace
project, creates("$out/zip5_coords.dta")

*** Step 4: Make _polygonid the only ID variable in database
use "$out/zip5_database_temp2", clear
keep _polygonid zip5 zip3
order _polygonid zip5 zip3
save12 "$out/zip5_database", replace
project, creates("$out/zip5_database.dta")

*** Step 5: Clean up extra files
erase "$out/zip5_database_temp.dta"
erase "$out/zip5_database_temp2.dta"
erase "$out/zip5_coords_temp.dta"

*** Step 6: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/zip5_maptile.ado")
project, relies_on("$out/zip5_maptile.md")
project, relies_on("$out/zip5_maptile.smcl")

*** Step 7: Test geo-specific options
use "$out/zip5_database.dta", clear
rename _polygonid test
duplicates drop zip5, force

maptile test, geo(zip5) geofolder($out) ///
	savegraph("$test/zip5_noopt.png") resolution(0.25) replace
project, creates("$test/zip5_noopt.png") preserve
	
maptile test, geo(zip5) geofolder($out) ///
	conus ///
	savegraph("$test/zip5_conus.png") resolution(0.25) replace
project, creates("$test/zip5_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(zip5) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/zip5_stoutline.png") resolution(0.25) replace
project, creates("$test/zip5_stoutline.png") preserve

maptile test, geo(zip5) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/zip5_conus_stoutline.png") resolution(0.25) replace
project, creates("$test/zip5_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
