CREATE PROGRAM afc_get_charge_events:dba
 SET afc_get_charge_events_vsn = "323720.003"
 RECORD reply(
   1 charge_event_qual = i4
   1 charge_event[*]
     2 charge_event_id = f8
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
     2 bill_item_id = f8
     2 order_id = f8
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 collection_priority_cd = f8
     2 report_priority_cd = f8
     2 accession = vc
     2 epsdt_ind = i2
     2 order_mnemonic = c20
     2 mnemonic = c20
     2 activity_type_disp = c40
     2 misc_ind = i2
     2 misc_price = f8
     2 misc_description = vc
     2 perf_loc_cd = f8
     2 build_exists = i2
     2 charge_event_act_qual = i2
     2 charge_event_act[*]
       3 charge_event_act_id = f8
       3 charge_event_id = f8
       3 cea_type_cd = f8
       3 cea_type_disp = vc
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
       3 misc_ind = i2
       3 result = vc
       3 item_copay = f8
       3 item_reimbursement = f8
       3 discount_amount = f8
       3 health_plan_id = f8
       3 prsnl_qual = i2
       3 prsnl[*]
         4 prsnl_id = f8
         4 prsnl_type_cd = f8
     2 charge_event_mod_qual = i2
     2 charge_event_mod[*]
       3 charge_event_id = f8
       3 charge_event_mod_type_cd = f8
       3 field1 = vc
       3 field2 = vc
       3 field3 = vc
       3 field4 = vc
       3 field1_id = f8
       3 field5 = vc
       3 field6 = vc
       3 field7 = vc
       3 field8 = vc
       3 field9 = vc
       3 field10 = vc
       3 field2_id = f8
       3 field3_id = f8
       3 nomen_id = f8
     2 nomen_qual = i2
     2 nomen[*]
       3 nomen_id = f8
 )
 DECLARE cewhereparser = vc WITH public, noconstant("1=1")
 DECLARE ceawhereparser = vc WITH public, noconstant("1=1")
 DECLARE lcecnt = i4 WITH public, noconstant(0)
 DECLARE lceacnt = i4 WITH public, noconstant(0)
 DECLARE lceapcnt = i4 WITH public, noconstant(0)
 DECLARE lcemcnt = i4 WITH public, noconstant(0)
 DECLARE iret = i2 WITH public, noconstant(0)
 DECLARE 13019_chargepoint = f8
 SET codeset = 13019
 SET cdf_meaning = "CHARGE POINT"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13019_chargepoint)
 DECLARE 13020_null = f8
 SET codeset = 13020
 SET cdf_meaning = "NULL"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13020_null)
 DECLARE 13029_clear = f8
 SET codeset = 13029
 SET cdf_meaning = "CLEAR"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,13029_clear)
 IF ((request->encntr_id > 0))
  SET cewhereparser = concat("ce.encntr_id = ",cnvtstring(request->encntr_id,17,2))
 ENDIF
 IF (cnvtdatetime(request->service_dt_tm_f) > 0)
  SET ceawhereparser =
  "cea.service_dt_tm between cnvtdatetime(request->service_dt_tm_f) and cnvtdatetime(request->service_dt_tm_t)"
 ENDIF
 SELECT
  IF ((request->encntr_id=0))
   PLAN (cea
    WHERE parser(ceawhereparser))
    JOIN (ce
    WHERE (ce.charge_event_id=(cea.charge_event_id+ 0))
     AND  NOT ( EXISTS (
    (SELECT
     c.charge_item_id
     FROM charge c
     WHERE c.charge_event_id=ce.charge_event_id))))
    JOIN (ceap
    WHERE ceap.charge_event_act_id=outerjoin(cea.charge_event_act_id))
  ELSE
   PLAN (ce
    WHERE parser(cewhereparser)
     AND  NOT ( EXISTS (
    (SELECT
     c.charge_item_id
     FROM charge c
     WHERE c.charge_event_id=ce.charge_event_id))))
    JOIN (cea
    WHERE cea.charge_event_id=ce.charge_event_id
     AND parser(ceawhereparser))
    JOIN (ceap
    WHERE ceap.charge_event_act_id=outerjoin(cea.charge_event_act_id))
  ENDIF
  INTO "nl:"
  FROM charge_event ce,
   charge_event_act cea,
   charge_event_act_prsnl ceap
  ORDER BY ce.charge_event_id, cea.charge_event_act_id, ceap.prsnl_id
  HEAD REPORT
   stat = alterlist(reply->charge_event,10)
  HEAD ce.charge_event_id
   lcecnt = (lcecnt+ 1), lceacnt = 0
   IF (mod(lcecnt,10)=1
    AND lcecnt != 1)
    stat = alterlist(reply->charge_event,(lcecnt+ 10))
   ENDIF
   stat = alterlist(reply->charge_event[lcecnt].charge_event_act,10), reply->charge_event[lcecnt].
   charge_event_id = ce.charge_event_id, reply->charge_event[lcecnt].ext_master_event_id = ce
   .ext_m_event_id,
   reply->charge_event[lcecnt].ext_master_event_cont_cd = ce.ext_m_event_cont_cd, reply->
   charge_event[lcecnt].ext_master_reference_id = ce.ext_m_reference_id, reply->charge_event[lcecnt].
   ext_master_reference_cont_cd = ce.ext_m_reference_cont_cd,
   reply->charge_event[lcecnt].ext_parent_event_id = ce.ext_p_event_id, reply->charge_event[lcecnt].
   ext_parent_event_cont_cd = ce.ext_p_event_cont_cd, reply->charge_event[lcecnt].
   ext_parent_reference_id = ce.ext_p_reference_id,
   reply->charge_event[lcecnt].ext_parent_reference_cont_cd = ce.ext_p_reference_cont_cd, reply->
   charge_event[lcecnt].ext_item_event_id = ce.ext_i_event_id, reply->charge_event[lcecnt].
   ext_item_event_cont_cd = ce.ext_i_event_cont_cd,
   reply->charge_event[lcecnt].ext_item_reference_id = ce.ext_i_reference_id, reply->charge_event[
   lcecnt].ext_item_reference_cont_cd = ce.ext_i_reference_cont_cd, reply->charge_event[lcecnt].
   order_id = ce.order_id,
   reply->charge_event[lcecnt].contributor_system_cd = ce.contributor_system_cd, reply->charge_event[
   lcecnt].reference_nbr = ce.reference_nbr, reply->charge_event[lcecnt].person_id = ce.person_id,
   reply->charge_event[lcecnt].encntr_id = ce.encntr_id, reply->charge_event[lcecnt].
   collection_priority_cd = ce.collection_priority_cd, reply->charge_event[lcecnt].report_priority_cd
    = ce.report_priority_cd,
   reply->charge_event[lcecnt].accession = ce.accession, reply->charge_event[lcecnt].epsdt_ind = ce
   .epsdt_ind, reply->charge_event[lcecnt].perf_loc_cd = ce.perf_loc_cd
  HEAD cea.charge_event_act_id
   lceapcnt = 0, lceacnt = (lceacnt+ 1)
   IF (mod(lceacnt,10)=1
    AND lceacnt != 1)
    stat = alterlist(reply->charge_event[lcecnt].charge_event_act,(lceacnt+ 10))
   ENDIF
   stat = alterlist(reply->charge_event[lcecnt].charge_event_act[lceacnt].prsnl,10), reply->
   charge_event[lcecnt].charge_event_act[lceacnt].charge_event_act_id = cea.charge_event_act_id,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].charge_event_id = cea.charge_event_id,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].cea_type_cd = cea.cea_type_cd, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].service_resource_cd = cea.service_resource_cd,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].service_dt_tm = cea.service_dt_tm,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].charge_dt_tm = cea.charge_dt_tm, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].charge_type_cd = cea.charge_type_cd, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].reference_range_factor_id = cea
   .reference_range_factor_id,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].alpha_nomen_id = cea.alpha_nomen_id, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].quantity = cea.quantity, reply->charge_event[lcecnt
   ].charge_event_act[lceacnt].units = cea.units,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].unit_type_cd = cea.unit_type_cd, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].patient_loc_cd = cea.patient_loc_cd, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].service_loc_cd = cea.service_loc_cd,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].reason_cd = cea.reason_cd, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].in_lab_dt_tm = cea.in_lab_dt_tm, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].cea_prsnl_id = cea.cea_prsnl_id,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].cea_prsnl_type_cd = cea.cea_type_cd, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].ext_price = cea.item_ext_price, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].item_price = cea.item_price,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].misc_ind = cea.misc_ind, reply->
   charge_event[lcecnt].charge_event_act[lceacnt].result = cea.result, reply->charge_event[lcecnt].
   charge_event_act[lceacnt].item_copay = cea.item_copay,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].item_reimbursement = cea.item_reimbursement,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].discount_amount = cea.discount_amount
  DETAIL
   lceapcnt = (lceapcnt+ 1)
   IF (mod(lceapcnt,10)=1
    AND lceapcnt != 1)
    stat = alterlist(reply->charge_event[lcecnt].charge_event_act[lceacnt].prsnl,(lceapcnt+ 10))
   ENDIF
   reply->charge_event[lcecnt].charge_event_act[lceacnt].prsnl[lceapcnt].prsnl_id = ceap.prsnl_id,
   reply->charge_event[lcecnt].charge_event_act[lceacnt].prsnl[lceapcnt].prsnl_type_cd = ceap
   .prsnl_type_cd
  FOOT  cea.charge_event_act_id
   reply->charge_event[lcecnt].charge_event_act_qual = lceacnt, reply->charge_event[lcecnt].
   charge_event_act[lceacnt].prsnl_qual = lceapcnt, stat = alterlist(reply->charge_event[lcecnt].
    charge_event_act[lceacnt].prsnl,lceapcnt)
  FOOT  ce.charge_event_id
   reply->charge_event[lcecnt].charge_event_act_qual = lceacnt, stat = alterlist(reply->charge_event[
    lcecnt].charge_event_act,lceacnt)
  FOOT REPORT
   reply->charge_event_qual = lcecnt, stat = alterlist(reply->charge_event,lcecnt)
  WITH nocounter
 ;end select
 IF ((reply->charge_event_qual > 0))
  SELECT INTO "nl:"
   FROM person p,
    (dummyt d  WITH seq = value(reply->charge_event_qual))
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=reply->charge_event[d.seq].person_id))
   DETAIL
    reply->charge_event[d.seq].person_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bill_item b,
    bill_item_modifier bim,
    (dummyt d  WITH seq = value(reply->charge_event_qual))
   PLAN (d
    WHERE (reply->charge_event[d.seq].ext_parent_reference_id=0.0))
    JOIN (b
    WHERE (b.ext_parent_reference_id=reply->charge_event[d.seq].ext_item_reference_id)
     AND (b.ext_parent_contributor_cd=reply->charge_event[d.seq].ext_item_reference_cont_cd)
     AND b.ext_child_reference_id=0
     AND b.ext_child_contributor_cd=0)
    JOIN (bim
    WHERE bim.bill_item_id=b.bill_item_id
     AND bim.bill_item_type_cd=13019_chargepoint
     AND bim.key2_id != 13029_clear
     AND bim.key4_id != 13020_null
     AND bim.active_ind=1)
   DETAIL
    reply->charge_event[d.seq].order_mnemonic = b.ext_description, reply->charge_event[d.seq].
    mnemonic = b.ext_short_desc, reply->charge_event[d.seq].activity_type_disp = uar_get_code_display
    (b.ext_owner_cd),
    reply->charge_event[d.seq].build_exists = 1, reply->charge_event[d.seq].bill_item_id = b
    .bill_item_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bill_item b,
    bill_item_modifier bim,
    (dummyt d  WITH seq = value(reply->charge_event_qual))
   PLAN (d
    WHERE (reply->charge_event[d.seq].ext_parent_reference_id > 0.0))
    JOIN (b
    WHERE (b.ext_parent_reference_id=reply->charge_event[d.seq].ext_parent_reference_id)
     AND (b.ext_parent_contributor_cd=reply->charge_event[d.seq].ext_parent_reference_cont_cd)
     AND (b.ext_child_reference_id=reply->charge_event[d.seq].ext_item_reference_id)
     AND (b.ext_child_contributor_cd=reply->charge_event[d.seq].ext_item_reference_cont_cd))
    JOIN (bim
    WHERE bim.bill_item_id=b.bill_item_id
     AND bim.bill_item_type_cd=13019_chargepoint
     AND bim.key2_id != 13029_clear
     AND bim.key4_id != 13020_null
     AND bim.active_ind=1)
   DETAIL
    reply->charge_event[d.seq].order_mnemonic = b.ext_description, reply->charge_event[d.seq].
    mnemonic = b.ext_short_desc, reply->charge_event[d.seq].activity_type_disp = uar_get_code_display
    (b.ext_owner_cd),
    reply->charge_event[d.seq].build_exists = 1, reply->charge_event[d.seq].bill_item_id = b
    .bill_item_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_mod cem,
    (dummyt d  WITH seq = value(reply->charge_event_qual))
   PLAN (d)
    JOIN (cem
    WHERE (cem.charge_event_id=reply->charge_event[d.seq].charge_event_id))
   ORDER BY cem.charge_event_id
   HEAD cem.charge_event_id
    lcemcnt = 0, stat = alterlist(reply->charge_event[d.seq].charge_event_mod,10)
   DETAIL
    lcemcnt = (lcemcnt+ 1)
    IF (mod(lcemcnt,10)=1
     AND lcemcnt != 1)
     stat = alterlist(reply->charge_event[d.seq].charge_event_mod,(lcemcnt+ 10))
    ENDIF
    reply->charge_event[d.seq].charge_event_mod[lcemcnt].charge_event_id = cem.charge_event_id, reply
    ->charge_event[d.seq].charge_event_mod[lcemcnt].charge_event_mod_type_cd = cem
    .charge_event_mod_type_cd, reply->charge_event[d.seq].charge_event_mod[lcemcnt].field1 = cem
    .field1,
    reply->charge_event[d.seq].charge_event_mod[lcemcnt].field2 = cem.field2, reply->charge_event[d
    .seq].charge_event_mod[lcemcnt].field3 = cem.field3, reply->charge_event[d.seq].charge_event_mod[
    lcemcnt].field4 = cem.field4,
    reply->charge_event[d.seq].charge_event_mod[lcemcnt].field5 = cem.field5, reply->charge_event[d
    .seq].charge_event_mod[lcemcnt].field6 = cem.field6, reply->charge_event[d.seq].charge_event_mod[
    lcemcnt].field7 = cem.field7,
    reply->charge_event[d.seq].charge_event_mod[lcemcnt].field8 = cem.field8, reply->charge_event[d
    .seq].charge_event_mod[lcemcnt].field9 = cem.field9, reply->charge_event[d.seq].charge_event_mod[
    lcemcnt].field10 = cem.field10,
    reply->charge_event[d.seq].charge_event_mod[lcemcnt].field1_id = cem.field1_id, reply->
    charge_event[d.seq].charge_event_mod[lcemcnt].field2_id = cem.field2_id, reply->charge_event[d
    .seq].charge_event_mod[lcemcnt].field3_id = cem.field3_id,
    reply->charge_event[d.seq].charge_event_mod[lcemcnt].nomen_id = cem.nomen_id
   FOOT  cem.charge_event_id
    reply->charge_event[d.seq].charge_event_mod_qual = lcemcnt, stat = alterlist(reply->charge_event[
     d.seq].charge_event_mod,lcemcnt)
   WITH nocounter
  ;end select
  CALL echorecord(reply)
 ENDIF
#end_program
END GO
