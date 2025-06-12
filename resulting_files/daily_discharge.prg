CREATE PROGRAM daily_discharge
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Admit date/time:" = "SYSDATE",
  "Discharge Date/Time:" = "SYSDATE",
  "Email" = ""
  WITH outdev, admit_dt_tm, disch_dt_tm,
  email_list
 DECLARE mf_cs319_fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_admit_dt_tm = f8 WITH protect, constant(cnvtdatetime( $ADMIT_DT_TM))
 DECLARE mf_disch_dt_tm = f8 WITH protect, constant(cnvtdatetime( $DISCH_DT_TM))
 DECLARE mf_cs333_attendingphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_cs333_admittingphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ADMITTINGPHYSICIAN"))
 DECLARE mf_cs69_daystay = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"DAYSTAY"))
 DECLARE mf_cs69_emergency = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY"))
 DECLARE mf_cs69_inpatient = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_cs69_observation = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,
   "OBSERVATION"))
 DECLARE mf_cs69_preadmit = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"PREADMIT"))
 DECLARE mf_cs69_recurring = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"RECURRING"))
 DECLARE mf_cs69_skillednursing = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,
   "SKILLEDNURSING"))
 DECLARE mf_cs69_waitlist = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"WAITLIST"))
 DECLARE ml_indx = i4 WITH protect, noconstant(0)
 DECLARE department = vc WITH protect, noconstant("")
 DECLARE mf_cs220_bmc_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_cs220_bfmc_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE mf_cs220_bwh_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE WING HOSPITAL"))
 DECLARE mf_cs220_bnh_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL"))
 DECLARE mf_cs220_bmc_psych_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER INPATIENT PSYCHIATRY"))
 DECLARE ms_output = vc WITH protect, noconstant("daily_disch.csv")
 RECORD m_info(
   1 l_enc_cnt = i4
   1 list[*]
     2 s_department = vc
     2 s_med_service = vc
     2 s_physician_name = vc
     2 s_physician_position = vc
     2 s_patient_name = vc
     2 s_admission_dt = vc
     2 s_discharge_dt = vc
     2 s_account_number = vc
     2 s_mrn = vc
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_encounter_type = vc
     2 f_encntr_id = f8
 ) WITH protect
 FREE RECORD fac_loc
 RECORD fac_loc(
   1 loc_cnt = i4
   1 list[*]
     2 f_code_val = f8
 ) WITH protect
 DECLARE rpt_line = vc WITH protect, noconstant(" ")
 DECLARE return_var = c2 WITH protect
 DECLARE exp_indx = i4 WITH protect, noconstant(0)
 DECLARE denominator = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_subject_line = vc WITH protect, noconstant(curprog)
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.display_key IN ("BFMC", "BMC", "BMCINPTPSYCH", "BNH", "BAYSTATEVASCULARSERVICES",
  "BWH", "HEARTANDVASCULARGREENFIELD", "NOEDGEADULTPED", "NORTHERNEDGEADULTANDPEDI")
   AND cv.active_ind=1
  DETAIL
   fac_loc->loc_cnt += 1, stat = alterlist(fac_loc->list,fac_loc->loc_cnt), fac_loc->list[fac_loc->
   loc_cnt].f_code_val = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   person p,
   encntr_prsnl_reltn epr,
   prsnl pl,
   code_value cv
  PLAN (e
   WHERE e.reg_dt_tm >= cnvtdatetime(mf_admit_dt_tm)
    AND e.disch_dt_tm <= cnvtdatetime(mf_disch_dt_tm)
    AND e.encntr_type_class_cd IN (mf_cs69_daystay, mf_cs69_emergency, mf_cs69_inpatient,
   mf_cs69_observation, mf_cs69_preadmit,
   mf_cs69_recurring, mf_cs69_skillednursing, mf_cs69_waitlist)
    AND expand(ml_indx,1,fac_loc->loc_cnt,e.loc_facility_cd,fac_loc->list[ml_indx].f_code_val)
    AND e.disch_dt_tm != null)
   JOIN (cv
   WHERE cv.code_value=e.loc_nurse_unit_cd
    AND cv.cdf_meaning="NURSEUNIT")
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_cs333_attendingphysician_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ((epr.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (epr.end_effective_dt_tm=null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id
    AND pl.physician_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin_nbr_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY e.encntr_id
  HEAD REPORT
   e = 0
  HEAD e.encntr_id
   e += 1, stat = alterlist(m_info->list,e), m_info->list[e].f_encntr_id = e.encntr_id,
   m_info->list[e].s_physician_name = trim(replace(pl.name_full_formatted,","," ",0),3), m_info->
   list[e].s_physician_position = trim(uar_get_code_display(pl.position_cd),3), m_info->list[e].
   s_patient_name = trim(replace(p.name_full_formatted,","," ",0),3),
   m_info->list[e].s_admission_dt = trim(format(cnvtdatetime(e.reg_dt_tm),"mm/dd/yyyy;;d"),3), m_info
   ->list[e].s_discharge_dt = trim(format(cnvtdatetime(e.disch_dt_tm),"mm/dd/yyyy;;d"),3), m_info->
   list[e].s_account_number = trim(ea.alias,3),
   m_info->list[e].s_mrn = trim(ea2.alias,3), m_info->list[e].s_facility = trim(uar_get_code_display(
     e.loc_facility_cd),3), m_info->list[e].s_nurse_unit = trim(uar_get_code_display(e
     .loc_nurse_unit_cd),3),
   m_info->list[e].s_encounter_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_info->list[e]
   .s_med_service = trim(uar_get_code_display(e.med_service_cd),3)
   CASE (cv.display_key)
    OF "NICU":
    OF "NCCN":
    OF "NCCU":
     department = "NICU",m_info->list[e].s_department = department
    OF "NIU":
     department = "Neurology",m_info->list[e].s_department = department
    OF "CARE":
    OF "HVCC":
    OF "MICU":
    OF "NIU":
    OF "SICU":
    OF "PICU":
     department = "Critical Care",m_info->list[e].s_department = department
    OF "APTU":
     department = "Psychology",m_info->list[e].s_department = department
    OF "INFCH":
    OF "PICU":
    OF "NNURA":
    OF "NNURB":
    OF "NNURD":
     department = "Pediatrics",m_info->list[e].s_department = department
    ELSE
     department = "Other",m_info->list[e].s_department = department
   ENDCASE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value(ms_output)
  department = m_info->list[d.seq].s_department
  FROM (dummyt d  WITH seq = size(m_info->list,5))
  ORDER BY m_info->list[d.seq].s_department, m_info->list[d.seq].s_admission_dt
  HEAD REPORT
   rpt_line = build2("Physician Name",",","Physician Position",",","Patient Name",
    ",","Admission Date",",","Discharge Date",",",
    "Account Number",",","MRN",",","Facility",
    ",","Nurse Unit",",","Encounter Type",","), col 0, rpt_line,
   row + 1
  HEAD department
   col 0, "", row + 1,
   rpt_line = build2("Department of ",m_info->list[d.seq].s_department,": "), col 0, rpt_line,
   row + 1, col 0, "",
   row + 1
  HEAD d.seq
   rpt_line = build2(m_info->list[d.seq].s_physician_name,",",m_info->list[d.seq].
    s_physician_position,",",m_info->list[d.seq].s_patient_name,
    ",",m_info->list[d.seq].s_admission_dt,",",m_info->list[d.seq].s_discharge_dt,",",
    m_info->list[d.seq].s_account_number,",",m_info->list[d.seq].s_mrn,",",m_info->list[d.seq].
    s_facility,
    ",",m_info->list[d.seq].s_nurse_unit,",",m_info->list[d.seq].s_encounter_type,",",
    m_info->list[d.seq].s_med_service,","), col 0, rpt_line,
   row + 1
  WITH nocounter, maxcol = 3000, maxrow = 1
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile(ms_output,ms_output,"alex.bowman@bhs.org",build2("TEST-AB dev example report",
   ms_subject_line),1)
#exit_script
END GO
