*! 5oct2016 Paul Goldsmith-Pinkham (paulgp@gmail.com) and Michael Stepner (stepner@mit.edu)

* manually creates a hexagonal map of U.S. states

/*******************************

The layout of the state hexagons used in this template was designed by
Brian Boyer, Danny DeBelius and Alyson Hurt at NPR, and described in an
NPR Visuals Team blog post:

	http://blog.apps.npr.org/2015/05/11/hex-tile-maps.html

The layout of the state hexagon map is also described in the
NPR dailygraphics code base (http://github.com/nprapps/dailygraphics),
Copyright (c) 2014 NPR. It is used here with permission under the terms of
the MIT open source license:

	http://github.com/nprapps/dailygraphics/blob/7d07a7a46ef0472e809fe0eba19b8cffde267c36/LICENSE

*******************************/


/***** Initialize *****/

* Check if run using -project-
return clear
capture project, doinfo
if (_rc==0 & !mi(r(pname))) global root `r(pdir)'  // run using -project-
else {  // running directly

	global root "/Users/michael/Documents/git_repos/maptile_geo_templates/build"

	* Disable project (since running do-files directly)
	cap program drop project
	program define project
		di "Project is disabled, skipping project command. (To re-enable, run -{stata program drop project}-)"
	end
	
}

* Specify subdirectories
global out "$root/geo_templates/statehex"
global test "$root/tests/statehex"

* Add utility programs to path
adopath ++ "$root/util"

* Tell -project- that we use -save12-
project, original("$root/util/save12.ado")


/***** Construct hexagons *****/

project, original("$root/geo_templates/state/state_coords_clean.dta")
use "$root/geo_templates/state/state_coords_clean.dta",clear

by _ID: keep if _n < 8

/*** Start with Texas ***/
/*** ID 52 ***/

gen base_X = .
gen base_Y = .
by _ID: replace base_X = 0 if _n == 2
by _ID: replace base_Y = 0 if _n == 2
by _ID: replace base_X = -0.5 if _n == 3
by _ID: replace base_Y = sqrt(3)/6 if _n == 3
by _ID: replace base_X = -0.5 if _n == 4
by _ID: replace base_Y = sqrt(3)/2 if _n == 4
by _ID: replace base_X = 0 if _n == 5
by _ID: replace base_Y = 2*sqrt(3)/3 if _n == 5
by _ID: replace base_X = 0.5 if _n == 6
by _ID: replace base_Y = sqrt(3)/2 if _n == 6
by _ID: replace base_X = 0.5 if _n == 7
by _ID: replace base_Y = sqrt(3)/6 if _n == 7


/*** TX First **/
by _ID: replace _X = base_X if _n == 2 & _ID == 52
by _ID: replace _Y = base_Y if _n == 2 & _ID == 52
by _ID: replace _X = base_X if _n == 3 & _ID == 52
by _ID: replace _Y = base_Y if _n == 3 & _ID == 52
by _ID: replace _X = base_X if _n == 4 & _ID == 52
by _ID: replace _Y = base_Y if _n == 4 & _ID == 52
by _ID: replace _X = base_X if _n == 5 & _ID == 52
by _ID: replace _Y = base_Y if _n == 5 & _ID == 52
by _ID: replace _X = base_X if _n == 6 & _ID == 52
by _ID: replace _Y = base_Y if _n == 6 & _ID == 52
by _ID: replace _X = base_X if _n == 7 & _ID == 52
by _ID: replace _Y = base_Y if _n == 7 & _ID == 52

/*** Florida **/
local X_trans = 3
local Y_trans = 0
local id = 28

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Oklahoma **/
    local X_trans = -0.5
local Y_trans = sqrt(3)/2
local id = 17
by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Arizona **/
    local X_trans = -1.5
local Y_trans = sqrt(3)/2
local id = 1

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Lousiana **/
    local X_trans = 0.5
local Y_trans = sqrt(3)/2
local id = 11

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Mississippi **/
    local X_trans = 1.5
local Y_trans = sqrt(3)/2
local id = 13

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Alabama **/
    local X_trans = 2.5
local Y_trans = sqrt(3)/2
local id = 26

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Georgia **/
    local X_trans = 3.5
local Y_trans = sqrt(3)/2
local id = 7

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** California **/
    local X_trans = -3
local Y_trans = 2*sqrt(3)/2
local id = 3

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Utah **/
local X_trans = -2
local Y_trans = 2*sqrt(3)/2
local id = 37

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** New Mexico **/
local X_trans = -1
local Y_trans = 2*sqrt(3)/2
local id = 15

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Kansas **/
local X_trans = 0
local Y_trans = 2*sqrt(3)/2
local id = 30

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Arkansas **/
local X_trans = 1
local Y_trans = 2*sqrt(3)/2
local id = 2

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Tennessee **/
local X_trans = 2
local Y_trans = 2*sqrt(3)/2
local id = 19

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** North Carolina **/
local X_trans = 3
local Y_trans = 2*sqrt(3)/2
local id = 33

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** South Carolina **/
local X_trans = 4
local Y_trans = 2*sqrt(3)/2
local id = 34

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** D.C. **/
local X_trans = 5
local Y_trans = 2*sqrt(3)/2
local id = 6

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Oregon **/
local X_trans = -3.5
local Y_trans = 3*sqrt(3)/2
local id = 49

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Nevada **/
local X_trans = -2.5
local Y_trans = 3*sqrt(3)/2
local id = 45

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Colorado **/
local X_trans = -1.5
local Y_trans = 3*sqrt(3)/2
local id = 4

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Nebraska **/
local X_trans = -0.5
local Y_trans = 3*sqrt(3)/2
local id = 44

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Missouri **/
local X_trans = 0.5
local Y_trans = 3*sqrt(3)/2
local id = 43

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Kentucky **/
local X_trans = 1.5
local Y_trans = 3*sqrt(3)/2
local id = 39

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** West Virgina **/
local X_trans = 2.5
local Y_trans = 3*sqrt(3)/2
local id = 23

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Virgina **/
local X_trans = 3.5
local Y_trans = 3*sqrt(3)/2
local id = 20

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Maryland **/
local X_trans = 4.5
local Y_trans = 3*sqrt(3)/2
local id = 31

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Delaware **/
local X_trans = 5.5
local Y_trans = 3*sqrt(3)/2
local id = 22

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Idaho **/
local X_trans = -3
local Y_trans = 4*sqrt(3)/2
local id = 29

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Wyoming **/
local X_trans = -2
local Y_trans = 4*sqrt(3)/2
local id = 25

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** South Dakota **/
local X_trans = -1
local Y_trans = 4*sqrt(3)/2
local id = 51

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Iowa **/
local X_trans = 0
local Y_trans = 4*sqrt(3)/2
local id = 38

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Illinois **/
local X_trans = 1
local Y_trans = 4*sqrt(3)/2
local id = 9

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Indiana **/
local X_trans = 2
local Y_trans = 4*sqrt(3)/2
local id = 10

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'



/*** Ohio **/
local X_trans = 3
local Y_trans = 4*sqrt(3)/2
local id = 48

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Pennsylvania **/
local X_trans = 4
local Y_trans = 4*sqrt(3)/2
local id = 18

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** New Jersey **/
local X_trans = 5
local Y_trans = 4*sqrt(3)/2
local id = 32

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Connecticut **/
local X_trans = 6
local Y_trans = 4*sqrt(3)/2
local id = 5

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Washington **/
local X_trans = -3.5
local Y_trans = 5*sqrt(3)/2
local id = 35

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Montana **/
local X_trans = -2.5
local Y_trans = 5*sqrt(3)/2
local id = 14

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** North Dakota **/
local X_trans = -1.5
local Y_trans = 5*sqrt(3)/2
local id = 16

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Minnesota **/
local X_trans = -0.5
local Y_trans = 5*sqrt(3)/2
local id = 12

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Wisconsin **/
local X_trans = 0.5
local Y_trans = 5*sqrt(3)/2
local id = 24

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Michigan **/
local X_trans = 2.5
local Y_trans = 5*sqrt(3)/2
local id = 42

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** New York **/
local X_trans = 4.5
local Y_trans = 5*sqrt(3)/2
local id = 47

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Massachussetts **/
local X_trans = 5.5
local Y_trans = 5*sqrt(3)/2
local id = 41

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Rhode Island **/
local X_trans = 6.5
local Y_trans = 5*sqrt(3)/2
local id = 50

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Vermont **/
local X_trans = 5.0
local Y_trans = 6*sqrt(3)/2
local id = 36

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** New Hampshire **/
local X_trans = 6.0
local Y_trans = 6*sqrt(3)/2
local id = 46

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Maine  **/
local X_trans = 6.5
local Y_trans = 7*sqrt(3)/2
local id = 40

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

/*** Hawaii  **/
local X_trans = -5.0
local Y_trans = 0
local id = 8

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'


/*** Alaska  **/
local X_trans = -4.5
local Y_trans = 7*sqrt(3)/2
local id = 27

by _ID: replace _X = base_X+`X_trans' if _n == 2 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 2 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 3 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 3 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 4 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 4 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 5 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 5 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 6 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 6 & _ID == `id'
by _ID: replace _X = base_X+`X_trans' if _n == 7 & _ID == `id'
by _ID: replace _Y = base_Y+`Y_trans' if _n == 7 & _ID == `id'

