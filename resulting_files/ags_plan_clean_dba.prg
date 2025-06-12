CREATE PROGRAM ags_plan_clean:dba
 PROMPT
  "JOB_ID (0.0) = " = 0
  WITH djob_id
 SET ags_plan_clean_mod = "000 10/12/06"
 CALL echo("<===== AGS_PLAN_CLEAN Begin =====>")
 CALL echo(concat("MOD:",ags_plan_clean_mod))
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 IF ((validate(failed,- (1))=- (1)))
  CALL echo("***")
  CALL echo("***   Declare Common Variables")
  CALL echo("***")
  IF ((validate(false,- (1))=- (1)))
   DECLARE false = i2 WITH public, noconstant(0)
  ENDIF
  IF ((validate(true,- (1))=- (1)))
   DECLARE true = i2 WITH public, noconstant(1)
  ENDIF
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  DECLARE s_log_name = vc WITH public, noconstant("")
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(log,0)))
  CALL echo("***")
  CALL echo("***   BEG LOGGING")
  CALL echo("***")
  SET define_logging_sub = true
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  DECLARE handle_logging(slog_file=vc,semail=vc,istatus_flag=i4) = null WITH protect
  DECLARE sstatus_file_name = vc WITH private, noconstant(concat("ags_plan_clean_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
 ENDIF
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 ags_plan_data_id = f8
 )
 DECLARE the_job_id = f8 WITH public, noconstant(cnvtreal( $DJOB_ID))
 DECLARE working_run_nbr = i4 WITH public, noconstant(0)
 DECLARE data_size = i4 WITH public, noconstant(1000)
 DECLARE working_timers = i4 WITH public, noconstant(0)
 DECLARE create_orgs = i2 WITH public, noconstant(false)
 DECLARE icutoverflag = i2 WITH public, noconstant(0)
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PLAN_CLEAN"
 CALL echo("***")
 CALL echo("***   Log Starting Conditions")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("THE_JOB_ID :: ",trim(cnvtstring(the_job_id)))
 CALL echo("***")
 CALL echo(build("***   $dJOB_ID: ",the_job_id))
 CALL echo("***")
 IF (the_job_id < 1)
  SET failed = input_error
  SET table_name = "dJOB_ID"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Input Error :: Invalid AGS_JOB_ID ",trim(cnvtstring(
     the_job_id)))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Job Data")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_job j
  PLAN (j
   WHERE j.ags_job_id=the_job_id
    AND j.status IN ("COMPLETE", "WAITING", "ERROR-CLEAN"))
  HEAD REPORT
   working_run_nbr = j.run_nbr
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_JOB"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Select Error :: ErrMsg :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   working_run_nbr :",working_run_nbr))
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Update Job to Cleaning")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_job j
  SET j.status = "CLEANING", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (j
   WHERE j.ags_job_id=the_job_id)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "AGS_JOB"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_JOB CLEANING :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo("***   Clean Data")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("BEG CLEAN :: AGS_JOB_ID :: ",trim(cnvtstring(the_job_id)
   ))
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_plan_data a,
   ags_plan_data a2
  PLAN (a
   WHERE a.ags_job_id=the_job_id
    AND a.person_id > 0.0
    AND a.health_plan_id > 0.0
    AND a.status != "IN ERROR"
    AND a.run_nbr=working_run_nbr)
   JOIN (a2
   WHERE a2.person_id=a.person_id
    AND a2.health_plan_id=a.health_plan_id
    AND ((a2.contributor_system_cd+ 0)=a.contributor_system_cd)
    AND ((a2.run_nbr+ 0) < a.run_nbr))
  HEAD REPORT
   stat = alterlist(hold->qual,data_size), idx = 0
  HEAD a2.ags_plan_data_id
   idx = (idx+ 1)
   IF (idx > size(hold->qual,5))
    stat = alterlist(hold->qual,(idx+ data_size))
   ENDIF
   hold->qual[idx].ags_plan_data_id = a2.ags_plan_data_id
  FOOT REPORT
   hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_PLAN_DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_PLAN_DATA LOADING :: Select Error :: ",trim(serrmsg
    ))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echorecord(hold)
 IF ((hold->qual_knt > 0))
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat(trim(cnvtstring(hold->qual_knt)),
   " Rows Found For Processing")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_plan_data p,
    (dummyt d  WITH seq = value(hold->qual_knt))
   SET p.seq = 1
   PLAN (d
    WHERE (hold->qual[d.seq].ags_plan_data_id > 0.0))
    JOIN (p
    WHERE (p.ags_plan_data_id=hold->qual[d.seq].ags_plan_data_id))
   WITH nocounter, maxcommit = value(5000)
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = select_error
   SET table_name = "AGS_PLAN_DATA CLEANING"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_PLAN_DATA CLEAN LOAD :: Delete Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No Rows Found For Processing"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("END CLEAN :: AGS_JOB_ID :: ",trim(cnvtstring(the_job_id)
   ))
 CALL echo("***")
 CALL echo("***   Update Job to Cleaned")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_job j
  SET j.status = "CLEANED", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (j
   WHERE j.ags_job_id=the_job_id)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "AGS_JOB CLEANED"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_JOB CLEANED :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 SUBROUTINE handle_logging(slog_file,semail,istatus)
   CALL echo("***")
   CALL echo(build("***   sLog_file :",slog_file))
   CALL echo(build("***   sEmail    :",semail))
   CALL echo(build("***   iStatus   :",istatus))
   CALL echo("***")
   FREE SET output_log
   SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
   SELECT INTO output_log
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     out_line = fillstring(254," "), sstatus = fillstring(25," ")
    DETAIL
     FOR (idx = 1 TO log->qual_knt)
       out_line = trim(substring(1,254,concat(format(log->qual[idx].smsgtype,"#######")," :: ",format
          (log->qual[idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[idx].smsg))))
       IF ((idx=log->qual_knt))
        IF (istatus=0)
         sstatus = "SUCCESS"
        ELSEIF (istatus=1)
         sstatus = "FAILURE"
        ELSE
         sstatus = "SUCCESS - With Warnings"
        ENDIF
        out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
       ENDIF
       col 0, out_line
       IF ((idx != log->qual_knt))
        row + 1
       ENDIF
     ENDFOR
    WITH nocounter, nullreport, formfeed = none,
     format = crstream, append, maxcol = 255,
     maxrow = 1
   ;end select
 END ;Subroutine
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  ROLLBACK
  CALL echo("***")
  CALL echo("***   failed != FALSE")
  CALL echo("***")
  IF (the_job_id > 0)
   CALL echo("***")
   CALL echo("***   Update Job to Error")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_job j
    SET j.status = "ERROR-CLEAN", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (j
     WHERE j.ags_job_id=the_job_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_JOB ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_JOB ERROR :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  CALL echo("***")
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PLAN_CLEAN"
 CALL echo("***")
 CALL echo("***   END LOGGING")
 CALL echo("***")
 CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 SET s_log_name = sstatus_file_name
 CALL echo("***")
 CALL echo(build("***   Log File: cer_log >",s_log_name))
 CALL echo("***")
 SET script_ver = "000 10/12/06"
 CALL echo("<===== AGS_PLAN_CLEAN End =====>")
END GO
