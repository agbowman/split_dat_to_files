CREATE PROGRAM bed_get_oc_orders_list:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 oc_list[*]
      2 catalog_cd = f8
      2 description = c100
      2 primary_mnemonic = c100
      2 cki = vc
      2 active_ind = i2
      2 synonyms[*]
        3 id = f8
        3 mnemonic = vc
        3 mnemonic_type
          4 code_value = f8
          4 display = vc
          4 mean = vc
        3 oe_format_id = f8
        3 active_ind = i2
      2 related_results_ind = i2
      2 orderable_type_flag = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 RECORD ordtemp(
   1 oc_list[*]
     2 catalog_cd = f8
     2 description = c100
     2 primary_mnemonic = c100
     2 cki = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 oe_format_id = f8
       3 fac_qual_ind = i2
       3 active_ind = i2
     2 therapeutic_class_match_ind = i2
     2 related_results_exist_ind = i2
     2 orderable_type_flag = f8
 )
 RECORD factemp(
   1 oc_list[*]
     2 catalog_cd = f8
     2 description = c100
     2 primary_mnemonic = c100
     2 cki = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 oe_format_id = f8
       3 fac_qual_ind = i2
       3 active_ind = i2
     2 orderable_type_flag = f8
 )
 RECORD therapeutic(
   1 classes[*]
     2 id = f8
 )
 DECLARE orderabletypesize = i4
 DECLARE excludedcatalogtypesize = i4
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET ocnt = 0
 SET alterlist_ocnt = 0
 SET rcnt = 0
 SET alterlist_rcnt = 0
 SET total_cnt = 0
 SET max_cnt = 0
 SET max_cnt = request->max_reply
 SET only_obsolete_ind = 0
 IF (validate(request->only_obsolete_ind))
  IF ((request->only_obsolete_ind=1))
   SET only_obsolete_ind = 1
  ENDIF
 ENDIF
 SET only_caresets_ind = 0
 IF (validate(request->only_caresets_ind))
  SET only_caresets_ind = request->only_caresets_ind
 ENDIF
 DECLARE search_string = vc
 SET search_string = "*"
 IF ((request->search_type_flag="S"))
  SET search_string = concat('"',trim(request->search_string),'*"')
 ELSE
  SET search_string = concat('"*',trim(request->search_string),'*"')
 ENDIF
 SET search_string = cnvtupper(search_string)
 DECLARE oc_parse = vc
 DECLARE ocs_parse = vc
 SET ocs_parse = " ocs.catalog_cd = oc.catalog_cd "
 IF ((request->load_inactives > 0))
  IF (only_caresets_ind=1)
   SET oc_parse = "oc.orderable_type_flag in (0,1,2,6)"
  ELSE
   IF (validate(request->exclude_free_text_orderables))
    IF ((request->exclude_free_text_orderables=1))
     SET oc_parse =
     "oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 and oc.orderable_type_flag != 10 "
    ELSE
     SET oc_parse = "oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 "
    ENDIF
   ELSE
    SET oc_parse = "oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 "
   ENDIF
  ENDIF
  IF ((request->load_inactives=2))
   SET oc_parse = concat(oc_parse," and oc.active_ind = 1 ")
   SET ocs_parse = concat(ocs_parse," and ocs.active_ind in (0,null) ")
  ENDIF
 ELSE
  IF (only_caresets_ind=1)
   SET oc_parse = "oc.active_ind = 1 and oc.orderable_type_flag in (0,1,2,6) "
  ELSE
   IF (validate(request->exclude_free_text_orderables))
    IF ((request->exclude_free_text_orderables=1))
     SET oc_parse = "oc.active_ind = 1 and oc.orderable_type_flag != 6 and "
     SET oc_parse = concat(oc_parse," oc.orderable_type_flag != 2 and oc.orderable_type_flag != 10 ")
    ELSE
     SET oc_parse =
     "oc.active_ind = 1 and oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 "
    ENDIF
   ELSE
    SET oc_parse =
    "oc.active_ind = 1 and oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 "
   ENDIF
  ENDIF
  SET ocs_parse = concat(ocs_parse," and ocs.active_ind = 1 ")
 ENDIF
 SET oc_parse = concat(oc_parse," and oc.catalog_cd > 0")
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->subactivity_type_code_value
   )
 ENDIF
 IF (validate(request->orderable_type_flags))
  SET orderabletypesize = size(request->orderable_type_flags,5)
  IF (orderabletypesize > 0)
   SET oc_parse = concat(oc_parse," and oc.orderable_type_flag in (")
   SET ocs_parse = concat(ocs_parse," and ocs.orderable_type_flag in (")
   FOR (i = 1 TO orderabletypesize)
     SET oc_parse = concat(oc_parse,build(request->orderable_type_flags[i].flag))
     SET ocs_parse = concat(ocs_parse,build(request->orderable_type_flags[i].flag))
     IF (i=orderabletypesize)
      SET oc_parse = concat(oc_parse,")")
      SET ocs_parse = concat(ocs_parse,")")
     ELSE
      SET oc_parse = concat(oc_parse,",")
      SET ocs_parse = concat(ocs_parse,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (validate(request->excluded_catalog_types))
  SET excludedcatalogtypesize = size(request->excluded_catalog_types,5)
  IF (excludedcatalogtypesize > 0)
   SET oc_parse = concat(oc_parse," and oc.catalog_type_cd not in (")
   FOR (i = 1 TO excludedcatalogtypesize)
    SET oc_parse = concat(oc_parse,build(request->excluded_catalog_types[i].id))
    IF (i=excludedcatalogtypesize)
     SET oc_parse = concat(oc_parse,")")
    ELSE
     SET oc_parse = concat(oc_parse,",")
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->search_string > " "))
  SET mnemoniccount = 0
  IF (validate(request->mnemonic_types))
   SET mnemoniccount = size(request->mnemonic_types,5)
  ENDIF
  IF ((((request->search_all_mnem_types_ind=1)) OR ((((request->mnemonic_type_code_value > 0)) OR (
  mnemoniccount > 0)) )) )
   SET ocs_parse = concat(ocs_parse," and cnvtupper(ocs.mnemonic) = ",search_string)
  ELSE
   SET oc_parse = concat(oc_parse," and (cnvtupper(oc.description) = ",search_string,
    " or  cnvtupper(oc.primary_mnemonic) = ",search_string,
    ")")
  ENDIF
 ENDIF
 IF ((request->mnemonic_type_code_value > 0))
  SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd = request->mnemonic_type_code_value")
 ELSEIF (validate(request->mnemonic_types))
  SET mnemonictypessize = size(request->mnemonic_types,5)
  IF (mnemonictypessize > 0)
   SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd in (")
   FOR (count = 1 TO mnemonictypessize)
    SET ocs_parse = concat(ocs_parse,build(request->mnemonic_types[count].mnemonic_type_code_value))
    IF (count=mnemonictypessize)
     SET ocs_parse = concat(ocs_parse,")")
    ELSE
     SET ocs_parse = concat(ocs_parse,",")
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->oe_format_id > 0))
  SET ocs_parse = build(ocs_parse," and ocs.oe_format_id = ",request->oe_format_id)
 ENDIF
 DECLARE off_parse = vc
 IF ((request->oe_field_id > 0))
  SET off_parse = build(" off.oe_format_id = ocs.oe_format_id and off.oe_field_id = ",request->
   oe_field_id)
 ELSE
  SET off_parse = " off.oe_format_id = outerjoin(oc.oe_format_id)"
 ENDIF
 SET therapeutic_class_id = 0.0
 IF (validate(request->therapeutic_class_id))
  IF ((request->therapeutic_class_id > 0))
   SET therapeutic_class_id = request->therapeutic_class_id
   SET oc_parse = build(oc_parse," and oc.cki = 'MUL.ORD!d*'")
  ENDIF
 ENDIF
 SET related_results_filter_ind = 0
 IF (validate(request->related_results_filter_ind))
  SET related_results_filter_ind = request->related_results_filter_ind
 ENDIF
 IF (only_obsolete_ind=1)
  IF ((request->oe_field_id > 0))
   SELECT INTO "NL:"
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     oe_format_fields off,
     code_value cv,
     mltm_order_catalog_load m
    PLAN (oc
     WHERE parser(oc_parse))
     JOIN (ocs
     WHERE parser(ocs_parse))
     JOIN (off
     WHERE parser(off_parse))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd)
     JOIN (m
     WHERE m.synonym_cki=outerjoin(ocs.cki)
      AND m.active_ind=outerjoin(1))
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     stat = alterlist(ordtemp->oc_list,50), ocnt = 0, alterlist_ocnt = 0
    HEAD oc.catalog_cd
     ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
     IF (alterlist_ocnt > 50)
      stat = alterlist(ordtemp->oc_list,(ocnt+ 50)), alterlist_ocnt = 1
     ENDIF
     ordtemp->oc_list[ocnt].catalog_cd = oc.catalog_cd, ordtemp->oc_list[ocnt].description = oc
     .description, ordtemp->oc_list[ocnt].primary_mnemonic = oc.primary_mnemonic,
     ordtemp->oc_list[ocnt].cki = oc.cki, ordtemp->oc_list[ocnt].active_ind = oc.active_ind, ordtemp
     ->oc_list[ocnt].orderable_type_flag = oc.orderable_type_flag,
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,10), scnt = 0, alterlist_scnt = 0
    HEAD ocs.synonym_id
     IF (m.synonym_cki=" ")
      scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
      IF (alterlist_scnt > 10)
       stat = alterlist(ordtemp->oc_list[ocnt].synonyms,(scnt+ 10)), alterlist_scnt = 1
      ENDIF
      ordtemp->oc_list[ocnt].synonyms[scnt].id = ocs.synonym_id, ordtemp->oc_list[ocnt].synonyms[scnt
      ].mnemonic = ocs.mnemonic, ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.code_value = cv
      .code_value,
      ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.display = cv.display, ordtemp->oc_list[ocnt
      ].synonyms[scnt].mnemonic_type.mean = cv.cdf_meaning, ordtemp->oc_list[ocnt].synonyms[scnt].
      oe_format_id = ocs.oe_format_id,
      ordtemp->oc_list[ocnt].synonyms[scnt].active_ind = ocs.active_ind
     ENDIF
    FOOT  oc.catalog_cd
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,scnt)
    FOOT REPORT
     stat = alterlist(ordtemp->oc_list,ocnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     code_value cv,
     mltm_order_catalog_load m
    PLAN (oc
     WHERE parser(oc_parse))
     JOIN (ocs
     WHERE parser(ocs_parse))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd)
     JOIN (m
     WHERE m.synonym_cki=outerjoin(ocs.cki)
      AND m.active_ind=outerjoin(1))
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     stat = alterlist(ordtemp->oc_list,50), ocnt = 0, alterlist_ocnt = 0
    HEAD oc.catalog_cd
     ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
     IF (alterlist_ocnt > 50)
      stat = alterlist(ordtemp->oc_list,(ocnt+ 50)), alterlist_ocnt = 1
     ENDIF
     ordtemp->oc_list[ocnt].catalog_cd = oc.catalog_cd, ordtemp->oc_list[ocnt].description = oc
     .description, ordtemp->oc_list[ocnt].primary_mnemonic = oc.primary_mnemonic,
     ordtemp->oc_list[ocnt].cki = oc.cki, ordtemp->oc_list[ocnt].active_ind = oc.active_ind, ordtemp
     ->oc_list[ocnt].orderable_type_flag = oc.orderable_type_flag,
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,10), scnt = 0, alterlist_scnt = 0
    HEAD ocs.synonym_id
     IF (m.synonym_cki=" ")
      scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
      IF (alterlist_scnt > 10)
       stat = alterlist(ordtemp->oc_list[ocnt].synonyms,(scnt+ 10)), alterlist_scnt = 1
      ENDIF
      ordtemp->oc_list[ocnt].synonyms[scnt].id = ocs.synonym_id, ordtemp->oc_list[ocnt].synonyms[scnt
      ].mnemonic = ocs.mnemonic, ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.code_value = cv
      .code_value,
      ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.display = cv.display, ordtemp->oc_list[ocnt
      ].synonyms[scnt].mnemonic_type.mean = cv.cdf_meaning, ordtemp->oc_list[ocnt].synonyms[scnt].
      oe_format_id = ocs.oe_format_id,
      ordtemp->oc_list[ocnt].synonyms[scnt].active_ind = ocs.active_ind
     ENDIF
    FOOT  oc.catalog_cd
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,scnt)
    FOOT REPORT
     stat = alterlist(ordtemp->oc_list,ocnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  IF ((request->oe_field_id > 0))
   SELECT INTO "NL:"
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     oe_format_fields off,
     code_value cv
    PLAN (oc
     WHERE parser(oc_parse))
     JOIN (ocs
     WHERE parser(ocs_parse))
     JOIN (off
     WHERE parser(off_parse))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd)
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     stat = alterlist(ordtemp->oc_list,50), ocnt = 0, alterlist_ocnt = 0
    HEAD oc.catalog_cd
     ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
     IF (alterlist_ocnt > 50)
      stat = alterlist(ordtemp->oc_list,(ocnt+ 50)), alterlist_ocnt = 1
     ENDIF
     ordtemp->oc_list[ocnt].catalog_cd = oc.catalog_cd, ordtemp->oc_list[ocnt].description = oc
     .description, ordtemp->oc_list[ocnt].primary_mnemonic = oc.primary_mnemonic,
     ordtemp->oc_list[ocnt].cki = oc.cki, ordtemp->oc_list[ocnt].active_ind = oc.active_ind, ordtemp
     ->oc_list[ocnt].orderable_type_flag = oc.orderable_type_flag,
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,10), scnt = 0, alterlist_scnt = 0
    HEAD ocs.synonym_id
     scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
     IF (alterlist_scnt > 10)
      stat = alterlist(ordtemp->oc_list[ocnt].synonyms,(scnt+ 10)), alterlist_scnt = 1
     ENDIF
     ordtemp->oc_list[ocnt].synonyms[scnt].id = ocs.synonym_id, ordtemp->oc_list[ocnt].synonyms[scnt]
     .mnemonic = ocs.mnemonic, ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.code_value = cv
     .code_value,
     ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.display = cv.display, ordtemp->oc_list[ocnt]
     .synonyms[scnt].mnemonic_type.mean = cv.cdf_meaning, ordtemp->oc_list[ocnt].synonyms[scnt].
     oe_format_id = ocs.oe_format_id,
     ordtemp->oc_list[ocnt].synonyms[scnt].active_ind = ocs.active_ind
    FOOT  oc.catalog_cd
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,scnt)
    FOOT REPORT
     stat = alterlist(ordtemp->oc_list,ocnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     code_value cv
    PLAN (oc
     WHERE parser(oc_parse))
     JOIN (ocs
     WHERE parser(ocs_parse))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd)
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     stat = alterlist(ordtemp->oc_list,50), ocnt = 0, alterlist_ocnt = 0
    HEAD oc.catalog_cd
     ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
     IF (alterlist_ocnt > 50)
      stat = alterlist(ordtemp->oc_list,(ocnt+ 50)), alterlist_ocnt = 1
     ENDIF
     ordtemp->oc_list[ocnt].catalog_cd = oc.catalog_cd, ordtemp->oc_list[ocnt].description = oc
     .description, ordtemp->oc_list[ocnt].primary_mnemonic = oc.primary_mnemonic,
     ordtemp->oc_list[ocnt].cki = oc.cki, ordtemp->oc_list[ocnt].active_ind = oc.active_ind, ordtemp
     ->oc_list[ocnt].orderable_type_flag = oc.orderable_type_flag,
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,10), scnt = 0, alterlist_scnt = 0
    HEAD ocs.synonym_id
     scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
     IF (alterlist_scnt > 10)
      stat = alterlist(ordtemp->oc_list[ocnt].synonyms,(scnt+ 10)), alterlist_scnt = 1
     ENDIF
     ordtemp->oc_list[ocnt].synonyms[scnt].id = ocs.synonym_id, ordtemp->oc_list[ocnt].synonyms[scnt]
     .mnemonic = ocs.mnemonic, ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.code_value = cv
     .code_value,
     ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type.display = cv.display, ordtemp->oc_list[ocnt]
     .synonyms[scnt].mnemonic_type.mean = cv.cdf_meaning, ordtemp->oc_list[ocnt].synonyms[scnt].
     oe_format_id = ocs.oe_format_id,
     ordtemp->oc_list[ocnt].synonyms[scnt].active_ind = ocs.active_ind
    FOOT  oc.catalog_cd
     stat = alterlist(ordtemp->oc_list[ocnt].synonyms,scnt)
    FOOT REPORT
     stat = alterlist(ordtemp->oc_list,ocnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET total_cnt = ocnt
 IF (total_cnt > 0)
  IF (therapeutic_class_id > 0)
   SET class_cnt = 1
   SET stat = alterlist(therapeutic->classes,1)
   SET therapeutic->classes[1].id = request->therapeutic_class_id
   DECLARE class_parse = vc
   SET class_parse = build("m.multum_category_id in (",request->therapeutic_class_id,")")
   SET search_ind = 1
   WHILE (search_ind=1)
     SET class_cnt_before = class_cnt
     SELECT INTO "NL:"
      FROM mltm_category_sub_xref m
      WHERE parser(class_parse)
      HEAD REPORT
       class_parse = "m.multum_category_id in (", comma_ind = 0
      DETAIL
       class_cnt = (class_cnt+ 1), stat = alterlist(therapeutic->classes,class_cnt), therapeutic->
       classes[class_cnt].id = m.sub_category_id
       IF (comma_ind=0)
        class_parse = build(class_parse,m.sub_category_id), comma_ind = 1
       ELSE
        class_parse = build(class_parse,",",m.sub_category_id)
       ENDIF
      WITH nocounter
     ;end select
     SET class_parse = build(class_parse,")")
     IF (class_cnt=class_cnt_before)
      SET search_ind = 0
     ENDIF
   ENDWHILE
   DECLARE class_string = vc
   SET class_string = "m.multum_category_id in ("
   FOR (c = 1 TO class_cnt)
     IF (c=1)
      SET class_string = build(class_string,therapeutic->classes[c].id)
     ELSE
      SET class_string = build(class_string,",",therapeutic->classes[c].id)
     ENDIF
   ENDFOR
   SET class_string = build(class_string,")")
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = total_cnt),
     mltm_category_drug_xref m
    PLAN (d)
     JOIN (m
     WHERE m.drug_identifier=substring(9,6,ordtemp->oc_list[d.seq].cki)
      AND parser(class_string))
    DETAIL
     ordtemp->oc_list[d.seq].therapeutic_class_match_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  IF (related_results_filter_ind IN (1, 2))
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = total_cnt),
     catalog_event_sets c
    PLAN (d)
     JOIN (c
     WHERE (c.catalog_cd=ordtemp->oc_list[d.seq].catalog_cd))
    DETAIL
     ordtemp->oc_list[d.seq].related_results_exist_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->facility_show_for=0)
  AND (request->facility_do_not_show_for=0))
  IF (((therapeutic_class_id > 0) OR (related_results_filter_ind > 0)) )
   SET total_qualify = 0
   FOR (r = 1 TO total_cnt)
     SET skip_ind = 0
     IF (therapeutic_class_id > 0
      AND (ordtemp->oc_list[r].therapeutic_class_match_ind=0))
      SET skip_ind = 1
     ENDIF
     IF (related_results_filter_ind=1
      AND (ordtemp->oc_list[r].related_results_exist_ind=0))
      SET skip_ind = 1
     ENDIF
     IF (related_results_filter_ind=2
      AND (ordtemp->oc_list[r].related_results_exist_ind=1))
      SET skip_ind = 1
     ENDIF
     IF (skip_ind=0)
      SET total_qualify = (total_qualify+ 1)
     ENDIF
   ENDFOR
   IF (((max_cnt=0) OR (((total_qualify=max_cnt) OR (total_qualify < max_cnt)) )) )
    SET replycnt = 0
    FOR (r = 1 TO total_cnt)
      SET skip_ind = 0
      IF (therapeutic_class_id > 0
       AND (ordtemp->oc_list[r].therapeutic_class_match_ind=0))
       SET skip_ind = 1
      ENDIF
      IF (related_results_filter_ind=1
       AND (ordtemp->oc_list[r].related_results_exist_ind=0))
       SET skip_ind = 1
      ENDIF
      IF (related_results_filter_ind=2
       AND (ordtemp->oc_list[r].related_results_exist_ind=1))
       SET skip_ind = 1
      ENDIF
      IF (skip_ind=0)
       SET replycnt = (replycnt+ 1)
       SET stat = alterlist(reply->oc_list,replycnt)
       SET reply->oc_list[replycnt].catalog_cd = ordtemp->oc_list[r].catalog_cd
       SET reply->oc_list[replycnt].description = ordtemp->oc_list[r].description
       SET reply->oc_list[replycnt].primary_mnemonic = ordtemp->oc_list[r].primary_mnemonic
       SET reply->oc_list[replycnt].cki = ordtemp->oc_list[r].cki
       SET reply->oc_list[replycnt].active_ind = ordtemp->oc_list[r].active_ind
       SET reply->oc_list[replycnt].orderable_type_flag = ordtemp->oc_list[r].orderable_type_flag
       IF ((request->load_synonyms_ind=1))
        SET scnt = size(ordtemp->oc_list[r].synonyms,5)
        SET stat = alterlist(reply->oc_list[replycnt].synonyms,scnt)
        FOR (s = 1 TO scnt)
          SET reply->oc_list[replycnt].synonyms[s].id = ordtemp->oc_list[r].synonyms[s].id
          SET reply->oc_list[replycnt].synonyms[s].mnemonic = ordtemp->oc_list[r].synonyms[s].
          mnemonic
          SET reply->oc_list[replycnt].synonyms[s].mnemonic_type.code_value = ordtemp->oc_list[r].
          synonyms[s].mnemonic_type.code_value
          SET reply->oc_list[replycnt].synonyms[s].mnemonic_type.display = ordtemp->oc_list[r].
          synonyms[s].mnemonic_type.display
          SET reply->oc_list[replycnt].synonyms[s].mnemonic_type.mean = ordtemp->oc_list[r].synonyms[
          s].mnemonic_type.mean
          SET reply->oc_list[replycnt].synonyms[s].oe_format_id = ordtemp->oc_list[r].synonyms[s].
          oe_format_id
          SET reply->oc_list[replycnt].synonyms[s].active_ind = ordtemp->oc_list[r].synonyms[s].
          active_ind
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET total_cnt = total_qualify
  ELSE
   IF (((max_cnt=0) OR (((total_cnt=max_cnt) OR (total_cnt < max_cnt)) )) )
    SET stat = alterlist(reply->oc_list,ocnt)
    FOR (r = 1 TO total_cnt)
      SET reply->oc_list[r].catalog_cd = ordtemp->oc_list[r].catalog_cd
      SET reply->oc_list[r].description = ordtemp->oc_list[r].description
      SET reply->oc_list[r].primary_mnemonic = ordtemp->oc_list[r].primary_mnemonic
      SET reply->oc_list[r].cki = ordtemp->oc_list[r].cki
      SET reply->oc_list[r].active_ind = ordtemp->oc_list[r].active_ind
      SET reply->oc_list[r].orderable_type_flag = ordtemp->oc_list[r].orderable_type_flag
      IF ((request->load_synonyms_ind=1))
       SET scnt = size(ordtemp->oc_list[r].synonyms,5)
       SET stat = alterlist(reply->oc_list[r].synonyms,scnt)
       FOR (s = 1 TO scnt)
         SET reply->oc_list[r].synonyms[s].id = ordtemp->oc_list[r].synonyms[s].id
         SET reply->oc_list[r].synonyms[s].mnemonic = ordtemp->oc_list[r].synonyms[s].mnemonic
         SET reply->oc_list[r].synonyms[s].mnemonic_type.code_value = ordtemp->oc_list[r].synonyms[s]
         .mnemonic_type.code_value
         SET reply->oc_list[r].synonyms[s].mnemonic_type.display = ordtemp->oc_list[r].synonyms[s].
         mnemonic_type.display
         SET reply->oc_list[r].synonyms[s].mnemonic_type.mean = ordtemp->oc_list[r].synonyms[s].
         mnemonic_type.mean
         SET reply->oc_list[r].synonyms[s].oe_format_id = ordtemp->oc_list[r].synonyms[s].
         oe_format_id
         SET reply->oc_list[r].synonyms[s].active_ind = ordtemp->oc_list[r].synonyms[s].active_ind
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ELSEIF ((request->facility_show_for > 0)
  AND (request->facility_do_not_show_for=0))
  IF ((request->facility_exclude_default_rows=1))
   SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
    "ofr.facility_cd = request->facility_show_for")
  ELSE
   SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
    "(ofr.facility_cd = 0 or ofr.facility_cd = request->facility_show_for)")
  ENDIF
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog oc,
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=ordtemp->oc_list[d.seq].catalog_cd))
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd)
     JOIN (ofr
     WHERE parser(ofr_parse))
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     stat = alterlist(reply->oc_list,50), rcnt = 0, alterlist_rcnt = 0
    HEAD oc.catalog_cd
     rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
     IF (alterlist_rcnt > 50)
      stat = alterlist(reply->oc_list,(rcnt+ 50)), alterlist_rcnt = 1
     ENDIF
     reply->oc_list[rcnt].catalog_cd = ordtemp->oc_list[d.seq].catalog_cd, reply->oc_list[rcnt].
     description = ordtemp->oc_list[d.seq].description, reply->oc_list[rcnt].primary_mnemonic =
     ordtemp->oc_list[d.seq].primary_mnemonic,
     reply->oc_list[rcnt].cki = ordtemp->oc_list[d.seq].cki, reply->oc_list[rcnt].active_ind =
     ordtemp->oc_list[d.seq].active_ind, reply->oc_list[rcnt].orderable_type_flag = ordtemp->oc_list[
     d.seq].orderable_type_flag,
     rep_syn_cnt = 0
    HEAD ocs.synonym_id
     scnt = size(ordtemp->oc_list[d.seq].synonyms,5)
     FOR (s = 1 TO scnt)
       IF ((ocs.synonym_id=ordtemp->oc_list[d.seq].synonyms[s].id))
        rep_syn_cnt = (rep_syn_cnt+ 1), stat = alterlist(reply->oc_list[rcnt].synonyms,rep_syn_cnt),
        reply->oc_list[rcnt].synonyms[rep_syn_cnt].id = ordtemp->oc_list[d.seq].synonyms[s].id,
        reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic = ordtemp->oc_list[d.seq].synonyms[s].
        mnemonic, reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.code_value = ordtemp->
        oc_list[d.seq].synonyms[s].mnemonic_type.code_value, reply->oc_list[rcnt].synonyms[
        rep_syn_cnt].mnemonic_type.display = ordtemp->oc_list[d.seq].synonyms[s].mnemonic_type.
        display,
        reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.mean = ordtemp->oc_list[d.seq].
        synonyms[s].mnemonic_type.mean, reply->oc_list[rcnt].synonyms[rep_syn_cnt].oe_format_id =
        ordtemp->oc_list[d.seq].synonyms[s].oe_format_id, reply->oc_list[rcnt].synonyms[rep_syn_cnt].
        active_ind = ordtemp->oc_list[d.seq].synonyms[s].active_ind
       ENDIF
     ENDFOR
    FOOT  oc.catalog_cd
     IF ((request->load_synonyms_ind=0))
      stat = alterlist(reply->oc_list[rcnt].synonyms,0)
     ENDIF
     IF (rep_syn_cnt=0)
      rcnt = (rcnt - 1), alterlist_rcnt = (alterlist_rcnt - 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->oc_list,rcnt)
    WITH nocounter
   ;end select
  ENDIF
  SET total_cnt = rcnt
 ELSEIF ((request->facility_show_for=0)
  AND (request->facility_do_not_show_for > 0))
  SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
   " ofr.facility_cd in (request->facility_do_not_show_for, 0)")
  SET stat = alterlist(reply->oc_list,50)
  SET rcnt = 0
  SET alterlist_rcnt = 0
  FOR (o = 1 TO ocnt)
    SET row_found = 0
    SELECT INTO "NL:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      ocs_facility_r ofr
     PLAN (oc
      WHERE (oc.catalog_cd=ordtemp->oc_list[o].catalog_cd))
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd)
      JOIN (ofr
      WHERE parser(ofr_parse))
     ORDER BY ocs.synonym_id
     HEAD ocs.synonym_id
      scnt = size(ordtemp->oc_list[o].synonyms,5)
      FOR (s = 1 TO scnt)
        IF ((ocs.synonym_id=ordtemp->oc_list[o].synonyms[s].id))
         ordtemp->oc_list[o].synonyms[s].fac_qual_ind = 1
        ENDIF
      ENDFOR
     DETAIL
      row_found = 1
     WITH nocounter
    ;end select
    SET scnt = size(ordtemp->oc_list[o].synonyms,5)
    SET ord_load_ind = 0
    SET rep_syn_cnt = 0
    FOR (s = 1 TO scnt)
      IF ((ordtemp->oc_list[o].synonyms[s].fac_qual_ind=0))
       IF (ord_load_ind=0)
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->oc_list,rcnt)
        SET reply->oc_list[rcnt].catalog_cd = ordtemp->oc_list[o].catalog_cd
        SET reply->oc_list[rcnt].description = ordtemp->oc_list[o].description
        SET reply->oc_list[rcnt].primary_mnemonic = ordtemp->oc_list[o].primary_mnemonic
        SET reply->oc_list[rcnt].cki = ordtemp->oc_list[o].cki
        SET reply->oc_list[rcnt].active_ind = ordtemp->oc_list[o].active_ind
        SET reply->oc_list[rcnt].orderable_type_flag = ordtemp->oc_list[o].orderable_type_flag
       ENDIF
       SET ord_load_ind = 1
       IF ((request->load_synonyms_ind=1))
        SET rep_syn_cnt = (rep_syn_cnt+ 1)
        SET stat = alterlist(reply->oc_list[rcnt].synonyms,rep_syn_cnt)
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].id = ordtemp->oc_list[o].synonyms[s].id
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic = ordtemp->oc_list[o].synonyms[s].
        mnemonic
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.code_value = ordtemp->oc_list[o]
        .synonyms[s].mnemonic_type.code_value
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.display = ordtemp->oc_list[o].
        synonyms[s].mnemonic_type.display
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.mean = ordtemp->oc_list[o].
        synonyms[s].mnemonic_type.mean
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].oe_format_id = ordtemp->oc_list[o].synonyms[s]
        .oe_format_id
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].active_ind = ordtemp->oc_list[o].synonyms[s].
        active_ind
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(reply->oc_list,rcnt)
  SET total_cnt = rcnt
 ELSEIF ((request->facility_show_for > 0)
  AND (request->facility_do_not_show_for > 0))
  SET stat = alterlist(factemp->oc_list,50)
  SET fcnt = 0
  SET alterlist_fcnt = 0
  IF ((request->facility_exclude_default_rows=1))
   SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
    "ofr.facility_cd = request->facility_show_for")
  ELSE
   SET ofr_parse = build("ofr.synonym_id = ocs.synonym_id and "," ofr.facility_cd IN (0,",request->
    facility_show_for,")")
  ENDIF
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog oc,
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=ordtemp->oc_list[d.seq].catalog_cd))
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd)
     JOIN (ofr
     WHERE parser(ofr_parse))
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD oc.catalog_cd
     fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
     IF (alterlist_fcnt > 50)
      stat = alterlist(factemp->oc_list,(fcnt+ 50)), alterlist_fcnt = 1
     ENDIF
     factemp->oc_list[fcnt].catalog_cd = ordtemp->oc_list[d.seq].catalog_cd, factemp->oc_list[fcnt].
     description = ordtemp->oc_list[d.seq].description, factemp->oc_list[fcnt].primary_mnemonic =
     ordtemp->oc_list[d.seq].primary_mnemonic,
     factemp->oc_list[fcnt].cki = ordtemp->oc_list[d.seq].cki, factemp->oc_list[fcnt].active_ind =
     ordtemp->oc_list[d.seq].active_ind, factemp->oc_list[rcnt].orderable_type_flag = ordtemp->
     oc_list[d.seq].orderable_type_flag,
     f_syn_cnt = 0
    HEAD ocs.synonym_id
     scnt = size(ordtemp->oc_list[d.seq].synonyms,5)
     FOR (s = 1 TO scnt)
       IF ((ocs.synonym_id=ordtemp->oc_list[d.seq].synonyms[s].id))
        f_syn_cnt = (f_syn_cnt+ 1), stat = alterlist(factemp->oc_list[fcnt].synonyms,f_syn_cnt),
        factemp->oc_list[fcnt].synonyms[f_syn_cnt].id = ordtemp->oc_list[d.seq].synonyms[s].id,
        factemp->oc_list[fcnt].synonyms[f_syn_cnt].mnemonic = ordtemp->oc_list[d.seq].synonyms[s].
        mnemonic, factemp->oc_list[fcnt].synonyms[f_syn_cnt].mnemonic_type.code_value = ordtemp->
        oc_list[d.seq].synonyms[s].mnemonic_type.code_value, factemp->oc_list[fcnt].synonyms[
        f_syn_cnt].mnemonic_type.display = ordtemp->oc_list[d.seq].synonyms[s].mnemonic_type.display,
        factemp->oc_list[fcnt].synonyms[f_syn_cnt].mnemonic_type.mean = ordtemp->oc_list[d.seq].
        synonyms[s].mnemonic_type.mean, factemp->oc_list[fcnt].synonyms[f_syn_cnt].oe_format_id =
        ordtemp->oc_list[d.seq].synonyms[s].oe_format_id, factemp->oc_list[fcnt].synonyms[f_syn_cnt].
        active_ind = ordtemp->oc_list[d.seq].synonyms[s].active_ind
       ENDIF
     ENDFOR
    FOOT REPORT
     stat = alterlist(factemp->oc_list,fcnt)
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->oc_list,50)
  SET rcnt = 0
  SET alterlist_rcnt = 0
  FOR (f = 1 TO fcnt)
    SET row_found = 0
    SELECT INTO "NL:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      ocs_facility_r ofr
     PLAN (oc
      WHERE (oc.catalog_cd=factemp->oc_list[f].catalog_cd))
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd)
      JOIN (ofr
      WHERE ofr.synonym_id=ocs.synonym_id
       AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_do_not_show_for))) )
     ORDER BY ocs.synonym_id
     HEAD ocs.synonym_id
      scnt = size(factemp->oc_list[f].synonyms,5)
      FOR (s = 1 TO scnt)
        IF ((ocs.synonym_id=factemp->oc_list[f].synonyms[s].id))
         factemp->oc_list[f].synonyms[s].fac_qual_ind = 1
        ENDIF
      ENDFOR
     DETAIL
      row_found = 1
     WITH nocounter
    ;end select
    SET ord_load_ind = 0
    SET scnt = size(factemp->oc_list[f].synonyms,5)
    SET rep_syn_cnt = 0
    FOR (s = 1 TO scnt)
      IF ((factemp->oc_list[f].synonyms[s].fac_qual_ind=0))
       IF (ord_load_ind=0)
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->oc_list,rcnt)
        SET reply->oc_list[rcnt].catalog_cd = factemp->oc_list[f].catalog_cd
        SET reply->oc_list[rcnt].description = factemp->oc_list[f].description
        SET reply->oc_list[rcnt].primary_mnemonic = factemp->oc_list[f].primary_mnemonic
        SET reply->oc_list[rcnt].cki = factemp->oc_list[f].cki
        SET reply->oc_list[rcnt].active_ind = factemp->oc_list[f].active_ind
        SET reply->oc_list[rcnt].orderable_type_flag = factemp->oc_list[f].orderable_type_flag
       ENDIF
       SET ord_load_ind = 1
       IF ((request->load_synonyms_ind=1))
        SET rep_syn_cnt = (rep_syn_cnt+ 1)
        SET stat = alterlist(reply->oc_list[rcnt].synonyms,rep_syn_cnt)
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].id = factemp->oc_list[f].synonyms[s].id
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic = factemp->oc_list[f].synonyms[s].
        mnemonic
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.code_value = factemp->oc_list[f]
        .synonyms[s].mnemonic_type.code_value
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.display = factemp->oc_list[f].
        synonyms[s].mnemonic_type.display
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].mnemonic_type.mean = factemp->oc_list[f].
        synonyms[s].mnemonic_type.mean
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].oe_format_id = factemp->oc_list[f].synonyms.
        oe_format_id
        SET reply->oc_list[rcnt].synonyms[rep_syn_cnt].active_ind = factemp->oc_list[f].synonyms.
        active_ind
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(reply->oc_list,rcnt)
  SET total_cnt = rcnt
 ENDIF
 IF (validate(request->load_related_results_ind))
  IF ((request->load_related_results_ind=1))
   SET tcnt = size(reply->oc_list,5)
   IF (tcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tcnt)),
      catalog_event_sets c
     PLAN (d)
      JOIN (c
      WHERE (c.catalog_cd=reply->oc_list[d.seq].catalog_cd))
     DETAIL
      reply->oc_list[d.seq].related_results_ind = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (total_cnt=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (total_cnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
 IF (max_cnt > 0
  AND total_cnt > max_cnt)
  SET stat = alterlist(reply->oc_list,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
