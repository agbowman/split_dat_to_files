CREATE PROGRAM cp_chart_clinical_results:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id:" = 0.0,
  "Personnel Id:" = 0.00,
  "Encounter Id:" = 0.0,
  "Provider Patient Relation Code:" = 0.00,
  "Date Time:" = ""
  WITH outdev, person_id, inputproviderid,
  encntr_id, inputppr, chart_date
 SUBROUTINE (addtoeventprsnllist(hparent=i4(ref),personid=f8,actionprsnlid=f8,actiontype=f8,
  actionstatus=f8,actiondttm=dq8,recorddata=vc(ref)) =null)
   DECLARE hprsnl = i4 WITH noconstant(0), private
   IF (hparent=0)
    CALL handleerror("AddToEventPrsnlList()","F","Parent Handle Missing","hParent required.",
     recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
   ENDIF
   IF (personid=0.0)
    CALL handleerror("AddToEventPrsnlList()","F","personId Missing","Parameter PersonId required.",
     recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
   ENDIF
   IF (actionprsnlid=0.0)
    CALL handleerror("AddToEventPrsnlList()","F","actionPrsnlId Missing",
     "Parameter actionPrsnlId required.",recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
   ENDIF
   IF (actiontype=0.0)
    CALL handleerror("AddToEventPrsnlList()","F","actionType Missing",
     "Parameter actionType required.",recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
   ENDIF
   IF (actionstatus=0.0)
    CALL handleerror("AddToEventPrsnlList()","F","actionStatus Missing",
     "Parameter actionStatus required.",recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
   ENDIF
   IF (actiondttm=0.0)
    CALL handleerror("AddToEventPrsnlList()","F","actionDtTm Missing",
     "Parameter actionDtTm required.",recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
   ENDIF
   IF (hparent)
    SET hprsnl = uar_srvadditem(hparent,"event_prsnl_list")
    IF (hprsnl)
     SET srvstat = uar_srvsetdouble(hprsnl,"person_id",personid)
     SET srvstat = uar_srvsetdouble(hprsnl,"action_prsnl_id",actionprsnlid)
     SET srvstat = uar_srvsetdouble(hprsnl,"action_type_cd",actiontype)
     SET srvstat = uar_srvsetdouble(hprsnl,"action_status_cd",actionstatus)
     SET srvstat = uar_srvsetdate(hprsnl,"action_dt_tm",actiondttm)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (execeventsensured(request=vc(ref)) =null WITH protect)
   CALL log_message("In ExecEventsEnsured()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ee_app_id = i4 WITH private, constant(600005)
   DECLARE ee_task_id = i4 WITH private, constant(600108)
   DECLARE ee_request_number = i4 WITH private, constant(600345)
   DECLARE rblistsize = i4 WITH private, noconstant(0)
   DECLARE repsize = i4 WITH private, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hreqlist = i4 WITH private, noconstant(0)
   DECLARE hreply = i4 WITH private, noconstant(0)
   DECLARE hstatusdata = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   DECLARE y = i4 WITH private, noconstant(0)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(request)
   ENDIF
   CALL initializeapptaskrequest(report_data,ee_app_id,ee_task_id,ee_request_number)
   SET hreq = uar_crmgetrequest(hstep)
   CALL echo(build("size(report_data->rep,5)::",size(report_data->rep,5)))
   SET repsize = size(request->qual,5)
   IF (repsize > 0)
    FOR (x = 1 TO repsize)
     SET hreqlist = uar_srvadditem(hreq,"elist")
     SET nsrvstat = uar_srvsetdouble(hreqlist,"event_id",request->qual[x].event_id)
    ENDFOR
    SET ncrmstat = uar_crmperform(hstep)
   ENDIF
   IF (ncrmstat=0)
    SET hreply = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hreply,"status_data")
    IF (uar_srvgetstringptr(hstatusdata,"status")="F")
     CALL handleerror("ExecEventsEnsured()","F",cnvtstring(ncrmstat),
      "Failure during execution of DCP_EVENTS_ENSURED")
    ENDIF
   ELSE
    CALL handleerror("ExecEventsEnsured()","F",cnvtstring(ncrmstat),
     "Failure during execution of DCP_EVENTS_ENSURED CRM STATUS")
   ENDIF
   CALL exit_srvrequest(happ,htask,hstep)
   CALL log_message(build("Exit ExecEventsEnsured(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (validateuserprivileges(valuerec=vc(ref),view_results_ind=i2,add_documentation_ind=i2,
  modify_documentation_ind=i2,unchart_documentation_ind=i2,sign_documentation_ind=i2,recorddata=vc(
   ref),event_set_level=i2) =i2)
   CALL log_message("In ValidateUserPrivileges()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE viewcnt = i4 WITH noconstant(0), private
   DECLARE addcnt = i4 WITH noconstant(0), private
   DECLARE modcnt = i4 WITH noconstant(0), private
   DECLARE unchartcnt = i4 WITH noconstant(0), private
   DECLARE signcnt = i4 WITH noconstant(0), private
   FREE RECORD priveventset_rec
   RECORD priveventset_rec(
     1 cnt = i4
     1 qual[*]
       2 value = vc
   ) WITH protect
   IF (event_set_level)
    CALL geteventsetnamesfromeventsetcds(valuerec,priveventset_rec)
    SET curalias chk_priv_req check_priv_request->event_privileges.event_set_level
    SET stat = movereclist(priveventset_rec->qual,check_priv_request->event_set_name,1,0,
     priveventset_rec->cnt,
     1)
   ELSE
    SET curalias chk_priv_req check_priv_request->event_privileges.event_code_level
    SET stat = movereclist(valuerec->qual,chk_priv_req->event_codes,1,0,valuerec->cnt,
     1)
   ENDIF
   SET curalias chk_priv_reply check_priv_reply->event_privileges
   SET chk_priv_req->view_results_ind = view_results_ind
   SET chk_priv_req->add_documentation_ind = add_documentation_ind
   SET chk_priv_req->modify_documentation_ind = modify_documentation_ind
   SET chk_priv_req->unchart_documentation_ind = unchart_documentation_ind
   SET chk_priv_req->sign_documentation_ind = sign_documentation_ind
   IF (validate(debug_ind,0)=1)
    CALL echo(build("$INPUTPROVIDERID::", $INPUTPROVIDERID,"::$INPUTPPR::", $INPUTPPR))
    CALL echorecord(check_priv_request)
   ENDIF
   CALL checkprivileges( $INPUTPROVIDERID, $INPUTPPR)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(check_priv_reply)
   ENDIF
   IF ((check_priv_reply->status_data.status="S"))
    IF (event_set_level)
     SET viewcnt = size(chk_priv_reply->view_results.granted.event_sets,5)
     SET addcnt = size(chk_priv_reply->add_documentation.granted.event_sets,5)
     SET modcnt = size(chk_priv_reply->modify_documentation.granted.event_sets,5)
     SET unchartcnt = size(chk_priv_reply->unchart_documentation.granted.event_sets,5)
     SET signcnt = size(chk_priv_reply->sign_documentation.granted.event_sets,5)
    ELSE
     SET viewcnt = size(chk_priv_reply->view_results.granted.event_codes,5)
     SET addcnt = size(chk_priv_reply->add_documentation.granted.event_codes,5)
     SET modcnt = size(chk_priv_reply->modify_documentation.granted.event_codes,5)
     SET unchartcnt = size(chk_priv_reply->unchart_documentation.granted.event_codes,5)
     SET signcnt = size(chk_priv_reply->sign_documentation.granted.event_codes,5)
    ENDIF
    IF (view_results_ind
     AND (viewcnt != valuerec->cnt))
     CALL handleerror("ValidateUserPrivileges()","F","",
      "User does not have necessary privs to view selected documents.",recorddata)
     CALL exit_srvrequest(happ,htask,hstep)
     GO TO exit_script
    ENDIF
    IF (add_documentation_ind
     AND (addcnt != valuerec->cnt))
     CALL handleerror("ValidateUserPrivileges()","F","",
      "User does not have necessary privs to add selected documents.",recorddata)
     CALL exit_srvrequest(happ,htask,hstep)
     GO TO exit_script
    ENDIF
    IF (modify_documentation_ind
     AND (modcnt != valuerec->cnt))
     CALL handleerror("ValidateUserPrivileges()","F","",
      "User does not have necessary privs to modify selected documents.",recorddata)
     CALL exit_srvrequest(happ,htask,hstep)
     GO TO exit_script
    ENDIF
    IF (unchart_documentation_ind
     AND (unchartcnt != valuerec->cnt))
     CALL handleerror("ValidateUserPrivileges()","F","",
      "User does not have necessary privs to unchart selected documents.",recorddata)
     CALL exit_srvrequest(happ,htask,hstep)
     GO TO exit_script
    ENDIF
    IF (sign_documentation_ind
     AND (signcnt != valuerec->cnt))
     CALL handleerror("ValidateUserPrivileges()","F","",
      "User does not have necessary privs to sign selected documents.",recorddata)
     CALL exit_srvrequest(happ,htask,hstep)
     GO TO exit_script
    ENDIF
   ELSEIF ((check_priv_reply->status_data.status="Z"))
    CALL handleerror("ValidateUserPrivileges()","F","No Records",
     "CheckPrivileges() did not return any requested privs.",recorddata)
    CALL exit_srvrequest(happ,htask,hstep)
    GO TO exit_script
   ENDIF
   SET curalias chk_priv_req off
   SET curalias chk_priv_reply off
   FREE RECORD priveventset_rec
   CALL exit_srvrequest(happ,htask,hstep)
   CALL log_message(build("Exit ValidateUserPrivileges(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 IF (validate(check_priv_request) != 1)
  RECORD check_priv_request(
    1 patient_user_criteria
      2 user_id = f8
      2 patient_user_relationship_cd = f8
    1 event_privileges
      2 event_set_level
        3 event_sets[*]
          4 event_set_name = vc
        3 view_results_ind = i2
        3 add_documentation_ind = i2
        3 modify_documentation_ind = i2
        3 unchart_documentation_ind = i2
        3 sign_documentation_ind = i2
      2 event_code_level
        3 event_codes[*]
          4 event_cd = f8
        3 view_results_ind = i2
        3 add_documentation_ind = i2
        3 modify_documentation_ind = i2
        3 unchart_documentation_ind = i2
        3 sign_documentation_ind = i2
  )
 ENDIF
 IF (validate(check_priv_reply) != 1)
  RECORD check_priv_reply(
    1 patient_user_information
      2 user_id = f8
      2 patient_user_relationship_cd = f8
      2 role_id = f8
    1 event_privileges
      2 view_results
        3 granted
          4 event_sets[*]
            5 event_set_name = vc
          4 event_codes[*]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 document_section_viewing
        3 granted
          4 event_codes[*]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 add_documentation
        3 granted
          4 event_sets[*]
            5 event_set_name = vc
          4 event_codes[*]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 modify_documentation
        3 granted
          4 event_sets[*]
            5 event_set_name = vc
          4 event_codes[*]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 unchart_documentation
        3 granted
          4 event_sets[*]
            5 event_set_name = vc
          4 event_codes[*]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 sign_documentation
        3 granted
          4 event_sets[*]
            5 event_set_name = vc
          4 event_codes[*]
            5 event_cd = f8
        3 status
          4 success_ind = i2
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
 ENDIF
 SUBROUTINE (checkprivileges(prsnlid=f8(val),pprcd=f8(val)) =null WITH protect)
   SET check_priv_request->patient_user_criteria.user_id = prsnlid
   SET check_priv_request->patient_user_criteria.patient_user_relationship_cd = pprcd
   EXECUTE mp_check_privs  WITH replace("REQUEST","CHECK_PRIV_REQUEST"), replace("REPLY",
    "CHECK_PRIV_REPLY")
 END ;Subroutine
 SUBROUTINE (explodeandinitbyeventset(eventsetrec=vc(ref)) =null WITH protect)
   SET break_cnt = 50
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(eventsetrec->qual,5)
   IF (nrecordsize=0)
    RETURN
   ENDIF
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ break_cnt)) * break_cnt)
   SET stat = alterlist(eventsetrec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET eventsetrec->qual[i].value = eventsetrec->qual[nrecordsize].value
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    v.event_cd
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ break_cnt)))),
     v500_event_set_explode v
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ break_cnt))))
     JOIN (v
     WHERE expand(idx,idxstart,((idxstart+ break_cnt) - 1),v.event_set_cd,eventsetrec->qual[idx].
      value,
      break_cnt))
    ORDER BY v.event_cd
    HEAD REPORT
     eccnt = 0
    HEAD v.event_cd
     eccnt += 1
     IF (eccnt > size(check_priv_request->event_privileges.event_code_level.event_codes,5))
      stat = alterlist(check_priv_request->event_privileges.event_code_level.event_codes,(eccnt+ 9))
     ENDIF
     check_priv_request->event_privileges.event_code_level.event_codes[eccnt].event_cd = v.event_cd
    DETAIL
     donothing = 0
    FOOT REPORT
     stat = alterlist(check_priv_request->event_privileges.event_code_level.event_codes,eccnt)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(check_priv_request)
   ENDIF
 END ;Subroutine
 DECLARE lapp_num = i4 WITH protect, constant(3202004)
 DECLARE ltask_num = i4 WITH protect, constant(3202004)
 DECLARE ecrmok = i2 WITH protect, constant(0)
 DECLARE esrvok = i2 WITH protect, constant(0)
 DECLARE hfailind = i2 WITH protect, constant(0)
 DECLARE string40 = i4 WITH protect, constant(40)
 DECLARE hmsg = i4 WITH protect, noconstant(0)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hrep = i4 WITH protect, noconstant(0)
 DECLARE hstatusdata = i4 WITH protect, noconstant(0)
 DECLARE ncrmstat = i2 WITH protect, noconstant(0)
 DECLARE nsrvstat = i2 WITH protect, noconstant(0)
 DECLARE g_perform_failed = i2 WITH protect, noconstant(0)
 SUBROUTINE (initializeapptaskrequest(recorddata=vc(ref),appnumber=i4(val),tasknumber=i4(val),
  requestnumber=i4(val),donotexitonfail=i2(val,0)) =null WITH protect)
   SET ncrmstat = uar_crmbeginapp(appnumber,happ)
   IF (((ncrmstat != ecrmok) OR (happ=0)) )
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: BEGIN Application Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("BEGIN","F","Application Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
   SET ncrmstat = uar_crmbegintask(happ,tasknumber,htask)
   IF (((ncrmstat != ecrmok) OR (htask=0)) )
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: BEGIN Task Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("BEGIN","F","Task Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
   SET ncrmstat = uar_crmbeginreq(htask,0,requestnumber,hstep)
   IF (((ncrmstat != ecrmok) OR (hstep=0)) )
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: BEGIN Request Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("BEGIN","F","Req Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: GET Request Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("GET","F","Req Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (initializerequest(recorddata=vc(ref),requestnumber=i4(val)) =null WITH protect)
   CALL initializeapptaskrequest(recorddata,lapp_num,ltask_num,requestnumber)
 END ;Subroutine
 SUBROUTINE (initializesrvrequest(recorddata=vc(ref),requestnumber=i4(val),donotexitonfail=i2(val,0)
  ) =null WITH protect)
   SET hmsg = uar_srvselectmessage(requestnumber)
   IF (hmsg=hfailind)
    IF (donotexitonfail)
     CALL echo("InitializeSRVRequest: Create Message handle failed")
     CALL exit_srvrequest(hmsg,hreq,hrep)
     RETURN
    ELSE
     CALL handleerror("CREATE","F","Message Handle",cnvtstring(hmsg),recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
   ENDIF
   SET hreq = uar_srvcreaterequest(hmsg)
   IF (hreq=hfailind)
    IF (donotexitonfail)
     CALL echo("InitializeSRVRequest: Create Request Handle failed")
     CALL exit_srvrequest(hmsg,hreq,hrep)
     RETURN
    ELSE
     CALL handleerror("CREATE","F","Req Handle",cnvtstring(hreq),recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
   ENDIF
   SET hrep = uar_srvcreatereply(hmsg)
   IF (hrep=hfailind)
    IF (donotexitonfail)
     CALL echo("InitializeSRVRequest: Create Reply Handle failed")
     CALL exit_srvrequest(hmsg,hreq,hrep)
     RETURN
    ELSE
     CALL handleerror("CREATE","F","Rep Handle",cnvtstring(hrep),recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getproviderposition(prsnl_id=f8) =f8 WITH protect)
   DECLARE prsnl_position_cd = f8 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnl_id
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     prsnl_position_cd = p.position_cd
    WITH nocounter
   ;end select
   RETURN(prsnl_position_cd)
 END ;Subroutine
 SUBROUTINE (createdatetimefromhandle(hhandle=i4(ref),sdatedataelement=vc(val),stimezonedataelement=
  vc(val)) =vc WITH protect)
   DECLARE time_zone = i4 WITH noconstant(0), protect
   DECLARE return_val = vc WITH noconstant(""), protect
   SET stat = uar_srvgetdate(hhandle,nullterm(sdatedataelement),recdate->datetime)
   IF (stimezonedataelement != "")
    SET time_zone = uar_srvgetlong(hhandle,nullterm(stimezonedataelement))
   ENDIF
   IF (validate(recdate->datetime,0))
    SET return_val = build(replace(datetimezoneformat(cnvtdatetime(recdate->datetime),
       datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET return_val = ""
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (handleerror(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc,
  recorddata=vc(ref)) =null WITH protect)
   SET recorddata->status_data.status = "F"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   SET g_perform_failed = 1
 END ;Subroutine
 SUBROUTINE (handlenodata(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc,recorddata=vc(ref)) =null WITH protect)
   SET recorddata->status_data.status = "Z"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE (exit_servicerequest(happ=i4,htask=i4,hstep=i4) =null WITH protect)
   IF (hstep != 0)
    SET ncrmstat = uar_crmendreq(hstep)
   ENDIF
   IF (htask != 0)
    SET ncrmstat = uar_crmendtask(htask)
   ENDIF
   IF (happ != 0)
    SET ncrmstat = uar_crmendapp(happ)
   ENDIF
   IF (g_perform_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE exit_srvrequest(hmsg,hreq,hrep)
   IF (hmsg != 0)
    SET nsrvstat = uar_srvdestroyinstance(hmsg)
   ENDIF
   IF (hreq != 0)
    SET nsrvstat = uar_srvdestroyinstance(hreq)
   ENDIF
   IF (hrep != 0)
    SET nsrvstat = uar_srvdestroyinstance(hrep)
   ENDIF
   IF (g_perform_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereply(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2) =i4 WITH protect
  )
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus="Z")
     CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(ncrmstat),recorddata)
     IF (zeroforceexit=1)
      CALL exit_servicerequest(happ,htask,hstep)
      GO TO exit_script
     ENDIF
    ELSEIF (sstatus != "S")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatesubreply(ncrmstat=i4,hstep=i4,recorddata=vc(ref)) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus != "S"
     AND sstatus != "Z")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereplyindicatordynamic(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc,statusblock=vc) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE successind = i2 WITH noconstant(0), protect
   DECLARE errormessage = vc WITH noconstant(""), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,nullterm(statusblock))
    SET successind = uar_srvgetshort(hstatusdata,"success_ind")
    SET errormessage = uar_srvgetstringptr(hstatusdata,"debug_error_message")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status Indicator: ",successind))
     CALL echo(build("Error Message: ",errormessage))
    ENDIF
    IF (successind != 1)
     CALL handleerror("ValidateReplyIndicator","F",srv_request,errormessage,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ELSEIF (trim(recordname) != "")
     SET resultlistcnt = uar_srvgetitemcount(hrep,nullterm(recordname))
     IF (resultlistcnt=0)
      IF (validate(debug_ind,0)=1)
       CALL echo(build("ZERO RESULTS found in [",trim(recordname,3),"]"))
      ENDIF
      CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(ncrmstat),recorddata)
      IF (zeroforceexit=1)
       CALL exit_servicerequest(happ,htask,hstep)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereplyindicator(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc) =i4 WITH protect)
   CALL validatereplyindicatordynamic(ncrmstat,hstep,recorddata,zeroforceexit,recordname,
    "status_data")
 END ;Subroutine
 SUBROUTINE (validatesrvreplyind(nsrvstat=i4,recorddata=vc(ref),zeroforceexit=i2,recordname=vc,
  statusblock=vc) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE successind = i2 WITH noconstant(0), protect
   DECLARE errormessage = vc WITH noconstant(""), protect
   IF (nsrvstat=esrvok)
    SET hstatusdata = uar_srvgetstruct(hrep,nullterm(statusblock))
    SET successind = uar_srvgetshort(hstatusdata,"success_ind")
    SET errormessage = uar_srvgetstringptr(hstatusdata,"debug_error_message")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status Indicator: ",successind))
     CALL echo(build("Error Message: ",errormessage))
    ENDIF
    IF (successind != 1)
     CALL handleerror("ValidateReply","F",srv_request,errormessage,recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ELSEIF (trim(recordname) != "")
     SET resultlistcnt = uar_srvgetitemcount(hrep,nullterm(recordname))
     IF (resultlistcnt=0)
      IF (validate(debug_ind,0)=1)
       CALL echo(build("ZERO RESULTS found in [",trim(recordname,3),"]"))
      ENDIF
      CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(nsrvstat),recorddata)
      IF (zeroforceexit=1)
       CALL exit_srvrequest(hmsg,hreq,hrep)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(nsrvstat),recorddata)
    CALL exit_srvrequest(hmsg,hreq,hrep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatesrvreply(nsrvstat=i4,recorddata=vc(ref),zeroforceexit=i2) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (nsrvstat=esrvok)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus="Z")
     CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(nsrvstat),recorddata)
     IF (zeroforceexit=1)
      CALL exit_srvrequest(hmsg,hreq,hrep)
      GO TO exit_script
     ENDIF
    ELSEIF (sstatus != "S")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(nsrvstat),recorddata)
    CALL exit_srvrequest(hmsg,hreq,hrep)
   ENDIF
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
 IF ( NOT (validate(mp_common_output_imported)))
  EXECUTE mp_common_output
 ENDIF
 FREE RECORD acr_params
 RECORD acr_params(
   1 chart_results[*]
     2 nomenclature_ids[*]
       3 nomenclature_id = f8
     2 event_cd = f8
     2 task_assay_cd = f8
     2 ocid = vc
     2 label_id = f8
     2 units_cd = f8
     2 value = vc
     2 ref_range_id = f8
   1 unchart_results[*]
     2 event_id = f8
     2 event_cd = f8
     2 event_status = vc
 )
 FREE RECORD eventcd_rec
 RECORD eventcd_rec(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD cr_reply
 RECORD cr_reply(
   1 script_exe_time = f8
   1 missing_unchart_privs_ind = i2
   1 missing_chart_privs_ind = i2
   1 failed_inerror_results_ind = i2
   1 error_signing_results_ind = i2
   1 signed_events[*]
     2 event_id = f8
     2 event_cd = f8
     2 ocid = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persist
 FREE RECORD unchart_result_data
 RECORD unchart_result_data(
   1 rep[*]
     2 sb
       3 severitycd = i4
       3 statuscd = i4
       3 statustext = vc
       3 substatuslist[*]
         4 substatuscd = i4
     2 rb_list[*]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 event_cd = f8
       3 result_status_cd = f8
       3 contributor_system_cd = f8
       3 reference_nbr = vc
       3 collating_seq = vc
       3 parent_event_id = f8
       3 prsnl_list[*]
         4 event_prsnl_id = f8
         4 action_prsnl_id = f8
         4 action_type_cd = f8
         4 action_dt_tm = dq8
         4 action_dt_tm_ind = i2
         4 action_tz = i4
         4 updt_cnt = i4
       3 clinical_event_id = f8
       3 updt_cnt = i4
       3 result_set_link_list[*]
         4 result_set_id = f8
         4 entry_type_cd = f8
         4 updt_cnt = i4
       3 ce_dynamic_label_id = f8
   1 dynamic_label_list[*]
     2 ce_dynamic_label_id = f8
     2 label_name = vc
     2 label_prsnl_id = f8
     2 label_status_cd = f8
     2 result_set_id = f8
     2 label_seq_nbr = i4
     2 valid_from_dt_tm = dq8
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist[*]
       3 substatuscd = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE uncharteventresults(null) = null WITH protect
 DECLARE handleresults(null) = null WITH protect
 DECLARE checkuserprivileges(null) = null WITH protect
 DECLARE geteventcdinfo(eventcd=f8) = null WITH protect
 DECLARE executechartresultsservice(null) = null WITH protect
 DECLARE uar_srvgetasis(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_axp =
 "srvrtl", image_aix = "libsrv.a(libsrv.o)", uar = "SrvGetAsIs",
 persist
 DECLARE putjsonrecordtofile(p1=vc(ref)) = null WITH protect
 DECLARE task_assay_cd = f8 WITH protect, noconstant(0.0)
 DECLARE event_cd_type = vc WITH protect, noconstant("")
 DECLARE script_begin_date_time = dq8 WITH constant(curtime3), private
 SET log_program_name = "cp_chart_clinical_results"
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 IF (validate(request->blob_in,"") != "")
  SET json_blob_in = trim(request->blob_in,3)
  IF (validate(debug_ind,0)=1)
   CALL echo(build2("Using request->blob_in: ",json_blob_in))
  ENDIF
 ELSE
  CALL log_message("Invalid json input",log_level_debug)
  GO TO exit_script
 ENDIF
 SET stat = cnvtjsontorec(json_blob_in)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(acr_params)
 ENDIF
 IF (size(acr_params->unchart_results,5) > 0)
  CALL uncharteventresults(null)
 ENDIF
 IF (size(acr_params->chart_results,5) > 0)
  CALL checkuserprivileges(null)
  CALL handleresults(null)
 ENDIF
 SUBROUTINE uncharteventresults(null)
   CALL log_message("Begin unchartEventResults()",log_level_debug)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE event_status = vc WITH protect, noconstant("")
   DECLARE event_id = f8 WITH protect, noconstant(0)
   DECLARE event_cd = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO size(acr_params->unchart_results,5))
     SET event_status = acr_params->unchart_results[j].event_status
     SET event_id = acr_params->unchart_results[j].event_id
     SET event_cd = acr_params->unchart_results[j].event_cd
     IF (event_cd > 0
      AND ((event_status="AUTHVERIFIED") OR (event_status="INPROGRESS")) )
      SET debug_ind = 1
      FREE RECORD check_priv_request
      SET stat = initrec(unchart_result_data)
      EXECUTE inn_mp_unchart_result "NOFORMS",  $PERSON_ID,  $INPUTPROVIDERID,
       $ENCNTR_ID, event_cd, event_id,
       $INPUTPPR WITH replace("REPORT_DATA","UNCHART_RESULT_DATA")
      SET debug_ind = 0
      IF ((unchart_result_data->status_data.status="F"))
       IF ((unchart_result_data->status_data.subeventstatus.operationname="ValidateUserPrivileges()")
       )
        SET cr_reply->missing_unchart_privs_ind = 1
       ELSE
        SET cr_reply->failed_inerror_results_ind = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message(build("Exit unchartEventResults(), Elapsed time in seconds:",((curtime3 -
     start_tm)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE checkuserprivileges(null)
   CALL log_message("Begin checkUserPrivileges()",log_level_debug)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE privviewres = i2 WITH protect, constant(0)
   DECLARE privadddoc = i2 WITH protect, constant(1)
   DECLARE privmoddoc = i2 WITH protect, constant(0)
   DECLARE privunchartdoc = i2 WITH protect, constant(0)
   DECLARE privsigndoc = i2 WITH protect, constant(0)
   FOR (j = 1 TO size(acr_params->chart_results,5))
    SET pos = locateval(k,1,size(eventcd_rec->qual,5),acr_params->chart_results[j].event_cd,
     eventcd_rec->qual[k].value)
    IF (pos=0)
     SET stat = alterlist(eventcd_rec->qual,j)
     SET eventcd_rec->qual[j].value = cnvtreal(acr_params->chart_results[j].event_cd)
    ENDIF
   ENDFOR
   SET eventcd_rec->cnt = size(eventcd_rec->qual,5)
   IF (validate(check_priv_request) != 1)
    RECORD check_priv_request(
      1 patient_user_criteria
        2 user_id = f8
        2 patient_user_relationship_cd = f8
      1 event_privileges
        2 event_set_level
          3 event_sets[*]
            4 event_set_name = vc
          3 view_results_ind = i2
          3 add_documentation_ind = i2
          3 modify_documentation_ind = i2
          3 unchart_documentation_ind = i2
          3 sign_documentation_ind = i2
        2 event_code_level
          3 event_codes[*]
            4 event_cd = f8
          3 view_results_ind = i2
          3 add_documentation_ind = i2
          3 modify_documentation_ind = i2
          3 unchart_documentation_ind = i2
          3 sign_documentation_ind = i2
    )
   ENDIF
   CALL validateuserprivileges(eventcd_rec,privviewres,privadddoc,privmoddoc,privunchartdoc,
    privsigndoc,cr_reply,0)
   CALL log_message(build("Exit checkUserPrivileges(), Elapsed time in seconds:",((curtime3 -
     start_tm)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE geteventcdinfo(event_cd,task_cd)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   CALL log_message("In getEventCdInfo()",log_level_debug)
   SELECT INTO "NL:"
    FROM discrete_task_assay dta
    PLAN (dta
     WHERE dta.active_ind=1
      AND dta.event_cd=event_cd)
    DETAIL
     event_cd_type = trim(uar_get_code_meaning(dta.default_result_type_cd),4)
     IF (task_cd=0)
      task_assay_cd = dta.task_assay_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getEventCdInfo(), Elapsed time in seconds:",((curtime3 - start_tm)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE executechartresultsservice(null)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   CALL log_message("In executeChartResultsService()",log_level_debug)
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE eventidx = i4 WITH protect, noconstant(0), protect
   DECLARE searchcntr = i4 WITH noconstant(0), protect
   DECLARE response_body = vc WITH protect, noconstant("")
   DECLARE response_size = i4 WITH protect, noconstant(0)
   DECLARE response = vc WITH protect, noconstant("")
   DECLARE clinical_json = vc WITH protect, noconstant("")
   DECLARE clinical_json_reply = vc WITH protect, noconstant("")
   DECLARE is_service_executed = i2 WITH protect, noconstant(0)
   SET is_service_executed = uar_srvexecute(hmsg3208713,hreq,hrep)
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("Service Executed?: ",is_service_executed))
   ENDIF
   IF (is_service_executed != 0)
    SET cr_reply->status_data.status = "F"
    SET cr_reply->error_signing_results_ind = 1
    SET cr_reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to contact Service to save the results."
    CALL log_message("Unable to contact Service to save the results.",log_level_debug)
    GO TO exit_script
   ENDIF
   SET response_body = uar_srvgetasisptr(hrep,"chart_results_json")
   SET response_size = uar_srvgetasissize(hrep,"chart_results_json")
   SET stat = memrealloc(response,response_size,"C1")
   CALL uar_srvgetasis(hrep,"chart_results_json",response,response_size)
   SET clinical_json = substring(1,response_size,response_body)
   SET clinical_json_reply = concat('{"CLINICAL_RESULTS": ',clinical_json,"}")
   SET stat = cnvtjsontorec(clinical_json_reply)
   DECLARE request_body = vc WITH protect
   SET request_body = uar_srvgetasisptr(hreq,"discrete_results")
   SET stat = cnvtjsontorec(concat('{"REQUEST_DATA": ',request_body,"}"))
   IF (validate(debug_ind,0)=1)
    CALL echorecord(request_data)
    CALL echo(build2("Service Response: ",clinical_json))
    CALL echo(build2("Concatinated string: ",clinical_json_reply))
    CALL echorecord(clinical_results)
   ENDIF
   SET hstatusstruct = uar_srvgetstruct(hrep,"status_data")
   IF (hstatusstruct=0)
    CALL echo("Invalid hStatusStruct returned from GetStruct")
    SET cr_reply->status_data.status = "F"
    SET cr_reply->error_signing_results_ind = 1
    SET cr_reply->status_data.subeventstatus[1].targetobjectvalue =
    "Invalid hStatusStruct returned from GetStruct"
    CALL log_message("Invalid hStatusStruct returned from GetStruct",log_level_debug)
    GO TO exit_script
   ENDIF
   SET sstatus = uar_srvgetstringptr(hstatusstruct,"status")
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("Service status: ",sstatus))
   ENDIF
   IF (sstatus="S")
    FOR (y = 1 TO size(clinical_results->data.successfulmeasurements,5))
      SET stat = alterlist(cr_reply->signed_events,y)
      SET eventidx = locateval(searchcntr,1,size(acr_params->chart_results,5),cnvtreal(
        clinical_results->data.successfulmeasurements[y].uniqueidentifier),cnvtreal(acr_params->
        chart_results[searchcntr].event_cd))
      SET cr_reply->signed_events[y].event_id = cnvtreal(clinical_results->data.
       successfulmeasurements[y].eventid)
      SET cr_reply->signed_events[y].event_cd = cnvtreal(clinical_results->data.
       successfulmeasurements[y].uniqueidentifier)
      SET cr_reply->signed_events[y].ocid = acr_params->chart_results[eventidx].ocid
    ENDFOR
   ELSEIF (sstatus="F")
    SET hsubeventstatus = uar_srvgetitem(hstatusstruct,"subeventstatus",0)
    SET cr_reply->status_data.subeventstatus[1].operationname = uar_srvgetstringptr(hsubeventstatus,
     "OperationName")
    SET cr_reply->status_data.subeventstatus[1].operationstatus = uar_srvgetstringptr(hsubeventstatus,
     "OperationStatus")
    SET cr_reply->status_data.subeventstatus[1].targetobjectname = uar_srvgetstringptr(
     hsubeventstatus,"TargetObjectName")
    SET cr_reply->status_data.subeventstatus[1].targetobjectvalue = uar_srvgetstringptr(
     hsubeventstatus,"TargetObjectValue")
   ENDIF
   IF (validate(clinical_results->data.failedmeasurements)=1)
    SET sstatus = "F"
    SET cr_reply->status_data.subeventstatus[1].targetobjectvalue = clinical_results->data.
    failedmeasurements.contents[1].failurereasonmessage
   ENDIF
   IF (sstatus="F")
    SET cr_reply->error_signing_results_ind = 1
   ENDIF
   SET cr_reply->status_data.status = sstatus
   CALL log_message(build("Exit executeChartResultsService(), Elapsed time in seconds:",((curtime3 -
     start_tm)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE handleresults(null)
   CALL log_message("Entering subroutine handleResults()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE current_dt_tm = dq8 WITH noconstant(cnvtdatetime(sysdate)), private
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE msg_3208713 = i4 WITH protect, constant(3208713)
   DECLARE request_source_cd = f8 WITH constant(uar_get_code_by("MEANING",30200,"CLINICIAN"))
   DECLARE request_entry_mode_cd = f8 WITH constant(uar_get_code_by("MEANING",29520,"CP_PATHWAY"))
   DECLARE event_cd = f8 WITH protect, noconstant(0.0)
   DECLARE label_id = f8 WITH protect, noconstant(0.0)
   DECLARE cur_date_time = vc WITH protect
   DECLARE upd_time = vc WITH protect
   DECLARE hmsg3208713 = i4 WITH protect, noconstant(0)
   SET hmsg3208713 = uar_srvselectmessage(msg_3208713)
   SET hreq = uar_srvcreaterequest(hmsg3208713)
   SET hrep = uar_srvcreatereply(hmsg3208713)
   SET cur_date_time = trim(format(cnvtdatetimeutc(current_dt_tm,3),"YYYY-MM-DDTHH:MM:SS.000Z;3;Q"))
   SET stat = uar_srvsetdouble(hreq,"prsnl_id", $INPUTPROVIDERID)
   SET stat = uar_srvsetdouble(hreq,"relationship_cd", $INPUTPPR)
   SET stat = uar_srvsetstring(hreq,"user_date_time",nullterm(cur_date_time))
   SET stat = uar_srvsetshort(hreq,"user_time_zone",datetimezonebyname(curtimezone))
   SET stat = uar_srvsetdouble(hreq,"entry_mode_cd",request_entry_mode_cd)
   SET stat = uar_srvsetdouble(hreq,"source_cd",request_source_cd)
   SET stat = uar_srvsetdouble(hreq,"person_id", $PERSON_ID)
   SET stat = uar_srvsetdouble(hreq,"encounter_id", $ENCNTR_ID)
   SET hdiscrete = uar_srvgetstruct(hreq,"discrete_results")
   FOR (i = 1 TO size(acr_params->chart_results,5))
     SET event_cd = cnvtreal(acr_params->chart_results[i].event_cd)
     SET label_id = cnvtreal(acr_params->chart_results[i].label_id)
     SET event_cd_type = ""
     SET task_assay_cd = cnvtreal(acr_params->chart_results[i].task_assay_cd)
     CALL geteventcdinfo(event_cd,task_assay_cd)
     CASE (event_cd_type)
      OF "3":
       SET hitem = uar_srvadditem(hdiscrete,"numeric_values")
       SET hrval = uar_srvgetstruct(hitem,"result_value")
       SET stat = uar_srvsetstring(hitem,"numeric_result_value",nullterm(acr_params->chart_results[i]
         .value))
      OF "8":
       SET hitem = uar_srvadditem(hdiscrete,"numeric_values")
       SET hrval = uar_srvgetstruct(hitem,"result_value")
       SET stat = uar_srvsetstring(hitem,"numeric_result_value",nullterm(acr_params->chart_results[i]
         .value))
      OF "7":
       SET hitem = uar_srvadditem(hdiscrete,"alpha_values")
       SET hrval = uar_srvgetstruct(hitem,"result_value")
       SET stat = uar_srvsetstring(hitem,"free_text_value",nullterm(acr_params->chart_results[i].
         value))
      OF "5":
      OF "2":
      OF "22":
      OF "21":
       SET hitem = uar_srvadditem(hdiscrete,"alpha_values")
       SET hrval = uar_srvgetstruct(hitem,"result_value")
       FOR (j = 1 TO size(acr_params->chart_results[i].nomenclature_ids,5))
        SET hnomenitem = uar_srvadditem(hitem,"nomenclature_ids")
        SET stat = uar_srvsetdouble(hnomenitem,"nomenclature_id",cnvtreal(acr_params->chart_results[i
          ].nomenclature_ids[j].nomenclature_id))
       ENDFOR
       IF (nullterm(acr_params->chart_results[i].value) != "")
        SET stat = uar_srvsetstring(hitem,"free_text_value",nullterm(acr_params->chart_results[i].
          value))
       ENDIF
     ENDCASE
     IF (( $CHART_DATE != ""))
      SET stat = uar_srvsetstring(hrval,"date_time",nullterm( $CHART_DATE))
     ELSE
      SET stat = uar_srvsetstring(hrval,"date_time",nullterm(cur_date_time))
     ENDIF
     IF (label_id != 0.0)
      SET stat = uar_srvsetdouble(hrval,"label_id",label_id)
     ENDIF
     SET stat = uar_srvsetdouble(hrval,"unique_id",event_cd)
     SET stat = uar_srvsetdouble(hrval,"event_cd",event_cd)
     SET stat = uar_srvsetdouble(hrval,"task_assay_cd",task_assay_cd)
     SET stat = uar_srvsetdouble(hitem,"unit_cd",cnvtreal(acr_params->chart_results[i].units_cd))
     SET stat = uar_srvsetdouble(hitem,"reference_range_id",cnvtreal(acr_params->chart_results[i].
       ref_range_id))
   ENDFOR
   CALL executechartresultsservice(null)
   CALL log_message(build("Exit handleResults(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 IF ((cr_reply->status_data.status="F")
  AND (cr_reply->status_data.subeventstatus[1].operationname="ValidateUserPrivileges()"))
  SET cr_reply->missing_chart_privs_ind = 1
 ENDIF
 SET cr_reply->script_exe_time = ((curtime3 - script_begin_date_time)/ 100.0)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(cr_reply)
 ENDIF
 CALL putjsonrecordtofile(cr_reply, $OUTDEV)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",cr_reply->script_exe_time),log_level_debug)
END GO
