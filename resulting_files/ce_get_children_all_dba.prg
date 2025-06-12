CREATE PROGRAM ce_get_children_all:dba
 DECLARE stat_i4 = i4 WITH protect, noconstant(0)
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 DECLARE stat_vc = vc WITH protect, noconstant("")
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 DECLARE eventcnt = i4 WITH noconstant(0)
 DECLARE eventvercnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 SET ntotal2 = value(size(request->event_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat_i4 = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT INTO "nl:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   clinical_event ce
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ce
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.parent_event_id,request->event_list[idx].event_id
    )
    AND ce.parent_event_id != ce.event_id
    AND ce.record_status_cd != record_status_deleted)
  ORDER BY ce.event_id, ce.parent_event_id, ce.valid_until_dt_tm
  HEAD ce.event_id
   donothing = 0
  HEAD ce.parent_event_id
   eventcnt += 1
   IF (mod(eventcnt,10)=1)
    stat_i4 = alterlist(reply->event_list,(eventcnt+ 9))
   ENDIF
   reply->event_list[eventcnt].event_id = ce.event_id, reply->event_list[eventcnt].parent_event_id =
   ce.parent_event_id
  HEAD ce.valid_until_dt_tm
   eventvercnt += 1
   IF (mod(eventvercnt,10)=1)
    stat_i4 = alterlist(reply->event_list[eventcnt].event_versions_list,(eventvercnt+ 9))
   ENDIF
  DETAIL
   reply->event_list[eventcnt].event_versions_list[eventvercnt].clinical_event_id = ce
   .clinical_event_id, reply->event_list[eventcnt].event_versions_list[eventvercnt].event_id = ce
   .event_id, reply->event_list[eventcnt].event_versions_list[eventvercnt].valid_until_dt_tm = ce
   .valid_until_dt_tm,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].view_level = ce.view_level, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].order_id = ce.order_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].order_action_sequence = ce
   .order_action_sequence, reply->event_list[eventcnt].event_versions_list[eventvercnt].catalog_cd =
   ce.catalog_cd, reply->event_list[eventcnt].event_versions_list[eventvercnt].encntr_id = ce
   .encntr_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].contributor_system_cd = ce
   .contributor_system_cd, reply->event_list[eventcnt].event_versions_list[eventvercnt].reference_nbr
    = ce.reference_nbr, reply->event_list[eventcnt].event_versions_list[eventvercnt].parent_event_id
    = ce.parent_event_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].valid_from_dt_tm = ce
   .valid_from_dt_tm, reply->event_list[eventcnt].event_versions_list[eventvercnt].event_class_cd =
   ce.event_class_cd, reply->event_list[eventcnt].event_versions_list[eventvercnt].event_cd = ce
   .event_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_tag = ce.event_tag, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].collating_seq = ce.collating_seq, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].event_end_dt_tm = ce.event_end_dt_tm,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_end_tz = ce.event_end_tz, reply
   ->event_list[eventcnt].event_versions_list[eventvercnt].task_assay_cd = ce.task_assay_cd, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].result_status_cd = ce.result_status_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].publish_flag = ce.publish_flag, reply
   ->event_list[eventcnt].event_versions_list[eventvercnt].subtable_bit_map = ce.subtable_bit_map,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_title_text = ce
   .event_title_text,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].result_val = ce.result_val, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].result_units_cd = ce.result_units_cd, reply
   ->event_list[eventcnt].event_versions_list[eventvercnt].performed_dt_tm = ce.performed_dt_tm,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].performed_tz = ce.performed_tz, reply
   ->event_list[eventcnt].event_versions_list[eventvercnt].performed_prsnl_id = ce.performed_prsnl_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].normal_low = ce.normal_low,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].normal_high = ce.normal_high, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].updt_dt_tm = ce.updt_dt_tm, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].note_importance_bit_map = ce
   .note_importance_bit_map,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].entry_mode_cd = ce.entry_mode_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].source_cd = ce.source_cd, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].clinical_seq = ce.clinical_seq,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].task_assay_version_nbr = ce
   .task_assay_version_nbr, reply->event_list[eventcnt].event_versions_list[eventvercnt].
   modifier_long_text_id = ce.modifier_long_text_id, reply->event_list[eventcnt].event_versions_list[
   eventvercnt].series_ref_nbr = ce.series_ref_nbr,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].person_id = ce.person_id, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].encntr_financial_id = ce.encntr_financial_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].accession_nbr = ce.accession_nbr,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_reltn_cd = ce.event_reltn_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_start_dt_tm = ce
   .event_start_dt_tm, reply->event_list[eventcnt].event_versions_list[eventvercnt].event_start_tz =
   ce.event_start_tz,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].record_status_cd = ce
   .record_status_cd, reply->event_list[eventcnt].event_versions_list[eventvercnt].authentic_flag =
   ce.authentic_flag, reply->event_list[eventcnt].event_versions_list[eventvercnt].qc_review_cd = ce
   .qc_review_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].normalcy_cd = ce.normalcy_cd, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].normalcy_method_cd = ce.normalcy_method_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].inquire_security_cd = ce
   .inquire_security_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].resource_group_cd = ce
   .resource_group_cd, reply->event_list[eventcnt].event_versions_list[eventvercnt].resource_cd = ce
   .resource_cd, reply->event_list[eventcnt].event_versions_list[eventvercnt].result_time_units_cd =
   ce.result_time_units_cd,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].verified_dt_tm = ce.verified_dt_tm,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].verified_tz = ce.verified_tz, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].verified_prsnl_id = ce.verified_prsnl_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].critical_low = ce.critical_low, reply
   ->event_list[eventcnt].event_versions_list[eventvercnt].critical_high = ce.critical_high, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].expiration_dt_tm = ce.expiration_dt_tm,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].updt_id = ce.updt_id, reply->
   event_list[eventcnt].event_versions_list[eventvercnt].updt_task = ce.updt_task, reply->event_list[
   eventcnt].event_versions_list[eventvercnt].updt_cnt = ce.updt_cnt,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].updt_applctx = ce.updt_applctx, reply
   ->event_list[eventcnt].event_versions_list[eventvercnt].event_end_dt_tm_os = ce.event_end_dt_tm_os,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_tag_set_flag = ce
   .event_tag_set_flag,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].event_start_tz = ce.event_start_tz,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].nomen_string_flag = ce
   .nomen_string_flag, reply->event_list[eventcnt].event_versions_list[eventvercnt].
   ce_dynamic_label_id = ce.ce_dynamic_label_id,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].device_free_txt = ce.device_free_txt,
   reply->event_list[eventcnt].event_versions_list[eventvercnt].trait_bit_map = ce.trait_bit_map,
   stat_vc = assign(validate(reply->event_list[eventcnt].event_versions_list[eventvercnt].
     normal_ref_range_txt,""),ce.normal_ref_range_txt),
   stat_f8 = assign(validate(reply->event_list[eventcnt].event_versions_list[eventvercnt].
     ce_grouping_id,0),ce.ce_grouping_id), stat_i4 = assign(validate(reply->event_list[eventcnt].
     event_versions_list[eventvercnt].subtable_bit_map2,0),ce.subtable_bit_map2)
  FOOT  ce.valid_until_dt_tm
   donothing = 0
  FOOT  ce.parent_event_id
   stat_i4 = alterlist(reply->event_list[eventcnt].event_versions_list,eventvercnt), eventvercnt = 0
  FOOT  ce.event_id
   donothing = 0
  WITH nocounter
 ;end select
 SET stat_i4 = alterlist(reply->event_list,eventcnt)
 SET reply->qual = eventcnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
