CREATE PROGRAM bhs_athn_sign_forwared_doc_v2
 RECORD arequest(
   1 lst[*]
     2 ce_event_prsnl_id = f8
     2 event_id = f8
     2 valid_until_dt_tm_ind = i2
     2 valid_until_dt_tm = dq8
     2 event_prsnl_id = f8
     2 person_id = f8
     2 valid_from_dt_tm_ind = i2
     2 valid_from_dt_tm = f8
     2 action_type_cd = f8
     2 request_dt_tm_ind = i2
     2 request_dt_tm = f8
     2 request_tz = i4
     2 request_prsnl_id = f8
     2 request_prsnl_ft = c100
     2 request_comment = c255
     2 action_dt_tm_ind = i2
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 action_prsnl_id = f8
     2 action_prsnl_ft = c100
     2 proxy_prsnl_id = f8
     2 proxy_prsnl_ft = c100
     2 action_status_cd = f8
     2 action_comment = c255
     2 change_since_action_flag_ind = i2
     2 change_since_action_flag = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
     2 long_text_id = f8
     2 linked_event_id = f8
     2 system_comment = c255
     2 digital_signature_ident = c60
     2 action_prsnl_group_id = f8
     2 request_prsnl_group_id = f8
     2 receiving_person_id = f8
     2 receiving_person_ft = c100
 )
 RECORD areply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = c132
 )
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
 )
 FREE RECORD oreply
 RECORD oreply(
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
     2 prsnl_list[*]
       3 event_prsnl_id = f8
       3 action_prsnl_id = f8
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_tz = i4
       3 updt_cnt = i4
     2 clinical_event_id = f8
     2 updt_cnt = i4
     2 result_set_link_list[*]
       3 result_set_id = f8
       3 entry_type_cd = f8
       3 updt_cnt = i4
     2 ce_dynamic_label_id = f8
     2 clinsig_updt_dt_tm = dq8
     2 ce_grouping_id = f8
   1 result_group_list[*]
     2 result_group_id = f8
 )
 RECORD trequest(
   1 task_list[*]
     2 task_id = f8
     2 event_id = f8
     2 event_cd = f8
     2 task_status_cd = f8
     2 task_status_meaning = vc
     2 task_dt_tm = dq8
     2 task_updt_cnt = i4
     2 stat_ind = i2
     2 comments = c255
     2 msg_text = gvc
     2 contributor_system_cd = f8
     2 external_reference_nbr = vc
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_updt_cnt = i4
       3 msg_text = gvc
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
       3 proxy_prsnl_id = f8
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_updt_cnt = i4
       3 msg_text = gvc
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
     2 assign_prsnl_group_list[*]
       3 assign_prsnl_group_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_updt_cnt = i4
       3 msg_text = gvc
       3 assign_prsnl_id = f8
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
     2 scheduled_dt_tm = dq8
     2 remind_dt_tm = dq8
     2 sub_activity_list[*]
       3 order_proposal_id = f8
     2 encntr_id = f8
 )
 RECORD t_record(
   1 event_id = f8
   1 child_event_id = f8
   1 r_event_prsnl_id = f8
   1 r_ce_event_prsnl_id = f8
   1 p_event_prsnl_id = f8
   1 p_ce_event_prsnl_id = f8
   1 r_prsnl_id = f8
   1 a_prsnl_id = f8
   1 r_dt_tm = dq8
   1 task_id = f8
   1 applctx = f8
 )
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE authverified_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 DECLARE requested_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"REQUESTED"))
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"PENDING"))
 DECLARE verify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"VERIFY"))
 DECLARE endorsements_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"ENDORSEMENTS"))
 DECLARE signresult_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6027,"SIGNRESULT"))
 DECLARE t_pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"COMPLETE"))
 DECLARE opened_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 FREE RECORD srequest
 RECORD srequest(
   1 param = vc
 )
 FREE RECORD sreply
 RECORD sreply(
   1 param = vc
 )
 DECLARE comment_text = vc WITH noconstant(trim( $4,3))
 IF (textlen(comment_text) > 0)
  SET srequest->param = comment_text
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","SREQUEST"), replace("REPLY","SREPLY")
  SET comment_text = sreply->param
 ENDIF
 DECLARE event_id = f8
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.event_id= $2))
  HEAD REPORT
   event_id = ce.event_id
  WITH nocounter, time = 30
 ;end select
 IF (event_id=0)
  SET oreply->sb.statustext = "Invalid Event ID"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.parent_event_id= $2)
    AND (ce.event_id !=  $2))
  DETAIL
   t_record->child_event_id = ce.event_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE (cep.event_id= $2)
    AND cep.valid_until_dt_tm > sysdate)
  DETAIL
   IF (cep.action_type_cd=sign_cd
    AND cep.action_status_cd=requested_cd
    AND (cep.action_prsnl_id= $3))
    t_record->event_id = cep.event_id, t_record->a_prsnl_id = cep.action_prsnl_id, t_record->
    r_prsnl_id = cep.request_prsnl_id,
    t_record->r_ce_event_prsnl_id = cep.ce_event_prsnl_id, t_record->r_event_prsnl_id = cep
    .event_prsnl_id, t_record->r_dt_tm = cep.request_dt_tm
   ENDIF
   IF (cep.action_type_cd=sign_cd
    AND cep.action_status_cd=pending_cd)
    t_record->p_ce_event_prsnl_id = cep.ce_event_prsnl_id, t_record->p_event_prsnl_id = cep
    .event_prsnl_id
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.event_id=t_record->event_id)
    AND ta.task_type_cd=endorsements_cd
    AND ta.task_activity_cd=signresult_cd
    AND ta.active_ind=1)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id=t_record->a_prsnl_id)
    AND taa.task_status_cd IN (t_pending_cd, opened_cd))
  HEAD ta.task_id
   t_record->task_id = ta.task_id
  WITH nocounter, time = 30
 ;end select
 SET orequest->ensure_type = 2
 SET orequest->clin_event[1].event_id = t_record->event_id
 SET orequest->clin_event[1].view_level = 1
 SET orequest->clin_event[1].publish_flag = 1
 SET orequest->clin_event[1].record_status_cd = active_cd
 SET orequest->clin_event[1].result_status_cd = authverified_cd
 IF ((t_record->p_ce_event_prsnl_id > 0))
  SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,2)
  SET orequest->clin_event[1].event_prsnl_list[1].event_id = t_record->event_id
  SET orequest->clin_event[1].event_prsnl_list[1].event_prsnl_id = t_record->p_event_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[1].ce_event_prsnl_id = t_record->p_ce_event_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[1].action_status_cd = requested_cd
  SET orequest->clin_event[1].event_prsnl_list[1].request_prsnl_id = t_record->r_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[1].request_dt_tm = sysdate
  SET orequest->clin_event[1].event_prsnl_list[1].updt_id = t_record->a_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[2].event_id = t_record->event_id
  SET orequest->clin_event[1].event_prsnl_list[2].action_prsnl_id = t_record->a_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[2].action_type_cd = verify_cd
  SET orequest->clin_event[1].event_prsnl_list[2].action_dt_tm = sysdate
  SET orequest->clin_event[1].event_prsnl_list[2].action_status_cd = completed_cd
  SET orequest->clin_event[1].event_prsnl_list[2].updt_id = t_record->a_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[2].request_prsnl_id = t_record->r_prsnl_id
 ENDIF
 IF ((t_record->p_ce_event_prsnl_id=0))
  SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,1)
  SET orequest->clin_event[1].event_prsnl_list[1].event_id = t_record->event_id
  SET orequest->clin_event[1].event_prsnl_list[1].action_prsnl_id = t_record->a_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[1].action_type_cd = verify_cd
  SET orequest->clin_event[1].event_prsnl_list[1].action_dt_tm = sysdate
  SET orequest->clin_event[1].event_prsnl_list[1].action_status_cd = completed_cd
  SET orequest->clin_event[1].event_prsnl_list[1].updt_id = t_record->a_prsnl_id
  SET orequest->clin_event[1].event_prsnl_list[1].request_prsnl_id = t_record->r_prsnl_id
 ENDIF
 SET stat = tdbexecute(3200000,3200000,1000012,"REC",orequest,
  "REC",oreply)
 IF ((t_record->child_event_id > 0))
  FREE RECORD oreply
  SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,0)
  SET orequest->clin_event[1].event_id = t_record->child_event_id
  SET orequest->clin_event[1].view_level = 0
  SET orequest->clin_event[1].publish_flag = 1
  SET orequest->clin_event[1].record_status_cd = active_cd
  SET orequest->clin_event[1].result_status_cd = authverified_cd
  SET stat = tdbexecute(3200000,3200000,1000012,"REC",orequest,
   "REC",oreply)
 ENDIF
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE (cep.ce_event_prsnl_id=t_record->r_ce_event_prsnl_id))
  HEAD cep.ce_event_prsnl_id
   t_record->applctx = cep.updt_applctx
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(arequest->lst,1)
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE (cep.ce_event_prsnl_id=t_record->r_ce_event_prsnl_id)
    AND cep.valid_until_dt_tm > sysdate)
  HEAD cep.ce_event_prsnl_id
   arequest->lst[1].ce_event_prsnl_id = cep.ce_event_prsnl_id, arequest->lst[1].event_id = cep
   .event_id, arequest->lst[1].valid_until_dt_tm_ind = 0,
   arequest->lst[1].valid_until_dt_tm = cep.valid_until_dt_tm, arequest->lst[1].event_prsnl_id = cep
   .event_prsnl_id, arequest->lst[1].person_id = cep.person_id,
   arequest->lst[1].valid_from_dt_tm_ind = 0, arequest->lst[1].valid_from_dt_tm = sysdate, arequest->
   lst[1].action_type_cd = cep.action_type_cd,
   arequest->lst[1].request_dt_tm_ind = 0, arequest->lst[1].request_dt_tm = cep.request_dt_tm,
   arequest->lst[1].request_tz = cep.request_tz,
   arequest->lst[1].request_prsnl_id = cep.request_prsnl_id, arequest->lst[1].request_prsnl_ft = cep
   .request_prsnl_ft, arequest->lst[1].request_comment = cep.request_comment,
   arequest->lst[1].action_dt_tm_ind = 0, arequest->lst[1].action_dt_tm = sysdate, arequest->lst[1].
   action_tz = cep.request_tz,
   arequest->lst[1].action_prsnl_id = cep.action_prsnl_id, arequest->lst[1].action_prsnl_ft = cep
   .action_prsnl_ft, arequest->lst[1].proxy_prsnl_id = cep.proxy_prsnl_id,
   arequest->lst[1].proxy_prsnl_ft = cep.proxy_prsnl_ft, arequest->lst[1].action_status_cd =
   completed_cd, arequest->lst[1].action_comment = trim(comment_text,3),
   arequest->lst[1].change_since_action_flag_ind = 1, arequest->lst[1].change_since_action_flag = 0,
   arequest->lst[1].updt_dt_tm = sysdate,
   arequest->lst[1].updt_task = cep.updt_task, arequest->lst[1].updt_id = cep.action_prsnl_id,
   arequest->lst[1].updt_cnt = (cep.updt_cnt+ 1),
   arequest->lst[1].updt_applctx = t_record->applctx, arequest->lst[1].updt_task = cep.updt_task,
   arequest->lst[1].long_text_id = cep.long_text_id,
   arequest->lst[1].linked_event_id = cep.linked_event_id, arequest->lst[1].system_comment = cep
   .system_comment, arequest->lst[1].digital_signature_ident = cep.digital_signature_ident,
   arequest->lst[1].action_prsnl_group_id = cep.action_prsnl_group_id, arequest->lst[1].
   request_prsnl_group_id = cep.request_prsnl_group_id, arequest->lst[1].receiving_person_id = cep
   .receiving_person_id,
   arequest->lst[1].receiving_person_ft = cep.receiving_person_ft
  WITH nocounter
 ;end select
 EXECUTE ce_event_prsnl_upd  WITH replace("REQUEST","AREQUEST"), replace("REPLY","AREPLY")
 COMMIT
 SET stat = alterlist(trequest->task_list,1)
 SET trequest->task_list[1].task_id = t_record->task_id
 SET stat = alterlist(trequest->task_list.assign_prsnl_list,1)
 SET trequest->task_list[1].assign_prsnl_list[1].assign_prsnl_id = t_record->a_prsnl_id
 SET trequest->task_list[1].assign_prsnl_list[1].task_status_cd = complete_cd
 SET trequest->task_list[1].assign_prsnl_list[1].task_status_meaning = "COMPLETE"
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.task_id=t_record->task_id))
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id=t_record->a_prsnl_id))
  DETAIL
   trequest->task_list[1].task_updt_cnt = ta.updt_cnt, trequest->task_list[1].assign_prsnl_list[1].
   assign_updt_cnt = taa.updt_cnt
  WITH nocounter, time = 30
 ;end select
 SET stat = tdbexecute(600005,3202004,967142,"REC",trequest,
  "REC",treply)
#end_script
#end_prog
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(oreply)
 ELSE
  CALL echojson(oreply, $1)
 ENDIF
END GO
