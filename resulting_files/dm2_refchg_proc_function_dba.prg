CREATE PROGRAM dm2_refchg_proc_function:dba
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
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 DECLARE cnt = i2
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm2_refchg_proc_function script."
 SELECT INTO "NL:"
  object_name
  FROM user_objects uo
  WHERE uo.object_name="DM_REFCHG_ENVID"
   AND uo.object_type="PROCEDURE"
  WITH nocounter
 ;end select
 IF (curqual=0)
  EXECUTE dm_readme_include_sql "cer_install:dm_refchg_envid.sql"
  IF ((dm_sql_reply->status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_refchg_envid", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:dm_proc_refchg_ins_log.sql"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "proc_refchg_ins_log", "procedure"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:dm_ccl_to_sql_str.sql"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "dm_ccl_to_sql_str", "function"
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
#exit_script
 SET readme_data->status = dm_sql_reply->status
 IF ((readme_data->status="F"))
  SET readme_data->message = dm_sql_reply->msg
 ELSE
  SET readme_data->message = "All PL/SQL FUNCTIONS exist in database."
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
