CREATE PROGRAM edw_create_pathway_outcome_ref:dba
 SELECT INTO value(outcme_r_extractfile)
  FROM (dummyt d  WITH seq = value(size(outcome_ref->qual,5)))
  WHERE (outcome_ref->qual[d.seq].outcome_ref_sk != null)
  DETAIL
   outcome_counter = (outcome_counter+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].outcome_ref_sk,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].pathway_component_seq,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].description,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].outcome_type_ref,16))), v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].expand_qty,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].expand_unit_ref,16))),
   v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].offset_qty,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].offset_unit_ref,16))), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].target_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].clinical_category_ref,16))), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].clinical_sub_category_ref,16))), v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].intended_duration_qty,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].intended_duration_unit_ref,16))), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].linked_to_time_frame_ind,16))), v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].chemo_related_ind,str_find,str_replace,3),3)),
   v_bar,
   CALL print(build(outcome_ref->qual[d.seq].required_ind)), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].event_ref,16))), v_bar,
   CALL print(trim(replace(outcome_ref->qual[d.seq].expectation,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].result_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].task_assay_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,outcome_ref->qual[d.seq].active_dt_tm,0,
      cnvtdatetimeutc(outcome_ref->qual[d.seq].active_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(outcome_ref->qual[d.seq].active_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(outcome_ref->qual[d.seq].active_dt_tm,cnvtint(outcome_ref->
      qual[d.seq].active_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(build(outcome_ref->qual[d.seq].outcome_ref_source_flg)),
   v_bar, "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar,
   CALL print(trim(outcome_ref->qual[d.seq].src_active_ind,3)),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
#exit_script
 SET script_version = "005 05/06/2020 SS077455"
END GO
