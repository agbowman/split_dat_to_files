CREATE PROGRAM edw_create_pathway_action:dba
 DECLARE ipathway_count = i4 WITH protect, constant(size(edw_pathway_action->qual,5))
 SELECT INTO value(pathway_action_extractfile)
  FROM (dummyt d  WITH seq = ipathway_count)
  WHERE ipathway_count > 0
  DETAIL
   col 0, health_system_id, v_bar,
   health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].pathway_phase_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].action_seq,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pathway_action->qual[d.seq].start_dt_tm,0,
      cnvtdatetimeutc(edw_pathway_action->qual[d.seq].start_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].communication_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].duration_unit_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pathway_action->qual[d.seq].end_dt_tm,0,
      cnvtdatetimeutc(edw_pathway_action->qual[d.seq].end_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].pathway_status_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].action_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pathway_action->qual[d.seq].action_dt_tm,
      0,cnvtdatetimeutc(edw_pathway_action->qual[d.seq].action_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].duration_qty,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].action_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].provider_prsnl,16))), v_bar,
   extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].action_tm_zn,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].start_tm_zn,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].end_tm_zn,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].pathway_phase_action_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].pathway_catalog_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].action_reason_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_pathway_action->qual[d.seq].action_comment,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].start_estimated_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pathway_action->qual[d.seq].end_estimated_ind,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "004 05/29/2018 SB026554"
END GO
