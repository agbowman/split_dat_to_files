CREATE PROGRAM bed_get_res_dup_sch_resource:dba
 FREE SET reply
 RECORD reply(
   1 dups[*]
     2 mnemonic = vc
     2 sch_resource_code_value = f8
     2 service_resource_code_value = f8
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_dups
 RECORD temp_dups(
   1 dups[*]
     2 sch_resource_code_value = f8
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET req_cnt = size(request->check_list,5)
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=14231
     AND cv.display_key=trim(cnvtupper(cnvtalphanum(request->check_list[d.seq].mnemonic)))
     AND (cv.code_value != request->check_list[d.seq].sch_resource_code_value))
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(temp_dups->dups,100)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(temp_dups->dups,(tot_cnt+ 100)), cnt = 1
    ENDIF
    temp_dups->dups[tot_cnt].sch_resource_code_value = cv.code_value
   FOOT REPORT
    stat = alterlist(temp_dups->dups,tot_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_cnt),
    sch_resource s
   PLAN (d)
    JOIN (s
    WHERE s.mnemonic_key=trim(cnvtupper(request->check_list[d.seq].mnemonic))
     AND (s.resource_cd != request->check_list[d.seq].sch_resource_code_value))
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(temp_dups->dups,100)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(temp_dups->dups,(tot_cnt+ 100)), cnt = 1
    ENDIF
    temp_dups->dups[tot_cnt].sch_resource_code_value = s.resource_cd
   FOOT REPORT
    stat = alterlist(temp_dups->dups,tot_cnt)
   WITH nocounter
  ;end select
  IF (tot_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt),
     sch_resource s
    PLAN (d)
     JOIN (s
     WHERE (s.resource_cd=temp_dups->dups[d.seq].sch_resource_code_value)
      AND s.active_ind=1)
    ORDER BY s.resource_cd
    HEAD REPORT
     rcnt = 0, rtot_cnt = 0, stat = alterlist(reply->dups,10)
    HEAD s.resource_cd
     rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
     IF (rcnt > 10)
      stat = alterlist(reply->dups,(rtot_cnt+ 10)), rcnt = 1
     ENDIF
     reply->dups[rtot_cnt].mnemonic = request->check_list[d.seq].mnemonic, reply->dups[rtot_cnt].
     service_resource_code_value = s.service_resource_cd, reply->dups[rtot_cnt].person_id = s
     .person_id,
     reply->dups[rtot_cnt].sch_resource_code_value = s.resource_cd
    FOOT REPORT
     stat = alterlist(reply->dups,rtot_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
