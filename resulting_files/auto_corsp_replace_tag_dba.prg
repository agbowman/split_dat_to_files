CREATE PROGRAM auto_corsp_replace_tag:dba
 IF ( NOT (validate(refnote,0)))
  FREE SET refnote
  RECORD refnote(
    1 event_cd = f8
    1 succession_type = f8
    1 record_status = f8
    1 result_status = f8
    1 referralnote = vc
    1 notetypeid = f8
    1 notetypedescription = vc
    1 subject_line = vc
  )
  DECLARE cv_echo = vc
  DECLARE cv_cath = vc
  DECLARE cv_nuc = vc
  SET cv_echo = "CV_ECHO_DOC*"
  SET cv_cath = "CV_CATH_DOC*"
  SET cv_nuc = "CV_NUC_DOC*"
 ENDIF
 IF ( NOT (validate(processnote,0)))
  FREE SET processnote
  RECORD processnote(
    1 finalnote = vgc
  )
 ENDIF
 IF ( NOT (validate(cv_echo_ref,0)))
  DECLARE cv_echo_ref = vc
  DECLARE cv_cath_ref = vc
  DECLARE cv_nuc_ref = vc
  SET cv_echo_ref = "Echo Referral Letter"
  SET cv_cath_ref = "Cath Referral Letter"
  SET cv_nuc_ref = "Nuclear Referral Letter"
 ENDIF
 DECLARE facility = vc
 DECLARE patientlastname = vc
 DECLARE patientfirstname = vc
 DECLARE patientname = vc
 DECLARE authorpersonid = f8
 DECLARE authorlastname = vc
 DECLARE authorfirstname = vc
 DECLARE authorname = vc
 DECLARE refphycd = f8
 DECLARE referringphyid = f8
 DECLARE reflastname = vc
 DECLARE reffirstname = vc
 DECLARE refname = vc
 DECLARE street = vc
 DECLARE city = vc
 DECLARE state = vc
 DECLARE zip = vc
 DECLARE city_st_zip = vc
 SELECT INTO "nl:"
  FROM encounter entr
  WHERE (entr.encntr_id=requestin->clin_detail_list.encntr_id)
  DETAIL
   facility = uar_get_code_description(entr.loc_facility_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=requestin->clin_detail_list.person_id)
  DETAIL
   patientlastname = p.name_last, patientfirstname = p.name_first
  WITH nocounter
 ;end select
 SET patientname = concat(patientfirstname," ",patientlastname)
 SELECT INTO "nl:"
  FROM clinical_event ce,
   person p
  PLAN (ce
   WHERE (ce.event_id=requestin->clin_detail_list.event_id))
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id)
  DETAIL
   authorpersonid = ce.performed_prsnl_id, authorlastname = p.name_last, authorfirstname = p
   .name_first
  WITH nocounter
 ;end select
 SET authorname = concat(authorfirstname," ",authorlastname)
 SET refphycd = uar_get_code_by("DISPLAY",333,"Referring Physician")
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   person p,
   address a
  PLAN (epr
   WHERE (epr.encntr_id=requestin->clin_detail_list.encntr_id)
    AND epr.encntr_prsnl_r_cd=refphycd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
   JOIN (a
   WHERE a.parent_entity_id=epr.prsnl_person_id)
  DETAIL
   reflastname = p.name_last, reffirstname = p.name_first, street = a.street_addr,
   city = a.city, state = uar_get_code_display(a.state_cd), zip = a.zipcode
  WITH nocounter
 ;end select
 SET refname = concat(reffirstname," ",reflastname)
 SET city_st_zip = concat(city," ",state,","," ",
  zip)
 SET processnote->finalnote = replace(processnote->finalnote,"<StreetAdd>",street,0)
 SET processnote->finalnote = replace(processnote->finalnote,"<CityStateZip>",city_st_zip,0)
 SET processnote->finalnote = replace(processnote->finalnote,"<Facility>",facility,0)
 SET processnote->finalnote = replace(processnote->finalnote,"<ReferringDoctor>",refname,0)
 SET processnote->finalnote = replace(processnote->finalnote,"<ReferringDoctorLastName>",reflastname,
  0)
 SET processnote->finalnote = replace(processnote->finalnote,"<PatientName>",patientname,0)
 SET processnote->finalnote = replace(processnote->finalnote,"<Author>",authorname,0)
 SET script_version = "001 12/05/03 IH6582"
END GO
