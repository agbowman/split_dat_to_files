CREATE PROGRAM bhs_athn_sign_master_doc
 RECORD orequest(
   1 ensure_type = i2
   1 event_subclass_cd = f8
   1 eso_action_meaning = vc
   1 ensure_type2 = i2
   1 override_pat_context_tz = i4
   1 clin_event
     2 ensure_type = i2
     2 event_id = f8
     2 view_level = i4
     2 view_level_ind = i2
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_cd_cki = vc
     2 series_ref_nbr = vc
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_financial_id = f8
     2 accession_nbr = vc
     2 contributor_system_cd = f8
     2 contributor_system_cd_cki = vc
     2 reference_nbr = vc
     2 parent_event_id = f8
     2 event_class_cd = f8
     2 event_class_cd_cki = vc
     2 event_cd = f8
     2 event_cd_cki = vc
     2 event_tag = vc
     2 event_reltn_cd = f8
     2 event_reltn_cd_cki = vc
     2 event_start_dt_tm = dq8
     2 event_start_dt_tm_ind = i2
     2 event_end_dt_tm = dq8
     2 event_end_dt_tm_ind = i2
     2 event_end_dt_tm_os = f8
     2 event_end_dt_tm_os_ind = i2
     2 task_assay_cd = f8
     2 task_assay_cd_cki = vc
     2 record_status_cd = f8
     2 record_status_cd_cki = vc
     2 result_status_cd = f8
     2 result_status_cd_cki = vc
     2 authentic_flag = i2
     2 authentic_flag_ind = i2
     2 publish_flag = i2
     2 publish_flag_ind = i2
     2 qc_review_cd = f8
     2 qc_review_cd_cki = vc
     2 normalcy_cd = f8
     2 normalcy_cd_cki = vc
     2 normalcy_method_cd = f8
     2 normalcy_method_cd_cki = vc
     2 inquire_security_cd = f8
     2 inquire_security_cd_cki = vc
     2 resource_group_cd = f8
     2 resource_group_cd_cki = vc
     2 resource_cd = f8
     2 resource_cd_cki = vc
     2 subtable_bit_map = i4
     2 subtable_bit_map_ind = i2
     2 event_title_text = vc
     2 collating_seq = vc
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 expiration_dt_tm = dq8
     2 expiration_dt_tm_ind = i2
     2 note_importance_bit_map = i2
     2 event_tag_set_flag = i2
     2 clinsig_updt_dt_tm_flag = i2
     2 clinsig_updt_dt_tm = dq8
     2 clinsig_updt_dt_tm_ind = i2
     2 clinical_event_id = f8
     2 valid_until_dt_tm = dq8
     2 valid_until_dt_tm_ind = i2
     2 valid_from_dt_tm = dq8
     2 valid_from_dt_tm_ind = i2
     2 result_val = vc
     2 result_units_cd = f8
     2 result_units_cd_cki = vc
     2 result_time_units_cd = f8
     2 result_time_units_cd_cki = vc
     2 verified_dt_tm = dq8
     2 verified_dt_tm_ind = i2
     2 verified_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_dt_tm_ind = i2
     2 performed_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 updt_dt_tm_ind = i2
     2 updt_id = f8
     2 updt_task = i4
     2 updt_task_ind = i2
     2 updt_cnt = i4
     2 updt_cnt_ind = i2
     2 updt_applctx = i4
     2 updt_applctx_ind = i2
     2 ensure_type2 = i2
     2 order_action_sequence = i4
     2 entry_mode_cd = f8
     2 source_cd = f8
     2 clinical_seq = vc
     2 event_start_tz = i4
     2 event_end_tz = i4
     2 verified_tz = i4
     2 performed_tz = i4
     2 replacement_event_id = f8
     2 task_assay_version_nbr = f8
     2 modifier_long_text = vc
     2 modifier_long_text_id = f8
     2 src_event_id = f8
     2 src_clinsig_updt_dt_tm = dq8
     2 nomen_string_flag = i2
     2 ce_dynamic_label_id = f8
     2 replacement_label_id = f8
     2 event_prsnl_list[*]
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 action_type_cd = f8
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 action_prsnl_pin = vc
       3 defeat_succn_ind = i2
       3 ce_event_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
       3 ensure_type = i2
       3 digital_signature_ident = vc
       3 action_prsnl_group_id = f8
       3 request_prsnl_group_id = f8
       3 receiving_person_id = f8
       3 receiving_person_ft = vc
 )
 RECORD t_record(
   1 event_cnt = i4
   1 event_qual[*]
     2 event_id = f8
     2 updt_cnt = i4
 )
 DECLARE updt_cnt = i4
 DECLARE author_id = f8
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.parent_event_id= $2)
    AND ce.valid_until_dt_tm > sysdate)
  HEAD REPORT
   updt_cnt = ce.updt_cnt, author_id = ce.performed_prsnl_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.parent_event_id= $2)
    AND (ce.event_id !=  $2)
    AND ce.valid_until_dt_tm > sysdate)
  DETAIL
   t_record->event_cnt = (t_record->event_cnt+ 1), stat = alterlist(t_record->event_qual,t_record->
    event_cnt), t_record->event_qual[t_record->event_cnt].event_id = ce.event_id,
   t_record->event_qual[t_record->event_cnt].updt_cnt = ce.updt_cnt
  WITH nocounter, time = 30
 ;end select
 SET orequest->ensure_type = 2
 SET orequest->clin_event[1].event_id =  $2
 SET orequest->clin_event[1].view_level = 1
 SET orequest->clin_event[1].publish_flag = 1
 SET orequest->clin_event[1].record_status_cd = 188
 SET orequest->clin_event[1].result_status_cd = 25
 SET orequest->clin_event[1].updt_cnt = updt_cnt
 SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,2)
 SET orequest->clin_event[1].event_prsnl_list[1].event_id =  $2
 SET orequest->clin_event[1].event_prsnl_list[1].action_prsnl_id = author_id
 SET orequest->clin_event[1].event_prsnl_list[1].action_type_cd = 112
 SET orequest->clin_event[1].event_prsnl_list[1].action_dt_tm = sysdate
 SET orequest->clin_event[1].event_prsnl_list[1].action_status_cd = 653
 SET orequest->clin_event[1].event_prsnl_list[1].proxy_prsnl_id =  $3
 SET orequest->clin_event[1].event_prsnl_list[2].ensure_type = 3
 SET orequest->clin_event[1].event_prsnl_list[2].event_id =  $2
 SET orequest->clin_event[1].event_prsnl_list[2].action_prsnl_id = author_id
 SET orequest->clin_event[1].event_prsnl_list[2].action_type_cd = 107
 SET orequest->clin_event[1].event_prsnl_list[2].action_dt_tm = sysdate
 SET orequest->clin_event[1].event_prsnl_list[2].action_status_cd = 653
 SET orequest->clin_event[1].event_prsnl_list[2].request_prsnl_id = author_id
 SET orequest->clin_event[1].event_prsnl_list[2].proxy_prsnl_id =  $3
 SET stat = tdbexecute(3200000,3200000,1000012,"REC",orequest,
  "REC",oreply)
 SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,0)
 FOR (i = 1 TO t_record->event_cnt)
   SET orequest->clin_event[1].event_id = t_record->event_qual[i].event_id
   SET orequest->clin_event[1].result_status_cd = 25
   SET orequest->clin_event[1].updt_cnt = t_record->event_qual[i].updt_cnt
   SET orequest->clin_event[1].view_level = 0
   SET stat = tdbexecute(3200000,3200000,1000012,"REC",orequest,
    "REC",oreply)
 ENDFOR
 CALL echojson(oreply, $1)
END GO
