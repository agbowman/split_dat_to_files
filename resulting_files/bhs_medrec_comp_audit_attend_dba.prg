CREATE PROGRAM bhs_medrec_comp_audit_attend:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting Discharge Date" = curdate,
  "Ending Discharge Date" = curdate,
  "" = "report preview"
  WITH outdev, beg_dt, end_dt,
  email
 DECLARE trigger_encntrid = f8 WITH public
 DECLARE retval = i4 WITH public
 DECLARE phys_type = vc
 DECLARE var_output = vc
 DECLARE email_ind = i4
 DECLARE current_loc = f8 WITH public
 SET email_ind = 4
 DECLARE disch_per_done = i4
 IF (validate(request->batch_selection))
  SET start_disch_date = datetimeadd(cnvtdatetime(curdate,0),- (8))
  SET end_disch_date = datetimeadd(cnvtdatetime(curdate,235959),- (1))
  SET send_mail =  $EMAIL
 ELSE
  SET start_disch_date = cnvtdatetime(cnvtdate( $BEG_DT),0)
  SET end_disch_date = cnvtdatetime(cnvtdate( $END_DT),235959)
  SET send_mail =  $EMAIL
 ENDIF
 IF (datetimediff(cnvtdatetime(cnvtdate( $END_DT),0),cnvtdatetime(cnvtdate( $BEG_DT),0)) > 14)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 14 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime(cnvtdate( $END_DT),0),cnvtdatetime(cnvtdate( $BEG_DT),0)) < 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_audit_attend"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET dta1 = uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION")
 SET attend_cd = uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
 SET home_med_cd = uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW")
 SET perform_cd = uar_get_code_by("DISPLAYKEY",21,"PERFORM")
 FREE RECORD temp
 RECORD temp(
   1 count = i2
   1 qual[*]
     2 physician_id = f8
     2 rule_fired = i4
     2 tot_admt_res = i4
     2 tot_tran_res = i4
     2 tot_disch_res = i4
     2 tot_admt_rule = i4
     2 tot_tran_rule = i4
     2 tot_disch_rule = i4
     2 tot_comp_12 = i4
     2 tot_comp_24 = i4
     2 tot_comp_18 = i4
     2 enc_det_cnt = i4
     2 enc_det[*]
       3 encntrid = f8
       3 reg_date = dq8
       3 review_res_date = dq8
       3 admt_res_date = dq8
       3 comp_18 = i4
       3 comp_24 = i4
       3 admit_rul_cnt = i4
       3 transfer_rul_cnt = i4
       3 beg_trans_loc = dq8
       3 end_trans_loc = dq8
       3 disch_rul_cnt = i4
       3 admitresult = i4
       3 transferresult = i4
       3 dischresult = i4
       3 transfer_cnt = i4
       3 trans_detail[*]
         4 beg_date = dq8
         4 end_date = dq8
 )
 SET max_enct_cnt = 0
 SET max_tran_cnt = 0
 SELECT DISTINCT INTO "NL:"
  epr.prsnl_person_id, emad.encntr_id, e_loc_nurse_unit_disp = uar_get_code_display(elh
   .loc_nurse_unit_cd),
  elh.beg_effective_dt_tm, module_sort =
  IF (ema.module_name="BHS_SYN_MED_REC_ADM*") 1
  ELSEIF (ema.module_name="BHS_SYN_MED_REC_TRANSFER*") 2
  ELSEIF (ema.module_name="BHS_SYN_MED_REC_DISCH*") 3
  ENDIF
  FROM eks_module_audit ema,
   eks_module_audit_det emad,
   encounter e,
   encntr_loc_hist elh,
   encntr_prsnl_reltn epr
  PLAN (ema
   WHERE ema.begin_dt_tm >= cnvtdatetime(datetimeadd(sysdate,- (16)))
    AND ema.end_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ema.module_name="BHS_SYN_MED_REC*"
    AND ema.conclude=2)
   JOIN (emad
   WHERE emad.module_audit_id=ema.rec_id
    AND ((emad.encntr_id+ 0) > 0)
    AND emad.order_id > 0)
   JOIN (e
   WHERE e.encntr_id=emad.encntr_id
    AND ((e.disch_dt_tm+ 0) BETWEEN cnvtdatetime(start_disch_date) AND cnvtdatetime(end_disch_date)))
   JOIN (epr
   WHERE epr.encntr_id=emad.encntr_id
    AND ((epr.prsnl_person_id+ 0) > 0)
    AND epr.encntr_prsnl_r_cd=attend_cd
    AND ema.updt_dt_tm BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ema.updt_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
  ORDER BY epr.prsnl_person_id, emad.encntr_id, module_sort,
   e_loc_nurse_unit_disp, 0
  HEAD REPORT
   cnt = 0, cnta = 0, stat = alterlist(temp->qual,10)
  HEAD epr.prsnl_person_id
   cnt = (cnt+ 1), temp->count = cnt
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].physician_id = epr.prsnl_person_id, cnta = 0, stat = alterlist(temp->qual[cnt].
    enc_det,10)
  HEAD emad.encntr_id
   trigger_encntrid = emad.encntr_id, cnta = (cnta+ 1)
   IF (mod(cnta,10)=1)
    stat = alterlist(temp->qual[cnt].enc_det,(cnta+ 9))
   ENDIF
   temp->qual[cnt].enc_det[cnta].encntrid = emad.encntr_id, temp->qual[cnt].enc_det[cnta].reg_date =
   e.reg_dt_tm, temp->qual[cnt].enc_det_cnt = (temp->qual[cnt].enc_det_cnt+ 1)
  HEAD module_sort
   IF (ema.module_name="BHS_SYN_MED_REC_ADM*")
    temp->qual[cnt].enc_det[cnta].admit_rul_cnt = 1, temp->qual[cnt].tot_admt_rule = (temp->qual[cnt]
    .tot_admt_rule+ 1)
   ENDIF
   IF (ema.module_name="BHS_SYN_MED_REC_TRANSFER*")
    temp->qual[cnt].enc_det[cnta].transfer_rul_cnt = 1, temp->qual[cnt].tot_tran_rule = (temp->qual[
    cnt].tot_tran_rule+ 1), current_loc = elh.loc_nurse_unit_cd
   ENDIF
   IF (ema.module_name="BHS_SYN_MED_REC_DISCH*")
    temp->qual[cnt].enc_det[cnta].disch_rul_cnt = 1, temp->qual[cnt].tot_disch_rule = (temp->qual[cnt
    ].tot_disch_rule+ 1)
   ENDIF
   temp->qual[cnt].rule_fired = (temp->qual[cnt].rule_fired+ 1)
  HEAD ema.rec_id
   IF (ema.module_name="BHS_SYN_MED_REC_TRANSFER*"
    AND current_loc != elh.loc_nurse_unit_cd)
    temp->qual[cnt].tot_tran_rule = (temp->qual[cnt].tot_tran_rule+ 1)
   ENDIF
  FOOT  emad.encntr_id
   IF ((max_enct_cnt <= temp->qual[cnt].enc_det_cnt))
    max_enct_cnt = temp->qual[cnt].enc_det_cnt
   ENDIF
  FOOT  epr.prsnl_person_id
   stat = alterlist(temp->qual[cnt].enc_det,cnta)
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter, format, separator = " "
 ;end select
 SELECT INTO "nl:"
  physinumber = d1.seq, encnternumber = d2.seq, ce.encntr_id,
  ce.event_cd, ce.result_val
  FROM clinical_event ce,
   (dummyt d1  WITH seq = size(temp->qual,5)),
   (dummyt d2  WITH seq = max_enct_cnt)
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= temp->qual[d1.seq].enc_det_cnt))
   JOIN (ce
   WHERE (ce.encntr_id=temp->qual[d1.seq].enc_det[d2.seq].encntrid)
    AND ce.event_cd=dta1
    AND ((ce.result_val="Admission") OR (((ce.result_val="Transfer") OR (ce.result_val="Discharge"))
   )) )
  ORDER BY ce.encntr_id
  HEAD ce.result_val
   IF (ce.result_val="Admission"
    AND (temp->qual[d1.seq].enc_det[d2.seq].encntrid=ce.encntr_id))
    IF ((temp->qual[d1.seq].enc_det[d2.seq].admitresult <= 0))
     temp->qual[d1.seq].tot_admt_res = (temp->qual[d1.seq].tot_admt_res+ 1), temp->qual[d1.seq].
     enc_det[d2.seq].admitresult = 1, temp->qual[d1.seq].enc_det[d2.seq].admt_res_date = ce
     .verified_dt_tm,
     temp->qual[d1.seq].enc_det[d2.seq].admt_res_date = ce.verified_dt_tm
     IF (datetimediff(ce.verified_dt_tm,temp->qual[d1.seq].enc_det[d2.seq].reg_date,3) <= 24
      AND ce.result_status_cd=auth_ver_cd)
      temp->qual[d1.seq].tot_comp_24 = (temp->qual[d1.seq].tot_comp_24+ 1)
     ENDIF
    ENDIF
   ELSEIF (ce.result_val="Transfer"
    AND (temp->qual[d1.seq].enc_det[d2.seq].encntrid=ce.encntr_id))
    IF ((temp->qual[d1.seq].enc_det[d2.seq].transferresult <= 0))
     temp->qual[d1.seq].tot_tran_res = (temp->qual[d1.seq].tot_tran_res+ 1), temp->qual[d1.seq].
     enc_det[d2.seq].transferresult = 1
     IF (datetimediff(ce.verified_dt_tm,temp->qual[d1.seq].enc_det[d2.seq].beg_trans_loc,3) <= 12
      AND ce.result_status_cd=auth_ver_cd)
      temp->qual[d1.seq].tot_comp_12 = (temp->qual[d1.seq].tot_comp_12+ 1)
     ENDIF
    ENDIF
   ELSEIF (ce.result_val="Discharge"
    AND (temp->qual[d1.seq].enc_det[d2.seq].encntrid=ce.encntr_id))
    IF ((temp->qual[d1.seq].enc_det[d2.seq].dischresult <= 0))
     temp->qual[d1.seq].tot_disch_res = (temp->qual[d1.seq].tot_disch_res+ 1)
    ENDIF
    temp->qual[d1.seq].enc_det[d2.seq].dischresult = 1
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (dummyt d1  WITH seq = size(temp->qual,5)),
   (dummyt d2  WITH seq = max_enct_cnt)
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= temp->qual[d1.seq].enc_det_cnt))
   JOIN (ce
   WHERE (ce.encntr_id=temp->qual[d1.seq].enc_det[d2.seq].encntrid)
    AND (temp->qual[d1.seq].enc_det[d2.seq].admitresult > 0)
    AND ce.event_cd=home_med_cd
    AND ce.result_status_cd=auth_ver_cd)
  ORDER BY ce.encntr_id, ce.clinsig_updt_dt_tm DESC, temp->qual[d1.seq].enc_det[d2.seq].admt_res_date
  HEAD ce.encntr_id
   IF ((temp->qual[d1.seq].enc_det[d2.seq].encntrid=ce.encntr_id)
    AND datetimediff(temp->qual[d1.seq].enc_det[d2.seq].admt_res_date,ce.verified_dt_tm,3) <= 18
    AND ce.result_status_cd=auth_ver_cd)
    temp->qual[d1.seq].tot_comp_18 = (temp->qual[d1.seq].tot_comp_18+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (email_ind=0)
  SELECT INTO value(var_output)
   doctor = substring(1,25,trim(pr.name_full_formatted,3)), department =
   IF (uar_get_code_display(pr.position_cd)="BHS Anesthesiology MD") "Anesthesiology"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Cardiology MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Cardiac Surgery MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Critical Care MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS ER Medicine MD") "Emergency Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Infectious Disease MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS GI MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Urology MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Thoracic MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Trauma MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Resident") "Resident"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Oncology MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Neonatal MD") "Pediatrics"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Neurology MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS OB/GYN MD") "Ob/Gyn"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Orthopedics MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS General Pediatrics MD") "Pediatrics"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Psychiatry MD") "Psychiatry"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Physiatry MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Pulmonary MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Radiology MD") "Radiology"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Renal MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS General Surgery MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Midwife") "Ob/Gyn"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Associate Professional") "Associate Provider"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Physician (General Medicine)")
    "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Medical Student") "Medical Student"
   ELSE "Other"
   ENDIF
   FROM (dummyt d1  WITH seq = size(temp->qual,5)),
    prsnl pr
   PLAN (d1)
    JOIN (pr
    WHERE (pr.person_id=temp->qual[d1.seq].physician_id))
   ORDER BY department, doctor
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", rpt_tot_adm_res = 0,
    rpt_tot_tran_res = 0, rpt_tot_disch_res = 0, rpt_tot_adm_rule = 0,
    rpt_tot_tran_rule = 0, rpt_tot_disch_rule = 0, rpt_tot_comp12 = 0,
    rpt_tot_comp24 = 0, rpt_tot_comp18 = 0, pct_adm_done = 0,
    pct_tran_done = 0, pct_disch_done = 0, total_docs_rpt = 0,
    num_alias = 0, row + 2, col 40,
    "{F/1}{CPI/14}{B}Attending's  Medication Reconciliation Report{ENDB}", row + 2, col 35,
    "{B}Report Date: ", today = format(curdate,"MMM-DD-YYYY;;D"), st_dt2 = build("{B}Audit From...",
     format(cnvtdate( $BEG_DT),"mm/dd/yy;;d"),"  To...    ",format(cnvtdate( $END_DT),"mm/dd/yy;;d")),
    col + 1, st_dt2, row + 2,
    printpsheader = 0
   HEAD PAGE
    prt_num_docs = 0, prtnum_departments = 0, total_lines = 0,
    total_lines = 0, maxlines = 44, total_lines = (total_lines+ prtnum_departments),
    col 0, "{B}PAGE:", col + 1,
    curpage
    IF (printpsheader)
     col 0, "{PS/792 0 translate 90 rotate/}"
    ENDIF
    row + 1, printpsheader = 1, row + 1,
    col 32, "{B}Admits", col 50,
    "Done  In", call reportmove('COL',(61+ 2),0), "|",
    col 70, "Transfers", col 85,
    "Done In", call reportmove('COL',(94+ 2),0), "|",
    col 100, "Discharge", row + 1,
    col 0, "{B}Attending", call reportmove('COL',(25+ 2),0),
    "Completed", call reportmove('COL',(35+ 2),0), "Patients",
    call reportmove('COL',(44+ 2),0), "%Done", call reportmove('COL',(50+ 2),0),
    "18hrs", call reportmove('COL',(56+ 2),0), "24hrs",
    call reportmove('COL',(61+ 2),0), "|", call reportmove('COL',(63+ 2),0),
    "Completed", call reportmove('COL',(73+ 2),0), "Patients",
    call reportmove('COL',(82+ 2),0), "%Done", call reportmove('COL',(88+ 2),0),
    "12 hrs", call reportmove('COL',(94+ 2),0), "|",
    call reportmove('COL',(95+ 2),0), "Completed", call reportmove('COL',(105+ 2),0),
    "Patients", call reportmove('COL',(115+ 2),0), "%Done{ENDB}",
    row + 1, col 0, "{REPEAT/118/_/}"
   HEAD department
    row + 1, col 0, "{F/6}{CPI/14}{B}{U}",
    department
    IF ((total_lines=(maxlines - 1)))
     prtnum_departments = (prtnum_departments+ 2)
    ELSE
     prtnum_departments = (prtnum_departments+ 1)
    ENDIF
    CALL echo(build("number md = ",prt_num_docs)),
    CALL echo(build("Number Dept. = ",prtnum_departments))
   HEAD doctor
    prt_num_docs = (prt_num_docs+ 1), total_docs_rpt = (total_docs_rpt+ 1), total_lines = (
    prtnum_departments+ prt_num_docs)
    IF (prt_num_docs=1
     AND total_lines=1)
     row + 1, col 0, "{F/6}{CPI/14}{B}{U}",
     department, prtnum_departments = (prtnum_departments+ 1)
    ENDIF
    row + 1, col 0, "{F/1}{CPI/14}",
    doctor, call reportmove('COL',(25+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_admt_res))),
    call reportmove('COL',(33+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_admt_rule))), call reportmove('COL',(42+ 15),0),
    CALL print(trim(cnvtstring(cnvtreal((cnvtreal((temp->qual[d1.seq].tot_admt_res/ cnvtreal(temp->
         qual[d1.seq].tot_admt_rule))) * 100))))), call reportmove('COL',(47+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_comp_18))),
    call reportmove('COL',(53+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_comp_24))), call reportmove('COL',(58+ 15),0),
    "|", call reportmove('COL',(60+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_tran_res))),
    call reportmove('COL',(70+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_tran_rule))), call reportmove('COL',(80+ 15),0),
    CALL print(trim(cnvtstring(cnvtreal(((cnvtreal(temp->qual[d1.seq].tot_tran_res)/ cnvtreal(temp->
        qual[d1.seq].tot_tran_rule)) * 100))))), call reportmove('COL',(85+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_comp_12))),
    call reportmove('COL',(91+ 15),0), "|", call reportmove('COL',(93+ 15),0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_disch_res))), call reportmove('COL',(102+ 15)
    ,0),
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_disch_rule))),
    call reportmove('COL',(112+ 15),0),
    CALL print(trim(cnvtstring(cnvtreal(((cnvtreal(temp->qual[d1.seq].tot_disch_res)/ cnvtreal(temp->
        qual[d1.seq].tot_disch_rule)) * 100)))))
    IF (total_lines >= maxlines
     AND (total_docs_rpt < temp->count))
     row 7, BREAK
    ENDIF
    rpt_tot_adm_res = (temp->qual[d1.seq].tot_admt_res+ rpt_tot_adm_res), rpt_tot_tran_res = (temp->
    qual[d1.seq].tot_tran_res+ rpt_tot_tran_res), rpt_tot_disch_res = (temp->qual[d1.seq].
    tot_disch_res+ rpt_tot_disch_res),
    rpt_tot_adm_rule = (temp->qual[d1.seq].tot_admt_rule+ rpt_tot_adm_rule), rpt_tot_tran_rule = (
    temp->qual[d1.seq].tot_tran_rule+ rpt_tot_tran_rule), rpt_tot_disch_rule = (temp->qual[d1.seq].
    tot_disch_rule+ rpt_tot_disch_rule),
    rpt_tot_comp24 = (temp->qual[d1.seq].tot_comp_24+ rpt_tot_comp24), rpt_tot_comp18 = (temp->qual[
    d1.seq].tot_comp_18+ rpt_tot_comp18), rpt_tot_comp12 = (temp->qual[d1.seq].tot_comp_12+
    rpt_tot_comp12)
   FOOT REPORT
    row + 1, col 0, "{REPEAT/118/_/}",
    row + 1, pct_adm_done = ((cnvtreal(cnvtreal(rpt_tot_adm_res))/ cnvtreal(rpt_tot_adm_rule)) * 100),
    pct_tran_done = ((cnvtreal(cnvtreal(rpt_tot_tran_res))/ cnvtreal(rpt_tot_tran_rule)) * 100),
    pct_disch_done = ((cnvtreal(cnvtreal(rpt_tot_disch_res))/ cnvtreal(rpt_tot_disch_rule)) * 100),
    col 0, "{B/6}Totals:",
    call reportmove('COL',(30+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_adm_res))), call reportmove('COL',(37+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_adm_rule))), call reportmove('COL',(47+ 2),0),
    CALL print(trim(cnvtstring(pct_adm_done))),
    call reportmove('COL',(52+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_comp18))), call reportmove('COL',(58+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_comp24))), call reportmove('COL',(63+ 2),0), "|",
    call reportmove('COL',(65+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_tran_res))), call reportmove('COL',(75+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_tran_rule))), call reportmove('COL',(85+ 2),0),
    CALL print(trim(cnvtstring(pct_tran_done))),
    call reportmove('COL',(90+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_comp12))), call reportmove('COL',(96+ 2),0),
    "|", call reportmove('COL',(98+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_disch_res))),
    call reportmove('COL',(107+ 2),0),
    CALL print(trim(cnvtstring(rpt_tot_disch_rule))), call reportmove('COL',(117+ 2),0),
    CALL print(trim(cnvtstring(pct_disch_done)))
   WITH nocounter, format, separator = " ",
    landscape, dio = 08, nullreport = 1
  ;end select
 ELSEIF (email_ind=1)
  SELECT INTO value(var_output)
   doctor = trim(pr.name_full_formatted), department =
   IF (uar_get_code_display(pr.position_cd)="BHS Anesthesiology MD") "Anesthesiology"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Cardiology MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Cardiac Surgery MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Critical Care MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS ER Medicine MD") "Emergency Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Infectious Disease MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS GI MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Urology MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Thoracic MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Trauma MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Resident") "Resident"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Oncology MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Neonatal MD") "Pediatrics"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Neurology MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS OB/GYN MD") "Ob/Gyn"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Orthopedics MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS General Pediatrics MD") "Pediatrics"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Psychiatry MD") "Psychiatry"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Physiatry MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Pulmonary MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Radiology MD") "Radiology"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Renal MD") "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS General Surgery MD") "Surgery"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Midwife") "Ob/Gyn"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Associate Professional") "Associate Provider"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Physician (General Medicine)")
    "Internal Medicine"
   ELSEIF (uar_get_code_display(pr.position_cd)="BHS Medical Student") "Medical Student"
   ELSE "Other"
   ENDIF
   , admit_comp = temp->qual[d1.seq].tot_admt_res,
   admit_pat = temp->qual[d1.seq].tot_admt_rule, admit_per_done = ((cnvtreal(temp->qual[d1.seq].
    tot_admt_res)/ temp->qual[d1.seq].tot_admt_rule) * 100), admit_comp18 = temp->qual[d1.seq].
   tot_comp_18,
   admit_comp24 = temp->qual[d1.seq].tot_comp_24, tran_comp = temp->qual[d1.seq].tot_tran_res,
   tran_pat = temp->qual[d1.seq].tot_tran_rule,
   tran_per_done = ((cnvtreal(temp->qual[d1.seq].tot_tran_res)/ temp->qual[d1.seq].tot_tran_rule) *
   100), tran_comp12 = temp->qual[d1.seq].tot_comp_12, disch_comp = temp->qual[d1.seq].tot_disch_res,
   disch_pat = temp->qual[d1.seq].tot_disch_rule, disch_per_done = ((cnvtreal(temp->qual[d1.seq].
    tot_disch_res)/ temp->qual[d1.seq].tot_disch_rule) * 100)
   FROM (dummyt d1  WITH seq = size(temp->qual,5)),
    prsnl pr
   PLAN (d1)
    JOIN (pr
    WHERE (pr.person_id=temp->qual[d1.seq].physician_id))
   ORDER BY doctor
   WITH nocounter, format, pcformat('"',","),
    time = 30
  ;end select
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "bhs_audit_attend.csv"
  SET subject = concat("Attending Medreconcilations Report")
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,subject,0)
 ENDIF
#exit_prg
END GO
