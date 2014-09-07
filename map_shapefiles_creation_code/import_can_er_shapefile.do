* import_can_er_shapefile.do: imports 2011 economic region shapefile into Stata format

*** Version history:
* 2014-08-06, Michael Stepner


/*******************************

** INPUT FILES ** 
- ger_000b11a_e.zip
	"Economic Regions"
	Boundary Files, 2011 Census. Statistics Canada Catalogue no. 92-160-X.
	Downloaded from: http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-2011-eng.cfm
** OUTPUT FILES **- can_er_database.dta- can_er_coords.dta*******************************/
global root "/Users/michael/Documents/git_repos/maptile"
global raw "$root/raw_data/can_er"
global out "$root/map_shapefiles"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/ger_000b11a_e.zip", replace

shp2dta using "$raw/ger_000b11a_e", database("$out/can_er_database_temp") ///
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

save "$out/can_er_database", replace


*** Step 3: Clean coordinates
use "$out/can_er_coords_temp", clear

** Rescale to a better projection: by default, streched too wide
* (used height & width of Saskwatchewan as a guide, comparing to Google Maps projection)
replace _Y=_Y*1.709

save "$out/can_er_coords", replace


*** Step 4: Clean up extra files
erase "$out/can_er_database_temp.dta"
erase "$out/can_er_coords_temp.dta"
