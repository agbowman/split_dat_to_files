CREATE PROGRAM dcp_get_dcp_form_all:dba
 RECORD reply(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 definition = vc
   1 task_assay_cd = f8
   1 task_assay_disp = vc
   1 event_cd = f8
   1 event_cd_disp = vc
   1 done_charting_ind = i2
   1 active_ind = i2
   1 width = i4
   1 height = i4
   1 flags = i4
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 updt_cnt = i4
   1 sect_cnt = i2
   1 sect_list[*]
     2 dcp_forms_def_id = f8
     2 section_seq = i4
     2 dcp_section_ref_id = f8
     2 description = vc
     2 definition = vc
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 event_cd = f8
     2 event_disp = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 input_cnt = i2
     2 input_list[*]
       3 dcp_input_ref_id = f8
       3 input_ref_seq = i4
       3 description = vc
       3 module = vc
       3 input_type = i4
       3 updt_cnt = i4
       3 nv_cnt = i2
       3 nv[*]
         4 pvc_name = vc
         4 pvc_value = vc
         4 merge_id = f8
         4 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 event_set_name = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id, dfd.dcp_forms_def_id, dfd.section_seq,
  dsr.dcp_section_ref_id, dir.dcp_input_ref_id, dir.input_ref_seq,
  nvp.name_value_prefs_id
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   (dummyt d1  WITH seq = 1),
   dcp_input_ref dir,
   (dummyt d  WITH seq = 1),
   name_value_prefs nvp
  PLAN (dfr
   WHERE (dfr.dcp_forms_ref_id=request->dcp_forms_ref_id))
   JOIN (dfd
   WHERE dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfd.active_ind=1)
   JOIN (dsr
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id)
   JOIN (d1)
   JOIN (dir
   WHERE dir.dcp_section_ref_id=dsr.dcp_section_ref_id)
   JOIN (d)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.parent_entity_name="DCP_INPUT_REF"
    AND nvp.active_ind=1)
  ORDER BY dfd.section_seq, dir.input_ref_seq, dir.dcp_input_ref_id
  HEAD REPORT
   count1 = 0, reply->dcp_forms_ref_id = dfr.dcp_forms_ref_id, reply->description = dfr.description,
   reply->definition = dfr.definition, reply->task_assay_cd = dfr.task_assay_cd, reply->event_cd =
   dfr.event_cd,
   reply->flags = dfr.flags, reply->done_charting_ind = dfr.done_charting_ind, reply->active_ind =
   dfr.active_ind,
   reply->width = dfr.width, reply->height = dfr.height, reply->beg_effective_dt_tm = dfr
   .beg_effective_dt_tm,
   reply->end_effective_dt_tm = dfr.end_effective_dt_tm, reply->updt_cnt = dfr.updt_cnt, reply->
   event_set_name = dfr.event_set_name
  HEAD dfd.section_seq
   count1 = (count1+ 1), count2 = 0
   IF (count1 > size(reply->sect_list,5))
    stat = alterlist(reply->sect_list,(count1+ 10))
   ENDIF
   reply->sect_list[count1].dcp_forms_def_id = dfd.dcp_forms_def_id, reply->sect_list[count1].
   section_seq = dfd.section_seq, reply->sect_list[count1].dcp_section_ref_id = dsr
   .dcp_section_ref_id,
   reply->sect_list[count1].description = dsr.description, reply->sect_list[count1].definition = dsr
   .definition, reply->sect_list[count1].task_assay_cd = dsr.task_assay_cd,
   reply->sect_list[count1].event_cd = dsr.event_cd, reply->sect_list[count1].active_ind = dsr
   .active_ind, reply->sect_list[count1].beg_effective_dt_tm = dsr.beg_effective_dt_tm,
   reply->sect_list[count1].end_effective_dt_tm = dsr.end_effective_dt_tm, reply->sect_list[count1].
   updt_cnt = dsr.updt_cnt
  HEAD dir.dcp_input_ref_id
   IF (dir.dcp_input_ref_id > 0)
    count2 = (count2+ 1)
    IF (count2 > size(reply->sect_list[count1].input_list,5))
     stat = alterlist(reply->sect_list[count1].input_list,(count2+ 10))
    ENDIF
    reply->sect_list[count1].input_list[count2].dcp_input_ref_id = dir.dcp_input_ref_id, reply->
    sect_list[count1].input_list[count2].input_ref_seq = dir.input_ref_seq, reply->sect_list[count1].
    input_list[count2].description = dir.description,
    reply->sect_list[count1].input_list[count2].module = dir.module, reply->sect_list[count1].
    input_list[count2].input_type = dir.input_type, reply->sect_list[count1].input_list[count2].
    updt_cnt = dir.updt_cnt
   ENDIF
   count3 = 0
  DETAIL
   IF (nvp.name_value_prefs_id > 0)
    count3 = (count3+ 1)
    IF (count3 > size(reply->sect_list[count1].input_list[count2].nv,5))
     stat = alterlist(reply->sect_list[count1].input_list[count2].nv,(count3+ 10))
    ENDIF
    reply->sect_list[count1].input_list[count2].nv[count3].pvc_name = nvp.pvc_name, reply->sect_list[
    count1].input_list[count2].nv[count3].pvc_value = nvp.pvc_value, reply->sect_list[count1].
    input_list[count2].nv[count3].merge_id = nvp.merge_id,
    reply->sect_list[count1].input_list[count2].nv[count3].sequence = nvp.sequence
   ENDIF
  FOOT  dir.dcp_input_ref_id
   IF (count2 > 0)
    reply->sect_list[count1].input_list[count2].nv_cnt = count3, stat = alterlist(reply->sect_list[
     count1].input_list[count2].nv,count3)
   ENDIF
  FOOT  dfd.section_seq
   reply->sect_list[count1].input_cnt = count2, stat = alterlist(reply->sect_list[count1].input_list,
    count2)
  FOOT REPORT
   reply->sect_cnt = count1, stat = alterlist(reply->sect_list,count1)
  WITH nocounter, outerjoin = d1, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("form desc:",reply->description))
 CALL echo(build("sect cnt:",reply->sect_cnt))
 FOR (x = 1 TO reply->sect_cnt)
   CALL echo(build("--sect desc:",reply->sect_list[x].description))
   CALL echo(build("--sect input cnt:",reply->sect_list[x].input_cnt))
   FOR (y = 1 TO reply->sect_list[x].input_cnt)
     CALL echo(build("----ic desc:",reply->sect_list[x].input_list[y].description))
     CALL echo(build("----ic nv cnt:",reply->sect_list[x].input_list[y].nv_cnt))
     FOR (z = 1 TO reply->sect_list[x].input_list[y].nv_cnt)
      CALL echo(build("------name:",reply->sect_list[x].input_list[y].nv[z].pvc_name))
      CALL echo(build("------value:",reply->sect_list[x].input_list[y].nv[z].pvc_value))
     ENDFOR
   ENDFOR
 ENDFOR
END GO
