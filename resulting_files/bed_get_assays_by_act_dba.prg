CREATE PROGRAM bed_get_assays_by_act:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 mnemonic = vc
     2 description = vc
     2 act_type_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET req_size = size(request->activity_types,5)
 IF (req_size > 0)
  SELECT INTO "nl:"
   FROM discrete_task_assay dta,
    (dummyt d  WITH seq = value(req_size))
   PLAN (d)
    JOIN (dta
    WHERE (dta.activity_type_cd=request->activity_types[d.seq].act_type_code_value)
     AND dta.active_ind=1)
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->assays,100)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->assays,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->assays[tot_cnt].code_value = dta.task_assay_cd, reply->assays[tot_cnt].mnemonic = dta
    .mnemonic, reply->assays[tot_cnt].description = dta.description,
    reply->assays[tot_cnt].act_type_code_value = dta.activity_type_cd
   FOOT REPORT
    stat = alterlist(reply->assays,tot_cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
