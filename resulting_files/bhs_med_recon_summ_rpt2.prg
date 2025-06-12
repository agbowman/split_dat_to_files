CREATE PROGRAM bhs_med_recon_summ_rpt2
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Start Date:" = curdate,
  "Enter End Date" = "CURDATE"
  WITH outdev, st_dt, en_dt
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET num_disch_ords = 0.00
 SET num_disch_summ = 0
 SET num_home_rev = 0
 SET num_disch_ords2 = 0
 SET status_1 = uar_get_code_by("DISPLAY_KEY",6004,"ORDERED")
 SET status_2 = uar_get_code_by("DISPLAY_KEY",6004,"COMPLETED")
 SET contrib_cd = uar_get_code_by("DISPLAY_KEY",89,"POWERCHART")
 SET event_cd = uar_get_code_by("DISPLAY_KEY",72,"PHYSICIANDISCHARGESUMMARY")
 SET entry_mode = uar_get_code_by("DISPLAY_KEY",29520,"POWERNOTE")
 SET activity_type_1 = uar_get_code_by("DISPLAY_KEY",106,"COMMUNICATIONORDERS")
 SET catalog_type_1 = uar_get_code_by("DISPLAY_KEY",6000,"PATIENTCARE")
 SET catalog_cd_3 = uar_get_code_by("DISPLAY_KEY",200,"HOMEMEDSUPDATEDINMEDICATIONPROFILE")
 SET maxsecs = 60
 IF (validate(isodbc,0)=1)
  SET maxsecs = 60
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  disch_ord_phy = trim(pr.name_full_formatted), disch_ord_dt = o.status_dt_tm"@SHORTDATETIME",
  disch_ord_flag =
  IF (o.order_id > 0) "1"
  ENDIF
  ,
  disch_ord = uar_get_code_description(o.catalog_cd), patient_name = substring(1,20,p1
   .name_full_formatted), reg_dt_tm = e.reg_dt_tm"@SHORTDATETIME",
  disch_dt = e.disch_dt_tm"@SHORTDATETIME", p1.person_id, oa.order_provider_id,
  oa.order_id, pr.person_id
  FROM dummyt d1,
   encounter e,
   person p1,
   orders o,
   order_action oa,
   person pr,
   clinical_event c
  PLAN (d1)
   JOIN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0000) AND cnvtdatetime(cnvtdate( $EN_DT
     ),235959)
    AND ((e.encntr_type_cd+ 0)=679656.00))
   JOIN (p1
   WHERE p1.person_id=e.person_id)
   JOIN (o
   WHERE o.encntr_id=outerjoin(e.encntr_id)
    AND o.catalog_cd=outerjoin(792016))
   JOIN (oa
   WHERE oa.order_id=outerjoin(o.order_id))
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (c
   WHERE c.encntr_id=e.encntr_id)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 1
  DETAIL
   IF (row >= 66)
    BREAK
   ENDIF
   col 1, "encntr info: ", col + 1,
   cnt, col + 1, e.encntr_id,
   col + 1, reg_dt_tm, col + 1,
   disch_dt, row + 1, col 1,
   "patient info: ", col + 1, p1.person_id,
   col + 1, patient_name, row + 1,
   col 1, "disch ord: ", col + 1,
   o.order_id, col + 1, disch_ord_flag,
   col + 1, disch_ord_dt, col + 1,
   disch_ord, row + 1, col 1,
   "order_act: ", col + 1, oa.order_provider_id,
   col + 1, oa.order_id, row + 1,
   col 1, "disch_phy_name: ", col + 1,
   disch_ord_phy, row + 1, col + 1,
   "clin event: ", col + 1, c.encntr_id,
   row + 2, cnt = (cnt+ 1)
  WITH maxrec = 500, maxcol = 300, maxrow = 500,
   outerjoin = d2, outerjoin = d3, dio = 08,
   noheading, format = variable, time = value(maxsecs),
   nullreport
 ;end select
END GO
