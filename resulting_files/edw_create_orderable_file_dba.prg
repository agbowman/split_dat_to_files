CREATE PROGRAM edw_create_orderable_file:dba
 SELECT INTO value(ordbl_extractfile)
  FROM (dummyt d  WITH seq = value(or_cnt))
  WHERE or_cnt > 0
  DETAIL
   o_file_cnt = (o_file_cnt+ 1), col 0,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].orderable_sk,16))),
   v_bar, health_system_source_id, v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].orderable_display,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].orderable_desc,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].orderable_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].activity_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].activity_sub_type_ref,16))),
   v_bar,
   CALL print(trim(edw_orderable->qual[d.seq].bill_only_ind)), v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].concept_cki,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(edw_orderable->qual[d.seq].cont_order_method_flg)), v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].clinical_category_ref,16))), v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].dept_display_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(edw_orderable->qual[d.seq].dc_interaction_days)), v_bar,
   CALL print(trim(edw_orderable->qual[d.seq].modifiable_flg)), v_bar,
   CALL print(trim(edw_orderable->qual[d.seq].orderable_type_flg)),
   v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].orderable_event_ref,16))), v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].orderable_synonym,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].orderable_synonym_type_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].opcs_nomen,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].order_catalog_ref,16))), v_bar,
   CALL print(trim(replace(edw_orderable->qual[d.seq].orderable_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(edw_orderable->qual[d.seq].src_active_ind,3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_orderable->qual[d.seq].order_sentence_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_orderable->qual[d.seq].src_updt_dt_tm,0,
      cnvtdatetimeutc(edw_orderable->qual[d.seq].src_updt_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "012 05/23/16 MF025696"
END GO
