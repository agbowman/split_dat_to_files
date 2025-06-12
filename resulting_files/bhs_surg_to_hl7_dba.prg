CREATE PROGRAM bhs_surg_to_hl7:dba
 DECLARE mf_surg_case = f8 WITH protect, constant( $1)
 DECLARE ms_cr_str = vc WITH protect, constant(char(013))
 DECLARE ms_bm_str = vc WITH protect, constant(char(011))
 DECLARE ms_eom_str = vc WITH protect, constant("")
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_ssn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"SSN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_current_name_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",213,"CURRENT"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_orgdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "ORGANIZATIONDOCTOR"))
 DECLARE mf_externid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "EXTERNALIDENTIFIER"))
 DECLARE mf_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE mf_schedappt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"SCHEDAPPT"))
 DECLARE mf_sch_patient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE mf_admitdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ADMITTINGPHYSICIAN"))
 DECLARE mf_prim_surg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",10170,
   "PRIMARYSURGEON"))
 DECLARE mf_inortime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,"SNINORMIN"))
 DECLARE mf_outortime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,"SNOUTORMIN")
  )
 DECLARE mf_surgdiag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SURGDIAGNOSIS"))
 DECLARE mf_snwoundclass_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNWOUNDCLASS"))
 DECLARE mf_record_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_result_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_result_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_result_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_result_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_snsurgicalwoundclosure_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNSURGICALWOUNDCLOSURE"))
 DECLARE mf_snhairremovalmethod_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNHAIRREMOVALMETHOD"))
 DECLARE mf_snhairremovalsite_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNHAIRREMOVALSITE"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_t_size = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_err_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_trans_name = vc WITH protect, noconstant("")
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE ms_file_path = vc WITH protect, noconstant(concat(trim(logical("bhscust"),3),"/diaghl7/"))
 DECLARE ml_dmc_ret = i4 WITH protect, noconstant(0)
 DECLARE ms_cmd_str = vc WITH protect, noconstant("")
 DECLARE ms_final_hl7_msg = vc WITH protect, noconstant("")
 DECLARE ml_output_size = i4 WITH protect, noconstant(10000)
 FREE RECORD m_prsn_info
 RECORD m_prsn_info(
   1 f_encntr_id = f8
   1 f_person_id = f8
   1 f_surg_case_id = f8
   1 d_cnt = i4
   1 s_cmrn = vc
   1 s_mrn = vc
   1 s_fin_nbr = vc
   1 s_mrn_fac = vc
   1 s_encntr_fac = vc
   1 s_name_first = vc
   1 s_name_middle = vc
   1 s_name_last = vc
   1 s_dob = vc
   1 s_gender = vc
   1 s_addr_line1 = vc
   1 s_addr_line2 = vc
   1 s_city = vc
   1 s_state = vc
   1 s_zip_code = vc
   1 s_home_phone_num = vc
   1 s_ssn = vc
   1 s_msh_hl7_slice = vc
   1 s_pid_hl7_slice = vc
   1 s_pv1_hl7_slice = vc
   1 f_encntr_class_cd = f8
   1 s_encntr_class_value = vc
   1 f_med_service_cd = f8
   1 s_med_service__value = vc
   1 f_encntr_type_cd = f8
   1 s_encntr_type_value = vc
   1 f_marital_type_cd = f8
   1 s_marital_type_value = vc
   1 f_nurs_unit_cd = f8
   1 s_nurs_unit_value = vc
   1 f_room_cd = f8
   1 s_room_value = vc
   1 f_bed_cd = f8
   1 s_bed_value = vc
   1 f_admit_type_cd = f8
   1 s_admit_type_value = vc
   1 s_preadmit_nbr = vc
   1 f_admit_dt_tm = f8
   1 f_disch_dt_tm = f8
   1 s_admit_doc_alias = vc
   1 s_admit_doc_lname = vc
   1 s_admit_doc_fname = vc
   1 s_surg_case_nbr = vc
   1 f_surg_loc_cd = f8
   1 s_surg_loc_value = vc
   1 f_surg_start_dt_tm = f8
   1 f_surg_duration = f8
   1 s_ail_hl7_slice = vc
   1 f_surg_stop_dt_tm = f8
   1 f_surg_prsnl_id = f8
   1 s_surg_orgdoc_alias = vc
   1 s_surg_first_name = vc
   1 s_surg_last_name = vc
   1 f_in_or_dt_tm = f8
   1 f_out_or_dt_tm = f8
   1 s_sch_hl7_slice = vc
   1 s_diag = vc
   1 s_diag_hl7_slice = vc
   1 f_appt_type_cd = f8
   1 s_appt_type = vc
   1 f_sched_type_cd = f8
   1 s_sched_type = vc
   1 f_asa_class_cd = f8
   1 s_asa_class = vc
   1 f_anesthesia_type_cd = f8
   1 s_anesthesia_type = vc
   1 f_wound_class_cd = f8
   1 s_wound_class = vc
   1 s_zcm_hl7_slice = vc
   1 s_wound_closure = vc
   1 s_hr_site = vc
   1 s_hr_method = vc
   1 l_attend_cnt = i4
   1 attend[*]
     2 f_prsnl_id = f8
     2 s_name_last = vc
     2 s_name_first = vc
     2 s_alias = vc
     2 f_role_code = f8
     2 s_role = vc
     2 f_in_date = dq8
     2 f_out_date = dq8
     2 f_dur_min = f8
     2 s_aip_hl7_slice = vc
   1 l_proc_cnt = i4
   1 proc[*]
     2 f_catalog_cd = f8
     2 s_syn_display = vc
     2 s_proc_alias = vc
     2 f_proc_start_dt_tm = f8
     2 f_proc_end_dt_tm = f8
     2 f_proc_min_duration = f8
     2 s_pr1_hl7_slice = vc
     2 s_ais_hl7_slice = vc
     2 f_prim_surg_id = f8
     2 s_prim_surg_alias = vc
     2 s_prim_surg_name_last = vc
     2 s_prim_surg_name_first = vc
   1 sch_cnt = i4
   1 sch[*]
     2 alias = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sch_event se,
   sch_event_detail sed
  PLAN (sc
   WHERE sc.surg_case_id=mf_surg_case
    AND sc.active_ind=1)
   JOIN (sed
   WHERE sed.sch_event_id=outerjoin(sc.sch_event_id)
    AND sed.oe_field_meaning=outerjoin("SURGDIAGNOSIS")
    AND sed.active_ind=outerjoin(1))
   JOIN (se
   WHERE se.sch_event_id=outerjoin(sc.sch_event_id)
    AND se.active_ind=outerjoin(1))
  ORDER BY sed.seq_nbr
  HEAD REPORT
   m_prsn_info->l_attend_cnt = 0
  DETAIL
   m_prsn_info->f_encntr_id = sc.encntr_id, m_prsn_info->f_person_id = sc.person_id, m_prsn_info->
   f_surg_case_id = sc.surg_case_id,
   m_prsn_info->f_surg_loc_cd = sc.surg_op_loc_cd, m_prsn_info->s_surg_loc_value = trim(
    uar_get_code_display(sc.surg_op_loc_cd),3), m_prsn_info->f_surg_start_dt_tm = sc.surg_start_dt_tm,
   m_prsn_info->f_surg_duration = datetimediff(sc.surg_stop_dt_tm,sc.surg_start_dt_tm,4), m_prsn_info
   ->f_surg_stop_dt_tm = sc.surg_stop_dt_tm, m_prsn_info->f_surg_prsnl_id = sc.surgeon_prsnl_id,
   m_prsn_info->s_diag = trim(sed.oe_field_display_value,3), m_prsn_info->f_appt_type_cd = se
   .appt_type_cd, m_prsn_info->f_asa_class_cd = sc.asa_class_cd,
   m_prsn_info->f_sched_type_cd = sc.sched_type_cd, m_prsn_info->f_wound_class_cd = sc.wound_class_cd,
   m_prsn_info->s_surg_case_nbr = trim(sc.surg_case_nbr_formatted,3)
  WITH nocounter
 ;end select
 IF ((m_prsn_info->f_wound_class_cd=0.0))
  SELECT INTO "nl:"
   FROM perioperative_document pd,
    clinical_event ce,
    ce_coded_result ccr
   PLAN (pd
    WHERE (pd.surg_case_id=m_prsn_info->f_surg_case_id)
     AND pd.create_dt_tm IS NOT null
     AND pd.rec_ver_dt_tm IS NOT null)
    JOIN (ce
    WHERE (ce.encntr_id=m_prsn_info->f_encntr_id)
     AND (ce.person_id=m_prsn_info->f_person_id)
     AND ce.event_cd IN (mf_snwoundclass_cd)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.record_status_cd=188
     AND ce.result_status_cd IN (23, 25, 34, 35)
     AND ce.reference_nbr >= cnvtstring(pd.periop_doc_id,10,2,r)
     AND ce.reference_nbr < cnvtstring((pd.periop_doc_id+ 1),10,2,r)
     AND substring(1,(findstring("SN",ce.reference_nbr) - 1),ce.reference_nbr)=cnvtstring(pd
     .periop_doc_id,10,2,r))
    JOIN (ccr
    WHERE ccr.event_id=ce.event_id
     AND ccr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   ORDER BY ccr.event_id
   HEAD ccr.event_id
    m_prsn_info->f_wound_class_cd = ccr.result_cd
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM case_times ct
  WHERE (ct.surg_case_id=m_prsn_info->f_surg_case_id)
   AND ct.active_ind=1
   AND ct.task_assay_cd IN (mf_inortime_cd, mf_outortime_cd)
  DETAIL
   IF (ct.task_assay_cd=mf_inortime_cd)
    m_prsn_info->f_in_or_dt_tm = ct.case_time_dt_tm
   ENDIF
   IF (ct.task_assay_cd=mf_outortime_cd)
    m_prsn_info->f_out_or_dt_tm = ct.case_time_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SET ms_file_name = "al_test_surg7.txt"
 SET ms_trans_name = concat(trim(cnvtstring(m_prsn_info->f_person_id,20),3),"_",trim(cnvtstring(
    m_prsn_info->f_encntr_id,20),3),"_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"))
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE (pa.person_id=m_prsn_info->f_person_id)
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND pa.person_alias_type_cd IN (mf_cmrn_cd, mf_ssn_cd)
  ORDER BY pa.updt_dt_tm
  DETAIL
   IF (pa.person_alias_type_cd=mf_cmrn_cd)
    m_prsn_info->s_cmrn = format(trim(pa.alias,3),"#######;P0")
   ENDIF
   IF (pa.person_alias_type_cd=mf_ssn_cd)
    m_prsn_info->s_ssn = trim(pa.alias,3)
   ENDIF
  FOOT REPORT
   ml_t_size = size(m_prsn_info->s_cmrn)
   IF (ml_t_size=0)
    ml_err_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  CALL echo("Unable to obtain CMRN for patient")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_alias ea
  WHERE (ea.encntr_id=m_prsn_info->f_encntr_id)
   AND ea.active_ind=1
   AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND ea.encntr_alias_type_cd IN (mf_mrn_cd, mf_fin_cd)
  ORDER BY ea.updt_dt_tm
  DETAIL
   IF (ea.encntr_alias_type_cd=mf_mrn_cd)
    m_prsn_info->s_mrn = format(trim(ea.alias,3),"#######;P0"), m_prsn_info->s_mrn_fac = substring(1,
     3,uar_get_code_display(ea.alias_pool_cd))
   ENDIF
   IF (ea.encntr_alias_type_cd=mf_fin_cd)
    m_prsn_info->s_fin_nbr = format(trim(ea.alias,3),"##########;P0")
   ENDIF
  FOOT REPORT
   ml_t_size = size(m_prsn_info->s_mrn)
   IF (ml_t_size=0)
    ml_err_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  CALL echo("Unable to obtain Fin/MRN number for the visit")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e
  WHERE (e.encntr_id=m_prsn_info->f_encntr_id)
  DETAIL
   IF (trim(uar_get_code_display(e.loc_facility_cd),3)="BMC")
    m_prsn_info->s_encntr_fac = "BHS"
   ELSEIF (trim(uar_get_code_display(e.loc_facility_cd),3)="BFMC")
    m_prsn_info->s_encntr_fac = "FMC"
   ELSEIF (trim(uar_get_code_display(e.loc_facility_cd),3)="BMLH")
    m_prsn_info->s_encntr_fac = "MLH"
   ELSEIF (trim(uar_get_code_display(e.loc_facility_cd),3)="BWH")
    m_prsn_info->s_encntr_fac = "WMH"
   ELSEIF (trim(uar_get_code_display(e.loc_facility_cd),3)="BNH")
    m_prsn_info->s_encntr_fac = "BNH"
   ENDIF
  WITH nocounter
 ;end select
 SET m_prsn_info->s_msh_hl7_slice = build("MSH|^~\&","|CERNER","|",m_prsn_info->s_encntr_fac,"|MIDAS",
  "|",m_prsn_info->s_encntr_fac,"|",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"),"|",
  "|ORA^A08","|",replace(ms_trans_name,"_","",0),"|P","|2.3",
  "|",replace(ms_trans_name,"_","",0),"|","|")
 SELECT INTO "nl:"
  FROM person_name pn
  WHERE (pn.person_id=m_prsn_info->f_person_id)
   AND pn.active_ind=1
   AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND pn.name_type_cd=mf_current_name_cd
  ORDER BY pn.name_type_seq
  DETAIL
   m_prsn_info->s_name_first = trim(pn.name_first), m_prsn_info->s_name_last = trim(pn.name_last),
   m_prsn_info->s_name_middle = trim(pn.name_middle)
  FOOT REPORT
   ml_t_size = size(m_prsn_info->s_name_first)
   IF (ml_t_size=0)
    ml_err_ind = 1
   ENDIF
   ml_t_size = size(m_prsn_info->s_name_last)
   IF (ml_t_size=0)
    ml_err_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  CALL echo("Unable to optain First or Last name. Skipping...")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=m_prsn_info->f_person_id)
  DETAIL
   m_prsn_info->f_marital_type_cd = p.marital_type_cd, m_prsn_info->s_dob = format(p.birth_dt_tm,
    "YYYYMMDD;;q")
   IF (p.sex_cd=mf_female_cd)
    m_prsn_info->s_gender = "F"
   ELSEIF (p.sex_cd=mf_male_cd)
    m_prsn_info->s_gender = "M"
   ELSE
    m_prsn_info->s_gender = "U"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND (ad.parent_entity_id=m_prsn_info->f_person_id)
   AND ad.address_type_cd=mf_addr_home_cd
   AND ad.active_ind=1
   AND ad.end_effective_dt_tm > sysdate
   AND ad.address_type_seq=1
  DETAIL
   m_prsn_info->s_addr_line1 = trim(ad.street_addr), m_prsn_info->s_addr_line2 = trim(ad.street_addr2
    ), m_prsn_info->s_city = trim(ad.city),
   m_prsn_info->s_zip_code = trim(ad.zipcode), m_prsn_info->s_state = uar_get_code_display(ad
    .state_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON"
   AND (ph.parent_entity_id=m_prsn_info->f_person_id)
   AND ph.phone_type_cd IN (mf_phone_home_cd)
   AND ph.phone_type_seq=1
   AND ph.active_ind=1
   AND ph.end_effective_dt_tm > sysdate
  DETAIL
   m_prsn_info->s_home_phone_num = replace(replace(replace(replace(trim(ph.phone_num,3)," ",""),"(",
      ""),")",""),"-","")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  WHERE (e.encntr_id=m_prsn_info->f_encntr_id)
  DETAIL
   m_prsn_info->f_med_service_cd = e.med_service_cd, m_prsn_info->f_encntr_class_cd = e
   .encntr_class_cd, m_prsn_info->f_encntr_type_cd = e.encntr_type_cd,
   m_prsn_info->f_nurs_unit_cd = e.loc_nurse_unit_cd, m_prsn_info->f_room_cd = e.loc_room_cd,
   m_prsn_info->f_bed_cd = e.loc_bed_cd,
   m_prsn_info->f_admit_type_cd = e.admit_type_cd, m_prsn_info->s_preadmit_nbr = trim(e.preadmit_nbr,
    3), m_prsn_info->f_admit_dt_tm = e.reg_dt_tm,
   m_prsn_info->f_disch_dt_tm = e.disch_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p,
   prsnl_alias pa
  PLAN (epr
   WHERE (epr.encntr_id=m_prsn_info->f_encntr_id)
    AND epr.encntr_prsnl_r_cd=mf_admitdoc_cd
    AND epr.prsnl_person_id != 0)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF")
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=mf_orgdoc_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  ORDER BY epr.active_ind DESC, epr.beg_effective_dt_tm DESC
  HEAD REPORT
   m_prsn_info->s_admit_doc_alias = format(trim(pa.alias,3),"#####;P0"), m_prsn_info->
   s_admit_doc_fname = cnvtupper(trim(p.name_last,3)), m_prsn_info->s_admit_doc_lname = cnvtupper(
    trim(p.name_first,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE (p.person_id=m_prsn_info->f_surg_prsnl_id)
    AND p.name_last_key != "NOTONSTAFF")
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=mf_orgdoc_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  HEAD REPORT
   m_prsn_info->s_surg_orgdoc_alias = format(trim(pa.alias,3),"#####;P0"), m_prsn_info->
   s_surg_last_name = cnvtupper(trim(p.name_last,3)), m_prsn_info->s_surg_first_name = cnvtupper(trim
    (p.name_first,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM perioperative_document pd,
   clinical_event ce
  PLAN (pd
   WHERE (pd.surg_case_id=m_prsn_info->f_surg_case_id)
    AND pd.create_dt_tm IS NOT null)
   JOIN (ce
   WHERE (ce.encntr_id=m_prsn_info->f_encntr_id)
    AND (ce.person_id=m_prsn_info->f_person_id)
    AND ce.event_cd IN (mf_snsurgicalwoundclosure_cd, mf_snhairremovalsite_cd,
   mf_snhairremovalmethod_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.record_status_cd=mf_record_active_cd
    AND ce.result_status_cd IN (mf_result_active_cd, mf_result_auth_cd, mf_result_altered_cd,
   mf_result_modified_cd)
    AND ce.reference_nbr >= cnvtstring(pd.periop_doc_id,10,2,r)
    AND ce.reference_nbr < cnvtstring((pd.periop_doc_id+ 1),10,2,r)
    AND substring(1,(findstring("SN",ce.reference_nbr) - 1),ce.reference_nbr)=cnvtstring(pd
    .periop_doc_id,10,2,r))
  ORDER BY ce.event_cd, ce.clinsig_updt_dt_tm, ce.event_id
  DETAIL
   IF (ce.event_cd=mf_snsurgicalwoundclosure_cd)
    m_prsn_info->s_wound_closure = trim(ce.result_val,3)
   ENDIF
   IF (ce.event_cd=mf_snhairremovalsite_cd)
    m_prsn_info->s_hr_site = trim(ce.result_val,3)
   ENDIF
   IF (ce.event_cd=mf_snhairremovalmethod_cd
    AND cnvtupper(trim(ce.result_val,3)) != "NONE")
    m_prsn_info->s_hr_method = trim(ce.result_val,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ml_sort =
  IF (ca.role_perf_cd=mf_prim_surg_cd) 1
  ELSE 2
  ENDIF
  FROM case_attendance ca,
   prsnl p,
   prsnl_alias pa,
   prsnl_alias pa2,
   code_value_outbound cvo
  PLAN (ca
   WHERE (ca.surg_case_id=m_prsn_info->f_surg_case_id)
    AND ca.active_ind=1
    AND ca.in_dt_tm IS NOT null
    AND ca.case_attendee_id != 0)
   JOIN (p
   WHERE p.person_id=ca.case_attendee_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.prsnl_alias_type_cd=outerjoin(mf_orgdoc_cd)
    AND pa.active_ind=outerjoin(1))
   JOIN (pa2
   WHERE pa2.person_id=outerjoin(p.person_id)
    AND pa2.prsnl_alias_type_cd=outerjoin(mf_externid_cd)
    AND pa2.active_ind=outerjoin(1))
   JOIN (cvo
   WHERE cvo.code_value=outerjoin(ca.role_perf_cd)
    AND cvo.contributor_source_cd=outerjoin(mf_schedappt_cd))
  ORDER BY ml_sort, ca.case_attendee_id, ca.beg_effective_dt_tm DESC
  HEAD ca.case_attendance_id
   m_prsn_info->l_attend_cnt = (m_prsn_info->l_attend_cnt+ 1), stat = alterlist(m_prsn_info->attend,
    m_prsn_info->l_attend_cnt), m_prsn_info->attend[m_prsn_info->l_attend_cnt].f_prsnl_id = ca
   .case_attendee_id,
   m_prsn_info->attend[m_prsn_info->l_attend_cnt].f_in_date = ca.in_dt_tm, m_prsn_info->attend[
   m_prsn_info->l_attend_cnt].f_out_date = ca.out_dt_tm, m_prsn_info->attend[m_prsn_info->
   l_attend_cnt].f_role_code = ca.role_perf_cd,
   m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_role = trim(cvo.alias,3)
   IF (size(trim(pa.alias,3)) > 0)
    IF (size(trim(pa.alias,3)) < 5)
     m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_alias = format(trim(pa.alias,3),"#####;P0")
    ELSE
     m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_alias = trim(pa.alias,3)
    ENDIF
   ELSE
    IF (substring(1,2,trim(p.username,3)) IN ("SN", "EN", "CN"))
     m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_alias = trim(p.username,3)
    ELSEIF (substring(1,3,trim(p.username,3)) IN ("NA-"))
     m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_alias = substring(4,7,trim(p.username,3))
    ELSEIF (size(trim(pa2.alias,3)) > 0)
     m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_alias = trim(pa2.alias)
    ELSE
     m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_alias = "UNKWN"
    ENDIF
   ENDIF
   m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_name_first = cnvtupper(trim(p.name_first,3)),
   m_prsn_info->attend[m_prsn_info->l_attend_cnt].s_name_last = cnvtupper(trim(p.name_last,3))
  WITH nocounter
 ;end select
 IF ((m_prsn_info->l_attend_cnt > 0))
  FOR (ml_idx1 = 1 TO m_prsn_info->l_attend_cnt)
   SET m_prsn_info->attend[ml_idx1].f_dur_min = datetimediff(m_prsn_info->attend[ml_idx1].f_out_date,
    m_prsn_info->attend[ml_idx1].f_in_date,4)
   SET m_prsn_info->attend[ml_idx1].s_aip_hl7_slice = build("AIP|",ml_idx1,"|U","|",m_prsn_info->
    attend[ml_idx1].s_alias,
    "^",m_prsn_info->attend[ml_idx1].s_name_last,"^",m_prsn_info->attend[ml_idx1].s_name_first,"|",
    "|",m_prsn_info->attend[ml_idx1].s_role,"|",format(m_prsn_info->attend[ml_idx1].f_in_date,
     "YYYYMMDDHHMMSS;;q"),"|",
    "|","|",cnvtstring(m_prsn_info->attend[ml_idx1].f_dur_min,20),"|MIN","|",
    "|")
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.code_value IN (m_prsn_info->f_med_service_cd, m_prsn_info->f_encntr_class_cd)
   AND cva.contributor_source_cd=mf_adtegate_cd
  ORDER BY cva.alias DESC
  DETAIL
   IF ((cva.code_value=m_prsn_info->f_med_service_cd))
    m_prsn_info->s_med_service__value = trim(cva.alias,3)
   ENDIF
   IF ((cva.code_value=m_prsn_info->f_encntr_class_cd))
    m_prsn_info->s_encntr_class_value = trim(cva.alias,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  prim_ord =
  IF (scp.primary_proc_ind=1) 1
  ELSE 100
  ENDIF
  FROM surg_case_procedure scp,
   order_catalog_synonym ocs,
   order_detail od,
   prsnl p,
   prsnl_alias pa
  PLAN (scp
   WHERE (scp.surg_case_id=m_prsn_info->f_surg_case_id)
    AND scp.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=scp.synonym_id)
   JOIN (od
   WHERE od.order_id=outerjoin(scp.order_id)
    AND od.oe_field_id=outerjoin(mf_surgdiag_cd))
   JOIN (p
   WHERE p.person_id=outerjoin(scp.primary_surgeon_id)
    AND p.name_last_key != outerjoin("NOTONSTAFF"))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.prsnl_alias_type_cd=outerjoin(mf_orgdoc_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm > outerjoin(sysdate))
  ORDER BY prim_ord, scp.primary_proc_ind DESC, scp.surg_case_proc_id
  HEAD REPORT
   m_prsn_info->l_proc_cnt = 0
  HEAD scp.surg_case_proc_id
   IF (((scp.primary_proc_ind=1) OR (scp.sched_primary_ind=1)) )
    m_prsn_info->f_anesthesia_type_cd = scp.anesth_type_cd
   ENDIF
   m_prsn_info->l_proc_cnt = (m_prsn_info->l_proc_cnt+ 1), stat = alterlist(m_prsn_info->proc,
    m_prsn_info->l_proc_cnt), m_prsn_info->proc[m_prsn_info->l_proc_cnt].f_catalog_cd = ocs
   .catalog_cd,
   m_prsn_info->proc[m_prsn_info->l_proc_cnt].s_syn_display = ocs.mnemonic, m_prsn_info->proc[
   m_prsn_info->l_proc_cnt].f_proc_start_dt_tm = scp.proc_start_dt_tm, m_prsn_info->proc[m_prsn_info
   ->l_proc_cnt].f_proc_end_dt_tm = scp.proc_end_dt_tm,
   m_prsn_info->proc[m_prsn_info->l_proc_cnt].f_proc_min_duration = datetimediff(scp.proc_end_dt_tm,
    scp.proc_start_dt_tm,4), m_prsn_info->proc[m_prsn_info->l_proc_cnt].f_prim_surg_id = scp
   .primary_surgeon_id
   IF (size(trim(pa.alias,3)) < 5)
    m_prsn_info->proc[m_prsn_info->l_proc_cnt].s_prim_surg_alias = format(trim(pa.alias,3),"#####;P0"
     )
   ELSE
    m_prsn_info->proc[m_prsn_info->l_proc_cnt].s_prim_surg_alias = trim(pa.alias,3)
   ENDIF
   m_prsn_info->proc[m_prsn_info->l_proc_cnt].s_prim_surg_name_first = trim(p.name_first_key,3),
   m_prsn_info->proc[m_prsn_info->l_proc_cnt].s_prim_surg_name_last = trim(p.name_last_key,3)
  WITH nocounter
 ;end select
 IF ((m_prsn_info->l_proc_cnt > 0))
  SELECT INTO "nl:"
   FROM code_value_outbound cvo
   WHERE cvo.contributor_source_cd=mf_schedappt_cd
    AND expand(ml_idx1,1,m_prsn_info->l_proc_cnt,cvo.code_value,m_prsn_info->proc[ml_idx1].
    f_catalog_cd)
   DETAIL
    ml_idx2 = locateval(ml_idx1,1,m_prsn_info->l_proc_cnt,cvo.code_value,m_prsn_info->proc[ml_idx1].
     f_catalog_cd), m_prsn_info->proc[ml_idx2].s_proc_alias = cvo.alias
   WITH nocounter
  ;end select
  FOR (ml_idx1 = 1 TO m_prsn_info->l_proc_cnt)
   SET m_prsn_info->proc[ml_idx1].s_pr1_hl7_slice = build("PR1|",ml_idx1,"|","|",m_prsn_info->proc[
    ml_idx1].s_proc_alias,
    "^",m_prsn_info->proc[ml_idx1].s_syn_display,"|","|",format(m_prsn_info->proc[ml_idx1].
     f_proc_start_dt_tm,"YYYYMMDDHHMMSS;;q"),
    "|","|",format(m_prsn_info->proc[ml_idx1].f_proc_start_dt_tm,"YYYYMMDDHHMMSS;;q"),"^",format(
     m_prsn_info->proc[ml_idx1].f_proc_end_dt_tm,"YYYYMMDDHHMMSS;;q"),
    "|","|","|","|",m_prsn_info->proc[ml_idx1].s_prim_surg_alias,
    "^",m_prsn_info->proc[ml_idx1].s_prim_surg_name_last,"^",m_prsn_info->proc[ml_idx1].
    s_prim_surg_name_first,"|")
   SET m_prsn_info->proc[ml_idx1].s_ais_hl7_slice = build("AIS|",ml_idx1,"|U","|",m_prsn_info->proc[
    ml_idx1].s_proc_alias,
    "^",m_prsn_info->proc[ml_idx1].s_syn_display,"|",format(m_prsn_info->proc[ml_idx1].
     f_proc_start_dt_tm,"YYYYMMDDHHMMSS;;q"),"|",
    format(m_prsn_info->proc[ml_idx1].f_proc_start_dt_tm,"YYYYMMDDHHMMSS;;q"),"^",format(m_prsn_info
     ->proc[ml_idx1].f_proc_end_dt_tm,"YYYYMMDDHHMMSS;;q"),"|","|",
    cnvtstring(m_prsn_info->proc[ml_idx1].f_proc_min_duration,20),"|MINS")
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_outbound cvo
  WHERE cvo.code_value IN (m_prsn_info->f_marital_type_cd, m_prsn_info->f_nurs_unit_cd, m_prsn_info->
  f_room_cd, m_prsn_info->f_bed_cd, m_prsn_info->f_admit_type_cd,
  m_prsn_info->f_encntr_type_cd, m_prsn_info->f_appt_type_cd, m_prsn_info->f_asa_class_cd,
  m_prsn_info->f_anesthesia_type_cd, m_prsn_info->f_wound_class_cd,
  m_prsn_info->f_sched_type_cd)
   AND cvo.contributor_source_cd IN (mf_adtegate_cd, mf_schedappt_cd)
  DETAIL
   IF ((cvo.code_value=m_prsn_info->f_marital_type_cd)
    AND cvo.contributor_source_cd=mf_adtegate_cd)
    m_prsn_info->s_marital_type_value = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_nurs_unit_cd)
    AND cvo.contributor_source_cd=mf_adtegate_cd)
    m_prsn_info->s_nurs_unit_value = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_room_cd)
    AND cvo.contributor_source_cd=mf_adtegate_cd)
    m_prsn_info->s_room_value = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_bed_cd)
    AND cvo.contributor_source_cd=mf_adtegate_cd)
    m_prsn_info->s_bed_value = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_admit_type_cd)
    AND cvo.contributor_source_cd=mf_adtegate_cd)
    m_prsn_info->s_admit_type_value = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_encntr_type_cd)
    AND cvo.contributor_source_cd=mf_adtegate_cd)
    m_prsn_info->s_encntr_type_value = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_appt_type_cd)
    AND cvo.contributor_source_cd=mf_schedappt_cd)
    m_prsn_info->s_appt_type = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_asa_class_cd)
    AND cvo.contributor_source_cd=mf_schedappt_cd)
    m_prsn_info->s_asa_class = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_anesthesia_type_cd)
    AND cvo.contributor_source_cd=mf_schedappt_cd)
    m_prsn_info->s_anesthesia_type = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_wound_class_cd)
    AND cvo.contributor_source_cd=mf_schedappt_cd)
    m_prsn_info->s_wound_class = trim(cvo.alias,3)
   ENDIF
   IF ((cvo.code_value=m_prsn_info->f_sched_type_cd)
    AND cvo.contributor_source_cd=mf_schedappt_cd)
    m_prsn_info->s_sched_type = trim(cvo.alias,3)
   ENDIF
  WITH nocounter
 ;end select
 SET m_prsn_info->s_pv1_hl7_slice = build("PV1|1","|",m_prsn_info->s_encntr_class_value,"|",
  m_prsn_info->s_nurs_unit_value,
  "^",m_prsn_info->s_room_value,"^",m_prsn_info->s_bed_value,"|",
  m_prsn_info->s_admit_type_value,"|",m_prsn_info->s_preadmit_nbr,"|","|",
  "|","|","|",m_prsn_info->s_med_service__value,"|",
  "|","|","|","|","|",
  "|",m_prsn_info->s_admit_doc_alias,"^",m_prsn_info->s_admit_doc_lname,"^",
  m_prsn_info->s_admit_doc_fname,"|",m_prsn_info->s_encntr_type_value,"|","|",
  "|","|","|","|","|",
  "|","|","|","|","|",
  "|","|","|","|","|",
  "|","|","|","|","|",
  "|","|","|","|",format(cnvtdatetime(m_prsn_info->f_admit_dt_tm),"YYYYMMDDHHMMSS;;q"),
  "|",format(cnvtdatetime(m_prsn_info->f_disch_dt_tm),"YYYYMMDDHHMMSS;;q"))
 SET m_prsn_info->s_pid_hl7_slice = build("PID|1","|",m_prsn_info->s_cmrn,"|",m_prsn_info->s_mrn,
  "^^^",m_prsn_info->s_mrn_fac,"|","|",m_prsn_info->s_name_last,
  "^",m_prsn_info->s_name_first,"^",m_prsn_info->s_name_middle,"|",
  "|",m_prsn_info->s_dob,"|",m_prsn_info->s_gender,"|",
  "|","|",m_prsn_info->s_addr_line1,"^",m_prsn_info->s_addr_line2,
  "^",m_prsn_info->s_city,"^",m_prsn_info->s_state,"^",
  m_prsn_info->s_zip_code,"|","|",m_prsn_info->s_home_phone_num,"|",
  "|","|",m_prsn_info->s_marital_type_value,"|","|",
  m_prsn_info->s_fin_nbr,"|","|")
 SET m_prsn_info->s_ail_hl7_slice = build("AIL|1","|U","|",m_prsn_info->s_surg_loc_value,"^^^",
  "|ROOM","|","|",format(m_prsn_info->f_surg_start_dt_tm,"YYYYMMDDHHMMSS;;q"),"|",
  "|","|",cnvtstring(m_prsn_info->f_surg_duration,20),"|MINS")
 SET m_prsn_info->s_sch_hl7_slice = build("SCH|",m_prsn_info->s_surg_case_nbr,"|",m_prsn_info->
  s_surg_case_nbr,"|",
  "|","|","|","|","|",
  m_prsn_info->s_sched_type,"|",format(m_prsn_info->f_in_or_dt_tm,"YYYYMMDDHHMMSS;;q"),"^",format(
   m_prsn_info->f_out_or_dt_tm,"YYYYMMDDHHMMSS;;q"),
  "^",cnvtstring(datetimediff(m_prsn_info->f_out_or_dt_tm,m_prsn_info->f_in_or_dt_tm,4),20),"|MINS",
  "|","^^",
  cnvtstring(m_prsn_info->f_surg_duration,20),"^",format(m_prsn_info->f_surg_start_dt_tm,
   "YYYYMMDDHHMMSS;;q"),"^",format(m_prsn_info->f_surg_stop_dt_tm,"YYYYMMDDHHMMSS;;q"),
  "|",m_prsn_info->s_surg_orgdoc_alias,"^",m_prsn_info->s_surg_last_name,"^",
  m_prsn_info->s_surg_first_name,"|")
 SET m_prsn_info->s_diag_hl7_slice = build("DG1|1|||",m_prsn_info->s_diag)
 SET m_prsn_info->s_zcm_hl7_slice = build("ZCM|1","|",m_prsn_info->s_wound_class,"|",m_prsn_info->
  s_asa_class,
  "|","|",m_prsn_info->s_anesthesia_type,"|","|",
  m_prsn_info->s_wound_closure,"|",m_prsn_info->s_hr_site,"^",m_prsn_info->s_hr_method,
  "|")
 CALL echorecord(m_prsn_info)
 SET ms_final_hl7_msg = concat(ms_bm_str,m_prsn_info->s_msh_hl7_slice,ms_cr_str,m_prsn_info->
  s_sch_hl7_slice,ms_cr_str,
  m_prsn_info->s_pid_hl7_slice,ms_cr_str,m_prsn_info->s_pv1_hl7_slice,ms_cr_str,m_prsn_info->
  s_diag_hl7_slice)
 IF ((m_prsn_info->l_proc_cnt > 0))
  FOR (ml_loop = 1 TO m_prsn_info->l_proc_cnt)
    SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,m_prsn_info->proc[ml_loop].
     s_pr1_hl7_slice)
  ENDFOR
 ELSE
  SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,"PR1|1||||||")
 ENDIF
 SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,"RGS|1")
 IF ((m_prsn_info->l_proc_cnt > 0))
  FOR (ml_loop = 1 TO m_prsn_info->l_proc_cnt)
    SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,m_prsn_info->proc[ml_loop].
     s_ais_hl7_slice)
  ENDFOR
 ELSE
  SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,"AIS|1|||||||")
 ENDIF
 SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,m_prsn_info->s_ail_hl7_slice)
 IF ((m_prsn_info->l_attend_cnt > 0))
  FOR (ml_loop = 1 TO m_prsn_info->l_attend_cnt)
    SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,m_prsn_info->attend[ml_loop].
     s_aip_hl7_slice)
  ENDFOR
 ELSE
  SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,"AIP|1|||||||||||")
 ENDIF
 SET ms_final_hl7_msg = cnvtupper(concat(ms_final_hl7_msg,ms_cr_str,m_prsn_info->s_zcm_hl7_slice,
   ms_eom_str))
 SET ml_output_size = (size(ms_final_hl7_msg)+ 1)
 CALL echo(ms_final_hl7_msg)
#exit_program
 IF (ml_err_ind=0)
  SELECT INTO value(gv_file)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    CALL print(ms_final_hl7_msg)
   WITH nocounter, maxcol = value(ml_output_size), format,
    append, noheading
  ;end select
 ENDIF
END GO
