*! 23jun2017  Benjmain Chartock (chartock@wharton.upenn.edu) and Michael Stepner (stepner@mit.edu)

* merges 2014 County boundaries into 2014 US District Court boundaries

/*******************************

** INPUT FILES ** 
- judicialdistrictcountiescrosswalk-30469.xlsx
    Downloaded from http://doi.org/10.3886/E30426V1
	
	Licensed under the Creative Commons Attribution 4.0 International License,
	https://creativecommons.org/licenses/by/4.0/
	
	Citation:
		Hansen, Mary Eschelbach; Chen, Jess; Davis, Matthew.
		United States District Court Boundary Shapefiles (1900-2000).
		Ann Arbor, MI: Inter-university Consortium for Political and
		Social Research [distributor], 2015-03-02.
		http://doi.org/10.3886/E30426V1
		
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
global raw "$root/raw_data/district_courts"
global out "$root/geo_templates/district_courts"
global test "$root/tests/district_courts"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

* Tell -project- that we use -mergepoly- (obtained from SSC)
project, original("$root/util/mergepoly.ado")
project, original("$root/util/mergepoly.hlp")


*** Step 1: Use County -> District Courts crosswalk to
*** 		merge District Court variable onto County database
project, original("$raw/judicialdistrictcountiescrosswalk-30469.xlsx")
import excel using "$raw/judicialdistrictcountiescrosswalk-30469.xlsx", first clear

keep if end_district == "  1/1/2014"
isid FIPS
drop start_district end_district

gen district_short = "D " + state
replace district_short = "CD " + state if district == "Central District"
replace district_short = "ED " + state if district == "Eastern District"
replace district_short = "MD " + state if district == "Middle District"
replace district_short = "ND " + state if district == "Northern District"
replace district_short = "SD " + state if district == "Southern District"
replace district_short = "WD " + state if district == "Western District"

keep FIPS state_code district_short
rename FIPS county
rename state_code statefips
rename district_short district
isid county

project, original("$root/geo_templates/county2014/county2014_database.dta") preserve
merge 1:1 county using "$root/geo_templates/county2014/county2014_database.dta", assert(1 3) keep(3) nogen


*** Step 2: Merge county polygons into District Courts

project, original("$root/geo_templates/county2014/county2014_coords.dta") preserve
mergepoly id using "$root/geo_templates/county2014/county2014_coords.dta", ///
	coordinates("$out/district_courts_coords.dta") ///
	by(district) replace
save12 "$out/district_courts_database.dta", replace
project, creates("$out/district_courts_database.dta")

* Resave coords in Stata 12 format
use "$out/district_courts_coords.dta", clear
save12 "$out/district_courts_coords.dta", replace
project, creates("$out/district_courts_coords.dta")


*** Step 3: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/district_courts_maptile.ado")
project, relies_on("$out/district_courts_maptile.smcl")


*** Step 4: Test geo-specific options
use "$out/district_courts_database.dta", clear
rename id test

maptile test, geo(district_courts) geofolder($out) ///
	savegraph("$test/district_courts_noopt.png") resolution(0.5) replace
project, creates("$test/district_courts_noopt.png") preserve
	
maptile test, geo(district_courts) geofolder($out) ///
	conus ///
	savegraph("$test/district_courts_conus.png") resolution(0.5) replace
project, creates("$test/district_courts_conus.png") preserve

project, original("$root/geo_templates/state/state_coords_clean.dta") preserve
copy "$root/geo_templates/state/state_coords_clean.dta" "$out/state_coords_clean.dta"

maptile test, geo(district_courts) geofolder($out) ///
	stateoutline(medium) ///
	savegraph("$test/district_courts_stoutline.png") resolution(0.5) replace
project, creates("$test/district_courts_stoutline.png") preserve

maptile test, geo(district_courts) geofolder($out) ///
	conus stateoutline(medium) ///
	savegraph("$test/district_courts_conus_stoutline.png") resolution(0.5) replace
project, creates("$test/district_courts_conus_stoutline.png") preserve

erase "$out/state_coords_clean.dta"

