CREATE PROGRAM afc_ct_adjust_charge:dba
 DECLARE afc_ct_adjust_charge_version = vc WITH private, noconstant("CHARGSRV-15575.ft.009")
 IF (validate(reply->new_charge_item_id)=0)
  RECORD reply(
    1 new_charge_item_id = f8
    1 charge_mod_qual = i2
    1 charge_mods[*]
      2 charge_mod_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temprequest
 RECORD temprequest(
   1 charge_item_id = f8
   1 parent_charge_item_id = f8
   1 charge_event_act_id = f8
   1 charge_event_id = f8
   1 charge_description = vc
   1 bill_item_id = f8
   1 order_id = f8
   1 encntr_id = f8
   1 person_id = f8
   1 payor_id = f8
   1 ord_loc_cd = f8
   1 perf_loc_cd = f8
   1 ord_phys_id = f8
   1 perf_phys_id = f8
   1 price_sched_id = f8
   1 item_allowable = f8
   1 item_copay = f8
   1 item_price = f8
   1 item_extended_price = f8
   1 item_quantity = f8
   1 charge_type_cd = f8
   1 research_acct_id = f8
   1 suspense_rsn_cd = f8
   1 reason_comment = vc
   1 posted_cd = f8
   1 posted_dt_tm = dq8
   1 process_flg = i4
   1 service_dt_tm = dq8
   1 activity_dt_tm = dq8
   1 active_ind = i2
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 credited_dt_tm = dq8
   1 interface_file_id = f8
   1 tier_group_cd = f8
   1 def_bill_item_id = f8
   1 verify_phys_id = f8
   1 gross_price = f8
   1 discount_amount = f8
   1 manual_ind = i2
   1 combine_ind = i2
   1 bundle_id = f8
   1 institution_cd = f8
   1 department_cd = f8
   1 section_cd = f8
   1 subsection_cd = f8
   1 level5_cd = f8
   1 admit_type_cd = f8
   1 med_service_cd = f8
   1 activity_type_cd = f8
   1 inst_fin_nbr = vc
   1 cost_center_cd = f8
   1 abn_status_cd = f8
   1 health_plan_id = f8
   1 fin_class_cd = f8
   1 server_process_flag = i2
   1 activity_sub_type_cd = f8
   1 provider_specialty_cd = f8
   1 original_org_id = f8
   1 item_price_adj_amt = f8
 )
 FREE SET bill_code
 RECORD bill_code(
   1 bill_code_qual = i2
   1 bill_code[*]
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 activity_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 charge_item_id = f8
     2 charge_mod_id = f8
     2 charge_mod_type_cd = f8
     2 code1_cd = f8
     2 end_effective_dt_tm = dq8
     2 field1 = vc
     2 field10 = vc
     2 field1_id = f8
     2 field2 = vc
     2 field2_id = f8
     2 field3 = vc
     2 field3_id = f8
     2 field4 = vc
     2 field4_id = f8
     2 field5 = vc
     2 field5_id = f8
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 nomen_id = f8
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
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
 SET failed = false
 SET reply->status_data.status = "F"
 IF ( NOT (validate(table_name)))
  DECLARE table_name = vc WITH public, noconstant("CHARGE")
 ELSE
  SET table_name = "CHARGE"
 ENDIF
 DECLARE cid_new_nbr = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM charge c
  WHERE (c.charge_item_id=request->charge_item_id)
  DETAIL
   temprequest->parent_charge_item_id = c.parent_charge_item_id, temprequest->charge_event_act_id = c
   .charge_event_act_id, temprequest->charge_event_id = c.charge_event_id,
   temprequest->charge_description = c.charge_description, temprequest->bill_item_id = c.bill_item_id,
   temprequest->order_id = c.order_id,
   temprequest->encntr_id = c.encntr_id, temprequest->person_id = c.person_id, temprequest->payor_id
    = c.payor_id,
   temprequest->ord_loc_cd = c.ord_loc_cd, temprequest->perf_loc_cd = c.perf_loc_cd, temprequest->
   ord_phys_id = c.ord_phys_id,
   temprequest->perf_phys_id = c.perf_phys_id, temprequest->price_sched_id = c.price_sched_id,
   temprequest->item_allowable = c.item_allowable,
   temprequest->item_copay = c.item_copay, temprequest->item_price = c.item_price, temprequest->
   item_extended_price = c.item_extended_price,
   temprequest->item_quantity = c.item_quantity, temprequest->charge_type_cd = c.charge_type_cd,
   temprequest->research_acct_id = c.research_acct_id,
   temprequest->suspense_rsn_cd = c.suspense_rsn_cd, temprequest->reason_comment = c.reason_comment,
   temprequest->posted_cd = c.posted_cd,
   temprequest->posted_dt_tm = c.posted_dt_tm, temprequest->service_dt_tm = c.service_dt_tm,
   temprequest->activity_dt_tm = c.activity_dt_tm,
   temprequest->active_ind = c.active_ind, temprequest->active_status_cd = c.active_status_cd,
   temprequest->active_status_dt_tm = c.active_status_dt_tm,
   temprequest->active_status_prsnl_id = c.active_status_prsnl_id, temprequest->beg_effective_dt_tm
    = c.beg_effective_dt_tm, temprequest->end_effective_dt_tm = c.end_effective_dt_tm,
   temprequest->credited_dt_tm = c.credited_dt_tm, temprequest->interface_file_id = c
   .interface_file_id, temprequest->tier_group_cd = c.tier_group_cd,
   temprequest->def_bill_item_id = c.def_bill_item_id, temprequest->verify_phys_id = c.verify_phys_id,
   temprequest->gross_price = c.gross_price,
   temprequest->discount_amount = c.discount_amount, temprequest->item_price_adj_amt = c
   .item_price_adj_amt, temprequest->manual_ind = c.manual_ind,
   temprequest->combine_ind = c.combine_ind, temprequest->bundle_id = c.bundle_id, temprequest->
   institution_cd = c.institution_cd,
   temprequest->department_cd = c.department_cd, temprequest->section_cd = c.section_cd, temprequest
   ->subsection_cd = c.subsection_cd,
   temprequest->level5_cd = c.level5_cd, temprequest->admit_type_cd = c.admit_type_cd, temprequest->
   med_service_cd = c.med_service_cd,
   temprequest->activity_type_cd = c.activity_type_cd, temprequest->activity_sub_type_cd = c
   .activity_sub_type_cd, temprequest->provider_specialty_cd = c.provider_specialty_cd,
   temprequest->inst_fin_nbr = c.inst_fin_nbr, temprequest->cost_center_cd = c.cost_center_cd,
   temprequest->abn_status_cd = c.abn_status_cd,
   temprequest->health_plan_id = c.health_plan_id, temprequest->fin_class_cd = c.fin_class_cd,
   temprequest->process_flg = c.process_flg,
   temprequest->server_process_flag = c.server_process_flag, temprequest->original_org_id = c
   .original_org_id
  WITH nocounter
 ;end select
 IF (validate(debug,- (1)) > 0)
  CALL echo(temprequest->process_flg)
 ENDIF
 SET count1 = 0
 SELECT INTO "nl:"
  FROM charge_mod cm
  WHERE (cm.charge_item_id=request->charge_item_id)
   AND cm.active_ind=1
  DETAIL
   count1 += 1, stat = alterlist(bill_code->bill_code,count1), bill_code->bill_code[count1].
   active_ind = cm.active_ind,
   bill_code->bill_code[count1].active_status_cd = cm.active_status_cd, bill_code->bill_code[count1].
   active_status_dt_tm = cm.active_status_dt_tm, bill_code->bill_code[count1].active_status_prsnl_id
    = cm.active_status_prsnl_id,
   bill_code->bill_code[count1].activity_dt_tm = cm.activity_dt_tm, bill_code->bill_code[count1].
   beg_effective_dt_tm = cm.beg_effective_dt_tm, bill_code->bill_code[count1].charge_mod_type_cd = cm
   .charge_mod_type_cd,
   bill_code->bill_code[count1].code1_cd = cm.code1_cd, bill_code->bill_code[count1].
   end_effective_dt_tm = cm.end_effective_dt_tm, bill_code->bill_code[count1].field1 = cm.field1,
   bill_code->bill_code[count1].field10 = cm.field10, bill_code->bill_code[count1].field1_id = cm
   .field1_id, bill_code->bill_code[count1].field2 = cm.field2,
   bill_code->bill_code[count1].field2_id = cm.field2_id, bill_code->bill_code[count1].field3 = cm
   .field3, bill_code->bill_code[count1].field3_id = cm.field3_id,
   bill_code->bill_code[count1].field4 = cm.field4, bill_code->bill_code[count1].field4_id = cm
   .field4_id, bill_code->bill_code[count1].field5 = cm.field5,
   bill_code->bill_code[count1].field5_id = cm.field5_id, bill_code->bill_code[count1].field6 = cm
   .field6, bill_code->bill_code[count1].field7 = cm.field7,
   bill_code->bill_code[count1].field8 = cm.field8, bill_code->bill_code[count1].field9 = cm.field9,
   bill_code->bill_code[count1].nomen_id = cm.nomen_id,
   bill_code->bill_code[count1].updt_applctx = cm.updt_applctx, bill_code->bill_code[count1].updt_cnt
    = cm.updt_cnt, bill_code->bill_code[count1].updt_dt_tm = cm.updt_dt_tm,
   bill_code->bill_code[count1].updt_id = cm.updt_id, bill_code->bill_code[count1].updt_task = cm
   .updt_task, bill_code->bill_code_qual = count1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  temp_var = seq(charge_event_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   cid_new_nbr = cnvtreal(temp_var)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET failed = gen_nbr_error
  RETURN
 ENDIF
 INSERT  FROM charge c
  SET c.charge_item_id = cid_new_nbr, c.parent_charge_item_id = temprequest->parent_charge_item_id, c
   .charge_event_act_id = temprequest->charge_event_act_id,
   c.charge_event_id = temprequest->charge_event_id, c.bill_item_id = temprequest->bill_item_id, c
   .order_id = temprequest->order_id,
   c.encntr_id = temprequest->encntr_id, c.person_id = temprequest->person_id, c.payor_id =
   temprequest->payor_id,
   c.ord_loc_cd = temprequest->ord_loc_cd, c.perf_loc_cd = temprequest->perf_loc_cd, c.ord_phys_id =
   temprequest->ord_phys_id,
   c.perf_phys_id = temprequest->perf_phys_id, c.charge_description = temprequest->charge_description,
   c.price_sched_id = temprequest->price_sched_id,
   c.item_quantity =
   IF ((request->item_quantity=0)) temprequest->item_quantity
   ELSE request->item_quantity
   ENDIF
   , c.item_price =
   IF ((request->item_price=0)) temprequest->item_price
   ELSE request->item_price
   ENDIF
   , c.item_extended_price =
   IF ((request->item_extended_price=0))
    IF ((request->item_quantity=0))
     IF ((request->item_price=0)) (temprequest->item_price * temprequest->item_quantity)
     ELSE (temprequest->item_quantity * request->item_price)
     ENDIF
    ELSE
     IF ((request->item_price=0)) (temprequest->item_price * request->item_quantity)
     ELSE (request->item_price * request->item_quantity)
     ENDIF
    ENDIF
   ELSE request->item_extended_price
   ENDIF
   ,
   c.item_allowable = temprequest->item_allowable, c.item_copay = temprequest->item_copay, c
   .charge_type_cd = temprequest->charge_type_cd,
   c.research_acct_id = temprequest->research_acct_id, c.suspense_rsn_cd = temprequest->
   suspense_rsn_cd, c.reason_comment = temprequest->reason_comment,
   c.posted_cd = temprequest->posted_cd, c.posted_dt_tm = cnvtdatetime(temprequest->posted_dt_tm), c
   .process_flg =
   IF ((temprequest->process_flg=2)) 2
   ELSE 0
   ENDIF
   ,
   c.service_dt_tm = cnvtdatetime(temprequest->service_dt_tm), c.activity_dt_tm = cnvtdatetime(
    temprequest->activity_dt_tm), c.beg_effective_dt_tm = cnvtdatetime(temprequest->
    beg_effective_dt_tm),
   c.end_effective_dt_tm = cnvtdatetime(temprequest->end_effective_dt_tm), c.active_ind = temprequest
   ->active_ind, c.active_status_cd = temprequest->active_status_cd,
   c.active_status_prsnl_id = reqinfo->updt_id, c.active_status_dt_tm = cnvtdatetime(sysdate), c
   .credited_dt_tm = cnvtdatetime(temprequest->credited_dt_tm),
   c.interface_file_id = temprequest->interface_file_id, c.tier_group_cd = temprequest->tier_group_cd,
   c.def_bill_item_id = temprequest->def_bill_item_id,
   c.verify_phys_id = temprequest->verify_phys_id, c.gross_price = temprequest->gross_price, c
   .discount_amount = (temprequest->gross_price - request->item_price),
   c.item_price_adj_amt = temprequest->item_price_adj_amt, c.manual_ind = temprequest->manual_ind, c
   .combine_ind = temprequest->combine_ind,
   c.bundle_id = temprequest->bundle_id, c.institution_cd = temprequest->institution_cd, c
   .department_cd = temprequest->department_cd,
   c.section_cd = temprequest->section_cd, c.subsection_cd = temprequest->subsection_cd, c.level5_cd
    = temprequest->level5_cd,
   c.admit_type_cd = temprequest->admit_type_cd, c.med_service_cd = temprequest->med_service_cd, c
   .activity_type_cd = temprequest->activity_type_cd,
   c.activity_sub_type_cd = temprequest->activity_sub_type_cd, c.provider_specialty_cd = temprequest
   ->provider_specialty_cd, c.inst_fin_nbr = temprequest->inst_fin_nbr,
   c.cost_center_cd = temprequest->cost_center_cd, c.abn_status_cd = temprequest->abn_status_cd, c
   .health_plan_id = temprequest->health_plan_id,
   c.fin_class_cd = temprequest->fin_class_cd, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
   updt_task,
   c.posted_id = reqinfo->updt_id, c.server_process_flag = temprequest->server_process_flag, c
   .original_org_id = temprequest->original_org_id,
   c.original_encntr_id =
   IF (validate(temprequest->parent_charge_item_id,0)=0) temprequest->encntr_id
   ELSE
    (SELECT
     c.original_encntr_id
     FROM charge c
     WHERE (c.charge_item_id=temprequest->parent_charge_item_id))
   ENDIF
  WITH nocounter
 ;end insert
 DECLARE cmcnt = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(1)
 FOR (x = 1 TO size(bill_code->bill_code,5))
   SET cmcnt += 1
   SET stat = alterlist(cmreq->objarray,cmcnt)
   SET cmreq->objarray[cmcnt].action_type = "ADD"
   SET cmreq->objarray[cmcnt].charge_mod_id = seq(charge_event_seq,nextval)
   SET cmreq->objarray[cmcnt].charge_item_id = cid_new_nbr
   SET cmreq->objarray[cmcnt].charge_mod_type_cd = bill_code->bill_code[x].charge_mod_type_cd
   SET cmreq->objarray[cmcnt].field1 = bill_code->bill_code[x].field1
   SET cmreq->objarray[cmcnt].field2 = bill_code->bill_code[x].field2
   SET cmreq->objarray[cmcnt].field3 = bill_code->bill_code[x].field3
   SET cmreq->objarray[cmcnt].field4 = bill_code->bill_code[x].field4
   SET cmreq->objarray[cmcnt].field5 = bill_code->bill_code[x].field5
   SET cmreq->objarray[cmcnt].field6 = bill_code->bill_code[x].field6
   SET cmreq->objarray[cmcnt].field7 = bill_code->bill_code[x].field7
   SET cmreq->objarray[cmcnt].field8 = bill_code->bill_code[x].field8
   SET cmreq->objarray[cmcnt].field9 = bill_code->bill_code[x].field9
   SET cmreq->objarray[cmcnt].field10 = bill_code->bill_code[x].field10
   SET cmreq->objarray[cmcnt].activity_dt_tm = cnvtdatetime(bill_code->bill_code[x].activity_dt_tm)
   SET cmreq->objarray[cmcnt].updt_cnt = 0
   SET cmreq->objarray[cmcnt].active_ind = bill_code->bill_code[x].active_ind
   SET cmreq->objarray[cmcnt].active_status_cd = bill_code->bill_code[x].active_status_cd
   SET cmreq->objarray[cmcnt].active_status_dt_tm = cnvtdatetime(bill_code->bill_code[x].
    active_status_dt_tm)
   SET cmreq->objarray[cmcnt].active_status_prsnl_id = bill_code->bill_code[x].active_status_prsnl_id
   SET cmreq->objarray[cmcnt].beg_effective_dt_tm = cnvtdatetime(bill_code->bill_code[x].
    beg_effective_dt_tm)
   SET cmreq->objarray[cmcnt].end_effective_dt_tm = cnvtdatetime(bill_code->bill_code[x].
    end_effective_dt_tm)
   SET cmreq->objarray[cmcnt].code1_cd = bill_code->bill_code[x].code1_cd
   SET cmreq->objarray[cmcnt].nomen_id = bill_code->bill_code[x].nomen_id
   SET cmreq->objarray[cmcnt].field1_id = bill_code->bill_code[x].field1_id
   SET cmreq->objarray[cmcnt].field2_id = bill_code->bill_code[x].field2_id
   SET cmreq->objarray[cmcnt].field3_id = bill_code->bill_code[x].field3_id
   SET cmreq->objarray[cmcnt].field4_id = bill_code->bill_code[x].field4_id
   SET cmreq->objarray[cmcnt].field5_id = bill_code->bill_code[x].field5_id
 ENDFOR
 IF (size(cmreq->objarray,5) <= 0)
  CALL echo("No charge_mods to add")
 ELSE
  EXECUTE afc_val_charge_mod  WITH replace("REQUEST",cmreq), replace("REPLY",cmrep)
  IF ((cmrep->status_data.status != "S"))
   CALL logmessage(curprog,"afc_val_charge_mod did not return success",log_debug)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(cmreq)
    CALL echorecord(cmrep)
   ENDIF
   SET failed = insert_error
   RETURN
  ENDIF
 ENDIF
 IF (failed != false)
  GO TO check_error
 ELSE
  SET reply->new_charge_item_id = cid_new_nbr
  SET count1 = 0
  SELECT INTO "nl:"
   FROM charge_mod cm
   WHERE cm.charge_item_id=cid_new_nbr
   DETAIL
    count1 += 1, stat = alterlist(reply->charge_mods,count1), reply->charge_mods[count1].
    charge_mod_id = cm.charge_mod_id,
    reply->charge_mod_qual = count1
   WITH nocounter
  ;end select
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
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
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
#end_program
END GO
