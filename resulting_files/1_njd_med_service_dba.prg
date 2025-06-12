CREATE PROGRAM 1_njd_med_service:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 DECLARE mrn_var = f8
 SET mrn_var = uar_get_code_by("MEANING",319,"MRN")
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  e_med_service_disp = uar_get_code_display(e.med_service_cd), p.name_full_formatted, e.reg_dt_tm,
  e.disch_dt_tm, e.reason_for_visit, ea.alias,
  ea_encntr_alias_type_disp = uar_get_code_display(ea.encntr_alias_type_cd), e.encntr_id
  FROM person p,
   encounter e,
   encntr_alias ea
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime("01-JAN-2017 00:00:00.00") AND cnvtdatetime(
    "30-JUN-2017 23:59:59.00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_var)
  ORDER BY e_med_service_disp DESC
  HEAD REPORT
   row 1, col 54, "MEDICAL SERVICE REPORT",
   row + 2
  HEAD PAGE
   col 2, "REPORT DATE:", col 17,
   curdate, row + 2, col 29,
   "FULL NAME", col 54, "MEDICAL RECORD NUMBER",
   col 85, "ADMISSION DATE", col 109,
   "DISCHARGE DATE", row + 2
  HEAD e_med_service_disp
   col 2, "MEDICAL SERVICE:", row + 1,
   e_med_service_disp1 = substring(1,18,e_med_service_disp), col 13, e_med_service_disp1,
   row + 2
  DETAIL
   IF (((row+ 2) >= maxrow))
    BREAK
   ENDIF
   name_full_formatted1 = substring(1,25,p.name_full_formatted), alias1 = substring(1,15,ea.alias),
   col 29,
   name_full_formatted1, col 57, alias1,
   col 89, e.reg_dt_tm, col 109,
   e.disch_dt_tm, row + 1
  FOOT  e_med_service_disp
   col 5, "MEDICAL SERVICE TOTAL:", tot_patients = count(e.encntr_id),
   col 29, tot_patients, row + 2
  FOOT PAGE
   call reportmove('ROW',(maxrow - 1),0), col 65, "PAGE",
   col 73, curpage"##"
  FOOT REPORT
   col 58, "END OF REPORT"
  WITH maxrec = 100, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
