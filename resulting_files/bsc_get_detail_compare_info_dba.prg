CREATE PROGRAM bsc_get_detail_compare_info:dba
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 med_order_type_cd = f8
   1 action_cnt = i4
   1 action_qual[*]
     2 action_type_cd = f8
     2 action_type_disp = c40
     2 action_type_mean = c12
     2 action_sequence = i4
     2 core_ind = i2
     2 action_rejected_ind = i2
     2 action_personnel_id = f8
     2 communication_type_cd = f8
     2 communication_type_disp = c40
     2 provider_id = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 order_dt_tm = dq8
     2 order_tz = i4
     2 effective_tz = i4
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c12
     2 dept_status_cd = f8
     2 dept_status_disp = c40
     2 undo_action_type_cd = f8
     2 undo_action_type_disp = c40
     2 medstudent_action_ind = i2
     2 detail_qual_cnt = i4
     2 need_rx_clin_review_flag = i2
     2 detail_qual[*]
       3 label_text = vc
       3 group_seq = i4
       3 field_seq = i4
       3 oe_field_display_value = vc
       3 oe_field_id = f8
       3 oe_field_dt_tm = dq8
       3 oe_field_tz = i4
       3 oe_field_meaning_id = f8
       3 oe_field_value = f8
     2 comment_flag = i2
     2 comment_text = vc
     2 ingredient_qual_cnt = i4
     2 ingredient_qual[*]
       3 order_mnemonic = vc
       3 hna_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_detail_display_line = vc
       3 catalog_cd = f8
       3 synonym_id = f8
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 dose_quantity = f8
       3 dose_quantity_unit = f8
       3 include_in_total_volume_flag = i2
       3 ingredient_type_flag = i2
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET map_request
 RECORD map_request(
   1 mapping_ind = i2
   1 map_from_value = i2
 )
 FREE SET map_reply
 RECORD map_reply(
   1 map_to_value = i2
 )
 FREE SET review_flag_map
 RECORD review_flag_map(
   1 action[*]
     2 needs_verify_ind = i4
     2 need_clin_review_flag = i4
     2 mapped_clin_review_flag = i4
 )
 DECLARE coreind = i4 WITH noconstant(0)
 DECLARE action_cnt = i4 WITH noconstant(0)
 DECLARE detail_cnt = i4 WITH noconstant(0)
 DECLARE ing_cnt = i4 WITH noconstant(0)
 DECLARE comment_type_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE new_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE renew_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"RENEW"))
 DECLARE activate_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE resume_renew_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"RESUME/RENEW"
   ))
 DECLARE collection_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"COLLECTION"))
 DECLARE discharge_action_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,
   "DISORDER"))
 DECLARE med_order_iv_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE med_order_intermittent_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"INTERMITTENT")
  )
 DECLARE med_order_med_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 SET target_action_type_cd = new_action_type_cd
 SELECT INTO "nl:"
  nullactdttm = nullind(oa.action_dt_tm), nullorddttm = nullind(oa.order_dt_tm), check = decode(off
   .seq,"off",oi.seq,"oi",oa.seq,
   "oa","n")
  FROM order_action oa,
   (dummyt d1  WITH seq = 1),
   order_ingredient oi,
   (dummyt d2  WITH seq = 1),
   order_detail od,
   orders os,
   oe_format_fields off
  PLAN (oa
   WHERE (oa.order_id=request->order_id))
   JOIN (os
   WHERE os.order_id=oa.order_id)
   JOIN (d1)
   JOIN (((oi
   WHERE oi.order_id=oa.order_id
    AND oi.action_sequence=oa.action_sequence
    AND oi.ingredient_type_flag != icompoundchild)
   ) ORJOIN ((d2)
   JOIN (od
   WHERE od.order_id=oa.order_id
    AND od.action_sequence=oa.action_sequence
    AND od.oe_field_meaning_id != 125
    AND od.oe_field_meaning_id != 2071
    AND od.oe_field_meaning_id != 2094)
   JOIN (off
   WHERE off.oe_format_id=os.oe_format_id
    AND ((off.action_type_cd=oa.action_type_cd) OR (off.action_type_cd=target_action_type_cd))
    AND off.oe_field_id=od.oe_field_id)
   ))
  ORDER BY oa.action_sequence DESC, od.oe_field_id, od.detail_sequence,
   oi.order_id, oi.comp_sequence
  HEAD REPORT
   action_cnt = 0, reply->med_order_type_cd = os.med_order_type_cd, reply->person_id = os.person_id,
   reply->encntr_id = os.encntr_id
  HEAD oa.action_sequence
   detail_cnt = 0, ing_cnt = 0, ing_case_cnt = 0,
   action_cnt = (action_cnt+ 1)
   IF (action_cnt > size(reply->action_qual,5))
    stat = alterlist(reply->action_qual,(action_cnt+ 5))
   ENDIF
   reply->action_qual[action_cnt].action_type_cd = oa.action_type_cd, reply->action_qual[action_cnt].
   action_sequence = oa.action_sequence, reply->action_qual[action_cnt].core_ind = oa.core_ind,
   reply->action_qual[action_cnt].action_rejected_ind = oa.action_rejected_ind, reply->action_qual[
   action_cnt].action_personnel_id = oa.action_personnel_id, reply->action_qual[action_cnt].
   communication_type_cd = oa.communication_type_cd,
   reply->action_qual[action_cnt].provider_id = oa.order_provider_id, reply->action_qual[action_cnt].
   catalog_type_cd = os.catalog_type_cd
   IF (nullactdttm=0)
    reply->action_qual[action_cnt].action_dt_tm = cnvtdatetime(oa.action_dt_tm), reply->action_qual[
    action_cnt].action_tz = oa.action_tz, reply->action_qual[action_cnt].effective_tz = oa
    .effective_tz
   ENDIF
   IF (nullorddttm=0)
    reply->action_qual[action_cnt].order_dt_tm = cnvtdatetime(oa.order_dt_tm), reply->action_qual[
    action_cnt].order_tz = oa.order_tz
   ENDIF
   reply->action_qual[action_cnt].order_status_cd = oa.order_status_cd, reply->action_qual[action_cnt
   ].dept_status_cd = oa.dept_status_cd, reply->action_qual[action_cnt].undo_action_type_cd = oa
   .undo_action_type_cd,
   reply->action_qual[action_cnt].medstudent_action_ind = oa.medstudent_action_ind
   IF (oa.action_type_cd=modify_action_type_cd)
    label_action_type_cd = target_action_type_cd
   ELSEIF (oa.action_type_cd=renew_action_type_cd)
    label_action_type_cd = target_action_type_cd
   ELSEIF (oa.action_type_cd=activate_action_type_cd)
    label_action_type_cd = target_action_type_cd
   ELSEIF (oa.action_type_cd=resume_renew_action_type_cd)
    label_action_type_cd = target_action_type_cd
   ELSEIF (oa.action_type_cd=collection_action_type_cd)
    label_action_type_cd = target_action_type_cd
   ELSEIF (oa.action_type_cd=new_action_type_cd)
    label_action_type_cd = target_action_type_cd
   ELSE
    label_action_type_cd = oa.action_type_cd
   ENDIF
  DETAIL
   IF (check="off")
    IF (off.action_type_cd=label_action_type_cd)
     detail_cnt = (detail_cnt+ 1)
     IF (detail_cnt > size(reply->action_qual[action_cnt].detail_qual,5))
      stat = alterlist(reply->action_qual[action_cnt].detail_qual,(detail_cnt+ 5))
     ENDIF
     IF (size(od.oe_field_display_value,1) > 0)
      reply->action_qual[action_cnt].detail_qual[detail_cnt].oe_field_display_value = trim(od
       .oe_field_display_value,3)
     ENDIF
     IF (od.oe_field_dt_tm_value > null)
      reply->action_qual[action_cnt].detail_qual[detail_cnt].oe_field_dt_tm = od.oe_field_dt_tm_value,
      reply->action_qual[action_cnt].detail_qual[detail_cnt].oe_field_tz = od.oe_field_tz
     ENDIF
     reply->action_qual[action_cnt].detail_qual[detail_cnt].oe_field_id = od.oe_field_id, reply->
     action_qual[action_cnt].detail_qual[detail_cnt].label_text = off.label_text, reply->action_qual[
     action_cnt].detail_qual[detail_cnt].group_seq = off.group_seq,
     reply->action_qual[action_cnt].detail_qual[detail_cnt].field_seq = off.field_seq, reply->
     action_qual[action_cnt].detail_qual[detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id,
     reply->action_qual[action_cnt].detail_qual[detail_cnt].oe_field_value = od.oe_field_value
    ENDIF
   ELSEIF (check="oi")
    ing_case_cnt = (ing_case_cnt+ 1), ing_cnt = (ing_cnt+ 1)
    IF (ing_cnt > size(reply->action_qual[action_cnt].ingredient_qual,5))
     stat = alterlist(reply->action_qual[action_cnt].ingredient_qual,(ing_cnt+ 5))
    ENDIF
    reply->action_qual[action_cnt].ingredient_qual[ing_cnt].order_mnemonic = oi.order_mnemonic, reply
    ->action_qual[action_cnt].ingredient_qual[ing_cnt].hna_mnemonic = oi.hna_order_mnemonic, reply->
    action_qual[action_cnt].ingredient_qual[ing_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
    reply->action_qual[action_cnt].ingredient_qual[ing_cnt].order_detail_display_line = oi
    .order_detail_display_line, reply->action_qual[action_cnt].ingredient_qual[ing_cnt].catalog_cd =
    oi.catalog_cd, reply->action_qual[action_cnt].ingredient_qual[ing_cnt].synonym_id = oi.synonym_id,
    reply->action_qual[action_cnt].ingredient_qual[ing_cnt].strength = oi.strength, reply->
    action_qual[action_cnt].ingredient_qual[ing_cnt].strength_unit = oi.strength_unit, reply->
    action_qual[action_cnt].ingredient_qual[ing_cnt].volume = oi.volume,
    reply->action_qual[action_cnt].ingredient_qual[ing_cnt].volume_unit = oi.volume_unit, reply->
    action_qual[action_cnt].ingredient_qual[ing_cnt].dose_quantity = oi.dose_quantity, reply->
    action_qual[action_cnt].ingredient_qual[ing_cnt].dose_quantity_unit = oi.dose_quantity_unit,
    reply->action_qual[action_cnt].ingredient_qual[ing_cnt].include_in_total_volume_flag = oi
    .include_in_total_volume_flag, reply->action_qual[action_cnt].ingredient_qual[ing_cnt].
    ingredient_type_flag = oi.ingredient_type_flag, reply->action_qual[action_cnt].ingredient_qual[
    ing_cnt].normalized_rate = oi.normalized_rate,
    reply->action_qual[action_cnt].ingredient_qual[ing_cnt].normalized_rate_unit_cd = oi
    .normalized_rate_unit_cd
   ENDIF
  FOOT  oa.action_sequence
   reply->action_qual[action_cnt].detail_qual_cnt = detail_cnt, reply->action_qual[action_cnt].
   ingredient_qual_cnt = ing_cnt, stat = alterlist(reply->action_qual[action_cnt].detail_qual,
    detail_cnt),
   stat = alterlist(reply->action_qual[action_cnt].ingredient_qual,ing_cnt)
  WITH outerjoin = d1
 ;end select
 SET reply->action_cnt = action_cnt
 SET stat = alterlist(reply->action_qual,action_cnt)
 SELECT INTO "nl:"
  oa.order_id, oa.action_sequence, lt.long_text_id,
  oc.order_id, oc.action_sequence, oc.comment_type_cd,
  check = decode(lt.seq,"lt","n")
  FROM order_action oa,
   (dummyt d3  WITH seq = 1),
   order_comment oc,
   long_text lt
  PLAN (oa
   WHERE (oa.order_id=request->order_id))
   JOIN (d3)
   JOIN (oc
   WHERE oc.order_id=oa.order_id
    AND oc.action_sequence=oa.action_sequence
    AND oc.comment_type_cd=comment_type_cd)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind=1)
  ORDER BY oa.action_sequence DESC
  HEAD REPORT
   action_cnt = 0
  HEAD oa.action_sequence
   action_cnt = (action_cnt+ 1)
  DETAIL
   IF (check="lt")
    reply->action_qual[action_cnt].comment_text = lt.long_text, reply->action_qual[action_cnt].
    comment_flag = 1
   ENDIF
  WITH outerjoin = d3
 ;end select
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE actionseq = i4 WITH protect, noconstant(1)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE last_core_action_seq = i4 WITH noconstant(1)
 DECLARE last_core_seq_found = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM order_action oa
  WHERE (oa.order_id=request->order_id)
  ORDER BY oa.action_sequence
  HEAD REPORT
   action_cnt = 0
  DETAIL
   action_cnt = (action_cnt+ 1)
   IF (action_cnt > size(review_flag_map->action,5))
    stat = alterlist(review_flag_map->action,(action_cnt+ 9))
   ENDIF
   review_flag_map->action[action_cnt].need_clin_review_flag = oa.need_clin_review_flag,
   review_flag_map->action[action_cnt].needs_verify_ind = oa.needs_verify_ind
  FOOT REPORT
   stat = alterlist(review_flag_map->action,action_cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(review_flag_map->action,5))
   IF ((review_flag_map->action[i].need_clin_review_flag=0))
    SET map_request->mapping_ind = 2
    SET map_request->map_from_value = review_flag_map->action[i].needs_verify_ind
    SET modify = nopredeclare
    EXECUTE dcp_map_clin_review_flag  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
     "MAP_REPLY")
    SET modify = predeclare
    SET review_flag_map->action[i].mapped_clin_review_flag = map_reply->map_to_value
   ELSE
    SET review_flag_map->action[i].mapped_clin_review_flag = review_flag_map->action[i].
    need_clin_review_flag
   ENDIF
 ENDFOR
 SET actionseq = action_cnt
 SELECT INTO "nl:"
  FROM order_action oa
  WHERE (oa.order_id=request->order_id)
   AND oa.action_sequence <= actionseq
  ORDER BY oa.action_sequence DESC
  HEAD REPORT
   bfound = 0
  DETAIL
   IF (last_core_seq_found=0
    AND oa.core_ind=1)
    last_core_action_seq = oa.action_sequence, last_core_seq_found = 1
   ENDIF
   IF (bfound=0
    AND oa.action_sequence <= size(review_flag_map->action,5))
    IF ((review_flag_map->action[oa.action_sequence].mapped_clin_review_flag != 4))
     actionseq = oa.action_sequence, bfound = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (bfound=0)
  SET actionseq = last_core_action_seq
 ENDIF
 IF (actionseq <= size(review_flag_map->action,5))
  FOR (i = 1 TO action_cnt)
    SET reply->action_qual[i].need_rx_clin_review_flag = review_flag_map->action[actionseq].
    mapped_clin_review_flag
  ENDFOR
 ENDIF
 IF ((reply->action_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "MOD 001 PK028395 25/02/2015"
END GO
