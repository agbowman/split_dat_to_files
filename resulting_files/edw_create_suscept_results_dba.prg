CREATE PROGRAM edw_create_suscept_results:dba
 SELECT INTO value(suscept_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   suscept_cntr = (suscept_cntr+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(suscept_rslt->qual[d.seq].micro_task_sk,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(suscept_rslt->qual[d.seq].suscept_results_sk,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].detail_test_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].panel_ref,16))), v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].procedure_status_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].antibiotic_medication_ref,16))), v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].result_status_ref,16))), v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].result_type_flg)),
   v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].interpretation_result_ref,16))), v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].alpha_numeric_result_ref,16))), v_bar,
   CALL print(trim(cnvtstring(build(suscept_rslt->qual[d.seq].numeric_result),16))),
   v_bar,
   CALL print(trim(replace(suscept_rslt->qual[d.seq].result_txt,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].result_unit_ref,16))), v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].abnormal_response_ind)),
   v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].chartable_ind)), v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].panel_complete_required_ind)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,suscept_rslt->qual[d.seq].performed_dt_tm,0,
      cnvtdatetimeutc(suscept_rslt->qual[d.seq].performed_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].performed_tm_zn)), v_bar,
   CALL print(evaluate(datetimezoneformat(suscept_rslt->qual[d.seq].performed_dt_tm,cnvtint(
      suscept_rslt->qual[d.seq].performed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,suscept_rslt->qual[d.seq].verified_dt_tm,0,
      cnvtdatetimeutc(suscept_rslt->qual[d.seq].verified_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].verified_tm_zn)), v_bar,
   CALL print(evaluate(datetimezoneformat(suscept_rslt->qual[d.seq].verified_dt_tm,cnvtint(
      suscept_rslt->qual[d.seq].verified_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,suscept_rslt->qual[d.seq].canceled_dt_tm,0,
      cnvtdatetimeutc(suscept_rslt->qual[d.seq].canceled_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].canceled_tm_zn)), v_bar,
   CALL print(evaluate(datetimezoneformat(suscept_rslt->qual[d.seq].canceled_dt_tm,cnvtint(
      suscept_rslt->qual[d.seq].canceled_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,suscept_rslt->qual[d.seq].pending_dt_tm,0,
      cnvtdatetimeutc(suscept_rslt->qual[d.seq].pending_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].pending_tm_zn)), v_bar,
   CALL print(evaluate(datetimezoneformat(suscept_rslt->qual[d.seq].pending_dt_tm,cnvtint(
      suscept_rslt->qual[d.seq].pending_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,suscept_rslt->qual[d.seq].corrected_dt_tm,0,
      cnvtdatetimeutc(suscept_rslt->qual[d.seq].corrected_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(build(suscept_rslt->qual[d.seq].corrected_tm_zn)), v_bar,
   CALL print(evaluate(datetimezoneformat(suscept_rslt->qual[d.seq].corrected_dt_tm,cnvtint(
      suscept_rslt->qual[d.seq].corrected_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(suscept_rslt->qual[d.seq].event_sk,16))),
   v_bar, "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar, "1",
   v_bar, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 CALL echo(build("SUSCEPTIBILITY RESULTS Count :",suscept_cntr))
 SET script_version = "005 05/05/17 mf025696"
 IF (error(err_msg,1)=0)
  SET error_ind = 0
 ENDIF
END GO
