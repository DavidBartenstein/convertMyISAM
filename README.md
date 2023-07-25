# convertMyISAM
A single line bash command that converts all MyISAM tables from EVERY database on the server to InnoDB.

Prerequisites to consider:
 - this command assumes you have root access to every database on your server and no need for database credentials

It executes the following steps:
 - checks the available diskspace
 - checks the amount of diskspace needed to backup all MyISAM tables in every single database
 - considering a safe amount of 15% diskspace, if enough space is indeed available, it creates backup files using mysqldump. If not: it spits out a diskspace warning and exits the script.
 - if the backup is succesfull, the script starts converting all the MyISAM tables and logs what it does to files in the ~/MyISAMconversion/backup directory
