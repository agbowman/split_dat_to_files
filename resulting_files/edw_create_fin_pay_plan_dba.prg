CREATE PROGRAM edw_create_fin_pay_plan:dba
 SELECT INTO value(fin_pay_plan_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].pft_encntr_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].pft_pay_plan_pe_reltn_id,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pay_plan->qual[d.seq].ending_encntr_dt_tm,
      0,cnvtdatetimeutc(edw_pay_plan->qual[d.seq].ending_encntr_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].ending_encntr_tz))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pay_plan->qual[d.seq].ending_encntr_dt_tm,cnvtint(
      edw_pay_plan->qual[d.seq].ending_encntr_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].ending_encntr_status_cd,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].orig_encntr_bal,11,2))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pay_plan->qual[d.seq].orig_encntr_dt_tm,0,
      cnvtdatetimeutc(edw_pay_plan->qual[d.seq].orig_encntr_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].orig_encntr_tz))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pay_plan->qual[d.seq].orig_encntr_dt_tm,cnvtint(
      edw_pay_plan->qual[d.seq].orig_encntr_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].pft_payment_plan_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].guarantor_person_sk,16))), v_bar,
   CALL print(trim(edw_pay_plan->qual[d.seq].resp_party_table_name)),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].resp_party_table_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].billing_entity_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pay_plan->qual[d.seq].
      cur_period_start_dt_tm,0,cnvtdatetimeutc(edw_pay_plan->qual[d.seq].cur_period_start_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].cur_period_start_tz))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pay_plan->qual[d.seq].cur_period_start_dt_tm,cnvtint(
      edw_pay_plan->qual[d.seq].cur_period_start_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].current_plan_status_cd,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].cycle_length,16))), v_bar,
   CALL print(trim(edw_pay_plan->qual[d.seq].due_day)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pay_plan->qual[d.seq].duration_plan_dt_tm,
      0,cnvtdatetimeutc(edw_pay_plan->qual[d.seq].duration_plan_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].duration_plan_tz))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pay_plan->qual[d.seq].duration_plan_dt_tm,cnvtint(
      edw_pay_plan->qual[d.seq].duration_plan_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pay_plan->qual[d.seq].ending_plan_dt_tm,0,
      cnvtdatetimeutc(edw_pay_plan->qual[d.seq].ending_plan_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].ending_plan_tz))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pay_plan->qual[d.seq].ending_plan_dt_tm,cnvtint(
      edw_pay_plan->qual[d.seq].ending_plan_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pay_plan->qual[d.seq].begin_plan_dt_tm,0,
      cnvtdatetimeutc(edw_pay_plan->qual[d.seq].begin_plan_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].begin_plan_tz))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pay_plan->qual[d.seq].begin_plan_dt_tm,cnvtint(
      edw_pay_plan->qual[d.seq].begin_plan_tz),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].installment_amount,11,2))),
   v_bar,
   CALL print(trim(edw_pay_plan->qual[d.seq].number_of_payments)), v_bar,
   CALL print(trim(cnvtstring(edw_pay_plan->qual[d.seq].total_amount_due,11,2))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print("1"), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 05/23/16 mf025696"
END GO
