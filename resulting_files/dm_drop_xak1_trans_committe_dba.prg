CREATE PROGRAM dm_drop_xak1_trans_committe:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dm_drop_XAK1_trans_committe"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 IF (currdb="ORACLE")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XAK1TRANSFUSION_COMMITTEE", "INDEX", 1
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed dropping XAK1TRANSFUSION_COMMITTEE object:",errmsg)
   GO TO exit_script
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
