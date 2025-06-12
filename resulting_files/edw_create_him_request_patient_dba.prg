CREATE PROGRAM edw_create_him_request_patient:dba
 SELECT INTO value(him_request_patient_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].him_request_patient_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].him_request_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].request_status_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_him_request_patient->qual[d.seq].
      request_status_dt_tm,0,cnvtdatetimeutc(edw_him_request_patient->qual[d.seq].
       request_status_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].request_status_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_him_request_patient->qual[d.seq].request_status_dt_tm,
     cnvtint(edw_him_request_patient->qual[d.seq].request_status_dt_tm),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].request_status_prsnl_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].approval_ind,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_him_request_patient->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(edw_him_request_patient->qual[d.seq].
       src_beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].src_beg_effective_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_him_request_patient->qual[d.seq].
     src_beg_effective_dt_tm,cnvtint(edw_him_request_patient->qual[d.seq].src_beg_effective_dt_tm),
     "HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_him_request_patient->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(edw_him_request_patient->qual[d.seq].
       src_end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].src_end_effective_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_him_request_patient->qual[d.seq].
     src_end_effective_dt_tm,cnvtint(edw_him_request_patient->qual[d.seq].src_end_effective_dt_tm),
     "HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].encounter_nk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].encounter_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].create_prsnl_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].last_update_prsnl_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].cancel_prsnl_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].rejected_reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].authorized_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].authorized_reject_reason_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_him_request_patient->qual[d.seq].active_ind,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
