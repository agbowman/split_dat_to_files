CREATE PROGRAM al_bhs_rpt_prenatal_summary:dba
 PROMPT
  "Send Message to Screen" = "MINE",
  "Patient:" = "",
  "Enter EDD - End Date:" = "CURDATE",
  "Output to File/Printer/MINE" = "MINE"
  WITH messagetoscreen, lstperson, edate,
  outdev
 CALL echo("Defining Record Structure Section")
 FREE RECORD requested_fac
 RECORD requested_fac(
   1 pat_fac[*]
     2 mf_person_id = f8
 )
 FREE RECORD work_form
 RECORD work_form(
   1 forms[*]
     2 mf_person_id = f8
     2 mf_encntr_id = f8
     2 mf_dcp_forms_actv_id = f8
     2 ms_dcp_desc = vc
     2 ms_reference_nbr = vc
     2 ms_activity_dt = vc
 ) WITH protect
 FREE RECORD acog_data
 RECORD acog_data(
   1 acog[*]
     2 mf_encntr_id = f8
     2 ms_gravida = vc
     2 ms_parity = vc
     2 ms_eeddt1 = vc
     2 ms_eeddt2 = vc
     2 ms_ultrdt1 = vc
     2 ms_ultrdt2 = vc
     2 ms_lmp_dt = vc
 ) WITH protect
 FREE RECORD prentl_sum
 RECORD prentl_sum(
   1 patient[*]
     2 mf_person_id = f8
     2 ms_edd_dt = vc
     2 ms_edd_method = vc
     2 ms_prsn_full = vc
     2 mf_encntr_id = f8
     2 ms_account_no = vc
     2 mf_fac = f8
     2 ms_mrn = vc
     2 ms_dob = vc
     2 ms_lang = vc
     2 ms_gravida = vc
     2 ms_parity = vc
     2 ms_eeddt1 = vc
     2 ms_eeddt2 = vc
     2 ms_ultrdt1 = vc
     2 ms_ultrdt2 = vc
     2 ms_lmp_dt = vc
     2 allergies = vc
     2 lab_data[*]
       3 ms_lab_name = vc
       3 ms_lab_rslt = vc
       3 ms_lab_dt = vc
     2 problem_data[*]
       3 ms_problem_list = vc
     2 medication_data[*]
       3 ms_med_list = vc
     2 gar_par[*]
       3 ms_gravida = i2
       3 ms_parity = i2
       3 ms_abortion = i2
       3 ms_living = i2
       3 ms_fullterm = i2
       3 ms_parapreterm = i2
     2 visit_summary[*]
       3 ms_vdate = vc
       3 ms_gest_age = vc
       3 ms_fndal_hght = vc
       3 ms_presentation = vc
       3 ms_fhr = vc
       3 ms_cervical_exam = vc
       3 ms_systolic_bp = vc
       3 ms_diastolic_bp = vc
       3 ms_weight_kg = vc
       3 ms_edema = vc
     2 clin_sum[*]
       3 ms_clin_dt = vc
       3 ms_clin_note = vc
     2 fin_cnt[*]
       3 mn_tcnt = i2
 ) WITH protect
 CALL echo("Declare Variable Section")
 DECLARE ms_amb_cd = vc WITH protect, constant("AMBULATORY")
 DECLARE mf_wwcobgn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"WWCLINICOB"))
 DECLARE mf_wwcobgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"WWCLINICOB"))
 DECLARE mf_mfmobgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"MATFETALMED"))
 DECLARE mf_bwwobgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BAYSTWWGRPOBGYN"))
 DECLARE mf_pwhobgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"PIONWHBMC"))
 DECLARE mf_bmlwbgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"BMPMLOBGYNWARE"
   ))
 DECLARE mf_bwwgobgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"BAYSTWWGOBGYN"
   ))
 DECLARE mf_masnobgyn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BAYSTATEMASONSQ"))
 DECLARE ml_cd_set = i4 WITH protect, constant(220)
 DECLARE mf_acct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"VISITID"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cln_formsum_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "CLINICIANSUMMARY"))
 DECLARE mf_eeddt1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "ESTIMATEDDUEDATEBYULTRASOUND1"))
 DECLARE mf_eeddt2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "ESTIMATEDDUEDATEBYULTRASOUND2"))
 DECLARE mf_ultrdt1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "DATEOFULTRASOUND1"))
 DECLARE mf_ultrdt2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "DATEOFULTRASOUND2"))
 DECLARE mf_lmpdt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "LASTMENSTRUALPERIOD"))
 DECLARE mf_gasage_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "GESTATIONALAGEV001"))
 DECLARE mf_fundalhg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,"FUNDALHEIGHT"
   ))
 DECLARE mf_presentation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "FETALPRESENTATIONBABYA"))
 DECLARE mf_fhr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "FETALHEARTRATEBABYA"))
 DECLARE mf_cervdilation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "CERVICALDILATATION"))
 DECLARE mf_cerveffacent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "CERVICALEFFACEMENT"))
 DECLARE mf_cervstation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "FETALSTATION"))
 DECLARE mf_systolic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_diastolic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,"WEIGHT"))
 DECLARE mf_edema_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,"EDEMA"))
 DECLARE mf_edd_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "FINALESTIMATEDDUEDATE"))
 DECLARE mf_active_cycle_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12030,"ACTIVE"))
 DECLARE mf_active_allergy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"
   ))
 DECLARE ms_acog_form = vc WITH protect, constant("ACOG")
 DECLARE ms_daw_str = vc WITH protect, constant("DAW")
 DECLARE ms_freq_str = vc WITH protect, constant("FREQ")
 DECLARE ms_freetxtdose_str = vc WITH protect, constant("FREETXTDOSE")
 DECLARE ms_dose_str = vc WITH protect, constant("DOSE")
 DECLARE ms_doseunit_str = vc WITH protect, constant("DOSEUNIT")
 DECLARE ms_strengthdose_str = vc WITH protect, constant("STRENGTHDOSE")
 DECLARE ms_strengthdoseunit_str = vc WITH protect, constant("STRENGTHDOSEUNIT")
 DECLARE ms_volumedose_str = vc WITH protect, constant("VOLUMEDOSE")
 DECLARE ms_volumedoseunit_str = vc WITH protect, constant("VOLUMEDOSEUNIT")
 DECLARE ms_rxroute_str = vc WITH protect, constant("RXROUTE")
 DECLARE ms_order_cmt_str = vc WITH protect, constant("ORDER_COMMENT")
 DECLARE mn_ord_flag_0 = i2 WITH protect, constant(0)
 DECLARE mn_ord_flag_1 = i2 WITH protect, constant(1)
 DECLARE mn_ord_flag_2 = i2 WITH protect, constant(2)
 DECLARE mn_ord_flag_3 = i2 WITH protect, constant(3)
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_date_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DATE"))
 DECLARE mf_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"VOIDEDWITHRESULTS"
   ))
 DECLARE mf_del_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_incompl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE mf_incomplete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE")
  )
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDING"))
 DECLARE mf_pendingrev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDING REV"
   ))
 DECLARE mf_disch_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE"))
 DECLARE mf_req_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,
   "REQUESTORDERS"))
 DECLARE mf_careset_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,"CARESETS"))
 DECLARE mf_tlab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,"LABORATORY"))
 DECLARE mf_lab_req_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"LABOPREQUEST")
  )
 DECLARE mf_op_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"OPLABTOBEDONE")
  )
 DECLARE mf_pat_care_op_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCAREOP"))
 DECLARE mf_pharmacy_cattyp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PHARMACY"))
 DECLARE mf_lab_cattyp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY")
  )
 DECLARE mf_lab_inoff_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "LABINOFFICEOP"))
 DECLARE mf_micro_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MICROOP"))
 DECLARE mf_bb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE mf_genlab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE mf_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"LABORATORY"))
 DECLARE mf_snomed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"SNOMEDCT"))
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD9CM"))
 DECLARE mf_outpatient = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE mf_onetimeop = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE mf_officevisit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT"))
 DECLARE mf_preofficevisit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREOFFICEVISIT"))
 DECLARE mf_outpatientonetime = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE mf_gravida_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GRAVIDA"))
 DECLARE mf_parity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PARITY"))
 DECLARE mf_abortion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ABORTION"))
 DECLARE mf_living_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LIVINGCHILDREN"))
 DECLARE mf_fullterm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"FULLTERM"))
 DECLARE mf_parapreterm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREMATUREBIRTHS"))
 DECLARE mf_weight72_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_cln_sum_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CLINICIANSUMMARY"
   ))
 DECLARE mf_no_compression_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_ocf_compression_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_method_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!12676044"))
 DECLARE mf_lmp2_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!12676043"))
 DECLARE mf_powerforms_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",29520,"POWERFORMS"
   ))
 DECLARE ms_beg_doc = vc WITH constant(
  "{\rtf1\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 tahoma;}}\f0\fs20")
 DECLARE ms_beg_bold = vc WITH constant("\b ")
 DECLARE ms_end_bold = vc WITH constant("\b0 ")
 DECLARE ms_end_line = vc WITH constant("\par ")
 DECLARE ms_end_para = vc WITH constant("\pard ")
 DECLARE ms_end_doc = vc WITH constant("}")
 DECLARE ms_cerv_data = vc WITH protect, noconstant(" ")
 DECLARE ml_blob_size = i4 WITH protect, noconstant(0)
 DECLARE ml_rpt_prt = i4 WITH protect, noconstant(0)
 DECLARE ms_head_ind = vc WITH protect, noconstant("N")
 DECLARE ms_lmp_ind = vc WITH protect, noconstant("N")
 DECLARE ml_start_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_sub_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_continue = vc WITH protect, noconstant(" ")
 DECLARE ms_temp_plist = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_outputpmr = vc WITH protect, noconstant(" ")
 DECLARE ms_ms_msg1 = vc WITH protect, noconstant(" ")
 DECLARE ms_ms_msg2 = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE mn_success = i2 WITH protect, noconstant(0)
 DECLARE mn_tcnt = i2 WITH protect, noconstant(0)
 DECLARE ms_g = vc WITH protect, noconstant(" ")
 DECLARE ms_p = vc WITH protect, noconstant(" ")
 DECLARE ms_l = vc WITH protect, noconstant(" ")
 DECLARE ms_a = vc WITH protect, noconstant(" ")
 DECLARE ms_f = vc WITH protect, noconstant(" ")
 DECLARE ms_pt = vc WITH protect, noconstant(" ")
 DECLARE ms_grapar_line = vc WITH protect, noconstant(" ")
 DECLARE mf_hld_person = f8 WITH protect, noconstant(0.0)
 DECLARE ms_hpg = vc WITH protect, noconstant(" ")
 DECLARE ms_tpg = vc WITH protect, noconstant(" ")
 DECLARE mn_pgc = i2 WITH protect, noconstant(0)
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE md_start_date = dq8 WITH protect
 DECLARE md_end_date = dq8 WITH protect
 DECLARE md_end_dte_p30 = dq8 WITH protect
 DECLARE ps_blob_in = vc WITH private, noconstant(" ")
 DECLARE ps_blob_out = vc WITH private, noconstant(" ")
 DECLARE ps_blob_rtf = vc WITH private, noconstant(" ")
 DECLARE pl_blob_ret_len = i4 WITH private, noconstant(0)
 DECLARE pl_pat_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_e_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_f_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_acog_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_cl_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_h_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_vs_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_pcnt = i4 WITH private, noconstant(0)
 DECLARE pl_a_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_p_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_prob_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_med_cnt = i4 WITH private, noconstant(0)
 DECLARE pl_pt_cnt = i4 WITH private, noconstant(0)
 SET md_end_dt_tm = cnvtdatetime( $EDATE)
 SET md_end_dt_p30 = cnvtlookahead("30,D",cnvtdatetime(md_end_dt_tm))
 CALL echo(build("md_end_dt_p30= ",format(cnvtdate(md_end_dt_p30),";;d")))
 CALL echo("Validating User Input")
 IF (( $LSTPERSON <= ""))
  SELECT INTO  $MESSAGETOSCREEN
   FROM dummyt
   HEAD REPORT
    ms_msg1 = "You Have not Selected at least 1 patient Record.", ms_msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), ms_msg1,
    row + 2, ms_msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ENDIF
 SET md_start_date = cnvtdatetime(format(datetimefind(cnvtlookbehind("9M",cnvtdatetime(md_end_dt_tm)),
    "M","B","E"),";;Q"))
 CALL echo(build("md_start_date2",format(md_start_date,"MM/DD/YY HH:MM;;q")))
 IF (datetimediff(cnvtdatetime(md_end_dt_tm),cnvtdatetime(md_start_date)) > 305.0)
  CALL echo("Hitting 305 rule")
  SET ms_output =  $MESSAGETOSCREEN
  SELECT INTO  $MESSAGETOSCREEN
   FROM dummyt
   HEAD REPORT
    ms_msg1 = "The Start Date range extends beyond 305 days .", ms_msg2 =
    "  Please Enter a date within the 305 days.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), ms_msg1,
    row + 2, ms_msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $OUTDEV="MINE"))
  SET ms_output =  $MESSAGETOSCREEN
 ELSE
  CALL echo(build("Report sent to printer ", $OUTDEV))
  SET ms_output =  $OUTDEV
  SELECT INTO  $MESSAGETOSCREEN
   FROM dummyt
   HEAD REPORT
    msg1 = concat("Report sent to printer ", $OUTDEV), col 0, y_pos = 18,
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))),
    msg1, row + 1
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
 SET ms_temp_plist = trim( $LSTPERSON,3)
 SET ms_temp_plist = replace(ms_temp_plist,"VALUE","")
 SET ms_temp_plist = replace(ms_temp_plist,"(","")
 SET ms_temp_plist = replace(ms_temp_plist,")","")
 WHILE (ml_cnt1 < 100
  AND ml_cnt1 != 100)
   SET ml_cnt1 = (ml_cnt1+ 1)
   SET ms_tmp_str = trim(piece(ms_temp_plist,",",ml_cnt1,"1",0),3)
   IF (ms_tmp_str="1"
    AND ml_cnt1=1)
    SET stat = alterlist(requested_fac->pat_fac,ml_cnt1)
    SET requested_fac->pat_fac[ml_cnt1].mf_person_id = cnvtreal(trim(ms_temp_plist,3))
   ELSEIF (textlen(ms_tmp_str) > 1
    AND ((ms_tmp_str != "1") OR (ms_tmp_str="1"
    AND ml_cnt1=1)) )
    SET stat = alterlist(requested_fac->pat_fac,ml_cnt1)
    SET requested_fac->pat_fac[ml_cnt1].mf_person_id = cnvtreal(ms_tmp_str)
   ELSE
    SET ml_cnt1 = 101
   ENDIF
 ENDWHILE
 CALL echo("Getting Estimated Due Date part 1 data")
 SELECT DISTINCT INTO "nl:"
  pi.person_id
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   pregnancy_instance pi,
   pregnancy_estimate pe
  PLAN (d)
   JOIN (pi
   WHERE (pi.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND pi.active_ind=1
    AND pi.historical_ind=0)
   JOIN (pe
   WHERE pe.pregnancy_id=pi.pregnancy_id
    AND pe.est_delivery_dt_tm < cnvtdatetime(md_end_dt_p30)
    AND pe.active_ind=1
    AND pe.method_cd=outerjoin(mf_lmp2_cd))
  ORDER BY pi.person_id
  HEAD REPORT
   pl_pat_cnt = 0
  DETAIL
   pl_pat_cnt = (pl_pat_cnt+ 1), stat = alterlist(prentl_sum->patient,pl_pat_cnt)
   IF (pe.method_cd > 0)
    prentl_sum->patient[pl_pat_cnt].mf_person_id = pi.person_id, prentl_sum->patient[pl_pat_cnt].
    ms_edd_dt = format(pe.est_delivery_dt_tm,"MM/DD/YY;;q"), prentl_sum->patient[pl_pat_cnt].
    ms_edd_method = uar_get_code_display(pe.method_cd),
    prentl_sum->patient[pl_pat_cnt].ms_lmp_dt = format(pe.method_dt_tm,"MM/DD/YY;;d"), ms_lmp_ind =
    "Y"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Estimated Due Date part 2 data")
 SELECT DISTINCT INTO "nl:"
  pi.person_id
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   pregnancy_instance pi,
   pregnancy_estimate pe
  PLAN (d)
   JOIN (pi
   WHERE (pi.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND pi.active_ind=1
    AND pi.historical_ind=0)
   JOIN (pe
   WHERE pe.pregnancy_id=outerjoin(pi.pregnancy_id)
    AND pe.method_cd=outerjoin(mf_method_cd)
    AND pe.active_ind=outerjoin(1))
  ORDER BY pi.person_id
  HEAD REPORT
   pl_pcnt = 0
  DETAIL
   pl_pcnt = (pl_pcnt+ 1), stat = alterlist(prentl_sum->patient,pl_pcnt)
   IF (pe.method_cd > 0)
    prentl_sum->patient[pl_pcnt].mf_person_id = pi.person_id, prentl_sum->patient[pl_pcnt].ms_edd_dt
     = format(pe.est_delivery_dt_tm,"MM/DD/YY;;q"), prentl_sum->patient[pl_pcnt].ms_edd_method =
    uar_get_code_display(pe.method_cd)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("curqual= ",curqual))
 CALL echo("Getting Requested Faciltiy data")
 SELECT DISTINCT INTO "NL:"
  e.person_id
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   encounter e,
   encntr_alias ea,
   encntr_alias ea1,
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=requested_fac->pat_fac[d.seq].mf_person_id))
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_outpatient, mf_onetimeop, mf_officevisit, mf_preofficevisit,
   mf_outpatientonetime))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea1
   WHERE ea1.encntr_id=ea.encntr_id
    AND ea1.encntr_alias_type_cd=mf_mrn_cd)
  ORDER BY e.person_id
  HEAD REPORT
   stat = 0, pl_e_cnt = 0
  DETAIL
   pl_e_cnt = (pl_e_cnt+ 1), stat = alterlist(prentl_sum->patient,pl_e_cnt), prentl_sum->patient[
   pl_e_cnt].mf_person_id = e.person_id,
   prentl_sum->patient[pl_e_cnt].mf_encntr_id = e.encntr_id, prentl_sum->patient[pl_e_cnt].
   ms_account_no = ea.alias, prentl_sum->patient[pl_e_cnt].ms_prsn_full = p.name_full_formatted,
   prentl_sum->patient[pl_e_cnt].ms_dob = format(p.birth_dt_tm,"mm/dd/yy;;d"), prentl_sum->patient[
   pl_e_cnt].ms_mrn = ea1.alias, prentl_sum->patient[pl_e_cnt].ms_lang = uar_get_code_display(p
    .language_cd),
   prentl_sum->patient[pl_e_cnt].mf_fac = e.location_cd
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 CALL echo("Getting ACOG & Admission Assessment OB Forms")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   dcp_forms_activity dfa
  PLAN (d)
   JOIN (dfa
   WHERE (dfa.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND dfa.description IN (ms_acog_form)
    AND dfa.flags > 0
    AND dfa.form_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
  ORDER BY dfa.form_dt_tm, dfa.description DESC
  HEAD REPORT
   pl_f_cnt = 0
  DETAIL
   pl_f_cnt = (pl_f_cnt+ 1), stat = alterlist(work_form->forms,pl_f_cnt), work_form->forms[pl_f_cnt].
   mf_person_id = dfa.person_id,
   work_form->forms[pl_f_cnt].mf_encntr_id = dfa.encntr_id, work_form->forms[pl_f_cnt].
   mf_dcp_forms_actv_id = dfa.dcp_forms_activity_id, work_form->forms[pl_f_cnt].ms_dcp_desc = dfa
   .description,
   work_form->forms[pl_f_cnt].ms_reference_nbr = trim(build2(dfa.dcp_forms_activity_id,"*"),3),
   work_form->forms[pl_f_cnt].ms_activity_dt = format(dfa.form_dt_tm,"MM-DD-YYYY hh:mm:ss;;d")
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 CALL echo("Getting ACOG data")
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   (dummyt d1  WITH seq = size(prentl_sum->patient,5)),
   clinical_event ce
  PLAN (d)
   JOIN (d1
   WHERE (prentl_sum->patient[d1.seq].mf_person_id=requested_fac->pat_fac[d.seq].mf_person_id))
   JOIN (ce
   WHERE (ce.person_id=prentl_sum->patient[d1.seq].mf_person_id)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
  HEAD d.seq
   pl_acog_cnt = 0
  DETAIL
   pl_acog_cnt = (pl_acog_cnt+ 1), stat = alterlist(acog_data->acog,pl_acog_cnt)
   IF (ce.event_class_cd=mf_date_cd)
    ml_start_pos = (findstring(":",ce.result_val,1,0)+ 1), ml_end_pos = (findstring(":",ce.result_val,
     1,1) - 13), ms_temp_val = trim(substring(ml_start_pos,ml_end_pos,ce.result_val)),
    ms_temp_val2 = concat(substring(5,2,ms_temp_val),"/",substring(7,2,ms_temp_val),"/",substring(1,4,
      ms_temp_val))
   ENDIF
   acog_data->acog[pl_acog_cnt].mf_encntr_id = ce.encntr_id
   CASE (ce.task_assay_cd)
    OF mf_eeddt1_cd:
     prentl_sum->patient[d1.seq].ms_eeddt1 = ms_temp_val2
    OF mf_eeddt2_cd:
     prentl_sum->patient[d1.seq].ms_eeddt2 = ms_temp_val2
    OF mf_ultrdt1_cd:
     prentl_sum->patient[d1.seq].ms_ultrdt1 = ms_temp_val2
    OF mf_ultrdt2_cd:
     prentl_sum->patient[d1.seq].ms_ultrdt2 = ms_temp_val2
    OF mf_lmpdt_cd:
     IF (ms_lmp_ind != "Y")
      prentl_sum->patient[d1.seq].ms_lmp_dt = ms_temp_val2
     ELSE
      ms_lmp_ind = "N"
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo("Getting Allergy Data")
 SELECT DISTINCT INTO "nl:"
  n.source_string
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   allergy a,
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND a.reaction_status_cd=mf_active_allergy_cd
    AND a.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
  ORDER BY d.seq, n.source_string
  DETAIL
   IF (size(trim(prentl_sum->patient[d.seq].allergies,3)) > 0)
    prentl_sum->patient[d.seq].allergies = concat(trim(prentl_sum->patient[d.seq].allergies,3),", ",n
     .source_string)
   ELSE
    prentl_sum->patient[d.seq].allergies = trim(n.source_string,3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Lab data")
 SELECT DISTINCT INTO "nl:"
  o.catalog_cd
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   orders o,
   clinical_event ce
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(md_start_date) AND cnvtdatetime(md_end_dt_tm)
    AND o.catalog_type_cd IN (mf_lab_cattyp_cd)
    AND o.dcp_clin_cat_cd IN (mf_req_order_cd, mf_careset_cd, mf_tlab_cd)
    AND o.active_ind=1
    AND  NOT (o.order_status_cd IN (mf_del_cd, mf_void_cd, mf_incompl_cd, mf_canceled_cd,
   mf_discont_cd))
    AND o.discontinue_type_cd != mf_disch_discont_cd)
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND o.active_ind=1)
  ORDER BY d.seq, o.catalog_cd, ce.clinical_event_id
  HEAD d.seq
   null
  HEAD o.catalog_cd
   pl_p_cnt = 0
  HEAD ce.clinical_event_id
   pl_p_cnt = (pl_p_cnt+ 1), stat = alterlist(prentl_sum->patient[d.seq].lab_data,pl_p_cnt),
   prentl_sum->patient[d.seq].lab_data[pl_p_cnt].ms_lab_name = substring(1,80,trim(
     uar_get_code_display(o.catalog_cd))),
   prentl_sum->patient[d.seq].lab_data[pl_p_cnt].ms_lab_rslt = substring(1,80,trim(ce.result_val)),
   prentl_sum->patient[d.seq].lab_data[pl_p_cnt].ms_lab_dt = substring(1,80,trim(format(o
      .orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d")))
  WITH nocounter
 ;end select
 CALL echo("Getting Problems data")
 SELECT DISTINCT INTO "nl"
  p.problem_id
  FROM problem p,
   nomenclature n,
   (dummyt d  WITH seq = size(requested_fac->pat_fac,5))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
    AND p.active_ind=1
    AND p.life_cycle_status_cd=mf_active_cycle_cd)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_vocabulary_cd IN (mf_snomed_cd, mf_icd9_cd))
  ORDER BY d.seq, p.problem_id
  HEAD d.seq
   pl_prob_cnt = 0
  DETAIL
   pl_prob_cnt = (pl_prob_cnt+ 1), stat = alterlist(prentl_sum->patient[d.seq].problem_data,
    pl_prob_cnt)
   IF (p.nomenclature_id > 0)
    prentl_sum->patient[d.seq].problem_data[pl_prob_cnt].ms_problem_list = n.source_string, problem
     = n.source_string
   ELSE
    problem = p.problem_ftdesc, prentl_sum->patient[d.seq].problem_data[pl_prob_cnt].ms_problem_list
     = p.problem_ftdesc
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Getting Medication data")
 SELECT DISTINCT INTO "nl:"
  o.ordered_as_mnemonic
  FROM orders o,
   order_detail od,
   (dummyt d  WITH seq = size(requested_fac->pat_fac,5))
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND o.catalog_type_cd=mf_pharmacy_cattyp_cd
    AND o.order_status_cd IN (mf_incomplete_cd, mf_inprocess_cd, mf_ordered_cd, mf_pending_cd,
   mf_pendingrev_cd)
    AND o.template_order_flag IN (mn_ord_flag_0, mn_ord_flag_1)
    AND o.orig_ord_as_flag IN (mn_ord_flag_1, mn_ord_flag_2, mn_ord_flag_3))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning=ms_daw_str)
  ORDER BY d.seq, o.ordered_as_mnemonic
  HEAD d.seq
   pl_med_cnt = 0
  DETAIL
   pl_med_cnt = (pl_med_cnt+ 1), stat = alterlist(prentl_sum->patient[d.seq].medication_data,
    pl_med_cnt), prentl_sum->patient[d.seq].medication_data[pl_med_cnt].ms_med_list = o
   .ordered_as_mnemonic
  WITH nocounter
 ;end select
 CALL echo("Getting Gravida/Parity Data")
 SELECT DISTINCT INTO "nl:"
  ce.event_cd, format(ce.updt_dt_tm,"MM/DD/YY HH:MM;;d")
  FROM (dummyt d  WITH value(requested_fac->pat_fac,5)),
   (dummyt d1  WITH seq = size(prentl_sum->patient,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND ce.event_cd IN (mf_gravida_cd, mf_parity_cd, mf_fullterm_cd, mf_parapreterm_cd,
   mf_abortion_cd,
   mf_living_cd)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
   JOIN (d1
   WHERE (prentl_sum->patient[d1.seq].mf_person_id=ce.person_id))
  ORDER BY ce.event_cd, ce.clinical_event_id, ce.updt_dt_tm DESC
  HEAD ce.event_cd
   pl_pt_cnt = 0
  HEAD ce.clinical_event_id
   null
  HEAD ce.updt_dt_tm
   pl_pt_cnt = (pl_pt_cnt+ 1), stat = alterlist(prentl_sum->patient[d1.seq].gar_par,pl_pt_cnt)
   CASE (ce.event_cd)
    OF mf_gravida_cd:
     IF ( NOT (trim(ce.result_val) IN ("0", "", " ", null)))
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_gravida = cnvtint(trim(ce.result_val))
     ELSE
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_gravida = 0
     ENDIF
    OF mf_parity_cd:
     IF ( NOT (trim(ce.result_val) IN ("0", "", " ")))
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_parity = cnvtint(trim(ce.result_val))
     ELSE
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_parity = 0
     ENDIF
    OF mf_living_cd:
     IF ( NOT (trim(ce.result_val) IN ("0", "", " ")))
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_living = cnvtint(trim(ce.result_val))
     ELSE
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_living = 0
     ENDIF
    OF mf_abortion_cd:
     IF ( NOT (trim(ce.result_val) IN ("0", "", " ")))
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_abortion = cnvtint(trim(ce.result_val))
     ELSE
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_abortion = 0
     ENDIF
    OF mf_fullterm_cd:
     IF ( NOT (ce.result_val IN ("0", "", " ")))
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_fullterm = cnvtint(trim(ce.result_val))
     ELSE
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_fullterm = 0
     ENDIF
    OF mf_parapreterm_cd:
     IF ( NOT (ce.result_val IN ("0", "", " ")))
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_parapreterm = cnvtint(trim(ce.result_val))
     ELSE
      prentl_sum->patient[d1.seq].gar_par[pl_pt_cnt].ms_parapreterm = 0
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 CALL echorecord(prentl_sum)
 CALL echo("Getting Visit Summary Data")
 SELECT INTO "nl:"
  ce.event_end_dt_tm_os
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=requested_fac->pat_fac[d.seq].mf_person_id)
    AND ce.valid_from_dt_tm > cnvtdatetime(md_start_date)
    AND ce.task_assay_cd IN (mf_gasage_cd, mf_fundalhg_cd, mf_presentation_cd, mf_fhr_cd,
   mf_cervdilation_cd,
   mf_cerveffacent_cd, mf_cervstation_cd, mf_systolic_cd, mf_diastolic_cd, mf_weight_cd,
   mf_edema_cd)
    AND ce.task_assay_cd > 0.00
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
  ORDER BY d.seq, ce.clinical_event_id, ce.event_end_dt_tm_os
  HEAD d.seq
   pl_vs_cnt = 1, pl_h_cnt = 1, md_hold_dt = ce.event_end_dt_tm_os
  HEAD ce.clinical_event_id
   null
  HEAD ce.event_end_dt_tm_os
   stat = alterlist(prentl_sum->patient[d.seq].visit_summary,pl_vs_cnt)
   CASE (ce.task_assay_cd)
    OF mf_gasage_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_gest_age = trim(ce.result_val)
    OF mf_fundalhg_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_fndal_hght = trim(ce.result_val)
    OF mf_presentation_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_presentation = trim(ce.result_val)
    OF mf_fhr_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_fhr = trim(ce.result_val)
    OF mf_cervdilation_cd:
    OF mf_cerveffacent_cd:
    OF mf_cervstation_cd:
     ms_cerv_data = concat(ms_cerv_data,trim(ce.result_val)),prentl_sum->patient[d.seq].
     visit_summary[pl_h_cnt].ms_cervical_exam = ms_cerv_data
    OF mf_systolic_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_systolic_bp = trim(ce.result_val)
    OF mf_diastolic_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_diastolic_bp = trim(ce.result_val)
    OF mf_weight_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_weight_kg = trim(ce.result_val)
    OF mf_edema_cd:
     prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_edema = trim(ce.result_val)
   ENDCASE
   prentl_sum->patient[d.seq].visit_summary[pl_h_cnt].ms_vdate = format(ce.event_end_dt_tm,
    "MM/DD/YYYY;;d")
   IF (md_hold_dt != ce.event_end_dt_tm)
    md_hold_dt = ce.event_end_dt_tm, pl_vs_cnt = (pl_vs_cnt+ 1), pl_h_cnt = (pl_h_cnt+ 1)
   ENDIF
  WITH nocounter, maxcol = 1500
 ;end select
 CALL echorecord(prentl_sum)
 CALL echo("Getting Clinician Summary by Form Data")
 SELECT INTO "nl:"
  ce.event_end_dt_tm
  FROM (dummyt d  WITH seq = size(requested_fac->pat_fac,5)),
   (dummyt d1  WITH seq = value(size(work_form->forms,5))),
   clinical_event ce,
   ce_blob cb
  PLAN (d)
   JOIN (d1
   WHERE (work_form->forms[d1.seq].mf_person_id=requested_fac->pat_fac[d.seq].mf_person_id))
   JOIN (ce
   WHERE (ce.person_id=work_form->forms[d1.seq].mf_person_id)
    AND operator(ce.reference_nbr,"LIKE",patstring(work_form->forms[d1.seq].ms_reference_nbr,1))
    AND ce.task_assay_cd=mf_cln_formsum_cd
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
   JOIN (cb
   WHERE ce.event_id=cb.event_id
    AND cb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, ce.event_end_dt_tm DESC
  HEAD d.seq
   pl_cl_cnt = 0
  DETAIL
   pl_blob_size = cnvtint(cb.blob_length), ps_blob_in = fillstring(64000," "), ps_blob_out =
   fillstring(64000," "),
   ps_blob_rtf = fillstring(64000," "), pl_blob_ret_len = 0, ps_blob_in = cb.blob_contents
   IF (cb.compression_cd=mf_ocf_compression_cd)
    CALL uar_ocf_uncompress(ps_blob_in,pl_blob_size,ps_blob_out,64000,pl_blob_ret_len),
    CALL uar_rtf2(ps_blob_out,pl_blob_ret_len,ps_blob_rtf,64000,pl_blob_ret_len,1)
   ELSE
    CALL uar_rtf2(ps_blob_in,pl_blob_size,ps_blob_rtf,64000,pl_blob_ret_len,1)
   ENDIF
   pl_cl_cnt = (pl_cl_cnt+ 1), stat = alterlist(prentl_sum->patient[d.seq].clin_sum,pl_cl_cnt),
   prentl_sum->patient[d.seq].clin_sum[pl_cl_cnt].ms_clin_dt = format(ce.performed_dt_tm,
    "MM/DD/YY;;d"),
   prentl_sum->patient[d.seq].clin_sum[pl_cl_cnt].ms_clin_note = replace(trim(ps_blob_rtf,3)," \par ",
    char(12),0)
  WITH nocounter
 ;end select
 CALL echorecord(prentl_sum)
 CALL echo("Getting Clinician Summary  by Event Data")
 SELECT INTO "nl:"
  ce.event_end_dt_tm
  FROM (dummyt d  WITH seq = size(prentl_sum->patient,5)),
   clinical_event ce2
  PLAN (d)
   JOIN (ce2
   WHERE (ce2.person_id=prentl_sum->patient[d.seq].mf_person_id)
    AND ce2.event_cd=mf_cln_sum_cd
    AND ce2.entry_mode_cd != mf_powerforms_cd
    AND ce2.view_level=1
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce2.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
  ORDER BY d.seq, ce2.event_end_dt_tm DESC
  HEAD d.seq
   pl_cl_cnt = size(prentl_sum->patient[d.seq].clin_sum,5),
   CALL echo(pl_cl_cnt)
  DETAIL
   pl_cl_cnt = (pl_cl_cnt+ 1), stat = alterlist(prentl_sum->patient[d.seq].clin_sum,pl_cl_cnt)
   IF ( NOT (ce2.result_val IN ("", " ", null)))
    prentl_sum->patient[d.seq].clin_sum[pl_cl_cnt].ms_clin_dt = format(ce2.performed_dt_tm,
     "MM/DD/YY;;d"), prentl_sum->patient[d.seq].clin_sum[pl_cl_cnt].ms_clin_note = trim(ce2
     .result_val)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(prentl_sum)
 CALL echo("Calculating Page & Total Count Section")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE report_header(ncalc=i2) = f8 WITH protect
 DECLARE report_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_demographic(ncalc=i2) = f8 WITH protect
 DECLARE patient_demographicabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_demographic2(ncalc=i2) = f8 WITH protect
 DECLARE patient_demographic2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE allergy_list(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE allergy_listabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE labheader(ncalc=i2) = f8 WITH protect
 DECLARE labheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE lab_results(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE lab_resultsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE problemheader(ncalc=i2) = f8 WITH protect
 DECLARE problemheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE problem_list(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE problem_listabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE medicationheader(ncalc=i2) = f8 WITH protect
 DECLARE medicationheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE medication_list(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medication_listabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE visitsumheader(ncalc=i2) = f8 WITH protect
 DECLARE visitsumheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE visit_summary(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE visit_summaryabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE clinicalheader(ncalc=i2) = f8 WITH protect
 DECLARE clinicalheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE clinician_summary(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE clinician_summaryabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE subfooter(ncalc=i2) = f8 WITH protect
 DECLARE subfooterabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE foot_report_section(ncalc=i2) = f8 WITH protect
 DECLARE foot_report_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remallergies = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontallergy_list = i2 WITH noconstant(0), protect
 DECLARE _bcontlab_results = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow = i2 WITH noconstant(0), protect
 DECLARE _remname = i4 WITH noconstant(1), protect
 DECLARE _remresults = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remproblems = i4 WITH noconstant(1), protect
 DECLARE _bcontproblem_list = i2 WITH noconstant(0), protect
 DECLARE _remmedication = i4 WITH noconstant(1), protect
 DECLARE _bcontmedication_list = i2 WITH noconstant(0), protect
 DECLARE _bcontvisit_summary = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow1 = i2 WITH noconstant(0), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remgesage = i4 WITH noconstant(1), protect
 DECLARE _remfundalhght = i4 WITH noconstant(1), protect
 DECLARE _rempresetation = i4 WITH noconstant(1), protect
 DECLARE _remfhr = i4 WITH noconstant(1), protect
 DECLARE _remcervexam = i4 WITH noconstant(1), protect
 DECLARE _remsystolicbp = i4 WITH noconstant(1), protect
 DECLARE _remdiastolicbp = i4 WITH noconstant(1), protect
 DECLARE _remweight = i4 WITH noconstant(1), protect
 DECLARE _remedema = i4 WITH noconstant(1), protect
 DECLARE _bcontclinician_summary = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow2 = i2 WITH noconstant(0), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remms_clin_note = i4 WITH noconstant(1), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times20b0 = i4 WITH noconstant(0), protect
 DECLARE _pen50s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 DECLARE ssn_var = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN")), protect
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN")), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:prenatal_sum_header_img.jpg")
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE report_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE report_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.570000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 5.333
    SET rptsd->m_height = 0.438
    SET _oldfont = uar_rptsetfont(_hreport,_times20b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prenatal Summary",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 2.875)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed On:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 3.563)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen50s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.463),(offsetx+ 7.313),(offsety+
     1.463))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 6.438)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_continue,char(0)))
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 1.125),(offsety+ 0.000),5.208,
     0.813,1)
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curtime,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("@",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_demographic(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_demographicabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_demographicabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.060000), private
   DECLARE __mrn_nbr = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_mrn,char(0))),
   protect
   DECLARE __patientfullname = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_prsn_full,
     char(0))), protect
   DECLARE __patdob = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_dob,char(0))),
   protect
   DECLARE __languagespoken = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_lang,char(0
      ))), protect
   DECLARE __lmpdate = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_lmp_dt,char(0))),
   protect
   DECLARE __eddfinal = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_edd_dt,char(0))),
   protect
   DECLARE __method1 = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_edd_method,char(0)
     )), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Gravida/Parity:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.375
    SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.438)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn_nbr)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientfullname)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patdob)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 6.188
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_grapar_line,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Language Spoken:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LMP:",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EDD:",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Method:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__languagespoken)
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lmpdate)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__eddfinal)
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__method1)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_demographic2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_demographic2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_demographic2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE __patientfullname12 = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].
     ms_prsn_full,char(0))), protect
   DECLARE __mrn_nbr11 = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_mrn,char(0))),
   protect
   DECLARE __patdob = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].ms_dob,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientfullname12)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.188)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn_nbr11)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patdob)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE allergy_list(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergy_listabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergy_listabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_allergies = f8 WITH noconstant(0.0), private
   IF ((prentl_sum->patient[ml_pd_prt].allergies != ""))
    DECLARE __allergies = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].allergies,char(0))
     ), protect
   ENDIF
   IF (bcontinue=0)
    SET _remallergies = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.625)
   SET rptsd->m_width = 5.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF ((prentl_sum->patient[ml_pd_prt].allergies != ""))
    SET _holdremallergies = _remallergies
    IF (_remallergies > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallergies,((size(
         __allergies) - _remallergies)+ 1),__allergies)))
     SET drawheight_allergies = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remallergies = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallergies,((size(__allergies) -
        _remallergies)+ 1),__allergies)))))
      SET _remallergies = (_remallergies+ rptsd->m_drawlength)
     ELSE
      SET _remallergies = 0
     ENDIF
     SET growsum = (growsum+ _remallergies)
    ENDIF
   ELSE
    SET _remallergies = 0
    SET _holdremallergies = _remallergies
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.063)
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medication Allergies:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.625)
   SET rptsd->m_width = 5.688
   SET rptsd->m_height = drawheight_allergies
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND _holdremallergies > 0)
    IF ((prentl_sum->patient[ml_pd_prt].allergies != ""))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallergies,((size(
         __allergies) - _holdremallergies)+ 1),__allergies)))
    ENDIF
   ELSE
    SET _remallergies = _holdremallergies
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE labheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prenatal Labs:",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Result",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 5.813)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE lab_results(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = lab_resultsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __name = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].lab_data[ml_lab_prt].
     ms_lab_name,char(0))), protect
   DECLARE __results = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].lab_data[ml_lab_prt].
     ms_lab_rslt,char(0))), protect
   DECLARE __date = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].lab_data[ml_lab_prt].
     ms_lab_dt,char(0))), protect
   IF (bcontinue=0)
    SET _remname = 1
    SET _remresults = 1
    SET _remdate = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.132)
   SET rptsd->m_width = 2.514
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremname = _remname
   IF (_remname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remname,((size(__name) -
       _remname)+ 1),__name)))
    SET drawheight_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remname,((size(__name) - _remname)+ 1),
       __name)))))
     SET _remname = (_remname+ rptsd->m_drawlength)
    ELSE
     SET _remname = 0
    ENDIF
    SET growsum = (growsum+ _remname)
   ENDIF
   SET rptsd->m_flags = 549
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.653)
   SET rptsd->m_width = 3.035
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremresults = _remresults
   IF (_remresults > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remresults,((size(
        __results) - _remresults)+ 1),__results)))
    SET drawheight_results = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remresults = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remresults,((size(__results) -
       _remresults)+ 1),__results)))))
     SET _remresults = (_remresults+ rptsd->m_drawlength)
    ELSE
     SET _remresults = 0
    ENDIF
    SET growsum = (growsum+ _remresults)
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.695)
   SET rptsd->m_width = 1.680
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate = (_remdate+ rptsd->m_drawlength)
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum = (growsum+ _remdate)
   ENDIF
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.132)
   SET rptsd->m_width = 2.514
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremname > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremname,((size(
         __name) - _holdremname)+ 1),__name)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remname = _holdremname
   ENDIF
   SET rptsd->m_flags = 548
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.653)
   SET rptsd->m_width = 3.035
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremresults > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremresults,((size(
         __results) - _holdremresults)+ 1),__results)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remresults = _holdremresults
   ENDIF
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.695)
   SET rptsd->m_width = 1.680
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(
         __date) - _holdremdate)+ 1),__date)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.125),offsety,(offsetx+ 0.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.646),offsety,(offsetx+ 2.646),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.688),offsety,(offsetx+ 5.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.375),offsety,(offsetx+ 7.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.125),(offsety+ 0.000),(offsetx+ 7.375),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.125),(offsety+ sectionheight),(offsetx+ 7.375),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE lab_resultsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow(rpt_calcheight,maxheight_tablerow,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow(rpt_render,maxheight_tablerow,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE problemheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = problemheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE problemheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.360000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.115)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Problem List (Active):",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE problem_list(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = problem_listabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE problem_listabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_problems = f8 WITH noconstant(0.0), private
   DECLARE __problems = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].problem_data[
     ml_prob_prt].ms_problem_list,char(0))), protect
   IF (bcontinue=0)
    SET _remproblems = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremproblems = _remproblems
   IF (_remproblems > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remproblems,((size(
        __problems) - _remproblems)+ 1),__problems)))
    SET drawheight_problems = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remproblems = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remproblems,((size(__problems) -
       _remproblems)+ 1),__problems)))))
     SET _remproblems = (_remproblems+ rptsd->m_drawlength)
    ELSE
     SET _remproblems = 0
    ENDIF
    SET growsum = (growsum+ _remproblems)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = drawheight_problems
   IF (ncalc=rpt_render
    AND _holdremproblems > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremproblems,((size(
        __problems) - _holdremproblems)+ 1),__problems)))
   ELSE
    SET _remproblems = _holdremproblems
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medicationheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medicationheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medicationheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 292
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medications:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medication_list(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medication_listabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medication_listabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_medication = f8 WITH noconstant(0.0), private
   DECLARE __medication = vc WITH noconstant(build2(prentl_sum->patient[ml_pd_prt].medication_data[
     ml_med_prt].ms_med_list,char(0))), protect
   IF (bcontinue=0)
    SET _remmedication = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.313)
   SET rptsd->m_width = 4.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmedication = _remmedication
   IF (_remmedication > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedication,((size(
        __medication) - _remmedication)+ 1),__medication)))
    SET drawheight_medication = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedication = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedication,((size(__medication) -
       _remmedication)+ 1),__medication)))))
     SET _remmedication = (_remmedication+ rptsd->m_drawlength)
    ELSE
     SET _remmedication = 0
    ENDIF
    SET growsum = (growsum+ _remmedication)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.313)
   SET rptsd->m_width = 4.625
   SET rptsd->m_height = drawheight_medication
   IF (ncalc=rpt_render
    AND _holdremmedication > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedication,((size(
        __medication) - _holdremmedication)+ 1),__medication)))
   ELSE
    SET _remmedication = _holdremmedication
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE visitsumheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = visitsumheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE visitsumheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Visit Summary:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FHR",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Gestational Age",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("    Fundal   Height",char(0)))
    SET rptsd->m_flags = 276
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Presentation",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cervical Exam",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Systolic BP",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diastolic BP",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Edema",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE visit_summary(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = visit_summaryabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __date = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[ml_vs_prt].
     ms_vdate,char(0))), protect
   DECLARE __gesage = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[ml_vs_prt
     ].ms_gest_age,char(0))), protect
   DECLARE __fundalhght = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[
     ml_vs_prt].ms_fndal_hght,char(0))), protect
   DECLARE __presetation = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[
     ml_vs_prt].ms_presentation,char(0))), protect
   DECLARE __fhr = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[ml_vs_prt].
     ms_fhr,char(0))), protect
   DECLARE __cervexam = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[
     ml_vs_prt].ms_cervical_exam,char(0))), protect
   DECLARE __systolicbp = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[
     ml_vs_prt].ms_systolic_bp,char(0))), protect
   DECLARE __diastolicbp = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[
     ml_vs_prt].ms_diastolic_bp,char(0))), protect
   DECLARE __weight = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[ml_vs_prt
     ].ms_weight_kg,char(0))), protect
   DECLARE __edema = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].visit_summary[ml_vs_prt]
     .ms_edema,char(0))), protect
   IF (bcontinue=0)
    SET _remdate = 1
    SET _remgesage = 1
    SET _remfundalhght = 1
    SET _rempresetation = 1
    SET _remfhr = 1
    SET _remcervexam = 1
    SET _remsystolicbp = 1
    SET _remdiastolicbp = 1
    SET _remweight = 1
    SET _remedema = 1
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.816
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate = (_remdate+ rptsd->m_drawlength)
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum = (growsum+ _remdate)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.830)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremgesage = _remgesage
   IF (_remgesage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remgesage,((size(__gesage
        ) - _remgesage)+ 1),__gesage)))
    SET drawheight_gesage = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remgesage = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remgesage,((size(__gesage) - _remgesage)
       + 1),__gesage)))))
     SET _remgesage = (_remgesage+ rptsd->m_drawlength)
    ELSE
     SET _remgesage = 0
    ENDIF
    SET growsum = (growsum+ _remgesage)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.559)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfundalhght = _remfundalhght
   IF (_remfundalhght > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfundalhght,((size(
        __fundalhght) - _remfundalhght)+ 1),__fundalhght)))
    SET drawheight_fundalhght = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfundalhght = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfundalhght,((size(__fundalhght) -
       _remfundalhght)+ 1),__fundalhght)))))
     SET _remfundalhght = (_remfundalhght+ rptsd->m_drawlength)
    ELSE
     SET _remfundalhght = 0
    ENDIF
    SET growsum = (growsum+ _remfundalhght)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.288)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempresetation = _rempresetation
   IF (_rempresetation > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempresetation,((size(
        __presetation) - _rempresetation)+ 1),__presetation)))
    SET drawheight_presetation = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempresetation = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempresetation,((size(__presetation) -
       _rempresetation)+ 1),__presetation)))))
     SET _rempresetation = (_rempresetation+ rptsd->m_drawlength)
    ELSE
     SET _rempresetation = 0
    ENDIF
    SET growsum = (growsum+ _rempresetation)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.017)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfhr = _remfhr
   IF (_remfhr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfhr,((size(__fhr) -
       _remfhr)+ 1),__fhr)))
    SET drawheight_fhr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfhr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfhr,((size(__fhr) - _remfhr)+ 1),__fhr
       )))))
     SET _remfhr = (_remfhr+ rptsd->m_drawlength)
    ELSE
     SET _remfhr = 0
    ENDIF
    SET growsum = (growsum+ _remfhr)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcervexam = _remcervexam
   IF (_remcervexam > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcervexam,((size(
        __cervexam) - _remcervexam)+ 1),__cervexam)))
    SET drawheight_cervexam = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcervexam = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcervexam,((size(__cervexam) -
       _remcervexam)+ 1),__cervexam)))))
     SET _remcervexam = (_remcervexam+ rptsd->m_drawlength)
    ELSE
     SET _remcervexam = 0
    ENDIF
    SET growsum = (growsum+ _remcervexam)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.476)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremsystolicbp = _remsystolicbp
   IF (_remsystolicbp > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsystolicbp,((size(
        __systolicbp) - _remsystolicbp)+ 1),__systolicbp)))
    SET drawheight_systolicbp = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsystolicbp = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsystolicbp,((size(__systolicbp) -
       _remsystolicbp)+ 1),__systolicbp)))))
     SET _remsystolicbp = (_remsystolicbp+ rptsd->m_drawlength)
    ELSE
     SET _remsystolicbp = 0
    ENDIF
    SET growsum = (growsum+ _remsystolicbp)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.205)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdiastolicbp = _remdiastolicbp
   IF (_remdiastolicbp > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdiastolicbp,((size(
        __diastolicbp) - _remdiastolicbp)+ 1),__diastolicbp)))
    SET drawheight_diastolicbp = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdiastolicbp = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdiastolicbp,((size(__diastolicbp) -
       _remdiastolicbp)+ 1),__diastolicbp)))))
     SET _remdiastolicbp = (_remdiastolicbp+ rptsd->m_drawlength)
    ELSE
     SET _remdiastolicbp = 0
    ENDIF
    SET growsum = (growsum+ _remdiastolicbp)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.934)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremweight = _remweight
   IF (_remweight > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweight,((size(__weight
        ) - _remweight)+ 1),__weight)))
    SET drawheight_weight = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweight = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweight,((size(__weight) - _remweight)
       + 1),__weight)))))
     SET _remweight = (_remweight+ rptsd->m_drawlength)
    ELSE
     SET _remweight = 0
    ENDIF
    SET growsum = (growsum+ _remweight)
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.663)
   SET rptsd->m_width = 0.712
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremedema = _remedema
   IF (_remedema > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remedema,((size(__edema)
        - _remedema)+ 1),__edema)))
    SET drawheight_edema = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remedema = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remedema,((size(__edema) - _remedema)+ 1),
       __edema)))))
     SET _remedema = (_remedema+ rptsd->m_drawlength)
    ELSE
     SET _remedema = 0
    ENDIF
    SET growsum = (growsum+ _remedema)
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.816
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(
         __date) - _holdremdate)+ 1),__date)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.830)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremgesage > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremgesage,((size(
         __gesage) - _holdremgesage)+ 1),__gesage)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remgesage = _holdremgesage
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.559)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremfundalhght > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfundalhght,((size
        (__fundalhght) - _holdremfundalhght)+ 1),__fundalhght)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remfundalhght = _holdremfundalhght
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.288)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdrempresetation > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempresetation,((
        size(__presetation) - _holdrempresetation)+ 1),__presetation)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _rempresetation = _holdrempresetation
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.017)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremfhr > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfhr,((size(__fhr)
         - _holdremfhr)+ 1),__fhr)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remfhr = _holdremfhr
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremcervexam > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcervexam,((size(
         __cervexam) - _holdremcervexam)+ 1),__cervexam)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcervexam = _holdremcervexam
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.476)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremsystolicbp > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsystolicbp,((size
        (__systolicbp) - _holdremsystolicbp)+ 1),__systolicbp)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remsystolicbp = _holdremsystolicbp
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.205)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremdiastolicbp > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdiastolicbp,((
        size(__diastolicbp) - _holdremdiastolicbp)+ 1),__diastolicbp)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdiastolicbp = _holdremdiastolicbp
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.934)
   SET rptsd->m_width = 0.722
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremweight > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweight,((size(
         __weight) - _holdremweight)+ 1),__weight)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remweight = _holdremweight
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.663)
   SET rptsd->m_width = 0.712
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremedema > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremedema,((size(
         __edema) - _holdremedema)+ 1),__edema)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remedema = _holdremedema
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.823),offsety,(offsetx+ 0.823),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.552),offsety,(offsetx+ 1.552),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.281),offsety,(offsetx+ 2.281),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.010),offsety,(offsetx+ 3.010),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.469),offsety,(offsetx+ 4.469),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.198),offsety,(offsetx+ 5.198),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.927),offsety,(offsetx+ 5.927),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.656),offsety,(offsetx+ 6.656),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.375),offsety,(offsetx+ 7.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.375),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.375),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE visit_summaryabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow1 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow1(rpt_calcheight,maxheight_tablerow1,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow1)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow1 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow1(rpt_render,maxheight_tablerow1,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE clinicalheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = clinicalheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE clinicalheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.650000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Clinical Summary:",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.333)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET rptsd->m_y = (offsety+ 0.333)
    SET rptsd->m_x = (offsetx+ 3.063)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Clinical Note",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE clinician_summary(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = clinician_summaryabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __date = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].clin_sum[ml_cs_prt].
     ms_clin_dt,char(0))), protect
   DECLARE __ms_clin_note = vc WITH noconstant(build(prentl_sum->patient[ml_pd_prt].clin_sum[
     ml_cs_prt].ms_clin_note,char(0))), protect
   IF (bcontinue=0)
    SET _remdate = 1
    SET _remms_clin_note = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.805
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate = (_remdate+ rptsd->m_drawlength)
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum = (growsum+ _remdate)
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.819)
   SET rptsd->m_width = 6.556
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremms_clin_note = _remms_clin_note
   IF (_remms_clin_note > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remms_clin_note,((size(
        __ms_clin_note) - _remms_clin_note)+ 1),__ms_clin_note)))
    SET drawheight_ms_clin_note = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remms_clin_note = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remms_clin_note,((size(__ms_clin_note) -
       _remms_clin_note)+ 1),__ms_clin_note)))))
     SET _remms_clin_note = (_remms_clin_note+ rptsd->m_drawlength)
    ELSE
     SET _remms_clin_note = 0
    ENDIF
    SET growsum = (growsum+ _remms_clin_note)
   ENDIF
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 0.805
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(
         __date) - _holdremdate)+ 1),__date)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 36
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.819)
   SET rptsd->m_width = 6.556
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render)
    IF (_holdremms_clin_note > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremms_clin_note,((
        size(__ms_clin_note) - _holdremms_clin_note)+ 1),__ms_clin_note)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remms_clin_note = _holdremms_clin_note
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.812),offsety,(offsetx+ 0.812),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.375),offsety,(offsetx+ 7.375),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.375),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.375),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE clinician_summaryabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow2 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow2(rpt_calcheight,maxheight_tablerow2,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow2)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow2 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow2(rpt_render,maxheight_tablerow2,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE subfooter(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = subfooterabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE subfooterabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_hpg,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE foot_report_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = foot_report_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE foot_report_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.406
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("End of Report",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_tpg,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_PRENATAL_SUMMARY"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _stat = _loadimages(0)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 52
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 20
   SET rptfont->m_bold = rpt_on
   SET _times20b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_off
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.050
   SET _pen50s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET page_size = 10.25
 SET becont = 0
 SET mn_tcnt = 0
 SET ml_size = value(size(prentl_sum->patient,5))
 SET ms_garpar = 1
 FOR (ms_gar_par = 1 TO ms_garpar)
   SET ms_g = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_gravida))
   SET ms_p = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_parity))
   SET ms_l = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_living))
   SET ms_a = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_abortion))
   SET ms_f = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_fullterm))
   SET ms_pt = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_parapreterm))
 ENDFOR
 SET ms_grapar_line = concat("G",ms_g,",","P",ms_p,
  "(",ms_l,",",ms_pt,",",
  ms_a,",",ms_l,")")
 FOR (ml_pd_prt = 1 TO ml_size)
   IF (ml_pd_prt=1)
    SET mn_tcnt = (mn_tcnt+ 1)
    SET d0 = report_header(rpt_render)
    SET d0 = patient_demographic(rpt_render)
    SET remain_space = (page_size - _yoffset)
   ELSE
    SET d0 = foot_report_section(rpt_render)
    SET d0 = pagebreak(0)
    SET mn_tcnt = (mn_tcnt+ 1)
    SET d0 = report_header(rpt_render)
    IF (mn_tcnt > 1)
     SET d0 = patient_demographic2(rpt_render)
    ENDIF
    SET remain_space = (page_size - _yoffset)
    SET becont = 0
   ENDIF
   IF ((((_yoffset+ allergy_list(rpt_calcheight,remain_space,becont))+ foot_report_section(
    rpt_calcheight)) > page_size))
    SET _yoffset = page_size
    SET d0 = subfooter(rpt_render)
    SET d0 = foot_report_section(rpt_render)
    SET d0 = pagebreak(0)
    SET mn_tcnt = (mn_tcnt+ 1)
    SET d0 = report_header(rpt_render)
    IF (mn_tcnt > 1)
     SET d0 = patient_demographic2(rpt_render)
    ENDIF
    SET ms_continue = "(Continued)"
   ENDIF
   WHILE (becont=1)
     SET _yoffset = page_size
     SET d0 = subfooter(rpt_render)
     SET d0 = foot_report_section(rpt_render)
     SET d0 = pagebreak(0)
     SET mn_tcnt = (mn_tcnt+ 1)
     SET ms_continue = "(Continued)"
     SET d0 = report_header(rpt_render)
     IF (mn_tcnt > 1)
      SET d0 = patient_demographic2(rpt_render)
     ENDIF
     SET ms_continue = ""
     SET remain_space = (page_size - _yoffset)
     SET becont = 0
   ENDWHILE
   SET remain_space = (page_size - _yoffset)
   SET d0 = allergy_list(rpt_render,remain_space,becont)
   SET ms_head_ind = "N"
   FOR (ml_lab_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].lab_data,5))
     IF ((((_yoffset+ lab_results(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET d0 = pagebreak(0)
      SET mn_tcnt = (mn_tcnt+ 1)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_tcnt > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = labheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = labheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET d0 = pagebreak(0)
       SET mn_tcnt = (mn_tcnt+ 1)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_tcnt > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = lab_results(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_prob_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].problem_data,5))
     IF ((((_yoffset+ problem_list(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET d0 = pagebreak(0)
      SET mn_tcnt = (mn_tcnt+ 1)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_tcnt > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = problemheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = problemheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET d0 = pagebreak(0)
       SET mn_tcnt = (mn_tcnt+ 1)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_tcnt > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = problem_list(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_med_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].medication_data,5))
     IF ((((_yoffset+ medication_list(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET d0 = pagebreak(0)
      SET mn_tcnt = (mn_tcnt+ 1)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_tcnt > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = medicationheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = medicationheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET d0 = pagebreak(0)
       SET mn_tcnt = (mn_tcnt+ 1)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_tcnt > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = medication_list(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_vs_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].visit_summary,5))
     IF ((((_yoffset+ visit_summary(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET d0 = pagebreak(0)
      SET mn_tcnt = (mn_tcnt+ 1)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_tcnt > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = visitsumheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = visitsumheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET d0 = pagebreak(0)
       SET mn_tcnt = (mn_tcnt+ 1)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_tcnt > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = visit_summary(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_cs_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].clin_sum,5))
     IF ((((_yoffset+ clinician_summary(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET d0 = pagebreak(0)
      SET mn_tcnt = (mn_tcnt+ 1)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_tcnt > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = clinicalheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = clinicalheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET d0 = pagebreak(0)
       SET mn_tcnt = (mn_tcnt+ 1)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_tcnt > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = clinician_summary(rpt_render,remain_space,becont)
   ENDFOR
   IF (ml_pd_prt=ml_size)
    SET mf_hld_person = 0
   ENDIF
   IF ((mf_hld_person != prentl_sum->patient[ml_pd_prt].mf_person_id))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH value(size(prentl_sum->patient,5))),
      (dummyt d1  WITH seq = size(prentl_sum->patient,5))
     PLAN (d)
      JOIN (d1
      WHERE (prentl_sum->patient[d1.seq].mf_person_id=prentl_sum->patient[ml_pd_prt].mf_person_id))
     ORDER BY d1.seq
     HEAD d1.seq
      ml_t_cnt = 1
     DETAIL
      d1.seq, stat = alterlist(prentl_sum->patient[d1.seq].fin_cnt,ml_t_cnt), prentl_sum->patient[d1
      .seq].fin_cnt[ml_t_cnt].mn_tcnt = mn_tcnt,
      mf_hld_person = prentl_sum->patient[ml_pd_prt].mf_person_id, mn_tcnt = 0
     WITH nocounter
    ;end select
    CALL echorecord(prentl_sum)
   ENDIF
 ENDFOR
 SET d0 = foot_report_section(rpt_calcheight)
 SET d0 = finalizereport(ms_output)
 CALL echo("Print Report Section")
 SET d0 = initializereport(0)
 SET page_size = 10.25
 SET becont = 0
 SET mn_pgc = 0
 SET ml_size = value(size(prentl_sum->patient,5))
 SET ms_garpar = value(size(prentl_sum->patient.gar_par,5))
 SET ml_size = value(size(prentl_sum->patient,5))
 SET ms_garpar = 1
 FOR (ms_gar_par = 1 TO ms_garpar)
   SET ms_g = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_gravida))
   SET ms_p = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_parity))
   SET ms_l = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_living))
   SET ms_a = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_abortion))
   SET ms_f = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_fullterm))
   SET ms_pt = trim(cnvtstring(prentl_sum->patient.gar_par[ms_garpar].ms_parapreterm))
 ENDFOR
 SET ms_grapar_line = concat("G",ms_g,",","P",ms_p,
  "(",ms_f,",",ms_pt,",",
  ms_a,",",ms_l,")")
 FOR (ml_pd_prt = 1 TO ml_size)
   IF (ml_pd_prt=1)
    SET mn_pgc = (mn_pgc+ 1)
    SET d0 = report_header(rpt_render)
    SET d0 = patient_demographic(rpt_render)
    SET remain_space = (page_size - _yoffset)
   ELSE
    SET d0 = foot_report_section(rpt_render)
    SET d0 = pagebreak(0)
    SET mn_tcnt = (mn_tcnt+ 1)
    SET d0 = report_header(rpt_render)
    SET d0 = patient_demographic(rpt_render)
    SET remain_space = (page_size - _yoffset)
    SET becont = 0
   ENDIF
   IF ((((_yoffset+ allergy_list(rpt_calcheight,remain_space,becont))+ foot_report_section(
    rpt_calcheight)) > page_size))
    SET _yoffset = page_size
    SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
        patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
    SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
        ml_pd_prt].fin_cnt[1].mn_tcnt))))
    SET d0 = subfooter(rpt_render)
    SET d0 = foot_report_section(rpt_render)
    SET d0 = pagebreak(0)
    SET mn_pgc = (mn_pgc+ 1)
    SET d0 = report_header(rpt_render)
    IF (mn_pgc > 1)
     SET d0 = patient_demographic2(rpt_render)
    ENDIF
    SET ms_continue = "(Continued)"
   ENDIF
   WHILE (becont=1)
     SET _yoffset = page_size
     SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
         patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
     SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
         ml_pd_prt].fin_cnt[1].mn_tcnt))))
     SET d0 = subfooter(rpt_render)
     SET d0 = foot_report_section(rpt_render)
     SET mn_pgc = (mn_pgc+ 1)
     SET d0 = pagebreak(0)
     SET ms_continue = "(Continued)"
     SET d0 = report_header(rpt_render)
     IF (mn_pgc > 1)
      SET d0 = patient_demographic2(rpt_render)
     ENDIF
     SET ms_continue = ""
     SET remain_space = (page_size - _yoffset)
     SET becont = 0
   ENDWHILE
   SET remain_space = (page_size - _yoffset)
   SET d0 = allergy_list(rpt_render,remain_space,becont)
   SET ms_head_ind = "N"
   FOR (ml_lab_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].lab_data,5))
     IF ((((_yoffset+ lab_results(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
          patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
          ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET mn_pgc = (mn_pgc+ 1)
      SET d0 = pagebreak(0)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_pgc > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = labheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = labheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET mn_pgc = (mn_pgc+ 1)
       SET d0 = foot_report_section(rpt_render)
       SET d0 = pagebreak(0)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_pgc > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = lab_results(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_prob_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].problem_data,5))
     IF ((((_yoffset+ problem_list(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
          patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
          ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET mn_pgc = (mn_pgc+ 1)
      SET d0 = pagebreak(0)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_pgc > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = problemheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = problemheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET mn_pgc = (mn_pgc+ 1)
       SET d0 = pagebreak(0)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_pgc > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = problem_list(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_med_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].medication_data,5))
     IF ((((_yoffset+ medication_list(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
          patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
          ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET mn_pgc = (mn_pgc+ 1)
      SET d0 = pagebreak(0)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_pgc > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = medicationheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = medicationheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET mn_pgc = (mn_pgc+ 1)
       SET d0 = pagebreak(0)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_pgc > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = medication_list(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_vs_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].visit_summary,5))
     IF ((((_yoffset+ visit_summary(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
          patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
          ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET mn_pgc = (mn_pgc+ 1)
      SET d0 = pagebreak(0)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_pgc > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = visitsumheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = visitsumheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET mn_pgc = (mn_pgc+ 1)
       SET d0 = pagebreak(0)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_pgc > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = visit_summary(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_head_ind = "N"
   FOR (ml_cs_prt = 1 TO size(prentl_sum->patient[ml_pd_prt].clin_sum,5))
     IF ((((_yoffset+ clinician_summary(rpt_calcheight,remain_space,becont))+ foot_report_section(
      rpt_calcheight)) > page_size))
      SET _yoffset = page_size
      SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
          patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
          ml_pd_prt].fin_cnt[1].mn_tcnt))))
      SET d0 = subfooter(rpt_render)
      SET d0 = foot_report_section(rpt_render)
      SET mn_pgc = (mn_pgc+ 1)
      SET d0 = pagebreak(0)
      SET ms_continue = "(Continued)"
      SET d0 = report_header(rpt_render)
      IF (mn_pgc > 1)
       SET d0 = patient_demographic2(rpt_render)
      ENDIF
      SET d0 = clinicalheader(rpt_render)
      SET ms_continue = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      SET ms_head_ind = "Y"
     ELSE
      IF (ms_head_ind="N")
       SET remain_space = (page_size - _yoffset)
       SET d0 = clinicalheader(rpt_render)
       SET ms_head_ind = "Y"
      ENDIF
     ENDIF
     WHILE (becont=1)
       SET _yoffset = page_size
       SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->
           patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
       SET d0 = subfooter(rpt_render)
       SET d0 = foot_report_section(rpt_render)
       SET mn_pgc = (mn_pgc+ 1)
       SET d0 = pagebreak(0)
       SET ms_continue = "(Continued)"
       SET d0 = report_header(rpt_render)
       IF (mn_pgc > 1)
        SET d0 = patient_demographic2(rpt_render)
       ENDIF
       SET ms_continue = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET d0 = clinician_summary(rpt_render,remain_space,becont)
   ENDFOR
   SET ms_hpg = trim(concat("Page ",trim(cnvtstring(mn_pgc))," of ",trim(cnvtstring(prentl_sum->
       patient[ml_pd_prt].fin_cnt[1].mn_tcnt))))
   SET ms_tpg = trim(concat("Page ",cnvtstring(mn_pgc)," of ",trim(cnvtstring(prentl_sum->patient[
       ml_pd_prt].fin_cnt[1].mn_tcnt))))
   SET mn_pgc = 1
 ENDFOR
 SET d0 = foot_report_section(rpt_render)
 SET d0 = finalizereport(ms_output)
#exit_script
 SET last_mod =
 "002  03/30/2016 NA033934 SR411605776 Fix the report which was throwing error for some patients"
END GO
