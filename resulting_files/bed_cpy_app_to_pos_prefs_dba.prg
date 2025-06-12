CREATE PROGRAM bed_cpy_app_to_pos_prefs:dba
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
 FREE SET vp_source
 RECORD vp_source(
   1 vp_prefs[*]
     2 application = i4
     2 frame_type = vc
     2 view_name = vc
     2 view_seq = i4
     2 nvp_prefs[*]
       3 pvc_name = vc
       3 pvc_value = vc
       3 sequence = i4
       3 merge_name = vc
       3 merge_id = f8
     2 nvp_cnt = i4
   1 vp_cnt = i4
 )
 FREE SET vcp_source
 RECORD vcp_source(
   1 vcp_prefs[*]
     2 application = i4
     2 view_name = vc
     2 view_seq = i4
     2 comp_name = vc
     2 comp_seq = i4
     2 nvp_prefs[*]
       3 pvc_name = vc
       3 pvc_value = vc
       3 sequence = i4
       3 merge_name = vc
       3 merge_id = f8
     2 nvp_cnt = i4
   1 vcp_cnt = i4
 )
 FREE SET vp_insert
 RECORD vp_insert(
   1 vp_prefs[*]
     2 vp_id = f8
     2 application = i4
     2 position_code_value = f8
     2 frame_type = vc
     2 view_name = vc
     2 view_seq = i4
 )
 FREE SET vcp_insert
 RECORD vcp_insert(
   1 vcp_prefs[*]
     2 vcp_id = f8
     2 application = i4
     2 position_code_value = f8
     2 view_name = vc
     2 view_seq = i4
     2 comp_name = vc
     2 comp_seq = i4
 )
 FREE SET nvp_insert
 RECORD nvp_insert(
   1 nvp_insert[*]
     2 parent_id = f8
     2 parent_name = vc
     2 pvc_name = vc
     2 pvc_value = vc
     2 merge_name = vc
     2 merge_id = f8
     2 sequence = i4
 )
 DECLARE error_flag = vc WITH protect
 DECLARE req_cnt = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 IF ((request->application=0))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Aplication = 0")
  GO TO exit_script
 ENDIF
 SET req_cnt = size(request->positions,5)
 IF (req_cnt=0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Empty Position List")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   view_prefs v
  PLAN (d)
   JOIN (v
   WHERE (v.application_number=request->application)
    AND (v.position_cd=request->positions[d.seq].position_code_value)
    AND v.prsnl_id IN (0, null)
    AND v.active_ind=1)
  HEAD d.seq
   error_flag = "Y", reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Invalid Position VP")
  WITH nocounter
 ;end select
 IF (error_flag="Y")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   view_comp_prefs v
  PLAN (d)
   JOIN (v
   WHERE (v.application_number=request->application)
    AND (v.position_cd=request->positions[d.seq].position_code_value)
    AND v.prsnl_id IN (0, null)
    AND v.active_ind=1)
  HEAD d.seq
   error_flag = "Y", reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Invalid Position VCP")
  WITH nocounter
 ;end select
 IF (error_flag="Y")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE (v.application_number=request->application)
    AND v.position_cd=0
    AND v.prsnl_id=0
    AND v.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=v.view_prefs_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.active_ind=1)
  ORDER BY v.view_prefs_id, n.name_value_prefs_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(vp_source->vp_prefs,100)
  HEAD v.view_prefs_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(vp_source->vp_prefs,(tcnt+ 100)), cnt = 1
   ENDIF
   vp_source->vp_prefs[tcnt].application = v.application_number, vp_source->vp_prefs[tcnt].frame_type
    = v.frame_type, vp_source->vp_prefs[tcnt].view_name = v.view_name,
   vp_source->vp_prefs[tcnt].view_seq = v.view_seq, ncnt = 0, ntcnt = 0,
   stat = alterlist(vp_source->vp_prefs[tcnt].nvp_prefs,100)
  HEAD n.name_value_prefs_id
   ncnt = (ncnt+ 1), ntcnt = (ntcnt+ 1)
   IF (ncnt > 100)
    stat = alterlist(vp_source->vp_prefs[tcnt].nvp_prefs,(ntcnt+ 100)), ncnt = 1
   ENDIF
   vp_source->vp_prefs[tcnt].nvp_prefs[ntcnt].pvc_name = n.pvc_name, vp_source->vp_prefs[tcnt].
   nvp_prefs[ntcnt].pvc_value = n.pvc_value, vp_source->vp_prefs[tcnt].nvp_prefs[ntcnt].sequence = n
   .sequence,
   vp_source->vp_prefs[tcnt].nvp_prefs[ntcnt].merge_id = n.merge_id, vp_source->vp_prefs[tcnt].
   nvp_prefs[ntcnt].merge_name = n.merge_name
  FOOT  v.view_prefs_id
   vp_source->vp_prefs[tcnt].nvp_cnt = ntcnt, stat = alterlist(vp_source->vp_prefs[tcnt].nvp_prefs,
    ntcnt)
  FOOT REPORT
   vp_source->vp_cnt = tcnt, stat = alterlist(vp_source->vp_prefs,tcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM view_comp_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE (v.application_number=request->application)
    AND v.position_cd=0
    AND v.prsnl_id=0
    AND v.active_ind=1)
   JOIN (n
   WHERE n.parent_entity_id=v.view_comp_prefs_id
    AND n.parent_entity_name="VIEW_COMP_PREFS"
    AND n.active_ind=1)
  ORDER BY v.view_comp_prefs_id, n.name_value_prefs_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(vcp_source->vcp_prefs,100)
  HEAD v.view_comp_prefs_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(vcp_source->vcp_prefs,(tcnt+ 100)), cnt = 1
   ENDIF
   vcp_source->vcp_prefs[tcnt].application = v.application_number, vcp_source->vcp_prefs[tcnt].
   view_name = v.view_name, vcp_source->vcp_prefs[tcnt].view_seq = v.view_seq,
   vcp_source->vcp_prefs[tcnt].comp_name = v.comp_name, vcp_source->vcp_prefs[tcnt].comp_seq = v
   .comp_seq, ncnt = 0,
   ntcnt = 0, stat = alterlist(vcp_source->vcp_prefs[tcnt].nvp_prefs,100)
  HEAD n.name_value_prefs_id
   ncnt = (ncnt+ 1), ntcnt = (ntcnt+ 1)
   IF (ncnt > 100)
    stat = alterlist(vcp_source->vcp_prefs[tcnt].nvp_prefs,(ntcnt+ 100)), ncnt = 1
   ENDIF
   vcp_source->vcp_prefs[tcnt].nvp_prefs[ntcnt].pvc_name = n.pvc_name, vcp_source->vcp_prefs[tcnt].
   nvp_prefs[ntcnt].pvc_value = n.pvc_value, vcp_source->vcp_prefs[tcnt].nvp_prefs[ntcnt].sequence =
   n.sequence,
   vcp_source->vcp_prefs[tcnt].nvp_prefs[ntcnt].merge_id = n.merge_id, vcp_source->vcp_prefs[tcnt].
   nvp_prefs[ntcnt].merge_name = n.merge_name
  FOOT  v.view_comp_prefs_id
   vcp_source->vcp_prefs[tcnt].nvp_cnt = ntcnt, stat = alterlist(vcp_source->vcp_prefs[tcnt].
    nvp_prefs,ntcnt)
  FOOT REPORT
   vcp_source->vcp_cnt = tcnt, stat = alterlist(vcp_source->vcp_prefs,tcnt)
  WITH nocounter
 ;end select
 DECLARE to_id = f8 WITH protect
 DECLARE vpcnt = i4 WITH protect
 DECLARE nvpcnt = i4 WITH protect
 DECLARE vcpcnt = i4 WITH protect
 SET vpcnt = 0
 SET vcpcnt = 0
 SET nvpcnt = 0
 FOR (r = 1 TO req_cnt)
  FOR (v = 1 TO vp_source->vp_cnt)
    SET to_id = 0.0
    SELECT INTO "NL:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      to_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET vpcnt = (vpcnt+ 1)
    SET stat = alterlist(vp_insert->vp_prefs,vpcnt)
    SET vp_insert->vp_prefs[vpcnt].vp_id = to_id
    SET vp_insert->vp_prefs[vpcnt].application = vp_source->vp_prefs[v].application
    SET vp_insert->vp_prefs[vpcnt].frame_type = vp_source->vp_prefs[v].frame_type
    SET vp_insert->vp_prefs[vpcnt].position_code_value = request->positions[r].position_code_value
    SET vp_insert->vp_prefs[vpcnt].view_name = vp_source->vp_prefs[v].view_name
    SET vp_insert->vp_prefs[vpcnt].view_seq = vp_source->vp_prefs[v].view_seq
    FOR (nvp = 1 TO vp_source->vp_prefs[v].nvp_cnt)
      SET nvpcnt = (nvpcnt+ 1)
      SET stat = alterlist(nvp_insert->nvp_insert,nvpcnt)
      SET nvp_insert->nvp_insert[nvpcnt].parent_id = vp_insert->vp_prefs[vpcnt].vp_id
      SET nvp_insert->nvp_insert[nvpcnt].parent_name = "VIEW_PREFS"
      SET nvp_insert->nvp_insert[nvpcnt].pvc_name = vp_source->vp_prefs[v].nvp_prefs[nvp].pvc_name
      SET nvp_insert->nvp_insert[nvpcnt].pvc_value = vp_source->vp_prefs[v].nvp_prefs[nvp].pvc_value
      SET nvp_insert->nvp_insert[nvpcnt].sequence = vp_source->vp_prefs[v].nvp_prefs[nvp].sequence
      SET nvp_insert->nvp_insert[nvpcnt].merge_id = vp_source->vp_prefs[v].nvp_prefs[nvp].merge_id
      SET nvp_insert->nvp_insert[nvpcnt].merge_name = vp_source->vp_prefs[v].nvp_prefs[nvp].
      merge_name
    ENDFOR
  ENDFOR
  FOR (v = 1 TO vcp_source->vcp_cnt)
    SET to_id = 0.0
    SELECT INTO "NL:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual du
     PLAN (du)
     DETAIL
      to_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET vcpcnt = (vcpcnt+ 1)
    SET stat = alterlist(vcp_insert->vcp_prefs,vcpcnt)
    SET vcp_insert->vcp_prefs[vcpcnt].vcp_id = to_id
    SET vcp_insert->vcp_prefs[vcpcnt].application = vcp_source->vcp_prefs[v].application
    SET vcp_insert->vcp_prefs[vcpcnt].comp_name = vcp_source->vcp_prefs[v].comp_name
    SET vcp_insert->vcp_prefs[vcpcnt].comp_seq = vcp_source->vcp_prefs[v].comp_seq
    SET vcp_insert->vcp_prefs[vcpcnt].position_code_value = request->positions[r].position_code_value
    SET vcp_insert->vcp_prefs[vcpcnt].view_name = vcp_source->vcp_prefs[v].view_name
    SET vcp_insert->vcp_prefs[vcpcnt].view_seq = vcp_source->vcp_prefs[v].view_seq
    FOR (nvp = 1 TO vcp_source->vcp_prefs[v].nvp_cnt)
      SET nvpcnt = (nvpcnt+ 1)
      SET stat = alterlist(nvp_insert->nvp_insert,nvpcnt)
      SET nvp_insert->nvp_insert[nvpcnt].parent_id = vcp_insert->vcp_prefs[vcpcnt].vcp_id
      SET nvp_insert->nvp_insert[nvpcnt].parent_name = "VIEW_COMP_PREFS"
      SET nvp_insert->nvp_insert[nvpcnt].pvc_name = vcp_source->vcp_prefs[v].nvp_prefs[nvp].pvc_name
      SET nvp_insert->nvp_insert[nvpcnt].pvc_value = vcp_source->vcp_prefs[v].nvp_prefs[nvp].
      pvc_value
      SET nvp_insert->nvp_insert[nvpcnt].sequence = vcp_source->vcp_prefs[v].nvp_prefs[nvp].sequence
      SET nvp_insert->nvp_insert[nvpcnt].merge_id = vcp_source->vcp_prefs[v].nvp_prefs[nvp].merge_id
      SET nvp_insert->nvp_insert[nvpcnt].merge_name = vcp_source->vcp_prefs[v].nvp_prefs[nvp].
      merge_name
    ENDFOR
  ENDFOR
 ENDFOR
 IF (vpcnt > 0)
  SET ierrcode = 0
  INSERT  FROM view_prefs v,
    (dummyt d  WITH seq = value(vpcnt))
   SET v.application_number = vp_insert->vp_prefs[d.seq].application, v.active_ind = 1, v.frame_type
     = vp_insert->vp_prefs[d.seq].frame_type,
    v.position_cd = vp_insert->vp_prefs[d.seq].position_code_value, v.prsnl_id = 0.0, v.view_name =
    vp_insert->vp_prefs[d.seq].view_name,
    v.view_seq = vp_insert->vp_prefs[d.seq].view_seq, v.view_prefs_id = vp_insert->vp_prefs[d.seq].
    vp_id, v.updt_applctx = reqinfo->updt_applctx,
    v.updt_cnt = 0, v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->updt_id,
    v.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (v)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on view_prefs insert")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (vcpcnt > 0)
  INSERT  FROM view_comp_prefs v,
    (dummyt d  WITH seq = value(vcpcnt))
   SET v.application_number = vcp_insert->vcp_prefs[d.seq].application, v.active_ind = 1, v
    .position_cd = vcp_insert->vcp_prefs[d.seq].position_code_value,
    v.prsnl_id = 0.0, v.view_name = vcp_insert->vcp_prefs[d.seq].view_name, v.view_seq = vcp_insert->
    vcp_prefs[d.seq].view_seq,
    v.view_comp_prefs_id = vcp_insert->vcp_prefs[d.seq].vcp_id, v.comp_name = vcp_insert->vcp_prefs[d
    .seq].comp_name, v.comp_seq = vcp_insert->vcp_prefs[d.seq].comp_seq,
    v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = 0, v.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    v.updt_id = reqinfo->updt_id, v.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (v)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error on view_comp_prefs insert")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (nvpcnt > 0)
  INSERT  FROM name_value_prefs v,
    (dummyt d  WITH seq = value(nvpcnt))
   SET v.name_value_prefs_id = seq(carenet_seq,nextval), v.active_ind = 1, v.parent_entity_id =
    nvp_insert->nvp_insert[d.seq].parent_id,
    v.parent_entity_name = nvp_insert->nvp_insert[d.seq].parent_name, v.pvc_name = nvp_insert->
    nvp_insert[d.seq].pvc_name, v.pvc_value = nvp_insert->nvp_insert[d.seq].pvc_value,
    v.sequence = nvp_insert->nvp_insert[d.seq].sequence, v.merge_id = nvp_insert->nvp_insert[d.seq].
    merge_id, v.merge_name = nvp_insert->nvp_insert[d.seq].merge_name,
    v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = 0, v.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    v.updt_id = reqinfo->updt_id, v.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (v)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error on name_value_prefs insert")
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
