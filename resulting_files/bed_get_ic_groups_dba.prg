CREATE PROGRAM bed_get_ic_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 groups[*]
      2 group_id = f8
      2 group_name = vc
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
 DECLARE tcnt = i4 WITH protect
 SELECT INTO "nl:"
  FROM lh_cnt_ic_antibgrm_group g
  PLAN (g
   WHERE (g.group_type_flag=request->group_type_flag))
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->groups,100)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->groups,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->groups[tcnt].group_id = g.lh_cnt_ic_antibgrm_group_id, reply->groups[tcnt].group_name = g
   .group_name
  FOOT REPORT
   stat = alterlist(reply->groups,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failure retrieving groups")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
