CREATE PROGRAM afc_charge_event_find:dba
 SET afc_charge_event_find = "48688.FT.000"
 RECORD reply(
   1 charge_event_id = f8
   1 ext_m_event_id = f8
   1 ext_m_event_cont_cd = f8
   1 ext_m_reference_id = f8
   1 ext_m_reference_cont_cd = f8
   1 ext_p_event_id = f8
   1 ext_p_event_cont_cd = f8
   1 ext_p_reference_id = f8
   1 ext_p_reference_cont_cd = f8
   1 ext_i_event_id = f8
   1 ext_i_event_cont_cd = f8
   1 ext_i_reference_id = f8
   1 ext_i_reference_cont_cd = f8
   1 bill_item_id = f8
   1 p_bill_item_id = f8
   1 m_bill_item_id = f8
   1 p_charge_event_id = f8
   1 m_charge_event_id = f8
   1 order_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 cancelled_ind = i2
   1 cancelled_dt_tm = dq8
   1 person_id = f8
   1 encntr_id = f8
   1 collection_priority_cd = f8
   1 report_priority_cd = f8
   1 accession = vc
   1 updt_cnt = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 active_ind = i2
   1 active_status_dt_tm = dq8
   1 updt_task = i4
   1 updt_applctx = i4
   1 research_account_id = f8
   1 abn_status_cd = f8
   1 perf_loc_cd = f8
   1 health_plan_id = f8
   1 epsdt_ind = i2
   1 charge_event_act_count = i4
   1 charge_event_act[*]
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 cea_type_cd = f8
     2 cea_prsnl_id = f8
     2 service_resource_cd = f8
     2 service_dt_tm = dq8
     2 charge_dt_tm = dq8
     2 charge_type_cd = f8
     2 reference_range_factor_id = f8
     2 alpha_nomen_id = f8
     2 quantity = f8
     2 units = i4
     2 unit_type_cd = f8
     2 patient_loc_cd = f8
     2 service_loc_cd = f8
     2 reason_cd = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
     2 active_ind = i2
     2 insert_dt_tm = dq8
     2 updt_id = f8
     2 updt_applctx = i4
     2 in_lab_dt_tm = dq8
     2 accession_id = f8
     2 repeat_ind = i2
     2 result = vc
     2 cea_misc1 = vc
     2 cea_misc1_id = f8
     2 cea_misc2 = vc
     2 cea_misc2_id = f8
     2 cea_misc3 = vc
     2 cea_misc3_id = f8
     2 cea_misc4_id = f8
     2 srv_diag1_id = f8
     2 srv_diag2_id = f8
     2 srv_diag3_id = f8
     2 srv_diag4_id = f8
     2 srv_diag_cd = f8
     2 misc_ind = i2
     2 cea_misc5_id = f8
     2 cea_misc6_id = f8
     2 cea_misc7_id = f8
     2 activity_dt_tm = dq8
     2 priority_cd = f8
     2 item_price = f8
     2 item_ext_price = f8
     2 item_copay = f8
     2 discount_amount = f8
     2 item_reimbursement = f8
     2 item_deductible_amt = f8
     2 patient_responsibility_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE charge_event_act_count = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET curalias cea reply->charge_event_act[charge_event_act_count]
 SELECT INTO "nl:"
  FROM charge c,
   charge_event ev,
   charge_event_act act
  PLAN (c
   WHERE (c.charge_item_id=request->charge_item_id))
   JOIN (ev
   WHERE ev.charge_event_id=c.charge_event_id)
   JOIN (act
   WHERE act.charge_event_act_id=c.charge_event_act_id)
  HEAD ev.charge_event_id
   reply->charge_event_id = ev.charge_event_id, reply->ext_m_event_id = ev.ext_m_event_id, reply->
   ext_m_event_cont_cd = ev.ext_m_event_cont_cd,
   reply->ext_m_reference_id = ev.ext_m_reference_id, reply->ext_m_reference_cont_cd = ev
   .ext_m_reference_cont_cd, reply->ext_p_event_id = ev.ext_p_event_id,
   reply->ext_p_event_cont_cd = ev.ext_p_event_cont_cd, reply->ext_p_reference_id = ev
   .ext_p_reference_id, reply->ext_p_reference_cont_cd = ev.ext_p_reference_cont_cd,
   reply->ext_i_event_id = ev.ext_i_event_id, reply->ext_i_event_cont_cd = ev.ext_i_event_cont_cd,
   reply->ext_i_reference_id = ev.ext_i_reference_id,
   reply->ext_i_reference_cont_cd = ev.ext_i_reference_cont_cd, reply->bill_item_id = ev.bill_item_id,
   reply->p_bill_item_id = ev.p_bill_item_id,
   reply->m_bill_item_id = ev.m_bill_item_id, reply->p_charge_event_id = ev.p_charge_event_id, reply
   ->m_charge_event_id = ev.m_charge_event_id,
   reply->order_id = ev.order_id, reply->contributor_system_cd = ev.contributor_system_cd, reply->
   reference_nbr = ev.reference_nbr,
   reply->cancelled_ind = ev.cancelled_ind, reply->cancelled_dt_tm = cnvtdatetime(ev.cancelled_dt_tm),
   reply->person_id = ev.person_id,
   reply->encntr_id = ev.encntr_id, reply->collection_priority_cd = ev.collection_priority_cd, reply
   ->report_priority_cd = ev.report_priority_cd,
   reply->accession = ev.accession, reply->updt_cnt = ev.updt_cnt, reply->updt_dt_tm = cnvtdatetime(
    ev.updt_dt_tm),
   reply->updt_id = ev.updt_id, reply->active_ind = ev.active_ind, reply->active_status_dt_tm =
   cnvtdatetime(ev.active_status_dt_tm),
   reply->updt_task = ev.updt_task, reply->updt_applctx = ev.updt_applctx, reply->research_account_id
    = ev.research_account_id,
   reply->abn_status_cd = ev.abn_status_cd, reply->perf_loc_cd = ev.perf_loc_cd, reply->
   health_plan_id = ev.health_plan_id,
   reply->epsdt_ind = ev.epsdt_ind
  DETAIL
   charge_event_act_count = (charge_event_act_count+ 1), stat = alterlist(reply->charge_event_act,
    charge_event_act_count), cea->charge_event_act_id = act.charge_event_act_id,
   cea->charge_event_id = act.charge_event_id, cea->cea_type_cd = act.cea_type_cd, cea->cea_prsnl_id
    = act.cea_prsnl_id,
   cea->service_resource_cd = act.service_resource_cd, cea->service_dt_tm = cnvtdatetime(act
    .service_dt_tm), cea->charge_dt_tm = cnvtdatetime(act.charge_dt_tm),
   cea->charge_type_cd = act.charge_type_cd, cea->reference_range_factor_id = act
   .reference_range_factor_id, cea->alpha_nomen_id = act.alpha_nomen_id,
   cea->quantity = act.quantity, cea->units = act.units, cea->unit_type_cd = act.unit_type_cd,
   cea->patient_loc_cd = act.patient_loc_cd, cea->service_loc_cd = act.service_loc_cd, cea->reason_cd
    = act.reason_cd,
   cea->updt_cnt = act.updt_cnt, cea->updt_dt_tm = cnvtdatetime(act.updt_dt_tm), cea->updt_task = act
   .updt_task,
   cea->active_ind = act.active_ind, cea->insert_dt_tm = cnvtdatetime(act.insert_dt_tm), cea->updt_id
    = act.updt_id,
   cea->updt_applctx = act.updt_applctx, cea->in_lab_dt_tm = cnvtdatetime(act.in_lab_dt_tm), cea->
   accession_id = act.accession_id,
   cea->repeat_ind = act.repeat_ind, cea->result = act.result, cea->cea_misc1 = act.cea_misc1,
   cea->cea_misc1_id = act.cea_misc1_id, cea->cea_misc2 = act.cea_misc2, cea->cea_misc2_id = act
   .cea_misc2_id,
   cea->cea_misc3 = act.cea_misc3, cea->cea_misc3_id = act.cea_misc3_id, cea->cea_misc4_id = act
   .cea_misc4_id,
   cea->srv_diag1_id = act.srv_diag1_id, cea->srv_diag2_id = act.srv_diag2_id, cea->srv_diag3_id =
   act.srv_diag3_id,
   cea->srv_diag4_id = act.srv_diag4_id, cea->srv_diag_cd = act.srv_diag_cd, cea->misc_ind = act
   .misc_ind,
   cea->cea_misc5_id = act.cea_misc5_id, cea->cea_misc6_id = act.cea_misc6_id, cea->cea_misc7_id =
   act.cea_misc7_id,
   cea->activity_dt_tm = cnvtdatetime(act.activity_dt_tm), cea->priority_cd = act.priority_cd, cea->
   item_price = act.item_price,
   cea->item_ext_price = act.item_ext_price, cea->item_copay = act.item_copay, cea->discount_amount
    = act.discount_amount,
   cea->item_reimbursement = act.item_reimbursement, cea->item_deductible_amt = act
   .item_deductible_amt, cea->patient_responsibility_flag = act.patient_responsibility_flag
  WITH nocounter
 ;end select
#end_program
 IF ((reply->charge_event_id > 0))
  SET reply->status_data.status = "S"
  SET reply->charge_event_act_count = size(reply->charge_event_act,5)
 ENDIF
 SET curalias cea off
 CALL echorecord(reply)
END GO
