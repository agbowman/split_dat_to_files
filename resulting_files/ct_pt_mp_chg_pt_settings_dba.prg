CREATE PROGRAM ct_pt_mp_chg_pt_settings:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 RECORD reply(
   1 not_interested_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putunboundedstringtofile(trec=vc(ref)) =null WITH protect)
   CALL log_message("In PutUnboundedStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE curstringlength = i4 WITH noconstant(textlen(trec->val))
   DECLARE newmaxvarlen = i4 WITH noconstant(0)
   DECLARE origcurmaxvarlen = i4 WITH noconstant(0)
   IF (curstringlength > curmaxvarlen)
    SET origcurmaxvarlen = curmaxvarlen
    SET newmaxvarlen = (curstringlength+ 10000)
    SET modify maxvarlen newmaxvarlen
   ENDIF
   CALL putstringtofile(trec->val)
   IF (newmaxvarlen > 0)
    SET modify maxvarlen origcurmaxvarlen
   ENDIF
   CALL log_message(build("Exit PutUnboundedStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (validate(_memory_reply_string)=1)
    SET _memory_reply_string = svalue
   ELSE
    FREE RECORD putrequest
    RECORD putrequest(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putrequest->source_dir =  $OUTDEV
    SET putrequest->isblob = "1"
    SET putrequest->document = svalue
    SET putrequest->document_size = size(putrequest->document)
    EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   ENDIF
   CALL log_message(build("Exit PutStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (populatereplywitherrormessageifany(reply=vc(ref)) =vc)
   DECLARE errormessage = vc
   DECLARE temperrormessage = vc
   DECLARE errorcode = i4 WITH noconstant(1)
   WHILE (errorcode != 0)
    SET errorcode = error(temperrormessage,0)
    IF (errorcode != 0)
     SET errormessage = concat(errormessage,"ErrorSeperator",temperrormessage)
    ENDIF
   ENDWHILE
   IF ( NOT (trim(errormessage)=""))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Execution"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errormessage
   ENDIF
   RETURN(errormessage)
 END ;Subroutine
 IF (( $JSONREQUEST=""))
  CALL populate_subeventstatus_rec("REQUEST","F","ct_pt_mp_chg_pt_settings","Invalid JSON Request",
   "reply")
  GO TO exit_script
 ENDIF
 SET stat = cnvtjsontorec( $JSONREQUEST)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE add_ind = i2 WITH protect, noconstant(0)
 DECLARE error_message = vc WITH protect
 DECLARE interest_add_ind = i2 WITH protect, noconstant(0)
 DECLARE participant_name = vc WITH protect, noconstant("")
 DECLARE settings_id_str = vc WITH protect, noconstant("")
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE last_interest_updt_dt_tm = dq8 WITH protect
 DECLARE lst_updt_dt_tm_str = vc WITH protect, noconstant("")
 DECLARE ct_pt_settings_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM ct_pt_settings cts
  WHERE (cts.person_id=person->person_id)
   AND cts.active_ind=1
  DETAIL
   last_interest_updt_dt_tm = cts.not_interested_dt_tm, ct_pt_settings_id = cts.ct_pt_settings_id
  WITH nocounter, forupdatewait(cts)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM ct_pt_settings cts
   SET cts.active_ind = 0, cts.updt_dt_tm = cnvtdatetime(sysdate), cts.updt_id = reqinfo->updt_id,
    cts.updt_task = reqinfo->updt_task, cts.updt_applctx = reqinfo->updt_applctx, cts.updt_cnt = (cts
    .updt_cnt+ 1)
   WHERE cts.ct_pt_settings_id=ct_pt_settings_id
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL echo("Failed to update row in ct_pt_settings table.")
   GO TO error_check
  ELSE
   SET add_ind = 1
  ENDIF
 ELSE
  SET add_ind = 1
  SET interest_add_ind = 1
 ENDIF
 IF (add_ind=1)
  INSERT  FROM ct_pt_settings cts
   SET cts.ct_pt_settings_id = seq(protocol_def_seq,nextval), cts.person_id = person->person_id, cts
    .not_interested_ind = person->not_interested_ind,
    cts.not_interested_dt_tm = cnvtdatetime(sysdate), cts.not_interested_prsnl_id = reqinfo->updt_id,
    cts.interest_option_cd = person->interest_option_cd,
    cts.updt_dt_tm = cnvtdatetime(sysdate), cts.updt_id = reqinfo->updt_id, cts.updt_task = reqinfo->
    updt_task,
    cts.updt_applctx = reqinfo->updt_applctx, cts.updt_cnt = 0, cts.active_ind = 1
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL echo("Failed to insert row in ct_pt_settings table.")
   GO TO error_check
  ENDIF
 ENDIF
 SET reply->not_interested_dt_tm = cnvtdatetime(sysdate)
#error_check
 SET reqinfo->commit_ind = 0
 SET error_message = populatereplywitherrormessageifany(reply)
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (trim(error_message)="")
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   COMMIT
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(reply)
 CALL putjsonrecordtofile(reply)
 IF ((reply->status_data.status="S"))
  IF (interest_add_ind=1)
   EXECUTE cclaudit audit_mode, "Prescreen_Interest_Add", "Add",
   "Person", "Patient", "Patient",
   "Origination / Creation", person->person_id, ""
  ELSE
   SET lst_updt_dt_tm_str = build("LST_UPDT_DT_TM: ",datetimezoneformat(last_interest_updt_dt_tm,0,
     "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
   SET settings_id_str = build3(3,"CT_PT_SETTINGS_ID: ",ct_pt_settings_id)
   SET participant_name = concat(settings_id_str," ",lst_updt_dt_tm_str," (UPDT_DT_TM)")
   EXECUTE cclaudit audit_mode, "PS_Interest_Change", "Modify",
   "Person", "Patient", "Patient",
   "Amendment", person->person_id, participant_name
  ENDIF
 ENDIF
 SET last_mod = "000"
 SET mod_date = "July 22, 2019"
END GO
