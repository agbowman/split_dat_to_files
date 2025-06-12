CREATE PROGRAM edw_create_fin_workload:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(fin_workload_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].workload_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].charge_event_sk,16))), v_bar,
   CALL print(trim(edw_workload->qual[d.seq].workload_code)), v_bar,
   CALL print(trim(edw_workload->qual[d.seq].workload_desc,16)),
   v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].workload_multiplier,16))), v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].workload_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].workload_quantity,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].workload_units,16))), v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].workload_extended_units,16))), v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].item_for_count_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].bill_item_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_workload->qual[d.seq].active_ind,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
