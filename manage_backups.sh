#!/bin/bash

# This script checks the number of backup directories in /mnt/e/ubuntu-backups/.
# If there are more than 10 backup directories, it deletes the oldest ones,
# ensuring that only the 10 most recent backups are kept.

# Define the backup directory path
backup_base_directory="/mnt/e/ubuntu-backups"

# Get the list of backup directories sorted by creation time (oldest first)
backup_directories=($(ls -dt ${backup_base_directory}/backup-*))

# Get the number of backups
num_backups=${#backup_directories[@]}

# Define the maximum number of backups to keep
max_backups=10

# Check if the number of backups exceeds the maximum allowed
if [ $num_backups -gt $max_backups ]; then
  # Calculate the number of backups to delete
  num_to_delete=$((num_backups - max_backups))

  # Delete the oldest backups
  for ((i=0; i<num_to_delete; i++)); do
    rm -rf "${backup_directories[$i]}"
    echo "Deleted old backup: ${backup_directories[$i]}"
  done
else
  echo "Number of backups ($num_backups) is within the limit ($max_backups). No backups deleted."
fi

