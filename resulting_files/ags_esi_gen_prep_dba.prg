CREATE PROGRAM ags_esi_gen_prep:dba
 PROMPT
  "TASK_ID          (0.0) = " = 0.0,
  "App Flag (1=AGS 2=ESI) = " = 1,
  "Batch Processes  (1-6) = " = 1,
  "Batch Size             = " = 10000
  WITH vtaskid, vappflag, vbatchproccnt,
  vbatchsize
 CALL echo("<===== AGS_ESI_GEN_PREP Begin =====>")
 SET script_ver = "000 05/17/06"
 CALL echo(concat("MOD:",script_ver))
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 IF (validate(log,"!")="!")
  EXECUTE cclseclogin2
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  SET define_logging_sub = true
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
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  DECLARE sstatus_file_name = vc WITH public, constant(concat("ags_esi_gen_prep_",format(cnvtdatetime
     (curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 FREE RECORD batchesrec
 RECORD batchesrec(
   1 batch_cnt = i4
   1 batch[*]
     2 process = i4
     2 start_person_id = f8
     2 finish_person_id = f8
 )
 DECLARE dtaskid = f8 WITH public, constant(cnvtreal( $VTASKID))
 DECLARE staskid = vc WITH public, constant(trim(cnvtstring(dtaskid)))
 DECLARE lappflag = i4 WITH private, constant( $VAPPFLAG)
 DECLARE lbatchproccnt = i4 WITH private, constant( $VBATCHPROCCNT)
 DECLARE lbatchsize = i4 WITH public, constant( $VBATCHSIZE)
 DECLARE li = i4 WITH public, noconstant(0)
 DECLARE lj = i4 WITH public, noconstant(0)
 DECLARE sfilename = vc WITH public, noconstant(" ")
 DECLARE dagsjobid = f8 WITH public, noconstant(0.0)
 DECLARE lloglevel = i4 WITH public, noconstant(0)
 DECLARE str1 = vc WITH public, noconstant(" ")
 DECLARE str2 = vc WITH public, noconstant(" ")
 DECLARE str3 = vc WITH public, noconstant(" ")
 IF (dtaskid <= 0.0)
  SET failed = input_error
  SET table_name = "dTaskId"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "Error :: dTaskId <= 0.0"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lbatchproccnt > 6)
  SET failed = input_error
  SET table_name = "lBatchProcCnt"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "Error :: lBatchProcCnt > 6"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   AGS_TASK & AGS_JOB Lookup")
 CALL echo("***")
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j
  PLAN (t
   WHERE t.ags_task_id=dtaskid)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
  ORDER BY t.ags_task_id, j.ags_job_id
  DETAIL
   dagsjobid = j.ags_job_id, lloglevel = t.timers_flag
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lloglevel >= 1)
  SET trace = callecho
  SET trace = cost
  IF (lloglevel > 1)
   SET trace = echorecord
  ENDIF
 ELSE
  SET trace = nocallecho
  SET trace = nocost
  SET trace = noechorecord
 ENDIF
 CALL echo(build("ags_task_id:",dtaskid))
 CALL echo(build("lAppFlag     :",lappflag))
 CALL echo(build("lBatchProcCnt:",lbatchproccnt))
 CALL echo(build("lBatchSize   :",lbatchsize))
 CASE (lappflag)
  OF 1:
   CALL echo("***")
   CALL echo("***   AGS App")
   CALL echo("***")
   SELECT INTO "nl:"
    a.person_id
    FROM ags_person_data a
    WHERE a.person_id > 0
     AND a.ags_job_id=dagsjobid
    ORDER BY a.person_id
    HEAD REPORT
     li = 0
    DETAIL
     li = (li+ 1)
     IF (mod(li,lbatchsize)=1)
      batchesrec->batch_cnt = (batchesrec->batch_cnt+ 1), stat = alterlist(batchesrec->batch,
       batchesrec->batch_cnt), batchesrec->batch[batchesrec->batch_cnt].start_person_id = a.person_id
     ENDIF
     batchesrec->batch[batchesrec->batch_cnt].finish_person_id = a.person_id
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET failed = select_error
    SET table_name = "AGS_PERSON_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: curqual < 1 for AGS_TASK_ID :: ",staskid)
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
  OF 2:
   CALL echo("***")
   CALL echo("***   ESI App")
   CALL echo("***")
   SET failed = input_error
   SET table_name = "ESI App"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "ErrMsg :: Support for ESI has not been built yet!"
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
 ENDCASE
 FOR (li = 1 TO batchesrec->batch_cnt)
   SET batchesrec->batch[li].process = (mod((li - 1),lbatchproccnt)+ 1)
 ENDFOR
 IF (lloglevel > 1)
  CALL echorecord(batchesrec)
 ENDIF
 CALL echo("***")
 CALL echo("***   Create Shell Files")
 CALL echo("***")
 FOR (li = 1 TO lbatchproccnt)
   SET sfilename = ""
   IF (cursys="AIX")
    SET sfilename = concat("ags_esi_batch",format(li,"##;P0"),".ksh")
   ELSE
    SET sfilename = concat("ags_esi_batch",format(li,"##;P0"),".com")
   ENDIF
   CALL echo(build("file name:",sfilename))
   IF (findfile(sfilename)=0)
    SELECT INTO value(sfilename)
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     DETAIL
      IF (cursys="AIX")
       "#!/usr/bin/ksh", row + 1, ". $cer_mgr/.user_setup `$cer_mgr_exe/getenvlog`",
       row + 1, "ccl <<!", row + 1
       FOR (lj = 1 TO batchesrec->batch_cnt)
         IF ((batchesrec->batch[lj].process=li))
          str1 = trim(cnvtstring(batchesrec->batch[lj].start_person_id),3), str2 = trim(cnvtstring(
            batchesrec->batch[lj].finish_person_id),3), "reset",
          row + 1, str3 = concat("call echo('Starting batch ",trim(cnvtstring(lj),3)," of ",trim(
            cnvtstring(batchesrec->batch_cnt),3)," -- Persons ",
           str1," to ",str2,")') go"), str3,
          row + 1, str3 = concat("set opf_batch_start_person_id = ",str1," go"), str3,
          row + 1, str3 = concat("set opf_batch_finish_person_id = ",str2," go"), str3,
          row + 1, "opf_gen_matches go", row + 1,
          "commit go", row + 1, "exit",
          row + 1, "!", row + 1,
          "ccl <<!", row + 1
         ENDIF
       ENDFOR
       "commit go", row + 1, "exit"
      ELSE
       "$ccl", row + 1
       FOR (lj = 1 TO batchesrec->batch_cnt)
         IF ((batchesrec->batch[lj].process=li))
          str1 = trim(cnvtstring(batchesrec->batch[lj].start_person_id),3), str2 = trim(cnvtstring(
            batchesrec->batch[lj].finish_person_id),3), "reset",
          row + 1, str3 = concat("call echo('Starting batch ",trim(cnvtstring(lj),3)," of ",trim(
            cnvtstring(batchesrec->batch_cnt),3)," -- Persons ",
           str1," to ",str2,")') go"), str3,
          row + 1, str3 = concat("set opf_batch_start_person_id = ",str1," go"), str3,
          row + 1, str3 = concat("set opf_batch_finish_person_id = ",str2," go"), str3,
          row + 1, "opf_gen_matches go", row + 1,
          "commit go", row + 1, "exit",
          row + 1, "$ccl", row + 1
         ENDIF
       ENDFOR
       "commit go", row + 1, "exit"
      ENDIF
     WITH nocounter, noformfeed, format = variable,
      maxrow = 1
    ;end select
   ELSE
    SET failed = input_error
    SET table_name = "findfile()"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("Error :: File:'",trim(sfilename),"' already exists!")
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
 ENDFOR
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
      FOR (exe_idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[exe_idx].smsgtype,"#######")," :: ",
           format(log->qual[exe_idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[
            exe_idx].smsg))))
        IF ((exe_idx=log->qual_knt))
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
        IF ((exe_idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nolidx, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
    IF ((email->qual_knt > 0))
     DECLARE msgpriority = i4 WITH public, noconstant(5)
     DECLARE sendto = vc WITH public, noconstant(trim(semail))
     DECLARE sender = vc WITH public, noconstant("sf3151")
     DECLARE subject = vc WITH public, noconstant("")
     DECLARE msgclass = vc WITH public, noconstant("IPM.NOTE")
     DECLARE msgtext = vc WITH public, noconstant("")
     IF (istatus=0)
      SET subject = concat("SUCCESS - ",trim(slog_file))
      SET msgtext = concat("SUCCESS - ",trim(slog_file))
     ELSEIF (istatus=1)
      SET subject = concat("FAILURE - ",trim(slog_file))
      SET msgtext = concat("FAILURE - ",trim(slog_file))
     ELSE
      SET subject = concat("SUCCESS (with Warnings) - ",trim(slog_file))
      SET msgtext = concat("SUCCESS (with Warnings) - ",trim(slog_file))
     ENDIF
     FOR (eidx = 1 TO email->qual_knt)
       IF ((email->qual[eidx].send_flag=0))
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=1)
        AND istatus != 1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=2)
        AND istatus=1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
#exit_script
 IF (failed != false)
  ROLLBACK
  CALL echorecord(log)
  IF (dtaskid > 0)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=dtaskid)
    WITH nolidx
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Select Error :: ",trim(serrmsg))
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
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_ESO_GEN_PREP"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("<===== AGS_ESO_GEN_PREP End =====>")
END GO
