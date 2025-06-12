CREATE PROGRAM bhs_athn_upd_doc_in_error
 FREE RECORD result
 RECORD result(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE formaterrorcomment(null) = vc
 DECLARE calleventensureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID EVENT ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (((textlen( $4)=0) OR (cnvtdatetime( $4) <= 0)) )
  CALL echo("INVALID UPDATE DTTM PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calleventensureserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 SUBROUTINE formaterrorcomment(null)
   DECLARE formatted_comment = vc WITH protect, noconstant(trim( $5,3))
   DECLARE crlf = vc WITH protect, constant(concat(char(13),char(10)))
   CALL echo(build("UNFORMATTED ERROR COMMENT: ",formatted_comment))
   IF (textlen(formatted_comment))
    SET formatted_comment = replace(formatted_comment,"ltpercgt","%",0)
    SET formatted_comment = replace(formatted_comment,"ltampgt","&",0)
    SET formatted_comment = replace(formatted_comment,"ltsquotgt","'",0)
    SET formatted_comment = replace(formatted_comment,"ltscolgt",";",0)
    SET formatted_comment = replace(formatted_comment,"ltpipgt","|",0)
    SET formatted_comment = replace(formatted_comment,"ltless","<",0)
    SET formatted_comment = replace(formatted_comment,"ltgrtr",">",0)
    SET formatted_comment = replace(formatted_comment,"ltcrlf",crlf,0)
   ENDIF
   CALL echo(build("FORMATTED ERROR COMMENT: ",formatted_comment))
   RETURN(formatted_comment)
 END ;Subroutine
 SUBROUTINE calleventensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(600108)
   DECLARE requestid = i4 WITH constant(1000012)
   DECLARE error_comment = vc WITH protect, noconstant("")
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE c_in_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
   DECLARE c_res_comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"RES COMMENT"))
   DECLARE c_ah_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"AH"))
   DECLARE c_cerner_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13,"CERNER"))
   DECLARE c_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
   DECLARE c_modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
   DECLARE c_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
   DECLARE now = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FREE RECORD cerequest
   RECORD cerequest(
     1 ensure_type = i2
     1 event_subclass_cd = f8
     1 eso_action_meaning = vc
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
       2 io_result[*]
         3 person_id = f8
         3 io_dt_tm = dq8
         3 io_dt_tm_ind = i2
         3 type_cd = f8
         3 group_cd = f8
         3 volume = f8
         3 volume_ind = i2
         3 authentic_flag = i2
         3 authentic_flag_ind = i2
         3 record_status_cd = f8
         3 io_comment = vc
         3 system_note = vc
         3 ce_io_result_id = f8
         3 event_id = f8
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
       2 specimen_coll[*]
         3 specimen_id = f8
         3 container_id = f8
         3 container_type_cd = f8
         3 specimen_status_cd = f8
         3 collect_dt_tm = dq8
         3 collect_dt_tm_ind = i2
         3 collect_method_cd = f8
         3 collect_loc_cd = f8
         3 collect_prsnl_id = f8
         3 collect_volume = f8
         3 collect_volume_ind = i2
         3 collect_unit_cd = f8
         3 collect_priority_cd = f8
         3 source_type_cd = f8
         3 source_text = vc
         3 body_site_cd = f8
         3 danger_cd = f8
         3 positive_ind = i2
         3 positive_ind_ind = i2
         3 specimen_trans_list[*]
           4 sequence_nbr = i4
           4 sequence_nbr_ind = i2
           4 transfer_dt_tm = dq8
           4 transfer_dt_tm_ind = i2
           4 transfer_prsnl_id = f8
           4 transfer_loc_cd = f8
           4 receive_dt_tm = dq8
           4 receive_dt_tm_ind = i2
           4 receive_prsnl_id = f8
           4 receive_loc_cd = f8
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 blob_result[*]
         3 succession_type_cd = f8
         3 sub_series_ref_nbr = vc
         3 storage_cd = f8
         3 format_cd = f8
         3 device_cd = f8
         3 blob_handle = vc
         3 blob_attributes = vc
         3 blob[*]
           4 blob_seq_num = i4
           4 blob_seq_num_ind = i2
           4 compression_cd = f8
           4 blob_contents = gvc
           4 blob_contents_ind = i2
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 blob_length = i4
           4 blob_length_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 blob_summary[*]
           4 blob_length = i4
           4 blob_length_ind = i2
           4 format_cd = f8
           4 compression_cd = f8
           4 checksum = i4
           4 checksum_ind = i2
           4 long_blob = gvc
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 ce_blob_summary_id = f8
           4 blob_summary_id = f8
           4 event_id = f8
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
         3 valid_from_dt_tm = dq8
         3 valid_from_dt_tm_ind = i2
         3 valid_until_dt_tm = dq8
         3 valid_until_dt_tm_ind = i2
         3 max_sequence_nbr = i4
         3 max_sequence_nbr_ind = i2
         3 checksum = i4
         3 checksum_ind = i2
         3 updt_dt_tm = dq8
         3 updt_dt_tm_ind = i2
         3 updt_task = i4
         3 updt_task_ind = i2
         3 updt_id = f8
         3 updt_cnt = i4
         3 updt_cnt_ind = i2
         3 updt_applctx = i4
         3 updt_applctx_ind = i2
       2 string_result[*]
         3 ensure_type = i2
         3 string_result_text = vc
         3 string_result_format_cd = f8
         3 equation_id = f8
         3 last_norm_dt_tm = dq8
         3 last_norm_dt_tm_ind = i2
         3 unit_of_measure_cd = f8
         3 feasible_ind = i2
         3 feasible_ind_ind = i2
         3 inaccurate_ind = i2
         3 inaccurate_ind_ind = i2
         3 interp_comp_list[*]
           4 comp_idx = i4
           4 comp_idx_ind = i2
           4 comp_event_id = f8
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 blood_transfuse[*]
         3 transfuse_start_dt_tm = dq8
         3 transfuse_start_dt_tm_ind = i2
         3 transfuse_end_dt_tm = dq8
         3 transfuse_end_dt_tm_ind = i2
         3 transfuse_note = vc
         3 transfuse_route_cd = f8
         3 transfuse_site_cd = f8
         3 transfuse_pt_loc_cd = f8
         3 initial_volume = f8
         3 total_intake_volume = f8
         3 transfusion_rate = f8
         3 transfusion_unit_cd = f8
         3 transfusion_time_cd = f8
         3 event_id = f8
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
       2 apparatus[*]
         3 apparatus_type_cd = f8
         3 apparatus_serial_nbr = vc
         3 apparatus_size_cd = f8
         3 body_site_cd = f8
         3 insertion_pt_loc_cd = f8
         3 insertion_prsnl_id = f8
         3 removal_pt_loc_cd = f8
         3 removal_prsnl_id = f8
         3 assistant_list[*]
           4 assistant_type_cd = f8
           4 sequence_nbr = i4
           4 sequence_nbr_ind = i2
           4 assistant_prsnl_id = f8
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 product[*]
         3 product_id = f8
         3 product_nbr = vc
         3 product_cd = f8
         3 abo_cd = f8
         3 rh_cd = f8
         3 product_status_cd = f8
         3 product_antigen_list[*]
           4 prod_ant_seq_nbr = i4
           4 prod_ant_seq_nbr_ind = i2
           4 antigen_cd = f8
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 date_result[*]
         3 result_dt_tm = dq8
         3 result_dt_tm_ind = i2
         3 result_dt_tm_os = f8
         3 result_dt_tm_os_ind = i2
         3 date_type_flag = i2
         3 date_type_flag_ind = i2
         3 event_id = f8
         3 valid_until_dt_tm = dq8
         3 valid_until_dt_tm_ind = i2
         3 valid_from_dt_tm = dq8
         3 valid_from_dt_tm_ind = i2
         3 updt_dt_tm = dq8
         3 updt_dt_tm_ind = i2
         3 updt_task = i4
         3 updt_task_ind = i2
         3 updt_id = f8
         3 updt_cnt = i4
         3 updt_cnt_ind = i2
         3 updt_applctx = i4
         3 updt_applctx_ind = i2
       2 med_result_list[*]
         3 admin_note = vc
         3 admin_prov_id = f8
         3 admin_start_dt_tm = dq8
         3 admin_start_dt_tm_ind = i2
         3 admin_end_dt_tm = dq8
         3 admin_end_dt_tm_ind = i2
         3 admin_route_cd = f8
         3 admin_site_cd = f8
         3 admin_method_cd = f8
         3 admin_pt_loc_cd = f8
         3 initial_dosage = f8
         3 initial_dosage_ind = i2
         3 admin_dosage = f8
         3 admin_dosage_ind = i2
         3 dosage_unit_cd = f8
         3 initial_volume = f8
         3 initial_volume_ind = i2
         3 total_intake_volume = f8
         3 total_intake_volume_ind = i2
         3 diluent_type_cd = f8
         3 ph_dispense_id = f8
         3 infusion_rate = f8
         3 infusion_rate_ind = i2
         3 infusion_unit_cd = f8
         3 infusion_time_cd = f8
         3 medication_form_cd = f8
         3 reason_required_flag = i2
         3 reason_required_flag_ind = i2
         3 response_required_flag = i2
         3 response_required_flag_ind = i2
         3 admin_strength = i4
         3 admin_strength_ind = i2
         3 admin_strength_unit_cd = f8
         3 substance_lot_number = vc
         3 substance_exp_dt_tm = dq8
         3 substance_exp_dt_tm_ind = i2
         3 substance_manufacturer_cd = f8
         3 refusal_cd = f8
         3 system_entry_dt_tm = dq8
         3 system_entry_dt_tm_ind = i2
         3 iv_event_cd = f8
         3 event_id = f8
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
       2 event_note_list[*]
         3 note_type_cd = f8
         3 note_format_cd = f8
         3 entry_method_cd = f8
         3 note_prsnl_id = f8
         3 note_dt_tm = dq8
         3 note_dt_tm_ind = i2
         3 record_status_cd = f8
         3 compression_cd = f8
         3 checksum = i4
         3 checksum_ind = i2
         3 long_text_id = f8
         3 non_chartable_flag = i2
         3 importance_flag = i2
         3 long_blob = gvc
         3 ce_event_note_id = f8
         3 valid_from_dt_tm = dq8
         3 valid_from_dt_tm_ind = i2
         3 valid_until_dt_tm = dq8
         3 valid_until_dt_tm_ind = i2
         3 event_note_id = f8
         3 event_id = f8
         3 updt_dt_tm = dq8
         3 updt_dt_tm_ind = i2
         3 updt_task = i4
         3 updt_task_ind = i2
         3 updt_id = f8
         3 updt_cnt = i4
         3 updt_cnt_ind = i2
         3 updt_applctx = i4
         3 updt_applctx_ind = i2
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
       2 microbiology_list[*]
         3 ensure_type = i2
         3 micro_seq_nbr = i4
         3 micro_seq_nbr_ind = i2
         3 organism_cd = f8
         3 organism_occurrence_nbr = i4
         3 organism_occurrence_nbr_ind = i2
         3 organism_type_cd = f8
         3 observation_prsnl_id = f8
         3 biotype = vc
         3 probability = f8
         3 positive_ind = i2
         3 positive_ind_ind = i2
         3 susceptibility_list[*]
           4 ensure_type = i2
           4 micro_seq_nbr = i4
           4 micro_seq_nbr_ind = i2
           4 suscep_seq_nbr = i4
           4 suscep_seq_nbr_ind = i2
           4 susceptibility_test_cd = f8
           4 detail_susceptibility_cd = f8
           4 panel_antibiotic_cd = f8
           4 antibiotic_cd = f8
           4 diluent_volume = f8
           4 diluent_volume_ind = i2
           4 result_cd = f8
           4 result_text_value = vc
           4 result_numeric_value = f8
           4 result_numeric_value_ind = i2
           4 result_unit_cd = f8
           4 result_dt_tm = dq8
           4 result_dt_tm_ind = i2
           4 result_prsnl_id = f8
           4 susceptibility_status_cd = f8
           4 abnormal_flag = i2
           4 abnormal_flag_ind = i2
           4 chartable_flag = i2
           4 chartable_flag_ind = i2
           4 nomenclature_id = f8
           4 antibiotic_note = vc
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 coded_result_list[*]
         3 ensure_type = i2
         3 sequence_nbr = i4
         3 sequence_nbr_ind = i2
         3 nomenclature_id = f8
         3 acr_code_str = vc
         3 proc_code_str = vc
         3 pathology_str = vc
         3 result_set = i4
         3 result_set_ind = i2
         3 result_cd = f8
         3 group_nbr = i4
         3 group_nbr_ind = i2
         3 mnemonic = vc
         3 short_string = vc
         3 descriptor = vc
         3 unit_of_measure_cd = f8
         3 event_id = f8
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
       2 linked_result_list[*]
         3 ensure_type = i2
         3 linked_event_id = f8
         3 order_id = f8
         3 encntr_id = f8
         3 accession_nbr = vc
         3 contributor_system_cd = f8
         3 reference_nbr = vc
         3 event_class_cd = f8
         3 series_ref_nbr = vc
         3 sub_series_ref_nbr = vc
         3 succession_type_cd = f8
         3 event_id = f8
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
       2 event_modifier_list[*]
         3 modifier_cd = f8
         3 modifier_value_cd = f8
         3 modifier_val_ft = vc
         3 event_id = f8
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
       2 suscep_footnote_r_list[*]
         3 ensure_type = i2
         3 micro_seq_nbr = i4
         3 micro_seq_nbr_ind = i2
         3 suscep_seq_nbr = i4
         3 suscep_seq_nbr_ind = i2
         3 suscep_footnote_id = f8
         3 suscep_footnote[*]
           4 event_id = f8
           4 ce_suscep_footnote_id = f8
           4 suscep_footnote_id = f8
           4 checksum = i4
           4 checksum_ind = i2
           4 compression_cd = f8
           4 format_cd = f8
           4 contributor_system_cd = f8
           4 blob_length = i4
           4 blob_length_ind = i2
           4 reference_nbr = vc
           4 long_blob = gvc
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 inventory_result_list[*]
         3 ensure_type = i2
         3 item_id = f8
         3 serial_nbr = vc
         3 serial_mnemonic = vc
         3 description = vc
         3 item_nbr = vc
         3 quantity = f8
         3 quantity_ind = i2
         3 body_site = vc
         3 reference_entity_id = f8
         3 reference_entity_name = vc
         3 implant_result[*]
           4 ensure_type = i2
           4 item_id = f8
           4 item_size = vc
           4 harvest_site = vc
           4 culture_ind = i2
           4 culture_ind_ind = i2
           4 tissue_graft_type_cd = f8
           4 explant_reason_cd = f8
           4 explant_disposition_cd = f8
           4 reference_entity_id = f8
           4 reference_entity_name = vc
           4 manufacturer_cd = f8
           4 manufacturer_ft = vc
           4 model_nbr = vc
           4 lot_nbr = vc
           4 other_identifier = vc
           4 expiration_dt_tm = dq8
           4 expiration_dt_tm_ind = i2
           4 ecri_code = vc
           4 batch_nbr = vc
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 inv_time_result_list[*]
           4 ensure_type = i2
           4 item_id = f8
           4 start_dt_tm = dq8
           4 start_dt_tm_ind = i2
           4 end_dt_tm = dq8
           4 end_dt_tm_ind = i2
           4 event_id = f8
           4 valid_from_dt_tm = dq8
           4 valid_from_dt_tm_ind = i2
           4 valid_until_dt_tm = dq8
           4 valid_until_dt_tm_ind = i2
           4 updt_dt_tm = dq8
           4 updt_dt_tm_ind = i2
           4 updt_task = i4
           4 updt_task_ind = i2
           4 updt_id = f8
           4 updt_cnt = i4
           4 updt_cnt_ind = i2
           4 updt_applctx = i4
           4 updt_applctx_ind = i2
         3 event_id = f8
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
       2 script_list[*]
         3 event_req_flag = i2
         3 event_rep_flag = i2
         3 script_name = vc
         3 location = vc
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
       2 ce_dynamic_label_id = f8
       2 event_end_tz = i4
     1 ensure_type2 = i2
   ) WITH protect
   FREE RECORD cereply
   RECORD cereply(
     1 sb
       2 severitycd = i4
       2 statuscd = i4
       2 statustext = vc
     1 rb_list[*]
       2 event_id = f8
       2 valid_from_dt_tm = dq8
       2 event_cd = f8
       2 result_status_cd = f8
       2 contributor_system_cd = f8
       2 reference_nbr = vc
       2 collating_seq = vc
       2 parent_event_id = f8
       2 prsnl_list[*]
         3 event_prsnl_id = f8
         3 action_prsnl_id = f8
         3 action_type_cd = f8
         3 action_dt_tm = dq8
         3 action_dt_tm_ind = i2
     1 script_reply_list[*]
   ) WITH protect
   SET cerequest->ensure_type = 2
   SET cerequest->clin_event.result_status_cd = c_in_error_cd
   SET cerequest->clin_event.event_id =  $2
   SELECT INTO "NL:"
    FROM clinical_event ce
    PLAN (ce
     WHERE (ce.event_id=cerequest->clin_event.event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime(now)
      AND ce.valid_from_dt_tm <= cnvtdatetime(now))
    ORDER BY ce.valid_from_dt_tm DESC
    HEAD ce.event_id
     cerequest->clin_event.view_level = ce.view_level, cerequest->clin_event.person_id = ce.person_id,
     cerequest->clin_event.encntr_id = ce.encntr_id,
     cerequest->clin_event.contributor_system_cd = ce.contributor_system_cd, cerequest->clin_event.
     parent_event_id = ce.parent_event_id, cerequest->clin_event.event_class_cd = ce.event_class_cd,
     cerequest->clin_event.event_reltn_cd = ce.event_reltn_cd, cerequest->clin_event.event_cd = ce
     .event_cd, cerequest->clin_event.event_end_dt_tm = ce.event_end_dt_tm,
     cerequest->clin_event.record_status_cd = ce.record_status_cd, cerequest->clin_event.
     authentic_flag = ce.authentic_flag, cerequest->clin_event.publish_flag = ce.publish_flag,
     cerequest->clin_event.valid_until_dt_tm = ce.valid_until_dt_tm, cerequest->clin_event.
     valid_from_dt_tm = ce.valid_from_dt_tm, cerequest->clin_event.performed_dt_tm = ce
     .performed_dt_tm,
     cerequest->clin_event.event_end_tz = ce.event_end_tz
    WITH nocounter, time = 30
   ;end select
   SET error_comment = formaterrorcomment(null)
   IF (textlen(error_comment) > 0)
    SET stat = alterlist(cerequest->clin_event.event_note_list,1)
    SET cerequest->clin_event.event_note_list[1].note_type_cd = c_res_comment_cd
    SET cerequest->clin_event.event_note_list[1].note_format_cd = c_ah_cd
    SET cerequest->clin_event.event_note_list[1].entry_method_cd = c_cerner_cd
    SET cerequest->clin_event.event_note_list[1].note_prsnl_id =  $3
    SET cerequest->clin_event.event_note_list[1].note_dt_tm = cnvtdatetime( $4)
    SET cerequest->clin_event.event_note_list[1].record_status_cd = c_active_cd
    SET cerequest->clin_event.event_note_list[1].long_blob = error_comment
    SET cerequest->clin_event.event_note_list[1].event_id = cerequest->clin_event.event_id
   ENDIF
   SET stat = alterlist(cerequest->clin_event.event_prsnl_list,1)
   SET cerequest->clin_event.event_prsnl_list[1].person_id = cerequest->clin_event.person_id
   SET cerequest->clin_event.event_prsnl_list[1].event_id = cerequest->clin_event.event_id
   SET cerequest->clin_event.event_prsnl_list[1].action_type_cd = c_modify_cd
   SET cerequest->clin_event.event_prsnl_list[1].request_dt_tm_ind = 1
   SET cerequest->clin_event.event_prsnl_list[1].action_prsnl_id =  $3
   SET cerequest->clin_event.event_prsnl_list[1].action_dt_tm = cnvtdatetime( $4)
   SET cerequest->clin_event.event_prsnl_list[1].action_status_cd = c_completed_cd
   SET cerequest->clin_event.event_prsnl_list[1].defeat_succn_ind = 1
   SET cerequest->clin_event.event_prsnl_list[1].valid_from_dt_tm_ind = 1
   SET cerequest->clin_event.event_prsnl_list[1].valid_until_dt_tm_ind = 1
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",cerequest,
    "REC",cereply,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(cereply)
   IF ((cereply->sb.statustext != "F"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
