CREATE PROGRAM bed_get_vvl_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 hide_flag = i2
       3 oe_format_id = f8
       3 oe_format_name = vc
       3 med_admin_mask = i4
       3 titratable_ind = i2
       3 active_ind = i2
       3 ord_sentence_ind = i2
       3 synonym_type
         4 type_code_value = f8
         4 display = vc
         4 meaning = vc
       3 products[*]
         4 item_id = f8
         4 description = vc
       3 all_fac_ind = i2
       3 virtual_view_ind = i2
       3 order_sets[*]
         4 catalog_cd = f8
         4 description = vc
         4 sentence_ind = i2
       3 power_plans[*]
         4 pplan_id = f8
         4 description = vc
         4 sentence_ind = i2
       3 order_folders[*]
         4 category_id = f8
         4 long_desc = vc
         4 person_id = f8
         4 name_full_formatted = vc
         4 sentence_ind = i2
     2 products[*]
       3 item_id = f8
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
 SET y_code_value = 0.0
 SET y_code_value = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET z_code_value = 0.0
 SET z_code_value = uar_get_code_by("MEANING",6011,"TRADEPROD")
 SET req_cnt = size(request->orders,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE syn_parse = vc
 SET syn_parse = concat(
  "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
  "c_code_value, e_code_value, m_code_value, n_code_value)")
 IF (validate(request->prescription_ind))
  IF ((request->prescription_ind=1))
   SET syn_parse = concat(
    "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, y_code_value, z_code_value,",
    "c_code_value, e_code_value, m_code_value, n_code_value)")
  ENDIF
 ENDIF
 SET stat = alterlist(reply->orders,req_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt))
  PLAN (d)
  ORDER BY d.seq
  DETAIL
   reply->orders[d.seq].catalog_code_value = request->orders[d.seq].catalog_code_value
  WITH nocounter
 ;end select
 SET tot_cnt = 0
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
    AND ((((mfoi.parent_entity_id+ 0) IN (0, request->facility_code_value))) OR ((request->
   ignore_facility_ind=1)))
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
  HEAD md.item_id
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
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_catalog_synonym ocs,
   order_entry_format oef,
   code_value cv
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.catalog_cd=reply->orders[d.seq].catalog_code_value)
    AND parser(syn_parse))
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
    AND oef.action_type_cd=outerjoin(oe_order_code_value))
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd)
  ORDER BY d.seq, ocs.synonym_id
  HEAD d.seq
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->orders[d.seq].synonyms,100)
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->orders[d.seq].synonyms,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->orders[d.seq].synonyms[tot_cnt].synonym_id = ocs.synonym_id, reply->orders[d.seq].synonyms[
   tot_cnt].active_ind = ocs.active_ind, reply->orders[d.seq].synonyms[tot_cnt].hide_flag = ocs
   .hide_flag,
   reply->orders[d.seq].synonyms[tot_cnt].med_admin_mask = ocs.rx_mask, reply->orders[d.seq].
   synonyms[tot_cnt].mnemonic = ocs.mnemonic, reply->orders[d.seq].synonyms[tot_cnt].oe_format_id =
   oef.oe_format_id,
   reply->orders[d.seq].synonyms[tot_cnt].oe_format_name = oef.oe_format_name, reply->orders[d.seq].
   synonyms[tot_cnt].titratable_ind = ocs.ingredient_rate_conversion_ind, reply->orders[d.seq].
   synonyms[tot_cnt].synonym_type.type_code_value = ocs.mnemonic_type_cd,
   reply->orders[d.seq].synonyms[tot_cnt].synonym_type.display = cv.display, reply->orders[d.seq].
   synonyms[tot_cnt].synonym_type.meaning = cv.cdf_meaning
  FOOT  d.seq
   stat = alterlist(reply->orders[d.seq].synonyms,tot_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_cnt)
  SET syn_cnt = size(reply->orders[x].synonyms,5)
  IF (syn_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(syn_cnt)),
     ocs_facility_r ocsf,
     code_value cv
    PLAN (d)
     JOIN (ocsf
     WHERE (ocsf.synonym_id=reply->orders[x].synonyms[d.seq].synonym_id))
     JOIN (cv
     WHERE cv.code_value=outerjoin(ocsf.facility_cd)
      AND cv.code_value > outerjoin(0))
    ORDER BY d.seq
    DETAIL
     IF (ocsf.facility_cd=0)
      reply->orders[x].synonyms[d.seq].all_fac_ind = 1
     ENDIF
     IF ((((ocsf.facility_cd=request->facility_code_value)) OR ((request->facility_code_value=0))) )
      reply->orders[x].synonyms[d.seq].virtual_view_ind = 1
     ELSEIF ((reply->orders[x].synonyms[d.seq].virtual_view_ind=0))
      reply->orders[x].synonyms[d.seq].virtual_view_ind = 2
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(syn_cnt)),
     ord_cat_sent_r ocsr,
     order_sentence os
    PLAN (d)
     JOIN (ocsr
     WHERE (ocsr.synonym_id=reply->orders[x].synonyms[d.seq].synonym_id)
      AND ocsr.active_ind=1)
     JOIN (os
     WHERE os.order_sentence_id=ocsr.order_sentence_id)
    ORDER BY d.seq
    HEAD d.seq
     reply->orders[x].synonyms[d.seq].ord_sentence_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(syn_cnt)),
     cs_component c,
     order_catalog oc,
     order_sentence os
    PLAN (d)
     JOIN (c
     WHERE (c.comp_id=reply->orders[x].synonyms[d.seq].synonym_id))
     JOIN (oc
     WHERE oc.catalog_cd=c.catalog_cd
      AND oc.active_ind=1)
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(c.order_sentence_id))
    ORDER BY d.seq, oc.catalog_cd
    HEAD d.seq
     cnt = 0, tcnt = 0, stat = alterlist(reply->orders[x].synonyms[d.seq].order_sets,10)
    HEAD oc.catalog_cd
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->orders[x].synonyms[d.seq].order_sets,(tcnt+ 10)), cnt = 1
     ENDIF
     reply->orders[x].synonyms[d.seq].order_sets[tcnt].catalog_cd = oc.catalog_cd, reply->orders[x].
     synonyms[d.seq].order_sets[tcnt].description = oc.description
    DETAIL
     IF (os.order_sentence_id > 0)
      reply->orders[x].synonyms[d.seq].order_sets[tcnt].sentence_ind = 1
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->orders[x].synonyms[d.seq].order_sets,tcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(syn_cnt)),
     alt_sel_list l,
     alt_sel_cat c,
     prsnl p,
     order_sentence os
    PLAN (d)
     JOIN (l
     WHERE (l.synonym_id=reply->orders[x].synonyms[d.seq].synonym_id))
     JOIN (c
     WHERE c.alt_sel_category_id=l.alt_sel_category_id
      AND c.adhoc_ind IN (0, null)
      AND c.ahfs_ind IN (0, null))
     JOIN (p
     WHERE p.person_id=outerjoin(c.owner_id))
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(l.order_sentence_id))
    ORDER BY d.seq, c.alt_sel_category_id
    HEAD d.seq
     cnt = 0, tcnt = 0, stat = alterlist(reply->orders[x].synonyms[d.seq].order_folders,10)
    HEAD c.alt_sel_category_id
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->orders[x].synonyms[d.seq].order_folders,(tcnt+ 10)), cnt = 1
     ENDIF
     reply->orders[x].synonyms[d.seq].order_folders[tcnt].long_desc = c.long_description, reply->
     orders[x].synonyms[d.seq].order_folders[tcnt].category_id = c.alt_sel_category_id, reply->
     orders[x].synonyms[d.seq].order_folders[tcnt].person_id = p.person_id,
     reply->orders[x].synonyms[d.seq].order_folders[tcnt].name_full_formatted = p.name_full_formatted
    DETAIL
     IF (os.order_sentence_id > 0)
      reply->orders[x].synonyms[d.seq].order_folders[tcnt].sentence_ind = 1
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->orders[x].synonyms[d.seq].order_folders,tcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(syn_cnt)),
     pathway_comp pcomp,
     pathway_catalog pcat,
     pw_comp_os_reltn pcor,
     order_sentence os
    PLAN (d)
     JOIN (pcomp
     WHERE pcomp.parent_entity_name="ORDER_CATALOG_SYNONYM"
      AND (pcomp.parent_entity_id=reply->orders[x].synonyms[d.seq].synonym_id)
      AND pcomp.active_ind=1)
     JOIN (pcat
     WHERE pcat.pathway_catalog_id=pcomp.pathway_catalog_id
      AND pcat.active_ind=1)
     JOIN (pcor
     WHERE pcor.pathway_comp_id=outerjoin(pcomp.pathway_comp_id))
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(pcor.order_sentence_id))
    ORDER BY d.seq, pcat.pathway_catalog_id
    HEAD d.seq
     cnt = 0, tcnt = 0, stat = alterlist(reply->orders[x].synonyms[d.seq].power_plans,10)
    HEAD pcat.pathway_catalog_id
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->orders[x].synonyms[d.seq].power_plans,(tcnt+ 10)), cnt = 1
     ENDIF
     reply->orders[x].synonyms[d.seq].power_plans[tcnt].pplan_id = pcat.pathway_catalog_id, reply->
     orders[x].synonyms[d.seq].power_plans[tcnt].description = pcat.description
    DETAIL
     IF (os.order_sentence_id > 0)
      reply->orders[x].synonyms[d.seq].power_plans[tcnt].sentence_ind = 1
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->orders[x].synonyms[d.seq].power_plans,tcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(syn_cnt)),
     synonym_item_r s,
     med_identifier mi
    PLAN (d)
     JOIN (s
     WHERE (s.synonym_id=reply->orders[x].synonyms[d.seq].synonym_id))
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
     cnt = 0, tot_cnt = 0, stat = alterlist(reply->orders[x].synonyms[d.seq].products,10)
    DETAIL
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->orders[x].synonyms[d.seq].products,(tot_cnt+ 10)), cnt = 1
     ENDIF
     reply->orders[x].synonyms[d.seq].products[tot_cnt].item_id = s.item_id, reply->orders[x].
     synonyms[d.seq].products[tot_cnt].description = mi.value
    FOOT  d.seq
     stat = alterlist(reply->orders[x].synonyms[d.seq].products,tot_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
