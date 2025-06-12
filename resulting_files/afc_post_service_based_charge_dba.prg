CREATE PROGRAM afc_post_service_based_charge:dba
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
 CALL beginservice("CHARGSRV-15782.003")
 IF ( NOT (validate(reply->status_data.status)))
  RECORD reply(
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
 ENDIF
 RECORD chargesrec(
   1 charges[*]
     2 chargeitemid = f8
     2 encounterid = f8
     2 servicebasedind = i2
     2 suspendcode = i4
     2 cdm_suspend_check = i2
     2 cdm_suspend_check_cd = f8
     2 cpt_suspend_check = i2
     2 cpt_suspend_check_cd = f8
     2 rev_suspend_check = i2
     2 rev_suspend_check_cd = f8
     2 no_cdm_id_suspend_check = i2
     2 cost_center_suspend_check = i2
     2 backload_noserviceind_suspend_check = i2
     2 processmode = i2
 ) WITH protect
 RECORD cdm_codes(
   1 code_vals[*]
     2 code_val = f8
 ) WITH protect
 RECORD cpt_codes(
   1 code_vals[*]
     2 code_val = f8
 ) WITH protect
 RECORD rev_codes(
   1 code_vals[*]
     2 code_val = f8
 ) WITH protect
 RECORD susp(
   1 charge_qual = i2
   1 charges[*]
     2 chargeitemid = f8
     2 suspendcode = i4
 ) WITH protect
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
 DECLARE interfaced_through_service = i4 WITH protect, constant(1)
 DECLARE interfaced_process_flag = i4 WITH protect, constant(999)
 DECLARE suspended_process_flag = i4 WITH protect, constant(1)
 DECLARE suspend_default_enum_val = i4 WITH protect, constant(0)
 DECLARE suspend_nocdm_enum_val = i4 WITH protect, constant(1)
 DECLARE suspend_nocpt_enum_val = i4 WITH protect, constant(2)
 DECLARE suspend_norev_enum_val = i4 WITH protect, constant(3)
 DECLARE suspend_nocost_enum_val = i4 WITH protect, constant(4)
 DECLARE suspend_nocdmid_enum_val = i4 WITH protect, constant(5)
 DECLARE suspend_backldnoserv_enum_val = i4 WITH protect, constant(6)
 DECLARE backloadcharge = i2 WITH protect, constant(1)
 DECLARE dcrcharge = i2 WITH protect, constant(2)
 IF ( NOT (validate(cs24454_svcbasedind)))
  DECLARE cs24454_svcbasedind = f8 WITH protect, constant(uar_get_code_by("MEANING",24454,
    "SVCBASEDIND"))
 ENDIF
 IF ( NOT (validate(cs24454_processmode)))
  DECLARE cs24454_processmode = f8 WITH protect, constant(uar_get_code_by("MEANING",24454,
    "PROCESSMODE"))
 ENDIF
 IF ( NOT (validate(cs29322_chargecreated_event)))
  DECLARE cs29322_chargecreated_event = f8 WITH protect, constant(uar_get_code_by("MEANING",29322,
    "CHRGCREATED"))
 ENDIF
 IF ( NOT (validate(cs24454_chrgitemid)))
  DECLARE cs24454_chrgitemid = f8 WITH protect, constant(uar_get_code_by("MEANING",24454,"CHRGITEMID"
    ))
 ENDIF
 IF ( NOT (validate(cs23369_wfevent)))
  DECLARE cs23369_wfevent = f8 WITH protect, constant(uar_get_code_by("MEANING",23369,"WFEVENT"))
 ENDIF
 IF ( NOT (validate(cs13019_suspense)))
  DECLARE cs13019_suspense = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"SUSPENSE"))
 ENDIF
 IF ( NOT (validate(cs48_active)))
  DECLARE cs48_active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs13030_nocdm)))
  DECLARE cs13030_nocdm = f8 WITH protect, constant(uar_get_code_by("MEANING",13030,"NOCDM"))
 ENDIF
 IF (cs13030_nocdm IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS13030_NOCDM IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs13030_nocpt)))
  DECLARE cs13030_nocpt = f8 WITH protect, constant(uar_get_code_by("MEANING",13030,"NOCPT4"))
 ENDIF
 IF (cs13030_nocpt IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS13030_NOCPT IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs13030_norev)))
  DECLARE cs13030_norev = f8 WITH protect, constant(uar_get_code_by("MEANING",13030,"NOREV"))
 ENDIF
 IF (cs13030_norev IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS13030_NOREV IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs13030_nocost)))
  DECLARE cs13030_nocost = f8 WITH protect, constant(uar_get_code_by("MEANING",13030,"NOCOST"))
 ENDIF
 IF (cs13030_nocost IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS13030_NOCOST IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs13030_nocdmid)))
  DECLARE cs13030_nocdmid = f8 WITH protect, constant(uar_get_code_by("MEANING",13030,"NOCDMID"))
 ENDIF
 IF (cs13030_nocdmid IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS13030_NOCDMID IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs13030_backldnoserv)))
  DECLARE cs13030_backldnoserv = f8 WITH protect, constant(uar_get_code_by("MEANING",13030,
    "BACKLDNOSERV"))
 ENDIF
 IF (cs13030_backldnoserv IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS13030_BACKLDNOSERV IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs14002_all)))
  DECLARE cs14002_all = f8 WITH protect, constant(uar_get_code_by("MEANING",14002,"ALL"))
 ENDIF
 IF (cs14002_all IN (0.0, null, - (1)))
  IF (validate(debug,- (1)) > 0)
   CALL echo("CS14002_ALL IS NULL")
  ENDIF
  GO TO end_program
 ENDIF
 IF ( NOT (validate(cs13019_bill_code)))
  DECLARE cs13019_bill_code = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 ENDIF
 CALL populatechargesrec(request,chargesrec)
 IF ( NOT (publishchargecreatedevent(request,chargesrec)))
  CALL exitservicefailure("Failed to publish charge created event",true)
 ENDIF
 CALL updateservicebasedchargesasinterfaced(chargesrec)
 CALL exitservicesuccess("")
