CREATE PROGRAM edw_create_phone:dba
 SELECT INTO value(phone_extractfile)
  FROM (dummyt d  WITH seq = size(edw_phone->qual,5))
  WHERE (edw_phone->qual[d.seq].phone_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].phone_sk,16))), v_bar,
   CALL print(trim(edw_phone->qual[d.seq].src_active_ind,3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_phone->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(edw_phone->qual[d.seq].src_beg_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].src_beg_effective_tm_zn))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_phone->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(edw_phone->qual[d.seq].src_end_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].src_end_effective_tm_zn))),
   v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].call_instruction,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].contact_name,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].contact_method_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].description,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].extension,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].phone_long_text_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].modem_capability_ref,16))), v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].operation_hours,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].paging_code,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].src_parent_entity_sk,16))), v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].src_parent_entity_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].phone_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].phone_type_ref,16))), v_bar,
   CALL print(build(edw_phone->qual[d.seq].phone_type_seq)), v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].source_identifier,str_find,str_replace,3))),
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(replace(edw_phone->qual[d.seq].formatted_phone_nbr,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_phone->qual[d.seq].phone_format_ref,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 06/13/2011 RP019504"
END GO
