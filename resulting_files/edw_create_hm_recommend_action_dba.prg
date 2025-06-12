CREATE PROGRAM edw_create_hm_recommend_action:dba
 SELECT INTO value(hm_recac_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].hm_recommend_action_inst_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].hm_recommend_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].hm_expect_sat_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].related_hm_recommend_action_sk,16)
    )),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].on_behalf_of_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      action_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].action_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].action_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].action_flag,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      due_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].due_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].due_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      expire_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].expire_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].expire_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      qualified_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].qualified_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].qualified_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].long_text_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].frequency_val,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].frequency_unit_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_hm_recommend_action->qual[d.seq].expectation_ftdesc,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      satisfaction_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].satisfaction_dt_tm,3)
      ),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].satisfaction_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].satisfaction_sk,16))), v_bar,
   CALL print(trim(replace(edw_hm_recommend_action->qual[d.seq].satisfaction_source,str_find,
     str_replace,3))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      prev_due_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].prev_due_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].prev_due_dt_tm,cnvtint
     (default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      prev_expire_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].prev_expire_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].prev_expire_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_hm_recommend_action->qual[d.seq].
      prev_qualified_dt_tm,0,cnvtdatetimeutc(edw_hm_recommend_action->qual[d.seq].
       prev_qualified_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_hm_recommend_action->qual[d.seq].prev_qualified_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].prev_frequency_val,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_recommend_action->qual[d.seq].prev_frequency_unit_ref,16))),
   v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
