CREATE PROGRAM ct_get_eqb_valid_for_activate:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE qns_cnt = i2 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 CALL echo(enrolling_cd)
 CALL echo(request->prot_amendment_id)
 SELECT INTO "nl:"
  peq.prot_elig_quest_id
  FROM prot_elig_quest peq,
   prot_questionnaire pq
  PLAN (pq
   WHERE (pq.prot_amendment_id=request->prot_amendment_id)
    AND pq.questionnaire_type_cd=enrolling_cd
    AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (peq
   WHERE peq.prot_questionnaire_id=pq.prot_questionnaire_id
    AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   qns_cnt = (qns_cnt+ 1)
  WITH nocounter
 ;end select
 CALL echo(qns_cnt)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(build("Validity=",reply->status_data.status))
 SET last_mod = "003"
 SET mod_date = "August 20, 2007"
END GO
