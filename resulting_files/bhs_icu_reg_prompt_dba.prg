CREATE PROGRAM bhs_icu_reg_prompt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Facility:" = 0
  WITH outdev, s_beg_dt, s_end_dt,
  f_facility_cd
 FREE RECORD m_info
 RECORD m_info(
   1 pat[*]
     2 l_print_order = i4
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_sex_cd = f8
     2 s_name_full = vc
     2 s_fin_nbr = vc
     2 f_height_in = f8
     2 f_height_cm = f8
     2 f_ibw_kg = f8
     2 s_nurse_unit = vc
     2 s_room = vc
     2 s_bed = vc
     2 s_room_bed = vc
     2 s_icu_beg_dt_tm = vc
     2 f_icu_days = f8
     2 n_sed_vac = i2
     2 n_oral_swab = i2
     2 n_stress_ulcer = i2
     2 n_dvt = i2
     2 n_sedation = i2
     2 n_pain_control = i2
     2 n_nm_block = i2
     2 n_tidal_vol = i2
     2 f_tidal_val = f8
     2 s_tidal_units = vc
     2 f_vt_ibw = f8
     2 l_f_vt = i4
     2 f_resp_rt = f8
     2 s_resp_rt_units = vc
     2 n_eol_addr = i2
     2 n_glu_cnt = i2
     2 l_glu_min = i4
     2 l_glu_max = i4
     2 f_glu_per = f8
     2 n_nutrition = i2
     2 s_vent_mode = vc
     2 n_score = i2
     2 n_hob_90_per = i2
     2 hob[*]
       3 n_hob_30 = i2
       3 s_hob_val = vc
 ) WITH protect
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE head_section(ncalc=i2) = f8 WITH protect
 DECLARE head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE line_section(ncalc=i2) = f8 WITH protect
 DECLARE line_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detail_section(ncalc=i2) = f8 WITH protect
 DECLARE detail_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
 SUBROUTINE head_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE head_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __report_date = vc WITH noconstant(build2(concat("Run Time: ",trim(format(sysdate,
        "dd-mmm-yyyy hh:mm;;d"))),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ICU Safety Bundle Report",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.250)
    SET rptsd->m_width = 2.771
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__report_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Loc",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("f/Vt",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vt/IBW",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Stress",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NMBlock",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Oral",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("HOB",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DVT",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("24hr Glu",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("% Glu",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pain",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 7.500)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sedation",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 8.125)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sed Vac",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 8.750)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nutrn",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vent",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 9.188)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EOL",char(0)))
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 9.563)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Score",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE line_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = line_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE line_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.094),(offsetx+ 10.000),(offsety
     + 0.094))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detail_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detail_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detail_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE __name = vc WITH noconstant(build2(m_info->pat[ml_idx].s_name_full,char(0))), protect
   DECLARE __loc = vc WITH noconstant(build2(m_info->pat[ml_idx].s_room_bed,char(0))), protect
   DECLARE __f_vt = vc WITH noconstant(build2(trim(cnvtstring(m_info->pat[ml_idx].l_f_vt)),char(0))),
   protect
   DECLARE __vt_ibw = vc WITH noconstant(build2(
     IF (trim(m_info->pat[ml_idx].s_vent_mode) > " ") trim(cnvtstring(m_info->pat[ml_idx].f_vt_ibw))
     ENDIF
     ,char(0))), protect
   DECLARE __stress = vc WITH noconstant(build2(
     IF (trim(m_info->pat[ml_idx].s_vent_mode) > " ")
      IF ((m_info->pat[ml_idx].n_stress_ulcer=1)) "Y"
      ELSE "N"
      ENDIF
     ELSEIF ((m_info->pat[ml_idx].n_stress_ulcer=1)) "Y"
     ENDIF
     ,char(0))), protect
   DECLARE __nm_block = vc WITH noconstant(build2(
     IF (trim(m_info->pat[ml_idx].s_vent_mode) > " ")
      IF ((m_info->pat[ml_idx].n_nm_block=1)) "Y"
      ELSE "N"
      ENDIF
     ELSEIF ((m_info->pat[ml_idx].n_nm_block=1)) "Y"
     ENDIF
     ,char(0))), protect
   DECLARE __oral = vc WITH noconstant(build2(
     IF (trim(m_info->pat[ml_idx].s_vent_mode) > " ")
      IF ((m_info->pat[ml_idx].n_oral_swab=1)) "Y"
      ELSE "N"
      ENDIF
     ELSEIF ((m_info->pat[ml_idx].n_oral_swab=1)) "Y"
     ENDIF
     ,char(0))), protect
   DECLARE __hob = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_hob_90_per=1)) "Y"
     ELSE "N"
     ENDIF
     ,char(0))), protect
   DECLARE __dvt = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_dvt=1)) "Y"
     ELSE "N"
     ENDIF
     ,char(0))), protect
   DECLARE __glu_24 = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].l_glu_min > 0)
      AND (m_info->pat[ml_idx].l_glu_max > 0)) concat(trim(cnvtstring(m_info->pat[ml_idx].l_glu_min)),
       "; ",trim(cnvtstring(m_info->pat[ml_idx].l_glu_max)))
     ELSEIF ((m_info->pat[ml_idx].l_glu_max > 0)) trim(cnvtstring(m_info->pat[ml_idx].l_glu_max))
     ELSE "N/A"
     ENDIF
     ,char(0))), protect
   DECLARE __per_glu = vc WITH noconstant(build2(trim(cnvtstring(m_info->pat[ml_idx].f_glu_per)),char
     (0))), protect
   DECLARE __pain = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_pain_control=1)) "Y"
     ELSE "N"
     ENDIF
     ,char(0))), protect
   DECLARE __sedation = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_sedation=1)) "Y"
     ELSE "N"
     ENDIF
     ,char(0))), protect
   DECLARE __sedation_vacation = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_sed_vac=1)) "Y"
     ELSE "N"
     ENDIF
     ,char(0))), protect
   DECLARE __nutrition = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_nutrition=1)) "EN"
     ELSEIF ((m_info->pat[ml_idx].n_nutrition=2)) "TN"
     ELSE "R"
     ENDIF
     ,char(0))), protect
   DECLARE __vent = vc WITH noconstant(build2(m_info->pat[ml_idx].s_vent_mode,char(0))), protect
   DECLARE __eol = vc WITH noconstant(build2(
     IF ((m_info->pat[ml_idx].n_eol_addr=1)) "Y"
     ELSE "N"
     ENDIF
     ,char(0))), protect
   DECLARE __score = vc WITH noconstant(build2(trim(cnvtstring(m_info->pat[ml_idx].n_score)),char(0))
    ), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__loc)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__f_vt)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__vt_ibw)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__stress)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nm_block)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 0.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__oral)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hob)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dvt)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__glu_24)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__per_glu)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pain)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.563)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sedation)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.188)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sedation_vacation)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.750)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nutrition)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__vent)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 9.250)
    SET rptsd->m_width = 0.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__eol)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 9.625)
    SET rptsd->m_width = 0.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__score)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_ICU_REG_PROMPT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
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
   SET rptfont->m_recsize = 52
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
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $S_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $S_END_DT," 23:59:59"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"FINAL"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FIN NBR"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_icu_a_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICUA"))
 DECLARE mf_icu_b_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICUB"))
 DECLARE mf_icu_c_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICUC"))
 DECLARE mf_cvcu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"CVCU"))
 DECLARE mf_pcu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"PCU"))
 DECLARE mf_hvcc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"HVCC"))
 DECLARE mf_sicu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"SICU"))
 DECLARE mf_niu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NIU"))
 DECLARE mf_d5a_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"D5A"))
 DECLARE mf_micu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"MICU"))
 DECLARE mf_iccu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ICCU"))
 DECLARE mf_icu_cd = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",220,"ICU"))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.data_status_cd=mf_auth_cd
   AND cv.cdf_meaning="NURSEUNIT"
   AND cv.display_key="ICU"
  DETAIL
   mf_icu_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build2("iccu: ",mf_iccu_cd))
 CALL echo(build2("icu: ",mf_icu_cd))
 DECLARE mf_sed_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SEDATIONVACATION"
   ))
 DECLARE mf_oral_swab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHLORHEXIDINETOPICAL"))
 DECLARE mf_hob_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"VAPPRECAUTIONS"))
 DECLARE mf_tidal_vol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TIDALVOLUMEDELIVERED"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_resp_rt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"RESPIRATORYRATE")
  )
 DECLARE mf_glu_poc1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,"Glucose (POC)"))
 DECLARE mf_glu_poc2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,"Glucose, POC"))
 DECLARE mf_glu_level_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE mf_tube_cont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TUBEFEEDINGCONTINUOUS"))
 DECLARE mf_ent_feed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ENTERALFEEDINGS"
   ))
 DECLARE mf_tube_feed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ENTERALTUBEFEEDINGS"))
 DECLARE mf_nutrn_int_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUTRITIONINTERVENTIONS"))
 DECLARE mf_tpn_1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA55D14L3ACETLYTES"))
 DECLARE mf_tpn_2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA55D14L3STANDLYTES"))
 DECLARE mf_tpn_3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA5D15"))
 DECLARE mf_tpn_4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA5D18L3ACETLYTES"))
 DECLARE mf_tpn_5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALA5D18L3STANDLYTES"))
 DECLARE mf_tpn_6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TPNADULTCENTRALCUSTOM"))
 DECLARE mf_vent_mode_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"VENTILATORMODE"
   ))
 DECLARE mf_wean_indx = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "WEANINGRAPIDSHALLOWBREATHINGINDEX"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(cnvtreal( $F_FACILITY_CD))
 DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mf_dfr_id = f8 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 CALL echo(build2("beg_dt: ",ms_beg_dt_tm))
 CALL echo(build2("end_dt: ",ms_end_dt_tm))
 CALL echo("get patient/encntr info")
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ed
   WHERE ed.loc_facility_cd=mf_facility_cd
    AND ed.loc_nurse_unit_cd IN (mf_icu_a_cd, mf_icu_b_cd, mf_icu_c_cd, mf_cvcu_cd, mf_pcu_cd,
   mf_hvcc_cd, mf_sicu_cd, mf_niu_cd, mf_d5a_cd, mf_micu_cd,
   mf_icu_cd, mf_iccu_cd)
    AND ed.active_ind=1
    AND ed.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_class_cd=mf_inpt_cd
    AND e.reg_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND e.disch_dt_tm=null
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND elh.loc_nurse_unit_cd=ed.loc_nurse_unit_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_cd))
  ORDER BY ed.loc_nurse_unit_cd, p.name_last_key
  HEAD REPORT
   pl_cnt = 0
  HEAD elh.encntr_id
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_info->pat,5))
    stat = alterlist(m_info->pat,(pl_cnt+ 10))
   ENDIF
   m_info->pat[pl_cnt].f_encntr_id = e.encntr_id, m_info->pat[pl_cnt].f_person_id = p.person_id,
   m_info->pat[pl_cnt].s_name_full = trim(p.name_full_formatted),
   m_info->pat[pl_cnt].f_sex_cd = p.sex_cd, m_info->pat[pl_cnt].s_fin_nbr = trim(ea.alias), m_info->
   pat[pl_cnt].s_nurse_unit = trim(uar_get_code_display(ed.loc_nurse_unit_cd)),
   m_info->pat[pl_cnt].s_room = trim(uar_get_code_display(ed.loc_room_cd)), m_info->pat[pl_cnt].s_bed
    = trim(uar_get_code_display(ed.loc_bed_cd)), m_info->pat[pl_cnt].s_room_bed = trim(concat(m_info
     ->pat[pl_cnt].s_room,m_info->pat[pl_cnt].s_bed)),
   ms_tmp = ""
   FOR (pn_loop_cnt = 1 TO textlen(m_info->pat[pl_cnt].s_room_bed))
     IF (isnumeric(substring(pn_loop_cnt,1,m_info->pat[pl_cnt].s_room_bed)) > 0)
      ms_tmp = concat(ms_tmp,substring(pn_loop_cnt,1,m_info->pat[pl_cnt].s_room_bed))
     ENDIF
   ENDFOR
   m_info->pat[pl_cnt].s_room_bed = trim(ms_tmp,3), m_info->pat[pl_cnt].s_icu_beg_dt_tm = trim(format
    (elh.beg_effective_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_info->pat[pl_cnt].f_icu_days = datetimediff(
    sysdate,elh.beg_effective_dt_tm)
  FOOT REPORT
   stat = alterlist(m_info->pat,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 CALL echo("get clinical events")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=m_info->pat[d.seq].f_encntr_id)
    AND (ce.person_id=m_info->pat[d.seq].f_person_id)
    AND ce.event_cd IN (mf_sed_vac_cd, mf_oral_swab_cd, mf_hob_cd, mf_tidal_vol_cd, mf_height_cd,
   mf_resp_rt_cd, mf_glu_poc1_cd, mf_glu_poc2_cd, mf_glu_level_cd, mf_tube_cont_cd,
   mf_ent_feed_cd, mf_tube_feed_cd, mf_nutrn_int_cd, mf_tpn_1_cd, mf_tpn_2_cd,
   mf_tpn_3_cd, mf_tpn_4_cd, mf_tpn_5_cd, mf_tpn_6_cd, mf_vent_mode_cd,
   mf_wean_indx)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd)
    AND ce.view_level=1)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm
  HEAD ce.encntr_id
   pl_hob_cnt = 0, pl_hob_30_cnt = 0, pl_glu_cnt = 0,
   pl_glu_good_cnt = 0
  DETAIL
   CASE (ce.event_cd)
    OF mf_sed_vac_cd:
     m_info->pat[d.seq].n_sed_vac = 1
    OF mf_oral_swab_cd:
     IF (ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      m_info->pat[d.seq].n_oral_swab = 1
     ENDIF
    OF mf_hob_cd:
     IF (ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_hob_cnt = (pl_hob_cnt+ 1)
      IF (pl_hob_cnt > size(m_info->pat[d.seq].hob,5))
       stat = alterlist(m_info->pat[d.seq].hob,(pl_hob_cnt+ 5))
      ENDIF
      m_info->pat[d.seq].hob[pl_hob_cnt].s_hob_val = trim(ce.result_val)
      IF (((findstring("HOB AT 80 DEGREES",cnvtupper(trim(ce.result_val))) > 0) OR (findstring(
       "HOB 30-45 DEGREES",cnvtupper(trim(ce.result_val))) > 0)) )
       m_info->pat[d.seq].hob[pl_hob_cnt].n_hob_30 = 1, pl_hob_30_cnt = (pl_hob_30_cnt+ 1)
      ENDIF
     ENDIF
    OF mf_tidal_vol_cd:
     m_info->pat[d.seq].n_tidal_vol = 1,m_info->pat[d.seq].f_tidal_val = cnvtreal(ce.result_val),
     m_info->pat[d.seq].s_tidal_units = trim(uar_get_code_display(ce.result_units_cd))
    OF mf_height_cd:
     IF (cnvtupper(trim(uar_get_code_display(ce.result_units_cd)))="CM")
      m_info->pat[d.seq].f_height_cm = cnvtreal(ce.result_val), m_info->pat[d.seq].f_height_in = (
      cnvtreal(ce.result_val) * 0.3937)
     ELSEIF (cnvtupper(trim(uar_get_code_display(ce.result_units_cd)))="IN")
      m_info->pat[d.seq].f_height_in = cnvtreal(ce.result_val), m_info->pat[d.seq].f_height_cm = (
      cnvtreal(ce.result_val) * 2.54)
     ENDIF
     ,
     IF ((m_info->pat[d.seq].f_sex_cd=mf_male_cd))
      m_info->pat[d.seq].f_ibw_kg = (50+ (2.3 * (m_info->pat[d.seq].f_height_in - 60)))
     ELSEIF ((m_info->pat[d.seq].f_sex_cd=mf_female_cd))
      m_info->pat[d.seq].f_ibw_kg = (45.5+ (2.3 * (m_info->pat[d.seq].f_height_in - 60)))
     ENDIF
    OF mf_resp_rt_cd:
     m_info->pat[d.seq].f_resp_rt = cnvtreal(ce.result_val),m_info->pat[d.seq].s_resp_rt_units = trim
     (uar_get_code_display(ce.result_units_cd))
    OF mf_glu_poc1_cd:
     IF (cnvtint(ce.result_val) > 0
      AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_glu_cnt = (pl_glu_cnt+ 1)
      IF (cnvtint(ce.result_val) >= 50
       AND cnvtint(ce.result_val) <= 180)
       pl_glu_good_cnt = (pl_glu_good_cnt+ 1)
      ENDIF
      IF ((cnvtint(ce.result_val) > m_info->pat[d.seq].l_glu_max))
       m_info->pat[d.seq].l_glu_max = cnvtint(ce.result_val)
      ENDIF
      IF ((((cnvtint(ce.result_val) < m_info->pat[d.seq].l_glu_min)) OR ((m_info->pat[d.seq].
      l_glu_min=0))) )
       m_info->pat[d.seq].l_glu_min = cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_glu_poc2_cd:
     IF (cnvtint(ce.result_val) > 0
      AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_glu_cnt = (pl_glu_cnt+ 1)
      IF (cnvtint(ce.result_val) >= 50
       AND cnvtint(ce.result_val) <= 180)
       pl_glu_good_cnt = (pl_glu_good_cnt+ 1)
      ENDIF
      IF ((cnvtint(ce.result_val) > m_info->pat[d.seq].l_glu_max))
       m_info->pat[d.seq].l_glu_max = cnvtint(ce.result_val)
      ENDIF
      IF ((((cnvtint(ce.result_val) < m_info->pat[d.seq].l_glu_min)) OR ((m_info->pat[d.seq].
      l_glu_min=0))) )
       m_info->pat[d.seq].l_glu_min = cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_glu_level_cd:
     IF (cnvtint(ce.result_val) > 0
      AND ce.event_end_dt_tm BETWEEN datetimeadd(sysdate,- (1)) AND sysdate)
      pl_glu_cnt = (pl_glu_cnt+ 1)
      IF (cnvtint(ce.result_val) >= 50
       AND cnvtint(ce.result_val) <= 180)
       pl_glu_good_cnt = (pl_glu_good_cnt+ 1)
      ENDIF
      IF ((cnvtint(ce.result_val) > m_info->pat[d.seq].l_glu_max))
       m_info->pat[d.seq].l_glu_max = cnvtint(ce.result_val)
      ENDIF
      IF ((((cnvtint(ce.result_val) < m_info->pat[d.seq].l_glu_min)) OR ((m_info->pat[d.seq].
      l_glu_min=0))) )
       m_info->pat[d.seq].l_glu_min = cnvtint(ce.result_val)
      ENDIF
     ENDIF
    OF mf_tube_cont_cd:
     IF ((m_info->pat[d.seq].n_nutrition=0))
      m_info->pat[d.seq].n_nutrition = 1
     ENDIF
    OF mf_ent_feed_cd:
     IF ((m_info->pat[d.seq].n_nutrition=0))
      m_info->pat[d.seq].n_nutrition = 1
     ENDIF
    OF mf_tube_feed_cd:
     IF ((m_info->pat[d.seq].n_nutrition=0))
      m_info->pat[d.seq].n_nutrition = 1
     ENDIF
    OF mf_nutrn_int_cd:
     IF (findstring("OTHER: TPN",cnvtupper(ce.result_val),1) > 0)
      m_info->pat[d.seq].n_nutrition = 2
     ENDIF
    OF mf_tpn_1_cd:
     m_info->pat[d.seq].n_nutrition = 2
    OF mf_tpn_2_cd:
     m_info->pat[d.seq].n_nutrition = 2
    OF mf_tpn_3_cd:
     m_info->pat[d.seq].n_nutrition = 2
    OF mf_tpn_4_cd:
     m_info->pat[d.seq].n_nutrition = 2
    OF mf_tpn_5_cd:
     m_info->pat[d.seq].n_nutrition = 2
    OF mf_tpn_6_cd:
     m_info->pat[d.seq].n_nutrition = 2
    OF mf_vent_mode_cd:
     m_info->pat[d.seq].s_vent_mode = trim(ce.result_val)
    OF mf_wean_indx:
     m_info->pat[d.seq].l_f_vt = cnvtint(ce.result_val)
   ENDCASE
  FOOT  ce.encntr_id
   stat = alterlist(m_info->pat[d.seq].hob,pl_hob_cnt), m_info->pat[d.seq].n_glu_cnt = pl_glu_cnt
   IF (pl_hob_30_cnt > 0)
    IF (((cnvtreal(pl_hob_30_cnt)/ cnvtreal(size(m_info->pat[d.seq].hob,5))) >= 0.90))
     m_info->pat[d.seq].n_hob_90_per = 1
    ENDIF
   ENDIF
   IF (pl_glu_good_cnt > 0)
    m_info->pat[d.seq].f_glu_per = ((cnvtreal(pl_glu_good_cnt)/ cnvtreal(pl_glu_cnt)) * 100)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   orders o,
   order_catalog oc
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=m_info->pat[d.seq].f_encntr_id)
    AND o.active_ind=1
    AND o.template_order_flag IN (0, 1))
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=o.catalog_cd
    AND ((cnvtupper(oc.primary_mnemonic) IN ("ESOMAPRAZOLE", "FAMOTIDINE", "PANTOPRAZOLE")) OR (((
   cnvtupper(oc.primary_mnemonic)="ARGATROBAN*") OR (((cnvtupper(oc.primary_mnemonic)="DESIRUDIN*")
    OR (((cnvtupper(oc.primary_mnemonic)="ENOXAPARIN*") OR (((cnvtupper(oc.primary_mnemonic)=
   "FONDAPARINUX*") OR (((cnvtupper(oc.primary_mnemonic)="HEPARIN*") OR (((cnvtupper(oc
    .primary_mnemonic)="WARFARIN*") OR (((cnvtupper(oc.primary_mnemonic)="ATIVAN*") OR (((cnvtupper(
    oc.primary_mnemonic)="DIAZEPAM*") OR (((cnvtupper(oc.primary_mnemonic)="LORAZEPAM*") OR (((
   cnvtupper(oc.primary_mnemonic)="MIDEZOLAM*") OR (((cnvtupper(oc.primary_mnemonic)="PROPOFOL*") OR
   (((cnvtupper(oc.primary_mnemonic)="VERSED*") OR (((cnvtupper(oc.primary_mnemonic)="FENTANYL*") OR
   (((cnvtupper(oc.primary_mnemonic)="HYDROMORPHONE*") OR (((cnvtupper(oc.primary_mnemonic)=
   "MORPHINE*") OR (((cnvtupper(oc.primary_mnemonic)="CISATRACURIUM*") OR (((cnvtupper(oc
    .primary_mnemonic)="PANCURONIUM*") OR (cnvtupper(oc.primary_mnemonic)="VECURONIUM*")) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  DETAIL
   CASE (cnvtupper(oc.primary_mnemonic))
    OF "ESOMAPRAZOLE":
     m_info->pat[d.seq].n_stress_ulcer = 1
    OF "FAMOTIDINE":
     m_info->pat[d.seq].n_stress_ulcer = 1
    OF "PANTOPRAZOLE":
     m_info->pat[d.seq].n_stress_ulcer = 1
    OF "ARGATROBAN*":
     m_info->pat[d.seq].n_dvt = 1
    OF "DESIRUDIN*":
     m_info->pat[d.seq].n_dvt = 1
    OF "ENOXAPARIN*":
     m_info->pat[d.seq].n_dvt = 1
    OF "FONDAPARINUX*":
     m_info->pat[d.seq].n_dvt = 1
    OF "HEPARIN*":
     m_info->pat[d.seq].n_dvt = 1
    OF "WARFARIN*":
     m_info->pat[d.seq].n_dvt = 1
    OF "ATIVAN*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_info->pat[d.seq].n_sedation = 1
     ENDIF
    OF "DIAZEPAM*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_info->pat[d.seq].n_sedation = 1
     ENDIF
    OF "LORAZEPAM*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_info->pat[d.seq].n_sedation = 1
     ENDIF
    OF "MIDEZOLAM*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_info->pat[d.seq].n_sedation = 1
     ENDIF
    OF "PROPOFOL*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_info->pat[d.seq].n_sedation = 1
     ENDIF
    OF "VERSED*":
     IF (datetimediff(sysdate,o.active_status_dt_tm,3) <= 24)
      m_info->pat[d.seq].n_sedation = 1
     ENDIF
    OF "FENTANYL*":
     m_info->pat[d.seq].n_pain_control = 1
    OF "HYDROMORPHONE*":
     m_info->pat[d.seq].n_pain_control = 1
    OF "MORPHINE*":
     m_info->pat[d.seq].n_pain_control = 1
    OF "CISATRACURIUM*":
     m_info->pat[d.seq].n_nm_block = 1
    OF "PANCURONIUM*":
     m_info->pat[d.seq].n_nm_block = 1
    OF "VECURONIUM*":
     m_info->pat[d.seq].n_nm_block = 1
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo("check for EOL form")
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.active_ind=1
   AND dfr.description="ICU Communication and Palliative Care"
  DETAIL
   mf_dfr_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfa.encntr_id
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5))),
   dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (d)
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_dfr_id
    AND dfa.active_ind=1
    AND (dfa.encntr_id=m_info->pat[d.seq].f_encntr_id)
    AND (dfa.person_id=m_info->pat[d.seq].f_person_id)
    AND dfa.form_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd, mf_active_cd, mf_final_cd))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.active_ind=1)
  HEAD dfa.encntr_id
   m_info->pat[d.seq].n_eol_addr = 1
  WITH nocounter
 ;end select
 CALL echo("calculate values")
 FOR (ml_loop_cnt = 1 TO size(m_info->pat,5))
   IF ((m_info->pat[ml_loop_cnt].f_ibw_kg > 0)
    AND (m_info->pat[ml_loop_cnt].f_tidal_val > 0))
    SET m_info->pat[ml_loop_cnt].f_vt_ibw = (m_info->pat[ml_loop_cnt].f_tidal_val/ m_info->pat[
    ml_loop_cnt].f_ibw_kg)
   ENDIF
   SET m_info->pat[ml_loop_cnt].n_score = 9
   IF ((m_info->pat[ml_loop_cnt].n_dvt=0))
    SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
   ENDIF
   IF ((m_info->pat[ml_loop_cnt].f_glu_per < 75))
    SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
   ENDIF
   IF (trim(m_info->pat[ml_loop_cnt].s_vent_mode) > " ")
    IF ((m_info->pat[ml_loop_cnt].l_f_vt <= 0))
     SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_info->pat[ml_loop_cnt].n_stress_ulcer=0))
     SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_info->pat[ml_loop_cnt].n_oral_swab=0))
     SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_info->pat[ml_loop_cnt].n_hob_90_per=0))
     SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_info->pat[ml_loop_cnt].n_sedation=1)
     AND (m_info->pat[ml_loop_cnt].n_sed_vac=0))
     SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
    ENDIF
    IF ((m_info->pat[ml_loop_cnt].n_nutrition=0))
     SET m_info->pat[ml_loop_cnt].n_score = (m_info->pat[ml_loop_cnt].n_score - 1)
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("create report")
 SET d0 = head_section(rpt_render)
 SET d0 = line_section(rpt_render)
 SELECT INTO "nl:"
  ps_room = m_info->pat[d.seq].s_room_bed
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5)))
  ORDER BY ps_room
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), m_info->pat[d.seq].l_print_order = pl_cnt
  WITH nocounter
 ;end select
 FOR (ml_loop_cnt = 1 TO size(m_info->pat,5))
  SET ml_idx = locateval(ml_num,1,size(m_info->pat,5),ml_loop_cnt,m_info->pat[ml_num].l_print_order)
  SET d0 = detail_section(rpt_render)
 ENDFOR
 SET d0 = finalizereport(value(ms_output))
#exit_script
 IF (size(m_info->pat,5)=0)
  SELECT INTO value( $OUTDEV)
   HEAD REPORT
    col 0, "No patients found"
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_info
END GO
