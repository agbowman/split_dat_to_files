CREATE PROGRAM bhs_fac_meds_recon_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Organization" = 0,
  "Select Nursing Unit /s" = 0,
  "Enter Starting Discharge Date" = curdate,
  "Enter Ending Discharge Date" = curdate,
  "" = "report preview"
  WITH outdev, org, nur,
  beg_dt, end_dt, email
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(3,0)))), public
 SET operations = 0
 IF (validate(request->batch_selection))
  SET start_disch_date = datetimeadd(cnvtdatetime(curdate,0),- (8))
  SET end_disch_date = datetimeadd(cnvtdatetime(curdate,235959),- (1))
  SET send_mail =  $EMAIL
  SET operations = 1
 ELSE
  SET start_disch_date = cnvtdatetime(cnvtdate( $BEG_DT),0)
  SET end_disch_date = cnvtdatetime(cnvtdate( $END_DT),235959)
  SET send_mail =  $EMAIL
  IF (any_status_ind="I")
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "You Must Pick a Facility", msg2 = "  Please retry again.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_prg
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
 ENDIF
 CALL echo(format(start_disch_date,";;Q"))
 CALL echo(format(end_disch_date,";;Q"))
 IF (findstring("@",send_mail) > 0)
  SET email_ind = 1
  SET var_output = "bhs_audit_facilty"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET home_med_cd = uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW")
 SET perform_cd = uar_get_code_by("DISPLAYKEY",21,"PERFORM")
 SET dta1 = uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION")
 FREE RECORD temp
 RECORD temp(
   1 count = i2
   1 qual[*]
     2 facility = vc
     2 units = vc
     2 rule_fired = i4
     2 tot_admt_rule = i4
     2 tot_tran_rule = i4
     2 tot_disch_rule = i4
     2 tot_admt_res = i4
     2 tot_tran_res = i4
     2 tot_disch_res = i4
     2 tot_comp_12 = i4
     2 tot_comp_24 = i4
     2 tot_comp_18 = i4
     2 enc_det_cnt = i2
     2 enc_det[*]
       3 encntr_id = f8
       3 reg_date = dq8
       3 review_res_date = dq8
       3 admt_res_date = dq8
       3 beg_trans_loc = dq8
       3 comp_18 = i4
       3 comp_24 = i4
       3 admit_rul_cnt = i4
       3 transfer_rul_cnt = i4
       3 disch_rul_cnt = i4
       3 admitresult = i4
       3 transferresult = i4
       3 dischresult = i4
 )
 CALL echo("select 111")
 SET max_enct_cnt = 0
 SELECT
  IF (((any_status_ind="C") OR (operations=1)) )
   PLAN (ema
    WHERE ema.module_name="BHS_SYN_MED_*"
     AND ema.begin_dt_tm >= cnvtdatetime(datetimeadd(sysdate,- (16)))
     AND ema.end_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((ema.conclude+ 0)=2))
    JOIN (emad
    WHERE emad.module_audit_id=ema.rec_id
     AND ((emad.encntr_id+ 0) > 0)
     AND emad.order_id > 0)
    JOIN (elh
    WHERE emad.encntr_id=elh.encntr_id
     AND (elh.loc_facility_cd= $ORG)
     AND emad.updt_dt_tm BETWEEN (elh.beg_effective_dt_tm+ 0) AND (elh.end_effective_dt_tm+ 0))
    JOIN (en
    WHERE elh.encntr_id=en.encntr_id
     AND ((en.disch_dt_tm+ 0) BETWEEN cnvtdatetime(start_disch_date) AND cnvtdatetime(end_disch_date)
    ))
  ELSE
   PLAN (ema
    WHERE ema.module_name="BHS_SYN_MED_*"
     AND ema.begin_dt_tm >= cnvtdatetime(datetimeadd(sysdate,- (16)))
     AND ema.end_dt_tm <= cnvtdatetime(curdate,curtime3))
    JOIN (emad
    WHERE emad.module_audit_id=ema.rec_id
     AND ((emad.encntr_id+ 0) > 0)
     AND emad.order_id > 0)
    JOIN (elh
    WHERE emad.encntr_id=elh.encntr_id
     AND (elh.loc_facility_cd= $ORG)
     AND (elh.loc_nurse_unit_cd= $NUR)
     AND emad.updt_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    JOIN (en
    WHERE elh.encntr_id=en.encntr_id
     AND ((en.disch_dt_tm+ 0) BETWEEN cnvtdatetime(start_disch_date) AND cnvtdatetime(end_disch_date)
    ))
  ENDIF
  DISTINCT INTO "nl:"
  e_loc_facility_disp = uar_get_code_display(elh.loc_facility_cd), en.encntr_id,
  e_loc_nurse_unit_disp = uar_get_code_display(elh.loc_nurse_unit_cd),
  module_sort =
  IF (ema.module_name="BHS_SYN_MED_REC_ADM*") 1
  ELSEIF (ema.module_name="BHS_SYN_MED_REC_TRANSFER*") 2
  ELSEIF (ema.module_name="BHS_SYN_MED_REC_DISCH*") 3
  ENDIF
  FROM eks_module_audit ema,
   eks_module_audit_det emad,
   encntr_loc_hist elh,
   encounter en
  ORDER BY e_loc_facility_disp, e_loc_nurse_unit_disp, emad.encntr_id,
   module_sort, elh.beg_effective_dt_tm
  HEAD REPORT
   cnt = 0, cnta = 0, stat = alterlist(temp->qual,10)
  HEAD e_loc_nurse_unit_disp
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].facility = e_loc_facility_disp, temp->qual[cnt].units = e_loc_nurse_unit_disp,
   cnta = 0,
   stat = alterlist(temp->qual[cnt].enc_det,10)
  HEAD emad.encntr_id
   cnta = (cnta+ 1)
   IF (mod(cnta,10)=1
    AND cnta != 1)
    stat = alterlist(temp->qual[cnt].enc_det,(cnta+ 9))
   ENDIF
   temp->qual[cnt].enc_det_cnt = (temp->qual[cnt].enc_det_cnt+ 1), temp->qual[cnt].enc_det[cnta].
   encntr_id = emad.encntr_id
  HEAD ema.module_name
   IF (ema.module_name="BHS_SYN_MED_REC_ADM*"
    AND (temp->qual[cnt].enc_det[cnta].admit_rul_cnt <= 0))
    temp->qual[cnt].enc_det[cnta].admit_rul_cnt = (temp->qual[cnt].enc_det[cnta].admit_rul_cnt+ 1),
    temp->qual[cnt].tot_admt_rule = (temp->qual[cnt].tot_admt_rule+ 1)
   ELSEIF (ema.module_name="BHS_SYN_MED_REC_DISCH*")
    temp->qual[cnt].enc_det[cnta].disch_rul_cnt = (temp->qual[cnt].enc_det[cnta].disch_rul_cnt+ 1),
    temp->qual[cnt].tot_disch_rule = (temp->qual[cnt].tot_disch_rule+ 1)
   ELSEIF (ema.module_name="BHS_SYN_MED_REC_TRANSFER*")
    temp->qual[cnt].enc_det[cnta].transfer_rul_cnt = (temp->qual[cnt].enc_det[cnta].transfer_rul_cnt
    + 1), temp->qual[cnt].tot_tran_rule = (temp->qual[cnt].tot_tran_rule+ 1), temp->qual[cnt].
    enc_det[cnta].beg_trans_loc = elh.beg_effective_dt_tm
   ENDIF
   temp->qual[cnt].rule_fired = (temp->qual[cnt].rule_fired+ 1)
   IF ((max_enct_cnt <= temp->qual[cnt].enc_det_cnt))
    max_enct_cnt = temp->qual[cnt].enc_det_cnt
   ENDIF
  FOOT  e_loc_nurse_unit_disp
   stat = alterlist(temp->qual[cnt].enc_det,cnta)
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.result_val, transfer_date = format(cnvtdatetime(temp->qual[d1.seq].enc_det[d2.seq].beg_trans_loc
    ),";;Q"), ce.verified_dt_tm
  FROM clinical_event ce,
   (dummyt d1  WITH seq = size(temp->qual,5)),
   (dummyt d2  WITH seq = max_enct_cnt)
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= temp->qual[d1.seq].enc_det_cnt))
   JOIN (ce
   WHERE (ce.encntr_id=temp->qual[d1.seq].enc_det[d2.seq].encntr_id)
    AND ce.event_cd=dta1
    AND ((ce.result_val="Admission") OR (((ce.result_val="Transfer") OR (ce.result_val="Discharge"))
   )) )
  ORDER BY ce.encntr_id
  HEAD ce.result_val
   IF (ce.result_val="Admission"
    AND (temp->qual[d1.seq].enc_det[d2.seq].encntr_id=ce.encntr_id))
    IF ((temp->qual[d1.seq].enc_det[d2.seq].admitresult <= 0))
     temp->qual[d1.seq].enc_det[d2.seq].admt_res_date = ce.verified_dt_tm, temp->qual[d1.seq].
     tot_admt_res = (temp->qual[d1.seq].tot_admt_res+ 1)
    ENDIF
    temp->qual[d1.seq].enc_det[d2.seq].admitresult = 1
   ELSEIF (ce.result_val="Transfer"
    AND (temp->qual[d1.seq].enc_det[d2.seq].encntr_id=ce.encntr_id))
    IF ((temp->qual[d1.seq].enc_det[d2.seq].transferresult <= 0))
     temp->qual[d1.seq].tot_tran_res = (temp->qual[d1.seq].tot_tran_res+ 1)
     IF (datetimediff(ce.verified_dt_tm,temp->qual[d1.seq].enc_det[d2.seq].beg_trans_loc,3) <= 12
      AND ce.result_status_cd=auth_ver_cd)
      temp->qual[d1.seq].tot_comp_12 = (temp->qual[d1.seq].tot_comp_12+ 1)
     ENDIF
    ENDIF
    temp->qual[d1.seq].enc_det[d2.seq].transferresult = 1
   ELSEIF (ce.result_val="Discharge"
    AND (temp->qual[d1.seq].enc_det[d2.seq].encntr_id=ce.encntr_id))
    IF ((temp->qual[d1.seq].enc_det[d2.seq].dischresult <= 0))
     temp->qual[d1.seq].tot_disch_res = (temp->qual[d1.seq].tot_disch_res+ 1)
    ENDIF
    temp->qual[d1.seq].enc_det[d2.seq].dischresult = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM clinical_event ce,
   (dummyt d1  WITH seq = size(temp->qual,5)),
   (dummyt d2  WITH seq = max_enct_cnt)
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= temp->qual[d1.seq].enc_det_cnt))
   JOIN (ce
   WHERE (ce.encntr_id=temp->qual[d1.seq].enc_det[d2.seq].encntr_id)
    AND (temp->qual[d1.seq].enc_det[d2.seq].admitresult > 0)
    AND ce.event_cd=home_med_cd
    AND ce.result_status_cd=auth_ver_cd)
  ORDER BY ce.encntr_id, ce.clinsig_updt_dt_tm DESC, temp->qual[d1.seq].enc_det[d2.seq].admt_res_date
  HEAD ce.encntr_id
   IF ((temp->qual[d1.seq].enc_det[d2.seq].encntr_id=ce.encntr_id)
    AND datetimediff(temp->qual[d1.seq].enc_det[d2.seq].admt_res_date,ce.verified_dt_tm,3) <= 18
    AND ce.result_status_cd=auth_ver_cd)
    temp->qual[d1.seq].tot_comp_18 = (temp->qual[d1.seq].tot_comp_18+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (email_ind=0)
  SELECT INTO value(var_output)
   FROM (dummyt d1  WITH seq = size(temp->qual,5))
   PLAN (d1)
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}{F/1}{CPI/14}{B}", rpt_tot_adm_res = 0,
    rpt_tot_tran_res = 0, rpt_tot_disch_res = 0, rpt_tot_adm_rule = 0,
    rpt_tot_tran_rule = 0, rpt_tot_disch_rule = 0, pct_adm_done = 0,
    pct_tran_done = 0, pct_disch_done = 0, rpt_tot_comp12 = 0,
    rpt_tot_comp24 = 0, rpt_tot_comp18 = 0, row + 2,
    col 40, "{B}Facility  Medication Reconciliation{ENDB}", row + 2,
    col 35, "{B}Report Date: ", today = format(curdate,"MMM-DD-YYYY;;D"),
    st_dt2 = build("{B}Audit From...",format(cnvtdate(start_disch_date),"mm/dd/yy;;d"),"  To...    ",
     format(cnvtdate(end_disch_date),"mm/dd/yy;;d")), col + 1, st_dt2,
    row + 2
   HEAD PAGE
    col 0, "{B}PAGE:", col + 1,
    curpage, row + 1, row + 1,
    col 16, "{B}Admits", col 44,
    "Done In", call reportmove('COL',(48+ 5),0), "Transfers",
    col 95, "Discharge", row + 1,
    col 0, "{B}Facility", col 12,
    "Unit", col 18, "Completed",
    col 28, "Patients", col 38,
    "%Done", col 44, "18hrs",
    col 52, "|", call reportmove('COL',(48+ 5),0),
    "Completed", call reportmove('COL',(59+ 5),0), "Patients",
    call reportmove('COL',(69+ 5),0), "%Done", call reportmove('COL',(76+ 5),0),
    "12 hrs", call reportmove('COL',(82+ 5),0), "|",
    call reportmove('COL',(83+ 5),0), "Completed", call reportmove('COL',(93+ 5),0),
    "Patients", call reportmove('COL',(103+ 5),0), "%Done{ENDB}",
    row + 1, col 0, "{REPEAT/118/_/}"
   DETAIL
    row + 1, col 0,
    CALL print(trim(temp->qual[d1.seq].facility)),
    col 9,
    CALL print(trim(temp->qual[d1.seq].units)), col 16,
    CALL print(trim(cnvtstring(cnvtreal(temp->qual[d1.seq].tot_admt_res)))), col 25,
    CALL print(trim(cnvtstring(cnvtreal(temp->qual[d1.seq].tot_admt_rule)))),
    col 35,
    CALL print(trim(cnvtstring(((cnvtreal(temp->qual[d1.seq].tot_admt_res)/ temp->qual[d1.seq].
      tot_admt_rule) * 100)))), col 41,
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_comp_18))), col 49, "|",
    col 51,
    CALL print(trim(cnvtstring(cnvtreal(temp->qual[d1.seq].tot_tran_res)))), col 61,
    CALL print(trim(cnvtstring(cnvtreal(temp->qual[d1.seq].tot_tran_rule)))), col 71,
    CALL print(trim(cnvtstring(((cnvtreal(temp->qual[d1.seq].tot_tran_res)/ temp->qual[d1.seq].
      tot_tran_rule) * 100)))),
    col 81,
    CALL print(trim(cnvtstring(temp->qual[d1.seq].tot_comp_12))), col 84,
    "|", col 85,
    CALL print(trim(cnvtstring(cnvtreal(temp->qual[d1.seq].tot_disch_res)))),
    col 95,
    CALL print(trim(cnvtstring(cnvtreal(temp->qual[d1.seq].tot_disch_rule)))), col 105,
    CALL print(trim(cnvtstring(((cnvtreal(temp->qual[d1.seq].tot_disch_res)/ temp->qual[d1.seq].
      tot_disch_rule) * 100)))), rpt_tot_adm_res = (temp->qual[d1.seq].tot_admt_res+ rpt_tot_adm_res),
    rpt_tot_tran_res = (temp->qual[d1.seq].tot_tran_res+ rpt_tot_tran_res),
    rpt_tot_disch_res = (temp->qual[d1.seq].tot_disch_res+ rpt_tot_disch_res), rpt_tot_adm_rule = (
    temp->qual[d1.seq].tot_admt_rule+ rpt_tot_adm_rule), rpt_tot_tran_rule = (temp->qual[d1.seq].
    tot_tran_rule+ rpt_tot_tran_rule),
    rpt_tot_disch_rule = (temp->qual[d1.seq].tot_disch_rule+ rpt_tot_disch_rule), rpt_tot_comp24 = (
    temp->qual[d1.seq].tot_comp_24+ rpt_tot_comp24), rpt_tot_comp18 = (temp->qual[d1.seq].tot_comp_18
    + rpt_tot_comp18),
    rpt_tot_comp12 = (temp->qual[d1.seq].tot_comp_12+ rpt_tot_comp12)
   FOOT REPORT
    row + 1, col 0, "{REPEAT/118/_/}",
    row + 1, pct_adm_done = ((cnvtreal(rpt_tot_adm_res)/ rpt_tot_adm_rule) * 100), pct_tran_done = ((
    cnvtreal(rpt_tot_tran_res)/ rpt_tot_tran_rule) * 100),
    pct_disch_done = ((cnvtreal(rpt_tot_disch_res)/ rpt_tot_disch_rule) * 100), col 0, "{B/6}Totals:",
    col 21,
    CALL print(trim(cnvtstring(rpt_tot_adm_res))), col 30,
    CALL print(trim(cnvtstring(rpt_tot_adm_rule))), col 40,
    CALL print(trim(cnvtstring(pct_adm_done))),
    col 46,
    CALL print(trim(cnvtstring(rpt_tot_comp18))), col 54,
    "|", col 56,
    CALL print(trim(cnvtstring(rpt_tot_tran_res))),
    call reportmove('COL',(61+ 5),0),
    CALL print(trim(cnvtstring(rpt_tot_tran_rule))), call reportmove('COL',(71+ 5),0),
    CALL print(trim(cnvtstring(pct_tran_done))), call reportmove('COL',(81+ 5),0),
    CALL print(trim(cnvtstring(rpt_tot_comp12))),
    col 89, "|", col 90,
    CALL print(trim(cnvtstring(rpt_tot_disch_res))), col 100,
    CALL print(trim(cnvtstring(rpt_tot_disch_rule))),
    col 110,
    CALL print(trim(cnvtstring(pct_disch_done)))
   WITH nocounter, format, separator = " ",
    dio = 08
  ;end select
 ELSEIF (email_ind=1)
  SELECT INTO value(var_output)
   facility = temp->qual[d1.seq].facility, nrs_unit = temp->qual[d1.seq].units, admit_comp = temp->
   qual[d1.seq].tot_admt_res,
   admit_patients = temp->qual[d1.seq].tot_admt_rule, admit_per_done = ((cnvtreal(temp->qual[d1.seq].
    tot_admt_res)/ temp->qual[d1.seq].tot_admt_rule) * 100), admit_comp18 = temp->qual[d1.seq].
   tot_comp_18,
   tran_comp = temp->qual[d1.seq].tot_tran_res, tran_patients = temp->qual[d1.seq].tot_tran_rule,
   tran_per_done = ((cnvtreal(temp->qual[d1.seq].tot_tran_res)/ temp->qual[d1.seq].tot_tran_rule) *
   100),
   tran_comp_12 = temp->qual[d1.seq].tot_comp_12, disch_comp = temp->qual[d1.seq].tot_disch_res,
   disch_patients = temp->qual[d1.seq].tot_disch_rule,
   disch_per_done = ((cnvtreal(temp->qual[d1.seq].tot_disch_res)/ temp->qual[d1.seq].tot_disch_rule)
    * 100)
   FROM (dummyt d1  WITH seq = size(temp->qual,5))
   WITH nocounter, format, pcformat('"',","),
    time = 30
  ;end select
  SET filename_in = trim(var_output)
  SET email_address = trim(send_mail)
  SET filename_out = "bhs_audit_facilty.csv"
  SET subject = concat("Facility Medication Reconcilation Report")
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,subject,0)
 ENDIF
#exit_prg
END GO
