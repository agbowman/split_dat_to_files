CREATE PROGRAM dm_script_report:dba
 DECLARE ml_max_error_num = i4 WITH protect, constant(15007)
 DECLARE ml_min_error_num = i4 WITH protect, constant(15000)
 DECLARE ml_errors_cnt = i4 WITH protect, constant(((ml_max_error_num - ml_min_error_num)+ 1))
 FREE RECORD m_error_struct
 RECORD m_error_struct(
   1 error_list[ml_errors_cnt]
     2 error_status = vc
 )
 DECLARE dm_date = vc WITH protect, noconstant(" ")
 DECLARE dm_environ_id = i4 WITH protect, noconstant(0)
 DECLARE dm_max_col = i4 WITH protect, constant(32001)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE dm_unique_dat = vc WITH protect, noconstant(" ")
 SET dm_date = format(cnvtdatetime(curdate,curtime3),"mm/dd/yy;;d")
 SET dm_unique_dat = concat(cnvtlower(curuser),trim(cnvtstring(curtime3),3),".dat")
 SELECT INTO "nl:"
  FROM dm_threshold dt,
   dm_threshold_criteria dtc
  PLAN (dt
   WHERE dt.review_type="BUILDTIME SCANNER"
    AND dt.active_ind=1)
   JOIN (dtc
   WHERE dtc.criteria_name="INCLUDE_ERROR")
  DETAIL
   IF (ml_min_error_num <= dtc.criteria_value
    AND dtc.criteria_value <= ml_max_error_num)
    m_error_struct->error_list[((dtc.criteria_value - ml_min_error_num)+ 1)].error_status = dtc
    .action
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   dm_environ_id = di.info_number
  WITH nocounter, maxcol = value(dm_max_col), format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_env dsi
  WHERE dsi.script_name=cnvtupper( $1)
   AND (dsi.project_instance= $2)
   AND dsi.environment_id=dm_environ_id
  HEAD REPORT
   tmp_inst = dsi.project_instance, tmp_env = dm_environ_id, col 0,
   "************************************", row + 1, col 0,
   "DM_SCRIPT_REPORT for ", col + 1, dm_date,
   col + 1, curtime, row + 1,
   col 0, "************************************", row + 2,
   col 0, "Script Name: ", col + 1,
   dsi.script_name, row + 1, col 0,
   "Project Instance:", col + 1, tmp_inst,
   row + 1, col 0, "Environment:",
   col + 1, tmp_env, row + 1,
   col 0, "Analyzed: ", col + 1,
   dsi.updt_dt_tm
  WITH nocounter, maxcol = value(dm_max_col), format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM (dummyt d  WITH seq = size(dm_script_scanner_reply->err_list,5))
  HEAD REPORT
   e_line = fillstring(50,"="), p_line = fillstring(50,"."), d_status = fillstring(8," "),
   d_disp = fillstring(500," "), row + 2, col 0,
   e_line, row + 1, col 0,
   "Script Scanner Results:", row + 1
   IF ((dm_script_scanner_reply->fail_ind=1))
    d_status = "SUCCESS"
    FOR (d_loop = 1 TO size(dm_script_scanner_reply->err_list,5))
      IF ((ml_min_error_num <= dm_script_scanner_reply->err_list[d_loop].fail_number)
       AND (dm_script_scanner_reply->err_list[d_loop].fail_number <= ml_max_error_num))
       IF (d_status != "FAILED")
        d_status = m_error_struct->error_list[((dm_script_scanner_reply->err_list[d_loop].fail_number
         - ml_min_error_num)+ 1)].error_status
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    d_status = "SUCCESS"
   ENDIF
   col 0, "STATUS:", col + 1,
   d_status, row + 1, col 0,
   "----------", row + 1
  DETAIL
   IF ((dm_script_scanner_reply->err_list[d.seq].fail_message="Success"))
    col 0, "No errors reported for this script."
   ELSE
    d_disp = concat(m_error_struct->error_list[((dm_script_scanner_reply->err_list[d.seq].fail_number
      - ml_min_error_num)+ 1)].error_status,": ",dm_script_scanner_reply->err_list[d.seq].
     fail_message), col 0, d_disp
   ENDIF
   row + 1
  FOOT REPORT
   col 0, p_line
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_tbl_env dst
  WHERE dst.script_name=cnvtupper( $1)
   AND (dst.project_instance= $2)
   AND dst.environment_id=dm_environ_id
  HEAD REPORT
   row + 1, col 0, "Insert Tables: ",
   row + 1
  DETAIL
   IF (dst.insert_ind > 0)
    col 2, dst.table_name, row + 1
   ENDIF
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_tbl_env dst
  WHERE dst.script_name=cnvtupper( $1)
   AND (dst.project_instance= $2)
   AND dst.environment_id=dm_environ_id
  HEAD REPORT
   row + 1, col 0, "Update Tables: ",
   row + 1
  DETAIL
   IF (dst.update_ind > 0)
    col 2, dst.table_name, row + 1
   ENDIF
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_tbl_env dst
  WHERE dst.script_name=cnvtupper( $1)
   AND (dst.project_instance= $2)
   AND dst.environment_id=dm_environ_id
  HEAD REPORT
   row + 1, col 0, "Delete Tables: ",
   row + 1
  DETAIL
   IF (dst.delete_ind > 0)
    col 2, dst.table_name, row + 1
   ENDIF
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_tbl_env dst
  WHERE dst.script_name=cnvtupper( $1)
   AND (dst.project_instance= $2)
   AND dst.environment_id=dm_environ_id
  HEAD REPORT
   row + 1, col 0, "Select Tables: ",
   row + 1
  DETAIL
   IF (dst.select_ind > 0)
    col 2, dst.table_name, row + 1
   ENDIF
  FOOT REPORT
   row + 1
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_ndx_env dsx
  WHERE dsx.script_name=cnvtupper( $1)
   AND (dsx.project_instance= $2)
   AND dsx.environment_id=dm_environ_id
   AND dsx.index_name > " "
  HEAD REPORT
   row + 1, col 0, "Indexes Utilized: ",
   row + 1, col 0, "Table Name: ",
   col 30, "Index Name: ", row + 1
  DETAIL
   col 0, dsx.table_name, col 30,
   dsx.index_name, row + 1
  FOOT REPORT
   row + 1
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 SELECT INTO value(dm_unique_dat)
  FROM dm_script_info_sql_env dss
  WHERE dss.script_name=cnvtupper( $1)
   AND (dss.project_instance= $2)
   AND dss.environment_id=dm_environ_id
  HEAD REPORT
   row + 1, col 0, "SQL Statements: ",
   row + 1, col 0, "*********************************************"
  DETAIL
   tmp_cost = trim(cnvtstring(dss.cost),3), row + 1, col 0,
   "Optimizer: ", col + 1, dss.optimizer,
   row + 1, col 0, "Cost: ",
   col + 1, tmp_cost, d_len = textlen(dss.sql_stmt)
   IF (d_len > 2000)
    d_cycles = (ceil((d_len/ 2000))+ 1), d_start = 1, d_chars = 1900
    FOR (d_loop = 1 TO d_cycles)
      row + 1, d_disp = substring(d_start,d_chars,dss.sql_stmt), col 0,
      d_disp, d_start = (d_start+ d_chars)
    ENDFOR
    row + 1
   ELSE
    row + 1, col 0, dss.sql_stmt,
    row + 1
   ENDIF
   col 0, "*********************************************"
  WITH nocounter, append, maxcol = value(dm_max_col),
   format = variable
 ;end select
 CALL parser(concat('set logical search_logical "',value(dm_unique_dat),'" go'))
 FREE DEFINE rtl2
 DEFINE rtl2 "search_logical"
 SELECT
  t.line
  FROM rtl2t t
  WITH nocounter, formfeed = none, maxrow = 1
 ;end select
 CALL echo("*** Removing DAT files ***")
 SET stat = remove(value(dm_unique_dat))
 IF (stat=0)
  SET error_ind = "Y"
  CALL echo("** Purge DAT Files Failed **")
 ELSE
  CALL echo(concat("** Removal of:",value(dm_unique_dat),"*.* complete **"))
 ENDIF
END GO
