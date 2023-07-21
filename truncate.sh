#!/bin/bash

# Set the file name and size limit
filename="your_filename" ##edit
size_limit=1000000000 #1gb

# Check the file size
file_size=$(stat -c%s "$filename")

# If the file size is greater than the size limit, truncate it
if [ "$file_size" -gt "$size_limit" ]; then
  echo "Truncating file..."
  truncate -s 100000000 "$filename" #100mb
fi

#### Single Command ####
# if [ "$(stat -c%s my_file.txt)" -gt 100000000 ]; then #100mb
#   truncate -s 0 my_file.txt ##edit ; #0byte
# fi
