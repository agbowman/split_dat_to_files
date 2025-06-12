CREATE PROGRAM acm_add_procedure:dba
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
 IF ( NOT (validate(add_procedure_request)))
  SET failed = not_found
  SET table_name = "add_procedure_request was not defined by calling script"
  GO TO exit_script
 ENDIF
 IF ( NOT (validate(add_procedure_reply)))
  RECORD add_procedure_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 procedure_id = f8
      2 status = i4
      2 update_dt_tm = dq8
  )
 ENDIF
 DECLARE update_dt_tm = dq8 WITH protect, noconstant(0.0)
 SET table_name = "PROCEDURE"
 SET add_procedure_reply->qual_cnt = size(add_procedure_request->qual,5)
 SET stat = alterlist(add_procedure_reply->qual,add_procedure_reply->qual_cnt)
 IF ((add_procedure_reply->qual_cnt=0))
  SET failed = attribute_error
  SET table_name = "No procedures passed in"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO add_procedure_reply->qual_cnt)
   SET generic_ind = true
   IF ((add_procedure_request->qual[i].procedure_id=0))
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      add_procedure_reply->qual[i].procedure_id = nextseqnum, add_procedure_request->qual[i].
      procedure_id = nextseqnum
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET generic_ind = false
    ENDIF
   ELSE
    SET add_procedure_reply->qual[i].procedure_id = add_procedure_request->qual[i].procedure_id
   ENDIF
   IF ( NOT (generic_ind))
    SET add_procedure_reply->qual[i].status = gen_nbr_error
    SET failed = gen_nbr_error
    SET table_name = "Failed to generate a sequence number"
    GO TO exit_script
   ENDIF
 ENDFOR
 SET update_dt_tm = cnvtdatetime(sysdate)
 IF (checkdic("PROCEDURE.PROC_START_DT_TM","A",0) > 0
  AND checkdic("PROCEDURE.PROC_END_DT_TM","A",0) > 0
  AND validate(add_procedure_request->qual[1].proc_start_dt_tm)
  AND validate(add_procedure_request->qual[1].proc_end_dt_tm))
  INSERT  FROM procedure t,
    (dummyt d  WITH seq = value(add_procedure_reply->qual_cnt))
   SET t.procedure_id = add_procedure_request->qual[d.seq].procedure_id, t.updt_cnt = 0, t.updt_dt_tm
     = cnvtdatetime(update_dt_tm),
    t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
    updt_applctx,
    t.active_ind = add_procedure_request->qual[d.seq].active_ind, t.active_status_cd =
    IF ((add_procedure_request->qual[d.seq].active_status_cd > 0)) add_procedure_request->qual[d.seq]
     .active_status_cd
    ELSE
     IF ((add_procedure_request->qual[d.seq].active_ind=true)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
    ENDIF
    , t.active_status_dt_tm = cnvtdatetime(sysdate),
    t.active_status_prsnl_id = reqinfo->updt_id, t.beg_effective_dt_tm =
    IF ((add_procedure_request->qual[d.seq].beg_effective_dt_tm > 0)) cnvtdatetime(
      add_procedure_request->qual[d.seq].beg_effective_dt_tm)
    ELSE cnvtdatetime(sysdate)
    ENDIF
    , t.end_effective_dt_tm =
    IF ((add_procedure_request->qual[d.seq].end_effective_dt_tm > 0)) cnvtdatetime(
      add_procedure_request->qual[d.seq].end_effective_dt_tm)
    ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    ,
    t.contributor_system_cd =
    IF ((add_procedure_request->qual[d.seq].contributor_system_cd > 0)) add_procedure_request->qual[d
     .seq].contributor_system_cd
    ELSE reqdata->contributor_system_cd
    ENDIF
    , t.encntr_id = add_procedure_request->qual[d.seq].encntr_id, t.nomenclature_id =
    add_procedure_request->qual[d.seq].nomenclature_id,
    t.proc_dt_tm =
    IF ((add_procedure_request->qual[d.seq].proc_dt_tm > 0)) cnvtdatetime(add_procedure_request->
      qual[d.seq].proc_dt_tm)
    ELSE null
    ENDIF
    , t.proc_priority = add_procedure_request->qual[d.seq].proc_priority, t.proc_func_type_cd =
    add_procedure_request->qual[d.seq].proc_func_type_cd,
    t.proc_minutes = add_procedure_request->qual[d.seq].proc_minutes, t.consent_cd =
    add_procedure_request->qual[d.seq].consent_cd, t.diag_nomenclature_id = add_procedure_request->
    qual[d.seq].diag_nomenclature_id,
    t.reference_nbr = trim(add_procedure_request->qual[d.seq].reference_nbr), t.seg_unique_key = trim
    (add_procedure_request->qual[d.seq].seg_unique_key), t.mod_nomenclature_id =
    add_procedure_request->qual[d.seq].mod_nomenclature_id,
    t.anesthesia_cd = add_procedure_request->qual[d.seq].anesthesia_cd, t.anesthesia_minutes =
    add_procedure_request->qual[d.seq].anesthesia_minutes, t.tissue_type_cd = add_procedure_request->
    qual[d.seq].tissue_type_cd,
    t.svc_cat_hist_id = add_procedure_request->qual[d.seq].svc_cat_hist_id, t.proc_loc_cd =
    add_procedure_request->qual[d.seq].proc_loc_cd, t.proc_loc_ft_ind = add_procedure_request->qual[d
    .seq].proc_loc_ft_ind,
    t.proc_ft_loc = trim(add_procedure_request->qual[d.seq].proc_ft_loc), t.proc_ft_dt_tm_ind =
    add_procedure_request->qual[d.seq].proc_ft_dt_tm_ind, t.proc_ft_time_frame = trim(
     add_procedure_request->qual[d.seq].proc_ft_time_frame),
    t.comment_ind = add_procedure_request->qual[d.seq].comment_ind, t.long_text_id =
    add_procedure_request->qual[d.seq].long_text_id, t.proc_ftdesc = trim(add_procedure_request->
     qual[d.seq].proc_ftdesc),
    t.procedure_note = trim(add_procedure_request->qual[d.seq].procedure_note), t.generic_val_cd =
    add_procedure_request->qual[d.seq].generic_val_cd, t.ranking_cd = add_procedure_request->qual[d
    .seq].ranking_cd,
    t.clinical_service_cd = add_procedure_request->qual[d.seq].clinical_service_cd, t.dgvp_ind =
    add_procedure_request->qual[d.seq].dgvp_ind, t.encntr_slice_id = add_procedure_request->qual[d
    .seq].encntr_slice_id,
    t.proc_dt_tm_prec_cd = add_procedure_request->qual[d.seq].proc_dt_tm_prec_cd, t
    .proc_dt_tm_prec_flag = add_procedure_request->qual[d.seq].proc_dt_tm_prec_flag, t.proc_type_flag
     = add_procedure_request->qual[d.seq].proc_type_flag,
    t.suppress_narrative_ind = add_procedure_request->qual[d.seq].suppress_narrative_ind, t
    .laterality_cd = add_procedure_request->qual[d.seq].laterality_cd, t.proc_start_dt_tm =
    IF ((add_procedure_request->qual[d.seq].proc_start_dt_tm > 0)) cnvtdatetime(add_procedure_request
      ->qual[d.seq].proc_start_dt_tm)
    ELSE null
    ENDIF
    ,
    t.proc_end_dt_tm =
    IF ((add_procedure_request->qual[d.seq].proc_end_dt_tm > 0)) cnvtdatetime(add_procedure_request->
      qual[d.seq].proc_end_dt_tm)
    ELSE null
    ENDIF
    , stat = assign(validate(add_procedure_reply->qual[d.seq].update_dt_tm),cnvtdatetime(update_dt_tm
      ))
   PLAN (d)
    JOIN (t)
   WITH nocounter, status(add_procedure_reply->qual[d.seq].status)
  ;end insert
 ELSE
  INSERT  FROM procedure t,
    (dummyt d  WITH seq = value(add_procedure_reply->qual_cnt))
   SET t.procedure_id = add_procedure_request->qual[d.seq].procedure_id, t.updt_cnt = 0, t.updt_dt_tm
     = cnvtdatetime(update_dt_tm),
    t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
    updt_applctx,
    t.active_ind = add_procedure_request->qual[d.seq].active_ind, t.active_status_cd =
    IF ((add_procedure_request->qual[d.seq].active_status_cd > 0)) add_procedure_request->qual[d.seq]
     .active_status_cd
    ELSE
     IF ((add_procedure_request->qual[d.seq].active_ind=true)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
    ENDIF
    , t.active_status_dt_tm = cnvtdatetime(sysdate),
    t.active_status_prsnl_id = reqinfo->updt_id, t.beg_effective_dt_tm =
    IF ((add_procedure_request->qual[d.seq].beg_effective_dt_tm > 0)) cnvtdatetime(
      add_procedure_request->qual[d.seq].beg_effective_dt_tm)
    ELSE cnvtdatetime(sysdate)
    ENDIF
    , t.end_effective_dt_tm =
    IF ((add_procedure_request->qual[d.seq].end_effective_dt_tm > 0)) cnvtdatetime(
      add_procedure_request->qual[d.seq].end_effective_dt_tm)
    ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    ,
    t.contributor_system_cd =
    IF ((add_procedure_request->qual[d.seq].contributor_system_cd > 0)) add_procedure_request->qual[d
     .seq].contributor_system_cd
    ELSE reqdata->contributor_system_cd
    ENDIF
    , t.encntr_id = add_procedure_request->qual[d.seq].encntr_id, t.nomenclature_id =
    add_procedure_request->qual[d.seq].nomenclature_id,
    t.proc_dt_tm =
    IF ((add_procedure_request->qual[d.seq].proc_dt_tm > 0)) cnvtdatetime(add_procedure_request->
      qual[d.seq].proc_dt_tm)
    ELSE null
    ENDIF
    , t.proc_priority = add_procedure_request->qual[d.seq].proc_priority, t.proc_func_type_cd =
    add_procedure_request->qual[d.seq].proc_func_type_cd,
    t.proc_minutes = add_procedure_request->qual[d.seq].proc_minutes, t.consent_cd =
    add_procedure_request->qual[d.seq].consent_cd, t.diag_nomenclature_id = add_procedure_request->
    qual[d.seq].diag_nomenclature_id,
    t.reference_nbr = trim(add_procedure_request->qual[d.seq].reference_nbr), t.seg_unique_key = trim
    (add_procedure_request->qual[d.seq].seg_unique_key), t.mod_nomenclature_id =
    add_procedure_request->qual[d.seq].mod_nomenclature_id,
    t.anesthesia_cd = add_procedure_request->qual[d.seq].anesthesia_cd, t.anesthesia_minutes =
    add_procedure_request->qual[d.seq].anesthesia_minutes, t.tissue_type_cd = add_procedure_request->
    qual[d.seq].tissue_type_cd,
    t.svc_cat_hist_id = add_procedure_request->qual[d.seq].svc_cat_hist_id, t.proc_loc_cd =
    add_procedure_request->qual[d.seq].proc_loc_cd, t.proc_loc_ft_ind = add_procedure_request->qual[d
    .seq].proc_loc_ft_ind,
    t.proc_ft_loc = trim(add_procedure_request->qual[d.seq].proc_ft_loc), t.proc_ft_dt_tm_ind =
    add_procedure_request->qual[d.seq].proc_ft_dt_tm_ind, t.proc_ft_time_frame = trim(
     add_procedure_request->qual[d.seq].proc_ft_time_frame),
    t.comment_ind = add_procedure_request->qual[d.seq].comment_ind, t.long_text_id =
    add_procedure_request->qual[d.seq].long_text_id, t.proc_ftdesc = trim(add_procedure_request->
     qual[d.seq].proc_ftdesc),
    t.procedure_note = trim(add_procedure_request->qual[d.seq].procedure_note), t.generic_val_cd =
    add_procedure_request->qual[d.seq].generic_val_cd, t.ranking_cd = add_procedure_request->qual[d
    .seq].ranking_cd,
    t.clinical_service_cd = add_procedure_request->qual[d.seq].clinical_service_cd, t.dgvp_ind =
    add_procedure_request->qual[d.seq].dgvp_ind, t.encntr_slice_id = add_procedure_request->qual[d
    .seq].encntr_slice_id,
    t.proc_dt_tm_prec_cd = add_procedure_request->qual[d.seq].proc_dt_tm_prec_cd, t
    .proc_dt_tm_prec_flag = add_procedure_request->qual[d.seq].proc_dt_tm_prec_flag, t.proc_type_flag
     = add_procedure_request->qual[d.seq].proc_type_flag,
    t.suppress_narrative_ind = add_procedure_request->qual[d.seq].suppress_narrative_ind, t
    .laterality_cd = add_procedure_request->qual[d.seq].laterality_cd, stat = assign(validate(
      add_procedure_reply->qual[d.seq].update_dt_tm),cnvtdatetime(update_dt_tm))
   PLAN (d)
    JOIN (t)
   WITH nocounter, status(add_procedure_reply->qual[d.seq].status)
  ;end insert
 ENDIF
 FOR (i = 1 TO add_procedure_reply->qual_cnt)
   IF ((add_procedure_reply->qual[i].status=0))
    SET failed = insert_error
    SET add_procedure_reply->qual[i].status = insert_error
    IF (validate(add_procedure_reply->qual[i].update_dt_tm))
     SET add_procedure_reply->qual[i].update_dt_tm = 0
    ENDIF
    GO TO exit_script
   ENDIF
 ENDFOR
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
