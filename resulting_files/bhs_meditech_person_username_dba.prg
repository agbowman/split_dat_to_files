CREATE PROGRAM bhs_meditech_person_username:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "PersonID" = 0,
  "UserID" = 0
  WITH outdev, mf_patient_person_id, mf_user_person_id
 FREE RECORD medi
 RECORD medi(
   1 ms_medi_username = vc
   1 ms_medi_noble_username = vc
   1 ms_medi_patient_mrn = vc
   1 ms_medi_noble_patient_mrn = vc
   1 ms_medi_domain = vc
   1 ms_medi_mis_name = vc
   1 ms_medi_pos_cd = f8
 ) WITH protect
 DECLARE mf_externalid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"EXTERNALID"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_bwhmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BWHMRN"))
 DECLARE mf_nb_med_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,
   "NOBLEMEDITECHMRN"))
 EXECUTE bhs_check_domain
 SELECT INTO "nl:"
  FROM bhs_application_user a
  WHERE (a.person_id= $MF_USER_PERSON_ID)
   AND a.active_ind=1
   AND cnvtupper(a.application) IN ("MEDITECH", "MEDITECH_NOBLE")
  DETAIL
   IF (cnvtupper(a.application)="MEDITECH")
    medi->ms_medi_username = a.application_username
   ELSEIF (cnvtupper(a.application)="MEDITECH_NOBLE")
    medi->ms_medi_noble_username = a.application_username
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE (pa.person_id= $MF_PATIENT_PERSON_ID)
   AND pa.person_alias_type_cd=mf_mrn_cd
   AND pa.alias_pool_cd IN (mf_bwhmrn_cd, mf_nb_med_mrn_cd)
   AND pa.active_ind=1
  ORDER BY pa.updt_dt_tm
  DETAIL
   IF (pa.alias_pool_cd=mf_bwhmrn_cd)
    medi->ms_medi_patient_mrn = trim(pa.alias,3)
   ELSEIF (pa.alias_pool_cd=mf_nb_med_mrn_cd)
    medi->ms_medi_noble_patient_mrn = trim(pa.alias,3)
   ENDIF
  WITH nocounter
 ;end select
 SET medi->ms_medi_domain = "LIVE"
 SET medi->ms_medi_mis_name = "WMH"
 SET _memory_reply_string = cnvtrectojson(medi)
 CALL echo(_memory_reply_string)
END GO
