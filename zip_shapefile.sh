#!/bin/bash

echo "Zipping $1 template..."
cd build/geo_templates/$1
zip -FS ../../../geo_zip_files/geo_$1.zip $1_*.dta $1_*.ado $1_*.smcl

echo "Zipping $1 creation files..."
cd ../../archive
cd $(ls -d */ | grep $1 | tail -n 1)  # find most recent archive
zip -FS -r ../../../geo_zip_files/geo_$1_creation.zip *
