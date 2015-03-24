**maptile {hline 2} Geography: state**

# Description

**state** generates a map of U.S. states.

It displays Alaska and Hawaii rescaled and moved to the bottom left of the map, below the continental US, for ease of viewing.

# Geographic ID variables

Table: col1width=13

-------------   -----------------------------
**state**       2-letter state abbreviations
**statefips**   2-digit state FIPS codes
**statename**   unabbreviated state names
-------------   -----------------------------

# Geography-Specific Options

---------------------   -----------------------------
{opth geoid(varname)}   specifies the geographic ID variable to use; default is **geoid(state)**
---------------------   -----------------------------


# Author

Michael Stepner{break}
stepner@mit.edu