# backupDotViaTar
backupDotViaTar is a bash based backup that uses tar. It also manages your backup sets and keeps the last ten.

# To Install

Execute the following command

  git clone https://github.com/cpsource/backupDotViaTar.git
  
Then modify the backup_directory variable in files backup_ubuntu.sh and backup-check.sh to point to where you wish your backup sets to be created and managed.

# To Run

From your root directory, type

	./backupDotViaTar/backup_ubuntu.sh switches
	
	Switches are
	  full or partial
	  -x 'some-directory' - exclude this directory from the backup
You can verify your backup set by

	./backupDotViaTar/backup-check.sh switches
	
	Switches are
	  * -x 'some-directory' - exclude this directory from the backup.
	  * -w - watch each 100th file being checked. It's eye candy.
	  * -d - display every file being checked. It's for debugging.

You can cleanup all your gits by

  ./backupDotViaTar/git_gc.sh
  
Other scripts in the git have comments on what they do.
# Cron
You can set crontab -e to allow the backup script to run a midnight every day, or whatever.
# Other notes
This was mostly written (99%) by ChatGPT4 and took about five hours, including this documentation.


	
	  


