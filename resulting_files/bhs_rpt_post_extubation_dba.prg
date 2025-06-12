CREATE PROGRAM bhs_rpt_post_extubation:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, s_begin_date, s_end_date,
  s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_performed_dt_tm = vc
     2 s_intubated_dt_tm = vc
     2 s_extubated_dt_tm = vc
     2 s_glasgow_coma_score = vc
     2 s_1tsp_of_applesauce = vc
     2 s_5mlor1tsp_of_water = vc
     2 s_sips_h2o = vc
     2 s_swallow_eval_calc = vc
     2 s_condition1_reassess = vc
     2 s_condition2_reassess = vc
     2 s_condition1 = vc
     2 s_condition2 = vc
     2 s_condition2_equation = vc
     2 s_exclusion_criteria = vc
     2 s_keep_npo = vc
     2 s_proceed_to_step1 = vc
     2 s_proceed_to_step2 = vc
     2 s_proceed_to_step3 = vc
     2 s_risk_factors = vc
     2 s_risk_factors_score = vc
     2 s_step2_readiness = vc
     2 s_step2_reassess = vc
     2 s_volitional_swallow = vc
     2 s_wait_reassess_dt_tm = vc
     2 s_diet_after_consult = vc
     2 s_tot_intubation_time = vc
 ) WITH protect
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_swallowscreenform_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUPOSTEXTUBATIONSWALLOWSCREENFORM"))
 DECLARE mf_dcpgenericcode_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE mf_glasgowcomascore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GLASGOWCOMASCORE"))
 DECLARE mf_datetimeintubated_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEINTUBATED"))
 DECLARE mf_datetimeextubated_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEEXTUBATED"))
 DECLARE mf_totintubationtime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TOTALINTUBATIONTIME"))
 DECLARE mf_exclusioncriteria_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALEXCLUSIONCRITERIA"))
 DECLARE mf_evalkeepnpo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALKEEPNPO"))
 DECLARE mf_riskfactors_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALRISKFACTORS"))
 DECLARE mf_riskfactorsscore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALRISKFACTORSSCORE"))
 DECLARE mf_proceedtostep2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALPROCEEDTOSTEP2"))
 DECLARE mf_waitreassessdttm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALWAITREASSESSDATETIME"))
 DECLARE mf_condition1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALCONDITION1"))
 DECLARE mf_condition2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALCONDITION2"))
 DECLARE mf_proceedtostep3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALPROCEEDTOSTEP3"))
 DECLARE mf_volitionalswallow_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALVOLITIONALSWALLOW"))
 DECLARE mf_5mlor1tspofwater_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVAL5MLOR1TSPOFWATER"))
 DECLARE mf_1tspofapplesauce_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVAL1TSPOFAPPLESAUCE"))
 DECLARE mf_60ml34seqsipsh2o_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVAL60ML34SEQSIPSH2O"))
 DECLARE mf_step2readiness_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALSTEP2READINESS"))
 DECLARE mf_proceedtostep1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALPROCEEDTOSTEP1"))
 DECLARE mf_startdiet_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "STARTDIETAFTERNUTRITIONCONSULT"))
 DECLARE mf_cond2equation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALCONDITION2EQUATION"))
 DECLARE mf_step2reassessment_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALSTEP2REASSESSMENT"))
 DECLARE mf_cond1reassess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALCONDITION1REASSESS"))
 DECLARE mf_cond2reassess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ICUSWALLOWEVALCONDITION2REASSESS"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_calculation = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SET ms_subject = build2("ICU Adult Post Extubation Swallow Screen Monthly Report ",trim(format(
     mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")
    ))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_POST_EXTUBATION"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET ms_subject = build2("ICU Adult Post Extubation Swallow Screen Report ",trim(format(
     mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")
    ))
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 93)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result cedr
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.event_cd IN (mf_glasgowcomascore_cd, mf_datetimeintubated_cd, mf_datetimeextubated_cd,
   mf_totintubationtime_cd, mf_exclusioncriteria_cd,
   mf_evalkeepnpo_cd, mf_riskfactors_cd, mf_riskfactorsscore_cd, mf_proceedtostep2_cd,
   mf_waitreassessdttm_cd,
   mf_condition1_cd, mf_condition2_cd, mf_proceedtostep3_cd, mf_volitionalswallow_cd,
   mf_5mlor1tspofwater_cd,
   mf_1tspofapplesauce_cd, mf_60ml34seqsipsh2o_cd, mf_step2readiness_cd, mf_proceedtostep1_cd,
   mf_startdiet_cd,
   mf_cond2equation_cd, mf_step2reassessment_cd, mf_cond1reassess_cd, mf_cond2reassess_cd)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.publish_flag=1
    AND ce.event_tag != "In Error")
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY ce.performed_dt_tm, ce.parent_event_id
  HEAD REPORT
   ml_cnt = 0
  HEAD ce.parent_event_id
   ml_calculation = 0, ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].f_person_id = ce.person_id, m_rec->qual[ml_cnt].f_encntr_id = ce.encntr_id,
   m_rec->qual[ml_cnt].s_performed_dt_tm = format(ce.performed_dt_tm,"mm/dd/yyyy hh:mm;;d")
  HEAD ce.event_id
   CASE (ce.event_cd)
    OF mf_glasgowcomascore_cd:
     m_rec->qual[ml_cnt].s_glasgow_coma_score = ce.result_val
    OF mf_datetimeintubated_cd:
     m_rec->qual[ml_cnt].s_intubated_dt_tm = format(cedr.result_dt_tm,"mm/dd/yyyy hh:mm;;d")
    OF mf_datetimeextubated_cd:
     m_rec->qual[ml_cnt].s_extubated_dt_tm = format(cedr.result_dt_tm,"mm/dd/yyyy hh:mm;;d")
    OF mf_totintubationtime_cd:
     m_rec->qual[ml_cnt].s_tot_intubation_time = ce.result_val
    OF mf_exclusioncriteria_cd:
     m_rec->qual[ml_cnt].s_exclusion_criteria = ce.result_val
    OF mf_evalkeepnpo_cd:
     m_rec->qual[ml_cnt].s_keep_npo = ce.result_val
    OF mf_riskfactors_cd:
     m_rec->qual[ml_cnt].s_risk_factors = ce.result_val
    OF mf_waitreassessdttm_cd:
     m_rec->qual[ml_cnt].s_wait_reassess_dt_tm = format(cedr.result_dt_tm,"mm/dd/yyyy hh:mm;;d")
    OF mf_condition1_cd:
     m_rec->qual[ml_cnt].s_condition1 = ce.result_val
    OF mf_condition2_cd:
     m_rec->qual[ml_cnt].s_condition2 = ce.result_val
    OF mf_proceedtostep2_cd:
     m_rec->qual[ml_cnt].s_proceed_to_step2 = ce.result_val
    OF mf_step2readiness_cd:
     m_rec->qual[ml_cnt].s_step2_readiness = ce.result_val
    OF mf_startdiet_cd:
     m_rec->qual[ml_cnt].s_diet_after_consult = ce.result_val
    OF mf_cond2equation_cd:
     m_rec->qual[ml_cnt].s_condition2_equation = ce.result_val
    OF mf_step2reassessment_cd:
     m_rec->qual[ml_cnt].s_step2_reassess = ce.result_val
    OF mf_cond1reassess_cd:
     m_rec->qual[ml_cnt].s_condition1_reassess = ce.result_val
    OF mf_cond2reassess_cd:
     m_rec->qual[ml_cnt].s_condition2_reassess = ce.result_val
    OF mf_proceedtostep1_cd:
     m_rec->qual[ml_cnt].s_proceed_to_step1 = ce.result_val,
     IF (ml_calculation < 16)
      ml_calculation = evaluate(ce.result_val,"Do not proceed",70,(ml_calculation+ 1))
     ENDIF
    OF mf_riskfactorsscore_cd:
     m_rec->qual[ml_cnt].s_risk_factors_score = ce.result_val,
     IF (ml_calculation < 16)
      IF (cnvtint(ce.result_val) >= 10)
       ml_calculation = 75
      ELSE
       ml_calculation += cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_proceedtostep3_cd:
     m_rec->qual[ml_cnt].s_proceed_to_step3 = ce.result_val,
     IF (ml_calculation < 16)
      ml_calculation = evaluate(ce.result_val,"Proceed to Step 3",(ml_calculation+ 1),
       "Reassess in 2 Hours",(ml_calculation+ 2),
       80)
     ENDIF
    OF mf_volitionalswallow_cd:
     m_rec->qual[ml_cnt].s_volitional_swallow = ce.result_val,
     IF (ml_calculation < 16)
      ml_calculation = evaluate(ce.result_val,"Fail",85,(ml_calculation+ 1))
     ENDIF
    OF mf_5mlor1tspofwater_cd:
     m_rec->qual[ml_cnt].s_5mlor1tsp_of_water = ce.result_val,
     IF (ml_calculation < 16)
      ml_calculation = evaluate(ce.result_val,"Fail",90,(ml_calculation+ 1))
     ENDIF
    OF mf_1tspofapplesauce_cd:
     m_rec->qual[ml_cnt].s_1tsp_of_applesauce = ce.result_val,
     IF (ml_calculation < 16)
      ml_calculation = evaluate(ce.result_val,"Fail",95,(ml_calculation+ 1))
     ENDIF
    OF mf_60ml34seqsipsh2o_cd:
     m_rec->qual[ml_cnt].s_sips_h2o = ce.result_val,
     IF (ml_calculation < 16)
      ml_calculation = evaluate(ce.result_val,"Fail",99,(ml_calculation+ 1))
     ENDIF
   ENDCASE
  FOOT  ce.parent_event_id
   m_rec->qual[ml_cnt].s_swallow_eval_calc = cnvtstring(ml_calculation)
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = m_rec->l_cnt),
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_rec->qual[d.seq].f_person_id))
   JOIN (ea1
   WHERE (ea1.encntr_id=m_rec->qual[d.seq].f_encntr_id)
    AND ea1.encntr_alias_type_cd=mf_fin_cd
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (ea2
   WHERE (ea2.encntr_id=m_rec->qual[d.seq].f_encntr_id)
    AND ea2.encntr_alias_type_cd=mf_mrn_cd
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  HEAD d.seq
   m_rec->qual[d.seq].s_patient_name = p.name_full_formatted, m_rec->qual[d.seq].s_fin = ea1.alias,
   m_rec->qual[d.seq].s_mrn = ea2.alias
  WITH nocounter
 ;end select
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"MRN#",','"ACC#",','"FORM PERFORMED DT/TM",',
   '"INTUBATED DT/TM",',
   '"EXTUBATED DT/TM",','"GLASGOW COMA SCORE",','"1 TSP OF APPLESAUCE",','"5ML OR 1 TSP OF WATER",',
   '"60ML/3-4 SEQ. SIPS H20",',
   '"SWALLOW EVAL CALCULATION",','"CONDITION 1 REASSESSMENT",','"CONDITION 2 REASSESSMENT",',
   '"CONDITION 1",','"CONDITION 2",',
   '"CONDITION 2 EQUATION",','"EXCLUSION CRITERIA",','"KEEP NPO",','"PROCEED TO STEP 1",',
   '"PROCEED TO STEP 2",',
   '"PROCEED TO STEP 3",','"RISK FACTORS",','"RISK FACTORS SCORE",','"STEP 2 READINESS",',
   '"STEP 2 REASSESSMENT",',
   '"VOLITIONAL SWALLOW",','"WAIT REASSESSMENT DT/TM",','"START DIET AFTER NUTRITION CONSULT",',
   '"TOTAL INTUBATION TIME",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_patient_name,3),'","',trim(m_rec->qual[
     ml_cnt].s_mrn,3),'","',
    trim(m_rec->qual[ml_cnt].s_fin,3),'","',trim(m_rec->qual[ml_cnt].s_performed_dt_tm,3),'","',trim(
     m_rec->qual[ml_cnt].s_intubated_dt_tm,3),
    '","',trim(m_rec->qual[ml_cnt].s_extubated_dt_tm,3),'","',trim(m_rec->qual[ml_cnt].
     s_glasgow_coma_score,3),'","',
    trim(m_rec->qual[ml_cnt].s_1tsp_of_applesauce,3),'","',trim(m_rec->qual[ml_cnt].
     s_5mlor1tsp_of_water,3),'","',trim(m_rec->qual[ml_cnt].s_sips_h2o,3),
    '","',trim(m_rec->qual[ml_cnt].s_swallow_eval_calc,3),'","',trim(m_rec->qual[ml_cnt].
     s_condition1_reassess,3),'","',
    trim(m_rec->qual[ml_cnt].s_condition2_reassess,3),'","',trim(m_rec->qual[ml_cnt].s_condition1,3),
    '","',trim(m_rec->qual[ml_cnt].s_condition2,3),
    '","',trim(m_rec->qual[ml_cnt].s_condition2_equation,3),'","',trim(m_rec->qual[ml_cnt].
     s_exclusion_criteria,3),'","',
    trim(m_rec->qual[ml_cnt].s_keep_npo,3),'","',trim(m_rec->qual[ml_cnt].s_proceed_to_step1,3),'","',
    trim(m_rec->qual[ml_cnt].s_proceed_to_step2,3),
    '","',trim(m_rec->qual[ml_cnt].s_proceed_to_step3,3),'","',trim(m_rec->qual[ml_cnt].
     s_risk_factors,3),'","',
    trim(m_rec->qual[ml_cnt].s_risk_factors_score,3),'","',trim(m_rec->qual[ml_cnt].s_step2_readiness,
     3),'","',trim(m_rec->qual[ml_cnt].s_step2_reassess,3),
    '","',trim(m_rec->qual[ml_cnt].s_volitional_swallow,3),'","',trim(m_rec->qual[ml_cnt].
     s_wait_reassess_dt_tm,3),'","',
    trim(m_rec->qual[ml_cnt].s_diet_after_consult,3),'","',trim(m_rec->qual[ml_cnt].
     s_tot_intubation_time,3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,100,m_rec->qual[d.seq].s_patient_name), mrn# = substring(1,100,m_rec->
    qual[d.seq].s_mrn), acc# = substring(1,100,m_rec->qual[d.seq].s_fin),
   form_performed_dt_tm = substring(1,100,m_rec->qual[d.seq].s_performed_dt_tm), intubated_dt_tm =
   substring(1,100,m_rec->qual[d.seq].s_intubated_dt_tm), extubated_dt_tm = substring(1,100,m_rec->
    qual[d.seq].s_extubated_dt_tm),
   glasgow_coma_score = substring(1,100,m_rec->qual[d.seq].s_glasgow_coma_score), 1tsp_of_applesauce
    = substring(1,100,m_rec->qual[d.seq].s_1tsp_of_applesauce), 5ml_or_1tsp_of_water = substring(1,
    100,m_rec->qual[d.seq].s_5mlor1tsp_of_water),
   60ml_3_4_seq_sips_of_h2o = substring(1,100,m_rec->qual[d.seq].s_sips_h2o),
   swallow_eval_calculation = substring(1,100,m_rec->qual[d.seq].s_swallow_eval_calc),
   condition1_reassessment = substring(1,100,m_rec->qual[d.seq].s_condition1_reassess),
   condition2_reassessment = substring(1,100,m_rec->qual[d.seq].s_condition2_reassess), condition1 =
   substring(1,100,m_rec->qual[d.seq].s_condition1), condition2 = substring(1,100,m_rec->qual[d.seq].
    s_condition2),
   condition2_equation = substring(1,100,m_rec->qual[d.seq].s_condition2_equation),
   exclusion_criteria = substring(1,100,m_rec->qual[d.seq].s_exclusion_criteria), keep_npo =
   substring(1,100,m_rec->qual[d.seq].s_keep_npo),
   proceed_to_step1 = substring(1,100,m_rec->qual[d.seq].s_proceed_to_step1), proceed_to_step2 =
   substring(1,100,m_rec->qual[d.seq].s_proceed_to_step2), proceed_to_step3 = substring(1,100,m_rec->
    qual[d.seq].s_proceed_to_step3),
   risk_factors = substring(1,100,m_rec->qual[d.seq].s_risk_factors), risk_factors_score = substring(
    1,100,m_rec->qual[d.seq].s_risk_factors_score), step2_readiness = substring(1,100,m_rec->qual[d
    .seq].s_step2_readiness),
   step2_reassessment = substring(1,100,m_rec->qual[d.seq].s_step2_reassess), volitional_swallow =
   substring(1,100,m_rec->qual[d.seq].s_volitional_swallow), wait_reassessment_dt_tm = substring(1,
    100,m_rec->qual[d.seq].s_wait_reassess_dt_tm),
   start_diet_after_nutrition_consult = substring(1,100,m_rec->qual[d.seq].s_diet_after_consult),
   total_intubation_time = substring(1,100,m_rec->qual[d.seq].s_tot_intubation_time)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (((mn_ops=1) OR (textlen(trim( $OUTDEV,3))=0)) )
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
