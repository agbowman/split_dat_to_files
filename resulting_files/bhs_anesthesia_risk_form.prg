CREATE PROGRAM bhs_anesthesia_risk_form
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "event id:" = 0
  WITH outdev, eventid
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE result(dummy) = null WITH public
 DECLARE pagebreak(dummy) = null WITH public
 DECLARE finalizereport(ssendreport=vc) = null WITH public
 DECLARE headreportsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH public
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH public
 DECLARE body2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH public
 DECLARE body2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH public
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
 DECLARE _bcontheadreportsection = i2 WITH noconstant(0), protect
 DECLARE _remtxtlists = i2 WITH noconstant(1), protect
 DECLARE _bcontbody2 = i2 WITH noconstant(0), protect
 DECLARE _remlblpae = i2 WITH noconstant(1), protect
 DECLARE _times16bu0 = i4 WITH noconstant(0), public
 DECLARE _times10b0 = i4 WITH noconstant(0), public
 DECLARE _times120 = i4 WITH noconstant(0), public
 DECLARE _times12b0 = i4 WITH noconstant(0), public
 DECLARE _times100 = i4 WITH noconstant(0), public
 DECLARE _times14b0 = i4 WITH noconstant(0), public
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), public
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), public
 SUBROUTINE result(dummy)
   CALL initializereport(0)
   SELECT
    qual_title = results->qual[dtrs1.seq].title, qual_surgerydt = results->qual[dtrs1.seq].surgerydt,
    qual_patientname = results->qual[dtrs1.seq].patientname,
    qual_mrn = results->qual[dtrs1.seq].mrn, qual_age = results->qual[dtrs1.seq].age, qual_procedure
     = results->qual[dtrs1.seq].procedure,
    qual_surgeon = results->qual[dtrs1.seq].surgeon, qual_pcp = results->qual[dtrs1.seq].pcp,
    qual_consulttxt = results->qual[dtrs1.seq].consulttxt,
    qual_consultto = results->qual[dtrs1.seq].consultto, qual_listofquestions = results->qual[dtrs1
    .seq].listofquestions, qual_pae = results->qual[dtrs1.seq].pae,
    qual_paedt = results->qual[dtrs1.seq].paedt
    FROM (dummyt dtrs1  WITH seq = value(size(results->qual,5)))
    HEAD REPORT
     _d0 = qual_title, _d1 = qual_surgerydt, _d2 = qual_patientname,
     _d3 = qual_mrn, _d4 = qual_age, _d5 = qual_procedure,
     _d6 = qual_surgeon, _d7 = qual_pcp, _d8 = qual_consulttxt,
     _d9 = qual_consultto, _d10 = qual_listofquestions, _d11 = qual_pae,
     _d12 = qual_paedt, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom),
     _bcontheadreportsection = 0,
     _bcontbody2 = 0, bfirsttime = 1
     WHILE (((_bcontheadreportsection=1) OR (((_bcontbody2=1) OR (bfirsttime=1)) )) )
       IF (_bcontbody2=0)
        _bholdcontinue = _bcontheadreportsection, _fdrawheight = headreportsection(rpt_calcheight,((
         rptreport->m_pageheight - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
        IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
         CALL pagebreak(0)
        ELSEIF (_bholdcontinue=1
         AND _bcontheadreportsection=0)
         CALL pagebreak(0)
        ENDIF
        dummy_val = headreportsection(rpt_render,((rptreport->m_pageheight - rptreport->
         m_marginbottom) - _yoffset),_bcontheadreportsection)
       ENDIF
       IF (_bcontheadreportsection=0)
        _bholdcontinue = _bcontbody2, _fdrawheight = body2(rpt_calcheight,((rptreport->m_pageheight
          - rptreport->m_marginbottom) - _yoffset),_bholdcontinue)
        IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
         CALL pagebreak(0)
        ELSEIF (_bholdcontinue=1
         AND _bcontbody2=0)
         CALL pagebreak(0)
        ENDIF
        dummy_val = body2(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
         _yoffset),_bcontbody2)
       ENDIF
       bfirsttime = 0
     ENDWHILE
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
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
 SUBROUTINE headreportsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(4.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remtxtlists = 1
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.508
   SET rptsd->m_height = 0.567
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat("BAYSTATE MEDICAL CENTER",_crlf,
       "DEPARTMENT OF ANESTHESIOLOGY",_crlf,"CHESTNUT SURGERY CENTER PREADMISSION EVALUATION OFFICE"),
      char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.250)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.508
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Surgery Date:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.500)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.508
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary care phys:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.308)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.508
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Surgeon:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.125)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.508
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 1.933)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.192
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 1.750)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.317
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medical record #:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.250)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 4.067
   SET rptsd->m_height = 0.208
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_surgerydt,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.308)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 5.817
   SET rptsd->m_height = 0.275
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_surgeon,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.500)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 5.750
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_pcp,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.125)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 5.317
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_procedure,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 1.933)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 1.550
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_age,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 1.750)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_mrn,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.558)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient name:",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.558)
   SET rptsd->m_x = (offsetx+ 1.808)
   SET rptsd->m_width = 4.750
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_patientname,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.808)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.817
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_consulttxt,char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 2.808)
   SET rptsd->m_x = (offsetx+ 3.558)
   SET rptsd->m_width = 1.550
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_consultto,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 3.183)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 6.250
   SET rptsd->m_height = 0.242
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "List Specific question(s) to the consultant or reason(s) for the high risk:",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.808)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.425
   SET _dummyfont = uar_rptsetfont(_hreport,_times16bu0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_title,char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_y = (offsety+ 3.375)
   SET rptsd->m_x = (offsetx+ 0.375)
   SET rptsd->m_width = 7.067
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   SET _holdremtxtlists = _remtxtlists
   IF (_remtxtlists > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtxtlists,((size(
        qual_listofquestions) - _remtxtlists)+ 1),qual_listofquestions)))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtxtlists = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtxtlists,((size(qual_listofquestions)
        - _remtxtlists)+ 1),qual_listofquestions)))))
     SET _remtxtlists = (_remtxtlists+ rptsd->m_drawlength)
    ELSE
     SET _remtxtlists = 0
    ENDIF
    SET growsum = (growsum+ _remtxtlists)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremtxtlists > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtxtlists,((size(
        qual_listofquestions) - _holdremtxtlists)+ 1),qual_listofquestions)))
   ELSE
    SET _remtxtlists = _holdremtxtlists
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
 SUBROUTINE body2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = body2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE body2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(2.040000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remlblpae = 1
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.433)
   SET rptsd->m_width = 1.550
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont(_hreport,_times120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_pae,char(0)))
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.567
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   SET _holdremlblpae = _remlblpae
   IF (_remlblpae > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlblpae,((size(
        "PAE physician:") - _remlblpae)+ 1),"PAE physician:")))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlblpae = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlblpae,((size("PAE physician:") -
       _remlblpae)+ 1),"PAE physician:")))))
     SET _remlblpae = (_remlblpae+ rptsd->m_drawlength)
    ELSE
     SET _remlblpae = 0
    ENDIF
    SET growsum = (growsum+ _remlblpae)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremlblpae > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlblpae,((size(
        "PAE physician:") - _holdremlblpae)+ 1),"PAE physician:")))
   ELSE
    SET _remlblpae = _holdremlblpae
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.683)
   SET rptsd->m_width = 1.550
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times120)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(qual_paedt,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.183)
   SET rptsd->m_width = 0.442
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date:",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.558)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 6.567
   SET rptsd->m_height = 1.083
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "All requested consults should be completed as soon as possible, and no later than three days prior to the patie",
       "nt's surgery to avoid unnecessary delays and/or cancellations. All completed consults should be forwarded immedi",
       "ately for review, with this cover sheet to: Anesthesia Preadmission Evaluation Office, Chestnut Surgery G, at Ba",
       "ystate Medical Center. FAX (413) 794 - 1856."),char(0)))
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety+ 0.375)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 6.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("*** PLEASE NOTE ***",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.25),(offsety+ 1.69),(offsetx+ 6.75),(offsety+
     1.69))
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
   SET rptreport->m_reportname = "BHS_ANESTHESIA_RISK_FORM"
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
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _times16bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_underline = rpt_off
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 3
   SET _pen14s3c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL result(0)
END GO
