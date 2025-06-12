CREATE PROGRAM edw_create_hm_expect:dba
 SELECT INTO value(hm_expct_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].hm_expect_inst_sk,16))), v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].expect_meaning,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].expect_name,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].always_count_hist_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].interval_only_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].last_action_seq,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].max_age,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].seq_nbr,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].step_cnt,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].hm_expect_series_sk,16))), v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].expect_series_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].first_step_age,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].last_action_seq,16))), v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].priority_meaning,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].rule_associated_ind,16))), v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].series_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].hm_expect_sched_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].expect_sched_loc,16))), v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].expect_sched_meaning,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_hm_expect->qual[d.seq].expect_sched_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].expect_sched_type_flg,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].last_action_seq,16))), v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].on_time_start_age,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_hm_expect->qual[d.seq].sched_level_flg,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
