CREATE PROGRAM bed_get_mos_pre_sent:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 description = vc
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
         4 sequence = i4
         4 usage_flag = i2
         4 encntr_group_code_value = f8
         4 dup_ind = i2
         4 ignore_ind = i2
         4 details[*]
           5 oe_field_id = f8
           5 field_disp_value = vc
           5 field_code_value = f8
           5 group_seq = i4
           5 field_seq = i4
           5 field_type_flag = i2
       3 mnemonic_type_meaning = vc
   1 more_ind = i2
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
     2 description = vc
     2 load_ind = i2
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 mnemonic_type_code_value = f8
       3 mnemonic_type_display = vc
       3 mnemonic_type_meaning = vc
       3 oe_format_id = f8
       3 load_ind = i2
       3 sentences[*]
         4 ext_identifier = vc
         4 os_id = f8
         4 full_display = vc
         4 display = vc
         4 load_ind = i2
         4 encntr_group_code_value = f8
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
 )
 FREE SET temp1
 RECORD temp1(
   1 sentences[*]
     2 syn_cki = vc
     2 ext_identifier = vc
     2 os_id = f8
     2 full_display = vc
     2 display = vc
     2 load_ind = i2
     2 encntr_group_code_value = f8
     2 oe_format_id = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_code_value = f8
     2 mnemonic_type_display = vc
     2 mnemonic_type_meaning = vc
     2 catalog_code_value = f8
     2 description = vc
     2 ignore_ind = i2
     2 dup_ind = i2
     2 nosort_details[*]
       3 oe_field_id = f8
       3 field_disp_value = vc
       3 field_code_value = f8
       3 oe_field_label = vc
       3 field_meaning = vc
       3 codeset = i4
       3 group_seq = i4
       3 field_seq = i4
       3 field_type_flag = i2
       3 clin_line_label = vc
       3 label_text = vc
       3 clin_suffix_ind = i2
       3 clin_line_ind = i2
       3 disp_yes_no_flag = i2
     2 sort_details[*]
       3 oe_field_id = f8
       3 field_disp_value = vc
       3 field_code_value = f8
       3 oe_field_label = vc
       3 field_meaning = vc
       3 codeset = i4
       3 group_seq = i4
       3 field_seq = i4
       3 field_type_flag = i2
       3 clin_line_label = vc
       3 label_text = vc
       3 clin_suffix_ind = i2
       3 clin_line_ind = i2
       3 disp_yes_no_flag = i2
 )
 FREE SET temp2
 RECORD temp2(
   1 sentences[*]
     2 syn_cki = vc
     2 ext_identifier = vc
     2 brext_identifier = vc
     2 os_id = f8
     2 full_display = vc
     2 display = vc
     2 load_ind = i2
     2 encntr_group_code_value = f8
     2 oe_format_id = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_code_value = f8
     2 mnemonic_type_display = vc
     2 mnemonic_type_meaning = vc
     2 catalog_code_value = f8
     2 description = vc
     2 ignore_ind = i2
     2 dup_ind = i2
     2 nosort_details[*]
       3 oe_field_id = f8
       3 field_disp_value = vc
       3 field_code_value = f8
       3 oe_field_label = vc
       3 field_meaning = vc
       3 codeset = i4
       3 group_seq = i4
       3 field_seq = i4
       3 field_type_flag = i2
       3 clin_line_label = vc
       3 label_text = vc
       3 clin_suffix_ind = i2
       3 clin_line_ind = i2
       3 disp_yes_no_flag = i2
     2 sort_details[*]
       3 oe_field_id = f8
       3 field_disp_value = vc
       3 field_code_value = f8
       3 oe_field_label = vc
       3 field_meaning = vc
       3 codeset = i4
       3 group_seq = i4
       3 field_seq = i4
       3 field_type_flag = i2
       3 clin_line_label = vc
       3 label_text = vc
       3 clin_suffix_ind = i2
       3 clin_line_ind = i2
       3 disp_yes_no_flag = i2
 )
 FREE SET oemap
 RECORD oemap(
   1 oef_id = f8
   1 fields[*]
     2 oe_field_id = f8
     2 oe_field_label = vc
     2 field_meaning = vc
     2 codeset = i4
     2 group_seq = i4
     2 field_seq = i4
     2 field_type_flag = i2
     2 clin_line_label = vc
     2 label_text = vc
     2 clin_suffix_ind = i2
     2 clin_line_ind = i2
     2 disp_yes_no_flag = i2
 )
 FREE SET codemap
 RECORD codemap(
   1 maps[*]
     2 codeset = i4
     2 codeval = vc
     2 map_code = f8
     2 map_table = vc
     2 map_disp = vc
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
 SET y_code_value = 0.0
 SET y_code_value = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET z_code_value = 0.0
 SET z_code_value = uar_get_code_by("MEANING",6011,"TRADEPROD")
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
 SET action_code = uar_get_code_by("MEANING",6003,"DISORDER")
 DECLARE oc_parse = vc
 SET oc_parse = concat(
  "oc.catalog_cd = ocs.catalog_cd and oc.orderable_type_flag in (0,1) and oc.active_ind = 1")
 IF ((request->catalog_code_value > 0))
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE (oc.catalog_cd=request->catalog_code_value))
   DETAIL
    oc_parse = concat(oc_parse," and trim(cnvtupper(oc.description)) > '",trim(cnvtupper(oc
       .description)),"'")
   WITH nocounter
  ;end select
 ENDIF
 DECLARE order_sentence = vc
 DECLARE order_sentence_full = vc
 DECLARE os_value = vc
 SET prn_id = 0.0
 SELECT INTO "nl:"
  FROM oe_field_meaning o
  WHERE o.oe_field_meaning="SCH/PRN"
  DETAIL
   prn_id = o.oe_field_meaning_id
  WITH nocounter
 ;end select
 SET mapcnt = 0
 SELECT INTO "nl:"
  FROM br_med_ordsent_map b,
   code_value cv
  PLAN (b
   WHERE b.parent_entity_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_value=b.parent_entity_id
    AND cv.active_ind=1)
  ORDER BY b.codeset, b.field_value
  HEAD REPORT
   mapcnt = 0, cnt = 0, stat = alterlist(codemap->maps,100)
  DETAIL
   mapcnt = (mapcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(codemap->maps,(mapcnt+ 100)), cnt = 1
   ENDIF
   codemap->maps[mapcnt].codeset = b.codeset, codemap->maps[mapcnt].codeval = b.field_value, codemap
   ->maps[mapcnt].map_code = b.parent_entity_id,
   codemap->maps[mapcnt].map_table = b.parent_entity_name, codemap->maps[mapcnt].map_disp = cv
   .display
  FOOT REPORT
   stat = alterlist(codemap->maps,mapcnt)
  WITH nocounter
 ;end select
 IF (mapcnt=0)
  GO TO exit_script
 ENDIF
 SET otcnt = 0
 SELECT INTO "nl:"
  FROM mltm_order_sent mos,
   mltm_order_sent_detail mosd
  PLAN (mos
   WHERE mos.external_identifier="MUL.OP!*"
    AND mos.usage_flag=2)
   JOIN (mosd
   WHERE mosd.external_identifier=mos.external_identifier)
  ORDER BY mos.external_identifier, mosd.oe_field_meaning
  HEAD REPORT
   ocnt = 0, otcnt = 0, stat = alterlist(temp1->sentences,100)
  HEAD mosd.external_identifier
   ocnt = (ocnt+ 1), otcnt = (otcnt+ 1)
   IF (ocnt > 100)
    stat = alterlist(temp1->sentences,(otcnt+ 100)), ocnt = 1
   ENDIF
   temp1->sentences[otcnt].ext_identifier = mos.external_identifier, temp1->sentences[otcnt].syn_cki
    = mos.synonym_cki, temp1->sentences[otcnt].load_ind = 1,
   dcnt = 0, dtcnt = 0, stat = alterlist(temp1->sentences[otcnt].nosort_details,10),
   dose_unit_ind = 0, sd_ind = 0, sdu_ind = 0,
   vd_ind = 0, vdu_ind = 0, ftd_ind = 0
  DETAIL
   dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
   IF (dcnt > 10)
    stat = alterlist(temp1->sentences[otcnt].nosort_details,(dtcnt+ 10)), dcnt = 1
   ENDIF
   temp1->sentences[otcnt].nosort_details[dtcnt].field_disp_value = mosd.oe_field_value, temp1->
   sentences[otcnt].nosort_details[dtcnt].field_meaning = mosd.oe_field_meaning
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
   stat = alterlist(temp1->sentences[otcnt].nosort_details,dtcnt)
   IF (((sd_ind=1
    AND sdu_ind != 1) OR (((vd_ind=1
    AND vdu_ind != 1) OR (((sd_ind != 1
    AND sdu_ind=1) OR (((vd_ind != 1
    AND vdu_ind=1) OR (sd_ind=0
    AND sdu_ind=0
    AND vd_ind=0
    AND vdu_ind=0
    AND ftd_ind != 1)) )) )) )) )
    temp1->sentences[otcnt].load_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(temp1->sentences,otcnt)
  WITH nocounter
 ;end select
 IF (otcnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(otcnt)),
   order_catalog_synonym ocs,
   order_catalog oc
  PLAN (d
   WHERE (temp1->sentences[d.seq].load_ind=1))
   JOIN (ocs
   WHERE (ocs.cki=temp1->sentences[d.seq].syn_cki)
    AND ((ocs.mnemonic_type_cd+ 0) IN (primary_code_value, brand_code_value, dcp_code_value,
   c_code_value, e_code_value,
   m_code_value, n_code_value, y_code_value, z_code_value))
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE parser(oc_parse))
  ORDER BY ocs.oe_format_id, ocs.synonym_id, temp1->sentences[d.seq].ext_identifier
  HEAD REPORT
   tcnt = 0, cnt = 0, stat = alterlist(temp2->sentences,100)
  DETAIL
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (tcnt > 100)
    stat = alterlist(temp2->sentences,(cnt+ 100)), tcnt = 1
   ENDIF
   temp2->sentences[cnt].catalog_code_value = oc.catalog_cd, temp2->sentences[cnt].description = oc
   .description, temp2->sentences[cnt].mnemonic = ocs.mnemonic,
   temp2->sentences[cnt].oe_format_id = ocs.oe_format_id, temp2->sentences[cnt].
   mnemonic_type_code_value = ocs.mnemonic_type_cd, temp2->sentences[cnt].synonym_id = ocs.synonym_id,
   temp2->sentences[cnt].syn_cki = temp1->sentences[d.seq].syn_cki, temp2->sentences[cnt].
   ext_identifier = temp1->sentences[d.seq].ext_identifier, temp2->sentences[cnt].brext_identifier =
   concat("BR",trim(temp1->sentences[d.seq].ext_identifier)),
   temp2->sentences[cnt].load_ind = 1, det_size = size(temp1->sentences[d.seq].nosort_details,5),
   stat = alterlist(temp2->sentences[cnt].nosort_details,det_size)
   FOR (x = 1 TO det_size)
    temp2->sentences[cnt].nosort_details[x].field_disp_value = temp1->sentences[d.seq].
    nosort_details[x].field_disp_value,temp2->sentences[cnt].nosort_details[x].field_meaning = temp1
    ->sentences[d.seq].nosort_details[x].field_meaning
   ENDFOR
  FOOT REPORT
   stat = alterlist(temp2->sentences,cnt)
  WITH nocounter
 ;end select
 SET stat = initrec(temp1)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   ord_cat_sent_r o,
   order_sentence os
  PLAN (d)
   JOIN (o
   WHERE (o.synonym_id=temp2->sentences[d.seq].synonym_id)
    AND o.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=o.order_sentence_id
    AND ((os.external_identifier=trim(temp2->sentences[d.seq].ext_identifier)) OR (os
   .external_identifier=trim(temp2->sentences[d.seq].brext_identifier))) )
  ORDER BY d.seq
  DETAIL
   temp2->sentences[d.seq].load_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_name_value b
  PLAN (d
   WHERE (temp2->sentences[d.seq].load_ind=1))
   JOIN (b
   WHERE b.br_nv_key1="MEDORDSENTIGN"
    AND (b.br_name=temp2->sentences[d.seq].ext_identifier)
    AND b.br_value=cnvtstring(temp2->sentences[d.seq].synonym_id)
    AND b.br_client_id=0)
  ORDER BY d.seq
  DETAIL
   IF ((request->return_ignored_ind=0))
    temp2->sentences[d.seq].load_ind = 0
   ENDIF
   temp2->sentences[d.seq].ignore_ind = 1
  WITH nocounter
 ;end select
 SET oecnt = 0
 SET prev_oef = 0.0
 FOR (x = 1 TO cnt)
   SET det_size = size(temp2->sentences[x].nosort_details,5)
   IF ((prev_oef != temp2->sentences[x].oe_format_id))
    SET stat = build_oefmap(temp2->sentences[x].oe_format_id)
    SET prev_oef = temp2->sentences[x].oe_format_id
   ENDIF
   FOR (y = 1 TO det_size)
     SET num = 0
     SET tindex = 0
     SET tindex = locatevalsort(num,1,oecnt,temp2->sentences[x].nosort_details[y].field_meaning,oemap
      ->fields[num].field_meaning)
     IF (tindex > 0)
      SET temp2->sentences[x].nosort_details[y].codeset = oemap->fields[tindex].codeset
      SET temp2->sentences[x].nosort_details[y].oe_field_id = oemap->fields[tindex].oe_field_id
      SET temp2->sentences[x].nosort_details[y].oe_field_label = oemap->fields[tindex].oe_field_label
      SET temp2->sentences[x].nosort_details[y].field_type_flag = oemap->fields[tindex].
      field_type_flag
      SET temp2->sentences[x].nosort_details[y].field_seq = oemap->fields[tindex].field_seq
      SET temp2->sentences[x].nosort_details[y].group_seq = oemap->fields[tindex].group_seq
      SET temp2->sentences[x].nosort_details[y].label_text = oemap->fields[tindex].label_text
      SET temp2->sentences[x].nosort_details[y].clin_line_label = oemap->fields[tindex].
      clin_line_label
      SET temp2->sentences[x].nosort_details[y].clin_suffix_ind = oemap->fields[tindex].
      clin_suffix_ind
      SET temp2->sentences[x].nosort_details[y].clin_line_ind = oemap->fields[tindex].clin_line_ind
      SET temp2->sentences[x].nosort_details[y].disp_yes_no_flag = oemap->fields[tindex].
      disp_yes_no_flag
     ELSE
      IF ((temp2->sentences[x].nosort_details[y].field_meaning != "SPECINX")
       AND (temp2->sentences[x].nosort_details[y].field_meaning != "DRUGFORM"))
       SET temp2->sentences[x].load_ind = 0
       IF ((temp2->sentences[x].oe_format_id > 0))
        SET bad_oe_cnt = size(bad_oe->oefs,5)
        SET bad_oe_cnt = (bad_oe_cnt+ 1)
        SET stat = alterlist(bad_oe->oefs,bad_oe_cnt)
        SET bad_oe->oefs[bad_oe_cnt].id = temp2->sentences[x].oe_format_id
        SET bad_oe->oefs[bad_oe_cnt].field_mean = temp2->sentences[x].nosort_details[y].field_meaning
       ENDIF
      ENDIF
     ENDIF
     IF ((temp2->sentences[x].nosort_details[y].codeset > 0))
      SET num = 0
      SET tindex = 0
      SET tindex = locatevalsort(num,1,mapcnt,temp2->sentences[x].nosort_details[y].codeset,codemap->
       maps[num].codeset,
       cnvtupper(temp2->sentences[x].nosort_details[y].field_disp_value),codemap->maps[num].codeval)
      IF (tindex > 0)
       SET temp2->sentences[x].nosort_details[y].field_code_value = codemap->maps[tindex].map_code
       SET temp2->sentences[x].nosort_details[y].field_disp_value = codemap->maps[tindex].map_disp
      ELSE
       SET temp2->sentences[x].load_ind = 0
      ENDIF
     ENDIF
   ENDFOR
   IF ((temp2->sentences[x].load_ind=1)
    AND det_size > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(det_size))
     PLAN (d)
     ORDER BY temp2->sentences[x].nosort_details[d.seq].group_seq, temp2->sentences[x].
      nosort_details[d.seq].field_seq
     HEAD REPORT
      stat = alterlist(temp2->sentences[x].sort_details,det_size), dtcnt = 0, order_sentence = "",
      order_sentence_full = "", os_value = "", gseq = 0
     DETAIL
      IF ((temp2->sentences[x].nosort_details[d.seq].oe_field_id=0)
       AND (((temp2->sentences[x].nosort_details[d.seq].field_meaning="SPECINX")) OR ((temp2->
      sentences[x].nosort_details[d.seq].field_meaning="DRUGFORM"))) )
       stat = alterlist(temp2->sentences[x].sort_details,(det_size - 1))
      ELSE
       dtcnt = (dtcnt+ 1), temp2->sentences[x].sort_details[dtcnt].clin_line_ind = temp2->sentences[x
       ].nosort_details[d.seq].clin_line_ind, temp2->sentences[x].sort_details[dtcnt].clin_line_label
        = temp2->sentences[x].nosort_details[d.seq].clin_line_label,
       temp2->sentences[x].sort_details[dtcnt].clin_suffix_ind = temp2->sentences[x].nosort_details[d
       .seq].clin_suffix_ind, temp2->sentences[x].sort_details[dtcnt].codeset = temp2->sentences[x].
       nosort_details[d.seq].codeset, temp2->sentences[x].sort_details[dtcnt].field_code_value =
       temp2->sentences[x].nosort_details[d.seq].field_code_value,
       temp2->sentences[x].sort_details[dtcnt].field_disp_value = temp2->sentences[x].nosort_details[
       d.seq].field_disp_value, temp2->sentences[x].sort_details[dtcnt].field_meaning = temp2->
       sentences[x].nosort_details[d.seq].field_meaning, temp2->sentences[x].sort_details[dtcnt].
       field_seq = temp2->sentences[x].nosort_details[d.seq].field_seq,
       temp2->sentences[x].sort_details[dtcnt].field_type_flag = temp2->sentences[x].nosort_details[d
       .seq].field_type_flag, temp2->sentences[x].sort_details[dtcnt].group_seq = temp2->sentences[x]
       .nosort_details[d.seq].group_seq, temp2->sentences[x].sort_details[dtcnt].label_text = temp2->
       sentences[x].nosort_details[d.seq].label_text,
       temp2->sentences[x].sort_details[dtcnt].oe_field_id = temp2->sentences[x].nosort_details[d.seq
       ].oe_field_id, temp2->sentences[x].sort_details[dtcnt].oe_field_label = temp2->sentences[x].
       nosort_details[d.seq].oe_field_label, temp2->sentences[x].sort_details[dtcnt].disp_yes_no_flag
        = temp2->sentences[x].nosort_details[d.seq].disp_yes_no_flag
       IF ((temp2->sentences[x].sort_details[dtcnt].field_type_flag=7))
        IF ((temp2->sentences[x].sort_details[dtcnt].field_disp_value IN ("YES", "1")))
         temp2->sentences[x].sort_details[dtcnt].field_disp_value = "Yes"
        ENDIF
        IF ((temp2->sentences[x].sort_details[dtcnt].field_disp_value IN ("NO", "0")))
         temp2->sentences[x].sort_details[dtcnt].field_disp_value = "No"
        ENDIF
       ENDIF
       os_value = temp2->sentences[x].sort_details[dtcnt].field_disp_value
       IF ((temp2->sentences[x].sort_details[dtcnt].field_type_flag=7))
        IF ((temp2->sentences[x].sort_details[dtcnt].field_disp_value="Yes"))
         IF ((temp2->sentences[x].sort_details[dtcnt].disp_yes_no_flag IN (0, 1)))
          os_value = temp2->sentences[x].sort_details[dtcnt].label_text
         ELSE
          os_value = ""
         ENDIF
        ELSEIF ((temp2->sentences[x].sort_details[dtcnt].field_disp_value="No"))
         IF ((temp2->sentences[x].sort_details[dtcnt].field_meaning="SCH/PRN"))
          os_value = ""
         ELSE
          IF ((temp2->sentences[x].sort_details[dtcnt].disp_yes_no_flag IN (0, 2)))
           os_value = temp2->sentences[x].sort_details[dtcnt].clin_line_label
          ELSE
           os_value = ""
          ENDIF
         ENDIF
        ENDIF
       ELSE
        IF ((temp2->sentences[x].sort_details[dtcnt].clin_line_label > " "))
         IF ((temp2->sentences[x].sort_details[dtcnt].clin_suffix_ind=1))
          os_value = concat(trim(temp2->sentences[x].sort_details[dtcnt].field_disp_value)," ",trim(
            temp2->sentences[x].sort_details[dtcnt].clin_line_label))
         ELSE
          os_value = concat(trim(temp2->sentences[x].sort_details[dtcnt].clin_line_label)," ",trim(
            temp2->sentences[x].sort_details[dtcnt].field_disp_value))
         ENDIF
        ENDIF
       ENDIF
       IF (dtcnt=1)
        first_add_to_new_group = 1, order_sentence_full = trim(os_value)
        IF ((temp2->sentences[x].sort_details[dtcnt].clin_line_ind=1))
         order_sentence = trim(os_value), first_add_to_new_group = 0
        ENDIF
        gseq = temp2->sentences[x].sort_details[dtcnt].group_seq
       ELSE
        IF (os_value > " ")
         IF ((gseq=temp2->sentences[x].sort_details[dtcnt].group_seq))
          order_sentence_full = concat(trim(order_sentence_full)," ",trim(os_value))
          IF ((temp2->sentences[x].sort_details[dtcnt].clin_line_ind=1))
           IF (first_add_to_new_group=1)
            order_sentence = concat(trim(order_sentence),", ",trim(os_value)), first_add_to_new_group
             = 0
           ELSE
            order_sentence = concat(trim(order_sentence)," ",trim(os_value))
           ENDIF
          ENDIF
         ELSE
          first_add_to_new_group = 1, order_sentence_full = concat(trim(order_sentence_full),", ",
           trim(os_value))
          IF ((temp2->sentences[x].sort_details[dtcnt].clin_line_ind=1))
           order_sentence = concat(trim(order_sentence),", ",trim(os_value)), first_add_to_new_group
            = 0
          ENDIF
          gseq = temp2->sentences[x].sort_details[dtcnt].group_seq
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     FOOT REPORT
      temp2->sentences[x].display = trim(order_sentence,3), temp2->sentences[x].full_display = trim(
       order_sentence_full,3)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    ord_cat_sent_r ocsr,
    order_sentence os
   PLAN (d
    WHERE (temp2->sentences[d.seq].load_ind=1))
    JOIN (ocsr
    WHERE (ocsr.synonym_id=temp2->sentences[d.seq].synonym_id)
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND ((os.oe_format_id+ 0)=temp2->sentences[d.seq].oe_format_id)
     AND os.usage_flag=2)
   DETAIL
    IF ((os.order_sentence_display_line=temp2->sentences[d.seq].display))
     temp2->sentences[d.seq].dup_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  FREE SET mill
  RECORD mill(
    1 details[*]
      2 field_disp_value = vc
      2 field_value = f8
      2 field_type_flag = i2
  )
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    ord_cat_sent_r ocsr,
    order_sentence os,
    order_sentence_detail osd,
    order_entry_fields oef,
    oe_format_fields off
   PLAN (d
    WHERE (temp2->sentences[d.seq].load_ind=1)
     AND (temp2->sentences[d.seq].dup_ind=0))
    JOIN (ocsr
    WHERE (ocsr.synonym_id=temp2->sentences[d.seq].synonym_id)
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND ((os.oe_format_id+ 0)=temp2->sentences[d.seq].oe_format_id)
     AND os.usage_flag=2)
    JOIN (osd
    WHERE osd.order_sentence_id=os.order_sentence_id)
    JOIN (oef
    WHERE oef.oe_field_id=osd.oe_field_id)
    JOIN (off
    WHERE off.oe_field_id=oef.oe_field_id
     AND off.action_type_cd=action_code
     AND ((off.oe_format_id+ 0)=temp2->sentences[d.seq].oe_format_id))
   ORDER BY d.seq, os.order_sentence_id, off.group_seq,
    off.field_seq
   HEAD os.order_sentence_id
    millcnt = 0
   DETAIL
    IF (off.clin_line_ind=1)
     millcnt = (millcnt+ 1), stat = alterlist(mill->details,millcnt), mill->details[millcnt].
     field_value = osd.oe_field_value,
     mill->details[millcnt].field_disp_value = osd.oe_field_display_value, mill->details[millcnt].
     field_type_flag = oef.field_type_flag
    ENDIF
   FOOT  os.order_sentence_id
    match_ind = 1, tempcnt = 0, tempcnt = size(temp2->sentences[d.seq].sort_details,5),
    tempidx = 0
    FOR (x = 1 TO millcnt)
      tempidx = (tempidx+ 1), found_idx = 0
      FOR (t = tempidx TO tempcnt)
        IF ((temp2->sentences[d.seq].sort_details[t].clin_line_ind=1))
         found_idx = t, tempidx = t, t = (tempcnt+ 1)
        ENDIF
      ENDFOR
      IF (found_idx > 0)
       IF ((mill->details[x].field_type_flag IN (1, 2)))
        IF ((mill->details[x].field_value != cnvtreal(cnvtalphanum(temp2->sentences[d.seq].
          sort_details[found_idx].field_disp_value))))
         match_ind = 0, x = (millcnt+ 1)
        ENDIF
       ELSEIF ((mill->details[x].field_type_flag=7))
        IF ((((mill->details[x].field_value=0)
         AND trim(temp2->sentences[d.seq].sort_details[found_idx].field_disp_value) != "No") OR ((
        mill->details[x].field_value=1)
         AND trim(temp2->sentences[d.seq].sort_details[found_idx].field_disp_value) != "Yes")) )
         match_ind = 0, x = (millcnt+ 1)
        ENDIF
       ELSE
        IF ((mill->details[x].field_disp_value != temp2->sentences[d.seq].sort_details[found_idx].
        field_disp_value))
         match_ind = 0, x = (millcnt+ 1)
        ENDIF
       ENDIF
      ELSE
       match_ind = 0, x = (millcnt+ 1)
      ENDIF
    ENDFOR
    IF (match_ind=1)
     temp2->sentences[d.seq].dup_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET sentence_cnt = 0
  SET sentence_tunc = 0
  DECLARE prev_disp = vc
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt))
   PLAN (d
    WHERE (temp2->sentences[d.seq].load_ind=1)
     AND (temp2->sentences[d.seq].dup_ind=0))
   ORDER BY cnvtupper(temp2->sentences[d.seq].description), temp2->sentences[d.seq].
    catalog_code_value, temp2->sentences[d.seq].synonym_id,
    temp2->sentences[d.seq].full_display
   HEAD REPORT
    prev_cat = 0.0, prev_syn = 0.0, prev_disp = "",
    sentence_cnt = 0, sentence_trunc = 0, rcnt = 0,
    rtot_cnt = 0, stat = alterlist(reply->orders,100), rstot_cnt = 0,
    rftot_cnt = 0
   DETAIL
    IF ((prev_cat != temp2->sentences[d.seq].catalog_code_value))
     rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
     IF (rcnt > 100)
      stat = alterlist(reply->orders,(rtot_cnt+ 100)), rcnt = 1
     ENDIF
     reply->orders[rtot_cnt].catalog_code_value = temp2->sentences[d.seq].catalog_code_value, reply->
     orders[rtot_cnt].description = temp2->sentences[d.seq].description, prev_cat = temp2->sentences[
     d.seq].catalog_code_value,
     prev_syn = 0.0, prev_disp = ""
     IF (rtot_cnt > 1)
      stat = alterlist(reply->orders[(rtot_cnt - 1)].synonyms[rstot_cnt].sentences,rftot_cnt), stat
       = alterlist(reply->orders[(rtot_cnt - 1)].synonyms,rstot_cnt), rftot_cnt = 0,
      rstot_cnt = 0
     ENDIF
     rscnt = 0, rstot_cnt = 0, stat = alterlist(reply->orders[rtot_cnt].synonyms,10)
    ENDIF
    IF ((prev_syn != temp2->sentences[d.seq].synonym_id))
     rscnt = (rscnt+ 1), rstot_cnt = (rstot_cnt+ 1)
     IF (rscnt > 10)
      stat = alterlist(reply->orders[rtot_cnt].synonyms,(rstot_cnt+ 10)), rscnt = 1
     ENDIF
     reply->orders[rtot_cnt].synonyms[rstot_cnt].mnemonic = temp2->sentences[d.seq].mnemonic, reply->
     orders[rtot_cnt].synonyms[rstot_cnt].mnemonic_type_code_value = temp2->sentences[d.seq].
     mnemonic_type_code_value, reply->orders[rtot_cnt].synonyms[rstot_cnt].mnemonic_type_meaning =
     uar_get_code_meaning(temp2->sentences[d.seq].mnemonic_type_code_value),
     reply->orders[rtot_cnt].synonyms[rstot_cnt].mnemonic_type_display = uar_get_code_display(temp2->
      sentences[d.seq].mnemonic_type_code_value), reply->orders[rtot_cnt].synonyms[rstot_cnt].
     synonym_id = temp2->sentences[d.seq].synonym_id, reply->orders[rtot_cnt].synonyms[rstot_cnt].
     oe_format_id = temp2->sentences[d.seq].oe_format_id
     IF (rstot_cnt > 1)
      stat = alterlist(reply->orders[rtot_cnt].synonyms[(rstot_cnt - 1)].sentences,rftot_cnt),
      rftot_cnt = 0
     ENDIF
     prev_syn = temp2->sentences[d.seq].synonym_id, prev_disp = "", rfcnt = 0,
     rftot_cnt = 0, stat = alterlist(reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences,10),
     det_size = 0
    ENDIF
    IF ((prev_disp != temp2->sentences[d.seq].full_display))
     rfcnt = (rfcnt+ 1), rftot_cnt = (rftot_cnt+ 1)
     IF (rfcnt > 10)
      stat = alterlist(reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences,(rftot_cnt+ 10)), rfcnt
       = 1
     ENDIF
     IF ((temp2->sentences[d.seq].ignore_ind=0))
      sentence_cnt = (sentence_cnt+ 1)
      IF (sentence_trunc=0
       AND sentence_cnt > 1000)
       sentence_trunc = rtot_cnt
      ENDIF
     ENDIF
     reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].display = temp2->sentences[d
     .seq].display, reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].dup_ind = temp2
     ->sentences[d.seq].dup_ind, reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].
     encntr_group_code_value = temp2->sentences[d.seq].encntr_group_code_value,
     reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].ext_identifier = temp2->
     sentences[d.seq].ext_identifier, reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt
     ].full_display = temp2->sentences[d.seq].full_display, reply->orders[rtot_cnt].synonyms[
     rstot_cnt].sentences[rftot_cnt].ignore_ind = temp2->sentences[d.seq].ignore_ind,
     reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].sequence = 0, reply->orders[
     rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].usage_flag = 2, det_size = size(temp2->
      sentences[d.seq].sort_details,5),
     stat = alterlist(reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].details,
      det_size)
     FOR (x = 1 TO det_size)
       reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].details[x].field_code_value
        = temp2->sentences[d.seq].sort_details[x].field_code_value, reply->orders[rtot_cnt].synonyms[
       rstot_cnt].sentences[rftot_cnt].details[x].field_disp_value = temp2->sentences[d.seq].
       sort_details[x].field_disp_value, reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[
       rftot_cnt].details[x].field_seq = temp2->sentences[d.seq].sort_details[x].field_seq,
       reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].details[x].field_type_flag =
       temp2->sentences[d.seq].sort_details[x].field_type_flag, reply->orders[rtot_cnt].synonyms[
       rstot_cnt].sentences[rftot_cnt].details[x].group_seq = temp2->sentences[d.seq].sort_details[x]
       .group_seq, reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences[rftot_cnt].details[x].
       oe_field_id = temp2->sentences[d.seq].sort_details[x].oe_field_id
     ENDFOR
     prev_disp = temp2->sentences[d.seq].full_display
    ENDIF
   FOOT REPORT
    IF (rftot_cnt > 0)
     stat = alterlist(reply->orders[rtot_cnt].synonyms[rstot_cnt].sentences,rftot_cnt)
    ENDIF
    IF (rstot_cnt > 0)
     stat = alterlist(reply->orders[rtot_cnt].synonyms,rstot_cnt)
    ENDIF
    IF (sentence_cnt > 1000)
     stat = alterlist(reply->orders,sentence_trunc), reply->more_ind = 1
    ELSE
     stat = alterlist(reply->orders,rtot_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
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
 SUBROUTINE build_oefmap(oef_id)
   SET stat = initrec(oemap)
   SET oecnt = 0
   SELECT INTO "nl:"
    FROM oe_field_meaning ofm,
     order_entry_fields oef,
     oe_format_fields off
    PLAN (off
     WHERE off.action_type_cd=action_code
      AND off.accept_flag IN (0, 1, 3)
      AND off.oe_format_id=oef_id)
     JOIN (oef
     WHERE oef.oe_field_id=off.oe_field_id)
     JOIN (ofm
     WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
    ORDER BY ofm.oe_field_meaning
    HEAD REPORT
     oecnt = 0, oetcnt = 0, stat = alterlist(oemap->fields,10),
     oemap->oef_id = oef_id
    HEAD ofm.oe_field_meaning
     oecnt = (oecnt+ 1), oetcnt = (oetcnt+ 1)
     IF (oetcnt > 10)
      stat = alterlist(oemap->fields,(oecnt+ 10)), oetcnt = 1
     ENDIF
     oemap->fields[oecnt].clin_line_ind = off.clin_line_ind, oemap->fields[oecnt].clin_line_label =
     off.clin_line_label, oemap->fields[oecnt].clin_suffix_ind = off.clin_suffix_ind,
     oemap->fields[oecnt].codeset = oef.codeset, oemap->fields[oecnt].field_meaning = ofm
     .oe_field_meaning, oemap->fields[oecnt].field_seq = off.field_seq,
     oemap->fields[oecnt].field_type_flag = oef.field_type_flag, oemap->fields[oecnt].group_seq = off
     .group_seq, oemap->fields[oecnt].label_text = off.label_text,
     oemap->fields[oecnt].oe_field_id = off.oe_field_id, oemap->fields[oecnt].oe_field_label = oef
     .description, oemap->fields[oecnt].disp_yes_no_flag = off.disp_yes_no_flag
    FOOT REPORT
     stat = alterlist(oemap->fields,oecnt)
    WITH nocounter
   ;end select
   RETURN(1.0)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
