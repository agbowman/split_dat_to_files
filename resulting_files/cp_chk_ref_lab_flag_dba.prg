CREATE PROGRAM cp_chk_ref_lab_flag:dba
 SET total = 0
 SET modified = 0
 SELECT DISTINCT INTO "nl:"
  chart_format_id
  FROM chart_format
  WHERE chart_format_id > 0.0
  WITH nocounter
 ;end select
 SET total = curqual
 SELECT INTO "nl:"
  ref_lab_flag
  FROM chart_format
  WHERE ref_lab_flag != null
   AND chart_format_id > 0.0
  WITH nocounter
 ;end select
 SET modified = curqual
 IF (modified=total)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "ref_lab_flag was successfully updated in CHART_FORMAT table"
  CALL echo("ref_lab_flag was successfully updated in CHART_FORMAT table")
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of ref_lab_flag for CHART_FORMAT table failed"
  CALL echo("update process of ref_lab_flag for CHART_FORMAT table failed")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
