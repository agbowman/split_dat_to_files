CREATE PROGRAM dm_cmb_include_sql:dba
 SET c_mod = "DM_CMB_INCLUDE_SQL 002"
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto Success on DB2 sites"
  GO TO exit_program
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 CALL echo("***")
 CALL echo(concat("*** Start readme ",curprog))
 CALL echo("***")
 DECLARE dcis_sub_check_object("procedure name") = i4
 SET dcis_stat = 0
 SET dcis_stat = dcis_sub_check_object("DM_CMB_FIND_PERSON2")
 SET dcis_stat = dcis_sub_check_object("DM_CMB_FIND_ENCOUNTER2")
 CALL echo(concat("*** Creating procedure dm_cmb_find_person2. ***"))
 EXECUTE dm_readme_include_sql "cer_install:dm_cmb_find_person2.sql"
 EXECUTE dm_readme_include_sql_chk "dm_cmb_find_person2", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO sql_failed
 ENDIF
 CALL echo(concat("*** Creating procedure dm_cmb_find_encounter2. ***"))
 EXECUTE dm_readme_include_sql "cer_install:dm_cmb_find_encounter2.sql"
 EXECUTE dm_readme_include_sql_chk "dm_cmb_find_encounter2", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO sql_failed
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "All procedures created successfully."
 GO TO exit_program
#sql_failed
 SET readme_data->status = dm_sql_reply->status
 SET readme_data->message = dm_sql_reply->msg
 GO TO exit_program
 SUBROUTINE dcis_sub_check_object(p_procedure_name)
   SET dcis_return_val = 0
   SET p_procedure_name = cnvtupper(p_procedure_name)
   SELECT INTO "nl:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=p_procedure_name
    DETAIL
     dcis_return_val = 1
    WITH nocounter
   ;end select
   IF (dcis_return_val=1)
    CALL parser(concat("rdb drop procedure ",p_procedure_name," go"))
    CALL echo(concat("*** Procedure ",p_procedure_name," found and dropped. ***"))
   ELSE
    CALL echo(concat("*** Procedure ",p_procedure_name," did not previously exist. ***"))
   ENDIF
   RETURN(dcis_return_val)
 END ;Subroutine
#exit_program
 CALL echo("***")
 IF ((readme_data->status="F"))
  CALL echo(concat("*** Readme ",curprog," failed!"))
 ENDIF
 CALL echo(concat("*** ",readme_data->message))
 CALL echo("***")
 EXECUTE dm_readme_status
END GO
