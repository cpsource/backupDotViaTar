#!/bin/bash

# This script checks if regular files in the current directory (dot) are backed up in 'backup-latest'.
# The first argument on the command line should be 'full' or 'partial'.
# If 'partial' is presented, it excludes the directories: .cache, snap, and venv.
# The optional arguments '-d', '-w', and '-x' modify the script's behavior:
# -d displays each filename before diffing.
# -w displays the name of every 100th file checked.
# -x <exclude-name> adds an additional directory to the exclude list.
# It reports files that are not backed up and differences between existing files.

# Check the first argument and set the exclusion list accordingly
backup_type="$1"
case "$backup_type" in
  full)
    exclude_list=()
    ;;
  partial)
    exclude_list=(./.cache ./snap ./venv)
    ;;
  *)
    echo "Usage: $0 [full|partial] [-d] [-w] [-x <exclude-name>...]"
    echo "full    : Include all directories in the check."
    echo "partial : Exclude .cache, snap, and venv directories from the check."
    echo "-d      : Display each filename before diffing."
    echo "-w      : Display the name of every 100th file checked."
    echo "-x      : Exclude an additional directory from the check."
    exit 1
    ;;
esac

# Initialize flags for optional arguments
display_diff=false
display_every_100th=false

# Check remaining command line arguments
shift
while [ "$1" ]; do
  case "$1" in
    -d)
      display_diff=true
      ;;
    -w)
      display_every_100th=true
      ;;
    -x)
      shift
      if [ "$1" ]; then
        exclude_dir="$1"
        # Ensure the exclude_dir starts with ./
        if [[ "$exclude_dir" != ./* ]]; then
          exclude_dir="./$exclude_dir"
        fi
        exclude_list+=("$exclude_dir")
      else
        echo "Error: -x requires a directory name"
        exit 1
      fi
      ;;
    *)
      echo "Usage: $0 [full|partial] [-d] [-w] [-x <exclude-name>...]"
      echo "full    : Include all directories in the check."
      echo "partial : Exclude .cache, snap, and venv directories from the check."
      echo "-d      : Display each filename before diffing."
      echo "-w      : Display the name of every 100th file checked."
      echo "-x      : Exclude an additional directory from the check."
      exit 1
      ;;
  esac
  shift
done

# Display the exclusion list
echo "Excluding the following directories from the check:"
for exclude_dir in "${exclude_list[@]}"; do
  echo "  $exclude_dir"
done

# Define the source directory and the backup directory
source_directory="."
backup_directory="/mnt/e/ubuntu-backups/backup-latest"

# Ensure the backup directory exists
if [ ! -d "$backup_directory" ]; then
  echo "Error: Backup directory 'backup-latest' does not exist."
  exit 1
fi

# Initialize counters for total, missing, different files, and total bytes
total_count=0
missing_count=0
different_count=0
total_bytes=0

# Subroutines to increment the counts
increment_total_count() {
  ((total_count++))
}

increment_missing_count() {
  ((missing_count++))
}

increment_different_count() {
  ((different_count++))
}

increment_total_bytes() {
  total_bytes=$((total_bytes + $1))
}

# Build the find command with the appropriate exclusions
find_command="find $source_directory"
for exclude_dir in "${exclude_list[@]}"; do
  find_command="$find_command -path '$exclude_dir' -prune -o"
done
find_command="$find_command -type f -print"

# Execute the find command and check each file
while IFS= read -r source_file; do
  # Increment the total files checked count
  increment_total_count

  # Display the name of every 100th file checked if the -w option is present
  if [ "$display_every_100th" = true ] && ((total_count % 100 == 0)); then
    echo "Checking 100th file: $source_file"
  fi

  # Construct the corresponding backup file path
  backup_file="$backup_directory/${source_file#./}"

  # Add the file size to the total bytes
  if [ -e "$source_file" ]; then
    file_size=$(stat -c%s "$source_file")
    increment_total_bytes $file_size
  fi

  # Check if the file exists in the backup directory
  if [ ! -e "$backup_file" ]; then
    echo "File not backed up: $source_file" >&2
    increment_missing_count
  else
    # Display the filename if the -d option is present
    if [ "$display_diff" = true ]; then
      echo "Checking file: $source_file"
    fi

    # Compare the source file and the backup file
    if ! diff -q "$source_file" "$backup_file" > /dev/null; then
      echo "Files differ: $source_file" >&2
      increment_different_count
    fi
  fi
done < <(eval "$find_command")

# Report the count of total, missing, different files, and total bytes
echo "Backup check completed."
echo "Total files checked: $total_count"
echo "Missing files: $missing_count"
echo "Different files: $different_count"
echo "Total bytes checked: $total_bytes"

