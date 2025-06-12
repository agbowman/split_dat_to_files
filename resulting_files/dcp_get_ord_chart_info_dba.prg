CREATE PROGRAM dcp_get_ord_chart_info:dba
 SET modify = predeclare
 RECORD reply(
   1 order_id = f8
   1 person_id = f8
   1 pharmacy_ind = i2
   1 ordering_id = f8
   1 catalog_cd = f8
   1 event_cd = f8
   1 hna_order_mnemonic = vc
   1 ordered_as_mnemonic = vc
   1 order_mnemonic = vc
   1 catalog_type_cd = f8
   1 order_status_cd = f8
   1 orig_order_dt_tm = dq8
   1 orig_order_tz = i4
   1 current_start_dt_tm = dq8
   1 current_start_tz = i4
   1 projected_stop_dt_tm = dq8
   1 projected_stop_tz = i4
   1 order_detail_display_line = vc
   1 clinical_display_line = vc
   1 iv_ind = i2
   1 constant_ind = i2
   1 prn_ind = i2
   1 rx_mask = i4
   1 template_order_id = f8
   1 action_seq = i4
   1 activity_type_cd = f8
   1 encntr_id = f8
   1 dispense_category_cd = f8
   1 product_action_seq = i4
   1 comment_type_mask = i4
   1 order_comment_text = vc
   1 ingredient_ind = i2
   1 detqual_cnt = i4
   1 detqual[*]
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
   1 ingqual_cnt = i4
   1 ingqual[*]
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_detail_display_line = vc
     2 strength = f8
     2 strength_unit = f8
     2 volume = f8
     2 volume_unit = f8
     2 freetext_dose = vc
     2 freq_cd = f8
     2 event_cd = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 synonym_id = f8
     2 ingredient_type_flag = i2
     2 comp_sequence = i4
     2 hna_order_mnemonic = vc
     2 product[*]
       3 item_id = f8
       3 dispense_category_cd = f8
   1 need_rx_verify_ind = i2
   1 need_rx_clin_review_flag = i2
   1 orderable_type_flag = i2
   1 dcp_clin_cat_cd = f8
   1 med_order_type_cd = f8
   1 need_nurse_review_ind = i2
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
 DECLARE product_cnt = i4 WITH noconstant(0)
 DECLARE use_products = i2 WITH noconstant(1)
 DECLARE found_products = i2 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE detail_cnt = i4 WITH noconstant(0)
 DECLARE ing_cnt = i4 WITH noconstant(0)
 DECLARE rx_ind = i2 WITH noconstant(0)
 DECLARE template_order_id = f8 WITH noconstant(0.0)
 DECLARE core_action = i4 WITH noconstant(0)
 DECLARE last_ingred_action = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE mar_note_mask = i4 WITH constant(2)
 DECLARE admin_note_mask = i4 WITH constant(128)
 DECLARE new_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM orders o,
   orders ot,
   code_value_event_r cve,
   order_action oa,
   order_detail od,
   order_entry_fields oef,
   oe_format_fields off,
   dummyt d1
  PLAN (o
   WHERE (o.order_id=request->order_id))
   JOIN (ot
   WHERE ot.order_id=o.template_order_id)
   JOIN (cve
   WHERE outerjoin(o.catalog_cd)=cve.parent_cd)
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_rejected_ind=0)
   JOIN (od
   WHERE outerjoin(oa.order_id)=od.order_id
    AND outerjoin(oa.action_sequence)=od.action_sequence)
   JOIN (oef
   WHERE outerjoin(od.oe_field_id)=oef.oe_field_id)
   JOIN (d1)
   JOIN (off
   WHERE o.oe_format_id=off.oe_format_id
    AND off.action_type_cd=new_action_type_cd
    AND oef.oe_field_id=off.oe_field_id)
  ORDER BY od.oe_field_meaning_id, od.action_sequence DESC
  HEAD REPORT
   count1 = 0, reply->ingredient_ind = o.ingredient_ind, rx_ind = o.ingredient_ind,
   reply->order_id = o.order_id, reply->person_id = o.person_id, reply->hna_order_mnemonic = o
   .hna_order_mnemonic,
   reply->ordered_as_mnemonic = o.ordered_as_mnemonic, reply->order_mnemonic = o.order_mnemonic,
   reply->catalog_type_cd = o.catalog_type_cd,
   reply->activity_type_cd = o.activity_type_cd, reply->order_status_cd = o.order_status_cd, reply->
   orig_order_dt_tm = cnvtdatetime(o.orig_order_dt_tm),
   reply->orig_order_tz = o.orig_order_tz, reply->current_start_dt_tm = cnvtdatetime(o
    .current_start_dt_tm), reply->current_start_tz = o.current_start_tz,
   reply->projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm), reply->projected_stop_tz = o
   .projected_stop_tz, reply->order_detail_display_line = o.order_detail_display_line,
   reply->clinical_display_line = o.clinical_display_line, reply->iv_ind = o.iv_ind, reply->prn_ind
    = o.prn_ind,
   reply->rx_mask = o.rx_mask, reply->catalog_cd = o.catalog_cd, reply->template_order_id = o
   .template_order_id,
   core_action = o.template_core_action_sequence, last_ingred_action = o.last_ingred_action_sequence,
   reply->event_cd = cve.event_cd,
   reply->encntr_id = o.encntr_id, reply->need_rx_verify_ind = o.need_rx_verify_ind, reply->
   need_rx_clin_review_flag = o.need_rx_clin_review_flag,
   reply->orderable_type_flag = o.orderable_type_flag, reply->dcp_clin_cat_cd = o.dcp_clin_cat_cd,
   reply->med_order_type_cd = o.med_order_type_cd
   IF (o.template_order_id > 0)
    reply->comment_type_mask = bor(o.comment_type_mask,band(ot.comment_type_mask,admin_note_mask)),
    reply->comment_type_mask = bor(reply->comment_type_mask,band(ot.comment_type_mask,mar_note_mask)),
    reply->need_nurse_review_ind = ot.need_nurse_review_ind
   ELSE
    reply->comment_type_mask = o.comment_type_mask, reply->need_nurse_review_ind = o
    .need_nurse_review_ind
   ENDIF
  HEAD od.oe_field_id
   act_seq = od.action_sequence, flag = 1
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    flag = 0
   ENDIF
  DETAIL
   IF (oa.action_sequence=1)
    reply->ordering_id = oa.order_provider_id
   ENDIF
   IF (flag=1
    AND od.oe_field_id > 0)
    detail_cnt = (detail_cnt+ 1)
    IF (detail_cnt > size(reply->detqual,5))
     stat = alterlist(reply->detqual,(detail_cnt+ 5))
    ENDIF
    IF (od.oe_field_display_value > " ")
     reply->detqual[detail_cnt].oe_field_display_value = trim(od.oe_field_display_value)
    ENDIF
    reply->detqual[detail_cnt].oe_field_dt_tm_value = od.oe_field_dt_tm_value, reply->detqual[
    detail_cnt].oe_field_tz = od.oe_field_tz, reply->detqual[detail_cnt].oe_field_id = od.oe_field_id,
    reply->detqual[detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id, reply->detqual[
    detail_cnt].oe_field_value = od.oe_field_value, reply->detqual[detail_cnt].min_val = oef.min_val,
    reply->detqual[detail_cnt].max_val = oef.max_val, reply->detqual[detail_cnt].input_mask = off
    .input_mask, reply->detqual[detail_cnt].label_text = off.label_text,
    reply->detqual[detail_cnt].filter_params = off.filter_params
   ENDIF
   reply->detqual_cnt = detail_cnt
  WITH nocounter, outerjoin = d1
 ;end select
 SET stat = alterlist(reply->detqual,detail_cnt)
 IF ((reply->need_rx_clin_review_flag=0))
  SET map_request->mapping_ind = 1
  SET map_request->map_from_value = reply->need_rx_verify_ind
  SET modify = nopredeclare
  EXECUTE dcp_map_clin_review_flag  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
   "MAP_REPLY")
  SET modify = predeclare
  SET reply->need_rx_clin_review_flag = map_reply->map_to_value
 ENDIF
 IF (band(reply->comment_type_mask,order_comment_mask)=order_comment_mask)
  SELECT INTO "nl:"
   FROM order_comment oc,
    long_text lt
   PLAN (oc
    WHERE (oc.order_id=request->order_id)
     AND oc.comment_type_cd=order_comment_cd
     AND (oc.action_sequence=
    (SELECT
     max(oc2.action_sequence)
     FROM order_comment oc2
     WHERE oc2.order_id=oc.order_id
      AND oc2.comment_type_cd=order_comment_cd)))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id)
   DETAIL
    reply->order_comment_text = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->template_order_id > 0))
  SELECT INTO "nl:"
   FROM order_ingredient oi,
    code_value_event_r cve
   PLAN (oi
    WHERE (oi.order_id=reply->template_order_id)
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE (oi2.order_id=reply->template_order_id)
      AND oi2.action_sequence <= core_action)))
    JOIN (cve
    WHERE cve.parent_cd=outerjoin(oi.catalog_cd))
   ORDER BY oi.comp_sequence
   HEAD REPORT
    ing_cnt = 0
   DETAIL
    ing_cnt = (ing_cnt+ 1)
    IF (ing_cnt > size(reply->ingqual,5))
     stat = alterlist(reply->ingqual,(ing_cnt+ 5))
    ENDIF
    reply->ingqual[ing_cnt].order_mnemonic = oi.order_mnemonic, reply->ingqual[ing_cnt].
    ordered_as_mnemonic = oi.ordered_as_mnemonic, reply->ingqual[ing_cnt].order_detail_display_line
     = oi.order_detail_display_line,
    reply->ingqual[ing_cnt].strength = oi.strength, reply->ingqual[ing_cnt].strength_unit = oi
    .strength_unit, reply->ingqual[ing_cnt].volume = oi.volume,
    reply->ingqual[ing_cnt].volume_unit = oi.volume_unit, reply->ingqual[ing_cnt].freetext_dose = oi
    .freetext_dose, reply->ingqual[ing_cnt].freq_cd = oi.freq_cd,
    reply->ingqual[ing_cnt].event_cd = cve.event_cd, reply->ingqual[ing_cnt].catalog_cd = oi
    .catalog_cd, reply->ingqual[ing_cnt].catalog_type_cd = oi.catalog_type_cd,
    reply->ingqual[ing_cnt].synonym_id = oi.synonym_id, reply->ingqual[ing_cnt].ingredient_type_flag
     = oi.ingredient_type_flag, reply->ingqual[ing_cnt].comp_sequence = oi.comp_sequence,
    reply->ingqual[ing_cnt].hna_order_mnemonic = oi.hna_order_mnemonic
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_ingredient oi,
    code_value_event_r cve
   PLAN (oi
    WHERE (oi.order_id=request->order_id)
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE (oi2.order_id=request->order_id)
      AND oi2.action_sequence <= last_ingred_action)))
    JOIN (cve
    WHERE outerjoin(oi.catalog_cd)=cve.parent_cd)
   ORDER BY oi.comp_sequence
   HEAD REPORT
    ing_cnt = 0
   DETAIL
    ing_cnt = (ing_cnt+ 1)
    IF (ing_cnt > size(reply->ingqual,5))
     stat = alterlist(reply->ingqual,(ing_cnt+ 5))
    ENDIF
    reply->ingqual[ing_cnt].order_mnemonic = oi.order_mnemonic, reply->ingqual[ing_cnt].
    ordered_as_mnemonic = oi.ordered_as_mnemonic, reply->ingqual[ing_cnt].order_detail_display_line
     = oi.order_detail_display_line,
    reply->ingqual[ing_cnt].strength = oi.strength, reply->ingqual[ing_cnt].strength_unit = oi
    .strength_unit, reply->ingqual[ing_cnt].volume = oi.volume,
    reply->ingqual[ing_cnt].volume_unit = oi.volume_unit, reply->ingqual[ing_cnt].freetext_dose = oi
    .freetext_dose, reply->ingqual[ing_cnt].freq_cd = oi.freq_cd,
    reply->ingqual[ing_cnt].event_cd = cve.event_cd, reply->ingqual[ing_cnt].catalog_cd = oi
    .catalog_cd, reply->ingqual[ing_cnt].catalog_type_cd = oi.catalog_type_cd,
    reply->ingqual[ing_cnt].synonym_id = oi.synonym_id, reply->ingqual[ing_cnt].ingredient_type_flag
     = oi.ingredient_type_flag, reply->ingqual[ing_cnt].comp_sequence = oi.comp_sequence,
    reply->ingqual[ing_cnt].hna_order_mnemonic = oi.hna_order_mnemonic
   WITH nocounter
  ;end select
 ENDIF
 SET reply->ingqual_cnt = ing_cnt
 SET stat = alterlist(reply->ingqual,ing_cnt)
 IF ((reply->template_order_id=0))
  SET template_order_id = request->order_id
  SET reply->action_seq = last_ingred_action
 ELSE
  SET template_order_id = reply->template_order_id
  SET reply->action_seq = core_action
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->ingqual,5))),
   order_product op,
   medication_definition md
  PLAN (d)
   JOIN (op
   WHERE op.order_id=template_order_id
    AND (op.action_sequence >= reply->action_seq)
    AND (op.ingred_sequence=reply->ingqual[d.seq].comp_sequence))
   JOIN (md
   WHERE md.item_id=op.item_id)
  ORDER BY op.action_sequence, op.ingred_sequence
  HEAD op.action_sequence
   IF (use_products=1)
    reply->product_action_seq = op.action_sequence
   ENDIF
  HEAD op.ingred_sequence
   product_cnt = 0
  DETAIL
   IF (use_products > 0)
    product_cnt = (product_cnt+ 1), stat = alterlist(reply->ingqual[d.seq].product,product_cnt),
    reply->ingqual[d.seq].product[product_cnt].item_id = op.item_id,
    reply->ingqual[d.seq].product[product_cnt].dispense_category_cd = md.dispense_category_cd,
    found_products = 1
   ENDIF
  FOOT  op.action_sequence
   use_products = 0
  WITH nocounter
 ;end select
 IF (found_products=0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->ingqual,5))),
    order_product op,
    medication_definition md
   PLAN (d)
    JOIN (op
    WHERE op.order_id=template_order_id
     AND (op.action_sequence < reply->action_seq)
     AND (op.ingred_sequence=reply->ingqual[d.seq].comp_sequence))
    JOIN (md
    WHERE md.item_id=op.item_id)
   ORDER BY op.action_sequence DESC, op.ingred_sequence
   HEAD op.action_sequence
    IF (use_products=1)
     reply->product_action_seq = op.action_sequence
    ENDIF
   HEAD op.ingred_sequence
    product_cnt = 0
   DETAIL
    IF (use_products > 0)
     product_cnt = (product_cnt+ 1), stat = alterlist(reply->ingqual[d.seq].product,product_cnt),
     reply->ingqual[d.seq].product[product_cnt].item_id = op.item_id,
     reply->ingqual[d.seq].product[product_cnt].dispense_category_cd = md.dispense_category_cd
    ENDIF
   FOOT  op.action_sequence
    use_products = 0
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM order_dispense od
  WHERE od.order_id=template_order_id
  DETAIL
   reply->dispense_category_cd = od.dispense_category_cd
  WITH maxqual(od,1), nocounter
 ;end select
 IF ((reply->catalog_cd=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "027"
 SET mod_date = "11/15/2006"
 SET modify = nopredeclare
END GO
