CREATE PROGRAM bhs_ma_ancillary_compl:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Beginning Date" = "CURDATE",
  "Select the Ending Date" = "CURDATE"
  WITH outdev, updt, updt2
 SET ops_ind = validate(request->batch_selection,"N")
 IF (ops_ind != "N")
  SET end_dt = cnvtdatetime((cnvtdate(curdate,"MM01YYYY;;D") - 1),235959)
  SET beg_dt = cnvtdatetime(cnvtdate(end_dt,"MM01YYYY;;D"),0)
 ELSE
  SET beg_dt = cnvtdate( $UPDT,"MMDDYYYY")
  SET end_dt = cnvtdate( $UPDT2,"MMDDYYYY")
  IF (beg_dt > end_dt)
   SET error_message = concat("Begin Date greater than End Date")
   CALL write_error_message(error_message)
   GO TO exit_script
  ENDIF
 ENDIF
 SET start_disp = format(beg_dt,"MM/DD/YYYY;;D")
 SET end_disp = format(end_dt,"MM/DD/YYYY;;D")
 DECLARE completed_cd = f8 WITH noconstant(0.0)
 DECLARE complete_cd = f8 WITH noconstant(0.0)
 DECLARE verified_cd = f8 WITH noconstant(0.0)
 DECLARE mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE mrn_alias_pool_cd = f8 WITH noconstant(0.0)
 DECLARE fin_nbr_cd = f8 WITH noconstant(0.0)
 DECLARE facility_cd = f8 WITH noconstant(0.0)
 DECLARE done_cd = f8 WITH noconstant(0.0)
 DECLARE powerchart_cd = f8 WITH noconstant(0.0)
 DECLARE document_cd = f8 WITH noconstant(0.0)
 DECLARE softmed_cd = f8 WITH noconstant(0.0)
 DECLARE child_cd = f8 WITH noconstant(0.0)
 DECLARE root_cd = f8 WITH noconstant(0.0)
 SET mnstat = uar_get_meaning_by_codeset(6004,"COMPLETED",1,completed_cd)
 SET mnstat = uar_get_meaning_by_codeset(79,"COMPLETE",1,complete_cd)
 SET mrn_alias_cd = uar_get_code_by("MEANING",4,"MRN")
 SET mrn_alias_pool_cd = uar_get_code_by("DISPLAYKEY",263,"FMCMRN")
 SET mnstat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_nbr_cd)
 SET mnstat = uar_get_meaning_by_codeset(8,"AUTH",1,verified_cd)
 SET done_cd = uar_get_code_by("DISPLAYKEY",53,"DONE")
 SET mnstat = uar_get_meaning_by_codeset(89,"POWERCHART",1,powerchart_cd)
 SET document_cd = uar_get_code_by("DISPLAYKEY",53,"DOC")
 SET softmed_cd = uar_get_code_by("DISPLAYKEY",89,"SOFTMED")
 SET mnstat = uar_get_meaning_by_codeset(24,"CHILD",1,child_cd)
 SET mnstat = uar_get_meaning_by_codeset(24,"ROOT",1,root_cd)
 DECLARE fmc_id = f8 WITH noconstant(0.0)
 DECLARE fmc_inp_psych_id = f8 WITH noconstant(0.0)
 DECLARE beacon_rec_id = f8 WITH noconstant(0.0)
 DECLARE brattleboro_id = f8 WITH noconstant(0.0)
 DECLARE adult_php_id = f8 WITH noconstant(0.0)
 DECLARE outpatient_psych_id = f8 WITH noconstant(0.0)
 DECLARE eeg_portable_cd = f8 WITH noconstant(0.0)
 DECLARE eeg_sleep_cd = f8 WITH noconstant(0.0)
 DECLARE eeg_routine_cd = f8 WITH noconstant(0.0)
 DECLARE broncho_eval_cd = f8 WITH noconstant(0.0)
 DECLARE diffuse_cap_cd = f8 WITH noconstant(0.0)
 DECLARE asthma_test_cd = f8 WITH noconstant(0.0)
 DECLARE lung_cap_cd = f8 WITH noconstant(0.0)
 DECLARE max_vent_cd = f8 WITH noconstant(0.0)
 DECLARE metacholine_cd = f8 WITH noconstant(0.0)
 DECLARE pft_comp_cd = f8 WITH noconstant(0.0)
 DECLARE pulm_stress_cd = f8 WITH noconstant(0.0)
 DECLARE spiro_pft_cd = f8 WITH noconstant(0.0)
 DECLARE echo_2d_cd = f8 WITH noconstant(0.0)
 DECLARE echo_complete_cd = f8 WITH noconstant(0.0)
 DECLARE echo_stress_cd = f8 WITH noconstant(0.0)
 DECLARE echo_dobutamine_cd = f8 WITH noconstant(0.0)
 DECLARE holter_24_cd = f8 WITH noconstant(0.0)
 DECLARE holter_48_cd = f8 WITH noconstant(0.0)
 DECLARE stress_dobutamine_cd = f8 WITH noconstant(0.0)
 DECLARE stress_persantine_cd = f8 WITH noconstant(0.0)
 DECLARE tread_mod_stress_cd = f8 WITH noconstant(0.0)
 DECLARE tread_mod_nuc_cd = f8 WITH noconstant(0.0)
 DECLARE tread_post_stress_cd = f8 WITH noconstant(0.0)
 DECLARE tread_post_nuc_cd = f8 WITH noconstant(0.0)
 DECLARE tread_stress_cd = f8 WITH noconstant(0.0)
 DECLARE tread_nuc_cd = f8 WITH noconstant(0.0)
 SET eeg_portable_cd = uar_get_code_by("DISPLAYKEY",200,"EEGPORTABLE")
 SET eeg_sleep_cd = uar_get_code_by("DISPLAYKEY",200,"EEGWSLEEP")
 SET eeg_routine_cd = uar_get_code_by("DISPLAYKEY",200,"EEGROUTINE")
 SET broncho_eval_cd = uar_get_code_by("DISPLAYKEY",200,"BRONCHOSPASMEVALUATION")
 SET diffuse_cap_cd = uar_get_code_by("DISPLAYKEY",200,"DIFFUSINGCAPACITYCARBONMONOXIDE")
 SET asthma_test_cd = uar_get_code_by("DISPLAYKEY",200,"EXERCISETESTFORASTHMA")
 SET lung_cap_cd = uar_get_code_by("DISPLAYKEY",200,"LUNGRESIDUALCAPACITY")
 SET max_vent_cd = uar_get_code_by("DISPLAYKEY",200,"MAXIMUMVOLUNTARYVENTILATION")
 SET metacholine_cd = uar_get_code_by("DISPLAYKEY",200,"METACHOLINECHALLENGE")
 SET pft_comp_cd = uar_get_code_by("DISPLAYKEY",200,"PFTCOMPLETE")
 SET pulm_stress_cd = uar_get_code_by("DISPLAYKEY",200,"PULMSTRESSHOMEO2EVAL")
 SET spiro_pft_cd = uar_get_code_by("DISPLAYKEY",200,"SPIROMETRYSCREENINGPFT")
 SET echo_2d_cd = uar_get_code_by("DISPLAYKEY",200,"ECHO2DWCONTRAST")
 SET echo_complete_cd = uar_get_code_by("DISPLAYKEY",200,"ECHOCOMPLETE")
 SET echo_stress_cd = uar_get_code_by("DISPLAYKEY",200,"ECHOSTRESS")
 SET echo_dobutamine_cd = uar_get_code_by("DISPLAYKEY",200,"ECHOSTRESSWDOBUTAMINE")
 SET holter_24_cd = uar_get_code_by("DISPLAYKEY",200,"HOLTERMONITOR24HOURS")
 SET holter_48_cd = uar_get_code_by("DISPLAYKEY",200,"HOLTERMONITOR48HOURS")
 SET stress_dobutamine_cd = uar_get_code_by("DISPLAYKEY",200,"STRESSNUCWDOBUTAMINE")
 SET stress_persantine_cd = uar_get_code_by("DISPLAYKEY",200,"STRESSNUCWPERSANTINE")
 SET tread_mod_stress_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLMODIFIEDSTRESS")
 SET tread_mod_nuc_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLMODIFIEDWNUCIMAGING")
 SET tread_post_stress_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLPOSTMISTRESS")
 SET tread_post_nuc_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLPOSTMIWNUCIMAGING")
 SET tread_stress_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLSTANDARDSTRESS")
 SET tread_nuc_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLSTANDARDWNUCIMAGING")
 FREE SET orders
 RECORD orders(
   1 qual[*]
     2 order_id = f8
     2 task_completed_ind = c1
     2 softmed_results_ind = c1
     2 p_name = vc
     2 mrn = vc
     2 fin_nbr = vc
     2 order_mnemonic = vc
     2 order_dt_tm = dq8
     2 order_dt = c16
     2 task_dt = c16
     2 softmed_dt = c16
 )
 IF (ops_ind != "N")
  SET reply->status_data.status = "F"
 ENDIF
 SELECT INTO "nl"
  FROM organization o
  WHERE o.org_name IN ("Franklin Medical Center", "Franklin Medical Center Inpatient Psychiatry",
  "Beacon Recovery", "Brattleboro Retreat", "Adult PHP",
  "Outpatient Psych")
   AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND o.active_ind=1
  DETAIL
   CASE (o.org_name)
    OF "Franklin Medical Center":
     fmc_id = o.organization_id
    OF "Franklin Medical Center Inpatient Psychiatry":
     fmc_inp_psych_id = o.organization_id
    OF "Beacon Recovery":
     beacon_rec_id = o.organization_id
    OF "Brattleboro Retreat":
     brattleboro_id = o.organization_id
    OF "Adult PHP":
     adult_php_id = o.organization_id
    OF "Outpatient Psych":
     outpatient_psych_id = o.organization_id
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.order_id, p_name = substring(1,25,p.name_full_formatted), mrn = substring(1,12,pa.alias),
  fin_nbr = substring(1,15,ea.alias), order_mnemonic = substring(1,40,o.ordered_as_mnemonic),
  orderable = uar_get_code_display(o.catalog_cd),
  order_dt = format(o.orig_order_dt_tm,"MM/DD/YYYY;;D")
  FROM orders o,
   encounter e,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(beg_dt,0) AND cnvtdatetime(end_dt,235959)
    AND o.catalog_cd IN (eeg_portable_cd, eeg_sleep_cd, eeg_routine_cd, broncho_eval_cd,
   diffuse_cap_cd,
   asthma_test_cd, lung_cap_cd, max_vent_cd, metacholine_cd, pft_comp_cd,
   pulm_stress_cd, spiro_pft_cd, echo_2d_cd, echo_complete_cd, echo_stress_cd,
   echo_dobutamine_cd, holter_24_cd, holter_48_cd, stress_dobutamine_cd, stress_persantine_cd,
   tread_mod_stress_cd, tread_mod_nuc_cd, tread_post_stress_cd, tread_post_nuc_cd, tread_stress_cd,
   tread_nuc_cd)
    AND o.order_status_cd=completed_cd
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.organization_id IN (fmc_id, fmc_inp_psych_id, beacon_rec_id, brattleboro_id, adult_php_id,
   outpatient_psych_id))
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(mrn_alias_cd)
    AND pa.alias_pool_cd=outerjoin(mrn_alias_pool_cd)
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.active_ind=outerjoin(1))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd)
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.active_ind=outerjoin(1))
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), stat = alterlist(orders->qual,o_cnt), orders->qual[o_cnt].order_id = o
   .order_id,
   orders->qual[o_cnt].p_name = p_name, orders->qual[o_cnt].mrn = mrn, orders->qual[o_cnt].fin_nbr =
   fin_nbr,
   orders->qual[o_cnt].order_mnemonic = order_mnemonic, orders->qual[o_cnt].order_dt = order_dt,
   orders->qual[o_cnt].order_dt_tm = o.orig_order_dt_tm
  WITH counter
 ;end select
 CALL echo(value(size(orders->qual,5)))
 SELECT INTO "nl:"
  ta.order_id, task_dt = format(ta.task_create_dt_tm,"MM/DD/YYYY;;D"), task_status =
  uar_get_code_display(ta.task_status_cd)
  FROM (dummyt d  WITH seq = value(size(orders->qual,5))),
   task_activity ta
  PLAN (d)
   JOIN (ta
   WHERE (ta.order_id=orders->qual[d.seq].order_id)
    AND ta.task_status_cd=complete_cd
    AND ta.active_ind=1)
  ORDER BY ta.order_id
  DETAIL
   orders->qual[d.seq].task_completed_ind = "Y", orders->qual[d.seq].task_dt = task_dt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.order_id, softmed_dt = format(ce.clinsig_updt_dt_tm,"MM/DD/YYYY;;D")
  FROM (dummyt d  WITH seq = value(size(orders->qual,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.order_id=orders->qual[d.seq].order_id)
    AND ce.contributor_system_cd=softmed_cd
    AND ce.result_status_cd=verified_cd
    AND ce.event_reltn_cd=child_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1)
  ORDER BY ce.order_id
  HEAD ce.order_id
   orders->qual[d.seq].softmed_results_ind = "Y", orders->qual[d.seq].softmed_dt = softmed_dt
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  order_id = cnvtstring(orders->qual[d.seq].order_id), p_name = substring(1,25,orders->qual[d.seq].
   p_name), mrn = substring(1,15,orders->qual[d.seq].mrn),
  fin_nbr = substring(1,15,orders->qual[d.seq].fin_nbr), order_mnemonic = substring(1,40,orders->
   qual[d.seq].order_mnemonic), order_dt = orders->qual[d.seq].order_dt,
  task_dt = orders->qual[d.seq].task_dt, softmed_dt = substring(1,10,orders->qual[d.seq].softmed_dt)
  FROM (dummyt d  WITH seq = value(size(orders->qual,5)))
  PLAN (d
   WHERE (orders->qual[d.seq].task_completed_ind="Y")
    AND (orders->qual[d.seq].softmed_results_ind="Y"))
  ORDER BY order_dt DESC, order_mnemonic
  HEAD REPORT
   line = fillstring(178,"-"), p_cnt = 0
  HEAD PAGE
   CALL center("Ancillary Completed Reconciliation Report",1,178), col 156, "Page: ",
   curpage"###", row + 1,
   CALL center("Franklin Medical Center",1,178),
   col 156, curdate, col 166,
   curtime, row + 1, col 76,
   "For ", start_disp, " - ",
   end_disp, row + 2, col 144,
   "Task", col 164, "SoftMed",
   row + 1, col 1, "Order Date",
   col 18, "Orderable", col 64,
   "Order_id", col 78, "Patient Name",
   col 108, "MRN", col 123,
   "Acct #", col 144, "Completed Dt",
   col 164, "Result Dt", row + 1,
   col 1, line, row + 1
  HEAD order_dt
   row + 1
  DETAIL
   IF (row > 47)
    BREAK
   ENDIF
   col 1, order_dt, col 18,
   order_mnemonic, col 64, order_id,
   col 78, p_name, col 108,
   mrn, col 123, fin_nbr,
   col 144, task_dt, col 164,
   softmed_dt, row + 1
  FOOT PAGE
   IF (row > 47)
    col 1, line, row + 1,
    col 1, "Page: ", curpage"###",
    col 156, curdate, col 166,
    curtime
   ENDIF
  FOOT REPORT
   IF (row=44)
    row + 1
   ELSE
    row + 2
   ENDIF
   CALL center("*****  END OF REPORT  *****",1,178), row 47, col 1,
   line, row + 1, col 1,
   "Page: ", curpage"###", col 143,
   "Report Date: ", curdate, col 166,
   curtime
  WITH nocounter, nullreport, maxrow = 50,
   maxcol = 180, landscape, compress
 ;end select
 IF (ops_ind != "N")
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SUBROUTINE write_error_message(error_msg)
   SELECT INTO trim( $1)
    FROM dummyt d
    DETAIL
     col 2, error_msg
    WITH nocounter, noheading, noformat
   ;end select
 END ;Subroutine
END GO
