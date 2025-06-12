CREATE PROGRAM bhs_athn_add_wkf_text_v1
 RECORD wrequest(
   1 patient_id = f8
   1 encntr_id = f8
   1 prsnl_id = f8
 )
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 dataset_uid = vc
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 event_id_list[*]
     2 event_id = f8
   1 action_type_cd_list[*]
     2 action_type_cd = f8
   1 src_event_id_ind = i2
   1 action_prsnl_group_id = f8
   1 query_mode2 = i4
   1 event_uuid = vc
 )
 RECORD prequest(
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
     2 result_set_link_list[*]
       3 ensure_type = i2
       3 event_id = f8
       3 result_set_id = f8
       3 entry_type_cd = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 replacement_event_id = f8
       3 result_set_group = f8
       3 relation_type_cd = f8
 )
 RECORD event_rep(
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist[*]
       3 substatuscd = i4
   1 rb_list[*]
     2 event_id = f8
     2 valid_from_dt_tm = dq8
     2 event_cd = f8
     2 result_status_cd = f8
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 collating_seq = vc
     2 parent_event_id = f8
     2 result_set_link_list[*]
       3 result_set_id = f8
       3 entry_type_cd = f8
       3 updt_cnt = i4
 )
 RECORD erequest(
   1 wkf_workflow_id = f8
   1 service_dt_tm = dq8
   1 service_tz = i4
   1 end_dt_tm = dq8
   1 component[*]
     2 wkf_component_id = f8
     2 component_concept = vc
     2 component_entity_name = c32
     2 component_entity_id = f8
     2 component_reference_number = vc
   1 output[*]
     2 wkf_output_id = f8
     2 output_type_cd = f8
     2 output_entity_name = c32
     2 output_entity_id = f8
     2 output_reference_number = vc
 )
 RECORD e_request(
   1 blob = vc
   1 url_source_ind = i2
 )
 RECORD e_reply(
   1 blob = vc
 )
 RECORD t_request(
   1 param = vc
 )
 RECORD t_reply(
   1 param = vc
 )
 RECORD out_rec(
   1 event_id = vc
   1 workflow_id = vc
   1 ce_blob = vc
 )
 DECLARE ros_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"REVIEWOFSYSTEMSDOCUMENTATION"))
 DECLARE pe_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PHYSICALEXAMINATIONDOCUMENTATION")
  )
 DECLARE hpi_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYOFPRESENTILLNESSDOCUMENTATION"))
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE inprogress_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"INPROGRESS"))
 DECLARE modify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"MODIFY"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 DECLARE txt_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"TXT"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE r_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",24,"R"))
 DECLARE routclinical_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",87,"ROUTCLINICAL"))
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM"))
 DECLARE xhtml_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",23,"XHTML"))
 DECLARE blob_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",25,"BLOB"))
 DECLARE final_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",63,"FINAL"))
 DECLARE ocfcompression_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",120,"OCFCOMPRESSION"))
 DECLARE workflowdocumentationcomponent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,
   "WORKFLOWDOCUMENTATIONCOMPONENT"))
 DECLARE narrative_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002218,"NARRATIVE"))
 DECLARE historyofpresentillness_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",255431,
   "HISTORYOFPRESENTILLNESS"))
 DECLARE physicalexam_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",255431,"PHYSICALEXAM"))
 DECLARE reviewofsystems_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",255431,"REVIEWOFSYSTEMS")
  )
 DECLARE workflow_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",255431,"WORKFLOW"))
 DECLARE person_id = f8
 DECLARE event_cd = f8
 DECLARE workflow_id = f8
 DECLARE exists_ind = i2
 DECLARE event_id = f8
 DECLARE html_string = vc
 DECLARE guid_string = vc
 DECLARE t_line = vc
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 IF (( $4="ROS"))
  SET event_cd = ros_cd
 ELSEIF (( $4="PE"))
  SET event_cd = pe_cd
 ELSEIF (( $4="HPI"))
  SET event_cd = hpi_cd
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 SET wrequest->patient_id = person_id
 SET wrequest->encntr_id =  $2
 SET wrequest->prsnl_id =  $3
 SET stat = tdbexecute(600005,3202004,969575,"REC",wrequest,
  "REC",wreply)
 SET workflow_id = wreply->workflow_id
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_result_set_link crsl,
   wkf_component wc,
   wkf_workflow ww
  PLAN (ce
   WHERE (ce.encntr_id= $2)
    AND (ce.updt_id= $3)
    AND ce.event_cd=event_cd
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (crsl
   WHERE crsl.event_id=ce.event_id
    AND crsl.valid_until_dt_tm > sysdate)
   JOIN (wc
   WHERE wc.component_entity_id=crsl.result_set_id)
   JOIN (ww
   WHERE ww.wkf_workflow_id=wc.wkf_workflow_id
    AND (ww.prsnl_id= $3)
    AND ww.service_dt_tm = null)
  HEAD REPORT
   exists_ind = 1, event_id = ce.event_id
  WITH nocounter, time = 30
 ;end select
 SET e_request->blob =  $6
 SET e_request->url_source_ind = 1
 EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
 IF (exists_ind=1)
  SET orequest->event_id = event_id
  SET orequest->query_mode = 1
  SET orequest->valid_from_dt_tm_ind = 1
  SET orequest->decode_flag = 1
  SET orequest->subtable_bit_map_ind = 1
  SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
   "REC",oreply)
  SET t_line = oreply->rb_list[1].blob_result[1].blob[1].blob_contents
  SET pos = findstring('top-right" id="_',t_line)
  SET guid_string = substring((pos+ 15),37,t_line)
  SET html_string = concat(
   '<!DOCTYPE html PUBLIC "-// W3C//DTD XHTML 1.0 Strict// EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
   '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:dd="DynamicDocumentation"><head><title></title></head><body>',
   '<div class="ddfreetext ddremovable" contenteditable="true" dd:btnfloatingstyle="top-right" ',
   'id="',guid_string,
   '">',e_reply->blob,"</div></body></html>")
  SET t_request->param = html_string
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST",t_request), replace("REPLY",t_reply)
  SET html_string = replace(t_reply->param,"Â "," ")
  SET prequest->ensure_type = 2
  SET prequest->clin_event[1].event_id = event_id
  SET prequest->clin_event[1].view_level = 1
  SET prequest->clin_event[1].publish_flag = 1
  SET prequest->clin_event[1].record_status_cd = active_cd
  SET prequest->clin_event[1].result_status_cd = inprogress_cd
  SET stat = alterlist(prequest->clin_event[1].result_set_link_list,1)
  SET prequest->clin_event[1].result_set_link_list[1].result_set_id = oreply->rb_list[1].
  result_set_link_list[1].result_set_id
  SET prequest->clin_event[1].result_set_link_list[1].entry_type_cd = workflow_cd
  SET stat = alterlist(prequest->clin_event[1].blob_result,1)
  SET prequest->clin_event[1].blob_result[1].event_id = event_id
  SET stat = alterlist(prequest->clin_event[1].blob_result[1].blob,1)
  SET prequest->clin_event[1].blob_result[1].blob[1].blob_contents = html_string
  SET stat = alterlist(prequest->clin_event[1].event_prsnl_list,1)
  SET prequest->clin_event[1].event_prsnl_list[1].event_id = event_id
  SET prequest->clin_event[1].event_prsnl_list[1].action_prsnl_id =  $3
  SET prequest->clin_event[1].event_prsnl_list[1].action_type_cd = modify_cd
  SET prequest->clin_event[1].event_prsnl_list[1].action_dt_tm = sysdate
  SET prequest->clin_event[1].event_prsnl_list[1].action_status_cd = completed_cd
  SET stat = tdbexecute(3200000,3202004,1000012,"REC",prequest,
   "REC",preply)
  SET erequest->wkf_workflow_id = workflow_id
  FOR (i = 1 TO size(wreply->workflow_components,5))
    IF ((wreply->workflow_components[i].component_concept= $4))
     SET stat = alterlist(erequest->component,1)
     SET erequest->component[1].wkf_component_id = wreply->workflow_components[i].
     workflow_component_id
     SET erequest->component[1].component_concept =  $4
     SET erequest->component[1].component_entity_id = wreply->workflow_components[i].
     component_entity_id
     SET erequest->component[1].component_entity_name = wreply->workflow_components[i].
     component_entity_name
    ENDIF
  ENDFOR
  SET event_rep->sb[1].statuscd = 0
  SET event_rep->sb[1].severitycd = 0
  SET stat = alterlist(event_rep->sb[1].substatuslist,1)
  SET event_rep->sb[1].substatuslist[1].substatuscd = 0
  SET stat = alterlist(event_rep->rb_list,1)
  SET event_rep->rb_list[1].event_id = preply->rb_list[1].event_id
  SET event_rep->rb_list[1].reference_nbr = preply->rb_list[1].reference_nbr
  SET stat = alterlist(event_rep->rb_list[1].result_set_link_list,1)
  SET event_rep->rb_list[1].result_set_link_list[1].result_set_id = oreply->rb_list[1].
  result_set_link_list[1].result_set_id
  EXECUTE doc_ens_workflow  WITH replace("REQUEST",erequest)
 ENDIF
 IF (exists_ind=0)
  SET html_string = concat(
   '<!DOCTYPE html PUBLIC "-// W3C//DTD XHTML 1.0 Strict// EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
   '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:dd="DynamicDocumentation"><head><title></title></head><body>',
   '<div class="ddfreetext ddremovable" contenteditable="true" dd:btnfloatingstyle="top-right" ',
   'id="_', $5,
   '">',e_reply->blob,"</div></body></html>")
  SET t_request->param = html_string
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST",t_request), replace("REPLY",t_reply)
  SET html_string = t_reply->param
  SET prequest->ensure_type = 2
  SET prequest->clin_event[1].person_id = person_id
  SET prequest->clin_event[1].encntr_id =  $2
  SET prequest->clin_event[1].clinsig_updt_dt_tm = cnvtdatetime(curdate,curtime3)
  SET prequest->clin_event[1].event_cd = event_cd
  SET prequest->clin_event[1].event_class_cd = txt_cd
  SET prequest->clin_event[1].view_level = 1
  SET prequest->clin_event[1].contributor_system_cd = powerchart_cd
  SET prequest->clin_event[1].event_reltn_cd = r_cd
  SET prequest->clin_event[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
  SET prequest->clin_event[1].event_tag = "In Progress"
  SET prequest->clin_event[1].event_end_dt_tm = cnvtdatetime(curdate,curtime3)
  SET prequest->clin_event[1].record_status_cd = active_cd
  SET prequest->clin_event[1].result_status_cd = inprogress_cd
  SET prequest->clin_event[1].authentic_flag = 1
  SET prequest->clin_event[1].publish_flag = 1
  SET prequest->clin_event[1].inquire_security_cd = routclinical_cd
  SET prequest->clin_event[1].subtable_bit_map = 1073742593
  SET prequest->clin_event[1].updt_dt_tm = cnvtdatetime(curdate,curtime3)
  SET prequest->clin_event[1].updt_dt_tm_ind = 1
  SET prequest->clin_event[1].updt_cnt = 1
  SET prequest->clin_event[1].updt_task = 3202004
  SET prequest->clin_event[1].updt_task_ind = 1
  SET prequest->clin_event[1].entry_mode_cd = workflowdocumentationcomponent_cd
  SET stat = alterlist(prequest->clin_event[1].blob_result,1)
  SET prequest->clin_event[1].blob_result[1].storage_cd = blob_cd
  SET prequest->clin_event[1].blob_result[1].format_cd = xhtml_cd
  SET prequest->clin_event[1].blob_result[1].succession_type_cd = final_cd
  SET prequest->clin_event[1].blob_result[1].valid_from_dt_tm = sysdate
  SET stat = alterlist(prequest->clin_event[1].blob_result[1].blob,1)
  SET prequest->clin_event[1].blob_result[1].blob[1].blob_contents = html_string
  SET prequest->clin_event[1].blob_result[1].blob[1].blob_length = textlen(html_string)
  SET prequest->clin_event[1].blob_result[1].blob[1].compression_cd = ocfcompression_cd
  SET stat = alterlist(prequest->clin_event[1].result_set_link_list,1)
  IF (( $4="ROS"))
   SET prequest->clin_event[1].result_set_link_list[1].entry_type_cd = reviewofsystems_cd
  ELSEIF (( $4="PE"))
   SET prequest->clin_event[1].result_set_link_list[1].entry_type_cd = physicalexam_cd
  ELSEIF (( $4="HPI"))
   SET prequest->clin_event[1].result_set_link_list[1].entry_type_cd = historyofpresentillness_cd
  ENDIF
  SET prequest->clin_event[1].result_set_link_list[1].relation_type_cd = narrative_cd
  SET prequest->clin_event[1].result_set_link_list[1].valid_from_dt_tm = cnvtdatetime(curdate,
   curtime3)
  SET stat = alterlist(prequest->clin_event[1].event_prsnl_list,1)
  SET prequest->clin_event[1].event_prsnl_list[1].action_prsnl_id =  $3
  SET prequest->clin_event[1].event_prsnl_list[1].action_type_cd = perform_cd
  SET prequest->clin_event[1].event_prsnl_list[1].action_dt_tm = sysdate
  SET prequest->clin_event[1].event_prsnl_list[1].action_status_cd = completed_cd
  SET stat = tdbexecute(3200000,3202004,1000012,"REC",prequest,
   "REC",preply)
  SET event_id = preply->rb_list[1].event_id
  SET erequest->wkf_workflow_id = workflow_id
  SET stat = alterlist(erequest->component,1)
  IF (( $4="ROS"))
   SET erequest->component[1].component_concept = "ROS"
  ELSEIF (( $4="PE"))
   SET erequest->component[1].component_concept = "PE"
  ELSEIF (( $4="HPI"))
   SET erequest->component[1].component_concept = "HPI"
  ENDIF
  SET erequest->component[1].component_entity_name = "CE_RESULT_SET_LINK"
  SET erequest->component[1].component_entity_id = preply->rb_list[1].result_set_link_list[1].
  result_set_id
  SET event_rep->sb[1].statuscd = 0
  SET event_rep->sb[1].severitycd = 0
  SET stat = alterlist(event_rep->sb[1].substatuslist,1)
  SET event_rep->sb[1].substatuslist[1].substatuscd = 0
  SET stat = alterlist(event_rep->rb_list,1)
  SET event_rep->rb_list[1].event_id = preply->rb_list[1].event_id
  SET event_rep->rb_list[1].reference_nbr = preply->rb_list[1].reference_nbr
  SET stat = alterlist(event_rep->rb_list[1].result_set_link_list,1)
  SET event_rep->rb_list[1].result_set_link_list[1].result_set_id = preply->rb_list[1].
  result_set_link_list[1].result_set_id
  EXECUTE doc_ens_workflow  WITH replace("REQUEST",erequest)
 ENDIF
 SET out_rec->event_id = cnvtstring(event_id)
 SET out_rec->workflow_id = cnvtstring(workflow_id)
 SET out_rec->ce_blob = html_string
 CALL echojson(out_rec, $1)
END GO
