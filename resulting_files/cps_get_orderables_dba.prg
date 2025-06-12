CREATE PROGRAM cps_get_orderables:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 more_ind = i2
   1 exact_ind = i2
   1 catalog_qual = i4
   1 catalog_item[*]
     2 synonym_id = f8
     2 order_sentence_id = f8
     2 catalog_cd = f8
     2 catalog_disp = c40
     2 oe_format_id = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 mnemonic = vc
     2 primary_mnemonic = vc
     2 mnemonic_key_cap = vc
     2 mnemonic_type_cd = f8
     2 ref_text_mask = i4
     2 prep_info_flag = i2
     2 auto_invoke_prep_ind = i2
     2 cki = vc
     2 synonym_cki = vc
     2 dup_checking_ind = i2
     2 orderable_type_flag = i2
     2 category_name = vc
     2 category_id = f8
     2 virtual_view = vc
     2 health_plan_view = vc
     2 comment_template_flag = i2
     2 disable_order_comment_ind = i2
     2 infoscan_item[*]
       3 health_plan_id = f8
       3 non_formu_cvrg_flag = i2
       3 policy_unlisted_drug_flag = i2
       3 policy_generic_drug_flag = i2
       3 policy_brand_reimburse_flag = i2
       3 policy_brand_interchg_flag = i2
       3 tier_flag = i2
       3 drug_qual[*]
         4 cki = vc
         4 main_multum_drug_code = i4
         4 prod_formu_qual[*]
           5 prod_formu_status_flag = i2
           5 note_qual[*]
             6 note_identifier = c10
             6 note_advise_restrict_ind = i2
             6 notes = vc
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ifacilitytableexists = i2 WITH protect, noconstant(0)
 DECLARE ifacilityind = i2 WITH protect, noconstant(0)
 DECLARE specific_ind = i2 WITH noconstant(0)
 DECLARE nurse_prep_cd = f8 WITH constant(uar_get_code_by("MEANING",6009,"NURSE PREP"))
 SET dvar = 0
 SET context_ind = 0
 SET code_set = 6011
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 IF ((request->max_qual > 0))
  SET max_qual = (request->max_qual+ 1)
 ELSE
  SET max_qual = (100+ 1)
 ENDIF
 SET exact_str = cnvtupper(trim(request->search_string))
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET context_ind = 1
 ELSE
  FREE SET context
  RECORD context(
    1 context_ind = i4
    1 search_flag = i2
    1 max_qual = i2
    1 product_ind = i2
    1 virtual_offset = i4
    1 facility_cd = f8
    1 synonym_id = f8
    1 mnemonic_key_cap = vc
    1 end_search = vc
    1 cat_qual = i4
    1 cat[*]
      2 catalog_type_cd = f8
  )
  SET context->cat_qual = request->cat_qual
  SET context->max_qual = request->max_qual
  SET context->product_ind = request->product_ind
  SET context->virtual_offset = request->virtual_offset
  SET context->facility_cd = request->facility_cd
  SET context->search_flag = request->search_flag
  IF ((request->search_string > " "))
   SET context->mnemonic_key_cap = cnvtupper(trim(request->search_string))
   SET context->end_search = cnvtupper(concat(trim(request->search_string),"ZZZZ"))
  ELSE
   SET context->mnemonic_key_cap = " "
   SET failed = input_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SEARCH_STRING"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The search string must be greater than a blank"
   GO TO exit_script
  ENDIF
  IF ((request->cat_qual > 0))
   SET stat = alterlist(context->cat,request->cat_qual)
   FOR (i = 1 TO request->cat_qual)
     SET context->cat[i].catalog_type_cd = request->cat[i].catalog_type_cd
   ENDFOR
  ENDIF
 ENDIF
 SET cdf_meaning = "GENERICPROD"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET genericprod_cd = code_value
 SET cdf_meaning = "GENERICTOP"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET generictop_cd = code_value
 SET cdf_meaning = "TRADEPROD"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET tradeprod_cd = code_value
 SET cdf_meaning = "TRADETOP"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET tradetop_cd = code_value
 SET cdf_meaning = "IVNAME"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET ivname_cd = code_value
 SET cdf_meaning = "PRIMARY"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET primary_cd = code_value
 SET cdf_meaning = "BRANDNAME"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET brandname_cd = code_value
 SET cdf_meaning = "DISPDRUG"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET dispdrug_cd = code_value
 SET cdf_meaning = "DCP"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET dcp_cd = code_value
 SELECT INTO "nl:"
  FROM dba_tables dt
  WHERE dt.table_name="OCS_FACILITY_R"
   AND dt.owner="V500"
  DETAIL
   ifacilitytableexists = 1
  WITH nocounter
 ;end select
 IF ((context->facility_cd > 0)
  AND ifacilitytableexists=1)
  SET ifacilityind = 1
 ENDIF
 IF ((request->cat_qual > 0))
  CALL find_list_cat(dvar)
  CALL process_infoscan(dvar)
 ELSE
  CALL find_list(dvar)
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_facility_r rtfr,
   ref_text_version rtv,
   (dummyt d  WITH seq = value(size(reply->catalog_item,5)))
  PLAN (d)
   JOIN (rtfr
   WHERE (rtfr.parent_entity_id=reply->catalog_item[d.seq].catalog_cd)
    AND rtfr.parent_entity_name="ORDER_CATALOG"
    AND rtfr.facility_cd=0
    AND rtfr.text_type_cd=nurse_prep_cd)
   JOIN (rtv
   WHERE rtv.ref_text_variation_id=rtfr.ref_text_variation_id
    AND rtv.active_ind=1)
  HEAD rtfr.parent_entity_id
   specific_ind = 0
  DETAIL
   IF (specific_ind=0)
    IF (rtfr.facility_cd != 0)
     CALL echo(build("Found a specific facility_cd for entity id:",rtfr.parent_entity_id)),
     specific_ind = 1
    ENDIF
    reply->catalog_item[d.seq].auto_invoke_prep_ind = rtv.auto_invoke_prep_ind
   ENDIF
  WITH nocounter
 ;end select
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_CATALOG_SYNONYM"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
 GO TO exit_script
 SUBROUTINE find_list_cat(lvar)
   IF ((context->search_flag=1))
    SET ierrcode = 0
    SELECT
     IF (ifacilityind > 0
      AND (context->product_ind > 0))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND  EXISTS (
       (SELECT
        ofr.synonym_id
        FROM ocs_facility_r ofr
        WHERE ofr.synonym_id=ocs.synonym_id
         AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=context->facility_cd))) )))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=oc.catalog_cd
        AND ocs2.mnemonic_type_cd=primary_cd)
       JOIN (d1)
       JOIN (al
       WHERE al.synonym_id=ocs2.synonym_id)
       JOIN (ac
       WHERE ac.alt_sel_category_id=al.alt_sel_category_id
        AND ac.owner_id < 1
        AND ac.security_flag=2
        AND ac.ahfs_ind=1
        AND ac.adhoc_ind IN (0, null))
     ELSEIF (ifacilityind > 0)
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd,
       tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND  EXISTS (
       (SELECT
        ofr.synonym_id
        FROM ocs_facility_r ofr
        WHERE ofr.synonym_id=ocs.synonym_id
         AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=context->facility_cd))) )))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=oc.catalog_cd
        AND ocs2.mnemonic_type_cd=primary_cd)
       JOIN (d1)
       JOIN (al
       WHERE al.synonym_id=ocs2.synonym_id)
       JOIN (ac
       WHERE ac.alt_sel_category_id=al.alt_sel_category_id
        AND ac.owner_id < 1
        AND ac.security_flag=2
        AND ac.ahfs_ind=1
        AND ac.adhoc_ind IN (0, null))
     ELSEIF ((context->product_ind > 0)
      AND (context->virtual_offset > 0)
      AND (context->virtual_offset < 101))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND substring(context->virtual_offset,1,ocs.virtual_view)="1")
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=oc.catalog_cd
        AND ocs2.mnemonic_type_cd=primary_cd)
       JOIN (d1)
       JOIN (al
       WHERE al.synonym_id=ocs2.synonym_id)
       JOIN (ac
       WHERE ac.alt_sel_category_id=al.alt_sel_category_id
        AND ac.owner_id < 1
        AND ac.security_flag=2
        AND ac.ahfs_ind=1
        AND ac.adhoc_ind IN (0, null))
     ELSEIF ((context->virtual_offset > 0)
      AND (context->virtual_offset < 101))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd,
       tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND substring(context->virtual_offset,1,ocs.virtual_view)="1")
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=oc.catalog_cd
        AND ocs2.mnemonic_type_cd=primary_cd)
       JOIN (d1)
       JOIN (al
       WHERE al.synonym_id=ocs2.synonym_id)
       JOIN (ac
       WHERE ac.alt_sel_category_id=al.alt_sel_category_id
        AND ac.owner_id < 1
        AND ac.security_flag=2
        AND ac.ahfs_ind=1
        AND ac.adhoc_ind IN (0, null))
     ELSEIF ((context->product_ind > 0))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null)))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=oc.catalog_cd
        AND ocs2.mnemonic_type_cd=primary_cd)
       JOIN (d1)
       JOIN (al
       WHERE al.synonym_id=ocs2.synonym_id)
       JOIN (ac
       WHERE ac.alt_sel_category_id=al.alt_sel_category_id
        AND ac.owner_id < 1
        AND ac.security_flag=2
        AND ac.ahfs_ind=1
        AND ac.adhoc_ind IN (0, null))
     ELSE
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd,
       tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null)))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.catalog_cd=oc.catalog_cd
        AND ocs2.mnemonic_type_cd=primary_cd)
       JOIN (d1)
       JOIN (al
       WHERE al.synonym_id=ocs2.synonym_id)
       JOIN (ac
       WHERE ac.alt_sel_category_id=al.alt_sel_category_id
        AND ac.owner_id < 1
        AND ac.security_flag=2
        AND ac.ahfs_ind=1
        AND ac.adhoc_ind IN (0, null))
     ENDIF
     DISTINCT INTO "nl:"
     ocs.synonym_id, ac.alt_sel_category_id
     FROM (dummyt d  WITH seq = value(context->cat_qual)),
      order_catalog_synonym ocs,
      order_catalog oc,
      order_catalog_synonym ocs2,
      alt_sel_list al,
      alt_sel_cat ac,
      (dummyt d1  WITH seq = 1)
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, ac.long_description_key_cap,
      0
     HEAD REPORT
      knt = 0, stat = alterlist(reply->catalog_item,10)
     HEAD ocs.mnemonic_key_cap
      dvar = 0
     HEAD ocs.synonym_id
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(reply->catalog_item,(knt+ 9))
      ENDIF
      reply->catalog_item[knt].synonym_id = ocs.synonym_id, reply->catalog_item[knt].
      order_sentence_id = ocs.order_sentence_id, reply->catalog_item[knt].catalog_cd = ocs.catalog_cd,
      reply->catalog_item[knt].oe_format_id = ocs.oe_format_id, reply->catalog_item[knt].
      activity_type_cd = ocs.activity_type_cd, reply->catalog_item[knt].activity_subtype_cd = ocs
      .activity_subtype_cd,
      reply->catalog_item[knt].catalog_type_cd = ocs.catalog_type_cd, reply->catalog_item[knt].
      mnemonic = ocs.mnemonic, reply->catalog_item[knt].primary_mnemonic = oc.description,
      reply->catalog_item[knt].mnemonic_key_cap = ocs.mnemonic_key_cap, reply->catalog_item[knt].
      mnemonic_type_cd = ocs.mnemonic_type_cd, reply->catalog_item[knt].ref_text_mask = oc
      .ref_text_mask,
      reply->catalog_item[knt].prep_info_flag = oc.prep_info_flag, reply->catalog_item[knt].cki = oc
      .cki, reply->catalog_item[knt].synonym_cki = ocs.cki,
      reply->catalog_item[knt].dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[knt].
      orderable_type_flag = ocs.orderable_type_flag, reply->catalog_item[knt].category_name = ac
      .long_description,
      reply->catalog_item[knt].category_id = ac.alt_sel_category_id, reply->catalog_item[knt].
      virtual_view = ocs.virtual_view, reply->catalog_item[knt].health_plan_view = ocs
      .health_plan_view,
      reply->catalog_item[knt].comment_template_flag = oc.comment_template_flag, reply->catalog_item[
      knt].disable_order_comment_ind = oc.disable_order_comment_ind, reply->catalog_item[knt].
      requisition_format_cd = oc.requisition_format_cd,
      reply->catalog_item[knt].requisition_object_name = uar_get_code_meaning(oc
       .requisition_format_cd), cat_knt = 0
     DETAIL
      cat_knt = (cat_knt+ 1)
      IF (cat_knt > 1)
       knt = (knt+ 1)
       IF (mod(knt,10)=1
        AND knt != 1)
        stat = alterlist(reply->catalog_item,(knt+ 9))
       ENDIF
       reply->catalog_item[knt].synonym_id = ocs.synonym_id, reply->catalog_item[knt].
       order_sentence_id = ocs.order_sentence_id, reply->catalog_item[knt].catalog_cd = ocs
       .catalog_cd,
       reply->catalog_item[knt].oe_format_id = ocs.oe_format_id, reply->catalog_item[knt].
       activity_type_cd = ocs.activity_type_cd, reply->catalog_item[knt].activity_subtype_cd = ocs
       .activity_subtype_cd,
       reply->catalog_item[knt].catalog_type_cd = ocs.catalog_type_cd, reply->catalog_item[knt].
       mnemonic = ocs.mnemonic, reply->catalog_item[knt].primary_mnemonic = oc.description,
       reply->catalog_item[knt].mnemonic_key_cap = ocs.mnemonic_key_cap, reply->catalog_item[knt].
       mnemonic_type_cd = ocs.mnemonic_type_cd, reply->catalog_item[knt].ref_text_mask = oc
       .ref_text_mask,
       reply->catalog_item[knt].prep_info_flag = oc.prep_info_flag, reply->catalog_item[knt].cki = oc
       .cki, reply->catalog_item[knt].synonym_cki = ocs.cki,
       reply->catalog_item[knt].dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[knt].
       orderable_type_flag = ocs.orderable_type_flag, reply->catalog_item[knt].category_name = ac
       .long_description,
       reply->catalog_item[knt].category_id = ac.alt_sel_category_id, reply->catalog_item[knt].
       virtual_view = ocs.virtual_view, reply->catalog_item[knt].health_plan_view = ocs
       .health_plan_view,
       reply->catalog_item[knt].comment_template_flag = oc.comment_template_flag, reply->
       catalog_item[knt].disable_order_comment_ind = oc.disable_order_comment_ind, reply->
       catalog_item[knt].requisition_format_cd = oc.requisition_format_cd,
       reply->catalog_item[knt].requisition_object_name = uar_get_code_meaning(oc
        .requisition_format_cd)
      ENDIF
     FOOT REPORT
      IF (knt >= max_qual)
       reply->more_ind = 1, reply->catalog_qual = (knt - 1), stat = alterlist(reply->catalog_item,knt
        ),
       context->context_ind = 1, context->mnemonic_key_cap = reply->catalog_item[knt].
       mnemonic_key_cap, context->synonym_id = reply->catalog_item[knt].synonym_id
      ELSE
       reply->more_ind = 0, reply->catalog_qual = knt, stat = alterlist(reply->catalog_item,knt),
       context->context_ind = 0, context->mnemonic_key_cap = ocs.mnemonic_key_cap, context->
       synonym_id = ocs.synonym_id
      ENDIF
     WITH nocounter, maxqual(ocs,value(max_qual)), outerjoin = d1
    ;end select
    SET ierrcode = error(serrmsg,1)
   ELSE
    SET ierrcode = 0
    SELECT
     IF (ifacilityind > 0
      AND (context->product_ind > 0))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND  EXISTS (
       (SELECT
        ofr.synonym_id
        FROM ocs_facility_r ofr
        WHERE ofr.synonym_id=ocs.synonym_id
         AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=context->facility_cd))) )))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
     ELSEIF (ifacilityind > 0)
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd,
       tradetop_cd,
       dcp_cd, ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND  EXISTS (
       (SELECT
        ofr.synonym_id
        FROM ocs_facility_r ofr
        WHERE ofr.synonym_id=ocs.synonym_id
         AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=context->facility_cd))) )))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
     ELSEIF ((context->product_ind > 0)
      AND (context->virtual_offset > 0)
      AND (context->virtual_offset < 101))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND substring(context->virtual_offset,1,ocs.virtual_view)="1")
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
     ELSEIF ((context->virtual_offset > 0)
      AND (context->virtual_offset < 101))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd,
       tradetop_cd,
       dcp_cd, ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null))
        AND substring(context->virtual_offset,1,ocs.virtual_view)="1")
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
     ELSEIF ((context->product_ind > 0))
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
       ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null)))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
     ELSE
      PLAN (d
       WHERE d.seq > 0)
       JOIN (ocs
       WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
        AND (ocs.mnemonic_key_cap < context->end_search)
        AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd,
       tradetop_cd,
       dcp_cd, ivname_cd)
        AND ((ocs.catalog_type_cd+ 0)=context->cat[d.seq].catalog_type_cd)
        AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
       10))
        AND ((ocs.active_ind+ 0) > 0)
        AND ((ocs.hide_flag+ 0) IN (0, null)))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd)
     ENDIF
     INTO "nl:"
     FROM (dummyt d  WITH seq = value(context->cat_qual)),
      order_catalog_synonym ocs,
      order_catalog oc
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, 0
     HEAD REPORT
      knt = 0, stat = alterlist(reply->catalog_item,10)
     DETAIL
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(reply->catalog_item,(knt+ 9))
      ENDIF
      reply->catalog_item[knt].synonym_id = ocs.synonym_id, reply->catalog_item[knt].
      order_sentence_id = ocs.order_sentence_id, reply->catalog_item[knt].catalog_cd = ocs.catalog_cd,
      reply->catalog_item[knt].oe_format_id = ocs.oe_format_id, reply->catalog_item[knt].
      activity_type_cd = ocs.activity_type_cd, reply->catalog_item[knt].activity_subtype_cd = ocs
      .activity_subtype_cd,
      reply->catalog_item[knt].catalog_type_cd = ocs.catalog_type_cd, reply->catalog_item[knt].
      mnemonic = ocs.mnemonic, reply->catalog_item[knt].primary_mnemonic = oc.description,
      reply->catalog_item[knt].mnemonic_key_cap = ocs.mnemonic_key_cap, reply->catalog_item[knt].
      mnemonic_type_cd = ocs.mnemonic_type_cd, reply->catalog_item[knt].ref_text_mask = oc
      .ref_text_mask,
      reply->catalog_item[knt].prep_info_flag = oc.prep_info_flag, reply->catalog_item[knt].cki = oc
      .cki, reply->catalog_item[knt].synonym_cki = ocs.cki,
      reply->catalog_item[knt].dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[knt].
      orderable_type_flag = ocs.orderable_type_flag, reply->catalog_item[knt].virtual_view = ocs
      .virtual_view,
      reply->catalog_item[knt].health_plan_view = ocs.health_plan_view, reply->catalog_item[knt].
      comment_template_flag = oc.comment_template_flag, reply->catalog_item[knt].
      disable_order_comment_ind = oc.disable_order_comment_ind,
      reply->catalog_item[knt].requisition_format_cd = oc.requisition_format_cd, reply->catalog_item[
      knt].requisition_object_name = uar_get_code_meaning(oc.requisition_format_cd)
     FOOT REPORT
      IF (knt=max_qual)
       reply->more_ind = 1, reply->catalog_qual = (knt - 1), stat = alterlist(reply->catalog_item,(
        knt - 1)),
       context->context_ind = 1, context->mnemonic_key_cap = reply->catalog_item[(knt - 1)].
       mnemonic_key_cap, context->synonym_id = reply->catalog_item[(knt - 1)].synonym_id
      ELSE
       reply->more_ind = 0, reply->catalog_qual = knt, stat = alterlist(reply->catalog_item,knt),
       context->context_ind = 0, context->mnemonic_key_cap = ocs.mnemonic_key_cap, context->
       synonym_id = ocs.synonym_id
      ENDIF
     WITH nocounter, maxqual(ocs,value(max_qual))
    ;end select
    SET ierrcode = error(serrmsg,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE find_list(lvar)
   SET ierrcode = 0
   SELECT
    IF (ifacilityind > 0
     AND (context->product_ind > 0))
     PLAN (ocs
      WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
       AND (ocs.mnemonic_key_cap < context->end_search)
       AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
      ivname_cd)
       AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
      10))
       AND ((ocs.active_ind+ 0) > 0)
       AND ((ocs.hide_flag+ 0) IN (0, null))
       AND  EXISTS (
      (SELECT
       ofr.synonym_id
       FROM ocs_facility_r ofr
       WHERE ofr.synonym_id=ocs.synonym_id
        AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=context->facility_cd))) )))
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ELSEIF (ifacilityind > 0)
     PLAN (ocs
      WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
       AND (ocs.mnemonic_key_cap < context->end_search)
       AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd, tradetop_cd,
      dcp_cd, ivname_cd)
       AND ((ocs.active_ind+ 0) > 0)
       AND ((ocs.hide_flag+ 0) IN (0, null))
       AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
      10))
       AND  EXISTS (
      (SELECT
       ofr.synonym_id
       FROM ocs_facility_r ofr
       WHERE ofr.synonym_id=ocs.synonym_id
        AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=context->facility_cd))) )))
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ELSEIF ((context->product_ind > 0)
     AND (context->virtual_offset > 0)
     AND (context->virtual_offset < 101))
     PLAN (ocs
      WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
       AND (ocs.mnemonic_key_cap < context->end_search)
       AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
      ivname_cd)
       AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
      10))
       AND ((ocs.active_ind+ 0) > 0)
       AND ((ocs.hide_flag+ 0) IN (0, null))
       AND substring(context->virtual_offset,1,ocs.virtual_view)="1")
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ELSEIF ((context->virtual_offset > 0)
     AND (context->virtual_offset < 101))
     PLAN (ocs
      WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
       AND (ocs.mnemonic_key_cap < context->end_search)
       AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd, tradetop_cd,
      dcp_cd, ivname_cd)
       AND ((ocs.active_ind+ 0) > 0)
       AND ((ocs.hide_flag+ 0) IN (0, null))
       AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
      10))
       AND substring(context->virtual_offset,1,ocs.virtual_view)="1")
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ELSEIF ((context->product_ind > 0))
     PLAN (ocs
      WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
       AND (ocs.mnemonic_key_cap < context->end_search)
       AND ocs.mnemonic_type_cd IN (genericprod_cd, generictop_cd, tradeprod_cd, tradetop_cd,
      ivname_cd)
       AND ((ocs.active_ind+ 0) > 0)
       AND ((ocs.hide_flag+ 0) IN (0, null))
       AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
      10)))
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ELSE
     PLAN (ocs
      WHERE (ocs.mnemonic_key_cap >= context->mnemonic_key_cap)
       AND (ocs.mnemonic_key_cap < context->end_search)
       AND ocs.mnemonic_type_cd IN (primary_cd, brandname_cd, dispdrug_cd, generictop_cd, tradetop_cd,
      dcp_cd, ivname_cd)
       AND ((ocs.active_ind+ 0) > 0)
       AND ((ocs.hide_flag+ 0) IN (0, null))
       AND ((ocs.orderable_type_flag+ 0) IN (0, 1, 2, 6, 8,
      10)))
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
    ENDIF
    INTO "nl:"
    FROM order_catalog_synonym ocs,
     order_catalog oc
    ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, 0
    HEAD REPORT
     knt = 0, stat = alterlist(reply->catalog_item,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->catalog_item,(knt+ 9))
     ENDIF
     reply->catalog_item[knt].synonym_id = ocs.synonym_id, reply->catalog_item[knt].order_sentence_id
      = ocs.order_sentence_id, reply->catalog_item[knt].catalog_cd = ocs.catalog_cd,
     reply->catalog_item[knt].oe_format_id = ocs.oe_format_id, reply->catalog_item[knt].
     activity_type_cd = ocs.activity_type_cd, reply->catalog_item[knt].activity_subtype_cd = ocs
     .activity_subtype_cd,
     reply->catalog_item[knt].catalog_type_cd = ocs.catalog_type_cd, reply->catalog_item[knt].
     mnemonic = ocs.mnemonic, reply->catalog_item[knt].primary_mnemonic = oc.description,
     reply->catalog_item[knt].mnemonic_key_cap = ocs.mnemonic_key_cap, reply->catalog_item[knt].
     mnemonic_type_cd = ocs.mnemonic_type_cd, reply->catalog_item[knt].ref_text_mask = oc
     .ref_text_mask,
     reply->catalog_item[knt].prep_info_flag = oc.prep_info_flag, reply->catalog_item[knt].cki = oc
     .cki, reply->catalog_item[knt].synonym_cki = ocs.cki,
     reply->catalog_item[knt].dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[knt].
     orderable_type_flag = ocs.orderable_type_flag, reply->catalog_item[knt].virtual_view = ocs
     .virtual_view,
     reply->catalog_item[knt].health_plan_view = ocs.health_plan_view, reply->catalog_item[knt].
     comment_template_flag = oc.comment_template_flag, reply->catalog_item[knt].
     disable_order_comment_ind = oc.disable_order_comment_ind,
     reply->catalog_item[knt].requisition_format_cd = oc.requisition_format_cd, reply->catalog_item[
     knt].requisition_object_name = uar_get_code_meaning(oc.requisition_format_cd)
    FOOT REPORT
     IF (knt=max_qual)
      reply->more_ind = 1, reply->catalog_qual = (knt - 1), stat = alterlist(reply->catalog_item,(knt
        - 1)),
      context->context_ind = 1, context->mnemonic_key_cap = reply->catalog_item[(knt - 1)].
      mnemonic_key_cap, context->synonym_id = reply->catalog_item[(knt - 1)].synonym_id
     ELSE
      reply->more_ind = 0, reply->catalog_qual = knt, stat = alterlist(reply->catalog_item,knt),
      context->context_ind = 0, context->mnemonic_key_cap = ocs.mnemonic_key_cap, context->synonym_id
       = ocs.synonym_id
     ENDIF
    WITH nocounter, maxqual(ocs,value(max_qual))
   ;end select
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE process_infoscan(lvar)
   IF ((request->infoscan_ind=1))
    FREE SET tmp_req
    RECORD tmp_req(
      1 plan_qual[*]
        2 health_plan_id = f8
        2 drug_qual[*]
          3 cki = vc
          3 synonym_id = f8
    )
    IF (size(request->plan_qual,5) > 0)
     SET stat = alterlist(tmp_req->plan_qual,size(request->plan_qual,5))
     FOR (i = 1 TO size(request->plan_qual,5))
       SET tmp_req->plan_qual[i].health_plan_id = request->plan_qual[i].health_plan_id
       SET stat = alterlist(tmp_req->plan_qual[i].drug_qual,size(reply->catalog_item,5))
       FOR (j = 1 TO size(reply->catalog_item,5))
        SET tmp_req->plan_qual[i].drug_qual[j].cki = reply->catalog_item[j].synonym_cki
        SET tmp_req->plan_qual[i].drug_qual[j].synonym_id = reply->catalog_item[j].synonym_id
       ENDFOR
     ENDFOR
    ENDIF
    FREE SET tmp_reply
    RECORD tmp_reply(
      1 plan_qual[*]
        2 health_plan_id = f8
        2 non_formu_cvrg_flag = i2
        2 policy_unlisted_drug_flag = i2
        2 policy_generic_drug_flag = i2
        2 policy_brand_reimburse_flag = i2
        2 policy_brand_interchg_flag = i2
        2 tier_flag = i2
        2 drug_qual[*]
          3 cki = vc
          3 main_multum_drug_code = i4
          3 prod_formu_qual[*]
            4 prod_formu_status_flag = i2
            4 note_qual[*]
              5 note_identifier = c10
              5 note_advise_restrict_ind = i2
              5 notes = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    EXECUTE hna_obj_get_drug_plan_info  WITH replace("REQUEST","TMP_REQ"), replace("REPLY",
     "TMP_REPLY")
    SET max_plan_cnt = size(tmp_reply->plan_qual,5)
    SET max_drug_cnt = 0
    SET max_formu_cnt = 0
    FOR (i = 1 TO max_plan_cnt)
     IF (max_drug_cnt < size(tmp_reply->plan_qual[i].drug_qual,5))
      SET max_drug_cnt = size(tmp_reply->plan_qual[i].drug_qual,5)
     ENDIF
     FOR (j = 1 TO size(tmp_reply->plan_qual[i].drug_qual,5))
       IF (max_formu_cnt < size(tmp_reply->plan_qual[i].drug_qual,5))
        SET max_formu_cnt = size(tmp_reply->plan_qual[i].drug_qual[j].prod_formu_qual,5)
       ENDIF
     ENDFOR
    ENDFOR
    CALL echo(build("max_drug_cnt = ",max_drug_cnt))
    SELECT INTO "nl:"
     d1.seq, d2.seq, d3.seq
     FROM (dummyt d1  WITH seq = size(reply->catalog_item,5)),
      (dummyt d2  WITH seq = size(tmp_reply->plan_qual,5)),
      (dummyt d3  WITH seq = max_drug_cnt)
     PLAN (d1
      WHERE d1.seq > 0)
      JOIN (d2
      WHERE d2.seq <= size(tmp_reply->plan_qual,5)
       AND (tmp_reply->plan_qual[d2.seq].health_plan_id > 0))
      JOIN (d3
      WHERE (tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].cki=reply->catalog_item[d1.seq].
      synonym_cki)
       AND d3.seq <= max_drug_cnt)
     HEAD d1.seq
      stat = alterlist(reply->catalog_item[d1.seq].infoscan_item,size(tmp_req->plan_qual,5))
     DETAIL
      reply->catalog_item[d1.seq].infoscan_item[d2.seq].health_plan_id = tmp_reply->plan_qual[d2.seq]
      .health_plan_id, reply->catalog_item[d1.seq].infoscan_item[d2.seq].non_formu_cvrg_flag =
      tmp_reply->plan_qual[d2.seq].non_formu_cvrg_flag, reply->catalog_item[d1.seq].infoscan_item[d2
      .seq].policy_unlisted_drug_flag = tmp_reply->plan_qual[d2.seq].policy_unlisted_drug_flag,
      reply->catalog_item[d1.seq].infoscan_item[d2.seq].policy_generic_drug_flag = tmp_reply->
      plan_qual[d2.seq].policy_brand_reimburse_flag, reply->catalog_item[d1.seq].infoscan_item[d2.seq
      ].policy_brand_reimburse_flag = tmp_reply->plan_qual[d2.seq].non_formu_cvrg_flag, reply->
      catalog_item[d1.seq].infoscan_item[d2.seq].policy_brand_interchg_flag = tmp_reply->plan_qual[d2
      .seq].policy_brand_interchg_flag,
      reply->catalog_item[d1.seq].infoscan_item[d2.seq].tier_flag = tmp_reply->plan_qual[d2.seq].
      tier_flag, stat = alterlist(reply->catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual,1),
      reply->catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual[1].cki = tmp_reply->plan_qual[d2
      .seq].drug_qual[d3.seq].cki,
      reply->catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual[1].main_multum_drug_code =
      tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].main_multum_drug_code, stat = alterlist(reply->
       catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual[1].prod_formu_qual,size(tmp_reply->
        plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual,5))
      FOR (x = 1 TO size(tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual,5))
        reply->catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual[1].prod_formu_qual[x].
        prod_formu_status_flag = tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].
        prod_formu_status_flag, stat = alterlist(reply->catalog_item[d1.seq].infoscan_item[d2.seq].
         drug_qual[1].prod_formu_qual[x].note_qual,size(tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq
          ].prod_formu_qual[x].note_qual,5))
        FOR (y = 1 TO size(tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].
         note_qual,5))
          reply->catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual[1].prod_formu_qual[x].
          note_qual[y].note_advise_restrict_ind = tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].
          prod_formu_qual[x].note_qual[y].note_advise_restrict_ind, reply->catalog_item[d1.seq].
          infoscan_item[d2.seq].drug_qual[1].prod_formu_qual[x].note_qual[y].note_identifier =
          tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].note_qual[y].
          note_identifier, reply->catalog_item[d1.seq].infoscan_item[d2.seq].drug_qual[1].
          prod_formu_qual[x].note_qual[y].notes = tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].
          prod_formu_qual[x].note_qual[y].notes
        ENDFOR
      ENDFOR
     WITH nocounter
    ;end select
    IF ((tmp_reply->status_data.status="F"))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Execution"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "hna_obj_get_drug_plan_info"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "hna_obj_get_drug_plan_info script failed."
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed=false)
  IF ((reply->catalog_qual > 0))
   SET reply->status_data.status = "S"
   IF ((request->exact_ind=1)
    AND (reply->catalog_item[1].mnemonic_key_cap=exact_str))
    SET reply->exact_ind = 1
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET script_ver = "024 07/17/09 AA017768"
END GO
