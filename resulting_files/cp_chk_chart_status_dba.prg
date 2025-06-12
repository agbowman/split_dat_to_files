CREATE PROGRAM cp_chk_chart_status:dba
 SET total = 0
 SET modified = 0
 SELECT DISTINCT INTO "nl:"
  chart_request_id
  FROM chart_request
  WHERE chart_request_id > 0.0
  WITH nocounter
 ;end select
 SET total = curqual
 SELECT INTO "nl:"
  chart_status_cd
  FROM chart_request
  WHERE chart_status_cd > 0.0
   AND chart_request_id > 0.0
  WITH nocounter
 ;end select
 SET modified = curqual
 IF (modified=total)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "chart_status_cd was successfully updated in CHART_REQUEST table"
  CALL echo("CHART_STATUS_CD was successfully updated in CHART_REQUEST table")
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "update process of chart_status_cd for CHART_REQUEST table failed"
  CALL echo("update process of chart_status_cd for CHART_REQUEST table failed")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
