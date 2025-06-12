CREATE PROGRAM bhs_spiritual_srvs_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO value("spiritual_services_report.csv")
  patient_name = p.name_full_formatted, nurse_unit = cv.display_key, admission_dt_tm = format(e
   .reg_dt_tm,"MM-DD-YYYY HH:MM:SS;;D"),
  length_of_stay_in_days = floor(datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm))
  FROM encntr_domain ed,
   encounter e,
   person p,
   code_value cv
  PLAN (ed
   WHERE ed.loc_nurse_unit_cd > 0
    AND ed.loc_facility_cd=673936)
   JOIN (e
   WHERE ed.encntr_id=e.encntr_id
    AND ed.person_id=e.person_id
    AND e.encntr_type_class_cd IN (391, 392)
    AND e.disch_dt_tm = null
    AND datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm) >= 14)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (cv
   WHERE e.loc_nurse_unit_cd=cv.code_value)
  ORDER BY floor(datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm)) DESC
  WITH nocounter, format, pcformat(value('"'),value(",")),
   time = 30000
 ;end select
 SET var_output = "spiritual_services_report.csv"
 EXECUTE bhs_ma_email_file
 CALL emailfile("spiritual_services_report.csv","spiritual_services_report.csv",
  "ashokkumar.kanukuntla@bhs.org,Barbara.miller@bhs.org,susan.gralinski@bhs.org,thomas.chirdo@bhs.org",
  "Spiritual Servies Report",0)
 SELECT INTO value( $1)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "Report was created."
  WITH nocounter
 ;end select
END GO
