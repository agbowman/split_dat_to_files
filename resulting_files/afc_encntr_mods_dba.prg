CREATE PROGRAM afc_encntr_mods:dba
 DECLARE afc_encntr_mods = vc WITH protect, constant("RCBACM-25363.018")
 RECORD wtptaskrequest(
   1 transaction = vc
   1 o_encntr_id = f8
   1 o_encntr_type_cd = f8
   1 n_encntr_type_cd = f8
   1 o_encntr_type_class_cd = f8
   1 n_encntr_type_class_cd = f8
   1 o_fin_class_cd = f8
   1 n_fin_class_cd = f8
   1 o_loc_nurse_unit_cd = f8
   1 n_loc_nurse_unit_cd = f8
   1 o_disch_dt_tm = dq8
   1 n_disch_dt_tm = dq8
   1 omitrebillind = i2
   1 apply_self_pay_ind = i2
   1 add_crossover_hp_ind = i2
   1 o_loc_facility_cd = f8
   1 n_loc_facility_cd = f8
 ) WITH protect
 RECORD addtaskqueuerequest(
   1 requestjson = vc
   1 processdttm = dq8
   1 taskident = vc
   1 entityname = vc
   1 entityid = f8
   1 taskdatatxt = vc
 ) WITH protect
 RECORD addtaskqueuereply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD cancelencounterrequest(
   1 encntr_id = f8
 ) WITH protect
 RECORD cancelencounterreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD integritycheckreq(
   1 transaction_id = f8
   1 n_encntr_id = f8
 ) WITH protect
 RECORD integritycheckrep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
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
 CALL echo("Begin PFT_RM_STATUS_DETAIL_CONSTANTS.INC, version [545118.007]")
 IF ( NOT (validate(status_detail_lock_error)))
  DECLARE status_detail_lock_error = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(status_detail_suspended_charges)))
  DECLARE status_detail_suspended_charges = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(status_detail_invalid_cob)))
  DECLARE status_detail_invalid_cob = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(status_detail_encounter_in_history)))
  DECLARE status_detail_encounter_in_history = i4 WITH protect, constant(4)
 ENDIF
 IF ( NOT (validate(status_detail_encounter_in_baddebt)))
  DECLARE status_detail_encounter_in_baddebt = i4 WITH protect, constant(5)
 ENDIF
 IF ( NOT (validate(status_detail_skip_rebill_event_error)))
  DECLARE status_detail_skip_rebill_event_error = i4 WITH protect, constant(6)
 ENDIF
 IF ( NOT (validate(status_detail_skip_rebill_chrg_error)))
  DECLARE status_detail_skip_rebill_chrg_error = i4 WITH protect, constant(7)
 ENDIF
 IF ( NOT (validate(status_detail_hp_add_fail_835_posting)))
  DECLARE status_detail_hp_add_fail_835_posting = i4 WITH protect, constant(10)
 ENDIF
 IF ( NOT (validate(status_detail_guarantor_error)))
  DECLARE status_detail_guarantor_error = i4 WITH protect, constant(11)
 ENDIF
 IF ( NOT (validate(status_detail_enctype_error)))
  DECLARE status_detail_enctype_error = i4 WITH protect, constant(12)
 ENDIF
 CALL echo(build("Including PFT_XML_COMMON_SUBS.INC, version [",nullterm("356730.006"),"]"))
 SUBROUTINE (begindocument(pbuffer=vc,pencoding=vc) =vc)
   RETURN(concat(pbuffer,'<?xml version="1.0" encoding="',trim(pencoding,3),'"?>'))
 END ;Subroutine
 SUBROUTINE (beginelement(pbuffer=vc,pname=vc) =vc)
   RETURN(concat(pbuffer,"<",trim(pname,3),">"))
 END ;Subroutine
 SUBROUTINE (endelement(pbuffer=vc,pname=vc) =vc)
   RETURN(concat(pbuffer,"</",trim(pname,3),">"))
 END ;Subroutine
 SUBROUTINE (writeelement(pbuffer=vc,pname=vc,pvalue=vc) =vc)
  IF (size(trim(pvalue,3)) > 0)
   RETURN(concat(pbuffer,"<",trim(pname,3),">",trim(replaceescapablecharacters(pvalue),3),
    "</",trim(pname,3),">"))
  ENDIF
  RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (writeelementnotrim(pbuffer=vc,pname=vc,pvalue=vc) =vc)
  IF (size(trim(pvalue,3)) > 0)
   RETURN(concat(pbuffer,"<",trim(pname,3),">",replaceescapablecharacters(pvalue),
    "</",trim(pname,3),">"))
  ENDIF
  RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (beginelementname(pbuffer=vc,pname=vc) =vc)
   RETURN(concat(pbuffer,"<",trim(pname,3)))
 END ;Subroutine
 SUBROUTINE (writeattribute(pbuffer=vc,pname=vc,pvalue=vc) =vc)
  IF (size(trim(pvalue,3)) > 0)
   RETURN(concat(pbuffer," ",trim(pname,3),'="',trim(replaceescapablecharacters(pvalue),3),
    '"'))
  ENDIF
  RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (endelementname(pbuffer=vc) =vc)
   RETURN(concat(pbuffer,">"))
 END ;Subroutine
 SUBROUTINE (writevalue(pbuffer=vc,pvalue=vc) =vc)
   RETURN(concat(pbuffer,trim(replaceescapablecharacters(pvalue),3)))
 END ;Subroutine
 SUBROUTINE (replaceescapablecharacters(ptext=vc) =vc)
   DECLARE str_out = vc WITH protect, noconstant("")
   SET str_out = replace(ptext,"&","&amp;",0)
   SET str_out = replace(str_out,"<","&lt;",0)
   SET str_out = replace(str_out,">","&gt;",0)
   SET str_out = replace(str_out,char(34),"&quot;",0)
   SET str_out = replace(str_out,char(39),"&apos;",0)
   RETURN(str_out)
 END ;Subroutine
 SUBROUTINE (toxmldateformat(pdate=q8) =vc)
   RETURN(format(pdate,"YYYY-MM-DD;;d"))
 END ;Subroutine
 SUBROUTINE (writedateelement(pbuffer=vc,pname=vc,pdate=q8) =vc)
   DECLARE tmp_str = vc WITH protect, noconstant("")
   SET tmp_str = format(pdate,"YYYY-MM-DD;;d")
   IF (size(trim(tmp_str,3)) > 0)
    RETURN(concat(pbuffer,"<",trim(pname,3),">",trim(replaceescapablecharacters(tmp_str),3),
     "</",trim(pname,3),">"))
   ENDIF
   RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (writedatetimeelement(pbuffer=vc,pname=vc,pdate=q8) =vc)
   DECLARE datetime = vc WITH protect, noconstant(format(pdate,"YYYY-MM-DDTHH:MM:SS;3;Q"))
   IF (size(trim(datetime,3)) > 0)
    RETURN(concat(pbuffer,"<",trim(pname,3),">",trim(replaceescapablecharacters(datetime),3),
     "</",trim(pname,3),">"))
   ENDIF
   RETURN(pbuffer)
 END ;Subroutine
 SUBROUTINE (writecodetype(pbuffer=vc,pname=vc,pcodevalue=f8) =vc)
   DECLARE meaning = vc WITH protect, noconstant("")
   DECLARE displaykey = vc WITH protect, noconstant("")
   DECLARE alias = vc WITH private, noconstant("")
   DECLARE lindex = i4 WITH protect, noconstant(0)
   DECLARE pbuffer1 = vc WITH protect, noconstant("")
   DECLARE pbuffer2 = vc WITH protect, noconstant("")
   DECLARE pbuffer3 = vc WITH protect, noconstant("")
   DECLARE pbuffer4 = vc WITH protect, noconstant("")
   DECLARE pbuffer5 = vc WITH protect, noconstant("")
   DECLARE pbuffer6 = vc WITH protect, noconstant("")
   DECLARE pbuffer7 = vc WITH protect, noconstant(pbuffer)
   IF (pcodevalue > 0.0)
    IF (validate(gpreferences->currentbatchcontributorsources.contributorsourcecd,0.0) > 0.0)
     SET alias = getcachedcodevalueoutboundalias(gpreferences->currentbatchcontributorsources.
      contributorsourcecd,pcodevalue)
    ENDIF
    IF ( NOT (alias > ""))
     IF (validate(gpreferences->currentbatchcontributorsources.altcontributorsourcecd,0.0) > 0.0)
      SET alias = getcachedcodevalueoutboundalias(gpreferences->currentbatchcontributorsources.
       altcontributorsourcecd,pcodevalue)
     ENDIF
    ENDIF
    SET meaning = uar_get_code_meaning(pcodevalue)
    SET displaykey = cnvtupper(cnvtalphanum(uar_get_code_display(pcodevalue)))
    IF (((size(trim(meaning,3)) > 0) OR (((size(trim(displaykey,3)) > 0) OR (size(trim(alias,3)) > 0
    )) )) )
     SET pbuffer1 = beginelementname(pbuffer,pname)
     SET pbuffer2 = writeattribute(pbuffer1,"id",cnvtstring(pcodevalue,17))
     SET pbuffer3 = writeattribute(pbuffer2,"meaning",meaning)
     SET pbuffer4 = writeattribute(pbuffer3,"displayKey",displaykey)
     SET pbuffer5 = writeattribute(pbuffer4,"outboundAlias",alias)
     SET pbuffer6 = endelementname(pbuffer5)
     SET pbuffer7 = endelement(pbuffer6,pname)
    ENDIF
   ENDIF
   RETURN(pbuffer7)
 END ;Subroutine
 SUBROUTINE (writecodeextendedtype(pbuffer=vc,pname=vc,pcodevalue=f8) =vc)
   DECLARE meaning = vc WITH protect, noconstant(nullterm(""))
   DECLARE displaykey = vc WITH protect, noconstant(nullterm(""))
   DECLARE outboundalias = vc WITH protect, noconstant(nullterm(""))
   DECLARE outboundaliases = vc WITH protect, noconstant(nullterm(""))
   DECLARE pbuffer1 = vc WITH protect, noconstant("")
   DECLARE pbuffer2 = vc WITH protect, noconstant("")
   DECLARE pbuffer3 = vc WITH protect, noconstant("")
   DECLARE pbuffer4 = vc WITH protect, noconstant("")
   DECLARE pbuffer5 = vc WITH protect, noconstant("")
   DECLARE pbuffer6 = vc WITH protect, noconstant("")
   DECLARE pbuffer7 = vc WITH protect, noconstant(pbuffer)
   IF (pcodevalue > 0.0)
    IF (validate(gpreferences->currentbatchcontributorsources.contributorsourcecd,0.0) > 0.0)
     DECLARE bottom = i4 WITH private, noconstant(0)
     DECLARE top = i4 WITH private, noconstant(0)
     DECLARE middle = i4 WITH private, noconstant(0)
     DECLARE done = i2 WITH private, noconstant(false)
     DECLARE sindex = i4 WITH private, noconstant(0)
     DECLARE lindex = i4 WITH protect, noconstant(0)
     DECLARE aidx = i4 WITH private, noconstant(0)
     DECLARE acnt = i4 WITH private, noconstant(0)
     SET sindex = locateval(lindex,1,size(codevalueoutboundaliases->contributorsources,5),
      gpreferences->currentbatchcontributorsources.contributorsourcecd,codevalueoutboundaliases->
      contributorsources[lindex].contributorsourcecd)
     IF (sindex > 0)
      SET bottom = 1
      SET top = size(codevalueoutboundaliases->contributorsources[sindex].codevalues,5)
      IF (top > 0)
       WHILE (done=false
        AND bottom <= top)
        SET middle = ((top+ bottom)/ 2)
        IF ((pcodevalue < codevalueoutboundaliases->contributorsources[sindex].codevalues[middle].
        codevalue))
         SET top = (middle - 1)
        ELSEIF ((pcodevalue > codevalueoutboundaliases->contributorsources[sindex].codevalues[middle]
        .codevalue))
         SET bottom = (middle+ 1)
        ELSE
         SET acnt = size(codevalueoutboundaliases->contributorsources[sindex].codevalues[middle].
          aliases,5)
         IF (acnt > 0)
          FREE RECORD temprec
          RECORD temprec(
            1 xml = vc
          )
          SET temprec->xml = beginelement(temprec->xml,"outboundAliases")
          FOR (aidx = 1 TO acnt)
            IF (aidx=1)
             SET outboundalias = codevalueoutboundaliases->contributorsources[sindex].codevalues[
             middle].aliases[aidx].alias
            ENDIF
            SET temprec->xml = beginelementname(temprec->xml,"outboundAlias")
            SET temprec->xml = writeattribute(temprec->xml,"meaning",codevalueoutboundaliases->
             contributorsources[sindex].codevalues[middle].aliases[aidx].meaning)
            SET temprec->xml = writeattribute(temprec->xml,"alias",codevalueoutboundaliases->
             contributorsources[sindex].codevalues[middle].aliases[aidx].alias)
            SET temprec->xml = concat(temprec->xml,"/")
            SET temprec->xml = endelementname(temprec->xml)
          ENDFOR
          SET outboundaliases = endelement(temprec->xml,"outboundAliases")
          FREE RECORD temprec
         ENDIF
         SET done = true
        ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    ENDIF
    SET meaning = uar_get_code_meaning(pcodevalue)
    SET displaykey = cnvtupper(cnvtalphanum(uar_get_code_display(pcodevalue)))
    IF (((size(trim(meaning,3)) > 0) OR (((size(trim(displaykey,3)) > 0) OR (size(trim(outboundalias,
      3)) > 0)) )) )
     SET pbuffer1 = beginelementname(pbuffer,pname)
     SET pbuffer2 = writeattribute(pbuffer1,"id",cnvtstring(pcodevalue,17))
     SET pbuffer3 = writeattribute(pbuffer2,"meaning",meaning)
     SET pbuffer4 = writeattribute(pbuffer3,"displayKey",displaykey)
     SET pbuffer5 = writeattribute(pbuffer4,"outboundAlias",outboundalias)
     SET pbuffer6 = endelementname(pbuffer5)
     SET pbuffer7 = endelement(concat(pbuffer6,outboundaliases),pname)
    ENDIF
   ENDIF
   RETURN(pbuffer7)
 END ;Subroutine
 CALL echo("Begin PFT_RM_I18N_CONSTANTS.INC, version [645142.024]")
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE hi18n = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE i18n_apply_health_plan_mod_on_encounter_in_bad_debt_comment = vc WITH protect, constant(
  uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Health plan modification performed on an encounter in bad debt",
   "Health plan modification performed on an encounter in bad debt"))
 DECLARE i18n_apply_health_plan_mod_on_encounter_in_history_comment = vc WITH protect, constant(
  uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Health plan modification performed after encounter moved to history",
   "Health plan modification performed after encounter moved to history"))
 DECLARE i18n_apply_guarantor_added_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Added guarantor","Added guarantor"))
 DECLARE i18n_apply_guarantor_removed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Removed guarantor","Removed guarantor"))
 DECLARE i18n_apply_guarantor_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Changed guarantor from","Changed guarantor from"))
 DECLARE i18n_encntr_type_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter type changed","Encounter type changed"))
 DECLARE i18n_to = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"PFT_RM_I18N_CONSTANTS. to",
   " to"))
 DECLARE i18n_from = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"PFT_RM_I18N_CONSTANTS. from",
   " from"))
 DECLARE i18n_apply_formal_pay_plan_removed_comment = vc WITH protect, constant(uar_i18ngetmessage(
   hi18n,"PFT_RM_I18N_CONSTANTS.Encounter removed from formal payment plan",
   "Encounter removed from formal payment plan"))
 DECLARE i18n_added = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Added ","Added "))
 DECLARE i18n_removed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Removed ","Removed "))
 DECLARE i18n_changed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Changed ","Changed "))
 DECLARE i18n_insurance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. insurance "," insurance "))
 DECLARE i18n_primary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. primary "," primary "))
 DECLARE i18n_secondary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. secondary "," secondary "))
 DECLARE i18n_tertiary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. tertiary "," tertiary "))
 DECLARE i18n_fourth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. fourth "," fourth "))
 DECLARE i18n_fifth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. fifth "," fifth "))
 DECLARE i18n_sixth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. sixth "," sixth "))
 DECLARE i18n_seventh = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. seventh "," seventh "))
 DECLARE i18n_eighth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. eighth "," eighth "))
 DECLARE i18n_ninth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. ninth "," ninth "))
 DECLARE i18n_tenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. tenth "," tenth "))
 DECLARE i18n_eleventh = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. eleventh "," eleventh "))
 DECLARE i18n_twelfth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. twelfth "," twelfth "))
 DECLARE i18n_thirteenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. thirteenth "," thirteenth "))
 DECLARE i18n_fourteenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. forteenth "," forteenth "))
 DECLARE i18n_fifteenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. fifteenth "," fifteenth "))
 DECLARE i18n_sixteenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. sixteenth "," sixteenth "))
 DECLARE i18n_seventeenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. seventeenth "," seventeenth "))
 DECLARE i18n_eighteenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. eighteenth "," eighteenth "))
 DECLARE i18n_nineteenth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. nineteenth "," nineteenth "))
 DECLARE i18n_twentieth = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. twentieth "," twentieth "))
 DECLARE i18n_beyondtwenty = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS. beyondtwenty "," Health Plan "))
 DECLARE i18n_encntr_not_locked_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.The encounter was not able to be locked while processing the registration modifications",
   build(
    "The encounter was not able to be locked while processing the registration modifications. The modifications can ",
    " be reevaluated when other services have finished processing this encounter")))
 DECLARE i18n_invalid_cob_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Invalid coordination of benefits found for this encounter",
   "Invalid coordination of benefits found for this encounter"))
 DECLARE i18n_encntr_in_bad_debt_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter in bad debt","Encounter in bad debt"))
 DECLARE i18n_encntr_in_history_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter in history","Encounter in history"))
 DECLARE i18n_em_failed_to_suspended_charges_message = vc WITH protect, constant(uar_i18ngetmessage(
   hi18n,"PFT_RM_I18N_CONSTANTS.Encounter modification evaluation failed due to suspended charges ",
   "Encounter modification evaluation failed due to suspended charges "))
 DECLARE i18n_em_failed_to_lock_error_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter modification evaluation failed due to lock error",
   "Encounter modification evaluation failed due to lock error"))
 DECLARE i18n_em_failed_general_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter modification evaluation failed ",
   "Encounter modification evaluation failed "))
 DECLARE i18n_em_succeeded_general_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter modification was successfully evaluated",
   "Encounter modification was successfully evaluated"))
 DECLARE i18n_recurring_etc_pmcharge_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter type change occurred moving from or to a recurring encounter type",
   "Encounter type change occurred moving from or to a recurring encounter type on an encounter with room and bed charges"
   ))
 DECLARE i18n_skip_rebill_event_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.The encounter modification had additional modifications",build(
    "The encounter modification had additional modifications beyond ",
    "the primary health plan. The modification cannot bypass re-billing with this condition.")))
 DECLARE i18n_skip_rebill_chrg_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.The encounter had charges that re-tiered, had bill code changes, or were unable to process",
   build(
    "The encounter had charges that re-tiered, had bill code changes, or were unable to process. ",
    "The modification cannot bypass re-billing with these conditions.")))
 DECLARE i18n_admit_date_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Admit date changed","Admit date changed"))
 DECLARE i18n_cross_hp_fail_835_posting_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Crossover HP Failed During 835 Posting",
   "Crossover HP Failed During 835 Posting"))
 DECLARE i18n_authorization_beg_date_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(
   hi18n,"PFT_RM_I18N_CONSTANTS.Service begin date changed","service begin date changed"))
 DECLARE i18n_authorization_info_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Authorization","Authorization"))
 DECLARE i18n_authorization_end_date_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(
   hi18n,"PFT_RM_I18N_CONSTANTS.Service end date changed","service end date changed"))
 DECLARE i18n_authorization_type_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Type changed","type changed"))
 DECLARE i18n_authorization_deleted_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.is deleted","is deleted"))
 DECLARE i18n_authorization_newly_added_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.is added","is added"))
 DECLARE i18n_authorization_status_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(
   hi18n,"PFT_RM_I18N_CONSTANTS.status changed","status changed"))
 DECLARE i18n_authorization_service_date_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.service date","service date"))
 DECLARE i18n_skip_financial_encounter_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Encounter was bypassed during encounter modifications because it was in bad debt or history",
   "Encounter was bypassed during encounter modifications because it was in bad debt or history"))
 DECLARE i18n_reg_date_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Registration date changed","Registration date changed"))
 DECLARE i18n_facility_changed_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.This encounter was transferred","This encounter was transferred"))
 DECLARE i18n_facility_trans_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.The transfer","The transfer"))
 DECLARE i18n_facility_cancel_trans_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.was canceled for this encounter","was canceled for this encounter"))
 DECLARE i18n_profile_conversion_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Profile Conversion",
   "Encounter was converted to using profiles with additional changes necessitating billing to be reset."
   ))
 DECLARE i18n_unable_to_determine_guarantor = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Unable to determine guarantor","Unable to determine guarantor"))
 DECLARE i18n_unable_to_determine_enctype = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Unable to determine encounter type","Unable to determine encounter type"))
 DECLARE i18n_surcharge_reprocessing_evaluation_comment = vc WITH protect, constant(
  uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Non-primary surcharge exempt evaluations performed due to health plan modifications.",
   "Non-primary surcharge exempt evaluations performed due to health plan modifications."))
 DECLARE i18n_add_guar_resp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.A guarantor responsibility has been added",
   "A guarantor responsibility has been added"))
 DECLARE i18n_remove_guar_resp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.A guarantor responsibility has been removed",
   "A guarantor responsibility has been removed"))
 DECLARE i18n_change_guar_resp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.A guarantor responsibility has been changed",
   "A guarantor responsibility has been changed"))
 DECLARE i18n_guar_supr_corsp_timeline_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Guarantor Information Mismatch Present for Correspondence",
   "Guarantor Information Mismatch Present for Correspondence"))
 DECLARE i18n_guar_supr_corsp_hold = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
   "PFT_RM_I18N_CONSTANTS.Automatic Correspondence Suppression",
   "Automatic Correspondence Suppression"))
 DECLARE i18n_guar_supr_stmt_hold = vc WITH protect, constant(uar_i18ngetmessage(hi18n,build(
    "PFT_RM_I18N_CONSTANTS.Hold Applied on statement as the Guarantor details on statement does not match with",
    "Person Management Guarantor"),
   "Statement suppression hold applied due to mismatching guarantor information"))
 IF ( NOT (validate(i18n_guarmismatch)))
  DECLARE i18n_guarmismatch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RM_I18N_CONSTANTS.I18N_GUARMISMATCH",
    "The guarantor information does not match the guarantor entered during registration"))
 ENDIF
 IF ( NOT (validate(i18n_autostmtsuppression)))
  DECLARE i18n_autostmtsuppression = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RM_I18N_CONSTANTS.I18N_AUTOSTMTSUPPRESSION","Automatic Statement Suppression"))
 ENDIF
 CALL echo("End PFT_RM_I18N_CONSTANTS.INC")
 CALL echo("Begin PFT_RM_FAILURE_REPORTING_SUBS.INC, version [545118.006]")
 IF ( NOT (validate(cs29321_demmods_cd)))
  DECLARE cs29321_demmods_cd = f8 WITH protect, constant(getcodevalue(29321,"DEMOMODS",0))
 ENDIF
 IF ( NOT (validate(cs29322_cmbmod_cd)))
  DECLARE cs29322_cmbmod_cd = f8 WITH protect, constant(getcodevalue(29322,"COMBHPMODENC",0))
 ENDIF
 IF ( NOT (validate(cs29320_pftencntr_cd)))
  DECLARE cs29320_pftencntr_cd = f8 WITH protect, constant(getcodevalue(29320,"PFTENCNTR",0))
 ENDIF
 IF ( NOT (validate(cs4002267_suspchg_cd)))
  DECLARE cs4002267_suspchg_cd = f8 WITH protect, constant(getcodevalue(4002267,"SUSPENDCHRGS",0))
 ENDIF
 IF ( NOT (validate(cs4002267_lockerror_cd)))
  DECLARE cs4002267_lockerror_cd = f8 WITH protect, constant(getcodevalue(4002267,"LOCKERROR",0))
 ENDIF
 IF ( NOT (validate(cs4002267_norbillchrgs_cd)))
  DECLARE cs4002267_norbillchrgs_cd = f8 WITH protect, constant(getcodevalue(4002267,"NORBILLCHRGS",0
    ))
 ENDIF
 IF ( NOT (validate(cs4002267_norbillevent_cd)))
  DECLARE cs4002267_norbillevent_cd = f8 WITH protect, constant(getcodevalue(4002267,"NORBILLEVENT",0
    ))
 ENDIF
 IF ( NOT (validate(cs4002267_unknown_cd)))
  DECLARE cs4002267_unknown_cd = f8 WITH protect, constant(getcodevalue(4002267,"UNKNOWN",0))
 ENDIF
 IF ( NOT (validate(cs4002267_invalid_cob_cd)))
  DECLARE cs4002267_invalid_cob_cd = f8 WITH protect, constant(getcodevalue(4002267,"INVALIDCOB",0))
 ENDIF
 IF ( NOT (validate(cs4002267_encntr_in_hist_cd)))
  DECLARE cs4002267_encntr_in_hist_cd = f8 WITH protect, constant(getcodevalue(4002267,"ENCNTRINHIST",
    0))
 ENDIF
 IF ( NOT (validate(cs4002267_encntr_in_bd_cd)))
  DECLARE cs4002267_encntr_in_bd_cd = f8 WITH protect, constant(getcodevalue(4002267,"ENCNTRINBD",0))
 ENDIF
 IF ( NOT (validate(cs24450_pending_reg_mod_cd)))
  DECLARE cs24450_pending_reg_mod_cd = f8 WITH protect, constant(getcodevalue(24450,"PENDREGMOD",0))
 ENDIF
 IF ( NOT (validate(cs4002267_crshp835fail_cd)))
  DECLARE cs4002267_crshp835fail_cd = f8 WITH protect, constant(getcodevalue(4002267,"CRSHP835FAIL",0
    ))
 ENDIF
 IF ( NOT (validate(cs4002267_guarnotfound)))
  DECLARE cs4002267_guarnotfound = f8 WITH protect, constant(getcodevalue(4002267,"GUARNOTFOUND",0))
 ENDIF
 IF ( NOT (validate(cs4002267_enctypenotfound)))
  DECLARE cs4002267_enctypenotfound = f8 WITH protect, constant(getcodevalue(4002267,"ENCTYPENOTFD",0
    ))
 ENDIF
 IF (validate(queueencounterstoworkflow,char(128))=char(128))
  SUBROUTINE (queueencounterstoworkflow(idx=i4,pftencounters=vc(ref),pqii=f8(ref)) =i2)
    CALL logmessage("queueEncountersToWorkflow","Entering",log_debug)
    SET pqii = 0.0
    FREE RECORD wfrequest
    RECORD wfrequest(
      1 pft_queue_event_cd = f8
      1 entity[1]
        2 pft_entity_type_cd = f8
        2 entity_id = f8
        2 pft_entity_status_cd = f8
        2 item_status_cd = f8
    )
    FREE RECORD wfreply
    RECORD wfreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    CALL logmessage("queueEncountersToWorkflow",build("Queueing pft_encntr #",pftencounters->
      encounters[idx].pftencntrid),log_debug)
    SET wfrequest->pft_queue_event_cd = cs29322_cmbmod_cd
    SET wfrequest->entity[1].pft_entity_type_cd = cs29320_pftencntr_cd
    SET wfrequest->entity[1].entity_id = pftencounters->encounters[idx].pftencntrid
    SET wfrequest->entity[1].pft_entity_status_cd = cs29321_demmods_cd
    SET wfrequest->entity[1].item_status_cd = pftencounters->encounters[idx].failurereasoncd
    EXECUTE pft_wf_publish_queue_event  WITH replace("REQUEST",wfrequest), replace("REPLY",wfreply)
    IF ((wfreply->status_data.status != "S"))
     CALL addtracemessage("queueEncountersToWorkflow",
      "pft_wf_publish_queue_event did not return success")
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM pft_queue_item pqi
     WHERE (pqi.pft_encntr_id=pftencounters->encounters[idx].pftencntrid)
      AND pqi.active_ind=true
      AND (pqi.item_status_cd=pftencounters->encounters[idx].failurereasoncd)
     DETAIL
      pqii = pqi.pft_queue_item_id
     WITH nocounter
    ;end select
    IF (curqual != 1)
     CALL addtracemessage("queueEncountersToWorkflow",
      "pft_wf_publish_queue_event did not return success")
     RETURN(false)
    ENDIF
    CALL logmessage("queueEncountersToWorkflow","Exiting",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(reportsuspendedcharges,char(128))=char(128))
  DECLARE reportsuspendedcharges(idx=i4,pftencounters=vc(ref)) = i2
  SUBROUTINE reportsuspendedcharges(idx,pftencounters,pqii)
    CALL logmessage(build("reportSuspendedCharges:",pqii),"Entering",log_debug)
    FREE RECORD longblobrequest
    RECORD longblobrequest(
      1 objarray[*]
        2 parent_entity_name = vc
        2 parent_entity_id = f8
        2 long_blob = vc
        2 active_ind = i2
        2 active_status_cd = f8
    )
    FREE RECORD longblobreply
    RECORD longblobreply(
      1 qual_cnt = i4
      1 qual[*]
        2 long_blob_id = f8
        2 status = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
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
    )
    SET stat = alterlist(longblobrequest->objarray,1)
    SET longblobrequest->objarray[1].parent_entity_name = "PFT_QUEUE_ITEM"
    SET longblobrequest->objarray[1].parent_entity_id = pqii
    SET longblobrequest->objarray[1].long_blob = pftencounters->encounters[idx].xmlchargelist
    SET longblobrequest->objarray[1].active_ind = true
    SET longblobrequest->objarray[1].active_status_cd = reqdata->active_status_cd
    EXECUTE pft_da_add_long_blob  WITH replace("REQUEST",longblobrequest), replace("REPLY",
     longblobreply)
    IF ((longblobreply->status_data.status != "S"))
     CALL addtracemessage("reportSuspendedCharges","pft_add_long_blob did not return success")
     RETURN(false)
    ENDIF
    CALL logmessage("reportSuspendedCharges","Exiting",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(getpftencntrfailures,char(128))=char(128))
  SUBROUTINE (getpftencntrfailures(details=vc(ref),pftencounters=vc(ref)) =i2)
    CALL logmessage("getPftEncntrFailures","Entering",log_debug)
    DECLARE pecnt = i4 WITH protect, noconstant(0)
    DECLARE paramidx = i4 WITH protect, noconstant(0)
    CALL echorecord(details)
    IF (size(details->status_detail.details,5) > 0)
     SELECT INTO "nl:"
      entityid = details->status_detail.details[d1.seq].entityid
      FROM (dummyt d1  WITH seq = size(details->status_detail.details,5)),
       pft_charge pc
      PLAN (d1
       WHERE (details->status_detail.details[d1.seq].detailflag=status_detail_suspended_charges))
       JOIN (pc
       WHERE (pc.charge_item_id=details->status_detail.details[d1.seq].entityid)
        AND pc.active_ind=true)
      ORDER BY pc.pft_encntr_id, entityid
      HEAD pc.pft_encntr_id
       pecnt += 1, stat = alterlist(pftencounters->encounters,pecnt), pftencounters->encounters[pecnt
       ].pftencntrid = pc.pft_encntr_id,
       pftencounters->encounters[pecnt].failurereasoncd = cs4002267_suspchg_cd, pftencounters->
       encounters[pecnt].xmlchargelist = begindocument(pftencounters->encounters[pecnt].xmlchargelist,
        "iso-8859-1"), pftencounters->encounters[pecnt].xmlchargelist = beginelement(pftencounters->
        encounters[pecnt].xmlchargelist,"charges")
      DETAIL
       pftencounters->encounters[pecnt].xmlchargelist = beginelementname(pftencounters->encounters[
        pecnt].xmlchargelist,"charge"), pftencounters->encounters[pecnt].xmlchargelist =
       writeattribute(pftencounters->encounters[pecnt].xmlchargelist,"chargeItemId",cnvtstring(
         entityid)), pftencounters->encounters[pecnt].xmlchargelist = endelementname(pftencounters->
        encounters[pecnt].xmlchargelist),
       pftencounters->encounters[pecnt].xmlchargelist = writeelement(pftencounters->encounters[pecnt]
        .xmlchargelist,"pftEncntrId",cnvtstring(pc.pft_encntr_id))
       FOR (paramidx = 1 TO size(details->details[d1.seq].parameters,5))
         IF ((details->details[d1.seq].parameters[paramidx].paramname="CHARGE_TYPE_CD"))
          pftencounters->encounters[pecnt].xmlchargelist = writeelement(pftencounters->encounters[
           pecnt].xmlchargelist,"chargeTypeCd",details->details[d1.seq].parameters[paramidx].
           paramvalue)
         ENDIF
         IF ((details->details[d1.seq].parameters[paramidx].paramname="SUSPENSE_REASON_CD"))
          pftencounters->encounters[pecnt].xmlchargelist = writeelement(pftencounters->encounters[
           pecnt].xmlchargelist,"suspenseReasonCd",details->details[d1.seq].parameters[paramidx].
           paramvalue)
         ENDIF
         IF ((details->details[d1.seq].parameters[paramidx].paramname="UNKNOWN_REASON"))
          pftencounters->encounters[pecnt].xmlchargelist = writeelement(pftencounters->encounters[
           pecnt].xmlchargelist,"unknownSuspenseReasonDesc",details->details[d1.seq].parameters[
           paramidx].paramvalue)
         ENDIF
       ENDFOR
       pftencounters->encounters[pecnt].xmlchargelist = endelement(pftencounters->encounters[pecnt].
        xmlchargelist,"charge")
      FOOT  pc.pft_encntr_id
       pftencounters->encounters[pecnt].xmlchargelist = endelement(pftencounters->encounters[pecnt].
        xmlchargelist,"charges")
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      entityid = details->status_detail.details[d1.seq].entityid
      FROM (dummyt d1  WITH seq = size(details->status_detail.details,5))
      PLAN (d1
       WHERE (details->status_detail.details[d1.seq].detailflag != status_detail_suspended_charges))
      DETAIL
       pecnt += 1, stat = alterlist(pftencounters->encounters,pecnt), pftencounters->encounters[pecnt
       ].pftencntrid = entityid
       IF ((details->status_detail.details[d1.seq].detailmessage IN (i18n_encntr_not_locked_comment,
       i18n_em_failed_to_lock_error_message)))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_lockerror_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailmessage=i18n_invalid_cob_comment))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_invalid_cob_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailmessage=i18n_encntr_in_history_comment))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_encntr_in_hist_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailmessage=i18n_encntr_in_bad_debt_comment)
       )
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_encntr_in_bd_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailmessage=i18n_skip_rebill_chrg_comment))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_norbillchrgs_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailmessage=i18n_skip_rebill_event_comment))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_norbillevent_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailflag=
       status_detail_hp_add_fail_835_posting))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_crshp835fail_cd
       ELSEIF ((details->status_detail.details[d1.seq].detailflag=status_detail_guarantor_error))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_guarnotfound
       ELSEIF ((details->status_detail.details[d1.seq].detailflag=status_detail_enctype_error))
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_enctypenotfound
       ELSE
        pftencounters->encounters[pecnt].failurereasoncd = cs4002267_unknown_cd
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    CALL echorecord(pftencounters)
    CALL logmessage("getPftEncntrFailures","Exiting",log_debug)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(removeoldchargefailurereporting,char(128))=char(128))
  SUBROUTINE (removeoldchargefailurereporting(idx=i4,pftencounters=vc(ref)) =i2)
    CALL logmessage("removeOldChargeFailureReporting","Entering",log_debug)
    DECLARE pqicnt = i4 WITH protect, noconstant(0)
    DECLARE blobcnt = i4 WITH protect, noconstant(0)
    FREE RECORD dequeueitems
    RECORD dequeueitems(
      1 pft_queue_item_qual = i2
      1 pft_queue_item[*]
        2 pft_queue_item_id = f8
    )
    FREE RECORD dequeuereply
    RECORD dequeuereply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    FREE RECORD removeblobrequest
    RECORD removeblobrequest(
      1 call_echo_ind = i2
      1 qual[*]
        2 long_blob_id = f8
        2 updt_cnt = i4
        2 allow_partial_ind = i2
        2 force_updt_ind = i2
    )
    FREE RECORD blobreply
    RECORD blobreply(
      1 qual_cnt = i4
      1 qual[*]
        2 status = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SELECT INTO "nl:"
     FROM pft_queue_item pqi
     WHERE (pqi.pft_encntr_id=pftencounters->encounters[idx].pftencntrid)
      AND pqi.active_ind=true
      AND pqi.pft_entity_status_cd=cs29321_demmods_cd
      AND pqi.item_status_cd=cs4002267_suspchg_cd
     ORDER BY pqi.pft_queue_item_id
     HEAD pqi.pft_queue_item_id
      pqicnt += 1, stat = alterlist(dequeueitems->pft_queue_item,pqicnt), dequeueitems->
      pft_queue_item[pqicnt].pft_queue_item_id = pqi.pft_queue_item_id
     WITH nocounter
    ;end select
    SET dequeueitems->pft_queue_item_qual = size(dequeueitems->pft_queue_item,5)
    IF (size(dequeueitems->pft_queue_item,5) > 0)
     EXECUTE pft_del_queue_item  WITH replace("REQUEST",dequeueitems), replace("REPLY",dequeuereply)
     IF ((dequeuereply->status_data.status="F"))
      CALL addtracemessage("removeOldChargeFailureReporting",
       "pft_del_queue_item did not return success")
      RETURN(false)
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = size(dequeueitems->pft_queue_item,5)),
       long_blob lb
      PLAN (d1)
       JOIN (lb
       WHERE (lb.parent_entity_id=dequeueitems->pft_queue_item[d1.seq].pft_queue_item_id)
        AND lb.parent_entity_name="PFT_QUEUE_ITEM")
      DETAIL
       blobcnt += 1, stat = alterlist(removeblobrequest->qual,blobcnt), removeblobrequest->qual[
       blobcnt].long_blob_id = lb.long_blob_id
      WITH nocounter
     ;end select
     IF (size(removeblobrequest->qual,5) > 0)
      EXECUTE pft_del_long_blob  WITH replace("REQUEST",removeblobrequest), replace("REPLY",blobreply
       )
      IF ((blobreply->status_data.status="F"))
       CALL addtracemessage("removeOldChargeFailureReporting",
        "pft_del_long_blob did not return success")
       RETURN(false)
      ENDIF
     ENDIF
    ENDIF
    CALL logmessage("removeOldChargeFailureReporting","Exiting",log_debug)
    FREE RECORD dequeueitems
    FREE RECORD dequeuereply
    FREE RECORD removeblobrequest
    FREE RECORD blobreply
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(savefailurereasondescription,char(128))=char(128))
  SUBROUTINE (savefailurereasondescription(encounterid=f8,failurereasondesc=vc) =i2)
    DECLARE addcnt = i4 WITH protect, noconstant(0)
    DECLARE uptcnt = i4 WITH protect, noconstant(0)
    FREE RECORD addlongtextrequest
    RECORD addlongtextrequest(
      1 objarray[*]
        2 parent_entity_name = vc
        2 parent_entity_id = f8
        2 long_text = vc
    )
    FREE RECORD addlongtextreply
    RECORD addlongtextreply(
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
    )
    FREE RECORD uptlongtextrequest
    RECORD uptlongtextrequest(
      1 objarray[*]
        2 long_text_id = f8
        2 long_text = vc
        2 updt_cnt = i4
    )
    SELECT INTO "nl:"
     FROM pft_encntr pe,
      pe_status_reason psr,
      long_text lt
     PLAN (pe
      WHERE pe.encntr_id=encounterid
       AND pe.active_ind=true)
      JOIN (psr
      WHERE psr.pft_encntr_id=pe.pft_encntr_id
       AND psr.pe_status_reason_cd=cs24450_pending_reg_mod_cd
       AND psr.active_ind=true)
      JOIN (lt
      WHERE (lt.parent_entity_id= Outerjoin(psr.pe_status_reason_id))
       AND (lt.parent_entity_name= Outerjoin("PE_STATUS_REASON"))
       AND (lt.active_ind= Outerjoin(true)) )
     HEAD psr.pe_status_reason_id
      IF (lt.long_text_id > 0)
       uptcnt += 1, stat = alterlist(uptlongtextrequest->objarray,uptcnt), uptlongtextrequest->
       objarray[uptcnt].long_text_id = lt.long_text_id,
       uptlongtextrequest->objarray[uptcnt].long_text = failurereasondesc, uptlongtextrequest->
       objarray[uptcnt].updt_cnt = (lt.updt_cnt+ 1)
      ELSE
       addcnt += 1, stat = alterlist(addlongtextrequest->objarray,addcnt), addlongtextrequest->
       objarray[addcnt].parent_entity_name = "PE_STATUS_REASON",
       addlongtextrequest->objarray[addcnt].parent_entity_id = psr.pe_status_reason_id,
       addlongtextrequest->objarray[addcnt].long_text = failurereasondesc
      ENDIF
     WITH nocounter
    ;end select
    IF (size(addlongtextrequest->objarray,5) > 0)
     CALL echorecord(addlongtextrequest)
     EXECUTE pft_da_add_long_text  WITH replace("REQUEST",addlongtextrequest), replace("REPLY",
      addlongtextreply)
     IF ((addlongtextreply->status_data.status != "S"))
      CALL addtracemessage("saveFailureReasonDescription",
       "pft_da_upt_long_text did not return success")
      CALL echorecord(addlongtextrequest)
      CALL echorecord(addlongtextreply)
      RETURN(false)
     ENDIF
    ENDIF
    IF (size(uptlongtextrequest->objarray,5) > 0)
     UPDATE  FROM long_text lt,
       (dummyt d  WITH seq = value(size(uptlongtextrequest->objarray,5)))
      SET lt.long_text = uptlongtextrequest->objarray[d.seq].long_text, lt.updt_cnt =
       uptlongtextrequest->objarray[d.seq].updt_cnt, lt.updt_dt_tm = cnvtdatetime(sysdate),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx
      PLAN (d)
       JOIN (lt
       WHERE (lt.long_text_id=uptlongtextrequest->objarray[d.seq].long_text_id))
     ;end update
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
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
 IF (validate(notifyprofitforregmodforencounter,char(128))=char(128))
  SUBROUTINE (notifyprofitforregmodforencounter(encntrid=f8,pmdata=vc(ref)) =i2)
    DECLARE encntrcnt = i4 WITH protect, noconstant(0)
    DECLARE ephcdvalue = f8 WITH protect, noconstant(0.0)
    FREE RECORD holdsrequest
    RECORD holdsrequest(
      1 objarray[*]
        2 pft_encntr_id = f8
        2 pe_status_reason_cd = f8
        2 reason_comment = vc
        2 reapply_ind = i4
    )
    FREE RECORD holdsreply
    RECORD holdsreply(
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
    )
    IF (((checkprg("PFT_RM_PROCESS_REG_MODS")=0) OR (checkprg("PFT_APPLY_BILL_HOLD_SUSPENSION")=0)) )
     RETURN(false)
    ENDIF
    SET stat = uar_get_meaning_by_codeset(24450,"PENDREGMOD",1,ephcdvalue)
    IF (ephcdvalue <= 0.0)
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe
     PLAN (e
      WHERE e.encntr_id=encntrid)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true
       AND  NOT ( EXISTS (
      (SELECT
       psr.pe_status_reason_cd
       FROM pe_status_reason psr
       WHERE psr.pft_encntr_id=pe.pft_encntr_id
        AND psr.pe_status_reason_cd=ephcdvalue
        AND psr.active_ind=true))))
     ORDER BY pe.pft_encntr_id
     HEAD pe.pft_encntr_id
      encntrcnt += 1, stat = alterlist(holdsrequest->objarray,encntrcnt), holdsrequest->objarray[
      encntrcnt].pft_encntr_id = pe.pft_encntr_id,
      holdsrequest->objarray[encntrcnt].pe_status_reason_cd = ephcdvalue, holdsrequest->objarray[
      encntrcnt].reapply_ind = true
     WITH nocounter
    ;end select
    IF (size(holdsrequest->objarray,5) > 0)
     EXECUTE pft_apply_bill_hold_suspension  WITH replace("REQUEST",holdsrequest), replace("REPLY",
      holdsreply)
     IF ((holdsreply->status_data.status != "S"))
      RETURN(false)
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
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
 CALL beginservice(afc_encntr_mods)
 IF ( NOT (validate(cs29321_demmods_cd)))
  DECLARE cs29321_demmods_cd = f8 WITH protect, constant(getcodevalue(29321,"DEMOMODS",0))
 ENDIF
 IF ( NOT (validate(cs29322_cmbmod_cd)))
  DECLARE cs29322_cmbmod_cd = f8 WITH protect, constant(getcodevalue(29322,"COMBHPMODENC",0))
 ENDIF
 IF ( NOT (validate(cs29320_pftencntr_cd)))
  DECLARE cs29320_pftencntr_cd = f8 WITH protect, constant(getcodevalue(29320,"PFTENCNTR",0))
 ENDIF
 IF ( NOT (validate(cs4002267_suspchg_cd)))
  DECLARE cs4002267_suspchg_cd = f8 WITH protect, constant(getcodevalue(4002267,"SUSPENDCHRGS",0))
 ENDIF
 IF ( NOT (validate(cs4002267_lockerror_cd)))
  DECLARE cs4002267_lockerror_cd = f8 WITH protect, constant(getcodevalue(4002267,"LOCKERROR",0))
 ENDIF
 IF ( NOT (validate(cs4002267_unknown_cd)))
  DECLARE cs4002267_unknown_cd = f8 WITH protect, constant(getcodevalue(4002267,"UNKNOWN",0))
 ENDIF
 IF ( NOT (validate(cs355_userdefined_cd)))
  DECLARE cs355_userdefined_cd = f8 WITH protect, constant(getcodevalue(355,"USERDEFINED",1))
 ENDIF
 IF ( NOT (validate(cs356_skipregmods_cd)))
  DECLARE cs356_skipregmods_cd = f8 WITH protect, constant(getcodevalue(356,"SKIPREGMODS",1))
 ENDIF
 IF ( NOT (validate(cs207902_notifyprofit_cd)))
  DECLARE cs207902_notifyprofit_cd = f8 WITH protect, constant(getcodevalue(207902,"NOTIFYPROFIT",1))
 ENDIF
 IF ( NOT (validate(cs48_deleted_cd)))
  DECLARE cs48_deleted_cd = f8 WITH protect, constant(getcodevalue(48,"DELETED",1))
 ENDIF
 IF ( NOT (validate(cs261_cancelled_cd)))
  DECLARE cs261_cancelled_cd = f8 WITH protect, constant(getcodevalue(261,"CANCELLED",1))
 ENDIF
 DECLARE encounter = vc WITH protect, constant("ENCOUNTER")
 DECLARE pft_rm_process_wtp = vc WITH protect, constant("PFT_RM_PROCESS_WTP")
 DECLARE omitrebillind = i2 WITH protect, noconstant(false)
 DECLARE pftencntrid = f8 WITH protect, noconstant(0.0)
 IF ((request->o_encntr_id < 1.0))
  CALL exitservicesuccess("0.0 old encounter id passed in.")
  GO TO exit_script
 ENDIF
 IF ( NOT (setlogicaldomaincontext(request->o_encntr_id)))
  CALL logmessage("afc_encntr_mods","Failed to set the logical domain context",log_info)
  SET reqinfo->commit_ind = false
  GO TO exit_script
 ENDIF
 SET omitrebillind = getomitrebillindicator(request->o_encntr_id)
 IF (isencountercancelled(request->o_encntr_id))
  SET cancelencounterrequest->encntr_id = request->o_encntr_id
  EXECUTE pft_rm_process_reg_cancel  WITH replace("REQUEST",cancelencounterrequest), replace("REPLY",
   cancelencounterreply)
  IF ((cancelencounterreply->status_data.status="F"))
   CALL exitservicefailure("Failed to execute pft_rm_process_reg_cancel",go_to_exit_script)
  ELSE
   CALL exitservicesuccess("Successfully executed pft_rm_process_reg_cancel")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (ispatientaccountingclient(request->o_encntr_id))
  SET wtptaskrequest->o_encntr_id = request->o_encntr_id
  SET wtptaskrequest->omitrebillind = omitrebillind
  SET wtptaskrequest->apply_self_pay_ind = request->apply_self_pay_ind
  IF (validate(request->add_crossover_hp_ind,0)=1)
   SET wtptaskrequest->add_crossover_hp_ind = request->add_crossover_hp_ind
  ENDIF
  SELECT INTO "nl:"
   FROM pm_transaction pt
   PLAN (pt
    WHERE (pt.transaction_id=request->transaction_id)
     AND (pt.n_encntr_id=request->o_encntr_id)
     AND pt.transaction != "CMB"
     AND pt.activity_dt_tm <= cnvtdatetime(sysdate))
   ORDER BY pt.activity_dt_tm DESC
   HEAD REPORT
    wtptaskrequest->transaction = pt.transaction, wtptaskrequest->o_encntr_type_cd = pt
    .o_encntr_type_cd, wtptaskrequest->n_encntr_type_cd = pt.n_encntr_type_cd,
    wtptaskrequest->o_encntr_type_class_cd = pt.o_encntr_type_class_cd, wtptaskrequest->
    n_encntr_type_class_cd = pt.n_encntr_type_class_cd, wtptaskrequest->o_fin_class_cd = pt
    .o_fin_class_cd,
    wtptaskrequest->n_fin_class_cd = pt.n_fin_class_cd, wtptaskrequest->o_loc_nurse_unit_cd = pt
    .o_loc_nurse_unit_cd, wtptaskrequest->n_loc_nurse_unit_cd = pt.n_loc_nurse_unit_cd,
    wtptaskrequest->o_disch_dt_tm = pt.o_disch_dt_tm, wtptaskrequest->n_disch_dt_tm = pt
    .n_disch_dt_tm, wtptaskrequest->o_loc_facility_cd = pt.o_loc_facility_cd,
    wtptaskrequest->n_loc_facility_cd = pt.n_loc_facility_cd
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET addtaskqueuerequest->taskident = pft_rm_process_wtp
   SET addtaskqueuerequest->entityname = encounter
   SET addtaskqueuerequest->entityid = request->o_encntr_id
   SET addtaskqueuerequest->requestjson = cnvtrectojson(wtptaskrequest)
   IF (validate(request->apply_self_pay_ind,0)=1)
    SET addtaskqueuerequest->processdttm = cnvtlookahead("1,H")
   ELSE
    SET addtaskqueuerequest->processdttm = cnvtdatetime(sysdate)
   ENDIF
   EXECUTE wtp_workflow_task_save  WITH replace("REQUEST",addtaskqueuerequest), replace("REPLY",
    addtaskqueuereply)
   IF ((addtaskqueuereply->status_data.status != "S"))
    CALL exitservicefailure("Failed to execute wtp_workflow_task_save",go_to_exit_script)
   ENDIF
   IF (validate(request->n_encntr_id,0.0) > 0.0)
    SET integritycheckreq->transaction_id = request->transaction_id
    SET integritycheckreq->n_encntr_id = request->n_encntr_id
    EXECUTE pft_reg_integrity_check  WITH replace("REQUEST",integritycheckreq), replace("REPLY",
     integritycheckrep)
    IF ((integritycheckrep->status_data.status != "S"))
     CALL logmessage("afc_encntr_mods",build2("Integrity check for encntr_id ",build(request->
        n_encntr_id)," failed."),log_warning)
    ENDIF
   ENDIF
  ENDIF
 ELSE
  IF (isuserdefinedpreferenceforregistrationmodificationset(request->o_encntr_id))
   CALL exitservicesuccess(
    "Encounter user defined field has prevented this encounter from being processed")
  ENDIF
  DECLARE failurereasondescription = vc WITH protect, noconstant("")
  RECORD statusdetails(
    1 status_detail
      2 details[*]
        3 entityid = f8
        3 detailflag = i4
        3 detailmessage = vc
        3 parameters[*]
          4 paramname = vc
          4 paramvalue = vc
  ) WITH protect
  RECORD failuremessagesforreport(
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
  ) WITH protect
  RECORD afcrmrequest(
    1 encounterid = f8
    1 omitrebillind = i2
  ) WITH protect
  RECORD afcrmreply(
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
    1 status_detail
      2 details[*]
        3 entityid = f8
        3 detailflag = i4
        3 detailmessage = vc
        3 parameters[*]
          4 paramname = vc
          4 paramvalue = vc
  ) WITH protect
  SET afcrmrequest->encounterid = request->o_encntr_id
  SET afcrmrequest->omitrebillind = omitrebillind
  EXECUTE afc_rm_process_reg_mods  WITH replace("REQUEST",afcrmrequest), replace("REPLY",afcrmreply)
  IF ((afcrmreply->status_data.status != "S"))
   CALL logmessage("afc_encntr_mods","afc_rm_process_reg_mods did not return success",log_error)
   ROLLBACK
   IF (validate(request->add_crossover_hp_ind,0)=1)
    SELECT INTO "nl:"
     FROM pft_encntr pe
     WHERE (pe.encntr_id=request->o_encntr_id)
      AND pe.active_ind=true
     DETAIL
      pftencntrid = pe.pft_encntr_id
     WITH nocounter, maxrec = 1
    ;end select
    IF (validate(afcrmreply->status_detail))
     SET stat = alterlist(afcrmreply->status_detail.details,1)
     SET afcrmreply->status_detail.details[1].entityid = pftencntrid
     SET afcrmreply->status_detail.details[1].detailflag = status_detail_hp_add_fail_835_posting
     SET afcrmreply->status_detail.details[1].detailmessage = nullterm(
      i18n_cross_hp_fail_835_posting_comment)
    ENDIF
    IF (notifyprofitforregmodforencounter(request->encntr_id,request) != true)
     CALL logmessage("afc_encntr_mods","failed to add the pending reg mod hold",log_error)
    ENDIF
   ENDIF
   CALL copystatusdetails(afcrmreply,statusdetails)
   CALL copytracemessages(afcrmreply,failuremessagesforreport)
   DECLARE pftencntridx = i4 WITH protect, noconstant(0)
   DECLARE queueid = f8 WITH protect, noconstant(0.0)
   RECORD pftencntrs(
     1 encounters[*]
       2 failurereasoncd = f8
       2 pftencntrid = f8
       2 pftqueueitemid = f8
       2 parententityname = vc
       2 xmlchargelist = vc
   ) WITH protect
   IF ( NOT (getpftencntrfailures(statusdetails,pftencntrs)))
    CALL exitservicefailure("getEncounterFailures did not return success",go_to_exit_script)
   ENDIF
   FOR (pftencntridx = 1 TO size(pftencntrs->encounters,5))
     IF ( NOT (removeoldchargefailurereporting(pftencntridx,pftencntrs)))
      CALL exitservicefailure("removeOldChargeFailureReporting did not return success",
       go_to_exit_script)
     ENDIF
     IF ((pftencntrs->encounters[pftencntridx].pftencntrid > 0))
      IF ( NOT (queueencounterstoworkflow(pftencntridx,pftencntrs,queueid)))
       CALL exitservicefailure("queueEncountersToWorkflow did not return success",go_to_exit_script)
      ENDIF
     ENDIF
     IF ((pftencntrs->encounters[pftencntridx].failurereasoncd=cs4002267_suspchg_cd))
      IF ( NOT (reportsuspendedcharges(pftencntridx,pftencntrs,queueid)))
       CALL exitservicefailure("reportSuspendedCharges did not return success",go_to_exit_script)
      ENDIF
     ENDIF
   ENDFOR
   IF (size(statusdetails->status_detail.details,5) > 0)
    SET failurereasondescription = statusdetails->status_detail.details[1].detailmessage
   ELSE
    FOR (failurecnt = 1 TO size(failuremessagesforreport->failure_stack.failures,5))
      SET failurereasondescription = build2(failurereasondescription,"*PRG:",failuremessagesforreport
       ->failure_stack.failures[failurecnt].programname,"*SUB:",failuremessagesforreport->
       failure_stack.failures[failurecnt].routinename,
       "*MSG:",failuremessagesforreport->failure_stack.failures[failurecnt].message)
    ENDFOR
   ENDIF
   IF ( NOT (savefailurereasondescription(request->o_encntr_id,failurereasondescription)))
    CALL exitservicefailure("saveFailureReasonDescription did not return success",go_to_exit_script)
   ENDIF
   CALL logmessage("afc_encntr_mods","Exiting due to failure.  Please review work queues.",log_debug)
  ENDIF
  SET reqinfo->commit_ind = true
 ENDIF
