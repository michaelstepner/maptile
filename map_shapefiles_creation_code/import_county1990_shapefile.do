* import_county1990_shapefile.do: imports 1990 County shapefile into Stata format, cleaning the output files

*** Version history:
* 2013-07-05, Michael Stepner


/*******************************

** INPUT FILES ** 
- co99_d90_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html
** OUTPUT FILES **- county1990_database_clean.dta- county1990_coords_clean.dta*******************************/

global dropboxroot "/Users/michael/Dropbox"
global dropboxroot "C:/Users/RA 2/Dropbox"global root "$dropboxroot/ra_working_folder/shapefile_generation"

global raw "$root/raw_data"

*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/co99_d90_shp.zip", replace

shp2dta using "$raw/co99_d90", database("$root/map_shapefiles/county1990_database") ///
	coordinates("$root/map_shapefiles/county1990_coords") genid(id) replace


*** Step 2: Clean database
use "$root/map_shapefiles/county1990_database", clear
rename ST statefips
rename CO county
destring statefips county, replace
replace county=count+statefips*1000
keep statefips county id
drop if statefips>56
save "$root/map_shapefiles/county1990_database_clean", replace

*** Step 3: Clean coordinates
use "$root/map_shapefiles/county1990_coords", clear
gen id=_ID
merge m:1 id using "$root/map_shapefiles/county1990_database_clean"
drop if _merge==1
drop _merge

** Drop Alaska islands off to the far right
*sum _X if statefips==2
*sum _X if statefips==2 & inrange(_X,-50,50)
drop if statefips==2 & _X>0 & !missing(_X)

** Drop leftmost islands of Hawaii
*sum _X if statefips==15
*sum _X if statefips==15 & inrange(_X,-160.45,-160.4)
drop if statefips==15 & _X<-160.4 & !missing(_X)

keep _ID _X _Y
sort _ID, stable
save "$root/map_shapefiles/county1990_coords_clean", replace

*** Step 4: Clean up extra files
erase "$root/map_shapefiles/county1990_database.dta"
erase "$root/map_shapefiles/county1990_coords.dta"
