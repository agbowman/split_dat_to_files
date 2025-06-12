CREATE PROGRAM ct_pt_mp_get_potential_study:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 RECORD reply(
   1 protocols[*]
     2 pt_prot_prescreen_id = f8
     2 prot_master_id = f8
     2 added_via_flag = i2
     2 primary_mnemonic = vc
     2 prot_status_mean = vc
     2 screening_dt_tm = dq8
     2 screener_person_id = f8
     2 screener_full_name = vc
     2 screening_status_cd = f8
     2 screening_status_disp = vc
     2 screening_status_desc = vc
     2 screening_status_mean = c12
     2 referral_dt_tm = dq8
     2 referral_person_id = f8
     2 referral_full_name = vc
     2 comment_text = vc
     2 reason_text = vc
     2 filename = vc
     2 displayable_docs_ind = i2
     2 open_amendment_id = f8
     2 checklist_exists_ind = i2
     2 protocol_aliases[*]
       3 prot_alias = vc
     2 access_masks[*]
       3 entity_access_id = f8
       3 functionality_cd = f8
       3 functionality_disp = c50
       3 functionality_mean = vc
       3 access_mask = c5
       3 updt_cnt = i4
   1 statuses[*]
     2 status_cd = f8
     2 status_disp = vc
     2 status_mean = vc
   1 syscancel_cd = f8
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
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 IF (( $JSONREQUEST=""))
  CALL populate_subeventstatus_rec("REQUEST","F","ct_pt_mp_get_potential_study",
   "Invalid JSON Request","reply")
  GO TO exit_script
 ENDIF
 SET stat = cnvtjsontorec( $JSONREQUEST)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE application_statuses_codeset = f8 WITH protect, constant(17914)
 DECLARE screening_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,
   "COMPLETE"))
 DECLARE screening_completed_not_qualified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   17901,"COMPLETENQ"))
 DECLARE screening_completed_qualified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,
   "COMPLETEQUAL"))
 DECLARE syscancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE institution_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17296,"INSTITUTION"))
 DECLARE open_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"ACTIVATED"))
 DECLARE not_interested_ind = i2 WITH protect, noconstant(- (1))
 DECLARE role_type_str = vc WITH protect
 DECLARE user_org_str = vc WITH protect
 DECLARE user_org_size = i4 WITH protect, noconstant(0)
 DECLARE user_org_itr = i4 WITH protect, noconstant(0)
 DECLARE protocol_cnt = i4 WITH protect, noconstant(0)
 DECLARE alias_cnt = i4 WITH protect, noconstant(0)
 DECLARE alias_pool_display = vc WITH protect
 DECLARE status_cnt = i2 WITH protect, noconstant(0)
 DECLARE itr = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE access_mask_cnt = i4 WITH protect, noconstant(0)
 DECLARE functionality_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17311,"ELIGLAUNCH"))
 DECLARE log_domain_where_str = vc WITH protect
 SET reply->syscancel_cd = syscancel_cd
 SET reply->status_data.status = "F"
 IF (checkdic("PROT_ROLE_ACCESS.LOGICAL_DOMAIN_ID","A",0)=2)
  IF ( NOT (validate(domain_reply)))
   RECORD domain_reply(
     1 logical_domain_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
  SET log_domain_where_str = "pra.logical_domain_id = domain_reply->logical_domain_id"
 ELSE
  SET log_domain_where_str = "1=1"
 ENDIF
 SELECT INTO "nl:"
  FROM ct_pt_settings cps
  WHERE (cps.person_id=potential_studies_request->person_id)
   AND cps.active_ind=1
  DETAIL
   not_interested_ind = cps.not_interested_ind
  WITH nocounter
 ;end select
 IF (not_interested_ind=1)
  SET reply->status_data.status = "NI"
  SET reply->status_data.subeventstatus[1].operationname = "Check prescreening interest"
  SET reply->status_data.subeventstatus[1].operationstatus = "NI"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "patient is not interested in prescreening"
  GO TO exit_script
 ELSEIF ((not_interested_ind=- (1)))
  SET ct_get_pref_request->pref_entry = "default_interest"
  EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
   "CT_GET_PREF_REPLY")
  CALL echo(build("default_interest:",ct_get_pref_reply->pref_value))
  IF ((ct_get_pref_reply->pref_value=1))
   SET reply->status_data.status = "NI"
   SET reply->status_data.subeventstatus[1].operationname = "Default prescreening interest"
   SET reply->status_data.subeventstatus[1].operationstatus = "NI"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "default prescreening interest is not interested"
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
 CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
 IF ((org_sec_reply->orgsecurityflag=1))
  EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
  SET user_org_size = size(user_org_reply->organizations,5)
  SET user_org_str =
  "expand(user_org_itr, 1, user_org_size, pr.organization_id,					  user_org_reply->organizations[user_org_itr]->organization_id)"
  SET role_type_str = "pr.prot_role_type_cd = institution_cd"
 ELSE
  SET user_org_str = "1=1"
  SET role_type_str = "1=1"
 ENDIF
 SELECT INTO "NL:"
  FROM pt_prot_prescreen ppp,
   prot_master pm,
   prot_amendment pa,
   prot_role pr,
   ct_document cd,
   ct_document_version cdv
  PLAN (ppp
   WHERE (ppp.person_id=potential_studies_request->person_id)
    AND ppp.prot_master_id > 0
    AND  NOT (ppp.screening_status_cd IN (syscancel_cd, screening_completed_cd,
   screening_completed_not_qualified_cd, screening_completed_qualified_cd)))
   JOIN (pm
   WHERE pm.prot_master_id=ppp.prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pm.display_ind=1
    AND pm.network_flag < 2)
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND pa.amendment_status_cd=pm.prot_status_cd)
   JOIN (pr
   WHERE pr.prot_amendment_id=pa.prot_amendment_id
    AND parser(role_type_str)
    AND parser(user_org_str)
    AND pr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (cd
   WHERE (cd.prot_amendment_id= Outerjoin(pa.prot_amendment_id))
    AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (cdv
   WHERE (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
    AND (cdv.display_ind= Outerjoin(1))
    AND (cdv.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY ppp.pt_prot_prescreen_id DESC
  HEAD ppp.pt_prot_prescreen_id
   protocol_cnt += 1
   IF (protocol_cnt > size(reply->protocols,5))
    stat = alterlist(reply->protocols,(protocol_cnt+ 9))
   ENDIF
   reply->protocols[protocol_cnt].pt_prot_prescreen_id = ppp.pt_prot_prescreen_id, reply->protocols[
   protocol_cnt].prot_master_id = ppp.prot_master_id, reply->protocols[protocol_cnt].primary_mnemonic
    = pm.primary_mnemonic,
   reply->protocols[protocol_cnt].prot_status_mean = uar_get_code_meaning(pm.prot_status_cd), reply->
   protocols[protocol_cnt].screening_dt_tm = ppp.screened_dt_tm, reply->protocols[protocol_cnt].
   screener_person_id = ppp.screener_person_id,
   reply->protocols[protocol_cnt].screening_status_cd = ppp.screening_status_cd, reply->protocols[
   protocol_cnt].screening_status_mean = uar_get_code_meaning(ppp.screening_status_cd), reply->
   protocols[protocol_cnt].screening_status_disp = uar_get_code_display(ppp.screening_status_cd),
   reply->protocols[protocol_cnt].referral_dt_tm = ppp.referred_dt_tm, reply->protocols[protocol_cnt]
   .referral_person_id = ppp.referred_person_id, reply->protocols[protocol_cnt].comment_text = ppp
   .comment_text,
   reply->protocols[protocol_cnt].reason_text = ppp.reason_text, reply->protocols[protocol_cnt].
   open_amendment_id = pa.prot_amendment_id, reply->protocols[protocol_cnt].added_via_flag = ppp
   .added_via_flag
  DETAIL
   IF (cdv.display_ind=1)
    reply->protocols[protocol_cnt].displayable_docs_ind = 1
   ENDIF
  WITH nocounter, expand = 2, orahintcbo(" GATHER_PLAN_STATISTICS ")
 ;end select
 SET stat = alterlist(reply->protocols,protocol_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "no potential studies found for the patient"
  GO TO exit_script
 ENDIF
 IF (protocol_cnt > 0)
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE expand(itr,1,protocol_cnt,p.person_id,reply->protocols[itr].referral_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    pos = locateval(itr,1,protocol_cnt,p.person_id,reply->protocols[itr].referral_person_id)
    WHILE (pos > 0)
     reply->protocols[pos].referral_full_name = p.name_full_formatted,pos = locateval(itr,(pos+ 1),
      protocol_cnt,p.person_id,reply->protocols[itr].referral_person_id)
    ENDWHILE
   WITH nocounter, expand = 2
  ;end select
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE expand(itr,1,protocol_cnt,p.person_id,reply->protocols[itr].screener_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    pos = locateval(itr,1,protocol_cnt,p.person_id,reply->protocols[itr].screener_person_id)
    WHILE (pos > 0)
     reply->protocols[pos].screener_full_name = p.name_full_formatted,pos = locateval(itr,(pos+ 1),
      protocol_cnt,p.person_id,reply->protocols[itr].screener_person_id)
    ENDWHILE
   WITH nocounter, expand = 2
  ;end select
  SELECT INTO "nl:"
   FROM prot_alias pa,
    alias_pool ap
   PLAN (pa
    WHERE expand(itr,1,protocol_cnt,pa.prot_master_id,reply->protocols[itr].prot_master_id)
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (ap
    WHERE ap.alias_pool_cd=pa.alias_pool_cd)
   ORDER BY pa.prot_master_id
   HEAD pa.prot_master_id
    alias_cnt = 0, pos = locateval(itr,1,protocol_cnt,pa.prot_master_id,reply->protocols[itr].
     prot_master_id)
   DETAIL
    IF (pos > 0)
     alias_cnt += 1
     IF (alias_cnt > size(reply->protocols[pos].protocol_aliases,5))
      stat = alterlist(reply->protocols[pos].protocol_aliases,(alias_cnt+ 9))
     ENDIF
     alias_pool_display = uar_get_code_display(pa.alias_pool_cd), reply->protocols[pos].
     protocol_aliases[alias_cnt].prot_alias = concat(alias_pool_display,"-",cnvtalias(pa.prot_alias,
       pa.alias_pool_cd))
    ENDIF
   FOOT  pa.prot_master_id
    stat = alterlist(reply->protocols[pos].protocol_aliases,alias_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prot_questionnaire pq
   WHERE expand(itr,1,protocol_cnt,pq.prot_amendment_id,reply->protocols[itr].open_amendment_id)
    AND pq.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    pos = locateval(itr,1,protocol_cnt,pq.prot_amendment_id,reply->protocols[itr].open_amendment_id)
    IF (pos > 0)
     reply->protocols[pos].checklist_exists_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET stat = getcurrentposition(null)
  IF (stat)
   CALL echo(build("User's current position is: ",sac_cur_pos_rep->position_cd))
  ELSE
   CALL echo(build("Default position lookup failed with status: ",sac_cur_pos_rep->status_data.status
     ))
  ENDIF
  SELECT INTO "nl:"
   FROM entity_access ea
   WHERE expand(itr,1,protocol_cnt,ea.prot_amendment_id,reply->protocols[itr].open_amendment_id)
    AND (ea.person_id=reqinfo->updt_id)
    AND ea.functionality_cd=functionality_cd
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    index = locateval(itr,1,protocol_cnt,ea.prot_amendment_id,reply->protocols[itr].open_amendment_id
     )
    IF (index > 0)
     access_mask_cnt = size(reply->protocols[index].access_masks,5), access_mask_cnt += 1, stat =
     alterlist(reply->protocols[index].access_masks,access_mask_cnt),
     reply->protocols[index].access_masks[access_mask_cnt].access_mask = ea.access_mask, reply->
     protocols[index].access_masks[access_mask_cnt].updt_cnt = ea.updt_cnt, reply->protocols[index].
     access_masks[access_mask_cnt].functionality_cd = ea.functionality_cd,
     reply->protocols[index].access_masks[access_mask_cnt].functionality_mean = uar_get_code_meaning(
      ea.functionality_cd)
    ENDIF
   WITH nocounter, expand = 2
  ;end select
  SELECT INTO "nl:"
   FROM prot_role pr,
    prot_role_access pra
   PLAN (pr
    WHERE expand(itr,1,protocol_cnt,pr.prot_amendment_id,reply->protocols[itr].open_amendment_id)
     AND (((pr.person_id=reqinfo->updt_id)) OR ((pr.position_cd=sac_cur_pos_rep->position_cd)))
     AND pr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pra
    WHERE pra.prot_role_cd=pr.prot_role_cd
     AND pra.functionality_cd=functionality_cd
     AND pra.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND parser(log_domain_where_str))
   DETAIL
    index = locateval(itr,1,protocol_cnt,pr.prot_amendment_id,reply->protocols[itr].open_amendment_id
     )
    IF (index > 0)
     access_mask_cnt = size(reply->protocols[index].access_masks,5), access_mask_cnt += 1, stat =
     alterlist(reply->protocols[index].access_masks,access_mask_cnt),
     reply->protocols[index].access_masks[access_mask_cnt].access_mask = pra.access_mask, reply->
     protocols[index].access_masks[access_mask_cnt].updt_cnt = - (1), reply->protocols[index].
     access_masks[access_mask_cnt].functionality_cd = pra.functionality_cd,
     reply->protocols[index].access_masks[access_mask_cnt].functionality_mean = uar_get_code_display(
      pra.functionality_cd)
    ENDIF
   WITH nocounter, expand = 2
  ;end select
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_group cvg,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=application_statuses_codeset
    AND cv1.active_ind=1
    AND cv1.cdf_meaning="POTENTIALST"
    AND cv1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (cvg
   WHERE cvg.parent_code_value=cv1.code_value)
   JOIN (cv2
   WHERE cv2.code_value=cvg.child_code_value
    AND cv2.active_ind=1
    AND cv2.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   status_cnt += 1
   IF (status_cnt > size(reply->statuses,5))
    stat = alterlist(reply->statuses,(status_cnt+ 9))
   ENDIF
   reply->statuses[status_cnt].status_cd = cv2.code_value, reply->statuses[status_cnt].status_disp =
   cv2.display, reply->statuses[status_cnt].status_mean = cv2.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->statuses,status_cnt)
#exit_script
 CALL populatereplywitherrormessageifany(reply)
 CALL echorecord(reply)
 CALL putjsonrecordtofile(reply)
 SET last_mod = "002"
 SET mod_date = "Jul 04, 2021"
END GO
