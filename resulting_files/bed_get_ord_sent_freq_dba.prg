CREATE PROGRAM bed_get_ord_sent_freq:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 freqs[*]
      2 freq_code_value = f8
      2 display = vc
      2 meaning = vc
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
 DECLARE activity_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE (ocs.synonym_id=request->uid))
  DETAIL
   activity_cd = ocs.activity_type_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrieve activity type from order_catalog_synonym table.")
 IF (activity_cd > 0.0)
  SELECT INTO "nl:"
   FROM code_value_group cvg,
    code_value cv
   PLAN (cvg
    WHERE cvg.parent_code_value=activity_cd)
    JOIN (cv
    WHERE cv.code_set=4003
     AND cv.code_value=cvg.child_code_value
     AND cv.active_ind=1)
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->freqs,100)
   DETAIL
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->freqs,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->freqs[tot_cnt].freq_code_value = cv.code_value, reply->freqs[tot_cnt].display = cv.display,
    reply->freqs[tot_cnt].meaning = cv.cdf_meaning
   FOOT REPORT
    stat = alterlist(reply->freqs,tot_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed to retrieve frequencies from code_set")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
