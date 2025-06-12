CREATE PROGRAM bhs_pneumonia_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Facility (BMC, MLH, FMC, BNH, BNHINPTPSYCH, BNHREHAB) " = "BMC"
  WITH outdev, fac
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 DECLARE medgeneral_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",34,"MEDGENERAL")), protect
 SET fac_cd = 0.0
 SET encntr_type_cd1 = 0.0
 SET encntr_type_cd2 = 0.0
 SET encntr_type_cd3 = 0.0
 SET person_alias_cd = 0.0
 SET atten_cd = 0.0
 SET rx_activity_type = 0.0
 SET rx_catalog_type = 0.0
 SET xr_activity_type = 0.0
 SET xr_catalog_type = 0.0
 SET ordered_cd = 0.0
 SET completed_cd = 0.0
 SET pendingcomplete_cd = 0.0
 SET rendingreview_cd = 0.0
 SET inprocess_cd = 0.0
 SET person_alias_cd = uar_get_code_by("DISPLAY_KEY",4,"MRN")
 SET attend_cd = 0.0
 SET attend_cd = uar_get_code_by("DISPLAY_KEY",333,"ATTENDINGPHYSICIAN")
 SET rx_activity_type = 0.0
 SET rx_activity_type = uar_get_code_by("DISPLAY_KEY",106,"PHARMACY")
 SET xr_activity_type = 0.0
 SET xr_activity_type = uar_get_code_by("DISPLAY_KEY",106,"RADIOLOGY")
 SET rx_catalog_type = 0.0
 SET rx_catalog_type = uar_get_code_by("DISPLAY_KEY",6000,"PHARMACY")
 SET xr_catalog_type = 0.0
 SET xr_catalog_type = uar_get_code_by("DISPLAY_KEY",6000,"RADIOLOGY")
 SET ordered_cd = 0.0
 SET ordered_cd = uar_get_code_by("DISPLAY_KEY",6004,"ORDERED")
 SET completed_cd = 0.0
 SET completed_cd = uar_get_code_by("DISPLAY_KEY",6004,"COMPLETED")
 SET pendingcomplete_cd = 0.0
 SET pendingcomplete_cd = uar_get_code_by("DISPLAY_KEY",6004,"PENDINGCOMPLETE")
 SET pendingreview_cd = 0.0
 SET pendingreview_cd = uar_get_code_by("DISPLAY_KEY",6004,"PENDINGREVIEW")
 SET inprocess_cd = 0.0
 SET inprocess_cd = uar_get_code_by("DISPLAY_KEY",6004,"INPROCESS")
 SET st_date = cnvtdatetime((curdate - 1),0000)
 SET en_date = cnvtdatetime(curdate,curtime)
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND (cv.display_key= $FAC)
  DETAIL
   fac_cd = cv.code_value
  WITH maxrec = 1
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  pat_name = trim(p.name_full_formatted), reg_dt = e.reg_dt_tm"@SHORTDATETIME", age = cnvtage(
   cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),
  disch_dt = e.disch_dt_tm"@SHORTDATETIME", pt_type = trim(uar_get_code_display(e.encntr_type_cd)),
  mrn = cnvtalias(pa.alias,pa.alias_pool_cd),
  nurse = trim(uar_get_code_display(e.loc_nurse_unit_cd)), room_bed = concat(trim(
    uar_get_code_display(e.loc_room_cd)),"-",trim(uar_get_code_display(e.loc_bed_cd))), dr_name =
  trim(pr.name_full_formatted),
  cxr_ord = trim(uar_get_code_display(o.catalog_cd)), abx_order = trim(uar_get_code_display(o2
    .catalog_cd)), cxr_ord_dt = o.orig_order_dt_tm"@SHORTDATE",
  abx_ord_dt = o2.orig_order_dt_tm"@SHORTDATE", st_date = cnvtdatetime((curdate - 1),0000)
  "mm/dd/yyyy;;d", en_date = cnvtdatetime(curdate,curtime)"mm/dd/yyyy;;d"
  FROM encntr_domain ed,
   encounter e,
   person p,
   person_alias pa,
   encntr_prsnl_reltn ep,
   prsnl pr,
   orders o,
   orders o2,
   dummyt d
  PLAN (ed
   WHERE ed.end_effective_dt_tm > sysdate
    AND ed.med_service_cd=medgeneral_var
    AND ed.encntr_id IN (
   (SELECT
    o.encntr_id
    FROM orders o
    WHERE o.catalog_cd IN (877482, 877485, 787221, 787929, 787931,
    787930, 787312, 787314, 787327, 787329,
    881866, 773026.00, 772346.00, 772482.00)
     AND o.encntr_id=ed.encntr_id)))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND ((e.loc_facility_cd+ 0)=fac_cd)
    AND ((e.encntr_type_cd+ 0) IN (679656.00, 309308.00, 309312.00))
    AND ((e.active_ind+ 0)=1)
    AND e.disch_dt_tm=null
    AND e.med_service_cd=medgeneral_var)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND ((cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)+ 0) < cnvtdatetime(
    cnvtagedatetime(18,0,0,0))))
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND ((pa.person_alias_type_cd+ 0)=person_alias_cd))
   JOIN (ep
   WHERE ep.encntr_id=e.encntr_id
    AND ((ep.encntr_prsnl_r_cd+ 0)=attend_cd)
    AND ep.expiration_ind=0
    AND ep.end_effective_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=ep.prsnl_person_id
    AND ((pr.person_id+ 0) != 0))
   JOIN (d)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.catalog_type_cd=xr_catalog_type
    AND o.activity_type_cd=xr_activity_type
    AND o.catalog_cd IN (877482, 877485, 787221, 787929, 787931,
   787930, 787312, 787314, 787327, 787329,
   881866)
    AND ((o.order_status_cd+ 0) IN (ordered_cd, completed_cd, pendingcomplete_cd, inprocess_cd,
   pendingreview_cd))
    AND ((o.updt_dt_tm+ 0) >= cnvtdatetime((curdate - 1),0000)))
   JOIN (o2
   WHERE o2.encntr_id=e.encntr_id
    AND o2.person_id=e.person_id
    AND o2.catalog_type_cd=rx_catalog_type
    AND o2.activity_type_cd=rx_activity_type
    AND o2.catalog_cd IN (773026.00, 772346.00, 772482.00)
    AND cnvtupper(o2.hna_order_mnemonic) IN ("LEVOFLOXACIN", "CEFTRIAXONE", "AZITHROMYCIN")
    AND o2.orig_order_dt_tm >= cnvtdatetime((curdate - 1),curtime3)
    AND ((o2.template_order_id+ 0) < 1))
  ORDER BY nurse, room_bed, o2.order_id,
   o2.order_mnemonic, 0
  HEAD REPORT
   rpt_range = concat("Range: ",format(cnvtdatetime(cnvtdate(st_date),0000),"mm/dd/yyyy hh:mm;;d"),
    " - ",format(cnvtdatetime(cnvtdate(en_date),curtime),"mm/dd/yyyy hh:mm;;d")), y_pos = 18,
   printpsheader = 0,
   col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , tot_pts = 0
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1, row + 1, "{F/5}{CPI/11}",
   CALL print(calcpos(324,(y_pos+ 11))), "Pneumonia Detection Report", row + 1,
   row + 1, "{CPI/14}",
   CALL print(calcpos(36,(y_pos+ 29))),
   "Report Date:", row + 1,
   CALL print(calcpos(90,(y_pos+ 29))),
   curdate, row + 1,
   CALL print(calcpos(320,(y_pos+ 29))),
   rpt_range, row + 1,
   CALL print(calcpos(666,(y_pos+ 29))),
   "Page:", row + 1,
   CALL print(calcpos(684,(y_pos+ 29))),
   curpage, row + 1, row + 1,
   CALL print(calcpos(36,(y_pos+ 47))), "Report Time:", row + 1,
   CALL print(calcpos(90,(y_pos+ 47))), curtime, row + 1,
   row + 1,
   CALL print(calcpos(36,(y_pos+ 65))), "Patient",
   CALL print(calcpos(162,(y_pos+ 65))), "Med Rec",
   CALL print(calcpos(252,(y_pos+ 65))),
   "Location",
   CALL print(calcpos(324,(y_pos+ 65))), "Attend Phys",
   CALL print(calcpos(486,(y_pos+ 65))), "CXR Date",
   CALL print(calcpos(576,(y_pos+ 65))),
   "ABX Date",
   CALL print(calcpos(648,(y_pos+ 65))), "Antibiotic",
   row + 1, row + 1, y_val = ((792 - y_pos) - 93),
   "{PS/newpath 2 setlinewidth   36 ", y_val, " moveto  736 ",
   y_val, " lineto stroke 36 ", y_val,
   " moveto/}", row + 1, y_pos += 85
  HEAD e.encntr_id
   x = 0
  HEAD o.order_id
   row + 1, "{F/4}{CPI/14}", row + 1,
   CALL print(calcpos(36,(y_pos+ 11))), pat_name, row + 1,
   CALL print(calcpos(162,(y_pos+ 11))), mrn, row + 1,
   CALL print(calcpos(252,(y_pos+ 11))), room_bed, row + 1,
   CALL print(calcpos(324,(y_pos+ 11))), dr_name, row + 1,
   CALL print(calcpos(486,(y_pos+ 11))), cxr_ord_dt, row + 1
  HEAD o2.order_id
   row + 1, "{F/4}{CPI/14}", row + 1,
   CALL print(calcpos(576,(y_pos+ 11))), abx_ord_dt, row + 1,
   CALL print(calcpos(648,(y_pos+ 11))), abx_order, row + 1,
   y_pos += 11
  FOOT  o2.order_id
   y_pos += 0
  FOOT  o.order_id
   y_pos += 0
  FOOT  e.encntr_id
   x = 0
  FOOT REPORT
   IF (((y_pos+ 116) >= 612))
    y_pos = 0, BREAK
   ELSE
    y_pos += 36
   ENDIF
   tot_pts = (count(e.encntr_id) - 1)
   IF (tot_pts >= 1)
    y_pos += 24, row + 1, "{F/5}{CPI/14}",
    CALL print(calcpos(324,(y_pos+ 11))), "Total Patients Detected:", row + 1,
    CALL print(calcpos(414,(y_pos+ 11))), tot_pts, row + 1,
    row + 1,
    CALL print(calcpos(324,(y_pos+ 65))), "Program:",
    row + 1,
    CALL print(calcpos(360,(y_pos+ 65))), curprog
   ELSE
    y_pos += 24, row + 1, "{F/5}{CPI/14}",
    CALL print(calcpos(324,(y_pos+ 11))), "No Patients Detected"
   ENDIF
  WITH maxcol = 300, maxrow = 300, landscape,
   dio = 08, noheading, format = variable,
   time = value(maxsecs), nullreport
 ;end select
END GO
