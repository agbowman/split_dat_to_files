CREATE PROGRAM bhs_add_username_prsnl_alias:dba
 DECLARE mf_cs320_username_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4218575"
   ))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_pos
 RECORD m_pos(
   1 l_cnt = i4
   1 qual[*]
     2 f_position_cd = f8
     2 s_position = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_name = vc
     2 s_user_name = vc
     2 s_position = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=88
    AND cv.display IN ("BHS ED Medicine MD", "BHS ED RN W/OE and Tasks", "BHS AMB MA",
   "BHS AMB Nurse", "BHS AMB Office Staff",
   "BHS Ambulatory Clinician", "BHS Anesthesiology MD", "BHS Associate Professional",
   "BHS Audiologist", "BHS BH Associate Professional",
   "BHS BH Counselor", "BHS BH Hospital Case Manager", "BHS BH Occupational Therapist",
   "BHS BH PCO Associate Professional", "BHS BH RN",
   "BHS BH RN Supv", "BHS BH Resident", "BHS BH Social Worker", "BHS Cardiac Rehab Mgr",
   "BHS Cardiac Rehab Supv",
   "BHS Cardiac Surgery MD", "BHS Cardiology MD", "BHS Case Manager/Social Worker",
   "BHS Child Life Staff", "BHS Counselor",
   "BHS Counselor w/ Order Entry", "BHS Critical Care MD", "BHS DBA No Tools", "BHS Dietician",
   "BHS Endoscopy MD",
   "BHS GI MD", "BHS General Pediatrics MD", "BHS General Surgery MD", "BHS HBO Wound",
   "BHS Hospital Case Manager",
   "BHS Hospital Medicine", "BHS Infectious Disease MD", "BHS Informatics", "BHS Interpreter",
   "BHS Medical Student",
   "BHS Midwife", "BHS Neonatal MD", "BHS Neuro Supv", "BHS Neurology MD",
   "BHS Non-Invasive Cardiology",
   "BHS Non-Invasive Cardiology RN", "BHS Nursing Student", "BHS OB RN", "BHS OB Resident",
   "BHS OB/GYN MD",
   "BHS OT Assistant", "BHS Occupational Therapist", "BHS Onco RN", "BHS Oncology MD",
   "BHS Orthopedics MD",
   "BHS PCO ASR", "BHS PCO Associate Professional", "BHS PCO OFFICE STAFF", "BHS PCO RN",
   "BHS PCO TA",
   "BHS PCO w/OE No EZ Script", "BHS PCO w/OE and EZ Script", "BHS PON Office Staff",
   "BHS PT Assistant", "BHS Pharm Tech",
   "BHS Pharmacist", "BHS Pharmacy Mgr", "BHS Physiatry MD", "BHS Physical Therapist",
   "BHS Physician (General Medicine)",
   "BHS Physician -Physician Practices", "BHS Physician-General Surgery",
   "BHS Primary Care Physician", "BHS Psychiatry MD", "BHS Pulmonary MD",
   "BHS RN", "BHS RN Supv", "BHS RN w/o task", "BHS Rad Associate Professional", "BHS Rad Resident",
   "BHS Radiology MD", "BHS Rehab Mgr", "BHS Renal MD", "BHS Resident", "BHS Resp Therapist",
   "BHS Resp Therapy Student", "BHS Respiratory Mgr", "BHS SN Manager", "BHS SN RN", "BHS Scribe",
   "BHS Social Worker", "BHS Speech Therapist", "BHS Spiritual Services", "BHS TA (LPN)",
   "BHS Thoracic MD",
   "BHS Trauma MD", "BHS Urology MD", "DBA", "DBA BHS"))
  ORDER BY cv.code_value
  DETAIL
   m_pos->l_cnt += 1, stat = alterlist(m_pos->qual,m_pos->l_cnt), m_pos->qual[m_pos->l_cnt].
   f_position_cd = cv.code_value,
   m_pos->qual[m_pos->l_cnt].s_position = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.active_status_cd=188.0
    AND p.position_cd != 283540467.00
    AND  NOT (p.person_id IN (
   (SELECT
    pa.person_id
    FROM prsnl_alias pa
    WHERE pa.prsnl_alias_type_cd=mf_cs320_username_cd
     AND pa.active_ind=1))))
  ORDER BY p.person_id
  HEAD REPORT
   m_rec->l_cnt = 0
  HEAD p.person_id
   IF (size(trim(p.username,3)) > 0)
    IF ( NOT (substring(1,4,trim(p.username,3)) IN ("SPND", "TERM"))
     AND  NOT (substring(1,2,trim(p.username,3)) IN ("NA"))
     AND  NOT (substring(1,3,trim(p.username,3)) IN ("SUS", "MSO"))
     AND  NOT (trim(p.username,3) IN ("ACODISCARD", "ADDICTIONCONSULT", "ADDICTIONCONSULTBFMC",
    "ADMDUGAN", "AMBMA",
    "AMBNURSE", "AMBOFFICE", "AMBPHYSICIAN", "ANESOB", "ANESPREOP",
    "APACHE", "AUDIOTEST", "BEHAVHLTH", "BFMCREHAB", "BHCOUNSTEST",
    "BHOCTHRTEST", "BHRNSUPTEST", "BHRNTEST", "BHS RN BYPASS", "BHSTOC",
    "BHSWTEST", "BWHBH", "CARDIOCONSULT", "CARDIOCONSULTBFMC", "CARDIOLOGYHAMPDEN",
    "CER051468", "CERNSUP", "CERSUP1", "CHILDPSYCH", "CLINICALINFORMATICS",
    "COUMADIN", "EDCACHE", "ELECTROPHYS", "ELIMUSYS", "EPCS1",
    "FETALDISPLAY", "FETALINK", "FHAUTH", "FLSCONSULT", "GASTROENTEROLOGY",
    "GERIATRIC", "HEMACONSULT", "HIST", "HOSPMD", "IACCESS1",
    "IBUSSVC", "IBUSSVC2", "IDCONSULT", "IMAGEDEV", "INPTATTEND",
    "INPTDIAB", "IQHSUPER", "KIDNEYCA", "LCSP", "MOBJECTS",
    "MPAGEICU", "MYHEALTH", "NEUROCONSULT", "NEWAP", "NEWHOSPMD",
    "OBRN", "OINBOX", "ONCOCONSULT", "ONCORN", "OSGTESTREF",
    "PAIN", "PAINSVC", "PALLIATIVE", "PDHOSP", "PEDIINBOX",
    "PEDIINFECT", "PHARMACYINBOX", "PHTRIAGE", "PKLINK", "PREADMIT",
    "PVCARDIOLOGY", "RADGUIDEDPROC", "REHABMED", "RTANE", "SECURECERNER",
    "SPIRITUALSERVICES", "SYSTEM", "TRANSFUSE", "CERNER", "PATROL",
    "AHMPINBOX", "BEDROCK", "BHS IRB", "CHMPINBOX", "CONSUMERADOLESCENT",
    "CONSUMERDBA", "EDATTEND", "EDPLASMABMC", "EWARNING", "EXTRA",
    "FNDTLIST", "FNENGINE", "FNPHYSDOC", "FNRADTECH", "GN003795",
    "GN003796", "GN004718", "GN004719", "GN004720", "GN004721",
    "GN006055", "GN006769", "GN007494", "GN007616", "GN007744",
    "GN009049", "GN009050", "GN009051", "GN009052", "GN009053",
    "GN009054", "GN009055", "GN009057", "GN009058", "GN009059",
    "GN009060", "GN009061", "GN009062", "GN009063", "GN009064",
    "GN009065", "GN009066", "GN009067", "GN009068", "GN009071",
    "GN009072", "GN009073", "GN009074", "GN009075", "GN009076",
    "GN009077", "GN009079", "GN009080", "GN009081", "GN009082",
    "GN009395", "GN009510", "GN009661", "GN009662", "GN009663",
    "GN009664", "GN009665", "GN009666", "GN009667", "GN009668",
    "GN009669", "GN009670", "GN009671", "GN010291", "GN010292",
    "GN010293", "GN012354", "GN012509", "GN012571", "GN012572",
    "GN012573", "GN012574", "GN012575", "GN012576", "GN058164",
    "GN058417", "GN058418", "GN058419", "GN058420", "GN060059",
    "GN060845", "GN063448", "GN064301", "GN064304", "GN064305",
    "GN064306", "GN064307", "GN064308", "GN064309", "GN068714",
    "GN070994", "GN071062", "GN071063", "GN071064", "GN071065",
    "GN071066", "GN072413", "GN073773", "GN073776", "GN073798",
    "GN073808", "GN073821", "GN073828", "GN073847", "GN073919",
    "GN073926", "GN073945", "GN073952", "GN073960", "GN073979",
    "GN073984", "GN073994", "GN074515", "GN074670", "GN074671",
    "GN074672", "GN074673", "GN074674", "GN074918", "GN074943",
    "GN074944", "GN075526", "GN075530", "GN075531", "GN075546",
    "GN075552", "GN075563", "GN075564", "GN075585", "GN075982",
    "GN075983", "GN076491", "GN076492", "GN076494", "GN076495",
    "GN076496", "GN076497", "GN090048", "GN091517", "GN091518",
    "GN091519", "GN091520", "GN091656", "GN092477", "GN092779",
    "GN092780", "GN092781", "GN092782", "GN092783", "GN092784",
    "GN092785", "GN093180", "GN094831", "GN094984", "GN095261",
    "GN095262", "GN096586", "GN104582", "HEALTHFIDELITY", "MISFILEORD",
    "MRDIRECT", "POWERSCRIBE", "PRDIRECT", "PRINT", "PSSDUP",
    "RADSCHEDCO", "REFERRALSDIRECT", "REFUSORD", "SHIELDS", "SYSTEMOPENID",
    "TECHLAB4", "TRANSFERSDIRECT", "TRAUMAATT", "VACCMSO_EN87350_20211001",
    "VACCMSO_PN82243_20211001",
    "WOUNDCONSULTS", "SYSTEMHF", "DM055051", "SM024660", "JD037383",
    "JM036570", "CM052122")))
     m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
     f_person_id = p.person_id,
     m_rec->qual[m_rec->l_cnt].s_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
     s_position = trim(uar_get_code_display(p.position_cd),3), m_rec->qual[m_rec->l_cnt].s_user_name
      = trim(p.username,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET frec->file_name = concat("bhs_add_username_prsnl_alias_",format(cnvtdatetime(sysdate),
   "YYYYMMDDHHMMSS;;d"),".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = concat('"',"Person_ID",'","',"Name",'","',
  "Position",'","',"Username",'"',char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
  SET frec->file_buf = build('"',trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,2),3),'","',
   m_rec->qual[ml_idx1].s_name,'","',
   m_rec->qual[ml_idx1].s_position,'","',m_rec->qual[ml_idx1].s_user_name,'"',char(10))
  SET stat = cclio("WRITE",frec)
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
  INSERT  FROM prsnl_alias pa
   SET pa.active_ind = 1, pa.active_status_cd = 188, pa.active_status_dt_tm = cnvtdatetime(sysdate),
    pa.active_status_prsnl_id = 21310040.0, pa.alias = trim(m_rec->qual[ml_idx1].s_user_name,3), pa
    .alias_pool_cd = 0.0,
    pa.beg_effective_dt_tm = cnvtdatetime(sysdate), pa.check_digit = 0, pa.check_digit_method_cd =
    0.0,
    pa.contributor_system_cd = 0.0, pa.data_status_cd = 25, pa.data_status_dt_tm = cnvtdatetime(
     sysdate),
    pa.data_status_prsnl_id = 21310040.0, pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pa
    .person_id = m_rec->qual[ml_idx1].f_person_id,
    pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.prsnl_alias_sub_type_cd = 0.0, pa
    .prsnl_alias_type_cd = mf_cs320_username_cd,
    pa.updt_applctx = 1234, pa.updt_cnt = 0, pa.updt_dt_tm = cnvtdatetime(sysdate),
    pa.updt_id = 21310040.0, pa.updt_task = 1234
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
#exit_script
END GO
