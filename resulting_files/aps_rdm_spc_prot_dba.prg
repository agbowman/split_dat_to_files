CREATE PROGRAM aps_rdm_spc_prot:dba
 DECLARE errmsg = vc WITH protect, noconstant("")
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
 SET readme_data->message = "Readme Failed:  Starting script aps_rdm_spc_prot..."
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=200473
   AND rp.sequence=1
  WITH nocounter, forupdate(rp)
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select request_processing: ",errmsg)
 ELSEIF (curqual=0)
  INSERT  FROM request_processing rp
   SET rp.request_number = 200473, rp.sequence = 1, rp.format_script = "PFMT_APS_PATHOLOGY_ORDER",
    rp.target_request_number = 560201, rp.destination_step_id = 560201, rp.service =
    "ORM.OrderWriteSynch",
    rp.reprocess_reply_ind = 1, rp.active_ind = 1, rp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    rp.updt_id = reqinfo->updt_id, rp.updt_task = reqinfo->updt_task, rp.updt_cnt = 0,
    rp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert request_processing: ",errmsg)
  ELSE
   COMMIT
   SET readme_data->status = "S"
   SET readme_data->message = concat("Execution Complete: ","script aps_rdm_spc_prot")
  ENDIF
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = concat("Row Exists: ","script aps_rdm_spc_prot")
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
