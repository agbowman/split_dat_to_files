CREATE PROGRAM bed_get_mos_syns_by_ord:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 mnemonic_type_code_value = f8
       3 mnemonic_type_display = vc
       3 oe_format_id = f8
       3 sentences[*]
         4 sentence_id = f8
         4 ext_identifier = vc
         4 full_display = vc
         4 display = vc
         4 source_flag = i2
         4 count = i4
         4 sequence = i4
         4 comment_id = f8
         4 comment_txt = vc
         4 usage_flag = i2
         4 encntr_group_code_value = f8
         4 details[*]
           5 oe_field_id = f8
           5 oe_field_label = vc
           5 field_disp_value = vc
           5 field_code_value = f8
       3 products[*]
         4 item_id = f8
       3 mnemonic_type_meaning = vc
     2 products[*]
       3 item_id = f8
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 invalid_formats[*]
     2 oe_format_id = f8
     2 name = vc
     2 fields[*]
       3 description = vc
 )
 FREE SET treply
 RECORD treply(
   1 orders[*]
     2 catalog_code_value = f8
     2 synonyms[*]
       3 synonym_id = f8
       3 oe_format_id = f8
       3 sentences[*]
         4 ext_identifier = vc
         4 os_id = f8
         4 full_display = vc
         4 display = vc
         4 load_ind = i2
         4 source = i2
         4 count = i4
         4 comment_id = f8
         4 comment_txt = vc
         4 encntr_group_code_value = f8
         4 oe_format_id = f8
         4 details[*]
           5 oe_field_id = f8
           5 field_disp_value = vc
           5 field_code_value = f8
           5 oe_field_label = vc
           5 field_meaning = vc
           5 codeset = i4
           5 group_seq = i4
           5 field_seq = i4
           5 field_type_flag = i2
           5 clin_line_label = vc
           5 label_text = vc
           5 clin_suffix_ind = i2
           5 clin_line_ind = i2
           5 disp_yes_no_flag = i2
 )
 FREE SET treply2
 RECORD treply2(
   1 orders[*]
     2 synonyms[*]
       3 sentences[*]
         4 ext_identifier = vc
         4 os_id = f8
         4 full_display = vc
         4 display = vc
         4 load_ind = i2
         4 source = i2
         4 count = i4
         4 comment_id = f8
         4 comment_txt = vc
         4 details[*]
           5 oe_field_id = f8
           5 field_disp_value = vc
           5 field_code_value = f8
           5 oe_field_label = vc
           5 field_meaning = vc
           5 codeset = i4
           5 group_seq = i4
           5 field_seq = i4
           5 field_type_flag = i2
           5 clin_line_label = vc
           5 label_text = vc
           5 clin_suffix_ind = i2
           5 clin_line_ind = i2
           5 exist_ind = i2
           5 disp_yes_no_flag = i2
 )
 FREE SET bad_oe
 RECORD bad_oe(
   1 oefs[*]
     2 id = f8
     2 name = vc
     2 field_mean = vc
     2 field_desc = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET orderable_code_value = 0.0
 SET orderable_code_value = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET inpatient_code_value = 0.0
 SET inpatient_code_value = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET sys_pkg_code_value = 0.0
 SET sys_pkg_code_value = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET system_code_value = 0.0
 SET system_code_value = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET desc_code_value = 0.0
 SET desc_code_value = uar_get_code_by("MEANING",11000,"DESC")
 SET oe_order_code_value = 0.0
 SET oe_order_code_value = uar_get_code_by("MEANING",6003,"ORDER")
 SET action_code = 0.0
 IF ((request->usage_flag=2))
  SET action_code = uar_get_code_by("MEANING",6003,"DISORDER")
 ELSE
  SET action_code = uar_get_code_by("MEANING",6003,"ORDER")
 ENDIF
 SET req_cnt = size(request->orders,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->orders,req_cnt)
 SET stat = alterlist(treply->orders,req_cnt)
 FOR (x = 0 TO req_cnt)
  SET reply->orders[x].catalog_code_value = request->orders[x].catalog_code_value
  SET treply->orders[x].catalog_code_value = request->orders[x].catalog_code_value
 ENDFOR
 SET max_syn_cnt = 0
 SELECT INTO "nl:"
  mtype = uar_get_code_display(ocs.mnemonic_type_cd), mmean = uar_get_code_meaning(ocs
   .mnemonic_type_cd)
  FROM (dummyt d1  WITH seq = value(req_cnt)),
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (d1)
   JOIN (ocs
   WHERE (ocs.catalog_cd=reply->orders[d1.seq].catalog_code_value)
    AND ((ocs.mnemonic_type_cd+ 0) IN (primary_code_value, brand_code_value, dcp_code_value,
   c_code_value, e_code_value,
   m_code_value, n_code_value))
    AND ocs.active_ind=1
    AND ocs.hide_flag IN (0, null))
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id
    AND ofr.facility_cd IN (request->facility_code_value))
  ORDER BY d1.seq, ocs.synonym_id
  HEAD d1.seq
   scnt = 0, stcnt = 0, stat = alterlist(reply->orders[d1.seq].synonyms,10),
   stat = alterlist(treply->orders[d1.seq].synonyms,10)
  HEAD ocs.synonym_id
   scnt = (scnt+ 1), stcnt = (stcnt+ 1)
   IF (scnt > 10)
    stat = alterlist(reply->orders[d1.seq].synonyms,(stcnt+ 10)), stat = alterlist(treply->orders[d1
     .seq].synonyms,(stcnt+ 10)), scnt = 1
   ENDIF
   reply->orders[d1.seq].synonyms[stcnt].synonym_id = ocs.synonym_id, reply->orders[d1.seq].synonyms[
   stcnt].mnemonic = ocs.mnemonic, reply->orders[d1.seq].synonyms[stcnt].oe_format_id = ocs
   .oe_format_id,
   reply->orders[d1.seq].synonyms[stcnt].mnemonic_type_code_value = ocs.mnemonic_type_cd, reply->
   orders[d1.seq].synonyms[stcnt].mnemonic_type_display = mtype, reply->orders[d1.seq].synonyms[stcnt
   ].mnemonic_type_meaning = mmean,
   treply->orders[d1.seq].synonyms[stcnt].synonym_id = ocs.synonym_id, treply->orders[d1.seq].
   synonyms[stcnt].oe_format_id = ocs.oe_format_id
  FOOT  d1.seq
   stat = alterlist(reply->orders[d1.seq].synonyms,stcnt), stat = alterlist(treply->orders[d1.seq].
    synonyms,stcnt)
   IF (stcnt > max_syn_cnt)
    max_syn_cnt = stcnt
   ENDIF
  WITH nocounter
 ;end select
 IF (max_syn_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_catalog_item_r ocir,
   medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   item_definition id,
   med_identifier mi
  PLAN (d)
   JOIN (ocir
   WHERE (ocir.catalog_cd=reply->orders[d.seq].catalog_code_value))
   JOIN (md
   WHERE ocir.item_id=md.item_id)
   JOIN (mdf
   WHERE md.item_id=mdf.item_id
    AND mdf.pharmacy_type_cd=inpatient_code_value
    AND mdf.flex_type_cd=sys_pkg_code_value)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND ((mfoi.flex_object_type_cd+ 0)=orderable_code_value)
    AND ((mfoi.parent_entity_id+ 0) IN (0, request->facility_code_value))
    AND mfoi.active_ind=1)
   JOIN (id
   WHERE md.item_id=id.item_id
    AND ((id.active_ind+ 0)=1))
   JOIN (mi
   WHERE mi.item_id=id.item_id
    AND mi.pharmacy_type_cd=inpatient_code_value
    AND mi.med_identifier_type_cd=desc_code_value
    AND ((mi.flex_type_cd+ 0)=system_code_value)
    AND mi.primary_ind=1
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.active_ind+ 0)=1))
  ORDER BY d.seq, md.item_id
  HEAD d.seq
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->orders[d.seq].products,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->orders[d.seq].products,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->orders[d.seq].products[tot_cnt].item_id = md.item_id, reply->orders[d.seq].products[tot_cnt
   ].description = mi.value
  FOOT  d.seq
   stat = alterlist(reply->orders[d.seq].products,tot_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(treply2->orders,req_cnt)
 FOR (w = 1 TO req_cnt)
   SET syn_cnt = size(treply->orders[w].synonyms,5)
   SET stat = alterlist(treply2->orders[w].synonyms,syn_cnt)
   IF (syn_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(syn_cnt)),
      synonym_item_r s,
      med_identifier mi
     PLAN (d)
      JOIN (s
      WHERE (s.synonym_id=reply->orders[w].synonyms[d.seq].synonym_id))
      JOIN (mi
      WHERE mi.item_id=s.item_id
       AND mi.pharmacy_type_cd=inpatient_code_value
       AND mi.med_identifier_type_cd=desc_code_value
       AND ((mi.flex_type_cd+ 0)=system_code_value)
       AND mi.primary_ind=1
       AND ((mi.med_product_id+ 0)=0)
       AND ((mi.active_ind+ 0)=1))
     ORDER BY d.seq
     HEAD d.seq
      cnt = 0, tot_cnt = 0, stat = alterlist(reply->orders[w].synonyms[d.seq].products,10)
     DETAIL
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(reply->orders[w].synonyms[d.seq].products,(tot_cnt+ 10)), cnt = 1
      ENDIF
      reply->orders[w].synonyms[d.seq].products[tot_cnt].item_id = s.item_id
     FOOT  d.seq
      stat = alterlist(reply->orders[w].synonyms[d.seq].products,tot_cnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(syn_cnt)),
      order_catalog_synonym ocs,
      mltm_order_sent mos,
      mltm_order_sent_detail mosd
     PLAN (d
      WHERE size(reply->orders[w].synonyms[d.seq].products,5)=0)
      JOIN (ocs
      WHERE (ocs.synonym_id=reply->orders[w].synonyms[d.seq].synonym_id))
      JOIN (mos
      WHERE mos.synonym_cki=ocs.cki
       AND (mos.usage_flag=request->usage_flag)
       AND trim(mos.external_identifier)="MUL.IP!*")
      JOIN (mosd
      WHERE mosd.external_identifier=mos.external_identifier)
     ORDER BY d.seq, mosd.external_identifier, mosd.sequence
     HEAD d.seq
      cnt = 0, tot_cnt = 0, stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,10)
     HEAD mosd.external_identifier
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10)), cnt = 1
      ENDIF
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].ext_identifier = mos.external_identifier,
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].load_ind = 1, treply2->orders[w].
      synonyms[d.seq].sentences[tot_cnt].source = 1,
      dcnt = 0, dtcnt = 0, stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].
       details,10),
      dose_unit_ind = 0, sd_ind = 0, sdu_ind = 0,
      vd_ind = 0, vdu_ind = 0, ftd_ind = 0
     HEAD mosd.sequence
      dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
      IF (dcnt > 10)
       stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,(dtcnt+ 10)),
       dcnt = 1
      ENDIF
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details[dtcnt].field_disp_value = mosd
      .oe_field_value, treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details[dtcnt].
      field_meaning = mosd.oe_field_meaning
      IF (mosd.oe_field_meaning="STRENGTHDOSE")
       sd_ind = 1
      ELSEIF (mosd.oe_field_meaning="STRENGTHDOSEUNIT")
       sdu_ind = 1
      ELSEIF (mosd.oe_field_meaning="VOLUMEDOSE")
       vd_ind = 1
      ELSEIF (mosd.oe_field_meaning="VOLUMEDOSEUNIT")
       vdu_ind = 1
      ELSEIF (mosd.oe_field_meaning="FREETXTDOSE")
       ftd_ind = 1
      ENDIF
     FOOT  mosd.external_identifier
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,dtcnt)
      IF (((sd_ind=1
       AND sdu_ind != 1) OR (((vd_ind=1
       AND vdu_ind != 1) OR (((sd_ind != 1
       AND sdu_ind=1) OR (((vd_ind != 1
       AND vdu_ind=1) OR (sd_ind=0
       AND sdu_ind=0
       AND vd_ind=0
       AND vdu_ind=0
       AND ftd_ind != 1)) )) )) )) )
       treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].load_ind = 0
      ENDIF
     FOOT  d.seq
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,tot_cnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(syn_cnt)),
      order_catalog_synonym ocs,
      synonym_item_r sir,
      medication_definition md,
      mltm_order_sent mos,
      mltm_order_sent_detail mosd
     PLAN (d
      WHERE size(reply->orders[w].synonyms[d.seq].products,5) > 0)
      JOIN (ocs
      WHERE (ocs.synonym_id=reply->orders[w].synonyms[d.seq].synonym_id))
      JOIN (sir
      WHERE sir.synonym_id=ocs.synonym_id)
      JOIN (md
      WHERE md.item_id=sir.item_id)
      JOIN (mos
      WHERE concat("MUL.FRMLTN!",trim(cnvtstring(mos.main_multum_drug_code)))=md.cki
       AND (mos.usage_flag=request->usage_flag)
       AND trim(mos.external_identifier)="MUL.IP!*")
      JOIN (mosd
      WHERE mosd.external_identifier=mos.external_identifier)
     ORDER BY d.seq, mosd.external_identifier, mosd.sequence
     HEAD d.seq
      cnt = 0, tot_cnt = size(treply2->orders[w].synonyms[d.seq].sentences,5), stat = alterlist(
       treply2->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10))
     HEAD mosd.external_identifier
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10)), cnt = 1
      ENDIF
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].ext_identifier = mos.external_identifier,
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].load_ind = 1, treply2->orders[w].
      synonyms[d.seq].sentences[tot_cnt].source = 1,
      dcnt = 0, dtcnt = 0, stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].
       details,10),
      dose_unit_ind = 0, sd_ind = 0, sdu_ind = 0,
      vd_ind = 0, vdu_ind = 0, ftd_ind = 0
     HEAD mosd.sequence
      dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
      IF (dcnt > 10)
       stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,(dtcnt+ 10)),
       dcnt = 1
      ENDIF
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details[dtcnt].field_disp_value = mosd
      .oe_field_value, treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details[dtcnt].
      field_meaning = mosd.oe_field_meaning
      IF (mosd.oe_field_meaning="STRENGTHDOSE")
       sd_ind = 1
      ELSEIF (mosd.oe_field_meaning="STRENGTHDOSEUNIT")
       sdu_ind = 1
      ELSEIF (mosd.oe_field_meaning="VOLUMEDOSE")
       vd_ind = 1
      ELSEIF (mosd.oe_field_meaning="VOLUMEDOSEUNIT")
       vdu_ind = 1
      ELSEIF (mosd.oe_field_meaning="FREETXTDOSE")
       ftd_ind = 1
      ENDIF
     FOOT  mosd.external_identifier
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,dtcnt)
      IF (((sd_ind=1
       AND sdu_ind != 1) OR (((vd_ind=1
       AND vdu_ind != 1) OR (((sd_ind != 1
       AND sdu_ind=1) OR (((vd_ind != 1
       AND vdu_ind=1) OR (sd_ind=0
       AND sdu_ind=0
       AND vd_ind=0
       AND vdu_ind=0
       AND ftd_ind != 1)) )) )) )) )
       treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].load_ind = 0
      ENDIF
     FOOT  d.seq
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,tot_cnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(syn_cnt)),
      synonym_item_r sir,
      medication_definition md,
      br_ordsent bo,
      br_ordsent_detail bod
     PLAN (d)
      JOIN (sir
      WHERE (sir.synonym_id=reply->orders[w].synonyms[d.seq].synonym_id))
      JOIN (md
      WHERE md.item_id=sir.item_id)
      JOIN (bo
      WHERE bo.mmdc=md.cki)
      JOIN (bod
      WHERE bod.br_ordsent_id=bo.br_ordsent_id)
     ORDER BY d.seq, bod.br_ordsent_id, bod.br_ordsent_detail_id
     HEAD d.seq
      cnt = 0, tot_cnt = size(treply2->orders[w].synonyms[d.seq].sentences,5), stat = alterlist(
       treply2->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10))
     HEAD bod.br_ordsent_id
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10)), cnt = 1
      ENDIF
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].load_ind = 1, treply2->orders[w].
      synonyms[d.seq].sentences[tot_cnt].source = 2, treply2->orders[w].synonyms[d.seq].sentences[
      tot_cnt].os_id = bo.br_ordsent_id,
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].count = bo.ordsent_count, dcnt = 0, dtcnt
       = 0,
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,10),
      dose_unit_ind = 0, sd_ind = 0,
      sdu_ind = 0, vd_ind = 0, vdu_ind = 0,
      ftd_ind = 0
     HEAD bod.br_ordsent_detail_id
      dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
      IF (dcnt > 10)
       stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,(dtcnt+ 10)),
       dcnt = 1
      ENDIF
      treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details[dtcnt].field_disp_value = bod
      .oe_field_value, treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details[dtcnt].
      field_meaning = bod.oe_field_meaning
      IF (bod.oe_field_meaning="STRENGTHDOSE")
       sd_ind = 1
      ELSEIF (bod.oe_field_meaning="STRENGTHDOSEUNIT")
       sdu_ind = 1
      ELSEIF (bod.oe_field_meaning="VOLUMEDOSE")
       vd_ind = 1
      ELSEIF (bod.oe_field_meaning="VOLUMEDOSEUNIT")
       vdu_ind = 1
      ELSEIF (bod.oe_field_meaning="FREETXTDOSE")
       ftd_ind = 1
      ENDIF
     FOOT  bod.br_ordsent_id
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].details,dtcnt)
      IF (((sd_ind=1
       AND sdu_ind != 1) OR (((vd_ind=1
       AND vdu_ind != 1) OR (((sd_ind != 1
       AND sdu_ind=1) OR (((vd_ind != 1
       AND vdu_ind=1) OR (sd_ind=0
       AND sdu_ind=0
       AND vd_ind=0
       AND vdu_ind=0
       AND ftd_ind != 1)) )) )) )) )
       treply2->orders[w].synonyms[d.seq].sentences[tot_cnt].load_ind = 0
      ENDIF
     FOOT  d.seq
      stat = alterlist(treply2->orders[w].synonyms[d.seq].sentences,tot_cnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(syn_cnt)),
      ord_cat_sent_r ocsr,
      filter_entity_reltn f,
      order_sentence os,
      long_text lt
     PLAN (d)
      JOIN (ocsr
      WHERE (ocsr.synonym_id=reply->orders[w].synonyms[d.seq].synonym_id)
       AND ocsr.active_ind=1)
      JOIN (f
      WHERE f.parent_entity_id=ocsr.order_sentence_id
       AND f.parent_entity_name="ORDER_SENTENCE"
       AND (((f.filter_entity1_id=request->facility_code_value)) OR (f.filter_entity1_id=0))
       AND f.filter_entity1_name="LOCATION")
      JOIN (os
      WHERE os.order_sentence_id=f.parent_entity_id
       AND (os.usage_flag=request->usage_flag)
       AND (os.order_encntr_group_cd=request->encntr_grp_code_value))
      JOIN (lt
      WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
     ORDER BY d.seq, os.order_sentence_id
     HEAD d.seq
      cnt = 0, tot_cnt = size(treply->orders[w].synonyms[d.seq].sentences,5), stat = alterlist(treply
       ->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10))
     HEAD os.order_sentence_id
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(treply->orders[w].synonyms[d.seq].sentences,(tot_cnt+ 10)), cnt = 1
      ENDIF
      treply->orders[w].synonyms[d.seq].sentences[tot_cnt].ext_identifier = "", treply->orders[w].
      synonyms[d.seq].sentences[tot_cnt].load_ind = 1, treply->orders[w].synonyms[d.seq].sentences[
      tot_cnt].source = 3,
      treply->orders[w].synonyms[d.seq].sentences[tot_cnt].os_id = os.order_sentence_id, treply->
      orders[w].synonyms[d.seq].sentences[tot_cnt].display = os.order_sentence_display_line, treply->
      orders[w].synonyms[d.seq].sentences[tot_cnt].comment_id = lt.long_text_id,
      treply->orders[w].synonyms[d.seq].sentences[tot_cnt].comment_txt = lt.long_text, treply->
      orders[w].synonyms[d.seq].sentences[tot_cnt].encntr_group_code_value = os.order_encntr_group_cd,
      treply->orders[w].synonyms[d.seq].sentences[tot_cnt].oe_format_id = os.oe_format_id
     FOOT  d.seq
      stat = alterlist(treply->orders[w].synonyms[d.seq].sentences,tot_cnt)
     WITH nocounter
    ;end select
   ENDIF
   FOR (x = 1 TO syn_cnt)
     SET sent_cnt = size(treply2->orders[w].synonyms[x].sentences,5)
     SET rep_sent_cnt = 0
     FOR (y = 1 TO sent_cnt)
      SET det_cnt = size(treply2->orders[w].synonyms[x].sentences[y].details,5)
      IF (det_cnt > 0)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(det_cnt)),
         oe_field_meaning ofm,
         order_entry_fields oef,
         oe_format_fields off
        PLAN (d)
         JOIN (ofm
         WHERE (ofm.oe_field_meaning=treply2->orders[w].synonyms[x].sentences[y].details[d.seq].
         field_meaning))
         JOIN (oef
         WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id)
         JOIN (off
         WHERE off.oe_field_id=oef.oe_field_id
          AND off.action_type_cd=action_code
          AND off.accept_flag IN (0, 1, 3)
          AND (off.oe_format_id=reply->orders[w].synonyms[x].oe_format_id))
        ORDER BY d.seq
        DETAIL
         treply2->orders[w].synonyms[x].sentences[y].details[d.seq].codeset = oef.codeset, treply2->
         orders[w].synonyms[x].sentences[y].details[d.seq].oe_field_id = oef.oe_field_id, treply2->
         orders[w].synonyms[x].sentences[y].details[d.seq].oe_field_label = oef.description,
         treply2->orders[w].synonyms[x].sentences[y].details[d.seq].field_type_flag = oef
         .field_type_flag, treply2->orders[w].synonyms[x].sentences[y].details[d.seq].field_seq = off
         .field_seq, treply2->orders[w].synonyms[x].sentences[y].details[d.seq].group_seq = off
         .group_seq,
         treply2->orders[w].synonyms[x].sentences[y].details[d.seq].label_text = off.label_text,
         treply2->orders[w].synonyms[x].sentences[y].details[d.seq].clin_line_label = off
         .clin_line_label, treply2->orders[w].synonyms[x].sentences[y].details[d.seq].clin_suffix_ind
          = off.clin_suffix_ind,
         treply2->orders[w].synonyms[x].sentences[y].details[d.seq].clin_line_ind = off.clin_line_ind,
         treply2->orders[w].synonyms[x].sentences[y].details[d.seq].disp_yes_no_flag = off
         .disp_yes_no_flag
        WITH nocounter
       ;end select
       FOR (z = 1 TO det_cnt)
         IF ((treply2->orders[w].synonyms[x].sentences[y].details[z].oe_field_id=0)
          AND (treply2->orders[w].synonyms[x].sentences[y].details[z].field_meaning != "SPECINX")
          AND (treply2->orders[w].synonyms[x].sentences[y].details[z].field_meaning != "DRUGFORM"))
          SET treply2->orders[w].synonyms[x].sentences[y].load_ind = 0
          IF ((reply->orders[w].synonyms[x].oe_format_id > 0))
           SET bad_oe_cnt = size(bad_oe->oefs,5)
           SET bad_oe_cnt = (bad_oe_cnt+ 1)
           SET stat = alterlist(bad_oe->oefs,bad_oe_cnt)
           SET bad_oe->oefs[bad_oe_cnt].id = reply->orders[w].synonyms[x].oe_format_id
           SET bad_oe->oefs[bad_oe_cnt].field_mean = treply2->orders[w].synonyms[x].sentences[y].
           details[z].field_meaning
          ENDIF
         ENDIF
       ENDFOR
       IF ((treply2->orders[w].synonyms[x].sentences[y].load_ind=1))
        SET tscnt = (size(treply->orders[w].synonyms[x].sentences,5)+ 1)
        SET stat = alterlist(treply->orders[w].synonyms[x].sentences,tscnt)
        SET treply->orders[w].synonyms[x].sentences[tscnt].load_ind = treply2->orders[w].synonyms[x].
        sentences[y].load_ind
        SET treply->orders[w].synonyms[x].sentences[tscnt].source = treply2->orders[w].synonyms[x].
        sentences[y].source
        SET treply->orders[w].synonyms[x].sentences[tscnt].os_id = treply2->orders[w].synonyms[x].
        sentences[y].os_id
        SET treply->orders[w].synonyms[x].sentences[tscnt].count = treply2->orders[w].synonyms[x].
        sentences[y].count
        SET treply->orders[w].synonyms[x].sentences[tscnt].ext_identifier = treply2->orders[w].
        synonyms[x].sentences[y].ext_identifier
        SET stat = alterlist(treply->orders[w].synonyms[x].sentences[tscnt].details,det_cnt)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = value(det_cnt))
         PLAN (d)
         ORDER BY treply2->orders[w].synonyms[x].sentences[y].details[d.seq].group_seq, treply2->
          orders[w].synonyms[x].sentences[y].details[d.seq].field_seq
         HEAD REPORT
          dtl_cnt = 0
         DETAIL
          IF ((treply2->orders[w].synonyms[x].sentences[y].details[d.seq].oe_field_id=0)
           AND (((treply2->orders[w].synonyms[x].sentences[y].details[d.seq].field_meaning="SPECINX")
          ) OR ((treply2->orders[w].synonyms[x].sentences[y].details[d.seq].field_meaning="DRUGFORM")
          )) )
           stat = alterlist(treply->orders[w].synonyms[x].sentences[tscnt].details,(det_cnt - 1))
          ELSE
           dtl_cnt = (dtl_cnt+ 1), treply->orders[w].synonyms[x].sentences[tscnt].details[dtl_cnt].
           codeset = treply2->orders[w].synonyms[x].sentences[y].details[d.seq].codeset, treply->
           orders[w].synonyms[x].sentences[tscnt].details[dtl_cnt].oe_field_id = treply2->orders[w].
           synonyms[x].sentences[y].details[d.seq].oe_field_id,
           treply->orders[w].synonyms[x].sentences[tscnt].details[dtl_cnt].oe_field_label = treply2->
           orders[w].synonyms[x].sentences[y].details[d.seq].oe_field_label, treply->orders[w].
           synonyms[x].sentences[tscnt].details[dtl_cnt].field_type_flag = treply2->orders[w].
           synonyms[x].sentences[y].details[d.seq].field_type_flag, treply->orders[w].synonyms[x].
           sentences[tscnt].details[dtl_cnt].field_seq = treply2->orders[w].synonyms[x].sentences[y].
           details[d.seq].field_seq,
           treply->orders[w].synonyms[x].sentences[tscnt].details[dtl_cnt].group_seq = treply2->
           orders[w].synonyms[x].sentences[y].details[d.seq].group_seq, treply->orders[w].synonyms[x]
           .sentences[tscnt].details[dtl_cnt].label_text = treply2->orders[w].synonyms[x].sentences[y
           ].details[d.seq].label_text, treply->orders[w].synonyms[x].sentences[tscnt].details[
           dtl_cnt].clin_line_label = treply2->orders[w].synonyms[x].sentences[y].details[d.seq].
           clin_line_label,
           treply->orders[w].synonyms[x].sentences[tscnt].details[dtl_cnt].clin_suffix_ind = treply2
           ->orders[w].synonyms[x].sentences[y].details[d.seq].clin_suffix_ind, treply->orders[w].
           synonyms[x].sentences[tscnt].details[dtl_cnt].clin_line_ind = treply2->orders[w].synonyms[
           x].sentences[y].details[d.seq].clin_line_ind, treply->orders[w].synonyms[x].sentences[
           tscnt].details[dtl_cnt].field_disp_value = treply2->orders[w].synonyms[x].sentences[y].
           details[d.seq].field_disp_value,
           treply->orders[w].synonyms[x].sentences[tscnt].details[dtl_cnt].field_meaning = treply2->
           orders[w].synonyms[x].sentences[y].details[d.seq].field_meaning, treply->orders[w].
           synonyms[x].sentences[tscnt].details[dtl_cnt].disp_yes_no_flag = treply2->orders[w].
           synonyms[x].sentences[y].details[d.seq].disp_yes_no_flag
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
     ENDFOR
     SET sent_cnt = size(treply->orders[w].synonyms[x].sentences,5)
     IF (sent_cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(sent_cnt)),
        order_sentence os,
        order_sentence_detail osd,
        order_entry_fields oef,
        oe_field_meaning oem,
        oe_format_fields off
       PLAN (d
        WHERE (treply->orders[w].synonyms[x].sentences[d.seq].source=3))
        JOIN (os
        WHERE (os.order_sentence_id=treply->orders[w].synonyms[x].sentences[d.seq].os_id))
        JOIN (osd
        WHERE osd.order_sentence_id=os.order_sentence_id)
        JOIN (oef
        WHERE oef.oe_field_id=osd.oe_field_id)
        JOIN (oem
        WHERE oem.oe_field_meaning_id=oef.oe_field_meaning_id)
        JOIN (off
        WHERE off.oe_field_id=outerjoin(oef.oe_field_id)
         AND off.action_type_cd=outerjoin(action_code)
         AND ((off.oe_format_id+ 0)=outerjoin(treply->orders[w].synonyms[x].sentences[d.seq].
         oe_format_id)))
       ORDER BY d.seq, off.group_seq, off.field_seq
       HEAD d.seq
        dcnt = 0, dtcnt = 0, stat = alterlist(treply->orders[w].synonyms[x].sentences[d.seq].details,
         10),
        sd_ind = 0, sdu_ind = 0, vd_ind = 0,
        vdu_ind = 0, ftd_ind = 0
       DETAIL
        dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
        IF (dcnt > 10)
         stat = alterlist(treply->orders[w].synonyms[x].sentences[d.seq].details,(dtcnt+ 10)), dcnt
          = 1
        ENDIF
        treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].codeset = oef.codeset, treply->
        orders[w].synonyms[x].sentences[d.seq].details[dtcnt].oe_field_id = oef.oe_field_id, treply->
        orders[w].synonyms[x].sentences[d.seq].details[dtcnt].field_disp_value = osd
        .oe_field_display_value,
        treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].field_code_value = osd
        .default_parent_entity_id, treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].
        field_meaning = oem.oe_field_meaning, treply->orders[w].synonyms[x].sentences[d.seq].details[
        dtcnt].oe_field_label = oef.description,
        treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].field_type_flag = oef
        .field_type_flag, treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].field_seq =
        off.field_seq, treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].group_seq = off
        .group_seq,
        treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].label_text = off.label_text,
        treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].clin_line_label = off
        .clin_line_label, treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].
        clin_suffix_ind = off.clin_suffix_ind,
        treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].clin_line_ind = off
        .clin_line_ind, treply->orders[w].synonyms[x].sentences[d.seq].details[dtcnt].
        disp_yes_no_flag = off.disp_yes_no_flag
       FOOT  d.seq
        stat = alterlist(treply->orders[w].synonyms[x].sentences[d.seq].details,dtcnt)
       WITH nocounter
      ;end select
     ENDIF
     FOR (y = 1 TO sent_cnt)
       SET det_cnt = size(treply->orders[w].synonyms[x].sentences[y].details,5)
       IF (det_cnt > 0)
        SELECT INTO "nl:"
         FROM (dummyt d1  WITH seq = value(det_cnt)),
          br_med_ordsent_map b,
          code_value_set cvs
         PLAN (d1
          WHERE (treply->orders[w].synonyms[x].sentences[y].details[d1.seq].codeset > 0)
           AND (treply->orders[w].synonyms[x].sentences[y].load_ind=1)
           AND (treply->orders[w].synonyms[x].sentences[y].source IN (1, 2)))
          JOIN (cvs
          WHERE (cvs.code_set=treply->orders[w].synonyms[x].sentences[y].details[d1.seq].codeset))
          JOIN (b
          WHERE b.codeset=outerjoin(cvs.code_set)
           AND b.field_value=outerjoin(cnvtupper(treply->orders[w].synonyms[x].sentences[y].details[
            d1.seq].field_disp_value))
           AND b.parent_entity_name=outerjoin("CODE_VALUE"))
         ORDER BY d1.seq
         HEAD d1.seq
          IF (b.br_med_ordsent_map_id=0)
           treply->orders[w].synonyms[x].sentences[y].load_ind = 0
          ELSE
           treply->orders[w].synonyms[x].sentences[y].details[d1.seq].field_code_value = b
           .parent_entity_id, treply->orders[w].synonyms[x].sentences[y].details[d1.seq].
           field_disp_value = uar_get_code_display(b.parent_entity_id)
          ENDIF
         WITH nocounter
        ;end select
       ENDIF
       IF ((treply->orders[w].synonyms[x].sentences[y].load_ind=1))
        DECLARE order_sentence = vc
        DECLARE order_sentence_full = vc
        DECLARE os_value = vc
        FOR (z = 1 TO det_cnt)
          IF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_type_flag=7))
           IF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value IN ("YES", "1"
           )))
            SET treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value = "Yes"
           ENDIF
           IF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value IN ("NO", "0")
           ))
            SET treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value = "No"
           ENDIF
          ENDIF
          SET os_value = treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value
          IF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_type_flag=7))
           IF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value="Yes"))
            IF ((treply->orders[w].synonyms[x].sentences[y].details[z].disp_yes_no_flag IN (0, 1)))
             SET os_value = treply->orders[w].synonyms[x].sentences[y].details[z].label_text
            ELSE
             SET os_value = ""
            ENDIF
           ELSEIF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_disp_value="No"))
            IF ((treply->orders[w].synonyms[x].sentences[y].details[z].field_meaning="SCH/PRN"))
             SET os_value = ""
            ELSE
             IF ((treply->orders[w].synonyms[x].sentences[y].details[z].disp_yes_no_flag IN (0, 2)))
              SET os_value = treply->orders[w].synonyms[x].sentences[y].details[z].clin_line_label
             ELSE
              SET os_value = ""
             ENDIF
            ENDIF
           ENDIF
          ELSE
           IF ((treply->orders[w].synonyms[x].sentences[y].details[z].clin_line_label > " "))
            IF ((treply->orders[w].synonyms[x].sentences[y].details[z].clin_suffix_ind=1))
             SET os_value = concat(trim(treply->orders[w].synonyms[x].sentences[y].details[z].
               field_disp_value)," ",trim(treply->orders[w].synonyms[x].sentences[y].details[z].
               clin_line_label))
            ELSE
             SET os_value = concat(trim(treply->orders[w].synonyms[x].sentences[y].details[z].
               clin_line_label)," ",trim(treply->orders[w].synonyms[x].sentences[y].details[z].
               field_disp_value))
            ENDIF
           ENDIF
          ENDIF
          IF (z=1)
           SET order_sentence_full = trim(os_value)
           IF ((treply->orders[w].synonyms[x].sentences[y].details[z].clin_line_ind=1))
            SET order_sentence = trim(os_value)
           ENDIF
           SET gseq = treply->orders[w].synonyms[x].sentences[y].details[z].group_seq
          ELSE
           IF (os_value > " ")
            IF ((gseq=treply->orders[w].synonyms[x].sentences[y].details[z].group_seq))
             SET order_sentence_full = concat(trim(order_sentence_full)," ",trim(os_value))
             IF ((treply->orders[w].synonyms[x].sentences[y].details[z].clin_line_ind=1))
              SET order_sentence = concat(trim(order_sentence)," ",trim(os_value))
             ENDIF
            ELSE
             SET order_sentence_full = concat(trim(order_sentence_full),", ",trim(os_value))
             IF ((treply->orders[w].synonyms[x].sentences[y].details[z].clin_line_ind=1))
              SET order_sentence = concat(trim(order_sentence),", ",trim(os_value))
             ENDIF
             SET gseq = treply->orders[w].synonyms[x].sentences[y].details[z].group_seq
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
        IF ((treply->orders[w].synonyms[x].sentences[y].source != 3))
         SET treply->orders[w].synonyms[x].sentences[y].display = trim(order_sentence,3)
         SET treply->orders[w].synonyms[x].sentences[y].full_display = trim(order_sentence_full,3)
        ENDIF
       ENDIF
     ENDFOR
     IF (sent_cnt > 0)
      DECLARE prev_disp = vc
      SET prev_source = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(sent_cnt))
       PLAN (d
        WHERE (treply->orders[w].synonyms[x].sentences[d.seq].load_ind=1))
       ORDER BY treply->orders[w].synonyms[x].sentences[d.seq].full_display, treply->orders[w].
        synonyms[x].sentences[d.seq].source
       HEAD REPORT
        stat = alterlist(reply->orders[w].synonyms[x].sentences,10), rep_sent_cnt = 0, tcnt = 0
       DETAIL
        IF ((((((prev_disp != treply->orders[w].synonyms[x].sentences[d.seq].full_display)) OR ((
        prev_source != treply->orders[w].synonyms[x].sentences[d.seq].source))) ) OR ((treply->
        orders[w].synonyms[x].sentences[d.seq].source=3))) )
         IF ((treply->orders[w].synonyms[x].sentences[d.seq].source IN (1, 2)))
          rep_sent_cnt = (rep_sent_cnt+ 1), tcnt = (tcnt+ 1)
          IF (tcnt > 10)
           stat = alterlist(reply->orders[w].synonyms[x].sentences,(rep_sent_cnt+ 10)), tcnt = 1
          ENDIF
          reply->orders[w].synonyms[x].sentences[rep_sent_cnt].display = treply->orders[w].synonyms[x
          ].sentences[d.seq].display, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
          full_display = treply->orders[w].synonyms[x].sentences[d.seq].full_display, reply->orders[w
          ].synonyms[x].sentences[rep_sent_cnt].ext_identifier = treply->orders[w].synonyms[x].
          sentences[d.seq].ext_identifier,
          reply->orders[w].synonyms[x].sentences[rep_sent_cnt].source_flag = treply->orders[w].
          synonyms[x].sentences[d.seq].source, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
          usage_flag = request->usage_flag, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
          count = treply->orders[w].synonyms[x].sentences[d.seq].count,
          det_cnt = size(treply->orders[w].synonyms[x].sentences[d.seq].details,5), stat = alterlist(
           reply->orders[w].synonyms[x].sentences[rep_sent_cnt].details,det_cnt)
          FOR (d = 1 TO det_cnt)
            reply->orders[w].synonyms[x].sentences[rep_sent_cnt].details[d].field_code_value = treply
            ->orders[w].synonyms[x].sentences[d.seq].details[d].field_code_value, reply->orders[w].
            synonyms[x].sentences[rep_sent_cnt].details[d].field_disp_value = treply->orders[w].
            synonyms[x].sentences[d.seq].details[d].field_disp_value, reply->orders[w].synonyms[x].
            sentences[rep_sent_cnt].details[d].oe_field_id = treply->orders[w].synonyms[x].sentences[
            d.seq].details[d].oe_field_id,
            reply->orders[w].synonyms[x].sentences[rep_sent_cnt].details[d].oe_field_label = treply->
            orders[w].synonyms[x].sentences[d.seq].details[d].oe_field_label
          ENDFOR
         ENDIF
         IF ((treply->orders[w].synonyms[x].sentences[d.seq].source=3))
          rep_sent_cnt = (rep_sent_cnt+ 1), tcnt = (tcnt+ 1)
          IF (tcnt > 10)
           stat = alterlist(reply->orders[w].synonyms[x].sentences,(rep_sent_cnt+ 10)), tcnt = 1
          ENDIF
          reply->orders[w].synonyms[x].sentences[rep_sent_cnt].display = treply->orders[w].synonyms[x
          ].sentences[d.seq].display, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
          full_display = treply->orders[w].synonyms[x].sentences[d.seq].full_display, reply->orders[w
          ].synonyms[x].sentences[rep_sent_cnt].ext_identifier = treply->orders[w].synonyms[x].
          sentences[d.seq].ext_identifier,
          reply->orders[w].synonyms[x].sentences[rep_sent_cnt].source_flag = treply->orders[w].
          synonyms[x].sentences[d.seq].source, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
          usage_flag = request->usage_flag, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
          count = treply->orders[w].synonyms[x].sentences[d.seq].count,
          reply->orders[w].synonyms[x].sentences[rep_sent_cnt].encntr_group_code_value = treply->
          orders[w].synonyms[x].sentences[d.seq].encntr_group_code_value, reply->orders[w].synonyms[x
          ].sentences[rep_sent_cnt].comment_id = treply->orders[w].synonyms[x].sentences[d.seq].
          comment_id, reply->orders[w].synonyms[x].sentences[rep_sent_cnt].comment_txt = treply->
          orders[w].synonyms[x].sentences[d.seq].comment_txt,
          reply->orders[w].synonyms[x].sentences[rep_sent_cnt].sentence_id = treply->orders[w].
          synonyms[x].sentences[d.seq].os_id, det_cnt = size(treply->orders[w].synonyms[x].sentences[
           d.seq].details,5), stat = alterlist(reply->orders[w].synonyms[x].sentences[rep_sent_cnt].
           details,det_cnt)
          FOR (d = 1 TO det_cnt)
            reply->orders[w].synonyms[x].sentences[rep_sent_cnt].details[d].field_code_value = treply
            ->orders[w].synonyms[x].sentences[d.seq].details[d].field_code_value, reply->orders[w].
            synonyms[x].sentences[rep_sent_cnt].details[d].field_disp_value = treply->orders[w].
            synonyms[x].sentences[d.seq].details[d].field_disp_value, reply->orders[w].synonyms[x].
            sentences[rep_sent_cnt].details[d].oe_field_id = treply->orders[w].synonyms[x].sentences[
            d.seq].details[d].oe_field_id,
            reply->orders[w].synonyms[x].sentences[rep_sent_cnt].details[d].oe_field_label = treply->
            orders[w].synonyms[x].sentences[d.seq].details[d].oe_field_label
          ENDFOR
         ENDIF
         prev_disp = treply->orders[w].synonyms[x].sentences[d.seq].full_display, prev_source =
         treply->orders[w].synonyms[x].sentences[d.seq].source
        ENDIF
       FOOT REPORT
        stat = alterlist(reply->orders[w].synonyms[x].sentences,rep_sent_cnt)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 ENDFOR
 SET bad_oe_cnt = size(bad_oe->oefs,5)
 IF (bad_oe_cnt > 0)
  DECLARE prev_mean = vc
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(bad_oe_cnt)),
    order_entry_format o,
    oe_field_meaning m
   PLAN (d)
    JOIN (o
    WHERE (o.oe_format_id=bad_oe->oefs[d.seq].id))
    JOIN (m
    WHERE m.oe_field_meaning=cnvtupper(bad_oe->oefs[d.seq].field_mean))
   ORDER BY o.oe_format_id, cnvtupper(m.oe_field_meaning), m.oe_field_meaning_id
   HEAD REPORT
    ocnt = 0, otcnt = 0, stat = alterlist(reply->invalid_formats,10)
   HEAD o.oe_format_id
    ocnt = (ocnt+ 1), otcnt = (otcnt+ 1)
    IF (ocnt > 10)
     stat = alterlist(reply->invalid_formats,(otcnt+ 10)), ocnt = 1
    ENDIF
    reply->invalid_formats[otcnt].oe_format_id = o.oe_format_id, reply->invalid_formats[otcnt].name
     = o.oe_format_name, mcnt = 0,
    mtcnt = 0, stat = alterlist(reply->invalid_formats[otcnt].fields,10)
   HEAD m.oe_field_meaning_id
    mcnt = (mcnt+ 1), mtcnt = (mtcnt+ 1)
    IF (mcnt > 10)
     stat = alterlist(reply->invalid_formats[otcnt].fields,(mtcnt+ 10)), mcnt = 1
    ENDIF
    reply->invalid_formats[otcnt].fields[mtcnt].description = m.description
   FOOT  o.oe_format_id
    stat = alterlist(reply->invalid_formats[otcnt].fields,mtcnt)
   FOOT REPORT
    stat = alterlist(reply->invalid_formats,otcnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
