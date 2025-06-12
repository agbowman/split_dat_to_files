CREATE PROGRAM dcp_add_note_dlg:dba
 RECORD internal(
   1 view_cnt = i4
   1 pview[1]
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 frame_type = c12
     2 view_name = c12
     2 view_seq = i4
     2 nv_cnt = i4
     2 nv[4]
       3 pvc_name = c32
       3 pvc_value = vc
   1 view_comp_cnt = i4
   1 pviewcomp[1]
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 comp_name = c12
     2 comp_seq = i4
     2 nv_cnt = i4
     2 nv[2]
       3 pvc_name = c32
       3 pvc_value = vc
 )
 SET internal->view_cnt = 1
 SET internal->pview[1].application_number = 600005
 SET internal->pview[1].position_cd = 0
 SET internal->pview[1].prsnl_id = 0
 SET internal->pview[1].frame_type = "CLINNOTESDLG"
 SET internal->pview[1].view_name = "CLINNOTES"
 SET internal->pview[1].view_seq = 1
 SET internal->pview[1].nv_cnt = 4
 SET internal->pview[1].nv[1].pvc_name = "VIEW_IND"
 SET internal->pview[1].nv[1].pvc_value = "0"
 SET internal->pview[1].nv[2].pvc_name = "VIEW_CAPTION"
 SET internal->pview[1].nv[2].pvc_value = "Document Viewer"
 SET internal->pview[1].nv[3].pvc_name = "DISPLAY_SEQ"
 SET internal->pview[1].nv[3].pvc_value = "1"
 SET internal->pview[1].nv[4].pvc_name = "DLL_NAME"
 SET internal->pview[1].nv[4].pvc_value = ""
 SET internal->view_comp_cnt = 1
 SET internal->pviewcomp[1].application_number = 600005
 SET internal->pviewcomp[1].position_cd = 0
 SET internal->pviewcomp[1].prsnl_id = 0
 SET internal->pviewcomp[1].view_name = "CLINNOTES"
 SET internal->pviewcomp[1].view_seq = 1
 SET internal->pviewcomp[1].comp_name = "CLINNOTES"
 SET internal->pviewcomp[1].comp_seq = 1
 SET internal->pviewcomp[1].nv_cnt = 2
 SET internal->pviewcomp[1].nv[1].pvc_name = "COMP_POSITION"
 SET internal->pviewcomp[1].nv[1].pvc_value = "0,0,3,4"
 SET internal->pviewcomp[1].nv[2].pvc_name = "COMP_DLLNAME"
 SET internal->pviewcomp[1].nv[2].pvc_value = "PVNOTES"
 SET failed = "F"
 DECLARE vp_id = f8 WITH protect, noconstant(0)
 SET view_cnt = 0
 SET view_cnt = cnvtint(size(internal->pview,5))
 FOR (x = 1 TO internal->view_cnt)
   IF ((internal->pview[x].prsnl_id > 0))
    SET internal->pview[x].position_cd = 0
   ENDIF
   SELECT INTO "nl:"
    vp.seq
    FROM view_prefs vp
    WHERE (vp.application_number=internal->pview[x].application_number)
     AND (vp.position_cd=internal->pview[x].position_cd)
     AND (vp.prsnl_id=internal->pview[x].prsnl_id)
     AND (vp.frame_type=internal->pview[x].frame_type)
     AND (vp.view_name=internal->pview[x].view_name)
     AND (vp.view_seq=internal->pview[x].view_seq)
     AND vp.active_ind=1
    DETAIL
     vp_id = vp.view_prefs_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    FOR (y = 1 TO internal->pview[x].nv_cnt)
     UPDATE  FROM name_value_prefs nvp
      SET nvp.pvc_value = internal->pview[x].nv[y].pvc_value
      WHERE nvp.parent_entity_id=vp_id
       AND nvp.parent_entity_name="VIEW_PREFS"
       AND (nvp.pvc_name=internal->pview[x].nv[y].pvc_name)
      WITH nocounter
     ;end update
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "VIEW_PREFS",
        nvp.parent_entity_id = vp_id,
        nvp.pvc_name = internal->pview[x].nv[y].pvc_name, nvp.pvc_value = internal->pview[x].nv[y].
        pvc_value, nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
    ENDFOR
   ELSE
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      vp_id = j
     WITH format, nocounter
    ;end select
    INSERT  FROM view_prefs vp
     SET vp.view_prefs_id = vp_id, vp.application_number = internal->pview[x].application_number, vp
      .position_cd = internal->pview[x].position_cd,
      vp.prsnl_id = internal->pview[x].prsnl_id, vp.frame_type = internal->pview[x].frame_type, vp
      .view_name = internal->pview[x].view_name,
      vp.view_seq = internal->pview[x].view_seq, vp.active_ind = 1, vp.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      vp.updt_id = reqinfo->updt_id, vp.updt_task = reqinfo->updt_task, vp.updt_applctx = reqinfo->
      updt_applctx,
      vp.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM name_value_prefs nvp,
      (dummyt d1  WITH seq = value(internal->pview[x].nv_cnt))
     SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
      "VIEW_PREFS",
      nvp.parent_entity_id = vp_id, nvp.pvc_name = internal->pview[x].nv[d1.seq].pvc_name, nvp
      .pvc_value = internal->pview[x].nv[d1.seq].pvc_value,
      nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
      updt_id,
      nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
     PLAN (d1)
      JOIN (nvp)
     WITH nocounter
    ;end insert
    IF (curqual != value(internal->pview[x].nv_cnt))
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET failed = "F"
 SET vp_id = 0
 SET view_comp_cnt = 0
 SET view_comp_cnt = cnvtint(size(internal->pviewcomp,5))
 FOR (x = 1 TO internal->view_comp_cnt)
   IF ((internal->pviewcomp[x].prsnl_id > 0))
    SET internal->pviewcomp[x].position_cd = 0
   ENDIF
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     vp_id = j
    WITH format, nocounter
   ;end select
   INSERT  FROM view_comp_prefs vp
    SET vp.view_comp_prefs_id = vp_id, vp.application_number = internal->pviewcomp[x].
     application_number, vp.position_cd = internal->pviewcomp[x].position_cd,
     vp.prsnl_id = internal->pviewcomp[x].prsnl_id, vp.view_name = internal->pviewcomp[x].view_name,
     vp.view_seq = internal->pviewcomp[x].view_seq,
     vp.comp_name = internal->pviewcomp[x].comp_name, vp.comp_seq = internal->pviewcomp[x].comp_seq,
     vp.active_ind = 1,
     vp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vp.updt_id = reqinfo->updt_id, vp.updt_task =
     reqinfo->updt_task,
     vp.updt_applctx = reqinfo->updt_applctx, vp.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   INSERT  FROM name_value_prefs nvp,
     (dummyt d1  WITH seq = value(internal->pviewcomp[x].nv_cnt))
    SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
     "VIEW_COMP_PREFS",
     nvp.parent_entity_id = vp_id, nvp.pvc_name = internal->pviewcomp[x].nv[d1.seq].pvc_name, nvp
     .pvc_value = internal->pviewcomp[x].nv[d1.seq].pvc_value,
     nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
     updt_id,
     nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
    PLAN (d1)
     JOIN (nvp)
    WITH nocounter
   ;end insert
   IF (curqual != value(internal->pviewcomp[x].nv_cnt))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
 ELSE
  IF (failed="D")
   SET reqinfo->commit_ind = 0
  ELSE
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
END GO
