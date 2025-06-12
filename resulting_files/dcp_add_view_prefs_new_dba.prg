CREATE PROGRAM dcp_add_view_prefs_new:dba
 RECORD reply(
   1 pview[*]
     2 view_prefs_id = f8
     2 nv[*]
       3 name_value_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE vp_id = f8 WITH noconstant(0.0)
 DECLARE nvp_id = f8 WITH noconstant(0.0)
 DECLARE new_nvp_cnt = i4 WITH noconstant(0)
 DECLARE view_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET view_cnt = cnvtint(size(request->pview,5))
 SET stat = alterlist(reply->pview,view_cnt)
 FOR (x = 1 TO request->view_cnt)
   IF ((request->pview[x].prsnl_id > 0))
    SET request->pview[x].position_cd = 0
   ENDIF
   SELECT INTO "nl:"
    vp.seq
    FROM view_prefs vp
    WHERE (vp.application_number=request->pview[x].application_number)
     AND (vp.position_cd=request->pview[x].position_cd)
     AND (vp.prsnl_id=request->pview[x].prsnl_id)
     AND (vp.frame_type=request->pview[x].frame_type)
     AND (vp.view_name=request->pview[x].view_name)
     AND (vp.view_seq=request->pview[x].view_seq)
     AND vp.active_ind=1
    DETAIL
     vp_id = vp.view_prefs_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET new_nvp_cnt = 0
    FOR (y = 1 TO request->pview[x].nv_cnt)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = request->pview[x].nv[y].pvc_value, nvp.sequence = request->pview[x].nv[y].
       sequence, nvp.merge_id = request->pview[x].nv[y].merge_id,
       nvp.merge_name = request->pview[x].nv[y].merge_name
      WHERE nvp.parent_entity_id=vp_id
       AND nvp.parent_entity_name="VIEW_PREFS"
       AND (nvp.pvc_name=request->pview[x].nv[y].pvc_name)
       AND (nvp.sequence=request->pview[x].nv[y].sequence)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        nvp_id = cnvtreal(j)
      ;end select
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = nvp_id, nvp.parent_entity_name = "VIEW_PREFS", nvp
        .parent_entity_id = vp_id,
        nvp.pvc_name = request->pview[x].nv[y].pvc_name, nvp.pvc_value = request->pview[x].nv[y].
        pvc_value, nvp.sequence = request->pview[x].nv[y].sequence,
        nvp.merge_id = request->pview[x].nv[y].merge_id, nvp.merge_name = request->pview[x].nv[y].
        merge_name, nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
      SET new_nvp_cnt = (new_nvp_cnt+ 1)
      SET stat = alterlist(reply->pview[x].nv,new_nvp_cnt)
      SET reply->pview[x].nv[new_nvp_cnt].name_value_prefs_id = nvp_id
     ENDIF
    ENDFOR
   ELSE
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      vp_id = cnvtreal(j)
    ;end select
    SET reply->pview[cnt].view_prefs_id = vp_id WITH format, nocounter
    INSERT  FROM view_prefs vp
     SET vp.view_prefs_id = vp_id, vp.application_number = request->pview[x].application_number, vp
      .position_cd = request->pview[x].position_cd,
      vp.prsnl_id = request->pview[x].prsnl_id, vp.frame_type = request->pview[x].frame_type, vp
      .view_name = request->pview[x].view_name,
      vp.view_seq = request->pview[x].view_seq, vp.active_ind = 1, vp.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      vp.updt_id = reqinfo->updt_id, vp.updt_task = reqinfo->updt_task, vp.updt_applctx = reqinfo->
      updt_applctx,
      vp.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].targetobjectname = "view_prefs table"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
     SET failed = "T"
     GO TO exit_script
    ENDIF
    SET new_nvp_cnt = 0
    FOR (y = 1 TO request->pview[x].nv_cnt)
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)
       FROM dual
       DETAIL
        nvp_id = cnvtreal(j)
      ;end select
      INSERT  FROM name_value_prefs nvp
       SET nvp.seq = 1, nvp.name_value_prefs_id = nvp_id, nvp.parent_entity_name = "VIEW_PREFS",
        nvp.parent_entity_id = vp_id, nvp.pvc_name = request->pview[x].nv[y].pvc_name, nvp.pvc_value
         = request->pview[x].nv[y].pvc_value,
        nvp.sequence = request->pview[x].nv[y].sequence, nvp.merge_id = request->pview[x].nv[y].
        merge_id, nvp.merge_name = request->pview[x].nv[y].merge_name,
        nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
        updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt =
        0
       WITH nocounter
      ;end insert
      SET new_nvp_cnt = (new_nvp_cnt+ 1)
      SET stat = alterlist(reply->pview[x].nv,new_nvp_cnt)
      SET reply->pview[x].nv[new_nvp_cnt].name_value_prefs_id = nvp_id
    ENDFOR
    IF (new_nvp_cnt != value(request->pview[x].nv_cnt))
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "VIEW_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_VIEW_PREFS"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET reply->pview[x].view_prefs_id = vp_id
 ENDFOR
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  IF (failed="D")
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "D"
  ELSE
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
END GO
