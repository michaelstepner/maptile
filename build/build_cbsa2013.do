*! 5aug2016  Meru Bhanot (meru@uchicago.edu) and Michael Stepner (stepner@mit.edu)

* imports 2013 U.S. CBSA shapefile into Stata format

/*******************************

** INPUT FILES ** 
- US_cbsa_2013.dbf
- US_cbsa_2013.shp
	2013 CBSA shapefile fom NHGIS

- US_state_2010.zip
	2010 state shapefile from NHGIS

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
global raw "$root/raw_data/cbsa2013"
global out "$root/geo_templates/cbsa2013"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

* Create a temporary directory
cap mkdir "$root/temp"

*** Step 1: Process state outline shapefile

* Convert from shapefile to dta
project, original("$raw/US_state_2010.zip")
cd "$raw"
unzipfile "$raw/US_state_2010.zip", replace

shp2dta using "$raw/US_state_2010.shp", ///
	database("$root/temp/CBSA_stateborders_database.dta") ///
	coordinates("$root/temp/CBSA_stateborders_coords.dta") ///
	replace

* Reshape state outline shapefile

project, original("$root/util/reshape_us_CBSAstateoutline.ado")

reshape_us_CBSAstateoutline using "$root/temp/CBSA_stateborders_coords.dta", ///
	save_coords("$out/cbsa2013_stateborders.dta") ///
	save_shifts("$root/temp/CBSA_AlaskaHawaiiShifts.dta")
	
project, creates("$out/cbsa2013_stateborders.dta")

* Create state outline shapefile without AK or HI

use "$out/cbsa2013_stateborders.dta", clear
drop if !missing(sname)
drop sname 
save12 "${out}/cbsa2013_stateborders_noAKHI.dta", replace
project, creates("${out}/cbsa2013_stateborders_noAKHI.dta")

*** Step 3: Process CBSA shapefile

** Step 3.1: Unzip & convert shape file to dta
project, original("$raw/US_cbsa_2013.shp")
project, relies_on("$raw/US_cbsa_2013.dbf")

shp2dta using "$raw/US_cbsa_2013.shp", ///
	database("$root/temp/cbsa2013_database.dta") ///
	coordinates("$root/temp/cbsa2013_coords.dta") ///
	replace

** Step 3.2: Clean database
use "$root/temp/cbsa2013_database.dta", clear
gen statefp = 15 if regexm(NAME,", HI")
replace statefp = 2 if regexm(NAME,", AK")
drop if regexm(NAME,", PR") // Drop Puerto Rico

keep CBSAFP _ID statefp
rename CBSAFP cbsa2013
destring cbsa2013, replace
recast double cbsa2013

save12 "${out}/cbsa2013_database.dta", replace
project, creates("${out}/cbsa2013_database.dta")

** Step 3.3: Fix Coordinates
use "$root/temp/cbsa2013_coords.dta", clear
merge m:1 _ID using "$out/cbsa2013_database.dta", assert(1 3) keep(3) nogen

project, original("$root/util/reshape_us_CBSA.ado") preserve
reshape_us_CBSA using "$root/temp/CBSA_AlaskaHawaiiShifts.dta" // Rearrange Hawaii and Alaska

sort _ID, stable
keep _ID _X _Y

save12 "$out/cbsa2013_coords.dta", replace
project, creates("$out/cbsa2013_coords.dta")

** Step 3.4: Clean up temporary files
rm "$root/temp/CBSA_AlaskaHawaiiShifts.dta"
rm "$root/temp/CBSA_stateborders_coords.dta"
rm "$root/temp/CBSA_stateborders_database.dta"
rm "$root/temp/cbsa2013_coords.dta"
rm "$root/temp/cbsa2013_database.dta"
rmdir "$root/temp"

** Step 3.5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/cbsa2013_maptile.ado")
project, relies_on("$out/cbsa2013_maptile.smcl")
