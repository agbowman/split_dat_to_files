CREATE PROGRAM bhs_rpt_high_risk_diab_pats:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 61982940.00,
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Format" = "LAYOUT",
  "Recipients" = ""
  WITH outdev, f_facility_cd, s_begin_date,
  s_end_date, s_option, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 pats[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_name = vc
     2 s_gender = vc
     2 s_dob = vc
     2 s_mrn = vc
     2 s_diabetes_diag = vc
     2 s_weight = vc
     2 s_height = vc
     2 s_bmi = vc
     2 s_smoking_status = vc
     2 s_ldl = vc
     2 s_hdl = vc
     2 s_triglycerides = vc
     2 s_tot_cholesterol = vc
     2 s_hba1c_diagnostic = vc
     2 s_hba1c_monitoring = vc
     2 s_serum_creatinine = vc
     2 s_egfr_aa = vc
     2 s_egfr_non_aa = vc
     2 s_urine_albumin = vc
     2 s_sbp = vc
     2 s_dbp = vc
     2 s_last_eye_exam_dt = vc
     2 s_last_foot_exam_dt = vc
     2 bg[*]
       3 s_value = vc
       3 s_result_dt_tm = vc
     2 hosps[*]
       3 s_visit_dt_tm = vc
       3 s_reason = vc
     2 er_visits[*]
       3 s_visit_dt_tm = vc
       3 s_reason = vc
 ) WITH protect
 RECORD m_flat_rec(
   1 pats[*]
     2 s_name = vc
     2 s_gender = vc
     2 s_dob = vc
     2 s_mrn = vc
     2 s_diabetes_diag = vc
     2 s_weight = vc
     2 s_height = vc
     2 s_bmi = vc
     2 s_smoking_status = vc
     2 s_ldl = vc
     2 s_hdl = vc
     2 s_triglycerides = vc
     2 s_tot_cholesterol = vc
     2 s_hba1c_diagnostic = vc
     2 s_hba1c_monitoring = vc
     2 s_serum_creatinine = vc
     2 s_egfr_aa = vc
     2 s_egfr_non_aa = vc
     2 s_urine_albumin = vc
     2 s_sbp = vc
     2 s_dbp = vc
     2 s_last_eye_exam_dt = vc
     2 s_last_foot_exam_dt = vc
     2 s_bg_value = vc
     2 s_bg_result_dt_tm = vc
     2 s_hosp_visit_dt_tm = vc
     2 s_hosp_reason = vc
     2 s_er_visit_dt_tm = vc
     2 s_er_reason = vc
 ) WITH protect
 DECLARE ms_option = vc WITH protect, constant(cnvtupper(trim( $S_OPTION,3)))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_icd10cm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD10CM"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")
  )
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_outpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OUTPATIENT"))
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",321,"EMERGENCY"))
 DECLARE mf_bodymassindex_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BODYMASSINDEX"))
 DECLARE mf_sbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_dbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_smokingcessation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGCESSATION"))
 DECLARE mf_cholesterol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CHOLESTEROL")
  )
 DECLARE mf_triglycerides_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRIGLYCERIDES"))
 DECLARE mf_hdl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HDLCHOLESTEROL"))
 DECLARE mf_ldl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE mf_glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE mf_albuminurine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ALBUMINURINE"))
 DECLARE mf_a1c_diagnostic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CDIAGNOSTIC"))
 DECLARE mf_a1c_monitoring_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CMONITORING"))
 DECLARE mf_egfr_non_aa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRNONAFRICANAMERICAN"))
 DECLARE mf_egfr_aa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRAFRICANAMERICAN"))
 DECLARE mf_creatinineblood_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Creatinine-Blood"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_max = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE ms_date_range = vc WITH protect, noconstant("")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_facility = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_output = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _times60 = i4 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times18b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _pen15s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (headreport(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_facility,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_flags = 532
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.438
    SET _dummyfont = uar_rptsetfont(_hreport,_times18b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("High Risk Diabetes Patient Report",
      char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.730
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Facility:",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.615)
    SET rptsd->m_x = (offsetx+ 1.125)
    SET rptsd->m_width = 4.750
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_date_range,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpatient(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpatientabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpatientabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.470000), private
   DECLARE __s_creatinine = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_serum_creatinine,char(0))
    ), protect
   DECLARE __s_name = vc WITH noconstant(build2(substring(1,50,m_rec->pats[ml_cnt].s_name),char(0))),
   protect
   DECLARE __s_mrn = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_mrn,char(0))), protect
   DECLARE __s_gender = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_gender,char(0))), protect
   DECLARE __s_dob = vc WITH noconstant(build2(substring(1,50,m_rec->pats[ml_cnt].s_dob),char(0))),
   protect
   DECLARE __s_diabetes_diag = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_diabetes_diag,char(0))
    ), protect
   DECLARE __s_height = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_height,char(0))), protect
   DECLARE __s_weight = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_weight,char(0))), protect
   DECLARE __s_bmi = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_bmi,char(0))), protect
   DECLARE __s_ldl = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_ldl,char(0))), protect
   DECLARE __s_hdl = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_hdl,char(0))), protect
   DECLARE __s_triglycerides = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_triglycerides,char(0))
    ), protect
   DECLARE __s_tot_cholesterol = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_tot_cholesterol,char
     (0))), protect
   DECLARE __s_hba1c_monitoring = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_hba1c_monitoring,
     char(0))), protect
   DECLARE __s_egfr_aa = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_egfr_aa,char(0))), protect
   DECLARE __s_egfr_non_aa = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_egfr_non_aa,char(0))),
   protect
   DECLARE __s_urine_albumin = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_urine_albumin,char(0))
    ), protect
   DECLARE __s_sbp = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_sbp,char(0))), protect
   DECLARE __s_dbp = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_dbp,char(0))), protect
   DECLARE __s_last_foot_exam = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_last_foot_exam_dt,
     char(0))), protect
   DECLARE __s_last_eye_exam = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_last_eye_exam_dt,char(
      0))), protect
   DECLARE __s_smoking_status = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_smoking_status,char(0
      ))), protect
   DECLARE __s_hba1c_diagnostic = vc WITH noconstant(build2(m_rec->pats[ml_cnt].s_hba1c_diagnostic,
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.490
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_creatinine)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.303)
    SET rptsd->m_x = (offsetx+ 0.011)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.303)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.303)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Gender",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.303)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Of Birth",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 2.167
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 0.792
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_mrn)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 0.792
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_gender)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_dob)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diagnosis",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.625
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_diabetes_diag)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Height (cm)",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.917)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight (kg)",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMI",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 2.448)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LDL",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("HDL",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 3.553)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Triglycerides",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 1.490
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Cholesterol",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.230)
    SET rptsd->m_x = (offsetx+ 5.719)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.396
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("HbA1c Monitoring",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 0.011)
    SET rptsd->m_width = 0.740
    SET rptsd->m_height = 0.376
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_height)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 0.917)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_weight)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_bmi)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_ldl)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_hdl)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 3.553)
    SET rptsd->m_width = 0.886
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_triglycerides)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_tot_cholesterol)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 5.719)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_hba1c_monitoring)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Creatinine",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("eGFR AA",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 1.626)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("eGFR Non AA",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Urine Albumin",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SBP",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 4.240)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DBP",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 4.782)
    SET rptsd->m_width = 1.490
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Last Eye Exam",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.948)
    SET rptsd->m_x = (offsetx+ 5.896)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Last Foot Exam",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_egfr_aa)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 1.626)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_egfr_non_aa)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_urine_albumin)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_sbp)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 4.240)
    SET rptsd->m_width = 0.886
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_dbp)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 5.896)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_last_foot_exam)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.209)
    SET rptsd->m_x = (offsetx+ 4.782)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_last_eye_exam)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.292
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Smoking Status",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_smoking_status)
    SET _dummypen = uar_rptsetpen(_hreport,_pen15s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.130),(offsetx+ 7.501),(offsety+
     0.130))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.230)
    SET rptsd->m_x = (offsetx+ 6.605)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.396
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("HbA1c Diagnostic",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.573)
    SET rptsd->m_x = (offsetx+ 6.605)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_hba1c_diagnostic)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (glucosehead(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = glucoseheadabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (glucoseheadabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 132
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.084)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.188
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Glucose Values Under 54 mg/dL",
      char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (glucosedetail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = glucosedetailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (glucosedetailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __s_value = vc WITH noconstant(build2(m_rec->pats[ml_cnt].bg[ml_cnt2].s_value,char(0))),
   protect
   DECLARE __s_result_dt_tm = vc WITH noconstant(build2(m_rec->pats[ml_cnt].bg[ml_cnt2].
     s_result_dt_tm,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_value)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.105)
    SET rptsd->m_width = 1.709
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_result_dt_tm)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (ervisithead(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ervisitheadabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (ervisitheadabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.084)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.188
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ER Visits",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (ervisitdetail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ervisitdetailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (ervisitdetailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __s_visit_dt_tm = vc WITH noconstant(build2(m_rec->pats[ml_cnt].er_visits[ml_cnt2].
     s_visit_dt_tm,char(0))), protect
   DECLARE __s_reason = vc WITH noconstant(build2(m_rec->pats[ml_cnt].er_visits[ml_cnt2].s_reason,
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_visit_dt_tm)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.105)
    SET rptsd->m_width = 6.334
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_reason)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (hospitalizationhead(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hospitalizationheadabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (hospitalizationheadabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.084)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.188
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hospitalizations",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (hospitalizationdetail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hospitalizationdetailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (hospitalizationdetailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __s_visit_dt_tm = vc WITH noconstant(build2(m_rec->pats[ml_cnt].hosps[ml_cnt2].
     s_visit_dt_tm,char(0))), protect
   DECLARE __s_reason = vc WITH noconstant(build2(m_rec->pats[ml_cnt].hosps[ml_cnt2].s_reason,char(0)
     )), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_visit_dt_tm)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.105)
    SET rptsd->m_width = 6.396
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_reason)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpage(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpageabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen15s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.130),(offsetx+ 7.501),(offsety+
     0.130))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_HIGH_RISK_DIAB_PATS"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET rptreport->m_needsnotonaskharabic = 0
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET _times60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 18
   SET rptfont->m_bold = rpt_on
   SET _times18b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.015
   SET _pen15s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_HIGH_RISK_DIAB_PATS*"
    AND di.info_char=ms_option
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 185)
  SET ms_error = "Date range exceeds 6 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 IF (((textlen(trim( $S_RECIPIENTS,3)) > 1) OR (mn_ops=1)) )
  IF (ms_option="CSV")
   SET ms_output = build("bhs_rpt_high_risk_diab_pats_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
    "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy ;;d"),3),".csv")
  ELSEIF (ms_option="LAYOUT")
   SET ms_output = build("bhs_rpt_high_risk_diab_pats_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
    "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy ;;d"),3),".pdf")
  ENDIF
  SET ms_subject = build2("High Risk Diabetes Patient Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm ;;d")))
 ENDIF
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
  SET ms_facility = "<all>"
 ELSE
  SET ms_facility_p = concat("e.loc_facility_cd = ",trim(cnvtstring( $F_FACILITY_CD)))
  SET ms_facility = substring(1,100,uar_get_code_display( $F_FACILITY_CD))
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   diagnosis d,
   nomenclature n,
   person p,
   encntr_alias ea
  PLAN (e
   WHERE parser(ms_facility_p)
    AND e.reg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (d
   WHERE d.encntr_id=e.encntr_id
    AND d.active_ind=1
    AND d.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_vocabulary_cd=mf_icd10cm_cd
    AND n.source_identifier IN ("E10.9", "E11.9", "O24.319", "O24.419"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  ORDER BY p.name_last
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->pats,5))
    CALL alterlist(m_rec->pats,(ml_cnt+ 100))
   ENDIF
   m_rec->pats[ml_cnt].f_encntr_id = e.encntr_id, m_rec->pats[ml_cnt].f_person_id = p.person_id,
   m_rec->pats[ml_cnt].s_name = p.name_full_formatted,
   m_rec->pats[ml_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy ;;d"),3), m_rec->pats[ml_cnt].
   s_gender = uar_get_code_display(p.sex_cd), m_rec->pats[ml_cnt].s_mrn = ea.alias,
   m_rec->pats[ml_cnt].s_diabetes_diag = n.source_string, m_rec->pats[ml_cnt].s_bmi = "n/a", m_rec->
   pats[ml_cnt].s_sbp = "n/a",
   m_rec->pats[ml_cnt].s_dbp = "n/a", m_rec->pats[ml_cnt].s_height = "n/a", m_rec->pats[ml_cnt].
   s_weight = "n/a",
   m_rec->pats[ml_cnt].s_tot_cholesterol = "n/a", m_rec->pats[ml_cnt].s_triglycerides = "n/a", m_rec
   ->pats[ml_cnt].s_hdl = "n/a",
   m_rec->pats[ml_cnt].s_ldl = "n/a", m_rec->pats[ml_cnt].s_smoking_status = "n/a", m_rec->pats[
   ml_cnt].s_urine_albumin = "n/a",
   m_rec->pats[ml_cnt].s_hba1c_diagnostic = "n/a", m_rec->pats[ml_cnt].s_hba1c_monitoring = "n/a",
   m_rec->pats[ml_cnt].s_serum_creatinine = "n/a",
   m_rec->pats[ml_cnt].s_egfr_non_aa = "n/a", m_rec->pats[ml_cnt].s_egfr_aa = "n/a", m_rec->pats[
   ml_cnt].s_last_eye_exam_dt = "n/a",
   m_rec->pats[ml_cnt].s_last_foot_exam_dt = "n/a"
  FOOT REPORT
   CALL alterlist(m_rec->pats,ml_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE expand(ml_num,1,size(m_rec->pats,5),ce.encntr_id,m_rec->pats[ml_num].f_encntr_id)
    AND ce.event_cd IN (mf_bodymassindex_cd, mf_sbp_cd, mf_dbp_cd, mf_height_cd, mf_weight_cd,
   mf_cholesterol_cd, mf_triglycerides_cd, mf_hdl_cd, mf_ldl_cd, mf_smokingcessation_cd,
   mf_glucose_cd, mf_albuminurine_cd, mf_a1c_diagnostic_cd, mf_a1c_monitoring_cd,
   mf_creatinineblood_cd,
   mf_egfr_non_aa_cd, mf_egfr_aa_cd)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (cnvtupper(trim(ce.result_val,3)) IN ("PENDING", "IN ERROR", "DATE\TIME CORRECTION",
   "NOT REPORTED IF <18 YRS")))
  ORDER BY ce.encntr_id, ce.event_end_dt_tm
  HEAD ce.encntr_id
   ml_idx = locateval(ml_num,1,size(m_rec->pats,5),ce.encntr_id,m_rec->pats[ml_num].f_encntr_id)
  HEAD ce.event_id
   CASE (ce.event_cd)
    OF mf_bodymassindex_cd:
     m_rec->pats[ml_idx].s_bmi = ce.result_val
    OF mf_sbp_cd:
     m_rec->pats[ml_idx].s_sbp = ce.result_val
    OF mf_dbp_cd:
     m_rec->pats[ml_idx].s_dbp = ce.result_val
    OF mf_height_cd:
     m_rec->pats[ml_idx].s_height = ce.result_val
    OF mf_weight_cd:
     m_rec->pats[ml_idx].s_weight = ce.result_val
    OF mf_cholesterol_cd:
     m_rec->pats[ml_idx].s_tot_cholesterol = ce.result_val
    OF mf_triglycerides_cd:
     m_rec->pats[ml_idx].s_triglycerides = ce.result_val
    OF mf_hdl_cd:
     m_rec->pats[ml_idx].s_hdl = ce.result_val
    OF mf_ldl_cd:
     m_rec->pats[ml_idx].s_ldl = ce.result_val
    OF mf_smokingcessation_cd:
     m_rec->pats[ml_idx].s_smoking_status = ce.result_val
    OF mf_albuminurine_cd:
     IF (textlen(trim(ce.result_val,3)) < 9)
      m_rec->pats[ml_idx].s_urine_albumin = ce.result_val
     ENDIF
    OF mf_a1c_diagnostic_cd:
     m_rec->pats[ml_idx].s_hba1c_diagnostic = ce.result_val
    OF mf_a1c_monitoring_cd:
     m_rec->pats[ml_idx].s_hba1c_monitoring = ce.result_val
    OF mf_creatinineblood_cd:
     m_rec->pats[ml_idx].s_serum_creatinine = ce.result_val
    OF mf_egfr_non_aa_cd:
     m_rec->pats[ml_idx].s_egfr_non_aa = ce.result_val
    OF mf_egfr_aa_cd:
     m_rec->pats[ml_idx].s_egfr_aa = ce.result_val
    OF mf_glucose_cd:
     IF (cnvtint(ce.result_val) BETWEEN 1 AND 54)
      ml_cnt = (size(m_rec->pats[ml_idx].bg,5)+ 1),
      CALL alterlist(m_rec->pats[ml_idx].bg,ml_cnt), m_rec->pats[ml_idx].bg[ml_cnt].s_value = ce
      .result_val,
      m_rec->pats[ml_idx].bg[ml_cnt].s_result_dt_tm = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"
       )
     ENDIF
   ENDCASE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(m_rec->pats,5)),
   hm_recommendation hr,
   hm_expect he
  PLAN (d)
   JOIN (hr
   WHERE (hr.person_id=m_rec->pats[d.seq].f_person_id)
    AND hr.status_flag != 7
    AND hr.expect_id != 0
    AND hr.last_satisfaction_dt_tm != null)
   JOIN (he
   WHERE he.expect_id=hr.expect_id
    AND cnvtupper(he.expect_meaning) IN ("EHRO_DIABETES_DILATED",
   "EHRO_DIABETES_COMPREHENSIVE_FOOT_EXAM", "DIABETES COMPREHENSIVE FOOT EXAM",
   "DIABETES DILATED RETINAL EYE EXAM")
    AND he.active_ind=1)
  ORDER BY hr.person_id, hr.last_satisfaction_dt_tm
  DETAIL
   IF (cnvtupper(he.expect_meaning) IN ("EHRO_DIABETES_COMPREHENSIVE_FOOT_EXAM",
   "DIABETES COMPREHENSIVE FOOT EXAM"))
    m_rec->pats[d.seq].s_last_foot_exam_dt = trim(format(hr.last_satisfaction_dt_tm,"mm/dd/yyyy ;;d"),
     3)
   ELSEIF (cnvtupper(he.expect_meaning) IN ("EHRO_DIABETES_DILATED",
   "DIABETES DILATED RETINAL EYE EXAM"))
    m_rec->pats[d.seq].s_last_eye_exam_dt = trim(format(hr.last_satisfaction_dt_tm,"mm/dd/yyyy ;;d"),
     3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(m_rec->pats,5)),
   encounter e
  PLAN (d)
   JOIN (e
   WHERE (e.person_id=m_rec->pats[d.seq].f_person_id)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate
    AND e.encntr_type_class_cd IN (mf_observation_cd, mf_inpatient_cd, mf_outpatient_cd))
  HEAD e.encntr_id
   IF (e.encntr_class_cd=mf_emergency_cd)
    ml_cnt = (size(m_rec->pats[d.seq].er_visits,5)+ 1),
    CALL alterlist(m_rec->pats[d.seq].er_visits,ml_cnt), m_rec->pats[d.seq].er_visits[ml_cnt].
    s_visit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
    m_rec->pats[d.seq].er_visits[ml_cnt].s_reason = e.reason_for_visit
   ELSEIF (e.encntr_type_class_cd IN (mf_observation_cd, mf_inpatient_cd))
    ml_cnt = (size(m_rec->pats[d.seq].hosps,5)+ 1),
    CALL alterlist(m_rec->pats[d.seq].hosps,ml_cnt), m_rec->pats[d.seq].hosps[ml_cnt].s_visit_dt_tm
     = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
    m_rec->pats[d.seq].hosps[ml_cnt].s_reason = e.reason_for_visit
   ENDIF
  WITH nocounter
 ;end select
 IF (ms_option="CSV")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(m_rec->pats,5))
   PLAN (d)
   HEAD REPORT
    ml_cnt = 0
   HEAD d.seq
    ml_cnt += 1
    IF (ml_cnt > size(m_flat_rec->pats,5))
     CALL alterlist(m_flat_rec->pats,(ml_cnt+ 100))
    ENDIF
    m_flat_rec->pats[ml_cnt].s_name = m_rec->pats[d.seq].s_name, m_flat_rec->pats[ml_cnt].s_dob =
    m_rec->pats[d.seq].s_dob, m_flat_rec->pats[ml_cnt].s_gender = m_rec->pats[d.seq].s_gender,
    m_flat_rec->pats[ml_cnt].s_mrn = m_rec->pats[d.seq].s_mrn, m_flat_rec->pats[ml_cnt].
    s_diabetes_diag = m_rec->pats[d.seq].s_diabetes_diag, m_flat_rec->pats[ml_cnt].s_bmi = m_rec->
    pats[d.seq].s_bmi,
    m_flat_rec->pats[ml_cnt].s_sbp = m_rec->pats[d.seq].s_sbp, m_flat_rec->pats[ml_cnt].s_dbp = m_rec
    ->pats[d.seq].s_dbp, m_flat_rec->pats[ml_cnt].s_height = m_rec->pats[d.seq].s_height,
    m_flat_rec->pats[ml_cnt].s_weight = m_rec->pats[d.seq].s_weight, m_flat_rec->pats[ml_cnt].
    s_tot_cholesterol = m_rec->pats[d.seq].s_tot_cholesterol, m_flat_rec->pats[ml_cnt].
    s_triglycerides = m_rec->pats[d.seq].s_triglycerides,
    m_flat_rec->pats[ml_cnt].s_hdl = m_rec->pats[d.seq].s_hdl, m_flat_rec->pats[ml_cnt].s_ldl = m_rec
    ->pats[d.seq].s_ldl, m_flat_rec->pats[ml_cnt].s_smoking_status = m_rec->pats[d.seq].
    s_smoking_status,
    m_flat_rec->pats[ml_cnt].s_urine_albumin = m_rec->pats[d.seq].s_urine_albumin, m_flat_rec->pats[
    ml_cnt].s_hba1c_diagnostic = m_rec->pats[d.seq].s_hba1c_diagnostic, m_flat_rec->pats[ml_cnt].
    s_hba1c_monitoring = m_rec->pats[d.seq].s_hba1c_monitoring,
    m_flat_rec->pats[ml_cnt].s_serum_creatinine = m_rec->pats[d.seq].s_serum_creatinine, m_flat_rec->
    pats[ml_cnt].s_egfr_non_aa = m_rec->pats[d.seq].s_egfr_non_aa, m_flat_rec->pats[ml_cnt].s_egfr_aa
     = m_rec->pats[d.seq].s_egfr_aa,
    m_flat_rec->pats[ml_cnt].s_last_eye_exam_dt = m_rec->pats[d.seq].s_last_eye_exam_dt, m_flat_rec->
    pats[ml_cnt].s_last_foot_exam_dt = m_rec->pats[d.seq].s_last_foot_exam_dt, ml_cnt2 = ml_cnt,
    ml_max = ml_cnt
    FOR (ml_idx = 1 TO size(m_rec->pats[d.seq].bg,5))
      ml_cnt = ((ml_cnt2+ ml_idx) - 1)
      IF (ml_cnt > size(m_flat_rec->pats,5))
       CALL alterlist(m_flat_rec->pats,(ml_cnt+ 100))
      ENDIF
      m_flat_rec->pats[ml_cnt].s_bg_value = m_rec->pats[d.seq].bg[ml_idx].s_value, m_flat_rec->pats[
      ml_cnt].s_bg_result_dt_tm = m_rec->pats[d.seq].bg[ml_idx].s_result_dt_tm, ml_max = ml_cnt
    ENDFOR
    ml_cnt = ml_cnt2
    FOR (ml_idx = 1 TO size(m_rec->pats[d.seq].hosps,5))
      ml_cnt = ((ml_cnt2+ ml_idx) - 1)
      IF (ml_cnt > size(m_flat_rec->pats,5))
       CALL alterlist(m_flat_rec->pats,(ml_cnt+ 100))
      ENDIF
      m_flat_rec->pats[ml_cnt].s_hosp_reason = m_rec->pats[d.seq].hosps[ml_idx].s_reason, m_flat_rec
      ->pats[ml_cnt].s_hosp_visit_dt_tm = m_rec->pats[d.seq].hosps[ml_idx].s_visit_dt_tm
      IF (ml_cnt > ml_max)
       ml_max = ml_cnt
      ENDIF
    ENDFOR
    ml_cnt = ml_cnt2
    FOR (ml_idx = 1 TO size(m_rec->pats[d.seq].er_visits,5))
      ml_cnt = ((ml_cnt2+ ml_idx) - 1)
      IF (ml_cnt > size(m_flat_rec->pats,5))
       CALL alterlist(m_flat_rec->pats,(ml_cnt+ 100))
      ENDIF
      m_flat_rec->pats[ml_cnt].s_er_reason = m_rec->pats[d.seq].er_visits[ml_idx].s_reason,
      m_flat_rec->pats[ml_cnt].s_er_visit_dt_tm = m_rec->pats[d.seq].er_visits[ml_idx].s_visit_dt_tm
      IF (ml_cnt > ml_max)
       ml_max = ml_cnt
      ENDIF
    ENDFOR
    ml_cnt = ml_max
   FOOT REPORT
    CALL alterlist(m_flat_rec->pats,ml_cnt)
   WITH nocounter
  ;end select
  IF (((textlen(trim( $S_RECIPIENTS,3)) > 1) OR (mn_ops=1)) )
   SET frec->file_name = ms_output
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"PATIENT NAME",','"GENDER",','"DATE OF BIRTH",','"MRN",',
    '"DIAGNOSIS",',
    '"WEIGHT (KG)",','"HEIGHT (CM)",','"BMI",','"SMOKING STATUS",','"LDL",',
    '"HDL",','"TRIGLYCERIDES",','"TOTAL CHOLESTEROL",','"HBA1C DIAGNOSTIC",','"HBA1C MONITORING",',
    '"SERUM CREATININE",','"EGFR NON AFRICAN AMERICAN",','"EGFR AFRICAN AMERICAN",',
    '"URINE ALBUMIN",','"BG VALUES UNDER 54 MG/DL",',
    '"BG RESULT DT TM",','"SYSTOLIC BP",','"DIASTOLIC BP",','"HOSPITALIZATION DT TM",',
    '"HOSPITALIZATION REASON",',
    '"ER VISIT DT TM",','"ER VISIT REASON",','"LAST EYE EXAM DT TM",','"LAST FOOT EXAM DT TM",',char(
     13))
   SET stat = cclio("WRITE",frec)
   FOR (ml_idx = 1 TO size(m_flat_rec->pats,5))
    SET frec->file_buf = build('"',trim(m_flat_rec->pats[ml_idx].s_name,3),'","',trim(m_flat_rec->
      pats[ml_idx].s_gender,3),'","',
     trim(m_flat_rec->pats[ml_idx].s_dob,3),'","',trim(m_flat_rec->pats[ml_idx].s_mrn,3),'","',trim(
      m_flat_rec->pats[ml_idx].s_diabetes_diag,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_weight,3),'","',trim(m_flat_rec->pats[ml_idx].s_height,3),
     '","',
     trim(m_flat_rec->pats[ml_idx].s_bmi,3),'","',trim(m_flat_rec->pats[ml_idx].s_smoking_status,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_ldl,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_hdl,3),'","',trim(m_flat_rec->pats[ml_idx].s_triglycerides,
      3),'","',
     trim(m_flat_rec->pats[ml_idx].s_tot_cholesterol,3),'","',trim(m_flat_rec->pats[ml_idx].
      s_hba1c_diagnostic,3),'","',trim(m_flat_rec->pats[ml_idx].s_hba1c_monitoring,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_serum_creatinine,3),'","',trim(m_flat_rec->pats[ml_idx].
      s_egfr_non_aa,3),'","',
     trim(m_flat_rec->pats[ml_idx].s_egfr_aa,3),'","',trim(m_flat_rec->pats[ml_idx].s_urine_albumin,3
      ),'","',trim(m_flat_rec->pats[ml_idx].s_bg_value,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_bg_result_dt_tm,3),'","',trim(m_flat_rec->pats[ml_idx].
      s_sbp,3),'","',
     trim(m_flat_rec->pats[ml_idx].s_dbp,3),'","',trim(m_flat_rec->pats[ml_idx].s_hosp_visit_dt_tm,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_hosp_reason,3),
     '","',trim(m_flat_rec->pats[ml_idx].s_er_visit_dt_tm,3),'","',trim(m_flat_rec->pats[ml_idx].
      s_er_reason,3),'","',
     trim(m_flat_rec->pats[ml_idx].s_last_eye_exam_dt,3),'","',trim(m_flat_rec->pats[ml_idx].
      s_last_foot_exam_dt,3),'"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ELSE
   SELECT INTO value( $OUTDEV)
    patient_name = substring(1,50,m_flat_rec->pats[d.seq].s_name), gender = substring(1,50,m_flat_rec
     ->pats[d.seq].s_gender), date_of_birth = substring(1,50,m_flat_rec->pats[d.seq].s_dob),
    mrn = substring(1,50,m_flat_rec->pats[d.seq].s_mrn), diagnosis = substring(1,200,m_flat_rec->
     pats[d.seq].s_diabetes_diag), weight = substring(1,50,m_flat_rec->pats[d.seq].s_weight),
    height = substring(1,50,m_flat_rec->pats[d.seq].s_height), bmi = substring(1,50,m_flat_rec->pats[
     d.seq].s_bmi), smoking_status = substring(1,50,m_flat_rec->pats[d.seq].s_smoking_status),
    ldl = substring(1,50,m_flat_rec->pats[d.seq].s_ldl), hdl = substring(1,50,m_flat_rec->pats[d.seq]
     .s_hdl), triglycerides = substring(1,50,m_flat_rec->pats[d.seq].s_triglycerides),
    total_cholesterol = substring(1,50,m_flat_rec->pats[d.seq].s_tot_cholesterol), hba1c_diagnostic
     = substring(1,50,m_flat_rec->pats[d.seq].s_hba1c_diagnostic), hba1c_monitoring = substring(1,50,
     m_flat_rec->pats[d.seq].s_hba1c_monitoring),
    serum_creatinine = substring(1,50,m_flat_rec->pats[d.seq].s_serum_creatinine),
    egfr_non_african_american = substring(1,50,m_flat_rec->pats[d.seq].s_egfr_non_aa),
    egfr_african_american = substring(1,50,m_flat_rec->pats[d.seq].s_egfr_aa),
    urine_albumin = substring(1,50,m_flat_rec->pats[d.seq].s_urine_albumin), bg_values_under_54_mg_dl
     = substring(1,50,m_flat_rec->pats[d.seq].s_bg_value), bg_result_dt_tm = substring(1,50,
     m_flat_rec->pats[d.seq].s_bg_result_dt_tm),
    systolic_bp = substring(1,50,m_flat_rec->pats[d.seq].s_sbp), diastolic_bp = substring(1,50,
     m_flat_rec->pats[d.seq].s_dbp), hospitalization_dt_tm = substring(1,50,m_flat_rec->pats[d.seq].
     s_hosp_visit_dt_tm),
    hospitalization_reason = substring(1,50,m_flat_rec->pats[d.seq].s_hosp_reason), er_visit_dt_tm =
    substring(1,50,m_flat_rec->pats[d.seq].s_er_visit_dt_tm), er_visit_reason = substring(1,50,
     m_flat_rec->pats[d.seq].s_er_reason),
    last_eye_exam_dt_tm = substring(1,50,m_flat_rec->pats[d.seq].s_last_eye_exam_dt),
    last_foot_exam_dt_tm = substring(1,50,m_flat_rec->pats[d.seq].s_last_foot_exam_dt)
    FROM (dummyt d  WITH seq = size(m_flat_rec->pats,5))
    PLAN (d)
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 ELSEIF (ms_option="LAYOUT")
  SET ms_date_range = concat(trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(
    format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm ;;d"),3))
  EXECUTE reportrtl
  SET d0 = initializereport(0)
  SET d0 = headreport(rpt_render)
  SUBROUTINE (break_check(f_section_height=f8) =null)
   SET mf_rem_space = (mf_page_size - (_yoffset+ f_section_height))
   IF ((mf_rem_space <= (footpage(rpt_calcheight)+ 0.10)))
    SET _yoffset = 10.08
    SET d0 = footpage(rpt_render)
    SET d0 = pagebreak(0)
   ENDIF
  END ;Subroutine
  FOR (ml_cnt = 1 TO size(m_rec->pats,5))
    CALL break_check(headpatient(rpt_calcheight))
    SET d0 = headpatient(rpt_render)
    IF (size(m_rec->pats[ml_cnt].bg,5) > 0)
     CALL break_check(glucosehead(rpt_calcheight))
     SET d0 = glucosehead(rpt_render)
     FOR (ml_cnt2 = 1 TO size(m_rec->pats[ml_cnt].bg,5))
      CALL break_check(glucosedetail(rpt_calcheight))
      SET d0 = glucosedetail(rpt_render)
     ENDFOR
    ENDIF
    IF (size(m_rec->pats[ml_cnt].er_visits,5) > 0)
     CALL break_check(ervisithead(rpt_calcheight))
     SET d0 = ervisithead(rpt_render)
     FOR (ml_cnt2 = 1 TO size(m_rec->pats[ml_cnt].er_visits,5))
      CALL break_check(ervisitdetail(rpt_calcheight))
      SET d0 = ervisitdetail(rpt_render)
     ENDFOR
    ENDIF
    IF (size(m_rec->pats[ml_cnt].hosps,5) > 0)
     CALL break_check(hospitalizationhead(rpt_calcheight))
     SET d0 = hospitalizationhead(rpt_render)
     FOR (ml_cnt2 = 1 TO size(m_rec->pats[ml_cnt].hosps,5))
      CALL break_check(hospitalizationdetail(rpt_calcheight))
      SET d0 = hospitalizationdetail(rpt_render)
     ENDFOR
    ENDIF
  ENDFOR
  SET _yoffset = 10.08
  SET d0 = footpage(rpt_render)
  SET d0 = finalizereport(ms_output)
 ENDIF
 IF (((textlen(trim( $S_RECIPIENTS,3)) > 1) OR (mn_ops=1)) )
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_output,ms_output,concat('"',ms_recipients,'"'),ms_subject,1)
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
