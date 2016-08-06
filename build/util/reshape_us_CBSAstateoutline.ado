program define reshape_us_CBSAstateoutline

	syntax using/, save_coords(string) save_shifts(string)
	
	use `"`using'"', clear

	gen sname = ""
	replace sname = "AK" if _Y >= 2300000 & !missing(_Y) // Label Alaska from borders
	replace sname = "HI" if _X <= -4000000 & _Y <= 2300000 & !missing(_X) // Label Hawaii from borders
	tab _Y if _X <= -4000000 & _Y <= 2300000 & !missing(_X) // Gives Y <= 400000 cutoff
	drop if sname == "HI" & _Y >= 500000 & !missing(_Y) // Drop top of Hawaii
	drop if _X >= 2750000 & !missing(_X) // Drop Puerto Rico from Borders 
	
	summ _X if sname == "" // Find Left of US
	global left_US = `r(min)'
	summ _Y if sname == "" // Find Bottom of US
	global bot_US = `r(min)'
	summ _X if sname == "AK" // Find Left Right of AK
	global left_AK = `r(min)'
	global right_AK = `r(max)'
	summ _Y if sname == "AK" // Find Top Bot of AK
	global bot_AK = `r(min)'
	global top_AK = `r(max)'
	summ _X if sname == "HI" // Find Left Right of HI
	global left_HI = `r(min)'
	global right_HI = `r(max)'
	summ _Y if sname == "HI" // Find Top Bot of HI
	global bot_HI = `r(min)'
	global top_HI = `r(max)'
	
	// Get Shifts for Alaska
	global shiftdown_AK = $bot_AK - $bot_US
	global shiftright_AK = $left_AK - $left_US
	
	// Shift Alaska 
	replace _X = _X - $shiftright_AK if sname == "AK" 
	replace _Y = _Y - $shiftdown_AK if sname == "AK" 
	
	// Rescale Alaska
	replace _X = (_X - $left_US)/3.5 + $left_US if sname == "AK" 
	replace _Y = (_Y - $bot_US)/3.5 + $bot_US if sname == "AK" 
	
	// Get new right for Alaska 
	summ _Y if sname == "AK"
	global newright_AK = `r(max)'
	
	// Get shifts for Hawaii
	global shiftdown_HI = $bot_HI - $bot_US
	global shiftright_HI = $left_HI - $newright_AK + 500000 // Unclear why this 500000 is needed
	
	// Shift Hawaii 
	replace _X = _X - $shiftright_HI if sname == "HI" 
	replace _Y = _Y - $shiftdown_HI if sname == "HI"
	
	
	save12 `"`save_coords'"', replace
	
	clear 
	set obs 2
	foreach state in "HI" "AK" {
		gen `state'_Moves = .
		replace `state'_Moves = ${shiftright_`state'} if _n == 1
		replace `state'_Moves = ${shiftdown_`state'} if _n == 2
	}
	gen US_data = .
	replace US_data = $left_US if _n == 1
	replace US_data = $bot_US if _n == 2
	gen newright_AK = $newright_AK if _n == 1
	
	save12 `"`save_shifts'"', replace
	
end
