#!/bin/bash
cd build/geo_templates/$1
zip ../../../geo_zip_files/geo_$1.zip $1_*.dta $1_*.ado $1_*.smcl