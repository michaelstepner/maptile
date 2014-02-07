{smcl}
{* *! version 0.70beta2  6feb2014}{...}
{vieweralsosee "spmap" "help spmap"}{...}
{viewerjumpto "Syntax" "maptile##syntax"}{...}
{viewerjumpto "Description" "maptile##description"}{...}
{viewerjumpto "Installing geographies" "maptile##installgeo"}{...}
{viewerjumpto "Using geographies" "maptile##usegeo"}{...}
{viewerjumpto "Making new geographies" "maptile##makegeo"}{...}
{viewerjumpto "Options" "maptile##options"}{...}
{viewerjumpto "Examples" "maptile##examples"}{...}
{viewerjumpto "Saved results" "maptile##saved_results"}{...}
{viewerjumpto "Author" "maptile##author"}{...}
{viewerjumpto "Acknowledgements" "maptile##acknowledgements"}{...}
{title:Title}

{pstd}
{hi:maptile} {hline 2} Categorical maps


{marker syntax}{title:Syntax}

{pstd} Map a variable

{p 8 15 2}
{cmd:maptile}
{varname} {ifin}{cmd:,}
 {cmdab:geo:graphy(}{it:{help maptile##usegeo:geoname}}{cmd:)} [{it:options}]


{pstd} Helper programs:
{bf:{help maptile##cmd_install:maptile_install}},
{bf:{help maptile##cmd_geolist:maptile_geolist}},
{bf:{help maptile##cmd_geohelp:maptile_geohelp}}


{synoptset 35 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{cmdab:geo:graphy(}{it:{help maptile##usegeo:geoname}}{cmd:)}}geographic template to map{p_end}
{synopt :{it:{help maptile##geo_options:geo_options}}}options specific to the geographic template being used{p_end}

{syntab :Bins}
{synopt :{opt n:quantiles(#)}}number of quantiles (color bins); default is {bf:6}{p_end}
{synopt :{opth cut:points(varname)}}use quantiles of {it:varname} as cutpoints{p_end}
{synopt :{opth cutv:alues(numlist)}}use values of {it:numlist} as cutpoints{p_end}

{syntab :Colors}
{synopt :{opt rev:color}}reverse color order{p_end}
{synopt :{opt prop:color}}space colors proportionally to the data{p_end}
{synopt :{opt shrinkc:olorscale(#)}}shrink color spectrum to fraction of full size; default is {bf:1}{p_end}
{synopt :{cmdab:rangec:olor(}{it:{help colorstyle} {help colorstyle}}{cmd:)}}manually specify color spectum boundaries{p_end}
{synopt :{cmdab:fc:olor(}{it:{help spmap##color:spmap_colorlist}}{cmd:)}}manually specify color scheme, instead of using a color spectrum{p_end}
{synopt :{opth ndf:color(colorstyle)}}color for areas with missing data{p_end}

{syntab :Legend}
{synopt :{opt legd:ecimals(#)}}number of decimals to display in legend{p_end}
{synopt :{cmdab:legf:ormat(}{it:{help format:%fmt}}{cmd:)}}numerical format to display in legend{p_end}

{syntab :Output}
{synopt :{opt savegraph(filename)}}save map to file; format automatically detected from extension [ex: .gph .jpg .png]{p_end}
{synopt :{opt replace}}overwrite the file if it already exists{p_end}
{synopt :{opt res:olution(#)}}scale the saved map image by a proportion; default is {bf:1}{p_end}

{syntab :Advanced}
{synopt :{cmdab:mapif(}{it:condition}{cmd:)}}restrict the map to a subset of areas{p_end}
{synopt :{cmdab:spopt(}{it:{help spmap:spmap_opts} {help twoway_options:twoway_opts}}{cmd:)}}pass spmap options or twoway_options directly to graph command{p_end}
{synopt :{opt geofolder(folder_name)}}folder containing maptile geographies; default is {bf:{help sysdir:PERSONAL}}/maptile_geographies{p_end}
{synopt :{opt hasdatabase}}dataset already contains the shapefile {it:{help spmap##basemap2:idvar}}; maptile does not need to merge it in{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:maptile} makes it easy to map a variable in Stata.  It generates choropleth maps, where each area is shaded according to the value of the variable being plotted.
By default, {cmd:maptile} divides the geographic units into equal-sized bins (corresponding to quantiles of the plotted variable), then colors the bins in increasing intensity.

{pstd}
To generate any particular map, {cmd:maptile} uses a 'geography', which is a template for that map.
These need to be {help maptile##installgeo:downloaded and installed}. If no geography currently exists for the region you want to map, you can {help maptile##makegeo:make a new one}.

{pstd}
{cmd:maptile} requires {cmd:spmap} to be installed, and is largely a convenient interface for using {cmd:spmap}.
As its help file states, "{cmd:spmap} gives the user full control over the formatting of almost every map element, thus allowing the production of highly customized maps".
When using {cmd:maptile}, most of these customizations are stored away in the geography template.
As a result, the syntax for making highly customized maps using {cmd:maptile} can be very simple.
Additionally, the geography templates can be easily shared and used by others.


{marker installgeo}{...}
{title:Installing geographies}

{pstd}
{cmd:maptile} geography templates are distributed as .ZIP files.  Many are available {browse "http://michaelstepner.com/maptile/geographies":from maptile's website}.

{marker cmd_install}{...}
{pstd}
1) To install a new geography template automatically, use:

{p 12 19 2}
{cmd:maptile_install} using {it:URL}{c |}{it:filename} [, {opt replace}]


{pmore}
When you point {cmd:maptile_install} to a URL or local ZIP file, it will automatically extract the files to the {bf:{help sysdir:PERSONAL}}/maptile_geographies folder. That is where {cmd:maptile} looks for geography templates by default.

{pmore}If you add {opt replace}, it will automatically overwrite existing files with ones from the ZIP file.

{pstd}
2) Alternatively, you can install a geography manually.

{pmore}Simply extract the geography ZIP file to any folder on your computer.
Then direct {cmd:maptile} to look in that folder using the {opt geofolder(folder_name)} option.


{marker usegeo}{...}
{title:Using geographies}

{pstd}1) Specify the geography name ({it:geoname})

{p 9 9 2}Each time you run {cmd:maptile} you need to specify the name of a geography template to use with the option {opt geo:graphy(geoname)}.

{marker cmd_geolist}{...}
{p 9 9 2}To list the names of currently installed geographies, use:

{p 15 22 2}
{cmd:maptile_geolist} [, {opt geofolder(folder_name)}]

{p 9 9 2}Running {cmd:maptile_geolist} without any options will list geographies in the {bf:{help sysdir:PERSONAL}}/maptile_geographies folder, which is where {cmd:maptile} loads geographies from automatically.


{marker geoid}{...}
{pstd}2) Ensure your dataset contains the correct geographic ID variable

{p 9 9 2}Your dataset must contain a geographic identifier variable, which associates each observation with an area on the map.

{p 9 9 2}Each geography will expect a specific geographic ID variable. For example, the geography for U.S. states might require a variable named "state" containing 2-letter state abbreviations. The required geographic ID variable will be indicated in the geography's help file.

{marker cmd_geohelp}{...}
{p 9 9 2} To see a geography's help file, use:

{p 15 22 2}
{cmd:maptile_geohelp} {it:geoname} [, {opt geofolder(folder_name)}]


{marker geo_options}{...}
{pstd}{it:3) Use any geography-specific options desired (geo_options)}

{p 9 9 2}Some geographies provide additional options which you can add to the {cmd:maptile} command.

{p 9 9 2}For example, a geography may provide an option that lets the user specify the coding format of the geographic ID variable (ex: US state 2-letter abbreviations or 2-digit FIPS codes).
As a second example, some geographies of the United States provide an option to place a heavier line on state borders.

{p 9 9 2}These additional options will be detailed in the {help maptile##cmd_geohelp:geography's help file}.


{marker makegeo}{...}
{title:Making new geographies}

{pstd}To be completed.


{marker options}{...}
{title:Options}

{pstd}To be completed.


{marker examples}{...}
{title:Examples}

{pstd}Install a geography template for U.S. States.{p_end}
{phang2}. {stata `"maptile_install using "http://michaelstepner.com/maptile/geo_state.zip""'}{p_end}

{pstd}Load state-level 1980 U.S. Census data.{p_end}
{phang2}. {stata sysuse census}{p_end}

{pstd}Rename the geographic ID vars to match the variable names of the {it:state} geography template.{p_end}
{phang2}. {stata rename (state state2) (statename state)}{p_end}

{pstd}{bf:Example 1}

{pstd}Plot the percentage of the population that are small children in each state.{p_end}
{phang2}. {stata gen babyperc=poplt5/pop*100}{p_end}
{phang2}. {stata maptile babyperc, geo(state)}{p_end}

{pstd}Small children are most common in the Western US.
But the bin of states with the highest percentage of children is much higher than the other 5 bins.{p_end}

{pstd}Try coloring each bin proportionally to its median value.{p_end}
{phang2}. {stata maptile babyperc, geo(state) propcolor}{p_end}
{phang2}. {stata matrix list r(midpoints)}{p_end}

{pstd}Most US states have a fairly similar proportion of children, but the highest group stands out.{p_end}

{pstd}Instead of grouping the states into quantile bins, now try coloring states individually and displaying a full spectrum in the legend.{p_end}
{phang2}. {stata maptile babyperc, geo(state) spopt(legstyle(3)) cutvalues(5(0.5)13)}{p_end}

{pstd}The proportion of children is very homogenous across states, with Utah as a major exception.
Three other states also stand out a bit from the rest.{p_end}

{pstd}Now format the map to make it look a little nicer.
(Hide DC because it is missing and it can't be seen in a map of US states anyway.){p_end}
{phang2}. {stata maptile babyperc, geo(state) spopt( legstyle(3) title("Percentage of Population Under Age 5", margin(medsmall)) ) mapif(state!="DC") cutvalues(5(0.5)13) legdecimals(0)}{p_end}


{pstd}{bf:Example 2}

{pstd}How do marriage rates vary across the US?{p_end}
{phang2}. {stata gen marriagerate=marriage/pop*100}{p_end}
{phang2}. {stata maptile marriagerate, geo(state)}{p_end}

{pstd}Quickly investigate that wide top bin (1.28-14.28).{p_end}
{phang2}. {stata sum marriagerate, d}{p_end}
{phang2}. {stata list if marriagerate>2}{p_end}
{phang2}. {stata maptile marriagerate, geo(state) propcolor}{p_end}

{pstd}Nevada is a huge outlier (because so many non-residents go to Las Vegas and get married).
But more broadly, the bins are quite evenly spaced.{p_end}

{pstd}Highlight the places with low marriage rates by reversing the colors, so that states with low marriage rates are dark red.{p_end}
{phang2}. {stata maptile marriagerate, geo(state) revcolor}{p_end}

{pstd}Now suppose you're making a Valentine's Day feature piece: the current color scheme won't do.{p_end}

{pstd}Try the Red -> Purple color scheme.{p_end}
{phang2}. {stata maptile marriagerate, geo(state) fcolor(RdPu)}{p_end}

{pstd}Still not splashy enough. Try manually defining the color spectrum.{p_end}
{phang2}. {stata maptile marriagerate, geo(state) rangecolor(pink*0.05 pink*1.3)}{p_end}


{marker saved_results}{...}
{title:Saved Results}

{pstd}
{cmd:maptile} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(breaks)}}list of cut points between bins{p_end}
{synopt:{cmd:r(midpoints)}}median value within each group ({it:if {opt propcolor} specified}){p_end}


{marker author}{...}
{title:Author}

{pstd}Michael Stepner{p_end}
{pstd}stepner@mit.edu{p_end}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}{cmd:maptile} was built on the shoulders of giants.  Maps are generated using
{cmd:spmap}, written by Maurizio Pisati. The geography template shapefiles were made using
{cmd:shp2dta}, written by Kevin Crow, as well as {cmd:mergepoly}, written by Robert Picard.
