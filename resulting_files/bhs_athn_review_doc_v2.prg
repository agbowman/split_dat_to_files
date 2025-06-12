CREATE PROGRAM bhs_athn_review_doc_v2
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
   1 r_event_prsnl_id = f8
   1 r_ce_event_prsnl_id = f8
   1 r_prsnl_id = f8
   1 a_prsnl_id = f8
   1 r_dt_tm = dq8
   1 task_id = f8
 )
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 DECLARE requested_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"REQUESTED"))
 DECLARE review_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"REVIEW"))
 DECLARE endorsements_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"ENDORSEMENTS"))
 DECLARE reviewresult_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6027,"REVIEWRESULT"))
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
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE (cep.event_id= $2))
  DETAIL
   IF (cep.action_type_cd=review_cd
    AND cep.action_status_cd=requested_cd
    AND (cep.action_prsnl_id= $3))
    t_record->event_id = cep.event_id, t_record->a_prsnl_id = cep.action_prsnl_id, t_record->
    r_prsnl_id = cep.request_prsnl_id,
    t_record->r_ce_event_prsnl_id = cep.ce_event_prsnl_id, t_record->r_event_prsnl_id = cep
    .event_prsnl_id, t_record->r_dt_tm = cep.request_dt_tm
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE (ta.event_id=t_record->event_id)
    AND ta.task_type_cd=endorsements_cd
    AND ta.task_activity_cd=reviewresult_cd
    AND ta.active_ind=1)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id=t_record->a_prsnl_id)
    AND taa.task_status_cd IN (t_pending_cd, opened_cd)
    AND  NOT (taa.task_status_cd IN (complete_cd)))
  HEAD ta.task_id
   t_record->task_id = ta.task_id
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
   arequest->lst[1].updt_applctx = reqinfo->updt_applctx, arequest->lst[1].updt_task = cep.updt_task,
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
 CALL echojson(treply, $1)
END GO
