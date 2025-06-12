CREATE PROGRAM bhs_fac_meds_recon_det1:dba
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
  DISTINCT INTO  $OUTDEV
  e_loc_facility_disp = uar_get_code_display(elh.loc_facility_cd), en.encntr_id, elh
  .beg_effective_dt_tm,
  elh.end_effective_dt_tm, e_loc_nurse_unit_disp = uar_get_code_display(elh.loc_nurse_unit_cd),
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
  WITH nocounter, format, separator = " "
 ;end select
#exit_prg
END GO
