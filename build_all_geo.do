foreach geo in "can_er" "cbsa2009" "cbsa2013" "msacmsa2000" "msapmsa2000" {

	project , setmaster("/Users/michael/Documents/git_repos/maptile_geo_templates/build/build_`geo'.do") textlog
	project build_`geo', build
	*project build_`geo', list(directory)
	project build_`geo', share(`geo', alltime) textlog
	project build_`geo', pclear
	
}

