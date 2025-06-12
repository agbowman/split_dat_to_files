CREATE PROGRAM edw_create_bb_release:dba
 SELECT INTO value(bbrlse_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].bb_assign_release_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].product_event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].product_sk,16))), v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].release_type_flg,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_release_info->qual[d.seq].release_dt_tm,0,
      cnvtdatetimeutc(bb_release_info->qual[d.seq].release_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(bb_release_info->qual[d.seq].release_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].release_intl_units,16))), v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].release_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].release_qty,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].release_reason_ref,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(bb_release_info->qual[d.seq].active_ind,16))), v_bar,
   row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 35000, maxrow = 1,
   append
 ;end select
 CALL echo(build("BBRLSE Count = ",curqual))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 01/31/2012 SM016593"
END GO
