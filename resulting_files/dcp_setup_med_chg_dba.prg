CREATE PROGRAM dcp_setup_med_chg:dba
 SET sequence = 0
 SET found = 0
 SET readme_data->message = build(
  "PVReadMe 1105 BEGIN:dcp_setup_med_chg:Updt so ProcesSvr hndls credit chrg on admin upon EvtEnsurs"
  )
 EXECUTE dm_readme_status
 COMMIT
 SELECT INTO "nl:"
  rp.sequence
  FROM request_processing rp
  WHERE rp.request_number=3091000
  DETAIL
   IF (rp.format_script="PFMT_DCP_MED_CHG")
    found = 1
   ENDIF
   IF (rp.sequence > sequence)
    sequence = rp.sequence
   ENDIF
  FOOT REPORT
   sequence = (sequence+ 1)
  WITH nocounter
 ;end select
 IF (found > 0)
  SET readme_data->status = "S"
  SET readme_data->message = build("PVReadMe 1105 FINISHED:Alredy set up, no update needed.")
  EXECUTE dm_readme_status
  COMMIT
  GO TO exit_script
 ENDIF
 INSERT  FROM request_processing rp
  SET rp.request_number = 3091000, rp.sequence = sequence, rp.target_request_number = 0,
   rp.format_script = "PFMT_DCP_MED_CHG", rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp.updt_id
    = 0,
   rp.updt_task = 0, rp.updt_applctx = 0, rp.updt_cnt = 0,
   rp.forward_override_ind = 0, rp.destination_step_id = 305615, rp.reprocess_reply_ind = 0,
   rp.active_ind = 1
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = build("PVReadMe 1105 FINISHED:Update Successfull.")
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = build("PVReadMe 1105 FINISHED:Update NOT Successfull.")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
#exit_script
END GO
