CREATE PROGRAM bhs_rounds_report_v2:dba
 IF ( NOT (validate(req2,0)))
  RECORD req2(
    1 fromccl = i4
    1 printcpt4codes = i4
    1 chestpainobs = i4
    1 pagebreak = i4
  )
  SET req2->fromccl = 0
  SET req2->printcpt4codes = 1
  SET req2->chestpainobs = 0
 ENDIF
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 patient_name = c25
     2 admit_dt = vc
     2 los = vc
     2 reason_for_visit = vc
     2 facility = vc
     2 building = vc
     2 location = vc
     2 room_bed = vc
     2 mrn = vc
     2 dob = vc
     2 age = vc
     2 attenddoc_name = c25
     2 pcp_name = c25
     2 nurse_qual[*]
       3 nurse = vc
     2 casemanager = vc
     2 total_problems = i4
     2 problem[*]
       3 status = vc
       3 beg_effective_dt_tm = vc
       3 text = vc
     2 total_diagnoses = i4
     2 diagnosis[*]
       3 source_identifier = vc
       3 source_string = vc
       3 diag_dt_tm = c16
       3 diag_type_desc = vc
       3 diag_rank_desc = vc
     2 total_allergies = i4
     2 allergy[*]
       3 source_string = vc
       3 substance_type_disp = vc
       3 severity = vc
       3 allergy_dt_tm = vc
     2 total_isolation = i4
     2 isolation[*]
       3 isolation_name = vc
     2 total_screening = i4
     2 screening[*]
       3 screening_name = vc
     2 total_quit = i4
     2 quit[*]
       3 quit_name = vc
     2 total_immunization = i4
     2 immunization[*]
       3 immunization_name = vc
     2 prob_diag_all_max_cnt = i4
     2 prob_diag_all_cnt = i4
     2 prob_diag_all[*]
       3 column1 = vc
       3 column2 = vc
       3 column3 = vc
       3 column4 = vc
     2 total_meds = i4
     2 sched_meds = i2
     2 prn_meds = i2
     2 iv_meds = i2
     2 home_meds = i2
     2 meds[*]
       3 order_id = f8
       3 mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 date = vc
       3 order_status_disp = vc
       3 freq = vc
       3 dose = vc
       3 strength_dose = vc
       3 volume_dose = vc
       3 freetext_dose = vc
       3 rate = vc
       3 route = vc
       3 diluent = vc
       3 need_rx_verify_ind = i2
       3 need_rx_verify_str = vc
       3 type = i2
       3 ioi = i2
       3 iv_prn = vc
     2 med_line_cnt = i4
     2 med_line[*]
       3 column1 = vc
       3 column2 = vc
       3 column3 = vc
       3 column4 = vc
     2 total_vitals = i4
     2 vitals[*]
       3 temp_result = vc
       3 temp_range = vc
       3 systolic_bp_result = vc
       3 systolic_bp_range = vc
       3 diastolic_bp_result = vc
       3 diastolic_bp_range = vc
       3 resp_rate_result = vc
       3 resp_rate_range = vc
       3 pulse_result = vc
       3 pulse_range = vc
       3 o2_sat_result = vc
       3 o2_sat_range = vc
       3 mode_of_delivery = vc
       3 liters_per_min = vc
     2 total_lab_results = i4
     2 lab_results[*]
       3 lab_header = c30
       3 event_id = f8
       3 event_cd_disp = c15
       3 result = c15
       3 result_val = vc
       3 normalcy_disp = vc
       3 most_recent_date = vc
       3 date = vc
     2 lab_line_cnt = i4
     2 lab_line[*]
       3 column1 = vc
       3 column2 = vc
       3 column3 = vc
     2 micro_labs = i4
     2 micro_orders[*]
       3 order_id = f8
       3 orderable = vc
       3 order_status = vc
       3 order_date = vc
     2 blood_bank_labs = i4
     2 blood_bank_orders[*]
       3 order_id = f8
       3 orderable = vc
       3 order_status = vc
       3 order_date = vc
     2 rad_count = i4
     2 rad_orders[*]
       3 order_id = f8
       3 orderable = vc
       3 order_status = vc
       3 order_date = vc
     2 total_titrate_cnt = i4
     2 titrate[*]
       3 12_io_line = vc
       3 12_io_total = vc
       3 24_io_line = vc
       3 24_io_total = vc
     2 total_io = i4
     2 io[*]
       3 type = vc
       3 hour_range = vc
       3 io_line = vc
     2 intake_line_cnt = i4
     2 intake_line[*]
       3 column1 = vc
       3 column2 = vc
     2 output_line_cnt = i4
     2 output_line[*]
       3 column1 = vc
       3 column2 = vc
     2 total_orders = i4
     2 orders[*]
       3 orderable = vc
       3 type = vc
       3 date = vc
     2 diets[*]
       3 orderable = vc
       3 date = vc
       3 clinical_display_line = vc
     2 total_sticky_notes = i4
     2 sticky_notes[*]
       3 notes = vc
       3 note_date = vc
       3 prsnl_name = vc
     2 weights[*]
       3 weight_dt_tm = vc
       3 weight_value = vc
       3 weight_unit = vc
     2 weight_tot_unit = vc
     2 weight_change = f8
     2 weight_up_down = c5
     2 chestpainobs = i2
 )
 DECLARE total_rows = i2
 DECLARE save_total_rows = i2
 DECLARE max_total_rows = i2
 DECLARE tot_cnt = i2
 DECLARE printed_dt_tm = vc
 DECLARE printed_by = vc
 DECLARE printed_on = vc
 SET printed_on = format(cnvtdatetime(curdate,curtime),"mm/dd/yy hh:mm;;d")
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE chestpainobs_str = vc WITH protect, constant("Chest Pain Observation (Cardiology)")
 DECLARE authverified = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE bmdservice = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"BMDSERVICE"))
 DECLARE edadmitreqform = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "EDADMISSIONREQUESTFORM"))
 DECLARE nursing = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",259571,"NURSING"))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE inpatient_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE allergy_canceled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE iv_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE intermittent_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE ivsolutions_cd = f8 WITH public, constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"))
 DECLARE pharmacy_cattyp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE pharmacy_acttyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE o_activity_type_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION"))
 DECLARE o_catalog_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"ISOLATION"))
 DECLARE patientcare_cattyp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCARE"))
 DECLARE condition_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"CONDITION"))
 DECLARE influenza_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "HAVEYOURECEIVEDYOURINFLUENZAVACCINE"))
 DECLARE smoking_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"SMOKINGCESSATION"))
 DECLARE quitsmoking_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTWANTSREFERRALTOQUITSMOKING"))
 DECLARE dose = vc
 DECLARE strength_dose = vc
 DECLARE volume_dose = vc
 DECLARE freetext_dose = vc
 DECLARE dose_unit = vc
 DECLARE strength_unit = vc
 DECLARE volume_unit = vc
 DECLARE rate = vc
 DECLARE rate_unit = vc
 DECLARE route = vc
 DECLARE diluent = vc
 DECLARE sched_cnt = i2
 DECLARE prn_cnt = i2
 DECLARE iv_cnt = i2
 DECLARE headerprinted = i4 WITH noconstant(0)
 DECLARE cnt_temp = i2
 DECLARE cnt_pulse = i2
 DECLARE cnt_sbp = i2
 DECLARE cnt_dbp = i2
 DECLARE cnt_rr = i2
 DECLARE cnt_o2sat = i2
 DECLARE low_temp_result = vc
 DECLARE high_temp_result = vc
 DECLARE low_pulse_result = vc
 DECLARE high_pulse_result = vc
 DECLARE low_sbp_result = vc
 DECLARE high_sbp_result = vc
 DECLARE low_dbp_result = vc
 DECLARE high_dbp_result = vc
 DECLARE low_rr_result = vc
 DECLARE high_rr_result = vc
 DECLARE low_o2sat_result = vc
 DECLARE high_o2sat_result = vc
 DECLARE rounds_note_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14122,"ROUNDNOTE"))
 DECLARE sticky_note_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14122,"POWERCHART"))
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE gen_lab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE blood_bank_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE blood_bank_mlh_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANKMLH"
   ))
 DECLARE blood_bank_donor_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKDONOR"))
 DECLARE blood_bank_products_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKPRODUCT"))
 DECLARE blood_bank_donor_products_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "BLOODBANKDONORPRODUCT"))
 DECLARE ap_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ANATOMICPATHOLOGY"))
 DECLARE hla_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"HLA"))
 DECLARE code_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS"))
 DECLARE od_limited_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16449,"LIMITATIONS"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE most_recent_date = vc
 DECLARE micro_cnt = i4
 DECLARE blood_bank_cnt = i4
 DECLARE next_display = c15
 DECLARE current_display = c15
 DECLARE diff_between = f8
 DECLARE current_05 = f8
 DECLARE restraint_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS"))
 DECLARE heparin_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"HEPARIN"))
 DECLARE enoxaparin_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"ENOXAPARIN"))
 DECLARE warfarin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"WARFARIN")), protect
 DECLARE cath_foley_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERFOLEY"))
 DECLARE cath_care_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERCARE"))
 DECLARE cath_foley_3_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERFOLEYTHREEWAY"))
 DECLARE cathetersinglelumenindwellingurinary_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERSINGLELUMENINDWELLINGURINARY")), protect
 DECLARE cath_texas_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERTEXAS"))
 DECLARE cath_suprap_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERSUPRAPUBIC"))
 DECLARE cath_coude_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERCOUDE"))
 DECLARE boots_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "PNEUMATICCOMPRESSIONBOOTS"))
 DECLARE stockings_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "ANTIEMBOLISMSTOCKINGS"))
 DECLARE placeholder_event_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,
   "PLACEHOLDER"))
 DECLARE tube_continuous_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,
   "Tube Feeding Continuous"))
 DECLARE infant_formula_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,"Infant Formulas"
   ))
 DECLARE infant_formula_add_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,
   "Infant Formula Additives"))
 DECLARE tube_feeding_add_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,
   "Tube Feeding Additives"))
 DECLARE tube_feeding_bolus_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,
   "Tube Feeding Bolus"))
 DECLARE supplements_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,"Supplements"))
 DECLARE diets_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",106,"Diets"))
 DECLARE 12_hour_i_total = f8
 DECLARE 12_hour_o_total = f8
 DECLARE 12_hour_i_comp_total = f8
 DECLARE 12_hour_i_comp_line = vc
 DECLARE 12_hour_o_comp_total = f8
 DECLARE 12_hour_o_comp_line = vc
 DECLARE 24_hour_i_total = f8
 DECLARE 24_hour_o_total = f8
 DECLARE 24_hour_i_comp_total = f8
 DECLARE 24_hour_i_comp_line = vc
 DECLARE 24_hour_o_comp_total = f8
 DECLARE 24_hour_o_comp_line = vc
 DECLARE 12_hour_i_comp_total = f8
 DECLARE 12_hour_o_comp_total = f8
 DECLARE 24_hour_i_comp_total = f8
 DECLARE 24_hour_o_comp_total = f8
 DECLARE xcol = i2
 DECLARE ycol = i2
 DECLARE save_ycol = i2
 DECLARE save_ycol1 = i2
 DECLARE save_ycol2 = i2
 DECLARE end_ycol = i2
 DECLARE line = vc
 DECLARE short_line = vc
 DECLARE wrapcol = i2
 DECLARE tempstring = vc
 DECLARE printstring = vc
 DECLARE eol = i4
 DECLARE med_string = vc
 DECLARE total_lab_rows = i2
 DECLARE lab_string = vc
 DECLARE total_med_rows = i2
 DECLARE pcnt = i4
 DECLARE dcnt = i4
 DECLARE acnt = i4
 DECLARE total_dpa_rows = i4
 DECLARE total_order_rows = f8
 DECLARE order_string = vc
 DECLARE note_string = vc
 DECLARE encntr_ids_0 = i4
 DECLARE last_weight = f8
 DECLARE first_weight = f8
 DECLARE total_weight = f8
 DECLARE total_delta = c5
 DECLARE print_weight = vc
 DECLARE saved_units = vc
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 IF (validate(displaynurse)=0)
  SET displaynurse = 0
 ENDIF
 IF (validate(request->visit,"Z") != "Z")
  SET printer_disp = request->output_device
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    printed_by = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  IF (size(request->visit,5) > 0)
   SELECT INTO "nl:"
    encntr_id = request->visit[d1.seq].encntr_id
    FROM (dummyt d1  WITH seq = value(size(request->visit,5)))
    HEAD REPORT
     stat = alterlist(dlrec->seq,10), cnt = 0, encntr_ids_0 = 0
    HEAD encntr_id
     IF (encntr_id != 0)
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(dlrec->seq,(cnt+ 10))
      ENDIF
      dlrec->seq[cnt].encntr_id = request->visit[d1.seq].encntr_id
     ENDIF
    DETAIL
     IF (encntr_id=0)
      encntr_ids_0 = (encntr_ids_0+ 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(dlrec->seq,cnt), dlrec->encntr_total = cnt
    WITH nocounter
   ;end select
  ENDIF
  IF (((size(request->visit,5)=0) OR (encntr_ids_0=size(request->visit,5))) )
   SELECT INTO value(printer_disp)
    FROM dummyt
    HEAD REPORT
     line = fillstring(200,"-"), line_short = fillstring(125,"-"), xcol = 0,
     ycol = 0, "{f/0}{cpi/18}", ycol = 30,
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), "*** Baystate Rounds Report v2 ***",
     xcol = 215,
     CALL print(calcpos(xcol,ycol)), "Printed on: ",
     printed_on, xcol = 400,
     CALL print(calcpos(xcol,ycol)),
     "Printed by: ", printed_by, ycol = (ycol+ 8),
     row + 1, xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)), line, ycol = (ycol+ 8),
     row + 1, xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     "{b}", "Location-", xcol = 100,
     CALL print(calcpos(xcol,ycol)), "{b}", "Name",
     xcol = 215,
     CALL print(calcpos(xcol,ycol)), "{b}",
     "MR", xcol = 265,
     CALL print(calcpos(xcol,ycol)),
     "{b}", "DOB(age)", xcol = 325,
     CALL print(calcpos(xcol,ycol)), "{b}", "Admit date(Day)",
     xcol = 400,
     CALL print(calcpos(xcol,ycol)), "{b}",
     "Attending", xcol = 500,
     CALL print(calcpos(xcol,ycol)),
     "{b}", "PCP", ycol = (ycol+ 8),
     row + 1, xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     "{endb}", line, ycol = (ycol+ 16),
     row + 1, xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     "Encounters not available from Patient List.", ycol = (ycol+ 16), row + 1
    WITH nocounter, dio = postscript, maxrow = 800,
     maxcol = 800
   ;end select
   GO TO end_of_program
  ENDIF
 ELSE
  IF ((reqinfo->updt_id > 0))
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     printed_by = trim(p.name_full_formatted)
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(dlrec->seq,1)
  SET dlrec->encntr_total = 1
  SET printer_disp =  $1
  SET dlrec->seq[1].encntr_id = 33328701
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total)),
   encounter e,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn epr1,
   prsnl ep,
   person_prsnl_reltn ppr,
   prsnl pp
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=dlrec->seq[d1.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ((ea.encntr_alias_type_cd+ 0)=mrn_cd)
    AND ((ea.active_ind+ 0)=1)
    AND ((ea.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime)))
   JOIN (epr1
   WHERE epr1.encntr_id=outerjoin(e.encntr_id)
    AND epr1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime))
    AND epr1.active_ind=outerjoin(1)
    AND epr1.encntr_prsnl_r_cd=outerjoin(attenddoc_cd))
   JOIN (ep
   WHERE ep.person_id=outerjoin(epr1.prsnl_person_id))
   JOIN (ppr
   WHERE ppr.person_id=outerjoin(e.person_id)
    AND ppr.beg_effective_dt_tm <= outerjoin(cnvtdatetime((curdate+ 1),curtime3))
    AND ppr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime))
    AND ppr.active_ind=outerjoin(1)
    AND ppr.person_prsnl_r_cd=outerjoin(pcp_cd))
   JOIN (pp
   WHERE pp.person_id=outerjoin(ppr.prsnl_person_id))
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   dlrec->seq[d1.seq].person_id = e.person_id, dlrec->seq[d1.seq].admit_dt = format(e.reg_dt_tm,
    "mm/dd;;d"), dlrec->seq[d1.seq].los =
   IF (e.disch_dt_tm != null) cnvtstring(datetimediff(e.disch_dt_tm,e.reg_dt_tm))
   ELSE cnvtstring(datetimediff(cnvtdatetime(curdate,curtime),e.reg_dt_tm))
   ENDIF
   ,
   dlrec->seq[d1.seq].reason_for_visit = trim(e.reason_for_visit), dlrec->seq[d1.seq].facility = trim
   (uar_get_code_display(e.loc_facility_cd)), dlrec->seq[d1.seq].building = trim(uar_get_code_display
    (e.loc_building_cd)),
   dlrec->seq[d1.seq].room_bed = concat(trim(uar_get_code_display(e.loc_room_cd),3)," ",trim(
     uar_get_code_display(e.loc_bed_cd),3)), dlrec->seq[d1.seq].dob = format(p.birth_dt_tm,
    "mm/dd/yy;;d"), dlrec->seq[d1.seq].age = substring(1,3,trim(cnvtage(p.birth_dt_tm),3)),
   dlrec->seq[d1.seq].patient_name = trim(p.name_full_formatted), dlrec->seq[d1.seq].mrn = trim(ea
    .alias), dlrec->seq[d1.seq].attenddoc_name = trim(ep.name_full_formatted),
   dlrec->seq[d1.seq].pcp_name = trim(pp.name_full_formatted)
   IF (trim(uar_get_code_display(e.loc_nurse_unit_cd))="Geri Psych")
    dlrec->seq[d1.seq].location = "GP"
   ELSEIF (trim(uar_get_code_display(e.loc_nurse_unit_cd))="Med Surg")
    dlrec->seq[d1.seq].location = "MS"
   ELSEIF (trim(uar_get_code_display(e.loc_nurse_unit_cd))="Parker North")
    dlrec->seq[d1.seq].location = "PN"
   ELSE
    dlrec->seq[d1.seq].location = trim(uar_get_code_display(e.loc_nurse_unit_cd))
   ENDIF
  FOOT  e.encntr_id
   IF (e.reason_for_visit > " ")
    stat = alterlist(dlrec->seq[d1.seq].diagnosis,1), dlrec->seq[d1.seq].diagnosis[1].diag_type_desc
     = "Reason For Visit", dlrec->seq[d1.seq].diagnosis[1].source_string = e.reason_for_visit,
    dlrec->seq[d1.seq].diagnosis[1].diag_dt_tm = substring(1,14,format(e.reg_dt_tm,
      "@SHORTDATETIME;;Q")), dlrec->seq[d1.seq].total_diagnoses = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (displaynurse=1)
  SELECT INTO "nl:"
   FROM clinical_event ce,
    prsnl pr,
    (dummyt d  WITH seq = size(dlrec->seq,5))
   PLAN (d)
    JOIN (ce
    WHERE (ce.encntr_id=dlrec->seq[d.seq].encntr_id)
     AND ce.event_title_text="Case Management *"
     AND ce.view_level=1)
    JOIN (pr
    WHERE pr.person_id=ce.updt_id)
   ORDER BY ce.encntr_id, ce.event_start_dt_tm DESC
   HEAD ce.encntr_id
    dlrec->seq[d.seq].casemanager = concat(trim(pr.name_first,3)," ",trim(pr.name_last,3))
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM encntr_domain e,
    dcp_shift_assignment sa,
    dcp_care_team ct,
    dcp_care_team_prsnl ctp,
    prsnl p,
    (dummyt d  WITH seq = size(dlrec->seq,5))
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=dlrec->seq[d.seq].encntr_id))
    JOIN (sa
    WHERE ((sa.loc_bed_cd=e.loc_bed_cd
     AND sa.loc_bed_cd > 0) OR (sa.loc_bed_cd=0
     AND sa.loc_room_cd=e.loc_room_cd
     AND sa.active_ind=1
     AND sa.loc_room_cd > 0))
     AND sa.active_ind=1
     AND sa.purge_ind=0
     AND cnvtdatetime(curdate,curtime3) BETWEEN sa.beg_effective_dt_tm AND sa.end_effective_dt_tm
     AND sa.assign_type_cd=nursing)
    JOIN (ct
    WHERE ct.careteam_id > outerjoin(0)
     AND ct.careteam_id=outerjoin(sa.careteam_id)
     AND ct.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime))
     AND ct.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
    JOIN (ctp
    WHERE ctp.careteam_id > outerjoin(0)
     AND ctp.careteam_id=outerjoin(ct.careteam_id)
     AND ctp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime))
     AND ctp.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime)))
    JOIN (p
    WHERE ((p.person_id=sa.prsnl_id
     AND sa.prsnl_id > 0) OR (p.person_id=ctp.prsnl_id
     AND ctp.prsnl_id > 0))
     AND p.person_id > 0)
   ORDER BY e.encntr_id, p.name_full_formatted
   HEAD e.encntr_id
    nursecnt = 0
   HEAD p.name_full_formatted
    nursecnt = (nursecnt+ 1), stat = alterlist(dlrec->seq[d.seq].nurse_qual,nursecnt), dlrec->seq[d
    .seq].nurse_qual[nursecnt].nurse = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
    IF (cnvtupper(uar_get_code_display(p.position_cd))="BHS RN")
     dlrec->seq[d.seq].nurse_qual[nursecnt].nurse = concat(dlrec->seq[d.seq].nurse_qual[nursecnt].
      nurse," RN")
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(dlrec->seq,5))),
    clinical_event ce1,
    clinical_event ce2,
    clinical_event ce3
   PLAN (d)
    JOIN (ce1
    WHERE (ce1.person_id=dlrec->seq[d.seq].person_id)
     AND ce1.event_cd=bmdservice
     AND ce1.result_val=chestpainobs_str
     AND ce1.result_status_cd=authverified)
    JOIN (ce2
    WHERE ce2.event_id=ce1.parent_event_id)
    JOIN (ce3
    WHERE ce3.event_id=ce2.parent_event_id
     AND ce3.event_cd=edadmitreqform)
   DETAIL
    dlrec->seq[d.seq].chestpainobs = 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl"
  p.person_id, encntr_id = dlrec->seq[d.seq].encntr_id, p.onset_dt_tm,
  problem_string =
  IF (p.nomenclature_id=0
   AND trim(p.problem_ftdesc) > " ") trim(p.problem_ftdesc)
  ELSEIF (p.nomenclature_id > 0
   AND n.source_vocabulary_cd=snmct_cd) trim(n.source_string)
  ENDIF
  FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
   problem p,
   nomenclature n
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=dlrec->seq[d.seq].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
    AND n.source_vocabulary_cd=outerjoin(snmct_cd))
  ORDER BY p.person_id, encntr_id, p.onset_dt_tm DESC,
   problem_string
  HEAD p.person_id
   row + 0
  HEAD encntr_id
   prob_cnt = 0
  HEAD problem_string
   IF (size(trim(problem_string,3)) > 0)
    prob_cnt = (prob_cnt+ 1), stat = alterlist(dlrec->seq[d.seq].problem,prob_cnt), dlrec->seq[d.seq]
    .total_problems = prob_cnt,
    dlrec->seq[d.seq].problem[prob_cnt].text = trim(problem_string,3), dlrec->seq[d.seq].problem[
    prob_cnt].status = uar_get_code_display(p.life_cycle_status_cd), dlrec->seq[d.seq].problem[
    prob_cnt].beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,"@SHORTDATETIME;;Q"))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.encntr_id, diag_dt_tm = cnvtdatetime(d.diag_dt_tm), d.nomenclature_id,
  d.diagnosis_id
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   diagnosis d,
   nomenclature n
  PLAN (dd)
   JOIN (d
   WHERE (d.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND cnvtdatetime(curdate,curtime3) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
  ORDER BY d.encntr_id, diag_dt_tm DESC, d.nomenclature_id,
   d.diagnosis_id
  HEAD d.encntr_id
   diag_cnt = dlrec->seq[dd.seq].total_diagnoses, stat = alterlist(dlrec->seq[dd.seq].diagnosis,(
    diag_cnt+ 10))
  DETAIL
   diag_cnt = (diag_cnt+ 1)
   IF (mod(diag_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].diagnosis,(diag_cnt+ 10))
   ENDIF
   IF (n.nomenclature_id > 0)
    dlrec->seq[dd.seq].diagnosis[diag_cnt].source_string = n.source_string
   ELSEIF (size(trim(d.diag_ftdesc)) > 0)
    dlrec->seq[dd.seq].diagnosis[diag_cnt].source_string = d.diag_ftdesc
   ELSEIF (size(trim(d.diagnosis_display)) > 0)
    dlrec->seq[dd.seq].diagnosis[diag_cnt].source_string = d.diagnosis_display
   ENDIF
   dlrec->seq[dd.seq].diagnosis[diag_cnt].source_identifier = n.source_identifier, dlrec->seq[dd.seq]
   .diagnosis[diag_cnt].diag_dt_tm = substring(1,14,format(d.diag_dt_tm,"@SHORTDATETIME;;Q")), dlrec
   ->seq[dd.seq].diagnosis[diag_cnt].diag_type_desc = uar_get_code_display(d.diag_type_cd),
   dlrec->seq[dd.seq].diagnosis[diag_cnt].diag_rank_desc = uar_get_code_display(d.ranking_cd)
  FOOT  d.encntr_id
   IF (diag_cnt > 0)
    stat = alterlist(dlrec->seq[dd.seq].diagnosis,diag_cnt), dlrec->seq[dd.seq].total_diagnoses =
    diag_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[dd.seq].encntr_id, allergy_string =
  IF (a.substance_nom_id=0
   AND trim(a.substance_ftdesc) > " ") trim(a.substance_ftdesc)
  ELSEIF (a.substance_nom_id > 0) trim(n.source_string)
  ENDIF
  , substance_type_disp =
  IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
  ELSE "Other "
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   allergy a,
   nomenclature n
  PLAN (dd)
   JOIN (a
   WHERE (a.person_id=dlrec->seq[dd.seq].person_id)
    AND ((a.active_ind+ 0)=1)
    AND ((a.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((((a.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))) OR (((a.end_effective_dt_tm
   + 0)=null)))
    AND ((a.reaction_status_cd+ 0) != allergy_canceled_cd))
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
  ORDER BY a.person_id, encntr_id, substance_type_disp,
   allergy_string
  HEAD a.person_id
   row + 0
  HEAD encntr_id
   all_cnt = 0
  DETAIL
   all_cnt = (all_cnt+ 1), stat = alterlist(dlrec->seq[dd.seq].allergy,all_cnt), dlrec->seq[dd.seq].
   total_allergies = all_cnt,
   dlrec->seq[dd.seq].allergy[all_cnt].source_string = allergy_string, dlrec->seq[dd.seq].allergy[
   all_cnt].substance_type_disp = substance_type_disp, dlrec->seq[dd.seq].allergy[all_cnt].severity
    = uar_get_code_display(a.severity_cd),
   dlrec->seq[dd.seq].allergy[all_cnt].allergy_dt_tm = substring(1,14,format(a.updt_dt_tm,
     "@SHORTDATETIME;;Q"))
  WITH nocounter
 ;end select
 SET total_isolation = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total)),
   orders o
  PLAN (d1)
   JOIN (o
   WHERE (o.person_id=dlrec->seq[d1.seq].person_id)
    AND (o.encntr_id=dlrec->seq[d1.seq].encntr_id)
    AND o.activity_type_cd=o_activity_type_cd
    AND o.catalog_cd=o_catalog_cd
    AND o.catalog_type_cd=patientcare_cattyp_cd
    AND o.order_status_cd=o_ordered_cd
    AND o.dcp_clin_cat_cd=condition_cd)
  ORDER BY o.person_id, o.order_id
  HEAD o.person_id
   isol_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].isolation,10)
  HEAD o.order_id
   isol_cnt = (isol_cnt+ 1)
   IF (mod(isol_cnt,10)=1)
    stat = alterlist(dlrec->seq[d1.seq].isolation,(isol_cnt+ 9))
   ENDIF
   dlrec->seq[d1.seq].isolation[isol_cnt].isolation_name = o.order_mnemonic
  FOOT  o.person_id
   stat = alterlist(dlrec->seq[d1.seq].isolation,isol_cnt), dlrec->seq[d1.seq].total_isolation = (
   total_isolation+ isol_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  WHERE (dlrec->seq[d1.seq].total_problems > 0)
  ORDER BY encntr_id
  HEAD REPORT
   MACRO (line_wrap_indent)
    limit = 0, maxlen = wrapcol, cr = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", "|", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      IF (limit != 1)
       printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column1 = concat(" ",printstring)
      ELSEIF (limit=1)
       maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,total_rows), dlrec->seq[d1.seq].
        prob_diag_all_cnt = total_rows
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column1 = printstring
      ENDIF
      tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
  HEAD encntr_id
   pcnt = 0, total_rows = 0, max_total_rows = 0,
   save_total_rows = 0, printstring = "", stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(
    total_rows+ 10)),
   dlrec->seq[d1.seq].prob_diag_all_cnt = (total_rows+ 10)
  DETAIL
   FOR (pcnt = 1 TO dlrec->seq[d1.seq].total_problems)
     IF (size(trim(dlrec->seq[d1.seq].problem[pcnt].text,3)) > 0
      AND size(trim(dlrec->seq[d1.seq].problem[pcnt].text,3)) <= 45)
      total_rows = (total_rows+ 1)
      IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
       stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
       prob_diag_all_cnt = (total_rows+ 10)
      ENDIF
      dlrec->seq[d1.seq].prob_diag_all[total_rows].column1 = trim(dlrec->seq[d1.seq].problem[pcnt].
       text)
     ELSEIF (size(trim(dlrec->seq[d1.seq].problem[pcnt].text,3)) > 0)
      tempstring = trim(dlrec->seq[d1.seq].problem[pcnt].text), wrapcol = 45, eol = size(tempstring),
      line_wrap_indent
     ENDIF
   ENDFOR
   max_total_rows = total_rows
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,max_total_rows), dlrec->seq[d1.seq].
   prob_diag_all_cnt = max_total_rows, dlrec->seq[d1.seq].prob_diag_all_max_cnt = max_total_rows
  WITH nocounter
 ;end select
 DECLARE diag_temp_string = vc
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  WHERE (dlrec->seq[d1.seq].total_diagnoses > 0)
  ORDER BY encntr_id
  HEAD REPORT
   MACRO (line_wrap_indent)
    limit = 0, maxlen = wrapcol, cr = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", "|", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      IF (limit != 1)
       printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column2 = concat(" ",printstring)
      ELSEIF (limit=1)
       maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column2 = printstring
      ENDIF
      tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
  HEAD encntr_id
   dcnt = 0, total_rows = 0, max_total_rows = 0,
   save_total_rows = 0, printstring = ""
   IF ((dlrec->seq[d1.seq].prob_diag_all_cnt > 0))
    stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(dlrec->seq[d1.seq].prob_diag_all_cnt+ 10)),
    dlrec->seq[d1.seq].prob_diag_all_cnt = (dlrec->seq[d1.seq].prob_diag_all_cnt+ 10)
   ELSEIF ((dlrec->seq[d1.seq].prob_diag_all_cnt=0))
    stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,10), dlrec->seq[d1.seq].prob_diag_all_cnt = 10
   ENDIF
  DETAIL
   FOR (dcnt = 1 TO dlrec->seq[d1.seq].total_diagnoses)
    IF ((dlrec->seq[d1.seq].diagnosis[dcnt].diag_rank_desc="Primary"))
     diag_temp_string = concat(trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string)," (Primary) ")
    ELSEIF ((dlrec->seq[d1.seq].diagnosis[dcnt].diag_type_desc="Principle"))
     diag_temp_string = concat(trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string)," (Principle) "
      )
    ELSE
     diag_temp_string = trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string)
    ENDIF
    ,
    IF (size(trim(diag_temp_string)) > 0
     AND size(trim(diag_temp_string)) <= 45)
     total_rows = (total_rows+ 1)
     IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
      stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
      prob_diag_all_cnt = (total_rows+ 10)
     ENDIF
     dlrec->seq[d1.seq].prob_diag_all[total_rows].column2 = trim(diag_temp_string)
    ELSEIF (size(trim(diag_temp_string)) > 0)
     tempstring = trim(diag_temp_string), wrapcol = 45, eol = size(tempstring),
     line_wrap_indent
    ENDIF
   ENDFOR
   IF ((total_rows > dlrec->seq[d1.seq].prob_diag_all_max_cnt))
    max_total_rows = total_rows
   ELSE
    max_total_rows = dlrec->seq[d1.seq].prob_diag_all_max_cnt
   ENDIF
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,max_total_rows), dlrec->seq[d1.seq].
   prob_diag_all_cnt = max_total_rows, dlrec->seq[d1.seq].prob_diag_all_max_cnt = max_total_rows
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  WHERE (dlrec->seq[d1.seq].total_allergies > 0)
  ORDER BY encntr_id
  HEAD REPORT
   MACRO (line_wrap_indent)
    limit = 0, maxlen = wrapcol, cr = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", "|", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      IF (limit != 1)
       printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column3 = concat(" ",printstring)
      ELSEIF (limit=1)
       maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column3 = printstring
      ENDIF
      tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
  HEAD encntr_id
   acnt = 0, total_rows = 0, max_total_rows = 0,
   save_total_rows = 0, printstring = ""
   IF ((dlrec->seq[d1.seq].prob_diag_all_cnt > 0))
    stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(dlrec->seq[d1.seq].prob_diag_all_cnt+ 10)),
    dlrec->seq[d1.seq].prob_diag_all_cnt = (dlrec->seq[d1.seq].prob_diag_all_cnt+ 10)
   ELSEIF ((dlrec->seq[d1.seq].prob_diag_all_cnt=0))
    stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,10), dlrec->seq[d1.seq].prob_diag_all_cnt = 10
   ENDIF
   FOR (acnt = 1 TO dlrec->seq[d1.seq].total_allergies)
     IF (size(trim(dlrec->seq[d1.seq].allergy[acnt].source_string)) > 0
      AND size(trim(dlrec->seq[d1.seq].allergy[acnt].source_string)) <= 45)
      total_rows = (total_rows+ 1)
      IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
       stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
       prob_diag_all_cnt = (total_rows+ 10)
      ENDIF
      dlrec->seq[d1.seq].prob_diag_all[total_rows].column3 = trim(dlrec->seq[d1.seq].allergy[acnt].
       source_string)
     ELSEIF (size(trim(dlrec->seq[d1.seq].allergy[acnt].source_string)) > 0)
      tempstring = trim(dlrec->seq[d1.seq].allergy[acnt].source_string), wrapcol = 45, eol = size(
       trim(tempstring)),
      line_wrap_indent
     ENDIF
   ENDFOR
   IF ((total_rows > dlrec->seq[d1.seq].prob_diag_all_max_cnt))
    max_total_rows = total_rows
   ELSE
    max_total_rows = dlrec->seq[d1.seq].prob_diag_all_max_cnt
   ENDIF
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,max_total_rows), dlrec->seq[d1.seq].
   prob_diag_all_cnt = max_total_rows, dlrec->seq[d1.seq].prob_diag_all_max_cnt = max_total_rows
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  med_type =
  IF (((o.med_order_type_cd IN (iv_cd, intermittent_cd)) OR (o.dcp_clin_cat_cd=ivsolutions_cd)) ) 4
  ELSEIF (o.orig_ord_as_flag IN (1, 2)) 6
  ELSEIF (o.prn_ind=0
   AND o.freq_type_flag != 5) 1
  ELSEIF (o.prn_ind=0
   AND o.freq_type_flag=5) 2
  ELSEIF (o.prn_ind=1) 3
  ELSE 5
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o,
   order_detail od
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND o.order_status_cd IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd)
    AND o.catalog_type_cd=pharmacy_cattyp_cd
    AND o.template_order_flag IN (0, 1)
    AND  NOT (o.orig_ord_as_flag IN (1, 2)))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE")) OR (od.oe_field_meaning="OTHER"
    AND (od.oe_field_value=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=od.oe_field_value
     AND ((cv.code_set+ 0)=102202))))) )
  ORDER BY o.encntr_id, o.order_mnemonic, o.order_id,
   od.action_sequence
  HEAD o.encntr_id
   med_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].meds,10), sched_cnt = 0,
   prn_cnt = 0, iv_cnt = 0
  HEAD o.order_mnemonic
   row + 0
  HEAD o.order_id
   dose = " ", strength_dose = " ", freetext_dose = " ",
   volume_dose = " ", dose_unit = " ", strength_unit = " ",
   volume_unit = " ", rate = " ", rate_unit = " ",
   med_cnt = (med_cnt+ 1)
   IF (mod(med_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].meds,(med_cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].meds[med_cnt].order_id = o.order_id, dlrec->seq[dd.seq].meds[med_cnt].type =
   med_type, dlrec->seq[dd.seq].meds[med_cnt].ioi = o.incomplete_order_ind,
   dlrec->seq[dd.seq].meds[med_cnt].mnemonic =
   IF (trim(o.order_mnemonic) > "") concat(trim(o.order_mnemonic),"|")
   ELSE concat(trim(o.ordered_as_mnemonic),"|")
   ENDIF
   , dlrec->seq[dd.seq].meds[med_cnt].date = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->
   seq[dd.seq].meds[med_cnt].order_status_disp = uar_get_code_display(o.order_status_cd),
   dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Verified)"
    OF 1:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Unverified)"
    OF 2:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Rejected)"
   ENDCASE
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    dlrec->seq[dd.seq].meds[med_cnt].freq = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATE")
    rate = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATEUNIT")
    rate_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSE")
    dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    strength_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
    volume_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    freetext_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    dose_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    strength_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    volume_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="OTHER")
    dlrec->seq[dd.seq].meds[med_cnt].diluent = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RXROUTE")
    dlrec->seq[dd.seq].meds[med_cnt].route = concat(trim(od.oe_field_display_value),"|")
   ENDIF
  FOOT  o.order_id
   IF (med_type=1)
    sched_cnt = (sched_cnt+ 1)
   ELSEIF (med_type=3)
    prn_cnt = (prn_cnt+ 1)
   ELSEIF (med_type=4)
    iv_cnt = (iv_cnt+ 1)
   ENDIF
   IF (med_type=4
    AND o.prn_ind=1)
    dlrec->seq[dd.seq].meds[med_cnt].iv_prn = "PRN"
   ENDIF
   IF (rate > " ")
    IF (rate_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].rate = concat(rate,rate_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].rate = rate
    ENDIF
   ENDIF
   IF (dose > " ")
    IF (dose_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].dose = concat(dose,dose_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].dose = concat(dose)
    ENDIF
   ENDIF
   IF (strength_dose > " ")
    IF (strength_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].strength_dose = concat(strength_dose,strength_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].strength_dose = concat(strength_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " ")
    IF (volume_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " "
    AND strength_dose <= ""
    AND dose <= "")
    IF (volume_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (freetext_dose > " ")
    dlrec->seq[dd.seq].meds[med_cnt].freetext_dose = concat(freetext_dose)
   ENDIF
  FOOT  o.order_mnemonic
   row + 0
  FOOT  o.encntr_id
   dlrec->seq[dd.seq].total_meds = med_cnt, stat = alterlist(dlrec->seq[dd.seq].meds,med_cnt), dlrec
   ->seq[dd.seq].sched_meds = sched_cnt,
   dlrec->seq[dd.seq].prn_meds = prn_cnt, dlrec->seq[dd.seq].iv_meds = iv_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  WHERE (dlrec->seq[d1.seq].total_isolation > 0)
  ORDER BY encntr_id
  HEAD REPORT
   MACRO (line_wrap_indent)
    limit = 0, maxlen = wrapcol, cr = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", "|", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      IF (limit != 1)
       printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column4 = concat(" ",printstring)
      ELSEIF (limit=1)
       maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
        prob_diag_all_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].prob_diag_all[total_rows].column4 = printstring
      ENDIF
      tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
  HEAD encntr_id
   acnt = 0, total_rows = 0, max_total_rows = 0,
   save_total_rows = 0, printstring = ""
   IF ((dlrec->seq[d1.seq].prob_diag_all_cnt > 0))
    stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(dlrec->seq[d1.seq].prob_diag_all_cnt+ 10)),
    dlrec->seq[d1.seq].prob_diag_all_cnt = (dlrec->seq[d1.seq].prob_diag_all_cnt+ 10)
   ELSEIF ((dlrec->seq[d1.seq].prob_diag_all_cnt=0))
    stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,10), dlrec->seq[d1.seq].prob_diag_all_cnt = 10
   ENDIF
   FOR (acnt = 1 TO dlrec->seq[d1.seq].total_isolation)
     IF (size(trim(dlrec->seq[d1.seq].isolation[acnt].isolation_name)) > 0
      AND size(trim(dlrec->seq[d1.seq].isolation[acnt].isolation_name)) <= 45)
      total_rows = (total_rows+ 1)
      IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
       stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
       prob_diag_all_cnt = (total_rows+ 10)
      ENDIF
      dlrec->seq[d1.seq].prob_diag_all[total_rows].column4 = trim(dlrec->seq[d1.seq].isolation[acnt].
       isolation_name)
     ELSEIF (size(trim(dlrec->seq[d1.seq].isolation[acnt].isolation_name)) > 0)
      tempstring = trim(dlrec->seq[d1.seq].isolation[acnt].isolation_name), wrapcol = 45, eol = size(
       trim(tempstring)),
      line_wrap_indent
     ENDIF
   ENDFOR
   IF ((total_rows > dlrec->seq[d1.seq].prob_diag_all_max_cnt))
    max_total_rows = total_rows
   ELSE
    max_total_rows = dlrec->seq[d1.seq].prob_diag_all_max_cnt
   ENDIF
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,max_total_rows), dlrec->seq[d1.seq].
   prob_diag_all_cnt = max_total_rows, dlrec->seq[d1.seq].prob_diag_all_max_cnt = max_total_rows
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  med_type =
  IF (((o.med_order_type_cd IN (iv_cd, intermittent_cd)) OR (o.dcp_clin_cat_cd=ivsolutions_cd)) ) 4
  ELSEIF (o.orig_ord_as_flag IN (1, 2)) 6
  ELSEIF (o.prn_ind=0
   AND o.freq_type_flag != 5) 1
  ELSEIF (o.prn_ind=0
   AND o.freq_type_flag=5) 2
  ELSEIF (o.prn_ind=1) 3
  ELSE 5
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o,
   order_detail od
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND o.order_status_cd IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd)
    AND o.catalog_type_cd=pharmacy_cattyp_cd
    AND o.template_order_flag IN (0, 1)
    AND  NOT (o.orig_ord_as_flag IN (1, 2)))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE")) OR (od.oe_field_meaning="OTHER"
    AND (od.oe_field_value=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=od.oe_field_value
     AND ((cv.code_set+ 0)=102202))))) )
  ORDER BY o.encntr_id, o.order_mnemonic, o.order_id,
   od.action_sequence
  HEAD o.encntr_id
   med_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].meds,10), sched_cnt = 0,
   prn_cnt = 0, iv_cnt = 0
  HEAD o.order_mnemonic
   row + 0
  HEAD o.order_id
   dose = " ", strength_dose = " ", freetext_dose = " ",
   volume_dose = " ", dose_unit = " ", strength_unit = " ",
   volume_unit = " ", rate = " ", rate_unit = " ",
   med_cnt = (med_cnt+ 1)
   IF (mod(med_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].meds,(med_cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].meds[med_cnt].order_id = o.order_id, dlrec->seq[dd.seq].meds[med_cnt].type =
   med_type, dlrec->seq[dd.seq].meds[med_cnt].ioi = o.incomplete_order_ind,
   dlrec->seq[dd.seq].meds[med_cnt].mnemonic =
   IF (trim(o.order_mnemonic) > "") concat(trim(o.order_mnemonic),"|")
   ELSE concat(trim(o.ordered_as_mnemonic),"|")
   ENDIF
   , dlrec->seq[dd.seq].meds[med_cnt].date = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->
   seq[dd.seq].meds[med_cnt].order_status_disp = uar_get_code_display(o.order_status_cd),
   dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Verified)"
    OF 1:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Unverified)"
    OF 2:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Rejected)"
   ENDCASE
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    dlrec->seq[dd.seq].meds[med_cnt].freq = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATE")
    rate = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATEUNIT")
    rate_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSE")
    dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    strength_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
    volume_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    freetext_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    dose_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    strength_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    volume_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="OTHER")
    dlrec->seq[dd.seq].meds[med_cnt].diluent = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RXROUTE")
    dlrec->seq[dd.seq].meds[med_cnt].route = concat(trim(od.oe_field_display_value),"|")
   ENDIF
  FOOT  o.order_id
   IF (med_type=1)
    sched_cnt = (sched_cnt+ 1)
   ELSEIF (med_type=3)
    prn_cnt = (prn_cnt+ 1)
   ELSEIF (med_type=4)
    iv_cnt = (iv_cnt+ 1)
   ENDIF
   IF (med_type=4
    AND o.prn_ind=1)
    dlrec->seq[dd.seq].meds[med_cnt].iv_prn = "PRN"
   ENDIF
   IF (rate > " ")
    IF (rate_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].rate = concat(rate,rate_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].rate = rate
    ENDIF
   ENDIF
   IF (dose > " ")
    IF (dose_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].dose = concat(dose,dose_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].dose = concat(dose)
    ENDIF
   ENDIF
   IF (strength_dose > " ")
    IF (strength_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].strength_dose = concat(strength_dose,strength_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].strength_dose = concat(strength_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " ")
    IF (volume_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " "
    AND strength_dose <= ""
    AND dose <= "")
    IF (volume_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (freetext_dose > " ")
    dlrec->seq[dd.seq].meds[med_cnt].freetext_dose = concat(freetext_dose)
   ENDIF
  FOOT  o.order_mnemonic
   row + 0
  FOOT  o.encntr_id
   dlrec->seq[dd.seq].total_meds = med_cnt, stat = alterlist(dlrec->seq[dd.seq].meds,med_cnt), dlrec
   ->seq[dd.seq].sched_meds = sched_cnt,
   dlrec->seq[dd.seq].prn_meds = prn_cnt, dlrec->seq[dd.seq].iv_meds = iv_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  med_type = 6
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o,
   order_detail od,
   dummyt do
  PLAN (dd)
   JOIN (o
   WHERE (o.person_id=dlrec->seq[dd.seq].person_id)
    AND o.order_status_cd IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd)
    AND o.catalog_type_cd=pharmacy_cattyp_cd
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag IN (1, 2))
   JOIN (do)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND ((od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RATE", "RATEUNIT",
   "RXROUTE")) OR (od.oe_field_meaning="OTHER"
    AND (od.oe_field_value=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=od.oe_field_value
     AND ((cv.code_set+ 0)=102202))))) )
  ORDER BY o.person_id, o.order_mnemonic, o.order_id,
   od.action_sequence
  HEAD o.person_id
   med_cnt = size(dlrec->seq[dd.seq].meds,5), stat = alterlist(dlrec->seq[dd.seq].meds,(med_cnt+ 10)),
   home_cnt = 0
  HEAD o.order_mnemonic
   row + 0
  HEAD o.order_id
   dose = " ", strength_dose = " ", freetext_dose = " ",
   volume_dose = " ", dose_unit = " ", strength_unit = " ",
   volume_unit = " ", rate = " ", rate_unit = " ",
   home_cnt = (home_cnt+ 1), med_cnt = (med_cnt+ 1)
   IF (mod(med_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].meds,(med_cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].meds[med_cnt].order_id = o.order_id, dlrec->seq[dd.seq].meds[med_cnt].type =
   med_type, dlrec->seq[dd.seq].meds[med_cnt].ioi = o.incomplete_order_ind,
   dlrec->seq[dd.seq].meds[med_cnt].mnemonic =
   IF (trim(o.order_mnemonic) > "") concat(trim(o.order_mnemonic),"|")
   ELSE concat(trim(o.ordered_as_mnemonic),"|")
   ENDIF
   , dlrec->seq[dd.seq].meds[med_cnt].date = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), dlrec->
   seq[dd.seq].meds[med_cnt].order_status_disp = uar_get_code_display(o.order_status_cd),
   dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_ind = o.need_rx_verify_ind
   CASE (o.need_rx_verify_ind)
    OF 0:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Verified)"
    OF 1:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Unverified)"
    OF 2:
     dlrec->seq[dd.seq].meds[med_cnt].need_rx_verify_str = "(Rejected)"
   ENDCASE
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    dlrec->seq[dd.seq].meds[med_cnt].freq = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATE")
    rate = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RATEUNIT")
    rate_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSE")
    dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    strength_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
    volume_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    freetext_dose = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    dose_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    strength_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    volume_unit = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="OTHER")
    dlrec->seq[dd.seq].meds[med_cnt].diluent = concat(trim(od.oe_field_display_value),"|")
   ELSEIF (od.oe_field_meaning="RXROUTE")
    dlrec->seq[dd.seq].meds[med_cnt].route = concat(trim(od.oe_field_display_value),"|")
   ENDIF
  FOOT  o.order_id
   IF (rate > " ")
    IF (rate_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].rate = concat(rate,rate_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].rate = rate
    ENDIF
   ENDIF
   IF (dose > " ")
    IF (dose_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].dose = concat(dose,dose_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].dose = concat(dose)
    ENDIF
   ENDIF
   IF (strength_dose > " ")
    IF (strength_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].strength_dose = concat(strength_dose,strength_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].strength_dose = concat(strength_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " ")
    IF (volume_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (volume_dose > " "
    AND strength_dose <= ""
    AND dose <= "")
    IF (volume_unit > " ")
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose,volume_unit)
    ELSE
     dlrec->seq[dd.seq].meds[med_cnt].volume_dose = concat(volume_dose)
    ENDIF
   ENDIF
   IF (freetext_dose > " ")
    dlrec->seq[dd.seq].meds[med_cnt].freetext_dose = concat(freetext_dose)
   ENDIF
  FOOT  o.order_mnemonic
   row + 0
  FOOT  o.person_id
   dlrec->seq[dd.seq].home_meds = home_cnt, dlrec->seq[dd.seq].total_meds = med_cnt, stat = alterlist
   (dlrec->seq[dd.seq].meds,med_cnt)
  WITH nocounter, outerjoin = do
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  ORDER BY encntr_id
  HEAD REPORT
   MACRO (line_wrap_indent)
    limit = 0, maxlen = wrapcol, cr = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", "|", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      IF (limit != 1)
       printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].
        med_line_cnt = (total_rows+ 10)
       ENDIF
       IF ((dlrec->seq[d1.seq].meds[mcnt].type=1))
        dlrec->seq[d1.seq].med_line[total_rows].column2 = concat(" ",printstring)
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=6))
        dlrec->seq[d1.seq].med_line[total_rows].column1 = concat(" ",printstring)
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=3))
        dlrec->seq[d1.seq].med_line[total_rows].column3 = concat(" ",printstring)
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=4))
        dlrec->seq[d1.seq].med_line[total_rows].column3 = concat(" ",printstring)
       ENDIF
      ELSEIF (limit=1)
       maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring), total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].
        med_line_cnt = (total_rows+ 10)
       ENDIF
       IF ((dlrec->seq[d1.seq].meds[mcnt].type=1))
        dlrec->seq[d1.seq].med_line[total_rows].column4 = printstring, dlrec->seq[d1.seq].med_line[
        total_rows].column2 = printstring
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=6))
        dlrec->seq[d1.seq].med_line[total_rows].column1 = printstring
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=3))
        dlrec->seq[d1.seq].med_line[total_rows].column3 = printstring
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=4))
        dlrec->seq[d1.seq].med_line[total_rows].column3 = printstring
       ENDIF
      ENDIF
      tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
  HEAD encntr_id
   total_med_rows = 0, total_rows = 0, max_total_rows = 0,
   save_total_rows = 0, med_string = "", stat = alterlist(dlrec->seq[d1.seq].med_line,10),
   dlrec->seq[d1.seq].med_line_cnt = 10
  DETAIL
   home_med_found = 0, total_rows = (total_rows+ 1)
   IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
    stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
     = (total_rows+ 10)
   ENDIF
   dlrec->seq[d1.seq].med_line[total_rows].column1 = "{b}{u}Home Meds"
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=6))
      home_med_found = 1, med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,
         dlrec->seq[d1.seq].meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,dlrec->seq[d1
         .seq].meds[mcnt].rate,dlrec->seq[d1.seq].meds[mcnt].strength_dose,
         dlrec->seq[d1.seq].meds[mcnt].volume_dose,dlrec->seq[d1.seq].meds[mcnt].diluent,dlrec->seq[
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0)
      IF (size(med_string) > 0
       AND size(med_string) <= 45)
       total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].
        med_line_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].med_line[total_rows].column1 = med_string
      ELSEIF (size(med_string) > 0)
       tempstring = med_string, wrapcol = 45, eol = size(tempstring),
       line_wrap_indent
      ENDIF
     ENDIF
   ENDFOR
   IF (home_med_found=0)
    total_rows = (total_rows+ 1)
    IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
     stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
      = (total_rows+ 10)
    ENDIF
    dlrec->seq[d1.seq].med_line[total_rows].column1 = "No Home meds found for encounter."
   ENDIF
   max_total_rows = total_rows, total_rows = 0, sched_med_found = 0,
   total_rows = (total_rows+ 1)
   IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
    stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
     = (total_rows+ 10)
   ENDIF
   dlrec->seq[d1.seq].med_line[total_rows].column2 = "{b}{u}Scheduled Meds"
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=1))
      sched_med_found = 1, med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,
         dlrec->seq[d1.seq].meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,dlrec->seq[d1
         .seq].meds[mcnt].rate,dlrec->seq[d1.seq].meds[mcnt].strength_dose,
         dlrec->seq[d1.seq].meds[mcnt].volume_dose,dlrec->seq[d1.seq].meds[mcnt].diluent,dlrec->seq[
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0)
      IF (size(med_string) > 0
       AND size(med_string) <= 45)
       total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].
        med_line_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].med_line[total_rows].column2 = med_string
      ELSEIF (size(med_string) > 0)
       tempstring = med_string, wrapcol = 45, eol = size(tempstring),
       line_wrap_indent
      ENDIF
     ENDIF
   ENDFOR
   IF (sched_med_found=0)
    total_rows = (total_rows+ 1)
    IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
     stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
      = (total_rows+ 10)
    ENDIF
    dlrec->seq[d1.seq].med_line[total_rows].column2 = "No Home meds found for encounter."
   ENDIF
   IF (total_rows > max_total_rows)
    max_total_rows = total_rows
   ENDIF
   total_rows = 0, prn_med_found = 0, total_rows = (total_rows+ 1)
   IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
    stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
     = (total_rows+ 10)
   ENDIF
   dlrec->seq[d1.seq].med_line[total_rows].column3 = "{b}{u}PRN Meds"
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=3))
      prn_med_found = 1, med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,
         dlrec->seq[d1.seq].meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,dlrec->seq[d1
         .seq].meds[mcnt].rate,dlrec->seq[d1.seq].meds[mcnt].strength_dose,
         dlrec->seq[d1.seq].meds[mcnt].volume_dose,dlrec->seq[d1.seq].meds[mcnt].diluent,dlrec->seq[
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0)
      IF (size(med_string) > 0
       AND size(med_string) <= 45)
       total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].
        med_line_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].med_line[total_rows].column3 = med_string
      ELSEIF (size(med_string) > 0)
       tempstring = med_string, wrapcol = 45, eol = size(tempstring),
       line_wrap_indent
      ENDIF
     ENDIF
   ENDFOR
   IF (prn_med_found=0)
    total_rows = (total_rows+ 1)
    IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
     stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
      = (total_rows+ 10)
    ENDIF
    dlrec->seq[d1.seq].med_line[total_rows].column3 = "No PRN meds found for encounter."
   ENDIF
   iv_med_found = 0, total_rows = (total_rows+ 1), dlrec->seq[d1.seq].med_line[total_rows].column3
   IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
    stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
     = (total_rows+ 10)
   ENDIF
   dlrec->seq[d1.seq].med_line[total_rows].column3 = "{b}{u}IV Fluids{endb}{endu}"
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=4))
      iv_med_found = 1, med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,dlrec
         ->seq[d1.seq].meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,substring(1,(
          findstring(".",dlrec->seq[d1.seq].meds[mcnt].rate,1,0)+ 2),dlrec->seq[d1.seq].meds[mcnt].
          rate),substring(findstring("m",dlrec->seq[d1.seq].meds[mcnt].rate,1,1),6,dlrec->seq[d1.seq]
          .meds[mcnt].rate),
         dlrec->seq[d1.seq].meds[mcnt].strength_dose,dlrec->seq[d1.seq].meds[mcnt].volume_dose,dlrec
         ->seq[d1.seq].meds[mcnt].diluent,dlrec->seq[d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].
         meds[mcnt].iv_prn,
         dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0)
      IF (size(med_string) > 0
       AND size(med_string) <= 45)
       total_rows = (total_rows+ 1)
       IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
        stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].
        med_line_cnt = (total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].med_line[total_rows].column3 = med_string
      ELSEIF (size(med_string) > 0)
       tempstring = trim(med_string), wrapcol = 45, eol = size(trim(tempstring)),
       line_wrap_indent
      ENDIF
     ENDIF
   ENDFOR
   IF (iv_med_found=0)
    total_rows = (total_rows+ 1)
    IF ((dlrec->seq[d1.seq].med_line_cnt=total_rows))
     stat = alterlist(dlrec->seq[d1.seq].med_line,(total_rows+ 10)), dlrec->seq[d1.seq].med_line_cnt
      = (total_rows+ 10)
    ENDIF
    dlrec->seq[d1.seq].med_line[total_rows].column3 = "No IV meds found for encounter."
   ENDIF
   IF (total_rows > max_total_rows)
    max_total_rows = total_rows
   ENDIF
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].med_line,max_total_rows), dlrec->seq[d1.seq].med_line_cnt =
   max_total_rows
  WITH nocounter
 ;end select
 EXECUTE bhs_incl_rounds_get_vital_io
 CALL get_vitals(0)
 SELECT INTO "nl:"
  event_display = uar_get_code_display(ce.event_cd), catalog_display = uar_get_code_display(ce
   .catalog_cd)
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o,
   clinical_event ce
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND o.activity_type_cd=gen_lab_cd)
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
    AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd, pending_cd))
    AND ce.result_val > " ")
  ORDER BY ce.encntr_id, catalog_display, ce.order_id DESC,
   ce.event_id
  HEAD ce.encntr_id
   lab_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].lab_results,10)
  HEAD catalog_display
   lab_cnt = (lab_cnt+ 1)
   IF (mod(lab_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].lab_results,(lab_cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].lab_results[lab_cnt].lab_header = concat("{b}{u}",substring(1,28,
     uar_get_code_display(ce.catalog_cd))), dlrec->seq[dd.seq].lab_results[lab_cnt].result_val =
   "HEADER"
  DETAIL
   most_recent_date = " ", most_recent_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), lab_cnt
    = (lab_cnt+ 1)
   IF (mod(lab_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].lab_results,(lab_cnt+ 10))
   ENDIF
   dlrec->seq[dd.seq].lab_results[lab_cnt].event_id = ce.event_id
   IF (size(trim(uar_get_code_display(ce.event_cd))) <= 15)
    dlrec->seq[dd.seq].lab_results[lab_cnt].event_cd_disp = uar_get_code_display(ce.event_cd)
   ELSE
    IF (trim(ce.result_val) <= ""
     AND trim(uar_get_code_display(ce.result_units_cd)) <= "")
     dlrec->seq[dd.seq].lab_results[lab_cnt].event_cd_disp = concat(substring(1,27,
       uar_get_code_display(ce.event_cd)),"...")
    ELSE
     dlrec->seq[dd.seq].lab_results[lab_cnt].event_cd_disp = concat(substring(1,12,
       uar_get_code_display(ce.event_cd)),"...")
    ENDIF
   ENDIF
   IF (trim(uar_get_code_display(ce.result_units_cd)) > " ")
    IF (size(trim(concat(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd))))) >
    15)
     dlrec->seq[dd.seq].lab_results[lab_cnt].result = substring(1,12,trim(concat(trim(ce.result_val),
        " ",trim(uar_get_code_display(ce.result_units_cd)),"...")))
    ELSE
     dlrec->seq[dd.seq].lab_results[lab_cnt].result = trim(concat(trim(ce.result_val)," ",trim(
        uar_get_code_display(ce.result_units_cd))))
    ENDIF
   ELSE
    IF (size(trim(ce.result_val)) > 15)
     dlrec->seq[dd.seq].lab_results[lab_cnt].result = concat(trim(substring(1,12,ce.result_val)),
      "...")
    ELSE
     dlrec->seq[dd.seq].lab_results[lab_cnt].result = trim(ce.result_val)
    ENDIF
   ENDIF
   dlrec->seq[dd.seq].lab_results[lab_cnt].date = format(ce.event_end_dt_tm,"mm/dd hh:mm;;d"), dlrec
   ->seq[dd.seq].lab_results[lab_cnt].most_recent_date = most_recent_date, dlrec->seq[dd.seq].
   lab_results[lab_cnt].normalcy_disp = trim(uar_get_code_display(ce.normalcy_cd)),
   dlrec->seq[dd.seq].lab_results[lab_cnt].result_val = trim(ce.result_val)
  FOOT  ce.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].lab_results,lab_cnt), dlrec->seq[dd.seq].total_lab_results =
   lab_cnt
  WITH nocounter
 ;end select
 SET limit = 0
 FOR (x = 1 TO dlrec->encntr_total)
   FOR (y = 1 TO dlrec->seq[x].total_lab_results)
     SET tempstring = " "
     SET maxlen = 0
     SET current_result_ok = 1
     SET next_result_ok = 1
     IF (trim(dlrec->seq[x].lab_results[y].result_val) > " "
      AND ((y+ 1) <= dlrec->seq[x].total_lab_results)
      AND trim(dlrec->seq[x].lab_results[(y+ 1)].result_val) > " ")
      SET tempstring = trim(dlrec->seq[x].lab_results[y].result_val)
      SET maxlen = size(trim(dlrec->seq[x].lab_results[y].result_val))
      WHILE (tempstring > " "
       AND current_result_ok=1
       AND limit < 1000)
        SET ii = 0
        SET limit = (limit+ 1)
        SET pos = 0
        WHILE (pos=0
         AND current_result_ok=1)
          SET ii = (ii+ 1)
          IF (ichar(substring((maxlen - ii),1,tempstring)) BETWEEN 58 AND 122)
           SET current_result_ok = 2
          ELSEIF (ii=maxlen)
           SET pos = maxlen
          ENDIF
          SET tempstring = substring((pos+ 1),maxlen,tempstring)
        ENDWHILE
      ENDWHILE
      SET tempstring = trim(dlrec->seq[x].lab_results[(y+ 1)].result_val)
      SET maxlen = size(trim(dlrec->seq[x].lab_results[(y+ 1)].result_val))
      WHILE (tempstring > " "
       AND next_result_ok=1
       AND limit < 1000)
        SET ii = 0
        SET limit = (limit+ 1)
        SET pos = 0
        WHILE (pos=0
         AND next_result_ok=1)
          SET ii = (ii+ 1)
          IF (ichar(substring((maxlen - ii),1,tempstring)) BETWEEN 58 AND 122)
           SET next_result_ok = 2
          ELSEIF (ii=maxlen)
           SET pos = maxlen
          ENDIF
          SET tempstring = substring((pos+ 1),maxlen,tempstring)
        ENDWHILE
      ENDWHILE
      IF (current_result_ok=1
       AND next_result_ok=1)
       SET current_display = dlrec->seq[x].lab_results[y].event_cd_disp
       SET next_display = dlrec->seq[x].lab_results[(y+ 1)].event_cd_disp
       IF (next_display=current_display)
        SET diff_between = abs((cnvtreal(dlrec->seq[x].lab_results[(y+ 1)].result_val) - cnvtreal(
          dlrec->seq[x].lab_results[y].result_val)))
        SET current_05 = (cnvtreal(dlrec->seq[x].lab_results[y].result_val) * 000.05)
        IF (diff_between > current_05)
         SET dlrec->seq[x].lab_results[(y+ 1)].normalcy_disp = concat(dlrec->seq[x].lab_results[(y+ 1
          )].normalcy_disp," *")
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  WHERE (dlrec->seq[d1.seq].total_lab_results > 0)
  HEAD encntr_id
   total_lab_rows = 0, total_rows = 0, save_total_rows = 0,
   lab_string = " "
  DETAIL
   total_lab_rows = cnvtint((dlrec->seq[d1.seq].total_lab_results/ 3.0))
   IF (mod(dlrec->seq[d1.seq].total_lab_results,3) != 0)
    total_lab_rows = cnvtint(((dlrec->seq[d1.seq].total_lab_results/ 3)+ 1))
   ENDIF
   FOR (lcnt = 1 TO dlrec->seq[d1.seq].total_lab_results)
     IF (lcnt <= total_lab_rows)
      header_swt = dlrec->seq[d1.seq].lab_results[lcnt].result_val
      IF (header_swt != "HEADER")
       lab_string = concat(dlrec->seq[d1.seq].lab_results[lcnt].date," ",dlrec->seq[d1.seq].
        lab_results[lcnt].event_cd_disp," ",trim(dlrec->seq[d1.seq].lab_results[lcnt].result))
      ELSE
       lab_string = dlrec->seq[d1.seq].lab_results[lcnt].lab_header
      ENDIF
      total_rows = (total_rows+ 1), stat = alterlist(dlrec->seq[d1.seq].lab_line,total_rows), dlrec->
      seq[d1.seq].lab_line_cnt = total_rows
      IF (trim(dlrec->seq[d1.seq].lab_results[lcnt].normalcy_disp) IN ("C", "C *", "H", "H *", "L",
      "L *"))
       dlrec->seq[d1.seq].lab_line[total_rows].column1 = concat("{b}",lab_string," ",dlrec->seq[d1
        .seq].lab_results[lcnt].normalcy_disp)
      ELSE
       dlrec->seq[d1.seq].lab_line[total_rows].column1 = concat(lab_string," ",dlrec->seq[d1.seq].
        lab_results[lcnt].normalcy_disp)
      ENDIF
     ENDIF
   ENDFOR
   total_rows = 0
   FOR (lcnt = 1 TO dlrec->seq[d1.seq].total_lab_results)
     IF (lcnt > total_lab_rows
      AND (lcnt <= (total_lab_rows * 2)))
      header_swt = dlrec->seq[d1.seq].lab_results[lcnt].result_val
      IF (header_swt != "HEADER")
       lab_string = concat(dlrec->seq[d1.seq].lab_results[lcnt].date," ",dlrec->seq[d1.seq].
        lab_results[lcnt].event_cd_disp," ",trim(dlrec->seq[d1.seq].lab_results[lcnt].result))
      ELSE
       lab_string = dlrec->seq[d1.seq].lab_results[lcnt].lab_header
      ENDIF
      total_rows = (total_rows+ 1)
      IF (trim(dlrec->seq[d1.seq].lab_results[lcnt].normalcy_disp) IN ("C", "C *", "H", "H *", "L",
      "L *"))
       dlrec->seq[d1.seq].lab_line[total_rows].column2 = concat("{b}",lab_string," ",dlrec->seq[d1
        .seq].lab_results[lcnt].normalcy_disp)
      ELSE
       dlrec->seq[d1.seq].lab_line[total_rows].column2 = concat(lab_string," ",dlrec->seq[d1.seq].
        lab_results[lcnt].normalcy_disp)
      ENDIF
     ENDIF
   ENDFOR
   total_rows = 0
   FOR (lcnt = 1 TO dlrec->seq[d1.seq].total_lab_results)
     IF ((lcnt > (total_lab_rows * 2))
      AND (lcnt <= (total_lab_rows * 3)))
      header_swt = dlrec->seq[d1.seq].lab_results[lcnt].result_val
      IF (header_swt != "HEADER")
       lab_string = concat(dlrec->seq[d1.seq].lab_results[lcnt].date," ",dlrec->seq[d1.seq].
        lab_results[lcnt].event_cd_disp," ",trim(dlrec->seq[d1.seq].lab_results[lcnt].result))
      ELSE
       lab_string = dlrec->seq[d1.seq].lab_results[lcnt].lab_header
      ENDIF
      total_rows = (total_rows+ 1)
      IF (trim(dlrec->seq[d1.seq].lab_results[lcnt].normalcy_disp) IN ("C", "C *", "H", "H *", "L",
      "L *"))
       dlrec->seq[d1.seq].lab_line[total_rows].column3 = concat("{b}",lab_string," ",dlrec->seq[d1
        .seq].lab_results[lcnt].normalcy_disp)
      ELSE
       dlrec->seq[d1.seq].lab_line[total_rows].column3 = concat(lab_string," ",dlrec->seq[d1.seq].
        lab_results[lcnt].normalcy_disp)
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_order =
  IF (o.catalog_cd IN (cath_foley_cd, cath_foley_3_cd, cath_care_cd, cath_coude_cd, cath_texas_cd,
  cath_suprap_cd, cathetersinglelumenindwellingurinary_var)) 1
  ELSEIF (o.hna_order_mnemonic="Heparin") 2
  ELSEIF (o.hna_order_mnemonic IN ("Enoxaparin", "Warfarin")) 3
  ELSEIF (o.hna_order_mnemonic="Anti-Embolism Stockings") 4
  ELSEIF (o.hna_order_mnemonic="Pneumatic Compression Boots") 5
  ELSEIF (o.activity_type_cd=restraint_cd) 6
  ELSE 7
  ENDIF
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND ((o.activity_type_cd IN (micro_cd, blood_bank_cd, radiology_cd)
    AND o.current_start_dt_tm >= cnvtdatetime((curdate - 3),curtime)) OR (((o.activity_type_cd=
   restraint_cd
    AND ((o.order_status_cd+ 0)=o_ordered_cd)) OR (o.catalog_cd IN (heparin_cd, enoxaparin_cd,
   warfarin_cd, cath_foley_cd, cath_foley_3_cd,
   cath_care_cd, cath_coude_cd, cath_texas_cd, cath_suprap_cd, boots_cd,
   stockings_cd, cathetersinglelumenindwellingurinary_var)
    AND ((o.order_status_cd+ 0)=o_ordered_cd))) ))
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.encntr_id, sort_order, o.orig_order_dt_tm DESC,
   o.hna_order_mnemonic
  HEAD o.encntr_id
   micro_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].micro_orders,10), blood_bank_cnt = 0,
   stat = alterlist(dlrec->seq[dd.seq].blood_bank_orders,10), ord_cnt = 0, stat = alterlist(dlrec->
    seq[dd.seq].orders,10),
   rad_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].rad_orders,10)
  HEAD sort_order
   row + 0
  HEAD o.orig_order_dt_tm
   row + 0
  HEAD o.hna_order_mnemonic
   IF ( NOT (o.activity_type_cd IN (micro_cd, blood_bank_cd, radiology_cd)))
    ord_cnt = (ord_cnt+ 1)
    IF (mod(ord_cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].orders,(ord_cnt+ 10))
    ENDIF
    IF (o.catalog_cd IN (cath_foley_cd, cath_foley_3_cd, cath_care_cd, cath_coude_cd, cath_texas_cd,
    cath_suprap_cd, cathetersinglelumenindwellingurinary_var))
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "catheter", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Heparin")
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "heparin", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Enoxaparin")
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "Enoxaparin", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Warfarin")
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "Warfarin", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic IN ("Pneumatic Compression Boots", "Anti-Embolism Stockings"))
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "compression device", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.activity_type_cd=restraint_cd)
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "restraint", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ENDIF
   ENDIF
  DETAIL
   IF (o.activity_type_cd=micro_cd)
    micro_cnt = (micro_cnt+ 1)
    IF (mod(micro_cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].micro_orders,(micro_cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].micro_orders[micro_cnt].order_id = o.order_id, dlrec->seq[dd.seq].
    micro_orders[micro_cnt].order_date = format(o.orig_order_dt_tm,"mm/dd hh:mm;;d")
    IF (size(trim(o.hna_order_mnemonic)) <= 40)
     dlrec->seq[dd.seq].micro_orders[micro_cnt].orderable = trim(o.hna_order_mnemonic)
    ELSE
     dlrec->seq[dd.seq].micro_orders[micro_cnt].orderable = concat(substring(1,37,o
       .hna_order_mnemonic),"...")
    ENDIF
    IF (size(trim(uar_get_code_display(o.order_status_cd))) <= 12)
     dlrec->seq[dd.seq].micro_orders[micro_cnt].order_status = trim(uar_get_code_display(o
       .order_status_cd))
    ELSE
     dlrec->seq[dd.seq].micro_orders[micro_cnt].order_status = concat(substring(1,9,
       uar_get_code_display(o.order_status_cd)),"...")
    ENDIF
   ELSEIF (o.activity_type_cd=blood_bank_cd)
    blood_bank_cnt = (blood_bank_cnt+ 1)
    IF (mod(blood_bank_cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].blood_bank_orders,(blood_bank_cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].blood_bank_orders[blood_bank_cnt].order_id = o.order_id, dlrec->seq[dd.seq].
    blood_bank_orders[blood_bank_cnt].order_date = format(o.orig_order_dt_tm,"mm/dd hh:mm;;d")
    IF (size(trim(o.hna_order_mnemonic)) <= 40)
     dlrec->seq[dd.seq].blood_bank_orders[blood_bank_cnt].orderable = trim(o.hna_order_mnemonic)
    ELSE
     dlrec->seq[dd.seq].blood_bank_orders[blood_bank_cnt].orderable = concat(substring(1,37,o
       .hna_order_mnemonic),"...")
    ENDIF
    IF (size(trim(uar_get_code_display(o.order_status_cd))) <= 12)
     dlrec->seq[dd.seq].blood_bank_orders[blood_bank_cnt].order_status = trim(uar_get_code_display(o
       .order_status_cd))
    ELSE
     dlrec->seq[dd.seq].blood_bank_orders[blood_bank_cnt].order_status = concat(substring(1,9,
       uar_get_code_display(o.order_status_cd)),"...")
    ENDIF
   ELSEIF (o.activity_type_cd=radiology_cd)
    rad_cnt = (rad_cnt+ 1)
    IF (mod(rad_cnt,10)=1)
     stat = alterlist(dlrec->seq[dd.seq].rad_orders,(rad_cnt+ 10))
    ENDIF
    dlrec->seq[dd.seq].rad_orders[rad_cnt].order_id = o.order_id, dlrec->seq[dd.seq].rad_orders[
    rad_cnt].order_date = format(o.orig_order_dt_tm,"mm/dd hh:mm;;d")
    IF (size(trim(o.hna_order_mnemonic)) <= 40)
     dlrec->seq[dd.seq].rad_orders[rad_cnt].orderable = trim(o.hna_order_mnemonic)
    ELSE
     dlrec->seq[dd.seq].rad_orders[rad_cnt].orderable = concat(substring(1,37,o.hna_order_mnemonic),
      "...")
    ENDIF
    IF (size(trim(uar_get_code_display(o.order_status_cd))) <= 12)
     dlrec->seq[dd.seq].rad_orders[rad_cnt].order_status = trim(uar_get_code_display(o
       .order_status_cd))
    ELSE
     dlrec->seq[dd.seq].rad_orders[rad_cnt].order_status = concat(substring(1,9,uar_get_code_display(
        o.order_status_cd)),"...")
    ENDIF
   ENDIF
  FOOT  o.hna_order_mnemonic
   row + 0
  FOOT  o.orig_order_dt_tm
   row + 0
  FOOT  sort_order
   row + 0
  FOOT  o.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].micro_orders,micro_cnt), dlrec->seq[dd.seq].micro_labs =
   micro_cnt, stat = alterlist(dlrec->seq[dd.seq].blood_bank_orders,blood_bank_cnt),
   dlrec->seq[dd.seq].blood_bank_labs = blood_bank_cnt, stat = alterlist(dlrec->seq[dd.seq].orders,
    ord_cnt), dlrec->seq[dd.seq].total_orders = ord_cnt,
   stat = alterlist(dlrec->seq[dd.seq].rad_orders,rad_cnt), dlrec->seq[dd.seq].rad_count = rad_cnt
  WITH nocounter
 ;end select
 SET total_immunization = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total)),
   clinical_event ce
  PLAN (d1)
   JOIN (ce
   WHERE (ce.person_id=dlrec->seq[d1.seq].person_id)
    AND (ce.encntr_id=dlrec->seq[d1.seq].encntr_id)
    AND ce.event_cd=influenza_cd)
  ORDER BY ce.person_id, ce.order_id
  HEAD ce.person_id
   imz_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].immunization,10)
  HEAD ce.encntr_id
   imz_cnt = (imz_cnt+ 1)
   IF (mod(imz_cnt,10)=1)
    stat = alterlist(dlrec->seq[d1.seq].immunization,(imz_cnt+ 9))
   ENDIF
   dlrec->seq[d1.seq].immunization[imz_cnt].immunization_name = trim(ce.result_val,3)
  FOOT  ce.person_id
   stat = alterlist(dlrec->seq[d1.seq].immunization,imz_cnt), dlrec->seq[d1.seq].total_immunization
    = (total_immunization+ imz_cnt)
  WITH nocounter
 ;end select
 SET total_screening = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total)),
   clinical_event ce
  PLAN (d1)
   JOIN (ce
   WHERE (ce.person_id=dlrec->seq[d1.seq].person_id)
    AND (ce.encntr_id=dlrec->seq[d1.seq].encntr_id)
    AND ce.event_cd=smoking_cd)
  ORDER BY ce.person_id, ce.order_id
  HEAD ce.person_id
   scr_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].screening,10)
  HEAD ce.encntr_id
   scr_cnt = (scr_cnt+ 1)
   IF (mod(scr_cnt,10)=1)
    stat = alterlist(dlrec->seq[d1.seq].screening,(scr_cnt+ 9))
   ENDIF
   dlrec->seq[d1.seq].screening[scr_cnt].screening_name = trim(ce.result_val,3)
  FOOT  ce.person_id
   stat = alterlist(dlrec->seq[d1.seq].screening,scr_cnt), dlrec->seq[d1.seq].total_screening = (
   total_screening+ scr_cnt)
  WITH nocounter
 ;end select
 SET total_quit = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total)),
   clinical_event ce
  PLAN (d1)
   JOIN (ce
   WHERE (ce.person_id=dlrec->seq[d1.seq].person_id)
    AND (ce.encntr_id=dlrec->seq[d1.seq].encntr_id)
    AND ce.event_cd=quitsmoking_cd)
  ORDER BY ce.person_id, ce.order_id
  HEAD ce.person_id
   qt_cnt = 0, stat = alterlist(dlrec->seq[d1.seq].quit,10)
  HEAD ce.encntr_id
   qt_cnt = (qt_cnt+ 1)
   IF (mod(qt_cnt,10)=1)
    stat = alterlist(dlrec->seq[d1.seq].quit,(qt_cnt+ 9))
   ENDIF
   dlrec->seq[d1.seq].quit[qt_cnt].quit_name = trim(ce.result_val,3)
  FOOT  ce.person_id
   stat = alterlist(dlrec->seq[d1.seq].quit,qt_cnt), dlrec->seq[d1.seq].total_quit = (total_quit+
   qt_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   (dummyt d  WITH seq = value(dlrec->encntr_total))
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[d.seq].encntr_id)
    AND o.activity_type_cd=code_status_cd
    AND ((o.order_status_cd+ 0)=o_ordered_cd))
   JOIN (od
   WHERE od.order_id=outerjoin(o.order_id)
    AND od.oe_field_id=outerjoin(od_limited_cd))
  ORDER BY o.encntr_id, o.order_id, od.action_sequence DESC
  HEAD REPORT
   ord_cnt = 0
  HEAD o.encntr_id
   row + 0
  HEAD o.order_id
   ord_cnt = (size(dlrec->seq[d.seq].orders,5)+ 1), stat = alterlist(dlrec->seq[d.seq].orders,ord_cnt
    ), dlrec->seq[d.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic)
   IF (od.detail_sequence > 0)
    dlrec->seq[d.seq].orders[ord_cnt].orderable = concat(dlrec->seq[d.seq].orders[ord_cnt].orderable,
     " (",trim(od.oe_field_display_value),")")
   ENDIF
  FOOT  o.encntr_id
   dlrec->seq[d.seq].total_orders = ord_cnt
  WITH nocounter
 ;end select
 CALL get_io(0)
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[dd.seq].encntr_id
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   sticky_note sn,
   prsnl p
  PLAN (dd)
   JOIN (sn
   WHERE sn.parent_entity_name="PERSON"
    AND (sn.parent_entity_id=dlrec->seq[dd.seq].person_id)
    AND ((sn.sticky_note_type_cd=sticky_note_cd) OR (sn.sticky_note_type_cd=rounds_note_cd
    AND sn.public_ind=1))
    AND sn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=sn.updt_id)
  ORDER BY sn.parent_entity_id, encntr_id, sn.beg_effective_dt_tm DESC
  HEAD sn.parent_entity_id
   row + 0
  HEAD encntr_id
   sn_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].sticky_notes,5)
  DETAIL
   sn_cnt = (sn_cnt+ 1)
   IF (mod(sn_cnt,5)=1)
    stat = alterlist(dlrec->seq[dd.seq].sticky_notes,(sn_cnt+ 4))
   ENDIF
   dlrec->seq[dd.seq].sticky_notes[sn_cnt].notes = trim(sn.sticky_note_text), dlrec->seq[dd.seq].
   sticky_notes[sn_cnt].note_date = format(sn.beg_effective_dt_tm,"mm/dd/yyyy hh:mm;;d"), dlrec->seq[
   dd.seq].sticky_notes[sn_cnt].prsnl_name = trim(p.name_full_formatted)
  FOOT  encntr_id
   dlrec->seq[dd.seq].total_sticky_notes = sn_cnt, stat = alterlist(dlrec->seq[dd.seq].sticky_notes,
    sn_cnt)
  FOOT  sn.parent_entity_id
   row + 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dlrec->encntr_total)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[d.seq].encntr_id)
    AND o.activity_type_cd IN (tube_continuous_cd, infant_formula_cd, infant_formula_add_cd,
   tube_feeding_add_cd, tube_feeding_bolus_cd,
   supplements_cd, diets_cd)
    AND ((o.order_status_cd+ 0)=o_ordered_cd)
    AND o.template_order_flag IN (0, 1))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   diet_cnt = 0
  DETAIL
   diet_cnt = (diet_cnt+ 1)
   IF (mod(diet_cnt,10)=1)
    stat = alterlist(dlrec->seq[d.seq].diets,(diet_cnt+ 9))
   ENDIF
   dlrec->seq[d.seq].diets[diet_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[d.seq].
   diets[diet_cnt].clinical_display_line = trim(o.clinical_display_line,3), dlrec->seq[d.seq].diets[
   diet_cnt].date = format(o.orig_order_dt_tm,"MM/DD/YYYY;;D")
  FOOT  o.encntr_id
   stat = alterlist(dlrec->seq[d.seq].diets,diet_cnt)
  WITH nocounter
 ;end select
 SET encntrcnt = 0
 SELECT INTO value(printer_disp)
  facility = dlrec->seq[d1.seq].facility, building = dlrec->seq[d1.seq].building, location = dlrec->
  seq[d1.seq].location,
  room_bed = dlrec->seq[d1.seq].room_bed, fac_loc =
  IF (textlen(trim(concat(trim(dlrec->seq[d1.seq].facility),"/",trim(dlrec->seq[d1.seq].location)," ",
     trim(dlrec->seq[d1.seq].room_bed)))) > 15) concat(substring(1,15,trim(concat(trim(dlrec->seq[d1
        .seq].location)," ",trim(dlrec->seq[d1.seq].room_bed)))),"-")
  ELSE trim(concat(trim(dlrec->seq[d1.seq].location)," ",trim(dlrec->seq[d1.seq].room_bed)))
  ENDIF
  , dob_age = concat(dlrec->seq[d1.seq].dob,"(",dlrec->seq[d1.seq].age,")"),
  admit_day = concat(dlrec->seq[d1.seq].admit_dt,"(",dlrec->seq[d1.seq].los,")"), encntr_id = dlrec->
  seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  ORDER BY facility, building, location,
   room_bed, encntr_id
  HEAD REPORT
   line = fillstring(200,"-"), line_short = fillstring(125,"-"), xcol = 0,
   ycol = 0, save_ycol = 0, end_ycol = 0,
   MACRO (line_wrap)
    limit = 0, maxlen = wrapcol, cr = char(13)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring),
      CALL print(calcpos(xcol,ycol)), printstring,
      ycol = (ycol+ 8), row + 1, tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
   ,
   MACRO (line_wrap_indent)
    limit = 0, maxlen = wrapcol, cr = char(13),
    lf = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ","))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring), lfloc = findstring(lf,printstring), crloc =
      findstring(cr,printstring)
      IF (lfloc=0
       AND crloc=0)
       CALL print(calcpos(xcol,ycol)), printstring, row + 1
       IF (limit=1)
        maxlen = (maxlen - 2), xcol = (xcol+ 5)
       ENDIF
       ycol = (ycol+ 8), tempstring = substring((pos+ 1),9999,tempstring)
      ELSE
       IF (((crloc < lfloc
        AND crloc > 0) OR (lfloc=0)) )
        printstring = substring(1,(crloc - 1),printstring),
        CALL print(calcpos(xcol,ycol)), printstring,
        row + 1
        IF (limit=1)
         maxlen = (maxlen - 2), xcol = (xcol+ 5)
        ENDIF
        ycol = (ycol+ 8), tempstring = substring((crloc+ 1),9999,tempstring)
       ELSEIF (((lfloc < crloc
        AND lfloc > 0) OR (crloc=0)) )
        printstring = substring(1,(lfloc - 1),printstring),
        CALL print(calcpos(xcol,ycol)), printstring,
        row + 1
        IF (limit=1)
         maxlen = (maxlen - 2), xcol = (xcol+ 5)
        ENDIF
        ycol = (ycol+ 8), tempstring = substring((lfloc+ 1),9999,tempstring)
       ENDIF
       WHILE (substring(1,1,tempstring) IN (" ", cr, lf)
        AND size(tempstring) > 0)
         tempstring = substring(2,9999,tempstring)
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDMACRO
   , "{f/0}{cpi/18}",
   ycol = 30, xcol = 30,
   CALL print(calcpos(xcol,ycol)),
   "*** Baystate Rounds Report v2 ***", xcol = 215,
   CALL print(calcpos(xcol,ycol)),
   "Printed on: ", printed_on, xcol = 400,
   CALL print(calcpos(xcol,ycol)), "Printed by: ", printed_by,
   ycol = (ycol+ 8), row + 1
  HEAD PAGE
   "{f/0}{cpi/18}", ycol = 38, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), line,
   ycol = (ycol+ 8), row + 1, xcol = 30,
   CALL print(calcpos(xcol,ycol)), "{b}", "Location",
   xcol = 100,
   CALL print(calcpos(xcol,ycol)), "{b}",
   "Name", xcol = 215,
   CALL print(calcpos(xcol,ycol)),
   "{b}", "MR", xcol = 265,
   CALL print(calcpos(xcol,ycol)), "{b}", "DOB(age)",
   xcol = 325,
   CALL print(calcpos(xcol,ycol)), "{b}",
   "Admit date(Day)", xcol = 400,
   CALL print(calcpos(xcol,ycol)),
   "{b}", "Attending", xcol = 500,
   CALL print(calcpos(xcol,ycol)), "{b}", "PCP",
   ycol = (ycol+ 8), row + 1, xcol = 30,
   CALL print(calcpos(xcol,ycol)), "{endb}", line,
   ycol = (ycol+ 8), row + 1, xcol = 30,
   row + 1,
   CALL print(calcpos(xcol,ycol)), fac_loc,
   xcol = 100, row + 1,
   CALL print(calcpos(xcol,ycol)),
   dlrec->seq[d1.seq].patient_name, xcol = 215, row + 1,
   CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].mrn, xcol = 265,
   row + 1,
   CALL print(calcpos(xcol,ycol)), dob_age,
   xcol = 325, row + 1,
   CALL print(calcpos(xcol,ycol)),
   admit_day, xcol = 400, row + 1,
   CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].attenddoc_name, xcol = 500,
   row + 1,
   CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].pcp_name
   IF (textlen(trim(dlrec->seq[d1.seq].casemanager,3)) > 0)
    ycol = (ycol+ 8), row + 1, row + 1,
    CALL print(calcpos(215,ycol)), "{b}", "Case Manager: ",
    "{endb}", row + 1,
    CALL print(calcpos(270,ycol)),
    dlrec->seq[d1.seq].casemanager
   ENDIF
   IF (size(dlrec->seq[d1.seq].nurse_qual,5) > 0)
    IF (textlen(trim(dlrec->seq[d1.seq].casemanager,3)) <= 0)
     ycol = (ycol+ 8), row + 1
    ENDIF
    CALL print(calcpos(400,ycol)), "{b}", "Nurse(s): ",
    "{endb}"
    FOR (nursecnt = 1 TO size(dlrec->seq[d1.seq].nurse_qual,5))
      IF (nursecnt > 1)
       ycol = (ycol+ 8), row + 1
      ENDIF
      CALL print(calcpos(440,ycol)), dlrec->seq[d1.seq].nurse_qual[nursecnt].nurse
    ENDFOR
   ENDIF
   headerprinted = 1, ycol = (ycol+ 8), row + 1
  HEAD encntr_id
   encntrcnt = (encntrcnt+ 1)
   IF ((ycol > (725 - 48)))
    BREAK
   ELSEIF (ycol != 30
    AND ycol != 78
    AND headerprinted=0)
    "{f/0}{cpi/18}", ycol = (ycol+ 8), row + 1,
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    line, ycol = (ycol+ 8), row + 1,
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{b}",
    "Location", xcol = 100,
    CALL print(calcpos(xcol,ycol)),
    "{b}", "Name", xcol = 215,
    CALL print(calcpos(xcol,ycol)), "{b}", "MR",
    xcol = 265,
    CALL print(calcpos(xcol,ycol)), "{b}",
    "DOB(age)", xcol = 325,
    CALL print(calcpos(xcol,ycol)),
    "{b}", "Admit date(Day)", xcol = 400,
    CALL print(calcpos(xcol,ycol)), "{b}", "Attending",
    xcol = 500,
    CALL print(calcpos(xcol,ycol)), "{b}",
    "PCP", ycol = (ycol+ 8), row + 1,
    xcol = 30,
    CALL print(calcpos(xcol,ycol)), "{endb}",
    line, ycol = (ycol+ 8), row + 1,
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    fac_loc, xcol = 100, row + 1,
    CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].patient_name, xcol = 215,
    row + 1,
    CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].mrn,
    xcol = 265, row + 1,
    CALL print(calcpos(xcol,ycol)),
    dob_age, xcol = 325, row + 1,
    CALL print(calcpos(xcol,ycol)), admit_day, xcol = 400,
    row + 1,
    CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].attenddoc_name,
    xcol = 500, row + 1,
    CALL print(calcpos(xcol,ycol)),
    dlrec->seq[d1.seq].pcp_name
    IF ((dlrec->seq[d1.seq].chestpainobs=1))
     ycol = (ycol+ 8), row + 1, row + 1,
     CALL print(calcpos(30,ycol)), chestpainobs_str
    ENDIF
    ycol = (ycol+ 8), row + 1, row + 1,
    CALL print(calcpos(215,ycol)), "{b}", "Case Manager: ",
    "{endb}"
    IF (textlen(trim(dlrec->seq[d1.seq].casemanager,3)) > 0)
     row + 1,
     CALL print(calcpos(270,ycol)), dlrec->seq[d1.seq].casemanager
    ENDIF
    CALL print(calcpos(400,ycol)), "{b}", "Nurse(s): ",
    "{endb}"
    IF (size(dlrec->seq[d1.seq].nurse_qual,5) > 0)
     FOR (nursecnt = 1 TO size(dlrec->seq[d1.seq].nurse_qual,5))
       IF (nursecnt > 1)
        ycol = (ycol+ 8), row + 1
       ENDIF
       CALL print(calcpos(440,ycol)), dlrec->seq[d1.seq].nurse_qual[nursecnt].nurse
     ENDFOR
    ENDIF
    headerprinted = 1, ycol = (ycol+ 8), row + 1
   ENDIF
   headerprinted = 0
   IF ((dlrec->seq[d1.seq].total_vitals > 0))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}Temp {endb}", dlrec->seq[d1.seq].vitals[1].temp_result, "(",
    dlrec->seq[d1.seq].vitals[1].temp_range, "), ", "{b}Pulse {endb}",
    dlrec->seq[d1.seq].vitals[1].pulse_result, "(", dlrec->seq[d1.seq].vitals[1].pulse_range,
    "), ", "{b}BP {endb}", dlrec->seq[d1.seq].vitals[1].systolic_bp_result,
    "/", dlrec->seq[d1.seq].vitals[1].diastolic_bp_result, "(",
    dlrec->seq[d1.seq].vitals[1].systolic_bp_range, "/", dlrec->seq[d1.seq].vitals[1].
    diastolic_bp_range,
    "), ", "{b}Respiratory Rate {endb}", dlrec->seq[d1.seq].vitals[1].resp_rate_result,
    "(", dlrec->seq[d1.seq].vitals[1].resp_rate_range, "), ",
    "{b}O2 Sat {endb}", dlrec->seq[d1.seq].vitals[1].o2_sat_result, "%(",
    dlrec->seq[d1.seq].vitals[1].o2_sat_range, "%)", " (",
    dlrec->seq[d1.seq].vitals[1].liters_per_min, "L ", dlrec->seq[d1.seq].vitals[1].mode_of_delivery,
    ")", ycol = (ycol+ 8), row + 1
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No vitals found in last 24 hours", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 32)))
    BREAK
   ENDIF
   IF ((((dlrec->seq[d1.seq].intake_line_cnt > 0)) OR ((dlrec->seq[d1.seq].output_line_cnt > 0))) )
    xcol = 60, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "{b}12hr", xcol = 285, row + 1,
    CALL print(calcpos(xcol,ycol)), "{b}24hr"
    IF (size(dlrec->seq[d1.seq].weights,5) > 0)
     print_weight = trim(format(dlrec->seq[d1.seq].weight_change,"##.##")), total_delta = dlrec->seq[
     d1.seq].weight_up_down, saved_units = dlrec->seq[d1.seq].weights,
     xcol = 500, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}{u}Weights ", total_delta, print_weight,
     saved_units, first_weight = 000.00, last_weight = 000.00,
     total_weight = 00.00, total_delta = " NONE"
    ELSE
     xcol = 500, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Weights Charted"
    ENDIF
    ycol = (ycol+ 8), row + 1, weight_cnt = 0
    IF ((dlrec->seq[d1.seq].intake_line_cnt > 0))
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}In{endb}"
     FOR (lcnt = 1 TO dlrec->seq[d1.seq].intake_line_cnt)
       IF (ycol > 725)
        BREAK
       ENDIF
       IF (lcnt=1)
        IF ((dlrec->seq[d1.seq].intake_line[lcnt].column1 <= ""))
         xcol = 60, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "No Intake found in the last 12 hours."
        ELSE
         xcol = 60, row + 1,
         CALL print(calcpos(xcol,ycol)),
         dlrec->seq[d1.seq].intake_line[lcnt].column1
        ENDIF
        IF ((dlrec->seq[d1.seq].intake_line[lcnt].column2 <= ""))
         xcol = 285, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "No Intake found in the last 24 hours."
        ELSE
         xcol = 285, row + 1,
         CALL print(calcpos(xcol,ycol)),
         dlrec->seq[d1.seq].intake_line[lcnt].column2
        ENDIF
       ELSE
        xcol = 60, row + 1,
        CALL print(calcpos(xcol,ycol)),
        dlrec->seq[d1.seq].intake_line[lcnt].column1, xcol = 285, row + 1,
        CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].intake_line[lcnt].column2
       ENDIF
       IF (weight_cnt < size(dlrec->seq[d1.seq].weights,5))
        weight_cnt = (weight_cnt+ 1), xcol = 500, row + 1,
        CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].weights[weight_cnt].weight_dt_tm, " ",
        dlrec->seq[d1.seq].weights[weight_cnt].weight_value, " ", dlrec->seq[d1.seq].weights[
        weight_cnt].weight_unit
       ENDIF
       ycol = (ycol+ 8), row + 1
     ENDFOR
    ELSE
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}In{endb}", xcol = 60, row + 1,
     CALL print(calcpos(xcol,ycol)), "No Intake found in the last 12 hours.", xcol = 285,
     row + 1,
     CALL print(calcpos(xcol,ycol)), "No Intake found in the last 24 hours."
     IF (weight_cnt < size(dlrec->seq[d1.seq].weights,5))
      weight_cnt = (weight_cnt+ 1), xcol = 500, row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].weights[weight_cnt].weight_dt_tm, " ",
      dlrec->seq[d1.seq].weights[weight_cnt].weight_value, " ", dlrec->seq[d1.seq].weights[weight_cnt
      ].weight_unit
     ENDIF
     ycol = (ycol+ 8), row + 1
    ENDIF
    IF ((dlrec->seq[d1.seq].output_line_cnt > 0))
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}Out{endb}"
     FOR (lcnt = 1 TO dlrec->seq[d1.seq].output_line_cnt)
       IF (ycol > 725)
        BREAK
       ENDIF
       IF (lcnt=1)
        IF ((dlrec->seq[d1.seq].output_line[lcnt].column1 <= ""))
         xcol = 60, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "No Output found in the last 12 hours."
        ELSE
         xcol = 60, row + 1,
         CALL print(calcpos(xcol,ycol)),
         dlrec->seq[d1.seq].output_line[lcnt].column1
        ENDIF
        IF ((dlrec->seq[d1.seq].output_line[lcnt].column2 <= ""))
         xcol = 285, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "No Output found in the last 24 hours."
        ELSE
         xcol = 285, row + 1,
         CALL print(calcpos(xcol,ycol)),
         dlrec->seq[d1.seq].output_line[lcnt].column2
        ENDIF
       ELSE
        xcol = 60, row + 1,
        CALL print(calcpos(xcol,ycol)),
        dlrec->seq[d1.seq].output_line[lcnt].column1, xcol = 285, row + 1,
        CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].output_line[lcnt].column2
       ENDIF
       IF (weight_cnt < size(dlrec->seq[d1.seq].weights,5))
        weight_cnt = (weight_cnt+ 1), xcol = 500, row + 1,
        CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].weights[weight_cnt].weight_dt_tm, " ",
        dlrec->seq[d1.seq].weights[weight_cnt].weight_value, " ", dlrec->seq[d1.seq].weights[
        weight_cnt].weight_unit
       ENDIF
       ycol = (ycol+ 8), row + 1
     ENDFOR
    ELSE
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}Out{endb}", xcol = 60, row + 1,
     CALL print(calcpos(xcol,ycol)), "No Output found in the last 12 hours.", xcol = 285,
     row + 1,
     CALL print(calcpos(xcol,ycol)), "No Output found in the last 24 hours."
     IF (weight_cnt < size(dlrec->seq[d1.seq].weights,5))
      weight_cnt = (weight_cnt+ 1), xcol = 500, row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].weights[weight_cnt].weight_dt_tm, " ",
      dlrec->seq[d1.seq].weights[weight_cnt].weight_value, " ", dlrec->seq[d1.seq].weights[weight_cnt
      ].weight_unit
     ENDIF
     ycol = (ycol+ 8), row + 1
    ENDIF
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No I&O found in the last 24 hours."
    IF (size(dlrec->seq[d1.seq].weights,5) > 0)
     print_weight = trim(format(dlrec->seq[d1.seq].weight_change,"##.##")), total_delta = dlrec->seq[
     d1.seq].weight_up_down, saved_unit = dlrec->seq[d1.seq].weight_tot_unit,
     xcol = 500, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}{u}Weights ", total_delta, print_weight,
     first_weight = 000.00, last_weight = 000.00, total_weight = 00.00,
     total_delta = " NONE"
    ELSE
     xcol = 500, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "No Weights Charted"
    ENDIF
    ycol = (ycol+ 8), row + 1
   ENDIF
   FOR (i = (weight_cnt+ 1) TO size(dlrec->seq[d1.seq].weights,5))
     xcol = 500, row + 1,
     CALL print(calcpos(xcol,ycol)),
     dlrec->seq[d1.seq].weights[i].weight_dt_tm, " ", dlrec->seq[d1.seq].weights[i].weight_value,
     " ", dlrec->seq[d1.seq].weights[i].weight_unit, ycol = (ycol+ 8),
     row + 1
   ENDFOR
   IF ((ycol > (725 - 16)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Problems", xcol = 215, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Diagnoses", xcol = 400,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}Allergies{endb}{endu}",
   ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].prob_diag_all_cnt > 0))
    FOR (lcnt = 1 TO dlrec->seq[d1.seq].prob_diag_all_cnt)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (lcnt=1)
      IF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column1)=0)
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No Problems found for patient."
      ELSEIF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column1) > 0)
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].prob_diag_all[lcnt].column1
      ENDIF
      IF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column2)=0)
       xcol = 215, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No Diagnoses found for encounter."
      ELSEIF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column2) > 0)
       xcol = 215, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].prob_diag_all[lcnt].column2
      ENDIF
      IF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column3)=0)
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No Allergies found for patient."
      ELSEIF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column3) > 0)
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].prob_diag_all[lcnt].column3
      ENDIF
      ycol = (ycol+ 8), row + 1
     ELSEIF (lcnt > 1)
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      dlrec->seq[d1.seq].prob_diag_all[lcnt].column1, xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].prob_diag_all[lcnt].column2, xcol = 400,
      row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].prob_diag_all[lcnt].column3,
      ycol = (ycol+ 8), row + 1
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Problems found for patient.", xcol = 215, row + 1,
    CALL print(calcpos(xcol,ycol)), "No Diagnoses found for encounter.", xcol = 400,
    row + 1,
    CALL print(calcpos(xcol,ycol)), "No Allergies found for patient.",
    ycol = (ycol+ 10), xcol = 30, ycol = (ycol+ 8),
    row + 1
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Isolation{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].prob_diag_all_cnt > 0))
    FOR (lcnt = 1 TO dlrec->seq[d1.seq].prob_diag_all_cnt)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (lcnt=1)
      IF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column4)=0)
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No isolation found for patient."
      ELSEIF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column4) > 0)
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].prob_diag_all[lcnt].column4
      ENDIF
      ycol = (ycol+ 8), row + 1
     ELSEIF (lcnt > 1)
      IF (size(dlrec->seq[d1.seq].prob_diag_all[lcnt].column4) > 0)
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].prob_diag_all[lcnt].column4, ycol = (ycol+ 8), row + 1
      ENDIF
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Isolations found for patient.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Diet Orders", ycol = (ycol+ 8)
   IF (size(dlrec->seq[d1.seq].diets,5)=0)
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No diets found for patient.", ycol = (ycol+ 8)
   ELSE
    FOR (i = 1 TO size(dlrec->seq[d1.seq].diets,5))
     tempstring = concat(dlrec->seq[d1.seq].diets[i].orderable," ",dlrec->seq[d1.seq].diets[i].
      clinical_display_line),
     IF (size(tempstring) < 150)
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      tempstring, ycol = (ycol+ 8)
     ELSE
      row + 0
     ENDIF
    ENDFOR
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   FOR (lcnt = 1 TO dlrec->seq[d1.seq].med_line_cnt)
     IF (ycol > 725)
      BREAK
     ENDIF
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     dlrec->seq[d1.seq].med_line[lcnt].column1, xcol = 215, row + 1,
     CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].med_line[lcnt].column2, xcol = 400,
     row + 1,
     CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].med_line[lcnt].column3,
     xcol = 450, row + 1, ycol = (ycol+ 8),
     row + 1
   ENDFOR
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}General Lab Results in last 24 hours{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].lab_line_cnt > 0))
    FOR (lcnt = 1 TO dlrec->seq[d1.seq].lab_line_cnt)
      IF (ycol > 725)
       BREAK
      ENDIF
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      dlrec->seq[d1.seq].lab_line[lcnt].column1, xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].lab_line[lcnt].column2, xcol = 400,
      row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].lab_line[lcnt].column3,
      ycol = (ycol+ 8), row + 1
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Labs found on encounter in last 24 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Radiology, Micro, Blood Bank Orders in the last 72 hours{endb}{endu}", ycol = (ycol+ 8),
   row + 1
   IF ((dlrec->seq[d1.seq].rad_count > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].rad_count)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((ocnt=1) OR (mod(ocnt,2)=1)) )
      order_string = concat(dlrec->seq[d1.seq].rad_orders[ocnt].order_date," ",trim(dlrec->seq[d1.seq
        ].rad_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].rad_orders[ocnt].order_status)),
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].rad_count))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((ocnt=2) OR (mod(ocnt,2)=0)) )
      order_string = concat(dlrec->seq[d1.seq].rad_orders[ocnt].order_date," ",trim(dlrec->seq[d1.seq
        ].rad_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].rad_orders[ocnt].order_status)),
      xcol = 325, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string, ycol = (ycol+ 8),
      row + 1
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Radiology Orders found on encounter in last 72 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((dlrec->seq[d1.seq].micro_labs > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].micro_labs)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((ocnt=1) OR (mod(ocnt,2)=1)) )
      order_string = concat(dlrec->seq[d1.seq].micro_orders[ocnt].order_date," ",trim(dlrec->seq[d1
        .seq].micro_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].micro_orders[ocnt].
        order_status)), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].micro_labs))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((ocnt=2) OR (mod(ocnt,2)=0)) )
      order_string = concat(dlrec->seq[d1.seq].micro_orders[ocnt].order_date," ",trim(dlrec->seq[d1
        .seq].micro_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].micro_orders[ocnt].
        order_status)), xcol = 325, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string, ycol = (ycol+ 8),
      row + 1
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Micro Orders found on encounter in last 72 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   IF ((dlrec->seq[d1.seq].blood_bank_labs > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].blood_bank_labs)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((ocnt=1) OR (mod(ocnt,2)=1)) )
      order_string = concat(dlrec->seq[d1.seq].blood_bank_orders[ocnt].order_date," ",trim(dlrec->
        seq[d1.seq].blood_bank_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].blood_bank_orders[
        ocnt].order_status)), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].blood_bank_labs))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((ocnt=2) OR (mod(ocnt,2)=0)) )
      order_string = concat(dlrec->seq[d1.seq].blood_bank_orders[ocnt].order_date," ",trim(dlrec->
        seq[d1.seq].blood_bank_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].blood_bank_orders[
        ocnt].order_status)), xcol = 325, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string, ycol = (ycol+ 8),
      row + 1
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Blood Bank Orders found on encounter in last 72 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Other Info (DVT Prophylaxis,", " Urinary Catheters, Restraints, Code Status){endb}{endu}",
   ycol = (ycol+ 8),
   row + 1, offset = 0
   IF ((dlrec->seq[d1.seq].total_orders=0)
    AND (dlrec->seq[d1.seq].total_immunization=0)
    AND (dlrec->seq[d1.seq].total_screening=0)
    AND (dlrec->seq[d1.seq].total_quit=0))
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Other Info found on encounter.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((dlrec->seq[d1.seq].total_orders > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].total_orders)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((((ocnt+ offset)=1)) OR (mod((ocnt+ offset),3)=1)) )
      order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_orders))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=2)) OR (mod((ocnt+ offset),3)=2)) )
      order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable), xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_orders))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=3)) OR (mod((ocnt+ offset),3)=0)) )
      order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable)
      IF (size(order_string) <= 40)
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       order_string
      ELSE
       offset = (offset+ 1), ocnt = (ocnt - 1)
      ENDIF
      ycol = (ycol+ 8), row + 1
     ENDIF
    ENDFOR
   ENDIF
   IF ((dlrec->seq[d1.seq].total_immunization > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].total_immunization)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((((ocnt+ offset)=1)) OR (mod((ocnt+ offset),3)=1)) )
      order_string = trim(dlrec->seq[d1.seq].immunization[ocnt].immunization_name), xcol = 30, row +
      1,
      CALL print(calcpos(xcol,ycol)), "Influenza immunization status: ", order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_immunization))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=2)) OR (mod((ocnt+ offset),3)=2)) )
      order_string = trim(dlrec->seq[d1.seq].immunization[ocnt].immunization_name), xcol = 215, row
       + 1,
      CALL print(calcpos(xcol,ycol)), "Influenza immunization status: ", order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_immunization))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=3)) OR (mod((ocnt+ offset),3)=0)) )
      order_string = trim(dlrec->seq[d1.seq].immunization[ocnt].immunization_name)
      IF (size(order_string) <= 40)
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Influenza immunization status: ", order_string
      ELSE
       offset = (offset+ 1), ocnt = (ocnt - 1)
      ENDIF
      ycol = (ycol+ 8), row + 1
     ENDIF
    ENDFOR
   ENDIF
   IF ((dlrec->seq[d1.seq].total_screening > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].total_screening)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((((ocnt+ offset)=1)) OR (mod((ocnt+ offset),3)=1)) )
      order_string = trim(dlrec->seq[d1.seq].screening[ocnt].screening_name), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), "Tobacco History: ", order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_screening))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=2)) OR (mod((ocnt+ offset),3)=2)) )
      order_string = trim(dlrec->seq[d1.seq].screening[ocnt].screening_name), xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), "Tobacco History: ", order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_screening))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=3)) OR (mod((ocnt+ offset),3)=0)) )
      order_string = trim(dlrec->seq[d1.seq].screening[ocnt].screening_name)
      IF (size(order_string) <= 40)
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Tobacco History: ", order_string
      ELSE
       offset = (offset+ 1), ocnt = (ocnt - 1)
      ENDIF
      ycol = (ycol+ 8), row + 1
     ENDIF
    ENDFOR
   ENDIF
   IF ((dlrec->seq[d1.seq].total_quit > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].total_quit)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((((ocnt+ offset)=1)) OR (mod((ocnt+ offset),3)=1)) )
      order_string = trim(dlrec->seq[d1.seq].quit[ocnt].quit_name), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), "Quitworks referral:", order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_quit))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=2)) OR (mod((ocnt+ offset),3)=2)) )
      order_string = trim(dlrec->seq[d1.seq].quit[ocnt].quit_name), xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), "Quitworks referral:", order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_quit))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((((ocnt+ offset)=3)) OR (mod((ocnt+ offset),3)=0)) )
      order_string = trim(dlrec->seq[d1.seq].quit[ocnt].quit_name)
      IF (size(order_string) <= 40)
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "Quitworks referral:", order_string
      ELSE
       offset = (offset+ 1), ocnt = (ocnt - 1)
      ENDIF
      ycol = (ycol+ 8), row + 1
     ENDIF
    ENDFOR
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Rounds/Sticky Notes{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].total_sticky_notes > 0))
    FOR (ncnt = 1 TO dlrec->seq[d1.seq].total_sticky_notes)
      IF (ycol > 725)
       BREAK
      ENDIF
      note_string = concat(trim(dlrec->seq[d1.seq].sticky_notes[ncnt].note_date)," ",trim(dlrec->seq[
        d1.seq].sticky_notes[ncnt].prsnl_name),"- ",trim(dlrec->seq[d1.seq].sticky_notes[ncnt].notes)
       ), tempstring = trim(note_string), wrapcol = 130,
      eol = size(trim(tempstring)), xcol = 30, line_wrap_indent
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No notes found on patient.", ycol = (ycol+ 8), row + 1
   ENDIF
   headerprinted = 0
  FOOT  encntr_id
   IF ((req2->pagebreak=2)
    AND (encntrcnt < dlrec->encntr_total))
    BREAK
   ENDIF
  WITH dio = postscript, maxcol = 800, maxrow = 800
 ;end select
#end_of_program
 IF (ml_debug_flag > 10)
  CALL echorecord(dlrec)
 ENDIF
 FREE RECORD dlrec
 FREE RECORD pt
 SET last_mod = "002 - SH013356 09/9/17 417340103 Add more characters to the room name"
END GO