save12 "$out/statehex_coords.dta", replace
project, creates("$out/statehex_coords.dta")


/***** Add hex centroids to database for labeling *****/

project, original("$root/geo_templates/state/state_database_clean.dta")
use "$root/geo_templates/state/state_database_clean.dta", clear

gen __label_X = 0 if state == "TX"
gen __label_Y = sqrt(3)/3 if state == "TX"

/*** Florida **/
local X_trans = 3
local Y_trans = 0
local id = 28
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Oklahoma **/
    local X_trans = -0.5
local Y_trans = sqrt(3)/2
local id = 17
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Arizona **/
    local X_trans = -1.5
local Y_trans = sqrt(3)/2
local id = 1
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Lousiana **/
    local X_trans = 0.5
local Y_trans = sqrt(3)/2
local id = 11
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Mississippi **/
    local X_trans = 1.5
local Y_trans = sqrt(3)/2
local id = 13
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Alabama **/
    local X_trans = 2.5
local Y_trans = sqrt(3)/2
local id = 26
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Georgia **/
    local X_trans = 3.5
local Y_trans = sqrt(3)/2
local id = 7
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** California **/
    local X_trans = -3
local Y_trans = 2*sqrt(3)/2
local id = 3
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Utah **/
local X_trans = -2
local Y_trans = 2*sqrt(3)/2
local id = 37
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** New Mexico **/
local X_trans = -1
local Y_trans = 2*sqrt(3)/2
local id = 15
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Kansas **/
local X_trans = 0
local Y_trans = 2*sqrt(3)/2
local id = 30
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Arkansas **/
local X_trans = 1
local Y_trans = 2*sqrt(3)/2
local id = 2
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Tennessee **/
local X_trans = 2
local Y_trans = 2*sqrt(3)/2
local id = 19
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** North Carolina **/
local X_trans = 3
local Y_trans = 2*sqrt(3)/2
local id = 33
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** South Carolina **/
local X_trans = 4
local Y_trans = 2*sqrt(3)/2
local id = 34
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** D.C. **/
local X_trans = 5
local Y_trans = 2*sqrt(3)/2
local id = 6
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Oregon **/
local X_trans = -3.5
local Y_trans = 3*sqrt(3)/2
local id = 49
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Nevada **/
local X_trans = -2.5
local Y_trans = 3*sqrt(3)/2
local id = 45
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Colorado **/
local X_trans = -1.5
local Y_trans = 3*sqrt(3)/2
local id = 4
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Nebraska **/
local X_trans = -0.5
local Y_trans = 3*sqrt(3)/2
local id = 44
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Missouri **/
local X_trans = 0.5
local Y_trans = 3*sqrt(3)/2
local id = 43
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Kentucky **/
local X_trans = 1.5
local Y_trans = 3*sqrt(3)/2
local id = 39
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** West Virgina **/
local X_trans = 2.5
local Y_trans = 3*sqrt(3)/2
local id = 23
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Virgina **/
local X_trans = 3.5
local Y_trans = 3*sqrt(3)/2
local id = 20
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Maryland **/
local X_trans = 4.5
local Y_trans = 3*sqrt(3)/2
local id = 31
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Delaware **/
local X_trans = 5.5
local Y_trans = 3*sqrt(3)/2
local id = 22
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Idaho **/
local X_trans = -3
local Y_trans = 4*sqrt(3)/2
local id = 29
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Wyoming **/
local X_trans = -2
local Y_trans = 4*sqrt(3)/2
local id = 25
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** South Dakota **/
local X_trans = -1
local Y_trans = 4*sqrt(3)/2
local id = 51
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Iowa **/
local X_trans = 0
local Y_trans = 4*sqrt(3)/2
local id = 38
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Illinois **/
local X_trans = 1
local Y_trans = 4*sqrt(3)/2
local id = 9
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Indiana **/
local X_trans = 2
local Y_trans = 4*sqrt(3)/2
local id = 10
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'



