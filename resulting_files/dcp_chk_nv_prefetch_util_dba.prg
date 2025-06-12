CREATE PROGRAM dcp_chk_nv_prefetch_util:dba
 SET nbr_records = 0
 SELECT INTO "nl:"
  n.name_value_prefs_id
  FROM name_value_prefs n
  WHERE n.pvc_name="PREFETCH"
  DETAIL
   nbr_records = (nbr_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 133
 IF (nbr_records > 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "PREFETCH rows still exist in name_value_prefs"
 ELSE
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
