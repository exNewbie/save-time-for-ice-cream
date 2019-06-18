#!/bin/bash

## Usage: execute-sql-file.sh file.s3
set -e

S3_FILE=$1;

while IFS='' read -r line || [[ -n "$line" ]]; do
  time aws s3 cp "s3://upload.plantminer.com.au/${line}" "s3://upload.plantminer.com.au/${line}" --sse >> upload.plantminer.com.au-encrypt.log
  echo "=================================================================================================================================================";
done < "${S3_FILE}"
