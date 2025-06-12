CREATE PROGRAM aps_get_case_report:dba
 RECORD event(
   1 qual[*]
     2 parent_cd = f8
     2 event_cd = f8
 )
 RECORD worksheet_req(
   1 specimen_cd = f8
   1 prefix_id = f8
   1 catalog_cd = f8
   1 default_only_flag = i2
 )
 RECORD temp(
   1 qual[*]
     2 specimen_cd = f8
     2 prefix_id = f8
     2 catalog_cd = f8
 )
 IF ((validate(worksheet_rep->curqual,- (99))=- (99)))
  RECORD worksheet_rep(
    1 ws_qual[*]
      2 scr_pattern_id = f8
      2 scr_pattern_disp = c40
      2 task_assay_cd = f8
      2 sequence = i2
      2 pattern_description = vc
      2 pattern_cki_source = vc
      2 pattern_cki_identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE synoptic_enabled_ind = i2 WITH noconstant(0)
 DECLARE spec_seq = i2 WITH noconstant(0)
 DECLARE n_doc_images = i2 WITH protect, constant(2)
 DECLARE doc_images_present_ind = i2 WITH protect, noconstant(0)
 DECLARE correctinit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE correctinprc_cd = f8 WITH protect, noconstant(0.0)
#script
 SET n_images = 1
 SET failed = "F"
 SET error_cnt = 0
 SET lock_id = 0.0
 SET screen_cnt = 0
 SET verified_cd = 0.0
 SET canceled_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SET case_id = 0.0
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET imagecnt = 0
 SET diagcodescnt = 0
 SET sectioncnt = 0
 IF (((band(request->blob_bitmap,n_images)) OR (band(request->blob_bitmap,n_doc_images))) )
  SET call_aps_get_report_images_ind = 1
 ENDIF
 IF (validate(request->report_status_flag,0)=0)
  SET case_report_where = concat("request->report_id = cr.report_id and ",
   "cr.status_cd not in(verified_cd, ","canceled_cd, corrected_cd, signinproc_cd, ","csigninproc_cd)"
   )
 ELSE
  SET case_report_where = concat("request->report_id = cr.report_id and ",
   "cr.status_cd != canceled_cd")
 ENDIF
 IF ((request->called_ind != 1))
  RECORD reply(
    1 rpt_info_qual[*]
      2 case_event_cd = f8
      2 case_event_id = f8
      2 case_updt_cnt = i4
      2 event_id = f8
      2 report_id = f8
      2 catalog_cd = f8
      2 event_cd = f8
      2 order_id = f8
      2 orig_order_dt_tm = dq8
      2 orig_order_tz = i4
      2 hold_cd = f8
      2 hold_disp = c40
      2 hold_comment = vc
      2 hold_comment_long_text_id = f8
      2 hold_comment_lt_updt_cnt = i4
      2 status_cd = f8
      2 status_disp = c40
      2 status_desc = vc
      2 status_mean = c12
      2 comments = vc
      2 comments_long_text_id = f8
      2 comments_updt_cnt = i4
      2 cancel_cd = f8
      2 cancel_disp = c40
      2 last_edit_dt_tm = dq8
      2 responsible_pathologist_id = f8
      2 responsible_pathologist_name = vc
      2 responsible_resident_id = f8
      2 responsible_resident_name = vc
      2 service_resource_cd = f8
      2 service_resource_disp = c40
      2 blob_bitmap = i4
      2 dept_blob_bitmap = i4
      2 images_read_only_ind = i2
      2 updt_cnt = i4
      2 cr_updt_cnt = i4
      2 synoptic_stale_ind = i2
      2 synoptic_stale_dt_tm = dq8
      2 synoptic_worksheets_allowed_ind = i2
      2 synoptic_incomplete_ind = i2
      2 synoptic_results_exist_ind = i2
      2 section_qual[*]
        3 event_id = f8
        3 hist_act_cd = f8
        3 status_cd = f8
        3 status_disp = c40
        3 required_ind = i2
        3 modified_ind = i2
        3 task_assay_cd = f8
        3 task_assay_disp = c40
        3 task_assay_desc = vc
        3 event_cd = f8
        3 section_sequence = i4
        3 result_type_cd = f8
        3 result_type_disp = c40
        3 result_type_desc = vc
        3 result_type_mean = c12
        3 sign_line_ind = i2
        3 updt_cnt = i4
        3 prompt_rtf_text = vc
        3 report_detail_id = f8
        3 image_qual[*]
          4 blob_ref_id = f8
          4 sequence_nbr = i4
          4 owner_cd = f8
          4 storage_cd = f8
          4 format_cd = f8
          4 blob_handle = vc
          4 blob_title = vc
          4 tbnl_long_blob_id = f8
          4 tbnl_format_cd = f8
          4 long_blob = vgc
          4 create_prsnl_id = f8
          4 create_prsnl_name = vc
          4 source_device_cd = f8
          4 source_device_disp = c40
          4 chartable_note = vc
          4 chartable_note_id = f8
          4 chartable_note_updt_cnt = i4
          4 non_chartable_note = vc
          4 non_chartable_note_id = f8
          4 non_chartable_note_updt_cnt = i4
          4 publish_flag = i2
          4 valid_from_dt_tm = dq8
          4 updt_id = f8
          4 updt_cnt = i4
          4 blob_foreign_ident = vc
      2 screen_qual[*]
        3 sequence = i4
        3 screener_id = f8
        3 screener_name = vc
        3 screen_dt_tm = dq8
        3 verify_ind = i2
        3 review_reason_flag = i4
        3 initial_screener_ind = i2
        3 reference_range_factor_id = f8
        3 nomenclature_id = f8
        3 diagnostic_category_cd = f8
        3 endocerv_ind = i2
        3 adequacy_flag = i2
        3 standard_rpt_id = f8
        3 standard_rpt_desc = c40
        3 event_id = f8
        3 valid_from_dt_tm = dq8
        3 updt_cnt = i4
      2 lock_username = vc
      2 lock_dt_tm = dq8
      2 image_qual[*]
        3 blob_ref_id = f8
        3 sequence_nbr = i4
        3 owner_cd = f8
        3 storage_cd = f8
        3 format_cd = f8
        3 blob_handle = vc
        3 blob_title = vc
        3 tbnl_long_blob_id = f8
        3 tbnl_format_cd = f8
        3 long_blob = vgc
        3 create_prsnl_id = f8
        3 create_prsnl_name = vc
        3 source_device_cd = f8
        3 source_device_disp = c40
        3 chartable_note = vc
        3 chartable_note_id = f8
        3 chartable_note_updt_cnt = i4
        3 non_chartable_note = vc
        3 non_chartable_note_id = f8
        3 non_chartable_note_updt_cnt = i4
        3 publish_flag = i2
        3 valid_from_dt_tm = dq8
        3 updt_id = f8
        3 updt_cnt = i4
        3 blob_foreign_ident = vc
      2 case_reports_blob_bitmap = i4
    1 report_status = c1
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
 ENDIF
 SET reply->report_status = "F"
 SET stat = alterlist(reply->rpt_info_qual,1)
 SET stat = alterlist(reply->rpt_info_qual[1].section_qual,5)
 IF ((request->called_ind != 1)
  AND textlen(trim(validate(request->accession_nbr," "))) > 0)
  RECORD case_event(
    1 accession_nbr = c20
    1 event_id = f8
  )
  SET case_event->accession_nbr = request->accession_nbr
  EXECUTE aps_get_case_event_id
  SET reply->rpt_info_qual[1].case_event_id = case_event->event_id
 ENDIF
 SET verified_cd = uar_get_code_by("MEANING",1305,"VERIFIED")
 SET cancel_cd = uar_get_code_by("MEANING",1305,"CANCEL")
 SET corrected_cd = uar_get_code_by("MEANING",1305,"CORRECTED")
 SET signinproc_cd = uar_get_code_by("MEANING",1305,"SIGNINPROC")
 SET csigninproc_cd = uar_get_code_by("MEANING",1305,"CSIGNINPROC")
 SET correctinit_cd = uar_get_code_by("MEANING",1305,"CORRECTINIT")
 SET correctinprc_cd = uar_get_code_by("MEANING",1305,"CORRECTINPRC")
 IF (verified_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:VERIFIED")
  SET failed = "T"
 ENDIF
 IF (cancel_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:CANCEL")
  SET failed = "T"
 ENDIF
 IF (corrected_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:CORRECTED")
  SET failed = "T"
 ENDIF
 IF (signinproc_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:SIGNINPROC")
  SET failed = "T"
 ENDIF
 IF (csigninproc_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:CSIGNINPROC")
  SET failed = "T"
 ENDIF
 IF (correctinit_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:CORRECTINIT")
  SET failed = "T"
 ENDIF
 IF (correctinprc_cd <= 0)
  CALL handle_errors("UAR","F","CODE_VALUE:1305","MEANING:CORRECTINPRC")
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reply->report_status = "F"
  SET stat = alterlist(reply->rpt_info_qual,0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cr.event_id, rt.editing_prsnl_id, rdt.task_assay_cd,
  dta.history_activity_type_cd, synoptic_null_ind = nullind(cr.synoptic_stale_dt_tm)
  FROM case_report cr,
   pathology_case pc,
   report_task rt,
   orders o,
   prsnl p1,
   prsnl p2,
   report_detail_task rdt,
   discrete_task_assay dta
  PLAN (cr
   WHERE parser(case_report_where))
   JOIN (pc
   WHERE cr.case_id=pc.case_id)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (o
   WHERE o.order_id=rt.order_id)
   JOIN (p1
   WHERE rt.responsible_pathologist_id=p1.person_id)
   JOIN (p2
   WHERE rt.responsible_resident_id=p2.person_id)
   JOIN (rdt
   WHERE rt.report_id=rdt.report_id)
   JOIN (dta
   WHERE rdt.task_assay_cd=dta.task_assay_cd)
  ORDER BY rdt.section_sequence
  HEAD REPORT
   section_cnt = 0, case_id = cr.case_id, lock_id = rt.editing_prsnl_id,
   reply->rpt_info_qual[1].case_updt_cnt = pc.updt_cnt, reply->rpt_info_qual[1].blob_bitmap = cr
   .blob_bitmap, reply->rpt_info_qual[1].lock_dt_tm = cnvtdatetime(rt.editing_dt_tm),
   reply->rpt_info_qual[1].hold_cd = rt.hold_cd, reply->rpt_info_qual[1].hold_comment_long_text_id =
   rt.hold_comment_long_text_id, reply->rpt_info_qual[1].updt_cnt = rt.updt_cnt,
   reply->rpt_info_qual[1].comments_long_text_id = rt.comments_long_text_id, reply->rpt_info_qual[1].
   order_id = rt.order_id, reply->rpt_info_qual[1].event_id = cr.event_id,
   reply->rpt_info_qual[1].catalog_cd = cr.catalog_cd, reply->rpt_info_qual[1].status_cd = cr
   .status_cd
   CASE (reply->rpt_info_qual[1].status_cd)
    OF cancel_cd:
     reply->rpt_info_qual[1].blob_bitmap = 0,reply->rpt_info_qual[1].dept_blob_bitmap = 0
    OF verified_cd:
    OF corrected_cd:
     reply->rpt_info_qual[1].blob_bitmap = cr.blob_bitmap,reply->rpt_info_qual[1].dept_blob_bitmap =
     0
    OF correctinit_cd:
    OF correctinprc_cd:
     reply->rpt_info_qual[1].blob_bitmap = cr.blob_bitmap,reply->rpt_info_qual[1].dept_blob_bitmap =
     n_images
    OF signinproc_cd:
    OF csigninproc_cd:
     reply->rpt_info_qual[1].blob_bitmap = cr.blob_bitmap,reply->rpt_info_qual[1].dept_blob_bitmap =
     bor(n_images,n_doc_images),reply->rpt_info_qual[1].images_read_only_ind = 1
    ELSE
     reply->rpt_info_qual[1].blob_bitmap = cr.blob_bitmap,reply->rpt_info_qual[1].dept_blob_bitmap =
     bor(n_images,n_doc_images)
   ENDCASE
   reply->rpt_info_qual[1].cancel_cd = cr.cancel_cd, reply->rpt_info_qual[1].cr_updt_cnt = cr
   .updt_cnt, reply->rpt_info_qual[1].last_edit_dt_tm = rt.last_edit_dt_tm,
   reply->rpt_info_qual[1].responsible_pathologist_id = rt.responsible_pathologist_id, reply->
   rpt_info_qual[1].responsible_pathologist_name = p1.name_full_formatted, reply->rpt_info_qual[1].
   responsible_resident_id = rt.responsible_resident_id,
   reply->rpt_info_qual[1].responsible_resident_name = p2.name_full_formatted, reply->rpt_info_qual[1
   ].service_resource_cd = rt.service_resource_cd
   IF (synoptic_null_ind=1)
    reply->rpt_info_qual[1].synoptic_stale_ind = 0
   ELSE
    reply->rpt_info_qual[1].synoptic_stale_ind = 1, reply->rpt_info_qual[1].synoptic_stale_dt_tm = cr
    .synoptic_stale_dt_tm
   ENDIF
   reply->rpt_info_qual[1].synoptic_worksheets_allowed_ind = 0, reply->rpt_info_qual[1].
   synoptic_incomplete_ind = 0, reply->rpt_info_qual[1].synoptic_results_exist_ind = 0,
   reply->rpt_info_qual[1].orig_order_dt_tm = cnvtdatetime(o.orig_order_dt_tm), reply->rpt_info_qual[
   1].orig_order_tz = o.orig_order_tz
  DETAIL
   section_cnt += 1
   IF (mod(section_cnt,5)=1
    AND section_cnt != 1)
    stat = alterlist(reply->rpt_info_qual[1].section_qual,(section_cnt+ 4))
   ENDIF
   reply->rpt_info_qual[1].section_qual[section_cnt].task_assay_cd = rdt.task_assay_cd, reply->
   rpt_info_qual[1].section_qual[section_cnt].hist_act_cd = dta.history_activity_type_cd, reply->
   rpt_info_qual[1].section_qual[section_cnt].event_id = rdt.event_id,
   reply->rpt_info_qual[1].section_qual[section_cnt].status_cd = rdt.status_cd, reply->rpt_info_qual[
   1].section_qual[section_cnt].required_ind = rdt.required_ind, reply->rpt_info_qual[1].
   section_qual[section_cnt].modified_ind = rdt.modified_ind,
   reply->rpt_info_qual[1].section_qual[section_cnt].section_sequence = rdt.section_sequence, reply->
   rpt_info_qual[1].section_qual[section_cnt].result_type_cd = rdt.result_type_cd, reply->
   rpt_info_qual[1].section_qual[section_cnt].updt_cnt = rdt.updt_cnt,
   reply->rpt_info_qual[1].section_qual[section_cnt].task_assay_cd = rdt.task_assay_cd, reply->
   rpt_info_qual[1].section_qual[section_cnt].sign_line_ind = rdt.signature_footnote_ind
  FOOT REPORT
   IF (section_cnt != 5)
    stat = alterlist(reply->rpt_info_qual[1].section_qual,section_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","REPORT_TASK")
  SET failed = "T"
  SET reply->report_status = "Z"
  SET stat = alterlist(reply->rpt_info_qual,0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = 1),
   long_text lt
  PLAN (d1
   WHERE (reply->rpt_info_qual[1].comments_long_text_id > 0))
   JOIN (lt
   WHERE (reply->rpt_info_qual[1].comments_long_text_id=lt.long_text_id))
  DETAIL
   reply->rpt_info_qual[1].comments = lt.long_text, reply->rpt_info_qual[1].comments_updt_cnt = lt
   .updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = 1),
   long_text lt
  PLAN (d1
   WHERE (reply->rpt_info_qual[1].hold_comment_long_text_id > 0))
   JOIN (lt
   WHERE (reply->rpt_info_qual[1].hold_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->rpt_info_qual[1].hold_comment = lt.long_text, reply->rpt_info_qual[1].
   hold_comment_lt_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="ANATOMIC PATHOLOGY"
    AND di.info_name="SYNOPTIC REPORTING")
  DETAIL
   synoptic_enabled_ind = di.info_number
  WITH nocounter
 ;end select
 IF (synoptic_enabled_ind=1)
  SELECT INTO "nl:"
   FROM ap_case_synoptic_ws ws
   PLAN (ws
    WHERE (ws.report_id=request->report_id))
   DETAIL
    reply->rpt_info_qual[1].synoptic_worksheets_allowed_ind = 1
    IF (ws.status_flag=1)
     reply->rpt_info_qual[1].synoptic_incomplete_ind = 1
    ENDIF
    IF (ws.status_flag != 0)
     reply->rpt_info_qual[1].synoptic_results_exist_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF ((reply->rpt_info_qual[1].synoptic_worksheets_allowed_ind=0))
   SET spec_cnt = 0
   SET s_cnt = 0
   SELECT INTO "nl:"
    cs.*
    FROM pathology_case pc,
     case_report cr,
     case_specimen cs
    PLAN (cs
     WHERE cs.case_id=case_id)
     JOIN (pc
     WHERE pc.case_id=case_id)
     JOIN (cr
     WHERE (cr.report_id=request->report_id))
    ORDER BY cs.case_id, cs.specimen_cd
    HEAD cs.specimen_cd
     spec_cnt += 1, stat = alterlist(temp->qual,spec_cnt), temp->qual[spec_cnt].specimen_cd = cs
     .specimen_cd,
     temp->qual[spec_cnt].prefix_id = pc.prefix_id, temp->qual[spec_cnt].catalog_cd = cr.catalog_cd
    WITH nocounter
   ;end select
   FOR (s_cnt = 1 TO spec_cnt)
     SET worksheet_req->specimen_cd = temp->qual[s_cnt].specimen_cd
     SET worksheet_req->prefix_id = temp->qual[s_cnt].prefix_id
     SET worksheet_req->catalog_cd = temp->qual[s_cnt].catalog_cd
     SET worksheet_req->default_only_flag = 0
     EXECUTE aps_get_synoptic_allowed_ws  WITH replace("REQUEST","WORKSHEET_REQ"), replace("REPLY",
      "WORKSHEET_REP")
     IF ((worksheet_rep->status_data.status="S")
      AND size(worksheet_rep->ws_qual,5) > 0)
      SET reply->rpt_info_qual[1].synoptic_worksheets_allowed_ind = 1
      SET s_cnt = (spec_cnt+ 1)
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (band(request->blob_bitmap,reply->rpt_info_qual[1].blob_bitmap))
  EXECUTE aps_get_report_images
 ENDIF
 IF ((request->prompt_ind=1))
  SELECT INTO "nl:"
   apt.long_text_id, apt.task_assay_cd, lt.long_text_id
   FROM ap_prompt_test apt,
    (dummyt d  WITH seq = value(size(reply->rpt_info_qual[1].section_qual,5))),
    long_text lt
   PLAN (apt
    WHERE case_id=apt.accession_id
     AND 1=apt.active_ind)
    JOIN (d
    WHERE (apt.task_assay_cd=reply->rpt_info_qual[1].section_qual[d.seq].task_assay_cd)
     AND (reply->rpt_info_qual[1].section_qual[d.seq].event_id=0.0))
    JOIN (lt
    WHERE apt.long_text_id=lt.long_text_id
     AND 1=lt.active_ind)
   DETAIL
    IF (lt.long_text_id > 0)
     reply->rpt_info_qual[1].section_qual[d.seq].prompt_rtf_text = lt.long_text
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->cyto_report_ind=1))
  SELECT INTO "nl:"
   cse.sequence, csr.description
   FROM cyto_screening_event cse,
    cyto_standard_rpt csr
   PLAN (cse
    WHERE case_id=cse.case_id
     AND 1=cse.active_ind)
    JOIN (csr
    WHERE cse.standard_rpt_id=csr.standard_rpt_id)
   ORDER BY cse.sequence
   HEAD REPORT
    stat = alterlist(reply->rpt_info_qual[1].screen_qual,1), screen_cnt = 0
   DETAIL
    screen_cnt += 1, stat = alterlist(reply->rpt_info_qual[1].screen_qual,screen_cnt), reply->
    rpt_info_qual[1].screen_qual[screen_cnt].sequence = cse.sequence,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].screener_id = cse.screener_id, reply->
    rpt_info_qual[1].screen_qual[screen_cnt].screen_dt_tm = cse.screen_dt_tm, reply->rpt_info_qual[1]
    .screen_qual[screen_cnt].verify_ind = cse.verify_ind,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].review_reason_flag = cse.review_reason_flag,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].initial_screener_ind = cse.initial_screener_ind,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].reference_range_factor_id = cse
    .reference_range_factor_id,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].nomenclature_id = cse.nomenclature_id, reply->
    rpt_info_qual[1].screen_qual[screen_cnt].diagnostic_category_cd = cse.diagnostic_category_cd,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].endocerv_ind = cse.endocerv_ind,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].adequacy_flag = cse.adequacy_flag, reply->
    rpt_info_qual[1].screen_qual[screen_cnt].standard_rpt_id = cse.standard_rpt_id, reply->
    rpt_info_qual[1].screen_qual[screen_cnt].standard_rpt_desc = csr.description,
    reply->rpt_info_qual[1].screen_qual[screen_cnt].event_id = cse.event_id, reply->rpt_info_qual[1].
    screen_qual[screen_cnt].valid_from_dt_tm = cse.valid_from_dt_tm, reply->rpt_info_qual[1].
    screen_qual[screen_cnt].updt_cnt = cse.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->rpt_info_qual[1].screen_qual,screen_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM prsnl p,
    (dummyt d1  WITH seq = value(size(reply->rpt_info_qual[1].screen_qual,5)))
   PLAN (d1)
    JOIN (p
    WHERE (reply->rpt_info_qual[1].screen_qual[d1.seq].screener_id=p.person_id)
     AND (reply->rpt_info_qual[1].screen_qual[d1.seq].screener_id > 0))
   DETAIL
    reply->rpt_info_qual[1].screen_qual[d1.seq].screener_name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->lock_ind=1))
  IF (lock_id > 0)
   SET reply->report_status = "P"
   SET failed = "T"
   SELECT INTO "nl:"
    p.username
    FROM prsnl p
    WHERE lock_id=p.person_id
    DETAIL
     reply->rpt_info_qual[1].lock_username = p.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","Z","TABLE","PRSNL LOCK")
    SET reply->report_status = "Z"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SET reqinfo->commit_ind = 0
  ELSE
   SELECT INTO "nl:"
    rt.report_id
    FROM report_task rt
    WHERE (request->report_id=rt.report_id)
    WITH forupdate(rt)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
    SET failed = "T"
    SET reply->report_status = "Z"
    GO TO exit_script
   ENDIF
   SET reply->rpt_info_qual[1].updt_cnt += 1
   UPDATE  FROM report_task rt
    SET rt.editing_prsnl_id = reqinfo->updt_id, rt.editing_dt_tm = cnvtdatetime(curdate,curtime), rt
     .updt_dt_tm = cnvtdatetime(curdate,curtime),
     rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
     updt_applctx,
     rt.updt_cnt = reply->rpt_info_qual[1].updt_cnt
    WHERE (request->report_id=rt.report_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","Z","TABLE","REPORT_TASK")
    SET reply->report_status = "Z"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
 SET stat = alterlist(event->qual,(size(reply->rpt_info_qual[1].section_qual,5)+ 2))
 SET code_value = 0.0
 SET code_set = 73
 SET cdf_meaning = "APS01"
 EXECUTE cpm_get_cd_for_cdf
 SET event->qual[1].parent_cd = code_value
 SET event->qual[2].parent_cd = reply->rpt_info_qual[1].catalog_cd
 FOR (x = 1 TO size(reply->rpt_info_qual[1].section_qual,5))
   SET event->qual[(x+ 2)].parent_cd = reply->rpt_info_qual[1].section_qual[x].task_assay_cd
 ENDFOR
 EXECUTE aps_get_event_codes
 SET reply->rpt_info_qual[1].case_event_cd = event->qual[1].event_cd
 SET reply->rpt_info_qual[1].event_cd = event->qual[2].event_cd
 FOR (x = 1 TO size(reply->rpt_info_qual[1].section_qual,5))
   SET reply->rpt_info_qual[1].section_qual[x].event_cd = event->qual[(x+ 2)].event_cd
 ENDFOR
 SET reply->rpt_info_qual[1].case_reports_blob_bitmap = 0
 SELECT INTO "nl:"
  FROM case_report cr
  PLAN (cr
   WHERE cr.case_id=case_id
    AND cr.cancel_cd IN (0, null))
  DETAIL
   reply->rpt_info_qual[1].case_reports_blob_bitmap = bor(reply->rpt_info_qual[1].
    case_reports_blob_bitmap,cr.blob_bitmap)
  WITH nocounter
 ;end select
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (failed="F")
  SET reply->report_status = "S"
 ENDIF
 IF ((request->called_ind != 1))
  SET reply->status_data.status = reply->report_status
 ENDIF
END GO
