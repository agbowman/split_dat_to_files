CREATE PROGRAM acm_chg_procedure:dba
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
 IF (validate(chg_procedure_request,0))
  SET called_by_script_server = false
 ELSE
  SET called_by_script_server = true
 ENDIF
 IF (called_by_script_server=true)
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
  SET nbr1 = size(request->qual,5)
  SET stat = alterlist(chg_procedure_request->qual,nbr1)
  SET chg_procedure_request->call_echo_ind = request->call_echo_ind
  FOR (i = 1 TO nbr1)
    SET chg_procedure_request->qual[i].procedure_id = request->qual[i].procedure_id
    SET chg_procedure_request->qual[i].updt_cnt = request->qual[i].updt_cnt
    SET chg_procedure_request->qual[i].beg_effective_dt_tm = request->qual[i].beg_effective_dt_tm
    SET chg_procedure_request->qual[i].end_effective_dt_tm = request->qual[i].end_effective_dt_tm
    SET chg_procedure_request->qual[i].contributor_system_cd = request->qual[i].contributor_system_cd
    SET chg_procedure_request->qual[i].encntr_id = request->qual[i].encntr_id
    SET chg_procedure_request->qual[i].nomenclature_id = request->qual[i].nomenclature_id
    SET chg_procedure_request->qual[i].proc_dt_tm = request->qual[i].proc_dt_tm
    SET chg_procedure_request->qual[i].proc_priority = request->qual[i].proc_priority
    SET chg_procedure_request->qual[i].proc_func_type_cd = request->qual[i].proc_func_type_cd
    SET chg_procedure_request->qual[i].proc_minutes = request->qual[i].proc_minutes
    SET chg_procedure_request->qual[i].consent_cd = request->qual[i].consent_cd
    SET chg_procedure_request->qual[i].diag_nomenclature_id = request->qual[i].diag_nomenclature_id
    SET chg_procedure_request->qual[i].reference_nbr = request->qual[i].reference_nbr
    SET chg_procedure_request->qual[i].seg_unique_key = request->qual[i].seg_unique_key
    SET chg_procedure_request->qual[i].mod_nomenclature_id = request->qual[i].mod_nomenclature_id
    SET chg_procedure_request->qual[i].anesthesia_cd = request->qual[i].anesthesia_cd
    SET chg_procedure_request->qual[i].anesthesia_minutes = request->qual[i].anesthesia_minutes
    SET chg_procedure_request->qual[i].tissue_type_cd = request->qual[i].tissue_type_cd
    SET chg_procedure_request->qual[i].svc_cat_hist_id = request->qual[i].svc_cat_hist_id
    SET chg_procedure_request->qual[i].proc_loc_cd = request->qual[i].proc_loc_cd
    SET chg_procedure_request->qual[i].proc_loc_ft_ind = request->qual[i].proc_loc_ft_ind
    SET chg_procedure_request->qual[i].proc_ft_loc = request->qual[i].proc_ft_loc
    SET chg_procedure_request->qual[i].proc_ft_dt_tm_ind = request->qual[i].proc_ft_dt_tm_ind
    SET chg_procedure_request->qual[i].proc_ft_time_frame = request->qual[i].proc_ft_time_frame
    SET chg_procedure_request->qual[i].comment_ind = request->qual[i].comment_ind
    SET chg_procedure_request->qual[i].long_text_id = request->qual[i].long_text_id
    SET chg_procedure_request->qual[i].proc_ftdesc = request->qual[i].proc_ftdesc
    SET chg_procedure_request->qual[i].procedure_note = request->qual[i].procedure_note
    SET chg_procedure_request->qual[i].generic_val_cd = request->qual[i].generic_val_cd
    SET chg_procedure_request->qual[i].ranking_cd = request->qual[i].ranking_cd
    SET chg_procedure_request->qual[i].clinical_service_cd = request->qual[i].clinical_service_cd
    SET chg_procedure_request->qual[i].dgvp_ind = request->qual[i].dgvp_ind
    SET chg_procedure_request->qual[i].encntr_slice_id = request->qual[i].encntr_slice_id
    SET chg_procedure_request->qual[i].proc_dt_tm_prec_flag = request->qual[i].proc_dt_tm_prec_flag
    SET chg_procedure_request->qual[i].proc_type_flag = request->qual[i].proc_type_flag
    SET chg_procedure_request->qual[i].suppress_narrative_ind = request->qual[i].
    suppress_narrative_ind
    SET chg_procedure_request->qual[i].allow_partial_ind = request->qual[i].allow_partial_ind
    SET chg_procedure_request->qual[i].version_ind = request->qual[i].version_ind
    SET chg_procedure_request->qual[i].force_updt_ind = request->qual[i].force_updt_ind
    SET chg_procedure_request->qual[i].active_ind = request->qual[i].active_ind
    SET chg_procedure_request->qual[i].proc_dt_tm_prec_cd = request->qual[i].proc_dt_tm_prec_cd
    SET chg_procedure_request->qual[i].laterality_cd = request->qual[i].laterality_cd
    IF (validate(chg_procedure_request->qual[i].proc_start_dt_tm)
     AND validate(request->qual[i].proc_start_dt_tm))
     SET chg_procedure_request->qual[i].proc_start_dt_tm = request->qual[i].proc_start_dt_tm
    ENDIF
    IF (validate(chg_procedure_request->qual[i].proc_end_dt_tm)
     AND validate(request->qual[i].proc_end_dt_tm))
     SET chg_procedure_request->qual[i].proc_end_dt_tm = request->qual[i].proc_end_dt_tm
    ENDIF
  ENDFOR
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
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
 DECLARE update_dt_tm = dq8 WITH protect, noconstant(0.0)
 SET nbr_correct = 0
 SET reply->status_data.status = "F"
 SET table_name = "PROCEDURE"
 SET chg_procedure_reply->qual_cnt = size(chg_procedure_request->qual,5)
 SET stat = alterlist(chg_procedure_reply->qual,chg_procedure_reply->qual_cnt)
 IF ((chg_procedure_reply->qual_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  t.updt_cnt, d.seq
  FROM procedure t,
   (dummyt d  WITH seq = value(chg_procedure_reply->qual_cnt))
  PLAN (d)
   JOIN (t
   WHERE (t.procedure_id=chg_procedure_request->qual[d.seq].procedure_id))
  HEAD REPORT
   i_version = 0
  DETAIL
   IF ((((t.updt_cnt=chg_procedure_request->qual[d.seq].updt_cnt)) OR ((chg_procedure_request->qual[d
   .seq].force_updt_ind=1))) )
    chg_procedure_reply->qual[d.seq].status = 1
   ELSE
    chg_procedure_reply->qual[d.seq].status = update_cnt_error
   ENDIF
  WITH nocounter, forupdate(t)
 ;end select
 SET nbr_correct = 0
 FOR (i = 1 TO chg_procedure_reply->qual_cnt)
   IF ((chg_procedure_reply->qual[i].status=1))
    SET nbr_correct += 1
   ELSE
    IF ((chg_procedure_request->qual[i].allow_partial_ind != 1))
     SET failed = select_error
     SET nbr_correct = 0
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_correct=0)
  GO TO exit_script
 ENDIF
 SET update_dt_tm = cnvtdatetime(sysdate)
 IF (checkdic("PROCEDURE.PROC_START_DT_TM","A",0)
  AND checkdic("PROCEDURE.PROC_END_DT_TM","A",0))
  UPDATE  FROM procedure t,
    (dummyt d  WITH seq = value(chg_procedure_reply->qual_cnt))
   SET t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(update_dt_tm), t.updt_id = reqinfo->
    updt_id,
    t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.beg_effective_dt_tm
     =
    IF ((chg_procedure_request->qual[d.seq].beg_effective_dt_tm > 0)) cnvtdatetime(
      chg_procedure_request->qual[d.seq].beg_effective_dt_tm)
    ELSE t.beg_effective_dt_tm
    ENDIF
    ,
    t.end_effective_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].end_effective_dt_tm > 0)) cnvtdatetime(
      chg_procedure_request->qual[d.seq].end_effective_dt_tm)
    ELSEIF ((chg_procedure_request->qual[d.seq].active_ind=false)) cnvtdatetime(sysdate)
    ELSE t.end_effective_dt_tm
    ENDIF
    , t.contributor_system_cd = chg_procedure_request->qual[d.seq].contributor_system_cd, t.encntr_id
     = chg_procedure_request->qual[d.seq].encntr_id,
    t.nomenclature_id = chg_procedure_request->qual[d.seq].nomenclature_id, t.proc_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].proc_dt_tm > 0)) cnvtdatetime(chg_procedure_request->
      qual[d.seq].proc_dt_tm)
    ELSE null
    ENDIF
    , t.proc_priority = chg_procedure_request->qual[d.seq].proc_priority,
    t.proc_func_type_cd = chg_procedure_request->qual[d.seq].proc_func_type_cd, t.proc_minutes =
    chg_procedure_request->qual[d.seq].proc_minutes, t.consent_cd = chg_procedure_request->qual[d.seq
    ].consent_cd,
    t.diag_nomenclature_id = chg_procedure_request->qual[d.seq].diag_nomenclature_id, t.reference_nbr
     = trim(chg_procedure_request->qual[d.seq].reference_nbr), t.seg_unique_key = trim(
     chg_procedure_request->qual[d.seq].seg_unique_key),
    t.mod_nomenclature_id = chg_procedure_request->qual[d.seq].mod_nomenclature_id, t.anesthesia_cd
     = chg_procedure_request->qual[d.seq].anesthesia_cd, t.anesthesia_minutes = chg_procedure_request
    ->qual[d.seq].anesthesia_minutes,
    t.tissue_type_cd = chg_procedure_request->qual[d.seq].tissue_type_cd, t.svc_cat_hist_id =
    chg_procedure_request->qual[d.seq].svc_cat_hist_id, t.proc_loc_cd = chg_procedure_request->qual[d
    .seq].proc_loc_cd,
    t.proc_loc_ft_ind = chg_procedure_request->qual[d.seq].proc_loc_ft_ind, t.proc_ft_loc = trim(
     chg_procedure_request->qual[d.seq].proc_ft_loc), t.proc_ft_dt_tm_ind = chg_procedure_request->
    qual[d.seq].proc_ft_dt_tm_ind,
    t.proc_ft_time_frame = trim(chg_procedure_request->qual[d.seq].proc_ft_time_frame), t.comment_ind
     = chg_procedure_request->qual[d.seq].comment_ind, t.long_text_id = chg_procedure_request->qual[d
    .seq].long_text_id,
    t.proc_ftdesc = trim(chg_procedure_request->qual[d.seq].proc_ftdesc), t.procedure_note = trim(
     chg_procedure_request->qual[d.seq].procedure_note), t.generic_val_cd = chg_procedure_request->
    qual[d.seq].generic_val_cd,
    t.ranking_cd = chg_procedure_request->qual[d.seq].ranking_cd, t.clinical_service_cd =
    chg_procedure_request->qual[d.seq].clinical_service_cd, t.dgvp_ind = chg_procedure_request->qual[
    d.seq].dgvp_ind,
    t.encntr_slice_id = chg_procedure_request->qual[d.seq].encntr_slice_id, t.proc_dt_tm_prec_flag =
    chg_procedure_request->qual[d.seq].proc_dt_tm_prec_flag, t.proc_type_flag = chg_procedure_request
    ->qual[d.seq].proc_type_flag,
    t.suppress_narrative_ind = chg_procedure_request->qual[d.seq].suppress_narrative_ind, t
    .proc_dt_tm_prec_cd = chg_procedure_request->qual[d.seq].proc_dt_tm_prec_cd, t.laterality_cd =
    chg_procedure_request->qual[d.seq].laterality_cd,
    t.proc_start_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].proc_start_dt_tm > 0)) cnvtdatetime(chg_procedure_request
      ->qual[d.seq].proc_start_dt_tm)
    ELSE null
    ENDIF
    , t.proc_end_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].proc_end_dt_tm > 0)) cnvtdatetime(chg_procedure_request->
      qual[d.seq].proc_end_dt_tm)
    ELSE null
    ENDIF
    , t.active_ind = chg_procedure_request->qual[d.seq].active_ind,
    t.active_status_cd =
    IF ((chg_procedure_request->qual[d.seq].active_ind=false)) reqdata->inactive_status_cd
    ELSE t.active_status_cd
    ENDIF
    , t.active_status_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].active_ind=false)) cnvtdatetime(sysdate)
    ELSE t.active_status_dt_tm
    ENDIF
    , t.active_status_prsnl_id =
    IF ((chg_procedure_request->qual[d.seq].active_ind=false)) reqinfo->updt_id
    ELSE t.active_status_prsnl_id
    ENDIF
    ,
    stat = assign(validate(chg_procedure_reply->qual[d.seq].update_dt_tm),cnvtdatetime(update_dt_tm))
   PLAN (d
    WHERE (chg_procedure_reply->qual[d.seq].status=1))
    JOIN (t
    WHERE (t.procedure_id=chg_procedure_request->qual[d.seq].procedure_id))
   WITH nocounter, status(chg_procedure_reply->qual[d.seq].status)
  ;end update
 ELSE
  UPDATE  FROM procedure t,
    (dummyt d  WITH seq = value(chg_procedure_reply->qual_cnt))
   SET t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(update_dt_tm), t.updt_id = reqinfo->
    updt_id,
    t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.beg_effective_dt_tm
     =
    IF ((chg_procedure_request->qual[d.seq].beg_effective_dt_tm > 0)) cnvtdatetime(
      chg_procedure_request->qual[d.seq].beg_effective_dt_tm)
    ELSE t.beg_effective_dt_tm
    ENDIF
    ,
    t.end_effective_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].end_effective_dt_tm > 0)) cnvtdatetime(
      chg_procedure_request->qual[d.seq].end_effective_dt_tm)
    ELSEIF ((chg_procedure_request->qual[d.seq].active_ind=false)) cnvtdatetime(sysdate)
    ELSE t.end_effective_dt_tm
    ENDIF
    , t.contributor_system_cd = chg_procedure_request->qual[d.seq].contributor_system_cd, t.encntr_id
     = chg_procedure_request->qual[d.seq].encntr_id,
    t.nomenclature_id = chg_procedure_request->qual[d.seq].nomenclature_id, t.proc_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].proc_dt_tm > 0)) cnvtdatetime(chg_procedure_request->
      qual[d.seq].proc_dt_tm)
    ELSE null
    ENDIF
    , t.proc_priority = chg_procedure_request->qual[d.seq].proc_priority,
    t.proc_func_type_cd = chg_procedure_request->qual[d.seq].proc_func_type_cd, t.proc_minutes =
    chg_procedure_request->qual[d.seq].proc_minutes, t.consent_cd = chg_procedure_request->qual[d.seq
    ].consent_cd,
    t.diag_nomenclature_id = chg_procedure_request->qual[d.seq].diag_nomenclature_id, t.reference_nbr
     = trim(chg_procedure_request->qual[d.seq].reference_nbr), t.seg_unique_key = trim(
     chg_procedure_request->qual[d.seq].seg_unique_key),
    t.mod_nomenclature_id = chg_procedure_request->qual[d.seq].mod_nomenclature_id, t.anesthesia_cd
     = chg_procedure_request->qual[d.seq].anesthesia_cd, t.anesthesia_minutes = chg_procedure_request
    ->qual[d.seq].anesthesia_minutes,
    t.tissue_type_cd = chg_procedure_request->qual[d.seq].tissue_type_cd, t.svc_cat_hist_id =
    chg_procedure_request->qual[d.seq].svc_cat_hist_id, t.proc_loc_cd = chg_procedure_request->qual[d
    .seq].proc_loc_cd,
    t.proc_loc_ft_ind = chg_procedure_request->qual[d.seq].proc_loc_ft_ind, t.proc_ft_loc = trim(
     chg_procedure_request->qual[d.seq].proc_ft_loc), t.proc_ft_dt_tm_ind = chg_procedure_request->
    qual[d.seq].proc_ft_dt_tm_ind,
    t.proc_ft_time_frame = trim(chg_procedure_request->qual[d.seq].proc_ft_time_frame), t.comment_ind
     = chg_procedure_request->qual[d.seq].comment_ind, t.long_text_id = chg_procedure_request->qual[d
    .seq].long_text_id,
    t.proc_ftdesc = trim(chg_procedure_request->qual[d.seq].proc_ftdesc), t.procedure_note = trim(
     chg_procedure_request->qual[d.seq].procedure_note), t.generic_val_cd = chg_procedure_request->
    qual[d.seq].generic_val_cd,
    t.ranking_cd = chg_procedure_request->qual[d.seq].ranking_cd, t.clinical_service_cd =
    chg_procedure_request->qual[d.seq].clinical_service_cd, t.dgvp_ind = chg_procedure_request->qual[
    d.seq].dgvp_ind,
    t.encntr_slice_id = chg_procedure_request->qual[d.seq].encntr_slice_id, t.proc_dt_tm_prec_flag =
    chg_procedure_request->qual[d.seq].proc_dt_tm_prec_flag, t.proc_type_flag = chg_procedure_request
    ->qual[d.seq].proc_type_flag,
    t.suppress_narrative_ind = chg_procedure_request->qual[d.seq].suppress_narrative_ind, t
    .proc_dt_tm_prec_cd = chg_procedure_request->qual[d.seq].proc_dt_tm_prec_cd, t.laterality_cd =
    chg_procedure_request->qual[d.seq].laterality_cd,
    t.active_ind = chg_procedure_request->qual[d.seq].active_ind, t.active_status_cd =
    IF ((chg_procedure_request->qual[d.seq].active_ind=false)) reqdata->inactive_status_cd
    ELSE t.active_status_cd
    ENDIF
    , t.active_status_dt_tm =
    IF ((chg_procedure_request->qual[d.seq].active_ind=false)) cnvtdatetime(sysdate)
    ELSE t.active_status_dt_tm
    ENDIF
    ,
    t.active_status_prsnl_id =
    IF ((chg_procedure_request->qual[d.seq].active_ind=false)) reqinfo->updt_id
    ELSE t.active_status_prsnl_id
    ENDIF
    , stat = assign(validate(chg_procedure_reply->qual[d.seq].update_dt_tm),cnvtdatetime(update_dt_tm
      ))
   PLAN (d
    WHERE (chg_procedure_reply->qual[d.seq].status=1))
    JOIN (t
    WHERE (t.procedure_id=chg_procedure_request->qual[d.seq].procedure_id))
   WITH nocounter, status(chg_procedure_reply->qual[d.seq].status)
  ;end update
 ENDIF
 SET nbr_correct = 0
 FOR (i = 1 TO chg_procedure_reply->qual_cnt)
   IF ((chg_procedure_reply->qual[i].status=1))
    SET nbr_correct += 1
   ELSE
    IF ((chg_procedure_reply->qual[i].status=0))
     SET chg_procedure_reply->qual[i].status = update_error
     IF ((chg_procedure_request->qual[i].allow_partial_ind != 1))
      SET failed = update_error
      SET nbr_correct = 0
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_correct=0)
  GO TO exit_script
 ENDIF
#exit_script
 IF (called_by_script_server=true)
  SET reply->qual_cnt = chg_procedure_reply->qual_cnt
  SET stat = alterlist(reply->qual,reply->qual_cnt)
  FOR (i = 1 TO reply->qual_cnt)
    SET reply->qual[i].status = chg_procedure_reply->qual[i].status
  ENDFOR
 ENDIF
#check_failed
 IF (failed=false)
  CASE (nbr_correct)
   OF 0:
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
   OF chg_procedure_reply->qual_cnt:
    SET reqinfo->commit_ind = true
    SET reply->status_data.status = "S"
   ELSE
    SET reqinfo->commit_ind = true
    SET reply->status_data.status = "P"
  ENDCASE
 ELSE
  CALL echorecord(chg_procedure_request)
  CALL echorecord(chg_procedure_reply)
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
