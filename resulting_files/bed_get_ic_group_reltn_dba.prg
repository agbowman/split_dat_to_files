CREATE PROGRAM bed_get_ic_group_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 groups[*]
      2 group_id = f8
      2 relations[*]
        3 reltn_id = f8
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 parent_entity_disp = vc
        3 parent_active_ind = i2
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
 SET req_size = size(request->groups,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->groups,req_size)
 FOR (x = 1 TO req_size)
   SET reply->groups[x].group_id = request->groups[x].group_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   lh_cnt_ic_antibgrm_group_r r,
   code_value c
  PLAN (d)
   JOIN (r
   WHERE (r.lh_cnt_ic_antibgrm_group_id=request->groups[d.seq].group_id)
    AND cnvtupper(r.parent_entity_name)="CODE_VALUE")
   JOIN (c
   WHERE c.code_value=r.parent_entity_id)
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->groups[d.seq].relations,10)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 1)
    stat = alterlist(reply->groups[d.seq].relations,(tcnt+ 10)), cnt = 1
   ENDIF
   reply->groups[d.seq].relations[tcnt].reltn_id = r.lh_cnt_ic_antibgrm_group_r_id, reply->groups[d
   .seq].relations[tcnt].parent_entity_id = c.code_value, reply->groups[d.seq].relations[tcnt].
   parent_entity_name = "CODE_VALUE",
   reply->groups[d.seq].relations[tcnt].parent_entity_disp = c.description, reply->groups[d.seq].
   relations[tcnt].parent_active_ind = c.active_ind
  FOOT  d.seq
   stat = alterlist(reply->groups[d.seq].relations,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failure retrieving reltns")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
