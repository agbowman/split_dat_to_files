CREATE PROGRAM ams_purge_review:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Successful with Message Report (template filter available)" = 0,
  "Purges hitting 70% of Max Row report (all templates)" = 0,
  "Purge Parameter Audit (all templates)" = 0,
  "Purges running longer than 5 min (all templates)" = 0,
  "Template to purge or report on" = 0,
  "Run Single Purge and show Report (must select template above)" = 0
  WITH outdev, fails, threshold,
  parameter, longrun, template,
  runpurge
 EXECUTE ams_define_toolkit_common
 FREE SET request
 DECLARE templ = i4 WITH protect, noconstant(0)
 DECLARE script_name = vc WITH protect, constant("AMS_PURGE_REVIEW")
 DECLARE run_ind = i2 WITH protect, noconstant(false)
 RECORD request(
   1 batch_selection = vc
 )
 SET purge_flag =  $RUNPURGE
 SET fail_report =  $FAILS
 SET threshold_report =  $THRESHOLD
 SET longrun_report =  $LONGRUN
 SET parameters_report =  $PARAMETER
 SET temptl =  $TEMPLATE
 SET request->batch_selection = build(temptl,",",temptl)
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 IF (purge_flag=1
  AND fail_report=0
  AND temptl != 0)
  EXECUTE dm_purge_data
 ENDIF
 IF (threshold_report=1)
  SELECT INTO  $OUTDEV
   t.name, purge = evaluate(j.purge_flag,1,"Purge with job level logging",2,
    "Purge with table level logging",
    3,"Don't Purge - Audit only"), t.template_nbr,
   percent_of_max = ((cnvtreal(l.parent_rows)/ cnvtreal(j.max_rows)) * 100), purged_rows = l
   .parent_rows, max_rows_per_run = j.max_rows,
   l.start_dt_tm"@SHORTDATETIME", total_rows = d.num_rows, partent_table = l.parent_table
   FROM dm_purge_job_log l,
    dm_purge_job j,
    dm_purge_template t,
    dba_tables d
   WHERE ((l.parent_rows/ j.max_rows) > 0.7)
    AND l.job_id=j.job_id
    AND (l.start_dt_tm > (sysdate - 30))
    AND t.template_nbr=j.template_nbr
    AND j.max_rows > 0
    AND l.parent_table=d.table_name
   ORDER BY t.name, l.start_dt_tm DESC
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (fail_report=1
  AND temptl=0)
  SELECT INTO  $OUTDEV
   nbr = d.template_nbr, purge_template = d.name, last_run = dpjm.last_run_dt_tm"@SHORTDATETIME",
   last_status = evaluate(dpjm.last_run_status_flag,1,"SUCCESS",2,"FAILURE"), dpjl.log_id, run = dpjl
   .start_dt_tm"@SHORTDATETIME",
   runtime = format(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm),"HH:MM:SS;;Z"), message = dpjl
   .err_msg, error_code = dpjl.err_code,
   purge_script = d.program_str, dpjl.parent_table, dpjl.parent_rows,
   dpjl.child_rows
   FROM dm_purge_job dpjm,
    dm_purge_template d,
    dm_purge_job_log dpjl
   PLAN (dpjm
    WHERE (dpjm.last_run_dt_tm > (sysdate - 14))
     AND dpjm.last_run_status_flag=1)
    JOIN (d
    WHERE dpjm.template_nbr=d.template_nbr)
    JOIN (dpjl
    WHERE dpjl.job_id=dpjm.job_id
     AND (dpjl.updt_dt_tm > (sysdate - 14))
     AND dpjl.err_msg > " ")
   ORDER BY d.name, run DESC
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (fail_report=0
  AND temptl != 0
  AND threshold_report=0)
  SELECT INTO  $OUTDEV
   nbr = d.template_nbr, purge_template = d.name, last_run = dpjm.last_run_dt_tm"@SHORTDATETIME",
   last_status = evaluate(dpjm.last_run_status_flag,1,"SUCCESS",2,"FAILURE"), dpjl.log_id, run = dpjl
   .start_dt_tm"@SHORTDATETIME",
   runtime = format(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm),"HH:MM:SS;;Z"), message = dpjl
   .err_msg, error_code = dpjl.err_code,
   purge_script = d.program_str, dpjl.parent_table, dpjl.parent_rows,
   dpjl.child_rows
   FROM dm_purge_job dpjm,
    dm_purge_template d,
    dm_purge_job_log dpjl
   PLAN (dpjm
    WHERE (dpjm.template_nbr= $TEMPLATE)
     AND (dpjm.last_run_dt_tm > (sysdate - 14))
     AND dpjm.last_run_status_flag=1)
    JOIN (d
    WHERE dpjm.template_nbr=d.template_nbr)
    JOIN (dpjl
    WHERE dpjl.job_id=dpjm.job_id
     AND (dpjl.updt_dt_tm > (sysdate - 14)))
   ORDER BY d.name, run DESC
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (fail_report=1
  AND temptl != 0)
  SELECT INTO  $OUTDEV
   nbr = d.template_nbr, purge_template = d.name, last_run = dpjm.last_run_dt_tm"@SHORTDATETIME",
   last_status = evaluate(dpjm.last_run_status_flag,1,"SUCCESS",2,"FAILURE"), dpjl.log_id, run = dpjl
   .start_dt_tm"@SHORTDATETIME",
   runtime = format(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm),"HH:MM:SS;;Z"), message = dpjl
   .err_msg, error_code = dpjl.err_code,
   purge_script = d.program_str, dpjl.parent_table, dpjl.parent_rows,
   dpjl.child_rows
   FROM dm_purge_job dpjm,
    dm_purge_template d,
    dm_purge_job_log dpjl
   PLAN (dpjm
    WHERE (dpjm.template_nbr= $TEMPLATE)
     AND (dpjm.last_run_dt_tm > (sysdate - 7))
     AND dpjm.last_run_status_flag=1)
    JOIN (d
    WHERE dpjm.template_nbr=d.template_nbr)
    JOIN (dpjl
    WHERE dpjl.job_id=dpjm.job_id
     AND (dpjl.updt_dt_tm > (sysdate - 7))
     AND dpjl.err_msg > " ")
   ORDER BY d.name, run DESC
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (fail_report=0
  AND temptl=0
  AND threshold_report=0
  AND longrun_report=0
  AND parameters_report=0)
  SELECT INTO  $OUTDEV
   nbr = d.template_nbr, purge_template = d.name, last_run = dpjm.last_run_dt_tm"@SHORTDATETIME",
   last_status = evaluate(dpjm.last_run_status_flag,1,"SUCCESS",2,"FAILURE"), dpjl.log_id, run = dpjl
   .start_dt_tm"@SHORTDATETIME",
   runtime = format(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm),"HH:MM:SS;;Z"), message = dpjl
   .err_msg, error_code = dpjl.err_code,
   purge_script = d.program_str, dpjl.parent_table, dpjl.parent_rows,
   dpjl.child_rows
   FROM dm_purge_job dpjm,
    dm_purge_template d,
    dm_purge_job_log dpjl
   PLAN (dpjm
    WHERE (dpjm.last_run_dt_tm > (sysdate - 7))
     AND dpjm.last_run_status_flag=1)
    JOIN (d
    WHERE dpjm.template_nbr=d.template_nbr)
    JOIN (dpjl
    WHERE dpjl.job_id=dpjm.job_id
     AND (dpjl.updt_dt_tm > (sysdate - 7)))
   ORDER BY d.name, run DESC
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (longrun_report=1)
  SELECT INTO  $OUTDEV
   dpt.name, dpt.template_nbr, d.start_dt_tm"@SHORTDATETIME",
   d.end_dt_tm"@SHORTDATETIME", runtime = format(datetimediff(d.end_dt_tm,d.start_dt_tm),
    "HH:MM:SS;;Z"), purge = evaluate(dp.purge_flag,1,"Purge with job level logging",2,
    "Purge with table level logging",
    3,"Don't Purge - Audit only"),
   d.err_code, d.err_msg, purge_script = dpt.program_str,
   d.parent_table, d.parent_rows, d.child_rows
   FROM dm_purge_job_log d,
    dm_purge_job dp,
    dm_purge_template dpt
   PLAN (d
    WHERE ((datetimediff(d.end_dt_tm,d.start_dt_tm) * 1440) > 5)
     AND d.start_dt_tm > cnvtdatetime((curdate - 14),curtime3))
    JOIN (dp
    WHERE d.job_id=dp.job_id)
    JOIN (dpt
    WHERE dpt.template_nbr=dp.template_nbr)
   ORDER BY runtime DESC
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 IF (parameters_report=1)
  SELECT INTO  $OUTDEV
   d.template_nbr, dp.name, active = evaluate(d.active_flag,1,"Active",2,"Inactive",
    3,"Template for the job has changed.  Needs to be reviewed."),
   d.last_run_dt_tm"@SHORTDATETIME", d.max_rows, purge = evaluate(d.purge_flag,1,
    "Purge with job level logging",2,"Purge with table level logging",
    3,"Don't Purge - Audit only"),
   dpj.value, dpt.prompt_str
   FROM dm_purge_template dp,
    dm_purge_job d,
    dm_purge_token dpt,
    dm_purge_job_token dpj,
    dummyt d1,
    dummyt d2
   PLAN (dp)
    JOIN (d
    WHERE d.template_nbr=dp.template_nbr
     AND d.active_flag IN (1, 2, 3))
    JOIN (d1)
    JOIN (dpj
    WHERE d.job_id=dpj.job_id)
    JOIN (d2)
    JOIN (dpt
    WHERE d.template_nbr=dpt.template_nbr
     AND dpj.token_str=dpt.token_str)
   ORDER BY dp.name, dpt.prompt_str
   WITH nocounter, separator = " ", format,
    outerjoin = d1, outerjoin = d2
  ;end select
 ENDIF
 CALL updtdminfo(script_name)
#exit_script
 SET script_ver = "001  09/19/2013  SB8469 Initial Release"
END GO
