CREATE PROGRAM bed_ens_viewpoint:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 viewpoint_name = vc
    1 viewpoint_name_key = vc
    1 mp_viewpoint_id = f8
    1 active_ind = i2
    1 action_flag = i2
    1 mpages[*]
      2 br_datamart_category_id = f8
      2 view_seq = i8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 mp_viewpoint_id = f8
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD temp_reltn_id(
   1 reltn_id[*]
     2 reltn_id = f8
 )
 RECORD temp_add_reltn(
   1 encntrs[*]
     2 category_id = f8
     2 encntr_type = f8
     2 new_reltn_id = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132,"")
 SET ierrcode = error(serrmsg,1)
 IF ((request->action_flag=1))
  SET ierrcode = 0
  INSERT  FROM mp_viewpoint v
   SET v.mp_viewpoint_id = seq(mpages_seq,nextval), v.viewpoint_name = request->viewpoint_name, v
    .viewpoint_name_key = cnvtupper(request->viewpoint_name_key),
    v.active_ind = request->active_ind, v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id =
    reqinfo->updt_id,
    v.updt_task = reqinfo->updt_task, v.updt_cnt = 0, v.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus.targetobjectname = concat("ERROR CREATING NEW VIEWPOINT")
   SET reply->status_data.subeventstatus.targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM mp_viewpoint v
   PLAN (v
    WHERE v.viewpoint_name_key=cnvtupper(request->viewpoint_name_key))
   DETAIL
    reply->mp_viewpoint_id = v.mp_viewpoint_id
   WITH nocounter
  ;end select
 ELSEIF ((request->action_flag=2))
  SET ierrcode = 0
  UPDATE  FROM mp_viewpoint v
   SET v.viewpoint_name = request->viewpoint_name, v.active_ind = request->active_ind, v.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    v.updt_id = reqinfo->updt_id, v.updt_task = reqinfo->updt_task, v.updt_cnt = (v.updt_cnt+ 1),
    v.updt_applctx = reqinfo->updt_applctx
   PLAN (v
    WHERE (v.mp_viewpoint_id=request->mp_viewpoint_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus.targetobjectname = concat("ERROR UPDATING VIEWPOINT")
   SET reply->status_data.subeventstatus.targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET reply->mp_viewpoint_id = request->mp_viewpoint_id
 ENDIF
 SET reltn_cnt = 0
 SET reltn_id = 0.0
 SET mpage_cnt = 0
 SET encntr_cnt = 0
 SELECT INTO "nl:"
  FROM mp_viewpoint_reltn m,
   mp_viewpoint_encntr e
  PLAN (m
   WHERE (m.mp_viewpoint_id=reply->mp_viewpoint_id))
   JOIN (e
   WHERE e.mp_viewpoint_reltn_id=outerjoin(m.mp_viewpoint_reltn_id))
  ORDER BY m.mp_viewpoint_reltn_id, m.br_datamart_category_id, e.encntr_type_cd
  HEAD m.mp_viewpoint_reltn_id
   IF (m.mp_viewpoint_reltn_id > 0)
    reltn_cnt = (reltn_cnt+ 1), stat = alterlist(temp_reltn_id->reltn_id,reltn_cnt), temp_reltn_id->
    reltn_id[reltn_cnt].reltn_id = m.mp_viewpoint_reltn_id
   ENDIF
  HEAD m.br_datamart_category_id
   IF (m.br_datamart_category_id > 0)
    mpage_cnt = (mpage_cnt+ 1)
   ENDIF
  HEAD e.encntr_type_cd
   IF (e.encntr_type_cd > 0)
    encntr_cnt = (encntr_cnt+ 1), stat = alterlist(temp_add_reltn->encntrs,encntr_cnt),
    temp_add_reltn->encntrs[encntr_cnt].encntr_type = e.encntr_type_cd,
    temp_add_reltn->encntrs[encntr_cnt].category_id = m.br_datamart_category_id
   ENDIF
  WITH nocounter
 ;end select
 IF (reltn_cnt > 0)
  DELETE  FROM mp_viewpoint_encntr mpve,
    (dummyt d  WITH seq = value(reltn_cnt))
   SET mpve.seq = 1
   PLAN (d)
    JOIN (mpve
    WHERE (mpve.mp_viewpoint_reltn_id=temp_reltn_id->reltn_id[d.seq].reltn_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error removing a records from mp_viewpoint_encntr table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM mp_viewpoint_reltn vr
  PLAN (vr
   WHERE (vr.mp_viewpoint_id=reply->mp_viewpoint_id))
  WITH nocounter
 ;end delete
 SET ierrcode = 0
 INSERT  FROM mp_viewpoint_reltn vr,
   (dummyt d  WITH seq = value(size(request->mpages,5)))
  SET vr.mp_viewpoint_reltn_id = seq(mpages_seq,nextval), vr.mp_viewpoint_id = reply->mp_viewpoint_id,
   vr.br_datamart_category_id = request->mpages[d.seq].br_datamart_category_id,
   vr.view_seq = request->mpages[d.seq].view_seq, vr.updt_dt_tm = cnvtdatetime(curdate,curtime3), vr
   .updt_id = reqinfo->updt_id,
   vr.updt_task = reqinfo->updt_task, vr.updt_cnt = 0, vr.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (vr)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus.targetobjectname = concat("ERROR ADDING MPAGES")
  SET reply->status_data.subeventstatus.targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->mpages,5))),
   (dummyt d2  WITH seq = value(size(temp_add_reltn->encntrs,5))),
   mp_viewpoint_reltn vr
  PLAN (d)
   JOIN (d2
   WHERE (request->mpages[d.seq].br_datamart_category_id=temp_add_reltn->encntrs[d2.seq].category_id)
   )
   JOIN (vr
   WHERE (vr.mp_viewpoint_id=reply->mp_viewpoint_id)
    AND (vr.br_datamart_category_id=request->mpages[d.seq].br_datamart_category_id))
  ORDER BY d2.seq
  HEAD d2.seq
   temp_add_reltn->encntrs[d2.seq].new_reltn_id = vr.mp_viewpoint_reltn_id
  WITH nocounter
 ;end select
 INSERT  FROM mp_viewpoint_encntr e,
   (dummyt d  WITH seq = value(size(temp_add_reltn->encntrs,5)))
  SET e.mp_viewpoint_encntr_id = seq(bedrock_seq,nextval), e.encntr_type_cd = temp_add_reltn->
   encntrs[d.seq].encntr_type, e.mp_viewpoint_reltn_id = temp_add_reltn->encntrs[d.seq].new_reltn_id,
   e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo
   ->updt_task,
   e.updt_cnt = 0, e.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (temp_add_reltn->encntrs[d.seq].new_reltn_id > 0))
   JOIN (e)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus.targetobjectname = concat("ERROR ADDING MPAGES")
  SET reply->status_data.subeventstatus.targetobjectvalue = serrmsg
  GO TO exit_script
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
