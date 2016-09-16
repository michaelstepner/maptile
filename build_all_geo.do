cap program drop build_geo
program define build_geo

	syntax name(name=geo id="geo name")

	project , setmaster("/Users/michael/Documents/git_repos/maptile_geo_templates/build/build_`geo'.do") textlog
	project build_`geo', build
	*project build_`geo', list(directory)
	project build_`geo', share(`geo', alltime) textlog
	project build_`geo', pclear
	
end

build_geo state
build_geo can_er
build_geo can_prov
build_geo cbsa2009
build_geo cbsa2013
build_geo msacmsa2000
build_geo msapmsa2000
build_geo hrr
build_geo county1990
build_geo cz
