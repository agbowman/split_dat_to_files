CREATE PROGRAM bed_aud_cn_powerplans:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 power_plans[*]
      2 power_plan_id = f8
    1 synonyms[*]
      2 synonym_id = f8
    1 version
      2 archived_ind = i2
      2 test_ind = i2
      2 production_ind = i2
      2 show_inactive_powerplans_ind = i2
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
 SET reply->status_data.status = "F"
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 powerplanid = f8
     2 powerplan = vc
     2 version = i4
     2 status = vc
     2 plan_type = vc
     2 cross_enc_ind = i2
     2 sub_phase_ind = i2
     2 duration = vc
     2 duration_units = vc
     2 clin_category = vc
     2 clin_subcategory = vc
     2 primary_synonym = vc
     2 include_ind = i2
     2 required_ind = i2
     2 order_sentence = vc
     2 order_sentence_filter = vc
     2 order_sentence_comment = vc
     2 display_method = vc
     2 outcome_desc = vc
     2 outcome_expect = vc
     2 phase = vc
     2 phase_pcat_id = f8
     2 note = vc
     2 comments = vc
     2 comp_seq = i4
     2 sp_parent_entity_id = f8
     2 iv_catalog_cd = f8
     2 pathway_comp_id = f8
     2 virtual_view = vc
 )
 FREE RECORD sort_temp
 RECORD sort_temp(
   1 tqual[*]
     2 powerplan = vc
     2 version = i4
     2 status = vc
     2 plan_type = vc
     2 cross_enc_ind = i2
     2 sub_phase_ind = i2
     2 duration = vc
     2 duration_units = vc
     2 clin_category = vc
     2 clin_subcategory = vc
     2 primary_synonym = vc
     2 include_ind = i2
     2 required_ind = i2
     2 order_sentence = vc
     2 order_sentence_filter = vc
     2 order_sentence_comment = vc
     2 display_method = vc
     2 outcome_desc = vc
     2 outcome_expect = vc
     2 phase = vc
     2 phase_pcat_id = f8
     2 note = vc
     2 comments = vc
     2 comp_seq = i4
     2 iv_catalog_cd = f8
     2 virtual_view = vc
 )
 FREE RECORD temp_filter
 RECORD temp_filter(
   1 age_min_value = f8
   1 age_max_value = f8
   1 age_unit_cd_display = vc
   1 pma_min_value = f8
   1 pma_max_value = f8
   1 pma_unit_cd_display = vc
   1 weight_min_value = f8
   1 weight_max_value = f8
   1 weight_unit_cd_display = vc
 )
 DECLARE subphase_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"SUBPHASE")), protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE temp_status = vc
 DECLARE virtual_view = vc
 DECLARE elementsadded = i2
 DECLARE finalstring = vc
 DECLARE tempstr = vc
 DECLARE type = vc
 DECLARE minvalue = f8
 DECLARE maxvalue = f8
 DECLARE display = vc
 DECLARE stringsection = vc
 DECLARE tcnt = i4
 DECLARE tcnt1 = i4
 DECLARE high_volume_cnt = i4
 DECLARE row_nbr = i4
 DECLARE currentserverdate = dq8
 DECLARE firstelementinstring = i4
 DECLARE computefiltercriteria(type=vc,minvalue=f8,maxvalue=f8,display=vc,elementsadded=i2) = vc
 DECLARE computestatus(begineffective=dq8,endeffective=dq8) = vc
 DECLARE computefilter(index=i4) = vc
 DECLARE request_power_plans_size = i4
 DECLARE pcat_parse = vc
 DECLARE pp_id_list = vc
 DECLARE request_synonyms_size = i4
 DECLARE pp_id_restrict = vc
 DECLARE pp_id_count = i4
 DECLARE inactive_powerplans_parse = vc
 DECLARE cnt1 = i4
 FREE RECORD temp1
 RECORD temp1(
   1 ids[*]
     2 id = f8
 )
 FREE RECORD temp2
 RECORD temp2(
   1 ids[*]
     2 id = f8
 )
 SET high_volume_cnt = 0
 IF (validate(request->version.show_inactive_powerplans_ind))
  IF ((request->version.show_inactive_powerplans_ind=1))
   SET inactive_powerplans_parse = "pcat.active_ind in (0,1)"
  ELSE
   SET inactive_powerplans_parse = "pcat.active_ind = 1"
  ENDIF
 ENDIF
 SET request_power_plans_size = size(request->power_plans,5)
 SET request_synonyms_size = size(request->synonyms,5)
 IF (request_power_plans_size > 0)
  SET stat = alterlist(temp1->ids,request_power_plans_size)
  FOR (rpps = 1 TO request_power_plans_size)
   SET temp1->ids[rpps].id = request->power_plans[rpps].power_plan_id
   IF (rpps > 1)
    SET pp_id_list = build(pp_id_list," , ",trim(cnvtstring(request->power_plans[rpps].power_plan_id,
       18,2)))
   ELSE
    SET pp_id_list = build(trim(cnvtstring(request->power_plans[rpps].power_plan_id,18,2)))
   ENDIF
  ENDFOR
 ENDIF
 SET cnt1 = request_power_plans_size
 IF (((request->version.test_ind) OR (request->version.archived_ind)) )
  DECLARE pp_version_list = vc WITH noconstant(" "), protect
  DECLARE version_parse = vc
  SET version_parse = " "
  IF (pp_id_list > " ")
   SET version_parse = build(" pcat.pathway_catalog_id in ( ",pp_id_list," ) ")
  ENDIF
  IF (version_parse > " ")
   SELECT INTO "nl:"
    FROM pathway_catalog pcat
    WHERE parser(version_parse)
     AND pcat.version_pw_cat_id > 0.0
    DETAIL
     pp_version_list = build(pp_version_list," , ",cnvtstring(pcat.version_pw_cat_id,18,2))
    WITH nocounter
   ;end select
  ENDIF
  IF (pp_version_list > " ")
   SET pp_version_list = substring(3,size(trim(pp_version_list)),trim(pp_version_list))
   SET version_parse = build(" pcat.version_pw_cat_id in ( ",pp_version_list," ) ",
    " and pcat.pathway_catalog_id not in ( ",pp_id_list,
    " ) ")
   SELECT INTO "nl:"
    FROM pathway_catalog pcat
    WHERE parser(version_parse)
    DETAIL
     cnt1 = (cnt1+ 1), stat = alterlist(temp1->ids,cnt1), temp1->ids[cnt1].id = pcat
     .pathway_catalog_id,
     pp_id_list = build(pp_id_list," , ",cnvtstring(pcat.pathway_catalog_id,18,2))
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (request_power_plans_size=0
  AND request_synonyms_size=0
  AND (request->version.archived_ind=0)
  AND (request->version.production_ind=0)
  AND (request->version.test_ind=0))
  SELECT DISTINCT INTO "nl:"
   pcat.version_pw_cat_id
   FROM pathway_catalog pcat
   WHERE pcat.version_pw_cat_id > 0
    AND pcat.active_ind IN (0, 1)
   ORDER BY pcat.description, pcat.version DESC
   HEAD pcat.version_pw_cat_id
    cnt1 = (cnt1+ 1), stat = alterlist(temp1->ids,cnt1), temp1->ids[cnt1].id = pcat
    .pathway_catalog_id
    IF (pp_id_list > " ")
     pp_id_list = build(pp_id_list," , ",cnvtstring(pcat.pathway_catalog_id,18,2))
    ELSE
     pp_id_list = build(trim(cnvtstring(pcat.pathway_catalog_id,18,2)))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE cnt2 = i4
 SET cnt2 = 0
 FOR (k = 1 TO cnt1)
   SELECT INTO "nl:"
    FROM pw_cat_reltn pw,
     pathway_catalog pcat,
     code_value cv1
    PLAN (pcat
     WHERE (pcat.pathway_catalog_id=temp1->ids[k].id))
     JOIN (pw
     WHERE pcat.pathway_catalog_id=pw.pw_cat_s_id
      AND pw.type_mean="GROUP")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pcat.pathway_type_cd))
    HEAD pw.pw_cat_t_id
     cnt2 = (cnt2+ 1), stat = alterlist(temp2->ids,cnt2), temp2->ids[cnt2].id = pw.pw_cat_t_id
     IF (pp_id_list > " ")
      pp_id_list = build(pp_id_list," , ",cnvtstring(pw.pw_cat_t_id,18,2))
     ELSE
      pp_id_list = build(trim(cnvtstring(pw.pw_cat_t_id,18,2)))
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FOR (i = 1 TO cnt2)
   SET cnt1 = (cnt1+ 1)
   SET stat = alterlist(temp1->ids,cnt1)
   SET temp1->ids[cnt1].id = temp2->ids[i].id
 ENDFOR
 DECLARE active_ind_str = vc
 IF (request_power_plans_size=0
  AND (request->version.archived_ind=0)
  AND (request->version.production_ind=0)
  AND (request->version.test_ind=0)
  AND (request->version.show_inactive_powerplans_ind=0))
  SET active_ind_str = "(1)"
 ELSE
  SET active_ind_str = "(0,1)"
 ENDIF
 IF (request_power_plans_size=0
  AND request_synonyms_size=0)
  IF ((request->version.show_inactive_powerplans_ind=0))
   SET pcat_parse = "pcat.active_ind = 1"
  ELSE
   SET pcat_parse = "pcat.active_ind in (0,1)"
  ENDIF
 ENDIF
 SET pp_id_restrict = build("pcat.pathway_catalog_id = pcomp.pathway_catalog_id")
 SET pp_id_restrict = build(pp_id_restrict," and pcat.active_ind in  ")
 SET pp_id_restrict = build(pp_id_restrict,active_ind_str)
 IF (pp_id_list > " ")
  SET pp_id_restrict = build(pp_id_restrict," and pcat.pathway_catalog_id in ( ",pp_id_list," )")
 ENDIF
 IF (request_synonyms_size > 0)
  SET pp_id_list = " "
  SET cnt1 = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = request_synonyms_size),
    pathway_catalog pcat,
    pathway_comp pcomp,
    order_catalog_synonym ocs
   PLAN (d
    WHERE (request->synonyms[d.seq].synonym_id > 0))
    JOIN (ocs
    WHERE (ocs.synonym_id=request->synonyms[d.seq].synonym_id))
    JOIN (pcomp
    WHERE pcomp.parent_entity_id=ocs.synonym_id
     AND pcomp.active_ind=1)
    JOIN (pcat
    WHERE parser(pp_id_restrict))
   HEAD pcat.pathway_catalog_id
    cnt1 = (cnt1+ 1), stat = alterlist(temp1->ids,cnt1), temp1->ids[cnt1].id = pcat
    .pathway_catalog_id
    IF (pp_id_list > " ")
     pp_id_list = build(pp_id_list," , ",cnvtstring(pcat.pathway_catalog_id,18,2))
    ELSE
     pp_id_list = build(trim(cnvtstring(pcat.pathway_catalog_id,18,2)))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE num = i4
 SET num = 0
 IF (pp_id_list > " ")
  IF (pcat_parse > " ")
   SET pcat_parse = build(pcat_parse,
    " and expand(num,1,size(temp1->ids,5),pcat.pathway_catalog_id, temp1->ids[num].id )")
  ELSE
   SET pcat_parse = build(
    "expand(num,1,size(temp1->ids,5),pcat.pathway_catalog_id, temp1->ids[num].id )")
  ENDIF
 ENDIF
 IF ( NOT (request->version.test_ind
  AND request->version.production_ind
  AND request->version.archived_ind)
  AND ((request->version.test_ind) OR (((request->version.production_ind) OR (request->version.
 archived_ind)) )) )
  IF (request->version.production_ind)
   IF (request->version.test_ind)
    IF (pcat_parse > " ")
     SET pcat_parse = build(pcat_parse,
      " and pcat.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ")
    ELSE
     SET pcat_parse = build(" pcat.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ")
    ENDIF
   ELSEIF (request->version.archived_ind)
    IF (pcat_parse > " ")
     SET pcat_parse = build(pcat_parse,
      " and pcat.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ")
    ELSE
     SET pcat_parse = build("pcat.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ")
    ENDIF
   ELSE
    IF (pcat_parse > " ")
     SET pcat_parse = build(pcat_parse,
      " and ( pcat.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ",
      " and pcat.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ) ")
    ELSE
     SET pcat_parse = build("( pcat.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ",
      " and pcat.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ) ")
    ENDIF
   ENDIF
  ELSE
   IF (request->version.test_ind
    AND request->version.archived_ind)
    IF (pcat_parse > " ")
     SET pcat_parse = build(pcat_parse,
      " and ( pcat.beg_effective_dt_tm > cnvtdatetime(curdate, curtime3) ",
      " or pcat.end_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ) ")
    ELSE
     SET pcat_parse = build("( pcat.beg_effective_dt_tm > cnvtdatetime(curdate, curtime3) ",
      " or pcat.end_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ) ")
    ENDIF
   ELSEIF (request->version.test_ind)
    IF (pcat_parse > " ")
     SET pcat_parse = build(pcat_parse,
      " and ( pcat.beg_effective_dt_tm > cnvtdatetime(curdate, curtime3) ) ")
    ELSE
     SET pcat_parse = build("( pcat.beg_effective_dt_tm > cnvtdatetime(curdate, curtime3) ) ")
    ENDIF
   ELSEIF (request->version.archived_ind)
    IF (pcat_parse > " ")
     SET pcat_parse = build(pcat_parse,
      " and ( pcat.end_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ) ")
    ELSE
     SET pcat_parse = build("( pcat.end_effective_dt_tm <= cnvtdatetime(curdate, curtime3) ) ")
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (pcat_parse > " ")
  IF ((request->skip_volume_check_ind=0))
   SELECT INTO "nl:"
    FROM pathway_comp pcomp,
     order_catalog_synonym ocs,
     outcome_catalog ocat,
     pathway_catalog pcat,
     long_text l,
     long_text l2
    PLAN (pcomp
     WHERE pcomp.active_ind=1)
     JOIN (pcat
     WHERE parser(pcat_parse)
      AND parser(inactive_powerplans_parse)
      AND pcat.pathway_catalog_id=pcomp.pathway_catalog_id)
     JOIN (ocs
     WHERE ocs.synonym_id=outerjoin(pcomp.parent_entity_id))
     JOIN (ocat
     WHERE ocat.outcome_catalog_id=outerjoin(pcomp.parent_entity_id))
     JOIN (l
     WHERE l.long_text_id=outerjoin(pcomp.parent_entity_id))
     JOIN (l2
     WHERE l2.long_text_id=outerjoin(pcat.long_text_id))
    ORDER BY pcat.description
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "NL:"
    FROM pathway_catalog pcat,
     code_value cv1,
     long_text l
    PLAN (pcat
     WHERE parser(pcat_parse)
      AND  NOT (pcat.pathway_catalog_id IN (
     (SELECT
      pcomp.pathway_catalog_id
      FROM pathway_comp pcomp
      WHERE pcomp.active_ind=1)))
      AND pcat.type_mean="PHASE")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pcat.display_method_cd))
     JOIN (l
     WHERE l.long_text_id=outerjoin(pcat.long_text_id))
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "NL:"
    FROM pathway_catalog pcat,
     code_value cv1,
     long_text l
    PLAN (pcat
     WHERE parser(pcat_parse)
      AND parser(inactive_powerplans_parse)
      AND  NOT (pcat.pathway_catalog_id IN (
     (SELECT
      pw.pw_cat_s_id
      FROM pw_cat_reltn pw)))
      AND  NOT (pcat.pathway_catalog_id IN (
     (SELECT
      pcomp.pathway_catalog_id
      FROM pathway_comp pcomp
      WHERE pcomp.active_ind=1)))
      AND pcat.type_mean != "PHASE")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pcat.pathway_type_cd))
     JOIN (l
     WHERE l.long_text_id=outerjoin(pcat.long_text_id))
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter, expand = 1
   ;end select
   IF (high_volume_cnt > 5000)
    SET reply->high_volume_flag = 2
    GO TO exit_script
   ELSEIF (high_volume_cnt > 3000)
    SET reply->high_volume_flag = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET tcnt = 0
 IF (pcat_parse > " ")
  SELECT INTO "NL:"
   FROM pathway_comp pcomp,
    pathway_catalog pcat,
    order_catalog_synonym ocs,
    outcome_catalog ocat,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5,
    pw_comp_os_reltn pcor,
    order_sentence os,
    long_text l,
    long_text l2,
    long_text l3,
    order_sentence_filter osf,
    code_value cv_age,
    code_value cv_pma,
    code_value cv_weight
   PLAN (pcat
    WHERE parser(pcat_parse)
     AND parser(inactive_powerplans_parse))
    JOIN (pcomp
    WHERE pcat.pathway_catalog_id=pcomp.pathway_catalog_id
     AND pcomp.active_ind=1)
    JOIN (ocs
    WHERE ocs.synonym_id=outerjoin(pcomp.parent_entity_id))
    JOIN (ocat
    WHERE ocat.outcome_catalog_id=outerjoin(pcomp.parent_entity_id))
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(pcat.pathway_type_cd))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(pcomp.duration_unit_cd))
    JOIN (cv3
    WHERE cv3.code_value=outerjoin(pcomp.dcp_clin_cat_cd))
    JOIN (cv4
    WHERE cv4.code_value=outerjoin(pcomp.dcp_clin_sub_cat_cd))
    JOIN (cv5
    WHERE cv5.code_value=outerjoin(pcat.display_method_cd))
    JOIN (pcor
    WHERE pcor.pathway_comp_id=outerjoin(pcomp.pathway_comp_id))
    JOIN (os
    WHERE os.order_sentence_id=outerjoin(pcor.order_sentence_id))
    JOIN (l
    WHERE l.long_text_id=outerjoin(pcomp.parent_entity_id))
    JOIN (l2
    WHERE l2.long_text_id=outerjoin(pcat.long_text_id))
    JOIN (l3
    WHERE l3.long_text_id=outerjoin(os.ord_comment_long_text_id))
    JOIN (osf
    WHERE osf.order_sentence_id=outerjoin(os.order_sentence_id))
    JOIN (cv_age
    WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
    JOIN (cv_pma
    WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
    JOIN (cv_weight
    WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
   ORDER BY pcat.pathway_catalog_id, pcat.description
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt)
    IF (pcat.type_mean="PHASE")
     temp->tqual[tcnt].phase = pcat.description, temp->tqual[tcnt].phase_pcat_id = pcat
     .pathway_catalog_id
    ELSE
     temp->tqual[tcnt].powerplanid = pcat.pathway_catalog_id, temp->tqual[tcnt].powerplan = pcat
     .description, temp->tqual[tcnt].comments = l2.long_text,
     temp->tqual[tcnt].phase = ""
    ENDIF
    temp->tqual[tcnt].version = pcat.version, temp->tqual[tcnt].status = computestatus(pcat
     .beg_effective_dt_tm,pcat.end_effective_dt_tm), temp->tqual[tcnt].plan_type = cv1.display,
    temp->tqual[tcnt].cross_enc_ind = pcat.cross_encntr_ind, temp->tqual[tcnt].sub_phase_ind = pcat
    .sub_phase_ind
    IF (pcomp.duration_qty=0)
     temp->tqual[tcnt].duration = " "
    ELSE
     temp->tqual[tcnt].duration = cnvtstring(pcomp.duration_qty)
    ENDIF
    temp->tqual[tcnt].duration_units = cv2.display, temp->tqual[tcnt].clin_category = cv3.display,
    temp->tqual[tcnt].clin_subcategory = cv4.display
    IF (pcomp.parent_entity_name="ORDER_CATALOG_SYNONYM")
     temp->tqual[tcnt].primary_synonym = ocs.mnemonic
    ELSE
     temp->tqual[tcnt].primary_synonym = " "
    ENDIF
    temp->tqual[tcnt].include_ind = pcomp.include_ind, temp->tqual[tcnt].required_ind = pcomp
    .required_ind, temp->tqual[tcnt].order_sentence = os.order_sentence_display_line,
    temp_filter->age_min_value = osf.age_min_value, temp_filter->age_max_value = osf.age_max_value,
    temp_filter->age_unit_cd_display = cv_age.display,
    temp_filter->pma_min_value = osf.pma_min_value, temp_filter->pma_max_value = osf.pma_max_value,
    temp_filter->pma_unit_cd_display = cv_pma.display,
    temp_filter->weight_min_value = osf.weight_min_value, temp_filter->weight_max_value = osf
    .weight_max_value, temp_filter->weight_unit_cd_display = cv_weight.display,
    temp->tqual[tcnt].order_sentence_filter = computefilter(tcnt), temp->tqual[tcnt].
    order_sentence_comment = l3.long_text, temp->tqual[tcnt].display_method = cv5.display
    IF (pcomp.parent_entity_name="OUTCOME_CATALOG")
     temp->tqual[tcnt].outcome_desc = ocat.description, temp->tqual[tcnt].outcome_expect = ocat
     .expectation
    ELSE
     temp->tqual[tcnt].outcome_desc = " ", temp->tqual[tcnt].outcome_expect = " "
    ENDIF
    IF (pcomp.parent_entity_name="LONG_TEXT")
     temp->tqual[tcnt].note = l.long_text
    ELSE
     temp->tqual[tcnt].note = " "
    ENDIF
    temp->tqual[tcnt].comp_seq = pcomp.sequence
    IF (pcomp.comp_type_cd=subphase_comp_cd)
     temp->tqual[tcnt].sp_parent_entity_id = pcomp.parent_entity_id
    ELSEIF (pcomp.comp_type_cd=order_comp_cd)
     IF (ocs.orderable_type_flag IN (8, 11))
      temp->tqual[tcnt].iv_catalog_cd = ocs.catalog_cd, temp->tqual[tcnt].order_sentence = " ", temp
      ->tqual[tcnt].comp_seq = pcor.seq
     ENDIF
    ENDIF
    temp->tqual[tcnt].pathway_comp_id = pcomp.pathway_comp_id
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (tcnt > 0)
  FOR (t = 1 TO tcnt)
   IF ((temp->tqual[t].phase_pcat_id > 0))
    SELECT INTO "NL:"
     FROM pw_cat_reltn pw,
      pathway_catalog pcat,
      code_value cv1
     PLAN (pw
      WHERE (pw.pw_cat_t_id=temp->tqual[t].phase_pcat_id)
       AND pw.type_mean="GROUP")
      JOIN (pcat
      WHERE pcat.pathway_catalog_id=pw.pw_cat_s_id
       AND parser(inactive_powerplans_parse))
      JOIN (cv1
      WHERE cv1.code_value=outerjoin(pcat.pathway_type_cd))
     DETAIL
      temp->tqual[t].powerplanid = pcat.pathway_catalog_id, temp->tqual[t].powerplan = pcat
      .description, temp->tqual[t].version = pcat.version,
      temp->tqual[t].status = computestatus(pcat.beg_effective_dt_tm,pcat.end_effective_dt_tm), temp
      ->tqual[t].plan_type = cv1.display, temp->tqual[t].cross_enc_ind = pcat.cross_encntr_ind
     WITH nocounter
    ;end select
   ENDIF
   IF ((temp->tqual[t].powerplanid > 0))
    SELECT INTO "NL:"
     FROM pathway_catalog pcat,
      long_text l
     PLAN (pcat
      WHERE (pcat.pathway_catalog_id=temp->tqual[t].powerplanid))
      JOIN (l
      WHERE l.parent_entity_id=outerjoin(pcat.pathway_catalog_id))
     DETAIL
      IF (l.parent_entity_name="PATHWAY_CATALOG")
       temp->tqual[t].comments = l.long_text
      ELSE
       temp->tqual[t].comments = ""
      ENDIF
     WITH nocounter
    ;end select
    CALL echo(build("powerplan",temp->tqual[t].powerplan))
   ENDIF
  ENDFOR
 ENDIF
 SET tcnt1 = size(temp->tqual,5)
 IF (pcat_parse > " ")
  SELECT INTO "NL:"
   FROM pathway_catalog pcat,
    code_value cv1,
    long_text l
   PLAN (pcat
    WHERE parser(pcat_parse)
     AND parser(inactive_powerplans_parse)
     AND  NOT (pcat.pathway_catalog_id IN (
    (SELECT
     pcomp.pathway_catalog_id
     FROM pathway_comp pcomp
     WHERE pcomp.active_ind=1)))
     AND pcat.type_mean="PHASE")
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(pcat.display_method_cd))
    JOIN (l
    WHERE l.long_text_id=outerjoin(pcat.long_text_id))
   DETAIL
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp->tqual,tcnt1), temp->tqual[tcnt1].phase = pcat
    .description,
    temp->tqual[tcnt1].phase_pcat_id = pcat.pathway_catalog_id, temp->tqual[tcnt1].version = pcat
    .version, temp->tqual[tcnt1].status = computestatus(pcat.beg_effective_dt_tm,pcat
     .end_effective_dt_tm),
    temp->tqual[tcnt1].cross_enc_ind = pcat.cross_encntr_ind, temp->tqual[tcnt1].sub_phase_ind = pcat
    .sub_phase_ind, temp->tqual[tcnt1].display_method = cv1.display
   WITH nocounter, expand = 1
  ;end select
  IF (tcnt1 > 0)
   FOR (x = (tcnt+ 1) TO tcnt1)
     SELECT INTO "NL:"
      FROM pw_cat_reltn pw,
       pathway_catalog pcat,
       code_value cv1,
       long_text l
      PLAN (pw
       WHERE (pw.pw_cat_t_id=temp->tqual[x].phase_pcat_id)
        AND pw.type_mean="GROUP")
       JOIN (pcat
       WHERE parser(pcat_parse)
        AND parser(inactive_powerplans_parse)
        AND pcat.pathway_catalog_id=pw.pw_cat_s_id)
       JOIN (cv1
       WHERE cv1.code_value=outerjoin(pcat.pathway_type_cd))
       JOIN (l
       WHERE l.long_text_id=outerjoin(pcat.long_text_id))
      DETAIL
       temp->tqual[x].powerplanid = pcat.pathway_catalog_id, temp->tqual[x].powerplan = pcat
       .description, temp->tqual[x].version = pcat.version,
       temp->tqual[x].status = computestatus(pcat.beg_effective_dt_tm,pcat.end_effective_dt_tm), temp
       ->tqual[x].plan_type = cv1.display, temp->tqual[x].cross_enc_ind = pcat.cross_encntr_ind,
       temp->tqual[x].comments = l.long_text
      WITH nocounter, expand = 1
     ;end select
   ENDFOR
   SET tcnt1 = size(temp->tqual,5)
   SELECT INTO "NL:"
    FROM pathway_catalog pcat,
     code_value cv1,
     long_text l
    PLAN (pcat
     WHERE parser(pcat_parse)
      AND parser(inactive_powerplans_parse)
      AND  NOT (pcat.pathway_catalog_id IN (
     (SELECT
      pw.pw_cat_s_id
      FROM pw_cat_reltn pw)))
      AND  NOT (pcat.pathway_catalog_id IN (
     (SELECT
      pcomp.pathway_catalog_id
      FROM pathway_comp pcomp
      WHERE pcomp.active_ind=1)))
      AND pcat.type_mean != "PHASE")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pcat.pathway_type_cd))
     JOIN (l
     WHERE l.long_text_id=outerjoin(pcat.long_text_id))
    DETAIL
     tcnt1 = (tcnt1+ 1), stat = alterlist(temp->tqual,tcnt1), temp->tqual[tcnt1].powerplan = pcat
     .description,
     temp->tqual[tcnt1].powerplanid = pcat.pathway_catalog_id, temp->tqual[tcnt1].version = pcat
     .version, temp->tqual[tcnt1].status = computestatus(pcat.beg_effective_dt_tm,pcat
      .end_effective_dt_tm),
     temp->tqual[tcnt1].plan_type = cv1.display, temp->tqual[tcnt1].cross_enc_ind = pcat
     .cross_encntr_ind, temp->tqual[tcnt1].comments = l.long_text
    WITH nocounter, expand = 1
   ;end select
   IF (tcnt1 > 0)
    FOR (i = 1 TO tcnt1)
      SET virtual_view = ""
      SELECT INTO "nl:"
       FROM pw_cat_flex p,
        code_value c
       PLAN (p
        WHERE (p.pathway_catalog_id=temp->tqual[i].powerplanid)
         AND p.parent_entity_name="CODE_VALUE")
        JOIN (c
        WHERE c.code_value=p.parent_entity_id)
       DETAIL
        IF (c.code_value=0.0)
         virtual_view = "All"
        ELSE
         IF (size(trim(c.display),1) > 0)
          IF (size(trim(virtual_view),1) > 0)
           virtual_view = concat(trim(virtual_view),",",trim(c.display))
          ELSE
           virtual_view = concat(trim(c.display))
          ENDIF
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      SET temp->tqual[i].virtual_view = virtual_view
    ENDFOR
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt1),
     pathway_catalog pwc
    PLAN (d
     WHERE (temp->tqual[d.seq].sp_parent_entity_id > 0))
     JOIN (pwc
     WHERE (pwc.pathway_catalog_id=temp->tqual[d.seq].sp_parent_entity_id))
    DETAIL
     temp->tqual[d.seq].phase = pwc.description
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt1),
     cs_component cc,
     order_catalog_synonym ocs,
     pw_comp_os_reltn pcor,
     order_sentence os,
     long_text lt
    PLAN (d
     WHERE (temp->tqual[d.seq].iv_catalog_cd > 0))
     JOIN (cc
     WHERE (cc.catalog_cd=temp->tqual[d.seq].iv_catalog_cd))
     JOIN (ocs
     WHERE ocs.synonym_id=cc.comp_id)
     JOIN (pcor
     WHERE pcor.pathway_comp_id=outerjoin(temp->tqual[d.seq].pathway_comp_id)
      AND pcor.iv_comp_syn_id=outerjoin(ocs.synonym_id))
     JOIN (os
     WHERE os.order_sentence_id=outerjoin(pcor.order_sentence_id))
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
    ORDER BY temp->tqual[d.seq].powerplanid, temp->tqual[d.seq].pathway_comp_id, temp->tqual[d.seq].
     iv_catalog_cd,
     cc.catalog_cd, ocs.synonym_id
    HEAD ocs.synonym_id
     tcnt1 = (tcnt1+ 1), stat = alterlist(temp->tqual,tcnt1), temp->tqual[tcnt1].powerplanid = temp->
     tqual[d.seq].powerplanid,
     temp->tqual[tcnt1].powerplan = temp->tqual[d.seq].powerplan, temp->tqual[tcnt1].version = temp->
     tqual[d.seq].version, temp->tqual[tcnt1].status = temp->tqual[d.seq].status,
     temp->tqual[tcnt1].phase = temp->tqual[d.seq].phase, temp->tqual[tcnt1].primary_synonym = concat
     (temp->tqual[d.seq].primary_synonym,", ",ocs.mnemonic), temp->tqual[tcnt1].order_sentence = os
     .order_sentence_display_line,
     temp->tqual[tcnt1].order_sentence_filter = temp->tqual[d.seq].order_sentence_filter, temp->
     tqual[tcnt1].plan_type = temp->tqual[d.seq].plan_type, temp->tqual[tcnt1].display_method = temp
     ->tqual[d.seq].display_method,
     temp->tqual[tcnt1].cross_enc_ind = temp->tqual[d.seq].cross_enc_ind, temp->tqual[tcnt1].
     sub_phase_ind = temp->tqual[d.seq].sub_phase_ind, temp->tqual[tcnt1].duration = temp->tqual[d
     .seq].duration,
     temp->tqual[tcnt1].duration_units = temp->tqual[d.seq].duration_units, temp->tqual[tcnt1].
     clin_category = temp->tqual[d.seq].clin_category, temp->tqual[tcnt1].clin_subcategory = temp->
     tqual[d.seq].clin_subcategory,
     temp->tqual[tcnt1].include_ind = temp->tqual[d.seq].include_ind, temp->tqual[tcnt1].required_ind
      = temp->tqual[d.seq].required_ind, temp->tqual[tcnt1].order_sentence_comment = lt.long_text,
     temp->tqual[tcnt1].outcome_desc = temp->tqual[d.seq].outcome_desc, temp->tqual[tcnt1].
     outcome_expect = temp->tqual[d.seq].outcome_expect, temp->tqual[tcnt1].phase = temp->tqual[d.seq
     ].phase,
     temp->tqual[tcnt1].phase_pcat_id = temp->tqual[d.seq].phase_pcat_id, temp->tqual[tcnt1].note =
     temp->tqual[d.seq].note, temp->tqual[tcnt1].comments = temp->tqual[d.seq].comments,
     temp->tqual[tcnt1].comp_seq = temp->tqual[d.seq].comp_seq, temp->tqual[tcnt1].virtual_view =
     temp->tqual[d.seq].virtual_view
    WITH nocounter
   ;end select
   SET stat = alterlist(sort_temp->tqual,tcnt1)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tcnt1)
    PLAN (d)
    ORDER BY cnvtupper(temp->tqual[d.seq].powerplan), temp->tqual[d.seq].version, cnvtupper(substring
      (1,200,temp->tqual[d.seq].phase)),
     cnvtupper(substring(1,200,temp->tqual[d.seq].clin_category)), cnvtupper(substring(1,200,temp->
       tqual[d.seq].clin_subcategory)), temp->tqual[d.seq].comp_seq
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), sort_temp->tqual[cnt].powerplan = temp->tqual[d.seq].powerplan, sort_temp->
     tqual[cnt].version = temp->tqual[d.seq].version,
     sort_temp->tqual[cnt].status = temp->tqual[d.seq].status, sort_temp->tqual[cnt].plan_type = temp
     ->tqual[d.seq].plan_type, sort_temp->tqual[cnt].cross_enc_ind = temp->tqual[d.seq].cross_enc_ind,
     sort_temp->tqual[cnt].sub_phase_ind = temp->tqual[d.seq].sub_phase_ind, sort_temp->tqual[cnt].
     duration = temp->tqual[d.seq].duration, sort_temp->tqual[cnt].duration_units = temp->tqual[d.seq
     ].duration_units,
     sort_temp->tqual[cnt].clin_category = temp->tqual[d.seq].clin_category, sort_temp->tqual[cnt].
     clin_subcategory = temp->tqual[d.seq].clin_subcategory, sort_temp->tqual[cnt].primary_synonym =
     temp->tqual[d.seq].primary_synonym,
     sort_temp->tqual[cnt].include_ind = temp->tqual[d.seq].include_ind, sort_temp->tqual[cnt].
     required_ind = temp->tqual[d.seq].required_ind, sort_temp->tqual[cnt].order_sentence = temp->
     tqual[d.seq].order_sentence,
     sort_temp->tqual[cnt].order_sentence_filter = temp->tqual[d.seq].order_sentence_filter,
     sort_temp->tqual[cnt].order_sentence_comment = temp->tqual[d.seq].order_sentence_comment,
     sort_temp->tqual[cnt].display_method = temp->tqual[d.seq].display_method,
     sort_temp->tqual[cnt].outcome_desc = temp->tqual[d.seq].outcome_desc, sort_temp->tqual[cnt].
     outcome_expect = temp->tqual[d.seq].outcome_expect, sort_temp->tqual[cnt].phase = temp->tqual[d
     .seq].phase,
     sort_temp->tqual[cnt].phase_pcat_id = temp->tqual[d.seq].phase_pcat_id, sort_temp->tqual[cnt].
     note = temp->tqual[d.seq].note, sort_temp->tqual[cnt].comments = temp->tqual[d.seq].comments,
     sort_temp->tqual[cnt].comp_seq = temp->tqual[d.seq].comp_seq, sort_temp->tqual[cnt].
     iv_catalog_cd = temp->tqual[d.seq].iv_catalog_cd, sort_temp->tqual[cnt].virtual_view = temp->
     tqual[d.seq].virtual_view
    WITH nocounter
   ;end select
   FOR (t = 1 TO tcnt1)
     SET temp->tqual[t].powerplan = sort_temp->tqual[t].powerplan
     SET temp->tqual[t].version = sort_temp->tqual[t].version
     SET temp->tqual[t].status = sort_temp->tqual[t].status
     SET temp->tqual[t].plan_type = sort_temp->tqual[t].plan_type
     SET temp->tqual[t].cross_enc_ind = sort_temp->tqual[t].cross_enc_ind
     SET temp->tqual[t].sub_phase_ind = sort_temp->tqual[t].sub_phase_ind
     SET temp->tqual[t].duration = sort_temp->tqual[t].duration
     SET temp->tqual[t].duration_units = sort_temp->tqual[t].duration_units
     SET temp->tqual[t].clin_category = sort_temp->tqual[t].clin_category
     SET temp->tqual[t].clin_subcategory = sort_temp->tqual[t].clin_subcategory
     SET temp->tqual[t].primary_synonym = sort_temp->tqual[t].primary_synonym
     SET temp->tqual[t].include_ind = sort_temp->tqual[t].include_ind
     SET temp->tqual[t].required_ind = sort_temp->tqual[t].required_ind
     SET temp->tqual[t].order_sentence = sort_temp->tqual[t].order_sentence
     SET temp->tqual[t].order_sentence_filter = sort_temp->tqual[t].order_sentence_filter
     SET temp->tqual[t].order_sentence_comment = sort_temp->tqual[t].order_sentence_comment
     SET temp->tqual[t].display_method = sort_temp->tqual[t].display_method
     SET temp->tqual[t].outcome_desc = sort_temp->tqual[t].outcome_desc
     SET temp->tqual[t].outcome_expect = sort_temp->tqual[t].outcome_expect
     SET temp->tqual[t].phase = sort_temp->tqual[t].phase
     SET temp->tqual[t].phase_pcat_id = sort_temp->tqual[t].phase_pcat_id
     SET temp->tqual[t].note = sort_temp->tqual[t].note
     SET temp->tqual[t].comments = sort_temp->tqual[t].comments
     SET temp->tqual[t].comp_seq = sort_temp->tqual[t].comp_seq
     SET temp->tqual[t].iv_catalog_cd = sort_temp->tqual[t].iv_catalog_cd
     SET temp->tqual[t].virtual_view = sort_temp->tqual[t].virtual_view
   ENDFOR
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,23)
 SET reply->collist[1].header_text = "PowerPlan"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Version"
 SET reply->collist[2].data_type = 3
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Status"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Plan Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Display Method"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Cross Encounter"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Sub Phase Indicator"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Phase/SubPhase"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Clinical Category"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Clinical Sub-Category"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Note"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Order Sentence"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Order Sentence Filter"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Order Sentence Comment"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Include"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Required"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Outcome Description"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Outcome Expectation"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Duration"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Duration Units"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Plan Comments"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Powerplan Virtual View"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 IF (tcnt1=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt1)
   IF ((temp->tqual[x].iv_catalog_cd=0))
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,23)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].powerplan
    SET reply->rowlist[row_nbr].celllist[2].nbr_value = temp->tqual[x].version
    SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].status
    SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].plan_type
    SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].display_method
    IF ((temp->tqual[x].cross_enc_ind=1))
     SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[6].string_value = " "
    ENDIF
    IF ((temp->tqual[x].sub_phase_ind=1))
     SET reply->rowlist[row_nbr].celllist[7].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[7].string_value = " "
    ENDIF
    SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].phase
    SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].clin_category
    SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].clin_subcategory
    SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].note
    SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].primary_synonym
    SET reply->rowlist[row_nbr].celllist[13].string_value = temp->tqual[x].order_sentence
    SET reply->rowlist[row_nbr].celllist[14].string_value = temp->tqual[x].order_sentence_filter
    SET reply->rowlist[row_nbr].celllist[15].string_value = temp->tqual[x].order_sentence_comment
    IF ((temp->tqual[x].include_ind=1))
     SET reply->rowlist[row_nbr].celllist[16].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[16].string_value = " "
    ENDIF
    IF ((temp->tqual[x].required_ind=1))
     SET reply->rowlist[row_nbr].celllist[17].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[17].string_value = " "
    ENDIF
    SET reply->rowlist[row_nbr].celllist[18].string_value = temp->tqual[x].outcome_desc
    SET reply->rowlist[row_nbr].celllist[19].string_value = temp->tqual[x].outcome_expect
    SET reply->rowlist[row_nbr].celllist[20].string_value = temp->tqual[x].duration
    SET reply->rowlist[row_nbr].celllist[21].string_value = temp->tqual[x].duration_units
    SET reply->rowlist[row_nbr].celllist[22].string_value = temp->tqual[x].comments
    SET reply->rowlist[row_nbr].celllist[23].string_value = temp->tqual[x].virtual_view
   ENDIF
 ENDFOR
 SUBROUTINE computestatus(begineffective,endeffective)
   SET currentserverdate = cnvtdatetime(curdate,curtime3)
   IF (endeffective=null)
    SET temp_status = "Unknown"
   ELSEIF (datetimecmp(currentserverdate,endeffective) >= 0)
    SET temp_status = "Archive"
   ELSEIF (begineffective=null)
    SET temp_status = "Unknown"
   ELSEIF (datetimecmp(currentserverdate,begineffective) >= 0)
    IF (datetimecmp(currentserverdate,endeffective) <= 0)
     SET temp_status = "Production"
    ELSE
     SET temp_status = "Unknown"
    ENDIF
   ELSEIF (datetimecmp(currentserverdate,begineffective) <= 0)
    SET temp_status = "Testing"
   ELSE
    SET temp_status = "Unknown"
   ENDIF
   RETURN(temp_status)
 END ;Subroutine
 SUBROUTINE computefilter(index)
   SET finalstring = " "
   SET elementsadded = 0
   SET type = "AGE"
   SET minvalue = temp_filter->age_min_value
   SET maxvalue = temp_filter->age_max_value
   SET display = temp_filter->age_unit_cd_display
   SET tempstr = computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   IF (size(tempstr,1) > 0
    AND elementsadded > 0)
    SET finalstring = concat(finalstring," AND ")
   ENDIF
   SET finalstring = concat(finalstring," ",tempstr)
   IF (size(tempstr,1) > 0)
    SET elementsadded = (elementsadded+ 1)
   ENDIF
   SET type = "PMA"
   SET minvalue = temp_filter->pma_min_value
   SET maxvalue = temp_filter->pma_max_value
   SET display = temp_filter->pma_unit_cd_display
   SET tempstr = computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   IF (size(tempstr,1) > 0
    AND elementsadded > 0)
    SET finalstring = concat(finalstring," AND ")
   ENDIF
   SET finalstring = concat(finalstring," ",tempstr)
   IF (size(tempstr,1) > 0)
    SET elementsadded = (elementsadded+ 1)
   ENDIF
   SET type = "WEIGHT"
   SET minvalue = temp_filter->weight_min_value
   SET maxvalue = temp_filter->weight_max_value
   SET display = temp_filter->weight_unit_cd_display
   SET tempstr = computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   IF (size(tempstr,1) > 0
    AND elementsadded > 0)
    SET finalstring = concat(finalstring," AND ")
   ENDIF
   SET finalstring = concat(finalstring," ",tempstr)
   IF (size(tempstr,1) > 0)
    SET elementsadded = (elementsadded+ 1)
   ENDIF
   RETURN(finalstring)
 END ;Subroutine
 SUBROUTINE computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   DECLARE minvaluestr = vc WITH noconstant
   DECLARE maxvaluestr = vc WITH noconstant
   SET stringsection = concat(" ")
   SET firstelementinstring = 0
   IF (((display=null) OR (minvalue=0
    AND maxvalue=0)) )
    RETURN(stringsection)
   ENDIF
   IF (type="PMA")
    IF (elementsadded=0)
     SET stringsection = concat(" ",type,"  ",stringsection)
    ELSE
     SET stringsection = concat(type,"  ",stringsection)
    ENDIF
   ENDIF
   IF (elementsadded=0)
    SET firstelementinstring = 1
   ENDIF
   IF (type="WEIGHT")
    SET minvaluestr = cnvtstring(minvalue,10,2)
    SET maxvaluestr = cnvtstring(maxvalue,10,2)
   ELSE
    SET minvaluestr = cnvtstring(minvalue)
    SET maxvaluestr = cnvtstring(maxvalue)
   ENDIF
   IF (minvalue > 0
    AND maxvalue=0)
    IF (firstelementinstring=1)
     SET stringsection = concat(stringsection," Greater than or equal to ",minvaluestr)
    ELSE
     SET stringsection = concat(stringsection," greater than or equal to ",minvaluestr)
    ENDIF
   ELSEIF (minvalue=0
    AND maxvalue > 0)
    IF (firstelementinstring=1)
     SET stringsection = concat(stringsection," Less than ",maxvaluestr)
    ELSE
     SET stringsection = concat(stringsection," less than ",maxvaluestr)
    ENDIF
   ELSE
    IF (firstelementinstring=1)
     SET stringsection = concat(stringsection," Between ")
    ELSE
     SET stringsection = concat(stringsection,"between ")
    ENDIF
    SET stringsection = concat(stringsection," ",minvaluestr)
    SET stringsection = concat(stringsection," and ")
    SET stringsection = concat(stringsection," ",maxvaluestr)
   ENDIF
   SET stringsection = concat(stringsection," ",display)
   RETURN(stringsection)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_powerplans.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
