#!/bin/sh

files=$(/app/app/static/generated/*)
if [ ${#files[@]} -eq 0 ]; then 
  echo Building assets
  flask assets build
fi
python3 /app/run.py
