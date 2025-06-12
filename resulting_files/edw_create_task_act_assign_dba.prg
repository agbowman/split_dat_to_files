CREATE PROGRAM edw_create_task_act_assign:dba
 CALL echo(build("cur list size=",cur_list_size))
 SELECT INTO value(tskactas_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].task_activity_assign_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].task_activity_sk,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].assign_person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].assign_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_assign_info->qual[d.seq].
      beg_effective_dt_tm,0,cnvtdatetimeutc(task_activity_assign_info->qual[d.seq].
       beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_assign_info->qual[d.seq].beg_effective_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_assign_info->qual[d.seq].
      end_effective_dt_tm,0,cnvtdatetimeutc(task_activity_assign_info->qual[d.seq].
       end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_assign_info->qual[d.seq].end_effective_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].contributor_system_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].copy_type_flg,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].event_prsnl,16))),
   v_bar,
   CALL print(trim(replace(task_activity_assign_info->qual[d.seq].external_reference_number,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].proxy_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].rejection_ind,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_assign_info->qual[d.seq].
      remind_dt_tm,0,cnvtdatetimeutc(task_activity_assign_info->qual[d.seq].remind_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_assign_info->qual[d.seq].remind_dt_tm,cnvtint
     (default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].reply_allowed_ind,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,task_activity_assign_info->qual[d.seq].
      scheduled_dt_tm,0,cnvtdatetimeutc(task_activity_assign_info->qual[d.seq].scheduled_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(task_activity_assign_info->qual[d.seq].scheduled_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].task_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(task_activity_assign_info->qual[d.seq].active_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("TSKACTAS Count = ",curqual))
 CALL echo("Done with create")
 CALL edwupdatescriptstatus("TSKACTAS",curqual,"1","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 11/30/11 SM016593"
END GO
