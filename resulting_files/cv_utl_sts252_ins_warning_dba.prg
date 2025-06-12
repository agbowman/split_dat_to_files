CREATE PROGRAM cv_utl_sts252_ins_warning:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD internal
 RECORD internal(
   1 dataset_id = f8
   1 msg_illegal[*]
     2 xref_id = f8
   1 msg_illegal_long_text_id = f8
   1 msg_illegal_tool[*]
     2 xref_id = f8
   1 msg_illegal_tool_long_text_id = f8
   1 msg_reportwarn[*]
     2 xref_id = f8
   1 msg_reportwarn_long_text_id = f8
   1 msg_reportwarn_tool[*]
     2 xref_id = f8
   1 msg_reportwarn_tool_long_text_id = f8
   1 msg_report[*]
     2 xref_id = f8
   1 msg_report_long_text_id = f8
   1 msg_report_tool[*]
     2 xref_id = f8
   1 msg_report_tool_long_text_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE failure = c1 WITH protect, noconstant("F")
 DECLARE warning_on = c1 WITH protect, noconstant("F")
 DECLARE cnt = i4 WITH protect
 DECLARE err_message = vc WITH protect
 DECLARE the_new_line = vc WITH protect
 SET the_new_line = concat(char(13),char(10))
 DECLARE cv_log_my_files = i2 WITH protect, noconstant(1)
 CALL cv_log_message("get dataset_id")
 SELECT INTO "nl:"
  FROM cv_dataset d
  WHERE d.dataset_internal_name="STS03"
  DETAIL
   internal->dataset_id = d.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure attempting to retrieve dataset_id")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref cx
  SET cx.error_text_id = 0.0, cx.warning_text_id = 0.0
  WHERE cx.xref_internal_name="STS03_*"
 ;end update
 SELECT INTO "NL:"
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("STS03_VENDORID", "STS03_SOFTVRSN", "STS03_DATAVRSN",
  "STS03_RECORDID", "STS03_PATID")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_illegal,cnt), internal->msg_illegal[cnt].xref_id =
   x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 5)
  SET warning_on = "T"
  SET err_message = build("STS03 Illegal fields failed: expect (5), actual (",trim(cnvtstring(cnt),3),
   ")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   internal->msg_illegal_long_text_id = nextseqnum
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "It is illegal for this data to be missing, contact administrator to fix it!", l.parent_entity_id
    = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.active_ind = 1,
   l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), l.active_status_prsnl_id = reqinfo->updt_id,
   l.long_text_id = internal->msg_illegal_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text illegal message")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(internal->msg_illegal,5)))
  SET x.error_text_id = internal->msg_illegal_long_text_id
  PLAN (d1
   WHERE (internal->msg_illegal[d1.seq].xref_id != 0.0))
   JOIN (x
   WHERE (x.xref_id=internal->msg_illegal[d1.seq].xref_id))
  WITH nocounter
 ;end update
 SELECT INTO "NL:"
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name="STS03_PARTICID"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_illegal_tool,cnt), internal->msg_illegal_tool[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 1)
  SET warning_on = "T"
  SET err_message = build(err_message,"STS03_PARTICID failed: expect (1), actual (",trim(cnvtstring(
     cnt),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   internal->msg_illegal_tool_long_text_id = nextseqnum
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "It is illegal for this data to be missing, add it with Orgtool!", l.parent_entity_id = internal->
   dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.active_ind = 1,
   l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), l.active_status_prsnl_id = reqinfo->updt_id,
   l.long_text_id = internal->msg_illegal_tool_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text illegal message with tool!")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(internal->msg_illegal_tool,5)))
  SET x.error_text_id = internal->msg_illegal_tool_long_text_id
  PLAN (d1
   WHERE (internal->msg_illegal_tool[d1.seq].xref_id != 0.0))
   JOIN (x
   WHERE (x.xref_id=internal->msg_illegal_tool[d1.seq].xref_id))
  WITH nocounter
 ;end update
 SELECT INTO "NL:"
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.reqd_flag=30
   AND x.xref_internal_name != "STS03_AGE"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_reportwarn,cnt), internal->msg_reportwarn[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 9)
  SET warning_on = "T"
  SET err_message = build(err_message,"Report and Warn failed: expect (9), actual (",trim(cnvtstring(
     cnt),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   internal->msg_reportwarn_long_text_id = nextseqnum
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "Missing data may make the record unacceptable for analysis in the national database!", l
   .parent_entity_id = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.active_ind = 1,
   l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), l.active_status_prsnl_id = reqinfo->updt_id,
   l.long_text_id = internal->msg_reportwarn_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report and warn message")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(internal->msg_reportwarn,5)))
  SET x.warning_text_id = internal->msg_reportwarn_long_text_id
  PLAN (d1
   WHERE (internal->msg_reportwarn[d1.seq].xref_id != 0.0))
   JOIN (x
   WHERE (x.xref_id=internal->msg_reportwarn[d1.seq].xref_id))
  WITH nocounter
 ;end update
 SELECT INTO "NL:"
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name="STS03_AGE"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_reportwarn_tool,cnt), internal->
   msg_reportwarn_tool[cnt].xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 1)
  SET warning_on = "T"
  SET err_message = build(err_message,"STS03_AGE failed: expect (1), actual (",trim(cnvtstring(cnt),3
    ),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   internal->msg_reportwarn_tool_long_text_id = nextseqnum
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "Missing data may make the record unacceptable for analysis, add it with Pmhnareg tool!", l
   .parent_entity_id = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.active_ind = 1,
   l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), l.active_status_prsnl_id = reqinfo->updt_id,
   l.long_text_id = internal->msg_reportwarn_tool_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report and warn message with tool!")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(internal->msg_reportwarn_tool,5)))
  SET x.warning_text_id = internal->msg_reportwarn_tool_long_text_id
  PLAN (d1
   WHERE internal->msg_reportwarn_tool[d1.seq].xref_id)
   JOIN (x
   WHERE (x.xref_id=internal->msg_reportwarn_tool[d1.seq].xref_id))
  WITH nocounter
 ;end update
 SELECT INTO "NL:"
  x.xref_id
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("STS03_DOB", "STS03_HOSPNAME", "STS03_HOSPSTAT", "STS03_HOSPZIP",
  "STS03_MEDRECN",
  "STS03_PATFNAME", "STS03_PATLNAME", "STS03_PATZIP", "STS03_SSN")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_report_tool,cnt), internal->msg_report_tool[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 9)
  SET warning_on = "T"
  SET err_message = build(err_message,"PMHNAREG warning message failed: expect (9), actual (",trim(
    cnvtstring(cnt),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   internal->msg_report_tool_long_text_id = nextseqnum
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "Data is missing, add it with Pmhnareg tool!", l.parent_entity_id = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.active_ind = 1,
   l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), l.active_status_prsnl_id = reqinfo->updt_id,
   l.long_text_id = internal->msg_report_tool_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report message")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(internal->msg_report_tool,5)))
  SET x.warning_text_id = internal->msg_report_tool_long_text_id
  PLAN (d1
   WHERE (internal->msg_report_tool[d1.seq].xref_id != 0.0))
   JOIN (x
   WHERE (x.xref_id=internal->msg_report_tool[d1.seq].xref_id))
  WITH nocounter
 ;end update
 SELECT INTO "NL:"
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.warning_text_id=0.0
   AND x.error_text_id=0.0
   AND x.xref_internal_name != "STS03_PRED*"
   AND x.xref_internal_name != "STS03_PROCTYPE"
   AND x.reqd_flag > 0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_report,cnt), internal->msg_report[cnt].xref_id = x
   .xref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   internal->msg_report_long_text_id = nextseqnum
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text = "Data is missing!", l.parent_entity_id =
   internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.active_ind = 1,
   l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), l.active_status_prsnl_id = reqinfo->updt_id,
   l.long_text_id = internal->msg_report_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report message")
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_xref x,
   (dummyt d1  WITH seq = value(size(internal->msg_report,5)))
  SET x.warning_text_id = internal->msg_report_long_text_id
  PLAN (d1
   WHERE (internal->msg_report[d1.seq].xref_id != 0.0))
   JOIN (x
   WHERE (x.xref_id=internal->msg_report[d1.seq].xref_id))
  WITH nocounter
 ;end update
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
  CALL echo("*********************************")
  CALL echo("Update failed, action rollbacked!")
  CALL echo("*********************************")
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("*********************************")
  CALL echo("Update success, action committed!")
  CALL echo("*********************************")
 ENDIF
 IF (warning_on="T")
  CALL echo("Please copy and send the following message to Cerner")
  CALL echo(err_message)
  CALL echo("*********************************")
 ENDIF
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
 DECLARE cv_utl_sts252_ins_warning_vrsn = vc WITH private, constant("003 BM9013 05/09/2007")
END GO
