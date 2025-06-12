CREATE PROGRAM dm_drop_pk_cmt_x_map:dba
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
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 IF (currdb="ORACLE")
  EXECUTE dm_drop_obsolete_objects "XPKCMT_CROSS_MAP", "INDEX", 1
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode=0)
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "XPKCMT_CROSS_MAP Dropped."
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = build("README Failed: ",errmsg)
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
