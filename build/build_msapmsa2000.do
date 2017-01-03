*! 3jan2017  Meru Bhanot (meru@uchicago.edu) and Michael Stepner (stepner@mit.edu)

* imports 2000 U.S. PMSA shapefile into Stata format

/*******************************

** INPUT FILES ** 
- US_msapmsa_2000.dbf
- US_msapmsa_2000.shp
	2000 PMSA shapefile fom NHGIS,
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
global raw "$root/raw_data/msapmsa2000"
global out "$root/geo_templates/msapmsa2000"
global test "$root/tests/msapmsa2000"

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
	save_coords("$out/msapmsa2000_stateborders.dta") ///
	save_shifts("$root/temp/MSA_AlaskaHawaiiShifts.dta")
	
project, creates("$out/msapmsa2000_stateborders.dta")

* Create state outline shapefile without AK or HI

use "$out/msapmsa2000_stateborders.dta", clear
drop if !missing(sname)
drop sname 
save12 "${out}/msapmsa2000_stateborders_noAKHI.dta", replace
project, creates("${out}/msapmsa2000_stateborders_noAKHI.dta")


*** Step 2: Process MSA/PMSA shapefile

** Step 2.1: Unzip & convert shape file to dta
project, original("$raw/US_pmsa_2000.shp")
project, relies_on("$raw/US_pmsa_2000.dbf")

shp2dta using "$raw/US_pmsa_2000.shp", ///
	database("$root/temp/msapmsa2000_database.dta") ///
	coordinates("$root/temp/msapmsa2000_coords.dta") ///
	replace

** Step 2.2: Clean database
use "$root/temp/msapmsa2000_database.dta", clear

rename PMSA msapmsa2000
rename MSACMSA msacmsa2000
rename _ID _IDPMSA

keep msapmsa2000 msacmsa2000 _IDPMSA
destring msapmsa2000 msacmsa2000, replace
recast double msapmsa2000 msacmsa2000

project, original("$root/geo_templates/msacmsa2000/msacmsa2000_database.dta") preserve
merge m:1 msacmsa2000 using "$root/geo_templates/msacmsa2000/msacmsa2000_database.dta",	assert(2 3) nogen
rename _ID _IDCMSA
sort _IDCMSA _IDPMSA
gen _ID = _n

preserve
keep _IDCMSA _IDPMSA _ID
save "$root/temp/ID_mapping_pmsa_cmsa.dta", replace
restore

replace msapmsa2000 = msacmsa2000 if missing(msapmsa2000)
keep msapmsa2000 _ID statefp

save12 "$out/msapmsa2000_database.dta", replace
project, creates("$out/msapmsa2000_database.dta")

** Step 2.3: Fix Coordinates

// Get coordinates from msacmsa, already with Hawaii and Alaska moved
project, original("$root/geo_templates/msacmsa2000/msacmsa2000_coords.dta")
use "$root/geo_templates/msacmsa2000/msacmsa2000_coords.dta", clear

rename _ID _IDCMSA
joinby _IDCMSA using "$root/temp/ID_mapping_pmsa_cmsa.dta"
sort _ID, stable
drop if !missing(_IDPMSA)
drop _IDPMSA _IDCMSA
order _ID

tempfile cmsacoords
save `cmsacoords', replace

// Open our coordinates and append
use "$root/temp/msapmsa2000_coords.dta", clear

rename _ID _IDPMSA
joinby _IDPMSA using "$root/temp/ID_mapping_pmsa_cmsa.dta"
keep _ID _X _Y
order _ID

append using `cmsacoords'
sort _ID, stable

save12 "$out/msapmsa2000_coords.dta", replace
project, creates("$out/msapmsa2000_coords.dta")


*** Step 3: Clean up temporary files
rm "$root/temp/MSA_stateborders_database.dta"
rm "$root/temp/MSA_stateborders_coords.dta"
rm "$root/temp/MSA_AlaskaHawaiiShifts.dta"
rm "$root/temp/msapmsa2000_coords.dta"
rm "$root/temp/msapmsa2000_database.dta"
rm "$root/temp/ID_mapping_pmsa_cmsa.dta"
rmdir "$root/temp"


*** Step 4: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/msapmsa2000_maptile.ado")
project, relies_on("$out/msapmsa2000_maptile.smcl")


*** Test geo-specific options
use "$out/msapmsa2000_database.dta", clear
rename _ID test

maptile test, geo(msapmsa2000) geofolder($out) ///
	savegraph("$test/msapmsa2000_noopt.png") resolution(0.25) replace
project, creates("$test/msapmsa2000_noopt.png") preserve

maptile test, geo(msapmsa2000) geofolder($out) ///
	conus ///
	savegraph("$test/msapmsa2000_conus.png") resolution(0.25) replace
project, creates("$test/msapmsa2000_conus.png") preserve

maptile test, geo(msapmsa2000) geofolder($out) ///
	nostateoutline ///
	savegraph("$test/msapmsa2000_nostateoutline.png") resolution(0.25) replace
project, creates("$test/msapmsa2000_nostateoutline.png") preserve

maptile test, geo(msapmsa2000) geofolder($out) ///
	conus nostateoutline ///
	savegraph("$test/msapmsa2000_conus_nostateoutline.png") resolution(0.25) replace
project, creates("$test/msapmsa2000_conus_nostateoutline.png") preserve
