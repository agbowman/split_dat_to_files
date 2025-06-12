CREATE PROGRAM afc_rpt_ct_rule_qual_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Service Begin Date Time" = "SYSDATE",
  "Service End Date Time" = "SYSDATE"
  WITH outdev, servicefromdatetime, servicetodatetime
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
 CALL beginservice("323720.001")
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD chargelist
 RECORD chargelist(
   1 charges[*]
     2 chargeitemid = f8
     2 offsetchargeitemid = f8
     2 grpqualid = f8
     2 qualundoid = f8
     2 chargeeventid = f8
 )
 DECLARE getchargelistforservicedate(dummy=i4) = i2
 DECLARE generatereportforchargelist(dummy=i4) = i2
 IF ( NOT (validate(cs13028_dr)))
  DECLARE cs13028_dr = f8 WITH protect, constant(getcodevalue(13028,"DR",0))
 ENDIF
 IF ( NOT (validate(cs13028_cr)))
  DECLARE cs13028_cr = f8 WITH protect, constant(getcodevalue(13028,"CR",0))
 ENDIF
 IF ( NOT (validate(cs319_fin)))
  DECLARE cs319_fin = f8 WITH protect, constant(getcodevalue(319,"FIN NBR",0))
 ENDIF
 CALL getchargelistforservicedate(0)
 IF ( NOT (size(chargelist->charges,5) > 0))
  CALL exitservicenodata("No charges were found for the give date",dont_go_to_exit_script)
 ENDIF
 CALL generatereportforchargelist(0)
 CALL exitservicesuccess("Finished processing registration modifications")
 SUBROUTINE getchargelistforservicedate(dummy)
   DECLARE chrgidx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM charge c,
     charge c2
    PLAN (c2
     WHERE c2.service_dt_tm >= cnvtdatetime( $SERVICEFROMDATETIME)
      AND c2.service_dt_tm <= cnvtdatetime( $SERVICETODATETIME)
      AND c2.cs_cpp_undo_qual_id != 0.0
      AND c2.active_ind=true
      AND c2.charge_type_cd=cs13028_dr
      AND c2.offset_charge_item_id != 0.0
      AND  NOT ( EXISTS (
     (SELECT
      c3.charge_item_id
      FROM charge c3
      WHERE c3.charge_item_id=c2.offset_charge_item_id
       AND c3.cs_cpp_undo_id != 0.0
       AND c3.active_ind=true)))
      AND  NOT ( EXISTS (
     (SELECT
      c4.charge_item_id
      FROM charge c4
      WHERE c4.parent_charge_item_id=c2.charge_item_id
       AND c4.offset_charge_item_id=0.0
       AND c4.charge_type_cd=cs13028_dr
       AND c4.active_ind=false))))
     JOIN (c
     WHERE ((c.cs_cpp_undo_qual_id=c2.cs_cpp_undo_qual_id) OR (((c.charge_item_id=c2
     .offset_charge_item_id) OR (c.cs_cpp_undo_id=c2.cs_cpp_undo_qual_id)) ))
      AND c.active_ind=true)
    ORDER BY c.charge_item_id
    HEAD REPORT
     stat = alterlist(chargelist->charges,100), chrgidx = 0
    HEAD c.charge_item_id
     chrgidx = (chrgidx+ 1)
     IF (mod(chrgidx,100)=1
      AND chrgidx != 1)
      stat = alterlist(chargelist->charges,(chrgidx+ 99))
     ENDIF
     chargelist->charges[chrgidx].chargeitemid = c.charge_item_id, chargelist->charges[chrgidx].
     offsetchargeitemid = c.offset_charge_item_id, chargelist->charges[chrgidx].chargeeventid = c
     .charge_event_id
     IF (c.cs_cpp_undo_qual_id > 0.0)
      chargelist->charges[chrgidx].grpqualid = c.cs_cpp_undo_qual_id, chargelist->charges[chrgidx].
      qualundoid = c.cs_cpp_undo_qual_id
     ELSEIF (c.cs_cpp_undo_id > 0.0)
      chargelist->charges[chrgidx].grpqualid = c.cs_cpp_undo_id, chargelist->charges[chrgidx].
      qualundoid = c.cs_cpp_undo_id
     ENDIF
     IF ((chargelist->charges[chrgidx].grpqualid=0.0))
      iindex = 0, igl_idx = 0, igl_idx = locateval(iindex,1,size(chargelist->charges,5),c
       .offset_charge_item_id,chargelist->charges[iindex].chargeitemid)
      IF (igl_idx > 0)
       chargelist->charges[chrgidx].offsetchargeitemid = chargelist->charges[igl_idx].
       offsetchargeitemid, chargelist->charges[chrgidx].grpqualid = chargelist->charges[igl_idx].
       grpqualid
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(chargelist->charges,chrgidx)
    WITH nocounter
   ;end select
   IF ( NOT (size(chargelist->charges,5) > 0))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE generatereportforchargelist(dummy)
   DECLARE i18nhandle = i4 WITH public, noconstant(0)
   DECLARE colheaderexists = i2 WITH protect, noconstant(false)
   DECLARE startdate = vc WITH protect, noconstant( $SERVICEFROMDATETIME)
   DECLARE enddate = vc WITH protect, noconstant( $SERVICETODATETIME)
   SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
   SELECT INTO value( $OUTDEV)
    grpqualid = chargelist->charges[d.seq].grpqualid, chargeeventid = chargelist->charges[d.seq].
    chargeeventid, chargeitemid = chargelist->charges[d.seq].chargeitemid,
    offsetchargeitemid = chargelist->charges[d.seq].offsetchargeitemid
    FROM (dummyt d  WITH seq = value(size(chargelist->charges,5))),
     charge c,
     bill_item b,
     encounter e,
     person p,
     encntr_alias a,
     cs_cpp_undo u,
     cs_cpp_rule r
    PLAN (d
     WHERE (chargelist->charges[d.seq].chargeitemid > 0.0))
     JOIN (c
     WHERE (c.charge_item_id=chargelist->charges[d.seq].chargeitemid))
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id)
     JOIN (u
     WHERE (u.cs_cpp_undo_id=chargelist->charges[d.seq].qualundoid))
     JOIN (r
     WHERE r.cs_cpp_rule_id=u.cs_cpp_rule_id)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id)
     JOIN (p
     WHERE p.person_id=e.person_id)
     JOIN (a
     WHERE a.encntr_id=outerjoin(e.encntr_id)
      AND a.encntr_alias_type_cd=outerjoin(cs319_fin)
      AND a.active_ind=outerjoin(true))
    ORDER BY p.person_id, e.encntr_id, grpqualid,
     chargeeventid, chargeitemid, offsetchargeitemid DESC
    HEAD REPORT
     report_name = uar_i18ngetmessage(i18nhandle,"k1","CT Rule Qualification Audit Report"),
     filter_display = uar_i18ngetmessage(i18nhandle,"k1",build2("Service Date Time Between ",
       startdate," and ",enddate)), line180 = fillstring(179,"-")
    HEAD PAGE
     row 0, col 73, report_name,
     row + 1, col 55, filter_display,
     row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Page:"), col 2,
     displaystring, col 9, curpage"###",
     displaystring = uar_i18ngetmessage(i18nhandle,"k1","Report Date:"), col 154, displaystring,
     col 168, curdate"DD-MMM-YYYY;;D", row + 1,
     col 0, line180, row + 1,
     displaystring = uar_i18ngetmessage(i18nhandle,"k1","Patient Name:"), col 2, displaystring,
     full_name = substring(1,80,p.name_full_formatted), col 16, full_name,
     displaystring = uar_i18ngetmessage(i18nhandle,"k1","Encounter Number:"), col 105, displaystring,
     fin_nbr = substring(1,20,a.alias), col 124, fin_nbr,
     row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Rule Name"), col 2,
     displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Charge Description"), col 55,
     displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Charge Type"), col 105,
     displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Date of Service"), col 120,
     displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Quantity"), col 140,
     displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Price"), col 153,
     displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Changes Identified"), col 160,
     displaystring, row + 1, col 0,
     line180, row + 1
     IF ( NOT (size(chargelist->charges,5) > 0))
      norecordstring = uar_i18ngetmessage(i18nhandle,"k1","No records found for the given date "),
      col 73, norecordstring,
      row + 1, row + 1
     ENDIF
     colheaderexists = true
    HEAD e.encntr_id
     IF (((row+ 5) > maxrow))
      BREAK
     ENDIF
     IF ( NOT (colheaderexists))
      displaystring = uar_i18ngetmessage(i18nhandle,"k1","Patient Name:"), col 2, displaystring,
      full_name = substring(1,80,p.name_full_formatted), col 16, full_name,
      displaystring = uar_i18ngetmessage(i18nhandle,"k1","Encounter Number:"), col 105, displaystring,
      fin_nbr = substring(1,20,a.alias), col 124, fin_nbr,
      row + 1, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Rule Name"), col 2,
      displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Charge Description"), col 55,
      displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Charge Type"), col 105,
      displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Date of Service"), col 120,
      displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Quantity"), col 140,
      displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Price"), col 153,
      displaystring, displaystring = uar_i18ngetmessage(i18nhandle,"k1","Changes Identified"), col
      160,
      displaystring, row + 1, col 0,
      line180, row + 1
     ENDIF
    HEAD grpqualid
     row + 0
    HEAD c.charge_item_id
     IF (((row+ 3) > maxrow))
      BREAK
     ENDIF
     IF (r.cs_cpp_rule_id > 0.0)
      rule_name = substring(1,50,r.rule_name)
     ELSE
      rule_name = uar_i18ngetmessage(i18nhandle,"k1","(No Rule)")
     ENDIF
     IF (validate(debug,0)=1)
      rule_name = build(rule_name,cnvtstring(c.charge_item_id,17))
     ENDIF
     col 2, rule_name, chrg_desc = substring(1,50,b.ext_description),
     col 55, chrg_desc, chrg_type = uar_get_code_display(c.charge_type_cd),
     col 105, chrg_type, dt_service = format(c.service_dt_tm,"DD-MMM-YY HH:MM;;D"),
     col 120, dt_service, qty = c.item_quantity,
     col 140, qty"####.##;I;F", price = c.item_extended_price,
     col 148, price"########.##;I;F"
     IF (c.cs_cpp_undo_id > 0.0)
      ct_updt = uar_i18ngetmessage(i18nhandle,"k1","Y")
     ELSE
      ct_updt = uar_i18ngetmessage(i18nhandle,"k1","N")
     ENDIF
     col 175, ct_updt, row + 1
    FOOT  grpqualid
     row + 1
    FOOT  e.encntr_id
     col 0, line180, row + 1,
     row + 1, colheaderexists = false
    FOOT REPORT
     report_end = uar_i18ngetmessage(i18nhandle,"k1","End Of Report"), col 83, report_end,
     row + 1, col 0, line180
    WITH nocounter, nullreport, compress,
     landscape, maxrow = 45, maxcol = 180,
     format = variable
   ;end select
   RETURN(true)
 END ;Subroutine
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(chargelist)
 ENDIF
 FREE RECORD chargelist
END GO
