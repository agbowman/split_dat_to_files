CREATE PROGRAM amb_imx_patient_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica18b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c14540253 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = size(brec->edata,5))
    PLAN (d1
     WHERE d1.seq > 0)
    ORDER BY d1.seq
    HEAD REPORT
     _d0 = d1.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fdrawheight
      = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    HEAD d1.seq
     row + 0
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  d1.seq
     row + 0
    FOOT REPORT
     _fdrawheight = footreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportsection(rpt_render)
    WITH nocounter, append
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
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
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(3.520000), private
   DECLARE __patname = vc WITH noconstant(build2(report_data->pt_name,char(0))), protect
   DECLARE __printdate = vc WITH noconstant(build2(report_data->print_dt,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(report_data->pt_mrn,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(report_data->pt_dob,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(report_data->pt_age,char(0))), protect
   DECLARE __orgname = vc WITH noconstant(build2(report_data->fac,char(0))), protect
   DECLARE __fac_addr1 = vc WITH noconstant(build2(report_data->fac_addr1,char(0))), protect
   DECLARE __fac_addrstate = vc WITH noconstant(build2(concat(report_data->fac_city,", ",report_data
      ->fac_state," ",report_data->fac_zip),char(0))), protect
   DECLARE __fac_phone = vc WITH noconstant(build2(report_data->fac_phone,char(0))), protect
   DECLARE __pcp = vc WITH noconstant(build2(report_data->pcp,char(0))), protect
   DECLARE __printby = vc WITH noconstant(build2(report_data->print_by,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.542)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.542)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.797),(offsetx+ 7.500),(offsety+
     1.797))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.292)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.354
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica18b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Preventive Services Report",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.052
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__printdate)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.604)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 1.604)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 1.604)
    SET rptsd->m_x = (offsetx+ 6.375)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.604)
    SET rptsd->m_x = (offsetx+ 4.188)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_y = (offsety+ 1.604)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 1.604)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET rptsd->m_y = (offsety+ 0.604)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orgname)
    SET rptsd->m_y = (offsety+ 0.844)
    SET rptsd->m_x = (offsetx+ 0.073)
    SET rptsd->m_width = 4.677
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fac_addr1)
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fac_addrstate)
    SET rptsd->m_y = (offsety+ 1.229)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.688
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fac_phone)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c14540253)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 3.271),7.500,0.250,
     rpt_fill,uar_rptencodecolor(192,192,192))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 5.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Eligible Covered Services",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 3.302)
    SET rptsd->m_x = (offsetx+ 5.813)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Eligible",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 1.917),7.500,1.260,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.979)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Care Physician:",char(0)))
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Referrals Recommended:",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.750),(offsety+ 1.979),0.104,0.104,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 1.906)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes | No",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.479),(offsety+ 1.979),0.104,0.104,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.979)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed By:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.094)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__printby)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE __service_name = vc WITH noconstant(build2(brec->edata[d1.seq].groupname,char(0))),
   protect
   DECLARE __report_date = vc WITH noconstant(build2(brec->edata[d1.seq].reportdate,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.050
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c14540253)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__service_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
    SET rptsd->m_padding = rpt_sdrightborder
    SET rptsd->m_paddingwidth = 0.230
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.010)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__report_date)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 0.094)
    SET rptsd->m_width = 7.281
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "*Note: Services are eligible at a future date. Receiving service before this date may require co-payment or coinsurance.",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.094)
    SET rptsd->m_width = 7.281
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "For more information, refer to http://medicare.gov. Look for Preventive Services, or call (800) 633-4227.",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.094)
    SET rptsd->m_width = 7.281
    SET rptsd->m_height = 1.438
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Disclaimer: Actual eligibility for Preventive Services may vary by patient due to a variety of reasons, includi",
       "ng, but not limited to, preexisting diagnoses or risk factors, age, sex, alternative services previously provi",
       "ded, and type of Medicare eligibility. Some services may incur charges if corrective services are performed duri",
       "ng the screenings. The list of Preventive Services presented is not all-inclusive. Please refer to CMS Preventive",
       " Service references for all services and their specific coverage information. All information provided is from ",
       "Medicare records. The provider is responsible for verifying the medical necessity of any Preventive Services ",
       "that are shown to be eligible per Medicare records."),char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "AMB_IMX_PATIENT_REPORT_LAYOUT"
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
   SET rptfont->m_recsize = 60
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
   SET rptfont->m_bold = rpt_on
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 18
   SET rptfont->m_bold = rpt_on
   SET _helvetica18b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_rgbcolor = uar_rptencodecolor(221,221,221)
   SET _pen14s0c14540253 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
