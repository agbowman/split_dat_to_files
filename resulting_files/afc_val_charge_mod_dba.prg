CREATE PROGRAM afc_val_charge_mod:dba
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
 CALL beginservice("CHARGSRV-13049.004")
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
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
 ENDIF
 RECORD reccptmodifiers(
   1 listmodifier[*]
     2 charge_item_id = f8
     2 charge_mod_id = f8
     2 field6 = vc
     2 field1_id = f8
 ) WITH protect
 RECORD recicdcodes(
   1 listicdcode[*]
     2 charge_item_id = f8
     2 charge_mod_id = f8
     2 field6 = vc
 ) WITH protect
 RECORD addchargemodreq(
   1 objarray[1]
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
     2 charge_mod_source_cd = f8
 ) WITH protect
 RECORD uptchargemodreq(
   1 objarray[1]
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
     2 charge_mod_source_cd = f8
 ) WITH protect
 RECORD delchargemodreq(
   1 objarray[1]
     2 charge_mod_id = f8
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
 ) WITH protect
 RECORD chargemodrep(
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
 DECLARE cs14002_afc_schedule_type = f8 WITH protect, constant(14002.0)
 DECLARE cs14002meaning = c12 WITH protect, noconstant("")
 DECLARE locatecptmod = i2 WITH protect, noconstant(false)
 DECLARE locateicdcode = i2 WITH protect, noconstant(false)
 DECLARE failurecount = i4 WITH protect, noconstant(0)
 CALL logmessage(curprog,"afc_val_charge_mod - Executing...",log_debug)
 SET reply->status_data.status = "F"
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 IF (size(request->objarray,5) <= 0)
  CALL exitservicefailure("bill codes information can not be empty",go_to_exit_script)
 ENDIF
 CALL getchargeitemcptmod(null)
 CALL getchargeitemicd(null)
 CALL checkdupcptandicd(null)
 IF (failurecount=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 CALL logmessage(curprog,"afc_val_charge_mod - Exiting...",log_debug)
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 SUBROUTINE (addchargemod(idx0=i4) =null WITH protect)
   CALL logmessage(curprog,"addChargeMod - Entering...",log_debug)
   SET addchargemodreq->objarray[1].charge_mod_id = request->objarray[idx0].charge_mod_id
   SET addchargemodreq->objarray[1].charge_item_id = request->objarray[idx0].charge_item_id
   SET addchargemodreq->objarray[1].charge_mod_type_cd = request->objarray[idx0].charge_mod_type_cd
   SET addchargemodreq->objarray[1].field1 = request->objarray[idx0].field1
   SET addchargemodreq->objarray[1].field2 = request->objarray[idx0].field2
   SET addchargemodreq->objarray[1].field3 = request->objarray[idx0].field3
   SET addchargemodreq->objarray[1].field4 = request->objarray[idx0].field4
   SET addchargemodreq->objarray[1].field5 = request->objarray[idx0].field5
   SET addchargemodreq->objarray[1].field6 = request->objarray[idx0].field6
   SET addchargemodreq->objarray[1].field7 = request->objarray[idx0].field7
   SET addchargemodreq->objarray[1].field8 = request->objarray[idx0].field8
   SET addchargemodreq->objarray[1].field9 = request->objarray[idx0].field9
   SET addchargemodreq->objarray[1].field10 = request->objarray[idx0].field10
   SET addchargemodreq->objarray[1].updt_cnt = request->objarray[idx0].updt_cnt
   SET addchargemodreq->objarray[1].active_ind = request->objarray[idx0].active_ind
   SET addchargemodreq->objarray[1].active_status_cd = request->objarray[idx0].active_status_cd
   SET addchargemodreq->objarray[1].active_status_dt_tm = request->objarray[idx0].active_status_dt_tm
   SET addchargemodreq->objarray[1].active_status_prsnl_id = request->objarray[idx0].
   active_status_prsnl_id
   SET addchargemodreq->objarray[1].beg_effective_dt_tm = request->objarray[idx0].beg_effective_dt_tm
   SET addchargemodreq->objarray[1].end_effective_dt_tm = request->objarray[idx0].end_effective_dt_tm
   SET addchargemodreq->objarray[1].code1_cd = request->objarray[idx0].code1_cd
   SET addchargemodreq->objarray[1].nomen_id = request->objarray[idx0].nomen_id
   SET addchargemodreq->objarray[1].field1_id = request->objarray[idx0].field1_id
   SET addchargemodreq->objarray[1].field2_id = request->objarray[idx0].field2_id
   SET addchargemodreq->objarray[1].field3_id = request->objarray[idx0].field3_id
   SET addchargemodreq->objarray[1].field4_id = request->objarray[idx0].field4_id
   SET addchargemodreq->objarray[1].field5_id = request->objarray[idx0].field5_id
   SET addchargemodreq->objarray[1].cm1_nbr = request->objarray[idx0].cm1_nbr
   SET addchargemodreq->objarray[1].activity_dt_tm = request->objarray[idx0].activity_dt_tm
   SET addchargemodreq->objarray[1].charge_mod_source_cd = validate(request->objarray[idx0].
    charge_mod_source_cd,0.0)
   EXECUTE afc_da_add_charge_mod  WITH replace("REQUEST",addchargemodreq), replace("REPLY",
    chargemodrep)
   IF ((chargemodrep->status_data.status != "S"))
    CALL logmessage(curprog,"AFC_DA_ADD_CHARGE_MOD did not return success",log_debug)
    SET failurecount += 1
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(addchargemodreq)
     CALL echorecord(chargemodrep)
    ENDIF
   ELSE
    IF ((request->objarray[idx0].charge_mod_id <= 0))
     SET request->objarray[idx0].charge_mod_id = addchargemodreq->objarray[1].charge_mod_id
    ENDIF
   ENDIF
   CALL logmessage(curprog,"addChargeMod - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (uptchargemod(idx0=i4) =null WITH protect)
   CALL logmessage(curprog,"uptChargeMod - Entering...",log_debug)
   SET uptchargemodreq->objarray[1].charge_mod_id = request->objarray[idx0].charge_mod_id
   SET uptchargemodreq->objarray[1].charge_item_id = request->objarray[idx0].charge_item_id
   SET uptchargemodreq->objarray[1].charge_mod_type_cd = request->objarray[idx0].charge_mod_type_cd
   SET uptchargemodreq->objarray[1].field1 = request->objarray[idx0].field1
   SET uptchargemodreq->objarray[1].field2 = request->objarray[idx0].field2
   SET uptchargemodreq->objarray[1].field3 = request->objarray[idx0].field3
   SET uptchargemodreq->objarray[1].field4 = request->objarray[idx0].field4
   SET uptchargemodreq->objarray[1].field5 = request->objarray[idx0].field5
   SET uptchargemodreq->objarray[1].field6 = request->objarray[idx0].field6
   SET uptchargemodreq->objarray[1].field7 = request->objarray[idx0].field7
   SET uptchargemodreq->objarray[1].field8 = request->objarray[idx0].field8
   SET uptchargemodreq->objarray[1].field9 = request->objarray[idx0].field9
   SET uptchargemodreq->objarray[1].field10 = request->objarray[idx0].field10
   SET uptchargemodreq->objarray[1].updt_cnt = request->objarray[idx0].updt_cnt
   SET uptchargemodreq->objarray[1].active_ind = request->objarray[idx0].active_ind
   SET uptchargemodreq->objarray[1].active_status_cd = request->objarray[idx0].active_status_cd
   SET uptchargemodreq->objarray[1].active_status_dt_tm = request->objarray[idx0].active_status_dt_tm
   SET uptchargemodreq->objarray[1].active_status_prsnl_id = request->objarray[idx0].
   active_status_prsnl_id
   SET uptchargemodreq->objarray[1].beg_effective_dt_tm = request->objarray[idx0].beg_effective_dt_tm
   SET uptchargemodreq->objarray[1].end_effective_dt_tm = request->objarray[idx0].end_effective_dt_tm
   SET uptchargemodreq->objarray[1].code1_cd = request->objarray[idx0].code1_cd
   SET uptchargemodreq->objarray[1].nomen_id = request->objarray[idx0].nomen_id
   SET uptchargemodreq->objarray[1].field1_id = request->objarray[idx0].field1_id
   SET uptchargemodreq->objarray[1].field2_id = request->objarray[idx0].field2_id
   SET uptchargemodreq->objarray[1].field3_id = request->objarray[idx0].field3_id
   SET uptchargemodreq->objarray[1].field4_id = request->objarray[idx0].field4_id
   SET uptchargemodreq->objarray[1].field5_id = request->objarray[idx0].field5_id
   SET uptchargemodreq->objarray[1].cm1_nbr = request->objarray[idx0].cm1_nbr
   SET uptchargemodreq->objarray[1].activity_dt_tm = request->objarray[idx0].activity_dt_tm
   SET uptchargemodreq->objarray[1].charge_mod_source_cd = validate(request->objarray[idx0].
    charge_mod_source_cd,0.0)
   EXECUTE afc_da_upt_charge_mod  WITH replace("REQUEST",uptchargemodreq), replace("REPLY",
    chargemodrep)
   IF ((chargemodrep->status_data.status != "S"))
    CALL logmessage(curprog,"AFC_DA_UPT_CHARGE_MOD did not return success",log_debug)
    SET failurecount += 1
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(uptchargemodreq)
     CALL echorecord(chargemodrep)
    ENDIF
   ENDIF
   CALL logmessage(curprog,"uptChargeMod - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (delchargemod(idx0=i4) =null WITH protect)
   CALL logmessage(curprog,"delChargeMod - Entering...",log_debug)
   SET delchargemodreq->objarray[1].charge_mod_id = request->objarray[idx0].charge_mod_id
   SET delchargemodreq->objarray[1].updt_cnt = request->objarray[idx0].updt_cnt
   SET delchargemodreq->objarray[1].active_ind = 0
   SET delchargemodreq->objarray[1].active_status_cd = request->objarray[idx0].active_status_cd
   EXECUTE afc_da_upt_charge_mod  WITH replace("REQUEST",delchargemodreq), replace("REPLY",
    chargemodrep)
   IF ((chargemodrep->status_data.status != "S"))
    CALL logmessage(curprog,"AFC_DA_UPT_CHARGE_MOD did not return success",log_debug)
    SET failurecount += 1
    IF (validate(debug,- (1)) > 0)
     CALL echorecord(delchargemodreq)
     CALL echorecord(chargemodrep)
    ENDIF
   ENDIF
   CALL logmessage(curprog,"delChargeMod - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (checkdupcptandicd(dummyvar=i2) =null WITH protect)
   CALL logmessage(curprog,"checkDupCptandIcd - Entering...",log_debug)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   IF (size(request->objarray,5) > 0)
    FOR (i = 1 TO size(request->objarray,5))
      IF ((request->objarray[i].action_type="DEL"))
       CALL delchargemod(i)
      ELSE
       IF (validate(request->objarray[i].updateicdcodes))
        IF (size(request->objarray[i].updateicdcodes,5) > 0)
         FOR (j = 1 TO size(request->objarray[i].updateicdcodes,5))
           FOR (k = 1 TO size(recicdcodes->listicdcode,5))
             IF ((request->objarray[i].updateicdcodes[j].chargemodid=recicdcodes->listicdcode[k].
             charge_mod_id))
              SET recicdcodes->listicdcode[k].field6 = request->objarray[i].updateicdcodes[j].field6
             ENDIF
           ENDFOR
         ENDFOR
        ENDIF
       ENDIF
       SET cs14002meaning = uar_get_code_meaning(request->objarray[i].field1_id)
       IF (cs14002meaning="MODIFIER")
        FOR (j = 1 TO size(reccptmodifiers->listmodifier,5))
          IF ((request->objarray[i].charge_item_id=reccptmodifiers->listmodifier[j].charge_item_id)
           AND (request->objarray[i].field6=reccptmodifiers->listmodifier[j].field6)
           AND (request->objarray[i].charge_mod_id != reccptmodifiers->listmodifier[j].charge_mod_id)
           AND (request->objarray[i].field1_id=reccptmodifiers->listmodifier[j].field1_id))
           SET locatecptmod = true
          ENDIF
        ENDFOR
       ELSEIF (cs14002meaning="ICD9")
        FOR (j = 1 TO size(recicdcodes->listicdcode,5))
          IF ((request->objarray[i].charge_item_id=recicdcodes->listicdcode[j].charge_item_id)
           AND (request->objarray[i].field6=recicdcodes->listicdcode[j].field6)
           AND (request->objarray[i].charge_mod_id != recicdcodes->listicdcode[j].charge_mod_id))
           SET locateicdcode = true
          ENDIF
        ENDFOR
       ENDIF
       IF (locatecptmod=false
        AND locateicdcode=false)
        IF ((request->objarray[i].action_type="ADD"))
         CALL addchargemod(i)
        ELSEIF ((request->objarray[i].action_type="UPT"))
         CALL uptchargemod(i)
        ELSE
         CALL logmessage(curprog,"checkDupCptandIcd - Invalid Action Type",log_warning)
         SET failurecount += 1
        ENDIF
       ENDIF
       SET locatecptmod = false
       SET locateicdcode = false
      ENDIF
    ENDFOR
   ENDIF
   CALL logmessage(curprog,"checkDupCptandIcd - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (getchargeitemcptmod(dummyvar=i2) =null WITH protect)
   CALL logmessage(curprog,"getChargeItemCptMod - Entering...",log_debug)
   DECLARE countmod = i4 WITH protect, noconstant(0)
   DECLARE locmod = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO size(request->objarray,5))
     SET num = 0
     SET locmod = locateval(num,1,size(reccptmodifiers->listmodifier,5),request->objarray[i].
      charge_item_id,reccptmodifiers->listmodifier[num].charge_item_id)
     IF (locmod=0)
      SELECT INTO "nl:"
       FROM charge_mod cm,
        code_value cv
       PLAN (cm
        WHERE (cm.charge_item_id=request->objarray[i].charge_item_id)
         AND cm.active_ind=1)
        JOIN (cv
        WHERE cv.code_value=cm.field1_id
         AND cv.code_set=cs14002_afc_schedule_type
         AND cv.cdf_meaning="MODIFIER"
         AND cv.active_ind=1)
       DETAIL
        countmod += 1, stat = alterlist(reccptmodifiers->listmodifier,countmod), reccptmodifiers->
        listmodifier[countmod].charge_item_id = cm.charge_item_id,
        reccptmodifiers->listmodifier[countmod].charge_mod_id = cm.charge_mod_id, reccptmodifiers->
        listmodifier[countmod].field6 = cm.field6, reccptmodifiers->listmodifier[countmod].field1_id
         = cm.field1_id
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(reccptmodifiers)
   ENDIF
   CALL logmessage(curprog,"getChargeItemCptMod - Exiting...",log_debug)
 END ;Subroutine
 SUBROUTINE (getchargeitemicd(dummyvar=i2) =null WITH protect)
   CALL logmessage(curprog,"getChargeItemIcd - Entering...",log_debug)
   DECLARE counticd = i4 WITH protect, noconstant(0)
   DECLARE locicd = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO size(request->objarray,5))
     SET num = 0
     SET locicd = locateval(num,1,size(recicdcodes->listicdcode,5),request->objarray[i].
      charge_item_id,recicdcodes->listicdcode[num].charge_item_id)
     IF (locicd=0)
      SELECT INTO "nl:"
       FROM charge_mod cm,
        code_value cv
       PLAN (cm
        WHERE (cm.charge_item_id=request->objarray[i].charge_item_id)
         AND cm.active_ind=1)
        JOIN (cv
        WHERE cv.code_value=cm.field1_id
         AND cv.code_set=cs14002_afc_schedule_type
         AND cv.cdf_meaning="ICD9"
         AND cv.active_ind=1)
       DETAIL
        counticd += 1, stat = alterlist(recicdcodes->listicdcode,counticd), recicdcodes->listicdcode[
        counticd].charge_item_id = cm.charge_item_id,
        recicdcodes->listicdcode[counticd].charge_mod_id = cm.charge_mod_id, recicdcodes->
        listicdcode[counticd].field6 = cm.field6
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(recicdcodes)
   ENDIF
   CALL logmessage(curprog,"getChargeItemIcd - Exiting...",log_debug)
 END ;Subroutine
END GO
