CREATE PROGRAM afc_srv_add_charge:dba
 CALL echo(
  "##############################################################################################")
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
 CALL echo("Begin including pft_identify_charge_original_org.inc, version [520969.001]")
 SUBROUTINE (determineoriginalorgforcharge(pencounterid=f8,pservicedatetime=dq8) =f8)
   CALL logmessage("PFT_IDENTIFY_CHARGE_ORIGINAL_ORG","Starting",log_debug)
   DECLARE originalorgid = f8 WITH protect, noconstant(0.0)
   DECLARE dencntrlochistid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM encntr_loc_hist elh
    PLAN (elh
     WHERE elh.encntr_id=pencounterid
      AND elh.beg_effective_dt_tm <= cnvtdatetime(pservicedatetime)
      AND elh.end_effective_dt_tm >= cnvtdatetime(pservicedatetime))
    DETAIL
     originalorgid = elh.organization_id
    WITH nocounter
   ;end select
   IF (originalorgid=0.0)
    SELECT INTO "nl:"
     FROM encntr_loc_hist elh
     PLAN (elh
      WHERE elh.encntr_id=pencounterid)
     ORDER BY elh.encntr_loc_hist_id
     HEAD elh.encntr_loc_hist_id
      dencntrlochistid = elh.encntr_loc_hist_id
     WITH maxrec = 1
    ;end select
    SELECT INTO "nl:"
     FROM encntr_loc_hist elh,
      encounter e
     PLAN (elh
      WHERE elh.encntr_id=pencounterid
       AND elh.encntr_loc_hist_id=dencntrlochistid
       AND elh.end_effective_dt_tm >= cnvtdatetime(pservicedatetime))
      JOIN (e
      WHERE e.encntr_id=elh.encntr_id
       AND e.reg_dt_tm <= cnvtdatetime(pservicedatetime))
     DETAIL
      originalorgid = elh.organization_id
     WITH nocounter
    ;end select
   ENDIF
   IF (originalorgid=0.0)
    SELECT INTO "nl:"
     FROM encounter e
     PLAN (e
      WHERE e.encntr_id=pencounterid)
     DETAIL
      originalorgid = e.organization_id
     WITH nocounter
    ;end select
   ENDIF
   RETURN(originalorgid)
 END ;Subroutine
 RECORD reply(
   1 error_qual = i2
   1 error_information[*]
     2 error_code = i2
     2 error_msg = c132
   1 charge_item_id = f8
   1 realtime_ind = i2
 )
 SET error_code = 1
 SET error_msg = fillstring(132," ")
 SET error_count = 0
 SET error_clear = 0
 SET msg_clear = fillstring(132," ")
 DECLARE chargeoriginalorgid = f8 WITH noconstant(0.0), protect
 SET new_nbr = 0.0
 SELECT INTO "nl:"
  y = seq(charge_event_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_nbr = cnvtreal(y)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET reply->charge_item_id = - (2)
  GO TO end_program
 ELSE
  SET reply->charge_item_id = new_nbr
 ENDIF
 SET error_clear = error(msg_clear,1)
 SET chargeoriginalorgid = 0.0
 IF (validate(request->encntr_id,- (0.00001)) > 0.0
  AND validate(request->service_dt_tm,0.0) > 0.0)
  SET chargeoriginalorgid = determineoriginalorgforcharge(request->encntr_id,request->service_dt_tm)
 ENDIF
 INSERT  FROM charge c
  SET c.charge_item_id = new_nbr, c.charge_event_id = request->charge_event_id, c.charge_event_act_id
    = request->charge_act_id,
   c.bill_item_id = request->bill_item_id, c.charge_description = request->charge_description, c
   .gross_price = request->gross_price,
   c.discount_amount = request->discount_amount, c.item_price = request->item_price, c.person_id =
   request->person_id,
   c.encntr_id = request->encntr_id, c.interface_file_id = request->interface_id, c.tier_group_cd =
   request->tier_group_cd,
   c.def_bill_item_id = request->def_bill_item_id, c.price_sched_id = request->price_sched_id, c
   .payor_id = request->payor_id,
   c.item_quantity = request->item_quantity, c.item_extended_price = request->item_extended_price, c
   .parent_charge_item_id = request->parent_charge_item_id,
   c.charge_type_cd = request->charge_type_cd, c.suspense_rsn_cd = request->suspense_rsn_cd, c
   .reason_comment = request->reason_comment,
   c.posted_cd = request->posted_cd, c.order_id = request->order_id, c.process_flg = request->
   process_flg,
   c.ord_loc_cd = request->ord_loc_cd, c.perf_loc_cd = request->perf_loc_cd, c.ord_phys_id = request
   ->ord_phys_id,
   c.verify_phys_id = request->verify_phys_id, c.perf_phys_id = request->perf_phys_id, c
   .activity_dt_tm =
   IF ((request->activity_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->activity_dt_tm)
   ENDIF
   ,
   c.service_dt_tm =
   IF ((request->service_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->service_dt_tm)
   ENDIF
   , c.active_ind = request->active_ind, c.active_status_cd = request->active_status_cd,
   c.active_status_prsnl_id = request->active_status_prsnl_id, c.active_status_dt_tm = cnvtdatetime(
    sysdate), c.updt_cnt = 0,
   c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = request->updt_id, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_task = reqinfo->updt_task, c.beg_effective_dt_tm =
   IF ((request->beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->beg_effective_dt_tm)
   ENDIF
   , c.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"),
   c.manual_ind = request->manual_ind, c.inst_fin_nbr = request->inst_fin_nbr, c.research_acct_id =
   request->research_acct_id,
   c.admit_type_cd = request->admit_type_cd, c.med_service_cd = request->med_service_cd, c
   .institution_cd = request->institution_cd,
   c.department_cd = request->department_cd, c.section_cd = request->section_cd, c.subsection_cd =
   request->subsection_cd,
   c.level5_cd = request->level5_cd, c.cost_center_cd = request->cost_center_cd, c.abn_status_cd =
   request->abn_status_cd,
   c.activity_type_cd = request->activity_type_cd, c.fin_class_cd = request->fin_class_cd, c
   .health_plan_id = request->health_plan_id,
   c.credited_dt_tm =
   IF (uar_get_code_meaning(request->charge_type_cd)="CR") cnvtdatetime(curdate,curtime)
   ELSE null
   ENDIF
   , c.original_org_id = chargeoriginalorgid, c.original_encntr_id =
   IF (validate(request->parent_charge_item_id,0)=0) request->encntr_id
   ELSE
    (SELECT
     c.original_encntr_id
     FROM charge c
     WHERE (c.charge_item_id=request->parent_charge_item_id))
   ENDIF
  WITH nocounter
 ;end insert
 SET error_code = error(error_msg,0)
 WHILE (error_code != 0)
   SET error_count += 1
   SET reply->error_qual = error_count
   SET stat = alterlist(reply->error_information,error_count)
   SET reply->error_information[error_count].error_code = error_code
   SET reply->error_information[error_count].error_msg = error_msg
   SET error_code = error(error_msg,0)
 ENDWHILE
 CALL echo("after insert")
 IF (curqual=0)
  SET request->charge_item_id = - (3)
 ELSE
  SELECT INTO "nl:"
   realtime_ind = interfacefiles->files[d1.seq].realtime_ind
   FROM (dummyt d1  WITH seq = value(size(interfacefiles->files,5)))
   WHERE (interfacefiles->files[d1.seq].interface_file_id=request->interface_id)
   DETAIL
    reply->realtime_ind = realtime_ind
   WITH nocounter
  ;end select
  CALL echo(build("reply->realtime_ind: ",reply->realtime_ind))
 ENDIF
#end_program
 CALL echo(
  "##############################################################################################")
END GO
