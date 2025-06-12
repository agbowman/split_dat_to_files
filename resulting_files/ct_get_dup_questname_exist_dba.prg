CREATE PROGRAM ct_get_dup_questname_exist:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 CALL echo(request->questionnaire_name)
 SELECT INTO "nl:"
  FROM prot_questionnaire pq
  WHERE (pq.prot_amendment_id=request->prot_amendment_id)
   AND trim(cnvtupper(pq.questionnaire_name))=trim(cnvtupper(request->questionnaire_name))
   AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND (pq.prot_questionnaire_id != request->prot_questionnaire_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "December 14, 2007"
END GO
