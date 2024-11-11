#!/bin/bash

output_file="cpu_usage_log.txt"

echo "$(date)"
# $2 = %us (user space) and $4 = %sy (system space) to get the total CPU usage.
echo "$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%" >> "$output_file"

echo "CPU usage logged."