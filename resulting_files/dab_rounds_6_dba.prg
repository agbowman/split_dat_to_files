CREATE PROGRAM dab_rounds_6:dba
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
     2 total_lab_results = i4
     2 lab_results[*]
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
     2 total_sticky_notes = i4
     2 sticky_notes[*]
       3 notes = vc
       3 note_date = vc
       3 prsnl_name = vc
 )
 DECLARE total_rows = i2
 DECLARE save_total_rows = i2
 DECLARE max_total_rows = i2
 DECLARE tot_cnt = i2
 DECLARE printed_dt_tm = vc
 DECLARE printed_by = vc
 DECLARE printed_on = vc
 SET printed_on = format(cnvtdatetime(curdate,curtime),"mm/dd/yy hh:mm;;d")
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
 DECLARE temp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"TEMPERATURE"))
 DECLARE pulse_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE systolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE diastolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE resp_rate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE"))
 DECLARE o2_sat_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"OXYGENSATURATION"))
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
 DECLARE laboratory_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE gen_lab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
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
     CALL print(calcpos(xcol,ycol)), "*** Baystate Rounds Report ***",
     xcol = 215,
     CALL print(calcpos(xcol,ycol)), "Printed on: ",
     printed_on, xcol = 400,
     CALL print(calcpos(xcol,ycol)),
     "Printed by: ", printed_by, ycol = (ycol+ 8),
     row + 1, xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)), line, ycol = (ycol+ 8),
     row + 1, xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     "{b}", "Location", xcol = 100,
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
  SET dlrec->seq[1].encntr_id = 28519921
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
   ELSE
    dlrec->seq[dd.seq].diagnosis[diag_cnt].source_string = d.diag_ftdesc
   ENDIF
   dlrec->seq[dd.seq].diagnosis[diag_cnt].source_identifier = n.source_identifier, dlrec->seq[dd.seq]
   .diagnosis[diag_cnt].diag_dt_tm = substring(1,14,format(d.diag_dt_tm,"@SHORTDATETIME;;Q")), dlrec
   ->seq[dd.seq].diagnosis[diag_cnt].diag_type_desc = uar_get_code_display(d.diag_type_cd)
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
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != allergy_canceled_cd)
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
     IF (size(trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string)) > 0
      AND size(trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string)) <= 45)
      total_rows = (total_rows+ 1)
      IF ((dlrec->seq[d1.seq].prob_diag_all_cnt=total_rows))
       stat = alterlist(dlrec->seq[d1.seq].prob_diag_all,(total_rows+ 10)), dlrec->seq[d1.seq].
       prob_diag_all_cnt = (total_rows+ 10)
      ENDIF
      dlrec->seq[d1.seq].prob_diag_all[total_rows].column2 = trim(dlrec->seq[d1.seq].diagnosis[dcnt].
       source_string)
     ELSEIF (size(trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string)) > 0)
      tempstring = trim(dlrec->seq[d1.seq].diagnosis[dcnt].source_string), wrapcol = 45, eol = size(
       tempstring),
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
  ORDER BY o.encntr_id, o.ordered_as_mnemonic, o.order_id,
   od.action_sequence
  HEAD o.encntr_id
   med_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].meds,10), sched_cnt = 0,
   prn_cnt = 0, iv_cnt = 0
  HEAD o.ordered_as_mnemonic
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
   IF (trim(o.ordered_as_mnemonic) > "") concat(trim(o.ordered_as_mnemonic),"|")
   ELSE concat(trim(o.order_mnemonic),"|")
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
  FOOT  o.ordered_as_mnemonic
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
  WHERE (dlrec->seq[d1.seq].total_meds > 0)
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
        dlrec->seq[d1.seq].med_line[total_rows].column1 = concat(" ",printstring)
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=3))
        dlrec->seq[d1.seq].med_line[total_rows].column2 = concat(" ",printstring)
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
        dlrec->seq[d1.seq].med_line[total_rows].column1 = printstring
       ELSEIF ((dlrec->seq[d1.seq].meds[mcnt].type=3))
        dlrec->seq[d1.seq].med_line[total_rows].column2 = printstring
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
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=1))
      med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,dlrec->seq[d1.seq].
         meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,dlrec->seq[d1.seq].meds[mcnt].
         rate,dlrec->seq[d1.seq].meds[mcnt].strength_dose,
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
   max_total_rows = total_rows, total_rows = 0
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=3))
      med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,dlrec->seq[d1.seq].
         meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,dlrec->seq[d1.seq].meds[mcnt].
         rate,dlrec->seq[d1.seq].meds[mcnt].strength_dose,
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
   IF (total_rows > max_total_rows)
    max_total_rows = total_rows
   ENDIF
   total_rows = 0
   FOR (mcnt = 1 TO dlrec->seq[d1.seq].total_meds)
     IF ((dlrec->seq[d1.seq].meds[mcnt].type=4))
      med_string = replace(trim(concat(dlrec->seq[d1.seq].meds[mcnt].mnemonic,dlrec->seq[d1.seq].
         meds[mcnt].dose,dlrec->seq[d1.seq].meds[mcnt].freetext_dose,dlrec->seq[d1.seq].meds[mcnt].
         rate,dlrec->seq[d1.seq].meds[mcnt].strength_dose,
         dlrec->seq[d1.seq].meds[mcnt].volume_dose,dlrec->seq[d1.seq].meds[mcnt].diluent,dlrec->seq[
         d1.seq].meds[mcnt].route,dlrec->seq[d1.seq].meds[mcnt].iv_prn,dlrec->seq[d1.seq].meds[mcnt].
         freq)),"|"," ",0)
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
   IF (total_rows > max_total_rows)
    max_total_rows = total_rows
   ENDIF
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].med_line,max_total_rows), dlrec->seq[d1.seq].med_line_cnt =
   max_total_rows
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event ce
  PLAN (dd)
   JOIN (ce
   WHERE (ce.person_id=dlrec->seq[dd.seq].person_id)
    AND ce.event_cd IN (temp_cd, pulse_cd, resp_rate_cd, systolic_bp_cd, diastolic_bp_cd,
   o2_sat_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ce.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
    AND ce.view_level=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd, pending_cd)))
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   stat = alterlist(dlrec->seq[dd.seq].vitals,10), vit_cnt = 0, vit_cnt = (vit_cnt+ 1)
   IF (mod(vit_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].vitals,(vit_cnt+ 10))
   ENDIF
   low_temp_result = fillstring(10," "), high_temp_result = fillstring(10," "), low_pulse_result =
   fillstring(10," "),
   high_pulse_result = fillstring(10," "), low_sbp_result = fillstring(10," "), high_sbp_result =
   fillstring(10," "),
   low_dbp_result = fillstring(10," "), high_dbp_result = fillstring(10," "), low_rr_result =
   fillstring(10," "),
   high_rr_result = fillstring(10," "), low_o2sat_result = fillstring(10," "), high_o2sat_result =
   fillstring(10," ")
  HEAD ce.event_cd
   IF (ce.event_cd=temp_cd)
    cnt_temp = 0, dlrec->seq[dd.seq].vitals[vit_cnt].temp_result = trim(ce.result_val)
   ELSEIF (ce.event_cd=pulse_cd)
    cnt_pulse = 0, dlrec->seq[dd.seq].vitals[vit_cnt].pulse_result = trim(ce.result_val)
   ELSEIF (ce.event_cd=systolic_bp_cd)
    cnt_sbp = 0, dlrec->seq[dd.seq].vitals[vit_cnt].systolic_bp_result = trim(ce.result_val)
   ELSEIF (ce.event_cd=diastolic_bp_cd)
    cnt_dbp = 0, dlrec->seq[dd.seq].vitals[vit_cnt].diastolic_bp_result = trim(ce.result_val)
   ELSEIF (ce.event_cd=resp_rate_cd)
    cnt_rr = 0, dlrec->seq[dd.seq].vitals[vit_cnt].resp_rate_result = trim(ce.result_val)
   ELSEIF (ce.event_cd=o2_sat_cd)
    cnt_o2sat = 0, dlrec->seq[dd.seq].vitals[vit_cnt].o2_sat_result = trim(ce.result_val)
   ENDIF
  DETAIL
   IF (ce.event_cd=temp_cd)
    cnt_temp = (cnt_temp+ 1)
    IF (cnt_temp=1)
     low_temp_result = trim(ce.result_val), high_temp_result = trim(ce.result_val)
    ELSE
     IF (cnvtreal(low_temp_result) > cnvtreal(trim(ce.result_val)))
      low_temp_result = trim(ce.result_val)
     ELSEIF (cnvtreal(high_temp_result) < cnvtreal(trim(ce.result_val)))
      high_temp_result = trim(ce.result_val)
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=pulse_cd)
    cnt_pulse = (cnt_pulse+ 1)
    IF (cnt_pulse=1)
     low_pulse_result = trim(ce.result_val), high_pulse_result = trim(ce.result_val)
    ELSE
     IF (cnvtreal(low_pulse_result) > cnvtreal(trim(ce.result_val)))
      low_pulse_result = trim(ce.result_val)
     ELSEIF (cnvtreal(high_pulse_result) < cnvtreal(trim(ce.result_val)))
      high_pulse_result = trim(ce.result_val)
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=systolic_bp_cd)
    cnt_sbp = (cnt_sbp+ 1)
    IF (cnt_sbp=1)
     low_sbp_result = trim(ce.result_val), high_sbp_result = trim(ce.result_val)
    ELSE
     IF (cnvtreal(low_sbp_result) > cnvtreal(trim(ce.result_val)))
      low_sbp_result = trim(ce.result_val)
     ELSEIF (cnvtreal(high_sbp_result) < cnvtreal(trim(ce.result_val)))
      high_sbp_result = trim(ce.result_val)
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=diastolic_bp_cd)
    cnt_dbp = (cnt_dbp+ 1)
    IF (cnt_dbp=1)
     low_dbp_result = trim(ce.result_val), high_dbp_result = trim(ce.result_val)
    ELSE
     IF (cnvtreal(low_dbp_result) > cnvtreal(trim(ce.result_val)))
      low_dbp_result = trim(ce.result_val)
     ELSEIF (cnvtreal(high_dbp_result) < cnvtreal(trim(ce.result_val)))
      high_dbp_result = trim(ce.result_val)
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=resp_rate_cd)
    cnt_rr = (cnt_rr+ 1)
    IF (cnt_rr=1)
     low_rr_result = trim(ce.result_val), high_rr_result = trim(ce.result_val)
    ELSE
     IF (cnvtreal(low_rr_result) > cnvtreal(trim(ce.result_val)))
      low_rr_result = trim(ce.result_val)
     ELSEIF (cnvtreal(high_rr_result) < cnvtreal(trim(ce.result_val)))
      high_rr_result = trim(ce.result_val)
     ENDIF
    ENDIF
   ELSEIF (ce.event_cd=o2_sat_cd)
    cnt_o2sat = (cnt_o2sat+ 1)
    IF (cnt_o2sat=1)
     low_o2sat_result = trim(ce.result_val), high_o2sat_result = trim(ce.result_val)
    ELSE
     IF (cnvtreal(low_o2sat_result) > cnvtreal(trim(ce.result_val)))
      low_o2sat_result = trim(ce.result_val)
     ELSEIF (cnvtreal(high_o2sat_result) < cnvtreal(trim(ce.result_val)))
      high_o2sat_result = trim(ce.result_val)
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce.encntr_id
   dlrec->seq[dd.seq].vitals[vit_cnt].temp_range = concat(low_temp_result,"-",high_temp_result),
   dlrec->seq[dd.seq].vitals[vit_cnt].pulse_range = concat(low_pulse_result,"-",high_pulse_result),
   dlrec->seq[dd.seq].vitals[vit_cnt].systolic_bp_range = concat(low_sbp_result,"-",high_sbp_result),
   dlrec->seq[dd.seq].vitals[vit_cnt].diastolic_bp_range = concat(low_dbp_result,"-",high_dbp_result),
   dlrec->seq[dd.seq].vitals[vit_cnt].resp_rate_range = concat(low_rr_result,"-",high_rr_result),
   dlrec->seq[dd.seq].vitals[vit_cnt].o2_sat_range = concat(low_o2sat_result,"-",high_o2sat_result),
   dlrec->seq[dd.seq].total_vitals = vit_cnt, stat = alterlist(dlrec->seq[dd.seq].vitals,vit_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  event_display = uar_get_code_display(ce.event_cd)
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   orders o,
   clinical_event ce
  PLAN (dd)
   JOIN (o
   WHERE (o.encntr_id=dlrec->seq[dd.seq].encntr_id)
    AND o.activity_type_cd=gen_lab_cd
    AND o.template_order_flag IN (0, 2))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
    AND ce.event_end_dt_tm <= cnvtdatetime(curdate,curtime)
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd, pending_cd))
    AND ce.result_val > " ")
  ORDER BY ce.encntr_id, event_display, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   lab_cnt = 0, stat = alterlist(dlrec->seq[dd.seq].lab_results,10)
  HEAD ce.event_cd
   most_recent_date = " ", most_recent_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
  DETAIL
   lab_cnt = (lab_cnt+ 1)
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
      lab_string = concat(dlrec->seq[d1.seq].lab_results[lcnt].date," ",dlrec->seq[d1.seq].
       lab_results[lcnt].event_cd_disp," ",trim(dlrec->seq[d1.seq].lab_results[lcnt].result)),
      total_rows = (total_rows+ 1), stat = alterlist(dlrec->seq[d1.seq].lab_line,total_rows),
      dlrec->seq[d1.seq].lab_line_cnt = total_rows
      IF (trim(dlrec->seq[d1.seq].lab_results[lcnt].normalcy_disp) IN ("C", "C *"))
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
      lab_string = concat(dlrec->seq[d1.seq].lab_results[lcnt].date," ",dlrec->seq[d1.seq].
       lab_results[lcnt].event_cd_disp," ",trim(dlrec->seq[d1.seq].lab_results[lcnt].result)),
      total_rows = (total_rows+ 1)
      IF (trim(dlrec->seq[d1.seq].lab_results[lcnt].normalcy_disp) IN ("C", "C *"))
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
      lab_string = concat(dlrec->seq[d1.seq].lab_results[lcnt].date," ",dlrec->seq[d1.seq].
       lab_results[lcnt].event_cd_disp," ",trim(dlrec->seq[d1.seq].lab_results[lcnt].result)),
      total_rows = (total_rows+ 1)
      IF (trim(dlrec->seq[d1.seq].lab_results[lcnt].normalcy_disp) IN ("C", "C *"))
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
  IF (o.hna_order_mnemonic="Catheter*") 1
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
    AND ((o.activity_type_cd IN (micro_cd, blood_bank_cd)
    AND o.current_start_dt_tm >= cnvtdatetime((curdate - 1),curtime)) OR (((o.activity_type_cd=
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
    seq[dd.seq].orders,10)
  HEAD sort_order
   row + 0
  HEAD o.orig_order_dt_tm
   row + 0
  HEAD o.hna_order_mnemonic
   ord_cnt = (ord_cnt+ 1)
   IF (mod(ord_cnt,10)=1)
    stat = alterlist(dlrec->seq[dd.seq].orders,(ord_cnt+ 10))
   ENDIF
   IF (o.hna_order_mnemonic="Catheter*")
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
    ord_cnt), dlrec->seq[dd.seq].total_orders = ord_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[dd.seq].encntr_id, io_type = "Intake", 12hr_ind =
  IF (ceo.event_end_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),- ((720/ 1440.0)))) 1
  ELSE 0
  ENDIF
  ,
  event_cd = ceo.event_cd, event_end_dt_tm = ceo.event_end_dt_tm, result_val = ceo.result_val,
  event_display = trim(o.ordered_as_mnemonic,3), result_status = ceo.result_status_cd
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event ceo,
   orders o
  PLAN (dd)
   JOIN (ceo
   WHERE (ceo.person_id=dlrec->seq[dd.seq].person_id)
    AND ceo.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
    AND ceo.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ceo.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
    AND ceo.result_val > " "
    AND ceo.result_val != "0.*"
    AND ceo.view_level=1
    AND  NOT (ceo.result_status_cd IN (inerror_cd, notdone_cd))
    AND ceo.event_title_text="IVPARENT")
   JOIN (o
   WHERE o.order_id=ceo.order_id)
  ORDER BY encntr_id, event_cd, io_type,
   event_end_dt_tm DESC
  HEAD encntr_id
   stat = alterlist(dlrec->seq[dd.seq].titrate,1), io_cnt = 0, 12_hour_i_total = 0,
   12_hour_i_comp_total = 0, 12_hour_i_comp_line = "", 24_hour_i_total = 0,
   24_hour_i_comp_total = 0, 24_hour_i_comp_line = ""
  HEAD event_cd
   12_hour_i_comp_total = 0, 24_hour_i_comp_total = 0
  DETAIL
   IF (12hr_ind=1)
    12_hour_i_total = (12_hour_i_total+ cnvtreal(result_val))
   ELSE
    24_hour_i_total = (24_hour_i_total+ cnvtreal(result_val))
   ENDIF
   IF (12hr_ind=1)
    12_hour_i_comp_total = (12_hour_i_comp_total+ cnvtreal(result_val))
   ELSE
    24_hour_i_comp_total = (24_hour_i_comp_total+ cnvtreal(result_val))
   ENDIF
  FOOT  event_cd
   24_hour_i_comp_total = (24_hour_i_comp_total+ 12_hour_i_comp_total)
   IF (12_hour_i_comp_total > 0
    AND (dlrec->seq[dd.seq].titrate[1].12_io_line > " "))
    dlrec->seq[dd.seq].titrate[1].12_io_line = concat(dlrec->seq[dd.seq].titrate[1].12_io_line,",",
     trim(cnvtstring(12_hour_i_comp_total))," ",trim(event_display))
   ELSEIF (12_hour_i_comp_total > 0)
    dlrec->seq[dd.seq].titrate[1].12_io_line = concat(trim(cnvtstring(12_hour_i_comp_total))," ",trim
     (event_display))
   ENDIF
   IF (24_hour_i_comp_total > 0
    AND (dlrec->seq[dd.seq].titrate[1].24_io_line > " "))
    dlrec->seq[dd.seq].titrate[1].24_io_line = concat(dlrec->seq[dd.seq].titrate[1].24_io_line,",",
     trim(cnvtstring(24_hour_i_comp_total))," ",trim(event_display))
   ELSEIF (24_hour_i_comp_total > 0)
    dlrec->seq[dd.seq].titrate[1].24_io_line = concat(trim(cnvtstring(24_hour_i_comp_total))," ",trim
     (event_display))
   ENDIF
  FOOT  encntr_id
   IF (12_hour_i_total > 0)
    dlrec->seq[dd.seq].titrate[1].12_io_total = trim(cnvtstring(12_hour_i_total),3)
   ENDIF
   IF (((24_hour_i_total+ 12_hour_i_total) > 0))
    dlrec->seq[dd.seq].titrate[1].24_io_total = trim(cnvtstring((24_hour_i_total+ 12_hour_i_total)),3
     )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[dd.seq].encntr_id, io_type =
  IF (vesc.event_set_name_key IN ("MISCOUTPUTSECTION", "INSENSIBLELOSSVOL", "IRRIGANTOUTPUTSECTION",
  "CBIOUTPUTSECTION", "DIALYSISOUTPUTSECTION",
  "DRAINS", "GIOUTPUTSECTION", "STOOLOUTPUTSECTION", "URINEOUTPUTSECTION")) "Output"
  ELSEIF (vesc.event_set_name_key IN ("DIALYSISINTAKESECTION", "CBIINPUTSECTION", "MISCINTAKESECTION",
  "IRRIGANTINTAKESECTION", "DILUENTS",
  "PARENTERALNUTRITIONSECTION", "BLOODPRODUCTSSECTION", "IVS", "FEEDINGSSECTION", "ORALINTAKESECTION"
  )) "Intake"
  ENDIF
  , 12hr_ind =
  IF (ce.event_end_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime),- ((720/ 1440.0)))) 1
  ELSE 0
  ENDIF
  ,
  event_cd = ce.event_cd, event_end_dt_tm = ce.event_end_dt_tm, result_val = ce.result_val,
  event_display = trim(uar_get_code_display(ce.event_cd),3), result_status = ce.result_status_cd
  FROM v500_event_set_code vesc,
   v500_event_set_explode vese,
   (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   clinical_event ce
  PLAN (dd)
   JOIN (ce
   WHERE (ce.person_id=dlrec->seq[dd.seq].person_id)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ((ce.encntr_id+ 0)=dlrec->seq[dd.seq].encntr_id)
    AND ce.result_val > " "
    AND ce.result_val != "0.*"
    AND ce.view_level=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND  NOT ( EXISTS (
   (SELECT
    ce1.parent_event_id
    FROM clinical_event ce1
    WHERE ce1.parent_event_id=ce.parent_event_id
     AND ce1.event_title_text="IVPARENT"))))
   JOIN (vese
   WHERE vese.event_cd=ce.event_cd)
   JOIN (vesc
   WHERE vesc.event_set_cd=vese.event_set_cd
    AND cnvtupper(vesc.event_set_name_key) IN ("MISCOUTPUTSECTION", "INSENSIBLELOSSVOL",
   "IRRIGANTOUTPUTSECTION", "CBIOUTPUTSECTION", "DIALYSISOUTPUTSECTION",
   "DRAINS", "GIOUTPUTSECTION", "STOOLOUTPUTSECTION", "URINEOUTPUTSECTION", "DIALYSISINTAKESECTION",
   "CBIINPUTSECTION", "MISCINTAKESECTION", "IRRIGANTINTAKESECTION", "DILUENTS",
   "PARENTERALNUTRITIONSECTION",
   "BLOODPRODUCTSSECTION", "IVS", "FEEDINGSSECTION", "ORALINTAKESECTION"))
  ORDER BY encntr_id, vesc.event_set_name_key, event_cd,
   io_type, event_end_dt_tm DESC
  HEAD encntr_id
   dlrec->seq[dd.seq].total_io = 4, stat = alterlist(dlrec->seq[dd.seq].io,4), io_cnt = 0,
   12_hour_i_total = 0, 12_hour_o_total = 0, 12_hour_i_comp_total = 0,
   12_hour_i_comp_line = "", 12_hour_o_comp_total = 0, 12_hour_o_comp_line = "",
   24_hour_i_total = 0, 24_hour_o_total = 0, 24_hour_i_comp_total = 0,
   24_hour_i_comp_line = "", 24_hour_o_comp_total = 0, 24_hour_o_comp_line = ""
  HEAD event_cd
   12_hour_i_comp_total = 0, 12_hour_o_comp_total = 0, 24_hour_i_comp_total = 0,
   24_hour_o_comp_total = 0
  DETAIL
   IF (trim(uar_get_code_display(event_cd)) != "*Frequency"
    AND trim(uar_get_code_display(event_cd)) != "*Count")
    IF (12hr_ind=1)
     IF (io_type="Intake")
      12_hour_i_total = (12_hour_i_total+ cnvtreal(result_val))
     ELSEIF (io_type="Output")
      12_hour_o_total = (12_hour_o_total+ cnvtreal(result_val))
     ENDIF
    ELSE
     IF (io_type="Intake")
      24_hour_i_total = (24_hour_i_total+ cnvtreal(result_val))
     ELSEIF (io_type="Output")
      24_hour_o_total = (24_hour_o_total+ cnvtreal(result_val))
     ENDIF
    ENDIF
   ENDIF
   IF (12hr_ind=1)
    IF (io_type="Intake")
     12_hour_i_comp_total = (12_hour_i_comp_total+ cnvtreal(result_val))
    ELSEIF (io_type="Output")
     12_hour_o_comp_total = (12_hour_o_comp_total+ cnvtreal(result_val))
    ENDIF
   ELSE
    IF (io_type="Intake")
     24_hour_i_comp_total = (24_hour_i_comp_total+ cnvtreal(result_val))
    ELSEIF (io_type="Output")
     24_hour_o_comp_total = (24_hour_o_comp_total+ cnvtreal(result_val))
    ENDIF
   ENDIF
  FOOT  event_cd
   24_hour_i_comp_total = (24_hour_i_comp_total+ 12_hour_i_comp_total), 24_hour_o_comp_total = (
   24_hour_o_comp_total+ 12_hour_o_comp_total)
   IF (12_hour_i_comp_total > 0
    AND (dlrec->seq[dd.seq].io[1].io_line > " ")
    AND (dlrec->seq[dd.seq].io[1].type="I")
    AND (dlrec->seq[dd.seq].io[1].hour_range="12"))
    dlrec->seq[dd.seq].io[1].io_line = concat(dlrec->seq[dd.seq].io[1].io_line,",",trim(cnvtstring(
       12_hour_i_comp_total))," ",trim(event_display))
   ELSEIF (12_hour_i_comp_total > 0)
    dlrec->seq[dd.seq].io[1].type = "I", dlrec->seq[dd.seq].io[1].hour_range = "12", dlrec->seq[dd
    .seq].io[1].io_line = concat(trim(cnvtstring(12_hour_i_comp_total))," ",trim(event_display))
   ENDIF
   IF (24_hour_i_comp_total > 0
    AND (dlrec->seq[dd.seq].io[2].io_line > " ")
    AND (dlrec->seq[dd.seq].io[2].type="I")
    AND (dlrec->seq[dd.seq].io[2].hour_range="24"))
    dlrec->seq[dd.seq].io[2].io_line = concat(dlrec->seq[dd.seq].io[2].io_line,",",trim(cnvtstring(
       24_hour_i_comp_total))," ",trim(event_display))
   ELSEIF (24_hour_i_comp_total > 0)
    dlrec->seq[dd.seq].io[2].type = "I", dlrec->seq[dd.seq].io[2].hour_range = "24", dlrec->seq[dd
    .seq].io[2].io_line = concat(trim(cnvtstring(24_hour_i_comp_total))," ",trim(event_display))
   ENDIF
   IF (12_hour_o_comp_total > 0
    AND (dlrec->seq[dd.seq].io[3].io_line > " ")
    AND (dlrec->seq[dd.seq].io[3].type="O")
    AND (dlrec->seq[dd.seq].io[3].hour_range="12"))
    dlrec->seq[dd.seq].io[3].io_line = concat(dlrec->seq[dd.seq].io[3].io_line,",",trim(cnvtstring(
       12_hour_o_comp_total))," ",trim(event_display))
   ELSEIF (12_hour_o_comp_total > 0)
    dlrec->seq[dd.seq].io[3].type = "O", dlrec->seq[dd.seq].io[3].hour_range = "12", dlrec->seq[dd
    .seq].io[3].io_line = concat(trim(cnvtstring(12_hour_o_comp_total))," ",trim(event_display))
   ENDIF
   IF (24_hour_o_comp_total > 0
    AND (dlrec->seq[dd.seq].io[4].io_line > " ")
    AND (dlrec->seq[dd.seq].io[4].type="O")
    AND (dlrec->seq[dd.seq].io[4].hour_range="24"))
    dlrec->seq[dd.seq].io[4].io_line = concat(dlrec->seq[dd.seq].io[4].io_line,",",trim(cnvtstring(
       24_hour_o_comp_total))," ",trim(event_display))
   ELSEIF (24_hour_o_comp_total > 0)
    dlrec->seq[dd.seq].io[4].type = "O", dlrec->seq[dd.seq].io[4].hour_range = "24", dlrec->seq[dd
    .seq].io[4].io_line = concat(trim(cnvtstring(24_hour_o_comp_total))," ",trim(event_display))
   ENDIF
  FOOT  encntr_id
   IF (((12_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[1].io_line > " ")))
    AND (dlrec->seq[dd.seq].titrate[1].12_io_total > " "))
    dlrec->seq[dd.seq].io[1].io_line = concat(trim(cnvtstring((12_hour_i_total+ cnvtreal(dlrec->seq[
        dd.seq].titrate[1].12_io_total))),3)," ","(",dlrec->seq[dd.seq].titrate[1].12_io_line,",",
     " ",dlrec->seq[dd.seq].io[1].io_line,")")
   ELSEIF (((12_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[1].io_line > " "))) )
    dlrec->seq[dd.seq].io[1].io_line = concat(trim(cnvtstring(12_hour_i_total),3)," ","(",dlrec->seq[
     dd.seq].io[1].io_line,")")
   ELSEIF ((dlrec->seq[dd.seq].titrate[1].12_io_total > " "))
    dlrec->seq[dd.seq].io[1].io_line = concat(trim(dlrec->seq[dd.seq].titrate[1].12_io_total,3)," ",
     "(",dlrec->seq[dd.seq].titrate[1].12_io_line,")"), dlrec->seq[dd.seq].io[1].type = "I", dlrec->
    seq[dd.seq].io[1].hour_range = "12"
   ENDIF
   IF (((((24_hour_i_total+ 12_hour_i_total) > 0)) OR ((dlrec->seq[dd.seq].io[2].io_line > " ")))
    AND (dlrec->seq[dd.seq].titrate[1].24_io_total > " "))
    dlrec->seq[dd.seq].io[2].io_line = concat(trim(cnvtstring(((24_hour_i_total+ 12_hour_i_total)+
       cnvtreal(dlrec->seq[dd.seq].titrate[1].24_io_total))),3)," ","(",dlrec->seq[dd.seq].titrate[1]
     .24_io_line,",",
     " ",dlrec->seq[dd.seq].io[2].io_line,")")
   ELSEIF (((24_hour_i_total > 0) OR ((dlrec->seq[dd.seq].io[2].io_line > " "))) )
    dlrec->seq[dd.seq].io[2].io_line = concat(trim(cnvtstring((24_hour_i_total+ 12_hour_i_total)),3),
     " ","(",dlrec->seq[dd.seq].io[2].io_line,")")
   ELSEIF ((dlrec->seq[dd.seq].titrate[1].24_io_total > " "))
    dlrec->seq[dd.seq].io[2].io_line = concat(trim(dlrec->seq[dd.seq].titrate[1].24_io_total,3)," ",
     "(",dlrec->seq[dd.seq].titrate[1].24_io_line,")"), dlrec->seq[dd.seq].io[2].type = "I", dlrec->
    seq[dd.seq].io[2].hour_range = "24"
   ENDIF
   IF (((12_hour_o_total > 0) OR ((dlrec->seq[dd.seq].io[3].io_line > " "))) )
    dlrec->seq[dd.seq].io[3].io_line = concat(trim(cnvtstring(12_hour_o_total),3)," ","(",dlrec->seq[
     dd.seq].io[3].io_line,")")
   ENDIF
   IF (((((24_hour_o_total+ 12_hour_o_total) > 0)) OR ((dlrec->seq[dd.seq].io[4].io_line > " "))) )
    dlrec->seq[dd.seq].io[4].io_line = concat(trim(cnvtstring((24_hour_o_total+ 12_hour_o_total)),3),
     " ","(",dlrec->seq[dd.seq].io[4].io_line,")")
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(dlrec->seq,5))
   IF (size(dlrec->seq[x].titrate,5) > 0
    AND size(dlrec->seq[x].io,5)=0)
    SET dlrec->seq[x].total_io = 4
    SET stat = alterlist(dlrec->seq[x].io,4)
    IF (trim(dlrec->seq[x].titrate[1].12_io_total,3) > "0")
     SET dlrec->seq[x].io[1].io_line = concat(trim(dlrec->seq[x].titrate[1].12_io_total,3)," ","(",
      trim(dlrec->seq[x].titrate[1].12_io_line,3),")")
     SET dlrec->seq[x].io[1].type = "I"
     SET dlrec->seq[x].io[1].hour_range = "12"
    ENDIF
    IF (trim(dlrec->seq[x].titrate[1].24_io_total,3) > "0")
     SET dlrec->seq[x].io[2].io_line = concat(trim(dlrec->seq[x].titrate[1].24_io_total,3)," ","(",
      trim(dlrec->seq[x].titrate[1].24_io_line,3),")")
     SET dlrec->seq[x].io[2].type = "I"
     SET dlrec->seq[x].io[2].hour_range = "24"
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[d1.seq].encntr_id
  FROM (dummyt d1  WITH seq = value(dlrec->encntr_total))
  WHERE (dlrec->seq[d1.seq].total_io > 0)
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
       printstring = substring(1,pos,tempstring)
       IF ((dlrec->seq[d1.seq].io[x].type="I"))
        i_total_rows = (i_total_rows+ 1)
        IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
         stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
         intake_line_cnt = (i_total_rows+ 10)
        ENDIF
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         dlrec->seq[d1.seq].intake_line[i_total_rows].column1 = concat(" ",printstring)
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         dlrec->seq[d1.seq].intake_line[i_total_rows].column2 = concat(" ",printstring)
        ENDIF
       ENDIF
       IF ((dlrec->seq[d1.seq].io[x].type="O"))
        o_total_rows = (o_total_rows+ 1)
        IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
         stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
         output_line_cnt = (o_total_rows+ 10)
        ENDIF
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         dlrec->seq[d1.seq].output_line[o_total_rows].column1 = concat(" ",printstring)
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         dlrec->seq[d1.seq].output_line[o_total_rows].column2 = concat(" ",printstring)
        ENDIF
       ENDIF
      ELSEIF (limit=1)
       maxlen = (maxlen - 2), printstring = substring(1,pos,tempstring)
       IF ((dlrec->seq[d1.seq].io[x].type="I"))
        i_total_rows = (i_total_rows+ 1)
        IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
         stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
         intake_line_cnt = (i_total_rows+ 10)
        ENDIF
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         dlrec->seq[d1.seq].intake_line[o_total_rows].column1 = printstring
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         dlrec->seq[d1.seq].intake_line[total_rows].column2 = printstring
        ENDIF
       ENDIF
       IF ((dlrec->seq[d1.seq].io[x].type="O"))
        o_total_rows = (o_total_rows+ 1)
        IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
         stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
         output_line_cnt = (o_total_rows+ 10)
        ENDIF
        IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
         dlrec->seq[d1.seq].output_line[total_rows].column1 = printstring
        ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
         AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
         dlrec->seq[d1.seq].output_line[total_rows].column2 = printstring
        ENDIF
       ENDIF
      ENDIF
      tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
  HEAD encntr_id
   i_max_total_rows = 0, i_total_rows = 0, o_max_total_rows = 0,
   o_total_rows = 0, total_rows = 0, stat = alterlist(dlrec->seq[d1.seq].intake_line,10),
   dlrec->seq[d1.seq].intake_line_cnt = 10, stat = alterlist(dlrec->seq[d1.seq].output_line,10),
   dlrec->seq[d1.seq].output_line_cnt = 10
  DETAIL
   FOR (x = 1 TO 2)
     IF ((dlrec->seq[d1.seq].io[x].type="I"))
      IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND size(dlrec->seq[d1.seq].io[x].io_line) <= 60
       AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
       i_total_rows = (i_total_rows+ 1)
       IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
        stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
        intake_line_cnt = (i_total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].intake_line[i_total_rows].column1 = dlrec->seq[d1.seq].io[x].io_line
      ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
       tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 60, eol = size(trim(tempstring)),
       xcol = 60, line_wrap_indent
      ENDIF
      i_max_total_rows = i_total_rows, i_total_rows = 0
      IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND size(dlrec->seq[d1.seq].io[x].io_line) <= 60
       AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
       i_total_rows = (i_total_rows+ 1)
       IF ((dlrec->seq[d1.seq].intake_line_cnt=i_total_rows))
        stat = alterlist(dlrec->seq[d1.seq].intake_line,(i_total_rows+ 10)), dlrec->seq[d1.seq].
        intake_line_cnt = (i_total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].intake_line[i_total_rows].column2 = dlrec->seq[d1.seq].io[x].io_line
      ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
       tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 60, eol = size(trim(tempstring)),
       xcol = 350, ycol = save_ycol, line_wrap_indent
      ENDIF
     ENDIF
   ENDFOR
   IF (i_total_rows > i_max_total_rows)
    i_max_total_rows = i_total_rows
   ENDIF
   i_total_rows = 0
   FOR (x = 3 TO 4)
     IF ((dlrec->seq[d1.seq].io[x].type="O"))
      IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND size(dlrec->seq[d1.seq].io[x].io_line) <= 60
       AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
       o_total_rows = (o_total_rows+ 1)
       IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
        stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
        output_line_cnt = (o_total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].output_line[o_total_rows].column1 = dlrec->seq[d1.seq].io[x].io_line
      ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND (dlrec->seq[d1.seq].io[x].hour_range="12"))
       tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 60, eol = size(trim(tempstring)),
       xcol = 60, ycol = save_ycol, line_wrap_indent
      ENDIF
      o_max_total_rows = o_total_rows, o_total_rows = 0
      IF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND size(dlrec->seq[d1.seq].io[x].io_line) <= 60
       AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
       o_total_rows = (o_total_rows+ 1)
       IF ((dlrec->seq[d1.seq].output_line_cnt=o_total_rows))
        stat = alterlist(dlrec->seq[d1.seq].output_line,(o_total_rows+ 10)), dlrec->seq[d1.seq].
        output_line_cnt = (o_total_rows+ 10)
       ENDIF
       dlrec->seq[d1.seq].output_line[o_total_rows].column2 = dlrec->seq[d1.seq].io[x].io_line
      ELSEIF (size(dlrec->seq[d1.seq].io[x].io_line) > 0
       AND (dlrec->seq[d1.seq].io[x].hour_range="24"))
       tempstring = dlrec->seq[d1.seq].io[x].io_line, wrapcol = 60, eol = size(trim(tempstring)),
       xcol = 350, ycol = save_ycol, line_wrap_indent
      ENDIF
     ENDIF
   ENDFOR
   IF (o_total_rows > o_max_total_rows)
    o_max_total_rows = o_total_rows
   ENDIF
   o_total_rows = 0
  FOOT  encntr_id
   stat = alterlist(dlrec->seq[d1.seq].intake_line,i_max_total_rows), dlrec->seq[d1.seq].
   intake_line_cnt = i_max_total_rows, stat = alterlist(dlrec->seq[d1.seq].output_line,
    o_max_total_rows),
   dlrec->seq[d1.seq].output_line_cnt = o_max_total_rows
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = dlrec->seq[dd.seq].encntr_id
  FROM (dummyt dd  WITH seq = value(dlrec->encntr_total)),
   sticky_note sn,
   prsnl p
  PLAN (dd)
   JOIN (sn
   WHERE sn.parent_entity_name="PERSON"
    AND (sn.parent_entity_id=dlrec->seq[dd.seq].person_id)
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
 SELECT INTO value(printer_disp)
  facility = dlrec->seq[d1.seq].facility, building = dlrec->seq[d1.seq].building, location = dlrec->
  seq[d1.seq].location,
  room_bed = dlrec->seq[d1.seq].room_bed, fac_loc =
  IF (textlen(trim(concat(trim(dlrec->seq[d1.seq].facility),"/",trim(dlrec->seq[d1.seq].location)," ",
     trim(dlrec->seq[d1.seq].room_bed)))) > 15) concat(substring(1,13,trim(concat(trim(dlrec->seq[d1
        .seq].facility),"/",trim(dlrec->seq[d1.seq].location)," ",trim(dlrec->seq[d1.seq].room_bed)))
     ),"...")
  ELSE trim(concat(trim(dlrec->seq[d1.seq].facility),"/",trim(dlrec->seq[d1.seq].location)," ",trim(
      dlrec->seq[d1.seq].room_bed)))
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
    limit = 0, maxlen = wrapcol, cr = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring),
      CALL print(calcpos(xcol,ycol)), printstring
      IF (limit=1)
       maxlen = (maxlen - 2), xcol = (xcol+ 5)
      ENDIF
      ycol = (ycol+ 8), row + 1, tempstring = substring((pos+ 1),eol,tempstring)
    ENDWHILE
   ENDMACRO
   , "{f/0}{cpi/18}",
   ycol = 30, xcol = 30,
   CALL print(calcpos(xcol,ycol)),
   "*** Baystate Rounds Report ***", xcol = 215,
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
   CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].pcp_name,
   ycol = (ycol+ 16), row + 1
  HEAD encntr_id
   IF ((ycol > (725 - 48)))
    BREAK
   ELSEIF (ycol != 30
    AND ycol != 78)
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
    dlrec->seq[d1.seq].pcp_name, ycol = (ycol+ 16), row + 1
   ENDIF
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
    dlrec->seq[d1.seq].vitals[1].o2_sat_range, "%)", ycol = (ycol+ 8),
    row + 1
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
    "{b}12hr", xcol = 350, row + 1,
    CALL print(calcpos(xcol,ycol)), "{b}24hr", ycol = (ycol+ 8),
    row + 1
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
         xcol = 350, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "No Intake found in the last 24 hours."
        ELSE
         xcol = 350, row + 1,
         CALL print(calcpos(xcol,ycol)),
         dlrec->seq[d1.seq].intake_line[lcnt].column2
        ENDIF
       ELSE
        xcol = 60, row + 1,
        CALL print(calcpos(xcol,ycol)),
        dlrec->seq[d1.seq].intake_line[lcnt].column1, xcol = 350, row + 1,
        CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].intake_line[lcnt].column2
       ENDIF
       ycol = (ycol+ 8), row + 1
     ENDFOR
    ELSE
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}In{endb}", xcol = 60, row + 1,
     CALL print(calcpos(xcol,ycol)), "No Intake found in the last 12 hours.", xcol = 350,
     row + 1,
     CALL print(calcpos(xcol,ycol)), "No Intake found in the last 24 hours.",
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
         xcol = 350, row + 1,
         CALL print(calcpos(xcol,ycol)),
         "No Output found in the last 24 hours."
        ELSE
         xcol = 350, row + 1,
         CALL print(calcpos(xcol,ycol)),
         dlrec->seq[d1.seq].output_line[lcnt].column2
        ENDIF
       ELSE
        xcol = 60, row + 1,
        CALL print(calcpos(xcol,ycol)),
        dlrec->seq[d1.seq].output_line[lcnt].column1, xcol = 350, row + 1,
        CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].output_line[lcnt].column2
       ENDIF
       ycol = (ycol+ 8), row + 1
     ENDFOR
    ELSE
     xcol = 30, row + 1,
     CALL print(calcpos(xcol,ycol)),
     "{b}Out{endb}", xcol = 60, row + 1,
     CALL print(calcpos(xcol,ycol)), "No Output found in the last 12 hours.", xcol = 350,
     row + 1,
     CALL print(calcpos(xcol,ycol)), "No Output found in the last 24 hours.",
     ycol = (ycol+ 8), row + 1
    ENDIF
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No I&O found in the last 24 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
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
    ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Scheduled Meds", xcol = 215, row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}PRN Meds", xcol = 400,
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}{u}IV Fluids{endb}{endu}",
   ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].med_line_cnt > 0))
    FOR (lcnt = 1 TO dlrec->seq[d1.seq].med_line_cnt)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (lcnt=1)
      IF ((dlrec->seq[d1.seq].med_line[lcnt].column1 <= ""))
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No Scheduled meds found for encounter."
      ELSE
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].med_line[lcnt].column1
      ENDIF
      IF ((dlrec->seq[d1.seq].med_line[lcnt].column2 <= ""))
       xcol = 215, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No PRN meds found for encounter."
      ELSE
       xcol = 215, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].med_line[lcnt].column2
      ENDIF
      IF ((dlrec->seq[d1.seq].med_line[lcnt].column3 <= ""))
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       "No IV meds found for encounter."
      ELSE
       xcol = 400, row + 1,
       CALL print(calcpos(xcol,ycol)),
       dlrec->seq[d1.seq].med_line[lcnt].column3
      ENDIF
      ycol = (ycol+ 8), row + 1
     ELSEIF (lcnt > 1)
      xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)),
      dlrec->seq[d1.seq].med_line[lcnt].column1, xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].med_line[lcnt].column2, xcol = 400,
      row + 1,
      CALL print(calcpos(xcol,ycol)), dlrec->seq[d1.seq].med_line[lcnt].column3,
      ycol = (ycol+ 8), row + 1
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Scheduled meds found for encounter.", xcol = 215, row + 1,
    CALL print(calcpos(xcol,ycol)), "No PRN meds found for encounter.", xcol = 400,
    row + 1,
    CALL print(calcpos(xcol,ycol)), "No IV meds found for encounter.",
    ycol = (ycol+ 8), row + 1
   ENDIF
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
   "{b}{u}Micro Orders in last 24 hours{endb}{endu}", ycol = (ycol+ 8), row + 1
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
    "No Micro Orders found on encounter in last 24 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Blood Bank Orders in last 24 hours{endb}{endu}", ycol = (ycol+ 8), row + 1
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
    "No Blood Bank Orders found on encounter in last 24 hours.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Other Info{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].total_orders > 0))
    FOR (ocnt = 1 TO dlrec->seq[d1.seq].total_orders)
     IF (ycol > 725)
      BREAK
     ENDIF
     ,
     IF (((ocnt=1) OR (mod(ocnt,3)=1)) )
      order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable), xcol = 30, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_orders))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((ocnt=2) OR (mod(ocnt,3)=2)) )
      order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable), xcol = 215, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string
      IF ((ocnt=dlrec->seq[d1.seq].total_orders))
       ycol = (ycol+ 8), row + 1
      ENDIF
     ELSEIF (((ocnt=3) OR (mod(ocnt,3)=0)) )
      order_string = trim(dlrec->seq[d1.seq].orders[ocnt].orderable), xcol = 400, row + 1,
      CALL print(calcpos(xcol,ycol)), order_string, ycol = (ycol+ 8),
      row + 1
     ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Other Info found on encounter.", ycol = (ycol+ 8), row + 1
   ENDIF
   IF ((ycol > (725 - 24)))
    BREAK
   ENDIF
   xcol = 30, row + 1,
   CALL print(calcpos(xcol,ycol)),
   "{b}{u}Sticky Notes{endb}{endu}", ycol = (ycol+ 8), row + 1
   IF ((dlrec->seq[d1.seq].total_sticky_notes > 0))
    FOR (ncnt = 1 TO dlrec->seq[d1.seq].total_sticky_notes)
      IF (ycol > 725)
       BREAK
      ENDIF
      note_string = concat(trim(dlrec->seq[d1.seq].sticky_notes[ncnt].note_date)," ",trim(dlrec->seq[
        d1.seq].sticky_notes[ncnt].prsnl_name),"- ",trim(dlrec->seq[d1.seq].sticky_notes[ncnt].notes)
       )
      IF (size(note_string) > 0
       AND size(note_string) <= 130)
       xcol = 30, row + 1,
       CALL print(calcpos(xcol,ycol)),
       note_string, ycol = (ycol+ 8), row + 1
      ELSEIF (size(note_string) > 0)
       tempstring = trim(note_string), wrapcol = 130, eol = size(trim(tempstring)),
       xcol = 30, line_wrap_indent
      ENDIF
    ENDFOR
   ELSE
    xcol = 30, row + 1,
    CALL print(calcpos(xcol,ycol)),
    "No Sticky notes found on patient.", ycol = (ycol+ 8), row + 1
   ENDIF
  WITH dio = postscript, maxcol = 800, maxrow = 800
 ;end select
 FREE RECORD dlrec
 FREE RECORD pt
#end_of_program
END GO
