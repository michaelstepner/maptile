* import_county1990_shapefile.do: imports 1990 County shapefile into Stata format, cleaning the output files

*** Version history:
* 2016-08-05, Michael Stepner
* 2014-01-31, Michael Stepner
* 2013-07-05, Michael Stepner


/*******************************

** INPUT FILES ** 
- co99_d90_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html
- reshape_us.do

** OUTPUT FILES **
- county1990_database_clean.dta
- county1990_coords_clean.dta

*******************************/

global root "/Users/michael/Documents/git_repos/maptile_geo_templates"
global raw "$root/raw_data"
global out "$root/map_shapefiles"
global code "$root/map_shapefiles_creation_code"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/co99_d90_shp.zip", replace

shp2dta using "$raw/co99_d90", database("$out/county1990_database") ///
	coordinates("$out/county1990_coords") genid(id) replace


*** Step 2: Clean database
cd "$root/map_shapefiles_creation_code"

use "$out/county1990_database", clear
rename ST statefips
rename CO county
destring statefips county, replace
replace county=county+statefips*1000
keep statefips county id
drop if statefips>56
save12 "$out/county1990_database_clean", replace

*** Step 3: Clean coordinates
use "$out/county1990_coords", clear
gen id=_ID
merge m:1 id using "$out/county1990_database_clean", assert(3) nogen

** Reshape U.S.
do "$code/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/county1990_coords_clean", replace

*** Step 4: Clean up extra files
erase "$out/county1990_database.dta"
erase "$out/county1990_coords.dta"
