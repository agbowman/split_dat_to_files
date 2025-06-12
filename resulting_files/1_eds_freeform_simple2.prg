CREATE PROGRAM 1_eds_freeform_simple2
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE pagebreak(dummy) = null WITH public
 DECLARE finalizereport(ssendreport=vc) = null WITH public
 DECLARE layoutsection0(ncalc=i2) = f8 WITH public
 DECLARE layoutsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE initializereport(dummy) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _flmargin = f8 WITH noconstant(0.0), protect
 DECLARE _ftmargin = f8 WITH noconstant(0.0), protect
 DECLARE _flabelwidth = f8 WITH noconstant(0.0), protect
 DECLARE _flabelheight = f8 WITH noconstant(0.0), protect
 DECLARE _frowgutter = f8 WITH noconstant(0.0), protect
 DECLARE _fcolgutter = f8 WITH noconstant(0.0), protect
 DECLARE _nrows = i4 WITH noconstant(0), protect
 DECLARE _ncols = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), public
 DECLARE _times16biu0 = i4 WITH noconstant(0), public
 DECLARE _times100 = i4 WITH noconstant(0), public
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), public
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), public
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
 SUBROUTINE layoutsection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE layoutsection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(5.000000), private
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.03),(offsety+ 0.38),3.84,1.31,
     rpt_fill,uar_rptencodecolor(192,192,192))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.500
    SET _oldfont = uar_rptsetfont(_hreport,_times16biu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Medical Center",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.854
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(128,255,255))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Update Dt Tm: ",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_y = (offsety+ 0.906)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.854
    SET rptsd->m_height = 0.250
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(128,255,255))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Person ID: ",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.name_full_formatted,char(0)))
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(p.person_id),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 0.854
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(128,255,255))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Person Name: ",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(p.updt_dt_tm,"mm/dd/yyyy hh:mm"
       ),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code128,(offsetx+ 0.63),(offsety+ 1.88))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 2.22
    SET rptbce->m_height = 0.31
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bprintinterp = 0
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,nullterm(build2(p.person_id)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "1_eds_freeform_simple2"
   SET rptreport->m_pagewidth = 4.00
   SET rptreport->m_pageheight = 5.00
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
   CALL _createfonts(0)
   CALL _createpens(0)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
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
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _times16biu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE get_names_id(dummy) = null WITH public
 SUBROUTINE get_names_id(ncalc)
   CALL initializereport(0)
   SET _flmargin = rptreport->m_marginleft
   SET _ftmargin = rptreport->m_margintop
   SET _flabelwidth = 4.000000
   SET _flabelheight = 5.000000
   SET _frowgutter = 0.000000
   SET _fcolgutter = 0.000000
   SET _ncols = 1
   SET _nrows = 1
   SELECT
    p.name_full_formatted, p.person_id, p.updt_dt_tm
    FROM person p
    HEAD REPORT
     _d0 = p.name_full_formatted, _d1 = p.person_id, _d2 = p.updt_dt_tm,
     x = 0, y = 0
    DETAIL
     IF (y >= _nrows)
      x = 0, y = 0,
      CALL pagebreak(0)
     ENDIF
     _xoffset = ((_flmargin+ (_flabelwidth * x))+ (_fcolgutter * x)), _yoffset = ((_ftmargin+ (
     _flabelheight * y))+ (_frowgutter * y)), dummy_val = layoutsection0(rpt_render),
     x = (x+ 1)
     IF (x >= _ncols)
      x = 0, y = (y+ 1)
     ENDIF
    WITH maxrec = 10, nocounter, separator = " ",
     format
   ;end select
   CALL finalizereport(_sendto)
 END ;Subroutine
 CALL get_names_id(0)
END GO
