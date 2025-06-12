CREATE PROGRAM acm_chg_encntr_plan_reltn:dba
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
 DECLARE t1 = i4 WITH noconstant(0), protect
 DECLARE t2 = i4 WITH noconstant(0), protect
 DECLARE max_val = i4 WITH noconstant(200), protect
 DECLARE t_val = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE f_val = i4 WITH noconstant(1), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE chg_cnt = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE active_status_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_status_dt_tm = f8 WITH protect, noconstant(0.0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->encntr_plan_reltn_qual[xref->chg[index].idx].status = 0
 ENDFOR
 IF (t_val <= max_val)
  SET max_val = t_val
  CALL getexistingrows(max_val)
 ELSE
  SET t_val = max_val
  WHILE (chg_cnt > 0)
    CALL getexistingrows(max_val)
    SET chg_cnt -= max_val
    SET f_val = (t_val+ 1)
    IF (chg_cnt > max_val)
     SET t_val += max_val
    ELSE
     SET t_val += chg_cnt
    ENDIF
  ENDWHILE
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(xref->chg_cnt)),
   encntr_plan_reltn e
  SET e.encntr_plan_reltn_id = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   encntr_plan_reltn_id, e.assign_benefits_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].
   idx].assign_benefits_cd, e.beg_effective_dt_tm = cnvtdatetime(acm_request->encntr_plan_reltn_qual[
    xref->chg[d.seq].idx].beg_effective_dt_tm),
   e.card_category_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].card_category_cd, e
   .contributor_system_cd =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].contributor_system_cd > 0.0))
    acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   , e.coord_benefits_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   coord_benefits_cd,
   e.coverage_comments_long_text_id = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   coverage_comments_long_text_id, e.deduct_amt = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq
   ].idx].deduct_amt, e.deduct_met_amt = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   deduct_met_amt,
   e.deduct_met_dt_tm =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].deduct_met_dt_tm > 0)) cnvtdatetime
    (acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].deduct_met_dt_tm)
   ELSE null
   ENDIF
   , e.denial_reason_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].denial_reason_cd,
   e.encntr_id =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].encntr_id > 0)) acm_request->
    encntr_plan_reltn_qual[xref->chg[d.seq].idx].encntr_id
   ELSE reply->encounter_qual[acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].encntr_idx].
    encntr_id
   ENDIF
   ,
   e.end_effective_dt_tm = cnvtdatetime(acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
    end_effective_dt_tm), e.group_name = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   group_name, e.group_nbr = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].group_nbr,
   e.health_card_expiry_dt_tm =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_card_expiry_dt_tm > 0))
    cnvtdatetime(acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_card_expiry_dt_tm)
   ELSE null
   ENDIF
   , e.health_card_issue_dt_tm =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_card_issue_dt_tm > 0))
    cnvtdatetime(acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_card_issue_dt_tm)
   ELSE null
   ENDIF
   , e.health_card_nbr = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_card_nbr,
   e.health_card_province = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   health_card_province, e.health_card_type = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].
   idx].health_card_type, e.health_card_ver_code = acm_request->encntr_plan_reltn_qual[xref->chg[d
   .seq].idx].health_card_ver_code,
   e.health_plan_id =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_plan_id > 0)) acm_request->
    encntr_plan_reltn_qual[xref->chg[d.seq].idx].health_plan_id
   ELSE reply->health_plan_qual[acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
    health_plan_idx].health_plan_id
   ENDIF
   , e.insured_card_name = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   insured_card_name, e.insur_source_info_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].
   idx].insur_source_info_cd,
   e.ins_card_copied_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   ins_card_copied_cd, e.life_rsv_daily_ded_amt = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq
   ].idx].life_rsv_daily_ded_amt, e.life_rsv_daily_ded_qual_cd = acm_request->encntr_plan_reltn_qual[
   xref->chg[d.seq].idx].life_rsv_daily_ded_qual_cd,
   e.life_rsv_days = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].life_rsv_days, e
   .life_rsv_remain_days = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   life_rsv_remain_days, e.member_nbr = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   member_nbr,
   e.member_person_code = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   member_person_code, e.military_base_location = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq
   ].idx].military_base_location, e.military_rank_cd = acm_request->encntr_plan_reltn_qual[xref->chg[
   d.seq].idx].military_rank_cd,
   e.military_service_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   military_service_cd, e.military_status_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].
   idx].military_status_cd, e.organization_id = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].
   idx].organization_id,
   e.orig_priority_seq = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].orig_priority_seq,
   e.person_id =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_id > 0)) acm_request->
    encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_id
   ELSE reply->person_qual[acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_idx].
    person_id
   ENDIF
   , e.person_org_reltn_id =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_org_reltn_id > 0))
    acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_org_reltn_id
   ELSE reply->person_org_reltn_qual[acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
    person_org_reltn_idx].person_org_reltn_id
   ENDIF
   ,
   e.person_plan_reltn_id =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_plan_reltn_id > 0))
    acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].person_plan_reltn_id
   ELSE reply->person_plan_reltn_qual[acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
    person_plan_reltn_idx].person_plan_reltn_id
   ENDIF
   , e.plan_class_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].plan_class_cd, e
   .plan_type_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].plan_type_cd,
   e.policy_nbr = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].policy_nbr, e
   .priority_seq = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].priority_seq, e
   .program_status_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].program_status_cd,
   e.sponsor_person_org_reltn_id = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   sponsor_person_org_reltn_id, e.subscriber_type_cd = acm_request->encntr_plan_reltn_qual[xref->chg[
   d.seq].idx].subscriber_type_cd, e.subs_member_nbr = acm_request->encntr_plan_reltn_qual[xref->chg[
   d.seq].idx].subs_member_nbr,
   e.verify_dt_tm =
   IF ((acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].verify_dt_tm > 0)) cnvtdatetime(
     acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].verify_dt_tm)
   ELSE null
   ENDIF
   , e.verify_prsnl_id = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].verify_prsnl_id, e
   .verify_status_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].verify_status_cd,
   e.active_ind = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].active_ind, e
   .active_status_cd = acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].active_status_cd, e
   .active_status_prsnl_id = active_status_prsnl_id,
   e.active_status_dt_tm = cnvtdatetime(active_status_dt_tm), e.updt_cnt = (e.updt_cnt+ 1), e
   .updt_dt_tm = cnvtdatetime(sysdate),
   e.updt_id = reqinfo->updt_id, e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->
   updt_task
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_plan_reltn_id=acm_request->encntr_plan_reltn_qual[xref->chg[d.seq].idx].
   encntr_plan_reltn_id))
  WITH nocounter, status(reply->encntr_plan_reltn_qual[xref->chg[d.seq].idx].status)
 ;end update
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->encntr_plan_reltn_qual[xref->chg[index].idx].status != 1))
    SET failed = update_error
    SET table_name = "ENCNTR_PLAN_RELTN"
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE getexistingrows(x)
   SELECT INTO "nl:"
    FROM encntr_plan_reltn e
    WHERE expand(t1,f_val,t_val,e.encntr_plan_reltn_id,acm_request->encntr_plan_reltn_qual[xref->chg[
     t1].idx].encntr_plan_reltn_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,e.encntr_plan_reltn_id,acm_request->encntr_plan_reltn_qual[xref->
      chg[t1].idx].encntr_plan_reltn_id,
      max_val), idx = xref->chg[t2].idx
     IF ((((e.updt_cnt=acm_request->encntr_plan_reltn_qual[idx].updt_cnt)) OR ((acm_request->
     force_updt_ind=1))) )
      reply->encntr_plan_reltn_qual[idx].status = - (1), reply->encntr_plan_reltn_qual[idx].
      encntr_plan_reltn_id = acm_request->encntr_plan_reltn_qual[idx].encntr_plan_reltn_id
     ELSE
      failed = update_cnt_error
     ENDIF
     chg_str = acm_request->encntr_plan_reltn_qual[idx].chg_str
     IF (findstring("ASSIGN_BENEFITS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].assign_benefits_cd = e.assign_benefits_cd
     ENDIF
     IF (findstring("BEG_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].beg_effective_dt_tm = e.beg_effective_dt_tm
     ENDIF
     IF (findstring("CARD_CATEGORY_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].card_category_cd = e.card_category_cd
     ENDIF
     IF (findstring("CONTRIBUTOR_SYSTEM_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].contributor_system_cd = e.contributor_system_cd
     ENDIF
     IF (findstring("COORD_BENEFITS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].coord_benefits_cd = e.coord_benefits_cd
     ENDIF
     IF (findstring("COVERAGE_COMMENTS_LONG_TEXT_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].coverage_comments_long_text_id = e
      .coverage_comments_long_text_id
     ENDIF
     IF (findstring("DEDUCT_AMT,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].deduct_amt = e.deduct_amt
     ENDIF
     IF (findstring("DEDUCT_MET_AMT,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].deduct_met_amt = e.deduct_met_amt
     ENDIF
     IF (findstring("DEDUCT_MET_DT_TM,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].deduct_met_dt_tm = e.deduct_met_dt_tm
     ENDIF
     IF (findstring("DENIAL_REASON_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].denial_reason_cd = e.denial_reason_cd
     ENDIF
     IF (findstring("ENCNTR_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].encntr_id = e.encntr_id
     ENDIF
     IF (findstring("END_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].end_effective_dt_tm = e.end_effective_dt_tm
     ENDIF
     IF (findstring("GROUP_NAME,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].group_name = e.group_name
     ENDIF
     IF (findstring("GROUP_NBR,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].group_nbr = e.group_nbr
     ENDIF
     IF (findstring("HEALTH_CARD_EXPIRY_DT_TM,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_card_expiry_dt_tm = e.health_card_expiry_dt_tm
     ENDIF
     IF (findstring("HEALTH_CARD_ISSUE_DT_TM,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_card_issue_dt_tm = e.health_card_issue_dt_tm
     ENDIF
     IF (findstring("HEALTH_CARD_NBR,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_card_nbr = e.health_card_nbr
     ENDIF
     IF (findstring("HEALTH_CARD_PROVINCE,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_card_province = e.health_card_province
     ENDIF
     IF (findstring("HEALTH_CARD_TYPE,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_card_type = e.health_card_type
     ENDIF
     IF (findstring("HEALTH_CARD_VER_CODE,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_card_ver_code = e.health_card_ver_code
     ENDIF
     IF (findstring("HEALTH_PLAN_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].health_plan_id = e.health_plan_id
     ENDIF
     IF (findstring("INSURED_CARD_NAME,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].insured_card_name = e.insured_card_name
     ENDIF
     IF (findstring("INSUR_SOURCE_INFO_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].insur_source_info_cd = e.insur_source_info_cd
     ENDIF
     IF (findstring("INS_CARD_COPIED_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].ins_card_copied_cd = e.ins_card_copied_cd
     ENDIF
     IF (findstring("LIFE_RSV_DAILY_DED_AMT,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].life_rsv_daily_ded_amt = e.life_rsv_daily_ded_amt
     ENDIF
     IF (findstring("LIFE_RSV_DAILY_DED_QUAL_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].life_rsv_daily_ded_qual_cd = e
      .life_rsv_daily_ded_qual_cd
     ENDIF
     IF (findstring("LIFE_RSV_DAYS,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].life_rsv_days = e.life_rsv_days
     ENDIF
     IF (findstring("LIFE_RSV_REMAIN_DAYS,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].life_rsv_remain_days = e.life_rsv_remain_days
     ENDIF
     IF (findstring("MEMBER_NBR,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].member_nbr = e.member_nbr
     ENDIF
     IF (findstring("MEMBER_PERSON_CODE,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].member_person_code = e.member_person_code
     ENDIF
     IF (findstring("MILITARY_BASE_LOCATION,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].military_base_location = e.military_base_location
     ENDIF
     IF (findstring("MILITARY_RANK_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].military_rank_cd = e.military_rank_cd
     ENDIF
     IF (findstring("MILITARY_SERVICE_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].military_service_cd = e.military_service_cd
     ENDIF
     IF (findstring("MILITARY_STATUS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].military_status_cd = e.military_status_cd
     ENDIF
     IF (findstring("ORGANIZATION_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].organization_id = e.organization_id
     ENDIF
     IF (findstring("ORIG_PRIORITY_SEQ,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].orig_priority_seq = e.orig_priority_seq
     ENDIF
     IF (findstring("PERSON_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].person_id = e.person_id
     ENDIF
     IF (findstring("PERSON_ORG_RELTN_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].person_org_reltn_id = e.person_org_reltn_id
     ENDIF
     IF (findstring("PERSON_PLAN_RELTN_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].person_plan_reltn_id = e.person_plan_reltn_id
     ENDIF
     IF (findstring("PLAN_CLASS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].plan_class_cd = e.plan_class_cd
     ENDIF
     IF (findstring("PLAN_TYPE_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].plan_type_cd = e.plan_type_cd
     ENDIF
     IF (findstring("POLICY_NBR,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].policy_nbr = e.policy_nbr
     ENDIF
     IF (findstring("PRIORITY_SEQ,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].priority_seq = e.priority_seq
     ENDIF
     IF (findstring("PROGRAM_STATUS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].program_status_cd = e.program_status_cd
     ENDIF
     IF (findstring("SPONSOR_PERSON_ORG_RELTN_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].sponsor_person_org_reltn_id = e
      .sponsor_person_org_reltn_id
     ENDIF
     IF (findstring("SUBSCRIBER_TYPE_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].subscriber_type_cd = e.subscriber_type_cd
     ENDIF
     IF (findstring("SUBS_MEMBER_NBR,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].subs_member_nbr = e.subs_member_nbr
     ENDIF
     IF (findstring("VERIFY_DT_TM,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].verify_dt_tm = e.verify_dt_tm
     ENDIF
     IF (findstring("VERIFY_PRSNL_ID,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].verify_prsnl_id = e.verify_prsnl_id
     ENDIF
     IF (findstring("VERIFY_STATUS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].verify_status_cd = e.verify_status_cd
     ENDIF
     IF (findstring("ACTIVE_IND,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].active_ind = e.active_ind
     ENDIF
     IF (findstring("ACTIVE_STATUS_CD,",chg_str)=0)
      acm_request->encntr_plan_reltn_qual[idx].active_status_cd = e.active_status_cd
     ENDIF
     IF (((findstring("ACTIVE_IND,",chg_str) != 0) OR (findstring("ACTIVE_STATUS_CD,",chg_str) != 0
     )) )
      active_status_prsnl_id = reqinfo->updt_id, active_status_dt_tm = cnvtdatetime(sysdate)
     ELSE
      active_status_prsnl_id = e.active_status_prsnl_id, active_status_dt_tm = cnvtdatetime(e
       .active_status_dt_tm)
     ENDIF
    WITH nocounter, forupdatewait(e), time = 5
   ;end select
   IF (failed)
    SET table_name = "ENCNTR_PLAN_RELTN"
    GO TO exit_script
   ENDIF
   FOR (index = f_val TO t_val)
     IF ((reply->encntr_plan_reltn_qual[xref->chg[index].idx].status=0))
      SET failed = select_error
      SET table_name = "ENCNTR_PLAN_RELTN"
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
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
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
