CREATE PROGRAM ams_ccl_review
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Username (filter)" = "*",
  "Sensetive Tables Only" = 0
  WITH outdev, sdate, edate,
  user, sensetive
 EXECUTE ams_define_toolkit_common
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE cclreport1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_CCL_REVIEW")
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _reml_long_text = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica8255 = i4 WITH noconstant(0), protect
 DECLARE _helvetica8u0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE table_name = vc WITH protect
 DECLARE rec_cnt = vc WITH protect
 DECLARE application_number = vc WITH protect
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE cclreport1(dummy)
   SELECT DISTINCT
    p.name_full_formatted, p.username, application_number = cnvtstring(c.application_nbr),
    a.description, c.begin_dt_tm"@SHORTDATETIME", c.object_name,
    c.object_params, c.object_type, c.status,
    l.long_text, rec_cnt = cnvtstring(c.records_cnt), c.output_device,
    c.tempfile, c.report_event_id
    FROM ccl_report_audit c,
     long_text l,
     prsnl p,
     person_name pn,
     application a,
     dummyt d1
    PLAN (c
     WHERE c.application_nbr IN (3010000, 950001, 3070000, 3050000)
      AND c.begin_dt_tm >= cnvtdatetime(cnvtdate2( $SDATE,"mm-dd-yyyy"),0)
      AND c.begin_dt_tm <= cnvtdatetime(cnvtdate2( $EDATE,"mm-dd-yyyy"),235959))
     JOIN (a
     WHERE c.application_nbr=a.application_number)
     JOIN (p
     WHERE c.updt_id=p.person_id
      AND (p.username= $USER))
     JOIN (pn
     WHERE p.person_id=pn.person_id
      AND pn.name_title IN ("Cerner AMS", "Cerner IRC"))
     JOIN (l
     WHERE outerjoin(c.long_text_id)=l.long_text_id
      AND l.parent_entity_name="CCL_REPORT_AUDIT")
     JOIN (d1
     WHERE parser(table_name))
    ORDER BY p.name_full_formatted, c.begin_dt_tm
    HEAD REPORT
     _d0 = p.name_full_formatted, _d1 = p.username, _d2 = application_number,
     _d3 = a.description, _d4 = c.begin_dt_tm, _d5 = c.object_name,
     _d6 = l.long_text, _d7 = rec_cnt, _d8 = c.output_device,
     _d9 = c.tempfile, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom),
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headpagesection(rpt_render)
    HEAD p.name_full_formatted
     row + 0
    HEAD c.begin_dt_tm
     row + 0
    DETAIL
     _bcontdetailsection = 0, bfirsttime = 1
     WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontdetailsection=0)
        BREAK
       ENDIF
       dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection), bfirsttime
        = 0
     ENDWHILE
    FOOT  c.begin_dt_tm
     row + 0
    FOOT  p.name_full_formatted
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
     _yoffset = _yhold
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
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE __fieldname2 = vc WITH noconstant(build2( $SDATE,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2( $EDATE,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.625
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Adhoc CCL requests executed from ",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.229
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 0.927
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 0.594
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("through",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.630000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_l_long_text = f8 WITH noconstant(0.0), private
   DECLARE __c_begin_dt_tm = vc WITH noconstant(build2(format(c.begin_dt_tm,"@SHORTDATETIME"),char(0)
     )), protect
   DECLARE __l_long_text = vc WITH noconstant(build2(cnvtupper(l.long_text),char(0))), protect
   IF (bcontinue=0)
    SET _reml_long_text = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (l.long_text IN ("*CLINICAL_EVENT*", "*CE_*", "*PERSON*", "*ENCOUNTER*", "*ENCNTR*",
   "*ORDERS*", "*RESULT*"))
    SET _fntcond = _helvetica8255
   ELSE
    SET _fntcond = _helvetica80
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 4.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_fntcond)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdreml_long_text = _reml_long_text
   IF (_reml_long_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reml_long_text,((size(
        __l_long_text) - _reml_long_text)+ 1),__l_long_text)))
    SET drawheight_l_long_text = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reml_long_text = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reml_long_text,((size(__l_long_text) -
       _reml_long_text)+ 1),__l_long_text)))))
     SET _reml_long_text = (_reml_long_text+ rptsd->m_drawlength)
    ELSE
     SET _reml_long_text = 0
    ENDIF
    SET growsum = (growsum+ _reml_long_text)
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.000),7.448,0.188,
     rpt_fill,uar_rptencodecolor(178,178,178))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(a.description,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 0.896
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Application:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.438)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.302
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Application Number:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.625)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.010
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Query Time:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.813)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.552
   SET rptsd->m_height = 0.188
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Object Name:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.813)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.281
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(c.object_name,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.000)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 0.917
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Output Device:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.000)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.417
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(c.output_device,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.188)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.198
   SET rptsd->m_height = 0.292
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Record Count:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.375)
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Tempfile:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.375)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.698
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(c.tempfile,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.729
   SET rptsd->m_height = 0.271
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica8u0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Executed Query Code:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.438)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.323
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(application_number,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 2.344
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.name_full_formatted,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.313)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.username,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.271
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.625)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Username:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.625)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__c_begin_dt_tm)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.188)
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 1.115
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rec_cnt,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (l.long_text IN ("*CLINICAL_EVENT*", "*CE_*", "*PERSON*", "*ENCOUNTER*", "*ENCNTR*",
   "*ORDERS*", "*RESULT*"))
    SET _fntcond = _helvetica8255
   ELSE
    SET _fntcond = _helvetica80
   ENDIF
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 4.250
   SET rptsd->m_height = drawheight_l_long_text
   SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
   IF (ncalc=rpt_render
    AND _holdreml_long_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreml_long_text,((size
       (__l_long_text) - _holdreml_long_text)+ 1),__l_long_text)))
   ELSE
    SET _reml_long_text = _holdreml_long_text
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
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "AMS_CCL_REVIEW"
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 12
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_rgbcolor = rpt_red
   SET _helvetica8255 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _helvetica8u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_underline = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (( $SENSETIVE=1))
  SET table_name =
  'L.LONG_TEXT in("*CLINICAL_EVENT*","*CE_*","*PERSON*","*ENCOUNTER*","*ENCNTR*","*RESULT*")'
 ELSEIF (( $SENSETIVE=0))
  SET table_name = 'L.LONG_TEXT=("*")'
 ENDIF
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET _fholdenddetail = _fenddetail
 CALL cclreport1(0)
 SET _fenddetail = _fholdenddetail
 CALL finalizereport(_sendto)
 CALL updtdminfo(script_name)
END GO
