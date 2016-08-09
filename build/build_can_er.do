*! 5aug2016  Michael Stepner, stepner@mit.edu

* imports 2011 Canadian economic regions shapefile into Stata format

/*******************************

** INPUT FILES ** 
- ger_000b11a_e.zip
	"Economic Regions"
	Boundary Files, 2011 Census. Statistics Canada Catalogue no. 92-160-X.
	Downloaded from: http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-2011-eng.cfm

- ger_000b11a_e-simple.zip
	A transformed version of the Statistics Canada shapefile, with its detail
	simplified and file size reduced. Implemented in the script: simplify_can_er.sh

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
global raw "$root/raw_data/can_er"
global out "$root/geo_templates/can_er"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

*** Step 1: Unzip & convert shape file to dta

project, relies_on("$raw/ger_000b11a_e.zip")  // original shapefile
project, relies_on("$raw/simplify_can_er.sh")  // shapefile simplification code
project, original("$raw/ger_000b11a_e-simple.zip")  // simplified shapefile

cd "$raw"
unzipfile "$raw/ger_000b11a_e-simple.zip", replace

shp2dta using "$raw/can_er", database("$out/can_er_database_temp") ///
	coordinates("$out/can_er_coords_temp") genid(_polygonid) replace


*** Step 2: Clean database
use "$out/can_er_database_temp", clear

* Rename variables
rename PRUID provcode
label var provcode "Province code (2-digit, SGC)"
rename ERUID er
label var er "Economic Region code (4-digit, first 2 are province)"

destring provcode er, replace

keep provcode er _polygonid

save12 "$out/can_er_database.dta", replace
project, creates("$out/can_er_database.dta")


*** Step 3: Clean coordinates
use "$out/can_er_coords_temp", clear

** Rescale to a better projection: by default, streched too wide
* (used height & width of Saskwatchewan as a guide, comparing to Google Maps projection)
replace _Y=_Y*1.709

save12 "$out/can_er_coords.dta", replace
project, creates("$out/can_er_coords.dta")


*** Step 4: Clean up extra files
erase "$out/can_er_database_temp.dta"
erase "$out/can_er_coords_temp.dta"

*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/can_er_maptile.ado")
project, relies_on("$out/can_er_maptile.md")
project, relies_on("$out/can_er_maptile.smcl")
