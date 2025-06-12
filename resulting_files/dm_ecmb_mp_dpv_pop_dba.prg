CREATE PROGRAM dm_ecmb_mp_dpv_pop:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 DECLARE dm_cmb_get_context(dummy=i2) = null
 DECLARE dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) = null
 SUBROUTINE dm_cmb_get_context(dummy)
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
 SUBROUTINE dm_cmb_exc_maint_status(s_dcems_status,s_dcems_msg,s_dcems_tname)
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
 DECLARE initializerequest(recorddata=vc(ref),requestnumber=i4(val)) = null WITH protect
 DECLARE initializeapptaskrequest(recorddata=vc(ref),applicationnumber=i4(val),tasknumber=i4(val),
  requestnumber=i4(val),donotexitonfail=i2(val,0)) = null WITH protect
 DECLARE exit_servicerequest(happ=i4,htask=i4,hstep=i4) = null WITH protect
 DECLARE handleerror(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc,
  recorddata=vc(ref)) = null WITH protect
 DECLARE handlenodata(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc,
  recorddata=vc(ref)) = null WITH protect
 DECLARE validatereply(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2) = i4 WITH protect
 DECLARE validatesubreply(ncrmstat=i4,hstep=i4,recorddata=vc(ref)) = i4 WITH protect
 DECLARE validatereplyindicator(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,recordname=
  vc) = i4 WITH protect
 DECLARE validatereplyindicatordynamic(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc,
  statusblock=vc) = i4 WITH protect
 DECLARE getproviderposition(prsnl_id=f8) = f8 WITH protect
 DECLARE createdatetimefromhandle(p1=i4(ref),p2=vc(val),p3=vc(val)) = vc WITH protect
 DECLARE initializesrvrequest(recorddata=vc(ref),requestnumber=i4(val),donotexitonfail=i2(val,0)) =
 null WITH protect
 DECLARE validatesrvreply(nsrvstat=i4,recorddata=vc(ref),zeroforceexit=i2) = i4 WITH protect
 DECLARE validatesrvreplyind(nsrvstat=i4,recorddata=vc(ref),zeroforceexit=i2,recordname=vc,
  statusblock=vc) = i4 WITH protect
 SUBROUTINE initializeapptaskrequest(recorddata,appnumber,tasknumber,requestnumber,donotexitonfail)
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
 SUBROUTINE initializerequest(recorddata,requestnumber)
   CALL initializeapptaskrequest(recorddata,lapp_num,ltask_num,requestnumber)
 END ;Subroutine
 SUBROUTINE initializesrvrequest(recorddata,requestnumber,donotexitonfail)
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
 SUBROUTINE getproviderposition(prsnl_id)
   DECLARE prsnl_position_cd = f8 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnl_id
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     prsnl_position_cd = p.position_cd
    WITH nocounter
   ;end select
   RETURN(prsnl_position_cd)
 END ;Subroutine
 SUBROUTINE createdatetimefromhandle(hhandle,sdatedataelement,stimezonedataelement)
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
 SUBROUTINE handleerror(operationname,operationstatus,targetobjectname,targetobjectvalue,recorddata)
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
 SUBROUTINE handlenodata(operationname,operationstatus,targetobjectname,targetobjectvalue,recorddata)
   SET recorddata->status_data.status = "Z"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE exit_servicerequest(happ,htask,hstep)
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
 SUBROUTINE validatereply(ncrmstat,hstep,recorddata,zeroforceexit)
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
 SUBROUTINE validatesubreply(ncrmstat,hstep,recorddata)
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
 SUBROUTINE validatereplyindicatordynamic(ncrmstat,hstep,recorddata,zeroforceexit,recordname,
  statusblock)
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
 SUBROUTINE validatereplyindicator(ncrmstat,hstep,recorddata,zeroforceexit,recordname)
   CALL validatereplyindicatordynamic(ncrmstat,hstep,recorddata,zeroforceexit,recordname,
    "status_data")
 END ;Subroutine
 SUBROUTINE validatesrvreplyind(nsrvstat,recorddata,zeroforceexit,recordname,statusblock)
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
 SUBROUTINE validatesrvreply(nsrvstat,recorddata,zeroforceexit)
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE reprime(personid=f8) = null WITH protect
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_loopcount1 = i4
 DECLARE d_from_person_id = f8
 SET v_cust_count1 = 0
 SET v_cust_loopcount1 = 0
 SET d_from_person_id = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "MP_DPV_POP"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "NONE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
#exit_sub
 FREE SET rreclist
END GO
