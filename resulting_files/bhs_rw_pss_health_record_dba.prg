CREATE PROGRAM bhs_rw_pss_health_record:dba
 PROMPT
  "Enter Output Destination: " = "MINE",
  "Enter PowerNote EVENT_ID: " = 0.00,
  "encounter id" = 0
  WITH prompt1, prompt2, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 f_person_id = f8
   1 f_encntr_id = f8
   1 s_fin = vc
   1 s_pat_name = vc
   1 s_pat_gender = vc
   1 s_pat_dob = vc
   1 n_under_6_ind = i2
   1 s_form_dt_tm = vc
   1 f_prsnl_id = f8
   1 s_prsnl_name = vc
   1 f_med_hist_blob_id = f8
   1 s_med_hist = vc
   1 f_fam_hist_blob_id = f8
   1 s_fam_hist = vc
   1 n_allergy_ind = i2
   1 s_allergy_line = vc
   1 n_anaphylaxis_ind = i2
   1 s_anaphylaxis_hist = vc
   1 n_epi_pen_ind = i2
   1 n_asthma_ind = i2
   1 n_asthma_plan_ind = i2
   1 n_diabetes_ind = i2
   1 n_diabetes_type = i2
   1 n_seizure_ind = i2
   1 s_seizure_disorder = vc
   1 s_cur_health_other = vc
   1 s_exam_dt = vc
   1 s_height = vc
   1 s_weight = vc
   1 s_bmi = vc
   1 s_bp = vc
   1 s_sys_bp = vc
   1 s_dias_bp = vc
   1 s_pulse = vc
   1 n_exam_passed_ind = i2
   1 s_exam_notes = vc
   1 n_left_eye_pass_ind = i2
   1 n_right_eye_pass_ind = i2
   1 n_both_eyes_pass_ind = i2
   1 n_left_ear_pass_ind = i2
   1 n_right_ear_pass_ind = i2
   1 n_stereopsis_pass_ind = i2
   1 n_posture_pass_ind = i2
   1 f_lead_event_id = f8
   1 s_lead_result = vc
   1 s_lead_date = vc
   1 f_hgb_event_id = f8
   1 s_hgb_date = vc
   1 s_hgb_result = vc
   1 n_urine_pass_ind = i2
   1 n_other_ind = i2
   1 s_other_notes = vc
   1 n_tb_pos_ind = i2
   1 n_participate_ind = i2
   1 s_participate_notes = vc
   1 n_immun_comp_ind = i2
   1 s_immun_notes = vc
   1 s_location = vc
   1 s_group = vc
   1 s_phone = vc
   1 s_address = vc
   1 s_city = vc
   1 s_state = vc
   1 s_zip = vc
   1 s_date = vc
 )
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_rea_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_true_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15751,"TRUE"))
 DECLARE mf_bld_lead_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODLEADPEDI15YR"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHTLBOZ"))
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_sys_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_dias_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_pulse_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE mf_hgb_results_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "POCHGBRESULTS"))
 DECLARE mf_lead_res_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODLEADSPECTYPEPEDI15YR"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_output = vc WITH protect, noconstant( $1)
 DECLARE mf_form_event_id = f8 WITH protect, noconstant(cnvtreal( $2))
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(cnvtreal( $F_ENCNTR_ID))
 EXECUTE reportrtl
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times8i0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times10bi0 = i4 WITH noconstant(0), protect
 DECLARE _times10bu0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (report_section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (report_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE __name = vc WITH noconstant(build2(m_info->s_pat_name,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(m_info->s_pat_dob,char(0))), protect
   DECLARE __height = vc WITH noconstant(build2(m_info->s_height,char(0))), protect
   DECLARE __bp = vc WITH noconstant(build2(m_info->s_bp,char(0))), protect
   DECLARE __bmi = vc WITH noconstant(build2(m_info->s_bmi,char(0))), protect
   DECLARE __weight = vc WITH noconstant(build2(m_info->s_weight,char(0))), protect
   DECLARE __exam_date = vc WITH noconstant(build2(m_info->s_exam_dt,char(0))), protect
   DECLARE __female_check = vc WITH noconstant(build2(
     IF (trim(m_info->s_pat_gender)="F") "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __male_check = vc WITH noconstant(build2(
     IF (trim(m_info->s_pat_gender)="M") "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __asthma_action_yes2 = vc WITH noconstant(build2(
     IF ((m_info->n_exam_passed_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __exam_comments = vc WITH noconstant(build2(m_info->s_exam_notes,char(0))), protect
   DECLARE __both_eyes_pass = vc WITH noconstant(build2(
     IF ((m_info->n_stereopsis_pass_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __left_eye_pass = vc WITH noconstant(build2(
     IF ((m_info->n_left_eye_pass_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __right_eye_pass = vc WITH noconstant(build2(
     IF ((m_info->n_right_eye_pass_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __posture_pass = vc WITH noconstant(build2(
     IF ((m_info->n_posture_pass_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __left_ear_pass = vc WITH noconstant(build2(
     IF ((m_info->n_left_ear_pass_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __allergy_y = vc WITH noconstant(build2(
     IF ((m_info->n_allergy_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __posture_fail = vc WITH noconstant(build2(
     IF ((m_info->n_posture_pass_ind=2)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __left_ear_fail = vc WITH noconstant(build2(
     IF ((m_info->n_left_ear_pass_ind=2)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __right_ear_fail = vc WITH noconstant(build2(
     IF ((m_info->n_allergy_ind=1)) ""
     ELSE "X"
     ENDIF
     ,char(0))), protect
   DECLARE __both_eyes_fail = vc WITH noconstant(build2(
     IF ((m_info->n_stereopsis_pass_ind=2)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __left_eye_fail = vc WITH noconstant(build2(
     IF ((m_info->n_left_eye_pass_ind=2)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __right_eye_fail = vc WITH noconstant(build2(
     IF ((m_info->n_right_eye_pass_ind=2)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __group = vc WITH noconstant(build2(m_info->s_group,char(0))), protect
   DECLARE __state = vc WITH noconstant(build2(m_info->s_state,char(0))), protect
   DECLARE __city = vc WITH noconstant(build2(m_info->s_city,char(0))), protect
   DECLARE __zip = vc WITH noconstant(build2(m_info->s_zip,char(0))), protect
   DECLARE __phone = vc WITH noconstant(build2(m_info->s_phone,char(0))), protect
   DECLARE __address = vc WITH noconstant(build2(m_info->s_address,char(0))), protect
   DECLARE __lead_result = vc WITH noconstant(build2(m_info->s_lead_result,char(0))), protect
   DECLARE __lead_date = vc WITH noconstant(build2(m_info->s_lead_date,char(0))), protect
   DECLARE __hdb_result = vc WITH noconstant(build2(m_info->s_hgb_result,char(0))), protect
   DECLARE __hgb_date = vc WITH noconstant(build2(m_info->s_hgb_date,char(0))), protect
   DECLARE __urine_pos = vc WITH noconstant(build2(
     IF ((m_info->n_urine_pass_ind=1)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __urine_neg = vc WITH noconstant(build2(
     IF ((m_info->n_urine_pass_ind=2)) "X"
     ELSE ""
     ENDIF
     ,char(0))), protect
   DECLARE __pulse = vc WITH noconstant(build2(m_info->s_pulse,char(0))), protect
   DECLARE __examiner_name = vc WITH noconstant(build2(m_info->s_prsnl_name,char(0))), protect
   DECLARE __sdate = vc WITH noconstant(build2(m_info->s_date,char(0))), protect
   DECLARE __allergies = vc WITH noconstant(build2(m_info->s_allergy_line,char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 1.563),7.500,1.938,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.188),(offsety+ 5.005),(offsetx+ 6.251),(offsety+
     5.005))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.438),7.500,0.625,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Male",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.000),7.500,0.438,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MASSACHUSETTS SCHOOL HEALTH RECORD",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Health Care Provider Examination",
      char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 1.063),7.500,0.500,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medical History:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.688),(offsety+ 0.630),(offsetx+ 3.751),(offsety+
     0.630))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Female",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.125),(offsety+ 0.630),(offsetx+ 7.376),(offsety+
     0.630))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pertinent Family History:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Current Health Issues:",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Y",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("N",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.251)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("History of Anaphlyaxis",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.501)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Asthma Action Plan",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.251)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Other (Please specify)",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.001)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Seizure disorder:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diabetes:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.501)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Asthma:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.501)
    SET rptsd->m_x = (offsetx+ 3.563)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.501)
    SET rptsd->m_x = (offsetx+ 2.938)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type II",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 1.626)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type I",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),(offsety+ 2.130),(offsetx+ 7.376),(offsety+
     2.130))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.251)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Epi-Pen",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.251)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.251)
    SET rptsd->m_x = (offsetx+ 6.563)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.063),(offsety+ 2.380),(offsetx+ 5.751),(offsety+
     2.380))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.626),(offsety+ 3.130),(offsetx+ 7.376),(offsety+
     3.130))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.938),(offsety+ 3.380),(offsetx+ 7.376),(offsety+
     3.380))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.500),7.500,0.688,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.563)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Current Medications (if relevant to the student's health and safety)",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.563)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 3.126
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Please circle those administered in school; a separate",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.751)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 7.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "medication order form is needed for each medication adminstered in school.",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 4.188),7.500,2.438,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physical Examination",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Examination:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.500),(offsety+ 4.380),(offsetx+ 7.376),(offsety+
     4.380))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hgt:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Wgt:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMI:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BP:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.438),(offsety+ 4.630),(offsetx+ 1.501),(offsety+
     4.630))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.001),(offsety+ 4.630),(offsetx+ 3.064),(offsety+
     4.630))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.688),(offsety+ 4.630),(offsetx+ 4.751),(offsety+
     4.630))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.188),(offsety+ 4.630),(offsetx+ 6.251),(offsety+
     4.630))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__height)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bp)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bmi)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__weight)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.188)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__exam_date)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__female_check)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__male_check)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.688)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.751
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("The entire examination was normal:",
      char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.688)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__asthma_action_yes2)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.875)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(If abnormal, please describe)",char(
       0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.063)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 7.250
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__exam_comments)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.125),(offsety+ 5.380),(offsetx+ 7.376),(offsety+
     5.380))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.438)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Screening:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vision:",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Right Eye",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hearing:",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Stereopsis",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Left Eye",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__both_eyes_pass)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__left_eye_pass)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__right_eye_pass)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__posture_pass)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__left_ear_pass)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__allergy_y)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Postural Screening",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Left Ear",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Right Ear",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Scoliosis/Kyphosis/Lordosis)",char(0
       )))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.438)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Pass)  (Fail)",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Laboratory Results:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Lead",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.751),(offsety+ 6.568),(offsetx+ 2.251),(offsety+
     6.568))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.251),(offsety+ 6.568),(offsetx+ 3.751),(offsety+
     6.568))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__posture_fail)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__left_ear_fail)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__right_ear_fail)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 1.751)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__both_eyes_fail)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 1.751)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__left_eye_fail)
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 1.751)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__right_eye_fail)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.438)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Pass)  (Fail)",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 6.625),7.500,0.938,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.688)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 6.375
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "This student has the following problems that may impact his/her educational experience:",char(
       0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.875)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vision",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.875)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fine/Gross Motor Deficit",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Other",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.875)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Speech/Language",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 2.126)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Behavior",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.875)
    SET rptsd->m_x = (offsetx+ 2.126)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hearing",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.125)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Emotional/Social",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.313)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Comments/Recommendations:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.813),(offsety+ 7.505),(offsetx+ 7.376),(offsety+
     7.505))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 7.563),7.500,0.500,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.625)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 6.438
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "This student may participate fully in the school program, including physical education and competitive",
      char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.625)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Y",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.625)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("N",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "sports.  If no, please list restrictions:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.438),(offsety+ 8.005),(offsetx+ 7.438),(offsety+
     8.005))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 8.063),7.500,0.500,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.126)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Immunizations are complete (please attach complete immunization record).  If not, give reason:",
      char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.126)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Y",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.126)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("N",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 8.505),(offsetx+ 7.438),(offsety+
     8.505))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 8.563),7.500,1.438,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 8.818),(offsetx+ 3.751),(offsety+
     8.818))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),(offsety+ 8.818),(offsetx+ 7.438),(offsety+
     8.818))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 9.193),(offsetx+ 7.438),(offsety+
     9.193))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 9.568),(offsetx+ 7.438),(offsety+
     9.568))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Signature of Examiner",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.813)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Circle",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.813)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MD, DO, NP, PA",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.813)
    SET rptsd->m_x = (offsetx+ 2.938)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.813)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 3.001
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Please print name of Examiner",char(0
       )))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Group Practice",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.188)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Telephone",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.563)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Zip Code",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 5.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times8i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Please attach additional information as needed for the health and safety of the student.",char
      (0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.563)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("State",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.563)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("City",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.001)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__group)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__state)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__city)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__zip)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.001)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__phone)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.376)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 3.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__address)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 4.313)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hgb",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.688),(offsety+ 6.568),(offsetx+ 5.563),(offsety+
     6.568))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.375),(offsety+ 6.568),(offsetx+ 6.876),(offsety+
     6.568))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.125),(offsety+ 6.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.438),(offsety+ 6.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.688),(offsety+ 7.125),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.688),(offsety+ 6.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.876),(offsety+ 7.125),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.876),(offsety+ 6.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.125),(offsety+ 7.125),0.188,0.177,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 1.751)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lead_result)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lead_date)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hdb_result)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 6.375)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hgb_date)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__urine_pos)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Urinalysis",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.625)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__urine_neg)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.438)
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(Pos) (Neg)",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pulse:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pulse)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.375),(offsety+ 3.000),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.375),(offsety+ 2.750),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.375),(offsety+ 2.500),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.375),(offsety+ 2.250),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.125),(offsety+ 3.000),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.125),(offsety+ 2.750),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.125),(offsety+ 2.500),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.125),(offsety+ 2.250),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.188),(offsety+ 2.750),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.375),(offsety+ 2.750),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.313),(offsety+ 2.500),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.688),(offsety+ 2.500),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 6.875),(offsety+ 2.250),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 6.313),(offsety+ 2.250),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.063),(offsety+ 7.625),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.500),(offsety+ 7.625),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.063),(offsety+ 8.125),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.500),(offsety+ 8.125),0.188,0.177,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.626)
    SET rptsd->m_x = (offsetx+ 4.313)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__examiner_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.626)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sdate)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TB Screen",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Y",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("N",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 5.875)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Low Risk",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 6.875),(offsety+ 5.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 6.063),(offsety+ 5.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.563),(offsety+ 5.875),0.188,0.177,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__allergies)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RW_PSS_HEALTH_RECORD"
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
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_underline = rpt_on
   SET _times10bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_underline = rpt_off
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_on
   SET _times10bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _times8i0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 IF (trim(ms_output) <= " ")
  SET retval = - (1)
  SET log_message = build2("No output destination passed in (",trim(ms_output),"). Exiting script.")
  GO TO exit_script
 ENDIF
 IF (mf_form_event_id <= 0.00)
  SET log_message = build2("No event_id passed in (",trim(cnvtstring(mf_form_event_id)),").")
 ENDIF
 CALL echo("main select")
 CALL echo("get person info")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin_cd)) )
  HEAD p.person_id
   m_info->f_person_id = p.person_id, m_info->s_pat_name = trim(p.name_full_formatted,3), m_info->
   f_encntr_id = e.encntr_id,
   m_info->s_fin = trim(ea.alias)
   IF (p.sex_cd=mf_male_cd)
    m_info->s_pat_gender = "M"
   ELSEIF (p.sex_cd=mf_female_cd)
    m_info->s_pat_gender = "F"
   ENDIF
   m_info->s_pat_dob = trim(format(p.birth_dt_tm,"mmmmmmmmm dd, yyyy;;d"),3)
   IF (datetimecmp(cnvtdatetime(curdate,0),p.birth_dt_tm) <= 2192)
    m_info->n_under_6_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get clinical events")
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=m_info->f_person_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_mod_cd)
    AND ce.event_cd IN (mf_height_cd, mf_weight_cd, mf_bmi_cd, mf_sys_bp_cd, mf_dias_bp_cd,
   mf_pulse_cd, mf_hgb_results_cd, mf_lead_res_cd))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.event_cd
   pl_cnt += 1, ms_result = trim(ce.result_val), ms_result_unit = trim(uar_get_code_display(ce
     .result_units_cd))
   IF (((pl_cnt=1) OR (ce.event_end_dt_tm > cnvtdatetime(m_info->s_exam_dt))) )
    m_info->s_exam_dt = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"))
   ENDIF
   CASE (ce.event_cd)
    OF mf_height_cd:
     IF (trim(ms_result_unit)="cm")
      ms_result = cnvtstring((cnvtreal(ms_result) * 0.393700787)), ms_result_unit = "in"
     ENDIF
     ,m_info->s_height = concat(trim(ms_result)," ",trim(ms_result_unit))
    OF mf_weight_cd:
     m_info->s_weight = concat(trim(ms_result)," ",trim(ms_result_unit))
    OF mf_bmi_cd:
     m_info->s_bmi = trim(ms_result)
    OF mf_sys_bp_cd:
     m_info->s_sys_bp = trim(ms_result)
    OF mf_dias_bp_cd:
     m_info->s_dias_bp = trim(ms_result)
    OF mf_pulse_cd:
     m_info->s_pulse = concat(trim(ms_result)," ",trim(ms_result_unit))
    OF mf_hgb_results_cd:
     m_info->s_hgb_result = ms_result,m_info->s_hgb_date = trim(format(ce.event_end_dt_tm,
       "mm/dd/yy;;d"))
    OF mf_lead_res_cd:
     m_info->s_lead_result = ms_result,m_info->s_lead_date = trim(format(ce.event_end_dt_tm,
       "mm/dd/yy;;d"))
   ENDCASE
  FOOT REPORT
   IF ((m_info->s_sys_bp > " ")
    AND (m_info->s_dias_bp > " "))
    m_info->s_bp = build2(m_info->s_sys_bp,"/",m_info->s_dias_bp)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get allergies")
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n
  PLAN (a
   WHERE (a.person_id=m_info->f_person_id)
    AND a.active_status_cd=mf_active_cd
    AND a.reaction_status_cd=mf_rea_active_cd
    AND a.active_ind=1
    AND a.end_effective_dt_tm >= sysdate)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id
    AND trim(n.source_string) != "NKA")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   CALL echo(n.source_string), pl_cnt += 1
   IF (pl_cnt=1)
    m_info->s_allergy_line = trim(n.source_string)
   ELSE
    m_info->s_allergy_line = concat(m_info->s_allergy_line,", ",trim(n.source_string))
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET m_info->n_allergy_ind = 1
 ENDIF
 SET m_info->s_date = trim(format(sysdate,"mm/dd/yy;;d"))
 IF (cnvtupper(substring(1,3,m_info->s_fin))="PSS")
  SET m_info->s_location = "ELONGMEADOW"
  SET m_info->s_group = "Pediatric Services of Springfield"
  SET m_info->s_phone = "(413) 525-1870"
  SET m_info->s_address = "250 North Main St"
  SET m_info->s_city = "East Longmeadow"
  SET m_info->s_state = "MA"
  SET m_info->s_zip = "01028"
 ENDIF
 IF (mf_form_event_id > 0.00)
  CALL echo("event_id > 0")
  SELECT INTO "nl:"
   FROM scd_story ss,
    scd_term st,
    scr_term_text stt,
    scd_term_data std
   PLAN (ss
    WHERE ss.event_id=mf_form_event_id)
    JOIN (st
    WHERE st.scd_story_id=ss.scd_story_id)
    JOIN (stt
    WHERE stt.scr_term_id=st.scr_term_id
     AND stt.definition > " ")
    JOIN (std
    WHERE (std.scd_term_data_id= Outerjoin(st.scd_term_data_id)) )
   HEAD REPORT
    pl_cnt = 0
   HEAD ss.scd_story_id
    m_info->f_person_id = ss.person_id, m_info->f_encntr_id = ss.encounter_id, m_info->s_form_dt_tm
     = trim(format(ss.active_status_dt_tm,"mmmmmmmmm-dd-yyyy;;d")),
    m_info->f_prsnl_id = ss.author_id
   HEAD st.scd_term_id
    pn_true_ind = 0
   DETAIL
    pn_true_ind = 0
    IF (st.truth_state_cd=mf_true_cd)
     pn_true_ind = 1
    ENDIF
    CASE (trim(stt.definition))
     OF "FT_MED_HX":
      IF (std.fkey_entity_name="SCD_BLOB"
       AND std.scd_term_data_key <= " ")
       m_info->f_med_hist_blob_id = std.fkey_id
      ENDIF
     OF "FT_FAM_HX":
      IF (std.fkey_entity_name="SCD_BLOB"
       AND std.scd_term_data_key <= " ")
       m_info->f_fam_hist_blob_id = std.fkey_id
      ENDIF
     OF "ANAPHYLAXIS_HX":
      m_info->n_anaphylaxis_ind = pn_true_ind
     OF "ANAPHYLAXIS_NOTES":
      m_info->s_anaphylaxis_hist = trim(std.value_text)
     OF "EPI_PEN":
      m_info->n_epi_pen_ind = pn_true_ind
     OF "ASTHMA":
      m_info->n_asthma_ind = pn_true_ind
     OF "ASTHMA_PLAN":
      m_info->n_asthma_plan_ind = pn_true_ind
     OF "DIABETES":
      m_info->n_diabetes_ind = pn_true_ind
     OF "DIABETES TYPE I":
      m_info->n_diabetes_type = 1
     OF "DIABETES TYPE II":
      m_info->n_diabetes_type = 2
     OF "SEIZURE":
      m_info->n_seizure_ind = pn_true_ind
     OF "CUR_HEALTH_OTHER":
      m_info->s_cur_health_other = trim(std.value_text)
     OF "RIGHT_EYE_PASSED":
      m_info->n_right_eye_pass_ind = pn_true_ind
     OF "RIGHT_EYE_REFERRED":
      IF (pn_true_ind=1)
       m_info->n_right_eye_pass_ind = 2
      ENDIF
     OF "LEFT_EYE_PASSED":
      m_info->n_left_eye_pass_ind = pn_true_ind
     OF "LEFT_EYE_REFERRED":
      IF (pn_true_ind=1)
       m_info->n_left_eye_pass_ind = 2
      ENDIF
     OF "STEREOPSIS":
      m_info->n_stereopsis_pass_ind = pn_true_ind
     OF "RIGHT_EAR_PASSED":
      m_info->n_right_ear_pass_ind = pn_true_ind
     OF "RIGHT_EAR_REFERRED":
      IF (pn_true_ind=1)
       m_info->n_right_ear_pass_ind = 2
      ENDIF
     OF "LEFT_EAR_PASSED":
      m_info->n_left_ear_pass_ind = pn_true_ind
     OF "LEFT_EAR_REFERRED":
      IF (pn_true_ind=1)
       m_info->n_left_ear_pass_ind = 2
      ENDIF
     OF "POSTURAL_SCREENING_PASSED":
      m_info->n_posture_pass_ind = pn_true_ind
     OF "POSTURAL_SCREENING_REFERRED":
      IF (pn_true_ind=1)
       m_info->n_posture_pass_ind = 2
      ENDIF
     OF "EXAM_DATE":
      m_info->s_exam_dt = trim(format(std.value_dt_tm,"MMMMMMMMM DD, YYYY;;D"),3)
     OF "EXAM_PASSED_IND":
      m_info->n_exam_passed_ind = pn_true_ind
     OF "EXAM_NOTES":
      m_info->s_exam_notes = trim(std.value_text)
     OF "IMMUN_COMPLETE_IND":
      m_info->n_immun_comp_ind = pn_true_ind
     OF "IMMUN_NOTES":
      m_info->s_immun_notes = trim(std.value_text)
     OF "LEAD":
      IF (std.fkey_entity_name="CLINICAL_EVENT")
       m_info->f_lead_event_id = std.fkey_id
      ENDIF
     OF "HGB":
      IF (std.fkey_entity_name="CLINICAL_EVENT")
       m_info->f_hgb_event_id = std.fkey_id
      ENDIF
     OF "URINE_POS":
      m_info->n_urine_pass_ind = pn_true_ind
     OF "URINE_NEG":
      IF (pn_true_ind=1)
       m_info->n_urine_pass_ind = 2
      ENDIF
     OF "PARTICIPATE_IND":
      m_info->n_participate_ind = pn_true_ind
     OF "PARTICIPATE_NOTES":
      m_info->s_participate_notes = trim(std.value_text)
     OF "ELONGMEADOW":
      m_info->s_location = "ELONGMEADOW",m_info->s_group = "Pediatric Services of Springfield",m_info
      ->s_phone = "(413) 525-1870",
      m_info->s_address = "250 North Main St",m_info->s_city = "East Longmeadow",m_info->s_state =
      "MA",
      m_info->s_zip = "01028"
     OF "WILBRAHAM":
      m_info->s_location = "WILBRAHAM",m_info->s_group = "Pediatric Services of Springfield",m_info->
      s_phone = "(413) 525-1870",
      m_info->s_address = "35 Post Office Park",m_info->s_city = "Wilbraham",m_info->s_state = "MA",
      m_info->s_zip = "01095"
     OF "GREENFIELD":
      m_info->s_location = "GREENFIELD",m_info->s_group = "Baystate Greenfield Pediatrics",m_info->
      s_phone = "(413) 773-2042",
      m_info->s_address = "48 Sanderson Street",m_info->s_city = "Greenfield",m_info->s_state = "MA",
      m_info->s_zip = "01301"
     OF "PVFAMILY":
      m_info->s_location = "PVFAMILY",m_info->s_group = "Baystate Pioneer Valley Family Medicine",
      m_info->s_phone = "(413) 387-4100",
      m_info->s_address = "118 Conz Street",m_info->s_city = "Northampton",m_info->s_state = "MA",
      m_info->s_zip = "01060"
     OF "DEERFIELD":
      m_info->s_location = "DEERFIELD",m_info->s_group = "Baystate Deerfield Pediatrics",m_info->
      s_phone = "(413) 665-7805",
      m_info->s_address = "434 State Road",m_info->s_city = "Whately",m_info->s_state = "MA",
      m_info->s_zip = "01093"
     OF "BRIGHTWOOD":
      m_info->s_location = "BRIGHTWOOD",m_info->s_group = "Baystate Brightwood Health Center",m_info
      ->s_phone = "(413) 794-4458",
      m_info->s_address = "380 Plainfield Street",m_info->s_city = "Springfield",m_info->s_state =
      "MA",
      m_info->s_zip = "01119"
     OF "MASONSQUARE":
      m_info->s_location = "MASONSQUARE",m_info->s_group =
      "Baystate Mason Square Neighborhood Health Center",m_info->s_phone = "(413) 794-3710",
      m_info->s_address = "11 Wilbraham Road",m_info->s_city = "Springfield",m_info->s_state = "MA",
      m_info->s_zip = "01119"
     OF "GENERALPEDI":
      m_info->s_location = "GENERALPEDI",m_info->s_group = "Baystate General Pediatrics",m_info->
      s_phone = "(413) 794-0816",
      m_info->s_address = "3300 Main Street",m_info->s_city = "Springfield",m_info->s_state = "MA",
      m_info->s_zip = "01199"
     OF "HIGHST":
      m_info->s_location = "HIGHST",m_info->s_group = "Baystate High Street Health Center",m_info->
      s_phone = "(413) 794-2515",
      m_info->s_address = "140 High Street",m_info->s_city = "Springfield",m_info->s_state = "MA",
      m_info->s_zip = "01199"
     OF "QUABBIN":
      m_info->s_location = "QUABBIN",m_info->s_group = "Baystate Quabbin Pediatrics",m_info->s_phone
       = "(413) 967-2040",
      m_info->s_address = "83 South Street, Suite 112",m_info->s_city = "Ware",m_info->s_state = "MA",
      m_info->s_zip = "01082"
     OF "OFFICE_OTHER":
      m_info->s_location = "OTHER"
     OF "GROUP":
      m_info->s_group = trim(std.value_text)
     OF "PHONE":
      m_info->s_phone = trim(std.value_text)
     OF "ADDRESS":
      m_info->s_address = trim(std.value_text)
     OF "CITY":
      m_info->s_city = trim(std.value_text)
     OF "STATE":
      m_info->s_state = trim(std.value_text)
     OF "ZIP":
      m_info->s_zip = trim(std.value_text)
    ENDCASE
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=m_info->f_prsnl_id)
     AND p.active_ind=1
     AND p.end_effective_dt_tm > sysdate)
   HEAD p.person_id
    m_info->s_prsnl_name = trim(p.name_full_formatted,3)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   textlen_lb_long_blob = textlen(lb.long_blob)
   FROM long_blob lb
   PLAN (lb
    WHERE lb.parent_entity_id IN (m_info->f_fam_hist_blob_id, m_info->f_med_hist_blob_id)
     AND lb.parent_entity_id > 0.00
     AND lb.parent_entity_name="SCD_BLOB")
   HEAD REPORT
    ps_blob_out = fillstring(32000," ")
   HEAD lb.parent_entity_id
    CALL uar_rtf(lb.long_blob,textlen_lb_long_blob,ps_blob_out,32000,32000,0)
    IF ((lb.parent_entity_id=m_info->f_fam_hist_blob_id))
     m_info->s_fam_hist = trim(ps_blob_out,3)
    ELSEIF ((lb.parent_entity_id=m_info->f_med_hist_blob_id))
     m_info->s_med_hist = trim(ps_blob_out,3)
    ENDIF
   WITH nocounter
  ;end select
  IF ((((m_info->f_lead_event_id > 0.00)) OR ((m_info->f_hgb_event_id > 0.00))) )
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.event_id IN (m_info->f_lead_event_id, m_info->f_hgb_event_id)
      AND ce.event_id > 0.00)
    DETAIL
     IF ((ce.event_id=m_info->f_lead_event_id))
      m_info->s_lead_date = trim(format(ce.event_end_dt_tm,"mm-dd-yy;;d")), m_info->s_lead_result =
      build2(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)))
     ELSEIF ((ce.event_id=m_info->f_hgb_event_id))
      m_info->s_hgb_date = trim(format(ce.event_end_dt_tm,"mm-dd-yy;;d")), m_info->s_hgb_result =
      build2(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)))
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL echo("set output location")
  IF (ms_output="discern")
   IF ((m_info->s_location="E"))
    SET ms_output = "ponpsselong1"
   ELSEIF ((m_info->s_location="W"))
    SET ms_output = "ponpsswilb1"
   ELSE
    SET retval = 0
    SET log_message = "Other Office used - printer unknown. Exiting Script"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET d0 = report_section(rpt_render)
 SET d0 = finalizereport(value(ms_output))
 SET retval = 100
#exit_script
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
