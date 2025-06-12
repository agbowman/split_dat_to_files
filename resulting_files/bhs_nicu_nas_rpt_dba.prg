CREATE PROGRAM bhs_nicu_nas_rpt:dba
 PROMPT
  "Email:" = ""
  WITH ms_email_addr
 EXECUTE bhs_sys_stand_subroutine
 DECLARE ms_nas_rpt_filename = vc WITH protect, constant("bhs_nicu_nas_rpt.csv")
 DECLARE mf_cmrn_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BHSCMRN"))
 DECLARE mf_beg_date = f8 WITH protect, constant(cnvtdatetime(cnvtlookbehind("30,D",cnvtdatetime(
     sysdate))))
 DECLARE mf_end_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE ms_search_date = vc WITH protect, constant(concat(format(cnvtdatetime(mf_beg_date),
    "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime(mf_end_date),"MM/DD/YY HH:MM;;D")))
 DECLARE mf_nccn_cd = f8 WITH protect, noconstant(0)
 DECLARE mf_nicu_cd = f8 WITH protect, noconstant(0)
 DECLARE mf_nnura_cd = f8 WITH protect, noconstant(0)
 DECLARE mf_nnurb_cd = f8 WITH protect, noconstant(0)
 DECLARE mf_nnurc_cd = f8 WITH protect, noconstant(0)
 DECLARE mf_nnurd_cd = f8 WITH protect, noconstant(0)
 DECLARE ms_name_first = vc WITH protect, noconstant("")
 DECLARE ms_name_last = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_disp = vc WITH protect, noconstant("")
 DECLARE ms_dob = vc WITH protect, noconstant("")
 DECLARE ms_gest_age = vc WITH protect, noconstant("")
 DECLARE ms_disch_dt = vc WITH protect, noconstant("")
 DECLARE ms_diag_dt = vc WITH protect, noconstant("")
 DECLARE ms_diagnosis = vc WITH protect, noconstant("")
 DECLARE ms_diag_bill_code = vc WITH protect, noconstant("")
 DECLARE ms_status = vc WITH protect, noconstant("SUCCESS")
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (findstring("@", $MS_EMAIL_ADDR)=0)
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,
   'Invalid email recipients list. Email should contain at least one "@" character.')
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.display_key IN ("NCCN", "NICU", "NNURA", "NNURB", "NNURC",
  "NNURD")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.display_key)
    OF "NCCN":
     mf_nccn_cd = cv.code_value
    OF "NICU":
     mf_nicu_cd = cv.code_value
    OF "NNURA":
     mf_nnura_cd = cv.code_value
    OF "NNURB":
     mf_nnurb_cd = cv.code_value
    OF "NNURC":
     mf_nnurc_cd = cv.code_value
    OF "NNURD":
     mf_nnurd_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO value(ms_nas_rpt_filename)
  FROM nomenclature n,
   diagnosis d,
   encounter e,
   encntr_loc_hist elh,
   person p,
   person_alias pa,
   person_patient pp
  PLAN (n
   WHERE n.source_identifier IN ("P96.1", "P04.49", "P22.1"))
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND ((d.diag_dt_tm BETWEEN cnvtdatetime(mf_beg_date) AND cnvtdatetime(mf_end_date)) OR (d
   .diag_dt_tm = null)) )
   JOIN (e
   WHERE e.encntr_id=d.encntr_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.loc_nurse_unit_cd IN (mf_nccn_cd, mf_nicu_cd, mf_nnura_cd, mf_nnurb_cd, mf_nnurc_cd,
   mf_nnurd_cd))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND ((p.birth_dt_tm BETWEEN cnvtdatetime(mf_beg_date) AND cnvtdatetime(mf_end_date)) OR (p
   .birth_dt_tm = null)) )
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_type_cd
    AND pa.alias_pool_cd=mf_cmrn_cd)
   JOIN (pp
   WHERE pp.person_id=p.person_id)
  ORDER BY pa.alias
  HEAD REPORT
   col 0, "BHS: Neonatal Abstinence Syndrome Report", row + 1,
   col 0, ms_search_date, row + 2,
   col 0,
   "NAME_FIRST,NAME_LAST,MRN,NURSE_UNIT,DOB,GESTATIONAL_AGE,DISCHARGE_DATE,DIAGNOSIS_DATE,DIAGNOSIS,DIAGNOSIS_CD",
   row + 1
  HEAD pa.alias
   ms_name_first = trim(p.name_first,3), ms_name_last = trim(p.name_last,3), ms_diagnosis = trim(d
    .diagnosis_display,3),
   ms_diag_bill_code = trim(n.source_identifier,3), ms_nurse_unit_disp = uar_get_code_display(elh
    .loc_nurse_unit_cd), ms_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
    "YYYY/MM/DD HH:MM:SS;;D"),
   ms_gest_age = build((pp.gest_age_at_birth/ 7)," Weeks/",mod(pp.gest_age_at_birth,7)," Days Old"),
   ms_disch_dt = format(e.disch_dt_tm,"YYYY/MM/DD HH:MM:SS;;D"), ms_diag_dt = format(d.diag_dt_tm,
    "YYYY/MM/DD HH:MM:SS;;D"),
   col 0, '"', ms_name_first,
   '","', ms_name_last, '",',
   pa.alias, ',"', ms_nurse_unit_disp,
   '",', ms_dob, ",",
   ms_gest_age, ",", ms_disch_dt,
   ",", ms_diag_dt, ',"',
   ms_diagnosis, '","', ms_diag_bill_code,
   '"', row + 1
  WITH nocounter, maxrow = 1, format = variable,
   formfeed = none, maxcol = 3000
 ;end select
 IF (curqual=0)
  SET ms_error = "No rows qualified"
  GO TO exit_script
 ENDIF
 IF (error(ms_error,0) > 0)
  SET ms_status = "FAIL"
  GO TO exit_script
 ENDIF
 CALL emailfile(ms_nas_rpt_filename,ms_nas_rpt_filename, $MS_EMAIL_ADDR,
  "NICU Neonatal Abstinence Syndrome Report - Last 30 Days",1)
 SET ms_error = concat(ms_error,"File has been emailed to: ", $MS_EMAIL_ADDR)
#exit_script
 CALL echo("********************")
 CALL echo(ms_status)
 CALL echo(ms_error)
 CALL echo("********************")
END GO
