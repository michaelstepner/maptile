*! 27dec2016  Michael Stepner, stepner@mit.edu

* imports 2011 Canadian province shapefile into Stata format


/*******************************

** INPUT FILES ** 
- gpr_000b11a_e.zip
	"Provinces/Territories"
	Boundary Files, 2011 Census. Statistics Canada Catalogue no. 92-160-X.
	Downloaded from: http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-2011-eng.cfm

- gpr_000b11a_e-simple.zip
	A transformed version of the Statistics Canada shapefile, with its detail
	simplified and file size reduced. Implemented in the script: simplify_can_prov.sh
	
- province_SGCcode_postalabbrev_crosswalk.dta
	Created from:
		StatsCan, 2011 Census, Table 8: Abbreviations and codes for provinces and territories
		http://www.statcan.gc.ca/pub/92-195-x/2011001/geo/prov/tbl/tbl8-eng.htm

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
global test "$root/tests/can_prov"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")

* Tell -project- that we use -geo2xy- (obtained from SSC, with added Lambert projection)
project, original("$root/util/geo2xy.ado")
project, original("$root/util/geo2xy.hlp")
project, original("$root/util/geo2xy_lambert_sphere.ado")
project, original("$root/util/geo2xy_lambert_sphere.hlp")


*** Step 1: Unzip & convert shape file to dta

project, relies_on("$raw/gpr_000b11a_e.zip")  // original shapefile
project, relies_on("$raw/simplify_can_prov.sh")  // shapefile simplification code
project, original("$raw/gpr_000b11a_e-simple.zip")  // simplified shapefile

cd "$raw"
unzipfile "$raw/gpr_000b11a_e-simple.zip", replace

shp2dta using "$raw/can_prov", database("$out/can_prov_database_temp") ///
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

* Rescale to Statistics Canada's standard Lambert projection for general maps of Canada
geo2xy _Y _X , replace proj(lambert_sphere, 49 77 `=63+23/60+26/3600' `=-91-52/60')

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

*** Step 6: Test geo-specific options
use "$out/can_prov_database.dta", clear
rename _polygonid test

maptile test, geo(can_prov) geofolder($out) ///
	savegraph("$test/can_prov_noopt.png") resolution(0.25) replace
project, creates("$test/can_prov_noopt.png") preserve

maptile test, geo(can_prov) geofolder($out) ///
	mapifprov ///
	savegraph("$test/can_prov_mapifprov.png") resolution(0.25) replace
project, creates("$test/can_prov_mapifprov.png") preserve

maptile test, geo(can_prov) geofolder($out) ///
	legendoffset(5) ///
	savegraph("$test/can_prov_legendoffset5.png") resolution(0.25) replace
project, creates("$test/can_prov_legendoffset5.png") preserve

* Test different geoids
foreach geoid in prov provcode provcode_old provname {

	maptile test, geo(can_prov) geofolder($out) ///
		geoid(`geoid') ///
		savegraph("$test/can_prov_geoid_`geoid'.png") resolution(0.25) replace
	project, creates("$test/can_prov_geoid_`geoid'.png") preserve

}

* Test automatic legendoffset as number of quantiles increases
forvalues n=4(2)12 {

	maptile test, geo(can_prov) geofolder($out) ///
		nq(`n') legd(2) ///
		savegraph("$test/can_prov_nq`n'.png") resolution(0.25) replace
	project, creates("$test/can_prov_nq`n'.png") preserve

}

forvalues n=4(2)6 {

	maptile test, geo(can_prov) geofolder($out) ///
		nq(`n') mapifprov legd(2) ///
		savegraph("$test/can_prov_mapifprov_nq`n'.png") resolution(0.25) replace
	project, creates("$test/can_prov_mapifprov_nq`n'.png") preserve

}
