*! 20Mar2019  Chigusa Okamoto(okamoto.chigusa.econ@gmail.com, okamoto-chigusa546@g.ecc.u-tokyo.ac.jp) 
* and Michael Stepner (stepner@mit.edu, michaelstepner@gmail.com)

* imports 2015 Administrative Zones shapefile into Stata format


/*******************************

** INPUT FILES ** 
- mmm20151001_district.zip
	Provided by Municipality Map Maker for Web
	(Takashi Kirimura, http://www.tkirimura.com/mmm/).
	Ordinance-designated cities are outputted in adminitrative district units.

	
- mmm20151001_city.zip
	Provided by Municipality Map Maker for Web
	(Takashi Kirimura, http://www.tkirimura.com/mmm/).
	Ordinance-designated cities are outputted in city units.
	
*******************************/


*** Step 0: Initialize

* Check if run using -project-
return clear
capture project, doinfo
if (_rc==0 & !mi(r(pname))) global root `r(pdir)'  // run using -project-
else {  // running directly

	global root "/Users/chigusaokamoto/localgit/maptile/geo_jpn_mun2015_creation"

	* Disable project (since running do-files directly)
	cap program drop project
	program define project
		di "Project is disabled, skipping project command. (To re-enable, run -{stata program drop project}-)"
	end
	
}

* Specify subdirectories
global raw "$root/raw_data/jpn_mun2015"
global out "$root/geo_templates/jpn_mun2015"
global test "$root/tests/jpn_mun2015"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")



*** Step 1: Unzip & convert shape file to dta
foreach i in district city{

	project, original("$raw/mmm20151001_`i'.zip")
	cd "$raw"
	unzipfile "$raw/mmm20151001_`i'.zip", replace
	shp2dta using "$raw/mmm20151001", database("$out/jpn_mun2015_database_`i'") ///
		coordinates("$out/jpn_mun2015_coords_`i'") replace
	erase "$raw/mmm20151001.shp"
	erase "$raw/mmm20151001.shx"
	erase "$raw/mmm20151001.prj"
	erase "$raw/mmm20151001.dbf"

}	


	
*** Step 2: Clean database
cd "$root"
foreach i in district city{
	
	use "$out/jpn_mun2015_database_`i'", clear
	keep JISCODE _ID
	rename JISCODE mun
	
	* Drop the Northern Territories and Ogasawara Village
	drop if mun == 13421
	drop if inrange(mun, 1695, 1700)
	bysort mun: assert _N == 1
	save12 "$out/jpn_mun2015_database_`i'.dta", replace
	project, creates("$out/jpn_mun2015_database_`i'.dta")
	
}



*** Step 3: Clean coordinates
foreach i in district city{

	* Attach "mun" to coordinates file
	use "$out/jpn_mun2015_coords_`i'.dta", clear
	merge m:1 _ID using "$out/jpn_mun2015_database_`i'.dta", assert(1 3) keep(3) nogen	

	* Drop Northern Territories and Ogasawara Village
	drop if mun == 13421
	drop if inrange(mun, 1695, 1700)
	sort _ID, stable
	save12 "$out/jpn_mun2015_coords_`i'.dta", replace
	project, creates("$out/jpn_mun2015_coords_`i'.dta")

}


*** Step 4: Create shapefiles for options
** Shapefile for option "compressed": move Okinawa prefecture to topleft

foreach i in district city{ 

	use "$out/jpn_mun2015_coords_`i'.dta", clear
	replace _X = _X + 6 if mun >= 47000
	replace _Y = _Y + 16 if mun >= 47000
	sort _ID, stable
	drop mun
	save12 "$out/jpn_mun2015_coords_`i'_compressed.dta", replace
	project, creates("$out/jpn_mun2015_coords_`i'_compressed.dta")

}


*** Step 5: Reference other files using -project-
project, relies_on("$root/readme.txt")
project, relies_on("$out/jpn_mun2015_maptile.ado")
project, relies_on("$out/jpn_mun2015_maptile.md")
project, relies_on("$out/jpn_mun2015_maptile.smcl")



*** Step 6: Test geo-specific options
use "$out/jpn_mun2015_database_city.dta", clear 
rename _ID test

* no option	
maptile test, geo(jpn_mun2015) geofolder($out) ///
	savegraph("$test/jpn_mun2015_noopt.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_noopt.png") preserve

* compressed
maptile test, geo(jpn_mun2015) geofolder($out) compressed ///
	savegraph("$test/jpn_mun2015_compressed.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_compressed.png") preserve


* district
use "$out/jpn_mun2015_database_district.dta", clear 
rename _ID test
maptile test, geo(jpn_mun2015) geofolder($out) district ///
	savegraph("$test/jpn_mun2015_district.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_district.png") preserve


* district & compressed
maptile test, geo(jpn_mun2015) geofolder($out) district compressed ///
	savegraph("$test/jpn_mun2015_district_compressed.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_district_compressed.png") preserve


* Ordinance-designated cities in city level
* Example: Tokyo-to (except islands), Saitama-Ken, Chiba-ken, Kanagawa-ken
use "$out/jpn_mun2015_database_city.dta", clear
rename _ID test
local area inrange(mun, 11000, 14999) & !inrange(mun, 13360, 13421)
maptile test if `area', geo(jpn_mun2015) geofolder($out) mapif(`area') ///
	savegraph("$test/jpn_mun2015_designed.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_designed.png") preserve

	
* Ordinance-designated cities in districtrict level
* Example: Tokyo-to (except islands), Saitama-Ken, Chiba-ken, Kanagawa-ken
use "$out/jpn_mun2015_database_district.dta", clear 
rename _ID test
local area inrange(mun, 11000, 14999) & !inrange(mun, 13360, 13421)
maptile test if `area', geo(jpn_mun2015) geofolder($out) mapif(`area') district ///
	savegraph("$test/jpn_mun2015_district_designed.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_district_designed.png") preserve
	

* Tokyo's 23 wards w/o outption
use "$out/jpn_mun2015_database_city.dta", clear
rename _ID test
keep if inrange(mun, 13101, 13123)
maptile test if inrange(mun, 13101, 13123), ///
	geo(jpn_mun2015) geofolder($out) mapif(inrange(mun, 13101, 13123)) ///
	savegraph("$test/jpn_mun2015_tokyo.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_tokyo.png") preserve

	
* Tokyo's 23 wards w/ district
use "$out/jpn_mun2015_database_district.dta", clear 
rename _ID test
keep if inrange(mun, 13101, 13123)
maptile test if inrange(mun, 13101, 13123), district ///
	geo(jpn_mun2015) geofolder($out) mapif(inrange(mun, 13101, 13123)) ///
	savegraph("$test/jpn_mun2015_district_tokyo.png") resolution(0.25) replace
project, creates("$test/jpn_mun2015_district_tokyo.png") preserve

