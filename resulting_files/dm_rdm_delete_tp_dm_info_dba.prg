CREATE PROGRAM dm_rdm_delete_tp_dm_info:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_delete_tp_dm_info.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SELECT INTO "nl:"
  di.info_domain
  FROM dm_info di
  WHERE di.info_domain="PM_RDM_TASK_PREVIEW"
   AND di.info_name="PM_RDM_TASK_PREVIEW"
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed checking existence of DM_INFO row:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: No DM_INFO row found to delete")
  GO TO exit_script
 ELSE
  DELETE  FROM dm_info di
   WHERE di.info_domain="PM_RDM_TASK_PREVIEW"
    AND di.info_name="PM_RDM_TASK_PREVIEW"
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed deleting the DM_INFO row:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