/*** Ohio **/
local X_trans = 3
local Y_trans = 4*sqrt(3)/2
local id = 48
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Pennsylvania **/
local X_trans = 4
local Y_trans = 4*sqrt(3)/2
local id = 18
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** New Jersey **/
local X_trans = 5
local Y_trans = 4*sqrt(3)/2
local id = 32
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** Connecticut **/
local X_trans = 6
local Y_trans = 4*sqrt(3)/2
local id = 5
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Washington **/
local X_trans = -3.5
local Y_trans = 5*sqrt(3)/2
local id = 35
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Montana **/
local X_trans = -2.5
local Y_trans = 5*sqrt(3)/2
local id = 14
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'


/*** North Dakota **/
local X_trans = -1.5
local Y_trans = 5*sqrt(3)/2
local id = 16
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Minnesota **/
local X_trans = -0.5
local Y_trans = 5*sqrt(3)/2
local id = 12
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Wisconsin **/
local X_trans = 0.5
local Y_trans = 5*sqrt(3)/2
local id = 24
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Michigan **/
local X_trans = 2.5
local Y_trans = 5*sqrt(3)/2
local id = 42
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** New York **/
local X_trans = 4.5
local Y_trans = 5*sqrt(3)/2
local id = 47
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Massachussetts **/
local X_trans = 5.5
local Y_trans = 5*sqrt(3)/2
local id = 41
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Rhode Island **/
local X_trans = 6.5
local Y_trans = 5*sqrt(3)/2
local id = 50
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Vermont **/
local X_trans = 5.0
local Y_trans = 6*sqrt(3)/2
local id = 36
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** New Hampshire **/
local X_trans = 6.0
local Y_trans = 6*sqrt(3)/2
local id = 46
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Maine  **/
local X_trans = 6.5
local Y_trans = 7*sqrt(3)/2
local id = 40
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Hawaii  **/
local X_trans = -5.0
local Y_trans = 0
local id = 8
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

