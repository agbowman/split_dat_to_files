CREATE PROGRAM dcp_get_pw_cat_detail:dba
 RECORD reply(
   1 pathway_catalog_id = f8
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 cross_encntr_ind = i2
   1 description = vc
   1 age_units_cd = f8
   1 age_units_disp = c40
   1 age_units_mean = c12
   1 pw_text = vc
   1 long_text_id = f8
   1 text_updt_cnt = i4
   1 restrict_comp_add_ind = i2
   1 restrict_tf_add_ind = i2
   1 restrict_cc_add_ind = i2
   1 pw_forms_ref_id = f8
   1 comp_forms_ref_id = f8
   1 updt_cnt = i4
   1 version = i4
   1 version_cnt = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 qual_version[*]
     2 pathway_catalog_id = f8
     2 version = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 nomen_cnt = i4
   1 qual_nomen[*]
     2 pathway_focus_id = f8
     2 pathway_catalog_id = f8
     2 pathway_level_ind = i2
     2 nomenclature_id = f8
     2 vocabulary = c40
     2 principle_type = c40
     2 source_string = c255
     2 updt_cnt = i4
     2 default_status_cd = f8
     2 sequence = i4
   1 time_frame_cnt = i4
   1 qual_time_frame[*]
     2 time_frame_id = f8
     2 description = vc
     2 sequence = i4
     2 active_ind = i2
     2 duration_qty = i4
     2 age_units_cd = f8
     2 age_units_disp = c40
     2 age_units_mean = c12
     2 continuous_ind = i2
     2 start_ind = i2
     2 end_ind = i2
     2 updt_cnt = i4
     2 prnt_time_frame_id = f8
   1 care_category_cnt = i4
   1 qual_care_category[*]
     2 care_category_id = f8
     2 care_category_cd = f8
     2 description = vc
     2 sequence = i4
     2 restrict_comp_add_ind = i2
     2 comp_add_variance_ind = i2
     2 active_ind = i2
     2 updt_cnt = i4
   1 component_cnt = i4
   1 qual_component[*]
     2 pathway_comp_id = f8
     2 time_frame_id = f8
     2 care_category_id = f8
     2 sequence = i4
     2 active_ind = i2
     2 comp_type_cd = f8
     2 comp_type_disp = c40
     2 comp_type_mean = c12
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 orc_mnemonic = vc
     2 oe_format_id = f8
     2 dcp_clin_cat_cd = f8
     2 orderable_type_flag = i2
     2 ref_text_mask = i4
     2 order_sentence_id = f8
     2 clinical_display_line = vc
     2 sentence_detail_cnt = i4
     2 qual_sentence_detail[*]
       3 sequence = i4
       3 order_sentence_id = f8
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_meaning_id = f8
       3 oe_field_type_flag = i2
     2 duration_seq = i4
     2 duration_unit_seq = i4
     2 linked_to_tf_ind = i2
     2 frequency_seq = i4
     2 reference_task_id = f8
     2 task_description = vc
     2 comp_label = vc
     2 comp_text = vc
     2 text_updt_cnt = i4
     2 comp_long_text_id = f8
     2 required_ind = i2
     2 included_ind = i2
     2 repeat_ind = i2
     2 after_qty = i4
     2 age_units_cd = f8
     2 age_units_disp = c40
     2 age_units_mean = c12
     2 related_comp_id = f8
     2 related_comp_seq = i4
     2 updt_cnt = i4
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 duration_unit_disp = c40
     2 duration_unit_mean = c12
     2 task_assay_cd = f8
     2 event_cd = f8
     2 result_type_cd = f8
     2 result_type_disp = c40
     2 result_type_mean = c12
     2 outcome_operator_cd = f8
     2 outcome_operator_disp = c40
     2 outcome_operator_mean = c12
     2 result_value = f8
     2 result_units_cd = f8
     2 result_units_disp = c40
     2 result_units_mean = c12
     2 capture_variance_ind = i2
     2 variance_required_ind = i2
     2 var_reference_task_id = f8
     2 dcp_forms_ref_id = f8
     2 outcome_forms_ref_id = f8
     2 dcp_form_name = vc
     2 cond_ind = i2
     2 cond_desc = vc
     2 cond_note_id = f8
     2 cond_note = vc
     2 ctext_updt_cnt = i4
     2 cond_module_name = vc
     2 cond_false_ind = i2
     2 rrf_age_qty = i4
     2 rrf_age_units_cd = f8
     2 rrf_age_units_disp = c40
     2 rrf_age_units_mean = c12
     2 rrf_sex_cd = f8
     2 rrf_sex_disp = c40
     2 rrf_sex_mean = c12
     2 outcome_value_descript = vc
     2 event_set_disp = vc
     2 nomen_comp_cnt = i4
     2 qual_comp_nomen[*]
       3 primary_ind = i2
       3 nomenclature_id = f8
   1 relationship_cnt = i4
   1 qual_relationship[*]
     2 dcp_entity_reltn_id = f8
     2 relationship_mean = c12
     2 entity2_id = f8
     2 entity2_display = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 SET cnt1 = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SET cnt4 = 0
 SET cnt5 = 0
 SET cnt6 = 0
 SET count9 = 0
 SET echo_label = fillstring(30," ")
 SET idpathway = 0
 SET idlongtext = 0
 SET idtimeframe = 0
 SET idcarecategory = 0
 SET idcomponent = 0
 SET reply->status_data.status = "F"
 SET cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET note_meaning = "NOTE"
 SET order_create_meaning = "ORDER CREATE"
 SET label_meaning = "LABEL"
 SET outcome_create_meaning = "OUTCOME CREA"
 SET task_create_meaning = "TASK CREATE"
 SET result_outcome_meaning = "RESULT OUTCO"
 SET pw_text_id = 0
 SET comp_text_id = 0
 SET ent_rel_id = 0
 SET parent_entity_name = fillstring(32," ")
 SET rrf_age_qty = 0
 SET rrf_age_units_mean = fillstring(12," ")
 SET task_assay_cd = 0.0
 SET rrf_sex_cd = 0.0
 SET result_value = 0.0
 SET outcome_value_descript = fillstring(255," ")
 SET duration_mean_id = 0.0
 SET duration_unit_mean_id = 0.0
 SET frequency_mean_id = 0.0
 SET code_set = 16750
 SET cdf_meaning = note_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET note_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = order_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET order_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = label_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET label_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = outcome_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET outcome_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = task_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET task_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = result_outcome_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
 SET code_set = 289
 SET cdf_meaning = "2"
 EXECUTE cpm_get_cd_for_cdf
 SET alpha_type_cd = code_value
 SET code_set = 289
 SET cdf_meaning = "5"
 EXECUTE cpm_get_cd_for_cdf
 SET multi_type_cd = code_value
 SELECT INTO "nl:"
  ofm.oe_field_meaning_id, ofm.oe_field_meaning
  FROM oe_field_meaning ofm
  WHERE ((ofm.oe_field_meaning="DURATION") OR (((ofm.oe_field_meaning="DURATIONUNIT") OR (ofm
  .oe_field_meaning="FREQ")) ))
  DETAIL
   IF (ofm.oe_field_meaning="DURATION")
    duration_mean_id = ofm.oe_field_meaning_id
   ELSEIF (ofm.oe_field_meaning="DURATIONUNIT")
    duration_unit_mean_id = ofm.oe_field_meaning_id
   ELSEIF (ofm.oe_field_meaning="FREQ")
    frequency_mean_id = ofm.oe_field_meaning_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pwc.pathway_catalog_id
  FROM pathway_catalog pwc
  WHERE (request->pathway_catalog_id=pwc.pathway_catalog_id)
  HEAD REPORT
   reply->pathway_catalog_id = pwc.pathway_catalog_id, reply->active_ind = pwc.active_ind
   IF (nullind(pwc.beg_effective_dt_tm)=0)
    reply->beg_effective_dt_tm = cnvtdatetime(pwc.beg_effective_dt_tm)
   ENDIF
   IF (nullind(pwc.end_effective_dt_tm)=0)
    reply->end_effective_dt_tm = cnvtdatetime(pwc.end_effective_dt_tm)
   ENDIF
   reply->description = pwc.description, reply->cross_encntr_ind = pwc.cross_encntr_ind, reply->
   restrict_comp_add_ind = pwc.restrict_comp_add_ind,
   reply->restrict_tf_add_ind = pwc.restrict_tf_add_ind, reply->restrict_cc_add_ind = pwc
   .restrict_cc_add_ind, reply->pw_forms_ref_id = pwc.pw_forms_ref_id,
   reply->comp_forms_ref_id = pwc.comp_forms_ref_id, reply->age_units_cd = pwc.age_units_cd, reply->
   long_text_id = pwc.long_text_id,
   reply->updt_cnt = pwc.updt_cnt, reply->version = pwc.version
   IF (nullind(pwc.updt_dt_tm)=0)
    reply->updt_dt_tm = cnvtdatetime(pwc.updt_dt_tm)
   ENDIF
   reply->updt_id = pwc.updt_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt
  WHERE (lt.parent_entity_id=reply->pathway_catalog_id)
   AND lt.parent_entity_name="PATHWAY_CATALOG"
   AND (lt.long_text_id=reply->long_text_id)
  HEAD REPORT
   reply->pw_text = lt.long_text, reply->text_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pf.pathway_catalog_id
  FROM pathway_focus pf,
   nomenclature nom,
   code_value cv,
   code_value cv2
  PLAN (pf
   WHERE (pf.pathway_catalog_id=reply->pathway_catalog_id))
   JOIN (nom
   WHERE nom.nomenclature_id=pf.nomenclature_id)
   JOIN (cv
   WHERE nom.principle_type_cd=cv.code_value)
   JOIN (cv2
   WHERE nom.source_vocabulary_cd=cv2.code_value)
  ORDER BY pf.sequence
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1)
   IF (cnt1 > size(reply->qual_nomen,5))
    stat = alterlist(reply->qual_nomen,(cnt1+ 10))
   ENDIF
   reply->qual_nomen[cnt1].pathway_catalog_id = pf.pathway_catalog_id, reply->qual_nomen[cnt1].
   pathway_focus_id = pf.pathway_focus_id, reply->qual_nomen[cnt1].pathway_level_ind = pf
   .pathway_level_ind,
   reply->qual_nomen[cnt1].nomenclature_id = pf.nomenclature_id, reply->qual_nomen[cnt1].
   default_status_cd = pf.default_status_cd, reply->qual_nomen[cnt1].vocabulary = cv2.display,
   reply->qual_nomen[cnt1].principle_type = cv.display, reply->qual_nomen[cnt1].source_string = nom
   .source_string, reply->qual_nomen[cnt1].updt_cnt = pf.updt_cnt,
   reply->qual_nomen[cnt1].sequence = pf.sequence
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_nomen,cnt1)
 SET reply->nomen_cnt = cnt1
 CALL echo("       ")
 CALL echo(build("nomen_cnt",reply->nomen_cnt))
 CALL echo("       ")
 SELECT INTO "nl:"
  pwc.pathway_catalog_id
  FROM pathway_catalog pwc
  WHERE (reply->pathway_catalog_id=pwc.version_pw_cat_id)
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1)
   IF (cnt1 > size(reply->qual_version,5))
    stat = alterlist(reply->qual_version,(cnt1+ 10))
   ENDIF
   reply->qual_version[cnt1].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual_version[cnt1].
   version = pwc.version
   IF (nullind(pwc.beg_effective_dt_tm)=0)
    reply->qual_version[cnt1].beg_effective_dt_tm = cnvtdatetime(pwc.beg_effective_dt_tm)
   ENDIF
   IF (nullind(pwc.end_effective_dt_tm)=0)
    reply->qual_version[cnt1].end_effective_dt_tm = cnvtdatetime(pwc.end_effective_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_version,cnt1)
 SET reply->version_cnt = cnt1
 SELECT INTO "nl:"
  tf.time_frame_id
  FROM time_frame tf
  WHERE (reply->pathway_catalog_id=tf.pathway_catalog_id)
   AND tf.active_ind=1
  HEAD REPORT
   cnt4 = 0
  DETAIL
   cnt4 = (cnt4+ 1)
   IF (cnt4 > size(reply->qual_time_frame,5))
    stat = alterlist(reply->qual_time_frame,(cnt4+ 10))
   ENDIF
   reply->qual_time_frame[cnt4].time_frame_id = tf.time_frame_id, reply->qual_time_frame[cnt4].
   description = tf.description, reply->qual_time_frame[cnt4].sequence = tf.sequence,
   reply->qual_time_frame[cnt4].active_ind = tf.active_ind, reply->qual_time_frame[cnt4].duration_qty
    = tf.duration_qty, reply->qual_time_frame[cnt4].age_units_cd = tf.age_units_cd,
   reply->qual_time_frame[cnt4].continuous_ind = tf.continuous_ind, reply->qual_time_frame[cnt4].
   start_ind = tf.start_ind, reply->qual_time_frame[cnt4].end_ind = tf.end_ind,
   reply->qual_time_frame[cnt4].updt_cnt = tf.updt_cnt, reply->qual_time_frame[cnt4].
   prnt_time_frame_id = tf.prnt_time_frame_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_time_frame,cnt4)
 SET reply->time_frame_cnt = cnt4
 SELECT INTO "nl:"
  cc.care_category_id
  FROM care_category cc
  WHERE (reply->pathway_catalog_id=cc.pathway_catalog_id)
   AND cc.active_ind=1
  HEAD REPORT
   cnt5 = 0
  DETAIL
   cnt5 = (cnt5+ 1)
   IF (cnt5 > size(reply->qual_care_category,5))
    stat = alterlist(reply->qual_care_category,(cnt5+ 10))
   ENDIF
   reply->qual_care_category[cnt5].care_category_id = cc.care_category_id, reply->qual_care_category[
   cnt5].care_category_cd = cc.care_category_cd, reply->qual_care_category[cnt5].description = cc
   .description,
   reply->qual_care_category[cnt5].sequence = cc.sequence, reply->qual_care_category[cnt5].
   restrict_comp_add_ind = cc.restrict_comp_add_ind, reply->qual_care_category[cnt5].
   comp_add_variance_ind = cc.comp_add_variance_ind,
   reply->qual_care_category[cnt5].active_ind = cc.active_ind, reply->qual_care_category[cnt5].
   updt_cnt = cc.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_care_category,cnt5)
 SET reply->care_category_cnt = cnt5
 SELECT INTO "nl:"
  pc.pathway_comp_id
  FROM pathway_comp pc
  WHERE (pc.pathway_catalog_id=reply->pathway_catalog_id)
   AND pc.active_ind=1
  HEAD REPORT
   cnt6 = 0
  DETAIL
   cnt6 = (cnt6+ 1)
   IF (cnt6 > size(reply->qual_component,5))
    stat = alterlist(reply->qual_component,(cnt6+ 10))
   ENDIF
   reply->qual_component[cnt6].pathway_comp_id = pc.pathway_comp_id, reply->qual_component[cnt6].
   time_frame_id = pc.time_frame_id, reply->qual_component[cnt6].care_category_id = pc
   .care_category_id,
   reply->qual_component[cnt6].sequence = pc.sequence, reply->qual_component[cnt6].active_ind = pc
   .active_ind, reply->qual_component[cnt6].comp_type_cd = pc.comp_type_cd,
   reply->qual_component[cnt6].parent_entity_name = pc.parent_entity_name, reply->qual_component[cnt6
   ].parent_entity_id = pc.parent_entity_id, reply->qual_component[cnt6].order_sentence_id = pc
   .order_sentence_id,
   reply->qual_component[cnt6].comp_label = pc.comp_label, reply->qual_component[cnt6].required_ind
    = pc.required_ind, reply->qual_component[cnt6].included_ind = pc.include_ind,
   reply->qual_component[cnt6].repeat_ind = pc.repeat_ind, reply->qual_component[cnt6].after_qty = pc
   .after_qty, reply->qual_component[cnt6].age_units_cd = pc.age_units_cd,
   reply->qual_component[cnt6].age_units_mean = uar_get_code_meaning(pc.age_units_cd), reply->
   qual_component[cnt6].related_comp_id = pc.related_comp_id, reply->qual_component[cnt6].updt_cnt =
   pc.updt_cnt,
   reply->qual_component[cnt6].cond_ind = pc.cond_ind, reply->qual_component[cnt6].cond_desc = pc
   .cond_desc, reply->qual_component[cnt6].cond_note_id = pc.cond_note_id,
   reply->qual_component[cnt6].cond_module_name = pc.cond_module_name, reply->qual_component[cnt6].
   cond_false_ind = pc.cond_false_ind, reply->qual_component[cnt6].duration_qty = pc.duration_qty,
   reply->qual_component[cnt6].duration_unit_cd = pc.duration_unit_cd, reply->qual_component[cnt6].
   linked_to_tf_ind = pc.linked_to_tf_ind, reply->qual_component[cnt6].task_assay_cd = pc
   .task_assay_cd,
   reply->qual_component[cnt6].event_cd = pc.event_cd, reply->qual_component[cnt6].result_type_cd =
   pc.result_type_cd, reply->qual_component[cnt6].outcome_operator_cd = pc.outcome_operator_cd,
   reply->qual_component[cnt6].result_value = pc.result_value, reply->qual_component[cnt6].
   result_units_cd = pc.result_units_cd, reply->qual_component[cnt6].capture_variance_ind = pc
   .capture_variance_ind,
   reply->qual_component[cnt6].variance_required_ind = pc.variance_required_ind, reply->
   qual_component[cnt6].dcp_forms_ref_id = pc.dcp_forms_ref_id, reply->qual_component[cnt6].
   outcome_forms_ref_id = pc.outcome_forms_ref_id,
   reply->qual_component[cnt6].var_reference_task_id = pc.reference_task_id, reply->qual_component[
   cnt6].rrf_age_qty = pc.rrf_age_qty, reply->qual_component[cnt6].rrf_age_units_cd = pc
   .rrf_age_units_cd,
   reply->qual_component[cnt6].rrf_sex_cd = pc.rrf_sex_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_component,cnt6)
 SET reply->component_cnt = cnt6
 FOR (cnt6 = 1 TO reply->component_cnt)
  SELECT INTO "nl:"
   pcf.nomenclature_id, pcf.primary_ind
   FROM pathway_comp_focus_r pcf
   WHERE (pcf.pathway_comp_id=reply->qual_component[cnt6].pathway_comp_id)
   HEAD REPORT
    count9 = 0
   DETAIL
    count9 = (count9+ 1)
    IF (count9 > size(reply->qual_component[cnt6].qual_comp_nomen,5))
     stat = alterlist(reply->qual_component[cnt6].qual_comp_nomen,(count9+ 10))
    ENDIF
    reply->qual_component[cnt6].qual_comp_nomen[count9].nomenclature_id = pcf.nomenclature_id, reply
    ->qual_component[cnt6].qual_comp_nomen[count9].primary_ind = pcf.primary_ind
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->qual_component[cnt6].nomen_comp_cnt = 0
  ELSE
   SET stat = alterlist(reply->qual_component[cnt6].qual_comp_nomen,count9)
   SET reply->qual_component[cnt6].nomen_comp_cnt = count9
  ENDIF
 ENDFOR
 FOR (cnt6 = 1 TO reply->component_cnt)
  CASE (reply->qual_component[cnt6].comp_type_cd)
   OF note_type_cd:
    EXECUTE FROM note_comp TO note_comp_end
   OF order_create_type_cd:
    EXECUTE FROM create_orc_comp TO create_orc_comp_end
   OF outcome_create_type_cd:
    EXECUTE FROM create_orc_comp TO create_orc_comp_end
   OF task_create_type_cd:
    EXECUTE FROM create_task_comp TO create_task_comp_end
   OF result_outcome_type_cd:
    EXECUTE FROM result_comp TO result_comp_end
  ENDCASE
  IF ((reply->qual_component[cnt6].cond_ind=1))
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE (lt.parent_entity_id=reply->qual_component[cnt6].pathway_comp_id)
     AND lt.parent_entity_name="PATHWAY_COMP"
     AND (lt.long_text_id=reply->qual_component[cnt6].cond_note_id)
    HEAD REPORT
     reply->qual_component[cnt6].cond_note = lt.long_text, reply->qual_component[cnt6].ctext_updt_cnt
      = lt.updt_cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  der.dcp_entity_reltn_id
  FROM dcp_entity_reltn der
  WHERE (der.entity1_id=reply->pathway_catalog_id)
   AND der.entity_reltn_mean="PWC/DIAGN"
  HEAD REPORT
   cnt3 = 0
  DETAIL
   cnt3 = (cnt3+ 1)
   IF (cnt3 > size(reply->qual_relationship,5))
    stat = alterlist(reply->qual_relationship,(cnt3+ 10))
   ENDIF
   reply->qual_relationship[cnt3].dcp_entity_reltn_id = der.dcp_entity_reltn_id, reply->
   qual_relationship[cnt3].relationship_mean = der.entity_reltn_mean, reply->qual_relationship[cnt3].
   entity2_id = der.entity2_id,
   reply->qual_relationship[cnt3].entity2_display = der.entity2_display, reply->qual_relationship[
   cnt3].updt_cnt = der.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual_relationship,cnt3)
 SET reply->relationship_cnt = cnt3
 FOR (cnt3 = 1 TO reply->relationship_cnt)
   CASE (reply->qual_relationship[cnt3].relationship_mean)
    OF "PW\DIAGN":
     EXECUTE FROM diagn_reltn TO diagn_reltn_end
   ENDCASE
 ENDFOR
 GO TO exit_script
