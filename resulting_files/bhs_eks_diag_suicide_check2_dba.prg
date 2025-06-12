CREATE PROGRAM bhs_eks_diag_suicide_check2:dba
 DECLARE mf_encntr_id = f8 WITH protect, constant(trigger_encntrid)
 DECLARE mf_src_vocab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD10CM"))
 DECLARE ml_fail_ind = i2 WITH protect, noconstant(0)
 DECLARE mf_diag_id1 = f8 WITH protect, constant(cnvtreal(eksdata->tqual[3].qual[5].data[2].misc))
 SET retval = 100
 IF (mf_diag_id1 > 0)
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE d.diagnosis_id=mf_diag_id1
     AND  NOT (d.diagnosis_display IN ("Alteration in meaningfulness as evidenced by helplessness",
    "Alteration in meaningfulness as evidenced by hopelessness",
    "At high risk for violence against self", "At risk for self harm", "At risk for self-harm",
    "At risk for suicide")))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id
     AND n.source_vocabulary_cd=mf_src_vocab_cd
     AND n.source_identifier="R45.89")
   DETAIL
    ml_fail_ind = 1, log_misc1 = concat("Diagnosis does not qualify for suicide screening: ",trim(n
      .source_string,3))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE d.diagnosis_id=mf_diag_id1
     AND  NOT (d.diagnosis_display IN ("Observation following alleged suicide attempt",
    "H/O suicide attempt", "H/O: attempted suicide", "H/O: suicide attempt",
    "History of attempted suicide",
    "History of suicide attempt", "Hx of suicide attempt", "Previous known suicide attempt",
    "At high risk for suicide")))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id
     AND n.source_vocabulary_cd=mf_src_vocab_cd
     AND n.source_identifier="Z*")
   DETAIL
    ml_fail_ind = 1, log_misc1 = concat("Diagnosis does not qualify for suicide screening: ",trim(n
      .source_string,3))
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (ml_fail_ind=1)
  SET retval = 0
 ENDIF
END GO
