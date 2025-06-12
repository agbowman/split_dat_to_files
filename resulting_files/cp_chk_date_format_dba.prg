CREATE PROGRAM cp_chk_date_format:dba
 SET total = 0
 SET modified = 0
 SELECT DISTINCT INTO "nl:"
  chart_format_id
  FROM chart_format
  WHERE chart_format_id > 0
  WITH nocounter
 ;end select
 SET total = curqual
 SELECT INTO "nl:"
  date_mask
  FROM chart_format
  WHERE  NOT (date_mask IN (" ", null))
   AND chart_format_id > 0
  WITH nocounter
 ;end select
 SET modified = curqual
 IF (modified=total)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "date_mask was successfully updated in CHART_FORMAT table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "update process of date_mask for CHART_FORMAT table failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 SET modified = 0
 SET total = 0
 SELECT INTO "nl:"
  chart_group_id
  FROM chart_horz_format
  WHERE chart_group_id > 0
  WITH nocounter
 ;end select
 SET total = curqual
 SELECT INTO "nl:"
  date_mask
  FROM chart_horz_format
  WHERE  NOT (date_mask IN (" ", null))
   AND chart_group_id > 0
  WITH nocounter
 ;end select
 SET modified = curqual
 IF (modified=total)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "date_mask was successfully updated in CHART_HORZ_FORMAT table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of date_mask for CHART_HORZ_FORMAT table failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 SET modified = 0
 SET total = 0
 SELECT INTO "nl:"
  chart_group_id
  FROM chart_vert_format
  WHERE chart_group_id > 0
  WITH nocounter
 ;end select
 SET total = curqual
 SELECT INTO "nl:"
  date_mask
  FROM chart_vert_format
  WHERE  NOT (date_mask IN (" ", null))
   AND chart_group_id > 0
  WITH nocounter
 ;end select
 SET modified = curqual
 IF (modified=total)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "date_mask was successfully updated in CHART_VERT_FORMAT table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of date_mask for CHART_VERT_FORMAT table failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 SET modified = 0
 SET total = 0
 SELECT INTO "nl:"
  chart_group_id
  FROM chart_zonal_format
  WHERE chart_group_id > 0
  WITH nocounter
 ;end select
 SET total = curqual
 SELECT INTO "nl:"
  date_mask
  FROM chart_zonal_format
  WHERE  NOT (date_mask IN (" ", null))
   AND chart_group_id > 0
  WITH nocounter
 ;end select
 SET modified = curqual
 IF (modified=total)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "date_mask was successfully updated in CHART_ZONAL_FORMAT table"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of date_mask for CHART_ZONAL_FORMAT table failed"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
