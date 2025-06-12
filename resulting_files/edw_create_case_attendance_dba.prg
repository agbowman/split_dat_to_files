CREATE PROGRAM edw_create_case_attendance:dba
 SELECT INTO value(case_attendance_extractfile)
  FROM (dummyt d  WITH seq = size(edw_case_attendance->qual,5))
  WHERE (edw_case_attendance->qual[d.seq].case_attendance_sk > 0)
  DETAIL
   record_count = (record_count+ 1), col 0, health_system_id,
   v_bar, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].surgical_case_proc_sk,16))), v_bar,
   CALL print(trim(build(cnvtstring(edw_case_attendance->qual[d.seq].case_attendance_sk,16),"~",
     cnvtstring(edw_case_attendance->qual[d.seq].surgical_case_proc_sk,16)))),
   v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].perioperative_doc_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].doc_terminated_reason_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_case_attendance->qual[d.seq].
      doc_terminated_dt_tm,0,cnvtdatetimeutc(edw_case_attendance->qual[d.seq].doc_terminated_dt_tm,3)
      ),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].doc_terminated_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_case_attendance->qual[d.seq].doc_terminated_dt_tm,
     cnvtint(edw_case_attendance->qual[d.seq].doc_terminated_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].doc_terminated_by_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].segment_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].attendee_prsnl,16))), v_bar,
   CALL print(trim(replace(edw_case_attendance->qual[d.seq].ft_attendee,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].role_perform_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_case_attendance->qual[d.seq].in_or_dt_tm,
      0,cnvtdatetimeutc(edw_case_attendance->qual[d.seq].in_or_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].in_or_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_case_attendance->qual[d.seq].in_or_dt_tm,cnvtint(
      edw_case_attendance->qual[d.seq].in_or_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_case_attendance->qual[d.seq].out_or_dt_tm,
      0,cnvtdatetimeutc(edw_case_attendance->qual[d.seq].out_or_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].out_or_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_case_attendance->qual[d.seq].out_or_dt_tm,cnvtint(
      edw_case_attendance->qual[d.seq].out_or_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].reason_for_relief_ref,16))), v_bar,
   CALL print(trim(edw_case_attendance->qual[d.seq].signing_attendee_ind,3)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(edw_case_attendance->qual[d.seq].active_ind,3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_case_attendance->qual[d.seq].surgical_case_sk,16))), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "006 09/15/2010 RP019504"
END GO
