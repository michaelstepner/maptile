#!/bin/bash
export AWS_CONFIG_FILE=".aws_config"
aws s3 sync geo_zip_files/ s3://files.michaelstepner.com --acl public-read --exclude .DS_Store
aws s3 sync map_shapefiles/ s3://files.michaelstepner.com --acl public-read --exclude "*" --include "demo_maptile.*"