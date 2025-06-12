CREATE PROGRAM cnt_imp_dta
 CALL parser("dm2_set_context 'FIRE_REFCHG_TRG','NO' go")
 CALL parser("rdb alter table CNT_DATA_MAP       disable constraint XFK1CNT_DATA_MAP       go")
 CALL parser("rdb alter table CNT_DTA            disable constraint XFK1CNT_DTA            go")
 CALL parser("rdb alter table CNT_DTA_RRF_R      disable constraint XFK1CNT_DTA_RRF_R      go")
 CALL parser("rdb alter table CNT_DTA_RRF_R      disable constraint XFK2CNT_DTA_RRF_R      go")
 CALL parser("rdb alter table CNT_INPUT          disable constraint XFK1CNT_INPUT          go")
 CALL parser("rdb alter table CNT_INPUT          disable constraint XFK2CNT_INPUT          go")
 CALL parser("rdb alter table CNT_INPUT_KEY      disable constraint XFK1CNT_INPUT_KEY      go")
 CALL parser("rdb alter table CNT_PF_SECTION_R   disable constraint XFK1CNT_PF_SECTION_R   go")
 CALL parser("rdb alter table CNT_PF_SECTION_R   disable constraint XFK2CNT_PF_SECTION_R   go")
 CALL parser("rdb alter table CNT_POWERFORM      disable constraint XFK1CNT_POWERFORM      go")
 CALL parser("rdb alter table CNT_REF_TEXT       disable constraint XFK1CNT_REF_TEXT       go")
 CALL parser("rdb alter table CNT_RRF            disable constraint XFK1CNT_RRF            go")
 CALL parser("rdb alter table CNT_RRF_AR_R       disable constraint XFK1CNT_RRF_AR_R       go")
 CALL parser("rdb alter table CNT_RRF_AR_R       disable constraint XFK2CNT_RRF_AR_R       go")
 CALL parser("rdb alter table CNT_SECTION        disable constraint XFK1CNT_SECTION        go")
 CALL parser("rdb alter table CNT_DTA_RRF_R      disable constraint XFK2CNT_DTA_RRF_R go")
 COMMIT
 DECLARE offset_req_ind = i2 WITH constant(validate(request->dta_obj_list[1].dta_obj.offset_mins_list
   ))
 DECLARE category_req_ind = i2 WITH constant(validate(request->dta_obj_list[1].dta_obj.
   reference_range_factor_list[1].reference_range_factor.alpha_category_list))
 DECLARE advanced_req_ind = i2 WITH constant(validate(request->dta_obj_list[1].dta_obj.
   reference_range_factor_list[1].reference_range_factor.advanced_delta_list))
 SET curalias dta_struct request->dta_obj_list[dta_a].dta_obj
 SET curalias rrf_struct request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[dta_rrf].
 reference_range_factor
 SET curalias ar_struct request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[dta_rrf].
 reference_range_factor.alpha_response_list[dta_ar].alpha_response
 SET curalias data_map_struct request->dta_obj_list[dta_a].dta_obj.data_map_list[dta_dm].data_map
 IF (offset_req_ind=1)
  SET curalias offset_mins_struct request->dta_obj_list[dta_a].dta_obj.offset_mins_list[dta_dom].
  offset_mins
 ENDIF
 IF (category_req_ind=1)
  SET curalias category_struct request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[
  dta_rrf].reference_range_factor.alpha_category_list[dta_arc].alpha_category
 ENDIF
 IF (advanced_req_ind=1)
  SET curalias advanced_struct request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[
  dta_rrf].reference_range_factor.advanced_delta_list[dta_ad].advanced_delta
 ENDIF
 SET curalias dta_proc_struct request->dta_obj_list[dta_a].dta_obj.related_proc_type_list[dta_proc].
 related_proc_type
 EXECUTE cnt_upd_cvuid_alias
 DECLARE ta_uid = vc WITH noconstant("")
 DECLARE r_uid = vc WITH noconstant("")
 DECLARE arr_uid = vc WITH noconstant("")
 DECLARE tmp_event_cduid = vc WITH noconstant("")
 DECLARE dta_a = i4 WITH noconstant(0)
 DECLARE dta_rrf = i4 WITH noconstant(0)
 DECLARE dta_ar = i4 WITH noconstant(0)
 DECLARE dta_dm = i4 WITH noconstant(0)
 DECLARE dta_dom = i4 WITH noconstant(0)
 DECLARE dta_proc = i4 WITH noconstant(0)
 DECLARE dta_arc = i4 WITH noconstant(0)
 DECLARE dta_ad = i4 WITH noconstant(0)
 DECLARE cnt_disp = vc WITH noconstant("")
 DECLARE cnt_disp_key = vc WITH noconstant("")
 DECLARE cnt_mean = vc WITH noconstant("")
 DECLARE cnt_cd = f8 WITH noconstant(0.0)
 DECLARE cnt_cduid = vc WITH noconstant("")
 DECLARE new_dta = i2 WITH noconstant(0)
 DECLARE new_rrf = i2 WITH noconstant(0)
 DECLARE new_ar = i2 WITH noconstant(0)
 DECLARE dta_replace = i2 WITH noconstant(0)
 DECLARE compare_dt_tm = dq8
 DECLARE log_txt = vc
 DECLARE min_year = i4 WITH public, constant(525600)
 DECLARE min_month = i4 WITH public, constant(44640)
 DECLARE min_week = i4 WITH public, constant(10080)
 DECLARE min_day = i4 WITH public, constant(1440)
 DECLARE min_hour = i4 WITH public, constant(60)
 DECLARE min_minute = i4 WITH public, constant(1)
 DECLARE min_sec = i4 WITH public, constant(0)
 DECLARE cduid_years = vc WITH public, constant("CERNER!ED64C838-1DD1-11B2-A082-9CDB2AF8B48F")
 DECLARE cduid_months = vc WITH public, constant("CERNER!246068B0-1DD2-11B2-A082-8738C42C7339")
 DECLARE cduid_weeks = vc WITH public, constant("CERNER!26187952-1DD2-11B2-A089-C0A7C9BB8879")
 DECLARE cduid_days = vc WITH public, constant("CERNER!241BC91C-1DD2-11B2-A082-C0A0CD409405")
 DECLARE cduid_hours = vc WITH public, constant("CERNER!92E4D046-1DD2-11B2-B07B-C4218ED4890E")
 DECLARE cduid_minutes = vc WITH public, constant("CERNER!FA4F1CB0-1DD1-11B2-A082-DD09831C2B6A")
 DECLARE age_from_min = i4 WITH noconstant(0)
 DECLARE age_to_min = i4 WITH noconstant(0)
 DECLARE tmp_dta_key_id = f8 WITH noconstant(0.0)
 DECLARE tmp_dta_id = f8 WITH noconstant(0.0)
 DECLARE tmp_rrf_id = f8 WITH noconstant(0.0)
 DECLARE tmp_rrf_key_id = f8 WITH noconstant(0.0)
 DECLARE tmp_alpha_respkey_id = f8 WITH noconstant(0.0)
 DECLARE rad_column_ind = i2 WITH noconstant(0)
 DECLARE dtaoffset_table_ind = i2 WITH noconstant(0)
 DECLARE category_table_ind = i2 WITH noconstant(0)
 DECLARE advanced_table_ind = i2 WITH noconstant(0)
 DECLARE witness_req_ind = i2 WITH constant(validate(request->dta_obj_list[1].dta_obj.
   witness_required_ind))
 DECLARE tmp_category_id = f8 WITH noconstant(0.0)
 DECLARE relassay_table_ind = i2 WITH noconstant(0)
 DECLARE truth_column_ind = i2 WITH noconstant(0)
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 FREE SET temp_guid_rec
 RECORD temp_guid_rec(
   1 pf_list[*]
     2 form_description = vc
     2 form_definition = vc
     2 dcp_forms_ref_id = f8
     2 version_dt_tm = dq8
     2 form_event_cd = f8
     2 text_rend_evt_cd = f8
     2 sect_list[*]
       3 sect_description = vc
       3 sect_definition = vc
       3 dcp_section_ref_id = f8
       3 version_dt_tm = dq8
       3 cv_list[*]
         4 input_cnt = i4
         4 mod_cnt = i4
         4 cv_type = vc
         4 code_value = f8
         4 grid_item_cnt = i4
         4 cv_dta_disp = vc
         4 version_dt_tm = dq8
     2 cond_sect_list[*]
       3 dcp_section_ref_id = f8
       3 sect_definition = vc
       3 sect_description = vc
       3 version_dt_tm = f8
       3 section_cnt = i4
       3 input_cnt = i4
       3 mod_cnt = i4
 )
 FREE SET dta_guid_rec
 RECORD dta_guid_rec(
   1 dta_obj_list[*]
     2 dta_display = vc
     2 task_assay_cd = f8
     2 version_dt_tm = dq8
     2 activity_type_cd = f8
     2 default_result_type_cd = f8
     2 bb_result_type_cd = f8
     2 rad_sect_type_cd = f8
     2 event_cd = f8
     2 text_type_cd = f8
     2 cv_list[*]
       3 code_value = f8
       3 version_dt_tm = dq8
       3 cv_type = vc
       3 data_map_cnt = i4
       3 rrf_factor_cnt = i4
       3 ar_cnt = i4
       3 ad_cnt = i4
       3 rel_proc_type_cnt = i4
       3 dta_offset_cnt = i4
 )
 FREE SET nomen_guid_rec
 RECORD nomen_guid_rec(
   1 term_obj_list[*]
     2 principle_type_cd = f8
     2 contributor_system_cd = f8
     2 source_vocabulary_cd = f8
     2 string_status_cd = f8
     2 string_source_cd = f8
     2 language_cd = f8
     2 term_source_cd = f8
     2 data_status_cd = f8
     2 vocab_axis_cd = f8
     2 concept_source_cd = f8
 )
 FREE SET eq_guid_rec
 RECORD eq_guid_rec(
   1 eq_obj_list[*]
     2 act_type_cd = f8
     2 serv_cd = f8
     2 species_cd = f8
     2 age_from_units_cd = f8
     2 age_to_units_cd = f8
     2 sex_code_cd = f8
     2 comp_act_type_cd = f8
     2 result_status_cd = f8
     2 units_cd = f8
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 task_assay_ver_dt_tm = dq8
     2 included_assay_cd = f8
     2 included_assay_disp = vc
     2 included_assay_ver_dt_tm = dq8
 )
 FREE SET interp_guid_rec
 RECORD interp_guid_rec(
   1 interp_obj_list[*]
     2 act_type_cd = f8
     2 sex_code_cd = f8
     2 service_resource_cd = f8
     2 component_list[*]
       3 act_type_cd = f8
       3 dta_disp = vc
       3 version_dt_tm = dq8
       3 component_dta_cd = f8
     2 state_list[*]
       3 act_type_cd = f8
       3 source_vocab_cd = f8
       3 principle_type_cd = f8
       3 result_source_vocab_cd = f8
       3 result_prin_type_cd = f8
       3 dta_disp = vc
       3 version_dt_tm = dq8
       3 input_dta_cd = f8
     2 dta_disp = vc
     2 version_dt_tm = dq8
     2 dta_cd = f8
 )
 FREE SET cv_guid_rec
 RECORD cv_guid_rec(
   1 cv_list[*]
     2 code_value = f8
     2 cv_guid = vc
 )
 DECLARE cnt_get_new_uuid(null) = vc
 DECLARE is_internal_domain(null) = i2
 SUBROUTINE (cnt_pf_chk_by_id(form_ref_id=f8) =vc)
   DECLARE form_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_pf_key2 c
    PLAN (c
     WHERE c.dcp_forms_ref_id=form_ref_id)
    DETAIL
     form_uid = c.form_uid
    WITH nocounter
   ;end select
   RETURN(form_uid)
 END ;Subroutine
 SUBROUTINE (cnt_sect_chk_by_id(sect_ref_id=f8) =vc)
   DECLARE section_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_section_key2 c
    PLAN (c
     WHERE c.dcp_section_ref_id=sect_ref_id)
    DETAIL
     section_uid = c.section_uid
    WITH nocounter
   ;end select
   RETURN(section_uid)
 END ;Subroutine
 SUBROUTINE (cnt_dta_chk_by_cd(task_assay_cd=f8) =vc)
   DECLARE dta_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_dta_key2 c
    PLAN (c
     WHERE c.task_assay_cd=task_assay_cd)
    DETAIL
     dta_uid = c.task_assay_uid
    WITH nocounter
   ;end select
   RETURN(dta_uid)
 END ;Subroutine
 SUBROUTINE (cnt_cv_chk_by_cd(code_value=f8) =vc)
   DECLARE cv_uid = vc WITH noconstant(" ")
   IF (code_value > 0)
    SELECT INTO "nl:"
     FROM cnt_code_value_key c
     PLAN (c
      WHERE c.code_value=code_value)
     DETAIL
      cv_uid = c.code_value_uid
     WITH nocounter
    ;end select
   ENDIF
   RETURN(cv_uid)
 END ;Subroutine
 SUBROUTINE (cnt_pf_ins(pf_desc=vc,pf_def=vc,pf_ref_id=f8,pf_dt_tm=f8) =vc)
   DECLARE uuid1 = c36
   DECLARE pf_uid = vc WITH noconstant(" ")
   DECLARE pfk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET pf_uid = concat(prefix,build(uuid1))
   SET pfk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_pf_key2 c
    SET c.cnt_pf_key_id = pfk_id, c.form_uid = pf_uid, c.form_definition = pf_def,
     c.form_description = pf_desc, c.dcp_forms_ref_id = pf_ref_id, c.version_dt_tm = cnvtdatetime(
      pf_dt_tm),
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(pf_uid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_section_ins(sect_desc=vc,sect_def=vc,sect_ref_id=f8,sect_dt_tm=f8) =vc)
   DECLARE uuid1 = c36
   DECLARE sect_uid = vc WITH noconstant(" ")
   DECLARE csk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET sect_uid = concat(prefix,build(uuid1))
   SET csk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_section_key2 c
    SET c.cnt_section_key2_id = csk_id, c.section_uid = sect_uid, c.section_definition = sect_def,
     c.section_description = sect_desc, c.dcp_section_ref_id = sect_ref_id, c.version_dt_tm =
     cnvtdatetime(sect_dt_tm),
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(sect_uid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_dta_ins(dta_disp=vc,assay_cd=f8,dta_dt_tm=f8) =vc)
   DECLARE uuid1 = c36
   DECLARE dta_uid = vc WITH noconstant(" ")
   DECLARE cdk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET dta_uid = concat(prefix,build(uuid1))
   SET cdk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_dta_key2 c
    SET c.cnt_dta_key_id = cdk_id, c.task_assay_uid = dta_uid, c.task_assay_disp = dta_disp,
     c.task_assay_cd = assay_cd, c.version_dt_tm = cnvtdatetime(dta_dt_tm), c.updt_id = reqinfo->
     updt_id,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo
     ->updt_applctx,
     c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(dta_uid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_cv_ins(code_set=f8,code_value=f8,cv_disp=vc,cv_desc=vc,cv_cki=vc,cv_concept_cki=vc,
  cv_cdf_meaning=vc) =vc)
   DECLARE uuid1 = c36
   DECLARE cv_uid = vc WITH noconstant(" ")
   DECLARE ccvk_id = f8
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET cv_uid = concat(prefix,build(uuid1))
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   IF (code_value > 0)
    INSERT  FROM cnt_code_value_key c
     SET c.cnt_code_value_key_id = ccvk_id, c.code_value_uid = cv_uid, c.code_set = code_set,
      c.code_value = code_value, c.display = cv_disp, c.description = cv_desc,
      c.cki = cv_cki, c.concept_cki = cv_concept_cki, c.cdf_meaning = cv_cdf_meaning,
      c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
      updt_task,
      c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     RETURN(" ")
    ELSE
     RETURN(cv_uid)
    ENDIF
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_dta_chk_uid(tmp_uid=vc) =vc)
   DECLARE ret_uid = vc WITH noconstant("")
   SET ret_uid = tmp_uid
   SELECT INTO "nl:"
    FROM cnt_uid_alias c
    PLAN (c
     WHERE c.cnt_uid_alias=tmp_uid
      AND c.cnt_uid_domain="CNT_DTA_KEY2")
    DETAIL
     ret_uid = c.cnt_uid
    WITH check
   ;end select
   RETURN(ret_uid)
 END ;Subroutine
 SUBROUTINE (cnt_rrf_chk_uid(tmp_id=f8) =vc)
   DECLARE rrf_guid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_rrf_key c
    PLAN (c
     WHERE c.dcp_ref_range_factor_id=tmp_id)
    DETAIL
     rrf_guid = c.rrf_uid
    WITH nocounter
   ;end select
   RETURN(rrf_guid)
 END ;Subroutine
 SUBROUTINE (cnt_rrf_ins(rrf_id=f8) =vc)
   DECLARE uuid1 = c36
   DECLARE rrf_guid = vc WITH noconstant(" ")
   DECLARE cdk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET rrf_guid = concat(prefix,build(uuid1))
   SET cdk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_rrf_key c
    SET c.cnt_rrf_key_id = cdk_id, c.rrf_uid = rrf_guid, c.dcp_ref_range_factor_id = rrf_id,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(rrf_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_alpha_resp_chk_uid(tmp_id=f8) =vc)
   DECLARE ar_guid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_alpha_response_key c
    PLAN (c
     WHERE c.nomenclature_id=tmp_id)
    DETAIL
     ar_guid = c.ar_uid
    WITH nocounter
   ;end select
   RETURN(ar_guid)
 END ;Subroutine
 SUBROUTINE (cnt_alpha_resp_ins(nomen_id=f8) =vc)
   DECLARE uuid1 = c36
   DECLARE ar_guid = vc WITH noconstant(" ")
   DECLARE cdk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET ar_guid = concat(prefix,build(uuid1))
   SET cdk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_alpha_response_key c
    SET c.cnt_alpha_response_key_id = cdk_id, c.nomenclature_id = nomen_id, c.ar_uid = ar_guid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(ar_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_equation_chk_uid(task_assay_uid=vc,serv_cduid=vc,sex_cduid=vc,species_cduid=vc,
  age_from_minutes=i4,age_to_minutes=i4) =vc)
   DECLARE equation_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_equation c
    PLAN (c
     WHERE c.task_assay_uid=task_assay_uid
      AND c.service_resource_cduid=serv_cduid
      AND c.sex_cduid=sex_cduid
      AND c.species_cduid=species_cduid
      AND c.age_from_minutes=age_from_minutes
      AND c.age_to_minutes=age_to_minutes)
    DETAIL
     equation_uid = c.equation_uid
    WITH nocounter
   ;end select
   RETURN(equation_uid)
 END ;Subroutine
 SUBROUTINE (cnt_equation_ins(equation_id=f8,task_assay_uid=vc,serv_cduid=vc,sex_cduid=vc,
  species_cduid=vc,age_from_minutes=i4,age_to_minutes=i4) =vc)
   DECLARE uuid1 = c36
   DECLARE equation_uid = vc WITH noconstant(" ")
   DECLARE cdk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET equation_uid = concat(prefix,build(uuid1))
   SET cdk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_equation c
    SET c.cnt_equation_id = cdk_id, c.equation_id = equation_id, c.equation_uid = equation_uid,
     c.task_assay_uid = task_assay_uid, c.service_resource_cduid = serv_cduid, c.sex_cduid =
     sex_cduid,
     c.species_cduid = species_cduid, c.age_from_minutes = age_from_minutes, c.age_to_minutes =
     age_to_minutes,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(equation_uid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_interp_chk_uid(tmp_id=f8) =vc)
   DECLARE dcp_interp_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_dcp_interp2 c
    PLAN (c
     WHERE c.dcp_interp_id=tmp_id)
    DETAIL
     dcp_interp_uid = c.dcp_interp_uid
    WITH nocounter
   ;end select
   RETURN(dcp_interp_uid)
 END ;Subroutine
 SUBROUTINE (cnt_interp_ins(interp_id=f8) =vc)
   DECLARE uuid1 = c36
   DECLARE dcp_interp_uid = vc WITH noconstant(" ")
   DECLARE cdk_id = f8 WITH noconstant(0.0)
   EXECUTE ccluarxrtl
   SET uuid1 = uar_createuuid(0)
   SET dcp_interp_uid = concat(prefix,build(uuid1))
   SET cdk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_dcp_interp2 c
    SET c.cnt_dcp_interp2_id = cdk_id, c.dcp_interp_id = interp_id, c.dcp_interp_uid = dcp_interp_uid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(dcp_interp_uid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_next_seq(seq_name=vc) =f8)
   SET next_seq = 0.0
   SET seq_string = concat("seq(",seq_name,", nextval)")
   SELECT INTO "nl:"
    number = parser(seq_string)"##################;rp0"
    FROM dual
    DETAIL
     next_seq = cnvtreal(number)
    WITH format, counter
   ;end select
   RETURN(next_seq)
 END ;Subroutine
 SUBROUTINE (cnt_wv_workingview_item_chk_by_cd(code_value=f8) =vc)
   DECLARE working_view_item_guid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_wv_item_key c
    PLAN (c
     WHERE c.cnt_wv_item_key_id=code_value)
    DETAIL
     working_view_item_guid = c.wv_item_uid
    WITH nocounter
   ;end select
   RETURN(working_view_item_guid)
 END ;Subroutine
 SUBROUTINE (cnt_wv_section_chk_by_cd(code_value=f8) =vc)
   DECLARE working_view_section_guid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_wv_section_key c
    PLAN (c
     WHERE c.cnt_wv_section_key_id=code_value)
    DETAIL
     working_view_section_guid = c.wv_section_uid
    WITH nocounter
   ;end select
   RETURN(working_view_section_guid)
 END ;Subroutine
 SUBROUTINE (cnt_wv_working_view_chk_by_cd(code_value=f8) =vc)
   DECLARE working_view_guid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_wv_key c
    PLAN (c
     WHERE c.cnt_wv_key_id=code_value)
    DETAIL
     working_view_guid = c.working_view_uid
    WITH nocounter
   ;end select
   RETURN(working_view_guid)
 END ;Subroutine
 SUBROUTINE (cnt_wv_section_insert(working_view_section_id=f8,working_view_section_uid=vc,
  wv_sec_version_dt_tm=dq8,event_set_name=vc,required_ind=i2,included_ind=i2,falloff_view_minutes=i2,
  section_type_flag=i2,display_name=vc,default_open_pref=i2) =vc)
   DECLARE temp_section_guid = c36
   DECLARE section_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_section_guid = uar_createuuid(0)
   IF (working_view_section_uid IN ("", " ", null))
    SET section_guid = concat(prefix,build(temp_section_guid))
   ELSE
    SET section_guid = working_view_section_uid
   ENDIF
   IF (working_view_section_id=0.0)
    SET working_view_section_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (wv_sec_version_dt_tm IN (0, null))
    SET wv_sec_version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_wv_section_key c
    SET c.cnt_wv_section_key_id = working_view_section_id, c.wv_section_uid = section_guid, c
     .version_dt_tm = cnvtdatetime(wv_sec_version_dt_tm),
     c.event_set_name = event_set_name, c.required_ind = required_ind, c.included_ind = included_ind,
     c.section_type_flag = section_type_flag, c.display_name = display_name, c.default_open_pref_flag
      = default_open_pref,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(section_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_wv_working_view_insert(working_view_id=f8,working_view_uid=vc,location_cd=f8,
  location_disp=vc,location_cduid=vc,version_dt_tm=dq8,current_working_view=f8,display_name=vc,
  view_state=i2,position_cd=f8,position_disp=vc,position_cduid=vc,version_num=i2,active_ind=i2,
  disp_name_pref=vc,wv_ref_id=f8) =vc)
   DECLARE temp_working_view_guid = vc WITH noconstant(" ")
   DECLARE working_view_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_working_view_guid = uar_createuuid(0)
   IF (working_view_uid IN ("", " ", null))
    SET working_view_guid = concat(prefix,build(temp_working_view_guid))
   ELSE
    SET working_view_guid = working_view_uid
   ENDIF
   IF (working_view_id=0.0)
    SET working_view_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_wv_key c
    SET c.cnt_wv_key_id = working_view_id, c.dcp_wv_ref_id = wv_ref_id, c.working_view_uid =
     working_view_guid,
     c.location_cd = location_cd, c.location_display_txt = location_disp, c.location_cduid =
     location_cduid,
     c.version_dt_tm = cnvtdatetime(version_dt_tm), c.current_working_view = current_working_view, c
     .display_name = display_name,
     c.view_state_flag = view_state, c.position_cd = position_cd, c.position_display_txt =
     position_disp,
     c.position_cduid = position_cduid, c.version_num = version_num, c.active_ind = 1,
     c.display_name_pref = disp_name_pref, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(
      sysdate),
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(working_view_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_wv_item_insert(wv_item_id=f8,wv_item_uid=vc,item_version_dt_tm=dq8,event_set_name=vc,
  parent_event_set_name=vc,item_included_ind=i2,item_falloff_view_numbers=i2,task_assay_guid=vc,
  disp_assoc_ind=i2) =vc)
   DECLARE temp_item_guid = c36
   DECLARE item_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_item_guid = uar_createuuid(0)
   IF (wv_item_uid IN ("", " ", null))
    SET item_guid = concat(prefix,build(temp_item_guid))
   ELSE
    SET item_guid = wv_item_uid
   ENDIF
   IF (wv_item_id=0.0)
    SET wv_item_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (item_version_dt_tm IN (0, null))
    SET item_version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_wv_item_key c
    SET c.cnt_wv_item_key_id = wv_item_id, c.wv_item_uid = item_guid, c.version_dt_tm = cnvtdatetime(
      item_version_dt_tm),
     c.primitive_event_set_name = event_set_name, c.parent_event_set_name = parent_event_set_name, c
     .included_ind = item_included_ind,
     c.falloff_view_minutes = item_falloff_view_numbers, c.task_assay_guid = task_assay_guid, c
     .disp_assoc_ind = disp_assoc_ind,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(item_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE cnt_get_new_uuid(null)
   DECLARE cnt_new_uuid = vc WITH noconstant(" ")
   DECLARE temp_new_uuid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_new_uuid = uar_createuuid(0)
   SET cnt_new_uuid = concat(prefix,build(temp_new_uuid))
   RETURN(cnt_new_uuid)
 END ;Subroutine
 SUBROUTINE (add_wv_section_relation(working_view_guid=vc,working_view_section_guid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_wv_section_r c
    SET c.cnt_wv_section_r_id = ccvk_id, c.working_view_uid = working_view_guid, c.wv_section_uid =
     working_view_section_guid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (add_wv_section_item_relation(working_view_section_guid=vc,wv_item_guid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_wv_section_item_r c
    SET c.cnt_wv_section_item_r_id = ccvk_id, c.wv_section_uid = working_view_section_guid, c
     .wv_item_uid = wv_item_guid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (cnt_wv_working_view_update(working_view_id=f8,working_view_uid=vc,location_cd=f8,
  location_disp=vc,location_cduid=vc,version_dt_tm=dq8,current_working_view=f8,display_name=vc,
  view_state=i2,position_cd=f8,position_disp=vc,position_cduid=vc,version_num=i2,active_ind=i2,
  disp_name_pref=vc,wv_ref_id=f8) =vc)
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   UPDATE  FROM cnt_wv_key c
    SET c.dcp_wv_ref_id = wv_ref_id, c.location_cd = location_cd, c.location_display_txt =
     location_disp,
     c.location_cduid = location_cduid, c.version_dt_tm = cnvtdatetime(version_dt_tm), c
     .current_working_view = current_working_view,
     c.display_name = display_name, c.view_state_flag = view_state, c.position_cd = position_cd,
     c.position_display_txt = position_disp, c.position_cduid = position_cduid, c.version_num =
     version_num,
     c.active_ind = 1, c.display_name_pref = disp_name_pref, c.updt_id = reqinfo->updt_id,
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx
    WHERE c.working_view_uid=working_view_uid
    WITH nocounter
   ;end update
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE (cnt_wv_section_update(working_view_section_id=f8,working_view_section_uid=vc,
  wv_sec_version_dt_tm=dq8,event_set_name=vc,required_ind=i2,included_ind=i2,falloff_view_minutes=i2,
  section_type_flag=i2,display_name=vc,default_open_pref=i2) =vc)
   IF (wv_sec_version_dt_tm IN (0, null))
    SET wv_sec_version_dt_tm = sysdate
   ENDIF
   UPDATE  FROM cnt_wv_section_key c
    SET c.version_dt_tm = cnvtdatetime(wv_sec_version_dt_tm), c.event_set_name = event_set_name, c
     .required_ind = required_ind,
     c.included_ind = included_ind, c.section_type_flag = section_type_flag, c.display_name =
     display_name,
     c.default_open_pref_flag = default_open_pref, c.updt_id = reqinfo->updt_id, c.updt_dt_tm =
     cnvtdatetime(sysdate),
     c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
     updt_applctx
    WHERE c.wv_section_uid=working_view_section_uid
    WITH nocounter
   ;end update
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE (cnt_wv_item_update(wv_item_id=f8,wv_item_uid=vc,item_version_dt_tm=dq8,event_set_name=vc,
  parent_event_set_name=vc,item_included_ind=i2,item_falloff_view_numbers=i2,task_assay_guid=vc,
  disp_assoc_ind=i2) =vc)
   IF (item_version_dt_tm IN (0, null))
    SET item_version_dt_tm = sysdate
   ENDIF
   UPDATE  FROM cnt_wv_item_key c
    SET c.version_dt_tm = cnvtdatetime(item_version_dt_tm), c.primitive_event_set_name =
     event_set_name, c.parent_event_set_name = parent_event_set_name,
     c.included_ind = item_included_ind, c.falloff_view_minutes = item_falloff_view_numbers, c
     .task_assay_guid = task_assay_guid,
     c.disp_assoc_ind = disp_assoc_ind, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(
      sysdate),
     c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
     updt_applctx
    WHERE c.wv_item_uid=wv_item_uid
    WITH nocounter
   ;end update
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_chk_by_cd(code_value=f8) =vc)
   DECLARE doc_set_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_key c
    PLAN (c
     WHERE c.cnt_ds_key_id=code_value)
    DETAIL
     doc_set_uid = c.cnt_ds_key_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_insert(doc_set_ref_id=f8,doc_set_ref_uid=vc,doc_set_name=vc,doc_set_name_key
  =vc,doc_set_description=vc,event_set_name=vc,event_cd=f8,event_cd_cki=vc,event_cd_concept_cki=vc,
  event_cd_disp=vc,event_cd_uid=vc,active_ind=i2,allow_comment_ind=i2,status=i2,version_dt_tm=dq8) =
  vc)
   DECLARE temp_ds_guid = c36
   DECLARE ds_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_ds_guid = uar_createuuid(0)
   IF (doc_set_ref_id=0.0)
    SET doc_set_ref_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (doc_set_ref_uid IN ("", " ", null))
    SET ds_guid = concat(prefix,build(temp_ds_guid))
   ELSE
    SET ds_guid = doc_set_ref_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_ds_key c
    SET c.cnt_ds_key_id = doc_set_ref_id, c.cnt_ds_key_uid = ds_guid, c.doc_set_name = doc_set_name,
     c.doc_set_name_key = doc_set_name_key, c.doc_set_description = doc_set_description, c
     .event_set_name = event_set_name,
     c.event_cd = event_cd, c.event_cd_cki = event_cd_cki, c.event_cd_concept_cki =
     event_cd_concept_cki,
     c.event_cd_uid = event_cd_uid, c.event_cd_display_name = event_cd_disp, c.active_ind =
     active_ind,
     c.allow_comment_ind = allow_comment_ind, c.version_dt_tm = cnvtdatetime(version_dt_tm), c
     .updt_id = reqinfo->updt_id,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo
     ->updt_applctx,
     c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(ds_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_update(doc_set_ref_id=f8,doc_set_ref_uid=vc,doc_set_name=vc,doc_set_name_key
  =vc,doc_set_description=vc,event_set_name=vc,event_cd=f8,event_cd_cki=vc,event_cd_concept_cki=vc,
  event_cd_disp=vc,event_cd_uid=vc,active_ind=i2,allow_comment_ind=i2,status=i2,version_dt_tm=dq8) =
  vc)
  IF (version_dt_tm IN (0, null))
   SET version_dt_tm = sysdate
  ENDIF
  UPDATE  FROM cnt_ds_key c
   SET c.cnt_ds_key_id = doc_set_ref_id, c.doc_set_name = doc_set_name, c.doc_set_name_key =
    doc_set_name_key,
    c.doc_set_description = doc_set_description, c.event_set_name = event_set_name, c.event_cd =
    event_cd,
    c.event_cd_cki = event_cd_cki, c.event_cd_concept_cki = event_cd_concept_cki, c.event_cd_uid =
    event_cd_uid,
    c.event_cd_display_name = event_cd_disp, c.active_ind = active_ind, c.allow_comment_ind =
    allow_comment_ind,
    c.version_dt_tm = cnvtdatetime(version_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_dt_tm =
    cnvtdatetime(sysdate),
    c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
    updt_applctx
   WHERE c.cnt_ds_key_uid=doc_set_ref_uid
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_section_chk_by_cd(code_value=f8) =vc)
   DECLARE doc_set_section_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_section_key c
    PLAN (c
     WHERE c.cnt_ds_section_key_id=code_value)
    DETAIL
     doc_set_section_uid = c.cnt_ds_section_key_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_section_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_section_event_cd_chk_by_cd(code_value=f8) =vc)
   DECLARE section_event_cd_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_section_key c
    PLAN (c
     WHERE c.event_cd=code_value)
    DETAIL
     section_event_cd_uid = c.event_cd_uid
    WITH nocounter
   ;end select
   RETURN(section_event_cd_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_section_update(cnt_ds_section_id=f8,cnt_ds_section_uid=vc,
  doc_set_section_name=vc,doc_set_section_name_key=vc,doc_set_section_description=vc,
  doc_set_section_instruction=vc,event_set_name=vc,event_cd=vc,event_cd_cki=vc,event_cd_concept_cki=
  vc,event_cd_disp=vc,event_cd_uid=vc,active_ind=i2,allow_comment_ind=i2,version_dt_tm=dq8) =vc)
  IF (version_dt_tm IN (0, null))
   SET version_dt_tm = sysdate
  ENDIF
  UPDATE  FROM cnt_ds_section_key c
   SET c.doc_set_section_name = doc_set_section_name, c.doc_set_section_name_key =
    doc_set_section_name_key, c.doc_set_section_description = doc_set_section_description,
    c.doc_set_section_instruction = doc_set_section_instruction, c.event_set_name = event_set_name, c
    .event_cd = event_cd,
    c.event_cd_cki = event_cd_cki, c.event_cd_concept_cki = event_cd_concept_cki, c.event_cd_uid =
    event_cd_uid,
    c.event_cd_display_name = event_cd_disp, c.active_ind = active_ind, c.allow_comment_ind =
    allow_comment_ind,
    c.version_dt_tm = cnvtdatetime(version_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_dt_tm =
    cnvtdatetime(sysdate),
    c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
    updt_applctx
   WHERE c.cnt_ds_section_key_uid=cnt_ds_section_uid
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_section_insert(cnt_ds_section_id=f8,cnt_ds_section_uid=vc,
  doc_set_section_name=vc,doc_set_section_name_key=vc,doc_set_section_description=vc,
  doc_set_section_instruction=vc,event_set_name=vc,event_cd=vc,event_cd_cki=vc,event_cd_concept_cki=
  vc,event_cd_disp=vc,event_cd_uid=vc,active_ind=i2,allow_comment_ind=i2,version_dt_tm=dq8) =vc)
   DECLARE temp_ds_sec_guid = c36
   DECLARE ds_sec_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_ds_sec_guid = uar_createuuid(0)
   IF (cnt_ds_section_id=0.0)
    SET cnt_ds_section_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (cnt_ds_section_uid IN ("", " ", null))
    SET ds_sec_guid = concat(prefix,build(temp_ds_sec_guid))
   ELSE
    SET ds_sec_guid = cnt_ds_section_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_ds_section_key c
    SET c.cnt_ds_section_key_id = cnt_ds_section_id, c.cnt_ds_section_key_uid = ds_sec_guid, c
     .doc_set_section_name = doc_set_section_name,
     c.doc_set_section_name_key = doc_set_section_name_key, c.doc_set_section_description =
     doc_set_section_description, c.doc_set_section_instruction = doc_set_section_instruction,
     c.event_set_name = event_set_name, c.event_cd = event_cd, c.event_cd_cki = event_cd_cki,
     c.event_cd_concept_cki = event_cd_concept_cki, c.event_cd_uid = event_cd_uid, c
     .event_cd_display_name = event_cd_disp,
     c.active_ind = active_ind, c.allow_comment_ind = allow_comment_ind, c.version_dt_tm =
     cnvtdatetime(version_dt_tm),
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(ds_sec_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (add_ds_section_relation(cnt_ds_key_uid=vc,cnt_ds_section_uid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_ds_section_r c
    SET c.cnt_ds_section_r_id = ccvk_id, c.cnt_ds_key_uid = cnt_ds_key_uid, c.cnt_ds_section_key_uid
      = cnt_ds_section_uid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_ele_chk_by_cd(code_value=f8) =vc)
   DECLARE doc_set_ele_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_sec_element_key c
    PLAN (c
     WHERE c.cnt_ds_sec_element_key_id=code_value)
    DETAIL
     doc_set_ele_uid = c.cnt_ds_sec_element_key_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_ele_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_ele_event_cd_chk_by_cd(code_value=f8) =vc)
   DECLARE doc_set_ele_event_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_sec_element_key c
    PLAN (c
     WHERE c.event_cd=code_value)
    DETAIL
     doc_set_ele_event_uid = c.event_cd_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_ele_event_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_dta_event_cd_chk_by_cd(task_assay_cd=f8) =vc)
   DECLARE doc_set_ele_dta_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_sec_element_key c
    PLAN (c
     WHERE c.task_assay_cd=task_assay_cd)
    DETAIL
     doc_set_ele_dta_uid = c.task_assay_cd_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_ele_dta_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_ele_type_cd_chk_by_cd(element_type_cd=f8) =vc)
   DECLARE doc_set_ele_type_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_sec_element_key c
    PLAN (c
     WHERE c.element_type_cd=element_type_cd)
    DETAIL
     doc_set_ele_type_uid = c.element_type_cd_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_ele_type_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_ele_insert(cnt_ds_sec_element_id=f8,cnt_ds_sec_element_uid=vc,
  doc_set_element_name=vc,doc_set_element_description=vc,active_ind=i2,event_cd=f8,event_cd_cki=vc,
  event_cd_concept_cki=vc,event_cd_disp=vc,event_cd_uid=vc,task_assay_cd=f8,task_assay_cki=vc,
  task_assay_disp=vc,task_assay_cd_uid=vc,required_ind=i2,read_only_ind=i2,doc_set_elem_sequence=i2,
  element_type_cd=f8,element_type_disp=vc,element_type_mean=vc,element_type_cd_uid=vc,
  allow_comment_ind=i2,version_dt_tm=dq8) =vc)
   DECLARE temp_ds_sec_ele_guid = c36
   DECLARE ds_sec_ele_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_ds_sec_ele_guid = uar_createuuid(0)
   IF (cnt_ds_sec_element_id=0.0)
    SET cnt_ds_sec_element_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (cnt_ds_sec_element_uid IN ("", " ", null))
    SET ds_sec_ele_guid = concat(prefix,build(temp_ds_sec_ele_guid))
   ELSE
    SET ds_sec_ele_guid = cnt_ds_sec_element_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_ds_sec_element_key c
    SET c.cnt_ds_sec_element_key_id = cnt_ds_sec_element_id, c.cnt_ds_sec_element_key_uid =
     ds_sec_ele_guid, c.doc_set_element_name = doc_set_element_name,
     c.doc_set_element_description = doc_set_element_description, c.active_ind = active_ind, c
     .event_cd = event_cd,
     c.event_cd_cki = event_cd_cki, c.event_cd_concept_cki = event_cd_concept_cki, c
     .event_cd_display_name = event_cd_disp,
     c.event_cd_uid = event_cd_uid, c.task_assay_cd = task_assay_cd, c.task_assay_cki =
     task_assay_cki,
     c.task_assay_display_name = task_assay_disp, c.task_assay_cd_uid = task_assay_cd_uid, c
     .required_ind = required_ind,
     c.read_only_ind = read_only_ind, c.doc_set_elem_sequence = doc_set_elem_sequence, c
     .element_type_cd = element_type_cd,
     c.element_type_display_name = element_type_disp, c.element_type_mean_txt = element_type_mean, c
     .element_type_cd_uid = element_type_cd_uid,
     c.allow_comment_ind = allow_comment_ind, c.version_dt_tm = cnvtdatetime(version_dt_tm), c
     .updt_id = reqinfo->updt_id,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo
     ->updt_applctx,
     c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(ds_sec_ele_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_ele_update(cnt_ds_sec_element_id=f8,cnt_ds_sec_element_uid=vc,
  doc_set_element_name=vc,doc_set_element_description=vc,active_ind=i2,event_cd=f8,event_cd_cki=vc,
  event_cd_concept_cki=vc,event_cd_disp=vc,event_cd_uid=vc,task_assay_cd=f8,task_assay_cki=vc,
  task_assay_disp=vc,task_assay_cd_uid=vc,required_ind=i2,read_only_ind=i2,doc_set_elem_sequence=i2,
  element_type_cd=f8,element_type_disp=vc,element_type_mean=vc,element_type_cd_uid=vc,
  allow_comment_ind=i2,version_dt_tm=dq8) =vc)
  IF (version_dt_tm IN (0, null))
   SET version_dt_tm = sysdate
  ENDIF
  UPDATE  FROM cnt_ds_sec_element_key c
   SET c.doc_set_element_name = doc_set_element_name, c.doc_set_element_description =
    doc_set_element_description, c.active_ind = active_ind,
    c.event_cd = event_cd, c.event_cd_cki = event_cd_cki, c.event_cd_concept_cki =
    event_cd_concept_cki,
    c.event_cd_display_name = event_cd_disp, c.event_cd_uid = event_cd_uid, c.task_assay_cd =
    task_assay_cd,
    c.task_assay_cki = task_assay_cki, c.task_assay_display_name = task_assay_disp, c
    .task_assay_cd_uid = task_assay_cd_uid,
    c.required_ind = required_ind, c.read_only_ind = read_only_ind, c.doc_set_elem_sequence =
    doc_set_elem_sequence,
    c.element_type_cd = element_type_cd, c.element_type_display_name = element_type_disp, c
    .element_type_mean_txt = element_type_mean,
    c.element_type_cd_uid = element_type_cd_uid, c.allow_comment_ind = allow_comment_ind, c
    .version_dt_tm = cnvtdatetime(version_dt_tm),
    c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
    updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx
   WHERE c.cnt_ds_sec_element_key_uid=cnt_ds_sec_element_uid
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE (add_ds_section_ele_relation(cnt_ds_section_uid=vc,cnt_ds_sec_element_uid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_ds_section_element_r c
    SET c.cnt_ds_section_element_r_id = ccvk_id, c.cnt_ds_section_key_uid = cnt_ds_section_uid, c
     .cnt_ds_sec_element_key_uid = cnt_ds_sec_element_uid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_label_id_chk_by_cd(label_template_id=f8) =vc)
   DECLARE doc_set_label_id_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_label_key c
    PLAN (c
     WHERE c.label_template_id=label_template_id)
    DETAIL
     doc_set_label_id_uid = c.cnt_ds_label_key_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_label_id_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_label_insert(label_template_id=f8,label_template_uid=vc,
  encounter_specific_ind=i2,version_dt_tm=dq8) =vc)
   DECLARE temp_ds_sec_label_guid = c36
   DECLARE ds_sec_label_guid = vc WITH noconstant(" ")
   DECLARE ccvk_id = f8
   EXECUTE ccluarxrtl
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   SET temp_ds_sec_label_guid = uar_createuuid(0)
   IF (label_template_id=0.0)
    SET label_template_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (label_template_uid IN ("", " ", null))
    SET ds_sec_label_guid = concat(prefix,build(temp_ds_sec_label_guid))
   ELSE
    SET ds_sec_label_guid = label_template_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_ds_label_key c
    SET c.cnt_ds_label_key_id = ccvk_id, c.label_template_id = label_template_id, c
     .cnt_ds_label_key_uid = ds_sec_label_guid,
     c.encounter_specific_ind = encounter_specific_ind, c.version_dt_tm = cnvtdatetime(version_dt_tm),
     c.updt_id = reqinfo->updt_id,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo
     ->updt_applctx,
     c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(ds_sec_label_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_label_update(label_template_id=f8,label_template_uid=vc,
  encounter_specific_ind=i2,version_dt_tm=dq8) =vc)
  IF (version_dt_tm IN (0, null))
   SET version_dt_tm = sysdate
  ENDIF
  UPDATE  FROM cnt_ds_label_key c
   SET c.encounter_specific_ind = encounter_specific_ind, c.label_template_id = label_template_id, c
    .version_dt_tm = cnvtdatetime(version_dt_tm),
    c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
    updt_task,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx
   WHERE c.cnt_ds_label_key_uid=label_template_uid
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE (add_ds_label_relation(doc_set_uid=vc,cnt_ds_label_uid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_ds_label_r c
    SET c.cnt_ds_label_r_id = ccvk_id, c.cnt_ds_key_uid = doc_set_uid, c.cnt_ds_label_key_uid =
     cnt_ds_label_uid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_assay_id_chk_by_cd(assay_id=f8) =vc)
   DECLARE doc_set_assay_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_ds_label_assay_key c
    PLAN (c
     WHERE c.cnt_ds_label_assay_key_id=assay_id)
    DETAIL
     doc_set_assay_uid = c.cnt_ds_label_assay_key_uid
    WITH nocounter
   ;end select
   RETURN(doc_set_assay_uid)
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_label_assay_insert(cnt_ds_label_assay_id=f8,cnt_ds_label_assay_uid=vc,
  dta_mnemonic=vc,activity_type_disp=vc,version_dt_tm=dq8) =vc)
   DECLARE temp_ds_label_assay_guid = c36
   DECLARE ds_label_assay_guid = vc WITH noconstant(" ")
   EXECUTE ccluarxrtl
   SET temp_ds_label_assay_guid = uar_createuuid(0)
   IF (cnt_ds_label_assay_id=0.0)
    SET cnt_ds_label_assay_id = get_next_seq("REFERENCE_SEQ")
   ENDIF
   IF (cnt_ds_label_assay_uid IN ("", " ", null))
    SET ds_label_assay_guid = concat(prefix,build(temp_ds_label_assay_guid))
   ELSE
    SET ds_label_assay_guid = cnt_ds_label_assay_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_ds_label_assay_key c
    SET c.cnt_ds_label_assay_key_id = cnt_ds_label_assay_id, c.cnt_ds_label_assay_key_uid =
     ds_label_assay_guid, c.dta_mnemonic = dta_mnemonic,
     c.activity_type_disp_txt = activity_type_disp, c.version_dt_tm = cnvtdatetime(version_dt_tm), c
     .updt_id = reqinfo->updt_id,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo
     ->updt_applctx,
     c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(ds_label_assay_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_doc_set_label_assay_update(cnt_ds_label_assay_id=f8,cnt_ds_label_assay_uid=vc,
  dta_mnemonic=vc,activity_type_disp=vc,version_dt_tm=dq8) =vc)
  IF (version_dt_tm IN (0, null))
   SET version_dt_tm = sysdate
  ENDIF
  UPDATE  FROM cnt_ds_label_assay_key lak
   SET lak.dta_mnemonic = dta_mnemonic, lak.activity_type_disp_txt = activity_type_disp, lak
    .version_dt_tm = cnvtdatetime(version_dt_tm),
    lak.updt_id = reqinfo->updt_id, lak.updt_dt_tm = cnvtdatetime(sysdate), lak.updt_task = reqinfo->
    updt_task,
    lak.updt_cnt = (lak.updt_cnt+ 1), lak.updt_applctx = reqinfo->updt_applctx
   WHERE lak.cnt_ds_label_assay_key_uid=cnt_ds_label_assay_uid
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE (add_ds_label_assay_relation(cnt_ds_label_uid=vc,cnt_ds_label_assay_uid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_ds_label_assay_r c
    SET c.cnt_ds_label_assay_r_id = ccvk_id, c.cnt_ds_label_key_uid = cnt_ds_label_uid, c
     .cnt_ds_label_assay_key_uid = cnt_ds_label_assay_uid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (cnt_wv_cond_exp_chk_by_id(exp_id=f8) =vc)
   DECLARE cond_exp_uid = vc WITH noconstant(" ")
   SELECT INTO "nl:"
    FROM cnt_cond_expression_key ce
    PLAN (ce
     WHERE ce.cond_expression_id=exp_id)
    DETAIL
     cond_exp_uid = ce.cnt_cond_expression_key_uid
    WITH nocounter
   ;end select
   RETURN(cond_exp_uid)
 END ;Subroutine
 SUBROUTINE (cnt_wv_con_exp_insert(con_exp_id=f8,con_exp_uid=vc,con_act_ind=i2,con_exp_name=vc,
  con_exp_txt=vc,con_exp_pos_txt=vc,con_exp_mul_ind=i2,con_exp_prev_id=f8,version_dt_tm=dq8) =vc)
   DECLARE temp_cond_exp_guid = c36
   DECLARE cond_exp_guid = vc WITH noconstant(" ")
   DECLARE cond_id = f8 WITH noconstant(0.0)
   SET cond_id = get_next_seq("REFERENCE_SEQ")
   EXECUTE ccluarxrtl
   SET temp_cond_exp_guid = uar_createuuid(0)
   IF (con_exp_uid IN ("", " ", null))
    SET cond_exp_guid = concat(prefix,build(temp_cond_exp_guid))
   ELSE
    SET cond_exp_guid = con_exp_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_cond_expression_key c
    SET c.cnt_cond_expression_key_id = cond_id, c.cnt_cond_expression_key_uid = cond_exp_guid, c
     .active_ind = con_act_ind,
     c.cond_expression_id = con_exp_id, c.cond_expression_name = con_exp_name, c.cond_expression_txt
      = con_exp_txt,
     c.cond_postfix_txt = con_exp_pos_txt, c.multiple_ind = con_exp_mul_ind, c
     .prev_cond_expression_id = con_exp_prev_id,
     c.dcp_cond_expression_ref_id = 0.0, c.version_dt_tm = cnvtdatetime(version_dt_tm), c.updt_id =
     reqinfo->updt_id,
     c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo
     ->updt_applctx,
     c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(cond_exp_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_wv_con_exp_update(con_exp_id=f8,con_exp_uid=vc,con_act_ind=i2,con_exp_name=vc,
  con_exp_txt=vc,con_exp_pos_txt=vc,con_exp_mul_ind=i2,con_exp_prev_id=f8,version_dt_tm=dq8) =vc)
  IF (version_dt_tm IN (0, null))
   SET version_dt_tm = sysdate
  ENDIF
  UPDATE  FROM cnt_cond_expression_key c
   SET c.active_ind = con_act_ind, c.cond_expression_id = con_exp_id, c.cond_expression_name =
    con_exp_name,
    c.cond_expression_txt = con_exp_txt, c.cond_postfix_txt = con_exp_pos_txt, c.multiple_ind =
    con_exp_mul_ind,
    c.prev_cond_expression_id = con_exp_prev_id, c.version_dt_tm = cnvtdatetime(version_dt_tm), c
    .updt_id = reqinfo->updt_id,
    c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt
    + 1),
    c.updt_applctx = reqinfo->updt_applctx
   WHERE c.cnt_cond_expression_key_uid=con_exp_uid
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE (cnt_wv_con_com_insert(con_com_id=f8,con_com_uid=vc,con_com_act_ind=i2,con_com_name=vc,
  con_com_comp_id=f8,con_com_opr_cd=f8,con_com_opr_cd_uid=vc,con_com_prev_id=f8,con_com_req_ind=i2,
  con_com_res_val=f8,con_com_assay_cd=f8,con_com_assay_cd_uid=vc,version_dt_tm=dq8,ar_uid=vc) =vc)
   DECLARE temp_cond_com_guid = c36
   DECLARE cond_com_guid = vc WITH noconstant(" ")
   DECLARE cond_id = f8 WITH noconstant(0.0)
   SET cond_id = get_next_seq("REFERENCE_SEQ")
   EXECUTE ccluarxrtl
   SET temp_cond_com_guid = uar_createuuid(0)
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   IF (con_com_uid IN ("", " ", null))
    SET cond_com_guid = concat(prefix,build(temp_cond_com_guid))
   ELSE
    SET cond_com_guid = con_com_uid
   ENDIF
   INSERT  FROM cnt_cond_exprsn_comp_key cc
    SET cc.active_ind = con_com_act_ind, cc.cnt_cond_exprsn_comp_key_id = cond_id, cc
     .cnt_cond_exprsn_comp_key_uid = cond_com_guid,
     cc.cond_comp_name = con_com_name, cc.cond_exprsn_comp_id = con_com_comp_id, cc.cond_exprsn_id =
     con_com_id,
     cc.dcp_cond_exp_comp_id_ref_id = 0.0, cc.operator_cd = con_com_opr_cd, cc.operator_cd_uid =
     con_com_opr_cd_uid,
     cc.prev_cond_exprsn_comp_id = con_com_prev_id, cc.required_ind = con_com_req_ind, cc
     .result_value = con_com_res_val,
     cc.trigger_assay_cd = con_com_assay_cd, cc.trigger_assay_cd_uid = con_com_assay_cd_uid, cc
     .version_dt_tm = cnvtdatetime(version_dt_tm),
     cc.ar_uid = ar_uid, cc.updt_id = reqinfo->updt_id, cc.updt_dt_tm = cnvtdatetime(sysdate),
     cc.updt_task = reqinfo->updt_task, cc.updt_applctx = reqinfo->updt_applctx, cc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(cond_com_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cnt_wv_con_dta_insert(con_dta_act_ind=i2,con_dta_age_from_nbr=i4,con_dta_age_from_cd=f8,
  con_dta_age_from_uid=vc,con_dta_age_to_nbr=i4,con_dta_age_to_cd=f8,con_dta_age_to_uid=vc,
  con_dta_uid=vc,con_dta_assay_cd=f8,con_dta_assay_uid=vc,ref_id=f8,con_dta_exp_id=f8,cnt_dta_ref_id=
  f8,con_dta_gen_cd=f8,con_dta_gen_cd_uid=vc,con_dta_loc_cd=f8,con_dta_loc_cd_uid=vc,con_dta_pos_cd=
  f8,con_dta_pos_cd_uid=vc,con_dta_prev_id=f8,con_dta_req_ind=i2,version_dt_tm=dq8) =vc)
   DECLARE temp_cond_dta_guid = c36
   DECLARE cond_dta_guid = vc WITH noconstant(" ")
   DECLARE cond_id = f8 WITH noconstant(0.0)
   SET cond_id = get_next_seq("REFERENCE_SEQ")
   EXECUTE ccluarxrtl
   SET temp_cond_dta_guid = uar_createuuid(0)
   IF (con_dta_uid IN ("", " ", null))
    SET cond_dta_guid = concat(prefix,build(temp_cond_dta_guid))
   ELSE
    SET cond_dta_guid = con_dta_uid
   ENDIF
   IF (version_dt_tm IN (0, null))
    SET version_dt_tm = sysdate
   ENDIF
   INSERT  FROM cnt_conditional_dta_key ccd
    SET ccd.active_ind = con_dta_act_ind, ccd.age_from_nbr = con_dta_age_from_nbr, ccd
     .age_from_unit_cd = con_dta_age_from_cd,
     ccd.age_from_unit_cd_uid = con_dta_age_from_uid, ccd.age_to_nbr = con_dta_age_to_nbr, ccd
     .age_to_unit_cd = con_dta_age_to_cd,
     ccd.age_to_unit_cd_uid = con_dta_age_to_uid, ccd.cnt_conditional_dta_key_id = cond_id, ccd
     .cnt_conditional_dta_key_uid = cond_dta_guid,
     ccd.conditional_assay_cd = con_dta_assay_cd, ccd.conditional_assay_cd_uid = con_dta_assay_uid,
     ccd.conditional_dta_id = ref_id,
     ccd.cond_expression_id = con_dta_exp_id, ccd.dcp_cond_dta_ref_id = cnt_dta_ref_id, ccd.gender_cd
      = con_dta_gen_cd,
     ccd.gender_cd_uid = con_dta_gen_cd_uid, ccd.required_ind = con_dta_req_ind, ccd.location_cd =
     con_dta_loc_cd,
     ccd.location_cd_uid = con_dta_loc_cd_uid, ccd.position_cd = con_dta_pos_cd, ccd.position_cd_uid
      = con_dta_pos_cd_uid,
     ccd.prev_conditional_dta_id = con_dta_prev_id, ccd.version_dt_tm = cnvtdatetime(version_dt_tm),
     ccd.updt_id = reqinfo->updt_id,
     ccd.updt_dt_tm = cnvtdatetime(sysdate), ccd.updt_task = reqinfo->updt_task, ccd.updt_applctx =
     reqinfo->updt_applctx,
     ccd.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(cond_dta_guid)
   ENDIF
 END ;Subroutine
 SUBROUTINE is_internal_domain(null)
   DECLARE is_internal_domain = i2
   SET is_internal_domain = 0
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="KNOWLEDGE INDEX APPLICATIONS"
      AND d.info_name="KIA_CMT_DOMAIN")
    DETAIL
     is_internal_domain = 1
    WITH nocounter
   ;end select
   RETURN(is_internal_domain)
 END ;Subroutine
 SUBROUTINE (cnt_wv_update_old_rows(display_name=vc) =f8)
   DECLARE ref_id = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    FROM cnt_wv_key w1
    PLAN (w1
     WHERE cnvtupper(trim(w1.display_name))=cnvtupper(trim(display_name))
      AND w1.active_ind=1)
    ORDER BY w1.updt_dt_tm DESC
    DETAIL
     IF (ref_id=0.0)
      ref_id = w1.dcp_wv_ref_id
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM cnt_wv_key w
    SET w.active_ind = 0, w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(sysdate),
     w.updt_task = reqinfo->updt_task, w.updt_cnt = (w.updt_cnt+ 1), w.updt_applctx = reqinfo->
     updt_applctx
    WHERE cnvtupper(trim(w.display_name))=cnvtupper(trim(display_name))
    WITH nocounter
   ;end update
   RETURN(ref_id)
 END ;Subroutine
 SUBROUTINE (add_item_da_dta_relation(wv_item_guid=vc,da_assay_cd_uid=vc) =i2)
   DECLARE return_val = i2
   DECLARE ccvk_id = f8
   SET ccvk_id = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM cnt_wv_item_dta c
    SET c.cnt_wv_item_dta_id = ccvk_id, c.wv_item_uid = wv_item_guid, c.task_assay_uid =
     da_assay_cd_uid,
     c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
     updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET return_val = 0
   ELSE
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SELECT
  *
  FROM dtable
  WHERE table_name="CNT_DTA_OFFSET_MIN"
 ;end select
 IF (curqual > 0)
  SET dtaoffset_table_ind = 1
 ENDIF
 SELECT
  *
  FROM dtable
  WHERE table_name="CNT_ALPHA_RESP_CATEGORY"
 ;end select
 IF (curqual > 0)
  SET category_table_ind = 1
 ENDIF
 SELECT
  *
  FROM dtable
  WHERE table_name="CNT_ADVANCED_DELTA"
 ;end select
 IF (curqual > 0)
  SET advanced_table_ind = 1
 ENDIF
 RANGE OF c IS cnt_dta
 SET rad_column_ind = validate(c.rad_sect_type_cduid)
 FREE RANGE c
 SELECT
  *
  FROM dtable
  WHERE table_name="CNT_RELATED_ASSAY"
 ;end select
 IF (curqual > 0)
  SET relassay_table_ind = 1
 ENDIF
 RANGE OF c IS cnt_rrf_ar_r
 SET truth_column_ind = validate(c.truth_state_cduid)
 FREE RANGE c
 IF (validate(request->dta_obj_list[1].dta_obj.exported_dt_tm,0) != 0)
  SET compare_dt_tm = request->dta_obj_list[1].dta_obj.exported_dt_tm
 ELSEIF ((request->file_dt_tm=0))
  SET compare_dt_tm = sysdate
 ELSE
  SET compare_dt_tm = request->file_dt_tm
 ENDIF
 FOR (dta_a = 1 TO size(request->dta_obj_list,5))
   SET ta_uid = ""
   SET new_dta = 1
   SET tmp_dta_key_id = 0.0
   SET tmp_dta_id = 0.0
   IF ((dta_struct->task_assay_guid > " "))
    SET ta_uid = dta_struct->task_assay_guid
    SET ta_uid = replace(ta_uid,"UNKNOWN!","CERNER!",1)
   ELSEIF ((dta_struct->dta_mnemonic > " "))
    SET ta_uid = concat("TEMP!",dta_struct->dta_mnemonic)
    SET ta_uid = cnt_dta_chk_uid(ta_uid)
   ENDIF
   SELECT INTO "nl:"
    FROM cnt_dta_key2 c
    PLAN (c
     WHERE trim(c.task_assay_uid)=ta_uid)
    DETAIL
     new_dta = 0
    WITH nocounter
   ;end select
   SET dta_replace = 0
   IF (new_dta=0)
    SELECT INTO "nl:"
     FROM cnt_dta_key2 c
     PLAN (c
      WHERE c.task_assay_uid=ta_uid)
     DETAIL
      IF (cnvtdatetime(compare_dt_tm) >= cnvtdatetime(c.version_dt_tm))
       dta_replace = 1, tmp_dta_key_id = c.cnt_dta_key_id
      ENDIF
     WITH check
    ;end select
    IF (dta_replace=1)
     UPDATE  FROM cnt_dta_key2 c
      SET c.version_dt_tm = cnvtdatetime(compare_dt_tm), c.updt_dt_tm = cnvtdatetime(sysdate), c
       .updt_id = reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c
       .updt_cnt+ 1)
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end update
     DELETE  FROM cnt_dta c
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end delete
     DELETE  FROM cnt_data_map c
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end delete
     DELETE  FROM cnt_dta_rrf_r c
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end delete
     DELETE  FROM cnt_ref_text c
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end delete
     DELETE  FROM cnt_rrf c
      WHERE  NOT ( EXISTS (
      (SELECT
       r.rrf_uid
       FROM cnt_rrf_key r
       WHERE r.rrf_uid=c.rrf_uid)))
       AND c.cnt_rrf_id != 0.00
      WITH check
     ;end delete
     DELETE  FROM cnt_rrf_ar_r c
      WHERE  NOT ( EXISTS (
      (SELECT
       r.rrf_uid
       FROM cnt_rrf_key r
       WHERE r.rrf_uid=c.rrf_uid)))
       AND c.cnt_rrf_ar_r_id != 0.00
      WITH check
     ;end delete
     DELETE  FROM cnt_related_assay c
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end delete
     COMMIT
     SET log_txt = ""
     SET log_txt = build("Rebuilding DTA: ",ta_uid)
     CALL cnt_imp_dta_log(logfile_name,log_txt,1)
    ENDIF
   ENDIF
   IF (new_dta=1)
    SELECT INTO "nl:"
     tmp_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      tmp_dta_key_id = tmp_id
     WITH format, counter
    ;end select
    INSERT  FROM cnt_dta_key2 c
     SET c.task_assay_uid = ta_uid, c.task_assay_disp = dta_struct->dta_mnemonic, c.task_assay_cd =
      0.0,
      c.version_dt_tm = cnvtdatetime(compare_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_dt_tm =
      cnvtdatetime(sysdate),
      c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
      c.cnt_dta_key_id = tmp_dta_key_id
     WITH nocounter
    ;end insert
    SET log_txt = ""
    SET log_txt = build("Inserting DTA:",ta_uid)
    CALL cnt_imp_dta_log(logfile_name,log_txt,1)
   ENDIF
   IF (((new_dta=1
    AND curqual > 0) OR (dta_replace=1)) )
    IF (new_dta=1
     AND curqual > 0)
     UPDATE  FROM cnt_section_dta_r c
      SET c.cnt_dta_key_id = tmp_dta_key_id
      WHERE c.task_assay_uid=ta_uid
      WITH nocounter
     ;end update
    ENDIF
    SELECT INTO "nl:"
     tmp_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      tmp_dta_id = tmp_id
     WITH format, counter
    ;end select
    IF (rad_column_ind=1
     AND witness_req_ind=1)
     INSERT  FROM cnt_dta c
      SET c.task_assay_uid = ta_uid, c.active_ind = 1, c.activity_type_cd = 0.0,
       c.activity_type_cduid =
       IF ((dta_struct->activity_type_cduid > " ")) trim(dta_struct->activity_type_cduid)
       ELSEIF (trim(dta_struct->activity_type_disp) > " ") concat("&DISPLAY&106&",trim(dta_struct->
          activity_type_disp))
       ELSE " "
       ENDIF
       , c.bb_result_type_cd = 0.0, c.bb_result_type_cduid =
       IF ((dta_struct->bb_result_type_cduid > " ")) trim(dta_struct->bb_result_type_cduid)
       ELSEIF (trim(dta_struct->bb_result_type_disp_key) > " ") concat("&DISPLAY_KEY&1636&",trim(
          dta_struct->bb_result_type_disp_key))
       ELSE " "
       ENDIF
       ,
       c.cerner_defined_ind = 0, c.cnt_dta_id = tmp_dta_id, c.cnt_dta_key_id = tmp_dta_key_id,
       c.cnt_dta_key_task_assay_uid = " ", c.code_set = dta_struct->code_set, c.concept_cki =
       dta_struct->concept_cki,
       c.default_result_type_cd = 0.0, c.default_result_type_cduid =
       IF ((dta_struct->default_result_type_cduid > " ")) trim(dta_struct->default_result_type_cduid)
       ELSEIF ((dta_struct->default_result_type_disp_key > " ")) concat("&DISPLAY_KEY&289&",trim(
          dta_struct->default_result_type_disp_key))
       ELSE " "
       ENDIF
       , c.default_type_flag = dta_struct->default_type_flag,
       c.delta_lvl_flag = 0, c.description = dta_struct->dta_description, c.dta_cki = dta_struct->
       dta_cki,
       c.dta_internal_uid = " ", c.event_cd = 0.0, c.event_code_cduid =
       IF ((dta_struct->event_cduid > " ")) trim(dta_struct->event_cduid)
       ELSEIF ((dta_struct->event_code_disp > " ")) concat("&DISPLAY&72&",trim(dta_struct->
          event_code_disp))
       ELSE " "
       ENDIF
       ,
       c.history_activity_type_cd = 0.0, c.history_activity_type_cduid = " ", c.icd_code_ind = 0,
       c.interp_data_ind = 0, c.io_flag = dta_struct->io_flag, c.mnemonic = dta_struct->dta_mnemonic,
       c.mnemonic_key_cap = cnvtupper(dta_struct->dta_mnemonic), c.modifier_ind = 0, c
       .print_ref_ranges_on_rept_ind = 0,
       c.print_results = 0, c.rad_section_type_cd = 0.0, c.rad_sect_type_cduid =
       IF ((dta_struct->rad_section_type_cduid > " ")) trim(dta_struct->rad_section_type_cduid)
       ELSEIF ((dta_struct->rad_section_type_disp_key > " ")) concat("&DISPLAY_KEY&14286&",trim(
          dta_struct->rad_section_type_disp_key))
       ELSE " "
       ENDIF
       ,
       c.ref_range_script = " ", c.rel_assay_ind = 0, c.rendering_provider_ind = 0,
       c.sci_notation_ind = dta_struct->sci_notation_ind, c.signature_line_ind = dta_struct->
       witness_required_ind, c.single_select_ind = dta_struct->single_select_ind,
       c.strt_assay_id = 0, c.task_rept_ind = 0, c.transmit_ind = 0,
       c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = sysdate,
       c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.version_number = 0
      WITH check
     ;end insert
    ELSE
     INSERT  FROM cnt_dta c
      SET c.task_assay_uid = ta_uid, c.active_ind = 1, c.activity_type_cd = 0.0,
       c.activity_type_cduid =
       IF ((dta_struct->activity_type_cduid > " ")) trim(dta_struct->activity_type_cduid)
       ELSEIF (trim(dta_struct->activity_type_disp) > " ") concat("&DISPLAY&106&",trim(dta_struct->
          activity_type_disp))
       ELSE " "
       ENDIF
       , c.bb_result_type_cd = 0.0, c.bb_result_type_cduid =
       IF ((dta_struct->bb_result_type_cduid > " ")) trim(dta_struct->bb_result_type_cduid)
       ELSEIF (trim(dta_struct->bb_result_type_disp_key) > " ") concat("&DISPLAY_KEY&1636&",trim(
          dta_struct->bb_result_type_disp_key))
       ELSE " "
       ENDIF
       ,
       c.cerner_defined_ind = 0, c.cnt_dta_id = tmp_dta_id, c.cnt_dta_key_id = tmp_dta_key_id,
       c.cnt_dta_key_task_assay_uid = " ", c.code_set = dta_struct->code_set, c.concept_cki =
       dta_struct->concept_cki,
       c.default_result_type_cd = 0.0, c.default_result_type_cduid =
       IF ((dta_struct->default_result_type_cduid > " ")) trim(dta_struct->default_result_type_cduid)
       ELSEIF ((dta_struct->default_result_type_disp_key > " ")) concat("&DISPLAY_KEY&289&",trim(
          dta_struct->default_result_type_disp_key))
       ELSE " "
       ENDIF
       , c.default_type_flag = dta_struct->default_type_flag,
       c.delta_lvl_flag = 0, c.description = dta_struct->dta_description, c.dta_cki = dta_struct->
       dta_cki,
       c.dta_internal_uid = " ", c.event_cd = 0.0, c.event_code_cduid =
       IF ((dta_struct->event_cduid > " ")) trim(dta_struct->event_cduid)
       ELSEIF ((dta_struct->event_code_disp > " ")) concat("&DISPLAY&72&",trim(dta_struct->
          event_code_disp))
       ELSE " "
       ENDIF
       ,
       c.history_activity_type_cd = 0.0, c.history_activity_type_cduid = " ", c.icd_code_ind = 0,
       c.interp_data_ind = 0, c.io_flag = dta_struct->io_flag, c.mnemonic = dta_struct->dta_mnemonic,
       c.mnemonic_key_cap = cnvtupper(dta_struct->dta_mnemonic), c.modifier_ind = 0, c
       .print_ref_ranges_on_rept_ind = 0,
       c.print_results = 0, c.rad_section_type_cd = 0.0, c.ref_range_script = " ",
       c.rel_assay_ind = 0, c.rendering_provider_ind = 0, c.sci_notation_ind = dta_struct->
       sci_notation_ind,
       c.signature_line_ind = 0, c.single_select_ind = dta_struct->single_select_ind, c.strt_assay_id
        = 0,
       c.task_rept_ind = 0, c.transmit_ind = 0, c.updt_applctx = reqinfo->updt_applctx,
       c.updt_cnt = 0, c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task, c.version_number = 0
      WITH check
     ;end insert
    ENDIF
    IF (size(request->dta_obj_list[dta_a].dta_obj.data_map_list,5) > 0)
     DELETE  FROM cnt_data_map c
      WHERE c.task_assay_uid=ta_uid
      WITH check
     ;end delete
     FOR (dta_dm = 1 TO size(request->dta_obj_list[dta_a].dta_obj.data_map_list,5))
       INSERT  FROM cnt_data_map c
        SET c.active_ind = 1, c.cnt_data_map_id = seq(reference_seq,nextval), c.cnt_dta_key_id =
         tmp_dta_key_id,
         c.data_map_type_flag = 0, c.max_digits = data_map_struct->max_digits, c.min_decimal_places
          = data_map_struct->min_decimal_places,
         c.min_digits = data_map_struct->min_digits, c.service_resource_cd = 0.0, c
         .service_resource_cduid =
         IF (trim(data_map_struct->service_resource_cduid) > " ") trim(data_map_struct->
           service_resource_cduid)
         ELSEIF (trim(data_map_struct->service_resource_disp) > " ") concat("&DISPLAY&221",trim(
            data_map_struct->service_resource_disp))
         ELSE " "
         ENDIF
         ,
         c.task_assay_uid = ta_uid, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
         c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
         updt_task
        WITH check
       ;end insert
       SET log_txt = ""
       SET log_txt = build("Inserting Data Map:",dta_dm,":",data_map_struct->min_digits,":",
        data_map_struct->max_digits,":",ta_uid)
       CALL cnt_imp_dta_log(logfile_name,log_txt,1)
     ENDFOR
    ENDIF
    IF (dtaoffset_table_ind=1
     AND offset_req_ind=1)
     IF (size(request->dta_obj_list[dta_a].dta_obj.offset_mins_list,5) > 0)
      DELETE  FROM cnt_dta_offset_min cdom
       WHERE cdom.task_assay_uid=ta_uid
       WITH check
      ;end delete
      FOR (dta_dom = 1 TO size(request->dta_obj_list[dta_a].dta_obj.offset_mins_list,5))
        INSERT  FROM cnt_dta_offset_min cdom
         SET cdom.task_assay_uid = ta_uid, cdom.cnt_dta_offset_min_id = seq(reference_seq,nextval),
          cdom.offset_min_type_cd = 0.0,
          cdom.offset_min_type_cduid =
          IF (trim(offset_mins_struct->offset_min_type_cduid) > " ") trim(offset_mins_struct->
            offset_min_type_cduid)
          ELSEIF (trim(offset_mins_struct->offset_min_type_mean) > " ") concat("&MEANING&4002164",
            trim(offset_mins_struct->offset_min_type_mean))
          ELSE " "
          ENDIF
          , cdom.offset_min_nbr = offset_mins_struct->offset_min_nbr, cdom.beg_effective_dt_tm =
          sysdate,
          cdom.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), cdom.active_ind = 1, cdom
          .updt_applctx = reqinfo->updt_applctx,
          cdom.updt_cnt = 0, cdom.updt_dt_tm = sysdate, cdom.updt_id = reqinfo->updt_id,
          cdom.updt_task = reqinfo->updt_task
         WITH check
        ;end insert
        SET log_txt = ""
        SET log_txt = build("Inserting dta offset mins:",dta_dom,":",offset_mins_struct->
         offset_min_type_mean,":",
         offset_mins_struct->offset_min_nbr,":",ta_uid)
        CALL cnt_imp_dta_log(logfile_name,log_txt,1)
      ENDFOR
     ENDIF
    ENDIF
    IF (relassay_table_ind=1)
     IF (size(request->dta_obj_list[dta_a].dta_obj.related_proc_type_list,5) > 0)
      DELETE  FROM cnt_related_assay cra
       WHERE cra.task_assay_uid=ta_uid
       WITH check
      ;end delete
      FOR (dta_proc = 1 TO size(request->dta_obj_list[dta_a].dta_obj.related_proc_type_list,5))
        INSERT  FROM cnt_related_assay cra
         SET cra.cnt_related_assay_id = seq(reference_seq,nextval), cra.task_assay_uid = ta_uid, cra
          .related_type_cd = 0.0,
          cra.active_ind = 1, cra.related_proc_type_cduid =
          IF (trim(dta_proc_struct->related_proc_type_cduid) > " ") trim(dta_proc_struct->
            related_proc_type_cduid)
          ELSEIF (trim(dta_proc_struct->related_proc_type_mean) > " ") concat("&MEANING&15189",trim(
             dta_proc_struct->related_proc_type_mean))
          ELSE " "
          ENDIF
          , cra.beg_effective_dt_tm = cnvtdatetime(sysdate),
          cra.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cra.active_status_cd = active_cd,
          cra.active_status_prsnl_id = reqinfo->updt_id,
          cra.active_status_dt_tm = cnvtdatetime(sysdate), cra.updt_applctx = reqinfo->updt_applctx,
          cra.updt_cnt = 0,
          cra.updt_dt_tm = sysdate, cra.updt_id = reqinfo->updt_id, cra.updt_task = reqinfo->
          updt_task
         WITH check
        ;end insert
      ENDFOR
     ENDIF
    ENDIF
    FOR (dta_rrf = 1 TO size(request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list,5))
      SET new_rrf = 1
      SET r_uid = ""
      SET tmp_rrf_id = 0.0
      SET tmp_rrf_key_id = 0.0
      IF ((rrf_struct->rrf_guid > " "))
       SET r_uid = trim(rrf_struct->rrf_guid)
      ELSE
       SET r_uid = build("TEMP!",ta_uid,rrf_struct->age_from,rrf_struct->age_from_units_disp_key,
        rrf_struct->age_to)
      ENDIF
      SET new_rrf = 1
      SELECT INTO "nl:"
       FROM cnt_rrf_key c
       PLAN (c
        WHERE c.rrf_uid=r_uid)
       DETAIL
        new_rrf = 0, tmp_rrf_key_id = c.cnt_rrf_key_id
       WITH check
      ;end select
      SET age_to_min = 0
      SET age_from_min = 0
      SELECT INTO "nl:"
       FROM cnt_code_value_key c
       PLAN (c
        WHERE c.code_set=340
         AND (((rrf_struct->age_from_units_cduid=c.code_value_uid)) OR (concat("&DISPLAY_KEY&340&",
         trim(rrf_struct->age_from_units_disp_key))=c.code_value_uid_alias)) )
       DETAIL
        CASE (c.code_value_uid)
         OF cduid_years:
          age_from_min = (min_year * rrf_struct->age_from)
         OF cduid_months:
          age_from_min = (min_month * rrf_struct->age_from)
         OF cduid_weeks:
          age_from_min = (min_week * rrf_struct->age_from)
         OF cduid_days:
          age_from_min = (min_day * rrf_struct->age_from)
         OF cduid_hours:
          age_from_min = (min_hour * rrf_struct->age_from)
         OF cduid_minutes:
          age_from_min = (min_minute * rrf_struct->age_from)
        ENDCASE
       WITH check
      ;end select
      IF ((rrf_struct->age_from > 0)
       AND age_from_min=0)
       IF ((rrf_struct->age_from_mean > ""))
        SET age_from_min = convert_age_to_minutes(rrf_struct->age_from,rrf_struct->age_from_mean)
       ELSE
        SET age_from_min = convert_age_to_minutes(rrf_struct->age_from,rrf_struct->
         age_from_units_disp_key)
       ENDIF
      ENDIF
      SELECT INTO "nl:"
       FROM cnt_code_value_key c
       PLAN (c
        WHERE c.code_set=340
         AND (((rrf_struct->age_to_units_cduid=c.code_value_uid)) OR (concat("&DISPLAY_KEY&340&",trim
         (rrf_struct->age_to_units_disp_key))=c.code_value_uid_alias)) )
       DETAIL
        CASE (c.code_value_uid)
         OF cduid_years:
          age_to_min = (min_year * rrf_struct->age_to)
         OF cduid_months:
          age_to_min = (min_month * rrf_struct->age_to)
         OF cduid_weeks:
          age_to_min = (min_week * rrf_struct->age_to)
         OF cduid_days:
          age_to_min = (min_day * rrf_struct->age_to)
         OF cduid_hours:
          age_to_min = (min_hour * rrf_struct->age_to)
         OF cduid_minutes:
          age_to_min = (min_minute * rrf_struct->age_to)
        ENDCASE
       WITH check
      ;end select
      IF ((rrf_struct->age_to > 0)
       AND age_to_min=0)
       IF ((rrf_struct->age_to_mean > ""))
        SET age_to_min = convert_age_to_minutes(rrf_struct->age_to,rrf_struct->age_to_mean)
       ELSE
        SET age_to_min = convert_age_to_minutes(rrf_struct->age_to,rrf_struct->age_to_units_disp_key)
       ENDIF
      ENDIF
      SELECT INTO "jpl.log"
       FROM dual
       DETAIL
        col 0, "r_uid", col 10,
        r_uid, row + 1, col 0,
        "age_to", col 10, age_to_min,
        row + 1, col 0, "age_to_units_disp_key",
        col 20, rrf_struct->age_to_units_disp_key, row + 1,
        col 0, "min_year:", col 20,
        min_year, row + 1, col 0,
        "rrf-age_to:", col 20, rrf_struct->age_to,
        row + 1
       WITH append
      ;end select
      IF (new_rrf=1)
       SELECT INTO "nl:"
        tmp_id = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         tmp_rrf_key_id = tmp_id
        WITH format, counter
       ;end select
       INSERT  FROM cnt_rrf_key c
        SET c.age_from_minutes = age_from_min, c.age_from_units_cd = 0.0, c.age_from_units_cduid =
         IF ((rrf_struct->age_from_units_cduid > " ")) trim(rrf_struct->age_from_units_cduid)
         ELSEIF ((rrf_struct->age_from_units_disp_key > " ")) concat("&DISPLAY_KEY&340&",trim(
            rrf_struct->age_from_units_disp_key))
         ELSE " "
         ENDIF
         ,
         c.age_to_minutes = age_to_min, c.age_to_units_cd = 0.0, c.age_to_units_cduid =
         IF ((rrf_struct->age_to_units_cduid > " ")) trim(rrf_struct->age_to_units_cduid)
         ELSEIF ((rrf_struct->age_to_units_disp_key > " ")) concat("&DISPLAY_KEY&340&",trim(
            rrf_struct->age_to_units_disp_key))
         ELSE " "
         ENDIF
         ,
         c.cnt_rrf_key_id = tmp_rrf_key_id, c.organism_cd = 0.0, c.organism_cduid = " ",
         c.patient_condition_cd = 0.0, c.patient_condition_cduid = " ", c.precedence_sequence = 0,
         c.rrf_internal_uid = " ", c.rrf_uid = r_uid, c.service_resource_cd = 0.0,
         c.service_resource_cduid =
         IF ((rrf_struct->service_resource_cduid > " ")) trim(rrf_struct->service_resource_cduid)
         ELSEIF (trim(rrf_struct->service_resource_disp) > " ") concat("&DISPLAY&221&",trim(
            rrf_struct->service_resource_disp))
         ELSE " "
         ENDIF
         , c.sex_cd = 0.0, c.sex_cduid =
         IF ((rrf_struct->sex_cduid > " ")) trim(rrf_struct->sex_cduid)
         ELSEIF (trim(rrf_struct->sex_disp_key) > " ") concat("&DISPLAY_KEY&57&",trim(rrf_struct->
            sex_disp_key))
         ELSE " "
         ENDIF
         ,
         c.species_cd = 0.0, c.species_cduid =
         IF ((rrf_struct->species_cduid > " ")) trim(rrf_struct->species_cduid)
         ELSEIF (trim(rrf_struct->species_disp) > " ") concat("&DISPLAY&226&",trim(rrf_struct->
            species_disp))
         ELSE " "
         ENDIF
         , c.specimen_type_cd = 0.0,
         c.specimen_type_cduid =
         IF ((rrf_struct->specimen_type_cduid > " ")) trim(rrf_struct->specimen_type_cduid)
         ELSEIF (trim(rrf_struct->specimen_type_disp) > " ") concat("&DISPLAY&2052&",trim(rrf_struct
            ->specimen_type_disp))
         ELSE " "
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
         c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
        WITH check
       ;end insert
      ELSE
       UPDATE  FROM cnt_rrf_key c
        SET c.age_from_minutes = age_from_min, c.age_from_units_cd = 0.0, c.age_from_units_cduid =
         IF ((rrf_struct->age_from_units_cduid > " ")) trim(rrf_struct->age_from_units_cduid)
         ELSEIF ((rrf_struct->age_from_units_disp_key > " ")) concat("&DISPLAY_KEY&340&",trim(
            rrf_struct->age_from_units_disp_key))
         ELSE " "
         ENDIF
         ,
         c.age_to_minutes = age_to_min, c.age_to_units_cd = 0.0, c.age_to_units_cduid =
         IF ((rrf_struct->age_to_units_cduid > " ")) trim(rrf_struct->age_to_units_cduid)
         ELSEIF ((rrf_struct->age_to_units_disp_key > " ")) concat("&DISPLAY_KEY&340&",trim(
            rrf_struct->age_to_units_disp_key))
         ELSE " "
         ENDIF
         ,
         c.organism_cd = 0.0, c.organism_cduid = " ", c.patient_condition_cd = 0.0,
         c.patient_condition_cduid = " ", c.precedence_sequence = 0, c.rrf_internal_uid = " ",
         c.service_resource_cd = 0.0, c.service_resource_cduid =
         IF ((rrf_struct->service_resource_cduid > " ")) trim(rrf_struct->service_resource_cduid)
         ELSEIF (trim(rrf_struct->service_resource_disp) > " ") concat("&DISPLAY&221&",trim(
            rrf_struct->service_resource_disp))
         ELSE " "
         ENDIF
         , c.sex_cd = 0.0,
         c.sex_cduid =
         IF ((rrf_struct->sex_cduid > " ")) trim(rrf_struct->sex_cduid)
         ELSEIF (trim(rrf_struct->sex_disp_key) > " ") concat("&DISPLAY_KEY&57&",trim(rrf_struct->
            sex_disp_key))
         ELSE " "
         ENDIF
         , c.species_cd = 0.0, c.species_cduid =
         IF ((rrf_struct->species_cduid > " ")) trim(rrf_struct->species_cduid)
         ELSEIF (trim(rrf_struct->species_disp) > " ") concat("&DISPLAY&226&",trim(rrf_struct->
            species_disp))
         ELSE " "
         ENDIF
         ,
         c.specimen_type_cd = 0.0, c.specimen_type_cduid =
         IF ((rrf_struct->specimen_type_cduid > " ")) trim(rrf_struct->specimen_type_cduid)
         ELSEIF (trim(rrf_struct->specimen_type_disp) > " ") concat("&DISPLAY&2052&",trim(rrf_struct
            ->specimen_type_disp))
         ELSE " "
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx,
         c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id,
         c.updt_task = reqinfo->updt_task
        WHERE c.rrf_uid=r_uid
        WITH check
       ;end update
      ENDIF
      SELECT INTO "nl:"
       FROM cnt_dta_rrf_r r
       PLAN (r
        WHERE r.rrf_uid=r_uid
         AND r.task_assay_uid=ta_uid)
       DETAIL
        tmp_rrf_id = r.cnt_rrf_id
       WITH check
      ;end select
      IF (curqual < 1)
       SELECT INTO "nl:"
        tmp_id = seq(reference_seq,nextval)
        FROM dual
        DETAIL
         tmp_rrf_id = tmp_id
        WITH format, counter
       ;end select
       INSERT  FROM cnt_dta_rrf_r c
        SET c.cnt_dta_id = tmp_dta_id, c.cnt_dta_rrf_r_id = seq(reference_seq,nextval), c.cnt_rrf_id
          = tmp_rrf_id,
         c.rrf_uid = r_uid, c.task_assay_uid = ta_uid, c.updt_applctx = reqinfo->updt_applctx,
         c.updt_cnt = 0, c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id,
         c.updt_task = reqinfo->updt_task
        WITH check
       ;end insert
      ENDIF
      SET log_txt = ""
      SET log_txt = build("Inserting RRF:",ta_uid,":",r_uid)
      CALL cnt_imp_dta_log(logfile_name,log_txt,1)
      SELECT INTO "nl:"
       FROM cnt_rrf c
       PLAN (c
        WHERE c.rrf_uid=r_uid)
       WITH check
      ;end select
      IF (curqual < 1)
       INSERT  FROM cnt_rrf c
        SET c.rrf_uid = r_uid, c.active_ind = 1, c.cnt_rrf_id = tmp_rrf_id,
         c.cnt_rrf_key_id = tmp_rrf_key_id, c.code_set = 0, c.critical_high = rrf_struct->
         critical_high,
         c.critical_ind =
         IF ((rrf_struct->critical_low > 0)
          AND (rrf_struct->critical_high > 0)) 3
         ELSEIF ((rrf_struct->critical_high > 0)) 2
         ELSEIF ((rrf_struct->critical_low > 0)) 1
         ELSE 0
         ENDIF
         , c.critical_low = rrf_struct->critical_low, c.default_result = 0.0,
         c.def_result_ind = 0, c.delta_check_type_cd = 0.0, c.delta_check_type_cduid = " ",
         c.delta_chk_flag = 0, c.delta_minutes = 0, c.delta_value = 0,
         c.dilute_ind = 0, c.encntr_type_cd = 0.0, c.encntr_type_cduid =
         IF ((rrf_struct->encntr_type_cduid > " ")) trim(rrf_struct->encntr_type_cduid)
         ELSEIF (trim(rrf_struct->encntr_type_disp) > " ") concat("&DISPLAY&71&",trim(rrf_struct->
            encntr_type_disp))
         ELSE " "
         ENDIF
         ,
         c.feasible_high = rrf_struct->feasible_high, c.feasible_ind =
         IF ((rrf_struct->feasible_low > 0)
          AND (rrf_struct->feasible_high > 0)) 3
         ELSEIF ((rrf_struct->feasible_high > 0)) 2
         ELSEIF ((rrf_struct->feasible_low > 0)) 1
         ELSE 0
         ENDIF
         , c.feasible_low = rrf_struct->feasible_low,
         c.gestational_ind = rrf_struct->gestational_ind, c.linear_high = rrf_struct->linear_high, c
         .linear_ind =
         IF ((rrf_struct->linear_low > 0)
          AND (rrf_struct->linear_high > 0)) 3
         ELSEIF ((rrf_struct->linear_high > 0)) 2
         ELSEIF ((rrf_struct->linear_low > 0)) 1
         ELSE 0
         ENDIF
         ,
         c.linear_low = rrf_struct->linear_low, c.mins_back = rrf_struct->mins_back, c.normal_high =
         rrf_struct->normal_high,
         c.normal_ind =
         IF ((rrf_struct->normal_low > 0)
          AND (rrf_struct->normal_high > 0)) 3
         ELSEIF ((rrf_struct->normal_high > 0)) 2
         ELSEIF ((rrf_struct->normal_low > 0)) 1
         ELSE 0
         ENDIF
         , c.normal_low = rrf_struct->normal_low, c.review_high = 0,
         c.review_ind = 0, c.review_low = 0, c.sensitive_high = rrf_struct->sensitive_high,
         c.sensitive_ind =
         IF ((rrf_struct->sensitive_low > 0)
          AND (rrf_struct->sensitive_high > 0)) 3
         ELSEIF ((rrf_struct->sensitive_high > 0)) 2
         ELSEIF ((rrf_struct->sensitive_low > 0)) 1
         ELSE 0
         ENDIF
         , c.sensitive_low = rrf_struct->sensitive_low, c.units_cd = 0.0,
         c.units_cduid =
         IF ((rrf_struct->units_cduid > " ")) trim(rrf_struct->units_cduid)
         ELSEIF (trim(rrf_struct->units_disp) > " ") concat("&DISPLAY&54&",trim(rrf_struct->
            units_disp))
         ELSE " "
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
         c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
        WITH check
       ;end insert
      ENDIF
      IF (category_table_ind=1
       AND category_req_ind=1)
       IF (dta_replace=1)
        DELETE  FROM cnt_alpha_resp_category carc
         WHERE carc.rrf_uid=r_uid
         WITH check
        ;end delete
       ENDIF
       SELECT INTO "nl:"
        FROM cnt_alpha_resp_category carc
        WHERE carc.rrf_uid=r_uid
        WITH check
       ;end select
       IF (curqual < 1)
        FOR (dta_arc = 1 TO size(request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[
         dta_rrf].reference_range_factor.alpha_category_list,5))
          INSERT  FROM cnt_alpha_resp_category carc
           SET carc.cnt_alpha_resp_category_id = seq(reference_seq,nextval), carc.category_name =
            category_struct->category_name, carc.display_seq = category_struct->display_seq,
            carc.expand_flag = category_struct->expand_flag, carc.rrf_uid = r_uid, carc.updt_applctx
             = reqinfo->updt_applctx,
            carc.updt_cnt = 0, carc.updt_dt_tm = sysdate, carc.updt_id = reqinfo->updt_id,
            carc.updt_task = reqinfo->updt_task
          ;end insert
        ENDFOR
       ENDIF
      ENDIF
      IF (dta_replace=1)
       DELETE  FROM cnt_rrf_ar_r c
        WHERE c.rrf_uid=r_uid
        WITH check
       ;end delete
      ENDIF
      SELECT INTO "nl:"
       FROM cnt_rrf_ar_r c
       WHERE c.rrf_uid=r_uid
       WITH check
      ;end select
      IF (curqual < 1)
       FOR (dta_ar = 1 TO size(request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[
        dta_rrf].reference_range_factor.alpha_response_list,5))
         SET arr_uid = ""
         SET new_ar = 1
         IF ((ar_struct->ar_guid > " "))
          SET arr_uid = ar_struct->ar_guid
         ELSE
          SET arr_uid = concat("TEMP!",ar_struct->source_string)
          SELECT INTO "nl:"
           FROM cnt_uid_alias c
           PLAN (c
            WHERE c.cnt_uid_domain="CNT_ALPHA_RESPONSE_KEY"
             AND c.cnt_uid_alias=arr_uid)
           DETAIL
            arr_uid = c.cnt_uid
           WITH check
          ;end select
         ENDIF
         SELECT INTO "nl:"
          FROM cnt_rrf_ar_r c
          PLAN (c
           WHERE c.ar_uid=arr_uid
            AND c.rrf_uid=r_uid)
          DETAIL
           new_ar = 0
          WITH nocounter
         ;end select
         IF (new_ar=1)
          SET tmp_alpha_respkey_id = 0.0
          SELECT INTO "nl:"
           FROM cnt_alpha_response_key c
           PLAN (c
            WHERE c.ar_uid=arr_uid)
           DETAIL
            tmp_alpha_respkey_id = c.cnt_alpha_response_key_id
           WITH nocounter
          ;end select
          IF (category_table_ind=1
           AND category_req_ind=1)
           SET tmp_category_id = 0.0
           SELECT INTO "nl:"
            FROM cnt_alpha_resp_category c
            PLAN (c
             WHERE c.rrf_uid=r_uid
              AND c.category_name=trim(ar_struct->category_name))
            DETAIL
             tmp_category_id = c.cnt_alpha_resp_category_id
            WITH nocounter
           ;end select
          ENDIF
          IF (truth_column_ind=1)
           INSERT  FROM cnt_rrf_ar_r c
            SET c.alpha_responses_category_id = tmp_category_id, c.ar_uid = arr_uid, c
             .cnt_alpha_response_key_id = tmp_alpha_respkey_id,
             c.cnt_rrf_ar_r_id = seq(reference_seq,nextval), c.cnt_rrf_key_id = tmp_rrf_key_id, c
             .default_ind = ar_struct->default_ind,
             c.description = ar_struct->mnemonic, c.multi_alpha_sort_order = ar_struct->
             multi_alpha_sort_order, c.reference_ind = ar_struct->reference_ind,
             c.result_process_cd = 0.0, c.result_process_cduid =
             IF ((ar_struct->result_process_cduid > " ")) trim(ar_struct->result_process_cduid)
             ELSEIF (trim(ar_struct->result_process_disp) > " ") concat("&DISPLAY&1902&",trim(
                ar_struct->result_process_disp))
             ELSE " "
             ENDIF
             , c.result_value = ar_struct->result_value,
             c.rrf_uid = r_uid, c.ar_sequence = ar_struct->sequence, c.truth_state_cd = 0.0,
             c.truth_state_cduid =
             IF ((ar_struct->truth_state_cduid > " ")) trim(ar_struct->truth_state_cduid)
             ELSEIF (trim(ar_struct->truth_state_mean) > " ") concat("&MEANING&15751&",trim(ar_struct
                ->truth_state_mean))
             ELSE " "
             ENDIF
             , c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
             c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
             c.use_units_ind = ar_struct->use_units_ind
            WITH nocounter
           ;end insert
          ELSE
           INSERT  FROM cnt_rrf_ar_r c
            SET c.alpha_responses_category_id = tmp_category_id, c.ar_uid = arr_uid, c
             .cnt_alpha_response_key_id = tmp_alpha_respkey_id,
             c.cnt_rrf_ar_r_id = seq(reference_seq,nextval), c.cnt_rrf_key_id = tmp_rrf_key_id, c
             .default_ind = ar_struct->default_ind,
             c.description = ar_struct->mnemonic, c.multi_alpha_sort_order = ar_struct->
             multi_alpha_sort_order, c.reference_ind = ar_struct->reference_ind,
             c.result_process_cd = 0.0, c.result_process_cduid =
             IF ((ar_struct->result_process_cduid > " ")) trim(ar_struct->result_process_cduid)
             ELSEIF (trim(ar_struct->result_process_disp) > " ") concat("&DISPLAY&1902&",trim(
                ar_struct->result_process_disp))
             ELSE " "
             ENDIF
             , c.result_value = ar_struct->result_value,
             c.rrf_uid = r_uid, c.ar_sequence = ar_struct->sequence, c.updt_applctx = reqinfo->
             updt_applctx,
             c.updt_cnt = 0, c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id,
             c.updt_task = reqinfo->updt_task, c.use_units_ind = ar_struct->use_units_ind
            WITH nocounter
           ;end insert
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF (advanced_table_ind=1
       AND advanced_req_ind=1)
       IF (dta_replace=1)
        DELETE  FROM cnt_advanced_delta cad
         WHERE cad.rrf_uid=r_uid
         WITH check
        ;end delete
       ENDIF
       SELECT INTO "nl:"
        FROM cnt_advanced_delta cad
        WHERE cad.rrf_uid=r_uid
        WITH check
       ;end select
       IF (curqual < 1)
        FOR (dta_ad = 1 TO size(request->dta_obj_list[dta_a].dta_obj.reference_range_factor_list[
         dta_rrf].reference_range_factor.advanced_delta_list,5))
          INSERT  FROM cnt_advanced_delta cad
           SET cad.cnt_advanced_delta_id = seq(reference_seq,nextval), cad.active_ind = 1, cad
            .active_status_cd = active_cd,
            cad.active_status_dt_tm = cnvtdatetime(sysdate), cad.active_status_prsnl_id = reqinfo->
            updt_id, cad.beg_effective_dt_tm = cnvtdatetime(sysdate),
            cad.delta_check_type_cd = 0.00, cad.delta_check_type_cduid =
            IF ((advanced_struct->delta_check_type_cduid > " ")) trim(advanced_struct->
              delta_check_type_cduid)
            ELSEIF (trim(advanced_struct->delta_check_type_disp) > " ") concat("&DISPLAY&1902&",trim(
               advanced_struct->delta_check_type_disp))
            ELSE " "
            ENDIF
            , cad.delta_high = advanced_struct->delta_high,
            cad.delta_flag = advanced_struct->delta_ind, cad.delta_low = advanced_struct->delta_low,
            cad.delta_minutes = advanced_struct->delta_minutes,
            cad.delta_value = advanced_struct->delta_value, cad.end_effective_dt_tm = cnvtdatetime(
             "31-DEC-2100"), cad.rrf_uid = r_uid,
            cad.updt_applctx = reqinfo->updt_applctx, cad.updt_cnt = 0, cad.updt_dt_tm = sysdate,
            cad.updt_id = reqinfo->updt_id, cad.updt_task = reqinfo->updt_task
          ;end insert
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 UPDATE  FROM cnt_dta c
  SET c.activity_type_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.activity_type_cduid), c.activity_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.activity_type_cduid)
  WHERE c.activity_type_cduid="&*"
   AND c.activity_type_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.activity_type_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.activity_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.activity_type_cduid)
  WHERE c.activity_type_cd=0.0
   AND c.activity_type_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.activity_type_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.default_result_type_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.default_result_type_cduid), c.default_result_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.default_result_type_cduid)
  WHERE c.default_result_type_cduid="&*"
   AND c.default_result_type_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.default_result_type_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.default_result_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.default_result_type_cduid)
  WHERE c.default_result_type_cd=0.0
   AND c.default_result_type_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.default_result_type_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.event_code_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.event_code_cduid), c.event_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.event_code_cduid)
  WHERE c.event_code_cduid="&*"
   AND c.event_code_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.event_code_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.event_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.event_code_cduid)
  WHERE c.event_cd=0.0
   AND c.event_code_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.event_code_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_data_map c
  SET c.service_resource_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.service_resource_cduid), c.service_resource_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.service_resource_cduid)
  WHERE c.service_resource_cduid="&*"
   AND c.service_resource_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.service_resource_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_data_map c
  SET c.service_resource_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.service_resource_cduid)
  WHERE c.service_resource_cd=0.0
   AND c.service_resource_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.service_resource_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_ar_r c
  SET c.result_process_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.result_process_cduid), c.result_process_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.result_process_cduid)
  WHERE c.result_process_cduid="&*"
   AND c.result_process_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.result_process_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_ar_r c
  SET c.result_process_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.result_process_cduid)
  WHERE c.result_process_cd=0.0
   AND c.result_process_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.result_process_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf c
  SET c.encntr_type_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.encntr_type_cduid), c.encntr_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.encntr_type_cduid)
  WHERE c.encntr_type_cduid="&*"
   AND c.encntr_type_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.encntr_type_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf c
  SET c.encntr_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.encntr_type_cduid)
  WHERE c.encntr_type_cd=0.0
   AND c.encntr_type_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.encntr_type_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf c
  SET c.units_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.units_cduid), c.units_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.units_cduid)
  WHERE c.units_cduid="&*"
   AND c.units_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.units_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf c
  SET c.units_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.units_cduid)
  WHERE c.units_cd=0.0
   AND c.units_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.units_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.age_from_units_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.age_from_units_cduid), c.age_from_units_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.age_from_units_cduid)
  WHERE c.age_from_units_cduid="&*"
   AND c.age_from_units_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.age_from_units_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.age_from_units_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.age_from_units_cduid)
  WHERE c.age_from_units_cd=0.0
   AND c.age_from_units_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.age_from_units_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.age_to_units_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.age_to_units_cduid), c.age_to_units_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.age_to_units_cduid)
  WHERE c.age_to_units_cduid="&*"
   AND c.age_to_units_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.age_to_units_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.age_to_units_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.age_to_units_cduid)
  WHERE c.age_to_units_cd=0.0
   AND c.age_to_units_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.age_to_units_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.service_resource_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.service_resource_cduid), c.service_resource_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.service_resource_cduid)
  WHERE c.service_resource_cduid="&*"
   AND c.service_resource_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.service_resource_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.service_resource_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.service_resource_cduid)
  WHERE c.service_resource_cd=0.0
   AND c.service_resource_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.service_resource_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.sex_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.sex_cduid), c.sex_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.sex_cduid)
  WHERE c.sex_cduid="&*"
   AND c.sex_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.sex_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.sex_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.sex_cduid)
  WHERE c.sex_cd=0.0
   AND c.sex_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.sex_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.species_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.species_cduid), c.species_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.species_cduid)
  WHERE c.species_cduid="&*"
   AND c.species_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.species_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.species_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.species_cduid)
  WHERE c.species_cd=0.0
   AND c.species_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.species_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.specimen_type_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.specimen_type_cduid), c.specimen_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.specimen_type_cduid)
  WHERE c.specimen_type_cduid="&*"
   AND c.specimen_type_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.specimen_type_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_rrf_key c
  SET c.specimen_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.specimen_type_cduid)
  WHERE c.specimen_type_cd=0.0
   AND c.specimen_type_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.specimen_type_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.bb_result_type_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.bb_result_type_cduid), c.bb_result_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.bb_result_type_cduid)
  WHERE c.bb_result_type_cduid="&*"
   AND c.bb_result_type_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.bb_result_type_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_dta c
  SET c.bb_result_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.bb_result_type_cduid)
  WHERE c.bb_result_type_cd=0.0
   AND c.bb_result_type_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.bb_result_type_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 IF (rad_column_ind=1)
  UPDATE  FROM cnt_dta c
   SET c.rad_sect_type_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.rad_sect_type_cduid), c.rad_section_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.rad_sect_type_cduid)
   WHERE c.rad_sect_type_cduid="&*"
    AND c.rad_sect_type_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.rad_sect_type_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_dta c
   SET c.rad_section_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.rad_sect_type_cduid)
   WHERE c.rad_section_type_cd=0.0
    AND c.rad_sect_type_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.rad_sect_type_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 IF (advanced_table_ind=1)
  UPDATE  FROM cnt_advanced_delta c
   SET c.delta_check_type_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.delta_check_type_cduid), c.delta_check_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.delta_check_type_cduid)
   WHERE c.delta_check_type_cduid="&*"
    AND c.delta_check_type_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.delta_check_type_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_advanced_delta c
   SET c.delta_check_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.delta_check_type_cduid)
   WHERE c.delta_check_type_cd=0.0
    AND c.delta_check_type_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.delta_check_type_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 IF (relassay_table_ind=1)
  UPDATE  FROM cnt_related_assay c
   SET c.related_proc_type_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.related_proc_type_cduid), c.related_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.related_proc_type_cduid)
   WHERE c.related_proc_type_cduid="&*"
    AND c.related_proc_type_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.related_proc_type_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_related_assay c
   SET c.related_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.related_proc_type_cduid)
   WHERE c.related_type_cd=0.0
    AND c.related_proc_type_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.related_proc_type_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 IF (dtaoffset_table_ind=1)
  UPDATE  FROM cnt_dta_offset_min c
   SET c.offset_min_type_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.offset_min_type_cduid), c.offset_min_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.offset_min_type_cduid)
   WHERE c.offset_min_type_cduid="&*"
    AND c.offset_min_type_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.offset_min_type_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_dta_offset_min c
   SET c.offset_min_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.offset_min_type_cduid)
   WHERE c.offset_min_type_cd=0.0
    AND c.offset_min_type_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.offset_min_type_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 IF (truth_column_ind=1)
  UPDATE  FROM cnt_rrf_ar_r c
   SET c.truth_state_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.truth_state_cduid), c.truth_state_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.truth_state_cduid)
   WHERE c.truth_state_cduid="&*"
    AND c.truth_state_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.truth_state_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_rrf_ar_r c
   SET c.truth_state_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.truth_state_cduid)
   WHERE c.truth_state_cd=0.0
    AND c.truth_state_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.truth_state_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 SUBROUTINE (cnt_imp_dta_log(lf_name=vc,txt=vc,app_ind=i2) =i2)
   IF (app_ind=true)
    SELECT INTO value(lf_name)
     FROM dual
     DETAIL
      col 0, txt, row + 1
     WITH append
    ;end select
   ELSE
    SELECT INTO value(lf_name)
     FROM dual
     DETAIL
      col 0, txt, row + 1
     WITH check
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (convert_age_to_minutes(age_value=i4,age_unit_disp=vc) =i4)
   SET minutes = 0
   CASE (trim(cnvtupper(cnvtalphanum(age_unit_disp))))
    OF "YEARS":
     SET minutes = (min_per_year * age_value)
    OF "MONTHS":
     SET minutes = (min_per_month * age_value)
    OF "WEEKS":
     SET minutes = (min_per_week * age_value)
    OF "DAYS":
     SET minutes = (min_per_day * age_value)
    OF "HOURS":
     SET minutes = (min_per_hour * age_value)
    OF "MINUTES":
     SET minutes = (min_per_minute * age_value)
    OF "SECONDS":
     SET minutes = (min_per_second * age_value)
   ENDCASE
   RETURN(minutes)
 END ;Subroutine
#end_of_script
 COMMIT
 CALL parser("dm2_set_context 'FIRE_REFCHG_TRG','YES' go")
 SET script_vers = "07/11/16"
 CALL echo("Script was last modified on: 07/11/16 by SK023113")
END GO
