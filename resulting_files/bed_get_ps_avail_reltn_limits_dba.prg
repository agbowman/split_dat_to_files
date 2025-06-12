CREATE PROGRAM bed_get_ps_avail_reltn_limits:dba
 FREE SET reply
 RECORD reply(
   1 reltns[*]
     2 display = vc
     2 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET reltn_limit = 0
 SELECT INTO "nl:"
  FROM code_set_extension c
  PLAN (c
   WHERE c.code_set=40
    AND c.field_name="FAMILY_RELTN_IND")
  DETAIL
   reltn_limit = 1
  WITH nocounter
 ;end select
 IF (reltn_limit=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_extension e,
   code_value c1,
   code_value_group g,
   code_value c2
  PLAN (e
   WHERE e.code_set=40
    AND e.field_name="FAMILY_RELTN_IND"
    AND e.field_value="Y")
   JOIN (c1
   WHERE c1.code_value=e.code_value)
   JOIN (g
   WHERE g.parent_code_value=outerjoin(c1.code_value)
    AND g.code_set=outerjoin(387571))
   JOIN (c2
   WHERE c2.code_value=outerjoin(g.child_code_value))
  ORDER BY c1.display, c2.display
  HEAD c1.display
   rcnt = (rcnt+ 1), stat = alterlist(reply->reltns,rcnt), reply->reltns[rcnt].display = trim(c1
    .display),
   reply->reltns[rcnt].value = build("R",trim(cnvtstring(c1.code_value,20)),"F0")
  DETAIL
   IF (c2.display > " ")
    rcnt = (rcnt+ 1), stat = alterlist(reply->reltns,rcnt), reply->reltns[rcnt].display = concat(trim
     (c1.display)," - ",trim(c2.display)),
    reply->reltns[rcnt].value = build("R",trim(cnvtstring(c1.code_value,20)),"F",trim(cnvtstring(c2
       .code_value,20)))
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
