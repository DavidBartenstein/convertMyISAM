backup_dir=~/MyISAMconversion/backup; required_space=$(mysql -N -e "SET sql_log_bin = 0; SELECT CONCAT('ALTER TABLE \`', table_schema, '\`.\`', table_name, '\` ENGINE=InnoDB;') FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema') AND engine='MyISAM';" | wc -c); required_space=$((required_space * 115 / 100)); available_space=$(df -P / | awk 'NR==2 {print $4}'); if ((available_space < required_space)); then echo "Insufficient disk space. Backup and conversion aborted. Please free up space."; else mkdir -p "$backup_dir"; db_list=$(mysql -N -e "SET sql_log_bin = 0; SELECT DISTINCT(table_schema) FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema') AND engine='MyISAM';"); for db_name in $db_list; do log_file="${backup_dir}/${db_name}_dump_log.txt"; mysqldump_command="mysqldump --single-transaction --quick --lock-tables=false --routines --triggers --no-create-db --no-create-info --skip-add-drop-table --skip-comments --databases $db_name"; echo "Executing: $mysqldump_command" >> "$log_file"; table_list=($(mysql -N -e "SET sql_log_bin = 0; SELECT table_name FROM information_schema.tables WHERE table_schema = '$db_name' AND engine='MyISAM';")); for table_name in "${table_list[@]}"; do echo "Dumping table: $table_name" >> "$log_file"; mysqldump --single-transaction --quick --lock-tables=false --routines --triggers --no-create-db --no-create-info --skip-add-drop-table --skip-comments --databases "$db_name" --tables "$table_name" >> "${backup_dir}/${db_name}_backup.sql" 2>> "$log_file"; done; echo "Altering table engines for database: $db_name" >> "$log_file"; mysql -N -e "SET sql_log_bin = 0; SELECT CONCAT('ALTER TABLE \`', table_schema, '\`.\`', table_name, '\` ENGINE=InnoDB;') FROM information_schema.tables WHERE table_schema = '$db_name' AND engine='MyISAM';" | mysql -N; done; echo "Backup and table engine alterations completed successfully in: $backup_dir"; fi
