CREATE PROGRAM acm_procedure_update:dba
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(add_procedure_request,0)))
  RECORD add_procedure_request(
    1 qual[*]
      2 procedure_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 contributor_system_cd = f8
      2 encntr_id = f8
      2 nomenclature_id = f8
      2 proc_dt_tm = dq8
      2 proc_priority = i4
      2 proc_func_type_cd = f8
      2 proc_minutes = i4
      2 consent_cd = f8
      2 diag_nomenclature_id = f8
      2 reference_nbr = vc
      2 seg_unique_key = vc
      2 mod_nomenclature_id = f8
      2 anesthesia_cd = f8
      2 anesthesia_minutes = i4
      2 tissue_type_cd = f8
      2 svc_cat_hist_id = f8
      2 proc_loc_cd = f8
      2 proc_loc_ft_ind = i2
      2 proc_ft_loc = vc
      2 proc_ft_dt_tm_ind = i2
      2 proc_ft_time_frame = c40
      2 comment_ind = i2
      2 long_text_id = f8
      2 proc_ftdesc = vc
      2 procedure_note = vc
      2 generic_val_cd = f8
      2 ranking_cd = f8
      2 clinical_service_cd = f8
      2 dgvp_ind = i2
      2 encntr_slice_id = f8
      2 proc_dt_tm_prec_flag = i2
      2 proc_type_flag = i2
      2 suppress_narrative_ind = i2
      2 proc_dt_tm_prec_cd = f8
      2 laterality_cd = f8
      2 proc_start_dt_tm = dq8
      2 proc_end_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(add_procedure_reply,0)))
  RECORD add_procedure_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 procedure_id = f8
      2 status = i4
      2 update_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(add_proc_prsnl_rel_request,0)))
  RECORD add_proc_prsnl_rel_request(
    1 qual[*]
      2 proc_prsnl_reltn_id = f8
      2 prsnl_person_id = f8
      2 proc_prsnl_reltn_cd = f8
      2 procedure_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 contributor_system_cd = f8
      2 free_text_cd = f8
      2 ft_prsnl_name = i4
      2 proc_prsnl_ft_ind = i2
      2 proc_ft_prsnl = vc
  )
 ENDIF
 IF ( NOT (validate(add_proc_prsnl_rel_reply,0)))
  RECORD add_proc_prsnl_rel_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 proc_prsnl_reltn_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(add_proc_modifier_request,0)))
  RECORD add_proc_modifier_request(
    1 qual[*]
      2 proc_modifier_id = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 nomenclature_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 contributor_system_cd = f8
      2 group_seq = i4
      2 sequence = i4
  )
 ENDIF
 IF ( NOT (validate(add_proc_modifier_reply,0)))
  RECORD add_proc_modifier_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 proc_modifier_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(add_long_text_request,0)))
  RECORD add_long_text_request(
    1 qual[*]
      2 long_text_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 long_text = vc
  )
 ENDIF
 IF ( NOT (validate(add_long_text_reply,0)))
  RECORD add_long_text_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 long_text_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(add_nomen_entity_r_request,0)))
  RECORD add_nomen_entity_r_request(
    1 qual[*]
      2 nomen_entity_reltn_id = f8
      2 nomenclature_id = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 child_entity_name = c32
      2 child_entity_id = f8
      2 reltn_type_cd = f8
      2 freetext_display = vc
      2 person_id = f8
      2 encntr_id = f8
      2 active_ind = i2
      2 activity_type_cd = f8
      2 priority = i4
      2 reltn_subtype_cd = f8
      2 order_action_sequence = i4
      2 inactive_order_action_sequence = i4
  )
 ENDIF
 IF ( NOT (validate(add_nomen_entity_r_reply,0)))
  RECORD add_nomen_entity_r_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 nomen_entity_reltn_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(ina_proc_prsnl_rel_request,0)))
  RECORD ina_proc_prsnl_rel_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 proc_prsnl_reltn_id = f8
      2 updt_cnt = i4
      2 active_status_cd = f8
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(ina_proc_prsnl_rel_reply,0)))
  RECORD ina_proc_prsnl_rel_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(ina_nomen_entity_r_request,0)))
  RECORD ina_nomen_entity_r_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 nomen_entity_reltn_id = f8
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(ina_nomen_entity_r_reply,0)))
  RECORD ina_nomen_entity_r_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(ina_proc_modifier_request,0)))
  RECORD ina_proc_modifier_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 proc_modifier_id = f8
      2 updt_cnt = i4
      2 active_status_cd = f8
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(ina_proc_modifier_reply,0)))
  RECORD ina_proc_modifier_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(chg_procedure_request,0)))
  RECORD chg_procedure_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 procedure_id = f8
      2 updt_cnt = i4
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 contributor_system_cd = f8
      2 encntr_id = f8
      2 nomenclature_id = f8
      2 proc_dt_tm = dq8
      2 proc_priority = i4
      2 proc_func_type_cd = f8
      2 proc_minutes = i4
      2 consent_cd = f8
      2 diag_nomenclature_id = f8
      2 reference_nbr = vc
      2 seg_unique_key = vc
      2 mod_nomenclature_id = f8
      2 anesthesia_cd = f8
      2 anesthesia_minutes = i4
      2 tissue_type_cd = f8
      2 svc_cat_hist_id = f8
      2 proc_loc_cd = f8
      2 proc_loc_ft_ind = i2
      2 proc_ft_loc = vc
      2 proc_ft_dt_tm_ind = i2
      2 proc_ft_time_frame = c40
      2 comment_ind = i2
      2 long_text_id = f8
      2 proc_ftdesc = vc
      2 procedure_note = vc
      2 generic_val_cd = f8
      2 ranking_cd = f8
      2 clinical_service_cd = f8
      2 dgvp_ind = i2
      2 encntr_slice_id = f8
      2 proc_dt_tm_prec_flag = i2
      2 proc_type_flag = i2
      2 suppress_narrative_ind = i2
      2 allow_partial_ind = i2
      2 version_ind = i2
      2 force_updt_ind = i2
      2 active_ind = i2
      2 proc_dt_tm_prec_cd = f8
      2 laterality_cd = f8
      2 proc_start_dt_tm = dq8
      2 proc_end_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(chg_procedure_reply,0)))
  RECORD chg_procedure_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
      2 update_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(add_procedure_acti_request,0)))
  RECORD add_procedure_acti_request(
    1 qual[*]
      2 procedure_action_id = f8
      2 procedure_id = f8
      2 prsnl_id = f8
      2 action_type_mean = c12
      2 action_dt_tm = dq8
    1 context_encntr_id = f8
  )
 ENDIF
 IF ( NOT (validate(add_procedure_acti_reply,0)))
  RECORD add_procedure_acti_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 procedure_action_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 procedures[*]
      2 procedure_id = f8
      2 update_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD modifiers_old
 RECORD modifiers_old(
   1 mods[*]
     2 proc_modifier_id = f8
     2 group_sequence = i4
     2 sequence = i4
     2 nomenclature_id = f8
 )
 FREE RECORD modifiers_new
 RECORD modifiers_new(
   1 mods[*]
     2 group_sequence = i4
     2 sequence = i4
     2 nomenclature_id = f8
 )
 FREE RECORD updates_rep
 RECORD updates_rep(
   1 procedures[*]
     2 providers[*]
       3 proc_prsnl_reltn_id = f8
       3 provider_id = f8
       3 provider_name = vc
       3 procedure_reltn_cd = f8
     2 comments[*]
       3 comment_id = f8
       3 prsnl_id = f8
       3 comment_dt_tm = dq8
       3 comment = vc
       3 prsnl_name = vc
       3 comment_tz = i4
     2 modifier_groups[*]
       3 sequence = i4
       3 modifiers[*]
         4 proc_modifier_id = f8
         4 sequence = i4
         4 nomenclature_id = f8
         4 source_string = vc
         4 concept_cki = vc
         4 source_vocabulary_cd = f8
         4 source_identifier = vc
     2 diagnosis_groups[*]
       3 nomen_entity_reltn_id = f8
       3 diagnosis_group_id = f8
     2 procedure_id = f8
     2 version = i4
     2 encounter_id = f8
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 performed_dt_tm = dq8
     2 performed_dt_tm_prec = i4
     2 minutes = i4
     2 priority = i4
     2 anesthesia_cd = f8
     2 anesthesia_minutes = i4
     2 tissue_type_cd = f8
     2 location_id = f8
     2 free_text_location = vc
     2 free_text = vc
     2 note = vc
     2 ranking_cd = f8
     2 clinical_service_cd = f8
     2 active_ind = i2
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 procedure_type = i4
     2 suppress_narrative_ind = i2
     2 last_action_dt_tm = dq8
     2 free_text_timeframe = vc
     2 performed_dt_tm_prec_cd = f8
     2 laterality_cd = f8
     2 update_dt_tm = dq8
     2 proc_start_dt_tm = dq8
     2 proc_end_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(updates_cnt)))
  DECLARE updates_cnt = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(procedure_cnt)))
  DECLARE procedure_cnt = i4 WITH protect, constant(size(request->procedures,5))
 ENDIF
 IF ( NOT (validate(index)))
  DECLARE index = i4 WITH protect, noconstant(0)
 ENDIF
 DECLARE index_new = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE _idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE _cnt = i4 WITH protect, noconstant(0)
 DECLARE _cnt2 = i4 WITH protect, noconstant(0)
 DECLARE nomen_reltn_type_cd = f8 WITH protect, constant(loadcodevalue(23549,"DIAGTOPROC",0))
 DECLARE found = i2 WITH protect, noconstant(0)
 DECLARE contextencntrid = f8 WITH protect, constant(validate(request->context_encntr_id,0.0))
 IF (procedure_cnt=0)
  SET failed = attribute_error
  SET table_name = "No procedures to maintain"
  GO TO exit_script
 ENDIF
 EXECUTE acm_get_proc_by_proc_id  WITH replace("REQUEST",updates_req), replace("REPLY",updates_rep)
 IF (updates_cnt != size(updates_rep->procedures,5))
  SET failed = update_error
  SET table_name = "Attempted to update a non-existant procedure"
  GO TO exit_script
 ENDIF
 SET curalias procedure_old updates_rep->procedures[index]
 SET curalias procedure_new request->procedures[index_new]
 SET stat = alterlist(chg_procedure_request->qual,updates_cnt)
 SET stat = alterlist(add_procedure_acti_request->qual,updates_cnt)
 FOR (index = 1 TO updates_cnt)
   IF (locateval(index_new,1,procedure_cnt,procedure_old->procedure_id,procedure_new->procedure_id)
    > 0)
    IF ((procedure_new->version != procedure_old->version))
     SET failed = attribute_error
     SET table_name = "Incorrect procedure version"
     GO TO exit_script
    ENDIF
    IF ((((procedure_new->encounter_id != procedure_old->encounter_id)) OR ((procedure_new->
    nomenclature_id != procedure_old->nomenclature_id))) )
     SET failed = attribute_error
     SET table_name = "Modifying restricted values"
     GO TO exit_script
    ENDIF
    CALL validate_procedure(index_new)
    IF ((procedure_new->active_ind=1))
     SET cnt = size(procedure_old->providers,5)
     CALL init_match(size(procedure_new->providers,5))
     FOR (idx = 1 TO cnt)
      IF ((procedure_old->providers[idx].provider_id=0)
       AND size(trim(procedure_old->providers[idx].provider_name),1) > 0)
       SET found = locateval(_idx,1,size(procedure_new->providers,5),procedure_old->providers[idx].
        provider_name,procedure_new->providers[_idx].provider_name,
        procedure_old->providers[idx].procedure_reltn_cd,procedure_new->providers[_idx].
        procedure_reltn_cd)
      ELSEIF ((procedure_old->providers[idx].provider_id != 0))
       SET found = locateval(_idx,1,size(procedure_new->providers,5),procedure_old->providers[idx].
        provider_id,procedure_new->providers[_idx].provider_id,
        procedure_old->providers[idx].procedure_reltn_cd,procedure_new->providers[_idx].
        procedure_reltn_cd)
      ENDIF
      IF (found)
       SET match->cnt += 1
       SET match->qual[_idx].found = true
      ELSE
       SET _cnt = (size(ina_proc_prsnl_rel_request->qual,5)+ 1)
       SET stat = alterlist(ina_proc_prsnl_rel_request->qual,_cnt)
       SET ina_proc_prsnl_rel_request->qual[_cnt].proc_prsnl_reltn_id = procedure_old->providers[idx]
       .proc_prsnl_reltn_id
       SET ina_proc_prsnl_rel_request->qual[_cnt].force_updt_ind = 1
      ENDIF
     ENDFOR
     SET cnt = size(procedure_new->providers,5)
     IF ((match->cnt != cnt))
      FOR (idx = 1 TO cnt)
        IF ( NOT (match->qual[idx].found))
         SET _cnt = (size(add_proc_prsnl_rel_request->qual,5)+ 1)
         SET stat = alterlist(add_proc_prsnl_rel_request->qual,_cnt)
         SET add_proc_prsnl_rel_request->qual[_cnt].procedure_id = procedure_new->procedure_id
         SET add_proc_prsnl_rel_request->qual[_cnt].prsnl_person_id = procedure_new->providers[idx].
         provider_id
         SET add_proc_prsnl_rel_request->qual[_cnt].proc_ft_prsnl = procedure_new->providers[idx].
         provider_name
         SET add_proc_prsnl_rel_request->qual[_cnt].proc_prsnl_reltn_cd = procedure_new->providers[
         idx].procedure_reltn_cd
         SET add_proc_prsnl_rel_request->qual[_cnt].contributor_system_cd = procedure_new->
         contributor_system_cd
         SET add_proc_prsnl_rel_request->qual[_cnt].active_ind = 1
        ENDIF
      ENDFOR
     ENDIF
     SET cnt = size(procedure_new->comments,5)
     FOR (idx = 1 TO cnt)
       SET _cnt = (size(add_long_text_request->qual,5)+ 1)
       SET stat = alterlist(add_long_text_request->qual,_cnt)
       SET add_long_text_request->qual[_cnt].parent_entity_id = procedure_new->procedure_id
       SET add_long_text_request->qual[_cnt].parent_entity_name = "PROCEDURE"
       SET add_long_text_request->qual[_cnt].long_text = procedure_new->comments[idx].comment
       SET add_long_text_request->qual[_cnt].active_ind = 1
     ENDFOR
     SET cnt = size(procedure_old->diagnosis_groups,5)
     CALL init_match(size(procedure_new->diagnosis_groups,5))
     FOR (idx = 1 TO cnt)
       IF (locateval(_idx,1,size(procedure_new->diagnosis_groups,5),procedure_old->diagnosis_groups[
        idx].diagnosis_group_id,procedure_new->diagnosis_groups[_idx].diagnosis_group_id) != 0)
        SET match->cnt += 1
        SET match->qual[_idx].found = true
       ELSE
        SET _cnt = (size(ina_nomen_entity_r_request->qual,5)+ 1)
        SET stat = alterlist(ina_nomen_entity_r_request->qual,_cnt)
        SET ina_nomen_entity_r_request->qual[_cnt].nomen_entity_reltn_id = procedure_old->
        diagnosis_groups[idx].nomen_entity_reltn_id
        SET ina_nomen_entity_r_request->qual[_cnt].force_updt_ind = 1
       ENDIF
     ENDFOR
     SET cnt = size(procedure_new->diagnosis_groups,5)
     IF ((match->cnt != cnt))
      FOR (idx = 1 TO cnt)
        IF ( NOT (match->qual[idx].found))
         SET _cnt = (size(add_nomen_entity_r_request->qual,5)+ 1)
         SET stat = alterlist(add_nomen_entity_r_request->qual,_cnt)
         SET add_nomen_entity_r_request->qual[_cnt].parent_entity_name = "DIAGNOSIS"
         SET add_nomen_entity_r_request->qual[_cnt].parent_entity_id = procedure_new->
         diagnosis_groups[idx].diagnosis_group_id
         SET add_nomen_entity_r_request->qual[_cnt].child_entity_name = "PROCEDURE"
         SET add_nomen_entity_r_request->qual[_cnt].child_entity_id = procedure_new->procedure_id
         SET add_nomen_entity_r_request->qual[_cnt].reltn_type_cd = nomen_reltn_type_cd
         SET add_nomen_entity_r_request->qual[_cnt].encntr_id = procedure_new->encounter_id
         SET add_nomen_entity_r_request->qual[_cnt].active_ind = 1
        ENDIF
      ENDFOR
     ENDIF
     SET cnt = size(procedure_old->modifier_groups,5)
     FOR (idx = 1 TO cnt)
       SET _cnt = size(procedure_old->modifier_groups[idx].modifiers,5)
       SET _cnt2 = size(modifiers_old->mods,5)
       SET stat = alterlist(modifiers_old->mods,(_cnt2+ _cnt))
       FOR (_idx = 1 TO _cnt)
         SET modifiers_old->mods[(_cnt2+ _idx)].proc_modifier_id = procedure_old->modifier_groups[idx
         ].modifiers[_idx].proc_modifier_id
         SET modifiers_old->mods[(_cnt2+ _idx)].group_sequence = procedure_old->modifier_groups[idx].
         sequence
         SET modifiers_old->mods[(_cnt2+ _idx)].sequence = procedure_old->modifier_groups[idx].
         modifiers[_idx].sequence
         SET modifiers_old->mods[(_cnt2+ _idx)].nomenclature_id = procedure_old->modifier_groups[idx]
         .modifiers[_idx].nomenclature_id
       ENDFOR
     ENDFOR
     SET cnt = size(procedure_new->modifier_groups,5)
     FOR (idx = 1 TO cnt)
       SET _cnt = size(procedure_new->modifier_groups[idx].modifiers,5)
       SET _cnt2 = size(modifiers_new->mods,5)
       SET stat = alterlist(modifiers_new->mods,(_cnt2+ _cnt))
       FOR (_idx = 1 TO _cnt)
         SET modifiers_new->mods[(_cnt2+ _idx)].group_sequence = procedure_new->modifier_groups[idx].
         sequence
         SET modifiers_new->mods[(_cnt2+ _idx)].sequence = procedure_new->modifier_groups[idx].
         modifiers[_idx].sequence
         SET modifiers_new->mods[(_cnt2+ _idx)].nomenclature_id = procedure_new->modifier_groups[idx]
         .modifiers[_idx].nomenclature_id
       ENDFOR
     ENDFOR
     CALL init_match(size(modifiers_new->mods,5))
     SET cnt = size(modifiers_old->mods,5)
     FOR (idx = 1 TO cnt)
       IF (locateval(_idx,1,size(modifiers_new->mods,5),modifiers_old->mods[idx].nomenclature_id,
        modifiers_new->mods[_idx].nomenclature_id,
        modifiers_old->mods[idx].group_sequence,modifiers_new->mods[_idx].group_sequence,
        modifiers_old->mods[idx].sequence,modifiers_new->mods[_idx].sequence) != 0)
        SET match->cnt += 1
        SET match->qual[_idx].found = true
       ELSE
        SET _cnt = (size(ina_proc_modifier_request->qual,5)+ 1)
        SET stat = alterlist(ina_proc_modifier_request->qual,_cnt)
        SET ina_proc_modifier_request->qual[_cnt].proc_modifier_id = modifiers_old->mods[idx].
        proc_modifier_id
        SET ina_proc_modifier_request->qual[_cnt].force_updt_ind = 1
       ENDIF
     ENDFOR
     SET cnt = size(modifiers_new->mods,5)
     IF ((match->cnt != cnt))
      FOR (idx = 1 TO cnt)
        IF ( NOT (match->qual[idx].found))
         SET _cnt = (size(add_proc_modifier_request->qual,5)+ 1)
         SET stat = alterlist(add_proc_modifier_request->qual,_cnt)
         SET add_proc_modifier_request->qual[_cnt].parent_entity_name = "PROCEDURE"
         SET add_proc_modifier_request->qual[_cnt].parent_entity_id = procedure_new->procedure_id
         SET add_proc_modifier_request->qual[_cnt].nomenclature_id = modifiers_new->mods[idx].
         nomenclature_id
         SET add_proc_modifier_request->qual[_cnt].active_ind = 1
         SET add_proc_modifier_request->qual[_cnt].contributor_system_cd = procedure_new->
         procedure_id
         SET add_proc_modifier_request->qual[_cnt].group_seq = modifiers_new->mods[idx].
         group_sequence
         SET add_proc_modifier_request->qual[_cnt].sequence = modifiers_new->mods[idx].sequence
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    SET add_procedure_acti_request->qual[index].procedure_id = procedure_new->procedure_id
    SET add_procedure_acti_request->qual[index].prsnl_id = reqinfo->updt_id
    SET add_procedure_acti_request->qual[index].action_type_mean = "UPDATE"
    SET add_procedure_acti_request->qual[index].action_dt_tm = cnvtdatetime(sysdate)
    SET chg_procedure_request->qual[index].procedure_id = procedure_new->procedure_id
    SET chg_procedure_request->qual[index].active_ind = procedure_new->active_ind
    SET chg_procedure_request->qual[index].anesthesia_cd = procedure_new->anesthesia_cd
    SET chg_procedure_request->qual[index].anesthesia_minutes = procedure_new->anesthesia_minutes
    SET chg_procedure_request->qual[index].clinical_service_cd = procedure_new->clinical_service_cd
    IF ((procedure_new->contributor_system_cd > 0))
     SET chg_procedure_request->qual[index].contributor_system_cd = procedure_new->
     contributor_system_cd
    ELSE
     SET chg_procedure_request->qual[index].contributor_system_cd = procedure_old->
     contributor_system_cd
    ENDIF
    SET chg_procedure_request->qual[index].encntr_id = procedure_new->encounter_id
    SET chg_procedure_request->qual[index].end_effective_dt_tm = procedure_new->end_effective_dt_tm
    SET chg_procedure_request->qual[index].nomenclature_id = procedure_new->nomenclature_id
    IF ((procedure_new->performed_dt_tm > 0))
     SET chg_procedure_request->qual[index].proc_dt_tm = procedure_new->performed_dt_tm
     SET chg_procedure_request->qual[index].proc_ft_time_frame = ""
    ENDIF
    SET chg_procedure_request->qual[index].proc_dt_tm_prec_cd = procedure_new->
    performed_dt_tm_prec_cd
    SET chg_procedure_request->qual[index].proc_dt_tm_prec_flag = procedure_new->performed_dt_tm_prec
    SET chg_procedure_request->qual[index].proc_ft_loc = procedure_new->free_text_location
    SET chg_procedure_request->qual[index].proc_ftdesc = procedure_new->free_text
    SET chg_procedure_request->qual[index].proc_loc_cd = procedure_new->location_id
    SET chg_procedure_request->qual[index].proc_minutes = procedure_new->minutes
    SET chg_procedure_request->qual[index].proc_priority = procedure_new->priority
    SET chg_procedure_request->qual[index].proc_type_flag = procedure_new->procedure_type
    IF ((procedure_new->note != null))
     SET chg_procedure_request->qual[index].procedure_note = procedure_new->note
    ELSEIF ((chg_procedure_request->qual[index].nomenclature_id > 0))
     SELECT INTO "nl:"
      n.source_string
      FROM nomenclature n
      WHERE (n.nomenclature_id=chg_procedure_request->qual[index].nomenclature_id)
      DETAIL
       chg_procedure_request->qual[index].procedure_note = n.source_string
      WITH nocounter
     ;end select
    ELSE
     SET chg_procedure_request->qual[index].procedure_note = chg_procedure_request->qual[index].
     proc_ftdesc
    ENDIF
    SET chg_procedure_request->qual[index].ranking_cd = procedure_new->ranking_cd
    SET chg_procedure_request->qual[index].suppress_narrative_ind = procedure_new->
    suppress_narrative_ind
    SET chg_procedure_request->qual[index].tissue_type_cd = procedure_new->tissue_type_cd
    SET chg_procedure_request->qual[index].updt_cnt = procedure_new->version
    SET chg_procedure_request->qual[index].laterality_cd = procedure_new->laterality_cd
    SET chg_procedure_request->qual[index].reference_nbr = cnvtstring(procedure_new->reference_nbr)
    IF (validate(chg_procedure_request->qual[index].proc_start_dt_tm)
     AND validate(procedure_new->proc_start_dt_tm))
     SET chg_procedure_request->qual[index].proc_start_dt_tm = procedure_new->proc_start_dt_tm
    ENDIF
    IF (validate(chg_procedure_request->qual[index].proc_end_dt_tm)
     AND validate(procedure_new->proc_end_dt_tm))
     SET chg_procedure_request->qual[index].proc_end_dt_tm = procedure_new->proc_end_dt_tm
    ENDIF
   ELSE
    SET failed = attribute_error
    SET table_name = "Invalid Procedure"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (validate(add_procedure_acti_request->context_encntr_id)=1)
  SET add_procedure_acti_request->context_encntr_id = contextencntrid
 ENDIF
 SET curalias procedure_new off
 SET curalias procedure_old off
 IF (size(chg_procedure_request->qual,5) > 0)
  EXECUTE acm_chg_procedure
  FOR (i = 1 TO chg_procedure_reply->qual_cnt)
    IF (validate(reply->procedures[i].update_dt_tm)
     AND validate(chg_procedure_reply->qual[i].update_dt_tm))
     SET reply->procedures[i].update_dt_tm = chg_procedure_reply->qual[i].update_dt_tm
    ENDIF
  ENDFOR
  CALL check_status(null)
 ENDIF
 SET cnt = size(add_proc_prsnl_rel_request->qual,5)
 IF (cnt > 0)
  CALL index_prsnl(cnt)
  EXECUTE acm_add_proc_prsnl_rel
  CALL check_status(null)
 ENDIF
 IF (size(ina_proc_prsnl_rel_request->qual,5) > 0)
  EXECUTE acm_ina_proc_prsnl_rel
  CALL check_status(null)
 ENDIF
 SET cnt = size(add_proc_modifier_request->qual,5)
 IF (cnt > 0)
  CALL index_modifier(cnt)
  EXECUTE acm_add_proc_modifier
  CALL check_status(null)
 ENDIF
 IF (size(ina_proc_modifier_request->qual,5) > 0)
  EXECUTE acm_ina_proc_modifier
  CALL check_status(null)
 ENDIF
 SET cnt = size(add_long_text_request->qual,5)
 IF (cnt > 0)
  CALL index_long_text(cnt)
  EXECUTE acm_add_long_text
  CALL check_status(null)
 ENDIF
 SET cnt = size(add_nomen_entity_r_request->qual,5)
 IF (cnt > 0)
  IF (cnt > 0)
   SELECT INTO "nl:"
    e.person_id
    FROM (dummyt d  WITH seq = value(cnt)),
     encounter e
    PLAN (d)
     JOIN (e
     WHERE (e.encntr_id=add_nomen_entity_r_request->qual[d.seq].encntr_id))
    ORDER BY d.seq
    DETAIL
     add_nomen_entity_r_request->qual[d.seq].person_id = e.person_id
    WITH nocounter
   ;end select
  ENDIF
  CALL index_diagnosis(cnt)
  EXECUTE acm_add_nomen_entity_r
  CALL check_status(null)
 ENDIF
 IF (size(ina_nomen_entity_r_request->qual,5) > 0)
  EXECUTE acm_ina_nomen_entity_r
  CALL check_status(null)
 ENDIF
 SET cnt = size(add_procedure_acti_request->qual,5)
 IF (cnt > 0)
  CALL index_action(cnt)
  EXECUTE acm_add_procedure_acti
  CALL check_status(null)
 ENDIF
 SUBROUTINE (init_match(sz=i4) =null)
   FREE RECORD match
   RECORD match(
     1 cnt = i4
     1 qual[*]
       2 found = i2
   ) WITH persistscript
   SET stat = alterlist(match->qual,sz)
   RETURN
 END ;Subroutine
 SUBROUTINE (index_prsnl(nbr=i4) =null)
   SELECT INTO "nl:"
    xseq = seq(reference_seq,nextval)
    FROM (dummyt d  WITH seq = value(nbr)),
     dual u
    PLAN (d)
     JOIN (u)
    DETAIL
     add_proc_prsnl_rel_request->qual[d.seq].proc_prsnl_reltn_id = xseq
   ;end select
 END ;Subroutine
 SUBROUTINE (index_modifier(nbr=i4) =null)
   SELECT INTO "nl:"
    xseq = seq(reference_seq,nextval)
    FROM (dummyt d  WITH seq = value(nbr)),
     dual u
    PLAN (d)
     JOIN (u)
    DETAIL
     add_proc_modifier_request->qual[d.seq].proc_modifier_id = xseq
   ;end select
 END ;Subroutine
 SUBROUTINE (index_long_text(nbr=i4) =null)
   SELECT INTO "nl:"
    xseq = seq(long_data_seq,nextval)
    FROM (dummyt d  WITH seq = value(nbr)),
     dual u
    PLAN (d)
     JOIN (u)
    DETAIL
     add_long_text_request->qual[d.seq].long_text_id = xseq
   ;end select
 END ;Subroutine
 SUBROUTINE (index_diagnosis(nbr=i4) =null)
   SELECT INTO "nl:"
    xseq = seq(entity_reltn_seq,nextval)
    FROM (dummyt d  WITH seq = value(nbr)),
     dual u
    PLAN (d)
     JOIN (u)
    DETAIL
     add_nomen_entity_r_request->qual[d.seq].nomen_entity_reltn_id = xseq
   ;end select
 END ;Subroutine
 SUBROUTINE (index_action(nbr=i4) =null)
   SELECT INTO "nl:"
    xseq = seq(reference_seq,nextval)
    FROM (dummyt d  WITH seq = value(nbr)),
     dual u
    PLAN (d)
     JOIN (u)
    DETAIL
     add_procedure_acti_request->qual[d.seq].procedure_action_id = xseq
   ;end select
 END ;Subroutine
#exit_script
 IF ( NOT (failed))
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = false
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
