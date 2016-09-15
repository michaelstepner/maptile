**maptile {hline 2} Geography: hrr**

# Description

**hrr** generates a map of United States hospital referer regions (HRRs), which "represent regional health care markets for tertiary medical care".

HRRs were defined and constructed by the Dartmouth Atlas, using a process described briefly on [their Research Methods webpage](http://www.dartmouthatlas.org/tools/faq/researchmethods.aspx), and in more detail in their [Online Appendix](http://www.dartmouthatlas.org/downloads/methods/geogappdx.pdf).

Alaska and Hawaii are rescaled and moved to the bottom left of the map, below the continental US, for ease of viewing.

# Geographic ID variable

**hrr** {hline 2} HRR codes

# Geography-Specific Options

Table: col1width=32

-----------------------------------   -----------------------------
{opth stateoutline(linewidthstyle)}   overlays the map with a (potentially thicker) line on state boundaries
**conus**                             hides Alaska and Hawaii, on the map **and** the state outline
-----------------------------------   -----------------------------

# Author

Michael Stepner{break}
stepner@mit.edu

# License

This geography template was constructed using a HRR shapefile and ZIP-HRR crosswalk provided at dartmouthatlas.org. Email correspondence with atlas@dartmouth.edu confirmed that these files are "freely available for use", "don't have any restrictions on redistribution, nor any licensing requirement". They were not released under any specific intellectual property license.

All code and documentation in this geography template is released into the public domain using the terms of the [Unlicense](http://unlicense.org/).  The **hrr_coords.dta** and **hrr_database.dta** files are derived from Dartmouth Atlas files. Like the files they are derived from, they are freely available for use with no restrictions on modification or redistributon, nor any licensing requirements. I cannot apply a specific license to those files, since they are derived from files that do not have a specific intellectual property license.