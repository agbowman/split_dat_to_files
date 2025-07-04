CREATE PROGRAM ags_benefit_level_purge:dba
 PROMPT
  "Backout Type (J, I, P) =" = "J",
  "AGS_JOB_ID (0.0) = " = 0.0
  WITH cbackout_type, djob_id
 CALL echo("***")
 CALL echo("***   BEG :: AGS_BENEFIT_LEVEL_PURGE")
 CALL echo("***")
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
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
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
  DECLARE sstatus_file_name = vc WITH private, noconstant(concat("ags_benefit_level_purge_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_BENEFIT_LEVEL_PURGE"
 DECLARE the_type = c1 WITH protect, noconstant(" ")
 SET the_type =  $CBACKOUT_TYPE
 DECLARE the_job_id = f8 WITH protect, noconstant(0.0)
 SET the_job_id =  $DJOB_ID
 FREE RECORD purge_rec
 RECORD purge_rec(
   1 qual_knt = i4
   1 qual[*]
     2 delete_item_id = f8
     2 delete_person_id = f8
     2 delete_run_nbr = i4
     2 bo_item_id = f8
     2 mil_item_id = f8
 )
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
 IF (the_type="P"
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
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(person_rec->qual_knt)),
    ags_benefit_level_data a1
   PLAN (d
    WHERE d.seq > 0
     AND (person_rec->qual[d.seq].validated_ind > 0)
     AND (person_rec->qual[d.seq].person_id > 0))
    JOIN (a1
    WHERE (a1.person_id=person_rec->qual[d.seq].person_id))
   HEAD REPORT
    sknt = 0, stat = alterlist(purge_rec->qual,10)
   DETAIL
    sknt = (sknt+ 1)
    IF (mod(sknt,10)=1
     AND sknt != 1)
     stat = alterlist(purge_rec->qual,(sknt+ 9))
    ENDIF
    purge_rec->qual[sknt].mil_item_id = a1.person_id, purge_rec->qual[sknt].delete_item_id = a1
    .ags_benefit_level_data_id, purge_rec->qual[sknt].delete_person_id = a1.person_id,
    purge_rec->qual[sknt].delete_run_nbr = a1.run_nbr
   FOOT REPORT
    purge_rec->qual_knt = sknt, stat = alterlist(purge_rec->qual,sknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = selete_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat(
    "SELECT ERROR AGS_BENEFIT_LEVEL_DATA (delete items) >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (the_type="J"
  AND the_job_id > 0.0)
  CALL echo("***")
  CALL echo("***   JOB Type Run")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_benefit_level_data a1
   PLAN (a1
    WHERE a1.ags_job_id=the_job_id
     AND a1.person_id > 0)
   HEAD REPORT
    sknt = 0, stat = alterlist(purge_rec->qual,10)
   DETAIL
    sknt = (sknt+ 1)
    IF (mod(sknt,10)=1
     AND sknt != 1)
     stat = alterlist(purge_rec->qual,(sknt+ 9))
    ENDIF
    purge_rec->qual[sknt].mil_item_id = a1.person_id, purge_rec->qual[sknt].delete_item_id = a1
    .ags_benefit_level_data_id, purge_rec->qual[sknt].delete_person_id = a1.person_id,
    purge_rec->qual[sknt].delete_run_nbr = a1.run_nbr
   FOOT REPORT
    purge_rec->qual_knt = sknt, stat = alterlist(purge_rec->qual,sknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = selete_error
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat(
    "SELECT ERROR AGS_BENEFIT_LEVEL_DATA (delete items) >> ",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (the_type="I")
  CALL echo("***")
  CALL echo("***   ITEM Type Run")
  CALL echo("***")
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "INVALID PURGE >> BENEFIT_LEVEL by Item Not Allowed"
  GO TO exit_script
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
 IF ((purge_rec->qual_knt < 1))
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No items found to purge"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(purge_rec->qual_knt)),
   ags_benefit_level_data a1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (a1
   WHERE (a1.person_id=purge_rec->qual[d.seq].delete_person_id)
    AND (a1.run_nbr < purge_rec->qual[d.seq].delete_run_nbr))
  ORDER BY d.seq, a1.run_nbr DESC
  HEAD d.seq
   purge_rec->qual[d.seq].bo_item_id = a1.ags_benefit_level_data_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = selete_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat(
   "SELECT ERROR AGS_BENEFIT_LEVEL_DATA (backout items) >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM gs_benefit_level g,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET g.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].mil_item_id > 0))
   JOIN (g
   WHERE (g.person_id=purge_rec->qual[d.seq].mil_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR GS_BENEFIT_LEVEL >> ",trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_benefit_level_data b,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET b.status = "BACK OUT", b.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id > 0))
   JOIN (b
   WHERE (b.ags_benefit_level_data_id=purge_rec->qual[d.seq].bo_item_id))
  WITH nocounter, maxcommit = 5000
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE ERROR AGS_BENEFIT_LEVEL_DATA (backout item) >> ",
   trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_benefit_level_data b,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET b.status = "BACK OUT", b.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id < 1)
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (b
   WHERE (b.ags_benefit_level_data_id=purge_rec->qual[d.seq].delete_item_id))
  WITH nocounter, maxcommit = 5000
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE ERROR AGS_BENEFIT_LEVEL_DATA (delete item) >> ",
   trim(serrmsg))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DELETE  FROM ags_benefit_level_data b,
   (dummyt d  WITH seq = value(purge_rec->qual_knt))
  SET b.seq = 1
  PLAN (d
   WHERE d.seq > 0
    AND (purge_rec->qual[d.seq].bo_item_id > 0)
    AND (purge_rec->qual[d.seq].delete_item_id > 0))
   JOIN (b
   WHERE (b.ags_benefit_level_data_id=purge_rec->qual[d.seq].delete_item_id))
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
  SET log->qual[log->qual_knt].smsg = concat("DELETE ERROR AGS_BENEFIT_LEVEL_DATA (delete item) >> ",
   trim(serrmsg))
  GO TO exit_script
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
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  IF (the_job_id > 0)
   CALL echo("***")
   CALL echo("***   Update Job to Purged")
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_BENEFIT_LEVEL_PURGE"
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
 CALL echo("***")
 CALL echo("***   END :: AGS_BENEFIT_LEVEL_PURGE")
 CALL echo("***")
 SET script_ver = "000   03/10/06"
END GO
