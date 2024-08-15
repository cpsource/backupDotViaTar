#!/bin/bash

# Get the current day of the week (1-7 where 1 is Monday and 7 is Sunday)
day_of_week=$(date +%u)

# Base command
command="./backupDotViaTar/backup-ubuntu.sh full -x .cache -x snap -x .local"

# Check if it's Tuesday through Sunday (2-7)
if [ $day_of_week -ge 2 ] && [ $day_of_week -le 7 ]; then
  command="$command -x venv"
fi

# Execute the command
$command

