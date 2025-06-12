CREATE PROGRAM bhs_pat_demog:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Person ID:" = ""
  WITH outdev, mf_person_id
 FREE RECORD pinfo
 RECORD pinfo(
   1 ms_name = vc
   1 ms_address_lone = vc
   1 ms_address_ltwo = vc
   1 ms_city = vc
   1 ms_state = vc
   1 ms_zip = vc
   1 ms_cmrn = vc
   1 ms_language_read = vc
   1 ms_language_spoken = vc
   1 ms_gender = vc
   1 ms_birth_sex = vc
   1 ms_phone_home = vc
   1 ms_phone_cell = vc
   1 ms_phone_bus = vc
   1 ms_email_home = vc
   1 ms_dob = vc
   1 ms_pid = vc
   1 ms_deceased = vc
   1 ms_race1 = vc
   1 ms_race2 = vc
   1 ms_race3 = vc
   1 ms_race4 = vc
   1 ms_race5 = vc
   1 ms_ethnicity1 = vc
   1 ms_ethnicity2 = vc
   1 ms_hispanic_ind = vc
   1 ms_religion = vc
   1 ms_head_of_household = vc
   1 ms_marital_status = vc
   1 ms_advanced_directive = vc
   1 s_aux_aid_svc1 = vc
   1 s_aux_aid_svc2 = vc
   1 s_aux_aid_svc3 = vc
   1 s_aux_aid_svc4 = vc
   1 s_aux_aid_svc5 = vc
   1 s_aux_aid_svc6 = vc
   1 s_aux_aid_svc7 = vc
   1 s_aux_aid_svc8 = vc
   1 s_aux_aid_svc9 = vc
   1 s_aux_aid_svc10 = vc
   1 s_lang_proficiency = vc
 ) WITH protect
 DECLARE mf_user_def_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,"USERDEFINED"))
 DECLARE mf_race1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_race2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_race3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_race4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_race5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs356_auxaid1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES1"))
 DECLARE mf_cs356_auxaid2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES2"))
 DECLARE mf_cs356_auxaid3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES3"))
 DECLARE mf_cs356_auxaid4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES4"))
 DECLARE mf_cs356_auxaid5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES5"))
 DECLARE mf_cs356_auxaid6 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES6"))
 DECLARE mf_cs356_auxaid7 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES7"))
 DECLARE mf_cs356_auxaid8 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES8"))
 DECLARE mf_cs356_auxaid9 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES9"))
 DECLARE mf_cs356_auxaid10 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "AUXILIARYAIDSANDSERVICES10"))
 DECLARE mf_cs356_lang_prof = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEPROFICIENCY"))
 DECLARE mf_cs356_lang_read = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEREAD"))
 DECLARE mf_advdir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVE")
  )
 DECLARE mf_yes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14769,"YES"))
 DECLARE mf_yesof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14769,"YESONFILE"))
 DECLARE mf_yesnof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14769,"YESNOTONFILE"))
 DECLARE mf_inerror1_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror2_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerror3_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE mf_inerror4_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_unauth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE mf_notdone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_cancelled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_inlab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE mf_rejected_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE mf_unknown_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE mf_placeholder_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_phone_bus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_cs43_mobile = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs23056_email = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3877602"))
 DECLARE mf_cs23056_phone = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3877599"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mi_advdir_ind = i2 WITH protect, noconstant(0)
 DECLARE mf_p_id = f8 WITH protect, noconstant(0.0)
 SET mf_p_id = cnvtreal( $MF_PERSON_ID)
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=mf_p_id
  DETAIL
   pinfo->ms_marital_status = uar_get_code_display(p.marital_type_cd), pinfo->ms_pid = cnvtstring(p
    .person_id,20,2), pinfo->ms_deceased = uar_get_code_display(p.deceased_cd),
   pinfo->ms_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YY"),
   pinfo->ms_name = trim(p.name_full_formatted,3), pinfo->ms_gender = uar_get_code_display(p.sex_cd)
   IF (p.language_cd=0.0)
    pinfo->ms_language_spoken = "unknown"
   ELSE
    pinfo->ms_language_spoken = trim(uar_get_code_display(p.language_cd),3)
   ENDIF
   IF (trim(uar_get_code_display(p.ethnic_grp_cd),3) IN ("Yes", "No", "Unavailable/Unknown",
   "Declined", "Unable to Collect",
   "Don't Know", "Choose Not to Answer", "Unknown", "Hispanic", "Not Hispanic"))
    IF (trim(uar_get_code_display(p.ethnic_grp_cd),3)="Yes")
     pinfo->ms_hispanic_ind = "Hispanic"
    ELSEIF (trim(uar_get_code_display(p.ethnic_grp_cd),3)="No")
     pinfo->ms_hispanic_ind = "Not Hispanic"
    ELSE
     pinfo->ms_hispanic_ind = trim(uar_get_code_display(p.ethnic_grp_cd),3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_info pi
  PLAN (pi
   WHERE pi.person_id=mf_p_id
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_user_def_cd
    AND pi.info_sub_type_cd IN (mf_race1_cd, mf_race2_cd, mf_race3_cd, mf_race4_cd, mf_race5_cd,
   mf_cs356_auxaid1, mf_cs356_auxaid2, mf_cs356_auxaid3, mf_cs356_auxaid4, mf_cs356_auxaid5,
   mf_cs356_auxaid6, mf_cs356_auxaid7, mf_cs356_auxaid8, mf_cs356_auxaid9, mf_cs356_auxaid10,
   mf_cs356_lang_prof, mf_cs356_lang_read))
  HEAD pi.info_sub_type_cd
   CASE (pi.info_sub_type_cd)
    OF mf_race1_cd:
     pinfo->ms_race1 = trim(uar_get_code_display(pi.value_cd),3)
    OF mf_race2_cd:
     pinfo->ms_race2 = trim(uar_get_code_display(pi.value_cd),3)
    OF mf_race3_cd:
     pinfo->ms_race3 = trim(uar_get_code_display(pi.value_cd),3)
    OF mf_race4_cd:
     pinfo->ms_race4 = trim(uar_get_code_display(pi.value_cd),3)
    OF mf_race5_cd:
     pinfo->ms_race5 = trim(uar_get_code_display(pi.value_cd),3)
    OF mf_cs356_auxaid1:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc1 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid2:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc2 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid3:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc3 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid4:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc4 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid5:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc5 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid6:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc6 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid7:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc7 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid8:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc8 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid9:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc9 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_auxaid10:
     IF (pi.value_cd > 0.0)
      pinfo->s_aux_aid_svc10 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_lang_prof:
     IF (pi.value_cd > 0.0)
      pinfo->s_lang_proficiency = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    OF mf_cs356_lang_read:
     IF (pi.value_cd > 0.0)
      pinfo->ms_language_read = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bhs_demographics bd
  WHERE bd.person_id=mf_p_id
   AND bd.end_effective_dt_tm > sysdate
   AND bd.active_ind=1
  ORDER BY bd.updt_dt_tm
  DETAIL
   IF (trim(bd.description)="race 1"
    AND textlen(trim(pinfo->ms_race1,3))=0)
    pinfo->ms_race1 = uar_get_code_display(bd.code_value)
   ENDIF
   IF (trim(bd.description)="race 2"
    AND textlen(trim(pinfo->ms_race2,3))=0)
    pinfo->ms_race2 = uar_get_code_display(bd.code_value)
   ENDIF
   IF (trim(bd.description)="language read"
    AND textlen(trim(pinfo->ms_language_read,3))=0)
    pinfo->ms_language_read = uar_get_code_display(bd.code_value)
   ENDIF
   IF (trim(bd.description)="ethnicity 1")
    pinfo->ms_ethnicity1 = uar_get_code_display(bd.code_value)
   ENDIF
   IF (trim(bd.description)="ethnicity 2")
    pinfo->ms_ethnicity2 = uar_get_code_display(bd.code_value)
   ENDIF
   IF (trim(bd.description)="hispanic ind"
    AND textlen(trim(pinfo->ms_hispanic_ind,3))=0)
    CASE (pinfo->ms_hispanic_ind)
     OF "R":
      pinfo->ms_hispanic_ind = "Choose Not to Answer"
     OF "D":
      pinfo->ms_hispanic_ind = "Don't Know"
     OF "T":
      pinfo->ms_hispanic_ind = "Unable to Collect"
     OF "Y":
      pinfo->ms_hispanic_ind = "Hispanic"
     OF "N":
      pinfo->ms_hispanic_ind = "Not Hispanic"
     ELSE
      pinfo->ms_hispanic_ind = "Unknown"
    ENDCASE
   ENDIF
   IF (trim(bd.description)="religion")
    pinfo->ms_religion = uar_get_code_display(bd.code_value)
   ENDIF
  WITH nocounter
 ;end select
 IF (size(trim(pinfo->ms_race1))=0)
  SELECT INTO "nl:"
   FROM person p
   WHERE p.person_id=mf_p_id
   DETAIL
    pinfo->ms_race1 = trim(uar_get_code_display(p.race_cd))
   WITH nocounter
  ;end select
  IF (size(trim(pinfo->ms_race1))=0)
   SELECT INTO "nl:"
    FROM person_code_value_r pcv
    WHERE pcv.person_id=mf_p_id
     AND pcv.code_set=282
     AND pcv.active_ind=1
    ORDER BY pcv.beg_effective_dt_tm DESC
    DETAIL
     pinfo->ms_race1 = trim(uar_get_code_display(pcv.code_value))
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_id=mf_p_id
   AND pa.person_alias_type_cd=mf_cmrn_cd
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > sysdate
  DETAIL
   pinfo->ms_cmrn = pa.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_patient pp
  WHERE pp.person_id=mf_p_id
   AND pp.active_ind=1
  DETAIL
   pinfo->ms_head_of_household = pp.mother_identifier, pinfo->ms_birth_sex = trim(
    uar_get_code_display(pp.birth_sex_cd),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND ad.parent_entity_id=mf_p_id
   AND ad.address_type_cd=mf_addr_home_cd
   AND ad.active_ind=1
   AND ad.end_effective_dt_tm > sysdate
   AND ad.address_type_seq=1
  DETAIL
   pinfo->ms_address_lone = ad.street_addr, pinfo->ms_address_ltwo = ad.street_addr2, pinfo->ms_city
    = ad.city,
   pinfo->ms_state = ad.state, pinfo->ms_zip = ad.zipcode
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  WHERE ph.parent_entity_name IN ("PERSON", "PERSON_PATIENT")
   AND ph.parent_entity_id=mf_p_id
   AND ph.phone_type_cd IN (mf_phone_home_cd, mf_phone_bus_cd, mf_cs43_mobile)
   AND ph.phone_type_seq=1
   AND ph.active_ind=1
  DETAIL
   IF (ph.contact_method_cd=mf_cs23056_phone
    AND ph.parent_entity_name="PERSON")
    IF (ph.phone_type_cd=mf_phone_bus_cd)
     pinfo->ms_phone_bus = trim(ph.phone_num,3)
    ELSEIF (ph.phone_type_cd=mf_phone_home_cd)
     pinfo->ms_phone_home = trim(ph.phone_num,3)
    ELSEIF (ph.phone_type_cd=mf_cs43_mobile)
     pinfo->ms_phone_cell = trim(ph.phone_num,3)
    ENDIF
   ELSEIF (ph.contact_method_cd=mf_cs23056_email)
    pinfo->ms_email_home = trim(ph.phone_num,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.person_id=mf_p_id
   AND ce.event_cd=mf_advdir_cd
   AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
  mf_inprogress_cd,
  mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
  mf_unknown_cd))
   AND ce.event_class_cd != mf_placeholder_cd
   AND ce.view_level=1
   AND ce.valid_from_dt_tm <= cnvtdatetime(sysdate)
   AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY ce.valid_from_dt_tm DESC
  HEAD ce.person_id
   IF (cnvtupper(ce.result_val)="Y*")
    mi_advdir_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (mi_advdir_ind=0)
  SELECT INTO "nl:"
   FROM person_patient p
   WHERE p.person_id=mf_p_id
    AND p.living_will_cd IN (mf_yes_cd, mf_yesof_cd, mf_yesnof_cd)
    AND p.active_ind=1
   DETAIL
    IF (p.living_will_cd > 0)
     mi_advdir_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET pinfo->ms_advanced_directive = evaluate(mi_advdir_ind,1,"Yes","No")
 CALL echorecord(pinfo)
 SET _memory_reply_string = cnvtrectojson(pinfo)
#exit_program
 CALL echo(_memory_reply_string)
END GO
