CREATE PROGRAM ct_pt_mp_get_pt_settings:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 RECORD reply(
   1 not_interested_ind = i2
   1 interest_option_cd = f8
   1 change_interest_privilege_ind = i2
   1 prescreen_privilege_ind = i2
   1 default_interest_ind = i2
   1 interest_options[*]
     2 interest_cd = f8
     2 interest_disp = vc
     2 interest_mean = vc
   1 last_comment_txt = vc
   1 last_comment_prsnl_name = vc
   1 last_comment_add_dt_tm = dq8
   1 last_comment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD codeset_request(
   1 codeset = i4
 )
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
   1 pref_value = i4
   1 pref_values[*]
     2 values = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD privsrequest(
   1 patient_user_criteria
     2 user_id = f8
     2 patient_user_relationship_cd = f8
   1 privilege_criteria
     2 privileges[*]
       3 privilege_cd = f8
     2 locations[*]
       3 location_id = f8
 )
 RECORD privsreply(
   1 patient_user_information
     2 user_id = f8
     2 patient_user_relationship_cd = f8
     2 role_id = f8
   1 privileges[*]
     2 privilege_cd = f8
     2 default[*]
       3 granted_ind = i2
       3 exceptions[*]
         4 entity_name = vc
         4 type_cd = f8
         4 id = f8
       3 status
         4 success_ind = i2
     2 locations[*]
       3 location_id = f8
       3 privilege
         4 granted_ind = i2
         4 exceptions[*]
           5 entity_name = vc
           5 type_cd = f8
           5 id = f8
         4 status
           5 success_ind = i2
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
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
  CALL populate_subeventstatus_rec("REQUEST","F","ct_pt_mp_get_pt_settings","Invalid JSON Request",
   "reply")
  GO TO exit_script
 ENDIF
 SET stat = cnvtjsontorec( $JSONREQUEST)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE interested_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notinterested_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prescreen_interest_privilege_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,
   "PRESCREENIN"))
 DECLARE prescreen_privilege_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,
   "PRESCREEN"))
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE person_id = f8 WITH protect, constant(person->person_id)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE options_cnt = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET bstat = uar_get_meaning_by_codeset(17910,"INTERESTED",1,interested_cd)
 SET bstat = uar_get_meaning_by_codeset(17910,"NOTINTEREST",1,notinterested_cd)
 SET privsrequest->patient_user_criteria.user_id = person->provider_id
 SET stat = alterlist(privsrequest->privilege_criteria.privileges,2)
 SET privsrequest->privilege_criteria.privileges[1].privilege_cd = prescreen_interest_privilege_cd
 SET privsrequest->privilege_criteria.privileges[2].privilege_cd = prescreen_privilege_cd
 EXECUTE mp_get_privs_by_codes  WITH replace("REQUEST","PRIVSREQUEST"), replace("REPLY","PRIVSREPLY")
 SET cnt = size(privsreply->privileges,5)
 FOR (idx = 1 TO cnt)
   IF (size(privsreply->privileges[idx].default,5) > 0)
    IF ((privsreply->privileges[idx].privilege_cd=prescreen_interest_privilege_cd))
     SET reply->change_interest_privilege_ind = privsreply->privileges[idx].default[1].granted_ind
    ELSEIF ((privsreply->privileges[idx].privilege_cd=prescreen_privilege_cd))
     SET reply->prescreen_privilege_ind = privsreply->privileges[idx].default[1].granted_ind
    ENDIF
   ENDIF
 ENDFOR
 SET ct_get_pref_request->pref_entry = "default_interest"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
  "CT_GET_PREF_REPLY")
 CALL echo(build("default interest:",ct_get_pref_reply->pref_value))
 SET reply->default_interest_ind = ct_get_pref_reply->pref_value
 SET codeset_request->codeset = 17910
 SET stat = tdbexecute(5000,5000,6022,"REC",codeset_request,
  "REC",codeset_reply)
 SET cnt = size(codeset_reply->codesetlist,5)
 FOR (idx = 1 TO cnt)
   IF (trim(codeset_reply->codesetlist[idx].meaning) != "")
    SET options_cnt += 1
    IF (options_cnt > size(reply->interest_options,5))
     SET stat = alterlist(reply->interest_options,(options_cnt+ 9))
    ENDIF
    SET reply->interest_options[options_cnt].interest_cd = codeset_reply->codesetlist[idx].code
    SET reply->interest_options[options_cnt].interest_disp = codeset_reply->codesetlist[idx].display
    SET reply->interest_options[options_cnt].interest_mean = codeset_reply->codesetlist[idx].meaning
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->interest_options,options_cnt)
 CALL echorecord(codeset_reply)
 SELECT INTO "nl:"
  FROM pt_interest_comment pic,
   prsnl p
  WHERE pic.comment_added_prsnl_id=p.person_id
   AND pic.person_id=person_id
   AND pic.active_ind=1
  ORDER BY pic.comment_added_dt_tm DESC
  DETAIL
   reply->last_comment_add_dt_tm = pic.comment_added_dt_tm, reply->last_comment_txt = pic.comment_txt,
   reply->last_comment_prsnl_name = p.name_full_formatted,
   reply->last_comment_id = pic.pt_interest_comment_id
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "NL:"
  FROM ct_pt_settings cts
  WHERE (cts.person_id=person->person_id)
   AND cts.active_ind=1
  DETAIL
   reply->not_interested_ind = cts.not_interested_ind, reply->interest_option_cd = cts
   .interest_option_cd
   IF (cts.interest_option_cd=0)
    IF (cts.not_interested_ind=1)
     reply->interest_option_cd = notinterested_cd
    ELSE
     reply->interest_option_cd = interested_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Didn't find any prescreen settings for the patient"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL populatereplywitherrormessageifany(reply)
 CALL echorecord(reply)
 CALL putjsonrecordtofile(reply)
 SET last_mod = "000"
 SET mod_date = "July 22, 2019"
END GO
