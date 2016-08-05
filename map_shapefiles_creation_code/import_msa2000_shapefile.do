* import_msa2000_shapefile.do: imports shapefile into Stata format, cleaning the output files

*** Version history:
* 2016-08-05, Michael Stepner
* 2015-11-25, minor updates by Michael Stepner
* 2015-11-11, Arash Farahani



/*******************************

** INFORMATION ABOUT MSA-CMSA Files **

The shape files were taken from NHGIS.
- nhgis0003_shapefile_tl2000_us_state_2000.zip
- nhgis0001_shapefile_tl2000_us_msa_cmsa_2000.zip

MSA-CMSA and State files were first merged using ARCGIS to create a shapefile of MSA's that includes state borders.
The coordinate system of the resulting file was projected to WGS1984 coordinate system.

** INPUT FILES ** 
- US_msacmsa_2000.shp (Provided by NHGIS)
- US_state_2000.shp (Provided by NHGIS)
- US_msa_state_2000_merge.shp (ArcGIS output)
- reshape_us.do

** OUTPUT FILES **
- msa2000_database_clean.dta
- msa2000_coords_clean.dta

*******************************/

global root "/Users/michael/Documents/git_repos/maptile_geo_templates"
global raw "$root/raw_data/msa"
global out "$root/map_shapefiles"
global code "$root/map_shapefiles_creation_code"


*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/US_msa_state_2000_merge.zip", replace

shp2dta using "$raw/US_msa_state_2000_Merge", database("$out/msa2000_database") ///
	coordinates("$out/msa2000_coords") genid(id) replace


*** Step 2: Clean database
cd "$code"

use "$out/msa2000_database", clear
rename (MSACMSA NHGISST) (msa state)
destring msa state, replace
keep msa state id
save12 "$out/msa2000_database_clean", replace

*** Step 3: Clean coordinates
use "$out/msa2000_coords", clear
gen id=_ID
merge m:1 id using "$out/msa2000_database_clean", assert(1 3) keep(3) nogen

** Generate state variable for AK and HI
gen statefips=2 if inrange(msa,380,380) | state==20
replace statefips=15 if inlist(msa,3320,3320) | state==150

** Reshape U.S.
do "$code/reshape_us.do"

** Save coords dataset
keep _ID _X _Y
sort _ID, stable
save12 "$out/msa2000_coords_clean", replace

*** Step 4: Clean up extra files
erase "$out/msa2000_database.dta"
erase "$out/msa2000_coords.dta"
