CREATE PROGRAM bed_ens_pp_placehldr_cleanup:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_placeholder
 RECORD temp_placeholder(
   1 placeholders[*]
     2 id = f8
 )
 FREE SET temp_reltn
 RECORD temp_reltn(
   1 reltns[*]
     2 id = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM br_pw_comp_placehldr_r r
  PLAN (r
   WHERE  NOT ( EXISTS (
   (SELECT
    p.pathway_comp_id
    FROM pathway_comp p
    WHERE p.pathway_uuid=r.pathway_uuid
     AND p.parent_entity_name="LONG_TEXT")))
    AND r.br_pw_comp_placehldr_r_id > 0.0)
  ORDER BY r.br_pw_comp_placehldr_r_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp_reltn->reltns,10)
  HEAD r.br_pw_comp_placehldr_r_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp_reltn->reltns,(tcnt+ 10)), cnt = 1
   ENDIF
   temp_reltn->reltns[tcnt].id = r.br_pw_comp_placehldr_r_id
  FOOT REPORT
   stat = alterlist(temp_reltn->reltns,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SET ierrcode = 0
  DELETE  FROM br_pw_comp_placehldr_r r,
    (dummyt d  WITH seq = value(tcnt))
   SET r.seq = 1
   PLAN (d)
    JOIN (r
    WHERE (r.br_pw_comp_placehldr_r_id=temp_reltn->reltns[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error deleting relations",serrmsg)
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM br_pw_comp_placehldr b
  PLAN (b
   WHERE  NOT ( EXISTS (
   (SELECT
    r.br_pw_comp_placehldr_r_id
    FROM br_pw_comp_placehldr_r r
    WHERE r.br_pw_comp_placehldr_id=b.br_pw_comp_placehldr_id)))
    AND b.br_pw_comp_placehldr_id > 0.0)
  ORDER BY b.br_pw_comp_placehldr_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp_placeholder->placeholders,10)
  HEAD b.br_pw_comp_placehldr_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp_placeholder->placeholders,(tcnt+ 10)), cnt = 1
   ENDIF
   temp_placeholder->placeholders[tcnt].id = b.br_pw_comp_placehldr_id
  FOOT REPORT
   stat = alterlist(temp_placeholder->placeholders,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SET ierrcode = 0
  DELETE  FROM br_pw_comp_placehldr b,
    (dummyt d  WITH seq = value(tcnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_pw_comp_placehldr_id=temp_placeholder->placeholders[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error deleting placeholders",serrmsg)
  ENDIF
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
