CREATE PROGRAM edw_create_fin_collection:dba
 SELECT INTO value(fin_collect_extractfile)
  FROM (dummyt d  WITH seq = cur_list_size)
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].pft_encntr_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].pft_encntr_collection_r_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].collection_state_cd,16))), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].coll_percentage,16,2))),
   v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].current_balance,11,2))), v_bar,
   CALL print(build(edw_collection->qual[d.seq].curr_bal_dr_cr_flag)), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].orig_write_off_bal,11,2))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_collection->qual[d.seq].
      orig_write_off_dt_tm,0,cnvtdatetimeutc(edw_collection->qual[d.seq].orig_write_off_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(build(edw_collection->qual[d.seq].orig_write_off_tz)), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_collection->qual[d.seq].orig_write_off_dt_tm,cnvtint(
      edw_collection->qual[d.seq].orig_write_off_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].pre_collect_agency_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].collect_agency_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].return_balance,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_collection->qual[d.seq].return_dt_tm,0,
      cnvtdatetimeutc(edw_collection->qual[d.seq].return_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(build(edw_collection->qual[d.seq].return_tz)), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_collection->qual[d.seq].return_dt_tm,cnvtint(
      edw_collection->qual[d.seq].return_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].send_back_reason_cd,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_collection->qual[d.seq].send_dt_tm,0,
      cnvtdatetimeutc(edw_collection->qual[d.seq].send_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(build(edw_collection->qual[d.seq].send_tz)),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_collection->qual[d.seq].send_dt_tm,cnvtint(
      edw_collection->qual[d.seq].send_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].total_adj_amt,11,2))), v_bar,
   CALL print(build(edw_collection->qual[d.seq].total_adj_dr_cr_flag)),
   v_bar,
   CALL print(trim(cnvtstring(edw_collection->qual[d.seq].total_payment_amt,11,2))), v_bar,
   CALL print(build(edw_collection->qual[d.seq].total_pay_dr_cr_flag)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_collection->qual[d.seq].
      beg_effective_dt_tm,0,cnvtdatetimeutc(edw_collection->qual[d.seq].beg_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(edw_collection->qual[d.seq].beg_effective_tz)), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_collection->qual[d.seq].beg_effective_dt_tm,cnvtint(
      edw_collection->qual[d.seq].beg_effective_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_collection->qual[d.seq].
      end_effective_dt_tm,0,cnvtdatetimeutc(edw_collection->qual[d.seq].end_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(edw_collection->qual[d.seq].end_effective_tz)), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_collection->qual[d.seq].end_effective_dt_tm,cnvtint(
      edw_collection->qual[d.seq].end_effective_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print("1"), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 05/23/16 mf025696"
END GO
