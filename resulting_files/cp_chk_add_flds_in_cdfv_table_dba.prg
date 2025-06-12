CREATE PROGRAM cp_chk_add_flds_in_cdfv_table:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  cdfv.parent_entity_name
  FROM chart_dist_filter_value cdfv
  WHERE trim(cdfv.parent_entity_name)=null
   AND cdfv.distribution_id != 0
  DETAIL
   nbr_records += 1
  WITH nocounter
 ;end select
 IF (nbr_records=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "chart_dist_filter_value table was successfully updated with parent_entity_name"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "chart_dist_filter_value table failed successful update with parent_entity_name"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
