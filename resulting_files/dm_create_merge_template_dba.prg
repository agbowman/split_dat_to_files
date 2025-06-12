CREATE PROGRAM dm_create_merge_template:dba
 CALL echo("Start dm_create_merge_template")
 EXECUTE dm_ins_merge_translates 0, 0
 CALL echo("dm_create_merge_template is finished")
#exit_program
END GO
