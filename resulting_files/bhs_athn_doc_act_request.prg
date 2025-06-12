CREATE PROGRAM bhs_athn_doc_act_request
 RECORD orequest(
   1 req[*]
     2 ensure_type = i2
     2 version_dt_tm = dq8
     2 version_dt_tm_ind = i2
     2 event_prsnl
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
       3 event_action_modifier_list[*]
         4 ce_event_action_modifier_id = f8
         4 event_action_modifier_id = f8
         4 event_id = f8
         4 event_prsnl_id = f8
         4 action_type_modifier_cd = f8
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
       3 ensure_type = i2
       3 digital_signature_ident = vc
       3 action_prsnl_group_id = f8
       3 request_prsnl_group_id = f8
       3 receiving_person_id = f8
       3 receiving_person_ft = vc
     2 ensure_type2 = i2
     2 clinsig_updt_dt_tm_flag = i2
     2 clinsig_updt_dt_tm = dq8
     2 clinsig_updt_dt_tm_ind = i2
   1 message_item
     2 message_text = vc
     2 subject = vc
     2 confidentiality = i2
     2 priority = i2
     2 due_date = dq8
     2 sender_id = f8
   1 user_id = f8
   1 result_set_links[*]
     2 ensure_type = i2
     2 event_id = f8
     2 result_set_id = f8
     2 entry_type_cd = f8
     2 relation_type_cd = f8
 )
 RECORD t_record(
   1 prsnl_cnt = i4
   1 prsnl_qual[*]
     2 prsnl_id = f8
 )
 DECLARE date_line = vc
 DECLARE time_line = vc
 DECLARE action_type = f8 WITH protect, constant(uar_get_code_by("display_key",21, $5))
 DECLARE action_status = f8 WITH protect, constant(uar_get_code_by("display_key",103,"REQUESTED"))
 DECLARE forward_cd = f8 WITH constant(uar_get_code_by("display_key",254550,"FORWARD"))
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $3
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->prsnl_cnt += 1
    SET stat = alterlist(t_record->prsnl_qual,t_record->prsnl_cnt)
    SET t_record->prsnl_qual[t_record->prsnl_cnt].prsnl_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET t_record->prsnl_cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->prsnl_qual,t_record->prsnl_cnt)
    SET t_record->prsnl_qual[t_record->prsnl_cnt].prsnl_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
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
 SET i_request->prsnl_id =  $4
 IF ((i_request->prsnl_id > 0))
  CALL echorecord(i_request)
  EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
  IF ((i_reply->status_data.status != "S"))
   CALL echo("impersonate user failed...exiting!")
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(orequest->req,t_record->prsnl_cnt)
 FOR (i = 1 TO t_record->prsnl_cnt)
   SET orequest->req[i].ensure_type = 2
   SET orequest->req[i].event_prsnl.event_id =  $2
   SET orequest->req[i].event_prsnl.action_prsnl_id = t_record->prsnl_qual[i].prsnl_id
   SET orequest->req[i].event_prsnl.request_prsnl_id =  $4
   SET orequest->req[i].event_prsnl.action_type_cd = action_type
   SET orequest->req[i].event_prsnl.action_status_cd = action_status
   SET date_line = substring(1,10, $7)
   SET time_line = substring(12,8, $7)
   SET orequest->req[i].event_prsnl.request_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,
    "HH;mm;ss",0)
   SET orequest->req[i].event_prsnl.request_comment =  $8
   SET stat = alterlist(orequest->req[i].event_prsnl.event_action_modifier_list,1)
   SET orequest->req[i].event_prsnl.event_action_modifier_list[1].event_id =  $2
   SET orequest->req[i].event_prsnl.event_action_modifier_list[1].action_type_modifier_cd =
   forward_cd
 ENDFOR
 SET orequest->user_id =  $4
 SET orequest->message_item.sender_id =  $4
 SET orequest->message_item.subject =  $9
 SET orequest->message_item.message_text =  $10
 SET orequest->message_item.confidentiality =  $11
 SET orequest->message_item.priority =  $12
 IF (textlen( $13) > 1)
  SET date_line = substring(1,10, $13)
  SET time_line = substring(12,8, $13)
  SET orequest->message_item.due_date = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",
   0)
 ENDIF
 SET stat = tdbexecute(600005,3200210,1000056,"REC",orequest,
  "REC",oreply)
 SET _memory_reply_string = cnvtrectojson(oreply)
END GO
