CREATE PROGRAM edw_create_requester:dba
 SELECT INTO value(requester_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].requester_sk,16))),
   v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].parent_entity_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].parent_entity_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].requester_source_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].billable_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].prebill_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].charges_per_page,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].selection_criteria_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].delivery_method_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_requester->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(edw_requester->qual[d.seq].src_beg_effective_dt_tm,3)
      ),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].src_beg_effective_dt_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_requester->qual[d.seq].src_beg_effective_dt_tm,cnvtint(
      edw_requester->qual[d.seq].src_beg_effective_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_requester->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(edw_requester->qual[d.seq].src_end_effective_dt_tm,3)
      ),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].src_end_effective_dt_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_requester->qual[d.seq].src_end_effective_dt_tm,cnvtint(
      edw_requester->qual[d.seq].src_end_effective_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].active_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].expected_turn_around,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].request_reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].prebill_over_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].approval_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].bill_to_address_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].mail_to_address_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].mail_to_address_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].bill_to_address_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].mail_to_phone_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].mail_to_fax_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].bill_to_phone_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].bill_to_fax_sk,16))),
   v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_last,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_last_key,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_last_key_nls,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_first,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_first_key,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_first_key_nls,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_requester->qual[d.seq].name_full_formatted,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].mail_to_address_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].mail_to_address_type_seq,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].bill_to_address_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_requester->qual[d.seq].bill_to_address_type_seq,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
