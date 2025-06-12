CREATE PROGRAM bhs_surgical_notify_frm_layout
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE pagebreak(dummy) = null WITH public
 DECLARE finalizereport(ssendreport=vc) = null WITH public
 DECLARE layoutsection0(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH public
 DECLARE layoutsection0abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 public
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
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontlayoutsection0 = i2 WITH noconstant(0), protect
 DECLARE _rempatname19 = i2 WITH noconstant(1), protect
 DECLARE _rempatname27 = i2 WITH noconstant(1), protect
 DECLARE _times120 = i4 WITH noconstant(0), public
 DECLARE _times12b0 = i4 WITH noconstant(0), public
 DECLARE _times100 = i4 WITH noconstant(0), public
 DECLARE _times28b16777215 = i4 WITH noconstant(0), public
 DECLARE _pen0s0c12632256 = i4 WITH noconstant(0), public
 DECLARE _pen14s0c12632256 = i4 WITH noconstant(0), public
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
 SUBROUTINE layoutsection0(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection0abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE layoutsection0abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(7.630000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _rempatname19 = 1
    SET _rempatname27 = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c12632256)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 1.07),7.50,0.30,
     rpt_fill,rpt_white)
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 2.07),7.50,0.30,
     rpt_fill,rpt_white)
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 2.69),7.50,0.30,
     rpt_fill,rpt_white)
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 3.25),7.50,0.30,
     rpt_fill,rpt_white)
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 3.84),7.50,2.47,
     rpt_fill,rpt_white)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.22),(offsety+ 0.22),7.51,6.07,
     rpt_nofill,rpt_white)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c12632256)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 0.80),1.32,5.50,
     rpt_fill,uar_rptencodecolor(192,192,192))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.25),(offsety+ 0.22),7.49,0.57,
     rpt_fill,rpt_black)
   ENDIF
   SET rptsd->m_flags = 68
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.850)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.283
   SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 3.875)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reasons:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 3.592)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Surgeon:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 3.292)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.975)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Surgery:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.725)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.417)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN Number:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.100)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phone Number:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 1.375)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Address:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 1.100)
   SET rptsd->m_x = (offsetx+ 0.300)
   SET rptsd->m_width = 1.192
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.175)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.500
   SET _dummyfont = uar_rptsetfont(_hreport,_times28b16777215)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].title,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.100)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.692
   SET rptsd->m_height = 0.258
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].patientname,char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_y = (offsety+ 3.875)
   SET rptsd->m_x = (offsetx+ 3.717)
   SET rptsd->m_width = 3.967
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempatname19 = _rempatname19
   IF (_rempatname19 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatname19,((size(
        results->qual[1].reasonresults) - _rempatname19)+ 1),results->qual[1].reasonresults)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatname19 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatname19,((size(results->qual[1].
        reasonresults) - _rempatname19)+ 1),results->qual[1].reasonresults)))))
     SET _rempatname19 = (_rempatname19+ rptsd->m_drawlength)
    ELSE
     SET _rempatname19 = 0
    ENDIF
    SET growsum = (growsum+ _rempatname19)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdrempatname19 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatname19,((size(
        results->qual[1].reasonresults) - _holdrempatname19)+ 1),results->qual[1].reasonresults)))
   ELSE
    SET _rempatname19 = _holdrempatname19
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 3.592)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = 0.258
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].surgeon,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 3.292)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].procedure,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.975)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = 0.258
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].proceduredt,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.725)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = 0.258
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].dob,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.100)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.817
   SET rptsd->m_height = 0.258
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].phone,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.417)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.817
   SET rptsd->m_height = 0.258
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].mrn,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.375)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.692
   SET rptsd->m_height = 0.692
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].address,char(0)))
   ENDIF
   SET rptsd->m_flags = 69
   SET rptsd->m_y = (offsety+ 3.875)
   SET rptsd->m_x = (offsetx+ 1.517)
   SET rptsd->m_width = 2.117
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   SET _holdrempatname27 = _rempatname27
   IF (_rempatname27 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatname27,((size(
        results->qual[1].reasons) - _rempatname27)+ 1),results->qual[1].reasons)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatname27 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatname27,((size(results->qual[1].
        reasons) - _rempatname27)+ 1),results->qual[1].reasons)))))
     SET _rempatname27 = (_rempatname27+ rptsd->m_drawlength)
    ELSE
     SET _rempatname27 = 0
    ENDIF
    SET growsum = (growsum+ _rempatname27)
   ENDIF
   SET rptsd->m_flags = 68
   IF (ncalc=rpt_render
    AND _holdrempatname27 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatname27,((size(
        results->qual[1].reasons) - _holdrempatname27)+ 1),results->qual[1].reasons)))
   ELSE
    SET _rempatname27 = _holdrempatname27
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.850)
   SET rptsd->m_x = (offsetx+ 1.675)
   SET rptsd->m_width = 5.692
   SET rptsd->m_height = 0.258
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(results->qual[1].dttm,char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_SURGICAL_NOTIFY_FRM_LAYOUT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
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
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 28
   SET rptfont->m_rgbcolor = rpt_white
   SET _times28b16777215 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_rgbcolor = uar_rptencodecolor(192,192,192)
   SET _pen14s0c12632256 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = uar_rptencodecolor(192,192,192)
   SET _pen0s0c12632256 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET bfirsttime = 1
 WHILE (((_bcontlayoutsection0=1) OR (bfirsttime=1)) )
   SET _bholdcontinue = _bcontlayoutsection0
   SET _fdrawheight = layoutsection0(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ELSEIF (_bholdcontinue=1
    AND _bcontlayoutsection0=0)
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = layoutsection0(rpt_render,(_fenddetail - _yoffset),_bcontlayoutsection0)
   SET bfirsttime = 0
 ENDWHILE
 CALL finalizereport(_sendto)
END GO
