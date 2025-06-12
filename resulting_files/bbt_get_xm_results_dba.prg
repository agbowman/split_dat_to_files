CREATE PROGRAM bbt_get_xm_results:dba
 RECORD reply(
   1 qual[1]
     2 product_event_id = f8
     2 xm_result_value_alpha = c20
     2 xm_result_event_prsnl_username = c20
     2 xm_result_event_dt_tm = dq8
     2 xm_expire_dt_tm = dq8
     2 accession = c20
     2 mnemonic_key_cap = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET bb_processing_code_set = 1636
 SET xm_interp_cdf_meaing = "               "
 SET xm_interp_cdf_meaning = "HISTRY & UPD"
 SET result_stat_code_set = 1901
 SET verified_status_cdf_meaning = "               "
 SET corrected_status_cdf_meaning = "               "
 SET verified_status_cdf_meaning = "VERIFIED"
 SET corrected_status_cdf_meaning = "CORRECTED"
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET event_cnt = 0
 SET result_cnt = 0
 SET xm_interp_cd = 0.0
 SET cv_cnt = 0
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
#begin_main
 SET reply->status_data.status = "I"
 SET event_cnt = cnvtint(size(request->eventlist,5))
 SET stat = alter(reply->qual,event_cnt)
 SET xm_interp_cd = 0.0
 SET xm_interp_cd = get_code_value(bb_processing_code_set,xm_interp_cdf_meaning)
 IF (xm_interp_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get xm_interp code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get xm_interp code_value"
 ELSE
  SET cv_cnt = 0
  SET verified_status_cd = get_code_value(result_stat_code_set,verified_status_cdf_meaning)
  SET corrected_status_cd = get_code_value(result_stat_code_set,corrected_status_cdf_meaning)
  IF (((verified_status_cd=0.0) OR (corrected_status_cd=0.0)) )
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname =
   "get verified/corrected status code_value"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_tag_print_ctrl"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get verified/corrected status code_value"
  ELSE
   SELECT INTO "nl:"
    pe.order_id, pe.bb_result_id, xm.crossmatch_exp_dt_tm,
    r.result_id, r.task_assay_cd, dta.bb_result_processing_cd,
    pr.result_value_alpha, re.event_dt_tm, re.event_personnel_id,
    pnl.username, aor.accession
    FROM (dummyt d  WITH seq = value(event_cnt)),
     product_event pe,
     crossmatch xm,
     result r,
     discrete_task_assay dta,
     perform_result pr,
     result_event re,
     prsnl pnl,
     (dummyt d_aor  WITH seq = 1),
     accession_order_r aor
    PLAN (d)
     JOIN (pe
     WHERE (pe.product_event_id=request->eventlist[d.seq].product_event_id))
     JOIN (xm
     WHERE xm.product_event_id=pe.product_event_id)
     JOIN (r
     WHERE r.bb_result_id=pe.bb_result_id
      AND r.order_id=pe.order_id)
     JOIN (dta
     WHERE dta.task_assay_cd=r.task_assay_cd
      AND dta.bb_result_processing_cd=xm_interp_cd)
     JOIN (pr
     WHERE pr.result_id=r.result_id
      AND ((pr.result_status_cd=verified_status_cd) OR (pr.result_status_cd=corrected_status_cd)) )
     JOIN (re
     WHERE re.result_id=r.result_id
      AND re.perform_result_id=pr.perform_result_id
      AND re.event_type_cd=pr.result_status_cd)
     JOIN (pnl
     WHERE pnl.person_id=re.event_personnel_id)
     JOIN (d_aor
     WHERE d_aor.seq=1)
     JOIN (aor
     WHERE aor.order_id=pe.order_id
      AND aor.primary_flag=0)
    DETAIL
     result_cnt += 1, reply->qual[d.seq].product_event_id = pe.product_event_id, reply->qual[d.seq].
     xm_result_value_alpha = pr.result_value_alpha,
     reply->qual[d.seq].xm_result_event_prsnl_username = pnl.username, reply->qual[d.seq].
     xm_result_event_dt_tm = re.event_dt_tm, reply->qual[d.seq].xm_expire_dt_tm = xm
     .crossmatch_exp_dt_tm,
     reply->qual[d.seq].accession = aor.accession, reply->qual[d.seq].mnemonic_key_cap = dta
     .mnemonic_key_cap
    WITH nocounter, outerjoin(d_aor)
   ;end select
   IF (curqual=0)
    SET count1 += 1
    IF (count1 > size(reply->status_data.subeventstatus,5))
     SET stat = alter(reply->status_data,count1)
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "get xm_results"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_xm_results"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = ""
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
#end_main
#exit_script
 IF ((reply->status_data.status != "F"))
  SET count1 += 1
  IF (count1 > size(reply->status_data.subeventstatus,5))
   SET stat = alter(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_xm_results"
  IF (result_cnt=event_cnt)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "crossmatch results found for all crossmatch events"
   SET reply->status_data.subeventstatus[count1].operationname = "Success"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  ELSE
   IF (result_cnt > 0)
    SET reply->status_data.status = "P"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue =
    "WARNING:  Crossmatch results not fould for all crossmatch events"
    SET reply->status_data.subeventstatus[count1].operationname = "Zero"
    SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   ELSE
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue =
    "WARNING:  No crossmatch results found for any crossmatch events"
    SET reply->status_data.subeventstatus[count1].operationname = "Zero"
    SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   ENDIF
  ENDIF
 ENDIF
END GO
