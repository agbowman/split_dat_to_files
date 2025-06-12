CREATE PROGRAM dcp_get_ord_ings_from_disp_hx:dba
 SET modify = predeclare
 RECORD reply(
   1 order_id = f8
   1 action_sequence = i4
   1 iv_latest_core_action_sequence = i4
   1 catalog_cd = f8
   1 template_order_flag = i2
   1 med_order_type_cd = f8
   1 hna_order_mnemonic = vc
   1 ordered_as_mnemonic = vc
   1 order_mnemonic = vc
   1 ingred_qual[*]
     2 catalog_cd = f8
     2 freq_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 ingredient_type_flag = i2
     2 event_cd = f8
     2 form_cd = f8
     2 route_cnt = i4
     2 route_qual[*]
       3 route_cd = f8
     2 normalized_rate = f8
     2 normalized_rate_unit_cd = f8
     2 normalized_rate_unit_cd_disp = vc
     2 normalized_rate_unit_cd_desc = vc
     2 normalized_rate_unit_cd_mean = vc
     2 concentration = f8
     2 concentration_unit_cd = f8
     2 concentration_unit_cd_disp = vc
     2 concentration_unit_cd_desc = vc
     2 concentration_unit_cd_mean = vc
     2 ingredient_rate_conversion_ind = i2
     2 synonym_id = f8
     2 clinically_significant_flag = i2
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 order_mnemonic = vc
     2 catalog_cd_match_ind = i2
     2 display_additives_first_ind = i2
     2 synonym_qual[*]
       3 synonym_id = f8
     2 item_id = f8
     2 immunization_ind = i2
     2 waste_charge_ind = i2
   1 root_event_id = f8
   1 iv_ind = i2
   1 prn_ind = i2
   1 constant_ind = i2
   1 tnf_ind = i2
   1 latest_core_action_sequence = i4
   1 person_id = f8
   1 compatible_orders[*]
     2 order_id = f8
     2 template_order_id = f8
   1 elapsed_time = f8
   1 missing_single_diluent_list[*]
     2 order_id = f8
     2 template_order_id = f8
     2 diluent_event_cd = f8
     2 diluent_catalog_cd = f8
     2 diluent_ordered_as_mnemonic = vc
     2 diluent_hna_order_mnemonic = vc
     2 diluent_order_mnemonic = vc
   1 template_order_id = f8
   1 active_order_found_ind = i2
   1 inactive_order_found_ind = i2
   1 found_order_id = f8
   1 multi_found_ind = i2
   1 found_order_status = f8
   1 dosing_method_flag = i2
   1 disp_form_route_qual[*]
     2 route_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 order_cnt = i4
   1 order_qual[*]
     2 order_id = f8
     2 last_action_seq = i4
     2 action_cnt = i4
     2 template_order_id = f8
     2 med_order_type_cd = f8
     2 action_qual[*]
       3 action_sequence = i4
       3 route_cd = f8
       3 ingred_cnt = i4
       3 ingred_qual[*]
         4 catalog_cd = f8
         4 strength = f8
         4 strength_unit = f8
         4 volume = f8
         4 volume_unit = f8
         4 ingredient_type_flag = i2
         4 catalog_cd_match_ind = i2
         4 freq_cd = f8
         4 synonym_id = f8
 ) WITH protect
 RECORD comp_routes(
   1 route_qual[*]
     2 route_cd = f8
 ) WITH protect
 RECORD comp_order_actions(
   1 order_action_qual[*]
     2 order_id = f8
     2 action_sequence = i4
 ) WITH protect
 RECORD comp_diluent_order_actions(
   1 order_action_qual[*]
     2 order_id = f8
     2 action_sequence = i4
     2 event_cd = f8
     2 catalog_cd = f8
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 order_mnemonic = vc
 ) WITH protect
 RECORD temp_ingred_inds(
   1 array[*]
     2 ingred_found_ind = i2
 )
 FREE RECORD temp_itemids
 RECORD temp_itemids(
   1 itemqual[*]
     2 catalog_cd = f8
     2 item_pos = i4
     2 item_id = f8
     2 synonymqual[*]
       3 synonym_id = f8
 )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE overdue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE prn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE continuous_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE nonsched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE sched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"SCH"))
 DECLARE every_bag_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4004,"EVERYBAG"))
 DECLARE iv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE oe_field_meaning_id_route = f8 WITH protect, constant(2050.00)
 DECLARE oe_field_meaning_id_form = f8 WITH protect, constant(2014.00)
 DECLARE cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voided_wrslt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE medstudent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pending_ord_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE unscheduled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE iv_med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE csyspkgtyp = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE csystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE diluent_flag = i2 WITH protect, constant(2)
 DECLARE drugformdetail = i4 WITH protect, constant(2014)
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 DECLARE routedetail = i4 WITH protect, constant(2050)
 DECLARE ingred_cnt = i4 WITH protect, noconstant(0)
 DECLARE routecnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE md_cnt = i4 WITH protect, noconstant(0)
 DECLARE diluent_idx = i4 WITH protect, noconstant(0)
 DECLARE diluent_order_cnt = i4 WITH protect, noconstant(0)
 DECLARE dum_itr = i4 WITH protect, noconstant(0)
 DECLARE latestdrugformcd = f8 WITH protect, noconstant(0.0)
 DECLARE latestroutecd = f8 WITH protect, noconstant(0.0)
 DECLARE start_time = f8 WITH protect, noconstant(curtime3)
 DECLARE tnf_scan_clause = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE found = i4 WITH protect, noconstant(0)
 DECLARE match_cnt = i4 WITH protect, noconstant(0)
 DECLARE act_cnt = i4 WITH protect, noconstant(0)
 DECLARE ing_cnt = i4 WITH protect, noconstant(0)
 DECLARE oa_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE skipped_ingred_idx = i4 WITH protect, noconstant(0)
 DECLARE search_idx = i4 WITH protect, noconstant(0)
 DECLARE skipped_ingred_cnt = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE tnf_scan_across_order_id_pref = i2 WITH protect, noconstant(0)
 DECLARE mod_date = vc WITH private, noconstant("")
 DECLARE last_mod = c3 WITH private, noconstant("000")
 DECLARE order_info_ind = i2 WITH protect, noconstant(validate(request->order_info_ind,0))
 DECLARE check_mltm_syn_id_pref = i2 WITH protect, noconstant(0)
 DECLARE check_disp_syn_id_pref = i2 WITH protect, noconstant(0)
 DECLARE failed_to_match = i2 WITH protect, noconstant(0)
 DECLARE ingred_found = i2 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE temp = i2 WITH protect, noconstant(0)
 DECLARE bhassynonyms = i2 WITH protect, noconstant(0)
 DECLARE bhasitemids = i2 WITH protect, noconstant(0)
 DECLARE ireplysize = i4 WITH protect, noconstant(0)
 DECLARE itmpitemsize = i4 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE getpocprefs(null) = null
 DECLARE checkactionmissdiluent(order_idx=i4,action_idx=i4) = i4
 DECLARE checkforordersoutsidetimerange(null) = null
 DECLARE getsynonymsfromitem(null) = null
 DECLARE getmultumsynonymsfromitem(null) = null
 DECLARE getitemids(null) = null
 DECLARE populatereplysynonymids(null) = null
 DECLARE immunizationcheck(null) = null
 SELECT INTO "nl:"
  FROM dispense_hx dh,
   orders o
  PLAN (dh
   WHERE (dh.dispense_hx_id=request->dispense_hx_id))
   JOIN (o
   WHERE o.order_id=dh.order_id)
  DETAIL
   reply->dosing_method_flag = o.dosing_method_flag
   IF ((reply->dosing_method_flag=1))
    reply->order_id = o.order_id, reply->med_order_type_cd = o.med_order_type_cd, reply->
    hna_order_mnemonic = o.hna_order_mnemonic,
    reply->ordered_as_mnemonic = o.ordered_as_mnemonic, reply->order_mnemonic = o.order_mnemonic
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->dosing_method_flag=1))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dispense_hx dh,
   orders o,
   prod_dispense_hx pdh,
   order_ingredient oi,
   medication_definition md,
   route_form_r rfr,
   code_value_event_r cve,
   order_catalog_synonym ocs
  PLAN (dh
   WHERE (dh.dispense_hx_id=request->dispense_hx_id))
   JOIN (o
   WHERE o.order_id=dh.order_id)
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id)
   JOIN (oi
   WHERE oi.order_id=dh.order_id
    AND (oi.action_sequence=
   (SELECT
    max(oi2.action_sequence)
    FROM order_ingredient oi2
    WHERE oi2.order_id=dh.order_id
     AND oi2.action_sequence <= dh.action_sequence))
    AND oi.comp_sequence=pdh.ingred_sequence
    AND oi.ingredient_type_flag != icompoundchild)
   JOIN (md
   WHERE md.item_id=pdh.item_id)
   JOIN (rfr
   WHERE rfr.form_cd=outerjoin(md.form_cd))
   JOIN (cve
   WHERE cve.parent_cd=outerjoin(oi.catalog_cd))
   JOIN (ocs
   WHERE ocs.synonym_id=oi.synonym_id)
  ORDER BY oi.comp_sequence
  HEAD REPORT
   ingred_cnt = 0, reply->order_id = dh.order_id, reply->action_sequence = dh.action_sequence,
   reply->catalog_cd = o.catalog_cd, reply->template_order_flag = o.template_order_flag, reply->
   med_order_type_cd = o.med_order_type_cd,
   reply->hna_order_mnemonic = o.hna_order_mnemonic, reply->ordered_as_mnemonic = o
   .ordered_as_mnemonic, reply->order_mnemonic = o.order_mnemonic,
   reply->iv_ind = o.iv_ind, reply->prn_ind = o.prn_ind, reply->constant_ind = o.constant_ind,
   reply->person_id = o.person_id, reply->template_order_id = o.template_order_id
  HEAD oi.comp_sequence
   routecnt = 0, ingred_cnt = (ingred_cnt+ 1)
   IF (ingred_cnt > size(reply->ingred_qual,5))
    stat = alterlist(reply->ingred_qual,(ingred_cnt+ 5))
   ENDIF
   reply->ingred_qual[ingred_cnt].catalog_cd = oi.catalog_cd, reply->ingred_qual[ingred_cnt].
   synonym_id = oi.synonym_id, reply->ingred_qual[ingred_cnt].freq_cd = oi.freq_cd,
   reply->ingred_qual[ingred_cnt].strength = oi.strength, reply->ingred_qual[ingred_cnt].
   strength_unit_cd = oi.strength_unit, reply->ingred_qual[ingred_cnt].volume = oi.volume,
   reply->ingred_qual[ingred_cnt].volume_unit_cd = oi.volume_unit, reply->ingred_qual[ingred_cnt].
   ingredient_type_flag = oi.ingredient_type_flag, reply->ingred_qual[ingred_cnt].event_cd = cve
   .event_cd,
   reply->ingred_qual[ingred_cnt].form_cd = md.form_cd, reply->ingred_qual[ingred_cnt].
   normalized_rate = oi.normalized_rate, reply->ingred_qual[ingred_cnt].normalized_rate_unit_cd = oi
   .normalized_rate_unit_cd,
   reply->ingred_qual[ingred_cnt].concentration = oi.concentration, reply->ingred_qual[ingred_cnt].
   concentration_unit_cd = oi.concentration_unit_cd, reply->ingred_qual[ingred_cnt].
   ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
   reply->ingred_qual[ingred_cnt].clinically_significant_flag = oi.clinically_significant_flag, reply
   ->ingred_qual[ingred_cnt].order_mnemonic = oi.order_mnemonic, reply->ingred_qual[ingred_cnt].
   ordered_as_mnemonic = oi.ordered_as_mnemonic,
   reply->ingred_qual[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->ingred_qual[
   ingred_cnt].waste_charge_ind = evaluate(validate(pdh.waste_flag,0),1,1,0)
   IF (validate(ocs.display_additives_first_ind))
    reply->ingred_qual[ingred_cnt].display_additives_first_ind = ocs.display_additives_first_ind
   ENDIF
   IF (ocs.orderable_type_flag=10)
    reply->tnf_ind = 1
   ENDIF
   reply->ingred_qual[ingred_cnt].item_id = md.item_id
  DETAIL
   IF (rfr.route_cd > 0)
    routecnt = (routecnt+ 1)
    IF (routecnt > size(reply->ingred_qual[ingred_cnt].route_qual,5))
     stat = alterlist(reply->ingred_qual[ingred_cnt].route_qual,(routecnt+ 5))
    ENDIF
    reply->ingred_qual[ingred_cnt].route_qual[routecnt].route_cd = rfr.route_cd
   ENDIF
  FOOT  oi.comp_sequence
   stat = alterlist(reply->ingred_qual[ingred_cnt].route_qual,routecnt), reply->ingred_qual[
   ingred_cnt].route_cnt = routecnt
  FOOT REPORT
   stat = alterlist(reply->ingred_qual,ingred_cnt)
  WITH nocounter
 ;end select
 IF (ingred_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF ((((reply->iv_ind=1)) OR ((((reply->prn_ind=1)) OR ((reply->constant_ind=1))) )) )
  SELECT INTO "nl:"
   FROM order_detail od
   WHERE (od.order_id=reply->order_id)
    AND (od.action_sequence=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=od.oe_field_id
     AND (od2.action_sequence <= reply->action_sequence)))
    AND od.oe_field_meaning_id IN (drugformdetail, routedetail)
   DETAIL
    IF (od.oe_field_meaning_id=drugformdetail)
     latestdrugformcd = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=routedetail)
     latestroutecd = od.oe_field_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM order_action oa,
    order_ingredient oi,
    order_detail od
   PLAN (oa
    WHERE (oa.order_id=reply->order_id)
     AND (oa.action_sequence >= reply->action_sequence)
     AND oa.core_ind=1)
    JOIN (oi
    WHERE oi.order_id=oa.order_id
     AND oi.action_sequence=oa.action_sequence
     AND oi.ingredient_type_flag != icompoundchild)
    JOIN (od
    WHERE od.order_id=outerjoin(oi.order_id)
     AND od.action_sequence=outerjoin(oi.action_sequence))
   ORDER BY oa.action_sequence, oi.comp_sequence
   HEAD REPORT
    ingred_cnt = 0, failed_to_match = 0
   HEAD oa.action_sequence
    ingred_cnt = 0, reply->iv_latest_core_action_sequence = oa.action_sequence, reply->
    latest_core_action_sequence = oa.action_sequence
   HEAD oi.comp_sequence
    IF (failed_to_match=0)
     ingred_cnt = (ingred_cnt+ 1), ingred_found = 0
     FOR (cnt = 1 TO size(reply->ingred_qual,5))
       IF ((reply->ingred_qual[cnt].catalog_cd=oi.catalog_cd))
        ingred_found = 1
        IF ((reply->ingred_qual[cnt].strength > 0)
         AND (reply->ingred_qual[cnt].strength_unit_cd > 0))
         IF ((reply->ingred_qual[cnt].strength != oi.strength))
          failed_to_match = 1
         ELSEIF ((reply->ingred_qual[cnt].strength_unit_cd != oi.strength_unit))
          failed_to_match = 1
         ENDIF
        ELSE
         IF ((reply->ingred_qual[cnt].volume != oi.volume))
          failed_to_match = 1
         ELSEIF ((reply->ingred_qual[cnt].volume_unit_cd != oi.volume_unit))
          failed_to_match = 1
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (ingred_found=0)
      IF (oi.freq_cd=every_bag_cd)
       failed_to_match = 1
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    IF (failed_to_match=0)
     IF (od.oe_field_meaning_id=drugformdetail)
      IF (latestdrugformcd > 0
       AND od.oe_field_value > 0
       AND latestdrugformcd != od.oe_field_value)
       failed_to_match = 1
      ENDIF
     ELSEIF (od.oe_field_meaning_id=routedetail)
      IF (latestroutecd > 0
       AND od.oe_field_value > 0
       AND latestroutecd != od.oe_field_value)
       failed_to_match = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  oi.comp_sequence
    temp = 0
   FOOT  oa.action_sequence
    IF (failed_to_match=0)
     IF (size(reply->ingred_qual,5) > ingred_cnt)
      failed_to_match = 1
     ENDIF
     IF (failed_to_match=0)
      reply->action_sequence = oa.action_sequence
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE icompatibleroutescnt = i4 WITH protect, noconstant(0)
 DECLARE dorderformcd = f8 WITH protect, noconstant(0)
 SET stat = alterlist(comp_routes->route_qual,1)
 SET stat = alterlist(reply->disp_form_route_qual,1)
 SELECT DISTINCT INTO "nl:"
  od.oe_field_meaning_id, od.action_sequence, od.oe_field_value
  FROM dispense_hx dh,
   order_detail od
  PLAN (dh
   WHERE (dh.dispense_hx_id=request->dispense_hx_id))
   JOIN (od
   WHERE od.order_id=dh.order_id
    AND od.oe_field_meaning_id IN (oe_field_meaning_id_route, oe_field_meaning_id_form)
    AND (od.action_sequence <=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=od.oe_field_id
     AND od2.action_sequence <= dh.action_sequence)))
  ORDER BY od.oe_field_meaning_id, od.action_sequence DESC
  HEAD od.oe_field_meaning_id
   IF (oe_field_meaning_id_route=od.oe_field_meaning_id)
    icompatibleroutescnt = (icompatibleroutescnt+ 1), comp_routes->route_qual[icompatibleroutescnt].
    route_cd = od.oe_field_value, reply->disp_form_route_qual[icompatibleroutescnt].route_cd = od
    .oe_field_value
   ELSEIF (oe_field_meaning_id_form=od.oe_field_meaning_id)
    dorderformcd = od.oe_field_value
   ENDIF
  FOOT REPORT
   IF (validate(debug_ind)
    AND debug_ind > 0)
    CALL echo(build(build("*** Dispense Order Form Cd = ",dorderformcd),build(" ",
      uar_get_code_display(dorderformcd)))),
    CALL echorecord(comp_routes)
   ENDIF
  WITH nocounter
 ;end select
 IF (dorderformcd > 0)
  SELECT DISTINCT INTO "nl:"
   r.route_cd
   FROM route_form_r r
   WHERE r.form_cd=dorderformcd
    AND r.route_cd != 0
   DETAIL
    icompatibleroutescnt = (icompatibleroutescnt+ 1)
    IF (mod(icompatibleroutescnt,10)=2)
     stat = alterlist(comp_routes->route_qual,(icompatibleroutescnt+ 9)), stat = alterlist(reply->
      disp_form_route_qual,(icompatibleroutescnt+ 9))
    ENDIF
    comp_routes->route_qual[icompatibleroutescnt].route_cd = r.route_cd, reply->disp_form_route_qual[
    icompatibleroutescnt].route_cd = r.route_cd
    IF (validate(debug_ind)
     AND debug_ind > 0)
     CALL echo(build("**** Compatible Route: ",comp_routes->route_qual[icompatibleroutescnt].route_cd
      ))
    ENDIF
   FOOT REPORT
    stat = alterlist(comp_routes->route_qual,icompatibleroutescnt), stat = alterlist(reply->
     disp_form_route_qual,icompatibleroutescnt)
    IF (validate(debug_ind)
     AND debug_ind > 0)
     CALL echorecord(comp_routes)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE lordercnt = i4 WITH protect, noconstant(0)
 RECORD compat_orders(
   1 order_list[*]
     2 order_id = f8
 ) WITH protect
 IF (icompatibleroutescnt > 0)
  CALL getpocprefs(null)
  IF ((reply->tnf_ind=1))
   IF (tnf_scan_across_order_id_pref=0)
    SET tnf_scan_clause = "o.order_id = reply->order_id"
   ELSE
    SET tnf_scan_clause = "0 = 0"
   ENDIF
  ELSE
   SET tnf_scan_clause = "0 = 0"
  ENDIF
  SELECT INTO "nl:"
   FROM code_value cv,
    task_activity ta
   PLAN (cv
    WHERE cv.code_set=6026
     AND cv.cdf_meaning IN ("MED", "IV"))
    JOIN (ta
    WHERE (ta.person_id=reply->person_id)
     AND ta.task_status_cd IN (pending_cd, overdue_cd)
     AND ta.task_class_cd IN (prn_cd, continuous_cd, nonsched_cd)
     AND ta.task_type_cd=cv.code_value)
   HEAD ta.order_id
    lordercnt = (lordercnt+ 1), stat = alterlist(compat_orders->order_list,lordercnt), compat_orders
    ->order_list[lordercnt].order_id = ta.order_id
   WITH nocounter
  ;end select
  IF (check_disp_syn_id_pref=1)
   SET ireplysize = size(reply->ingred_qual,5)
   CALL getitemids(null)
   IF (bhasitemids=1)
    CALL getsynonymsfromitem(null)
    IF (bhassynonyms=0
     AND check_mltm_syn_id_pref=1)
     CALL getmultumsynonymsfromitem(null)
    ENDIF
    CALL populatereplysynonymids(null)
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM code_value cv,
    task_activity ta,
    orders o1,
    orders o2
   PLAN (cv
    WHERE cv.code_set=6026
     AND cv.cdf_meaning IN ("MED", "IV"))
    JOIN (ta
    WHERE (ta.person_id=reply->person_id)
     AND ta.task_status_cd IN (pending_cd, overdue_cd)
     AND ta.task_class_cd=sched_cd
     AND ta.task_type_cd=cv.code_value)
    JOIN (o1
    WHERE o1.order_id=ta.order_id)
    JOIN (o2
    WHERE o2.order_id=o1.template_order_id
     AND o2.dosing_method_flag=0)
   ORDER BY ta.order_id
   HEAD ta.order_id
    lordercnt = (lordercnt+ 1), stat = alterlist(compat_orders->order_list,lordercnt)
    IF (o1.template_order_id > 0)
     compat_orders->order_list[lordercnt].order_id = o1.template_order_id
    ELSE
     compat_orders->order_list[lordercnt].order_id = ta.order_id
    ENDIF
   WITH nocounter
  ;end select
  IF (lordercnt > 0)
   DECLARE nsize = i4 WITH protect, constant(40)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(lordercnt)/ nsize)) * nsize))
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE synonym_idx = i4 WITH protect, noconstant(0)
   DECLARE found_route = i2 WITH protect, noconstant(0)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE xord = i4 WITH protect, noconstant(0)
   SET stat = alterlist(compat_orders->order_list,ntotal)
   FOR (i = (lordercnt+ 1) TO ntotal)
     SET compat_orders->order_list[i].order_id = compat_orders->order_list[lordercnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     order_action oa,
     order_detail od,
     order_ingredient oi
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(xord,nstart,(nstart+ (nsize - 1)),o.order_id,compat_orders->order_list[xord].
      order_id)
      AND parser(tnf_scan_clause))
     JOIN (oa
     WHERE oa.order_id=o.order_id)
     JOIN (od
     WHERE od.order_id=oa.order_id
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=oa.order_id
       AND od2.action_sequence <= oa.action_sequence
       AND od2.oe_field_meaning_id=routedetail))
      AND od.oe_field_meaning_id=routedetail)
     JOIN (oi
     WHERE oi.order_id=oa.order_id
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=oa.order_id
       AND oi2.action_sequence <= oa.action_sequence))
      AND oi.ingredient_type_flag != icompoundchild)
    ORDER BY o.order_id, oa.action_sequence, od.action_sequence,
     oi.comp_sequence
    HEAD REPORT
     lordercnt = 0
    HEAD o.order_id
     lordercnt = (lordercnt+ 1), stat = alterlist(internal->order_qual,lordercnt), internal->
     order_qual[lordercnt].order_id = o.order_id,
     internal->order_qual[lordercnt].last_action_seq = o.last_action_sequence, internal->order_qual[
     lordercnt].template_order_id = o.template_order_id, internal->order_qual[lordercnt].
     med_order_type_cd = o.med_order_type_cd,
     act_cnt = 0
    HEAD oa.action_sequence
     route_cd = 0, ing_cnt = 0
    HEAD od.order_id
     route_cd = od.oe_field_value, found_route = 0
     FOR (rcnt = 1 TO icompatibleroutescnt)
       IF ((route_cd=comp_routes->route_qual[rcnt].route_cd))
        act_cnt = (act_cnt+ 1)
        IF (mod(act_cnt,10)=1)
         stat = alterlist(internal->order_qual[lordercnt].action_qual,(act_cnt+ 9))
        ENDIF
        internal->order_qual[lordercnt].action_qual[act_cnt].action_sequence = oa.action_sequence,
        internal->order_qual[lordercnt].action_qual[act_cnt].route_cd = route_cd, found_route = 1,
        rcnt = icompatibleroutescnt
       ENDIF
     ENDFOR
    HEAD oi.comp_sequence
     IF (found_route=1)
      ing_cnt = (ing_cnt+ 1)
      IF (mod(ing_cnt,10)=1)
       stat = alterlist(internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual,(ing_cnt+ 9)
        )
      ENDIF
      internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].catalog_cd = oi
      .catalog_cd, internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].strength
       = oi.strength, internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].
      strength_unit = oi.strength_unit,
      internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].volume = oi.volume,
      internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].volume_unit = oi
      .volume_unit, internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].
      ingredient_type_flag = oi.ingredient_type_flag,
      internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].freq_cd = oi.freq_cd,
      internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual[ing_cnt].synonym_id = oi
      .synonym_id
     ENDIF
    FOOT  oa.action_sequence
     IF (found_route=1)
      stat = alterlist(internal->order_qual[lordercnt].action_qual[act_cnt].ingred_qual,ing_cnt),
      internal->order_qual[lordercnt].action_qual[act_cnt].ingred_cnt = ing_cnt
     ENDIF
    FOOT  o.order_id
     stat = alterlist(internal->order_qual[lordercnt].action_qual,act_cnt), internal->order_qual[
     lordercnt].action_cnt = act_cnt
     IF (act_cnt=0)
      lordercnt = (lordercnt - 1), stat = alterlist(internal->order_qual,lordercnt)
     ENDIF
    FOOT REPORT
     internal->order_cnt = lordercnt
    WITH nocounter
   ;end select
  ENDIF
  DECLARE ordidx = i4 WITH protect, noconstant(0)
  DECLARE oactidx = i4 WITH protect, noconstant(0)
  DECLARE oingidx = i4 WITH protect, noconstant(0)
  DECLARE singidx = i4 WITH protect, noconstant(0)
  DECLARE sizerepsynqual = i4 WITH protect, noconstant(0)
  FOR (ordidx = 1 TO internal->order_cnt)
    FOR (oactidx = 1 TO internal->order_qual[ordidx].action_cnt)
     IF ((request->qual_miss_diluent_ind=1)
      AND ((internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt+ 1)=ingred_cnt))
      SET diluent_idx = checkactionmissdiluent(ordidx,oactidx)
     ENDIF
     IF ((((internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt >= ingred_cnt)) OR (
     diluent_idx > 0)) )
      SET match_cnt = 0
      SET skipped_ingred_cnt = 0
      FOR (oingidx = 1 TO internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt)
       SET internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].
       catalog_cd_match_ind = 0
       FOR (singidx = 1 TO ingred_cnt)
         SET search_idx = 0
         SET sizerepsynqual = size(reply->ingred_qual[singidx].synonym_qual,5)
         IF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].catalog_cd=reply
         ->ingred_qual[singidx].catalog_cd))
          IF (size(reply->ingred_qual[singidx].synonym_qual,5) > 0)
           SET synonym_idx = locateval(search_idx,start,sizerepsynqual,internal->order_qual[ordidx].
            action_qual[oactidx].ingred_qual[oingidx].synonym_id,reply->ingred_qual[singidx].
            synonym_qual[search_idx].synonym_id)
           IF (synonym_idx > 0)
            SET internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].
            catalog_cd_match_ind = 1
           ELSE
            SET internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].
            catalog_cd_match_ind = 0
           ENDIF
          ELSE
           SET internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].
           catalog_cd_match_ind = 1
          ENDIF
          IF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].
          catalog_cd_match_ind=1))
           IF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength > 0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength_unit
            > 0)
            AND (reply->ingred_qual[singidx].strength > 0)
            AND (reply->ingred_qual[singidx].strength_unit_cd > 0))
            IF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength=
            reply->ingred_qual[singidx].strength)
             AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].
            strength_unit=reply->ingred_qual[singidx].strength_unit_cd))
             IF ((((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume=0))
              OR ((((reply->ingred_qual[singidx].volume=0)) OR ((internal->order_qual[ordidx].
             action_qual[oactidx].ingred_qual[oingidx].volume=reply->ingred_qual[singidx].volume)
              AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume_unit
             =reply->ingred_qual[singidx].volume_unit_cd))) )) )
              CALL echo("Strength/strength unit and volume/volume units are equal")
              SET match_cnt = (match_cnt+ 1)
             ELSE
              CALL echo("Strength/strength units are equal but volume/volume units are not equal")
             ENDIF
            ELSE
             CALL echo("Strength/strength units are not equal")
            ENDIF
           ELSEIF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume > 0
           )
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume_unit
            > 0)
            AND (reply->ingred_qual[singidx].strength > 0)
            AND (reply->ingred_qual[singidx].strength_unit_cd > 0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume=reply
           ->ingred_qual[singidx].strength)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume_unit=
           reply->ingred_qual[singidx].strength_unit_cd))
            SET match_cnt = (match_cnt+ 1)
            CALL echo("Ordered volume/volume unit equal to dispense strength/strength unit")
           ELSEIF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength
            > 0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength_unit
            > 0)
            AND (reply->ingred_qual[singidx].volume > 0)
            AND (reply->ingred_qual[singidx].volume_unit_cd > 0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength=
           reply->ingred_qual[singidx].volume)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength_unit
           =reply->ingred_qual[singidx].volume_unit_cd))
            SET match_cnt = (match_cnt+ 1)
            CALL echo("Ordered strength/strength unit equal to dispense volume/volume unit")
           ELSEIF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength=0
           )
            AND (reply->ingred_qual[singidx].strength=0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume > 0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume_unit
            > 0)
            AND (reply->ingred_qual[singidx].volume > 0)
            AND (reply->ingred_qual[singidx].volume_unit_cd > 0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume=reply
           ->ingred_qual[singidx].volume)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume_unit=
           reply->ingred_qual[singidx].volume_unit_cd))
            SET match_cnt = (match_cnt+ 1)
            CALL echo("Only volumes are equal")
           ELSEIF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength=0
           )
            AND (reply->ingred_qual[singidx].strength=0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume=0)
            AND (reply->ingred_qual[singidx].volume=0)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].strength_unit
           =reply->ingred_qual[singidx].strength_unit_cd)
            AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[oingidx].volume_unit=
           reply->ingred_qual[singidx].volume_unit_cd))
            SET match_cnt = (match_cnt+ 1)
            CALL echo("No strength or volume - units match, retain for freetext")
           ELSE
            CALL echo("No match")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDFOR
      IF ((match_cnt < internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt)
       AND match_cnt=ingred_cnt
       AND (internal->order_qual[ordidx].med_order_type_cd=iv_cd))
       SET start = 0
       FOR (dum_itr = 1 TO (internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt - match_cnt)
        )
         SET skipped_ingred_idx = locateval(search_idx,start,internal->order_qual[ordidx].
          action_qual[oactidx].ingred_cnt,0,internal->order_qual[ordidx].action_qual[oactidx].
          ingred_qual[search_idx].catalog_cd_match_ind)
         IF (skipped_ingred_idx > 0
          AND (internal->order_qual[ordidx].action_qual[oactidx].ingred_qual[skipped_ingred_idx].
         freq_cd != every_bag_cd))
          SET skipped_ingred_cnt = (skipped_ingred_cnt+ 1)
         ENDIF
         SET start = (skipped_ingred_idx+ 1)
       ENDFOR
      ENDIF
      IF (match_cnt=ingred_cnt
       AND (match_cnt=internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt))
       CALL echo(build("Adding Complete Match Order, Order #: ",internal->order_qual[ordidx].order_id
         ))
       SET oa_cnt = (oa_cnt+ 1)
       IF (mod(oa_cnt,10)=1)
        SET stat = alterlist(comp_order_actions->order_action_qual,(oa_cnt+ 9))
       ENDIF
       SET comp_order_actions->order_action_qual[oa_cnt].order_id = internal->order_qual[ordidx].
       order_id
       SET comp_order_actions->order_action_qual[oa_cnt].action_sequence = internal->order_qual[
       ordidx].action_qual[oactidx].action_sequence
       IF ((internal->order_qual[ordidx].action_qual[oactidx].action_sequence=internal->order_qual[
       ordidx].last_action_seq))
        SET order_cnt = (order_cnt+ 1)
        IF (mod(order_cnt,10)=1)
         SET stat = alterlist(reply->compatible_orders,(order_cnt+ 9))
        ENDIF
        SET reply->compatible_orders[order_cnt].order_id = internal->order_qual[ordidx].order_id
       ENDIF
      ELSEIF (diluent_idx > 0
       AND (match_cnt=internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt))
       CALL echo(build("Adding Missing Diluent Order, Order #: ",internal->order_qual[ordidx].
         order_id))
       SET md_cnt = (md_cnt+ 1)
       IF (mod(md_cnt,10)=1)
        SET stat = alterlist(comp_diluent_order_actions->order_action_qual,(md_cnt+ 9))
       ENDIF
       SET comp_diluent_order_actions->order_action_qual[md_cnt].order_id = internal->order_qual[
       ordidx].order_id
       SET comp_diluent_order_actions->order_action_qual[md_cnt].action_sequence = internal->
       order_qual[ordidx].action_qual[oactidx].action_sequence
       SET comp_diluent_order_actions->order_action_qual[md_cnt].event_cd = reply->ingred_qual[
       diluent_idx].event_cd
       SET comp_diluent_order_actions->order_action_qual[md_cnt].catalog_cd = reply->ingred_qual[
       diluent_idx].catalog_cd
       SET comp_diluent_order_actions->order_action_qual[md_cnt].order_mnemonic = reply->ingred_qual[
       diluent_idx].order_mnemonic
       SET comp_diluent_order_actions->order_action_qual[md_cnt].ordered_as_mnemonic = reply->
       ingred_qual[diluent_idx].ordered_as_mnemonic
       SET comp_diluent_order_actions->order_action_qual[md_cnt].hna_order_mnemonic = reply->
       ingred_qual[diluent_idx].hna_order_mnemonic
      ELSEIF ((internal->order_qual[ordidx].action_qual[oactidx].ingred_cnt=(skipped_ingred_cnt+
      match_cnt)))
       CALL echo(build("Adding non Every Bag Order, Order #: ",internal->order_qual[ordidx].order_id)
        )
       SET oa_cnt = (oa_cnt+ 1)
       IF (mod(oa_cnt,10)=1)
        SET stat = alterlist(comp_order_actions->order_action_qual,(oa_cnt+ 9))
       ENDIF
       SET comp_order_actions->order_action_qual[oa_cnt].order_id = internal->order_qual[ordidx].
       order_id
       SET comp_order_actions->order_action_qual[oa_cnt].action_sequence = internal->order_qual[
       ordidx].action_qual[oactidx].action_sequence
       IF ((internal->order_qual[ordidx].action_qual[oactidx].action_sequence=internal->order_qual[
       ordidx].last_action_seq))
        SET order_cnt = (order_cnt+ 1)
        IF (mod(order_cnt,10)=1)
         SET stat = alterlist(reply->compatible_orders,(order_cnt+ 9))
        ENDIF
        SET reply->compatible_orders[order_cnt].order_id = internal->order_qual[ordidx].order_id
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(comp_order_actions->order_action_qual,oa_cnt)
  SET stat = alterlist(comp_diluent_order_actions->order_action_qual,md_cnt)
  IF (oa_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(oa_cnt)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.template_order_id=comp_order_actions->order_action_qual[d.seq].order_id)
      AND ((o.template_core_action_sequence+ 0)=comp_order_actions->order_action_qual[d.seq].
     action_sequence)
      AND ((o.hide_flag+ 0) IN (null, 0)))
    HEAD o.order_id
     order_cnt = (order_cnt+ 1)
     IF (mod(order_cnt,10)=1)
      stat = alterlist(reply->compatible_orders,(order_cnt+ 9))
     ENDIF
     reply->compatible_orders[order_cnt].order_id = o.order_id, reply->compatible_orders[order_cnt].
     template_order_id = o.template_order_id
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->compatible_orders,order_cnt)
  IF (md_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(md_cnt)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.template_order_id=comp_diluent_order_actions->order_action_qual[d.seq].order_id)
      AND ((o.template_core_action_sequence+ 0) <= reply->action_sequence)
      AND ((o.template_core_action_sequence+ 0)=comp_diluent_order_actions->order_action_qual[d.seq].
     action_sequence)
      AND ((o.template_order_id+ 0) > 0)
      AND ((o.hide_flag+ 0) IN (null, 0)))
    HEAD o.order_id
     diluent_order_cnt = (diluent_order_cnt+ 1)
     IF (mod(diluent_order_cnt,10)=1)
      stat = alterlist(reply->missing_single_diluent_list,(order_cnt+ 9))
     ENDIF
     reply->missing_single_diluent_list[diluent_order_cnt].order_id = o.order_id, reply->
     missing_single_diluent_list[diluent_order_cnt].template_order_id = o.template_order_id, reply->
     missing_single_diluent_list[diluent_order_cnt].diluent_event_cd = comp_diluent_order_actions->
     order_action_qual[d.seq].event_cd,
     reply->missing_single_diluent_list[diluent_order_cnt].diluent_catalog_cd =
     comp_diluent_order_actions->order_action_qual[d.seq].catalog_cd, reply->
     missing_single_diluent_list[diluent_order_cnt].diluent_hna_order_mnemonic =
     comp_diluent_order_actions->order_action_qual[d.seq].hna_order_mnemonic, reply->
     missing_single_diluent_list[diluent_order_cnt].diluent_order_mnemonic =
     comp_diluent_order_actions->order_action_qual[d.seq].order_mnemonic,
     reply->missing_single_diluent_list[diluent_order_cnt].diluent_ordered_as_mnemonic =
     comp_diluent_order_actions->order_action_qual[d.seq].ordered_as_mnemonic
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->missing_single_diluent_list,diluent_order_cnt)
  IF (order_info_ind=1)
   CALL checkforordersoutsidetimerange(null)
  ENDIF
 ENDIF
 CALL immunizationcheck(null)
 SUBROUTINE checkactionmissdiluent(order_idx,action_idx)
   DECLARE miss_diluent_idx = i4 WITH protect, noconstant(0)
   DECLARE match_action_ingred_idx = i4 WITH protect, noconstant(0)
   DECLARE scan_ing_it = i4 WITH protect, noconstant(0)
   FOR (scan_ing_it = 1 TO ingred_cnt)
    SET match_action_ingred_idx = locateval(search_idx,1,internal->order_qual[order_idx].action_qual[
     action_idx].ingred_cnt,reply->ingred_qual[scan_ing_it].catalog_cd,internal->order_qual[order_idx
     ].action_qual[action_idx].ingred_qual[search_idx].catalog_cd)
    IF (match_action_ingred_idx=0)
     IF ((reply->ingred_qual[scan_ing_it].ingredient_type_flag=diluent_flag)
      AND miss_diluent_idx=0)
      SET miss_diluent_idx = scan_ing_it
     ELSE
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(miss_diluent_idx)
 END ;Subroutine
 SUBROUTINE getpocprefs(null)
   CALL echo("dcp_get_ord_ings_from_disp_hx - ****** Entering GetPOCPrefs Subroutine ******")
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   SET tnf_scan_across_order_id_pref = 1
   SET check_disp_syn_id_pref = 0
   SET check_mltm_syn_id_pref = 0
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL echo("bad hPref, try logging in")
   ELSE
    SET status = uar_prefaddcontext(hpref,"default","system")
    IF (status != 1)
     CALL echo("bad context")
    ELSE
     SET status = uar_prefsetsection(hpref,"component")
     IF (status != 1)
      CALL echo("bad section")
     ELSE
      SET hgroup = uar_prefcreategroup()
      SET status = uar_prefsetgroupname(hgroup,"pocscanningpolicies")
      IF (status != 1)
       CALL echo("bad group name")
      ELSE
       SET status = uar_prefaddgroup(hpref,hgroup)
       SET status = uar_prefperform(hpref)
       SET hsection = uar_prefgetsectionbyname(hpref,"component")
       SET hgroup2 = uar_prefgetgroupbyname(hsection,"pocscanningpolicies")
       SET entrycount = 0
       SET status = uar_prefgetgroupentrycount(hgroup2,entrycount)
       IF (validate(debug_ind)
        AND debug_ind > 0)
        CALL echo(build("entry count:",entrycount))
       ENDIF
       SET idxentry = 0
       DECLARE entryname = c100
       DECLARE namelen = i4 WITH noconstant(100)
       FOR (idxentry = 0 TO (entrycount - 1))
         SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
         SET namelen = 100
         SET entryname = ""
         SET status = uar_prefgetentryname(hentry,entryname,namelen)
         IF (validate(debug_ind)
          AND debug_ind > 0)
          CALL echo(build("entry name: ",entryname))
         ENDIF
         SET attrcount = 0
         SET status = uar_prefgetentryattrcount(hentry,attrcount)
         IF (status != 1)
          CALL echo("bad entryAttrCount")
         ELSE
          IF (validate(debug_ind)
           AND debug_ind > 0)
           CALL echo(build("attrCount:",attrcount))
          ENDIF
          SET idxattr = 0
          FOR (idxattr = 0 TO (attrcount - 1))
            SET hattr = uar_prefgetentryattr(hentry,idxattr)
            IF (validate(debug_ind)
             AND debug_ind > 0)
             CALL echo(build("hAttr:",hattr))
            ENDIF
            DECLARE attrname = c100
            SET namelen = 100
            SET status = uar_prefgetattrname(hattr,attrname,namelen)
            IF (validate(debug_ind)
             AND debug_ind > 0)
             CALL echo(build("   attribute name: ",attrname))
            ENDIF
            SET valcount = 0
            SET status = uar_prefgetattrvalcount(hattr,valcount)
            SET idxval = 0
            FOR (idxval = 0 TO (valcount - 1))
              DECLARE valname = c100
              SET namelen = 100
              SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
              IF (validate(debug_ind)
               AND debug_ind > 0)
               CALL echo(build("      val:",valname))
              ENDIF
              IF (cnvtupper(trim(entryname,3))="TNF_SCAN_ACROSS_ORDER_ID")
               SET tnf_scan_across_order_id_pref = cnvtint(trim(valname,3))
              ELSEIF (cnvtupper(trim(entryname,3))="CHECK_DISP_SYN_ID")
               SET check_disp_syn_id_pref = cnvtint(trim(valname,3))
              ELSEIF (cnvtupper(trim(entryname,3))="USE_MLTM_SYN_MATCH")
               SET check_mltm_syn_id_pref = cnvtint(trim(valname,3))
              ENDIF
            ENDFOR
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("TNF_SCAN_ACROSS_ORDER_ID preference = ",tnf_scan_across_order_id_pref))
   CALL echo("dcp_get_ord_ings_from_disp_hx - ****** Exiting GetPOCPrefs Subroutine ******")
 END ;Subroutine
 SUBROUTINE checkforordersoutsidetimerange(null)
   DECLARE start_time_func = f8 WITH private, noconstant(curtime3)
   DECLARE elapsed_time_func = f8 WITH private, noconstant(0.0)
   DECLARE imatchcnt = i4 WITH protect, noconstant(0)
   DECLARE inactiveordseqind = i2 WITH protect, noconstant(0)
   DECLARE iscannedingredcnt = i4 WITH protect, noconstant(size(reply->ingred_qual,5))
   DECLARE lingredidx = i4 WITH protect, noconstant(0)
   DECLARE ingredmatchind = i2 WITH protect, noconstant(0)
   DECLARE iunmatcheddiluentcnt = i4 WITH protect, noconstant(0)
   DECLARE ienc = i4 WITH protect, noconstant(0)
   DECLARE iencsize = i4 WITH protect, noconstant(size(request->encntr_list,5))
   DECLARE iordingreds = i4 WITH protect, noconstant(0)
   DECLARE iallscannedingredsfound = i2 WITH noconstant(0)
   DECLARE syncnt = i4 WITH protect, noconstant(0)
   DECLARE synidx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(temp_ingred_inds->array,iscannedingredcnt)
   SELECT
    IF (iencsize > 0)
     PLAN (o
      WHERE (o.person_id=reply->person_id)
       AND expand(ienc,1,iencsize,(o.encntr_id+ 0),request->encntr_list[ienc].encntr_id)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND ((o.projected_stop_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (1))) OR (o
      .projected_stop_dt_tm=null)) )
      JOIN (oi
      WHERE oi.order_id=o.order_id)
      JOIN (ocs
      WHERE ocs.synonym_id=oi.synonym_id)
    ELSE
     PLAN (o
      WHERE (o.person_id=reply->person_id)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.template_order_flag IN (0, 1)
       AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
      13))
       AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
       AND ((o.projected_stop_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (1))) OR (o
      .projected_stop_dt_tm=null)) )
      JOIN (oi
      WHERE oi.order_id=o.order_id)
      JOIN (ocs
      WHERE ocs.synonym_id=oi.synonym_id)
    ENDIF
    INTO "nl:"
    FROM orders o,
     order_ingredient oi,
     order_catalog_synonym ocs
    ORDER BY oi.order_id, oi.action_sequence DESC
    HEAD REPORT
     imatchcnt = 0
    HEAD oi.order_id
     inactiveordseqind = 0, imatchcnt = 0, iunmatcheddiluentcnt = 0,
     iordingreds = 0
     FOR (lingredidx = 1 TO iscannedingredcnt)
       temp_ingred_inds->array[lingredidx].ingred_found_ind = 0
     ENDFOR
    HEAD oi.action_sequence
     inactiveordseqind = inactiveordseqind
    DETAIL
     IF (inactiveordseqind=0)
      IF (((ocs.orderable_type_flag=10
       AND tnf_scan_across_order_id_pref=0
       AND (reply->order_id=o.order_id)) OR (((ocs.orderable_type_flag != 10) OR (
      tnf_scan_across_order_id_pref=1)) )) )
       iordingreds = (iordingreds+ 1), ingredmatchind = 0
       FOR (lingredidx = 1 TO iscannedingredcnt)
         IF ((reply->ingred_qual[lingredidx].catalog_cd=oi.catalog_cd))
          syncnt = size(reply->ingred_qual[lingredidx].synonym_qual,5)
          IF (syncnt > 0)
           FOR (synidx = 1 TO syncnt)
             IF ((reply->ingred_qual[lingredidx].synonym_qual[synidx].synonym_id=oi.synonym_id))
              imatchcnt = (imatchcnt+ 1), ingredmatchind = 1, temp_ingred_inds->array[lingredidx].
              ingred_found_ind = 1,
              synidx = syncnt, lingredidx = iscannedingredcnt
             ENDIF
           ENDFOR
          ELSE
           imatchcnt = (imatchcnt+ 1), ingredmatchind = 1, temp_ingred_inds->array[lingredidx].
           ingred_found_ind = 1,
           lingredidx = iscannedingredcnt
          ENDIF
         ENDIF
       ENDFOR
       IF (ingredmatchind=0
        AND oi.freq_cd != every_bag_cd
        AND oi.freq_cd != 0)
        imatchcnt = (imatchcnt+ 1), ingredmatchind = 1
       ENDIF
       IF ((request->qual_miss_diluent_ind=1)
        AND ingredmatchind=0
        AND oi.ingredient_type_flag=diluent_flag)
        iunmatcheddiluentcnt = (iunmatcheddiluentcnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    FOOT  oi.action_sequence
     inactiveordseqind = 1
    FOOT  oi.order_id
     iallscannedingredsfound = 1
     FOR (lingredidx = 1 TO iscannedingredcnt)
       IF ((temp_ingred_inds->array[lingredidx].ingred_found_ind=0))
        iallscannedingredsfound = 0
       ENDIF
     ENDFOR
     IF (debug_ind > 0)
      CALL echo("----------------------------------------"),
      CALL echo(build("iScannedIngredCnt:",iscannedingredcnt)),
      CALL echo(build("iMatchCnt:",imatchcnt)),
      CALL echo(build("iOrdIngreds:",iordingreds)),
      CALL echo(build("iUnmatchedDiluentCnt:",iunmatcheddiluentcnt)),
      CALL echo(build("iAllScannedIngredsFound:",iallscannedingredsfound)),
      CALL echo("----------------------------------------")
     ENDIF
     IF (iallscannedingredsfound=1
      AND (iordingreds=(iunmatcheddiluentcnt+ imatchcnt))
      AND iunmatcheddiluentcnt < 2)
      IF (o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
      pending_ord_cd, pending_rev_cd, suspended_cd, unscheduled_cd))
       IF ((reply->active_order_found_ind=1))
        reply->multi_found_ind = 1, reply->found_order_status = 0
       ELSE
        reply->multi_found_ind = 0, reply->found_order_id = o.order_id
       ENDIF
       reply->active_order_found_ind = 1, reply->found_order_status = o.order_status_cd
      ELSE
       IF ((reply->active_order_found_ind=0))
        IF ((reply->inactive_order_found_ind=1))
         reply->multi_found_ind = 1, reply->found_order_status = 0
        ELSE
         reply->found_order_id = o.order_id, reply->found_order_status = o.order_status_cd
        ENDIF
        reply->inactive_order_found_ind = 1
       ENDIF
      ENDIF
     ENDIF
     inactiveordseqind = 0
    FOOT REPORT
     imatchcnt = 0
    WITH nocounter
   ;end select
   SET elapsed_time_func = ((curtime3 - start_time_func)/ 100)
   CALL echo(build("Order Search Function elapsed time (seconds): ",elapsed_time_func))
   CALL echo(
    "dcp_get_ord_ings_from_disp_hx - ****** Exiting CheckForOrdersOutsideTimeRange Subroutine ******"
    )
 END ;Subroutine
 SUBROUTINE getitemids(null)
   DECLARE iidxitem1 = i4 WITH protect, noconstant(0)
   DECLARE iidxitem2 = i4 WITH protect, noconstant(0)
   DECLARE iitemcnt = i4 WITH protect, noconstant(0)
   DECLARE replycnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dispense_hx dh,
     prod_dispense_hx pdh,
     order_ingredient oi
    PLAN (dh
     WHERE (dh.dispense_hx_id=request->dispense_hx_id))
     JOIN (pdh
     WHERE pdh.dispense_hx_id=dh.dispense_hx_id)
     JOIN (oi
     WHERE oi.order_id=dh.order_id
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=dh.order_id
       AND oi2.action_sequence <= dh.action_sequence))
      AND oi.comp_sequence=pdh.ingred_sequence
      AND oi.ingredient_type_flag != icompoundchild)
    ORDER BY oi.catalog_cd
    HEAD REPORT
     replycnt = size(reply->ingred_qual,5), iitemcnt = 0
    HEAD oi.catalog_cd
     iidxitem1 = locateval(iidxitem2,1,replycnt,oi.catalog_cd,reply->ingred_qual[iidxitem2].
      catalog_cd)
    DETAIL
     IF (iidxitem1 > 0)
      bhasitemids = 1, iitemcnt = (iitemcnt+ 1)
      IF (mod(iitemcnt,10)=1)
       stat = alterlist(temp_itemids->itemqual,(iitemcnt+ 9))
      ENDIF
      temp_itemids->itemqual[iitemcnt].item_id = pdh.item_id, temp_itemids->itemqual[iitemcnt].
      item_pos = iidxitem1, temp_itemids->itemqual[iitemcnt].catalog_cd = oi.catalog_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(temp_itemids->itemqual,iitemcnt)
   ;end select
   SET itmpitemsize = size(temp_itemids->itemqual,5) WITH nocounter
 END ;Subroutine
 SUBROUTINE getsynonymsfromitem(null)
   DECLARE x1 = i4 WITH protect, noconstant(0)
   DECLARE iidxsyno1 = i4 WITH protect, noconstant(0)
   DECLARE iidxsyno2 = i4 WITH protect, noconstant(0)
   DECLARE isyncnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM synonym_item_r sir,
     order_catalog_synonym ocs
    PLAN (sir
     WHERE expand(x1,1,itmpitemsize,sir.item_id,temp_itemids->itemqual[x1].item_id)
      AND sir.synonym_id > 0)
     JOIN (ocs
     WHERE ocs.synonym_id=sir.synonym_id
      AND ((ocs.active_ind+ 0) > 0))
    ORDER BY sir.item_id
    HEAD sir.item_id
     iidxsyno1 = locateval(iidxsyno2,1,itmpitemsize,sir.item_id,temp_itemids->itemqual[iidxsyno2].
      item_id), isyncnt = 0
    DETAIL
     IF (iidxsyno1 > 0)
      bhassynonyms = 1, isyncnt = (isyncnt+ 1)
      IF (mod(isyncnt,10)=1)
       stat = alterlist(temp_itemids->itemqual[iidxsyno1].synonymqual,(isyncnt+ 9))
      ENDIF
      temp_itemids->itemqual[iidxsyno1].synonymqual[isyncnt].synonym_id = sir.synonym_id
     ENDIF
    FOOT  sir.item_id
     stat = alterlist(temp_itemids->itemqual[iidxsyno1].synonymqual,isyncnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getmultumsynonymsfromitem(null)
   DECLARE x2 = i4 WITH protect, noconstant(0)
   DECLARE iidxmult1 = i4 WITH protect, noconstant(0)
   DECLARE iidxmult2 = i4 WITH protect, noconstant(0)
   DECLARE isyncnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM mltm_ndc_core_description mdc,
     mltm_mmdc_name_map mnm,
     med_identifier mdi,
     order_catalog_synonym ocs,
     order_catalog_item_r ocir
    PLAN (mdi
     WHERE expand(x2,1,itmpitemsize,mdi.item_id,temp_itemids->itemqual[x2].item_id)
      AND mdi.med_identifier_type_cd=cndc
      AND mdi.active_ind=1
      AND mdi.med_product_id > 0
      AND mdi.pharmacy_type_cd=cinpatient
      AND mdi.flex_type_cd IN (csystem, csyspkgtyp))
     JOIN (ocir
     WHERE mdi.item_id=ocir.item_id)
     JOIN (mdc
     WHERE mdi.value_key=mdc.ndc_code)
     JOIN (mnm
     WHERE mdc.main_multum_drug_code=mnm.main_multum_drug_code)
     JOIN (ocs
     WHERE concat("MUL.ORD-SYN!",cnvtstring(mnm.drug_synonym_id))=ocs.cki
      AND ocs.active_ind > 0
      AND ocs.synonym_id > 0)
    ORDER BY mdi.item_id
    HEAD mdi.item_id
     iidxmult1 = locateval(iidxmult2,1,itmpitemsize,mdi.item_id,temp_itemids->itemqual[iidxmult2].
      item_id), isyncnt = 0
    DETAIL
     IF (iidxmult1 > 0)
      bhassynonyms = 1, isyncnt = (isyncnt+ 1)
      IF (mod(isyncnt,10)=1)
       stat = alterlist(temp_itemids->itemqual[iidxmult1].synonymqual,(isyncnt+ 9))
      ENDIF
      temp_itemids->itemqual[iidxmult1].synonymqual[isyncnt].synonym_id = ocs.synonym_id
     ENDIF
    FOOT  mdi.item_id
     stat = alterlist(temp_itemids->itemqual[iidxmult1].synonymqual,isyncnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE populatereplysynonymids(null)
   DECLARE itmpitemsynonymqualsize = i4 WITH protect, noconstant(0)
   DECLARE itmpcnt = i4 WITH protect, noconstant(0)
   DECLARE iexistrepcnt = i4 WITH protect, noconstant(0)
   DECLARE itmpsynonymsize = i4 WITH protect, noconstant(0)
   DECLARE itmpsynoidx = i4 WITH protect, noconstant(0)
   DECLARE iidx1 = i4 WITH protect, noconstant(0)
   DECLARE iidx2 = i4 WITH protect, noconstant(0)
   DECLARE iidxrep1 = i4 WITH protect, noconstant(0)
   DECLARE iidxrep2 = i4 WITH protect, noconstant(0)
   DECLARE itmpitmidx = i4 WITH protect, noconstant(0)
   DECLARE icatalog_cd = f8 WITH protect, noconstant(0)
   DECLARE itmpsynonymid = f8 WITH protect, noconstant(0)
   DECLARE iingredsynonymid = f8 WITH protect, noconstant(0)
   FOR (itmpitmidx = 1 TO itmpitemsize)
     SET iidx2 = 0
     SET iidxrep2 = 0
     SET icatalog_cd = temp_itemids->itemqual[itmpitmidx].catalog_cd
     SET iidx1 = locateval(iidx2,1,ireplysize,icatalog_cd,reply->ingred_qual[iidx2].catalog_cd)
     IF (iidx1 > 0)
      SET iingredsynonymid = reply->ingred_qual[iidx1].synonym_id
      SET itmpitemsynonymqualsize = size(temp_itemids->itemqual[itmpitmidx].synonymqual,5)
      SET iidxrep1 = locateval(iidxrep2,1,itmpitemsynonymqualsize,iingredsynonymid,temp_itemids->
       itemqual[itmpitmidx].synonymqual[iidxrep2].synonym_id)
      SET iexistrepcnt = size(reply->ingred_qual[iidx1].synonym_qual,5)
      SET itmpsynonymsize = size(temp_itemids->itemqual[itmpitmidx].synonymqual,5)
      IF (iidxrep1=0
       AND bhassynonyms=1)
       SET stat = alterlist(reply->ingred_qual[iidx1].synonym_qual,((iexistrepcnt+ itmpsynonymsize)+
        1))
       SET reply->ingred_qual[iidx1].synonym_qual[(iexistrepcnt+ 1)].synonym_id = iingredsynonymid
      ELSE
       SET stat = alterlist(reply->ingred_qual[iidx1].synonym_qual,(iexistrepcnt+ itmpsynonymsize))
      ENDIF
      FOR (itmpsynoidx = 1 TO itmpsynonymsize)
        IF (iidxrep1=0
         AND bhassynonyms=1)
         SET reply->ingred_qual[iidx1].synonym_qual[((iexistrepcnt+ itmpsynoidx)+ 1)].synonym_id =
         temp_itemids->itemqual[itmpitmidx].synonymqual[itmpsynoidx].synonym_id
        ELSE
         SET reply->ingred_qual[iidx1].synonym_qual[(iexistrepcnt+ itmpsynoidx)].synonym_id =
         temp_itemids->itemqual[itmpitmidx].synonymqual[itmpsynoidx].synonym_id
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE immunizationcheck(null)
   DECLARE idxing = i4 WITH protect, noconstant(0)
   DECLARE iingredsize = i4 WITH protect, noconstant(size(reply->ingred_qual,5))
   IF (validate(debug_ind)
    AND debug_ind > 0)
    CALL echo("dcp_get_ord_ings_from_disp_hx - ****** Starting ImmunizationCheck Subroutine ******")
    CALL echo(build("  - **** ingredient size is:",iingredsize))
   ENDIF
   SELECT INTO "nl:"
    cve.code_set, cve.field_name, cve.field_type,
    cve.field_value, cve.code_value
    FROM code_value_extension cve
    PLAN (cve
     WHERE expand(idxing,1,iingredsize,cve.code_value,reply->ingred_qual[idxing].catalog_cd)
      AND cve.code_set=200
      AND cve.field_name="IMMUNIZATIONIND"
      AND cve.field_value="1")
    DETAIL
     reply->ingred_qual[idxing].immunization_ind = 1
     IF (validate(debug_ind)
      AND debug_ind > 0)
      CALL echo(concat(build("  - ****** Catalog Cd: ",cve.code_value),", is an immunization"))
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(debug_ind)
    AND debug_ind > 0)
    CALL echo("dcp_get_ord_ings_from_disp_hx - ****** Existing ImmunizationCheck Subroutine ******")
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD internal
 FREE RECORD comp_routes
 FREE RECORD comp_order_actions
 FREE RECORD compat_orders
 FREE RECORD temp_ingred_inds
 FREE RECORD temp_itemids
 SET reply->elapsed_time = ((curtime3 - start_time)/ 100)
 SET last_mod = "029"
 SET mod_date = "06/16/17"
 SET modify = nopredeclare
END GO
