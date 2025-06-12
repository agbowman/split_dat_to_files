CREATE PROGRAM ams_ccl_audit_runtimes
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Runtime cutoff (minutes)" = 5
  WITH outdev, runtime
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_CCL_AUDIT_RUNTIMES")
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 SET run_secs = ( $RUNTIME * 60)
 SELECT INTO  $OUTDEV
  application = a.description, task = at.description, request = r.request_name,
  row_time = c.updt_dt_tm"@SHORTDATETIME", runtime_in_minutes = datetimediff(c.end_dt_tm,c
   .begin_dt_tm,4), run_by = p.name_full_formatted,
  c.object_name, c.status, c.object_params,
  c.object_type, c.records_cnt, c.output_device,
  c.tempfile, c.long_text_id, l.long_text
  FROM ccl_report_audit c,
   person p,
   application a,
   application_task at,
   request r,
   long_text l
  PLAN (c
   WHERE c.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),0) AND cnvtdatetime(curdate,130000)
    AND c.object_name != "*MP_*"
    AND ((datetimediff(c.end_dt_tm,c.begin_dt_tm) * 86400) > run_secs))
   JOIN (p
   WHERE c.updt_id=p.person_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number)
   JOIN (at
   WHERE c.updt_task=at.task_number)
   JOIN (r
   WHERE c.request_nbr=r.request_number
    AND r.request_name != "CCL_RUN_MPAGE")
   JOIN (l
   WHERE c.long_text_id=l.long_text_id)
  ORDER BY application, runtime_in_minutes DESC
  WITH nocounter, separator = " ", format
 ;end select
 SUBROUTINE amsuser(a_prsnl_id)
   DECLARE user_ind = i2 WITH protect, noconstant(false)
   DECLARE prsnl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   SELECT INTO "nl:"
    p.person_id
    FROM person_name p
    PLAN (p
     WHERE p.person_id=a_prsnl_id
      AND p.name_type_cd=prsnl_cd
      AND p.name_title="Cerner AMS"
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (p.person_id > 0)
      user_ind = true
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 CALL updtdminfo(script_name)
#exit_script
 SET script_ver = "002  07/01/2015  SB8469 Security and Tracking release"
END GO
