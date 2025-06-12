CREATE PROGRAM clinical_event_78_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM clinical_event t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.clinical_event_id = evaluate2(
    IF ((request->lst[d.seq].clinical_event_id=- (1))) 0
    ELSE request->lst[d.seq].clinical_event_id
    ENDIF
    ), t.encntr_id = evaluate2(
    IF ((request->lst[d.seq].encntr_id=- (1))) 0
    ELSE request->lst[d.seq].encntr_id
    ENDIF
    ), t.person_id = evaluate2(
    IF ((request->lst[d.seq].person_id=- (1))) 0
    ELSE request->lst[d.seq].person_id
    ENDIF
    ),
   t.event_start_dt_tm = evaluate2(
    IF ((request->lst[d.seq].event_start_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].event_start_dt_tm)
    ENDIF
    ), t.encntr_financial_id = evaluate2(
    IF ((request->lst[d.seq].encntr_financial_id=- (1))) 0
    ELSE request->lst[d.seq].encntr_financial_id
    ENDIF
    ), t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ),
   t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ), t.event_title_text = request->lst[d.seq].event_title_text, t.view_level = evaluate2(
    IF ((request->lst[d.seq].view_level_ind=1)) null
    ELSE request->lst[d.seq].view_level
    ENDIF
    ),
   t.order_id = evaluate2(
    IF ((request->lst[d.seq].order_id=- (1))) 0
    ELSE request->lst[d.seq].order_id
    ENDIF
    ), t.catalog_cd = evaluate2(
    IF ((request->lst[d.seq].catalog_cd=- (1))) 0
    ELSE request->lst[d.seq].catalog_cd
    ENDIF
    ), t.series_ref_nbr = request->lst[d.seq].series_ref_nbr,
   t.accession_nbr = request->lst[d.seq].accession_nbr, t.contributor_system_cd = evaluate2(
    IF ((request->lst[d.seq].contributor_system_cd=- (1))) 0
    ELSE request->lst[d.seq].contributor_system_cd
    ENDIF
    ), t.reference_nbr = request->lst[d.seq].reference_nbr,
   t.parent_event_id = evaluate2(
    IF ((request->lst[d.seq].parent_event_id=- (1))) 0
    ELSE request->lst[d.seq].parent_event_id
    ENDIF
    ), t.event_reltn_cd = evaluate2(
    IF ((request->lst[d.seq].event_reltn_cd=- (1))) 0
    ELSE request->lst[d.seq].event_reltn_cd
    ENDIF
    ), t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ),
   t.event_class_cd = evaluate2(
    IF ((request->lst[d.seq].event_class_cd=- (1))) 0
    ELSE request->lst[d.seq].event_class_cd
    ENDIF
    ), t.event_cd = evaluate2(
    IF ((request->lst[d.seq].event_cd=- (1))) 0
    ELSE request->lst[d.seq].event_cd
    ENDIF
    ), t.event_tag = request->lst[d.seq].event_tag,
   t.event_end_dt_tm = evaluate2(
    IF ((request->lst[d.seq].event_end_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].event_end_dt_tm)
    ENDIF
    ), t.event_end_dt_tm_os = evaluate2(
    IF ((request->lst[d.seq].event_end_dt_tm_os_ind=1)) null
    ELSE request->lst[d.seq].event_end_dt_tm_os
    ENDIF
    ), t.result_val = request->lst[d.seq].result_val,
   t.result_units_cd = evaluate2(
    IF ((request->lst[d.seq].result_units_cd=- (1))) 0
    ELSE request->lst[d.seq].result_units_cd
    ENDIF
    ), t.result_time_units_cd = evaluate2(
    IF ((request->lst[d.seq].result_time_units_cd=- (1))) 0
    ELSE request->lst[d.seq].result_time_units_cd
    ENDIF
    ), t.task_assay_cd = evaluate2(
    IF ((request->lst[d.seq].task_assay_cd=- (1))) 0
    ELSE request->lst[d.seq].task_assay_cd
    ENDIF
    ),
   t.record_status_cd = evaluate2(
    IF ((request->lst[d.seq].record_status_cd=- (1))) 0
    ELSE request->lst[d.seq].record_status_cd
    ENDIF
    ), t.result_status_cd = evaluate2(
    IF ((request->lst[d.seq].result_status_cd=- (1))) 0
    ELSE request->lst[d.seq].result_status_cd
    ENDIF
    ), t.authentic_flag = evaluate2(
    IF ((request->lst[d.seq].authentic_flag_ind=1)) null
    ELSE request->lst[d.seq].authentic_flag
    ENDIF
    ),
   t.publish_flag = evaluate2(
    IF ((request->lst[d.seq].publish_flag_ind=1)) null
    ELSE request->lst[d.seq].publish_flag
    ENDIF
    ), t.qc_review_cd = evaluate2(
    IF ((request->lst[d.seq].qc_review_cd=- (1))) 0
    ELSE request->lst[d.seq].qc_review_cd
    ENDIF
    ), t.normalcy_cd = evaluate2(
    IF ((request->lst[d.seq].normalcy_cd=- (1))) 0
    ELSE request->lst[d.seq].normalcy_cd
    ENDIF
    ),
   t.normalcy_method_cd = evaluate2(
    IF ((request->lst[d.seq].normalcy_method_cd=- (1))) 0
    ELSE request->lst[d.seq].normalcy_method_cd
    ENDIF
    ), t.inquire_security_cd = evaluate2(
    IF ((request->lst[d.seq].inquire_security_cd=- (1))) 0
    ELSE request->lst[d.seq].inquire_security_cd
    ENDIF
    ), t.resource_group_cd = evaluate2(
    IF ((request->lst[d.seq].resource_group_cd=- (1))) 0
    ELSE request->lst[d.seq].resource_group_cd
    ENDIF
    ),
   t.resource_cd = evaluate2(
    IF ((request->lst[d.seq].resource_cd=- (1))) 0
    ELSE request->lst[d.seq].resource_cd
    ENDIF
    ), t.subtable_bit_map = request->lst[d.seq].subtable_bit_map, t.collating_seq = request->lst[d
   .seq].collating_seq,
   t.verified_dt_tm = evaluate2(
    IF ((request->lst[d.seq].verified_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].verified_dt_tm)
    ENDIF
    ), t.verified_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].verified_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].verified_prsnl_id
    ENDIF
    ), t.performed_dt_tm = evaluate2(
    IF ((request->lst[d.seq].performed_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].performed_dt_tm)
    ENDIF
    ),
   t.performed_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].performed_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].performed_prsnl_id
    ENDIF
    ), t.normal_low = request->lst[d.seq].normal_low, t.normal_high = request->lst[d.seq].normal_high,
   t.critical_low = request->lst[d.seq].critical_low, t.critical_high = request->lst[d.seq].
   critical_high, t.event_tag_set_flag = request->lst[d.seq].event_tag_set_flag,
   t.expiration_dt_tm = evaluate2(
    IF ((request->lst[d.seq].expiration_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].expiration_dt_tm)
    ENDIF
    ), t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm), t.updt_id = request->lst[d.seq
   ].updt_id,
   t.updt_task = request->lst[d.seq].updt_task, t.updt_cnt = request->lst[d.seq].updt_cnt, t
   .updt_applctx = request->lst[d.seq].updt_applctx
  PLAN (d)
   JOIN (t
   WHERE (t.clinical_event_id=request->lst[d.seq].clinical_event_id))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
