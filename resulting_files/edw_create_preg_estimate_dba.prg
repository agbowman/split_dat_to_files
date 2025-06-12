CREATE PROGRAM edw_create_preg_estimate:dba
 SELECT INTO value(pregnancy_estimate_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].pregnancy_estimate_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].pregnancy_inst_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].prev_preg_estimate_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].status_flg,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].method_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].descriptor_ref,16))), v_bar,
   CALL print(trim(edw_preg_estimate->qual[d.seq].descriptor_txt)),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].descriptor_flg,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].edd_long_text_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_preg_estimate->qual[d.seq].method_dt_tm,0,
      cnvtdatetimeutc(edw_preg_estimate->qual[d.seq].method_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].time_zone))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_preg_estimate->qual[d.seq].method_dt_tm,cnvtint(
      edw_preg_estimate->qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].crown_rump_length,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].biparietal_diameter,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].head_circumference,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].est_gest_age_days,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_preg_estimate->qual[d.seq].
      est_delivery_dt_tm,0,cnvtdatetimeutc(edw_preg_estimate->qual[d.seq].est_delivery_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].time_zone))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_preg_estimate->qual[d.seq].est_delivery_dt_tm,cnvtint(
      edw_preg_estimate->qual[d.seq].est_delivery_dt_tm),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].confirmation_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].author_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_preg_estimate->qual[d.seq].entered_dt_tm,
      0,cnvtdatetimeutc(edw_preg_estimate->qual[d.seq].entered_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_preg_estimate->qual[d.seq].time_zone))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_preg_estimate->qual[d.seq].entered_dt_tm,cnvtint(
      edw_preg_estimate->qual[d.seq].entered_dt_tm),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(edw_preg_estimate->qual[d.seq].src_active_ind)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
