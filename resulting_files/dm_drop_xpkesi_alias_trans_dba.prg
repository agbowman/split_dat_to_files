CREATE PROGRAM dm_drop_xpkesi_alias_trans:dba
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
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET readme_data->message = "Drop XPKESI_ALIAS_TRANS"
 EXECUTE dm_readme_status
 EXECUTE dm_drop_obsolete_objects "XPKESI_ALIAS_TRANS ", "INDEX", 1
 IF (errcode != 0)
  SET readme_data->message = build(errmsg,"- Readme Failed.")
  SET readme_data->status = "F"
  GO TO end_program
 ELSE
  SET readme_data->message = "Successfully dropped XPKESI_ALIAS_TRANS"
  SET readme_data->status = "S"
 ENDIF
#end_program
 EXECUTE dm_readme_status
END GO
