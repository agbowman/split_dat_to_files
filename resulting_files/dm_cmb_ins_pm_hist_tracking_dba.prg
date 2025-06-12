CREATE PROGRAM dm_cmb_ins_pm_hist_tracking:dba
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 INSERT  FROM pm_hist_tracking h
  SET h.pm_hist_tracking_id = dcipht_request->pm_hist_tracking_id, h.encntr_id = dcipht_request->
   encntr_id, h.person_id = dcipht_request->person_id,
   h.transaction_dt_tm = cnvtdatetime(curdate,curtime3), h.transaction_type_txt = dcipht_request->
   transaction_type_txt, h.transaction_reason_txt = dcipht_request->transaction_reason_txt,
   h.create_dt_tm = cnvtdatetime(curdate,curtime3), h.create_prsnl_id = reqinfo->updt_id, h
   .create_task = reqinfo->updt_task,
   h.updt_applctx = reqinfo->updt_applctx, h.updt_id = reqinfo->updt_id, h.updt_task = reqinfo->
   updt_task,
   h.updt_dt_tm = cnvtdatetime(curdate,curtime3), h.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (error(dcipht_reply->err_msg,1) != 0)
  SET dcipht_reply->status = "F"
 ELSE
  SET dcipht_reply->status = "S"
 ENDIF
END GO
