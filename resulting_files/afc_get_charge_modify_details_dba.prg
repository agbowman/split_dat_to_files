CREATE PROGRAM afc_get_charge_modify_details:dba
 IF (validate(getcodevalue,char(128))=char(128))
  DECLARE getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE getcodevalue(code_set,cdf_meaning,option_flag)
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
  DECLARE logmessage(psubroutine=vc,pmessage=vc,plevel=i4) = null
  SUBROUTINE logmessage(psubroutine,pmessage,plevel)
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
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(curdate,curtime3))
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
  DECLARE beginservice(pversion=vc) = null
  SUBROUTINE beginservice(pversion)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  DECLARE exitservicesuccess(pmessage=vc) = null
  SUBROUTINE exitservicesuccess(pmessage)
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
  DECLARE exitservicefailure(pmessage=vc,exitscriptind=i2) = null
  SUBROUTINE exitservicefailure(pmessage,exitscriptind)
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
  DECLARE exitservicenodata(pmessage=vc,exitscriptind=i2) = null
  SUBROUTINE exitservicenodata(pmessage,exitscriptind)
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
  DECLARE setreplystatus(pstatus=vc,pmessage=vc) = null
  SUBROUTINE setreplystatus(pstatus,pmessage)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  DECLARE addtracemessage(proutinename=vc,pmessage=vc) = null
  SUBROUTINE addtracemessage(proutinename,pmessage)
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
  DECLARE addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) = null
  SUBROUTINE addstatusdetail(pentityid,pdetailflag,pdetailmessage)
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
  DECLARE copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) = null
  SUBROUTINE copystatusdetails(pfromrecord,prtorecord)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx = (toidx+ 1)
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt = (toparamcnt+ 1)
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
  DECLARE addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) = null
  SUBROUTINE addstatusdetailparam(pdetailidx,pparamname,pparamvalue)
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
  DECLARE copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) = null
  SUBROUTINE copytracemessages(pfromrecord,prtorecord)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx = (toidx+ 1)
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
 CALL beginservice("320259.001")
 IF (validate(reply->charge_modifications)=0)
  RECORD reply(
    1 charge_item_id = f8
    1 charge_description = vc
    1 service_dt_tm = dq8
    1 quantity = f8
    1 price = f8
    1 charge_modifications[*]
      2 mod_type = vc
      2 old_value = vc
      2 new_value = vc
      2 reason_cd = vc
      2 reason_comment = vc
      2 updated_by = vc
      2 updt_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD changelogdetails(
   1 charge_mod_count = i4
   1 charge_mods[*]
     2 charge_item_id = f8
     2 field2 = vc
     2 field3 = vc
     2 field7 = vc
     2 field2_id = f8
     2 field3_id = f8
     2 active_ind = i2
     2 reason_cd = vc
     2 reason_comment = vc
     2 updated_by = vc
     2 updt_dt_tm = dq8
 ) WITH protect
 DECLARE fillchangelogdetailsinreply(pmodtype=vc,poldvalue=vc,pnewvalue=vc,pupdatedby=vc,pupdtdttm=
  dq8,
  preasoncd=vc,preasoncomment=vc) = null
 DECLARE hi18n = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 DECLARE i18n_ordering_physician = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val1",
   "Ordering Physician"))
 DECLARE i18n_rendering_physician = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val2",
   "Rendering Physician"))
 DECLARE i18n_research_account = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val3",
   "Research Account"))
 DECLARE i18n_abn_status = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val4","ABN Status"))
 DECLARE i18n_performing_location = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val5",
   "Performing Location"))
 DECLARE i18n_price = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val6","Price"))
 DECLARE i18n_quantity = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val7","Quantity"))
 DECLARE i18n_extended_price = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"Val8",
   "Extended Price"))
 IF ( NOT (validate(cs13019_changelog)))
  DECLARE cs13019_changelog = f8 WITH protect, constant(getcodevalue(13019,"CHANGELOG",0))
 ENDIF
 IF ( NOT (validate(cs13019_mod_rsn)))
  DECLARE cs13019_mod_rsn = f8 WITH protect, constant(getcodevalue(13019,"MOD RSN",0))
 ENDIF
 IF ( NOT (validate(cs13028_cr)))
  DECLARE cs13028_cr = f8 WITH protect, constant(getcodevalue(13028,"CR",0))
 ENDIF
 DECLARE count = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(request->charge_event_id)))
  CALL exitservicefailure("Charge Event Id is required",true)
 ENDIF
 SELECT INTO "nl:"
  FROM charge c,
   charge_mod cm,
   prsnl p
  PLAN (c
   WHERE (c.charge_event_id=request->charge_event_id)
    AND c.active_ind=1
    AND c.charge_type_cd != cs13028_cr)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.active_ind=1
    AND cm.charge_mod_type_cd=cs13019_changelog)
   JOIN (p
   WHERE p.person_id=cm.updt_id
    AND p.active_ind=1)
  ORDER BY c.updt_dt_tm, c.parent_charge_item_id
  DETAIL
   count = (size(changelogdetails->charge_mods,5)+ 1), stat = alterlist(changelogdetails->charge_mods,
    count), changelogdetails->charge_mod_count = count,
   changelogdetails->charge_mods[count].charge_item_id = cm.charge_item_id, changelogdetails->
   charge_mods[count].field2 = cm.field2, changelogdetails->charge_mods[count].field3 = cm.field3,
   changelogdetails->charge_mods[count].field2_id = cm.field2_id, changelogdetails->charge_mods[count
   ].field3_id = cm.field3_id, changelogdetails->charge_mods[count].field7 = cm.field7,
   changelogdetails->charge_mods[count].updt_dt_tm = cm.updt_dt_tm, changelogdetails->charge_mods[
   count].reason_cd = cm.field4, changelogdetails->charge_mods[count].reason_comment = cm.field5,
   changelogdetails->charge_mods[count].updated_by = p.name_full_formatted
  FOOT REPORT
   reply->charge_item_id = c.charge_item_id, reply->charge_description = c.charge_description, reply
   ->service_dt_tm = c.service_dt_tm,
   reply->quantity = c.item_quantity, reply->price = c.item_extended_price
  WITH nocounter
 ;end select
 IF (size(changelogdetails->charge_mods,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = size(changelogdetails->charge_mods,5)),
    prsnl p1,
    prsnl p2
   PLAN (d1
    WHERE (changelogdetails->charge_mods[d1.seq].field7 IN (i18n_ordering_physician,
    i18n_rendering_physician)))
    JOIN (p1
    WHERE (p1.person_id=changelogdetails->charge_mods[d1.seq].field2_id))
    JOIN (p2
    WHERE (p2.person_id=changelogdetails->charge_mods[d1.seq].field3_id))
   DETAIL
    CALL fillchangelogdetailsinreply(changelogdetails->charge_mods[d1.seq].field7,p1
    .name_full_formatted,p2.name_full_formatted,changelogdetails->charge_mods[d1.seq].updated_by,
    changelogdetails->charge_mods[d1.seq].updt_dt_tm,changelogdetails->charge_mods[d1.seq].reason_cd,
    changelogdetails->charge_mods[d1.seq].reason_comment)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = size(changelogdetails->charge_mods,5)),
    research_account ra1,
    research_account ra2
   PLAN (d1
    WHERE (changelogdetails->charge_mods[d1.seq].field7=i18n_research_account))
    JOIN (ra1
    WHERE (ra1.research_account_id=changelogdetails->charge_mods[d1.seq].field2_id))
    JOIN (ra2
    WHERE (ra2.research_account_id=changelogdetails->charge_mods[d1.seq].field3_id))
   DETAIL
    CALL fillchangelogdetailsinreply(changelogdetails->charge_mods[d1.seq].field7,concat(trim(ra1
      .account_nbr)," ",trim(ra1.description)),concat(trim(ra2.account_nbr)," ",trim(ra2.description)
     ),changelogdetails->charge_mods[d1.seq].updated_by,changelogdetails->charge_mods[d1.seq].
    updt_dt_tm,changelogdetails->charge_mods[d1.seq].reason_cd,changelogdetails->charge_mods[d1.seq].
    reason_comment)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = size(changelogdetails->charge_mods,5))
   PLAN (d1
    WHERE  NOT ((changelogdetails->charge_mods[d1.seq].field7 IN (i18n_ordering_physician,
    i18n_rendering_physician, i18n_research_account))))
   DETAIL
    IF ((changelogdetails->charge_mods[d1.seq].field7 IN (i18n_abn_status, i18n_performing_location))
    )
     CALL fillchangelogdetailsinreply(changelogdetails->charge_mods[d1.seq].field7,
     uar_get_code_display(changelogdetails->charge_mods[d1.seq].field2_id),uar_get_code_display(
      changelogdetails->charge_mods[d1.seq].field3_id),changelogdetails->charge_mods[d1.seq].
     updated_by,changelogdetails->charge_mods[d1.seq].updt_dt_tm,changelogdetails->charge_mods[d1.seq
     ].reason_cd,changelogdetails->charge_mods[d1.seq].reason_comment)
    ELSEIF ((changelogdetails->charge_mods[d1.seq].field7 IN (i18n_price, i18n_quantity,
    i18n_extended_price)))
     CALL fillchangelogdetailsinreply(changelogdetails->charge_mods[d1.seq].field7,cnvtstring(
      changelogdetails->charge_mods[d1.seq].field2_id,17,2),cnvtstring(changelogdetails->charge_mods[
      d1.seq].field3_id,17,2),changelogdetails->charge_mods[d1.seq].updated_by,changelogdetails->
     charge_mods[d1.seq].updt_dt_tm,changelogdetails->charge_mods[d1.seq].reason_cd,changelogdetails
     ->charge_mods[d1.seq].reason_comment)
    ELSE
     CALL fillchangelogdetailsinreply(changelogdetails->charge_mods[d1.seq].field7,changelogdetails->
     charge_mods[d1.seq].field2,changelogdetails->charge_mods[d1.seq].field3,changelogdetails->
     charge_mods[d1.seq].updated_by,changelogdetails->charge_mods[d1.seq].updt_dt_tm,changelogdetails
     ->charge_mods[d1.seq].reason_cd,changelogdetails->charge_mods[d1.seq].reason_comment)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  CALL exitservicenodata("No Charge Modifications found for the given Charge Event Id",true)
 ENDIF
 IF (size(reply->charge_modifications,5) > 0)
  CALL exitservicesuccess("")
 ENDIF
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
 SUBROUTINE fillchangelogdetailsinreply(pmodtype,poldvalue,pnewvalue,pupdatedby,pupdtdttm,preasoncd,
  preasoncomment)
   DECLARE count1 = i4 WITH protect, noconstant(0)
   SET count1 = (size(reply->charge_modifications,5)+ 1)
   SET stat = alterlist(reply->charge_modifications,count1)
   SET reply->charge_modifications[count1].mod_type = pmodtype
   SET reply->charge_modifications[count1].old_value = poldvalue
   SET reply->charge_modifications[count1].new_value = pnewvalue
   SET reply->charge_modifications[count1].updated_by = pupdatedby
   SET reply->charge_modifications[count1].updt_dt_tm = pupdtdttm
   SET reply->charge_modifications[count1].reason_cd = preasoncd
   SET reply->charge_modifications[count1].reason_comment = preasoncomment
 END ;Subroutine
END GO
