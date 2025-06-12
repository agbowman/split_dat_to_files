CREATE PROGRAM ce_get_events_by_io_result:dba
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE replycnt = i4 WITH noconstant(0)
 DECLARE ioresultcnt = i4 WITH noconstant(0)
 DECLARE mergeeventsetlistcnt = i4 WITH noconstant(0)
 DECLARE encntrlistcnt = i4 WITH noconstant(0)
 DECLARE stop_dt_tm = q8
 DECLARE start_dt_tm = q8
 DECLARE end_dt_tm = q8
 DECLARE finish_start_dt_tm = q8
 DECLARE finish_end_dt_tm = q8
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE gcontinuequery = i4 WITH noconstant(0)
 DECLARE ocf_eof = i2 WITH constant(4)
 DECLARE ocf_last_one = i2 WITH constant(11)
 DECLARE eio_query_single = i4 WITH constant(0)
 DECLARE eio_merge_result = i4 WITH constant(1)
 DECLARE eio_return_reference_result = i4 WITH constant(4)
 DECLARE not_empty = i2 WITH constant(0)
 DECLARE empty = i2 WITH constant(1)
 DECLARE max_date = q8 WITH constant(cnvtdatetimeutc("31-DEC-2100 00:00:00"))
 DECLARE gquerymode = i4 WITH constant(request->query_mode)
 DECLARE gsearchstartdttmind = i4 WITH constant(request->search_start_dt_tm_ind)
 DECLARE gsearchenddttmind = i4 WITH constant(request->search_end_dt_tm_ind)
 DECLARE geventstofetch = i4 WITH constant(request->events_to_fetch)
 DECLARE greturnreferenceresult = i2 WITH constant(band(gquerymode,eio_return_reference_result))
 DECLARE gmergeresult = i2 WITH constant(band(gquerymode,eio_merge_result))
 DECLARE mergeeventsetlistsize = i4 WITH constant(size(request->merge_event_set_list,5))
 DECLARE encntrlistsize = i4 WITH constant(size(request->encntr_id_list,5))
 DECLARE iowhereclause = vc WITH noconstant(" ")
 DECLARE eqwhereclause = vc WITH noconstant(" ")
 DECLARE finishwhereclause = vc WITH noconstant(" ")
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 IF (geventstofetch
  AND (context->last_event_dt_tm_ind=not_empty))
  SET gcontinuequery = 1
 ENDIF
 SET start_dt_tm = request->search_start_dt_tm
 SET end_dt_tm = request->search_end_dt_tm
 SET finish_start_dt_tm = request->search_start_dt_tm
 SET finish_end_dt_tm = request->search_end_dt_tm
 DECLARE executereferenceeventquery(null) = null
 DECLARE executeintakeoutputquery(null) = null
 DECLARE executeintakeoutputquerywithresultcap(null) = null
 DECLARE executemergequery(null) = null
 DECLARE executefinishday(null) = null
 DECLARE executecheckmore(null) = null
 DECLARE buildiosearchdates(null) = null
 DECLARE buildcesearchdates(null) = null
 IF (geventstofetch)
  CALL executeintakeoutputquerywithresultcap(null)
 ELSE
  CALL executeintakeoutputquery(null)
 ENDIF
 IF (geventstofetch
  AND replycnt >= geventstofetch)
  CALL executefinishday(null)
 ENDIF
 IF (gmergeresult)
  CALL executemergequery(null)
 ENDIF
 IF (greturnreferenceresult
  AND ioresultcnt > 0)
  CALL executereferenceeventquery(null)
 ENDIF
 IF (geventstofetch=0)
  SET context->cursor_exhausted = ocf_eof
 ELSEIF (ioresultcnt=0)
  SET context->cursor_exhausted = ocf_eof
 ELSEIF (geventstofetch > 0
  AND ioresultcnt < geventstofetch)
  SET context->cursor_exhausted = ocf_last_one
 ELSE
  CALL executecheckmore(null)
 ENDIF
 SET stat = alterlist(reply->rb_list,replycnt)
 SET error_code = error(error_msg,0)
 GO TO exit_script
 SUBROUTINE executeintakeoutputquery(null)
   SET iowhereclause = "ior.person_id = request->PERSON_ID "
   IF (request->io_type_flag)
    SET iowhereclause = build(iowhereclause," and ior.io_type_flag = request->IO_TYPE_FLAG ")
   ENDIF
   IF (encntrlistsize > 0)
    SET iowhereclause = build(iowhereclause,
     " and expand( encntrListCnt, 1, encntrListSize, ior.encntr_id+0, ")
    SET iowhereclause = build(iowhereclause," request->encntr_id_list[encntrListCnt].encntr_id ) ")
   ENDIF
   SELECT INTO "nl:"
    ce.event_id, valid_until_dt_tm_ind = nullind(ce.valid_until_dt_tm), clinsig_updt_dt_tm_ind =
    nullind(ce.clinsig_updt_dt_tm),
    valid_from_dt_tm_ind = nullind(ce.valid_from_dt_tm), event_end_dt_tm_ind = nullind(ce
     .event_end_dt_tm), performed_dt_tm_ind = nullind(ce.performed_dt_tm),
    updt_dt_tm_ind = nullind(ce.updt_dt_tm), view_level_ind = nullind(ce.view_level),
    event_start_dt_tm_ind = nullind(ce.event_start_dt_tm),
    publish_flag_ind = nullind(ce.publish_flag), subtable_bit_map_ind = nullind(ce.subtable_bit_map),
    verified_dt_tm_ind = nullind(ce.verified_dt_tm),
    expiration_dt_tm_ind = nullind(ce.expiration_dt_tm), updt_task_ind = nullind(ce.updt_task),
    updt_cnt_ind = nullind(ce.updt_cnt),
    updt_applctx_ind = nullind(ce.updt_applctx)
    FROM clinical_event ce,
     ce_intake_output_result ior
    PLAN (ior
     WHERE parser(iowhereclause)
      AND ior.valid_until_dt_tm=cnvtdatetimeutc(max_date)
      AND ior.io_end_dt_tm <= cnvtdatetimeutc(start_dt_tm)
      AND ior.io_end_dt_tm >= cnvtdatetimeutc(end_dt_tm))
     JOIN (ce
     WHERE ce.event_id=ior.event_id
      AND ce.valid_until_dt_tm=ior.valid_until_dt_tm)
    ORDER BY ior.io_end_dt_tm DESC
    DETAIL
     replycnt += 1
     IF (mod(replycnt,100)=1)
      stat = alterlist(reply->rb_list,(replycnt+ 99))
     ENDIF
     reply->rb_list[replycnt].event_id = ce.event_id, reply->rb_list[replycnt].event_end_dt_tm = ce
     .event_end_dt_tm, reply->rb_list[replycnt].clinical_event_id = ce.clinical_event_id,
     reply->rb_list[replycnt].valid_until_dt_tm = ce.valid_until_dt_tm, reply->rb_list[replycnt].
     valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->rb_list[replycnt].view_level = ce
     .view_level,
     reply->rb_list[replycnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, reply->rb_list[replycnt].
     clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->rb_list[replycnt].order_id = ce.order_id,
     reply->rb_list[replycnt].order_action_sequence = ce.order_action_sequence, reply->rb_list[
     replycnt].catalog_cd = ce.catalog_cd, reply->rb_list[replycnt].encntr_id = ce.encntr_id,
     reply->rb_list[replycnt].contributor_system_cd = ce.contributor_system_cd, reply->rb_list[
     replycnt].reference_nbr = ce.reference_nbr, reply->rb_list[replycnt].parent_event_id = ce
     .parent_event_id,
     reply->rb_list[replycnt].valid_from_dt_tm = ce.valid_from_dt_tm, reply->rb_list[replycnt].
     valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->rb_list[replycnt].event_class_cd = ce
     .event_class_cd,
     reply->rb_list[replycnt].event_cd = ce.event_cd, reply->rb_list[replycnt].event_tag = ce
     .event_tag, reply->rb_list[replycnt].event_tag_set_flag = ce.event_tag_set_flag,
     reply->rb_list[replycnt].collating_seq = ce.collating_seq, reply->rb_list[replycnt].
     event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[replycnt].event_end_dt_tm_ind =
     event_end_dt_tm_ind,
     reply->rb_list[replycnt].event_end_tz = ce.event_end_tz, reply->rb_list[replycnt].task_assay_cd
      = ce.task_assay_cd, reply->rb_list[replycnt].result_status_cd = ce.result_status_cd,
     reply->rb_list[replycnt].publish_flag = ce.publish_flag, reply->rb_list[replycnt].
     subtable_bit_map = ce.subtable_bit_map, reply->rb_list[replycnt].event_title_text = ce
     .event_title_text,
     reply->rb_list[replycnt].result_val = ce.result_val, reply->rb_list[replycnt].result_units_cd =
     ce.result_units_cd, reply->rb_list[replycnt].performed_dt_tm = ce.performed_dt_tm,
     reply->rb_list[replycnt].performed_dt_tm_ind = performed_dt_tm_ind, reply->rb_list[replycnt].
     performed_tz = ce.performed_tz, reply->rb_list[replycnt].performed_prsnl_id = ce
     .performed_prsnl_id,
     reply->rb_list[replycnt].normal_low = ce.normal_low, reply->rb_list[replycnt].normal_high = ce
     .normal_high, reply->rb_list[replycnt].updt_dt_tm = ce.updt_dt_tm,
     reply->rb_list[replycnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->rb_list[replycnt].
     note_importance_bit_map = ce.note_importance_bit_map, reply->rb_list[replycnt].entry_mode_cd =
     ce.entry_mode_cd,
     reply->rb_list[replycnt].source_cd = ce.source_cd, reply->rb_list[replycnt].clinical_seq = ce
     .clinical_seq, reply->rb_list[replycnt].task_assay_version_nbr = ce.task_assay_version_nbr,
     reply->rb_list[replycnt].modifier_long_text_id = ce.modifier_long_text_id, reply->rb_list[
     replycnt].view_level_ind = view_level_ind, reply->rb_list[replycnt].series_ref_nbr = ce
     .series_ref_nbr,
     reply->rb_list[replycnt].person_id = ce.person_id, reply->rb_list[replycnt].encntr_financial_id
      = ce.encntr_financial_id, reply->rb_list[replycnt].accession_nbr = ce.accession_nbr,
     reply->rb_list[replycnt].event_reltn_cd = ce.event_reltn_cd, reply->rb_list[replycnt].
     event_start_dt_tm = ce.event_start_dt_tm, reply->rb_list[replycnt].event_start_dt_tm_ind =
     event_start_dt_tm_ind,
     reply->rb_list[replycnt].event_start_tz = ce.event_start_tz, reply->rb_list[replycnt].
     record_status_cd = ce.record_status_cd, reply->rb_list[replycnt].authentic_flag = ce
     .authentic_flag,
     reply->rb_list[replycnt].publish_flag_ind = publish_flag_ind, reply->rb_list[replycnt].
     qc_review_cd = ce.qc_review_cd, reply->rb_list[replycnt].normalcy_cd = ce.normalcy_cd,
     reply->rb_list[replycnt].normalcy_method_cd = ce.normalcy_method_cd, reply->rb_list[replycnt].
     inquire_security_cd = ce.inquire_security_cd, reply->rb_list[replycnt].resource_group_cd = ce
     .resource_group_cd,
     reply->rb_list[replycnt].resource_cd = ce.resource_cd, reply->rb_list[replycnt].
     subtable_bit_map_ind = subtable_bit_map_ind, reply->rb_list[replycnt].result_time_units_cd = ce
     .result_time_units_cd,
     reply->rb_list[replycnt].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[replycnt].
     verified_dt_tm_ind = verified_dt_tm_ind, reply->rb_list[replycnt].verified_tz = ce.verified_tz,
     reply->rb_list[replycnt].verified_prsnl_id = ce.verified_prsnl_id, reply->rb_list[replycnt].
     critical_low = ce.critical_low, reply->rb_list[replycnt].critical_high = ce.critical_high,
     reply->rb_list[replycnt].expiration_dt_tm = ce.expiration_dt_tm, reply->rb_list[replycnt].
     expiration_dt_tm_ind = expiration_dt_tm_ind, reply->rb_list[replycnt].updt_id = ce.updt_id,
     reply->rb_list[replycnt].updt_task = ce.updt_task, reply->rb_list[replycnt].updt_task_ind =
     updt_task_ind, reply->rb_list[replycnt].updt_cnt = ce.updt_cnt,
     reply->rb_list[replycnt].updt_cnt_ind = updt_cnt_ind, reply->rb_list[replycnt].updt_applctx = ce
     .updt_applctx, reply->rb_list[replycnt].updt_applctx_ind = updt_applctx_ind,
     reply->rb_list[replycnt].src_event_id = ce.src_event_id, reply->rb_list[replycnt].
     src_clinsig_updt_dt_tm = ce.src_clinsig_updt_dt_tm, reply->rb_list[replycnt].nomen_string_flag
      = ce.nomen_string_flag,
     reply->rb_list[replycnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, reply->rb_list[replycnt].
     device_free_txt = ce.device_free_txt, reply->rb_list[replycnt].trait_bit_map = ce.trait_bit_map
    FOOT REPORT
     context->last_event_dt_tm = ior.io_end_dt_tm, context->last_event_dt_tm_ind = 0
    WITH nocounter
   ;end select
   SET ioresultcnt = replycnt
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE executeintakeoutputquerywithresultcap(null)
   SET iowhereclause = "ior.person_id = request->PERSON_ID "
   IF (request->io_type_flag)
    SET iowhereclause = build(iowhereclause," and ior.io_type_flag = request->IO_TYPE_FLAG ")
   ENDIF
   IF (encntrlistsize > 0)
    SET iowhereclause = build(iowhereclause,
     " and expand( encntrListCnt, 1, encntrListSize, ior.encntr_id+0, ")
    SET iowhereclause = build(iowhereclause," request->encntr_id_list[encntrListCnt].encntr_id ) ")
   ENDIF
   SELECT INTO "nl:"
    ce.event_id, valid_until_dt_tm_ind = nullind(ce.valid_until_dt_tm), clinsig_updt_dt_tm_ind =
    nullind(ce.clinsig_updt_dt_tm),
    valid_from_dt_tm_ind = nullind(ce.valid_from_dt_tm), event_end_dt_tm_ind = nullind(ce
     .event_end_dt_tm), performed_dt_tm_ind = nullind(ce.performed_dt_tm),
    updt_dt_tm_ind = nullind(ce.updt_dt_tm), view_level_ind = nullind(ce.view_level),
    event_start_dt_tm_ind = nullind(ce.event_start_dt_tm),
    publish_flag_ind = nullind(ce.publish_flag), subtable_bit_map_ind = nullind(ce.subtable_bit_map),
    verified_dt_tm_ind = nullind(ce.verified_dt_tm),
    expiration_dt_tm_ind = nullind(ce.expiration_dt_tm), updt_task_ind = nullind(ce.updt_task),
    updt_cnt_ind = nullind(ce.updt_cnt),
    updt_applctx_ind = nullind(ce.updt_applctx)
    FROM (
     (
     (SELECT
      pn_rank = row_number() OVER(
      ORDER BY ior.io_end_dt_tm DESC), ior.io_end_dt_tm, ior.event_id,
      ior.valid_until_dt_tm
      FROM ce_intake_output_result ior
      WHERE parser(iowhereclause)
       AND ior.valid_until_dt_tm=cnvtdatetimeutc(max_date)
       AND ior.io_end_dt_tm <= cnvtdatetimeutc(start_dt_tm)
       AND ior.io_end_dt_tm >= cnvtdatetimeutc(end_dt_tm)
      WITH sqltype("f8","dq8","f8","dq8")))
     a),
     clinical_event ce
    WHERE a.pn_rank <= value(geventstofetch)
     AND ce.event_id=a.event_id
     AND ce.valid_until_dt_tm=a.valid_until_dt_tm
    ORDER BY a.io_end_dt_tm DESC
    DETAIL
     replycnt += 1
     IF (mod(replycnt,100)=1)
      stat = alterlist(reply->rb_list,(replycnt+ 99))
     ENDIF
     reply->rb_list[replycnt].event_id = ce.event_id, reply->rb_list[replycnt].event_end_dt_tm = ce
     .event_end_dt_tm, reply->rb_list[replycnt].clinical_event_id = ce.clinical_event_id,
     reply->rb_list[replycnt].valid_until_dt_tm = ce.valid_until_dt_tm, reply->rb_list[replycnt].
     valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->rb_list[replycnt].view_level = ce
     .view_level,
     reply->rb_list[replycnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, reply->rb_list[replycnt].
     clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->rb_list[replycnt].order_id = ce.order_id,
     reply->rb_list[replycnt].order_action_sequence = ce.order_action_sequence, reply->rb_list[
     replycnt].catalog_cd = ce.catalog_cd, reply->rb_list[replycnt].encntr_id = ce.encntr_id,
     reply->rb_list[replycnt].contributor_system_cd = ce.contributor_system_cd, reply->rb_list[
     replycnt].reference_nbr = ce.reference_nbr, reply->rb_list[replycnt].parent_event_id = ce
     .parent_event_id,
     reply->rb_list[replycnt].valid_from_dt_tm = ce.valid_from_dt_tm, reply->rb_list[replycnt].
     valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->rb_list[replycnt].event_class_cd = ce
     .event_class_cd,
     reply->rb_list[replycnt].event_cd = ce.event_cd, reply->rb_list[replycnt].event_tag = ce
     .event_tag, reply->rb_list[replycnt].event_tag_set_flag = ce.event_tag_set_flag,
     reply->rb_list[replycnt].collating_seq = ce.collating_seq, reply->rb_list[replycnt].
     event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[replycnt].event_end_dt_tm_ind =
     event_end_dt_tm_ind,
     reply->rb_list[replycnt].event_end_tz = ce.event_end_tz, reply->rb_list[replycnt].task_assay_cd
      = ce.task_assay_cd, reply->rb_list[replycnt].result_status_cd = ce.result_status_cd,
     reply->rb_list[replycnt].publish_flag = ce.publish_flag, reply->rb_list[replycnt].
     subtable_bit_map = ce.subtable_bit_map, reply->rb_list[replycnt].event_title_text = ce
     .event_title_text,
     reply->rb_list[replycnt].result_val = ce.result_val, reply->rb_list[replycnt].result_units_cd =
     ce.result_units_cd, reply->rb_list[replycnt].performed_dt_tm = ce.performed_dt_tm,
     reply->rb_list[replycnt].performed_dt_tm_ind = performed_dt_tm_ind, reply->rb_list[replycnt].
     performed_tz = ce.performed_tz, reply->rb_list[replycnt].performed_prsnl_id = ce
     .performed_prsnl_id,
     reply->rb_list[replycnt].normal_low = ce.normal_low, reply->rb_list[replycnt].normal_high = ce
     .normal_high, reply->rb_list[replycnt].updt_dt_tm = ce.updt_dt_tm,
     reply->rb_list[replycnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->rb_list[replycnt].
     note_importance_bit_map = ce.note_importance_bit_map, reply->rb_list[replycnt].entry_mode_cd =
     ce.entry_mode_cd,
     reply->rb_list[replycnt].source_cd = ce.source_cd, reply->rb_list[replycnt].clinical_seq = ce
     .clinical_seq, reply->rb_list[replycnt].task_assay_version_nbr = ce.task_assay_version_nbr,
     reply->rb_list[replycnt].modifier_long_text_id = ce.modifier_long_text_id, reply->rb_list[
     replycnt].view_level_ind = view_level_ind, reply->rb_list[replycnt].series_ref_nbr = ce
     .series_ref_nbr,
     reply->rb_list[replycnt].person_id = ce.person_id, reply->rb_list[replycnt].encntr_financial_id
      = ce.encntr_financial_id, reply->rb_list[replycnt].accession_nbr = ce.accession_nbr,
     reply->rb_list[replycnt].event_reltn_cd = ce.event_reltn_cd, reply->rb_list[replycnt].
     event_start_dt_tm = ce.event_start_dt_tm, reply->rb_list[replycnt].event_start_dt_tm_ind =
     event_start_dt_tm_ind,
     reply->rb_list[replycnt].event_start_tz = ce.event_start_tz, reply->rb_list[replycnt].
     record_status_cd = ce.record_status_cd, reply->rb_list[replycnt].authentic_flag = ce
     .authentic_flag,
     reply->rb_list[replycnt].publish_flag_ind = publish_flag_ind, reply->rb_list[replycnt].
     qc_review_cd = ce.qc_review_cd, reply->rb_list[replycnt].normalcy_cd = ce.normalcy_cd,
     reply->rb_list[replycnt].normalcy_method_cd = ce.normalcy_method_cd, reply->rb_list[replycnt].
     inquire_security_cd = ce.inquire_security_cd, reply->rb_list[replycnt].resource_group_cd = ce
     .resource_group_cd,
     reply->rb_list[replycnt].resource_cd = ce.resource_cd, reply->rb_list[replycnt].
     subtable_bit_map_ind = subtable_bit_map_ind, reply->rb_list[replycnt].result_time_units_cd = ce
     .result_time_units_cd,
     reply->rb_list[replycnt].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[replycnt].
     verified_dt_tm_ind = verified_dt_tm_ind, reply->rb_list[replycnt].verified_tz = ce.verified_tz,
     reply->rb_list[replycnt].verified_prsnl_id = ce.verified_prsnl_id, reply->rb_list[replycnt].
     critical_low = ce.critical_low, reply->rb_list[replycnt].critical_high = ce.critical_high,
     reply->rb_list[replycnt].expiration_dt_tm = ce.expiration_dt_tm, reply->rb_list[replycnt].
     expiration_dt_tm_ind = expiration_dt_tm_ind, reply->rb_list[replycnt].updt_id = ce.updt_id,
     reply->rb_list[replycnt].updt_task = ce.updt_task, reply->rb_list[replycnt].updt_task_ind =
     updt_task_ind, reply->rb_list[replycnt].updt_cnt = ce.updt_cnt,
     reply->rb_list[replycnt].updt_cnt_ind = updt_cnt_ind, reply->rb_list[replycnt].updt_applctx = ce
     .updt_applctx, reply->rb_list[replycnt].updt_applctx_ind = updt_applctx_ind,
     reply->rb_list[replycnt].src_event_id = ce.src_event_id, reply->rb_list[replycnt].
     src_clinsig_updt_dt_tm = ce.src_clinsig_updt_dt_tm, reply->rb_list[replycnt].nomen_string_flag
      = ce.nomen_string_flag,
     reply->rb_list[replycnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, reply->rb_list[replycnt].
     device_free_txt = ce.device_free_txt, reply->rb_list[replycnt].trait_bit_map = ce.trait_bit_map
    FOOT REPORT
     context->last_event_dt_tm = a.io_end_dt_tm, context->last_event_dt_tm_ind = 0
    WITH nocounter
   ;end select
   SET ioresultcnt = replycnt
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE executemergequery(null)
   SET eqwhereclause = " ce.valid_until_dt_tm = cnvtdatetimeutc(MAX_DATE) "
   IF (encntrlistsize > 0)
    SET eqwhereclause = build(eqwhereclause,
     " and expand(encntrListCnt, 1, encntrListSize, ce.encntr_id+0, ")
    SET eqwhereclause = build(eqwhereclause," request->encntr_id_list[encntrListCnt].encntr_id) ")
   ENDIF
   SELECT INTO "nl:"
    ce.event_id, valid_until_dt_tm_ind = nullind(ce.valid_until_dt_tm), clinsig_updt_dt_tm_ind =
    nullind(ce.clinsig_updt_dt_tm),
    valid_from_dt_tm_ind = nullind(ce.valid_from_dt_tm), event_end_dt_tm_ind = nullind(ce
     .event_end_dt_tm), performed_dt_tm_ind = nullind(ce.performed_dt_tm),
    updt_dt_tm_ind = nullind(ce.updt_dt_tm), view_level_ind = nullind(ce.view_level),
    event_start_dt_tm_ind = nullind(ce.event_start_dt_tm),
    publish_flag_ind = nullind(ce.publish_flag), subtable_bit_map_ind = nullind(ce.subtable_bit_map),
    verified_dt_tm_ind = nullind(ce.verified_dt_tm),
    expiration_dt_tm_ind = nullind(ce.expiration_dt_tm), updt_task_ind = nullind(ce.updt_task),
    updt_cnt_ind = nullind(ce.updt_cnt),
    updt_applctx_ind = nullind(ce.updt_applctx), lt.long_text
    FROM clinical_event ce,
     long_text lt
    WHERE (ce.person_id=request->person_id)
     AND ce.record_status_cd != record_status_deleted
     AND ce.event_cd IN (
    (SELECT
     ex.event_cd
     FROM v500_event_set_explode ex
     WHERE expand(mergeeventsetlistcnt,1,mergeeventsetlistsize,ex.event_set_cd,request->
      merge_event_set_list[mergeeventsetlistcnt].merge_event_set_cd)))
     AND parser(eqwhereclause)
     AND ce.event_end_dt_tm <= cnvtdatetimeutc(start_dt_tm)
     AND ce.event_end_dt_tm >= cnvtdatetimeutc(finish_end_dt_tm)
     AND lt.long_text_id=ce.modifier_long_text_id
    DETAIL
     replycnt += 1
     IF (mod(replycnt,100)=1)
      stat = alterlist(reply->rb_list,(replycnt+ 99))
     ENDIF
     reply->rb_list[replycnt].event_id = ce.event_id, reply->rb_list[replycnt].event_end_dt_tm = ce
     .event_end_dt_tm, reply->rb_list[replycnt].clinical_event_id = ce.clinical_event_id,
     reply->rb_list[replycnt].valid_until_dt_tm = ce.valid_until_dt_tm, reply->rb_list[replycnt].
     valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->rb_list[replycnt].view_level = ce
     .view_level,
     reply->rb_list[replycnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, reply->rb_list[replycnt].
     clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->rb_list[replycnt].order_id = ce.order_id,
     reply->rb_list[replycnt].order_action_sequence = ce.order_action_sequence, reply->rb_list[
     replycnt].catalog_cd = ce.catalog_cd, reply->rb_list[replycnt].encntr_id = ce.encntr_id,
     reply->rb_list[replycnt].contributor_system_cd = ce.contributor_system_cd, reply->rb_list[
     replycnt].reference_nbr = ce.reference_nbr, reply->rb_list[replycnt].parent_event_id = ce
     .parent_event_id,
     reply->rb_list[replycnt].valid_from_dt_tm = ce.valid_from_dt_tm, reply->rb_list[replycnt].
     valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->rb_list[replycnt].event_class_cd = ce
     .event_class_cd,
     reply->rb_list[replycnt].event_cd = ce.event_cd, reply->rb_list[replycnt].event_tag = ce
     .event_tag, reply->rb_list[replycnt].event_tag_set_flag = ce.event_tag_set_flag,
     reply->rb_list[replycnt].collating_seq = ce.collating_seq, reply->rb_list[replycnt].
     event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[replycnt].event_end_dt_tm_ind =
     event_end_dt_tm_ind,
     reply->rb_list[replycnt].event_end_tz = ce.event_end_tz, reply->rb_list[replycnt].task_assay_cd
      = ce.task_assay_cd, reply->rb_list[replycnt].result_status_cd = ce.result_status_cd,
     reply->rb_list[replycnt].publish_flag = ce.publish_flag, reply->rb_list[replycnt].
     subtable_bit_map = ce.subtable_bit_map, reply->rb_list[replycnt].event_title_text = ce
     .event_title_text,
     reply->rb_list[replycnt].result_val = ce.result_val, reply->rb_list[replycnt].result_units_cd =
     ce.result_units_cd, reply->rb_list[replycnt].performed_dt_tm = ce.performed_dt_tm,
     reply->rb_list[replycnt].performed_dt_tm_ind = performed_dt_tm_ind, reply->rb_list[replycnt].
     performed_tz = ce.performed_tz, reply->rb_list[replycnt].performed_prsnl_id = ce
     .performed_prsnl_id,
     reply->rb_list[replycnt].normal_low = ce.normal_low, reply->rb_list[replycnt].normal_high = ce
     .normal_high, reply->rb_list[replycnt].updt_dt_tm = ce.updt_dt_tm,
     reply->rb_list[replycnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->rb_list[replycnt].
     note_importance_bit_map = ce.note_importance_bit_map, reply->rb_list[replycnt].entry_mode_cd =
     ce.entry_mode_cd,
     reply->rb_list[replycnt].source_cd = ce.source_cd, reply->rb_list[replycnt].clinical_seq = ce
     .clinical_seq, reply->rb_list[replycnt].task_assay_version_nbr = ce.task_assay_version_nbr,
     reply->rb_list[replycnt].modifier_long_text_id = ce.modifier_long_text_id, reply->rb_list[
     replycnt].view_level_ind = view_level_ind, reply->rb_list[replycnt].series_ref_nbr = ce
     .series_ref_nbr,
     reply->rb_list[replycnt].person_id = ce.person_id, reply->rb_list[replycnt].encntr_financial_id
      = ce.encntr_financial_id, reply->rb_list[replycnt].accession_nbr = ce.accession_nbr,
     reply->rb_list[replycnt].event_reltn_cd = ce.event_reltn_cd, reply->rb_list[replycnt].
     event_start_dt_tm = ce.event_start_dt_tm, reply->rb_list[replycnt].event_start_dt_tm_ind =
     event_start_dt_tm_ind,
     reply->rb_list[replycnt].event_start_tz = ce.event_start_tz, reply->rb_list[replycnt].
     record_status_cd = ce.record_status_cd, reply->rb_list[replycnt].authentic_flag = ce
     .authentic_flag,
     reply->rb_list[replycnt].publish_flag_ind = publish_flag_ind, reply->rb_list[replycnt].
     qc_review_cd = ce.qc_review_cd, reply->rb_list[replycnt].normalcy_cd = ce.normalcy_cd,
     reply->rb_list[replycnt].normalcy_method_cd = ce.normalcy_method_cd, reply->rb_list[replycnt].
     inquire_security_cd = ce.inquire_security_cd, reply->rb_list[replycnt].resource_group_cd = ce
     .resource_group_cd,
     reply->rb_list[replycnt].resource_cd = ce.resource_cd, reply->rb_list[replycnt].
     subtable_bit_map_ind = subtable_bit_map_ind, reply->rb_list[replycnt].result_time_units_cd = ce
     .result_time_units_cd,
     reply->rb_list[replycnt].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[replycnt].
     verified_dt_tm_ind = verified_dt_tm_ind, reply->rb_list[replycnt].verified_tz = ce.verified_tz,
     reply->rb_list[replycnt].verified_prsnl_id = ce.verified_prsnl_id, reply->rb_list[replycnt].
     critical_low = ce.critical_low, reply->rb_list[replycnt].critical_high = ce.critical_high,
     reply->rb_list[replycnt].expiration_dt_tm = ce.expiration_dt_tm, reply->rb_list[replycnt].
     expiration_dt_tm_ind = expiration_dt_tm_ind, reply->rb_list[replycnt].updt_id = ce.updt_id,
     reply->rb_list[replycnt].updt_task = ce.updt_task, reply->rb_list[replycnt].updt_task_ind =
     updt_task_ind, reply->rb_list[replycnt].updt_cnt = ce.updt_cnt,
     reply->rb_list[replycnt].updt_cnt_ind = updt_cnt_ind, reply->rb_list[replycnt].updt_applctx = ce
     .updt_applctx, reply->rb_list[replycnt].updt_applctx_ind = updt_applctx_ind,
     reply->rb_list[replycnt].src_event_id = ce.src_event_id, reply->rb_list[replycnt].
     src_clinsig_updt_dt_tm = ce.src_clinsig_updt_dt_tm, reply->rb_list[replycnt].nomen_string_flag
      = ce.nomen_string_flag,
     reply->rb_list[replycnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, reply->rb_list[replycnt].
     device_free_txt = ce.device_free_txt, reply->rb_list[replycnt].trait_bit_map = ce.trait_bit_map
    FOOT REPORT
     IF (lt.long_text != null)
      donothing = 0
     ENDIF
    WITH nocounter
   ;end select
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE executereferenceeventquery(null)
   SET iowhereclause = "ior.person_id = request->PERSON_ID "
   IF (request->io_type_flag)
    SET iowhereclause = build(iowhereclause," and ior.io_type_flag = request->IO_TYPE_FLAG ")
   ENDIF
   IF (encntrlistsize > 0)
    SET iowhereclause = build(iowhereclause,
     " and expand( encntrListCnt, 1, encntrListSize, ior.encntr_id+0, ")
    SET iowhereclause = build(iowhereclause," request->encntr_id_list[encntrListCnt].encntr_id ) ")
   ENDIF
   SELECT INTO "nl:"
    ce.event_id, valid_until_dt_tm_ind = nullind(ce.valid_until_dt_tm), clinsig_updt_dt_tm_ind =
    nullind(ce.clinsig_updt_dt_tm),
    valid_from_dt_tm_ind = nullind(ce.valid_from_dt_tm), event_end_dt_tm_ind = nullind(ce
     .event_end_dt_tm), performed_dt_tm_ind = nullind(ce.performed_dt_tm),
    updt_dt_tm_ind = nullind(ce.updt_dt_tm), view_level_ind = nullind(ce.view_level),
    event_start_dt_tm_ind = nullind(ce.event_start_dt_tm),
    publish_flag_ind = nullind(ce.publish_flag), subtable_bit_map_ind = nullind(ce.subtable_bit_map),
    verified_dt_tm_ind = nullind(ce.verified_dt_tm),
    expiration_dt_tm_ind = nullind(ce.expiration_dt_tm), updt_task_ind = nullind(ce.updt_task),
    updt_cnt_ind = nullind(ce.updt_cnt),
    updt_applctx_ind = nullind(ce.updt_applctx)
    FROM ce_intake_output_result ior,
     clinical_event ce
    PLAN (ior
     WHERE parser(iowhereclause)
      AND ior.valid_until_dt_tm=cnvtdatetimeutc(max_date)
      AND ior.io_end_dt_tm <= cnvtdatetimeutc(start_dt_tm)
      AND ior.io_end_dt_tm >= cnvtdatetimeutc(finish_end_dt_tm)
      AND ior.event_id != ior.reference_event_id)
     JOIN (ce
     WHERE ce.event_id=ior.reference_event_id
      AND ce.valid_until_dt_tm=ior.valid_until_dt_tm)
    DETAIL
     replycnt += 1
     IF (mod(replycnt,100)=1)
      stat = alterlist(reply->rb_list,(replycnt+ 99))
     ENDIF
     reply->rb_list[replycnt].event_id = ce.event_id, reply->rb_list[replycnt].event_end_dt_tm = ce
     .event_end_dt_tm, reply->rb_list[replycnt].clinical_event_id = ce.clinical_event_id,
     reply->rb_list[replycnt].valid_until_dt_tm = ce.valid_until_dt_tm, reply->rb_list[replycnt].
     valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->rb_list[replycnt].view_level = ce
     .view_level,
     reply->rb_list[replycnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, reply->rb_list[replycnt].
     clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->rb_list[replycnt].order_id = ce.order_id,
     reply->rb_list[replycnt].order_action_sequence = ce.order_action_sequence, reply->rb_list[
     replycnt].catalog_cd = ce.catalog_cd, reply->rb_list[replycnt].encntr_id = ce.encntr_id,
     reply->rb_list[replycnt].contributor_system_cd = ce.contributor_system_cd, reply->rb_list[
     replycnt].reference_nbr = ce.reference_nbr, reply->rb_list[replycnt].parent_event_id = ce
     .parent_event_id,
     reply->rb_list[replycnt].valid_from_dt_tm = ce.valid_from_dt_tm, reply->rb_list[replycnt].
     valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->rb_list[replycnt].event_class_cd = ce
     .event_class_cd,
     reply->rb_list[replycnt].event_cd = ce.event_cd, reply->rb_list[replycnt].event_tag = ce
     .event_tag, reply->rb_list[replycnt].event_tag_set_flag = ce.event_tag_set_flag,
     reply->rb_list[replycnt].collating_seq = ce.collating_seq, reply->rb_list[replycnt].
     event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[replycnt].event_end_dt_tm_ind =
     event_end_dt_tm_ind,
     reply->rb_list[replycnt].event_end_tz = ce.event_end_tz, reply->rb_list[replycnt].task_assay_cd
      = ce.task_assay_cd, reply->rb_list[replycnt].result_status_cd = ce.result_status_cd,
     reply->rb_list[replycnt].publish_flag = ce.publish_flag, reply->rb_list[replycnt].
     subtable_bit_map = ce.subtable_bit_map, reply->rb_list[replycnt].event_title_text = ce
     .event_title_text,
     reply->rb_list[replycnt].result_val = ce.result_val, reply->rb_list[replycnt].result_units_cd =
     ce.result_units_cd, reply->rb_list[replycnt].performed_dt_tm = ce.performed_dt_tm,
     reply->rb_list[replycnt].performed_dt_tm_ind = performed_dt_tm_ind, reply->rb_list[replycnt].
     performed_tz = ce.performed_tz, reply->rb_list[replycnt].performed_prsnl_id = ce
     .performed_prsnl_id,
     reply->rb_list[replycnt].normal_low = ce.normal_low, reply->rb_list[replycnt].normal_high = ce
     .normal_high, reply->rb_list[replycnt].updt_dt_tm = ce.updt_dt_tm,
     reply->rb_list[replycnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->rb_list[replycnt].
     note_importance_bit_map = ce.note_importance_bit_map, reply->rb_list[replycnt].entry_mode_cd =
     ce.entry_mode_cd,
     reply->rb_list[replycnt].source_cd = ce.source_cd, reply->rb_list[replycnt].clinical_seq = ce
     .clinical_seq, reply->rb_list[replycnt].task_assay_version_nbr = ce.task_assay_version_nbr,
     reply->rb_list[replycnt].modifier_long_text_id = ce.modifier_long_text_id, reply->rb_list[
     replycnt].view_level_ind = view_level_ind, reply->rb_list[replycnt].series_ref_nbr = ce
     .series_ref_nbr,
     reply->rb_list[replycnt].person_id = ce.person_id, reply->rb_list[replycnt].encntr_financial_id
      = ce.encntr_financial_id, reply->rb_list[replycnt].accession_nbr = ce.accession_nbr,
     reply->rb_list[replycnt].event_reltn_cd = ce.event_reltn_cd, reply->rb_list[replycnt].
     event_start_dt_tm = ce.event_start_dt_tm, reply->rb_list[replycnt].event_start_dt_tm_ind =
     event_start_dt_tm_ind,
     reply->rb_list[replycnt].event_start_tz = ce.event_start_tz, reply->rb_list[replycnt].
     record_status_cd = ce.record_status_cd, reply->rb_list[replycnt].authentic_flag = ce
     .authentic_flag,
     reply->rb_list[replycnt].publish_flag_ind = publish_flag_ind, reply->rb_list[replycnt].
     qc_review_cd = ce.qc_review_cd, reply->rb_list[replycnt].normalcy_cd = ce.normalcy_cd,
     reply->rb_list[replycnt].normalcy_method_cd = ce.normalcy_method_cd, reply->rb_list[replycnt].
     inquire_security_cd = ce.inquire_security_cd, reply->rb_list[replycnt].resource_group_cd = ce
     .resource_group_cd,
     reply->rb_list[replycnt].resource_cd = ce.resource_cd, reply->rb_list[replycnt].
     subtable_bit_map_ind = subtable_bit_map_ind, reply->rb_list[replycnt].result_time_units_cd = ce
     .result_time_units_cd,
     reply->rb_list[replycnt].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[replycnt].
     verified_dt_tm_ind = verified_dt_tm_ind, reply->rb_list[replycnt].verified_tz = ce.verified_tz,
     reply->rb_list[replycnt].verified_prsnl_id = ce.verified_prsnl_id, reply->rb_list[replycnt].
     critical_low = ce.critical_low, reply->rb_list[replycnt].critical_high = ce.critical_high,
     reply->rb_list[replycnt].expiration_dt_tm = ce.expiration_dt_tm, reply->rb_list[replycnt].
     expiration_dt_tm_ind = expiration_dt_tm_ind, reply->rb_list[replycnt].updt_id = ce.updt_id,
     reply->rb_list[replycnt].updt_task = ce.updt_task, reply->rb_list[replycnt].updt_task_ind =
     updt_task_ind, reply->rb_list[replycnt].updt_cnt = ce.updt_cnt,
     reply->rb_list[replycnt].updt_cnt_ind = updt_cnt_ind, reply->rb_list[replycnt].updt_applctx = ce
     .updt_applctx, reply->rb_list[replycnt].updt_applctx_ind = updt_applctx_ind,
     reply->rb_list[replycnt].src_event_id = ce.src_event_id, reply->rb_list[replycnt].
     src_clinsig_updt_dt_tm = ce.src_clinsig_updt_dt_tm, reply->rb_list[replycnt].nomen_string_flag
      = ce.nomen_string_flag,
     reply->rb_list[replycnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, reply->rb_list[replycnt].
     device_free_txt = ce.device_free_txt, reply->rb_list[replycnt].trait_bit_map = ce.trait_bit_map
    WITH nocounter
   ;end select
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE executefinishday(null)
   CALL setfinishdaytimerange(null)
   SET finishwhereclause = "ior.person_id = request->PERSON_ID "
   SET finishwhereclause = build(finishwhereclause,
    " and ior.valid_until_dt_tm = cnvtdatetimeutc(MAX_DATE) ")
   IF (request->io_type_flag)
    SET finishwhereclause = build(finishwhereclause," and ior.io_type_flag = request->IO_TYPE_FLAG ")
   ENDIF
   SET finishwhereclause = build(finishwhereclause,
    " and ior.io_end_dt_tm <= cnvtdatetimeutc(finish_start_dt_tm) ")
   SET finishwhereclause = build(finishwhereclause,
    " and ior.io_end_dt_tm >= cnvtdatetimeutc(finish_end_dt_tm) ")
   IF (encntrlistsize > 0)
    SET finishwhereclause = build(finishwhereclause,
     " and expand( encntrListCnt, 1, encntrListSize, ior.encntr_id+0, ")
    SET finishwhereclause = build(finishwhereclause,
     " request->encntr_id_list[encntrListCnt].encntr_id ) ")
   ENDIF
   SELECT INTO "nl:"
    ce.event_id, valid_until_dt_tm_ind = nullind(ce.valid_until_dt_tm), clinsig_updt_dt_tm_ind =
    nullind(ce.clinsig_updt_dt_tm),
    valid_from_dt_tm_ind = nullind(ce.valid_from_dt_tm), event_end_dt_tm_ind = nullind(ce
     .event_end_dt_tm), performed_dt_tm_ind = nullind(ce.performed_dt_tm),
    updt_dt_tm_ind = nullind(ce.updt_dt_tm), view_level_ind = nullind(ce.view_level),
    event_start_dt_tm_ind = nullind(ce.event_start_dt_tm),
    publish_flag_ind = nullind(ce.publish_flag), subtable_bit_map_ind = nullind(ce.subtable_bit_map),
    verified_dt_tm_ind = nullind(ce.verified_dt_tm),
    expiration_dt_tm_ind = nullind(ce.expiration_dt_tm), updt_task_ind = nullind(ce.updt_task),
    updt_cnt_ind = nullind(ce.updt_cnt),
    updt_applctx_ind = nullind(ce.updt_applctx)
    FROM clinical_event ce,
     ce_intake_output_result ior
    PLAN (ior
     WHERE parser(finishwhereclause))
     JOIN (ce
     WHERE ce.event_id=ior.event_id
      AND ce.valid_until_dt_tm=ior.valid_until_dt_tm)
    ORDER BY ior.io_end_dt_tm DESC
    DETAIL
     replycnt += 1
     IF (mod(replycnt,100)=1)
      stat = alterlist(reply->rb_list,(replycnt+ 99))
     ENDIF
     reply->rb_list[replycnt].event_id = ce.event_id, reply->rb_list[replycnt].event_end_dt_tm = ce
     .event_end_dt_tm, reply->rb_list[replycnt].clinical_event_id = ce.clinical_event_id,
     reply->rb_list[replycnt].valid_until_dt_tm = ce.valid_until_dt_tm, reply->rb_list[replycnt].
     valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->rb_list[replycnt].view_level = ce
     .view_level,
     reply->rb_list[replycnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, reply->rb_list[replycnt].
     clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->rb_list[replycnt].order_id = ce.order_id,
     reply->rb_list[replycnt].order_action_sequence = ce.order_action_sequence, reply->rb_list[
     replycnt].catalog_cd = ce.catalog_cd, reply->rb_list[replycnt].encntr_id = ce.encntr_id,
     reply->rb_list[replycnt].contributor_system_cd = ce.contributor_system_cd, reply->rb_list[
     replycnt].reference_nbr = ce.reference_nbr, reply->rb_list[replycnt].parent_event_id = ce
     .parent_event_id,
     reply->rb_list[replycnt].valid_from_dt_tm = ce.valid_from_dt_tm, reply->rb_list[replycnt].
     valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->rb_list[replycnt].event_class_cd = ce
     .event_class_cd,
     reply->rb_list[replycnt].event_cd = ce.event_cd, reply->rb_list[replycnt].event_tag = ce
     .event_tag, reply->rb_list[replycnt].event_tag_set_flag = ce.event_tag_set_flag,
     reply->rb_list[replycnt].collating_seq = ce.collating_seq, reply->rb_list[replycnt].
     event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[replycnt].event_end_dt_tm_ind =
     event_end_dt_tm_ind,
     reply->rb_list[replycnt].event_end_tz = ce.event_end_tz, reply->rb_list[replycnt].task_assay_cd
      = ce.task_assay_cd, reply->rb_list[replycnt].result_status_cd = ce.result_status_cd,
     reply->rb_list[replycnt].publish_flag = ce.publish_flag, reply->rb_list[replycnt].
     subtable_bit_map = ce.subtable_bit_map, reply->rb_list[replycnt].event_title_text = ce
     .event_title_text,
     reply->rb_list[replycnt].result_val = ce.result_val, reply->rb_list[replycnt].result_units_cd =
     ce.result_units_cd, reply->rb_list[replycnt].performed_dt_tm = ce.performed_dt_tm,
     reply->rb_list[replycnt].performed_dt_tm_ind = performed_dt_tm_ind, reply->rb_list[replycnt].
     performed_tz = ce.performed_tz, reply->rb_list[replycnt].performed_prsnl_id = ce
     .performed_prsnl_id,
     reply->rb_list[replycnt].normal_low = ce.normal_low, reply->rb_list[replycnt].normal_high = ce
     .normal_high, reply->rb_list[replycnt].updt_dt_tm = ce.updt_dt_tm,
     reply->rb_list[replycnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->rb_list[replycnt].
     note_importance_bit_map = ce.note_importance_bit_map, reply->rb_list[replycnt].entry_mode_cd =
     ce.entry_mode_cd,
     reply->rb_list[replycnt].source_cd = ce.source_cd, reply->rb_list[replycnt].clinical_seq = ce
     .clinical_seq, reply->rb_list[replycnt].task_assay_version_nbr = ce.task_assay_version_nbr,
     reply->rb_list[replycnt].modifier_long_text_id = ce.modifier_long_text_id, reply->rb_list[
     replycnt].view_level_ind = view_level_ind, reply->rb_list[replycnt].series_ref_nbr = ce
     .series_ref_nbr,
     reply->rb_list[replycnt].person_id = ce.person_id, reply->rb_list[replycnt].encntr_financial_id
      = ce.encntr_financial_id, reply->rb_list[replycnt].accession_nbr = ce.accession_nbr,
     reply->rb_list[replycnt].event_reltn_cd = ce.event_reltn_cd, reply->rb_list[replycnt].
     event_start_dt_tm = ce.event_start_dt_tm, reply->rb_list[replycnt].event_start_dt_tm_ind =
     event_start_dt_tm_ind,
     reply->rb_list[replycnt].event_start_tz = ce.event_start_tz, reply->rb_list[replycnt].
     record_status_cd = ce.record_status_cd, reply->rb_list[replycnt].authentic_flag = ce
     .authentic_flag,
     reply->rb_list[replycnt].publish_flag_ind = publish_flag_ind, reply->rb_list[replycnt].
     qc_review_cd = ce.qc_review_cd, reply->rb_list[replycnt].normalcy_cd = ce.normalcy_cd,
     reply->rb_list[replycnt].normalcy_method_cd = ce.normalcy_method_cd, reply->rb_list[replycnt].
     inquire_security_cd = ce.inquire_security_cd, reply->rb_list[replycnt].resource_group_cd = ce
     .resource_group_cd,
     reply->rb_list[replycnt].resource_cd = ce.resource_cd, reply->rb_list[replycnt].
     subtable_bit_map_ind = subtable_bit_map_ind, reply->rb_list[replycnt].result_time_units_cd = ce
     .result_time_units_cd,
     reply->rb_list[replycnt].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[replycnt].
     verified_dt_tm_ind = verified_dt_tm_ind, reply->rb_list[replycnt].verified_tz = ce.verified_tz,
     reply->rb_list[replycnt].verified_prsnl_id = ce.verified_prsnl_id, reply->rb_list[replycnt].
     critical_low = ce.critical_low, reply->rb_list[replycnt].critical_high = ce.critical_high,
     reply->rb_list[replycnt].expiration_dt_tm = ce.expiration_dt_tm, reply->rb_list[replycnt].
     expiration_dt_tm_ind = expiration_dt_tm_ind, reply->rb_list[replycnt].updt_id = ce.updt_id,
     reply->rb_list[replycnt].updt_task = ce.updt_task, reply->rb_list[replycnt].updt_task_ind =
     updt_task_ind, reply->rb_list[replycnt].updt_cnt = ce.updt_cnt,
     reply->rb_list[replycnt].updt_cnt_ind = updt_cnt_ind, reply->rb_list[replycnt].updt_applctx = ce
     .updt_applctx, reply->rb_list[replycnt].updt_applctx_ind = updt_applctx_ind,
     reply->rb_list[replycnt].src_event_id = ce.src_event_id, reply->rb_list[replycnt].
     src_clinsig_updt_dt_tm = ce.src_clinsig_updt_dt_tm, reply->rb_list[replycnt].nomen_string_flag
      = ce.nomen_string_flag,
     reply->rb_list[replycnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, reply->rb_list[replycnt].
     device_free_txt = ce.device_free_txt, reply->rb_list[replycnt].trait_bit_map = ce.trait_bit_map
    FOOT REPORT
     context->last_event_dt_tm = ior.io_end_dt_tm, context->last_event_dt_tm_ind = 0
    WITH nocounter
   ;end select
   SET ioresultcnt = replycnt
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    GO TO exit_script
   ENDIF
   IF ((stop_dt_tm < context->last_event_dt_tm))
    SET context->last_event_dt_tm = cnvtlookbehind("1,S",stop_dt_tm)
   ENDIF
   SET context->last_event_dt_tm = cnvtlookbehind("1,S",context->last_event_dt_tm)
 END ;Subroutine
 SUBROUTINE setfinishdaytimerange(null)
   SET stop_dt_tm = cnvtdatetimeutc(format(cnvtdatetimeutc(context->last_event_dt_tm,1),
     "DD-MMM-YYYY;;D"))
   IF ((request->start_hour > 0))
    SET interval = build(request->start_hour,",H")
    SET stop_dt_tm = cnvtlookahead(interval,stop_dt_tm)
   ENDIF
   IF ((context->last_event_dt_tm <= stop_dt_tm))
    SET stop_dt_tm = datetimeadd(stop_dt_tm,- (1))
   ENDIF
   SET finish_start_dt_tm = context->last_event_dt_tm
   SET finish_end_dt_tm = stop_dt_tm
   SET context->last_event_dt_tm = finish_start_dt_tm
   SET context->last_event_dt_tm_ind = 0
 END ;Subroutine
 SUBROUTINE executecheckmore(null)
   IF (end_dt_tm=finish_end_dt_tm)
    SET context->cursor_exhausted = ocf_last_one
    RETURN
   ENDIF
   SET finishwhereclause = "ior.person_id = request->PERSON_ID "
   IF (request->io_type_flag)
    SET finishwhereclause = build(finishwhereclause," and ior.io_type_flag = request->IO_TYPE_FLAG ")
   ENDIF
   IF (encntrlistsize > 0)
    SET finishwhereclause = build(finishwhereclause,
     " and expand( encntrListCnt, 1, encntrListSize, ior.encntr_id+0, ")
    SET finishwhereclause = build(finishwhereclause,
     " request->encntr_id_list[encntrListCnt].encntr_id ) ")
   ENDIF
   SELECT INTO "nl:"
    ior.person_id
    FROM ce_intake_output_result ior
    PLAN (ior
     WHERE parser(finishwhereclause)
      AND ior.valid_until_dt_tm=cnvtdatetimeutc(max_date)
      AND ior.io_end_dt_tm <= cnvtdatetimeutc(context->last_event_dt_tm)
      AND ior.io_end_dt_tm >= cnvtdatetimeutc(end_dt_tm))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET context->cursor_exhausted = ocf_last_one
   ELSE
    SET context->cursor_exhausted = 0
   ENDIF
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
