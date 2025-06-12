CREATE PROGRAM afc_srv_upt_charge:dba
 RECORD reply(
   1 charge_item_id = f8
   1 realtime_ind = i2
 )
 SET reply->charge_item_id = request->charge_item_id
 UPDATE  FROM charge c
  SET c.charge_event_id = request->charge_event_id, c.charge_event_act_id = request->charge_act_id, c
   .bill_item_id = request->bill_item_id,
   c.charge_description = substring(1,200,trim(request->charge_description)), c.gross_price = request
   ->gross_price, c.discount_amount = request->discount_amount,
   c.item_price = request->item_price, c.person_id = request->person_id, c.encntr_id = request->
   encntr_id,
   c.price_sched_id = request->price_sched_id, c.payor_id = request->payor_id, c.item_quantity =
   request->item_quantity,
   c.item_extended_price = request->item_extended_price, c.parent_charge_item_id = request->
   parent_charge_item_id, c.charge_type_cd = request->charge_type_cd,
   c.suspense_rsn_cd = request->suspense_rsn_cd, c.reason_comment = substring(1,200,trim(request->
     reason_comment)), c.posted_cd = request->posted_cd,
   c.order_id = request->order_id, c.process_flg = request->process_flg, c.ord_loc_cd = request->
   ord_srv_res_cd,
   c.perf_loc_cd = request->perf_loc_cd, c.ord_phys_id = request->ord_phys_id, c.perf_phys_id =
   request->perf_phys_id,
   c.verify_phys_id = request->verify_phys_id, c.inst_fin_nbr = substring(1,50,trim(request->
     inst_fin_nbr)), c.research_acct_id = request->research_acct_id,
   c.admit_type_cd = request->admit_type_cd, c.med_service_cd = request->med_service_cd, c
   .institution_cd = request->institution_cd,
   c.department_cd = request->department_cd, c.section_cd = request->section_cd, c.subsection_cd =
   request->subsection_cd,
   c.level5_cd = request->level5_cd, c.cost_center_cd = request->cost_center_cd, c.abn_status_cd =
   request->abn_status_cd,
   c.activity_type_cd = request->activity_type_cd, c.activity_dt_tm =
   IF ((request->activity_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->activity_dt_tm)
   ENDIF
   , c.service_dt_tm =
   IF ((request->service_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->service_dt_tm)
   ENDIF
   ,
   c.active_ind = request->active_ind, c.active_status_cd = request->active_status_cd, c
   .active_status_prsnl_id = request->active_status_prsnl_id,
   c.active_status_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate
    ),
   c.updt_id = 0, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task,
   c.beg_effective_dt_tm =
   IF ((request->beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->beg_effective_dt_tm)
   ENDIF
   , c.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"), c.fin_class_cd = request->
   fin_class_cd,
   c.health_plan_id = request->health_plan_id, c.interface_file_id = request->interface_id, c
   .tier_group_cd = request->tier_group_cd,
   c.def_bill_item_id = request->def_bill_item_id, c.manual_ind = request->manual_ind
  WHERE (c.charge_item_id=request->charge_item_id)
 ;end update
 SELECT INTO "nl:"
  realtime_ind = interfacefiles->files[d1.seq].realtime_ind
  FROM (dummyt d1  WITH seq = value(size(interfacefiles->files,5)))
  WHERE (interfacefiles->files[d1.seq].interface_file_id=request->interface_id)
  DETAIL
   reply->realtime_ind = realtime_ind
  WITH nocounter
 ;end select
 CALL echo(build("reply->realtime_ind: ",reply->realtime_ind))
#end_program
END GO
