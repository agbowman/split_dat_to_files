CREATE PROGRAM edw_create_med_admin_evt_files
 SELECT INTO value(medadevt_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  PLAN (d
   WHERE cur_list_size > 0)
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].med_evt_key,16))),
   v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].med_key,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].med_admin_event_seq,16))),
   v_bar,
   CALL print(build(datetimezoneformat(evaluate(curutc,1,med_admin_evt->qual[d.seq].beg_dt_tm,0,
      cnvtdatetimeutc(med_admin_evt->qual[d.seq].beg_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm")
    )), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(med_admin_evt->qual[d.seq].beg_dt_tm,cnvtint(med_admin_evt
      ->qual[d.seq].beg_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(build(datetimezoneformat(evaluate(curutc,1,med_admin_evt->qual[d.seq].end_dt_tm,0,
      cnvtdatetimeutc(med_admin_evt->qual[d.seq].end_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm")
    )), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(med_admin_evt->qual[d.seq].end_dt_tm,cnvtint(med_admin_evt
      ->qual[d.seq].end_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].careaware_used_ind,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].clinical_warning_cnt,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].documentation_action_seq,16))),
   v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].event_cnt,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].event_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].needs_verify_flg,16))),
   v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].nurse_unit_ref,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].order_result_var_ind,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].position_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].positive_med_ident_ind,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].positive_patient_ident_ind,16))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].prsnl_sk,16))),
   v_bar,
   CALL print(build(datetimezoneformat(evaluate(curutc,1,med_admin_evt->qual[d.seq].sched_dt_tm,0,
      cnvtdatetimeutc(med_admin_evt->qual[d.seq].sched_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].sched_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(med_admin_evt->qual[d.seq].sched_dt_tm,cnvtint(
      med_admin_evt->qual[d.seq].sched_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].src_app_flg,16))), v_bar,
   CALL print(build(datetimezoneformat(evaluate(curutc,1,med_admin_evt->qual[d.seq].
      verification_dt_tm,0,cnvtdatetimeutc(med_admin_evt->qual[d.seq].verification_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].verification_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(med_admin_evt->qual[d.seq].verification_dt_tm,cnvtint(
      med_admin_evt->qual[d.seq].verification_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(med_admin_evt->qual[d.seq].verified_prsnl_sk,16))), v_bar, "1",
   v_bar, "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 SET script_version = "000 10/27/11 AO9323"
END GO
