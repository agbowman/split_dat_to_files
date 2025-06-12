CREATE PROGRAM bmdi_rdm_add_dm_info:dba
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
 DECLARE mcrdmerrmsg = c132 WITH protect, noconstant(" ")
 DECLARE mlerrcode = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script bmdi_rdm_add_dm_info"
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DEVICE INTEGRATION SCRIPT LOGGING"
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Success: The row already exists"
  GO TO end_script
 ENDIF
 INSERT  FROM dm_info di
  SET di.info_domain = "DEVICE INTEGRATION SCRIPT LOGGING", di.updt_applctx = reqinfo->updt_applctx,
   di.updt_cnt = 0,
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
   reqinfo->updt_task
  WITH nocounter
 ;end insert
 SET mlerrcode = error(mcrdmerrmsg,0)
 IF (mlerrcode != 0)
  ROLLBACK
  SET readme_data->message = mcrdmerrmsg
  GO TO end_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Success: bmdi_rdm_add_dm_info successfully completed"
 COMMIT
#end_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
