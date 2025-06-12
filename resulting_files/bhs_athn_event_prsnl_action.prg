CREATE PROGRAM bhs_athn_event_prsnl_action
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
 RECORD oreply(
   1 status = vc
 )
 DECLARE date_line = vc
 DECLARE time_line = vc
 IF (( $5="REQUESTED"))
  SET oreply->status =
  "Request is not a valid action status for BHS_ATHN_EVENT_PRSNL_ACTION. Use BHS_ATHN_EVENT_PRSNL_ACT_REQ"
  GO TO exit_script
 ENDIF
 FREE RECORD oreply
 DECLARE action_type = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",21, $4))
 DECLARE action_status = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",103, $5))
 SET stat = alterlist(orequest->req,1)
 SET orequest->req[1].ensure_type = 2
 SET orequest->req[1].event_prsnl.event_id =  $2
 SET orequest->req[1].event_prsnl.action_prsnl_id =  $3
 SET orequest->req[1].event_prsnl.action_type_cd = action_type
 SET orequest->req[1].event_prsnl.action_status_cd = action_status
 SET date_line = substring(1,10, $6)
 SET time_line = substring(12,8, $6)
 SET orequest->req[1].event_prsnl.action_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,
  "HH;mm;ss",4)
 SET orequest->req[1].event_prsnl.request_prsnl_id =  $7
 IF (textlen( $8) > 1)
  SET date_line = substring(1,10, $8)
  SET time_line = substring(12,8, $8)
  SET orequest->req[1].event_prsnl.request_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,
   "HH;mm;ss",4)
 ENDIF
 SET orequest->req[1].event_prsnl.action_comment =  $9
 SET orequest->req[1].event_prsnl.proxy_prsnl_id =  $10
 SET stat = tdbexecute(3200000,3200210,1000056,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
