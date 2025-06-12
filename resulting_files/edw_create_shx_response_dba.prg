CREATE PROGRAM edw_create_shx_response:dba
 SELECT INTO value(shx_resp_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(concat(trim(cnvtstring(edw_shx_response->qual[d.seq].response_sk,16)),"~",trim(
     cnvtstring(edw_shx_response->qual[d.seq].shx_alpha_response_sk,16)))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].response_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].shx_alpha_response_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].shx_activity_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].response_modifier_flag))),
   v_bar,
   CALL print(trim(edw_shx_response->qual[d.seq].response_type)), v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].response_unit_ref))), v_bar,
   CALL print(trim(replace(edw_shx_response->qual[d.seq].response_val,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].task_assay_sk))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].alpha_response_nomen))), v_bar,
   CALL print(trim(replace(edw_shx_response->qual[d.seq].other_txt,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_response->qual[d.seq].active_ind))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
