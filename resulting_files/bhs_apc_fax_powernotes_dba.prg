CREATE PROGRAM bhs_apc_fax_powernotes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Run Mode:" = "",
  "Begin Date Time" = "SYSDATE",
  "End Date Time" = "SYSDATE",
  "APC age in hrs before faxing:" = 48,
  "Create CSV?" = "",
  "CSV Recipient:" = ""
  WITH outdev, s_mode, s_beg_dt_tm,
  s_end_dt_tm, l_apc_age, c_csv_ind,
  s_csv_recipient
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE coversheet_section(ncalc=i2) = f8 WITH protect
 DECLARE coversheet_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE head_section(ncalc=i2) = f8 WITH protect
 DECLARE head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE powernote_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE powernote_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
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
 DECLARE _remphydischsumlbl = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpowernote_section = i2 WITH noconstant(0), protect
 DECLARE _hrtf_phydischsumlbl = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE coversheet_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = coversheet_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE coversheet_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.750000), private
   DECLARE __fax_dt_tm = vc WITH noconstant(build2(build(format(cnvtdatetime(curdate,curtime3),
       "MM/DD/YY HH:MM;;q")),char(0))), protect
   DECLARE __pcp_name = vc WITH noconstant(build2(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name,
     char(0))), protect
   DECLARE __patient_name = vc WITH noconstant(build2(m_rec->fax[ml_idx].s_patient,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fax_dt_tm)
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_powernote_title,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phys Name:",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fax date/time:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 1.750
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat("Confidentiality Note:",_crlf,
       "This facsimile transmittal may contain confidential patient medical record information and is intended only for ",
       "the use of the entity to which it is addressed. If the reader of this transmittal is not the intended recipient,",
       " or the employee or agent responsible for delivering the transmittal to the intended recipient, you are hereby n",
       "otified that any dissemination, distribution or copying of this communication is strictly prohibited. If you hav",
       "e received this communication in error, please notify us immediately by telephone at 413-794-1223. Thank you."
       ),char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE head_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE head_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.630000), private
   DECLARE __fax_dt_tm = vc WITH noconstant(build2(build(format(cnvtdatetime(curdate,curtime3),
       "MM/DD/YY HH:MM;;q")),char(0))), protect
   DECLARE __pcp_name = vc WITH noconstant(build2(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name,
     char(0))), protect
   DECLARE __patient_name = vc WITH noconstant(build2(m_rec->fax[ml_idx].s_patient,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(m_rec->fax[ml_idx].s_mrn_nbr,char(0))), protect
   DECLARE __fin = vc WITH noconstant(build2(m_rec->fax[ml_idx].s_acct_nbr,char(0))), protect
   DECLARE __admit_date = vc WITH noconstant(build2(m_rec->fax[ml_idx].s_admit_dt,char(0))), protect
   DECLARE __disch_date = vc WITH noconstant(build2(m_rec->fax[ml_idx].s_disch_dt,char(0))), protect
   DECLARE __location = vc WITH noconstant(build2(concat(m_rec->fax[ml_idx].s_nurse_unit," ",m_rec->
      fax[ml_idx].s_facility),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fax_dt_tm)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_powernote_title,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phys Name:",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fax date/time:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Disch Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__disch_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__location)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE powernote_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powernote_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE powernote_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_phydischsumlbl = f8 WITH noconstant(0.0), private
   DECLARE __phydischsumlbl = vc WITH noconstant(build2(ms_blob_rtf,char(0))), protect
   IF (bcontinue=0)
    SET _remphydischsumlbl = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remphydischsumlbl > 0)
    IF (_hrtf_phydischsumlbl=0)
     SET _hrtf_phydischsumlbl = uar_rptcreatertf(_hreport,__phydischsumlbl,5.250)
    ENDIF
    IF (_hrtf_phydischsumlbl != 0)
     SET _fdrawheight = maxheight
     SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_phydischsumlbl,(offsetx+ 0.000),(offsety+ 0.000),
      _fdrawheight)
    ENDIF
    IF ((_fdrawheight > (sectionheight - 0.000)))
     SET sectionheight = (0.000+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_phydischsumlbl)
     SET _hrtf_phydischsumlbl = 0
     SET _remphydischsumlbl = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remphydischsumlbl)
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "BHS_APC_FAX_POWERNOTES"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
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
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 EXECUTE bhs_hlp_ccl
 EXECUTE bhs_check_domain:dba
 FREE RECORD fax_reply
 RECORD fax_reply(
   1 sts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetojbectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 res[*]
     2 s_display_key = vc
     2 s_display = vc
     2 f_pos_cd = f8
   1 fax[*]
     2 s_patient = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_admit_dt = vc
     2 s_acct_nbr = vc
     2 s_mrn_nbr = vc
     2 s_disch_dt = vc
     2 s_nurse_unit = vc
     2 s_facility = vc
     2 s_sign_phys_name = vc
     2 f_sign_phys_id = f8
     2 s_note_type = vc
     2 s_note_title = vc
     2 f_event_id = f8
     2 f_parent_event_id = f8
     2 f_contr_sys_cd = f8
     2 s_contr_sys = vc
     2 s_cep_action_dt_tm = vc
     2 n_data_ind = i2
     2 s_qual_dt_tm = vc
     2 l_sort = i4
     2 s_sign_par_or_chld = vc
     2 recip[*]
       3 s_phys_name = vc
       3 s_phys_username = vc
       3 f_phys_id = f8
       3 n_bmp_phys_ind = i2
       3 s_fax_nbr = vc
       3 n_fax_nbr_ind = i2
       3 n_exclude_ind = i2
       3 n_fax_stat = i2
       3 n_inbox_stat = i2
       3 n_docmgr_stat = i2
       3 l_log_grp_cnt = i2
       3 s_file_name = vc
       3 n_file_found = i2
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_mode = vc WITH protect, constant(trim(cnvtupper( $S_MODE)))
 DECLARE mc_csv_ind = c1 WITH protect, constant(trim(cnvtupper( $C_CSV_IND)))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_fax_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3000,"FAX"))
 DECLARE mf_fax_bus_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS"))
 DECLARE mf_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"PCP"))
 DECLARE mf_story_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE mf_fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_nbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_discharged_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE ms_email_filename = vc WITH protect, constant("autofax_email_file.txt")
 DECLARE mf_routine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",1304,"ROUTINE"))
 DECLARE ms_urgnote_disp_key = vc WITH protect, constant("URGENTCARENOTE")
 DECLARE ms_dm_info_name = vc WITH protect, constant(concat("NOTES_FAXING_",ms_mode,"_STOP_DT_TM"))
 DECLARE ml_pcp_max_hrs = i4 WITH protect, constant(48)
 DECLARE ml_pcp_job_hrs = i4 WITH protect, constant(24)
 DECLARE ml_apc_max_hrs = i4 WITH protect, constant(48)
 DECLARE ml_apc_job_hrs = i4 WITH protect, constant(24)
 DECLARE ml_apc_age_hrs = i4 WITH protect, constant( $L_APC_AGE)
 DECLARE ms_look_interval = vc WITH protect, constant(concat(trim(cnvtstring( $L_APC_AGE)),",H"))
 DECLARE mf_nuance_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"NUANCE"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant( $S_BEG_DT_TM)
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant( $S_END_DT_TM)
 DECLARE ms_apc_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_apc_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant( $S_CSV_RECIPIENT)
 DECLARE mf_doc_mgr_pool_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_note_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_csv_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_prefix = vc WITH protect, noconstant(" ")
 DECLARE ms_dm_stop_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_max_hrs = vc WITH protect, noconstant(" ")
 DECLARE ms_job_hrs = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_blob = vc WITH protect, noconstant(" ")
 DECLARE ms_fin_nbr = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE mf_output_dest_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp2 = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_recip_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_test = i2 WITH protect, noconstant(0)
 DECLARE ms_powernote_title = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE becont = i4 WITH protect, noconstant(0)
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_body = vc WITH protect, noconstant(" ")
 DECLARE ml_sent_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_log_grp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_lastname = vc WITH protect, noconstant(" ")
 DECLARE ms_firstname = vc WITH protect, noconstant(" ")
 DECLARE ms_blob_rtf = vc WITH protect, noconstant(" ")
 DECLARE ms_cc_rtf = vc WITH protect, noconstant(" ")
 DECLARE mf_urgentcare_id = f8 WITH protect, noconstant(0.0)
 DECLARE sbr_get_fax_nbrs(ml_rec_idx=i4) = null
 DECLARE sbr_upd_dm_info(ms_stop_dt_tm=vc) = null
 RECORD inboxrequest(
   1 message_list[*]
     2 draft_msg_uid = vc
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 task_type_cd = f8
     2 priority_cd = f8
     2 save_to_chart_ind = i2
     2 msg_sender_pool_id = f8
     2 msg_sender_person_id = f8
     2 msg_sender_prsnl_id = f8
     2 msg_subject = vc
     2 refill_request_ind = i2
     2 msg_text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 callername = vc
     2 callerphone = vc
     2 notify_info[1]
       3 notify_pool_ind = f8
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list[*]
         4 notify_status_cd = f8
         4 delay[1]
           5 value = i4
           5 unit_flag = i2
     2 action_request_list[*]
       3 action_request_cd = f8
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
       3 reply_allowed_ind = i2
     2 assign_pool_list[*]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 encounter_class_cd = f8
     2 encounter_type_cd = f8
     2 org_id = f8
     2 get_best_encounter = i2
     2 create_encounter = i2
     2 proposed_order_list[*]
       3 proposed_order_id = f8
     2 event_id = f8
     2 order_id = f8
     2 encntr_prsnl_reltn_cd = f8
     2 facility_cd = f8
     2 send_to_chart_ind = i2
     2 original_task_uid = vc
     2 rx_renewal_list[*]
       3 rx_renewal_uid = vc
     2 task_status_flag = i2
     2 task_activity_flag = i2
     2 event_class_flag = i2
     2 attachments[*]
       3 name = c255
       3 location_handle = c255
       3 media_identifier = c255
       3 media_version = i4
     2 sender_email = c320
     2 assign_emails[*]
       3 email = c320
       3 cc_ind = i2
       3 selection_nbr = i4
       3 first_name = c100
       3 last_name = c100
       3 display_name = c100
     2 sender_email_display_name = c100
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 skip_validation_ind = i2
 )
 RECORD inboxreply(
   1 task_id = f8
   1 status_data[1]
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 invalid_receivers[*]
     2 entity_id = f8
     2 entity_type = vc
 )
 CALL echo(concat("Begin Log: Mode:",ms_mode," ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script-TEST","")
 IF (((validate(request->batch_selection)) OR (mn_ops=1)) )
  SET mn_ops = 1
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="BHS_OPS_FAX_POWERNOTES"
    AND d.info_name=ms_dm_info_name
   DETAIL
    ms_beg_dt_tm = trim(format(d.info_date,"dd-mmm-yyyy hh:mm:ss;;d"))
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_msg = "001 - DM_INFO row not found"
   GO TO send_page
  ENDIF
  IF (ms_mode="PCP")
   IF (datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3) > ml_pcp_max_hrs)
    SET ms_msg = concat("002 - Last job ended over ",trim(cnvtstring(ml_pcp_max_hrs)),"hrs ago")
    SET ms_max_hrs = trim(cnvtstring(ml_pcp_max_hrs))
    SET ms_job_hrs = trim(cnvtstring(ml_pcp_job_hrs))
    GO TO send_page
   ENDIF
  ELSEIF (ms_mode="APC")
   IF (datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3) > ml_apc_max_hrs)
    SET ms_msg = concat("002 - Last job ended over ",trim(cnvtstring(ml_apc_max_hrs)),"hrs ago")
    SET ms_max_hrs = trim(cnvtstring(ml_apc_max_hrs))
    SET ms_job_hrs = trim(cnvtstring(ml_apc_job_hrs))
    GO TO send_page
   ENDIF
  ENDIF
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
  IF (ms_mode="APC")
   SET ms_apc_beg_dt_tm = trim(format(cnvtlookbehind(ms_look_interval,cnvtdatetime(ms_beg_dt_tm)),
     "dd-mmm-yyyy hh:mm:ss;;d"))
   SET ms_apc_end_dt_tm = trim(format(cnvtlookbehind(ms_look_interval,cnvtdatetime(ms_end_dt_tm)),
     "dd-mmm-yyyy hh:mm:ss;;d"))
  ENDIF
 ELSE
  IF (((textlen(trim(ms_beg_dt_tm))=0) OR (textlen(trim(ms_end_dt_tm))=0)) )
   SET ms_msg = "Warning: For non-ops runs of this script, you have to enter a date range - Exiting"
   GO TO exit_script
  ELSEIF (cnvtdatetime(ms_end_dt_tm) <= cnvtdatetime(ms_beg_dt_tm))
   SET ms_msg = "Warning: End Date must be later than Begin Date - Exiting"
   GO TO exit_script
  ENDIF
  IF (ms_mode="APC")
   SET ms_apc_beg_dt_tm = trim(format(cnvtlookbehind(ms_look_interval,cnvtdatetime(ms_beg_dt_tm)),
     "dd-mmm-yyyy hh:mm:ss;;d"))
   SET ms_apc_end_dt_tm = trim(format(cnvtlookbehind(ms_look_interval,cnvtdatetime(ms_end_dt_tm)),
     "dd-mmm-yyyy hh:mm:ss;;d"))
   CALL echo(concat("APC Beg: ",ms_apc_beg_dt_tm))
   CALL echo(concat("APC End: ",ms_apc_end_dt_tm))
  ENDIF
 ENDIF
 IF (mc_csv_ind="Y"
  AND mn_ops=0)
  IF (((findstring("@",ms_recipients)=0) OR (textlen(ms_recipients)=0)) )
   SET ms_msg = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
 ELSEIF (mc_csv_ind="Y"
  AND mn_ops=1)
  IF (findstring("@",ms_recipients)=0)
   SET ms_recipients = "joe.echols@bhs.org"
  ENDIF
 ENDIF
 IF (gl_bhs_prod_flag=0)
  SET mn_test = 1
 ENDIF
 IF (ms_mode="PCP")
  SET ms_dclcom_str = "rm $bhscust/fax1_*"
 ELSEIF (ms_mode="APC")
  SET ms_dclcom_str = "rm $bhscust/fax2_*"
 ENDIF
 SET len = textlen(trim(ms_dclcom_str))
 SET status = 0
 SELECT INTO "nl:"
  FROM device d,
   output_dest od
  PLAN (d
   WHERE d.description="Auto Fax Station")
   JOIN (od
   WHERE od.device_cd=d.device_cd)
  DETAIL
   mf_output_dest_cd = od.output_dest_cd
  WITH nocounter
 ;end select
 IF (mf_output_dest_cd=0
  AND mn_test=0)
  CALL echo("output_dest_cd = 0; no autofax station: exiting")
  SET ms_msg = "Output destination 'Auto Fax Station' not found"
  GO TO exit_script
 ELSE
  CALL echo(concat("output_dest_cd = ",trim(cnvtstring(mf_output_dest_cd))))
 ENDIF
 IF (ms_mode="APC")
  SELECT INTO "nl:"
   FROM prsnl_group pg
   WHERE pg.prsnl_group_name_key="BHDOCUMENTMANAGEMENT"
    AND pg.active_ind=1
   HEAD pg.prsnl_group_name_key
    mf_doc_mgr_pool_id = pg.prsnl_group_id
   WITH nocounter
  ;end select
  IF (mf_doc_mgr_pool_id=0.0)
   SET ms_msg = "Document Manager Pool not found"
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display_key="*RESIDENT*")
  HEAD REPORT
   pl_cnt = 0
  HEAD cv.code_value
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->res,5))
    stat = alterlist(m_rec->res,(pl_cnt+ 3))
   ENDIF
   m_rec->res[pl_cnt].f_pos_cd = cv.code_value, m_rec->res[pl_cnt].s_display = trim(cv.display),
   m_rec->res[pl_cnt].s_display_key = trim(cv.display_key)
  FOOT REPORT
   stat = alterlist(m_rec->res,pl_cnt)
  WITH nocounter
 ;end select
 IF (ms_mode="PCP")
  CALL echo("not apc")
 ELSEIF (ms_mode="APC")
  CALL echo("find dictated notes to fax")
  SELECT DISTINCT INTO "nl:"
   ce.event_id, p.person_id, ps_title = substring(1,40,trim(ce.event_title_text)),
   cep.updt_dt_tm, cep.action_prsnl_id
   FROM clinical_event ce,
    ce_event_prsnl cep,
    prsnl pr1,
    person p,
    encounter e,
    ce_blob cb
   PLAN (ce
    WHERE ce.event_id IN (
    (SELECT
     x.person_id
     FROM bhs_physician_fax_list x
     WHERE x.person_id > 0))
     AND ce.event_cd IN (
    (SELECT
     b.event_cd
     FROM bhs_event_cd_list b
     WHERE b.grouper=concat(ms_mode,"-NUANCE")
      AND b.listkey="NOTES FAXING"
      AND b.active_ind=1))
     AND ce.authentic_flag=1
     AND ce.event_class_cd=mf_doc_cd
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(ms_apc_beg_dt_tm) AND cnvtdatetime(
     ms_apc_end_dt_tm))
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.active_ind=1)
    JOIN (cep
    WHERE cep.event_id IN (ce.parent_event_id, ce.event_id)
     AND cep.valid_until_dt_tm > sysdate
     AND cep.action_type_cd=mf_sign_cd
     AND cep.action_status_cd=mf_completed_cd
     AND cep.action_dt_tm BETWEEN cnvtdatetime(ms_apc_beg_dt_tm) AND cnvtdatetime(ms_apc_end_dt_tm))
    JOIN (pr1
    WHERE pr1.person_id=cep.action_prsnl_id
     AND  NOT (expand(ml_idx,1,size(m_rec->res,5),pr1.position_cd,m_rec->res[ml_idx].f_pos_cd)))
    JOIN (p
    WHERE p.person_id=ce.person_id
     AND p.active_ind=1)
    JOIN (cb
    WHERE cb.event_id=ce.event_id
     AND cb.valid_until_dt_tm > sysdate)
   ORDER BY p.person_id, ps_title, cep.action_dt_tm DESC
   HEAD REPORT
    pl_cnt = size(m_rec->fax,5)
   HEAD ce.event_id
    pl_cnt = (pl_cnt+ 1)
    IF (pl_cnt > size(m_rec->fax,5))
     stat = alterlist(m_rec->fax,(pl_cnt+ 25))
    ENDIF
    IF (cep.event_id=ce.parent_event_id)
     m_rec->fax[pl_cnt].s_sign_par_or_chld = "PARENT"
    ELSEIF (cep.event_id=ce.event_id)
     m_rec->fax[pl_cnt].s_sign_par_or_chld = "CHILD"
    ENDIF
    m_rec->fax[pl_cnt].s_patient = trim(p.name_full_formatted), m_rec->fax[pl_cnt].f_person_id = p
    .person_id, m_rec->fax[pl_cnt].f_encntr_id = ce.encntr_id,
    m_rec->fax[pl_cnt].s_note_type = trim(uar_get_code_display(ce.event_cd)), m_rec->fax[pl_cnt].
    s_admit_dt = trim(format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;d")), m_rec->fax[pl_cnt].s_disch_dt =
    trim(format(e.disch_dt_tm,"MM/DD/YYYY HH:MM;;d")),
    m_rec->fax[pl_cnt].f_event_id = ce.event_id, m_rec->fax[pl_cnt].f_sign_phys_id = cep
    .action_prsnl_id, m_rec->fax[pl_cnt].s_sign_phys_name = trim(pr1.name_full_formatted),
    m_rec->fax[pl_cnt].s_note_title = trim(ce.event_title_text), m_rec->fax[pl_cnt].
    s_cep_action_dt_tm = trim(format(cep.action_dt_tm,"MM/DD/YYYY HH:MM:SS;;d")), m_rec->fax[pl_cnt].
    s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd)),
    m_rec->fax[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->fax[pl_cnt]
    .s_qual_dt_tm = trim(format(cnvtlookahead(ms_look_interval,cep.action_dt_tm),
      "dd-mmm-yyyy hh:mm:ss;;d")), m_rec->fax[pl_cnt].f_contr_sys_cd = ce.contributor_system_cd,
    m_rec->fax[pl_cnt].s_contr_sys = trim(uar_get_code_display(ce.contributor_system_cd)), ms_tmp =
    concat("event_id: ",trim(cnvtstring(ce.event_id))," sign date: ",trim(format(cep.action_dt_tm,
       "mm/dd/yy hh:mm;;d"))," disch: ",
     m_rec->fax[pl_cnt].s_disch_dt)
   FOOT REPORT
    stat = alterlist(m_rec->fax,pl_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(m_rec->fax,5)=0)
  CALL echo("No records found for today - exiting")
  SET reply->status_data[1].status = "S"
  SET ms_msg = "No records found to fax"
  CALL sbr_upd_dm_info(ms_end_dt_tm)
  CALL uar_send_mail(nullterm(ms_recipients),nullterm(concat(ms_mode," NOTES FAXING OPS ",trim(format
      (sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(concat(ms_mode," - No notes found for this job")),
   nullterm(curnode),1,
   nullterm("IPM.NOTE"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->fax,5))),
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (ea1
   WHERE (ea1.encntr_id=m_rec->fax[d.seq].f_encntr_id)
    AND ea1.encntr_alias_type_cd=mf_fin_nbr_cd
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(m_rec->fax[d.seq].f_encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_nbr_cd)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm > outerjoin(cnvtdatetime(ms_beg_dt_tm)))
  ORDER BY d.seq
  HEAD d.seq
   m_rec->fax[d.seq].s_acct_nbr = trim(ea1.alias), m_rec->fax[d.seq].s_mrn_nbr = trim(ea2.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pq_date = cnvtdatetime(m_rec->fax[d.seq].s_qual_dt_tm)
  FROM (dummyt d  WITH seq = value(size(m_rec->fax,5)))
  ORDER BY pq_date
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), m_rec->fax[d.seq].l_sort = pl_cnt
  WITH nocounter
 ;end select
 FOR (ml_cnt = 1 TO size(m_rec->fax,5))
   SET ml_idx = locateval(ml_num,1,size(m_rec->fax,5),ml_cnt,m_rec->fax[ml_num].l_sort)
   CALL echo(build(ml_cnt," of ",size(m_rec->fax,5)," idx: ",ml_idx,
     " eventid: ",m_rec->fax[ml_idx].f_event_id))
   SET ml_sent_cnt = 0
   SET ms_blob_rtf = ""
   CALL echo("select blob")
   SELECT INTO "nl:"
    FROM ce_blob cb
    PLAN (cb
     WHERE (cb.event_id=m_rec->fax[ml_idx].f_event_id)
      AND cb.valid_until_dt_tm > sysdate)
    ORDER BY cb.updt_dt_tm DESC
    HEAD REPORT
     pl_cnt = 0, pl_num = 0, ps_blob_out = fillstring(32768," "),
     pl_blob_ret_len = 0, pl_beg = 0, pl_end = 0,
     pl_mid = 0
    HEAD cb.event_id
     ml_loop_cnt = 0, pl_num = 0
     IF (textlen(trim(cb.blob_contents)) > 0)
      ps_blob_out = fillstring(32768," "), pl_blob_ret_len = 0
      IF (cb.compression_cd=mf_comp_cd)
       CALL uar_ocf_uncompress(trim(cb.blob_contents),textlen(trim(cb.blob_contents)),ps_blob_out,
       size(ps_blob_out),32768), ms_blob_rtf = trim(ps_blob_out)
      ELSEIF (cb.compression_cd=mf_no_comp_cd)
       ms_blob_rtf = trim(cb.blob_contents)
       IF (findstring("ocf_blob",ms_blob_rtf) > 0)
        ms_blob_rtf = replace(ms_blob_rtf,"ocf_blob","",0)
       ENDIF
      ENDIF
      ps_blob_out = fillstring(32768," "),
      CALL uar_rtf(ms_blob_rtf,textlen(ms_blob_rtf),ps_blob_out,size(ps_blob_out),pl_blob_ret_len,1),
      ms_blob = trim(ps_blob_out)
      IF (ms_mode="APC"
       AND (m_rec->fax[ml_idx].f_contr_sys_cd != mf_nuance_cd))
       CALL echo("get the recipients out of the file"), pl_beg = findstring(
        "Report sent to all consultants:",ms_blob,1)
       IF (pl_beg > 0)
        pl_beg = (findstring(":",ms_blob,pl_beg)+ 1)
       ENDIF
       WHILE (pl_beg > 0)
         ml_loop_cnt = (ml_loop_cnt+ 1), pl_mid = findstring(",",ms_blob,pl_beg), pl_end = findstring
         (".",ms_blob,pl_beg),
         ms_tmp = trim(substring(pl_beg,(pl_end - pl_beg),ms_blob),3)
         IF (locateval(pl_num,1,size(m_rec->fax[ml_idx].recip,5),ms_tmp,m_rec->fax[ml_idx].recip[
          pl_num].s_phys_name)=0)
          pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->fax[ml_idx].recip,pl_cnt), ml_log_grp_cnt = (
          ml_log_grp_cnt+ 1),
          m_rec->fax[ml_idx].recip[pl_cnt].l_log_grp_cnt = ml_log_grp_cnt, m_rec->fax[ml_idx].recip[
          pl_cnt].s_phys_name = ms_tmp
         ENDIF
         pl_beg = findstring("Report sent to all consultants:",ms_blob,pl_end)
         IF (pl_beg > 0)
          pl_beg = (findstring(":",ms_blob,pl_beg)+ 1)
         ENDIF
         IF (ml_loop_cnt > 50)
          pl_beg = 0
         ENDIF
       ENDWHILE
      ELSEIF (ms_mode="APC"
       AND (m_rec->fax[ml_idx].f_contr_sys_cd=mf_nuance_cd))
       CALL echo("get the recipients out of the file - Nuance"), pl_beg = findstring("CC:",
        ms_blob_rtf,1,1)
       IF (pl_beg > 0)
        pl_beg = (findstring(":",ms_blob_rtf,pl_beg)+ 1), ms_cc_rtf = substring(pl_beg,textlen(
          ms_blob_rtf),ms_blob_rtf), pl_beg = 1
       ENDIF
       WHILE (pl_beg > 0)
         ml_loop_cnt = (ml_loop_cnt+ 1), pl_end = findstring(concat(char(92),"par"),ms_cc_rtf,pl_beg)
         IF (pl_end > 0)
          ms_tmp = trim(substring(pl_beg,(pl_end - pl_beg),ms_cc_rtf)), pl_beg = findstring("{",
           ms_tmp,1,1), ms_tmp = substring((pl_beg+ 1),textlen(ms_tmp),ms_tmp),
          ms_tmp = replace(ms_tmp,".",""), pl_mid = findstring(" ",ms_tmp,1)
          IF (pl_mid > 0)
           ms_firstname = substring(1,(pl_mid - 1),ms_tmp), ms_lastname = substring((pl_mid+ 1),
            textlen(ms_tmp),ms_tmp), ms_tmp = concat(ms_lastname,",",ms_firstname)
           IF (locateval(pl_num,1,size(m_rec->fax[ml_idx].recip,5),ms_tmp,m_rec->fax[ml_idx].recip[
            pl_num].s_phys_name)=0)
            pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->fax[ml_idx].recip,pl_cnt), ml_log_grp_cnt
             = (ml_log_grp_cnt+ 1),
            m_rec->fax[ml_idx].recip[pl_cnt].l_log_grp_cnt = ml_log_grp_cnt, m_rec->fax[ml_idx].
            recip[pl_cnt].s_phys_name = ms_tmp
           ENDIF
          ENDIF
         ENDIF
         IF (pl_end > 0)
          pl_beg = findstring(concat(char(92),"par",char(92),"par"),ms_cc_rtf,pl_end)
         ELSE
          pl_beg = 0
         ENDIF
         IF (pl_beg > 0)
          pl_beg = (findstring(" ",ms_cc_rtf,pl_beg)+ 1)
         ENDIF
         IF (ml_loop_cnt > 50)
          pl_beg = - (1)
         ENDIF
       ENDWHILE
      ENDIF
      IF (size(m_rec->fax[ml_idx].recip,5) > 0)
       ms_blob = ms_blob_rtf, pl_beg = 0, pl_end = 0,
       pl_beg = findstring("{\revised\revauth1",ms_blob), x = 0
       WHILE (pl_beg > 0)
         pl_end = findstring("}",ms_blob,pl_beg), ms_tmp = substring(pl_beg,((pl_end - pl_beg)+ 1),
          ms_blob), ms_tmp2 = replace(ms_tmp,"{\revised\revauth1","",0),
         ms_tmp2 = replace(ms_tmp2,"}","",0), ms_blob = replace(ms_blob,ms_tmp,ms_tmp2,0), pl_beg =
         findstring("{\revised\revauth1",ms_blob,pl_beg),
         x = (x+ 1)
         IF (x=1000)
          pl_beg = 0
         ENDIF
       ENDWHILE
       pl_beg = 0, pl_end = 0, pl_beg = findstring("{\deleted\",ms_blob),
       x = 0
       WHILE (pl_beg > 0)
         pl_end = findstring("}",ms_blob,pl_beg), ms_tmp = substring(pl_beg,((pl_end - pl_beg)+ 1),
          ms_blob), ms_blob = replace(ms_blob,ms_tmp,"",0),
         pl_beg = findstring("{\deleted\",ms_blob,pl_beg), x = (x+ 1)
         IF (x=1000)
          pl_beg = 0
         ENDIF
       ENDWHILE
       ms_blob_rtf = trim(ms_blob)
      ENDIF
      m_rec->fax[ml_idx].n_data_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (((curqual < 1) OR ((m_rec->fax[ml_idx].n_data_ind=0))) )
    CALL echo(concat("Data not found for event_id: ",trim(cnvtstring(m_rec->fax[ml_idx].f_event_id)))
     )
   ENDIF
   IF (size(m_rec->fax[ml_idx].recip,5)=0)
    CALL echo("no recipients found")
   ELSEIF (size(m_rec->fax[ml_idx].recip,5) > 0)
    CALL echo("at least one recipient")
    CALL sbr_get_fax_nbrs(ml_idx)
    IF ((m_rec->fax[ml_idx].n_data_ind=0))
     CALL echo("data not found for note")
     FOR (ml_recip_cnt = 1 TO size(m_rec->fax[ml_idx].recip,5))
       CALL echo("log error for each recip - no data found for note")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
        m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
        "Fail","No data found for Note","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
        m_rec->fax[ml_idx].f_person_id,
        "Patient person_id","","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
        m_rec->fax[ml_idx].f_encntr_id,
        "Patient encntr_id","","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
        m_rec->fax[ml_idx].f_event_id,
        "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->fax[
         ml_idx].s_note_type),"F")
     ENDFOR
    ELSEIF ((m_rec->fax[ml_idx].n_data_ind=1))
     CALL echo("loop through recipients")
     FOR (ml_recip_cnt = 1 TO size(m_rec->fax[ml_idx].recip,5))
      CALL echo(build("recipient: ",ml_recip_cnt))
      IF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_exclude_ind=0)
       AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_fax_nbr_ind=1))
       CALL echo("creating the file to fax")
       SET ms_fin_nbr = ""
       SET ms_filename_prefix = ""
       SET ms_note_filename = ""
       SET ms_fin_nbr = m_rec->fax[ml_idx].s_acct_nbr
       IF (textlen(trim(ms_fin_nbr)) > 0)
        IF (textlen(trim(ms_fin_nbr)) > 9)
         SET ms_fin_nbr = substring(1,9,ms_fin_nbr)
        ENDIF
        SET ms_filename_prefix = trim(format(sysdate,"hh:mm:ss.cc;;d"),3)
        SET ms_filename_prefix = replace(ms_filename_prefix,":","")
        SET ms_filename_prefix = replace(ms_filename_prefix,".","")
        IF (ms_mode="PCP")
         SET ms_filename_prefix = concat("fax1_",substring(4,5,ms_filename_prefix),"_")
        ELSEIF (ms_mode="APC")
         SET ms_filename_prefix = concat("fax3_",substring(4,5,ms_filename_prefix),"_")
        ENDIF
        SET ms_note_filename = concat(ms_filename_prefix,trim(cnvtstring(m_rec->fax[ml_idx].
           f_event_id)),"_",trim(cnvtstring(ml_recip_cnt)),".dat")
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].s_file_name = ms_note_filename
       ELSE
        SET ms_note_filename = concat(ms_filename_prefix,".dat")
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].s_file_name = ms_note_filename
        CALL echo(concat("FIN_NBR not found. File name = ",ms_note_filename))
       ENDIF
       SET d0 = initializereport(0)
       SET becont = 0
       SET ms_powernote_title = m_rec->fax[ml_idx].s_note_title
       SET d0 = coversheet_section(rpt_render)
       SET d0 = pagebreak(1)
       SET d0 = head_section(rpt_render)
       SET d0 = powernote_section(rpt_render,7.75,becont)
       SET ms_powernote_title = concat(m_rec->fax[ml_idx].s_note_title," (continued)")
       WHILE (becont=1)
         SET d0 = pagebreak(1)
         SET d0 = head_section(rpt_render)
         SET d0 = powernote_section(rpt_render,7.75,becont)
       ENDWHILE
       SET d0 = finalizereport(value(concat("bhscust:",ms_note_filename)))
       IF (findfile(concat("bhscust:",ms_note_filename))=1)
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].n_file_found = 1
        SET stat = initrec(fax_reply)
        EXECUTE bhs_sys_send_fax ms_note_filename, trim(cnvtstring(m_rec->fax[ml_idx].recip[
          ml_recip_cnt].f_phys_id)), mf_output_dest_cd,
        trim(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_fax_nbr)
        IF ((fax_reply->status_data.status="S"))
         UPDATE  FROM bhs_physician_fax_list b
          SET b.active_ind = 1
          WHERE (b.person_id=m_rec->fax[ml_idx].f_event_id)
           AND b.name=trim(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name,3)
          WITH nocounter
         ;end update
         COMMIT
        ENDIF
        IF ((fax_reply->status_data.status="F"))
         IF (ms_mode="PCP")
          CALL echo(concat("fax failed, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
            s_phys_name))
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
           m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
           "Fax insert to RRD queue failed",m_rec->fax[ml_idx].recip[ml_recip_cnt].s_file_name,"F")
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
           m_rec->fax[ml_idx].f_person_id,
           "Patient person_id","","F")
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
           m_rec->fax[ml_idx].f_encntr_id,
           "Patient encntr_id","","F")
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
           m_rec->fax[ml_idx].f_event_id,
           "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->
            fax[ml_idx].s_note_type),"F")
         ENDIF
        ELSE
         SET m_rec->fax[ml_idx].recip[ml_recip_cnt].n_fax_stat = 1
         SET ml_sent_cnt = (ml_sent_cnt+ 1)
         CALL echo(concat("log file faxed, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
           s_phys_name))
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
          m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
          concat("Fax Number: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].s_fax_nbr),m_rec->fax[ml_idx].
          recip[ml_recip_cnt].s_file_name,"S")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
          m_rec->fax[ml_idx].f_person_id,
          "Patient person_id","","S")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
          m_rec->fax[ml_idx].f_encntr_id,
          "Patient encntr_id","","S")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
          m_rec->fax[ml_idx].f_event_id,
          "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->
           fax[ml_idx].s_note_type),"S")
        ENDIF
       ELSE
        IF (ms_mode="PCP")
         CALL echo(concat("log file not found, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
           s_phys_name))
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
          m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
          "Fax file not found",concat("Fax Number: ",m_rec->fax[ml_idx].s_pcp_fax_nbr),"F")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
          m_rec->fax[ml_idx].f_person_id,
          "Patient person_id","","F")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
          m_rec->fax[ml_idx].f_encntr_id,
          "Patient encntr_id","","F")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
          m_rec->fax[ml_idx].f_event_id,
          "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->
           fax[ml_idx].s_note_type),"F")
        ENDIF
       ENDIF
      ELSEIF (ms_mode="APC"
       AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind=1))
       CALL echo(concat("fwd note to EN*** CIS Inbox: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
         s_phys_name))
       SET ms_subject = m_rec->fax[ml_idx].s_note_title
       SET ms_body = ms_blob_rtf
       SET stat = initrec(inboxrequest)
       SET stat = alterlist(inboxrequest->message_list,1)
       SET inboxrequest->message_list[1].msg_sender_prsnl_id = m_rec->fax[ml_idx].f_sign_phys_id
       SET inboxrequest->message_list[1].person_id = m_rec->fax[ml_idx].f_person_id
       SET inboxrequest->message_list[1].encntr_id = m_rec->fax[ml_idx].f_encntr_id
       SET inboxrequest->message_list[1].task_type_cd = 2678
       SET inboxrequest->message_list[1].msg_text = ms_body
       SET inboxrequest->message_list[1].msg_subject = ms_subject
       SET inboxrequest->message_list[1].event_id = 0
       SET inboxrequest->message_list[1].priority_cd = mf_routine_cd
       SET stat = alterlist(inboxrequest->message_list[1].assign_prsnl_list,1)
       SET inboxrequest->message_list[1].assign_prsnl_list[1].assign_prsnl_id = m_rec->fax[ml_idx].
       recip[ml_recip_cnt].f_phys_id
       SET inboxreply->status_data[1].status = "S"
       IF ((inboxreply->status_data[1].status="S"))
        SET ml_sent_cnt = (ml_sent_cnt+ 1)
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].n_inbox_stat = 1
        CALL echo(concat("log file emailed, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
          s_phys_name))
        CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
         m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
         "CIS Inbox Msg sent","","S")
        CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
         m_rec->fax[ml_idx].f_person_id,
         "Patient person_id","","S")
        CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
         m_rec->fax[ml_idx].f_encntr_id,
         "Patient encntr_id","","S")
        CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
         m_rec->fax[ml_idx].f_event_id,
         "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->fax[
          ml_idx].s_note_type),"S")
       ELSE
        IF (ms_mode="PCP")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
          m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
          "Failed sending CIS Inbox Msg","","F")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
          m_rec->fax[ml_idx].f_person_id,
          "Patient person_id","","F")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
          m_rec->fax[ml_idx].f_encntr_id,
          "Patient encntr_id","","F")
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
          m_rec->fax[ml_idx].f_event_id,
          "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->
           fax[ml_idx].s_note_type),"F")
        ENDIF
       ENDIF
      ELSEIF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_exclude_ind=1))
       SET ml_sent_cnt = (ml_sent_cnt+ 1)
       CALL echo(concat("log phys excluded, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
         s_phys_name))
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
        m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
        "Fail","Physician exluded from faxing","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
        m_rec->fax[ml_idx].f_person_id,
        "Patient person_id","","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
        m_rec->fax[ml_idx].f_encntr_id,
        "Patient encntr_id","","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
        m_rec->fax[ml_idx].f_event_id,
        "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->fax[
         ml_idx].s_note_type),"F")
      ELSEIF (ms_mode="PCP"
       AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_fax_nbr_ind=0))
       CALL echo(concat("log fax not found, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
         s_phys_name))
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
        m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
        "Fail","No fax number found","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
        m_rec->fax[ml_idx].f_person_id,
        "Patient person_id","","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
        m_rec->fax[ml_idx].f_encntr_id,
        "Patient encntr_id","","F")
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
        m_rec->fax[ml_idx].f_event_id,
        "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->fax[
         ml_idx].s_note_type),"F")
      ELSE
       CALL echo(concat("recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name,
         " does not qualify for fax or fwd"))
      ENDIF
     ENDFOR
    ENDIF
    CALL echo(concat("sent: ",trim(cnvtstring(ml_sent_cnt))," of ",trim(cnvtstring(size(m_rec->fax[
         ml_idx].recip,5)))))
    IF (ml_sent_cnt < size(m_rec->fax[ml_idx].recip,5))
     IF ((m_rec->fax[ml_idx].n_data_ind=1)
      AND ms_mode="APC")
      SET ms_subject = ""
      SET ms_body = ""
      SET ms_subject = m_rec->fax[ml_idx].s_note_title
      SET ms_body =
      "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fs8\fswiss\fcharset0 Arial;}}{"
      SET ms_body = concat(ms_body," Please deliver this note to the following recipient(s):\par")
      FOR (ml_recip_cnt = 1 TO size(m_rec->fax[ml_idx].recip,5))
        IF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_fax_stat=0)
         AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_inbox_stat=0)
         AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_exclude_ind=0))
         SET ms_body = concat(ms_body,char(10),"    ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
          s_phys_name,char(10))
         IF (textlen(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_fax_nbr) > 0
          AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind=0)
          AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_file_found=1))
          SET ms_body = concat(ms_body,"    failed sending fax through RRD:",m_rec->fax[ml_idx].
           recip[ml_recip_cnt].s_fax_nbr,char(10))
         ELSEIF (textlen(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_fax_nbr) > 0
          AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind=0)
          AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_file_found=0))
          SET ms_body = concat(ms_body,"    failed finding file to send to RRD:",m_rec->fax[ml_idx].
           recip[ml_recip_cnt].s_fax_nbr,char(10))
         ELSEIF (textlen(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_fax_nbr)=0
          AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind=0))
          SET ms_body = concat(ms_body,"    no fax number found in system",char(10))
         ELSEIF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind=1))
          SET ms_body = concat(ms_body,"    failed sending CIS inbox message",char(10))
         ELSEIF (textlen(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_username)=0)
          SET ms_body = concat(ms_body,"    recipient not found in the system",char(10))
         ENDIF
         IF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind=1))
          SET ms_body = concat(ms_body,"    *BMP*",char(10))
         ELSE
          SET ms_body = concat(ms_body,"    *NON-BMP*",char(10))
         ENDIF
         SET ms_body = concat(ms_body,"\par")
        ENDIF
      ENDFOR
      SET ms_body = concat(ms_body," \par \pard}} ",ms_blob_rtf)
      SET stat = initrec(inboxrequest)
      SET stat = alterlist(inboxrequest->message_list,1)
      SET inboxrequest->message_list[1].msg_sender_prsnl_id = m_rec->fax[ml_idx].f_sign_phys_id
      SET inboxrequest->message_list[1].person_id = m_rec->fax[ml_idx].f_person_id
      SET inboxrequest->message_list[1].encntr_id = m_rec->fax[ml_idx].f_encntr_id
      SET inboxrequest->message_list[1].task_type_cd = 2678
      SET inboxrequest->message_list[1].msg_text = ms_body
      SET inboxrequest->message_list[1].msg_subject = ms_subject
      SET inboxrequest->message_list[1].event_id = 0
      SET inboxrequest->message_list[1].priority_cd = mf_routine_cd
      SET stat = alterlist(inboxrequest->message_list[1].assign_pool_list,1)
      SET inboxrequest->message_list[1].assign_pool_list[1].assign_pool_id = mf_doc_mgr_pool_id
      CALL echo("sending note to document manager pool")
      IF (mf_doc_mgr_pool_id > 0.0)
       SET reply->status_data[1].status = "S"
      ENDIF
      FOR (ml_recip_cnt = 1 TO size(m_rec->fax[ml_idx].recip,5))
        IF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_fax_stat=0)
         AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_inbox_stat=0)
         AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_exclude_ind=0))
         CALL echo(concat("log docmgr inbox, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
           s_phys_name))
         IF ((inboxreply->status_data[1].status="S"))
          SET ml_sent_cnt = (ml_sent_cnt+ 1)
          SET m_rec->fax[ml_idx].recip[ml_recip_cnt].n_docmgr_stat = 1
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
           0.00,
           "Note sent to Document Manager for delivery",m_rec->fax[ml_idx].recip[ml_recip_cnt].
           s_phys_name,inboxreply->status_data[1].status)
         ELSEIF (mf_doc_mgr_pool_id=0.0)
          SET inboxreply->status_data[1].status = "F"
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
           0.00,
           "CIS Document Manager Pool not found",m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name,
           inboxreply->status_data[1].status)
         ELSE
          SET inboxreply->status_data[1].status = "F"
          CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
           0.00,
           "Failed sending CIS msg to Document Manager",m_rec->fax[ml_idx].recip[ml_recip_cnt].
           s_phys_name,inboxreply->status_data[1].status)
         ENDIF
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"person_id",
          m_rec->fax[ml_idx].f_person_id,
          "Patient person_id","",inboxreply->status_data[1].status)
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"encntr_id",
          m_rec->fax[ml_idx].f_encntr_id,
          "Patient encntr_id","",inboxreply->status_data[1].status)
         CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"event_id",
          m_rec->fax[ml_idx].f_event_id,
          "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->
           fax[ml_idx].s_note_type),inboxreply->status_data[1].status)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   CALL echo("end of loop")
   CALL sbr_upd_dm_info(m_rec->fax[ml_idx].s_qual_dt_tm)
 ENDFOR
 SET reply->status_data[1].status = "S"
 CALL sbr_upd_dm_info(ms_end_dt_tm)
 IF (mc_csv_ind="Y")
  SET ms_csv_filename = concat("bhs_ops_fax_",cnvtlower(ms_mode),trim(format(sysdate,
     "mmddyyhhmmss;;d")),".csv")
  SELECT INTO value(ms_csv_filename)
   FROM (dummyt d1  WITH seq = value(size(m_rec->fax,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->fax[d1.seq].recip,5)))
    JOIN (d2)
   HEAD REPORT
    ms_tmp = concat(
     "recip_name,patient_name,note_type,note_title,fax_nbr,fax_nbr_ind,exclude_ind,fax_stat,inbox_stat,",
     "docmgr_stat,bmp_ind,event_id_type,parent_event_id,event_id,patient_id,encntr_id,admit_dt_tm,fin,mrn,",
     "disch_dt_tm,nurse_unit,facility,",
     "signing_phys,signing_phys_prsnl_id,contr_sys_cd,contr_sys,cep_action_dt_tm,data_ind,note_qual_dt_tm,",
     "recip_username,recip_prsnl_id,log_grp_cnt,fax_file_name,fax_file_found,sort"), col 0, ms_tmp
   DETAIL
    row + 1, ms_tmp = concat('"',trim(m_rec->fax[d1.seq].recip[d2.seq].s_phys_name),'",','"',trim(
      m_rec->fax[d1.seq].s_patient),
     '",','"',trim(m_rec->fax[d1.seq].s_note_type),'",','"',
     trim(m_rec->fax[d1.seq].s_note_title),'",','"',trim(m_rec->fax[d1.seq].recip[d2.seq].s_fax_nbr),
     '",',
     '"',trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].n_fax_nbr_ind)),'",','"',trim(cnvtstring(
       m_rec->fax[d1.seq].recip[d2.seq].n_exclude_ind)),
     '",','"',trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].n_fax_stat)),'",','"',
     trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].n_inbox_stat)),'",','"',trim(cnvtstring(m_rec->
       fax[d1.seq].recip[d2.seq].n_docmgr_stat)),'",',
     '"',trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].n_bmp_phys_ind)),'",','"',trim(m_rec->fax[
      d1.seq].s_sign_par_or_chld),
     '",','"',trim(cnvtstring(m_rec->fax[d1.seq].f_parent_event_id)),'",','"',
     trim(cnvtstring(m_rec->fax[d1.seq].f_event_id)),'",','"',trim(cnvtstring(m_rec->fax[d1.seq].
       f_person_id)),'",',
     '"',trim(cnvtstring(m_rec->fax[d1.seq].f_encntr_id)),'",','"',trim(m_rec->fax[d1.seq].s_admit_dt
      ),
     '",','"',trim(m_rec->fax[d1.seq].s_acct_nbr),'",','"',
     trim(m_rec->fax[d1.seq].s_mrn_nbr),'",','"',trim(m_rec->fax[d1.seq].s_disch_dt),'",',
     '"',trim(m_rec->fax[d1.seq].s_nurse_unit),'",','"',trim(m_rec->fax[d1.seq].s_facility),
     '",','"',trim(m_rec->fax[d1.seq].s_sign_phys_name),'",','"',
     trim(cnvtstring(m_rec->fax[d1.seq].f_sign_phys_id)),'",','"',trim(cnvtstring(m_rec->fax[d1.seq].
       f_contr_sys_cd)),'",',
     '"',trim(m_rec->fax[d1.seq].s_contr_sys),'",','"',trim(m_rec->fax[d1.seq].s_cep_action_dt_tm),
     '",','"',trim(cnvtstring(m_rec->fax[d1.seq].n_data_ind)),'",','"',
     trim(m_rec->fax[d1.seq].s_qual_dt_tm),'",','"',trim(m_rec->fax[d1.seq].recip[d2.seq].
      s_phys_username),'",',
     '"',trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].f_phys_id)),'",','"',trim(cnvtstring(m_rec
       ->fax[d1.seq].recip[d2.seq].l_log_grp_cnt)),
     '",','"',trim(m_rec->fax[d1.seq].recip[d2.seq].s_file_name),'",','"',
     trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].n_file_found)),'",','"',trim(cnvtstring(m_rec->
       fax[d1.seq].l_sort)),'"'), col 0,
    ms_tmp
   WITH nocounter, maxcol = 2000, maxrow = 1
  ;end select
  IF (curqual > 0)
   CALL bhs_sbr_log("log","",0,concat("BHS_OPS_FAX_POWERNOTES_",ms_mode),0.0,
    "",concat("CSV file generated: ",ms_csv_filename),"R")
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat(ms_mode," BHS_OPS_FAX_POWERNOTES ",ms_beg_dt_tm," - ",ms_end_dt_tm)
   CALL emailfile(value(ms_csv_filename),ms_csv_filename,ms_recipients,ms_tmp,1)
  ELSE
   CALL uar_send_mail(nullterm(ms_recipients),nullterm(concat(ms_mode," NOTES FAXING OPS ",trim(
       format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(concat(ms_mode,
      " - No notes found for this job")),nullterm(curnode),1,
    nullterm("IPM.NOTE"))
  ENDIF
 ENDIF
 GO TO exit_script
#send_page
 CALL echo("send page")
 IF (mn_test=1)
  CALL echo("don't forget to put the goto back in")
  GO TO exit_script
 ENDIF
 SET ms_tmp = concat("*** ",ms_mode," BHS_OPS_FAX_POWERNOTES FAILURE ",curnode," ***",
  char(13),"Job Name: Notes Faxing ",ms_mode,char(13),"Job Date: ",
  trim(format(sysdate,"mm/dd/yy hh:mm;;d")),char(13),"Error: ",ms_msg,char(13),
  char(13),"Manual Run: ExpMenu->Main->CIS Core Programs->Notes Faxing Job",char(13))
 IF (ms_msg="001*")
  SET ms_tmp = concat(ms_tmp,
   "Please ensure that the DM_INFO row for BHS_OPS_FAX_POWERNOTES has been inserted",char(13),
   "and dm_info.info_dt_tm has been set appropriately.",char(13),
   char(13))
  SET ms_tmp = concat(ms_tmp,"Once the appropriate start_dt_tm for this job has been determined, ",
   "use the following command to insert the dm_info_row:",char(13),char(13),
   "   insert into dm_info d",char(13),"   set",char(13),
   "     d.info_domain = 'BHS_OPS_FAX_POWERNOTES',",
   char(13),"     d.info_name = '",ms_mode,"_STOP_DT_TM',",char(13),
   "     d.info_date = <date_tm>,",char(13),"     d.updt_dt_tm = sysdate,",char(13),
   "     d.updt_id = reqinfo->updt_id",
   char(13),"   with nocounter go commit go")
 ELSEIF (ms_msg="002*")
  SET ms_tmp = concat(ms_tmp,
   "The time gap since the last BHS_OPS_FAX_POWERNOTES job ended is greater than ",ms_max_hrs,
   " hrs for ",ms_mode,
   ".",char(13),"Please run the jobs manually in increments of ",ms_job_hrs,
   " hrs to cover the time gap.",
   char(13),
   "Once complete, update the dm_info.info_dt_tm to an appropriate time to begin the ops job.",char(
    13),char(13))
  SET ms_tmp = concat(ms_tmp,"Once the appropriate start_dt_tm for this job has been determined, ",
   "use the following command to update the dm_info_row:",char(13),char(13),
   "   update into dm_info d",char(13),"   set",char(13),"     d.info_date = <date_tm>,",
   char(13),"     d.updt_dt_tm = sysdate,",char(13),"     d.updt_id = reqinfo->updt_id",char(13),
   "   where d.info_domain = 'BHS_OPS_FAX_POWERNOTES'",char(13),"     and d.info_name = '",
   ms_dm_info_name,"'",
   char(13),"   with nocounter go commit go")
 ENDIF
 CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat(ms_mode," NOTES FAXING OPS FAIL ",
    trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_tmp),nullterm(concat(ms_mode,
    "NOTES FAXING OPS JOB ",curnode)),1,
  nullterm("IPM.NOTE"))
#exit_script
 CALL bhs_sbr_log("stop","",0,"",0.0,
  concat(trim(cnvtstring(size(m_rec->fax,5)))," notes found to fax"),ms_msg,reply->status_data[1].
  status)
 IF (mn_ops=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat("BHS_OPS_FAX_POWERNOTES executed for range ",ms_beg_dt_tm," to ",ms_end_dt_tm),
    col 0, ms_tmp
    IF ((reply->status_data[1].status="F"))
     col 0, row + 1, "Job Failed"
    ELSE
     col 0, row + 1, "Job Succeeded"
    ENDIF
    col 0, row + 2, ms_msg
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE sbr_get_fax_nbrs(ml_rec_idx)
   DECLARE ms_tmp_phone = vc WITH protect, noconstant(" ")
   DECLARE ms_area = vc WITH protect, noconstant(" ")
   DECLARE ms_prefix = vc WITH protect, noconstant(" ")
   DECLARE ms_suffix = vc WITH protect, noconstant(" ")
   DECLARE ms_adj_nbr = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(m_rec->fax[ml_rec_idx].recip,5))),
     bhs_physician_fax_list b
    PLAN (d
     WHERE (m_rec->fax[ml_rec_idx].recip[d.seq].n_fax_nbr_ind=0)
      AND (m_rec->fax[ml_rec_idx].recip[d.seq].n_bmp_phys_ind=0))
     JOIN (b
     WHERE (b.person_id=m_rec->fax[ml_rec_idx].f_event_id)
      AND b.name=trim(m_rec->fax[ml_rec_idx].recip[d.seq].s_phys_name,3))
    HEAD REPORT
     pl_len = 0
    DETAIL
     ms_tmp_phone = "", ms_area = "", ms_prefix = "",
     ms_suffix = "", ms_adj_nbr = "", ms_tmp_phone = trim(b.fax),
     ms_tmp_phone = replace(ms_tmp_phone,".",""), ms_tmp_phone = replace(ms_tmp_phone,",",""),
     ms_tmp_phone = replace(ms_tmp_phone,"'",""),
     ms_tmp_phone = replace(ms_tmp_phone,'"',""), ms_tmp_phone = replace(ms_tmp_phone,"(",""),
     ms_tmp_phone = replace(ms_tmp_phone,")",""),
     ms_tmp_phone = replace(ms_tmp_phone,"[",""), ms_tmp_phone = replace(ms_tmp_phone,"]",""),
     ms_tmp_phone = replace(ms_tmp_phone,"-",""),
     ms_tmp_phone = replace(ms_tmp_phone,"_",""), ms_tmp_phone = replace(ms_tmp_phone," ","")
     WHILE (substring(1,1,ms_tmp_phone)="0")
       ms_tmp_phone = trim(substring(2,textlen(ms_tmp_phone),ms_tmp_phone))
     ENDWHILE
     pl_len = textlen(ms_tmp_phone)
     IF (pl_len > 10)
      WHILE (pl_len > 10)
       ms_tmp_phone = trim(substring(2,textlen(ms_tmp_phone),ms_tmp_phone)),pl_len = textlen(
        ms_tmp_phone)
      ENDWHILE
     ENDIF
     IF (pl_len=10)
      ms_area = substring(1,3,ms_tmp_phone), ms_prefix = substring(4,3,ms_tmp_phone), ms_suffix =
      substring(7,4,ms_tmp_phone)
     ELSEIF (pl_len=7)
      ms_area = "413", ms_prefix = substring(1,3,ms_tmp_phone), ms_suffix = substring(4,4,
       ms_tmp_phone)
     ELSE
      CALL echo("number invalid")
     ENDIF
     IF (ms_area="413"
      AND ms_prefix IN ("204", "205", "206", "209", "210",
     "214", "218", "219", "221", "222",
     "224", "226", "231", "233", "234",
     "237", "240", "241", "244", "246",
     "250", "257", "261", "262", "263",
     "264", "265", "266", "271", "272",
     "273", "275", "276", "279", "285",
     "286", "288", "290", "292", "293",
     "294", "295", "297", "301", "302",
     "304", "306", "308", "309", "313",
     "314", "315", "317", "318", "322",
     "328", "330", "331", "335", "342",
     "348", "351", "355", "356", "363",
     "364", "366", "372", "374", "375",
     "377", "378", "382", "384", "385",
     "386", "388", "391", "420", "425",
     "426", "427", "431", "433", "437",
     "438", "439", "451", "452", "454",
     "455", "459", "474", "478", "480",
     "485", "486", "493", "495", "504",
     "505", "509", "513", "519", "523",
     "525", "526", "530", "531", "532",
     "533", "534", "535", "536", "537",
     "538", "539", "540", "543", "547",
     "552", "557", "561", "562", "563",
     "564", "565", "566", "567", "568",
     "569", "572", "575", "579", "583",
     "589", "592", "593", "594", "595",
     "596", "598", "599", "610", "612",
     "626", "627", "631", "636", "639",
     "642", "647", "650", "654", "657",
     "675", "682", "683", "686", "693",
     "726", "729", "730", "731", "732",
     "733", "734", "735", "736", "737",
     "739", "744", "746", "747", "748",
     "750", "754", "755", "759", "777",
     "781", "782", "783", "784", "785",
     "786", "787", "788", "789", "794",
     "796", "798", "799", "814", "821",
     "827", "831", "832", "846", "847",
     "858", "861", "875", "883", "885",
     "886", "887", "888", "896", "920",
     "935", "949", "977", "995", "998"))
      ms_adj_nbr = concat(ms_prefix,ms_suffix)
     ELSE
      ms_adj_nbr = concat("1",ms_area,ms_prefix,ms_suffix)
     ENDIF
     m_rec->fax[ml_rec_idx].recip[d.seq].s_fax_nbr = ms_adj_nbr, m_rec->fax[ml_rec_idx].recip[d.seq].
     n_fax_nbr_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE sbr_upd_dm_info(ms_stop_dt_tm)
   IF (mn_ops=1)
    UPDATE  FROM dm_info d
     SET d.info_date = cnvtlookahead("1,S",cnvtdatetime(ms_stop_dt_tm)), d.updt_dt_tm = sysdate, d
      .updt_id = reqinfo->updt_id
     WHERE d.info_domain="BHS_OPS_FAX_POWERNOTES"
      AND d.info_name=ms_dm_info_name
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 END ;Subroutine
 IF (mn_test=1)
  CALL echorecord(m_rec)
 ENDIF
 FREE RECORD m_rec
END GO
