CREATE PROGRAM bhs_rpt_notes_faxing:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Status:" = "",
  "Delivery Type:" = "",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Physician Last Name:" = "",
  "Physician" = 0,
  "Patient MRN:" = "",
  "Select Patient" = 0
  WITH outdev, s_status, s_deliv_type,
  s_beg_dt, s_end_dt, s_phys_last_name,
  f_phys_id, s_pat_mrn, f_person_id
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line(ncalc=i2) = f8 WITH protect
 DECLARE sec_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_phys(ncalc=i2) = f8 WITH protect
 DECLARE sec_physabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_detail(ncalc=i2) = f8 WITH protect
 DECLARE sec_detailabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line2(ncalc=i2) = f8 WITH protect
 DECLARE sec_line2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
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
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE __run_date = vc WITH noconstant(build2(trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d")),char(0
      ))), protect
   DECLARE __end_sysdate = vc WITH noconstant(build2(trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d")),
     char(0))), protect
   DECLARE __beg_sysdate = vc WITH noconstant(build2(trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d")),
     char(0))), protect
   DECLARE __filter_calc = vc WITH noconstant(build2(
     IF (mf_phys_id=0
      AND mf_person_id=0) "No patient or Physician filter set"
     ELSEIF (mf_phys_id > 0
      AND mf_person_id=0) concat("PHYS: ",ms_phys_name)
     ELSEIF (mf_phys_id=0
      AND mf_person_id > 0) concat("Patient: ",ms_phys_name)
     ENDIF
     ,char(0))), protect
   DECLARE __found_cnt = vc WITH noconstant(build2(trim(cnvtstring(size(m_rec->ids,5))),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Notes Faxing Audit:  Performed on",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__run_date)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__end_sysdate)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__beg_sysdate)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("-",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Search for status: ",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Found: ",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Filter by:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__filter_calc)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_status,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__found_cnt)
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_phys(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_physabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_physabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __s_phys_name = vc WITH noconstant(build2(m_rec->det[d.seq].s_phys_name,char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.000),7.542,0.250,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physician: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_phys_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
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
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE __status_string = vc WITH noconstant(build2(
     IF ((m_rec->det[d.seq].s_phys_desc="Fail")) concat("Fail - ",m_rec->det[d.seq].s_phys_msg)
     ELSE concat("Success: ",m_rec->det[d.seq].s_phys_desc)
     ENDIF
     ,char(0))), protect
   DECLARE __s_pat_name = vc WITH noconstant(build2(m_rec->det[d.seq].s_pat_name,char(0))), protect
   DECLARE __s_event_msg = vc WITH noconstant(build2(m_rec->det[d.seq].s_event_msg,char(0))), protect
   DECLARE __s_fax_dt_tm = vc WITH noconstant(build2(m_rec->det[d.seq].s_fax_dt_tm,char(0))), protect
   DECLARE __s_fin = vc WITH noconstant(build2(m_rec->det[d.seq].s_fin,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__status_string)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_pat_name)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 4.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_event_msg)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_fax_dt_tm)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct #: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_fin)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status: ",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),(offsety+ 0.000),(offsetx+ 7.250),(offsety+
     0.000))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_NOTES_FAXING"
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
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
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
 END ;Subroutine
 SET d0 = initializereport(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 ids[*]
     2 f_log_id = f8
     2 f_detail_id = f8
     2 f_grp_num = i4
   1 det[*]
     2 f_detail_id = f8
     2 l_grp_num = i4
     2 f_phys_id = f8
     2 s_phys_name = vc
     2 s_phys_desc = vc
     2 s_phys_msg = vc
     2 f_pat_id = f8
     2 s_pat_name = vc
     2 s_pat_desc = vc
     2 s_pat_msg = vc
     2 f_encntr_id = f8
     2 s_fin = vc
     2 f_event_id = f8
     2 s_event_desc = vc
     2 s_event_msg = vc
     2 s_fax_dt_tm = vc
 ) WITH protect
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_deliv_type = vc WITH protect, constant(trim(cnvtupper( $S_DELIV_TYPE)))
 DECLARE ms_status = vc WITH protect, constant(trim(cnvtupper( $S_STATUS)))
 DECLARE mf_phys_id = f8 WITH protect, constant(cnvtreal( $F_PHYS_ID))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE ms_prg_name = vc WITH protect, constant("BHS_OPS_FAX_POWERNOTES")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_parser = vc WITH protect, noconstant(" ")
 DECLARE ms_pat_name = vc WITH protect, noconstant(" ")
 DECLARE ms_phys_name = vc WITH protect, noconstant(" ")
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 CALL echo("set parser strings")
 IF (mf_phys_id > 0
  AND mf_person_id > 0)
  SELECT INTO "nl:"
   FROM person p
   WHERE p.person_id=mf_person_id
   HEAD p.person_id
    ms_pat_name = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.person_id=mf_phys_id
   HEAD p.person_id
    ms_phys_name = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  CALL echo("parser1")
  SET ms_parser = concat(" bd.bhs_log_detail_id in (select x.bhs_log_detail_id",
   "                          from bhs_log_detail x",
   "                          where x.bhs_log_id = bl.bhs_log_id",
   '                            and x.parent_entity_name = "prsnl_id"',
   "                            and x.parent_entity_id = ",
   trim(cnvtstring(mf_phys_id)),"                            and exists(select y.bhs_log_id",
   "                                       from bhs_log_detail y",
   "                                       where y.bhs_log_id = x.bhs_log_id",
   '                                         and y.parent_entity_name = "person_id"',
   "                                         and y.parent_entity_id = ",trim(cnvtstring(mf_person_id)
    ),"                                         and y.detail_group = x.detail_group))")
 ELSEIF (mf_phys_id > 0
  AND mf_person_id <= 0)
  CALL echo("parser2")
  SET ms_parser = concat(" bd.bhs_log_detail_id in (select x.bhs_log_detail_id",
   "                          from bhs_log_detail x",
   "                          where x.bhs_log_id = bl.bhs_log_id",
   '                            and x.parent_entity_name = "prsnl_id"',
   "                            and x.parent_entity_id = ",
   trim(cnvtstring(mf_phys_id)),")")
 ELSEIF (mf_phys_id <= 0
  AND mf_person_id > 0)
  CALL echo("parser3")
  SET ms_parser = concat(" bd.bhs_log_detail_id in (select x.bhs_log_detail_id",
   "                          from bhs_log_detail x",
   "                          where x.bhs_log_id = bl.bhs_log_id",
   '                            and x.parent_entity_name = "person_id"',
   "                            and x.parent_entity_id = ",
   trim(cnvtstring(mf_person_id)),")")
 ELSEIF (mf_phys_id <= 0
  AND mf_person_id <= 0)
  CALL echo("parser4")
  SET ms_parser = ' bd.bhs_log_id = bl.bhs_log_id and bd.parent_entity_name = "prsnl_id"'
 ENDIF
 CALL echo(ms_parser)
 SELECT
  IF (ms_status="FAIL")
   PLAN (bl
    WHERE bl.start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND bl.object_name=ms_prg_name)
    JOIN (bd
    WHERE parser(ms_parser)
     AND bd.description="Fail")
   ORDER BY bl.bhs_log_id, bd.detail_group, bd.detail_seq
   WITH nocounter
  ELSEIF (ms_status="SUCCESS")
   PLAN (bl
    WHERE bl.start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
     AND bl.object_name=ms_prg_name)
    JOIN (bd
    WHERE parser(ms_parser)
     AND bd.description != "Fail")
   ORDER BY bl.bhs_log_id, bd.detail_group, bd.detail_seq
   WITH nocounter
  ELSE
  ENDIF
  INTO "nl:"
  FROM bhs_log bl,
   bhs_log_detail bd
  PLAN (bl
   WHERE bl.start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND bl.object_name=ms_prg_name)
   JOIN (bd
   WHERE parser(ms_parser))
  ORDER BY bl.bhs_log_id, bd.detail_group, bd.detail_seq
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   CALL echo(bl.object_name), pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->ids,pl_cnt),
   m_rec->ids[pl_cnt].f_log_id = bl.bhs_log_id, m_rec->ids[pl_cnt].f_detail_id = bd.bhs_log_detail_id,
   m_rec->ids[pl_cnt].f_grp_num = bd.detail_group
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->ids,5))),
   bhs_log_detail b
  PLAN (d)
   JOIN (b
   WHERE (b.bhs_log_id=m_rec->ids[d.seq].f_log_id)
    AND (b.detail_group=m_rec->ids[d.seq].f_grp_num))
  ORDER BY d.seq
  HEAD REPORT
   pl_cnt = 0
  HEAD b.detail_group
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->det,pl_cnt), m_rec->det[pl_cnt].f_detail_id = b
   .bhs_log_detail_id,
   m_rec->det[pl_cnt].l_grp_num = b.detail_group, m_rec->det[pl_cnt].s_fax_dt_tm = trim(format(b
     .updt_dt_tm,"dd-mmm-yyyy;;d"))
  DETAIL
   CALL echo("*********")
   IF (b.parent_entity_name="person_id")
    m_rec->det[pl_cnt].f_pat_id = b.parent_entity_id, m_rec->det[pl_cnt].s_pat_desc = b.description,
    m_rec->det[pl_cnt].s_pat_msg = b.msg
   ELSEIF (b.parent_entity_name="prsnl_id")
    IF (b.parent_entity_id=0)
     CALL echo(build2(trim(b.description)," ",d.seq," ",pl_cnt)), m_rec->det[pl_cnt].s_phys_name = b
     .msg
    ENDIF
    m_rec->det[pl_cnt].f_phys_id = b.parent_entity_id, m_rec->det[pl_cnt].s_phys_desc = b.description,
    m_rec->det[pl_cnt].s_phys_msg = ""
   ELSEIF (b.parent_entity_name="event_id")
    m_rec->det[pl_cnt].f_event_id = b.parent_entity_id, m_rec->det[pl_cnt].s_event_desc = b
    .description, m_rec->det[pl_cnt].s_event_msg = b.msg
   ELSEIF (b.parent_entity_name="encntr_id")
    m_rec->det[pl_cnt].f_encntr_id = b.parent_entity_id
   ENDIF
   CALL echo(b.parent_entity_id),
   CALL echo(b.description),
   CALL echo(b.msg)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->det,5))),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_rec->det[d.seq].f_pat_id))
  HEAD d.seq
   m_rec->det[d.seq].s_pat_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->det,5))),
   prsnl p
  PLAN (d
   WHERE (m_rec->det[d.seq].f_phys_id > 0))
   JOIN (p
   WHERE (p.person_id=m_rec->det[d.seq].f_phys_id))
  HEAD d.seq
   m_rec->det[d.seq].s_phys_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->det,5))),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=m_rec->det[d.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  HEAD ea.encntr_id
   m_rec->det[d.seq].s_fin = trim(ea.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ps_phys_name = m_rec->det[d.seq].s_phys_name, ps_pat_name = m_rec->det[d.seq].s_pat_name
  FROM (dummyt d  WITH seq = value(size(m_rec->det,5)))
  ORDER BY ps_phys_name, ps_pat_name
  HEAD REPORT
   pl_det_cnt = 0
  HEAD PAGE
   d0 = sec_head(rpt_render), d0 = sec_line(rpt_render)
  HEAD ps_phys_name
   pl_det_cnt = 0, mf_rem_space = (mf_page_size - ((_yoffset+ sec_detail(rpt_calcheight))+ sec_foot(
    rpt_calcheight)))
   IF (mf_rem_space < sec_phys(rpt_calcheight))
    d0 = sec_foot(rpt_render), d0 = pagebreak(0), d0 = sec_head(rpt_render),
    d0 = sec_line(rpt_render)
   ENDIF
   d0 = sec_phys(rpt_render)
  DETAIL
   pl_det_cnt = (pl_det_cnt+ 1), mf_rem_space = (mf_page_size - (_yoffset+ sec_foot(rpt_calcheight)))
   IF (mf_rem_space < sec_detail(rpt_calcheight))
    d0 = sec_foot(rpt_render), d0 = pagebreak(0), d0 = sec_head(rpt_render),
    d0 = sec_line(rpt_render), d0 = sec_phys(rpt_render)
   ENDIF
   IF (pl_det_cnt > 1)
    d0 = sec_line2(rpt_render)
   ENDIF
   d0 = sec_detail(rpt_render)
  FOOT PAGE
   d0 = sec_foot(rpt_render)
  WITH nocounter
 ;end select
 SET d0 = finalizereport(ms_output)
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
