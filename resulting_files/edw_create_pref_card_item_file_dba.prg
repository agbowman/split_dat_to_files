CREATE PROGRAM edw_create_pref_card_item_file:dba
 SELECT INTO value(pref_card_item_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
   AND (pref_card_item_info->qual[d.seq].pref_card_sk != 0.0)
  DETAIL
   pref_card_cnt = (pref_card_cnt+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].pref_card_sk,16))), v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].pref_card_item_sk,16))), v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].catalog_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].associated_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].surgical_specialty_ref,16))), v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].surgical_area_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].document_type_ref,16))), v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].hist_avg_duration)), v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].total_case_nbr)),
   v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].override_hist_avg_duration)), v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].override_total_case_nbr)), v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].override_lookback_nbr)),
   v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].recent_avg_case_nbr)), v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].recent_avg_duration)), v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].request_open_qty)),
   v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].request_hold_qty)), v_bar,
   "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)),
   v_bar,
   CALL print(trim(pref_card_item_info->qual[d.seq].src_active_ind,3)), v_bar,
   CALL print(trim(cnvtstring(pref_card_item_info->qual[d.seq].item_sk,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "003 11/27/12 SM016593"
END GO
