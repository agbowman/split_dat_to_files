CREATE PROGRAM afc_rca_save_charge_event:dba
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
 RECORD afc_dm_request(
   1 info_name_qual = i2
   1 info[*]
     2 info_name = vc
   1 info_name = vc
 )
 RECORD afc_dm_reply(
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
 DECLARE nrepcount = i4 WITH protect, noconstant(0)
 DECLARE siteallowadmit = vc WITH protect, noconstant("Y")
 DECLARE siteallowadmittime = i2 WITH protect, noconstant(0)
 DECLARE checkservicedischarge = vc WITH protect, noconstant("N")
 DECLARE checkservicedischargetime = i2 WITH protect, noconstant(0)
 DECLARE checksystemdischarge = vc WITH protect, noconstant("N")
 DECLARE checksystemdischargetime = i2 WITH protect, noconstant(0)
 DECLARE systemdaysafterdischarge = i4 WITH protect, noconstant(0)
 DECLARE servicedaysafterdischarge = i4 WITH protect, noconstant(0)
 DECLARE servicedatepreferencetype = i2 WITH protect, noconstant(0)
 DECLARE svcdatevalid = i2 WITH protect, constant(0)
 DECLARE svcdatebeforeadmit = i2 WITH protect, constant(1)
 DECLARE svcdatebeforeadmitwarn = i2 WITH protect, constant(2)
 DECLARE svcdateafterdisch = i2 WITH protect, constant(3)
 DECLARE svcdateafterdischwarn = i2 WITH protect, constant(4)
 DECLARE sysdateafterdisch = i2 WITH protect, constant(5)
 DECLARE sysdateafterdischwarn = i2 WITH protect, constant(6)
 DECLARE svcdatemissing = i2 WITH protect, constant(7)
 SUBROUTINE (initializeservicedateval(dummy=vc) =i2)
   SET afc_dm_request->info_name_qual = 9
   SET stat = alterlist(afc_dm_request->info,9)
   SET afc_dm_request->info[1].info_name = "ALLOW SERVICE DATE < ADMIT DATE"
   SET afc_dm_request->info[2].info_name = "CHECK SERVICE DATE DISCHARGE"
   SET afc_dm_request->info[3].info_name = "CHECK SYSTEM DATE DISCHARGE"
   SET afc_dm_request->info[4].info_name = "SYSTEM DAYS AFTER DISCHARGE"
   SET afc_dm_request->info[5].info_name = "SERVICE DAYS AFTER DISCHARGE"
   SET afc_dm_request->info[6].info_name = "PREFERENCE TYPE"
   SET afc_dm_request->info[7].info_name = "ALLOW SERVICE DATE < ADMIT DATE TIME"
   SET afc_dm_request->info[8].info_name = "CHECK SYSTEM DATE DISCHARGE TIME"
   SET afc_dm_request->info[9].info_name = "CHECK SERVICE DATE DISCHARGE TIME"
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->status_data.status="S"))
    FOR (nrepcount = 1 TO size(afc_dm_reply->dm_info,5))
      CASE (afc_dm_reply->dm_info[nrepcount].info_name)
       OF "ALLOW SERVICE DATE < ADMIT DATE":
        SET siteallowadmit = afc_dm_reply->dm_info[nrepcount].info_char
       OF "CHECK SERVICE DATE DISCHARGE":
        SET checkservicedischarge = afc_dm_reply->dm_info[nrepcount].info_char
       OF "CHECK SYSTEM DATE DISCHARGE":
        SET checksystemdischarge = afc_dm_reply->dm_info[nrepcount].info_char
       OF "SYSTEM DAYS AFTER DISCHARGE":
        SET systemdaysafterdischarge = afc_dm_reply->dm_info[nrepcount].info_number
       OF "SERVICE DAYS AFTER DISCHARGE":
        SET servicedaysafterdischarge = afc_dm_reply->dm_info[nrepcount].info_number
       OF "PREFERENCE TYPE":
        SET servicedatepreferencetype = afc_dm_reply->dm_info[nrepcount].info_number
       OF "ALLOW SERVICE DATE < ADMIT DATE TIME":
        SET siteallowadmittime = afc_dm_reply->dm_info[nrepcount].info_number
       OF "CHECK SYSTEM DATE DISCHARGE TIME":
        SET checksystemdischargetime = afc_dm_reply->dm_info[nrepcount].info_number
       OF "CHECK SERVICE DATE DISCHARGE TIME":
        SET checkservicedischargetime = afc_dm_reply->dm_info[nrepcount].info_number
      ENDCASE
    ENDFOR
    RETURN(true)
   ELSEIF ((afc_dm_reply->status_data.status="Z"))
    RETURN(true)
   ELSEIF ((afc_dm_reply->status_data.status="F"))
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkservicedate(servicedttm=f8,admitdttm=f8,preregdttm=f8,dischargedttm=f8,systemdttm=
  f8) =i2)
   DECLARE datereturnvalue = i2
   DECLARE dischargedate = f8
   SET datereturnvalue = svcdatevalid
   IF (servicedttm > 0)
    IF (((siteallowadmit="N") OR (siteallowadmit="W")) )
     IF (((admitdttm > 0) OR (preregdttm > 0)) )
      IF (admitdttm < 1)
       SET admitdttm = preregdttm
      ENDIF
      IF (((siteallowadmittime=0
       AND datetimediff(cnvtdatetime(cnvtdate(admitdttm),cnvttime(admitdttm)),cnvtdatetime(cnvtdate(
         servicedttm),cnvttime(servicedttm)),5) > 0) OR (datetimecmp(cnvtdatetime(admitdttm),
       cnvtdatetime(servicedttm)) > 0)) )
       IF (siteallowadmit="N")
        SET datereturnvalue = svcdatebeforeadmit
       ELSE
        SET datereturnvalue = svcdatebeforeadmitwarn
       ENDIF
      ENDIF
     ELSE
      SET datereturnvalue = svcdatebeforeadmit
     ENDIF
    ENDIF
    IF (datereturnvalue=0
     AND servicedatepreferencetype=1)
     IF (((checkservicedischarge="Y") OR (checkservicedischarge="W"))
      AND dischargedttm > 0)
      SET dischargedate = datetimeadd(dischargedttm,servicedaysafterdischarge)
      IF (((checkservicedischargetime=0
       AND datetimediff(cnvtdatetime(cnvtdate(servicedttm),cnvttime(servicedttm)),cnvtdatetime(
        cnvtdate(dischargedate),cnvttime(dischargedate)),5) > 0) OR (datetimecmp(cnvtdatetime(
        servicedttm),cnvtdatetime(dischargedate)) > 0)) )
       IF (checkservicedischarge="Y")
        SET datereturnvalue = svcdateafterdisch
       ELSE
        SET datereturnvalue = svcdateafterdischwarn
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (datereturnvalue=0)
     IF (((checksystemdischarge="Y") OR (checksystemdischarge="W"))
      AND dischargedttm > 0)
      SET dischargedate = datetimeadd(dischargedttm,systemdaysafterdischarge)
      IF (((checksystemdischargetime=0
       AND datetimediff(cnvtdatetime(cnvtdate(systemdttm),cnvttime(systemdttm)),cnvtdatetime(cnvtdate
        (dischargedate),cnvttime(dischargedate)),5) > 0) OR (datetimecmp(cnvtdatetime(systemdttm),
       cnvtdatetime(dischargedate)) > 0)) )
       IF (checksystemdischarge="Y")
        SET datereturnvalue = sysdateafterdisch
       ELSE
        SET datereturnvalue = sysdateafterdischwarn
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (servicedttm < 1)
     SET datereturnvalue = svcdatemissing
    ENDIF
   ENDIF
   RETURN(datereturnvalue)
 END ;Subroutine
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
 CALL beginservice("689659.015")
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 chargebatchid = f8
    1 chargeeventid = f8
    1 price = f8
    1 servicedttmvalidind = i2
    1 cptlist[*]
      2 alias = vc
      2 value = f8
    1 diaglist[*]
      2 alias = vc
      2 value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 quantity = f8
    1 haspatresponsibility = i2
    1 serviceitems[1]
      2 serviceitemid = f8
      2 categories[1]
        3 categoryname = vc
        3 patrespfields[*]
          4 fieldname = vc
          4 fielddisplay = vc
          4 fieldtype = vc
          4 optionlist[*]
            5 optionvalue = vc
            5 optioncd = f8
    1 cdmdisplay = vc
  )
 ENDIF
 FREE RECORD chargebatchreq
 RECORD chargebatchreq(
   1 chargebatchid = f8
   1 chargebatchalias = vc
   1 chargebatchdate = dq8
   1 userdefinedind = i2
 )
 FREE RECORD chargebatchrep
 RECORD chargebatchrep(
   1 chargebatchid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD validateeventreq
 RECORD validateeventreq(
   1 serviceitemid = f8
   1 cptlist[*]
     2 alias = vc
     2 value = f8
   1 diaglist[*]
     2 alias = vc
     2 value = f8
   1 flexfields[*]
     2 fieldtypecd = f8
     2 fielddatetime = dq8
     2 fieldchar = vc
     2 fieldnbr = f8
     2 fieldind = i2
     2 fieldcd = f8
 )
 FREE RECORD validateeventrep
 RECORD validateeventrep(
   1 serviceitemdesc = vc
   1 cptlist[*]
     2 validind = i2
     2 value = f8
     2 alias = vc
   1 requiredfieldstatus = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pireq
 RECORD pireq(
   1 objarray[*]
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 encntr_org_id = f8
     2 fin_class_cd = f8
     2 encntr_type_cd = f8
     2 health_plan_id = f8
     2 loc_nurse_unit_cd = f8
     2 service_dt_tm = dq8
     2 item_quantity = i4
     2 charge_event_act_id = f8
     2 charge_mod[*]
       3 charge_mod_id = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 activity_dt_tm = dq8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_task = i4
       3 updt_applctx = i4
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 code1_cd = f8
       3 nomen_id = f8
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 cm1_nbr = f8
     2 orderingphysid = f8
     2 renderingphysid = f8
     2 serviceresourcecd = f8
 )
 FREE RECORD pirep
 RECORD pirep(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 payor_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 order_id = f8
     2 beg_effective_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 admit_type_cd = f8
     2 med_service_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_dt_tm = dq8
     2 process_flg = i2
     2 parent_charge_item_id = f8
     2 interface_id = f8
     2 tier_group_cd = f8
     2 def_bill_item_id = f8
     2 verify_phys_id = f8
     2 gross_price = f8
     2 discount_amount = f8
     2 activity_type_cd = f8
     2 research_acct_id = f8
     2 cost_center_cd = f8
     2 abn_status_cd = f8
     2 perf_loc_cd = f8
     2 inst_fin_nbr = c50
     2 ord_loc_cd = f8
     2 fin_class_cd = f8
     2 health_plan_id = f8
     2 manual_ind = i2
     2 updt_ind = i2
     2 payor_type_cd = f8
     2 item_copay = f8
     2 item_reimbursement = f8
     2 posted_dt_tm = dq8
     2 item_interval_id = f8
     2 list_price = f8
     2 list_price_sched_id = f8
     2 realtime_ind = i2
     2 epsdt_ind = i2
     2 ref_phys_id = f8
     2 alpha_nomen_id = f8
     2 server_process_flag = i2
     2 mods[*]
       3 mod_id = f8
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 charge_item_id = f8
       3 charge_mod_type_cd = f8
       3 field1 = c200
       3 field2 = c200
       3 field3 = c200
       3 field4 = c200
       3 field5 = c200
       3 field6 = c200
       3 field7 = c200
       3 field8 = c200
       3 field9 = c200
       3 field10 = c200
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
       3 field4_id = f8
       3 field5_id = f8
       3 nomen_id = f8
       3 cm1_nbr = f8
     2 offset_charge_item_id = f8
     2 patient_responsibility_flag = i2
     2 item_deductible_amt = f8
   1 srv_diag[*]
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_act_id = f8
     2 srv_diag_cd = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag_tier = f8
     2 srv_diag_reason = c200
 )
 FREE RECORD chargebatchdetailreq
 RECORD chargebatchdetailreq(
   1 objarray[*]
     2 charge_batch_detail_id = f8
     2 charge_batch_id = f8
     2 encntr_id = f8
     2 ordering_phys_id = f8
     2 bill_item_id = f8
     2 service_item_ident = vc
     2 service_item_ident_type_cd = f8
     2 service_item_qty = f8
     2 service_item_price_amt = f8
     2 service_item_desc = vc
     2 service_dt_tm = dq8
     2 perf_loc_cd = f8
     2 diagnosis_pointer_txt = vc
     2 status_cd = f8
     2 item_copay_amt = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
     2 active_ind = i2
     2 updt_cnt = i4
     2 rendering_phys_id = f8
     2 service_resource_cd = f8
 )
 FREE RECORD chargebatchdetailrep
 RECORD chargebatchdetailrep(
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
 FREE RECORD chargebatchdtlcdreq
 RECORD chargebatchdtlcdreq(
   1 objarray[*]
     2 charge_batch_detail_code_id = f8
     2 charge_batch_detail_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 type_ident = vc
     2 priority_seq = i4
     2 active_ind = i2
     2 updt_cnt = i4
     2 type_cd = f8
     2 updt_cnt = i4
 )
 FREE RECORD chargebatchdtlcdrep
 RECORD chargebatchdtlcdrep(
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
 FREE RECORD chargebatchdtlfldreq
 RECORD chargebatchdtlfldreq(
   1 objarray[*]
     2 charge_batch_detail_field_id = f8
     2 charge_batch_detail_id = f8
     2 field_type_cd = f8
     2 field_value_dt_tm = dq8
     2 field_value_dt_tm_null = i2
     2 field_value_char = vc
     2 field_value_nbr = f8
     2 field_value_ind = i2
     2 field_value_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 field_value_start_dt_tm = dq8
     2 field_value_start_dt_tm_null = i2
     2 field_value_end_dt_tm = dq8
     2 field_value_end_dt_tm_null = i2
     2 field_value_prsnl_id = f8
     2 priority_seq = i4
 )
 FREE RECORD chargebatchdtlfldrep
 RECORD chargebatchdtlfldrep(
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
 FREE RECORD chrgbatchstatusreq
 RECORD chrgbatchstatusreq(
   1 objarray[*]
     2 charge_batch_id = f8
     2 created_prsnl_id = f8
     2 assigned_prsnl_id = f8
     2 user_defined_ind = i2
     2 active_ind = i2
     2 status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_tm_null = i2
     2 created_dt_tm = dq8
     2 created_dt_tm_null = i2
     2 accessed_dt_tm = dq8
     2 accessed_dt_tm_null = i2
     2 updt_cnt = i4
 )
 FREE RECORD chrgbatchstatusrep
 RECORD chrgbatchstatusrep(
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
 FREE RECORD encounterinfo
 RECORD encounterinfo(
   1 encntr_id = f8
   1 person_id = f8
   1 encntr_type = f8
   1 encntr_org_id = f8
   1 fin_class_cd = f8
   1 encntr_type_cd = f8
   1 loc_nurse_unit_cd = f8
   1 loc_building_cd = f8
   1 loc_facility_cd = f8
   1 primaryhealthplanid = f8
   1 secondaryhealthplanid = f8
   1 shareofcost = f8
   1 program_service_cd = f8
 )
 FREE RECORD pbmpatrespreq
 RECORD pbmpatrespreq(
   1 qual[*]
     2 param_name = vc
     2 param_value = vc
 )
 FREE RECORD pbmpatresprep
 RECORD pbmpatresprep(
   1 qual[*]
     2 param_name = vc
     2 param_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE i18n_pat_responsibility = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,"Val1",
   "Patient Responsibility"))
 DECLARE i18n_yes = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,"Val1","Yes"))
 DECLARE i18n_no = vc WITH protect, constant(uar_i18ngetmessage(_hi18n,"Val1","No"))
 IF ( NOT (validate(cs4002321_modifier_cd)))
  DECLARE cs4002321_modifier_cd = f8 WITH protect, constant(getcodevalue(4002321,"MODIFIER",0))
 ENDIF
 IF ( NOT (validate(cs4002321_diag_cd)))
  DECLARE cs4002321_diag_cd = f8 WITH protect, constant(getcodevalue(4002321,"DIAG",0))
 ENDIF
 IF ( NOT (validate(cs4002322_pending_cd)))
  DECLARE cs4002322_pending_cd = f8 WITH protect, constant(getcodevalue(4002322,"PENDING",0))
 ENDIF
 IF ( NOT (validate(cs4002322_failed_cd)))
  DECLARE cs4002322_failed_cd = f8 WITH protect, constant(getcodevalue(4002322,"FAILED",0))
 ENDIF
 IF ( NOT (validate(cs4002322_locked_cd)))
  DECLARE cs4002322_locked_cd = f8 WITH protect, constant(getcodevalue(4002322,"LOCKED",0))
 ENDIF
 IF ( NOT (validate(cs4002324_cpt_cd)))
  DECLARE cs4002324_cpt_cd = f8 WITH protect, constant(getcodevalue(4002324,"CPT",0))
 ENDIF
 IF ( NOT (validate(cs4002324_cdm_cd)))
  DECLARE cs4002324_cdm_cd = f8 WITH protect, constant(getcodevalue(4002324,"CDM",0))
 ENDIF
 IF ( NOT (validate(cs4002324_icd_cd)))
  DECLARE cs4002324_icd_cd = f8 WITH protect, constant(getcodevalue(4002324,"ICD",0))
 ENDIF
 IF ( NOT (validate(cs13019_prompt_cd)))
  DECLARE cs13019_prompt_cd = f8 WITH protect, constant(getcodevalue(13019,"PROMPT",0))
 ENDIF
 IF ( NOT (validate(cs13019_billcode_cd)))
  DECLARE cs13019_billcode_cd = f8 WITH protect, constant(getcodevalue(13019,"BILL CODE",0))
 ENDIF
 IF ( NOT (validate(cs14002_icd9_cd)))
  DECLARE cs14002_icd9_cd = f8 WITH protect, constant(getcodevalue(14002,"ICD9",0))
 ENDIF
 IF ( NOT (validate(cs305570_docmin_cd)))
  DECLARE cs305570_docmin_cd = f8 WITH protect, constant(getcodevalue(305570,"DOCMIN",0))
 ENDIF
 IF ( NOT (validate(cs305570_numclients_cd)))
  DECLARE cs305570_numclients_cd = f8 WITH protect, constant(getcodevalue(305570,"NUMCLIENTS",0))
 ENDIF
 IF ( NOT (validate(cs305570_numtherapist_cd)))
  DECLARE cs305570_numtherapist_cd = f8 WITH protect, constant(getcodevalue(305570,"NUMTHERAPIST",0))
 ENDIF
 IF ( NOT (validate(cs305570_quantity_cd)))
  DECLARE cs305570_quantity_cd = f8 WITH protect, constant(getcodevalue(305570,"QUANTITY",0))
 ENDIF
 IF ( NOT (validate(cs305570_travelmin_cd)))
  DECLARE cs305570_travelmin_cd = f8 WITH protect, constant(getcodevalue(305570,"TRAVELMIN",0))
 ENDIF
 IF ( NOT (validate(cs4002321_cdm_cd)))
  DECLARE cs4002321_cdm_cd = f8 WITH protect, constant(getcodevalue(4002321,"CDM",0))
 ENDIF
 IF ( NOT (validate(cs4002352_casetime_cd)))
  DECLARE cs4002352_casetime_cd = f8 WITH protect, constant(getcodevalue(4002352,"CASETIME",0))
 ENDIF
 IF ( NOT (validate(cs4002352_holdtime_cd)))
  DECLARE cs4002352_holdtime_cd = f8 WITH protect, constant(getcodevalue(4002352,"HOLDTIME",0))
 ENDIF
 IF ( NOT (validate(cs4002352_relieftime_cd)))
  DECLARE cs4002352_relieftime_cd = f8 WITH protect, constant(getcodevalue(4002352,"RELIEFTIME",0))
 ENDIF
 IF ( NOT (validate(cs4002352_asacode_cd)))
  DECLARE cs4002352_asacode_cd = f8 WITH protect, constant(getcodevalue(4002352,"ASACODE",0))
 ENDIF
 DECLARE serviceitemdesc = vc WITH public, noconstant("")
 DECLARE chargeeventstatus = f8 WITH public, noconstant(0.0)
 DECLARE modobjcnt = i4 WITH protect, noconstant(0)
 DECLARE modreccnt = i4 WITH protect, noconstant(0)
 DECLARE cptmodifierscnt = i4 WITH protect, noconstant(0)
 DECLARE diagcnt = i4 WITH protect, noconstant(0)
 DECLARE loopcount = i4 WITH protect, noconstant(0)
 DECLARE fieldcnt = i4 WITH protect, noconstant(0)
 DECLARE batchcnt = i4 WITH protect, noconstant(0)
 DECLARE foundfailedevent = i2 WITH protect, noconstant(0)
 DECLARE createddttm = f8 WITH protect, noconstant(0.0)
 DECLARE evaluateforpatientresposibility(null) = i2
 CALL logmessage("Main","Begining main processing",log_debug)
 SET reply->haspatresponsibility = false
 IF ( NOT (validate(request->encounterid,- (1)) > 0.0))
  CALL logmessage("Main","encounterID is zero",log_debug)
  CALL exitservicefailure("EncounterID is zero",go_to_exit_script)
 ENDIF
 CALL initializeservicedateval(0)
 CALL getencounterinfo(request->encounterid)
 IF ((request->quantity <= 0))
  CALL logmessage("Main","Invalid quantity, default to 1",log_debug)
  SET request->quantity = 1.0
 ENDIF
 SET chargeeventstatus = cs4002322_pending_cd
 SET reply->quantity = request->quantity
 IF ((request->serviceitemid > 0.0))
  CALL getprice("")
 ELSE
  SET chargeeventstatus = cs4002322_failed_cd
 ENDIF
 IF ((request->ispatientrespevaluated=false)
  AND (request->quantity > 0.0)
  AND (reply->price > 0.0))
  IF (evaluateforpatientresposibility(request->encounterid))
   CALL logmessage("evaluateForPatientResposibility",
    "Patient Responsibility evaluated and it is required",log_debug)
   CALL exitservicesuccess("Exiting script")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->evaluateonlyind=true))
  CALL logmessage("Main","Only Patient Responsibility evaluated",log_debug)
  CALL exitservicesuccess("Exiting script")
  GO TO exit_script
 ENDIF
 IF ((request->chargebatchid=0.0))
  CALL logmessage("Main","No chargeBatchID exists, add system defined batch",log_debug)
  EXECUTE afc_rca_save_charge_batch  WITH replace("REQUEST",chargebatchreq), replace("REPLY",
   chargebatchrep)
  IF ((chargebatchrep->status_data.status="S"))
   SET reply->chargebatchid = chargebatchrep->chargebatchid
  ELSE
   CALL exitservicefailure("Failure adding Charge Batch",go_to_exit_script)
  ENDIF
 ELSE
  CALL logmessage("Main",build("Batch exists: ",cnvtstring(request->chargebatchid)),log_debug)
  SET reply->chargebatchid = request->chargebatchid
 ENDIF
 CALL checkdates("")
 IF ( NOT ((reply->servicedttmvalidind IN (svcdatevalid, svcdatebeforeadmitwarn,
 svcdateafterdischwarn, sysdateafterdischwarn))))
  SET chargeeventstatus = cs4002322_failed_cd
 ENDIF
 CALL logmessage("Main","Assign data element values",log_debug)
 IF ( NOT (getvaliditemvalues("")))
  CALL exitservicefailure("Failed validating item values",go_to_exit_script)
 ENDIF
 IF ((request->deductibleamt > 0.0)
  AND (request->deductibleamt > reply->price))
  CALL logmessage("Main",build("Deductible Amount is greater than Service Price Amount for : ",
    cnvtstring(request->chargebatchid)),log_debug)
  SET chargeeventstatus = cs4002322_failed_cd
 ENDIF
 IF ((request->chargeeventid > 0.0))
  IF ( NOT (uptchargeeventdetail("")))
   CALL exitservicefailure("Failed updating charge_event_detail",go_to_exit_script)
  ENDIF
 ELSE
  IF ( NOT (addchargeeventdetail("")))
   CALL exitservicefailure("Failed adding charge_event_detail",go_to_exit_script)
  ENDIF
 ENDIF
 IF ((reply->chargeeventid > 0.0))
  IF ( NOT (savechargeeventdetailcodes("")))
   CALL exitservicefailure("Failed saving charge_event_detail_code",go_to_exit_script)
  ENDIF
 ENDIF
 IF ((reply->chargeeventid > 0.0))
  IF ( NOT (savechargeeventflexfields("")))
   CALL exitservicefailure("Failed saving charge_event_detail_field",go_to_exit_script)
  ENDIF
 ENDIF
 IF (chargeeventstatus=cs4002322_failed_cd)
  SELECT INTO "nl"
   FROM charge_batch b
   WHERE (b.charge_batch_id=reply->chargebatchid)
    AND b.status_cd != cs4002322_locked_cd
   DETAIL
    null
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF ( NOT (updatebatchstatus(cs4002322_failed_cd)))
    CALL exitservicefailure("Failed updating batch status",go_to_exit_script)
   ENDIF
  ENDIF
 ELSE
  CALL logmessage("MAIN","Check to see if the current state of the batch is failed",log_debug)
  SELECT INTO "nl:"
   FROM charge_batch b
   WHERE (b.charge_batch_id=reply->chargebatchid)
    AND b.status_cd=cs4002322_failed_cd
   DETAIL
    null
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL logmessage("MAIN","Reset batch status if appropriate",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch_detail d
    WHERE (d.charge_batch_id=reply->chargebatchid)
     AND d.status_cd=cs4002322_failed_cd
     AND d.active_ind=1
    DETAIL
     foundfailedevent = 1
    WITH nocounter
   ;end select
   IF (foundfailedevent=0)
    CALL logmessage("MAIN","Updating the batch status to PENDING",log_debug)
    IF ( NOT (updatebatchstatus(cs4002322_pending_cd)))
     CALL exitservicefailure("Failed updating batch status",log_debug)
    ENDIF
   ELSE
    CALL logmessage("MAIN","Batch still contains failed events",log_debug)
   ENDIF
  ELSE
   CALL logmessage("MAIN","The batch is not currently failed",log_debug)
  ENDIF
 ENDIF
 IF ((validate(request->serviceresourcecd,- (0.00001)) != - (0.00001)))
  IF ((request->serviceresourcecd > 0.0))
   CALL logmodcapability(0)
  ENDIF
 ENDIF
 CALL exitservicesuccess("Exiting script")
 SUBROUTINE (getvaliditemvalues(null=vc) =i2)
   SET loopitems = 0
   CALL logmessage("getValidItemValues","Begin sub",log_debug)
   IF (size(request->cptlist,5) > 0)
    CALL logmessage("getValidItemValues","Populate cpt modifiers",log_debug)
    SET stat = movereclist(request->cptlist,validateeventreq->cptlist,1,0,size(request->cptlist,5),
     true)
   ENDIF
   IF (size(request->flexfields,5) > 0)
    CALL logmessage("getValidItemValues","Populate flex fields",log_debug)
    SET stat = alterlist(validateeventreq->flexfields,size(request->flexfields,5))
    FOR (fieldcnt = 1 TO size(request->flexfields,5))
      SET validateeventreq->flexfields[fieldcnt].fieldtypecd = request->flexfields[fieldcnt].
      fieldtypecd
      SET validateeventreq->flexfields[fieldcnt].fielddatetime = request->flexfields[fieldcnt].
      fielddatetime
      SET validateeventreq->flexfields[fieldcnt].fieldchar = request->flexfields[fieldcnt].fieldchar
      SET validateeventreq->flexfields[fieldcnt].fieldnbr = request->flexfields[fieldcnt].fieldnbr
      SET validateeventreq->flexfields[fieldcnt].fieldind = request->flexfields[fieldcnt].fieldind
      SET validateeventreq->flexfields[fieldcnt].fieldcd = request->flexfields[fieldcnt].fieldcd
    ENDFOR
   ENDIF
   SET validateeventreq->serviceitemid = request->serviceitemid
   CALL logmessage("getValidItemValues","executing afc_rca_validate_charge_event",log_debug)
   EXECUTE afc_rca_validate_charge_event  WITH replace("REQUEST",validateeventreq), replace("REPLY",
    validateeventrep)
   CALL logmessage("getValidItemValues",build("script call status ",validateeventrep->status_data.
     status),log_debug)
   IF ((validateeventrep->status_data.status="S"))
    FOR (loopitems = 1 TO size(validateeventrep->cptlist,5))
      SET stat = alterlist(reply->cptlist,loopitems)
      IF ((validateeventrep->cptlist[loopitems].validind=1))
       SET reply->cptlist[loopitems].alias = validateeventrep->cptlist[loopitems].alias
      ENDIF
      IF ((validateeventrep->cptlist[loopitems].validind=0))
       SET chargeeventstatus = cs4002322_failed_cd
      ENDIF
    ENDFOR
    FOR (loopitems = 1 TO size(request->diaglist,5))
      SET stat = alterlist(reply->diaglist,loopitems)
      SET reply->diaglist[loopitems].alias = request->diaglist[loopitems].alias
      SET reply->diaglist[loopitems].value = request->diaglist[loopitems].value
    ENDFOR
    SET serviceitemdesc = validateeventrep->serviceitemdesc
    IF ((validateeventrep->requiredfieldstatus="F"))
     SET chargeeventstatus = cs4002322_failed_cd
    ENDIF
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("getValidItemValues","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (getprice(null=vc) =null)
   CALL logmessage("getPrice","Begin sub",log_debug)
   DECLARE pindex = i2 WITH noconstant(0)
   DECLARE asaflexfieldindex = i2 WITH noconstant(0)
   DECLARE flexfieldsidx = i2 WITH noconstant(0)
   SET stat = alterlist(pireq->objarray,1)
   CALL logmessage("getPrice","Get bill item info",log_debug)
   IF ((request->serviceitemid > 0))
    SELECT INTO "nl:"
     FROM bill_item b
     WHERE (b.bill_item_id=request->serviceitemid)
     DETAIL
      pireq->objarray[1].ext_parent_reference_id = b.ext_parent_reference_id, pireq->objarray[1].
      ext_parent_contributor_cd = b.ext_parent_contributor_cd
     WITH nocounter
    ;end select
   ELSE
    CALL logmessage("getPrice","serviceItemID is zero",log_debug)
    RETURN
   ENDIF
   CALL logmessage("getPrice","Get encounter info",log_debug)
   IF ((request->encounterid > 0))
    SET pireq->objarray[1].encntr_id = encounterinfo->encntr_id
    SET pireq->objarray[1].person_id = encounterinfo->person_id
    SET pireq->objarray[1].encntr_org_id = encounterinfo->encntr_org_id
    SET pireq->objarray[1].fin_class_cd = encounterinfo->fin_class_cd
    SET pireq->objarray[1].encntr_type_cd = encounterinfo->encntr_type_cd
    SET pireq->objarray[1].loc_nurse_unit_cd = encounterinfo->loc_nurse_unit_cd
    SET pireq->objarray[1].health_plan_id = encounterinfo->primaryhealthplanid
    SET pireq->objarray[1].orderingphysid = request->orderingphysid
    SET pireq->objarray[1].renderingphysid = request->renderingphysid
    SET pireq->objarray[1].serviceresourcecd = request->serviceresourcecd
   ELSE
    CALL logmessage("getPrice","encounterID is zero",log_debug)
    RETURN
   ENDIF
   CALL logmessage("getPrice","Get service date/time",log_debug)
   IF ((request->servicedttm > 0))
    SET pireq->objarray[1].service_dt_tm = cnvtdatetime(request->servicedttm)
   ELSE
    SET pireq->objarray[1].service_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   CALL logmessage("getPrice","Get quantity",log_debug)
   SET pireq->objarray[1].item_quantity = request->quantity
   CALL logmessage("getPrice","Get performing location",log_debug)
   SET pireq->objarray[1].perf_loc_cd = request->performinglocationcd
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(request->flexfields,5)))
    PLAN (d1
     WHERE (request->flexfields[d1.seq].fieldtypecd IN (cs305570_docmin_cd, cs305570_numclients_cd,
     cs305570_numtherapist_cd, cs305570_quantity_cd, cs305570_travelmin_cd)))
    HEAD REPORT
     pindex = 0
    DETAIL
     pindex += 1, stat = alterlist(pireq->objarray[1].charge_mod,pindex), pireq->objarray[1].
     charge_mod[pindex].charge_mod_type_cd = cs13019_prompt_cd,
     pireq->objarray[1].charge_mod[pindex].field1_id = request->flexfields[d1.seq].fieldtypecd, pireq
     ->objarray[1].charge_mod[pindex].field7 = uar_get_code_display(request->flexfields[d1.seq].
      fieldtypecd), pireq->objarray[1].charge_mod[pindex].field2_id = request->flexfields[d1.seq].
     fieldnbr
    WITH nocounter
   ;end select
   SET asaflexfieldindex = locateval(flexfieldsidx,1,size(request->flexfields,5),cs4002352_asacode_cd,
    request->flexfields[flexfieldsidx].fieldtypecd)
   IF (asaflexfieldindex > 0)
    FOR (cptmodifierscnt = 1 TO size(request->cptlist,5))
      SET pindex += 1
      SET stat = alterlist(pireq->objarray[1].charge_mod,pindex)
      SET pireq->objarray[1].charge_mod[pindex].charge_mod_type_cd = cs13019_billcode_cd
      SET pireq->objarray[1].charge_mod[pindex].field6 = request->cptlist[cptmodifierscnt].alias
      SET pireq->objarray[1].charge_mod[pindex].field7 = request->cptlist[cptmodifierscnt].alias
      SET pireq->objarray[1].charge_mod[pindex].field3_id = uar_get_code_by("DISPLAY",17769,request->
       cptlist[cptmodifierscnt].alias)
    ENDFOR
   ENDIF
   FOR (diagcnt = 1 TO size(request->diaglist,5))
     SET pindex += 1
     SET stat = alterlist(pireq->objarray[1].charge_mod,pindex)
     SET pireq->objarray[1].charge_mod[pindex].charge_mod_type_cd = cs13019_billcode_cd
     SET pireq->objarray[1].charge_mod[pindex].field6 = request->diaglist[diagcnt].alias
     SET pireq->objarray[1].charge_mod[pindex].field7 = request->diaglist[diagcnt].alias
     SET pireq->objarray[1].charge_mod[pindex].nomen_id = request->diaglist[diagcnt].value
     SET pireq->objarray[1].charge_mod[pindex].field1_id = cs14002_icd9_cd
     SET pireq->objarray[1].charge_mod[pindex].field2_id = diagcnt
   ENDFOR
   CALL logmessage("getPrice","Call afc_run_price_inquiry",log_debug)
   EXECUTE afc_run_price_inquiry  WITH replace("REQUEST",pireq), replace("REPLY",pirep)
   IF (size(pirep->charges,5) > 0)
    SET reply->price = pirep->charges[1].item_extended_price
    SET reply->quantity = pirep->charges[1].item_quantity
    IF ((reply->quantity < 1.0))
     CALL logmessage("getPrice","calculated quantity is not valid for the calculation method",
      log_debug)
     SET reply->quantity = request->quantity
    ENDIF
   ELSE
    CALL logmessage("getPrice","Nothing replied from afc_run_price_inquiry",log_debug)
   ENDIF
   CALL logmessage("getPrice","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (addchargeeventdetail(null=vc) =i2)
   CALL logmessage("addChargeEventDetail","Begin sub",log_debug)
   SET stat = alterlist(chargebatchdetailreq->objarray,1)
   SET chargebatchdetailreq->objarray[1].charge_batch_id = reply->chargebatchid
   SET chargebatchdetailreq->objarray[1].encntr_id = request->encounterid
   SET chargebatchdetailreq->objarray[1].ordering_phys_id = request->orderingphysid
   SET chargebatchdetailreq->objarray[1].rendering_phys_id = request->renderingphysid
   SET chargebatchdetailreq->objarray[1].bill_item_id = request->serviceitemid
   SET chargebatchdetailreq->objarray[1].service_item_ident = request->serviceitemtext
   IF ((request->serviceitemmode=1))
    SET chargebatchdetailreq->objarray[1].service_item_ident_type_cd = cs4002324_cdm_cd
   ELSEIF ((request->serviceitemmode=2))
    SET chargebatchdetailreq->objarray[1].service_item_ident_type_cd = cs4002324_icd_cd
   ELSE
    SET chargebatchdetailreq->objarray[1].service_item_ident_type_cd = cs4002324_cpt_cd
   ENDIF
   SET chargebatchdetailreq->objarray[1].service_item_qty = reply->quantity
   SET chargebatchdetailreq->objarray[1].service_item_price_amt = reply->price
   SET chargebatchdetailreq->objarray[1].service_item_desc = serviceitemdesc
   SET chargebatchdetailreq->objarray[1].service_dt_tm = cnvtdatetime(request->servicedttm)
   SET chargebatchdetailreq->objarray[1].perf_loc_cd = request->performinglocationcd
   SET chargebatchdetailreq->objarray[1].status_cd = chargeeventstatus
   SET chargebatchdetailreq->objarray[1].diagnosis_pointer_txt = request->diagnosispointertext
   SET chargebatchdetailreq->objarray[1].active_ind = 1
   SET chargebatchdetailreq->objarray[1].item_copay_amt = request->copayamt
   SET chargebatchdetailreq->objarray[1].item_deductible_amt = request->deductibleamt
   SET chargebatchdetailreq->objarray[1].patient_responsibility_flag = request->patrespflag
   IF ((validate(request->serviceresourcecd,- (0.00001)) != - (0.00001)))
    SET chargebatchdetailreq->objarray[1].service_resource_cd = request->serviceresourcecd
   ENDIF
   CALL logmessage("addChargeEventDetail","Call data access to save charge_batch_detail",log_debug)
   EXECUTE afc_da_add_charge_batch_detail  WITH replace("REQUEST",chargebatchdetailreq), replace(
    "REPLY",chargebatchdetailrep)
   IF ((chargebatchdetailrep->status_data.status="S"))
    CALL logmessage("addChargeEventDetail","Status is successful",log_debug)
    FOR (modobjcnt = 1 TO size(chargebatchdetailrep->mod_objs,5))
      FOR (modreccnt = 1 TO size(chargebatchdetailrep->mod_objs[modobjcnt].mod_recs,5))
        SET reply->chargeeventid = cnvtreal(chargebatchdetailrep->mod_objs[modobjcnt].mod_recs[
         modreccnt].pk_values)
      ENDFOR
    ENDFOR
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("addChargeEventDetail","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (uptchargeeventdetail(null=vc) =i2)
   SET updt_cnt = 0
   CALL logmessage("uptChargeEventDetail","Begin sub",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch_detail c
    WHERE (c.charge_batch_detail_id=request->chargeeventid)
    DETAIL
     updt_cnt = c.updt_cnt
    WITH nocounter
   ;end select
   SET reply->chargeeventid = request->chargeeventid
   SET stat = alterlist(chargebatchdetailreq->objarray,1)
   SET chargebatchdetailreq->objarray[1].charge_batch_detail_id = reply->chargeeventid
   SET chargebatchdetailreq->objarray[1].charge_batch_id = reply->chargebatchid
   SET chargebatchdetailreq->objarray[1].encntr_id = request->encounterid
   SET chargebatchdetailreq->objarray[1].ordering_phys_id = request->orderingphysid
   SET chargebatchdetailreq->objarray[1].rendering_phys_id = request->renderingphysid
   SET chargebatchdetailreq->objarray[1].bill_item_id = request->serviceitemid
   SET chargebatchdetailreq->objarray[1].service_item_ident = request->serviceitemtext
   IF ((request->serviceitemmode=1))
    SET chargebatchdetailreq->objarray[1].service_item_ident_type_cd = cs4002324_cdm_cd
   ELSEIF ((request->serviceitemmode=2))
    SET chargebatchdetailreq->objarray[1].service_item_ident_type_cd = cs4002324_icd_cd
   ELSE
    SET chargebatchdetailreq->objarray[1].service_item_ident_type_cd = cs4002324_cpt_cd
   ENDIF
   SET chargebatchdetailreq->objarray[1].service_item_qty = reply->quantity
   SET chargebatchdetailreq->objarray[1].service_item_price_amt = reply->price
   SET chargebatchdetailreq->objarray[1].service_item_desc = serviceitemdesc
   IF ((reply->servicedttmvalidind != 7))
    SET chargebatchdetailreq->objarray[1].service_dt_tm = cnvtdatetime(request->servicedttm)
   ELSE
    SET chargebatchdetailreq->objarray[1].service_dt_tm = 0.0
   ENDIF
   SET chargebatchdetailreq->objarray[1].perf_loc_cd = request->performinglocationcd
   SET chargebatchdetailreq->objarray[1].status_cd = chargeeventstatus
   SET chargebatchdetailreq->objarray[1].diagnosis_pointer_txt = request->diagnosispointertext
   SET chargebatchdetailreq->objarray[1].item_copay_amt = request->copayamt
   SET chargebatchdetailreq->objarray[1].item_deductible_amt = request->deductibleamt
   SET chargebatchdetailreq->objarray[1].patient_responsibility_flag = request->patrespflag
   SET chargebatchdetailreq->objarray[1].active_ind = 1
   SET chargebatchdetailreq->objarray[1].updt_cnt = updt_cnt
   IF ((validate(request->serviceresourcecd,- (0.00001)) != - (0.00001)))
    SET chargebatchdetailreq->objarray[1].service_resource_cd = request->serviceresourcecd
   ENDIF
   EXECUTE afc_da_upt_charge_batch_detail  WITH replace("REQUEST",chargebatchdetailreq), replace(
    "REPLY",chargebatchdetailrep)
   IF ((chargebatchdetailrep->status_data.status="S"))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("uptChargeEventDetail","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (savechargeeventdetailcodes(null=vc) =i2)
   CALL logmessage("saveChargeEventDetailCodes","Begin sub",log_debug)
   CALL logmessage("saveChargeEventDetailCodes","Query for detail codes",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch_detail_code c
    WHERE (c.charge_batch_detail_id=reply->chargeeventid)
    DETAIL
     loopcount += 1, stat = alterlist(chargebatchdtlcdreq->objarray,loopcount), chargebatchdtlcdreq->
     objarray[loopcount].charge_batch_detail_code_id = c.charge_batch_detail_code_id,
     chargebatchdtlcdreq->objarray[loopcount].charge_batch_detail_id = c.charge_batch_detail_id,
     chargebatchdtlcdreq->objarray[loopcount].parent_entity_name = c.parent_entity_name,
     chargebatchdtlcdreq->objarray[loopcount].parent_entity_id = c.parent_entity_id,
     chargebatchdtlcdreq->objarray[loopcount].type_ident = c.type_ident, chargebatchdtlcdreq->
     objarray[loopcount].priority_seq = c.priority_seq, chargebatchdtlcdreq->objarray[loopcount].
     type_cd = c.type_cd,
     chargebatchdtlcdreq->objarray[loopcount].updt_cnt = c.updt_cnt
    WITH nocounter
   ;end select
   IF (size(chargebatchdtlcdreq->objarray,5) > 0)
    CALL logmessage("saveChargeEventDetailCodes","Inactivate detail codes",log_debug)
    EXECUTE afc_da_upt_charge_batch_dtl_cd  WITH replace("REQUEST",chargebatchdtlcdreq), replace(
     "REPLY",chargebatchdtlcdrep)
    IF ((chargebatchdtlcdrep->status_data.status != "S"))
     CALL logmessage("saveChargeEventDetailCodes","Error inactivating existing detail codes",
      log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   SET stat = initrec(chargebatchdtlcdreq)
   SET stat = initrec(chargebatchdtlcdrep)
   CALL logmessage("saveChargeEventDetailCodes","Load modifiers",log_debug)
   FOR (loopcount = 1 TO size(validateeventrep->cptlist,5))
     SET stat = alterlist(chargebatchdtlcdreq->objarray,loopcount)
     SET chargebatchdtlcdreq->objarray[loopcount].charge_batch_detail_id = reply->chargeeventid
     SET chargebatchdtlcdreq->objarray[loopcount].type_cd = cs4002321_modifier_cd
     SET chargebatchdtlcdreq->objarray[loopcount].parent_entity_id = validateeventrep->cptlist[
     loopcount].value
     SET chargebatchdtlcdreq->objarray[loopcount].parent_entity_name = "CODE_VALUE"
     SET chargebatchdtlcdreq->objarray[loopcount].type_ident = validateeventreq->cptlist[loopcount].
     alias
     SET chargebatchdtlcdreq->objarray[loopcount].priority_seq = loopcount
     SET chargebatchdtlcdreq->objarray[loopcount].active_ind = 1
   ENDFOR
   SET modcnt = size(chargebatchdtlcdreq->objarray,5)
   CALL logmessage("saveChargeEventDetailCodes","Load dx codes",log_debug)
   FOR (loopcount = 1 TO size(request->diaglist,5))
     SET stat = alterlist(chargebatchdtlcdreq->objarray,(loopcount+ modcnt))
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].charge_batch_detail_id = reply->
     chargeeventid
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].type_cd = cs4002321_diag_cd
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].parent_entity_id = request->diaglist[
     loopcount].value
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].parent_entity_name = "NOMENCLATURE"
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].type_ident = request->diaglist[loopcount]
     .alias
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].priority_seq = loopcount
     SET chargebatchdtlcdreq->objarray[(loopcount+ modcnt)].active_ind = 1
   ENDFOR
   IF (size(pirep->charges[1].mods,5) > 0)
    CALL logmessage("saveChargeEventDetailCodes","Load CDM codes",log_debug)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(pirep->charges[1].mods,5)))
     PLAN (d1
      WHERE uar_get_code_meaning(pirep->charges[1].mods[d1.seq].field1_id)="CDM_SCHED"
       AND (pirep->charges[1].mods[d1.seq].field2_id=1))
     HEAD REPORT
      detailcodescount = (size(chargebatchdtlcdreq->objarray,5)+ 1)
     DETAIL
      stat = alterlist(chargebatchdtlcdreq->objarray,detailcodescount), chargebatchdtlcdreq->
      objarray[detailcodescount].charge_batch_detail_id = reply->chargeeventid, chargebatchdtlcdreq->
      objarray[detailcodescount].type_cd = cs4002321_cdm_cd,
      chargebatchdtlcdreq->objarray[detailcodescount].parent_entity_id = pirep->charges[1].mods[d1
      .seq].field1_id, chargebatchdtlcdreq->objarray[detailcodescount].parent_entity_name =
      "CODE_VALUE", chargebatchdtlcdreq->objarray[detailcodescount].type_ident = pirep->charges[1].
      mods[d1.seq].field6,
      chargebatchdtlcdreq->objarray[detailcodescount].priority_seq = pirep->charges[1].mods[d1.seq].
      field2_id, chargebatchdtlcdreq->objarray[detailcodescount].active_ind = true, reply->cdmdisplay
       = pirep->charges[1].mods[d1.seq].field6
     WITH nocounter
    ;end select
   ENDIF
   IF (size(chargebatchdtlcdreq->objarray,5) > 0)
    CALL logmessage("saveChargeEventDetailCodes","Insert detail codes",log_debug)
    EXECUTE afc_da_add_charge_batch_dtl_cd  WITH replace("REQUEST",chargebatchdtlcdreq), replace(
     "REPLY",chargebatchdtlcdrep)
    IF ((chargebatchdtlcdrep->status_data.status != "S"))
     CALL logmessage("saveChargeEventDetailCodes","Failed inserting detail codes",log_debug)
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
   ELSE
    RETURN(true)
   ENDIF
   CALL logmessage("saveChargeEventDetailCodes","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (savechargeeventflexfields(null=vc) =i2)
   CALL logmessage("saveChargeEventFlexFields","Begin sub",log_debug)
   SET fieldcnt = 0
   CALL logmessage("saveChargeEventFlexFields","Query for flex fields",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch_detail_field c
    WHERE (c.charge_batch_detail_id=reply->chargeeventid)
     AND c.active_ind=1
    DETAIL
     fieldcnt += 1, stat = alterlist(chargebatchdtlfldreq->objarray,fieldcnt), chargebatchdtlfldreq->
     objarray[fieldcnt].charge_batch_detail_field_id = c.charge_batch_detail_field_id,
     chargebatchdtlfldreq->objarray[fieldcnt].charge_batch_detail_id = c.charge_batch_detail_id,
     chargebatchdtlfldreq->objarray[fieldcnt].field_type_cd = c.field_type_cd, chargebatchdtlfldreq->
     objarray[fieldcnt].field_value_dt_tm = c.field_value_dt_tm,
     chargebatchdtlfldreq->objarray[fieldcnt].field_value_char = c.field_value_char,
     chargebatchdtlfldreq->objarray[fieldcnt].field_value_nbr = c.field_value_nbr,
     chargebatchdtlfldreq->objarray[fieldcnt].field_value_ind = c.field_value_ind,
     chargebatchdtlfldreq->objarray[fieldcnt].field_value_cd = c.field_value_cd, chargebatchdtlfldreq
     ->objarray[fieldcnt].updt_cnt = c.updt_cnt, chargebatchdtlfldreq->objarray[fieldcnt].
     field_value_start_dt_tm = c.field_value_start_dt_tm,
     chargebatchdtlfldreq->objarray[fieldcnt].field_value_end_dt_tm = c.field_value_end_dt_tm,
     chargebatchdtlfldreq->objarray[fieldcnt].field_value_prsnl_id = c.field_value_prsnl_id,
     chargebatchdtlfldreq->objarray[fieldcnt].priority_seq = c.priority_seq
    WITH nocounter
   ;end select
   IF (size(chargebatchdtlfldreq->objarray,5) > 0)
    CALL logmessage("saveChargeEventFlexFields","Inactivate flex fields",log_debug)
    EXECUTE afc_da_upt_chrg_batch_dtl_fld  WITH replace("REQUEST",chargebatchdtlfldreq), replace(
     "REPLY",chargebatchdtlfldrep)
    IF ((chargebatchdtlfldrep->status_data.status != "S"))
     CALL logmessage("saveChargeEventFlexFields","Error inactivating existing flex fields",log_debug)
     RETURN(false)
    ENDIF
   ENDIF
   SET stat = initrec(chargebatchdtlfldreq)
   SET stat = initrec(chargebatchdtlfldrep)
   SET stat = alterlist(chargebatchdtlfldreq->objarray,size(request->flexfields,5))
   FOR (fieldcnt = 1 TO size(request->flexfields,5))
     SET chargebatchdtlfldreq->objarray[fieldcnt].charge_batch_detail_id = reply->chargeeventid
     SET chargebatchdtlfldreq->objarray[fieldcnt].field_type_cd = request->flexfields[fieldcnt].
     fieldtypecd
     SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_dt_tm = request->flexfields[fieldcnt].
     fielddatetime
     SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_char = request->flexfields[fieldcnt].
     fieldchar
     SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_nbr = request->flexfields[fieldcnt].
     fieldnbr
     SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_ind = request->flexfields[fieldcnt].
     fieldind
     SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_cd = request->flexfields[fieldcnt].
     fieldcd
     SET chargebatchdtlfldreq->objarray[fieldcnt].active_ind = 1
     IF (validate(request->flexfields[fieldcnt].fieldstartdatetime,0.0) > 0.0)
      SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_start_dt_tm = validate(request->
       flexfields[fieldcnt].fieldstartdatetime,0.0)
     ENDIF
     IF (validate(request->flexfields[fieldcnt].fieldenddatetime,0.0) > 0.0)
      SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_end_dt_tm = validate(request->
       flexfields[fieldcnt].fieldenddatetime,0.0)
     ENDIF
     IF (validate(request->flexfields[fieldcnt].fieldprsnlid,0.0) > 0.0)
      SET chargebatchdtlfldreq->objarray[fieldcnt].field_value_prsnl_id = validate(request->
       flexfields[fieldcnt].fieldprsnlid,0.0)
     ENDIF
     IF (validate(request->flexfields[fieldcnt].priorityseq,0) > 0)
      SET chargebatchdtlfldreq->objarray[fieldcnt].priority_seq = validate(request->flexfields[
       fieldcnt].priorityseq,0.0)
     ENDIF
   ENDFOR
   IF (size(chargebatchdtlfldreq->objarray,5) > 0)
    CALL logmessage("saveChargeEventFlexFields","Insert new flex fields",log_debug)
    EXECUTE afc_da_add_chrg_batch_dtl_fld  WITH replace("REQUEST",chargebatchdtlfldreq), replace(
     "REPLY",chargebatchdtlfldrep)
    IF ((chargebatchdtlfldrep->status_data.status != "S"))
     CALL echorecord(chargebatchdtlfldrep)
     CALL logmessage("saveChargeEventFlexFields","Error inserting existing flex fields",log_debug)
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatebatchstatus(dstatus=f8) =i2)
   CALL logmessage("updateBatchStatus","Begin sub",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch c
    WHERE (c.charge_batch_id=reply->chargebatchid)
    DETAIL
     batchcnt += 1, stat = alterlist(chrgbatchstatusreq->objarray,batchcnt), chrgbatchstatusreq->
     objarray[batchcnt].charge_batch_id = c.charge_batch_id,
     chrgbatchstatusreq->objarray[batchcnt].created_prsnl_id = c.created_prsnl_id, chrgbatchstatusreq
     ->objarray[batchcnt].assigned_prsnl_id = c.assigned_prsnl_id, chrgbatchstatusreq->objarray[
     batchcnt].user_defined_ind = c.user_defined_ind,
     chrgbatchstatusreq->objarray[batchcnt].active_ind = c.active_ind, chrgbatchstatusreq->objarray[
     batchcnt].status_cd = dstatus, chrgbatchstatusreq->objarray[batchcnt].status_dt_tm =
     cnvtdatetime(sysdate),
     chrgbatchstatusreq->objarray[batchcnt].created_dt_tm = cnvtdatetime(c.created_dt_tm),
     chrgbatchstatusreq->objarray[batchcnt].accessed_dt_tm = cnvtdatetime(c.accessed_dt_tm),
     chrgbatchstatusreq->objarray[batchcnt].updt_cnt = c.updt_cnt
    WITH nocounter
   ;end select
   EXECUTE afc_da_upt_charge_batch  WITH replace("REQUEST",chrgbatchstatusreq), replace("REPLY",
    chrgbatchstatusrep)
   IF ((chrgbatchstatusrep->status_data.status="S"))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
   CALL logmessage("updateBatchStatus","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (checkdates(null=vc) =null)
   CALL logmessage("checkDates","Begin sub",log_debug)
   IF ((request->chargeeventid > 0.0))
    SELECT INTO "nl:"
     FROM charge_batch_detail c
     WHERE (c.charge_batch_detail_id=request->chargeeventid)
     DETAIL
      createddttm = c.created_dt_tm
     WITH nocounter
    ;end select
   ELSE
    SET createddttm = cnvtdatetime(sysdate)
   ENDIF
   SELECT INTO "nl:"
    FROM encounter e
    WHERE (e.encntr_id=request->encounterid)
    DETAIL
     reply->servicedttmvalidind = checkservicedate(request->servicedttm,e.reg_dt_tm,e.pre_reg_dt_tm,e
      .disch_dt_tm,createddttm)
    WITH nocounter
   ;end select
   CALL logmessage("checkDates","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE (getencounterinfo(pencntrid=f8) =null)
   CALL logmessage("getEncounterInfo","Begin sub",log_debug)
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE e.encntr_id=pencntrid)
    DETAIL
     encounterinfo->encntr_id = e.encntr_id, encounterinfo->person_id = e.person_id, encounterinfo->
     encntr_type = e.encntr_type_cd,
     encounterinfo->encntr_org_id = e.organization_id, encounterinfo->fin_class_cd = e
     .financial_class_cd, encounterinfo->loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     encounterinfo->loc_building_cd = e.loc_building_cd, encounterinfo->loc_facility_cd = e
     .loc_facility_cd, encounterinfo->program_service_cd = e.program_service_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encntr_plan_reltn epr
    WHERE epr.encntr_id=pencntrid
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND epr.active_ind=1
    DETAIL
     IF (epr.priority_seq=1)
      encounterinfo->primaryhealthplanid = epr.health_plan_id, encounterinfo->shareofcost = epr
      .deduct_amt
     ELSE
      encounterinfo->secondaryhealthplanid = epr.health_plan_id
     ENDIF
    WITH nocounter
   ;end select
   CALL logmessage("getEncounterInfo","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE evaluateforpatientresposibility(null)
   CALL logmessage("evaluateForPatientResposibility","Begin sub",log_debug)
   DECLARE pactivitytypecode = f8 WITH noconstant(0.0)
   DECLARE pindex = i2 WITH noconstant(0)
   DECLARE pcnt = i2 WITH noconstant(1)
   IF ((request->serviceitemid > 0.0))
    SELECT INTO "nl:"
     FROM bill_item bi
     WHERE (bi.bill_item_id=request->serviceitemid)
     DETAIL
      pactivitytypecode = bi.ext_owner_cd
     WITH nocounter
    ;end select
   ELSE
    CALL logmessage("evaluateForPatientResposibility","Service Item ID is zero",log_debug)
    RETURN(false)
   ENDIF
   IF ((encounterinfo->loc_facility_cd > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "FACILITY_CD"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->loc_facility_cd)
   ENDIF
   IF ((encounterinfo->loc_nurse_unit_cd > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "LOC_NURSE_UNIT_CD"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->loc_nurse_unit_cd)
   ENDIF
   IF ((encounterinfo->loc_building_cd > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "LOC_BUILDING_CD"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->loc_building_cd)
   ENDIF
   IF ((request->serviceitemid > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "BILL_ITEM_ID"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(request->serviceitemid)
   ENDIF
   IF ((encounterinfo->primaryhealthplanid > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "HEALTH_PLAN_ID"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->primaryhealthplanid)
   ENDIF
   IF ((encounterinfo->secondaryhealthplanid > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "SECONDARY_HEALTH_PLAN_ID"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->secondaryhealthplanid)
   ENDIF
   IF (pactivitytypecode > 0.0)
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "ACTIVITY_TYPE"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(pactivitytypecode)
   ENDIF
   IF ((encounterinfo->encntr_type > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "ENCNTR_TYPE"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(cnvtstring(encounterinfo->encntr_type))
   ENDIF
   IF ((encounterinfo->fin_class_cd > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "FIN_CLASS"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->fin_class_cd)
   ENDIF
   IF ((encounterinfo->program_service_cd > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "PROGRAM_SERVICE"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->program_service_cd)
   ENDIF
   IF ((encounterinfo->shareofcost > 0.0))
    SET pindex += 1
    SET stat = alterlist(pbmpatrespreq->qual,pindex)
    SET pbmpatrespreq->qual[pindex].param_name = "MONTHLY_SOC"
    SET pbmpatrespreq->qual[pindex].param_value = cnvtstring(encounterinfo->shareofcost)
   ENDIF
   EXECUTE pft_pbm_pat_responsibility  WITH replace("REQUEST",pbmpatrespreq), replace("REPLY",
    pbmpatresprep)
   SET pindex = 0
   IF (cnvtupper(pbmpatresprep->status_data.status)="S")
    FOR (pcnt = 1 TO size(pbmpatresprep->qual,5))
      IF ((pbmpatresprep->qual[pcnt].param_name != "PFT_PBR_WRAPPER_STATUS")
       AND trim(pbmpatresprep->qual[pcnt].param_value,3) != "")
       SET pindex += 1
       SET stat = alterlist(reply->serviceitems[1].categories[1].patrespfields,pindex)
       SET reply->serviceitems[1].categories[1].patrespfields[pindex].fieldname = pbmpatresprep->
       qual[pcnt].param_name
       SET reply->serviceitems[1].categories[1].patrespfields[pindex].fielddisplay = pbmpatresprep->
       qual[pcnt].param_value
       IF ((pbmpatresprep->qual[pcnt].param_name IN ("DEDUCTIBLE", "COPAY")))
        SET reply->serviceitems[1].categories[1].patrespfields[pindex].fieldtype = "CURRENCY"
       ELSEIF ((pbmpatresprep->qual[pcnt].param_name="NONCOVERED"))
        SET reply->serviceitems[1].categories[1].patrespfields[pindex].fieldtype = "YESNO"
        SET stat = alterlist(reply->serviceitems[1].categories[1].patrespfields[pindex].optionlist,2)
        SET reply->serviceitems[1].categories[1].patrespfields[pindex].optionlist[1].optionvalue =
        i18n_yes
        SET reply->serviceitems[1].categories[1].patrespfields[pindex].optionlist[1].optioncd = 1
        SET reply->serviceitems[1].categories[1].patrespfields[pindex].optionlist[2].optionvalue =
        i18n_no
        SET reply->serviceitems[1].categories[1].patrespfields[pindex].optionlist[2].optioncd = 2
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (size(reply->serviceitems[1].categories[1].patrespfields,5) > 0)
    SET reply->serviceitems[1].serviceitemid = request->serviceitemid
    SET reply->serviceitems[1].categories[1].categoryname = i18n_pat_responsibility
    SET reply->haspatresponsibility = true
    RETURN(true)
   ELSE
    SET reply->haspatresponsibility = false
    RETURN(false)
   ENDIF
   CALL logmessage("evaluateForPatientResposibility","End sub",log_debug)
 END ;Subroutine
#exit_script
 SUBROUTINE (logmodcapability(dummyvar=i2) =null)
   DECLARE lon_collector_id = vc WITH protect, constant("2015.2.00161.1")
   IF (validate(debug,- (1)) > 0)
    CALL echo("Begin Sub logModCapability")
    CALL echo("----------------------------------")
    CALL echorecord(request)
    CALL echo(lon_collector_id)
   ENDIF
   RECORD capabilitylogrequest(
     1 capability_ident = vc
     1 teamname = vc
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
   SET capabilitylogrequest->capability_ident = lon_collector_id
   SET capabilitylogrequest->teamname = "PATIENT_ACCOUNTING"
   SET stat = alterlist(capabilitylogrequest->entities,1)
   SET capabilitylogrequest->entities[1].entity_id = reply->chargeeventid
   SET capabilitylogrequest->entities[1].entity_name = "CHARGE"
   CALL echorecord(capabilitylogrequest)
   EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilitylogrequest), replace("REPLY",
    capabilitylogreply)
   CALL echorecord(capabilitylogreply)
   IF ((capabilitylogreply->status_data.status != "S"))
    CALL logmessage(curprog,"logCapabilityInfo: pft_log_solution_capability failed.",log_error)
   ENDIF
 END ;Subroutine
 IF (validate(debug,0)=1)
  CALL echorecord(pireq)
  CALL echorecord(pirep)
  CALL echorecord(pbmpatrespreq)
  CALL echorecord(pbmpatresprep)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD chargebatchreq
 FREE RECORD chargebatchrep
 FREE RECORD validateeventreq
 FREE RECORD validateeventrep
 FREE RECORD pireq
 FREE RECORD pirep
 FREE RECORD chargebatchdetailreq
 FREE RECORD chargebatchdetailrep
 FREE RECORD chargebatchdtlcdreq
 FREE RECORD chargebatchdtlcdrep
 FREE RECORD chargebatchdtlfldreq
 FREE RECORD chargebatchdtlfldrep
 FREE RECORD chrgbatchstatusreq
 FREE RECORD chrgbatchstatusrep
 FREE RECORD encounterinfo
 FREE RECORD pbmpatrespreq
 FREE RECORD pbmpatresprep
END GO
