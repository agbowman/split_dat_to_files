CREATE PROGRAM cps_get_fav_alt_sel_item:dba
 FREE SET reply
 RECORD reply(
   1 synonym_count = i4
   1 synonym[*]
     2 alt_sel_category_id = f8
     2 synonym_id = f8
     2 sequence = i4
     2 order_sentence_id = f8
     2 order_sentence_disp = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 oe_format_id = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 mnemonic = vc
     2 generic_mnemonic = vc
     2 ref_text_mask = i4
     2 prep_info_flag = i2
     2 auto_invoke_prep_ind = i2
     2 orderable_type_flag = i2
     2 dup_checking_ind = i2
     2 cki = vc
     2 synonym_cki = vc
     2 orderable_type_flag = i2
     2 virtual_view = vc
     2 health_plan_view = vc
     2 comment_template_flag = i2
     2 disable_order_comment_ind = i2
     2 mnemonic_type_cd = f8
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
 SET reply->status_data.status = "F"
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
 DECLARE ifacilitytableexists = i2 WITH protect, noconstant(0)
 DECLARE ifacilityind = i2 WITH protect, noconstant(0)
 DECLARE inum = i2 WITH protect, noconstant(0)
 IF (checkdic("OCS_FACILITY_R","T",0)=2)
  SET ifacilitytableexists = 1
 ENDIF
 SET virtual_ind = 0
 IF ((((request->facility_cd > 0)) OR ((request->virtual_offset > 0)
  AND (request->virtual_offset < 101))) )
  SET virtual_ind = 1
  IF ((request->facility_cd > 0)
   AND ifacilitytableexists=1)
   SET ifacilityind = 1
  ENDIF
 ENDIF
 SET ierrcode = 0
 SELECT
  IF (ifacilityind=1)
   PLAN (al
    WHERE expand(inum,1,request->cat_list_qual,al.alt_sel_category_id,request->cat_list[inum].
     alt_sel_cat_id)
     AND ((al.synonym_id+ 0) > 0)
     AND ((al.list_type+ 0)=2))
    JOIN (os
    WHERE al.synonym_id=os.synonym_id
     AND ((os.active_ind+ 0)=1)
     AND ((os.hide_flag+ 0) IN (0, null))
     AND  EXISTS (
    (SELECT
     ofr.synonym_id
     FROM ocs_facility_r ofr
     WHERE ofr.synonym_id=os.synonym_id
      AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_cd))) )))
    JOIN (oc
    WHERE os.catalog_cd=oc.catalog_cd)
    JOIN (s
    WHERE s.order_sentence_id=outerjoin(al.order_sentence_id))
  ELSEIF (virtual_ind=1)
   PLAN (al
    WHERE expand(inum,1,request->cat_list_qual,al.alt_sel_category_id,request->cat_list[cgfasi_tm].
     alt_sel_cat_id)
     AND ((al.synonym_id+ 0) > 0)
     AND ((al.list_type+ 0)=2))
    JOIN (os
    WHERE al.synonym_id=os.synonym_id
     AND ((os.active_ind+ 0)=1)
     AND ((os.hide_flag+ 0) IN (0, null))
     AND substring(request->virtual_offset,1,os.virtual_view)="1")
    JOIN (oc
    WHERE os.catalog_cd=oc.catalog_cd)
    JOIN (s
    WHERE s.order_sentence_id=outerjoin(al.order_sentence_id))
  ELSE
   PLAN (al
    WHERE expand(inum,1,request->cat_list_qual,al.alt_sel_category_id,request->cat_list[inum].
     alt_sel_cat_id)
     AND ((al.synonym_id+ 0) > 0))
    JOIN (os
    WHERE al.synonym_id=os.synonym_id
     AND ((os.active_ind+ 0)=1)
     AND ((os.hide_flag+ 0) IN (0, null)))
    JOIN (oc
    WHERE os.catalog_cd=oc.catalog_cd)
    JOIN (s
    WHERE s.order_sentence_id=outerjoin(al.order_sentence_id))
  ENDIF
  INTO "nl:"
  FROM alt_sel_list al,
   order_catalog_synonym os,
   order_catalog oc,
   order_sentence s
  ORDER BY al.alt_sel_category_id, al.sequence, os.mnemonic_key_cap
  HEAD REPORT
   knt = 0, stat = alterlist(reply->synonym,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->synonym,(knt+ 9))
   ENDIF
   reply->synonym[knt].alt_sel_category_id = al.alt_sel_category_id, reply->synonym[knt].synonym_id
    = os.synonym_id, reply->synonym[knt].sequence = al.sequence,
   reply->synonym[knt].order_sentence_id = al.order_sentence_id, reply->synonym[knt].
   order_sentence_disp = s.order_sentence_display_line, reply->synonym[knt].catalog_cd = os
   .catalog_cd,
   reply->synonym[knt].catalog_type_cd = os.catalog_type_cd, reply->synonym[knt].oe_format_id = os
   .oe_format_id, reply->synonym[knt].activity_type_cd = os.activity_type_cd,
   reply->synonym[knt].activity_subtype_cd = os.activity_subtype_cd, reply->synonym[knt].mnemonic =
   os.mnemonic, reply->synonym[knt].generic_mnemonic = oc.description,
   reply->synonym[knt].ref_text_mask = oc.ref_text_mask, reply->synonym[knt].prep_info_flag = oc
   .prep_info_flag, reply->synonym[knt].orderable_type_flag = oc.orderable_type_flag,
   reply->synonym[knt].dup_checking_ind = oc.dup_checking_ind, reply->synonym[knt].cki = oc.cki,
   reply->synonym[knt].synonym_cki = os.cki,
   reply->synonym[knt].orderable_type_flag = os.orderable_type_flag, reply->synonym[knt].virtual_view
    = os.virtual_view, reply->synonym[knt].health_plan_view = os.health_plan_view,
   reply->synonym[knt].comment_template_flag = oc.comment_template_flag, reply->synonym[knt].
   disable_order_comment_ind = oc.disable_order_comment_ind, reply->synonym[knt].mnemonic_type_cd =
   os.mnemonic_type_cd,
   reply->synonym[knt].requisition_format_cd = oc.requisition_format_cd, reply->synonym[knt].
   requisition_object_name = uar_get_code_meaning(oc.requisition_format_cd)
  FOOT REPORT
   reply->synonym_count = knt, stat = alterlist(reply->synonym,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALT_SEL_LIST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET failed = true
  GO TO exit_script
 ENDIF
 DECLARE specific_ind = i2 WITH protect, noconstant(0)
 DECLARE nurse_prep_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6009,"NURSE PREP"))
 SELECT INTO "nl:"
  FROM ref_text_facility_r rtfr,
   ref_text_version rtv,
   (dummyt d  WITH seq = value(size(reply->synonym,5)))
  PLAN (d)
   JOIN (rtfr
   WHERE (rtfr.parent_entity_id=reply->synonym[d.seq].catalog_cd)
    AND rtfr.parent_entity_name="ORDER_CATALOG"
    AND rtfr.text_type_cd=nurse_prep_cd
    AND (((rtfr.facility_cd=request->facility_cd)) OR (rtfr.facility_cd=0)) )
   JOIN (rtv
   WHERE rtv.ref_text_variation_id=rtfr.ref_text_variation_id
    AND rtv.active_ind=1)
  HEAD rtfr.parent_entity_id
   specific_ind = 0
  DETAIL
   IF (specific_ind=0)
    IF (rtfr.facility_cd != 0)
     specific_ind = 1
    ENDIF
    reply->synonym[d.seq].auto_invoke_prep_ind = rtv.auto_invoke_prep_ind
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REF_TEXT_FACILITY_R"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET failed = true
  GO TO exit_script
 ENDIF
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
     SET stat = alterlist(tmp_req->plan_qual[i].drug_qual,size(reply->synonym,5))
     FOR (j = 1 TO size(reply->synonym,5))
      SET tmp_req->plan_qual[i].drug_qual[j].cki = reply->synonym[j].synonym_cki
      SET tmp_req->plan_qual[i].drug_qual[j].synonym_id = reply->synonym[j].synonym_id
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
  EXECUTE hna_obj_get_drug_plan_info  WITH replace("REQUEST","TMP_REQ"), replace("REPLY","TMP_REPLY")
  SET max_drug_cnt = 0
  FOR (i = 1 TO size(tmp_reply->plan_qual,5))
    IF (max_drug_cnt < size(tmp_reply->plan_qual[i].drug_qual,5))
     SET max_drug_cnt = size(tmp_reply->plan_qual[i].drug_qual,5)
    ENDIF
  ENDFOR
  CALL echo(build("max_drug_cnt = ",max_drug_cnt))
  SELECT INTO "nl:"
   d1.seq, d2.seq, d3.seq
   FROM (dummyt d1  WITH seq = size(reply->synonym,5)),
    (dummyt d2  WITH seq = size(tmp_reply->plan_qual,5)),
    (dummyt d3  WITH seq = max_drug_cnt)
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE d2.seq <= size(tmp_reply->plan_qual,5)
     AND (tmp_reply->plan_qual[d2.seq].health_plan_id > 0))
    JOIN (d3
    WHERE (tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].cki=reply->synonym[d1.seq].synonym_cki)
     AND d3.seq <= max_drug_cnt)
   HEAD d1.seq
    stat = alterlist(reply->synonym[d1.seq].infoscan_item,size(tmp_req->plan_qual,5))
   DETAIL
    reply->synonym[d1.seq].infoscan_item[d2.seq].health_plan_id = tmp_reply->plan_qual[d2.seq].
    health_plan_id, reply->synonym[d1.seq].infoscan_item[d2.seq].non_formu_cvrg_flag = tmp_reply->
    plan_qual[d2.seq].non_formu_cvrg_flag, reply->synonym[d1.seq].infoscan_item[d2.seq].
    policy_unlisted_drug_flag = tmp_reply->plan_qual[d2.seq].policy_unlisted_drug_flag,
    reply->synonym[d1.seq].infoscan_item[d2.seq].policy_generic_drug_flag = tmp_reply->plan_qual[d2
    .seq].policy_brand_reimburse_flag, reply->synonym[d1.seq].infoscan_item[d2.seq].
    policy_brand_reimburse_flag = tmp_reply->plan_qual[d2.seq].non_formu_cvrg_flag, reply->synonym[d1
    .seq].infoscan_item[d2.seq].policy_brand_interchg_flag = tmp_reply->plan_qual[d2.seq].
    policy_brand_interchg_flag,
    reply->synonym[d1.seq].infoscan_item[d2.seq].tier_flag = tmp_reply->plan_qual[d2.seq].tier_flag,
    stat = alterlist(reply->synonym[d1.seq].infoscan_item[d2.seq].drug_qual,1), reply->synonym[d1.seq
    ].infoscan_item[d2.seq].drug_qual[1].cki = tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].cki,
    reply->synonym[d1.seq].infoscan_item[d2.seq].drug_qual[1].main_multum_drug_code = tmp_reply->
    plan_qual[d2.seq].drug_qual[d3.seq].main_multum_drug_code, stat = alterlist(reply->synonym[d1.seq
     ].infoscan_item[d2.seq].drug_qual[1].prod_formu_qual,size(tmp_reply->plan_qual[d2.seq].
      drug_qual[d3.seq].prod_formu_qual,5))
    FOR (x = 1 TO size(tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual,5))
      reply->synonym[d1.seq].infoscan_item[d2.seq].drug_qual[1].prod_formu_qual[x].
      prod_formu_status_flag = tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].
      prod_formu_status_flag, stat = alterlist(reply->synonym[d1.seq].infoscan_item[d2.seq].
       drug_qual[1].prod_formu_qual[x].note_qual,size(tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].
        prod_formu_qual[x].note_qual,5))
      FOR (y = 1 TO size(tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].note_qual,
       5))
        reply->synonym[d1.seq].infoscan_item[d2.seq].drug_qual[1].prod_formu_qual[x].note_qual[y].
        note_advise_restrict_ind = tmp_reply->plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].
        note_qual[y].note_advise_restrict_ind, reply->synonym[d1.seq].infoscan_item[d2.seq].
        drug_qual[1].prod_formu_qual[x].note_qual[y].note_identifier = tmp_reply->plan_qual[d2.seq].
        drug_qual[d3.seq].prod_formu_qual[x].note_qual[y].note_identifier, reply->synonym[d1.seq].
        infoscan_item[d2.seq].drug_qual[1].prod_formu_qual[x].note_qual[y].notes = tmp_reply->
        plan_qual[d2.seq].drug_qual[d3.seq].prod_formu_qual[x].note_qual[y].notes
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
#exit_script
 IF (failed=false)
  IF ((reply->synonym_count > 0))
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET script_version = "020 05/04/09 JT018805"
END GO
