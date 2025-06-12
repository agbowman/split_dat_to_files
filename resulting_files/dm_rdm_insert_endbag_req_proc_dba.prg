CREATE PROGRAM dm_rdm_insert_endbag_req_proc:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_insert_endbag_req_proc..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE max_seq = i4 WITH protect, noconstant(0)
 DECLARE ifound = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=3091000
   AND rp.format_script="PFMT_BSC_CALC_END_BAG"
  DETAIL
   ifound = 1
  WITH nocounter
 ;end select
 IF (ifound=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Row is already inserted in request_processing table"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  sequence = max(rp.sequence)
  FROM request_processing rp
  WHERE rp.request_number=3091000
  DETAIL
   max_seq = sequence
  WITH nocounter
 ;end select
 SET max_seq = (max_seq+ 1)
 INSERT  FROM request_processing rp
  SET rp.request_number = 3091000, rp.sequence = max_seq, rp.target_request_number = 0,
   rp.format_script = "PFMT_BSC_CALC_END_BAG", rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp
   .updt_id = reqinfo->updt_id,
   rp.updt_task = reqinfo->updt_task, rp.updt_cnt = 0, rp.updt_applctx = reqinfo->updt_applctx,
   rp.service = "", rp.forward_override_ind = 0, rp.destination_step_id = 0,
   rp.reprocess_reply_ind = 0, rp.active_ind = 1
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert row into request_processing: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
