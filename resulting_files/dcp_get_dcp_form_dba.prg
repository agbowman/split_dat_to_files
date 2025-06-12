CREATE PROGRAM dcp_get_dcp_form:dba
 RECORD reply(
   1 dcp_forms_ref_id = f8
   1 dcp_form_instance_id = f8
   1 description = vc
   1 definition = vc
   1 task_assay_cd = f8
   1 task_assay_disp = vc
   1 event_cd = f8
   1 event_cd_disp = vc
   1 done_charting_ind = i2
   1 active_ind = i2
   1 height = i4
   1 width = i4
   1 flags = i4
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 updt_cnt = i4
   1 sect_cnt = i2
   1 text_rendition_event_cd = f8
   1 sect_list[*]
     2 dcp_forms_def_id = f8
     2 section_seq = i4
     2 dcp_section_ref_id = f8
     2 dcp_section_instance_id = f8
     2 description = vc
     2 definition = vc
     2 flags = i4
     2 width = i4
     2 height = i4
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 event_cd = f8
     2 event_disp = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
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
 IF ((request->version_dt_tm=null))
  CALL echo("no date")
 ENDIF
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id, dfd.dcp_forms_def_id, dfd.section_seq,
  dsr.dcp_section_ref_id
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr
  PLAN (dfr
   WHERE (dfr.dcp_forms_ref_id=request->dcp_forms_ref_id)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(request->version_dt_tm)
    AND dfr.end_effective_dt_tm > cnvtdatetime(request->version_dt_tm))
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id)
   JOIN (dsr
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND dsr.beg_effective_dt_tm <= cnvtdatetime(request->version_dt_tm)
    AND dsr.end_effective_dt_tm > cnvtdatetime(request->version_dt_tm))
  ORDER BY dfd.section_seq
  HEAD REPORT
   count1 = 0, reply->dcp_forms_ref_id = dfr.dcp_forms_ref_id, reply->dcp_form_instance_id = dfr
   .dcp_form_instance_id,
   reply->description = dfr.description, reply->definition = dfr.definition, reply->task_assay_cd =
   dfr.task_assay_cd,
   reply->event_cd = dfr.event_cd, reply->done_charting_ind = dfr.done_charting_ind, reply->
   active_ind = dfr.active_ind,
   reply->width = dfr.width, reply->height = dfr.height, reply->flags = dfr.flags,
   reply->beg_effective_dt_tm = dfr.beg_effective_dt_tm, reply->end_effective_dt_tm = dfr
   .end_effective_dt_tm, reply->updt_cnt = dfr.updt_cnt,
   reply->text_rendition_event_cd = dfr.text_rendition_event_cd, reply->event_set_name = dfr
   .event_set_name
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->sect_list,5))
    stat = alterlist(reply->sect_list,(count1+ 10))
   ENDIF
   reply->sect_list[count1].dcp_forms_def_id = dfd.dcp_forms_def_id, reply->sect_list[count1].
   section_seq = dfd.section_seq, reply->sect_list[count1].dcp_section_ref_id = dsr
   .dcp_section_ref_id,
   reply->sect_list[count1].dcp_section_instance_id = dsr.dcp_section_instance_id, reply->sect_list[
   count1].description = dsr.description, reply->sect_list[count1].definition = dsr.definition,
   reply->sect_list[count1].flags = dfd.flags, reply->sect_list[count1].task_assay_cd = dsr
   .task_assay_cd, reply->sect_list[count1].event_cd = dsr.event_cd,
   reply->sect_list[count1].active_ind = dsr.active_ind, reply->sect_list[count1].width = dsr.width,
   reply->sect_list[count1].height = dsr.height,
   reply->sect_list[count1].beg_effective_dt_tm = dsr.beg_effective_dt_tm, reply->sect_list[count1].
   end_effective_dt_tm = dsr.end_effective_dt_tm, reply->sect_list[count1].updt_cnt = dsr.updt_cnt
  FOOT REPORT
   reply->sect_cnt = count1, stat = alterlist(reply->sect_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 CALL echo(build("form desc:",reply->description))
 CALL echo(build("sect cnt:",reply->sect_cnt))
 FOR (x = 1 TO count1)
   CALL echo(build("--desc:",reply->sect_list[x].description))
 ENDFOR
END GO
