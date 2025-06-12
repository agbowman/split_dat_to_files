CREATE PROGRAM afc_ens_price_sched_item:dba
 CALL echo("running..afc_ens_p_s_i")
 IF ( NOT (validate(afc_ens_price_sched_items_script_vrsn)))
  DECLARE afc_ens_price_sched_items_script_vrsn = vc WITH constant("464331.001"), private
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
 CALL beginservice(afc_ens_price_sched_items_script_vrsn)
 FREE RECORD pricescheditemhistory
 RECORD pricescheditemhistory(
   1 price_sched_items_hist_qual = i2
   1 price_sched_items_hist[*]
     2 price_sched_items_hist_id = f8
     2 price_sched_items_id = f8
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price = f8
     2 allowable = f8
     2 copay = f8
     2 deductible = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind = i2
     2 exclusive_ind = i2
     2 tax = f8
     2 cost_adj_amt = f8
     2 billing_discount_priority_seq = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 units_ind = i2
     2 stats_only_ind = i2
     2 capitation_ind = i2
     2 referral_req_ind = i2
     2 permanent_del_ind = i2
     2 modification_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i2
     2 updt_dt_tm = dq8
     2 updt_task = f8
     2 updt_applctx = f8
     2 task_action_flag = i2
 )
 FREE RECORD addedpricescheditemreply
 RECORD addedpricescheditemreply(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF (validate(preparehistoryrequest,char(128))=char(128))
  DECLARE preparehistoryrequest(pricescheditemid=f8,actiontype=vc) = null WITH protect
 ENDIF
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET updt_cnt_error = 20
 SET failed = false
 SET table_name = fillstring(50," ")
 FREE RECORD reply
 RECORD reply(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET hafc_ens_price_sched_item = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET table_name = "PRICE_SCHED_ITEMS"
 CALL echo("executing afc_ens_price_sched_items.....")
 IF ((request->price_sched_items_qual > 0))
  SET reply->price_sched_items_qual = request->price_sched_items_qual
  SET stat = alterlist(reply->price_sched_items,request->price_sched_items_qual)
  SET stat = initrec(addedpricescheditemreply)
  FOR (inx0 = 1 TO request->price_sched_items_qual)
    CASE (request->price_sched_items[inx0].action_type)
     OF "ADD":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE afc_add_price_sched_item  WITH replace("REPLY",addedpricescheditemreply)
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "UPT":
      SET action_begin = inx0
      SET action_end = inx0
      CALL preparehistoryrequest(request->price_sched_items[inx0].price_sched_items_id,"UPT")
      EXECUTE afc_upt_price_sched_item
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "DEL":
      SET action_begin = inx0
      SET action_end = inx0
      CALL preparehistoryrequest(request->price_sched_items[inx0].price_sched_items_id,"DEL")
      EXECUTE afc_del_price_sched_item
      IF (failed != false)
       GO TO check_error
      ENDIF
     ELSE
      SET failed = true
      GO TO check_error
    ENDCASE
  ENDFOR
  IF (validate(addedpricescheditemreply->price_sched_items)
   AND size(addedpricescheditemreply->price_sched_items,5) > 0)
   FOR (futureeffaddindex = 1 TO size(addedpricescheditemreply->price_sched_items,5))
     IF (validate(addedpricescheditemreply->price_sched_items[futureeffaddindex].price_sched_items_id,
      0.0) > 0.0)
      CALL preparehistoryrequest(addedpricescheditemreply->price_sched_items[futureeffaddindex].
       price_sched_items_id,"ADD")
     ENDIF
   ENDFOR
  ENDIF
  IF (size(pricescheditemhistory->price_sched_items_hist,5) > 0)
   EXECUTE afc_add_price_sched_item_hist  WITH replace("REQUEST",pricescheditemhistory)
   IF (failed != false)
    CALL logmessage(nullterm("afc_add_price_sched_item_hist"),nullterm(
      "Failure in archiving Bill Item Modification(s)"),log_error)
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL exitservicesuccess(build("Success"))
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   OF updt_cnt_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDT_CNT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
 SUBROUTINE preparehistoryrequest(pricescheditemid,actiontype)
   IF ((validate(rec_count,- (1))=- (1)))
    DECLARE rec_count = i2 WITH protect, noconstant(0)
   ENDIF
   IF ((validate(task_action_flag,- (1))=- (1)))
    DECLARE task_action_flag = i2 WITH protect, noconstant(0)
   ENDIF
   SET rec_count = (pricescheditemhistory->price_sched_items_hist_qual+ 1)
   SET stat = alterlist(pricescheditemhistory->price_sched_items_hist,rec_count)
   SET pricescheditemhistory->price_sched_items_hist_qual = rec_count
   IF (actiontype="ADD")
    SET task_action_flag = 0
   ELSEIF (actiontype="UPT")
    SET task_action_flag = 1
   ELSEIF (actiontype="DEL")
    SET task_action_flag = 2
   ENDIF
   SELECT INTO "nl:"
    psi.*
    FROM price_sched_items psi
    WHERE psi.price_sched_items_id=pricescheditemid
     AND psi.active_ind=true
    DETAIL
     stat = alterlist(pricescheditemhistory->price_sched_items_hist,rec_count), pricescheditemhistory
     ->price_sched_items_hist[rec_count].price_sched_items_hist_id = 0.0, pricescheditemhistory->
     price_sched_items_hist[rec_count].price_sched_items_id = psi.price_sched_items_id,
     pricescheditemhistory->price_sched_items_hist[rec_count].price_sched_id = psi.price_sched_id,
     pricescheditemhistory->price_sched_items_hist[rec_count].bill_item_id = psi.bill_item_id,
     pricescheditemhistory->price_sched_items_hist[rec_count].price = psi.price,
     pricescheditemhistory->price_sched_items_hist[rec_count].allowable = psi.allowable,
     pricescheditemhistory->price_sched_items_hist[rec_count].copay = psi.copay,
     pricescheditemhistory->price_sched_items_hist[rec_count].deductible = psi.deductible,
     pricescheditemhistory->price_sched_items_hist[rec_count].percent_revenue = psi.percent_revenue,
     pricescheditemhistory->price_sched_items_hist[rec_count].charge_level_cd = psi.charge_level_cd,
     pricescheditemhistory->price_sched_items_hist[rec_count].interval_template_cd = psi
     .interval_template_cd,
     pricescheditemhistory->price_sched_items_hist[rec_count].detail_charge_ind = psi
     .detail_charge_ind, pricescheditemhistory->price_sched_items_hist[rec_count].exclusive_ind = psi
     .exclusive_ind, pricescheditemhistory->price_sched_items_hist[rec_count].tax = psi.tax,
     pricescheditemhistory->price_sched_items_hist[rec_count].cost_adj_amt = psi.cost_adj_amt,
     pricescheditemhistory->price_sched_items_hist[rec_count].billing_discount_priority_seq = psi
     .billing_discount_priority_seq, pricescheditemhistory->price_sched_items_hist[rec_count].
     active_ind = psi.active_ind,
     pricescheditemhistory->price_sched_items_hist[rec_count].active_status_cd = psi.active_status_cd,
     pricescheditemhistory->price_sched_items_hist[rec_count].active_status_dt_tm = psi
     .active_status_dt_tm, pricescheditemhistory->price_sched_items_hist[rec_count].
     active_status_prsnl_id = psi.active_status_prsnl_id,
     pricescheditemhistory->price_sched_items_hist[rec_count].beg_effective_dt_tm = psi
     .beg_effective_dt_tm, pricescheditemhistory->price_sched_items_hist[rec_count].
     end_effective_dt_tm = psi.end_effective_dt_tm, pricescheditemhistory->price_sched_items_hist[
     rec_count].units_ind = psi.units_ind,
     pricescheditemhistory->price_sched_items_hist[rec_count].stats_only_ind = psi.stats_only_ind,
     pricescheditemhistory->price_sched_items_hist[rec_count].capitation_ind = psi.capitation_ind,
     pricescheditemhistory->price_sched_items_hist[rec_count].referral_req_ind = psi.referral_req_ind,
     pricescheditemhistory->price_sched_items_hist[rec_count].permanent_del_ind = 0,
     pricescheditemhistory->price_sched_items_hist[rec_count].modification_dt_tm = psi.updt_dt_tm,
     pricescheditemhistory->price_sched_items_hist[rec_count].updt_id = psi.updt_id,
     pricescheditemhistory->price_sched_items_hist[rec_count].updt_cnt = psi.updt_cnt,
     pricescheditemhistory->price_sched_items_hist[rec_count].updt_dt_tm = psi.updt_dt_tm,
     pricescheditemhistory->price_sched_items_hist[rec_count].updt_task = psi.updt_task,
     pricescheditemhistory->price_sched_items_hist[rec_count].updt_applctx = psi.updt_applctx,
     pricescheditemhistory->price_sched_items_hist[rec_count].task_action_flag = task_action_flag
    WITH nocounter
   ;end select
   SET pricescheditemhistory->price_sched_items_hist_qual = rec_count
   SET rec_count = (rec_count+ 1)
   IF (curqual=0)
    SET failed = select_error
    SET reply->status_data.status = "Z"
    RETURN
   ENDIF
 END ;Subroutine
#end_program
END GO
