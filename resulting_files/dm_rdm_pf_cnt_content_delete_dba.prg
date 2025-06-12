CREATE PROGRAM dm_rdm_pf_cnt_content_delete:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rdm_pf_cnt_content_delete..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE internal_domain_ind = i2 WITH protect, noconstant(0)
 DECLARE table_found = i2 WITH protect, noconstant(0)
 DECLARE table_name = vc WITH protect, noconstant("")
 DECLARE check_for_error(table_name=vc) = null
 SELECT INTO "NL:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="KNOWLEDGE INDEX APPLICATIONS"
    AND d.info_name="KIA_CMT_DOMAIN")
  DETAIL
   internal_domain_ind = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to query DM_INFO table:",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM user_tab_columns utc
  WHERE utc.table_name="cnt_dcp_interp2"
  HEAD REPORT
   table_found = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed to select data from user_tab_columns:",errmsg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 IF (internal_domain_ind != 1)
  DELETE  FROM cnt_dcp_interp_state c
   WHERE c.cnt_dcp_interp_state_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_dcp_interp_state"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_dcp_interp_component c
   WHERE c.cnt_dcp_interp_component_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_dcp_interp_component"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_dcp_interp c
   WHERE c.cnt_dcp_interp_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_dcp_interp"
  CALL check_for_error(table_name)
  IF (table_found=1)
   DELETE  FROM cnt_dcp_interp2 c
    WHERE c.cnt_dcp_interp2_id != 0.00
    WITH nocounter
   ;end delete
   SET table_name = "cnt_dcp_interp2"
   CALL check_for_error(table_name)
  ELSE
   SET readme_data->message = " Table cnt_dcp_interp2 not found"
  ENDIF
  DELETE  FROM cnt_equation_component c
   WHERE c.cnt_equation_component_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_equation_component"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_equation c
   WHERE c.cnt_equation_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_equation"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_data_map c
   WHERE c.cnt_data_map_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_data_map"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_ref_text c
   WHERE c.cnt_ref_text_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_ref_text"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_dta_rrf_r c
   WHERE c.cnt_dta_rrf_r_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_dta_rrf_r"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_rrf_ar_r c
   WHERE c.cnt_rrf_ar_r_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_rrf_ar_r"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_rrf c
   WHERE c.cnt_rrf_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_rrf"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_rrf_key c
   WHERE c.cnt_rrf_key_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_rrf_key"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_section_dta_r c
   WHERE c.cnt_section_dta_r_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_section_dta_r"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_dta c
   WHERE c.cnt_dta_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_dta"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_dta_key2 c
   WHERE c.cnt_dta_key_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_dta_key2"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_alpha_response c
   WHERE c.cnt_alpha_response_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_alpha_response"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_alpha_response_key c
   WHERE c.cnt_alpha_response_key_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_alpha_response_key"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_grid c
   WHERE c.cnt_grid_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_grid"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_input c
   WHERE c.cnt_input_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_input"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_input_key c
   WHERE c.cnt_input_key_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_input_key"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_pf_section_r c
   WHERE c.cnt_pf_section_r_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_pf_section_r"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_section c
   WHERE c.cnt_section_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_section"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_section_key2 c
   WHERE c.cnt_section_key2_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_section_key2"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_powerform c
   WHERE c.cnt_powerform_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_powerform"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_pf_key2 c
   WHERE c.cnt_pf_key_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_pf_key2"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_code_value_key c
   WHERE c.cnt_code_value_key_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_code_value_key"
  CALL check_for_error(table_name)
  DELETE  FROM cnt_data_version c
   WHERE c.cnt_data_version_id != 0.00
   WITH nocounter
  ;end delete
  SET table_name = "cnt_data_version"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_equation_component c
   SET c.included_assay_cd = 0.00, c.result_status_cd = 0.00, c.units_cd = 0.00
   WHERE c.cnt_equation_component_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_equation_component"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_equation c
   SET c.age_from_units_cd = 0.00, c.age_to_units_cd = 0.00, c.task_assay_cd = 0.00,
    c.service_resource_cd = 0.00, c.sex_cd = 0.00, c.species_cd = 0.00
   WHERE c.cnt_equation_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_equation"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_data_map c
   SET c.service_resource_cd = 0.00
   WHERE c.cnt_data_map_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_data_map"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_ref_text c
   SET c.text_type_cd = 0.00
   WHERE c.cnt_ref_text_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_ref_text"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_rrf_ar_r c
   SET c.result_process_cd = 0.00, c.truth_state_cd = 0.00
   WHERE c.cnt_rrf_ar_r_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_rrf_ar_r"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_rrf c
   SET c.delta_check_type_cd = 0.00, c.encntr_type_cd = 0.00, c.units_cd = 0.00
   WHERE c.cnt_rrf_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_rrf"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_rrf_key c
   SET c.age_from_units_cd = 0.00, c.age_to_units_cd = 0.00, c.organism_cd = 0.00,
    c.patient_condition_cd = 0.00, c.service_resource_cd = 0.00, c.sex_cd = 0.00,
    c.species_cd = 0.00, c.specimen_type_cd = 0.00
   WHERE c.cnt_rrf_key_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_rrf_key"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_dta c
   SET c.activity_type_cd = 0.00, c.bb_result_type_cd = 0.00, c.default_result_type_cd = 0.00,
    c.event_cd = 0.00, c.history_activity_type_cd = 0.00, c.rad_section_type_cd = 0.00
   WHERE c.cnt_dta_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_dta"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_dta_key2 c
   SET c.task_assay_cd = 0.00
   WHERE c.cnt_dta_key_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_dta_key2"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_alpha_response c
   SET c.concept_source_cd = 0.00, c.contributor_system_cd = 0.00, c.data_status_cd = 0.00,
    c.language_cd = 0.00, c.string_source_cd = 0.00, c.string_status_cd = 0.00,
    c.term_source_cd = 0.00, c.vocab_axis_cd = 0.00
   WHERE c.cnt_alpha_response_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_alpha_response"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_alpha_response_key c
   SET c.principle_type_cd = 0.00, c.source_vocabulary_cd = 0.00
   WHERE c.cnt_alpha_response_key_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_alpha_response_key"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_grid c
   SET c.int_event_cd = 0.00
   WHERE c.cnt_grid_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_grid"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_input c
   SET c.event_cd = 0.00
   WHERE c.cnt_input_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_input"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_powerform c
   SET c.form_event_cd = 0.00, c.text_rendition_event_cd = 0.00
   WHERE c.cnt_powerform_id=0.00
   WITH nocounter
  ;end update
  SET table_name = "cnt_powerform"
  CALL check_for_error(table_name)
  UPDATE  FROM cnt_code_value_key c
   SET c.code_value = 0.00
   WHERE cnt_code_value_key_id=0.00
  ;end update
  SET table_name = "cnt_code_value_key"
  CALL check_for_error(table_name)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "This is a CMTDEV domain. Hence, did not perform any action"
  GO TO exit_script
 ENDIF
 SUBROUTINE check_for_error(table_name)
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = build("Failed to delete/update from table: ",cnvtupper(table_name),
     ", error message: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
