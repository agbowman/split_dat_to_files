CREATE PROGRAM dcp_get_ord_dtls_from_disp_hx:dba
 SET modify = predeclare
 RECORD reply(
   1 order_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 hna_order_mnemonic = vc
   1 ordered_as_mnemonic = vc
   1 order_mnemonic = vc
   1 catalog_cd = f8
   1 event_cd = f8
   1 action_sequence = i4
   1 iv_ind = i2
   1 clinical_display_line = vc
   1 effective_dt_tm = dq8
   1 effective_tz = i4
   1 orig_order_dt_tm = dq8
   1 orig_order_tz = i4
   1 order_provider_id = f8
   1 order_status_cd = f8
   1 template_order_id = f8
   1 template_core_action_sequence = f8
   1 need_rx_verify_ind = i2
   1 need_rx_clin_review_flag = i2
   1 prn_ind = i2
   1 orderable_type_flag = i2
   1 dcp_clin_cat_cd = f8
   1 med_order_type_cd = f8
   1 root_event_id = f8
   1 detail_qual[*]
     2 oe_field_display_value = vc
     2 oe_field_dt_tm_value = dq8
     2 oe_field_tz = i4
     2 oe_field_id = f8
     2 oe_field_meaning_id = f8
     2 oe_field_value = f8
     2 min_val = f8
     2 max_val = f8
     2 input_mask = vc
     2 label_text = vc
     2 filter_params = vc
   1 ingred_qual[*]
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 order_detail_display_line = vc
     2 ingredient_type_flag = i2
     2 comp_sequence = i4
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit = f8
     2 freetext_dose = vc
     2 freq_cd = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 synonym_id = f8
     2 event_cd = f8
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
     2 clinically_significant_flag = i2
     2 product_qual[*]
       3 item_id = f8
       3 dispense_category_cd = f8
       3 dose_quantity = f8
       3 dose_quantity_unit_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD map_request(
   1 mapping_ind = i2
   1 map_from_value = i2
 )
 RECORD map_reply(
   1 map_to_value = i2
 )
 DECLARE errmsg = vc
 DECLARE detail_cnt = i4
 DECLARE ingred_cnt = i4
 DECLARE code_value = f8
 DECLARE product_cnt = i4
 DECLARE order_id = f8
 DECLARE action_sequence = i4
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE new_action_type_cd = f8
 DECLARE group_class_cd = f8
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 SET reply->status_data.status = "F"
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 SET modify = nopredeclare
 EXECUTE cpm_get_cd_for_cdf
 SET modify = predeclare
 SET new_action_type_cd = code_value
 SET code_set = 53
 SET cdf_meaning = "GRP"
 SET modify = nopredeclare
 EXECUTE cpm_get_cd_for_cdf
 SET modify = predeclare
 SET group_class_cd = code_value
 SELECT INTO "nl:"
  FROM dispense_hx dh
  WHERE (dh.dispense_hx_id=request->dispense_hx_id)
  DETAIL
   order_id = dh.order_id, action_sequence = dh.action_sequence
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errmsg = concat("order_id and action_sequence not found for a given dispense_hx_id: ",
   cnvtstring(request->dispense_hx_id,20,2))
  CALL logstatus("SELECT","F","DISPENSE_HX",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   (dummyt d1  WITH seq = 1),
   code_value_event_r cve,
   (dummyt d2  WITH seq = 1),
   order_detail od,
   oe_format_fields off,
   (dummyt d3  WITH seq = 1),
   order_entry_fields oef
  PLAN (o
   WHERE o.order_id=order_id)
   JOIN (oa
   WHERE oa.order_id=order_id
    AND oa.action_sequence=action_sequence)
   JOIN (d1)
   JOIN (cve
   WHERE cve.parent_cd=o.catalog_cd)
   JOIN (d2)
   JOIN (od
   WHERE od.order_id=oa.order_id
    AND od.action_sequence <= oa.action_sequence)
   JOIN (off
   WHERE off.oe_format_id=o.oe_format_id
    AND off.action_type_cd=new_action_type_cd
    AND off.oe_field_id=od.oe_field_id)
   JOIN (d3)
   JOIN (oef
   WHERE oef.oe_field_id=od.oe_field_id
    AND ((oef.field_type_flag=1) OR (oef.field_type_flag=2)) )
  ORDER BY o.order_id, oa.order_id, od.oe_field_id,
   od.action_sequence DESC
  HEAD REPORT
   detail_cnt = 0
  HEAD o.order_id
   reply->order_id = o.order_id, reply->person_id = o.person_id, reply->encntr_id = o.encntr_id,
   reply->hna_order_mnemonic = o.hna_order_mnemonic, reply->ordered_as_mnemonic = o
   .ordered_as_mnemonic, reply->order_mnemonic = o.order_mnemonic,
   reply->catalog_cd = o.catalog_cd, reply->iv_ind = o.iv_ind, reply->orig_order_dt_tm = cnvtdatetime
   (o.orig_order_dt_tm),
   reply->orig_order_tz = o.orig_order_tz, reply->template_order_id = o.template_order_id, reply->
   template_core_action_sequence = o.template_core_action_sequence,
   reply->need_rx_verify_ind = o.need_rx_verify_ind, reply->need_rx_clin_review_flag = o
   .need_rx_clin_review_flag, reply->prn_ind = o.prn_ind,
   reply->orderable_type_flag = o.orderable_type_flag, reply->dcp_clin_cat_cd = o.dcp_clin_cat_cd,
   reply->med_order_type_cd = o.med_order_type_cd,
   reply->event_cd = cve.event_cd
  HEAD oa.order_id
   reply->clinical_display_line = oa.clinical_display_line, reply->effective_dt_tm = cnvtdatetime(oa
    .effective_dt_tm), reply->effective_tz = oa.effective_tz,
   reply->order_provider_id = oa.order_provider_id, reply->order_status_cd = oa.order_status_cd,
   reply->action_sequence = oa.action_sequence
  HEAD od.oe_field_id
   detail_cnt = (detail_cnt+ 1)
   IF (mod(detail_cnt,10)=1)
    stat = alterlist(reply->detail_qual,(detail_cnt+ 9))
   ENDIF
   reply->detail_qual[detail_cnt].oe_field_display_value = trim(od.oe_field_display_value), reply->
   detail_qual[detail_cnt].oe_field_dt_tm_value = cnvtdatetime(od.oe_field_dt_tm_value), reply->
   detail_qual[detail_cnt].oe_field_tz = od.oe_field_tz,
   reply->detail_qual[detail_cnt].oe_field_id = od.oe_field_id, reply->detail_qual[detail_cnt].
   oe_field_meaning_id = od.oe_field_meaning_id, reply->detail_qual[detail_cnt].oe_field_value = od
   .oe_field_value,
   reply->detail_qual[detail_cnt].min_val = oef.min_val, reply->detail_qual[detail_cnt].max_val = oef
   .max_val, reply->detail_qual[detail_cnt].input_mask = off.input_mask,
   reply->detail_qual[detail_cnt].label_text = off.label_text, reply->detail_qual[detail_cnt].
   filter_params = off.filter_params
  FOOT REPORT
   stat = alterlist(reply->detail_qual,detail_cnt)
  WITH nocounter, outerjoin = d1, dontcare = cve,
   outerjoin = d2, outerjoin = d3
 ;end select
 IF ((reply->need_rx_clin_review_flag=0))
  SET map_request->mapping_ind = 1
  SET map_request->map_from_value = reply->need_rx_verify_ind
  SET modify = nopredeclare
  EXECUTE dcp_map_clin_review_flag  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
   "MAP_REPLY")
  SET modify = predeclare
  SET reply->need_rx_clin_review_flag = map_reply->map_to_value
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.order_id=order_id
    AND ce.parent_event_id=ce.event_id
    AND ce.event_class_cd=group_class_cd)
  DETAIL
   reply->root_event_id = ce.event_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prod_dispense_hx pdh,
   order_ingredient oi,
   code_value_event_r cve,
   order_product op,
   medication_definition md,
   order_catalog_synonym ocs
  PLAN (pdh
   WHERE (pdh.dispense_hx_id=request->dispense_hx_id))
   JOIN (oi
   WHERE oi.order_id=order_id
    AND oi.action_sequence=action_sequence
    AND oi.comp_sequence=pdh.ingred_sequence
    AND oi.ingredient_type_flag != icompoundchild)
   JOIN (cve
   WHERE cve.parent_cd=outerjoin(oi.catalog_cd))
   JOIN (op
   WHERE op.order_id=oi.order_id
    AND op.action_sequence=action_sequence)
   JOIN (ocs
   WHERE ocs.synonym_id=oi.synonym_id)
   JOIN (md
   WHERE md.item_id=outerjoin(op.item_id))
  ORDER BY oi.comp_sequence
  HEAD REPORT
   ingred_cnt = 0, product_cnt = 0
  HEAD oi.comp_sequence
   ingred_cnt = (ingred_cnt+ 1)
   IF (mod(ingred_cnt,10)=1)
    stat = alterlist(reply->ingred_qual,(ingred_cnt+ 9))
   ENDIF
   reply->ingred_qual[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic, reply->ingred_qual[
   ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic, reply->ingred_qual[ingred_cnt].
   order_mnemonic = oi.order_mnemonic,
   reply->ingred_qual[ingred_cnt].order_detail_display_line = oi.order_detail_display_line, reply->
   ingred_qual[ingred_cnt].ingredient_type_flag = oi.ingredient_type_flag, reply->ingred_qual[
   ingred_cnt].comp_sequence = oi.comp_sequence,
   reply->ingred_qual[ingred_cnt].strength = oi.strength, reply->ingred_qual[ingred_cnt].
   strength_unit_cd = oi.strength_unit, reply->ingred_qual[ingred_cnt].volume = oi.volume,
   reply->ingred_qual[ingred_cnt].volume_unit = oi.volume_unit, reply->ingred_qual[ingred_cnt].
   freetext_dose = oi.freetext_dose, reply->ingred_qual[ingred_cnt].freq_cd = oi.freq_cd,
   reply->ingred_qual[ingred_cnt].catalog_cd = oi.catalog_cd, reply->ingred_qual[ingred_cnt].
   catalog_type_cd = oi.catalog_type_cd, reply->ingred_qual[ingred_cnt].synonym_id = oi.synonym_id,
   reply->ingred_qual[ingred_cnt].event_cd = cve.event_cd, reply->ingred_qual[ingred_cnt].
   normalized_rate = oi.normalized_rate, reply->ingred_qual[ingred_cnt].normalized_rate_unit_cd = oi
   .normalized_rate_unit_cd,
   reply->ingred_qual[ingred_cnt].concentration = oi.concentration, reply->ingred_qual[ingred_cnt].
   concentration_unit_cd = oi.concentration_unit_cd, reply->ingred_qual[ingred_cnt].
   ingredient_rate_conversion_ind = ocs.ingredient_rate_conversion_ind,
   reply->ingred_qual[ingred_cnt].clinically_significant_flag = oi.clinically_significant_flag,
   product_cnt = 0
  DETAIL
   product_cnt = (product_cnt+ 1)
   IF (mod(product_cnt,10)=1)
    stat = alterlist(reply->ingred_qual[ingred_cnt].product_qual,(product_cnt+ 9))
   ENDIF
   reply->ingred_qual[ingred_cnt].product_qual[product_cnt].item_id = op.item_id, reply->ingred_qual[
   ingred_cnt].product_qual[product_cnt].dispense_category_cd = md.dispense_category_cd, reply->
   ingred_qual[ingred_cnt].product_qual[product_cnt].dose_quantity = op.dose_quantity,
   reply->ingred_qual[ingred_cnt].product_qual[product_cnt].dose_quantity_unit_cd = op
   .dose_quantity_unit_cd
  FOOT  oi.comp_sequence
   stat = alterlist(reply->ingred_qual[ingred_cnt].product_qual,product_cnt)
  FOOT REPORT
   stat = alterlist(reply->ingred_qual,ingred_cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (((detail_cnt > 0) OR (((ingred_cnt > 0) OR (product_cnt > 0)) )) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 DECLARE logstatus(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) =
 null
 SUBROUTINE logstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SET last_mod = "005"
 SET mod_date = "11/15/2006"
 SET modify = nopredeclare
END GO
