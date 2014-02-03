{smcl}
{* *! version 0.70  1feb2014}{...}
{viewerjumpto "Syntax" "maptile##syntax"}{...}
{viewerjumpto "Description" "maptile##description"}{...}
{viewerjumpto "Options" "maptile##options"}{...}
{viewerjumpto "Examples" "maptile##examples"}{...}
{viewerjumpto "Saved results" "maptile##saved_results"}{...}
{viewerjumpto "Installing a geography" "maptile##installgeo"}{...}
{viewerjumpto "Making a new geography" "maptile##makegeo"}{...}
{viewerjumpto "Author" "maptile##author"}{...}
{viewerjumpto "Acknowledgements" "maptile##acknowledgements"}{...}
{title:Title}

{pstd}
{hi:maptile} {hline 2} Quantile maps


{marker syntax}{title:Syntax}

{pstd} Map a variable

{p 8 15 2}
{cmd:maptile}
{varname} {ifin}{cmd:,} {opt geo:graphy(geoname)} [{it:options}]


{pstd} Install a new geography template

{p 8 15 2}
{cmd:maptile_install} using {it:URL}{c |}{it:filename} [, {opt replace}]


{synoptset 35 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opt geo:graphy(geoname)}}geographic template to map{p_end}
{synopt :{it:geo_options}}options specific to the geographic template being used{p_end}

