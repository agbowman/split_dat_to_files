CREATE PROGRAM bed_get_nurse_witns_ords_list:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 active_ind = i2
       3 hide_flag = i2
       3 synonym_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD therapeutic(
   1 classes[*]
     2 id = f8
 )
 RECORD searchtemp(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 active_ind = i2
       3 hide_flag = i2
       3 synonym_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
 )
 RECORD ordtemp(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 active_ind = i2
       3 hide_flag = i2
       3 synonym_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 move_ind = i2
 )
 RECORD exceptemp(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 active_ind = i2
       3 hide_flag = i2
       3 synonym_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 fac_match_ind = i2
       3 loc_match_ind = i2
       3 iv_event_match_ind = i2
       3 route_match_ind = i2
       3 age_range_match_ind = i2
       3 move_ind = i2
 )
 RECORD factemp(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
     2 active_ind = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 active_ind = i2
       3 hide_flag = i2
       3 synonym_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 move_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET total_ord_cnt = 0
 SET last_ord = 0
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 2500
 ENDIF
 DECLARE pharmacy_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharmacy_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE age_range_cd = f8 WITH public, noconstant(0.0)
 DECLARE iv_event_cd = f8 WITH public, noconstant(0.0)
 DECLARE location_cd = f8 WITH public, noconstant(0.0)
 DECLARE route_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4000047
    AND cv.cdf_meaning IN ("AGECODE", "IVEVENT", "LOCATION", "ROUTE")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="AGECODE")
    age_range_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVEVENT")
    iv_event_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="LOCATION")
    location_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ROUTE")
    route_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE brandname_cd = f8 WITH public, noconstant(0.0)
 DECLARE dcp_cd = f8 WITH public, noconstant(0.0)
 DECLARE dispdrug_cd = f8 WITH public, noconstant(0.0)
 DECLARE generictop_cd = f8 WITH public, noconstant(0.0)
 DECLARE ivname_cd = f8 WITH public, noconstant(0.0)
 DECLARE primary_cd = f8 WITH public, noconstant(0.0)
 DECLARE tradetop_cd = f8 WITH public, noconstant(0.0)
 DECLARE rxmnem_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP", "RXMNEMONIC")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="BRANDNAME")
    brandname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DCP")
    dcp_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPDRUG")
    dispdrug_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICTOP")
    generictop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVNAME")
    ivname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PRIMARY")
    primary_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADETOP")
    tradetop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RXMNEMONIC")
    rxmnem_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE search_string = vc
 IF ((request->search_string > " "))
  SET search_string = cnvtupper(request->search_string)
 ENDIF
 DECLARE oc_parse = vc
 SET oc_parse = build2(
  "oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 and oc.catalog_cd > 0 and oc.catalog_type_cd = ",
  cnvtstring(pharmacy_cd))
 DECLARE ocs_parse = vc
 SET ocs_parse = "ocs.catalog_cd = oc.catalog_cd"
 SET exception_search_ind = 0
 IF ((request->exception_mode_ind=1))
  SET exception_search_ind = 1
  SET oc_parse = build2(oc_parse," and oc.active_ind = 1")
  SET ocs_parse = build2(ocs_parse," and ocs.witness_flag = ",cnvtstring(request->witness_default_ind
    ))
  SET ocs_parse = build2(ocs_parse," and ocs.active_ind = 1")
  SET ocs_parse = build2(ocs_parse,
   " and ocs.mnemonic_type_cd in (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd,",
   "ivname_cd, primary_cd, tradetop_cd, rxmnem_cd)")
 ELSE
  IF ((request->include_inactives_ind=0))
   SET oc_parse = build2(oc_parse," and oc.active_ind = 1")
  ENDIF
  IF ((request->order_entry_format_id > 0))
   SET ocs_parse = build2(ocs_parse," and ocs.oe_format_id = ",request->order_entry_format_id)
  ENDIF
  IF ((request->include_inactives_ind=0))
   SET ocs_parse = build2(ocs_parse," and ocs.active_ind = 1")
  ENDIF
  IF ((request->include_hidden_synonyms_ind=0))
   SET ocs_parse = build2(ocs_parse," and ocs.hide_flag in (0,null)")
  ENDIF
  IF ((request->synonym_type_code_value > 0))
   SET ocs_parse = build2(ocs_parse," and ocs.mnemonic_type_cd = ",request->synonym_type_code_value)
  ELSE
   SET ocs_parse = build2(ocs_parse,
    " and ocs.mnemonic_type_cd in (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd,",
    "ivname_cd, primary_cd, tradetop_cd, rxmnem_cd)")
  ENDIF
 ENDIF
 IF ((request->therapeutic_class_id > 0))
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
 ENDIF
 SET ocnt = 0
 IF ((request->therapeutic_class_id > 0))
  SET oc_parse = build2(oc_parse," and oc.cki = 'MUL.ORD!d*'")
  SELECT INTO "NL:"
   FROM order_catalog oc,
    mltm_category_drug_xref m,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (m
    WHERE m.drug_identifier=substring(9,6,oc.cki)
     AND parser(class_string))
    JOIN (ocs
    WHERE parser(ocs_parse))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY oc.description, ocs.mnemonic, oc.catalog_cd
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1)
    IF (search_string > " ")
     stat = alterlist(searchtemp->orderables,ocnt), searchtemp->orderables[ocnt].code_value = oc
     .catalog_cd, searchtemp->orderables[ocnt].description = oc.description,
     searchtemp->orderables[ocnt].active_ind = oc.active_ind
    ELSEIF (exception_search_ind=1)
     stat = alterlist(exceptemp->orderables,ocnt), exceptemp->orderables[ocnt].code_value = oc
     .catalog_cd, exceptemp->orderables[ocnt].description = oc.description,
     exceptemp->orderables[ocnt].active_ind = oc.active_ind
    ELSE
     stat = alterlist(ordtemp->orderables,ocnt), ordtemp->orderables[ocnt].code_value = oc.catalog_cd,
     ordtemp->orderables[ocnt].description = oc.description,
     ordtemp->orderables[ocnt].active_ind = oc.active_ind
    ENDIF
    scnt = 0
   DETAIL
    scnt = (scnt+ 1)
    IF (search_string > " ")
     stat = alterlist(searchtemp->orderables[ocnt].synonyms,scnt), searchtemp->orderables[ocnt].
     synonyms[scnt].id = ocs.synonym_id, searchtemp->orderables[ocnt].synonyms[scnt].mnemonic = ocs
     .mnemonic,
     searchtemp->orderables[ocnt].synonyms[scnt].active_ind = ocs.active_ind, searchtemp->orderables[
     ocnt].synonyms[scnt].hide_flag = ocs.hide_flag, searchtemp->orderables[ocnt].synonyms[scnt].
     synonym_type.code_value = cv.code_value,
     searchtemp->orderables[ocnt].synonyms[scnt].synonym_type.display = cv.display, searchtemp->
     orderables[ocnt].synonyms[scnt].synonym_type.mean = cv.cdf_meaning
    ELSEIF (exception_search_ind=1)
     stat = alterlist(exceptemp->orderables[ocnt].synonyms,scnt), exceptemp->orderables[ocnt].
     synonyms[scnt].id = ocs.synonym_id, exceptemp->orderables[ocnt].synonyms[scnt].mnemonic = ocs
     .mnemonic,
     exceptemp->orderables[ocnt].synonyms[scnt].active_ind = ocs.active_ind, exceptemp->orderables[
     ocnt].synonyms[scnt].hide_flag = ocs.hide_flag, exceptemp->orderables[ocnt].synonyms[scnt].
     synonym_type.code_value = cv.code_value,
     exceptemp->orderables[ocnt].synonyms[scnt].synonym_type.display = cv.display, exceptemp->
     orderables[ocnt].synonyms[scnt].synonym_type.mean = cv.cdf_meaning
    ELSE
     stat = alterlist(ordtemp->orderables[ocnt].synonyms,scnt), ordtemp->orderables[ocnt].synonyms[
     scnt].id = ocs.synonym_id, ordtemp->orderables[ocnt].synonyms[scnt].mnemonic = ocs.mnemonic,
     ordtemp->orderables[ocnt].synonyms[scnt].active_ind = ocs.active_ind, ordtemp->orderables[ocnt].
     synonyms[scnt].hide_flag = ocs.hide_flag, ordtemp->orderables[ocnt].synonyms[scnt].synonym_type.
     code_value = cv.code_value,
     ordtemp->orderables[ocnt].synonyms[scnt].synonym_type.display = cv.display, ordtemp->orderables[
     ocnt].synonyms[scnt].synonym_type.mean = cv.cdf_meaning
    ENDIF
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
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY oc.description, ocs.mnemonic, oc.catalog_cd
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1)
    IF (search_string > " ")
     stat = alterlist(searchtemp->orderables,ocnt), searchtemp->orderables[ocnt].code_value = oc
     .catalog_cd, searchtemp->orderables[ocnt].description = oc.description,
     searchtemp->orderables[ocnt].active_ind = oc.active_ind
    ELSEIF (exception_search_ind=1)
     stat = alterlist(exceptemp->orderables,ocnt), exceptemp->orderables[ocnt].code_value = oc
     .catalog_cd, exceptemp->orderables[ocnt].description = oc.description,
     exceptemp->orderables[ocnt].active_ind = oc.active_ind
    ELSE
     stat = alterlist(ordtemp->orderables,ocnt), ordtemp->orderables[ocnt].code_value = oc.catalog_cd,
     ordtemp->orderables[ocnt].description = oc.description,
     ordtemp->orderables[ocnt].active_ind = oc.active_ind
    ENDIF
    scnt = 0
   DETAIL
    scnt = (scnt+ 1)
    IF (search_string > " ")
     stat = alterlist(searchtemp->orderables[ocnt].synonyms,scnt), searchtemp->orderables[ocnt].
     synonyms[scnt].id = ocs.synonym_id, searchtemp->orderables[ocnt].synonyms[scnt].mnemonic = ocs
     .mnemonic,
     searchtemp->orderables[ocnt].synonyms[scnt].active_ind = ocs.active_ind, searchtemp->orderables[
     ocnt].synonyms[scnt].hide_flag = ocs.hide_flag, searchtemp->orderables[ocnt].synonyms[scnt].
     synonym_type.code_value = cv.code_value,
     searchtemp->orderables[ocnt].synonyms[scnt].synonym_type.display = cv.display, searchtemp->
     orderables[ocnt].synonyms[scnt].synonym_type.mean = cv.cdf_meaning
    ELSEIF (exception_search_ind=1)
     stat = alterlist(exceptemp->orderables[ocnt].synonyms,scnt), exceptemp->orderables[ocnt].
     synonyms[scnt].id = ocs.synonym_id, exceptemp->orderables[ocnt].synonyms[scnt].mnemonic = ocs
     .mnemonic,
     exceptemp->orderables[ocnt].synonyms[scnt].active_ind = ocs.active_ind, exceptemp->orderables[
     ocnt].synonyms[scnt].hide_flag = ocs.hide_flag, exceptemp->orderables[ocnt].synonyms[scnt].
     synonym_type.code_value = cv.code_value,
     exceptemp->orderables[ocnt].synonyms[scnt].synonym_type.display = cv.display, exceptemp->
     orderables[ocnt].synonyms[scnt].synonym_type.mean = cv.cdf_meaning
    ELSE
     stat = alterlist(ordtemp->orderables[ocnt].synonyms,scnt), ordtemp->orderables[ocnt].synonyms[
     scnt].id = ocs.synonym_id, ordtemp->orderables[ocnt].synonyms[scnt].mnemonic = ocs.mnemonic,
     ordtemp->orderables[ocnt].synonyms[scnt].active_ind = ocs.active_ind, ordtemp->orderables[ocnt].
     synonyms[scnt].hide_flag = ocs.hide_flag, ordtemp->orderables[ocnt].synonyms[scnt].synonym_type.
     code_value = cv.code_value,
     ordtemp->orderables[ocnt].synonyms[scnt].synonym_type.display = cv.display, ordtemp->orderables[
     ocnt].synonyms[scnt].synonym_type.mean = cv.cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 IF (search_string > " ")
  DECLARE found_psn = i4
  SET movecnt = 0
  FOR (o = 1 TO ocnt)
    SET scnt = size(searchtemp->orderables[o].synonyms,5)
    SET found_ind = 0
    SET found_psn = findstring(search_string,cnvtupper(searchtemp->orderables[o].description))
    IF ((((request->search_type_flag="S")
     AND found_psn=1) OR ((request->search_type_flag="C")
     AND found_psn > 0)) )
     SET found_ind = 1
    ELSE
     FOR (s = 1 TO scnt)
      SET found_psn = findstring(search_string,cnvtupper(searchtemp->orderables[o].synonyms[s].
        mnemonic))
      IF ((((request->search_type_flag="S")
       AND found_psn=1) OR ((request->search_type_flag="C")
       AND found_psn > 0)) )
       SET found_ind = 1
       SET s = (scnt+ 1)
      ENDIF
     ENDFOR
    ENDIF
    IF (found_ind=1)
     SET movecnt = (movecnt+ 1)
     IF (exception_search_ind=1)
      SET stat = alterlist(exceptemp->orderables,movecnt)
      SET exceptemp->orderables[movecnt].code_value = searchtemp->orderables[o].code_value
      SET exceptemp->orderables[movecnt].description = searchtemp->orderables[o].description
      SET exceptemp->orderables[movecnt].active_ind = searchtemp->orderables[o].active_ind
      SET stat = alterlist(exceptemp->orderables[movecnt].synonyms,scnt)
     ELSE
      SET stat = alterlist(ordtemp->orderables,movecnt)
      SET ordtemp->orderables[movecnt].code_value = searchtemp->orderables[o].code_value
      SET ordtemp->orderables[movecnt].description = searchtemp->orderables[o].description
      SET ordtemp->orderables[movecnt].active_ind = searchtemp->orderables[o].active_ind
      SET stat = alterlist(ordtemp->orderables[movecnt].synonyms,scnt)
     ENDIF
     FOR (s = 1 TO scnt)
       IF (exception_search_ind=1)
        SET exceptemp->orderables[movecnt].synonyms[s].id = searchtemp->orderables[o].synonyms[s].id
        SET exceptemp->orderables[movecnt].synonyms[s].mnemonic = searchtemp->orderables[o].synonyms[
        s].mnemonic
        SET exceptemp->orderables[movecnt].synonyms[s].active_ind = searchtemp->orderables[o].
        synonyms[s].active_ind
        SET exceptemp->orderables[movecnt].synonyms[s].hide_flag = searchtemp->orderables[o].
        synonyms[s].hide_flag
        SET exceptemp->orderables[movecnt].synonyms[s].synonym_type.code_value = searchtemp->
        orderables[o].synonyms[s].synonym_type.code_value
        SET exceptemp->orderables[movecnt].synonyms[s].synonym_type.display = searchtemp->orderables[
        o].synonyms[s].synonym_type.display
        SET exceptemp->orderables[movecnt].synonyms[s].synonym_type.mean = searchtemp->orderables[o].
        synonyms[s].synonym_type.mean
       ELSE
        SET ordtemp->orderables[movecnt].synonyms[s].id = searchtemp->orderables[o].synonyms[s].id
        SET ordtemp->orderables[movecnt].synonyms[s].mnemonic = searchtemp->orderables[o].synonyms[s]
        .mnemonic
        SET ordtemp->orderables[movecnt].synonyms[s].active_ind = searchtemp->orderables[o].synonyms[
        s].active_ind
        SET ordtemp->orderables[movecnt].synonyms[s].hide_flag = searchtemp->orderables[o].synonyms[s
        ].hide_flag
        SET ordtemp->orderables[movecnt].synonyms[s].synonym_type.code_value = searchtemp->
        orderables[o].synonyms[s].synonym_type.code_value
        SET ordtemp->orderables[movecnt].synonyms[s].synonym_type.display = searchtemp->orderables[o]
        .synonyms[s].synonym_type.display
        SET ordtemp->orderables[movecnt].synonyms[s].synonym_type.mean = searchtemp->orderables[o].
        synonyms[s].synonym_type.mean
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SET ocnt = movecnt
 ENDIF
 IF (exception_search_ind=1)
  FOR (o = 1 TO ocnt)
   SET scnt = size(exceptemp->orderables[o].synonyms,5)
   IF (scnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = scnt),
      ocs_attr_xcptn oax
     PLAN (d)
      JOIN (oax
      WHERE (oax.synonym_id=exceptemp->orderables[o].synonyms[d.seq].id))
     DETAIL
      IF ((request->facility_code_value > 0)
       AND (oax.facility_cd=request->facility_code_value))
       exceptemp->orderables[o].synonyms[d.seq].fac_match_ind = 1
      ENDIF
      IF ((request->location_code_value > 0)
       AND (oax.flex_obj_cd=request->location_code_value)
       AND oax.flex_obj_type_cd=location_cd)
       exceptemp->orderables[o].synonyms[d.seq].loc_match_ind = 1
      ENDIF
      IF ((request->iv_event_code_value > 0)
       AND (oax.flex_obj_cd=request->iv_event_code_value)
       AND oax.flex_obj_type_cd=iv_event_cd)
       exceptemp->orderables[o].synonyms[d.seq].iv_event_match_ind = 1
      ENDIF
      IF ((request->route_code_value > 0)
       AND (oax.flex_obj_cd=request->route_code_value)
       AND oax.flex_obj_type_cd=route_cd)
       exceptemp->orderables[o].synonyms[d.seq].route_match_ind = 1
      ENDIF
      IF ((request->age_range_code_value > 0)
       AND (oax.flex_obj_cd=request->age_range_code_value)
       AND oax.flex_obj_type_cd=age_range_cd)
       exceptemp->orderables[o].synonyms[d.seq].age_range_match_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  SET ro = 0
  FOR (o = 1 TO ocnt)
    SET scnt = size(exceptemp->orderables[o].synonyms,5)
    SET nbr_of_qualifying_syns = 0
    FOR (s = 1 TO scnt)
      SET match_ind = 1
      IF ((request->facility_code_value > 0)
       AND (exceptemp->orderables[o].synonyms[s].fac_match_ind=0))
       SET match_ind = 0
      ENDIF
      IF ((request->location_code_value > 0)
       AND (exceptemp->orderables[o].synonyms[s].loc_match_ind=0))
       SET match_ind = 0
      ENDIF
      IF ((request->route_code_value > 0)
       AND (exceptemp->orderables[o].synonyms[s].route_match_ind=0))
       SET match_ind = 0
      ENDIF
      IF ((request->iv_event_code_value > 0)
       AND (exceptemp->orderables[o].synonyms[s].iv_event_match_ind=0))
       SET match_ind = 0
      ENDIF
      IF ((request->age_range_code_value > 0)
       AND (exceptemp->orderables[o].synonyms[s].age_range_match_ind=0))
       SET match_ind = 0
      ENDIF
      IF (match_ind=1)
       SET exceptemp->orderables[o].synonyms[s].move_ind = 1
       SET nbr_of_qualifying_syns = (nbr_of_qualifying_syns+ 1)
      ENDIF
    ENDFOR
    IF (nbr_of_qualifying_syns > 0)
     SET ro = (ro+ 1)
     SET stat = alterlist(ordtemp->orderables,ro)
     SET ordtemp->orderables[ro].code_value = exceptemp->orderables[o].code_value
     SET ordtemp->orderables[ro].description = exceptemp->orderables[o].description
     SET ordtemp->orderables[ro].active_ind = exceptemp->orderables[o].active_ind
     SET rs = 0
     FOR (s = 1 TO scnt)
       IF ((exceptemp->orderables[o].synonyms[s].move_ind=1))
        SET rs = (rs+ 1)
        SET stat = alterlist(ordtemp->orderables[ro].synonyms,rs)
        SET ordtemp->orderables[ro].synonyms[rs].id = exceptemp->orderables[o].synonyms[s].id
        SET ordtemp->orderables[ro].synonyms[rs].mnemonic = exceptemp->orderables[o].synonyms[s].
        mnemonic
        SET ordtemp->orderables[ro].synonyms[rs].active_ind = exceptemp->orderables[o].synonyms[s].
        active_ind
        SET ordtemp->orderables[ro].synonyms[rs].hide_flag = exceptemp->orderables[o].synonyms[s].
        hide_flag
        SET ordtemp->orderables[ro].synonyms[rs].synonym_type.code_value = exceptemp->orderables[o].
        synonyms[s].synonym_type.code_value
        SET ordtemp->orderables[ro].synonyms[rs].synonym_type.display = exceptemp->orderables[o].
        synonyms[s].synonym_type.display
        SET ordtemp->orderables[ro].synonyms[rs].synonym_type.mean = exceptemp->orderables[o].
        synonyms[s].synonym_type.mean
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SET ocnt = ro
 ENDIF
 SET total_ord_cnt = ocnt
 SET return_cnt = 0
 SET last_ord = 0
 IF ((request->include_facility_code_value=0)
  AND (request->exclude_facility_code_value=0))
  SET stat = alterlist(reply->orderables,ocnt)
  FOR (r = 1 TO ocnt)
    IF (last_ord=0)
     SET return_cnt = (return_cnt+ 1)
    ENDIF
    SET reply->orderables[r].code_value = ordtemp->orderables[r].code_value
    SET reply->orderables[r].description = ordtemp->orderables[r].description
    SET reply->orderables[r].active_ind = ordtemp->orderables[r].active_ind
    SET scnt = size(ordtemp->orderables[r].synonyms,5)
    SET stat = alterlist(reply->orderables[r].synonyms,scnt)
    FOR (s = 1 TO scnt)
      IF (last_ord=0)
       SET return_cnt = (return_cnt+ 1)
      ENDIF
      SET reply->orderables[r].synonyms[s].id = ordtemp->orderables[r].synonyms[s].id
      SET reply->orderables[r].synonyms[s].mnemonic = ordtemp->orderables[r].synonyms[s].mnemonic
      SET reply->orderables[r].synonyms[s].active_ind = ordtemp->orderables[r].synonyms[s].active_ind
      SET reply->orderables[r].synonyms[s].hide_flag = ordtemp->orderables[r].synonyms[s].hide_flag
      SET reply->orderables[r].synonyms[s].synonym_type.code_value = ordtemp->orderables[r].synonyms[
      s].synonym_type.code_value
      SET reply->orderables[r].synonyms[s].synonym_type.display = ordtemp->orderables[r].synonyms[s].
      synonym_type.display
      SET reply->orderables[r].synonyms[s].synonym_type.mean = ordtemp->orderables[r].synonyms[s].
      synonym_type.mean
    ENDFOR
    IF (last_ord=0
     AND return_cnt > max_cnt)
     IF (r=1)
      SET last_ord = r
     ELSE
      SET last_ord = (r - 1)
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF ((request->include_facility_code_value > 0)
  AND (request->exclude_facility_code_value=0))
  IF ((request->exclude_default_facility_ind=1))
   SET ofr_parse = build2("ofr.synonym_id = ordtemp->orderables[o]->synonyms[d.seq].id and ",
    "ofr.facility_cd = request->include_facility_code_value")
  ELSE
   SET ofr_parse = build2("ofr.synonym_id = ordtemp->orderables[o]->synonyms[d.seq].id and ",
    "(ofr.facility_cd = 0 or ofr.facility_cd = request->include_facility_code_value)")
  ENDIF
  SET ro = 0
  FOR (o = 1 TO ocnt)
    SET nbr_of_qualifying_syns = 0
    SET scnt = size(ordtemp->orderables[o].synonyms,5)
    IF (scnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = scnt),
       ocs_facility_r ofr
      PLAN (d)
       JOIN (ofr
       WHERE parser(ofr_parse))
      DETAIL
       ordtemp->orderables[o].synonyms[d.seq].move_ind = 1, nbr_of_qualifying_syns = (
       nbr_of_qualifying_syns+ 1)
      WITH nocounter
     ;end select
    ENDIF
    IF (nbr_of_qualifying_syns > 0)
     IF (last_ord=0)
      SET return_cnt = (return_cnt+ 1)
     ENDIF
     SET ro = (ro+ 1)
     SET stat = alterlist(reply->orderables,ro)
     SET reply->orderables[ro].code_value = ordtemp->orderables[o].code_value
     SET reply->orderables[ro].description = ordtemp->orderables[o].description
     SET reply->orderables[ro].active_ind = ordtemp->orderables[o].active_ind
     SET rs = 0
     FOR (s = 1 TO scnt)
       IF ((ordtemp->orderables[o].synonyms[s].move_ind=1))
        IF (last_ord=0)
         SET return_cnt = (return_cnt+ 1)
        ENDIF
        SET rs = (rs+ 1)
        SET stat = alterlist(reply->orderables[ro].synonyms,rs)
        SET reply->orderables[ro].synonyms[rs].id = ordtemp->orderables[o].synonyms[s].id
        SET reply->orderables[ro].synonyms[rs].mnemonic = ordtemp->orderables[o].synonyms[s].mnemonic
        SET reply->orderables[ro].synonyms[rs].active_ind = ordtemp->orderables[o].synonyms[s].
        active_ind
        SET reply->orderables[ro].synonyms[rs].hide_flag = ordtemp->orderables[o].synonyms[s].
        hide_flag
        SET reply->orderables[ro].synonyms[rs].synonym_type.code_value = ordtemp->orderables[o].
        synonyms[s].synonym_type.code_value
        SET reply->orderables[ro].synonyms[rs].synonym_type.display = ordtemp->orderables[o].
        synonyms[s].synonym_type.display
        SET reply->orderables[ro].synonyms[rs].synonym_type.mean = ordtemp->orderables[o].synonyms[s]
        .synonym_type.mean
       ENDIF
     ENDFOR
    ENDIF
    IF (last_ord=0
     AND return_cnt > max_cnt)
     IF (ro=1)
      SET last_ord = ro
     ELSE
      SET last_ord = (ro - 1)
     ENDIF
    ENDIF
  ENDFOR
  SET total_ord_cnt = ro
 ELSEIF ((request->include_facility_code_value=0)
  AND (request->exclude_facility_code_value > 0))
  SET ro = 0
  FOR (o = 1 TO ocnt)
    SET scnt = size(ordtemp->orderables[o].synonyms,5)
    SET nbr_of_qualifying_syns = 0
    IF (scnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = scnt),
       ocs_facility_r ofr
      PLAN (d)
       JOIN (ofr
       WHERE (ofr.synonym_id=ordtemp->orderables[o].synonyms[d.seq].id)
        AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->exclude_facility_code_value))) )
      DETAIL
       ordtemp->orderables[o].synonyms[d.seq].move_ind = 1, nbr_of_qualifying_syns = (
       nbr_of_qualifying_syns+ 1)
      WITH nocounter
     ;end select
    ENDIF
    IF (nbr_of_qualifying_syns=0)
     IF (last_ord=0)
      SET return_cnt = (return_cnt+ 1)
     ENDIF
     SET ro = (ro+ 1)
     SET stat = alterlist(reply->orderables,ro)
     SET reply->orderables[ro].code_value = ordtemp->orderables[o].code_value
     SET reply->orderables[ro].description = ordtemp->orderables[o].description
     SET reply->orderables[ro].active_ind = ordtemp->orderables[o].active_ind
     SET rs = 0
     FOR (s = 1 TO scnt)
       IF ((ordtemp->orderables[o].synonyms[s].move_ind=0))
        IF (last_ord=0)
         SET return_cnt = (return_cnt+ 1)
        ENDIF
        SET rs = (rs+ 1)
        SET stat = alterlist(reply->orderables[ro].synonyms,rs)
        SET reply->orderables[ro].synonyms[rs].id = ordtemp->orderables[o].synonyms[s].id
        SET reply->orderables[ro].synonyms[rs].mnemonic = ordtemp->orderables[o].synonyms[s].mnemonic
        SET reply->orderables[ro].synonyms[rs].active_ind = ordtemp->orderables[o].synonyms[s].
        active_ind
        SET reply->orderables[ro].synonyms[rs].hide_flag = ordtemp->orderables[o].synonyms[s].
        hide_flag
        SET reply->orderables[ro].synonyms[rs].synonym_type.code_value = ordtemp->orderables[o].
        synonyms[s].synonym_type.code_value
        SET reply->orderables[ro].synonyms[rs].synonym_type.display = ordtemp->orderables[o].
        synonyms[s].synonym_type.display
        SET reply->orderables[ro].synonyms[rs].synonym_type.mean = ordtemp->orderables[o].synonyms[s]
        .synonym_type.mean
       ENDIF
     ENDFOR
    ENDIF
    IF (last_ord=0
     AND return_cnt > max_cnt)
     IF (ro=1)
      SET last_ord = ro
     ELSE
      SET last_ord = (ro - 1)
     ENDIF
    ENDIF
  ENDFOR
  SET total_ord_cnt = ro
 ELSEIF ((request->include_facility_code_value > 0)
  AND (request->exclude_facility_code_value > 0))
  IF ((request->exclude_default_facility_ind=1))
   SET ofr_parse = build2("ofr.synonym_id = ordtemp->orderables[o]->synonyms[d.seq].id and ",
    "ofr.facility_cd = request->include_facility_code_value")
  ELSE
   SET ofr_parse = build2("ofr.synonym_id = ordtemp->orderables[o]->synonyms[d.seq].id and ",
    "(ofr.facility_cd = 0 or ofr.facility_cd = request->include_facility_code_value)")
  ENDIF
  SET fo = 0
  FOR (o = 1 TO ocnt)
    SET nbr_of_qualifying_syns = 0
    SET scnt = size(ordtemp->orderables[o].synonyms,5)
    IF (scnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = scnt),
       ocs_facility_r ofr
      PLAN (d)
       JOIN (ofr
       WHERE parser(ofr_parse))
      DETAIL
       ordtemp->orderables[o].synonyms[d.seq].move_ind = 1, nbr_of_qualifying_syns = (
       nbr_of_qualifying_syns+ 1)
      WITH nocounter
     ;end select
    ENDIF
    IF (nbr_of_qualifying_syns > 0)
     SET fo = (fo+ 1)
     SET stat = alterlist(factemp->orderables,fo)
     SET factemp->orderables[fo].code_value = ordtemp->orderables[o].code_value
     SET factemp->orderables[fo].description = ordtemp->orderables[o].description
     SET factemp->orderables[fo].active_ind = ordtemp->orderables[o].active_ind
     SET fs = 0
     FOR (s = 1 TO scnt)
       IF ((ordtemp->orderables[o].synonyms[s].move_ind=1))
        SET fs = (fs+ 1)
        SET stat = alterlist(factemp->orderables[fo].synonyms,fs)
        SET factemp->orderables[fo].synonyms[fs].id = ordtemp->orderables[o].synonyms[s].id
        SET factemp->orderables[fo].synonyms[fs].mnemonic = ordtemp->orderables[o].synonyms[s].
        mnemonic
        SET factemp->orderables[fo].synonyms[fs].active_ind = ordtemp->orderables[o].synonyms[s].
        active_ind
        SET factemp->orderables[fo].synonyms[fs].hide_flag = ordtemp->orderables[o].synonyms[s].
        hide_flag
        SET factemp->orderables[fo].synonyms[fs].synonym_type.code_value = ordtemp->orderables[o].
        synonyms[s].synonym_type.code_value
        SET factemp->orderables[fo].synonyms[fs].synonym_type.display = ordtemp->orderables[o].
        synonyms[s].synonym_type.display
        SET factemp->orderables[fo].synonyms[fs].synonym_type.mean = ordtemp->orderables[o].synonyms[
        s].synonym_type.mean
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SET faccnt = fo
  SET ro = 0
  FOR (o = 1 TO faccnt)
    SET scnt = size(factemp->orderables[o].synonyms,5)
    IF (scnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = scnt),
       ocs_facility_r ofr
      PLAN (d)
       JOIN (ofr
       WHERE (ofr.synonym_id=factemp->orderables[o].synonyms[d.seq].id)
        AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->exclude_facility_code_value))) )
      DETAIL
       factemp->orderables[o].synonyms[d.seq].move_ind = 1
      WITH nocounter
     ;end select
     SET nbr_of_qualifying_syns = 0
     FOR (s = 1 TO scnt)
       IF ((factemp->orderables[o].synonyms[s].move_ind=0))
        SET nbr_of_qualifying_syns = (nbr_of_qualifying_syns+ 1)
       ENDIF
     ENDFOR
    ENDIF
    IF (nbr_of_qualifying_syns > 0)
     IF (last_ord=0)
      SET return_cnt = (return_cnt+ 1)
     ENDIF
     SET ro = (ro+ 1)
     SET stat = alterlist(reply->orderables,ro)
     SET reply->orderables[ro].code_value = factemp->orderables[o].code_value
     SET reply->orderables[ro].description = factemp->orderables[o].description
     SET reply->orderables[ro].active_ind = factemp->orderables[o].active_ind
     SET rs = 0
     FOR (s = 1 TO scnt)
       IF ((factemp->orderables[o].synonyms[s].move_ind=0))
        IF (last_ord=0)
         SET return_cnt = (return_cnt+ 1)
        ENDIF
        SET rs = (rs+ 1)
        SET stat = alterlist(reply->orderables[ro].synonyms,rs)
        SET reply->orderables[ro].synonyms[rs].id = factemp->orderables[o].synonyms[s].id
        SET reply->orderables[ro].synonyms[rs].mnemonic = factemp->orderables[o].synonyms[s].mnemonic
        SET reply->orderables[ro].synonyms[rs].active_ind = factemp->orderables[o].synonyms[s].
        active_ind
        SET reply->orderables[ro].synonyms[rs].hide_flag = factemp->orderables[o].synonyms[s].
        hide_flag
        SET reply->orderables[ro].synonyms[rs].synonym_type.code_value = factemp->orderables[o].
        synonyms[s].synonym_type.code_value
        SET reply->orderables[ro].synonyms[rs].synonym_type.display = factemp->orderables[o].
        synonyms[s].synonym_type.display
        SET reply->orderables[ro].synonyms[rs].synonym_type.mean = factemp->orderables[o].synonyms[s]
        .synonym_type.mean
       ENDIF
     ENDFOR
    ENDIF
    IF (last_ord=0
     AND return_cnt > max_cnt)
     IF (ro=1)
      SET last_ord = ro
     ELSE
      SET last_ord = (ro - 1)
     ENDIF
    ENDIF
  ENDFOR
  SET total_ord_cnt = ro
 ENDIF
#exit_script
 IF (total_ord_cnt=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (total_ord_cnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
 IF (max_cnt > 0
  AND last_ord > 0)
  SET stat = alterlist(reply->orderables,last_ord)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
