CREATE PROGRAM dm_pcmb_workflow_task_queue:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 SET escpok = 0
 SET escpinvalid = 1
 SET escpexists = 2
 SET escpfailure = 3
 SET escpnoaccess = 4
 SET emsgok = 0
 SET emsgcomerror = 1
 SET emsgdataerror = 2
 SET emsgrequesterror = 3
 SET emsgsecurityerror = 4
 SET emsgticketexpired = 5
 SET emsgresourceerror = 6
 SET emsginvalid = 7
 IF (validate(scp_addentry,99)=99)
  DECLARE oensit_scp_functions = i2 WITH persist
  SET oensit_scp_functions = 1
  DECLARE scp_addentry = i2 WITH persist
  DECLARE scp_removeentry = i2 WITH persist
  DECLARE scp_queryentry = i2 WITH persist
  DECLARE scp_modifyentry = i2 WITH persist
  DECLARE scp_modifyentrylogon = i2 WITH persist
  DECLARE scp_modifyentryprop = i2 WITH persist
  DECLARE scp_enumentries = i2 WITH persist
  DECLARE scp_enumprop = i2 WITH persist
  DECLARE scp_startserver = i2 WITH persist
  DECLARE scp_stopserver = i2 WITH persist
  DECLARE scp_killserver = i2 WITH persist
  DECLARE scp_queryserver = i2 WITH persist
  DECLARE scp_enumservers = i2 WITH persist
  DECLARE scp_queryservice = i2 WITH persist
  DECLARE scp_enumservices = i2 WITH persist
  DECLARE scp_getplatform = i2 WITH persist
  DECLARE scp_startdomain = i2 WITH persist
  DECLARE scp_stopdomain = i2 WITH persist
  DECLARE scp_killdomain = i2 WITH persist
  DECLARE scp_setprop = i2 WITH persist
  DECLARE scp_enumnodes = i2 WITH persist
  DECLARE scp_querydomain = i2 WITH persist
  DECLARE scp_fetchentry = i2 WITH persist
  DECLARE scp_fetchserver = i2 WITH persist
  DECLARE scp_fetchservice = i2 WITH persist
  DECLARE scp_setlogon = i2 WITH persist
  SET scp_addentry = 0
  SET scp_removeentry = 1
  SET scp_queryentry = 2
  SET scp_modifyentry = 3
  SET scp_modifyentrylogon = 4
  SET scp_modifyentryprop = 5
  SET scp_enumentries = 6
  SET scp_enumprop = 7
  SET scp_startserver = 8
  SET scp_stopserver = 9
  SET scp_killserver = 10
  SET scp_queryserver = 11
  SET scp_enumservers = 12
  SET scp_queryservice = 13
  SET scp_enumservices = 14
  SET scp_getplatform = 15
  SET scp_startdomain = 16
  SET scp_stopdomain = 17
  SET scp_killdomain = 18
  SET scp_setprop = 19
  SET scp_enumnodes = 20
  SET scp_querydomain = 21
  SET scp_fetchentry = 22
  SET scp_fetchserver = 23
  SET scp_fetchservice = 24
  SET scp_setlogon = 25
  DECLARE uar_oen_get_nodename() = c32 WITH persist
  DECLARE uar_float_to_double(p1=i4(value),p2=vc(ref)) = f8 WITH persist
  DECLARE uar_scpcreate(p1=vc(ref)) = i4 WITH image_axp = "dpsrtl", uar = "ScpCreate", image_aix =
  "libdps.a(libdps.o)",
  persist
  DECLARE uar_scpdestroy(p1=i4(value)) = null WITH image_axp = "dpsrtl", uar = "ScpDestroy",
  image_aix = "libdps.a(libdps.o)",
  persist
  DECLARE uar_scpselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dpsrtl", uar = "ScpSelect",
  image_aix = "libdps.a(libdps.o)",
  persist
  DECLARE uar_srvgetucharasint(p1=i4(value),p2=vc(ref)) = i1 WITH image_axp = "srvrtl", image_aix =
  "libsrv.a(libsrv.o)", uar = "SrvGetUChar",
  persist
 ENDIF
 DECLARE iswtpserveravailable(dummy) = i2
 SUBROUTINE (writerowtowtp(pwtptaskrequest=vc,ptaskident=vc,pentityid=f8,pentityname=vc,pprocessdttm=
  dq8,ptaskdatatxt=vc) =i2)
   CALL logmessage("writeRowToWTP","Entering",log_debug)
   RECORD wtpsaverequest(
     1 requestjson = vc
     1 processdttm = dq8
     1 taskident = vc
     1 entityid = f8
     1 entityname = vc
     1 taskdatatxt = vc
   ) WITH protect
   RECORD wtpsavereply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   IF (((size(trim(pwtptaskrequest,3)) <= 0) OR (size(trim(ptaskident,3)) <= 0)) )
    CALL addtracemessage("writeRowToWTP",
     "Missing task name and/or request JSON to add task to WTP queue.")
    RETURN(false)
   ENDIF
   SET wtpsaverequest->requestjson = pwtptaskrequest
   SET wtpsaverequest->processdttm = evaluate(pprocessdttm,0.0,cnvtdatetime(sysdate),pprocessdttm)
   SET wtpsaverequest->taskident = ptaskident
   IF (pentityid > 0.0
    AND size(trim(pentityname,3)) > 0)
    SET wtpsaverequest->entityname = pentityname
    SET wtpsaverequest->entityid = pentityid
   ENDIF
   IF (size(trim(ptaskdatatxt,3)) > 0)
    SET wtpsaverequest->taskdatatxt = trim(ptaskdatatxt,3)
   ENDIF
   IF (validate(debug,0) > 0)
    CALL echorecord(wtpsaverequest)
   ENDIF
   IF (checkprg("WTP_WORKFLOW_TASK_SAVE") <= 0)
    CALL addtracemessage("writeRowToWTP",
     "WTP_WORKFLOW_TASK_SAVE script doesn't exist in CCL dictionary.")
    RETURN(false)
   ENDIF
   EXECUTE wtp_workflow_task_save  WITH replace("REQUEST",wtpsaverequest), replace("REPLY",
    wtpsavereply)
   IF ((wtpsavereply->status_data.status != "S"))
    CALL addtracemessage("writeRowToWTP","WTP_WORKFLOW_TASK_SAVE returned failure.")
    RETURN(false)
   ENDIF
   CALL logmessage("writeRowToWTP","Exiting",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE iswtpserveravailable(dummy)
   CALL logmessage("isWTPServerAvailable","Entering",log_debug)
   DECLARE instancecount = i4
   DECLARE hscp = i4
   DECLARE hmsg = i4
   DECLARE hreq = i4
   DECLARE hrep = i4
   DECLARE wtpserver_entry = i4 WITH protect, constant(477)
   SET hscp = uar_scpcreate(nullterm(curnode))
   SET hmsg = uar_scpselect(hscp,scp_fetchserver)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hrep = uar_srvcreatereply(hmsg)
   SET stat = uar_srvexecute(hmsg,hreq,hrep)
   IF (stat != emsgok)
    SET stat = alterlist(errlog->entity,1)
    CASE (stat)
     OF emsgcomerror:
      CALL logmessage("isWTPServerAvailable","Communication error; no server available",log_info)
     OF emsgdataerror:
      CALL logmessage("isWTPServerAvailable","Data inconsistency or mismatch in message",log_info)
     OF emsgrequesterror:
      CALL logmessage("isWTPServerAvailable","No handler to service request",log_info)
     OF emsgsecurityerror:
      CALL logmessage("isWTPServerAvailable",
       "Program is not logged in or unable to acquire service ticket",log_info)
     OF emsgticketexpired:
      CALL logmessage("isWTPServerAvailable","Security ticket has expired",log_info)
     OF emsgresourceerror:
      CALL logmessage("isWTPServerAvailable","No available memory or associated resource",log_info)
     OF emsginvalid:
      CALL logmessage("isWTPServerAvailable","Handle is not valid",log_info)
    ENDCASE
    CALL uar_scpdestroy(hscp)
    RETURN(false)
   ENDIF
   SET nbr_entries = uar_srvgetitemcount(hrep,"serverlist")
   FOR (idx = 0 TO (nbr_entries - 1))
    SET hitem = uar_srvgetitem(hrep,"serverlist",idx)
    IF (uar_srvgetushort(hitem,"entryid")=wtpserver_entry)
     SET instancecount += 1
    ENDIF
   ENDFOR
   CALL uar_scpdestroy(hscp)
   IF (instancecount <= 0)
    RETURN(false)
   ENDIF
   CALL logmessage("isWTPServerAvailable","Exiting",log_debug)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE writecombinesrowtowtp(pwtptaskrequest,ptaskident,pentityid,pentityname,pprocessdttm,
  ptaskdatatxt)
   CALL logmessage("writeCombinesRowToWTP","Entering",log_debug)
   RECORD wtpsaverequest(
     1 requestjson = vc
     1 processdttm = dq8
     1 taskident = vc
     1 entityid = f8
     1 entityname = vc
     1 taskdatatxt = vc
   ) WITH protect
   RECORD wtpsavereply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   IF (((size(trim(pwtptaskrequest,3)) <= 0) OR (size(trim(ptaskident,3)) <= 0)) )
    CALL addtracemessage("writeCombinesRowToWTP",
     "Missing task name and/or request JSON to add task to WTP queue.")
    RETURN(false)
   ENDIF
   SET wtpsaverequest->requestjson = pwtptaskrequest
   SET wtpsaverequest->processdttm = evaluate(pprocessdttm,0.0,cnvtdatetime(sysdate),pprocessdttm)
   SET wtpsaverequest->taskident = ptaskident
   IF (pentityid > 0.0
    AND size(trim(pentityname,3)) > 0)
    SET wtpsaverequest->entityname = pentityname
    SET wtpsaverequest->entityid = pentityid
   ENDIF
   IF (size(trim(ptaskdatatxt,3)) > 0)
    SET wtpsaverequest->taskdatatxt = trim(ptaskdatatxt,3)
   ENDIF
   IF (validate(debug,0) > 0)
    CALL echorecord(wtpsaverequest)
   ENDIF
   IF (checkprg("WTP_WORKFLOW_TASK_SAVE") <= 0)
    CALL addtracemessage("writeCombinesRowToWTP",
     "WTP_WORKFLOW_TASK_SAVE script doesn't exist in CCL dictionary.")
    RETURN(false)
   ENDIF
   EXECUTE wtp_workflow_task_save  WITH replace("REQUEST",wtpsaverequest), replace("REPLY",
    wtpsavereply)
   IF ((wtpsavereply->status_data.status != "S"))
    CALL addtracemessage("writeCombinesRowToWTP","WTP_WORKFLOW_TASK_SAVE returned failure.")
    RETURN(false)
   ENDIF
   CALL logmessage("writeCombinesRowToWTP","Exiting",log_debug)
   RETURN(true)
 END ;Subroutine
 CALL echo("Begin PFT_LOGICAL_DOMAIN_SUBS.INC, version [714452.014 w/o 002,005,007,008,009,010]")
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 IF ( NOT (validate(profitlogicaldomaininfo)))
  RECORD profitlogicaldomaininfo(
    1 hasbeenset = i2
    1 logicaldomainid = f8
    1 logicaldomainsystemuserid = f8
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(ld_concept_batch_trans)))
  DECLARE ld_concept_batch_trans = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_event)))
  DECLARE ld_concept_pft_event = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_ruleset)))
  DECLARE ld_concept_pft_ruleset = i2 WITH public, constant(ld_concept_person)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_queue_item_wf_hist)))
  DECLARE ld_concept_pft_queue_item_wf_hist = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_concept_pft_workflow)))
  DECLARE ld_concept_pft_workflow = i2 WITH public, constant(ld_concept_prsnl)
 ENDIF
 IF ( NOT (validate(ld_entity_account)))
  DECLARE ld_entity_account = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(ld_entity_adjustment)))
  DECLARE ld_entity_adjustment = vc WITH protect, constant("ADJUSTMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_balance)))
  DECLARE ld_entity_balance = vc WITH protect, constant("BALANCE")
 ENDIF
 IF ( NOT (validate(ld_entity_charge)))
  DECLARE ld_entity_charge = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(ld_entity_claim)))
  DECLARE ld_entity_claim = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(ld_entity_encounter)))
  DECLARE ld_entity_encounter = vc WITH protect, constant("ENCOUNTER")
 ENDIF
 IF ( NOT (validate(ld_entity_invoice)))
  DECLARE ld_entity_invoice = vc WITH protect, constant("INVOICE")
 ENDIF
 IF ( NOT (validate(ld_entity_payment)))
  DECLARE ld_entity_payment = vc WITH protect, constant("PAYMENT")
 ENDIF
 IF ( NOT (validate(ld_entity_person)))
  DECLARE ld_entity_person = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(ld_entity_pftencntr)))
  DECLARE ld_entity_pftencntr = vc WITH protect, constant("PFTENCNTR")
 ENDIF
 IF ( NOT (validate(ld_entity_statement)))
  DECLARE ld_entity_statement = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(getlogicaldomain)))
  SUBROUTINE (getlogicaldomain(concept=i4,logicaldomainid=f8(ref)) =i2)
    CALL logmessage("getLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     IF (((concept < ld_concept_minvalue) OR (concept > ld_concept_maxvalue)) )
      CALL logmessage("getLogicalDomain",build2("Invalid logical domain concept: ",concept),log_error
       )
      RETURN(false)
     ENDIF
     FREE RECORD acm_get_curr_logical_domain_req
     RECORD acm_get_curr_logical_domain_req(
       1 concept = i4
     )
     FREE RECORD acm_get_curr_logical_domain_rep
     RECORD acm_get_curr_logical_domain_rep(
       1 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     DECLARE currentuserid = f8 WITH protect, constant(reqinfo->updt_id)
     IF ((profitlogicaldomaininfo->hasbeenset=true))
      SET reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
     ENDIF
     SET acm_get_curr_logical_domain_req->concept = concept
     EXECUTE acm_get_curr_logical_domain
     SET reqinfo->updt_id = currentuserid
     IF ((acm_get_curr_logical_domain_rep->status_block.status_ind != true))
      CALL logmessage("getLogicalDomain","Failed to retrieve logical domain...",log_error)
      CALL echorecord(acm_get_curr_logical_domain_rep)
      RETURN(false)
     ENDIF
     SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
     CALL logmessage("getLogicalDomain",build2("Logical domain for concept [",trim(cnvtstring(concept
         )),"]: ",trim(cnvtstring(logicaldomainid))),log_debug)
     FREE RECORD acm_get_curr_logical_domain_req
     FREE RECORD acm_get_curr_logical_domain_rep
    ELSE
     SET logicaldomainid = 0.0
    ENDIF
    CALL logmessage("getLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getlogicaldomainforentitytype(pentityname=vc,prlogicaldomainid=f8(ref)) =i2)
   DECLARE entityconcept = i4 WITH protect, noconstant(0)
   CASE (pentityname)
    OF value(ld_entity_person,ld_entity_encounter,ld_entity_pftencntr):
     SET entityconcept = ld_concept_person
    OF value(ld_entity_claim,ld_entity_invoice,ld_entity_statement,ld_entity_adjustment,
    ld_entity_charge,
    ld_entity_payment,ld_entity_account,ld_entity_balance):
     SET entityconcept = ld_concept_organization
   ENDCASE
   RETURN(getlogicaldomain(entityconcept,prlogicaldomainid))
 END ;Subroutine
 IF ( NOT (validate(setlogicaldomain)))
  SUBROUTINE (setlogicaldomain(logicaldomainid=f8) =i2)
    CALL logmessage("setLogicalDomain","Entering...",log_debug)
    IF (arelogicaldomainsinuse(0))
     SELECT INTO "nl:"
      FROM logical_domain ld
      WHERE ld.logical_domain_id=logicaldomainid
      DETAIL
       profitlogicaldomaininfo->logicaldomainsystemuserid = ld.system_user_id
      WITH nocounter
     ;end select
     SET profitlogicaldomaininfo->logicaldomainid = logicaldomainid
     SET profitlogicaldomaininfo->hasbeenset = true
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE (p.person_id=reqinfo->updt_id)
      DETAIL
       IF (p.logical_domain_id != logicaldomainid)
        reqinfo->updt_id = profitlogicaldomaininfo->logicaldomainsystemuserid
       ENDIF
      WITH nocounter
     ;end select
     IF (validate(debug,0))
      CALL echorecord(profitlogicaldomaininfo)
      CALL echo(build("reqinfo->updt_id:",reqinfo->updt_id))
     ENDIF
    ENDIF
    CALL logmessage("setLogicalDomain","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(arelogicaldomainsinuse)))
  DECLARE arelogicaldomainsinuse(null) = i2
  SUBROUTINE arelogicaldomainsinuse(null)
    CALL logmessage("areLogicalDomainsInUse","Entering...",log_debug)
    DECLARE multiplelogicaldomainsdefined = i2 WITH protect, noconstant(false)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id > 0.0
      AND ld.active_ind=true
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET multiplelogicaldomainsdefined = true
    ENDIF
    CALL logmessage("areLogicalDomainsInUse",build2("Multiple logical domains ",evaluate(
       multiplelogicaldomainsdefined,true,"are","are not")," in use"),log_debug)
    CALL logmessage("areLogicalDomainsInUse","Exiting...",log_debug)
    RETURN(multiplelogicaldomainsdefined)
  END ;Subroutine
 ENDIF
 SUBROUTINE (getparameterentityname(dparmcd=f8) =vc)
   DECLARE parammeaning = vc WITH private, constant(trim(uar_get_code_meaning(dparmcd)))
   DECLARE returnvalue = vc WITH private, noconstant("")
   SET returnvalue = evaluate(parammeaning,"BEID","BILLING_ENTITY","OPTIONALBEID","BILLING_ENTITY",
    "HP ID","HEALTH_PLAN","HP_LIST","HEALTH_PLAN","PRIMARYHP",
    "HEALTH_PLAN","PRIPAYORHPID","HEALTH_PLAN","SECPAYORHPID","HEALTH_PLAN",
    "TERPAYORHPID","HEALTH_PLAN","COLLAGENCY","ORGANIZATION","PAYORORGID",
    "ORGANIZATION","PRECOLAGENCY","ORGANIZATION","PRIPAYORORGI","ORGANIZATION",
    "SECPAYORORGI","ORGANIZATION","TERPAYORORGI","ORGANIZATION","PAYER_LIST",
    "ORGANIZATION","UNKNOWN")
   RETURN(returnvalue)
 END ;Subroutine
 SUBROUTINE (paramsarevalidfordomain(paramstruct=vc(ref),dlogicaldomainid=f8) =i2)
   DECLARE paramidx = i4 WITH private, noconstant(0)
   DECLARE paramentityname = vc WITH private, noconstant("")
   DECLARE paramvalue = f8 WITH protect, noconstant(0.0)
   DECLARE paramerror = i2 WITH protect, noconstant(false)
   FOR (paramidx = 1 TO paramstruct->lparams_qual)
     SET paramentityname = getparameterentityname(paramstruct->aparams[paramidx].dvalue_meaning)
     SET paramvalue = cnvtreal(paramstruct->aparams[paramidx].svalue)
     SET paramerror = true
     IF (paramentityname="BILLING_ENTITY")
      SELECT INTO "nl:"
       FROM billing_entity be,
        organization o
       PLAN (be
        WHERE be.billing_entity_id=paramvalue)
        JOIN (o
        WHERE o.organization_id=be.organization_id
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="HEALTH_PLAN")
      SELECT INTO "nl:"
       FROM health_plan hp
       PLAN (hp
        WHERE hp.health_plan_id=paramvalue
         AND hp.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSEIF (paramentityname="ORGANIZATION")
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE o.organization_id=paramvalue
         AND o.logical_domain_id=dlogicaldomainid)
       DETAIL
        paramerror = false
       WITH nocounter
      ;end select
     ELSE
      SET paramerror = false
     ENDIF
     IF (paramerror)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 IF ( NOT (validate(getlogicaldomainsystemuser)))
  SUBROUTINE (getlogicaldomainsystemuser(logicaldomainid=f8(ref)) =f8)
    DECLARE systempersonnelid = f8 WITH protect, noconstant(0.0)
    SELECT INTO "nl:"
     FROM logical_domain ld
     WHERE ld.logical_domain_id=logicaldomainid
     DETAIL
      systempersonnelid = ld.system_user_id
     WITH nocounter
    ;end select
    IF (systempersonnelid <= 0.0)
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE p.active_ind=true
       AND p.logical_domain_id=logicaldomainid
       AND p.username="SYSTEM"
      DETAIL
       systempersonnelid = p.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (systempersonnelid <= 0.0)
     CALL logmessage("getLogicalDomainSystemUser",
      "Failed to determine the default 'SYSTEM' personnel id",log_error)
     RETURN(0.0)
    ENDIF
    CALL logmessage("getLogicalDomainSystemUser","Exiting",log_debug)
    RETURN(systempersonnelid)
  END ;Subroutine
 ENDIF
 RECORD wtptaskrequest(
   1 smode = vc
   1 cmb_qual_cnt = i4
   1 cmb_qual[1]
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 ids_qual_cnt = i4
     2 ids_qual[1]
       3 additional_id = f8
   1 wtpflag = i2
   1 activityuserid = i4
 ) WITH protect
 DECLARE usewtpframework = i2 WITH protect, noconstant(true)
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE ispersoncombinequeueable = i2 WITH protect, noconstant(true)
 IF (call_script="DM_UNCOMBINE")
  GO TO exit_sub
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "WORKFLOW_TASK_QUEUE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_WORKFLOW_TASK_QUEUE"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 CALL processpersoncombtowtp(0)
 SUBROUTINE (processpersoncombtowtp(dummy=i2) =null)
   IF ((request->parent_table="PERSON")
    AND (request->xxx_combine[icombine].encntr_id=0.0))
    SET wtptaskrequest->smode = "PERSON_COMBINE"
    SET wtptaskrequest->cmb_qual[1].from_xxx_id = request->xxx_combine[icombine].from_xxx_id
    SET wtptaskrequest->cmb_qual[1].to_xxx_id = request->xxx_combine[icombine].to_xxx_id
    IF ((wtptaskrequest->cmb_qual[1].from_xxx_id != 0))
     SELECT INTO "nl:"
      FROM person_combine_det pcd
      PLAN (pcd
       WHERE (pcd.entity_id=wtptaskrequest->cmb_qual[1].from_xxx_id)
        AND pcd.entity_name="WORKFLOW_TASK_QUEUE"
        AND pcd.active_ind=true)
     ;end select
     IF (curqual)
      SET ispersoncombinequeueable = false
     ENDIF
    ENDIF
   ELSEIF ((request->parent_table="PERSON")
    AND (request->xxx_combine[icombine].encntr_id != 0.0))
    SET wtptaskrequest->smode = "ENCOUNTER_MOVE"
    SET wtptaskrequest->cmb_qual[1].from_xxx_id = request->xxx_combine[icombine].from_xxx_id
    SET wtptaskrequest->cmb_qual[1].to_xxx_id = request->xxx_combine[icombine].to_xxx_id
    SET wtptaskrequest->cmb_qual[1].ids_qual[1].additional_id = request->xxx_combine[icombine].
    encntr_id
    IF ((wtptaskrequest->cmb_qual[1].from_xxx_id != 0)
     AND (wtptaskrequest->cmb_qual[1].to_xxx_id != 0))
     SELECT INTO "nl:"
      FROM person_combine pc
      PLAN (pc
       WHERE (pc.encntr_id=wtptaskrequest->cmb_qual[1].ids_qual[1].additional_id)
        AND (pc.from_person_id=wtptaskrequest->cmb_qual[1].from_xxx_id)
        AND (pc.to_person_id=wtptaskrequest->cmb_qual[1].to_xxx_id)
        AND pc.active_ind=true
        AND pc.person_combine_id IN (
       (SELECT
        max(pcd.person_combine_id)
        FROM person_combine_det pcd
        WHERE (pcd.entity_id=wtptaskrequest->cmb_qual[1].ids_qual[1].additional_id)
         AND pcd.entity_name="WORKFLOW_TASK_QUEUE"
         AND pcd.active_ind=true)))
      WITH nocounter
     ;end select
     IF (curqual)
      SET ispersoncombinequeueable = false
     ENDIF
    ENDIF
   ENDIF
   SET wtptaskrequest->activityuserid = reqinfo->updt_id
   SET wtptaskrequest->wtpflag = true
   IF ( NOT (getlogicaldomain(ld_concept_organization,logicaldomainid)))
    SET failed = select_error
    SET request->error_message = "Failed to get Logical Domain Id"
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="PROFIT_WORKFLOW"
      AND d.info_name="DISABLE_FIN_COMBINES_WTP"
      AND d.info_domain_id=logicaldomainid
      AND d.info_number > 0.0)
    DETAIL
     usewtpframework = false
    WITH nocounter
   ;end select
   IF (usewtpframework)
    IF (ispersoncombinequeueable)
     IF ((wtptaskrequest->smode="PERSON_COMBINE"))
      SET icombinedet += 1
      SET stat = alterlist(request->xxx_combine_det,icombinedet)
      SET request->xxx_combine_det[icombinedet].combine_action_cd = add
      SET request->xxx_combine_det[icombinedet].entity_id = wtptaskrequest->cmb_qual[1].from_xxx_id
      SET request->xxx_combine_det[icombinedet].entity_name = "WORKFLOW_TASK_QUEUE"
      SET request->xxx_combine_det[icombinedet].attribute_name = "ENTITY_ID"
     ELSEIF ((wtptaskrequest->smode="ENCOUNTER_MOVE"))
      SET icombinedet += 1
      SET stat = alterlist(request->xxx_combine_det,icombinedet)
      SET request->xxx_combine_det[icombinedet].combine_action_cd = add
      SET request->xxx_combine_det[icombinedet].entity_id = wtptaskrequest->cmb_qual[1].ids_qual[1].
      additional_id
      SET request->xxx_combine_det[icombinedet].entity_name = "WORKFLOW_TASK_QUEUE"
      SET request->xxx_combine_det[icombinedet].attribute_name = "ENTITY_ID"
     ENDIF
     IF ( NOT (writecombinesrowtowtp(cnvtrectojson(wtptaskrequest),"PFT_COMBINE_CLINICAL_ENCOUNTER",
      wtptaskrequest->cmb_qual[1].from_xxx_id,request->parent_table,cnvtdatetime(sysdate),
      "")))
      SET failed = insert_error
      SET request->error_message = "Failed to write combine item to workflow_task_queue table"
      GO TO exit_sub
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_sub
END GO
