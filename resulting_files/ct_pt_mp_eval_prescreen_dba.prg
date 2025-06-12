CREATE PROGRAM ct_pt_mp_eval_prescreen:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prescreened(
   1 prot[*]
     2 prot_master_id = f8
 )
 RECORD he_server_response(
   1 consequents[*]
     2 what_inferred = f8
     2 absent = i4
 )
 RECORD pendingstatus(
   1 prescreenid[*]
     2 pt_prot_prescreen_id = f8
 )
 RECORD unregistered(
   1 prot[*]
     2 prot_master_id = f8
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
 SET log_program_name = "ct_pt_mp_eval_prescreen"
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"FAILED"))
 DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"COMPLETE"))
 DECLARE syscancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE added_via_he = i2 WITH protect, constant(2)
 DECLARE conseq_cnt = i4 WITH protect, noconstant(0)
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0.0)
 DECLARE manually_added = i2 WITH protect, constant(1)
 DECLARE protcnt = i4 WITH protect, noconstant(0)
 DECLARE pendingprotcnt = i4 WITH protect, noconstant(0)
 DECLARE unregprotcnt = i4 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE spersonid = vc WITH protect
 DECLARE nbrconsentries = i4 WITH protect, noconstant(0)
 DECLARE sconsqname = vc WITH protect
 DECLARE swhtinf = vc WITH protect
 DECLARE sabsent = vc WITH protect
 DECLARE status = vc WITH protect
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE hmsg = i4
 DECLARE hrequest = i4
 DECLARE hreply = i4
 DECLARE iret = i4
 DECLARE hitem = i4
 DECLARE hstatus = i4
 DECLARE hconsitem = i4
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE add_flag = i2 WITH protect, noconstant(0)
 DECLARE found_idx = i4 WITH protect, noconstant(0)
 DECLARE prescreen_id = f8 WITH protect, noconstant(0.0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=request->screener_id)
  DETAIL
   logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET err_msg = "Logical domain id not found."
  SET fail_flag = 1
  GO TO exit_script
 ENDIF
 SET hmsg = uar_srvselectmessage(966700)
 SET hrequest = uar_srvcreaterequest(hmsg)
 SET hreply = uar_srvcreatereply(hmsg)
 IF (((hmsg=null) OR (((hrequest=null) OR (hreply=null)) )) )
  SET err_msg = "Error creating HE handle."
  SET fail_flag = 1
  CALL uar_srvdestroyinstance(hreply)
  CALL uar_srvdestroyinstance(hrequest)
  GO TO exit_script
 ENDIF
 SET iret = uar_srvsetstring(hrequest,"knowledge_base_name","CLINTRIALS")
 SET iret = uar_srvsetstring(hrequest,"rule_engine","Drools")
 SET iret = uar_srvsetshort(hrequest,"use_stateful_session",0)
 SET iret = uar_srvsetshort(hrequest,"publish_consequents_flag",0)
 SET hitem = uar_srvadditem(hrequest,"axises")
 SET iret = uar_srvsetstring(hitem,"name","PERSON")
 SET iret = uar_srvsetstring(hitem,"value",nullterm(trim(cnvtstring(request->person_id))))
 SET stat = uar_srvexecute(hmsg,hrequest,hreply)
 IF (stat > 0)
  SET err_msg = "HE execution failed."
  SET fail_flag = 1
  CALL uar_srvdestroyinstance(hreply)
  CALL uar_srvdestroyinstance(hrequest)
  GO TO exit_script
 ENDIF
 SET hstatus = uar_srvgetstruct(hreply,"status_data")
 SET status = uar_srvgetstringptr(hstatus,"status")
 IF (status="F")
  SET err_msg = "HE transaction failed."
  SET fail_flag = 1
  CALL uar_srvdestroyinstance(hreply)
  CALL uar_srvdestroyinstance(hrequest)
 ELSE
  SET hitem = uar_srvgetitem(hreply,"axises",0)
  SET spersonid = uar_srvgetstringptr(hitem,"value")
  IF ((cnvtreal(spersonid)=request->person_id))
   SET nbrconsentries = uar_srvgetitemcount(hitem,"consequents")
   IF (nbrconsentries > 0)
    SET stat = alterlist(he_server_response->consequents,nbrconsentries)
   ENDIF
   FOR (j = 0 TO (nbrconsentries - 1))
     SET hconsitem = uar_srvgetitem(hitem,"consequents",j)
     SET sconsqname = uar_srvgetstringptr(hconsitem,"name")
     SET swhtinf = uar_srvgetstringptr(hconsitem,"what_inferred")
     SET sabsent = uar_srvgetstringptr(hconsitem,"absent")
     SET he_server_response->consequents[(j+ 1)].what_inferred = cnvtreal(swhtinf)
     SET he_server_response->consequents[(j+ 1)].absent = cnvtint(sabsent)
   ENDFOR
  ENDIF
 ENDIF
 SET conseq_cnt = size(he_server_response->consequents,5)
 SET stat = alterlist(unregistered->prot,conseq_cnt)
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE expand(idx,1,conseq_cnt,pm.prot_master_id,he_server_response->consequents[idx].what_inferred)
   AND pm.logical_domain_id=logical_domain_id
   AND  NOT ( EXISTS (
  (SELECT
   ppr.prot_master_id
   FROM pt_prot_reg ppr
   WHERE ppr.prot_master_id=pm.prot_master_id
    AND (ppr.person_id=request->person_id)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))))
  DETAIL
   unregprotcnt += 1, unregistered->prot[unregprotcnt].prot_master_id = pm.prot_master_id
  WITH nocounter
 ;end select
 SET stat = alterlist(unregistered->prot,unregprotcnt)
 SELECT INTO "nl:"
  FROM pt_prot_prescreen p,
   prot_master pm
  PLAN (p
   WHERE  NOT (expand(idx,1,conseq_cnt,p.prot_master_id,he_server_response->consequents[idx].
    what_inferred))
    AND (p.person_id=request->person_id)
    AND p.screening_status_cd=pending_cd
    AND p.added_via_flag != manually_added)
   JOIN (pm
   WHERE pm.prot_master_id=p.prot_master_id
    AND pm.prescreen_type_flag=1)
  DETAIL
   pendingprotcnt += 1
   IF (mod(pendingprotcnt,10)=1)
    stat = alterlist(pendingstatus->prescreenid,(pendingprotcnt+ 9))
   ENDIF
   pendingstatus->prescreenid[pendingprotcnt].pt_prot_prescreen_id = p.pt_prot_prescreen_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE expand(idx,1,unregprotcnt,pm.prot_master_id,unregistered->prot[idx].prot_master_id)
   AND  NOT ( EXISTS (
  (SELECT
   ppp.prot_master_id
   FROM pt_prot_prescreen ppp
   WHERE ppp.prot_master_id=pm.prot_master_id
    AND (ppp.person_id=request->person_id))))
  DETAIL
   found_idx = locateval(idx,1,size(prescreened->prot,5),pm.prot_master_id,prescreened->prot[idx].
    prot_master_id)
   IF (found_idx=0)
    protcnt += 1
    IF (mod(protcnt,10)=1)
     stat = alterlist(prescreened->prot,(protcnt+ 9))
    ENDIF
    prescreened->prot[protcnt].prot_master_id = pm.prot_master_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prot_master pm,
   pt_prot_prescreen ppp
  PLAN (pm
   WHERE expand(idx,1,unregprotcnt,pm.prot_master_id,unregistered->prot[idx].prot_master_id))
   JOIN (ppp
   WHERE ppp.prot_master_id=pm.prot_master_id
    AND (ppp.person_id=request->person_id))
  ORDER BY ppp.prot_master_id
  HEAD ppp.prot_master_id
   add_flag = 1, prescreen_id = 0
  DETAIL
   IF (((ppp.screening_status_cd != syscancel_cd
    AND ppp.screening_status_cd != pending_cd) OR (ppp.screening_status_cd=pending_cd
    AND ppp.added_via_flag=manually_added)) )
    add_flag = 0
   ELSEIF (ppp.screening_status_cd=pending_cd
    AND ppp.added_via_flag != manually_added)
    prescreen_id = ppp.pt_prot_prescreen_id
   ENDIF
  FOOT  ppp.prot_master_id
   IF (add_flag=1)
    IF (prescreen_id > 0)
     pendingprotcnt += 1
     IF (mod(pendingprotcnt,10)=1)
      stat = alterlist(pendingstatus->prescreenid,(pendingprotcnt+ 9))
     ENDIF
     pendingstatus->prescreenid[pendingprotcnt].pt_prot_prescreen_id = prescreen_id
    ENDIF
    found_idx = locateval(idx,1,size(prescreened->prot,5),ppp.prot_master_id,prescreened->prot[idx].
     prot_master_id)
    IF (found_idx=0)
     protcnt += 1
     IF (mod(protcnt,10)=1)
      stat = alterlist(prescreened->prot,(protcnt+ 9))
     ENDIF
     prescreened->prot[protcnt].prot_master_id = ppp.prot_master_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(prescreened->prot,protcnt)
 SET stat = alterlist(pendingstatus->prescreenid,pendingprotcnt)
 IF (pendingprotcnt > 0)
  UPDATE  FROM pt_prot_prescreen ppp
   SET ppp.screening_status_cd = syscancel_cd, ppp.updt_dt_tm = cnvtdatetime(sysdate), ppp.updt_cnt
     = (ppp.updt_cnt+ 1)
   WHERE expand(idx,1,pendingprotcnt,ppp.pt_prot_prescreen_id,pendingstatus->prescreenid[idx].
    pt_prot_prescreen_id)
  ;end update
 ENDIF
 IF (protcnt > 0)
  INSERT  FROM pt_prot_prescreen ppp,
    (dummyt d  WITH seq = value(protcnt))
   SET ppp.pt_prot_prescreen_id = seq(protocol_def_seq,nextval), ppp.ct_prescreen_job_id = request->
    job_id, ppp.person_id = request->person_id,
    ppp.prot_master_id = prescreened->prot[d.seq].prot_master_id, ppp.screener_person_id = request->
    screener_id, ppp.screened_dt_tm = cnvtdatetime(sysdate),
    ppp.screening_status_cd = pending_cd, ppp.added_via_flag = added_via_he, ppp.updt_dt_tm =
    cnvtdatetime(sysdate)
   PLAN (d)
    JOIN (ppp)
   WITH nocounter
  ;end insert
 ENDIF
