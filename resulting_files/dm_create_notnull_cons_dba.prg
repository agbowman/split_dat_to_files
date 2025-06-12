CREATE PROGRAM dm_create_notnull_cons:dba
 SET dcn_tbl_name = trim(cnvtupper( $1))
 SET dcn_col_name = trim(cnvtupper( $2))
 SET dcn_op1 =  $3
 SET dcn_op2 =  $4
 SET dcn_op3 =  $5
 SET dcn_def_null = 0
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name=dcn_tbl_name
   AND u.column_name=dcn_col_name
  DETAIL
   IF (((nullind(u.data_default)=1) OR (((u.data_default="''") OR (u.data_default="NULL")) )) )
    dcn_def_null = 1
   ELSE
    dcn_def_null = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (dcn_def_null=1)) )
  EXECUTE dm_schema_actual_start2 dcn_op1
  SET ddl_log->err_code = 1
  SET ddl_log->err_str = "Command not processed column does not exist or data default not valued."
  SET ddl_log->cmd_str = concat("alter table ",dcn_tbl_name," modify ",dcn_col_name,
   " not null enable novalidate")
  SET ddl_log->ignore_ind = 0
  EXECUTE dm_schema_actual_stop2 dcn_op1
  EXECUTE dm_schema_actual_start2 dcn_op2
  SET ddl_log->err_code = 1
  SET ddl_log->err_str = "Command not processed column does not exist or data default not valued."
  SET ddl_log->cmd_str = concat("find not null constraint name for table ",dcn_tbl_name," column ",
   dcn_col_name)
  SET ddl_log->ignore_ind = 0
  EXECUTE dm_schema_actual_stop2 dcn_op2
  EXECUTE dm_schema_actual_start2 dcn_op3
  SET ddl_log->err_code = 1
  SET ddl_log->err_str = "Command not processed column does not exist or data default not valued."
  SET ddl_log->cmd_str = concat("alter table ",dcn_tbl_name," enable not null constraint for column ",
   dcn_col_name)
  SET ddl_log->ignore_ind = 0
  EXECUTE dm_schema_actual_stop2 dcn_op3
  GO TO exit_script
 ENDIF
 EXECUTE dm_schema_actual_start2 dcn_op1
 SET dcn_str = concat("RDB ALTER TABLE ",dcn_tbl_name," MODIFY ",dcn_col_name,
  " NOT NULL ENABLE NOVALIDATE go")
 CALL parser(dcn_str)
 SET ddl_log->err_code = error(ddl_log->err_str,1)
 SET ddl_log->cmd_str = concat("alter table ",dcn_tbl_name," modify ",dcn_col_name,
  " not null enable novalidate")
 SET ddl_log->ignore_ind = 0
 SET user_updt_ind = 1
 EXECUTE dm_schema_actual_stop2 dcn_op1
 EXECUTE dm_schema_actual_start2 dcn_op2
 SET ddl_log->cons_name = " "
 SELECT INTO "nl:"
  u.constraint_name
  FROM user_constraints u,
   user_cons_columns uc
  PLAN (u
   WHERE u.table_name=dcn_tbl_name
    AND u.constraint_type="C"
    AND u.status="ENABLED"
    AND u.validated="NOT VALIDATED")
   JOIN (uc
   WHERE u.constraint_name=uc.constraint_name
    AND uc.column_name=dcn_col_name)
  DETAIL
   ddl_log->cons_name = u.constraint_name
  WITH nocounter
 ;end select
 SET ddl_log->err_code = error(ddl_log->err_str,1)
 SET ddl_log->cmd_str = concat("find not null constraint name for table ",dcn_tbl_name," column ",
  dcn_col_name)
 SET ddl_log->ignore_ind = 0
 SET user_updt_ind = 1
 EXECUTE dm_schema_actual_stop2 dcn_op2
 EXECUTE dm_schema_actual_start2 dcn_op3
 SET dcn_str = concat("RDB ALTER TABLE ",dcn_tbl_name," ENABLE CONSTRAINT ",trim(ddl_log->cons_name),
  " go")
 CALL parser(dcn_str)
 SET ddl_log->err_code = error(ddl_log->err_str,1)
 SET ddl_log->cmd_str = concat("alter table ",dcn_tbl_name," enable not null constraint for column ",
  dcn_col_name)
 SET ddl_log->ignore_ind = 0
 SET user_updt_ind = 1
 EXECUTE dm_schema_actual_stop2 dcn_op3
#exit_script
END GO
