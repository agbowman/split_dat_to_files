CREATE PROGRAM ams_health_check_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE cclbuildhlink(vcprog=vc,vcparams=vc,nviewtype=i2,vcdescription=vc) = vc WITH protect
 DECLARE cclbuildapplink(nmode=i2,vcappname=vc,vcparams=vc,vcdescription=vc) = vc WITH protect
 DECLARE cclbuildweblink(vcaddress=vc,nmode=i2,vcdescription=vc) = vc WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE query1html(ndummy=i2) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headreportsectionhtml(dummy=i2) = null WITH protect
 DECLARE urlsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE urlsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE urlsectionhtml(dummy=i2) = null WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesectionhtml(dummy=i2) = null WITH protect
 DECLARE headcatsection(ncalc=i2) = f8 WITH protect
 DECLARE headcatsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headcatsectionhtml(dummy=i2) = null WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsectionhtml(dummy=i2) = null WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesectionhtml(dummy=i2) = null WITH protect
 DECLARE footreportsection(ncalc=i2) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportsectionhtml(dummy=i2) = null WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 RECORD _htmlfileinfo(
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_offset = i4
   1 file_dir = i4
 ) WITH protect
 SET _htmlfileinfo->file_desc = 0
 DECLARE _htmlfilestat = i4 WITH noconstant(0), protect
 DECLARE _bgeneratehtml = i1 WITH noconstant(evaluate(validate(request->output_device,"N"),"MINE",1,
   '"MINE"',1,
   0)), protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remtxtrptdesc = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bconturlsection = i2 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b4440443 = i4 WITH noconstant(0), protect
 DECLARE _helvetica98421504 = i4 WITH noconstant(0), protect
 DECLARE _helvetica14b16777215 = i4 WITH noconstant(0), protect
 DECLARE _helvetica26b16777215 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b255 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10u16711680 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b13800461 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage2 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
  SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_bmp,"cer_install:health_check_header.bmp")
  SET _himage2 = uar_rptinitimagefromfile(_hreport,rpt_bmp,"cer_install:small_logo.bmp")
 END ;Subroutine
 SUBROUTINE cclbuildhlink(vcprogname,vcparams,nwindow,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    SET vcreturn = build(^<a href='javascript:CCLLINK("^,vcprogname,'","',vcparams,'",',
     nwindow,")'>",vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE cclbuildapplink(nmode,vcappname,vcparams,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    SET vcreturn = build("<a href='javascript:APPLINK(",nmode,',"',vcappname,'","',
     vcparams,^")'>^,vcdescription,"</a>")
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE cclbuildweblink(vcaddress,nmode,vcdescription)
   DECLARE vcreturn = vc WITH private, noconstant(vcdescription)
   IF ((_htmlfileinfo->file_desc != 0))
    IF (nmode=1)
     SET vcreturn = build("<a href='",vcaddress,"'>",vcdescription,"</a>")
    ELSE
     SET vcreturn = build("<a href='",vcaddress,"' target='_blank'>",vcdescription,"</a>")
    ENDIF
   ENDIF
   RETURN(vcreturn)
 END ;Subroutine
 SUBROUTINE query1(dummy)
   SELECT INTO "NL:"
    description = substring(1,100,audits->list[d1.seq].description), prevcnt = trim(evaluate(audits->
      list[d1.seq].prev_fail_cnt,- (1),"OFF",0,"PASS",
      format(audits->list[d1.seq].prev_fail_cnt,";,L;"))), currentcnt = trim(evaluate(audits->list[d1
      .seq].current_fail_cnt,- (1),"OFF",0,"PASS",
      format(audits->list[d1.seq].current_fail_cnt,";,L;"))),
    curdttm = format(audits->current_run_dt_tm,"DD-MMM-YYYY;;D"), cat = substring(1,100,audits->list[
     d1.seq].category), auditnum = audits->list[d1.seq].audit_num
    FROM (dummyt d1  WITH seq = value(size(audits->list,5)))
    PLAN (d1)
    ORDER BY cat
    HEAD REPORT
     _d0 = d1.seq, _d1 = description, _d2 = prevcnt,
     _d3 = currentcnt, _d4 = cat, _d5 = auditnum,
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fenddetail = (_fenddetail
      - footpagesection(rpt_calcheight)), _fdrawheight = headreportsection(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ urlsection(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render), _bconturlsection = 0, bfirsttime = 1
     WHILE (((_bconturlsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bconturlsection, _fdrawheight = urlsection(rpt_calcheight,((rptreport->
        m_pageheight - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
        CALL pagebreak(0)
       ELSEIF (_bholdcontinue=1
        AND _bconturlsection=0)
        CALL pagebreak(0)
       ENDIF
       dummy_val = urlsection(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
        _yoffset),_bconturlsection), bfirsttime = 0
     ENDWHILE
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headpagesection(rpt_render)
    HEAD cat
     _fdrawheight = headcatsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headcatsection(rpt_render)
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  cat
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
     _yoffset = _yhold
    FOOT REPORT
     _fdrawheight = footreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportsection(rpt_render)
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE query1html(ndummy)
  DECLARE rpt_pageofpage = vc WITH noconstant("Page 1 of 1"), protect
  SELECT INTO "NL:"
   description = substring(1,100,audits->list[d1.seq].description), prevcnt = trim(evaluate(audits->
     list[d1.seq].prev_fail_cnt,- (1),"OFF",0,"PASS",
     format(audits->list[d1.seq].prev_fail_cnt,";,L;"))), currentcnt = trim(evaluate(audits->list[d1
     .seq].current_fail_cnt,- (1),"OFF",0,"PASS",
     format(audits->list[d1.seq].current_fail_cnt,";,L;"))),
   curdttm = format(audits->current_run_dt_tm,"DD-MMM-YYYY;;D"), cat = substring(1,100,audits->list[
    d1.seq].category), auditnum = audits->list[d1.seq].audit_num
   FROM (dummyt d1  WITH seq = value(size(audits->list,5)))
   PLAN (d1)
   ORDER BY cat
   HEAD REPORT
    _d0 = d1.seq, _d1 = description, _d2 = prevcnt,
    _d3 = currentcnt, _d4 = cat, _d5 = auditnum,
    _htmlfileinfo->file_buf = "<thead>", _htmlfilestat = cclio("WRITE",_htmlfileinfo), dummy_val =
    headreportsectionhtml(0),
    dummy_val = urlsectionhtml(0), dummy_val = headpagesectionhtml(0), _htmlfileinfo->file_buf =
    "</thead>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   HEAD cat
    dummy_val = headcatsectionhtml(0)
   DETAIL
    dummy_val = detailsectionhtml(0)
   FOOT REPORT
    _htmlfileinfo->file_buf = "", _htmlfileinfo->file_buf = "<tfoot>", _htmlfilestat = cclio("WRITE",
     _htmlfileinfo),
    dummy_val = footpagesectionhtml(0), dummy_val = footreportsectionhtml(0), _htmlfileinfo->file_buf
     = "</tfoot>",
    _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   WITH nocounter, separator = " ", format
  ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   IF (_htmlfileinfo->file_desc)
    SET _htmlfileinfo->file_buf = "</html>"
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    SET _htmlfilestat = cclio("CLOSE",_htmlfileinfo)
   ELSE
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
   ENDIF
 END ;Subroutine
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.590000), private
   DECLARE __txtreportname = vc WITH noconstant(build2(audits->header_name,char(0))), protect
   DECLARE __txtclientmnemonic = vc WITH noconstant(build2(cnvtupper(clientstr),char(0))), protect
   DECLARE __txtdomain = vc WITH noconstant(build2(cnvtupper(curdomain),char(0))), protect
   DECLARE __txtcurtime = vc WITH noconstant(build2(trim(format(cnvtdatetime(audits->
        current_run_dt_tm),"@LONGDATETIME"),3),char(0))), protect
   DECLARE __txtpassrate = vc WITH noconstant(build2(format((audits->pass_rate * 100),"## %"),char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 0.000),(offsety+ 0.063),7.250,
     1.396,1)
    SET rptsd->m_flags = 292
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.958
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica26b16777215)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Application Management Services",char
      (0)))
    SET rptsd->m_flags = 260
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.438
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtreportname)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.646)
    SET rptsd->m_x = (offsetx+ 1.146)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtclientmnemonic)
    SET rptsd->m_y = (offsety+ 1.865)
    SET rptsd->m_x = (offsetx+ 1.146)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtdomain)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.646)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Client:",char(0)))
    SET rptsd->m_y = (offsety+ 1.865)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Domain:",char(0)))
    SET rptsd->m_y = (offsety+ 2.073)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prepared:",char(0)))
    SET rptsd->m_y = (offsety+ 2.281)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pass rate:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.073)
    SET rptsd->m_x = (offsetx+ 1.146)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtcurtime)
    SET rptsd->m_y = (offsety+ 2.281)
    SET rptsd->m_x = (offsetx+ 1.146)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtpassrate)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headreportsectionhtml(dummy)
  SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
   "<td width='624'"," class='HeadReportSection9'>","Application Management Services","</td>",
   "</tr></table>","<table border=0 cellspacing=0 cellpadding=0><tr>","<td width=60></td>",
   "<td width='528'"," class='HeadReportSection8'>",
   audits->header_name,"</td>","</tr></table>","<table border=0 cellspacing=0 cellpadding=0><tr>",
   "<td width=48></td>",
   "<td width='77'"," class='HeadReportSection2'>","Client:","</td>","<td width=1></td>",
   "<td width='240'"," class='HeadReportSection0'>",cnvtupper(clientstr),"</td>","</tr></table>",
   "<table border=0 cellspacing=0 cellpadding=0><tr>","<td width=48></td>","<td width='77'",
   " class='HeadReportSection2'>","Domain:",
   "</td>","<td width=1></td>","<td width='240'"," class='HeadReportSection0'>",cnvtupper(curdomain),
   "</td>","</tr></table>","<table border=0 cellspacing=0 cellpadding=0><tr>","<td width=48></td>",
   "<td width='77'",
   " class='HeadReportSection2'>","Prepared:","</td>","<td width=1></td>","<td width='240'",
   " class='HeadReportSection0'>",trim(format(cnvtdatetime(audits->current_run_dt_tm),"@LONGDATETIME"
     ),3),"</td>","</tr></table>","<table border=0 cellspacing=0 cellpadding=0><tr>",
   "<td width=48></td>","<td width='77'"," class='HeadReportSection2'>","Pass rate:","</td>",
   "<td width=1></td>","<td width='240'"," class='HeadReportSection0'>",format((audits->pass_rate *
    100),"## %"),"</td>",
   "</tr></table>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE urlsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = urlsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE urlsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.630000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_txtrptdesc = f8 WITH noconstant(0.0), private
   IF (textlen(audits->url) > 0)
    DECLARE __txturl = vc WITH noconstant(build2(audits->url,char(0))), protect
   ENDIF
   IF (textlen(audits->url) > 0)
    DECLARE __txtrptdesc = vc WITH noconstant(build2(audits->report_sentence,char(0))), protect
   ENDIF
   IF ( NOT (textlen(audits->url) > 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remtxtrptdesc = 1
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
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (textlen(audits->url) > 0)
    SET _holdremtxtrptdesc = _remtxtrptdesc
    IF (_remtxtrptdesc > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtxtrptdesc,((size(
         __txtrptdesc) - _remtxtrptdesc)+ 1),__txtrptdesc)))
     SET drawheight_txtrptdesc = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remtxtrptdesc = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtxtrptdesc,((size(__txtrptdesc) -
        _remtxtrptdesc)+ 1),__txtrptdesc)))))
      SET _remtxtrptdesc = (_remtxtrptdesc+ rptsd->m_drawlength)
     ELSE
      SET _remtxtrptdesc = 0
     ENDIF
     SET growsum = (growsum+ _remtxtrptdesc)
    ENDIF
   ELSE
    SET _remtxtrptdesc = 0
    SET _holdremtxtrptdesc = _remtxtrptdesc
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.281)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10u16711680)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (textlen(audits->url) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txturl)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_txtrptdesc
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   IF (ncalc=rpt_render
    AND _holdremtxtrptdesc > 0)
    IF (textlen(audits->url) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtxtrptdesc,((size
        (__txtrptdesc) - _holdremtxtrptdesc)+ 1),__txtrptdesc)))
    ENDIF
   ELSE
    SET _remtxtrptdesc = _holdremtxtrptdesc
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE urlsectionhtml(dummy)
   IF (textlen(audits->url) > 0)
    SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
     "<td width=48></td>"," ")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    IF (textlen(audits->url) > 0)
     SET _htmlfileinfo->file_buf = build2("<td width='720'"," class='URLSection0'>",audits->
      report_sentence,"</td>"," ")
    ELSE
     SET _htmlfileinfo->file_buf = build2("<td width='720' class='URLSection0'>","","</td>")
    ENDIF
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    SET _htmlfileinfo->file_buf = build2("</tr></table>",
     "<table border=0 cellspacing=0 cellpadding=0><tr>","<td width=48></td>"," ")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    IF (textlen(audits->url) > 0)
     SET _htmlfileinfo->file_buf = build2("<td width='720'"," class='URLSection1'>",audits->url,
      "</td>"," ")
    ELSE
     SET _htmlfileinfo->file_buf = build2("<td width='720' class='URLSection1'>","","</td>")
    ENDIF
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
    SET _htmlfileinfo->file_buf = build2("</tr></table>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE __curdttm = vc WITH noconstant(build2(trim(format(audits->current_run_dt_tm,
       "DD-MMM-YYYY;;D"),3),char(0))), protect
   DECLARE __prevdttm = vc WITH noconstant(build2(trim(format(audits->prev_run_dt_tm,"DD-MMM-YYYY;;D"
       ),3),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.552)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b13800461)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__curdttm)
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Current Run",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Previous Run",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 6.552)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prevdttm)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesectionhtml(dummy)
  SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
   "<td width=576></td>","<td width='96'"," class='HeadPageSection1'>","Current Run",
   "</td>","<td width='96'"," class='HeadPageSection1'>","Previous Run","</td>",
   "</tr></table>","<table border=0 cellspacing=0 cellpadding=0><tr>","<td width=581></td>",
   "<td width='96'"," class='HeadPageSection0'>",
   trim(format(audits->current_run_dt_tm,"DD-MMM-YYYY;;D"),3),"</td>","<td width='96'",
   " class='HeadPageSection0'>",trim(format(audits->prev_run_dt_tm,"DD-MMM-YYYY;;D"),3),
   "</td>","</tr></table>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE headcatsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headcatsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headcatsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __txtcategory = vc WITH noconstant(build2(trim(cat),char(0))), protect
   IF ( NOT (textlen(trim(audits->list[1].category)) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(123,193,67))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtcategory)
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.001),(offsety+ 0.021),(offsetx+ 0.001),(offsety+
     0.292))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),(offsety+ 0.021),(offsetx+ 7.500),(offsety+
     0.292))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.020),(offsetx+ 7.500),(offsety+
     0.020))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headcatsectionhtml(dummy)
   IF (textlen(trim(audits->list[1].category)) > 0)
    SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
     "<td width='720'"," class='HeadcatSection3'>",trim(cat),"</td>",
     "</tr></table>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __txtdesc = vc WITH noconstant(build2(
     IF (textlen(trim(cat)) > 0) build2(trim(cnvtstring(auditnum)),notrim(". "),description)
     ELSE build2("#",trim(cnvtstring(d1.seq)),": ",description)
     ENDIF
     ,char(0))), protect
   DECLARE __txtprevcnt = vc WITH noconstant(build2(trim(prevcnt),char(0))), protect
   DECLARE __txtcurrentcnt = vc WITH noconstant(build2(trim(currentcnt),char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.500),(offsety+ 0.000),1.000,0.302,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 6.500),(offsety+ 0.000),1.000,0.302,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.000),5.500,0.302,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 260
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 5.375
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b13800461)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtdesc)
    SET rptsd->m_flags = 272
    IF ((audits->list[d1.seq].prev_fail_cnt=0))
     SET _fntcond = _helvetica10b4440443
    ELSEIF ((audits->list[d1.seq].prev_fail_cnt > 0))
     SET _fntcond = _helvetica10b255
    ELSEIF ((audits->list[d1.seq].prev_fail_cnt=- (1)))
     SET _fntcond = _helvetica10b0
    ELSE
     SET _fntcond = _helvetica10b13800461
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.552)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.302
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtprevcnt)
    IF ((audits->list[d1.seq].current_fail_cnt > 0))
     SET _fntcond = _helvetica10b255
    ELSEIF ((audits->list[d1.seq].current_fail_cnt=0))
     SET _fntcond = _helvetica10b4440443
    ELSEIF ((audits->list[d1.seq].current_fail_cnt=- (1)))
     SET _fntcond = _helvetica10b0
    ELSE
     SET _fntcond = _helvetica10b13800461
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.552)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.302
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtcurrentcnt)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsectionhtml(dummy)
   SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
    "<td width='516'"," class='DetailSection2'>",
    IF (textlen(trim(cat)) > 0) build2(trim(cnvtstring(auditnum)),notrim(". "),description)
    ELSE build2("#",trim(cnvtstring(d1.seq)),": ",description)
    ENDIF
    ,"</td>",
    "")
   SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   IF ((audits->list[d1.seq].current_fail_cnt > 0))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0_Condition1'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSEIF ((audits->list[d1.seq].current_fail_cnt=0))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0_Condition2'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSEIF ((audits->list[d1.seq].current_fail_cnt=- (1)))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0_Condition3'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSE
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0'>","")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
   SET _htmlfileinfo->file_buf = build2(trim(currentcnt),"</td>","")
   SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   IF ((audits->list[d1.seq].prev_fail_cnt=0))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection1_Condition1'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSEIF ((audits->list[d1.seq].prev_fail_cnt > 0))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0_Condition1'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSEIF ((audits->list[d1.seq].prev_fail_cnt=- (1)))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection1_Condition3'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSE
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0'>","")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
   SET _htmlfileinfo->file_buf = build2(trim(prevcnt),"</td>","</tr></table>")
   SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.177)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 6.063
    SET rptsd->m_height = 0.323
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica98421504)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Cerner Corporation / 2800 Rockcreek Parkway /  Kansas City, MO 64117 / 866.221.8877 /  cerner.com",
      char(0)))
    SET _rptstat = uar_rptimagedraw(_hreport,_himage2,(offsetx+ 6.188),(offsety+ 0.177),1.219,
     0.323,1)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesectionhtml(dummy)
  SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
   "<td width=48></td>","<td width='582'"," class='FootPageSection1'>",
   "Cerner Corporation / 2800 Rockcreek Parkway /  Kansas City, MO 64117 / 866.221.8877 /  cerner.com",
   "</td>","</tr></table>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE footreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.590000), private
   DECLARE __txtcurrpasscnt = vc WITH noconstant(build2(trim(format(audits->current_pass_cnt,";,L;")),
     char(0))), protect
   DECLARE __txtprevpasscnt = vc WITH noconstant(build2(trim(format(audits->prev_pass_cnt,";,L;")),
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 260
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 5.375
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b13800461)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total number of passing audits",char(
       0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.292),5.500,0.302,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.500),(offsety+ 0.292),1.000,0.302,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 6.500),(offsety+ 0.292),1.000,0.302,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 272
    IF ((audits->current_pass_cnt < audits->prev_pass_cnt))
     SET _fntcond = _helvetica10b255
    ELSEIF ((audits->current_pass_cnt > audits->prev_pass_cnt))
     SET _fntcond = _helvetica10b4440443
    ELSEIF ((audits->current_pass_cnt=audits->prev_pass_cnt))
     SET _fntcond = _helvetica10b0
    ELSE
     SET _fntcond = _helvetica10b13800461
    ENDIF
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 5.552)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.302
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtcurrpasscnt)
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 6.552)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.302
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtprevpasscnt)
    SET rptsd->m_flags = 276
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(13,148,210))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Health Check Summary",char(0)))
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.001),(offsety+ 0.021),(offsetx+ 0.001),(offsety+
     0.292))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),(offsety+ 0.021),(offsetx+ 7.500),(offsety+
     0.292))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsectionhtml(dummy)
   SET _htmlfileinfo->file_buf = build2("<table border=0 cellspacing=0 cellpadding=0><tr>",
    "<td width='720'"," class='FootReportSection2'>","Health Check Summary","</td>",
    "<td width='516'"," class='DetailSection2'>","Total number of passing audits","</td>","")
   SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   IF ((audits->current_pass_cnt < audits->prev_pass_cnt))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='FootReportSection4_Condition1'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSEIF ((audits->current_pass_cnt > audits->prev_pass_cnt))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection1_Condition1'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSEIF ((audits->current_pass_cnt=audits->prev_pass_cnt))
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='FootReportSection4_Condition3'>")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSE
    SET _htmlfileinfo->file_buf = build2("<td width='86'"," class='DetailSection0'>","")
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ENDIF
   SET _htmlfileinfo->file_buf = build2(trim(format(audits->current_pass_cnt,";,L;")),"</td>",
    "<td width='86'"," class='FootReportSection3'>",trim(format(audits->prev_pass_cnt,";,L;")),
    "</td>","</tr></table>")
   SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bgeneratehtml=1)
    SET _htmlfileinfo->file_name = _sendto
    SET _htmlfileinfo->file_buf = "w+b"
    SET _htmlfilestat = cclio("OPEN",_htmlfileinfo)
    SET _htmlfileinfo->file_buf = "<html><head><META content=CCLLINK,APPLINK name=discern /></head>"
    SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
   ELSE
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "AMS_HEALTH_CHECK_REPORT"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
    SET rptreport->m_marginleft = 0.50
    SET rptreport->m_marginright = 0.50
    SET rptreport->m_margintop = 0.50
    SET rptreport->m_marginbottom = 0.30
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _stat = _loadimages(0)
    SET _rptpage = uar_rptstartpage(_hreport)
   ENDIF
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 26
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_rgbcolor = rpt_white
   SET _helvetica26b16777215 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _helvetica14b16777215 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET rptfont->m_rgbcolor = rpt_blue
   SET _helvetica10u16711680 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_rgbcolor = uar_rptencodecolor(13,148,210)
   SET _helvetica10b13800461 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = uar_rptencodecolor(123,193,67)
   SET _helvetica10b4440443 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = rpt_red
   SET _helvetica10b255 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_rgbcolor = rpt_gray
   SET _helvetica98421504 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE last_mod = vc WITH protect
 SET last_mod = "001"
 SET _bishtml = validate(_htmlfileinfo->file_desc,0)
 IF (_bishtml != 0)
  SET _htmlfileinfo->file_buf = build2("<STYLE>",
   "table {border-collapse: collapse; empty-cells: show;   }",".HeadReportSection0 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 12pt Helvetica;"," "," color: #000000;"," "," text-align: left;",
   " vertical-align: top;}",".HeadReportSection2 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 12pt Helvetica;",
   " "," color: #000000;"," "," text-align: left;"," vertical-align: top;}",
   ".HeadReportSection8 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 14pt Helvetica;"," ",
   " color: #ffffff;"," "," text-align: left;"," vertical-align: middle;}",".HeadReportSection9 {",
   ""," padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 26pt Helvetica;"," ",
   " color: #ffffff;",
   " "," text-align: left;"," vertical-align: middle;}",".URLSection0 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;"," font:   10pt Helvetica;"," "," color: #000000;"," ",
   " text-align: left;"," vertical-align: top;}",".URLSection1 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:   10pt Helvetica;"," text-decoration: underline;"," color: #0000ff;"," ",
   " text-align: left;",
   " vertical-align: top;}",".HeadPageSection0 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 10pt Helvetica;",
   " "," color: #0d94d2;"," "," text-align: right;"," vertical-align: top;}",
   ".HeadPageSection1 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 10pt Helvetica;"," ",
   " color: #0d94d2;"," "," text-align: right;"," vertical-align: top;}",".HeadcatSection3 {",
   ""," padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 14pt Helvetica;"," ",
   " color: #ffffff;",
   " background: #7bc143;"," text-align: center;"," vertical-align: middle;}",".DetailSection0 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Helvetica;"," "," color: #0d94d2;",
   " ",
   " text-align: center;"," vertical-align: middle;}",".DetailSection0_Condition1 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 10pt Helvetica;"," "," color: #ff0000;"," "," text-align: right;",
   " vertical-align: top;}",".DetailSection0_Condition2 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Helvetica;",
   " "," color: #7bc143;"," "," text-align: right;"," vertical-align: top;}",
   ".DetailSection0_Condition3 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 10pt Helvetica;"," ",
   " color: #000000;"," "," text-align: right;"," vertical-align: top;}",
   ".DetailSection1_Condition1 {",
   ""," padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Helvetica;"," ",
   " color: #7bc143;",
   " "," text-align: right;"," vertical-align: top;}",".DetailSection1_Condition3 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Helvetica;"," "," color: #000000;",
   " ",
   " text-align: right;"," vertical-align: top;}",".DetailSection2 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 10pt Helvetica;"," "," color: #0d94d2;"," "," text-align: left;",
   " vertical-align: middle;}",".FootPageSection1 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:   9pt Helvetica;",
   " "," color: #808080;"," "," text-align: center;"," vertical-align: middle;}",
   ".FootReportSection2 {",""," padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 14pt Helvetica;"," ",
   " color: #ffffff;"," background: #0d94d2;"," text-align: center;"," vertical-align: middle;}",
   ".FootReportSection3 {",
   ""," padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Helvetica;"," ",
   " color: #000000;",
   " "," text-align: center;"," vertical-align: middle;}",".FootReportSection4_Condition1 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;"," font:  bold 10pt Helvetica;"," "," color: #ff0000;",
   " ",
   " text-align: right;"," vertical-align: top;}",".FootReportSection4_Condition3 {","",
   " padding: 0.000in 0.000in 0.000in 0.000in;",
   " font:  bold 10pt Helvetica;"," "," color: #000000;"," "," text-align: right;",
   " vertical-align: top;}","</STYLE>")
  SET _htmlfilestat = cclio("WRITE",_htmlfileinfo)
 ENDIF
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 IF (_bishtml=0)
  SET _fholdenddetail = _fenddetail
  CALL query1(0)
  SET _fenddetail = _fholdenddetail
 ELSE
  CALL query1html(0)
 ENDIF
 CALL finalizereport(_sendto)
 IF (_bishtml != 0)
  SET _htmlfileinfo->file_buf = ""
 ENDIF
END GO
