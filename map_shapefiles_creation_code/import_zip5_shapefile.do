* import_zip5_shapefile.do: imports 2000 Census 5-digit ZCTA shapefile into Stata format, cleaning the output files
*! 5aug2016, Michael Stepner, stepner@mit.edu

/*******************************

** INFORMATION ABOUT ZCTAs (ZIP Code Tabulation Areas) **
http://www.census.gov/geo/reference/zctas.html
http://www.census.gov/geo/reference/zctafaq.html

** INPUT FILES ** 
- zt99_d00_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/prev_cartbndry_names.html
	  Under "5-Digit ZIP Code Tabulation Areas"
- reshape_us.do
	  
** OUTPUT FILES **
- zip5_database_clean.dta
- zip5_coords_clean.dta

*******************************/

global root "/Users/michael/Documents/git_repos/maptile_geo_templates"
global raw "$root/raw_data/zip5"
global out "$root/map_shapefiles"
global code "$root/map_shapefiles_creation_code"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/zt99_d00_shp.zip", replace

shp2dta using "$raw/zt99_d00", database("$out/zip5_database") ///
	coordinates("$out/zip5_coords") genid(id) replace


*** Step 2: Clean database
cd "$code"

use "$out/zip5_database", clear
keep ZCTA id
rename ZCTA zip5

* Generate a new polygon id that is sorted by zip5 (useful for selecting AK & HI, which is complicated by missing zip5 values)
egen _polygonid=group(zip5 id)

* Destring zip5
gen zip3=substr(zip5,1,3)
destring zip3, replace
destring zip5, replace force

* Missing values of zip5:
* --> Either had 3 digits followed by XX, which indicates a large sparsely-populated land area that doesn't map to a 5-digit ZIP
* 	  Or had 3 digits followed by HH, which indicates a body of water.
* 	  Source: websites about ZCTAs, referenced above.

* Drop Puerto Rico
drop if inrange(zip3,006,009)

save12 "$out/zip5_database_clean", replace

*** Step 3: Clean coordinates
use "$out/zip5_coords", clear
rename _ID id
merge m:1 id using "$out/zip5_database_clean", assert(1 3) keep(3) nogen

** Test that new _polygonid has one-to-one mapping with old ID
*egen testid=sd(id), by(_polygonid)
*assert testid==0

** Generate state variable for AK and HI
gen statefips=2 if inrange(zip3,995,999)
replace statefips=15 if inlist(zip3,967,968)

** Reshape U.S.
do "$code/reshape_us.do"

** Save coords dataset
rename _polygonid _ID
keep _ID _X _Y
order _ID _X _Y
sort _ID, stable
save12 "$out/zip5_coords_clean", replace

*** Step 4: Make _polygonid the only ID variable in database
use "$out/zip5_database_clean", clear
keep _polygonid zip5 zip3
order _polygonid zip5 zip3
save12 "$out/zip5_database_clean", replace 

*** Step 5: Clean up extra files
erase "$out/zip5_database.dta"
erase "$out/zip5_coords.dta"

