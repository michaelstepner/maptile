* import_state_shapefile.do: imports 2010 State shapefile into Stata format, cleaning the output files

*** Version history:
* 2014-01-30, Michael Stepner
* 2013-07-06, Michael Stepner


/*******************************

** INPUT FILES ** 
- gz_2010_us_040_00_20m.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html

- state_fips_abbrev.dta
	Contains a mapping between State FIPS codes and State standardized 2-letter abbreviations
** OUTPUT FILES **- state_database_clean.dta- state_coords_clean.dta*******************************/
global root "/Users/michael/Documents/git_repos/maptile"
global raw "$root/raw_data"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/gz_2010_us_040_00_20m.zip", replace

shp2dta using "$raw/gz_2010_us_040_00_20m", database("$root/map_shapefiles/state_database") ///
	coordinates("$root/map_shapefiles/state_coords") genid(id) replace


*** Step 2: Clean database
use "$root/map_shapefiles/state_database", clear
rename STATE statefips
rename NAME statename
keep statefips statename id
destring statefips, replace
merge 1:1 statefips using "$raw/state_fips_abbrev.dta", assert(2 3) keep(3) nogen
drop if statefips>56
save "$root/map_shapefiles/state_database_clean", replace

*** Step 3: Clean coordinates
use "$root/map_shapefiles/state_coords", clear
gen id=_ID
merge m:1 id using "$root/map_shapefiles/state_database_clean", assert(1 3) keep(3) nogen

** Drop Alaska islands off to the far right
*sum _X if statefips==2
*sum _X if statefips==2 & inrange(_X,-50,50)
drop if statefips==2 & _X>0 & !missing(_X)

** Drop leftmost islands of Hawaii
*sum _X if statefips==15
*sum _X if statefips==15 & inrange(_X,-160.45,-160.4)
drop if statefips==15 & _X<-160.4 & !missing(_X)

** Rescale U.S. to a better projection: by default, streched too wide
*sum _Y if !inlist(statefips,2,15)
replace _Y=_Y*1.355 if !inlist(statefips,2,15)


keep _ID _X _Y
sort _ID, stable
save "$root/map_shapefiles/state_coords_clean", replace

*** Step 4: Clean up extra files
erase "$root/map_shapefiles/state_database.dta"
erase "$root/map_shapefiles/state_coords.dta"
