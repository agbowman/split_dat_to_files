CREATE PROGRAM bhs_med_recon_detail2
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select From List:" = 0,
  "Enter Start Date:" = curdate,
  "Enter End Date" = curdate
  WITH outdev, physician_id, st_dt,
  en_dt
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 150
 ENDIF
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(2,0)))), public
 SET fnbr = uar_get_code_by("DISPLAY_KEY",319,"FINNBR")
 SET status_1 = uar_get_code_by("DISPLAY_KEY",6004,"ORDERED")
 SET status_2 = uar_get_code_by("DISPLAY_KEY",6004,"COMPLETED")
 SET activity_type_1 = uar_get_code_by("DISPLAY_KEY",106,"COMMUNICATIONORDERS")
 SET catalog_type_1 = uar_get_code_by("DISPLAY_KEY",6000,"PATIENTCARE")
 SET catalog_cd_3 = uar_get_code_by("DISPLAY_KEY",200,"HOMEMEDSUPDATEDINMEDICATIONPROFILE")
 SET catalog_cd_2 = uar_get_code_by("DISPLAY_KEY",200,"COMPLETEMEDRECONCILIATIONDISCHARGE")
 SET catalog_cd_1 = uar_get_code_by("DISPLAY_KEY",200,"COMPLETEMEDRECONCILIATIONADMIT")
 SELECT
  IF (any_status_ind="C")
   PLAN (d1)
    JOIN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0000) AND cnvtdatetime(cnvtdate(
       $EN_DT),235959)
     AND ((e.encntr_type_cd+ 0)=679656.00))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (ep
    WHERE ep.encntr_id=e.encntr_id
     AND ep.encntr_prsnl_r_cd=1119
     AND ep.prsnl_person_id > 0
     AND ((ep.active_ind=1
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000))) OR (ep.active_ind=0
     AND ((ep.expire_dt_tm+ 0) != null)
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000)))) )
    JOIN (p2
    WHERE p2.person_id=ep.prsnl_person_id)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fnbr)
    JOIN (o
    WHERE o.encntr_id=outerjoin(e.encntr_id)
     AND o.catalog_cd=outerjoin(792016))
    JOIN (oa
    WHERE oa.order_id=outerjoin(o.order_id)
     AND oa.action_sequence=outerjoin(1)
     AND oa.order_provider_id > outerjoin(0))
    JOIN (p1
    WHERE p1.person_id=outerjoin(oa.order_provider_id))
    JOIN (o1
    WHERE o1.encntr_id=outerjoin(e.encntr_id)
     AND o1.catalog_cd=outerjoin(catalog_cd_1)
     AND o1.order_status_cd=outerjoin(status_2))
    JOIN (o2
    WHERE o2.encntr_id=outerjoin(e.encntr_id)
     AND o2.catalog_cd=outerjoin(61245331.00))
    JOIN (o3
    WHERE o3.encntr_id=outerjoin(e.encntr_id)
     AND o3.need_rx_verify_ind=outerjoin(0)
     AND o3.activity_type_cd=outerjoin(705)
     AND o3.catalog_type_cd=outerjoin(2516)
     AND o3.orig_ord_as_flag IN (outerjoin(1), outerjoin(2)))
  ELSE
   PLAN (d1)
    JOIN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0000) AND cnvtdatetime(cnvtdate(
       $EN_DT),235959)
     AND ((e.encntr_type_cd+ 0)=679656.00))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (ep
    WHERE ep.encntr_id=e.encntr_id
     AND ep.encntr_prsnl_r_cd=1119
     AND (ep.prsnl_person_id= $PHYSICIAN_ID)
     AND ((ep.active_ind=1
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000))) OR (ep.active_ind=0
     AND ((ep.expire_dt_tm+ 0) != null)
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000)))) )
    JOIN (p2
    WHERE p2.person_id=ep.prsnl_person_id)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fnbr)
    JOIN (o
    WHERE o.encntr_id=outerjoin(e.encntr_id)
     AND o.catalog_cd=outerjoin(792016))
    JOIN (oa
    WHERE oa.order_id=outerjoin(o.order_id)
     AND oa.action_sequence=outerjoin(1)
     AND oa.order_provider_id > outerjoin( $PHYSICIAN_ID))
    JOIN (p1
    WHERE p1.person_id=outerjoin(oa.order_provider_id))
    JOIN (o1
    WHERE o1.encntr_id=outerjoin(e.encntr_id)
     AND o1.catalog_cd=outerjoin(catalog_cd_1)
     AND o1.order_status_cd=outerjoin(status_2))
    JOIN (o2
    WHERE o2.encntr_id=outerjoin(e.encntr_id)
     AND o2.catalog_cd=outerjoin(61245331.00))
    JOIN (o3
    WHERE o3.encntr_id=outerjoin(e.encntr_id)
     AND o3.need_rx_verify_ind=outerjoin(0)
     AND o3.activity_type_cd=outerjoin(705)
     AND o3.catalog_type_cd=outerjoin(2516)
     AND o3.orig_ord_as_flag IN (outerjoin(1), outerjoin(2)))
  ENDIF
  DISTINCT INTO  $OUTDEV
  pat_name = substring(1,30,trim(p.name_full_formatted)), acct_nbr = cnvtalias(ea.alias,ea
   .alias_pool_cd), phys =
  IF (p1.person_id=0.0) trim(p2.name_full_formatted)
  ELSE trim(p1.name_full_formatted)
  ENDIF
  ,
  adm_med_rec_dt =
  IF (o1.orig_order_dt_tm=null) " "
  ELSE format(o1.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
  ENDIF
  , med_rec_ord =
  IF (o2.orig_order_dt_tm != null) "Yes"
  ELSE "No"
  ENDIF
  , med_prof_updt = o3.updt_dt_tm"@SHORTDATETIME",
  disch_ord_dt =
  IF (o.orig_order_dt_tm=null) "Not Ordered"
  ELSE format(o.orig_order_dt_tm,"mm/dd/yyyy HH:MM;;d")
  ENDIF
  , e.disch_dt_tm"@SHORTDATETIME", diff_disch_ord =
  IF (datetimediff(o.orig_order_dt_tm,o3.updt_dt_tm,3) <= 2.00
   AND o.orig_order_dt_tm != null) "Yes"
  ELSE "No"
  ENDIF
  ,
  diff_disch_dt =
  IF (datetimediff(e.disch_dt_tm,o3.updt_dt_tm,3) <= 2.00) "Yes"
  ELSE "No"
  ENDIF
  , attend_phy = trim(p2.name_full_formatted), e.active_ind,
  o.catalog_cd, o_catalog_disp = uar_get_code_display(o.catalog_cd), o.activity_type_cd,
  o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o.catalog_type_cd,
  o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd),
  o.encntr_id, o.dept_status_cd, o_dept_status_disp = uar_get_code_display(o.dept_status_cd),
  o.order_id, oa.action_sequence, oa.order_provider_id,
  oa.order_id, o1.catalog_cd, o1_catalog_disp = uar_get_code_display(o1.catalog_cd),
  o.order_status_cd, o1.catalog_type_cd, o1_catalog_type_disp = uar_get_code_display(o1
   .catalog_type_cd),
  o_order_status_disp = uar_get_code_display(o.order_status_cd), o1.activity_type_cd,
  o1_activity_type_disp = uar_get_code_display(o1.activity_type_cd),
  o1.order_id, o2.catalog_cd, o2_catalog_disp = uar_get_code_display(o2.catalog_cd),
  o.person_id, o2.catalog_type_cd, o2_catalog_type_disp = uar_get_code_display(o2.catalog_type_cd),
  o2.activity_type_cd, o2_activity_type_disp = uar_get_code_display(o2.activity_type_cd), o2.order_id,
  o2.order_status_cd, o2_order_status_disp = uar_get_code_display(o2.order_status_cd), o1
  .order_status_cd,
  o1_order_status_disp = uar_get_code_display(o1.order_status_cd), p1.person_id,
  o3_activity_type_disp = uar_get_code_display(o3.activity_type_cd),
  o3_catalog_type_disp = uar_get_code_display(o3.catalog_type_cd), o3_catalog_disp =
  uar_get_code_display(o3.catalog_cd), o3.encntr_id,
  o3.order_id, o3.orig_ord_as_flag, ep.encntr_id,
  ep.encntr_prsnl_reltn_id, ep.prsnl_person_id, ep.expire_dt_tm"@SHORTDATETIME"
  FROM dummyt d1,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn ep,
   person p2,
   orders o,
   order_action oa,
   person p1,
   orders o1,
   orders o2,
   orders o3
  ORDER BY phys, acct_nbr
  HEAD REPORT
   y_pos = 18, pat_cnt2 = 0, printpsheader = 0,
   col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/5}{CPI/11}",
   CALL print(calcpos(293,(y_pos+ 0))), "Medication Reconciliation Detail Report", row + 1,
   row + 1, "{CPI/14}", strtend = concat("Range: ",format(cnvtdatetime(cnvtdate( $ST_DT),0000),
     "mm/dd/yyyy hh:mm;;d")," - ",format(cnvtdatetime(cnvtdate( $EN_DT),2359),"mm/dd/yyyy hh:mm;;d")),
   CALL print(calcpos(54,(y_pos+ 18))), "Report Date:", row + 1,
   CALL print(calcpos(126,(y_pos+ 18))), curdate, row + 1,
   CALL print(calcpos(300,(y_pos+ 18))), strtend,
   CALL print(calcpos(54,(y_pos+ 18))),
   "Report Date:", row + 1,
   CALL print(calcpos(126,(y_pos+ 18))),
   curdate, row + 1,
   CALL print(calcpos(630,(y_pos+ 18))),
   "Page:", row + 1,
   CALL print(calcpos(648,(y_pos+ 18))),
   curpage, row + 1, row + 1,
   CALL print(calcpos(54,(y_pos+ 36))), "Report Time:", row + 1,
   CALL print(calcpos(126,(y_pos+ 36))), curtime, row + 1,
   row + 1,
   CALL print(calcpos(216,(y_pos+ 54))), "Patient Name",
   CALL print(calcpos(342,(y_pos+ 54))), "Account Num",
   CALL print(calcpos(450,(y_pos+ 54))),
   "Admit",
   CALL print(calcpos(522,(y_pos+ 54))), "Discharge",
   CALL print(calcpos(594,(y_pos+ 54))), "Phys. Recon",
   CALL print(calcpos(684,(y_pos+ 54))),
   "Home Meds", row + 1,
   CALL print(calcpos(432,(y_pos+ 72))),
   "Med Recon Date",
   CALL print(calcpos(522,(y_pos+ 72))), "Order Date",
   CALL print(calcpos(594,(y_pos+ 72))), "Order Placed",
   CALL print(calcpos(684,(y_pos+ 72))),
   "Updated", row + 1, row + 1,
   y_val = ((792 - y_pos) - 100), "{PS/newpath 2 setlinewidth   54 ", y_val,
   " moveto  751 ", y_val, " lineto stroke 54 ",
   y_val, " moveto/}", row + 1,
   y_pos = (y_pos+ 103)
  HEAD phys
   IF (((y_pos+ 67) >= 612))
    y_pos = 0, BREAK
   ENDIF
   row + 1, "{F/5}{CPI/13}", row + 1,
   CALL print(calcpos(72,(y_pos+ 0))), phys, row + 1
  DETAIL
   IF (((y_pos+ 67) >= 612))
    y_pos = 0, BREAK
   ENDIF
   row + 1, "{F/4}{CPI/14}", row + 1,
   CALL print(calcpos(216,(y_pos+ 0))), pat_name, row + 1,
   CALL print(calcpos(342,(y_pos+ 0))), acct_nbr, row + 1,
   CALL print(calcpos(432,(y_pos+ 0))), adm_med_rec_dt, row + 1,
   CALL print(calcpos(522,(y_pos+ 0))), disch_ord_dt, row + 1,
   CALL print(calcpos(612,(y_pos+ 0))), med_rec_ord, row + 1,
   CALL print(calcpos(702,(y_pos+ 0))), diff_disch_ord, y_pos = (y_pos+ 13)
  FOOT  phys
   IF (((y_pos+ 67) >= 612))
    y_pos = 0, BREAK
   ENDIF
   "{F/0}{CPI/16}", pat_count = count(acct_nbr), row + 1,
   "{F/5}{CPI/14}",
   CALL print(calcpos(198,(y_pos+ 13))), "Patients Reported:",
   pat_count2 = count(acct_nbr), row + 1,
   CALL print(calcpos(306,(y_pos+ 13))),
   pat_count2"####", count_med_recon = count(o1.order_id
    WHERE o1.orig_order_dt_tm != null), count_med_updt = count(o2.order_id
    WHERE o2.orig_order_dt_tm != null),
   count_med_updt2 = count(o3.order_id
    WHERE diff_disch_ord="Yes"), row + 1, row + 1,
   CALL print(calcpos(180,(y_pos+ 26))), "Admit Recon Complete:", row + 1,
   CALL print(calcpos(306,(y_pos+ 26))), count_med_recon"####", perc_med_recon = ((count_med_recon/
   pat_count) * 100),
   row + 1,
   CALL print(calcpos(414,(y_pos+ 26))), perc_med_recon"###.#%",
   row + 1, row + 1,
   CALL print(calcpos(180,(y_pos+ 39))),
   "Home Meds Updated:", row + 1,
   CALL print(calcpos(306,(y_pos+ 39))),
   count_med_updt2"####", perc_med_updt = ((count_med_updt2/ pat_count) * 100), row + 1,
   CALL print(calcpos(414,(y_pos+ 39))), perc_med_updt"###.#%", y_pos = (y_pos+ 65)
  FOOT REPORT
   BREAK, row + 1, "{F/5}{CPI/11}",
   CALL print(calcpos(353,(y_pos+ 0))), "Report Summary", row + 1,
   "{F/0}{CPI/16}", pat_count = count(acct_nbr), pat_count2 = count(acct_nbr),
   count_med_recon = count(o1.order_id
    WHERE o1.orig_order_dt_tm != null), count_med_updt = count(o2.order_id
    WHERE o2.orig_order_dt_tm != null), count_med_updt2 = count(o3.order_id
    WHERE diff_disch_ord="Yes"),
   row + 1, "{F/5}{CPI/14}",
   CALL print(calcpos(198,(y_pos+ 72))),
   "Patients Reported:", row + 1,
   CALL print(calcpos(306,(y_pos+ 72))),
   pat_count2"####", row + 1, row + 1,
   CALL print(calcpos(180,(y_pos+ 85))), "Admit Recon Complete:", row + 1,
   CALL print(calcpos(306,(y_pos+ 85))), count_med_recon"####", perc_med_recon = ((count_med_recon/
   pat_count) * 100),
   row + 1,
   CALL print(calcpos(414,(y_pos+ 85))), perc_med_recon"###.#%",
   row + 1, row + 1,
   CALL print(calcpos(180,(y_pos+ 98))),
   "Home Meds Updated:", row + 1,
   CALL print(calcpos(306,(y_pos+ 98))),
   count_med_updt2"####", perc_med_updt = ((count_med_updt2/ pat_count) * 100), row + 1,
   CALL print(calcpos(414,(y_pos+ 98))), perc_med_updt"###.#%"
  WITH nullreport, maxcol = 300, maxrow = 500,
   landscape, dio = 08, noheading,
   format = variable, time = value(maxsecs)
 ;end select
END GO
