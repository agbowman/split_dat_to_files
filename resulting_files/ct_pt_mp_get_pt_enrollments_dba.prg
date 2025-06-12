CREATE PROGRAM ct_pt_mp_get_pt_enrollments:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 RECORD reply(
   1 enroll_list[*]
     2 prot_id = f8
     2 prot_mnemonic = vc
     2 prot_amendment_id = f8
     2 amendment_nbr = i4
     2 revision_ind = i2
     2 revision_nbr_txt = vc
     2 on_study_dt = dq8
     2 off_study_dt = dq8
     2 on_treatment_dt = dq8
     2 off_treatment_dt = dq8
     2 consented_dt = dq8
     2 on_follow_up_dt = dq8
     2 withdrawn_dt = dq8
     2 status_enum = i1
     2 max_dt = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
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
 SET log_program_name = "ct_pt_mp_get_pt_enrollments"
 FREE RECORD request
 IF (( $JSONREQUEST=""))
  CALL populate_subeventstatus_rec("REQUEST","F","ct_pt_mp_get_pt_enrollments","Invalid JSON Request",
   "reply")
  GO TO exit_script
 ENDIF
 SET stat = cnvtjsontorec( $JSONREQUEST)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE enroll_cnt = i4 WITH protect, noconstant(0)
 DECLARE userorgstr = vc WITH protect
 DECLARE userorgsize = i4 WITH protect, noconstant(0)
 DECLARE userorgitr = i4 WITH protect, noconstant(0)
 DECLARE not_qualified_status_enum = i1 WITH protect, constant(8)
 DECLARE status_where_str = vc WITH protect
 DECLARE status_enum_col_exists_ind = i1 WITH protect, noconstant(0)
 DECLARE consented_col_exists_ind = i1 WITH protect, noconstant(0)
 DECLARE on_followup_col_exists_ind = i1 WITH protect, noconstant(0)
 DECLARE withdrawn_col_exists_ind = i1 WITH protect, noconstant(0)
 DECLARE status_enum_def_value_str = vc WITH protect, noconstant("-1")
 DECLARE consented_def_value_str = vc WITH protect, noconstant('cnvtdatetime("31-DEC-2100")')
 DECLARE on_followup_def_value_str = vc WITH protect, noconstant('cnvtdatetime("31-DEC-2100")')
 DECLARE withdrawn_def_value_str = vc WITH protect, noconstant('cnvtdatetime("31-DEC-2100")')
 SET reply->status_data.status = "F"
 SET status_enum_col_exists_ind = checkdic("PT_PROT_REG.STATUS_ENUM","A",0)
 SET consented_col_exists_ind = checkdic("PT_PROT_REG.CONSENTED_DT_TM","A",0)
 SET on_followup_col_exists_ind = checkdic("PT_PROT_REG.ON_FOLLOWUP_DT_TM","A",0)
 SET withdrawn_col_exists_ind = checkdic("PT_PROT_REG.WITHDRAWN_DT_TM","A",0)
 IF (status_enum_col_exists_ind=2)
  SET status_where_str = build("ppr.status_enum != ",not_qualified_status_enum)
  SET status_enum_def_value_str = "ppr.status_enum"
 ELSE
  SET status_where_str = "1=1"
 ENDIF
 IF (consented_col_exists_ind=2)
  SET consented_def_value_str = "ppr.consented_dt_tm"
 ENDIF
 IF (on_followup_col_exists_ind=2)
  SET on_followup_def_value_str = "ppr.on_followup_dt_tm"
 ENDIF
 IF (withdrawn_col_exists_ind=2)
  SET withdrawn_def_value_str = "ppr.withdrawn_dt_tm"
 ENDIF
 EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
 CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
 IF ((org_sec_reply->orgsecurityflag=1))
  EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
  SET userorgsize = size(user_org_reply->organizations,5)
  SET userorgstr =
"expand(userOrgItr, 1, userOrgSize, ppr.enrolling_organization_id,					  user_org_reply->organizations[userOrgItr]->organiz\
ation_id)\
"
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 SELECT INTO "nl:"
  status_enum = parser(status_enum_def_value_str), consented_dt_tm = parser(consented_def_value_str),
  on_followup_dt_tm = parser(on_followup_def_value_str),
  withdrawn_dt_tm = parser(withdrawn_def_value_str)
  FROM pt_prot_reg ppr,
   ct_pt_amd_assignment caa,
   prot_amendment pa,
   prot_master pm
  PLAN (ppr
   WHERE (ppr.person_id=request->values[0].personid)
    AND parser(userorgstr)
    AND parser(status_where_str)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (caa
   WHERE caa.reg_id=ppr.reg_id
    AND caa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_amendment_id=caa.prot_amendment_id)
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id
    AND pm.display_ind=1
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY pm.prot_master_id, caa.ct_pt_amd_assignment_id DESC
  HEAD pm.prot_master_id
   enroll_cnt += 1
   IF (enroll_cnt > size(reply->enroll_list,5))
    stat = alterlist(reply->enroll_list,(enroll_cnt+ 9))
   ENDIF
   reply->enroll_list[enroll_cnt].prot_id = pm.prot_master_id, reply->enroll_list[enroll_cnt].
   prot_mnemonic = pm.primary_mnemonic, reply->enroll_list[enroll_cnt].on_study_dt = ppr
   .on_study_dt_tm,
   reply->enroll_list[enroll_cnt].on_treatment_dt = ppr.tx_start_dt_tm, reply->enroll_list[enroll_cnt
   ].off_treatment_dt = ppr.tx_completion_dt_tm, reply->enroll_list[enroll_cnt].off_study_dt = ppr
   .off_study_dt_tm,
   reply->enroll_list[enroll_cnt].max_dt = cnvtdatetime("31-DEC-2100"), reply->enroll_list[enroll_cnt
   ].prot_amendment_id = caa.prot_amendment_id, reply->enroll_list[enroll_cnt].amendment_nbr = pa
   .amendment_nbr,
   reply->enroll_list[enroll_cnt].revision_ind = pa.revision_ind, reply->enroll_list[enroll_cnt].
   revision_nbr_txt = pa.revision_nbr_txt, reply->enroll_list[enroll_cnt].consented_dt =
   consented_dt_tm,
   reply->enroll_list[enroll_cnt].on_follow_up_dt = on_followup_dt_tm, reply->enroll_list[enroll_cnt]
   .withdrawn_dt = withdrawn_dt_tm, reply->enroll_list[enroll_cnt].status_enum = status_enum
  WITH expand = 2, nocounter, orahintcbo(" GATHER_PLAN_STATISTICS ")
 ;end select
 SET stat = alterlist(reply->enroll_list,enroll_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Didn't find any protocol for a patient"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL populatereplywitherrormessageifany(reply)
 CALL putjsonrecordtofile(reply)
 CALL echorecord(reply)
 SET last_mod = "001"
 SET mod_date = "SEP 22, 2020"
END GO
