CREATE PROGRAM bhs_medrec_detail_audit_attend:dba
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
 SELECT DISTINCT INTO  $OUTDEV
  psn.name_full_formatted, epr.prsnl_person_id, emad.encntr_id,
  e_loc_nurse_unit_disp = uar_get_code_display(elh.loc_nurse_unit_cd), ema.module_name, elh
  .beg_effective_dt_tm,
  module_sort =
  IF (ema.module_name="BHS_SYN_MED_REC_ADM*") 1
  ELSEIF (ema.module_name="BHS_SYN_MED_REC_TRANSFER") 2
  ELSEIF (ema.module_name="BHS_SYN_MED_REC_DISCH") 3
  ENDIF
  FROM eks_module_audit ema,
   eks_module_audit_det emad,
   encounter e,
   encntr_loc_hist elh,
   encntr_prsnl_reltn epr,
   prsnl psn
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
   JOIN (psn
   WHERE epr.prsnl_person_id=psn.person_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ema.updt_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
  ORDER BY emad.encntr_id, psn.name_full_formatted, module_sort,
   e_loc_nurse_unit_disp, 0
  WITH nocounter, format, separator = " "
 ;end select
#exit_prg
END GO
