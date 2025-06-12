CREATE PROGRAM edw_create_perioperative_doc:dba
 SELECT INTO value(perioperative_doc_extractfile)
  FROM (dummyt d  WITH seq = size(edw_perioperative_doc_rep->qual,5))
  WHERE (edw_perioperative_doc_rep->qual[d.seq].perioperative_doc_sk != null)
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].surgical_case_sk,16))),
   v_bar,
   CALL print(trim(edw_perioperative_doc_rep->qual[d.seq].perioperative_doc_sk)), v_bar,
   CALL print(trim(replace(edw_perioperative_doc_rep->qual[d.seq].group_seq,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].perioperative_doc_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].doc_terminated_reason_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_perioperative_doc_rep->qual[d.seq].
      doc_terminated_dt_tm,0,cnvtdatetimeutc(edw_perioperative_doc_rep->qual[d.seq].
       doc_terminated_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].doc_terminated_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_perioperative_doc_rep->qual[d.seq].doc_terminated_dt_tm,
     cnvtint(edw_perioperative_doc_rep->qual[d.seq].doc_terminated_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].doc_terminated_by_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].segment_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].stage_ref,16))), v_bar,
   CALL print(trim(edw_perioperative_doc_rep->qual[d.seq].periop_doc_ref_sk)), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].form_event_sk,16))),
   v_bar,
   CALL print(trim(replace(edw_perioperative_doc_rep->qual[d.seq].result_value_formatted,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].codified_result_nomen,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].codified_result_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].codified_result_code_set))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].specialty_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].result_item,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].result_prsnl,16))), v_bar,
   CALL print(trim(replace(edw_perioperative_doc_rep->qual[d.seq].result_value_txt,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_perioperative_doc_rep->qual[d.seq].
      result_value_dt_tm,0,cnvtdatetimeutc(edw_perioperative_doc_rep->qual[d.seq].result_value_dt_tm,
       3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].result_value_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_perioperative_doc_rep->qual[d.seq].result_value_dt_tm,
     cnvtint(edw_perioperative_doc_rep->qual[d.seq].result_value_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].result_value_numeric,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].active_ind,3))),
   v_bar,
   CALL print(trim(edw_perioperative_doc_rep->qual[d.seq].result_ft_item_txt)), v_bar,
   CALL print(trim(replace(edw_perioperative_doc_rep->qual[d.seq].result_title_txt,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_perioperative_doc_rep->qual[d.seq].form_title_txt,str_find,str_replace,
     3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].periop_doc_type_flg,16))), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].periop_doc_id,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_perioperative_doc_rep->qual[d.seq].
      rec_ver_dt_tm,0,cnvtdatetimeutc(edw_perioperative_doc_rep->qual[d.seq].rec_ver_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_perioperative_doc_rep->qual[d.seq].
      rec_ver_dt_tm,0,cnvtdatetimeutc(edw_perioperative_doc_rep->qual[d.seq].rec_ver_dt_tm,2)),
     edw_perioperative_doc_rep->qual[d.seq].rec_ver_tm_zn,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].rec_ver_tm_zn,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_perioperative_doc_rep->qual[d.seq].
      last_ver_dt_tm,0,cnvtdatetimeutc(edw_perioperative_doc_rep->qual[d.seq].last_ver_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_perioperative_doc_rep->qual[d.seq].
      last_ver_dt_tm,0,cnvtdatetimeutc(edw_perioperative_doc_rep->qual[d.seq].last_ver_dt_tm,2)),
     edw_perioperative_doc_rep->qual[d.seq].rec_ver_tm_zn,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_perioperative_doc_rep->qual[d.seq].last_ver_tm_zn,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "009 12/02/2020 BS074648"
END GO
