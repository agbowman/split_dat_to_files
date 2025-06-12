CREATE PROGRAM afc_add_charge:dba
 SET afc_add_charge_vrsn = "CHARGSRV-14536.FT.009"
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(pft_failed,0)=0
  AND validate(pft_failed,1)=1)
  DECLARE pft_failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(table_name,"X")="X"
  AND validate(table_name,"Z")="Z")
  DECLARE table_name = vc WITH public, noconstant(" ")
 ENDIF
 IF (validate(call_echo_ind,0)=0
  AND validate(call_echo_ind,1)=1)
  DECLARE call_echo_ind = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(failed,0)=0
  AND validate(failed,1)=1)
  DECLARE failed = i2 WITH public, noconstant(false)
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
 DECLARE mdtdanone = q8 WITH noconstant(0.0)
 DECLARE mdtdaend = q8 WITH noconstant(0.0)
 DECLARE msdatablename = vc WITH noconstant("")
 SET mdtdanone = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET mdtdaend = cnvtdatetime("31-DEC-2100 23:59:59.00")
 SET msdatablename = "CHARGE"
 DECLARE mndamodobj = i4 WITH noconstant(0)
 DECLARE mndamodrec = i4 WITH noconstant(0)
 DECLARE mndamodfld = i4 WITH noconstant(0)
 DECLARE mndastart = i4 WITH noconstant(1)
 DECLARE mndastop = i4 WITH noconstant(0)
 IF (trim(cnvtstring(validate(transinfo->trans_dt_tm,0)))="0")
  RECORD transinfo(
    1 trans_dt_tm = dq8
  )
  SET transinfo->trans_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 IF (validate(reply->mod_objs,"Z")="Z")
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
  )
 ENDIF
 SET mndamodobj = size(reply->mod_objs,5)
 IF (mndamodobj=0)
  SET stat = alterlist(reply->mod_objs,1)
  SET mndamodobj = 1
  SET reply->mod_objs[mndamodobj].entity_type = msdatablename
 ENDIF
 SET mndamodrec = size(reply->mod_objs[mndamodobj].mod_recs,5)
 SET mndastop = size(request->objarray,5)
 SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs,(mndamodrec+ ((mndastop - mndastart)+ 1)))
 SET reply->status_data.status = "F"
 IF (validate(reply->charges))
  SET stat = alterlist(reply->charges,size(request->objarray,5))
 ENDIF
 CALL add_charge(mndastart,mndastop)
 SUBROUTINE (add_charge(nstart=i4,nstop=i4) =null WITH protect)
   DECLARE dactivestatuscd = f8 WITH noconstant(0.0), protect
   DECLARE did = f8 WITH noconstant(0.0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE chargeidx = i4 WITH noconstant(0), protect
   DECLARE chargeoriginalorgid = f8 WITH noconstant(0.0), protect
   SET dactivestatuscd = reqdata->active_status_cd
   SET i = nstart
   WHILE (i <= nstop)
     SET did = 0.0
     SET chargeoriginalorgid = 0.0
     IF (validate(request->objarray[i].charge_item_id,- (0.00001)) <= 0.0)
      SELECT INTO "nl:"
       sdapk = seq(charge_event_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        did = cnvtreal(sdapk)
       WITH format, counter
      ;end select
      IF (curqual=0)
       IF (false=checkerror(gen_nbr_error))
        RETURN
       ENDIF
      ELSE
       SET request->objarray[i].charge_item_id = did
      ENDIF
     ELSE
      SET did = request->objarray[i].charge_item_id
     ENDIF
     IF (validate(request->objarray[i].encntr_id,- (0.00001)) > 0.0
      AND validate(request->objarray[i].service_dt_tm,0.0) > 0.0)
      SET chargeoriginalorgid = determineoriginalorgforcharge(request->objarray[i].encntr_id,request
       ->objarray[i].service_dt_tm)
     ENDIF
     INSERT  FROM charge c
      SET c.charge_item_id = did, c.parent_charge_item_id =
       IF ((validate(request->objarray[i].parent_charge_item_id,- (0.00001)) != - (0.00001)))
        validate(request->objarray[i].parent_charge_item_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.charge_event_act_id =
       IF ((validate(request->objarray[i].charge_event_act_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].charge_event_act_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.charge_event_id =
       IF ((validate(request->objarray[i].charge_event_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].charge_event_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.bill_item_id =
       IF ((validate(request->objarray[i].bill_item_id,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].bill_item_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.order_id =
       IF ((validate(request->objarray[i].order_id,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].order_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.encntr_id =
       IF ((validate(request->objarray[i].encntr_id,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].encntr_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.person_id =
       IF ((validate(request->objarray[i].person_id,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].person_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.payor_id =
       IF ((validate(request->objarray[i].payor_id,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].payor_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.ord_loc_cd =
       IF ((validate(request->objarray[i].ord_loc_cd,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].ord_loc_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.perf_loc_cd =
       IF ((validate(request->objarray[i].perf_loc_cd,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].perf_loc_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.ord_phys_id =
       IF ((validate(request->objarray[i].ord_phys_id,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].ord_phys_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.perf_phys_id =
       IF ((validate(request->objarray[i].perf_phys_id,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].perf_phys_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.charge_description =
       IF (validate(request->objarray[i].charge_description,char(128)) != char(128)) validate(request
         ->objarray[i].charge_description,char(128))
       ELSE null
       ENDIF
       , c.price_sched_id =
       IF ((validate(request->objarray[i].price_sched_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].price_sched_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.item_quantity =
       IF ((validate(request->objarray[i].item_quantity,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_quantity,- (0.00001))
       ELSE null
       ENDIF
       , c.item_price =
       IF ((validate(request->objarray[i].item_price,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].item_price,- (0.00001))
       ELSE null
       ENDIF
       , c.item_extended_price =
       IF ((validate(request->objarray[i].item_extended_price,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_extended_price,- (0.00001))
       ELSE null
       ENDIF
       ,
       c.item_allowable =
       IF ((validate(request->objarray[i].item_allowable,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_allowable,- (0.00001))
       ELSE null
       ENDIF
       , c.item_copay =
       IF ((validate(request->objarray[i].item_copay,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].item_copay,- (0.00001))
       ELSE null
       ENDIF
       , c.charge_type_cd =
       IF ((validate(request->objarray[i].charge_type_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].charge_type_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.research_acct_id =
       IF ((validate(request->objarray[i].research_acct_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].research_acct_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.suspense_rsn_cd =
       IF ((validate(request->objarray[i].suspense_rsn_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].suspense_rsn_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.reason_comment =
       IF (validate(request->objarray[i].reason_comment,char(128)) != char(128)) validate(request->
         objarray[i].reason_comment,char(128))
       ELSE null
       ENDIF
       ,
       c.posted_cd =
       IF ((validate(request->objarray[i].posted_cd,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].posted_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.posted_dt_tm =
       IF (validate(request->objarray[i].posted_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].posted_dt_tm,0.0))
       ELSE null
       ENDIF
       , c.process_flg =
       IF ((validate(request->objarray[i].process_flg,- (1)) != - (1))) validate(request->objarray[i]
         .process_flg,- (1))
       ELSE null
       ENDIF
       ,
       c.service_dt_tm =
       IF (validate(request->objarray[i].service_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].service_dt_tm,0.0))
       ELSE null
       ENDIF
       , c.activity_dt_tm =
       IF (validate(request->objarray[i].activity_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].activity_dt_tm,0.0))
       ELSE null
       ENDIF
       , c.beg_effective_dt_tm =
       IF (validate(request->objarray[i].beg_effective_dt_tm,0.0) > 0.0) cnvtdatetime(validate(
          request->objarray[i].beg_effective_dt_tm,0.0))
       ELSE cnvtdatetime(transinfo->trans_dt_tm)
       ENDIF
       ,
       c.end_effective_dt_tm =
       IF (validate(request->objarray[i].end_effective_dt_tm,0.0) > 0.0) cnvtdatetime(validate(
          request->objarray[i].end_effective_dt_tm,0.0))
       ELSE cnvtdatetime(mdtdaend)
       ENDIF
       , c.credited_dt_tm =
       IF (validate(request->objarray[i].credited_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].credited_dt_tm,0.0))
       ELSE null
       ENDIF
       , c.adjusted_dt_tm =
       IF (validate(request->objarray[i].adjusted_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].adjusted_dt_tm,0.0))
       ELSE null
       ENDIF
       ,
       c.interface_file_id =
       IF ((validate(request->objarray[i].interface_file_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].interface_file_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.tier_group_cd =
       IF ((validate(request->objarray[i].tier_group_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].tier_group_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.def_bill_item_id =
       IF ((validate(request->objarray[i].def_bill_item_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].def_bill_item_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.verify_phys_id =
       IF ((validate(request->objarray[i].verify_phys_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].verify_phys_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.gross_price =
       IF ((validate(request->objarray[i].gross_price,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].gross_price,- (0.00001))
       ELSE null
       ENDIF
       , c.discount_amount =
       IF ((validate(request->objarray[i].discount_amount,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].discount_amount,- (0.00001))
       ELSE null
       ENDIF
       ,
       c.manual_ind =
       IF ((validate(request->objarray[i].manual_ind,- (1)) != - (1))) validate(request->objarray[i].
         manual_ind,- (1))
       ELSE null
       ENDIF
       , c.combine_ind =
       IF ((validate(request->objarray[i].combine_ind,- (1)) != - (1))) validate(request->objarray[i]
         .combine_ind,- (1))
       ELSE null
       ENDIF
       , c.activity_type_cd =
       IF ((validate(request->objarray[i].activity_type_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].activity_type_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.activity_sub_type_cd =
       IF ((validate(request->objarray[i].activity_sub_type_cd,- (0.00001)) != - (0.00001))) validate
        (request->objarray[i].activity_sub_type_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.provider_specialty_cd =
       IF ((validate(request->objarray[i].provider_specialty_cd,- (0.00001)) != - (0.00001)))
        validate(request->objarray[i].provider_specialty_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.admit_type_cd =
       IF ((validate(request->objarray[i].admit_type_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].admit_type_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.bundle_id =
       IF ((validate(request->objarray[i].bundle_id,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].bundle_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.department_cd =
       IF ((validate(request->objarray[i].department_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].department_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.institution_cd =
       IF ((validate(request->objarray[i].institution_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].institution_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.level5_cd =
       IF ((validate(request->objarray[i].level5_cd,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].level5_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.med_service_cd =
       IF ((validate(request->objarray[i].med_service_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].med_service_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.section_cd =
       IF ((validate(request->objarray[i].section_cd,- (0.00001)) != - (0.00001))) validate(request->
         objarray[i].section_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.subsection_cd =
       IF ((validate(request->objarray[i].subsection_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].subsection_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.abn_status_cd =
       IF ((validate(request->objarray[i].abn_status_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].abn_status_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.cost_center_cd =
       IF ((validate(request->objarray[i].cost_center_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].cost_center_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.inst_fin_nbr =
       IF (validate(request->objarray[i].inst_fin_nbr,char(128)) != char(128)) validate(request->
         objarray[i].inst_fin_nbr,char(128))
       ELSE null
       ENDIF
       , c.fin_class_cd =
       IF ((validate(request->objarray[i].fin_class_cd,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].fin_class_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.health_plan_id =
       IF ((validate(request->objarray[i].health_plan_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].health_plan_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.item_interval_id =
       IF ((validate(request->objarray[i].item_interval_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_interval_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.item_list_price =
       IF ((validate(request->objarray[i].item_list_price,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_list_price,- (0.00001))
       ELSE null
       ENDIF
       , c.item_reimbursement =
       IF ((validate(request->objarray[i].item_reimbursement,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_reimbursement,- (0.00001))
       ELSE null
       ENDIF
       ,
       c.list_price_sched_id =
       IF ((validate(request->objarray[i].list_price_sched_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].list_price_sched_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.payor_type_cd =
       IF ((validate(request->objarray[i].payor_type_cd,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].payor_type_cd,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.epsdt_ind =
       IF ((validate(request->objarray[i].epsdt_ind,- (1)) != - (1))) validate(request->objarray[i].
         epsdt_ind,- (1))
       ELSE null
       ENDIF
       ,
       c.ref_phys_id =
       IF ((validate(request->objarray[i].ref_phys_id,- (0.00001)) != - (0.00001))) validate(request
         ->objarray[i].ref_phys_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.start_dt_tm =
       IF (validate(request->objarray[i].start_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].start_dt_tm,0.0))
       ELSE null
       ENDIF
       , c.stop_dt_tm =
       IF (validate(request->objarray[i].stop_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
          objarray[i].stop_dt_tm,0.0))
       ELSE null
       ENDIF
       ,
       c.alpha_nomen_id =
       IF ((validate(request->objarray[i].alpha_nomen_id,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].alpha_nomen_id,- (0.00001))
       ELSE 0.0
       ENDIF
       , c.server_process_flag =
       IF ((validate(request->objarray[i].server_process_flag,- (1)) != - (1))) validate(request->
         objarray[i].server_process_flag,- (1))
       ELSE null
       ENDIF
       , c.offset_charge_item_id =
       IF ((validate(request->objarray[i].offset_charge_item_id,- (0.00001)) != - (0.00001)))
        validate(request->objarray[i].offset_charge_item_id,- (0.00001))
       ELSE 0.0
       ENDIF
       ,
       c.item_deductible_amt =
       IF ((validate(request->objarray[i].item_deductible_amt,- (0.00001)) != - (0.00001))) validate(
         request->objarray[i].item_deductible_amt,- (0.00001))
       ELSE null
       ENDIF
       , c.patient_responsibility_flag =
       IF ((validate(request->objarray[i].patient_responsibility_flag,- (1)) != - (1))) validate(
         request->objarray[i].patient_responsibility_flag,- (1))
       ELSE 0
       ENDIF
       , c.updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_task
        = reqinfo->updt_task,
       c.updt_applctx = reqinfo->updt_applctx, c.active_ind =
       IF ((validate(request->objarray[i].active_ind,- (1))=- (1))) true
       ELSE validate(request->objarray[i].active_ind,- (1))
       ENDIF
       , c.active_status_cd =
       IF ((validate(request->objarray[i].active_status_cd,- (0.00001))=- (0.00001))) dactivestatuscd
       ELSE evaluate(validate(request->objarray[i].active_status_cd,- (0.00001)),- (0.00001),
         dactivestatuscd,validate(request->objarray[i].active_status_cd,- (0.00001)))
       ENDIF
       ,
       c.active_status_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.active_status_prsnl_id =
       reqinfo->updt_id, c.posted_id = reqinfo->updt_id,
       c.original_org_id = chargeoriginalorgid, c.original_encntr_id =
       IF (validate(request->objarray[i].parent_charge_item_id,0)=0) request->objarray[i].encntr_id
       ELSE
        (SELECT
         c.original_encntr_id
         FROM charge c
         WHERE (c.charge_item_id=request->objarray[i].parent_charge_item_id))
       ENDIF
       , c.item_price_adj_amt =
       IF ((validate(request->objarray[i].item_price_adj_amt,- (0.00001))=- (0.00001))) 0.0
       ELSE validate(request->objarray[i].item_price_adj_amt,- (0.00001))
       ENDIF
      WITH nocounter
     ;end insert
     IF (curqual=0)
      IF (false=checkerror(insert_error))
       RETURN
      ENDIF
     ELSE
      IF (mndamodrec=size(reply->mod_objs[mndamodobj].mod_recs,5))
       SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs,1)
      ENDIF
      SET mndamodrec += 1
      SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].table_name = msdatablename
      SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].pk_values = cnvtstring(did,17,2)
      IF (validate(reply->charges))
       SET chargeidx += 1
       SET reply->charges[chargeidx].charge_item_id = did
      ENDIF
      CALL checkerror(true)
     ENDIF
     SET i += 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (checkerror(nfailed=i4) =i2 WITH protect)
   IF (nfailed=true)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = true
    RETURN(true)
   ELSE
    CASE (nfailed)
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
     ELSE
      SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    ENDCASE
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = msdatablename
    SET reqinfo->commit_ind = false
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (logfieldmodified(sfieldname=vc,sfieldtype=vc,sobjvalue=vc,sdbvalue=vc) =null)
   IF (mndamodfld=size(reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds,5))
    SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds,(mndamodfld+ 1))
   ENDIF
   SET mndamodfld += 1
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_name = sfieldname
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_type = sfieldtype
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_value_obj = trim(
    sobjvalue,3)
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_value_db = trim(
    sdbvalue,3)
 END ;Subroutine
#end_program
 SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs,mndamodrec)
END GO
