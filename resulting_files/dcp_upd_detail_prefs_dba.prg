CREATE PROGRAM dcp_upd_detail_prefs:dba
 RECORD reply(
   1 nv_cnt = i4
   1 nv[*]
     2 name_value_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE det_prefs_id = f8 WITH noconstant(0.0)
 DECLARE name_value_prefs_id = f8 WITH noconstant(0.0)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 IF ((request->nv_cnt > 0))
  SET stat = alterlist(reply->nv,request->nv_cnt)
  SET reply->nv_cnt = request->nv_cnt
 ENDIF
 IF ((request->position_cd > 0)
  AND (request->prsnl_id > 0))
  SET request->position_cd = 0
 ENDIF
 SELECT INTO "nl:"
  dp.seq
  FROM detail_prefs dp
  PLAN (dp
   WHERE (dp.application_number=request->application_number)
    AND (dp.position_cd=request->position_cd)
    AND (dp.prsnl_id=request->prsnl_id)
    AND (dp.view_name=request->view_name)
    AND (dp.view_seq=request->view_seq)
    AND (dp.comp_name=request->comp_name)
    AND (dp.comp_seq=request->comp_seq))
  HEAD REPORT
   det_prefs_id = 0
  DETAIL
   det_prefs_id = dp.detail_prefs_id
  WITH nocounter, maxqual(dp,1)
 ;end select
 IF (curqual=0)
  GO TO add_det_prefs
 ENDIF
 FOR (x = 1 TO request->nv_cnt)
  IF ((request->nv[x].name_value_prefs_id > 0))
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_name = request->nv[x].pvc_name, nvp.pvc_value = request->nv[x].pvc_value, nvp
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->
     updt_applctx,
     nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.merge_id = request->nv[x].merge_id, nvp.merge_name =
     request->nv[x].merge_name,
     nvp.sequence = request->nv[x].sequence
    WHERE (nvp.name_value_prefs_id=request->nv[x].name_value_prefs_id)
    WITH nocounter
   ;end update
   SET reply->nv[x].name_value_prefs_id = request->nv[x].name_value_prefs_id
  ELSE
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "DETAIL_PREFS", nvp
     .parent_entity_id = det_prefs_id,
     nvp.pvc_name = request->nv[x].pvc_name, nvp.pvc_value = request->nv[x].pvc_value, nvp.active_ind
      = 1,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0, nvp.merge_id = request->nv[x].
     merge_id,
     nvp.merge_name = request->nv[x].merge_name, nvp.sequence = request->nv[x].sequence
    WITH nocounter
   ;end insert
   SET reply->nv[x].name_value_prefs_id = name_value_prefs_id
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "name_value_prefs table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
 GO TO exit_script
#add_det_prefs
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   det_prefs_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 INSERT  FROM detail_prefs dp
  SET dp.detail_prefs_id = det_prefs_id, dp.application_number = request->application_number, dp
   .position_cd = request->position_cd,
   dp.prsnl_id = request->prsnl_id, dp.person_id = request->person_id, dp.view_name = request->
   view_name,
   dp.view_seq = request->view_seq, dp.comp_name = request->comp_name, dp.comp_seq = request->
   comp_seq,
   dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id,
   dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "detail_prefs table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->nv_cnt > 0))
  FOR (x = 1 TO request->nv_cnt)
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      request->nv[x].name_value_prefs_id = cnvtreal(j), reply->nv[x].name_value_prefs_id = cnvtreal(j
       )
     WITH format, nocounter
    ;end select
  ENDFOR
  INSERT  FROM name_value_prefs nvp,
    (dummyt d1  WITH seq = value(request->nv_cnt))
   SET nvp.seq = 1, nvp.name_value_prefs_id = request->nv[d1.seq].name_value_prefs_id, nvp
    .parent_entity_name = "DETAIL_PREFS",
    nvp.parent_entity_id = det_prefs_id, nvp.pvc_name = request->nv[d1.seq].pvc_name, nvp.pvc_value
     = request->nv[d1.seq].pvc_value,
    nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
    updt_id,
    nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0,
    nvp.merge_id = request->nv[d1.seq].merge_id, nvp.merge_name = request->nv[d1.seq].merge_name, nvp
    .sequence = request->nv[d1.seq].sequence
   PLAN (d1)
    JOIN (nvp)
   WITH nocounter
  ;end insert
  IF ((curqual != request->nv_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_UPD_DETAIL_PREFS"
   SET failed = "T"
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
