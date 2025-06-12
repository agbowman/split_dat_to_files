CREATE PROGRAM cdi_add_trans_log:dba
 FREE RECORD batch_summary_rec
 RECORD batch_summary_rec(
   1 qual[*]
     2 external_batch_ident = i4
     2 create_dt_tm = dq8
     2 cdi_ac_batch_id = f8
     2 ecp_cnt = i4
     2 combined_cnt = i4
     2 cur_auto_cnt = i4
     2 auto_comp_cnt = i4
     2 tot_auto_time = f8
     2 cur_man_cnt = i4
     2 man_comp_cnt = i4
     2 tot_man_time = f8
     2 man_create_cnt = i4
     2 man_del_cnt = i4
     2 complete_cnt = i4
     2 ac_rel_cnt = i4
     2 ac_rel_dt_tm = dq8
     2 prep_comp_cnt = i4
     2 tot_prep_time = f8
     2 ac_scan_time = f8
     2 ac_valid_time = f8
     2 ac_rec_time = f8
     2 ac_verify_time = f8
     2 ac_qc_time = f8
     2 ac_rel_time = f8
     2 update_rec = i2
     2 status = i4
     2 cur_pharmacy_cnt = i4
     2 pharmacy_comp_cnt = i4
     2 tot_pharmacy_time = f8
     2 pharmacy_del_cnt = i4
     2 wq_combined_cnt = i4
     2 wq_create_cnt = i4
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE recinserted = i4 WITH noconstant(0), protect
 DECLARE my_active_ind = i4 WITH noconstant(0), protect
 DECLARE now_dt_tm = vc WITH noconstant(""), protect
 DECLARE time_diff = i4 WITH noconstant(0), protect
 DECLARE old_queue = vc WITH noconstant(""), protect
 DECLARE cur_rec = i2 WITH constant(1), protect
 DECLARE my_cdi_trans_log_id = f8 WITH noconstant(0.0), protect
 DECLARE queue_var = f8 WITH noconstant(0.0), protect
 DECLARE reason_var = f8 WITH noconstant(0.0), protect
 DECLARE my_cdi_queue = c12 WITH noconstant(""), protect
 DECLARE my_reason = c12 WITH noconstant(""), protect
 DECLARE now_date = i4 WITH noconstant(0), protect
 DECLARE now_time = i4 WITH noconstant(0), protect
 DECLARE new_cdi_trans_log_id = f8 WITH noconstant(0.0), protect
 DECLARE new_cdi_pending_document_id = f8 WITH noconstant(0.0), protect
 DECLARE mrn_code_val = f8 WITH public, noconstant(0.0)
 DECLARE fin_code_val = f8 WITH public, noconstant(0.0)
 DECLARE err_msg = c200 WITH public, noconstant(" ")
 DECLARE err_code = i4 WITH public, noconstant(0)
 DECLARE batchcreatedttm = dq8 WITH noconstant(0), protect
 DECLARE batchexternalid = i4 WITH noconstant(request->external_batch_ident), protect
 DECLARE interval = dq8 WITH noconstant(cnvtdatetime(cnvtdate(00000000),cnvtint(1))), protect
 DECLARE dt_start = dq8 WITH noconstant(0), protect
 DECLARE dt_end = dq8 WITH noconstant(0), protect
 DECLARE batchcreatedttmset = i2 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET now_date = curdate
 SET now_time = curtime3
 SET now_dt_tm = build2(format(now_date,"DD-MMM-YYYY;;D")," ",format(now_time,"HH:MM:SS;;M"))
 SET my_cdi_queue = request->cdi_queue
 SET my_reason = request->reason
 IF (textlen(trim(request->create_date)) > 0)
  SET batchcreatedttm = cnvtdatetime(cnvtdate(request->create_date),cnvtint(request->create_time))
 ENDIF
 IF (textlen(trim(request->create_date)) > 0
  AND (request->external_batch_ident > 0))
  SET dt_start = (batchcreatedttm - interval)
  SET dt_end = (batchcreatedttm+ interval)
  SELECT INTO "NL:"
   FROM cdi_batch_summary bs
   WHERE (request->external_batch_ident=bs.external_batch_ident)
    AND bs.create_dt_tm > cnvtdatetime(dt_start)
    AND bs.create_dt_tm < cnvtdatetime(dt_end)
   DETAIL
    batchcreatedttm = bs.create_dt_tm, batchcreatedttmset = 1, batchexternalid = bs
    .external_batch_ident
   WITH nocounter
  ;end select
 ENDIF
 IF (((textlen(trim(request->blob_handle)) > 0) OR ((request->cdi_queue="BATCH_PREP")
  AND (request->action_type_flag=3))) )
  SET my_active_ind = 1
  IF (textlen(trim(request->blob_handle)) > 0)
   SELECT INTO "NL:"
    cs.cdi_trans_log_id, cs.action_dt_tm, cs.cdi_queue_cd,
    cs.ax_appid, cs.ax_docid, cs.batch_name,
    cs.blob_ref_id, cs.blob_type_flag, cs.cdi_form_id,
    cs.create_dt_tm, cs.document_type_alias, cs.doc_type,
    cs.encntr_id, cs.event_cd, cs.event_id,
    cs.external_batch_ident, cs.financial_nbr, cs.mrn,
    cs.page_cnt, cs.parent_entity_alias, cs.parent_entity_id,
    cs.parent_entity_name, cs.patient_name, cs.person_id,
    cs.subject, cs.cdi_pending_document_id
    FROM cdi_trans_log cs
    WHERE cs.active_ind=1
     AND (cs.blob_handle=request->blob_handle)
    HEAD REPORT
     count = 0
    DETAIL
     count += 1, my_cdi_trans_log_id = cs.cdi_trans_log_id, time_diff = datetimediff(cnvtdatetime(
       now_dt_tm),cs.action_dt_tm,5),
     old_queue = uar_get_code_meaning(cs.cdi_queue_cd)
     IF (((old_queue="HNAM") OR (cs.action_type_flag=0)) )
      IF ((request->ax_appid=0.0))
       request->ax_appid = cs.ax_appid
      ENDIF
      IF ((request->ax_docid=0.0))
       request->ax_docid = cs.ax_docid
      ENDIF
      IF (size(trim(request->batch_name),1) < 1)
       request->batch_name = cs.batch_name
      ENDIF
      IF ((request->blob_ref_id=0.0))
       request->blob_ref_id = cs.blob_ref_id
      ENDIF
      IF ((request->blob_type_flag=0.0))
       request->blob_type_flag = cs.blob_type_flag
      ENDIF
      IF ((request->cdi_form_id=0.0))
       request->cdi_form_id = cs.cdi_form_id
      ENDIF
      IF (size(trim(request->cdi_queue),1) < 1)
       request->cdi_queue = old_queue, my_cdi_queue = old_queue
      ENDIF
      IF (batchcreatedttmset=0)
       batchcreatedttm = cs.create_dt_tm, batchexternalid = cs.external_batch_ident
      ENDIF
      IF (size(trim(request->document_type_alias),1) < 1)
       request->document_type_alias = cs.document_type_alias
      ENDIF
      IF (size(trim(request->doc_type),1) < 1)
       request->doc_type = cs.doc_type
      ENDIF
      IF ((request->encntr_id=0.0))
       request->encntr_id = cs.encntr_id
      ENDIF
      IF ((request->event_cd=0.0))
       request->event_cd = cs.event_cd
      ENDIF
      IF ((request->event_id=0.0))
       request->event_id = cs.event_id
      ENDIF
      IF ((request->external_batch_ident=0.0))
       request->external_batch_ident = cs.external_batch_ident
      ENDIF
      IF (size(trim(request->financial_nbr),1) < 1)
       request->financial_nbr = cs.financial_nbr
      ENDIF
      IF (size(trim(request->mrn),1) < 1)
       request->mrn = cs.mrn
      ENDIF
      IF ((request->page_cnt=0))
       request->page_cnt = cs.page_cnt
      ENDIF
      IF (size(trim(request->parent_entity_alias),1) < 1)
       request->parent_entity_alias = cs.parent_entity_alias
      ENDIF
      IF ((request->parent_entity_id=0.0))
       request->parent_entity_id = cs.parent_entity_id
      ENDIF
      IF (size(trim(request->parent_entity_name),1) < 1)
       request->parent_entity_name = cs.parent_entity_name
      ENDIF
      IF ((request->person_id=0.0))
       request->person_id = cs.person_id
      ENDIF
      IF (size(trim(request->subject),1) < 1)
       request->subject = cs.subject
      ENDIF
      IF (size(trim(request->patient_name),1) < 1)
       request->patient_name = cs.patient_name
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (count > 0)
    UPDATE  FROM cdi_trans_log c
     SET c.active_ind = 0
     WHERE c.cdi_trans_log_id=my_cdi_trans_log_id
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  IF (size(trim(request->create_date)) > 0)
   SET stat = alterlist(batch_summary_rec->qual,1)
   SET batch_summary_rec->qual[cur_rec].external_batch_ident = batchexternalid
   SET batch_summary_rec->qual[cur_rec].create_dt_tm = cnvtdatetime(batchcreatedttm)
   SET batch_summary_rec->qual[cur_rec].cdi_ac_batch_id = 0.0
   SET batch_summary_rec->qual[cur_rec].update_rec = 0
   IF ((request->action_type_flag=0))
    IF ((request->cdi_queue="AUTO_INDEX"))
     SET batch_summary_rec->qual[cur_rec].complete_cnt = 1
     SET batch_summary_rec->qual[cur_rec].cur_auto_cnt = - (1)
     SET batch_summary_rec->qual[cur_rec].auto_comp_cnt = 1
     SET batch_summary_rec->qual[cur_rec].tot_auto_time = time_diff
    ELSEIF ((request->cdi_queue="MAN_INDEX"))
     SET batch_summary_rec->qual[cur_rec].complete_cnt = 1
     SET batch_summary_rec->qual[cur_rec].cur_man_cnt = - (1)
     SET batch_summary_rec->qual[cur_rec].man_comp_cnt = 1
     SET batch_summary_rec->qual[cur_rec].tot_auto_time = time_diff
    ELSEIF ((request->cdi_queue="BATCH_PREP"))
     SET batch_summary_rec->qual[cur_rec].cur_man_cnt = 1
     SET batch_summary_rec->qual[cur_rec].prep_comp_cnt = 1
     SET batch_summary_rec->qual[cur_rec].tot_prep_time = time_diff
    ELSEIF ((request->cdi_queue="WORKQUEUE"))
     SET batch_summary_rec->qual[cur_rec].wq_create_cnt = 1
    ENDIF
   ELSEIF ((request->action_type_flag=1))
    IF ((request->cdi_queue="AUTO_INDEX"))
     SET batch_summary_rec->qual[cur_rec].cur_auto_cnt = - (1)
     SET batch_summary_rec->qual[cur_rec].auto_comp_cnt = 1
     SET batch_summary_rec->qual[cur_rec].tot_auto_time = time_diff
     SET batch_summary_rec->qual[cur_rec].cur_man_cnt = 1
    ENDIF
   ELSEIF ((request->action_type_flag=2))
    IF ((request->cdi_queue="MAN_INDEX"))
     SET batch_summary_rec->qual[cur_rec].cur_man_cnt = - (1)
     SET batch_summary_rec->qual[cur_rec].man_comp_cnt = 1
     SET batch_summary_rec->qual[cur_rec].tot_auto_time = time_diff
     SET batch_summary_rec->qual[cur_rec].cur_auto_cnt = 1
    ELSEIF ((request->cdi_queue="BATCH_PREP"))
     SET batch_summary_rec->qual[cur_rec].cur_auto_cnt = 1
     SET batch_summary_rec->qual[cur_rec].prep_comp_cnt = 1
     SET batch_summary_rec->qual[cur_rec].tot_prep_time = time_diff
    ENDIF
   ELSEIF ((request->action_type_flag=3))
    IF ((request->cdi_queue="AUTO_INDEX"))
     SET batch_summary_rec->qual[cur_rec].cur_auto_cnt = - (1)
    ELSEIF ((request->cdi_queue="MAN_INDEX"))
     SET batch_summary_rec->qual[cur_rec].cur_man_cnt = - (1)
     SET batch_summary_rec->qual[cur_rec].man_del_cnt = 1
    ELSEIF ((request->cdi_queue="HNAM"))
     SET batch_summary_rec->qual[cur_rec].complete_cnt = 1
    ELSEIF ((request->cdi_queue="PHARMACY"))
     SET batch_summary_rec->qual[cur_rec].cur_pharmacy_cnt = - (1)
     SET batch_summary_rec->qual[cur_rec].pharmacy_del_cnt = 1
    ELSEIF ((request->cdi_queue="BATCH_PREP"))
     IF (trim(my_reason)="COMBINED")
      SET batch_summary_rec->qual[cur_rec].combined_cnt = 1
     ELSEIF (trim(my_reason)="DEL_ECP")
      SET batch_summary_rec->qual[cur_rec].ecp_cnt = 1
     ENDIF
    ELSEIF ((request->cdi_queue="WORKQUEUE"))
     SET batch_summary_rec->qual[cur_rec].wq_combined_cnt = 1
    ENDIF
   ELSEIF ((request->action_type_flag=6))
    IF ((request->cdi_queue="AUTO_INDEX"))
     SET batch_summary_rec->qual[cur_rec].cur_auto_cnt = 1
    ELSEIF ((request->cdi_queue="MAN_INDEX"))
     IF (trim(my_reason)="CREATE")
      SET batch_summary_rec->qual[cur_rec].man_create_cnt = 1
     ENDIF
     SET batch_summary_rec->qual[cur_rec].cur_man_cnt = 1
    ELSEIF ((request->cdi_queue="PHARMACY"))
     SET batch_summary_rec->qual[cur_rec].cur_pharmacy_cnt = 1
    ENDIF
   ENDIF
   EXECUTE cdi_upd_batch_summary
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = "F"
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[cur_rec].targetobjectname = "cdi_upd_batch_summary"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET queue_var = uar_get_code_by("MEANING",257571,nullterm(my_cdi_queue))
 SET reason_var = uar_get_code_by("MEANING",257572,nullterm(my_reason))
 IF ((((request->action_type_flag=4)) OR ((request->action_type_flag=10))) )
  SET new_cdi_pending_document_id = 0.0
 ELSE
  IF (textlen(trim(request->blob_handle)) > 0)
   SELECT INTO "nl:"
    x = seq(cdi_seq,nextval)
    FROM dual
    DETAIL
     new_cdi_pending_document_id = x
    WITH nocounter
   ;end select
   UPDATE  FROM cdi_pending_document d
    SET d.active_ind = 0
    WHERE (d.blob_handle=request->blob_handle)
     AND d.active_ind=1
    WITH nocounter
   ;end update
   INSERT  FROM cdi_pending_document d
    SET d.cdi_pending_document_id = new_cdi_pending_document_id, d.blob_handle = request->blob_handle,
     d.active_ind = 1,
     d.ax_app_ident = request->ax_appid, d.ax_doc_ident = request->ax_docid, d.birth_dt_tm =
     cnvtdatetime(request->birth_dt_tm),
     d.capture_loc_name = request->capture_loc_name, d.contributor_system_alias = request->
     contributor_system_alias, d.doc_type_alias = request->document_type_alias,
     d.doc_type_name = request->doc_type, d.doc_updt_dt_tm = cnvtdatetime(request->doc_updt_dt_tm), d
     .encntr_id = request->encntr_id,
     d.event_cd = request->event_cd, d.event_codeset = request->event_codeset, d.parent_entity_id =
     request->parent_entity_id,
     d.parent_entity_name = request->parent_entity_name, d.patient_name = request->patient_name, d
     .performing_provider_alias = request->provider_alias,
     d.person_id = request->person_id, d.reference_nbr_text = request->reference_nbr, d
     .result_status_alias = request->result_status,
     d.rx_priority_text = request->rx_priority, d.scan_dt_tm = evaluate(trim(request->create_date),"",
      cnvtdatetime("01-JAN-1900"),cnvtdatetime(batchcreatedttm)), d.service_dt_tm = cnvtdatetime(
      request->service_dt_tm),
     d.subject_text = request->subject, d.tracking_nbr_text = request->tracking_nbr, d.updt_applctx
      = reqinfo->updt_applctx,
     d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id,
     d.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_trans_log"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to insert cdi_pending_document row."
    GO TO exit_script
   ENDIF
   IF (size(request->parent_aliases,5) > 0)
    INSERT  FROM (dummyt dm  WITH seq = size(request->parent_aliases,5)),
      cdi_doc_dyn_metadata a
     SET a.cdi_pending_document_id = new_cdi_pending_document_id, a.cdi_doc_dyn_metadata_id = seq(
       cdi_seq,nextval), a.alias_type_codeset = request->parent_aliases[dm.seq].alias_type_codeset,
      a.alias_type_cd = request->parent_aliases[dm.seq].alias_type_cd, a.field_value = request->
      parent_aliases[dm.seq].field_value, a.updt_applctx = reqinfo->updt_applctx,
      a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id,
      a.updt_task = reqinfo->updt_task
     PLAN (dm
      WHERE (((request->parent_aliases[dm.seq].alias_type_codeset != 319)) OR ((request->
      parent_aliases[dm.seq].alias_type_cd != fin_code_val)
       AND (request->parent_aliases[dm.seq].alias_type_cd != mrn_code_val))) )
      JOIN (a)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_trans_log"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed to insert cdi_doc_dyn_metadata row."
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  x = seq(cdi_seq,nextval)
  FROM dual
  DETAIL
   new_cdi_trans_log_id = x
  WITH nocounter
 ;end select
 INSERT  FROM cdi_trans_log c
  SET c.cdi_trans_log_id = new_cdi_trans_log_id, c.action_dt_tm = cnvtdatetime(now_date,now_time), c
   .action_type_flag = request->action_type_flag,
   c.batch_name = request->batch_name, c.batch_name_key = cnvtupper(request->batch_name), c
   .patient_name = request->patient_name,
   c.mrn = request->mrn, c.financial_nbr = request->financial_nbr, c.blob_handle = request->
   blob_handle,
   c.person_id = request->person_id, c.encntr_id = request->encntr_id, c.event_cd = request->event_cd,
   c.page_deleted_cnt = request->page_deleted_cnt, c.page_cnt = request->page_cnt, c.perf_prsnl_id =
   reqinfo->updt_id,
   c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.event_id = request->event_id,
   c.blob_ref_id = request->blob_ref_id, c.blob_type_flag = request->blob_type_flag, c.ax_appid =
   request->ax_appid,
   c.ax_docid = request->ax_docid, c.cdi_queue_cd = queue_var, c.reason_cd = reason_var,
   c.doc_type = request->doc_type, c.subject = request->subject, c.active_ind = my_active_ind,
   c.create_dt_tm = evaluate(batchcreatedttm,0,cnvtdatetime("01-JAN-1900"),cnvtdatetime(
     batchcreatedttm)), c.external_batch_ident = batchexternalid, c.parent_entity_name = request->
   parent_entity_name,
   c.parent_entity_id = request->parent_entity_id, c.parent_entity_alias = request->
   parent_entity_alias, c.document_type_alias = request->document_type_alias,
   c.cdi_pending_document_id = new_cdi_pending_document_id, c.cdi_form_id = request->cdi_form_id, c
   .device_name = request->device_name,
   c.copy_cnt = request->copy_cnt, c.man_queue_cat_cd = request->man_queue_cat_cd, c.man_queue_err_cd
    = request->man_queue_err_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_add_trans_log"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to insert trans_log row."
  SET err_code = error(err_msg,1)
  CALL echo(err_msg)
  GO TO exit_script
 ENDIF
 IF (size(request->mod_details,5) > 0)
  INSERT  FROM (dummyt dm  WITH seq = size(request->mod_details,5)),
    cdi_trans_mod_detail dt
   SET dt.cdi_trans_log_id = new_cdi_trans_log_id, dt.cdi_trans_mod_detail_id = seq(cdi_seq,nextval),
    dt.action_sequence = request->mod_details[dm.seq].action_sequence,
    dt.action_type_flag = request->mod_details[dm.seq].action_type_flag, dt.start_page = request->
    mod_details[dm.seq].start_page, dt.end_page = request->mod_details[dm.seq].end_page,
    dt.position = request->mod_details[dm.seq].position, dt.updt_applctx = reqinfo->updt_applctx, dt
    .updt_cnt = 0,
    dt.updt_dt_tm = cnvtdatetime(sysdate), dt.updt_id = reqinfo->updt_id, dt.updt_task = reqinfo->
    updt_task
   PLAN (dm)
    JOIN (dt)
   WITH nocounter
  ;end insert
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD batch_summary_rec
END GO
