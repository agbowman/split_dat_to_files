CREATE PROGRAM da_get_questionnaires:dba
 DECLARE count = i4 WITH protect
 DECLARE max = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE msg = vc WITH protect
 SELECT
  IF ((request->val2=""))
   WHERE q.questionnaire_id != 0
  ELSE
   WHERE q.questionnaire_id != 0
    AND (q.entity_name=request->val2)
  ENDIF
  INTO "nl:"
  q.questionnaire_id, q.questionnaire_name
  FROM pm_qst_questionnaire q
  HEAD REPORT
   count = 0, max = 0
  DETAIL
   count = (count+ 1)
   IF (count > max)
    max = (max+ 100), stat = alterlist(reply->datacoll,max)
   ENDIF
   reply->datacoll[count].currcv = cnvtstring(q.questionnaire_id), reply->datacoll[count].description
    = q.questionnaire_name
  FOOT REPORT
   stat = alterlist(reply->datacoll,count)
  WITH nocounter, maxrec = 65535
 ;end select
 IF (error(msg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = " "
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = " "
  SET reply->status_data.subeventstatus[1].targetobjectvalue = msg
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
