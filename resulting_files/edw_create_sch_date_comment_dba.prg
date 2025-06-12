CREATE PROGRAM edw_create_sch_date_comment:dba
 SELECT INTO value(schdtcom_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].date_comment_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].parent_id,16))), v_bar,
   CALL print(trim(replace(edw_sch_date_comment->qual[d.seq].parent_table,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_sch_date_comment->qual[d.seq].
      action_dt_tm,0,cnvtdatetimeutc(edw_sch_date_comment->qual[d.seq].action_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_sch_date_comment->qual[d.seq].action_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","              ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].action_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_sch_date_comment->qual[d.seq].beg_dt_tm,0,
      cnvtdatetimeutc(edw_sch_date_comment->qual[d.seq].beg_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_sch_date_comment->qual[d.seq].beg_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","              ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_sch_date_comment->qual[d.seq].end_dt_tm,0,
      cnvtdatetimeutc(edw_sch_date_comment->qual[d.seq].end_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_sch_date_comment->qual[d.seq].end_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","              ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(replace(edw_sch_date_comment->qual[d.seq].mnemonic,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].orig_long_text_sk,16))), v_bar,
   CALL print(trim(replace(edw_sch_date_comment->qual[d.seq].apply_mnemonic,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].apply_text_type_ref,16))), v_bar,
   CALL print(trim(replace(edw_sch_date_comment->qual[d.seq].apply_days_of_wk,str_find,str_replace,3)
    )), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].sch_state_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].apply_long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].apply_sub_text_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].sch_state_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].sub_text_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_sch_date_comment->qual[d.seq].text_type_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_sch_date_comment->qual[d.seq].
      version_dt_tm,0,cnvtdatetimeutc(edw_sch_date_comment->qual[d.seq].version_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_sch_date_comment->qual[d.seq].version_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","              ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(trim(edw_sch_date_comment->qual[d.seq].active_ind)), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 SET script_version = "000 02/06/12 RP019504"
END GO
