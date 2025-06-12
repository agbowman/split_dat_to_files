CREATE PROGRAM dcp_add_plan_catalog
 SET modify = predeclare
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ccluarxrtl
 DECLARE plan_cnt = i4 WITH constant(value(size(request->planlist,5))), protect
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00"), protect
 DECLARE reltn_type_cd = f8 WITH constant(uar_get_code_by("MEANING",29753,"PLANANDDX")), protect
 SET pw_def_dose_calc_method_table_exists = checkdic("PW_DEF_DOSE_CALC_METHOD","T",0)
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE j = i4 WITH noconstant(0), protect
 DECLARE parent_entity_name = c32 WITH noconstant(fillstring(32," ")), protect
 DECLARE parent_entity_id = f8 WITH noconstant(0.0), protect
 DECLARE cfailed = c1 WITH noconstant("F"), protect
 DECLARE long_text_id = f8 WITH noconstant(0.0), protect
 DECLARE comp_text_id = f8 WITH noconstant(0.0), protect
 DECLARE plan_r_cnt = i4 WITH noconstant(0), protect
 DECLARE comp_cnt = i4 WITH noconstant(0), protect
 DECLARE ord_sent_cnt = i4 WITH noconstant(0), protect
 DECLARE plan_evidence_r_cnt = i4 WITH noconstant(0), protect
 DECLARE comp_r_cnt = i4 WITH noconstant(0), protect
 DECLARE facility_cnt = i4 WITH noconstant(0), protect
 DECLARE pathwayid = f8 WITH noconstant(0.0), protect
 DECLARE facility_flexing_description = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE problem_cnt = i4 WITH noconstant(0), protect
 DECLARE concept_cki_entity_r_id = f8 WITH noconstant(0.0), protect
 DECLARE group_cnt = i4 WITH noconstant(0), protect
 DECLARE group_comp_cnt = i4 WITH noconstant(0), protect
 DECLARE comp_phase_r_cnt = i4 WITH noconstant(0), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE cycle_cd = f8 WITH constant(uar_get_code_by("MEANING",4002313,"CYCLE")), protect
 DECLARE plan_synonym_cnt = i4 WITH noconstant(0), protect
 DECLARE methodpairreltnidx = i4 WITH noconstant(0), protect
 DECLARE nbr_addpairs = i4 WITH noconstant(0), protect
 FOR (i = 1 TO plan_cnt)
   IF ((((request->planlist[i].type_mean="PATHWAY")) OR ((((request->planlist[i].type_mean="CAREPLAN"
   )) OR ((request->planlist[i].type_mean="TAPERPLAN"))) )) )
    SET pathwayid = request->planlist[i].pathway_catalog_id
    IF ((request->planlist[i].display_description > ""))
     SET facility_flexing_description = request->planlist[i].display_description
    ELSE
     SET facility_flexing_description = request->planlist[i].description
    ENDIF
   ENDIF
   SET long_text_id = 0.0
   IF ((request->planlist[i].comment_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = nextseqnum
     WITH nocounter
    ;end select
    IF (long_text_id=0.0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
      "Unable to generate new long_text_id for pathway note")
     GO TO exit_script
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = long_text_id, lt.parent_entity_name = "PATHWAY_CATALOG", lt
      .parent_entity_id = request->planlist[i].pathway_catalog_id,
      lt.long_text = request->planlist[i].comment_text, lt.active_ind = 1, lt.active_status_cd =
      reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
      "Unable to insert pathway note into LONG_TEXT")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->planlist[i].cycle_ind=1)
    AND (request->planlist[i].cycle_label_cd <= 0.0))
    SET request->planlist[i].cycle_label_cd = cycle_cd
   ENDIF
   DECLARE phaseuuid = vc WITH protect
   SET phaseuuid = validate(request->planlist[i].uuid,"")
   IF (size(phaseuuid,1) <= 0)
    SET phaseuuid = uar_createuuid(0)
   ENDIF
   INSERT  FROM pathway_catalog pc
    SET pc.pathway_catalog_id = request->planlist[i].pathway_catalog_id, pc.type_mean = request->
     planlist[i].type_mean, pc.active_ind =
     IF ((request->planlist[i].type_mean IN ("PHASE", "DOT"))) 1
     ELSE request->planlist[i].active_ind
     ENDIF
     ,
     pc.cross_encntr_ind = request->planlist[i].cross_encntr_ind, pc.description = trim(request->
      planlist[i].description), pc.description_key = trim(cnvtupper(request->planlist[i].description)
      ),
     pc.long_text_id = long_text_id, pc.version =
     IF ((request->planlist[i].version > 0)
      AND  NOT ((request->planlist[i].type_mean IN ("PHASE", "DOT")))) request->planlist[i].version
     ELSEIF ( NOT ((request->planlist[i].type_mean IN ("PHASE", "DOT")))) 1
     ELSE 0
     ENDIF
     , pc.version_pw_cat_id =
     IF ((request->planlist[i].version_pw_cat_id > 0)
      AND  NOT ((request->planlist[i].type_mean IN ("PHASE", "DOT")))) request->planlist[i].
      version_pw_cat_id
     ELSEIF ( NOT ((request->planlist[i].type_mean IN ("PHASE", "DOT")))) request->planlist[i].
      pathway_catalog_id
     ELSE 0.0
     ENDIF
     ,
     pc.beg_effective_dt_tm =
     IF ((((request->planlist[i].type_mean IN ("PHASE", "DOT"))) OR (validate(request->testing_ind,0)
     =0)) ) cnvtdatetime(sysdate)
     ELSE cnvtdatetime(end_date_string)
     ENDIF
     , pc.end_effective_dt_tm = cnvtdatetime(end_date_string), pc.duration_qty = request->planlist[i]
     .duration_qty,
     pc.duration_unit_cd = request->planlist[i].duration_unit_cd, pc.pathway_type_cd = request->
     planlist[i].pathway_type_cd, pc.display_method_cd = request->planlist[i].display_method_cd,
     pc.ref_owner_person_id =
     IF ((request->planlist[i].flex_parent_entity_id > 0)) request->planlist[i].flex_parent_entity_id
     ELSE 0
     ENDIF
     , pc.display_description =
     IF ((request->planlist[i].display_description > "")
      AND (((request->planlist[i].type_mean="PATHWAY")) OR ((((request->planlist[i].type_mean=
     "CAREPLAN")) OR ((request->planlist[i].type_mean="TAPERPLAN"))) )) ) trim(request->planlist[i].
       display_description)
     ELSEIF ((((request->planlist[i].type_mean="PATHWAY")) OR ((((request->planlist[i].type_mean=
     "CAREPLAN")) OR ((request->planlist[i].type_mean="TAPERPLAN"))) )) ) trim(request->planlist[i].
       description)
     ELSE ""
     ENDIF
     , pc.sub_phase_ind =
     IF ((request->planlist[i].sub_phase_ind > 0)) request->planlist[i].sub_phase_ind
     ELSE 0
     ENDIF
     ,
     pc.hide_flexed_comp_ind =
     IF ((request->planlist[i].hide_flexed_comp_ind > 0)) request->planlist[i].hide_flexed_comp_ind
     ELSE 0
     ENDIF
     , pc.cycle_ind = request->planlist[i].cycle_ind, pc.standard_cycle_nbr = request->planlist[i].
     standard_cycle_nbr,
     pc.cycle_begin_nbr = request->planlist[i].cycle_begin_nbr, pc.cycle_end_nbr = request->planlist[
     i].cycle_end_nbr, pc.cycle_label_cd = request->planlist[i].cycle_label_cd,
     pc.cycle_display_end_ind = request->planlist[i].cycle_display_end_ind, pc.cycle_lock_end_ind =
     request->planlist[i].cycle_lock_end_ind, pc.cycle_increment_nbr = request->planlist[i].
     cycle_increment_nbr,
     pc.default_action_inpt_future_cd = request->planlist[i].default_action_inpt_future_cd, pc
     .default_action_inpt_now_cd = request->planlist[i].default_action_inpt_now_cd, pc
     .default_action_outpt_future_cd = request->planlist[i].default_action_outpt_future_cd,
     pc.default_action_outpt_now_cd = request->planlist[i].default_action_outpt_now_cd, pc
     .optional_ind = request->planlist[i].optional_ind, pc.future_ind = request->planlist[i].
     future_ind,
     pc.default_visit_type_flag = request->planlist[i].default_visit_type_flag, pc
     .prompt_on_selection_ind = request->planlist[i].prompt_on_selection_ind, pc.pathway_class_cd =
     request->planlist[i].pathway_class_cd,
     pc.linked_phase_ind = validate(request->planlist[i].linked_phase_ind,0), pc.default_view_mean =
     request->planlist[i].default_view_mean, pc.diagnosis_capture_ind = request->planlist[i].
     diagnosis_capture_ind,
     pc.provider_prompt_ind = request->planlist[i].provider_prompt_ind, pc.allow_copy_forward_ind =
     request->planlist[i].allow_copy_forward_ind, pc.auto_initiate_ind = request->planlist[i].
     auto_initiate_ind,
     pc.alerts_on_plan_ind = request->planlist[i].alerts_on_plan_ind, pc.alerts_on_plan_upd_ind =
     request->planlist[i].alerts_on_plan_upd_ind, pc.period_nbr = request->planlist[i].period_nbr,
     pc.period_custom_label = request->planlist[i].period_custom_label, pc.route_for_review_ind =
     request->planlist[i].route_for_review_ind, pc.default_start_time_txt = trim(validate(request->
       planlist[i].default_start_time_txt,"")),
     pc.primary_ind = validate(request->planlist[i].primary_ind,0), pc.pathway_uuid = trim(phaseuuid),
     pc.restricted_actions_bitmask = validate(request->planlist[i].restricted_actions_bitmask,0),
     pc.open_by_default_ind = validate(request->planlist[i].open_by_default_ind,0), pc
     .review_required_sig_count = validate(request->planlist[i].review_required_sig_count,0), pc
     .override_mrd_on_plan_ind = validate(request->planlist[i].override_mrd_on_plan_ind,0),
     pc.reschedule_reason_accept_flag = validate(request->planlist[i].reschedule_reason_accept_flag,0
      ), pc.disable_activate_all_ind = evaluate(request->planlist[i].allow_activate_all_ind,1,0,0,1),
     pc.updt_dt_tm = cnvtdatetime(sysdate),
     pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
     updt_applctx,
     pc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG","Unable to insert into PATHWAY_CATALOG")
    GO TO exit_script
   ENDIF
   IF ((request->planlist[i].flex_parent_entity_id > 0))
    INSERT  FROM pw_cat_flex pcf
     SET pcf.display_description_key =
      IF ((request->planlist[i].display_description > "")) cnvtupper(trim(request->planlist[i].
         display_description))
      ELSE cnvtupper(trim(request->planlist[i].description))
      ENDIF
      , pcf.pathway_catalog_id = request->planlist[i].pathway_catalog_id, pcf.parent_entity_id =
      request->planlist[i].flex_parent_entity_id,
      pcf.parent_entity_name = request->planlist[i].flex_parent_entity_name, pcf.updt_dt_tm =
      cnvtdatetime(sysdate), pcf.updt_id = reqinfo->updt_id,
      pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG","Unable to insert into PW_CAT_FLEX")
     GO TO exit_script
    ENDIF
   ENDIF
   SET comp_cnt = value(size(request->planlist[i].complist,5))
   FOR (j = 1 TO comp_cnt)
     IF ((request->planlist[i].complist[j].comp_type_mean="NOTE")
      AND (request->planlist[i].complist[j].comp_text != null))
      SET comp_text_id = 0.0
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        comp_text_id = nextseqnum
       WITH nocounter
      ;end select
      IF (comp_text_id=0.0)
       CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
        "Unable to generate new long_text_id for pathway component")
       GO TO exit_script
      ENDIF
      INSERT  FROM long_text lt
       SET lt.long_text_id = comp_text_id, lt.parent_entity_name = "PATHWAY_COMP", lt
        .parent_entity_id = request->planlist[i].complist[j].pathway_comp_id,
        lt.long_text = request->planlist[i].complist[j].comp_text, lt.active_ind = 1, lt
        .active_status_cd = reqdata->active_status_cd,
        lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
        lt.updt_dt_tm = cnvtdatetime(sysdate),
        lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
        lt.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
        "Unable to insert note component into long_text")
       GO TO exit_script
      ENDIF
     ENDIF
     SET parent_entity_name = fillstring(32," ")
     SET parent_entity_id = 0.0
     IF ((request->planlist[i].complist[j].comp_type_mean="NOTE"))
      SET parent_entity_name = "LONG_TEXT"
      SET parent_entity_id = comp_text_id
     ELSEIF ((request->planlist[i].complist[j].comp_type_mean IN ("ORDER CREATE", "PRESCRIPTION")))
      SET parent_entity_name = "ORDER_CATALOG_SYNONYM"
      SET parent_entity_id = request->planlist[i].complist[j].synonym_id
     ELSEIF ((request->planlist[i].complist[j].comp_type_mean="RESULT OUTCO"))
      SET parent_entity_name = "OUTCOME_CATALOG"
      SET parent_entity_id = request->planlist[i].complist[j].outcome_catalog_id
     ELSEIF ((request->planlist[i].complist[j].comp_type_mean="SUBPHASE"))
      SET parent_entity_name = "PATHWAY_CATALOG"
      SET parent_entity_id = request->planlist[i].complist[j].sub_phase_catalog_id
     ENDIF
     DECLARE componentuuid = vc WITH protect
     SET componentuuid = validate(request->planlist[i].complist[j].uuid,"")
     IF (size(componentuuid,1) <= 0)
      SET componentuuid = uar_createuuid(0)
     ENDIF
     DECLARE displayformatxml = vc WITH protect
     SET displayformatxml = trim(validate(request->planlist[i].complist[j].display_format_xml,""))
     INSERT  FROM pathway_comp pwc
      SET pwc.pathway_comp_id = request->planlist[i].complist[j].pathway_comp_id, pwc
       .pathway_catalog_id = request->planlist[i].pathway_catalog_id, pwc.sequence = request->
       planlist[i].complist[j].sequence,
       pwc.active_ind = 1, pwc.comp_type_cd = request->planlist[i].complist[j].comp_type_cd, pwc
       .parent_entity_name = parent_entity_name,
       pwc.parent_entity_id = parent_entity_id, pwc.dcp_clin_cat_cd = request->planlist[i].complist[j
       ].dcp_clin_cat_cd, pwc.dcp_clin_sub_cat_cd = request->planlist[i].complist[j].
       dcp_clin_sub_cat_cd,
       pwc.required_ind = request->planlist[i].complist[j].required_ind, pwc.include_ind = request->
       planlist[i].complist[j].include_ind, pwc.linked_to_tf_ind = request->planlist[i].complist[j].
       linked_to_tf_ind,
       pwc.persistent_ind = request->planlist[i].complist[j].persistent_ind, pwc.duration_qty =
       request->planlist[i].complist[j].duration_qty, pwc.duration_unit_cd = request->planlist[i].
       complist[j].duration_unit_cd,
       pwc.target_type_cd = request->planlist[i].complist[j].target_type_cd, pwc.expand_qty = request
       ->planlist[i].complist[j].expand_qty, pwc.expand_unit_cd = request->planlist[i].complist[j].
       expand_unit_cd,
       pwc.comp_label = request->planlist[i].complist[j].comp_label, pwc.offset_quantity = request->
       planlist[i].complist[j].offset_quantity, pwc.offset_unit_cd = request->planlist[i].complist[j]
       .offset_unit_cd,
       pwc.cross_phase_group_desc = request->planlist[i].complist[j].cross_phase_group_desc, pwc
       .cross_phase_group_nbr = request->planlist[i].complist[j].cross_phase_group_nbr, pwc.chemo_ind
        = request->planlist[i].complist[j].chemo_ind,
       pwc.chemo_related_ind = request->planlist[i].complist[j].chemo_related_ind, pwc.default_os_ind
        = validate(request->planlist[i].complist[j].default_os_ind,1), pwc.min_tolerance_interval =
       request->planlist[i].complist[j].min_tolerance_interval,
       pwc.min_tolerance_interval_unit_cd = request->planlist[i].complist[j].
       min_tolerance_interval_unit_cd, pwc.pathway_uuid = trim(componentuuid), pwc.display_format_xml
        =
       IF (displayformatxml != null) displayformatxml
       ELSE "<xml />"
       ENDIF
       ,
       pwc.lock_target_dose_flag = request->planlist[i].complist[j].lock_target_dose_flag, pwc
       .updt_dt_tm = cnvtdatetime(sysdate), pwc.updt_id = reqinfo->updt_id,
       pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->updt_applctx, pwc.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG","Unable to insert into PATHWAY_COMP")
      GO TO exit_script
     ENDIF
     IF ((request->planlist[i].complist[j].comp_type_mean IN ("ORDER CREATE", "PRESCRIPTION")))
      SET ord_sent_cnt = value(size(request->planlist[i].complist[j].ordsentlist,5))
      IF (ord_sent_cnt > 0)
       INSERT  FROM pw_comp_os_reltn pcor,
         (dummyt d  WITH seq = value(ord_sent_cnt))
        SET pcor.order_sentence_id = request->planlist[i].complist[j].ordsentlist[d.seq].
         order_sentence_id, pcor.order_sentence_seq = request->planlist[i].complist[j].ordsentlist[d
         .seq].order_sentence_seq, pcor.pathway_comp_id = request->planlist[i].complist[j].
         pathway_comp_id,
         pcor.iv_comp_syn_id = request->planlist[i].complist[j].ordsentlist[d.seq].iv_comp_syn_id,
         pcor.normalized_dose_unit_ind = request->planlist[i].complist[j].ordsentlist[d.seq].
         normalized_dose_unit_ind, pcor.updt_dt_tm = cnvtdatetime(sysdate),
         pcor.updt_id = reqinfo->updt_id, pcor.updt_task = reqinfo->updt_task, pcor.updt_applctx =
         reqinfo->updt_applctx,
         pcor.updt_cnt = 0
        PLAN (d)
         JOIN (pcor)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
         "Failed to insert a new row into PW_COMP_OS_RELTN table")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     IF (pw_def_dose_calc_method_table_exists)
      FOR (methodpairreltnidx = 1 TO size(request->planlist[i].complist[j].
       qual_defaultmethodpairreltn,5))
       SET nbr_addpairs = size(request->planlist[i].complist[j].qual_defaultmethodpairreltn[
        methodpairreltnidx].qual_methodpair,5)
       IF (nbr_addpairs > 0)
        INSERT  FROM pw_def_dose_calc_method pddcm,
          (dummyt d  WITH seq = value(nbr_addpairs))
         SET pddcm.pathway_comp_id = request->planlist[i].complist[j].pathway_comp_id, pddcm
          .pw_def_dose_calc_method_id = seq(reference_seq,nextval), pddcm.facility_cd = request->
          planlist[i].complist[j].qual_defaultmethodpairreltn[methodpairreltnidx].facility_cd,
          pddcm.method_cd = request->planlist[i].complist[j].qual_defaultmethodpairreltn[
          methodpairreltnidx].qual_methodpair[d.seq].method_cd, pddcm.method_mean = request->
          planlist[i].complist[j].qual_defaultmethodpairreltn[methodpairreltnidx].qual_methodpair[d
          .seq].method_mean, pddcm.updt_dt_tm = cnvtdatetime(sysdate),
          pddcm.updt_id = reqinfo->updt_id, pddcm.updt_cnt = 0, pddcm.updt_task = reqinfo->updt_task,
          pddcm.updt_applctx = reqinfo->updt_applctx
         PLAN (d)
          JOIN (pddcm)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         CALL report_failure("INSERT","F","PW_DEF_DOSE_CALC_METHOD",
          "Failed to insert new row into PW_DEF_DOSE_CALC_METHOD table")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   SET group_cnt = value(size(request->planlist[i].compgrouplist,5))
   FOR (j = 1 TO group_cnt)
    SET group_comp_cnt = value(size(request->planlist[i].compgrouplist[j].memberlist,5))
    IF (group_comp_cnt > 0)
     INSERT  FROM pw_comp_group pwcg,
       (dummyt d  WITH seq = value(group_comp_cnt))
      SET pwcg.pathway_catalog_id = request->planlist[i].pathway_catalog_id, pwcg.pw_comp_group_id =
       request->planlist[i].compgrouplist[j].pw_comp_group_id, pwcg.type_mean = request->planlist[i].
       compgrouplist[j].type_mean,
       pwcg.pathway_comp_id = request->planlist[i].compgrouplist[j].memberlist[d.seq].pathway_comp_id,
       pwcg.comp_seq = request->planlist[i].compgrouplist[j].memberlist[d.seq].comp_seq, pwcg
       .anchor_component_ind = request->planlist[i].compgrouplist[j].memberlist[d.seq].
       anchor_component_ind,
       pwcg.description = trim(request->planlist[i].compgrouplist[j].description), pwcg
       .linking_rule_flag = request->planlist[i].compgrouplist[j].linking_rule_flag, pwcg
       .linking_rule_quantity = request->planlist[i].compgrouplist[j].linking_rule_quantity,
       pwcg.override_reason_flag = request->planlist[i].compgrouplist[j].override_reason_flag, pwcg
       .updt_dt_tm = cnvtdatetime(sysdate), pwcg.updt_id = reqinfo->updt_id,
       pwcg.updt_task = reqinfo->updt_task, pwcg.updt_applctx = reqinfo->updt_applctx, pwcg.updt_cnt
        = 0
      PLAN (d)
       JOIN (pwcg)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
       "Failed to insert a new row into PW_COMP_GROUP table")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
   SET comp_r_cnt = value(size(request->planlist[i].compreltnlist,5))
   IF (comp_r_cnt > 0)
    INSERT  FROM pw_comp_reltn pcr,
      (dummyt d  WITH seq = value(comp_r_cnt))
     SET pcr.pathway_comp_s_id = request->planlist[i].compreltnlist[d.seq].pathway_comp_s_id, pcr
      .pathway_comp_t_id = request->planlist[i].compreltnlist[d.seq].pathway_comp_t_id, pcr.type_mean
       = request->planlist[i].compreltnlist[d.seq].type_mean,
      pcr.offset_quantity = request->planlist[i].compreltnlist[d.seq].offset_quantity, pcr
      .offset_unit_cd = request->planlist[i].compreltnlist[d.seq].offset_unit_cd, pcr
      .pathway_catalog_id = request->planlist[i].compreltnlist[d.seq].pathway_catalog_id,
      pcr.updt_dt_tm = cnvtdatetime(sysdate), pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo
      ->updt_task,
      pcr.updt_cnt = 0, pcr.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (pcr)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
      "Failed to insert new row(s) into PW_COMP_RELTN table")
     GO TO exit_script
    ENDIF
   ENDIF
   SET plan_synonym_cnt = value(size(request->planlist[i].synonymlist,5))
   IF (plan_synonym_cnt > 0)
    INSERT  FROM pw_cat_synonym pcs,
      (dummyt d  WITH seq = value(plan_synonym_cnt))
     SET pcs.pw_cat_synonym_id = seq(reference_seq,nextval), pcs.pathway_catalog_id = request->
      planlist[i].pathway_catalog_id, pcs.synonym_name = request->planlist[i].synonymlist[d.seq].
      synonym_name,
      pcs.synonym_name_key = trim(cnvtupper(request->planlist[i].synonymlist[d.seq].synonym_name)),
      pcs.primary_ind =
      IF (d.seq=1) 1
      ELSE 0
      ENDIF
      , pcs.updt_dt_tm = cnvtdatetime(sysdate),
      pcs.updt_id = reqinfo->updt_id, pcs.updt_task = reqinfo->updt_task, pcs.updt_cnt = 0,
      pcs.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (pcs)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
      "Failed to insert new row(s) into PW_CAT_SYNONYM table")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET plan_r_cnt = value(size(request->planreltnlist,5))
 IF (plan_r_cnt > 0)
  INSERT  FROM pw_cat_reltn pcr,
    (dummyt d  WITH seq = value(plan_r_cnt))
   SET pcr.pw_cat_s_id = request->planreltnlist[d.seq].pw_cat_s_id, pcr.pw_cat_t_id = request->
    planreltnlist[d.seq].pw_cat_t_id, pcr.type_mean = request->planreltnlist[d.seq].type_mean,
    pcr.offset_qty = request->planreltnlist[d.seq].offset_qty, pcr.offset_unit_cd = request->
    planreltnlist[d.seq].offset_unit_cd, pcr.updt_dt_tm = cnvtdatetime(sysdate),
    pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo->updt_task, pcr.updt_cnt = 0,
    pcr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (pcr)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
    "Failed to insert new row(s) into PW_CAT_RELTN table")
   GO TO exit_script
  ENDIF
 ENDIF
 SET plan_evidence_r_cnt = value(size(request->pwevidencereltnlist,5))
 IF (plan_evidence_r_cnt > 0)
  DECLARE size = i4 WITH noconstant(0), protect
  DECLARE num = i4 WITH noconstant(0), protect
  DECLARE evidence_id = f8 WITH noconstant(0.0), protect
  RECORD evidence(
    1 list[*]
      2 pw_evidence_reltn_id = f8
      2 pathway_catalog_id = f8
      2 dcp_clin_cat_cd = f8
      2 dcp_clin_sub_cat_cd = f8
      2 pathway_comp_id = f8
      2 type_mean = c12
      2 ref_text_reltn_id = f8
      2 evidence_locator = vc
      2 evidence_sequence = i4
  )
  SET stat = alterlist(evidence->list,plan_evidence_r_cnt)
  FOR (indx = 1 TO plan_evidence_r_cnt)
   SET evidence_id = request->pwevidencereltnlist[indx].pw_evidence_reltn_id
   IF (0=locateval(num,1,(size+ 1),evidence_id,evidence->list[num].pw_evidence_reltn_id))
    SET size += 1
    SET evidence->list[size].pw_evidence_reltn_id = request->pwevidencereltnlist[indx].
    pw_evidence_reltn_id
    SET evidence->list[size].pathway_catalog_id = request->pwevidencereltnlist[indx].
    pathway_catalog_id
    SET evidence->list[size].dcp_clin_cat_cd = request->pwevidencereltnlist[indx].dcp_clin_cat_cd
    SET evidence->list[size].dcp_clin_sub_cat_cd = request->pwevidencereltnlist[indx].
    dcp_clin_sub_cat_cd
    SET evidence->list[size].pathway_comp_id = request->pwevidencereltnlist[indx].pathway_comp_id
    SET evidence->list[size].type_mean = request->pwevidencereltnlist[indx].type_mean
    SET evidence->list[size].ref_text_reltn_id = request->pwevidencereltnlist[indx].ref_text_reltn_id
    SET evidence->list[size].evidence_locator = request->pwevidencereltnlist[indx].evidence_locator
    SET evidence->list[size].evidence_sequence = request->pwevidencereltnlist[indx].evidence_sequence
   ENDIF
  ENDFOR
  SET stat = alterlist(evidence->list,size)
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = value(size))
   SET per.pw_evidence_reltn_id = evidence->list[d.seq].pw_evidence_reltn_id, per.pathway_catalog_id
     = evidence->list[d.seq].pathway_catalog_id, per.dcp_clin_cat_cd = evidence->list[d.seq].
    dcp_clin_cat_cd,
    per.dcp_clin_sub_cat_cd = evidence->list[d.seq].dcp_clin_sub_cat_cd, per.pathway_comp_id =
    evidence->list[d.seq].pathway_comp_id, per.type_mean = evidence->list[d.seq].type_mean,
    per.ref_text_reltn_id = evidence->list[d.seq].ref_text_reltn_id, per.evidence_locator = evidence
    ->list[d.seq].evidence_locator, per.evidence_sequence = evidence->list[d.seq].evidence_sequence,
    per.updt_dt_tm = cnvtdatetime(sysdate), per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo->
    updt_task,
    per.updt_cnt = 0, per.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (per)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
    "Failed to insert new row(s) into PW_EVIDENCE_RELTN table")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->testing_ind=1))
  SET facility_flexing_description = fillstring(100," ")
  SET facility_flexing_description = concat("pathway_catalog_id=",build(pathwayid))
  SET facility_flexing_description = trim(facility_flexing_description)
  IF (size(facility_flexing_description,8) > 100)
   SET facility_flexing_description = substring(1,100,facility_flexing_description)
  ENDIF
 ENDIF
 SET facility_cnt = value(size(request->facilityflexlist,5))
 IF (facility_cnt > 0)
  INSERT  FROM pw_cat_flex pcf,
    (dummyt d  WITH seq = value(facility_cnt))
   SET pcf.display_description_key = cnvtupper(trim(facility_flexing_description)), pcf
    .pathway_catalog_id = pathwayid, pcf.parent_entity_id = request->facilityflexlist[d.seq].
    facility_cd,
    pcf.parent_entity_name = "CODE_VALUE", pcf.updt_dt_tm = cnvtdatetime(sysdate), pcf.updt_id =
    reqinfo->updt_id,
    pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = 0
   PLAN (d)
    JOIN (pcf)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
    "Unable to insert facility flex row into PW_CAT_FLEX")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->all_facility_ind=1))
  INSERT  FROM pw_cat_flex pcf
   SET pcf.display_description_key = cnvtupper(trim(facility_flexing_description)), pcf
    .pathway_catalog_id = pathwayid, pcf.parent_entity_id = 0,
    pcf.parent_entity_name = "CODE_VALUE", pcf.updt_dt_tm = cnvtdatetime(sysdate), pcf.updt_id =
    reqinfo->updt_id,
    pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
    "Unable to insert facility flex row into PW_CAT_FLEX")
   GO TO exit_script
  ENDIF
 ENDIF
 SET problem_cnt = value(size(request->problemdiaglist,5))
 IF (problem_cnt > 0)
  FOR (i = 1 TO problem_cnt)
    SET concept_cki_entity_r_id = 0.0
    SELECT INTO "nl:"
     nextseqnum = seq(entity_reltn_seq,nextval)
     FROM dual
     DETAIL
      concept_cki_entity_r_id = nextseqnum
     WITH nocounter
    ;end select
    IF (concept_cki_entity_r_id=0.0)
     CALL report_failure("INSERT","F","CONCEPT_CKI_ENTITY_R",
      "Unable to generate new concept_cki_entity_r_id for concept cki")
     GO TO exit_script
    ENDIF
    INSERT  FROM concept_cki_entity_r ccer
     SET ccer.concept_cki_entity_r_id = concept_cki_entity_r_id, ccer.entity_name = "PATHWAY_CATALOG",
      ccer.entity_id = request->problemdiaglist[i].pathway_catalog_id,
      ccer.concept_cki = request->problemdiaglist[i].concept_cki, ccer.beg_effective_dt_tm =
      cnvtdatetime(sysdate), ccer.end_effective_dt_tm = cnvtdatetime(end_date_string),
      ccer.active_ind = 1, ccer.reltn_type_cd = reltn_type_cd, ccer.updt_dt_tm = cnvtdatetime(sysdate
       ),
      ccer.updt_id = reqinfo->updt_id, ccer.updt_task = reqinfo->updt_task, ccer.updt_applctx =
      reqinfo->updt_applctx,
      ccer.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
      "Unable to insert new row into CONCEPT_CKI_ENTITY_R")
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 SET comp_phase_r_cnt = value(size(request->compphasereltnlist,5))
 FOR (i = 1 TO comp_phase_r_cnt)
   IF ((request->compphasereltnlist[i].pathway_comp_id <= 0.0))
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
      build(i),"]->pathway_comp_id was not valid"))
    GO TO exit_script
   ENDIF
   IF ((request->compphasereltnlist[i].pathway_catalog_id <= 0.0))
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
      build(i),"]->pathway_catalog_id was not valid"))
    GO TO exit_script
   ENDIF
   IF (size(trim(request->compphasereltnlist[i].type_mean),1) <= 0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
      build(i),"]->type_mean was not valid"))
    GO TO exit_script
   ENDIF
   INSERT  FROM pw_comp_cat_reltn pccr
    SET pccr.pw_comp_cat_reltn_id = seq(reference_seq,nextval), pccr.pathway_comp_id = request->
     compphasereltnlist[i].pathway_comp_id, pccr.pathway_catalog_id = request->compphasereltnlist[i].
     pathway_catalog_id,
     pccr.type_mean = request->compphasereltnlist[i].type_mean, pccr.updt_applctx = reqinfo->
     updt_applctx, pccr.updt_cnt = 0,
     pccr.updt_dt_tm = cnvtdatetime(sysdate), pccr.updt_id = reqinfo->updt_id, pccr.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
     "Failed to insert new row into PW_COMP_CAT_RELTN table")
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
