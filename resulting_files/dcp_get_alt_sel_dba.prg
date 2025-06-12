CREATE PROGRAM dcp_get_alt_sel:dba
 RECORD reply(
   1 get_list[*]
     2 alt_sel_category_id = f8
     2 short_description = vc
     2 long_description_key_cap = vc
     2 long_description = vc
     2 owner_id = f8
     2 updt_cnt = i4
     2 source_component_flag = i2
     2 child_list[*]
       3 list_type = i4
       3 mnemonic = vc
       3 child_alt_sel_cat_id = f8
       3 long_description_key_cap = vc
       3 long_description = vc
       3 owner_id = f8
       3 updt_cnt = i4
       3 synonym_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 oe_format_id = f8
       3 rx_mask = i4
       3 multiple_ord_sent_ind = i2
       3 order_sentence_id = f8
       3 order_sentence_disp_line = vc
       3 orderable_type_flag = i2
       3 dcp_clin_cat_cd = f8
       3 ref_text_mask = i4
       3 ord_sent_comment_id = f8
       3 ord_sent_comment = vc
       3 cki = vc
       3 mnemonic_type_cd = f8
       3 sequence = i4
       3 plan_display_description = vc
       3 pathway_catalog_id = f8
       3 evidence_locator = vc
       3 pw_evidence_reltn_id = f8
       3 witness_flag = i2
       3 ingredient_rate_conversion_ind = i2
       3 type_mean = c12
       3 pathway_type_cd = f8
       3 high_alert_ind = i2
       3 high_alert_long_text_id = f8
       3 high_alert_required_ntfy_ind = i2
       3 high_alert_text = vc
       3 plan_ref_text_ind = i2
       3 pw_cat_synonym_id = f8
       3 pw_synonym_name = vc
       3 regimen_catalog_id = f8
       3 regimen_catalog_synonym_id = f8
       3 regimen_synonym = vc
       3 ordsent_filter_display = vc
       3 ordsent_applicable_to_patient = i2
       3 d_preferred_ind = i2
       3 r_preferred_ind = i2
       3 u_preferred_ind = i2
       3 ordered_as_synonym_id = f8
     2 iv_set_synonym_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reftext(
   1 qual[*]
     2 index1 = i2
     2 index2 = i2
     2 pathway_catalog_id = f8
 )
 RECORD comments(
   1 qual[*]
     2 index1 = i2
     2 index2 = i2
     2 cmt_id = f8
 )
 RECORD highalert(
   1 qual[*]
     2 index1 = i2
     2 index2 = i2
     2 high_alert_long_text_id = f8
 )
 FREE RECORD filter_order_sentences
 RECORD filter_order_sentences(
   1 patient_criteria
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
   1 orders[*]
     2 unique_identifier = f8
     2 order_sentences[*]
       3 order_sentence_id = f8
       3 applicable_to_patient_ind = i2
       3 order_sentence_filters_index = i2
       3 order_sentence_filters[*]
         4 order_sentence_filter_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD preferred_ordering_indicators(
   1 orders[*]
     2 unique_identifier = i4
     2 child_list_identifier = i4
     2 synonym_cki = c255
     2 d_preferred_ind = i2
     2 r_preferred_ind = i2
     2 u_preferred_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE primary_mnemonic_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE nsourcecompflagcnt = i4 WITH protect, constant(size(request->source_list,5))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE child_folder = i4 WITH protect, constant(1)
 DECLARE synonym = i4 WITH protect, constant(2)
 DECLARE iv_favorite = i4 WITH protect, constant(5)
 DECLARE plan_favorite = i4 WITH protect, constant(6)
 DECLARE regimen_favorite = i4 WITH protect, constant(7)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE filter_orc = i4 WITH protect, noconstant(0)
 DECLARE comment_cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE stop = i4 WITH protect, noconstant(0)
 DECLARE reftext_cnt = i4 WITH protect, noconstant(0)
 DECLARE highalert_cnt = i4 WITH protect, noconstant(0)
 DECLARE preferred_ordering_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_index = i4 WITH noconstant(0), protect
 DECLARE orders_size = i4 WITH noconstant(0), protect
 DECLARE order_sentences_size = i4 WITH noconstant(0), protect
 DECLARE temp_num = f8 WITH noconstant(0), protect
 DECLARE med_fac_cd = f8 WITH protect, noconstant(0)
 DECLARE nonmed_fac_cd = f8 WITH protect, noconstant(0)
 DECLARE ordsent_filter_cnt = i4 WITH protect, noconstant(0)
 DECLARE pharmacy_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 IF ((request->apply_facility_on_med_ind=1))
  SET med_fac_cd = request->facility_cd
 ENDIF
 IF ((request->apply_facility_on_nonmed_ind=1))
  SET nonmed_fac_cd = request->facility_cd
 ENDIF
 IF ((request->facility_cd=0))
  IF ((request->virtual_view_offset > 0)
   AND (request->virtual_view_offset < 101))
   SET filter_orc = 1
  ENDIF
 ENDIF
 DECLARE nsize = i4 WITH protect, constant(20)
 DECLARE ntotal2 = i4 WITH protect, constant(size(request->alt_sel_list,5))
 DECLARE source_list_cnt = i4 WITH protect, constant(size(request->source_list,5))
 DECLARE ntotal = i4 WITH protect, constant((ntotal2+ (nsize - mod(ntotal2,nsize))))
 DECLARE ivsequence_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
 SET stat = alterlist(request->alt_sel_list,ntotal)
 SET start = 1
 SELECT
  IF (source_list_cnt > 0)
   PLAN (d1
    WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
    JOIN (ascat
    WHERE ((expand(num,start,(start+ (nsize - 1)),ascat.alt_sel_category_id,request->alt_sel_list[num
     ].alt_sel_category_id)
     AND ascat.alt_sel_category_id > 0.0) OR (expand(num,start,(start+ (nsize - 1)),ascat.owner_id,
     request->alt_sel_list[num].owner_id,
     ascat.long_description_key_cap,request->alt_sel_list[num].long_description_key_cap)
     AND ascat.owner_id > 0.0
     AND ascat.long_description_key_cap != null))
     AND expand(idx,1,nsourcecompflagcnt,ascat.source_component_flag,request->source_list[idx].
     source_component_flag,
     value(nsourcecompflagcnt)))
  ELSE
   PLAN (d1
    WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
    JOIN (ascat
    WHERE ((expand(num,start,(start+ (nsize - 1)),ascat.alt_sel_category_id,request->alt_sel_list[num
     ].alt_sel_category_id)
     AND ascat.alt_sel_category_id > 0.0) OR (expand(num,start,(start+ (nsize - 1)),ascat.owner_id,
     request->alt_sel_list[num].owner_id,
     ascat.long_description_key_cap,request->alt_sel_list[num].long_description_key_cap)
     AND ascat.owner_id > 0.0
     AND ascat.long_description_key_cap != null
     AND ascat.source_component_flag=1)) )
  ENDIF
  INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   alt_sel_cat ascat
  ORDER BY ascat.alt_sel_category_id
  HEAD REPORT
   stat = alterlist(request->alt_sel_list,ntotal2)
  DETAIL
   count1 += 1
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 5))
   ENDIF
   reply->get_list[count1].alt_sel_category_id = ascat.alt_sel_category_id, reply->get_list[count1].
   short_description = ascat.short_description, reply->get_list[count1].long_description_key_cap =
   ascat.long_description_key_cap,
   reply->get_list[count1].long_description = ascat.long_description, reply->get_list[count1].
   updt_cnt = ascat.updt_cnt, reply->get_list[count1].owner_id = ascat.owner_id,
   reply->get_list[count1].source_component_flag = ascat.source_component_flag, reply->get_list[
   count1].iv_set_synonym_id = ascat.iv_set_synonym_id
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 RANGE OF ascat IS alt_sel_cat
 DECLARE strlen1 = i4 WITH constant(size(ascat.long_description_key_cap))
 FREE RANGE ascat
 RANGE OF ocs IS order_catalog_synonym
 DECLARE strlen2 = i4 WITH constant(size(ocs.cki))
 FREE RANGE ocs
 RANGE OF os IS order_sentence
 DECLARE strlen3 = i4 WITH constant(size(os.order_sentence_display_line))
 FREE RANGE os
 RANGE OF pwc IS pathway_catalog
 DECLARE strlen4 = i4 WITH constant(size(pwc.display_description))
 FREE RANGE pwc
 RANGE OF rc IS regimen_cat_synonym
 DECLARE strlen5 = i4 WITH constant(size(rc.synonym_display))
 FREE RANGE rc
 SET stop = 0
 SET totaltime = 0.0
 SET i = 0
 WHILE (stop < count1)
   SET start = (stop+ 1)
   SET stop += 200
   IF (stop > count1)
    SET stop = count1
   ENDIF
   SET temptime = sysdate
   SELECT INTO "nl:"
    t1.alt_sel_cat_id, t1.list_type, t1.sequence,
    t1.mnemonic, t1.updt_cnt, t1.child_asc_id,
    t1.synonym_id, t1.catalog_cd, t1.catalog_type_cd,
    t1.activity_type_cd, t1.oe_format_id, t1.rx_mask,
    t1.multiple_ord_sent_ind, t1.orderable_type_flag, t1.dcp_clin_cat_cd,
    t1.ref_text_mask, t1.cki, t1.mnemonic_type_cd,
    t1.order_sentence_id, t1.order_sentence_disp_line, t1.ord_sent_comment_id,
    t1.long_description_key_cap, t1.long_description, t1.owner_id,
    t1.usage_flag, t1.order_encntr_group_cd, t1.plan_display_description,
    t1.pathway_catalog_id, t1.witness_flag, t1.ingredient_rate_conversion_ind,
    t1.type_mean, t1.pathway_type_cd, t1.high_alert_ind,
    t1.high_alert_long_text_id, t1.high_alert_required_ntfy_ind, t1.pw_cat_synonym_id,
    t1.pw_synonym_name, t1.regimen_catalog_id, t1.regimen_catalog_synonym_id,
    t1.regimen_synonym, t1.synonym_cki, t1.ordered_as_synonym_id
    FROM (
     (
     (SELECT
      alt_sel_cat_id = asl.alt_sel_category_id, list_type = synonym, sequence = asl.sequence,
      mnemonic = ocs.mnemonic, updt_cnt = ocs.updt_cnt, child_asc_id = 0.0,
      synonym_id = ocs.synonym_id, catalog_cd = ocs.catalog_cd, catalog_type_cd = ocs.catalog_type_cd,
      activity_type_cd = ocs.activity_type_cd, oe_format_id = ocs.oe_format_id, rx_mask = ocs.rx_mask,
      multiple_ord_sent_ind = ocs.multiple_ord_sent_ind, orderable_type_flag = ocs
      .orderable_type_flag, dcp_clin_cat_cd = ocs.dcp_clin_cat_cd,
      ref_text_mask = ocs.ref_text_mask, cki = oc.cki, mnemonic_type_cd = ocs.mnemonic_type_cd,
      order_sentence_id = asl.order_sentence_id, order_sentence_disp_line = os
      .order_sentence_display_line, ord_sent_comment_id = os.ord_comment_long_text_id,
      long_description_key_cap = value(fillstring(value(strlen1)," ")), long_description = value(
       fillstring(value(strlen1)," ")), owner_id = 0.0,
      usage_flag = os.usage_flag, order_encntr_group_cd = os.order_encntr_group_cd,
      plan_display_description = value(fillstring(value(strlen4)," ")),
      pathway_catalog_id = 0.0, witness_flag = ocs.witness_flag, ingredient_rate_conversion_ind = ocs
      .ingredient_rate_conversion_ind,
      type_mean = "", pathway_type_cd = 0.0, high_alert_ind = ocs.high_alert_ind,
      high_alert_long_text_id = ocs.high_alert_long_text_id, high_alert_required_ntfy_ind = ocs
      .high_alert_required_ntfy_ind, pw_cat_synonym_id = 0,
      pw_synonym_name = "", regimen_catalog_id = 0.0, regimen_catalog_synonym_id = 0.0,
      regimen_synonym = value(fillstring(value(strlen5)," ")), synonym_cki = ocs.cki,
      ordered_as_synonym_id = asl.ordered_as_synonym_id
      FROM alt_sel_list asl,
       order_catalog_synonym ocs,
       order_sentence os,
       order_catalog oc
      WHERE ((expand(num,start,stop,asl.alt_sel_category_id,reply->get_list[num].alt_sel_category_id)
       AND asl.list_type=synonym
       AND ocs.synonym_id=asl.synonym_id
       AND ocs.active_ind=1
       AND oc.catalog_cd=ocs.catalog_cd
       AND (((request->get_hidden_orders_flag=1)) OR (((ocs.hide_flag=0) OR (ocs.hide_flag=null)) ))
       AND ((filter_orc=0) OR (filter_orc=1
       AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1"))
       AND ((ocs.catalog_type_cd=pharmacy_type_cd
       AND ((((med_fac_cd=0) OR ( EXISTS (
      (SELECT
       ocsfr.synonym_id
       FROM ocs_facility_r ocsfr
       WHERE ocsfr.facility_cd IN (0, med_fac_cd)
        AND ocsfr.synonym_id=ocs.synonym_id)))) ) OR ( EXISTS (
      (SELECT
       ofr.synonym_id
       FROM ocs_facility_r ofr
       WHERE ofr.facility_cd IN (0, med_fac_cd)
        AND ofr.synonym_id > 0.0
        AND (ofr.synonym_id=
       (SELECT
        a.iv_set_synonym_id
        FROM alt_sel_cat a
        WHERE a.alt_sel_category_id=asl.alt_sel_category_id)))))) ) OR (ocs.catalog_type_cd !=
      pharmacy_type_cd
       AND ((nonmed_fac_cd=0) OR ( EXISTS (
      (SELECT
       ocsfr.synonym_id
       FROM ocs_facility_r ocsfr
       WHERE ocsfr.facility_cd IN (0, nonmed_fac_cd)
        AND ocsfr.synonym_id=ocs.synonym_id)))) ))
       AND os.order_sentence_id=asl.order_sentence_id) UNION (
      (SELECT
       alt_sel_cat_id = asl2.alt_sel_category_id, list_type = iv_favorite, sequence = asl2.sequence,
       mnemonic = ascat.short_description, updt_cnt = ascat.updt_cnt, child_asc_id = asl2
       .child_alt_sel_cat_id,
       synonym_id = 0.0, catalog_cd = 0.0, catalog_type_cd = 0.0,
       activity_type_cd = 0.0, oe_format_id = 0.0, rx_mask = 0,
       multiple_ord_sent_ind = 0, orderable_type_flag = 0, dcp_clin_cat_cd = 0.0,
       ref_text_mask = 0, cki = value(fillstring(value(strlen2)," ")), mnemonic_type_cd = 0.0,
       order_sentence_id = os2.order_sentence_id, order_sentence_disp_line = os2
       .order_sentence_display_line, ord_sent_comment_id = os2.ord_comment_long_text_id,
       long_description_key_cap = ascat.long_description_key_cap, long_description = ascat
       .long_description, owner_id = ascat.owner_id,
       usage_flag = 0, order_encntr_group_cd = 0.0, plan_display_description = value(fillstring(value
         (strlen4)," ")),
       pathway_catalog_id = 0.0, witness_flag = 0, ingredient_rate_conversion_ind = 0,
       type_mean = "", pathway_type_cd = 0.0, high_alert_ind = 0,
       high_alert_long_text_id = 0, high_alert_required_ntfy_ind = 0, pw_cat_synonym_id = 0,
       pw_synonym_name = "", regimen_catalog_id = 0.0, regimen_catalog_synonym_id = 0.0,
       regimen_synonym = value(fillstring(value(strlen5)," ")), synonym_cki = value(fillstring(value(
          strlen2)," ")), ordered_as_synonym_id = 0
       FROM alt_sel_list asl2,
        alt_sel_cat ascat,
        alt_sel_list asl3,
        order_sentence os2
       WHERE expand(num,start,stop,asl2.alt_sel_category_id,reply->get_list[num].alt_sel_category_id)
        AND asl2.list_type=iv_favorite
        AND ascat.alt_sel_category_id=asl2.child_alt_sel_cat_id
        AND asl3.alt_sel_category_id=ascat.alt_sel_category_id
        AND asl3.sequence=1
        AND ((os2.order_sentence_id=asl3.order_sentence_id) UNION (
       (SELECT
        alt_sel_cat_id = asl4.alt_sel_category_id, list_type = child_folder, sequence = asl4.sequence,
        mnemonic = ascat2.short_description, updt_cnt = ascat2.updt_cnt, child_asc_id = asl4
        .child_alt_sel_cat_id,
        synonym_id = 0.0, catalog_cd = 0.0, catalog_type_cd = 0.0,
        activity_type_cd = 0.0, oe_format_id = 0.0, rx_mask = 0,
        multiple_ord_sent_ind = 0, orderable_type_flag = 0, dcp_clin_cat_cd = 0.0,
        ref_text_mask = 0, cki = value(fillstring(value(strlen2)," ")), mnemonic_type_cd = 0.0,
        order_sentence_id = 0.0, order_sentence_disp_line = value(fillstring(value(strlen3)," ")),
        ord_sent_comment_id = 0.0,
        long_description_key_cap = ascat2.long_description_key_cap, long_description = ascat2
        .long_description, owner_id = ascat2.owner_id,
        usage_flag = 0, order_encntr_group_cd = 0.0, plan_display_description = value(fillstring(
          value(strlen4)," ")),
        pathway_catalog_id = 0.0, witness_flag = 0, ingredient_rate_conversion_ind = 0,
        type_mean = "", pathway_type_cd = 0.0, high_alert_ind = 0,
        high_alert_long_text_id = 0, high_alert_required_ntfy_ind = 0, pw_cat_synonym_id = 0,
        pw_synonym_name = "", regimen_catalog_id = 0.0, regimen_catalog_synonym_id = 0.0,
        regimen_synonym = value(fillstring(value(strlen5)," ")), synonym_cki = value(fillstring(value
          (strlen2)," ")), ordered_as_synonym_id = 0
        FROM alt_sel_list asl4,
         alt_sel_cat ascat2
        WHERE expand(num,start,stop,asl4.alt_sel_category_id,reply->get_list[num].alt_sel_category_id
         )
         AND asl4.list_type=child_folder
         AND ((ascat2.alt_sel_category_id=asl4.child_alt_sel_cat_id) UNION (
        (SELECT
         alt_sel_cat_id = asl5.alt_sel_category_id, list_type = plan_favorite, sequence = asl5
         .sequence,
         mnemonic = ascat3.short_description, updt_cnt = pwc.updt_cnt, child_asc_id = 0.0,
         synonym_id = 0.0, catalog_cd = 0.0, catalog_type_cd = 0.0,
         activity_type_cd = 0.0, oe_format_id = 0.0, rx_mask = 0,
         multiple_ord_sent_ind = 0, orderable_type_flag = 0, dcp_clin_cat_cd = 0.0,
         ref_text_mask = 0, cki = value(fillstring(value(strlen2),"")), mnemonic_type_cd = 0.0,
         order_sentence_id = 0.0, order_sentence_disp_line = value(fillstring(value(strlen3)," ")),
         ord_sent_comment_id = 0.0,
         long_description_key_cap = ascat3.long_description_key_cap, long_description = ascat3
         .long_description, owner_id = ascat3.owner_id,
         usage_flag = 0, order_encntr_group_cd = 0.0, plan_display_description = pwc
         .display_description,
         pathway_catalog_id = pwc.pathway_catalog_id, witness_flag = 0,
         ingredient_rate_conversion_ind = 0,
         type_mean = pwc.type_mean, pathway_type_cd = pwc.pathway_type_cd, high_alert_ind = 0,
         high_alert_long_text_id = 0, high_alert_required_ntfy_ind = 0, pw_cat_synonym_id = pcs
         .pw_cat_synonym_id,
         pw_synonym_name = pcs.synonym_name, regimen_catalog_id = 0.0, regimen_catalog_synonym_id =
         0.0,
         regimen_synonym = value(fillstring(value(strlen5)," ")), synonym_cki = value(fillstring(
           value(strlen2)," ")), ordered_as_synonym_id = 0
         FROM alt_sel_list asl5,
          alt_sel_cat ascat3,
          pathway_catalog pwc,
          pw_cat_flex pcf,
          pw_cat_synonym pcs
         WHERE expand(num,start,stop,asl5.alt_sel_category_id,reply->get_list[num].
          alt_sel_category_id)
          AND asl5.list_type=plan_favorite
          AND asl5.alt_sel_category_id=ascat3.alt_sel_category_id
          AND pwc.pathway_catalog_id=asl5.pathway_catalog_id
          AND pwc.active_ind=1
          AND pcf.pathway_catalog_id=pwc.pathway_catalog_id
          AND ((pcf.parent_entity_name="CODE_VALUE"
          AND pcf.parent_entity_id IN (request->plan_facility_cd, 0.0)) OR (pcf.parent_entity_name=
         "PRSNL"
          AND pwc.type_mean="TAPERPLAN"))
          AND ((((pcs.pathway_catalog_id=asl5.pathway_catalog_id
          AND pwc.type_mean="TAPERPLAN") OR (pcs.pw_cat_synonym_id=asl5.pw_cat_synonym_id
          AND pwc.type_mean != "TAPERPLAN")) ) UNION (
         (SELECT
          alt_sel_cat_id = asl6.alt_sel_category_id, list_type = regimen_favorite, sequence = asl6
          .sequence,
          mnemonic = ascat4.short_description, updt_cnt = rc.updt_cnt, child_asc_id = 0.0,
          synonym_id = 0.0, catalog_cd = 0.0, catalog_type_cd = 0.0,
          activity_type_cd = 0.0, oe_format_id = 0.0, rx_mask = 0,
          multiple_ord_sent_ind = 0, orderable_type_flag = 0, dcp_clin_cat_cd = 0.0,
          ref_text_mask = 0, cki = value(fillstring(value(strlen2),"")), mnemonic_type_cd = 0.0,
          order_sentence_id = 0.0, order_sentence_disp_line = value(fillstring(value(strlen3)," ")),
          ord_sent_comment_id = 0.0,
          long_description_key_cap = ascat4.long_description_key_cap, long_description = ascat4
          .long_description, owner_id = ascat4.owner_id,
          usage_flag = 0, order_encntr_group_cd = 0.0, plan_display_description = value(fillstring(
            value(strlen4)," ")),
          pathway_catalog_id = 0.0, witness_flag = 0, ingredient_rate_conversion_ind = 0,
          type_mean = "", pathway_type_cd = 0.0, high_alert_ind = 0,
          high_alert_long_text_id = 0, high_alert_required_ntfy_ind = 0, pw_cat_synonym_id = 0.0,
          pw_synonym_name = "", regimen_catalog_id = rc.regimen_catalog_id,
          regimen_catalog_synonym_id = asl6.regimen_cat_synonym_id,
          regimen_synonym = rcs.synonym_display, synonym_cki = value(fillstring(value(strlen2)," ")),
          ordered_as_synonym_id = 0
          FROM alt_sel_list asl6,
           alt_sel_cat ascat4,
           regimen_cat_synonym rcs,
           regimen_catalog rc,
           regimen_cat_facility_r rcf
          WHERE expand(num,start,stop,asl6.alt_sel_category_id,reply->get_list[num].
           alt_sel_category_id)
           AND asl6.list_type=regimen_favorite
           AND asl6.alt_sel_category_id=ascat4.alt_sel_category_id
           AND rcs.regimen_cat_synonym_id=asl6.regimen_cat_synonym_id
           AND rc.regimen_catalog_id=rcs.regimen_catalog_id
           AND rc.active_ind=1
           AND rcf.regimen_catalog_id=rc.regimen_catalog_id
           AND rcf.location_cd IN (request->plan_facility_cd, 0.0))))
         WITH sqltype("F8","I4","I4","C500","I4",
           "F8","F8","F8","F8","F8",
           "F8","I4","I2","I2","F8",
           "I4","C255","F8","F8","C255",
           "F8","C1000","C1000","F8","I2",
           "F8","VC","F8","I2","I2",
           "C12","F8","I2","F8","I2",
           "F8","VC","F8","F8","VC",
           "C255","F8"))))
        WITH sqltype("F8","I4","I4","C500","I4",
          "F8","F8","F8","F8","F8",
          "F8","I4","I2","I2","F8",
          "I4","C255","F8","F8","C255",
          "F8","C1000","C1000","F8","I2",
          "F8","VC","F8","I2","I2",
          "C12","F8","I2","F8","I2",
          "F8","VC","F8","F8","VC",
          "C255","F8"))))
       WITH sqltype("F8","I4","I4","C500","I4",
         "F8","F8","F8","F8","F8",
         "F8","I4","I2","I2","F8",
         "I4","C255","F8","F8","C255",
         "F8","C1000","C1000","F8","I2",
         "F8","VC","F8","I2","I2",
         "C12","F8","I2","F8","I2",
         "F8","VC","F8","F8","VC",
         "C255","F8"))))
      WITH sqltype("F8","I4","I4","C500","I4",
        "F8","F8","F8","F8","F8",
        "F8","I4","I2","I2","F8",
        "I4","C255","F8","F8","C255",
        "F8","C1000","C1000","F8","I2",
        "F8","VC","F8","I2","I2",
        "C12","F8","I2","F8","I2",
        "F8","VC","F8","F8","VC",
        "C255","F8")))
     t1)
    ORDER BY t1.alt_sel_cat_id, t1.sequence
    HEAD t1.alt_sel_cat_id
     num = locateval(num,start,stop,t1.alt_sel_cat_id,reply->get_list[num].alt_sel_category_id),
     count2 = 0
    DETAIL
     count2 += 1
     IF (count2 > size(reply->get_list[num].child_list,5))
      stat = alterlist(reply->get_list[num].child_list,(count2+ 10))
     ENDIF
     reply->get_list[num].child_list[count2].sequence = t1.sequence, reply->get_list[num].child_list[
     count2].mnemonic = trim(t1.mnemonic,3), reply->get_list[num].child_list[count2].updt_cnt = t1
     .updt_cnt,
     reply->get_list[num].child_list[count2].ordsent_applicable_to_patient = 1
     IF (t1.list_type=synonym
      AND (request->view_orders_ind=1))
      reply->get_list[num].child_list[count2].list_type = synonym, reply->get_list[num].child_list[
      count2].synonym_id = t1.synonym_id, reply->get_list[num].child_list[count2].catalog_cd = t1
      .catalog_cd,
      reply->get_list[num].child_list[count2].catalog_type_cd = t1.catalog_type_cd, reply->get_list[
      num].child_list[count2].activity_type_cd = t1.activity_type_cd, reply->get_list[num].
      child_list[count2].oe_format_id = t1.oe_format_id,
      reply->get_list[num].child_list[count2].rx_mask = t1.rx_mask, reply->get_list[num].child_list[
      count2].multiple_ord_sent_ind = t1.multiple_ord_sent_ind, reply->get_list[num].child_list[
      count2].orderable_type_flag = t1.orderable_type_flag,
      reply->get_list[num].child_list[count2].dcp_clin_cat_cd = t1.dcp_clin_cat_cd, reply->get_list[
      num].child_list[count2].ref_text_mask = t1.ref_text_mask, reply->get_list[num].child_list[
      count2].cki = trim(t1.cki,3),
      reply->get_list[num].child_list[count2].mnemonic_type_cd = t1.mnemonic_type_cd, reply->
      get_list[num].child_list[count2].witness_flag = t1.witness_flag, reply->get_list[num].
      child_list[count2].ingredient_rate_conversion_ind = t1.ingredient_rate_conversion_ind,
      reply->get_list[num].child_list[count2].ordered_as_synonym_id = t1.ordered_as_synonym_id
      IF ((request->usage_flag != 0)
       AND t1.usage_flag != 0
       AND (t1.usage_flag != request->usage_flag))
       reply->get_list[num].child_list[count2].order_sentence_id = t1.order_sentence_id, reply->
       get_list[num].child_list[count2].ord_sent_comment_id = 0
      ELSE
       IF ((request->order_encntr_group_cd != 0)
        AND t1.order_encntr_group_cd != 0
        AND (t1.order_encntr_group_cd != request->order_encntr_group_cd))
        reply->get_list[num].child_list[count2].order_sentence_id = 0, reply->get_list[num].
        child_list[count2].ord_sent_comment_id = 0
       ELSE
        reply->get_list[num].child_list[count2].order_sentence_id = t1.order_sentence_id, reply->
        get_list[num].child_list[count2].order_sentence_disp_line = trim(t1.order_sentence_disp_line,
         3), reply->get_list[num].child_list[count2].ord_sent_comment_id = t1.ord_sent_comment_id
        IF ((reply->get_list[num].child_list[count2].ord_sent_comment_id > 0.0))
         comment_cnt += 1
         IF (comment_cnt > size(comments->qual,5))
          stat = alterlist(comments->qual,(comment_cnt+ 10))
         ENDIF
         comments->qual[comment_cnt].index1 = num, comments->qual[comment_cnt].index2 = count2,
         comments->qual[comment_cnt].cmt_id = reply->get_list[num].child_list[count2].
         ord_sent_comment_id
        ENDIF
       ENDIF
      ENDIF
      reply->get_list[num].child_list[count2].high_alert_ind = t1.high_alert_ind, reply->get_list[num
      ].child_list[count2].high_alert_long_text_id = t1.high_alert_long_text_id, reply->get_list[num]
      .child_list[count2].high_alert_required_ntfy_ind = t1.high_alert_required_ntfy_ind
      IF ((reply->get_list[num].child_list[count2].high_alert_long_text_id > 0))
       highalert_cnt += 1
       IF (highalert_cnt > size(highalert->qual,5))
        stat = alterlist(highalert->qual,(highalert_cnt+ 10))
       ENDIF
       highalert->qual[highalert_cnt].index1 = num, highalert->qual[highalert_cnt].index2 = count2,
       highalert->qual[highalert_cnt].high_alert_long_text_id = reply->get_list[num].child_list[
       count2].high_alert_long_text_id
      ENDIF
      IF ((reply->get_list[num].child_list[count2].order_sentence_id > 0))
       orders_size = size(filter_order_sentences->orders,5), temp_num = num, order_index = locateval(
        idx,1,orders_size,temp_num,filter_order_sentences->orders[idx].unique_identifier)
       IF (order_index <= 0)
        orders_size += 1, stat = alterlist(filter_order_sentences->orders,orders_size),
        filter_order_sentences->orders[orders_size].unique_identifier = num,
        order_index = orders_size
       ENDIF
       order_sentences_size = size(filter_order_sentences->orders[order_index].order_sentences,5),
       order_sentences_size += 1, stat = alterlist(filter_order_sentences->orders[order_index].
        order_sentences,order_sentences_size),
       filter_order_sentences->orders[order_index].order_sentences[order_sentences_size].
       order_sentence_id = reply->get_list[num].child_list[count2].order_sentence_id,
       filter_order_sentences->orders[order_index].order_sentences[order_sentences_size].
       order_sentence_filters_index = count2
      ENDIF
      IF (validate(request->load_preferred_ordering_ind,0)=1
       AND trim(t1.synonym_cki) != "")
       preferred_ordering_cnt += 1
       IF (preferred_ordering_cnt > size(preferred_ordering_indicators->orders,5))
        CALL alterlist(preferred_ordering_indicators->orders,(size(preferred_ordering_indicators->
         orders,5)+ 10))
       ENDIF
       preferred_ordering_indicators->orders[preferred_ordering_cnt].unique_identifier = num,
       preferred_ordering_indicators->orders[preferred_ordering_cnt].child_list_identifier = count2,
       preferred_ordering_indicators->orders[preferred_ordering_cnt].synonym_cki = nullterm(t1
        .synonym_cki)
      ENDIF
     ELSEIF (t1.list_type=iv_favorite
      AND (request->view_orders_ind=1))
      reply->get_list[num].child_list[count2].list_type = iv_favorite, reply->get_list[num].
      child_list[count2].child_alt_sel_cat_id = t1.child_asc_id, reply->get_list[num].child_list[
      count2].long_description_key_cap = trim(t1.long_description_key_cap,3),
      reply->get_list[num].child_list[count2].long_description = trim(t1.long_description,3), reply->
      get_list[num].child_list[count2].owner_id = t1.owner_id, reply->get_list[num].child_list[count2
      ].order_sentence_id = t1.order_sentence_id,
      reply->get_list[num].child_list[count2].order_sentence_disp_line = trim(t1
       .order_sentence_disp_line,3), reply->get_list[num].child_list[count2].ord_sent_comment_id = t1
      .ord_sent_comment_id
      IF ((reply->get_list[num].child_list[count2].ord_sent_comment_id > 0.0))
       comment_cnt += 1
       IF (comment_cnt > size(comments->qual,5))
        stat = alterlist(comments->qual,(comment_cnt+ 10))
       ENDIF
       comments->qual[comment_cnt].index1 = num, comments->qual[comment_cnt].index2 = count2,
       comments->qual[comment_cnt].cmt_id = reply->get_list[num].child_list[count2].
       ord_sent_comment_id
      ENDIF
     ELSEIF (t1.list_type=plan_favorite
      AND ((((t1.type_mean="TAPERPLAN") OR (t1.pathway_type_cd=ivsequence_cd))
      AND (request->view_orders_ind=1)) OR (t1.type_mean != "TAPERPLAN"
      AND (request->view_plans_ind=1))) )
      reply->get_list[num].child_list[count2].list_type = plan_favorite, reply->get_list[num].
      child_list[count2].plan_display_description = trim(t1.plan_display_description,3), reply->
      get_list[num].child_list[count2].pathway_catalog_id = t1.pathway_catalog_id,
      reply->get_list[num].child_list[count2].owner_id = t1.owner_id, reply->get_list[num].
      child_list[count2].child_alt_sel_cat_id = t1.child_asc_id, reply->get_list[num].child_list[
      count2].long_description_key_cap = trim(t1.long_description_key_cap,3),
      reply->get_list[num].child_list[count2].long_description = trim(t1.long_description,3), reply->
      get_list[num].child_list[count2].type_mean = t1.type_mean, reply->get_list[num].child_list[
      count2].pathway_type_cd = t1.pathway_type_cd,
      reply->get_list[num].child_list[count2].pw_cat_synonym_id = t1.pw_cat_synonym_id, reply->
      get_list[num].child_list[count2].pw_synonym_name = t1.pw_synonym_name
      IF ((reply->get_list[num].child_list[count2].pathway_catalog_id > 0))
       reftext_cnt += 1
       IF (reftext_cnt > size(reftext->qual,5))
        stat = alterlist(reftext->qual,(reftext_cnt+ 10))
       ENDIF
       reftext->qual[reftext_cnt].index1 = num, reftext->qual[reftext_cnt].index2 = count2, reftext->
       qual[reftext_cnt].pathway_catalog_id = reply->get_list[num].child_list[count2].
       pathway_catalog_id
      ENDIF
     ELSEIF (t1.list_type=regimen_favorite
      AND (request->view_regimens_ind=1))
      reply->get_list[num].child_list[count2].list_type = regimen_favorite, reply->get_list[num].
      child_list[count2].regimen_synonym = trim(t1.regimen_synonym,3), reply->get_list[num].
      child_list[count2].regimen_catalog_id = t1.regimen_catalog_id,
      reply->get_list[num].child_list[count2].owner_id = t1.owner_id, reply->get_list[num].
      child_list[count2].child_alt_sel_cat_id = t1.child_asc_id, reply->get_list[num].child_list[
      count2].long_description_key_cap = trim(t1.long_description_key_cap,3),
      reply->get_list[num].child_list[count2].long_description = trim(t1.long_description,3), reply->
      get_list[num].child_list[count2].regimen_catalog_synonym_id = t1.regimen_catalog_synonym_id
     ELSEIF (t1.list_type=child_folder)
      reply->get_list[num].child_list[count2].list_type = child_folder, reply->get_list[num].
      child_list[count2].owner_id = t1.owner_id, reply->get_list[num].child_list[count2].
      child_alt_sel_cat_id = t1.child_asc_id,
      reply->get_list[num].child_list[count2].long_description_key_cap = trim(t1
       .long_description_key_cap,3), reply->get_list[num].child_list[count2].long_description = trim(
       t1.long_description,3)
     ELSE
      count2 -= 1
     ENDIF
    FOOT  t1.alt_sel_cat_id
     stat = alterlist(reply->get_list[num].child_list,count2)
    WITH nocounter, rdbunion
   ;end select
   SET i += 1
   SET statementtime = datetimediff(sysdate,temptime)
   SET totaltime += statementtime
 ENDWHILE
 SET stop = 0
 WHILE (stop < comment_cnt)
   SET start = (stop+ 1)
   SET stop += 200
   IF (stop > comment_cnt)
    SET stop = comment_cnt
   ENDIF
   SELECT INTO "nl:"
    FROM long_text lt
    WHERE expand(num,start,stop,lt.long_text_id,comments->qual[num].cmt_id)
    DETAIL
     num = locateval(num,start,stop,lt.long_text_id,comments->qual[num].cmt_id), reply->get_list[
     comments->qual[num].index1].child_list[comments->qual[num].index2].ord_sent_comment = lt
     .long_text
    WITH nocounter
   ;end select
 ENDWHILE
 IF (value(size(reftext->qual,5)) > 0)
  SELECT INTO "nl:"
   FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = value(size(reftext->qual,5)))
   PLAN (d)
    JOIN (per
    WHERE (per.pathway_catalog_id=reftext->qual[d.seq].pathway_catalog_id))
   DETAIL
    IF (per.dcp_clin_cat_cd=0.0
     AND per.dcp_clin_sub_cat_cd=0.0
     AND per.pathway_comp_id=0.0)
     IF (per.type_mean="REFTEXT")
      reply->get_list[reftext->qual[d.seq].index1].child_list[reftext->qual[d.seq].index2].
      pw_evidence_reltn_id = per.pw_evidence_reltn_id
     ENDIF
     IF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
      reply->get_list[reftext->qual[d.seq].index1].child_list[reftext->qual[d.seq].index2].
      evidence_locator = per.evidence_locator
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM ref_text_reltn rr,
    (dummyt d  WITH seq = value(size(reftext->qual,5)))
   PLAN (d)
    JOIN (rr
    WHERE (rr.parent_entity_id=reftext->qual[d.seq].pathway_catalog_id)
     AND rr.parent_entity_name="PATHWAY_CATALOG"
     AND rr.active_ind=1)
   DETAIL
    reply->get_list[reftext->qual[d.seq].index1].child_list[reftext->qual[d.seq].index2].
    plan_ref_text_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (value(size(highalert->qual,5)) > 0)
  SELECT INTO "nl:"
   FROM long_text lt,
    (dummyt d  WITH seq = value(size(highalert->qual,5)))
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=highalert->qual[d.seq].high_alert_long_text_id))
   DETAIL
    reply->get_list[highalert->qual[d.seq].index1].child_list[highalert->qual[d.seq].index2].
    high_alert_text = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 IF (orders_size > 0)
  IF (validate(request->patient_demographic.birth_dt_tm)=1)
   SET filter_order_sentences->patient_criteria.birth_dt_tm = request->patient_demographic.
   birth_dt_tm
   SET filter_order_sentences->patient_criteria.birth_tz = request->patient_demographic.birth_tz
   SET filter_order_sentences->patient_criteria.postmenstrual_age_in_days = request->
   patient_demographic.postmenstrual_age_in_days
   SET filter_order_sentences->patient_criteria.weight = request->patient_demographic.weight
   SET filter_order_sentences->patient_criteria.weight_unit_cd = request->patient_demographic.
   weight_unit_cd
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
   DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
   SUBROUTINE (filterordersentences(orm_filter_order_sentences_record=vc(ref)) =null)
    IF (size(orm_filter_order_sentences_record->orders,5) > 0)
     SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationname =
     "FilterOrderSentences"
     DECLARE hmessage = i4 WITH private, constant(uar_srvselect("FilterOrderSentences"))
     IF (hmessage=0)
      SET orm_filter_order_sentences_record->status_data.status = "F"
      SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
      "Error creating Transaction Message"
     ELSE
      DECLARE hrequest = i4 WITH private, constant(uar_srvcreaterequest(hmessage))
      IF (hrequest=0)
       SET orm_filter_order_sentences_record->status_data.status = "F"
       SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
       "Error creating the Request for the transaction"
      ELSE
       DECLARE hreply = i4 WITH private, constant(uar_srvcreatereply(hmessage))
       IF (hreply=0)
        SET orm_filter_order_sentences_record->status_data.status = "F"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
        "Error creating the Reply for the transaction"
       ELSE
        CALL populatepatientcriteria(orm_filter_order_sentences_record,hrequest)
        CALL populaterequest(orm_filter_order_sentences_record,hrequest)
        CALL executefilterordersentences(orm_filter_order_sentences_record,hmessage,hrequest,hreply)
        IF ((orm_filter_order_sentences_record->status_data.status="S"))
         CALL unpackreply(orm_filter_order_sentences_record,hreply)
        ELSE
         SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "F"
         SET orm_filter_order_sentences_record->status_data.subeventstatus[1].targetobjectvalue =
         uar_srvgetstringptr(uar_srvgetstruct(hreply,"transaction_status"),"debug_error_message")
        ENDIF
        CALL uar_srvdestroyinstance(hreply)
       ENDIF
       CALL uar_srvdestroyinstance(hrequest)
      ENDIF
      CALL uar_srvdestroyinstance(hmessage)
     ENDIF
    ELSE
     SET orm_filter_order_sentences_record->status_data.status = "S"
    ENDIF
    RETURN
   END ;Subroutine
   SUBROUTINE (populatepatientcriteria(orm_filter_order_sentences_record=vc(ref),hrequest=i4) =null)
     DECLARE hpatientcriteria = i4 WITH private, constant(uar_srvgetstruct(hrequest,
       "patient_criteria"))
     IF (hpatientcriteria != 0)
      CALL uar_srvsetdate(hpatientcriteria,"birth_dt_tm",cnvtdatetime(
        orm_filter_order_sentences_record->patient_criteria.birth_dt_tm))
      CALL uar_srvsetlong(hpatientcriteria,"birth_tz",orm_filter_order_sentences_record->
       patient_criteria.birth_tz)
      CALL uar_srvsetlong(hpatientcriteria,"postmenstrual_age_in_days",
       orm_filter_order_sentences_record->patient_criteria.postmenstrual_age_in_days)
      CALL uar_srvsetdouble(hpatientcriteria,"weight",orm_filter_order_sentences_record->
       patient_criteria.weight)
      CALL uar_srvsetdouble(hpatientcriteria,"weight_unit_cd",orm_filter_order_sentences_record->
       patient_criteria.weight_unit_cd)
     ENDIF
     RETURN
   END ;Subroutine
   SUBROUTINE (populaterequest(orm_filter_order_sentences_record=vc(ref),hrequest=i4) =null)
     DECLARE iordersindex = i4 WITH private, noconstant(0)
     DECLARE irequestorderssize = i4 WITH private, constant(size(orm_filter_order_sentences_record->
       orders,5))
     DECLARE horders = i4 WITH private, noconstant(0)
     DECLARE iordersentenceindex = i4 WITH private, noconstant(0)
     DECLARE iordersentencessize = i4 WITH private, noconstant(0)
     DECLARE hordersentences = i4 WITH private, noconstant(0)
     FOR (iordersindex = 1 TO irequestorderssize)
      SET horders = uar_srvadditem(hrequest,"orders")
      IF (horders != 0)
       CALL uar_srvsetdouble(horders,"unique_identifier",orm_filter_order_sentences_record->orders[
        iordersindex].unique_identifier)
       SET iordersentencessize = size(orm_filter_order_sentences_record->orders[iordersindex].
        order_sentences,5)
       IF (iordersentencessize > 0)
        FOR (iordersentenceindex = 1 TO iordersentencessize)
         SET hordersentences = uar_srvadditem(horders,"order_sentences")
         IF (hordersentences != 0)
          CALL uar_srvsetdouble(hordersentences,"order_sentence_id",orm_filter_order_sentences_record
           ->orders[iordersindex].order_sentences[iordersentenceindex].order_sentence_id)
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDFOR
     RETURN
   END ;Subroutine
   SUBROUTINE (executefilterordersentences(orm_filter_order_sentences_record=vc(ref),hmessage=i4,
    hrequest=i4,hreply=i4) =null)
     IF (uar_srvexecute(hmessage,hrequest,hreply)=0)
      DECLARE htransactionstatus = i4 WITH private, constant(uar_srvgetstruct(hreply,
        "transaction_status"))
      IF (htransactionstatus != 0)
       IF (uar_srvgetshort(htransactionstatus,"success_ind")=1)
        SET orm_filter_order_sentences_record->status_data.status = "S"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "S"
       ELSE
        SET orm_filter_order_sentences_record->status_data.status = "F"
        SET orm_filter_order_sentences_record->status_data.subeventstatus[1].operationstatus = "S"
       ENDIF
      ENDIF
     ENDIF
   END ;Subroutine
   SUBROUTINE (unpackreply(orm_filter_order_sentences_record=vc(ref),hreply=i4) =null)
     DECLARE lfindindex = i4 WITH private, noconstant(0)
     DECLARE iordersindex = i4 WITH private, noconstant(0)
     DECLARE iorderssize = i4 WITH private, constant(size(orm_filter_order_sentences_record->orders,5
       ))
     DECLARE horders = i4 WITH private, noconstant(0)
     DECLARE iordersentenceindex = i4 WITH private, noconstant(0)
     DECLARE hordersentences = i4 WITH private, noconstant(0)
     DECLARE ireplyordersindex = i4 WITH private, noconstant(0)
     DECLARE ireplyordersentencesize = i4 WITH private, noconstant(0)
     DECLARE ireplyordersentenceindex = i4 WITH private, noconstant(0)
     DECLARE iordersentfilterindex = i4 WITH private, noconstant(0)
     DECLARE iordersentfiltersize = i4 WITH private, noconstant(0)
     DECLARE hordersentencefilters = i4 WITH private, noconstant(0)
     DECLARE hordersentencefiltertype = i4 WITH private, noconstant(0)
     FOR (ireplyordersindex = 1 TO iorderssize)
      SET horders = uar_srvgetitem(hreply,"orders",(ireplyordersindex - 1))
      IF (horders != 0)
       SET iordersindex = locateval(lfindindex,1,iorderssize,uar_srvgetdouble(horders,
         "unique_identifier"),orm_filter_order_sentences_record->orders[lfindindex].unique_identifier
        )
       WHILE (iordersindex > 0)
         SET ireplyordersentencesize = uar_srvgetitemcount(horders,"order_sentences")
         FOR (ireplyordersentenceindex = 1 TO ireplyordersentencesize)
          SET hordersentences = uar_srvgetitem(horders,"order_sentences",(ireplyordersentenceindex -
           1))
          IF (hordersentences != 0)
           SET iordersentenceindex = locateval(lfindindex,1,size(orm_filter_order_sentences_record->
             orders[iordersindex].order_sentences,5),uar_srvgetdouble(hordersentences,
             "order_sentence_id"),orm_filter_order_sentences_record->orders[iordersindex].
            order_sentences[lfindindex].order_sentence_id)
           IF (iordersentenceindex > 0)
            SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
            iordersentenceindex].applicable_to_patient_ind = uar_srvgetshort(hordersentences,
             "applicable_to_patient_ind")
            SET iordersentfiltersize = uar_srvgetitemcount(hordersentences,"order_sentence_filters")
            IF (iordersentfiltersize > 0)
             SET stat = alterlist(orm_filter_order_sentences_record->orders[iordersindex].
              order_sentences[iordersentenceindex].order_sentence_filters,iordersentfiltersize)
             FOR (iordersentfilterindex = 1 TO iordersentfiltersize)
              SET hordersentencefilters = uar_srvgetitem(hordersentences,"order_sentence_filters",0)
              IF (hordersentencefilters != 0)
               SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
               iordersentenceindex].order_sentence_filters[iordersentfilterindex].
               order_sentence_filter_display = uar_srvgetstringptr(hordersentencefilters,
                "order_sentence_filter_display")
               SET hordersentencefiltertype = uar_srvgetstruct(hordersentencefilters,
                "order_sentence_filter_type")
               IF (hordersentencefiltertype != 0)
                IF (validate(orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type) > 0)
                 SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type.age_filter_ind = uar_srvgetshort(hordersentencefiltertype,
                  "age_filter_ind")
                 SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type.pma_filter_ind = uar_srvgetshort(hordersentencefiltertype,
                  "pma_filter_ind")
                 SET orm_filter_order_sentences_record->orders[iordersindex].order_sentences[
                 iordersentenceindex].order_sentence_filters[iordersentfilterindex].
                 order_sentence_filter_type.weight_filter_ind = uar_srvgetshort(
                  hordersentencefiltertype,"weight_filter_ind")
                ENDIF
               ENDIF
              ENDIF
             ENDFOR
            ENDIF
           ENDIF
          ENDIF
         ENDFOR
         SET iordersindex = locateval(lfindindex,(iordersindex+ 1),iorderssize,uar_srvgetdouble(
           horders,"unique_identifier"),orm_filter_order_sentences_record->orders[lfindindex].
          unique_identifier)
       ENDWHILE
      ENDIF
     ENDFOR
     SET last_mod = "003"
     SET mod_date = "May 05, 2022"
   END ;Subroutine
   CALL filterordersentences(filter_order_sentences)
   IF ((filter_order_sentences->status_data.status="S"))
    DECLARE sentencelocateindex = i4 WITH private, noconstant(0)
    DECLARE ireplyordersentencesize = i4 WITH private, noconstant(0)
    FOR (filteredorderidx = 1 TO size(filter_order_sentences->orders,5))
      SET ireplyordersentencesize = size(filter_order_sentences->orders[filteredorderidx].
       order_sentences,5)
      SET replyorderidx = filter_order_sentences->orders[filteredorderidx].unique_identifier
      FOR (filteredordsenidx = 1 TO ireplyordersentencesize)
        SET replyordsenidx = filter_order_sentences->orders[filteredorderidx].order_sentences[
        filteredordsenidx].order_sentence_filters_index
        SET reply->get_list[replyorderidx].child_list[replyordsenidx].ordsent_applicable_to_patient
         = filter_order_sentences->orders[filteredorderidx].order_sentences[filteredordsenidx].
        applicable_to_patient_ind
        IF (size(filter_order_sentences->orders[filteredorderidx].order_sentences[filteredordsenidx].
         order_sentence_filters,5) > 0)
         SET sentencelocateindex = locateval(num,(filteredordsenidx+ 1),ireplyordersentencesize,
          filter_order_sentences->orders[filteredorderidx].order_sentences[filteredordsenidx].
          order_sentence_id,filter_order_sentences->orders[filteredorderidx].order_sentences[num].
          order_sentence_id)
         IF (sentencelocateindex > 0)
          SET stat = alterlist(filter_order_sentences->orders[filteredorderidx].order_sentences[
           sentencelocateindex].order_sentence_filters,1)
          SET filter_order_sentences->orders[filteredorderidx].order_sentences[sentencelocateindex].
          order_sentence_filters[1].order_sentence_filter_display = filter_order_sentences->orders[
          filteredorderidx].order_sentences[filteredordsenidx].order_sentence_filters[1].
          order_sentence_filter_display
         ENDIF
         SET reply->get_list[replyorderidx].child_list[replyordsenidx].ordsent_filter_display =
         filter_order_sentences->orders[filteredorderidx].order_sentences[filteredordsenidx].
         order_sentence_filters[1].order_sentence_filter_display
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
  ENDIF
 ENDIF
 IF (validate(request->load_preferred_ordering_ind,0)=1)
  EXECUTE crmrtl
  EXECUTE srvrtl
  SUBROUTINE (getpreferenceindicatorsbysynonyms(preferred_ordering_indicators_record=vc(ref)) =null)
   IF (size(preferred_ordering_indicators_record->orders,5) > 0)
    SET preferred_ordering_indicators_record->status_data.subeventstatus[1].operationname =
    "GetReferenceIndicatorsBySynonyms"
    DECLARE hmessage = i4 WITH private, constant(uar_srvselect("GetReferenceIndicatorsBySynonyms"))
    IF (hmessage=0)
     SET preferred_ordering_indicators_record->status_data.status = "F"
     SET preferred_ordering_indicators_record->status_data.subeventstatus[1].targetobjectvalue =
     "Error creating Transaction Message"
    ELSE
     DECLARE hrequest = i4 WITH private, constant(uar_srvcreaterequest(hmessage))
     IF (hrequest=0)
      SET preferred_ordering_indicators_record->status_data.status = "F"
      SET preferred_ordering_indicators_record->status_data.subeventstatus[1].targetobjectvalue =
      "Error creating the Request for the transaction"
     ELSE
      DECLARE hreply = i4 WITH private, constant(uar_srvcreatereply(hmessage))
      IF (hreply=0)
       SET preferred_ordering_indicators_record->status_data.status = "F"
       SET preferred_ordering_indicators_record->status_data.subeventstatus[1].targetobjectvalue =
       "Error creating the Reply for the transaction"
      ELSE
       CALL populaterequestforpreferenceindicators(preferred_ordering_indicators_record,hrequest)
       CALL executegetreferenceindicatorsbysynonyms(preferred_ordering_indicators_record,hmessage,
        hrequest,hreply)
       IF ((preferred_ordering_indicators_record->status_data.status="S"))
        CALL unpackreplypreferenceindicators(preferred_ordering_indicators_record,hreply)
       ELSE
        SET preferred_ordering_indicators_record->status_data.subeventstatus[1].operationstatus = "F"
        SET preferred_ordering_indicators_record->status_data.subeventstatus[1].targetobjectvalue =
        uar_srvgetstringptr(uar_srvgetstruct(hreply,"transaction_status"),"debug_error_message")
       ENDIF
       CALL uar_srvdestroyinstance(hreply)
      ENDIF
      CALL uar_srvdestroyinstance(hrequest)
     ENDIF
     CALL uar_srvdestroyinstance(hmessage)
    ENDIF
   ELSE
    SET preferred_ordering_indicators_record->status_data.status = "S"
   ENDIF
   RETURN
  END ;Subroutine
  SUBROUTINE (populaterequestforpreferenceindicators(preferred_ordering_indicators_record=vc(ref),
   hrequest=i4) =null)
    DECLARE hrequestloadindicators = i4 WITH private, constant(uar_srvgetstruct(hrequest,
      "load_indicators"))
    IF (hrequestloadindicators != 0)
     CALL uar_srvsetshort(hrequestloadindicators,"retrieve_multum_indicators",1)
     CALL uar_srvsetshort(hrequestloadindicators,"retrieve_millennium_indicators",1)
    ENDIF
    DECLARE iordersindex = i4 WITH private, noconstant(0)
    DECLARE irequestorderssize = i4 WITH private, constant(size(preferred_ordering_indicators_record
      ->orders,5))
    DECLARE hsynonym = i4 WITH private, noconstant(0)
    FOR (iordersindex = 1 TO irequestorderssize)
     SET hsynonym = uar_srvadditem(hrequest,"synonyms")
     IF (hsynonym != 0)
      CALL uar_srvsetstring(hsynonym,"synonym_cki",preferred_ordering_indicators_record->orders[
       iordersindex].synonym_cki)
     ENDIF
    ENDFOR
    RETURN
  END ;Subroutine
  SUBROUTINE (executegetreferenceindicatorsbysynonyms(preferred_ordering_indicators_record=vc(ref),
   hmessage=i4,hrequest=i4,hreply=i4) =null)
    IF (uar_srvexecute(hmessage,hrequest,hreply)=0)
     DECLARE htransactionstatus = i4 WITH private, constant(uar_srvgetstruct(hreply,
       "transaction_status"))
     IF (htransactionstatus != 0)
      IF (uar_srvgetshort(htransactionstatus,"success_ind")=1)
       SET preferred_ordering_indicators_record->status_data.status = "S"
       SET preferred_ordering_indicators_record->status_data.subeventstatus[1].operationstatus = "S"
      ELSE
       SET preferred_ordering_indicators_record->status_data.status = "F"
       SET preferred_ordering_indicators_record->status_data.subeventstatus[1].operationstatus = "F"
      ENDIF
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE (unpackreplypreferenceindicators(preferred_ordering_indicators_record=vc(ref),hreply=i4
   ) =null)
    DECLARE ifindindex = i4 WITH private, noconstant(0)
    DECLARE iordersindex = i4 WITH private, noconstant(0)
    DECLARE ireplyordersindex = i4 WITH private, noconstant(0)
    DECLARE iorderssize = i4 WITH private, constant(size(preferred_ordering_indicators_record->orders,
      5))
    DECLARE ireplyindicatorsize = i4 WITH private, noconstant(0)
    DECLARE ireplyindicatorindex = i4 WITH private, noconstant(0)
    DECLARE iinvalidsynonymind = i2 WITH private, noconstant(0)
    DECLARE hindicator = i4 WITH private, noconstant(0)
    DECLARE sindicatorvalue = vc WITH private, noconstant("")
    DECLARE iloopindex = i4 WITH private, noconstant(0)
    FOR (ireplyordersindex = 0 TO (iorderssize - 1))
     SET hreplysynonym = uar_srvgetitem(hreply,"synonyms",ireplyordersindex)
     IF (hreplysynonym != 0)
      SET iordersindex = locateval(ifindindex,1,iorderssize,uar_srvgetstringptr(hreplysynonym,
        "synonym_cki"),preferred_ordering_indicators_record->orders[ifindindex].synonym_cki)
      SET iloopindex = iordersindex
      WHILE (iordersindex > 0
       AND iloopindex <= iorderssize)
        SET iinvalidsynonymind = uar_srvgetshort(hreplysynonym,"invalid_synonym_ind")
        IF (iinvalidsynonymind=0)
         SET ireplyindicatorsize = uar_srvgetitemcount(hreplysynonym,"multum_reference_indicators")
         IF (ireplyindicatorsize > 0)
          FOR (ireplyindicatorindex = 0 TO ireplyindicatorsize)
           SET hindicator = uar_srvgetitem(hreplysynonym,"multum_reference_indicators",
            ireplyindicatorindex)
           IF (hindicator > 0)
            SET sindicatorvalue = uar_srvgetstringptr(hindicator,"multum_indicator")
            IF (sindicatorvalue="R")
             SET preferred_ordering_indicators_record->orders[iordersindex].r_preferred_ind = 1
            ELSEIF (sindicatorvalue="U")
             SET preferred_ordering_indicators_record->orders[iordersindex].u_preferred_ind = 1
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
         SET ireplyindicatorsize = uar_srvgetitemcount(hreplysynonym,
          "millennium_reference_indicators")
         IF (ireplyindicatorsize > 0)
          FOR (ireplyindicatorindex = 0 TO ireplyindicatorsize)
           SET hindicator = uar_srvgetitem(hreplysynonym,"millennium_reference_indicators",
            ireplyindicatorindex)
           IF (hindicator > 0)
            SET sindicatorvalue = uar_srvgetstringptr(hindicator,"millennium_indicator")
            IF (sindicatorvalue="D")
             SET preferred_ordering_indicators_record->orders[iordersindex].d_preferred_ind = 1
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
        SET iloopindex += 1
        SET iordersindex = locateval(ifindindex,iloopindex,iorderssize,uar_srvgetstringptr(
          hreplysynonym,"synonym_cki"),preferred_ordering_indicators_record->orders[ifindindex].
         synonym_cki)
      ENDWHILE
     ENDIF
    ENDFOR
  END ;Subroutine
  CALL alterlist(preferred_ordering_indicators->orders,preferred_ordering_cnt)
  CALL getpreferenceindicatorsbysynonyms(preferred_ordering_indicators)
  IF ((preferred_ordering_indicators->status_data.status="S"))
   FOR (preferredorderingindex = 1 TO size(preferred_ordering_indicators->orders,5))
     SET replyorderindex = preferred_ordering_indicators->orders[preferredorderingindex].
     unique_identifier
     SET childlistindex = preferred_ordering_indicators->orders[preferredorderingindex].
     child_list_identifier
     SET reply->get_list[replyorderindex].child_list[childlistindex].r_preferred_ind =
     preferred_ordering_indicators->orders[preferredorderingindex].r_preferred_ind
     SET reply->get_list[replyorderindex].child_list[childlistindex].u_preferred_ind =
     preferred_ordering_indicators->orders[preferredorderingindex].u_preferred_ind
     SET reply->get_list[replyorderindex].child_list[childlistindex].d_preferred_ind =
     preferred_ordering_indicators->orders[preferredorderingindex].d_preferred_ind
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SET mod_date = "December 18, 2023"
 SET last_mod = "040"
END GO
