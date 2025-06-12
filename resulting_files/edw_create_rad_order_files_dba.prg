CREATE PROGRAM edw_create_rad_order_files:dba
 SELECT INTO value(rad_order_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].rad_order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].accession_add_on_ind,16))), v_bar,
   CALL print(trim(replace(rad_order_info->qual[d.seq].comment_txt,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].
      exam_completed_dt_tm,0,cnvtdatetimeutc(rad_order_info->qual[d.seq].exam_completed_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].exam_completed_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].exam_completed_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].exam_completed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].exam_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].group_event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].order_loc,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].packet_routing_ref,16))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].parent_order_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].
      pull_list_request_dt_tm,0,cnvtdatetimeutc(rad_order_info->qual[d.seq].pull_list_request_dt_tm,3
       )),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].pull_list_request_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].pull_list_request_dt_tm,cnvtint
     (rad_order_info->qual[d.seq].pull_list_request_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].
      pull_list_print_dt_tm,0,cnvtdatetimeutc(rad_order_info->qual[d.seq].pull_list_print_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].pull_list_print_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].pull_list_print_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].pull_list_print_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(replace(rad_order_info->qual[d.seq].reason_for_exam,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].removed_by_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].removed_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].removed_dt_tm,0,
      cnvtdatetimeutc(rad_order_info->qual[d.seq].removed_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].removed_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].removed_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].removed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].replaced_order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].report_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].restored_ind))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].exam_start_dt_tm,
      0,cnvtdatetimeutc(rad_order_info->qual[d.seq].exam_start_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].exam_start_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].exam_start_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].exam_start_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].vetting_dt_tm,0,
      cnvtdatetimeutc(rad_order_info->qual[d.seq].vetting_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].vetting_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].vetting_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].vetting_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].vetting_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].vetting_status_flg,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].request_dt_tm,0,
      cnvtdatetimeutc(rad_order_info->qual[d.seq].request_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].request_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].request_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].request_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_order_info->qual[d.seq].cancelled_dt_tm,0,
      cnvtdatetimeutc(rad_order_info->qual[d.seq].cancelled_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(rad_order_info->qual[d.seq].cancelled_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(rad_order_info->qual[d.seq].cancelled_dt_tm,cnvtint(
      rad_order_info->qual[d.seq].cancelled_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)),
   v_bar, "1", v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "004 05/07/20 BS074648"
END GO
