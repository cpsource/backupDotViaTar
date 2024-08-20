#!/bin/bash

# This script creates a backup of the current directory and stores it in a timestamped folder inside /mnt/e/ubuntu-backups/.
# The first argument on the command line should be 'full' or 'partial'.
# If 'partial' is presented, it excludes the directories: .cache, snap, and venv.
# Additionally, it checks if there are more than 10 backups in the /mnt/e/ubuntu-backups/ directory and deletes the oldest ones if necessary.
# After creating the backup, it creates a soft link named 'backup-latest' pointing to the latest backup set.
# The optional arguments '-x' add directories to the exclude list.

#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [full|partial] [-x <exclude-name>...] [-g] [-v]"
    echo "full    : Include all directories in the backup."
    echo "partial : Exclude .cache, snap, and venv directories from the backup."
    echo "-x      : Exclude an additional directory from the backup."
    echo "-g      : Create a compressed tar image of the backup directory."
    echo "-v      : Enable verbose output for tar commands."
    exit 1
}

# Initialize flags
create_tar=false
verbose_flag=""

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
    echo "Error: Missing or incorrect argument."
    show_help
    ;;
esac

# Check for additional exclude directories, -g flag, and -v flag
shift
while [ "$1" ]; do
  case "$1" in
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
    -g)
      echo "The -g flag is present. A compressed tar image will be created."
      create_tar=true
      ;;
    -v)
      echo "The -v flag is present. Verbose mode enabled."
      verbose_flag="v"
      ;;
    *)
      echo "Error: Invalid argument."
      show_help
      ;;
  esac
  shift
done

# Display the exclusion list
echo "Excluding the following directories from the backup:"
for exclude_dir in "${exclude_list[@]}"; do
  echo "  $exclude_dir"
done

# Get the current date and time
current_date_time=$(date +%Y%m%d%H%M%S)

# Define the source directory and the backup directory
source_directory="."
backup_directory="/mnt/e/ubuntu-backups/backup-$current_date_time"

# Create the backup directory
mkdir -p "$backup_directory"

# Build the tar command with the appropriate exclusions
tar_command="tar -c${verbose_flag}f -"
for exclude_dir in "${exclude_list[@]}"; do
  tar_command="$tar_command --exclude='$exclude_dir'"
done
tar_command="$tar_command '$source_directory'"

# Create a tarball of the source directory with the appropriate exclusions, and extract it to the backup directory
eval $tar_command | (cd "$backup_directory" && tar -x${verbose_flag}f -)

# Print completion message
echo "Backup completed successfully. Files are stored in: $backup_directory"

# Execute the new code if the flag is true
if $create_tar; then
  echo "Creating a compressed tar image of the backup directory..."

  # Define the output tar.gz file path
  output_tar="/mnt/g/My Drive/ubuntu-backups/$(basename "$backup_directory").tar.gz"

  # Create a compressed tar image of the entire backup directory
  tar -c${verbose_flag}zf "$output_tar" -C "$(dirname "$backup_directory")" "$(basename "$backup_directory")"

  # Print completion message
  echo "Compressed tar image created at: $output_tar"
fi

# Create a soft link named 'backup-latest' pointing to the latest backup
ln -sfn "$backup_directory" "/mnt/e/ubuntu-backups/backup-latest"
echo "Created soft link 'backup-latest' pointing to: $backup_directory"

# Define the backup base directory path
backup_base_directory="/mnt/e/ubuntu-backups"

# Get the list of backup directories sorted by creation time (oldest first), excluding the soft link 'backup-latest'
backup_directories=($(ls -dt ${backup_base_directory}/backup-* | grep -v 'backup-latest' | sort))

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
    echo "Deleting old backup: ${backup_directories[$i]}"
    rm -rf "${backup_directories[$i]}"
    echo "Deleted old backup: ${backup_directories[$i]}"
  done
else
  echo "Number of backups ($num_backups) is within the limit ($max_backups). No backups deleted."
fi

