CREATE PROGRAM bhs_mp_patinfo_widget:dba
 PROMPT
  "Enter Person ID:" = "",
  "Enter encounter id:" = ""
  WITH f_person_id, f_encntr_id
 RECORD pinfo(
   1 ms_address_lone = vc
   1 ms_address_ltwo = vc
   1 ms_city = vc
   1 ms_state = vc
   1 ms_zip = vc
   1 ms_phone_home = vc
   1 ms_phone_bus = vc
   1 ms_phone_cell = vc
   1 ms_preferred_phone = vc
   1 ms_visit_contact = vc
   1 ms_nursing_home = vc
   1 s_guarantor_contact = vc
   1 s_guarantor_home_number = vc
   1 s_guarantor_bus_number = vc
   1 s_guarantor_cell_number = vc
   1 s_next_of_kin_contact = vc
   1 s_next_of_kin_home_number = vc
   1 s_next_of_kin_bus_number = vc
   1 s_next_of_kin_cell_number = vc
   1 s_guardian_contact = vc
   1 s_guardian_home_number = vc
   1 s_guardian_bus_number = vc
   1 s_guardian_cell_number = vc
   1 s_emergency_contact = vc
   1 s_emergency_home_number = vc
   1 s_emergency_bus_number = vc
   1 s_emergency_cell_number = vc
 ) WITH protect
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
 DECLARE mf_phone_cell_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_contactprsn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DAYOFSURGERYCONTACTPERSON"))
 DECLARE mf_preferred_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BESTCONTACTNUMBERFORDAYOFSURGERY"))
 DECLARE mf_nursinghomesrehabfacilites_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSINGHOMESREHABFACILITES"))
 DECLARE mf_cs351_guarantor = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9519"))
 DECLARE mf_cs351_nxt_kin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9522"))
 DECLARE mf_cs351_guardian = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17057"))
 DECLARE mf_cs351_emergency = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6328"))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND ad.parent_entity_id=mf_person_id
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
  WHERE ph.parent_entity_name="PERSON"
   AND ph.parent_entity_id=mf_person_id
   AND ph.phone_type_cd IN (mf_phone_home_cd, mf_phone_bus_cd, mf_phone_cell_cd)
   AND ph.phone_type_seq=1
   AND ph.active_ind=1
  DETAIL
   IF (ph.phone_type_cd=mf_phone_bus_cd)
    pinfo->ms_phone_bus = trim(ph.phone_num,3)
   ELSEIF (ph.phone_type_cd=mf_phone_cell_cd)
    pinfo->ms_phone_cell = trim(ph.phone_num,3)
   ELSE
    pinfo->ms_phone_home = trim(ph.phone_num,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.encntr_id=mf_encntr_id
   AND ce.person_id=mf_person_id
   AND ce.event_cd IN (mf_contactprsn_cd, mf_preferred_phone_cd, mf_nursinghomesrehabfacilites_cd)
   AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
  mf_inprogress_cd,
  mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
  mf_unknown_cd))
   AND ce.event_class_cd != mf_placeholder_cd
   AND ce.view_level=1
   AND ce.valid_from_dt_tm <= sysdate
   AND ce.valid_until_dt_tm >= sysdate
  ORDER BY ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_contactprsn_cd:
     pinfo->ms_visit_contact = trim(ce.result_val,3)
    OF mf_preferred_phone_cd:
     pinfo->ms_preferred_phone = trim(ce.result_val,3)
    OF mf_nursinghomesrehabfacilites_cd:
     pinfo->ms_nursing_home = trim(ce.result_val,3)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_person_reltn epr,
   person p,
   phone ph,
   dummyt d
  PLAN (epr
   WHERE epr.encntr_id=mf_encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm >= sysdate
    AND epr.person_reltn_type_cd IN (mf_cs351_guarantor, mf_cs351_nxt_kin, mf_cs351_guardian,
   mf_cs351_emergency))
   JOIN (p
   WHERE p.person_id=epr.related_person_id
    AND p.active_ind=1)
   JOIN (d)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (mf_phone_home_cd, mf_phone_bus_cd, mf_phone_cell_cd)
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm >= sysdate)
  ORDER BY epr.person_reltn_type_cd, epr.beg_effective_dt_tm DESC
  DETAIL
   IF (epr.person_reltn_type_cd=mf_cs351_guarantor)
    pinfo->s_guarantor_contact = trim(p.name_full_formatted,3)
    CASE (ph.phone_type_cd)
     OF mf_phone_home_cd:
      pinfo->s_guarantor_home_number = trim(ph.phone_num,3)
     OF mf_phone_bus_cd:
      pinfo->s_guarantor_bus_number = trim(ph.phone_num,3)
     OF mf_phone_cell_cd:
      pinfo->s_guarantor_cell_number = trim(ph.phone_num,3)
    ENDCASE
   ELSEIF (epr.person_reltn_type_cd=mf_cs351_nxt_kin)
    pinfo->s_next_of_kin_contact = trim(p.name_full_formatted,3)
    CASE (ph.phone_type_cd)
     OF mf_phone_home_cd:
      pinfo->s_next_of_kin_home_number = trim(ph.phone_num,3)
     OF mf_phone_bus_cd:
      pinfo->s_next_of_kin_bus_number = trim(ph.phone_num,3)
     OF mf_phone_cell_cd:
      pinfo->s_next_of_kin_cell_number = trim(ph.phone_num,3)
    ENDCASE
   ELSEIF (epr.person_reltn_type_cd=mf_cs351_guardian)
    pinfo->s_guardian_contact = trim(p.name_full_formatted,3)
    CASE (ph.phone_type_cd)
     OF mf_phone_home_cd:
      pinfo->s_guardian_home_number = trim(ph.phone_num,3)
     OF mf_phone_bus_cd:
      pinfo->s_guardian_bus_number = trim(ph.phone_num,3)
     OF mf_phone_cell_cd:
      pinfo->s_guardian_cell_number = trim(ph.phone_num,3)
    ENDCASE
   ELSEIF (epr.person_reltn_type_cd=mf_cs351_emergency)
    pinfo->s_emergency_contact = trim(p.name_full_formatted,3)
    CASE (ph.phone_type_cd)
     OF mf_phone_home_cd:
      pinfo->s_emergency_home_number = trim(ph.phone_num,3)
     OF mf_phone_bus_cd:
      pinfo->s_emergency_bus_number = trim(ph.phone_num,3)
     OF mf_phone_cell_cd:
      pinfo->s_emergency_cell_number = trim(ph.phone_num,3)
    ENDCASE
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET _memory_reply_string = cnvtrectojson(pinfo)
#exit_program
 CALL echo(_memory_reply_string)
END GO
