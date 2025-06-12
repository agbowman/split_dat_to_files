CREATE PROGRAM bhs_mu_encounter:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Input File :" = "2010_october_mlh.txt",
  "Output File:" = "2010_october_mlh_out_enc.txt",
  "Report Type Flag (1=inpt 2=amb 3=sms 4=wnerta 5=recur):" = 1
  WITH outdev, input_file, output_file,
  report_type_flag
 DECLARE mf_pat_ed_form = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTFAMILYEDUCATIONFORM"))
 DECLARE mf_pat_ed_newb = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTFAMILYEDUCATIONNEWBORNFORM"))
 DECLARE mf_pat_ed_ob = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTFAMILYEDUCATIONOBFORM"))
 DECLARE mf_pat_ed_neon = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTFAMILYEDUCATIONNEONATALFORM"))
 DECLARE mf_pat_ed_pedi = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTFAMILYEDUCATIONPEDIFORM"))
 DECLARE mf_pat_ed_preop_card = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREOPCARDIACSURGERYEDUCATIONFORM"))
 DECLARE mf_pat_ed_precard_int = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PRECARDIACINTERVENTIONEDUCATIONFORM"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_sex_unknown_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"UNKNOWN"))
 DECLARE mf_sex_unspecified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,
   "UNSPECIFIED"))
 DECLARE mf_advance_dir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVE"))
 DECLARE mf_patient_ed_inst = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTEDUCATIONINSTRUCTION"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_order_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "CANCELED"))
 DECLARE mf_order_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED"))
 DECLARE mf_order_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "COMPLETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12030,"CANCELED"))
 DECLARE mf_dictated_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15750,"DICTATED"))
 DECLARE mf_signed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15750,"SIGNED"))
 DECLARE mf_transcribed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15750,
   "TRANSCRIBED"))
 DECLARE mf_prelim_cod = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PRELIMCAUSEOFDEATH"))
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ml_rpt_inpatient = i4 WITH protect, constant(1)
 DECLARE ml_rpt_ambulatory = i4 WITH protect, constant(2)
 DECLARE ml_rpt_sms = i4 WITH protect, constant(3)
 DECLARE ml_rpt_wnerta = i4 WITH protect, constant(4)
 DECLARE ml_rpt_recurring = i4 WITH protect, constant(5)
 DECLARE ml_rpt_debug_acct_inpt = i4 WITH protect, constant(91)
 DECLARE ml_rpt_debug_acct_amb = i4 WITH protect, constant(92)
 DECLARE ml_rpt_debug_acct_sms = i4 WITH protect, constant(93)
 DECLARE ml_rpt_debug_acct_wnerta = i4 WITH protect, constant(94)
 DECLARE ml_rpt_debug_acct_recurring = i4 WITH protect, constant(95)
 DECLARE ms_output = vc WITH protect, constant(value( $OUTDEV))
 DECLARE mn_report_type_flag = i4 WITH protect, constant( $REPORT_TYPE_FLAG)
 DECLARE ms_input_logical = vc WITH protect, constant("mu_in_enc")
 DECLARE ms_output_logical = vc WITH protect, constant("mu_out_enc")
 DECLARE md_timer_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_timer_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_loop_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_projected_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_service_dt_tm = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_service_dt = vc WITH protect, noconstant(" ")
 DECLARE ms_vital_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_report_type = vc WITH protect, noconstant(" ")
 DECLARE ms_date = vc WITH protect, noconstant(" ")
 DECLARE ms_time = vc WITH protect, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE ms_wnerta_pid = vc WITH protect, noconstant(" ")
 DECLARE mc_ed_ind = c1 WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_year = i4 WITH protect, noconstant(0)
 DECLARE ml_month = i4 WITH protect, noconstant(0)
 DECLARE ml_day = i4 WITH protect, noconstant(0)
 DECLARE ml_day_of_the_week = i4 WITH protect, noconstant(0)
 DECLARE mf_time_diff = f8 WITH protect, noconstant(0.0)
 DECLARE mf_projected_runtime = f8 WITH protect, noconstant(0.0)
 DECLARE mn_demog_lang_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_demog_race_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_demog_ethn_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_demog_dob_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_demog_gender_ind = i2 WITH protect, noconstant(0)
 IF (validate(reply->c_status)=0)
  RECORD reply(
    1 c_status = c1
  )
 ENDIF
 SET reply->c_status = "F"
 FREE RECORD input
 RECORD input(
   1 qual[*]
     2 s_fin = vc
     2 d_service_dt_tm = dq8
     2 c_ed_ind = c1
 )
 FREE RECORD cv_vital
 RECORD cv_vital(
   1 qual[*]
     2 f_code_value = f8
     2 s_display = cv
 )
 FREE RECORD cv_smoke
 RECORD cv_smoke(
   1 qual[*]
     2 f_code_value = f8
     2 s_display = cv
 )
 FREE RECORD cv_rs_inv
 RECORD cv_rs_inv(
   1 qual[*]
     2 f_code_value = f8
     2 s_display = cv
 )
 FREE RECORD cv_pat_ed
 RECORD cv_pat_ed(
   1 qual[*]
     2 f_code_value = f8
     2 s_display = cv
 )
 FREE RECORD cv_dead
 RECORD cv_dead(
   1 qual[*]
     2 f_code_value = f8
     2 s_display = cv
 )
 RECORD murf_request(
   1 s_filename = vc
 )
 RECORD murf_reply(
   1 s_file_type = vc
   1 qual[*]
     2 s_fin = vc
     2 d_service_dt_tm = dq8
     2 f_phy_npi = f8
     2 c_ed_ind = c1
   1 c_status = c1
 )
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 s_name_full_formatted = vc
     2 s_cmrn = vc
     2 f_pid = f8
     2 d_birth_dt_tm = dq8
     2 c_pos = c2
     2 f_eid = f8
     2 s_fin = vc
     2 d_beg_encntr_dt_tm = dq8
     2 d_end_encntr_dt_tm = dq8
     2 d_3_bus_days_dt_tm = dq8
     2 n_prob_ind = i2
     2 n_diag_ind = i2
     2 n_meds_coded_ind = i2
     2 n_cpoe_eligible_ind = i2
     2 n_cpoe_satisfied_ind = i2
     2 n_allergy_drug_ind = i2
     2 n_smoke_ind = i2
     2 n_vitals_ind = i2
     2 n_advance_dir_ind = i2
     2 n_clin_summary_ind = i2
     2 n_patient_ed_ind = i2
     2 n_demographics_ind = i2
     2 n_disch_dead_ind = i2
     2 n_prelim_cod_ord_ind = i2
 )
 SET logical mu_in_enc value(trim( $INPUT_FILE,3))
 CALL echo(build("LOGICAL mu_in_enc :",logical(ms_input_logical)))
 SET logical mu_out_enc value(trim( $OUTPUT_FILE,3))
 CALL echo(build("LOGICAL mu_out_enc:",logical(ms_output_logical)))
 EXECUTE bhs_hlp_csv
 EXECUTE bhs_hlp_err
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown during setup.  Exiting.")
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script ",curprog))
 ENDIF
 CASE (mn_report_type_flag)
  OF ml_rpt_inpatient:
   SET ms_report_type = "Inpatient"
  OF ml_rpt_ambulatory:
   SET ms_report_type = "Ambulatory"
  OF ml_rpt_sms:
   SET ms_report_type = "SMS"
  OF ml_rpt_wnerta:
   SET ms_report_type = "WNERTA"
  OF ml_rpt_recurring:
   SET ms_report_type = "RECURRING"
  OF ml_rpt_debug_acct_inpt:
   SET ms_report_type = "DEBUG ACCT# INPT"
  OF ml_rpt_debug_acct_amb:
   SET ms_report_type = "DEBUG ACCT# AMB"
  OF ml_rpt_debug_acct_sms:
   SET ms_report_type = "Debug ACCT# SMS"
  OF ml_rpt_debug_acct_wnerta:
   SET ms_report_type = "Debug ACCT# WNERTA"
  OF ml_rpt_debug_acct_recurring:
   SET ms_report_type = "Debug ACCT# RECURRING"
 ENDCASE
 CALL echo(concat("MU report type:         ",ms_report_type))
 CALL echo(concat("Input file:             ",logical(ms_input_logical)))
 CALL echo(concat("Output file:            ",logical(ms_output_logical)))
 CALL echo(concat("Processing start time:  ",format(md_timer_start,"DD-MMM-YYYY HH:MM:SS;;D")))
 CALL echo(concat("Debug flag:             ",cnvtstring(ml_debug_flag)))
 IF (mn_report_type_flag IN (ml_rpt_inpatient, ml_rpt_ambulatory, ml_rpt_sms, ml_rpt_wnerta,
 ml_rpt_recurring)
  AND findfile(ms_input_logical)=0)
  CALL echo(build('The input file "',logical(ms_input_logical),'" was not found.'))
  GO TO exit_script
 ENDIF
 IF ( NOT (mn_report_type_flag IN (ml_rpt_inpatient, ml_rpt_ambulatory, ml_rpt_sms, ml_rpt_wnerta,
 ml_rpt_recurring,
 ml_rpt_debug_acct_inpt, ml_rpt_debug_acct_amb, ml_rpt_debug_acct_sms, ml_rpt_debug_acct_wnerta,
 ml_rpt_debug_acct_recurring)))
  CALL echo(build("Invalid report type flag"))
  GO TO exit_script
 ENDIF
 IF (mn_report_type_flag IN (ml_rpt_debug_acct_inpt, ml_rpt_debug_acct_amb, ml_rpt_debug_acct_sms,
 ml_rpt_debug_acct_wnerta))
  SET stat = alterlist(murf_reply->qual,1)
  SET murf_reply->qual[1].s_fin = logical(ms_input_logical)
 ELSE
  CALL echo(concat("Processing input file ",logical(ms_input_logical)))
  SET md_timer_stop = sysdate
  CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
    " minutes"))
  SET stat = initrec(murf_request)
  SET stat = initrec(murf_reply)
  SET murf_request->s_filename = logical(ms_input_logical)
  EXECUTE bhs_mu_read_file
  IF ((murf_reply->c_status != "S"))
   CALL echo(build("Input file was not successfully read...  Exiting"))
   GO TO exit_script
  ENDIF
  IF ((murf_reply->s_file_type="UNKNOWN"))
   CALL echo(build("Unknown file type...  Exiting"))
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(build("Rows inputted:",size(murf_reply->qual,5)))
 IF (size(murf_reply->qual,5)=0)
  CALL echo(build("Input parsing found 0 rows"))
  GO TO exit_script
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo(concat("Error thrown while reading ", $INPUT_FILE,".  Exiting."))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=72
   AND ((cv.display_key="HEIGHT") OR (((cv.display_key="HEIGHTOTHER") OR (((cv.display_key="WEIGHT")
   OR (((cv.display_key="WEIGHTOTHER") OR (((cv.display_key="*SYSTOLIC*") OR (((cv.display_key=
  "*DIASTOLIC*") OR (((cv.display_key="BLOODPRESSUREOTHER") OR (((cv.display_key="BODYMASSINDEX*")
   OR (((cv.display_key="LASTDOCUMENTEDHEIGHTWEIGHTBMI") OR (cv.display_key="BMICALC")) )) )) )) ))
  )) )) )) ))
   AND  NOT (cv.display_key IN ("SYSTOLICMURMURDESCRIPTION", "SYSTOLICMURMURGRADE",
  "SYSTOLICPRESSUREASSISTED", "PAPDIASYSTOLIC", "DIASTOLICMURMURDESCRIPTION",
  "DIASTOLICMURMURGRADE", "DIASTOLICPRESSUREASSISTED", "AUGMENTEDENDDIASTOLICPRESSURE",
  "DIASTOLICAUGMENTATIONALARMSETTING"))
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(cv_vital->qual,ml_cnt), cv_vital->qual[ml_cnt].f_code_value
    = cv.code_value,
   cv_vital->qual[ml_cnt].s_display = cv.display
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("Number of vitals code values found:",size(cv_vital->qual,5)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the vitals code values.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=72
   AND cv.display_key="*SMOK*"
   AND  NOT (cv.display_key IN ("PATIENTINFORMEDSMOKEFREEHOSPITAL",
  "INFORMPATIENTHOSPITALISSMOKEFREE", "EDBURNSMOKEINHALATION"))
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(cv_smoke->qual,ml_cnt), cv_smoke->qual[ml_cnt].f_code_value
    = cv.code_value,
   cv_smoke->qual[ml_cnt].s_display = cv.display
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("Number of smoking code values found:",size(cv_smoke->qual,5)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the smoking code values.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=8
   AND cv.display_key IN ("INERROR", "NOTDONE")
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(cv_rs_inv->qual,ml_cnt), cv_rs_inv->qual[ml_cnt].
   f_code_value = cv.code_value,
   cv_rs_inv->qual[ml_cnt].s_display = cv.display
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("Number of undesired result status code values found:",size(cv_rs_inv->qual,5)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the undesired result status code values.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=19
   AND ((cv.display_key="*DECEASED*") OR (((cv.display_key="*EXPIRE*") OR (cv.display_key="*DEATH*"
  )) ))
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(cv_dead->qual,ml_cnt), cv_dead->qual[ml_cnt].f_code_value
    = cv.code_value,
   cv_dead->qual[ml_cnt].s_display = cv.display
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("Number of dead code values found:",size(cv_dead->qual,5)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the dead code values.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(murf_reply->qual,5)),
   encntr_alias ea,
   encounter e,
   person p,
   person_alias pa,
   code_value cv
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=murf_reply->qual[d.seq].s_fin)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < sysdate
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < sysdate
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
   JOIN (cv
   WHERE cv.code_value=e.encntr_type_cd)
  ORDER BY d.seq
  HEAD REPORT
   ml_cnt = 0
  HEAD d.seq
   ml_cnt = (ml_cnt+ 1), stat = alterlist(temp->qual,ml_cnt), temp->qual[ml_cnt].
   s_name_full_formatted = p.name_full_formatted,
   temp->qual[ml_cnt].s_cmrn = pa.alias, temp->qual[ml_cnt].f_pid = p.person_id, temp->qual[ml_cnt].
   d_birth_dt_tm = p.birth_dt_tm,
   temp->qual[ml_cnt].f_eid = e.encntr_id, temp->qual[ml_cnt].s_fin = murf_reply->qual[d.seq].s_fin,
   ml_pos = locateval(ml_idx,1,size(cv_dead->qual,5),e.disch_disposition_cd,cv_dead->qual[ml_idx].
    f_code_value)
   IF (ml_pos > 0)
    temp->qual[ml_cnt].n_disch_dead_ind = 1
   ENDIF
   IF (mn_report_type_flag IN (ml_rpt_inpatient))
    IF ((murf_reply->qual[d.seq].c_ed_ind != "Y"))
     temp->qual[ml_cnt].c_pos = "21"
    ELSE
     temp->qual[ml_cnt].c_pos = "23"
    ENDIF
    temp->qual[ml_cnt].d_beg_encntr_dt_tm = e.reg_dt_tm, temp->qual[ml_cnt].d_end_encntr_dt_tm =
    murf_reply->qual[d.seq].d_service_dt_tm
   ELSEIF (mn_report_type_flag IN (ml_rpt_ambulatory, ml_rpt_sms, ml_rpt_wnerta, ml_rpt_recurring))
    temp->qual[ml_cnt].d_beg_encntr_dt_tm = cnvtdatetime(cnvtdate(murf_reply->qual[d.seq].
      d_service_dt_tm),0)
    IF (cv.display_key="*RECUR*")
     temp->qual[ml_cnt].d_end_encntr_dt_tm = e.disch_dt_tm
    ELSE
     temp->qual[ml_cnt].d_end_encntr_dt_tm = cnvtdatetime(cnvtdate(murf_reply->qual[d.seq].
       d_service_dt_tm),235959)
    ENDIF
   ELSEIF (mn_report_type_flag IN (ml_rpt_debug_acct_inpt))
    temp->qual[ml_cnt].d_beg_encntr_dt_tm = e.reg_dt_tm, temp->qual[ml_cnt].d_end_encntr_dt_tm = e
    .disch_dt_tm
   ELSEIF (mn_report_type_flag IN (ml_rpt_debug_acct_amb, ml_rpt_debug_acct_sms,
   ml_rpt_debug_acct_wnerta, ml_rpt_debug_acct_recurring))
    temp->qual[ml_cnt].d_beg_encntr_dt_tm = cnvtdatetime(cnvtdate(e.reg_dt_tm),0), temp->qual[ml_cnt]
    .d_end_encntr_dt_tm = cnvtdatetime(cnvtdate(e.reg_dt_tm),235959)
   ENDIF
   ml_day_of_the_week = weekday(temp->qual[ml_cnt].d_end_encntr_dt_tm), temp->qual[ml_cnt].
   d_3_bus_days_dt_tm = evaluate(ml_day_of_the_week,0,datetimefind(datetimeadd(temp->qual[ml_cnt].
      d_end_encntr_dt_tm,3),"D","E","E"),1,datetimefind(datetimeadd(temp->qual[ml_cnt].
      d_end_encntr_dt_tm,3),"D","E","E"),
    2,datetimefind(datetimeadd(temp->qual[ml_cnt].d_end_encntr_dt_tm,3),"D","E","E"),3,datetimefind(
     datetimeadd(temp->qual[ml_cnt].d_end_encntr_dt_tm,5),"D","E","E"),4,
    datetimefind(datetimeadd(temp->qual[ml_cnt].d_end_encntr_dt_tm,5),"D","E","E"),5,datetimefind(
     datetimeadd(temp->qual[ml_cnt].d_end_encntr_dt_tm,5),"D","E","E"),6,datetimefind(datetimeadd(
      temp->qual[ml_cnt].d_end_encntr_dt_tm,4),"D","E","E"))
  FOOT  d.seq
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("Number of encounters qualified:",size(temp->qual,5)))
 IF (size(temp->qual,5)=0)
  CALL echo("No encounters qualified.  Generating empty output file.")
  GO TO generate_report
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the encounters.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   problem p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp->qual[d.seq].f_pid)
    AND p.nomenclature_id > 0
    AND p.life_cycle_status_cd != mf_canceled_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND p.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_prob_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Problem:",p.problem_id))
   ENDIF
  WITH nocounter, maxqual(p,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the problems.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   diagnosis dx
  PLAN (d)
   JOIN (dx
   WHERE (dx.person_id=temp->qual[d.seq].f_pid)
    AND dx.nomenclature_id > 0
    AND dx.active_ind=1
    AND dx.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND dx.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_diag_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Diagnosis:",dx.diagnosis_id))
   ENDIF
  WITH nocounter, maxqual(dx,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the diagnoses.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   allergy a
  PLAN (d
   WHERE (temp->qual[d.seq].f_pid > 0))
   JOIN (a
   WHERE (a.person_id=temp->qual[d.seq].f_pid)
    AND a.reaction_status_cd != mf_canceled_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND a.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_allergy_drug_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Allergy:",a.allergy_id))
   ENDIF
  WITH nocounter, maxqual(a,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the drug allergies.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=temp->qual[d.seq].f_pid)
    AND expand(ml_idx,1,size(cv_vital->qual,5),ce.event_cd,cv_vital->qual[ml_idx].f_code_value)
    AND  NOT (expand(ml_idx,1,size(cv_rs_inv->qual,5),ce.result_status_cd,cv_rs_inv->qual[ml_idx].
    f_code_value))
    AND ce.valid_from_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND ce.valid_until_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm))
  ORDER BY d.seq
  HEAD d.seq
   ht = 0, wt = 0, bmi = 0,
   bps = 0, bpd = 0
  DETAIL
   ms_vital_disp = cnvtupper(uar_get_code_display(ce.event_cd))
   CASE (ms_vital_disp)
    OF "HEIGHT":
     ht = 1
    OF "HEIGHTOTHER":
     ht = 1
    OF "WEIGHT":
     wt = 1
    OF "WEIGHTOTHER":
     wt = 1
    OF "*SYSTOLIC*":
     bps = 1
    OF "*DIASTOLIC*":
     bpd = 1
    OF "BLOODPRESSUREOTHER":
     bps = 1,bpd = 1
    OF "BODY MASS INDEX*":
     bmi = 1
    OF "LASTDOCUMENTEDHEIGHTWEIGHTBMI":
     bmi = 1
    OF "BMICALC":
     bmi = 1
   ENDCASE
   IF (ml_debug_flag >= 20)
    CALL echo(build("Vital:",ms_vital_disp))
   ENDIF
  FOOT  d.seq
   IF (bps=1
    AND bpd=1
    AND ((bmi=1) OR (ht=1
    AND wt=1)) )
    temp->qual[d.seq].n_vitals_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the vitals.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=temp->qual[d.seq].f_pid)
    AND expand(ml_idx,1,size(cv_smoke->qual,5),ce.event_cd,cv_smoke->qual[ml_idx].f_code_value)
    AND  NOT (expand(ml_idx,1,size(cv_rs_inv->qual,5),ce.result_status_cd,cv_rs_inv->qual[ml_idx].
    f_code_value))
    AND ce.valid_from_dt_tm > cnvtdatetime(datetimeadd(temp->qual[d.seq].d_beg_encntr_dt_tm,- (365)))
    AND ce.valid_until_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].n_smoke_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Smoke CE:",ce.clinical_event_id))
   ENDIF
  FOOT  d.seq
   row + 0
  WITH nocounter, maxqual(ce,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying for smoke check CE.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   hm_expect_mod mod,
   hm_expect_sat sat,
   hm_expect he
  PLAN (d
   WHERE (temp->qual[d.seq].n_smoke_ind=0))
   JOIN (mod
   WHERE (mod.person_id=temp->qual[d.seq].f_pid)
    AND mod.active_ind=1
    AND mod.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND mod.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm))
   JOIN (sat
   WHERE sat.expect_sat_id=mod.expect_sat_id
    AND sat.active_ind=1
    AND sat.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND sat.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)
    AND ((sat.satisfied_duration=0) OR (mod.modifier_dt_tm > datetimeadd(cnvtdatetime(temp->qual[d
     .seq].d_beg_encntr_dt_tm),(0 - sat.satisfied_duration)))) )
   JOIN (he
   WHERE sat.expect_id=he.expect_id
    AND he.expect_name="Tobacco*"
    AND he.active_ind=1
    AND he.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND he.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_smoke_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Smoke HM:",mod.expect_mod_id))
   ENDIF
  WITH nocounter, maxqual(mod,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying for smoke check in HM.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=temp->qual[d.seq].f_pid)
    AND  NOT (expand(ml_idx,1,size(cv_rs_inv->qual,5),ce.result_status_cd,cv_rs_inv->qual[ml_idx].
    f_code_value))
    AND ce.event_cd IN (mf_advance_dir_cd)
    AND ce.valid_from_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND ce.valid_until_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_advance_dir_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Advance Directive CE:",ce.clinical_event_id))
   ENDIF
  WITH nocounter, maxqual(ce,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying advance directive CE.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   person_patient p
  PLAN (d
   WHERE (temp->qual[d.seq].n_advance_dir_ind=0))
   JOIN (p
   WHERE (p.person_id=temp->qual[d.seq].f_pid)
    AND  NOT (p.living_will_cd IN (0, null))
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND p.end_effective_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_advance_dir_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Advance Directive PP:",p.person_id))
   ENDIF
  WITH nocounter, maxqual(p,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying advance directive PERSON.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   orders o,
   (dummyt d2  WITH seq = 1),
   order_action oa
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=temp->qual[d.seq].f_pid)
    AND o.orig_ord_as_flag IN (1, 2, 3)
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.orig_order_dt_tm <= cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND ((o.projected_stop_dt_tm=null) OR (o.projected_stop_dt_tm >= cnvtdatetime(temp->qual[d.seq].
    d_beg_encntr_dt_tm)))
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM order_action oa
    WHERE oa.order_id=o.order_id
     AND oa.order_status_cd IN (mf_order_canceled_cd, mf_order_discontinued_cd, mf_order_completed_cd
    )
     AND oa.action_dt_tm < cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)))))
   JOIN (d2)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1
    AND  EXISTS (
   (SELECT
    pr.person_id
    FROM prsnl pr
    WHERE pr.person_id=oa.action_personnel_id
     AND pr.physician_ind=1)))
  DETAIL
   temp->qual[d.seq].n_meds_coded_ind = 1, temp->qual[d.seq].n_cpoe_eligible_ind = 1
   IF (oa.order_action_id > 0)
    temp->qual[d.seq].n_cpoe_satisfied_ind = 1
   ENDIF
   IF (ml_debug_flag >= 20)
    CALL echo(build("Med Order:",o.order_id,":",oa.order_action_id))
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying med orders.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   order_compliance oc
  PLAN (d
   WHERE (temp->qual[d.seq].n_meds_coded_ind=0))
   JOIN (oc
   WHERE (oc.encntr_id=temp->qual[d.seq].f_eid)
    AND oc.no_known_home_meds_ind=1)
  DETAIL
   temp->qual[d.seq].n_meds_coded_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Meds Coded:",oc.order_compliance_id))
   ENDIF
  WITH nocounter, maxqual(oc,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying med orders (No Home Meds).  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=temp->qual[d.seq].f_eid)
    AND ce.event_cd=mf_patient_ed_inst
    AND  NOT (expand(ml_idx,1,size(cv_rs_inv->qual,5),ce.result_status_cd,cv_rs_inv->qual[ml_idx].
    f_code_value))
    AND ce.valid_from_dt_tm < cnvtdatetime(temp->qual[d.seq].d_3_bus_days_dt_tm)
    AND ce.valid_until_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(temp->qual[d.seq].d_3_bus_days_dt_tm))
  DETAIL
   temp->qual[d.seq].n_clin_summary_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Clinical Summary:",ce.clinical_event_id))
   ENDIF
  WITH nocounter, maxqual(ce,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying discharge summary.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   pat_ed_document ped
  PLAN (d)
   JOIN (ped
   WHERE (ped.encntr_id=temp->qual[d.seq].f_eid))
  DETAIL
   temp->qual[d.seq].n_patient_ed_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Patient Education:",ped.pat_ed_document_id))
   ENDIF
  WITH nocounter, maxqual(ped,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying patient education.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   clinical_event ce
  PLAN (d
   WHERE (temp->qual[d.seq].n_patient_ed_ind=0))
   JOIN (ce
   WHERE (ce.person_id=temp->qual[d.seq].f_pid)
    AND ce.event_cd IN (mf_pat_ed_form, mf_pat_ed_newb, mf_pat_ed_ob, mf_pat_ed_neon, mf_pat_ed_pedi,
   mf_pat_ed_preop_card, mf_pat_ed_precard_int)
    AND  NOT (expand(ml_idx,1,size(cv_rs_inv->qual,5),ce.result_status_cd,cv_rs_inv->qual[ml_idx].
    f_code_value))
    AND ce.valid_from_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm)
    AND ce.valid_until_dt_tm > cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)
    AND ce.event_end_dt_tm < cnvtdatetime(temp->qual[d.seq].d_end_encntr_dt_tm))
  DETAIL
   temp->qual[d.seq].n_patient_ed_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Patient Education DTA:",ce.clinical_event_id))
   ENDIF
  WITH nocounter, maxqual(ce,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying patient education DTA.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   encounter e,
   person p,
   bhs_demographics bd
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=temp->qual[d.seq].f_eid))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (bd
   WHERE bd.person_id=outerjoin(p.person_id)
    AND bd.active_ind=outerjoin(1)
    AND bd.end_effective_dt_tm > outerjoin(cnvtdatetime(temp->qual[d.seq].d_beg_encntr_dt_tm)))
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   mn_demog_lang_ind = 0, mn_demog_race_ind = 0, mn_demog_ethn_ind = 0,
   mn_demog_dob_ind = 0, mn_demog_gender_ind = 0
  DETAIL
   IF (p.birth_dt_tm > cnvtdatetime("01-JAN-1800"))
    mn_demog_dob_ind = 1
    IF (ml_debug_flag >= 20)
     CALL echo(build("Demographics DOB:",bd.bhs_demographics_id))
    ENDIF
   ENDIF
   IF ( NOT (p.sex_cd IN (mf_sex_unspecified_cd, mf_sex_unknown_cd)))
    mn_demog_gender_ind = 1
    IF (ml_debug_flag >= 20)
     CALL echo(build("Demographics Gender:",bd.bhs_demographics_id))
    ENDIF
   ENDIF
   IF (cnvtupper(bd.description)="ETHNICITY*")
    mn_demog_ethn_ind = 1
    IF (ml_debug_flag >= 20)
     CALL echo(build("Demographics Ethnicity:",bd.bhs_demographics_id))
    ENDIF
   ENDIF
   IF (cnvtupper(bd.description)="RACE*")
    mn_demog_race_ind = 1
    IF (ml_debug_flag >= 20)
     CALL echo(build("Demographics Race:",bd.bhs_demographics_id))
    ENDIF
   ENDIF
   IF (cnvtupper(bd.description)="LANGUAGE*")
    mn_demog_lang_ind = 1
    IF (ml_debug_flag >= 20)
     CALL echo(build("Demographics Language:",bd.bhs_demographics_id))
    ENDIF
   ENDIF
  FOOT  e.encntr_id
   IF (mn_demog_dob_ind=1
    AND mn_demog_race_ind=1
    AND mn_demog_ethn_ind=1
    AND mn_demog_lang_ind=1
    AND mn_demog_gender_ind=1)
    temp->qual[d.seq].n_demographics_ind = 1
    IF (ml_debug_flag >= 20)
     CALL echo(build("Demographics Satisfied"))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying demographics.  Exiting.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   orders o,
   order_detail od
  PLAN (d
   WHERE (temp->qual[d.seq].n_disch_dead_ind=1))
   JOIN (o
   WHERE (o.encntr_id=temp->qual[d.seq].f_eid))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_prelim_cod)
  DETAIL
   temp->qual[d.seq].n_prelim_cod_ord_ind = 1
   IF (ml_debug_flag >= 20)
    CALL echo(build("Preliminary Cause of Death:",od.order_id))
   ENDIF
  WITH nocounter, maxqual(od,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying Preliminary Cause of Death order detail.  Exiting.")
  GO TO exit_script
 ENDIF
#generate_report
 SELECT INTO value(ms_output_logical)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("encounter_id,account_number,encounter_begin_dt_tm,encounter_end_dt_tm,",
    "name_full_formatted,birth_dt_tm,cmrn,person_id,","problem_ind,diagnosis_ind,meds_coded_ind,",
    "cpoe_eligible_ind,cpoe_ind,drug_allergy_ind,smoke_ind,vitals_ind,",
    "advance_directive_ind,clinical_summary_ind,pos,patient_ed_ind,demographics_ind,",
    "discharge_expired_ind,preliminary_cause_of_death_ind"), row 0, col 0,
   ms_line
   FOR (ml_cnt = 1 TO size(temp->qual,5))
     ms_line = build(cnvtstring(temp->qual[ml_cnt].f_eid),",",'"',temp->qual[ml_cnt].s_fin,'"',
      ",",format(temp->qual[ml_cnt].d_beg_encntr_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),",",format(temp->
       qual[ml_cnt].d_end_encntr_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),",",
      '"',temp->qual[ml_cnt].s_name_full_formatted,'"',",",format(temp->qual[ml_cnt].d_birth_dt_tm,
       "YYYY-MM-DD HH:MM:SS;;D"),
      ",",'"',temp->qual[ml_cnt].s_cmrn,'"',",",
      cnvtstring(temp->qual[ml_cnt].f_pid),",",cnvtstring(temp->qual[ml_cnt].n_prob_ind),",",
      cnvtstring(temp->qual[ml_cnt].n_diag_ind),
      ",",cnvtstring(temp->qual[ml_cnt].n_meds_coded_ind),",",cnvtstring(temp->qual[ml_cnt].
       n_cpoe_eligible_ind),",",
      cnvtstring(temp->qual[ml_cnt].n_cpoe_satisfied_ind),",",cnvtstring(temp->qual[ml_cnt].
       n_allergy_drug_ind),",",cnvtstring(temp->qual[ml_cnt].n_smoke_ind),
      ",",cnvtstring(temp->qual[ml_cnt].n_vitals_ind),",",cnvtstring(temp->qual[ml_cnt].
       n_advance_dir_ind),",",
      cnvtstring(temp->qual[ml_cnt].n_clin_summary_ind),",",temp->qual[ml_cnt].c_pos,",",cnvtstring(
       temp->qual[ml_cnt].n_patient_ed_ind),
      ",",cnvtstring(temp->qual[ml_cnt].n_demographics_ind),",",cnvtstring(temp->qual[ml_cnt].
       n_disch_dead_ind),",",
      cnvtstring(temp->qual[ml_cnt].n_prelim_cod_ord_ind)), row + 1, col 0,
     ms_line
   ENDFOR
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 500, maxrow = 1
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while generating the output file.  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 SELECT INTO value(ms_output)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "The Meaningful Use encounter-based output csv file was created.",
   row + 1, ms_line = concat("MU Report type:         ",ms_report_type), col 0,
   ms_line, row + 1, ms_line = concat("Input file:             ",logical(ms_input_logical)),
   col 0, ms_line, row + 1,
   ms_line = concat("Output file:            ",logical(ms_output_logical)), col 0, ms_line,
   row + 1, ms_line = concat("Records:                ",cnvtstring(size(temp->qual,5))), col 0,
   ms_line, row + 1, ms_line = concat("Processing start time:  ",format(md_timer_start,
     "DD-MMM-YYYY HH:MM:SS;;D")),
   col 0, ms_line, row + 1,
   ms_line = concat("Processing end time:    ",format(md_timer_stop,"DD-MMM-YYYY HH:MM:SS;;D")), col
   0, ms_line,
   row + 1, ms_line = concat("Processing time:        ",trim(cnvtstring(datetimediff(md_timer_stop,
       md_timer_start,4)),3)," minutes"), col 0,
   ms_line, row + 1, ms_line = concat("Debug flag:             ",cnvtstring(ml_debug_flag)),
   col 0, ms_line
  WITH nocounter
 ;end select
 SET reply->c_status = "S"
#exit_script
 IF (ml_debug_flag >= 90)
  CALL echorecord(temp)
 ENDIF
 IF (ml_debug_flag >= 0)
  CALL echo("############################################")
  CALL echo(concat("Status:                 ",reply->c_status))
  CALL echo(concat("MU Report type:         ",ms_report_type))
  CALL echo(concat("Input file:             ",logical(ms_input_logical)))
  CALL echo(concat("Output file:            ",logical(ms_output_logical)))
  CALL echo(concat("Records:                ",cnvtstring(size(temp->qual,5))))
  CALL echo(concat("Processing start time:  ",format(md_timer_start,"DD-MMM-YYYY HH:MM:SS;;D")))
  CALL echo(concat("Processing start time:  ",format(md_timer_stop,"DD-MMM-YYYY HH:MM:SS;;D")))
  CALL echo(concat("Processing time:        ",trim(cnvtstring(datetimediff(md_timer_stop,
       md_timer_start,4)),3)," minutes"))
  CALL echo(concat("Debug flag:             ",cnvtstring(ml_debug_flag)))
  CALL echo("############################################")
 ENDIF
 SET stat = bhs_clear_error(0)
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Exiting script ",curprog," with status ",reply->c_status))
 ELSE
  FREE RECORD input
  FREE RECORD cv_vital
  FREE RECORD cv_smoke
  FREE RECORD temp
 ENDIF
END GO
