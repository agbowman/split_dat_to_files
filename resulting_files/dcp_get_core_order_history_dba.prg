CREATE PROGRAM dcp_get_core_order_history:dba
 SET modify = predeclare
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 iv_ind = i2
   1 update_date_tm = dq8
   1 action_qual[*]
     2 action_sequence = i4
     2 core_action_sequence = i4
     2 core_ind = i2
     2 effective_dt_tm = dq8
     2 effective_tz = i4
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 clinical_display_line = vc
     2 order_status_cd = f8
     2 ingred_qual[*]
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_mnemonic = vc
       3 ingredient_type_flag = i2
       3 comp_sequence = i4
       3 volume = f8
       3 volume_unit = f8
       3 strength = f8
       3 strength_unit = f8
       3 freetext_dose = vc
       3 catalog_cd = f8
       3 synonym_id = f8
       3 include_in_total_volume_flag = i2
       3 freq_cd = f8
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 normalized_rate_unit_cd_disp = vc
       3 normalized_rate_unit_cd_desc = vc
       3 normalized_rate_unit_cd_mean = vc
       3 concentration = f8
       3 concentration_unit_cd = f8
       3 concentration_unit_cd_disp = vc
       3 concentration_unit_cd_desc = vc
       3 concentration_unit_cd_mean = vc
       3 ingredient_rate_conversion_ind = i2
       3 clinically_significant_flag = i2
       3 display_additives_first_ind = i2
   1 root_event_id = f8
   1 need_rx_verify_ind = i2
   1 need_nurse_review_ind = i2
   1 comment_type_mask = i4
   1 order_comment_text = vc
   1 med_order_type_cd = f8
   1 need_rx_clin_review_flag = i2
   1 last_action_sequence = i4
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
 SET reply->status_data.status = "F"
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE action_cnt = i4 WITH noconstant(0)
 DECLARE ingred_cnt = i4 WITH noconstant(0)
 DECLARE order_action_where = c500 WITH noconstant(fillstring(500," "))
 DECLARE debug_cnt = i4 WITH noconstant(0)
 DECLARE order_comment_mask = i4 WITH constant(1)
 DECLARE core_action_sequence = i4 WITH noconstant(1)
 DECLARE group_class_cd = f8 WITH noconstant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 SET order_action_where = concat(trim(order_action_where),"oa.order_id = o.order_id")
 IF ((request->filter_by_core_ind=1))
  SET order_action_where = concat(trim(order_action_where)," and oa.core_ind = 1")
 ENDIF
 CALL echo(build("order_action_where parser--->",order_action_where))
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   order_ingredient oi,
   order_catalog_synonym ocs
  PLAN (o
   WHERE (o.order_id=request->order_id))
   JOIN (oa
   WHERE parser(order_action_where))
   JOIN (oi
   WHERE oi.order_id=oa.order_id
    AND (oi.action_sequence=
   (SELECT
    max(oi2.action_sequence)
    FROM order_ingredient oi2
    WHERE oi2.order_id=oi.order_id
     AND oi2.action_sequence <= oa.action_sequence))
    AND oi.ingredient_type_flag != icompoundchild)
   JOIN (ocs
   WHERE ocs.synonym_id=oi.synonym_id)
  ORDER BY o.order_id, oa.action_sequence, oi.ingredient_type_flag,
   oi.comp_sequence
  HEAD o.order_id
   action_cnt = 0, reply->person_id = o.person_id, reply->encntr_id = o.encntr_id,
   reply->iv_ind = o.iv_ind, reply->update_date_tm = o.updt_dt_tm, reply->need_rx_verify_ind = o
   .need_rx_verify_ind,
   reply->need_rx_clin_review_flag = o.need_rx_clin_review_flag, reply->need_nurse_review_ind = o
   .need_nurse_review_ind, reply->comment_type_mask = o.comment_type_mask,
   reply->med_order_type_cd = o.med_order_type_cd, reply->last_action_sequence = o
   .last_action_sequence, core_action_sequence = 1
  HEAD oa.action_sequence
   ingred_cnt = 0, action_cnt += 1
   IF (action_cnt > size(reply->action_qual,5))
    stat = alterlist(reply->action_qual,(action_cnt+ 5))
   ENDIF
   IF (oa.core_ind=1)
    core_action_sequence = oa.action_sequence
   ENDIF
   reply->action_qual[action_cnt].action_sequence = oa.action_sequence, reply->action_qual[action_cnt
   ].effective_dt_tm = cnvtdatetime(oa.effective_dt_tm), reply->action_qual[action_cnt].effective_tz
    = oa.effective_tz,
   reply->action_qual[action_cnt].action_dt_tm = cnvtdatetime(oa.action_dt_tm), reply->action_qual[
   action_cnt].action_tz = oa.action_tz, reply->action_qual[action_cnt].clinical_display_line = oa
   .clinical_display_line,
   reply->action_qual[action_cnt].order_status_cd = oa.order_status_cd, reply->action_qual[action_cnt
   ].core_ind = oa.core_ind, reply->action_qual[action_cnt].core_action_sequence =
   core_action_sequence
  DETAIL
   ingred_cnt += 1
   IF (ingred_cnt > size(reply->action_qual[action_cnt].ingred_qual,5))
    stat = alterlist(reply->action_qual[action_cnt].ingred_qual,(ingred_cnt+ 5))
   ENDIF
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].ordered_as_mnemonic = oi
   .ordered_as_mnemonic, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].order_mnemonic = oi
   .order_mnemonic,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].ingredient_type_flag = oi
   .ingredient_type_flag, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].comp_sequence = oi
   .comp_sequence, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].volume = oi.volume,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].volume_unit = oi.volume_unit, reply->
   action_qual[action_cnt].ingred_qual[ingred_cnt].strength = oi.strength, reply->action_qual[
   action_cnt].ingred_qual[ingred_cnt].strength_unit = oi.strength_unit,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].freetext_dose = oi.freetext_dose, reply->
   action_qual[action_cnt].ingred_qual[ingred_cnt].catalog_cd = oi.catalog_cd, reply->action_qual[
   action_cnt].ingred_qual[ingred_cnt].synonym_id = oi.synonym_id,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].include_in_total_volume_flag = oi
   .include_in_total_volume_flag, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].freq_cd = oi
   .freq_cd, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].normalized_rate = oi
   .normalized_rate,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].normalized_rate_unit_cd = oi
   .normalized_rate_unit_cd, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].concentration =
   oi.concentration, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].concentration_unit_cd =
   oi.concentration_unit_cd,
   reply->action_qual[action_cnt].ingred_qual[ingred_cnt].ingredient_rate_conversion_ind = ocs
   .ingredient_rate_conversion_ind, reply->action_qual[action_cnt].ingred_qual[ingred_cnt].
   clinically_significant_flag = oi.clinically_significant_flag
   IF (validate(ocs.display_additives_first_ind))
    reply->action_qual[action_cnt].ingred_qual[ingred_cnt].display_additives_first_ind = ocs
    .display_additives_first_ind
   ENDIF
  FOOT  oa.action_sequence
   stat = alterlist(reply->action_qual[action_cnt].ingred_qual,ingred_cnt)
  FOOT  o.order_id
   stat = alterlist(reply->action_qual,action_cnt)
  WITH nocounter
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
   WHERE (ce.order_id=request->order_id)
    AND ce.parent_event_id=ce.event_id
    AND ce.event_class_cd=group_class_cd)
  DETAIL
   reply->root_event_id = ce.event_id
  WITH nocounter
 ;end select
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
 IF (action_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "015 04/18/23"
 SET modify = nopredeclare
END GO
