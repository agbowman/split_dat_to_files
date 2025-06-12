CREATE PROGRAM edw_create_ap_report:dba
 SELECT INTO value(ap_rpt_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(ap_report->qual[d.seq].ap_rpt_section_sk)),
   v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].ap_case_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].section_type_task_assay_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_test_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_seq,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ap_report->qual[d.seq].order_dt_tm,0,
      cnvtdatetimeutc(ap_report->qual[d.seq].order_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"
     ))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].order_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(ap_report->qual[d.seq].order_dt_tm,cnvtint(ap_report->qual[
      d.seq].order_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].order_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].signing_loc,16))),
   v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_status_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ap_report->qual[d.seq].report_status_dt_tm,0,
      cnvtdatetimeutc(ap_report->qual[d.seq].report_status_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_status_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(ap_report->qual[d.seq].report_status_dt_tm,cnvtint(
      ap_report->qual[d.seq].report_status_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].report_status_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ap_report->qual[d.seq].synoptic_stale_dt_tm,0,
      cnvtdatetimeutc(ap_report->qual[d.seq].synoptic_stale_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].synoptic_stale_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(ap_report->qual[d.seq].synoptic_stale_dt_tm,cnvtint(
      ap_report->qual[d.seq].synoptic_stale_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].cancel_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ap_report->qual[d.seq].cancel_dt_tm,0,
      cnvtdatetimeutc(ap_report->qual[d.seq].cancel_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].cancel_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(ap_report->qual[d.seq].cancel_dt_tm,cnvtint(ap_report->
      qual[d.seq].cancel_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(ap_report->qual[d.seq].cancel_prsnl,16))), v_bar,
   CALL print(trim(replace(ap_report->qual[d.seq].report_text,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(ap_report->qual[d.seq].primary_report_flg)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, "1",
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 35000, maxrow = 1, append
 ;end select
 SET script_version = "002 05/22/19 mf025696"
END GO
