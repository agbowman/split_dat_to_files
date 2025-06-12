CREATE PROGRAM acm_procedure_add:dba
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
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE diag_proc_type_cd = f8 WITH protect, constant(loadcodevalue(23549,"DIAGTOPROC",0))
 DECLARE contextencntrid = f8 WITH protect, constant(validate(request->context_encntr_id,0.0))
 IF (adds_cnt > 0)
  CALL populate_add_procedure_req(null)
  IF (size(add_procedure_request->qual,5) > 0)
   EXECUTE acm_add_procedure
   FOR (i = 1 TO add_procedure_reply->qual_cnt)
     IF (validate(reply->procedures[i].update_dt_tm)
      AND validate(add_procedure_reply->qual[i].update_dt_tm))
      SET reply->procedures[i].update_dt_tm = add_procedure_reply->qual[i].update_dt_tm
     ENDIF
   ENDFOR
   CALL check_status(null)
  ENDIF
  IF (size(add_proc_prsnl_rel_request->qual,5) > 0)
   EXECUTE acm_add_proc_prsnl_rel
   CALL check_status(null)
  ENDIF
  IF (size(add_proc_modifier_request->qual,5) > 0)
   EXECUTE acm_add_proc_modifier
   CALL check_status(null)
  ENDIF
  IF (size(add_long_text_request->qual,5) > 0)
   EXECUTE acm_add_long_text
   CALL check_status(null)
  ENDIF
  IF (size(add_nomen_entity_r_request->qual,5) > 0)
   EXECUTE acm_add_nomen_entity_r
   CALL check_status(null)
  ENDIF
  IF (size(add_procedure_acti_request->qual,5) > 0)
   EXECUTE acm_add_procedure_acti
   CALL check_status(null)
  ENDIF
 ENDIF
 SUBROUTINE populate_add_procedure_req(null)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE j = i4 WITH private, noconstant(0)
   DECLARE prsnl_cnt = i4 WITH private, noconstant(0)
   DECLARE comment_cnt = i4 WITH private, noconstant(0)
   DECLARE modifier_cnt = i4 WITH private, noconstant(0)
   DECLARE diag_grp_cnt = i4 WITH private, noconstant(0)
   SELECT INTO "nl:"
    sequence = seq(reference_seq,nextval)
    FROM (dummyt d  WITH seq = value(adds_cnt)),
     dual t
    PLAN (d)
     JOIN (t)
    DETAIL
     request->procedures[xref->adds[d.seq].idx].procedure_id = sequence, reply->procedures[xref->
     adds[d.seq].idx].procedure_id = sequence
    WITH nocounter
   ;end select
   SET stat = alterlist(add_procedure_request->qual,adds_cnt)
   SET stat = alterlist(add_procedure_acti_request->qual,adds_cnt)
   FOR (index = 1 TO adds_cnt)
     SET req_idx = xref->adds[index].idx
     CALL validate_procedure(req_idx)
     SET add_procedure_request->qual[index].active_ind = 1
     SET add_procedure_request->qual[index].anesthesia_cd = request->procedures[req_idx].
     anesthesia_cd
     SET add_procedure_request->qual[index].anesthesia_minutes = request->procedures[req_idx].
     anesthesia_minutes
     SET add_procedure_request->qual[index].beg_effective_dt_tm = cnvtdatetime(sysdate)
     SET add_procedure_request->qual[index].clinical_service_cd = request->procedures[req_idx].
     clinical_service_cd
     SET add_procedure_request->qual[index].contributor_system_cd = request->procedures[req_idx].
     contributor_system_cd
     SET add_procedure_request->qual[index].encntr_id = request->procedures[req_idx].encounter_id
     SET add_procedure_request->qual[index].end_effective_dt_tm = request->procedures[req_idx].
     end_effective_dt_tm
     SET add_procedure_request->qual[index].nomenclature_id = request->procedures[req_idx].
     nomenclature_id
     SET add_procedure_request->qual[index].proc_dt_tm = request->procedures[req_idx].performed_dt_tm
     SET add_procedure_request->qual[index].proc_dt_tm_prec_cd = request->procedures[req_idx].
     performed_dt_tm_prec_cd
     SET add_procedure_request->qual[index].proc_dt_tm_prec_flag = request->procedures[req_idx].
     performed_dt_tm_prec
     SET add_procedure_request->qual[index].proc_ft_loc = request->procedures[req_idx].
     free_text_location
     SET add_procedure_request->qual[index].proc_ftdesc = request->procedures[req_idx].free_text
     SET add_procedure_request->qual[index].proc_loc_cd = request->procedures[req_idx].location_id
     SET add_procedure_request->qual[index].proc_minutes = request->procedures[req_idx].minutes
     SET add_procedure_request->qual[index].proc_priority = request->procedures[req_idx].priority
     SET add_procedure_request->qual[index].proc_type_flag = request->procedures[req_idx].
     procedure_type
     SET add_procedure_request->qual[index].procedure_id = request->procedures[req_idx].procedure_id
     IF (validate(add_procedure_request->qual[index].proc_start_dt_tm)
      AND validate(request->procedures[req_idx].proc_start_dt_tm))
      SET add_procedure_request->qual[index].proc_start_dt_tm = request->procedures[req_idx].
      proc_start_dt_tm
     ENDIF
     IF (validate(add_procedure_request->qual[index].proc_end_dt_tm)
      AND validate(request->procedures[req_idx].proc_end_dt_tm))
      SET add_procedure_request->qual[index].proc_end_dt_tm = request->procedures[req_idx].
      proc_end_dt_tm
     ENDIF
     IF ((request->procedures[req_idx].note != null))
      SET add_procedure_request->qual[index].procedure_note = request->procedures[req_idx].note
     ELSEIF ((add_procedure_request->qual[index].nomenclature_id > 0))
      SELECT INTO "nl:"
       n.source_string
       FROM nomenclature n
       WHERE (n.nomenclature_id=add_procedure_request->qual[index].nomenclature_id)
       DETAIL
        add_procedure_request->qual[index].procedure_note = n.source_string
       WITH nocounter
      ;end select
     ELSE
      SET add_procedure_request->qual[index].procedure_note = add_procedure_request->qual[index].
      proc_ftdesc
     ENDIF
     SET add_procedure_request->qual[index].ranking_cd = request->procedures[req_idx].ranking_cd
     SET add_procedure_request->qual[index].suppress_narrative_ind = request->procedures[req_idx].
     suppress_narrative_ind
     SET add_procedure_request->qual[index].tissue_type_cd = request->procedures[req_idx].
     tissue_type_cd
     SET add_procedure_request->qual[index].procedure_id = request->procedures[req_idx].procedure_id
     SET add_procedure_request->qual[index].laterality_cd = request->procedures[req_idx].
     laterality_cd
     SET add_procedure_request->qual[index].reference_nbr = cnvtstring(request->procedures[req_idx].
      reference_nbr)
     SET add_procedure_acti_request->qual[index].action_dt_tm = cnvtdatetime(sysdate)
     SET add_procedure_acti_request->qual[index].action_type_mean = "CREATE"
     SET add_procedure_acti_request->qual[index].procedure_id = request->procedures[req_idx].
     procedure_id
     SET add_procedure_acti_request->qual[index].prsnl_id = reqinfo->updt_id
     SET num_prsnl = size(request->procedures[req_idx].providers,5)
     IF (num_prsnl > 0)
      SET stat = alterlist(add_proc_prsnl_rel_request->qual,(prsnl_cnt+ num_prsnl))
      SET cnt = 0
      FOR (i = (prsnl_cnt+ 1) TO (prsnl_cnt+ num_prsnl))
        SET cnt += 1
        SET add_proc_prsnl_rel_request->qual[i].active_ind = 1
        SET add_proc_prsnl_rel_request->qual[i].procedure_id = request->procedures[req_idx].
        procedure_id
        SET add_proc_prsnl_rel_request->qual[i].prsnl_person_id = request->procedures[req_idx].
        providers[cnt].provider_id
        SET add_proc_prsnl_rel_request->qual[i].proc_prsnl_reltn_cd = request->procedures[req_idx].
        providers[cnt].procedure_reltn_cd
        SET add_proc_prsnl_rel_request->qual[i].proc_ft_prsnl = request->procedures[req_idx].
        providers[cnt].provider_name
      ENDFOR
      SET prsnl_cnt += num_prsnl
     ENDIF
     SET num_comments = size(request->procedures[req_idx].comments,5)
     IF (num_comments > 0)
      SET stat = alterlist(add_long_text_request->qual,(comment_cnt+ num_comments))
      SET cnt = 0
      FOR (i = (comment_cnt+ 1) TO (comment_cnt+ num_comments))
        SET cnt += 1
        SET add_long_text_request->qual[i].active_ind = 1
        SET add_long_text_request->qual[i].parent_entity_name = "PROCEDURE"
        SET add_long_text_request->qual[i].parent_entity_id = request->procedures[req_idx].
        procedure_id
        SET add_long_text_request->qual[i].long_text = request->procedures[req_idx].comments[cnt].
        comment
      ENDFOR
      SET comment_cnt += num_comments
     ENDIF
     SET num_modifier_grps = size(request->procedures[req_idx].modifier_groups,5)
     IF (num_modifier_grps > 0)
      FOR (i = 1 TO num_modifier_grps)
        SET group_seq = request->procedures[req_idx].modifier_groups[i].sequence
        SET num_modifiers = size(request->procedures[req_idx].modifier_groups[i].modifiers,5)
        IF (num_modifiers > 0)
         SET stat = alterlist(add_proc_modifier_request->qual,(modifier_cnt+ num_modifiers))
         SET cnt = 0
         FOR (j = (modifier_cnt+ 1) TO (modifier_cnt+ num_modifiers))
           SET cnt += 1
           SET add_proc_modifier_request->qual[j].active_ind = 1
           SET add_proc_modifier_request->qual[j].parent_entity_id = request->procedures[req_idx].
           procedure_id
           SET add_proc_modifier_request->qual[j].parent_entity_name = "PROCEDURE"
           SET add_proc_modifier_request->qual[j].group_seq = group_seq
           SET add_proc_modifier_request->qual[j].nomenclature_id = request->procedures[req_idx].
           modifier_groups[i].modifiers[cnt].nomenclature_id
           SET add_proc_modifier_request->qual[j].sequence = request->procedures[req_idx].
           modifier_groups[i].modifiers[cnt].sequence
         ENDFOR
         SET modifier_cnt += num_modifiers
        ENDIF
      ENDFOR
     ENDIF
     SET num_diag_grps = size(request->procedures[req_idx].diagnosis_groups,5)
     IF (num_diag_grps > 0)
      SET stat = alterlist(add_nomen_entity_r_request->qual,(diag_grp_cnt+ num_diag_grps))
      SET cnt = 0
      FOR (i = (diag_grp_cnt+ 1) TO (diag_grp_cnt+ num_diag_grps))
        SET cnt += 1
        SET add_nomen_entity_r_request->qual[i].active_ind = 1
        SET add_nomen_entity_r_request->qual[i].child_entity_id = request->procedures[req_idx].
        procedure_id
        SET add_nomen_entity_r_request->qual[i].child_entity_name = "PROCEDURE"
        SET add_nomen_entity_r_request->qual[i].encntr_id = request->procedures[req_idx].encounter_id
        SET add_nomen_entity_r_request->qual[i].parent_entity_id = request->procedures[req_idx].
        diagnosis_groups[cnt].diagnosis_group_id
        SET add_nomen_entity_r_request->qual[i].parent_entity_name = "DIAGNOSIS"
        SET add_nomen_entity_r_request->qual[i].reltn_type_cd = diag_proc_type_cd
      ENDFOR
      SET diag_grp_cnt += num_diag_grps
     ENDIF
   ENDFOR
   IF (validate(add_procedure_acti_request->context_encntr_id)=1)
    SET add_procedure_acti_request->context_encntr_id = contextencntrid
   ENDIF
   IF (diag_grp_cnt > 0)
    SELECT INTO "nl:"
     e.person_id
     FROM (dummyt d  WITH seq = value(diag_grp_cnt)),
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
   RETURN
 END ;Subroutine
#exit_script
 IF ( NOT (failed))
  SET reply->status_data.status = "S"
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
    OF version_insert_error:
     CALL s_add_subeventstatus("VERSION_INSERT","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF version_delete_error:
     CALL s_add_subeventstatus("VERSION_DELETE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCL_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
