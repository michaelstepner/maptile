*! 3jan2017  Meru Bhanot (meru@uchicago.edu) and Michael Stepner (stepner@mit.edu)

* imports 2000 U.S. MSA/CMSA shapefile into Stata format

/*******************************

** INPUT FILES ** 
- US_msacmsa_2000.dbf
- US_msacmsa_2000.shp
	2000 MSA/CMSA shapefile fom NHGIS,
	processed by Meru Bhanot using mapshaper.org to reduce its resolution

- US_state_2000.zip
	2000 state shapefile from NHGIS

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
global raw "$root/raw_data/msacmsa2000"
global out "$root/geo_templates/msacmsa2000"
global test "$root/tests/msacmsa2000"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

* Create a temporary directory
cap mkdir "$root/temp"


*** Step 1: Process state outline shapefile

* Convert from shapefile to dta
project, original("$raw/US_state_2000.zip")
cd "$raw"
unzipfile "$raw/US_state_2000.zip", replace

shp2dta using "$raw/US_state_2000.shp", ///
	database("$root/temp/MSA_stateborders_database.dta") ///
	coordinates("$root/temp/MSA_stateborders_coords.dta") ///
	replace
	
* Reshape state outline shapefile

project, original("$root/util/reshape_us_CBSAstateoutline.ado")

reshape_us_CBSAstateoutline using "$root/temp/MSA_stateborders_coords.dta", ///
	save_coords("$out/msacmsa2000_stateborders.dta") ///
	save_shifts("$root/temp/MSA_AlaskaHawaiiShifts.dta")
	
project, creates("$out/msacmsa2000_stateborders.dta")

* Create state outline shapefile without AK or HI

use "$out/msacmsa2000_stateborders.dta", clear
drop if !missing(sname)
drop sname 
save12 "${out}/msacmsa2000_stateborders_noAKHI.dta", replace
project, creates("${out}/msacmsa2000_stateborders_noAKHI.dta")


*** Step 2: Process MSA/CMSA shapefile

** Step 2.1: Unzip & convert shape file to dta
project, original("$raw/US_msacmsa_2000.shp")
project, relies_on("$raw/US_msacmsa_2000.dbf")

shp2dta using "$raw/US_msacmsa_2000.shp", ///
	database("$root/temp/msacmsa2000_database.dta") ///
	coordinates("$root/temp/msacmsa2000_coords.dta") ///
	replace

** Step 2.2: Clean database
use "$root/temp/msacmsa2000_database.dta", clear

keep MSACMSA _ID
rename MSACMSA msacmsa2000
destring msacmsa2000, replace
recast double msacmsa2000

// make statefp to id Hawaii and Alaska for reshaping: http://www.census.gov/population/estimates/metro-city/99mfips.txt
gen statefp = 15 if msacmsa == 3320
replace statefp = 2 if msacmsa == 380

save12 "${out}/msacmsa2000_database.dta", replace
project, creates("${out}/msacmsa2000_database.dta")

** Step 2.3: Fix Coordinates
use "$root/temp/msacmsa2000_coords.dta", clear
merge m:1 _ID using "$out/msacmsa2000_database.dta", assert(1 3) keep(3) nogen

project, original("$root/util/reshape_us_CBSA.ado") preserve
reshape_us_CBSA using "$root/temp/MSA_AlaskaHawaiiShifts.dta" // Rearrange Hawaii and Alaska

sort _ID, stable
keep _ID _X _Y

save12 "$out/msacmsa2000_coords.dta", replace
project, creates("$out/msacmsa2000_coords.dta")


*** Step 3: Clean up temporary files
rm "$root/temp/MSA_stateborders_database.dta"
rm "$root/temp/MSA_stateborders_coords.dta"
rm "$root/temp/MSA_AlaskaHawaiiShifts.dta"
rm "$root/temp/msacmsa2000_coords.dta"
rm "$root/temp/msacmsa2000_database.dta"
rmdir "$root/temp"


*** Step 4: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/msacmsa2000_maptile.ado")
project, relies_on("$out/msacmsa2000_maptile.smcl")


*** Test geo-specific options
use "$out/msacmsa2000_database.dta", clear
rename _ID test

maptile test, geo(msacmsa2000) geofolder($out) ///
	savegraph("$test/msacmsa2000_noopt.png") resolution(0.25) replace
project, creates("$test/msacmsa2000_noopt.png") preserve

maptile test, geo(msacmsa2000) geofolder($out) ///
	conus ///
	savegraph("$test/msacmsa2000_conus.png") resolution(0.25) replace
project, creates("$test/msacmsa2000_conus.png") preserve

maptile test, geo(msacmsa2000) geofolder($out) ///
	nostateoutline ///
	savegraph("$test/msacmsa2000_nostateoutline.png") resolution(0.25) replace
project, creates("$test/msacmsa2000_nostateoutline.png") preserve

maptile test, geo(msacmsa2000) geofolder($out) ///
	conus nostateoutline ///
	savegraph("$test/msacmsa2000_conus_nostateoutline.png") resolution(0.25) replace
project, creates("$test/msacmsa2000_conus_nostateoutline.png") preserve
