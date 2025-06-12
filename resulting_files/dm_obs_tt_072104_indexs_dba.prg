CREATE PROGRAM dm_obs_tt_072104_indexs:dba
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
 SET readme_data->message = "Failed to execute obsolete process"
 IF (currdb="ORACLE")
  CALL echo("Running Obsolete Process on indexes...")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XPKCODE_VALUE_FILTER_R", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XIE1EEM_TRANSACTION", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XIE5HIM_EVENT_ALLOCATION", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XFKNDXORDER_DISPENSE", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XIF003PAYMENT_SESSION", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XPKRAD_ACR_CODES", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XIE1SEG_GRP_SEQ_R", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XPKTRACK_ORD_EVENT_RELTN", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "XPKREF_TEXT_RELTN", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "FKNDX1_MIC_REF_BILLING_SUS", "INDEX", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Indexes were dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
