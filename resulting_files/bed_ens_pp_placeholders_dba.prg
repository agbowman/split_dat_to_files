CREATE PROGRAM bed_ens_pp_placeholders:dba
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
 FREE SET tempaddplaceholder
 RECORD tempaddplaceholder(
   1 placeholders[*]
     2 placeholder_id = f8
     2 placeholder_name = vc
     2 placeholder_type_flag = i2
 )
 FREE SET tempreltns
 RECORD tempreltns(
   1 placeholder_reltns[*]
     2 action_flag = i2
     2 placeholder_id = f8
     2 component_uuid = vc
     2 include_ind = i2
     2 required_ind = i2
 )
 DECLARE logerror(namemsg=vc,valuemsg=vc) = null
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET placeholdercountsize = size(request->placeholders,5)
 SET reltntotalsize = 0
 SET stat = alterlist(tempaddplaceholder->placeholders,placeholdercountsize)
 SET addplaceholdercnt = 0
 SET addreltncnt = 0
 FOR (phindex = 1 TO placeholdercountsize)
   IF ((request->placeholders[phindex].placeholder_id=0))
    SET addplaceholdercnt = (addplaceholdercnt+ 1)
    SET tempaddplaceholder->placeholders[addplaceholdercnt].placeholder_name = request->placeholders[
    phindex].placeholder_name
    SET tempaddplaceholder->placeholders[addplaceholdercnt].placeholder_type_flag = request->
    placeholders[phindex].placeholder_type_flag
    DECLARE placeholderid = f8
    SET placeholderid = 0
    SELECT INTO "nl:"
     tempid = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      placeholderid = cnvtreal(tempid)
     WITH nocounter
    ;end select
    SET request->placeholders[phindex].placeholder_id = placeholderid
    SET tempaddplaceholder->placeholders[addplaceholdercnt].placeholder_id = placeholderid
   ENDIF
   SET reltncountsize = size(request->placeholders[phindex].placeholder_reltns,5)
   SET stat = alterlist(tempreltns->placeholder_reltns,(reltntotalsize+ reltncountsize))
   FOR (reltnindex = 1 TO reltncountsize)
     SET reltntotalsize = (reltntotalsize+ 1)
     SET tempreltns->placeholder_reltns[reltntotalsize].placeholder_id = request->placeholders[
     phindex].placeholder_id
     SET tempreltns->placeholder_reltns[reltntotalsize].action_flag = request->placeholders[phindex].
     placeholder_reltns[reltnindex].action_flag
     SET tempreltns->placeholder_reltns[reltntotalsize].component_uuid = request->placeholders[
     phindex].placeholder_reltns[reltnindex].component_uuid
     SET tempreltns->placeholder_reltns[reltntotalsize].include_ind = request->placeholders[phindex].
     placeholder_reltns[reltnindex].include_ind
     SET tempreltns->placeholder_reltns[reltntotalsize].required_ind = request->placeholders[phindex]
     .placeholder_reltns[reltnindex].required_ind
   ENDFOR
 ENDFOR
 SET stat = alterlist(tempaddplaceholder->placeholders,addplaceholdercnt)
 IF (addplaceholdercnt > 0)
  INSERT  FROM br_pw_comp_placehldr p,
    (dummyt d  WITH seq = addplaceholdercnt)
   SET p.br_pw_comp_placehldr_id = tempaddplaceholder->placeholders[d.seq].placeholder_id, p
    .placehldr_name = tempaddplaceholder->placeholders[d.seq].placeholder_name, p.placehldr_name_key
     = cnvtupper(tempaddplaceholder->placeholders[d.seq].placeholder_name),
    p.comp_type_flag = tempaddplaceholder->placeholders[d.seq].placeholder_type_flag, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into BR_PW_COMP_PLACEHLDR ",serrmsg)
  ENDIF
 ENDIF
 IF (reltntotalsize > 0)
  INSERT  FROM br_pw_comp_placehldr_r r,
    (dummyt d  WITH seq = reltntotalsize)
   SET r.br_pw_comp_placehldr_r_id = seq(bedrock_seq,nextval), r.br_pw_comp_placehldr_id = tempreltns
    ->placeholder_reltns[d.seq].placeholder_id, r.pathway_uuid = cnvtupper(tempreltns->
     placeholder_reltns[d.seq].component_uuid),
    r.required_ind = tempreltns->placeholder_reltns[d.seq].required_ind, r.include_ind = tempreltns->
    placeholder_reltns[d.seq].include_ind, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = 0,
    r.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (tempreltns->placeholder_reltns[d.seq].action_flag=1))
    JOIN (r)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into BR_PW_COMP_PLACEHLDR_R",serrmsg)
  ENDIF
  UPDATE  FROM br_pw_comp_placehldr_r r,
    (dummyt d  WITH seq = reltntotalsize)
   SET r.required_ind = tempreltns->placeholder_reltns[d.seq].required_ind, r.include_ind =
    tempreltns->placeholder_reltns[d.seq].include_ind, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = (r.updt_cnt+ 1),
    r.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (tempreltns->placeholder_reltns[d.seq].action_flag=2))
    JOIN (r
    WHERE (r.br_pw_comp_placehldr_id=tempreltns->placeholder_reltns[d.seq].placeholder_id)
     AND (r.pathway_uuid=tempreltns->placeholder_reltns[d.seq].component_uuid))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error updating into BR_PW_COMP_PLACEHLDR_R",serrmsg)
  ENDIF
  DELETE  FROM br_pw_comp_placehldr_r r,
    (dummyt d  WITH seq = reltntotalsize)
   SET r.seq = 1
   PLAN (d
    WHERE (tempreltns->placeholder_reltns[d.seq].action_flag=3))
    JOIN (r
    WHERE (r.br_pw_comp_placehldr_id=tempreltns->placeholder_reltns[d.seq].placeholder_id)
     AND (r.pathway_uuid=tempreltns->placeholder_reltns[d.seq].component_uuid))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error deleting from BR_PW_COMP_PLACEHLDR_R",serrmsg)
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
