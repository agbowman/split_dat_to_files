CREATE PROGRAM bhs_athn_get_order_catalog_v2
 DECLARE moutputdevice = vc WITH noconstant( $1)
 FREE RECORD out_rec
 RECORD out_rec(
   1 order_synonyms[*]
     2 synonym_id = vc
     2 mnemonic = vc
     2 catalog_cd = vc
     2 catalog_mean = vc
     2 catalog_disp = vc
     2 catalog_type_cd = vc
     2 catalog_type_mean = vc
     2 catalog_type_disp = vc
     2 activity_type_cd = vc
     2 activity_type_mean = vc
     2 activity_type_disp = vc
     2 activity_subtype = vc
     2 stop_type_cd = f8
     2 stop_type_mean = vc
     2 stop_type_disp = vc
     2 stop_duration = f8
     2 stop_duration_unit_cd = f8
     2 stop_duration_unit = vc
     2 multiple_order_sent_ind = i2
     2 witness_flag = i2
     2 clinical_category_cd = vc
     2 clinical_category_mean = vc
     2 clinical_category_disp = vc
     2 synonym_cki = vc
     2 catalog_cki = vc
     2 rounding_rule_cd = f8
     2 lock_target_dose_ind = i2
     2 max_dose_calc_bsa_value = f8
     2 max_final_dose = f8
     2 max_final_dose_unit_cd = f8
     2 preferred_dose_flag = i2
     2 order_format_id = vc
     2 order_comment = vc
     2 dup_order_check_ind = i2
     2 exact_hit_action = vc
     2 min_ahead = f8
     2 min_ahead_action = vc
     2 min_behind = f8
     2 min_behind_action = vc
     2 disable_order_comment_flag = i2
     2 dup_check_sequence = f8
     2 outpat_flex_indicator = i2
     2 outpat_exact_hit_action = vc
     2 outpat_min_ahead = f8
     2 outpat_min_ahead_action = vc
     2 outpat_min_behind = f8
     2 outpat_min_behind_action = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_mean = vc
     2 activity_subtype_disp = vc
     2 diluent_ind = i2
     2 additive_ind = i2
     2 med_ind = i2
     2 slidingscale_ind = i2
     2 titrateable_ind = i2
     2 modifiable_flag = i2
     2 order_sentence_list[*]
       3 encounter_group = vc
       3 order_sentence_display_line = vc
       3 order_sentence_id = vc
       3 order_sentences[*]
         4 field_meaning_id = f8
         4 field_id = f8
         4 attribute_name = vc
         4 display_value = vc
         4 value = f8
 )
 SELECT INTO "nl:"
  FROM order_catalog_synonym o,
   order_sentence os,
   order_sentence_detail osd,
   order_entry_fields oe,
   order_catalog_text oct,
   long_text l,
   long_text ll,
   order_catalog oc,
   dup_checking d
  PLAN (o
   WHERE (o.synonym_id= $2))
   JOIN (os
   WHERE (os.parent_entity_id= Outerjoin(o.synonym_id))
    AND (os.order_sentence_id= Outerjoin( $3)) )
   JOIN (osd
   WHERE (osd.order_sentence_id= Outerjoin(os.order_sentence_id)) )
   JOIN (oe
   WHERE (oe.oe_field_id= Outerjoin(osd.oe_field_id)) )
   JOIN (oct
   WHERE (oct.catalog_cd= Outerjoin(o.catalog_cd)) )
   JOIN (l
   WHERE (l.long_text_id= Outerjoin(oct.long_text_id)) )
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (d
   WHERE (d.catalog_cd= Outerjoin(o.catalog_cd))
    AND (d.active_ind= Outerjoin(1)) )
   JOIN (ll
   WHERE (ll.long_text_id= Outerjoin(os.ord_comment_long_text_id)) )
  ORDER BY o.synonym_id, os.order_sentence_id
  HEAD REPORT
   cnt = 0
  HEAD o.synonym_id
   cnt += 1, stat = alterlist(out_rec->order_synonyms,cnt), out_rec->order_synonyms[cnt].synonym_id
    = cnvtstring(o.synonym_id),
   mnemonic = trim(o.mnemonic,3), pr_mnemonic = trim(oc.primary_mnemonic,3)
   IF (pr_mnemonic=mnemonic)
    displaytext = build(pr_mnemonic)
   ELSE
    displaytext = build(pr_mnemonic," (",mnemonic,")")
   ENDIF
   IF (textlen(displaytext) > 100)
    out_rec->order_synonyms[cnt].mnemonic = trim(pr_mnemonic,3)
   ELSE
    out_rec->order_synonyms[cnt].mnemonic = trim(displaytext,3)
   ENDIF
   out_rec->order_synonyms[cnt].catalog_cd = cnvtstring(o.catalog_cd), out_rec->order_synonyms[cnt].
   catalog_mean = trim(uar_get_code_meaning(o.catalog_cd),3), out_rec->order_synonyms[cnt].
   catalog_disp = trim(uar_get_code_display(o.catalog_cd),3),
   out_rec->order_synonyms[cnt].catalog_type_cd = cnvtstring(o.catalog_type_cd), out_rec->
   order_synonyms[cnt].catalog_type_disp = uar_get_code_display(o.catalog_type_cd), out_rec->
   order_synonyms[cnt].catalog_type_mean = uar_get_code_meaning(o.catalog_type_cd),
   out_rec->order_synonyms[cnt].activity_type_cd = cnvtstring(o.activity_type_cd), out_rec->
   order_synonyms[cnt].activity_type_mean = uar_get_code_meaning(o.activity_type_cd), out_rec->
   order_synonyms[cnt].activity_type_disp = trim(uar_get_code_display(o.activity_type_cd),3),
   out_rec->order_synonyms[cnt].activity_subtype = cnvtstring(o.activity_subtype_cd), out_rec->
   order_synonyms[cnt].stop_type_cd = oc.stop_type_cd, out_rec->order_synonyms[cnt].stop_type_mean =
   trim(uar_get_code_meaning(oc.stop_type_cd),3),
   out_rec->order_synonyms[cnt].stop_type_disp = trim(uar_get_code_display(oc.stop_type_cd),3),
   out_rec->order_synonyms[cnt].stop_duration = oc.stop_duration, out_rec->order_synonyms[cnt].
   stop_duration_unit_cd = oc.stop_duration_unit_cd,
   out_rec->order_synonyms[cnt].stop_duration_unit = uar_get_code_meaning(oc.stop_duration_unit_cd),
   out_rec->order_synonyms[cnt].multiple_order_sent_ind = o.multiple_ord_sent_ind, out_rec->
   order_synonyms[cnt].witness_flag = o.witness_flag,
   out_rec->order_synonyms[cnt].clinical_category_cd = cnvtstring(o.dcp_clin_cat_cd), out_rec->
   order_synonyms[cnt].clinical_category_mean = trim(uar_get_code_meaning(o.dcp_clin_cat_cd),3),
   out_rec->order_synonyms[cnt].clinical_category_disp = trim(uar_get_code_display(o.dcp_clin_cat_cd),
    3),
   out_rec->order_synonyms[cnt].synonym_cki = trim(o.cki,3), out_rec->order_synonyms[cnt].catalog_cki
    = trim(oc.cki,3), out_rec->order_synonyms[cnt].rounding_rule_cd = o.rounding_rule_cd,
   out_rec->order_synonyms[cnt].lock_target_dose_ind = o.lock_target_dose_ind, out_rec->
   order_synonyms[cnt].max_dose_calc_bsa_value = o.max_dose_calc_bsa_value, out_rec->order_synonyms[
   cnt].max_final_dose = o.max_final_dose,
   out_rec->order_synonyms[cnt].max_final_dose_unit_cd = o.max_final_dose_unit_cd, out_rec->
   order_synonyms[cnt].preferred_dose_flag = o.preferred_dose_flag, out_rec->order_synonyms[cnt].
   order_format_id = cnvtstring(o.oe_format_id),
   def_ord_comment = substring(1,500,trim(l.long_text,3)), def_sen_comment = substring(1,500,trim(ll
     .long_text,3))
   IF (def_sen_comment != " ")
    out_rec->order_synonyms[cnt].order_comment = trim(replace(def_sen_comment,"–","-",0),3)
   ELSE
    out_rec->order_synonyms[cnt].order_comment = trim(replace(def_ord_comment,"–","-",0),3)
   ENDIF
   out_rec->order_synonyms[cnt].dup_order_check_ind = oc.dup_checking_ind, out_rec->order_synonyms[
   cnt].exact_hit_action = uar_get_code_display(d.exact_hit_action_cd), out_rec->order_synonyms[cnt].
   min_ahead = d.min_ahead,
   out_rec->order_synonyms[cnt].min_ahead_action = uar_get_code_display(d.min_ahead_action_cd),
   out_rec->order_synonyms[cnt].min_behind = d.min_behind, out_rec->order_synonyms[cnt].
   min_behind_action = uar_get_code_display(d.min_behind_action_cd),
   out_rec->order_synonyms[cnt].disable_order_comment_flag = oc.disable_order_comment_ind, out_rec->
   order_synonyms[cnt].dup_check_sequence = d.dup_check_seq, out_rec->order_synonyms[cnt].
   outpat_flex_indicator = d.outpat_flex_ind,
   out_rec->order_synonyms[cnt].outpat_exact_hit_action = uar_get_code_display(d
    .outpat_exact_hit_action_cd), out_rec->order_synonyms[cnt].outpat_min_ahead = d.outpat_min_ahead,
   out_rec->order_synonyms[cnt].outpat_min_ahead_action = uar_get_code_display(d
    .outpat_min_ahead_action_cd),
   out_rec->order_synonyms[cnt].outpat_min_behind = d.outpat_min_behind, out_rec->order_synonyms[cnt]
   .outpat_min_behind_action = uar_get_code_display(d.outpat_min_behind_action_cd), out_rec->
   order_synonyms[cnt].activity_subtype_cd = o.activity_subtype_cd,
   out_rec->order_synonyms[cnt].activity_subtype_mean = trim(uar_get_code_meaning(o
     .activity_subtype_cd),3), out_rec->order_synonyms[cnt].activity_subtype_disp = trim(
    uar_get_code_display(o.activity_subtype_cd),3), out_rec->order_synonyms[cnt].diluent_ind =
   evaluate(band(o.rx_mask,1),0,0,1),
   out_rec->order_synonyms[cnt].additive_ind = evaluate(band(o.rx_mask,2),0,0,1), out_rec->
   order_synonyms[cnt].med_ind = evaluate(band(o.rx_mask,4),0,0,1), out_rec->order_synonyms[cnt].
   slidingscale_ind = evaluate(band(o.rx_mask,16),0,0,1),
   out_rec->order_synonyms[cnt].titrateable_ind = o.ingredient_rate_conversion_ind, out_rec->
   order_synonyms[cnt].modifiable_flag = oc.modifiable_flag, cnt1 = 0
  HEAD os.order_sentence_id
   cnt1 += 1, stat = alterlist(out_rec->order_synonyms[cnt].order_sentence_list,cnt1), out_rec->
   order_synonyms[cnt].order_sentence_list[cnt1].order_sentence_id = cnvtstring(os.order_sentence_id),
   out_rec->order_synonyms[cnt].order_sentence_list[cnt1].order_sentence_display_line = trim(os
    .order_sentence_display_line,3), out_rec->order_synonyms[cnt].order_sentence_list[cnt1].
   encounter_group = trim(uar_get_code_display(os.order_encntr_group_cd),3), cnt2 = 0
  DETAIL
   cnt2 += 1, stat = alterlist(out_rec->order_synonyms[cnt].order_sentence_list[cnt1].order_sentences,
    cnt2), out_rec->order_synonyms[cnt].order_sentence_list[cnt1].order_sentences[cnt2].
   field_meaning_id = osd.oe_field_meaning_id,
   out_rec->order_synonyms[cnt].order_sentence_list[cnt1].order_sentences[cnt2].field_id = osd
   .oe_field_id, out_rec->order_synonyms[cnt].order_sentence_list[cnt1].order_sentences[cnt2].
   attribute_name = trim(oe.description,3), out_rec->order_synonyms[cnt].order_sentence_list[cnt1].
   order_sentences[cnt2].display_value = trim(osd.oe_field_display_value,3),
   out_rec->order_synonyms[cnt].order_sentence_list[cnt1].order_sentences[cnt2].value =
   IF (osd.default_parent_entity_name="CODE_VALUE") osd.default_parent_entity_id
   ELSE
    IF (osd.oe_field_value > 0) osd.oe_field_value
    ELSE 0
    ENDIF
   ENDIF
  WITH time = 30
 ;end select
 EXECUTE bhs_athn_write_json_output  WITH replace("OUT_REC","OUT_REC"), replace("OUT_REC","OUT_REC")
END GO
