CREATE PROGRAM afc_rca_get_batches_for_prsnl:dba
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
 IF ( NOT (validate(pft_rca_task_authorization_version)))
  DECLARE pft_rca_task_authorization_version = vc WITH constant("690935.116")
 ENDIF
 CALL echo("Begin PFT_RCA_TASK_DISPLAY_NAMES.INC, version [691405.068]")
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
 IF ( NOT (validate(_hi18n)))
  DECLARE _hi18n = i4 WITH protect, noconstant(0)
 ENDIF
 SET stat = uar_i18nlocalizationinit(_hi18n,curprog,"",curcclrev)
 DECLARE i18n_reg = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Reg:","Reg:"))
 DECLARE i18n_task_associate_balance_for_billing = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Associate Balance For Billing","Associate Balance For Billing")
  )
 DECLARE i18n_task_addbillinghold = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Add Billing Hold","Add Billing Hold"))
 DECLARE i18n_task_addimage = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Add Image","Add Image"))
 DECLARE i18n_task_addratecode = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Add Rate Code","Add Rate Code"))
 DECLARE i18n_task_applyadjustment = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Apply Adjustment","Apply Adjustment"))
 DECLARE i18n_task_applyactioncode = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Apply Action Code","Apply Action Code"))
 DECLARE i18n_task_applycomment = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Apply Comment","Apply Comment"))
 DECLARE i18n_task_apply_remark = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Apply Remark","Apply Remark"))
 DECLARE i18n_task_applyrefund = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Apply Refund","Apply Refund"))
 DECLARE i18n_task_applyselfpayremittance = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Apply Self Pay Remittance","Apply Self Pay Remittance"))
 DECLARE i18n_task_createaprefund = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Create AP Refund","Create AP Refund"))
 DECLARE i18n_task_assigntobankruptcy = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Assign to Bankruptcy","Assign to Bankruptcy"))
 DECLARE i18n_task_billlatecharges = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Bill Late Charges","Bill Late Charges"))
 DECLARE i18n_task_bill_as_professional = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Bill as Professional","Bill as Professional"))
 DECLARE i18n_task_bill_as_institutional = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Bill as Institutional","Bill as Institutional"))
 DECLARE i18n_task_cancelaprefund = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Cancel Refund","Cancel Refund"))
 DECLARE i18n_task_cancelclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Cancel Claim","Cancel Claim"))
 DECLARE i18n_task_replaceclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Replace Claim","Replace Claim"))
 DECLARE i18n_task_cancelcorrespondence = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Cancel Correspondence","Cancel Correspondence"))
 DECLARE i18n_task_cancelremittancetask = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Cancel Remittance","Cancel Remittance"))
 DECLARE i18n_task_complete_insurance_balance = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Complete","Complete"))
 DECLARE i18n_task_correspondence = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Generate Correspondence","Generate Correspondence"))
 DECLARE i18n_task_creditcharge = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Credit","Credit"))
 DECLARE i18n_task_deleteimage = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Delete Image","Delete Image"))
 DECLARE i18n_task_denyclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Deny Claim","Deny Claim"))
 DECLARE i18n_task_disable_eob = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Disable","Disable"))
 DECLARE i18n_task_encountercombine = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Financial Combine","Financial Combine"))
 DECLARE i18n_task_encounteruncombine = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Financial Uncombine","Financial Uncombine"))
 DECLARE i18n_task_estimatepatientliability = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Estimate Patient Liability","Estimate Patient Liability"))
 DECLARE i18n_task_generate_adjustment_interim_claim = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Generate  Adjustment Interim Claim",
   "Generate  Adjustment Interim Claim"))
 DECLARE i18n_task_generate_continuing_interim_claim = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Generate Continuing Interim Claim",
   "Generate Continuing Interim Claim"))
 DECLARE i18n_task_generate_final_interim_claim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Generate Final Interim Claim","Generate Final Interim Claim"))
 DECLARE i18n_task_generate_initial_interim_claim = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Generate Initial Interim Claim",
   "Generate Initial Interim Claim"))
 DECLARE i18n_task_mark_as_transmitted = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Mark As Transmitted","Mark as Transmitted"))
 DECLARE i18n_task_generate_inquiry_letter = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Generate Inquiry Letter","Generate Inquiry Letter"))
 DECLARE i18n_task_generateclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Generate Claim","Generate Claim"))
 DECLARE i18n_task_generateondemandstatement = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Generate Statement","Generate Statement"))
 DECLARE i18n_task_identifyissue = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Identify Work Item","Identify Work Item"))
 DECLARE i18n_task_lockchargebatch = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Lock Charge Batch","Lock Charge Batch"))
 DECLARE i18n_task_manageimages = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Manage Images","Manage Images"))
 DECLARE i18n_task_manualrelease = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Manual Release","Manual Release"))
 DECLARE i18n_task_modifyaprefund = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify Refund","Modify Refund"))
 DECLARE i18n_task_modifyformalpaymentplan = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Formal Payment Plan","Formal Payment Plan"))
 DECLARE i18n_task_modifychargegroup = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify Charge Group","Modify Charge Group"))
 DECLARE i18n_task_modifyglalias = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.General Ledger Entries","General Ledger Entries"))
 DECLARE i18n_task_modifyimage = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify Image","Modify Image"))
 DECLARE i18n_task_modify_patient_responsibility = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Modify Patient Responsibility","Modify Patient Responsibility")
  )
 DECLARE i18n_task_modifyreceiptnumber = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify Receipt Number","Modify Receipt Number"))
 DECLARE i18n_task_modifystatementcycle = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Statement Cycle","Statement Cycle"))
 DECLARE i18n_task_modify_eob = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify","Modify"))
 DECLARE i18n_task_movechargesforencounter = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Move Charges","Move Charges"))
 DECLARE i18n_task_movecharges = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Move Charge","Move Charge"))
 DECLARE i18n_task_openbillrecordbrowser = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open Bill Record Browser","Open Bill Record Browser"))
 DECLARE i18n_task_openchargeentry = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Charge Entry","Charge Entry"))
 DECLARE i18n_task_openchargeviewer = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Charge Viewer","Charge Viewer"))
 DECLARE i18n_task_openclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open Claim","Open Claim"))
 DECLARE i18n_task_openfirstnet = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open FirstNet","Open FirstNet"))
 DECLARE i18n_task_openinvoice = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open Invoice","Open Invoice"))
 DECLARE i18n_task_openpostinglevel = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open Posting Level","Open Posting Level"))
 DECLARE i18n_task_openprofile = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open ProFile","Open ProFile"))
 DECLARE i18n_task_openpowerchart = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open PowerChart","Open PowerChart"))
 DECLARE i18n_task_openstatement = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open Statement","Open Statement"))
 DECLARE i18n_task_opensurginet = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open SurgiNet","Open SurgiNet"))
 DECLARE i18n_task_openumdap = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Open UMDAP","Open UMDAP"))
 DECLARE i18n_task_outofoffice = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Out of Office","Out Of Office..."))
 DECLARE i18n_task_postremittancetask = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Post Remittance","Post Remittance"))
 DECLARE i18n_task_pricingdetail = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Pricing Detail","Pricing Detail"))
 DECLARE i18n_task_printclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Print Claim","Print Claim"))
 DECLARE i18n_task_printinvoice = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Print Invoice","Print Invoice"))
 DECLARE i18n_task_reassignworkflowitem = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Reassign","Reassign"))
 DECLARE i18n_task_rebill_claim_lines = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Rebill Claim Lines","Rebill Claim Lines"))
 DECLARE i18n_task_redistributeworkflow = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Redistribute","Redistribute"))
 DECLARE i18n_task_redistributeallworkflow = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Redistribute All","Redistribute All"))
 DECLARE i18n_task_releasewithfollowup = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Release with Follow up","Release with Follow up"))
 DECLARE i18n_task_removebillinghold = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Remove Billing Hold","Remove Billing Hold"))
 DECLARE i18n_task_removechargeevent = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Remove Charge Batch","Remove Charge Batch"))
 DECLARE i18n_task_removeformalpaymentplan = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Remove Formal Payment Plan","Remove Formal Payment Plan"))
 DECLARE i18n_task_removefromcollections = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Remove from Collections","Remove from Collections"))
 DECLARE i18n_task_removeratecode = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Remove Rate Code","Remove Rate Code"))
 DECLARE i18n_task_modifypackage = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify Package","Modify Package"))
 DECLARE i18n_task_reversefrombankruptcy = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Reverse from Bankruptcy","Reverse from Bankruptcy"))
 DECLARE i18n_task_reversetransaction = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Reverse Transaction","Reverse Transaction"))
 DECLARE i18n_task_sendencountertocollections = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Assign to Collections","Assign to Collections"))
 DECLARE i18n_task_sendencountertoprecollections = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Assign to Pre-Collections","Assign to Pre-Collections"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill = vc WITH protect, constant(
  uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set as Ready to Bill","Set as Ready to Bill")
  )
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior = vc WITH protect, constant(
  uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set As Waiting Previous Balance Completion",
   "Set As Waiting Previous Balance Completion"))
 DECLARE i18n_task_set_insurance_balance_as_generated = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set As Generated","Set As Generated"))
 DECLARE i18n_task_submitremittancetask = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Submit Remittance","Submit Remittance"))
 DECLARE i18n_task_transfer_balance = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Transfer Balance","Transfer Balance"))
 DECLARE i18n_task_transfertransactiontogeneralar = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Transfer to General A/R Account",
   "Transfer to General A/R Account"))
 DECLARE i18n_task_transfertransactiontopatientar = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Transfer to Patient A/R Account",
   "Transfer to Patient A/R Account"))
 DECLARE i18n_task_transfertransaction = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Transfer Transaction","Transfer Transaction"))
 DECLARE i18n_task_unlockchargebatch = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Unlock Charge Batch","Unlock Charge Batch"))
 DECLARE i18n_task_unpackage = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Unpackage","Unpackage"))
 DECLARE i18n_task_viewaprefund = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View AP Refund","View AP Refund"))
 DECLARE i18n_task_viewcorrespondence = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View Correspondence","View Correspondence"))
 DECLARE i18n_task_view_collections_history = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View Collections History","View Collections History"))
 DECLARE i18n_task_viewimage = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View Image","View Image"))
 DECLARE i18n_task_viewreceipt = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View Receipt","View Receipt"))
 DECLARE i18n_task_viewreport = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View Report","View Report"))
 DECLARE i18n_task_viewreporthistory = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.View Report History","View Report History"))
 DECLARE i18n_task_voidclaim = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Void Claim","Void Claim"))
 DECLARE i18n_task_writeoffcharge = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Write Off","Write Off"))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_available = vc WITH protect,
 constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Balance completion available",
   "Balance completion available"))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_invalid_status = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Balance completion invalid status","Balance completion invalid status"
   ))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_not_insurance = vc WITH protect,
 constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Balance completion not insurance",
   "Balance completion not insurance"))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_encounter_history = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Balance completion encounter history",
   "Balance completion encounter history"))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_next_bal_not_rtb = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Balance completion next balance not ready to bill",
   "Balance completion next balance not ready to bill"))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_credit_amount = vc WITH protect,
 constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Balance completion credit amount",
   "Balance completion credit amount"))
 DECLARE i18n_task_complete_insurance_balance_flag_balance_completion_denied_pending_review = vc
 WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Balance completion denied pending review",
   "Balance completion denied pending review"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill_flag_set_rtb_invalid_status = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set rtb invalid status",
   "Set rtb invalid status"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill_flag_set_rtb_not_insurance = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set rtb not insurance",
   "Set rtb not insurance"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill_flag_set_rtb_encounter_history = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set rtb encounter history",
   "Set rtb encounter history"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill_flag_set_rtb_credit_amount = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set rtb credit amount",
   "Set rtb credit amount"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill_flag_set_rtb_denied_pending_review = vc
 WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.set rtb denied pending review","set rtb denied pending review"))
 DECLARE i18n_task_set_insurance_balance_as_ready_to_bill_flag_set_rtb_available = vc WITH protect,
 constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set rtb available",
   "Set rtb available"))
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_invalid_status = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc invalid status",
   "Set wpbc invalid status"))
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_not_insurance = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc not insurance",
   "Set wpbc not insurance"))
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_primary = vc WITH protect,
 constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc primary","Set wpbc primary")
  )
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_encounter_history = vc
 WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc encounter history","Set wpbc encounter history"))
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_credit_amount = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc credit amount",
   "Set wpbc credit amount"))
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_denied_pending_review =
 vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc denied pending review","Set wpbc denied pending review"))
 DECLARE i18n_task_set_insurance_balance_as_waiting_for_prior_flag_set_wpbc_available = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set wpbc available",
   "Set wpbc available"))
 DECLARE i18n_task_set_insurance_balance_as_generated_flag_set_generated_invalid_status = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Set generated invalid status","Set generated invalid status"))
 DECLARE i18n_task_set_insurance_balance_as_generated_flag_set_generated_not_insurance = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Set generated not insurance",
   "Set generated not insurance"))
 DECLARE i18n_task_set_insurance_balance_as_generated_flag_set_generated_encounter_history = vc WITH
 protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Set generated encounter history","Set generated encounter history"))
 DECLARE i18n_task_modifycharge = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Modify Charge","Modify Charge"))
 DECLARE i18n_task_generate_packages = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "FT_RCA_TASK_DISPLAY_NAMES.GeneratePackages","Generate Packages"))
 DECLARE i18n_task_hardclose = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.Hard Close","Hard Close"))
 DECLARE i18n_task_generate_invoice = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.GenerateInvoice","Generate Invoice"))
 DECLARE i18n_task_transfertransactiontoclientar = vc WITH protect, constant(uar_i18ngetmessage(
   _hi18n,"PFT_RCA_TASK_DISPLAY_NAMES.Transfer to Client A/R Account",
   "Transfer to Client A/R Account"))
 DECLARE i18n_task_modify_out_of_office = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ModifyOutOfOffice","Modify"))
 DECLARE i18n_task_delete_out_of_office = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.DeleteOutOfOffice","Delete"))
 DECLARE i18n_task_end_active_occurrence = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.EndActiveOccurrence","End Active Occurrence"))
 DECLARE i18n_task_modify_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ModifyWorkflowModel","Modify Workflow"))
 DECLARE i18n_task_pause_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.PauseWorkflowModel","Pause Workflow"))
 DECLARE i18n_task_resume_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ResumeWorkflowModel","Resume Workflow"))
 DECLARE i18n_task_reset_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ResetWorkflowModel","Reset Workflow"))
 DECLARE i18n_task_cancel_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.CancelWorkflowModel","Cancel Workflow"))
 DECLARE i18n_task_start_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.StartWorkflowModel","Start Workflow"))
 DECLARE i18n_task_compose_message = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ComposeMessage","Compose Message"))
 DECLARE i18n_task_openpatientaccount = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.OpenPatientAccount","Open Patient Account"))
 DECLARE i18n_task_reprioritize = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ReprioritizeWorkItem","Reprioritize"))
 DECLARE i18n_task_modifytransaction = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,
   "PFT_RCA_TASK_DISPLAY_NAMES.ModifyTransactionTask","Modify Transaction"))
 IF ( NOT (validate(tasks)))
  RECORD tasks(
    1 list[*]
      2 taskdisplayname = vc
      2 taskid = vc
      2 taskallowmultiselect = i2
  ) WITH protect
 ENDIF
 IF ( NOT (validate(entity_remittance)))
  DECLARE entity_remittance = vc WITH protect, constant("REMITTANCE")
 ENDIF
 IF ( NOT (validate(entity_eob)))
  DECLARE entity_eob = vc WITH protect, constant("EOB")
 ENDIF
 IF ( NOT (validate(entity_ap_refund)))
  DECLARE entity_ap_refund = vc WITH protect, constant("AP_REFUND")
 ENDIF
 IF ( NOT (validate(entity_billing_hold)))
  DECLARE entity_billing_hold = vc WITH protect, constant("BILLING_HOLD")
 ENDIF
 IF ( NOT (validate(entity_charge)))
  DECLARE entity_charge = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(entity_charge_batch)))
  DECLARE entity_charge_batch = vc WITH protect, constant("CHARGE_BATCH")
 ENDIF
 IF ( NOT (validate(entity_charge_client)))
  DECLARE entity_charge_client = vc WITH protect, constant("CHARGE_CLIENT")
 ENDIF
 IF ( NOT (validate(entity_claim)))
  DECLARE entity_claim = vc WITH protect, constant("CLAIM")
 ENDIF
 IF ( NOT (validate(entity_client_account)))
  DECLARE entity_client_account = vc WITH protect, constant("CLIENT_ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_research_account)))
  DECLARE entity_research_account = vc WITH protect, constant("RESEARCH_ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_client_invoice)))
  DECLARE entity_client_invoice = vc WITH protect, constant("CLIENT_INVOICE")
 ENDIF
 IF ( NOT (validate(entity_clinical_encounter)))
  DECLARE entity_clinical_encounter = vc WITH protect, constant("CLINICAL_ENCOUNTER")
 ENDIF
 IF ( NOT (validate(entity_excel_report)))
  DECLARE entity_excel_report = vc WITH protect, constant("EXCEL_REPORT")
 ENDIF
 IF ( NOT (validate(entity_financial_encounter)))
  DECLARE entity_financial_encounter = vc WITH protect, constant("FINANCIAL_ENCOUNTER")
 ENDIF
 IF ( NOT (validate(entity_fin_encounter_client)))
  DECLARE entity_fin_encounter_client = vc WITH protect, constant("FIN_ENCOUNTER_CLIENT")
 ENDIF
 IF ( NOT (validate(entity_fin_encounter_research)))
  DECLARE entity_fin_encounter_research = vc WITH protect, constant("FIN_ENCOUNTER_RESEARCH")
 ENDIF
 IF ( NOT (validate(entity_fin_encounter_guarantor)))
  DECLARE entity_fin_encounter_guarantor = vc WITH protect, constant("FIN_ENCOUNTER_GUARANTOR")
 ENDIF
 IF ( NOT (validate(entity_guarantor)))
  DECLARE entity_guarantor = vc WITH protect, constant("GUARANTOR")
 ENDIF
 IF ( NOT (validate(entity_guarantor_summary)))
  DECLARE entity_guarantor_summary = vc WITH protect, constant("GUARANTOR_SUMMARY")
 ENDIF
 IF ( NOT (validate(entity_workflow_follow_up)))
  DECLARE entity_workflow_follow_up = vc WITH protect, constant("FOLLOW_UP")
 ENDIF
 IF ( NOT (validate(entity_insurance_balance)))
  DECLARE entity_insurance_balance = vc WITH protect, constant("INSURANCE_BALANCE")
 ENDIF
 IF ( NOT (validate(entity_insurance_transaction)))
  DECLARE entity_insurance_transaction = vc WITH protect, constant("INSURANCE_TRANSACTION")
 ENDIF
 IF ( NOT (validate(entity_nonexcel_report)))
  DECLARE entity_nonexcel_report = vc WITH protect, constant("NONEXCEL_REPORT")
 ENDIF
 IF ( NOT (validate(entity_business_account)))
  DECLARE entity_business_account = vc WITH protect, constant("BUSINESS_ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_patient_account)))
  DECLARE entity_patient_account = vc WITH protect, constant("PATIENT_ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_personnel)))
  DECLARE entity_personnel = vc WITH protect, constant("PERSONNEL")
 ENDIF
 IF ( NOT (validate(entity_rate_code)))
  DECLARE entity_rate_code = vc WITH protect, constant("RATE_CODE")
 ENDIF
 IF ( NOT (validate(entity_report)))
  DECLARE entity_report = vc WITH protect, constant("REPORT")
 ENDIF
 IF ( NOT (validate(entity_selfpay_balance)))
  DECLARE entity_selfpay_balance = vc WITH protect, constant("SELFPAY_BALANCE")
 ENDIF
 IF ( NOT (validate(entity_selfpay_transaction)))
  DECLARE entity_selfpay_transaction = vc WITH protect, constant("SELFPAY_TRANSACTION")
 ENDIF
 IF ( NOT (validate(entity_statement)))
  DECLARE entity_statement = vc WITH protect, constant("STATEMENT")
 ENDIF
 IF ( NOT (validate(entity_workflow_item)))
  DECLARE entity_workflow_item = vc WITH protect, constant("WORKFLOW_ITEM")
 ENDIF
 IF ( NOT (validate(entity_workflow_summary)))
  DECLARE entity_workflow_summary = vc WITH protect, constant("WORKFLOW_SUMMARY")
 ENDIF
 IF ( NOT (validate(entity_workflow_module)))
  DECLARE entity_workflow_module = vc WITH protect, constant("WORKFLOW_MODULE")
 ENDIF
 IF ( NOT (validate(entity_image)))
  DECLARE entity_image = vc WITH protect, constant("IMAGE")
 ENDIF
 IF ( NOT (validate(entity_correspondence)))
  DECLARE entity_correspondence = vc WITH protect, constant("CORRESPONDENCE")
 ENDIF
 IF ( NOT (validate(entity_referral)))
  DECLARE entity_referral = vc WITH protect, constant("REFERRAL")
 ENDIF
 IF ( NOT (validate(entity_schevent)))
  DECLARE entity_schevent = vc WITH protect, constant("SCHEVENT")
 ENDIF
 IF ( NOT (validate(entity_schentry)))
  DECLARE entity_schentry = vc WITH protect, constant("SCHENTRY")
 ENDIF
 IF ( NOT (validate(entity_billing_entity)))
  DECLARE entity_billing_entity = vc WITH protect, constant("BILL_ENTITY")
 ENDIF
 IF ( NOT (validate(entity_tenant)))
  DECLARE entity_tenant = vc WITH protect, constant("TENANT")
 ENDIF
 IF ( NOT (validate(entity_account)))
  DECLARE entity_account = vc WITH protect, constant("ACCOUNT")
 ENDIF
 IF ( NOT (validate(entity_person)))
  DECLARE entity_person = vc WITH protect, constant("PERSON")
 ENDIF
 IF ( NOT (validate(entity_client_account_transaction)))
  DECLARE entity_client_account_transaction = vc WITH protect, constant("CLIENT_ACCOUNT_TRANSACTION")
 ENDIF
 IF ( NOT (validate(entity_line_item)))
  DECLARE entity_line_item = vc WITH protect, constant("LINE_ITEM")
 ENDIF
 IF ( NOT (validate(entity_business_account_transaction)))
  DECLARE entity_business_account_transaction = vc WITH protect, constant(
   "BUSINESS_ACCOUNT_TRANSACTION")
 ENDIF
 IF ( NOT (validate(entity_out_of_office)))
  DECLARE entity_out_of_office = vc WITH protect, constant("OUT_OF_OFFICE")
 ENDIF
 IF ( NOT (validate(entity_workflow_model)))
  DECLARE entity_workflow_model = vc WITH protect, constant("WORKFLOW_MODEL")
 ENDIF
 IF ( NOT (validate(entity_research_account_transaction)))
  DECLARE entity_research_account_transaction = vc WITH protect, constant(
   "RESEARCH_ACCOUNT_TRANSACTION")
 ENDIF
 IF ( NOT (validate(entity_charge_research)))
  DECLARE entity_charge_research = vc WITH protect, constant("CHARGE_RESEARCH")
 ENDIF
 IF ( NOT (validate(entity_patient_account_guarantor)))
  DECLARE entity_patient_account_guarantor = vc WITH protect, constant("PATIENT_ACCOUNT_GUARANTOR")
 ENDIF
 DECLARE associate_balance_for_billing_task_id = vc WITH protect, constant(
  "AssociateBalanceForBillingTask")
 DECLARE add_billing_hold_task_id = vc WITH protect, constant("AddBillingHoldTask")
 DECLARE add_image_task_id = vc WITH protect, constant("AddImageTask")
 DECLARE add_rate_code_task_id = vc WITH protect, constant("AddRateCodeTask")
 DECLARE apply_adjustment_task_id = vc WITH protect, constant("ApplyAdjustmentTask")
 DECLARE apply_adjustment_task_id2 = vc WITH protect, constant("ApplyAdjustmentTask2")
 DECLARE apply_action_code_task_id = vc WITH protect, constant("ApplyActionCodeTask")
 DECLARE apply_action_code_task_id2 = vc WITH protect, constant("ApplyActionCodeTask2")
 DECLARE apply_comment_task_id = vc WITH protect, constant("ApplyCommentTask")
 DECLARE apply_refund_task_id = vc WITH protect, constant("ApplyRefundTask")
 DECLARE apply_remark_task_id = vc WITH protect, constant("ApplyRemarkTask")
 DECLARE apply_sp_remittance_task_id = vc WITH protect, constant("ApplySelfPayRemittanceTask")
 DECLARE assign_to_bankruptcy_task_id = vc WITH protect, constant("AssignToBankruptcyTask")
 DECLARE bill_late_charges_task_id = vc WITH protect, constant("BillLateChargesTask")
 DECLARE bill_as_professional_task_id = vc WITH protect, constant("BillAsProfessionalTask")
 DECLARE bill_as_institutional_task_id = vc WITH protect, constant("BillAsInstitutionalTask")
 DECLARE cancel_ap_refund_task_id = vc WITH protect, constant("CancelAPRefundTask")
 DECLARE cancel_remittance_task_id = vc WITH protect, constant("CancelRemittanceTask")
 DECLARE cancel_claim_task_id = vc WITH protect, constant("CancelClaimTask")
 DECLARE replace_claim_task_id = vc WITH protect, constant("ReplaceClaimTask")
 DECLARE cancel_correspondence_task_id = vc WITH protect, constant("CancelCorrespondenceTask")
 DECLARE complete_insurance_balance_task_id = vc WITH protect, constant(
  "CompleteInsuranceBalanceTask")
 DECLARE create_aprefund_insurance_balance_task_id = vc WITH protect, constant(
  "CreateAPRefundForInsuranceBalanceTask")
 DECLARE create_aprefund_selfpay_balance_task_id = vc WITH protect, constant(
  "CreateAPRefundForSelfPayBalanceTask")
 DECLARE credit_charge_task_id = vc WITH protect, constant("CreditChargeTask")
 DECLARE delete_image_task_id = vc WITH protect, constant("DeleteImageTask")
 DECLARE deny_claim_task_id = vc WITH protect, constant("DenyClaimTask")
 DECLARE disable_eob_task_id = vc WITH protect, constant("DisableEOBTask")
 DECLARE encounter_combine_task_id = vc WITH protect, constant("EncounterCombineTask")
 DECLARE encounter_uncombine_task_id = vc WITH protect, constant("EncounterUncombineTask")
 DECLARE estimate_patient_liability_task_id = vc WITH protect, constant(
  "EstimatePatientLiabilityTask")
 DECLARE generate_claim_task_id = vc WITH protect, constant("GenerateClaimTask")
 DECLARE generate_adjustment_interim_claim_task_id = vc WITH protect, constant(
  "GenerateAdjustmentInterimClaimTask")
 DECLARE generate_continuing_interim_claim_task_id = vc WITH protect, constant(
  "GenerateContinuingInterimClaimTask")
 DECLARE generate_final_interim_claim_task_id = vc WITH protect, constant(
  "GenerateFinalInterimClaimTask")
 DECLARE generate_initial_interim_claim_task_id = vc WITH protect, constant(
  "GenerateInitialInterimClaimTask")
 DECLARE generate_statement_task_id = vc WITH protect, constant("GenerateStatementTask")
 DECLARE generate_invoice_task_id = vc WITH protect, constant("GenerateInvoiceTask")
 DECLARE generate_inquiry_letter_task_id = vc WITH protect, constant("GenerateInquiryLetterTask")
 DECLARE hard_close_task_id = vc WITH protect, constant("HardCloseTask")
 DECLARE identify_issue_task_id = vc WITH protect, constant("IdentifyIssueTask")
 DECLARE lock_charge_batch_task_id = vc WITH protect, constant("LockChargeBatchTask")
 DECLARE manage_images_task_id = vc WITH protect, constant("ManageImagesTask")
 DECLARE manual_release_task_id2 = vc WITH protect, constant("ManualReleaseTask2")
 DECLARE modify_ap_refund_task_id = vc WITH protect, constant("ModifyAPRefundTask")
 DECLARE modify_charge_group_task_id = vc WITH protect, constant("ModifyChargeGroupTask")
 DECLARE modify_formal_payment_plan_task_id = vc WITH protect, constant("ModifyFormalPaymentPlanTask"
  )
 DECLARE modify_gl_alias_task_id = vc WITH protect, constant("ModifyGLAliasTask")
 DECLARE modify_image_task_id = vc WITH protect, constant("ModifyImageTask")
 DECLARE modify_receipt_number_task_id = vc WITH protect, constant("ModifyReceiptNumberTask")
 DECLARE modify_statement_cycle_task_id = vc WITH protect, constant("ModifyStatementCycleTask")
 DECLARE modify_patient_responsibility_task_id = vc WITH protect, constant(
  "ModifyPatientResponsibilityTask")
 DECLARE move_charges_for_encounter_task_id = vc WITH protect, constant("MoveChargesForEncounterTask"
  )
 DECLARE move_charges_task_id = vc WITH protect, constant("MoveChargesTask")
 DECLARE modify_charge_task_id = vc WITH protect, constant("ModifyChargeTask")
 DECLARE modify_eob_task_id = vc WITH protect, constant("ModifyEOBTask")
 DECLARE open_bill_record_browser_task = vc WITH protect, constant("OpenBillRecordBrowserTask")
 DECLARE open_charge_entry_task_id = vc WITH protect, constant("OpenChargeEntryTask")
 DECLARE open_charge_viewer_task_id = vc WITH protect, constant("OpenChargeViewerTask")
 DECLARE open_claim_task_id = vc WITH protect, constant("OpenClaimTask")
 DECLARE open_first_net_task_id = vc WITH protect, constant("OpenFirstNetTask")
 DECLARE open_invoice_task_id = vc WITH protect, constant("OpenInvoiceTask")
 DECLARE open_pmconv_1_task = vc WITH protect, constant("OpenPMConversation1Task")
 DECLARE open_pmconv_2_task = vc WITH protect, constant("OpenPMConversation2Task")
 DECLARE open_posting_level_task = vc WITH protect, constant("OpenPostingLevelTask")
 DECLARE open_power_chart_task_id = vc WITH protect, constant("OpenPowerChartTask")
 DECLARE open_profile_task_id = vc WITH protect, constant("OpenProFileTask")
 DECLARE open_statement_task_id = vc WITH protect, constant("OpenStatementTask")
 DECLARE open_surgi_net_task_id = vc WITH protect, constant("OpenSurgiNetTask")
 DECLARE open_tbe_task_id = vc WITH protect, constant("OpenTBEForBatchTask")
 DECLARE open_umdap_task_id = vc WITH protect, constant("OpenUMDAPTask")
 DECLARE out_of_office_task_id = vc WITH protect, constant("OutOfOfficeTask")
 DECLARE post_remittance_task_id = vc WITH protect, constant("PostRemittanceTask")
 DECLARE pricing_detail_task_id = vc WITH protect, constant("PricingDetailTask")
 DECLARE print_claim_task_id = vc WITH protect, constant("PrintClaimTask")
 DECLARE print_invoice_task_id = vc WITH protect, constant("PrintInvoiceTask")
 DECLARE reassign_workflow_item_task_id = vc WITH protect, constant("ReassignWorkflowItemTask")
 DECLARE reassign_workflow_item_task_id2 = vc WITH protect, constant("ReassignWorkflowItemTask2")
 DECLARE rebill_claim_lines_task_id = vc WITH protect, constant("RebillClaimLinesTask")
 DECLARE redistribute_all_workflow__task_id = vc WITH protect, constant("RedistributeAllWorkflowTask"
  )
 DECLARE redistribute_workflow__task_id = vc WITH protect, constant("RedistributeWorkflowTask")
 DECLARE release_with_follow_up_task_id = vc WITH protect, constant("ReleaseWithFollowUpTask")
 DECLARE remove_billing_hold_task_id = vc WITH protect, constant("RemoveBillingHoldTask")
 DECLARE remove_charge_batch_task_id = vc WITH protect, constant("RemoveChargeBatchTask")
 DECLARE remove_formal_payment_plan_task_id = vc WITH protect, constant("RemoveFormalPaymentPlanTask"
  )
 DECLARE remove_from_collections_task_id = vc WITH protect, constant("RemoveFromCollectionsTask")
 DECLARE remove_rate_code_task_id = vc WITH protect, constant("RemoveRateCodeTask")
 DECLARE reverse_from_bankruptcy_task_id = vc WITH protect, constant("ReverseFromBankruptcyTask")
 DECLARE reverse_transaction_task_id = vc WITH protect, constant("ReverseTransactionTask")
 DECLARE send_encounter_to_collections_task_id = vc WITH protect, constant(
  "SendEncounterToCollectionsTask")
 DECLARE send_encounter_to_pre_collections_task_id = vc WITH protect, constant(
  "SendEncounterToPreCollectionsTask")
 DECLARE set_insurance_balance_as_generated_task_id = vc WITH protect, constant(
  "SetInsuranceBalanceAsGeneratedTask")
 DECLARE set_insurance_balance_as_ready_to_bill_task_id = vc WITH protect, constant(
  "SetInsuranceBalanceAsReadyToBillTask")
 DECLARE set_insurance_balance_as_waiting_for_prior_task_id = vc WITH protect, constant(
  "SetInsuranceBalanceAsWaitingForPriorTask")
 DECLARE show_patient_demographics_task_id = vc WITH protect, constant("ShowPatientDemographicsTask")
 DECLARE show_patient_demographics_task2_id = vc WITH protect, constant(
  "ShowPatientDemographicsTask2")
 DECLARE submit_remittance_task_id = vc WITH protect, constant("SubmitRemittanceTask")
 DECLARE transfer_balance_task_id = vc WITH protect, constant("TransferBalanceTask")
 DECLARE transfer_transaction_to_general_ar_task_id = vc WITH protect, constant(
  "TransferTransactionToGeneralARTask")
 DECLARE transfer_transaction_to_patient_ar_task_id = vc WITH protect, constant(
  "TransferTransactionToPatientARTask")
 DECLARE transfer_transaction_to_client_ar_task_id = vc WITH protect, constant(
  "TransferTransactionToClientARTask")
 DECLARE transfer_transaction_task_id = vc WITH protect, constant("TransferTransactionTask")
 DECLARE unlock_charge_batch_task_id = vc WITH protect, constant("UnlockChargeBatchTask")
 DECLARE view_correspondence_task_id = vc WITH protect, constant("ViewCorrespondenceTask")
 DECLARE view_collections_history_task_id = vc WITH protect, constant("ViewCollectionsHistoryTask")
 DECLARE view_image_task_id = vc WITH protect, constant("ViewImageTask")
 DECLARE view_receipt_task_id = vc WITH protect, constant("ViewReceiptTask")
 DECLARE view_report_history_task_id = vc WITH protect, constant("ViewReportHistoryTask")
 DECLARE view_report_task_id = vc WITH protect, constant("ViewReportTask")
 DECLARE void_claim_task_id = vc WITH protect, constant("VoidClaimTask")
 DECLARE write_off_charge_task_id = vc WITH protect, constant("WriteOffChargeTask")
 DECLARE mark_as_transmit_task_id = vc WITH protect, constant("MarkAsTransmitTask")
 DECLARE modify_out_of_office_task_id = vc WITH protect, constant("ModifyOutOfOfficeTask")
 DECLARE delete_out_of_office_task_id = vc WITH protect, constant("DeleteOutOfOfficeTask")
 DECLARE end_active_occurrence_task_id = vc WITH protect, constant("EndActiveOccurrenceTask")
 DECLARE modify_workflow_model_task_id = vc WITH protect, constant("ModifyWorkflowModelTask")
 DECLARE pause_workflow_model_task_id = vc WITH protect, constant("PauseWorkflowModelTask")
 DECLARE resume_workflow_model_task_id = vc WITH protect, constant("ResumeWorkflowModelTask")
 DECLARE reset_workflow_model_task_id = vc WITH protect, constant("ResetWorkflowModelTask")
 DECLARE cancel_workflow_model_task_id = vc WITH protect, constant("CancelWorkflowModelTask")
 DECLARE start_workflow_model_task_id = vc WITH protect, constant("StartWorkflowModelTask")
 DECLARE open_compose_message_task_id = vc WITH protect, constant("ComposeMessageTask")
 DECLARE open_patient_account_task_id = vc WITH protect, constant("OpenPatientAccountTask")
 DECLARE reprioritize_task_id = vc WITH protect, constant("ReprioritizeWorkItemTask")
 DECLARE modify_transaction_task_id = vc WITH protect, constant("ModifyTransactionTask")
 DECLARE revenue_cycle_app_number = i4 WITH protect, constant(130000)
 DECLARE tasknumberparser = vc WITH protect, noconstant("")
 IF (validate(getauthorizedtasksforentity,char(128))=char(128))
  SUBROUTINE (getauthorizedtasksforentity(entityname=vc,copytaskstoreplyind=i2) =i4)
    SET stat = initrec(tasks)
    CASE (entityname)
     OF entity_remittance:
      CALL addtaskifauthorized(130096,i18n_task_submitremittancetask,submit_remittance_task_id)
      CALL addtaskifauthorized(130095,i18n_task_cancelremittancetask,cancel_remittance_task_id)
      CALL addtaskifauthorized(130097,i18n_task_postremittancetask,post_remittance_task_id)
     OF entity_eob:
      CALL addtaskifauthorized2(130102,i18n_task_disable_eob,disable_eob_task_id,true)
      CALL addtaskifauthorized2(130102,i18n_task_modify_eob,modify_eob_task_id,true)
      CALL addtasktotasklist2(i18n_task_openpostinglevel,open_posting_level_task,true)
     OF entity_ap_refund:
      CALL addtaskifauthorized2(130186,i18n_task_cancelaprefund,cancel_ap_refund_task_id,true)
      CALL addtaskifauthorized2(130202,i18n_task_modifyaprefund,modify_ap_refund_task_id,false)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
     OF entity_billing_hold:
      CALL addtaskifauthorized(130041,i18n_task_removebillinghold,remove_billing_hold_task_id)
     OF entity_charge:
      CALL addtaskifauthorized(130094,i18n_task_applyactioncode,apply_action_code_task_id2)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130017,i18n_task_creditcharge,credit_charge_task_id)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized(130055,i18n_task_writeoffcharge,write_off_charge_task_id)
      CALL addtaskifauthorized2(130088,i18n_task_movecharges,move_charges_task_id,true)
      CALL addtaskifauthorized2(130066,i18n_task_modifychargegroup,modify_charge_group_task_id,true)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtaskifauthorized2(130104,i18n_task_modifycharge,modify_charge_task_id,true)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id2)
     OF entity_charge_client:
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130017,i18n_task_creditcharge,credit_charge_task_id)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized2(130104,i18n_task_modifycharge,modify_charge_task_id,true)
     OF entity_charge_research:
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130017,i18n_task_creditcharge,credit_charge_task_id)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized2(130104,i18n_task_modifycharge,modify_charge_task_id,true)
     OF entity_charge_batch:
      CALL addtaskifauthorized(130043,i18n_task_removechargeevent,remove_charge_batch_task_id)
      CALL addtaskifauthorized(130078,i18n_task_lockchargebatch,lock_charge_batch_task_id)
      CALL addtaskifauthorized(130078,i18n_task_unlockchargebatch,unlock_charge_batch_task_id)
     OF entity_claim:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130016,i18n_task_cancelclaim,cancel_claim_task_id)
      CALL addtaskifauthorized(130116,i18n_task_replaceclaim,replace_claim_task_id)
      CALL addtaskifauthorized(130118,i18n_task_voidclaim,void_claim_task_id)
      CALL addtaskifauthorized(130018,i18n_task_denyclaim,deny_claim_task_id)
      CALL addtaskifauthorized(130028,i18n_task_openbillrecordbrowser,open_bill_record_browser_task)
      CALL addtaskifauthorized(130031,i18n_task_openclaim,open_claim_task_id)
      CALL addtaskifauthorized(130036,i18n_task_printclaim,print_claim_task_id)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
      CALL addtaskifauthorized(130147,i18n_task_pricingdetail,pricing_detail_task_id)
      CALL addtaskifauthorized(130091,i18n_task_identifyissue,identify_issue_task_id)
      CALL addtaskifauthorized(130154,i18n_task_apply_remark,apply_remark_task_id)
      CALL addtaskifauthorized(130218,i18n_task_mark_as_transmitted,mark_as_transmit_task_id)
     OF entity_client_account:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
      CALL addtaskifauthorized(130269,i18n_task_generate_invoice,generate_invoice_task_id)
     OF entity_research_account:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130269,i18n_task_generate_invoice,generate_invoice_task_id)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_client_invoice:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130031,i18n_task_openinvoice,open_invoice_task_id)
      CALL addtaskifauthorized(130036,i18n_task_printinvoice,print_invoice_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_clinical_encounter:
      CALL addtaskifauthorized(130008,i18n_task_addratecode,add_rate_code_task_id)
      CALL addtaskifauthorized(130076,i18n_task_openchargeentry,open_charge_entry_task_id)
      CALL addtaskifauthorized(130030,i18n_task_openchargeviewer,open_charge_viewer_task_id)
      CALL addtaskifauthorized(130032,i18n_task_openprofile,open_profile_task_id)
      CALL addshowpatientdemographicstasks(0)
     OF entity_correspondence:
      CALL addtaskifauthorized(130108,i18n_task_cancelcorrespondence,cancel_correspondence_task_id)
      CALL addtaskifauthorized(130110,i18n_task_viewcorrespondence,view_correspondence_task_id)
     OF entity_excel_report:
      CALL addtaskifauthorized(130054,i18n_task_viewreporthistory,view_report_history_task_id)
     OF entity_financial_encounter:
     OF entity_fin_encounter_guarantor:
      CALL addtaskifauthorized(130007,i18n_task_addbillinghold,add_billing_hold_task_id)
      CALL addtaskifauthorized(130008,i18n_task_addratecode,add_rate_code_task_id)
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130010,i18n_task_applycomment,apply_comment_task_id,true)
      CALL addtaskifauthorized(130011,i18n_task_applyselfpayremittance,apply_sp_remittance_task_id)
      CALL addtaskifauthorized(130120,i18n_task_encountercombine,encounter_combine_task_id)
      CALL addtaskifauthorized(130121,i18n_task_encounteruncombine,encounter_uncombine_task_id)
      CALL addtaskifauthorized(130019,i18n_task_estimatepatientliability,
       estimate_patient_liability_task_id)
      CALL addtaskifauthorized(130021,i18n_task_generateondemandstatement,generate_statement_task_id)
      CALL addtaskifauthorized(130091,i18n_task_identifyissue,identify_issue_task_id)
      CALL addtaskifauthorized(130023,i18n_task_modifyformalpaymentplan,
       modify_formal_payment_plan_task_id)
      CALL addtaskifauthorized(130026,i18n_task_modifystatementcycle,modify_statement_cycle_task_id)
      CALL addtaskifauthorized(130027,i18n_task_movechargesforencounter,
       move_charges_for_encounter_task_id)
      CALL addtaskifauthorized(130076,i18n_task_openchargeentry,open_charge_entry_task_id)
      CALL addtaskifauthorized(130030,i18n_task_openchargeviewer,open_charge_viewer_task_id)
      CALL addtaskifauthorized(130032,i18n_task_openprofile,open_profile_task_id)
      CALL addtaskifauthorized(130042,i18n_task_removeformalpaymentplan,
       remove_formal_payment_plan_task_id)
      CALL addtaskifauthorized(130044,i18n_task_removefromcollections,remove_from_collections_task_id
       )
      CALL addshowpatientdemographicstasks(0)
      CALL addtaskifauthorized(130049,i18n_task_sendencountertocollections,
       send_encounter_to_collections_task_id)
      CALL addtaskifauthorized(130050,i18n_task_sendencountertoprecollections,
       send_encounter_to_pre_collections_task_id)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
      CALL addtaskifauthorized(130103,i18n_task_generate_inquiry_letter,
       generate_inquiry_letter_task_id)
      CALL addtaskifauthorized(130130,i18n_task_view_collections_history,
       view_collections_history_task_id)
      CALL addtaskifauthorized(130262,i18n_task_compose_message,open_compose_message_task_id)
     OF entity_fin_encounter_client:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130010,i18n_task_applycomment,apply_comment_task_id,true)
      CALL addtaskifauthorized(130030,i18n_task_openchargeviewer,open_charge_viewer_task_id)
      CALL addshowpatientdemographicstasks(0)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_fin_encounter_research:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130010,i18n_task_applycomment,apply_comment_task_id,true)
      CALL addtaskifauthorized(130030,i18n_task_openchargeviewer,open_charge_viewer_task_id)
      CALL addshowpatientdemographicstasks(0)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_guarantor:
      CALL addtaskifauthorized(130035,i18n_task_openumdap,open_umdap_task_id)
     OF entity_guarantor_summary:
      CALL addtaskifauthorized(130011,i18n_task_applyselfpayremittance,apply_sp_remittance_task_id)
     OF entity_insurance_balance:
      CALL addtaskifauthorized(130007,i18n_task_addbillinghold,add_billing_hold_task_id)
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130015,i18n_task_billlatecharges,bill_late_charges_task_id)
      CALL addtaskifauthorized(130020,i18n_task_generateclaim,generate_claim_task_id)
      CALL addtaskifauthorized(130056,i18n_task_complete_insurance_balance,
       complete_insurance_balance_task_id)
      CALL addtaskifauthorized(130063,i18n_task_generate_adjustment_interim_claim,
       generate_adjustment_interim_claim_task_id)
      CALL addtaskifauthorized(130061,i18n_task_generate_continuing_interim_claim,
       generate_continuing_interim_claim_task_id)
      CALL addtaskifauthorized(130062,i18n_task_generate_final_interim_claim,
       generate_final_interim_claim_task_id)
      CALL addtaskifauthorized(130060,i18n_task_generate_initial_interim_claim,
       generate_initial_interim_claim_task_id)
      CALL addtaskifauthorized(130091,i18n_task_identifyissue,identify_issue_task_id)
      CALL addtaskifauthorized(130059,i18n_task_set_insurance_balance_as_generated,
       set_insurance_balance_as_generated_task_id)
      CALL addtaskifauthorized(130057,i18n_task_set_insurance_balance_as_ready_to_bill,
       set_insurance_balance_as_ready_to_bill_task_id)
      CALL addtaskifauthorized(130058,i18n_task_set_insurance_balance_as_waiting_for_prior,
       set_insurance_balance_as_waiting_for_prior_task_id)
      CALL addtaskifauthorized(130084,i18n_task_transfer_balance,transfer_balance_task_id)
      CALL addtaskifauthorized(130086,i18n_task_associate_balance_for_billing,
       associate_balance_for_billing_task_id)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130092,i18n_task_modify_patient_responsibility,
       modify_patient_responsibility_task_id)
      CALL addtaskifauthorized(130123,i18n_task_bill_as_professional,bill_as_professional_task_id)
      CALL addtaskifauthorized(130124,i18n_task_bill_as_institutional,bill_as_institutional_task_id)
      CALL addtaskifauthorized(130012,i18n_task_createaprefund,
       create_aprefund_insurance_balance_task_id)
     OF entity_insurance_transaction:
      CALL addtaskifauthorized2(130010,i18n_task_applycomment,apply_comment_task_id,true)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized2(130047,i18n_task_reversetransaction,reverse_transaction_task_id,true)
      CALL addtaskifauthorized(130051,i18n_task_transfertransactiontogeneralar,
       transfer_transaction_to_general_ar_task_id)
      CALL addtaskifauthorized(130052,i18n_task_transfertransactiontopatientar,
       transfer_transaction_to_patient_ar_task_id)
      IF (((istaskauthorized(transfer_transaction_to_general_ar_task_id) > 0) OR (istaskauthorized(
       transfer_transaction_to_patient_ar_task_id) > 0)) )
       CALL addtasktotasklist2(i18n_task_transfertransaction,transfer_transaction_task_id,true)
      ENDIF
     OF entity_line_item:
      CALL addtaskifauthorized(130031,i18n_task_openclaim,open_claim_task_id)
      CALL addtaskifauthorized(130036,i18n_task_printclaim,print_claim_task_id)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtaskifauthorized(130154,i18n_task_apply_remark,apply_remark_task_id)
      CALL addtaskifauthorized2(130342,i18n_task_rebill_claim_lines,rebill_claim_lines_task_id,true)
     OF entity_nonexcel_report:
      CALL addtaskifauthorized(130054,i18n_task_viewreporthistory,view_report_history_task_id)
     OF entity_business_account:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
     OF entity_patient_account:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130011,i18n_task_applyselfpayremittance,apply_sp_remittance_task_id)
      CALL addtaskifauthorized(130014,i18n_task_assigntobankruptcy,assign_to_bankruptcy_task_id)
      CALL addtaskifauthorized(130046,i18n_task_reversefrombankruptcy,reverse_from_bankruptcy_task_id
       )
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_patient_account_guarantor:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130011,i18n_task_applyselfpayremittance,apply_sp_remittance_task_id)
      CALL addtaskifauthorized(130014,i18n_task_assigntobankruptcy,assign_to_bankruptcy_task_id)
      CALL addtaskifauthorized(130046,i18n_task_reversefrombankruptcy,reverse_from_bankruptcy_task_id
       )
      CALL addtaskifauthorized(130085,i18n_task_applyadjustment,apply_adjustment_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
      CALL addtaskifauthorized(130321,i18n_task_openpatientaccount,open_patient_account_task_id)
     OF entity_personnel:
      CALL addtasktotasklist(i18n_task_outofoffice,out_of_office_task_id)
     OF entity_rate_code:
      CALL addtaskifauthorized(130045,i18n_task_removeratecode,remove_rate_code_task_id)
     OF entity_report:
      CALL addtaskifauthorized(130054,i18n_task_viewreport,view_report_task_id)
     OF entity_selfpay_balance:
      CALL addtaskifauthorized(130007,i18n_task_addbillinghold,add_billing_hold_task_id)
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130020,i18n_task_generateclaim,generate_claim_task_id)
      CALL addtaskifauthorized(130021,i18n_task_generateondemandstatement,generate_statement_task_id)
      CALL addtaskifauthorized(130084,i18n_task_transfer_balance,transfer_balance_task_id)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130012,i18n_task_createaprefund,
       create_aprefund_selfpay_balance_task_id)
     OF entity_selfpay_transaction:
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized(130025,i18n_task_modifyreceiptnumber,modify_receipt_number_task_id)
      CALL addtaskifauthorized2(130047,i18n_task_reversetransaction,reverse_transaction_task_id,true)
      CALL addtaskifauthorized(130051,i18n_task_transfertransactiontogeneralar,
       transfer_transaction_to_general_ar_task_id)
      CALL addtaskifauthorized(130052,i18n_task_transfertransactiontopatientar,
       transfer_transaction_to_patient_ar_task_id)
      IF (((istaskauthorized(transfer_transaction_to_general_ar_task_id) > 0) OR (istaskauthorized(
       transfer_transaction_to_patient_ar_task_id) > 0)) )
       CALL addtasktotasklist2(i18n_task_transfertransaction,transfer_transaction_task_id,true)
      ENDIF
      CALL addtaskifauthorized(130053,i18n_task_viewreceipt,view_receipt_task_id)
      CALL addtaskifauthorized(130117,i18n_task_applyrefund,apply_refund_task_id)
      CALL addtaskifauthorized(130334,i18n_task_modifytransaction,modify_transaction_task_id)
     OF entity_client_account_transaction:
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized2(130047,i18n_task_reversetransaction,reverse_transaction_task_id,true)
      CALL addtaskifauthorized(130051,i18n_task_transfertransactiontogeneralar,
       transfer_transaction_to_general_ar_task_id)
      IF (((istaskauthorized(transfer_transaction_to_general_ar_task_id) > 0) OR (istaskvalid(130267)
       > 0)) )
       CALL addtasktotasklist2(i18n_task_transfertransaction,transfer_transaction_task_id,true)
      ENDIF
     OF entity_research_account_transaction:
      CALL addtaskifauthorized2(130047,i18n_task_reversetransaction,reverse_transaction_task_id,true)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
      CALL addtaskifauthorized(130051,i18n_task_transfertransactiontogeneralar,
       transfer_transaction_to_general_ar_task_id)
      IF (((istaskauthorized(transfer_transaction_to_general_ar_task_id) > 0) OR (istaskvalid(130267)
       > 0)) )
       CALL addtasktotasklist2(i18n_task_transfertransaction,transfer_transaction_task_id,true)
      ENDIF
     OF entity_business_account_transaction:
      CALL addtaskifauthorized(130052,i18n_task_transfertransactiontopatientar,
       transfer_transaction_to_patient_ar_task_id)
      IF (((istaskauthorized(transfer_transaction_to_patient_ar_task_id) > 0) OR (istaskvalid(130267)
       > 0)) )
       CALL addtasktotasklist2(i18n_task_transfertransaction,transfer_transaction_task_id,true)
      ENDIF
      CALL addtaskifauthorized2(130047,i18n_task_reversetransaction,reverse_transaction_task_id,true)
      CALL addtaskifauthorized(130024,i18n_task_modifyglalias,modify_gl_alias_task_id)
     OF entity_statement:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130010,i18n_task_applycomment,apply_comment_task_id)
      CALL addtaskifauthorized(130028,i18n_task_openbillrecordbrowser,open_bill_record_browser_task)
      CALL addtaskifauthorized(130034,i18n_task_openstatement,open_statement_task_id)
      CALL addtasktotasklist(i18n_task_addimage,add_image_task_id)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_workflow_item:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130091,i18n_task_identifyissue,identify_issue_task_id)
      CALL addtaskifauthorized2(130022,i18n_task_manualrelease,manual_release_task_id2,true)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
      CALL addtaskifauthorized(130040,i18n_task_releasewithfollowup,release_with_follow_up_task_id)
      CALL addtaskifauthorized(130111,i18n_task_openfirstnet,open_first_net_task_id)
      CALL addtaskifauthorized(130112,i18n_task_opensurginet,open_surgi_net_task_id)
      CALL addtaskifauthorized(130113,i18n_task_openpowerchart,open_power_chart_task_id)
      CALL addtaskifauthorized2(130329,i18n_task_reprioritize,reprioritize_task_id,true)
      CALL addshowpatientdemographicstasks(0)
     OF entity_workflow_follow_up:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130022,i18n_task_manualrelease,manual_release_task_id2,true)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
      CALL addtaskifauthorized(130040,i18n_task_releasewithfollowup,release_with_follow_up_task_id)
     OF entity_workflow_summary:
      CALL addtaskifauthorized(130038,i18n_task_redistributeworkflow,redistribute_workflow__task_id)
      CALL addtaskifauthorized(130038,i18n_task_redistributeallworkflow,
       redistribute_all_workflow__task_id)
     OF entity_workflow_module:
      CALL addtaskifauthorized(130038,i18n_task_redistributeallworkflow,
       redistribute_all_workflow__task_id)
     OF entity_image:
      CALL addimagetasks(0)
      CALL addtasktotasklist(i18n_task_manageimages,manage_images_task_id)
     OF entity_schevent:
     OF entity_referral:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
     OF entity_schentry:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
     OF entity_person:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
     OF entity_billing_entity:
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
      CALL addtaskifauthorized2(130232,i18n_task_hardclose,hard_close_task_id,true)
     OF entity_tenant:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized(130091,i18n_task_identifyissue,identify_issue_task_id)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
     OF entity_account:
      CALL addtaskifauthorized2(130094,i18n_task_applyactioncode,apply_action_code_task_id2,true)
      CALL addtaskifauthorized2(130105,i18n_task_reassignworkflowitem,reassign_workflow_item_task_id2,
       true)
      CALL addtaskifauthorized(130091,i18n_task_identifyissue,identify_issue_task_id)
     OF entity_out_of_office:
      CALL addtaskifauthorized(130280,i18n_task_modify_out_of_office,modify_out_of_office_task_id)
      CALL addtaskifauthorized(130280,i18n_task_delete_out_of_office,delete_out_of_office_task_id)
      CALL addtaskifauthorized(130281,i18n_task_end_active_occurrence,end_active_occurrence_task_id)
     OF entity_workflow_model:
      CALL addtaskifauthorized(130302,i18n_task_modify_workflow_model,modify_workflow_model_task_id)
      CALL addtaskifauthorized(130303,i18n_task_pause_workflow_model,pause_workflow_model_task_id)
      CALL addtaskifauthorized(130304,i18n_task_resume_workflow_model,resume_workflow_model_task_id)
      CALL addtaskifauthorized(130305,i18n_task_reset_workflow_model,reset_workflow_model_task_id)
      CALL addtaskifauthorized(130306,i18n_task_cancel_workflow_model,cancel_workflow_model_task_id)
      CALL addtaskifauthorized(130307,i18n_task_start_workflow_model,start_workflow_model_task_id)
     ELSE
      RETURN(- (1))
    ENDCASE
    IF (copytaskstoreplyind=1)
     SET stat = movereclist(tasks->list,reply->tasks.tasklist,1,size(reply->tasks.tasklist,5),size(
       tasks->list,5),
      true)
    ENDIF
    RETURN(size(tasks->list,5))
  END ;Subroutine
 ENDIF
 IF (validate(istaskvalid,char(128))=char(128))
  SUBROUTINE (istaskvalid(tasknumber=i4) =i2)
    DECLARE isvalid = i2 WITH protect, noconstant(0)
    IF (tasknumber=130094)
     SET tasknumberparser = " ta.task_number in (130009,130094)"
    ELSEIF (tasknumber=130105)
     SET tasknumberparser = " ta.task_number in (130037,130105)"
    ELSE
     SET tasknumberparser = build(" ta.task_number=",tasknumber)
    ENDIF
    SELECT INTO "nl:"
     FROM task_access ta,
      application_task at,
      application_group ag,
      application_access aa
     PLAN (ta
      WHERE parser(tasknumberparser)
       AND ((ta.app_group_cd+ 0) > 0))
      JOIN (at
      WHERE at.task_number=ta.task_number
       AND at.active_ind=true)
      JOIN (ag
      WHERE (ag.position_cd=reqinfo->position_cd)
       AND ag.app_group_cd=ta.app_group_cd
       AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (aa
      WHERE aa.app_group_cd=ag.app_group_cd
       AND aa.application_number=revenue_cycle_app_number
       AND aa.active_ind=1)
     WITH nocounter, maxqual(ta,1)
    ;end select
    IF (curqual > 0)
     SET isvalid = 1
    ENDIF
    RETURN(isvalid)
  END ;Subroutine
 ENDIF
 IF (validate(isnonrcataskvalid,char(128))=char(128))
  SUBROUTINE (isnonrcataskvalid(tasknumber=i4) =i2)
    DECLARE isvalid = i2 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM task_access ta,
      application_group ag
     PLAN (ta
      WHERE ta.task_number=tasknumber
       AND ((ta.app_group_cd+ 0) > 0))
      JOIN (ag
      WHERE (ag.position_cd=reqinfo->position_cd)
       AND ag.app_group_cd=ta.app_group_cd
       AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      isvalid = 1
     WITH nocounter, maxqual(ta,1)
    ;end select
    RETURN(isvalid)
  END ;Subroutine
 ENDIF
 IF (validate(istaskauthorized,char(128))=char(128))
  SUBROUTINE (istaskauthorized(taskid=vc) =i2)
    DECLARE index = i4 WITH protect, noconstant(0)
    DECLARE lindex = i4 WITH protect, noconstant(0)
    SET index = locateval(lindex,1,size(tasks->list,5),taskid,tasks->list[lindex].taskid)
    RETURN(index)
  END ;Subroutine
 ENDIF
 IF (validate(addtaskifauthorized,char(128))=char(128))
  SUBROUTINE (addtaskifauthorized(tasknumber=i4,taskdisplayname=vc,taskid=vc) =i2)
   CALL addtaskifauthorized2(tasknumber,taskdisplayname,taskid,false)
   RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(addtaskifauthorized2,char(128))=char(128))
  SUBROUTINE (addtaskifauthorized2(tasknumber=i4,taskdisplayname=vc,taskid=vc,taskallowmultipleselect
   =i2) =i2)
    IF ( NOT (istaskvalid(tasknumber)))
     RETURN(false)
    ENDIF
    CALL addtasktotasklist2(taskdisplayname,taskid,taskallowmultipleselect)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(addtasktotasklist,char(128))=char(128))
  SUBROUTINE (addtasktotasklist(taskdisplayname=vc,taskid=vc) =i2)
   CALL addtasktotasklist2(taskdisplayname,taskid,false)
   RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(addtasktotasklist2,char(128))=char(128))
  SUBROUTINE (addtasktotasklist2(taskdisplayname=vc,taskid=vc,taskallowmultipleselect=i2) =i2)
    DECLARE taskcount = i4 WITH private, noconstant((size(tasks->list,5)+ 1))
    SET stat = alterlist(tasks->list,taskcount)
    SET tasks->list[taskcount].taskdisplayname = taskdisplayname
    SET tasks->list[taskcount].taskid = taskid
    SET tasks->list[taskcount].taskallowmultiselect = taskallowmultipleselect
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(addshowpatientdemographicstasks,char(128))=char(128))
  DECLARE addshowpatientdemographicstasks(null) = i2
  SUBROUTINE addshowpatientdemographicstasks(null)
    DECLARE conversation_builder_app_number = i4 WITH protect, constant(100002)
    DECLARE profit_conversation_task = i4 WITH protect, constant(4051611)
    DECLARE profit_conversation_task2 = i4 WITH protect, constant(4051612)
    DECLARE conversationtaskid = i4 WITH protect, noconstant(0)
    DECLARE conversation2taskid = i4 WITH protect, noconstant(0)
    DECLARE task1mapped = i2 WITH protect, noconstant(false)
    DECLARE task2mapped = i2 WITH protect, noconstant(false)
    DECLARE profitconversationtaskdescription = vc WITH protect, noconstant("")
    DECLARE profitconversationtaskdescription2 = vc WITH protect, noconstant("")
    SELECT INTO "nl:"
     FROM pm_flx_task_conv_reltn pftcr,
      pm_flx_conversation pfc
     PLAN (pftcr
      WHERE pftcr.task IN (profit_conversation_task, profit_conversation_task2)
       AND pftcr.active_ind=true)
      JOIN (pfc
      WHERE pfc.conversation_id=pftcr.conversation_id
       AND pfc.active_ind=true)
     DETAIL
      CASE (pftcr.task)
       OF profit_conversation_task:
        profitconversationtaskdescription = build2(i18n_reg," ",trim(pfc.description,3)),
        conversationtaskid = pfc.task,task1mapped = true
       OF profit_conversation_task2:
        profitconversationtaskdescription2 = build2(i18n_reg," ",trim(pfc.description,3)),
        conversation2taskid = pfc.task,task2mapped = true
      ENDCASE
     WITH nocounter
    ;end select
    IF (task1mapped
     AND ((isnonrcataskvalid(conversationtaskid)) OR (isnonrcataskvalid(
     conversation_builder_app_number))) )
     CALL addtasktotasklist(profitconversationtaskdescription,show_patient_demographics_task_id)
    ENDIF
    IF (task2mapped
     AND ((isnonrcataskvalid(conversation2taskid)) OR (isnonrcataskvalid(
     conversation_builder_app_number))) )
     CALL addtasktotasklist(profitconversationtaskdescription2,show_patient_demographics_task2_id)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addimagetasks,char(128))=char(128))
  SUBROUTINE (addimagetasks(dummyvar=i2) =i2)
    CALL addtasktotasklist(i18n_task_viewimage,view_image_task_id)
    CALL addtasktotasklist(i18n_task_deleteimage,delete_image_task_id)
    CALL addtasktotasklist(i18n_task_modifyimage,modify_image_task_id)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(reply->status_data)))
  FREE RECORD reply
  RECORD reply(
    1 hasmoreind = i2
    1 chargebatch[*]
      2 chargebatchid = f8
      2 createdprsnl = vc
      2 assignedprsnl = vc
      2 status = i2
      2 chargebatchalias = vc
      2 chargebatchdate = dq8
      2 disabledtasks[*]
        3 taskid = vc
        3 message = vc
    1 tasks
      2 tasklist[*]
        3 taskdisplayname = vc
        3 taskid = vc
        3 taskallowmultiselect = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(getstartofday,char(128))=char(128))
  SUBROUTINE (getstartofday(pdatetime=dq8) =dq8)
    RETURN(cnvtdatetime(cnvtdate(format(pdatetime,"mmddyyyy;;q")),0))
  END ;Subroutine
 ENDIF
 IF (validate(getendofday,char(128))=char(128))
  SUBROUTINE (getendofday(pdatetime=dq8) =dq8)
    RETURN(cnvtdatetime(cnvtdate(format(pdatetime,"mmddyyyy;;q")),235959))
  END ;Subroutine
 ENDIF
 CALL echo("Begin PFT_RCA_I18N_CONSTANTS.INC, version [RCBACM-17290]")
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
 IF ( NOT (validate(i18n_professional)))
  DECLARE i18n_professional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Professional","Professional"))
 ENDIF
 IF ( NOT (validate(i18n_institutional)))
  DECLARE i18n_institutional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Institutional","Institutional"))
 ENDIF
 IF ( NOT (validate(i18n_selfpay)))
  DECLARE i18n_selfpay = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.SelfPay","Self Pay"))
 ENDIF
 IF ( NOT (validate(i18n_account)))
  DECLARE i18n_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Account","Account"))
 ENDIF
 IF ( NOT (validate(i18n_appointment)))
  DECLARE i18n_appointment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Appointment","Appointment"))
 ENDIF
 IF ( NOT (validate(i18n_client_account)))
  DECLARE i18n_client_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Client Account","Client Account"))
 ENDIF
 IF ( NOT (validate(i18n_research_account)))
  DECLARE i18n_research_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Research Account","Research Account"))
 ENDIF
 IF ( NOT (validate(i18n_patient_account)))
  DECLARE i18n_patient_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Patient Account","Patient Account"))
 ENDIF
 IF ( NOT (validate(i18n_encounter)))
  DECLARE i18n_encounter = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter","Encounter"))
 ENDIF
 IF ( NOT (validate(i18n_claim)))
  DECLARE i18n_claim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim","Claim"))
 ENDIF
 IF ( NOT (validate(i18n_imeclaim)))
  DECLARE i18n_imeclaim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.IME Claim","IME Claim"))
 ENDIF
 IF ( NOT (validate(i18n_charge)))
  DECLARE i18n_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge","Charge"))
 ENDIF
 IF ( NOT (validate(i18n_guarantor)))
  DECLARE i18n_guarantor = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Guarantor","Guarantor"))
 ENDIF
 IF ( NOT (validate(i18n_statement)))
  DECLARE i18n_statement = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Statement","Statement"))
 ENDIF
 IF ( NOT (validate(i18n_payment)))
  DECLARE i18n_payment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Payment","Payment"))
 ENDIF
 IF ( NOT (validate(i18n_adjustment)))
  DECLARE i18n_adjustment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjustment","Adjustment"))
 ENDIF
 IF ( NOT (validate(i18n_ap_refund)))
  DECLARE i18n_ap_refund = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.A/P Refund","Refund"))
 ENDIF
 IF ( NOT (validate(i18n_batch)))
  DECLARE i18n_batch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Batch","Batch"))
 ENDIF
 IF ( NOT (validate(i18n_registration)))
  DECLARE i18n_registration = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Registration","Registration"))
 ENDIF
 IF ( NOT (validate(i18n_authorization)))
  DECLARE i18n_authorization = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Authorization","Authorization"))
 ENDIF
 IF ( NOT (validate(i18n_person)))
  DECLARE i18n_person = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Person","Person"))
 ENDIF
 IF ( NOT (validate(i18n_organization)))
  DECLARE i18n_organization = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Organization","Organization"))
 ENDIF
 IF ( NOT (validate(i18n_balance)))
  DECLARE i18n_balance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance","Balance"))
 ENDIF
 IF ( NOT (validate(i18n_invoice)))
  DECLARE i18n_invoice = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Invoice","Invoice"))
 ENDIF
 IF ( NOT (validate(i18n_research_invoice)))
  DECLARE i18n_research_invoice = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ResearchInvoice","Research Invoice"))
 ENDIF
 IF ( NOT (validate(i18n_client_invoice)))
  DECLARE i18n_client_invoice = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ClientInvoice","Client Invoice"))
 ENDIF
 IF ( NOT (validate(i18n_line_item)))
  DECLARE i18n_line_item = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Line Item","Line Item"))
 ENDIF
 IF ( NOT (validate(i18n_inpatient)))
  DECLARE i18n_inpatient = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Inpatient","Inpatient"))
 ENDIF
 IF ( NOT (validate(i18n_outpatient)))
  DECLARE i18n_outpatient = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Outpatient","Outpatient"))
 ENDIF
 IF ( NOT (validate(i18n_guarantor_account)))
  DECLARE i18n_guarantor_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Guarantor Account","Guarantor Account"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_in_history)))
  DECLARE i18n_encounter_in_history = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter in history","Encounter in history"))
 ENDIF
 IF ( NOT (validate(i18n_balance_status)))
  DECLARE i18n_balance_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance not ready to bill","Balance not ready to bill"))
 ENDIF
 IF ( NOT (validate(i18n_no_formal_payment_plan)))
  DECLARE i18n_no_formal_payment_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No formal payment plan assigned","No formal payment plan assigned"))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_no_guar)))
  DECLARE i18n_formal_pay_plan_no_guar = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No guarantor found for the encounter.",
    "No guarantor found for the encounter."))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_unsup_cons_method)))
  DECLARE i18n_formal_pay_plan_unsup_cons_method = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Unsupported consolidated method.","Unsupported consolidated method."))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_excluded_enc_type)))
  DECLARE i18n_formal_pay_plan_excluded_enc_type = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter type is excluded from payment plans.",
    "Encounter type is excluded from payment plans."))
 ENDIF
 IF ( NOT (validate(i18n_formal_pay_plan_invalid_sp_bal)))
  DECLARE i18n_formal_pay_plan_invalid_sp_bal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Zero or credit balance on selfpay balance.",
    "Zero or credit balance on selfpay balance."))
 ENDIF
 IF ( NOT (validate(i18n_formal_payment_plan)))
  DECLARE i18n_formal_payment_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Formal payment plan assigned","Formal payment plan assigned"))
 ENDIF
 IF ( NOT (validate(i18n_ext_formal_pay_plan)))
  DECLARE i18n_ext_formal_pay_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Formal payment plan externally managed",
    "Formal payment plan is managed externally"))
 ENDIF
 IF ( NOT (validate(i18n_hold_disable_msg)))
  DECLARE i18n_hold_disable_msg = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter has one or more holds preventing assignment",
    "Encounter has one or more holds preventing assignment"))
 ENDIF
 IF ( NOT (validate(i18n_hold_be_preference_msg)))
  DECLARE i18n_hold_be_preference_msg = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter has holds and billing entity prevent manual claim gen pref set.",
    "Encounter has holds and billing entity prevent manual claim generation preference is set."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_in_pre_collection)))
  DECLARE i18n_encounter_in_pre_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is assigned to pre-collections",
    "Encounter is assigned to pre-collections"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_in_collection)))
  DECLARE i18n_encounter_in_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is assigned to collections",
    "Encounter is assigned to collections"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_not_in_collection)))
  DECLARE i18n_encounter_not_in_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is Removed from collections",
    "Encounter is Removed from collections"))
 ENDIF
 IF ( NOT (validate(i18n_encounter_not_sent_to_collection)))
  DECLARE i18n_encounter_not_sent_to_collection = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is Not in collections","Encounter is Not in collections"))
 ENDIF
 IF ( NOT (validate(i18n_generate_claim)))
  DECLARE i18n_generate_claim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance is not ready to bill.","Balance is not ready to bill."))
 ENDIF
 IF ( NOT (validate(i18n_generate_on_demand_statement)))
  DECLARE i18n_generate_on_demand_statement = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance is not ready to bill.","Balance is not ready to bill."))
 ENDIF
 IF ( NOT (validate(i18n_credit_charge_status)))
  DECLARE i18n_credit_charge_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge previously credited","Charge previously credited"))
 ENDIF
 IF ( NOT (validate(i18n_write_off_charge_status)))
  DECLARE i18n_write_off_charge_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge previously written off","Charge previously written off"))
 ENDIF
 IF ( NOT (validate(i18n_write_off_charge_credit_status)))
  DECLARE i18n_write_off_charge_credit_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.A credited charge cannot be written off",
    "A credited charge cannot be written off"))
 ENDIF
 IF ( NOT (validate(i18n_apply_comment_status)))
  DECLARE i18n_apply_comment_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Comment cannot be applied to a denial",
    "Comment cannot be applied to a denial"))
 ENDIF
 IF ( NOT (validate(i18n_transaction_transfered)))
  DECLARE i18n_transaction_transfered = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transaction previously transfered","Transaction previously transfered"))
 ENDIF
 IF ( NOT (validate(i18n_reverse_trns_for_pay_adj_trans)))
  DECLARE i18n_reverse_trns_for_pay_adj_trans = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Reversal transactions cannot be transferred",
    "Reversal transactions cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_reverse_trns_for_pay_adj_reverse)))
  DECLARE i18n_reverse_trns_for_pay_adj_reverse = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Reversal transactions cannot be reversed",
    "Reversal transactions cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_bad_deb_recovery_adj)))
  DECLARE i18n_bad_deb_recovery_adj = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bad debt recovery cannot be manually transferred",
    "Bad debt recovery cannot be manually transferred"))
 ENDIF
 IF ( NOT (validate(i18n_bad_deb_reversal_adj)))
  DECLARE i18n_bad_deb_reversal_adj = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bad debt reversal cannot be transferred",
    "Bad debt reversal cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_bad_deb_reversal_rev)))
  DECLARE i18n_bad_deb_reversal_rev = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bad debt reversal cannot be reversed",
    "Bad debt reversal cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_reversal_bankruptcy_writeoff)))
  DECLARE i18n_reversal_bankruptcy_writeoff = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy write-off cannot be reversed",
    "Bankruptcy write-off cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_reversal_bankruptcy_reversal)))
  DECLARE i18n_reversal_bankruptcy_reversal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy reversal cannot be reversed",
    "Bankruptcy reversal cannot be reversed"))
 ENDIF
 IF ( NOT (validate(i18n_bankruptcy_writeoff)))
  DECLARE i18n_bankruptcy_writeoff = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy write-off cannot be transferred",
    "Bankruptcy write-off cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_bankruptcy_reversal)))
  DECLARE i18n_bankruptcy_reversal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Bankruptcy reversal cannot be transferred",
    "Bankruptcy reversal cannot be transferred"))
 ENDIF
 IF ( NOT (validate(i18n_trans_already_transfered)))
  DECLARE i18n_trans_already_transfered = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transaction previously transferred","Transaction previously transferred")
   )
 ENDIF
 IF ( NOT (validate(i18n_trans_already_reversed)))
  DECLARE i18n_trans_already_reversed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transaction previously reversed","Transaction previously reversed"))
 ENDIF
 IF ( NOT (validate(i18n_no_to_balances)))
  DECLARE i18n_no_to_balances = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.There are no balances to transfer to.",
    "There are no balances to transfer to."))
 ENDIF
 IF ( NOT (validate(i18n_balance_zero)))
  DECLARE i18n_balance_zero = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is zero.","The balance is zero."))
 ENDIF
 IF ( NOT (validate(i18n_no_alias_to_modify)))
  DECLARE i18n_no_alias_to_modify = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No alias to modify","No alias to modify"))
 ENDIF
 IF ( NOT (validate(i18n_no_unbilled_late_charges)))
  DECLARE i18n_no_unbilled_late_charges = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No unbilled late charges","No unbilled late charges"))
 ENDIF
 IF ( NOT (validate(i18n_no_unbilled_charges)))
  DECLARE i18n_no_unbilled_charges = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No unbilled charges","No unbilled charges"))
 ENDIF
 IF ( NOT (validate(i18n_balance_canceled)))
  DECLARE i18n_balance_canceled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Associated balance is canceled or invalid.",
    "Associated balance is canceled or invalid."))
 ENDIF
 IF ( NOT (validate(i18n_billed_charge)))
  DECLARE i18n_billed_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge has been billed.","Charge has been billed."))
 ENDIF
 IF ( NOT (validate(i18n_selfpay_only_charge)))
  DECLARE i18n_selfpay_only_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Charge is associated to Self Pay Charge Group Only.",
    "Charge is associated to Self Pay Charge Group Only."))
 ENDIF
 IF ( NOT (validate(i18n_remittance_zero_payment)))
  DECLARE i18n_remittance_zero_payment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Remittance with a zero payment amount",
    "Remittance with a zero payment amount"))
 ENDIF
 IF ( NOT (validate(i18n_denial)))
  DECLARE i18n_denial = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Denial","Denial"))
 ENDIF
 IF ( NOT (validate(i18n_remove_charge_batch)))
  DECLARE i18n_remove_charge_batch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot delete a posted or submitted batch",
    "Cannot delete a posted or submitted batch"))
 ENDIF
 IF ( NOT (validate(i18n_unsupported_task)))
  DECLARE i18n_unsupported_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The task is unsupported.","The task is unsupported."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_adjustment_task)))
  DECLARE i18n_ime_apply_adjustment_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjustment can not be applied to IME claims.",
    "Adjustment can not be applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_comment_task)))
  DECLARE i18n_ime_apply_comment_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Comment can not be applied to IME claims.",
    "Comment can not be applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_action_code_task)))
  DECLARE i18n_ime_apply_action_code_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Action code can not applied to IME claims.",
    "Action code can not applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_ime_apply_remark_task)))
  DECLARE i18n_ime_apply_remark_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Remark can not be applied to IME claims.",
    "Remark can not be applied to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_corsp_not_cancelled)))
  DECLARE i18n_corsp_not_cancelled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Correspondence not in cancellable status.",
    "Correspondence not in cancellable status."))
 ENDIF
 IF ( NOT (validate(i18n_corsp_not_delivered)))
  DECLARE i18n_corsp_not_delivered = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Correspondence not in delivered status.",
    "Correspondence not in delivered status."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_has_baddebt_or_in_coll)))
  DECLARE i18n_encounter_has_baddebt_or_in_coll = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter has bad debt or in collections.",
    "Encounter has bad debt or in collections."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_already_combined_away)))
  DECLARE i18n_encounter_already_combined_away = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is already combined away.",
    "Encounter is already combined away."))
 ENDIF
 IF ( NOT (validate(i18n_pending_reg_mod_hold)))
  DECLARE i18n_pending_reg_mod_hold = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The pending registration modification hold cannot be released.",
    "The pending registration modification hold cannot be released."))
 ENDIF
 IF ( NOT (validate(i18n_encounter_already_packaged)))
  DECLARE i18n_encounter_already_packaged = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Encounter is already packaged.","Encounter is already packaged."))
 ENDIF
 IF ( NOT (validate(i18n_statement_cycle_is_workflow_model)))
  DECLARE i18n_statement_cycle_is_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Statement cycle is being managed by a workflow model. See Workflow view.",
    "Statement cycle is being managed by a workflow model. See Workflow view."))
 ENDIF
 IF ( NOT (validate(i18n_pharmanet_charge)))
  DECLARE i18n_pharmanet_charge = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Disabling the task as it is a PharmaNet charge.",
    "Disabling the task as it is a PharmaNet charge."))
 ENDIF
 IF ( NOT (validate(i18n_corsp_img_not_available)))
  DECLARE i18n_corsp_img_not_available = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Correspondence image is not available.",
    "Correspondence image is not available."))
 ENDIF
 IF ( NOT (validate(i18n_posted_unbilled)))
  DECLARE i18n_posted_unbilled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Posted - Unbilled","Posted - Unbilled"))
 ENDIF
 IF ( NOT (validate(i18n_posted_billed)))
  DECLARE i18n_posted_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Posted - Billed","Posted - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_posted_suppressed)))
  DECLARE i18n_posted_suppressed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Posted - Suppressed","Posted - Suppressed"))
 ENDIF
 IF ( NOT (validate(i18n_credited_billed)))
  DECLARE i18n_credited_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Credited - Billed","Credited - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_credited_suppressed)))
  DECLARE i18n_credited_suppressed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Credited - Suppressed","Credited - Suppressed"))
 ENDIF
 IF ( NOT (validate(i18n_written_off_unbilled)))
  DECLARE i18n_written_off_unbilled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Written Off - Unbilled","Written Off - Unbilled"))
 ENDIF
 IF ( NOT (validate(i18n_written_off_billed)))
  DECLARE i18n_written_off_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Written Off - Billed","Written Off - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_adjusted_unbilled)))
  DECLARE i18n_adjusted_unbilled = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjusted - Unbilled","Adjusted - Unbilled"))
 ENDIF
 IF ( NOT (validate(i18n_adjusted_billed)))
  DECLARE i18n_adjusted_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Adjusted - Billed","Adjusted - Billed"))
 ENDIF
 IF ( NOT (validate(i18n_late_debit)))
  DECLARE i18n_late_debit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Late Debit","Late Debit"))
 ENDIF
 IF ( NOT (validate(i18n_late_credit)))
  DECLARE i18n_late_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Late Credit","Late Credit"))
 ENDIF
 IF ( NOT (validate(i18n_late_debit_late_credit)))
  DECLARE i18n_late_debit_late_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Late Debit / Late Credit","Late Debit / Late Credit"))
 ENDIF
 IF ( NOT (validate(i18n_add_billing_hold)))
  DECLARE i18n_add_billing_hold = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot apply a billing hold to a self pay balance",
    "Cannot apply a billing hold to a self pay balance"))
 ENDIF
 IF ( NOT (validate(i18n_self_pay)))
  DECLARE i18n_self_pay = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Self Pay","Self Pay"))
 ENDIF
 IF ( NOT (validate(i18n_ime)))
  DECLARE i18n_ime = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.IME",
    "IME"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_primary)))
  DECLARE i18n_sequence_primary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Primary","Primary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_secondary)))
  DECLARE i18n_sequence_secondary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Secondary","Secondary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_tertiary)))
  DECLARE i18n_sequence_tertiary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Tertiary","Tertiary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_quaternary)))
  DECLARE i18n_sequence_quaternary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Quaternary","Quaternary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_quinary)))
  DECLARE i18n_sequence_quinary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Quinary","Quinary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_senary)))
  DECLARE i18n_sequence_senary = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Senary","Senary"))
 ENDIF
 IF ( NOT (validate(i18n_sequence_unknown)))
  DECLARE i18n_sequence_unknown = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Unknown","Unknown"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_cancelable)))
  DECLARE i18n_claim_not_cancelable = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in cancelable status","Claim not in cancelable status"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_replaceble)))
  DECLARE i18n_claim_not_replaceble = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in a replaceble status","Claim not in a replaceble status"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_deniable)))
  DECLARE i18n_claim_not_deniable = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in deniable status","Claim not in deniable status"))
 ENDIF
 IF ( NOT (validate(i18n_claim_not_voidable)))
  DECLARE i18n_claim_not_voidable = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Claim not in a voidable status","Claim not in a voidable status"))
 ENDIF
 IF ( NOT (validate(i18n_no_pricing_detail)))
  DECLARE i18n_no_pricing_detail = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No external identifier found for transaction. Cannot view Pricing Detail.",
    "No external identifier found for transaction. Cannot view Pricing Detail."))
 ENDIF
 IF ( NOT (validate(i18n_no_apply_remark)))
  DECLARE i18n_no_apply_remark = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Remark cannot be applied on Cancelled/Denied/Rejected claim or self",
    "Remark cannot be applied on Cancelled/Denied/Rejected claim or selfpay claims or invalid/cancelled balance."
    ))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_no_qual_chrg)))
  DECLARE i18n_move_chrg_no_qual_chrg = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.No qualifying charges on the source financial encounter.",
    "No qualifying charges on the source financial encounter."))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_no_enc_reltn)))
  DECLARE i18n_move_chrg_no_enc_reltn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.There is no relationship between selected encounters",
    "There is no relationship between selected encounters. Unable to move charges."))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_same_encntrs)))
  DECLARE i18n_move_chrg_same_encntrs = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Same source and target clinical encounters.",
    "Same source and target clinical encounters."))
 ENDIF
 IF ( NOT (validate(i18n_move_chrg_credit)))
  DECLARE i18n_move_chrg_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot move a credited charge.","Cannot move a credited charge."))
 ENDIF
 IF ( NOT (validate(i18n_modify_chrg_credit)))
  DECLARE i18n_modify_chrg_credit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot modify a credited charge.","Cannot modify a credited charge."))
 ENDIF
 IF ( NOT (validate(i18n_invalid_balance)))
  DECLARE i18n_invalid_balance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Voided","Voided"))
 ENDIF
 IF ( NOT (validate(i18n_task_system_error)))
  DECLARE i18n_task_system_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.A system error occurred.","A system error occurred."))
 ENDIF
 IF ( NOT (validate(i18n_separator_semicolon)))
  DECLARE i18n_separator_semicolon = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.SEMICOLON","; "))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_error)))
  DECLARE i18n_task_compl_bal_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to complete the balance.",
    "The system is unable to complete the balance."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_not_insurance)))
  DECLARE i18n_task_compl_bal_not_insurance = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not an insurance balance.",
    "The balance is not an insurance balance."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_invalid_status)))
  DECLARE i18n_task_compl_bal_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not currently in a status that can be set as Complete.",
    "The balance is not currently in a status that can be set as Complete."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_next_bal_invalid_status)))
  DECLARE i18n_task_compl_bal_next_bal_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The next balance in the coord of benefits cant be set to Rdy2Bill.",
    "The next balance in the coordination of benefits cannot be set to a Ready to Bill status."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_remaining_credit_amt)))
  DECLARE i18n_task_compl_bal_remaining_credit_amt = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_encntr_hist)))
  DECLARE i18n_task_compl_bal_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_claim_den_pend_rev)))
  DECLARE i18n_task_compl_bal_claim_den_pend_rev = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_compl_bal_success)))
  DECLARE i18n_task_compl_bal_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance was successfully completed.",
    "The balance was successfully completed."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_error)))
  DECLARE i18n_task_set_bal_rtb_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to set the balance as Ready to Bill.",
    "The system is unable to set the balance as Ready to Bill."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_invalid_status)))
  DECLARE i18n_task_set_bal_rtb_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not currently in a status that can be set as Ready to Bill.",
    "The balance is not currently in a status that can be set as Ready to Bill."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_remaining_credit_amt)))
  DECLARE i18n_task_set_bal_rtb_remaining_credit_amt = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_encntr_hist)))
  DECLARE i18n_task_set_bal_rtb_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_claim_den_pend_rev)))
  DECLARE i18n_task_set_bal_rtb_claim_den_pend_rev = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_rtb_success)))
  DECLARE i18n_task_set_bal_rtb_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance status was successfully set as Ready to Bill.",
    "The balance status was successfully set as Ready to Bill."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_error)))
  DECLARE i18n_task_set_bal_wpbc_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to set the balance as Waiting Prev Bal Compl",
    "The system is unable to set the balance as Waiting Previous Balance Completion."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_invalid_status)))
  DECLARE i18n_task_set_bal_wpbc_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not in a status that can be set as Waiting Prev Bal Compl",
    "The balance is not currently in a status that can be set as Waiting Previous Balance Completion."
    ))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_remaining_credit_amt)))
  DECLARE i18n_task_set_bal_wpbc_remaining_credit_amt = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_encntr_hist)))
  DECLARE i18n_task_set_bal_wpbc_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_claim_den_pend_rev)))
  DECLARE i18n_task_set_bal_wpbc_claim_den_pend_rev = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_wpbc_success)))
  DECLARE i18n_task_set_bal_wpbc_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance status was successfully set as Waiting Prev Bal Compl",
    "The balance status was successfully set as Waiting Previous Balance Completion."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_error)))
  DECLARE i18n_task_set_bal_generated_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to set the balance as Generated.",
    "The system is unable to set the balance as Generated."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_invalid_status)))
  DECLARE i18n_task_set_bal_generated_invalid_status = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance is not in a status that can be set as Waiting Prev Bal Compl",
    "The balance is not currently in a status that can be set as Waiting Previous Balance Completion."
    ))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_remaining_credit_amt)))
  DECLARE i18n_task_set_bal_generated_remaining_credit_amt = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.The balance has a remaining credit amount.",
    "The balance has a remaining credit amount."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_encntr_hist)))
  DECLARE i18n_task_set_bal_generated_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_claim_den_pend_rev)))
  DECLARE i18n_task_set_bal_generated_claim_den_pend_rev = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_no_claim)))
  DECLARE i18n_task_set_bal_generated_no_claim = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance does not currently have a valid claim.",
    "The balance does not currently have a valid claim."))
 ENDIF
 IF ( NOT (validate(i18n_task_set_bal_generated_success)))
  DECLARE i18n_task_set_bal_generated_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance status was successfully set as Generated.",
    "The balance status was successfully set as Generated."))
 ENDIF
 IF ( NOT (validate(i18n_task_generate_interim_not_available)))
  DECLARE i18n_task_generate_interim_not_available = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The task is not allowed","The task is not allowed"))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_late_charges_claim_den_pend_rev)))
  DECLARE i18n_task_bill_late_charges_claim_den_pend_rev = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The balance has a claim in a Denied Pending Review status.",
    "The balance has a claim in a Denied Pending Review status."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_late_charges_encntr_hist)))
  DECLARE i18n_task_bill_late_charges_encntr_hist = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance is associated to an encounter in history.",
    "The balance is associated to an encounter in history."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_late_charges_error)))
  DECLARE i18n_task_bill_late_charges_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The system is unable to bill late charges.",
    "The system is unable to bill late charges."))
 ENDIF
 IF ( NOT (validate(i18n_task_associate_bal_not_institutional)))
  DECLARE i18n_task_associate_bal_not_institutional = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.The balance is not an institutional balance.",
    "The balance is not an institutional balance."))
 ENDIF
 IF ( NOT (validate(i18n_task_associate_bal_already_billed)))
  DECLARE i18n_task_associate_bal_already_billed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.The intitutional balance has already been billed.",
    "The intitutional balance has already been billed."))
 ENDIF
 IF ( NOT (validate(i18n_task_associate_bal_no_professional)))
  DECLARE i18n_task_associate_bal_no_professional = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.There are no professional balances to associate to.",
    "There are no professional balances to associate to."))
 ENDIF
 IF ( NOT (validate(billing_with_professional)))
  DECLARE billing_with_professional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_with_professional","Billing With Professional"))
 ENDIF
 IF ( NOT (validate(billing_on_institutional)))
  DECLARE billing_on_institutional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_on_institutional","Billing On Institutional"))
 ENDIF
 IF ( NOT (validate(billing_with_institutional)))
  DECLARE billing_with_institutional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_with_institutional","Billing With Institutional"))
 ENDIF
 IF ( NOT (validate(billing_on_professional)))
  DECLARE billing_on_professional = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.billing_on_professional","Billing On Professional"))
 ENDIF
 IF ( NOT (validate(i18n_assoc_bal_ins_error)))
  DECLARE i18n_assoc_bal_ins_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.assocBalInsError",
    "A system error has occurred. Unable to associate balances for billing."))
 ENDIF
 IF ( NOT (validate(i18n_assoc_bal_upt_error)))
  DECLARE i18n_assoc_bal_upt_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.assocBalUptError",
    "A system error has occurred. Unable to update balance associations for billing."))
 ENDIF
 IF ( NOT (validate(i18n_assoc_bal_success)))
  DECLARE i18n_assoc_bal_success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.assocBalSuccess","Balance associations saved."))
 ENDIF
 IF ( NOT (validate(i18n_task_balance_associated_error)))
  DECLARE i18n_task_balance_associated_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance association made.","Balance association made."))
 ENDIF
 IF ( NOT (validate(i18n_uploaded_via_batch)))
  DECLARE i18n_uploaded_via_batch = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Uploaded via batch","Uploaded via batch"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_no_single_group_per_cg)))
  DECLARE i18n_task_mod_pat_resp_no_single_group_per_cg = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance must be associated to single-charge charge group",
    "Balance must be associated to single-charge charge group"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_self_pay)))
  DECLARE i18n_task_mod_pat_resp_self_pay = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Cannot modify patient responsibility for self pay balance",
    "Cannot modify patient responsibility for self pay balance"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_invalid_cg_status)))
  DECLARE i18n_task_mod_pat_resp_invalid_cg_status = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.Charge group is in an invalid status",
    "Charge group is in an invalid status"))
 ENDIF
 IF ( NOT (validate(i18n_task_mod_pat_resp_invalid_balance_status)))
  DECLARE i18n_task_mod_pat_resp_invalid_balance_status = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.Balance is in an invalid status",
    "Balance is in an invalid status"))
 ENDIF
 IF ( NOT (validate(i18n_task_image_action_unauthorized)))
  DECLARE i18n_task_image_action_unauthorized = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Image action unauthorized for user.",
    "Image action unauthorized for user."))
 ENDIF
 IF ( NOT (validate(i18n_ime_add_image_task)))
  DECLARE i18n_ime_add_image_task = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Image can not be added to IME claims.",
    "Image can not be added to IME claims."))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_submitted)))
  DECLARE i18n_view_batch_submitted = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_SUBMITTED","Waiting to Post"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_presubmit)))
  DECLARE i18n_view_batch_presubmit = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_PRESUBMIT","Pre-Submit"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_posted)))
  DECLARE i18n_view_batch_posted = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_POSTED","Posted"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_pending)))
  DECLARE i18n_view_batch_pending = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_PENDING","Open"))
 ENDIF
 IF ( NOT (validate(i18n_view_batch_errored)))
  DECLARE i18n_view_batch_errored = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.BATCH_ERRORED","In Error"))
 ENDIF
 IF ( NOT (validate(i18n_task_cancelbatchtask)))
  DECLARE i18n_task_cancelbatchtask = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.TASK_CANCEL_BATCH","Cancel Remittance"))
 ENDIF
 IF ( NOT (validate(i18n_system)))
  DECLARE i18n_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.LABEL_SYSTEM","System"))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_as_prof_error)))
  DECLARE i18n_task_bill_as_prof_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance cannot be billed as professional.",
    "Balance cannot be billed as professional."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_as_ins_error)))
  DECLARE i18n_task_bill_as_ins_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance cannot be billed as institutional.",
    "Balance cannot be billed as institutional."))
 ENDIF
 IF ( NOT (validate(i18n_task_bill_as_prof_or_ins_error)))
  DECLARE i18n_task_bill_as_prof_or_ins_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Balance is not in a status to be billed.",
    "Balance is not in a status to be billed."))
 ENDIF
 IF ( NOT (validate(i18n_refund)))
  DECLARE i18n_refund = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Refund","Refund"))
 ENDIF
 IF ( NOT (validate(i18n_refund_id)))
  DECLARE i18n_refund_id = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Refund Id","Refund Id"))
 ENDIF
 IF ( NOT (validate(i18n_refund_amt)))
  DECLARE i18n_refund_amt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Refund Amount","Refund Amount"))
 ENDIF
 IF ( NOT (validate(i18n_voided_refund_payment_desc)))
  DECLARE i18n_voided_refund_payment_desc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Payment to Offset Voided Refund, Refund Id:",
    "Payment to Offset Voided Refund, Refund Id:"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_title)))
  DECLARE i18n_reminder_title = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_TITLE","Reminder"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_title)))
  DECLARE i18n_escalation_title = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_TITLE","Escalation"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_reason_label)))
  DECLARE i18n_reminder_reason_label = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_REASON_LABEL","Reminder Reason:"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_reason_label)))
  DECLARE i18n_escalation_reason_label = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_REASON_LABEL","Escalation Reason:"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_reason_assignee)))
  DECLARE i18n_reminder_reason_assignee = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_REASON_ASSIGNEE","Reminder for assignee of work item"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_reason)))
  DECLARE i18n_escalation_reason = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_REASON","Escalation for incomplete work item"))
 ENDIF
 IF ( NOT (validate(i18n_reminder_message)))
  DECLARE i18n_reminder_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.REMINDER_MESSAGE","Reminder: Work Item Overdue"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_message)))
  DECLARE i18n_escalation_message = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_MESSAGE","Escalation: Work Item Overdue"))
 ENDIF
 IF ( NOT (validate(i18n_escalation_text)))
  DECLARE i18n_escalation_text = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ESCALATION_TEXT","ESCALATION: Work Item Overdue for"))
 ENDIF
 IF ( NOT (validate(i18n_resolver_label)))
  DECLARE i18n_resolver_label = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.RESOLVER_LABEL","Resolver:"))
 ENDIF
 IF ( NOT (validate(i18n_auto_approve_failure_workitem_description)))
  DECLARE i18n_auto_approve_failure_workitem_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.AUTO_APPROVE_FAILURE_WORKITEM_DESCRIPTION",
    "Adjustment in pending due to failure of WTP auto-approval"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_missing_payee_id_description)))
  DECLARE i18n_fsi_missing_payee_id_description = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.FSI_MISSING_PAYEE_ID_DESCRIPTION","Missing Payee Id"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_locate_logical_domain_description)))
  DECLARE i18n_fsi_fail_locate_logical_domain_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_LOCATE_LOGICAL_DOMAIN_DESCRIPTION",
    "Unable to find organization Logical domain"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_set_logical_domain_description)))
  DECLARE i18n_fsi_fail_set_logical_domain_description = vc WITH protect, constant(uar_i18ngetmessage
   (hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_SET_LOGICAL_DOMAIN_DESCRIPTION",
    "Failed to set the logical domain"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_missing_payee_and_health_plan_id_description)))
  DECLARE i18n_fsi_fail_missing_payee_and_health_plan_id_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.FSI_FAIL_MISSING_PAYEE_AND_HEALTH_PLAN_ID_DESCRIPTION",
    "Missing Payer ID and Health Plan ID"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_find_gl_ar_acct_description)))
  DECLARE i18n_fsi_fail_find_gl_ar_acct_description = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_FIND_GL_AR_ACCT_DESCRIPTION",
    "Unable to Find General A/R Account information"))
 ENDIF
 IF ( NOT (validate(i18n_fsi_fail_find_non_gl_ar_acct_description)))
  DECLARE i18n_fsi_fail_find_non_gl_ar_acct_description = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.FSI_FAIL_FIND_NON_GL_AR_ACCT_DESCRIPTION",
    "Unable to Find Non A/R GL Account information"))
 ENDIF
 CALL echo("End PFT_RCA_I18N_CONSTANTS.INC")
 IF ( NOT (validate(i18n_workflow_model)))
  DECLARE i18n_workflow_model = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.WORKFLOW_MODEL","Workflow Model: "))
 ENDIF
 IF ( NOT (validate(i18n_reset_status)))
  DECLARE i18n_reset_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.RESET_STATUS","model has been Reset."))
 ENDIF
 IF ( NOT (validate(i18n_resume_status)))
  DECLARE i18n_resume_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.RESUME_STATUS","model has been Resumed."))
 ENDIF
 IF ( NOT (validate(i18n_pause_status)))
  DECLARE i18n_pause_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.PAUSE_STATUS","model has been Paused."))
 ENDIF
 IF ( NOT (validate(i18n_cancel_status)))
  DECLARE i18n_cancel_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.CANCEL_STATUS","model has been Cancelled."))
 ENDIF
 IF ( NOT (validate(i18n_complete_status)))
  DECLARE i18n_complete_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.COMPLETE_STATUS","model completed."))
 ENDIF
 IF ( NOT (validate(i18n_workflow_event)))
  DECLARE i18n_workflow_event = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.WORKFLOW_EVENT","Workflow Event : "))
 ENDIF
 IF ( NOT (validate(i18n_error_cancelling_workflow)))
  DECLARE i18n_error_cancelling_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_CANCELLING_WORKFLOW","Workflow Error Occurred Cancelling Workflow")
   )
 ENDIF
 IF ( NOT (validate(i18n_error_resetting_workflow)))
  DECLARE i18n_error_resetting_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_RESETTING_WORKFLOW","Workflow Error Occurred Resetting Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_resuming_workflow)))
  DECLARE i18n_error_resuming_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_RESUMING_WORKFLOW","Workflow Error Occurred Resuming Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_pausing_workflow)))
  DECLARE i18n_error_pausing_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_PAUSING_WORKFLOW","Workflow Error Occurred Pausing Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_starting_workflow)))
  DECLARE i18n_error_starting_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_STARTING_WORKFLOW","Workflow Error Occurred Starting Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_progressing_workflow)))
  DECLARE i18n_error_progressing_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_PROGRESSING_WORKFLOW",
    "Workflow Error Occurred Progressing Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_error_publishing_workflow)))
  DECLARE i18n_error_publishing_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_PUBLISHING_WORKFLOW","Workflow Error Occurred Publishing Workflow")
   )
 ENDIF
 IF ( NOT (validate(i18n_error_handling_workflow)))
  DECLARE i18n_error_handling_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.ERROR_HANDLING_WORKFLOW","Workflow Error Occurred Handling Workflow"))
 ENDIF
 IF ( NOT (validate(i18n_autoactionerror_handling_workflow)))
  DECLARE i18n_autoactionerror_handling_workflow = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.AUTOACTIONERROR_HANDLING_WORKFLOW","Automated Action Error"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_default_description)))
  DECLARE i18n_workflow_error_default_description = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.WORKFLOW_ERROR_DEFAULT_DESCRIPTION",
    "Workflow Action Error Occurred"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_default_comment)))
  DECLARE i18n_workflow_error_default_comment = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.WORKFLOW_ERROR_DEFAULT_COMMENT","Model Unidentified"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_cancel_resolution)))
  DECLARE i18n_workflow_error_cancel_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_CANCEL_RESOLUTION",
    "Manually cancel the workflow using the cancel task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_pause_resolution)))
  DECLARE i18n_workflow_error_pause_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_PAUSE_RESOLUTION",
    "Manually pause the workflow using the pause task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_progress_resolution)))
  DECLARE i18n_workflow_error_progress_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_PROGRESS_RESOLUTION",
    "Manually cancel the workflow, then use the Identify Work item functionality to identify the next work item in the flow"
    ))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_publish_resolution)))
  DECLARE i18n_workflow_error_publish_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_PUBLISH_RESOLUTION",
    "Manually start the workflow using the Identify Work Item functionality"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_reset_resolution)))
  DECLARE i18n_workflow_error_reset_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_RESET_RESOLUTION",
    "Manually reset the workflow using the reset task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_resume_resolution)))
  DECLARE i18n_workflow_error_resume_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_RESUME_RESOLUTION",
    "Manually resume the workflow using the resume task"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_start_resolution)))
  DECLARE i18n_workflow_error_start_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_START_RESOLUTION",
    "Manually start the workflow using the Identify Work Item functionalilty"))
 ENDIF
 IF ( NOT (validate(i18n_workflow_error_handle_resolution)))
  DECLARE i18n_workflow_error_handle_resolution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKFLOW_ERROR_HANDLE_RESOLUTION","Handle Error Resolution Text."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_down)))
  DECLARE i18n_pharmacy_claim_server_down = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_DOWN",
    "Pharmacy claims query service is down or not responding."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_returned_invalid)))
  DECLARE i18n_pharmacy_claim_server_returned_invalid = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_RETURNED_INVALID",
    "Pharmacy claims server returned invalid claims."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_error)))
  DECLARE i18n_pharmacy_claim_server_error = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_ERROR",
    "Pharmacy claims server failed with error : "))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_creation_failed)))
  DECLARE i18n_faux_claim_creation_failed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CREATION_FAILED","Creation of faux claim returned error."
    ))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_canceled_failed)))
  DECLARE i18n_faux_claim_canceled_failed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CANCELED_FAILED",
    "Cancelling a faux claim returned error."))
 ENDIF
 IF ( NOT (validate(i18n_balance_status_update_failed)))
  DECLARE i18n_balance_status_update_failed = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_BALANCE_STATUS_UPDATE_FAILED",
    "Failed to update the balance status to generated."))
 ENDIF
 IF ( NOT (validate(i18n_health_plans_not_matched)))
  DECLARE i18n_health_plans_not_matched = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_HEALTH_PLANS_NOT_MATCHED",
    "Health plans on pharmacy claims did not match with that on encounter."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_down_resolution)))
  DECLARE i18n_pharmacy_claim_server_down_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_DOWN_RESOLUTION",
    "Verify if Pharmacy claims server is running."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_returned_invalid_resolution)))
  DECLARE i18n_pharmacy_claim_server_returned_invalid_resolution = vc WITH protect, constant(
   uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_RETURNED_INVALID_RESOLUTION",
    "Verify if the external master event id sent to Pharmacy claims server is valid."))
 ENDIF
 IF ( NOT (validate(i18n_pharmacy_claim_server_error_resolution)))
  DECLARE i18n_pharmacy_claim_server_error_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_PHARMACY_CLAIM_SERVER_ERROR_RESOLUTION",
    "Pharmacy claims server is throwing an error that has to be resolved."))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_creation_failed_resolution)))
  DECLARE i18n_faux_claim_creation_failed_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CREATION_FAILED_RESOLUTION",
    "Verify if the claims returned from pharmacy server are valid."))
 ENDIF
 IF ( NOT (validate(i18n_faux_claim_canceled_failed_resolution)))
  DECLARE i18n_faux_claim_canceled_failed_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_FAUX_CLAIM_CANCELED_FAILED_RESOLUTION",
    "Verify if the claim status is valid for canceling."))
 ENDIF
 IF ( NOT (validate(i18n_balance_status_update_failed_resolution)))
  DECLARE i18n_balance_status_update_failed_resolution = vc WITH protect, constant(uar_i18ngetmessage
   (hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_BALANCE_STATUS_UPDATE_FAILED_RESOLUTION",
    "Verify if the balance is in valid state."))
 ENDIF
 IF ( NOT (validate(i18n_health_plans_not_matched_resolution)))
  DECLARE i18n_health_plans_not_matched_resolution = vc WITH protect, constant(uar_i18ngetmessage(
    hi18n,"PFT_RCA_I18N_CONSTANTS.I18N_HEALTH_PLANS_NOT_MATCHED_RESOLUTION",
    "Verify if all the health plans are added to the encounter."))
 ENDIF
 IF ( NOT (validate(i18n_actioncode_alias_inuse)))
  DECLARE i18n_actioncode_alias_inuse = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ACTIONCODE_ALIAS_INUSE",
    "The alias is already in use. Please enter a unique alias."))
 ENDIF
 IF ( NOT (validate(i18n_actioncode_name_inuse)))
  DECLARE i18n_actioncode_name_inuse = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ACTIONCODE_NAME_INUSE",
    "The name is already in use. Please enter a unique name."))
 ENDIF
 IF ( NOT (validate(i18n_workitem_workflow_status)))
  DECLARE i18n_workitem_workflow_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_WORKITEM_WORKFLOW_STATUS","WorkItem with Workflow Status"))
 ENDIF
 IF ( NOT (validate(i18n_assigned_from)))
  DECLARE i18n_assigned_from = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ASSIGNED_FROM","Assigned from"))
 ENDIF
 IF ( NOT (validate(i18n_assigned_to)))
  DECLARE i18n_assigned_to = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ASSIGNED_TO","Assigned to"))
 ENDIF
 IF ( NOT (validate(i18n_final_coding_upt)))
  DECLARE i18n_final_coding_upt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_FINAL_CODING_UPT",
    "Final coding has been updated after billing has been initiated. Please review to ensure the proper DRG."
    ))
 ENDIF
 IF ( NOT (validate(i18n_other)))
  DECLARE i18n_other = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.OTHER","Other"))
 ENDIF
 IF ( NOT (validate(i18n_adjustmentapproval)))
  DECLARE i18n_adjustmentapproval = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ADJUSTMENTAPPROVAL","Adjustment Approval"))
 ENDIF
 IF ( NOT (validate(i18n_statementgeneration)))
  DECLARE i18n_statementgeneration = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_STATEMENTGENERATION","Statement Generation"))
 ENDIF
 IF ( NOT (validate(i18n_assign_fpp_by_external_system)))
  DECLARE i18n_assign_fpp_by_external_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_ASSIGN_FPP_BY_EXTERNAL_SYSTEM","Formal payment plan assigned by :"))
 ENDIF
 IF ( NOT (validate(i18n_modify_fpp_by_external_system)))
  DECLARE i18n_modify_fpp_by_external_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_MODIFY_FPP_BY_EXTERNAL_SYSTEM","Formal payment plan modified by :"))
 ENDIF
 IF ( NOT (validate(i18n_remove_fpp_by_external_system)))
  DECLARE i18n_remove_fpp_by_external_system = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_REMOVE_FPP_BY_EXTERNAL_SYSTEM","Formal payment plan removed by :"))
 ENDIF
 IF ( NOT (validate(i18n_stmtsuppressionaddedforextfpp)))
  DECLARE i18n_stmtsuppressionaddedforextfpp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_STMTSUPPRESSIONADDEDFOREXTFPP",
    "Statement Suppression Billing Hold applied."))
 ENDIF
 IF ( NOT (validate(i18n_stmtsuppressionremovedforextfpp)))
  DECLARE i18n_stmtsuppressionremovedforextfpp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_STMTSUPPRESSIONREMOVEDFOREXTFPP",
    "Statement Suppression Billing Hold removed."))
 ENDIF
 IF ( NOT (validate(i18n_extfppassignedforenc)))
  DECLARE i18n_extfppassignedforenc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_EXTFPPASSIGNEDFORENC",
    "External Payment Plan assigned for encounter."))
 ENDIF
 IF ( NOT (validate(i18n_task_send_bal_to_collections)))
  DECLARE i18n_task_send_bal_to_collections = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_TASK_SEND_BAL_TO_COLLECTIONS",
    "Cannot send balance to collection as dunning track is not at balance level"))
 ENDIF
 IF ( NOT (validate(i18n_task_modifystatementcycle_bal)))
  DECLARE i18n_task_modifystatementcycle_bal = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.I18N_TASK_MODIFYSTATEMENTCYCLE_BAL",
    "Cannot apply statement cycle to balance as dunning track is not at balance level"))
 ENDIF
 IF ( NOT (validate(i18n_transfer_of)))
  DECLARE i18n_transfer_of = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.Transfer of","Transfer of"))
 ENDIF
 IF ( NOT (validate(i18n_with_alias)))
  DECLARE i18n_with_alias = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.with alias","with alias"))
 ENDIF
 IF ( NOT (validate(i18n_originally_posted)))
  DECLARE i18n_originally_posted = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.originally posted","originally posted"))
 ENDIF
 IF ( NOT (validate(i18n_with_posted_date_of)))
  DECLARE i18n_with_posted_date_of = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.with a posted date of","with a posted date of"))
 ENDIF
 IF ( NOT (validate(i18n_for_amount_of)))
  DECLARE i18n_for_amount_of = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.for the amount of","for the amount of"))
 ENDIF
 IF ( NOT (validate(i18n_from_account)))
  DECLARE i18n_from_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.from account","from account"))
 ENDIF
 IF ( NOT (validate(i18n_to_account)))
  DECLARE i18n_to_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.to account","to account"))
 ENDIF
 IF ( NOT (validate(i18n_health_plan)))
  DECLARE i18n_health_plan = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.health plan","health plan"))
 ENDIF
 IF ( NOT (validate(i18n_performed_by)))
  DECLARE i18n_performed_by = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "PFT_RCA_I18N_CONSTANTS.performed by","performed by"))
 ENDIF
 IF ( NOT (validate(i18n_on)))
  DECLARE i18n_on = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"PFT_RCA_I18N_CONSTANTS.on",
    "on"))
 ENDIF
 IF ((request->maxlistsize > 0))
  DECLARE cap = i4 WITH protect, constant(request->maxlistsize)
 ELSE
  DECLARE cap = i4 WITH protect, constant(25)
 ENDIF
 DECLARE cap_plus_1 = i4 WITH protect, constant((cap+ 1))
 IF ( NOT (validate(batchfilterclause)))
  DECLARE batchfilterclause = vc WITH protect, noconstant("1=1")
 ENDIF
 IF ( NOT (validate(cntbatch)))
  DECLARE cntbatch = i4 WITH protect, noconstant(0)
 ENDIF
 SET batchfilterclause = "1=1"
 IF ((request->filter.batchstatusind=1))
  CASE (request->filter.batchstatus)
   OF 1:
    SET batchfilterclause = concat(" c.status_cd = ",cnvtstring(uar_get_code_by("MEANING",4002322,
       "PENDING")))
   OF 2:
    SET batchfilterclause = concat(" c.status_cd = ",cnvtstring(uar_get_code_by("MEANING",4002322,
       "FAILED")))
   OF 3:
    SET batchfilterclause = concat(" c.status_cd = ",cnvtstring(uar_get_code_by("MEANING",4002322,
       "SUBMITTED")))
   OF 4:
    SET batchfilterclause = concat(" c.status_cd = ",cnvtstring(uar_get_code_by("MEANING",4002322,
       "POSTED")))
   ELSE
    SET batchfilterclause = concat(" c.status_cd = ",cnvtstring(uar_get_code_by("MEANING",4002322,
       "LOCKED")))
  ENDCASE
 ENDIF
 IF ((request->filter.batchstartdateind=1))
  IF (batchfilterclause != "1=1")
   SET batchfilterclause = concat(batchfilterclause," and ")
  ELSE
   SET batchfilterclause = " "
  ENDIF
  SET batchfilterclause = concat(batchfilterclause,
   " c.batch_dt_tm >= cnvtdatetime(getStartOfDay(request->filter->batchStartDate))")
 ENDIF
 IF ((request->filter.batchenddateind=1))
  IF (batchfilterclause != "1=1")
   SET batchfilterclause = concat(batchfilterclause," and ")
  ELSE
   SET batchfilterclause = " "
  ENDIF
  SET batchfilterclause = concat(batchfilterclause,
   " c.batch_dt_tm <= cnvtdatetime(getEndOfDay(request->filter->batchEndDate))")
 ENDIF
 IF ((request->filter.batchaliasind=1))
  IF (batchfilterclause != "1=1")
   SET batchfilterclause = concat(batchfilterclause," and ")
  ELSE
   SET batchfilterclause = " "
  ENDIF
  SET batchfilterclause = concat(batchfilterclause," c.batch_alias = request->filter->batchAlias")
 ENDIF
 IF ((request->filter.createdstartdateind=1))
  IF (batchfilterclause != "1=1")
   SET batchfilterclause = concat(batchfilterclause," and ")
  ELSE
   SET batchfilterclause = " "
  ENDIF
  SET batchfilterclause = concat(batchfilterclause,
   " c.created_dt_tm >= cnvtdatetime(getStartOfDay(request->filter->createdStartDate))")
 ENDIF
 IF ((request->filter.createdenddateind=1))
  IF (batchfilterclause != "1=1")
   SET batchfilterclause = concat(batchfilterclause," and ")
  ELSE
   SET batchfilterclause = " "
  ENDIF
  SET batchfilterclause = concat(batchfilterclause,
   " c.created_dt_tm >= cnvtdatetime(getEndOfDay(request->filter->createdEndDate))")
 ENDIF
 CALL beginservice("311173.004")
 CALL logmessage("Main","Begining main processing",log_debug)
 CALL getauthorizedtasksforentity(entity_charge_batch,request->authorizedtasksind)
 CALL echo(build("batchFilterClause: ",batchfilterclause))
 SELECT INTO "nl:"
  FROM charge_batch c,
   prsnl p1,
   prsnl p2
  PLAN (c
   WHERE (c.assigned_prsnl_id=request->prsnlid)
    AND parser(batchfilterclause)
    AND c.user_defined_ind=1
    AND c.active_ind=1)
   JOIN (p1
   WHERE p1.person_id=c.assigned_prsnl_id)
   JOIN (p2
   WHERE p2.person_id=c.created_prsnl_id)
  ORDER BY c.charge_batch_id
  HEAD c.charge_batch_id
   cntbatch += 1
   IF (cntbatch <= cap)
    IF (mod(cntbatch,10)=1)
     stat = alterlist(reply->chargebatch,(cntbatch+ 9))
    ENDIF
    reply->chargebatch[cntbatch].chargebatchid = c.charge_batch_id
    IF (uar_get_code_meaning(c.status_cd)="PENDING")
     reply->chargebatch[cntbatch].status = 1
    ELSEIF (uar_get_code_meaning(c.status_cd)="FAILED")
     reply->chargebatch[cntbatch].status = 2
    ELSEIF (uar_get_code_meaning(c.status_cd)="SUBMITTED")
     reply->chargebatch[cntbatch].status = 3
    ELSEIF (uar_get_code_meaning(c.status_cd)="POSTED")
     reply->chargebatch[cntbatch].status = 4
    ELSEIF (uar_get_code_meaning(c.status_cd)="LOCKED")
     reply->chargebatch[cntbatch].status = 5
    ENDIF
    reply->chargebatch[cntbatch].chargebatchalias = c.batch_alias, reply->chargebatch[cntbatch].
    chargebatchdate = c.batch_dt_tm, reply->chargebatch[cntbatch].assignedprsnl = p1
    .name_full_formatted,
    reply->chargebatch[cntbatch].createdprsnl = p2.name_full_formatted
    IF ((((reply->chargebatch[cntbatch].status=3)) OR ((reply->chargebatch[cntbatch].status=4))) )
     CALL adddisabledtask(cntbatch,remove_charge_batch_task_id,i18n_remove_charge_batch),
     CALL adddisabledtask(cntbatch,lock_charge_batch_task_id,i18n_task_lockchargebatch),
     CALL adddisabledtask(cntbatch,unlock_charge_batch_task_id,i18n_task_unlockchargebatch)
    ELSEIF ((reply->chargebatch[cntbatch].status=5))
     CALL adddisabledtask(cntbatch,lock_charge_batch_task_id,i18n_task_lockchargebatch)
    ELSE
     CALL adddisabledtask(cntbatch,unlock_charge_batch_task_id,i18n_task_unlockchargebatch)
    ENDIF
   ELSE
    reply->hasmoreind = true
   ENDIF
  WITH nocounter, maxqual(c,value(cap_plus_1))
 ;end select
 IF (cntbatch > cap)
  SET cntbatch = cap
 ENDIF
 SET stat = alterlist(reply->chargebatch,cntbatch)
 IF (size(reply->chargebatch,5) <= 0)
  CALL exitservicenodata("No batches exist",go_to_exit_script)
 ENDIF
 CALL exitservicesuccess("Exiting script")
 SUBROUTINE (adddisabledtask(batchidx=i4,taskid=vc,pmessage=vc) =null)
   IF (istaskauthorized(taskid) > 0)
    SET dtcnt = (size(reply->chargebatch[batchidx].disabledtasks,5)+ 1)
    SET stat = alterlist(reply->chargebatch[batchidx].disabledtasks,dtcnt)
    SET reply->chargebatch[batchidx].disabledtasks[dtcnt].taskid = taskid
    SET reply->chargebatch[batchidx].disabledtasks[dtcnt].message = pmessage
   ENDIF
 END ;Subroutine
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
