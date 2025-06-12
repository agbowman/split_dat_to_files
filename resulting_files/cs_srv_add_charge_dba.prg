CREATE PROGRAM cs_srv_add_charge:dba
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
 IF (validate(logsolutioncapability,char(128))=char(128))
  SUBROUTINE (logsolutioncapability(teamname=vc,capability_ident=vc,entityid=f8,entity_name=vc) =i2)
    RECORD capabilityrequest(
      1 teamname = vc
      1 capability_ident = vc
      1 entities[1]
        2 entity_id = f8
        2 entity_name = vc
    ) WITH protect
    RECORD capabilityreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET capabilityrequest->teamname = teamname
    SET capabilityrequest->capability_ident = capability_ident
    SET capabilityrequest->entities[1].entity_id = entityid
    SET capabilityrequest->entities[1].entity_name = entity_name
    EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilityrequest), replace("REPLY",
     capabilityreply)
    IF ((capabilityreply->status_data.status != "S"))
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 SET cs_srv_add_charge_version = "CHARGSRV-15493.030"
 CALL echo(concat("CS_SRV_ADD_CHARGE - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ( NOT (validate(team_name)))
  DECLARE team_name = vc WITH protect, constant("PATIENT_ACCOUNTING")
 ENDIF
 IF ( NOT (validate(provider_specialty_capability_id)))
  DECLARE provider_specialty_capability_id = vc WITH protect, constant("2015.2.00223.2")
 ENDIF
 IF ( NOT (validate(entity_name)))
  DECLARE entity_name = vc WITH protect, constant("CHARGE")
 ENDIF
 IF ( NOT (validate(cs4518006_manually_added)))
  DECLARE cs4518006_manually_added = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,
    "MANUALLY_ADD"))
 ENDIF
 IF ( NOT (validate(cs4518006_copyfromcem)))
  DECLARE cs4518006_copyfromcem = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,
    "COPYFROMCEM"))
 ENDIF
 IF ( NOT (validate(cs4518006_ref_data)))
  DECLARE cs4518006_ref_data = f8 WITH protect, constant(uar_get_code_by("MEANING",4518006,"REF_DATA"
    ))
 ENDIF
 DECLARE next_nbr = f8
 DECLARE charge_cnt = i2
 DECLARE diag_cnt = i2
 RECORD chargeeventacts(
   1 chargeeventact[*]
     2 charge_event_act_id = f8
     2 prsnl_id = f8
 ) WITH protect
 RECORD priorities(
   1 qual[*]
     2 modpriority = f8
 ) WITH protect
 RECORD modifiers(
   1 qual[*]
     2 field1_id = f8
     2 field6 = c200
     2 field2_id = f8
     2 field_value = i2
     2 field3_id = f8
     2 charge_mod_source_cd = f8
 ) WITH protect
 RECORD physcharges(
   1 charges[*]
     2 charge_item_id = f8
     2 ord_phys_id = f8
 ) WITH protect
 RECORD nomenstruct(
   1 nomen_entity_qual[*]
     2 nomenclature_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 child_entity_name = c32
     2 child_entity_id = f8
     2 reltn_type_cd = i4
     2 freetext_display = vc
     2 person_id = f8
     2 encntr_id = f8
 )
 RECORD nomenstructreply(
   1 nomen_entity_qual[*]
     2 nomen_entity_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chargemodreq(
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
     2 charge_mod_source_cd = f8
 ) WITH protect
 RECORD chargemodreply(
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
 DECLARE nomencnt = i2 WITH noconstant(0)
 IF ((validate(chargecpt4,- (1))=- (1)))
  DECLARE chargecpt4 = f8 WITH noconstant(0.0), persist
  SET stat = uar_get_meaning_by_codeset(23549,nullterm("CHARGECPT4"),1,chargecpt4)
 ENDIF
 IF ((validate(cs13029_verified_cd,- (1))=- (1)))
  DECLARE cs13029_verified_cd = f8 WITH noconstant(0.0), persist
  SET stat = uar_get_meaning_by_codeset(13029,nullterm("VERIFIED"),1,cs13029_verified_cd)
 ENDIF
 IF ((validate(cs13019_noncovered_cd,- (1))=- (1)))
  DECLARE cs13019_noncovered_cd = f8 WITH noconstant(0.0), persist
  SET stat = uar_get_meaning_by_codeset(13019,nullterm("NONCOVERED"),1,cs13019_noncovered_cd)
 ENDIF
 SUBROUTINE getnextnumber(a)
   SELECT INTO "nl:"
    nextchargeid = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_nbr = cnvtreal(nextchargeid)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE chargeoriginalorgid(f)
  DECLARE lidx = i4 WITH noconstant(0)
  FOR (lidx = 1 TO charge_cnt)
    IF ((reply->charges[lidx].encntr_id > 0.0)
     AND cnvtdatetime(reply->charges[lidx].service_dt_tm) > 0.0
     AND validate(reply->charges[lidx].original_org_id)=1)
     SET reply->charges[lidx].original_org_id = determineoriginalorgforcharge(reply->charges[lidx].
      encntr_id,cnvtdatetime(reply->charges[lidx].service_dt_tm))
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE addcharges(b)
   DECLARE charge_loop = i2
   DECLARE mod_cnt = i2
   DECLARE mod_loop = i2
   DECLARE insert_ind = i2
   DECLARE pos = i4
   DECLARE modscount = i4
   DECLARE billcodecnt = i4 WITH protect, noconstant(0)
   CALL echo("Update charge table")
   UPDATE  FROM charge c,
     (dummyt d  WITH seq = value(charge_cnt))
    SET c.charge_event_id = reply->charges[d.seq].charge_event_id, c.charge_event_act_id = reply->
     charges[d.seq].charge_act_id, c.bill_item_id = reply->charges[d.seq].bill_item_id,
     c.charge_description = substring(1,200,trim(reply->charges[d.seq].charge_description)), c
     .gross_price = reply->charges[d.seq].gross_price, c.discount_amount = reply->charges[d.seq].
     discount_amount,
     c.item_price_adj_amt = validate(reply->charges[d.seq].item_price_adj_amt,0.0), c.item_price =
     reply->charges[d.seq].item_price, c.person_id = reply->charges[d.seq].person_id,
     c.encntr_id = reply->charges[d.seq].encntr_id, c.interface_file_id = reply->charges[d.seq].
     interface_id, c.tier_group_cd = reply->charges[d.seq].tier_group_cd,
     c.def_bill_item_id = reply->charges[d.seq].def_bill_item_id, c.price_sched_id = reply->charges[d
     .seq].price_sched_id, c.payor_id = reply->charges[d.seq].payor_id,
     c.item_quantity = reply->charges[d.seq].item_quantity, c.item_extended_price = reply->charges[d
     .seq].item_extended_price, c.parent_charge_item_id = reply->charges[d.seq].parent_charge_item_id,
     c.charge_type_cd = reply->charges[d.seq].charge_type_cd, c.suspense_rsn_cd = reply->charges[d
     .seq].suspense_rsn_cd, c.reason_comment = substring(1,200,trim(reply->charges[d.seq].
       reason_comment)),
     c.posted_cd = reply->charges[d.seq].posted_cd, c.order_id = reply->charges[d.seq].order_id, c
     .process_flg = reply->charges[d.seq].process_flg,
     c.ord_loc_cd = reply->charges[d.seq].ord_loc_cd, c.perf_loc_cd = reply->charges[d.seq].
     perf_loc_cd, c.ord_phys_id = reply->charges[d.seq].ord_phys_id,
     c.verify_phys_id = reply->charges[d.seq].verify_phys_id, c.perf_phys_id = reply->charges[d.seq].
     perf_phys_id, c.activity_dt_tm = cnvtdatetime(sysdate),
     c.service_dt_tm = cnvtdatetime(reply->charges[d.seq].service_dt_tm), c.active_ind = 1, c
     .active_status_dt_tm = cnvtdatetime(sysdate),
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c.beg_effective_dt_tm
      = cnvtdatetime(sysdate),
     c.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"), c.manual_ind = reply->charges[d
     .seq].manual_ind, c.inst_fin_nbr = substring(1,50,trim(reply->charges[d.seq].inst_fin_nbr)),
     c.research_acct_id = reply->charges[d.seq].research_acct_id, c.admit_type_cd = reply->charges[d
     .seq].admit_type_cd, c.med_service_cd = reply->charges[d.seq].med_service_cd,
     c.institution_cd = reply->charges[d.seq].institution_cd, c.department_cd = reply->charges[d.seq]
     .department_cd, c.section_cd = reply->charges[d.seq].section_cd,
     c.subsection_cd = reply->charges[d.seq].subsection_cd, c.level5_cd = reply->charges[d.seq].
     level5_cd, c.cost_center_cd = reply->charges[d.seq].cost_center_cd,
     c.abn_status_cd = reply->charges[d.seq].abn_status_cd, c.activity_type_cd = reply->charges[d.seq
     ].activity_type_cd, c.activity_sub_type_cd = validate(reply->charges[d.seq].activity_sub_type_cd,
      0.0),
     c.fin_class_cd = reply->charges[d.seq].fin_class_cd, c.health_plan_id = reply->charges[d.seq].
     health_plan_id, c.credited_dt_tm =
     IF ((reply->charges[d.seq].charge_type_cd=g_cs13028->cr)) cnvtdatetime(sysdate)
     ELSE null
     ENDIF
     ,
     c.payor_type_cd = reply->charges[d.seq].payor_type_cd, c.item_copay = reply->charges[d.seq].
     item_copay, c.item_reimbursement = reply->charges[d.seq].item_reimbursement,
     c.posted_dt_tm =
     IF ((reply->charges[d.seq].posted_dt_tm <= 0)) c.posted_dt_tm
     ELSE cnvtdatetime(reply->charges[d.seq].posted_dt_tm)
     ENDIF
     , c.item_interval_id = reply->charges[d.seq].item_interval_id, c.item_list_price = reply->
     charges[d.seq].list_price,
     c.list_price_sched_id = reply->charges[d.seq].list_price_sched_id, c.epsdt_ind = reply->charges[
     d.seq].epsdt_ind, c.ref_phys_id = reply->charges[d.seq].ref_phys_id,
     c.alpha_nomen_id = reply->charges[d.seq].alpha_nomen_id, c.server_process_flag = reply->charges[
     d.seq].server_process_flag, c.offset_charge_item_id = reply->charges[d.seq].
     offset_charge_item_id,
     c.item_deductible_amt = reply->charges[d.seq].item_deductible_amt, c.patient_responsibility_flag
      = reply->charges[d.seq].patient_responsibility_flag, c.provider_specialty_cd = validate(reply->
      charges[d.seq].provider_specialty_cd,0.0),
     c.original_org_id = validate(reply->charges[d.seq].original_org_id,0.0)
    PLAN (d
     WHERE (reply->charges[d.seq].charge_item_id > 0))
     JOIN (c
     WHERE (c.charge_item_id=reply->charges[d.seq].charge_item_id))
    WITH nocounter
   ;end update
   CALL echo("Get new charge_item_id and charge_mod_id")
   SET insert_ind = 0
   FOR (charge_loop = 1 TO charge_cnt)
     DECLARE modifiercnt = i4 WITH noconstant(0)
     DECLARE num = i4 WITH noconstant(0)
     DECLARE priority = f8 WITH noconstant(0)
     DECLARE cnt = i4 WITH noconstant(0)
     DECLARE modcnt = i4 WITH noconstant(0)
     IF ((reply->charges[charge_loop].charge_item_id > 0))
      SET reply->charges[charge_loop].updt_ind = 1
     ELSE
      SET insert_ind = 1
      SET reply->charges[charge_loop].updt_ind = 0
      CALL getnextnumber("NULL")
      SET reply->charges[charge_loop].charge_item_id = next_nbr
     ENDIF
     SET mod_cnt = size(reply->charges[charge_loop].mods.charge_mods,5)
     SET stat = alterlist(modifiers->qual,mod_cnt)
     SET modifiercnt = 0
     FOR (mod_loop = 1 TO mod_cnt)
       CALL getnextnumber("NULL")
       SET reply->charges[charge_loop].mods.charge_mods[mod_loop].mod_id = next_nbr
       SET reply->charges[charge_loop].mods.charge_mods[mod_loop].charge_item_id = reply->charges[
       charge_loop].charge_item_id
       IF ((reply->charges[charge_loop].mods.charge_mods[mod_loop].nomen_id > 0))
        SET nomencnt += 1
        SET stat = alterlist(nomenstruct->nomen_entity_qual,nomencnt)
        SET nomenstruct->nomen_entity_qual[nomencnt].nomenclature_id = reply->charges[charge_loop].
        mods.charge_mods[mod_loop].nomen_id
        SET nomenstruct->nomen_entity_qual[nomencnt].parent_entity_name = "CHARGE"
        SET nomenstruct->nomen_entity_qual[nomencnt].parent_entity_id = reply->charges[charge_loop].
        mods.charge_mods[mod_loop].charge_item_id
        SET nomenstruct->nomen_entity_qual[nomencnt].child_entity_name = "NOMENCLATURE"
        SET nomenstruct->nomen_entity_qual[nomencnt].child_entity_id = reply->charges[charge_loop].
        mods.charge_mods[mod_loop].nomen_id
        SET nomenstruct->nomen_entity_qual[nomencnt].reltn_type_cd = chargecpt4
        SET nomenstruct->nomen_entity_qual[nomencnt].person_id = reply->charges[charge_loop].
        person_id
        SET nomenstruct->nomen_entity_qual[nomencnt].encntr_id = reply->charges[charge_loop].
        encntr_id
       ENDIF
       IF (uar_get_code_meaning(reply->charges[charge_loop].mods.charge_mods[mod_loop].field1_id)=
       "MODIFIER")
        SET modifiercnt += 1
        SET modifiers->qual[modifiercnt].field1_id = reply->charges[charge_loop].mods.charge_mods[
        mod_loop].field1_id
        SET modifiers->qual[modifiercnt].field2_id = reply->charges[charge_loop].mods.charge_mods[
        mod_loop].field2_id
        SET modifiers->qual[modifiercnt].field6 = reply->charges[charge_loop].mods.charge_mods[
        mod_loop].field6
        SET modifiers->qual[modifiercnt].field3_id = reply->charges[charge_loop].mods.charge_mods[
        mod_loop].field3_id
        SET modifiers->qual[modifiercnt].field_value = 0
        SET modifiers->qual[modifiercnt].charge_mod_source_cd = validate(reply->charges[charge_loop].
         mods.charge_mods[mod_loop].charge_mod_source_cd,0.0)
       ENDIF
     ENDFOR
     SET stat = alterlist(modifiers->qual,modifiercnt)
     SET stat = initrec(priorities)
     IF (size(modifiers->qual,5) > 0)
      SELECT INTO "nl:"
       FROM code_value_extension cve
       WHERE expand(num,1,size(modifiers->qual,5),cve.code_value,modifiers->qual[num].field3_id)
        AND cnvtupper(cve.field_name)="PRICE MODIFIER"
        AND cve.code_set=17769
       HEAD REPORT
        mod_idx = 0, modnum = 0
       DETAIL
        IF (cnvtint(trim(cve.field_value,7))=1)
         mod_idx = locateval(modnum,1,size(modifiers->qual,5),cve.code_value,modifiers->qual[modnum].
          field3_id), modifiers->qual[mod_idx].field_value = cnvtint(trim(cve.field_value,7))
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       orderbypriority = evaluate(modifiers->qual[d.seq].charge_mod_source_cd,
        cs4518006_manually_added,1,cs4518006_copyfromcem,evaluate2(
         IF ((modifiers->qual[d.seq].field_value=1)) 2
         ELSE 4
         ENDIF
         ),
        0.0,evaluate2(
         IF ((modifiers->qual[d.seq].field_value=1)) 2
         ELSE 4
         ENDIF
         ),cs4518006_ref_data,evaluate2(
         IF ((modifiers->qual[d.seq].field_value=1)) 3
         ELSE 5
         ENDIF
         ),6)
       FROM (dummyt d  WITH seq = value(size(modifiers->qual,5)))
       PLAN (d)
       ORDER BY orderbypriority, modifiers->qual[d.seq].field2_id
       HEAD REPORT
        priority = 0, manuallyaddedcnt = 0
       DETAIL
        IF (orderbypriority=1)
         manuallyaddedcnt += 1, stat = alterlist(priorities->qual,manuallyaddedcnt), priorities->
         qual[manuallyaddedcnt].modpriority = modifiers->qual[d.seq].field2_id
        ELSE
         priority += 1, pos = 1
         WHILE (pos != 0)
          pos = locateval(cnt,1,manuallyaddedcnt,priority,priorities->qual[cnt].modpriority),
          IF (pos > 0)
           priority += 1
          ENDIF
         ENDWHILE
         modpos = locateval(modcnt,1,size(reply->charges[charge_loop].mods.charge_mods,5),modifiers->
          qual[d.seq].field6,reply->charges[charge_loop].mods.charge_mods[modcnt].field6,
          modifiers->qual[d.seq].field1_id,reply->charges[charge_loop].mods.charge_mods[modcnt].
          field1_id,modifiers->qual[d.seq].field3_id,reply->charges[charge_loop].mods.charge_mods[
          modcnt].field3_id)
         IF (modpos > 0)
          reply->charges[charge_loop].mods.charge_mods[modpos].field2_id = priority
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   IF (insert_ind=1)
    CALL echo("Insert into charge table")
    INSERT  FROM charge c,
      (dummyt d  WITH seq = value(charge_cnt))
     SET c.charge_item_id = reply->charges[d.seq].charge_item_id, c.charge_event_id = reply->charges[
      d.seq].charge_event_id, c.charge_event_act_id = reply->charges[d.seq].charge_act_id,
      c.bill_item_id = reply->charges[d.seq].bill_item_id, c.charge_description = substring(1,200,
       trim(reply->charges[d.seq].charge_description)), c.gross_price = reply->charges[d.seq].
      gross_price,
      c.discount_amount = reply->charges[d.seq].discount_amount, c.item_price_adj_amt = validate(
       reply->charges[d.seq].item_price_adj_amt,0.0), c.item_price = reply->charges[d.seq].item_price,
      c.person_id = reply->charges[d.seq].person_id, c.encntr_id = reply->charges[d.seq].encntr_id, c
      .interface_file_id = reply->charges[d.seq].interface_id,
      c.tier_group_cd = reply->charges[d.seq].tier_group_cd, c.def_bill_item_id = reply->charges[d
      .seq].def_bill_item_id, c.price_sched_id = reply->charges[d.seq].price_sched_id,
      c.payor_id = reply->charges[d.seq].payor_id, c.item_quantity = reply->charges[d.seq].
      item_quantity, c.item_extended_price = reply->charges[d.seq].item_extended_price,
      c.parent_charge_item_id = reply->charges[d.seq].parent_charge_item_id, c.charge_type_cd = reply
      ->charges[d.seq].charge_type_cd, c.suspense_rsn_cd = reply->charges[d.seq].suspense_rsn_cd,
      c.reason_comment = substring(1,200,trim(reply->charges[d.seq].reason_comment)), c.posted_cd =
      reply->charges[d.seq].posted_cd, c.order_id = reply->charges[d.seq].order_id,
      c.process_flg = reply->charges[d.seq].process_flg, c.ord_loc_cd = reply->charges[d.seq].
      ord_loc_cd, c.perf_loc_cd = reply->charges[d.seq].perf_loc_cd,
      c.ord_phys_id = reply->charges[d.seq].ord_phys_id, c.verify_phys_id = reply->charges[d.seq].
      verify_phys_id, c.perf_phys_id = reply->charges[d.seq].perf_phys_id,
      c.activity_dt_tm = cnvtdatetime(sysdate), c.service_dt_tm = cnvtdatetime(reply->charges[d.seq].
       service_dt_tm), c.active_ind = 1,
      c.active_status_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(
       sysdate),
      c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
      updt_task,
      c.beg_effective_dt_tm = cnvtdatetime(sysdate), c.end_effective_dt_tm = cnvtdatetime(
       "31-Dec-2100 00:00:00.00"), c.manual_ind = reply->charges[d.seq].manual_ind,
      c.inst_fin_nbr = substring(1,50,trim(reply->charges[d.seq].inst_fin_nbr)), c.research_acct_id
       = reply->charges[d.seq].research_acct_id, c.admit_type_cd = reply->charges[d.seq].
      admit_type_cd,
      c.med_service_cd = reply->charges[d.seq].med_service_cd, c.institution_cd = reply->charges[d
      .seq].institution_cd, c.department_cd = reply->charges[d.seq].department_cd,
      c.section_cd = reply->charges[d.seq].section_cd, c.subsection_cd = reply->charges[d.seq].
      subsection_cd, c.level5_cd = reply->charges[d.seq].level5_cd,
      c.cost_center_cd = reply->charges[d.seq].cost_center_cd, c.abn_status_cd = reply->charges[d.seq
      ].abn_status_cd, c.activity_type_cd = reply->charges[d.seq].activity_type_cd,
      c.activity_sub_type_cd = validate(reply->charges[d.seq].activity_sub_type_cd,0.0), c
      .fin_class_cd = reply->charges[d.seq].fin_class_cd, c.health_plan_id = reply->charges[d.seq].
      health_plan_id,
      c.credited_dt_tm =
      IF ((reply->charges[d.seq].charge_type_cd=g_cs13028->cr)) cnvtdatetime(sysdate)
      ELSE null
      ENDIF
      , c.payor_type_cd = reply->charges[d.seq].payor_type_cd, c.item_copay = reply->charges[d.seq].
      item_copay,
      c.item_reimbursement = reply->charges[d.seq].item_reimbursement, c.posted_dt_tm =
      IF ((reply->charges[d.seq].posted_dt_tm <= 0)) null
      ELSE cnvtdatetime(reply->charges[d.seq].posted_dt_tm)
      ENDIF
      , c.item_interval_id = reply->charges[d.seq].item_interval_id,
      c.item_list_price = reply->charges[d.seq].list_price, c.list_price_sched_id = reply->charges[d
      .seq].list_price_sched_id, c.epsdt_ind = reply->charges[d.seq].epsdt_ind,
      c.ref_phys_id = reply->charges[d.seq].ref_phys_id, c.alpha_nomen_id = reply->charges[d.seq].
      alpha_nomen_id, c.server_process_flag = reply->charges[d.seq].server_process_flag,
      c.offset_charge_item_id = reply->charges[d.seq].offset_charge_item_id, c.item_deductible_amt =
      reply->charges[d.seq].item_deductible_amt, c.patient_responsibility_flag = reply->charges[d.seq
      ].patient_responsibility_flag,
      c.posted_id = reqinfo->updt_id, c.provider_specialty_cd = validate(reply->charges[d.seq].
       provider_specialty_cd,0.0), c.original_org_id = validate(reply->charges[d.seq].original_org_id,
       0.0),
      c.original_encntr_id =
      IF (validate(reply->charges[d.seq].parent_charge_item_id,0)=0) reply->charges[d.seq].encntr_id
      ELSE
       (SELECT
        c.original_encntr_id
        FROM charge c
        WHERE (c.charge_item_id=reply->charges[d.seq].parent_charge_item_id))
      ENDIF
     PLAN (d
      WHERE (reply->charges[d.seq].updt_ind=0))
      JOIN (c)
     WITH nocounter
    ;end insert
    FOR (charge_loop = 1 TO charge_cnt)
      IF ((reply->charges[charge_loop].updt_ind=0)
       AND validate(reply->charges[charge_loop].provider_specialty_cd,0.0) > 0.0)
       CALL logsolutioncapability(team_name,provider_specialty_capability_id,reply->charges[
        charge_loop].charge_item_id,entity_name)
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("Insert into charge_mod table")
   FOR (charge_loop = 1 TO charge_cnt)
    SET mod_cnt = size(reply->charges[charge_loop].mods.charge_mods,5)
    IF (mod_cnt > 0)
     FOR (mod_loop = 1 TO mod_cnt)
       SET billcodecnt += 1
       SET stat = alterlist(chargemodreq->objarray,billcodecnt)
       SET chargemodreq->objarray[billcodecnt].action_type = "ADD"
       SET chargemodreq->objarray[billcodecnt].charge_mod_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].mod_id
       SET chargemodreq->objarray[billcodecnt].charge_item_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].charge_item_id
       SET chargemodreq->objarray[billcodecnt].charge_mod_type_cd = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].charge_event_mod_type_cd
       SET chargemodreq->objarray[billcodecnt].field1 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field1))
       SET chargemodreq->objarray[billcodecnt].field2 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field2))
       IF (validate(reply->charges[charge_loop].mods.charge_mods[mod_loop].field3_ext,"") != ""
        AND (reply->charges[charge_loop].mods.charge_mods[mod_loop].charge_event_mod_type_cd=
       cs13019_noncovered_cd))
        SET chargemodreq->objarray[billcodecnt].field3 = substring(1,350,trim(validate(reply->
           charges[charge_loop].mods.charge_mods[mod_loop].field3_ext,"")))
       ELSE
        SET chargemodreq->objarray[billcodecnt].field3 = substring(1,200,trim(reply->charges[
          charge_loop].mods.charge_mods[mod_loop].field3))
       ENDIF
       SET chargemodreq->objarray[billcodecnt].field4 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field4))
       SET chargemodreq->objarray[billcodecnt].field5 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field5))
       SET chargemodreq->objarray[billcodecnt].field6 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field6))
       SET chargemodreq->objarray[billcodecnt].field7 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field7))
       SET chargemodreq->objarray[billcodecnt].field8 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field8))
       SET chargemodreq->objarray[billcodecnt].field9 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field9))
       SET chargemodreq->objarray[billcodecnt].field10 = substring(1,200,trim(reply->charges[
         charge_loop].mods.charge_mods[mod_loop].field10))
       SET chargemodreq->objarray[billcodecnt].updt_cnt = 0
       SET chargemodreq->objarray[billcodecnt].active_ind = 1
       SET chargemodreq->objarray[billcodecnt].beg_effective_dt_tm = cnvtdatetime(sysdate)
       SET chargemodreq->objarray[billcodecnt].end_effective_dt_tm = cnvtdatetime(
        "31-Dec-2100 00:00:00.00")
       SET chargemodreq->objarray[billcodecnt].active_status_dt_tm = cnvtdatetime(sysdate)
       IF (validate(reply->charges[charge_loop].mods.charge_mods[mod_loop].code1_cd) != 0)
        SET chargemodreq->objarray[billcodecnt].code1_cd = validate(reply->charges[charge_loop].mods.
         charge_mods[mod_loop].code1_cd,- (0.00001))
       ELSE
        SET chargemodreq->objarray[billcodecnt].code1_cd = 0.0
       ENDIF
       SET chargemodreq->objarray[billcodecnt].nomen_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].nomen_id
       SET chargemodreq->objarray[billcodecnt].field1_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].field1_id
       SET chargemodreq->objarray[billcodecnt].field2_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].field2_id
       SET chargemodreq->objarray[billcodecnt].field3_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].field3_id
       SET chargemodreq->objarray[billcodecnt].field4_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].field4_id
       SET chargemodreq->objarray[billcodecnt].field5_id = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].field5_id
       SET chargemodreq->objarray[billcodecnt].cm1_nbr = reply->charges[charge_loop].mods.
       charge_mods[mod_loop].cm1_nbr
       IF (validate(reply->charges[charge_loop].mods.charge_mods[mod_loop].activity_dt_tm) != 0)
        SET chargemodreq->objarray[billcodecnt].activity_dt_tm = cnvtdatetime(validate(reply->
          charges[charge_loop].mods.charge_mods[mod_loop].activity_dt_tm,0.0))
       ELSE
        SET chargemodreq->objarray[billcodecnt].activity_dt_tm = null
       ENDIF
       IF (validate(reply->charges[charge_loop].mods.charge_mods[mod_loop].charge_mod_source_cd))
        SET chargemodreq->objarray[billcodecnt].charge_mod_source_cd = reply->charges[charge_loop].
        mods.charge_mods[mod_loop].charge_mod_source_cd
       ELSE
        SET chargemodreq->objarray[billcodecnt].charge_mod_source_cd = 0.0
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   IF (size(chargemodreq->objarray,5) <= 0)
    CALL echo("No charge_mods to add")
   ELSE
    EXECUTE afc_val_charge_mod  WITH replace("REQUEST",chargemodreq), replace("REPLY",chargemodreply)
    IF ((chargemodreply->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(chargemodreq)
      CALL echorecord(chargemodreply)
     ENDIF
    ENDIF
   ENDIF
   CALL echo("Check for realtime charges")
   SELECT INTO "nl:"
    i.realtime_ind
    FROM interface_file i,
     (dummyt d  WITH seq = value(charge_cnt))
    PLAN (d
     WHERE (reply->charges[d.seq].process_flg=0))
     JOIN (i
     WHERE (i.interface_file_id=reply->charges[d.seq].interface_id)
      AND i.realtime_ind=1)
    DETAIL
     reply->charges[d.seq].realtime_ind = 1
    WITH nocounter
   ;end select
   CALL echo("Update bill_item_id on charge_event table")
   UPDATE  FROM charge_event c,
     (dummyt d  WITH seq = value(charge_cnt))
    SET c.bill_item_id = reply->charges[d.seq].bill_item_id
    PLAN (d
     WHERE (reply->charges[d.seq].parent_charge_item_id=0))
     JOIN (c
     WHERE (c.charge_event_id=reply->charges[d.seq].charge_event_id))
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE updatechargeeventactprsnl(dummyvar)
   DECLARE eventcnt = i4 WITH noconstant(0)
   DECLARE chargecnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->charges,5))),
     charge c,
     interface_file i
    PLAN (d
     WHERE (reply->charges[d.seq].ord_phys_id > 0)
      AND (reply->charges[d.seq].verify_phys_id=0.0))
     JOIN (c
     WHERE (c.charge_item_id=reply->charges[d.seq].charge_item_id)
      AND c.active_ind=true)
     JOIN (i
     WHERE i.interface_file_id=c.interface_file_id
      AND i.order_phys_copy_ind=1
      AND i.active_ind=true)
    HEAD c.charge_event_act_id
     eventcnt += 1, stat = alterlist(chargeeventacts->chargeeventact,eventcnt), chargeeventacts->
     chargeeventact[eventcnt].charge_event_act_id = c.charge_event_act_id,
     chargeeventacts->chargeeventact[eventcnt].prsnl_id = c.ord_phys_id
    DETAIL
     chargecnt += 1, stat = alterlist(physcharges->charges,chargecnt), physcharges->charges[chargecnt
     ].charge_item_id = c.charge_item_id,
     physcharges->charges[chargecnt].ord_phys_id = c.ord_phys_id
    WITH nocounter
   ;end select
   IF (size(chargeeventacts->chargeeventact,5) > 0)
    INSERT  FROM charge_event_act_prsnl cea,
      (dummyt d  WITH seq = value(size(chargeeventacts->chargeeventact,5)))
     SET cea.seq = 1, cea.charge_event_act_id = chargeeventacts->chargeeventact[d.seq].
      charge_event_act_id, cea.prsnl_id = chargeeventacts->chargeeventact[d.seq].prsnl_id,
      cea.prsnl_type_cd = cs13029_verified_cd, cea.updt_applctx = reqinfo->updt_applctx, cea.updt_cnt
       = 0,
      cea.updt_dt_tm = cnvtdatetime(sysdate), cea.updt_id = reqinfo->updt_id, cea.updt_task = reqinfo
      ->updt_task,
      cea.active_ind = 1
     PLAN (d)
      JOIN (cea)
     WITH nocounter
    ;end insert
    UPDATE  FROM charge c,
      (dummyt d  WITH seq = value(size(physcharges->charges,5)))
     SET c.verify_phys_id = physcharges->charges[d.seq].ord_phys_id, c.updt_applctx = reqinfo->
      updt_applctx, c.updt_cnt = (c.updt_cnt+ 1),
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task
     PLAN (d)
      JOIN (c
      WHERE (c.charge_item_id=physcharges->charges[d.seq].charge_item_id))
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE updatecharges(e)
  UPDATE  FROM charge c,
    (dummyt d  WITH seq = value(charge_cnt))
   SET c.offset_charge_item_id = reply->charges[d.seq].charge_item_id
   PLAN (d
    WHERE (reply->charges[d.seq].offset_charge_item_id > 0))
    JOIN (c
    WHERE (c.charge_item_id=reply->charges[d.seq].offset_charge_item_id))
   WITH nocounter
  ;end update
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(charge_cnt)),
    (dummyt d2  WITH seq = value(charge_cnt))
   PLAN (d1
    WHERE (reply->charges[d1.seq].offset_charge_item_id=0))
    JOIN (d2
    WHERE (reply->charges[d2.seq].offset_charge_item_id=reply->charges[d1.seq].charge_item_id))
   DETAIL
    reply->charges[d1.seq].offset_charge_item_id = reply->charges[d2.seq].charge_item_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE adddiagnosiscodes(c)
   DECLARE diag_loop = i2
   RECORD cemrequest(
     1 objarray[*]
       2 action_type = c3
       2 charge_event_mod_id = f8
       2 charge_event_id = f8
       2 charge_event_mod_type_cd = f8
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
   RECORD cemreply(
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
   SET stat = alterlist(cemrequest->objarray,diag_cnt)
   FOR (diag_loop = 1 TO diag_cnt)
     CALL getnextnumber("NULL")
     SET reply->srv_diag[diag_loop].charge_event_mod_id = next_nbr
     SET cemrequest->objarray[diag_loop].action_type = "ADD"
     SET cemrequest->objarray[diag_loop].charge_event_mod_id = reply->srv_diag[diag_loop].
     charge_event_mod_id
     SET cemrequest->objarray[diag_loop].charge_event_mod_type_cd = g_cs13019->srv_diag
     SET cemrequest->objarray[diag_loop].charge_event_id = reply->srv_diag[diag_loop].charge_event_id
     SET cemrequest->objarray[diag_loop].field1_id = reply->srv_diag[diag_loop].charge_event_act_id
     SET cemrequest->objarray[diag_loop].field2_id = reply->srv_diag[diag_loop].srv_diag_cd
     SET cemrequest->objarray[diag_loop].field3_id = reply->srv_diag[diag_loop].srv_diag1_id
     SET cemrequest->objarray[diag_loop].field4_id = reply->srv_diag[diag_loop].srv_diag2_id
     SET cemrequest->objarray[diag_loop].field5_id = reply->srv_diag[diag_loop].srv_diag3_id
     SET cemrequest->objarray[diag_loop].field6 = substring(1,200,trim(reply->srv_diag[diag_loop].
       srv_diag_reason))
     SET cemrequest->objarray[diag_loop].field7 = cnvtstring(reply->srv_diag[diag_loop].srv_diag_tier
      )
     SET cemrequest->objarray[diag_loop].active_ind = 1
     SET cemrequest->objarray[diag_loop].active_status_dt_tm = cnvtdatetime(sysdate)
     SET cemrequest->objarray[diag_loop].beg_effective_dt_tm = cnvtdatetime(sysdate)
   ENDFOR
   CALL echo("Insert diagnosis codes into charge_event_mod table")
   IF (size(cemrequest->objarray,5) <= 0)
    IF (validate(debug,- (1)) > 0)
     CALL echo("No charge_event_mods to add")
    ENDIF
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",cemreply)
    IF ((cemreply->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cemrequest)
      CALL echorecord(cemreply)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
 SET charge_cnt = size(reply->charges,5)
 IF (charge_cnt > 0)
  CALL chargeoriginalorgid("NULL")
  CALL addcharges("NULL")
  CALL updatechargeeventactprsnl(0)
  CALL updatecharges("NULL")
 ENDIF
 SET diag_cnt = size(reply->srv_diag,5)
 IF (diag_cnt > 0)
  CALL adddiagnosiscodes("NULL")
 ENDIF
 IF (nomencnt > 0)
  EXECUTE dcp_add_nomen_entity_reltn  WITH replace("REQUEST",nomenstruct), replace("REPLY",
   nomenstructreply)
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
