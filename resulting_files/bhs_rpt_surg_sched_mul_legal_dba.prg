CREATE PROGRAM bhs_rpt_surg_sched_mul_legal:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Sched Location:" = 0,
  "Sched Start Date:" = "CURDATE",
  "Sched End Date:" = "CURDATE"
  WITH outdev, mf_sched_loc_cd, ms_beg_dt,
  ms_end_dt
 DECLARE mf_sched_loc_cd = f8 WITH protect, constant( $MF_SCHED_LOC_CD)
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_ancillary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"ANCILLARY"))
 DECLARE mf_latex_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"SNLATEXALLERGY")
  )
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE ms_sched_loc = vc WITH protect, constant(uar_get_code_display( $MF_SCHED_LOC_CD))
 DECLARE ms_cur_dt_tm = vc WITH protect, constant(concat("Print Date: ",format(sysdate,
    "MM-DD-YYYY HH:MM;;D")))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat( $MS_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat( $MS_END_DT," 23:59:59"))
 DECLARE ms_day = vc WITH protect, noconstant("")
 DECLARE ms_prev_date = vc WITH protect, noconstant("")
 DECLARE ms_cur_date = vc WITH protect, noconstant("")
 DECLARE ms_prev_room = vc WITH protect, noconstant("")
 DECLARE ms_cur_room = vc WITH protect, noconstant("")
 DECLARE ms_total_dur = vc WITH protect, noconstant("")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_continue = i4 WITH protect, noconstant(0)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remcomment = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsec_comment = i2 WITH noconstant(0), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times160 = i4 WITH noconstant(0), protect
 DECLARE _pen14s2c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (sec_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times160)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health System",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("OR Schedule from : ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("to",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.303)
    SET rptsd->m_x = (offsetx+ 1.865)
    SET rptsd->m_width = 3.823
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_sched_loc,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 3.251)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_beg_dt_tm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_end_dt_tm,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_day(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_dayabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_dayabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 3.855
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_day,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.011)
    SET rptsd->m_width = 1.803
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_cur_dt_tm,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_line1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_line1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_line1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.052),(offsetx+ 7.501),(offsety+
     0.052))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_line2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_line2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_line2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.052),(offsetx+ 7.501),(offsety+
     0.052))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_fields1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_fields1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_fields1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.417
    SET rptsd->m_height = 0.209
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.376)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Case #",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Room",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Latex Allergy",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_fields2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_fields2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_fields2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.209
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prim Surgeon",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ancillary Code",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Anesthesia ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Length",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.646)
    SET rptsd->m_width = 1.042
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Modifier",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_body2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_body2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_body2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.630000), private
   DECLARE __primsurg = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].
     s_prim_surg_name,char(0))), protect
   DECLARE __ancillary = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].s_ancillary,
     char(0))), protect
   DECLARE __proc = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].s_proc_name,char(0)
     )), protect
   DECLARE __anesthesia = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].s_anes_type,
     char(0))), protect
   DECLARE __length = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].s_duration,char(0
      ))), protect
   DECLARE __modifier = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].s_modifier,char
     (0))), protect
   DECLARE __assistsurg = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].
     s_assist_surg_name,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primsurg)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ancillary)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__proc)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.625
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__anesthesia)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__length)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.594)
    SET rptsd->m_width = 1.344
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__modifier)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__assistsurg)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_pref(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_prefabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_prefabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __pref = vc WITH noconstant(build2(m_case->qual[ml_idx1].proc[ml_idx2].s_pref_card,char(0)
     )), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.032)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pref)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_comment(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_commentabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_commentabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_comment = f8 WITH noconstant(0.0), private
   DECLARE __comment = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_public_comment,char(0))),
   protect
   IF (bcontinue=0)
    SET _remcomment = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.011)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.021)
   SET rptsd->m_width = 5.792
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcomment = _remcomment
   IF (_remcomment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcomment,((size(
        __comment) - _remcomment)+ 1),__comment)))
    SET drawheight_comment = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcomment = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcomment,((size(__comment) -
       _remcomment)+ 1),__comment)))))
     SET _remcomment += rptsd->m_drawlength
    ELSE
     SET _remcomment = 0
    ENDIF
    SET growsum += _remcomment
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.011)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.021)
   SET rptsd->m_width = 5.792
   SET rptsd->m_height = drawheight_comment
   IF (ncalc=rpt_render
    AND _holdremcomment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcomment,((size(
        __comment) - _holdremcomment)+ 1),__comment)))
   ELSE
    SET _remcomment = _holdremcomment
   ENDIF
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.438)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.230
   SET _dummyfont = uar_rptsetfont(_hreport,_times80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_total_dur,char(0)))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_body1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_body1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_body1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE __datetime = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_start_time,char(0))),
   protect
   DECLARE __patname = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_pat_name,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_pat_dob,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_mrn,char(0))), protect
   DECLARE __type = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_pat_type,char(0))), protect
   DECLARE __case = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_case_nbr,char(0))), protect
   DECLARE __room = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_or_room,char(0))), protect
   DECLARE __latexallergy = vc WITH noconstant(build2(m_case->qual[ml_idx1].s_latex_allergy,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__datetime)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 0.886
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__type)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__case)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__room)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__latexallergy)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_foot(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_footabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 0.980
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_SURG_SCHED_MUL_LEGAL"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 14.00
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
   SET rptfont->m_pointsize = 16
   SET _times160 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 2
   SET _pen14s2c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD m_case
 RECORD m_case(
   1 l_cnt = i4
   1 qual[*]
     2 f_surg_case_id = f8
     2 f_surg_area_cd = f8
     2 s_case_nbr = vc
     2 s_location = vc
     2 s_start_date = vc
     2 s_start_time = vc
     2 s_date_full = vc
     2 s_or_room = vc
     2 s_pat_name = vc
     2 s_pat_type = vc
     2 s_cmrn = vc
     2 s_mrn = vc
     2 s_pat_dob = vc
     2 f_case_date = f8
     2 s_public_comment = vc
     2 s_cleanup_tm = i4
     2 s_latex_allergy = vc
     2 l_tot_dur = i4
     2 p_cnt = i4
     2 proc[*]
       3 f_surg_proc_id = f8
       3 f_order_id = f8
       3 s_proc_name = vc
       3 f_cat_cd = f8
       3 s_modifier = vc
       3 l_prim_ind = i4
       3 s_ancillary = vc
       3 s_duration = vc
       3 s_prim_surg_name = vc
       3 s_assist_surg_name = vc
       3 f_surg_prsn_id = f8
       3 s_anes_type = vc
       3 s_pref_card = vc
 )
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET ms_beg_dt_tm = concat(format((curdate+ 1),"DD-MMM-YYYY;;D")," 00:00:00")
  SET ms_end_dt_tm = concat(format((curdate+ 1),"DD-MMM-YYYY;;D")," 23:59:59")
 ENDIF
 SELECT INTO "nl:"
  ps_case_dt = format(sc.sched_start_dt_tm,"MMDDYYYY;;D"), ps_or_room = uar_get_code_display(sc
   .sched_op_loc_cd), ps_case_tm = format(sc.sched_start_dt_tm,"HH:MM:SS;;M")
  FROM surgical_case sc,
   person p,
   person_alias pa,
   sch_event_comm sec,
   long_text lt,
   sch_event_detail sed,
   encntr_alias ea
  PLAN (sc
   WHERE (sc.sched_surg_area_cd= $MF_SCHED_LOC_CD)
    AND sc.sched_start_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND sc.sched_start_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND sc.active_ind=1
    AND sc.cancel_dt_tm = null)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (sec
   WHERE (sec.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sec.active_ind= Outerjoin(1))
    AND (sec.text_type_meaning= Outerjoin("COMMENT"))
    AND (sec.sub_text_meaning= Outerjoin("SURGPUBLIC"))
    AND (sec.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(sec.text_id))
    AND (lt.active_ind= Outerjoin(1)) )
   JOIN (sed
   WHERE (sed.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sed.oe_field_id= Outerjoin(mf_latex_cd))
    AND (sed.active_ind= Outerjoin(1))
    AND (sed.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(sc.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
    AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
  ORDER BY ps_case_dt, ps_or_room, ps_case_tm
  HEAD REPORT
   m_case->l_cnt = 0
  HEAD sc.surg_case_nbr_formatted
   m_case->l_cnt += 1, stat = alterlist(m_case->qual,m_case->l_cnt), m_case->qual[m_case->l_cnt].
   s_location = uar_get_code_display(sc.sched_surg_area_cd),
   m_case->qual[m_case->l_cnt].f_surg_area_cd = sc.sched_surg_area_cd, m_case->qual[m_case->l_cnt].
   s_case_nbr = sc.surg_case_nbr_formatted, m_case->qual[m_case->l_cnt].s_start_date = format(sc
    .sched_start_dt_tm,"DD-MMM-YYYY;;D"),
   m_case->qual[m_case->l_cnt].s_start_time = format(sc.sched_start_dt_tm,"HH:MM:SS;;M"), m_case->
   qual[m_case->l_cnt].s_date_full = format(sc.sched_start_dt_tm,"@SHORTDATETIME"), m_case->qual[
   m_case->l_cnt].f_case_date = sc.sched_start_dt_tm,
   m_case->qual[m_case->l_cnt].s_or_room = uar_get_code_display(sc.sched_op_loc_cd), m_case->qual[
   m_case->l_cnt].s_pat_name = p.name_full_formatted, m_case->qual[m_case->l_cnt].s_pat_type =
   uar_get_code_display(sc.sched_pat_type_cd),
   m_case->qual[m_case->l_cnt].s_cmrn = pa.alias, m_case->qual[m_case->l_cnt].s_mrn = trim(ea.alias),
   m_case->qual[m_case->l_cnt].s_pat_dob = format(p.birth_dt_tm,"DD-MMM-YYYY;;D"),
   m_case->qual[m_case->l_cnt].f_surg_case_id = sc.surg_case_id, m_case->qual[m_case->l_cnt].
   s_latex_allergy = trim(sed.oe_field_display_value,3)
   IF (size(trim(lt.long_text,3)) > 0
    AND trim(lt.long_text,3) != ":")
    m_case->qual[m_case->l_cnt].s_public_comment = concat("Comment: ",replace(trim(lt.long_text,3),
      char(013)," "))
   ENDIF
   m_case->qual[m_case->l_cnt].s_cleanup_tm = sc.sched_cleanup_dur
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surg_case_procedure scp,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   order_catalog oc,
   prsnl p,
   order_detail od
  PLAN (scp
   WHERE expand(ml_idx1,1,m_case->l_cnt,scp.surg_case_id,m_case->qual[ml_idx1].f_surg_case_id)
    AND scp.active_ind=1)
   JOIN (ocs
   WHERE (ocs.synonym_id= Outerjoin(scp.synonym_id)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(ocs.catalog_cd)) )
   JOIN (ocs2
   WHERE (ocs2.catalog_cd= Outerjoin(ocs.catalog_cd))
    AND (ocs2.mnemonic_type_cd= Outerjoin(mf_ancillary_cd))
    AND (ocs2.active_ind= Outerjoin(1)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
   JOIN (od
   WHERE (od.order_id= Outerjoin(scp.order_id))
    AND (od.oe_field_meaning= Outerjoin("SURGEON4")) )
  ORDER BY scp.surg_case_id, scp.surg_case_proc_id, ocs2.mnemonic,
   od.action_sequence DESC
  HEAD REPORT
   ml_idx2 = 0
  HEAD scp.surg_case_id
   ml_idx2 = locateval(ml_idx1,1,m_case->l_cnt,scp.surg_case_id,m_case->qual[ml_idx1].f_surg_case_id),
   CALL echo(ml_idx2)
  HEAD scp.surg_case_proc_id
   m_case->qual[ml_idx2].p_cnt += 1, stat = alterlist(m_case->qual[ml_idx2].proc,m_case->qual[ml_idx2
    ].p_cnt), m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_proc_name = oc
   .primary_mnemonic,
   m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].f_cat_cd = ocs.catalog_cd, m_case->qual[
   ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_modifier = scp.sched_modifier
   IF (isnumeric(substring(1,8,trim(ocs2.mnemonic,3))) > 0)
    m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_ancillary = substring(1,8,trim(ocs2
      .mnemonic,3))
   ENDIF
   m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].f_surg_proc_id = scp.surg_case_proc_id,
   m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_prim_surg_name = p.name_full_formatted,
   m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].f_surg_prsn_id = p.person_id,
   m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_assist_surg_name = od
   .oe_field_display_value, m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_duration = trim
   (cnvtstring(scp.sched_dur)), m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].s_anes_type
    = uar_get_code_display(scp.sched_anesth_type_cd),
   m_case->qual[ml_idx2].proc[m_case->qual[ml_idx2].p_cnt].f_order_id = scp.order_id, m_case->qual[
   ml_idx2].l_tot_dur += scp.sched_dur
  FOOT  scp.surg_case_proc_id
   null
  FOOT  scp.surg_case_id
   m_case->qual[ml_idx2].l_tot_dur += m_case->qual[ml_idx2].s_cleanup_tm
  WITH nocounter
 ;end select
 CALL echorecord(m_case)
 FOR (ml_idx1 = 1 TO m_case->l_cnt)
   FOR (ml_idx2 = 1 TO m_case->qual[ml_idx1].p_cnt)
     SET m_case->qual[ml_idx1].proc[ml_idx2].s_pref_card = "Pref Card: No"
     SELECT INTO "nl:"
      FROM preference_card pc
      WHERE (pc.catalog_cd=m_case->qual[ml_idx1].proc[ml_idx2].f_cat_cd)
       AND (pc.prsnl_id=m_case->qual[ml_idx1].proc[ml_idx2].f_surg_prsn_id)
       AND (pc.surg_area_cd=m_case->qual[ml_idx1].f_surg_area_cd)
      DETAIL
       m_case->qual[ml_idx1].proc[ml_idx2].s_pref_card = "Pref Card: Yes"
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM order_detail od
      PLAN (od
       WHERE (od.order_id=m_case->qual[ml_idx1].proc[ml_idx2].f_order_id)
        AND od.oe_field_meaning="ANESTHESIATYPE"
        AND (od.action_sequence=
       (SELECT
        max(od2.action_sequence)
        FROM order_detail od2
        WHERE od2.order_id=od.order_id
         AND od2.oe_field_meaning="ANESTHESIATYPE")))
      ORDER BY od.detail_sequence
      HEAD REPORT
       m_case->qual[ml_idx1].proc[ml_idx2].s_anes_type = ""
      DETAIL
       IF (size(trim(m_case->qual[ml_idx1].proc[ml_idx2].s_anes_type,3))=0)
        m_case->qual[ml_idx1].proc[ml_idx2].s_anes_type = trim(od.oe_field_display_value,3)
       ELSE
        m_case->qual[ml_idx1].proc[ml_idx2].s_anes_type = concat(m_case->qual[ml_idx1].proc[ml_idx2].
         s_anes_type,"; ",trim(od.oe_field_display_value,3))
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
 ENDFOR
 DECLARE mf_page_size = f8 WITH protect, constant(13.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 IF (mn_ops=1)
  EXECUTE bhs_rpt_surg_sched_ps  $OUTDEV
 ELSE
  SET d0 = sec_head(rpt_render)
  IF ((m_case->l_cnt > 0))
   SET ms_day = concat("Surgery Schedule - For: ",format(m_case->qual[1].f_case_date,"WWWWWWWWW;;D"),
    " ",m_case->qual[1].s_start_date)
   SET d0 = sec_day(rpt_render)
   SET ms_prev_date = m_case->qual[1].s_start_date
   SET ms_prev_room = m_case->qual[1].s_or_room
  ENDIF
  SET d0 = sec_line1(rpt_render)
  SET d0 = sec_fields1(rpt_render)
  SET d0 = sec_fields2(rpt_render)
  SET d0 = sec_line1(rpt_render)
  FOR (ml_idx1 = 1 TO m_case->l_cnt)
    SET ms_day = concat("Surgery Schedule - For: ",format(m_case->qual[ml_idx1].f_case_date,
      "WWWWWWWWW;;D")," ",m_case->qual[ml_idx1].s_start_date)
    SET ms_cur_date = m_case->qual[ml_idx1].s_start_date
    SET ms_cur_room = m_case->qual[ml_idx1].s_or_room
    SET ms_total_dur = concat("Tot Length: ",cnvtstring(m_case->qual[ml_idx1].l_tot_dur))
    IF (ms_cur_date != ms_prev_date)
     SET ms_prev_date = ms_cur_date
     SET ms_prev_room = ms_cur_room
     SET _yoffset = 13.18
     SET d0 = sec_foot(rpt_render)
     SET d0 = pagebreak(0)
     SET d0 = sec_day(rpt_render)
     SET d0 = sec_line1(rpt_render)
     SET d0 = sec_fields1(rpt_render)
     SET d0 = sec_fields2(rpt_render)
     SET d0 = sec_line1(rpt_render)
    ENDIF
    SET ml_continue = 1
    SET mf_rem_space = (mf_page_size - ((((_yoffset+ sec_body1(rpt_calcheight))+ sec_line2(
     rpt_calcheight))+ sec_comment(rpt_calcheight,5.0,ml_continue))+ (0.63 * m_case->qual[ml_idx1].
    p_cnt)))
    IF (mf_rem_space <= 0.5)
     SET _yoffset = 13.18
     SET d0 = sec_foot(rpt_render)
     SET d0 = pagebreak(0)
     SET d0 = sec_day(rpt_render)
     SET d0 = sec_line1(rpt_render)
     SET d0 = sec_fields1(rpt_render)
     SET d0 = sec_fields2(rpt_render)
     SET d0 = sec_line1(rpt_render)
    ENDIF
    IF (ms_prev_room != ms_cur_room)
     SET d0 = sec_line1(rpt_render)
     SET ms_prev_room = ms_cur_room
    ENDIF
    SET d0 = sec_body1(rpt_render)
    IF ((m_case->qual[ml_idx1].p_cnt > 0))
     FOR (ml_idx2 = 1 TO m_case->qual[ml_idx1].p_cnt)
      SET d0 = sec_body2(rpt_render)
      IF ((m_case->qual[ml_idx1].proc[ml_idx2].s_pref_card="Pref Card: No"))
       SET d0 = sec_pref(rpt_render)
      ENDIF
     ENDFOR
    ENDIF
    SET d0 = sec_comment(rpt_render,5.0,ml_continue)
    SET d0 = sec_line2(rpt_render)
  ENDFOR
  SET _yoffset = 13.18
  SET d0 = sec_foot(rpt_render)
  SET d0 = finalizereport(value( $OUTDEV))
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ENDIF
 SET last_mod =
 "005 06/19/18 Dave McDonald Added ops job functionality, created a PostScript layout for printing"
END GO
