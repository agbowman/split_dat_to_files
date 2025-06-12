CREATE PROGRAM cp_chk_add_prov_field:dba
 SET cnt_prov = 0
 SET error_cnt = 0
 SELECT INTO "nl:"
  cdfv.parent_entity_id
  FROM chart_dist_filter_value cdfv
  WHERE cdfv.type_flag=2
  HEAD REPORT
   cnt_prov = 0
  DETAIL
   cnt_prov += 1
  WITH nocounter
 ;end select
 IF (cnt_prov=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "SUCCESSFUL - Chart_Dist_Filter_Value table updated (reltn_type_cd)"
 ELSE
  SELECT INTO "nl:"
   cdfv.reltn_type_cd
   FROM chart_dist_filter_value cdfv
   WHERE cdfv.type_flag=2
   HEAD REPORT
    error_cnt = 0
   DETAIL
    IF (cdfv.reltn_type_cd=0)
     error_cnt += 1
    ENDIF
   WITH nocounter
  ;end select
  IF (error_cnt=0)
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg =
   "SUCCESSFUL - Chart_Dist_Filter_Value table updated (reltn_type_cd)"
  ELSE
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg =
   "FAILURE - Chart_Dist_Filter_Value table not updated (reltn_type_cd)"
  ENDIF
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
