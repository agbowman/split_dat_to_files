CREATE PROGRAM bhs_rounds_report_v3:dba
 FREE RECORD temprec
 RECORD temprec(
   1 qual[*]
     2 med = vc
 )
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
     2 prob_diag_all_max_cnt = i4
     2 prob_diag_all_cnt = i4
     2 prob_diag_all[*]
       3 column1 = vc
       3 column2 = vc
       3 column3 = vc
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
     2 homemeds[*]
       3 med = vc
     2 scheduledmeds[*]
       3 med = vc
     2 prnmeds[*]
       3 med = vc
     2 ivfluids[*]
       3 med = vc
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
 )
 DECLARE total_rows = i2
 DECLARE save_total_rows = i2
 DECLARE max_total_rows = i2
 DECLARE tot_cnt = i2
 DECLARE printed_dt_tm = vc
 DECLARE printed_by = vc
 DECLARE printed_on = vc
 SET printed_on = format(cnvtdatetime(curdate,curtime),"mm/dd/yy hh:mm;;d")
 SET reporttitle = "*** Baystate Rounds Report v3 ***"
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
 DECLARE cath_foley_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERFOLEY"))
 DECLARE cath_care_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,"CATHETERCARE"))
 DECLARE cath_foley_3_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERFOLEYTHREEWAY"))
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
 DECLARE order_string = vc WITH noconstant(" ")
 DECLARE note_string = vc WITH noconstant(" ")
 DECLARE encntr_ids_0 = i4
 DECLARE last_weight = f8
 DECLARE first_weight = f8
 DECLARE total_weight = f8
 DECLARE total_delta = c5
 DECLARE print_weight = vc
 DECLARE saved_units = vc
 CALL echo("Declare Report Writer layout variables")
 DECLARE tempature = vc WITH noconstant(" ")
 DECLARE pulse = vc WITH noconstant(" ")
 DECLARE bp = vc WITH noconstant(" ")
 DECLARE rr = vc WITH noconstant(" ")
 DECLARE sat = vc WITH noconstant(" ")
 DECLARE input12 = vc WITH noconstant(" ")
 DECLARE input24 = vc WITH noconstant(" ")
 DECLARE output12 = vc WITH noconstant(" ")
 DECLARE output24 = vc WITH noconstant(" ")
 DECLARE weightchange = vc WITH noconstant(" ")
 DECLARE weightin = vc WITH noconstant(" ")
 DECLARE prob = vc WITH noconstant(" ")
 DECLARE dx = vc WITH noconstant(" ")
 DECLARE all = vc WITH noconstant(" ")
 DECLARE dietorders = vc WITH noconstant(" ")
 DECLARE meds1 = vc WITH noconstant(" ")
 DECLARE meds2 = vc WITH noconstant(" ")
 DECLARE meds3 = vc WITH noconstant(" ")
 DECLARE medtype = vc WITH noconstant(" ")
 DECLARE scheduledmeds = vc WITH noconstant(" ")
 DECLARE prnmeds = vc WITH noconstant(" ")
 DECLARE ivfluids = vc WITH noconstant(" ")
 DECLARE labs1 = vc WITH noconstant(" ")
 DECLARE labs2 = vc WITH noconstant(" ")
 DECLARE labs3 = vc WITH noconstant(" ")
 DECLARE ordercol1 = vc WITH noconstant(" ")
 DECLARE ordercol2 = vc WITH noconstant(" ")
 DECLARE ordertitle = vc WITH noconstant(" ")
 DECLARE stickynotes = vc WITH noconstant(" ")
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
  CALL echo(build("encntr_ids_0: ",encntr_ids_0))
  CALL echo(build("size(request->visit,5): ",size(request->visit,5)))
  IF (((size(request->visit,5)=0) OR (encntr_ids_0=size(request->visit,5))) )
   SELECT INTO value(printer_disp)
    FROM dummyt
    HEAD REPORT
     line = fillstring(200,"-"), line_short = fillstring(125,"-"), xcol = 0,
     ycol = 0, "{f/0}{cpi/18}", ycol = 30,
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), "*** Baystate Rounds Report v3 ***",
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
   dlrec->seq[d1.seq].location = trim(uar_get_code_display(e.loc_nurse_unit_cd)), dlrec->seq[d1.seq].
   room_bed = concat(trim(uar_get_code_display(e.loc_room_cd),3),trim(uar_get_code_display(e
      .loc_bed_cd),3)), dlrec->seq[d1.seq].dob = format(p.birth_dt_tm,"mm/dd/yy;;d"),
   dlrec->seq[d1.seq].age = substring(1,3,trim(cnvtage(p.birth_dt_tm),3)), dlrec->seq[d1.seq].
   patient_name = trim(p.name_full_formatted), dlrec->seq[d1.seq].mrn = trim(ea.alias),
   dlrec->seq[d1.seq].attenddoc_name = trim(ep.name_full_formatted), dlrec->seq[d1.seq].pcp_name =
   trim(pp.name_full_formatted)
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
    dlrec->seq[d.seq].casemanager = concat(trim(pr.name_first,3)," ",trim(pr.name_last,3)),
    CALL echo(dlrec->seq[d.seq].casemanager)
   WITH nocounter
  ;end select
  CALL echo(size(dlrec->seq,5))
  CALL echo(curqual)
  CALL echorecord(dlrec)
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
     AND sa.loc_bed_cd > 0) OR (((sa.loc_bed_cd=0
     AND sa.loc_room_cd=e.loc_room_cd
     AND sa.active_ind=1
     AND sa.loc_room_cd > 0) OR (sa.loc_room_cd=0
     AND sa.loc_unit_cd=e.loc_nurse_unit_cd
     AND sa.active_ind=1
     AND sa.loc_unit_cd=0)) ))
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
    CALL echo("nurseFound"), nursecnt = (nursecnt+ 1), stat = alterlist(dlrec->seq[d.seq].nurse_qual,
     nursecnt),
    dlrec->seq[d.seq].nurse_qual[nursecnt].nurse = concat(trim(p.name_first,3)," ",trim(p.name_last,3
      ))
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
    AND ((cnvtdatetime(curdate,curtime3)+ 0) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm)
    AND ((d.active_ind+ 0)=1))
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
   CALL echo(build("FTDESC SIZE:",size(trim(d.diag_ftdesc))))
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
    AND ((o.order_status_cd+ 0) IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd))
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
    AND ((o.order_status_cd+ 0) IN (o_inprocess_cd, o_ordered_cd, o_pending_cd, o_pending_rev_cd))
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
        dlrec->seq[d1.seq].med_line[total_rows].column2 = printstring
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
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0), stat = alterlist(
       dlrec->seq[d1.seq].homemeds,(size(dlrec->seq[d1.seq].homemeds,5)+ 1)),
      dlrec->seq[d1.seq].homemeds[size(dlrec->seq[d1.seq].homemeds,5)].med = med_string
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
    dlrec->seq[d1.seq].med_line[total_rows].column1 = "No Home meds found for encounter.", stat =
    alterlist(dlrec->seq[d1.seq].homemeds,1), dlrec->seq[d1.seq].homemeds[1].med =
    "No Home meds found for encounter."
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
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0), stat = alterlist(
       dlrec->seq[d1.seq].scheduledmeds,(size(dlrec->seq[d1.seq].scheduledmeds,5)+ 1)),
      dlrec->seq[d1.seq].scheduledmeds[size(dlrec->seq[d1.seq].scheduledmeds,5)].med = med_string
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
    dlrec->seq[d1.seq].med_line[total_rows].column2 = "No Scheduled meds found for encounter.", stat
     = alterlist(dlrec->seq[d1.seq].scheduledmeds,1), dlrec->seq[d1.seq].scheduledmeds[1].med =
    "No Scheduled meds found for encounter."
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
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0), stat = alterlist(
       dlrec->seq[d1.seq].prnmeds,(size(dlrec->seq[d1.seq].prnmeds,5)+ 1)),
      dlrec->seq[d1.seq].prnmeds[size(dlrec->seq[d1.seq].prnmeds,5)].med = med_string
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
    dlrec->seq[d1.seq].med_line[total_rows].column3 = "No PRN meds found for encounter.", stat =
    alterlist(dlrec->seq[d1.seq].prnmeds,1), dlrec->seq[d1.seq].prnmeds[1].med =
    "No PRN meds found for encounter."
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
         dlrec->seq[d1.seq].meds[mcnt].freq)),"|"," ",0), stat = alterlist(dlrec->seq[d1.seq].
       ivfluids,(size(dlrec->seq[d1.seq].ivfluids,5)+ 1)),
      dlrec->seq[d1.seq].ivfluids[size(dlrec->seq[d1.seq].ivfluids,5)].med = med_string
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
    dlrec->seq[d1.seq].med_line[total_rows].column3 = "No IV meds found for encounter.", stat =
    alterlist(dlrec->seq[d1.seq].ivfluids,1), dlrec->seq[d1.seq].ivfluids[1].med =
    "No IV meds found for encounter."
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
  cath_suprap_cd)) 1
  ELSEIF (o.hna_order_mnemonic="Heparin") 2
  ELSEIF (o.hna_order_mnemonic="Enoxaparin") 3
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
   cath_foley_cd, cath_foley_3_cd, cath_care_cd,
   cath_coude_cd, cath_texas_cd, cath_suprap_cd, boots_cd, stockings_cd)
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
    cath_suprap_cd))
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "catheter", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Heparin")
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "heparin", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
      .orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
    ELSEIF (o.hna_order_mnemonic="Enoxaparin")
     dlrec->seq[dd.seq].orders[ord_cnt].orderable = trim(o.hna_order_mnemonic,3), dlrec->seq[dd.seq].
     orders[ord_cnt].type = "enoxaparin", dlrec->seq[dd.seq].orders[ord_cnt].date = format(o
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
     dlrec->seq[dd.seq].micro_orders[micro_cnt].order_status = concat(substring(1,15,
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
     dlrec->seq[dd.seq].blood_bank_orders[blood_bank_cnt].order_status = concat(substring(1,15,
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
     dlrec->seq[dd.seq].rad_orders[rad_cnt].order_status = concat(substring(1,15,uar_get_code_display
       (o.order_status_cd)),"...")
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
 CALL echo(build("Code Status:",code_status_cd))
 CALL echo(build("Limited:",od_limited_cd))
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
 CALL echorecord(dlrec,"dab_test_rounds.dat")
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
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE header(ncalc=i2) = f8 WITH protect
 DECLARE headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE personheader(ncalc=i2) = f8 WITH protect
 DECLARE personheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE vitals(ncalc=i2) = f8 WITH protect
 DECLARE vitalsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE input(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE inputabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE output(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE outputabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE inouttable(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE tablerow3(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE inouttableabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE prob_dx_all(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE prob_dx_allabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE diet(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE dietabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE meds(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE genlabhead(ncalc=i2) = f8 WITH protect
 DECLARE genlabheadabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE genlabsec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE genlabsecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE labstable(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow4(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE labstableabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE orders(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE ordersabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sticky(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE stickyabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontinput = i2 WITH noconstant(0), protect
 DECLARE _reminput12fld = i2 WITH noconstant(1), protect
 DECLARE _reminput12fld6 = i2 WITH noconstant(1), protect
 DECLARE _remweightinfld = i2 WITH noconstant(1), protect
 DECLARE _bcontoutput = i2 WITH noconstant(0), protect
 DECLARE _remoutput24fld = i2 WITH noconstant(1), protect
 DECLARE _remoutput12fld = i2 WITH noconstant(1), protect
 DECLARE _remweightoutfld = i2 WITH noconstant(1), protect
 DECLARE _bcontinouttable = i2 WITH noconstant(0), protect
 DECLARE _remcellname21 = i2 WITH noconstant(1), protect
 DECLARE _remcellname22 = i2 WITH noconstant(1), protect
 DECLARE _bconttablerow2 = i2 WITH noconstant(0), protect
 DECLARE _remcellname24 = i2 WITH noconstant(1), protect
 DECLARE _remcellname25 = i2 WITH noconstant(1), protect
 DECLARE _bconttablerow3 = i2 WITH noconstant(0), protect
 DECLARE _remweightinfld = i2 WITH noconstant(1), protect
 DECLARE _bcontprob_dx_all = i2 WITH noconstant(0), protect
 DECLARE _remprobfld = i2 WITH noconstant(1), protect
 DECLARE _remdxfld = i2 WITH noconstant(1), protect
 DECLARE _remallfld = i2 WITH noconstant(1), protect
 DECLARE _bcontdiet = i2 WITH noconstant(0), protect
 DECLARE _remdietordersfld = i2 WITH noconstant(1), protect
 DECLARE _bcontmeds = i2 WITH noconstant(0), protect
 DECLARE _remmedtypefld = i2 WITH noconstant(1), protect
 DECLARE _remcellname20 = i2 WITH noconstant(1), protect
 DECLARE _remcellname21 = i2 WITH noconstant(1), protect
 DECLARE _remcellname22 = i2 WITH noconstant(1), protect
 DECLARE _bconttablerow = i2 WITH noconstant(0), protect
 DECLARE _bcontgenlabsec = i2 WITH noconstant(0), protect
 DECLARE _remlabs1field = i2 WITH noconstant(1), protect
 DECLARE _remlabs1field4 = i2 WITH noconstant(1), protect
 DECLARE _remlabs1field5 = i2 WITH noconstant(1), protect
 DECLARE _bcontlabstable = i2 WITH noconstant(0), protect
 DECLARE _remcellname0 = i2 WITH noconstant(1), protect
 DECLARE _remcellname2 = i2 WITH noconstant(1), protect
 DECLARE _remcellname3 = i2 WITH noconstant(1), protect
 DECLARE _remcellname4 = i2 WITH noconstant(1), protect
 DECLARE _bconttablerow4 = i2 WITH noconstant(0), protect
 DECLARE _bcontorders = i2 WITH noconstant(0), protect
 DECLARE _remordertitlelbl = i2 WITH noconstant(1), protect
 DECLARE _remordercol1fld = i2 WITH noconstant(1), protect
 DECLARE _remordercol2fld = i2 WITH noconstant(1), protect
 DECLARE _bcontsticky = i2 WITH noconstant(0), protect
 DECLARE _remstickynotesfld = i2 WITH noconstant(1), protect
 DECLARE _times7bu0 = i4 WITH noconstant(0), protect
 DECLARE _times70 = i4 WITH noconstant(0), protect
 DECLARE _helvetica70 = i4 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _times7b0 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen5s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen5s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen10s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
 SUBROUTINE header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.125
    SET _oldfont = uar_rptsetfont(_hreport,_times70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed on:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed by:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reporttitle,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(printed_on,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(printed_by,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE personheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = personheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE personheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.188),(offsetx+ 8.021),(offsety+
     0.188))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 8.021),(offsety+
     0.063))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times7b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("name",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PCP",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date(Day)",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB(age)",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MR",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.125
    SET _dummyfont = uar_rptsetfont(_hreport,_times70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fac_loc,char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(dlrec->seq[d1.seq].patient_name,char(0
       )))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(dlrec->seq[d1.seq].mrn,char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(dob_age,char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(admit_day,char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(dlrec->seq[d1.seq].attenddoc_name,char
      (0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(dlrec->seq[d1.seq].pcp_name,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen5s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.302),(offsetx+ 8.021),(offsety+
     0.302))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE vitals(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = vitalsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE vitalsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.125
    SET _oldfont = uar_rptsetfont(_hreport,_times7b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Temp:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pulse:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BP:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Respiratory Rate:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sat:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.125
    SET _dummyfont = uar_rptsetfont(_hreport,_times70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tempature,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sat,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rr,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(bp,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pulse,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE input(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = inputabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE inputabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _reminput12fld = 1
    SET _reminput12fld6 = 1
    SET _remweightinfld = 1
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 1.448
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(weightchange,char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.094)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdreminput12fld = _reminput12fld
   IF (_reminput12fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminput12fld,((size(
        input12) - _reminput12fld)+ 1),input12)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminput12fld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminput12fld,((size(input12) -
       _reminput12fld)+ 1),input12)))))
     SET _reminput12fld = (_reminput12fld+ rptsd->m_drawlength)
    ELSE
     SET _reminput12fld = 0
    ENDIF
    SET growsum = (growsum+ _reminput12fld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdreminput12fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminput12fld,((size(
        input12) - _holdreminput12fld)+ 1),input12)))
   ELSE
    SET _reminput12fld = _holdreminput12fld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.073)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdreminput12fld6 = _reminput12fld6
   IF (_reminput12fld6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminput12fld6,((size(
        input24) - _reminput12fld6)+ 1),input24)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminput12fld6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminput12fld6,((size(input24) -
       _reminput12fld6)+ 1),input24)))))
     SET _reminput12fld6 = (_reminput12fld6+ rptsd->m_drawlength)
    ELSE
     SET _reminput12fld6 = 0
    ENDIF
    SET growsum = (growsum+ _reminput12fld6)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdreminput12fld6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminput12fld6,((size
       (input24) - _holdreminput12fld6)+ 1),input24)))
   ELSE
    SET _reminput12fld6 = _holdreminput12fld6
   ENDIF
   SET rptsd->m_y = (offsety+ 0.063)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.188
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_times7b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("In:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.094)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremweightinfld = _remweightinfld
   IF (_remweightinfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweightinfld,((size(
        weightin) - _remweightinfld)+ 1),weightin)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweightinfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweightinfld,((size(weightin) -
       _remweightinfld)+ 1),weightin)))))
     SET _remweightinfld = (_remweightinfld+ rptsd->m_drawlength)
    ELSE
     SET _remweightinfld = 0
    ENDIF
    SET growsum = (growsum+ _remweightinfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremweightinfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweightinfld,((size
       (weightin) - _holdremweightinfld)+ 1),weightin)))
   ELSE
    SET _remweightinfld = _holdremweightinfld
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_times7b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("12hr",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = 0.125
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("24hr",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE output(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = outputabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE outputabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remoutput24fld = 1
    SET _remoutput12fld = 1
    SET _remweightoutfld = 1
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
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremoutput24fld = _remoutput24fld
   IF (_remoutput24fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remoutput24fld,((size(
        output24) - _remoutput24fld)+ 1),output24)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remoutput24fld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remoutput24fld,((size(output24) -
       _remoutput24fld)+ 1),output24)))))
     SET _remoutput24fld = (_remoutput24fld+ rptsd->m_drawlength)
    ELSE
     SET _remoutput24fld = 0
    ENDIF
    SET growsum = (growsum+ _remoutput24fld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremoutput24fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremoutput24fld,((size
       (output24) - _holdremoutput24fld)+ 1),output24)))
   ELSE
    SET _remoutput24fld = _holdremoutput24fld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremoutput12fld = _remoutput12fld
   IF (_remoutput12fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remoutput12fld,((size(
        output12) - _remoutput12fld)+ 1),output12)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remoutput12fld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remoutput12fld,((size(output12) -
       _remoutput12fld)+ 1),output12)))))
     SET _remoutput12fld = (_remoutput12fld+ rptsd->m_drawlength)
    ELSE
     SET _remoutput12fld = 0
    ENDIF
    SET growsum = (growsum+ _remoutput12fld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremoutput12fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremoutput12fld,((size
       (output12) - _holdremoutput12fld)+ 1),output12)))
   ELSE
    SET _remoutput12fld = _holdremoutput12fld
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_times7b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Out:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremweightoutfld = _remweightoutfld
   IF (_remweightoutfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweightoutfld,((size(
        weightout) - _remweightoutfld)+ 1),weightout)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweightoutfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweightoutfld,((size(weightout) -
       _remweightoutfld)+ 1),weightout)))))
     SET _remweightoutfld = (_remweightoutfld+ rptsd->m_drawlength)
    ELSE
     SET _remweightoutfld = 0
    ENDIF
    SET growsum = (growsum+ _remweightoutfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremweightoutfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweightoutfld,((
       size(weightout) - _holdremweightoutfld)+ 1),weightout)))
   ELSE
    SET _remweightoutfld = _holdremweightoutfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE inouttable(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = inouttableabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.125
   SET _oldfont = uar_rptsetfont(_hreport,_times70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,"")
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_times7b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("12hr",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("24hr",char(0))))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.563),offsety,(offsetx+ 0.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 5.875),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 5.875),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remcellname21 = 1
    SET _remcellname22 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname21 = _remcellname21
   IF (_remcellname21 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname21,((size(
        nullterm(build2(input12,char(0)))) - _remcellname21)+ 1),nullterm(build2(input12,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname21 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname21,((size(nullterm(build2(
          input12,char(0)))) - _remcellname21)+ 1),nullterm(build2(input12,char(0))))))))
     SET _remcellname21 = (_remcellname21+ rptsd->m_drawlength)
    ELSE
     SET _remcellname21 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname21)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname22 = _remcellname22
   IF (_remcellname22 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname22,((size(
        nullterm(build2(output12,char(0)))) - _remcellname22)+ 1),nullterm(build2(output12,char(0))))
      ))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname22 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname22,((size(nullterm(build2(
          output12,char(0)))) - _remcellname22)+ 1),nullterm(build2(output12,char(0))))))))
     SET _remcellname22 = (_remcellname22+ rptsd->m_drawlength)
    ELSE
     SET _remcellname22 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname22)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times7b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("In:",char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname21 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname21,((size
        (nullterm(build2(input12,char(0)))) - _holdremcellname21)+ 1),nullterm(build2(input12,char(0)
          )))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname21 = _holdremcellname21
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname22 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname22,((size
        (nullterm(build2(output12,char(0)))) - _holdremcellname22)+ 1),nullterm(build2(output12,char(
           0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname22 = _holdremcellname22
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.563),offsety,(offsetx+ 0.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 5.875),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 5.875),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow3(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remcellname24 = 1
    SET _remcellname25 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname24 = _remcellname24
   IF (_remcellname24 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname24,((size(
        nullterm(build2(input24,char(0)))) - _remcellname24)+ 1),nullterm(build2(input24,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname24 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname24,((size(nullterm(build2(
          input24,char(0)))) - _remcellname24)+ 1),nullterm(build2(input24,char(0))))))))
     SET _remcellname24 = (_remcellname24+ rptsd->m_drawlength)
    ELSE
     SET _remcellname24 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname24)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname25 = _remcellname25
   IF (_remcellname25 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname25,((size(
        nullterm(build2(output24,char(0)))) - _remcellname25)+ 1),nullterm(build2(output24,char(0))))
      ))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname25 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname25,((size(nullterm(build2(
          output24,char(0)))) - _remcellname25)+ 1),nullterm(build2(output24,char(0))))))))
     SET _remcellname25 = (_remcellname25+ rptsd->m_drawlength)
    ELSE
     SET _remcellname25 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname25)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times7b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(build2("Out:",char(0))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.563)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname24 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname24,((size
        (nullterm(build2(input24,char(0)))) - _holdremcellname24)+ 1),nullterm(build2(input24,char(0)
          )))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname24 = _holdremcellname24
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname25 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname25,((size
        (nullterm(build2(output24,char(0)))) - _holdremcellname25)+ 1),nullterm(build2(output24,char(
           0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname25 = _holdremcellname25
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.563),offsety,(offsetx+ 0.563),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.625),offsety,(offsetx+ 2.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.875),offsety,(offsetx+ 5.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 5.875),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 5.875),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE inouttableabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remweightinfld = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow1 = (maxheight - (0.000+ holdheight))
     SET holdheight = (holdheight+ tablerow1(rpt_calcheight))
     IF (holdheight > maxheight_tablerow1)
      SET growsum = 1
     ENDIF
    ENDIF
    IF (growsum=0)
     SET maxheight_tablerow2 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow2(rpt_calcheight,maxheight_tablerow2,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow2)) )
      SET growsum = 1
     ENDIF
    ENDIF
    IF (growsum=0)
     SET maxheight_tablerow3 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow3(rpt_calcheight,maxheight_tablerow3,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow3)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET holdheight = (holdheight+ tablerow1(rpt_render))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET maxheight_tablerow2 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow2(rpt_render,maxheight_tablerow2,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET maxheight_tablerow3 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow3(rpt_render,maxheight_tablerow3,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.125
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(weightchange,char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.938)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremweightinfld = _remweightinfld
   IF (_remweightinfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remweightinfld,((size(
        weightin) - _remweightinfld)+ 1),weightin)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remweightinfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remweightinfld,((size(weightin) -
       _remweightinfld)+ 1),weightin)))))
     SET _remweightinfld = (_remweightinfld+ rptsd->m_drawlength)
    ELSE
     SET _remweightinfld = 0
    ENDIF
    SET growsum = (growsum+ _remweightinfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremweightinfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremweightinfld,((size
       (weightin) - _holdremweightinfld)+ 1),weightin)))
   ELSE
    SET _remweightinfld = _holdremweightinfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE prob_dx_all(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = prob_dx_allabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE prob_dx_allabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remprobfld = 1
    SET _remdxfld = 1
    SET _remallfld = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.125
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Problems:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.125
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diagnoses:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.125
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.438)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremprobfld = _remprobfld
   IF (_remprobfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprobfld,((size(prob)
        - _remprobfld)+ 1),prob)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprobfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprobfld,((size(prob) - _remprobfld)+ 1
       ),prob)))))
     SET _remprobfld = (_remprobfld+ rptsd->m_drawlength)
    ELSE
     SET _remprobfld = 0
    ENDIF
    SET growsum = (growsum+ _remprobfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremprobfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprobfld,((size(
        prob) - _holdremprobfld)+ 1),prob)))
   ELSE
    SET _remprobfld = _holdremprobfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdxfld = _remdxfld
   IF (_remdxfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdxfld,((size(dx) -
       _remdxfld)+ 1),dx)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdxfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdxfld,((size(dx) - _remdxfld)+ 1),dx))
     )))
     SET _remdxfld = (_remdxfld+ rptsd->m_drawlength)
    ELSE
     SET _remdxfld = 0
    ENDIF
    SET growsum = (growsum+ _remdxfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremdxfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdxfld,((size(dx)
        - _holdremdxfld)+ 1),dx)))
   ELSE
    SET _remdxfld = _holdremdxfld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.688)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremallfld = _remallfld
   IF (_remallfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallfld,((size(all) -
       _remallfld)+ 1),all)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remallfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallfld,((size(all) - _remallfld)+ 1),
       all)))))
     SET _remallfld = (_remallfld+ rptsd->m_drawlength)
    ELSE
     SET _remallfld = 0
    ENDIF
    SET growsum = (growsum+ _remallfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremallfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallfld,((size(all)
        - _holdremallfld)+ 1),all)))
   ELSE
    SET _remallfld = _holdremallfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE diet(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = dietabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE dietabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remdietordersfld = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.125
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diet Orders:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.813)
   SET rptsd->m_width = 7.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremdietordersfld = _remdietordersfld
   IF (_remdietordersfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdietordersfld,((size(
        dietorders) - _remdietordersfld)+ 1),dietorders)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdietordersfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdietordersfld,((size(dietorders) -
       _remdietordersfld)+ 1),dietorders)))))
     SET _remdietordersfld = (_remdietordersfld+ rptsd->m_drawlength)
    ELSE
     SET _remdietordersfld = 0
    ENDIF
    SET growsum = (growsum+ _remdietordersfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremdietordersfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdietordersfld,((
       size(dietorders) - _holdremdietordersfld)+ 1),dietorders)))
   ELSE
    SET _remdietordersfld = _holdremdietordersfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE meds(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remmedtypefld = 1
    SET _remcellname20 = 1
    SET _remcellname21 = 1
    SET _remcellname22 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen10s3c0)
   SET _holdremmedtypefld = _remmedtypefld
   IF (_remmedtypefld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedtypefld,((size(
        nullterm(build2(medtype,char(0)))) - _remmedtypefld)+ 1),nullterm(build2(medtype,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedtypefld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedtypefld,((size(nullterm(build2(
          medtype,char(0)))) - _remmedtypefld)+ 1),nullterm(build2(medtype,char(0))))))))
     SET _remmedtypefld = (_remmedtypefld+ rptsd->m_drawlength)
    ELSE
     SET _remmedtypefld = 0
    ENDIF
    SET growsum = (growsum+ _remmedtypefld)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_paddingwidth = 0.020
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.812)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   SET _holdremcellname20 = _remcellname20
   IF (_remcellname20 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname20,((size(
        nullterm(build2(meds1,char(0)))) - _remcellname20)+ 1),nullterm(build2(meds1,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname20 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname20,((size(nullterm(build2(
          meds1,char(0)))) - _remcellname20)+ 1),nullterm(build2(meds1,char(0))))))))
     SET _remcellname20 = (_remcellname20+ rptsd->m_drawlength)
    ELSE
     SET _remcellname20 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname20)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 37
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.937)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   SET _holdremcellname21 = _remcellname21
   IF (_remcellname21 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname21,((size(
        nullterm(build2(meds2,char(0)))) - _remcellname21)+ 1),nullterm(build2(meds2,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname21 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname21,((size(nullterm(build2(
          meds2,char(0)))) - _remcellname21)+ 1),nullterm(build2(meds2,char(0))))))))
     SET _remcellname21 = (_remcellname21+ rptsd->m_drawlength)
    ELSE
     SET _remcellname21 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname21)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.062)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   SET _holdremcellname22 = _remcellname22
   IF (_remcellname22 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname22,((size(
        nullterm(build2(meds3,char(0)))) - _remcellname22)+ 1),nullterm(build2(meds3,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname22 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname22,((size(nullterm(build2(
          meds3,char(0)))) - _remcellname22)+ 1),nullterm(build2(meds3,char(0))))))))
     SET _remcellname22 = (_remcellname22+ rptsd->m_drawlength)
    ELSE
     SET _remcellname22 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname22)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.812
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   IF (ncalc=rpt_render)
    IF (_holdremmedtypefld > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedtypefld,((size
        (nullterm(build2(medtype,char(0)))) - _holdremmedtypefld)+ 1),nullterm(build2(medtype,char(0)
          )))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remmedtypefld = _holdremmedtypefld
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_paddingwidth = 0.020
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.812)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname20 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname20,((size
        (nullterm(build2(meds1,char(0)))) - _holdremcellname20)+ 1),nullterm(build2(meds1,char(0)))))
      )
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname20 = _holdremcellname20
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 36
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.937)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname21 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname21,((size
        (nullterm(build2(meds2,char(0)))) - _holdremcellname21)+ 1),nullterm(build2(meds2,char(0)))))
      )
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname21 = _holdremcellname21
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.062)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen10s3c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname22 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname22,((size
        (nullterm(build2(meds3,char(0)))) - _holdremcellname22)+ 1),nullterm(build2(meds3,char(0)))))
      )
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname22 = _holdremcellname22
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.812),offsety,(offsetx+ 0.812),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.937),offsety,(offsetx+ 2.937),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.062),offsety,(offsetx+ 5.062),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 8.000),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 8.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
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
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE genlabhead(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = genlabheadabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE genlabheadabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.125
    SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "General Lab Results in last 24 hours:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE genlabsec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = genlabsecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE genlabsecabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remlabs1field = 1
    SET _remlabs1field4 = 1
    SET _remlabs1field5 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (labbold1=1
    AND labunder1=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder1=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _helvetica70
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.813)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_fntcond)
   SET _oldpen = uar_rptsetpen(_hreport,_pencond)
   SET _holdremlabs1field = _remlabs1field
   IF (_remlabs1field > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabs1field,((size(
        labs1) - _remlabs1field)+ 1),labs1)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabs1field = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabs1field,((size(labs1) -
       _remlabs1field)+ 1),labs1)))))
     SET _remlabs1field = (_remlabs1field+ rptsd->m_drawlength)
    ELSE
     SET _remlabs1field = 0
    ENDIF
    SET growsum = (growsum+ _remlabs1field)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlabs1field > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabs1field,((size(
        labs1) - _holdremlabs1field)+ 1),labs1)))
   ELSE
    SET _remlabs1field = _holdremlabs1field
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   IF (labbold3=1
    AND labunder3=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder3=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _courier70
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.073)
   SET rptsd->m_width = 2.802
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   SET _holdremlabs1field4 = _remlabs1field4
   IF (_remlabs1field4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabs1field4,((size(
        labs3) - _remlabs1field4)+ 1),labs3)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabs1field4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabs1field4,((size(labs3) -
       _remlabs1field4)+ 1),labs3)))))
     SET _remlabs1field4 = (_remlabs1field4+ rptsd->m_drawlength)
    ELSE
     SET _remlabs1field4 = 0
    ENDIF
    SET growsum = (growsum+ _remlabs1field4)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlabs1field4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabs1field4,((size
       (labs3) - _holdremlabs1field4)+ 1),labs3)))
   ELSE
    SET _remlabs1field4 = _holdremlabs1field4
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdrightborder
   IF (labbold2=1
    AND labunder2=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder2=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _courier70
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.948)
   SET rptsd->m_width = 2.104
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   SET _holdremlabs1field5 = _remlabs1field5
   IF (_remlabs1field5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabs1field5,((size(
        labs2) - _remlabs1field5)+ 1),labs2)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabs1field5 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabs1field5,((size(labs2) -
       _remlabs1field5)+ 1),labs2)))))
     SET _remlabs1field5 = (_remlabs1field5+ rptsd->m_drawlength)
    ELSE
     SET _remlabs1field5 = 0
    ENDIF
    SET growsum = (growsum+ _remlabs1field5)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlabs1field5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabs1field5,((size
       (labs2) - _holdremlabs1field5)+ 1),labs2)))
   ELSE
    SET _remlabs1field5 = _holdremlabs1field5
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE labstable(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labstableabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow4(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow4abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remcellname0 = 1
    SET _remcellname2 = 1
    SET _remcellname3 = 1
    SET _remcellname4 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcellname0 = _remcellname0
   IF (_remcellname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname0,((size("")
        - _remcellname0)+ 1),"")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname0,((size("") - _remcellname0)
       + 1),"")))))
     SET _remcellname0 = (_remcellname0+ rptsd->m_drawlength)
    ELSE
     SET _remcellname0 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname0)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   IF (labbold1=1
    AND labunder1=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder1=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _times70
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.813)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   SET _holdremcellname2 = _remcellname2
   IF (_remcellname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname2,((size(
        nullterm(build2(labs1,char(0)))) - _remcellname2)+ 1),nullterm(build2(labs1,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname2,((size(nullterm(build2(labs1,
          char(0)))) - _remcellname2)+ 1),nullterm(build2(labs1,char(0))))))))
     SET _remcellname2 = (_remcellname2+ rptsd->m_drawlength)
    ELSE
     SET _remcellname2 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname2)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   IF (labbold2=1
    AND labunder2=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder2=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _times70
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.938)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   SET _holdremcellname3 = _remcellname3
   IF (_remcellname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname3,((size(
        nullterm(build2(labs2,char(0)))) - _remcellname3)+ 1),nullterm(build2(labs2,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname3 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname3,((size(nullterm(build2(labs2,
          char(0)))) - _remcellname3)+ 1),nullterm(build2(labs2,char(0))))))))
     SET _remcellname3 = (_remcellname3+ rptsd->m_drawlength)
    ELSE
     SET _remcellname3 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname3)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 5
   IF (labbold3=1
    AND labunder3=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder3=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen14s0c0
    SET _fntcond = _times70
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 2.937
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   SET _holdremcellname4 = _remcellname4
   IF (_remcellname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcellname4,((size(
        nullterm(build2(labs3,char(0)))) - _remcellname4)+ 1),nullterm(build2(labs3,char(0))))))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcellname4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcellname4,((size(nullterm(build2(labs3,
          char(0)))) - _remcellname4)+ 1),nullterm(build2(labs3,char(0))))))))
     SET _remcellname4 = (_remcellname4+ rptsd->m_drawlength)
    ELSE
     SET _remcellname4 = 0
    ENDIF
    SET growsum = (growsum+ _remcellname4)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremcellname0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname0,((size(
         "") - _holdremcellname0)+ 1),"")))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname0 = _holdremcellname0
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   IF (labbold1=1
    AND labunder1=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder1=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _times70
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.813)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   IF (ncalc=rpt_render)
    IF (_holdremcellname2 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname2,((size(
         nullterm(build2(labs1,char(0)))) - _holdremcellname2)+ 1),nullterm(build2(labs1,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname2 = _holdremcellname2
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   IF (labbold2=1
    AND labunder2=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder2=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen5s3c0
    SET _fntcond = _times70
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.938)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   IF (ncalc=rpt_render)
    IF (_holdremcellname3 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname3,((size(
         nullterm(build2(labs2,char(0)))) - _holdremcellname3)+ 1),nullterm(build2(labs2,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname3 = _holdremcellname3
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   IF (labbold3=1
    AND labunder3=0)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7b0
   ELSEIF (labunder3=1)
    SET _pencond = _pen5s0c0
    SET _fntcond = _times7bu0
   ELSE
    SET _pencond = _pen14s0c0
    SET _fntcond = _times70
   ENDIF
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.063)
   SET rptsd->m_width = 2.937
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   SET _dummypen = uar_rptsetpen(_hreport,_pencond)
   IF (ncalc=rpt_render)
    IF (_holdremcellname4 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcellname4,((size(
         nullterm(build2(labs3,char(0)))) - _holdremcellname4)+ 1),nullterm(build2(labs3,char(0))))))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remcellname4 = _holdremcellname4
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.813),offsety,(offsetx+ 0.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.938),offsety,(offsetx+ 2.938),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.063),offsety,(offsetx+ 5.063),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 8.000),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 8.000),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labstableabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow4 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow4(rpt_calcheight,maxheight_tablerow4,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow4)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow4 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow4(rpt_render,maxheight_tablerow4,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE orders(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ordersabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE ordersabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remordertitlelbl = 1
    SET _remordercol1fld = 1
    SET _remordercol2fld = 1
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
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremordertitlelbl = _remordertitlelbl
   IF (_remordertitlelbl > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remordertitlelbl,((size(
        ordertitle) - _remordertitlelbl)+ 1),ordertitle)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remordertitlelbl = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remordertitlelbl,((size(ordertitle) -
       _remordertitlelbl)+ 1),ordertitle)))))
     SET _remordertitlelbl = (_remordertitlelbl+ rptsd->m_drawlength)
    ELSE
     SET _remordertitlelbl = 0
    ENDIF
    SET growsum = (growsum+ _remordertitlelbl)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremordertitlelbl > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremordertitlelbl,((
       size(ordertitle) - _holdremordertitlelbl)+ 1),ordertitle)))
   ELSE
    SET _remordertitlelbl = _holdremordertitlelbl
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.813)
   SET rptsd->m_width = 2.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremordercol1fld = _remordercol1fld
   IF (_remordercol1fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remordercol1fld,((size(
        ordercol1) - _remordercol1fld)+ 1),ordercol1)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remordercol1fld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remordercol1fld,((size(ordercol1) -
       _remordercol1fld)+ 1),ordercol1)))))
     SET _remordercol1fld = (_remordercol1fld+ rptsd->m_drawlength)
    ELSE
     SET _remordercol1fld = 0
    ENDIF
    SET growsum = (growsum+ _remordercol1fld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremordercol1fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremordercol1fld,((
       size(ordercol1) - _holdremordercol1fld)+ 1),ordercol1)))
   ELSE
    SET _remordercol1fld = _holdremordercol1fld
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremordercol2fld = _remordercol2fld
   IF (_remordercol2fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remordercol2fld,((size(
        ordercol2) - _remordercol2fld)+ 1),ordercol2)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remordercol2fld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remordercol2fld,((size(ordercol2) -
       _remordercol2fld)+ 1),ordercol2)))))
     SET _remordercol2fld = (_remordercol2fld+ rptsd->m_drawlength)
    ELSE
     SET _remordercol2fld = 0
    ENDIF
    SET growsum = (growsum+ _remordercol2fld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremordercol2fld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremordercol2fld,((
       size(ordercol2) - _holdremordercol2fld)+ 1),ordercol2)))
   ELSE
    SET _remordercol2fld = _holdremordercol2fld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE sticky(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = stickyabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE stickyabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remstickynotesfld = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.125
   SET _oldfont = uar_rptsetfont(_hreport,_times7bu0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Rounds/Sticky Notes:",char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 6.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times70)
   SET _holdremstickynotesfld = _remstickynotesfld
   IF (_remstickynotesfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remstickynotesfld,((size(
        stickynotes) - _remstickynotesfld)+ 1),stickynotes)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remstickynotesfld = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remstickynotesfld,((size(stickynotes) -
       _remstickynotesfld)+ 1),stickynotes)))))
     SET _remstickynotesfld = (_remstickynotesfld+ rptsd->m_drawlength)
    ELSE
     SET _remstickynotesfld = 0
    ENDIF
    SET growsum = (growsum+ _remstickynotesfld)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremstickynotesfld > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremstickynotesfld,((
       size(stickynotes) - _holdremstickynotesfld)+ 1),stickynotes)))
   ELSE
    SET _remstickynotesfld = _holdremstickynotesfld
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_ROUNDS_REPORT_V3"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
   SET rptreport->m_margintop = 0.25
   SET rptreport->m_marginbottom = 0.25
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET _times70 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET rptfont->m_bold = rpt_on
   SET _times7b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _times7bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _helvetica70 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_courier
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.005
   SET rptpen->m_penstyle = 3
   SET _pen5s3c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET rptpen->m_penstyle = 0
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010
   SET rptpen->m_penstyle = 3
   SET _pen10s3c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.005
   SET rptpen->m_penstyle = 0
   SET _pen5s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET becount = 0
 IF (ver="New")
  SET output = "NL:"
 ELSE
  SET output = printer_disp
  SET printer_disp = "NL:"
 ENDIF
 SELECT INTO value(output)
  fac_loc =
  IF (textlen(trim(concat(trim(dlrec->seq[d1.seq].facility),"/",trim(dlrec->seq[d1.seq].location)," ",
     trim(dlrec->seq[d1.seq].room_bed)))) > 15) concat(substring(1,13,trim(concat(trim(dlrec->seq[d1
        .seq].location)," ",trim(dlrec->seq[d1.seq].room_bed)))),"...")
  ELSE trim(concat(trim(dlrec->seq[d1.seq].location)," ",trim(dlrec->seq[d1.seq].room_bed)))
  ENDIF
  , encntr_id = dlrec->seq[d1.seq].encntr_id, facility = dlrec->seq[d1.seq].facility,
  building = dlrec->seq[d1.seq].building, location = dlrec->seq[d1.seq].location, room_bed = dlrec->
  seq[d1.seq].room_bed,
  dob_age = concat(dlrec->seq[d1.seq].dob,"(",dlrec->seq[d1.seq].age,")"), admit_day = concat(dlrec->
   seq[d1.seq].admit_dt,"(",dlrec->seq[d1.seq].los,")")
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  ORDER BY fac_loc, encntr_id
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
   MACRO (breakpage)
    IF (ver="New")
     stat = 0
    ELSE
     BREAK
    ENDIF
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
   ,
   "{f/0}{cpi/18}", ycol = 30, xcol = 30,
   CALL print(calcpos(xcol,ycol)), "*** Baystate Rounds Report v3 ***", xcol = 215,
   CALL print(calcpos(xcol,ycol)), "Printed on: ", printed_on,
   xcol = 400,
   CALL print(calcpos(xcol,ycol)), "Printed by: ",
   printed_by, d0 = header(rpt_render)
  HEAD PAGE
   d0 = personheader(rpt_render), "{f/0}{cpi/18}", ycol = 38,
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
  HEAD fac_loc
   stat = 0
  HEAD encntr_id
   encntrcnt = (encntrcnt+ 1)
   IF (headerprinted=0)
    d0 = personheader(rpt_render)
   ENDIF
   IF ((ycol > (725 - 48)))
    breakpage
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
    dlrec->seq[d1.seq].pcp_name, ycol = (ycol+ 8), row + 1,
    row + 1,
    CALL print(calcpos(215,ycol)), "{b}",
    "Case Manager: ", "{endb}"
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
    ycol = (ycol+ 8), row + 1
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
    ")", ycol = (ycol+ 8), row + 1,
    tempature = build(dlrec->seq[d1.seq].vitals[1].temp_result,"(",dlrec->seq[d1.seq].vitals[1].
     temp_range,")"), pulse = build(dlrec->seq[d1.seq].vitals[1].pulse_result,"(",dlrec->seq[d1.seq].
     vitals[1].pulse_range,")"), bp = build(dlrec->seq[d1.seq].vitals[1].systolic_bp_result,"/",dlrec
     ->seq[d1.seq].vitals[1].diastolic_bp_result,"(",dlrec->seq[d1.seq].vitals[1].systolic_bp_range,
     "/",dlrec->seq[d1.seq].vitals[1].diastolic_bp_range,")"),
    rr = build(dlrec->seq[d1.seq].vitals[1].resp_rate_result,"(",dlrec->seq[d1.seq].vitals[1].
     resp_rate_range,")"), sat = build(dlrec->seq[d1.seq].vitals[1].systolic_bp_result,"/",dlrec->
     seq[d1.seq].vitals[1].diastolic_bp_result,"(",dlrec->seq[d1.seq].vitals[1].systolic_bp_range,
     "/",dlrec->seq[d1.seq].vitals[1].diastolic_bp_range,")"), d0 = vitals(rpt_render)
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No vitals found in last 24 hours", ycol = (ycol+ 8), row + 1
   ENDIF
   jcnt = 0, input12 = " ", input24 = " ",
   output12 = " ", output24 = " ", first_weight = 000.00,
   last_weight = 000.00, total_weight = 00.00, total_delta = " NONE",
   weightchange = " ", weightin = " ", weightout = " "
   IF ((dlrec->seq[d1.seq].intake_line_cnt > 0))
    FOR (jcnt = 1 TO dlrec->seq[d1.seq].intake_line_cnt)
      IF (textlen(trim(input12,3)) > 0)
       input12 = concat(input12,char(10))
      ENDIF
      IF (textlen(trim(input24,3)) > 0)
       input24 = concat(input24,char(10))
      ENDIF
      input12 = concat(input12,trim(dlrec->seq[d1.seq].intake_line[jcnt].column1,3)), input24 =
      concat(input24,trim(dlrec->seq[d1.seq].intake_line[jcnt].column2,3))
    ENDFOR
   ENDIF
   IF (textlen(trim(input12,3)) <= 0)
    input12 = "No Intake found in the last 12 hours."
   ENDIF
   IF (textlen(trim(input24,3)) <= 0)
    input24 = "No output found in the last 24 hours."
   ENDIF
   FOR (jcnt = 1 TO dlrec->seq[d1.seq].output_line_cnt)
     IF (textlen(trim(output12,3)) > 0)
      output12 = concat(output12,char(10))
     ENDIF
     IF (textlen(trim(output24,3)) > 0)
      output24 = concat(output24,char(10))
     ENDIF
     output12 = concat(output12,trim(dlrec->seq[d1.seq].output_line[jcnt].column1,3)), output24 =
     concat(output24,trim(dlrec->seq[d1.seq].output_line[jcnt].column2,3))
   ENDFOR
   IF (textlen(trim(output12,3)) <= 0)
    output12 = "No Intake found in the last 12 hours."
   ENDIF
   IF (textlen(trim(output24,3)) <= 0)
    output24 = "No output found in the last 24 hours."
   ENDIF
   print_weight = trim(format(dlrec->seq[d1.seq].weight_change,"##.##")), total_delta = dlrec->seq[d1
   .seq].weight_up_down, saved_unit = dlrec->seq[d1.seq].weight_tot_unit,
   weightchange = concat("Weights ",total_delta,print_weight)
   FOR (jcnt = 1 TO size(dlrec->seq[d1.seq].weights,5))
     IF (textlen(trim(weightin,3)) > 0)
      weightin = concat(weightin,char(10))
     ENDIF
     weightin = concat(weightin,dlrec->seq[d1.seq].weights[jcnt].weight_dt_tm," ",dlrec->seq[d1.seq].
      weights[jcnt].weight_value," ",
      dlrec->seq[d1.seq].weights[jcnt].weight_unit)
     IF (jcnt=3)
      jcnt = size(dlrec->seq[d1.seq].weights,5)
     ENDIF
   ENDFOR
   IF (jcnt=0)
    weightin = "No Weights Charted"
   ENDIF
   IF (textlen(trim(output12,3)) <= 0)
    output12 = "No output found in the last 12 hours.", weightout = weightin, weightin = " "
   ENDIF
   IF (textlen(trim(output24,3)) <= 0)
    output24 = "No output found in the last 24 hours."
   ENDIF
   d0 = inouttable(rpt_render,8.5,becount)
   IF ((ycol > (725 - 32)))
    breakpage
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
        breakpage
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
        breakpage
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
   prob = " ", dx = " ", all = " "
   FOR (lcnt = 1 TO dlrec->seq[d1.seq].prob_diag_all_cnt)
     IF (textlen(trim(prob,3)) > 0)
      prob = concat(prob,char(10))
     ENDIF
     IF (textlen(trim(dx,3)) > 0)
      dx = concat(dx,char(10))
     ENDIF
     IF (textlen(trim(all,3)) > 0)
      all = concat(all,char(10))
     ENDIF
     prob = concat(prob,trim(dlrec->seq[d1.seq].prob_diag_all[lcnt].column1,3)), dx = concat(dx,trim(
       dlrec->seq[d1.seq].prob_diag_all[lcnt].column2,3)), all = concat(all,trim(dlrec->seq[d1.seq].
       prob_diag_all[lcnt].column3,3))
   ENDFOR
   IF (textlen(trim(prob,3)) <= 0)
    prob = "No Problems found for patient."
   ENDIF
   IF (textlen(trim(dx,3)) <= 0)
    dx = "No Diagnoses found for encounter."
   ENDIF
   IF (textlen(trim(all,3)) <= 0)
    all = "No Allergies found for patient."
   ENDIF
   d0 = prob_dx_all(rpt_render,8.5,becount)
   IF ((ycol > (725 - 16)))
    breakpage
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
      breakpage
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
    ycol = (ycol+ 8), row + 1
   ENDIF
   dietorders = " "
   FOR (jcnt = 1 TO size(dlrec->seq[d1.seq].diets,5))
    IF (textlen(trim(dietorders,3)) > 0)
     dietorders = concat(dietorders,char(10))
    ENDIF
    ,dietorders = concat(dietorders,dlrec->seq[d1.seq].diets[jcnt].orderable," ",dlrec->seq[d1.seq].
     diets[jcnt].clinical_display_line)
   ENDFOR
   IF (textlen(trim(dietorders,3)) <= 0)
    dietorders = "No diets found for patient."
   ENDIF
   d0 = diet(rpt_render,8.5,becount)
   IF ((ycol > (725 - 24)))
    breakpage
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
     IF (size(tempstring) < 120)
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      tempstring, ycol = (ycol+ 8)
     ELSE
      row + 0
     ENDIF
    ENDFOR
   ENDIF
   FOR (medtypecnt = 1 TO 4)
     stat = alterlist(temprec->qual,0), meds1 = " ", meds2 = " ",
     meds3 = " ", medtype = " ", lmed = 0
     FOR (lmed = 1 TO 100)
      stat = alterlist(temprec->qual,lmed),
      IF (medtypecnt=1)
       medtype = "Home meds:", temprec->qual[lmed].med = dlrec->seq[d1.seq].homemeds[lmed].med
       IF (lmed >= size(dlrec->seq[d1.seq].homemeds,5))
        lmed = 100
       ENDIF
      ELSEIF (medtypecnt=2)
       medtype = "Scheduled meds:", temprec->qual[lmed].med = dlrec->seq[d1.seq].scheduledmeds[lmed].
       med
       IF (lmed >= size(dlrec->seq[d1.seq].scheduledmeds,5))
        lmed = 100
       ENDIF
      ELSEIF (medtypecnt=3)
       medtype = "PRN Meds:", temprec->qual[lmed].med = dlrec->seq[d1.seq].prnmeds[lmed].med
       IF (lmed >= size(dlrec->seq[d1.seq].prnmeds,5))
        lmed = 100
       ENDIF
      ELSEIF (medtypecnt=4)
       medtype = "IV Fluids", temprec->qual[lmed].med = dlrec->seq[d1.seq].ivfluids[lmed].med
       IF (lmed >= size(dlrec->seq[d1.seq].ivfluids,5))
        lmed = 100
       ENDIF
      ENDIF
     ENDFOR
     recsize = size(temprec->qual,5), modval = mod(recsize,3), colcnt1 = cnvtint((recsize/ 3)),
     colcnt2 = (colcnt1 * 2), colcnt3 = recsize
     IF (modval=2)
      colcnt1 = (colcnt1+ 1), colcnt2 = (colcnt2+ 2)
     ELSEIF (modval=1)
      colcnt1 = (colcnt1+ modval), colcnt2 = (colcnt2+ 1)
     ENDIF
     FOR (x = 1 TO recsize)
       IF (x <= colcnt1)
        meds1 = concat(meds1,trim(build(x),3),") ",temprec->qual[x].med,char(10))
       ELSEIF (x > colcnt1
        AND x <= colcnt2)
        meds2 = concat(meds2,trim(build(x),3),") ",temprec->qual[x].med,char(10))
       ELSEIF (x > colcnt2)
        meds3 = concat(meds3,trim(build(x),3),") ",temprec->qual[x].med,char(10))
       ENDIF
     ENDFOR
     d0 = meds(rpt_render,8.5,becount)
   ENDFOR
   IF ((ycol > (725 - 24)))
    breakpage
   ENDIF
   FOR (lcnt = 1 TO dlrec->seq[d1.seq].med_line_cnt)
     IF (ycol > 725)
      breakpage
     ENDIF
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     dlrec->seq[d1.seq].med_line[lcnt].column1, xcol = 215, row + 1,
     CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].med_line[lcnt].column2, xcol = 400,
     row + 1,
     CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].med_line[lcnt].column3,
     ycol = (ycol+ 8), row + 1
   ENDFOR
   d0 = genlabhead(rpt_render)
   IF ((ycol > (725 - 24)))
    breakpage
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}General Lab Results in last 24 hours{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].lab_line_cnt > 0))
    FOR (lcnt = 1 TO dlrec->seq[d1.seq].lab_line_cnt)
      IF (ycol > 725)
       breakpage
      ENDIF
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      dlrec->seq[d1.seq].lab_line[lcnt].column1, xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].lab_line[lcnt].column2, xcol = 400,
      row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].lab_line[lcnt].column3,
      ycol = (ycol+ 8), row + 1, labbold1 = 0,
      labbold2 = 0, labbold3 = 0, labunder1 = 0,
      labunder2 = 0, labunder3 = 0
      IF (findstring("{b}",dlrec->seq[d1.seq].lab_line[lcnt].column1))
       labbold1 = 1
      ENDIF
      IF (findstring("{b}",dlrec->seq[d1.seq].lab_line[lcnt].column2))
       labbold2 = 1
      ENDIF
      IF (findstring("{b}",dlrec->seq[d1.seq].lab_line[lcnt].column3))
       labbold3 = 1
      ENDIF
      IF (findstring("{u}",dlrec->seq[d1.seq].lab_line[lcnt].column1))
       labunder1 = 1
      ENDIF
      IF (findstring("{u}",dlrec->seq[d1.seq].lab_line[lcnt].column2))
       labunder2 = 1
      ENDIF
      IF (findstring("{u}",dlrec->seq[d1.seq].lab_line[lcnt].column3))
       labunder3 = 1
      ENDIF
      dlrec->seq[d1.seq].lab_line[lcnt].column1 = replace(dlrec->seq[d1.seq].lab_line[lcnt].column1,
       "{b}",""), dlrec->seq[d1.seq].lab_line[lcnt].column1 = replace(dlrec->seq[d1.seq].lab_line[
       lcnt].column1,"{u}",""), dlrec->seq[d1.seq].lab_line[lcnt].column2 = replace(dlrec->seq[d1.seq
       ].lab_line[lcnt].column2,"{b}",""),
      dlrec->seq[d1.seq].lab_line[lcnt].column2 = replace(dlrec->seq[d1.seq].lab_line[lcnt].column2,
       "{u}",""), dlrec->seq[d1.seq].lab_line[lcnt].column3 = replace(dlrec->seq[d1.seq].lab_line[
       lcnt].column3,"{b}",""), dlrec->seq[d1.seq].lab_line[lcnt].column3 = replace(dlrec->seq[d1.seq
       ].lab_line[lcnt].column3,"{u}",""),
      labs1 = dlrec->seq[d1.seq].lab_line[lcnt].column1, labs2 = dlrec->seq[d1.seq].lab_line[lcnt].
      column2, labs3 = dlrec->seq[d1.seq].lab_line[lcnt].column3,
      d0 = labstable(rpt_render,8.5,becount)
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Labs found on encounter in last 24 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   FOR (xcnt = 1 TO 4)
     ordercol1 = " ", ordercol2 = " "
     IF (xcnt=1)
      ordertitle = "Radiology orders:", recsize = size(dlrec->seq[d1.seq].rad_orders,5)
     ELSEIF (xcnt=2)
      ordertitle = "micro orders:", recsize = size(dlrec->seq[d1.seq].micro_orders,5)
     ELSEIF (xcnt=3)
      ordertitle = "Blood bank orders:", recsize = size(dlrec->seq[d1.seq].blood_bank_orders,5)
     ELSEIF (xcnt=4)
      ordertitle = "Other orders:", recsize = size(dlrec->seq[d1.seq].orders,5)
     ENDIF
     modval = mod(recsize,2), colcnt1 = cnvtint((recsize/ 2)), colcnt2 = (colcnt1 * 2)
     IF (modval=1)
      colcnt1 = (colcnt1+ modval), colcnt2 = (colcnt2+ 1)
     ENDIF
     FOR (ocnt = 1 TO recsize)
      IF (xcnt=1)
       order_string = concat(dlrec->seq[d1.seq].rad_orders[ocnt].order_date," ",trim(dlrec->seq[d1
         .seq].rad_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].rad_orders[ocnt].order_status)
        )
      ELSEIF (xcnt=2)
       order_string = concat(dlrec->seq[d1.seq].micro_orders[ocnt].order_date," ",trim(dlrec->seq[d1
         .seq].micro_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].micro_orders[ocnt].
         order_status))
      ELSEIF (xcnt=3)
       order_string = concat(dlrec->seq[d1.seq].blood_bank_orders[ocnt].order_date," ",trim(dlrec->
         seq[d1.seq].blood_bank_orders[ocnt].orderable)," ",trim(dlrec->seq[d1.seq].
         blood_bank_orders[ocnt].order_status))
      ELSEIF (xcnt=4)
       order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable)
      ENDIF
      ,
      IF (ocnt <= colcnt1)
       ordercol1 = concat(ordercol1,order_string,char(10))
      ELSE
       ordercol2 = concat(ordercol2,order_string,char(10))
      ENDIF
     ENDFOR
     IF (recsize <= 0)
      IF (xcnt=1)
       ordercol1 = "No Radiology Orders in last 72 hours."
      ELSEIF (xcnt=2)
       ordercol1 = "No Micro Orders in last 72 hours."
      ELSEIF (xcnt=3)
       ordercol1 = "No Blood Bank Orders in last 72 hours."
      ELSEIF (xcnt=4)
       ordercol1 = "No Other order Info"
      ENDIF
     ENDIF
     d0 = orders(rpt_render,8.5,becount)
   ENDFOR
   IF ((ycol > (725 - 24)))
    breakpage
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Radiology, Micro, Blood Bank Orders in the last 72 hours{endb}{endu}", ycol = (ycol+ 8),
   row + 1
   IF ((dlrec->seq[d1.seq].rad_count > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].rad_count)
     IF (ycol > 725)
      breakpage
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
      breakpage
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
    breakpage
   ENDIF
   IF ((dlrec->seq[d1.seq].blood_bank_labs > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].blood_bank_labs)
     IF (ycol > 725)
      breakpage
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
    breakpage
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Other Info (DVT Prophylaxis,", " Urinary Catheters, Restraints, Code Status){endb}{endu}",
   ycol = (ycol+ 8),
   row + 1, offset = 0
   IF ((dlrec->seq[d1.seq].total_orders > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].total_orders)
     IF (ycol > 725)
      breakpage
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
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Other Info found on encounter.", ycol = (ycol+ 8), row + 1
   ENDIF
   FOR (ncnt = 1 TO size(dlrec->seq[d1.seq].sticky_notes,5))
     stickynotes = concat(stickynotes,trim(dlrec->seq[d1.seq].sticky_notes[ncnt].note_date)," ",trim(
       dlrec->seq[d1.seq].sticky_notes[ncnt].prsnl_name),"- ",
      trim(dlrec->seq[d1.seq].sticky_notes[ncnt].notes),char(10))
   ENDFOR
   IF (size(dlrec->seq[d1.seq].sticky_notes,5)=0)
    stickynotes = "No notes found on patient."
   ENDIF
   d0 = sticky(rpt_render,8.5,becount)
   IF ((ycol > (725 - 24)))
    breakpage
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Rounds/Sticky Notes{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].total_sticky_notes > 0))
    FOR (ncnt = 1 TO dlrec->seq[d1.seq].total_sticky_notes)
      IF (ycol > 725)
       breakpage
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
  FOOT  encntr_id
   IF ((req2->pagebreak=2)
    AND (encntrcnt < dlrec->encntr_total))
    breakpage
   ENDIF
  WITH dio = postscript, maxcol = 800, maxrow = 800
 ;end select
 IF (ver="New")
  SET d0 = finalizereport(printer_disp)
 ENDIF
 FREE RECORD dlrec
 FREE RECORD pt
#end_of_program
END GO
