*! 31jan2014, Michael Stepner, stepner@mit.edu
* reshape_us.do: takes a coordinates file from the U.S. Census Bureau and rescales CONUS, AK, HI; shifts AK HI below CONUS.



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
