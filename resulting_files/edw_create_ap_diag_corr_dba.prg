CREATE PROGRAM edw_create_ap_diag_corr:dba
 SELECT INTO value(ap_diag_extractfile)
  FROM (dummyt d  WITH seq = size(edw_ap_diag_corr->qual,5))
  WHERE (edw_ap_diag_corr->qual[d.seq].ap_diag_corr_sk > 0)
  DETAIL
   irecordcnt = (irecordcnt+ 1), col 0, health_system_id,
   v_bar, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].ap_diag_corr_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].ap_case_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].event_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_ap_diag_corr->qual[d.seq].initiated_dt_tm,
      0,cnvtdatetimeutc(edw_ap_diag_corr->qual[d.seq].initiated_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].initiated_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_ap_diag_corr->qual[d.seq].initiated_dt_tm,cnvtint(
      edw_ap_diag_corr->qual[d.seq].initiated_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].initiated_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_ap_diag_corr->qual[d.seq].completed_dt_tm,
      0,cnvtdatetimeutc(edw_ap_diag_corr->qual[d.seq].completed_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].completed_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_ap_diag_corr->qual[d.seq].completed_dt_tm,cnvtint(
      edw_ap_diag_corr->qual[d.seq].completed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].completed_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].correlated_case_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].disagree_reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].investigation_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].study_comment_long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].slides_reviewed_cnt,16))), v_bar,
   CALL print(trim(replace(edw_ap_diag_corr->qual[d.seq].study_description,str_find,str_replace,3),3)
   ),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].initial_discrepancy_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].final_discrepancy_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].init_eval_reason_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_ap_diag_corr->qual[d.seq].init_eval_description,str_find,str_replace,3
     ),3)), v_bar,
   CALL print(trim(replace(edw_ap_diag_corr->qual[d.seq].init_eval_display,str_find,str_replace,3),3)
   ), v_bar,
   CALL print(trim(edw_ap_diag_corr->qual[d.seq].init_eval_investigatn_req_flg,3)),
   v_bar,
   CALL print(trim(edw_ap_diag_corr->qual[d.seq].init_eval_reason_req_flg,3)), v_bar,
   CALL print(trim(edw_ap_diag_corr->qual[d.seq].init_eval_resolution_req_flg,3)), v_bar,
   CALL print(trim(cnvtstring(edw_ap_diag_corr->qual[d.seq].final_eval_reason_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_ap_diag_corr->qual[d.seq].final_eval_description,str_find,str_replace,
     3),3)), v_bar,
   CALL print(trim(replace(edw_ap_diag_corr->qual[d.seq].final_eval_display,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(edw_ap_diag_corr->qual[d.seq].final_eval_investigatn_req_flg,3)),
   v_bar,
   CALL print(trim(edw_ap_diag_corr->qual[d.seq].final_eval_reason_req_flg,3)), v_bar,
   CALL print(trim(edw_ap_diag_corr->qual[d.seq].final_eval_resolution_req_flg,3)), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   "1", v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 04/29/2020 ss077455"
END GO
