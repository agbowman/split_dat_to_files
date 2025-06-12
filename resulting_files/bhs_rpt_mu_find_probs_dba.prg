CREATE PROGRAM bhs_rpt_mu_find_probs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facilty" = "",
  "Select for Detail Audit (Default is Summary)" = 0,
  "Check to FTP Files" = 0,
  "Email Reminder" = 0
  WITH outdev, opsfacilty, select_output,
  ftpfiles, emailreminder
 EXECUTE bhs_check_domain
 RECORD problem_status(
   1 ml_total_patients = i4
   1 ml_total_problems = i4
   1 ml_total_snomeds = i4
   1 unit[*]
     2 ms_facility = vc
     2 ms_unit = vc
     2 mf_unitcd = f8
     2 ml_patcnt = i4
     2 ml_probcnt = i4
     2 ml_snocnt = i4
     2 patients[*]
       3 ms_account = vc
       3 ms_patient_name = vc
       3 mf_encounter_id = f8
       3 ms_problems_status = vc
       3 ms_snmedfound = vc
       3 ms_freetextfound = vc
       3 mf_person_id = f8
 )
 DECLARE ms_prefix = vc WITH constant("_prob_"), protect
 DECLARE ml_cntpat = i4 WITH noconstant(0), protect
 DECLARE ml_opsjob = i4 WITH noconstant(0), protect
 DECLARE ml_cntunit = i4 WITH noconstant(0), protect
 DECLARE mf_freetext = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12033,"FREETEXT")), protect
 DECLARE mf_resolved = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12030,"RESOLVED")), protect
 DECLARE mf_inactive = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12030,"INACTIVE")), protect
 DECLARE mf_canceled = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12030,"CANCELED")), protect
 DECLARE ml_unit_cnt = i4 WITH protect
 DECLARE ml_pat_cnt = i4 WITH protect
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")), protect
 DECLARE mf_facility_cd = f8 WITH noconstant(0), protect
 DECLARE mf_snomedct = f8 WITH constant(uar_get_code_by("DISPLAYKEY",400,"SNOMEDCT")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE ms_year = vc WITH protect
 DECLARE ml_day = i4 WITH protect
 DECLARE ms_name_fac = vc WITH protect
 DECLARE ml_month = i4 WITH protect
 DECLARE ms_time = vc WITH protect
 DECLARE ms_file_name = vc WITH protect
 DECLARE ms_delimiter1 = vc WITH protect
 DECLARE ms_delimiter2 = vc WITH protect
 DECLARE ms_facil = vc WITH protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_msg = vc WITH protect
 DECLARE ms_msgsubject = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
 SET ms_day = day(curdate)
 SET ms_month = month(curdate)
 SET ms_time = format(curtime,"HHMM;;M")
 IF (validate(request->batch_selection))
  SET ml_opsjob = 1
 ENDIF
 SELECT INTO "nl:"
  cv.display_key, cv.code_value
  FROM code_value cv
  WHERE (cv.description= $OPSFACILTY)
   AND cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_type_cd=mf_active
  DETAIL
   mf_facility_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ms_facil = replace(trim(uar_get_code_display(mf_facility_cd))," ","_",0)
 CALL echo(build("ms_facil = ",ms_facil))
 IF (( $SELECT_OUTPUT=1))
  SET ms_file_name = build(cnvtlower(ms_facil),"det",ms_prefix,cnvtlower(curdomain),ms_month,
   ms_day,ms_time,ms_year)
 ELSE
  SET ms_file_name = build(cnvtlower(ms_facil),"sum",ms_prefix,cnvtlower(curdomain),ms_month,
   ms_day,ms_time,ms_year)
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea,
   person p
  PLAN (ed
   WHERE ed.loc_facility_cd=mf_facility_cd
    AND ed.loc_nurse_unit_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="NURSEUNIT"
     AND cv.active_type_cd IN (mf_active)))
    AND ed.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_observation, mf_daystay, mf_inpatient)
    AND e.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND e.active_status_cd=mf_active)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_finnbr
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY ed.loc_nurse_unit_cd, e.person_id
  HEAD REPORT
   ml_unit_cnt = 0, stat = alterlist(problem_status->unit,10)
  HEAD ed.loc_nurse_unit_cd
   ml_unit_cnt += 1
   IF (mod(ml_unit_cnt,10)=1
    AND ml_unit_cnt > 1)
    stat = alterlist(problem_status->unit,(ml_unit_cnt+ 9))
   ENDIF
   problem_status->unit[ml_unit_cnt].ms_facility = uar_get_code_display(ed.loc_facility_cd),
   problem_status->unit[ml_unit_cnt].ms_unit = uar_get_code_display(ed.loc_nurse_unit_cd),
   problem_status->unit[ml_unit_cnt].mf_unitcd = ed.loc_nurse_unit_cd,
   ml_pat_cnt = 0, stat = alterlist(problem_status->unit[ml_unit_cnt].patients,10)
  HEAD e.person_id
   ml_pat_cnt += 1
   IF (mod(ml_pat_cnt,10)=1
    AND ml_pat_cnt > 1)
    stat = alterlist(problem_status->unit[ml_unit_cnt].patients,(ml_pat_cnt+ 9))
   ENDIF
   problem_status->unit[ml_unit_cnt].patients[ml_pat_cnt].mf_person_id = e.person_id, problem_status
   ->unit[ml_unit_cnt].patients[ml_pat_cnt].ms_problems_status = "no problems found", problem_status
   ->unit[ml_unit_cnt].patients[ml_pat_cnt].ms_snmedfound = "no SNOMED problems found",
   problem_status->unit[ml_unit_cnt].patients[ml_pat_cnt].mf_encounter_id = ed.encntr_id,
   problem_status->unit[ml_unit_cnt].patients[ml_pat_cnt].ms_patient_name = e.name_full_formatted,
   problem_status->unit[ml_unit_cnt].patients[ml_pat_cnt].ms_account = ea.alias,
   problem_status->unit[ml_unit_cnt].patients[ml_pat_cnt].ms_patient_name = p.name_full_formatted,
   problem_status->ml_total_patients += 1, problem_status->unit[ml_unit_cnt].ml_patcnt += 1
  FOOT  ed.loc_nurse_unit_cd
   stat = alterlist(problem_status->unit[ml_unit_cnt].patients,ml_pat_cnt), problem_status->unit[
   ml_unit_cnt].ml_patcnt = ml_pat_cnt, ml_pat_cnt = 0
  FOOT REPORT
   ed.loc_nurse_unit_cd, stat = alterlist(problem_status->unit,ml_unit_cnt), ml_unit_cnt = 0
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(size(problem_status->unit,5))),
   (dummyt d2  WITH seq = 1),
   problem p
  PLAN (d1
   WHERE maxrec(d2,size(problem_status->unit[d1.seq].patients,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.person_id=problem_status->unit[d1.seq].patients[d2.seq].mf_person_id)
    AND p.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
    AND  NOT (p.life_cycle_status_cd IN (mf_canceled, mf_resolved, mf_inactive)))
  ORDER BY d1.seq, d2.seq, p.person_id
  HEAD d1.seq
   null
  HEAD d2.seq
   null
  HEAD p.person_id
   problem_status->unit[d1.seq].patients[d2.seq].ms_problems_status = "problem found"
   IF (p.classification_cd=mf_freetext)
    problem_status->unit[d1.seq].patients[d2.seq].ms_freetextfound = "Yes"
   ENDIF
   IF ((problem_status->unit[d1.seq].patients[d2.seq].ms_problems_status="problem found"))
    problem_status->ml_total_problems += 1
   ENDIF
   IF ((problem_status->unit[d1.seq].patients[d2.seq].ms_problems_status="problem found"))
    problem_status->unit[d1.seq].ml_probcnt += 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(size(problem_status->unit,5))),
   (dummyt d2  WITH seq = 1),
   problem p,
   nomenclature n
  PLAN (d1
   WHERE maxrec(d2,size(problem_status->unit[d1.seq].patients,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.person_id=problem_status->unit[d1.seq].patients[d2.seq].mf_person_id)
    AND p.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
    AND  NOT (p.life_cycle_status_cd IN (mf_canceled, mf_resolved, mf_inactive)))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.source_vocabulary_cd=mf_snomedct)
  ORDER BY d1.seq, d2.seq
  HEAD d1.seq
   null
  HEAD d2.seq
   problem_status->unit[d1.seq].patients[d2.seq].ms_snmedfound = "SNOMED found", problem_status->
   ml_total_snomeds += 1, problem_status->unit[d1.seq].ml_snocnt += 1
  FOOT  d1.seq
   null
  WITH nocounter
 ;end select
 SET ms_delimiter1 = " "
 SET ms_delimiter2 = " "
 IF (( $FTPFILES=1))
  SET ms_file_name = concat(ms_file_name,".xls")
  SET ms_delimiter1 = '"'
  SET ms_delimiter2 = "	"
 ELSE
  SET ms_file_name =  $OUTDEV
 ENDIF
 IF (( $SELECT_OUTPUT=1))
  SELECT INTO value(ms_file_name)
   unit_name = substring(1,30,problem_status->unit[d1.seq].ms_unit), account_number = substring(1,30,
    problem_status->unit[d1.seq].patients[d2.seq].ms_account), patient_name = substring(1,30,
    problem_status->unit[d1.seq].patients[d2.seq].ms_patient_name),
   patient_problems_status = substring(1,30,problem_status->unit[d1.seq].patients[d2.seq].
    ms_problems_status), patient_snomedfound = substring(1,30,problem_status->unit[d1.seq].patients[
    d2.seq].ms_snmedfound), number_patients_unit = problem_status->unit[d1.seq].ml_patcnt,
   problem_complete_unit = problem_status->unit[d1.seq].ml_probcnt, snomed_complete_unit =
   problem_status->unit[d1.seq].ml_snocnt, problem_status_ml_total_problems = problem_status->
   ml_total_problems,
   problem_status_ml_total_snomeds = problem_status->ml_total_snomeds, patients_total =
   problem_status->ml_total_patients
   FROM (dummyt d1  WITH seq = value(size(problem_status->unit,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(problem_status->unit[d1.seq].patients,5)))
    JOIN (d2)
   WITH nocounter, format, pcformat(value(ms_delimiter1),value(ms_delimiter2))
  ;end select
  IF (curqual=0
   AND ( $FTPFILES=1))
   SET ms_file_name = replace(ms_file_name,".xls",".pdf",0)
   SELECT INTO value(ms_file_name)
    FROM dummyt
    HEAD REPORT
     msg1 = concat("No data selected for details report"), col 0, "{PS/792 0}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = pdf
   ;end select
  ENDIF
 ELSE
  IF (( $FTPFILES=0))
   SET ms_file_name =  $OUTDEV
  ENDIF
  SELECT INTO value(ms_file_name)
   facility = substring(1,30,problem_status->unit[d1.seq].ms_facility), unit = substring(1,30,
    problem_status->unit[d1.seq].ms_unit), patient_count = problem_status->unit[d1.seq].ml_patcnt,
   problem_count = problem_status->unit[d1.seq].ml_probcnt, snomed_count = problem_status->unit[d1
   .seq].ml_snocnt
   FROM (dummyt d1  WITH seq = value(size(problem_status->unit,5)))
   PLAN (d1)
   WITH nocounter, format, pcformat(value(ms_delimiter1),value(ms_delimiter2))
  ;end select
  SELECT INTO value(ms_file_name)
   facility = substring(1,30,"Problem Status"), unit = substring(1,30,"Totals"), patient_count =
   problem_status->ml_total_patients,
   problem_count = problem_status->ml_total_problems, snomed_count = problem_status->ml_total_snomeds
   WITH nocounter, noheading, format,
    pcformat(value(ms_delimiter1),value(ms_delimiter2)), append
  ;end select
  IF (size(problem_status->unit,5)=0
   AND ( $FTPFILES=1))
   SELECT INTO value(ms_file_name)
    FROM dummyt
    HEAD REPORT
     msg1 = concat("Not data selected for Summary report"), col 0, "{PS/792 0}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = pdf
   ;end select
  ENDIF
 ENDIF
 IF (( $FTPFILES=1))
  CALL echo(build("ms_file_name =",ms_file_name))
  IF (((cnvtupper(trim(curdomain,3))="READ") OR (gl_bhs_prod_flag=1)) )
   CALL echo(build("domain = ",trim(curdomain,3)))
   SET status = 0
   SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_file_name,
    " transfer.baystatehealth.org CernerFTP gJeZD64 ","'",'"',
    "ciscore\CIS Meaningful Use\Problems Audit",'"',"'")
   CALL echo(build("status = ",status))
  ELSE
   CALL echo(build("domain = ",trim(curdomain,3)))
   SET dclcom = concat("$bhscust/bhs_ftp_file.ksh ",ms_file_name,
    " transfer.baystatehealth.org CernerFTP gJeZD64 ","'",'"',
    "ciscore\CIS Meaningful Use\Problems Audit",'"',"'")
  ENDIF
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  CALL echo(build("status = ",status))
  CALL echo(build("ms_file_name =",ms_file_name))
  IF (((cnvtupper(trim(curdomain,3))="READ") OR (gl_bhs_prod_flag=1)) )
   CALL echo(build("domain = ",trim(curdomain,3)))
   SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_file_name,
    " transfer.baystatehealth.org CernerFTP gJeZD64 ","'",'"',
    "ciscore\CIS Meaningful Use\Problems Audit",'"',"'")
  ELSE
   CALL echo(build("domain = ",trim(curdomain,3)))
   SET dclcom = concat("$bhscust/bhs_ftp_file.ksh ",ms_file_name,
    " transfer.baystatehealth.org CernerFTP gJeZD64 ","'",'"',
    "ciscore\CIS Meaningful Use\Problems Audit",'"',"'")
  ENDIF
  SET status = 0
  CALL echo(dclcom)
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  CALL echo(build("status = ",status))
  SET stat = remove(ms_file_name)
  IF (( $EMAILREMINDER=1))
   CALL echo(build("emailreminder =", $EMAILREMINDER))
   SET ml_msgpriority = 5
   SET ms_sendto = "CISCore@bhs.org"
   SET ms_msgsubject = concat("Reminder:Problem Meaningful use Audit from ",curdomain)
   SET ms_msg = concat(
    "Go to directory '\\Bhsdata01\data$\CISCORE_FTP\CIS Meaningful Use\Problems Audit'")
   SET ms_msgcls = "IPM.NOTE"
   SET ms_sender = "cis_problems@bhs.org"
   CALL uar_send_mail(nullterm(ms_sendto),nullterm(ms_msgsubject),nullterm(ms_msg),nullterm(ms_sender
     ),ml_msgpriority,
    nullterm(ms_msgcls))
  ENDIF
  IF (ml_opsjob=0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = concat("Files have been send  to share "), col 0, "{PS/792 0}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
END GO
