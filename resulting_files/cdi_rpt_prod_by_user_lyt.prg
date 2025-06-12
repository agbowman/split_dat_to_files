CREATE PROGRAM cdi_rpt_prod_by_user_lyt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "User Name" = ""
  WITH outdev, begindate, enddate,
  username
 EXECUTE reportrtl
 RECORD batch_lyt(
   1 batch_details[*]
     2 startdate = dq8
     2 modulename = c32
     2 documents = i4
     2 pages = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cdi_rpt_prod_by_user_drvr  $BEGINDATE,  $ENDDATE,  $USERNAME
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE batch_query(dummy) = null WITH public
 DECLARE pagebreak(dummy) = null WITH public
 DECLARE finalizereport(ssendreport=vc) = null WITH public
 DECLARE headreportsection(ncalc=i2) = f8 WITH public
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE headpagesection(ncalc=i2) = f8 WITH public
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE headbatch_lyt_batch_details_startdatesection(ncalc=i2) = f8 WITH public
 DECLARE headbatch_lyt_batch_details_startdatesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 public
 DECLARE headbatch_lyt_batch_details_modulenamesection(ncalc=i2) = f8 WITH public
 DECLARE headbatch_lyt_batch_details_modulenamesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 public
 DECLARE detailsection(ncalc=i2) = f8 WITH public
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE footbatch_lyt_batch_details_modulenamesection(ncalc=i2) = f8 WITH public
 DECLARE footbatch_lyt_batch_details_modulenamesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 public
 DECLARE footbatch_lyt_batch_details_startdatesection(ncalc=i2) = f8 WITH public
 DECLARE footbatch_lyt_batch_details_startdatesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 public
 DECLARE footpagesection(ncalc=i2) = f8 WITH public
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE initializereport(dummy) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE _hi18nhandle = i4 WITH noconstant(0), public
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _times10bi0 = i4 WITH noconstant(0), public
 DECLARE _times10b0 = i4 WITH noconstant(0), public
 DECLARE _times100 = i4 WITH noconstant(0), public
 DECLARE _times16b0 = i4 WITH noconstant(0), public
 DECLARE _times16bi0 = i4 WITH noconstant(0), public
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), public
 SUBROUTINE batch_query(dummy)
   CALL initializereport(0)
   SELECT INTO "NL:"
    batch_lyt_batch_details_startdate = batch_lyt->batch_details[dtrs1.seq].startdate,
    batch_lyt_batch_details_modulename = batch_lyt->batch_details[dtrs1.seq].modulename,
    batch_lyt_batch_details_documents = batch_lyt->batch_details[dtrs1.seq].documents,
    batch_lyt_batch_details_pages = batch_lyt->batch_details[dtrs1.seq].pages
    FROM (dummyt dtrs1  WITH seq = value(size(batch_lyt->batch_details,5)))
    GROUP BY batch_lyt->batch_details[dtrs1.seq].startdate, batch_lyt->batch_details[dtrs1.seq].
     modulename
    ORDER BY batch_lyt_batch_details_startdate, batch_lyt_batch_details_modulename
    HEAD REPORT
     _d0 = batch_lyt_batch_details_startdate, _d1 = batch_lyt_batch_details_modulename, _fenddetail
      = ((rptreport->m_pageheight - rptreport->m_marginbottom) - footpagesection(rpt_calcheight)),
     dummy_val = headreportsection(rpt_render), total_docs = 0, total_pages = 0,
     module_docs = 0, module_pages = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(rpt_render)
     ENDIF
     dummy_val = headpagesection(rpt_render)
    HEAD batch_lyt_batch_details_startdate
     IF (((_yoffset+ headbatch_lyt_batch_details_startdatesection(rpt_calcheight)) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headbatch_lyt_batch_details_startdatesection(rpt_render), total_docs = 0,
     total_pages = 0
    HEAD batch_lyt_batch_details_modulename
     IF (((_yoffset+ headbatch_lyt_batch_details_modulenamesection(rpt_calcheight)) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headbatch_lyt_batch_details_modulenamesection(rpt_render), module_docs = 0,
     module_pages = 0
    DETAIL
     IF (((_yoffset+ detailsection(rpt_calcheight)) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render), total_docs = (total_docs+
     batch_lyt_batch_details_documents), total_pages = (total_pages+ batch_lyt_batch_details_pages),
     module_docs = (module_docs+ batch_lyt_batch_details_documents), module_pages = (module_pages+
     batch_lyt_batch_details_pages)
    FOOT  batch_lyt_batch_details_modulename
     IF (((_yoffset+ footbatch_lyt_batch_details_modulenamesection(rpt_calcheight)) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = footbatch_lyt_batch_details_modulenamesection(rpt_render)
    FOOT  batch_lyt_batch_details_startdate
     IF (((_yoffset+ footbatch_lyt_batch_details_startdatesection(rpt_calcheight)) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = footbatch_lyt_batch_details_startdatesection(rpt_render)
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
     _yoffset = _yhold
    WITH nocounter, separator = " ", format
   ;end select
   CALL finalizereport(_sendto)
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
   DECLARE sectionheight = f8 WITH noconstant(1.190000), private
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 7.50
   SET rptsd->m_height = 0.56
   SET _oldfont = uar_rptsetfont(_hreport,_times16bi0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(uar_i18ngetmessage(_hi18nhandle,
        "CPDI","ProVision Document Imaging"),_crlf,uar_i18ngetmessage(_hi18nhandle,
        "HeadReportSection_title1","Productivity by User Report")),char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.81)
   SET rptsd->m_x = (offsetx+ 0.75)
   SET rptsd->m_width = 6.00
   SET rptsd->m_height = 0.26
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(format(cnvtdatetime(cnvtdate2(
           $BEGINDATE,"MM/DD/YY"),0),"@SHORTDATE"),"  -  ",format(cnvtdatetime(cnvtdate2( $ENDDATE,
          "MM/DD/YY"),0),"@SHORTDATE")),char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.50)
   SET rptsd->m_x = (offsetx+ 0.75)
   SET rptsd->m_width = 6.00
   SET rptsd->m_height = 0.32
   SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2("For '", $USERNAME,"'"),char(0)
      ))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 2.00)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   SET _oldfont = uar_rptsetfont(_hreport,_times10bi0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadPageSection_ModuleNameheader","Module Name"),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 5.50)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadPageSection_FieldName01","Pages"),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 3.75)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadPageSection_FieldName02","Documents"),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.25
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadPageSection_DateHeader","Date"),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ - (0.01))
   SET rptsd->m_x = (offsetx+ 2.31)
   SET rptsd->m_width = 3.00
   SET rptsd->m_height = 0.28
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate=0.00)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadPageSection_FieldName3","NO RECORDS FOUND"),char(0)))
    ENDIF
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_startdatesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbatch_lyt_batch_details_startdatesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_startdatesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(
        batch_lyt_batch_details_startdate,"@SHORTDATE"),char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_modulenamesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbatch_lyt_batch_details_modulenamesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_modulenamesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 0.52
   SET rptsd->m_height = 0.26
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadBATCH_LYT_BATCH_DETAILS_MODULENAMESection_emptyfield",""),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 0.52
   SET rptsd->m_height = 0.26
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_emptyfield",""),char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footbatch_lyt_batch_details_modulenamesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footbatch_lyt_batch_details_modulenamesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footbatch_lyt_batch_details_modulenamesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 36
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 2.00)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_modulename,
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 3.75)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(module_docs),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 5.50)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(module_pages),char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footbatch_lyt_batch_details_startdatesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footbatch_lyt_batch_details_startdatesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footbatch_lyt_batch_details_startdatesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 36
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 2.00)
   SET rptsd->m_width = 1.25
   SET rptsd->m_height = 0.26
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Footbatch_lyt_batch_details_startdateSection_FieldName0","Daily Total:"),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 3.75)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(total_docs),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 5.50)
   SET rptsd->m_width = 1.50
   SET rptsd->m_height = 0.26
   IF (ncalc=0)
    IF (batch_lyt_batch_details_startdate > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(total_pages),char(0)))
    ENDIF
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.00
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 5.00)
   SET rptsd->m_width = 2.50
   SET rptsd->m_height = 0.25
   SET _oldfont = uar_rptsetfont(_hreport,_times10bi0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
   ENDIF
   SET rptsd->m_flags = 32
   SET rptsd->m_y = (offsety+ 0.00)
   SET rptsd->m_x = (offsetx+ 0.00)
   SET rptsd->m_width = 3.00
   SET rptsd->m_height = 0.25
   IF (ncalc=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build(format(sysdate,"@WEEKDAYNAME;;D"
        ),",",format(sysdate,"@LONGDATE;;D")),char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CDI_RPT_PROD_BY_USER_LYT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
    FROM output_dest o,
     device d,
     printer p
    PLAN (o
     WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
     JOIN (d
     WHERE d.device_cd=o.device_cd)
     JOIN (p
     WHERE p.device_cd=d.device_cd)
    DETAIL
     CASE (cnvtint(p_printer_type_cdf))
      OF 8:
      OF 26:
      OF 29:
       _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
      OF 16:
      OF 20:
      OF 24:
       _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
      OF 32:
      OF 18:
      OF 19:
      OF 27:
      OF 31:
       _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
      ELSE
       _xdiv = 1,_ydiv = 1
     ENDCASE
     _sendto = d.name
     IF (_xdiv > 1)
      rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
     ENDIF
     IF (_xdiv > 1)
      rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
     ENDIF
    WITH nocounter
   ;end select
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
   SET _times16bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_italic = rpt_off
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_italic = rpt_on
   SET _times10bi0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.01
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL batch_query(0)
END GO
