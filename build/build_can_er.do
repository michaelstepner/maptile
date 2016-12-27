*! 27dec2016  Michael Stepner, stepner@mit.edu

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
global test "$root/tests/can_er"

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

* Rescale to Statistics Canada's standard Lambert projection for general maps of Canada
geo2xy _Y _X , replace proj(lambert_sphere, 49 77 `=63+23/60+26/3600' `=-91-52/60')

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

*** Step 6: Test geo-specific options
use "$out/can_er_database.dta", clear
rename _polygonid test

maptile test, geo(can_er) geofolder($out) ///
	savegraph("$test/can_er_noopt.png") resolution(0.25) replace
project, creates("$test/can_er_noopt.png") preserve

maptile test, geo(can_er) geofolder($out) ///
	mapifprov ///
	savegraph("$test/can_er_mapifprov.png") resolution(0.25) replace
project, creates("$test/can_er_mapifprov.png") preserve

maptile test, geo(can_er) geofolder($out) ///
	legendoffset(5) ///
	savegraph("$test/can_er_legendoffset5.png") resolution(0.25) replace
project, creates("$test/can_er_legendoffset5.png") preserve

project, original("$root/geo_templates/can_prov/can_prov_coords.dta") preserve
copy "$root/geo_templates/can_prov/can_prov_coords.dta" "$out/can_prov_coords.dta"

maptile test, geo(can_er) geofolder($out) ///
	provoutline(medthin) ///
	savegraph("$test/can_er_provoutline.png") resolution(0.25) replace
project, creates("$test/can_er_provoutline.png") preserve

maptile test, geo(can_er) geofolder($out) ///
	mapifprov provoutline(medthin) ///
	savegraph("$test/can_er_mapifprov_provoutline.png") resolution(0.25) replace
project, creates("$test/can_er_mapifprov_provoutline.png") preserve

erase "$out/can_prov_coords.dta"

* Test automatic legendoffset as number of quantiles increases
forvalues n=4(2)20 {

	maptile test, geo(can_er) geofolder($out) ///
		nq(`n') legd(2) ///
		savegraph("$test/can_er_nq`n'.png") resolution(0.25) replace
	project, creates("$test/can_er_nq`n'.png") preserve

}

forvalues n=4(2)20 {

	maptile test, geo(can_er) geofolder($out) ///
		nq(`n') mapifprov legd(2) ///
		savegraph("$test/can_er_mapifprov_nq`n'.png") resolution(0.25) replace
	project, creates("$test/can_er_mapifprov_nq`n'.png") preserve

}
