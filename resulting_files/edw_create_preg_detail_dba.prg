CREATE PROGRAM edw_create_preg_detail:dba
 SELECT INTO value(pregnancy_detail_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].pregnancy_detail_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].pregnancy_estimate_sk,16))), v_bar,
   CALL print(trim(edw_preg_detail->qual[d.seq].lmp_symptoms_txt)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_preg_detail->qual[d.seq].
      pregnancy_test_dt_tm,0,cnvtdatetimeutc(edw_preg_detail->qual[d.seq].pregnancy_test_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].time_zone))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_preg_detail->qual[d.seq].pregnancy_test_dt_tm,cnvtint(
      edw_preg_detail->qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].contraception_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].contraception_duration,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].breastfeeding_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].menarche_age,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].menstrual_freq,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_preg_detail->qual[d.seq].
      prior_menses_dt_tm,0,cnvtdatetimeutc(edw_preg_detail->qual[d.seq].prior_menses_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_detail->qual[d.seq].time_zone))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_preg_detail->qual[d.seq].prior_menses_dt_tm,cnvtint(
      edw_preg_detail->qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(edw_preg_detail->qual[d.seq].src_active_ind)), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
