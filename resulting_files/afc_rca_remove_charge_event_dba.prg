CREATE PROGRAM afc_rca_remove_charge_event:dba
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
 IF ( NOT (validate(reply->status_data)))
  FREE RECORD reply
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
 FREE RECORD chrgbatchreq
 RECORD chrgbatchreq(
   1 objarray[*]
     2 charge_batch_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
 )
 FREE RECORD chrgbatchrep
 RECORD chrgbatchrep(
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
 FREE RECORD chrgeventreq
 RECORD chrgeventreq(
   1 objarray[*]
     2 charge_batch_detail_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
 )
 FREE RECORD chrgeventrep
 RECORD chrgeventrep(
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
 FREE RECORD detailcodereq
 RECORD detailcodereq(
   1 objarray[*]
     2 charge_batch_detail_code_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
 )
 FREE RECORD detailcoderep
 RECORD detailcoderep(
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
 FREE RECORD flexfieldreq
 RECORD flexfieldreq(
   1 objarray[*]
     2 charge_batch_detail_field_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
 )
 FREE RECORD flexfieldrep
 RECORD flexfieldrep(
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
 IF ( NOT (validate(cs4002322_submitted_cd)))
  DECLARE cs4002322_submitted_cd = f8 WITH protect, constant(getcodevalue(4002322,"SUBMITTED",0))
 ENDIF
 IF ( NOT (validate(cs4002322_posted_cd)))
  DECLARE cs4002322_posted_cd = f8 WITH protect, constant(getcodevalue(4002322,"POSTED",0))
 ENDIF
 DECLARE batchcnt = i4 WITH protect, noconstant(0)
 DECLARE dtlcount = i4 WITH protect, noconstant(0)
 DECLARE cdcount = i4 WITH protect, noconstant(0)
 DECLARE flxcount = i4 WITH protect, noconstant(0)
 DECLARE cefilterclause = vc WITH protect, noconstant("1=1")
 DECLARE delchargefrombatch(pmessage=vc) = i2
 DECLARE delchargebatch(pmessage=vc) = i2
 IF ((request->encounterid > 0.0))
  SET cefilterclause = "d.encntr_id = outerjoin(request->encounterID)"
 ENDIF
 CALL beginservice("192772.001")
 CALL logmessage("Main","Begining main processing",log_debug)
 CALL echo(build("parser: ",cefilterclause))
 IF ((request->chargeeventid > 0.0))
  CALL logmessage("Main","Removing a single charge event",log_debug)
  SELECT INTO "nl:"
   FROM charge_batch_detail d,
    charge_batch_detail_code c,
    charge_batch_detail_field f
   PLAN (d
    WHERE (d.charge_batch_detail_id=request->chargeeventid)
     AND  NOT (d.status_cd IN (cs4002322_submitted_cd, cs4002322_posted_cd))
     AND d.active_ind=1)
    JOIN (c
    WHERE c.charge_batch_detail_id=outerjoin(d.charge_batch_detail_id)
     AND c.active_ind=outerjoin(1))
    JOIN (f
    WHERE f.charge_batch_detail_id=outerjoin(d.charge_batch_detail_id)
     AND f.active_ind=outerjoin(1))
   ORDER BY d.charge_batch_detail_id, c.charge_batch_detail_code_id, f.charge_batch_detail_field_id
   HEAD d.charge_batch_detail_id
    dtlcount = (dtlcount+ 1), stat = alterlist(chrgeventreq->objarray,dtlcount), chrgeventreq->
    objarray[dtlcount].charge_batch_detail_id = d.charge_batch_detail_id,
    chrgeventreq->objarray[dtlcount].updt_cnt = d.updt_cnt
   HEAD c.charge_batch_detail_code_id
    IF (c.charge_batch_detail_code_id > 0.0)
     cdcount = (cdcount+ 1), stat = alterlist(detailcodereq->objarray,cdcount), detailcodereq->
     objarray[cdcount].charge_batch_detail_code_id = c.charge_batch_detail_code_id,
     detailcodereq->objarray[cdcount].updt_cnt = c.updt_cnt, detailcodereq->objarray[cdcount].
     active_ind = 0
    ENDIF
   DETAIL
    IF (f.charge_batch_detail_field_id > 0.0)
     flxcount = (flxcount+ 1), stat = alterlist(flexfieldreq->objarray,flxcount), flexfieldreq->
     objarray[flxcount].charge_batch_detail_field_id = f.charge_batch_detail_field_id,
     flexfieldreq->objarray[flxcount].updt_cnt = c.updt_cnt, flexfieldreq->objarray[flxcount].
     active_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  CALL logmessage("Main","Removing multiple charge events",log_debug)
  SELECT INTO "nl:"
   FROM charge_batch b,
    charge_batch_detail d
   PLAN (b
    WHERE (b.charge_batch_id=request->chargebatchid)
     AND  NOT (b.status_cd IN (cs4002322_submitted_cd, cs4002322_posted_cd)))
    JOIN (d
    WHERE d.charge_batch_id=outerjoin(b.charge_batch_id)
     AND parser(cefilterclause)
     AND d.status_cd != outerjoin(cs4002322_submitted_cd)
     AND d.status_cd != outerjoin(cs4002322_posted_cd)
     AND d.active_ind=outerjoin(1))
   ORDER BY b.charge_batch_id, d.charge_batch_detail_id
   HEAD b.charge_batch_id
    batchcnt = (batchcnt+ 1), stat = alterlist(chrgbatchreq->objarray,batchcnt), chrgbatchreq->
    objarray[batchcnt].charge_batch_id = b.charge_batch_id,
    chrgbatchreq->objarray[batchcnt].updt_cnt = b.updt_cnt, chrgbatchreq->objarray[batchcnt].
    active_ind = 0
   DETAIL
    IF (d.charge_batch_detail_id > 0.0)
     dtlcount = (dtlcount+ 1), stat = alterlist(chrgeventreq->objarray,dtlcount), chrgeventreq->
     objarray[dtlcount].charge_batch_detail_id = d.charge_batch_detail_id,
     chrgeventreq->objarray[dtlcount].updt_cnt = d.updt_cnt, chrgeventreq->objarray[dtlcount].
     active_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  IF (size(chrgeventreq->objarray,5) > 0)
   CALL logmessage("MAIN","Get charge_batch_detail_code",log_debug)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(chrgeventreq->objarray,5))),
     charge_batch_detail_code c
    PLAN (d1)
     JOIN (c
     WHERE c.charge_batch_detail_id=outerjoin(chrgeventreq->objarray[d1.seq].charge_batch_detail_id)
      AND c.active_ind=outerjoin(1))
    DETAIL
     cdcount = (cdcount+ 1), stat = alterlist(detailcodereq->objarray,cdcount), detailcodereq->
     objarray[cdcount].charge_batch_detail_code_id = c.charge_batch_detail_code_id,
     detailcodereq->objarray[cdcount].updt_cnt = c.updt_cnt, detailcodereq->objarray[cdcount].
     active_ind = 0
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(chrgeventreq->objarray,5))),
     charge_batch_detail_field f
    PLAN (d1)
     JOIN (f
     WHERE f.charge_batch_detail_id=outerjoin(chrgeventreq->objarray[d1.seq].charge_batch_detail_id)
      AND f.active_ind=outerjoin(1))
    DETAIL
     flxcount = (flxcount+ 1), stat = alterlist(flexfieldreq->objarray,flxcount), flexfieldreq->
     objarray[flxcount].charge_batch_detail_field_id = f.charge_batch_detail_field_id,
     flexfieldreq->objarray[flxcount].updt_cnt = f.updt_cnt, flexfieldreq->objarray[flxcount].
     active_ind = 0
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (size(chrgbatchreq->objarray,5) > 0
  AND (request->removebatchind=1))
  IF ( NOT (delchargebatch("")))
   CALL exitservicefailure("Failed removing charge batch",go_to_exit_script)
  ENDIF
 ENDIF
 IF (size(chrgeventreq->objarray,5) > 0)
  IF ( NOT (delchargefrombatch("")))
   CALL exitservicefailure("Failed removing charge event(s) from batch",go_to_exit_script)
  ENDIF
 ENDIF
 IF (size(chrgbatchreq->objarray,5)=0
  AND size(chrgeventreq->objarray,5)=0)
  IF ((request->chargeeventid > 0.0))
   CALL exitservicenodata(build("No data exists for charge detail id ",request->chargeeventid),
    go_to_exit_script)
  ELSE
   CALL exitservicenodata(build("No data exists for encounter id ",request->encounterid,
     " and batch id ",request->chargebatchid),go_to_exit_script)
  ENDIF
 ENDIF
 CALL exitservicesuccess("Exiting script")
 SUBROUTINE delchargefrombatch(null)
   CALL logmessage("delChargeFromBatch","Begin sub",log_debug)
   CALL logmessage("delChargeFromBatch","Remove charge batch detail",log_debug)
   EXECUTE afc_da_upt_charge_batch_detail  WITH replace("REQUEST",chrgeventreq), replace("REPLY",
    chrgeventrep)
   SET reply->status_data.status = chrgeventrep->status_data.status
   IF ((chrgeventrep->status_data.status != "S"))
    RETURN(false)
   ENDIF
   CALL echorecord(detailcodereq)
   IF (size(detailcodereq->objarray,5) > 0)
    CALL logmessage("delChargeFromBatch","Remove charge batch detail code",log_debug)
    EXECUTE afc_da_upt_charge_batch_dtl_cd  WITH replace("REQUEST",detailcodereq), replace("REPLY",
     detailcoderep)
    SET reply->status_data.status = detailcoderep->status_data.status
    IF ((detailcoderep->status_data.status != "S"))
     RETURN(false)
    ENDIF
   ENDIF
   CALL echorecord(flexfieldreq)
   IF (size(flexfieldreq->objarray,5) > 0)
    CALL logmessage("delChargeFromBatch","Remove charge batch flex fields",log_debug)
    EXECUTE afc_da_upt_chrg_batch_dtl_fld  WITH replace("REQUEST",flexfieldreq), replace("REPLY",
     flexfieldrep)
    SET reply->status_data.status = flexfieldrep->status_data.status
    IF ((flexfieldrep->status_data.status != "S"))
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
   CALL logmessage("delChargeFromBatch","End sub",log_debug)
 END ;Subroutine
 SUBROUTINE delchargebatch(null)
   CALL logmessage("delChargeBatch","Begin sub",log_debug)
   EXECUTE afc_da_upt_charge_batch  WITH replace("REQUEST",chrgbatchreq), replace("REPLY",
    chrgbatchrep)
   SET reply->status_data.status = chrgbatchrep->status_data.status
   IF ((chrgbatchrep->status_data.status != "S"))
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
   CALL logmessage("delChargeBatch","End sub",log_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD chrgbatchreq
 FREE RECORD chrgbatchrep
 FREE RECORD chrgeventreq
 FREE RECORD chrgeventrep
 FREE RECORD detailcodereq
 FREE RECORD detailcoderep
 FREE RECORD flexfieldreq
 FREE RECORD flexfieldrep
END GO
