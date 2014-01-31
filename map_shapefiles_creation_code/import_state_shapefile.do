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

** Rescale Alaska to a better projection: by default, streched FAR too wide
replace _Y=_Y*2.39 if statefips==2

** Rescale Hawaii to a better projection: by default, streched a touch too wide
replace _Y=_Y*1.056 if statefips==15


** Move Alaska to convenient location below continental U.S.

* Scale AK down
replace _X=_X/(16/3) if statefips==2
replace _Y=_Y/(16/3) if statefips==2

* Move AK to left hand side of CONUS
sum _X if !inlist(statefips,2,15) /* leftmost is -124.7332 */
local xshift=r(min)
sum _X if statefips==2
local xshift=`xshift'-r(min)

replace _X=_X+`xshift'+1 if statefips==2

* Move AK south of CONUS
sum _Y if !inlist(statefips,2,15) /* lowest is 33.25807 */
local yshift=r(min)
sum _Y if statefips==2
local yshift=`yshift'-r(min)
replace _Y=_Y+`yshift'-1 if statefips==2


** Move Hawaii to convenient location below continental U.S.

* Scale HI up
replace _X=_X*1.2 if statefips==15
replace _Y=_Y*1.2 if statefips==15

* Move HI right of AK
sum _X if statefips==2
local xshift=r(max)
sum _X if statefips==15
local xshift=`xshift'-r(min)

replace _X=_X+`xshift'+2.5 if statefips==15

* Move HI south of CONUS
sum _Y if !inlist(statefips,2,15) /* lowest is 33.25807 */
local yshift=r(min)
sum _Y if statefips==15
local yshift=`yshift'-r(min)

replace _Y=_Y+`yshift'+1 if statefips==15


** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save "$root/map_shapefiles/state_coords_clean", replace

*** Step 4: Clean up extra files
erase "$root/map_shapefiles/state_database.dta"
erase "$root/map_shapefiles/state_coords.dta"
