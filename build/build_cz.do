*! 16sep2016  Michael Stepner, stepner@mit.edu

* merges 1990 County shapefile into a 1990 CZ shapefile

/*******************************

** INPUT FILES ** 
- cw_cty_czone.dta
	Provided by David Dorn at http://www.ddorn.net/data.htm -- file [E6]
	
	Original citation:
		David Autor and David Dorn. "The Growth of Low Skill Service Jobs
		and the Polarization of the U.S. Labor Market." American Economic
		Review, 103(5), 1553-1597, 2013.

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
global raw "$root/raw_data/cz"
global out "$root/geo_templates/cz"
global test "$root/tests/cz"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

* Tell -project- that we use -mergepoly- (obtained from SSC)
project, original("$root/util/mergepoly.ado")
project, original("$root/util/mergepoly.hlp")


*** Step 1: Use Dorn County -> CZ crosswalk to merge CZ variable onto county database
project, original("$raw/cw_cty_czone.dta")
use "$raw/cw_cty_czone.dta", clear
rename cty_fips county
rename czone cz
keep county cz

project, original("$root/geo_templates/county1990/county1990_database.dta") preserve
merge 1:m county using "$root/geo_templates/county1990/county1990_database.dta", assert(3) nogen
compress


*** Step 2: Merge county polygons into CZs

project, original("$root/geo_templates/county1990/county1990_coords.dta") preserve
mergepoly id using "$root/geo_templates/county1990/county1990_coords.dta", ///
	coordinates("$out/cz_coords.dta") ///
	by(cz) replace
save12 "$out/cz_database.dta", replace
project, creates("$out/cz_database.dta")

* Resave coords in Stata 12 format
use "$out/cz_coords.dta", clear
save12 "$out/cz_coords.dta", replace
project, creates("$out/cz_coords.dta")


*** Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/cz_maptile.ado")
project, relies_on("$out/cz_maptile.md")
project, relies_on("$out/cz_maptile.smcl")

*** Test geo-specific options
use "$out/cz_database.dta", clear
rename id test

maptile test, geo(cz) geofolder($out) ///
	savegraph("$test/cz_noopt.png") replace
project, creates("$test/cz_noopt.png") preserve
	
maptile test, geo(cz) geofolder($out) ///
	conus ///
	savegraph("$test/cz_conus.png") replace
project, creates("$test/cz_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(cz) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/cz_stoutline.png") replace
project, creates("$test/cz_stoutline.png") preserve

maptile test, geo(cz) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/cz_conus_stoutline.png") replace
project, creates("$test/cz_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"
