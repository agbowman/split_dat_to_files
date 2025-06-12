CREATE PROGRAM bmdi_get_event_task_assay:dba
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 concept_cki = vc
     2 taskassayqual[*]
       3 task_assay_cd = f8
       3 task_assay_display = vc
     2 eventsqual[*]
       3 event_cd = f8
       3 event_display = vc
     2 resulttypequal[*]
       3 result_type_cd = f8
       3 result_type_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE event_code_set = i4 WITH protect, noconstant(72)
 DECLARE dta_code_set = i4 WITH protect, noconstant(14003)
 DECLARE event_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET qual_cnt = size(request->qual,5)
 SET stat = alterlist(reply->codes,qual_cnt)
 FOR (i = 1 TO qual_cnt)
   SET event_cnt = 0
   SET reply->codes[i].concept_cki = request->qual[i].concept_cki
   SELECT INTO "nl:"
    FROM code_value cv1
    WHERE cv1.code_set=event_code_set
     AND (cv1.concept_cki=request->qual[i].concept_cki)
    DETAIL
     event_cnt += 1, stat = alterlist(reply->codes[i].eventsqual,event_cnt), reply->codes[i].
     eventsqual[event_cnt].event_cd = cv1.code_value,
     reply->codes[i].eventsqual[event_cnt].event_display = uar_get_code_display(cv1.code_value)
    WITH nocounter
   ;end select
   SET event_cnt = 0
   SELECT INTO "nl:"
    FROM code_value cv2,
     discrete_task_assay dta
    PLAN (cv2
     WHERE cv2.code_set=dta_code_set
      AND (cv2.concept_cki=request->qual[i].concept_cki))
     JOIN (dta
     WHERE (dta.task_assay_cd= Outerjoin(cv2.code_value))
      AND (dta.concept_cki= Outerjoin(cv2.concept_cki)) )
    DETAIL
     event_cnt += 1, stat = alterlist(reply->codes[i].taskassayqual,event_cnt), reply->codes[i].
     taskassayqual[event_cnt].task_assay_cd = cv2.code_value,
     reply->codes[i].taskassayqual[event_cnt].task_assay_display = uar_get_code_display(cv2
      .code_value), ml_loc = locatevalsort(ml_idx,1,size(reply->codes[i].resulttypequal,5),dta
      .default_result_type_cd,reply->codes[i].resulttypequal[ml_idx].result_type_cd), ml_loc = abs(
      ml_loc)
     IF (dta.default_result_type_cd > 0
      AND ml_loc <= 0)
      stat = alterlist(reply->codes[i].resulttypequal,event_cnt), reply->codes[i].resulttypequal[
      event_cnt].result_type_cd = dta.default_result_type_cd, reply->codes[i].resulttypequal[
      event_cnt].result_type_display = uar_get_code_display(dta.default_result_type_cd)
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
END GO
