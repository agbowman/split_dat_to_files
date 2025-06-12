CREATE PROGRAM bhs_ed_disch_contact_list
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE ed_disch_contact_list(ncalc=i2) = f8 WITH protect
 DECLARE ed_disch_contact_listabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times9b0 = i4 WITH noconstant(0), protect
 DECLARE _times11b0 = i4 WITH noconstant(0), protect
 DECLARE _times110 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
 SUBROUTINE ed_disch_contact_list(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ed_disch_contact_listabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE ed_disch_contact_listabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(11.000000), private
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.500),(offsety+ 0.500),7.500,10.000,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.573)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times110)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "If you need to find a doctor, you can call                                   for a referral at                       .",
      char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 3.833)
    SET rptsd->m_width = 1.406
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health Link",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 6.177)
    SET rptsd->m_width = 1.292
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("(413) 794-2255",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.500),(offsety+ 0.823),7.500,0.417,
     rpt_fill,uar_rptencodecolor(242,242,242))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.958)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MEDICAL SERVICES",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.005),(offsety+ 0.833),(offsetx+ 3.005),(offsety+
     3.198))
    SET rptsd->m_y = (offsety+ 0.958)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PEDIATRIC RESOURCES",char(0)))
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.505),(offsety+ 0.833),(offsetx+ 5.505),(offsety+
     3.208))
    SET rptsd->m_y = (offsety+ 0.958)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EMERGENCY HELP",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.500),(offsety+ 3.198),7.500,0.417,
     rpt_fill,uar_rptencodecolor(242,242,242))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_ED_DISCH_CONTACT_LIST"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.00
   SET rptreport->m_marginright = 0.00
   SET rptreport->m_margintop = 0.00
   SET rptreport->m_marginbottom = 0.00
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
   SET rptfont->m_pointsize = 11
   SET _times110 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times11b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _times9b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = ed_disch_contact_list(rpt_render)
 SET d0 = finalizereport( $OUTDEV)
END GO
