CREATE PROGRAM edw_create_scd_term_data
 SELECT INTO value(scd_data_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].scd_story_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].scd_term_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].term_data_sk,16))), v_bar,
   CALL print(trim(replace(scd_term_data->qual[d.seq].scd_term_data_sk,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(scd_term_data->qual[d.seq].data_txt,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].data_type_ref,16))), v_bar,
   CALL print(trim(replace(scd_term_data->qual[d.seq].entity_name,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].entity_ident,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].diagnosis_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].procedure_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].order_sk,16))), v_bar,
   CALL print(trim(replace(scd_term_data->qual[d.seq].encounter_nk,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].code_set,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].code_value_ref,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].term_data_blob_format_ref,16))), v_bar,
   CALL print(trim(replace(scd_term_data->qual[d.seq].value_txt,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].value_nbr,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,scd_term_data->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(scd_term_data->qual[d.seq].value_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].value_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(scd_term_data->qual[d.seq].value_dt_tm,cnvtint(
      scd_term_data->qual[d.seq].value_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].value_dt_tm_offset,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].value_unit_of_measure_ref,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(scd_term_data->qual[d.seq].active_ind))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
