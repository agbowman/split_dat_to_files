CREATE PROGRAM bed_get_cki_match:dba
 FREE SET reply
 RECORD reply(
   1 dlist[*]
     2 data_item_id = vc
     2 data_item_field_1 = vc
     2 data_item_field_2 = vc
     2 data_item_field_3 = vc
     2 data_item_field_4 = vc
     2 data_item_field_5 = vc
     2 data_item_field_6 = vc
     2 data_item_field_7 = vc
     2 data_item_field_8 = vc
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 data_item_id = vc
     2 long_desc = vc
     2 short_desc = vc
     2 mil_name = vc
     2 match_ind = i2
     2 use_ind = i2
     2 cki = vc
     2 cpt4 = vc
     2 loinc = vc
     2 match_type = vc
     2 match_value = vc
     2 mcnt = i4
     2 mqual[*]
       3 mil_name = vc
       3 match_ind = i2
       3 cki = vc
       3 cpt4 = vc
       3 loinc = vc
       3 match_type = vc
       3 match_value = vc
 )
 FREE SET temp2
 RECORD temp2(
   1 cnt = i4
   1 qual[*]
     2 data_item_id = vc
     2 long_desc = vc
     2 short_desc = vc
     2 mil_name = vc
     2 match_ind = i2
     2 use_ind = i2
     2 cki = vc
     2 cpt4 = vc
     2 loinc = vc
     2 match_type = vc
     2 match_value = vc
     2 mcnt = i4
     2 mqual[*]
       3 mil_name = vc
       3 match_ind = i2
       3 cki = vc
       3 cpt4 = vc
       3 loinc = vc
       3 match_type = vc
       3 match_value = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET mcnt = 0
 SET fcnt = size(request->flist,5)
 DECLARE catalog_type = vc
 DECLARE activity_type = vc
 DECLARE ocs_filter_string = vc
 DECLARE oc_filter_string = vc
 SET catalog_type_cd = 0.0
 SET activity_type_cd = 0.0
 IF (fcnt > 0)
  FOR (x = 1 TO fcnt)
    IF (x=1)
     IF ((request->flist[x].filter_type="CATALOG_TYPE"))
      SET catalog_type = trim(request->flist[x].filter_value)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=6000
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        catalog_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET ocs_filter_string = build("ocs.catalog_type_cd = ",catalog_type_cd)
      SET oc_filter_string = build("oc.catalog_type_cd = ",catalog_type_cd)
     ELSEIF ((request->flist[x].filter_type="ACTIVITY_TYPE"))
      SET activity_type = trim(request->flist[x].filter_value)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=106
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        activity_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET ocs_filter_string = build("ocs.activity_type_cd = ",activity_type_cd)
      SET oc_filter_string = build("oc.activity_type_cd = ",activity_type_cd)
     ENDIF
    ELSE
     IF ((request->flist[x].filter_type="CATALOG_TYPE"))
      SET catalog_type = trim(request->flist[x].filter_value)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=6000
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        catalog_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET ocs_filter_string = build(trim(ocs_filter_string)," and ocs.catalog_type_cd = ",
       catalog_type_cd)
      SET oc_filter_string = build(trim(oc_filter_string)," and oc.catalog_type_cd = ",
       catalog_type_cd)
     ELSEIF ((request->flist[x].filter_type="ACTIVITY_TYPE"))
      SET activity_type = trim(request->flist[x].filter_value)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=106
         AND (cv.display=request->flist[x].filter_value))
       DETAIL
        activity_type_cd = cv.code_value
       WITH nocounter
      ;end select
      SET ocs_filter_string = build(trim(ocs_filter_string)," and ocs.activity_type_cd = ",
       activity_type_cd)
      SET oc_filter_string = build(trim(oc_filter_string)," and oc.activity_type_cd = ",
       activity_type_cd)
     ENDIF
    ENDIF
  ENDFOR
 ELSE
  SET ocs_filter_string = "ocs.synonym_id > 0"
  SET oc_filter_string = "oc.catalog_cd > 0"
 ENDIF
 SELECT INTO "nl:"
  FROM br_cki_client_data b,
   br_cki_client_data_field f
  PLAN (b
   WHERE (b.client_id=request->client_id)
    AND (b.data_type_id=request->data_type_id))
   JOIN (f
   WHERE f.br_cki_client_data_id=b.br_cki_client_data_id)
  ORDER BY f.br_cki_client_data_id
  HEAD REPORT
   cnt = 0
  HEAD f.br_cki_client_data_id
   cnt = (cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->qual,cnt),
   temp->qual[cnt].match_ind = 0, temp->qual[cnt].use_ind = 1
  DETAIL
   IF (catalog_type > " ")
    IF (f.field_nbr=4)
     IF (f.field_content != catalog_type)
      temp->qual[cnt].use_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (activity_type > " ")
    IF (f.field_nbr=5)
     IF (f.field_content != activity_type)
      temp->qual[cnt].use_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (f.field_nbr=10)
    temp->qual[cnt].data_item_id = f.field_content
   ENDIF
   IF (f.field_nbr=2)
    temp->qual[cnt].long_desc = f.field_content
   ENDIF
   IF (f.field_nbr=3)
    temp->qual[cnt].short_desc = f.field_content
   ENDIF
   IF (f.field_nbr=7)
    temp->qual[cnt].cpt4 = f.field_content
   ENDIF
   IF (f.field_nbr=9)
    temp->qual[cnt].loinc = f.field_content
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   br_cki_match m
  PLAN (d)
   JOIN (m
   WHERE (m.client_id=request->client_id)
    AND (m.data_type_id=request->data_type_id)
    AND (m.data_item=temp->qual[d.seq].data_item_id))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].use_ind = 0
  WITH nocounter
 ;end select
 IF ((request->match_type_ind=1))
  SET primary_cd = 0.0
  SET dcp_cd = 0.0
  SET ancillary_cd = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=6011
     AND cv.cdf_meaning IN ("PRIMARY", "DCP", "ANCILLARY"))
   DETAIL
    IF (cv.cdf_meaning="PRIMARY")
     primary_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="DCP")
     dcp_cd = cv.code_value
    ELSEIF (cv.cdf_meaning="ANCILLARY")
     ancillary_cd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    order_catalog_synonym ocs,
    order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0)
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (ocs
    WHERE ((ocs.mnemonic_key_cap=cnvtupper(temp->qual[d.seq].long_desc)) OR (ocs.mnemonic_key_cap=
    cnvtupper(temp->qual[d.seq].short_desc)))
     AND ocs.mnemonic_type_cd IN (primary_cd, dcp_cd, ancillary_cd))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.concept_cki > " "
     AND oc.active_ind=1)
   ORDER BY d.seq
   HEAD oc.catalog_cd
    temp->qual[d.seq].mil_name = oc.primary_mnemonic, temp->qual[d.seq].cki = oc.concept_cki, temp->
    qual[d.seq].match_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_auto_oc_synonym ocs,
    br_auto_order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0)
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (ocs
    WHERE ((ocs.mnemonic_key_cap=cnvtupper(temp->qual[d.seq].long_desc)) OR (ocs.mnemonic_key_cap=
    cnvtupper(temp->qual[d.seq].short_desc)))
     AND ocs.mnemonic_type_cd IN (primary_cd, dcp_cd, ancillary_cd))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.concept_cki > " ")
   ORDER BY d.seq
   HEAD oc.catalog_cd
    temp->qual[d.seq].mil_name = oc.primary_mnemonic, temp->qual[d.seq].cki = oc.concept_cki, temp->
    qual[d.seq].match_ind = 1
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_other_names b,
    order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0)
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (b
    WHERE b.parent_entity_name="ORDER_CATALOG"
     AND ((b.alias_name_key_cap=cnvtupper(temp->qual[d.seq].long_desc)) OR (b.alias_name_key_cap=
    cnvtupper(temp->qual[d.seq].short_desc))) )
    JOIN (oc
    WHERE oc.catalog_cd=b.parent_entity_id
     AND oc.concept_cki > " "
     AND oc.active_ind=1)
   ORDER BY d.seq
   HEAD oc.catalog_cd
    temp->qual[d.seq].mil_name = oc.primary_mnemonic, temp->qual[d.seq].cki = oc.concept_cki, temp->
    qual[d.seq].match_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_other_names b,
    br_auto_order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0)
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (b
    WHERE b.parent_entity_name="BR_AUTO_ORDER_CATALOG"
     AND ((b.alias_name_key_cap=cnvtupper(temp->qual[d.seq].long_desc)) OR (b.alias_name_key_cap=
    cnvtupper(temp->qual[d.seq].short_desc))) )
    JOIN (oc
    WHERE oc.catalog_cd=b.parent_entity_id
     AND oc.concept_cki > " ")
   ORDER BY d.seq
   HEAD oc.catalog_cd
    temp->qual[d.seq].mil_name = oc.primary_mnemonic, temp->qual[d.seq].cki = oc.concept_cki, temp->
    qual[d.seq].match_ind = 1
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=1))
   ORDER BY temp->qual[d.seq].long_desc
   HEAD REPORT
    dcnt = 0
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->dlist,dcnt), reply->dlist[dcnt].data_item_id = temp->
    qual[d.seq].data_item_id,
    reply->dlist[dcnt].data_item_field_1 = temp->qual[d.seq].long_desc, reply->dlist[dcnt].
    data_item_field_2 = temp->qual[d.seq].short_desc, reply->dlist[dcnt].data_item_field_3 = temp->
    qual[d.seq].mil_name,
    reply->dlist[dcnt].cki = temp->qual[d.seq].cki
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->match_type_ind IN (2, 3)))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_other_names b,
    order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].use_ind=1))
    JOIN (b
    WHERE b.parent_entity_name="CODE_VALUE"
     AND b.alias_name_key_cap=cnvtupper(temp->qual[d.seq].long_desc))
    JOIN (oc
    WHERE oc.catalog_cd=b.parent_entity_id
     AND oc.concept_cki > " "
     AND oc.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="Alternate"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "Alternate", temp->qual[d.seq].mqual[mcnt].
     match_value = b.alias_name
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_other_names b,
    order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].use_ind=1))
    JOIN (b
    WHERE b.parent_entity_name="CODE_VALUE"
     AND b.alias_name_key_cap=cnvtupper(temp->qual[d.seq].short_desc))
    JOIN (oc
    WHERE oc.catalog_cd=b.parent_entity_id
     AND oc.concept_cki > " "
     AND oc.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="Alternate"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "Alternate", temp->qual[d.seq].mqual[mcnt].
     match_value = b.alias_name
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_other_names b,
    br_auto_order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].use_ind=1))
    JOIN (b
    WHERE b.parent_entity_name="CODE_VALUE"
     AND b.alias_name_key_cap=cnvtupper(temp->qual[d.seq].long_desc))
    JOIN (oc
    WHERE oc.catalog_cd=b.parent_entity_id
     AND oc.concept_cki > " ")
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="Alternate"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "Alternate", temp->qual[d.seq].mqual[mcnt].
     match_value = b.alias_name
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_other_names b,
    br_auto_order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].use_ind=1))
    JOIN (b
    WHERE b.parent_entity_name="CODE_VALUE"
     AND b.alias_name_key_cap=cnvtupper(temp->qual[d.seq].short_desc))
    JOIN (oc
    WHERE oc.catalog_cd=b.parent_entity_id
     AND oc.concept_cki > " ")
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="Alternate"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "Alternate", temp->qual[d.seq].mqual[mcnt].
     match_value = b.alias_name
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    cmt_cross_map c,
    order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].loinc > " ")
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (c
    WHERE c.target_concept_cki=concat("LOINC!",trim(temp->qual[d.seq].loinc))
     AND c.active_ind=1)
    JOIN (oc
    WHERE oc.concept_cki=c.concept_cki
     AND oc.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="LOINC"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "LOINC", temp->qual[d.seq].mqual[mcnt].match_value =
     temp->qual[d.seq].loinc
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_auto_order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].loinc > " ")
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (oc
    WHERE (oc.loinc=temp->qual[d.seq].loinc))
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="LOINC"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "LOINC", temp->qual[d.seq].mqual[mcnt].match_value =
     temp->qual[d.seq].loinc
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    cmt_cross_map c,
    order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].cpt4 > " ")
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (c
    WHERE c.target_concept_cki=concat("CPT4!",trim(temp->qual[d.seq].cpt4))
     AND c.active_ind=1)
    JOIN (oc
    WHERE oc.concept_cki=c.concept_cki
     AND oc.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="CPT4"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "CPT4", temp->qual[d.seq].mqual[mcnt].match_value =
     temp->qual[d.seq].cpt4
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->cnt),
    br_auto_order_catalog oc
   PLAN (d
    WHERE (temp->qual[d.seq].cpt4 > " ")
     AND (temp->qual[d.seq].use_ind=1))
    JOIN (oc
    WHERE (oc.cpt4=temp->qual[d.seq].cpt4))
   ORDER BY d.seq
   HEAD d.seq
    mcnt = size(temp->qual[d.seq].mqual,5)
   HEAD oc.catalog_cd
    oc_name = oc.primary_mnemonic, new_ind = 1
    FOR (q = 1 TO mcnt)
      IF ((oc_name=temp->qual[d.seq].mqual[q].mil_name)
       AND (temp->qual[d.seq].mqual[q].match_type="CPT4"))
       new_ind = 0
      ENDIF
    ENDFOR
    IF (new_ind=1)
     mcnt = (mcnt+ 1), temp->qual[d.seq].mcnt = mcnt, stat = alterlist(temp->qual[d.seq].mqual,mcnt),
     temp->qual[d.seq].mqual[mcnt].mil_name = oc.primary_mnemonic, temp->qual[d.seq].mqual[mcnt].cki
      = oc.concept_cki, temp->qual[d.seq].mqual[mcnt].match_ind = 1,
     temp->qual[d.seq].mqual[mcnt].match_type = "CPT4", temp->qual[d.seq].mqual[mcnt].match_value =
     temp->qual[d.seq].cpt4
    ENDIF
   WITH nocounter, skipbedrock = 1
  ;end select
  SET dcnt = 0
  FOR (x = 1 TO size(temp->qual,5))
    IF (size(temp->qual[x].mqual,5) <= 10)
     FOR (y = 1 TO size(temp->qual[x].mqual,5))
       IF ((temp->qual[x].mqual[y].match_ind=1))
        IF ((request->match_type_ind=2))
         IF (size(temp->qual[x].mqual,5)=1)
          SET dcnt = (dcnt+ 1)
          SET stat = alterlist(reply->dlist,dcnt)
          SET reply->dlist[dcnt].data_item_id = temp->qual[x].data_item_id
          SET reply->dlist[dcnt].data_item_field_1 = temp->qual[x].long_desc
          SET reply->dlist[dcnt].data_item_field_2 = temp->qual[x].short_desc
          SET reply->dlist[dcnt].data_item_field_3 = temp->qual[x].mqual[y].mil_name
          SET reply->dlist[dcnt].data_item_field_4 = temp->qual[x].mqual[y].match_type
          SET reply->dlist[dcnt].data_item_field_5 = temp->qual[x].mqual[y].match_value
          SET reply->dlist[dcnt].cki = temp->qual[x].mqual[y].cki
         ENDIF
        ELSEIF ((request->match_type_ind=3))
         IF (size(temp->qual[x].mqual,5) > 1)
          SET dcnt = (dcnt+ 1)
          SET stat = alterlist(reply->dlist,dcnt)
          SET reply->dlist[dcnt].data_item_id = temp->qual[x].data_item_id
          SET reply->dlist[dcnt].data_item_field_1 = temp->qual[x].long_desc
          SET reply->dlist[dcnt].data_item_field_2 = temp->qual[x].short_desc
          SET reply->dlist[dcnt].data_item_field_3 = temp->qual[x].mqual[y].mil_name
          SET reply->dlist[dcnt].data_item_field_4 = temp->qual[x].mqual[y].match_type
          SET reply->dlist[dcnt].data_item_field_5 = temp->qual[x].mqual[y].match_value
          SET reply->dlist[dcnt].cki = temp->qual[x].mqual[y].cki
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (size(reply->dlist,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
