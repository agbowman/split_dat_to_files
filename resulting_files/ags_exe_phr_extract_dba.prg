CREATE PROGRAM ags_exe_phr_extract:dba
 CALL echo("***")
 CALL echo("***   BEG AGS_EXE_PHR_EXTRACT")
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
 DECLARE bs_length = i4 WITH protect, noconstant(0)
 DECLARE par_file_name = vc WITH protect, noconstant("")
 DECLARE working_batch_selection = vc WITH protect, noconstant("")
 DECLARE ipos = i4 WITH protect, noconstant(1)
 DECLARE npos = i4 WITH protect, noconstant(0)
 DECLARE spos = i4 WITH protect, noconstant(0)
 DECLARE field_name = vc WITH protect, noconstant("")
 DECLARE field_data = vc WITH protect, noconstant("")
 DECLARE testing_flag = i2 WITH protect, noconstant(0)
 DECLARE working_client_mnemonic = vc WITH protect, noconstant("")
 DECLARE working_job_id = f8 WITH protect, noconstant(0.0)
 CALL echo("***")
 CALL echo("***   BEG LOGGING")
 CALL echo("***")
 FREE RECORD email
 RECORD email(
   1 qual_knt = i4
   1 qual[*]
     2 address = vc
     2 send_flag = i2
 )
 DECLARE eknt = i4 WITH public, noconstant(0)
 FREE RECORD log
 RECORD log(
   1 qual_knt = i4
   1 qual[*]
     2 smsgtype = c12
     2 dmsg_dt_tm = dq8
     2 smsg = vc
 )
 DECLARE handle_logging(slog_file=vc,semail=vc,istatus_flag=i4) = null WITH protect
 DECLARE sstatus_file_name = vc WITH protect, noconstant(concat("ags_exe_phr_extract_",format(
    cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 DECLARE ilog_status = i2 WITH protect, noconstant(0)
 DECLARE sstatus_email = vc WITH protect, noconstant("")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_EXE_PHR_EXTRACT"
 CALL echo("***")
 CALL echo("***   BEG Parse Batch Selection")
 CALL echo("***")
 CALL echo("***")
 CALL echo(build("***   batch_selection :",request->batch_selection))
 CALL echo("***")
 SET bs_length = textlen(trim(request->batch_selection))
 IF (bs_length < 3)
  SET failed = input_error
  SET table_name = "BATCH_SELECTION"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("BATCH_SELECTION :: Invalid Length of less then 3 :: ",
   trim(request->batch_selection))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (cnvtupper(substring(1,10,request->batch_selection))="<PAR_FILE|")
  SET par_file_name = cnvtlower(trim(substring(11,(bs_length - 11),request->batch_selection)))
  CALL echo("***")
  CALL echo(build("***   par_file_name :",par_file_name))
  CALL echo("***")
  IF (findfile(value(par_file_name)))
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(nullterm(par_file_name))
   DEFINE rtl2 "file_loc"
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    the_line = r.line
    FROM rtl2t r
    HEAD REPORT
     working_batch_selection = trim(the_line)
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "READ PARAMETER FILE"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("READ PARAMETER FILE :: Select Error :: ",trim(serrmsg
      ))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
  ELSE
   SET failed = input_error
   SET table_name = "FIND PARAMETER FILE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("FIND PARAMETER FILE :: Input Error :: ",
    "Failed to find file :: ",trim(par_file_name))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
 ELSE
  SET working_batch_selection = trim(request->batch_selection)
 ENDIF
 CALL echo("***")
 CALL echo(build("***   working_batch_selection :",working_batch_selection))
 CALL echo("***")
 SET bs_length = textlen(trim(working_batch_selection))
 IF (bs_length <= 5)
  SET failed = input_error
  SET table_name = "WORKING_BATCH_SELECTION"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("PARSE WORKING_BATCH_SELECTION :: Parameter Error :: ",
   "Invalid WORKING_BATCH_SELECTION :: ",trim(working_batch_selection))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 WHILE (ipos < bs_length)
   SET ipos = findstring("<",working_batch_selection,ipos)
   IF (ipos < 1)
    SET failed = input_error
    SET table_name = "WORKING_BATCH_SELECTION"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("PARSE WORKING_BATCH_SELECTION :: Parameter Error :: ",
     "Invaild batch_selection string: '<' not present :: ",trim(working_batch_selection))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET npos = findstring(">",working_batch_selection,(ipos+ 1))
   IF (npos < 1)
    SET failed = input_error
    SET table_name = "WORKING_BATCH_SELECTION"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("PARSE WORKING_BATCH_SELECTION :: Parameter Error :: ",
     "Invaild batch_selection string: '>' not present :: ",trim(working_batch_selection))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET spos = findstring("|",working_batch_selection,(ipos+ 1))
   IF (spos < 1)
    SET failed = input_error
    SET table_name = "WORKING_BATCH_SELECTION"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("PARSE WORKING_BATCH_SELECTION :: Parameter Error :: ",
     "Invaild batch_selection string: '|' not present :: ",trim(working_batch_selection))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET field_name = trim(cnvtupper(substring((ipos+ 1),((spos - ipos) - 1),working_batch_selection)))
   SET field_data = trim(substring((spos+ 1),((npos - spos) - 1),working_batch_selection))
   CALL echo("***")
   CALL echo(build("***   FIELD_NAME :",field_name))
   CALL echo(build("***   FIELD_DATA :",field_data))
   CALL echo("***")
   IF ((( NOT (field_data > " ")) OR ( NOT (field_name > " "))) )
    SET failed = input_error
    SET table_name = "WORKING_BATCH_SELECTION"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("PARSE WORKING_BATCH_SELECTION :: Parameter Error :: ",
     "Invalid blank FIELD_DATA or FIELD_NAME :: FIELD_NAME :: ",trim(field_name)," :: FIELD_DATA :: ",
     trim(field_data))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   CASE (field_name)
    OF "EMAIL":
     SET sstatus_email = field_data
     SET eknt = (eknt+ 1)
     SET stat = alterlist(email->qual,eknt)
     SET email->qual_knt = eknt
     SET email->qual[eknt].address = field_data
    OF "SEND_FLAG":
     IF (eknt > 0)
      SET email->qual[eknt].send_flag = cnvtint(field_data)
     ENDIF
    OF "TEST_FLAG":
     SET testing_flag = cnvtint(field_data)
    OF "CLIENT_MNEMONIC":
     SET working_client_mnemonic = trim(cnvtupper(field_data))
    ELSE
     SET failed = input_error
     SET table_name = "WORKING_BATCH_SELECTION"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat(
      "PARSE WORKING_BATCH_SELECTION :: Parameter Error :: ",
      "Invaild batch_selection string: Unknown FIELD_NAME :: ",trim(field_name))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
   ENDCASE
   SET ipos = (npos+ 1)
 ENDWHILE
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("TESTING_FLAG :: ",trim(cnvtstring(testing_flag)))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("WORKING_CLIENT_MNEMONIC :: ",trim(
   working_client_mnemonic))
 FOR (eidx = 1 TO email->qual_knt)
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("EMAIL :: ",trim(email->qual[eidx].address),
    " SEND_FLAG :: ",trim(cnvtstring(email->qual[eidx].send_flag)))
 ENDFOR
 CALL echo("***")
 CALL echo("***   END Parse Batch Selection")
 CALL echo("***")
 IF (testing_flag < 1)
  SET trace = noechorecord
  SET trace = nocost
  SET trace = nocallecho
  SET message = noinformation
 ENDIF
 IF ( NOT (working_client_mnemonic > " "))
  SET failed = select_error
  SET table_name = "WORKING_CLIENT_MNEMONIC"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "INVALID BLANK WORKING_CLIENT_MNEMONIC"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Find Current PERSON JOB_ID")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> Find Current PERSON JOB_ID"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_job j,
   ags_task t
  PLAN (j
   WHERE j.status_dt_tm >= datetimeadd(cnvtdatetime(curdate,0),- (30))
    AND j.file_type="PERSON")
   JOIN (t
   WHERE t.ags_job_id=j.ags_job_id
    AND t.status="COMPLETE")
  ORDER BY j.run_nbr DESC, j.ags_job_id DESC
  HEAD REPORT
   working_job_id = j.ags_job_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET AGS_JOB_ID"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET AGS_JOB_ID :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> Find Current PERSON JOB_ID"
 CALL echo("***")
 CALL echo("***   END Find Current PERSON JOB_ID")
 CALL echo("***")
 IF (working_job_id > 0)
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "EXECUTING AGS_EXTRACT_PHR_MEMBERS"
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_JOB_ID : ",trim(cnvtstring(working_job_id)))
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("CLIENT_MNEMONIC : ",trim(working_client_mnemonic))
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DEBUG_MODE : ",trim(cnvtstring(testing_flag)))
  SET failed = false
  EXECUTE ags_extract_phr_members value(working_job_id), value(working_client_mnemonic), value(
   testing_flag)
  IF (failed != false)
   SET failed = select_error
   SET table_name = "AGS_EXTRACT_PHR_MEMBERS"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "ERROR EXECUTING AGS_EXTRACT_PHR_MEMBERS"
   GO TO exit_script
  ELSE
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = "SUCCESS EXECUTING AGS_EXTRACT_PHR_MEMBERS"
  ENDIF
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "AGS_JOB_ID NOT FOUND"
 ENDIF
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
    WITH nocounter, nullreport, formfeed = none,
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
#exit_script
 IF (failed != false)
  ROLLBACK
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
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_EXE_PHR_EXTRACT"
 CALL echo("***")
 CALL echo("***   END LOGGING")
 CALL echo("***")
 IF (testing_flag < 1)
  SET trace = echorecord
  SET trace = cost
  SET trace = callecho
  SET message = information
 ENDIF
 CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 CALL echo("***")
 CALL echo("***   END AGS_EXE_PHR_EXTRACT")
 CALL echo("***")
 SET script_ver = "001 01/20/06"
END GO
