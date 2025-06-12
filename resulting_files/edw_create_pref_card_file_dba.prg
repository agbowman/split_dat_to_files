CREATE PROGRAM edw_create_pref_card_file:dba
 SELECT INTO value(pref_card_extractfile)
  FROM (dummyt d  WITH seq = value(pc_cnt))
  WHERE pc_cnt > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(pref_card_info->qual[d.seq].surgical_case_proc_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(pref_card_info->qual[d.seq].pref_card_p_reltn_sk,16))), v_bar,
   CALL print(trim(cnvtstring(pref_card_info->qual[d.seq].pref_card_sk,16))), v_bar,
   CALL print(trim(cnvtstring(pref_card_info->qual[d.seq].document_type_ref,16))),
   v_bar,
   CALL print(trim(pref_card_info->qual[d.seq].pick_list_change_flg)), v_bar,
   CALL print(trim(cnvtstring(pref_card_info->qual[d.seq].pref_card_section_nbr,16))), v_bar, "3",
   v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar,
   CALL print(trim(pref_card_info->qual[d.seq].active_ind)), v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 IF (debug="Y")
  CALL echo(build("Rows written this loop:",pc_cnt))
 ENDIF
 SET script_version = "000 10/02/2006 rw010644"
END GO
