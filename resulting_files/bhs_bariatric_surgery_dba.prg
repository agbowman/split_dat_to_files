CREATE PROGRAM bhs_bariatric_surgery:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Patient MRN:" = "",
  "Select Patient:" = 0,
  "Education Seminar:" = "CURDATE",
  "education seminar ft" = "",
  "MWM Referral:" = "CURDATE",
  "MWM Referral FT" = "",
  "Labs:" = "CURDATE",
  "Labs ft" = "",
  "H Pylori:" = "CURDATE",
  "H Pylori ft" = "",
  "Treatment Completed:" = "CURDATE",
  "treatment completed ft" = "",
  "BNP Nutrition" = "CURDATE",
  "BNP Nutrition ft" = "",
  "BNP PA" = "CURDATE",
  "BNP PA ft" = "",
  "BSV" = "CURDATE",
  "BSV ft" = "",
  "Nutrition Clearance:" = "CURDATE",
  "Nutrition Clearance ft" = "",
  "Initial Psych Visit" = "CURDATE",
  "Initial Psych Visit ft" = "",
  "Psych Clearance:" = "CURDATE",
  "Psych Clearance ft" = "",
  "Sleep Clearance:" = "CURDATE",
  "Sleep Clearance ft" = "",
  "US" = "CURDATE",
  "US ft" = "",
  "Barium Swallow:" = "CURDATE",
  "Barium Swallow ft" = "",
  "Authorized:" = "CURDATE",
  "Authorized ft" = "",
  "OR" = "CURDATE",
  "OR ft" = "",
  "Comments:" = ""
  WITH outdev, s_mrn, f_person_id,
  s_education_seminar_dt, s_education_seminar_ft, s_mwm_referral_dt,
  s_mwm_referral_ft, s_labs_dt, s_labs_ft,
  s_h_pylori_dt, s_h_pylori_ft, s_treatment_completed_dt,
  s_treatment_completed_ft, s_bnp_nutrition_dt, s_bnp_nutrition_ft,
  s_bnp_pa_dt, s_bnp_pa_ft, s_bsv_dt,
  s_bsv_ft, s_nutrition_clearance_dt, s_nutrition_clearance_ft,
  s_initial_psych_visit_dt, s_initial_psych_visit_ft, s_psych_clearance_dt,
  s_psych_clearance_ft, s_sleep_clearance_dt, s_sleep_clearance_ft,
  s_us_dt, s_us_ft, s_barium_swallow_dt,
  s_barium_swallow_ft, s_authorized_dt, s_authorized_ft,
  s_or_dt, s_or_ft, s_comments
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line(ncalc=i2) = f8 WITH protect
 DECLARE sec_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_detail(ncalc=i2) = f8 WITH protect
 DECLARE sec_detailabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
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
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
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
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE sec_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __s_action = vc WITH noconstant(build2(
     IF (mn_upd_ind=1) "Record Updated"
     ELSE "Record Inserted"
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_action)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_pat_name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_mrn,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 0.032),(offsetx+ 7.542),(offsety+
     0.032))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_detail(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_detailabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(6.340000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Education Seminar:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_education_seminar_dt,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_education_seminar_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MWM Referral:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_mwm_referral_dt,char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_mwm_referral_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Labs:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_labs_dt,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_labs_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("H Pylori:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_h_pylori_dt,char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_h_pylori_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Treatment Completed:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_treatment_completed_dt,char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_treatment_completed_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BNP Nutrition:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_bnp_nutrition_dt,char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_bnp_nutrition_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BNP PA:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_bnp_pa_dt,char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_bnp_pa_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BSV:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_bsv_dt,char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_bsv_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nutrition Clearance:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_nutrition_clearance_dt,char(0)))
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_nutrition_clearance_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Initial Psych Visit:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_initial_psych_visit_dt,char(0)))
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_initial_psych_visit_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Psych Clearance:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_psych_clearance_dt,char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_psych_clearance_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sleep Clearance:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_sleep_clearance_dt,char(0)))
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_sleep_clearance_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("U/S:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_us_dt,char(0)))
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_us_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Barium Swallow:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_barium_swallow_dt,char(0)))
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_barium_swallow_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Authorized:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_authorized_dt,char(0)))
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_authorized_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("OR:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_or_dt,char(0)))
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_or_ft,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 4.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Comments:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 4.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_comments,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_BARIATRIC_SURGERY"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
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
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE ms_mrn = vc WITH protect, constant( $S_MRN)
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE ms_education_seminar_dt = vc WITH protect, constant( $S_EDUCATION_SEMINAR_DT)
 DECLARE ms_education_seminar_ft = vc WITH protect, constant( $S_EDUCATION_SEMINAR_FT)
 DECLARE ms_mwm_referral_dt = vc WITH protect, constant( $S_MWM_REFERRAL_DT)
 DECLARE ms_mwm_referral_ft = vc WITH protect, constant( $S_MWM_REFERRAL_FT)
 DECLARE ms_labs_dt = vc WITH protect, constant( $S_LABS_DT)
 DECLARE ms_labs_ft = vc WITH protect, constant( $S_LABS_FT)
 DECLARE ms_h_pylori_dt = vc WITH protect, constant( $S_H_PYLORI_DT)
 DECLARE ms_h_pylori_ft = vc WITH protect, constant( $S_H_PYLORI_FT)
 DECLARE ms_treatment_completed_dt = vc WITH protect, constant( $S_TREATMENT_COMPLETED_DT)
 DECLARE ms_treatment_completed_ft = vc WITH protect, constant( $S_TREATMENT_COMPLETED_FT)
 DECLARE ms_bnp_nutrition_dt = vc WITH protect, constant( $S_BNP_NUTRITION_DT)
 DECLARE ms_bnp_nutrition_ft = vc WITH protect, constant( $S_BNP_NUTRITION_FT)
 DECLARE ms_bnp_pa_dt = vc WITH protect, constant( $S_BNP_PA_DT)
 DECLARE ms_bnp_pa_ft = vc WITH protect, constant( $S_BNP_PA_FT)
 DECLARE ms_bsv_dt = vc WITH protect, constant( $S_BSV_DT)
 DECLARE ms_bsv_ft = vc WITH protect, constant( $S_BSV_FT)
 DECLARE ms_nutrition_clearance_dt = vc WITH protect, constant( $S_NUTRITION_CLEARANCE_DT)
 DECLARE ms_nutrition_clearance_ft = vc WITH protect, constant( $S_NUTRITION_CLEARANCE_FT)
 DECLARE ms_initial_psych_visit_dt = vc WITH protect, constant( $S_INITIAL_PSYCH_VISIT_DT)
 DECLARE ms_initial_psych_visit_ft = vc WITH protect, constant( $S_INITIAL_PSYCH_VISIT_FT)
 DECLARE ms_psych_clearance_dt = vc WITH protect, constant( $S_PSYCH_CLEARANCE_DT)
 DECLARE ms_psych_clearance_ft = vc WITH protect, constant( $S_PSYCH_CLEARANCE_FT)
 DECLARE ms_sleep_clearance_dt = vc WITH protect, constant( $S_SLEEP_CLEARANCE_DT)
 DECLARE ms_sleep_clearance_ft = vc WITH protect, constant( $S_SLEEP_CLEARANCE_FT)
 DECLARE ms_us_dt = vc WITH protect, constant( $S_US_DT)
 DECLARE ms_us_ft = vc WITH protect, constant( $S_US_FT)
 DECLARE ms_barium_swallow_dt = vc WITH protect, constant( $S_BARIUM_SWALLOW_DT)
 DECLARE ms_barium_swallow_ft = vc WITH protect, constant( $S_BARIUM_SWALLOW_FT)
 DECLARE ms_authorized_dt = vc WITH protect, constant( $S_AUTHORIZED_DT)
 DECLARE ms_authorized_ft = vc WITH protect, constant( $S_AUTHORIZED_FT)
 DECLARE ms_or_dt = vc WITH protect, constant( $S_OR_DT)
 DECLARE ms_or_ft = vc WITH protect, constant( $S_OR_FT)
 DECLARE ms_comments = vc WITH protect, constant( $S_COMMENTS)
 DECLARE mn_upd_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_pat_name = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM bhs_bariatric_surgery b,
   person p
  PLAN (b
   WHERE b.person_id=mf_person_id)
   JOIN (p
   WHERE p.person_id=b.person_id)
  HEAD b.person_id
   ms_pat_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET mn_upd_ind = 1
  UPDATE  FROM bhs_bariatric_surgery b
   SET b.active_ind = 1, b.authorized_dt_tm = cnvtdatetime(ms_authorized_dt), b.authorized_ft =
    ms_authorized_ft,
    b.barium_swallow_dt_tm = cnvtdatetime(ms_barium_swallow_dt), b.barium_swallow_ft =
    ms_barium_swallow_ft, b.bnp_nutrition_dt_tm = cnvtdatetime(ms_bnp_nutrition_dt),
    b.bnp_nutrition_ft = ms_bnp_nutrition_ft, b.bnp_pa_dt_tm = cnvtdatetime(ms_bnp_pa_dt), b
    .bnp_pa_ft = ms_bnp_pa_ft,
    b.bsv_dt_tm = cnvtdatetime(ms_bsv_dt), b.bsv_ft = ms_bsv_ft, b.comments = ms_comments,
    b.education_seminar_dt_tm = cnvtdatetime(ms_education_seminar_dt), b.education_seminar_ft =
    ms_education_seminar_ft, b.h_pylori_dt_tm = cnvtdatetime(ms_h_pylori_dt),
    b.h_pylori_ft = ms_h_pylori_ft, b.initial_psych_visit_dt_tm = cnvtdatetime(
     ms_initial_psych_visit_dt), b.initial_psych_visit_ft = ms_initial_psych_visit_ft,
    b.labs_dt_tm = cnvtdatetime(ms_labs_dt), b.labs_ft = ms_labs_ft, b.mwm_referral_dt_tm =
    cnvtdatetime(ms_mwm_referral_dt),
    b.mwm_referral_ft = ms_mwm_referral_ft, b.nutrition_clearance_dt_tm = cnvtdatetime(
     ms_nutrition_clearance_dt), b.nutrition_clearance_ft = ms_nutrition_clearance_ft,
    b.or_dt_tm = cnvtdatetime(ms_or_dt), b.or_ft = ms_or_ft, b.person_id = mf_person_id,
    b.psych_clearance_dt_tm = cnvtdatetime(ms_psych_clearance_dt), b.psych_clearance_ft =
    ms_psych_clearance_ft, b.sleep_clearance_dt_tm = cnvtdatetime(ms_sleep_clearance_dt),
    b.sleep_clearance_ft = ms_sleep_clearance_ft, b.treatment_completed_dt_tm = cnvtdatetime(
     ms_treatment_completed_dt), b.treatment_completed_ft = ms_treatment_completed_ft,
    b.us_dt_tm = cnvtdatetime(ms_us_dt), b.us_ft = ms_us_ft, b.updt_dt_tm = sysdate,
    b.updt_id = reqinfo->updt_id
   PLAN (b
    WHERE b.person_id=mf_person_id)
   WITH nocounter
  ;end update
 ELSE
  INSERT  FROM bhs_bariatric_surgery b
   SET b.bariatric_surgery_id = seq(bhs_eks_seq,nextval), b.active_ind = 1, b.authorized_dt_tm =
    cnvtdatetime(ms_authorized_dt),
    b.authorized_ft = ms_authorized_ft, b.barium_swallow_dt_tm = cnvtdatetime(ms_barium_swallow_dt),
    b.barium_swallow_ft = ms_barium_swallow_ft,
    b.bnp_nutrition_dt_tm = cnvtdatetime(ms_bnp_nutrition_dt), b.bnp_nutrition_ft =
    ms_bnp_nutrition_ft, b.bnp_pa_dt_tm = cnvtdatetime(ms_bnp_pa_dt),
    b.bnp_pa_ft = ms_bnp_pa_ft, b.bsv_dt_tm = cnvtdatetime(ms_bsv_dt), b.bsv_ft = ms_bsv_ft,
    b.comments = ms_comments, b.education_seminar_dt_tm = cnvtdatetime(ms_education_seminar_dt), b
    .education_seminar_ft = ms_education_seminar_ft,
    b.h_pylori_dt_tm = cnvtdatetime(ms_h_pylori_dt), b.h_pylori_ft = ms_h_pylori_ft, b
    .initial_psych_visit_dt_tm = cnvtdatetime(ms_initial_psych_visit_dt),
    b.initial_psych_visit_ft = ms_initial_psych_visit_ft, b.labs_dt_tm = cnvtdatetime(ms_labs_dt), b
    .labs_ft = ms_labs_ft,
    b.mwm_referral_dt_tm = cnvtdatetime(ms_mwm_referral_dt), b.mwm_referral_ft = ms_mwm_referral_ft,
    b.nutrition_clearance_dt_tm = cnvtdatetime(ms_nutrition_clearance_dt),
    b.nutrition_clearance_ft = ms_nutrition_clearance_ft, b.or_dt_tm = cnvtdatetime(ms_or_dt), b
    .or_ft = ms_or_ft,
    b.person_id = mf_person_id, b.psych_clearance_dt_tm = cnvtdatetime(ms_psych_clearance_dt), b
    .psych_clearance_ft = ms_psych_clearance_ft,
    b.sleep_clearance_dt_tm = cnvtdatetime(ms_sleep_clearance_dt), b.sleep_clearance_ft =
    ms_sleep_clearance_ft, b.treatment_completed_dt_tm = cnvtdatetime(ms_treatment_completed_dt),
    b.treatment_completed_ft = ms_treatment_completed_ft, b.us_dt_tm = cnvtdatetime(ms_us_dt), b
    .us_ft = ms_us_ft,
    b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id
   PLAN (b)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
 SET d0 = sec_head(rpt_render)
 SET d0 = sec_line(rpt_render)
 SET d0 = sec_detail(rpt_render)
 SET d0 = finalizereport(ms_output)
#exit_script
END GO
