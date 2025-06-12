CREATE PROGRAM bhs_rpt_pmat_missing_rh_neg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location:" = 0
  WITH outdev, beg_dt, end_dt,
  location
 DECLARE outpatient = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE onetimeop = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE officevisit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT"))
 DECLARE preofficevisit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOFFICEVISIT")
  )
 DECLARE outpatientonetime = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE rhogaminjectiongiven = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RHOGAMINJECTIONGIVEN"))
 DECLARE mf_blood_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BLOODTYPE"))
 DECLARE mrn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"MODIFIED"))
 DECLARE authverified = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_beg_dt = vc WITH protect, constant( $BEG_DT)
 DECLARE ms_end_dt = vc WITH protect, constant( $END_DT)
 DECLARE ms_location = f8 WITH protect, constant( $LOCATION)
 DECLARE full_name = vc WITH protect, noconstant("")
 DECLARE encounter_mrn = f8 WITH protect, noconstant(0)
 DECLARE gest_age_weeks = i2 WITH protect, noconstant(0)
 DECLARE est_due_date = vc WITH protect, noconstant("")
 DECLARE different_ega_days = i4 WITH protect, noconstant(0)
 SET gest_age_weeks = 0
 SELECT INTO value(ms_output)
  full_name = p.name_full_formatted, e.encntr_id, pe.est_gest_age_days,
  est_due_date = trim(format(pe.est_delivery_dt_tm,"mm/dd/yyyy")), encounter_mrn = ea.alias, pe
  .entered_dt_tm
  FROM encounter e,
   person p,
   pregnancy_instance pi,
   pregnancy_estimate pe,
   encntr_alias ea
  PLAN (e
   WHERE e.loc_nurse_unit_cd=ms_location
    AND e.encntr_type_cd IN (outpatientonetime, preofficevisit, officevisit, onetimeop, outpatient)
    AND e.est_arrive_dt_tm BETWEEN cnvtdatetime(ms_beg_dt) AND cnvtdatetime(ms_end_dt))
   JOIN (p
   WHERE e.person_id=p.person_id
    AND  EXISTS (
   (SELECT
    ce.event_cd
    FROM clinical_event ce
    WHERE ce.person_id=p.person_id
     AND ce.event_cd IN (mf_blood_type_cd)
     AND ce.result_val="*NEG*"
     AND ce.result_status_cd IN (authverified, modified)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)))
    AND  NOT ( EXISTS (
   (SELECT
    ce.event_cd
    FROM clinical_event ce
    WHERE ce.person_id=p.person_id
     AND ce.event_cd IN (rhogaminjectiongiven)
     AND ce.event_tag="Yes"
     AND ce.result_status_cd IN (authverified, modified)
     AND ce.valid_from_dt_tm >= cnvtdatetime((curdate - 30),curtime3)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)))))
   JOIN (pi
   WHERE p.person_id=pi.person_id
    AND pi.active_ind=1
    AND pi.preg_end_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pe
   WHERE pi.pregnancy_id=pe.pregnancy_id
    AND pe.est_gest_age_days >= 196
    AND pe.est_delivery_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pe.active_ind=1)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=mrn
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.name_full_formatted, pe.status_flag DESC
  HEAD REPORT
   pl_col = 0, col pl_col, "Patient_Name",
   pl_col = (pl_col+ 50), col pl_col, "MRN",
   pl_col = (pl_col+ 50), col pl_col, "EGA_Weeks",
   pl_col = (pl_col+ 50), col pl_col, "Est_Due_Date",
   pl_col = (pl_col+ 50)
  HEAD pe.pregnancy_id
   different_ega_days = datetimediff(cnvtdatetime(sysdate),cnvtdatetime(pe.entered_dt_tm),1),
   gest_age_weeks = ((pe.est_gest_age_days+ different_ega_days)/ 7), row + 1,
   pl_col = 0, col pl_col, full_name,
   pl_col = (pl_col+ 50), col pl_col, encounter_mrn,
   pl_col = (pl_col+ 50), col pl_col, gest_age_weeks,
   pl_col = (pl_col+ 50), col pl_col, est_due_date,
   pl_col = (pl_col+ 50)
  WITH nocounter, maxcol = 20000, format,
   separator = " "
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
END GO
