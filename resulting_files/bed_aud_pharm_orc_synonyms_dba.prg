CREATE PROGRAM bed_aud_pharm_orc_synonyms:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 facilities[*]
      2 code_value = f8
    1 powerorders_synonyms_only_ind = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 oqual[*]
     2 orderable_desc = vc
     2 synonyms[*]
       3 synonym_type = vc
       3 synonym = vc
       3 oe_format = vc
       3 active_ind = vc
       3 hide_flag = vc
       3 rx_mask = vc
       3 titratable_ind = vc
       3 dnum = vc
       3 catalog_cd = f8
       3 cnum = vc
       3 synonym_id = f8
       3 mmdc = vc
       3 item_id = vc
       3 assoc_prod = vc
       3 prod_type = vc
 )
 DECLARE order_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6003
    AND cv.cdf_meaning="ORDER"
    AND cv.active_ind=1)
  DETAIL
   order_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE pharm_cat_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharm_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE pharm_act_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharm_act_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE desc_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=11000
    AND cv.cdf_meaning="DESC"
    AND cv.active_ind=1)
  DETAIL
   desc_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE system_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4062
    AND cv.cdf_meaning="SYSTEM"
    AND cv.active_ind=1)
  DETAIL
   system_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE inpatient_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4500
    AND cv.cdf_meaning="INPATIENT"
    AND cv.active_ind=1)
  DETAIL
   inpatient_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE primary_cd = f8
 DECLARE brand_cd = f8
 DECLARE dcp_cd = f8
 DECLARE dispdrug_cd = f8
 DECLARE ivname_cd = f8
 DECLARE generictop_cd = f8
 DECLARE tradetop_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning IN ("PRIMARY", "BRANDNAME", "DCP", "DISPDRUG", "IVNAME",
   "GENERICTOP", "TRADETOP")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="PRIMARY")
    primary_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BRANDNAME")
    brand_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DCP")
    dcp_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPDRUG")
    dispdrug_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVNAME")
    ivname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICTOP")
    generictop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADETOP")
    tradetop_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET fcnt = 0
 IF (validate(request->facilities[1].code_value))
  SET fcnt = size(request->facilities,5)
  IF (fcnt > 0)
   DECLARE ofr_parse = vc
   SET ofr_parse =
   " ofr.synonym_id = ocs.synonym_id and (ofr.facility_cd = 0 or ofr.facility_cd in ("
   FOR (f = 1 TO fcnt)
     IF (f=1)
      SET ofr_parse = build2(ofr_parse,cnvtstring(request->facilities[f].code_value))
     ELSE
      SET ofr_parse = build2(ofr_parse,",",cnvtstring(request->facilities[f].code_value))
     ENDIF
   ENDFOR
   SET ofr_parse = build2(ofr_parse,"))")
  ENDIF
 ENDIF
 SET powerorders_syns_only = 0
 IF (validate(request->powerorders_synonyms_only_ind))
  IF ((request->powerorders_synonyms_only_ind=1))
   SET powerorders_syns_only = 1
  ENDIF
 ENDIF
 DECLARE ocs_parse = vc
 SET ocs_parse = " ocs.catalog_cd = oc.catalog_cd and ocs.activity_type_cd = pharm_act_cd"
 IF (powerorders_syns_only=1)
  SET ocs_parse = build2(ocs_parse," and ocs.mnemonic_type_cd in (",cnvtstring(primary_cd),",",
   cnvtstring(brand_cd),
   ",",cnvtstring(dcp_cd),",",cnvtstring(dispdrug_cd),",",
   cnvtstring(ivname_cd),",",cnvtstring(generictop_cd),",",cnvtstring(tradetop_cd),
   ")")
  SET ocs_parse = build2(ocs_parse," and ocs.active_ind = 1 and ocs.hide_flag in (0,null)")
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  IF (fcnt > 0)
   SELECT INTO "NL:"
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     ocs_facility_r ofr,
     code_value cv
    PLAN (oc
     WHERE ((oc.catalog_type_cd+ 0)=pharm_cat_cd)
      AND ((oc.activity_type_cd+ 0)=pharm_act_cd)
      AND  NOT (oc.orderable_type_flag IN (6, 8))
      AND oc.active_ind=1)
     JOIN (ocs
     WHERE parser(ocs_parse))
     JOIN (ofr
     WHERE parser(ofr_parse))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd
      AND cv.active_ind=1)
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM order_catalog oc,
     order_catalog_synonym ocs,
     code_value cv
    PLAN (oc
     WHERE ((oc.catalog_type_cd+ 0)=pharm_cat_cd)
      AND ((oc.activity_type_cd+ 0)=pharm_act_cd)
      AND  NOT (oc.orderable_type_flag IN (6, 8))
      AND oc.active_ind=1)
     JOIN (ocs
     WHERE parser(ocs_parse))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd
      AND cv.active_ind=1)
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 25000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE rx_mask_string = vc
 SET ocnt = 0
 IF (fcnt > 0)
  SELECT INTO "NL:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    ocs_facility_r ofr,
    code_value cv,
    order_entry_format oef,
    order_catalog_item_r ocir,
    med_identifier mi,
    med_def_flex mdf,
    medication_definition md,
    code_value cv1
   PLAN (oc
    WHERE ((oc.catalog_type_cd+ 0)=pharm_cat_cd)
     AND ((oc.activity_type_cd+ 0)=pharm_act_cd)
     AND  NOT (oc.orderable_type_flag IN (6, 8))
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE parser(ocs_parse))
    JOIN (ofr
    WHERE parser(ofr_parse))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
    JOIN (oef
    WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
     AND oef.action_type_cd=outerjoin(order_cd))
    JOIN (ocir
    WHERE ocir.synonym_id=outerjoin(ocs.synonym_id))
    JOIN (mi
    WHERE mi.item_id=outerjoin(ocir.item_id)
     AND mi.med_identifier_type_cd=outerjoin(desc_cd)
     AND mi.med_product_id=outerjoin(0)
     AND mi.primary_ind=outerjoin(1)
     AND mi.pharmacy_type_cd=outerjoin(inpatient_cd))
    JOIN (mdf
    WHERE mdf.item_id=outerjoin(ocir.item_id)
     AND mdf.flex_type_cd=outerjoin(system_cd)
     AND mdf.pharmacy_type_cd=outerjoin(inpatient_cd))
    JOIN (md
    WHERE md.item_id=outerjoin(ocir.item_id))
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(mdf.pharmacy_type_cd)
     AND cv1.active_ind=outerjoin(1))
   ORDER BY cnvtupper(oc.description), cnvtupper(cv.display), cnvtupper(ocs.mnemonic),
    ocs.synonym_id
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1), stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].orderable_desc = oc
    .description,
    scnt = 1, stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
   HEAD ocs.synonym_id
    rx_mask_string = " ", first_one = 1
    IF (band(ocs.rx_mask,1) > 0)
     rx_mask_string = "Diluent"
    ENDIF
    IF (band(ocs.rx_mask,2) > 0)
     IF (first_one=1)
      rx_mask_string = "Additive", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Additive")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,4) > 0)
     IF (first_one=1)
      rx_mask_string = "Med", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Med")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,8) > 0)
     IF (first_one=1)
      rx_mask_string = "TPN", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", TPN")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,16) > 0)
     IF (first_one=1)
      rx_mask_string = "Sliding Scale", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Sliding Scale")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,32) > 0)
     IF (first_one=1)
      rx_mask_string = "Tapering Dose", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Tapering Dose")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,64) > 0)
     IF (first_one=1)
      rx_mask_string = "PCA Pump", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", PCA Pump")
     ENDIF
    ENDIF
    IF (ocs.mnemonic_type_cd=primary_cd)
     temp->oqual[ocnt].synonyms[1].synonym_type = cv.display, temp->oqual[ocnt].synonyms[1].synonym
      = ocs.mnemonic, temp->oqual[ocnt].synonyms[1].oe_format = oef.oe_format_name
     IF (ocs.active_ind=1)
      temp->oqual[ocnt].synonyms[1].active_ind = "X"
     ENDIF
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[1].hide_flag = "X"
     ENDIF
     temp->oqual[ocnt].synonyms[1].rx_mask = rx_mask_string
     IF (ocs.ingredient_rate_conversion_ind=1)
      temp->oqual[ocnt].synonyms[1].titratable_ind = "X"
     ENDIF
     len = textlen(oc.cki), temp->oqual[ocnt].synonyms[1].dnum = oc.cki, temp->oqual[ocnt].synonyms[1
     ].catalog_cd = oc.catalog_cd,
     len = textlen(ocs.cki), temp->oqual[ocnt].synonyms[1].cnum = ocs.cki, temp->oqual[ocnt].
     synonyms[1].synonym_id = ocs.synonym_id,
     len = textlen(md.cki), temp->oqual[ocnt].synonyms[1].mmdc = md.cki
     IF (mi.item_id > 0)
      temp->oqual[ocnt].synonyms[1].item_id = cnvtstring(mi.item_id)
     ELSE
      temp->oqual[ocnt].synonyms[1].item_id = " "
     ENDIF
     temp->oqual[ocnt].synonyms[1].assoc_prod = mi.value, temp->oqual[ocnt].synonyms[1].prod_type =
     cv1.display
    ELSE
     scnt = (scnt+ 1), stat = alterlist(temp->oqual[ocnt].synonyms,scnt), temp->oqual[ocnt].synonyms[
     scnt].synonym_type = cv.display,
     temp->oqual[ocnt].synonyms[scnt].synonym = ocs.mnemonic, temp->oqual[ocnt].synonyms[scnt].
     oe_format = oef.oe_format_name
     IF (ocs.active_ind=1)
      temp->oqual[ocnt].synonyms[scnt].active_ind = "X"
     ENDIF
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[scnt].hide_flag = "X"
     ENDIF
     temp->oqual[ocnt].synonyms[scnt].rx_mask = rx_mask_string
     IF (ocs.ingredient_rate_conversion_ind=1)
      temp->oqual[ocnt].synonyms[scnt].titratable_ind = "X"
     ENDIF
     len = textlen(oc.cki), temp->oqual[ocnt].synonyms[scnt].dnum = oc.cki, temp->oqual[ocnt].
     synonyms[scnt].catalog_cd = oc.catalog_cd,
     len = textlen(ocs.cki), temp->oqual[ocnt].synonyms[scnt].cnum = ocs.cki, temp->oqual[ocnt].
     synonyms[scnt].synonym_id = ocs.synonym_id,
     len = textlen(md.cki), temp->oqual[ocnt].synonyms[scnt].mmdc = md.cki
     IF (mi.item_id > 0)
      temp->oqual[ocnt].synonyms[scnt].item_id = cnvtstring(mi.item_id)
     ELSE
      temp->oqual[ocnt].synonyms[scnt].item_id = " "
     ENDIF
     temp->oqual[ocnt].synonyms[scnt].assoc_prod = mi.value, temp->oqual[ocnt].synonyms[scnt].
     prod_type = cv1.display
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv,
    order_entry_format oef,
    order_catalog_item_r ocir,
    med_identifier mi,
    med_def_flex mdf,
    medication_definition md,
    code_value cv1
   PLAN (oc
    WHERE ((oc.catalog_type_cd+ 0)=pharm_cat_cd)
     AND ((oc.activity_type_cd+ 0)=pharm_act_cd)
     AND  NOT (oc.orderable_type_flag IN (6, 8))
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE parser(ocs_parse))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
    JOIN (oef
    WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id)
     AND oef.action_type_cd=outerjoin(order_cd))
    JOIN (ocir
    WHERE ocir.synonym_id=outerjoin(ocs.synonym_id))
    JOIN (mi
    WHERE mi.item_id=outerjoin(ocir.item_id)
     AND mi.med_identifier_type_cd=outerjoin(desc_cd)
     AND mi.med_product_id=outerjoin(0)
     AND mi.primary_ind=outerjoin(1)
     AND mi.pharmacy_type_cd=outerjoin(inpatient_cd))
    JOIN (mdf
    WHERE mdf.item_id=outerjoin(ocir.item_id)
     AND mdf.flex_type_cd=outerjoin(system_cd)
     AND mdf.pharmacy_type_cd=outerjoin(inpatient_cd))
    JOIN (md
    WHERE md.item_id=outerjoin(ocir.item_id))
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(mdf.pharmacy_type_cd)
     AND cv1.active_ind=outerjoin(1))
   ORDER BY cnvtupper(oc.description), cnvtupper(cv.display), cnvtupper(ocs.mnemonic),
    ocs.synonym_id
   HEAD oc.catalog_cd
    ocnt = (ocnt+ 1), stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].orderable_desc = oc
    .description,
    scnt = 1, stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
   HEAD ocs.synonym_id
    rx_mask_string = " ", first_one = 1
    IF (band(ocs.rx_mask,1) > 0)
     rx_mask_string = "Diluent"
    ENDIF
    IF (band(ocs.rx_mask,2) > 0)
     IF (first_one=1)
      rx_mask_string = "Additive", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Additive")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,4) > 0)
     IF (first_one=1)
      rx_mask_string = "Med", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Med")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,8) > 0)
     IF (first_one=1)
      rx_mask_string = "TPN", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", TPN")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,16) > 0)
     IF (first_one=1)
      rx_mask_string = "Sliding Scale", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Sliding Scale")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,32) > 0)
     IF (first_one=1)
      rx_mask_string = "Tapering Dose", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", Tapering Dose")
     ENDIF
    ENDIF
    IF (band(ocs.rx_mask,64) > 0)
     IF (first_one=1)
      rx_mask_string = "PCA Pump", first_one = 0
     ELSE
      rx_mask_string = build2(rx_mask_string,", PCA Pump")
     ENDIF
    ENDIF
    IF (ocs.mnemonic_type_cd=primary_cd)
     temp->oqual[ocnt].synonyms[1].synonym_type = cv.display, temp->oqual[ocnt].synonyms[1].synonym
      = ocs.mnemonic, temp->oqual[ocnt].synonyms[1].oe_format = oef.oe_format_name
     IF (ocs.active_ind=1)
      temp->oqual[ocnt].synonyms[1].active_ind = "X"
     ENDIF
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[1].hide_flag = "X"
     ENDIF
     temp->oqual[ocnt].synonyms[1].rx_mask = rx_mask_string
     IF (ocs.ingredient_rate_conversion_ind=1)
      temp->oqual[ocnt].synonyms[1].titratable_ind = "X"
     ENDIF
     len = textlen(oc.cki), temp->oqual[ocnt].synonyms[1].dnum = oc.cki, temp->oqual[ocnt].synonyms[1
     ].catalog_cd = oc.catalog_cd,
     len = textlen(ocs.cki), temp->oqual[ocnt].synonyms[1].cnum = ocs.cki, temp->oqual[ocnt].
     synonyms[1].synonym_id = ocs.synonym_id,
     len = textlen(md.cki), temp->oqual[ocnt].synonyms[1].mmdc = md.cki
     IF (mi.item_id > 0)
      temp->oqual[ocnt].synonyms[1].item_id = cnvtstring(mi.item_id)
     ELSE
      temp->oqual[ocnt].synonyms[1].item_id = " "
     ENDIF
     temp->oqual[ocnt].synonyms[1].assoc_prod = mi.value, temp->oqual[ocnt].synonyms[1].prod_type =
     cv1.display
    ELSE
     scnt = (scnt+ 1), stat = alterlist(temp->oqual[ocnt].synonyms,scnt), temp->oqual[ocnt].synonyms[
     scnt].synonym_type = cv.display,
     temp->oqual[ocnt].synonyms[scnt].synonym = ocs.mnemonic, temp->oqual[ocnt].synonyms[scnt].
     oe_format = oef.oe_format_name
     IF (ocs.active_ind=1)
      temp->oqual[ocnt].synonyms[scnt].active_ind = "X"
     ENDIF
     IF (ocs.hide_flag=1)
      temp->oqual[ocnt].synonyms[scnt].hide_flag = "X"
     ENDIF
     temp->oqual[ocnt].synonyms[scnt].rx_mask = rx_mask_string
     IF (ocs.ingredient_rate_conversion_ind=1)
      temp->oqual[ocnt].synonyms[scnt].titratable_ind = "X"
     ENDIF
     len = textlen(oc.cki), temp->oqual[ocnt].synonyms[scnt].dnum = oc.cki, temp->oqual[ocnt].
     synonyms[scnt].catalog_cd = oc.catalog_cd,
     len = textlen(ocs.cki), temp->oqual[ocnt].synonyms[scnt].cnum = ocs.cki, temp->oqual[ocnt].
     synonyms[scnt].synonym_id = ocs.synonym_id,
     len = textlen(md.cki), temp->oqual[ocnt].synonyms[scnt].mmdc = md.cki
     IF (mi.item_id > 0)
      temp->oqual[ocnt].synonyms[scnt].item_id = cnvtstring(mi.item_id)
     ELSE
      temp->oqual[ocnt].synonyms[scnt].item_id = " "
     ENDIF
     temp->oqual[ocnt].synonyms[scnt].assoc_prod = mi.value, temp->oqual[ocnt].synonyms[scnt].
     prod_type = cv1.display
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,16)
 SET reply->collist[1].header_text = "Orderable Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Order Entry Format"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Active"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Hide"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Rx Mask"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Titratable"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Catalog CKI"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "catalog_cd"
 SET reply->collist[10].data_type = 2
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "CNUM"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "synonymn_id"
 SET reply->collist[12].data_type = 2
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Product CKI"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "item_id"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Associated Product"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Product Type"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (o = 1 TO ocnt)
  SET scnt = size(temp->oqual[o].synonyms,5)
  FOR (s = 1 TO scnt)
    IF ((temp->oqual[o].synonyms[s].synonym > " "))
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,16)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[o].orderable_desc
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[o].synonyms[s].synonym
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[o].synonyms[s].synonym_type
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->oqual[o].synonyms[s].oe_format
     SET reply->rowlist[row_nbr].celllist[5].string_value = temp->oqual[o].synonyms[s].active_ind
     SET reply->rowlist[row_nbr].celllist[6].string_value = temp->oqual[o].synonyms[s].hide_flag
     SET reply->rowlist[row_nbr].celllist[7].string_value = temp->oqual[o].synonyms[s].rx_mask
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->oqual[o].synonyms[s].titratable_ind
     SET reply->rowlist[row_nbr].celllist[9].string_value = temp->oqual[o].synonyms[s].dnum
     SET reply->rowlist[row_nbr].celllist[10].double_value = temp->oqual[o].synonyms[s].catalog_cd
     SET reply->rowlist[row_nbr].celllist[11].string_value = temp->oqual[o].synonyms[s].cnum
     SET reply->rowlist[row_nbr].celllist[12].double_value = temp->oqual[o].synonyms[s].synonym_id
     SET reply->rowlist[row_nbr].celllist[13].string_value = temp->oqual[o].synonyms[s].mmdc
     SET reply->rowlist[row_nbr].celllist[14].string_value = temp->oqual[o].synonyms[s].item_id
     SET reply->rowlist[row_nbr].celllist[15].string_value = temp->oqual[o].synonyms[s].assoc_prod
     SET reply->rowlist[row_nbr].celllist[16].string_value = temp->oqual[o].synonyms[s].prod_type
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pharm_orc_synonyms_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
