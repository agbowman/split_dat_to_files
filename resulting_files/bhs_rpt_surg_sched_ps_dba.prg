CREATE PROGRAM bhs_rpt_surg_sched_ps:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_day(ncalc=i2) = f8 WITH protect
 DECLARE sec_dayabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line1(ncalc=i2) = f8 WITH protect
 DECLARE sec_line1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line2(ncalc=i2) = f8 WITH protect
 DECLARE sec_line2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_fields1(ncalc=i2) = f8 WITH protect
 DECLARE sec_fields1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_fields2(ncalc=i2) = f8 WITH protect
 DECLARE sec_fields2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_body2(ncalc=i2) = f8 WITH protect
 DECLARE sec_body2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_pref(ncalc=i2) = f8 WITH protect
 DECLARE sec_prefabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_comment(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sec_commentabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE sec_body1(ncalc=i2) = f8 WITH protect
 DECLARE sec_body1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_foot(ncalc=i2) = f8 WITH protect
 DECLARE sec_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times160)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health System",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("OR Schedule from : ",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("to",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 1.865)
    SET rptsd->m_width = 3.823
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_sched_loc,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_beg_dt_tm,char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_end_dt_tm,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_day(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_dayabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_dayabs(ncalc,offsetx,offsety)
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
    SET rptsd->m_width = 3.854
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_day,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.010)
    SET rptsd->m_width = 1.802
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_cur_dt_tm,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_line1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_line1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_line1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.052),(offsetx+ 7.500),(offsety+
     0.052))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_line2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_line2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_line2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.052),(offsetx+ 7.500),(offsety+
     0.052))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_fields1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_fields1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_fields1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.417
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Case #",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Room",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Latex Allergy",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_fields2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_fields2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_fields2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prim Surgeon",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ancillary Code",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Anesthesia ",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Length",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.646)
    SET rptsd->m_width = 1.042
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Modifier",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_body2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_body2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_body2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
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
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primsurg)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ancillary)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__proc)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.885
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__anesthesia)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__length)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.594)
    SET rptsd->m_width = 1.344
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__modifier)
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__assistsurg)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_pref(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_prefabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_prefabs(ncalc,offsetx,offsety)
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
    SET rptsd->m_y = (offsety+ 0.031)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pref)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_comment(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_commentabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_commentabs(ncalc,offsetx,offsety,maxheight,bcontinue)
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
    SET rptsd->m_y = (offsety+ 0.010)
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
     SET _remcomment = (_remcomment+ rptsd->m_drawlength)
    ELSE
     SET _remcomment = 0
    ENDIF
    SET growsum = (growsum+ _remcomment)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.010)
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
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.438)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.229
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
 SUBROUTINE sec_body1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_body1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_body1abs(ncalc,offsetx,offsety)
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
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__datetime)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 0.885
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__type)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__case)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__room)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__latexallergy)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "BHS_RPT_SURG_SCHED_PS"
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
    SET _yoffset = 10.18
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
    rpt_calcheight))+ sec_comment(rpt_calcheight,5.0,ml_continue))+ (0.40 * m_case->qual[ml_idx1].
   p_cnt)))
   IF (mf_rem_space <= 0.25)
    SET _yoffset = 10.18
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
 SET _yoffset = 10.18
 SET d0 = sec_foot(rpt_render)
 SET d0 = finalizereport(value( $OUTDEV))
END GO
