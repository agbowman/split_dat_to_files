CREATE PROGRAM ct_pt_mp_chg_prescreen_status:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 RECORD audit(
   1 pt_prot_prescreen_id = f8
   1 updt_dt_tm = dq8
   1 person_id = f8
 )
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
 FREE RECORD request
 IF (( $JSONREQUEST=""))
  CALL populate_subeventstatus_rec("REQUEST","F","ct_pt_mp_chg_prescreen_status",
   "Invalid JSON Request","reply")
  GO TO exit_script
 ENDIF
 SET stat = cnvtjsontorec( $JSONREQUEST)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE error_message = vc WITH protect
 DECLARE status_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE status_disp = c40 WITH protect, noconstant(fillstring(40," "))
 DECLARE status_dt_tm = vc WITH protect
 DECLARE status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE referral_person = vc WITH protect
 DECLARE syscancelcd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE participant_name = vc WITH protect, noconstant("")
 DECLARE prescreen_id_str = vc WITH protect, noconstant("")
 DECLARE lst_updt_dt_tm_str = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   referral_person = p.name_full_formatted
  WITH nocounter
 ;end select
 SET cnt = size(request->qual,5)
 FOR (idx = 1 TO cnt)
   DECLARE new_comment_text = vc WITH protect
   DECLARE reason_comment = vc WITH protect
   DECLARE full_comment_text = vc WITH protect
   SET status_cd = request->qual[idx].status_cd
   SELECT INTO "NL:"
    FROM pt_prot_prescreen pps
    WHERE (pps.pt_prot_prescreen_id=request->qual[idx].pt_prot_prescreen_id)
    DETAIL
     reason_comment = trim(pps.reason_text,2), audit->pt_prot_prescreen_id = pps.pt_prot_prescreen_id,
     audit->updt_dt_tm = pps.updt_dt_tm,
     audit->person_id = pps.person_id
    WITH nocounter, forupdate(pps)
   ;end select
   IF (curqual > 0)
    SET status_disp = uar_get_code_display(status_cd)
    SET status_mean = uar_get_code_meaning(status_cd)
    SET status_dt_tm = format(cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM:SS;;D")
    IF (status_cd != syscancelcd)
     SET full_comment_text = concat("(",trim(status_disp)," on ",trim(status_dt_tm)," by ",
      trim(referral_person),") ",trim(request->qual[idx].status_comment_text))
    ENDIF
    IF (reason_comment="")
     SET new_comment_text = full_comment_text
    ELSE
     SET new_comment_text = concat(full_comment_text,char(13),char(13),reason_comment)
    ENDIF
    CALL echo(new_comment_text)
    UPDATE  FROM pt_prot_prescreen pps
     SET pps.screening_status_cd = status_cd, pps.reason_text = new_comment_text, pps
      .referred_person_id =
      IF (status_mean="REFERRED") reqinfo->updt_id
      ELSE pps.referred_person_id
      ENDIF
      ,
      pps.referred_dt_tm =
      IF (status_mean="REFERRED") cnvtdatetime(sysdate)
      ELSE pps.referred_dt_tm
      ENDIF
      , pps.updt_dt_tm = cnvtdatetime(sysdate), pps.updt_id = reqinfo->updt_id,
      pps.updt_task = reqinfo->updt_task, pps.updt_applctx = reqinfo->updt_applctx, pps.updt_cnt = (
      pps.updt_cnt+ 1)
     WHERE (pps.pt_prot_prescreen_id=request->qual[idx].pt_prot_prescreen_id)
    ;end update
    IF (curqual=0)
     SET failed = "T"
     CALL echo("Failed to update row in pt_prot_prescreen table.")
     GO TO exit_script
    ENDIF
   ELSE
    SET failed = "T"
    CALL echo("Failed to lock row in pt_prot_prescreen table.")
    GO TO exit_script
   ENDIF
 ENDFOR
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
   SET lst_updt_dt_tm_str = build("LST_UPDT_DT_TM: ",datetimezoneformat(audit->updt_dt_tm,0,
     "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
   SET prescreen_id_str = build3(3,"PT_PROTOCOL_PRESCREEN_ID: ",audit->pt_prot_prescreen_id)
   SET participant_name = concat(prescreen_id_str," ",lst_updt_dt_tm_str," (UPDT_DT_TM)")
   EXECUTE cclaudit audit_mode, "Prescreened_Status", "Modify",
   "Person", "Patient", "Patient",
   "Amendment", audit->person_id, participant_name
  ENDIF
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
#exit_script
 CALL echorecord(reply)
 CALL putjsonrecordtofile(reply)
 SET last_mod = "000"
 SET mod_date = "July 22, 2019"
END GO
