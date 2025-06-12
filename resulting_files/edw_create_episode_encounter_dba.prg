CREATE PROGRAM edw_create_episode_encounter:dba
 SELECT INTO value(ep_enc_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(ep_enc->qual[d.seq].encounter_nk,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_encntr_reltn_id,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ep_enc->qual[d.seq].episode_start_dt_tm,0,
      cnvtdatetimeutc(ep_enc->qual[d.seq].episode_start_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_start_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_start_tm_vld_flg))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ep_enc->qual[d.seq].episode_end_dt_tm,0,
      cnvtdatetimeutc(ep_enc->qual[d.seq].episode_end_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"
     ))),
   v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_end_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_end_tm_vld_flg))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ep_enc->qual[d.seq].create_dt_tm,0,
      cnvtdatetimeutc(ep_enc->qual[d.seq].create_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].create_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].create_tm_vld_flg))), v_bar,
   CALL print(trim(replace(ep_enc->qual[d.seq].episode_name,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_type_ref))), v_bar,
   CALL print(ep_enc->qual[d.seq].active_ind), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].refer_facility_cd))), v_bar,
   CALL print(trim(cnvtstring(ep_enc->qual[d.seq].episode_sk,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 30-SEP-2013 SB026554"
END GO
