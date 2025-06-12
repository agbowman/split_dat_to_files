CREATE PROGRAM bed_get_phys_exp_history:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 results[*]
      2 topic_name = vc
      2 position_code_value = f8
      2 preference_name = vc
      2 transaction_dt_tm = dq8
      2 previous_value = vc
      2 new_value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE requestcount = i4 WITH constant(size(request->criterias,5))
 DECLARE count = i4 WITH noconstant(0)
 DECLARE tempcount = i4 WITH noconstant(0)
 IF (requestcount=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = requestcount),
   br_phys_exper_history br
  PLAN (d)
   JOIN (br
   WHERE (br.position_cd=request->criterias[d.seq].position_code_value)
    AND (((request->criterias[d.seq].topic_name > " ")
    AND (br.topic_name=request->criterias[d.seq].topic_name)) OR (br.topic_name > " "
    AND (request->criterias[d.seq].topic_name IN ("", " ", null))))
    AND (((request->criterias[d.seq].preference_name > " ")
    AND (br.preference_name=request->criterias[d.seq].preference_name)) OR (br.preference_name > " "
    AND (request->criterias[d.seq].preference_name IN ("", " ", null)))) )
  ORDER BY br.position_cd, br.topic_name, br.preference_name,
   br.transaction_dt_tm DESC
  HEAD REPORT
   count = 0, tempcount = 0, stat = alterlist(reply->results,10)
  HEAD br.position_cd
   stat = 0
  HEAD br.topic_name
   stat = 0
  HEAD br.preference_name
   count = (count+ 1), tempcount = (tempcount+ 1)
   IF (tempcount > 10)
    tempcount = 0, stat = alterlist(reply->results,(count+ 10))
   ENDIF
   reply->results[count].new_value = br.new_value, reply->results[count].position_code_value = br
   .position_cd, reply->results[count].preference_name = br.preference_name,
   reply->results[count].previous_value = br.previous_value, reply->results[count].topic_name = br
   .topic_name, reply->results[count].transaction_dt_tm = br.transaction_dt_tm
  FOOT REPORT
   stat = alterlist(reply->results,count)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting from br_phys_exper_history")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
