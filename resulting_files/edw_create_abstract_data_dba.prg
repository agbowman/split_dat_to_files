CREATE PROGRAM edw_create_abstract_data:dba
 SELECT INTO value(abstract_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].abstract_data_sk,16))),
   v_bar,
   CALL print(trim(edw_abstract_data->qual[d.seq].encounter_nk)), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].encntr_slice_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].svc_cat_hist_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].abstract_field_def_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].abstract_field_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].value_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].value_code_set,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_abstract_data->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(edw_abstract_data->qual[d.seq].value_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].value_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_abstract_data->qual[d.seq].value_dt_tm,cnvtint(
      edw_abstract_data->qual[d.seq].value_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(replace(edw_abstract_data->qual[d.seq].value_free_txt,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].value_nbr,16))), v_bar,
   CALL print(trim(cnvtstring(edw_abstract_data->qual[d.seq].active_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
