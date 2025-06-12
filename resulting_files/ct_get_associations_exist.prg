CREATE PROGRAM ct_get_associations_exist
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
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE qualcount = i4 WITH protect, noconstant(0)
 DECLARE reltncount = i4 WITH protect, noconstant(0)
 DECLARE questid = f8 WITH protect, noconstant(0.0)
 RECORD temp(
   1 qual[*]
     2 prot_questionnaire_id = i4
 )
 SET bstat = alterlist(temp->qual,(count+ 1))
 SELECT INTO "nl:"
  pq.prot_questionnaire_id
  FROM prot_questionnaire pq
  WHERE (pq.prot_amendment_id=request->prot_amendment_id)
   AND pq.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    bstat = alterlist(temp->qual,(count+ 9))
   ENDIF
   temp->qual[count].prot_questionnaire_id = pq.prot_questionnaire_id
  WITH nocounter
 ;end select
 SET bstat = alterlist(temp->qual,count)
 CALL echo(build("curqual after first query is = ",curqual))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET qualcount = cnvtint(size(temp->qual,5))
 CALL echo(build("qualcount is : ",qualcount))
 IF (qualcount > 0)
  SELECT INTO "nl:"
   qd.*
   FROM questionnaire_doc_reltn qd,
    (dummyt d  WITH seq = value(qualcount))
   PLAN (d)
    JOIN (qd
    WHERE (qd.prot_questionnaire_id=temp->qual[d.seq].prot_questionnaire_id)
     AND qd.active_ind=1)
   DETAIL
    CALL echo(build("prot_quest_id is = ",temp->qual[d.seq].prot_questionnaire_id)),
    CALL echo(build("QuestID is = ",questid))
    IF ((temp->qual[d.seq].prot_questionnaire_id != questid))
     reltncount = (reltncount+ 1),
     CALL echo(qd.questionnaire_doc_id)
    ENDIF
    questid = temp->qual[d.seq].prot_questionnaire_id
   WITH counter
  ;end select
  CALL echo(build("ReltnCount after second query is = ",reltncount))
  CALL echo(build("QualCount after second query is = ",qualcount))
  IF (reltncount != qualcount)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 SET last_mod = "000"
 SET mod_date = "October 10, 2007"
END GO