#exit_script
 SUBROUTINE (isuserdefinedpreferenceforregistrationmodificationset(encounterid=f8) =i2)
   DECLARE preferenceind = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM encntr_info ei,
     code_value cv
    PLAN (ei
     WHERE ei.encntr_id=encounterid
      AND ei.info_type_cd=cs355_userdefined_cd
      AND ei.info_sub_type_cd=cs356_skipregmods_cd)
     JOIN (cv
     WHERE cv.code_value=ei.value_cd)
    HEAD REPORT
     IF (uar_get_code_meaning(ei.value_cd)="YES")
      preferenceind = true
     ENDIF
    WITH nocounter
   ;end select
   RETURN(preferenceind)
 END ;Subroutine
 SUBROUTINE (setlogicaldomaincontext(encounterid=f8) =i2)
   DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM encounter e,
     person p
    PLAN (e
     WHERE e.encntr_id=encounterid)
     JOIN (p
     WHERE p.person_id=e.person_id)
    DETAIL
     logicaldomainid = p.logical_domain_id
    WITH nocounter
   ;end select
   IF ( NOT (setlogicaldomain(logicaldomainid)))
    CALL logmessage("setLogicalDomainContext","Unable to set logical domain context",log_error)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (getomitrebillindicator(encounterid=f8) =i2)
   DECLARE omitrebillselection = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pm_hist_tracking p
    PLAN (p
     WHERE p.encntr_id=encounterid)
    ORDER BY p.encntr_id, p.transaction_dt_tm DESC
    HEAD p.encntr_id
     omitrebillselection = p.omit_rebill_ind
    WITH nocounter
   ;end select
   RETURN(omitrebillselection)
 END ;Subroutine
 SUBROUTINE (isencountercancelled(encounterid=f8) =i2)
   SELECT INTO "nl:"
    FROM encounter e,
     pft_encntr pe
    PLAN (e
     WHERE e.encntr_id=encounterid
      AND e.active_ind=false
      AND e.active_status_cd=cs48_deleted_cd
      AND e.encntr_status_cd=cs261_cancelled_cd
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate))
     JOIN (pe
     WHERE pe.encntr_id=e.encntr_id
      AND pe.active_ind=true
      AND pe.balance <= 0.009
      AND pe.charge_balance <= 0.009
      AND pe.adjustment_balance <= 0.009
      AND pe.applied_payment_balance <= 0.009
      AND (pe.applied_payment_balance >= - (0.009)))
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (ispatientaccountingclient(encounterid=f8) =i2)
   DECLARE iscpaclient = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM encounter e,
     location l,
     be_org_reltn bor,
     billing_entity be,
     be_at_reltn bar,
     acct_template at
    PLAN (e
     WHERE e.encntr_id=encounterid
      AND e.active_ind=true)
     JOIN (l
     WHERE l.location_cd=e.loc_facility_cd
      AND l.active_ind=true)
     JOIN (bor
     WHERE bor.organization_id=l.organization_id
      AND bor.active_ind=true)
     JOIN (be
     WHERE be.billing_entity_id=bor.billing_entity_id
      AND be.active_ind=true)
     JOIN (bar
     WHERE bar.billing_entity_id IN (be.billing_entity_id, be.parent_be_id)
      AND bar.active_ind=true)
     JOIN (at
     WHERE at.acct_templ_id=bar.acct_templ_id
      AND at.active_ind=true
      AND at.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND at.end_effective_dt_tm >= cnvtdatetime(sysdate))
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     iscpaclient = true
    WITH nocounter
   ;end select
   RETURN(iscpaclient)
 END ;Subroutine
END GO
