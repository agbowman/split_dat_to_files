CREATE PROGRAM edw_create_fin_denial:dba
 SELECT INTO value(fin_denial_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].pft_encntr_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].denial_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].denial_reason_cd,16))), v_bar,
   CALL print(trim(replace(edw_denial->qual[d.seq].denial_txt,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_denial->qual[d.seq].beg_effective_dt_tm,0,
      cnvtdatetimeutc(edw_denial->qual[d.seq].beg_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].beg_effective_tz))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_denial->qual[d.seq].beg_effective_dt_tm,cnvtint(
      edw_denial->qual[d.seq].beg_effective_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(edw_denial->qual[d.seq].remark_code_attrib_value)), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].charge_item_id,16))), v_bar,
   CALL print(trim(edw_denial->qual[d.seq].claim_billed_amt)),
   v_bar,
   CALL print(trim(edw_denial->qual[d.seq].total_payment_amt)), v_bar,
   CALL print(trim(edw_denial->qual[d.seq].total_adjustment_amt)), v_bar,
   CALL print(trim(edw_denial->qual[d.seq].denial_billed_amt)),
   v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].created_prsnl_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].batch_trans_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].post_supervisor_person_id,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print("1"),
   v_bar,
   CALL print(trim(replace(edw_denial->qual[d.seq].denial_code_txt,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].corsp_activity_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].batch_trans_file_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].edi_adj_group_cd,16))), v_bar,
   CALL print(trim(cnvtstring(edw_denial->qual[d.seq].denial_type_cd,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "004 01/04/18 mf025696"
END GO
