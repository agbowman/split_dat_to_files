CREATE PROGRAM bed_get_ic_organisms_detail:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 organisms[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 has_children = i2
      2 group_id = f8
      2 active_ind = i2
      2 org_class_flag = i2
      2 has_suppressions = i2
      2 has_disclaimers = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET org_request
 RECORD org_request(
   1 parent_code_value = f8
 )
 FREE SET org_reply
 RECORD org_reply(
   1 organisms[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 has_children = i2
     2 group_id = f8
     2 active_ind = i2
     2 org_class_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET org_request->parent_code_value = request->parent_code_value
 EXECUTE bed_get_ic_organisms  WITH replace("REQUEST",org_request), replace("REPLY",org_reply)
 IF ((org_reply->status_data.status="F"))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "error in organisms"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = org_reply->status_data.subeventstatus[
  1].targetobjectvalue
  CALL echorecord(org_reply)
  GO TO exit_script
 ENDIF
 SET org_size = size(org_reply->organisms,5)
 IF (org_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->organisms,org_size)
 FOR (o = 1 TO org_size)
   SET reply->organisms[o].active_ind = org_reply->organisms[o].active_ind
   SET reply->organisms[o].code_value = org_reply->organisms[o].code_value
   SET reply->organisms[o].description = org_reply->organisms[o].description
   SET reply->organisms[o].display = org_reply->organisms[o].display
   SET reply->organisms[o].group_id = org_reply->organisms[o].group_id
   SET reply->organisms[o].has_children = org_reply->organisms[o].has_children
   SET reply->organisms[o].org_class_flag = org_reply->organisms[o].org_class_flag
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(org_size)),
   lh_cnt_ic_antibgrm_org_dsc l
  PLAN (d)
   JOIN (l
   WHERE (l.facility_cd=request->facility_code_value)
    AND (l.organism_cd=reply->organisms[d.seq].code_value))
  DETAIL
   IF (l.suppress_ind=1)
    reply->organisms[d.seq].has_suppressions = 1
   ENDIF
   IF (l.long_text_id > 0.0)
    reply->organisms[d.seq].has_disclaimers = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
