CREATE PROGRAM edw_create_loc_attributes:dba
 SELECT INTO value(loc_atr_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(loc_atr->qual[d.seq].location_attrib_sk_vc), v_bar,
   CALL print(loc_atr->qual[d.seq].src_active_ind),
   v_bar,
   CALL print(loc_atr->qual[d.seq].attrib_type_ref), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,loc_atr->qual[d.seq].src_beg_effective_dt_tm,
      0,cnvtdatetimeutc(loc_atr->qual[d.seq].src_beg_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(loc_atr->qual[d.seq].src_beg_effective_tm_zn),
   v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].src_beg_effective_tm_vld_flg))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,loc_atr->qual[d.seq].src_end_effective_dt_tm,
      0,cnvtdatetimeutc(loc_atr->qual[d.seq].src_end_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(loc_atr->qual[d.seq].src_end_effective_tm_zn),
   v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].src_end_effective_tm_vld_flg))), v_bar,
   CALL print(trim(replace(loc_atr->qual[d.seq].description,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].attrib_loc,16))),
   v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].parent_attrib_loc,16))), v_bar,
   CALL print(trim(replace(loc_atr->qual[d.seq].parent_attrib_meaning,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].value_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,loc_atr->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(loc_atr->qual[d.seq].value_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(loc_atr->qual[d.seq].value_tm_zn), v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].value_tm_vld_flg))),
   v_bar,
   CALL print(trim(cnvtstring(loc_atr->qual[d.seq].value_ident,16))), v_bar,
   CALL print(loc_atr->qual[d.seq].value_num), v_bar,
   CALL print(trim(replace(loc_atr->qual[d.seq].value_string,str_find,str_replace,3),3)),
   v_bar,
   CALL print(loc_atr->qual[d.seq].value_time_num), v_bar,
   CALL print(trim(replace(loc_atr->qual[d.seq].value_type,str_find,str_replace,3),3)), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(replace(loc_atr->qual[d.seq].hist_action,str_find,str_replace,3),3)), v_bar,
   CALL print(loc_atr->qual[d.seq].parent_location_attrib_sk),
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 09/03/2009 AO9323"
END GO
