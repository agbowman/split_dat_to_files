CREATE PROGRAM ccl_text2pdf
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Filename:" = "",
  "Style:" = 1
  WITH outdev, filein, nstyle
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE pagebreak(dummy) = null WITH public
 DECLARE initializereport(dummy) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _flmargin = f8 WITH noconstant(0.0), protect
 DECLARE _ftmargin = f8 WITH noconstant(0.0), protect
 DECLARE _flabelwidth = f8 WITH noconstant(0.0), protect
 DECLARE _flabelheight = f8 WITH noconstant(0.0), protect
 DECLARE _frowgutter = f8 WITH noconstant(0.0), protect
 DECLARE _fcolgutter = f8 WITH noconstant(0.0), protect
 DECLARE _nrows = i4 WITH noconstant(0), protect
 DECLARE _ncols = i4 WITH noconstant(0), protect
 DECLARE _nlabelcnt = i4 WITH noconstant(0), protect
 DECLARE _nmaxlabels = i4 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), public
 DECLARE _courier100 = i4 WITH noconstant(0), public
 DECLARE _times100 = i4 WITH noconstant(0), public
 DECLARE _pen10s0c0 = i4 WITH noconstant(0), public
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   IF (dummy)
    SET rptfont->m_rgbcolor = rpt_white
   ELSE
    SET rptfont->m_rgbcolor = rpt_black
   ENDIF
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 7
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.01
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH public)
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
   WHILE (_errorfound=rpt_errorfound)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (detailsection7pt(ncalc=i2) =f8 WITH public)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection7ptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsection7ptabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH public)
  IF (ncalc=0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.01
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 8.25
   SET rptsd->m_height = 0.15
   SET _oldfont = uar_rptsetfont(_hreport,_courier70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(m_slineout))
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   SET _yoffset += 0.150000
  ENDIF
  RETURN(0.150000)
 END ;Subroutine
 SUBROUTINE (detailsection10pt(ncalc=i2) =f8 WITH public)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection10ptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsection10ptabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH public)
  IF (ncalc=0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.01
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 8.25
   SET rptsd->m_height = 0.19
   SET _oldfont = uar_rptsetfont(_hreport,_courier100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
   SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(m_slineout))
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   SET _yoffset += 0.190000
  ENDIF
  RETURN(0.190000)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 84
   SET rptreport->m_reportname = "lvp_text2pdf"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
   SET rptreport->m_margintop = 0.25
   SET rptreport->m_marginbottom = 0.25
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _stat = _createfonts(_isfontcolorwhite)
   SET _stat = _createpens(0)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
 END ;Subroutine
 DECLARE selecttext(dummy) = null WITH public
 SET _sendto =  $OUTDEV
 CALL selecttext(0)
 SUBROUTINE selecttext(dummy)
   DECLARE _isfontcolorwhite = i2 WITH noconstant(0), protect
   DECLARE _initreport = i2 WITH noconstant(0), protect
   DECLARE m_bcompressed = i2 WITH noconstant(0), protect
   DECLARE m_blandscape = i2 WITH noconstant(0), protect
   DECLARE m_slineout = vc WITH noconstant(""), protect
   DECLARE sfilecpc = vc WITH noconstant( $FILEIN), private
   DECLARE scpcline = vc WITH noconstant("DIO(00)COMP(0)LAND(0)")
   DECLARE nfinddot = i2 WITH noconstant(findstring(".", $FILEIN,1,1)), private
   IF (nfinddot
    AND ( $NSTYLE=1))
    SET sfilecpc = cnvtlower(concat(substring(nfinddot,(textlen( $FILEIN) - nfinddot), $FILEIN),"_",
      substring((nfinddot+ 1),((textlen( $FILEIN) - nfinddot) - 1), $FILEIN),".cpc"))
   ELSE
    SET sfilecpc = cnvtlower(concat( $FILEIN,"_dat.cpc"))
   ENDIF
   CASE ( $NSTYLE)
    OF 1:
     FREE DEFINE rtl2
     FREE SET pdf_filecpc
     SET logical pdf_filecpc value(sfilecpc)
     IF (findfile(sfilecpc)=1)
      DEFINE rtl2 "PDF_FILECPC"
      SELECT INTO "nl:"
       rt.line
       FROM rtl2t rt
       DETAIL
        scpcline = rt.line
       WITH nocounter
      ;end select
     ENDIF
    OF 2:
     SET scpcline = "DIO(00)COMP(0)LAND(0)"
    OF 3:
     SET scpcline = "DIO(00)COMP(1)LAND(0)"
    OF 4:
     SET scpcline = "DIO(00)COMP(0)LAND(1)"
    OF 5:
     SET scpcline = "DIO(00)COMP(1)LAND(1)"
    ELSE
     SET scpcline = "DIO(00)COMP(0)LAND(0)"
   ENDCASE
   IF (substring(13,1,scpcline)="1")
    SET m_bcompressed = 1
   ELSE
    SET m_bcompressed = 0
   ENDIF
   IF (substring(20,1,scpcline)="1")
    SET m_blandscape = 1
   ELSE
    SET m_blandscape = 0
   ENDIF
   FREE DEFINE rtl2
   FREE SET pdf_file
   SET logical pdf_file value( $FILEIN)
   DEFINE rtl2 "PDF_FILE"
   SELECT
    rt.line
    FROM rtl2t rt
    HEAD REPORT
     CALL initializereport(0), _initreport = 1
     IF (( $NSTYLE=1))
      IF (textlen(trim(rt.line)) > 132
       AND m_blandscape=1)
       m_bcompressed = 1
      ELSEIF (textlen(trim(rt.line)) > 80
       AND m_blandscape=0)
       m_bcompressed = 1
      ENDIF
     ENDIF
    HEAD PAGE
     CALL echo("head page")
     IF (curpage > 1)
      CALL pagebreak(0)
     ENDIF
    DETAIL
     m_slineout = rt.line,
     CALL echo("detail")
     IF (substring(1,1,rt.line)=char(12))
      BREAK
     ELSE
      IF (m_bcompressed)
       fdetail = detailsection7pt(1)
      ELSE
       fdetail = detailsection10pt(1)
      ENDIF
      IF (((_yoffset+ fdetail) > 10.50))
       BREAK
      ENDIF
      IF (m_bcompressed)
       fdetail = detailsection7pt(0)
      ELSE
       fdetail = detailsection10pt(0)
      ENDIF
     ENDIF
    WITH format = variable
   ;end select
   FREE DEFINE rtl2
   IF (_initreport=0)
    SET _isfontcolorwhite = 1
    CALL initializereport(0)
    SET _fxstat = detailsection10pt(0)
   ENDIF
   SET dummyvar = finalizereport( $OUTDEV)
 END ;Subroutine
END GO
