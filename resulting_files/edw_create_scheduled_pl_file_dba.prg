CREATE PROGRAM edw_create_scheduled_pl_file:dba
 SELECT INTO value(scheduled_pl_extractfile)
  FROM (dummyt d  WITH seq = value(spl_cnt))
  WHERE spl_cnt > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(scheduled_pick_list_info->qual[d.seq].surgical_case_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scheduled_pick_list_info->qual[d.seq].sched_pick_list_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scheduled_pick_list_info->qual[d.seq].pref_card_item_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scheduled_pick_list_info->qual[d.seq].document_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(scheduled_pick_list_info->qual[d.seq].sched_pick_list_item,16))), v_bar,
   CALL print(trim(scheduled_pick_list_info->qual[d.seq].open_qty)), v_bar,
   CALL print(trim(scheduled_pick_list_info->qual[d.seq].hold_qty)),
   v_bar,
   CALL print(trim(scheduled_pick_list_info->qual[d.seq].changed_flg)), v_bar,
   CALL print(trim(cnvtstring(scheduled_pick_list_info->qual[d.seq].fill_loc,16))), v_bar, "3",
   v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar,
   CALL print(trim(scheduled_pick_list_info->qual[d.seq].active_ind)), v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 SET script_version = "000 09/29/2006 rw010644"
END GO