/*** Alaska  **/
local X_trans = -4.5
local Y_trans = 7*sqrt(3)/2
local id = 27
replace __label_X = 0 +`X_trans' if _polygonid == `id'
replace __label_Y = sqrt(3)/3 + `Y_trans' if _polygonid == `id'

save12 "$out/statehex_database.dta", replace
project, creates("$out/statehex_database.dta")


/***** Reference other files using -project- *****/
project, relies_on("$root/readme.txt")
project, relies_on("$root/UNLICENSE.txt")
project, relies_on("$out/statehex_maptile.ado")
project, relies_on("$out/statehex_maptile.smcl")


/***** Test geo-specific options *****/
use "$out/statehex_database.dta", clear
rename _polygonid test

* no options
maptile test, geo(statehex) geofolder($out) ///
	savegraph("$test/statehex_noopt.png") resolution(0.5) replace
project, creates("$test/statehex_noopt.png") preserve

* test geoid()
maptile test, geo(statehex) geofolder($out) ///
	geoid(state) ///
	savegraph("$test/statehex_geoid-state.png") resolution(0.5) replace
project, creates("$test/statehex_geoid-state.png") preserve

maptile test, geo(statehex) geofolder($out) ///
	geoid(statefips) ///
	savegraph("$test/statehex_geoid-statefips.png") resolution(0.5) replace
project, creates("$test/statehex_geoid-statefips.png") preserve

maptile test, geo(statehex) geofolder($out) ///
	geoid(statename) ///
	savegraph("$test/statehex_geoid-statename.png") resolution(0.5) replace
project, creates("$test/statehex_geoid-statename.png") preserve

gen teststate=state
rcof "maptile test, geo(statehex) geofolder($out) geoid(teststate)" == 198

* test labelhex()
maptile test, geo(statehex) geofolder($out) ///
	labelhex(statefips) ///
	savegraph("$test/statehex_label-statefips.png") resolution(0.5) replace
project, creates("$test/statehex_label-statefips.png") preserve

gen firstletter=substr(statename,1,1)

maptile test, geo(statehex) geofolder($out) ///
	labelhex(firstletter) ///
	savegraph("$test/statehex_label-firstletter.png") resolution(0.5) replace
project, creates("$test/statehex_label-firstletter.png") preserve

* test combinaton of geoid() and labelhex()
maptile test, geo(statehex) geofolder($out) ///
	geoid(statefips) labelhex(firstletter) ///
	savegraph("$test/statehex_geoid-statefips_label-firstletter.png") resolution(0.5) replace
project, creates("$test/statehex_geoid-statefips_label-firstletter.png") preserve

* test nolabel
maptile test, geo(statehex) geofolder($out) ///
	nolabel ///
	savegraph("$test/statehex_nolabel.png") resolution(0.5) replace
project, creates("$test/statehex_nolabel.png") preserve

* test that combination of nolabel and labelhex() gives error
rcof "maptile test, geo(statehex) geofolder($out) nolabel labelhex(state)" == 198

* test without DC
drop if state=="DC"
maptile test, geo(statehex) geofolder($out) ///
	savegraph("$test/statehex_withoutDC.png") resolution(0.5) replace
project, creates("$test/statehex_withoutDC.png") preserve
