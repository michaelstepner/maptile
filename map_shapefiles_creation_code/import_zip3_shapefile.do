* import_zip3_shapefile.do: imports 2000 Census 3-digit ZCTA shapefile into Stata format, cleaning the output files

*** Version history:
* 2016-08-05, Michael Stepner
* 2014-01-31, Michael Stepner
* 2013-07-06, Michael Stepner


/*******************************

** INFORMATION ABOUT ZCTAs (ZIP Code Tabulation Areas) **
http://www.census.gov/geo/reference/zctas.html
http://www.census.gov/geo/reference/zctafaq.html

** INPUT FILES ** 
- z399_d00_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/prev_cartbndry_names.html
	  Under "3-Digit ZIP Code Tabulation Areas"
- reshape_us.do

** OUTPUT FILES **
- zip3_database_clean.dta
- zip3_coords_clean.dta

*******************************/

global root "/Users/michael/Documents/git_repos/maptile_geo_templates"
global raw "$root/raw_data"
global out "$root/map_shapefiles"
global code "$root/map_shapefiles_creation_code"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/z399_d00_shp.zip", replace

shp2dta using "$raw/z399_d00", database("$out/zip3_database") ///
	coordinates("$out/zip3_coords") genid(id) replace


*** Step 2: Clean database
cd "$code"

use "$out/zip3_database", clear
keep ZCTA3 id
rename ZCTA3 zip3
destring zip3, replace
* Drop Puerto Rico
drop if inrange(zip3,006,009)
save12 "$out/zip3_database_clean", replace

*** Step 3: Clean coordinates
use "$out/zip3_coords", clear
gen id=_ID
merge m:1 id using "$out/zip3_database_clean", assert(1 3) keep(3) nogen

** Generate state variable for AK and HI
gen statefips=2 if inrange(zip3,995,999)
replace statefips=15 if inlist(zip3,967,968)

** Reshape U.S.
do "$code/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/zip3_coords_clean", replace

*** Step 4: Clean up extra files
erase "$out/zip3_database.dta"
erase "$out/zip3_coords.dta"
