*! 8aug2016  Michael Stepner, stepner@mit.edu

* imports 2011 Canadian province shapefile into Stata format


/*******************************

** INPUT FILES ** 
- gpr_000b11a_e.zip
	"Provinces/Territories"
	Boundary Files, 2011 Census. Statistics Canada Catalogue no. 92-160-X.
	Downloaded from: http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-2011-eng.cfm

- province_SGCcode_postalabbrev_crosswalk.dta
	Created from:
		StatsCan, 2011 Census, Table 8: Abbreviations and codes for provinces and territories
		http://www.statcan.gc.ca/pub/92-195-x/2011001/geo/prov/tbl/tbl8-eng.htm

** OUTPUT FILES **
- can_prov_database.dta
- can_prov_coords.dta

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
global raw "$root/raw_data/can_prov"
global out "$root/geo_templates/can_prov"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


*** Step 1: Unzip & convert shape file to dta

project, original("$raw/gpr_000b11a_e.zip")
cd "$raw"
unzipfile "$raw/gpr_000b11a_e.zip", replace

shp2dta using "$raw/gpr_000b11a_e", database("$out/can_prov_database_temp") ///
	coordinates("$out/can_prov_coords_temp") genid(_polygonid) replace


*** Step 2: Clean database
use "$out/can_prov_database_temp", clear

* Rename variables
rename PRUID provcode
label var provcode "Standard geographical classification (SGC) code"
rename PRENAME provname
label var provname "Province name (English)"

* Create classical StatsCan province codes
destring provcode, replace
gen provcode_old=real(substr(string(provcode),2,1)) + 10 * (provcode>=60)
label var provcode_old "Classical Statistics Canada province codes"

* Bring in 2-letter provice abbreviations
project, original("$raw/province_SGCcode_postalabbrev_crosswalk.dta") preserve
merge 1:1 provcode using "$raw/province_SGCcode_postalabbrev_crosswalk.dta", assert(3) nogen
label var prov "2-letter Postal Abbreviation"

keep prov provcode provcode_old provname _polygonid

save12 "$out/can_prov_database.dta", replace
project, creates("$out/can_prov_database.dta")


*** Step 3: Clean coordinates
use "$out/can_prov_coords_temp", clear

** Rescale to a better projection: by default, streched too wide
* (used height & width of Saskwatchewan as a guide, comparing to Google Maps projection)
replace _Y=_Y*1.709

save12 "$out/can_prov_coords.dta", replace
project, creates("$out/can_prov_coords.dta")


*** Step 4: Clean up extra files
erase "$out/can_prov_database_temp.dta"
erase "$out/can_prov_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/can_prov_maptile.ado")
project, relies_on("$out/can_prov_maptile.md")
project, relies_on("$out/can_prov_maptile.smcl")
