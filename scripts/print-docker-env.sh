#!/bin/bash

# Check if a file is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <env_file>"
  exit 1
fi

# Assign the first argument to a variable
ENV_FILE=$1

# Check if the file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "File not found: $ENV_FILE"
  exit 1
fi

# Read the file and extract uncommented lines
grep -v '^\s*#' "$ENV_FILE" | grep -v '^\s*$'

# Alternatively, using a while loop:
# while IFS= read -r line; do
#   if [[ ! "$line" =~ ^\s*# ]] && [[ ! "$line" =~ ^\s*$ ]]; then
#     echo "$line"
#   fi
# done < "$ENV_FILE"
