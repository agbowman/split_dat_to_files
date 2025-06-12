CREATE PROGRAM edw_create_surgical_delay:dba
 SELECT INTO value(surgical_delay_extractfile)
  FROM (dummyt d  WITH seq = size(edw_surgical_delay->qual,5))
  WHERE (edw_surgical_delay->qual[d.seq].surgical_delay_sk > 0)
  DETAIL
   record_count = (record_count+ 1), col 0, health_system_id,
   v_bar, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].surgical_case_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].surgical_delay_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].perioperative_doc_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].doc_terminated_reason_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_surgical_delay->qual[d.seq].
      doc_terminated_dt_tm,0,cnvtdatetimeutc(edw_surgical_delay->qual[d.seq].doc_terminated_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].doc_terminated_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_surgical_delay->qual[d.seq].doc_terminated_dt_tm,
     cnvtint(edw_surgical_delay->qual[d.seq].doc_terminated_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].doc_terminated_by_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].segment_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].delay_reason_ref,16))), v_bar,
   CALL print(trim(edw_surgical_delay->qual[d.seq].display_seq,3)),
   v_bar,
   CALL print(trim(replace(edw_surgical_delay->qual[d.seq].delay_desc,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(edw_surgical_delay->qual[d.seq].delay_duration,3)), v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].delay_documented_by_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].delay_reported_to_prsnl,16))), v_bar,
   CALL print(trim(replace(edw_surgical_delay->qual[d.seq].ft_prsnl_delay_reported_to,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_surgical_delay->qual[d.seq].delay_observe_by_prsnl,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(edw_surgical_delay->qual[d.seq].active_ind,3)),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "005 05/18/2020 BS074648"
END GO
