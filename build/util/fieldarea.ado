*! fieldarea by Sergiy Radyakin
*! a6197541-8c8b-48cb-aa9c-007513e89a93
*! Compute area of an irregular shape plot based 
*! on GPS coordinates of the vertices.

program define fieldarea
  
  version 9.2
  
  mata printf(" {break}%s{break}", fieldarea_about())
  
  syntax varlist(min=2 max=2), GENerate(string) [id(string) unit(string)] 
  local vt double
  local x : word 1 of `varlist'
  local y : word 2 of `varlist'
  local noe 2000
  
    
  tempvar ymi yma yme ll
  
  quietly {
  
	  if (_N==0) error `noe'

	  if (!missing(`"`id'"')) {
	  
	    count if missing(`id')
		local mid=r(N)
		if (`mid'==_N) error `noe'
		drop if missing(`id')
		if (`mid'>0) noisily display as result "Removed `mid' observations with missing ids."
		
		count if missing(`x') | missing(`y')
		local mxy=r(N)
		drop if missing(`x') | missing(`y')
		if (`mxy'>0) noisily display as result "Removed `mxy' observations with missing latitude or longitude information."
		if (_N==0) error `noe'		
	  
		sort `id', stable
		expand 2 if `id'!=`id'[_n-1]
		sort `id', stable
		
		egen `ymi'=min(`y'), by(`id')
		egen `yma'=max(`y'), by(`id')
		by `id': generate `yme'=(`ymi'+`yma')/2 if (_n==1)
		drop `ymi' `yma'
		
		by `id' : generate `vt' `generate'=(`x'+`x'[_n+1])*(`y'-`y'[_n+1])
		collapse (sum) `generate' (min) `yme', by(`id')
		
		generate `ll'=.
		
		forval i=1/`=_N' {
		  mata fieldarea_size(`=`yme'[`i']')
		  replace `ll'=`m2latlon' in `i'
		}
	  }
	  else {
		count if missing(`x') | missing(`y')
		local mxy=r(N)
		drop if missing(`x') | missing(`y')
		if (`mxy'>0) noisily display as result "Removed `mxy' observations with missing latitude or longitude information."
		if (_N==0) error `noe'	
		
		expand 2 if (_n==1)
		
		egen `ymi'=min(`y')
		egen `yma'=max(`y')
		generate `yme'=(`ymi'+`yma')/2 if (_n==1)
		
		generate `vt' `generate'=(`x'+`x'[_n+1])*(`y'-`y'[_n+1])
		collapse (sum) `generate' (min) `yme'
		
		generate `vt' `ll'=.
		mata fieldarea_size(`=`yme'[1]')
		replace `ll'=`m2latlon' in 1
	  }

	  replace `generate'=abs(`generate'*`ll'/2)
	  label variable `generate' "Area, `unit'"
  }
  
end

*** END OF FILE ***