{syntab :Quantiles}
{synopt :{opth n:quantiles(#)}}number of quantiles (color bins); default is {bf:6}{p_end}
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
{synopt :{cmdab:mapif(}{it:{help condition}}{cmd:)}}restrict the map to a subset of areas{p_end}
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
As the help file states, "{cmd:spmap} gives the user full control over the formatting of almost every map element, thus allowing the production of highly customized maps".
When using {cmd:maptile}, most of these customizations are stored away in the geography template.
As a result, the syntax for making highly customized maps using {cmd:maptile} can be very simple.
Additionally, the geography templates can be easily shared and used by others.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{marker by_notes}{...}
{phang}{opth by(varname)} plots a separate series for each by-value.  Both numeric and string by-variables
are supported, but numeric by-variables will have faster run times.

{pmore}Users should be aware of the two ways in which {cmd:binscatter} does not condition on by-values:

{phang3}1) When combined with {opt controls()} or {opt absorb()}, the program residualizes using the restricted model in which each covariate
has the same coefficient in each by-value sample.  It does not run separate regressions for each by-value.  If you wish to control for 
covariates using a different model, you can residualize your x- and y-variables beforehand using your desired model then run {cmd:binscatter}
on the residuals you constructed.

{phang3}2) When not combined with {opt discrete} or {opt xq()}, the program constructs a single set of bins
using the unconditional quantiles of the x-variable.  It does not bin the x-variable separately for each by-value.
If you wish to use a different binning procedure (such as constructing equal-sized bins separately for each
by-value), you can construct a variable containing your desired bins beforehand, then run {cmd:binscatter} with {opt xq()}.

{phang}{opt med:ians} creates the binned scatterplot using the median x- and y-value within each bin, rather than the mean.
This option only affects the scatter points; it does not, for instance, cause {opt linetype(lfit)}
to use quantile regression instead of OLS when drawing a fit line.

{dlgtab:Bins}

{phang}{opth n:quantiles(#)} specifies the number of equal-sized bins to be created.  This is equivalent to the number of
points in each series.  The default is {bf:20}. If the x-variable has fewer
unique values than the number of bins specified, then {opt discrete} will be automatically invoked, and no
binning will be performed.
This option cannot be combined with {opt discrete} or {opt xq()}.

{pmore}
Binning is performed after residualization when combined with {opt controls()} or {opt absorb()}.
Note that the binning procedure is equivalent to running xtile, which in certain cases will generate
fewer quantile categories than specified. (e.g. {stata sysuse auto}; {stata xtile temp=mpg, nq(20)}; {stata tab temp})
  
{phang}{opth gen:xq(varname)} creates a categorical variable containing the computed bins.
This option cannot be combined with {opt discrete} or {opt xq()}.

{phang}{opt discrete} specifies that the x-variable is discrete and that each x-value is to be treated as
a separate bin. {cmd:binscatter} will therefore plot the mean y-value associated with each x-value.
This option cannot be combined with {opt nquantiles()}, {opt genxq()} or {opt xq()}.

{pmore}
In most cases, {opt discrete} should not be combined with {opt controls()} or {opt absorb()}, since residualization occurs before binning,
and in general the residual of a discrete variable will not be discrete.

{phang}{opth xq(varname)} specifies a categorical variable that contains the bins to be used, instead of {cmd:binscatter} generating them.
This option is typically used to avoid recomputing the bins needlessly when {cmd:binscatter} is being run repeatedly on the same sample
and with the same x-variable.
It may be convenient to use {opt genxq(binvar)} in the first iteration, and specify {opt xq(binvar)} in subsequent iterations.
Computing quantiles is computationally intensive in large datasets, so avoiding repetition can reduce run times considerably.
This option cannot be combined with {opt nquantiles()}, {opt genxq()} or {opt discrete}.

{pmore}
Care should be taken when combining {opt xq()} with {opt controls()} or {opt absorb()}.  Binning takes place after residualization,
so if the sample changes or the control variables change, the bins ought to be recomputed as well.

{marker controls}{...}
{dlgtab:Controls}

{phang}{opth control:s(varlist)} residualizes the x-variable and y-variables on the specified controls before binning and plotting.
To do so, {cmd:binscatter} runs a regression of each variable on the controls, generates the residuals, and adds the sample mean of
each variable back to its residuals.

{phang}{opth absorb(varname)} absorbs fixed effects in the categorical variable from the x-variable and y-variables before binning and plotting,
To do so, {cmd:binscatter} runs an {helpb areg} of each variable with {it:absorb(varname)} and any {opt controls()} specified.  It then generates the
residuals and adds the sample mean of each variable back to its residuals.

{phang}{opt noa:ddmean} prevents the sample mean of each variable from being added back to its residuals, when combined with {opt controls()} or {opt absorb()}.

{marker fit_line}{...}
{dlgtab:Fit Line}

{marker linetype}{...}
{phang}{opth line:type(binscatter##linetype:linetype)} specifies the type of line plotted on each series.
The default is {bf:lfit}, which plots a linear fit line.  Other options are {bf:qfit} for a quadratic fit line,
{bf:connect} for connected points, and {bf:none} for no line.

{pmore}Linear or quadratic fit lines are estimated using the underlying data, not the binned scatter points. When combined with
{opt controls()} or {opt absorb()}, the fit line is estimated after the variables have been residualized.

{phang}{opth rd(numlist)} draws a dashed vertical line at the specified x-values and generates regression discontinuities when combined with {opt line(lfit|qfit)}.
Separate fit lines will be estimated below and above each discontinuity.  These estimations are performed using the underlying data, not the binned scatter points.

{pmore}The regression discontinuities do not affect the binned scatter points in any way.
Specifically, a bin may contain a discontinuity within its range, and therefore include data from both sides of the discontinuity.

{phang}{opt reportreg} displays the regressions used to estimate the fit lines in the results window.

{dlgtab:Graph Style}

{phang}{cmdab:col:ors(}{it:{help colorstyle}list}{cmd:)} specifies an ordered list of colors for each series

{phang}{cmdab:mc:olors(}{it:{help colorstyle}list}{cmd:)} specifies an ordered list of colors for the markers of each series, which overrides any list provided in {opt colors()}

{phang}{cmdab:lc:olors(}{it:{help colorstyle}list}{cmd:)} specifies an ordered list of colors for the line of each series, which overrides any list provided in {opt colors()}

{phang}{cmdab:m:symbols(}{it:{help symbolstyle}list}{cmd:)} specifies an ordered list of symbols for each series

{phang}{it:{help twoway_options}}:

{pmore}Any unrecognized options added to {cmd:binscatter} are appended to the end of the twoway command which generates the
binned scatter plot.

{pmore}These can be used to control the graph {help title options:titles},
{help legend option:legends}, {help axis options:axes}, added {help added line options:lines} and {help added text options:text},
{help region options:regions}, {help name option:name}, {help aspect option:aspect ratio}, etc.

{dlgtab:Save Output}

{phang}{opt savegraph(filename)} saves the graph to a file.  The format is automatically detected from the extension specified [ex: {bf:.gph .jpg .png}],
and either {cmd:graph save} or {cmd:graph export} is run.  If no file extension is specified {bf:.gph} is assumed.

{phang}{opt savedata(filename)} saves {it:filename}{bf:.csv} containing the binned scatterpoint data, and {it:filename}{bf:.do} which
loads the scatterpoint data, labels the variables, and plots the binscatter graph.

{pmore}Note that the saved result {bf:e(cmd)} provides an alternative way of capturing the binscatter graph and editing it.

{phang}{opt replace} specifies that files be overwritten if they alredy exist

{dlgtab:fastxtile options}

{phang}{opt nofastxtile} forces the use of {cmd:xtile} instead of {cmd:fastxtile} to compute bins.  There is no situation where this should
be necessary or useful.  The {cmd:fastxile} program generates identical results to {cmd:xtile}, but runs faster on large datasets, and has
additional options for random sampling which may be useful to increase speed.

{pmore}{cmd:fastxtile} is built into the {cmd:binscatter} code, but may also be installed
separately from SSC ({stata ssc install fastxtile:click here to install}) for use outside of {cmd:binscatter}.

{phang}{opth randvar(varname)} requests that {it:varname} be used to select a
sample of observations when computing the quantile boundaries.  Sampling increases
the speed of the binning procedure, but generates bins which are only approximately equal-sized
due to sampling error.  It is possible to omit this option and still perform random sampling from U[0,1]
as described below in {opt randcut()} and {opt randn()}.

{phang}{opt randcut(#)} specifies the upper bound on the variable contained
in {opt randvar(varname)}. Quantile boundaries are approximated using observations for which
{opt randvar()} <= #.  If no variable is specified in {opt randvar()},
a standard uniform random variable is generated. The default is {cmd:randcut(1)}.
This option cannot be combined with {opt randn()}.

{phang}{opt randn(#)} specifies an approximate number of observations to sample when
computing the quantile boundaries. Quantile boundaries are approximated using observations
for which a uniform random variable is <= #/N. The exact number of observations
sampled may therefore differ from #, but it equals # in expectation. When this option is
combined with {opth randvar(varname)}, {it:varname} ought to be distributed U[0,1].
Otherwise, a standard uniform random variable is generated. This option cannot be combined
with {opt randcut()}.


{marker examples}{...}
{title:Examples}

{pstd}Load the 1988 extract of the National Longitudinal Survey of Young Women and Mature Women.{p_end}
{phang2}. {stata sysuse nlsw88}{p_end}
{phang2}. {stata keep if inrange(age,35,44) & inrange(race,1,2)}{p_end}

{pstd}What is the relationship between job tenure and wages?{p_end}
{phang2}. {stata scatter wage tenure}{p_end}
{phang2}. {stata binscatter wage tenure}{p_end}

{pstd}The scatter was too crowded to be easily interpetable. The binscatter is cleaner, but a linear fit looks unreasonable.{p_end}

{pstd}Try a quadratic fit.{p_end}
{phang2}. {stata binscatter wage tenure, line(qfit)}{p_end}

{pstd}We can also plot a linear regression discontinuity.{p_end}
{phang2}. {stata binscatter wage tenure, rd(2.5)}{p_end}

{pstd} What is the relationship between age and wages?{p_end}
{phang2}. {stata scatter wage age}{p_end}
{phang2}. {stata binscatter wage age}{p_end}

{pstd} The binscatter is again much easier to interpret. (Note that {cmd:binscatter} automatically
used each age as a discrete bin, since there are fewer than 20 unique values.){p_end}

{pstd}How does the relationship vary by race?{p_end}
{phang2}. {stata binscatter wage age, by(race)}{p_end}

{pstd} The relationship between age and wages is very different for whites and blacks. But what if we control for occupation?{p_end}
{phang2}. {stata binscatter wage age, by(race) absorb(occupation)}{p_end}

{pstd} A very different picture emerges.  Let's label this graph nicely.{p_end}
{phang2}. {stata binscatter wage age, by(race) absorb(occupation) msymbols(O T) xtitle(Age) ytitle(Hourly Wage) legend(lab(1 White) lab(2 Black))}{p_end}


{marker saved_results}{...}
{title:Saved Results}

{pstd}
{cmd:binscatter} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(graphcmd)}}twoway command used to generate graph, which does not depend on loaded data{p_end}
{p 30 30 2}Note: it is often important to reference this result using `"`{bf:e(graphcmd)}'"'
rather than {bf:e(graphcmd)} in order to avoid truncation due to Stata's character limit for strings.

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(byvalues)}}ordered list of by-values {it:(if numeric by-variable specified)}{p_end}
{synopt:{cmd:e(rdintervals)}}ordered list of rd intervals {it:(if rd specified)}{p_end}
{synopt:{cmd:e(y#_coefs)}}fit line coefficients for #th y-variable {it:(if lfit or qfit specified)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks sample{p_end}
{p2colreset}{...}

{marker installgeo}{...}
{title:Installing a geography}
many are geos available {browse "http://michaelstepner.com/maptile/geographies":from the program's website}.

{marker makegeo}{...}
{title:Making a new geography}


{marker author}{...}
{title:Author}

{pstd}Michael Stepner{p_end}
{pstd}stepner@mit.edu{p_end}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}{cmd:maptile} was built on the shoulders of giants.  Maps are generated using
{cmd:spmap}, written by Maurizio Pisati. The geography template shapefiles were made using
{cmd:shp2dta}, written by Kevin Crow, as well as {cmd:mergepoly}, written by Robert Picard.
