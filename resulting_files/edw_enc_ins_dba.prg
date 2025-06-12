CREATE PROGRAM edw_enc_ins:dba
 DECLARE parser_line = vc WITH constant(build("BUILD(",value(encounter_nk),")"))
 DECLARE ins_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE priority_seq_cd = f8 WITH constant(edwgetcodevaluefromcdfmeaning(20790,"PRIORITY_SEQ")),
 protect
 DECLARE cv_ext_value = i4 WITH noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(large_batch_size)
 DECLARE parent_key_cnt = i4 WITH noconstant(0)
 IF (validate(pca_filter,0)=0)
  IF (ei_person_plan_reltn="Y")
   SELECT INTO "nl:"
    FROM person_plan_reltn ppr,
     encntr_plan_reltn epr,
     encounter
    PLAN (ppr
     WHERE ppr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
     JOIN (epr
     WHERE epr.person_plan_reltn_id=ppr.person_plan_reltn_id)
     JOIN (encounter
     WHERE encounter.encntr_id=epr.encntr_id
      AND parser(inst_filter)
      AND parser(org_filter))
    DETAIL
     ins_cnt = (ins_cnt+ 1)
     IF (mod(ins_cnt,10)=1)
      stat = alterlist(enc_ins_keys->qual,(ins_cnt+ 9))
     ENDIF
     enc_ins_keys->qual[ins_cnt].enc_insurance_sk = epr.encntr_plan_reltn_id
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM encntr_plan_reltn epr,
    encounter
   PLAN (epr
    WHERE epr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    JOIN (encounter
    WHERE encounter.encntr_id=epr.encntr_id
     AND parser(inst_filter)
     AND parser(org_filter))
   DETAIL
    ins_cnt = (ins_cnt+ 1)
    IF (mod(ins_cnt,10)=1)
     stat = alterlist(enc_ins_keys->qual,(ins_cnt+ 9))
    ENDIF
    enc_ins_keys->qual[ins_cnt].enc_insurance_sk = epr.encntr_plan_reltn_id
   FOOT REPORT
    stat = alterlist(enc_ins_keys->qual,ins_cnt)
   WITH nocounter
  ;end select
 ELSE
  SET ins_cnt = size(enc_ins_keys->qual,5)
 ENDIF
 IF (ins_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   encntrplan_id = enc_ins_keys->qual[d.seq].enc_insurance_sk
   FROM (dummyt d  WITH seq = value(ins_cnt))
   ORDER BY encntrplan_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), enc_ins_keys->qual[cnt].enc_insurance_sk = encntrplan_id
   FOOT REPORT
    ins_cnt = cnt, stat = alterlist(enc_ins_keys->qual,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.field_name="OPTION"
    AND cve.code_value=priority_seq_cd
   DETAIL
    cv_ext_value = cnvtint(cve.field_value)
   WITH nocounter
  ;end select
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),ins_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(enc_ins->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
    SET temp_indx = (temp_indx+ 1)
    SET enc_ins->qual[temp_indx].enc_insurance_sk = enc_ins_keys->qual[i].enc_insurance_sk
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(enc_ins->qual,new_list_size)
    FOR (i = temp_indx TO new_list_size)
      SET enc_ins->qual[i].enc_insurance_sk = enc_ins->qual[temp_indx].enc_insurance_sk
    ENDFOR
   ELSE
    SET cur_list_size = keys_batch
    SET loop_cnt = (cnvtreal(keys_batch)/ batch_size)
   ENDIF
   SET nstart = 1
   CALL echo(build("Encounter Health Insurance cnt :",ins_cnt))
   SELECT INTO "nl:"
    enc_nk = parser(parser_line), n_deduct_amt = nullind(epr.deduct_amt), n_deduct_met_amt = nullind(
     epr.deduct_met_amt),
    n_deduct_met_dt_tm = nullind(epr.deduct_met_dt_tm), n_fam_deduct_met_amt = nullind(ppr
     .fam_deduct_met_amt), n_ppr_deduct_amt = nullind(ppr.deduct_amt),
    n_ppr_deduct_met_amt = nullind(ppr.deduct_met_amt), n_insured_card_name = nullind(epr
     .insured_card_name), n_life_rsv_days = nullind(epr.life_rsv_days),
    n_life_rsv_daily_ded_amt = nullind(epr.life_rsv_daily_ded_amt), n_ppr_life_rsv_daily_ded_amt =
    nullind(ppr.life_rsv_daily_ded_amt), n_member_nbr = nullind(epr.member_nbr),
    n_policy_nbr = nullind(epr.policy_nbr), n_max_out_pckt_amt = nullind(ppr.max_out_pckt_amt),
    n_group_name = nullind(epr.group_name),
    n_group_nbr = nullind(epr.group_nbr), n_beg_effective_dt_tm = nullind(epr.beg_effective_dt_tm),
    n_end_effective_dt_tm = nullind(epr.end_effective_dt_tm)
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     encntr_plan_reltn epr,
     encounter,
     person_plan_reltn ppr,
     authorization auth,
     encntr_plan_auth_r epar
    PLAN (d)
     JOIN (epr
     WHERE (epr.encntr_plan_reltn_id=enc_ins->qual[d.seq].enc_insurance_sk))
     JOIN (encounter
     WHERE encounter.encntr_id=epr.encntr_id)
     JOIN (ppr
     WHERE ppr.person_plan_reltn_id=outerjoin(epr.person_plan_reltn_id)
      AND ppr.active_ind=outerjoin(1))
     JOIN (epar
     WHERE outerjoin(epr.encntr_plan_reltn_id)=epar.encntr_plan_reltn_id
      AND epar.active_ind=outerjoin(1)
      AND outerjoin(cnvtdatetime(curdate,curtime3)) >= epar.beg_effective_dt_tm
      AND outerjoin(cnvtdatetime(curdate,curtime3)) <= epar.end_effective_dt_tm)
     JOIN (auth
     WHERE outerjoin(epr.encntr_id)=auth.encntr_id
      AND outerjoin(epr.health_plan_id)=auth.health_plan_id
      AND auth.active_ind=outerjoin(1)
      AND auth.auth_type_cd > outerjoin(0)
      AND outerjoin(cnvtdatetime(curdate,curtime3)) >= auth.beg_effective_dt_tm
      AND outerjoin(cnvtdatetime(curdate,curtime3)) <= auth.end_effective_dt_tm)
    ORDER BY auth.beg_effective_dt_tm
    DETAIL
     parent_key_cnt = (parent_key_cnt+ 1)
     IF (mod(parent_key_cnt,10)=1)
      stat = alterlist(enc_ins_parent_keys->qual,(parent_key_cnt+ 9))
     ENDIF
     enc_ins_parent_keys->qual[parent_key_cnt].encounter_sk = encounter.encntr_id, enc_ins->qual[d
     .seq].loc_facility_cd = encounter.loc_facility_cd, enc_ins->qual[d.seq].encounter_nk = enc_nk,
     enc_ins->qual[d.seq].encounter_sk = encounter.encntr_id, enc_ins->qual[d.seq].insurance_hlthpln
      = epr.health_plan_id, enc_ins->qual[d.seq].assign_benefits_ref = epr.assign_benefits_cd,
     enc_ins->qual[d.seq].balance_type_ref = evaluate(epr.balance_type_cd,0.0,ppr.balance_type_cd,epr
      .balance_type_cd), enc_ins->qual[d.seq].card_category_ref = evaluate(epr.card_category_cd,0.0,
      ppr.card_category_cd,epr.card_category_cd), enc_ins->qual[d.seq].coordination_of_benefits_ref
      = epr.coord_benefits_cd,
     enc_ins->qual[d.seq].deduct_amt = evaluate(n_deduct_amt,1,evaluate(n_ppr_deduct_amt,0,trim(
        cnvtstring(ppr.deduct_amt,16,4))," "),trim(cnvtstring(epr.deduct_amt,16,4))), enc_ins->qual[d
     .seq].deduct_met_amt = evaluate(n_deduct_met_amt,1,evaluate(n_ppr_deduct_met_amt,0,trim(
        cnvtstring(ppr.deduct_met_amt,16,4))," "),trim(cnvtstring(epr.deduct_met_amt,16,4))), enc_ins
     ->qual[d.seq].deduct_met_dt_tm = evaluate(n_deduct_met_dt_tm,0,epr.deduct_met_dt_tm,ppr
      .deduct_met_dt_tm),
     enc_ins->qual[d.seq].family_deduct_met_amt = evaluate(n_fam_deduct_met_amt,0,trim(cnvtstring(ppr
        .fam_deduct_met_amt,16,4))," "), enc_ins->qual[d.seq].family_deduct_met_dt_tm = ppr
     .fam_deduct_met_dt_tm, enc_ins->qual[d.seq].denial_reason_ref = evaluate(epr.denial_reason_cd,
      0.0,ppr.denial_reason_cd,epr.denial_reason_cd),
     enc_ins->qual[d.seq].health_card_expire_dt_tm = epr.health_card_expiry_dt_tm, enc_ins->qual[d
     .seq].health_card_issue_dt_tm = epr.health_card_issue_dt_tm, enc_ins->qual[d.seq].
     health_card_nbr = epr.health_card_nbr,
     enc_ins->qual[d.seq].health_card_province = epr.health_card_province, enc_ins->qual[d.seq].
     health_card_type = epr.health_card_type, enc_ins->qual[d.seq].insurance_source_info_ref = epr
     .insur_source_info_cd,
     enc_ins->qual[d.seq].insured_card_name = evaluate(n_insured_card_name,1,ppr.insured_card_name,
      epr.insured_card_name), enc_ins->qual[d.seq].life_rsv_days = evaluate(n_life_rsv_days,1,ppr
      .life_rsv_days,epr.life_rsv_days), enc_ins->qual[d.seq].life_rsv_daily_ded_amt = evaluate(
      n_life_rsv_daily_ded_amt,1,evaluate(n_ppr_life_rsv_daily_ded_amt,0,trim(cnvtstring(ppr
         .life_rsv_daily_ded_amt,16,4))," "),evaluate(n_life_rsv_daily_ded_amt,0,trim(cnvtstring(epr
         .life_rsv_daily_ded_amt,16,4))," ")),
     enc_ins->qual[d.seq].life_rsv_daily_ded_qual_ref = evaluate(epr.life_rsv_daily_ded_qual_cd,0.0,
      ppr.life_rsv_daily_ded_qual_cd,epr.life_rsv_daily_ded_qual_cd), enc_ins->qual[d.seq].member_nbr
      = evaluate(n_member_nbr,1,ppr.member_nbr,epr.member_nbr), enc_ins->qual[d.seq].
     orig_priority_seq = ((epr.orig_priority_seq - cv_ext_value)+ 1),
     enc_ins->qual[d.seq].priority_seq = ((epr.priority_seq - cv_ext_value)+ 1), enc_ins->qual[d.seq]
     .plan_class_ref = evaluate(epr.plan_class_cd,0.0,ppr.plan_class_cd,epr.plan_class_cd), enc_ins->
     qual[d.seq].plan_type_ref = evaluate(epr.plan_type_cd,0.0,ppr.plan_type_cd,epr.plan_type_cd),
     enc_ins->qual[d.seq].policy_nbr = evaluate(n_policy_nbr,1,ppr.policy_nbr,epr.policy_nbr),
     enc_ins->qual[d.seq].program_status_ref = evaluate(epr.program_status_cd,0.0,ppr
      .program_status_cd,epr.program_status_cd), enc_ins->qual[d.seq].coverage_type_ref = ppr
     .coverage_type_cd,
     enc_ins->qual[d.seq].max_out_pocket_amt = evaluate(n_max_out_pckt_amt,0,trim(cnvtstring(ppr
        .max_out_pckt_amt,16,4))," "), enc_ins->qual[d.seq].max_out_pocket_dt_tm = ppr
     .max_out_pckt_dt_tm, enc_ins->qual[d.seq].verify_status_ref = evaluate(epr.verify_status_cd,0.0,
      ppr.verify_status_cd,epr.verify_status_cd),
     enc_ins->qual[d.seq].active_ind = epr.active_ind, enc_ins->qual[d.seq].group_name = evaluate(
      n_group_name,1,ppr.group_name,epr.group_name), enc_ins->qual[d.seq].group_nbr = evaluate(
      n_group_nbr,1,ppr.group_nbr,epr.group_nbr),
     enc_ins->qual[d.seq].organization_id = evaluate(epr.organization_id,0.0,ppr.organization_id,epr
      .organization_id), enc_ins->qual[d.seq].signature_on_file_cd = evaluate(epr
      .signature_on_file_cd,0.0,ppr.signature_on_file_cd,epr.signature_on_file_cd), enc_ins->qual[d
     .seq].src_beg_effective_dt_tm = evaluate(n_beg_effective_dt_tm,1,ppr.beg_effective_dt_tm,epr
      .beg_effective_dt_tm),
     enc_ins->qual[d.seq].src_end_effective_dt_tm = evaluate(n_end_effective_dt_tm,1,ppr
      .end_effective_dt_tm,epr.end_effective_dt_tm), enc_ins->qual[d.seq].auth_beg_dt_tm = auth
     .beg_effective_dt_tm, enc_ins->qual[d.seq].auth_end_dt_tm = auth.end_effective_dt_tm,
     enc_ins->qual[d.seq].auth_type_cd = auth.auth_type_cd, enc_ins->qual[d.seq].auth_nbr = auth
     .auth_nbr, enc_ins->qual[d.seq].auth_service_beg_dt_tm = auth.service_beg_dt_tm,
     enc_ins->qual[d.seq].auth_service_end_dt_tm = auth.service_end_dt_tm, enc_ins->qual[d.seq].
     subs_member_nbr = epr.subs_member_nbr, enc_ins->qual[d.seq].auth_required_ref = auth
     .auth_required_cd,
     enc_ins->qual[d.seq].subscriber_person_sk = ppr.subscriber_person_id, enc_ins->qual[d.seq].
     person_sk = encounter.person_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     encntr_benefit_r ebr
    PLAN (d)
     JOIN (ebr
     WHERE (ebr.encntr_plan_reltn_id=enc_ins->qual[d.seq].enc_insurance_sk)
      AND ebr.active_ind=1
      AND cnvtdatetime(curdate,curtime3) >= ebr.beg_effective_dt_tm
      AND cnvtdatetime(curdate,curtime3) <= ebr.end_effective_dt_tm)
    ORDER BY ebr.beg_effective_dt_tm
    HEAD ebr.encntr_plan_reltn_id
     enc_ins->qual[d.seq].benefit_deduct_amt = ebr.deduct_amt, enc_ins->qual[d.seq].benefit_copay_amt
      = ebr.copay_amt
    WITH nocounter
   ;end select
   FOR (i = 1 TO cur_list_size)
     SET timezone = gettimezone(enc_ins->qual[i].loc_facility_cd,enc_ins->qual[i].encounter_sk)
     SET enc_ins->qual[i].deduct_met_tm_zn = timezone
     SET enc_ins->qual[i].family_deduct_met_tm_zn = timezone
     SET enc_ins->qual[i].health_card_expire_tm_zn = timezone
     SET enc_ins->qual[i].health_card_issue_tm_zn = timezone
     SET enc_ins->qual[i].max_out_pocket_tm_zn = timezone
     SET enc_ins->qual[i].src_beg_effective_tm_zn = timezone
     SET enc_ins->qual[i].src_end_effective_tm_zn = timezone
     SET enc_ins->qual[i].auth_beg_tm_zn = timezone
     SET enc_ins->qual[i].auth_end_tm_zn = timezone
     IF (encounter_nk != default_encounter_nk)
      SET enc_ins->qual[i].encounter_nk = get_encounter_nk(enc_ins->qual[i].encounter_sk)
     ENDIF
   ENDFOR
   SELECT INTO value(enc_ins_extractfile)
    FROM (dummyt d  WITH seq = value(cur_list_size))
    DETAIL
     col 0,
     CALL print(trim(health_system_id)), v_bar,
     CALL print(trim(health_system_source_id)), v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].encounter_nk,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].encounter_sk,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].enc_insurance_sk,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].insurance_hlthpln,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].assign_benefits_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].balance_type_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].card_category_ref,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].coordination_of_benefits_ref,16))), v_bar,
     CALL print(trim(enc_ins->qual[d.seq].deduct_amt,3)), v_bar,
     CALL print(trim(enc_ins->qual[d.seq].deduct_met_amt,3)),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].deduct_met_dt_tm,0,
        cnvtdatetimeutc(enc_ins->qual[d.seq].deduct_met_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].deduct_met_tm_zn,16))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].deduct_met_dt_tm,cnvtint(enc_ins->
        qual[d.seq].deduct_met_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")),
     v_bar,
     CALL print(trim(enc_ins->qual[d.seq].family_deduct_met_amt,3)), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].
        family_deduct_met_dt_tm,0,cnvtdatetimeutc(enc_ins->qual[d.seq].family_deduct_met_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].family_deduct_met_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].family_deduct_met_dt_tm,cnvtint(
        enc_ins->qual[d.seq].family_deduct_met_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].denial_reason_ref,16))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].
        health_card_expire_dt_tm,0,cnvtdatetimeutc(enc_ins->qual[d.seq].health_card_expire_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].health_card_expire_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].health_card_expire_dt_tm,cnvtint(
        enc_ins->qual[d.seq].health_card_expire_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].
        health_card_issue_dt_tm,0,cnvtdatetimeutc(enc_ins->qual[d.seq].health_card_issue_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].health_card_issue_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].health_card_issue_dt_tm,cnvtint(
        enc_ins->qual[d.seq].health_card_issue_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].health_card_nbr,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].health_card_province,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].health_card_type,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].insurance_source_info_ref,16))),
     v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].insured_card_name,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].life_rsv_days,16))), v_bar,
     CALL print(trim(enc_ins->qual[d.seq].life_rsv_daily_ded_amt,3)),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].life_rsv_daily_ded_qual_ref,16))), v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].member_nbr,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].orig_priority_seq,16))),
     v_bar,
     CALL print(trim(evaluate(enc_ins->qual[d.seq].priority_seq,0,blank_field,cnvtstring(enc_ins->
        qual[d.seq].priority_seq,16)))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].plan_class_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].plan_type_ref,16))),
     v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].policy_nbr,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].program_status_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].coverage_type_ref,16))),
     v_bar,
     CALL print(trim(enc_ins->qual[d.seq].max_out_pocket_amt,3)), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].max_out_pocket_dt_tm,0,
        cnvtdatetimeutc(enc_ins->qual[d.seq].max_out_pocket_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].max_out_pocket_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].max_out_pocket_dt_tm,cnvtint(enc_ins
        ->qual[d.seq].max_out_pocket_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].verify_status_ref,16))), v_bar, "3",
     v_bar,
     CALL print(trim(extract_dt_tm_fmt)), v_bar,
     CALL print(build(enc_ins->qual[d.seq].active_ind)), v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].group_name,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].group_nbr,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].organization_id,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].signature_on_file_cd,16))),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].
        src_beg_effective_dt_tm,0,cnvtdatetimeutc(enc_ins->qual[d.seq].src_beg_effective_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].src_beg_effective_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].src_beg_effective_dt_tm,cnvtint(
        enc_ins->qual[d.seq].src_beg_effective_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].
        src_end_effective_dt_tm,0,cnvtdatetimeutc(enc_ins->qual[d.seq].src_end_effective_dt_tm,3)),
       utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].src_end_effective_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].src_end_effective_dt_tm,cnvtint(
        enc_ins->qual[d.seq].src_end_effective_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].auth_beg_dt_tm,0,
        cnvtdatetimeutc(enc_ins->qual[d.seq].auth_beg_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].auth_beg_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].auth_beg_dt_tm,cnvtint(enc_ins->
        qual[d.seq].auth_beg_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0"," ","0",
      "1")),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].auth_end_dt_tm,0,
        cnvtdatetimeutc(enc_ins->qual[d.seq].auth_end_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].auth_end_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_ins->qual[d.seq].auth_end_dt_tm,cnvtint(enc_ins->
        qual[d.seq].auth_end_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0"," ","0",
      "1")),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].auth_type_cd,16))), v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].auth_nbr,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].auth_service_beg_dt_tm,
        0,cnvtdatetimeutc(enc_ins->qual[d.seq].auth_service_beg_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_ins->qual[d.seq].auth_service_end_dt_tm,
        0,cnvtdatetimeutc(enc_ins->qual[d.seq].auth_service_end_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(replace(enc_ins->qual[d.seq].subs_member_nbr,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].benefit_deduct_amt,16,4))),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].benefit_copay_amt,16,4))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].auth_required_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].subscriber_person_sk,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_ins->qual[d.seq].person_sk,16))), v_bar,
     row + 1
    WITH check, noheading, nocounter,
     format = lfstream, maxcol = 1999, maxrow = 1,
     append
   ;end select
   IF (validate(pca_filter,0)=1)
    CALL parser(pca_getref)
   ENDIF
   SET stat = alterlist(enc_ins->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),ins_cnt)
 ENDWHILE
 IF (ins_cnt=0)
  SELECT INTO value(enc_ins_extractfile)
   FROM dummyt
   WHERE ins_cnt > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD enc_ins
 FREE RECORD enc_ins_keys
 CALL edwupdatescriptstatus("ENC_INS",ins_cnt,"19","19")
 CALL echo(build("ENC_INS Count = ",ins_cnt))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "021 08/10/22 ap086433"
END GO
