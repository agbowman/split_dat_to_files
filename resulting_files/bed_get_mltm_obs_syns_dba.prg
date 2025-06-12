CREATE PROGRAM bed_get_mltm_obs_syns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 primary_synonyms[*]
      2 synonym_id = f8
      2 catalog_cd = f8
      2 synonym_mnemonic = vc
      2 can_obsolete_ind = i2
      2 ignore_ind = i2
      2 mmdc = i4
      2 ndc_type = i2
      2 brand_name = vc
      2 synonym_type
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 synonyms[*]
        3 synonym_id = f8
        3 mnemonic = vc
        3 can_obsolete_ind = i2
        3 ignore_ind = i2
        3 mmdc = i4
        3 ndc_type = i2
        3 brand_name = vc
        3 synonym_type
          4 code_value = f8
          4 display = vc
          4 meaning = vc
        3 order_entry_format
          4 oe_format_id = f8
          4 name = vc
      2 order_entry_format
        3 oe_format_id = f8
        3 name = vc
    1 has_more_primaries = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  ) WITH protect
 ENDIF
 FREE RECORD temp_obs
 RECORD temp_obs(
   1 primary_synonyms[*]
     2 drug_synonym_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 synonym_mnemonic = vc
     2 can_obsolete_ind = i2
     2 ignore_ind = i2
     2 mmdc = i4
     2 ndc_type = i2
     2 brand_name = vc
     2 attached_to_mmdc = i2
     2 attached_to_millennium = i2
     2 synonyms[*]
       3 drug_synonym_id = f8
       3 synonym_id = f8
       3 mnemonic = vc
       3 ignore_ind = i2
       3 mmdc = i4
       3 ndc_type = i2
       3 brand_name = vc
       3 can_obsolete_ind = i2
       3 attached_to_mmdc = i2
       3 attached_to_millennium = i2
 )
 DECLARE only_return_obs_syn_ind = i2 WITH protect, constant(request->return_attached_to_millennium)
 DECLARE cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE synonym_table_name = vc WITH protect, constant("ORDER_CATALOG_SYNONYM")
 DECLARE cs6030orderable = f8 WITH protect, constant(uar_get_code_by("MEANING",6030,"ORDERABLE"))
 DECLARE total_item_count = i4 WITH protect, noconstant(0)
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = vc
 DECLARE getsynonymstoobsolete(dummyvar=i2) = null
 DECLARE checkmmdcs(dummyvar=i2) = null
 DECLARE populatereplyfromtemprec(dummyvar=i2) = null
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 CALL getsynonymstoobsolete(0)
 IF (size(temp_obs->primary_synonyms,5) > 0)
  CALL checkmmdcs(0)
  IF ((request->max_reply > 0)
   AND (request->paging_ind=0)
   AND (total_item_count > request->max_reply))
   SET stat = alterlist(reply->primary_synonyms,0)
   SET reply->too_many_results_ind = 1
   GO TO exit_script
  ENDIF
  CALL populatereplyfromtemprec(0)
 ENDIF
