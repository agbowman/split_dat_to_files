CREATE PROGRAM bhs_eks_ped_complex_care:dba
 DECLARE mf_pedi_cmplx_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIATRICCOMPLEXCARENOTIFICATIONFORM"))
 DECLARE mf_pedicomplexcarenotification01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PEDICOMPLEXCARENOTIFICATION1"))
 DECLARE mf_pedicomplexcarenotification02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PEDICOMPLEXCARENOTIFICATION2"))
 DECLARE mf_pedicomplexcarenotification03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PEDICOMPLEXCARENOTIFICATION3"))
 DECLARE mf_pedicomplexcarenotification04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PEDICOMPLEXCARENOTIFICATION4"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE ms_pcc_provider01_email = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider01_name = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider02_email = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider02_name = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider03_email = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider03_name = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider04_email = vc WITH protect, noconstant(" ")
 DECLARE ms_pcc_provider04_name = vc WITH protect, noconstant(" ")
 DECLARE ms_provider_email = vc WITH protect, noconstant(" ")
 DECLARE ms_patient_name = vc WITH protect, noconstant(" ")
 DECLARE ms_birth_dt = vc WITH protect, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_enc_loc = vc WITH protect, noconstant(" ")
 DECLARE ms_enc_reg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_enc_disch_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_enc_disch_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_email_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_body = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ml_dcllen = i4 WITH protect, noconstant(0)
 DECLARE ml_dclstatus = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE mf_pedi_cmplx_care_form_id = f8 WITH protect, noconstant(0.00)
 SET retval = 0
 SET log_message = fillstring(2500," ")
 SET log_message = "CCL script did not find any provider email addresses."
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias fin
  PLAN (e
   WHERE e.encntr_id=trigger_encntrid)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   ms_patient_name = trim(p.name_full_formatted), ms_fin = trim(fin.alias,3), ms_birth_dt = format(p
    .birth_dt_tm,"mm/dd/yyyy;;D"),
   ms_enc_loc = trim(uar_get_code_display(e.loc_facility_cd),3), ms_enc_reg_dt_tm = format(e
    .reg_dt_tm,"mm/dd/yyyy;;D")
   IF (e.disch_dt_tm != null)
    ms_enc_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy;;D")
   ENDIF
   IF (e.disch_disposition_cd > 0.00)
    ms_enc_disch_disp = trim(uar_get_code_display(e.disch_disposition_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.person_id=trigger_personid
    AND ce.event_cd=mf_pedi_cmplx_form_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ce.performed_dt_tm DESC
  HEAD REPORT
   mf_pedi_cmplx_care_form_id = ce.event_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event cef,
   clinical_event ces,
   clinical_event ce,
   encounter e,
   person p,
   dummyt d1,
   prsnl pr
  PLAN (cef
   WHERE cef.event_id=mf_pedi_cmplx_care_form_id)
   JOIN (ces
   WHERE ces.parent_event_id=cef.event_id)
   JOIN (ce
   WHERE ce.parent_event_id=ces.event_id
    AND ce.event_cd IN (mf_pedicomplexcarenotification01_cd, mf_pedicomplexcarenotification02_cd,
   mf_pedicomplexcarenotification03_cd, mf_pedicomplexcarenotification04_cd)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 360),0)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_auth_cd, mf_mod_cd))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pr
   WHERE pr.name_full_formatted=ce.result_val)
  ORDER BY ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD REPORT
   ms_pcc_provider01_name = "Not Entered", ms_pcc_provider02_name = "Not Entered",
   ms_pcc_provider03_name = "Not Entered",
   ms_pcc_provider04_name = "Not Entered"
  HEAD ce.event_cd
   retval = 100
   IF (findstring("@",pr.email) > 0)
    mn_email_ind = 1, ms_provider_email = trim(pr.email,3)
   ELSE
    ms_provider_email = " "
   ENDIF
   CASE (ce.event_cd)
    OF mf_pedicomplexcarenotification01_cd:
     ms_pcc_provider01_name = trim(ce.result_val,3),ms_pcc_provider01_email = ms_provider_email
    OF mf_pedicomplexcarenotification02_cd:
     ms_pcc_provider02_name = trim(ce.result_val,3),ms_pcc_provider02_email = ms_provider_email
    OF mf_pedicomplexcarenotification03_cd:
     ms_pcc_provider03_name = trim(ce.result_val,3),ms_pcc_provider03_email = ms_provider_email
    OF mf_pedicomplexcarenotification04_cd:
     ms_pcc_provider04_name = trim(ce.result_val,3),ms_pcc_provider04_email = ms_provider_email
   ENDCASE
  WITH outerjoin = d1, nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_email_address_list = " "
  IF (ms_pcc_provider01_email != " ")
   SET ms_email_address_list = trim(concat(trim(ms_email_address_list,3)," ",trim(
      ms_pcc_provider01_email,3)),3)
  ELSE
   SET ms_pcc_provider01_email = "No email address found"
  ENDIF
  IF (ms_pcc_provider02_email != " ")
   SET ms_email_address_list = trim(concat(trim(ms_email_address_list,3)," ",trim(
      ms_pcc_provider02_email,3)),3)
  ELSE
   SET ms_pcc_provider02_email = "No email address found"
  ENDIF
  IF (ms_pcc_provider03_email != " ")
   SET ms_email_address_list = trim(concat(trim(ms_email_address_list,3)," ",trim(
      ms_pcc_provider03_email,3)),3)
  ELSE
   SET ms_pcc_provider03_email = "No email address found"
  ENDIF
  IF (ms_pcc_provider04_email != " ")
   SET ms_email_address_list = trim(concat(trim(ms_email_address_list,3)," ",trim(
      ms_pcc_provider04_email,3)),3)
  ELSE
   SET ms_pcc_provider04_email = "No email address found"
  ENDIF
  CALL echo(build2("ms_email_address_list: ",ms_email_address_list))
  SET ms_subject = concat("Pediatric Complex Care Visit Alert - ",format(sysdate,"mm/dd/yyyy;;D"))
  IF (ms_enc_disch_dt_tm > " ")
   SET ms_body = concat(
    "There has been a visit discharged for the following Pediatric Complex Care Patient: ",char(10),
    "     ",ms_patient_name,char(10),
    "     Birth Date: ",ms_birth_dt,char(10),"     Acct#: ",ms_fin,
    char(10),"     Facility: ",ms_enc_loc,char(10),"     Registration Date: ",
    ms_enc_reg_dt_tm,char(10),"     Discharge Date: ",ms_enc_disch_dt_tm,char(10),
    "     Discharge Disposition: ",ms_enc_disch_disp)
  ELSE
   SET ms_body = concat(
    "There has been a new visit registered for the following Pediatric Complex Care Patient: ",char(
     10),"     ",ms_patient_name,char(10),
    "     Birth Date: ",ms_birth_dt,char(10),"     Acct#: ",ms_fin,
    char(10),"     Facility: ",ms_enc_loc,char(10),"     Registration Date: ",
    ms_enc_reg_dt_tm,char(10),"     Discharge Disposition: ",ms_enc_disch_disp)
  ENDIF
  SET ms_dclcom = concat("echo '",ms_body,"'"," | mailx -s '",ms_subject,
   "' ",ms_email_address_list)
  SET ml_dcllen = size(trim(ms_dclcom))
  SET ml_dclstatus = 0
  CALL dcl(ms_dclcom,ml_dcllen,ml_dclstatus)
  CALL echo(build2(ms_dclcom," - ",ml_dclstatus))
  SET log_message = build2("Message sent to the following providers: ","Provider#1: ",
   ms_pcc_provider01_name," (",ms_pcc_provider01_email,
   ") ","Provider#2: ",ms_pcc_provider02_name," (",ms_pcc_provider02_email,
   ") ","Provider#3: ",ms_pcc_provider03_name," (",ms_pcc_provider03_email,
   ") ","Provider#4: ",ms_pcc_provider04_name," (",ms_pcc_provider04_email,
   ")")
 ENDIF
#exit_script
 CALL echo(build2("retval: ",retval))
 CALL echo(build2("log_message: ",log_message))
END GO
