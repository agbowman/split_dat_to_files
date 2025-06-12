CREATE PROGRAM afc_add_bill_item_modifier_his:dba
 IF ( NOT (validate(afc_add_bill_item_mod_hist_script_vrsn)))
  DECLARE afc_add_bill_item_mod_hist_script_vrsn = vc WITH constant("464331.000"), private
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
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
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
 CALL beginservice(afc_add_bill_item_mod_hist_script_vrsn)
 IF (validate(reply->bill_item_modifier_hist_qual,999)=999)
  RECORD reply(
    1 bill_item_modifier_hist_qual = i2
    1 bill_item_modifier_hist[*]
      2 bill_item_modifier_hist_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF (validate(createbillitemmodhistory,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF ((validate(invalid_argument,- (1))=- (1)))
  DECLARE invalid_argument = i2 WITH protect, constant(21)
 ENDIF
 IF ((validate(default_updt_applctx,- (1.0))=- (1.0)))
  DECLARE default_updt_applctx = f8 WITH protect, constant(951001.0)
 ENDIF
 IF ((validate(default_updt_task,- (1.0))=- (1.0)))
  DECLARE default_updt_task = f8 WITH protect, constant(951001.0)
 ENDIF
 IF ( NOT (validate(cs48_recsts_active)))
  DECLARE cs48_recsts_active = f8 WITH protect, constant(getcodevalue(48,nullterm("ACTIVE"),0))
 ENDIF
 IF ( NOT (validate(billcode_type_cd)))
  DECLARE billcode_type_cd = f8 WITH protect, constant(getcodevalue(13019,nullterm("BILL CODE"),0))
 ENDIF
 IF ( NOT (validate(addon_type_cd)))
  DECLARE addon_type_cd = f8 WITH protect, constant(getcodevalue(13019,nullterm("ADD ON"),0))
 ENDIF
 IF ( NOT (validate(chargepoint_type_cd)))
  DECLARE chargepoint_type_cd = f8 WITH protect, constant(getcodevalue(13019,nullterm("CHARGE POINT"),
    0))
 ENDIF
 IF ( NOT (validate(workload_type_cd)))
  DECLARE workload_type_cd = f8 WITH protect, constant(getcodevalue(13019,nullterm("WORKLOAD"),0))
 ENDIF
 IF ( NOT (validate(bill_item_entity_name)))
  DECLARE bill_item_entity_name = vc WITH protect, constant(trim("BILL_ITEM",7))
 ENDIF
 IF ( NOT (validate(workload_code_entity_name)))
  DECLARE workload_code_entity_name = vc WITH protect, constant(trim("WORKLOAD_CODE",7))
 ENDIF
 IF ( NOT (validate(code_value_entity_name)))
  DECLARE code_value_entity_name = vc WITH protect, constant(trim("CODE_VALUE",7))
 ENDIF
 IF ( NOT (validate(default_end_date_time)))
  DECLARE default_end_date_time = dq8 WITH protect, constant(cnvtdatetime(nullterm(
     "31-DEC-2100 23:59:59")))
 ENDIF
 DECLARE table_name = vc WITH protect, constant("BILL_ITEM_MODIFIER_HIST")
 IF ( NOT (validate(script_name)))
  DECLARE script_name = vc WITH protect, constant("AFC_ADD_BILL_ITEM_MODIFIER_HIS")
 ENDIF
 IF ((validate(failed,- (1))=- (1)))
  DECLARE failed = i2 WITH noconstant(0)
 ENDIF
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF ( NOT (validate(lmessage)))
  DECLARE lmessage = vc WITH protect, noconstant("")
 ENDIF
 SET reply->bill_item_modifier_hist_qual = request->bill_item_modifier_hist_qual
 CALL createbillitemmodhistory(null)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL exitservicesuccess(build(" version : ",afc_add_bill_item_mod_hist_script_vrsn))
 ELSE
  CASE (failed)
   OF invalid_argument:
    SET reply->status_data.subeventstatus[1].operationname = "INVALID_ARGUMENT"
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->bill_item_modifier_hist_qual = 0
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(table_name)
  SET reqinfo->commit_ind = false
 ENDIF
 SUBROUTINE (createbillitemmodhistory(dummyvar=i4) =null)
   IF ( NOT (validate(add_bill_item_mod_his_sub_name)))
    DECLARE add_bill_item_mod_his_sub_name = vc WITH protect, constant(
     "AFC_ADD_BILL_ITEM_MODIFIER_HIS.createBillItemModHistory")
   ENDIF
   DECLARE index = i4 WITH protect, noconstant(0)
   IF (size(request->bill_item_modifier_hist_qual,5) > 0)
    IF ((validate(insert_begin,- (1))=- (1)))
     DECLARE insert_begin = i2 WITH private, constant(1)
    ENDIF
    IF ((validate(insert_end,- (1))=- (1)))
     DECLARE insert_end = i2 WITH private, constant(request->bill_item_modifier_hist_qual)
    ENDIF
    IF ((validate(new_bill_item_mod_hist_nbr,- (1))=- (1)))
     DECLARE new_bill_item_mod_hist_nbr = f8 WITH protect, noconstant(0.0)
    ENDIF
    FOR (index = insert_begin TO insert_end)
      SELECT INTO "nl:"
       y = seq(pft_activity_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_bill_item_mod_hist_nbr = cnvtreal(y)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       SET lmessage = uar_i18nbuildmessage(i18nhandle,"bimhKey_BillItemModHistId",
        "Generated BILL_ITEM_MOD_HIST_ID is [ %1 ]","d",new_bill_item_mod_hist_nbr)
       CALL logmessage(add_bill_item_mod_his_sub_name,lmessage,log_debug)
      ENDIF
      IF (validate(request->bill_item_modifier_hist[index].bill_item_mod_id,0.0) <= 0.0)
       SET failed = invalid_argument
       SET lmessage = uar_i18nbuildmessage(i18nhandle,"bimhKey_InvalidParam_1",
        "Invalid Argument %1 [ %2 ]","sd",nullterm("BILL_ITEM_MOD_ID"),
        request->bill_item_modifier_hist[index].bill_item_mod_id)
       CALL logmessage(add_bill_item_mod_his_sub_name,lmessage,log_error)
       GO TO check_error
      ELSEIF (validate(request->bill_item_modifier_hist[index].bill_item_id,0.0) <= 0.0)
       SET failed = invalid_argument
       SET lmessage = uar_i18nbuildmessage(i18nhandle,"bimhKey_InvalidParam_1",
        "Invalid Argument %1 [ %2 ]","sd",nullterm("BILL_ITEM_ID"),
        request->bill_item_modifier_hist[index].bill_item_id)
       CALL logmessage(add_bill_item_mod_his_sub_name,lmessage,log_error)
       GO TO check_error
      ELSE
       INSERT  FROM bill_item_modifier_hist bmih
        SET bmih.bill_item_modifier_hist_id = new_bill_item_mod_hist_nbr, bmih.bill_item_mod_id =
         validate(request->bill_item_modifier_hist[index].bill_item_mod_id,0.0), bmih.bill_item_id =
         validate(request->bill_item_modifier_hist[index].bill_item_id,0.0),
         bmih.bill_item_type_cd = validate(request->bill_item_modifier_hist[index].bill_item_type_cd,
          0.0), bmih.key1 = request->bill_item_modifier_hist[index].key1, bmih.key2 = request->
         bill_item_modifier_hist[index].key2,
         bmih.key3 = request->bill_item_modifier_hist[index].key3, bmih.key4 = request->
         bill_item_modifier_hist[index].key4, bmih.key5 = request->bill_item_modifier_hist[index].
         key5,
         bmih.key6 = request->bill_item_modifier_hist[index].key6, bmih.key7 = request->
         bill_item_modifier_hist[index].key7, bmih.key8 = request->bill_item_modifier_hist[index].
         key8,
         bmih.key9 = request->bill_item_modifier_hist[index].key9, bmih.key10 = request->
         bill_item_modifier_hist[index].key10, bmih.key11 = request->bill_item_modifier_hist[index].
         key11,
         bmih.key12 = request->bill_item_modifier_hist[index].key12, bmih.key13 = request->
         bill_item_modifier_hist[index].key13, bmih.key14 = request->bill_item_modifier_hist[index].
         key14,
         bmih.key15 = request->bill_item_modifier_hist[index].key15, bmih.key1_entity_name =
         nullcheck(
          IF (validate(request->bill_item_modifier_hist[index].bill_item_type_cd,addon_type_cd)=
          addon_type_cd) bill_item_entity_name
          ELSE code_value_entity_name
          ENDIF
          ,request->bill_item_modifier_hist[index].key1_entity_name,
          IF (trim(validate(request->bill_item_modifier_hist[index].key1_entity_name,""),7)="") 0
          ELSE 1
          ENDIF
          ), bmih.key2_entity_name = nullcheck(
          IF (validate(request->bill_item_modifier_hist[index].bill_item_type_cd,billcode_type_cd)=
          billcode_type_cd) ""
          ELSE code_value_entity_name
          ENDIF
          ,request->bill_item_modifier_hist[index].key2_entity_name,
          IF (trim(validate(request->bill_item_modifier_hist[index].key2_entity_name,""),7)="") 0
          ELSE 1
          ENDIF
          ),
         bmih.key3_entity_name = nullcheck(
          IF (validate(request->bill_item_modifier_hist[index].bill_item_type_cd,workload_type_cd)=
          workload_type_cd) workload_code_entity_name
          ELSE ""
          ENDIF
          ,request->bill_item_modifier_hist[index].key3_entity_name,
          IF (trim(validate(request->bill_item_modifier_hist[index].key3_entity_name,""),7)="") 0
          ELSE 1
          ENDIF
          ), bmih.key4_entity_name = nullcheck(
          IF (validate(request->bill_item_modifier_hist[index].bill_item_type_cd,chargepoint_type_cd)
          =chargepoint_type_cd) code_value_entity_name
          ELSE ""
          ENDIF
          ,request->bill_item_modifier_hist[index].key4_entity_name,
          IF (trim(validate(request->bill_item_modifier_hist[index].key4_entity_name,""),7)="") 0
          ELSE 1
          ENDIF
          ), bmih.key5_entity_name = nullcheck(
          IF (validate(request->bill_item_modifier_hist[index].key5_id,0.0) > 0.0)
           code_value_entity_name
          ELSE ""
          ENDIF
          ,request->bill_item_modifier_hist[index].key5_entity_name,
          IF (trim(validate(request->bill_item_modifier_hist[index].key4_entity_name,""),7)="") 0
          ELSE 1
          ENDIF
          ),
         bmih.key1_id = validate(request->bill_item_modifier_hist[index].key1_id,0.0), bmih.key2_id
          = validate(request->bill_item_modifier_hist[index].key2_id,0.0), bmih.key3_id = validate(
          request->bill_item_modifier_hist[index].key3_id,0.0),
         bmih.key4_id = validate(request->bill_item_modifier_hist[index].key4_id,0.0), bmih.key5_id
          = validate(request->bill_item_modifier_hist[index].key5_id,0.0), bmih.key11_id = validate(
          request->bill_item_modifier_hist[index].key11_id,0.0),
         bmih.key12_id = validate(request->bill_item_modifier_hist[index].key12_id,0.0), bmih
         .key13_id = validate(request->bill_item_modifier_hist[index].key13_id,0.0), bmih.key14_id =
         validate(request->bill_item_modifier_hist[index].key14_id,0.0),
         bmih.key15_id = validate(request->bill_item_modifier_hist[index].key15_id,0.0), bmih
         .bim1_int = validate(request->bill_item_modifier_hist[index].bim1_int,0.0), bmih.bim2_int =
         validate(request->bill_item_modifier_hist[index].bim2_int,0.0),
         bmih.bim_ind = validate(request->bill_item_modifier_hist[index].bim_ind,0), bmih.bim1_ind =
         validate(request->bill_item_modifier_hist[index].bim1_ind,0), bmih.bim1_nbr = validate(
          request->bill_item_modifier_hist[index].bim1_nbr,0.0),
         bmih.permanent_del_ind =
         IF ((validate(request->bill_item_modifier_hist[index].permanent_del_ind,- (1)) != - (1)))
          request->bill_item_modifier_hist[index].permanent_del_ind
         ELSE 0
         ENDIF
         , bmih.modification_dt_tm =
         IF (validate(request->bill_item_modifier_hist[index].updt_dt_tm,0.0) > 0.0) cnvtdatetime(
           request->bill_item_modifier_hist[index].updt_dt_tm)
         ELSE cnvtdatetime(sysdate)
         ENDIF
         , bmih.beg_effective_dt_tm =
         IF (validate(request->bill_item_modifier_hist[index].beg_effective_dt_tm,0.0) > 0.0)
          cnvtdatetime(request->bill_item_modifier_hist[index].beg_effective_dt_tm)
         ELSE cnvtdatetime(sysdate)
         ENDIF
         ,
         bmih.end_effective_dt_tm =
         IF (validate(request->bill_item_modifier_hist[index].end_effective_dt_tm,0.0) > 0.0)
          cnvtdatetime(request->bill_item_modifier_hist[index].end_effective_dt_tm)
         ELSE cnvtdatetime(default_end_date_time)
         ENDIF
         , bmih.active_ind =
         IF ((validate(request->bill_item_modifier_hist[index].active_ind,- (1)) != - (1))) request->
          bill_item_modifier_hist[index].active_ind
         ELSE true
         ENDIF
         , bmih.active_status_dt_tm =
         IF (validate(request->bill_item_modifier_hist[index].active_status_dt_tm,0.0) > 0.0)
          cnvtdatetime(request->bill_item_modifier_hist[index].active_status_dt_tm)
         ELSE cnvtdatetime(sysdate)
         ENDIF
         ,
         bmih.active_status_prsnl_id =
         IF (validate(request->bill_item_modifier_hist[index].active_status_prsnl_id,0.0) != 0.0)
          request->bill_item_modifier_hist[index].active_status_prsnl_id
         ELSE reqinfo->updt_id
         ENDIF
         , bmih.active_status_cd = nullcheck(cs48_recsts_active,request->bill_item_modifier_hist[
          index].active_status_cd,
          IF ((request->bill_item_modifier_hist[index].active_status_cd=0)) 0
          ELSE 1
          ENDIF
          ), bmih.updt_id = validate(request->bill_item_modifier_hist[index].updt_id,reqinfo->updt_id
          ),
         bmih.updt_dt_tm =
         IF (validate(request->bill_item_modifier_hist[index].updt_dt_tm,0.0) > 0.0) cnvtdatetime(
           request->bill_item_modifier_hist[index].updt_dt_tm)
         ELSE cnvtdatetime(sysdate)
         ENDIF
         , bmih.updt_task = validate(request->bill_item_modifier_hist[index].updt_task,reqinfo->
          updt_task), bmih.updt_applctx = validate(request->bill_item_modifier_hist[index].
          updt_applctx,reqinfo->updt_applctx),
         bmih.updt_cnt = validate(request->bill_item_modifier_hist[index].updt_cnt,0), bmih
         .task_action_flag = validate(request->bill_item_modifier_hist[index].task_action_flag,0)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failed = insert_error
        SET lmessage = uar_i18nbuildmessage(i18nhandle,"bimhKey_InsertError",
         "Failed to archive corresponding Bill Item modification(s) for Bill Item Mod Id [ %1 ]","d",
         request->bill_item_modifier_hist[index].bill_item_mod_id)
        CALL logmessage(add_bill_item_mod_his_sub_name,lmessage,log_error)
        SET lmessage = uar_i18ngetmessage(i18nhandle,"bimhKey_HistoryArchiveFailue",nullterm(
          "Failed in Bill_Item_Modfier_Hist record creation."))
        SET reply->status_data.subeventstatus[1].operationname = lmessage
        GO TO check_error
       ELSE
        SET failed = false
        SET reply->status_data.status = "S"
        SET stat = alterlist(reply->bill_item_modifier_hist,index)
        SET reply->bill_item_modifier_hist[index].bill_item_modifier_hist_id =
        new_bill_item_mod_hist_nbr
        SET lmessage = uar_i18nbuildmessage(i18nhandle,"bimhKey_ArchiveSuccess",
         "Archived corresponding Bill Item modification(s) successfully [ %1 ]","d",reply->
         bill_item_modifier_hist[index].bill_item_modifier_hist_id)
        CALL logmessage(add_bill_item_mod_his_sub_name,lmessage,log_info)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
#exit_script
END GO
