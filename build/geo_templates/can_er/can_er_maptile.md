**maptile {hline 2} Geography: can_er**

# Description

**can_er** generates a map of Canadian economic regions.

An economic region is a grouping of complete census divisions (with one exception in Ontario) created as a standard geographic unit for analysis of regional economic activity. [[Source]](http://www.statcan.gc.ca/pub/92-195-x/2011001/geo/er-re/er-re-eng.htm)

This template uses the boundaries from the 2011 Census.

# Geographic ID variables

Table: col1width=16

----------------   -----------------------------
**er**             4-digit economic region codes
----------------   -----------------------------

# Geography-Specific Options

Table: col1width=30

----------------------------------   -----------------------------
{opth provoutline(linewidthstyle)}   overlays the map with a (potentially thicker) line on province boundaries
----------------------------------   -----------------------------

Table: col1width=30

----------------------------------   -----------------------------
**mapifprov**                        excludes the territories from the map, only mapping the 10 provinces
----------------------------------   -----------------------------

{p 40 40 2}This does not exclude the territories' data from the calculation of the quantiles (equal-sized color bins). To avoid counting the territories in the quantiles, add an **if** statement to your maptile command that excludes them.

{p 40 40 2}{opt mapifprov} is equivalent to {opt mapif( \<province, not territory\> )} but additionally adjusts the legend placement.

Table: col1width=30

---------------------   -----------------------------
{opt legendoffset(#)}   manually shifts the legend downward. # must be non-negative. When not specified, the legend offset is computed automatically.
---------------------   -----------------------------

# Author

Michael Stepner{break}
stepner@mit.edu

# License

This geography template is released into the public domain.  The shapefile it is derived from is in the public domain, and all code and documentation in this template is released into the public domain using the terms of the [Unlicense](http://unlicense.org/).