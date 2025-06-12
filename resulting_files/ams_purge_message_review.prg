CREATE PROGRAM ams_purge_message_review
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select purge run to mark as REVIEWED" = 0
  WITH outdev, jobid
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_PURGE_MESSAGE_REVIEW")
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 UPDATE  FROM dm_purge_job_log dpjl
  SET dpjl.err_msg = concat("REVIEWED BY AMS -",dpjl.err_msg)
  WHERE dpjl.log_id IN ( $JOBID)
 ;end update
 SELECT INTO  $OUTDEV
  purge_template = d.name, dpjl.log_id, run = dpjl.start_dt_tm"@SHORTDATETIME",
  runtime = format(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm),"HH:MM:SS;;Z"), message = dpjl
  .err_msg
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
    AND dpjl.log_id IN ( $JOBID))
  ORDER BY purge_template, run DESC
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(script_name)
#exit_script
 SET script_ver = "001  09/19/2013  SB8469 Initial Release"
END GO
