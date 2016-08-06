* reshape_us.do: Rescales AK, HI; shifts AK HI southwest of US for mapping purposes.

*** Version history:
* 2016-08-05, Michael Stepner: cosmetic changes to fit maptile repository structure.
* 2015-12-15, Meru Bhanot: Changed substantially to match state border shifts.
* 2015-10-15, Meru Bhanot: Changed substantially due to different dataset.

program define reshape_us_CBSA

	syntax using/

	gen sname = ""
	replace sname = "AK" if _Y >= 2300000 & !missing(_Y) // Label Alaska from borders
	assert statefp == 2 if sname == "AK" 
	replace sname = "HI" if _X <= -4000000 & _Y <= 2300000 & !missing(_X) // Label Hawaii from borders
	//tab _Y if _X <= -4000000 & _Y <= 2300000 & !missing(_X) // Gives Y <= 400000 cutoff
	assert statefp == 15 if sname == "HI" 
	drop if sname == "HI" & _Y >= 500000 & !missing(_Y) // Drop top of Hawaii
	drop if _X >= 2750000 & !missing(_X) // Drop Puerto Rico from Borders 

	preserve
	use `"`using'"', clear
	foreach state in "HI" "AK" {
		local shiftright_`state' = `state'_Moves[1]
		local shiftdown_`state' = `state'_Moves[2]
	}
	local left_US = US_data[1]
	local bot_US = US_data[2] 
	local newright_AK = newright_AK[1]
	restore

	// Shift Alaska 
	replace _X = _X - `shiftright_AK' if sname == "AK" 
	replace _Y = _Y - `shiftdown_AK' if sname == "AK" 

	// Rescale Alaska
	replace _X = (_X - `left_US')/3.5 + `left_US' if sname == "AK" 
	replace _Y = (_Y - `bot_US')/3.5 + `bot_US' if sname == "AK" 

	// Shift Hawaii 
	replace _X = _X - `shiftright_HI' if sname == "HI" 
	replace _Y = _Y - `shiftdown_HI' if sname == "HI" 

end
