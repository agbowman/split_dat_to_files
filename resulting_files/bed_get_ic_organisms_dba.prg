CREATE PROGRAM bed_get_ic_organisms:dba
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
  FROM mic_organism_data m,
   code_value c
  PLAN (m
   WHERE (m.parent_cd=request->parent_code_value)
    AND m.organism_id > 0)
   JOIN (c
   WHERE c.code_value=m.organism_id)
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->organisms,100)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    cnt = 1, stat = alterlist(reply->organisms,(tcnt+ 100))
   ENDIF
   reply->organisms[tcnt].code_value = c.code_value, reply->organisms[tcnt].display = c.display,
   reply->organisms[tcnt].description = c.description,
   reply->organisms[tcnt].active_ind = c.active_ind, reply->organisms[tcnt].org_class_flag = m
   .org_class_flag
  FOOT REPORT
   stat = alterlist(reply->organisms,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("error on orgs")
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   mic_organism_data m,
   code_value c
  PLAN (d)
   JOIN (m
   WHERE (m.parent_cd=reply->organisms[d.seq].code_value))
   JOIN (c
   WHERE c.code_value=m.organism_id)
  ORDER BY d.seq
  HEAD d.seq
   reply->organisms[d.seq].has_children = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("error on child check")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   lh_cnt_ic_antibgrm_group g,
   lh_cnt_ic_antibgrm_group_r r
  PLAN (d)
   JOIN (r
   WHERE r.parent_entity_name="CODE_VALUE"
    AND (r.parent_entity_id=reply->organisms[d.seq].code_value))
   JOIN (g
   WHERE g.lh_cnt_ic_antibgrm_group_id=r.lh_cnt_ic_antibgrm_group_id
    AND g.group_type_flag=1)
  ORDER BY d.seq
  HEAD d.seq
   reply->organisms[d.seq].group_id = g.lh_cnt_ic_antibgrm_group_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("error on group check")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
