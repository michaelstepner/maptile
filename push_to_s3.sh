#!/bin/bash
export AWS_CONFIG_FILE=".aws_config"
aws s3 sync geo_zip_files/ s3://files.michaelstepner.com --acl public-read --exclude .DS_Store
aws s3 sync build/geo_templates/demo/ s3://files.michaelstepner.com --acl public-read --exclude "*" --include "demo_maptile.*"

for d in $(ls -d build/tests/*/)
do
  aws s3 sync $d s3://files.michaelstepner.com/geo_img --acl public-read --exclude "*" --include "*_noopt.png"
done
