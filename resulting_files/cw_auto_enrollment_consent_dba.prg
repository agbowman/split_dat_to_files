CREATE PROGRAM cw_auto_enrollment_consent:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person_Id:" = 0.00,
  "Encounter_Id:" = 0.00
  WITH outdev, person_id, encntr_id
 IF ( NOT (validate(commonwell_consent,0)))
  FREE RECORD commonwell_consent
  RECORD commonwell_consent(
    1 consent_status = i2
  ) WITH persistscript
 ENDIF
 DECLARE udf_consent_no = f8 WITH protected, constant(uar_get_code_by("DISPLAYKEY",29465,"DONOTSHARE"
   ))
 DECLARE consent_info_sub_type_cd = f8 WITH protected, constant(uar_get_code_by("DISPLAYKEY",356,
   "CONSENTFORINFORMATIONEXCHANGE"))
 SET commonwell_consent->consent_status = 0
 IF (udf_consent_no > 0
  AND consent_info_sub_type_cd > 0)
  SELECT INTO "nl:"
   p.person_id
   FROM person p,
    person_info pi
   PLAN (p
    WHERE (p.person_id= $PERSON_ID))
    JOIN (pi
    WHERE (pi.person_id= Outerjoin(p.person_id))
     AND ((pi.active_ind+ 0)= Outerjoin(1))
     AND (pi.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate)))
     AND (pi.info_sub_type_cd= Outerjoin(consent_info_sub_type_cd)) )
   DETAIL
    IF (pi.value_cd != udf_consent_no)
     commonwell_consent->consent_status = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET commonwell_consent->consent_status = 0
 ENDIF
END GO
