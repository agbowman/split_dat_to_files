CREATE PROGRAM bhs_rpt_brade_score_18:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse Unit" = 0
  WITH outdev, s_start_dt, s_stop_dt,
  f_fac_cd, f_nurse_unit_cd
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs72_bradenscore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BRADENSCORE"))
 DECLARE mf_cs72_bradenqscorepediatrics_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"BRADENQSCOREPEDIATRICS"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE ms_nunit_parser = vc WITH protect, noconstant(" 1 = 1 ")
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_nurse_unit = vc
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_age = vc
     2 s_dob = vc
     2 s_score_type = vc
     2 s_score = vc
     2 s_score_dt = vc
     2 s_admit_dt = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM nurse_unit n
  PLAN (n
   WHERE (n.location_cd= $F_NURSE_UNIT_CD)
    AND n.location_cd > 0)
  ORDER BY n.location_cd
  HEAD REPORT
   ms_nunit_parser = concat(" e.loc_nurse_unit_cd in (",trim(cnvtstring(n.location_cd,20,2),3))
  DETAIL
   ms_nunit_parser = concat(ms_nunit_parser,", ",trim(cnvtstring(n.location_cd,20,2),3))
  FOOT REPORT
   ms_nunit_parser = concat(ms_nunit_parser,") ")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND ce.event_cd IN (mf_cs72_bradenscore_cd, mf_cs72_bradenqscorepediatrics_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND (e.loc_facility_cd= $F_FAC_CD)
    AND parser(ms_nunit_parser))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY ce.person_id, ce.performed_dt_tm DESC
  HEAD ce.person_id
   IF (isnumeric(trim(ce.result_val,3))=1)
    IF (cnvtreal(trim(ce.result_val,3)) <= 18)
     m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
     f_encntr_id = e.encntr_id,
     m_rec->qual[m_rec->l_cnt].f_person_id = p.person_id, m_rec->qual[m_rec->l_cnt].s_nurse_unit =
     trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->qual[m_rec->l_cnt].s_patient_name =
     trim(p.name_full_formatted,3),
     m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_age = cnvtage(p
      .birth_dt_tm), m_rec->qual[m_rec->l_cnt].s_dob = trim(format(p.birth_dt_tm,";;d"),3),
     m_rec->qual[m_rec->l_cnt].s_score_type = trim(uar_get_code_display(ce.event_cd),3), m_rec->qual[
     m_rec->l_cnt].s_score = trim(ce.result_val,3), m_rec->qual[m_rec->l_cnt].s_score_dt = format(ce
      .performed_dt_tm,"MM/DD/YY HH:MM;;d"),
     m_rec->qual[m_rec->l_cnt].s_admit_dt = format(e.reg_dt_tm,"MM/DD/YY HH:MM;;d")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   nurse_unit = trim(substring(1,100,m_rec->qual[d.seq].s_nurse_unit),3), patient_name = trim(
    substring(1,100,m_rec->qual[d.seq].s_patient_name),3), mrn = trim(substring(1,100,m_rec->qual[d
     .seq].s_mrn),3),
   age = trim(substring(1,100,m_rec->qual[d.seq].s_age),3), dob = trim(substring(1,100,m_rec->qual[d
     .seq].s_dob),3), score_type = trim(substring(1,100,m_rec->qual[d.seq].s_score_type),3),
   score = trim(substring(1,100,m_rec->qual[d.seq].s_score),3), date = trim(substring(1,100,m_rec->
     qual[d.seq].s_score_dt),3), admit_date = trim(substring(1,100,m_rec->qual[d.seq].s_admit_dt),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   ORDER BY nurse_unit, patient_name
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", row 0, col 0,
    CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
    col 0,
    CALL print("Report completed. No qualifying data found."), row + 1,
    row 6, col 0,
    CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
      "mm/dd/yyyy hh:mm:ss;;q")))
   WITH nocounter, nullreport, maxcol = 300,
    dio = 08
  ;end select
 ENDIF
#exit_script
END GO
