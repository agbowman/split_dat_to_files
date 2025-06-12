CREATE PROGRAM edw_create_answer:dba
 SELECT INTO value(qstanswr_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].encounter_nk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].qst_answer_inst_sk,16))), v_bar,
   CALL print(trim(edw_answer->qual[d.seq].parent_entity_name)),
   v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].parent_entity_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].qst_question_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].value_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].value_chc,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_answer->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(edw_answer->qual[d.seq].value_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].value_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_answer->qual[d.seq].value_dt_tm,cnvtint(edw_answer->
      qual[d.seq].value_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].value_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].value_nbr,16))),
   v_bar,
   CALL print(trim(replace(edw_answer->qual[d.seq].value_txt,str_find,str_replace,3),3)), v_bar
   IF ((edw_answer->qual[d.seq].value_data_type="DATE"))
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_answer->qual[d.seq].value_dt_tm,0,
       cnvtdatetimeutc(edw_answer->qual[d.seq].value_dt_tm,3)),utc_timezone_index,
      "MM/DD/YYYY HH:mm:ss")))
   ELSE
    CALL print(trim(replace(edw_answer->qual[d.seq].string_value,str_find,str_replace,3),3))
   ENDIF
   v_bar,
   CALL print(trim(edw_answer->qual[d.seq].value_data_type)), v_bar,
   CALL print(trim(edw_answer->qual[d.seq].value_type)), v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].active_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(edw_answer->qual[d.seq].value_cd_set,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 10/30/2016 SB026554"
END GO
