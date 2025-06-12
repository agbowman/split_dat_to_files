CREATE PROGRAM edw_create_rad_exam_files:dba
 CALL echo(build("cur_list_size:",cur_list_size))
 SELECT INTO value(rad_exam_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].rad_exam_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].rad_order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].task_assay_sk,16))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].svc_res_dept_hier_sk,16))),
   v_bar,
   CALL print(trim(replace(rad_exam_info->qual[d.seq].exam_desc,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].exam_seq,16))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].exam_primary_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_exam_info->qual[d.seq].sched_req_dt_tm,0,
      cnvtdatetimeutc(rad_exam_info->qual[d.seq].sched_req_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].sched_req_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_exam_info->qual[d.seq].sched_req_dt_tm,cnvtint(
      rad_exam_info->qual[d.seq].sched_req_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_exam_info->qual[d.seq].starting_dt_tm,0,
      cnvtdatetimeutc(rad_exam_info->qual[d.seq].starting_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].starting_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_exam_info->qual[d.seq].starting_dt_tm,cnvtint(
      rad_exam_info->qual[d.seq].starting_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,rad_exam_info->qual[d.seq].complete_dt_tm,0,
      cnvtdatetimeutc(rad_exam_info->qual[d.seq].complete_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].complete_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(rad_exam_info->qual[d.seq].complete_dt_tm,cnvtint(
      rad_exam_info->qual[d.seq].complete_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(rad_exam_info->qual[d.seq].required_ind)), v_bar,
   CALL print(build(rad_exam_info->qual[d.seq].quantity)), v_bar,
   CALL print(trim(rad_exam_info->qual[d.seq].credit_ind)),
   v_bar,
   CALL print(trim(rad_exam_info->qual[d.seq].charges_sent_ind)), v_bar,
   "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)),
   v_bar, "1", v_bar,
   CALL print(trim(cnvtstring(rad_exam_info->qual[d.seq].src_updt_prsnl,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 01/06/16 SB026554"
END GO
