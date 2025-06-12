CREATE PROGRAM edw_create_question:dba
 SELECT INTO value(qstquest_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_question->qual[d.seq].qst_question_inst_sk,16))), v_bar,
   CALL print(trim(edw_question->qual[d.seq].entity_name)),
   v_bar,
   CALL print(trim(edw_question->qual[d.seq].questionnaire_name)), v_bar,
   CALL print(trim(cnvtstring(edw_question->qual[d.seq].questionnaire_type_flg,16))), v_bar,
   CALL print(trim(replace(edw_question->qual[d.seq].questionnaire_cond,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(edw_question->qual[d.seq].question_parent_value,16)), v_bar,
   CALL print(trim(cnvtstring(edw_question->qual[d.seq].question_parent_sk,16))), v_bar,
   CALL print(trim(replace(edw_question->qual[d.seq].question_meaning,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_question->qual[d.seq].question_seq,16))), v_bar,
   CALL print(trim(replace(edw_question->qual[d.seq].quest_txt,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_question->qual[d.seq].question_type,str_find,str_replace,3))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
