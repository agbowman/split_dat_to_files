CREATE PROGRAM aps_oe_fmtflds_load:dba
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 6006
 SET cdf_meaning = "WRITTEN"
 EXECUTE cpm_get_cd_for_cdf
 SET oe_format_info->communication_type_cd = code_value
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET mnemonic_type_cd = code_value
 SET nbr_to_get = cnvtint(size(oe_format_info->qual,5))
 SELECT INTO "nl:"
  dt.seq, oc.catalog_cd, ocs.catalog_cd,
  ocs.oe_format_id, fields_exist = decode(off.seq,"Y","N"), oef.oe_field_id,
  ofm.oe_field_meaning
  FROM (dummyt dt  WITH seq = value(nbr_to_get)),
   order_catalog oc,
   order_catalog_synonym ocs,
   (dummyt d1  WITH seq = 1),
   oe_format_fields off,
   order_entry_fields oef,
   oe_field_meaning ofm
  PLAN (dt)
   JOIN (oc
   WHERE (oe_format_info->qual[dt.seq].catalog_cd=oc.catalog_cd))
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND mnemonic_type_cd=ocs.mnemonic_type_cd)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (off
   WHERE ocs.oe_format_id=off.oe_format_id
    AND (oe_format_info->qual[dt.seq].action_type_cd=off.action_type_cd))
   JOIN (oef
   WHERE off.oe_field_id=oef.oe_field_id)
   JOIN (ofm
   WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id)
  ORDER BY dt.seq
  HEAD REPORT
   count1 = 0
  HEAD dt.seq
   count2 = 0, count1 += 1, oe_format_info->qual[count1].primary_mnemonic = oc.primary_mnemonic,
   oe_format_info->qual[count1].dept_display_name = oc.dept_display_name, oe_format_info->qual[count1
   ].activity_type_cd = oc.activity_type_cd, oe_format_info->qual[count1].activity_subtype_cd = oc
   .activity_subtype_cd,
   oe_format_info->qual[count1].cont_order_method_flag = oc.cont_order_method_flag, oe_format_info->
   qual[count1].complete_upon_order_ind = oc.complete_upon_order_ind, oe_format_info->qual[count1].
   order_review_ind = oc.order_review_ind,
   oe_format_info->qual[count1].print_req_ind = oc.print_req_ind, oe_format_info->qual[count1].
   requisition_format_cd = oc.requisition_format_cd, oe_format_info->qual[count1].
   requisition_routing_cd = oc.requisition_routing_cd,
   oe_format_info->qual[count1].resource_route_lvl = oc.resource_route_lvl, oe_format_info->qual[
   count1].consent_form_ind = oc.consent_form_ind, oe_format_info->qual[count1].
   consent_form_format_cd = oc.consent_form_format_cd,
   oe_format_info->qual[count1].consent_form_routing_cd = oc.consent_form_routing_cd, oe_format_info
   ->qual[count1].dept_dup_check_ind = oc.dept_dup_check_ind, oe_format_info->qual[count1].
   abn_review_ind = oc.abn_review_ind,
   oe_format_info->qual[count1].review_hierarchy_id = oc.review_hierarchy_id, oe_format_info->qual[
   count1].ref_text_mask = oc.ref_text_mask, oe_format_info->qual[count1].dup_checking_ind = oc
   .dup_checking_ind,
   oe_format_info->qual[count1].orderable_type_flag = oc.orderable_type_flag, oe_format_info->qual[
   count1].catalog_type_cd = ocs.catalog_type_cd, oe_format_info->qual[count1].synonym_id = ocs
   .synonym_id,
   oe_format_info->qual[count1].mnemonic = ocs.mnemonic, oe_format_info->qual[count1].oe_format_id =
   ocs.oe_format_id
  DETAIL
   IF (fields_exist="Y")
    count2 += 1
    IF (count2 > size(oe_format_info->qual[count1].fldqual,5))
     stat = alterlist(oe_format_info->qual[count1].fldqual,(count2+ 10))
    ENDIF
    oe_format_info->qual[count1].fldqual[count2].oe_field_id = off.oe_field_id, oe_format_info->qual[
    count1].fldqual[count2].value_required_ind = off.value_required_ind, oe_format_info->qual[count1]
    .fldqual[count2].group_seq = off.group_seq,
    oe_format_info->qual[count1].fldqual[count2].field_seq = off.field_seq, oe_format_info->qual[
    count1].fldqual[count2].default_value_id = cnvtreal(validate(off.default_parent_entity_id,off
      .default_value)), oe_format_info->qual[count1].fldqual[count2].default_value = off
    .default_value,
    oe_format_info->qual[count1].fldqual[count2].oe_field_meaning_id = oef.oe_field_meaning_id,
    oe_format_info->qual[count1].fldqual[count2].oe_field_meaning = ofm.oe_field_meaning
   ENDIF
  FOOT  dt.seq
   oe_format_info->qual[count1].fldqual_cnt = count2, stat = alterlist(oe_format_info->qual[count1].
    fldqual,count2)
  WITH nocounter, outerjoin = d1, check
 ;end select
END GO
