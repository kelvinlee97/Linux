#!/bin/bash
backup_dir="/path/to/backups" # edit
max_backups=5 # edit

while [ $(ls -1 "$backup_dir" | wc -l) -gt "$max_backups" ]; do
    oldest_backup=$(ls -1t "$backup_dir" | tail -n 1)
    # this action will keep delete the latest file until meet the condition "max_backups"
    rm -r "$backup_dir/$oldest_backup"
done

echo "Backup rotation completed"