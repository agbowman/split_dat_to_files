CREATE PROGRAM edw_create_shx_element:dba
 SELECT INTO value(shx_elem_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].shx_element_inst_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].shx_category_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].category_ref,16))), v_bar,
   CALL print(trim(replace(edw_shx_element->qual[d.seq].element_desc,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].category_comment_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].input_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].element_task_assay_sk,16))), v_bar,
   CALL print(trim(replace(edw_shx_element->qual[d.seq].response_label,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].response_label_layout_flg,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].element_seq,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_element->qual[d.seq].required_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