#populate_type_and_oef
 DECLARE reply_size = i4 WITH protect, constant(size(reply->primary_synonyms,5))
 IF (reply_size > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = reply_size),
    order_catalog_synonym ocs,
    code_value cv,
    order_entry_format oef
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=reply->primary_synonyms[d.seq].synonym_id))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd)
    JOIN (oef
    WHERE oef.oe_format_id=ocs.oe_format_id
     AND oef.action_type_cd=cs6003_order_cd)
   ORDER BY d.seq
   DETAIL
    reply->primary_synonyms[d.seq].synonym_type.code_value = cv.code_value, reply->primary_synonyms[d
    .seq].synonym_type.display = cv.display, reply->primary_synonyms[d.seq].synonym_type.meaning = cv
    .cdf_meaning,
    reply->primary_synonyms[d.seq].order_entry_format.oe_format_id = oef.oe_format_id, reply->
    primary_synonyms[d.seq].order_entry_format.name = oef.oe_format_name
   WITH nocounter
  ;end select
  CALL bederrorcheck("GETPRIMTYPEOEFERROR: Error getting primary synonym types or oefs.")
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = reply_size),
    (dummyt d2  WITH seq = 0),
    order_catalog_synonym ocs,
    code_value cv,
    order_entry_format oef
   PLAN (d1
    WHERE maxrec(d2,size(reply->primary_synonyms[d1.seq].synonyms,5)))
    JOIN (d2)
    JOIN (ocs
    WHERE (ocs.synonym_id=reply->primary_synonyms[d1.seq].synonyms[d2.seq].synonym_id))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd)
    JOIN (oef
    WHERE oef.oe_format_id=ocs.oe_format_id
     AND oef.action_type_cd=cs6003_order_cd)
   ORDER BY d1.seq, d2.seq
   DETAIL
    reply->primary_synonyms[d1.seq].synonyms[d2.seq].synonym_type.code_value = cv.code_value, reply->
    primary_synonyms[d1.seq].synonyms[d2.seq].synonym_type.display = cv.display, reply->
    primary_synonyms[d1.seq].synonyms[d2.seq].synonym_type.meaning = cv.cdf_meaning,
    reply->primary_synonyms[d1.seq].synonyms[d2.seq].order_entry_format.oe_format_id = oef
    .oe_format_id, reply->primary_synonyms[d1.seq].synonyms[d2.seq].order_entry_format.name = oef
    .oe_format_name
   WITH nocounter
  ;end select
  CALL bederrorcheck("GETTYPEOEFERROR: Error getting synonym types or oefs.")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE getsynonymstoobsolete(dummyvar)
   DECLARE prim_cnt = i4 WITH protect, noconstant(0)
   DECLARE syn_cnt = i4 WITH protect, noconstant(0)
   DECLARE cs6011_primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
   DECLARE qual_parse_string = vc WITH protect, constant(populateparsestringbasedonrequest(0))
   DECLARE prim_parse_string = vc WITH protect, noconstant(" ocs2.catalog_cd = cv.code_value ")
   IF ((request->last_primary_mnemonic > " "))
    SET prim_parse_string = concat(prim_parse_string," and cnvtupper(ocs2.mnemonic) > '",cnvtupper(
      trim(request->last_primary_mnemonic)),"' ")
   ENDIF
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs1,
     mltm_drug_name mltm,
     order_catalog oc,
     code_value cv,
     order_catalog_synonym ocs2,
     br_name_value bv
    PLAN (ocs1
     WHERE parser(qual_parse_string))
     JOIN (mltm
     WHERE concat("MUL.ORD-SYN!",cnvtstring(mltm.drug_synonym_id))=ocs1.cki
      AND mltm.is_obsolete="T")
     JOIN (oc
     WHERE oc.catalog_cd=ocs1.catalog_cd)
     JOIN (cv
     WHERE cv.code_value=oc.catalog_cd)
     JOIN (ocs2
     WHERE ocs2.mnemonic_type_cd=cs6011_primary_cd
      AND parser(prim_parse_string))
     JOIN (bv
     WHERE bv.br_nv_key1=outerjoin("OBSOLETESYN_IGN")
      AND bv.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
      AND bv.br_value=outerjoin(cnvtstring(ocs1.synonym_id)))
    ORDER BY cnvtupper(ocs2.mnemonic), ocs2.catalog_cd, cnvtupper(ocs1.mnemonic)
    HEAD REPORT
     stat = alterlist(temp_obs->primary_synonyms,10)
    HEAD ocs2.catalog_cd
     prim_cnt = (prim_cnt+ 1)
     IF (mod(prim_cnt,10)=0)
      stat = alterlist(temp_obs->primary_synonyms,(prim_cnt+ 10))
     ENDIF
     temp_obs->primary_synonyms[prim_cnt].synonym_id = ocs2.synonym_id, temp_obs->primary_synonyms[
     prim_cnt].catalog_cd = ocs2.catalog_cd, temp_obs->primary_synonyms[prim_cnt].synonym_mnemonic =
     ocs2.mnemonic,
     stat = alterlist(temp_obs->primary_synonyms[prim_cnt].synonyms,10)
    HEAD ocs1.mnemonic
     IF ((((temp_obs->primary_synonyms[prim_cnt].can_obsolete_ind=0)) OR (only_return_obs_syn_ind=1
     )) )
      syn_cnt = (syn_cnt+ 1)
      IF (mod(syn_cnt,10)=0)
       stat = alterlist(temp_obs->primary_synonyms[prim_cnt].synonyms,(syn_cnt+ 10))
      ENDIF
      IF (ocs1.synonym_id=ocs2.synonym_id)
       IF ((((request->return_ignored_ind=1)) OR (bv.br_name_value_id=0.0)) )
        total_item_count = (total_item_count+ 1), temp_obs->primary_synonyms[prim_cnt].
        can_obsolete_ind = 1
        IF (only_return_obs_syn_ind=0)
         stat = alterlist(temp_obs->primary_synonyms[prim_cnt].synonyms,0)
        ENDIF
        syn_cnt = 0
       ENDIF
       IF (bv.br_name_value_id > 0.0)
        temp_obs->primary_synonyms[prim_cnt].ignore_ind = 1
       ENDIF
       temp_obs->primary_synonyms[prim_cnt].drug_synonym_id = mltm.drug_synonym_id
      ELSEIF ((((request->return_ignored_ind=1)) OR (bv.br_name_value_id=0.0)) )
       total_item_count = (total_item_count+ 1), temp_obs->primary_synonyms[prim_cnt].synonyms[
       syn_cnt].drug_synonym_id = mltm.drug_synonym_id, temp_obs->primary_synonyms[prim_cnt].
       synonyms[syn_cnt].synonym_id = ocs1.synonym_id,
       temp_obs->primary_synonyms[prim_cnt].synonyms[syn_cnt].mnemonic = ocs1.mnemonic, temp_obs->
       primary_synonyms[prim_cnt].synonyms[syn_cnt].can_obsolete_ind = 1
       IF (bv.br_name_value_id > 0.0)
        temp_obs->primary_synonyms[prim_cnt].synonyms[syn_cnt].ignore_ind = 1
       ENDIF
      ENDIF
     ENDIF
    FOOT  ocs2.catalog_cd
     stat = alterlist(temp_obs->primary_synonyms[prim_cnt].synonyms,syn_cnt), syn_cnt = 0
    FOOT REPORT
     stat = alterlist(temp_obs->primary_synonyms,prim_cnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("SELMLTMOCSERROR: Error getting multum synonyms to obsolete.")
   IF (only_return_obs_syn_ind=0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(prim_cnt)),
      order_catalog_synonym ocs1,
      mltm_drug_name m,
      br_name_value bv
     PLAN (d
      WHERE (temp_obs->primary_synonyms[d.seq].can_obsolete_ind=1))
      JOIN (ocs1
      WHERE (ocs1.catalog_cd=temp_obs->primary_synonyms[d.seq].catalog_cd)
       AND ocs1.mnemonic_type_cd != cs6011_primary_cd
       AND ocs1.active_ind=1)
      JOIN (m
      WHERE concat("MUL.ORD-SYN!",cnvtstring(m.drug_synonym_id))=outerjoin(ocs1.cki))
      JOIN (bv
      WHERE bv.br_nv_key1=outerjoin("OBSOLETESYN_IGN")
       AND bv.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
       AND bv.br_value=outerjoin(cnvtstring(ocs1.synonym_id)))
     ORDER BY d.seq, cnvtupper(ocs1.mnemonic)
     HEAD d.seq
      syn_cnt = 0, stat = alterlist(temp_obs->primary_synonyms[d.seq].synonyms,10)
     DETAIL
      IF (mod(syn_cnt,10)=0)
       stat = alterlist(temp_obs->primary_synonyms[d.seq].synonyms,(syn_cnt+ 10))
      ENDIF
      syn_cnt = (syn_cnt+ 1), temp_obs->primary_synonyms[d.seq].synonyms[syn_cnt].synonym_id = ocs1
      .synonym_id, temp_obs->primary_synonyms[d.seq].synonyms[syn_cnt].mnemonic = ocs1.mnemonic
      IF (bv.br_name_value_id > 0.0)
       temp_obs->primary_synonyms[d.seq].synonyms[syn_cnt].ignore_ind = 1
      ENDIF
      IF ((((temp_obs->primary_synonyms[d.seq].synonyms[syn_cnt].ignore_ind=0)) OR ((request->
      return_ignored_ind=1)))
       AND m.is_obsolete="T"
       AND parser(qual_parse_string))
       temp_obs->primary_synonyms[d.seq].synonyms[syn_cnt].drug_synonym_id = m.drug_synonym_id,
       temp_obs->primary_synonyms[d.seq].synonyms[syn_cnt].can_obsolete_ind = 1, total_item_count = (
       total_item_count+ 1)
      ENDIF
     FOOT  d.seq
      stat = alterlist(temp_obs->primary_synonyms[d.seq].synonyms,syn_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("SELMLTMOCSERROR2: Error getting multum synonyms to obsolete.")
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prim_cnt),
     (dummyt d2  WITH seq = 1),
     alt_sel_list asl,
     alt_sel_cat ascat
    PLAN (d1
     WHERE maxrec(d2,size(temp_obs->primary_synonyms[d1.seq].synonyms,5)))
     JOIN (d2
     WHERE (temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind=1))
     JOIN (asl
     WHERE (asl.synonym_id=temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].synonym_id))
     JOIN (ascat
     WHERE ascat.alt_sel_category_id=asl.alt_sel_category_id
      AND ascat.ahfs_ind IN (0, null))
    DETAIL
     temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].attached_to_millennium = 1
     IF (asl.list_type=2
      AND (request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind = 0, total_item_count = (
      total_item_count - 1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = prim_cnt),
     alt_sel_list asl,
     alt_sel_cat ascat
    PLAN (d
     WHERE (temp_obs->primary_synonyms[d.seq].can_obsolete_ind=1))
     JOIN (asl
     WHERE (asl.synonym_id=temp_obs->primary_synonyms[d.seq].synonym_id))
     JOIN (ascat
     WHERE ascat.alt_sel_category_id=asl.alt_sel_category_id
      AND ascat.ahfs_ind IN (0, null))
    DETAIL
     temp_obs->primary_synonyms[d.seq].attached_to_millennium = 1
     IF (asl.list_type=2
      AND (request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d.seq].can_obsolete_ind = 0, total_item_count = (total_item_count -
      1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prim_cnt),
     (dummyt d2  WITH seq = 1),
     cs_component cc
    PLAN (d1
     WHERE maxrec(d2,size(temp_obs->primary_synonyms[d1.seq].synonyms,5)))
     JOIN (d2
     WHERE (temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind=1))
     JOIN (cc
     WHERE (cc.comp_id=temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].synonym_id)
      AND cc.comp_type_cd=cs6030orderable)
    DETAIL
     temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].attached_to_millennium = 1
     IF ((request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind = 0, total_item_count = (
      total_item_count - 1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = prim_cnt),
     cs_component cc
    PLAN (d
     WHERE (temp_obs->primary_synonyms[d.seq].can_obsolete_ind=1))
     JOIN (cc
     WHERE (cc.comp_id=temp_obs->primary_synonyms[d.seq].synonym_id)
      AND cc.comp_type_cd=cs6030orderable)
    DETAIL
     temp_obs->primary_synonyms[d.seq].attached_to_millennium = 1
     IF ((request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d.seq].can_obsolete_ind = 0, total_item_count = (total_item_count -
      1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prim_cnt),
     (dummyt d2  WITH seq = 1),
     pathway_comp pw
    PLAN (d1
     WHERE maxrec(d2,size(temp_obs->primary_synonyms[d1.seq].synonyms,5)))
     JOIN (d2
     WHERE (temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind=1))
     JOIN (pw
     WHERE (pw.parent_entity_id=temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].synonym_id)
      AND pw.parent_entity_name=synonym_table_name)
    DETAIL
     temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].attached_to_millennium = 1
     IF ((request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind = 0, total_item_count = (
      total_item_count - 1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = prim_cnt),
     pathway_comp pw
    PLAN (d
     WHERE (temp_obs->primary_synonyms[d.seq].can_obsolete_ind=1))
     JOIN (pw
     WHERE (pw.parent_entity_id=temp_obs->primary_synonyms[d.seq].synonym_id)
      AND pw.parent_entity_name=synonym_table_name)
    DETAIL
     temp_obs->primary_synonyms[d.seq].attached_to_millennium = 1
     IF ((request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d.seq].can_obsolete_ind = 0, total_item_count = (total_item_count -
      1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prim_cnt),
     (dummyt d2  WITH seq = 1),
     order_catalog_item_r ocir
    PLAN (d1
     WHERE maxrec(d2,size(temp_obs->primary_synonyms[d1.seq].synonyms,5)))
     JOIN (d2
     WHERE (temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind=1))
     JOIN (ocir
     WHERE (ocir.synonym_id=temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].synonym_id))
    DETAIL
     temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].attached_to_millennium = 1
     IF ((request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind = 0, total_item_count = (
      total_item_count - 1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = prim_cnt),
     order_catalog_item_r ocir
    PLAN (d
     WHERE (temp_obs->primary_synonyms[d.seq].can_obsolete_ind=1))
     JOIN (ocir
     WHERE (ocir.synonym_id=temp_obs->primary_synonyms[d.seq].synonym_id))
    DETAIL
     temp_obs->primary_synonyms[d.seq].attached_to_millennium = 1
     IF ((request->return_attached_to_millennium=0))
      temp_obs->primary_synonyms[d.seq].can_obsolete_ind = 0, total_item_count = (total_item_count -
      1)
     ENDIF
    WITH nocounter
   ;end select
   IF ((request->return_attached_to_millennium=1))
    FOR (x = 1 TO size(temp_obs->primary_synonyms,5))
     IF ((temp_obs->primary_synonyms[x].attached_to_millennium=0))
      SET temp_obs->primary_synonyms[x].can_obsolete_ind = 0
      SET total_item_count = (total_item_count - 1)
     ENDIF
     FOR (y = 1 TO size(temp_obs->primary_synonyms[x].synonyms,5))
       IF ((temp_obs->primary_synonyms[x].synonyms[y].attached_to_millennium=0))
        SET temp_obs->primary_synonyms[x].synonyms[y].can_obsolete_ind = 0
        SET total_item_count = (total_item_count - 1)
       ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
   DECLARE string_to_parse = vc WITH protect, noconstant(
    " ocs1.cki = 'MUL.ORD-SYN!*' and ocs1.active_ind = 1 ")
   IF ((request->starts_with_contains_type IN ("S", "s"))
    AND (request->mnemonic_search_string > " "))
    SET string_to_parse = concat(string_to_parse," and cnvtupper(ocs1.mnemonic) = '",cnvtupper(trim(
       request->mnemonic_search_string)),"*'")
   ELSEIF ((request->starts_with_contains_type IN ("C", "c"))
    AND (request->mnemonic_search_string > " "))
    SET string_to_parse = concat(string_to_parse," and cnvtupper(ocs1.mnemonic) = '*",cnvtupper(trim(
       request->mnemonic_search_string)),"*'")
   ENDIF
   DECLARE syn_type_size = i4 WITH protect, noconstant(size(request->synonym_types,5))
   IF (syn_type_size > 0)
    SET string_to_parse = concat(string_to_parse," and ocs1.mnemonic_type_cd in ( ")
   ENDIF
   FOR (x = 1 TO syn_type_size)
    SET string_to_parse = build(string_to_parse,request->synonym_types[x].code_value)
    IF (x < syn_type_size)
     SET string_to_parse = concat(string_to_parse,", ")
    ENDIF
   ENDFOR
   IF (syn_type_size > 0)
    SET string_to_parse = concat(string_to_parse," ) ")
   ENDIF
   CALL echo(string_to_parse)
   RETURN(string_to_parse)
 END ;Subroutine
 SUBROUTINE checkmmdcs(dummyvar)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(temp_obs->primary_synonyms,5)),
     mltm_drug_name_map md,
     mltm_mmdc_name_map mm,
     mltm_ndc_core_description mn,
     mltm_ndc_brand_name mbn
    PLAN (d)
     JOIN (md
     WHERE (md.drug_synonym_id=temp_obs->primary_synonyms[d.seq].drug_synonym_id))
     JOIN (mm
     WHERE mm.drug_synonym_id=md.drug_synonym_id)
     JOIN (mn
     WHERE mn.main_multum_drug_code=outerjoin(mm.main_multum_drug_code))
     JOIN (mbn
     WHERE mbn.brand_code=outerjoin(mn.brand_code))
    ORDER BY d.seq
    DETAIL
     IF (mm.main_multum_drug_code != null)
      temp_obs->primary_synonyms[d.seq].attached_to_mmdc = 1, temp_obs->primary_synonyms[d.seq].mmdc
       = mm.main_multum_drug_code, temp_obs->primary_synonyms[d.seq].brand_name = mbn
      .brand_description
      IF (md.function_id IN (17, 29))
       temp_obs->primary_synonyms[d.seq].ndc_type = 1
      ELSEIF (md.function_id > 0)
       temp_obs->primary_synonyms[d.seq].ndc_type = 2
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("SELMMDCERROR1: Error getting mmdc links.")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(temp_obs->primary_synonyms,5)),
     (dummyt d2  WITH seq = 1),
     mltm_drug_name_map md,
     mltm_mmdc_name_map mm,
     mltm_ndc_core_description mn,
     mltm_ndc_brand_name mbn
    PLAN (d1
     WHERE maxrec(d2,size(temp_obs->primary_synonyms[d1.seq].synonyms,5)))
     JOIN (d2
     WHERE (temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].can_obsolete_ind=1))
     JOIN (md
     WHERE (md.drug_synonym_id=temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].drug_synonym_id))
     JOIN (mm
     WHERE mm.drug_synonym_id=md.drug_synonym_id)
     JOIN (mn
     WHERE mn.main_multum_drug_code=outerjoin(mm.main_multum_drug_code))
     JOIN (mbn
     WHERE mbn.brand_code=outerjoin(mn.brand_code))
    ORDER BY d1.seq
    DETAIL
     IF (mm.main_multum_drug_code != null)
      temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].attached_to_mmdc = 1, temp_obs->
      primary_synonyms[d1.seq].synonyms[d2.seq].mmdc = mm.main_multum_drug_code, temp_obs->
      primary_synonyms[d1.seq].synonyms[d2.seq].brand_name = mbn.brand_description
      IF (md.function_id IN (17, 29))
       temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].ndc_type = 1
      ELSEIF (md.function_id > 0)
       temp_obs->primary_synonyms[d1.seq].synonyms[d2.seq].ndc_type = 2
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("SELMMDCERROR2: Error getting mmdc links.")
   IF ((request->return_mmdc_flag < 2))
    FOR (x = 1 TO size(temp_obs->primary_synonyms,5))
     IF ((request->return_mmdc_flag != temp_obs->primary_synonyms[x].attached_to_mmdc))
      SET temp_obs->primary_synonyms[x].can_obsolete_ind = 0
      SET total_item_count = (total_item_count - 1)
     ENDIF
     FOR (y = 1 TO size(temp_obs->primary_synonyms[x].synonyms,5))
       IF ((request->return_mmdc_flag != temp_obs->primary_synonyms[x].synonyms[y].attached_to_mmdc))
        SET temp_obs->primary_synonyms[x].synonyms[y].can_obsolete_ind = 0
        SET total_item_count = (total_item_count - 1)
       ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereplyfromtemprec(dummyvar)
   DECLARE prim_cnt = i4 WITH protect, noconstant(0)
   DECLARE syn_cnt = i4 WITH protect, noconstant(0)
   DECLARE total_syn_cnt = i4 WITH protect, noconstant(0)
   DECLARE prim_qualify_ind = i2 WITH protect, noconstant(0)
   DECLARE syn_qualify_ind = i2 WITH protect, noconstant(0)
   SET stat = alterlist(reply->primary_synonyms,10)
   FOR (x = 1 TO size(temp_obs->primary_synonyms,5))
     SET syn_cnt = 0
     SET stat = alterlist(reply->primary_synonyms,(prim_cnt+ 1))
     SET prim_cnt = (prim_cnt+ 1)
     IF ((temp_obs->primary_synonyms[x].can_obsolete_ind=1))
      SET prim_qualify_ind = 1
     ELSE
      SET prim_qualify_ind = 0
     ENDIF
     SET stat = alterlist(reply->primary_synonyms[prim_cnt].synonyms,10)
     FOR (y = 1 TO size(temp_obs->primary_synonyms[x].synonyms,5))
      IF (((prim_qualify_ind=1) OR ((temp_obs->primary_synonyms[x].synonyms[y].can_obsolete_ind=1)))
      )
       SET syn_qualify_ind = 1
       SET total_syn_cnt = (total_syn_cnt+ 1)
      ELSE
       SET syn_qualify_ind = 0
      ENDIF
      IF (syn_qualify_ind=1)
       SET stat = alterlist(reply->primary_synonyms[prim_cnt].synonyms,(syn_cnt+ 1))
       SET syn_cnt = (syn_cnt+ 1)
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].synonym_id = temp_obs->
       primary_synonyms[x].synonyms[y].synonym_id
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].mnemonic = temp_obs->primary_synonyms[
       x].synonyms[y].mnemonic
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].ignore_ind = temp_obs->
       primary_synonyms[x].synonyms[y].ignore_ind
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].can_obsolete_ind = temp_obs->
       primary_synonyms[x].synonyms[y].can_obsolete_ind
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].mmdc = temp_obs->primary_synonyms[x].
       synonyms[y].mmdc
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].ndc_type = temp_obs->primary_synonyms[
       x].synonyms[y].ndc_type
       SET reply->primary_synonyms[prim_cnt].synonyms[syn_cnt].brand_name = temp_obs->
       primary_synonyms[x].synonyms[y].brand_name
      ENDIF
     ENDFOR
     SET stat = alterlist(reply->primary_synonyms[prim_cnt].synonyms,syn_cnt)
     IF (((syn_cnt > 0) OR (prim_qualify_ind=1)) )
      SET total_syn_cnt = (total_syn_cnt+ syn_cnt)
      SET reply->primary_synonyms[prim_cnt].synonym_id = temp_obs->primary_synonyms[x].synonym_id
      SET reply->primary_synonyms[prim_cnt].catalog_cd = temp_obs->primary_synonyms[x].catalog_cd
      SET reply->primary_synonyms[prim_cnt].synonym_mnemonic = temp_obs->primary_synonyms[x].
      synonym_mnemonic
      SET reply->primary_synonyms[prim_cnt].can_obsolete_ind = prim_qualify_ind
      SET reply->primary_synonyms[prim_cnt].ignore_ind = temp_obs->primary_synonyms[x].ignore_ind
      SET reply->primary_synonyms[prim_cnt].mmdc = temp_obs->primary_synonyms[x].mmdc
      SET reply->primary_synonyms[prim_cnt].ndc_type = temp_obs->primary_synonyms[x].ndc_type
      SET reply->primary_synonyms[prim_cnt].brand_name = temp_obs->primary_synonyms[x].brand_name
      IF ((request->max_reply > 0)
       AND (total_syn_cnt > request->max_reply))
       SET stat = alterlist(reply->primary_synonyms,(prim_cnt - 1))
       SET reply->has_more_primaries = 1
       IF ((request->paging_ind=0))
        SET stat = alterlist(reply->primary_synonyms,0)
        SET reply->too_many_results_ind = 1
        GO TO exit_script
       ENDIF
       GO TO populate_type_and_oef
      ENDIF
     ELSE
      SET prim_cnt = (prim_cnt - 1)
      SET stat = alterlist(reply->primary_synonyms,prim_cnt)
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