#exit_script
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  UPDATE  FROM ct_prescreen_job cj
   SET cj.job_status_cd = completed_cd, cj.updt_cnt = (cj.updt_cnt+ 1), cj.updt_dt_tm = cnvtdatetime(
     sysdate)
   WHERE (cj.ct_prescreen_job_id=request->job_id)
   WITH nocounter
  ;end update
 ELSE
  SET reply->status_data.status = "F"
  SUBROUTINE (nextlongtextsequence(x=i2) =f8)
    DECLARE nsequence = f8 WITH protect
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      nsequence = nextseqnum
     WITH nocounter
    ;end select
    RETURN(nsequence)
  END ;Subroutine
  SUBROUTINE (insert_long_text(long_text_id=f8,text=vc,parent_name=vc,parent_id=f8) =i2)
   INSERT  FROM long_text lt
    SET lt.long_text_id =
     IF (long_text_id > 0) long_text_id
     ELSE seq(long_data_seq,nextval)
     ENDIF
     , lt.long_text = text, lt.parent_entity_name = parent_name,
     lt.parent_entity_id = parent_id, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
     updt_id,
     lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(sysdate),
     lt.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
  END ;Subroutine
  DECLARE long_text_id = f8 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM long_text lt
   WHERE (lt.parent_entity_id=request->job_id)
   DETAIL
    long_text_id = lt.long_text_id, err_msg = build2(err_msg,lt.long_text)
   WITH nocounter
  ;end select
  IF (long_text_id > 0)
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE lt.long_text_id=long_text_id
    WITH nocounter, forupdatewait(lt)
   ;end select
   UPDATE  FROM long_text lt
    SET lt.long_text = err_msg, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE lt.long_text_id=long_text_id
   ;end update
  ELSE
   SET long_text_id = nextlongtextsequence(0)
   CALL insert_long_text(long_text_id,err_msg,"ct_pt_mp_eval_prescreen",request->job_id)
  ENDIF
  UPDATE  FROM ct_prescreen_job cj
   SET cj.job_status_cd = failed_cd, cj.long_text_id = long_text_id, cj.updt_cnt = (cj.updt_cnt+ 1),
    cj.updt_dt_tm = cnvtdatetime(sysdate)
   WHERE (cj.ct_prescreen_job_id=request->job_id)
   WITH nocounter
  ;end update
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  CALL echo("Transaction error, changes rolled back")
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM ct_prot_prescreen_job_info cpj
  SET cpj.completed_flag = 1, cpj.updt_cnt = (cpj.updt_cnt+ 1), cpj.updt_dt_tm = cnvtdatetime(sysdate
    )
  WHERE (cpj.ct_prescreen_job_id=request->job_id)
  WITH nocounter
 ;end update
 COMMIT
 CALL echorecord(reply)
 SET last_mod = "000"
 SET mod_date = "May 17, 2021"
END GO
