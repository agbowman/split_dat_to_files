CREATE PROGRAM cnt_imp_interp:dba
 CALL parser("dm2_set_context 'FIRE_REFCHG_TRG','NO' go")
 CALL parser(
  "rdb alter table cnt_dcp_interp_component disable constraint XFK1CNT_DCP_INTERP_COMPONENT go")
 CALL parser("rdb alter table cnt_dcp_interp_state disable constraint XFK1CNT_DCP_INTERP_STATE go")
 CALL parser("rdb alter table cnt_dcp_interp_state disable constraint XFK4CNT_DCP_INTERP_STATE go")
 SET curalias interp_struct request->interp_obj_list[interp_a].interp_obj
 SET curalias icomponent_struct request->interp_obj_list[interp_a].interp_obj.component_list[comp_a].
 component
 SET curalias istate_struct request->interp_obj_list[interp_a].interp_obj.state_list[state_a].state
 DECLARE ta_uid = vc WITH noconstant("")
 DECLARE interp_a = i4 WITH noconstant(0)
 DECLARE state_a = i4 WITH noconstant(0)
 DECLARE comp_a = i4 WITH noconstant(0)
 DECLARE r_nom_id = f8 WITH noconstant(0.0)
 DECLARE nom_id = f8 WITH noconstant(0.0)
 DECLARE ark_uid = vc WITH noconstant("")
 DECLARE r_ark_uid = vc WITH noconstant("")
 DECLARE n_sv_uid = vc WITH noconstant("")
 DECLARE n_pt_uid = vc WITH noconstant("")
 DECLARE tmp_dcp_interp_id = f8 WITH noconstant(0.0)
 DECLARE tmp_dta_key_id = f8 WITH noconstant(0.0)
 DECLARE tmp_alpha_resp_key_id = f8 WITH noconstant(0.0)
 DECLARE overwrite_interp = i2 WITH noconstant(0)
 SELECT INTO "cnt_imp_interp.log"
  FROM dual
  DETAIL
   col 0, "CNT INTERP Import", row + 1
  WITH check
 ;end select
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
 FREE RECORD tmp_dta
 RECORD tmp_dta(
   1 qual[*]
     2 dta_uid = vc
 )
 DECLARE di_uid = vc WITH noconstant("")
 DECLARE ca_uid = vc WITH noconstant("")
 DECLARE ia_uid = vc WITH noconstant("")
 DECLARE rar_uid = vc WITH noconstant("")
 DECLARE compare_dt_tm = dq8
 DECLARE interp_replace = i2 WITH noconstant(0)
 DECLARE new_interp = i2 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 IF (validate(request->interp_obj_list[1].interp_obj.exported_dt_tm,0) != 0)
  SET compare_dt_tm = request->interp_obj_list[1].interp_obj.exported_dt_tm
 ELSE
  SET compare_dt_tm = sysdate
 ENDIF
 UPDATE  FROM cnt_uid_alias c
  SET c.cnt_uid =
   (SELECT
    d.task_assay_uid
    FROM cnt_dta_key2 d
    WHERE concat("TEMP!",d.task_assay_disp)=c.cnt_uid_alias), c.updt_task = 2501
  PLAN (c
   WHERE c.cnt_uid_domain="CNT_DTA_KEY2"
    AND  EXISTS (
   (SELECT
    d.task_assay_uid
    FROM cnt_dta_key2 d
    WHERE concat("TEMP!",d.task_assay_disp)=c.cnt_uid_alias)))
  WITH check
 ;end update
 SELECT INTO "cnt_imp_interp.log"
  FROM dual
  DETAIL
   t_size = size(request->interp_obj_list,5), col 0, "NBR of INTERPS:",
   col 25, t_size, row + 1
  WITH append
 ;end select
 FOR (interp_a = 1 TO size(request->interp_obj_list,5))
   SET ta_uid = ""
   SET interp_replace = 0
   SET tmp_dcp_interp_id = 0.0
   IF ((interp_struct->task_assay_uid > " "))
    SET ta_uid = interp_struct->task_assay_uid
    SET ta_uid = replace(ta_uid,"UNKNOWN!","CERNER!",1)
   ELSEIF ((interp_struct->dta_mnemonic > " "))
    SET ta_uid = concat("TEMP!",interp_struct->dta_mnemonic)
    SET ta_uid = cnt_dta_chk_uid(ta_uid)
   ENDIF
   SET di_uid = ""
   IF ((interp_struct->dcp_interp_uid > " "))
    SET di_uid = interp_struct->dcp_interp_uid
   ELSE
    SET di_uid = concat(ta_uid,"!",trim(interp_struct->service_resource_cduid),"!",trim(interp_struct
      ->sex_code_cduid),
     "!")
    SET di_uid = concat(di_uid,trim(cnvtstring(interp_struct->age_from_minutes)),"!")
    SET di_uid = concat(di_uid,trim(cnvtstring(interp_struct->age_to_minutes)))
    SET di_uid = substring(1,100,di_uid)
   ENDIF
   SELECT INTO "nl:"
    FROM cnt_dta_key2 c
    PLAN (c
     WHERE c.task_assay_uid=ta_uid)
    DETAIL
     IF (cnvtdatetime(compare_dt_tm) >= cnvtdatetime(c.version_dt_tm))
      interp_replace = 1
     ENDIF
    WITH check
   ;end select
   SET pos = 0
   IF (interp_a >= size(tmp_dta->qual,5))
    SET stat = alterlist(tmp_dta->qual,(interp_a+ 5))
   ENDIF
   SET pos = locateval(num,1,size(tmp_dta->qual,5),ta_uid,tmp_dta->qual[num].dta_uid)
   IF (pos=0
    AND interp_replace=1)
    SET overwrite_interp = 1
    SELECT INTO "nl:"
     FROM cnt_dcp_interp2 c,
      cnt_dta_key2 cd
     PLAN (cd
      WHERE cd.task_assay_uid=ta_uid)
      JOIN (c
      WHERE c.task_assay_uid=cd.task_assay_uid
       AND c.updt_dt_tm >= cd.updt_dt_tm)
     DETAIL
      overwrite_interp = 0
     WITH check
    ;end select
    IF (overwrite_interp=1)
     DELETE  FROM cnt_dcp_interp_state c
      WHERE c.dcp_interp_uid IN (
      (SELECT
       c1.dcp_interp_uid
       FROM cnt_dcp_interp2 c1
       WHERE ((c1.task_assay_uid=ta_uid) OR (c1.dcp_interp_uid=di_uid)) ))
      WITH check
     ;end delete
     DELETE  FROM cnt_dcp_interp_component c
      WHERE c.dcp_interp_uid IN (
      (SELECT
       c1.dcp_interp_uid
       FROM cnt_dcp_interp2 c1
       WHERE ((c1.task_assay_uid=ta_uid) OR (c1.dcp_interp_uid=di_uid)) ))
      WITH check
     ;end delete
     DELETE  FROM cnt_dcp_interp2 c
      WHERE ((c.task_assay_uid=ta_uid) OR (c.dcp_interp_uid=di_uid))
      WITH check
     ;end delete
    ENDIF
   ENDIF
   SET tmp_dta->qual[interp_a].dta_uid = ta_uid
   IF (interp_replace=1)
    SET tmp_dta_key_id = 0.0
    SELECT INTO "nl:"
     FROM cnt_dta_key2 c
     PLAN (c
      WHERE c.task_assay_uid=ta_uid)
     DETAIL
      tmp_dta_key_id = c.cnt_dta_key_id
     WITH check
    ;end select
    SET new_interp = 1
    SELECT INTO "nl:"
     FROM cnt_dcp_interp2 c
     PLAN (c
      WHERE c.dcp_interp_uid=di_uid)
     DETAIL
      new_interp = 0, tmp_dcp_interp_id = c.cnt_dcp_interp2_id
     WITH check
    ;end select
    IF (new_interp=0)
     UPDATE  FROM cnt_dcp_interp2 c
      SET c.age_from_minutes = interp_struct->age_from_minutes, c.age_to_minutes = interp_struct->
       age_to_minutes, c.cnt_dta_key_id = tmp_dta_key_id,
       c.service_resource_cd = 0.0, c.service_resource_cduid =
       IF ((interp_struct->service_resource_cduid > " ")) trim(interp_struct->service_resource_cduid)
       ELSEIF (trim(interp_struct->service_resource) > " ") concat("&DISPLAY&221&",trim(interp_struct
          ->service_resource))
       ELSE " "
       ENDIF
       , c.sex_cd = 0.0,
       c.sex_cduid =
       IF ((interp_struct->sex_code_cduid > " ")) trim(interp_struct->sex_code_cduid)
       ELSEIF (trim(interp_struct->sex_disp) > " ") concat("&DISPLAY_KEY&57&",trim(cnvtalphanum(
           cnvtupper(interp_struct->sex_disp))))
       ELSE " "
       ENDIF
       , c.task_assay_uid = ta_uid, c.updt_applctx = reqinfo->updt_applctx,
       c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->
       updt_id,
       c.updt_task = reqinfo->updt_task
      WHERE c.dcp_interp_uid=di_uid
      WITH check
     ;end update
    ELSE
     SET tmp_dcp_interp_id = 0.0
     SELECT INTO "nl:"
      tmp_id = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       tmp_dcp_interp_id = tmp_id
      WITH format, counter
     ;end select
     INSERT  FROM cnt_dcp_interp2 c
      SET c.age_from_minutes = interp_struct->age_from_minutes, c.age_to_minutes = interp_struct->
       age_to_minutes, c.cnt_dcp_interp2_id = tmp_dcp_interp_id,
       c.cnt_dta_key_id = tmp_dta_key_id, c.dcp_interp_uid = di_uid, c.service_resource_cd = 0.0,
       c.service_resource_cduid =
       IF ((interp_struct->service_resource_cduid > " ")) trim(interp_struct->service_resource_cduid)
       ELSEIF (trim(interp_struct->service_resource) > " ") concat("&DISPLAY&221&",trim(interp_struct
          ->service_resource))
       ELSE " "
       ENDIF
       , c.sex_cd = 0.0, c.sex_cduid =
       IF ((interp_struct->sex_code_cduid > " ")) trim(interp_struct->sex_code_cduid)
       ELSEIF (trim(interp_struct->sex_disp) > " ") concat("&DISPLAY_KEY&57&",trim(cnvtalphanum(
           cnvtupper(interp_struct->sex_disp))))
       ELSE " "
       ENDIF
       ,
       c.task_assay_uid = ta_uid, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
       updt_task
      WITH check
     ;end insert
    ENDIF
    SELECT INTO "cnt_imp_interp.log"
     FROM dual
     DETAIL
      col 0, "Interp Item:", col 25,
      interp_a, row + 1, col 0,
      "di_uid:", col 10, di_uid,
      row + 1, t_size = size(request->interp_obj_list[interp_a].interp_obj.component_list,5), col 0,
      "NBR of COMPS:", col 25, t_size,
      row + 1
     WITH append
    ;end select
    IF (size(request->interp_obj_list[interp_a].interp_obj.component_list,5) > 0)
     FOR (comp_a = 1 TO size(request->interp_obj_list[interp_a].interp_obj.component_list,5))
       SET ca_uid = ""
       IF ((icomponent_struct->component_task_assay_uid > " "))
        SET ca_uid = icomponent_struct->component_task_assay_uid
        SET ca_uid = replace(ca_uid,"UNKNOWN!","CERNER!",1)
       ELSEIF ((icomponent_struct->dta_mnemonic > " "))
        SET ca_uid = concat("TEMP!",icomponent_struct->dta_mnemonic)
        SET ca_uid = cnt_dta_chk_uid(ca_uid)
       ENDIF
       SELECT INTO "nl:"
        FROM cnt_dcp_interp_component c
        PLAN (c
         WHERE c.dcp_interp_uid=di_uid
          AND (c.component_sequence=icomponent_struct->component_seq))
        WITH check
       ;end select
       IF (curqual < 1)
        INSERT  FROM cnt_dcp_interp_component c
         SET c.cnt_dcp_interp_component_id = seq(reference_seq,nextval), c.cnt_dcp_interp_id =
          tmp_dcp_interp_id, c.component_assay_uid = ca_uid,
          c.component_sequence = icomponent_struct->component_seq, c.dcp_interp_uid = di_uid, c
          .description = icomponent_struct->description,
          c.flags = icomponent_struct->flags, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
          c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
         WITH check
        ;end insert
       ENDIF
     ENDFOR
    ENDIF
    SELECT INTO "cnt_imp_interp.log"
     FROM dual
     DETAIL
      col 0, "Interp Item:", col 25,
      interp_a, row + 1, t_size = size(request->interp_obj_list[interp_a].interp_obj.state_list,5),
      col 0, "NBR of STATES:", col 25,
      t_size, row + 1
     WITH append
    ;end select
    IF (size(request->interp_obj_list[interp_a].interp_obj.state_list,5) > 0)
     FOR (state_a = 1 TO size(request->interp_obj_list[interp_a].interp_obj.state_list,5))
       SET ia_uid = ""
       IF ((istate_struct->input_task_assay_uid > " "))
        SET ia_uid = istate_struct->input_task_assay_uid
        SET ia_uid = replace(ia_uid,"UNKNOWN!","CERNER!",1)
       ELSEIF ((istate_struct->input_dta_mnemonic > " "))
        SET ia_uid = concat("TEMP!",istate_struct->input_dta_mnemonic)
        SET ia_uid = cnt_dta_chk_uid(ia_uid)
       ENDIF
       SET r_nom_id = 0.0
       SET nom_id = 0.0
       SET n_pt_uid = ""
       SET n_sv_uid = ""
       SET ark_uid = ""
       SET r_ark_uid = ""
       IF ((istate_struct->principle_type_cduid > ""))
        SET n_pt_uid = istate_struct->principle_type_cduid
       ELSE
        SET n_pt_uid = concat("&MEAN&401&",trim(istate_struct->principle_type_mean))
        SELECT INTO "nl:"
         FROM cnt_code_value_key c
         PLAN (c
          WHERE c.code_value_uid_alias=n_pt_uid)
         DETAIL
          n_pt_uid = c.code_value_uid
         WITH check
        ;end select
       ENDIF
       IF ((istate_struct->source_vocab_cduid > ""))
        SET n_sv_uid = istate_struct->source_vocab_cduid
       ELSE
        SET n_sv_uid = concat("&MEAN&400&",trim(istate_struct->source_vocabulary_mean))
        SELECT INTO "nl:"
         FROM cnt_code_value_key c
         PLAN (c
          WHERE c.code_value_uid_alias=n_sv_uid)
         DETAIL
          n_sv_uid = c.code_value_uid
         WITH check
        ;end select
       ENDIF
       SELECT INTO "nl:"
        FROM cnt_alpha_response_key c
        PLAN (c
         WHERE c.principle_type_cduid=n_pt_uid
          AND (c.source_identifier=istate_struct->source_identifier)
          AND c.source_vocabulary_cduid=n_sv_uid
          AND (c.source_string=istate_struct->source_string))
        DETAIL
         nom_id = c.nomenclature_id, ark_uid = c.ar_uid
        WITH check
       ;end select
       SET n_pt_uid = ""
       SET n_sv_uid = ""
       IF ((istate_struct->result_principle_type_cduid > ""))
        SET n_pt_uid = istate_struct->result_principle_type_cduid
       ELSE
        SET n_pt_uid = concat("&MEAN&401&",trim(istate_struct->result_principle_type_mean))
        SELECT INTO "nl:"
         FROM cnt_code_value_key c
         PLAN (c
          WHERE c.code_value_uid_alias=n_pt_uid)
         DETAIL
          n_pt_uid = c.code_value_uid
         WITH check
        ;end select
       ENDIF
       IF ((istate_struct->result_source_vocab_cduid > ""))
        SET n_sv_uid = istate_struct->result_source_vocab_cduid
       ELSE
        SET n_sv_uid = concat("&MEAN&400&",trim(istate_struct->result_source_vocab_mean))
        SELECT INTO "nl:"
         FROM cnt_code_value_key c
         PLAN (c
          WHERE c.code_value_uid_alias=n_sv_uid)
         DETAIL
          n_sv_uid = c.code_value_uid
         WITH check
        ;end select
       ENDIF
       SELECT INTO "nl:"
        FROM cnt_alpha_response_key c
        PLAN (c
         WHERE c.principle_type_cduid=n_pt_uid
          AND (c.source_identifier=istate_struct->result_source_identifier)
          AND c.source_vocabulary_cduid=n_sv_uid
          AND (c.source_string=istate_struct->result_source_string))
        DETAIL
         r_nom_id = c.nomenclature_id, r_ark_uid = c.ar_uid
        WITH check
       ;end select
       SET tmp_alpha_resp_key_id = 0.0
       SELECT INTO "nl:"
        FROM cnt_alpha_response_key c
        PLAN (c
         WHERE c.ar_uid=ark_uid)
        DETAIL
         tmp_alpha_resp_key_id = c.cnt_alpha_response_key_id
        WITH check
       ;end select
       SELECT INTO "nl:"
        FROM cnt_dcp_interp_state c
        WHERE c.dcp_interp_uid=di_uid
         AND (c.resulting_state=istate_struct->resulting_state)
        WITH check
       ;end select
       IF (curqual < 1)
        INSERT  FROM cnt_dcp_interp_state c
         SET c.ar_uid = ark_uid, c.cnt_alpha_response_key_id = tmp_alpha_resp_key_id, c
          .cnt_dcp_interp_id = tmp_dcp_interp_id,
          c.cnt_dcp_interp_state_id = seq(reference_seq,nextval), c.dcp_interp_uid = di_uid, c.flags
           = istate_struct->flags,
          c.input_assay_uid = ia_uid, c.interp_state = istate_struct->state, c.nomenclature_id =
          nom_id,
          c.numeric_high = istate_struct->numeric_high, c.numeric_low = istate_struct->numeric_low, c
          .resulting_state = istate_struct->resulting_state,
          c.result_ar_uid = r_ark_uid, c.result_nomenclature_id = r_nom_id, c.result_value =
          istate_struct->result_value,
          c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = sysdate,
          c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
         WITH check
        ;end insert
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#end_of_script
 UPDATE  FROM cnt_dcp_interp2 c
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
 UPDATE  FROM cnt_dcp_interp2 c
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
 UPDATE  FROM cnt_dcp_interp2 c
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
 UPDATE  FROM cnt_dcp_interp2 c
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
 COMMIT
 CALL parser("dm2_set_context 'FIRE_REFCHG_TRG','YES' go")
END GO
