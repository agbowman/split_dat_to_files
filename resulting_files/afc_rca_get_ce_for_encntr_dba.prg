CREATE PROGRAM afc_rca_get_ce_for_encntr:dba
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
 DECLARE initializeservicedateval(dummy=vc) = i2
 SUBROUTINE initializeservicedateval(dummy)
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
 DECLARE checkservicedate(servicedttm=f8,admitdttm=f8,preregdttm=f8,dischargedttm=f8,systemdttm=f8)
  = i2
 SUBROUTINE checkservicedate(servicedttm,admitdttm,preregdttm,dischargedttm,systemdttm)
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
 IF ( NOT (validate(reply->status_data)))
  FREE RECORD reply
  RECORD reply(
    1 chargeevents[*]
      2 chargeeventid = f8
      2 orderingphysname = vc
      2 orderingphysid = f8
      2 serviceitemid = f8
      2 serviceitemident = vc
      2 serviceitemidenttype = i2
      2 serviceitemqty = f8
      2 serviceitempriceamt = f8
      2 serviceitemdesc = vc
      2 servicedttm = dq8
      2 perfloccd = f8
      2 status = i2
      2 diagnosispointer = i4
      2 batchicdcodes[*]
        3 alias = vc
        3 valid = i2
        3 aliasid = f8
      2 batchmodifiercodes[*]
        3 alias = vc
        3 valid = i2
        3 aliasid = f8
      2 flexfields[*]
        3 fieldtypecd = f8
        3 fielddatetime = dq8
        3 fieldchar = vc
        3 fieldnbr = f8
        3 fieldind = i2
        3 fieldcd = f8
        3 fieldvaluetype = vc
        3 fieldname = vc
        3 fieldstartdatetime = dq8
        3 fieldenddatetime = dq8
        3 fieldprsnlid = f8
        3 priorityseq = i2
      2 servicedttmvalidind = i2
      2 diagnosispointertext = vc
      2 renderingphysname = vc
      2 renderingphysid = f8
      2 cdmcode = vc
      2 servicetodate = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(cs4002352_suprvsngprov_cd)))
  DECLARE cs4002352_suprvsngprov_cd = f8 WITH protect, constant(getcodevalue(4002352,"SUPRVSNGPROV",0
    ))
 ENDIF
 IF ( NOT (validate(cs4002352_fromtodate_cd)))
  DECLARE cs4002352_fromtodate_cd = f8 WITH protect, constant(getcodevalue(4002352,"FROMTODATE",0))
 ENDIF
 DECLARE cntbatch = i4 WITH protect, noconstant(0)
 DECLARE cntfields = i4 WITH protect, noconstant(0)
 CALL beginservice("375834.007")
 CALL logmessage("Main","Begining main processing",log_debug)
 CALL initializeservicedateval(0)
 CALL logmessage("Main","Get charge details",log_debug)
 SELECT INTO "nl:"
  FROM charge_batch_detail c,
   prsnl p,
   prsnl p1,
   encounter e
  PLAN (c
   WHERE (c.charge_batch_id=request->chargebatchid)
    AND (c.encntr_id=request->encntrid)
    AND c.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=c.encntr_id)
   JOIN (p
   WHERE p.person_id=outerjoin(c.ordering_phys_id))
   JOIN (p1
   WHERE p1.person_id=outerjoin(c.rendering_phys_id))
  ORDER BY c.charge_batch_detail_id
  DETAIL
   cntbatch = (cntbatch+ 1)
   IF (mod(cntbatch,10)=1)
    stat = alterlist(reply->chargeevents,(cntbatch+ 9))
   ENDIF
   reply->chargeevents[cntbatch].chargeeventid = c.charge_batch_detail_id, reply->chargeevents[
   cntbatch].orderingphysid = c.ordering_phys_id, reply->chargeevents[cntbatch].orderingphysname = p
   .name_full_formatted,
   reply->chargeevents[cntbatch].renderingphysid = c.rendering_phys_id, reply->chargeevents[cntbatch]
   .renderingphysname = p1.name_full_formatted, reply->chargeevents[cntbatch].serviceitemid = c
   .bill_item_id,
   reply->chargeevents[cntbatch].serviceitemident = c.service_item_ident
   IF (uar_get_code_meaning(c.service_item_ident_type_cd)="CDM")
    reply->chargeevents[cntbatch].serviceitemidenttype = 1
   ELSEIF (uar_get_code_meaning(c.service_item_ident_type_cd)="ICD")
    reply->chargeevents[cntbatch].serviceitemidenttype = 2
   ELSE
    reply->chargeevents[cntbatch].serviceitemidenttype = 3
   ENDIF
   reply->chargeevents[cntbatch].serviceitemqty = c.service_item_qty, reply->chargeevents[cntbatch].
   serviceitempriceamt = c.service_item_price_amt, reply->chargeevents[cntbatch].serviceitemdesc = c
   .service_item_desc,
   reply->chargeevents[cntbatch].servicedttm = c.service_dt_tm, reply->chargeevents[cntbatch].
   servicedttmvalidind = checkservicedate(c.service_dt_tm,e.reg_dt_tm,e.pre_reg_dt_tm,e.disch_dt_tm,c
    .created_dt_tm), reply->chargeevents[cntbatch].perfloccd = c.perf_loc_cd,
   reply->chargeevents[cntbatch].diagnosispointertext = c.diagnosis_pointer_txt
   IF (uar_get_code_meaning(c.status_cd)="PENDING")
    reply->chargeevents[cntbatch].status = 1
   ELSEIF (uar_get_code_meaning(c.status_cd)="FAILED")
    reply->chargeevents[cntbatch].status = 2
   ELSEIF (uar_get_code_meaning(c.status_cd)="SUBMITTED")
    reply->chargeevents[cntbatch].status = 3
   ELSE
    reply->chargeevents[cntbatch].status = 4
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->chargeevents,cntbatch)
 IF (size(reply->chargeevents,5) > 0)
  CALL logmessage("Main","Get detail codes",log_debug)
  SELECT INTO "nl:"
   FROM charge_batch_detail_code c,
    (dummyt d1  WITH seq = value(size(reply->chargeevents,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_batch_detail_id=reply->chargeevents[d1.seq].chargeeventid)
     AND c.active_ind=1)
   ORDER BY c.charge_batch_detail_id, c.priority_seq
   HEAD c.charge_batch_detail_id
    cnticd = 0, cntmod = 0
   DETAIL
    IF (uar_get_code_meaning(c.type_cd)="MODIFIER")
     cntmod = (cntmod+ 1), stat = alterlist(reply->chargeevents[d1.seq].batchmodifiercodes,cntmod),
     reply->chargeevents[d1.seq].batchmodifiercodes[cntmod].alias = c.type_ident,
     reply->chargeevents[d1.seq].batchmodifiercodes[cntmod].valid = 0
     IF (c.parent_entity_id > 0)
      reply->chargeevents[d1.seq].batchmodifiercodes[cntmod].valid = 1, reply->chargeevents[d1.seq].
      batchmodifiercodes[cntmod].aliasid = c.parent_entity_id
     ENDIF
    ELSEIF (uar_get_code_meaning(c.type_cd)="CDM")
     reply->chargeevents[d1.seq].cdmcode = c.type_ident
    ELSE
     cnticd = (cnticd+ 1), stat = alterlist(reply->chargeevents[d1.seq].batchicdcodes,cnticd), reply
     ->chargeevents[d1.seq].batchicdcodes[cnticd].alias = c.type_ident,
     reply->chargeevents[d1.seq].batchicdcodes[cnticd].valid = 0
     IF (c.parent_entity_id > 0)
      reply->chargeevents[d1.seq].batchicdcodes[cnticd].valid = 1, reply->chargeevents[d1.seq].
      batchicdcodes[cnticd].aliasid = c.parent_entity_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL logmessage("Main","Get flex fields",log_debug)
  SELECT INTO "nl:"
   FROM charge_batch_detail_field c,
    code_value_extension cve,
    (dummyt d1  WITH seq = value(size(reply->chargeevents,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_batch_detail_id=reply->chargeevents[d1.seq].chargeeventid)
     AND c.active_ind=1)
    JOIN (cve
    WHERE cve.code_value=c.field_type_cd
     AND cve.field_name IN ("TYPE", "DATA_TYPE"))
   HEAD c.charge_batch_detail_id
    cntfields = 0
   DETAIL
    cntfields = (cntfields+ 1)
    IF (mod(cntfields,10)=1)
     stat = alterlist(reply->chargeevents[d1.seq].flexfields,(cntfields+ 9))
    ENDIF
    IF (c.field_type_cd=cs4002352_fromtodate_cd)
     reply->chargeevents[d1.seq].servicetodate = c.field_value_dt_tm
    ENDIF
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldtypecd = c.field_type_cd, reply->
    chargeevents[d1.seq].flexfields[cntfields].fielddatetime = c.field_value_dt_tm, reply->
    chargeevents[d1.seq].flexfields[cntfields].fieldchar = c.field_value_char,
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldnbr = c.field_value_nbr, reply->
    chargeevents[d1.seq].flexfields[cntfields].fieldind = c.field_value_ind, reply->chargeevents[d1
    .seq].flexfields[cntfields].fieldvaluetype = cve.field_value,
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldstartdatetime = c.field_value_start_dt_tm,
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldenddatetime = c.field_value_end_dt_tm,
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldprsnlid = c.field_value_prsnl_id,
    reply->chargeevents[d1.seq].flexfields[cntfields].priorityseq = c.priority_seq
    IF (cve.field_value="INDICATOR")
     IF (c.field_value_ind=0)
      reply->chargeevents[d1.seq].flexfields[cntfields].fieldcd = 2.00
     ELSE
      reply->chargeevents[d1.seq].flexfields[cntfields].fieldcd = 1.00
     ENDIF
    ELSE
     reply->chargeevents[d1.seq].flexfields[cntfields].fieldcd = c.field_value_cd
    ENDIF
   FOOT  c.charge_batch_detail_id
    stat = alterlist(reply->chargeevents[d1.seq].flexfields,cntfields)
   WITH nocounter
  ;end select
  CALL logmessage("Main","Get pat Resp fields",log_debug)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(reply->chargeevents,5))),
    charge_batch_detail c
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_batch_detail_id=reply->chargeevents[d1.seq].chargeeventid)
     AND c.active_ind=1)
   ORDER BY c.charge_batch_detail_id
   HEAD c.charge_batch_detail_id
    cntfields = 0
   DETAIL
    IF (validate(reply->chargeevents[d1.seq].flexfields))
     cntfields = size(reply->chargeevents[d1.seq].flexfields,5)
    ENDIF
    stat = alterlist(reply->chargeevents[d1.seq].flexfields,(cntfields+ 3)), cntfields = (cntfields+
    1), reply->chargeevents[d1.seq].flexfields[cntfields].fieldname = "NONCOVERED",
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldvaluetype = "YESNO"
    IF (c.patient_responsibility_flag=1)
     reply->chargeevents[d1.seq].flexfields[cntfields].fieldcd = 1.0
    ELSEIF (c.patient_responsibility_flag=2)
     reply->chargeevents[d1.seq].flexfields[cntfields].fieldcd = 2.0
    ENDIF
    cntfields = (cntfields+ 1), reply->chargeevents[d1.seq].flexfields[cntfields].fieldname = "COPAY",
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldvaluetype = "CURRENCY",
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldnbr = c.item_copay_amt, cntfields = (
    cntfields+ 1), reply->chargeevents[d1.seq].flexfields[cntfields].fieldname = "DEDUCTIBLE",
    reply->chargeevents[d1.seq].flexfields[cntfields].fieldvaluetype = "CURRENCY", reply->
    chargeevents[d1.seq].flexfields[cntfields].fieldnbr = c.item_deductible_amt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(reply->chargeevents,5))),
    (dummyt d2  WITH seq = 1),
    prsnl p
   PLAN (d1
    WHERE maxrec(d2,size(reply->chargeevents[d1.seq].flexfields,5)))
    JOIN (d2)
    JOIN (p
    WHERE (p.person_id=reply->chargeevents[d1.seq].flexfields[d2.seq].fieldnbr)
     AND (reply->chargeevents[d1.seq].flexfields[d2.seq].fieldtypecd=cs4002352_suprvsngprov_cd))
   DETAIL
    reply->chargeevents[d1.seq].flexfields[d2.seq].fieldchar = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSE
  CALL exitservicenodata("No charge details exist for given batch",go_to_exit_script)
 ENDIF
 CALL exitservicesuccess("Exiting script")
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