#exit_script
 SUBROUTINE (populatechargesrec(prrequest=vc(ref),prchargesrec=vc(ref)) =null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE chargecount = i4 WITH protect, noconstant(0)
   DECLARE chargepos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM charge c,
     interface_file i
    PLAN (c
     WHERE expand(idx,1,size(prrequest->charges,5),c.charge_item_id,prrequest->charges[idx].
      chargeitemid)
      AND c.active_ind=true)
     JOIN (i
     WHERE i.interface_file_id=c.interface_file_id
      AND i.active_ind=true)
    HEAD REPORT
     stat = alterlist(prchargesrec->charges,100), chargecount = 0
    DETAIL
     chargecount += 1, chargepos = locateval(idx,1,size(prrequest->charges,5),c.charge_item_id,
      prrequest->charges[idx].chargeitemid)
     IF (mod(chargecount,10)=1
      AND chargecount > 100)
      stat = alterlist(prchargesrec->charges,(chargecount+ 9))
     ENDIF
     prchargesrec->charges[chargecount].chargeitemid = c.charge_item_id, prchargesrec->charges[
     chargecount].encounterid = c.encntr_id, prchargesrec->charges[chargecount].servicebasedind = i
     .service_based_ind,
     prchargesrec->charges[chargecount].suspendcode = suspend_default_enum_val
     IF (chargepos > 0)
      prchargesrec->charges[chargecount].processmode = validate(prrequest->charges[chargepos].
       processmode,0)
     ENDIF
     IF ((prchargesrec->charges[chargecount].processmode != dcrcharge))
      IF (i.cdm_sched_cd=cs14002_all)
       prchargesrec->charges[chargecount].cdm_suspend_check = 2
      ELSEIF (i.cdm_sched_cd > 0)
       prchargesrec->charges[chargecount].cdm_suspend_check = 1, prchargesrec->charges[chargecount].
       cdm_suspend_check_cd = i.cdm_sched_cd
      ENDIF
      IF (i.cpt_sched_cd=cs14002_all)
       prchargesrec->charges[chargecount].cpt_suspend_check = 2
      ELSEIF (i.cpt_sched_cd > 0)
       prchargesrec->charges[chargecount].cpt_suspend_check = 1, prchargesrec->charges[chargecount].
       cpt_suspend_check_cd = i.cpt_sched_cd
      ENDIF
      IF (i.rev_sched_cd=cs14002_all)
       prchargesrec->charges[chargecount].rev_suspend_check = 2
      ELSEIF (i.rev_sched_cd > 0)
       prchargesrec->charges[chargecount].rev_suspend_check = 1, prchargesrec->charges[chargecount].
       rev_suspend_check_cd = i.rev_sched_cd
      ENDIF
      IF (i.cdm_id_suspend_ind)
       prchargesrec->charges[chargecount].no_cdm_id_suspend_check = 1
      ENDIF
      IF (i.cost_center_suspend_ind)
       prchargesrec->charges[chargecount].cost_center_suspend_check = 1
      ENDIF
      IF (i.service_based_ind != 1
       AND (prchargesrec->charges[chargecount].processmode=backloadcharge))
       prchargesrec->charges[chargecount].backload_noserviceind_suspend_check = 1
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(prchargesrec->charges,chargecount)
    WITH nocounter
   ;end select
   CALL getcodesets(null)
   CALL updatesuspendcodesforcharges(prchargesrec)
   CALL write_suspense_mods(prchargesrec)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(prchargesrec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (publishchargecreatedevent(prrequest=vc(ref),prchargesrec=vc(ref)) =i2)
   DECLARE encntridx = i4 WITH protect, noconstant(0)
   DECLARE paramsidx = i4 WITH protect, noconstant(0)
   DECLARE isservicebasedchargeonencntr = i2 WITH protect, noconstant(false)
   DECLARE eventprocessmode = i2 WITH protect, noconstant(0)
   RECORD chargecreatedeventreq(
     1 eventlist[*]
       2 entitytypekey = vc
       2 entityid = f8
       2 eventcd = f8
       2 eventtypecd = f8
       2 params[*]
         3 paramcd = f8
         3 paramvalue = f8
         3 newparamind = i2
         3 doublevalue = f8
         3 stringvalue = vc
         3 datevalue = dq8
         3 parententityname = vc
         3 parententityid = f8
   ) WITH protect
   RECORD chargecreatedeventrep(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SELECT INTO "nl:"
    encounterid = prchargesrec->charges[d.seq].encounterid, chargeid = prchargesrec->charges[d.seq].
    chargeitemid, servicebasedind = prchargesrec->charges[d.seq].servicebasedind,
    processmode = prchargesrec->charges[d.seq].processmode
    FROM (dummyt d  WITH seq = value(size(prchargesrec->charges,5)))
    WHERE (prchargesrec->charges[d.seq].chargeitemid > 0.0)
     AND (prchargesrec->charges[d.seq].suspendcode=suspend_default_enum_val)
    ORDER BY encounterid, processmode
    HEAD encounterid
     null
    HEAD processmode
     encntridx += 1, paramsidx = 0, stat = alterlist(chargecreatedeventreq->eventlist,encntridx),
     chargecreatedeventreq->eventlist[encntridx].entitytypekey = "ENCOUNTER", chargecreatedeventreq->
     eventlist[encntridx].entityid = encounterid, chargecreatedeventreq->eventlist[encntridx].eventcd
      = cs29322_chargecreated_event,
     chargecreatedeventreq->eventlist[encntridx].eventtypecd = cs23369_wfevent
    DETAIL
     paramsidx += 1, stat = alterlist(chargecreatedeventreq->eventlist[encntridx].params,paramsidx),
     chargecreatedeventreq->eventlist[encntridx].params[paramsidx].paramcd = cs24454_chrgitemid,
     chargecreatedeventreq->eventlist[encntridx].params[paramsidx].newparamind = true,
     chargecreatedeventreq->eventlist[encntridx].params[paramsidx].doublevalue = chargeid,
     eventprocessmode = prchargesrec->charges[d.seq].processmode
     IF ( NOT (isservicebasedchargeonencntr))
      isservicebasedchargeonencntr = evaluate(servicebasedind,true,true,false)
     ENDIF
    FOOT  processmode
     null
    FOOT  encounterid
     paramsidx += 1, stat = alterlist(chargecreatedeventreq->eventlist[encntridx].params,paramsidx),
     chargecreatedeventreq->eventlist[encntridx].params[paramsidx].paramcd = cs24454_svcbasedind,
     chargecreatedeventreq->eventlist[encntridx].params[paramsidx].newparamind = true
     IF (isservicebasedchargeonencntr)
      chargecreatedeventreq->eventlist[encntridx].params[paramsidx].stringvalue = "TRUE"
     ELSE
      chargecreatedeventreq->eventlist[encntridx].params[paramsidx].stringvalue = "FALSE"
     ENDIF
     CASE (eventprocessmode)
      OF dcrcharge:
       paramsidx += 1,stat = alterlist(chargecreatedeventreq->eventlist[encntridx].params,paramsidx),
       chargecreatedeventreq->eventlist[encntridx].params[paramsidx].paramcd = cs24454_processmode,
       chargecreatedeventreq->eventlist[encntridx].params[paramsidx].newparamind = true,
       chargecreatedeventreq->eventlist[encntridx].params[paramsidx].stringvalue = "DUAL"
      OF backloadcharge:
       paramsidx += 1,stat = alterlist(chargecreatedeventreq->eventlist[encntridx].params,paramsidx),
       chargecreatedeventreq->eventlist[encntridx].params[paramsidx].paramcd = cs24454_processmode,
       chargecreatedeventreq->eventlist[encntridx].params[paramsidx].newparamind = true,
       chargecreatedeventreq->eventlist[encntridx].params[paramsidx].stringvalue = "BACKLOAD"
     ENDCASE
    WITH nocounter
   ;end select
   IF (size(chargecreatedeventreq->eventlist,5) > 0)
    EXECUTE pft_publish_event  WITH replace("REQUEST",chargecreatedeventreq), replace("REPLY",
     chargecreatedeventrep)
   ELSE
    CALL logmessage(cursub,"No charges qualified to publish event.",log_debug)
   ENDIF
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(chargecreatedeventreq)
    CALL echorecord(chargecreatedeventrep)
   ENDIF
   IF ((chargecreatedeventrep->status_data.status != "S")
    AND size(chargecreatedeventreq->eventlist,5) > 0)
    CALL logmessage(cursub,"Call to pft_publish_event failed",log_debug)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (updateservicebasedchargesasinterfaced(prchargesrec=vc(ref)) =null)
   UPDATE  FROM charge c,
     (dummyt d  WITH seq = value(size(prchargesrec->charges,5)))
    SET c.service_interface_flag = evaluate(prchargesrec->charges[d.seq].servicebasedind,1,
      interfaced_through_service,c.service_interface_flag), c.process_flg =
     IF ((prchargesrec->charges[d.seq].suspendcode=suspend_default_enum_val)) interfaced_process_flag
     ELSE suspended_process_flag
     ENDIF
     , c.updt_dt_tm = cnvtdatetime(sysdate),
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
     updt_task
    PLAN (d)
     JOIN (c
     WHERE (c.charge_item_id=prchargesrec->charges[d.seq].chargeitemid)
      AND (prchargesrec->charges[d.seq].processmode != dcrcharge))
   ;end update
 END ;Subroutine
 SUBROUTINE (updatesuspendcodesforcharges(prchargesrec=vc(ref)) =null)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   DECLARE num2 = i4 WITH protect, noconstant(1)
   DECLARE pos = i4 WITH protect, noconstant(1)
   DECLARE idx1 = i4 WITH protect, noconstant(1)
   DECLARE idx2 = i4 WITH protect, noconstant(1)
   DECLARE idx3 = i4 WITH protect, noconstant(1)
   SELECT INTO "nl:"
    FROM charge c,
     (left JOIN charge_mod cm ON cm.charge_item_id=c.charge_item_id
      AND cm.active_ind=1
      AND cm.charge_mod_type_cd=cs13019_bill_code
      AND cm.field2_id=1
      AND trim(cm.field6) != ""),
     (left JOIN charge_desc_master cdm ON cdm.charge_desc_master_id=cm.field3_id)
    PLAN (c
     WHERE expand(num1,1,size(prchargesrec->charges,5),c.charge_item_id,prchargesrec->charges[num1].
      chargeitemid))
     JOIN (cm)
     JOIN (cdm)
    ORDER BY c.charge_item_id
    HEAD c.charge_item_id
     pos = locateval(num2,1,size(prchargesrec->charges,5),c.charge_item_id,prchargesrec->charges[num2
      ].chargeitemid)
     IF (c.cost_center_cd != 0)
      prchargesrec->charges[pos].cost_center_suspend_check = 0
     ENDIF
    DETAIL
     IF (0 < locateval(idx1,1,size(cdm_codes->code_vals,5),cm.field1_id,cdm_codes->code_vals[idx1].
      code_val))
      IF (cdm.charge_desc_master_id != 0
       AND cdm.active_ind=1)
       prchargesrec->charges[pos].no_cdm_id_suspend_check = 0
      ENDIF
      IF ((((prchargesrec->charges[pos].cdm_suspend_check=2)
       AND cm.field1_id > 0) OR ((prchargesrec->charges[pos].cdm_suspend_check=1)
       AND (cm.field1_id=prchargesrec->charges[pos].cdm_suspend_check_cd))) )
       prchargesrec->charges[pos].cdm_suspend_check = 0
      ENDIF
     ELSEIF (0 < locateval(idx2,1,size(cpt_codes->code_vals,5),cm.field1_id,cpt_codes->code_vals[idx2
      ].code_val)
      AND (((prchargesrec->charges[pos].cpt_suspend_check=2)
      AND cm.field1_id > 0) OR ((prchargesrec->charges[pos].cpt_suspend_check=1)
      AND (cm.field1_id=prchargesrec->charges[pos].cpt_suspend_check_cd))) )
      prchargesrec->charges[pos].cpt_suspend_check = 0
     ELSEIF (0 < locateval(idx3,1,size(rev_codes->code_vals,5),cm.field1_id,rev_codes->code_vals[idx3
      ].code_val)
      AND (((prchargesrec->charges[pos].rev_suspend_check=2)
      AND cm.field1_id > 0) OR ((prchargesrec->charges[pos].rev_suspend_check=1)
      AND (cm.field1_id=prchargesrec->charges[pos].rev_suspend_check_cd))) )
      prchargesrec->charges[pos].rev_suspend_check = 0
     ENDIF
    FOOT  c.charge_item_id
     IF ((prchargesrec->charges[pos].cdm_suspend_check > 0))
      prchargesrec->charges[pos].suspendcode = suspend_nocdm_enum_val
     ELSEIF ((prchargesrec->charges[pos].cpt_suspend_check > 0))
      prchargesrec->charges[pos].suspendcode = suspend_nocpt_enum_val
     ELSEIF ((prchargesrec->charges[pos].rev_suspend_check > 0))
      prchargesrec->charges[pos].suspendcode = suspend_norev_enum_val
     ELSEIF ((prchargesrec->charges[pos].no_cdm_id_suspend_check > 0))
      prchargesrec->charges[pos].suspendcode = suspend_nocdmid_enum_val
     ELSEIF ((prchargesrec->charges[pos].cost_center_suspend_check > 0))
      prchargesrec->charges[pos].suspendcode = suspend_nocost_enum_val
     ELSEIF ((prchargesrec->charges[pos].backload_noserviceind_suspend_check > 0))
      prchargesrec->charges[pos].suspendcode = suspend_backldnoserv_enum_val
     ELSE
      prchargesrec->charges[pos].suspendcode = suspend_default_enum_val
     ENDIF
     CALL echorecord(prchargesrec)
   ;end select
 END ;Subroutine
 SUBROUTINE (write_suspense_mods(prchargesrec=vc(ref)) =null)
   DECLARE billcodecnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(susp->charges,0)
   SET stat = alterlist(cmreq->objarray,0)
   SET susp_charge_count = 0
   SET susp->charge_qual = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(prchargesrec->charges,5)))
    WHERE (prchargesrec->charges[d1.seq].suspendcode != suspend_default_enum_val)
    DETAIL
     susp_charge_count += 1, stat = alterlist(susp->charges,susp_charge_count), susp->charges[
     susp_charge_count].chargeitemid = prchargesrec->charges[d1.seq].chargeitemid,
     susp->charges[susp_charge_count].suspendcode = prchargesrec->charges[d1.seq].suspendcode, susp->
     charge_qual = susp_charge_count
    WITH nocounter
   ;end select
   IF ((susp->charge_qual > 0))
    FOR (counter = 1 TO susp->charge_qual)
      CASE (susp->charges[counter].suspendcode)
       OF suspend_nocdm_enum_val:
        SET billcodecnt += 1
        CALL populate_susp_mod(susp->charges[counter].chargeitemid,cs13030_nocdm,
         uar_get_code_description(cs13030_nocdm),billcodecnt)
       OF suspend_nocpt_enum_val:
        SET billcodecnt += 1
        CALL populate_susp_mod(susp->charges[counter].chargeitemid,cs13030_nocpt,
         uar_get_code_description(cs13030_nocpt),billcodecnt)
       OF suspend_norev_enum_val:
        SET billcodecnt += 1
        CALL populate_susp_mod(susp->charges[counter].chargeitemid,cs13030_norev,
         uar_get_code_description(cs13030_norev),billcodecnt)
       OF suspend_nocdmid_enum_val:
        SET billcodecnt += 1
        CALL populate_susp_mod(susp->charges[counter].chargeitemid,cs13030_nocdmid,
         uar_get_code_description(cs13030_nocdmid),billcodecnt)
       OF suspend_nocost_enum_val:
        SET billcodecnt += 1
        CALL populate_susp_mod(susp->charges[counter].chargeitemid,cs13030_nocost,
         uar_get_code_description(cs13030_nocost),billcodecnt)
       OF suspend_backldnoserv_enum_val:
        SET billcodecnt += 1
        CALL populate_susp_mod(susp->charges[counter].chargeitemid,cs13030_backldnoserv,
         uar_get_code_description(cs13030_backldnoserv),billcodecnt)
      ENDCASE
    ENDFOR
   ENDIF
   IF (size(cmreq->objarray,5) > 0)
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
    IF ((cmrep->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cmreq)
      CALL echorecord(cmrep)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_susp_mod(charge=f8,code=f8,desc=vc,billcodecnt=i4) =null)
   SET new_charge_mod_id = 0.0
   SELECT INTO "nl:"
    ce_seq_num = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_charge_mod_id = cnvtreal(ce_seq_num)
    WITH format, counter
   ;end select
   SET stat = alterlist(cmreq->objarray,billcodecnt)
   SET cmreq->objarray[billcodecnt].action_type = "ADD"
   SET cmreq->objarray[billcodecnt].charge_mod_id = new_charge_mod_id
   SET cmreq->objarray[billcodecnt].charge_item_id = charge
   SET cmreq->objarray[billcodecnt].charge_mod_type_cd = cs13019_suspense
   SET cmreq->objarray[billcodecnt].field1 = cnvtstring(code,17,2)
   SET cmreq->objarray[billcodecnt].field6 = trim(desc)
   SET cmreq->objarray[billcodecnt].field1_id = code
   SET cmreq->objarray[billcodecnt].active_ind = 1
   SET cmreq->objarray[billcodecnt].active_status_cd = cs48_active
   SET cmreq->objarray[billcodecnt].active_status_prsnl_id = reqinfo->updt_id
   SET cmreq->objarray[billcodecnt].active_status_dt_tm = cnvtdatetime(sysdate)
   SET cmreq->objarray[billcodecnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
   SET cmreq->objarray[billcodecnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   SET cmreq->objarray[billcodecnt].updt_cnt = 0
 END ;Subroutine
 SUBROUTINE (getcodesets(dummy=i2) =null)
   DECLARE lcvcount = i4
   DECLARE codevalue = f8
   DECLARE total_remaining = i4
   DECLARE start_index = i4
   DECLARE occurances = i4
   DECLARE meaningval = c12
   SET stat = initrec(cdm_codes)
   SET stat = initrec(cpt_codes)
   SET stat = initrec(rev_codes)
   SET meaningval = "CDM_SCHED"
   SET start_index = 1
   SET occurances = 1
   SET stat = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
   IF (stat=0
    AND occurances > 0)
    DECLARE code_list[value(occurances)] = f8
    CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,
     total_remaining,
     code_list)
    SET stat = alterlist(cdm_codes->code_vals,occurances)
    FOR (lcvcount = 1 TO size(code_list,5))
      SET cdm_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
    ENDFOR
    FREE SET code_list
   ENDIF
   SET meaningval = "CPT4"
   SET start_index = 1
   SET occurances = 1
   SET stat = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
   IF (stat=0
    AND occurances > 0)
    DECLARE code_list[value(occurances)] = f8
    CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,
     total_remaining,
     code_list)
    SET stat = alterlist(cpt_codes->code_vals,occurances)
    FOR (lcvcount = 1 TO size(code_list,5))
      SET cpt_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
    ENDFOR
    FREE SET code_list
   ENDIF
   SET meaningval = "REVENUE"
   SET start_index = 1
   SET occurances = 1
   SET stat = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
   IF (stat=0
    AND occurances > 0)
    DECLARE code_list[value(occurances)] = f8
    CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,
     total_remaining,
     code_list)
    SET stat = alterlist(rev_codes->code_vals,occurances)
    FOR (lcvcount = 1 TO size(code_list,5))
      SET rev_codes->code_vals[lcvcount].code_val = code_list[lcvcount]
    ENDFOR
    FREE SET code_list
   ENDIF
 END ;Subroutine
#end_program
END GO
