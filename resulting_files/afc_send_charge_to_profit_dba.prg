CREATE PROGRAM afc_send_charge_to_profit:dba
 CALL echo(build("Executing AFC_SEND_CHARGE_TO_PROFIT, version [",nullterm("553184.001"),"]"))
 CALL echo("Begin PFT_EVAL_CHRG_POSTING_RULES_SUBS.INC, version [724294.008]")
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
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
 IF (validate(isequal,char(128))=char(128))
  SUBROUTINE (isequal(amount1=f8,amount2=f8) =i2)
   DECLARE tmpdiff = f8 WITH private, noconstant(abs((abs(amount1) - abs(amount2))))
   IF (tmpdiff < 0.009)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
  END ;Subroutine
 ENDIF
 CALL echo(build("Begin PFT_DIAGNOSIS_MAPPING_SUBS.INC, version [",nullterm("418045.004"),"]"))
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(nomenlist)))
  RECORD nomenlist(
    1 targetdiagnosistype = f8
    1 objarray[*]
      2 encntrid = f8
      2 chargeitemid = f8
      2 nomenlist[*]
        3 chargeeventmodid = f8
        3 chargemodid = f8
        3 nomenclatureid = f8
        3 diagtypecd = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(codes)))
  RECORD codes(
    1 codes[*]
      2 conceptcki = vc
      2 sourcenomenid = f8
      2 ckis[*]
        3 cki = vc
        3 groupsequence = i4
  ) WITH protect
 ENDIF
 IF ( NOT (validate(diagnosismap)))
  RECORD diagnosismap(
    1 objarray[*]
      2 encntrid = f8
      2 chargeitemid = f8
      2 diagnosis[*]
        3 chargeeventmodid = f8
        3 chargemodid = f8
        3 sourcenomenid = f8
        3 maptypeflg = f8
        3 synonyms[*]
          4 nomenid = f8
          4 sourceident = vc
          4 description = vc
        3 diagtypecd = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(synonymlist)))
  RECORD synonymlist(
    1 synonymlist[*]
      2 nomenid = f8
      2 sourceidentifier = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(sortlist)))
  RECORD sortlist(
    1 sortlist[*]
      2 targetcki = vc
      2 groupsequence = i4
  ) WITH protect
 ENDIF
 IF ( NOT (validate(srv_invalid_handle)))
  DECLARE srv_invalid_handle = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(srv_msg_ok)))
  DECLARE srv_msg_ok = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(one_to_one_mapping)))
  DECLARE one_to_one_mapping = f8 WITH protect, constant(1.0)
 ENDIF
 IF ( NOT (validate(one_to_many_mapping)))
  DECLARE one_to_many_mapping = f8 WITH protect, constant(2.0)
 ENDIF
 IF ( NOT (validate(no_mapping)))
  DECLARE no_mapping = f8 WITH protect, constant(3.0)
 ENDIF
 IF ( NOT (validate(icd9_effective_dt_tm)))
  RECORD icddatereply(
    1 icd9endeffectivedate = dq8
    1 icd10compliancedate = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
  EXECUTE afc_get_icd_compliance_date  WITH replace("REPLY",icddatereply)
  IF ((icddatereply->status_data.status="F"))
   RETURN(false)
  ENDIF
  DECLARE icd9_effective_dt_tm = f8 WITH protect, constant(cnvtdatetime(icddatereply->
    icd9endeffectivedate))
 ENDIF
 DECLARE hhandlernamesrvmsg = i4 WITH protect, noconstant(0)
 DECLARE hhandlernamesrvreq = i4 WITH protect, noconstant(0)
 DECLARE hhandlernamesrvrep = i4 WITH protect, noconstant(0)
 DECLARE msgstatus = i4 WITH protect, noconstant(1)
 DECLARE iconceptcount = i4 WITH protect, noconstant(0)
 DECLARE nomenloop = i4 WITH protect, noconstant(0)
 DECLARE objarrayloop = i4 WITH protect, noconstant(0)
 DECLARE isyncnt = i4 WITH protect, noconstant(0)
 DECLARE currentencounterid = f8 WITH protect, noconstant(0)
 DECLARE currentdiagtypecd = f8 WITH protect, noconstant(0)
 DECLARE previousencounterid = f8 WITH protect, noconstant(0)
 DECLARE previousdiagtypecd = f8 WITH protect, noconstant(0)
 DECLARE getsynonyms(null) = i2
 SUBROUTINE (prepareejstransaction(prsvrreq=i4(ref),prsvrrep=i4(ref),prsvrmsg=i4(ref),preqnumber=i4
  ) =i2)
   SET prsvrmsg = uar_srvselectmessage(preqnumber)
   IF (validate(debug,0)=1)
    CALL echo(build("prepareEJSTransaction() prSvrMsg=",prsvrmsg))
   ENDIF
   IF (prsvrmsg=srv_invalid_handle)
    CALL logmessage("prepareEJSTransaction","uar_SrvSelectMessage did not return successfully.",
     log_debug)
    RETURN(false)
   ENDIF
   SET prsvrreq = uar_srvcreaterequest(prsvrmsg)
   IF (validate(debug,0)=1)
    CALL echo(build("prepareEJSTransaction() prSvrReq=",prsvrreq))
   ENDIF
   IF (prsvrreq=srv_invalid_handle)
    CALL logmessage("prepareEJSTransaction","uar_SrvCreateRequest did not return successfully.",
     log_debug)
    RETURN(false)
   ENDIF
   SET prsvrrep = uar_srvcreatereply(prsvrmsg)
   IF (validate(debug,0)=1)
    CALL echo(build("prepareEJSTransaction() prSvrRep=",prsvrrep))
   ENDIF
   IF (prsvrrep=srv_invalid_handle)
    CALL logmessage("prepareEJSTransaction","uar_SrvCreateReply did not return successfully.",
     log_debug)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (cleanupsrvhandles(psrvreq=i4,psrvrep=i4,psrvmsg=i4,psrvstatus=i4) =i2)
   IF (validate(psrvreq))
    CALL uar_srvdestroyinstance(psrvreq)
   ENDIF
   IF (validate(psrvrep))
    CALL uar_srvdestroyinstance(psrvrep)
   ENDIF
   IF (validate(psrvmsg))
    CALL uar_srvdestroyinstance(psrvmsg)
   ENDIF
   IF (validate(psrvstatus))
    CALL uar_srvdestroyinstance(psrvstatus)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getdiagnosismap(nomenlist=vc,diagnosismap=vc(ref)) =i2)
   DECLARE l_handler_name_req = i4 WITH protect, constant(4174016)
   DECLARE hhandlernomens = i4 WITH protect, noconstant(0)
   DECLARE hnomenclatures = i4 WITH protect, noconstant(0)
   DECLARE scki = vc WITH protect, noconstant("")
   FOR (objarrayloop = 1 TO size(nomenlist->objarray,5))
     SET stat = initrec(synonymlist)
     SET isyncnt = 0
     SET stat = alterlist(diagnosismap->objarray,objarrayloop)
     SET currentencounterid = nomenlist->objarray[objarrayloop].encntrid
     SET diagnosismap->objarray[objarrayloop].encntrid = currentencounterid
     SET diagnosismap->objarray[objarrayloop].chargeitemid = nomenlist->objarray[objarrayloop].
     chargeitemid
     FOR (nomenloop = 1 TO size(nomenlist->objarray[objarrayloop].nomenlist,5))
       SET stat = prepareejstransaction(hhandlernamesrvreq,hhandlernamesrvrep,hhandlernamesrvmsg,
        l_handler_name_req)
       IF (stat=srv_invalid_handle)
        RETURN(false)
       ENDIF
       SET hhandlernomens = uar_srvadditem(hhandlernamesrvreq,"nomenclature_ids")
       SET stat = uar_srvsetdouble(hhandlernomens,"id",nomenlist->objarray[objarrayloop].nomenlist[
        nomenloop].nomenclatureid)
       SET msgstatus = uar_srvexecute(hhandlernamesrvmsg,hhandlernamesrvreq,hhandlernamesrvrep)
       IF (validate(debug,0)=1)
        CALL echo("Nomen_GetNomenclaturesByIds(4174016)")
        CALL uar_oen_dump_object(hhandlernamesrvreq)
        CALL uar_oen_dump_object(hhandlernamesrvrep)
       ENDIF
       IF (msgstatus != srv_msg_ok)
        CALL logmessage("getDiagnosisMap",
         "Unable to retrieve cki for source nomenclature id.  Service call failed.",log_debug)
        RETURN(false)
       ENDIF
       SET hnomenclatures = uar_srvgetitem(hhandlernamesrvrep,"nomenclatures",0)
       IF (hnomenclatures != srv_invalid_handle)
        SET stat = alterlist(diagnosismap->objarray[objarrayloop].diagnosis,nomenloop)
        SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].chargeeventmodid = nomenlist->
        objarray[objarrayloop].nomenlist[nomenloop].chargeeventmodid
        SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].chargemodid = nomenlist->
        objarray[objarrayloop].nomenlist[nomenloop].chargemodid
        SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].sourcenomenid = nomenlist->
        objarray[objarrayloop].nomenlist[nomenloop].nomenclatureid
        SET currentdiagtypecd = nomenlist->objarray[objarrayloop].nomenlist[nomenloop].diagtypecd
        SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].diagtypecd = currentdiagtypecd
        SET scki = fillstring(255,char(0))
        CALL uar_srvgetstring(hnomenclatures,"cki",scki,uar_srvgetstringlen(hnomenclatures,"cki"))
        CALL cleanupsrvhandles(hhandlernamesrvreq,hhandlernamesrvrep,hhandlernamesrvmsg,msgstatus)
        IF ( NOT (getconcept(scki,nomenlist->objarray[objarrayloop].nomenlist[nomenloop].
         nomenclatureid)))
         RETURN(false)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getconcept(pcki=vc,psourcenomenid=f8) =i2)
   DECLARE l_handler_name_req = i4 WITH protect, constant(4174018)
   DECLARE hhandlerconcepts = i4 WITH protect, noconstant(0)
   DECLARE hconcept = i4 WITH protect, noconstant(0)
   DECLARE hassociations = i4 WITH protect, noconstant(0)
   DECLARE htarget = i4 WITH protect, noconstant(0)
   DECLARE hnomenclatures = i4 WITH protect, noconstant(0)
   DECLARE fconceptsource = f8 WITH protect, noconstant(0)
   DECLARE fnomenclatureid = f8 WITH protect, noconstant(0)
   DECLARE ivtermind = i4 WITH protect, noconstant(0)
   DECLARE stargetcki = c255 WITH noconstant(fillstring(255," "))
   DECLARE ssourceconceptcki = c255 WITH noconstant(fillstring(255," "))
   DECLARE icountas = i4 WITH protect, noconstant(0)
   DECLARE icountasidx = i4 WITH protect, noconstant(0)
   DECLARE icountcki = i4 WITH protect, noconstant(0)
   DECLARE inomencnt = i4 WITH protect, noconstant(0)
   DECLARE inomenidx = i4 WITH protect, noconstant(0)
   DECLARE isortcnt = i4 WITH protect, noconstant(0)
   DECLARE igroupsequence = i4 WITH protect, noconstant(0)
   SET stat = prepareejstransaction(hhandlernamesrvreq,hhandlernamesrvrep,hhandlernamesrvmsg,
    l_handler_name_req)
   IF (stat=srv_invalid_handle)
    RETURN(false)
   ENDIF
   SET hhandlerconcepts = uar_srvadditem(hhandlernamesrvreq,"concept_cki")
   SET stat = uar_srvsetstring(hhandlerconcepts,"cki",trim(pcki))
   SET stat = uar_srvsetshort(hhandlerconcepts,"preferred_nomenclature_flag",1)
   SET msgstatus = uar_srvexecute(hhandlernamesrvmsg,hhandlernamesrvreq,hhandlernamesrvrep)
   IF (validate(debug,0)=1)
    CALL echo("Nomen_GetConceptAssociationByCki(4174018)")
    CALL uar_oen_dump_object(hhandlernamesrvreq)
    CALL uar_oen_dump_object(hhandlernamesrvrep)
   ENDIF
   IF (msgstatus != srv_msg_ok)
    CALL logmessage("getConcept",
     "Unable to retrieve related concept ckis for source nomenclature id.  Service call failed.",
     log_debug)
    RETURN(false)
   ENDIF
   SET hconcept = uar_srvgetitem(hhandlernamesrvrep,"concepts",0)
   IF (hconcept != srv_invalid_handle)
    SET iconceptcount += 1
    SET stat = alterlist(codes->codes,iconceptcount)
    CALL uar_srvgetstring(hconcept,"concept_cki",ssourceconceptcki,uar_srvgetstringlen(hconcept,
      "concept_cki"))
    SET codes->codes[iconceptcount].conceptcki = trim(ssourceconceptcki)
    SET codes->codes[iconceptcount].sourcenomenid = psourcenomenid
    SET icountas = uar_srvgetitemcount(hconcept,"associations")
    IF (icountas > 0)
     SET stat = initrec(sortlist)
     SET isortcnt = 0
     FOR (icountasidx = 1 TO icountas)
       SET stargetcki = fillstring(255,char(0))
       SET hassociations = uar_srvgetitem(hconcept,"associations",(icountasidx - 1))
       IF (hassociations != srv_invalid_handle)
        SET htarget = uar_srvgetstruct(hassociations,"target_concept")
        IF (htarget != srv_invalid_handle)
         CALL uar_srvgetstring(htarget,"cki",stargetcki,uar_srvgetstringlen(htarget,"cki"))
         SET igroupsequence = uar_srvgetlong(hassociations,"group_sequence")
         IF (icountas > 1)
          SET isortcnt += 1
          SET stat = alterlist(sortlist->sortlist,isortcnt)
          SET sortlist->sortlist[isortcnt].targetcki = trim(stargetcki)
          SET sortlist->sortlist[isortcnt].groupsequence = igroupsequence
         ELSE
          SET icountcki += 1
          SET stat = alterlist(codes->codes[iconceptcount].ckis,icountcki)
          SET codes->codes[iconceptcount].ckis[icountcki].cki = trim(stargetcki)
          SET codes->codes[iconceptcount].ckis[icountcki].groupsequence = igroupsequence
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (icountas > 1)
      SELECT INTO "nl:"
       target_cki = notrim(substring(1,255,sortlist->sortlist[d.seq].targetcki)), group_seq =
       sortlist->sortlist[d.seq].groupsequence
       FROM (dummyt d  WITH seq = value(icountas))
       ORDER BY group_seq, target_cki
       DETAIL
        icountcki += 1, stat = alterlist(codes->codes[iconceptcount].ckis,icountcki), codes->codes[
        iconceptcount].ckis[icountcki].cki = target_cki,
        codes->codes[iconceptcount].ckis[icountcki].groupsequence = group_seq
       WITH nocounter
      ;end select
     ENDIF
     IF ( NOT (getsynonyms(null)))
      RETURN(false)
     ENDIF
    ELSE
     SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].maptypeflg = no_mapping
    ENDIF
   ELSE
    SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].maptypeflg = no_mapping
   ENDIF
   CALL cleanupsrvhandles(hhandlernamesrvreq,hhandlernamesrvrep,hhandlernamesrvmsg,msgstatus)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getsynonyms(null)
   DECLARE l_handler_name_req = i4 WITH protect, constant(4174013)
   DECLARE hhandlernomens = i4 WITH protect, noconstant(0)
   DECLARE hnomenclatures = i4 WITH protect, noconstant(0)
   DECLARE hnomenclaturesynonyms = i4 WITH protect, noconstant(0)
   DECLARE fnomenclatureid = f8 WITH protect, noconstant(0)
   DECLARE fterminologycd = f8 WITH protect, noconstant(0)
   DECLARE ivtermind = i4 WITH protect, noconstant(0)
   DECLARE ickicount = i4 WITH protect, noconstant(0)
   DECLARE ickicountidx = i4 WITH protect, noconstant(0)
   DECLARE inomencnt = i4 WITH protect, noconstant(0)
   DECLARE inomencntidx = i4 WITH protect, noconstant(0)
   DECLARE inomensyncnt = i4 WITH protect, noconstant(0)
   DECLARE inomensynprimarycnt = i4 WITH protect, noconstant(0)
   DECLARE inomensynidx = i4 WITH protect, noconstant(0)
   DECLARE ssourceidentifier = c50 WITH noconstant(fillstring(50," "))
   DECLARE sdescription = c500 WITH noconstant(fillstring(500," "))
   DECLARE xindex = i4 WITH protect, noconstant(0)
   DECLARE idxmapsynidx = i4 WITH protect, noconstant(0)
   SET stat = prepareejstransaction(hhandlernamesrvreq,hhandlernamesrvrep,hhandlernamesrvmsg,
    l_handler_name_req)
   IF (stat=srv_invalid_handle)
    RETURN(false)
   ENDIF
   SET ickicount = size(codes->codes[iconceptcount].ckis,5)
   FOR (ickicountidx = 1 TO ickicount)
     SET hhandlernomens = uar_srvadditem(hhandlernamesrvreq,"nomenclatures")
     SET stat = uar_srvsetstring(hhandlernomens,"cki",nullterm(trim(codes->codes[iconceptcount].ckis[
        ickicountidx].cki)))
     SET stat = uar_srvsetdate(hhandlernomens,"effective_dt_tm",icd9_effective_dt_tm)
   ENDFOR
   SET msgstatus = uar_srvexecute(hhandlernamesrvmsg,hhandlernamesrvreq,hhandlernamesrvrep)
   IF (validate(debug,0)=1)
    CALL echo("Nomen_GetNomenclatureSynonymsByCki(4174013)")
    CALL uar_oen_dump_object(hhandlernamesrvreq)
    CALL uar_oen_dump_object(hhandlernamesrvrep)
   ENDIF
   IF (msgstatus != srv_msg_ok)
    CALL logmessage("getSynonyms",
     "Unable to retrieve synonyms for related concept ckis.  Service call failed.",log_debug)
    RETURN(false)
   ENDIF
   SET inomencnt = uar_srvgetitemcount(hhandlernamesrvrep,"nomenclatures")
   FOR (inomencntidx = 1 TO inomencnt)
    SET hnomenclatures = uar_srvgetitem(hhandlernamesrvrep,"nomenclatures",(inomencntidx - 1))
    IF (hnomenclatures != srv_invalid_handle)
     SET inomensyncnt = uar_srvgetitemcount(hnomenclatures,"nomenclature_synonyms")
     FOR (inomensynidx = 1 TO inomensyncnt)
      SET hnomenclaturesynonyms = uar_srvgetitem(hnomenclatures,"nomenclature_synonyms",(inomensynidx
        - 1))
      IF (hnomenclaturesynonyms != srv_invalid_handle)
       SET fterminologycd = uar_srvgetdouble(hnomenclaturesynonyms,"terminology_cd")
       IF ((fterminologycd=nomenlist->targetdiagnosistype))
        SET ivtermind = uar_srvgetshort(hnomenclaturesynonyms,"primary_vterm_ind")
        IF (ivtermind)
         SET ssourceidentifier = fillstring(50,char(0))
         SET sdescription = fillstring(500,char(0))
         SET inomensynprimarycnt += 1
         SET fnomenclatureid = uar_srvgetdouble(hnomenclaturesynonyms,"nomenclature_id")
         CALL uar_srvgetstring(hnomenclaturesynonyms,"source_identifier",ssourceidentifier,
          uar_srvgetstringlen(hnomenclaturesynonyms,"source_identifier"))
         IF (previousencounterid=currentencounterid
          AND previousdiagtypecd != currentdiagtypecd)
          SET stat = initrec(synonymlist)
          SET isyncnt = 0
         ENDIF
         IF (locateval(xindex,1,size(synonymlist->synonymlist,5),trim(ssourceidentifier),synonymlist
          ->synonymlist[xindex].sourceidentifier)=0)
          SET isyncnt += 1
          SET stat = alterlist(synonymlist->synonymlist,isyncnt)
          SET synonymlist->synonymlist[isyncnt].nomenid = fnomenclatureid
          SET synonymlist->synonymlist[isyncnt].sourceidentifier = trim(ssourceidentifier)
          SET idxmapsynidx += 1
          SET stat = alterlist(diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].synonyms,
           idxmapsynidx)
          SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].synonyms[idxmapsynidx].
          nomenid = fnomenclatureid
          SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].synonyms[idxmapsynidx].
          sourceident = trim(ssourceidentifier)
          CALL uar_srvgetstring(hnomenclaturesynonyms,"description",sdescription,uar_srvgetstringlen(
            hnomenclaturesynonyms,"description"))
          SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].synonyms[idxmapsynidx].
          description = trim(sdescription)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   SET previousencounterid = currentencounterid
   SET previousdiagtypecd = currentdiagtypecd
   IF (inomensynprimarycnt=1)
    SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].maptypeflg = one_to_one_mapping
   ELSEIF (inomensynprimarycnt > 1)
    SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].maptypeflg = one_to_many_mapping
   ELSE
    SET diagnosismap->objarray[objarrayloop].diagnosis[nomenloop].maptypeflg = no_mapping
   ENDIF
   CALL cleanupsrvhandles(hhandlernamesrvreq,hhandlernamesrvrep,hhandlernamesrvmsg,msgstatus)
   RETURN(true)
 END ;Subroutine
 CALL echo(build("Begin PFT_GET_ICD_PREF_SETTING_SUBS.INC, version [",nullterm("267003.001"),"]"))
 IF ( NOT (validate(dminforequest)))
  FREE RECORD dminforequest
  RECORD dminforequest(
    1 info_name_qual = i2
    1 info[*]
      2 info_name = vc
    1 info_name = vc
  )
 ENDIF
 IF ( NOT (validate(dminforeply)))
  RECORD dminforeply(
    1 dm_info_qual = i2
    1 dm_info[*]
      2 info_name = vc
      2 info_date = dq8
      2 info_char = vc
      2 info_number = f8
      2 info_long_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(geticdpreference,char(128))=char(128))
  DECLARE geticdpreference(null) = i2
  SUBROUTINE geticdpreference(null)
    SET dminforequest->info_name_qual = 4
    SET stat = alterlist(dminforequest->info,4)
    SET dminforequest->info[1].info_name = "ICD PRINCIPAL DIAGNOSIS TYPE"
    SET dminforequest->info[2].info_name = "ICD PRINCIPAL PROCEDURE TYPE"
    SET dminforequest->info[3].info_name = "SECONDARY ICD PRINCIPAL DIAGNOSIS TYPE"
    SET dminforequest->info[4].info_name = "SECONDARY ICD PRINCIPAL PROCEDURE TYPE"
    EXECUTE afc_get_dm_info  WITH replace("REQUEST",dminforequest), replace("REPLY",dminforeply)
    IF ((dminforeply->status_data.status="F"))
     RETURN(false)
    ENDIF
    RETURN(true)
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
 IF ( NOT (validate(ein_trans_alias_elements)))
  DECLARE ein_trans_alias_elements = i4 WITH protect, constant(21)
 ENDIF
 IF ( NOT (validate(ein_trans_alias)))
  DECLARE ein_trans_alias = i4 WITH protect, constant(20)
 ENDIF
 IF ( NOT (validate(map_error)))
  DECLARE map_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(new_map)))
  DECLARE new_map = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(no_map)))
  DECLARE no_map = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(pa_team_name)))
  DECLARE pa_team_name = vc WITH protect, constant("PATIENT_ACCOUNTING")
 ENDIF
 IF ( NOT (validate(icd_prof_capability_ident)))
  DECLARE icd_prof_capability_ident = vc WITH protect, constant("2014.1.00184.1")
 ENDIF
 IF ( NOT (validate(pft_encntr_entity_name)))
  DECLARE pft_encntr_entity_name = vc WITH protect, constant("FINANCIAL_ENCOUNTER")
 ENDIF
 IF ( NOT (validate(multi_guarantor_capability_ident)))
  DECLARE multi_guarantor_capability_ident = vc WITH protect, constant("2016.2.00220.1")
 ENDIF
 IF ( NOT (validate(cs20549_discount_adj_cd)))
  DECLARE cs20549_discount_adj_cd = f8 WITH protect, constant(getcodevalue(20549,"DISCOUNT ADJ",0))
 ENDIF
 IF ( NOT (validate(cs18937_disc_adj_cd)))
  DECLARE cs18937_disc_adj_cd = f8 WITH protect, constant(getcodevalue(18937,"DISC ADJ",0))
 ENDIF
 IF ( NOT (validate(cs18649_adjust_cd)))
  DECLARE cs18649_adjust_cd = f8 WITH protect, constant(getcodevalue(18649,"ADJUST",0))
 ENDIF
 IF ( NOT (validate(cs14002_icd_cd)))
  DECLARE cs14002_icd_cd = f8 WITH protect, constant(getcodevalue(14002,"ICD9",0))
 ENDIF
 IF ( NOT (validate(cs13019_mod_type_cd)))
  DECLARE cs13019_mod_type_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs21749_hcfa_1500_cd)))
  DECLARE cs21749_hcfa_1500_cd = f8 WITH protect, constant(getcodevalue(21749,"HCFA_1500",0))
 ENDIF
 IF ( NOT (validate(cs25753_reversal_cd)))
  DECLARE cs25753_reversal_cd = f8 WITH protect, constant(getcodevalue(25753,"REVERSAL",0))
 ENDIF
 IF ( NOT (validate(cs24269_history_cd)))
  DECLARE cs24269_history_cd = f8 WITH protect, constant(getcodevalue(24269,"HISTORY",1))
 ENDIF
 RECORD chargepbmrequest(
   1 eventkey = vc
   1 categorykey = vc
   1 htask = i4
   1 objarray[*]
     2 corspactivityid = f8
     2 activityid = f8
     2 pftchargeid = f8
     2 pftencntrid = f8
     2 encounterid = f8
     2 insurancebalanceid = f8
     2 scheventid = f8
     2 referralid = f8
     2 eventid = f8
     2 eventparams[*]
       3 paramkey = vc
       3 doublevalue = f8
       3 stringvalue = vc
       3 datevalue = dq8
       3 parententityname = vc
       3 parententityid = f8
       3 paramgroup = i4
     2 eventparamgroupcount = i4
     2 personid = f8
     2 billingentityid = f8
     2 accountid = f8
     2 schentryid = f8
 ) WITH protect
 RECORD chargepbmreply(
   1 rulesets[*]
     2 rulesetkey = vc
     2 eventkey = vc
     2 categorykey = vc
     2 objarray[*]
       3 corspactivityid = f8
       3 activityid = f8
       3 pftchargeid = f8
       3 pftencntrid = f8
       3 encounterid = f8
       3 insurancebalanceid = f8
       3 scheventid = f8
       3 referralid = f8
       3 actions[*]
         4 actionkey = vc
         4 params[*]
           5 paramkey = vc
           5 paramtype = vc
           5 paramvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (validate(checkchargeforwriteoff,char(128))=char(128))
  SUBROUTINE (checkchargeforwriteoff(ppftchargeid=f8,practionkey=vc(ref)) =i2)
    SET stat = alterlist(chargepbmrequest->objarray,1)
    SET chargepbmrequest->objarray[1].pftchargeid = ppftchargeid
    SET chargepbmrequest->categorykey = "CHRGPOST"
    SET chargepbmrequest->eventkey = "CHRG_WRITEOFF"
    EXECUTE pft_eval_pbm_rules  WITH replace("REQUEST",chargepbmrequest), replace("REPLY",
     chargepbmreply)
    IF ((chargepbmreply->status_data.status="F"))
     CALL logmessage("checkChargeForWriteoff","PFT_EVAL_PBM_RULES failed",log_error)
     RETURN(false)
    ELSEIF ((chargepbmreply->status_data.status="Z"))
     CALL logmessage("checkChargeForWriteoff","No Charge Rules to Evaluate",log_debug)
    ENDIF
    SET practionkey = trim(chargepbmreply->rulesets[1].objarray[1].actions[1].actionkey,3)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(checkchargesforwriteoffandgetaliases,char(128))=char(128))
  SUBROUTINE (checkchargesforwriteoffandgetaliases(prcharges=vc(ref)) =i2)
    DECLARE chargeindex = i4 WITH protect, noconstant(0)
    DECLARE actionsindex = i4 WITH protect, noconstant(0)
    DECLARE paramindex = i4 WITH protect, noconstant(0)
    DECLARE transaliasindex = i4 WITH protect, noconstant(0)
    DECLARE locatevalindex = i4 WITH protect, noconstant(0)
    DECLARE defaulttransid = f8 WITH protect, noconstant(0.0)
    IF (size(prcharges->charges,5) < 1)
     CALL logmessage("checkChargesForWriteoffAndGetAliases","No charges to check",log_debug)
     RETURN(true)
    ENDIF
    RECORD transaliases(
      1 objarray[*]
        2 transaliasid = f8
        2 transaliastypecd = f8
        2 transaliassubtypecd = f8
        2 transreasoncd = f8
        2 drcrflag = i2
    ) WITH protect
    RECORD transaliasfindrequest(
      1 objarray[*]
        2 trans_alias_id = f8
        2 trans_type_cd = f8
        2 trans_sub_type_cd = f8
        2 trans_reason_cd = f8
    ) WITH protect
    RECORD transaliasfindreply(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD objtransalias(
      1 proxy_ind = i2
      1 obj_vrsn_1 = f8
      1 ein_type = i4
      1 objarray[*]
        2 trans_alias_id = f8
        2 trans_type_cd = f8
        2 trans_type_disp = vc
        2 trans_type_desc = vc
        2 trans_type_mean = vc
        2 trans_type_code_set = i4
        2 trans_sub_type_cd = f8
        2 trans_sub_type_disp = vc
        2 trans_sub_type_desc = vc
        2 trans_sub_type_mean = vc
        2 trans_sub_type_code_set = i4
        2 trans_reason_cd = f8
        2 trans_reason_disp = vc
        2 trans_reason_desc = vc
        2 trans_reason_mean = vc
        2 trans_reason_code_set = i4
        2 dr_cr_flag = i2
        2 pft_trans_alias = vc
        2 edi_ind = i2
        2 pft_trans_alias_cd = f8
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD objdefaulttransalias(
      1 proxy_ind = i2
      1 obj_vrsn_1 = f8
      1 ein_type = i4
      1 objarray[*]
        2 trans_alias_id = f8
        2 trans_type_cd = f8
        2 trans_type_disp = vc
        2 trans_type_desc = vc
        2 trans_type_mean = vc
        2 trans_type_code_set = i4
        2 trans_sub_type_cd = f8
        2 trans_sub_type_disp = vc
        2 trans_sub_type_desc = vc
        2 trans_sub_type_mean = vc
        2 trans_sub_type_code_set = i4
        2 trans_reason_cd = f8
        2 trans_reason_disp = vc
        2 trans_reason_desc = vc
        2 trans_reason_mean = vc
        2 trans_reason_code_set = i4
        2 dr_cr_flag = i2
        2 pft_trans_alias = vc
        2 edi_ind = i2
        2 pft_trans_alias_cd = f8
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET stat = alterlist(chargepbmrequest->objarray,size(prcharges->charges,5))
    SET chargepbmrequest->categorykey = "CHRGPOST"
    SET chargepbmrequest->eventkey = "CHRG_WRITEOFF"
    FOR (chargeindex = 1 TO size(prcharges->charges,5))
      SET chargepbmrequest->objarray[chargeindex].pftchargeid = prcharges->charges[chargeindex].
      pftchargeid
    ENDFOR
    EXECUTE pft_eval_pbm_rules  WITH replace("REQUEST",chargepbmrequest), replace("REPLY",
     chargepbmreply)
    IF ((chargepbmreply->status_data.status="F"))
     CALL logmessage("checkChargeForWriteoff","PFT_EVAL_PBM_RULES failed",log_error)
     RETURN(false)
    ELSEIF ((chargepbmreply->status_data.status="Z"))
     CALL logmessage("checkChargeForWriteoff","No Charge Rules to Evaluate",log_debug)
    ENDIF
    SET stat = alterlist(transaliasfindrequest->objarray,1)
    SET transaliasfindrequest->objarray[1].trans_type_cd = cs18649_adjust_cd
    SET transaliasfindrequest->objarray[1].trans_sub_type_cd = cs20549_discount_adj_cd
    SET transaliasfindrequest->objarray[1].trans_reason_cd = cs18937_disc_adj_cd
    SET objtransalias->ein_type = ein_trans_alias_elements
    EXECUTE pft_trans_alias_find  WITH replace("REQUEST",transaliasfindrequest), replace("OBJREPLY",
     objdefaulttransalias), replace("REPLY",transaliasfindreply)
    IF (size(objdefaulttransalias->objarray,5) > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(objdefaulttransalias->objarray,5)))
      PLAN (d
       WHERE (objtransalias->objarray[d.seq].dr_cr_flag=2))
      DETAIL
       defaulttransid = objtransalias->objarray[d.seq].trans_alias_id
      WITH nocounter
     ;end select
    ENDIF
    SET stat = initrec(transaliasfindrequest)
    FOR (chargeindex = 1 TO size(prcharges->charges,5))
      FOR (actionsindex = 1 TO size(chargepbmreply->rulesets[1].objarray[chargeindex].actions,5))
        IF (cnvtupper(trim(chargepbmreply->rulesets[1].objarray[chargeindex].actions[actionsindex].
          actionkey,3))="WRITEOFF")
         SET prcharges->charges[chargeindex].actionkey = "WRITEOFF"
         SET prcharges->charges[chargeindex].transaliasid = defaulttransid
         SET prcharges->charges[chargeindex].transaliastypecd = cs18649_adjust_cd
         SET prcharges->charges[chargeindex].transaliassubtypecd = cs20549_discount_adj_cd
         SET prcharges->charges[chargeindex].transreasoncd = cs18937_disc_adj_cd
         SET prcharges->charges[chargeindex].eintype = ein_trans_alias_elements
         SET prcharges->charges[chargeindex].drcrflag = 2
         FOR (paramindex = 1 TO size(chargepbmreply->rulesets[1].objarray[chargeindex].actions[
          actionsindex].params,5))
           IF (cnvtupper(trim(chargepbmreply->rulesets[1].objarray[chargeindex].actions[actionsindex]
             .params[paramindex].paramkey))="TRANS_ALIAS_ID")
            SET prcharges->charges[chargeindex].transaliasid = cnvtreal(substring(1,(findstring("^",
               chargepbmreply->rulesets[1].objarray[chargeindex].actions[actionsindex].params[
               paramindex].paramvalue) - 1),chargepbmreply->rulesets[1].objarray[chargeindex].
              actions[actionsindex].params[paramindex].paramvalue))
            SET prcharges->charges[chargeindex].eintype = ein_trans_alias
            SET transaliasindex = 0
            SET transaliasindex = locateval(locatevalindex,1,size(transaliases->objarray,5),prcharges
             ->charges[chargeindex].transaliasid,transaliases->objarray[locatevalindex].transaliasid)
            IF (transaliasindex=0)
             SET stat = alterlist(transaliasfindrequest->objarray,1)
             SET transaliasfindrequest->objarray[1].trans_alias_id = prcharges->charges[chargeindex].
             transaliasid
             SET objtransalias->ein_type = ein_trans_alias
             EXECUTE pft_trans_alias_find  WITH replace("REQUEST",transaliasfindrequest), replace(
              "OBJREPLY",objtransalias), replace("REPLY",transaliasfindreply)
             IF ((((transaliasfindreply->status_data.status != "S")) OR (size(objtransalias->objarray,
              5)=0)) )
              CALL logmessage("checkChargesForWriteoff",build2("Unable to find transaction alias: ",
                prcharges->charges[chargeindex].transaliasid),log_error)
              RETURN(false)
             ENDIF
             SET prcharges->charges[chargeindex].transaliastypecd = objtransalias->objarray[1].
             trans_type_cd
             SET prcharges->charges[chargeindex].transaliassubtypecd = objtransalias->objarray[1].
             trans_sub_type_cd
             SET prcharges->charges[chargeindex].transreasoncd = objtransalias->objarray[1].
             trans_reason_cd
             SET prcharges->charges[chargeindex].drcrflag = objtransalias->objarray[1].dr_cr_flag
             SET transaliasindex += 1
             SET stat = alterlist(transaliases->objarray,transaliasindex)
             SET transaliases->objarray[transaliasindex].transaliastypecd = objtransalias->objarray[1
             ].trans_type_cd
             SET transaliases->objarray[transaliasindex].transaliassubtypecd = objtransalias->
             objarray[1].trans_sub_type_cd
             SET transaliases->objarray[transaliasindex].transreasoncd = objtransalias->objarray[1].
             trans_reason_cd
             SET transaliases->objarray[transaliasindex].drcrflag = objtransalias->objarray[1].
             dr_cr_flag
            ELSE
             SET prcharges->charges[chargeindex].transaliastypecd = transaliases->objarray[
             transaliasindex].transaliastypecd
             SET prcharges->charges[chargeindex].transaliassubtypecd = transaliases->objarray[
             transaliasindex].transaliassubtypecd
             SET prcharges->charges[chargeindex].transreasoncd = transaliases->objarray[
             transaliasindex].transreasoncd
             SET prcharges->charges[chargeindex].drcrflag = transaliases->objarray[transaliasindex].
             drcrflag
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(applychargeleveladjustment,char(128))=char(128))
  SUBROUTINE (applychargeleveladjustment(pchargeactivityid=f8,ppftchargeid=f8,pprimarybohpreltnid=f8,
   pitemextendedprice=f8) =i2)
    DECLARE transaliasid = f8 WITH protect, noconstant(0.0)
    DECLARE transtypecd = f8 WITH protect, noconstant(cs18649_adjust_cd)
    DECLARE transsubtypecd = f8 WITH protect, noconstant(cs20549_discount_adj_cd)
    DECLARE transreasoncd = f8 WITH protect, noconstant(cs18937_disc_adj_cd)
    DECLARE paramcnt = i4 WITH protect, noconstant(0)
    DECLARE adjamount = f8 WITH protect, noconstant(0.0)
    DECLARE totaladjustments = f8 WITH protect, noconstant(0.0)
    DECLARE chargeremamountwithadjust = f8 WITH protect, noconstant(0.0)
    RECORD transaliasfindrequest(
      1 objarray[*]
        2 trans_alias_id = f8
        2 trans_type_cd = f8
        2 trans_sub_type_cd = f8
        2 trans_reason_cd = f8
    ) WITH protect
    RECORD transaliasfindreply(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD objtransalias(
      1 proxy_ind = i2
      1 obj_vrsn_1 = f8
      1 ein_type = i4
      1 objarray[*]
        2 trans_alias_id = f8
        2 trans_type_cd = f8
        2 trans_type_disp = vc
        2 trans_type_desc = vc
        2 trans_type_mean = vc
        2 trans_type_code_set = i4
        2 trans_sub_type_cd = f8
        2 trans_sub_type_disp = vc
        2 trans_sub_type_desc = vc
        2 trans_sub_type_mean = vc
        2 trans_sub_type_code_set = i4
        2 trans_reason_cd = f8
        2 trans_reason_disp = vc
        2 trans_reason_desc = vc
        2 trans_reason_mean = vc
        2 trans_reason_code_set = i4
        2 dr_cr_flag = i2
        2 pft_trans_alias = vc
        2 edi_ind = i2
        2 pft_trans_alias_cd = f8
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD applydiscadjreq(
      1 objarray[*]
        2 activity_id = f8
        2 trans_type_cd = f8
        2 trans_sub_type_cd = f8
        2 trans_reason_cd = f8
        2 trans_alias_id = f8
        2 amount = f8
        2 bo_hp_reltn_id = f8
        2 chrg_writeoff_ind = i2
    ) WITH protect
    RECORD applydiscadjrep(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SELECT INTO "nl:"
     FROM pft_trans_reltn ptr
     WHERE ptr.parent_entity_id=ppftchargeid
      AND ptr.parent_entity_name="PFTCHARGE"
      AND ptr.trans_type_cd=cs18649_adjust_cd
      AND ptr.active_ind=true
     DETAIL
      totaladjustments += evaluate(ptr.dr_cr_flag,2,(ptr.amount * - (1)),ptr.amount)
     WITH nocounter
    ;end select
    IF (cnvtupper(trim(chargepbmreply->rulesets[1].objarray[1].actions[1].actionkey))="WRITEOFF"
     AND (chargepbmreply->rulesets[1].objarray[1].pftchargeid=ppftchargeid))
     FOR (paramcnt = 1 TO size(chargepbmreply->rulesets[1].objarray[1].actions[1].params,5))
       IF (cnvtupper(trim(chargepbmreply->rulesets[1].objarray[1].actions[1].params[paramcnt].
         paramkey))="TRANS_ALIAS_ID")
        SET transaliasid = cnvtreal(substring(1,(findstring("^",chargepbmreply->rulesets[1].objarray[
           1].actions[1].params[paramcnt].paramvalue) - 1),chargepbmreply->rulesets[1].objarray[1].
          actions[1].params[paramcnt].paramvalue))
       ENDIF
     ENDFOR
     SET stat = alterlist(transaliasfindrequest->objarray,1)
     IF (transaliasid > 0.0)
      SET transaliasfindrequest->objarray[1].trans_alias_id = transaliasid
      SET objtransalias->ein_type = ein_trans_alias
     ELSE
      SET transaliasfindrequest->objarray[1].trans_type_cd = cs18649_adjust_cd
      SET transaliasfindrequest->objarray[1].trans_sub_type_cd = cs20549_discount_adj_cd
      SET transaliasfindrequest->objarray[1].trans_reason_cd = cs18937_disc_adj_cd
      SET objtransalias->ein_type = ein_trans_alias_elements
     ENDIF
     IF (size(transaliasfindrequest->objarray,5) > 0)
      EXECUTE pft_trans_alias_find  WITH replace("REPLY",transaliasfindreply), replace("OBJREPLY",
       objtransalias), replace("REQUEST",transaliasfindrequest)
      IF (transaliasid > 0.0)
       IF ((((transaliasfindreply->status_data.status != "S")) OR (size(objtransalias->objarray,5)=0
       )) )
        CALL logmessage("applyChargeLevelAdjustment","Did not find the transaction alias",log_debug)
        RETURN(false)
       ENDIF
       SET transtypecd = objtransalias->objarray[1].trans_type_cd
       SET transsubtypecd = objtransalias->objarray[1].trans_sub_type_cd
       SET transreasoncd = objtransalias->objarray[1].trans_reason_cd
       SET adjamount = (round(abs((pitemextendedprice+ totaladjustments)),2) * evaluate(objtransalias
        ->objarray[1].dr_cr_flag,1,1,2,- (1),
        0))
      ELSE
       IF (size(objtransalias->objarray,5) > 0)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = value(size(objtransalias->objarray,5)))
         PLAN (d
          WHERE (objtransalias->objarray[d.seq].dr_cr_flag=2))
         DETAIL
          transaliasid = objtransalias->objarray[d.seq].trans_alias_id, transtypecd = objtransalias->
          objarray[d.seq].trans_type_cd, transsubtypecd = objtransalias->objarray[d.seq].
          trans_sub_type_cd,
          transreasoncd = objtransalias->objarray[d.seq].trans_reason_cd
         WITH nocounter
        ;end select
       ENDIF
       SET adjamount = (round((pitemextendedprice+ totaladjustments),2) * - (1.0))
      ENDIF
     ENDIF
     IF (curqual < 1)
      CALL logmessage("applyChargeLevelAdjustment",
       "Error finding primary charge group / health plan relationship",log_debug)
     ENDIF
     SET chargeremamountwithadjust = (pitemextendedprice+ totaladjustments)
     IF ( NOT (isequal(chargeremamountwithadjust,0.0))
      AND  NOT (chargeremamountwithadjust < 0.009))
      SET stat = alterlist(applydiscadjreq->objarray,1)
      SET applydiscadjreq->objarray[1].activity_id = pchargeactivityid
      SET applydiscadjreq->objarray[1].trans_type_cd = transtypecd
      SET applydiscadjreq->objarray[1].trans_sub_type_cd = transsubtypecd
      SET applydiscadjreq->objarray[1].trans_reason_cd = transreasoncd
      SET applydiscadjreq->objarray[1].trans_alias_id = transaliasid
      SET applydiscadjreq->objarray[1].amount = adjamount
      SET applydiscadjreq->objarray[1].bo_hp_reltn_id = pprimarybohpreltnid
      SET applydiscadjreq->objarray[1].chrg_writeoff_ind = 1
     ENDIF
     IF (size(applydiscadjreq->objarray,5) > 0)
      EXECUTE pft_apply_doll_adj_for_charge  WITH replace("REQUEST",applydiscadjreq), replace("REPLY",
       applydiscadjrep)
      IF ((applydiscadjrep->status_data.status != "S"))
       CALL logmessage("applyChargeLevelAdjustment",
        "Failed to apply write-off adjustment for charge.",log_debug)
       RETURN(false)
      ENDIF
     ENDIF
    ENDIF
    CALL logmessage("applyChargeLevelAdjustment","Exiting...",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(reversechargeleveladjustment,char(128))=char(128))
  SUBROUTINE (reversechargeleveladjustment(pchargeitemid=f8) =i2)
    CALL logmessage("reverseChargeLevelAdjustment","Entering",log_debug)
    DECLARE activitycnt = i4 WITH protect, noconstant(0)
    RECORD revtransrequest(
      1 inproc_batch_trans_id = f8
      1 batch_type_flag = i2
      1 script_name = vc
      1 suppress_transfer_reversal = i2
      1 objarray[*]
        2 activity_id = f8
        2 amount = f8
        2 payment_location_id = f8
        2 interchange_trans_ident = vc
        2 cc_trans_org_id = f8
        2 external_ident = vc
    ) WITH protect
    RECORD revtransreply(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SELECT INTO "nl:"
     FROM pft_charge pc,
      pft_trans_reltn ptr,
      batch_trans_file btf
     PLAN (pc
      WHERE pc.charge_item_id=pchargeitemid
       AND pc.active_ind=true)
      JOIN (ptr
      WHERE ptr.parent_entity_id=pc.pft_charge_id
       AND ptr.parent_entity_name="PFTCHARGE"
       AND ptr.active_ind=true
       AND ptr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND  NOT ( EXISTS (
      (SELECT
       1
       FROM trans_trans_reltn ttr
       WHERE ttr.parent_activity_id=ptr.activity_id
        AND ttr.trans_reltn_reason_cd=cs25753_reversal_cd
        AND ttr.active_ind=true
        AND ttr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND ttr.end_effective_dt_tm > cnvtdatetime(sysdate)))))
      JOIN (btf
      WHERE btf.batch_trans_file_id=ptr.batch_trans_file_id
       AND btf.chrg_writeoff_ind=1
       AND btf.active_ind=true)
     ORDER BY ptr.activity_id
     DETAIL
      activitycnt += 1, stat = alterlist(revtransrequest->objarray,activitycnt), revtransrequest->
      objarray[activitycnt].activity_id = ptr.activity_id
     WITH nocounter
    ;end select
    IF (size(revtransrequest->objarray,5) > 0)
     EXECUTE pft_reverse_transaction  WITH replace("REQUEST",revtransrequest), replace("REPLY",
      revtransreply)
     IF ((revtransreply->status_data.status != "S"))
      CALL logmessage("reverseChargeLevelAdjustment",
       "Failed to reverse discount adjustment for charge.",log_debug)
      RETURN(false)
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(evaluatechargediagnosismapping,char(128))=char(128))
  SUBROUTINE (evaluatechargediagnosismapping(pchargeid=f8,pchargeitemid=f8) =i4)
    DECLARE dprimarydiagnosistypecd = f8 WITH protect, noconstant(0.0)
    DECLARE dsecondarydiagnosistypecd = f8 WITH protect, noconstant(0.0)
    DECLARE inomencnt = i4 WITH protect, noconstant(0)
    DECLARE ichargecnt = i4 WITH protect, noconstant(0)
    SET stat = initrec(chargepbmrequest)
    SET stat = initrec(chargepbmreply)
    IF ( NOT (geticdpreference(0)))
     CALL logmessage("evaluateChargeDiagnosisMapping","getIcdPreference did not return success",
      log_error)
     RETURN(map_error)
    ENDIF
    FOR (dminfoidx = 1 TO dminforeply->dm_info_qual)
      IF ((dminforeply->dm_info[dminfoidx].info_name="ICD PRINCIPAL DIAGNOSIS TYPE"))
       SET dprimarydiagnosistypecd = dminforeply->dm_info[dminfoidx].info_long_id
      ELSEIF ((dminforeply->dm_info[dminfoidx].info_name="SECONDARY ICD PRINCIPAL DIAGNOSIS TYPE"))
       SET dsecondarydiagnosistypecd = dminforeply->dm_info[dminfoidx].info_long_id
      ENDIF
    ENDFOR
    IF (((dprimarydiagnosistypecd=0.0) OR (((dsecondarydiagnosistypecd=0.0) OR (
    dprimarydiagnosistypecd=dsecondarydiagnosistypecd)) )) )
     RETURN(no_map)
    ENDIF
    SET stat = alterlist(chargepbmrequest->objarray,1)
    SET chargepbmrequest->objarray[1].pftchargeid = pchargeid
    SET chargepbmrequest->categorykey = "CHRGPOST"
    SET chargepbmrequest->eventkey = "CHRG_DXMAP"
    EXECUTE pft_eval_pbm_rules  WITH replace("REQUEST",chargepbmrequest), replace("REPLY",
     chargepbmreply)
    IF (validate(debug))
     CALL echorecord(chargepbmreply)
    ENDIF
    IF ((chargepbmreply->status_data.status="F"))
     CALL logmessage("evaluateChargeDiagnosisMapping","PFT_EVAL_PBM_RULES failed",log_error)
     RETURN(map_error)
    ELSEIF ((chargepbmreply->status_data.status="Z"))
     CALL logmessage("evaluateChargeDiagnosisMapping","No Charge Rules to Evaluate",log_debug)
     RETURN(no_map)
    ENDIF
    IF (size(chargepbmreply->rulesets[1].objarray[1].actions,5) > 0)
     SET stat = initrec(nomenlist)
     SET stat = initrec(diagnosismap)
     SELECT INTO "nl:"
      FROM charge c,
       charge_event_mod cem,
       nomenclature n,
       charge_mod cm
      PLAN (c
       WHERE c.charge_item_id=pchargeitemid
        AND c.active_ind=true)
       JOIN (cem
       WHERE cem.charge_event_id=c.charge_event_id
        AND cem.charge_event_mod_type_cd=cs13019_mod_type_cd
        AND cem.active_ind=true
        AND cem.field1_id=cs14002_icd_cd
        AND cem.field5_id=0.0)
       JOIN (n
       WHERE n.nomenclature_id=cem.nomen_id
        AND n.source_vocabulary_cd=dprimarydiagnosistypecd
        AND n.active_ind=true)
       JOIN (cm
       WHERE cm.charge_item_id=c.charge_item_id
        AND cm.nomen_id=n.nomenclature_id
        AND cm.active_ind=true
        AND cm.field6=cem.field6
        AND cm.field2_id=cem.field2_id
        AND cm.field5_id=0.0)
      ORDER BY cem.field2_id, cm.charge_mod_id, cem.charge_event_mod_id
      HEAD REPORT
       ichargecnt += 1, stat = alterlist(nomenlist->objarray,ichargecnt), nomenlist->objarray[
       ichargecnt].encntrid = c.encntr_id,
       nomenlist->objarray[ichargecnt].chargeitemid = c.charge_item_id
      HEAD cm.charge_mod_id
       inomencnt += 1, stat = alterlist(nomenlist->objarray[ichargecnt].nomenlist,inomencnt),
       nomenlist->objarray[ichargecnt].nomenlist[inomencnt].nomenclatureid = n.nomenclature_id,
       nomenlist->objarray[ichargecnt].nomenlist[inomencnt].chargeeventmodid = cem
       .charge_event_mod_id, nomenlist->objarray[ichargecnt].nomenlist[inomencnt].chargemodid = cm
       .charge_mod_id
      WITH nocounter
     ;end select
     IF (inomencnt=0)
      RETURN(no_map)
     ENDIF
     SET nomenlist->targetdiagnosistype = dsecondarydiagnosistypecd
     IF (validate(debug))
      CALL echorecord(nomenlist)
     ENDIF
     IF ( NOT (getdiagnosismap(nomenlist,diagnosismap)))
      RETURN(map_error)
     ENDIF
     IF (validate(debug))
      CALL echorecord(diagnosismap)
     ENDIF
     IF ( NOT (addchargemoddx(0)))
      RETURN(map_error)
     ENDIF
     RETURN(new_map)
    ENDIF
    RETURN(no_map)
  END ;Subroutine
 ENDIF
 IF (validate(evaluateencounterdiagnosismapping,char(128))=char(128))
  SUBROUTINE (evaluateencounterdiagnosismapping(ppftencntrid=f8) =i4)
    DECLARE dprimarydiagnosistypecd = f8 WITH protect, noconstant(0.0)
    DECLARE dsecondarydiagnosistypecd = f8 WITH protect, noconstant(0.0)
    DECLARE inomencnt = i4 WITH protect, noconstant(0)
    DECLARE ichargecnt = i4 WITH protect, noconstant(0)
    SET stat = initrec(chargepbmrequest)
    SET stat = initrec(chargepbmreply)
    SELECT INTO "nl:"
     FROM pft_charge pc
     WHERE pc.pft_encntr_id=ppftencntrid
     DETAIL
      stat = alterlist(chargepbmrequest->objarray,1), chargepbmrequest->objarray[1].pftchargeid = pc
      .pft_charge_id, chargepbmrequest->categorykey = "CHRGPOST",
      chargepbmrequest->eventkey = "CHRG_DXMAP"
     WITH nocounter, maxrec = 1
    ;end select
    IF ((chargepbmrequest->objarray[1].pftchargeid > 0.0))
     EXECUTE pft_eval_pbm_rules  WITH replace("REQUEST",chargepbmrequest), replace("REPLY",
      chargepbmreply)
     IF (validate(debug))
      CALL echorecord(chargepbmreply)
     ENDIF
     IF ((chargepbmreply->status_data.status="F"))
      CALL logmessage("evaluateChargeDiagnosisMapping","PFT_EVAL_PBM_RULES failed",log_error)
      RETURN(map_error)
     ELSEIF ((chargepbmreply->status_data.status="Z"))
      CALL logmessage("evaluateChargeDiagnosisMapping","No Charge Rules to Evaluate",log_debug)
      RETURN(no_map)
     ENDIF
     IF (size(chargepbmreply->rulesets[1].objarray[1].actions,5) > 0)
      IF ( NOT (geticdpreference(0)))
       CALL logmessage("evaluateChargeDiagnosisMapping","getIcdPreference did not return success",
        log_error)
       RETURN(map_error)
      ENDIF
      FOR (dminfoidx = 1 TO dminforeply->dm_info_qual)
        IF ((dminforeply->dm_info[dminfoidx].info_name="ICD PRINCIPAL DIAGNOSIS TYPE"))
         SET dprimarydiagnosistypecd = dminforeply->dm_info[dminfoidx].info_long_id
        ELSEIF ((dminforeply->dm_info[dminfoidx].info_name="SECONDARY ICD PRINCIPAL DIAGNOSIS TYPE"))
         SET dsecondarydiagnosistypecd = dminforeply->dm_info[dminfoidx].info_long_id
        ENDIF
      ENDFOR
      IF (((dprimarydiagnosistypecd=0.0) OR (((dsecondarydiagnosistypecd=0.0) OR (
      dprimarydiagnosistypecd=dsecondarydiagnosistypecd)) )) )
       RETURN(no_map)
      ENDIF
      SET stat = initrec(nomenlist)
      SET stat = initrec(diagnosismap)
      SELECT INTO "nl:"
       FROM pft_charge pc,
        charge c,
        charge_event_mod cem,
        nomenclature n,
        charge_mod cm,
        pft_charge_bo_reltn pcbr,
        benefit_order bo,
        bt_condition btc
       PLAN (pc
        WHERE pc.pft_encntr_id=ppftencntrid
         AND pc.active_ind=true)
        JOIN (c
        WHERE c.charge_item_id=pc.charge_item_id
         AND c.active_ind=true
         AND c.charge_type_cd=cs13028_debit_cd
         AND c.offset_charge_item_id=0.0
         AND c.active_ind=true)
        JOIN (cem
        WHERE cem.charge_event_id=c.charge_event_id
         AND cem.charge_event_mod_type_cd=cs13019_mod_type_cd
         AND cem.active_ind=true
         AND cem.field1_id=cs14002_icd_cd
         AND cem.field5_id=0.0)
        JOIN (n
        WHERE n.nomenclature_id=cem.nomen_id
         AND n.source_vocabulary_cd=dprimarydiagnosistypecd
         AND n.active_ind=true)
        JOIN (cm
        WHERE cm.charge_item_id=c.charge_item_id
         AND cm.nomen_id=n.nomenclature_id
         AND cm.active_ind=true
         AND cm.field6=cem.field6
         AND cm.field5_id=0.0)
        JOIN (pcbr
        WHERE pcbr.pft_charge_id=pc.pft_charge_id
         AND pcbr.active_ind=true)
        JOIN (bo
        WHERE bo.benefit_order_id=pcbr.benefit_order_id
         AND bo.bo_status_cd != cs24451_invalid_cd
         AND bo.active_ind=true)
        JOIN (btc
        WHERE btc.bt_condition_id=bo.bt_condition_id
         AND btc.bill_type_cd=cs21749_hcfa_1500_cd)
       ORDER BY c.charge_item_id, cm.nomen_id
       HEAD c.charge_item_id
        ichargecnt += 1, stat = alterlist(nomenlist->objarray,ichargecnt), nomenlist->objarray[
        ichargecnt].encntrid = c.encntr_id,
        nomenlist->objarray[ichargecnt].chargeitemid = c.charge_item_id
       HEAD cm.nomen_id
        inomencnt += 1, stat = alterlist(nomenlist->objarray[ichargecnt].nomenlist,inomencnt),
        nomenlist->objarray[ichargecnt].nomenlist[inomencnt].nomenclatureid = n.nomenclature_id,
        nomenlist->objarray[ichargecnt].nomenlist[inomencnt].chargeeventmodid = cem
        .charge_event_mod_id, nomenlist->objarray[ichargecnt].nomenlist[inomencnt].chargemodid = cm
        .charge_mod_id
       WITH nocounter
      ;end select
      IF (inomencnt=0)
       RETURN(no_map)
      ENDIF
      SET nomenlist->targetdiagnosistype = dsecondarydiagnosistypecd
      IF (validate(debug))
       CALL echorecord(nomenlist)
      ENDIF
      IF ( NOT (getdiagnosismap(nomenlist,diagnosismap)))
       RETURN(map_error)
      ENDIF
      IF (validate(debug))
       CALL echorecord(diagnosismap)
      ENDIF
      IF ( NOT (addchargemoddx(0)))
       RETURN(map_error)
      ENDIF
      RETURN(new_map)
     ENDIF
    ENDIF
    RETURN(no_map)
  END ;Subroutine
 ENDIF
 IF (validate(addchargemod,char(128))=char(128))
  DECLARE addchargemoddx(null) = i2
  SUBROUTINE addchargemoddx(null)
    RECORD addchargemods(
      1 charge_mod_qual = i2
      1 charge_mod[*]
        2 action_type = c3
        2 charge_mod_id = f8
        2 charge_item_id = f8
        2 charge_mod_type_cd = f8
        2 charge_event_mod_id = f8
        2 field1 = vc
        2 field2 = vc
        2 field3 = vc
        2 field4 = vc
        2 field5 = vc
        2 field6 = vc
        2 field7 = vc
        2 field8 = vc
        2 field9 = vc
        2 field10 = vc
        2 field1_id = f8
        2 field2_id = f8
        2 field3_id = f8
        2 field4_id = f8
        2 field5_id = f8
        2 nomen_id = f8
        2 activity_dt_tm = dq8
        2 active_ind_ind = i2
        2 active_ind = i2
        2 active_status_cd = f8
        2 active_status_dt_tm = f8
        2 active_status_prsnl_id = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 nomen_entity_reltn_id = f8
        2 cm1_nbr = f8
    ) WITH protect
    RECORD uptchargemods(
      1 objarray[*]
        2 action_type = c3
        2 charge_item_id = f8
        2 charge_event_id = f8
        2 charge_mod_id = f8
        2 charge_mod_type_cd = f8
        2 charge_event_mod_type_cd = f8
        2 charge_event_mod_id = f8
        2 field2_id = f8
        2 field5_id = f8
        2 updt_cnt = i4
        2 active_ind = i2
        2 field1 = vc
        2 field2 = vc
        2 field3 = vc
        2 field4 = vc
        2 field5 = vc
        2 field6 = vc
        2 field7 = vc
        2 field8 = vc
        2 field9 = vc
        2 field10 = vc
        2 active_status_cd = f8
        2 active_status_dt_tm = dq8
        2 active_status_prsnl_id = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 code1_cd = f8
        2 nomen_id = f8
        2 field1_id = f8
        2 field3_id = f8
        2 field4_id = f8
        2 cm1_nbr = f8
        2 activity_dt_tm = dq8
    ) WITH protect
    RECORD dauptchargemodrep(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD addchargemodreply(
      1 charge_mod_qual = i2
      1 charge_mod[*]
        2 charge_mod_id = f8
        2 charge_item_id = f8
        2 charge_mod_type_cd = f8
        2 field1_id = f8
        2 field2_id = f8
        2 field3_id = f8
        2 field6 = vc
        2 field7 = vc
        2 nomen_id = f8
        2 action_type = c3
        2 nomen_entity_reltn_id = f8
        2 cm1_nbr = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    RECORD temper(
      1 objarray[*]
        2 field6 = vc
    ) WITH protect
    DECLARE ichargeidx = i4 WITH protect, noconstant(0)
    DECLARE iaddidx = i4 WITH protect, noconstant(0)
    DECLARE iudtdxidx = i4 WITH protect, noconstant(0)
    DECLARE isynonymidx = i4 WITH protect, noconstant(0)
    DECLARE imodcnt = i4 WITH protect, noconstant(0)
    DECLARE icurridx = i4 WITH protect, noconstant(0)
    DECLARE icntidx = i4 WITH protect, noconstant(0)
    DECLARE idupidx = i4 WITH protect, noconstant(0)
    DECLARE ipriority = i4 WITH protect, noconstant(0)
    FOR (ichargeidx = 1 TO size(diagnosismap->objarray,5))
      SET ipriority = 0
      SET stat = initrec(temper)
      SELECT INTO "nl:"
       FROM charge c,
        charge_event_mod cem,
        nomenclature n,
        charge_mod cm
       PLAN (c
        WHERE (c.charge_item_id=diagnosismap->objarray[ichargeidx].chargeitemid)
         AND c.active_ind=true)
        JOIN (cem
        WHERE cem.charge_event_id=c.charge_event_id
         AND cem.active_ind=true
         AND cem.field1_id=cs14002_icd_cd
         AND cem.charge_event_mod_type_cd=cs13019_mod_type_cd)
        JOIN (n
        WHERE n.nomenclature_id=cem.nomen_id
         AND n.active_ind=true)
        JOIN (cm
        WHERE (cm.charge_item_id=diagnosismap->objarray[ichargeidx].chargeitemid)
         AND cm.active_ind=true
         AND cm.charge_mod_type_cd=cs13019_mod_type_cd
         AND cm.nomen_id=cem.nomen_id
         AND cm.field6=cem.field6
         AND cm.field1_id=cs14002_icd_cd
         AND cm.field2_id=cem.field2_id)
       ORDER BY cem.field2_id, cm.charge_mod_id, cem.charge_event_mod_id
       HEAD cm.charge_mod_id
        ipriority += 1, iudtdxidx += 1, stat = alterlist(uptchargemods->objarray,iudtdxidx),
        iaddidx = locateval(icntidx,1,size(diagnosismap->objarray[ichargeidx].diagnosis,5),cem
         .charge_event_mod_id,diagnosismap->objarray[ichargeidx].diagnosis[icntidx].chargeeventmodid)
        IF (iaddidx > 0)
         stat = alterlist(temper->objarray,ipriority), temper->objarray[ipriority].field6 = trim(cem
          .field6), uptchargemods->objarray[iudtdxidx].charge_mod_id = diagnosismap->objarray[
         ichargeidx].diagnosis[iaddidx].chargemodid,
         uptchargemods->objarray[iudtdxidx].charge_event_mod_id = diagnosismap->objarray[ichargeidx].
         diagnosis[iaddidx].chargeeventmodid, uptchargemods->objarray[iudtdxidx].field2_id =
         ipriority, uptchargemods->objarray[iudtdxidx].field5_id = diagnosismap->objarray[ichargeidx]
         .diagnosis[iaddidx].maptypeflg,
         uptchargemods->objarray[iudtdxidx].updt_cnt = upt_force, uptchargemods->objarray[iudtdxidx].
         active_ind = true, uptchargemods->objarray[iudtdxidx].action_type = "UPT",
         uptchargemods->objarray[iudtdxidx].charge_item_id = cm.charge_item_id, uptchargemods->
         objarray[iudtdxidx].charge_event_id = c.charge_event_id, uptchargemods->objarray[iudtdxidx].
         field1_id = cm.field1_id,
         uptchargemods->objarray[iudtdxidx].charge_mod_type_cd = cs13019_mod_type_cd, uptchargemods->
         objarray[iudtdxidx].charge_event_mod_type_cd = cs13019_mod_type_cd, uptchargemods->objarray[
         iudtdxidx].field1 = cm.field1,
         uptchargemods->objarray[iudtdxidx].field2 = cm.field2, uptchargemods->objarray[iudtdxidx].
         field3 = cm.field3, uptchargemods->objarray[iudtdxidx].field4 = cm.field4,
         uptchargemods->objarray[iudtdxidx].field5 = cm.field5, uptchargemods->objarray[iudtdxidx].
         field6 = cm.field6, uptchargemods->objarray[iudtdxidx].field7 = cm.field7,
         uptchargemods->objarray[iudtdxidx].field8 = cm.field8, uptchargemods->objarray[iudtdxidx].
         field9 = cm.field9, uptchargemods->objarray[iudtdxidx].field10 = cm.field10,
         uptchargemods->objarray[iudtdxidx].active_status_cd = cm.active_status_cd, uptchargemods->
         objarray[iudtdxidx].field3_id = cm.field3_id, uptchargemods->objarray[iudtdxidx].field4_id
          = cm.field4_id,
         uptchargemods->objarray[iudtdxidx].code1_cd = cm.code1_cd, uptchargemods->objarray[iudtdxidx
         ].nomen_id = cm.nomen_id, uptchargemods->objarray[iudtdxidx].cm1_nbr = cm.cm1_nbr,
         imodcnt += size(diagnosismap->objarray[ichargeidx].diagnosis[iaddidx].synonyms,5), stat =
         alterlist(addchargemods->charge_mod,imodcnt)
         FOR (isynonymidx = 1 TO size(diagnosismap->objarray[ichargeidx].diagnosis[iaddidx].synonyms,
          5))
           IF (locateval(idupidx,1,size(temper->objarray,5),diagnosismap->objarray[ichargeidx].
            diagnosis[iaddidx].synonyms[isynonymidx].sourceident,temper->objarray[idupidx].field6)=0)
            ipriority += 1, icurridx += 1, stat = alterlist(temper->objarray,ipriority),
            temper->objarray[ipriority].field6 = substring(1,200,trim(diagnosismap->objarray[
              ichargeidx].diagnosis[iaddidx].synonyms[isynonymidx].sourceident)), addchargemods->
            charge_mod[icurridx].action_type = "ADD", addchargemods->charge_mod[icurridx].
            charge_item_id = diagnosismap->objarray[ichargeidx].chargeitemid,
            addchargemods->charge_mod[icurridx].charge_mod_type_cd = cs13019_mod_type_cd,
            addchargemods->charge_mod[icurridx].field6 = substring(1,200,trim(diagnosismap->objarray[
              ichargeidx].diagnosis[iaddidx].synonyms[isynonymidx].sourceident)), addchargemods->
            charge_mod[icurridx].field7 = substring(1,200,trim(diagnosismap->objarray[ichargeidx].
              diagnosis[iaddidx].synonyms[isynonymidx].description)),
            addchargemods->charge_mod[icurridx].field1_id = cs14002_icd_cd, addchargemods->
            charge_mod[icurridx].field2_id = ipriority, addchargemods->charge_mod[icurridx].field5_id
             = diagnosismap->objarray[ichargeidx].diagnosis[iaddidx].sourcenomenid,
            addchargemods->charge_mod[icurridx].nomen_id = diagnosismap->objarray[ichargeidx].
            diagnosis[iaddidx].synonyms[isynonymidx].nomenid
           ENDIF
         ENDFOR
        ELSE
         IF (((locateval(idupidx,1,size(temper->objarray,5),trim(cem.field6),temper->objarray[idupidx
          ].field6)=0) OR (n.source_vocabulary_cd=dprimarydiagnosistypecd)) )
          stat = alterlist(temper->objarray,ipriority), temper->objarray[ipriority].field6 = trim(cem
           .field6), uptchargemods->objarray[iudtdxidx].charge_mod_id = cm.charge_mod_id,
          uptchargemods->objarray[iudtdxidx].charge_event_mod_id = cem.charge_event_mod_id,
          uptchargemods->objarray[iudtdxidx].field2_id = ipriority, uptchargemods->objarray[iudtdxidx
          ].field5_id = cem.field5_id,
          uptchargemods->objarray[iudtdxidx].updt_cnt = upt_force, uptchargemods->objarray[iudtdxidx]
          .active_ind = true, uptchargemods->objarray[iudtdxidx].action_type = "UPT",
          uptchargemods->objarray[iudtdxidx].charge_item_id = cm.charge_item_id, uptchargemods->
          objarray[iudtdxidx].charge_event_id = c.charge_event_id, uptchargemods->objarray[iudtdxidx]
          .field1_id = cm.field1_id,
          uptchargemods->objarray[iudtdxidx].charge_mod_type_cd = cs13019_mod_type_cd, uptchargemods
          ->objarray[iudtdxidx].charge_event_mod_type_cd = cs13019_mod_type_cd, uptchargemods->
          objarray[iudtdxidx].field1 = cm.field1,
          uptchargemods->objarray[iudtdxidx].field2 = cm.field2, uptchargemods->objarray[iudtdxidx].
          field3 = cm.field3, uptchargemods->objarray[iudtdxidx].field4 = cm.field4,
          uptchargemods->objarray[iudtdxidx].field5 = cm.field5, uptchargemods->objarray[iudtdxidx].
          field6 = cm.field6, uptchargemods->objarray[iudtdxidx].field7 = cm.field7,
          uptchargemods->objarray[iudtdxidx].field8 = cm.field8, uptchargemods->objarray[iudtdxidx].
          field9 = cm.field9, uptchargemods->objarray[iudtdxidx].field10 = cm.field10,
          uptchargemods->objarray[iudtdxidx].active_status_cd = cm.active_status_cd, uptchargemods->
          objarray[iudtdxidx].field3_id = cm.field3_id, uptchargemods->objarray[iudtdxidx].field4_id
           = cm.field4_id,
          uptchargemods->objarray[iudtdxidx].code1_cd = cm.code1_cd, uptchargemods->objarray[
          iudtdxidx].nomen_id = cm.nomen_id, uptchargemods->objarray[iudtdxidx].cm1_nbr = cm.cm1_nbr
         ELSE
          ipriority -= 1, uptchargemods->objarray[iudtdxidx].charge_mod_id = cm.charge_mod_id,
          uptchargemods->objarray[iudtdxidx].charge_event_mod_id = cem.charge_event_mod_id,
          uptchargemods->objarray[iudtdxidx].active_ind = false, uptchargemods->objarray[iudtdxidx].
          updt_cnt = upt_force, uptchargemods->objarray[iudtdxidx].field2_id = cem.field2_id,
          uptchargemods->objarray[iudtdxidx].field5_id = cem.field5_id, uptchargemods->objarray[
          iudtdxidx].action_type = "DEL", uptchargemods->objarray[iudtdxidx].charge_item_id = cm
          .charge_item_id,
          uptchargemods->objarray[iudtdxidx].charge_event_id = c.charge_event_id, uptchargemods->
          objarray[iudtdxidx].field1_id = cm.field1_id, uptchargemods->objarray[iudtdxidx].
          charge_mod_type_cd = cs13019_mod_type_cd,
          uptchargemods->objarray[iudtdxidx].charge_event_mod_type_cd = cs13019_mod_type_cd,
          uptchargemods->objarray[iudtdxidx].field1 = cm.field1, uptchargemods->objarray[iudtdxidx].
          field2 = cm.field2,
          uptchargemods->objarray[iudtdxidx].field3 = cm.field3, uptchargemods->objarray[iudtdxidx].
          field4 = cm.field4, uptchargemods->objarray[iudtdxidx].field5 = cm.field5,
          uptchargemods->objarray[iudtdxidx].field6 = cm.field6, uptchargemods->objarray[iudtdxidx].
          field7 = cm.field7, uptchargemods->objarray[iudtdxidx].field8 = cm.field8,
          uptchargemods->objarray[iudtdxidx].field9 = cm.field9, uptchargemods->objarray[iudtdxidx].
          field10 = cm.field10, uptchargemods->objarray[iudtdxidx].active_status_cd = cm
          .active_status_cd,
          uptchargemods->objarray[iudtdxidx].field3_id = cm.field3_id, uptchargemods->objarray[
          iudtdxidx].field4_id = cm.field4_id, uptchargemods->objarray[iudtdxidx].code1_cd = cm
          .code1_cd,
          uptchargemods->objarray[iudtdxidx].nomen_id = cm.nomen_id, uptchargemods->objarray[
          iudtdxidx].cm1_nbr = cm.cm1_nbr
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      SET addchargemods->charge_mod_qual = imodcnt
    ENDFOR
    IF (iudtdxidx=0)
     RETURN(true)
    ENDIF
    DECLARE action_begin = i4 WITH protect, noconstant(1)
    DECLARE action_end = i4 WITH protect, noconstant(size(addchargemods->charge_mod,5))
    EXECUTE afc_add_charge_mod  WITH replace("REQUEST",addchargemods), replace("REPLY",
     addchargemodreply)
    IF (validate(debug))
     CALL echorecord(addchargemods)
     CALL echorecord(addchargemodreply)
     CALL echorecord(uptchargemods)
    ENDIF
    IF ((addchargemodreply->status_data.status != "S"))
     CALL logmessage("addChargeMod","afc_add_charge_mod did not return success",log_error)
     RETURN(false)
    ENDIF
    IF (size(uptchargemods->objarray,5) <= 0)
     CALL echo("No charge_mods to add")
    ELSE
     EXECUTE afc_val_charge_mod  WITH replace("REQUEST",uptchargemods), replace("REPLY",
      dauptchargemodrep)
     IF ((dauptchargemodrep->status_data.status != "S"))
      CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(uptchargemods)
       CALL echorecord(dauptchargemodrep)
      ENDIF
      RETURN(false)
     ENDIF
    ENDIF
    SET stat = initrec(dauptchargemodrep)
    IF (size(uptchargemods->objarray,5) <= 0)
     CALL echo("No charge_event_mods to add")
    ELSE
     EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",uptchargemods), replace("REPLY",
      dauptchargemodrep)
     IF ((dauptchargemodrep->status_data.status != "S"))
      CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(uptchargemods)
       CALL echorecord(dauptchargemodrep)
      ENDIF
      RETURN(false)
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(logcapabilityinfo,char(128))=char(128))
  SUBROUTINE (logcapabilityinfo(pteamname=vc,pcapabilityident=vc,pentityid=f8,pentityname=vc) =null)
    RECORD capabilitylogrequest(
      1 teamname = vc
      1 capability_ident = vc
      1 entities[*]
        2 entity_id = f8
        2 entity_name = vc
    ) WITH protect
    RECORD capabilitylogreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET capabilitylogrequest->teamname = pteamname
    SET capabilitylogrequest->capability_ident = pcapabilityident
    SET stat = alterlist(capabilitylogrequest->entities,1)
    SET capabilitylogrequest->entities[1].entity_id = pentityid
    SET capabilitylogrequest->entities[1].entity_name = pentityname
    EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilitylogrequest), replace(
     "REPLY",capabilitylogreply)
    IF ((capabilitylogreply->status_data.status != "S"))
     CALL logmessage(curprog,"logCapabilityInfo: pft_log_solution_capability failed.",log_error)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(writechargewoevaluationtowtp,char(128))=char(128))
  SUBROUTINE (writechargewoevaluationtowtp(pentityid=f8,pentitytype=vc,pjsonpftchrgstoevalwofor=vc(
    value,""),pskipwtqcheck=i2(value,false)) =i2)
    DECLARE cs24450_evalwriteoff_cd = f8 WITH protect, constant(getcodevalue(24450,"EVALWRITEOFF",0))
    DECLARE cs4002853_queued = f8 WITH protect, constant(getcodevalue(4002853,"QUEUED",0))
    IF (validate(debug,0)=1)
     CALL echo(build("pEntityId is: ",pentityid))
     CALL echo(build("pEntityType is: ",pentitytype))
     CALL echo(build("pJsonPftChrgsToEvalWoFor is: ",pjsonpftchrgstoevalwofor))
     CALL echo(build("pSkipWTQCheck is: ",pskipwtqcheck))
    ENDIF
    RECORD wtptaskrequest(
      1 encounterid = f8
      1 pft_charges[*]
        2 pft_charge_id = f8
    ) WITH protect
    RECORD applyholdrequest(
      1 objarray[*]
        2 pft_encntr_id = f8
        2 pe_status_reason_cd = f8
        2 reason_comment = vc
        2 reapply_ind = i4
        2 pft_balance_id = f8
        2 pft_hold_id = f8
        2 pe_sub_status_reason_cd = f8
        2 guar_acct_id = f8
    ) WITH protect
    DECLARE wtqrowexists = i2 WITH protect, noconstant(false)
    DECLARE encounterid = f8 WITH protect, noconstant(pentityid)
    DECLARE returnval = i2 WITH protect, noconstant(true)
    DECLARE pftencntrcnt = i4 WITH protect, noconstant(0)
    IF (pentitytype="PFTENCNTR")
     SELECT INTO "nl:"
      FROM pft_encntr pe
      PLAN (pe
       WHERE pe.pft_encntr_id=pentityid)
      DETAIL
       stat = alterlist(applyholdrequest->objarray,1), applyholdrequest->objarray[1].pft_encntr_id =
       pe.pft_encntr_id, applyholdrequest->objarray[1].pe_status_reason_cd = cs24450_evalwriteoff_cd,
       applyholdrequest->objarray[1].reapply_ind = true, encounterid = pe.encntr_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM encounter e,
       pft_encntr pe
      PLAN (e
       WHERE e.encntr_id=pentityid
        AND e.active_ind=true)
       JOIN (pe
       WHERE pe.encntr_id=e.encntr_id
        AND pe.active_ind=true
        AND pe.pft_encntr_status_cd != cs24269_history_cd)
      ORDER BY pe.pft_encntr_id
      HEAD pe.pft_encntr_id
       pftencntrcnt += 1, stat = alterlist(applyholdrequest->objarray,pftencntrcnt), applyholdrequest
       ->objarray[pftencntrcnt].pft_encntr_id = pe.pft_encntr_id,
       applyholdrequest->objarray[pftencntrcnt].pe_status_reason_cd = cs24450_evalwriteoff_cd,
       applyholdrequest->objarray[pftencntrcnt].reapply_ind = true
      WITH nocounter
     ;end select
    ENDIF
    IF ( NOT (pskipwtqcheck))
     SELECT INTO "nl:"
      FROM workflow_task_queue wtq
      PLAN (wtq
       WHERE wtq.entity_id=encounterid
        AND wtq.entity_name="ENCOUNTER"
        AND wtq.task_ident="PFT_EVALUATE_CHARGE_WRITE_OFF"
        AND wtq.queue_status_cd=cs4002853_queued
        AND wtq.process_dt_tm <= cnvtlookahead("1,D",cnvtdatetime(sysdate)))
      HEAD REPORT
       wtqrowexists = true
      WITH nocounter, orahintcbo("index(XIE2WORKFLOW_TASK_QUEUE)")
     ;end select
    ENDIF
    IF ( NOT (wtqrowexists)
     AND encounterid > 0.0)
     SET wtptaskrequest->encounterid = encounterid
     IF (size(trim(pjsonpftchrgstoevalwofor)) != 0)
      SET stat = cnvtjsontorec(pjsonpftchrgstoevalwofor)
      IF (validate(debug,0)=1)
       CALL echorecord(pftchargestoevalwriteofffor)
      ENDIF
      SET stat = moverec(pftchargestoevalwriteofffor->pft_charges,wtptaskrequest->pft_charges)
     ENDIF
     SET returnval = writerowtowtp(cnvtrectojson(wtptaskrequest),"PFT_EVALUATE_CHARGE_WRITE_OFF",
      encounterid,"ENCOUNTER",cnvtdatetime(sysdate),
      "")
     IF ( NOT (applywriteoffhold(applyholdrequest)))
      CALL logmessage("writeChargeWOEvaluationToWTP","Failed to apply Evaluate Write-OFF hold",
       log_error)
      SET returnval = false
     ENDIF
    ENDIF
    RETURN(returnval)
  END ;Subroutine
 ENDIF
 IF (validate(applywriteoffhold,char(128))=char(128))
  SUBROUTINE (applywriteoffhold(prapplyholdrequest=vc(ref)) =i2)
    RECORD applyholdreply(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
      1 objarray[*]
        2 service_cd = f8
        2 updt_id = f8
        2 event_key = vc
        2 category_key = vc
        2 published_ind = i2
        2 pe_status_reason_cd = f8
        2 acct_id = f8
        2 activity_id = f8
        2 batch_denial_file_r_id = f8
        2 batch_trans_ext_id = f8
        2 batch_trans_file_id = f8
        2 batch_trans_id = f8
        2 benefit_order_id = f8
        2 bill_item_id = f8
        2 bill_templ_id = f8
        2 bill_vrsn_nbr = i4
        2 billing_entity_id = f8
        2 bo_hp_reltn_id = f8
        2 charge_item_id = f8
        2 chrg_activity_id = f8
        2 claim_status_id = f8
        2 client_org_id = f8
        2 corsp_activity_id = f8
        2 corsp_log_reltn_id = f8
        2 denial_id = f8
        2 dirty_flag = i4
        2 encntr_id = f8
        2 guar_acct_id = f8
        2 guarantor_id = f8
        2 health_plan_id = f8
        2 long_text_id = f8
        2 organization_id = f8
        2 payor_org_id = f8
        2 pe_status_reason_id = f8
        2 person_id = f8
        2 pft_balance_id = f8
        2 pft_bill_activity_id = f8
        2 pft_charge_id = f8
        2 pft_encntr_fact_id = f8
        2 pft_encntr_id = f8
        2 pft_line_item_id = f8
        2 trans_alias_id = f8
        2 pft_payment_plan_id = f8
        2 daily_encntr_bal_id = f8
        2 daily_acct_bal_id = f8
        2 active_ind = i2
        2 active_status_cd = f8
        2 active_status_disp = vc
        2 active_status_desc = vc
        2 active_status_mean = vc
        2 active_status_code_set = f8
        2 active_status_dt_tm = dq8
        2 active_status_prsnl_id = f8
        2 beg_effective_dt_tm = dq8
        2 end_effective_dt_tm = dq8
        2 updt_applctx = f8
        2 updt_cnt = i4
        2 updt_dt_tm = dq8
        2 updt_id = f8
        2 updt_task = f8
        2 benefit_status_cd = f8
        2 financial_class_cd = f8
        2 payment_plan_flag = i2
        2 payment_location_id = f8
        2 encntr_plan_cob_id = f8
        2 guarantor_account_id = f8
        2 guarantor_id1 = f8
        2 guarantor_id2 = f8
        2 cbos_pe_reltn_id = f8
        2 post_dt_tm = dq8
        2 posting_category_type_flag = i2
    ) WITH protect
    IF (size(prapplyholdrequest->objarray,5) > 0)
     EXECUTE pft_apply_bill_hold_suspension  WITH replace("REQUEST",prapplyholdrequest), replace(
      "REPLY",applyholdreply)
     IF ((applyholdreply->status_data.status="F"))
      CALL logmessage("writeChargeWOEvaluationToWTP","Failed to apply Evaluate Write-OFF hold",
       log_error)
      RETURN(false)
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 CALL echo("Begin PFT_NT_GLOBAL_CONSTANTS.INC, version [CHARGSRV-14113.013]")
 IF ( NOT (validate(gconstants->posting_error_unknown_cd)))
  RECORD gconstants(
    1 interim_bill_flag_initial = i2
    1 interim_bill_flag_continuing = i2
    1 interim_bill_flag_final = i2
    1 suppress_flag_none = i2
    1 suppress_flag_claim_only = i2
    1 suppress_flag_bill_only = i2
    1 suppress_flag_claim_and_bill = i2
    1 process_flag_pending = i2
    1 process_flag_suspended = i2
    1 process_flag_posted = i2
    1 process_flag_abn_required = i2
    1 process_flag_absorbed = i2
    1 process_flag_interfaced = i2
    1 recur_bill_opt_flag_episode = i2
    1 recur_bill_opt_flag_month = i2
    1 recur_bill_opt_flag_flex = i2
    1 recur_wait_coding_flag_first = i2
    1 recur_wait_coding_flag_all = i2
    1 debit_flag = i2
    1 credit_flag = i2
    1 zero_flag = i2
    1 cs_4
      2 person_alias_type_account_cd = f8
      2 person_alias_type_cmrn_cd = f8
      2 person_alias_type_mrn_cd = f8
    1 cs_8
      2 data_status_authenticated_cd = f8
    1 cs_69
      2 encounter_type_class_recurring_cd = f8
    1 cs_319
      2 encntr_alias_type_financial_number_cd = f8
    1 cs_354
      2 financial_class_selfpay_cd = f8
    1 cs_370
      2 org_plan_reltn_type_carrier_cd = f8
    1 cs_13016
      2 charge_entry_cd = f8
    1 cs_13019
      2 charge_mod_type_bill_code_cd = f8
      2 charge_mod_type_suspense_cd = f8
      2 charge_mod_type_other_cd = f8
      2 charge_mod_type_financial_combine_cd = f8
      2 charge_mod_type_financial_uncombine_cd = f8
      2 charge_mod_type_noncovered_cd = f8
    1 cs_13028
      2 charge_type_credit_cd = f8
      2 charge_type_debit_cd = f8
    1 cs_13030
      2 cs_suspense_reason_posting_error_cd = f8
      2 cs_suspense_reason_no_icd9_cd = f8
      2 cs_suspense_reason_posting_error_disp = c40
    1 cs_18649
      2 transaction_type_charge_cd = f8
    1 cs_18734
      2 account_status_reason_auto_create_cd = f8
    1 cs_18735
      2 account_status_open_cd = f8
    1 cs_18736
      2 account_type_ar_cd = f8
    1 cs_18935
      2 bill_status_canceled_cd = f8
      2 bill_status_canceled_submitted_cd = f8
      2 bill_status_canceled_ready_submit_cd = f8
      2 bill_status_converted_print_image_cd = f8
      2 bill_status_rejected_cd = f8
      2 bill_status_submitted_cd = f8
      2 bill_status_transmitted_cd = f8
      2 bill_status_zero_bal_billed_cd = f8
      2 bill_status_zero_bal_not_billed_cd = f8
      2 bill_status_denied_cd = f8
      2 bill_status_deniedreview_cd = f8
      2 bill_status_transmitted_by_xover_cd = f8
      2 bill_status_submitted_by_asb_cd = f8
      2 bill_status_transmitted_by_asb_cd = f8
    1 cs_18936
      2 role_type_client_cd = f8
      2 role_type_patient_cd = f8
      2 role_type_guarantor_cd = f8
      2 role_type_guarantorpatient_cd = f8
      2 role_type_client_related_cd = f8
    1 cs_18937
      2 transaction_reason_late_charge_proc_cd = f8
    1 cs_18938
      2 transaction_status_active_cd = f8
    1 cs_20509
      2 journal_status_posted_cd = f8
    1 cs_20849
      2 account_sub_type_client_cd = f8
      2 account_sub_type_patient_cd = f8
      2 account_sub_type_guarantor_cd = f8
      2 account_sub_type_research_cd = f8
    1 cs_21749
      2 bill_type_hcfa_1450_cd = f8
      2 bill_type_hcfa_1500_cd = f8
    1 cs_21849
      2 bill_class_claim_cd = f8
    1 cs_22449
      2 profit_type_client_account_cd = f8
      2 profit_type_client_bill_only_cd = f8
      2 profit_type_client_bill_and_ar_cd = f8
    1 cs_24269
      2 pft_encntr_status_active_cd = f8
      2 pft_encntr_status_pending_cd = f8
    1 cs_24429
      2 be_domain_type_acute_care_cd = f8
    1 cs_24450
      2 pe_status_reason_72_hour_rule_cd = f8
      2 pe_status_reason_bill_combine_hold_cd = f8
      2 pe_status_reason_wait_discharge_hold_cd = f8
      2 pe_status_reason_wait_for_coding_hold_cd = f8
      2 pe_status_reason_standard_delay_hold_cd = f8
      2 pe_status_reason_no_rug_code_hold_cd = f8
      2 pe_status_reason_bad_rug_code_days_hold_cd = f8
      2 pe_status_reason_rug_code_error_hold_cd = f8
      2 pe_status_reason_diagnosis_assoc_hold_cd = f8
    1 cs_24451
      2 bo_hp_status_in_process_cd = f8
      2 bo_hp_status_invalid_cd = f8
      2 bo_hp_status_ready_to_bill_cd = f8
      2 bo_hp_status_transmitted_by_xover_cd = f8
      2 bo_hp_status_generated_cd = f8
      2 bo_hp_status_wait_for_prior_cd = f8
    1 cs_25872
      2 hold_reason_bill_combine_cd = f8
      2 hold_reason_charge_evaluation_cd = f8
      2 hold_reason_end_of_period_cd = f8
      2 hold_reason_package_pricing_cd = f8
      2 hold_reason_suspended_charges_cd = f8
      2 hold_reason_standard_delay_cd = f8
      2 hold_reason_skilled_nursing_cd = f8
    1 cs_26032
      2 account_number_type_cmrn_cd = f8
      2 account_number_type_mrn_cd = f8
    1 cs_26052
      2 hold_criteria_combine_from_cd = f8
      2 hold_criteria_combine_to_cd = f8
      2 hold_criteria_encntr_type_cd = f8
      2 hold_criteria_end_of_period_date_cd = f8
      2 hold_criteria_health_plan_cd = f8
      2 hold_criteria_fin_class_cd = f8
      2 hold_criteria_payer_cd = f8
      2 hold_criteria_excfacility_cd = f8
    1 cs_28422
      2 adjudicated_status_none_cd = f8
    1 cs_28640
      2 bts_criteria_charge_group_cd = f8
      2 bts_criteria_billing_entity_cd = f8
      2 bts_criteria_encntr_type_cd = f8
      2 bts_criteria_financial_class_cd = f8
      2 bts_criteria_health_plan_cd = f8
      2 bts_criteria_insurance_org_cd = f8
    1 cs_29320
      2 entity_type_claim_cd = f8
      2 entity_type_pft_encntr_cd = f8
    1 cs_29322
      2 queue_event_late_charge_cd = f8
      2 queue_event_diagnosis_review_comp_cd = f8
    1 cs_29920
      2 proration_type_payer_cd = f8
    1 cs_323570
      2 bill_activity_type_charge_cd = f8
    1 cs_325570
      2 amount_type_charge_cd = f8
    1 cs_4001910
      2 posting_error_unknown_cd = f8
      2 posting_error_invalid_charge_cd = f8
      2 posting_error_service_date_cd = f8
      2 posting_error_no_debit_cd = f8
      2 posting_error_no_ar_account_cd = f8
      2 posting_error_no_rev_account_cd = f8
      2 posting_error_billing_entity_cd = f8
      2 posting_error_no_cpt_cd = f8
      2 posting_error_no_cdm_cd = f8
      2 posting_error_no_rev_cd = f8
      2 posting_error_no_mrn_acct_nbr_cd = f8
      2 posting_error_no_cmrn_acct_nbr_cd = f8
      2 posting_error_in_bad_debt_cd = f8
      2 posting_error_pend_reg_mod_cd = f8
      2 posting_error_dx_mapping_cd = f8
      2 posting_error_charge_wo_cd = f8
      2 posting_error_invalid_cob_cd = f8
      2 cs_suspense_reason_posting_cg_dt_qual = f8
      2 posting_error_invalid_encntr_type_cd = f8
    1 cs_22089
      2 bill_status_reason_voided_cd = f8
  )
  SET gconstants->interim_bill_flag_initial = 1
  SET gconstants->interim_bill_flag_continuing = 2
  SET gconstants->interim_bill_flag_final = 3
  SET gconstants->suppress_flag_none = 0
  SET gconstants->suppress_flag_claim_only = 1
  SET gconstants->suppress_flag_bill_only = 2
  SET gconstants->suppress_flag_claim_and_bill = 3
  SET gconstants->process_flag_pending = 0
  SET gconstants->process_flag_suspended = 1
  SET gconstants->process_flag_posted = 100
  SET gconstants->process_flag_abn_required = 8
  SET gconstants->process_flag_absorbed = 7
  SET gconstants->process_flag_interfaced = 999
  SET gconstants->recur_bill_opt_flag_episode = 1
  SET gconstants->recur_bill_opt_flag_month = 2
  SET gconstants->recur_bill_opt_flag_flex = 3
  SET gconstants->recur_wait_coding_flag_first = 1
  SET gconstants->recur_wait_coding_flag_all = 2
  SET gconstants->zero_flag = 0
  SET gconstants->debit_flag = 1
  SET gconstants->credit_flag = 2
  SET gconstants->person_alias_type_account_cd = getcodevalue(4,"ACCOUNT",1)
  SET gconstants->person_alias_type_cmrn_cd = getcodevalue(4,"CMRN",1)
  SET gconstants->person_alias_type_mrn_cd = getcodevalue(4,"MRN",1)
  SET gconstants->data_status_authenticated_cd = getcodevalue(8,"AUTH",1)
  SET gconstants->encounter_type_class_recurring_cd = getcodevalue(69,"RECURRING",1)
  SET gconstants->encntr_alias_type_financial_number_cd = getcodevalue(319,"FIN NBR",1)
  SET gconstants->financial_class_selfpay_cd = getcodevalue(354,"SELFPAY",1)
  SET gconstants->org_plan_reltn_type_carrier_cd = getcodevalue(370,"CARRIER",1)
  SET gconstants->charge_entry_cd = getcodevalue(13016,"CHARGE ENTRY",1)
  SET gconstants->charge_mod_type_bill_code_cd = getcodevalue(13019,"BILL CODE",1)
  SET gconstants->charge_mod_type_suspense_cd = getcodevalue(13019,"SUSPENSE",1)
  SET gconstants->charge_mod_type_other_cd = getcodevalue(13019,"OTHER",1)
  SET gconstants->charge_mod_type_financial_combine_cd = getcodevalue(13019,"FIN CMB",1)
  SET gconstants->charge_mod_type_financial_uncombine_cd = getcodevalue(13019,"FIN UNCMB",1)
  SET gconstants->charge_mod_type_noncovered_cd = getcodevalue(13019,"NONCOVERED",1)
  SET gconstants->charge_type_credit_cd = getcodevalue(13028,"CR",1)
  SET gconstants->charge_type_debit_cd = getcodevalue(13028,"DR",1)
  SET gconstants->cs_suspense_reason_posting_error_cd = getcodevalue(13030,"POSTING",1)
  SET gconstants->cs_suspense_reason_no_icd9_cd = getcodevalue(13030,"NOICD9",1)
  SET gconstants->cs_suspense_reason_posting_error_disp = uar_get_code_display(gconstants->
   cs_suspense_reason_posting_error_cd)
  SET gconstants->transaction_type_charge_cd = getcodevalue(18649,"CHARGE",1)
  SET gconstants->account_status_reason_auto_create_cd = getcodevalue(18734,"AUTO CREATE",1)
  SET gconstants->account_status_open_cd = getcodevalue(18735,"OPEN",1)
  SET gconstants->account_type_ar_cd = getcodevalue(18736,"A/R",1)
  SET gconstants->bill_status_canceled_cd = getcodevalue(18935,"CANCELED",1)
  SET gconstants->bill_status_canceled_submitted_cd = getcodevalue(18935,"CNCLSBMTED",1)
  SET gconstants->bill_status_canceled_ready_submit_cd = getcodevalue(18935,"RTS CANCEL",1)
  SET gconstants->bill_status_converted_print_image_cd = getcodevalue(18935,"CONVERTED",1)
  SET gconstants->bill_status_rejected_cd = getcodevalue(18935,"REJECTED",1)
  SET gconstants->bill_status_submitted_cd = getcodevalue(18935,"SUBMITTED",1)
  SET gconstants->bill_status_transmitted_cd = getcodevalue(18935,"TRANSMITTED",1)
  SET gconstants->bill_status_zero_bal_billed_cd = getcodevalue(18935,"ZEROBILL",1)
  SET gconstants->bill_status_zero_bal_not_billed_cd = getcodevalue(18935,"ZERONOTBILL",1)
  SET gconstants->bill_status_denied_cd = getcodevalue(18935,"DENIED",1)
  SET gconstants->bill_status_deniedreview_cd = getcodevalue(18935,"DENIEDREVIEW",1)
  SET gconstants->bill_status_transmitted_by_xover_cd = getcodevalue(18935,"TRANSXOVRPAY",1)
  SET gconstants->bill_status_submitted_by_asb_cd = getcodevalue(18935,"SUBMITBYASB",1)
  SET gconstants->bill_status_transmitted_by_asb_cd = getcodevalue(18935,"TRANSBYASB",1)
  SET gconstants->role_type_client_cd = getcodevalue(18936,"CLIENT",1)
  SET gconstants->role_type_patient_cd = getcodevalue(18936,"PATIENT",1)
  SET gconstants->role_type_guarantor_cd = getcodevalue(18936,"GUARANTOR",1)
  SET gconstants->role_type_guarantorpatient_cd = getcodevalue(18936,"GUARANTORPAT",1)
  SET gconstants->role_type_client_related_cd = getcodevalue(18936,"RELATEDCLT",1)
  SET gconstants->transaction_reason_late_charge_proc_cd = getcodevalue(18937,"LT CHRG PROC",1)
  SET gconstants->transaction_status_active_cd = getcodevalue(18938,"ACTIVE",1)
  SET gconstants->journal_status_posted_cd = getcodevalue(20509,"POSTED",1)
  SET gconstants->account_sub_type_client_cd = getcodevalue(20849,"CLIENT",1)
  SET gconstants->account_sub_type_patient_cd = getcodevalue(20849,"PATIENT",1)
  SET gconstants->account_sub_type_guarantor_cd = getcodevalue(20849,"GUARANTOR",1)
  SET gconstants->account_sub_type_research_cd = getcodevalue(20849,"RESEARCH",1)
  SET gconstants->account_sub_type_research_cd = getcodevalue(20849,"RESEARCH",1)
  SET gconstants->bill_type_hcfa_1450_cd = getcodevalue(21749,"HCFA_1450",1)
  SET gconstants->bill_type_hcfa_1500_cd = getcodevalue(21749,"HCFA_1500",1)
  SET gconstants->bill_class_claim_cd = getcodevalue(21849,"CLAIM",1)
  SET gconstants->profit_type_client_account_cd = getcodevalue(22449,"PFTCLTACCT",1)
  SET gconstants->profit_type_client_bill_only_cd = getcodevalue(22449,"PFTCLTBILL",1)
  SET gconstants->profit_type_client_bill_and_ar_cd = getcodevalue(22449,"PFTPTACCT",1)
  SET gconstants->pft_encntr_status_active_cd = getcodevalue(24269,"ACTIVE",1)
  SET gconstants->pft_encntr_status_pending_cd = getcodevalue(24269,"PENDING",1)
  SET gconstants->be_domain_type_acute_care_cd = getcodevalue(24429,"ACUTE CARE",1)
  SET gconstants->pe_status_reason_72_hour_rule_cd = getcodevalue(24450,"72HOURRULE",1)
  SET gconstants->pe_status_reason_bill_combine_hold_cd = getcodevalue(24450,"BILLCOMBHOLD",1)
  SET gconstants->pe_status_reason_wait_discharge_hold_cd = getcodevalue(24450,"WAITDISCH",1)
  SET gconstants->pe_status_reason_wait_for_coding_hold_cd = getcodevalue(24450,"WAITCODING",1)
  SET gconstants->pe_status_reason_standard_delay_hold_cd = getcodevalue(24450,"STDDELAY",1)
  SET gconstants->pe_status_reason_no_rug_code_hold_cd = getcodevalue(24450,"NORUGCODE",1)
  SET gconstants->pe_status_reason_bad_rug_code_days_hold_cd = getcodevalue(24450,"BADRUGCDDAYS",1)
  SET gconstants->pe_status_reason_rug_code_error_hold_cd = getcodevalue(24450,"ERR_RUGCD",1)
  SET gconstants->pe_status_reason_diagnosis_assoc_hold_cd = getcodevalue(24450,"DXASSOCINC",1)
  SET gconstants->bo_hp_status_in_process_cd = getcodevalue(24451,"INPROCESS",1)
  SET gconstants->bo_hp_status_invalid_cd = getcodevalue(24451,"INVALID",1)
  SET gconstants->bo_hp_status_ready_to_bill_cd = getcodevalue(24451,"READYTOBILL",1)
  SET gconstants->bo_hp_status_transmitted_by_xover_cd = getcodevalue(24451,"TRANSXOVRPAY",1)
  SET gconstants->bo_hp_status_generated_cd = getcodevalue(24451,"GENERATED",1)
  SET gconstants->bo_hp_status_wait_for_prior_cd = getcodevalue(24451,"WAITBOCOMPL",1)
  SET gconstants->hold_reason_bill_combine_cd = getcodevalue(25872,"BILL_COMBINE",1)
  SET gconstants->hold_reason_charge_evaluation_cd = getcodevalue(25872,"CHARGEEVAL",1)
  SET gconstants->hold_reason_end_of_period_cd = getcodevalue(25872,"ENDOFPERIOD",1)
  SET gconstants->hold_reason_package_pricing_cd = getcodevalue(25872,"PKGPRICING",1)
  SET gconstants->hold_reason_suspended_charges_cd = getcodevalue(25872,"SUSPENDCHRGS",1)
  SET gconstants->hold_reason_standard_delay_cd = getcodevalue(25872,"STND_DELAY",1)
  SET gconstants->hold_reason_skilled_nursing_cd = getcodevalue(25872,"SKLD_NRSNG",1)
  SET gconstants->account_number_type_cmrn_cd = getcodevalue(26032,"CMRN",1)
  SET gconstants->account_number_type_mrn_cd = getcodevalue(26032,"MRN",1)
  SET gconstants->hold_criteria_combine_from_cd = getcodevalue(26052,"CMBFRMENCTYP",1)
  SET gconstants->hold_criteria_combine_to_cd = getcodevalue(26052,"CMBTOENCTYPE",1)
  SET gconstants->hold_criteria_encntr_type_cd = getcodevalue(26052,"ENCNTR_TYPE",1)
  SET gconstants->hold_criteria_end_of_period_date_cd = getcodevalue(26052,"ENDOFPERDT",1)
  SET gconstants->hold_criteria_health_plan_cd = getcodevalue(26052,"HEALTHPLAN",1)
  SET gconstants->hold_criteria_fin_class_cd = getcodevalue(26052,"FINCLASS",1)
  SET gconstants->hold_criteria_payer_cd = getcodevalue(26052,"PAYER",1)
  SET gconstants->hold_criteria_excfacility_cd = getcodevalue(26052,"EXCFACILITY",1)
  SET gconstants->adjudicated_status_none_cd = getcodevalue(28422,"NONE",1)
  SET gconstants->bts_criteria_charge_group_cd = getcodevalue(28640,"CHARGEGROUP",1)
  SET gconstants->bts_criteria_billing_entity_cd = getcodevalue(28640,"BILLENTITY",1)
  SET gconstants->bts_criteria_encntr_type_cd = getcodevalue(28640,"ENCNTRTYPE",1)
  SET gconstants->bts_criteria_financial_class_cd = getcodevalue(28640,"FINCLASS",1)
  SET gconstants->bts_criteria_health_plan_cd = getcodevalue(28640,"HEALTHPLAN",1)
  SET gconstants->bts_criteria_insurance_org_cd = getcodevalue(28640,"INSURANCEORG",1)
  SET gconstants->entity_type_claim_cd = getcodevalue(29320,"CLAIM",1)
  SET gconstants->entity_type_pft_encntr_cd = getcodevalue(29320,"PFTENCNTR",1)
  SET gconstants->queue_event_late_charge_cd = getcodevalue(29322,"LATECHARGE",1)
  SET gconstants->queue_event_diagnosis_review_comp_cd = getcodevalue(29322,"DXASSOCCOMP",1)
  SET gconstants->proration_type_payer_cd = getcodevalue(29920,"PAYER",1)
  SET gconstants->bill_activity_type_charge_cd = getcodevalue(323570,"CHARGE",1)
  SET gconstants->amount_type_charge_cd = getcodevalue(325570,"CHARGE",1)
  SET gconstants->posting_error_unknown_cd = getcodevalue(4001910,"UNKNOWN",1)
  SET gconstants->posting_error_invalid_charge_cd = getcodevalue(4001910,"INVALIDCHRG",1)
  SET gconstants->posting_error_service_date_cd = getcodevalue(4001910,"INVALIDSRVDT",1)
  SET gconstants->posting_error_no_debit_cd = getcodevalue(4001910,"NODEBIT",1)
  SET gconstants->posting_error_no_ar_account_cd = getcodevalue(4001910,"NOARACCOUNT",1)
  SET gconstants->posting_error_no_rev_account_cd = getcodevalue(4001910,"NOREVACCOUNT",1)
  SET gconstants->posting_error_billing_entity_cd = getcodevalue(4001910,"NOBILLENTITY",1)
  SET gconstants->posting_error_no_cpt_cd = getcodevalue(4001910,"NOCPT",1)
  SET gconstants->posting_error_no_cdm_cd = getcodevalue(4001910,"NOCDM",1)
  SET gconstants->posting_error_no_rev_cd = getcodevalue(4001910,"NOREV",1)
  SET gconstants->posting_error_no_mrn_acct_nbr_cd = getcodevalue(4001910,"NOMRNACTNBR",1)
  SET gconstants->posting_error_no_cmrn_acct_nbr_cd = getcodevalue(4001910,"NOCMRNACTNBR",1)
  SET gconstants->posting_error_in_bad_debt_cd = getcodevalue(4001910,"INBADDEBT",1)
  SET gconstants->posting_error_pend_reg_mod_cd = getcodevalue(4001910,"PENDREGMOD",1)
  SET gconstants->posting_error_dx_mapping_cd = getcodevalue(4001910,"DXMAPFAILED",1)
  SET gconstants->posting_error_charge_wo_cd = getcodevalue(4001910,"CHRGWOFAILED",1)
  SET gconstants->posting_error_invalid_cob_cd = getcodevalue(4001910,"INVALIDCOB",1)
  SET gconstants->cs_suspense_reason_posting_cg_dt_qual = getcodevalue(4001910,"OUTSIDEQALDT",1)
  SET gconstants->posting_error_invalid_encntr_type_cd = getcodevalue(4001910,"INVALIDENCTP",1)
  SET gconstants->bill_status_reason_voided_cd = getcodevalue(22089,"VOIDED",1)
 ENDIF
 CALL echo("End PFT_NT_GLOBAL_CONSTANTS.INC")
 RECORD cmreq(
   1 objarray[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD cmrep(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FOR (nrequestcnt = 1 TO size(request->charges,5))
   UPDATE  FROM charge c
    SET c.process_flg = 0, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (c.charge_item_id=request->charges[nrequestcnt].charge_item_id)
    WITH nocounter
   ;end update
 ENDFOR
 FOR (nrequestcnt = 1 TO size(request->charges,5))
   DECLARE billcdcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(cmreq->objarray,0)
   SELECT INTO "nl:"
    FROM charge_mod cm
    WHERE (cm.charge_item_id=request->charges[nrequestcnt].charge_item_id)
     AND (cm.charge_mod_type_cd=gconstants->charge_mod_type_suspense_cd)
     AND cm.active_ind=true
    DETAIL
     billcdcnt += 1, stat = alterlist(cmreq->objarray,billcdcnt), cmreq->objarray[billcdcnt].
     action_type = "DEL",
     cmreq->objarray[billcdcnt].charge_mod_id = cm.charge_mod_id, cmreq->objarray[billcdcnt].
     charge_item_id = cm.charge_item_id, cmreq->objarray[billcdcnt].updt_cnt = cm.updt_cnt,
     cmreq->objarray[billcdcnt].active_ind = false
    WITH nocounter
   ;end select
   IF (size(cmreq->objarray,5) <= 0)
    CALL echo("No charge_mods to update")
   ELSE
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE pft_nt_chrg_billing
 SET reply->status_data.status = "S"
END GO
