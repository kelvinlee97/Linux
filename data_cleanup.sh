#!/bin/bash

directory="/path/to/cleanup"

# -type f = only "files"
# -mtime +7 = older than 7 modified days.
find "$directory" -type f -mtime +7 -exec rm {} \;
echo "Old files removed."