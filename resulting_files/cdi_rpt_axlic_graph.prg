CREATE PROGRAM cdi_rpt_axlic_graph
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Begin Time" = "CURTIME",
  "End Time" = "CURTIME",
  "License Type" = "AX License                                                                      ",
  "All Licenses" = "1",
  "License Groups" = ""
  WITH outdev, begindate, enddate,
  begintime, endtime, licensetype,
  alllicenses, licensegroups
 EXECUTE reportrtl
 EXECUTE ccl_rptapi_graphrec
 RECORD batch_lyt(
   1 batch_details[*]
     2 licgrpnm = vc
     2 conndatetime = dq8
     2 pctusage = f8
     2 numused = i4
     2 numavail = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD templic(
   1 qual[*]
     2 licgrpnm = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE licquery(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE graphsection(ncalc=i2) = f8 WITH protect
 DECLARE graphsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant(0), protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
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
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times10bi0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times16bi0 = i4 WITH noconstant(0), protect
 DECLARE _pen10s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE batch_details_licgrpnm = vc WITH protect
 DECLARE batch_details_pctusage = vc WITH noconstant("0.0"), protect
 DECLARE batch_details_conndatetime = vc WITH protect
 DECLARE slicname = vc WITH protect
 DECLARE cnt_licenses = i2 WITH protect
 SUBROUTINE licquery(dummy)
   SELECT INTO outdev
    batch_lyt_batch_details_licgrpnm = substring(1,30,batch_lyt->batch_details[d2.seq].licgrpnm),
    batch_lyt_batch_details_conndatetime = batch_lyt->batch_details[d2.seq].conndatetime,
    batch_lyt_batch_details_pctusage = batch_lyt->batch_details[d2.seq].pctusage,
    batch_lyt_batch_details_numused = batch_lyt->batch_details[d2.seq].numused,
    batch_lyt_batch_details_numavail = batch_lyt->batch_details[d2.seq].numavail
    FROM (dummyt d2  WITH seq = value(size(batch_lyt->batch_details,5)))
    PLAN (d2)
    ORDER BY batch_lyt_batch_details_pctusage DESC
    HEAD REPORT
     _d0 = batch_lyt_batch_details_licgrpnm, _d1 = batch_lyt_batch_details_conndatetime, _d2 =
     batch_lyt_batch_details_pctusage,
     _d3 = batch_lyt_batch_details_numused, _d4 = batch_lyt_batch_details_numavail, _fenddetail = (
     rptreport->m_pageheight - rptreport->m_marginbottom),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail > (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ graphsection(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render), _fdrawheight = graphsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = graphsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headpagesection(rpt_render)
    HEAD batch_lyt_batch_details_pctusage
     row + 0
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  batch_lyt_batch_details_pctusage
     row + 0
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
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
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.340000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.583
    SET _oldfont = uar_rptsetfont(_hreport,_times16bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat("ProVision Document Imaging",
       _crlf,"License Monitor Summary and Graph Report"),char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 4.479
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2( $BEGINDATE,"  -  ", $ENDDATE),
      char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 4.490
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(build2("License Type: ",
         $LICENSETYPE)),char(0)))
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 1.552)
    SET rptsd->m_width = 4.448
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2( $BEGINTIME,"  -  ", $ENDTIME),
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE graphsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = graphsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE graphsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.310000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
    IF (size(batch_lyt->batch_details,5) > 0)
     SET rptgraphrec->m_ntype = 1
     SET rptgraphrec->m_fleft = (0.063000+ offsetx)
     SET rptgraphrec->m_ftop = (0.000000+ offsety)
     SET rptgraphrec->m_fwidth = 7.375000
     SET rptgraphrec->m_fheight = 3.188000
     SET rptgraphrec->m_stitle = "AX License Usage"
     SET rptgraphrec->m_lsttitle.m_sfontname = rpt_times
     SET rptgraphrec->m_lsttitle.m_nfontsize = 12
     SET rptgraphrec->m_lsttitle.m_bold = rpt_on
     SET rptgraphrec->m_lsttitle.m_italic = rpt_off
     SET rptgraphrec->m_lsttitle.m_underline = rpt_off
     SET rptgraphrec->m_lsttitle.m_strikethrough = rpt_off
     SET rptgraphrec->m_lsttitle.m_nbackmode = 0
     SET rptgraphrec->m_lsttitle.m_rgbbackcolor = rpt_white
     SET rptgraphrec->m_lsttitle.m_rgbfontcolor = rpt_black
     SET rptgraphrec->m_ssubtitle = ""
     SET rptgraphrec->m_sxtitle = "Date/Time"
     SET rptgraphrec->m_lstxtitle.m_sfontname = rpt_times
     SET rptgraphrec->m_lstxtitle.m_nfontsize = 10
     SET rptgraphrec->m_lstxtitle.m_bold = rpt_off
     SET rptgraphrec->m_lstxtitle.m_italic = rpt_off
     SET rptgraphrec->m_lstxtitle.m_underline = rpt_off
     SET rptgraphrec->m_lstxtitle.m_strikethrough = rpt_off
     SET rptgraphrec->m_lstxtitle.m_nbackmode = 0
     SET rptgraphrec->m_lstxtitle.m_rgbbackcolor = rpt_white
     SET rptgraphrec->m_lstxtitle.m_rgbfontcolor = rpt_black
     SET rptgraphrec->m_sytitle = "Percentage Used"
     SET rptgraphrec->m_lstytitle.m_sfontname = rpt_times
     SET rptgraphrec->m_lstytitle.m_nfontsize = 10
     SET rptgraphrec->m_lstytitle.m_bold = rpt_off
     SET rptgraphrec->m_lstytitle.m_italic = rpt_off
     SET rptgraphrec->m_lstytitle.m_underline = rpt_off
     SET rptgraphrec->m_lstytitle.m_strikethrough = rpt_off
     SET rptgraphrec->m_lstytitle.m_nbackmode = 0
     SET rptgraphrec->m_lstytitle.m_rgbbackcolor = rpt_white
     SET rptgraphrec->m_lstytitle.m_rgbfontcolor = rpt_black
     SET rptgraphrec->m_bxgrid = 0
     SET rptgraphrec->m_bygrid = 1
     SET rptgraphrec->m_nytype = 1
     SET rptgraphrec->m_syformat = ""
     SET rptgraphrec->m_syformat = ""
     SET rptgraphrec->m_fyindex = 0
     SET rptgraphrec->m_bymin = 1
     SET rptgraphrec->m_fymin = 0
     SET rptgraphrec->m_bymax = 1
     SET rptgraphrec->m_fymax = 100
     SET rptgraphrec->m_blegend = 1
     SET rptgraphrec->m_nlegendpos = 0
     SET rptgraphrec->m_lstlegend.m_sfontname = rpt_times
     SET rptgraphrec->m_lstlegend.m_nfontsize = 10
     SET rptgraphrec->m_lstlegend.m_bold = rpt_off
     SET rptgraphrec->m_lstlegend.m_italic = rpt_off
     SET rptgraphrec->m_lstlegend.m_underline = rpt_off
     SET rptgraphrec->m_lstlegend.m_strikethrough = rpt_off
     SET rptgraphrec->m_lstlegend.m_nbackmode = 0
     SET rptgraphrec->m_lstlegend.m_rgbbackcolor = rpt_white
     SET rptgraphrec->m_lstlegend.m_rgbfontcolor = rpt_black
     SET rptgraphrec->m_nlegendbkmode = 1
     SET rptgraphrec->m_rgblegendbkcolor = rpt_white
     SET rptgraphrec->m_nbkmode = 0
     SET rptgraphrec->m_rgbbkcolor = rpt_white
     SET rptgraphrec->m_fbordersize = 0.010
     SET rptgraphrec->m_rgbbordercolor = rpt_black
     SET rptgraphrec->m_nborderstyle = 0
     SET rptgraphrec->m_bshadow = 0
     SET rptgraphrec->m_ngridbkmode = 1
     SET rptgraphrec->m_rgbgridbkcolor = uar_rptencodecolor(192,192,192)
     SET rptgraphrec->m_rgbgridcolor = rpt_black
     SET rptgraphrec->m_fgridsize = 0.01
     SET rptgraphrec->m_ngridstyle = 0
     SET rptgraphrec->m_lstxgrid.m_sfontname = rpt_times
     SET rptgraphrec->m_lstxgrid.m_nfontsize = 10
     SET rptgraphrec->m_lstxgrid.m_bold = rpt_off
     SET rptgraphrec->m_lstxgrid.m_italic = rpt_off
     SET rptgraphrec->m_lstxgrid.m_underline = rpt_off
     SET rptgraphrec->m_lstxgrid.m_strikethrough = rpt_off
     SET rptgraphrec->m_lstxgrid.m_nbackmode = 0
     SET rptgraphrec->m_lstxgrid.m_rgbbackcolor = rpt_white
     SET rptgraphrec->m_lstxgrid.m_rgbfontcolor = rpt_black
     SET rptgraphrec->m_lstygrid.m_sfontname = rpt_times
     SET rptgraphrec->m_lstygrid.m_nfontsize = 10
     SET rptgraphrec->m_lstygrid.m_bold = rpt_off
     SET rptgraphrec->m_lstygrid.m_italic = rpt_off
     SET rptgraphrec->m_lstygrid.m_underline = rpt_off
     SET rptgraphrec->m_lstygrid.m_strikethrough = rpt_off
     SET rptgraphrec->m_lstygrid.m_nbackmode = 0
     SET rptgraphrec->m_lstygrid.m_rgbbackcolor = rpt_white
     SET rptgraphrec->m_lstygrid.m_rgbfontcolor = rpt_black
     SET rptgraphrec->m_ncontrollimits = 0
     EXECUTE ccl_rptapi_graph
     SET stat = initrec(rptgraphrec)
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (size(batch_lyt->batch_details,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("License Group Name",char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.188
    IF (size(batch_lyt->batch_details,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Peak Connection Time",char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.188
    IF (size(batch_lyt->batch_details,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Percentage - (Num Used/Num Avail)",
       char(0)))
    ENDIF
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (size(batch_lyt->batch_details,5) <= 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("NO RECORDS FOUND",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (size(batch_lyt->batch_details,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_licgrpnm,char
       (0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    IF (size(batch_lyt->batch_details,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(
        batch_lyt_batch_details_conndatetime,"DD-MMM-YYYY HH:MM:SS;;D"),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.188
    IF (size(batch_lyt->batch_details,5) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(trim(cnvtstring(
          batch_lyt_batch_details_pctusage)),"% - (",trim(cnvtstring(batch_lyt_batch_details_numused
          )),"/",trim(cnvtstring(batch_lyt_batch_details_numavail)),
        ")"),char(0)))
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CDI_RPT_AXLIC_GRAPH"
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
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_on
   SET _times16bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_italic = rpt_off
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_italic = rpt_on
   SET _times10bi0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010
   SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET _bsubreport = 1
 EXECUTE cdi_rpt_axlic_graph_drvr  $OUTDEV,  $BEGINDATE,  $ENDDATE,
  $BEGINTIME,  $ENDTIME,  $LICENSETYPE,
  $ALLLICENSES,  $LICENSEGROUPS
 SET _bsubreport = 0
 SET _fholdenddetail = _fenddetail
 CALL licquery(0)
 SET _fenddetail = _fholdenddetail
 CALL finalizereport(_sendto)
END GO
