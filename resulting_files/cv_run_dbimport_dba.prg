CREATE PROGRAM cv_run_dbimport:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 file_name = vc
    1 info_line[*]
      2 new_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET infoname = "DM_ENV_ID"
 SET domain = "DATA MANAGEMENT"
 SET reply->status_data.status = "F"
 SET failure = "F"
 SET v5_connect = fillstring(60," ")
 CALL echorecord(request,"cer_Temp:cv_run_dbimportRequest.dat")
 IF (cursys != "AIX")
  SET reply->file_name = build("CVDBIMPORT",curtime,".com")
 ELSE
  SET reply->file_name = build("CVDBIMPORT",curtime,".ksh")
 ENDIF
 SELECT INTO "nl:"
  de.v500_connect_string
  FROM dm_info di,
   dm_environment de
  WHERE di.info_name=infoname
   AND di.info_domain=domain
   AND de.environment_id=di.info_number
  DETAIL
   v5_connect = de.v500_connect_string
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO database_connection_failed
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d1  WITH seq = value(size(request->file,5)))
  PLAN (d1
   WHERE (request->file[d1.seq].prog_cd > 0))
   JOIN (cv
   WHERE (cv.code_value=request->file[d1.seq].prog_cd)
    AND cv.active_ind=1)
  DETAIL
   request->file[d1.seq].prog_name = cv.definition
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(request->file,5))
   IF ((request->file[i].prog_cd > 0))
    SET out_file_name = fillstring(30," ")
    IF (cursys != "AIX")
     SET out_file_name = concat(request->file[i].prog_name,".com")
    ELSE
     SET out_file_name = concat(request->file[i].prog_name,".ksh")
    ENDIF
    SET dir_name = fillstring(80," ")
    IF (cursys != "AIX")
     SET dir_name = build("@CCLUSERDIR:",out_file_name)
    ELSE
     SET dir_name = build(". $CCLUSERDIR/",out_file_name)
    ENDIF
    SELECT INTO value(out_file_name)
     FROM dual
     HEAD REPORT
      IF (cursys="AIX")
       prn_string1 = fillstring(125," "), prn_string2 = fillstring(125," "), prn_string3 = fillstring
       (125," "),
       prn_string4 = fillstring(125," "), ttl_prn_string = fillstring(500," ")
      ENDIF
     DETAIL
      IF (cursys != "AIX")
       row + 1, col 0, "$DIMP :== $CER_EXE:DBIMPORT.EXE",
       row + 1, col 0, "$DIMP CER_INSTALL:",
       request->file[i].file_name, " 1 ", request->file[i].blocks_to_process,
       " 0 ", "ORACLE:", v5_connect,
       request->file[i].prog_name, col + 2, request->file[i].prog_name,
       "Log 2"
      ELSE
       prn_string1 = concat(request->file[i].file_name," 1"), prn_string2 = concat(" ",cnvtstring(
         request->file[i].blocks_to_process)," 0"," ORACLE:",v5_connect), prn_string3 = concat(" ",
        request->file[i].prog_name),
       prn_string4 = concat(" ",request->file[i].prog_name,"Log 2"), ttl_prn_string = build(
        "$cer_exe/dbimport $cer_install/",prn_string1,prn_string2,prn_string3,prn_string4), row + 1,
       col 0, ttl_prn_string
      ENDIF
     WITH nocounter, formfeed = none, maxrow = 1,
      maxcol = 512, format = variable
    ;end select
    SELECT INTO value(reply->file_name)
     *
     FROM dual
     DETAIL
      "$@", out_file_name, row + 1
     WITH nocounter, append
    ;end select
   ENDIF
 ENDFOR
 SET newmsg = build("Please run the following script on the backend under CCLUSERDIR:",reply->
  file_name)
 SET reply->file_name = newmsg
 GO TO exit_script
#database_connection_failed
 SET stat = alterlist(reply->status_data.subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationname = "database_connection"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname =
 "get the connection type from DM_ENVIRONMENT"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_run_dbimport"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 GO TO end_program
#end_program
 CALL echorecord(reply,"cer_Temp:cv_run_dbimportReply.dat")
END GO
