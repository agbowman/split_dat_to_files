CREATE PROGRAM edw_create_rad_report_files:dba
 SELECT INTO value(rad_report_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].rad_report_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].rad_order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].classification_ref,16))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].report_creation_mthd_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].scd_story_sk,16))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].dictated_by_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].prev_owner_prsnl,16))),
   v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].rad_rpt_reference_nbr)), v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].no_proxy_ind)), v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].redictate_ind)),
   v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].modified_ind)), v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].res_queue_ind)), v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].addendum_ind)),
   v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].batch_sign_ind)), v_bar,
   CALL print(trim(rad_report_info->qual[d.seq].charges_sent_ind)), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].report_seq,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].org_trans_dt_tm,
      0,cnvtdatetimeutc(rad_report_info->qual[d.seq].org_trans_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].org_trans_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].org_trans_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].org_trans_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].final_dt_tm,0,
      cnvtdatetimeutc(rad_report_info->qual[d.seq].final_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].final_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].final_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].final_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].dictated_dt_tm,0,
      cnvtdatetimeutc(rad_report_info->qual[d.seq].dictated_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].dictated_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].dictated_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].dictated_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].
      posted_final_dt_tm,0,cnvtdatetimeutc(rad_report_info->qual[d.seq].posted_final_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].posted_final_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].posted_final_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].posted_final_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].ret_to_res_dt_tm,
      0,cnvtdatetimeutc(rad_report_info->qual[d.seq].ret_to_res_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].ret_to_res_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].ret_to_res_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].ret_to_res_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].
      voice_del_succ_dt_tm,0,cnvtdatetimeutc(rad_report_info->qual[d.seq].voice_del_succ_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].voice_del_succ_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].voice_del_succ_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].voice_del_succ_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_report_info->qual[d.seq].
      voice_del_atmt_dt_tm,0,cnvtdatetimeutc(rad_report_info->qual[d.seq].voice_del_atmt_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_report_info->qual[d.seq].voice_del_atmt_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_report_info->qual[d.seq].voice_del_atmt_dt_tm,cnvtint(
      rad_report_info->qual[d.seq].voice_del_atmt_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar, "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar, "1",
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "000 08/03/10 rp019504"
END GO
