CREATE PROGRAM bhs_dt_clin_sum2_surg2:dba
 DECLARE mf_surg_area_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_surg_area = vc WITH protect, constant(cnvtupper(trim( $2,3)))
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.display_key=ms_surg_area
    AND cv.code_set=221
    AND cv.cdf_meaning="SURGAREA"
    AND cv.active_ind=1)
  DETAIL
   mf_surg_area_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (mf_surg_area_cd <= 0.00)
  CALL echo("Surgical Area not found.")
  GO TO exit_script
 ENDIF
 SET report_code = 17280799.00
 SET date_class = uar_get_code_by("displaykey",53,"DATE")
 SET fin_type = uar_get_code_by("displaykey",319,"FINNBR")
 SET mrn_type = uar_get_code_by("displaykey",319,"MRN")
 DECLARE tmp_remove = vc
 FREE RECORD sw
 RECORD sw(
   1 consultstatus = vc
   1 planoutcome = vc
   1 commnets = vc
   1 reportfiled = vc
   1 language = vc
   1 reasonforref = vc
 )
 FREE RECORD act_pat
 RECORD act_pat(
   1 qual[*]
     2 eid = f8
     2 reg_dt_tm = vc
     2 pid = f8
     2 unit = c20
     2 room = c20
     2 bed = c10
     2 visit_reason = vc
     2 filename = vc
     2 s_sched_time = vc
     2 s_pat_type = vc
     2 s_surg_case_nbr = vc
     2 f_surg_case_id = f8
 )
 FREE RECORD pat
 RECORD pat(
   1 qual[*]
     2 pid = f8
     2 eid = f8
     2 ms_bloodpressurevenipuncture = vc
     2 ms_wearing_bpv_band = vc
     2 filename = vc
     2 name = vc
     2 religion = c30
     2 language = c30
     2 att_doc = c30
     2 pcp_doc = c30
     2 teaching_doc = c30
     2 visit_reason = vc
     2 diagnosis = vc
     2 complaint = vc
     2 code_status_name = vc
     2 code_status_detail[*]
       3 display = vc
     2 allergy = vc
     2 birth_dt = dq8
     2 mrn = c20
     2 cmrn = c20
     2 admit_dt = c30
     2 dob = dq8
     2 fin = c20
     2 unit_room_bed = vc
     2 s_sched_time = vc
     2 s_surg_case_nbr = vc
     2 s_pat_type = vc
     2 s_unit = vc
     2 s_room = vc
     2 f_surg_case_id = f8
     2 s_public_comment = vc
     2 l_pcnt = i4
     2 proc[*]
       3 f_proc_cd = f8
       3 s_proc_name = vc
       3 s_prim_surg = vc
       3 s_assist_surg = vc
       3 s_ancillary = vc
       3 s_modifier = vc
     2 sec[*]
       3 sec_disp = vc
       3 sec_event_id = f8
       3 grpr[*]
         4 grpr_disp = vc
         4 grpr_date = dq8
         4 event[*]
           5 event_disp = vc
           5 event_cnt = i2
           5 max_lookback_hrs = i2
           5 max_result_qty = i2
           5 result[*]
             6 event_result = vc
             6 begin_dt_time = dq8
             6 end_dt_tm = dq8
             6 result_age = i2
     2 ntnord[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 mdtrnord[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 diet[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 resp[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 monitor[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 lab_rad_ekg[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 nut[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 cprocedure[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 problems[*]
       3 problem_line = vc
     2 invasive[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 verify_ind = i2
       3 verify_str = c20
     2 infusion[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
 )
 DECLARE mf_bloodpressurevenipuncture = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODPRESSUREVENIPUNCTURE")), protect
 DECLARE mf_wearing_bpv_band = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WEARINGBPVENIPUNCTURERESTRICTIONBAND")), protect
 DECLARE mf_authverified = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE att_cd = f8
 DECLARE pcp_cd = f8
 DECLARE teaching_cd = f8
 SET teaching_cd = uar_get_code_by("displaykey",333,"TEACHINGCOVERAGE")
 SET pcp_cd = uar_get_code_by("displaykey",333,"PRIMARYCAREPHYSICIAN")
 SET att_cd = uar_get_code_by("displaykey",333,"ATTENDINGPHYSICIAN")
 DECLARE chiefcomplaint_cd = f8
 SET chiefcomplaint_cd = uar_get_code_by("DISPLAYKEY",72,"CHIEFCOMPLAINT")
 DECLARE pid = f8
 DECLARE eid = f8
 DECLARE iv_type_cd = f8
 DECLARE med_type_cd = f8
 DECLARE num_type_cd = f8
 DECLARE not_done_cd = f8
 DECLARE voided_cd = f8
 DECLARE begin_bag_cd = f8
 DECLARE site_chg_cd = f8
 DECLARE rate_chg_cd = f8
 DECLARE pain_rspns_cd = f8
 DECLARE med_reason_cd = f8
 DECLARE result_cmnt_cd = f8
 DECLARE compress_cd = f8
 DECLARE scope_clause = vc
 DECLARE date_clause = vc
 DECLARE max_num_sched_admins = i4
 DECLARE max_num_prn_admins = i4
 DECLARE max_num_cont_admins = i4
 DECLARE max_num_sched_actions = i4
 DECLARE max_num_prn_actions = i4
 DECLARE max_num_cont_actions = i4
 DECLARE schedordercnt = i4
 DECLARE assignscopeclause(null) = null
 DECLARE assigndateclause(null) = null
 DECLARE getqualifyingorders(null) = null
 DECLARE getscheduledmeds1(null) = null
 DECLARE getscheduledmeds2(null) = null
 DECLARE getvoidedindforscheduled(null) = null
 DECLARE getprnmeds(null) = null
 DECLARE getcontinuousmeds(null) = null
 DECLARE getvitalsigns(null) = null
 DECLARE getcomments(null) = null
 DECLARE getschedvsprnfield(null) = null
 DECLARE expanddetails(null) = null
 DECLARE checkforerror(qual_num=i4,op_name=vc,force_exit=i2) = null
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(18309,"IV",1,iv_type_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MED",1,med_type_cd)
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,num_type_cd)
 SET stat = uar_get_meaning_by_codeset(8,"NOT DONE",1,not_done_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,voided_cd)
 SET stat = uar_get_meaning_by_codeset(180,"BEGIN",1,begin_bag_cd)
 SET stat = uar_get_meaning_by_codeset(180,"RATECHG",1,rate_chg_cd)
 SET stat = uar_get_meaning_by_codeset(180,"SITECHG",1,site_chg_cd)
 SET stat = uar_get_meaning_by_codeset(14,"RES COMMENT",1,result_cmnt_cd)
 SET stat = uar_get_meaning_by_codeset(14,"RESPONSETO",1,pain_rspns_cd)
 SET stat = uar_get_meaning_by_codeset(14,"REASONFOR",1,med_reason_cd)
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compress_cd)
 SET pain_intensity = uar_get_code_by("DISPLAYKEY",72,"PAININTENSITY")
 SET pulse_rate = uar_get_code_by("DISPLAYKEY",72,"PULSERATE")
 SET systolic_pressure = uar_get_code_by("DISPLAYKEY",72,"SYSTOLICBLOODPRESSURE")
 SET diastolic_pressure = uar_get_code_by("DISPLAYKEY",72,"DIASTOLICBLOODPRESSURE")
 SET code_value = 0.0
 SET pharmacy = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy = code_value
 DECLARE date = cv
 DECLARE os_can_cd = f8
 DECLARE os_dis_cd = f8
 DECLARE os_com_cd = f8
 DECLARE os_del_cd = f8
 DECLARE os_fut_cd = f8
 DECLARE os_inp_cd = f8
 DECLARE os_inc_cd = f8
 DECLARE os_med_cd = f8
 DECLARE os_ord_cd = f8
 DECLARE os_pen_cd = f8
 DECLARE os_per_cd = f8
 DECLARE os_sus_cd = f8
 DECLARE os_tra_cd = f8
 DECLARE os_uns_cd = f8
 DECLARE os_voi_cd = f8
 SET kram = uar_get_meaning_by_codeset(6004,"CANCELED",1,os_can_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"DISCONTINUED",1,os_dis_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"COMPLETED",1,os_com_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"DELETED",1,os_del_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"FUTURE",1,os_fut_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"INPROCESS",1,os_inp_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"INCOMPLETE",1,os_inc_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"MEDSTUDENT",1,os_med_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"ORDERED",1,os_ord_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"PENDING",1,os_pen_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"PENDING REV",1,os_per_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"SUSPENDED",1,os_sus_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"TRANS/CANCEL",1,os_tra_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"UNSCHEDULED",1,os_uns_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,os_voi_cd)
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE callmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CALLMD"))
 DECLARE rntorn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RNTORN"))
 DECLARE admittransferdischarge_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE communicationorders_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS"))
 DECLARE restraints_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS"))
 DECLARE language_spoken_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKENV001"))
 DECLARE planoutcome = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PLANOUTCOME"))
 DECLARE mandatedreport = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MANDATEDREPORT")
  )
 DECLARE consultstatus = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CONSULTSTATUS"))
 DECLARE plancommnet = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PLANCOMMENTS"))
 DECLARE reasonforref = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"REASONFORREFERRAL"
   ))
 DECLARE woundcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"WOUNDCARE"))
 DECLARE orthopedictreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ORTHOPEDICTREATMENTS"))
 DECLARE orthosupply_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ORTHOSUPPLY"))
 DECLARE asmttxmonitoring_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ASMTTXMONITORING"))
 DECLARE intakeandoutput_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INTAKEANDOUTPUT"))
 DECLARE anatomicpathology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ANATOMICPATHOLOGY"))
 DECLARE bloodbank_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE bloodbankmlh_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANKMLH"))
 DECLARE cardiactxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "CARDIACTXPROCEDURES"))
 DECLARE ecg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ECG"))
 DECLARE pointofcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"POINTOFCARE"))
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"))
 DECLARE generallab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE physther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE occther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE speechther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE audiology_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE antepartum_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE neurodiag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE pulmlab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE dietary_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE respther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE diets_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"DIETS"))
 DECLARE supplements_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"SUPPLEMENTS"))
 DECLARE infantformulas_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INFANTFORMULAS"))
 DECLARE infantformulaadditives_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INFANTFORMULAADDITIVES"))
 DECLARE testdiet_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"TESTDIET"))
 DECLARE tubefeedingcontinuous_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "TUBEFEEDINGCONTINUOUS"))
 DECLARE tubefeedingadditives_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "TUBEFEEDINGADDITIVES"))
 DECLARE tubefeedingbolus_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "TUBEFEEDINGBOLUS"))
 DECLARE rttxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "RTTXPROCEDURES"))
 DECLARE nsgrespiratorytx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "NSGRESPIRATORYTX"))
 DECLARE ventilationnoninvasive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "VENTILATIONNONINVASIVE"))
 DECLARE ventilationinvasive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "VENTILATIONINVASIVE"))
 DECLARE sleepstudies_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"SLEEPSTUDIES"))
 DECLARE noninvasivecardiologytxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   106,"NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE mdtornconsults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNCONSULTS"))
 DECLARE consults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTS"))
 DECLARE hyperbaricoxygentx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "HYPERBARICOXYGENTX"))
 DECLARE mdtorntxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNTXPROCEDURES"))
 DECLARE allergy_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE bloodbankproduct_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE invasivelinestubesdrains_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INVASIVELINESTUBESDRAINS"))
 DECLARE infusiontherapy_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INFUSIONTHERAPY"))
 DECLARE infusion_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"IVSOLUTIONS"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE tempstring = vc
 DECLARE comment_string = vc
 DECLARE printstring = vc
 DECLARE code_status_cd1 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "DNRNOCPRBUTOKTOINTUBATE"))
 DECLARE code_status_cd2 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "DNRDNINOCPRNOINTUBATION"))
 DECLARE code_status_cd3 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLCODECONFIRMED"))
 DECLARE code_status_cd4 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLCODEPRESUMED"))
 DECLARE code_status_cd5 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLPERIOPERATIVERESUSCITATION"))
 DECLARE code_status_cd6 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDPERIOPERATIVERESUSCITATION"))
 DECLARE code_status_cd7 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDRESUSCITATION"))
 DECLARE code_status_cd8 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "NOPERIOPERATIVERESUSCITATION"))
 DECLARE code_status_cd9 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "RESUSCITATIONPERIOPERATIVE"))
 DECLARE fluidrestriction_cd = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FLUIDRESTRICTION"))
 DECLARE trayservicedelivery_cd = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "TRAYSERVICEDELIVERY"))
 DECLARE dialysistxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "DIALYSISTXPROCEDURES"))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_cs72_admissionnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADMISSIONNOTE"))
 DECLARE mf_cs72_historyandphysical_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYANDPHYSICAL"))
 DECLARE mf_cs72_historyandphysicalhsp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYANDPHYSICALHOSPITAL"))
 DECLARE mf_cs72_anesthesianote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANESTHESIANOTE"))
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE mf_cs6004_incomplete_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3815"
   ))
 DECLARE mf_cs6011_ancillary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,
   "ANCILLARY"))
 DECLARE title = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 EXECUTE bhs_hlp_ccl
 FREE RECORD m_cv_rec
 RECORD m_cv_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_code_value = f8
     2 s_desc = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND cv.display_key IN ("CONSULTATIONNOTE", "ADMISSIONNOTE", "HISTORYANDPHYSICAL",
   "HISTORYANDPHYSICALHOSPITAL", "ANESTHESIANOTE"))
  DETAIL
   m_cv_rec->l_cnt += 1, stat = alterlist(m_cv_rec->qual,m_cv_rec->l_cnt), m_cv_rec->qual[m_cv_rec->
   l_cnt].f_code_value = cv.code_value,
   m_cv_rec->qual[m_cv_rec->l_cnt].s_desc = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ps_case_dt = format(sc.sched_start_dt_tm,"MMDDYYYY;;D"), ps_or_room = uar_get_code_display(sc
   .sched_op_loc_cd), ps_case_tm = format(sc.sched_start_dt_tm,"HH:MM:SS;;M")
  FROM surgical_case sc,
   person p,
   encounter e
  PLAN (sc
   WHERE sc.sched_surg_area_cd=mf_surg_area_cd
    AND sc.sched_start_dt_tm >= cnvtdatetime(sysdate)
    AND sc.sched_start_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
    AND sc.active_ind=1
    AND sc.cancel_dt_tm = null)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id)
  ORDER BY ps_case_dt, ps_or_room, ps_case_tm
  HEAD sc.surg_case_nbr_formatted
   cnt += 1, stat = alterlist(act_pat->qual,cnt), act_pat->qual[cnt].eid = e.encntr_id,
   act_pat->qual[cnt].unit = trim(uar_get_code_display(sc.sched_surg_area_cd),3), act_pat->qual[cnt].
   room = ps_or_room, act_pat->qual[cnt].reg_dt_tm = format(e.reg_dt_tm,"mm/dd/yy ;;q"),
   act_pat->qual[cnt].pid = e.person_id, act_pat->qual[cnt].visit_reason = trim(e.reason_for_visit),
   act_pat->qual[cnt].filename = build(trim(substring(1,5,trim(cnvtlower(cnvtalphanum(p.name_last_key,
         2)),4)),3),"_",trim(substring(1,4,trim(cnvtlower(cnvtalphanum(p.name_first_key,2)),4)),3),
    ".ps"),
   act_pat->qual[cnt].s_pat_type = uar_get_code_display(sc.sched_pat_type_cd), act_pat->qual[cnt].
   s_sched_time = format(sc.sched_start_dt_tm,"MM/DD/YYYY HH:mm;;q"), act_pat->qual[cnt].
   s_surg_case_nbr = trim(sc.surg_case_nbr_formatted,3),
   act_pat->qual[cnt].f_surg_case_id = sc.surg_case_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET cnt1 = 0
 FOR (x = 1 TO size(act_pat->qual,5))
   SET cnt1 += 1
   SET stat = alterlist(pat->qual,cnt1)
   SET pat->qual[cnt1].pid = act_pat->qual[x].pid
   SET pat->qual[cnt1].eid = act_pat->qual[x].eid
   SET pat->qual[cnt1].unit_room_bed = concat(trim(act_pat->qual[x].unit,3),"-",trim(act_pat->qual[x]
     .room,3))
   SET pat->qual[cnt1].visit_reason = trim(act_pat->qual[x].visit_reason)
   SET pat->qual[cnt1].admit_dt = act_pat->qual[x].reg_dt_tm
   SET pat->qual[cnt1].s_pat_type = act_pat->qual[x].s_pat_type
   SET pat->qual[cnt1].s_sched_time = act_pat->qual[x].s_sched_time
   SET pat->qual[cnt1].s_surg_case_nbr = act_pat->qual[x].s_surg_case_nbr
   SET pat->qual[cnt1].s_unit = trim(act_pat->qual[x].unit,3)
   SET pat->qual[cnt1].s_room = trim(act_pat->qual[x].room,3)
   SET pat->qual[cnt1].f_surg_case_id = act_pat->qual[x].f_surg_case_id
 ENDFOR
 SET p_cnt = size(act_pat->qual,5)
 SELECT INTO "nl:"
  reg_date = act_pat->qual[d.seq].reg_dt_tm, unit = substring(1,50,act_pat->qual[d.seq].unit), room
   = substring(1,50,act_pat->qual[d.seq].room),
  bed = substring(1,50,act_pat->qual[d.seq].bed), result_age = datetimediff(cnvtdatetime(sysdate),ce
   .event_end_dt_tm,3), visit_reason = trim(act_pat->qual[d.seq].visit_reason),
  surg_case = substring(1,50,trim(act_pat->qual[d.seq].s_surg_case_nbr)), surg_sched_dt = substring(1,
   50,trim(act_pat->qual[d.seq].s_sched_time)), surg_pat_type = substring(1,50,trim(act_pat->qual[d
    .seq].s_pat_type)),
  surg_case_id = act_pat->qual[d.seq].f_surg_case_id
  FROM (dummyt d  WITH seq = value(p_cnt)),
   encounter e,
   clinical_event ce,
   bhs_grpr_dta_event_r dta,
   bhs_sect_grpr_r grpr,
   bhs_rept_sect_r sec
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=act_pat->qual[d.seq].eid))
   JOIN (ce
   WHERE (ce.encntr_id= Outerjoin(e.encntr_id))
    AND (ce.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ce.view_level= Outerjoin(1))
    AND (ce.authentic_flag= Outerjoin(1)) )
   JOIN (dta
   WHERE (dta.event_cd= Outerjoin(ce.event_cd))
    AND (dta.active_ind= Outerjoin(1)) )
   JOIN (grpr
   WHERE (grpr.grouper_cd= Outerjoin(dta.grouper_cd))
    AND (grpr.active_ind= Outerjoin(1)) )
   JOIN (sec
   WHERE (sec.section_cd= Outerjoin(grpr.section_cd))
    AND (sec.report_cd= Outerjoin(report_code))
    AND (sec.active_ind= Outerjoin(1)) )
  ORDER BY e.encntr_id, sec.section_seq, grpr.grouper_seq,
   dta.task_assay_seq, ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD REPORT
   cnt = 0, cnt2 = 0, cnt3 = 0,
   cnt4 = 0, cnt5 = 0
  HEAD e.encntr_id
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt += 1, stat = alterlist(pat->qual,cnt), pat->qual[cnt].pid = e.person_id,
    pat->qual[cnt].eid = e.encntr_id, pat->qual[cnt].unit_room_bed = build(unit,"/",room), pat->qual[
    cnt].visit_reason = visit_reason,
    pat->qual[cnt].admit_dt = reg_date, pat->qual[cnt].ms_bloodpressurevenipuncture =
    "No result found", pat->qual[cnt].s_room = room,
    pat->qual[cnt].s_unit = unit, pat->qual[cnt].s_surg_case_nbr = surg_case, pat->qual[cnt].
    s_pat_type = surg_pat_type,
    pat->qual[cnt].s_sched_time = surg_sched_dt, pat->qual[cnt].f_surg_case_id = surg_case_id
   ENDIF
   cnt2 = 0
  HEAD sec.section_seq
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt2 += 1, stat = alterlist(pat->qual[cnt].sec,cnt2), pat->qual[cnt].sec[cnt2].sec_disp =
    uar_get_code_display(sec.section_cd)
   ENDIF
   cnt3 = 0
  HEAD grpr.grouper_seq
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt3 += 1, stat = alterlist(pat->qual[cnt].sec[cnt2].grpr,cnt3), pat->qual[cnt].sec[cnt2].grpr[
    cnt3].grpr_disp = uar_get_code_display(grpr.grouper_cd),
    pat->qual[cnt].sec[cnt2].grpr[cnt3].grpr_date = ce.event_end_dt_tm
   ENDIF
   cnt4 = 0
  HEAD ce.event_cd
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt4 += 1, stat = alterlist(pat->qual[cnt].sec[cnt2].grpr[cnt3].event,cnt4)
    IF (size(trim(dta.event_display,3)) > 0)
     pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].event_disp = dta.event_display
    ELSE
     pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].event_disp = uar_get_code_display(ce.event_cd)
    ENDIF
    pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].max_lookback_hrs = dta.max_lookback_hours, pat->
    qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].max_result_qty = dta.max_result_qty
   ENDIF
   cnt5 = 0
  DETAIL
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt5 += 1, stat = alterlist(pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result,cnt5), pat->
    qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].event_cnt = cnt5
    IF (ce.event_class_cd=date_class)
     result = build(substring(7,2,ce.result_val),"/",substring(9,2,ce.result_val),"/",substring(3,4,
       ce.result_val)), pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].event_result =
     result
    ELSE
     pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].event_result = concat(ce.result_val
      )
    ENDIF
    pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].begin_dt_time = ce.valid_from_dt_tm,
    pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].end_dt_tm = ce.event_end_dt_tm, pat
    ->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].result_age = datetimediff(cnvtdatetime(
      sysdate),ce.event_end_dt_tm,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surg_case_procedure scp,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   order_catalog oc,
   prsnl p,
   order_detail od
  PLAN (scp
   WHERE expand(ml_idx,1,size(pat->qual,5),scp.surg_case_id,pat->qual[ml_idx].f_surg_case_id)
    AND scp.active_ind=1)
   JOIN (ocs
   WHERE (ocs.synonym_id= Outerjoin(scp.synonym_id)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(ocs.catalog_cd)) )
   JOIN (ocs2
   WHERE (ocs2.catalog_cd= Outerjoin(ocs.catalog_cd))
    AND (ocs2.mnemonic_type_cd= Outerjoin(mf_cs6011_ancillary_cd))
    AND (ocs2.active_ind= Outerjoin(1)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
   JOIN (od
   WHERE (od.order_id= Outerjoin(scp.order_id))
    AND (od.oe_field_meaning= Outerjoin("SURGEON4")) )
  ORDER BY scp.surg_case_id, scp.surg_case_proc_id, ocs2.mnemonic,
   od.action_sequence DESC
  HEAD REPORT
   ml_idx2 = 0
  HEAD scp.surg_case_id
   ml_idx2 = locateval(ml_idx,1,size(pat->qual,5),scp.surg_case_id,pat->qual[ml_idx].f_surg_case_id)
  HEAD scp.surg_case_proc_id
   IF (ml_idx2 > 0)
    pat->qual[ml_idx].l_pcnt += 1, stat = alterlist(pat->qual[ml_idx].proc,pat->qual[ml_idx].l_pcnt),
    pat->qual[ml_idx].proc[pat->qual[ml_idx].l_pcnt].f_proc_cd = ocs.catalog_cd,
    pat->qual[ml_idx].proc[pat->qual[ml_idx].l_pcnt].s_ancillary = substring(1,8,trim(ocs2.mnemonic,3
      )), pat->qual[ml_idx].proc[pat->qual[ml_idx].l_pcnt].s_assist_surg = od.oe_field_display_value,
    pat->qual[ml_idx].proc[pat->qual[ml_idx].l_pcnt].s_prim_surg = p.name_full_formatted,
    pat->qual[ml_idx].proc[pat->qual[ml_idx].l_pcnt].s_proc_name = oc.primary_mnemonic, pat->qual[
    ml_idx].proc[pat->qual[ml_idx].l_pcnt].s_modifier = scp.sched_modifier
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sch_event_comm sec,
   long_text lt
  PLAN (sc
   WHERE expand(ml_idx,1,size(pat->qual,5),sc.surg_case_id,pat->qual[ml_idx].f_surg_case_id))
   JOIN (sec
   WHERE sec.sch_event_id=sc.sch_event_id
    AND sec.active_ind=1
    AND sec.text_type_meaning="COMMENT"
    AND sec.sub_text_meaning="SURGPUBLIC"
    AND sec.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (lt
   WHERE lt.long_text_id=sec.text_id
    AND lt.active_ind=1)
  ORDER BY sc.surg_case_id
  HEAD REPORT
   ml_idx2 = 0
  HEAD sc.surg_case_id
   ml_idx2 = locateval(ml_idx,1,size(pat->qual,5),sc.surg_case_id,pat->qual[ml_idx].f_surg_case_id)
   IF (ml_idx2 > 0)
    IF (size(trim(lt.long_text,3)) > 0
     AND trim(lt.long_text,3) != ":")
     pat->qual[ml_idx2].s_public_comment = replace(trim(lt.long_text,3),char(013)," ")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (dummyt d1  WITH seq = value(size(pat->qual,5)))
  PLAN (d1)
   JOIN (ce
   WHERE (ce.encntr_id=pat->qual[d1.seq].eid)
    AND ce.event_cd IN (mf_bloodpressurevenipuncture, mf_wearing_bpv_band)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.result_status_cd=mf_authverified)
  ORDER BY ce.event_cd, ce.updt_dt_tm DESC
  HEAD ce.event_cd
   CALL echo(build("ce.encntr_id = ",ce.encntr_id))
   IF (ce.event_cd=mf_bloodpressurevenipuncture)
    pat->qual[d1.seq].ms_bloodpressurevenipuncture = ce.result_val
   ELSEIF (ce.event_cd=mf_wearing_bpv_band)
    pat->qual[d1.seq].ms_wearing_bpv_band = ce.result_val
   ENDIF
  WITH nocounter
 ;end select
 SET pat_cnt = size(pat->qual,5)
 CALL echo(build("pat_cnt",pat_cnt))
 CALL echo(build("p_cnt",p_cnt))
 SELECT INTO "nl:"
  name = trim(p.name_full_formatted), alias = trim(ea.alias)
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   person p,
   encntr_alias ea
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=pat->qual[d.seq].pid))
   JOIN (ea
   WHERE (ea.encntr_id=pat->qual[d.seq].eid)
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd IN (fin_type, mrn_type))
  DETAIL
   pat->qual[d.seq].name = name, pat->qual[d.seq].religion = substring(1,30,uar_get_code_display(p
     .religion_cd)), pat->qual[d.seq].language = substring(1,30,uar_get_code_display(p.language_cd)),
   pat->qual[d.seq].dob = p.birth_dt_tm, pat->qual[d.seq].filename = build(trim(substring(1,5,trim(
       cnvtlower(cnvtalphanum(p.name_last_key,2)),4)),3),"_",trim(substring(1,4,trim(cnvtlower(
        cnvtalphanum(p.name_first_key,2)),4)),3),".ps")
   IF (ea.encntr_alias_type_cd=fin_type)
    pat->qual[d.seq].fin = alias
   ELSEIF (ea.encntr_alias_type_cd=mrn_type)
    pat->qual[d.seq].mrn = alias
   ENDIF
   pat->qual[d.seq].birth_dt = p.birth_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=pat->qual[d.seq].eid)
    AND epr.expiration_ind=0
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE epr.prsnl_person_id=p.person_id
    AND p.physician_ind=1)
  DETAIL
   IF (epr.encntr_prsnl_r_cd=att_cd)
    pat->qual[d.seq].att_doc = substring(1,20,p.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=pcp_cd)
    pat->qual[d.seq].pcp_doc = substring(1,20,p.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=teaching_cd)
    pat->qual[d.seq].teaching_doc = substring(1,20,p.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   diagnosis d,
   nomenclature n
  PLAN (d1)
   JOIN (d
   WHERE (d.encntr_id=pat->qual[d1.seq].eid)
    AND ((d.active_ind+ 0)=1))
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(d.nomenclature_id)) )
  ORDER BY d.encntr_id, d.diag_dt_tm DESC, d.nomenclature_id
  HEAD d.encntr_id
   cnt = 0
  DETAIL
   IF (n.nomenclature_id > 0)
    pat->qual[d1.seq].diagnosis = n.source_string
   ELSE
    pat->qual[d1.seq].diagnosis = d.diag_ftdesc
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("I am in chief complaint")
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   clinical_event c
  PLAN (d1)
   JOIN (c
   WHERE ((c.person_id+ 0)=pat->qual[d1.seq].pid)
    AND c.event_cd=chiefcomplaint_cd
    AND (c.encntr_id=pat->qual[d1.seq].eid)
    AND ((c.view_level+ 0)=1)
    AND ((c.publish_flag+ 0)=1)
    AND ((c.valid_until_dt_tm+ 0)=cnvtdatetime("31-dec-2100,00:00:00"))
    AND  NOT (((c.result_status_cd+ 0) IN (inerror_cd, notdone_cd)))
    AND trim(c.event_tag) > " ")
  ORDER BY c.encntr_id, c.event_end_dt_tm DESC
  HEAD c.encntr_id
   IF (trim(pat->qual[d1.seq].diagnosis)="")
    pat->qual[d1.seq].diagnosis = trim(c.result_val)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   orders o,
   order_comment oc,
   long_text lt
  PLAN (d1)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[d1.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1)))
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
    AND (lt.active_ind= Outerjoin(1)) )
  ORDER BY o.encntr_id, o.activity_type_cd
  HEAD o.encntr_id
   cnt1 = 0, cnt2 = 0, cnt3 = 0,
   cnt4 = 0, cnt5 = 0, cnt6 = 0,
   cnt7 = 0, cnt8 = 0, cnt9 = 0,
   cnt10 = 0
  DETAIL
   IF (o.activity_type_cd IN (rntorn_cd))
    cnt1 += 1
    IF (mod(cnt1,10)=1)
     stat = alterlist(pat->qual[d1.seq].ntnord,(cnt1+ 9))
    ENDIF
    pat->qual[d1.seq].ntnord[cnt1].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].ntnord[cnt1].
    clinical_display = o.clinical_display_line, pat->qual[d1.seq].ntnord[cnt1].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].ntnord[cnt1].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd IN (callmd_cd, admittransferdischarge_cd, communicationorders_cd,
   restraints_cd))
    cnt2 += 1
    IF (mod(cnt2,10)=1)
     stat = alterlist(pat->qual[d1.seq].mdtrnord,(cnt2+ 9))
    ENDIF
    pat->qual[d1.seq].mdtrnord[cnt2].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].mdtrnord[
    cnt2].clinical_display = o.clinical_display_line, pat->qual[d1.seq].mdtrnord[cnt2].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].mdtrnord[cnt2].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd IN (woundcare_cd, orthopedictreatments_cd, orthosupply_cd,
   asmttxmonitoring_cd, intakeandoutput_cd))
    cnt5 += 1
    IF (mod(cnt5,10)=1)
     stat = alterlist(pat->qual[d1.seq].monitor,(cnt5+ 9))
    ENDIF
    pat->qual[d1.seq].monitor[cnt5].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].monitor[cnt5
    ].clinical_display = o.clinical_display_line, pat->qual[d1.seq].monitor[cnt5].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].monitor[cnt5].comment = lt.long_text
    ENDIF
   ENDIF
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[d1.seq].ntnord,cnt1), stat = alterlist(pat->qual[d1.seq].mdtrnord,cnt2),
   stat = alterlist(pat->qual[d1.seq].monitor,cnt5)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.catalog_type_cd=physther_cd) 1
  ELSEIF (o.catalog_type_cd=occther_cd) 2
  ELSEIF (o.catalog_type_cd=speechther_cd) 3
  ELSEIF (o.catalog_type_cd=audiology_cd) 4
  ELSEIF (o.catalog_type_cd=antepartum_cd) 5
  ELSEIF (o.activity_type_cd=consults_cd) 6
  ELSEIF (o.activity_type_cd=mdtornconsults_cd) 7
  ELSEIF (o.catalog_type_cd=neurodiag_cd) 8
  ELSEIF (o.catalog_type_cd=pulmlab_cd) 9
  ELSEIF (o.activity_type_cd=hyperbaricoxygentx_cd) 10
  ELSEIF (o.activity_type_cd=noninvasivecardiologytxprocedures_cd) 11
  ELSEIF (o.activity_type_cd=mdtorntxprocedures_cd) 12
  ELSEIF (o.activity_type_cd=dialysistxprocedures_cd) 13
  ELSE 99
  ENDIF
  FROM (dummyt dd  WITH seq = value(pat_cnt)),
   orders o
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[dd.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.orderable_type_flag+ 0)=0)
    AND ((((o.catalog_type_cd+ 0) IN (physther_cd, occther_cd, speechther_cd, audiology_cd,
   antepartum_cd,
   neurodiag_cd, pulmlab_cd))) OR (((o.activity_type_cd+ 0) IN (noninvasivecardiologytxprocedures_cd,
   hyperbaricoxygentx_cd, mdtornconsults_cd, consults_cd, mdtorntxprocedures_cd,
   dialysistxprocedures_cd)))) )
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(pat->qual[dd.seq].cprocedure,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(pat->qual[dd.seq].cprocedure,(cnt+ 10))
   ENDIF
   pat->qual[dd.seq].cprocedure[cnt].order_mnemonic = o.order_mnemonic, pat->qual[dd.seq].cprocedure[
   cnt].clinical_display = o.clinical_display_line
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[dd.seq].cprocedure,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.activity_type_cd=diets_cd) 1
  ELSEIF (o.activity_type_cd=supplements_cd) 2
  ELSEIF (o.activity_type_cd=infantformulas_cd) 3
  ELSEIF (o.activity_type_cd=infantformulaadditives_cd) 4
  ELSEIF (o.activity_type_cd=testdiet_cd) 5
  ELSEIF (o.activity_type_cd=tubefeedingcontinuous_cd) 6
  ELSEIF (o.activity_type_cd=tubefeedingadditives_cd) 7
  ELSEIF (o.activity_type_cd=tubefeedingbolus_cd) 8
  ENDIF
  FROM (dummyt dd  WITH seq = value(pat_cnt)),
   orders o
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[dd.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.activity_type_cd+ 0) IN (diets_cd, supplements_cd, infantformulas_cd,
   infantformulaadditives_cd, testdiet_cd,
   tubefeedingcontinuous_cd, tubefeedingadditives_cd, tubefeedingbolus_cd)))
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(pat->qual[dd.seq].diet,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(pat->qual[dd.seq].diet,(cnt+ 10))
   ENDIF
   pat->qual[dd.seq].diet[cnt].order_mnemonic = o.order_mnemonic, pat->qual[dd.seq].diet[cnt].
   clinical_display = o.clinical_display_line
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[dd.seq].diet,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.activity_type_cd=rttxprocedures_cd) 1
  ELSEIF (o.activity_type_cd=nsgrespiratorytx_cd) 2
  ELSEIF (o.activity_type_cd=ventilationnoninvasive_cd) 3
  ELSEIF (o.activity_type_cd=ventilationinvasive_cd) 4
  ELSEIF (o.activity_type_cd=sleepstudies_cd) 5
  ENDIF
  FROM (dummyt dd  WITH seq = value(pat_cnt)),
   orders o
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[dd.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.activity_type_cd+ 0) IN (rttxprocedures_cd, nsgrespiratorytx_cd,
   ventilationnoninvasive_cd, ventilationinvasive_cd, sleepstudies_cd)))
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(pat->qual[dd.seq].resp,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(pat->qual[dd.seq].resp,(cnt+ 10))
   ENDIF
   pat->qual[dd.seq].resp[cnt].order_mnemonic = o.order_mnemonic, pat->qual[dd.seq].resp[cnt].
   clinical_display = o.clinical_display_line
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[dd.seq].resp,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.activity_type_cd=anatomicpathology_cd) 6
  ELSEIF (o.activity_type_cd=bloodbank_cd) 4
  ELSEIF (o.activity_type_cd=bloodbankmlh_cd) 5
  ELSEIF (o.activity_type_cd=cardiactxprocedures_cd) 8
  ELSEIF (o.activity_type_cd=ecg_cd) 7
  ELSEIF (o.activity_type_cd=generallab_cd) 2
  ELSEIF (o.activity_type_cd=micro_cd) 3
  ELSEIF (o.activity_type_cd=pointofcare_cd) 1
  ELSEIF (o.catalog_cd=radiology_cd) 9
  ELSE 99
  ENDIF
  FROM (dummyt dd  WITH seq = value(pat_cnt)),
   orders o
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[dd.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.orderable_type_flag+ 0)=0)
    AND ((((o.catalog_type_cd+ 0)=radiology_cd)) OR (((o.activity_type_cd+ 0) IN (
   anatomicpathology_cd, bloodbank_cd, bloodbankmlh_cd, cardiactxprocedures_cd, ecg_cd,
   generallab_cd, micro_cd, pointofcare_cd)))) )
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(pat->qual[dd.seq].lab_rad_ekg,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(pat->qual[dd.seq].lab_rad_ekg,(cnt+ 10))
   ENDIF
   pat->qual[dd.seq].lab_rad_ekg[cnt].order_mnemonic = build(o.order_mnemonic,"[",
    uar_get_code_display(o.order_status_cd),"]"), pat->qual[dd.seq].lab_rad_ekg[cnt].clinical_display
    = o.clinical_display_line
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[dd.seq].lab_rad_ekg,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(pat_cnt)),
   orders o,
   order_comment oc,
   long_text lt
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[dd.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.orderable_type_flag+ 0)=0)
    AND ((o.catalog_cd+ 0) IN (fluidrestriction_cd, trayservicedelivery_cd)))
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
    AND (lt.active_ind= Outerjoin(1)) )
  ORDER BY o.encntr_id, cnvtdatetime(o.orig_order_dt_tm), o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(pat->qual[dd.seq].nut,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(pat->qual[dd.seq].nut,(cnt+ 10))
   ENDIF
   pat->qual[dd.seq].nut[cnt].order_mnemonic = build(o.order_mnemonic,"[",uar_get_code_display(o
     .order_status_cd),"]"), pat->qual[dd.seq].nut[cnt].clinical_display = o.clinical_display_line,
   pat->qual[dd.seq].nut[cnt].com_ind = o.order_comment_ind
   IF (o.order_comment_ind=1)
    pat->qual[dd.seq].nut[cnt].comment = trim(lt.long_text)
   ENDIF
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[dd.seq].nut,cnt)
  WITH nocounter
 ;end select
 FOR (xx = 1 TO pat_cnt)
   SELECT DISTINCT INTO "nl:"
    short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
       .substance_ftdesc))), substance_type_disp =
    IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
    ELSE "Other "
    ENDIF
    FROM allergy a,
     nomenclature n
    PLAN (a
     WHERE (a.person_id=pat->qual[xx].pid)
      AND ((a.active_ind+ 0)=1)
      AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((a.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (a.end_effective_dt_tm=null))
      AND a.reaction_status_cd != allergy_cancelled_cd)
     JOIN (n
     WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
    ORDER BY a.person_id, substance_type_disp, short_source_string
    HEAD REPORT
     temp1 = fillstring(100,""), temp2 = fillstring(1000,""), cnt = 0
    DETAIL
     cnt += 1, temp1 = concat(build(substance_type_disp,": ")," ",short_source_string), pat->qual[xx]
     .allergy = build(temp1,";",temp2),
     temp2 = trim(pat->qual[xx].allergy), temp1 = fillstring(100,"")
    WITH nocounter
   ;end select
 ENDFOR
 CALL echo("problem")
 SELECT INTO "nl"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   problem p,
   nomenclature n
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id= Outerjoin(pat->qual[d1.seq].pid))
    AND (p.active_ind= Outerjoin(1))
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(p.nomenclature_id))
    AND (n.source_vocabulary_cd= Outerjoin(snmct_cd)) )
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD p.person_id
   cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt += 1, stat = alterlist(pat->qual[d1.seq].problems,cnt)
    IF (p.nomenclature_id > 0)
     pat->qual[d1.seq].problems[cnt].problem_line = n.source_string
    ELSE
     pat->qual[d1.seq].problems[cnt].problem_line = p.problem_ftdesc
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(" blood bank")
 SELECT INTO "nl:"
  sort_order =
  IF (o.activity_type_cd=bloodbankproduct_cd) 1
  ELSEIF (o.activity_type_cd=invasivelinestubesdrains_cd) 2
  ELSE 99
  ENDIF
  FROM (dummyt dd  WITH seq = value(pat_cnt)),
   orders o
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[dd.seq].eid)
    AND ((o.order_status_cd+ 0) IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd))
    AND ((o.template_order_flag+ 0) IN (0, 1))
    AND ((o.activity_type_cd+ 0) IN (bloodbankproduct_cd, invasivelinestubesdrains_cd,
   infusiontherapy_cd)))
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(pat->qual[dd.seq].invasive,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(pat->qual[dd.seq].invasive,(cnt+ 10))
   ENDIF
   pat->qual[dd.seq].invasive[cnt].order_mnemonic = o.ordered_as_mnemonic, pat->qual[dd.seq].
   invasive[cnt].clinical_display = o.clinical_display_line, pat->qual[dd.seq].invasive[cnt].
   verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     pat->qual[dd.seq].invasive[cnt].verify_str = "(Verified)"
    OF 1:
     pat->qual[dd.seq].invasive[cnt].verify_str = "(Unverified)"
    OF 2:
     pat->qual[dd.seq].invasive[cnt].verify_str = "(Rejected)"
   ENDCASE
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[dd.seq].invasive,cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO pat_cnt)
   FREE RECORD temp
   RECORD temp(
     1 qual[*]
       2 display = vc
   )
   FREE RECORD pt
   RECORD pt(
     1 line_cnt = i2
     1 lns[*]
       2 line = vc
   )
   SELECT INTO "nl:"
    FROM orders o,
     order_detail od,
     order_entry_fields oef
    PLAN (o
     WHERE (o.encntr_id=pat->qual[x].eid)
      AND o.catalog_cd IN (code_status_cd1, code_status_cd2, code_status_cd3, code_status_cd4,
     code_status_cd5,
     code_status_cd6, code_status_cd7, code_status_cd8, code_status_cd9)
      AND o.order_status_cd=os_ord_cd)
     JOIN (od
     WHERE (od.order_id= Outerjoin(o.order_id))
      AND (od.oe_field_meaning= Outerjoin("OTHER")) )
     JOIN (oef
     WHERE (oef.oe_field_id= Outerjoin(od.oe_field_id)) )
    ORDER BY o.order_id, od.detail_sequence
    HEAD REPORT
     cnt = 0
    HEAD o.order_id
     pat->qual[x].code_status_name = trim(o.order_mnemonic)
    DETAIL
     cnt += 1, stat = alterlist(pat->qual[x].code_status_detail,cnt), pat->qual[x].
     code_status_detail[cnt].display = concat(trim(oef.description),": ",trim(od
       .oe_field_display_value))
    WITH nocounter
   ;end select
   SET pt->line_cnt = 0
   SET max_length = 85
   SET cnt = 0
   SET line_cnt = 0
   FOR (od = 1 TO size(pat->qual[x].code_status_detail,5))
     SET tempstring = fillstring(500,"")
     SET tempstring = trim(pat->qual[x].code_status_detail[od].display)
     EXECUTE dcp_parse_text value(tempstring), value(max_length)
     SET stat = alterlist(temp->qual,(cnt+ pt->line_cnt))
     FOR (line_cnt = 1 TO pt->line_cnt)
      SET cnt += 1
      SET temp->qual[cnt].display = trim(pt->lns[line_cnt].line)
     ENDFOR
   ENDFOR
   SET stat = alterlist(pat->qual[x].code_status_detail,size(temp->qual,5))
   FOR (od2 = 1 TO size(temp->qual,5))
     SET pat->qual[x].code_status_detail[od2].display = trim(temp->qual[od2].display)
   ENDFOR
 ENDFOR
 CALL echo("outside: ")
 CALL echo(pat_cnt)
 DECLARE sign_cd = f8 WITH protect, constant(uar_get_code_by("displaykey",21,"SIGN"))
 FOR (x = 1 TO pat_cnt)
   EXECUTE bhs_sys_pause 10
   SET personid = pat->qual[x].pid
   SET encntrid = pat->qual[x].eid
   CALL echo("inside the loop")
   FREE RECORD scheduled_orders
   RECORD scheduled_orders(
     1 qual[*]
       2 order_id = f8
       2 true_parent = i2
       2 order_detail = vc
       2 order_name = vc
       2 comm_cnt = i2
       2 comment[*]
         3 comment = vc
       2 print_ind = i2
       2 child_ord[*]
         3 order_id = f8
         3 start_dt = dq8
         3 order_mnemonic = vc
   )
   FREE RECORD scheduled_orders_disp
   RECORD scheduled_orders_disp(
     1 scheduled_orders[*]
       2 template_order_id = f8
       2 comment[*]
         3 comment = vc
       2 orig_order_dt_tm = dq8
       2 mnemonic = vc
       2 ordered_as_mnemonic = vc
       2 hna_mnemonic = vc
       2 voided_ind = i2
       2 core_actions[*]
         3 order_id = f8
         3 action_seq = i4
         3 action = c40
         3 action_dt_tm = dq8
         3 clinical_display_line = vc
         3 detail_value = f8
         3 detail_assigned = i2
       2 admins[*]
         3 order_id = f8
         3 parent_event_id = f8
         3 event_id = f8
         3 verified_dt_tm = dq8
         3 verified_prsnl_id = f8
         3 valid_from_dt_tm = dq8
         3 event_title_text = vc
         3 event_end_dt_tm = dq8
         3 result_status_meaning = c12
         3 result_status_display = c40
         3 from_ccr = i2
         3 not_given_reason = vc
         3 admin_start_dt_tm = dq8
         3 dosage_value = f8
         3 dosage_unit = c40
         3 site = c40
         3 admin_by_id = f8
         3 route = c40
         3 vital_signs[*]
           4 event_id = f8
           4 vital_sign = c40
           4 value = vc
           4 unit = c40
           4 normalcy_cd = f8
   )
   FREE RECORD prn_orders
   RECORD prn_orders(
     1 qual[*]
       2 order_id = f8
       2 true_parent = i2
       2 order_detail = vc
       2 order_name = vc
       2 comment = vc
       2 print_ind = i2
       2 child_ord[*]
         3 order_id = f8
         3 start_dt = dq8
         3 order_mnemonic = vc
   )
   FREE RECORD prn_orders_disp
   RECORD prn_orders_disp(
     1 prn_orders[*]
       2 order_id = f8
       2 comment = vc
       2 com_cnt = i2
       2 comment[*]
         3 comment = vc
       2 orig_order_dt_tm = dq8
       2 mnemonic = vc
       2 ordered_as_mnemonic = vc
       2 hna_mnemonic = vc
       2 voided_ind = i2
       2 core_actions[*]
         3 order_id = f8
         3 action_seq = i4
         3 action = c40
         3 action_dt_tm = dq8
         3 clinical_display_line = vc
         3 detail_value = f8
         3 detail_assigned = i2
       2 admins[*]
         3 order_id = f8
         3 parent_event_id = f8
         3 event_id = f8
         3 verified_dt_tm = dq8
         3 verified_prsnl_id = f8
         3 valid_from_dt_tm = dq8
         3 event_title_text = vc
         3 event_end_dt_tm = dq8
         3 result_status_meaning = c12
         3 result_status_display = c40
         3 from_ccr = i2
         3 not_given_reason = vc
         3 admin_start_dt_tm = dq8
         3 dosage_value = f8
         3 dosage_unit = c40
         3 site = c40
         3 admin_by_id = f8
         3 route = c40
         3 vital_signs[*]
           4 event_id = f8
           4 vital_sign = c40
           4 value = vc
           4 unit = c40
           4 normalcy_cd = f8
   )
   FREE RECORD continuous_orders
   RECORD continuous_orders(
     1 qual[*]
       2 order_id = f8
       2 true_parent = i2
       2 order_detail = vc
       2 order_name = vc
       2 comment = vc
       2 print_ind = i2
       2 child_ord[*]
         3 order_id = f8
         3 start_dt = dq8
         3 order_mnemonic = vc
   )
   FREE RECORD continuous_orders_disp
   RECORD continuous_orders_disp(
     1 continuous_orders[*]
       2 order_id = f8
       2 comment = vc
       2 com_cnt = i2
       2 comment[*]
         3 comment = vc
       2 orig_order_dt_tm = dq8
       2 mnemonic = vc
       2 ordered_as_mnemonic = vc
       2 hna_mnemonic = vc
       2 voided_ind = i2
       2 core_actions[*]
         3 action_seq = i4
         3 action_dt_tm = dq8
         3 action = c40
         3 clinical_display_line = vc
       2 admins[*]
         3 parent_event_id = f8
         3 event_id = f8
         3 verified_dt_tm = dq8
         3 verified_prsnl_id = f8
         3 valid_from_dt_tm = dq8
         3 event_title_text = vc
         3 event_end_dt_tm = dq8
         3 result_status_meaning = c12
         3 result_status_display = c40
         3 from_ccr = i2
         3 not_given_reason = vc
         3 iv_event_meaning = c12
         3 iv_event_display = c40
         3 admin_start_dt_tm = dq8
         3 init_dosage = f8
         3 dosage_unit = c40
         3 initial_volume = f8
         3 infusion_rate = f8
         3 infusion_unit = c40
         3 site = c40
         3 admin_by_id = f8
         3 route = c40
         3 comments[*]
           4 comment_type = c40
           4 text = vc
           4 commenter_id = f8
           4 note_dt_tm = dq8
           4 format = c12
   )
   FREE RECORD m_home_meds
   RECORD m_home_meds(
     1 l_cnt = i4
     1 qual[*]
       2 s_order_name = vc
       2 s_order_disp_line = vc
       2 s_status = vc
       2 f_order_id = f8
   ) WITH protect
   FREE RECORD m_fut_ord
   RECORD m_fut_ord(
     1 l_cnt = i4
     1 qual[*]
       2 f_order_id = f8
       2 s_ord_mnemonic = vc
       2 s_clin_display = vc
   )
   FREE RECORD m_inc_ord
   RECORD m_inc_ord(
     1 l_cnt = i4
     1 qual[*]
       2 f_order_id = f8
       2 s_ord_mnemonic = vc
       2 s_clin_display = vc
   )
   SELECT INTO "nl:"
    FROM orders o
    PLAN (o
     WHERE o.person_id=personid
      AND o.template_order_flag IN (0, 1)
      AND o.orig_ord_as_flag IN (1, 2)
      AND o.catalog_type_cd=pharmacy
      AND o.order_status_cd=os_ord_cd)
    ORDER BY o.order_id
    HEAD REPORT
     m_home_meds->l_cnt = 0
    HEAD o.order_id
     m_home_meds->l_cnt += 1, stat = alterlist(m_home_meds->qual,m_home_meds->l_cnt), m_home_meds->
     qual[m_home_meds->l_cnt].f_order_id = o.order_id,
     m_home_meds->qual[m_home_meds->l_cnt].s_order_name = build(o.order_mnemonic,"(",o
      .ordered_as_mnemonic,")"), m_home_meds->qual[m_home_meds->l_cnt].s_order_disp_line = trim(o
      .clinical_display_line,3)
     IF (o.orig_ord_as_flag=1)
      m_home_meds->qual[m_home_meds->l_cnt].s_status = "Prescribed"
     ELSE
      m_home_meds->qual[m_home_meds->l_cnt].s_status = "Documented"
     ENDIF
    WITH nocounter
   ;end select
   SET iv_cd2 = uar_get_code_by("DISPLAYKEY",18309,"IV")
   SET intermittent_cd2 = uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT")
   SET ivsolutions_cd2 = uar_get_code_by("DISPLAYKEY",16389,"IVSOLUTIONS")
   SELECT INTO "nl:"
    FROM orders o
    WHERE o.person_id=personid
     AND o.encntr_id=encntrid
     AND o.order_status_cd=mf_cs6004_incomplete_cd
    ORDER BY o.order_id
    HEAD o.order_id
     m_inc_ord->l_cnt += 1, stat = alterlist(m_inc_ord->qual,m_inc_ord->l_cnt), m_inc_ord->qual[
     m_inc_ord->l_cnt].f_order_id = o.order_id,
     m_inc_ord->qual[m_inc_ord->l_cnt].s_ord_mnemonic = concat(trim(o.order_mnemonic,3),"(",trim(o
       .ordered_as_mnemonic,3),")"), m_inc_ord->qual[m_inc_ord->l_cnt].s_clin_display = trim(o
      .clinical_display_line,3)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM orders o
    WHERE o.person_id=personid
     AND o.encntr_id=0.0
     AND o.order_status_cd=mf_cs6004_future_cd
    ORDER BY o.order_id
    HEAD o.order_id
     m_fut_ord->l_cnt += 1, stat = alterlist(m_fut_ord->qual,m_fut_ord->l_cnt), m_fut_ord->qual[
     m_fut_ord->l_cnt].f_order_id = o.order_id,
     m_fut_ord->qual[m_fut_ord->l_cnt].s_ord_mnemonic = concat(trim(o.order_mnemonic,3),"(",trim(o
       .ordered_as_mnemonic,3),")"), m_fut_ord->qual[m_fut_ord->l_cnt].s_clin_display = trim(o
      .clinical_display_line,3)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    mso =
    IF (((o.med_order_type_cd IN (iv_cd2, intermittent_cd2)) OR (o.dcp_clin_cat_cd=ivsolutions_cd2))
    ) 4
    ELSEIF (o.prn_ind=0
     AND o.freq_type_flag != 5) 1
    ELSEIF (o.prn_ind=0
     AND o.freq_type_flag=5) 2
    ELSEIF (o.prn_ind=1) 3
    ENDIF
    FROM orders o
    WHERE o.encntr_id=encntrid
     AND o.catalog_type_cd=pharmacy
     AND o.order_status_cd IN (os_fut_cd, os_inp_cd, os_inc_cd, os_ord_cd, os_pen_cd,
    os_per_cd)
     AND o.template_order_flag IN (0, 1)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))
    ORDER BY mso
    HEAD REPORT
     xcnt = 0, ycnt = 0, zcnt = 0,
     stat = alterlist(scheduled_orders->qual,10), stat = alterlist(prn_orders->qual,10), stat =
     alterlist(continuous_orders->qual,10)
    DETAIL
     CASE (mso)
      OF 1:
       xcnt += 1,
       IF (mod(xcnt,10)=1)
        stat = alterlist(scheduled_orders->qual,(xcnt+ 10))
       ENDIF
       ,scheduled_orders->qual[xcnt].order_id = o.order_id,scheduled_orders->qual[xcnt].order_name =
       build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"),scheduled_orders->qual[xcnt].
       order_detail = trim(o.clinical_display_line)
      OF 2:
       xcnt += 1,
       IF (mod(xcnt,10)=1)
        stat = alterlist(scheduled_orders->qual,(xcnt+ 10))
       ENDIF
       ,scheduled_orders->qual[xcnt].order_id = o.order_id,scheduled_orders->qual[xcnt].order_name =
       build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"),scheduled_orders->qual[xcnt].
       order_detail = trim(o.clinical_display_line)
      OF 3:
       ycnt += 1,
       IF (mod(ycnt,10)=1)
        stat = alterlist(prn_orders->qual,(ycnt+ 10))
       ENDIF
       ,prn_orders->qual[ycnt].order_id = o.order_id,prn_orders->qual[ycnt].order_name = build(o
        .order_mnemonic,"(",o.ordered_as_mnemonic,")"),prn_orders->qual[ycnt].order_detail = trim(o
        .clinical_display_line)
      OF 4:
       zcnt += 1,
       IF (mod(zcnt,10)=1)
        stat = alterlist(continuous_orders->qual,(zcnt+ 10))
       ENDIF
       ,continuous_orders->qual[zcnt].order_id = o.order_id,continuous_orders->qual[zcnt].order_name
        = build(o.order_mnemonic,"(",o.ordered_as_mnemonic,")"),continuous_orders->qual[zcnt].
       order_detail = trim(o.clinical_display_line)
     ENDCASE
    FOOT REPORT
     stat = alterlist(scheduled_orders->qual,xcnt), stat = alterlist(prn_orders->qual,ycnt), stat =
     alterlist(continuous_orders->qual,zcnt)
    WITH nocounter
   ;end select
   CALL echo("Schedule meds")
   SET sch_med_cnt = size(scheduled_orders->qual,5)
   IF (sch_med_cnt > 0)
    SELECT DISTINCT INTO "nl:"
     check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
      "csr"), template_order_id = scheduled_orders->qual[d1.seq].order_id
     FROM orders o,
      order_action oa,
      clinical_event ce,
      ce_med_result cmr,
      ce_coded_result ccr,
      ce_string_result csr,
      (dummyt d1  WITH seq = value(size(scheduled_orders->qual,5))),
      dummyt d2,
      dummyt d3,
      dummyt d4
     PLAN (d1)
      JOIN (o
      WHERE (o.template_order_id=scheduled_orders->qual[d1.seq].order_id)
       AND (scheduled_orders->qual[d1.seq].true_parent=1))
      JOIN (oa
      WHERE oa.order_id=o.template_order_id
       AND ((oa.core_ind+ 0)=1))
      JOIN (ce
      WHERE ce.order_id=o.order_id
       AND ((ce.person_id+ 0)=personid)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ((ce.event_class_cd+ 0)=med_type_cd)
       AND ((ce.publish_flag+ 0)=1))
      JOIN (d2)
      JOIN (((cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d3)
      JOIN (((ccr
      WHERE ccr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d4)
      JOIN (csr
      WHERE csr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      )) ))
     ORDER BY template_order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC
     HEAD REPORT
      actioncnt = 0, admincnt = 0
     HEAD template_order_id
      schedordercnt += 1, stat = alterlist(scheduled_orders_disp->scheduled_orders,schedordercnt),
      scheduled_orders_disp->scheduled_orders[schedordercnt].template_order_id = template_order_id,
      scheduled_orders_disp->scheduled_orders[schedordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
      scheduled_orders_disp->scheduled_orders[schedordercnt].mnemonic = o.order_mnemonic,
      scheduled_orders_disp->scheduled_orders[schedordercnt].ordered_as_mnemonic = o
      .ordered_as_mnemonic,
      scheduled_orders_disp->scheduled_orders[schedordercnt].hna_mnemonic = o.hna_order_mnemonic
     HEAD oa.action_sequence
      actioncnt += 1, stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].
       core_actions,actioncnt), scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[
      actioncnt].order_id = oa.order_id,
      scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].action_seq = oa
      .action_sequence, scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt
      ].action_dt_tm = oa.action_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].
      core_actions[actioncnt].action = uar_get_code_display(oa.action_type_cd),
      scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].
      clinical_display_line = oa.clinical_display_line
     DETAIL
      IF (actioncnt=1)
       admincnt += 1, stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].admins,
        admincnt), scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].order_id
        = o.order_id,
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].parent_event_id = ce
       .parent_event_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
       event_id = ce.event_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt
       ].verified_dt_tm = ce.verified_dt_tm,
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].verified_prsnl_id = ce
       .verified_prsnl_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
       valid_from_dt_tm = ce.valid_from_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt]
       .admins[admincnt].event_title_text = ce.event_title_text,
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].event_end_dt_tm = ce
       .event_end_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
       result_status_meaning = uar_get_code_meaning(ce.result_status_cd), scheduled_orders_disp->
       scheduled_orders[schedordercnt].admins[admincnt].result_status_display = uar_get_code_display(
        ce.result_status_cd),
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].admin_by_id = ce
       .performed_prsnl_id
       IF (check="cmr")
        scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].admin_start_dt_tm =
        cmr.admin_start_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt
        ].dosage_unit = uar_get_code_display(cmr.dosage_unit_cd), scheduled_orders_disp->
        scheduled_orders[schedordercnt].admins[admincnt].dosage_value = cmr.admin_dosage,
        scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].site =
        uar_get_code_display(cmr.admin_site_cd), scheduled_orders_disp->scheduled_orders[
        schedordercnt].admins[admincnt].route = uar_get_code_display(cmr.admin_route_cd)
       ELSEIF (check="ccr")
        scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].not_given_reason =
        uar_get_code_display(ccr.result_cd), scheduled_orders_disp->scheduled_orders[schedordercnt].
        admins[admincnt].from_ccr = 1
       ELSE
        IF ((scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].from_ccr != 1))
         scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].not_given_reason =
         csr.string_result_text
        ENDIF
       ENDIF
      ENDIF
     FOOT  template_order_id
      admincnt = 0, actioncnt = 0
     FOOT REPORT
      do_nothing = 0
     WITH nocounter
    ;end select
    CALL echo("END of SELECT")
   ENDIF
   SET prn_med_cnt = size(prn_orders->qual,5)
   IF (prn_med_cnt > 0)
    SELECT DISTINCT INTO "nl:"
     check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
      "csr")
     FROM orders o,
      order_action oa,
      clinical_event ce,
      ce_med_result cmr,
      ce_coded_result ccr,
      ce_string_result csr,
      (dummyt d1  WITH seq = value(size(prn_orders->qual,5))),
      dummyt d2,
      dummyt d3,
      dummyt d4
     PLAN (d1)
      JOIN (o
      WHERE (o.order_id=prn_orders->qual[d1.seq].order_id))
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.core_ind=1)
      JOIN (ce
      WHERE ce.order_id=oa.order_id
       AND ((ce.person_id+ 0)=personid)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ((ce.event_class_cd+ 0)=med_type_cd)
       AND ((ce.publish_flag+ 0)=1))
      JOIN (d2)
      JOIN (((cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d3)
      JOIN (((ccr
      WHERE ccr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d4)
      JOIN (csr
      WHERE csr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      )) ))
     ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      ce.event_id
     HEAD REPORT
      ordercnt = 0, actioncnt = 0, admincnt = 0
     HEAD o.order_id
      ordercnt += 1
      IF (mod(ordercnt,10)=1)
       stat = alterlist(prn_orders_disp->prn_orders,(ordercnt+ 9))
      ENDIF
      prn_orders_disp->prn_orders[ordercnt].order_id = o.order_id, prn_orders_disp->prn_orders[
      ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, prn_orders_disp->prn_orders[ordercnt].mnemonic
       = o.order_mnemonic,
      prn_orders_disp->prn_orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
      prn_orders_disp->prn_orders[ordercnt].hna_mnemonic = o.hna_order_mnemonic
      IF (o.order_status_cd=voided_cd)
       prn_orders_disp->prn_orders[ordercnt].voided_ind = 1
      ENDIF
     HEAD oa.action_sequence
      actioncnt += 1
      IF (mod(actioncnt,5)=1)
       stat = alterlist(prn_orders_disp->prn_orders[ordercnt].core_actions,(actioncnt+ 4))
      ENDIF
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].order_id = oa.order_id,
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action_seq = oa.action_sequence,
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action = uar_get_code_display(oa
       .action_type_cd), prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].
      clinical_display_line = oa.clinical_display_line
     DETAIL
      IF (actioncnt=1)
       admincnt += 1
       IF (mod(admincnt,10)=1)
        stat = alterlist(prn_orders_disp->prn_orders[ordercnt].admins,(admincnt+ 9))
       ENDIF
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].order_id = o.order_id, prn_orders_disp
       ->prn_orders[ordercnt].admins[admincnt].parent_event_id = ce.parent_event_id, prn_orders_disp
       ->prn_orders[ordercnt].admins[admincnt].event_id = ce.event_id,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].verified_dt_tm = ce.verified_dt_tm,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].verified_prsnl_id = ce
       .verified_prsnl_id, prn_orders_disp->prn_orders[ordercnt].admins[admincnt].valid_from_dt_tm =
       ce.valid_from_dt_tm,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].event_title_text = ce.event_title_text,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].event_end_dt_tm = ce.event_end_dt_tm,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].result_status_meaning =
       uar_get_code_meaning(ce.result_status_cd),
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].result_status_display =
       uar_get_code_display(ce.result_status_cd), prn_orders_disp->prn_orders[ordercnt].admins[
       admincnt].admin_by_id = ce.performed_prsnl_id
       IF (check="cmr")
        prn_orders_disp->prn_orders[ordercnt].admins[admincnt].admin_start_dt_tm = cmr
        .admin_start_dt_tm, prn_orders_disp->prn_orders[ordercnt].admins[admincnt].dosage_unit =
        uar_get_code_display(cmr.dosage_unit_cd), prn_orders_disp->prn_orders[ordercnt].admins[
        admincnt].dosage_value = cmr.admin_dosage,
        prn_orders_disp->prn_orders[ordercnt].admins[admincnt].site = uar_get_code_display(cmr
         .admin_site_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt].route =
        uar_get_code_display(cmr.admin_route_cd)
       ELSEIF (check="ccr")
        prn_orders_disp->prn_orders[ordercnt].admins[admincnt].not_given_reason =
        uar_get_code_display(ccr.result_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt].
        from_ccr = 1
       ELSE
        IF ((prn_orders_disp->prn_orders[ordercnt].admins[admincnt].from_ccr != 1))
         prn_orders_disp->prn_orders[ordercnt].admins[admincnt].not_given_reason = csr
         .string_result_text
        ENDIF
       ENDIF
      ENDIF
     FOOT  oa.action_sequence
      do_nothing = 0
     FOOT  o.order_id
      stat = alterlist(prn_orders_disp->prn_orders[ordercnt].core_actions,actioncnt), stat =
      alterlist(prn_orders_disp->prn_orders[ordercnt].admins,admincnt), max_num_prn_actions = maxval(
       max_num_prn_actions,actioncnt),
      max_num_prn_admins = maxval(max_num_prn_admins,admincnt), actioncnt = 0, admincnt = 0
     FOOT REPORT
      stat = alterlist(prn_orders_disp->prn_orders,ordercnt)
     WITH nocounter
    ;end select
   ENDIF
   SET cont_med_cnt = size(continuous_orders->qual,5)
   IF (cont_med_cnt > 0)
    SELECT DISTINCT INTO "nl:"
     check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
      "csr")
     FROM orders o,
      order_action oa,
      clinical_event ce,
      ce_med_result cmr,
      ce_coded_result ccr,
      ce_string_result csr,
      (dummyt d1  WITH seq = value(size(continuous_orders->qual,5))),
      dummyt d2,
      dummyt d3,
      dummyt d4
     PLAN (d1)
      JOIN (o
      WHERE (o.order_id=continuous_orders->qual[d1.seq].order_id))
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.core_ind=1)
      JOIN (ce
      WHERE ce.order_id=oa.order_id
       AND ((ce.person_id+ 0)=personid)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ((ce.event_class_cd+ 0)=med_type_cd)
       AND ((ce.publish_flag+ 0)=1))
      JOIN (d2)
      JOIN (((cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND cmr.iv_event_cd IN (begin_bag_cd, site_chg_cd, rate_chg_cd))
      ) ORJOIN ((d3)
      JOIN (((ccr
      WHERE ccr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d4)
      JOIN (csr
      WHERE csr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      )) ))
     ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      ce.event_id
     HEAD REPORT
      ordercnt = 0, actioncnt = 0, admincnt = 0
     HEAD o.order_id
      ordercnt += 1
      IF (mod(ordercnt,10)=1)
       stat = alterlist(continuous_orders_disp->continuous_orders,(ordercnt+ 9))
      ENDIF
      continuous_orders_disp->continuous_orders[ordercnt].order_id = o.order_id,
      continuous_orders_disp->continuous_orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
      continuous_orders_disp->continuous_orders[ordercnt].mnemonic = o.order_mnemonic,
      continuous_orders_disp->continuous_orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
      continuous_orders_disp->continuous_orders[ordercnt].hna_mnemonic = o.hna_order_mnemonic
      IF (o.order_status_cd=voided_cd)
       continuous_orders_disp->continuous_orders[ordercnt].voided_ind = 1
      ENDIF
     HEAD oa.action_sequence
      actioncnt += 1
      IF (mod(actioncnt,5)=1)
       stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].core_actions,(actioncnt+
        4))
      ENDIF
      continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].action_seq = oa
      .action_sequence, continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].
      action_dt_tm = oa.action_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].
      core_actions[actioncnt].action = uar_get_code_display(oa.action_type_cd),
      continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].
      clinical_display_line = oa.clinical_display_line
     DETAIL
      IF (actioncnt=1)
       admincnt += 1
       IF (mod(admincnt,10)=1)
        stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].admins,(admincnt+ 9))
       ENDIF
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].parent_event_id = ce
       .parent_event_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       event_id = ce.event_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       verified_dt_tm = ce.verified_dt_tm,
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].verified_prsnl_id = ce
       .verified_prsnl_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       valid_from_dt_tm = ce.valid_from_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].
       admins[admincnt].event_title_text = ce.event_title_text,
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].event_end_dt_tm = ce
       .event_end_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       result_status_meaning = uar_get_code_meaning(ce.result_status_cd), continuous_orders_disp->
       continuous_orders[ordercnt].admins[admincnt].result_status_display = uar_get_code_display(ce
        .result_status_cd),
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].admin_by_id = ce
       .performed_prsnl_id
       IF (check="cmr")
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].iv_event_meaning =
        uar_get_code_meaning(cmr.iv_event_cd), continuous_orders_disp->continuous_orders[ordercnt].
        admins[admincnt].iv_event_display = uar_get_code_display(cmr.iv_event_cd),
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].admin_start_dt_tm = cmr
        .admin_start_dt_tm,
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].init_dosage = cmr
        .initial_dosage, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
        dosage_unit = uar_get_code_display(cmr.dosage_unit_cd), continuous_orders_disp->
        continuous_orders[ordercnt].admins[admincnt].initial_volume = cmr.initial_volume,
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].infusion_rate = cmr
        .infusion_rate, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
        infusion_unit = uar_get_code_display(cmr.infusion_unit_cd), continuous_orders_disp->
        continuous_orders[ordercnt].admins[admincnt].site = uar_get_code_display(cmr.admin_site_cd),
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].route =
        uar_get_code_display(cmr.admin_route_cd)
       ELSEIF (check="ccr")
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].not_given_reason =
        uar_get_code_display(ccr.result_cd), continuous_orders_disp->continuous_orders[ordercnt].
        admins[admincnt].from_ccr = 1
       ELSE
        IF ((continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].from_ccr != 1))
         continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].not_given_reason = csr
         .string_result_text
        ENDIF
       ENDIF
      ENDIF
     FOOT  oa.action_sequence
      do_nothing = 0
     FOOT  o.order_id
      stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].core_actions,actioncnt),
      stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].admins,admincnt),
      max_num_cont_admins = maxval(max_num_cont_admins,admincnt),
      max_num_cont_actions = maxval(max_num_cont_actions,actioncnt), actioncnt = 0, admincnt = 0
     FOOT REPORT
      stat = alterlist(continuous_orders_disp->continuous_orders,ordercnt)
     WITH nocounter
    ;end select
   ENDIF
   FOR (xx = 1 TO size(scheduled_orders->qual,5))
    SELECT INTO "nl:"
     FROM orders o
     PLAN (o
      WHERE (o.template_order_id=scheduled_orders->qual[xx].order_id)
       AND o.template_order_id > 0
       AND o.current_start_dt_tm > cnvtdatetime(sysdate))
     ORDER BY o.current_start_dt_tm, o.order_id
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1, stat = alterlist(scheduled_orders->qual[xx].child_ord,cnt), scheduled_orders->qual[xx
      ].child_ord[cnt].order_id = o.order_id,
      scheduled_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, scheduled_orders->
      qual[xx].child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     len = textlen(lt.long_text)
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE (oc.order_id=scheduled_orders->qual[xx].order_id))
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id
       AND ((lt.active_ind+ 0)=1))
     HEAD REPORT
      b_linefeed = char(10), b_cr = char(13), b_cc = 0,
      b_s = 1, b_len = 0, b_e = 0,
      b_tmp_comment = fillstring(90,""), tmp_var = 0
     DETAIL
      b_cc = 1, scheduled_orders->qual[xx].comm_cnt = 0, b_s = 1
      WHILE (b_cc)
        b_tmp_comment = substring(b_s,90,lt.long_text), b_e = findstring(b_linefeed,b_tmp_comment,1)
        IF (b_e)
         scheduled_orders->qual[xx].comm_cnt += 1, tmp_var = scheduled_orders->qual[xx].comm_cnt,
         stat = alterlist(scheduled_orders->qual[xx].comment,tmp_var),
         scheduled_orders->qual[xx].comment[tmp_var].comment = substring(1,b_e,b_tmp_comment), b_s
          += b_e
        ELSE
         IF (b_tmp_comment > " ")
          scheduled_orders->qual[xx].comm_cnt += 1, tmp_var = scheduled_orders->qual[xx].comm_cnt,
          stat = alterlist(scheduled_orders->qual[xx].comment,tmp_var),
          scheduled_orders->qual[xx].comment[tmp_var].comment = b_tmp_comment, b_s += 90
         ELSE
          b_cc = 0
         ENDIF
        ENDIF
      ENDWHILE
     WITH nocounter
    ;end select
   ENDFOR
   FOR (xx = 1 TO size(prn_orders->qual,5))
     SELECT INTO "nl:"
      FROM orders o,
       order_comment oc,
       long_text lt
      PLAN (o
       WHERE (o.order_id=prn_orders->qual[xx].order_id))
       JOIN (oc
       WHERE (oc.order_id= Outerjoin(o.order_id)) )
       JOIN (lt
       WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
        AND (lt.active_ind= Outerjoin(1)) )
      ORDER BY o.current_start_dt_tm
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt += 1, stat = alterlist(prn_orders->qual[xx].child_ord,cnt), prn_orders->qual[xx].
       child_ord[cnt].order_id = o.order_id,
       prn_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, prn_orders->qual[xx].
       child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
       IF (o.order_comment_ind=1)
        prn_orders->qual[xx].comment = lt.long_text
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   FOR (p1 = 1 TO size(prn_orders->qual,5))
     FOR (p2 = 1 TO size(prn_orders_disp->prn_orders,5))
       IF ((prn_orders->qual[p1].order_id=prn_orders_disp->prn_orders[p2].order_id))
        SET prn_orders->qual[p1].print_ind = 1
        SET prn_orders_disp->prn_orders[p2].comment = prn_orders->qual[p1].comment
       ENDIF
     ENDFOR
   ENDFOR
   FOR (xx = 1 TO size(continuous_orders->qual,5))
     SELECT INTO "nl:"
      FROM orders o,
       order_comment oc,
       long_text lt
      PLAN (o
       WHERE (o.order_id=continuous_orders->qual[xx].order_id))
       JOIN (oc
       WHERE (oc.order_id= Outerjoin(o.order_id)) )
       JOIN (lt
       WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
        AND (lt.active_ind= Outerjoin(1)) )
      ORDER BY o.current_start_dt_tm
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt += 1, stat = alterlist(continuous_orders->qual[xx].child_ord,cnt), continuous_orders->
       qual[xx].child_ord[cnt].order_id = o.order_id,
       continuous_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, continuous_orders
       ->qual[xx].child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
       IF (o.order_comment_ind=1)
        continuous_orders->qual[xx].comment = lt.long_text
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   FOR (c1 = 1 TO size(continuous_orders->qual,5))
     FOR (c2 = 1 TO size(continuous_orders_disp->continuous_orders,5))
       IF ((continuous_orders->qual[c1].order_id=continuous_orders_disp->continuous_orders[c2].
       order_id))
        SET continuous_orders->qual[c1].print_ind = 1
        SET continuous_orders_disp->continuous_orders[c2].comment = continuous_orders->qual[c1].
        comment
       ENDIF
     ENDFOR
   ENDFOR
   FREE RECORD sw
   RECORD sw(
     1 consultstatus = vc
     1 planoutcome = vc
     1 commnets = vc
     1 reportfiled = vc
     1 language = vc
     1 reasonforref = vc
   )
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.encntr_id=encntrid
      AND ce.event_cd IN (language_spoken_cd, planoutcome, mandatedreport, consultstatus, plancommnet,
     reasonforref)
      AND ce.result_status_cd != inerror_cd
      AND ce.result_val > ""
      AND ce.view_level=1)
    DETAIL
     IF (ce.event_cd=language_spoken_cd)
      sw->language = trim(ce.result_val)
     ELSEIF (ce.event_cd=planoutcome)
      sw->planoutcome = trim(ce.result_val)
     ELSEIF (ce.event_cd=mandatedreport)
      sw->reportfiled = trim(ce.result_val)
     ELSEIF (ce.event_cd=consultstatus)
      sw->consultstatus = trim(ce.result_val)
     ELSEIF (ce.event_cd=plancommnet)
      sw->commnets = trim(ce.result_val)
     ELSEIF (ce.event_cd=reasonforref)
      sw->reasonforref = trim(ce.result_val)
     ENDIF
    WITH nocounter
   ;end select
   FREE RECORD pt_note
   RECORD pt_note(
     1 l_note_cnt = i4
     1 note_qual[*]
       2 f_event_cd = f8
       2 s_note_type = vc
       2 s_note_date = vc
       2 l_blob_cnt = i4
       2 blobs_qual[*]
         3 s_event_title_text = vc
         3 s_blob_contents = vc
         3 f_event_id = f8
         3 l_blob_length = i4
         3 f_comp_cd = f8
         3 l_blobseq = i4
         3 s_blob_nortf = vc
   ) WITH protect
   SELECT INTO "nl:"
    FROM clinical_event ce,
     clinical_event ce1,
     ce_blob ceb
    PLAN (ce
     WHERE ce.encntr_id=encntrid
      AND ce.publish_flag=1
      AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
      AND  NOT (ce.result_status_cd IN (inerror_cd))
      AND expand(ml_idx,1,m_cv_rec->l_cnt,ce.event_cd,m_cv_rec->qual[ml_idx].f_code_value))
     JOIN (ce1
     WHERE ce1.parent_event_id=ce.parent_event_id
      AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
     JOIN (ceb
     WHERE ceb.event_id=ce1.event_id
      AND ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
    ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id, ce1.event_id
    HEAD REPORT
     pt_note->l_note_cnt = 0, cnt_blobs = 0
    HEAD ce.event_end_dt_tm
     null
    HEAD ce.parent_event_id
     pt_note->l_note_cnt += 1, stat = alterlist(pt_note->note_qual,pt_note->l_note_cnt), pt_note->
     note_qual[pt_note->l_note_cnt].f_event_cd = ce.event_cd,
     pt_note->note_qual[pt_note->l_note_cnt].s_note_type = uar_get_code_display(ce.event_cd), pt_note
     ->note_qual[pt_note->l_note_cnt].s_note_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
     pt_note->note_qual[pt_note->l_note_cnt].l_blob_cnt = 0
    HEAD ce1.event_id
     pt_note->note_qual[pt_note->l_note_cnt].l_blob_cnt += 1, stat = alterlist(pt_note->note_qual[
      pt_note->l_note_cnt].blobs_qual,pt_note->note_qual[pt_note->l_note_cnt].l_blob_cnt), pt_note->
     note_qual[pt_note->l_note_cnt].blobs_qual[pt_note->note_qual[pt_note->l_note_cnt].l_blob_cnt].
     f_event_id = ceb.event_id,
     pt_note->note_qual[pt_note->l_note_cnt].blobs_qual[pt_note->note_qual[pt_note->l_note_cnt].
     l_blob_cnt].s_event_title_text = trim(ce1.event_title_text,3)
    WITH nocounter
   ;end select
   CALL echorecord(pt_note)
   CALL echo(encntrid)
   FOR (ml_idx = 1 TO size(pt_note->note_qual,5))
     FOR (ml_idx2 = 1 TO size(pt_note->note_qual[ml_idx].blobs_qual,5))
       SET pt_note->note_qual[ml_idx].blobs_qual[ml_idx2].s_blob_nortf = bhs_sbr_get_blob(pt_note->
        note_qual[ml_idx].blobs_qual[ml_idx2].f_event_id,1)
     ENDFOR
   ENDFOR
   FREE RECORD m_pref
   RECORD m_pref(
     1 icnt = i4
     1 item[*]
       2 f_item_id = f8
       2 s_item_type = vc
       2 s_item_desc = vc
       2 s_item_nbr = vc
       2 s_open = vc
       2 s_hold = vc
       2 s_fill = vc
       2 s_request = vc
       2 s_sch = vc
       2 s_item_loc = vc
       2 s_bin = vc
   )
   FREE RECORD m_fin_pref
   RECORD m_fin_pref(
     1 icnt = i4
     1 item[*]
       2 f_item_id = f8
       2 s_item_type = vc
       2 s_item_desc = vc
       2 s_item_nbr = vc
       2 s_open = vc
       2 s_hold = vc
       2 s_fill = vc
       2 s_request = vc
       2 s_sch = vc
       2 s_item_loc = vc
       2 s_bin = vc
     1 l_com_cnt = i4
     1 com_qual[*]
       2 s_comment_text = vc
   )
   SELECT INTO "nl:"
    FROM surgical_case sc,
     case_cart_pick_list ccpl,
     case_cart cc,
     mm_omf_item_master moim,
     dummyt d1,
     loc_resource_r lrr,
     locator_rollup lr
    PLAN (sc
     WHERE (sc.surg_case_id=pat->qual[x].f_surg_case_id))
     JOIN (ccpl
     WHERE ccpl.surg_case_id=sc.surg_case_id
      AND ccpl.active_ind=1
      AND ((ccpl.request_qty > 0) OR (((ccpl.hold_qty > 0) OR (((ccpl.open_qty > 0) OR (ccpl.fill_qty
      > 0)) )) )) )
     JOIN (cc
     WHERE cc.case_cart_id=ccpl.case_cart_id)
     JOIN (moim
     WHERE (moim.item_master_id= Outerjoin(ccpl.item_id)) )
     JOIN (d1)
     JOIN (lrr
     WHERE lrr.service_resource_cd=sc.sched_surg_area_cd
      AND lrr.loc_resource_type_cd IN (747))
     JOIN (lr
     WHERE lr.location_cd=lrr.location_cd
      AND lr.item_id=ccpl.item_id)
    ORDER BY moim.type_cd, ccpl.item_id, lrr.sequence DESC
    HEAD REPORT
     m_pref->icnt = 0
    HEAD ccpl.item_id
     m_pref->icnt += 1, stat = alterlist(m_pref->item,m_pref->icnt), m_pref->item[m_pref->icnt].
     f_item_id = ccpl.item_id,
     m_pref->item[m_pref->icnt].s_item_type = trim(uar_get_code_display(moim.type_cd),3), m_pref->
     item[m_pref->icnt].s_item_desc = moim.description, m_pref->item[m_pref->icnt].s_item_nbr = moim
     .stock_nbr,
     m_pref->item[m_pref->icnt].s_bin = "", m_pref->item[m_pref->icnt].s_item_loc = "", m_pref->item[
     m_pref->icnt].s_open = trim(cnvtstring(ccpl.open_qty,20),3),
     m_pref->item[m_pref->icnt].s_hold = trim(cnvtstring(ccpl.hold_qty,20),3), m_pref->item[m_pref->
     icnt].s_fill = trim(cnvtstring(ccpl.fill_qty,20),3), m_pref->item[m_pref->icnt].s_request = trim
     (cnvtstring(ccpl.request_qty,20),3),
     m_pref->item[m_pref->icnt].s_sch = ""
     IF (moim.scheduable_ind != 0)
      m_pref->item[m_pref->icnt].s_sch = "Yes"
     ELSE
      m_pref->item[m_pref->icnt].s_sch = "No"
     ENDIF
    DETAIL
     IF (lr.location_cd IS NOT null)
      m_pref->item[m_pref->icnt].s_item_loc = trim(uar_get_code_display(lr.location_cd),3), m_pref->
      item[m_pref->icnt].s_bin = trim(uar_get_code_display(lr.locator_cd),3)
     ENDIF
    FOOT  ccpl.item_id
     IF (size(m_pref->item[m_pref->icnt].s_item_loc)=0)
      m_pref->item[m_pref->icnt].s_item_loc = "<Not Defined>"
     ENDIF
     IF (size(m_pref->item[m_pref->icnt].s_bin)=0)
      m_pref->item[m_pref->icnt].s_bin = "<Not Defined>"
     ENDIF
    WITH nocounter, outerjoin(d1)
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = m_pref->icnt)
    PLAN (d)
    ORDER BY m_pref->item[d.seq].s_item_type, m_pref->item[d.seq].s_item_loc, m_pref->item[d.seq].
     s_bin,
     m_pref->item[d.seq].s_item_desc, m_pref->item[d.seq].s_item_nbr
    HEAD REPORT
     m_fin_pref->icnt = 0
    DETAIL
     m_fin_pref->icnt += 1, stat = alterlist(m_fin_pref->item,m_fin_pref->icnt), m_fin_pref->item[
     m_fin_pref->icnt].f_item_id = m_pref->item[d.seq].f_item_id,
     m_fin_pref->item[m_fin_pref->icnt].s_bin = m_pref->item[d.seq].s_bin, m_fin_pref->item[
     m_fin_pref->icnt].s_hold = m_pref->item[d.seq].s_hold, m_fin_pref->item[m_fin_pref->icnt].
     s_item_desc = m_pref->item[d.seq].s_item_desc,
     m_fin_pref->item[m_fin_pref->icnt].s_item_loc = m_pref->item[d.seq].s_item_loc, m_fin_pref->
     item[m_fin_pref->icnt].s_item_nbr = m_pref->item[d.seq].s_item_nbr, m_fin_pref->item[m_fin_pref
     ->icnt].s_item_type = m_pref->item[d.seq].s_item_type,
     m_fin_pref->item[m_fin_pref->icnt].s_open = m_pref->item[d.seq].s_open, m_fin_pref->item[
     m_fin_pref->icnt].s_fill = m_pref->item[d.seq].s_fill, m_fin_pref->item[m_fin_pref->icnt].
     s_request = m_pref->item[d.seq].s_request,
     m_fin_pref->item[m_fin_pref->icnt].s_sch = m_pref->item[d.seq].s_sch
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM surg_case_procedure scp,
     sn_surg_case_proc_doc ssc,
     sn_comment_text sct,
     long_text_reference ltr
    PLAN (scp
     WHERE (scp.surg_case_id=pat->qual[x].f_surg_case_id))
     JOIN (ssc
     WHERE ssc.surg_case_proc_id=scp.surg_case_proc_id
      AND ssc.active_ind=1)
     JOIN (sct
     WHERE sct.root_name="PREFERENCE_CARD"
      AND sct.root_id=ssc.pref_card_id
      AND sct.active_ind=1)
     JOIN (ltr
     WHERE ltr.long_text_id=sct.long_text_id)
    ORDER BY ltr.long_text_id
    HEAD ltr.long_text_id
     m_fin_pref->l_com_cnt += 1, stat = alterlist(m_fin_pref->com_qual,m_fin_pref->l_com_cnt),
     m_fin_pref->com_qual[m_fin_pref->l_com_cnt].s_comment_text = trim(ltr.long_text,3)
    WITH nocounter
   ;end select
   CALL echo(build("File Name:,",x,":",pat->qual[x].filename))
   IF ((pat->qual[x].filename > " "))
    SELECT INTO value(pat->qual[x].filename)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      l = 0, event_len = 0, date_len = 0,
      pat_cnt = 0, pat_cnt = size(pat->qual,5), line = fillstring(120,"="),
      line2 = fillstring(120,"*"), xcol = 0, ycol = 0,
      temp1 = fillstring(500,""), temp2 = fillstring(500,""), sord_cnt = 0,
      pord_cnt = 0, cord_cnt = 0, breakflag = 1,
      xcolvar = 0, wrapcol = 0,
      MACRO (rowplusone)
       ycol += 10, row + 1
       IF (ycol > 710)
        BREAK
       ENDIF
      ENDMACRO
      ,
      MACRO (rowplusone2)
       ycol += 10, row + 1
      ENDMACRO
      ,
      MACRO (line_wrap)
       limit = 0, maxlen = wrapcol, cr = char(13),
       lf = char(10)
       WHILE (tempstring > " "
        AND limit < 1000)
         ii = 0, limit += 1, pos = 0
         WHILE (pos=0)
          ii += 1,
          IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr, lf))
           pos = (maxlen - ii)
          ELSEIF (ii=maxlen)
           pos = maxlen
          ENDIF
         ENDWHILE
         printstring = substring(1,pos,tempstring),
         CALL print(calcpos(xcol,ycol)), printstring
         IF (limit=1)
          maxlen -= 5
         ENDIF
         IF (breakflag=1)
          rowplusone
         ELSE
          rowplusone2
         ENDIF
         tempstring = substring((pos+ 1),999,tempstring)
       ENDWHILE
      ENDMACRO
      ,
      MACRO (line_wrap2)
       b_linefeed = concat(char(10)), b_cc = 0, b_s = 1,
       b_len = 0, b_e = 0, b_tmp_comment = fillstring(90,""),
       a_tmp_string = fillstring(90,""), tmp_var = 0, b_cc = 1,
       b_s = 1
       WHILE (b_cc)
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         b_tmp_comment = substring(b_s,90,tempstring), b_e = findstring(b_linefeed,b_tmp_comment,1)
         IF (b_e)
          a_tmp_string = substring(1,b_e,b_tmp_comment),
          CALL print(calcpos(xcol,ycol)), a_tmp_string,
          row + 1, ycol += 8, b_s += b_e
         ELSE
          IF (b_tmp_comment > " ")
           CALL print(calcpos(xcol,ycol)), b_tmp_comment, row + 1,
           ycol += 8, b_s += 90
          ELSE
           b_cc = 0
          ENDIF
         ENDIF
       ENDWHILE
      ENDMACRO
     HEAD PAGE
      "{cpi/10}{f/12}", row + 1, "{pos/240/30}{b}Baystate Health System",
      row + 1, "{pos/170/45}{b}Surgical Downtime Clinical Summary Report (Ops)", row + 1,
      "{cpi/14}", row + 1, xcol = 30,
      ycol = 60,
      CALL print(calcpos(xcol,ycol)), "Run Date & Time:",
      curdate, " ", curtime,
      row + 1, xcol = 5, ycol += 10,
      CALL print(calcpos(xcol,ycol)), line, row + 1,
      xcol = 30, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "Location: ", pat->qual[x].s_unit, row + 1,
      xcol = 200,
      CALL print(calcpos(xcol,ycol)), "Name: ",
      pat->qual[x].name, row + 1, xcol = 350,
      CALL print(calcpos(xcol,ycol)), "Acc Nbr: ", pat->qual[x].fin,
      row + 1, xcol = 500, temp1 = concat("Page :",cnvtstring(curpage)),
      CALL print(calcpos(xcol,ycol)), temp1, row + 1,
      xcol = 30, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "Att. MD: ", pat->qual[x].att_doc, row + 1,
      xcol = 200,
      CALL print(calcpos(xcol,ycol)), "PCP MD: ",
      pat->qual[x].pcp_doc, row + 1, xcol = 350,
      CALL print(calcpos(xcol,ycol)), "MR Nbr: ", pat->qual[x].mrn,
      row + 1, xcol = 500, dob = format(pat->qual[x].dob,"mm/dd/yy ;;q"),
      CALL print(calcpos(xcol,ycol)), "D.O.B: ", dob,
      row + 1, ycol += 10, xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Teaching Cov.: ", pat->qual[x].teaching_doc,
      row + 1, xcol = 200,
      CALL print(calcpos(xcol,ycol)),
      "Language: ", pat->qual[x].language, row + 1,
      xcol = 350,
      CALL print(calcpos(xcol,ycol)), "Religion: ",
      pat->qual[x].religion, row + 1, ycol += 10,
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), "Surg Sched DT/TM: ",
      pat->qual[x].s_sched_time, row + 1, xcol = 200,
      CALL print(calcpos(xcol,ycol)), "Surg Case NBR: ", pat->qual[x].s_surg_case_nbr,
      row + 1, xcol = 350,
      CALL print(calcpos(xcol,ycol)),
      "Patient Type: ", pat->qual[x].s_pat_type, row + 1,
      xcol = 500,
      CALL print(calcpos(xcol,ycol)), "OR Room: ",
      pat->qual[x].s_room, row + 1, xcol = 30,
      ycol += 10, visit = substring(1,100,pat->qual[x].visit_reason),
      CALL print(calcpos(xcol,ycol)),
      "Reason for Visit: ", visit, row + 1,
      ad_date = pat->qual[x].admit_dt, xcol = 350,
      CALL print(calcpos(xcol,ycol)),
      "Admit Date: ", ad_date, row + 1,
      ycol += 10, xcol = 30, diag = substring(1,100,pat->qual[x].diagnosis),
      CALL print(calcpos(xcol,ycol)), "Diagnosis: ", diag,
      row + 1, ycol += 10, breakflag = 0,
      xcol = 30
      IF (curpage=1)
       tempstring = concat("Allergy: ",pat->qual[x].allergy), b_end = ";", b_cc = 0,
       b_s = 1, b_e = 0, b_tmp_comment = fillstring(90,""),
       a_tmp_string = fillstring(90,""), tmp_var = 0, b_cc = 1,
       b_s = 1
       WHILE (b_cc)
         b_tmp_comment = substring(b_s,90,tempstring), b_e = findstring(b_end,b_tmp_comment,b_s,1)
         IF (b_e)
          a_tmp_string = substring(1,b_e,b_tmp_comment),
          CALL print(calcpos(xcol,ycol)), a_tmp_string,
          row + 1, ycol += 8, b_s += b_e
         ELSE
          IF (b_tmp_comment > " ")
           CALL print(calcpos(xcol,ycol)), b_tmp_comment, row + 1,
           ycol += 8, b_s += 90
          ELSE
           b_cc = 0
          ENDIF
         ENDIF
       ENDWHILE
       xcol = 5, ycol += 8
      ENDIF
      CALL print(calcpos(xcol,ycol)), line, row + 1,
      xcol = 30, ycol += 8
     DETAIL
      IF (trim(pat->qual[x].code_status_name) > "")
       temp1 = concat("** Code Status: ",trim(pat->qual[x].code_status_name)," **")
      ELSE
       temp1 = "Code Status: N/A"
      ENDIF
      xcol = 100,
      CALL print(calcpos(xcol,ycol)), "{b}",
      temp1, row + 1, ycol += 8
      IF (size(pat->qual[x].code_status_detail,5) > 0)
       FOR (code = 1 TO size(pat->qual[x].code_status_detail,5))
         xcol = 150, tempstring = trim(pat->qual[x].code_status_detail[code].display), line_wrap2
       ENDFOR
       xcol = 5
      ENDIF
      xcol = 5,
      CALL print(calcpos(xcol,ycol)), line,
      row + 1, ycol += 10, xcol = 100,
      breakflag = 1, breakflag = 1, xcol = 30,
      l += 1, ycol += 5, title = build(l,"-","{b}Surgical Case Data:"),
      CALL print(calcpos(xcol,ycol)), "{b}", title,
      row + 1, ycol += 10
      FOR (ml_idx = 1 TO pat->qual[x].l_pcnt)
        ycol += 10
        IF (ycol > 710)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 50, tempstring = concat("{b} Procedure: {endb} ",pat->qual[x].proc[ml_idx].s_ancillary,
         "--",pat->qual[x].proc[ml_idx].s_proc_name), wrapcol = 122,
        line_wrap2
        IF (ycol > 710)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        IF (size(pat->qual[x].proc[ml_idx].s_modifier) > 0)
         xcol = 50, tempstring = concat("{b} Modifier: {endb} ",pat->qual[x].proc[ml_idx].s_modifier),
         wrapcol = 122,
         line_wrap2
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
        ENDIF
        IF (size(pat->qual[x].proc[ml_idx].s_prim_surg) > 0)
         xcol = 50, tempstring = concat("{b} Primary Surgeon: {endb} ",pat->qual[x].proc[ml_idx].
          s_prim_surg), wrapcol = 122,
         line_wrap2
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
        ENDIF
        IF (size(pat->qual[x].proc[ml_idx].s_assist_surg) > 0)
         xcol = 50, tempstring = concat("{b} Assistant Surgeon: {endb} ",pat->qual[x].proc[ml_idx].
          s_assist_surg), wrapcol = 122,
         line_wrap2
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
        ENDIF
      ENDFOR
      ycol += 10
      IF (size(trim(pat->qual[x].s_public_comment,3)) > 0)
       title = "{b}Comment:",
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1
       IF (ycol > 710)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       xcol = 50, ycol += 10, tempstring = pat->qual[x].s_public_comment,
       wrapcol = 122, line_wrap2
      ENDIF
      ycol += 10, xcol = 30
      FOR (y = 1 TO size(pat->qual[x].sec,5))
        IF ((pat->qual[x].sec[y].sec_disp IN ("Patient Data", "Additional Patient Data")))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         l += 1, temp1 = build(cnvtstring(l),"-",pat->qual[x].sec[y].sec_disp,":"),
         CALL print(calcpos(xcol,ycol)),
         "{b}", temp1, row + 1,
         ycol += 8
         FOR (z = 1 TO size(pat->qual[x].sec[y].grpr,5))
           IF (ycol > 740)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           grpr_date = format(pat->qual[x].sec[y].grpr[z].grpr_date,"mm/dd/yy hh:mm;;q"), xcol = 40,
           CALL print(calcpos(xcol,ycol)),
           grpr_date, row + 1, date_len = textlen(grpr_date)
           FOR (zz = 1 TO size(pat->qual[x].sec[y].grpr[z].event,5))
             IF (ycol > 740)
              xcol = 100, ycol += 10,
              CALL print(calcpos(xcol,ycol)),
              "**  Continue on Next Page **", row + 1, BREAK
             ENDIF
             temp1 = fillstring(500,""), xcol = 115, temp1 = pat->qual[x].sec[y].grpr[z].event[zz].
             event_disp
             IF ((pat->qual[x].sec[y].grpr[z].event[zz].max_result_qty > 0))
              IF ((pat->qual[x].sec[y].grpr[z].event[zz].event_cnt > pat->qual[x].sec[y].grpr[z].
              event[zz].max_result_qty))
               pat->qual[x].sec[y].grpr[z].event[zz].event_cnt = pat->qual[x].sec[y].grpr[z].event[zz
               ].max_result_qty
              ENDIF
              FOR (yy = 1 TO pat->qual[x].sec[y].grpr[z].event[zz].event_cnt)
                IF (ycol > 740)
                 xcol = 100, ycol += 10,
                 CALL print(calcpos(xcol,ycol)),
                 "**  Continue on Next Page **", row + 1, BREAK
                ENDIF
                IF (yy > 1
                 AND trim(temp1)=trim(pat->qual[x].sec[y].grpr[z].event[(zz - 1)].event_disp))
                 ycol2 = ycol, date2 = format(pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
                  end_dt_tm,"mm/dd/yy hh:mm;;q"), date = substring(1,8,date2),
                 time = substring(10,5,date2),
                 CALL print(calcpos(xcol,ycol)), date,
                 row + 1, ycol += 8,
                 CALL print(calcpos(xcol,ycol)),
                 time, row + 1, ycol += 8,
                 temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y].grpr[z].event[zz].result[yy]
                 .event_result,
                 CALL print(calcpos(xcol,ycol)),
                 temp2, row + 1, xcol += 50,
                 ycol = ycol2
                ELSE
                 temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y].grpr[z].event[zz].result[yy]
                 .event_result, temp1 = concat(build(temp1),": ",build(temp2)),
                 CALL print(calcpos(xcol,ycol)), temp1, row + 1,
                 temp1 = fillstring(500,"")
                ENDIF
                ycol += 8
              ENDFOR
             ENDIF
           ENDFOR
           xcol = 30
         ENDFOR
         xcol = 30, ycol += 5
        ENDIF
      ENDFOR
      xcol = 30, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "{b}Blood Pressure/Venipuncture : {endb}", row + 1, temp2 = fillstring(500,""),
      temp2 = pat->qual[x].ms_bloodpressurevenipuncture, tempstring = concat(build(temp2)), ycol +=
      10,
      wrapcol = 122, line_wrap2, temp1 = fillstring(500,"")
      IF (ycol > 710)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      xcol = 30, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "{b}Wearing BP/Venipuncture Restriction Band : {endb}", row + 1, temp2 = fillstring(500,""),
      temp2 = pat->qual[x].ms_wearing_bpv_band, tempstring = concat(build(temp2)), ycol += 10,
      wrapcol = 122, line_wrap2, temp1 = fillstring(500,"")
      IF (ycol > 710)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      xcol = 30, ycol += 5
      IF ((((sw->language > " ")) OR ((((sw->consultstatus > " ")) OR ((((sw->planoutcome > " ")) OR
      ((((sw->commnets > " ")) OR ((((sw->reportfiled > " ")) OR ((sw->reasonforref > " "))) )) ))
      )) )) )
       CALL print(calcpos(xcol,ycol)), "{b}Social Work Section: {endb}", row + 1,
       xcol = 30, ycol += 10
      ENDIF
      IF ((sw->language > ""))
       CALL print(calcpos(xcol,ycol)), "Language: ", sw->language,
       row + 1, xcol = 30, ycol += 10
      ENDIF
      IF ((sw->consultstatus > ""))
       CALL print(calcpos(xcol,ycol)), "Consult Status: ", sw->consultstatus,
       row + 1, xcol = 30, ycol += 10
      ENDIF
      IF ((sw->reasonforref > " "))
       CALL print(calcpos(xcol,ycol)), "Reason for Referral/Consult: ", sw->reasonforref,
       row + 1, xcol = 30, ycol += 10
      ENDIF
      IF ((sw->planoutcome > ""))
       CALL print(calcpos(xcol,ycol)), "Plan/Outcome: ", sw->planoutcome,
       row + 1, xcol = 30, ycol += 10
      ENDIF
      IF ((sw->commnets > ""))
       tempstring = concat("Plan Comments: ",sw->commnets), line_wrap2, ycol += 10
      ENDIF
      IF ((sw->reportfiled > ""))
       CALL print(calcpos(xcol,ycol)), "Mandated Report Filed: ", sw->reportfiled,
       row + 1, xcol = 30, ycol += 10
      ENDIF
      IF (ycol > 710)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      xcol = 30, ycol += 5, breakflag = 1,
      xcolvar = 30, wrapcol = 122, l += 1,
      ycol += 5, title = build(l,"-","{b}Invasive Lines/Tubes/Drains:"),
      CALL print(calcpos(xcol,ycol)),
      "{b}", title, row + 1,
      ycol += 10
      FOR (m1 = 1 TO size(pat->qual[x].invasive,5))
        IF (ycol > 710)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        tempstring = concat("{b}",pat->qual[x].invasive[m1].order_mnemonic,"{endb} ",pat->qual[x].
         invasive[m1].clinical_display,pat->qual[x].invasive[m1].verify_str), line_wrap2
      ENDFOR
      IF ((m_home_meds->l_cnt > 0))
       l += 1, ycol += 5, title = build(l,"-","{b}Medication History:"),
       CALL print(calcpos(xcol,ycol)), "{b}", title,
       row + 1, ycol += 10
       FOR (ml_idx = 1 TO m_home_meds->l_cnt)
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 50, tempstring = concat("{b}",m_home_meds->qual[ml_idx].s_order_name,"{endb}",":",
          m_home_meds->qual[ml_idx].s_status,
          ":",m_home_meds->qual[ml_idx].s_order_disp_line), wrapcol = 122,
         line_wrap2
       ENDFOR
      ENDIF
      IF (ycol > 710)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      IF (size(scheduled_orders->qual,5) > 0)
       xcol = 30, ycol += 5, l += 1,
       title = build(l,"-","{b}Scheduled Meds :"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 8
       FOR (z1 = 1 TO size(scheduled_orders->qual,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 30, line1 = fillstring(100,""), comment_string = fillstring(122,""),
         line1 = concat("{b}Medication: ",scheduled_orders->qual[z1].order_name)
         FOR (z2 = 1 TO size(scheduled_orders_disp->scheduled_orders,5))
           IF ((scheduled_orders->qual[z1].order_id=scheduled_orders_disp->scheduled_orders[z2].
           template_order_id))
            scheduled_orders->qual[z1].print_ind = 1
            IF (ycol > 740)
             xcol = 100, ycol += 10,
             CALL print(calcpos(xcol,ycol)),
             "**  Continue on Next Page **", row + 1, BREAK
            ENDIF
            CALL print(calcpos(50,ycol)), line1, row + 1,
            ycol += 8, tempstring = concat("Order Detail :",scheduled_orders_disp->scheduled_orders[
             z2].core_actions[1].clinical_display_line), xcol = 50,
            wrapcol = 122, line_wrap2
            IF (size(scheduled_orders->qual[z1].comment,5) > 0)
             FOR (comment = 1 TO size(scheduled_orders->qual[z1].comment,5))
               tempstring = build(scheduled_orders->qual[z1].comment[comment].comment), xcol = 50,
               CALL print(calcpos(xcol,ycol)),
               tempstring, row + 1, ycol += 8
             ENDFOR
            ENDIF
            IF (ycol > 740)
             xcol = 100, ycol += 10,
             CALL print(calcpos(xcol,ycol)),
             "**  Continue on Next Page **", row + 1, BREAK
            ENDIF
            CALL print(calcpos(50,ycol)), "{b}Last Dose Given", row + 1,
            xcol += 250,
            CALL print(calcpos(300,ycol)), "{b}Next Dose Due ",
            row + 1, ycol += 8, xcol = 50
            IF (ycol > 740)
             xcol = 100, ycol += 10,
             CALL print(calcpos(xcol,ycol)),
             "**  Continue on Next Page **", row + 1, BREAK
            ENDIF
            med_date = scheduled_orders_disp->scheduled_orders[z2].admins[1].event_end_dt_tm,
            med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
            dose = format(scheduled_orders_disp->scheduled_orders[z2].admins[1].dosage_value,
             "#######.##;l"), event1 = build(med_date_disp,"/",dose,scheduled_orders_disp->
             scheduled_orders[z2].admins[1].dosage_unit), event2 = fillstring(40,""),
            event2 = format(scheduled_orders->qual[z1].child_ord[1].start_dt,"mm/dd/yy hh:mm;;q"),
            CALL print(calcpos(50,ycol)), event1,
            row + 1,
            CALL print(calcpos(300,ycol)), event2,
            row + 1, ycol += 8
           ENDIF
         ENDFOR
         IF ((scheduled_orders->qual[z1].print_ind=1))
          ycol += 8
         ENDIF
       ENDFOR
      ENDIF
      IF (ycol > 740)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      FOR (sch = 1 TO size(scheduled_orders->qual,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 50
        IF ((scheduled_orders->qual[sch].print_ind=0))
         tempstring = concat("{b}",scheduled_orders->qual[sch].order_name,"{endb}",":",
          scheduled_orders->qual[sch].order_detail), wrapcol = 122, line_wrap2
         IF (size(scheduled_orders->qual[sch].comment,5) > 0)
          FOR (comment = 1 TO size(scheduled_orders->qual[sch].comment,5))
            tempstring = build(scheduled_orders->qual[sch].comment[comment].comment), xcol = 50,
            CALL print(calcpos(xcol,ycol)),
            tempstring, row + 1, ycol += 8
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
      IF (ycol > 710)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      IF (size(prn_orders_disp->prn_orders,5) > 0)
       xcol = 30, ycol += 5, l += 1,
       title = build(l,"-","{b}PRN Meds :"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 8
       FOR (z1 = 1 TO size(prn_orders_disp->prn_orders,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 30, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",prn_orders_disp->
          prn_orders[z1].ordered_as_mnemonic),
         comment_string = build(prn_orders_disp->prn_orders[z1].comment)
         IF (size(prn_orders_disp->prn_orders[z1].core_actions,5) > 0)
          IF (ycol > 740)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
          xcol = 50,
          CALL print(calcpos(50,ycol)), line1,
          row + 1, ycol += 8, tempstring = concat("Order Detail :",prn_orders_disp->prn_orders[z1].
           core_actions[1].clinical_display_line),
          wrapcol = 122, line_wrap2
          IF (comment_string > "")
           tempstring = concat("Comment: ",comment_string), line_wrap2
          ENDIF
         ENDIF
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), "{b}Last Dose Given",
         row + 1, ycol += 8, xcol = 50
         FOR (z3 = 1 TO 1)
           IF (ycol > 740)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           med_date = prn_orders_disp->prn_orders[z1].admins[z3].event_end_dt_tm, med_date_disp =
           format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
           dose = format(prn_orders_disp->prn_orders[z1].admins[z3].dosage_value,"#######.##;l"),
           event = build(med_date_disp,"->",dose,prn_orders_disp->prn_orders[z1].admins[z3].
            dosage_unit,",",
            prn_orders_disp->prn_orders[z1].admins[z3].route),
           CALL print(calcpos(50,ycol)),
           event, row + 1, ycol += 8
         ENDFOR
         ycol += 8
       ENDFOR
      ENDIF
      FOR (prn = 1 TO size(prn_orders->qual,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 50
        IF ((prn_orders->qual[prn].print_ind=0))
         tempstring = concat("{b}",prn_orders->qual[prn].order_name,"{endb}",":",prn_orders->qual[prn
          ].order_detail), wrapcol = 122, line_wrap2,
         comment_string = build(prn_orders->qual[prn].comment)
         IF (comment_string > "")
          tempstring = concat("Comment: ",comment_string), line_wrap2
         ENDIF
        ENDIF
      ENDFOR
      IF (ycol > 710)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      IF (size(continuous_orders_disp->continuous_orders,5) > 0)
       xcol = 30, ycol += 5, l += 1,
       title = build(l,"-","{b}IV Infusions :"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 8
       FOR (z1 = 1 TO size(continuous_orders_disp->continuous_orders,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 30, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",
          continuous_orders_disp->continuous_orders[z1].ordered_as_mnemonic),
         comment_string = build(continuous_orders_disp->continuous_orders[z1].comment)
         IF (size(continuous_orders_disp->continuous_orders[z1].core_actions,5) > 0)
          IF (ycol > 740)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
          CALL print(calcpos(50,ycol)), line1, row + 1,
          ycol += 8, xcol = 50, tempstring = concat("Order Detail :",continuous_orders_disp->
           continuous_orders[z1].core_actions[1].clinical_display_line),
          wrapcol = 122, line_wrap2
          IF (comment_string > "")
           tempstring = concat("Comment: ",comment_string), line_wrap2
          ENDIF
         ENDIF
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 50,
         CALL print(calcpos(50,ycol)), "{b}Last Dose Given",
         row + 1, ycol += 8, xcol = 50
         FOR (z3 = 1 TO 1)
          IF (ycol > 740)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
          ,
          IF (trim(continuous_orders_disp->continuous_orders[z1].admins[z3].event_title_text)=
          "IVPARENT")
           med_date = continuous_orders_disp->continuous_orders[z1].admins[z3].admin_start_dt_tm,
           med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
           dose = format(continuous_orders_disp->continuous_orders[z1].admins[z3].initial_volume,
            "#######.##;l"), dose_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3
            ].dosage_unit), rate = format(continuous_orders_disp->continuous_orders[z1].admins[z3].
            infusion_rate,"#######.##;l"),
           rate_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3].infusion_unit),
           event = build(med_date_disp,"->",dose,dose_unit,";",
            rate,",",rate_unit),
           CALL print(calcpos(50,ycol)),
           event, row + 1, ycol += 8
          ENDIF
         ENDFOR
         ycol += 8
       ENDFOR
      ENDIF
      FOR (con = 1 TO size(continuous_orders->qual,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 50
        IF ((continuous_orders->qual[con].print_ind=0))
         tempstring = concat("{b}",continuous_orders->qual[con].order_name,"{endb}",":",
          continuous_orders->qual[con].order_detail), wrapcol = 122, line_wrap2,
         comment_string = build(continuous_orders->qual[con].comment)
         IF (comment_string > "")
          tempstring = concat("Comment: ",comment_string), line_wrap2
         ENDIF
        ENDIF
      ENDFOR
      IF ((m_fut_ord->l_cnt > 0))
       l += 1, ycol += 10, xcol = 30,
       title = build(l,"-","{b}Future Orders:"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 10
       FOR (ml_idx = 1 TO m_fut_ord->l_cnt)
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 50, tempstring = concat("{b}",m_fut_ord->qual[ml_idx].s_ord_mnemonic,"{endb}",":",
          m_fut_ord->qual[ml_idx].s_clin_display), wrapcol = 122,
         line_wrap2
       ENDFOR
      ENDIF
      IF ((m_fut_ord->l_cnt > 0))
       l += 1, ycol += 10, xcol = 30,
       title = build(l,"-","{b}Incomplete Orders:"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 10
       FOR (ml_idx = 1 TO m_inc_ord->l_cnt)
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 50, tempstring = concat("{b}",m_inc_ord->qual[ml_idx].s_ord_mnemonic,"{endb}",":",
          m_inc_ord->qual[ml_idx].s_clin_display), wrapcol = 122,
         line_wrap2
       ENDFOR
      ENDIF
      xcol = 30, ycol += 5
      IF (size(pat->qual[x].lab_rad_ekg,5) > 0)
       IF (ycol > 740)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       l += 1, title = build(l,"-","{b}Lab / Rad / EKG Orders:"),
       CALL print(calcpos(xcol,ycol)),
       "{b}", title, row + 1,
       ycol += 10
       FOR (d1 = 1 TO size(pat->qual[x].lab_rad_ekg,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         tempstring = concat("{b}",pat->qual[x].lab_rad_ekg[d1].order_mnemonic,"{endb} ",pat->qual[x]
          .lab_rad_ekg[d1].clinical_display), line_wrap2
       ENDFOR
      ENDIF
      ycol += 5, xcol = 30
      FOR (y2 = 1 TO size(pat->qual[x].sec,5))
        IF ( NOT ((pat->qual[x].sec[y2].sec_disp IN ("Patient Data", "Additional Patient Data",
        "Post Acute Care Initial Evaluation", "Post Acute Care Discharge Plan", "Vital Signs",
        "Functonal Screening", "HEENT", "OB/GYN"))))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         IF (size(trim(pat->qual[x].sec[y2].sec_disp,3)) > 0)
          l += 1, temp1 = build(cnvtstring(l),"-",pat->qual[x].sec[y2].sec_disp,":"),
          CALL print(calcpos(xcol,ycol)),
          "{b}", temp1, row + 1,
          ycol += 8
          FOR (z = 1 TO size(pat->qual[x].sec[y2].grpr,5))
            IF (ycol > 740)
             xcol = 100, ycol += 10,
             CALL print(calcpos(xcol,ycol)),
             "**  Continue on Next Page **", row + 1, BREAK
            ENDIF
            grpr_date = format(pat->qual[x].sec[y2].grpr[z].grpr_date,"mm/dd/yy hh:mm;;q"), xcol = 40,
            CALL print(calcpos(xcol,ycol)),
            grpr_date, row + 1, date_len = textlen(grpr_date)
            FOR (zz = 1 TO size(pat->qual[x].sec[y2].grpr[z].event,5))
              IF (ycol > 740)
               xcol = 100, ycol += 10,
               CALL print(calcpos(xcol,ycol)),
               "**  Continue on Next Page **", row + 1, BREAK
              ENDIF
              temp1 = fillstring(500,""), xcol = 115, temp1 = pat->qual[x].sec[y2].grpr[z].event[zz].
              event_disp
              IF ((pat->qual[x].sec[y2].grpr[z].event[zz].max_result_qty > 0))
               IF ((pat->qual[x].sec[y2].grpr[z].event[zz].event_cnt > pat->qual[x].sec[y2].grpr[z].
               event[zz].max_result_qty))
                pat->qual[x].sec[y2].grpr[z].event[zz].event_cnt = pat->qual[x].sec[y2].grpr[z].
                event[zz].max_result_qty
               ENDIF
               FOR (yy = 1 TO pat->qual[x].sec[y2].grpr[z].event[zz].event_cnt)
                 IF (ycol > 740)
                  xcol = 100, ycol += 10,
                  CALL print(calcpos(xcol,ycol)),
                  "**  Continue on Next Page **", row + 1, BREAK
                 ENDIF
                 IF (yy > 1
                  AND trim(temp1)=trim(pat->qual[x].sec[y2].grpr[z].event[(zz - 1)].event_disp))
                  ycol2 = ycol, date2 = format(pat->qual[x].sec[y2].grpr[z].event[zz].result[yy].
                   end_dt_tm,"mm/dd/yy hh:mm;;q"), date = substring(1,8,date2),
                  time = substring(10,5,date2),
                  CALL print(calcpos(xcol,ycol)), date,
                  row + 1, ycol += 8,
                  CALL print(calcpos(xcol,ycol)),
                  time, row + 1, ycol += 8,
                  temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y2].grpr[z].event[zz].result[
                  yy].event_result,
                  CALL print(calcpos(xcol,ycol)),
                  temp2, row + 1, xcol += 50,
                  ycol = ycol2
                 ELSE
                  temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y2].grpr[z].event[zz].result[
                  yy].event_result, temp1 = concat(build(temp1),": ",build(temp2)),
                  CALL print(calcpos(xcol,ycol)), temp1, row + 1,
                  temp1 = fillstring(500,"")
                 ENDIF
                 ycol += 8
               ENDFOR
              ENDIF
            ENDFOR
            xcol = 30
          ENDFOR
          xcol = 30, ycol += 5
         ENDIF
        ENDIF
      ENDFOR
      IF ((pt_note->l_note_cnt > 0))
       xcol = 100, ycol = 720,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK,
       xcol = 30, l += 1, ycol += 5,
       title = build(l,"-","{b}Notes:"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 10
       FOR (ml_idx = 1 TO pt_note->l_note_cnt)
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         xcol = 130, title = build(" {b} ",pt_note->note_qual[ml_idx].s_note_type," {endb} (",pt_note
          ->note_qual[ml_idx].s_note_date,") ",
          ":"),
         CALL print(calcpos(xcol,ycol)),
         title, row + 1
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         FOR (ml_idx2 = 1 TO pt_note->note_qual[ml_idx].l_blob_cnt)
           IF (ycol > 710)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           ycol += 10, xcol = 135, title = build("{b}",pt_note->note_qual[ml_idx].blobs_qual[ml_idx2]
            .s_event_title_text),
           CALL print(calcpos(xcol,ycol)), "{b}", title,
           row + 1
           IF (ycol > 710)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           ycol += 10, xcol = 30, tempstring = pt_note->note_qual[ml_idx].blobs_qual[ml_idx2].
           s_blob_nortf,
           wrapcol = 122, line_wrap2
         ENDFOR
       ENDFOR
      ENDIF
      IF ((m_fin_pref->icnt > 0))
       xcol = 100, ycol = 720,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK,
       xcol = 30, l += 1, ycol += 5,
       title = build(l,"-","{b}Picklist Items:"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 15
       FOR (ml_idx = 1 TO m_fin_pref->icnt)
         IF (ml_idx=1)
          xcol = 300, title = concat(" {b} ",m_fin_pref->item[ml_idx].s_item_type),
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          ycol += 15
          IF (ycol > 710)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
         ELSE
          IF ((m_fin_pref->item[ml_idx].s_item_type != m_fin_pref->item[(ml_idx - 1)].s_item_type))
           xcol = 300, title = concat(" {b} ",m_fin_pref->item[ml_idx].s_item_type),
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           ycol += 15
           IF (ycol > 710)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
          ENDIF
         ENDIF
         IF (ml_idx=1)
          xcol = 30, ycol += 5, title = concat(" {b} Pick Location: {endb} ",m_fin_pref->item[ml_idx]
           .s_item_loc),
          CALL print(calcpos(xcol,ycol)), "{b}", title,
          row + 1, ycol += 15
          IF (ycol > 710)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
          xcol = 30, title = " {b} Bin {endb} ",
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          xcol = 90, title = " {b} Item Description {endb} ",
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          xcol = 400, title = " {b} Item Number {endb} ",
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          xcol = 490, title = " {b} Open {endb} ",
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          xcol = 520, title = " {b} Hold {endb} ",
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          xcol = 550, title = " {b} Sch Ind {endb} ",
          CALL print(calcpos(xcol,ycol)),
          "{b}", title, row + 1,
          ycol += 15
          IF (ycol > 710)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
         ELSE
          IF ((m_fin_pref->item[ml_idx].s_item_loc != m_fin_pref->item[(ml_idx - 1)].s_item_loc))
           xcol = 30, ycol += 5, title = concat(" {b} Pick Location: {endb} ",m_fin_pref->item[ml_idx
            ].s_item_loc),
           CALL print(calcpos(xcol,ycol)), "{b}", title,
           row + 1, ycol += 15
           IF (ycol > 710)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           xcol = 30, title = " {b} Bin {endb} ",
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           xcol = 100, title = " {b} Item Description {endb} ",
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           xcol = 400, title = " {b} Item Number {endb} ",
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           xcol = 490, title = " {b} Open {endb} ",
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           xcol = 520, title = " {b} Hold {endb} ",
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           xcol = 550, title = " {b} Sch Ind {endb} ",
           CALL print(calcpos(xcol,ycol)),
           "{b}", title, row + 1,
           ycol += 15
           IF (ycol > 710)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
          ENDIF
         ENDIF
         xcol = 30, title = m_fin_pref->item[ml_idx].s_bin,
         CALL print(calcpos(xcol,ycol)),
         title, row + 1, xcol = 100,
         title = m_fin_pref->item[ml_idx].s_item_desc,
         CALL print(calcpos(xcol,ycol)), title,
         row + 1, xcol = 400, title = substring(1,17,m_fin_pref->item[ml_idx].s_item_nbr),
         CALL print(calcpos(xcol,ycol)), title, row + 1,
         xcol = 500, title = m_fin_pref->item[ml_idx].s_open,
         CALL print(calcpos(xcol,ycol)),
         title, row + 1, xcol = 530,
         title = m_fin_pref->item[ml_idx].s_hold,
         CALL print(calcpos(xcol,ycol)), title,
         row + 1, xcol = 555, title = m_fin_pref->item[ml_idx].s_sch,
         CALL print(calcpos(xcol,ycol)), title, row + 1,
         ycol += 8
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
       ENDFOR
      ENDIF
      IF ((m_fin_pref->l_com_cnt > 0))
       xcol = 100, ycol = 720,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK,
       xcol = 30, l += 1, ycol += 5,
       title = build(l,"-","{b}Pref Card Comments:"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       title, row + 1, ycol += 10
       FOR (ml_idx = 1 TO m_fin_pref->l_com_cnt)
         IF (ycol > 710)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         ycol += 10, xcol = 30, tempstring = m_fin_pref->com_qual[ml_idx].s_comment_text,
         wrapcol = 122, line_wrap2
       ENDFOR
      ENDIF
     FOOT REPORT
      xcol = 100, ycol += 10, temp1 = concat("***** ","End of Report For ",pat->qual[x].name," *****"
       ),
      CALL print(calcpos(xcol,ycol)), temp1, row + 1
     WITH nocounter, maxrow = 800, maxcol = 1000,
      dio = postscript, nullreport
    ;end select
    SET spool value(pat->qual[x].filename)  $1
    SET tmp_remove = build2('set stat = remove("',pat->qual[x].filename,'") go')
    CALL echo(build("end - File Name:,",x,":",pat->qual[x].filename))
    CALL echo(tmp_remove)
    CALL parser(tmp_remove)
   ENDIF
 ENDFOR
#exit_script
END GO
