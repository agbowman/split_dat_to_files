CREATE PROGRAM dcp_upd_dcp_form_all:dba
 RECORD reply(
   1 dcp_forms_ref_id = f8
   1 section_cnt = i4
   1 sections[*]
     2 dcp_section_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 dir_list[*]
     2 dcp_input_ref_id = f8
 )
 SET reply->status_data.status = "F"
 SET new_form = 0
 SET dcp_forms_ref_id = 0
 SET new_sect = 0
 SET dcp_section_ref_id = 0
 SET dcp_input_ref_id = 0
 SET nvp_id = 0
 SET nv_cnt = 0
 SET count1 = 0
 SET input_cnt = 0
 IF ((request->sect_info_passed_ind=1))
  SET sect_cnt = size(request->sect_list,5)
 ELSE
  SET sect_cnt = 0
 ENDIF
 IF ((request->dcp_forms_ref_id > 0))
  SET dcp_forms_ref_id = request->dcp_forms_ref_id
  SET new_form = 0
 ELSE
  SET new_form = 1
 ENDIF
 IF ((request->beg_effective_dt_tm=null))
  SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF ((request->end_effective_dt_tm=null))
  SET request->end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
 ENDIF
 IF (new_form=0)
  UPDATE  FROM dcp_forms_ref dfr
   SET dfr.description = request->description, dfr.definition = request->definition, dfr
    .task_assay_cd = request->task_assay_cd,
    dfr.event_cd = request->event_cd, dfr.done_charting_ind = request->done_charting_ind, dfr
    .active_ind = request->active_ind,
    dfr.width = request->width, dfr.height = request->height, dfr.flags = request->flags,
    dfr.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), dfr.end_effective_dt_tm =
    cnvtdatetime(request->end_effective_dt_tm), dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    dfr.updt_id = reqinfo->updt_id, dfr.updt_task = reqinfo->updt_task, dfr.updt_applctx = reqinfo->
    updt_applctx,
    dfr.updt_cnt = (dfr.updt_cnt+ 1)
   WHERE (dfr.dcp_forms_ref_id=request->dcp_forms_ref_id)
   WITH nocounter
  ;end update
 ELSE
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    dcp_forms_ref_id = cnvtint(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM dcp_forms_ref d
   SET d.dcp_forms_ref_id = dcp_forms_ref_id, d.description = request->description, d.definition =
    request->definition,
    d.task_assay_cd = request->task_assay_cd, d.event_cd = request->event_cd, d.done_charting_ind =
    request->done_charting_ind,
    d.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), d.end_effective_dt_tm =
    cnvtdatetime(request->end_effective_dt_tm), d.active_ind = 1,
    d.width = request->width, d.height = request->height, d.flags = request->flags,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
    reqinfo->updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 IF ((request->sect_info_passed_ind != 1))
  GO TO exit_script
 ENDIF
 DELETE  FROM dcp_forms_def dfd
  WHERE dfd.dcp_forms_ref_id=dcp_forms_ref_id
  WITH nocounter
 ;end delete
 SET reply->section_cnt = sect_cnt
 SET stat = alterlist(reply->sections,sect_cnt)
 FOR (x = 1 TO sect_cnt)
   IF ((request->sect_list[x].beg_effective_dt_tm=null))
    SET request->sect_list[x].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF ((request->sect_list[x].end_effective_dt_tm=null))
    SET request->sect_list[x].end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
   ENDIF
   IF ((request->sect_list[x].dcp_section_ref_id > 0))
    SET dcp_section_ref_id = request->sect_list[x].dcp_section_ref_id
    SET reply->sections[x].dcp_section_ref_id = dcp_section_ref_id
    UPDATE  FROM dcp_section_ref dsr
     SET dsr.description = request->sect_list[x].description, dsr.definition = request->sect_list[x].
      definition, dsr.task_assay_cd = request->sect_list[x].task_assay_cd,
      dsr.event_cd = request->sect_list[x].event_cd, dsr.active_ind = request->sect_list[x].
      active_ind, dsr.width = request->sect_list[x].width,
      dsr.height = request->sect_list[x].height, dsr.beg_effective_dt_tm = cnvtdatetime(request->
       sect_list[x].beg_effective_dt_tm), dsr.end_effective_dt_tm = cnvtdatetime(request->sect_list[x
       ].end_effective_dt_tm),
      dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsr.updt_id = reqinfo->updt_id, dsr.updt_task
       = reqinfo->updt_task,
      dsr.updt_applctx = reqinfo->updt_applctx, dsr.updt_cnt = (dsr.updt_cnt+ 1)
     WHERE (dsr.dcp_section_ref_id=request->sect_list[x].dcp_section_ref_id)
     WITH nocounter
    ;end update
   ELSE
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      dcp_section_ref_id = cnvtint(j), reply->sections[x].dcp_section_ref_id = dcp_section_ref_id
     WITH format, nocounter
    ;end select
    INSERT  FROM dcp_section_ref d
     SET d.dcp_section_ref_id = dcp_section_ref_id, d.description = request->sect_list[x].description,
      d.definition = request->sect_list[x].definition,
      d.task_assay_cd = request->sect_list[x].task_assay_cd, d.event_cd = request->sect_list[x].
      event_cd, d.beg_effective_dt_tm = cnvtdatetime(request->sect_list[x].beg_effective_dt_tm),
      d.end_effective_dt_tm = cnvtdatetime(request->sect_list[x].end_effective_dt_tm), d.active_ind
       = 1, d.width = request->sect_list[x].width,
      d.height = request->sect_list[x].height, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
      .updt_id = reqinfo->updt_id,
      d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->sect_list[x].input_info_passed_ind=1))
    SET input_cnt = size(request->sect_list[x].input_list,5)
    SET count1 = 0
    SELECT INTO "nl:"
     dir.dcp_input_ref_id
     FROM dcp_input_ref dir
     PLAN (dir
      WHERE dir.dcp_section_ref_id=dcp_section_ref_id)
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 = (count1+ 1)
      IF (count1 > size(temp->dir_list,5))
       stat = alterlist(temp->dir_list,(count1+ 5))
      ENDIF
      temp->dir_list[count1].dcp_input_ref_id = dir.dcp_input_ref_id
     FOOT REPORT
      stat = alterlist(temp->dir_list,count1)
     WITH nocounter
    ;end select
    FOR (y = 1 TO count1)
     DELETE  FROM dcp_input_ref dir
      WHERE (dir.dcp_input_ref_id=temp->dir_list[y].dcp_input_ref_id)
      WITH nocounter
     ;end delete
     DELETE  FROM name_value_prefs nvp
      WHERE (nvp.parent_entity_id=temp->dir_list[y].dcp_input_ref_id)
       AND nvp.parent_entity_name="DCP_INPUT_REF"
      WITH nocounter
     ;end delete
    ENDFOR
    FOR (y = 1 TO input_cnt)
      IF ((request->sect_list[x].input_list[y].input_type > 0))
       IF ((request->sect_list[x].input_list[y].dcp_input_ref_id > 0))
        SET dcp_input_ref_id = request->sect_list[x].input_list[y].dcp_input_ref_id
       ELSE
        SELECT INTO "nl:"
         j = seq(carenet_seq,nextval)
         FROM dual
         DETAIL
          dcp_input_ref_id = cnvtint(j)
         WITH format, nocounter
        ;end select
       ENDIF
       INSERT  FROM dcp_input_ref dir
        SET dir.dcp_input_ref_id = dcp_input_ref_id, dir.dcp_section_ref_id = dcp_section_ref_id, dir
         .description = request->sect_list[x].input_list[y].description,
         dir.input_ref_seq = request->sect_list[x].input_list[y].input_ref_seq, dir.input_type =
         request->sect_list[x].input_list[y].input_type, dir.active_ind = 1,
         dir.updt_cnt = 0, dir.updt_dt_tm = cnvtdatetime(curdate,curtime3), dir.updt_id = reqinfo->
         updt_id,
         dir.updt_task = reqinfo->updt_task, dir.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       SET nv_cnt = size(request->sect_list[x].input_list[y].nv,5)
       FOR (z = 1 TO nv_cnt)
         IF ((request->sect_list[x].input_list[y].nv[z].pvc_name > " "))
          SELECT INTO "nl:"
           j = seq(carenet_seq,nextval)
           FROM dual
           DETAIL
            nvp_id = cnvtint(j)
           WITH format, nocounter
          ;end select
          INSERT  FROM name_value_prefs nvp
           SET nvp.name_value_prefs_id = nvp_id, nvp.parent_entity_name = "DCP_INPUT_REF", nvp
            .parent_entity_id = dcp_input_ref_id,
            nvp.pvc_name = request->sect_list[x].input_list[y].nv[z].pvc_name, nvp.pvc_value =
            request->sect_list[x].input_list[y].nv[z].pvc_value, nvp.merge_name = request->sect_list[
            x].input_list[y].nv[z].merge_name,
            nvp.merge_id = request->sect_list[x].input_list[y].nv[z].merge_id, nvp.sequence = request
            ->sect_list[x].input_list[y].nv[z].sequence, nvp.active_ind = 1,
            nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
            .updt_task = reqinfo->updt_task,
            nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
           WITH nocounter
          ;end insert
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   INSERT  FROM dcp_forms_def dfd
    SET dfd.dcp_forms_def_id = seq(carenet_seq,nextval), dfd.dcp_forms_ref_id = dcp_forms_ref_id, dfd
     .dcp_section_ref_id = dcp_section_ref_id,
     dfd.section_seq = request->sect_list[x].section_seq, dfd.flags = request->sect_list[x].flags,
     dfd.active_ind = 1,
     dfd.updt_cnt = 0, dfd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfd.updt_id = reqinfo->
     updt_id,
     dfd.updt_task = reqinfo->updt_task, dfd.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->dcp_forms_ref_id = dcp_forms_ref_id
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET temp_dcp_forms_ref_id = dcp_forms_ref_id
 EXECUTE dcp_add_td_r
END GO
