CREATE PROGRAM acm_chg_encntr_hist:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
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
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 FREE RECORD temp_record
 RECORD temp_record(
   1 encntr_hist_qual[*]
     2 encntr_flex_hist_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 person_id = f8
     2 placement_auth_prsnl_id = f8
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 mental_health_cd = f8
     2 mental_health_dt_tm = dq8
     2 admit_src_cd = f8
     2 admit_mode_cd = f8
     2 disch_disposition_cd = f8
     2 disch_dt_tm = dq8
     2 disch_to_loctn_cd = f8
     2 encntr_status_cd = f8
     2 reg_dt_tm = dq8
     2 trauma_cd = f8
     2 trauma_dt_tm = dq8
     2 triage_cd = f8
     2 triage_dt_tm = dq8
     2 patient_classification_cd = f8
     2 mental_category_cd = f8
     2 psychiatric_status_cd = f8
     2 inpatient_admit_dt_tm = dq8
     2 loc_temp_cd = f8
     2 change_bit = i4
     2 item_idx = i4
 )
 DECLARE chgbit = i4 WITH noconstant(0)
 DECLARE tracking_bit = i4 WITH noconstant(262143)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->encounter_qual[xref->chg[index].idx].status = 0
 ENDFOR
 SET stat = alterlist(temp_record->encntr_hist_qual,xref->chg_cnt)
 SET efh_qual_cntr = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(xref->chg_cnt))
  PLAN (d)
  DETAIL
   item_idx = xref->chg[d.seq].idx, chg_str = acm_request->encounter_qual[item_idx].chg_str, chgbit
    = 0
   IF (findstring("MENTAL_HEALTH_CD,",chg_str) != 0)
    chgbit = bor(1,chgbit)
   ENDIF
   IF (findstring("MENTAL_HEALTH_DT_TM,",chg_str) != 0)
    chgbit = bor(2,chgbit)
   ENDIF
   IF (findstring("ADMIT_SRC_CD,",chg_str) != 0)
    chgbit = bor(4,chgbit)
   ENDIF
   IF (findstring("ADMIT_MODE_CD,",chg_str) != 0)
    chgbit = bor(8,chgbit)
   ENDIF
   IF (findstring("DISCH_DISPOSITION_CD,",chg_str) != 0)
    chgbit = bor(16,chgbit)
   ENDIF
   IF (findstring("DISCH_DT_TM,",chg_str) != 0)
    chgbit = bor(32,chgbit)
   ENDIF
   IF (findstring("DISCH_TO_LOCTN_CD,",chg_str) != 0)
    chgbit = bor(64,chgbit)
   ENDIF
   IF (findstring("ENCNTR_STATUS_CD,",chg_str) != 0)
    chgbit = bor(128,chgbit)
   ENDIF
   IF (findstring("REG_DT_TM,",chg_str) != 0)
    chgbit = bor(256,chgbit)
   ENDIF
   IF (findstring("TRAUMA_CD,",chg_str) != 0)
    chgbit = bor(512,chgbit)
   ENDIF
   IF (findstring("TRAUMA_DT_TM,",chg_str) != 0)
    chgbit = bor(1024,chgbit)
   ENDIF
   IF (findstring("TRIAGE_CD,",chg_str) != 0)
    chgbit = bor(2048,chgbit)
   ENDIF
   IF (findstring("TRIAGE_DT_TM,",chg_str) != 0)
    chgbit = bor(4096,chgbit)
   ENDIF
   IF (findstring("PATIENT_CLASSIFICATION_CD,",chg_str) != 0)
    chgbit = bor(8192,chgbit)
   ENDIF
   IF (findstring("MENTAL_CATEGORY_CD,",chg_str) != 0)
    chgbit = bor(16384,chgbit)
   ENDIF
   IF (findstring("PSYCHIATRIC_STATUS_CD,",chg_str) != 0)
    chgbit = bor(32768,chgbit)
   ENDIF
   IF (findstring("INPATIENT_ADMIT_DT_TM,",chg_str) != 0)
    chgbit = bor(65536,chgbit)
   ENDIF
   IF (findstring("LOC_TEMP_CD,",chg_str) != 0)
    chgbit = bor(131072,chgbit)
   ENDIF
   IF (chgbit > 0)
    efh_qual_cntr = (efh_qual_cntr+ 1), temp_record->encntr_hist_qual[efh_qual_cntr].change_bit =
    chgbit, temp_record->encntr_hist_qual[efh_qual_cntr].item_idx = item_idx,
    temp_record->encntr_hist_qual[efh_qual_cntr].encntr_id = acm_request->encounter_qual[item_idx].
    encntr_id, temp_record->encntr_hist_qual[efh_qual_cntr].organization_id = acm_request->
    encounter_qual[item_idx].organization_id, temp_record->encntr_hist_qual[efh_qual_cntr].person_id
     = acm_request->encounter_qual[item_idx].person_id,
    temp_record->encntr_hist_qual[efh_qual_cntr].placement_auth_prsnl_id = acm_request->
    encounter_qual[item_idx].placement_auth_prsnl_id, temp_record->encntr_hist_qual[efh_qual_cntr].
    pm_hist_tracking_id = acm_request->encounter_qual[item_idx].pm_hist_tracking_id, temp_record->
    encntr_hist_qual[efh_qual_cntr].transaction_dt_tm = acm_request->encounter_qual[item_idx].
    transaction_dt_tm,
    temp_record->encntr_hist_qual[efh_qual_cntr].mental_health_cd = acm_request->encounter_qual[
    item_idx].mental_health_cd, temp_record->encntr_hist_qual[efh_qual_cntr].mental_health_dt_tm =
    acm_request->encounter_qual[item_idx].mental_health_dt_tm, temp_record->encntr_hist_qual[
    efh_qual_cntr].admit_src_cd = acm_request->encounter_qual[item_idx].admit_src_cd,
    temp_record->encntr_hist_qual[efh_qual_cntr].admit_mode_cd = acm_request->encounter_qual[item_idx
    ].admit_mode_cd, temp_record->encntr_hist_qual[efh_qual_cntr].disch_disposition_cd = acm_request
    ->encounter_qual[item_idx].disch_disposition_cd, temp_record->encntr_hist_qual[efh_qual_cntr].
    disch_dt_tm = acm_request->encounter_qual[item_idx].disch_dt_tm,
    temp_record->encntr_hist_qual[efh_qual_cntr].disch_to_loctn_cd = acm_request->encounter_qual[
    item_idx].disch_to_loctn_cd, temp_record->encntr_hist_qual[efh_qual_cntr].encntr_status_cd =
    acm_request->encounter_qual[item_idx].encntr_status_cd, temp_record->encntr_hist_qual[
    efh_qual_cntr].reg_dt_tm = acm_request->encounter_qual[item_idx].reg_dt_tm,
    temp_record->encntr_hist_qual[efh_qual_cntr].trauma_cd = acm_request->encounter_qual[item_idx].
    trauma_cd, temp_record->encntr_hist_qual[efh_qual_cntr].trauma_dt_tm = acm_request->
    encounter_qual[item_idx].trauma_dt_tm, temp_record->encntr_hist_qual[efh_qual_cntr].triage_cd =
    acm_request->encounter_qual[item_idx].triage_cd,
    temp_record->encntr_hist_qual[efh_qual_cntr].triage_dt_tm = acm_request->encounter_qual[item_idx]
    .triage_dt_tm, temp_record->encntr_hist_qual[efh_qual_cntr].patient_classification_cd =
    acm_request->encounter_qual[item_idx].patient_classification_cd, temp_record->encntr_hist_qual[
    efh_qual_cntr].mental_category_cd = acm_request->encounter_qual[item_idx].mental_category_cd,
    temp_record->encntr_hist_qual[efh_qual_cntr].psychiatric_status_cd = acm_request->encounter_qual[
    item_idx].psychiatric_status_cd, temp_record->encntr_hist_qual[efh_qual_cntr].
    inpatient_admit_dt_tm = acm_request->encounter_qual[item_idx].inpatient_admit_dt_tm, temp_record
    ->encntr_hist_qual[efh_qual_cntr].loc_temp_cd = acm_request->encounter_qual[item_idx].loc_temp_cd
   ELSE
    reply->encounter_qual[item_idx].status = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_record->encntr_hist_qual,efh_qual_cntr)
 IF (efh_qual_cntr > 0)
  INSERT  FROM encntr_flex_hist efh,
    (dummyt d  WITH seq = value(efh_qual_cntr))
   SET efh.encntr_flex_hist_id = seq(encounter_seq,nextval), efh.encntr_id = temp_record->
    encntr_hist_qual[d.seq].encntr_id, efh.organization_id = temp_record->encntr_hist_qual[d.seq].
    organization_id,
    efh.person_id = temp_record->encntr_hist_qual[d.seq].person_id, efh.placement_auth_prsnl_id =
    temp_record->encntr_hist_qual[d.seq].placement_auth_prsnl_id, efh.pm_hist_tracking_id =
    temp_record->encntr_hist_qual[d.seq].pm_hist_tracking_id,
    efh.transaction_dt_tm = cnvtdatetime(temp_record->encntr_hist_qual[d.seq].transaction_dt_tm), efh
    .mental_health_cd = temp_record->encntr_hist_qual[d.seq].mental_health_cd, efh
    .mental_health_dt_tm = cnvtdatetime(temp_record->encntr_hist_qual[d.seq].mental_health_dt_tm),
    efh.admit_src_cd = temp_record->encntr_hist_qual[d.seq].admit_src_cd, efh.admit_mode_cd =
    temp_record->encntr_hist_qual[d.seq].admit_mode_cd, efh.disch_disposition_cd = temp_record->
    encntr_hist_qual[d.seq].disch_disposition_cd,
    efh.disch_dt_tm = cnvtdatetime(temp_record->encntr_hist_qual[d.seq].disch_dt_tm), efh
    .disch_to_loctn_cd = temp_record->encntr_hist_qual[d.seq].disch_to_loctn_cd, efh.encntr_status_cd
     = temp_record->encntr_hist_qual[d.seq].encntr_status_cd,
    efh.reg_dt_tm = cnvtdatetime(temp_record->encntr_hist_qual[d.seq].reg_dt_tm), efh.trauma_cd =
    temp_record->encntr_hist_qual[d.seq].trauma_cd, efh.trauma_dt_tm = cnvtdatetime(temp_record->
     encntr_hist_qual[d.seq].trauma_dt_tm),
    efh.triage_cd = temp_record->encntr_hist_qual[d.seq].triage_cd, efh.triage_dt_tm = cnvtdatetime(
     temp_record->encntr_hist_qual[d.seq].triage_dt_tm), efh.patient_classification_cd = temp_record
    ->encntr_hist_qual[d.seq].patient_classification_cd,
    efh.mental_category_cd = temp_record->encntr_hist_qual[d.seq].mental_category_cd, efh
    .psychiatric_status_cd = temp_record->encntr_hist_qual[d.seq].psychiatric_status_cd, efh
    .inpatient_admit_dt_tm = cnvtdatetime(temp_record->encntr_hist_qual[d.seq].inpatient_admit_dt_tm),
    efh.loc_temp_cd = temp_record->encntr_hist_qual[d.seq].loc_temp_cd, efh.tracking_bit =
    tracking_bit, efh.change_bit = temp_record->encntr_hist_qual[d.seq].change_bit,
    efh.active_ind = 1, efh.active_status_cd = reqdata->active_status_cd, efh.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    efh.active_status_prsnl_id = reqinfo->updt_id, efh.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    efh.updt_id = reqinfo->updt_id,
    efh.updt_applctx = reqinfo->updt_applctx, efh.updt_task = reqinfo->updt_task, efh.updt_cnt =
    updt_cnt
   PLAN (d)
    JOIN (efh)
   WITH nocounter, status(reply->encounter_qual[temp_record->encntr_hist_qual[d.seq].item_idx].status
    )
  ;end insert
 ENDIF
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->encounter_qual[xref->chg[index].idx].status=0))
    SET failed = insert_error
    SET table_name = "ENCNTR_FLEX_HIST"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
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
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
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
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
