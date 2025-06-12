CREATE PROGRAM bed_get_datamart_defaults_b:dba
 FREE SET reply
 RECORD reply(
   1 filter[*]
     2 br_datamart_filter_id = f8
     2 default[*]
       3 code_value = f8
       3 display = vc
       3 unique_identifier = vc
       3 cv_display = vc
       3 values[*]
         4 result_type_flag = i2
         4 qualifier_flag = i2
         4 result_value = vc
         4 result_id = f8
         4 br_datamart_filter_id = f8
       3 details[*]
         4 br_datamart_filter_id = f8
         4 fields[*]
           5 oe_field_meaning_id = f8
           5 oe_field_meaning = vc
           5 oe_field_description = vc
           5 cki = vc
           5 detail_value = vc
           5 code_value = f8
       3 group_name = vc
       3 mpage_param_mean = vc
       3 mpage_param_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET dcnt = 0
 SET fcnt = size(request->filter,5)
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE ptcare_cd = f8
 SET ptcare_cd = uar_get_code_by("MEANING",400,"PTCARE")
 DECLARE alpha_resp_cd = f8
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=401
   AND cv.cdf_meaning="ALPHA RESPON"
   AND cv.active_ind=1
  DETAIL
   alpha_resp_cd = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->filter,fcnt)
 FOR (x = 1 TO fcnt)
   SET reply->filter[x].br_datamart_filter_id = request->filter[x].br_datamart_filter_id
   SET problem_ind = 0
   SET procedure_ind = 0
   SET code_ind = 0
   SET nomen_ind = 0
   SET powerplan_ind = 0
   SET order_ind = 0
   SET group_ind = 0
   SET mpage_sect_ind = 0
   SET defcnt = 0
   SET syn_ind = 0
   SET outcome_ind = 0
   SET edu_instr_ind = 0
   SET prob_reltn_ind = 0
   SET yes_no_ind = 0
   SET numeric_ind = 0
   SET hme_stat_ind = 0
   SET link_entry_ind = 0
   SET nomencltr_ind = 0
   SELECT INTO "nl:"
    FROM br_datamart_filter f,
     br_datamart_filter_category fc
    PLAN (f
     WHERE (f.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id))
     JOIN (fc
     WHERE fc.filter_category_mean=f.filter_category_mean)
    DETAIL
     IF (fc.filter_category_type_mean IN ("CODE_SET", "CODE_SET_SHARED"))
      code_ind = 1
     ENDIF
     IF (fc.filter_category_type_mean="NOMENCLATURE")
      nomen_ind = 1
     ENDIF
     IF (fc.filter_category_type_mean="POWERPLAN")
      powerplan_ind = 1
     ENDIF
     IF (fc.filter_category_type_mean="ORDER")
      order_ind = 1
     ENDIF
     IF (f.filter_category_mean="CE_GROUP")
      group_ind = 1
     ENDIF
     IF (f.filter_category_mean="MP_SECT_PARAMS")
      mpage_sect_ind = 1
     ENDIF
     IF (f.filter_category_mean="PROBLEM")
      problem_ind = 1
     ENDIF
     IF (f.filter_category_mean="PROCEDURE")
      procedure_ind = 1
     ENDIF
     IF (f.filter_category_mean="SYNONYM")
      syn_ind = 1
     ENDIF
     IF (f.filter_category_mean IN ("OUTCOME_VENUE_IP", "OUTCOME_VENUE_OR"))
      outcome_ind = 1
     ENDIF
     IF (f.filter_category_mean="ED_INSTRUCTIONS")
      edu_instr_ind = 1
     ENDIF
     IF (f.filter_category_mean="PROBLEM_RELTN")
      problem_ind = 1, prob_reltn_ind = 1
     ENDIF
     IF (f.filter_category_mean="NUMERIC_VALUE")
      numeric_ind = 1
     ENDIF
     IF (f.filter_category_mean="YES_NO")
      yes_no_ind = 1
     ENDIF
     IF (f.filter_category_mean="HME_SAT")
      hme_stat_ind = 1
     ENDIF
     IF (f.filter_category_mean="LINK_ENTRY")
      link_entry_ind = 1
     ENDIF
     IF (f.filter_category_mean="NOMENCLATURE")
      nomencltr_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET dcnt = 0
   IF (mpage_sect_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_report_filter_r f,
      br_datamart_report_default r
     PLAN (f
      WHERE (f.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id))
      JOIN (r
      WHERE r.br_datamart_report_id=f.br_datamart_report_id)
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].mpage_param_mean = r.mpage_param_mean,
      reply->filter[x].default[dcnt].mpage_param_value = r.mpage_param_value
     WITH nocounter
    ;end select
   ENDIF
   IF (code_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      dummyt d1,
      code_value c
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
       AND b.code_set > 0
       AND b.result_type_flag IN (0, null))
      JOIN (d1)
      JOIN (c
      WHERE c.code_set=b.code_set
       AND ((cnvtupper(c.display)=cnvtupper(b.cv_display)
       AND c.display > " ") OR (((cnvtupper(c.description)=cnvtupper(b.cv_description)
       AND c.description > " ") OR (((c.cdf_meaning=b.unique_identifier
       AND c.cdf_meaning > " ") OR (((c.concept_cki=b.unique_identifier
       AND c.concept_cki > " ") OR (c.cki=b.unique_identifier
       AND c.cki > " ")) )) )) ))
       AND c.active_ind=1)
     DETAIL
      IF (b.unique_identifier IN ("", " ", null))
       IF (((cnvtupper(c.display)=cnvtupper(b.cv_display)) OR (cnvtupper(c.description)=cnvtupper(b
        .cv_description))) )
        dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
        dcnt].code_value = c.code_value,
        reply->filter[x].default[dcnt].display = c.display, reply->filter[x].default[dcnt].
        unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
        .cv_display
       ENDIF
      ELSE
       dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
       dcnt].code_value = c.code_value,
       reply->filter[x].default[dcnt].display = c.display, reply->filter[x].default[dcnt].
       unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
       .cv_display
      ENDIF
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (group_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      dummyt d1,
      code_value c
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
       AND b.code_set > 0
       AND b.result_type_flag IN (0, null))
      JOIN (d1)
      JOIN (c
      WHERE c.code_set=b.code_set
       AND ((cnvtupper(c.display)=cnvtupper(b.group_ce_name)) OR (c.concept_cki=b
      .group_ce_concept_cki))
       AND c.active_ind=1)
     ORDER BY b.br_datamart_default_id
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].code_value = c.code_value,
      reply->filter[x].default[dcnt].display = c.display, reply->filter[x].default[dcnt].
      unique_identifier = b.group_ce_concept_cki, reply->filter[x].default[dcnt].cv_display = b
      .group_ce_name,
      reply->filter[x].default[dcnt].group_name = b.group_name
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (nomen_ind=1)
    IF (problem_ind=0
     AND procedure_ind=0
     AND nomencltr_ind=0)
     SELECT INTO "nl:"
      FROM br_datamart_default b,
       nomenclature n
      PLAN (b
       WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
        AND b.result_type_flag IN (0, null)
        AND b.cv_description > " ")
       JOIN (n
       WHERE n.source_string_keycap=cnvtupper(b.cv_description)
        AND n.source_string_keycap > " "
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      DETAIL
       dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
       dcnt].code_value = n.nomenclature_id
       IF (n.short_string > " ")
        reply->filter[x].default[dcnt].display = n.short_string
       ELSE
        reply->filter[x].default[dcnt].display = n.source_string
       ENDIF
       reply->filter[x].default[dcnt].unique_identifier = b.unique_identifier
       IF (b.cv_display > " ")
        reply->filter[x].default[dcnt].cv_display = b.cv_display
       ELSE
        reply->filter[x].default[dcnt].cv_display = b.cv_description
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (problem_ind=0
     AND procedure_ind=0
     AND nomencltr_ind=0)
     SELECT INTO "nl:"
      FROM br_datamart_default b,
       nomenclature n
      PLAN (b
       WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
        AND b.result_type_flag IN (0, null)
        AND b.cv_display > " ")
       JOIN (n
       WHERE n.source_vocabulary_cd=ptcare_cd
        AND cnvtupper(n.short_string)=cnvtupper(b.cv_display)
        AND n.short_string > " "
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      DETAIL
       found = 0
       FOR (z = 1 TO size(reply->filter[x].default,5))
         IF ((reply->filter[x].default[z].code_value=n.nomenclature_id))
          found = 1
         ENDIF
       ENDFOR
       IF (found=0)
        dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
        dcnt].code_value = n.nomenclature_id
        IF (n.short_string > " ")
         reply->filter[x].default[dcnt].display = n.short_string
        ELSE
         reply->filter[x].default[dcnt].display = n.source_string
        ENDIF
        reply->filter[x].default[dcnt].unique_identifier = b.unique_identifier
        IF (b.cv_display > " ")
         reply->filter[x].default[dcnt].cv_display = b.cv_display
        ELSE
         reply->filter[x].default[dcnt].cv_display = b.cv_description
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ELSEIF (nomencltr_ind=1)
     SELECT INTO "nl:"
      FROM br_datamart_default b,
       nomenclature n
      PLAN (b
       WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
        AND b.result_type_flag IN (0, null)
        AND b.unique_identifier > " ")
       JOIN (n
       WHERE ((n.concept_identifier=b.unique_identifier
        AND n.concept_identifier > " ") OR (n.concept_cki=b.unique_identifier
        AND n.concept_cki > " "))
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      DETAIL
       found = 0
       FOR (z = 1 TO size(reply->filter[x].default,5))
         IF ((reply->filter[x].default[z].code_value=n.nomenclature_id))
          found = 1
         ENDIF
       ENDFOR
       IF (found=0)
        dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
        dcnt].code_value = n.nomenclature_id
        IF (n.short_string > " ")
         reply->filter[x].default[dcnt].display = n.short_string
        ELSE
         reply->filter[x].default[dcnt].display = n.source_string
        ENDIF
        reply->filter[x].default[dcnt].unique_identifier = b.unique_identifier
        IF (b.cv_display > " ")
         reply->filter[x].default[dcnt].cv_display = b.cv_display
        ELSE
         reply->filter[x].default[dcnt].cv_display = b.cv_description
        ENDIF
        IF (prob_reltn_ind=1)
         stat = alterlist(reply->filter[x].default[dcnt].values,1), reply->filter[x].default[dcnt].
         values[1].result_value = b.result_value
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM br_datamart_default b,
       nomenclature n
      PLAN (b
       WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
        AND b.result_type_flag IN (0, null)
        AND b.unique_identifier > " ")
       JOIN (n
       WHERE n.concept_cki=b.unique_identifier
        AND n.concept_cki > " "
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      DETAIL
       found = 0
       FOR (z = 1 TO size(reply->filter[x].default,5))
         IF ((reply->filter[x].default[z].code_value=n.nomenclature_id))
          found = 1
         ENDIF
       ENDFOR
       IF (found=0)
        dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
        dcnt].code_value = n.nomenclature_id
        IF (n.short_string > " ")
         reply->filter[x].default[dcnt].display = n.short_string
        ELSE
         reply->filter[x].default[dcnt].display = n.source_string
        ENDIF
        reply->filter[x].default[dcnt].unique_identifier = b.unique_identifier
        IF (b.cv_display > " ")
         reply->filter[x].default[dcnt].cv_display = b.cv_display
        ELSE
         reply->filter[x].default[dcnt].cv_display = b.cv_description
        ENDIF
        IF (prob_reltn_ind=1)
         stat = alterlist(reply->filter[x].default[dcnt].values,1), reply->filter[x].default[dcnt].
         values[1].result_value = b.result_value
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (order_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      dummyt d1,
      order_catalog o
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
       AND b.result_type_flag IN (0, null))
      JOIN (d1)
      JOIN (o
      WHERE ((cnvtupper(o.description)=cnvtupper(b.cv_description)) OR (((cnvtupper(o
       .primary_mnemonic)=cnvtupper(b.cv_display)) OR (((o.concept_cki=b.unique_identifier) OR (o.cki
      =b.unique_identifier)) )) ))
       AND o.active_ind=1)
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].code_value = o.catalog_cd,
      reply->filter[x].default[dcnt].display = o.primary_mnemonic, reply->filter[x].default[dcnt].
      unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
      .cv_display
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (powerplan_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      dummyt d1,
      pathway_catalog p
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
       AND b.result_type_flag IN (0, null))
      JOIN (d1)
      JOIN (p
      WHERE ((p.description_key=cnvtupper(b.cv_description)) OR (((p.description_key=cnvtupper(b
       .cv_display)) OR (p.concept_cki=b.unique_identifier)) ))
       AND p.active_ind=1)
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].code_value = p.pathway_catalog_id,
      reply->filter[x].default[dcnt].display = p.description, reply->filter[x].default[dcnt].
      unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
      .cv_display
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (syn_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      dummyt d1,
      order_catalog_synonym ocs
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
       AND b.result_type_flag IN (0, null))
      JOIN (d1)
      JOIN (ocs
      WHERE ((ocs.cki=b.unique_identifier) OR (ocs.mnemonic_key_cap=cnvtupper(b.cv_display)))
       AND ocs.active_ind=1)
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].code_value = ocs.synonym_id,
      reply->filter[x].default[dcnt].display = ocs.mnemonic, reply->filter[x].default[dcnt].
      unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
      .cv_display
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (outcome_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      dummyt d1,
      code_value cv,
      discrete_task_assay dta
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id))
      JOIN (d1)
      JOIN (cv
      WHERE cv.concept_cki=b.unique_identifier
       AND cv.active_ind=1)
      JOIN (dta
      WHERE dta.task_assay_cd=cv.code_value
       AND dta.active_ind=1)
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].code_value = dta.task_assay_cd,
      reply->filter[x].default[dcnt].display = dta.mnemonic, reply->filter[x].default[dcnt].
      unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
      .cv_display,
      stat = alterlist(reply->filter[x].default[dcnt].values,1), reply->filter[x].default[dcnt].
      values[1].result_value = b.result_value
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (edu_instr_ind=1)
    FREE SET ptemp
    RECORD ptemp(
      1 quals[*]
        2 search_txt = vc
    )
    SET dcnt = 0
    SELECT INTO "nl:"
     FROM br_datamart_default b
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id))
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), stat = alterlist(ptemp->
       quals,dcnt),
      ptemp->quals[dcnt].search_txt = concat(trim(cnvtupper(b.unique_identifier)),"*"), reply->
      filter[x].default[dcnt].unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt]
      .cv_display = b.cv_display
     WITH nocounter
    ;end select
    DECLARE parse_txt = vc
    FOR (pt = 1 TO dcnt)
     SET parse_txt = concat("cnvtupper(p.key_doc_ident)='",ptemp->quals[pt].search_txt,"'")
     SELECT INTO "nl:"
      FROM pat_ed_reltn p
      PLAN (p
       WHERE parser(parse_txt)
        AND p.refr_text_id > 0
        AND p.active_ind=1)
      DETAIL
       reply->filter[x].default[pt].code_value = p.pat_ed_reltn_id, reply->filter[x].default[pt].
       display = p.pat_ed_reltn_desc
      WITH nocounter
     ;end select
    ENDFOR
    SET stat = initrec(ptemp)
   ENDIF
   SET defcnt = size(reply->filter[x].default,5)
   SET vcnt = 0
   IF (defcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(defcnt)),
      br_datamart_filter f,
      br_datamart_filter f2,
      br_datamart_default b,
      nomenclature n
     PLAN (d)
      JOIN (f
      WHERE (f.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id))
      JOIN (f2
      WHERE f2.br_datamart_category_id=f.br_datamart_category_id
       AND f2.br_datamart_filter_id != f.br_datamart_filter_id
       AND f2.filter_seq=f.filter_seq
       AND f2.filter_category_mean IN ("EVENT_NOMEN", "DTA_NOMEN"))
      JOIN (b
      WHERE b.br_datamart_filter_id=f2.br_datamart_filter_id
       AND (b.cv_display=reply->filter[x].default[d.seq].cv_display)
       AND b.result_type_flag > 0)
      JOIN (n
      WHERE n.source_string=outerjoin(b.result_value)
       AND n.source_vocabulary_cd=outerjoin(ptcare_cd)
       AND n.active_ind=outerjoin(1)
       AND n.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND n.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
       AND n.principle_type_cd=outerjoin(alpha_resp_cd))
     ORDER BY d.seq
     HEAD d.seq
      vcnt = 0
     DETAIL
      vcnt = (vcnt+ 1), stat = alterlist(reply->filter[x].default[d.seq].values,vcnt), reply->filter[
      x].default[d.seq].values[vcnt].result_type_flag = b.result_type_flag,
      reply->filter[x].default[d.seq].values[vcnt].qualifier_flag = b.qualifier_flag, reply->filter[x
      ].default[d.seq].values[vcnt].result_value = b.result_value, reply->filter[x].default[d.seq].
      values[vcnt].result_id = n.nomenclature_id,
      reply->filter[x].default[d.seq].values[vcnt].br_datamart_filter_id = b.br_datamart_filter_id
     WITH nocounter
    ;end select
   ENDIF
   SET ocnt = 0
   IF (defcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(defcnt)),
      br_datamart_filter f,
      br_datamart_filter f2,
      br_datamart_default b,
      br_datamart_default_detail dd,
      oe_field_meaning o
     PLAN (d)
      JOIN (f
      WHERE (f.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
       AND f.filter_category_mean="ORDER")
      JOIN (f2
      WHERE f2.br_datamart_category_id=f.br_datamart_category_id
       AND f2.br_datamart_filter_id != f.br_datamart_filter_id
       AND f2.filter_seq=f.filter_seq
       AND f2.filter_category_mean="ORDER_DETAILS")
      JOIN (b
      WHERE b.br_datamart_filter_id=f2.br_datamart_filter_id
       AND (b.cv_display=reply->filter[x].default[d.seq].cv_display)
       AND b.order_detail_ind=1)
      JOIN (dd
      WHERE dd.br_datamart_default_id=b.br_datamart_default_id)
      JOIN (o
      WHERE o.oe_field_meaning=dd.oe_field_meaning)
     ORDER BY d.seq
     HEAD d.seq
      ocnt = 0, fcnt = 0
     HEAD b.br_datamart_default_id
      fcnt = 0, ocnt = (ocnt+ 1), stat = alterlist(reply->filter[x].default[d.seq].details,ocnt),
      reply->filter[x].default[d.seq].details[ocnt].br_datamart_filter_id = b.br_datamart_filter_id
     DETAIL
      fcnt = (fcnt+ 1), stat = alterlist(reply->filter[x].default[d.seq].details[ocnt].fields,fcnt),
      reply->filter[x].default[d.seq].details[ocnt].fields[fcnt].oe_field_meaning_id = o
      .oe_field_meaning_id,
      reply->filter[x].default[d.seq].details[ocnt].fields[fcnt].oe_field_meaning = dd
      .oe_field_meaning, reply->filter[x].default[d.seq].details[ocnt].fields[fcnt].
      oe_field_description = o.description, reply->filter[x].default[d.seq].details[ocnt].fields[fcnt
      ].cki = dd.detail_cki,
      reply->filter[x].default[d.seq].details[ocnt].fields[fcnt].detail_value = dd.detail_value
     WITH nocounter
    ;end select
   ENDIF
   FOR (y = 1 TO size(reply->filter[x].default,5))
     FOR (z = 1 TO size(reply->filter[x].default[y].details,5))
       FOR (q = 1 TO size(reply->filter[x].default[y].details[z].fields,5))
         SET codeset = 0
         SELECT INTO "nl:"
          FROM order_entry_fields o
          PLAN (o
           WHERE (o.oe_field_meaning_id=reply->filter[x].default[y].details[z].fields[q].
           oe_field_meaning_id))
          DETAIL
           codeset = o.codeset
          WITH nocounter
         ;end select
         IF (codeset > 0)
          SELECT INTO "nl:"
           FROM code_value c
           PLAN (c
            WHERE c.code_set=codeset
             AND (((c.cdf_meaning=reply->filter[x].default[y].details[z].fields[q].detail_value)) OR
            (((c.display=cnvtupper(reply->filter[x].default[y].details[z].fields[q].detail_value))
             OR ((c.cki=reply->filter[x].default[y].details[z].fields[q].cki))) ))
             AND c.active_ind=1)
           DETAIL
            reply->filter[x].default[y].details[z].fields[q].code_value = c.code_value
           WITH nocounter
          ;end select
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   IF (((yes_no_ind=1) OR (((numeric_ind=1) OR (link_entry_ind=1)) )) )
    SET stat = alterlist(reply->filter[x].default,1)
    SELECT INTO "nl:"
     FROM br_datamart_default b
     WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id)
     HEAD REPORT
      tcnt = 0
     DETAIL
      tcnt = (tcnt+ 1), stat = alterlist(reply->filter[x].default[1].values,tcnt)
      IF (yes_no_ind=1)
       IF (cnvtupper(b.result_value)="YES")
        reply->filter[x].default[1].values[tcnt].result_value = "1"
       ELSE
        reply->filter[x].default[1].values[tcnt].result_value = "0"
       ENDIF
      ELSEIF (((numeric_ind=1) OR (link_entry_ind=1)) )
       reply->filter[x].default[1].values[tcnt].result_value = b.result_value
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (hme_stat_ind=1)
    SELECT INTO "nl:"
     FROM br_datamart_default b,
      hm_expect_sat es
     PLAN (b
      WHERE (b.br_datamart_filter_id=reply->filter[x].br_datamart_filter_id))
      JOIN (es
      WHERE es.satisfier_meaning=outerjoin(b.unique_identifier)
       AND es.active_ind=outerjoin(1)
       AND es.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND es.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(reply->filter[x].default,dcnt), reply->filter[x].default[
      dcnt].code_value = es.expect_sat_id,
      reply->filter[x].default[dcnt].display = es.expect_sat_name, reply->filter[x].default[dcnt].
      unique_identifier = b.unique_identifier, reply->filter[x].default[dcnt].cv_display = b
      .cv_display
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
