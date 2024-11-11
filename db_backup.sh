#!/bin/bash
database_name="your_database"
output_file="database_backup_$(date+%Y%m%d).sql"

mysqldump -u username -p password "$database_name" > "$output_file"
echo "Database backup created: $output_file"