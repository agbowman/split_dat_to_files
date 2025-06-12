CREATE PROGRAM edw_create_episode_activity:dba
 SELECT INTO value(ep_act_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].episode_activity_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].episode_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].epi_enc_reltn_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ep_activity_info->qual[d.seq].activity_dt_tm,
      0,cnvtdatetimeutc(ep_activity_info->qual[d.seq].activity_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(ep_activity_info->qual[d.seq].activity_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].activity_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].activity_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].episode_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].episode_pause_days_cnt,16))),
   v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].created_by_encntr_sk,16))), v_bar,
   CALL print(concat(trim(cnvtstring(ep_activity_info->qual[d.seq].created_by_encntr_sk,16)),trim(
     health_system_source_id))), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].created_by_schedule_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].created_by_ce_event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].updt_sk,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(ep_activity_info->qual[d.seq].active_ind,16))), row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 35000, maxrow = 1,
   append
 ;end select
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 04/05/2012 NZ016913"
END GO
