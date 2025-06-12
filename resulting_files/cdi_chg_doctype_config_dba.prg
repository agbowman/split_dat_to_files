CREATE PROGRAM cdi_chg_doctype_config:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE doctype_rows = i4 WITH noconstant(value(size(request->document_type_list,5))), protect
 DECLARE ins_dt_rows = i4 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH noconstant(" "), protect
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE j = i4 WITH noconstant(0), protect
 DECLARE cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(100)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET errmsg = fillstring(255," ")
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 IF (doctype_rows > 0)
  SET cur_list_size = doctype_rows
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET idx = 0
  SET nstart = 1
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DOCUMENT_TYPE"
  SELECT INTO "NL:"
   cdt.updt_cnt
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    cdi_document_type cdt
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cdt
    WHERE expand(idx,nstart,minval((nstart+ (batch_size - 1)),cur_list_size),cdt.cdi_document_type_id,
     request->document_type_list[idx].cdi_document_type_id,
     cdt.updt_cnt,request->document_type_list[idx].updt_cnt)
     AND cdt.cdi_document_type_id > 0)
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1)
   WITH nocounter, forupdate(cdt)
  ;end select
  IF (rows_to_update_count > 0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DOCUMENT_TYPE"
   UPDATE  FROM cdi_document_type cdt,
     (dummyt d  WITH seq = doctype_rows)
    SET cdt.event_cd = request->document_type_list[d.seq].event_cd, cdt.code_set = request->
     document_type_list[d.seq].code_set, cdt.cdi_ac_batchclass_id = 0,
     cdt.combine_ind = request->document_type_list[d.seq].combine_ind, cdt.combine_all_ind = request
     ->document_type_list[d.seq].combine_all_ind, cdt.max_page_cnt = request->document_type_list[d
     .seq].max_page_cnt,
     cdt.default_date_of_service_flag = request->document_type_list[d.seq].
     default_date_of_service_flag, cdt.category_cd = request->document_type_list[d.seq].category_cd,
     cdt.send_to_manual_ind = request->document_type_list[d.seq].send_to_manual_ind,
     cdt.updt_cnt = (cdt.updt_cnt+ 1), cdt.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdt.updt_task
      = reqinfo->updt_task,
     cdt.updt_id = reqinfo->updt_id, cdt.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cdt
     WHERE (cdt.cdi_document_type_id=request->document_type_list[d.seq].cdi_document_type_id)
      AND (cdt.updt_cnt=request->document_type_list[d.seq].updt_cnt)
      AND cdt.cdi_document_type_id != 0.0)
    WITH nocounter
   ;end update
   IF (curqual != rows_to_update_count)
    SET errcode = error(errmsg,1)
    GO TO exit_script
   ENDIF
  ENDIF
  SET ins_dt_rows = (doctype_rows - rows_to_update_count)
  FREE RECORD tmp_doctype
  RECORD tmp_doctype(
    1 doctypes[*]
      2 cdi_document_type_id = f8
  )
  SET stat = alterlist(tmp_doctype->doctypes,ins_dt_rows)
  EXECUTE dm2_dar_get_bulk_seq "tmp_doctype->doctypes", ins_dt_rows, "cdi_document_type_id",
  1, "CDI_SEQ"
  SET j = 1
  FOR (i = 1 TO doctype_rows)
    IF ((request->document_type_list[i].cdi_document_type_id=0.0)
     AND (request->document_type_list[i].updt_cnt=0.0))
     SET request->document_type_list[i].cdi_document_type_id = tmp_doctype->doctypes[j].
     cdi_document_type_id
     SET j = (j+ 1)
    ELSE
     SET request->document_type_list[i].updt_cnt = - (1)
    ENDIF
  ENDFOR
  SET stat = alterlist(tmp_doctype->doctypes,0)
  IF (ins_dt_rows > 0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DOCUMENT_TYPE"
   INSERT  FROM cdi_document_type cdt,
     (dummyt d  WITH seq = doctype_rows)
    SET cdt.cdi_document_type_id = request->document_type_list[d.seq].cdi_document_type_id, cdt
     .event_cd = request->document_type_list[d.seq].event_cd, cdt.code_set = request->
     document_type_list[d.seq].code_set,
     cdt.cdi_ac_batchclass_id = 0, cdt.combine_ind = request->document_type_list[d.seq].combine_ind,
     cdt.combine_all_ind = request->document_type_list[d.seq].combine_all_ind,
     cdt.max_page_cnt = request->document_type_list[d.seq].max_page_cnt, cdt.category_cd = request->
     document_type_list[d.seq].category_cd, cdt.send_to_manual_ind = request->document_type_list[d
     .seq].send_to_manual_ind,
     cdt.default_date_of_service_flag = request->document_type_list[d.seq].
     default_date_of_service_flag, cdt.delete_first_ind = 0, cdt.updt_cnt = 0,
     cdt.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdt.updt_task = reqinfo->updt_task, cdt.updt_id
      = reqinfo->updt_id,
     cdt.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (request->document_type_list[d.seq].updt_cnt=0))
     JOIN (cdt)
    WITH nocounter
   ;end insert
   IF ((curqual != (doctype_rows - rows_to_update_count)))
    SET errcode = error(errmsg,1)
    GO TO exit_script
   ENDIF
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  FREE RECORD temp
  RECORD temp(
    1 subtypes[*]
      2 cdi_document_type_id = f8
      2 cdi_document_subtype_id = f8
      2 alias = vc
      2 subject = vc
      2 combine_ind = i2
      2 combine_all_ind = i2
      2 max_page_cnt = i4
      2 updt_cnt = i4
      2 default_date_of_service_flag = i2
      2 contributor_source_cd = f8
  )
  DECLARE subtype_rows = i4 WITH noconstant(0), protect
  FOR (i = 1 TO doctype_rows)
    FOR (j = 1 TO size(request->document_type_list[i].subtype_list,5))
      SET subtype_rows = (subtype_rows+ 1)
      IF (subtype_rows > size(temp->subtypes,5))
       SET stat = alterlist(temp->subtypes,(subtype_rows+ 9))
      ENDIF
      SET temp->subtypes[subtype_rows].cdi_document_type_id = request->document_type_list[i].
      cdi_document_type_id
      SET temp->subtypes[subtype_rows].cdi_document_subtype_id = request->document_type_list[i].
      subtype_list[j].cdi_document_subtype_id
      SET temp->subtypes[subtype_rows].alias = request->document_type_list[i].subtype_list[j].alias
      SET temp->subtypes[subtype_rows].subject = request->document_type_list[i].subtype_list[j].
      subject
      SET temp->subtypes[subtype_rows].combine_ind = request->document_type_list[i].subtype_list[j].
      combine_ind
      SET temp->subtypes[subtype_rows].combine_all_ind = request->document_type_list[i].subtype_list[
      j].combine_all_ind
      SET temp->subtypes[subtype_rows].max_page_cnt = request->document_type_list[i].subtype_list[j].
      max_page_cnt
      SET temp->subtypes[subtype_rows].updt_cnt = request->document_type_list[i].subtype_list[j].
      updt_cnt
      SET temp->subtypes[subtype_rows].default_date_of_service_flag = request->document_type_list[i].
      subtype_list[j].default_date_of_service_flag
      SET temp->subtypes[subtype_rows].contributor_source_cd = request->document_type_list[i].
      subtype_list[j].contributor_source_cd
    ENDFOR
  ENDFOR
  SET stat = alterlist(temp->subtypes,subtype_rows)
  SET cur_list_size = subtype_rows
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET idx = 0
  SET nstart = 1
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DOCUMENT_SUBTYPE"
  SET rows_to_update_count = 0
  SELECT INTO "NL:"
   cdt.updt_cnt
   FROM (dummyt d2  WITH seq = value(loop_cnt)),
    cdi_document_subtype cds
   PLAN (d2
    WHERE initarray(nstart,evaluate(d2.seq,1,1,(nstart+ batch_size))))
    JOIN (cds
    WHERE expand(idx,nstart,minval((nstart+ (batch_size - 1)),cur_list_size),cds
     .cdi_document_subtype_id,temp->subtypes[idx].cdi_document_subtype_id,
     cds.updt_cnt,temp->subtypes[idx].updt_cnt)
     AND cds.cdi_document_subtype_id > 0)
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1)
   WITH nocounter, forupdate(cds)
  ;end select
  IF (rows_to_update_count > 0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DOCUMENT_SUBTYPE"
   UPDATE  FROM cdi_document_subtype cds,
     (dummyt d  WITH seq = subtype_rows)
    SET cds.cdi_document_type_id = temp->subtypes[d.seq].cdi_document_type_id, cds
     .document_type_alias = temp->subtypes[d.seq].alias, cds.subject = temp->subtypes[d.seq].subject,
     cds.combine_ind = temp->subtypes[d.seq].combine_ind, cds.combine_all_ind = temp->subtypes[d.seq]
     .combine_all_ind, cds.max_page_cnt = temp->subtypes[d.seq].max_page_cnt,
     cds.default_date_of_service_flag = temp->subtypes[d.seq].default_date_of_service_flag, cds
     .contributor_source_cd = temp->subtypes[d.seq].contributor_source_cd, cds.updt_cnt = (cds
     .updt_cnt+ 1),
     cds.updt_dt_tm = cnvtdatetime(curdate,curtime3), cds.updt_task = reqinfo->updt_task, cds.updt_id
      = reqinfo->updt_id,
     cds.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cds
     WHERE (cds.cdi_document_subtype_id=temp->subtypes[d.seq].cdi_document_subtype_id)
      AND (cds.updt_cnt=temp->subtypes[d.seq].updt_cnt)
      AND cds.cdi_document_subtype_id != 0.0)
    WITH nocounter
   ;end update
   IF (curqual != rows_to_update_count)
    SET errcode = error(errmsg,1)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (rows_to_update_count < subtype_rows)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_DOCUMENT_SUBTYPE"
   INSERT  FROM cdi_document_subtype cds,
     (dummyt d  WITH seq = subtype_rows)
    SET cds.cdi_document_subtype_id = seq(cdi_seq,nextval), cds.cdi_document_type_id = temp->
     subtypes[d.seq].cdi_document_type_id, cds.document_type_alias = temp->subtypes[d.seq].alias,
     cds.subject = temp->subtypes[d.seq].subject, cds.combine_ind = temp->subtypes[d.seq].combine_ind,
     cds.combine_all_ind = temp->subtypes[d.seq].combine_all_ind,
     cds.max_page_cnt = temp->subtypes[d.seq].max_page_cnt, cds.default_date_of_service_flag = temp->
     subtypes[d.seq].default_date_of_service_flag, cds.contributor_source_cd = temp->subtypes[d.seq].
     contributor_source_cd,
     cds.updt_cnt = 0, cds.updt_dt_tm = cnvtdatetime(curdate,curtime3), cds.updt_task = reqinfo->
     updt_task,
     cds.updt_id = reqinfo->updt_id, cds.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (temp->subtypes[d.seq].cdi_document_subtype_id=0.0))
     JOIN (cds)
    WITH nocounter
   ;end insert
   IF ((curqual != (subtype_rows - rows_to_update_count)))
    SET errcode = error(errmsg,1)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = " "
 SET reply->status_data.subeventstatus[1].targetobjectname = " "
 SET reply->status_data.subeventstatus[1].targetobjectvalue = " "
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
