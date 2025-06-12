CREATE PROGRAM bed_ens_prsnl_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl_reltns[*]
      2 prsnl_reltn_id = f8
      2 prsnl_id = f8
      2 prsnl_reltn_type_code_value = f8
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 display_seq = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_add_child
 RECORD temp_add_child(
   1 reltns[*]
     2 prsnl_reltn_id = f8
     2 prsnl_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 display_seq = i4
 )
 FREE SET temp_chg_child
 RECORD temp_chg_child(
   1 reltns[*]
     2 prsnl_reltn_child_id = f8
     2 prsnl_reltn_id = f8
     2 prsnl_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 display_seq = i4
 )
 FREE SET temp_del_child
 RECORD temp_del_child(
   1 reltns[*]
     2 prsnl_reltn_child_id = f8
     2 prsnl_reltn_id = f8
     2 prsnl_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = 0
 SET req_cnt = size(request->prsnl_reltns,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET active_code_value = uar_get_code_by("MEANING",48,"ACTIVE")
 SET add_cnt = 0
 SET del_cnt = 0
 SET chg_cnt = 0
 SET stat = alterlist(reply->prsnl_reltns,req_cnt)
 FOR (erx_x = 1 TO req_cnt)
   IF ((request->prsnl_reltns[erx_x].action_flag=1))
    SELECT INTO "NL:"
     j = seq(person_seq,nextval)"##################;rp0"
     FROM dual d
     PLAN (d)
     DETAIL
      request->prsnl_reltns[erx_x].prsnl_reltn_id = cnvtreal(j)
     WITH format, counter
    ;end select
   ENDIF
   SET reply->prsnl_reltns[erx_x].prsnl_reltn_id = request->prsnl_reltns[erx_x].prsnl_reltn_id
   SET reply->prsnl_reltns[erx_x].parent_entity_id = request->prsnl_reltns[erx_x].parent_entity_id
   SET reply->prsnl_reltns[erx_x].parent_entity_name = request->prsnl_reltns[erx_x].
   parent_entity_name
   SET reply->prsnl_reltns[erx_x].prsnl_id = request->prsnl_reltns[erx_x].prsnl_id
   SET reply->prsnl_reltns[erx_x].prsnl_reltn_type_code_value = request->prsnl_reltns[erx_x].
   prsnl_reltn_type_code_value
   SET reply->prsnl_reltns[erx_x].display_seq = request->prsnl_reltns[erx_x].display_seq
   SET child_size = size(request->prsnl_reltns[erx_x].child_reltns,5)
   FOR (erx_y = 1 TO child_size)
     IF ((request->prsnl_reltns[erx_x].action_flag != 3))
      IF ((request->prsnl_reltns[erx_x].child_reltns[erx_y].action_flag=1))
       SET add_cnt = (add_cnt+ 1)
       SET stat = alterlist(temp_add_child->reltns,add_cnt)
       SET temp_add_child->reltns[add_cnt].prsnl_id = request->prsnl_reltns[erx_x].prsnl_id
       SET temp_add_child->reltns[add_cnt].prsnl_reltn_id = request->prsnl_reltns[erx_x].
       prsnl_reltn_id
       SET temp_add_child->reltns[add_cnt].parent_entity_name = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].parent_entity_name
       SET temp_add_child->reltns[add_cnt].display_seq = request->prsnl_reltns[erx_x].child_reltns[
       erx_y].display_seq
       SET temp_add_child->reltns[add_cnt].parent_entity_id = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].parent_entity_id
      ELSEIF ((request->prsnl_reltns[erx_x].child_reltns[erx_y].action_flag=2))
       SET chg_cnt = (chg_cnt+ 1)
       SET stat = alterlist(temp_chg_child->reltns,chg_cnt)
       SET temp_chg_child->reltns[chg_cnt].prsnl_reltn_child_id = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].prsnl_reltn_child_id
       SET temp_chg_child->reltns[chg_cnt].prsnl_id = request->prsnl_reltns[erx_x].prsnl_id
       SET temp_chg_child->reltns[chg_cnt].prsnl_reltn_id = request->prsnl_reltns[erx_x].
       prsnl_reltn_id
       SET temp_chg_child->reltns[chg_cnt].parent_entity_name = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].parent_entity_name
       SET temp_chg_child->reltns[chg_cnt].parent_entity_id = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].parent_entity_id
       SET temp_chg_child->reltns[chg_cnt].display_seq = request->prsnl_reltns[erx_x].child_reltns[
       erx_y].display_seq
      ELSEIF ((request->prsnl_reltns[erx_x].child_reltns[erx_y].action_flag=3))
       SET del_cnt = (del_cnt+ 1)
       SET stat = alterlist(temp_del_child->reltns,del_cnt)
       SET temp_del_child->reltns[del_cnt].prsnl_reltn_child_id = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].prsnl_reltn_child_id
       SET temp_del_child->reltns[del_cnt].prsnl_id = request->prsnl_reltns[erx_x].prsnl_id
       SET temp_del_child->reltns[del_cnt].prsnl_reltn_id = request->prsnl_reltns[erx_x].
       prsnl_reltn_id
       SET temp_del_child->reltns[del_cnt].parent_entity_name = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].parent_entity_name
       SET temp_del_child->reltns[del_cnt].parent_entity_id = request->prsnl_reltns[erx_x].
       child_reltns[erx_y].parent_entity_id
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 IF (del_cnt > 0)
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(del_cnt))
   SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.display_seq = 0, p.updt_id = reqinfo
    ->updt_id,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_reltn_child_id=temp_del_child->reltns[d.seq].prsnl_reltn_child_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Inactivate prsnl_reltn_child rows."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM prsnl_reltn p,
   (dummyt d  WITH seq = value(req_cnt))
  SET p.active_ind = 0, p.display_seq = 0, p.updt_id = reqinfo->updt_id,
   p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
   updt_task,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (request->prsnl_reltns[d.seq].action_flag=3))
   JOIN (p
   WHERE (p.prsnl_reltn_id=request->prsnl_reltns[d.seq].prsnl_reltn_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Update prsnl_reltn rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM prsnl_reltn_child p,
   (dummyt d  WITH seq = value(req_cnt))
  SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p
   .updt_cnt = (p.updt_cnt+ 1),
   p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (request->prsnl_reltns[d.seq].action_flag=3))
   JOIN (p
   WHERE (p.prsnl_reltn_id=request->prsnl_reltns[d.seq].prsnl_reltn_id)
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Inactivate prsnl_reltn_child rows2."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF (chg_cnt > 0)
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(chg_cnt))
   SET p.display_seq = temp_chg_child->reltns[d.seq].display_seq, p.parent_entity_id = temp_chg_child
    ->reltns[d.seq].parent_entity_id, p.parent_entity_name = temp_chg_child->reltns[d.seq].
    parent_entity_name,
    p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
    updt_applctx,
    p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_reltn_child_id=temp_chg_child->reltns[d.seq].prsnl_reltn_child_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Update prsnl_reltn_child rows."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM prsnl_reltn p,
   (dummyt d  WITH seq = value(req_cnt))
  SET p.display_seq = request->prsnl_reltns[d.seq].display_seq, p.parent_entity_id = request->
   prsnl_reltns[d.seq].parent_entity_id, p.parent_entity_name = request->prsnl_reltns[d.seq].
   parent_entity_name,
   p.person_id = request->prsnl_reltns[d.seq].prsnl_id, p.reltn_type_cd = request->prsnl_reltns[d.seq
   ].prsnl_reltn_type_code_value, p.updt_id = reqinfo->updt_id,
   p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
   updt_task,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (request->prsnl_reltns[d.seq].action_flag=2))
   JOIN (p
   WHERE (p.prsnl_reltn_id=request->prsnl_reltns[d.seq].prsnl_reltn_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Update prsnl_reltn rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM prsnl_reltn p,
   (dummyt d  WITH seq = value(req_cnt))
  SET p.active_ind = 1, p.active_status_cd = active_code_value, p.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3),
   p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
    ), p.display_seq = request->prsnl_reltns[d.seq].display_seq,
   p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.parent_entity_id = request->prsnl_reltns[d
   .seq].parent_entity_id, p.parent_entity_name = request->prsnl_reltns[d.seq].parent_entity_name,
   p.person_id = request->prsnl_reltns[d.seq].prsnl_id, p.prsnl_reltn_id = request->prsnl_reltns[d
   .seq].prsnl_reltn_id, p.reltn_type_cd = request->prsnl_reltns[d.seq].prsnl_reltn_type_code_value,
   p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx,
   p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (request->prsnl_reltns[d.seq].action_flag=1))
   JOIN (p)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Insert prsnl_reltn rows."
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF (add_cnt > 0)
  SET ierrcode = 0
  INSERT  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(add_cnt))
   SET p.prsnl_reltn_child_id = seq(person_only_seq,nextval), p.prsnl_reltn_id = temp_add_child->
    reltns[d.seq].prsnl_reltn_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.display_seq = temp_add_child->reltns[d.seq
    ].display_seq, p.parent_entity_id = temp_add_child->reltns[d.seq].parent_entity_id,
    p.parent_entity_name = temp_add_child->reltns[d.seq].parent_entity_name, p.updt_id = reqinfo->
    updt_id, p.updt_cnt = 0,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Add prsnl_reltn_child rows."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
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
