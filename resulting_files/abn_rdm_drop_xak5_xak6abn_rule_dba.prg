CREATE PROGRAM abn_rdm_drop_xak5_xak6abn_rule:dba
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
 SET readme_data->message = "Failed to execute in database specific IF() statement"
 IF (currdb="ORACLE")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XAK5ABN_RULE", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XAK6ABN_RULE", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE1ABN_RULE", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  EXECUTE dm_drop_obsolete_objects "XIE4ORDER_SERV_RES_CONTAINER", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message =
  "XAK5ABN_RULE,XAK6ABN_RULE,XIE1ABN_RULE,XIE4ORDER_SERV_RES_CONTAINER indexes dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
