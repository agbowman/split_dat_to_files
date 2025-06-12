CREATE PROGRAM code_group_mod_trigger:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script code_group_mod_trigger.prg..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 EXECUTE dm_readme_include_sql "cer_install:create_code_value_group_mod_trigger.sql"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed while building the trigger",dm_sql_reply->msg)
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "TRG_CODE_VALUE_GROUP_MODS", "TRIGGER"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed while checking the trigger status",dm_sql_reply->
   msg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
