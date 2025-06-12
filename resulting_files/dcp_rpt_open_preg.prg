CREATE PROGRAM dcp_rpt_open_preg
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Query type" = "",
  "Operator" = "",
  "Start gestational age (weeks)" = "44",
  "End gestational age (weeks)" = "45",
  "Start date" = "CURDATE",
  "End date" = "CURDATE",
  "Organization" = 0,
  "Search type" = 0,
  "Enter physician last name" = "*",
  "Physician" = 0
  WITH outdev, qtype, operator,
  num_wks1, num_wks2, s_date,
  e_date, org, search_type,
  phys_last_name, physician
 EXECUTE reportrtl
 RECORD pregnancy(
   1 patient[*]
     2 person_lastname = vc
     2 person_firstname = vc
     2 mrn = vc
     2 gest_age = vc
     2 primary_physician = vc
     2 facility = vc
     2 edd = vc
   1 patient_cnt = i4
   1 debug = vc
   1 debug_f8 = f8
 )
 EXECUTE dcp_rpt_open_preg_drv "MINE",  $QTYPE,  $OPERATOR,
  $NUM_WKS1,  $NUM_WKS2,  $S_DATE,
  $E_DATE,  $ORG,  $SEARCH_TYPE,
  $PHYS_LAST_NAME,  $PHYSICIAN
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query2(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportrow(ncalc=i2) = f8 WITH protect
 DECLARE headreportrowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagerow1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagerow1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagerow2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagerow2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagerow(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagerowabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagerow3(ncalc=i2) = f8 WITH protect
 DECLARE headpagerow3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagerow4(ncalc=i2) = f8 WITH protect
 DECLARE headpagerow4abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailrow(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailrowabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpagerow(ncalc=i2) = f8 WITH protect
 DECLARE footpagerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportrow(ncalc=i2) = f8 WITH protect
 DECLARE footreportrowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
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
 DECLARE _remd_range = i4 WITH noconstant(1), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _remh_rangecaption = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagerow1 = i2 WITH noconstant(0), protect
 DECLARE _remd_filter = i4 WITH noconstant(1), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagerow2 = i2 WITH noconstant(0), protect
 DECLARE _remh_edd = i4 WITH noconstant(1), protect
 DECLARE _remh_gest_age = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagerow = i2 WITH noconstant(0), protect
 DECLARE _remd_facility = i4 WITH noconstant(1), protect
 DECLARE _remd_provider = i4 WITH noconstant(1), protect
 DECLARE _remd_edd = i4 WITH noconstant(1), protect
 DECLARE _remd_gest_age = i4 WITH noconstant(1), protect
 DECLARE _remd_patient_fname = i4 WITH noconstant(1), protect
 DECLARE _remd_patient_lname = i4 WITH noconstant(1), protect
 DECLARE _remd_mrn_fin = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailrow = i2 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c16777215 = i4 WITH noconstant(0), protect
 SUBROUTINE query2(dummy)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(pregnancy->patient,5))
    HEAD REPORT
     _d0 = d.seq, _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _fenddetail = (
     _fenddetail - footpagerow(rpt_calcheight))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headreportrow(rpt_render), _bcontheadpagerow1 = 0, dummy_val = headpagerow1(
      rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bcontheadpagerow1
      ),
     _bcontheadpagerow2 = 0, dummy_val = headpagerow2(rpt_render,((rptreport->m_pagewidth - rptreport
      ->m_marginbottom) - _yoffset),_bcontheadpagerow2), _bcontheadpagerow = 0,
     dummy_val = headpagerow(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
      _yoffset),_bcontheadpagerow), dummy_val = headpagerow3(rpt_render), dummy_val = headpagerow4(
      rpt_render)
    DETAIL
     _bcontdetailrow = 0, bfirsttime = 1
     WHILE (((_bcontdetailrow=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontdetailrow, _fdrawheight = detailrow(rpt_calcheight,(_fenddetail -
        _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontdetailrow=0)
        BREAK
       ENDIF
       dummy_val = detailrow(rpt_render,(_fenddetail - _yoffset),_bcontdetailrow), bfirsttime = 0
     ENDWHILE
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagerow(rpt_render),
     _yoffset = _yhold
    FOOT REPORT
     _fdrawheight = footreportrow(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportrow(rpt_render)
    WITH nocounter
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
 SUBROUTINE headreportrow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportrowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportrowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 0.007)
    SET rptsd->m_width = 9.993
    SET rptsd->m_height = 0.253
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c16777215)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(titlecaption,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagerow1(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagerow1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagerow1abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_d_range = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_h_rangecaption = f8 WITH noconstant(0.0), private
   DECLARE __d_range = vc WITH noconstant(build(dt_or_age_range,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build("",char(0))), protect
   DECLARE __h_rangecaption = vc WITH noconstant(build(rangecaption,char(0))), protect
   IF (bcontinue=0)
    SET _remd_range = 1
    SET _remfieldname1 = 1
    SET _remh_rangecaption = 1
   ENDIF
   SET rptsd->m_flags = 1029
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.007)
   SET rptsd->m_width = 2.993
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremd_range = _remd_range
   IF (_remd_range > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_range,((size(
        __d_range) - _remd_range)+ 1),__d_range)))
    SET drawheight_d_range = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_range = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_range,((size(__d_range) -
       _remd_range)+ 1),__d_range)))))
     SET _remd_range = (_remd_range+ rptsd->m_drawlength)
    ELSE
     SET _remd_range = 0
    ENDIF
    SET growsum = (growsum+ _remd_range)
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.882)
   SET rptsd->m_width = 0.118
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 1093
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.017)
   SET rptsd->m_width = 2.858
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremh_rangecaption = _remh_rangecaption
   IF (_remh_rangecaption > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remh_rangecaption,((size(
        __h_rangecaption) - _remh_rangecaption)+ 1),__h_rangecaption)))
    SET drawheight_h_rangecaption = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remh_rangecaption = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remh_rangecaption,((size(__h_rangecaption
        ) - _remh_rangecaption)+ 1),__h_rangecaption)))))
     SET _remh_rangecaption = (_remh_rangecaption+ rptsd->m_drawlength)
    ELSE
     SET _remh_rangecaption = 0
    ENDIF
    SET growsum = (growsum+ _remh_rangecaption)
   ENDIF
   SET rptsd->m_flags = 1028
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.007)
   SET rptsd->m_width = 2.993
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremd_range > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_range,((size(
        __d_range) - _holdremd_range)+ 1),__d_range)))
   ELSE
    SET _remd_range = _holdremd_range
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.882)
   SET rptsd->m_width = 0.118
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET rptsd->m_flags = 1092
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.017)
   SET rptsd->m_width = 2.858
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremh_rangecaption > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremh_rangecaption,((
       size(__h_rangecaption) - _holdremh_rangecaption)+ 1),__h_rangecaption)))
   ELSE
    SET _remh_rangecaption = _holdremh_rangecaption
   ENDIF
   SET rptsd->m_flags = 1056
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.267)
   SET rptsd->m_width = 2.743
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(print_prsnl_name,char(0)))
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.142)
   SET rptsd->m_width = 0.118
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 1088
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.128
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(reportbycaption,char(0)))
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.135),offsety,(offsetx+ 1.135),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.260),offsety,(offsetx+ 1.260),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.010),offsety,(offsetx+ 4.010),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.875),offsety,(offsetx+ 6.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.000),offsety,(offsetx+ 7.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
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
 SUBROUTINE headpagerow2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagerow2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagerow2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_d_filter = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE __d_filter = vc WITH noconstant(build(filtercaption,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build("",char(0))), protect
   IF (bcontinue=0)
    SET _remd_filter = 1
    SET _remfieldname1 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.028)
   SET rptsd->m_width = 2.972
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremd_filter = _remd_filter
   IF (_remd_filter > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_filter,((size(
        __d_filter) - _remd_filter)+ 1),__d_filter)))
    SET drawheight_d_filter = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_filter = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_filter,((size(__d_filter) -
       _remd_filter)+ 1),__d_filter)))))
     SET _remd_filter = (_remd_filter+ rptsd->m_drawlength)
    ELSE
     SET _remd_filter = 0
    ENDIF
    SET growsum = (growsum+ _remd_filter)
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.892)
   SET rptsd->m_width = 0.128
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.028)
   SET rptsd->m_width = 2.972
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_filter > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_filter,((size(
        __d_filter) - _holdremd_filter)+ 1),__d_filter)))
   ELSE
    SET _remd_filter = _holdremd_filter
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.892)
   SET rptsd->m_width = 0.128
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.007)
   SET rptsd->m_width = 2.878
   SET rptsd->m_height = sectionheight
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(filterbycaption,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 2.743
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(rpt_time_display,char(0)))
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 0.118
   SET rptsd->m_height = sectionheight
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.118
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(timereportcaption,char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.885),offsety,(offsetx+ 6.885),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.021),offsety,(offsetx+ 7.021),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
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
 SUBROUTINE headpagerow(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagerowabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagerowabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_h_edd = f8 WITH noconstant(0.0), private
   DECLARE drawheight_h_gest_age = f8 WITH noconstant(0.0), private
   DECLARE __h_edd = vc WITH noconstant(build(eddcaption,char(0))), protect
   DECLARE __h_gest_age = vc WITH noconstant(build(gestagecaption,char(0))), protect
   IF (bcontinue=0)
    SET _remh_edd = 1
    SET _remh_gest_age = 1
   ENDIF
   SET rptsd->m_flags = 1061
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.517)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremh_edd = _remh_edd
   IF (_remh_edd > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remh_edd,((size(__h_edd)
        - _remh_edd)+ 1),__h_edd)))
    SET drawheight_h_edd = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remh_edd = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remh_edd,((size(__h_edd) - _remh_edd)+ 1),
       __h_edd)))))
     SET _remh_edd = (_remh_edd+ rptsd->m_drawlength)
    ELSE
     SET _remh_edd = 0
    ENDIF
    SET growsum = (growsum+ _remh_edd)
   ENDIF
   SET rptsd->m_flags = 1061
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 1.253
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremh_gest_age = _remh_gest_age
   IF (_remh_gest_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remh_gest_age,((size(
        __h_gest_age) - _remh_gest_age)+ 1),__h_gest_age)))
    SET drawheight_h_gest_age = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remh_gest_age = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remh_gest_age,((size(__h_gest_age) -
       _remh_gest_age)+ 1),__h_gest_age)))))
     SET _remh_gest_age = (_remh_gest_age+ rptsd->m_drawlength)
    ELSE
     SET _remh_gest_age = 0
    ENDIF
    SET growsum = (growsum+ _remh_gest_age)
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 8.257)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(facilitycaption,char(0)))
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.507)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(physiciancaption,char(0)))
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.517)
   SET rptsd->m_width = 0.983
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremh_edd > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremh_edd,((size(
        __h_edd) - _holdremh_edd)+ 1),__h_edd)))
   ELSE
    SET _remh_edd = _holdremh_edd
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.257)
   SET rptsd->m_width = 1.253
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremh_gest_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremh_gest_age,((size(
        __h_gest_age) - _holdremh_gest_age)+ 1),__h_gest_age)))
   ELSE
    SET _remh_gest_age = _holdremh_gest_age
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.767)
   SET rptsd->m_width = 1.483
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(firstnamecaption,char(0)))
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.503
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(lastnamecaption,char(0)))
   ENDIF
   SET rptsd->m_flags = 1060
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(patientidcaption,char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.760),offsety,(offsetx+ 2.760),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.250),offsety,(offsetx+ 4.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.510),offsety,(offsetx+ 5.510),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.250),offsety,(offsetx+ 8.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
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
 SUBROUTINE headpagerow3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagerow3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.040000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdtopborder
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 0.007)
    SET rptsd->m_width = 9.993
    SET rptsd->m_height = 0.056
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagerow4(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagerow4abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF ( NOT ((pregnancy->patient_cnt=0)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 0.007)
    SET rptsd->m_width = 9.993
    SET rptsd->m_height = 0.503
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(nodatacaption,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailrow(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailrowabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailrowabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_d_facility = f8 WITH noconstant(0.0), private
   DECLARE drawheight_d_provider = f8 WITH noconstant(0.0), private
   DECLARE drawheight_d_edd = f8 WITH noconstant(0.0), private
   DECLARE drawheight_d_gest_age = f8 WITH noconstant(0.0), private
   DECLARE drawheight_d_patient_fname = f8 WITH noconstant(0.0), private
   DECLARE drawheight_d_patient_lname = f8 WITH noconstant(0.0), private
   DECLARE drawheight_d_mrn_fin = f8 WITH noconstant(0.0), private
   DECLARE __d_facility = vc WITH noconstant(build(pregnancy->patient[d.seq].facility,char(0))),
   protect
   DECLARE __d_provider = vc WITH noconstant(build(pregnancy->patient[d.seq].primary_physician,char(0
      ))), protect
   DECLARE __d_edd = vc WITH noconstant(build(pregnancy->patient[d.seq].edd,char(0))), protect
   DECLARE __d_gest_age = vc WITH noconstant(build(pregnancy->patient[d.seq].gest_age,char(0))),
   protect
   DECLARE __d_patient_fname = vc WITH noconstant(build(pregnancy->patient[d.seq].person_firstname,
     char(0))), protect
   DECLARE __d_patient_lname = vc WITH noconstant(build(pregnancy->patient[d.seq].person_lastname,
     char(0))), protect
   DECLARE __d_mrn_fin = vc WITH noconstant(build(pregnancy->patient[d.seq].mrn,char(0))), protect
   IF ( NOT ((pregnancy->patient_cnt > 0)))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remd_facility = 1
    SET _remd_provider = 1
    SET _remd_edd = 1
    SET _remd_gest_age = 1
    SET _remd_patient_fname = 1
    SET _remd_patient_lname = 1
    SET _remd_mrn_fin = 1
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 8.267)
   SET rptsd->m_width = 1.733
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremd_facility = _remd_facility
   IF (_remd_facility > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_facility,((size(
        __d_facility) - _remd_facility)+ 1),__d_facility)))
    SET drawheight_d_facility = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_facility = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_facility,((size(__d_facility) -
       _remd_facility)+ 1),__d_facility)))))
     SET _remd_facility = (_remd_facility+ rptsd->m_drawlength)
    ELSE
     SET _remd_facility = 0
    ENDIF
    SET growsum = (growsum+ _remd_facility)
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.517)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremd_provider = _remd_provider
   IF (_remd_provider > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_provider,((size(
        __d_provider) - _remd_provider)+ 1),__d_provider)))
    SET drawheight_d_provider = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_provider = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_provider,((size(__d_provider) -
       _remd_provider)+ 1),__d_provider)))))
     SET _remd_provider = (_remd_provider+ rptsd->m_drawlength)
    ELSE
     SET _remd_provider = 0
    ENDIF
    SET growsum = (growsum+ _remd_provider)
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.517)
   SET rptsd->m_width = 0.993
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremd_edd = _remd_edd
   IF (_remd_edd > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_edd,((size(__d_edd)
        - _remd_edd)+ 1),__d_edd)))
    SET drawheight_d_edd = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_edd = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_edd,((size(__d_edd) - _remd_edd)+ 1),
       __d_edd)))))
     SET _remd_edd = (_remd_edd+ rptsd->m_drawlength)
    ELSE
     SET _remd_edd = 0
    ENDIF
    SET growsum = (growsum+ _remd_edd)
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.267)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremd_gest_age = _remd_gest_age
   IF (_remd_gest_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_gest_age,((size(
        __d_gest_age) - _remd_gest_age)+ 1),__d_gest_age)))
    SET drawheight_d_gest_age = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_gest_age = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_gest_age,((size(__d_gest_age) -
       _remd_gest_age)+ 1),__d_gest_age)))))
     SET _remd_gest_age = (_remd_gest_age+ rptsd->m_drawlength)
    ELSE
     SET _remd_gest_age = 0
    ENDIF
    SET growsum = (growsum+ _remd_gest_age)
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.767)
   SET rptsd->m_width = 1.493
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremd_patient_fname = _remd_patient_fname
   IF (_remd_patient_fname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_patient_fname,((size
       (__d_patient_fname) - _remd_patient_fname)+ 1),__d_patient_fname)))
    SET drawheight_d_patient_fname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_patient_fname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_patient_fname,((size(
        __d_patient_fname) - _remd_patient_fname)+ 1),__d_patient_fname)))))
     SET _remd_patient_fname = (_remd_patient_fname+ rptsd->m_drawlength)
    ELSE
     SET _remd_patient_fname = 0
    ENDIF
    SET growsum = (growsum+ _remd_patient_fname)
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.503
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremd_patient_lname = _remd_patient_lname
   IF (_remd_patient_lname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_patient_lname,((size
       (__d_patient_lname) - _remd_patient_lname)+ 1),__d_patient_lname)))
    SET drawheight_d_patient_lname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_patient_lname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_patient_lname,((size(
        __d_patient_lname) - _remd_patient_lname)+ 1),__d_patient_lname)))))
     SET _remd_patient_lname = (_remd_patient_lname+ rptsd->m_drawlength)
    ELSE
     SET _remd_patient_lname = 0
    ENDIF
    SET growsum = (growsum+ _remd_patient_lname)
   ENDIF
   SET rptsd->m_flags = 293
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremd_mrn_fin = _remd_mrn_fin
   IF (_remd_mrn_fin > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remd_mrn_fin,((size(
        __d_mrn_fin) - _remd_mrn_fin)+ 1),__d_mrn_fin)))
    SET drawheight_d_mrn_fin = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remd_mrn_fin = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remd_mrn_fin,((size(__d_mrn_fin) -
       _remd_mrn_fin)+ 1),__d_mrn_fin)))))
     SET _remd_mrn_fin = (_remd_mrn_fin+ rptsd->m_drawlength)
    ELSE
     SET _remd_mrn_fin = 0
    ENDIF
    SET growsum = (growsum+ _remd_mrn_fin)
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 8.267)
   SET rptsd->m_width = 1.733
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_facility > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_facility,((size(
        __d_facility) - _holdremd_facility)+ 1),__d_facility)))
   ELSE
    SET _remd_facility = _holdremd_facility
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.517)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_provider > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_provider,((size(
        __d_provider) - _holdremd_provider)+ 1),__d_provider)))
   ELSE
    SET _remd_provider = _holdremd_provider
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.517)
   SET rptsd->m_width = 0.993
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_edd > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_edd,((size(
        __d_edd) - _holdremd_edd)+ 1),__d_edd)))
   ELSE
    SET _remd_edd = _holdremd_edd
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.267)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_gest_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_gest_age,((size(
        __d_gest_age) - _holdremd_gest_age)+ 1),__d_gest_age)))
   ELSE
    SET _remd_gest_age = _holdremd_gest_age
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.767)
   SET rptsd->m_width = 1.493
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_patient_fname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_patient_fname,((
       size(__d_patient_fname) - _holdremd_patient_fname)+ 1),__d_patient_fname)))
   ELSE
    SET _remd_patient_fname = _holdremd_patient_fname
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.257)
   SET rptsd->m_width = 1.503
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_patient_lname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_patient_lname,((
       size(__d_patient_lname) - _holdremd_patient_lname)+ 1),__d_patient_lname)))
   ELSE
    SET _remd_patient_lname = _holdremd_patient_lname
   ENDIF
   SET rptsd->m_flags = 292
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.243
   SET rptsd->m_height = sectionheight
   IF (ncalc=rpt_render
    AND _holdremd_mrn_fin > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremd_mrn_fin,((size(
        __d_mrn_fin) - _holdremd_mrn_fin)+ 1),__d_mrn_fin)))
   ELSE
    SET _remd_mrn_fin = _holdremd_mrn_fin
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.250),offsety,(offsetx+ 1.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.760),offsety,(offsetx+ 2.760),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.260),offsety,(offsetx+ 4.260),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.510),offsety,(offsetx+ 5.510),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.510),offsety,(offsetx+ 6.510),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.260),offsety,(offsetx+ 8.260),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
   ENDIF
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
 SUBROUTINE footpagerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 8.007)
    SET rptsd->m_width = 1.993
    SET rptsd->m_height = 0.243
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 6.007)
    SET rptsd->m_width = 1.993
    SET rptsd->m_height = 0.243
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 4.007)
    SET rptsd->m_width = 1.993
    SET rptsd->m_height = 0.243
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 2.007)
    SET rptsd->m_width = 1.993
    SET rptsd->m_height = 0.243
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 0.007)
    SET rptsd->m_width = 1.993
    SET rptsd->m_height = 0.243
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.000),offsety,(offsetx+ 2.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),offsety,(offsetx+ 4.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.000),offsety,(offsetx+ 6.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.000),offsety,(offsetx+ 8.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportrow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportrowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportrowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1040
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.007)
    SET rptsd->m_x = (offsetx+ 0.007)
    SET rptsd->m_width = 9.993
    SET rptsd->m_height = 0.545
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(endofreportcaption,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16777215)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 10.000),(offsety
     + 0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 10.000),offsety,(offsetx+ 10.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 10.000),(
     offsety+ sectionheight))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "DCP_RPT_OPEN_PREG"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
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
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_rgbcolor = rpt_white
   SET _pen14s0c16777215 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL query2(0)
 CALL finalizereport(_sendto)
END GO
