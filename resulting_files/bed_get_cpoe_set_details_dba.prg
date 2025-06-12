CREATE PROGRAM bed_get_cpoe_set_details:dba
 FREE SET reply
 RECORD reply(
   1 sets[*]
     2 catalog_code_value = f8
     2 description = vc
     2 primary_mnemonic = vc
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 oe_format_id = f8
       3 mnemonic_type
         4 code_value = f8
         4 meaning = vc
         4 display = vc
       3 active_ind = i2
       3 facilities[*]
         4 code_value = f8
         4 display = vc
     2 ingredients[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 oe_format_id = f8
       3 order_sentence
         4 order_sentence_id = f8
         4 display = vc
         4 commment_id = f8
         4 comment_txt = vc
         4 details[*]
           5 oe_field_id = f8
           5 oe_field_label = vc
           5 field_disp_value = vc
           5 field_code_value = f8
           5 field_value = f8
           5 field_type_flag = i2
           5 field_seq = i4
         4 oe_format_id = f8
         4 filters
           5 order_sentence_filter_id = f8
           5 age_min_value = f8
           5 age_max_value = f8
           5 age_unit_cd
             6 code_value = f8
             6 display = vc
             6 mean = vc
             6 description = vc
           5 pma_min_value = f8
           5 pma_max_value = f8
           5 pma_unit_cd
             6 code_value = f8
             6 display = vc
             6 mean = vc
             6 description = vc
           5 weight_min_value = f8
           5 weight_max_value = f8
           5 weight_unit_cd
             6 code_value = f8
             6 display = vc
             6 mean = vc
             6 description = vc
       3 rx_mask = i4
       3 sequence = i4
       3 catalog_code_value = f8
       3 lock_details_flag = i2
       3 auto_verification_optional_ind = i2
     2 intermittent_ind = i2
     2 modifiable_flag = i2
     2 orderable_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = size(request->sets,5)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET cs_ord_cd = 0.0
 SET cs_ord_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET stat = alterlist(reply->sets,scnt)
 FOR (s = 1 TO scnt)
   SET reply->sets[s].catalog_code_value = request->sets[s].catalog_code_value
 ENDFOR
 SET field_found = 0
 SET search_intermittent = 0
 RANGE OF o IS order_catalog_synonym
 SET field_found = validate(o.intermittent_ind)
 FREE RANGE o
 IF (field_found=1)
  SET search_intermittent = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr,
   code_value cv1,
   code_value cv2
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=reply->sets[d.seq].catalog_code_value))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd)
   JOIN (cv1
   WHERE cv1.code_value=ocs.mnemonic_type_cd
    AND cv1.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(ofr.facility_cd))
  ORDER BY d.seq, ocs.synonym_id, cv2.code_value
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->sets[d.seq].synonyms,100),
   reply->sets[d.seq].description = oc.description, reply->sets[d.seq].primary_mnemonic = oc
   .primary_mnemonic, reply->sets[d.seq].modifiable_flag = oc.modifiable_flag,
   reply->sets[d.seq].orderable_type_flag = oc.orderable_type_flag
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->sets[d.seq].synonyms,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->sets[d.seq].synonyms[tcnt].synonym_id = ocs.synonym_id, reply->sets[d.seq].synonyms[tcnt].
   mnemonic = ocs.mnemonic, reply->sets[d.seq].synonyms[tcnt].oe_format_id = ocs.oe_format_id,
   reply->sets[d.seq].synonyms[tcnt].active_ind = ocs.active_ind, reply->sets[d.seq].synonyms[tcnt].
   mnemonic_type.code_value = cv1.code_value, reply->sets[d.seq].synonyms[tcnt].mnemonic_type.display
    = cv1.display,
   reply->sets[d.seq].synonyms[tcnt].mnemonic_type.meaning = cv1.cdf_meaning, fcnt = 0, ftcnt = 0,
   stat = alterlist(reply->sets[d.seq].synonyms[tcnt].facilities,100)
  HEAD cv2.code_value
   IF (ofr.synonym_id > 0)
    fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
    IF (fcnt > 100)
     stat = alterlist(reply->sets[d.seq].synonyms[tcnt].facilities,(ftcnt+ 100)), fcnt = 1
    ENDIF
    reply->sets[d.seq].synonyms[tcnt].facilities[ftcnt].code_value = cv2.code_value, reply->sets[d
    .seq].synonyms[tcnt].facilities[ftcnt].display = cv2.display
   ENDIF
  FOOT  ocs.synonym_id
   stat = alterlist(reply->sets[d.seq].synonyms[tcnt].facilities,ftcnt)
  FOOT  d.seq
   stat = alterlist(reply->sets[d.seq].synonyms,tcnt)
  WITH nocounter
 ;end select
 IF (search_intermittent=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(scnt)),
    order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv1
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=reply->sets[d.seq].catalog_code_value))
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd)
    JOIN (cv1
    WHERE cv1.code_value=ocs.mnemonic_type_cd
     AND cv1.cdf_meaning="PRIMARY"
     AND cv1.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->sets[d.seq].intermittent_ind = ocs.intermittent_ind
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   cs_component cc,
   order_catalog_synonym ocs,
   order_sentence os,
   order_sentence_detail osd,
   order_entry_fields oef,
   long_text lt,
   order_sentence_filter osf,
   code_value cv_age,
   code_value cv_pma,
   code_value cv_weight
  PLAN (d)
   JOIN (cc
   WHERE (cc.catalog_cd=reply->sets[d.seq].catalog_code_value)
    AND cc.comp_type_cd=cs_ord_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=cc.comp_id)
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id))
   JOIN (osd
   WHERE osd.order_sentence_id=outerjoin(os.order_sentence_id))
   JOIN (oef
   WHERE oef.oe_field_id=outerjoin(osd.oe_field_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id)
    AND lt.active_ind=outerjoin(1))
   JOIN (osf
   WHERE outerjoin(os.order_sentence_id)=osf.order_sentence_id)
   JOIN (cv_age
   WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
   JOIN (cv_pma
   WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
   JOIN (cv_weight
   WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
  ORDER BY d.seq, ocs.synonym_id, os.order_sentence_id
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->sets[d.seq].ingredients,100)
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->sets[d.seq].ingredients,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->sets[d.seq].ingredients[tcnt].synonym_id = ocs.synonym_id, reply->sets[d.seq].ingredients[
   tcnt].mnemonic = ocs.mnemonic, reply->sets[d.seq].ingredients[tcnt].oe_format_id = ocs
   .oe_format_id,
   reply->sets[d.seq].ingredients[tcnt].rx_mask = ocs.rx_mask, reply->sets[d.seq].ingredients[tcnt].
   sequence = cc.comp_seq, reply->sets[d.seq].ingredients[tcnt].lock_details_flag = cc
   .lockdown_details_flag,
   reply->sets[d.seq].ingredients[tcnt].auto_verification_optional_ind = cc
   .av_optional_ingredient_ind, reply->sets[d.seq].ingredients[tcnt].catalog_code_value = ocs
   .catalog_cd
  HEAD os.order_sentence_id
   IF (os.order_sentence_id > 0)
    reply->sets[d.seq].ingredients[tcnt].order_sentence.order_sentence_id = os.order_sentence_id,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.display = os.order_sentence_display_line,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.oe_format_id = os.oe_format_id
    IF (lt.long_text_id > 0)
     reply->sets[d.seq].ingredients[tcnt].order_sentence.commment_id = lt.long_text_id, reply->sets[d
     .seq].ingredients[tcnt].order_sentence.comment_txt = lt.long_text
    ENDIF
   ENDIF
   fcnt = 0, ftcnt = 0, stat = alterlist(reply->sets[d.seq].ingredients[tcnt].order_sentence.details,
    10)
  DETAIL
   IF (os.order_sentence_id > 0
    AND oef.oe_field_id > 0)
    fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
    IF (fcnt > 10)
     stat = alterlist(reply->sets[d.seq].ingredients[tcnt].order_sentence.details,(ftcnt+ 10)), fcnt
      = 1
    ENDIF
    reply->sets[d.seq].ingredients[tcnt].order_sentence.details[ftcnt].oe_field_id = oef.oe_field_id,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.details[ftcnt].oe_field_label = oef
    .description, reply->sets[d.seq].ingredients[tcnt].order_sentence.details[ftcnt].field_code_value
     = osd.default_parent_entity_id,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.details[ftcnt].field_disp_value = osd
    .oe_field_display_value, reply->sets[d.seq].ingredients[tcnt].order_sentence.details[ftcnt].
    field_value = osd.oe_field_value, reply->sets[d.seq].ingredients[tcnt].order_sentence.details[
    ftcnt].field_type_flag = oef.field_type_flag,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.details[ftcnt].field_seq = osd.sequence,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.order_sentence_filter_id = osf
    .order_sentence_filter_id, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.
    age_min_value = osf.age_min_value,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.age_max_value = osf.age_max_value,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.age_unit_cd.code_value = osf
    .age_unit_cd, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.age_unit_cd.display =
    cv_age.display,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.age_unit_cd.description = cv_age
    .description, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.age_unit_cd.mean =
    cv_age.cdf_meaning, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.pma_min_value =
    osf.pma_min_value,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.pma_max_value = osf.pma_max_value,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.pma_unit_cd.code_value = osf
    .pma_unit_cd, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.pma_unit_cd.display =
    cv_pma.display,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.pma_unit_cd.description = cv_pma
    .description, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.pma_unit_cd.mean =
    cv_pma.cdf_meaning, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.weight_min_value
     = osf.weight_min_value,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.weight_max_value = osf
    .weight_max_value, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.weight_unit_cd.
    code_value = osf.weight_unit_cd, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.
    weight_unit_cd.display = cv_weight.display,
    reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.weight_unit_cd.description =
    cv_weight.description, reply->sets[d.seq].ingredients[tcnt].order_sentence.filters.weight_unit_cd
    .mean = cv_weight.cdf_meaning
   ENDIF
  FOOT  os.order_sentence_id
   stat = alterlist(reply->sets[d.seq].ingredients[tcnt].order_sentence.details,ftcnt)
  FOOT  d.seq
   stat = alterlist(reply->sets[d.seq].ingredients,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