#diagn_reltn
 SELECT INTO "nl:"
  nc.nomenclature_id
  FROM nomenclature nc
  WHERE (nc.nomenclature_id=reply->qual_relationship[cnt3].entity2_id)
  HEAD REPORT
   reply->qual_relationship[cnt3].entity2_display = nc.source_string
  WITH nocounter
 ;end select
#diagn_reltn_end
#note_comp
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt
  WHERE (lt.parent_entity_id=reply->qual_component[cnt6].pathway_comp_id)
   AND lt.parent_entity_name="PATHWAY_COMP"
   AND (lt.long_text_id=reply->qual_component[cnt6].parent_entity_id)
  HEAD REPORT
   reply->qual_component[cnt6].comp_text = lt.long_text, reply->qual_component[cnt6].
   comp_long_text_id = lt.long_text_id, reply->qual_component[cnt6].text_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
#note_comp_end
#create_orc_comp
 SELECT INTO "nl:"
  ocs.synonym_id
  FROM order_catalog_synonym ocs
  WHERE (ocs.synonym_id=reply->qual_component[cnt6].parent_entity_id)
  HEAD REPORT
   reply->qual_component[cnt6].synonym_id = ocs.synonym_id, reply->qual_component[cnt6].catalog_cd =
   ocs.catalog_cd, reply->qual_component[cnt6].catalog_type_cd = ocs.catalog_type_cd,
   reply->qual_component[cnt6].activity_type_cd = ocs.activity_type_cd, reply->qual_component[cnt6].
   orc_mnemonic = ocs.mnemonic, reply->qual_component[cnt6].oe_format_id = ocs.oe_format_id,
   reply->qual_component[cnt6].dcp_clin_cat_cd = ocs.dcp_clin_cat_cd, reply->qual_component[cnt6].
   orderable_type_flag = ocs.orderable_type_flag, reply->qual_component[cnt6].ref_text_mask = ocs
   .ref_text_mask
  WITH nocounter
 ;end select
 IF ((reply->qual_component[cnt6].order_sentence_id > 0))
  SELECT INTO "nl:"
   os.order_sentence_id
   FROM order_sentence os
   WHERE (os.order_sentence_id=reply->qual_component[cnt6].order_sentence_id)
   HEAD REPORT
    reply->qual_component[cnt6].clinical_display_line = os.order_sentence_display_line
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    osd.order_sentence_id
    FROM order_sentence_detail osd
    WHERE (osd.order_sentence_id=reply->qual_component[cnt6].order_sentence_id)
    HEAD REPORT
     cnt2 = 0
    DETAIL
     cnt2 = (cnt2+ 1)
     IF (cnt2 > size(reply->qual_component[cnt6].qual_sentence_detail,5))
      stat = alterlist(reply->qual_component[cnt6].qual_sentence_detail,(cnt2+ 10))
     ENDIF
     reply->qual_component[cnt6].qual_sentence_detail[cnt2].sequence = osd.sequence, reply->
     qual_component[cnt6].qual_sentence_detail[cnt2].order_sentence_id = osd.order_sentence_id, reply
     ->qual_component[cnt6].qual_sentence_detail[cnt2].oe_field_id = osd.oe_field_id,
     reply->qual_component[cnt6].qual_sentence_detail[cnt2].oe_field_value = osd.oe_field_value,
     reply->qual_component[cnt6].qual_sentence_detail[cnt2].oe_field_display_value = osd
     .oe_field_display_value, reply->qual_component[cnt6].qual_sentence_detail[cnt2].
     oe_field_meaning_id = osd.oe_field_meaning_id,
     reply->qual_component[cnt6].qual_sentence_detail[cnt2].oe_field_type_flag = osd.field_type_flag
     IF (osd.oe_field_meaning_id=duration_mean_id)
      reply->qual_component[cnt6].duration_seq = cnt2
     ENDIF
     IF (osd.oe_field_meaning_id=duration_unit_mean_id)
      reply->qual_component[cnt6].duration_unit_seq = cnt2
     ENDIF
     IF (osd.oe_field_meaning_id=frequency_mean_id)
      reply->qual_component[cnt6].frequency_seq = cnt2
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->qual_component[cnt6].qual_sentence_detail,cnt2)
   SET reply->qual_component[cnt6].sentence_detail_cnt = cnt2
  ENDIF
 ENDIF
