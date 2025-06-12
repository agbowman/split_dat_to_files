CREATE PROGRAM aps_rdm_move_track_svc_rsrc:dba
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
 SET readme_data->message = "Readme Failed:  Starting script aps_rdm_move_track_svc_rsrc..."
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 UPDATE  FROM ap_prefix ap
  SET ap.tracking_service_resource_cd = ap.service_resource_cd, ap.updt_applctx = reqinfo->
   updt_applctx, ap.updt_cnt = (ap.updt_cnt+ 1),
   ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_id = reqinfo->updt_id, ap.updt_task =
   reqinfo->updt_task
  WHERE ap.prefix_id > 0.0
   AND ap.interface_flag > 0
   AND ap.service_resource_cd > 0.0
   AND ap.tracking_service_resource_cd=0.0
  WITH nocounter
 ;end update
 IF (error(serrormessage,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update AP_PREFIX: ",serrormessage)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Tracking Service Resource(s) migrated."
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
