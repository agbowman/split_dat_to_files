CREATE PROGRAM ags_import_data_files:dba
 CALL echo("***")
 CALL echo("***   BEG AGS_IMPORT_DATA_FILES")
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
 IF ( NOT (validate(reply,0)))
  FREE RECORD reply
  RECORD reply(
    1 ags_job_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD data_info
 RECORD data_info(
   1 sending_system = vc
   1 directory = vc
   1 imp_file = vc
   1 full_imp_path_file = vc
   1 sql_ctl = vc
   1 file_type = vc
   1 email = vc
   1 task_cleanup_prog = vc
   1 imp_file_flag = i2
   1 check_date = vc
   1 ags_job_id = f8
   1 test_flag = i2
   1 task_size = i4
   1 eof_line = vc
   1 record_knt = i4
   1 run_nbr = i4
 )
 FREE RECORD ctl_rec
 RECORD ctl_rec(
   1 qual_knt = i4
   1 qual[*]
     2 a_line = vc
 )
 DECLARE file_path_name = vc WITH public, noconstant(" ")
 DECLARE cmd_line = vc WITH public, noconstant(" ")
 DECLARE cmd_status = i4 WITH public, noconstant(0)
 DECLARE bs_length = i4 WITH public, noconstant(0)
 DECLARE par_file_name = vc WITH public, noconstant("")
 DECLARE working_batch_selection = vc WITH public, noconstant("")
 DECLARE ipos = i4 WITH protect, noconstant(1)
 DECLARE npos = i4 WITH protect, noconstant(0)
 DECLARE spos = i4 WITH protect, noconstant(0)
 DECLARE field_name = vc WITH protect, noconstant("")
 DECLARE field_data = vc WITH protect, noconstant("")
 DECLARE default_task_size = i4 WITH public, constant(1000000)
 DECLARE continue = i2 WITH public, noconstant(true)
 DECLARE beg_spos = i4 WITH public, noconstant(0)
 DECLARE end_spos = i4 WITH public, noconstant(0)
 DECLARE prv_spos = i4 WITH public, noconstant(0)
 DECLARE cma_spos = i4 WITH public, noconstant(0)
 DECLARE cma_knt = i4 WITH public, noconstant(1)
 DECLARE temp_line = vc WITH public, noconstant("")
 DECLARE working_ctl_file = vc WITH public, noconstant("")
 DECLARE ctl_log_file = vc WITH public, noconstant("")
 DECLARE default_oracle_usr_pwd = vc WITH public, constant("v500/v500")
 DECLARE the_oracle_usr_pwd = vc WITH public, noconstant("v500/v500")
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
 DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_import_data_files_",format(
    cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 DECLARE ilog_status = i2 WITH public, noconstant(0)
 DECLARE sstatus_email = vc WITH public, noconstant("")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_IMPORT_DATA_FILES"
 CALL echo("***")
 CALL echo("***   PARSE BATCH_SELECTION")
 CALL echo("***")
 CALL echo("***")
 CALL echo(build("***   batch_selection :",request->batch_selection))
 CALL echo("***")
 SET bs_length = textlen(trim(request->batch_selection))
 IF (bs_length < 11)
  SET failed = input_error
  SET table_name = "REQUEST->BATCH_SELECTION"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("PARSE BATCH_SELECTION :: Parameter Error :: ",
   "Invalid BATCH_SELECTION :: ",trim(request->batch_selection))
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
    OF "SENDING_SYSTEM":
     SET data_info->sending_system = cnvtupper(field_data)
    OF "DIRECTORY":
     SET data_info->directory = field_data
    OF "IMP_FILE":
     SET data_info->imp_file = field_data
    OF "FULL_IMP_PATH_FILE":
     SET data_info->full_imp_path_file = field_data
    OF "SQL_CTL":
     SET data_info->sql_ctl = field_data
    OF "FILE_TYPE":
     SET data_info->file_type = cnvtupper(field_data)
    OF "EMAIL":
     SET data_info->email = field_data
     SET sstatus_email = data_info->email
     SET eknt = (eknt+ 1)
     SET stat = alterlist(email->qual,eknt)
     SET email->qual_knt = eknt
     SET email->qual[eknt].address = field_data
    OF "SEND_FLAG":
     IF (eknt > 0)
      SET email->qual[eknt].send_flag = cnvtint(field_data)
     ENDIF
    OF "TASK_CLEANUP_PROG":
     SET data_info->task_cleanup_prog = cnvtupper(field_data)
    OF "TEST_FLAG":
     SET data_info->test_flag = cnvtint(field_data)
    OF "TASK_SIZE":
     SET data_info->task_size = cnvtint(field_data)
    OF "ORACAL_USR_PWD":
     SET the_oracle_usr_pwd = trim(cnvtlower(field_data))
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
 SET sstatus_file_name = concat("ags_import_",trim(cnvtlower(data_info->sending_system)),"_",trim(
   cnvtlower(data_info->file_type)),"_",
  format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMM;;Q"),".log")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("SENDING_SYSTEM :: ",trim(data_info->sending_system))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("DIRECTORY :: ",trim(data_info->directory))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("IMP_FILE :: ",trim(data_info->imp_file))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("FULL_IMP_PATH_FILE :: ",trim(data_info->
   full_imp_path_file))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("SQL_CTL :: ",trim(data_info->sql_ctl))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("FILE_TYPE :: ",trim(data_info->file_type))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("TASK_CLEANUP_PROG :: ",trim(data_info->task_cleanup_prog
   ))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("TEST_FLAG :: ",trim(cnvtstring(data_info->test_flag)))
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("ORACLE_USR_PWD :: ",trim(the_oracle_usr_pwd))
 IF ((data_info->task_size < 1))
  SET data_info->task_size = default_task_size
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("TASK_SIZE :: ",trim(cnvtstring(data_info->task_size)))
 FOR (eidx = 1 TO email->qual_knt)
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("EMAIL :: ",trim(email->qual[eidx].address),
    " SEND_FLAG :: ",trim(cnvtstring(email->qual[eidx].send_flag)))
 ENDFOR
 IF ( NOT ((data_info->sending_system > " ")))
  SET failed = input_error
  SET table_name = "SENDING_SYSTEM"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID SENDING_SYSTEM :: Parameter Error :: ",trim(
    data_info->sending_system))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT ((data_info->directory > " ")))
  SET failed = input_error
  SET table_name = "DIRECTORY"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID DIRECTORY :: Parameter Error :: ",trim(
    data_info->directory))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT ((data_info->imp_file > " ")))
  SET failed = input_error
  SET table_name = "IMP_FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID IMP_FILE :: Parameter Error :: ",trim(data_info
    ->imp_file))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT ((data_info->full_imp_path_file > " ")))
  SET failed = input_error
  SET table_name = "FULL_IMP_PATH_FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID FULL_IMP_PATH_FILE :: Parameter Error :: ",trim
   (data_info->full_imp_path_file))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT ((data_info->sql_ctl > " ")))
  SET failed = input_error
  SET table_name = "SQL_CTL"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID SQL_CTL :: Parameter Error :: ",trim(data_info
    ->sql_ctl))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT ((data_info->file_type > " ")))
  SET failed = input_error
  SET table_name = "FILE_TYPE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID FILE_TYPE :: Parameter Error :: ",trim(
    data_info->file_type))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT ((data_info->task_cleanup_prog > " ")))
  SET failed = input_error
  SET table_name = "TASK_CLEANUP_PROG"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID TASK_CLEANUP_PROG :: Parameter Error :: ",trim(
    data_info->task_cleanup_prog))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (( NOT (the_oracle_usr_pwd) > " "))
  SET the_oracle_usr_pwd = default_oracle_usr_pwd
 ENDIF
 SET file_path_name = " "
 SET file_path_name = data_info->full_imp_path_file
 CALL echo("***")
 CALL echo(build("***   file_path_name :",file_path_name))
 CALL echo("***")
 SET data_info->imp_file_flag = findfile(value(file_path_name))
 IF ((data_info->imp_file_flag=0))
  SET failed = input_error
  SET table_name = "FIND IMPORT FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("FIND IMPORT DATA FILE :: Input Error :: ",
   "Failed to find file :: ",trim(file_path_name))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   GET CHECK_DATE")
 CALL echo("***")
 FREE DEFINE rtl2
 FREE SET file_loc
 SET logical file_loc value(nullterm(file_path_name))
 DEFINE rtl2 "file_loc"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM rtl2t r
  HEAD REPORT
   x = 1
  DETAIL
   x = 1
  FOOT REPORT
   data_info->eof_line = cnvtlower(trim(r.line))
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET CHECK_DATE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET CHECK_DATE :: Script Failure :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   eof_line :",data_info->eof_line))
 CALL echo("***")
 SET beg_spos = findstring("eof",data_info->eof_line)
 IF (beg_spos < 1)
  SET failed = input_error
  SET table_name = "PARSE EOF LINE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "PARSE EOF LINE :: Input Failure :: Couldn't find EOF line"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET cma_spos = findstring(",",data_info->eof_line,1,0)
 IF (cma_spos < 1)
  SET failed = input_error
  SET table_name = "PARSE EOF LINE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
  SET serrmsg = log->qual[log->qual_knt].smsg
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
  GO TO exit_script
 ENDIF
 SET continue = true
 WHILE (cma_spos > 0
  AND continue=true)
   SET beg_spos = (cma_spos+ 1)
   SET cma_spos = findstring(",",data_info->eof_line,beg_spos,0)
   IF (cma_spos > 0)
    SET cma_knt = (cma_knt+ 1)
    IF (cma_knt=4)
     SET continue = false
    ENDIF
   ELSE
    SET continue = false
   ENDIF
 ENDWHILE
 IF (cma_knt=4)
  SET beg_spos = (cma_spos+ 1)
  SET cma_spos = findstring(",",data_info->eof_line,beg_spos,0)
  SET cma_knt = (cma_knt+ 1)
  IF (cma_spos < 1)
   SET failed = input_error
   SET table_name = "PARSE EOF LINE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg =
   "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
   SET serrmsg = log->qual[log->qual_knt].smsg
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
   GO TO exit_script
  ENDIF
  SET end_spos = (cma_spos - 1)
  IF (isnumeric(substring(beg_spos,1,data_info->eof_line))=0)
   SET beg_spos = (beg_spos+ 1)
   IF (isnumeric(substring(beg_spos,1,data_info->eof_line))=0)
    SET failed = input_error
    SET table_name = "PARSE EOF LINE"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg =
    "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
    SET serrmsg = log->qual[log->qual_knt].smsg
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
    GO TO exit_script
   ENDIF
  ELSE
   SET beg_spos = beg_spos
  ENDIF
  IF (isnumeric(substring(end_spos,1,data_info->eof_line))=0)
   SET end_spos = (end_spos - 1)
   IF (isnumeric(substring(end_spos,1,data_info->eof_line))=0)
    SET failed = input_error
    SET table_name = "PARSE EOF LINE"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg =
    "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
    SET serrmsg = log->qual[log->qual_knt].smsg
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
    GO TO exit_script
   ENDIF
  ELSE
   SET end_spos = end_spos
  ENDIF
  IF (isnumeric(substring(beg_spos,((end_spos - beg_spos)+ 1),data_info->eof_line))=0)
   SET failed = input_error
   SET table_name = "PARSE EOF LINE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg =
   "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
   SET serrmsg = log->qual[log->qual_knt].smsg
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
   GO TO exit_script
  ELSE
   SET data_info->record_knt = cnvtint(trim(substring(beg_spos,((end_spos - beg_spos)+ 1),data_info->
      eof_line)))
  ENDIF
  SET beg_spos = (cma_spos+ 1)
  IF (isnumeric(substring(beg_spos,8,data_info->eof_line))=0)
   SET beg_spos = (beg_spos+ 1)
   IF (isnumeric(substring(beg_spos,8,data_info->eof_line))=0)
    SET failed = input_error
    SET table_name = "PARSE EOF LINE"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg =
    "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
    SET serrmsg = log->qual[log->qual_knt].smsg
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
    GO TO exit_script
   ENDIF
  ELSE
   SET beg_spos = beg_spos
  ENDIF
  SET data_info->check_date = substring(beg_spos,8,data_info->eof_line)
  SET data_info->run_nbr = cnvtint(trim(data_info->check_date))
 ELSE
  SET failed = input_error
  SET table_name = "PARSE EOF LINE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "PARSE EOF LINE :: Input Failure :: EOF line not formatted correctly"
  SET serrmsg = log->qual[log->qual_knt].smsg
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("eof_line :: ",trim(data_info->eof_line))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_job j
  PLAN (j
   WHERE (j.sending_system=data_info->sending_system)
    AND (j.filename=data_info->imp_file)
    AND (j.check_date=data_info->check_date)
    AND (j.record_count=data_info->record_knt)
    AND j.status != "PURGED")
  DETAIL
   data_info->imp_file_flag = 2
  WITH nocounter, maxqual(j,1)
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET LOAD STATUS"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET LOAD STATUS :: Script Failure :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ((data_info->imp_file_flag=2))
  SET ilog_status = 2
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "WARNING"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("IMPORT DATA FILE :: Already Loaded :: ",trim(
    file_path_name))
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   INSERT JOB DATA")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  num = seq(gs_seq,nextval)
  FROM dual
  DETAIL
   data_info->ags_job_id = cnvtreal(num)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = gen_nbr_error
  SET table_name = "GET NEW AGS_JOB_ID"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET NEW AGS_JOB_ID :: Script Failure :: ",trim(serrmsg)
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM ags_job j
  SET j.ags_job_id = data_info->ags_job_id, j.sending_system = data_info->sending_system, j.filename
    = data_info->imp_file,
   j.check_date = data_info->check_date, j.record_count = data_info->record_knt, j.file_type =
   data_info->file_type,
   j.run_dt_tm = cnvtdatetime(curdate,curtime3), j.run_nbr = data_info->run_nbr, j.status = "LOADING",
   j.status_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = insert_error
  SET table_name = "GET NEW AGS_JOB_ID"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("Insert New Job :: Script Failure :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo("***   FIND CONTROL FILE")
 CALL echo("***")
 IF (findfile(value(data_info->sql_ctl))=0)
  SET failed = input_error
  SET table_name = "FIND CONTROL FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("FIND CONTROL FILE :: Input Error :: ",
   "Failed to find file :: ",trim(data_info->sql_ctl))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   LOAD IMPORT DATA")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("BEG >> Loading ",trim(data_info->sending_system)," ",
  trim(data_info->imp_file)," ",
  trim(data_info->check_date)," AGS_JOB_ID : ",trim(cnvtstring(data_info->ags_job_id)))
 SET file_path_name = " "
 SET file_path_name = trim(data_info->sql_ctl)
 FREE DEFINE rtl2
 FREE SET file_loc
 SET logical file_loc value(nullterm(file_path_name))
 DEFINE rtl2 "file_loc"
 CALL echo("***")
 CALL echo(build("***  Primary CTL File :",file_path_name))
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM rtl2t r
  HEAD REPORT
   rknt = 0, stat = alterlist(ctl_rec->qual,10)
  DETAIL
   rknt = (rknt+ 1)
   IF (mod(rknt,10)=1
    AND rknt != 1)
    tat = alterlist(ctl_rec->qual,(rknt+ 9))
   ENDIF
   temp_line = trim(r.line), pos = 0, pos = findstring("YYYYMMDD",temp_line,1,0)
   IF (pos > 0)
    temp_line = replace(temp_line,"YYYYMMDD",trim(data_info->check_date))
   ENDIF
   pos = 0, pos = findstring("CONSTANT JOB_ID",temp_line,1,0)
   IF (pos > 0)
    temp_line = replace(temp_line,"CONSTANT JOB_ID",concat("CONSTANT ",trim(cnvtstring(data_info->
        ags_job_id))))
   ENDIF
   ctl_rec->qual[rknt].a_line = temp_line
  FOOT REPORT
   ctl_rec->qual_knt = rknt, stat = alterlist(ctl_rec->qual,rknt)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "READ CTL FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("READ CTL FILE :: Script Failure :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ((ctl_rec->qual_knt < 1))
  SET failed = input_error
  SET table_name = "READ CTL FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("READ CTL FILE :: Input Error :: Empty File",trim(
    file_path_name))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET file_path_name = ""
 IF (cursys="AIX")
  SET file_path_name = concat(trim(data_info->directory),"/working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   "1.ctl")
 ELSE
  SET file_path_name = concat(trim(data_info->directory),"working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   "1.ctl;*")
 ENDIF
 SET stat = remove(file_path_name)
 IF (cursys="AIX")
  SET file_path_name = concat(trim(data_info->directory),"/working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   "2.ctl")
 ELSE
  SET file_path_name = concat(trim(data_info->directory),"working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   "2.ctl;*")
 ENDIF
 SET stat = remove(file_path_name)
 IF (cursys="AIX")
  SET file_path_name = concat(trim(data_info->directory),"/working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   ".ctl")
 ELSE
  SET file_path_name = concat(trim(data_info->directory),"working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   ".ctl;*")
 ENDIF
 CALL echo("***")
 CALL echo(build("***   Remove Previous Working CTL File :",file_path_name))
 CALL echo("***")
 SET stat = remove(file_path_name)
 SET working_ctl_file = ""
 IF (cursys="AIX")
  SET working_ctl_file = concat(trim(data_info->directory),"/working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   ".ctl")
 ELSE
  SET working_ctl_file = concat(trim(data_info->directory),"working_",trim(cnvtlower(data_info->
     sending_system)),"_",trim(cnvtlower(data_info->file_type)),
   ".ctl")
 ENDIF
 CALL echo("***")
 CALL echo(build("***   Build Working CTL File :",working_ctl_file))
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO value(working_ctl_file)
  FROM (dummyt d  WITH seq = value(ctl_rec->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
  DETAIL
   col 0, ctl_rec->qual[d.seq].a_line, row + 1
  WITH nocounter, nullreport, formfeed = none,
   format = crstream, maxcol = 255, maxrow = 1
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "MAKE WORKING CTL FILE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("MAKE WORKING CTL FILE :: Script Failure :: ",trim(
    serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET ctl_log_file = ""
 IF (cursys="AIX")
  SET ctl_log_file = concat(trim(data_info->directory),"/",trim(cnvtlower(data_info->file_type)),
   "_import_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDD;;Q"),
   ".log")
  SET cmd_line = concat("$ORACLE_HOME/bin/sqlldr ",trim(the_oracle_usr_pwd)," control=",trim(
    working_ctl_file)," log=",
   trim(ctl_log_file))
 ELSE
  SET ctl_log_file = concat(trim(data_info->directory),trim(cnvtlower(data_info->file_type)),
   "_import_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDD;;Q"),".log")
  SET cmd_line = "@oracle_home:orauser.com"
  CALL dcl(cmd_line,size(cmd_line),cmd_status)
  SET cmd_line = concat("sqlldr ",trim(the_oracle_usr_pwd)," control=",trim(working_ctl_file)," log=",
   trim(ctl_log_file))
 ENDIF
 CALL echo("***")
 CALL echo(build("***   cmd_line :",cmd_line))
 CALL echo("***")
 CALL dcl(cmd_line,size(cmd_line),cmd_status)
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("END >> Loading ",trim(data_info->sending_system)," ",
  trim(data_info->imp_file)," ",
  trim(data_info->check_date)," AGS_JOB_ID : ",trim(cnvtstring(data_info->ags_job_id)))
 CALL echo("***")
 CALL echo("***   Create Tasks")
 CALL echo("***")
 CALL parser(concat("execute ",trim(data_info->task_cleanup_prog)," go"))
 IF (failed != false)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_task t
   PLAN (t
    WHERE (t.ags_job_id=data_info->ags_job_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = delete_error
   SET table_name = "AGS_TASK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("DELETE AGS_TASK ITEMS :: DELETE Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_job j
   PLAN (j
    WHERE (j.ags_job_id=data_info->ags_job_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = delete_error
   SET table_name = "AGS_JOB"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("DELETE AGS_JOB ITEMS :: DELETE Error :: ",trim(serrmsg
     ))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   UPDATE JOB/TASK DATA")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_task t
  SET t.status = "WAITING", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (t
   WHERE (t.ags_job_id=data_info->ags_job_id)
    AND t.status="LOADING")
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE AGS_TASK ITEMS :: Update Error :: ",trim(serrmsg
    ))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_job j
  SET j.status = "WAITING", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (j
   WHERE (j.ags_job_id=data_info->ags_job_id)
    AND j.status="LOADING")
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET table_name = "AGS_JOB"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE AGS_JOB ITEMS :: Update Error :: ",trim(serrmsg)
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 SET reply->ags_job_id = data_info->ags_job_id
 IF ((data_info->test_flag < 1))
  SET file_path_name = ""
  IF (cursys="AIX")
   SET file_path_name = trim(data_info->full_imp_path_file)
  ELSE
   SET file_path_name = concat(trim(data_info->full_imp_path_file),";*")
  ENDIF
  CALL echo("***")
  CALL echo(build("***   remove :",file_path_name))
  CALL echo("***")
  SET stat = remove(file_path_name)
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
  SET reply->ags_job_id = 0.0
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_IMPORT_DATA_FILES"
 CALL echo("***")
 CALL echo("***   END LOGGING")
 CALL echo("***")
 CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
#end_program
 CALL echorecord(data_info)
 CALL echo("***")
 CALL echo("***   END AGS_IMPORT_DATA_FILES")
 CALL echo("***")
 SET script_ver = "005 04/26/06"
END GO
