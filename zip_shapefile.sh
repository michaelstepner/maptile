#!/bin/bash
cd map_shapefiles
zip -FS ../geo_zip_files/geo_$1.zip $1_*.dta $1_*.ado $1_*.smcl