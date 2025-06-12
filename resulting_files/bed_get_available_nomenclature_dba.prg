CREATE PROGRAM bed_get_available_nomenclature:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 custom_filter_items[*]
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 display = vc
      2 status_ind = i2
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(record_data,0)))
  RECORD record_data(
    1 available_searches[*]
      2 identifier = vc
      2 terminologies[*]
        3 identifier = vc
        3 subsets[*]
          4 identifier = vc
        3 axes[*]
          4 identifier = vc
      2 cross_mapped_terminologies[*]
        3 identifier = vc
        3 subsets[*]
          4 identifier = vc
        3 axes[*]
          4 identifier = vc
      2 size = i4
      2 display_name = vc
    1 status_data
      2 success_ind = i2
      2 debug_error_message = vc
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 IF ( NOT (validate(discerncurrentversion)))
  DECLARE discerncurrentversion = i4 WITH constant(cnvtint(build(format(currev,"##;P0"),format(
      currevminor,"##;P0"),format(currevminor2,"##;P0"))))
 ENDIF
 IF (validate(bedbeginscript,char(128))=char(128))
  DECLARE bedbeginscript(dummyvar=i2) = null
  SUBROUTINE bedbeginscript(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederror,char(128))=char(128))
  DECLARE bederror(errordescription=vc) = null
  SUBROUTINE bederror(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bedexitsuccess,char(128))=char(128))
  DECLARE bedexitsuccess(dummyvar=i2) = null
  SUBROUTINE bedexitsuccess(dummyvar)
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorcheck,char(128))=char(128))
  DECLARE bederrorcheck(errordescription=vc) = null
  SUBROUTINE bederrorcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscript,char(128))=char(128))
  DECLARE bedexitscript(commitind=i2) = null
  SUBROUTINE bedexitscript(commitind)
   CALL bederrorcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind)
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 IF (validate(bedgetlogicaldomain,char(128))=char(128))
  DECLARE bedgetlogicaldomain(dummyvar=i2) = f8
  SUBROUTINE bedgetlogicaldomain(dummyvar)
    DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
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
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
    RETURN(logicaldomainid)
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 IF (validate(bedgetexpandind,char(128))=char(128))
  DECLARE bedgetexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) = i2
  SUBROUTINE bedgetexpandind(_reccnt,_bindcnt)
    DECLARE nexpandval = i4 WITH noconstant(1)
    IF (discerncurrentversion >= 81002)
     SET nexpandval = 2
    ENDIF
    RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
  END ;Subroutine
 ENDIF
 IF (validate(getfeaturetoggle,char(128))=char(128))
  DECLARE getfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE getfeaturetoggle(pfeaturetogglekey,psystemidentifier)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logdebugmessage("getFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled))
     ELSE
      CALL logdebugmessage("getFeatureToggle","Call to sys_check_feature_toggle failed")
     ENDIF
    ELSE
     CALL logdebugmessage("getFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."))
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isfeaturetoggleenabled)))
  DECLARE isfeaturetoggleenabled(pparentfeaturekey=vc,pchildfeaturekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE isfeaturetoggleenabled(pparentfeaturekey,pchildfeaturekey,psystemidentifier)
    DECLARE isparentfeatureenabled = i2 WITH noconstant(false)
    DECLARE ischildfeatureenabled = i2 WITH noconstant(false)
    SET isparentfeatureenabled = getfeaturetoggle(pparentfeaturekey,psystemidentifier)
    IF (isparentfeatureenabled)
     SET ischildfeatureenabled = getfeaturetoggle(pchildfeaturekey,psystemidentifier)
    ENDIF
    CALL logdebugmessage("isFeatureToggleEnabled",build2(" Parent Feature Toggle - ",
      pparentfeaturekey," value is = ",isparentfeatureenabled," and Child Feature Toggle - ",
      pchildfeaturekey," value is = ",ischildfeatureenabled))
    RETURN(ischildfeatureenabled)
  END ;Subroutine
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
 CALL bedbeginscript(0)
 DECLARE request_number = i4 WITH protect, constant(4174073)
 DECLARE voc_count = i4 WITH protect, noconstant(0)
 DECLARE termcnt = i4 WITH protect, noconstant(0)
 DECLARE resultcnts = i4 WITH protect, noconstant(0)
 DECLARE tsubsetscnt = i4 WITH protect, noconstant(0)
 DECLARE taxescnt = i4 WITH protect, noconstant(0)
 DECLARE msubsetscnt = i4 WITH protect, noconstant(0)
 DECLARE maxescnt = i4 WITH protect, noconstant(0)
 DECLARE corrcnt = i4 WITH protect, noconstant(0)
 DECLARE populatenomenclatures(dummyvar=i4) = null WITH protect
 CALL populatenomenclatures(request_number)
 SET voc_count = size(record_data->available_searches,5)
 IF (voc_count > 0)
  SET stat = alterlist(reply->custom_filter_items,voc_count)
  FOR (x = 1 TO voc_count)
    SET reply->custom_filter_items[x].parent_entity_id = 0
    SET reply->custom_filter_items[x].parent_entity_name = ""
    SET reply->custom_filter_items[x].display = record_data->available_searches[x].display_name
    SET reply->custom_filter_items[x].description = record_data->available_searches[x].identifier
    SET reply->custom_filter_items[x].status_ind = 1
  ENDFOR
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE populatenomenclatures(requestnumber)
  DECLARE listtransactioncheck = i4 WITH protect, constant(uar_srvselectmessage(requestnumber))
  IF (listtransactioncheck != 0)
   CALL initializesrvrequest(record_data,requestnumber)
   SET nsrvstat = uar_srvexecute(hmsg,hreq,hrep)
   SET hrep = validatesrvreplyind(nsrvstat,record_data,1,"available_searches","status_data")
   IF (hrep)
    SET resultcnts = uar_srvgetitemcount(hrep,"available_searches")
    SET stat = alterlist(record_data->available_searches,resultcnts)
    CALL echo(build2("resultCntS is: ",resultcnts))
    IF (resultcnts > 0)
     FOR (i = 0 TO (resultcnts - 1))
       CALL echo(build2("i is: ",i))
       SET termcnt = 0
       SET hsearchs = uar_srvgetitem(hrep,"available_searches",i)
       SET record_data->available_searches[(i+ 1)].identifier = uar_srvgetstringptr(hsearchs,
        "identifier")
       SET termcnt = uar_srvgetitemcount(hsearchs,"terminologies")
       SET stat = alterlist(record_data->available_searches[(i+ 1)].terminologies,termcnt)
       CALL echo(build2("termCnt is: ",termcnt))
       FOR (a = 0 TO (termcnt - 1))
         SET curs = uar_srvgetitem(hsearchs,"terminologies",a)
         SET record_data->available_searches[(i+ 1)].terminologies[(a+ 1)].identifier =
         uar_srvgetstringptr(curs,"identifier")
         SET tsubsetscnt = uar_srvgetitemcount(curs,"subsets")
         CALL echo(build2("tSubSetsCnt is: ",tsubsetscnt))
         IF (tsubsetscnt)
          SET stat = alterlist(record_data->available_searches[(i+ 1)].terminologies[(a+ 1)].subsets,
           tsubsetscnt)
          FOR (b = 0 TO (tsubsetscnt - 1))
           SET hsubsets = uar_srvgetitem(curs,"subsets",b)
           SET record_data->available_searches[(i+ 1)].terminologies[(a+ 1)].subsets[(b+ 1)].
           identifier = uar_srvgetstringptr(hsubsets,"identifier")
          ENDFOR
         ENDIF
         SET taxescnt = uar_srvgetitemcount(curs,"axes")
         CALL echo(build2("tAxesCnt is: ",taxescnt))
         IF (taxescnt)
          SET stat = alterlist(record_data->available_searches[(i+ 1)].terminologies[(a+ 1)].axes,
           taxescnt)
          FOR (c = 0 TO (taxescnt - 1))
           SET haxess = uar_srvgetitem(curs,"axes",c)
           SET record_data->available_searches[(i+ 1)].terminologies[(a+ 1)].axes[(c+ 1)].identifier
            = uar_srvgetstringptr(haxess,"identifier")
          ENDFOR
         ENDIF
       ENDFOR
       SET corrcnt = uar_srvgetitemcount(hsearchs,"cross_mapped_terminologies")
       CALL echo(build2("CorrCnt is: ",corrcnt))
       IF (corrcnt)
        SET stat = alterlist(record_data->available_searches[(i+ 1)].cross_mapped_terminologies,
         corrcnt)
        FOR (d = 0 TO (corrcnt - 1))
          SET corrs = uar_srvgetitem(hsearchs,"cross_mapped_terminologies",d)
          SET record_data->available_searches[(i+ 1)].cross_mapped_terminologies[(d+ 1)].identifier
           = uar_srvgetstringptr(corrs,"identifier")
          SET msubsetscnt = uar_srvgetitemcount(corrs,"subsets")
          CALL echo(build2("mSubSetsCnt is: ",msubsetscnt))
          IF (msubsetscnt)
           SET stat = alterlist(record_data->available_searches[(i+ 1)].cross_mapped_terminologies[(d
            + 1)].subsets,msubsetscnt)
           FOR (e = 0 TO (msubsetscnt - 1))
            SET hsubsets = uar_srvgetitem(curs,"subsets",e)
            SET record_data->available_searches[(i+ 1)].cross_mapped_terminologies[(d+ 1)].subsets[(e
            + 1)].identifier = uar_srvgetstringptr(hsubsets,"identifier")
           ENDFOR
          ENDIF
          SET maxescnt = uar_srvgetitemcount(corrs,"axes")
          CALL echo(build2("mAxesCnt is: ",maxescnt))
          IF (maxescnt)
           SET stat = alterlist(record_data->available_searches[(i+ 1)].cross_mapped_terminologies[(d
            + 1)].axes,maxescnt)
           FOR (f = 0 TO maxescnt)
            SET haxess = uar_srvgetitem(curs,"axes",(f+ 1))
            SET record_data->available_searches[(i+ 1)].cross_mapped_terminologies[(d+ 1)].axes[(f+ 1
            )].identifier = uar_srvgetstringptr(haxess,"identifier")
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
       SET record_data->available_searches[(i+ 1)].size = uar_srvgetlong(hsearchs,"size")
       SET record_data->available_searches[(i+ 1)].display_name = uar_srvgetstringptr(hsearchs,
        "display_name")
     ENDFOR
     SET hstatuss = uar_srvgetstruct(hrep,"status_data")
     SET record_data->status_data.success_ind = uar_srvgetshort(hstatuss,"success_ind")
     SET record_data->status_data.debug_error_message = uar_srvgetstringptr(hstatuss,
      "debug_error_message")
    ENDIF
    IF (hreq != 0)
     SET stat = uar_srvdestroyinstance(hreq)
    ENDIF
    IF (hrep != 0)
     SET stat = uar_srvdestroyinstance(hrep)
    ENDIF
   ELSE
    IF (hreq != 0)
     SET stat = uar_srvdestroyinstance(hreq)
    ENDIF
    IF (hrep != 0)
     SET stat = uar_srvdestroyinstance(hrep)
    ENDIF
   ENDIF
  ELSE
   SET record_data->status_data.success_ind = 0
  ENDIF
 END ;Subroutine
END GO
