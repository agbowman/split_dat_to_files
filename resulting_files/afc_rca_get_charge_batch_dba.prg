CREATE PROGRAM afc_rca_get_charge_batch:dba
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
  RECORD reply(
    1 chargebatchid = f8
    1 createdprsnlid = f8
    1 assignedprsnlid = f8
    1 userdefinedind = i2
    1 statuscd = f8
    1 statusdttm = dq8
    1 createddttm = dq8
    1 accesseddttm = dq8
    1 chargebatchalias = vc
    1 chargebatchdate = dq8
    1 updt_cnt = i4
    1 chargeevents[*]
      2 chargebatchdetailid = f8
      2 encounterid = f8
      2 orderingphysid = f8
      2 renderingphysid = f8
      2 billitemid = f8
      2 serviceitemident = vc
      2 serviceitemidenttypecd = f8
      2 serviceitemqty = f8
      2 serviceitempriceamt = f8
      2 serviceitemdesc = vc
      2 servicedttm = dq8
      2 perfloccd = f8
      2 statuscd = f8
      2 updt_cnt = i4
      2 copayamt = f8
      2 deductibleamt = f8
      2 patrespflag = i2
      2 batchdetailcodes[*]
        3 chargebatchdetailcodeid = f8
        3 parententityname = vc
        3 parententityid = f8
        3 typecd = f8
        3 typeident = vc
        3 priorityseq = i4
      2 flexfields[*]
        3 fieldtypecd = f8
        3 fielddatetime = dq8
        3 fieldchar = vc
        3 fieldnbr = f8
        3 fieldind = i2
        3 fieldcd = f8
        3 fieldvaluetype = vc
      2 serviceresourcecd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cntdetail = i4 WITH protect, noconstant(0)
 DECLARE cntcodes = i4 WITH protect, noconstant(0)
 DECLARE cntfields = i4 WITH protect, noconstant(0)
 CALL beginservice("259452.003")
 CALL logmessage("Main","Begining main processing",log_debug)
 IF ( NOT (validate(request->chargebatchid,- (1)) > 0.0))
  CALL exitservicefailure("No Value passed for ChargeBatchID",true)
 ENDIF
 SELECT INTO "nl:"
  FROM charge_batch c
  WHERE (c.charge_batch_id=request->chargebatchid)
   AND c.active_ind=1
  DETAIL
   reply->chargebatchid = c.charge_batch_id, reply->createdprsnlid = c.created_prsnl_id, reply->
   assignedprsnlid = c.assigned_prsnl_id,
   reply->userdefinedind = c.user_defined_ind, reply->statuscd = c.status_cd, reply->statusdttm = c
   .status_dt_tm,
   reply->createddttm = c.created_dt_tm, reply->accesseddttm = c.accessed_dt_tm, reply->
   chargebatchalias = c.batch_alias,
   reply->chargebatchdate = c.batch_dt_tm, reply->updt_cnt = c.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL logmessage("Main","Get charge events",log_debug)
  SELECT INTO "nl:"
   FROM charge_batch_detail c
   WHERE (c.charge_batch_id=reply->chargebatchid)
    AND c.active_ind=1
   DETAIL
    cntdetail = (cntdetail+ 1)
    IF (mod(cntdetail,10)=1)
     stat = alterlist(reply->chargeevents,(cntdetail+ 9))
    ENDIF
    reply->chargeevents[cntdetail].chargebatchdetailid = c.charge_batch_detail_id, reply->
    chargeevents[cntdetail].encounterid = c.encntr_id, reply->chargeevents[cntdetail].orderingphysid
     = c.ordering_phys_id,
    reply->chargeevents[cntdetail].renderingphysid = c.rendering_phys_id, reply->chargeevents[
    cntdetail].billitemid = c.bill_item_id, reply->chargeevents[cntdetail].serviceitemident = c
    .service_item_ident,
    reply->chargeevents[cntdetail].serviceitemidenttypecd = c.service_item_ident_type_cd, reply->
    chargeevents[cntdetail].serviceitemqty = c.service_item_qty, reply->chargeevents[cntdetail].
    serviceitemdesc = c.service_item_desc,
    reply->chargeevents[cntdetail].servicedttm = c.service_dt_tm, reply->chargeevents[cntdetail].
    perfloccd = c.perf_loc_cd, reply->chargeevents[cntdetail].statuscd = c.status_cd,
    reply->chargeevents[cntdetail].updt_cnt = c.updt_cnt, reply->chargeevents[cntdetail].copayamt = c
    .item_copay_amt, reply->chargeevents[cntdetail].deductibleamt = c.item_deductible_amt,
    reply->chargeevents[cntdetail].patrespflag = c.patient_responsibility_flag
    IF ((validate(reply->chargeevents[cntdetail].serviceresourcecd,- (0.00001)) != - (0.00001)))
     reply->chargeevents[cntdetail].serviceresourcecd = c.service_resource_cd
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->chargeevents,cntdetail)
  IF (size(reply->chargeevents,5) > 0)
   CALL logmessage("Main","Get detail codes",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch_detail_code c,
     (dummyt d1  WITH seq = value(size(reply->chargeevents,5)))
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_batch_detail_id=reply->chargeevents[d1.seq].chargebatchdetailid)
      AND c.active_ind=1)
    HEAD c.charge_batch_detail_id
     cntcodes = 0
    DETAIL
     cntcodes = (cntcodes+ 1), stat = alterlist(reply->chargeevents[d1.seq].batchdetailcodes,cntcodes
      ), reply->chargeevents[d1.seq].batchdetailcodes[cntcodes].chargebatchdetailcodeid = c
     .charge_batch_detail_code_id,
     reply->chargeevents[d1.seq].batchdetailcodes[cntcodes].parententityname = c.parent_entity_name,
     reply->chargeevents[d1.seq].batchdetailcodes[cntcodes].parententityid = c.parent_entity_id,
     reply->chargeevents[d1.seq].batchdetailcodes[cntcodes].typecd = c.type_cd,
     reply->chargeevents[d1.seq].batchdetailcodes[cntcodes].typeident = c.type_ident, reply->
     chargeevents[d1.seq].batchdetailcodes[cntcodes].priorityseq = c.priority_seq
    WITH nocounter
   ;end select
   CALL logmessage("Main","Get flex fields",log_debug)
   SELECT INTO "nl:"
    FROM charge_batch_detail_field c,
     code_value_extension cve,
     (dummyt d1  WITH seq = value(size(reply->chargeevents,5)))
    PLAN (d1)
     JOIN (c
     WHERE (c.charge_batch_detail_id=reply->chargeevents[d1.seq].chargebatchdetailid)
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
     reply->chargeevents[d1.seq].flexfields[cntfields].fieldtypecd = c.field_type_cd, reply->
     chargeevents[d1.seq].flexfields[cntfields].fielddatetime = c.field_value_dt_tm, reply->
     chargeevents[d1.seq].flexfields[cntfields].fieldchar = c.field_value_char,
     reply->chargeevents[d1.seq].flexfields[cntfields].fieldnbr = c.field_value_nbr, reply->
     chargeevents[d1.seq].flexfields[cntfields].fieldind = c.field_value_ind, reply->chargeevents[d1
     .seq].flexfields[cntfields].fieldcd = c.field_value_cd,
     reply->chargeevents[d1.seq].flexfields[cntfields].fieldvaluetype = cve.field_value
    FOOT  c.charge_batch_detail_id
     stat = alterlist(reply->chargeevents[d1.seq].flexfields,cntfields)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  CALL exitservicenodata(build("No batch returned for batch ID: ",request->chargebatchid),
   go_to_exit_script)
 ENDIF
 CALL exitservicesuccess("Exiting script")
#exit_script
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
