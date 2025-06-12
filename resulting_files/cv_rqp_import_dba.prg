CREATE PROGRAM cv_rqp_import:dba
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
 SET readme_data->message = "Readme Failed: Starting script cv_rqp_import..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE isrp = i2 WITH protect, noconstant(0)
 DECLARE iscvnet = i2 WITH protect, noconstant(0)
 DECLARE maxseq = i4 WITH protect, noconstant(0)
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 FREE RECORD atr_chg_request
 RECORD atr_chg_request(
   1 request_number = i4
   1 qual[*]
     2 sequence = i4
     2 target_request_number = i4
     2 format_script = c30
     2 service = vc
     2 forward_override_ind = i2
     2 reprocess_reply_ind = i2
     2 active_ind = i2
     2 destination_step_id = f8
     2 updt_cnt = i4
 )
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE cd.dataset_id != 0.0
   AND cd.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET iscvnet = 1
 ENDIF
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=114001
   AND ((rp.format_script IN ("PFMT_E_CV_GET_DISCH_DT_TM", "PFMT_CHK_CV_GET_DISCH_DT_TM")) OR (rp
  .target_request_number=4100512))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(atr_chg_request->qual,(cnt+ 9))
   ENDIF
   atr_chg_request->qual[cnt].sequence = rp.sequence, atr_chg_request->qual[cnt].
   target_request_number = rp.target_request_number, atr_chg_request->qual[cnt].format_script = rp
   .format_script,
   atr_chg_request->qual[cnt].service = rp.service, atr_chg_request->qual[cnt].forward_override_ind
    = rp.forward_override_ind, atr_chg_request->qual[cnt].reprocess_reply_ind = rp
   .reprocess_reply_ind,
   atr_chg_request->qual[cnt].active_ind = 0, atr_chg_request->qual[cnt].destination_step_id = rp
   .destination_step_id, atr_chg_request->qual[cnt].updt_cnt = rp.updt_cnt
   IF (rp.active_ind=1)
    isrp = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(atr_chg_request->qual,cnt), atr_chg_request->request_number = 114001
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = concat("Readme failed to select processing for request 114001: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (((cnt=0) OR (curqual=0)) )
  SET readme_data->message = "Select did not return processing items for request 114001."
 ELSE
  EXECUTE atr_chg_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to delete processing for request 114001: ",errmsg
    )
   GO TO exit_script
  ENDIF
 ENDIF
 SET atr_chg_request->request_number = 0
 SET stat = alterlist(atr_chg_request->qual,0)
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=3091000
   AND ((rp.format_script IN ("PFMT_CV_SUMMARY_DATA", "PFMT_CHK_CV_SUMMARY_DATA")) OR (rp
  .target_request_number=4100510))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(atr_chg_request->qual,(cnt+ 9))
   ENDIF
   atr_chg_request->qual[cnt].sequence = rp.sequence, atr_chg_request->qual[cnt].
   target_request_number = rp.target_request_number, atr_chg_request->qual[cnt].format_script = rp
   .format_script,
   atr_chg_request->qual[cnt].service = rp.service, atr_chg_request->qual[cnt].forward_override_ind
    = rp.forward_override_ind, atr_chg_request->qual[cnt].reprocess_reply_ind = rp
   .reprocess_reply_ind,
   atr_chg_request->qual[cnt].active_ind = 0, atr_chg_request->qual[cnt].destination_step_id = rp
   .destination_step_id, atr_chg_request->qual[cnt].updt_cnt = rp.updt_cnt
   IF (rp.active_ind=1)
    isrp = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(atr_chg_request->qual,cnt), atr_chg_request->request_number = 3091000
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = concat("Readme failed to select processing for request 3091000: ",errmsg
   )
  GO TO exit_script
 ENDIF
 IF (((cnt=0) OR (curqual=0)) )
  SET readme_data->message = "Select did not return processing items for request 3091000."
 ELSE
  EXECUTE atr_chg_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to delete processing for request 3091000: ",
    errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET atr_chg_request->request_number = 0
 SET stat = alterlist(atr_chg_request->qual,0)
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=600353
   AND ((rp.format_script IN ("PFMT_CV_FORM_CHARTED", "PFMT_CHK_CV_FORM_CHARTED")) OR (rp
  .target_request_number=4100511))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(atr_chg_request->qual,(cnt+ 9))
   ENDIF
   atr_chg_request->qual[cnt].sequence = rp.sequence, atr_chg_request->qual[cnt].
   target_request_number = rp.target_request_number, atr_chg_request->qual[cnt].format_script = rp
   .format_script,
   atr_chg_request->qual[cnt].service = rp.service, atr_chg_request->qual[cnt].forward_override_ind
    = rp.forward_override_ind, atr_chg_request->qual[cnt].reprocess_reply_ind = rp
   .reprocess_reply_ind,
   atr_chg_request->qual[cnt].active_ind = 0, atr_chg_request->qual[cnt].destination_step_id = rp
   .destination_step_id, atr_chg_request->qual[cnt].updt_cnt = rp.updt_cnt
   IF (rp.active_ind=1)
    isrp = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(atr_chg_request->qual,cnt), atr_chg_request->request_number = 600353
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = concat("Readme failed to select processing for request 600353: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (((cnt=0) OR (curqual=0)) )
  SET readme_data->message = "Select did not return processing items for request 600353."
 ELSE
  EXECUTE atr_chg_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to delete processing for request 600353: ",errmsg
    )
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 IF (((iscvnet=0) OR (isrp=0)) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme succeeded: All CVNet request processing rows inactivated"
  GO TO exit_script
 ENDIF
 SET atr_chg_request->request_number = 0
 SET stat = alterlist(atr_chg_request->qual,0)
 SET stat = alterlist(atr_chg_request->qual,1)
 SET atr_chg_request->request_number = 114001
 SET atr_chg_request->qual[1].format_script = "PFMT_E_CV_GET_DISCH_DT_TM"
 SET atr_chg_request->qual[1].target_request_number = 4100512
 SET atr_chg_request->qual[1].service = "CPMSCRIPTASYNC002"
 SET atr_chg_request->qual[1].destination_step_id = 6040.0
 SET atr_chg_request->qual[1].active_ind = 1
 SET atr_chg_request->qual[1].forward_override_ind = 0
 SET atr_chg_request->qual[1].reprocess_reply_ind = 0
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=114001
   AND rp.format_script="PFMT_E_CV_GET_DISCH_DT_TM"
   AND rp.target_request_number=4100512
   AND rp.service="CPMSCRIPTASYNC002"
   AND rp.destination_step_id=6040.0
  DETAIL
   atr_chg_request->qual[1].sequence = rp.sequence, atr_chg_request->qual[1].updt_cnt = rp.updt_cnt
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = concat("Readme failed to select processing for request 114001: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SELECT INTO "nl:"
   x1 = max(r.sequence)
   FROM request_processing r
   WHERE r.request_number=114001
   DETAIL
    maxseq = x1
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to select maximum sequence from request 114001: ",
    errmsg)
   GO TO exit_script
  ENDIF
  SET atr_chg_request->qual[1].sequence = (maxseq+ 1)
  EXECUTE atr_add_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to add processing for request 114001: ",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  EXECUTE atr_chg_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to change processing for request 114001: ",errmsg
    )
   GO TO exit_script
  ENDIF
 ENDIF
 SET atr_chg_request->request_number = 0
 SET stat = alterlist(atr_chg_request->qual,0)
 SET stat = alterlist(atr_chg_request->qual,1)
 SET atr_chg_request->request_number = 3091000
 SET atr_chg_request->qual[1].format_script = "PFMT_CV_SUMMARY_DATA"
 SET atr_chg_request->qual[1].target_request_number = 4100510
 SET atr_chg_request->qual[1].service = "CPMSCRIPTASYNC002"
 SET atr_chg_request->qual[1].destination_step_id = 6040.0
 SET atr_chg_request->qual[1].active_ind = 1
 SET atr_chg_request->qual[1].forward_override_ind = 0
 SET atr_chg_request->qual[1].reprocess_reply_ind = 0
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=3091000
   AND rp.format_script="PFMT_CV_SUMMARY_DATA"
   AND rp.target_request_number=4100510
   AND rp.service="CPMSCRIPTASYNC002"
   AND rp.destination_step_id=6040.0
  DETAIL
   atr_chg_request->qual[1].sequence = rp.sequence, atr_chg_request->qual[1].updt_cnt = rp.updt_cnt
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = concat("Readme failed to select processing for request 3091000: ",errmsg
   )
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SELECT INTO "nl:"
   x1 = max(r.sequence)
   FROM request_processing r
   WHERE r.request_number=3091000
   DETAIL
    maxseq = x1
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat(
    "Readme failed to select maximum sequence from request 3091000: ",errmsg)
   GO TO exit_script
  ENDIF
  SET atr_chg_request->qual[1].sequence = (maxseq+ 1)
  EXECUTE atr_add_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to add processing for request 3091000: ",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  EXECUTE atr_chg_req_proc  WITH replace("REQUEST","ATR_CHG_REQUEST")
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Readme failed to change processing for request 3091000: ",
    errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme succeeded: All CVNet request processing rows updated"
#exit_script
 IF ((readme_data->status != "F"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 DECLARE cv_rqp_import_vrsn = vc WITH private, constant("MOD 001 BM9013 11/06/06")
END GO
