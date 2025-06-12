CREATE PROGRAM bhs_rpt_admit_heart_failure:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Emails" = ""
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date, s_emails
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs400_icd10cm = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946")),
 protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE md_start_date = dq8 WITH noconstant(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0)),
 protect
 DECLARE md_end_date = dq8 WITH noconstant(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)),
 protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 FREE RECORD grec2
 RECORD grec2(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 FREE RECORD frec
 IF (validate(request->batch_selection))
  SET ml_ops_ind = 1
  SET md_start_date = cnvtdatetime((curdate - 1),curtime3)
  SET md_end_date = sysdate
 ENDIF
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec2->list,(ml_gcnt+ 4))
     ENDIF
     SET grec2->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_UNIT),ml_gcnt))
     SET grec2->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_UNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec2->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec2->list,1)
  SET ml_gcnt = 1
  SET grec2->list[1].f_cv =  $F_UNIT
  IF ((grec2->list[1].f_cv=0.0))
   SET grec2->list[1].s_disp = "All Units"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec2->list[1].s_disp = uar_get_code_display(grec2->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  facility = substring(1,30,uar_get_code_display(e.loc_facility_cd)), unit = substring(1,30,
   uar_get_code_display(e.loc_nurse_unit_cd)), patient_name = substring(1,100,p.name_full_formatted),
  dob = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,"@SHORTDATE4YR"), gender =
  substring(1,20,uar_get_code_display(p.sex_cd)), mrn = substring(1,30,mrn.alias),
  fin = substring(1,30,fin.alias)
  FROM nomenclature n,
   diagnosis dx,
   encounter e,
   encntr_alias mrn,
   encntr_alias fin,
   encounter e,
   person p
  PLAN (n
   WHERE n.source_vocabulary_cd=mf_cs400_icd10cm
    AND n.source_identifier_keycap="I50.9")
   JOIN (dx
   WHERE dx.nomenclature_id=n.nomenclature_id
    AND dx.active_ind=1
    AND dx.active_status_cd=mf_cs48_active)
   JOIN (e
   WHERE e.encntr_id=dx.encntr_id
    AND (e.loc_facility_cd= $F_FNAME)
    AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(md_start_date) AND cnvtdatetime(md_end_date))
   JOIN (mrn
   WHERE mrn.encntr_id=dx.encntr_id
    AND mrn.active_ind=1
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND sysdate BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm)
   JOIN (fin
   WHERE fin.encntr_id=dx.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_status_cd=mf_cs48_active
    AND p.active_ind=1)
  ORDER BY facility, unit, patient_name
  WITH nocounter, format, separator = " "
 ;end select
END GO
