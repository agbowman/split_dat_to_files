CREATE PROGRAM bed_get_mltm_synonyms_b:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderables[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 cki = vc
      2 concept_cki = vc
      2 synonyms[*]
        3 cki = vc
        3 concept_cki = vc
        3 mnemonic = vc
        3 mnemonic_type
          4 code_value = f8
          4 display = vc
          4 meaning = vc
        3 hide_ind = i2
        3 order_entry_format
          4 format_id = f8
          4 name = vc
        3 med_admin_mask = i2
        3 ignore_ind = i2
      2 immunization_ind = i2
      2 dcp_clin_cat_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 FREE SET temp_reply
 RECORD temp_reply(
   1 orderables[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 cki = vc
     2 concept_cki = vc
     2 skip_ind = i2
     2 dcp_clin_cat_mean = vc
     2 synonyms[*]
       3 cki = vc
       3 concept_cki = vc
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
       3 hide_ind = i2
       3 order_entry_format
         4 format_id = f8
         4 name = vc
       3 med_admin_mask = i2
       3 ignore_ind = i2
 )
 FREE SET temp_rep
 RECORD temp_rep(
   1 orders[*]
     2 dnum = vc
 )
 DECLARE primary = f8 WITH public, noconstant(0.0)
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE sub_cnt = i4 WITH public, noconstant(0)
 DECLARE list_cnt = i4 WITH public, noconstant(0)
 DECLARE tot_cnt = i4 WITH public, noconstant(0)
 DECLARE primary_flag = i2 WITH public, noconstant(0)
 DECLARE serrmsg = c132 WITH public
 DECLARE ierrcode = i2 WITH public, noconstant(0)
 DECLARE return_ignore_ind = i2 WITH public, noconstant(0)
 DECLARE rep_cnt = i4 WITH public, noconstant(0)
 DECLARE tcat_code = f8 WITH public, noconstant(0.0)
 DECLARE qual_num = i4 WITH public, noconstant(0)
 DECLARE dnumlen = i4 WITH public, noconstant(0)
 DECLARE syn_size = i4 WITH public, noconstant(0)
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 FREE SET temp_ords
 RECORD temp_ords(
   1 ords[*]
     2 catalog_cki = vc
     2 synonym_id = f8
     2 cur_cki = vc
     2 mul_cki = vc
     2 mul_concept_cki = vc
     2 hide_ind = i2
     2 m_type = vc
     2 mnemonic_key = vc
     2 m_type_mean = vc
 )
 SET ierrcode = 0
 UPDATE  FROM br_name_value b
  SET b.br_name = " ", b.updt_cnt = (b.updt_cnt+ 1), b.updt_id = reqinfo->updt_id,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task, b.updt_applctx =
   reqinfo->updt_applctx
  WHERE b.br_nv_key1="MLTM_IGN_CONTENT"
   AND b.br_name="MLTM_ORDER_CATALOG_LOAD"
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  GO TO exit_script
 ENDIF
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    ocs.cki
    FROM order_catalog_synonym ocs
    WHERE ocs.cki=m.synonym_cki
     AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
     AND ocs.concept_cki > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
     AND m.synonym_concept_cki IN ("", " ", null)))
     AND ocs.cki > " "))))
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_ords->ords,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_ords->ords,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_ords->ords[tot_cnt].catalog_cki = m.catalog_cki, temp_ords->ords[tot_cnt].mul_cki = m
   .synonym_cki, temp_ords->ords[tot_cnt].mul_concept_cki = m.synonym_concept_cki,
   temp_ords->ords[tot_cnt].hide_ind = m.hide_ind, temp_ords->ords[tot_cnt].m_type = m.mnemonic_type,
   temp_ords->ords[tot_cnt].mnemonic_key = m.mnemonic_key_cap,
   temp_ords->ords[tot_cnt].m_type_mean = m.mnemonic_type_mean
  FOOT REPORT
   stat = alterlist(temp_ords->ords,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tot_cnt)),
    order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (d)
    JOIN (oc
    WHERE (oc.cki=temp_ords->ords[d.seq].catalog_cki))
    JOIN (ocs
    WHERE (ocs.mnemonic_key_cap=temp_ords->ords[d.seq].mnemonic_key)
     AND (ocs.hide_flag=temp_ords->ords[d.seq].hide_ind)
     AND ocs.catalog_cd=oc.catalog_cd
     AND  NOT ( EXISTS (
    (SELECT
     m.synonym_cki
     FROM mltm_order_catalog_load m
     WHERE m.synonym_cki=ocs.cki
      AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
      AND ocs.concept_cki > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
      AND m.synonym_concept_cki IN ("", " ", null))) ))))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    IF ((((cv.cdf_meaning=temp_ords->ords[d.seq].m_type_mean)) OR (cnvtupper(cv.display)=cnvtupper(
     temp_ords->ords[d.seq].m_type))) )
     temp_ords->ords[d.seq].synonym_id = ocs.synonym_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET return_ignore_ind = 0
 IF (validate(request->return_ignored_ind))
  SET return_ignore_ind = request->return_ignored_ind
 ELSE
  SET return_ignore_ind = 1
 ENDIF
 SET cnt = 0
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m,
   br_name_value b
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    ocs.cki
    FROM order_catalog_synonym ocs
    WHERE ocs.cki=m.synonym_cki
     AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
     AND ocs.concept_cki > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
     AND m.synonym_concept_cki IN ("", " ", null))) ))))
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("MLTM_IGN_CONTENT")
    AND b.br_name=outerjoin(m.synonym_concept_cki)
    AND b.br_value=outerjoin(m.synonym_cki))
  ORDER BY m.catalog_cki
  HEAD REPORT
   cnt = 0, tot_cnt = 0, match_ind = 1,
   stat = alterlist(temp_reply->orderables,200)
  HEAD m.catalog_cki
   sub_cnt = 0, list_cnt = 0
   IF (match_ind=1)
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 200)
     stat = alterlist(temp_reply->orderables,(cnt+ 200)), tot_cnt = 1
    ENDIF
   ELSE
    stat = alterlist(temp_reply->orderables[cnt].synonyms,0)
   ENDIF
   match_ind = 0, temp_reply->orderables[cnt].cki = m.catalog_cki, temp_reply->orderables[cnt].
   concept_cki = m.catalog_concept_cki,
   temp_reply->orderables[cnt].description = m.description, temp_reply->orderables[cnt].
   dcp_clin_cat_mean = m.dcp_clin_cat_mean, stat = alterlist(temp_reply->orderables[cnt].synonyms,200
    )
  DETAIL
   IF (((return_ignore_ind=0
    AND b.br_name_value_id=0) OR (return_ignore_ind=1)) )
    sub_cnt = (sub_cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 200)
     stat = alterlist(temp_reply->orderables[cnt].synonyms,(sub_cnt+ 200)), list_cnt = 1
    ENDIF
    temp_reply->orderables[cnt].synonyms[sub_cnt].cki = m.synonym_cki, temp_reply->orderables[cnt].
    synonyms[sub_cnt].concept_cki = m.synonym_concept_cki, temp_reply->orderables[cnt].synonyms[
    sub_cnt].mnemonic = m.mnemonic,
    temp_reply->orderables[cnt].synonyms[sub_cnt].mnemonic_type.display = m.mnemonic_type, temp_reply
    ->orderables[cnt].synonyms[sub_cnt].mnemonic_type.meaning = m.mnemonic_type_mean, temp_reply->
    orderables[cnt].synonyms[sub_cnt].hide_ind = m.hide_ind,
    temp_reply->orderables[cnt].synonyms[sub_cnt].order_entry_format.name = m.order_entry_format,
    temp_reply->orderables[cnt].synonyms[sub_cnt].med_admin_mask = m.rx_mask_nbr
    IF (b.br_name_value_id > 0)
     temp_reply->orderables[cnt].synonyms[sub_cnt].ignore_ind = 1
    ENDIF
    match_ind = 1
   ENDIF
  FOOT  m.catalog_cki
   stat = alterlist(temp_reply->orderables[cnt].synonyms,sub_cnt)
  FOOT REPORT
   IF (cnt > 0
    AND match_ind=0)
    cnt = (cnt - 1)
   ENDIF
   stat = alterlist(temp_reply->orderables,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET rep_cnt = 0
  SET stat = alterlist(reply->orderables,cnt)
  SET stat = alterlist(temp_rep->orders,cnt)
  FOR (x = 1 TO cnt)
    SET list_cnt = size(temp_reply->orderables[x].synonyms,5)
    SET primary_flag = 0
    IF (list_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       order_entry_format oef
      PLAN (d)
       JOIN (oef
       WHERE (oef.oe_format_name=temp_reply->orderables[x].synonyms[d.seq].order_entry_format.name))
      DETAIL
       temp_reply->orderables[x].synonyms[d.seq].order_entry_format.format_id = oef.oe_format_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       code_value cv
      PLAN (d
       WHERE (temp_reply->orderables[x].synonyms[d.seq].mnemonic_type.meaning > " "))
       JOIN (cv
       WHERE (cv.cdf_meaning=temp_reply->orderables[x].synonyms[d.seq].mnemonic_type.meaning)
        AND cv.code_set=6011
        AND cv.active_ind=1)
      DETAIL
       temp_reply->orderables[x].synonyms[d.seq].mnemonic_type.code_value = cv.code_value, temp_reply
       ->orderables[x].synonyms[d.seq].mnemonic_type.meaning = cv.cdf_meaning, temp_reply->
       orderables[x].synonyms[d.seq].mnemonic_type.display = cv.display
       IF (cv.code_value=primary)
        primary_flag = 1, temp_reply->orderables[x].display = temp_reply->orderables[x].synonyms[d
        .seq].mnemonic
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       code_value cv
      PLAN (d
       WHERE (temp_reply->orderables[x].synonyms[d.seq].mnemonic_type.meaning IN ("", " ", null)))
       JOIN (cv
       WHERE cnvtupper(cv.display)=cnvtupper(temp_reply->orderables[x].synonyms[d.seq].mnemonic_type.
        display)
        AND cv.code_set=6011
        AND cv.active_ind=1)
      DETAIL
       temp_reply->orderables[x].synonyms[d.seq].mnemonic_type.code_value = cv.code_value, temp_reply
       ->orderables[x].synonyms[d.seq].mnemonic_type.meaning = cv.cdf_meaning
       IF (cv.code_value=primary)
        primary_flag = 1, temp_reply->orderables[x].display = temp_reply->orderables[x].synonyms[d
        .seq].mnemonic
       ENDIF
      WITH nocounter
     ;end select
     IF (primary_flag=0)
      SET tcat_code = 0.0
      SET qual_num = 0
      SELECT INTO "nl:"
       FROM order_catalog oc,
        code_value cv
       PLAN (oc
        WHERE (oc.cki=temp_reply->orderables[x].cki)
         AND oc.active_ind=1)
        JOIN (cv
        WHERE cv.code_value=oc.catalog_cd
         AND cv.code_set=200
         AND cv.active_ind=1)
       DETAIL
        tcat_code = oc.catalog_cd, qual_num = (qual_num+ 1)
       WITH nocounter
      ;end select
      IF (qual_num=0)
       SET temp_reply->orderables[x].skip_ind = 1
      ELSEIF (qual_num > 1)
       SELECT INTO "nl:"
        FROM mltm_order_catalog_load m,
         order_catalog oc
        PLAN (m
         WHERE (m.catalog_cki=temp_reply->orderables[x].cki)
          AND cnvtupper(m.mnemonic_type)="PRIMARY")
         JOIN (oc
         WHERE oc.cki=m.catalog_cki
          AND oc.primary_mnemonic=m.mnemonic
          AND oc.active_ind=1)
        DETAIL
         tcat_code = oc.catalog_cd
        WITH nocounter
       ;end select
       IF (((curqual=0) OR (curqual > 1)) )
        SET temp_reply->orderables[x].skip_ind = 1
       ENDIF
      ENDIF
      IF ((temp_reply->orderables[x].skip_ind=0))
       SET list_cnt = (list_cnt+ 1)
       SET stat = alterlist(temp_reply->orderables[x].synonyms,list_cnt)
       SELECT INTO "nl:"
        FROM order_catalog oc,
         order_catalog_synonym ocs
        PLAN (oc
         WHERE oc.catalog_cd=tcat_code)
         JOIN (ocs
         WHERE ocs.catalog_cd=oc.catalog_cd
          AND ocs.mnemonic_type_cd=primary
          AND ocs.active_ind=1)
        DETAIL
         temp_reply->orderables[x].code_value = oc.catalog_cd, temp_reply->orderables[x].synonyms[
         list_cnt].cki = ocs.cki, temp_reply->orderables[x].synonyms[list_cnt].concept_cki = ocs
         .concept_cki,
         temp_reply->orderables[x].synonyms[list_cnt].hide_ind = ocs.hide_flag, temp_reply->
         orderables[x].synonyms[list_cnt].med_admin_mask = ocs.rx_mask, temp_reply->orderables[x].
         synonyms[list_cnt].mnemonic = ocs.mnemonic,
         temp_reply->orderables[x].synonyms[list_cnt].mnemonic_type.code_value = ocs.mnemonic_type_cd,
         temp_reply->orderables[x].synonyms[list_cnt].order_entry_format.format_id = ocs.oe_format_id
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM order_entry_format oef
        WHERE (oef.oe_format_id=temp_reply->orderables[x].synonyms[list_cnt].order_entry_format.
        format_id)
        DETAIL
         temp_reply->orderables[x].synonyms[list_cnt].order_entry_format.name = oef.oe_format_name
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE (cv.code_value=temp_reply->orderables[x].synonyms[list_cnt].mnemonic_type.code_value)
         AND cv.active_ind=1
        DETAIL
         temp_reply->orderables[x].synonyms[list_cnt].mnemonic_type.display = cv.display, temp_reply
         ->orderables[x].synonyms[list_cnt].mnemonic_type.meaning = cv.cdf_meaning
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
    SET dnumlen = 0
    IF ((temp_reply->orderables[x].skip_ind=0))
     SET rep_cnt = (rep_cnt+ 1)
     SET dnumlen = textlen(temp_reply->orderables[x].cki)
     SET temp_rep->orders[rep_cnt].dnum = substring(9,dnumlen,temp_reply->orderables[x].cki)
     SET reply->orderables[rep_cnt].cki = temp_reply->orderables[x].cki
     SET reply->orderables[rep_cnt].code_value = temp_reply->orderables[x].code_value
     SET reply->orderables[rep_cnt].concept_cki = temp_reply->orderables[x].concept_cki
     SET reply->orderables[rep_cnt].description = temp_reply->orderables[x].description
     SET reply->orderables[rep_cnt].display = temp_reply->orderables[x].display
     SET reply->orderables[rep_cnt].dcp_clin_cat_mean = temp_reply->orderables[x].dcp_clin_cat_mean
     SET syn_size = size(temp_reply->orderables[x].synonyms,5)
     SET stat = alterlist(reply->orderables[rep_cnt].synonyms,syn_size)
     FOR (y = 1 TO syn_size)
       SET reply->orderables[rep_cnt].synonyms[y].cki = temp_reply->orderables[x].synonyms[y].cki
       SET reply->orderables[rep_cnt].synonyms[y].concept_cki = temp_reply->orderables[x].synonyms[y]
       .concept_cki
       SET reply->orderables[rep_cnt].synonyms[y].hide_ind = temp_reply->orderables[x].synonyms[y].
       hide_ind
       SET reply->orderables[rep_cnt].synonyms[y].ignore_ind = temp_reply->orderables[x].synonyms[y].
       ignore_ind
       SET reply->orderables[rep_cnt].synonyms[y].med_admin_mask = temp_reply->orderables[x].
       synonyms[y].med_admin_mask
       SET reply->orderables[rep_cnt].synonyms[y].mnemonic = temp_reply->orderables[x].synonyms[y].
       mnemonic
       SET reply->orderables[rep_cnt].synonyms[y].mnemonic_type.code_value = temp_reply->orderables[x
       ].synonyms[y].mnemonic_type.code_value
       SET reply->orderables[rep_cnt].synonyms[y].mnemonic_type.display = temp_reply->orderables[x].
       synonyms[y].mnemonic_type.display
       SET reply->orderables[rep_cnt].synonyms[y].mnemonic_type.meaning = temp_reply->orderables[x].
       synonyms[y].mnemonic_type.meaning
       SET reply->orderables[rep_cnt].synonyms[y].order_entry_format.format_id = temp_reply->
       orderables[x].synonyms[y].order_entry_format.format_id
       SET reply->orderables[rep_cnt].synonyms[y].order_entry_format.name = temp_reply->orderables[x]
       .synonyms[y].order_entry_format.name
     ENDFOR
    ENDIF
  ENDFOR
  SET stat = alterlist(reply->orderables,rep_cnt)
  SET stat = alterlist(temp_rep->orders,rep_cnt)
  IF (rep_cnt > 0)
   DECLARE cat_parse_txt = vc
   DECLARE drug_cat_id = f8
   DECLARE immunization_ind = i2
   SET drug_cat_id = 0.0
   SELECT INTO "nl:"
    FROM mltm_drug_categories mdc
    WHERE cnvtupper(mdc.category_name)="IMMUNOLOGIC AGENTS"
    DETAIL
     drug_cat_id = mdc.multum_category_id
    WITH nocounter
   ;end select
   SET cat_parse_txt = "x.multum_category_id IN ("
   SELECT INTO "nl:"
    FROM mltm_category_sub_xref mcs
    WHERE mcs.multum_category_id=drug_cat_id
    DETAIL
     cat_parse_txt = build(cat_parse_txt,mcs.sub_category_id,",")
    WITH nocounter
   ;end select
   SET cat_parse_txt = build(cat_parse_txt,drug_cat_id,")")
   SET immunization_ind = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(rep_cnt)),
     mltm_drug_name m,
     mltm_drug_name_map mm,
     mltm_category_drug_xref x
    PLAN (d)
     JOIN (mm
     WHERE (mm.drug_identifier=temp_rep->orders[d.seq].dnum)
      AND mm.function_id=16)
     JOIN (m
     WHERE m.drug_synonym_id=mm.drug_synonym_id)
     JOIN (x
     WHERE x.drug_identifier=mm.drug_identifier
      AND parser(cat_parse_txt))
    ORDER BY d.seq
    DETAIL
     reply->orderables[d.seq].immunization_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (cnt > 0
  AND error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="N")
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
