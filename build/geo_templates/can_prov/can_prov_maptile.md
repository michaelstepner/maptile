**maptile {hline 2} Geography: can_prov**

# Description

**can_prov** generates a map of Canadian provinces and territories.

This template uses the boundaries from the 2011 Census.

# Geographic ID variables

Table: col1width=16

----------------   -----------------------------
**prov**           2-letter postal abbreviations
**provcode**       2-digit SGC codes (Standard Geographical Classification)
**provcode_old**   older Statistics Canada province codes: 0-9 for provinces, 10-12 for territories
**provname**       full province names, in English
----------------   -----------------------------

# Geography-Specific Options

Table: col1width=22

---------------------   -----------------------------
{opth geoid(varname)}   specifies the geographic ID variable to use; default is **geoid(prov)**
---------------------   -----------------------------

Table: col1width=22

---------------------   -----------------------------
**mapifprov**           excludes the territories from the map, only mapping the 10 provinces
---------------------   -----------------------------

{p 32 32 2}This does not exclude the territories' data from the calculation of the quantiles (equal-sized color bins). To avoid counting the territories in the quantiles, add an **if** statement to your maptile command that excludes them.

{p 32 32 2}{opt mapifprov} is equivalent to {opt mapif( \<province, not territory\> )} but additionally adjusts the legend placement.

Table: col1width=22

---------------------   -----------------------------
{opt legendoffset(#)}   manually shifts the legend downward. # must be non-negative. When not specified, the legend offset is computed automatically.
---------------------   -----------------------------

# Author

Michael Stepner{break}
stepner@mit.edu