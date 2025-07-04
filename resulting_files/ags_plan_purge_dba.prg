CREATE PROGRAM ags_plan_purge:dba
 PROMPT
  "Backout Type (J, I, P) =" = "J",
  "AGS_JOB_ID (0.0) = " = 0.0
  WITH cbackout_type, djob_id
 SET ags_plan_purge_mod = "000 10/12/06"
 CALL echo("<===== AGS_PLAN_PURGE Begin =====>")
 CALL echo(concat("MOD:",ags_plan_purge_mod))
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
  DECLARE sstatus_file_name = vc WITH private, noconstant(concat("ags_plan_purge_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
 ENDIF
 FREE RECORD planrec
 RECORD planrec(
   1 qual_knt = i4
   1 qual[*]
     2 ags_plan_data_id = f8
   1 qual2_knt = i4
   1 qual2[*]
     2 person_rx_plan_reltn_id = f8
 )
 DECLARE the_type = c1 WITH protect, noconstant(" ")
 SET the_type =  $CBACKOUT_TYPE
 DECLARE the_job_id = f8 WITH protect, noconstant(cnvtreal( $DJOB_ID))
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_PLAN_PURGE"
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("PARAMETER >> BACKOUT_TYPE : ",trim(the_type))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("PARAMETER >> AGS_JOB_ID : ",trim(cnvtstring(the_job_id))
  )
 IF (cnvtupper(the_type)="P"
  AND the_job_id < 1)
  CALL echo("***")
  CALL echo("***   PERSON Type Run")
  CALL echo("***")
  IF ( NOT (validate(person_rec,0)))
   SET failed = input_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "PERSON_REC >> Not Defined"
   GO TO exit_script
  ENDIF
  IF (size(person_rec->qual,5) < 1)
   SET failed = input_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "PERSON_REC >> Has no items"
   GO TO exit_script
  ENDIF
  SET stat = initrec(planrec)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_plan_data a,
    (dummyt d  WITH seq = value(person_rec->qual_knt))
   PLAN (d
    WHERE d.seq > 0
     AND (person_rec->qual[d.seq].person_id > 0)
     AND (person_rec->qual[d.seq].validated_ind > 0))
    JOIN (a
    WHERE (a.person_id=person_rec->qual[d.seq].person_id)
     AND a.person_rx_plan_reltn_id > 0.0)
   ORDER BY a.person_rx_plan_reltn_id
   HEAD REPORT
    lidx = 0, stat = alterlist(planrec->qual,10), lidx2 = 0,
    stat = alterlist(planrec->qual2,10)
   HEAD a.person_rx_plan_reltn_id
    lidx2 = (lidx2+ 1)
    IF (mod(lidx2,10)=1
     AND lidx2 != 1)
     stat = alterlist(planrec->qual2,(lidx2+ 9))
    ENDIF
    planrec->qual2[lidx2].person_rx_plan_reltn_id = a.person_rx_plan_reltn_id
   DETAIL
    lidx = (lidx+ 1)
    IF (mod(lidx,10)=1
     AND lidx != 1)
     stat = alterlist(planrec->qual,(lidx+ 9))
    ENDIF
    planrec->qual[lidx].ags_plan_data_id = a.ags_plan_data_id
   FOOT REPORT
    planrec->qual_knt = lidx, stat = alterlist(planrec->qual,lidx), planrec->qual2_knt = lidx2,
    stat = alterlist(planrec->qual2,lidx2)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = select_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PLAN_DATA >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtupper(the_type)="J"
  AND the_job_id > 0.0)
  CALL echo("***")
  CALL echo("***   JOB Type Run")
  CALL echo("***")
  SET stat = initrec(planrec)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_plan_data a
   WHERE a.ags_job_id=the_job_id
    AND a.person_rx_plan_reltn_id > 0.0
   ORDER BY a.person_rx_plan_reltn_id
   HEAD REPORT
    lidx = 0, stat = alterlist(planrec->qual,10), lidx2 = 0,
    stat = alterlist(planrec->qual2,10)
   HEAD a.person_rx_plan_reltn_id
    lidx2 = (lidx2+ 1)
    IF (mod(lidx2,10)=1
     AND lidx2 != 1)
     stat = alterlist(planrec->qual2,(lidx2+ 9))
    ENDIF
    planrec->qual2[lidx2].person_rx_plan_reltn_id = a.person_rx_plan_reltn_id
   DETAIL
    lidx = (lidx+ 1)
    IF (mod(lidx,10)=1
     AND lidx != 1)
     stat = alterlist(planrec->qual,(lidx+ 9))
    ENDIF
    planrec->qual[lidx].ags_plan_data_id = a.ags_plan_data_id
   FOOT REPORT
    planrec->qual_knt = lidx, stat = alterlist(planrec->qual,lidx), planrec->qual2_knt = lidx2,
    stat = alterlist(planrec->qual2,lidx2)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = select_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PLAN_DATA >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtupper(the_type)="I")
  CALL echo("***")
  CALL echo("***   ITEM Type Run")
  CALL echo("***")
  IF ( NOT (validate(item_rec,0)))
   SET failed = input_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "ITEM_REC >> Not Defined"
   GO TO exit_script
  ENDIF
  IF ((item_rec->qual_knt < 1))
   SET failed = input_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "ITEM_REC >> Has no items"
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_plan_data a,
    (dummyt d  WITH seq = value(item_rec->qual_knt))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (a
    WHERE (a.person_rx_plan_reltn_id=item_rec->qual[d.seq].data_id)
     AND a.person_rx_plan_reltn_id > 0.0)
   ORDER BY a.person_rx_plan_reltn_id
   HEAD REPORT
    lidx = 0, stat = alterlist(planrec->qual,10), lidx2 = 0,
    stat = alterlist(planrec->qual2,10)
   HEAD a.person_rx_plan_reltn_id
    lidx2 = (lidx2+ 1)
    IF (mod(lidx2,10)=1
     AND lidx2 != 1)
     stat = alterlist(planrec->qual2,(lidx2+ 9))
    ENDIF
    planrec->qual2[lidx2].person_rx_plan_reltn_id = a.person_rx_plan_reltn_id
   DETAIL
    lidx = (lidx+ 1)
    IF (mod(lidx,10)=1
     AND lidx != 1)
     stat = alterlist(planrec->qual,(lidx+ 9))
    ENDIF
    planrec->qual[lidx].ags_plan_data_id = a.ags_plan_data_id
   FOOT REPORT
    planrec->qual_knt = lidx, stat = alterlist(planrec->qual,lidx), planrec->qual2_knt = lidx2,
    stat = alterlist(planrec->qual2,lidx2)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = select_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("SELECT ERROR AGS_PLAN_DATA >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSE
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "PARAMETER ERROR >> Invalid Parameter"
  GO TO exit_script
 ENDIF
 IF ((planrec->qual_knt > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  CALL echo("***")
  CALL echo("***   Delete from PERSON_RX_PLAN_RELTN")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM person_rx_plan_reltn r,
    (dummyt d  WITH seq = value(planrec->qual2_knt))
   SET r.seq = 1
   PLAN (d
    WHERE d.seq > 0)
    JOIN (r
    WHERE (r.person_rx_plan_reltn_id=planrec->qual2[d.seq].person_rx_plan_reltn_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = delete_error
   SET table_name = "PERSON_RX_PLAN_RELTN"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("DELETE Error :: ErrMsg :: ",trim(serrmsg))
   GO TO exit_script
  ENDIF
  CALL echo("***")
  CALL echo("***   Delete from AGS_PLAN_DATA")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_plan_data a,
    (dummyt d  WITH seq = value(planrec->qual_knt))
   SET a.seq = 1
   PLAN (d
    WHERE d.seq > 0)
    JOIN (a
    WHERE (a.ags_plan_data_id=planrec->qual[d.seq].ags_plan_data_id))
   WITH nocounter, maxcommit = 5000
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = delete_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR AGS_PLAN_DATA >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (define_logging_sub=true)
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
        out_line = trim(substring(1,254,concat(format(log->qual[idx].smsgtype,"#######")," :: ",
           format(log->qual[idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[idx].
            smsg))))
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
 ENDIF
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
    SET j.status = "ERROR-PURGE", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (j
     WHERE j.ags_job_id=the_job_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    ROLLBACK
    SET failed = update_error
    SET table_name = "AGS_JOB ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_JOB ERROR :: Update Error :: ",trim(serrmsg))
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
  CALL echo("***   else (failed = FALSE)")
  CALL echo("***")
  IF (the_job_id > 0)
   CALL echo("***")
   CALL echo("***   Update Job to Purge")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_job j
    SET j.status = "PURGED", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (j
     WHERE j.ags_job_id=the_job_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    ROLLBACK
    SET failed = update_error
    SET table_name = "AGS_JOB ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_JOB ERROR :: Update Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
  ENDIF
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PLAN_PURGEs"
 IF (define_logging_sub=true)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
  SET s_log_name = sstatus_file_name
  CALL echo("***")
  CALL echo(build("***   Log File: cer_log >",s_log_name))
  CALL echo("***")
 ENDIF
 SET script_ver = "001 11/08/06"
 CALL echo("<===== AGS_PLAN_PURGE End =====>")
END GO
