CREATE PROGRAM edw_create_ap_concept:dba
 SELECT INTO value(ap_cncpt_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(ap_concept->qual[d.seq].ap_concept_sk)), v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].ap_case_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].concept_type_flg,16))), v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].concept_nomen,16))), v_bar,
   CALL print(trim(ap_concept->qual[d.seq].ap_rpt_section_sk)),
   v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].report_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].specimen_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].concept_group_ident,16))),
   v_bar,
   CALL print(trim(replace(ap_concept->qual[d.seq].concept_value_txt,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].concept_truth_state_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].units_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(ap_concept->qual[d.seq].auto_code_flg,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, "1", v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "000 02/23/07 MG010594"
END GO
