CREATE PROGRAM dm_readme_mass_move_log:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_report TO 2999_report_exit
 GO TO 9999_exit_program
#1000_initialize
 SET mode = 2
 SET ocd = 0
 SET ocd =  $1
#1999_initialize_exit
#2000_report
 EXECUTE dm_readme_log
#2999_report_exit
#9999_exit_program
END GO
