CREATE PROGRAM bhs_dup_patient_chk:dba
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ms_cmrn = vc WITH protect, noconstant(" ")
 DECLARE ms_mrn = vc WITH protect, noconstant(" ")
 DECLARE ms_cmrn_match = vc WITH protect, noconstant(" ")
 DECLARE mn_exists = i2 WITH protect, noconstant(0)
 DECLARE ms_match_id = vc WITH protect, noconstant(" ")
 DECLARE mf_person_id = f8 WITH protect, noconstant(trigger_personid)
 DECLARE retval = i4 WITH public, noconstant(0)
 DECLARE log_message = vc WITH public, noconstant("")
 SELECT INTO "nl:"
  pa.alias
  FROM person p,
   person_alias pa
  PLAN (p
   WHERE p.person_id=mf_person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  DETAIL
   ms_cmrn = trim(pa.alias),
   CALL echo(build2("detail CMRN: ",ms_cmrn))
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET log_message = "CMRN not found, selecting by person_id"
  CALL echo(log_message)
  SELECT INTO "nl:"
   FROM bhs_person_match b
   PLAN (b
    WHERE ((b.a_person_id=mf_person_id) OR (b.b_person_id=mf_person_id))
     AND b.active_ind=1)
   DETAIL
    ms_match_id = trim(cnvtstring(b.bhs_person_match_id)), mn_exists = 1
    IF (b.a_person_id != mf_person_id)
     ms_mrn = trim(b.a_mrn), ms_cmrn_match = trim(b.a_corporate_nbr)
    ELSE
     ms_mrn = trim(b.b_mrn), ms_cmrn_match = trim(b.b_corporate_nbr)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET log_message = concat("CMRN = ",ms_cmrn)
  CALL echo(log_message)
  SELECT INTO "nl:"
   FROM bhs_person_match b
   PLAN (b
    WHERE ((b.a_corporate_nbr=ms_cmrn) OR (b.b_corporate_nbr=ms_cmrn))
     AND b.active_ind=1)
   DETAIL
    ms_match_id = trim(cnvtstring(b.bhs_person_match_id)), mn_exists = 1
    IF (b.a_person_id != mf_person_id)
     ms_mrn = trim(b.a_mrn), ms_cmrn_match = trim(b.a_corporate_nbr)
    ELSE
     ms_mrn = trim(b.b_mrn), ms_cmrn_match = trim(b.b_corporate_nbr)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("mrn: ",ms_mrn))
 IF (mn_exists=1)
  SET log_message = concat(log_message,"; exists - id = ",ms_match_id)
  SET log_misc1 = concat("This patient has been flagged by HIM for a duplicate medical record.",char(
    13),"The other number is:",char(13),"Medical Record #: ",
   ms_mrn,char(13),"Corporate #: ",ms_cmrn_match,char(13),
   char(13),"If assistance is needed, please PAGE the HIM Merge Team at 3-2419.")
  SET retval = 100
 ELSE
  SET log_message = concat(log_message,"; no match found")
 ENDIF
 CALL echo(log_message)
END GO
