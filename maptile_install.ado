*! version 0.70dev  XXjan2014  Michael Stepner, stepner@mit.edu

/*** Unlicence (abridged):
This is free and unencumbered software released into the public domain.
It is provided "AS IS", without warranty of any kind.

For the full legal text of the Unlicense, see <http://unlicense.org>
*/

* Why did I include a formal license? Jeff Atwood gives good reasons:
*  http://www.codinghorror.com/blog/2007/04/pick-a-license-any-license.html


program define maptile_install
	version 11
	
	syntax using/, [replace]
	
	* Ensure that the directories exist
	cap mkdir "`c(sysdir_personal)'"
	cap mkdir "`c(sysdir_personal)'maptile_geographies"
	
	* Change to the target directory
	local cwd `c(pwd)'
	cd `"`c(sysdir_personal)'maptile_geographies"'
	
	* Install the specified geography
	qui copy `"`using'"' temp.zip, replace
	unzipfile temp.zip, `replace'
	erase temp.zip

	* Change back to original directory
	qui cd `"`cwd'"'
	
end
