CREATE PROGRAM cdi_add_form_activity:dba
 IF (validate(reply->status_data.status)=0)
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
 RECORD temp_activities(
   1 activities[*]
     2 cdi_form_activity_id = f8
 )
 RECORD temp_fields(
   1 fields[*]
     2 cdi_form_field_activity_id = f8
     2 cdi_form_activity_id = f8
     2 cdi_form_field_id = f8
     2 field_status_flag = i2
     2 page_nbr = i4
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE inserted_rows = i4 WITH noconstant(0), protect
 DECLARE total_field_cnt = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_form_activity"
 SET req_size = value(size(request->activities,5))
 IF (req_size > 0)
  SELECT DISTINCT INTO "nl:"
   frm.cdi_form_id, frm.cdi_document_subtype_id
   FROM cdi_form frm
   PLAN (frm
    WHERE frm.cdi_form_id > 0
     AND expand(idx,1,req_size,frm.cdi_form_id,request->activities[idx].cdi_form_id))
   DETAIL
    FOR (idx = 1 TO req_size)
      IF ((request->activities[idx].cdi_form_id=frm.cdi_form_id))
       request->activities[idx].cdi_document_subtype_id = frm.cdi_document_subtype_id
      ENDIF
    ENDFOR
  ;end select
  SET stat = alterlist(temp_activities->activities,req_size)
  EXECUTE dm2_dar_get_bulk_seq "temp_activities->activities", req_size, "cdi_form_activity_id",
  1, "CDI_SEQ"
  FOR (i = 1 TO req_size)
    SET field_cnt = size(request->activities[i].fields,5)
    SET stat = alterlist(temp_fields->fields,(total_field_cnt+ field_cnt))
    FOR (j = 1 TO field_cnt)
      SET total_field_cnt = (total_field_cnt+ 1)
      SET temp_fields->fields[total_field_cnt].cdi_form_activity_id = temp_activities->activities[i].
      cdi_form_activity_id
      SET temp_fields->fields[total_field_cnt].cdi_form_field_id = request->activities[i].fields[j].
      cdi_form_field_id
      SET temp_fields->fields[total_field_cnt].field_status_flag = request->activities[i].fields[j].
      field_status_flag
      SET temp_fields->fields[total_field_cnt].page_nbr = request->activities[i].fields[j].page_nbr
    ENDFOR
  ENDFOR
  IF (total_field_cnt > 0)
   SET stat = alterlist(temp_fields->fields,total_field_cnt)
   EXECUTE dm2_dar_get_bulk_seq "temp_fields->fields", total_field_cnt, "cdi_form_field_activity_id",
   1, "CDI_SEQ"
  ENDIF
  INSERT  FROM cdi_form_activity fa,
    (dummyt d  WITH seq = req_size)
   SET fa.cdi_form_activity_id = temp_activities->activities[d.seq].cdi_form_activity_id, fa
    .activity_dt_tm = cnvtdatetime(request->activities[d.seq].activity_dt_tm), fa.event_cd = request
    ->activities[d.seq].event_cd,
    fa.event_code_set = request->activities[d.seq].event_code_set, fa.parent_entity_id = request->
    activities[d.seq].parent_entity_id, fa.parent_entity_name = request->activities[d.seq].
    parent_entity_name,
    fa.reason_cd = request->activities[d.seq].reason_cd, fa.reason_text = request->activities[d.seq].
    reason_text, fa.blob_handle = request->activities[d.seq].blob_handle,
    fa.blob_ref_id = request->activities[d.seq].blob_ref_id, fa.cdi_document_subtype_id = request->
    activities[d.seq].cdi_document_subtype_id, fa.event_id = request->activities[d.seq].event_id,
    fa.form_status_flag = request->activities[d.seq].form_status_flag, fa.cdi_form_id = request->
    activities[d.seq].cdi_form_id, fa.updt_cnt = 0,
    fa.updt_dt_tm = cnvtdatetime(curdate,curtime3), fa.updt_task = reqinfo->updt_task, fa.updt_id =
    reqinfo->updt_id,
    fa.updt_applctx = reqinfo->updt_applctx, fa.source_event_id = request->activities[d.seq].
    source_event_id
   PLAN (d)
    JOIN (fa)
   WITH nocounter
  ;end insert
  SET inserted_rows = curqual
  IF (inserted_rows < req_size)
   SET ecode = 0
   SET emsg = fillstring(200," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_ACTIVITY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   GO TO exit_script
  ENDIF
  IF (total_field_cnt > 0)
   INSERT  FROM cdi_form_field_activity ffa,
     (dummyt d  WITH seq = total_field_cnt)
    SET ffa.cdi_form_field_activity_id = temp_fields->fields[d.seq].cdi_form_field_activity_id, ffa
     .cdi_form_activity_id = temp_fields->fields[d.seq].cdi_form_activity_id, ffa.cdi_form_field_id
      = temp_fields->fields[d.seq].cdi_form_field_id,
     ffa.field_status_flag = temp_fields->fields[d.seq].field_status_flag, ffa.page_nbr = temp_fields
     ->fields[d.seq].page_nbr, ffa.updt_cnt = 0,
     ffa.updt_dt_tm = cnvtdatetime(curdate,curtime3), ffa.updt_task = reqinfo->updt_task, ffa.updt_id
      = reqinfo->updt_id,
     ffa.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (ffa)
    WITH nocounter
   ;end insert
   SET inserted_rows = curqual
   IF (inserted_rows < total_field_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_FIELD_ACTIVITY"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
