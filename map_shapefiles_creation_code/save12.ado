*! version 0.1.0  5aug2016  Michael Stepner, stepner@mit.edu
program define save12
	version 12
	
	syntax [anything], [nolabel replace all orphans emptyok]

	if c(stata_version)>=12 & c(stata_version)<13 {
		save `anything', `nolabel' `replace' `all' `orphans' `emptyok'
	}
	else if c(stata_version)>=13 & c(stata_version)<14 {
		saveold `anything', `nolabel' `replace' `all' `orphans' `emptyok'
	}
	else if c(stata_version)>=14 {
		saveold `anything', `nolabel' `replace' `all' `orphans' `emptyok' version(12)
	}
	else {
		di as error "Must have Stata version 12 or higher to save in Stata 12 format."
		error 499
	}

end
