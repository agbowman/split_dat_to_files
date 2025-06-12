CREATE PROGRAM bed_ens_tab_prefs:dba
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
 FREE SET cpy_request
 RECORD cpy_request(
   1 application = i4
   1 positions[*]
     2 position_code_value = f8
 )
 FREE SET cpy_reply
 RECORD cpy_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET 4411176_nvp_ins
 RECORD 4411176_nvp_ins(
   1 4411176_nvp_ins[*]
     2 view_id = f8
     2 pvc_name = vc
     2 pvc_value = vc
     2 sequence = i4
     2 merge_id = f8
     2 merge_name = vc
     2 pos_code = f8
     2 global_ind = i2
     2 nvp_id = f8
     2 source_nvp_id = f8
 )
 FREE SET 4411176_nvp_del
 RECORD 4411176_nvp_del(
   1 4411176_nvp_del[*]
     2 nvp_id = f8
 )
 DECLARE error_flag = vc WITH protect
 DECLARE req_cnt = i4 WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 DECLARE pos_cnt = i4 WITH protect
 DECLARE view_cnt = i4 WITH protect
 DECLARE add_pos_ind = i2 WITH protect
 DECLARE cpy_cnt = i4 WITH protect
 DECLARE nvp_cnt = i4 WITH protect
 DECLARE pref_cnt = i4 WITH protect
 DECLARE new_id = f8 WITH protect
 DECLARE nvp_del_cnt = i4 WITH protect
 IF ((request->application=0))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Aplication = 0")
  GO TO exit_script
 ENDIF
 SET pos_cnt = size(request->positions,5)
 IF (pos_cnt=0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("No positions")
  GO TO exit_script
 ENDIF
 SET nvp_cnt = 0
 SET cpy_request->application = request->application
 FOR (p = 1 TO pos_cnt)
   SET view_cnt = size(request->positions[p].views,5)
   SET add_pos_ind = 0
   FOR (v = 1 TO view_cnt)
     IF ((request->positions[p].views[v].global_ind=1))
      SET add_pos_ind = 1
     ENDIF
     SET pref_cnt = size(request->positions[p].views[v].preferences,5)
     FOR (n = 1 TO pref_cnt)
       SET nvp_cnt = (nvp_cnt+ 1)
       SET stat = alterlist(4411176_nvp_ins->4411176_nvp_ins,nvp_cnt)
       SET 4411176_nvp_ins->4411176_nvp_ins[nvp_cnt].global_ind = request->positions[p].views[v].
       global_ind
       SET 4411176_nvp_ins->4411176_nvp_ins[nvp_cnt].view_id = request->positions[p].views[v].view_id
       SET 4411176_nvp_ins->4411176_nvp_ins[nvp_cnt].pos_code = request->positions[p].
       position_code_value
       SET 4411176_nvp_ins->4411176_nvp_ins[nvp_cnt].source_nvp_id = request->positions[p].views[v].
       preferences[n].name_value_prefs_id
     ENDFOR
   ENDFOR
   IF (add_pos_ind=1)
    SET cpy_cnt = (cpy_cnt+ 1)
    SET stat = alterlist(cpy_request->positions,cpy_cnt)
    SET cpy_request->positions[cpy_cnt].position_code_value = request->positions[p].
    position_code_value
   ENDIF
 ENDFOR
 IF (nvp_cnt=0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("No Prefs")
  GO TO exit_script
 ENDIF
 IF (cpy_cnt > 0)
  EXECUTE bed_cpy_app_to_pos_prefs  WITH replace("REQUEST",cpy_request), replace("REPLY",cpy_reply)
  IF ((cpy_reply->status_data.status="F"))
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Copy Failed")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = cpy_reply->status_data.
   subeventstatus[1].targetobjectvalue
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE (n.name_value_prefs_id=4411176_nvp_ins->4411176_nvp_ins[d.seq].source_nvp_id))
  ORDER BY d.seq
  HEAD d.seq
   4411176_nvp_ins->4411176_nvp_ins[d.seq].merge_id = n.merge_id, 4411176_nvp_ins->4411176_nvp_ins[d
   .seq].merge_name = n.merge_name, 4411176_nvp_ins->4411176_nvp_ins[d.seq].pvc_name = n.pvc_name,
   4411176_nvp_ins->4411176_nvp_ins[d.seq].pvc_value = n.pvc_value, 4411176_nvp_ins->4411176_nvp_ins[
   d.seq].sequence = n.sequence
  WITH nocounter
 ;end select
 SET nvp_del_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d
   WHERE (4411176_nvp_ins->4411176_nvp_ins[d.seq].global_ind=0))
   JOIN (n
   WHERE (n.parent_entity_id=4411176_nvp_ins->4411176_nvp_ins[d.seq].view_id)
    AND n.parent_entity_name="VIEW_PREFS"
    AND trim(n.pvc_name)=trim(4411176_nvp_ins->4411176_nvp_ins[d.seq].pvc_name)
    AND n.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0
  DETAIL
   nvp_del_cnt = (nvp_del_cnt+ 1), stat = alterlist(4411176_nvp_del->4411176_nvp_del,nvp_del_cnt),
   4411176_nvp_del->4411176_nvp_del[nvp_del_cnt].nvp_id = n.name_value_prefs_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   view_prefs dp,
   view_prefs dp2,
   name_value_prefs n
  PLAN (d
   WHERE (4411176_nvp_ins->4411176_nvp_ins[d.seq].global_ind=1))
   JOIN (dp
   WHERE (dp.view_prefs_id=4411176_nvp_ins->4411176_nvp_ins[d.seq].view_id))
   JOIN (dp2
   WHERE dp2.view_name=dp.view_name
    AND dp2.view_seq=dp.view_seq
    AND dp2.frame_type=dp.frame_type
    AND dp2.application_number=dp.application_number
    AND (dp2.position_cd=4411176_nvp_ins->4411176_nvp_ins[d.seq].pos_code)
    AND dp2.prsnl_id=0)
   JOIN (n
   WHERE n.parent_entity_id=outerjoin(dp2.view_prefs_id)
    AND n.parent_entity_name=outerjoin("VIEW_PREFS")
    AND trim(n.pvc_name)=outerjoin(trim(4411176_nvp_ins->4411176_nvp_ins[d.seq].pvc_name))
    AND n.active_ind=outerjoin(1))
  ORDER BY d.seq, n.name_value_prefs_id
  HEAD d.seq
   4411176_nvp_ins->4411176_nvp_ins[d.seq].view_id = dp2.view_prefs_id, 4411176_nvp_ins->
   4411176_nvp_ins[d.seq].global_ind = 0
  HEAD n.name_value_prefs_id
   IF (n.name_value_prefs_id > 0)
    nvp_del_cnt = (nvp_del_cnt+ 1), stat = alterlist(4411176_nvp_del->4411176_nvp_del,nvp_del_cnt),
    4411176_nvp_del->4411176_nvp_del[nvp_del_cnt].nvp_id = n.name_value_prefs_id
   ENDIF
  WITH nocounter
 ;end select
 FOR (n = 1 TO nvp_cnt)
   IF ((4411176_nvp_ins->4411176_nvp_ins[n].global_ind=1))
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat("No Target Found")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Pos: ",4411176_nvp_ins->
     4411176_nvp_ins[n].pos_code," ViewId: ",4411176_nvp_ins->4411176_nvp_ins[n].view_id)
    CALL echorecord(4411176_nvp_ins)
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (nvp_del_cnt > 0)
  SET ierrcode = 0
  DELETE  FROM name_value_prefs n,
    (dummyt d  WITH seq = value(nvp_del_cnt))
   SET n.seq = 1
   PLAN (d)
    JOIN (n
    WHERE (n.name_value_prefs_id=4411176_nvp_del->4411176_nvp_del[d.seq].nvp_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on nvp delete")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 INSERT  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(nvp_cnt))
  SET n.name_value_prefs_id = seq(carenet_seq,nextval), n.pvc_value = 4411176_nvp_ins->
   4411176_nvp_ins[d.seq].pvc_value, n.merge_id = 4411176_nvp_ins->4411176_nvp_ins[d.seq].merge_id,
   n.merge_name = 4411176_nvp_ins->4411176_nvp_ins[d.seq].merge_name, n.sequence = 4411176_nvp_ins->
   4411176_nvp_ins[d.seq].sequence, n.active_ind = 1,
   n.parent_entity_id = 4411176_nvp_ins->4411176_nvp_ins[d.seq].view_id, n.parent_entity_name =
   "VIEW_PREFS", n.pvc_name = 4411176_nvp_ins->4411176_nvp_ins[d.seq].pvc_name,
   n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (n)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on nvp insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
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
