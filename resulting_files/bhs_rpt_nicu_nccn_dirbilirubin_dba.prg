CREATE PROGRAM bhs_rpt_nicu_nccn_dirbilirubin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "select result" = 0,
  "Select Operator" = "",
  "Enter Numeric Value Only to Qualify" = ""
  WITH outdev, s_start_date, s_end_date,
  f_result, s_operator, s_value
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 SELECT DISTINCT INTO  $OUTDEV
  mrn = ea.alias, patient_name = substring(1,60,p.name_full_formatted), dob = datebirthformat(p
   .birth_dt_tm,p.birth_tz,p.birth_prec_flag,"mm/dd/yyyy"),
  result = uar_get_code_display(ce.event_cd), value = ce.result_val
  FROM encntr_alias ea,
   encounter e,
   clinical_event ce,
   code_value cv,
   person p,
   dummyt d1
  PLAN (ea
   WHERE ea.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND e.active_ind=1)
   JOIN (cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display IN ("NCCN", "NICU")
    AND cv.code_value=e.loc_nurse_unit_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.active_status_cd=188)
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.encntr_id=e.encntr_id
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND (ce.event_cd= $F_RESULT)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE))
   JOIN (d1
   WHERE operator(cnvtreal(ce.result_val), $S_OPERATOR,cnvtreal( $S_VALUE)))
  ORDER BY ea.alias
  WITH nocounter, format, separator = " "
 ;end select
END GO
