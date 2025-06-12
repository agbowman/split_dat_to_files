CREATE PROGRAM aps_get_screening_events:dba
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
 SELECT INTO "nl:"
  cse.*, csr.*
  FROM cyto_screening_event cse,
   cyto_standard_rpt csr
  PLAN (cse
   WHERE (request->case_id=cse.case_id)
    AND 1=cse.active_ind)
   JOIN (csr
   WHERE cse.standard_rpt_id=csr.standard_rpt_id)
  ORDER BY cse.sequence
  HEAD REPORT
   stat = alterlist(reply->rpt_info_qual,1), stat = alterlist(reply->rpt_info_qual[1].screen_qual,1),
   screen_cnt = 0
  DETAIL
   screen_cnt += 1, stat = alterlist(reply->rpt_info_qual[1].screen_qual,screen_cnt), reply->
   rpt_info_qual[1].screen_qual[screen_cnt].sequence = cse.sequence,
   reply->rpt_info_qual[1].screen_qual[screen_cnt].screener_id = cse.screener_id, reply->
   rpt_info_qual[1].screen_qual[screen_cnt].screen_dt_tm = cse.screen_dt_tm, reply->rpt_info_qual[1].
   screen_qual[screen_cnt].verify_ind = cse.verify_ind,
   reply->rpt_info_qual[1].screen_qual[screen_cnt].review_reason_flag = cse.review_reason_flag, reply
   ->rpt_info_qual[1].screen_qual[screen_cnt].initial_screener_ind = cse.initial_screener_ind, reply
   ->rpt_info_qual[1].screen_qual[screen_cnt].reference_range_factor_id = cse
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
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
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
#exit_script
END GO
