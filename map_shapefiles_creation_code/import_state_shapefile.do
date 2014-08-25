* import_state_shapefile.do: imports 2010 State shapefile into Stata format, cleaning the output files

*** Version history:
* 2014-08-25, Michael Stepner
* 2014-01-31, Michael Stepner
* 2013-07-06, Michael Stepner


/*******************************

** INPUT FILES ** 
- reshape_us.do
- gz_2010_us_040_00_20m.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
- state_fips_abbrev.dta
	Contains a mapping between State FIPS codes and State standardized 2-letter abbreviations
** OUTPUT FILES **- state_database_clean.dta- state_coords_clean.dta*******************************/
global root "/Users/michael/Documents/git_repos/maptile"
global raw "$root/raw_data"
global out "$root/map_shapefiles"
global code "$root/map_shapefiles_creation_code"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/gz_2010_us_040_00_20m.zip", replace

shp2dta using "$raw/gz_2010_us_040_00_20m", database("$out/state_database") ///
	coordinates("$out/state_coords") genid(_polygonid) replace


*** Step 2: Clean database
use "$out/state_database", clear
rename STATE statefips
rename NAME statename
keep statefips statename _polygonid
destring statefips, replace
merge 1:1 statefips using "$raw/state_fips_abbrev.dta", assert(2 3) keep(3) nogen
drop if statefips>56
save "$out/state_database_clean", replace

*** Step 3: Clean coordinates
use "$out/state_coords", clear
gen _polygonid=_ID
merge m:1 _polygonid using "$out/state_database_clean", assert(1 3) keep(3) nogen

** Reshape U.S.
do "$code/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save "$out/state_coords_clean", replace

*** Step 4: Clean up extra files
erase "$out/state_database.dta"
erase "$out/state_coords.dta"
