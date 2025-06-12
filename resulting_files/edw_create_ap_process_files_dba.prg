CREATE PROGRAM edw_create_ap_process_files:dba
 SELECT INTO value(ap_process_extractfile)
  FROM (dummyt d  WITH seq = cur_list_size)
  WHERE (process->qual[d.seq].ap_process_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].ap_process_sk,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].ap_block_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].ap_specimen_sk,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].ap_slide_sk,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].ap_case_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].comment_long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].no_charge_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].priority_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,process->qual[d.seq].request_dt_tm,0,
      cnvtdatetimeutc(process->qual[d.seq].request_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"
     ))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].request_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(process->qual[d.seq].request_dt_tm,cnvtint(process->qual[d
      .seq].request_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].request_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].research_account_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].task_svc_res_dept_hier_sk,16))), v_bar,
   CALL print(trim(replace(process->qual[d.seq].slide_label,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].status_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,process->qual[d.seq].status_dt_tm,0,
      cnvtdatetimeutc(process->qual[d.seq].status_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss")
    )), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].status_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(process->qual[d.seq].status_dt_tm,cnvtint(process->qual[d
      .seq].status_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].status_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].task_assay_sk,16))), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].process_ordbl,16))),
   v_bar,
   CALL print(build(process->qual[d.seq].worklist_nbr)), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].cancel_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,process->qual[d.seq].cancel_dt_tm,0,
      cnvtdatetimeutc(process->qual[d.seq].cancel_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss")
    )),
   v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].cancel_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(process->qual[d.seq].cancel_dt_tm,cnvtint(process->qual[d
      .seq].cancel_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(process->qual[d.seq].cancel_prsnl,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, "1",
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 09/10/18 SB026554"
END GO