#create_orc_comp_end
#create_task_comp
 SELECT INTO "nl:"
  ot.reference_task_id
  FROM order_task ot
  WHERE (ot.reference_task_id=reply->qual_component[cnt6].parent_entity_id)
  HEAD REPORT
   reply->qual_component[cnt6].reference_task_id = ot.reference_task_id, reply->qual_component[cnt6].
   task_description = ot.task_description
  WITH nocounter
 ;end select
#create_task_comp_end
#result_comp
 SELECT INTO "nl:"
  vec.event_cd
  FROM v500_event_code vec,
   v500_event_set_code vesc
  PLAN (vec
   WHERE (vec.event_cd=reply->qual_component[cnt6].event_cd))
   JOIN (vesc
   WHERE cnvtupper(vesc.event_set_name)=cnvtupper(vec.event_set_name))
  HEAD REPORT
   reply->qual_component[cnt6].event_set_disp = vesc.event_set_cd_disp
  WITH nocounter
 ;end select
 IF ((((reply->qual_component[cnt6].result_type_cd=alpha_type_cd)) OR ((reply->qual_component[cnt6].
 result_type_cd=multi_type_cd))) )
  SET rrf_age_qty = reply->qual_component[cnt6].rrf_age_qty
  SET rrf_age_units_mean = reply->qual_component[cnt6].rrf_age_units_mean
  SET task_assay_cd = reply->qual_component[cnt6].task_assay_cd
  SET rrf_sex_cd = reply->qual_component[cnt6].rrf_sex_cd
  SET result_value = reply->qual_component[cnt6].result_value
  SET outcome_value_descript = fillstring(255," ")
  SET count1 = 0
  SET rr_id = 0.00
  SET first_one = "Y"
  SET age_in_minutes = 0.0
  SET code_set = 226
  SET cdf_meaning = "HUMAN"
  EXECUTE cpm_get_cd_for_cdf
  SET human_type_cd = code_value
  IF (rrf_age_units_mean="HOURS")
   SET age_in_minutes = (rrf_age_qty * 60)
  ELSEIF (rrf_age_units_mean="DAYS")
   SET age_in_minutes = ((rrf_age_qty * 60) * 24)
  ELSEIF (rrf_age_units_mean="WEEKS")
   SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 7)
  ELSEIF (rrf_age_units_mean="MONTHS")
   SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 30)
  ELSEIF (rrf_age_units_mean="YEARS")
   SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 365.25)
  ENDIF
  SELECT INTO "nl:"
   r.reference_range_factor_id, a.reference_range_factor_id, a.nomenclature_id,
   a.description
   FROM reference_range_factor r,
    alpha_responses a,
    (dummyt d1  WITH seq = 1)
   PLAN (r
    WHERE r.task_assay_cd=task_assay_cd
     AND r.active_ind=1
     AND r.species_cd=human_type_cd
     AND r.organism_cd=0.00
     AND r.service_resource_cd=0.00
     AND r.gestational_ind=0
     AND r.unknown_age_ind=0
     AND ((r.sex_cd=rrf_sex_cd) OR (r.sex_cd=0.00))
     AND r.age_from_minutes <= age_in_minutes
     AND r.age_to_minutes >= age_in_minutes)
    JOIN (d1)
    JOIN (a
    WHERE a.reference_range_factor_id=r.reference_range_factor_id)
   ORDER BY r.sex_cd DESC, r.precedence_sequence, r.reference_range_factor_id
   HEAD REPORT
    rr_id = 0.00, first_one = "Y"
   HEAD r.reference_range_factor_id
    count1 = 0
    IF (first_one="Y")
     rr_id = r.reference_range_factor_id
    ENDIF
   DETAIL
    IF (((rr_id=r.reference_range_factor_id) OR (first_one="Y")) )
     first_one = "N"
     IF (a.reference_range_factor_id > 0)
      IF (a.result_value=result_value)
       count1 = (count1+ 1)
       IF (count1=1)
        outcome_value_descript = a.description
       ELSE
        outcome_value_descript = concat(trim(outcome_value_descript),", ",trim(a.description))
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET reply->qual_component[cnt6].outcome_value_descript = trim(outcome_value_descript)
 ENDIF
 IF ((reply->qual_component[cnt6].var_reference_task_id > 0))
  SELECT INTO "nl:"
   ot.reference_task_id, ot.dcp_forms_ref_id
   FROM order_task ot
   WHERE (ot.reference_task_id=reply->qual_component[cnt6].var_reference_task_id)
   DETAIL
    reply->qual_component[cnt6].dcp_forms_ref_id = ot.dcp_forms_ref_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->qual_component[cnt6].capture_variance_ind=1)
  AND (reply->qual_component[cnt6].dcp_forms_ref_id > 0))
  SELECT INTO "nl:"
   dfr.dcp_forms_ref_id
   FROM dcp_forms_ref dfr
   WHERE (dfr.dcp_forms_ref_id=reply->qual_component[cnt6].dcp_forms_ref_id)
   HEAD REPORT
    reply->qual_component[cnt6].dcp_form_name = dfr.description
   WITH nocounter
  ;end select
 ENDIF
#result_comp_end
#exit_script
END GO
