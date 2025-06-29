CREATE PROGRAM edw_create_task_activity:dba
 SELECT INTO value(tskact_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_activity_sk,16))),
   v_bar,
   CALL print(build(task_activity_info->qual[d.seq].encntr_nk)), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].encntr_sk,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].event_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].catalog_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].catalog_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].charted_by_agent_ref,16))), v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].charted_by_agent_ident,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].charting_context_reference,str_find,
     str_replace,3))),
   v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].comments,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].confidential_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].continuous_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].contributor_system_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].delivery_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].event_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].event_class_ref,16))), v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].external_reference_number,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].iv_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].linked_order_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].location_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].med_order_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].msg_sender_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].msg_sender_person_sk,16))), v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].msg_subject,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].msg_subject_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].email_message_ident,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].orig_pool_task_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].performed_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].
      performed_dt_tm,0,cnvtdatetimeutc(task_activity_info->qual[d.seq].performed_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_info->qual[d.seq].performed_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].physician_order_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].read_ind,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].remind_dt_tm,
      0,cnvtdatetimeutc(task_activity_info->qual[d.seq].remind_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_info->qual[d.seq].remind_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].reschedule_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].reschedule_reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].routine_ind,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].
      scheduled_dt_tm,0,cnvtdatetimeutc(task_activity_info->qual[d.seq].scheduled_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_info->qual[d.seq].scheduled_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].source_tag,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].stat_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].suggested_entity_sk,16))),
   v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].suggested_entity_name,str_find,str_replace,
     3))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_activity_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_activity_class_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_class_ref,16))), v_bar,
   CALL print(trim(replace(task_activity_info->qual[d.seq].task_desc,str_find,str_replace,3))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].
      task_create_dt_tm,0,cnvtdatetimeutc(task_activity_info->qual[d.seq].task_create_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_info->qual[d.seq].task_create_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].task_dt_tm,0,
      cnvtdatetimeutc(task_activity_info->qual[d.seq].task_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_info->qual[d.seq].task_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_priority_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_status_reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].template_task_flg,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].tpn_ind,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].updt_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].active_ind,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(task_activity_info->qual[d.seq].task_activity_tm_zn,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].
      active_status_dt_tm,0,cnvtdatetimeutc(task_activity_info->qual[d.seq].active_status_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_info->qual[d.seq].
      active_status_dt_tm,0,cnvtdatetimeutc(task_activity_info->qual[d.seq].active_status_dt_tm,2)),
     task_activity_info->qual[d.seq].task_activity_tm_zn,"MM/DD/YYYY HH:mm"))),
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("TSKACT Count = ",curqual))
 CALL edwupdatescriptstatus("TSKACT",curqual,"1","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "001 01/07/16 SB026554"
END GO
