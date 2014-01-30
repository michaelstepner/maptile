* import_zip5_shapefile.do: imports 2000 Census 5-digit ZCTA shapefile into Stata format, cleaning the output files

*** Version history:
* 2013-07-06, Michael Stepner


/*******************************

** INFORMATION ABOUT ZCTAs (ZIP Code Tabulation Areas) **
http://www.census.gov/geo/reference/zctas.html
http://www.census.gov/geo/reference/zctafaq.html

** INPUT FILES ** 
- zt99_d00_shp.zip
	Provided by U.S. Census Bureau at http://www.census.gov/geo/maps-data/data/prev_cartbndry_names.html
	  Under "5-Digit ZIP Code Tabulation Areas"
	  ** OUTPUT FILES **- zip5_database_clean.dta- zip5_coords_clean.dta*******************************/

global dropboxroot "/Users/michael/Dropbox"
*global dropboxroot "C:/Users/RA 2/Dropbox"global root "$dropboxroot/ra_working_folder/shapefile_generation"

global raw "$root/raw_data"

*** Step 1: Unzip & convert shape file to dta
cd "$raw"
unzipfile "$raw/zt99_d00_shp.zip", replace

shp2dta using "$raw/zt99_d00", database("$root/map_shapefiles/zip5_database") ///
	coordinates("$root/map_shapefiles/zip5_coords") genid(id) replace


*** Step 2: Clean database
use "$root/map_shapefiles/zip5_database", clear
keep ZCTA id
rename ZCTA zip5
gen zip3=substr(zip5,1,3)
destring zip3, replace
destring zip5, replace force

* Missing values of zip5:
* --> Either had 3 digits followed by XX, which indicates a large sparsely-populated land area that doesn't map to a 5-digit ZIP
* 	  Or had 3 digits followed by HH, which indicates a body of water.
* 	  Source: websites about ZCTAs, referenced above.

* Drop Puerto Rico
drop if inrange(zip3,006,009)

save "$root/map_shapefiles/zip5_database_clean", replace

*** Step 3: Clean coordinates
use "$root/map_shapefiles/zip5_coords", clear
gen long id=_ID
merge m:1 id using "$root/map_shapefiles/zip5_database_clean", assert(1 3) keep(3) nogen

* Drop Alaska islands off to the far right
drop if inrange(zip3,995,999) & _X>0 & !missing(_X)

* Drop leftmost islands of Hawaii
drop if inlist(zip3,967,968) & _X<-160.4 & !missing(_X)

keep _ID _X _Y
sort _ID, stable
save "$root/map_shapefiles/zip5_coords_clean", replace

*** Step 4: Clean up extra files
erase "$root/map_shapefiles/zip5_database.dta"
erase "$root/map_shapefiles/zip5_coords.dta"

