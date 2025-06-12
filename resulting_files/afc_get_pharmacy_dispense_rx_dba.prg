CREATE PROGRAM afc_get_pharmacy_dispense_rx:dba
 CALL echo("executing afc_get_pharmacy_dispense_rx..mod 004")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 action_type = c3
    1 charge_event_qual = i2
    1 charge_event[*]
      2 ext_master_event_id = f8
      2 ext_master_event_cont_cd = f8
      2 ext_master_reference_id = f8
      2 ext_master_reference_cont_cd = f8
      2 ext_parent_event_id = f8
      2 ext_parent_event_cont_cd = f8
      2 ext_parent_reference_id = f8
      2 ext_parent_reference_cont_cd = f8
      2 ext_item_event_id = f8
      2 ext_item_event_cont_cd = f8
      2 ext_item_reference_id = f8
      2 ext_item_reference_cont_cd = f8
      2 order_id = f8
      2 contributor_system_cd = f8
      2 reference_nbr = vc
      2 person_id = f8
      2 person_name = vc
      2 encntr_id = f8
      2 collection_priority_cd = f8
      2 report_priority_cd = f8
      2 accession = vc
      2 order_mnemonic = c20
      2 activity_type_disp = c40
      2 charge_event_act_qual = i2
      2 charge_event_act[*]
        3 charge_event_id = f8
        3 cea_type_cd = f8
        3 cea_type_disp = c40
        3 service_resource_cd = f8
        3 service_dt_tm = dq8
        3 charge_dt_tm = dq8
        3 charge_type_cd = f8
        3 reference_range_factor_id = f8
        3 alpha_nomen_id = f8
        3 quantity = i4
        3 units = f8
        3 unit_type_cd = f8
        3 patient_loc_cd = f8
        3 service_loc_cd = f8
        3 reason_cd = f8
        3 in_lab_dt_tm = dq8
        3 in_transit_dt_tm = dq8
        3 cea_prsnl_id = f8
        3 cea_prsnl_type_cd = f8
        3 details = vc
        3 price_sched_id = f8
        3 ext_price = f8
        3 cost = f8
        3 bill_code_sched_cd = f8
        3 bill_code = vc
        3 item_desc = vc
        3 pharm_quantity = f8
        3 item_price = f8
        3 misc_ind = f8
        3 item_copay = f8
        3 item_reimbursement = f8
        3 discount_amount = f8
        3 health_plan_id = f8
      2 charge_event_mod[*]
        3 charge_event_id = f8
        3 charge_event_mod_type_cd = f8
        3 field1 = vc
        3 field2 = vc
        3 field3 = vc
        3 field4 = vc
        3 field5 = vc
        3 field6 = vc
        3 field7 = vc
        3 field8 = vc
        3 field9 = vc
        3 field10 = vc
        3 field1_id = f8
        3 field2_id = f8
        3 cm1_nbr = f8
        3 code1_cd = f8
  )
 ENDIF
 RECORD disp_quals(
   1 qual[*]
     2 order_id = f8
     2 dispense_hx_id = f8
     2 action_seq = i4
     2 item_id = f8
     2 ndc = vc
     2 manf_item_id = f8
     2 residual_ind = i2
     2 residual_price = f8
     2 residual_cost = f8
     2 residual_qty = f8
     2 residual_disp_hx_id = f8
     2 residual_item_copay = f8
     2 residual_item_reimbursement = f8
     2 residual_discount_amount = f8
     2 charge_type_cd = f8
     2 chrg_dispense_hx_id = f8
     2 reverse_ind = i2
 )
 SET x = 0
 SET charge_event_cnt = 0
 SET disp_quals_cnt = 0
 SET retail_pharm_type_cd = 0.0
 SET disp_id_cd = 0.0
 SET ord_cat_cd = 0.0
 SET manf_item_cd = 0.0
 SET dispensed_cd = 0.0
 SET pharmdr_cd = 0.0
 SET pharmcr_cd = 0.0
 SET billcode_cd = 0.0
 SET ndc_cd = 0.0
 SET dispense_event_type_cd = 0.0
 SET cancel_fill_event_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(4500,"RETAIL",1,retail_pharm_type_cd)
 SET stat = uar_get_meaning_by_codeset(13016,"DISP ID",1,disp_id_cd)
 SET stat = uar_get_meaning_by_codeset(13016,"ORD CAT",1,ord_cat_cd)
 SET stat = uar_get_meaning_by_codeset(13016,"MANF ITEM",1,manf_item_cd)
 SET stat = uar_get_meaning_by_codeset(13029,"DISPENSED",1,dispensed_cd)
 SET stat = uar_get_meaning_by_codeset(13028,"PHARMDR",1,pharmdr_cd)
 SET stat = uar_get_meaning_by_codeset(13028,"PHARMCR",1,pharmcr_cd)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,billcode_cd)
 SET stat = uar_get_meaning_by_codeset(11000,"NDC",1,ndc_cd)
 SET stat = uar_get_meaning_by_codeset(4032,"DISPENSE",1,dispense_event_type_cd)
 SET stat = uar_get_meaning_by_codeset(4032,"CANCELFILL",1,cancel_fill_event_type_cd)
 DECLARE ccancelowe = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"CANCELOWE"))
 DECLARE ccredit = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"CR"))
 DECLARE creverse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13029,"REVERSE"))
 DECLARE sretailreversechargepref = vc WITH protect, constant("rxareversepharmacycharge")
 CALL echo(build("ndc_cd:",ndc_cd))
 CALL echo(build("retail_pharm_type_cd:",retail_pharm_type_cd))
 RECORD copay_details(
   1 qual[*]
     2 order_id = f8
     2 dispense_hx_id = f8
     2 chargemodindex = i4
     2 field1_id = f8
     2 field7 = vc
     2 field2_id = f8
 )
 RECORD tmpfieldaction(
   1 oefields[*]
     2 oefieldmeaningcd = f8
     2 actionsequence = i4
     2 orderid = f8
 )
 DECLARE ltmpcopayqualindex = i4 WITH public, noconstant(0)
 DECLARE lchargemodindex = i4 WITH public, noconstant(1)
 DECLARE lchargeeventcount = i4 WITH public, noconstant(0)
 DECLARE lchargeeventqualcount = i4 WITH public, noconstant(0)
 DECLARE lcopaydetailscount = i4 WITH protect, noconstant(0)
 DECLARE lcurrentchargeidx = i4 WITH protect, noconstant(1)
 DECLARE lchargeeventmodcurrindex = i4 WITH protect, noconstant(0)
 DECLARE dchargemodtypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"FLEX"))
 DECLARE doefmserviceconnected = f8 WITH protect, constant(6050.0)
 DECLARE dserviceconnectedcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,
   "SVCCONNECTED"))
 DECLARE sserviceconnecteddisplay = vc WITH protect, constant(uar_get_code_display(
   dserviceconnectedcd))
 DECLARE doefmspecialauthority = f8 WITH protect, constant(6051.0)
 DECLARE dspecialauthoritycd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,
   "SPECIALAUTH"))
 DECLARE sspecialauthoritydisplay = vc WITH protect, noconstant(uar_get_code_display(
   dspecialauthoritycd))
 DECLARE doefmpharmacydesignation = f8 WITH protect, constant(6056.0)
 DECLARE dpharmacydesignationcodeset = f8 WITH protect, constant(4640013)
 DECLARE dcopayreasoncd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"COPAYREASON"))
 DECLARE scopayreasondisplay = vc WITH protect, constant(uar_get_code_display(dcopayreasoncd))
 DECLARE doefmbenefittype = f8 WITH protect, constant(6057.0)
 DECLARE dbenefittypecodeset = f8 WITH protect, constant(4640014)
 DECLARE doefmdayssupply = f8 WITH protect, constant(2225.00)
 DECLARE dbenefittypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"BENEFITTYPE"))
 DECLARE sbenefittypedisplay = vc WITH protect, constant(uar_get_code_display(dbenefittypecd))
 DECLARE dcopayexemptcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"COPAYEXEMPT"))
 DECLARE scopayexemptdisplay = vc WITH protect, constant(uar_get_code_display(dcopayexemptcd))
 DECLARE drxnumbercd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"RXNBR"))
 DECLARE srxnumberdisplay = vc WITH protect, constant(uar_get_code_display(drxnumbercd))
 DECLARE dfillnumbercd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"FILLNBR"))
 DECLARE sfillnumberdisplay = vc WITH protect, constant(uar_get_code_display(dfillnumbercd))
 DECLARE drxdaysupply = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"RXDAYSUPPLY"))
 DECLARE srxdaysupplydisplay = vc WITH protect, constant(uar_get_code_display(drxdaysupply))
 DECLARE dcopaycd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002352,"COPAY"))
 DECLARE scopaydisplay = vc WITH protect, noconstant(uar_get_code_display(dcopaycd))
 SELECT INTO "nl:"
  FROM dispense_hx dh,
   prod_dispense_hx pdh,
   med_identifier mi,
   dispense_hx dh2
  PLAN (dh
   WHERE dh.pharm_type_cd=retail_pharm_type_cd
    AND dh.dispense_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND dh.charge_ind=1
    AND ((dh.disp_event_type_cd+ 0) IN (dispense_event_type_cd, cancel_fill_event_type_cd, ccancelowe
   )))
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND pdh.manf_item_id > 0
    AND ((pdh.charge_qty > 0) OR (pdh.credit_qty > 0)) )
   JOIN (mi
   WHERE mi.med_product_id=pdh.med_product_id
    AND mi.item_id > 0
    AND mi.med_identifier_type_cd > 0
    AND mi.med_identifier_type_cd=ndc_cd)
   JOIN (dh2
   WHERE ((dh2.dispense_hx_id=dh.chrg_dispense_hx_id
    AND dh.disp_event_type_cd=cancel_fill_event_type_cd) OR (dh.disp_event_type_cd !=
   cancel_fill_event_type_cd
    AND dh2.dispense_hx_id=0)) )
  ORDER BY dh.dispense_hx_id, pdh.ingred_sequence
  HEAD dh.dispense_hx_id
   disp_quals_cnt += 1, stat = alterlist(disp_quals->qual,disp_quals_cnt)
   IF (dh.rev_dispense_hx_id > 0)
    disp_quals->qual[disp_quals_cnt].dispense_hx_id = dh.rev_dispense_hx_id, disp_quals->qual[
    disp_quals_cnt].residual_ind = 2, disp_quals->qual[disp_quals_cnt].residual_disp_hx_id = dh
    .dispense_hx_id
   ELSE
    disp_quals->qual[disp_quals_cnt].dispense_hx_id = pdh.dispense_hx_id
   ENDIF
   disp_quals->qual[disp_quals_cnt].action_seq = dh.action_sequence, disp_quals->qual[disp_quals_cnt]
   .item_id = pdh.item_id, disp_quals->qual[disp_quals_cnt].order_id = dh.order_id,
   disp_quals->qual[disp_quals_cnt].manf_item_id = pdh.manf_item_id, disp_quals->qual[disp_quals_cnt]
   .ndc = mi.value
   IF (dh.disp_event_type_cd IN (dispense_event_type_cd, ccancelowe))
    IF ((disp_quals->qual[disp_quals_cnt].residual_ind=2))
     disp_quals->qual[disp_quals_cnt].charge_type_cd = pharmcr_cd
    ELSE
     disp_quals->qual[disp_quals_cnt].charge_type_cd = pharmdr_cd
    ENDIF
   ELSEIF (dh.disp_event_type_cd=cancel_fill_event_type_cd)
    disp_quals->qual[disp_quals_cnt].charge_type_cd = pharmcr_cd, disp_quals->qual[disp_quals_cnt].
    reverse_ind = dh2.reverse_ind
   ELSE
    disp_quals->qual[disp_quals_cnt].charge_type_cd = 0
   ENDIF
   IF ((disp_quals->qual[disp_quals_cnt].charge_type_cd=pharmcr_cd)
    AND (disp_quals->qual[disp_quals_cnt].reverse_ind=1))
    disp_quals->qual[disp_quals_cnt].chrg_dispense_hx_id = dh2.dispense_hx_id
   ENDIF
   IF (dh.rev_dispense_hx_id > 0
    AND dh.residual_disp_qty > 0)
    disp_quals_cnt += 1, stat = alterlist(disp_quals->qual,disp_quals_cnt), disp_quals->qual[
    disp_quals_cnt].dispense_hx_id = dh.dispense_hx_id,
    disp_quals->qual[disp_quals_cnt].action_seq = dh.action_sequence, disp_quals->qual[disp_quals_cnt
    ].item_id = pdh.item_id, disp_quals->qual[disp_quals_cnt].order_id = dh.order_id,
    disp_quals->qual[disp_quals_cnt].manf_item_id = pdh.manf_item_id, disp_quals->qual[disp_quals_cnt
    ].ndc = mi.value, disp_quals->qual[disp_quals_cnt].residual_ind = 1,
    disp_quals->qual[disp_quals_cnt].residual_price = dh.residual_price, disp_quals->qual[
    disp_quals_cnt].residual_cost = dh.residual_cost_amt, disp_quals->qual[disp_quals_cnt].
    residual_qty = dh.residual_disp_qty,
    disp_quals->qual[disp_quals_cnt].residual_item_copay = dh.residual_copay_amt, disp_quals->qual[
    disp_quals_cnt].residual_item_reimbursement = dh.residual_reimbursement_amt, disp_quals->qual[
    disp_quals_cnt].residual_discount_amount = dh.residual_discount_amt,
    disp_quals->qual[disp_quals_cnt].residual_disp_hx_id = dh.dispense_hx_id, disp_quals->qual[
    disp_quals_cnt].charge_type_cd = pharmdr_cd
   ENDIF
  DETAIL
   x = x
  WITH nocounter
 ;end select
 CALL echorecord(disp_quals)
 CALL echo(build("size:",value(size(disp_quals->qual,5))))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(disp_quals->qual,5))),
   dispense_hx dh,
   charge_event ce,
   charge ch,
   orders ord,
   person p,
   order_dispense odisp,
   dummyt d1,
   dummyt d3
  PLAN (d)
   JOIN (dh
   WHERE (dh.dispense_hx_id=disp_quals->qual[d.seq].dispense_hx_id))
   JOIN (ord
   WHERE (ord.order_id=disp_quals->qual[d.seq].order_id))
   JOIN (p
   WHERE p.person_id=ord.person_id)
   JOIN (odisp
   WHERE (odisp.order_id=disp_quals->qual[d.seq].order_id))
   JOIN (d1)
   JOIN (ce
   WHERE (ce.ext_i_reference_id=disp_quals->qual[d.seq].manf_item_id)
    AND (ce.ext_m_event_id=disp_quals->qual[d.seq].dispense_hx_id))
   JOIN (d3)
   JOIN (ch
   WHERE ce.charge_event_id=ch.charge_event_id
    AND (((disp_quals->qual[d.seq].residual_ind=2)
    AND ch.charge_type_cd IN (ccredit, pharmcr_cd)) OR ((disp_quals->qual[d.seq].residual_ind != 2)
   )) )
  DETAIL
   IF (((ch.seq=0) OR (ce.seq=0)) )
    charge_event_cnt += 1, stat = alterlist(reply->charge_event,charge_event_cnt)
    IF ((disp_quals->qual[d.seq].charge_type_cd=pharmcr_cd)
     AND (disp_quals->qual[d.seq].reverse_ind=1))
     reply->charge_event[charge_event_cnt].ext_master_event_id = disp_quals->qual[d.seq].
     chrg_dispense_hx_id
    ELSE
     reply->charge_event[charge_event_cnt].ext_master_event_id = disp_quals->qual[d.seq].
     dispense_hx_id
    ENDIF
    reply->charge_event[charge_event_cnt].ext_master_event_cont_cd = disp_id_cd, reply->charge_event[
    charge_event_cnt].ext_master_reference_id = ord.catalog_cd, reply->charge_event[charge_event_cnt]
    .ext_master_reference_cont_cd = ord_cat_cd,
    reply->charge_event[charge_event_cnt].ext_parent_event_id = 0, reply->charge_event[
    charge_event_cnt].ext_parent_event_cont_cd = 0, reply->charge_event[charge_event_cnt].
    ext_parent_reference_id = 0,
    reply->charge_event[charge_event_cnt].ext_parent_reference_cont_cd = 0
    IF ((disp_quals->qual[d.seq].charge_type_cd=pharmcr_cd)
     AND (disp_quals->qual[d.seq].reverse_ind=1))
     reply->charge_event[charge_event_cnt].ext_item_event_id = disp_quals->qual[d.seq].
     chrg_dispense_hx_id
    ELSE
     reply->charge_event[charge_event_cnt].ext_item_event_id = disp_quals->qual[d.seq].dispense_hx_id
    ENDIF
    reply->charge_event[charge_event_cnt].ext_item_event_cont_cd = disp_id_cd, reply->charge_event[
    charge_event_cnt].ext_item_reference_id = disp_quals->qual[d.seq].manf_item_id, reply->
    charge_event[charge_event_cnt].ext_item_reference_cont_cd = manf_item_cd,
    reply->charge_event[charge_event_cnt].order_id = dh.order_id, reply->charge_event[
    charge_event_cnt].contributor_system_cd = 0, reply->charge_event[charge_event_cnt].reference_nbr
     = "",
    reply->charge_event[charge_event_cnt].person_id = odisp.person_id, reply->charge_event[
    charge_event_cnt].person_name = p.name_full_formatted, reply->charge_event[charge_event_cnt].
    encntr_id = odisp.encntr_id,
    reply->charge_event[charge_event_cnt].collection_priority_cd = 0, reply->charge_event[
    charge_event_cnt].report_priority_cd = 0, reply->charge_event[charge_event_cnt].accession = "",
    reply->charge_event[charge_event_cnt].order_mnemonic = "", reply->charge_event[charge_event_cnt].
    activity_type_disp = "", reply->charge_event[charge_event_cnt].charge_event_act_qual = 1,
    stat = alterlist(reply->charge_event[charge_event_cnt].charge_event_act,1), reply->charge_event[
    charge_event_cnt].charge_event_act[1].charge_event_id = 0
    IF ((disp_quals->qual[d.seq].charge_type_cd=pharmcr_cd)
     AND (disp_quals->qual[d.seq].reverse_ind=1))
     reply->charge_event[charge_event_cnt].charge_event_act[1].cea_type_cd = creverse_cd
    ELSE
     reply->charge_event[charge_event_cnt].charge_event_act[1].cea_type_cd = dispensed_cd
    ENDIF
    reply->charge_event[charge_event_cnt].charge_event_act[1].cea_type_disp = "", reply->
    charge_event[charge_event_cnt].charge_event_act[1].service_resource_cd = dh.disp_sr_cd, reply->
    charge_event[charge_event_cnt].charge_event_act[1].service_dt_tm = dh.disp_priority_dt_tm,
    reply->charge_event[charge_event_cnt].charge_event_act[1].charge_dt_tm = dh.disp_priority_dt_tm,
    reply->charge_event[charge_event_cnt].charge_event_act[1].charge_type_cd = disp_quals->qual[d.seq
    ].charge_type_cd, reply->charge_event[charge_event_cnt].charge_event_act[1].
    reference_range_factor_id = 0,
    reply->charge_event[charge_event_cnt].charge_event_act[1].alpha_nomen_id = 0, reply->
    charge_event[charge_event_cnt].charge_event_act[1].quantity = dh.bill_qty, reply->charge_event[
    charge_event_cnt].charge_event_act[1].units = 0,
    reply->charge_event[charge_event_cnt].charge_event_act[1].unit_type_cd = 0, reply->charge_event[
    charge_event_cnt].charge_event_act[1].patient_loc_cd = 0, reply->charge_event[charge_event_cnt].
    charge_event_act[1].service_loc_cd = dh.disp_sr_cd,
    reply->charge_event[charge_event_cnt].charge_event_act[1].reason_cd = 0, reply->charge_event[
    charge_event_cnt].charge_event_act[1].in_lab_dt_tm = cnvtdatetime(""), reply->charge_event[
    charge_event_cnt].charge_event_act[1].in_transit_dt_tm = cnvtdatetime(""),
    reply->charge_event[charge_event_cnt].charge_event_act[1].cea_prsnl_id = 0, reply->charge_event[
    charge_event_cnt].charge_event_act[1].cea_prsnl_type_cd = 0, reply->charge_event[charge_event_cnt
    ].charge_event_act[1].details = ord.order_mnemonic,
    reply->charge_event[charge_event_cnt].charge_event_act[1].price_sched_id = odisp
    .price_schedule_id, reply->charge_event[charge_event_cnt].charge_event_act[1].ext_price = dh
    .event_total_price, reply->charge_event[charge_event_cnt].charge_event_act[1].cost = dh.cost,
    reply->charge_event[charge_event_cnt].charge_event_act[1].bill_code_sched_cd = 0, reply->
    charge_event[charge_event_cnt].charge_event_act[1].bill_code = "", reply->charge_event[
    charge_event_cnt].charge_event_act[1].item_desc = ord.order_mnemonic,
    reply->charge_event[charge_event_cnt].charge_event_act[1].pharm_quantity = dh.bill_qty, reply->
    charge_event[charge_event_cnt].charge_event_act[1].item_price = (dh.event_total_price/ dh
    .bill_qty), reply->charge_event[charge_event_cnt].charge_event_act[1].misc_ind = 0,
    reply->charge_event[charge_event_cnt].charge_event_act[1].item_copay = dh.copay, reply->
    charge_event[charge_event_cnt].charge_event_act[1].item_reimbursement = dh.reimbursement, reply->
    charge_event[charge_event_cnt].charge_event_act[1].discount_amount = dh.discount_amount,
    reply->charge_event[charge_event_cnt].charge_event_act[1].health_plan_id = dh.health_plan_id,
    stat = alterlist(reply->charge_event[charge_event_cnt].charge_event_mod,1), reply->charge_event[
    charge_event_cnt].charge_event_mod[1].charge_event_id = 0,
    reply->charge_event[charge_event_cnt].charge_event_mod[1].charge_event_mod_type_cd = billcode_cd,
    reply->charge_event[charge_event_cnt].charge_event_mod[1].field1 = "", reply->charge_event[
    charge_event_cnt].charge_event_mod[1].field2 = "",
    reply->charge_event[charge_event_cnt].charge_event_mod[1].field3 = disp_quals->qual[d.seq].ndc,
    reply->charge_event[charge_event_cnt].charge_event_mod[1].field4 = "1", reply->charge_event[
    charge_event_cnt].charge_event_mod[1].field5 = "",
    reply->charge_event[charge_event_cnt].charge_event_mod[1].field6 = "", reply->charge_event[
    charge_event_cnt].charge_event_mod[1].field7 = "", reply->charge_event[charge_event_cnt].
    charge_event_mod[1].field8 = "",
    reply->charge_event[charge_event_cnt].charge_event_mod[1].field9 = "", reply->charge_event[
    charge_event_cnt].charge_event_mod[1].field10 = ""
    IF ((disp_quals->qual[d.seq].charge_type_cd=pharmdr_cd)
     AND dh.disp_event_type_cd=dispense_event_type_cd)
     CALL setrxandfillnbrinchargereply(charge_event_cnt,disp_quals->qual[d.seq].dispense_hx_id)
    ENDIF
    IF ((disp_quals->qual[d.seq].residual_ind=1))
     reply->charge_event[charge_event_cnt].charge_event_act[1].quantity = disp_quals->qual[d.seq].
     residual_qty, reply->charge_event[charge_event_cnt].charge_event_act[1].ext_price = disp_quals->
     qual[d.seq].residual_price, reply->charge_event[charge_event_cnt].charge_event_act[1].cost =
     disp_quals->qual[d.seq].residual_cost,
     reply->charge_event[charge_event_cnt].charge_event_act[1].pharm_quantity = disp_quals->qual[d
     .seq].residual_qty, reply->charge_event[charge_event_cnt].charge_event_act[1].item_price = (
     disp_quals->qual[d.seq].residual_price/ disp_quals->qual[d.seq].residual_qty), reply->
     charge_event[charge_event_cnt].charge_event_act[1].item_copay = disp_quals->qual[d.seq].
     residual_item_copay,
     reply->charge_event[charge_event_cnt].charge_event_act[1].item_reimbursement = disp_quals->qual[
     d.seq].residual_item_reimbursement, reply->charge_event[charge_event_cnt].charge_event_act[1].
     discount_amount = disp_quals->qual[d.seq].residual_discount_amount
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d3
 ;end select
 DECLARE lcopaydetailsindex = i4 WITH protect, noconstant(0)
 DECLARE lqualind = i4 WITH protect, noconstant(0)
 SET lchargeeventqualcount = value(size(reply->charge_event,5))
 SET lchargeeventcount = value(size(disp_quals->qual,5))
 SELECT INTO "nl:"
  FROM dispense_hx dh,
   order_detail od
  PLAN (dh
   WHERE expand(ltmpcopayqualindex,1,lchargeeventcount,dh.dispense_hx_id,disp_quals->qual[
    ltmpcopayqualindex].dispense_hx_id)
    AND dh.disp_event_type_cd=dispense_event_type_cd
    AND dh.rebill_flag IN (0, 3, 4))
   JOIN (od
   WHERE od.order_id=dh.order_id
    AND od.oe_field_meaning_id IN (doefmserviceconnected, doefmspecialauthority,
   doefmpharmacydesignation, doefmbenefittype, doefmdayssupply)
    AND od.action_sequence <= dh.action_sequence)
  ORDER BY od.action_sequence DESC
  HEAD dh.dispense_hx_id
   flag = 0
   IF (getfieldalreadyexistfororder(dcopaycd,1,lchargemodindex,od.action_sequence,dh.dispense_hx_id)=
   1)
    CALL setchargeeventmodinchargereply(dcopaycd,scopaydisplay,"",dh.copay_tier_cd,dh.copay_tier_cd,
    dh.copay_tier_cd,lchargemodindex)
   ENDIF
  DETAIL
   pos = 0, pos = locateval(lchargemodindex,1,lchargeeventqualcount,dh.dispense_hx_id,reply->
    charge_event[lchargemodindex].ext_item_event_id)
   WHILE (pos > 0
    AND (disp_quals->qual[ltmpcopayqualindex].charge_type_cd=pharmdr_cd))
     CASE (od.oe_field_meaning_id)
      OF doefmserviceconnected:
       dfieldmeaningcd = dserviceconnectedcd,lqualind = 1
      OF doefmspecialauthority:
       dfieldmeaningcd = dspecialauthoritycd,lqualind = 1
      OF doefmpharmacydesignation:
       dfieldmeaningcd = dcopayexemptcd,lqualind = 2
      OF doefmbenefittype:
       dfieldmeaningcd = dbenefittypecd,lqualind = 1
      OF doefmdayssupply:
       lqualind = 1,dfieldmeaningcd = drxdaysupply
     ENDCASE
     IF (getfieldalreadyexistfororder(dfieldmeaningcd,lqualind,lchargemodindex,od.action_sequence,dh
      .dispense_hx_id)=1)
      IF (od.oe_field_value > 0
       AND ((od.oe_field_meaning_id=doefmpharmacydesignation) OR (od.oe_field_meaning_id=
      doefmbenefittype)) )
       lcopaydetailsindex += 1, stat = alterlist(copay_details->qual,lcopaydetailsindex),
       copay_details->qual[lcopaydetailsindex].chargemodindex = lchargemodindex,
       copay_details->qual[lcopaydetailsindex].dispense_hx_id = dh.dispense_hx_id, copay_details->
       qual[lcopaydetailsindex].field2_id = od.oe_field_value, copay_details->qual[lcopaydetailsindex
       ].order_id = dh.order_id
      ENDIF
      CASE (od.oe_field_meaning_id)
       OF doefmserviceconnected:
        CALL setchargeeventmodinchargereply(dserviceconnectedcd,sserviceconnecteddisplay,"",od
        .oe_field_value,0.0,0.0,lchargemodindex)
       OF doefmspecialauthority:
        IF (od.oe_field_value > 0)
         CALL setchargeeventmodinchargereply(dspecialauthoritycd,sspecialauthoritydisplay,"",1.0,0.0,
         0.0,lchargemodindex)
        ELSE
         CALL setchargeeventmodinchargereply(dspecialauthoritycd,sspecialauthoritydisplay,"",0.0,0.0,
         0.0,lchargemodindex)
        ENDIF
       OF doefmpharmacydesignation:
        CALL setchargeeventmodinchargereply(dcopayreasoncd,scopayreasondisplay,uar_get_code_display(
         od.oe_field_value),od.oe_field_value,0.0,0.0,lchargemodindex)
        CALL echo(build("LOG - dCopayExemptCD",dcopayexemptcd))
        IF (od.oe_field_value > 0)
         copay_details->qual[lcopaydetailsindex].field1_id = dcopayexemptcd, copay_details->qual[
         lcopaydetailsindex].field7 = scopayexemptdisplay
        ENDIF
       OF doefmbenefittype:
        IF (od.oe_field_value > 0)
         CALL setchargeeventmodinchargereply(dbenefittypecd,sbenefittypedisplay,uar_get_code_display(
          od.oe_field_value),od.oe_field_value,0.0,0.0,lchargemodindex)
        ENDIF
       OF doefmdayssupply:
        CALL setchargeeventmodinchargereply(drxdaysupply,srxdaysupplydisplay,"",od.oe_field_value,od
        .oe_field_value,0.0,lchargemodindex)
      ENDCASE
     ENDIF
     pos = locateval(lchargemodindex,(lchargemodindex+ 1),lchargeeventqualcount,dh.dispense_hx_id,
      reply->charge_event[lchargemodindex].ext_item_event_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SET lchargemodindex = 0
 SET lqualind = 0
 SET lchargeeventqualcount = value(size(reply->charge_event,5))
 SET lchargeeventcount = value(size(disp_quals->qual,5))
 SELECT INTO "nl:"
  FROM dispense_hx dh,
   order_health_plan_detail ohpd
  PLAN (dh
   WHERE expand(ltmpcopayqualindex,1,lchargeeventcount,dh.dispense_hx_id,disp_quals->qual[
    ltmpcopayqualindex].dispense_hx_id)
    AND dh.disp_event_type_cd=dispense_event_type_cd
    AND dh.rebill_flag IN (1, 2))
   JOIN (ohpd
   WHERE ohpd.order_id=dh.order_id
    AND ohpd.detail_field_ident IN (doefmserviceconnected, doefmspecialauthority,
   doefmpharmacydesignation, doefmbenefittype, doefmdayssupply)
    AND ohpd.action_seq=dh.action_sequence)
  ORDER BY dh.dispense_hx_id
  HEAD dh.dispense_hx_id
   flag = 0
   IF (getfieldalreadyexistfororder(dcopaycd,1,lchargemodindex,ohpd.action_seq,dh.dispense_hx_id)=1)
    CALL setchargeeventmodinchargereply(dcopaycd,scopaydisplay,"",dh.copay_tier_cd,dh.copay_tier_cd,
    dh.copay_tier_cd,lchargemodindex)
   ENDIF
  DETAIL
   pos = 0, pos = locateval(lchargemodindex,1,lchargeeventqualcount,dh.dispense_hx_id,reply->
    charge_event[lchargemodindex].ext_item_event_id)
   WHILE (pos > 0
    AND (disp_quals->qual[ltmpcopayqualindex].charge_type_cd=pharmdr_cd))
     CASE (ohpd.detail_field_ident)
      OF cnvtint(doefmserviceconnected):
       dfieldmeaningcd = dserviceconnectedcd,lqualind = 1
      OF cnvtint(doefmspecialauthority):
       dfieldmeaningcd = dspecialauthoritycd,lqualind = 1
      OF cnvtint(doefmpharmacydesignation):
       dfieldmeaningcd = dcopayexemptcd,lqualind = 2
      OF cnvtint(doefmbenefittype):
       dfieldmeaningcd = dbenefittypecd,lqualind = 1
      OF cnvtint(doefmdayssupply):
       lqualind = 1,dfieldmeaningcd = drxdaysupply
     ENDCASE
     IF (getfieldalreadyexistfororder(dfieldmeaningcd,lqualind,lchargemodindex,ohpd.action_seq,dh
      .dispense_hx_id)=1)
      IF (ohpd.detail_field_value > 0
       AND ((ohpd.detail_field_ident=doefmpharmacydesignation) OR (ohpd.detail_field_ident=
      doefmbenefittype)) )
       lcopaydetailsindex += 1,
       CALL echo(build("lCopayDetailsIndex ",lcopaydetailsindex)),
       CALL echo(build("lChargeModIndex ",lchargemodindex)),
       stat = alterlist(copay_details->qual,lcopaydetailsindex), copay_details->qual[
       lcopaydetailsindex].chargemodindex = lchargemodindex, copay_details->qual[lcopaydetailsindex].
       dispense_hx_id = dh.dispense_hx_id,
       copay_details->qual[lcopaydetailsindex].field2_id = ohpd.detail_field_value, copay_details->
       qual[lcopaydetailsindex].order_id = dh.order_id
      ENDIF
      CASE (ohpd.detail_field_ident)
       OF cnvtint(doefmserviceconnected):
        CALL setchargeeventmodinchargereply(dserviceconnectedcd,sserviceconnecteddisplay,"",ohpd
        .detail_field_value,0.0,0.0,lchargemodindex)
       OF cnvtint(doefmspecialauthority):
        IF (ohpd.detail_field_value > 0)
         CALL setchargeeventmodinchargereply(dspecialauthoritycd,sspecialauthoritydisplay,"",1.0,0.0,
         0.0,lchargemodindex)
        ELSE
         CALL setchargeeventmodinchargereply(dspecialauthoritycd,sspecialauthoritydisplay,"",0.0,0.0,
         0.0,lchargemodindex)
        ENDIF
       OF cnvtint(doefmpharmacydesignation):
        CALL setchargeeventmodinchargereply(dcopayreasoncd,scopayreasondisplay,uar_get_code_display(
         ohpd.detail_field_value),ohpd.detail_field_value,0.0,0.0,lchargemodindex)
        CALL echo(build("for hx rebill LOG - dCopayExemptCD",dcopayexemptcd))
        IF (ohpd.detail_field_value > 0)
         copay_details->qual[lcopaydetailsindex].field1_id = dcopayexemptcd, copay_details->qual[
         lcopaydetailsindex].field7 = scopayexemptdisplay
        ENDIF
       OF cnvtint(doefmbenefittype):
        IF (ohpd.detail_field_value > 0)
         CALL setchargeeventmodinchargereply(dbenefittypecd,sbenefittypedisplay,uar_get_code_display(
          ohpd.detail_field_value),ohpd.detail_field_value,0.0,0.0,lchargemodindex)
        ENDIF
       OF cnvtint(doefmdayssupply):
        CALL setchargeeventmodinchargereply(drxdaysupply,srxdaysupplydisplay,"",ohpd
        .detail_field_value,ohpd.detail_field_value,0.0,lchargemodindex)
      ENDCASE
     ENDIF
     pos = locateval(lchargemodindex,(lchargemodindex+ 1),lchargeeventqualcount,dh.dispense_hx_id,
      reply->charge_event[lchargemodindex].ext_item_event_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SET ltmpcopayqualindex = 0
 SET lchargemodindex = 0
 CALL echorecord(copay_details)
 SET lcopaydetailscount = value(size(copay_details->qual,5))
 IF (lcopaydetailscount > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lcopaydetailscount)),
    code_value_extension cve
   PLAN (d1)
    JOIN (cve
    WHERE expand(ltmpcopayqualindex,1,lcopaydetailscount,cve.code_value,copay_details->qual[d1.seq].
     field2_id)
     AND cve.code_set=dpharmacydesignationcodeset
     AND (copay_details->qual[d1.seq].field1_id=dcopayexemptcd))
   DETAIL
    IF (cnvtreal(cve.field_value) IN (0, 1))
     lchargemodindex = copay_details->qual[d1.seq].chargemodindex,
     CALL setchargeeventmodinchargereply(copay_details->qual[d1.seq].field1_id,copay_details->qual[d1
     .seq].field7,"",cnvtreal(cve.field_value),0.0,0.0,lchargemodindex)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SUBROUTINE (getfieldalreadyexistfororder(dfieldmeaningcd=f8,lqualind=i2,lchargequalindex=i4,
  lactionsequence=i2,dispensehxid=f8) =i4)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   DECLARE flag = i4 WITH protect, noconstant(0)
   DECLARE lchargemodindex = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   IF (lqualind=1)
    SET lpos = locateval(lchargemodindex,1,size(reply->charge_event[lchargequalindex].
      charge_event_mod,5),dfieldmeaningcd,reply->charge_event[lchargequalindex].charge_event_mod[
     lchargemodindex].field1_id)
    IF (lpos=0)
     SET flag = 1
    ENDIF
   ELSEIF (lqualind=2)
    SET lpos = locateval(lchargemodindex,1,size(copay_details->qual,5),dispensehxid,copay_details->
     qual[lchargemodindex].dispense_hx_id)
    IF (lpos=0)
     SET flag = 1
    ENDIF
    WHILE (lpos > 0)
      IF ((copay_details->qual[lpos].field1_id=dfieldmeaningcd))
       SET flag = 2
      ELSE
       SET flag = 1
      ENDIF
      SET lpos = locateval(lchargemodindex,(lchargemodindex+ 1),size(copay_details->qual,5),
       dispensehxid,copay_details->qual[lchargemodindex].dispense_hx_id)
      IF (flag=2)
       SET lpos = 0
      ENDIF
    ENDWHILE
    SET lpos = 0
   ENDIF
   RETURN(flag)
 END ;Subroutine
 SUBROUTINE (setchargeeventmodinchargereply(field1_id=f8,field7=vc,field1=vc,field2_id=f8,cm1_nbr=f8,
  code1_cd=f8,lchargemodindex=i4) =null)
   IF (size(reply->charge_event) > 0)
    SET lchargeeventmodcurrindex = value(size(reply->charge_event[lchargemodindex].charge_event_mod,5
      ))
    SET lchargeeventmodcurrindex += 1
    CALL echo(build("lChargeEventModCurrIndex in subroutine:",lchargeeventmodcurrindex))
    SET stat = alterlist(reply->charge_event[lchargemodindex].charge_event_mod,
     lchargeeventmodcurrindex)
    SET reply->charge_event[lchargemodindex].charge_event_mod[lchargeeventmodcurrindex].
    charge_event_mod_type_cd = dchargemodtypecd
    SET reply->charge_event[lchargemodindex].charge_event_mod[lchargeeventmodcurrindex].field1_id =
    field1_id
    SET reply->charge_event[lchargemodindex].charge_event_mod[lchargeeventmodcurrindex].field7 =
    field7
    SET reply->charge_event[lchargemodindex].charge_event_mod[lchargeeventmodcurrindex].field1 =
    field1
    SET reply->charge_event[lchargemodindex].charge_event_mod[lchargeeventmodcurrindex].field2_id =
    field2_id
    SET stat = assign(validate(reply->charge_event[lchargemodindex].charge_event_mod[
      lchargeeventmodcurrindex].cm1_nbr),cm1_nbr)
    SET stat = assign(validate(reply->charge_event[lchargemodindex].charge_event_mod[
      lchargeeventmodcurrindex].code1_cd),code1_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE setrxandfillnbrinchargereply(lcurrentchargeidx,dispensehxid)
   DECLARE hrequest = i4 WITH public, noconstant(0)
   DECLARE hreply = i4 WITH public, noconstant(0)
   DECLARE hmsg = i4 WITH public, noconstant(0)
   DECLARE step = i4 WITH protect, constant(350000)
   DECLARE hdispense = i4 WITH public, noconstant(0)
   DECLARE lbillclaimdetail = i4 WITH noconstant(0)
   DECLARE lbilledclaimtotal = i4 WITH noconstant(0)
   DECLARE lchargeeventmodcurrind = i4 WITH noconstant(2)
   SET hmsg = uar_srvselectmessage(step)
   SET hrequest = uar_srvcreaterequest(hmsg)
   SET hreply = uar_srvcreatereply(hmsg)
   SET stat = uar_srvsetshort(hrequest,"alwaysLoadDispenseInfo",1)
   SET hdispense = uar_srvadditem(hrequest,"dispenses")
   SET stat = uar_srvsetdouble(hdispense,"dispenseHxId",cnvtreal(dispensehxid))
   SET service_stat = uar_srvexecute(hmsg,hrequest,hreply)
   IF (service_stat=0)
    SET hstatusdata = uar_srvgetstruct(hreply,"transaction_status")
    SET nstatus = uar_srvgetshort(hstatusdata,"success_ind")
    IF (nstatus <= 0)
     SET errormsg = uar_srvgetstringptr(hstatusdata,"debug_error_message")
     CALL echo(build("Error message from Service 350000: ",errormsg))
    ENDIF
    SET lbilledclaimtotal = uar_srvgetitemcount(hreply,"billedClaimDetails")
    IF (nstatus > 0
     AND lbilledclaimtotal > 0)
     SET lbillclaimdetail = uar_srvgetitem(hreply,"billedClaimDetails",0)
     SET stat = alterlist(reply->charge_event[lcurrentchargeidx].charge_event_mod,
      lchargeeventmodcurrind)
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].
     charge_event_mod_type_cd = dchargemodtypecd
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].field1_id =
     dfillnumbercd
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].field7 =
     sfillnumberdisplay
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].field2_id =
     uar_srvgetlong(lbillclaimdetail,"fillNumber")
     SET stat = assign(validate(reply->charge_event[lcurrentchargeidx].charge_event_mod[
       lchargeeventmodcurrind].cm1_nbr),uar_srvgetlong(lbillclaimdetail,"fillNumber"))
     SET lchargeeventmodcurrind += 1
     SET stat = alterlist(reply->charge_event[lcurrentchargeidx].charge_event_mod,
      lchargeeventmodcurrind)
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].
     charge_event_mod_type_cd = dchargemodtypecd
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].field1_id =
     drxnumbercd
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].field7 =
     srxnumberdisplay
     SET reply->charge_event[lcurrentchargeidx].charge_event_mod[lchargeeventmodcurrind].field2 =
     uar_srvgetstringptr(lbillclaimdetail,"prescriptionReferenceNumber")
    ELSE
     SET stat = alterlist(reply->charge_event[lcurrentchargeidx].charge_event_mod,1)
    ENDIF
   ENDIF
   SET stat = uar_srvdestroyinstance(hmsg)
   SET stat = uar_srvdestroyinstance(hrequest)
   SET stat = uar_srvdestroyinstance(hreply)
   SET stat = uar_srvdestroyinstance(hdispense)
   SET stat = uar_srvdestroyinstance(lbillclaimdetail)
 END ;Subroutine
 SET reply->action_type = "PHA"
 SET reply->charge_event_qual = value(size(reply->charge_event,5))
 CALL echorecord(reply)
 CALL echo("Last MOD: 008")
 CALL echo("MOD Date: 09/05/2020")
END GO
