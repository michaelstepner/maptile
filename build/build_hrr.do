*! 29aug2016  Michael Stepner, stepner@mit.edu

* imports Health Referer Region shapefile into Stata format, cleaning the output files

/*******************************

** INPUT FILES ** 
- hrr_bdry.zip
	Provided by Dartmouth Atlas at http://www.dartmouthatlas.org/tools/downloads.aspx?tab=39
- ZipHsaHrr13.xls
	Provided by Dartmouth Atlas at http://www.dartmouthatlas.org/tools/downloads.aspx?tab=39

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
global raw "$root/raw_data/hrr"
global out "$root/geo_templates/hrr"
global test "$root/tests/hrr"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/hrr_bdry.zip")
cd "$raw"
unzipfile "$raw/hrr_bdry.zip", replace

shp2dta using "$raw/HRR_Bdry", database("$out/hrr_database_temp") ///
	coordinates("$out/hrr_coords_temp") genid(_polygonid) replace


*** Step 2: Clean database
use "$out/hrr_database_temp.dta", clear
rename HRRNUM hrr
order hrr _polygonid, last

save12 "$out/hrr_database.dta", replace
project, creates("$out/hrr_database.dta")

*** Step 3: Clean coordinates

** Import HRR -> State crosswalk
project, original("$raw/ZipHsaHrr13.xls")
import excel using "$raw/ZipHsaHrr13.xls", clear firstrow
keep hrrnum hrrstate

duplicates drop

rename hrrnum hrr
rename hrrstate state

project, original("$root/geo_templates/state/state_database_clean.dta") preserve
merge m:1 state using "$root/geo_templates/state/state_database_clean.dta", assert(3) nogen keepusing(statefips)

tempfile hrr_to_state
save `hrr_to_state'

** Prepare coords of AK and HI from state geo
project, original("$root/geo_templates/state/state_coords_clean.dta")
project, original("$root/geo_templates/state/state_database_clean.dta")

use "$root/geo_templates/state/state_coords_clean.dta", clear
gen _polygonid=_ID
merge m:1 _polygonid using "$root/geo_templates/state/state_database_clean.dta", assert(3) nogen keepusing(statefips)

keep if inlist(statefips,2,15)

drop _polygonid
tempfile AK_HI_statecoords
save `AK_HI_statecoords'

** Load coordinates and state
use "$out/hrr_coords_temp.dta", clear
gen _polygonid=_ID
merge m:1 _polygonid using "$out/hrr_database", assert(3) nogen
merge m:1 hrr using `hrr_to_state', assert(3) nogen keepusing(statefips)

** Reshape U.S.
project, original("$root/util/reshape_us.do") preserve
do "$root/util/reshape_us.do"

** Replace Alaska and Hawaii with coords from state geo
* (the HRR shapefile comes with AK and HI inconveniently pre-rearranged)
qui tab _polygonid if statefips==2
assert r(r)==1
sum _polygonid if statefips==2, meanonly
local AK_polygonid = r(mean)

qui tab _polygonid if statefips==15
assert r(r)==1
sum _polygonid if statefips==15, meanonly
local HI_polygonid = r(mean)

drop if inlist(statefips,2,15)

append using `AK_HI_statecoords'
replace _ID = `AK_polygonid' if statefips==2
replace _ID = `HI_polygonid' if statefips==15

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/hrr_coords.dta", replace
project, creates("$out/hrr_coords.dta")

*** Step 4: Clean up extra files
erase "$out/hrr_database_temp.dta"
erase "$out/hrr_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/hrr_maptile.ado")

*** Step 6: Test geo-specific options
use "$out/hrr_database.dta", clear
rename _polygonid test

maptile test, geo(hrr) geofolder($out) ///
	savegraph("$test/hrr_noopt.png") replace
project, creates("$test/hrr_noopt.png") preserve
	
maptile test, geo(hrr) geofolder($out) ///
	conus ///
	savegraph("$test/hrr_conus.png") replace
project, creates("$test/hrr_conus.png") preserve
