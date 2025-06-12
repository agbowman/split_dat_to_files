CREATE PROGRAM edw_create_encntr_encntr_reltn:dba
 SELECT INTO value(encntr_encntr_reltn_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE (edw_encntr_encntr_reltn->qual[d.seq].enc_enc_reltn_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(edw_encntr_encntr_reltn->qual[d.seq].encounter_nk,str_find,str_replace,3),
    3)), v_bar,
   CALL print(trim(replace(edw_encntr_encntr_reltn->qual[d.seq].related_encounter_nk,str_find,
     str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_encntr_encntr_reltn->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_encntr_encntr_reltn->qual[d.seq].related_encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_encntr_encntr_reltn->qual[d.seq].enc_enc_reltn_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_encntr_encntr_reltn->qual[d.seq].enc_reltn_type_ref,16))), v_bar,
   "3", v_bar, "1",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 05/15/2020 BS074648"
END GO
