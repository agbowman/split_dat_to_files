CREATE PROGRAM edw_create_scd_term:dba
 SELECT INTO value(scd_term_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scd_story_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scd_term_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scd_paragraph_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scr_para_type_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].paragraph_seq,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].paragraph_truth_state_ref,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].paragraph_scd_term_data_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].paragraph_event_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scd_sentence_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].canonical_sentence_pattern_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].sentence_event_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].sentence_scr_term_hier_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].sentence_seq,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].sentence_author_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scr_term_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].term_scr_term_hier_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].parent_scd_term_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].succesor_scd_term_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].term_seq,16))), v_bar,
   CALL print(trim(replace(scd_term->qual[d.seq].concept_cki,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].scd_term_data_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].truth_state_ref,16))), v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].event_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].modify_prsnl,16))), v_bar,
   CALL print(trim(replace(scd_term->qual[d.seq].phase_txt,str_find,str_replace,3))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(scd_term->qual[d.seq].active_ind))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
