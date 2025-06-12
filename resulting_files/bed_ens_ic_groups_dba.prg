CREATE PROGRAM bed_ens_ic_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 groups[*]
      2 group_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_reltn
 RECORD temp_reltn(
   1 reltns[*]
     2 action_flag = i2
     2 reltn_id = f8
     2 group_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
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
 DECLARE temp_group_id = f8 WITH protect
 DECLARE temp_reltn_id = f8 WITH protect
 DECLARE req_size = i4 WITH protect
 DECLARE reltn_size = i4 WITH protect
 DECLARE reltn_cnt = i4 WITH protect
 SET req_size = size(request->groups,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->groups,req_size)
 SET reltn_cnt = 0
 FOR (x = 1 TO req_size)
   IF ((request->groups[x].action_flag=1))
    SET temp_group_id = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_group_id = cnvtreal(j)
     WITH format, counter
    ;end select
    CALL bederrorcheck("Sequence Error")
    SET request->groups[x].group_id = temp_group_id
   ENDIF
   SET reltn_size = size(request->groups[x].relations,5)
   FOR (r = 1 TO reltn_size)
     SET reltn_cnt = (reltn_cnt+ 1)
     SET stat = alterlist(temp_reltn->reltns,reltn_cnt)
     SET temp_reltn->reltns[reltn_cnt].action_flag = request->groups[x].relations[r].action_flag
     SET temp_reltn->reltns[reltn_cnt].parent_entity_id = request->groups[x].relations[r].
     parent_entity_id
     SET temp_reltn->reltns[reltn_cnt].parent_entity_name = cnvtupper(request->groups[x].relations[r]
      .parent_entity_name)
     SET temp_reltn->reltns[reltn_cnt].group_id = request->groups[x].group_id
     IF ((request->groups[x].relations[r].action_flag=1))
      SET temp_reltn_id = 0.0
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        temp_reltn_id = cnvtreal(j)
       WITH format, counter
      ;end select
      CALL bederrorcheck("Sequence2 Error")
      SET temp_reltn->reltns[reltn_cnt].reltn_id = temp_reltn_id
     ENDIF
   ENDFOR
   SET reply->groups[x].group_id = request->groups[x].group_id
 ENDFOR
 DELETE  FROM lh_cnt_ic_antibgrm_group_r l,
   (dummyt d  WITH seq = value(req_size))
  SET l.seq = 1
  PLAN (d
   WHERE (request->groups[d.seq].action_flag=3))
   JOIN (l
   WHERE (l.lh_cnt_ic_antibgrm_group_id=request->groups[d.seq].group_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Group1 Delete Error")
 DELETE  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(req_size))
  SET dsc.seq = 1
  PLAN (d
   WHERE (request->groups[d.seq].action_flag=3))
   JOIN (dsc
   WHERE (dsc.lh_cnt_ic_antibgrm_group_id=request->groups[d.seq].group_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Disclaimer Delete Error")
 DELETE  FROM lh_cnt_ic_antibgrm_group l,
   (dummyt d  WITH seq = value(req_size))
  SET l.seq = 1
  PLAN (d
   WHERE (request->groups[d.seq].action_flag=3))
   JOIN (l
   WHERE (l.lh_cnt_ic_antibgrm_group_id=request->groups[d.seq].group_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Group2 Delete Error")
 UPDATE  FROM lh_cnt_ic_antibgrm_group l,
   (dummyt d  WITH seq = value(req_size))
  SET l.group_name = request->groups[d.seq].group_name, l.group_type_flag = request->groups[d.seq].
   group_type_flag, l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_cnt = (l.updt_cnt+ 1),
   l.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->groups[d.seq].action_flag=2))
   JOIN (l
   WHERE (l.lh_cnt_ic_antibgrm_group_id=request->groups[d.seq].group_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Group Update Error")
 INSERT  FROM lh_cnt_ic_antibgrm_group l,
   (dummyt d  WITH seq = value(req_size))
  SET l.lh_cnt_ic_antibgrm_group_id = request->groups[d.seq].group_id, l.group_name = request->
   groups[d.seq].group_name, l.group_type_flag = request->groups[d.seq].group_type_flag,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo
   ->updt_task,
   l.updt_cnt = 0, l.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->groups[d.seq].action_flag=1))
   JOIN (l)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Group Insert Error")
 IF (reltn_cnt > 0)
  DELETE  FROM lh_cnt_ic_antibgrm_group_r l,
    (dummyt d  WITH seq = value(reltn_cnt))
   SET l.seq = 1
   PLAN (d
    WHERE (temp_reltn->reltns[d.seq].action_flag=3))
    JOIN (l
    WHERE (l.lh_cnt_ic_antibgrm_group_id=temp_reltn->reltns[d.seq].group_id)
     AND (l.parent_entity_name=temp_reltn->reltns[d.seq].parent_entity_name)
     AND (l.parent_entity_id=temp_reltn->reltns[d.seq].parent_entity_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Reltn Delete Error")
  UPDATE  FROM lh_cnt_ic_antibgrm_group_r l,
    (dummyt d  WITH seq = value(reltn_cnt))
   SET l.parent_entity_name = temp_reltn->reltns[d.seq].parent_entity_name, l.parent_entity_id =
    temp_reltn->reltns[d.seq].parent_entity_id, l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_cnt = (l.updt_cnt+ 1),
    l.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp_reltn->reltns[d.seq].action_flag=2))
    JOIN (l
    WHERE (l.lh_cnt_ic_antibgrm_group_id=temp_reltn->reltns[d.seq].group_id)
     AND (l.parent_entity_name=temp_reltn->reltns[d.seq].parent_entity_name)
     AND (l.parent_entity_id=temp_reltn->reltns[d.seq].parent_entity_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Reltn Update Error")
  INSERT  FROM lh_cnt_ic_antibgrm_group_r l,
    (dummyt d  WITH seq = value(reltn_cnt))
   SET l.lh_cnt_ic_antibgrm_group_r_id = temp_reltn->reltns[d.seq].reltn_id, l
    .lh_cnt_ic_antibgrm_group_id = temp_reltn->reltns[d.seq].group_id, l.parent_entity_name =
    temp_reltn->reltns[d.seq].parent_entity_name,
    l.parent_entity_id = temp_reltn->reltns[d.seq].parent_entity_id, l.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), l.updt_id = reqinfo->updt_id,
    l.updt_task = reqinfo->updt_task, l.updt_cnt = 0, l.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp_reltn->reltns[d.seq].action_flag=1))
    JOIN (l)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Reltn Insert Error")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
