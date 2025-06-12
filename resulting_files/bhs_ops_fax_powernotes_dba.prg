CREATE PROGRAM bhs_ops_fax_powernotes:dba
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
 EXECUTE bhs_check_domain:dba
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
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
 DECLARE _rptpage = h WITH noconstant(0), protect
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
 SUBROUTINE (coversheet_section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = coversheet_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (coversheet_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(3.750000), private
   DECLARE __fax_dt_tm = vc WITH noconstant(build2(build(format(cnvtdatetime(sysdate),
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
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fax_dt_tm)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_powernote_title,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phys Name:",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fax date/time:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.751
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 1.750
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat("Confidentiality Note:",_crlf,
       "This facsimile transmittal may contain confidential patient medical record information and is intended only for ",
       "the use of the entity to which it is addressed. If the reader of this transmittal is not the intended recipient,",
       " or the employee or agent responsible for delivering the transmittal to the intended recipient, you are hereby n",
       "otified that any dissemination, distribution or copying of this communication is strictly prohibited. If you hav",
       "e received this communication in error, please notify us immediately by telephone at 413-322-4325. Thank you."
       ),char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (head_section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.630000), private
   DECLARE __fax_dt_tm = vc WITH noconstant(build2(build(format(cnvtdatetime(sysdate),
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
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fax_dt_tm)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_powernote_title,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phys Name:",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fax date/time:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.751
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Disch Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__disch_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__location)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (powernote_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = powernote_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (powernote_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_phydischsumlbl = f8 WITH noconstant(0.0), private
   DECLARE __phydischsumlbl = vc WITH noconstant(build2(ms_blob_rtf,char(0))), protect
   IF (bcontinue=0)
    SET _remphydischsumlbl = 1
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET _oldfont = uar_rptsetfont(_hreport,_times120)
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
   SET growsum += _remphydischsumlbl
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
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
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_OPS_FAX_POWERNOTES"
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
   SET rptreport->m_needsnotonaskharabic = 0
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
     2 f_contr_sys_cd = f8
     2 s_contr_sys = vc
     2 s_cep_action_dt_tm = vc
     2 n_data_ind = i2
     2 s_qual_dt_tm = vc
     2 l_sort = i4
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
 DECLARE ms_mode_in = vc WITH protect, constant(trim(cnvtupper( $S_MODE)))
 DECLARE ms_mode = vc WITH protect, constant(trim(cnvtupper(substring(1,3, $S_MODE))))
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
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_ops_fax_powernotes/"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant( $S_BEG_DT_TM)
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant( $S_END_DT_TM)
 DECLARE ms_apc_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_apc_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant( $S_CSV_RECIPIENT)
 DECLARE mf_doc_mgr_pool_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_note_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_csv_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_xml_filename = vc WITH protect, noconstant(" ")
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
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_beg = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ml_mid = i4 WITH protect, noconstant(0)
 DECLARE ml_obrac = i4 WITH protect, noconstant(0)
 DECLARE ml_obrac_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_safety_cnt = i4 WITH protect, noconstant(0)
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
  "","Begin Script","")
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
  ENDIF
 ENDIF
 IF (mc_csv_ind="Y"
  AND mn_ops=0
  AND ms_recipients != "FTP")
  IF (((findstring("@",ms_recipients)=0) OR (textlen(ms_recipients)=0)) )
   SET ms_msg = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
 ELSEIF (mc_csv_ind="Y"
  AND mn_ops=1)
  IF (findstring("@",ms_recipients)=0)
   SET ms_recipients = "FTP"
  ENDIF
 ENDIF
 SET ms_csv_filename = concat(ms_loc_dir,"bhs_ops_fax_",cnvtlower(ms_mode),trim(format(sysdate,
    "mmddyyhhmmss;;d")),".csv")
 SET ms_xml_filename = concat(ms_loc_dir,"bhs_ops_fax_",cnvtlower(ms_mode),trim(format(sysdate,
    "mmddyyhhmmss;;d")),".xml")
 IF (findstring("TEST",ms_mode_in) > 0)
  SET mn_test = 1
  CALL echo(concat("Test mode set: mn_test = ",trim(cnvtstring(mn_test))))
 ENDIF
 IF (ms_mode="PCP")
  IF (mn_test=0)
   SET ms_dclcom_str = concat(
    "find $bhscust \( ! -name $(basename $bhscust) -type d -prune \) -o -mtime +7 -name ",
    '"fax1_*.dat" -type f -exec rm -rf {} \;')
  ELSE
   SET ms_dclcom_str = concat(
    "find $bhscust \( ! -name $(basename $bhscust) -type d -prune \) -o -mtime +7 -name ",
    '"fax1t_*.dat" -type f -exec rm -rf {} \;')
  ENDIF
 ELSEIF (ms_mode="APC")
  IF (mn_test=0)
   SET ms_dclcom_str = concat(
    "find $bhscust \( ! -name $(basename $bhscust) -type d -prune \) -o -mtime +7 -name ",
    '"fax2_*.dat" -type f -exec rm -rf {} \;')
  ELSE
   SET ms_dclcom_str = concat(
    "find $bhscust \( ! -name $(basename $bhscust) -type d -prune \) -o -mtime +7 -name ",
    '"fax2t_*.dat" -type f -exec rm -rf {} \;')
  ENDIF
 ENDIF
 SET len = textlen(trim(ms_dclcom_str))
 SET status = 0
 CALL dcl(ms_dclcom_str,len,status)
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
 ELSEIF (mn_test=1)
  SET mf_output_dest_cd = 0.0
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
   pl_cnt += 1
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
  CALL echo("PCP - find qualifying notes")
  CALL echo("get non-urgent care notes first")
  SELECT INTO "nl:"
   FROM scr_pattern s
   WHERE s.display_key=ms_urgnote_disp_key
   HEAD s.display_key
    mf_urgentcare_id = s.scr_pattern_id
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   pf_story_id = s.scd_story_id, p.person_id, ps_title = substring(1,40,trim(s.title)),
   cep.action_prsnl_id, s.event_id
   FROM encntr_domain ed,
    encounter e,
    scd_story s,
    scd_story_pattern ssp,
    scr_pattern srp,
    ce_event_prsnl cep,
    prsnl pr1,
    person p,
    encntr_prsnl_reltn epr,
    prsnl pr2,
    ce_blob cb
   PLAN (ed
    WHERE ed.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ed.encntr_id
     AND e.encntr_status_cd=mf_discharged_cd
     AND e.disch_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
    JOIN (s
    WHERE s.encounter_id=e.encntr_id
     AND s.story_completion_status_cd=mf_story_sign_cd)
    JOIN (ssp
    WHERE ssp.scd_story_id=s.scd_story_id
     AND ssp.scr_pattern_id IN (
    (SELECT
     b.event_cd
     FROM bhs_event_cd_list b
     WHERE b.grouper=ms_mode
      AND b.listkey="NOTES FAXING"
      AND b.active_ind=1
      AND b.event_cd != mf_urgentcare_id)))
    JOIN (srp
    WHERE srp.scr_pattern_id=ssp.scr_pattern_id
     AND srp.active_status_cd=mf_active_cd)
    JOIN (cep
    WHERE cep.event_id=s.event_id
     AND cep.valid_until_dt_tm > sysdate
     AND cep.action_type_cd=mf_sign_cd
     AND cep.action_status_cd=mf_completed_cd)
    JOIN (pr1
    WHERE pr1.person_id=cep.action_prsnl_id
     AND pr1.physician_ind=1)
    JOIN (p
    WHERE p.person_id=s.person_id
     AND p.active_ind=1)
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.end_effective_dt_tm > sysdate
     AND epr.encntr_prsnl_r_cd=mf_pcp_cd)
    JOIN (pr2
    WHERE pr2.person_id=epr.prsnl_person_id
     AND pr2.physician_ind=1
     AND  NOT (pr2.username IN ("EN*", "SPNDEN*", "SI*"))
     AND pr2.active_ind=1)
    JOIN (cb
    WHERE cb.event_id=s.event_id
     AND cb.valid_until_dt_tm > sysdate)
   ORDER BY p.person_id, ps_title, cep.action_dt_tm DESC
   HEAD REPORT
    pl_cnt = 0
   HEAD cep.event_id
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->fax,5))
     stat = alterlist(m_rec->fax,(pl_cnt+ 25))
    ENDIF
    m_rec->fax[pl_cnt].s_patient = trim(p.name_full_formatted), m_rec->fax[pl_cnt].f_person_id = p
    .person_id, m_rec->fax[pl_cnt].f_encntr_id = e.encntr_id,
    m_rec->fax[pl_cnt].s_note_type = trim(srp.display_key), m_rec->fax[pl_cnt].s_admit_dt = trim(
     format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;d")), m_rec->fax[pl_cnt].s_disch_dt = trim(format(e
      .disch_dt_tm,"MM/DD/YYYY HH:MM")),
    m_rec->fax[pl_cnt].f_event_id = s.event_id, m_rec->fax[pl_cnt].f_sign_phys_id = cep
    .action_prsnl_id, m_rec->fax[pl_cnt].s_sign_phys_name = trim(pr1.name_full_formatted),
    m_rec->fax[pl_cnt].s_note_title = ps_title, m_rec->fax[pl_cnt].s_cep_action_dt_tm = trim(format(
      cep.action_dt_tm,"MM/DD/YYYY HH:MM:SS")), m_rec->fax[pl_cnt].s_nurse_unit = trim(
     uar_get_code_display(e.loc_nurse_unit_cd)),
    m_rec->fax[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->fax[pl_cnt]
    .s_qual_dt_tm = trim(format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D")), m_rec->fax[pl_cnt].
    s_contr_sys = "POWERCHART",
    stat = alterlist(m_rec->fax[pl_cnt].recip,1), ml_log_grp_cnt += 1, m_rec->fax[pl_cnt].recip[1].
    l_log_grp_cnt = ml_log_grp_cnt,
    m_rec->fax[pl_cnt].recip[1].f_phys_id = pr2.person_id, m_rec->fax[pl_cnt].recip[1].s_phys_name =
    trim(pr2.name_full_formatted), m_rec->fax[pl_cnt].recip[1].s_phys_username = pr2.username,
    ms_tmp = concat("storyid: ",trim(cnvtstring(s.scd_story_id))," sign date: ",trim(format(cep
       .action_dt_tm,"mm/dd/yy hh:mm;;d"))," disch: ",
     m_rec->fax[pl_cnt].s_disch_dt)
   FOOT REPORT
    stat = alterlist(m_rec->fax,pl_cnt)
   WITH nocounter
  ;end select
  IF (mf_urgentcare_id > 0.0)
   CALL echo("get urgent care notes")
   SELECT DISTINCT INTO "nl:"
    pf_story_id = s.scd_story_id, p.person_id, ps_title = substring(1,40,trim(s.title)),
    cep.action_prsnl_id, s.event_id
    FROM encntr_domain ed,
     scr_pattern srp,
     scd_story_pattern ssp,
     scd_story s,
     encounter e,
     ce_event_prsnl cep,
     prsnl pr1,
     person p,
     encntr_prsnl_reltn epr,
     prsnl pr2,
     ce_blob cb
    PLAN (ed
     WHERE ed.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=ed.encntr_id
      AND e.active_ind=1)
     JOIN (s
     WHERE s.encounter_id=e.encntr_id
      AND s.story_completion_status_cd=mf_story_sign_cd)
     JOIN (ssp
     WHERE ssp.scd_story_id=s.scd_story_id
      AND ssp.scr_pattern_id=mf_urgentcare_id)
     JOIN (srp
     WHERE srp.scr_pattern_id=ssp.scr_pattern_id
      AND srp.active_status_cd=mf_active_cd)
     JOIN (cep
     WHERE cep.event_id=s.event_id
      AND cep.valid_until_dt_tm > sysdate
      AND cep.action_type_cd=mf_sign_cd
      AND cep.action_status_cd=mf_completed_cd
      AND cep.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
     JOIN (pr1
     WHERE pr1.person_id=cep.action_prsnl_id
      AND pr1.physician_ind=1)
     JOIN (p
     WHERE p.person_id=s.person_id
      AND p.active_ind=1)
     JOIN (epr
     WHERE epr.encntr_id=e.encntr_id
      AND epr.end_effective_dt_tm > sysdate
      AND epr.encntr_prsnl_r_cd=mf_pcp_cd)
     JOIN (pr2
     WHERE pr2.person_id=epr.prsnl_person_id
      AND pr2.physician_ind=1
      AND  NOT (pr2.username IN ("EN*", "SPNDEN*", "SI*"))
      AND pr2.active_ind=1)
     JOIN (cb
     WHERE cb.event_id=s.event_id
      AND cb.valid_until_dt_tm > sysdate)
    ORDER BY p.person_id, ps_title, cep.action_dt_tm DESC
    HEAD REPORT
     pl_cnt = size(m_rec->fax,5)
    HEAD cep.event_id
     pl_cnt += 1
     IF (pl_cnt > size(m_rec->fax,5))
      stat = alterlist(m_rec->fax,(pl_cnt+ 25))
     ENDIF
     m_rec->fax[pl_cnt].s_patient = trim(p.name_full_formatted), m_rec->fax[pl_cnt].f_person_id = p
     .person_id, m_rec->fax[pl_cnt].f_encntr_id = e.encntr_id,
     m_rec->fax[pl_cnt].s_note_type = trim(srp.display_key), m_rec->fax[pl_cnt].s_admit_dt = trim(
      format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;d")), m_rec->fax[pl_cnt].s_disch_dt = trim(format(e
       .disch_dt_tm,"MM/DD/YYYY HH:MM;;d")),
     m_rec->fax[pl_cnt].f_event_id = s.event_id, m_rec->fax[pl_cnt].f_sign_phys_id = cep
     .action_prsnl_id, m_rec->fax[pl_cnt].s_sign_phys_name = trim(pr1.name_full_formatted),
     m_rec->fax[pl_cnt].s_note_title = ps_title, m_rec->fax[pl_cnt].s_cep_action_dt_tm = trim(format(
       cep.action_dt_tm,"MM/DD/YYYY HH:MM:SS;;d")), m_rec->fax[pl_cnt].s_nurse_unit = trim(
      uar_get_code_display(e.loc_nurse_unit_cd)),
     m_rec->fax[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->fax[pl_cnt
     ].s_qual_dt_tm = trim(format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;D")), m_rec->fax[pl_cnt].
     s_contr_sys = "POWERCHART",
     stat = alterlist(m_rec->fax[pl_cnt].recip,1), ml_log_grp_cnt += 1, m_rec->fax[pl_cnt].recip[1].
     l_log_grp_cnt = ml_log_grp_cnt,
     m_rec->fax[pl_cnt].recip[1].f_phys_id = pr2.person_id, m_rec->fax[pl_cnt].recip[1].s_phys_name
      = trim(pr2.name_full_formatted), m_rec->fax[pl_cnt].recip[1].s_phys_username = pr2.username,
     ms_tmp = concat("storyid: ",trim(cnvtstring(s.scd_story_id))," sign date: ",trim(format(cep
        .action_dt_tm,"mm/dd/yy hh:mm;;d"))," disch: ",
      m_rec->fax[pl_cnt].s_disch_dt)
    FOOT REPORT
     stat = alterlist(m_rec->fax,pl_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (ms_mode="APC")
  CALL echo("APC - find qualifying notes")
  SELECT DISTINCT INTO "nl:"
   pf_story_id = s.scd_story_id, p.person_id, ps_title = substring(1,40,trim(s.title)),
   ps_phys_action = uar_get_code_display(cep.action_status_cd), cep.action_prsnl_id, s.event_id
   FROM encntr_domain ed,
    encounter e,
    scr_pattern srp,
    scd_story_pattern ssp,
    scd_story s,
    ce_event_prsnl cep,
    prsnl pr1,
    person p,
    ce_blob cb
   PLAN (ed
    WHERE ed.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ed.encntr_id
     AND e.active_ind=1)
    JOIN (s
    WHERE s.encounter_id=e.encntr_id
     AND s.story_completion_status_cd=mf_story_sign_cd)
    JOIN (ssp
    WHERE ssp.scd_story_id=s.scd_story_id
     AND ssp.scr_pattern_id IN (
    (SELECT
     b.event_cd
     FROM bhs_event_cd_list b
     WHERE b.grouper=ms_mode
      AND b.listkey="NOTES FAXING"
      AND b.active_ind=1)))
    JOIN (srp
    WHERE srp.scr_pattern_id=ssp.scr_pattern_id
     AND srp.active_status_cd=mf_active_cd)
    JOIN (cep
    WHERE cep.event_id=s.event_id
     AND cep.valid_until_dt_tm >= cnvtdatetime(ms_apc_beg_dt_tm)
     AND cep.action_type_cd=mf_sign_cd
     AND cep.action_status_cd=mf_completed_cd
     AND cep.action_dt_tm BETWEEN cnvtdatetime(ms_apc_beg_dt_tm) AND cnvtdatetime(ms_apc_end_dt_tm))
    JOIN (pr1
    WHERE pr1.person_id=cep.action_prsnl_id
     AND  NOT (expand(ml_idx,1,size(m_rec->res,5),pr1.position_cd,m_rec->res[ml_idx].f_pos_cd)))
    JOIN (p
    WHERE p.person_id=s.person_id
     AND p.active_ind=1)
    JOIN (cb
    WHERE cb.event_id=s.event_id
     AND cb.valid_until_dt_tm > sysdate)
   ORDER BY p.person_id, ps_title, cep.action_dt_tm DESC
   HEAD REPORT
    pl_cnt = 0
   HEAD cep.event_id
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->fax,5))
     stat = alterlist(m_rec->fax,(pl_cnt+ 25))
    ENDIF
    m_rec->fax[pl_cnt].s_patient = trim(p.name_full_formatted), m_rec->fax[pl_cnt].f_person_id = p
    .person_id, m_rec->fax[pl_cnt].f_encntr_id = e.encntr_id,
    m_rec->fax[pl_cnt].s_note_type = trim(srp.display_key), m_rec->fax[pl_cnt].s_admit_dt = trim(
     format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;d")), m_rec->fax[pl_cnt].s_disch_dt = trim(format(e
      .disch_dt_tm,"MM/DD/YYYY HH:MM;;d")),
    m_rec->fax[pl_cnt].f_event_id = s.event_id, m_rec->fax[pl_cnt].f_sign_phys_id = cep
    .action_prsnl_id, m_rec->fax[pl_cnt].s_sign_phys_name = trim(pr1.name_full_formatted),
    m_rec->fax[pl_cnt].s_note_title = ps_title, m_rec->fax[pl_cnt].s_cep_action_dt_tm = trim(format(
      cep.action_dt_tm,"MM/DD/YYYY HH:MM:SS;;d")), m_rec->fax[pl_cnt].s_nurse_unit = trim(
     uar_get_code_display(e.loc_nurse_unit_cd)),
    m_rec->fax[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->fax[pl_cnt]
    .s_qual_dt_tm = trim(format(cnvtlookahead(ms_look_interval,cep.action_dt_tm),
      "dd-mmm-yyyy hh:mm:ss;;D")), m_rec->fax[pl_cnt].s_contr_sys = "POWERCHART",
    ms_tmp = concat("storyid: ",trim(cnvtstring(s.scd_story_id))," sign date: ",trim(format(cep
       .action_dt_tm,"mm/dd/yy hh:mm;;d"))," disch: ",
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
  IF (ms_recipients="FTP")
   SELECT INTO value(ms_csv_filename)
    FROM dummyt d
    HEAD REPORT
     col 0, "no data found"
    WITH nocounter
   ;end select
  ELSE
   CALL uar_send_mail(nullterm(ms_recipients),nullterm(concat(ms_mode," NOTES FAXING OPS ",trim(
       format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(concat(ms_mode,
      " - No notes found for this job")),nullterm(curnode),1,
    nullterm("IPM.NOTE"))
  ENDIF
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
   WHERE (ea2.encntr_id= Outerjoin(m_rec->fax[d.seq].f_encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_nbr_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(cnvtdatetime(ms_beg_dt_tm))) )
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
   pl_cnt += 1, m_rec->fax[d.seq].l_sort = pl_cnt
  WITH nocounter
 ;end select
 FOR (ml_cnt = 1 TO size(m_rec->fax,5))
   SET ml_idx = locateval(ml_num,1,size(m_rec->fax,5),ml_cnt,m_rec->fax[ml_num].l_sort)
   CALL echo(build(ml_cnt," of ",size(m_rec->fax,5)," idx: ",ml_idx,
     " eventid: ",m_rec->fax[ml_idx].f_event_id))
   SET ml_sent_cnt = 0
   SET ms_blob_rtf = ""
   CALL echo("select blob")
   CALL echo(concat("fin: ",m_rec->fax[ml_idx].s_acct_nbr))
   SET ms_blob_rtf = bhs_sbr_get_blob(m_rec->fax[ml_idx].f_event_id,0)
   SET ms_blob = bhs_sbr_get_blob(m_rec->fax[ml_idx].f_event_id,1)
   SET ml_recip_cnt = 0
   SET ml_loc = 0
   SET ml_beg = 0
   SET ml_end = 0
   SET ml_mid = 0
   SET ml_obrac = 0
   SET ml_obrac_cnt = 0
   SET ml_loop_cnt = 0
   SET ml_beg = 0
   SET ml_loc = 0
   IF (textlen(trim(ms_blob)) > 0)
    IF (ms_mode="APC"
     AND (m_rec->fax[ml_idx].f_contr_sys_cd != mf_nuance_cd))
     CALL echo("get the recipients out of the file")
     SET ml_beg = findstring("Report sent to all consultants:",ms_blob,1)
     IF (ml_beg > 0)
      SET ml_beg = (findstring(":",ms_blob,ml_beg)+ 1)
     ENDIF
     WHILE (ml_beg > 0)
       SET ml_loop_cnt += 1
       SET ml_mid = findstring(",",ms_blob,ml_beg)
       SET ml_end = findstring(".",ms_blob,ml_beg)
       SET ms_tmp = trim(substring(ml_beg,(ml_end - ml_beg),ms_blob),3)
       IF (locateval(ml_loc,1,size(m_rec->fax[ml_idx].recip,5),ms_tmp,m_rec->fax[ml_idx].recip[ml_loc
        ].s_phys_name)=0)
        SET ml_recip_cnt += 1
        CALL alterlist(m_rec->fax[ml_idx].recip,ml_recip_cnt)
        SET ml_log_grp_cnt += 1
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt = ml_log_grp_cnt
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name = ms_tmp
       ENDIF
       SET ml_beg = findstring("Report sent to all consultants:",ms_blob,ml_end)
       IF (ml_beg > 0)
        SET ml_beg = (findstring(":",ms_blob,ml_beg)+ 1)
       ENDIF
       IF (ml_loop_cnt > 50)
        SET ml_beg = 0
       ENDIF
     ENDWHILE
    ELSEIF (ms_mode="APC"
     AND (m_rec->fax[ml_idx].f_contr_sys_cd=mf_nuance_cd))
     CALL echo("get the recipients out of the file - Nuance")
     SET ml_beg = findstring("CC:",ms_blob_rtf,1,1)
     IF (ml_beg > 0)
      SET ml_beg = (findstring(":",ms_blob_rtf,ml_beg)+ 1)
      SET ms_cc_rtf = substring(ml_beg,textlen(ms_blob_rtf),ms_blob_rtf)
      SET ml_beg = 1
     ENDIF
     WHILE (ml_beg > 0)
       SET ml_loop_cnt += 1
       SET ml_end = findstring(concat(char(92),"par"),ms_cc_rtf,ml_beg)
       IF (ml_end > 0)
        SET ms_tmp = trim(substring(ml_beg,(ml_end - ml_beg),ms_cc_rtf))
        SET ml_beg = findstring("{",ms_tmp,1,1)
        SET ms_tmp = substring((ml_beg+ 1),textlen(ms_tmp),ms_tmp)
        SET ms_tmp = replace(ms_tmp,".","")
        SET ml_mid = findstring(" ",ms_tmp,1)
        IF (ml_mid > 0)
         SET ms_firstname = substring(1,(ml_mid - 1),ms_tmp)
         SET ms_lastname = substring((ml_mid+ 1),textlen(ms_tmp),ms_tmp)
         SET ms_tmp = concat(ms_lastname,",",ms_firstname)
         IF (locateval(ml_loc,1,size(m_rec->fax[ml_idx].recip,5),ms_tmp,m_rec->fax[ml_idx].recip[
          ml_loc].s_phys_name)=0)
          SET ml_recip_cnt += 1
          CALL alterlist(m_rec->fax[ml_idx].recip,ml_recip_cnt)
          SET ml_log_grp_cnt += 1
          SET m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt = ml_log_grp_cnt
          SET m_rec->fax[ml_idx].recip[ml_recip_cnt].s_phys_name = ms_tmp
         ENDIF
        ENDIF
       ENDIF
       IF (ml_end > 0)
        SET ml_beg = findstring(concat(char(92),"par",char(92),"par"),ms_cc_rtf,ml_end)
       ELSE
        SET ml_beg = 0
       ENDIF
       IF (ml_beg > 0)
        SET ml_beg = (findstring(" ",ms_cc_rtf,ml_beg)+ 1)
       ENDIF
       IF (ml_loop_cnt > 50)
        SET ml_beg = - (1)
       ENDIF
     ENDWHILE
    ENDIF
    IF (size(m_rec->fax[ml_idx].recip,5) > 0)
     SET ms_blob = ms_blob_rtf
     SET ml_beg = 0
     SET ml_end = 0
     SET ml_obrac = 0
     SET ml_beg = findstring("{\deleted\",ms_blob)
     SET ml_safety_cnt = 0
     WHILE (ml_beg > 0)
       SET ml_obrac_cnt = 0
       SET ml_obrac = findstring("{",ms_blob,(ml_beg+ 1))
       SET ml_end = findstring("}",ms_blob,ml_beg)
       WHILE (ml_obrac < ml_end
        AND ml_obrac > 0)
         SET ml_obrac = findstring("{",ms_blob,(ml_obrac+ 1))
         SET ml_obrac_cnt += 1
         IF (ml_obrac_cnt=1000)
          SET ml_obrac = 0
         ENDIF
       ENDWHILE
       FOR (ml_loop_cnt = 1 TO ml_obrac_cnt)
         SET ml_end = findstring("}",ms_blob,(ml_end+ 1))
       ENDFOR
       SET ms_tmp = substring(ml_beg,((ml_end - ml_beg)+ 1),ms_blob)
       CALL echo("******* delete *******")
       CALL echo(ms_tmp)
       CALL echo("******* delete *******")
       SET ms_blob = replace(ms_blob,ms_tmp,"",0)
       SET ml_beg = findstring("{\deleted\",ms_blob,ml_beg)
       SET ml_safety_cnt += 1
       IF (ml_safety_cnt=1000)
        SET ml_beg = 0
       ENDIF
     ENDWHILE
     SET ms_blob_rtf = trim(ms_blob)
    ENDIF
    SET m_rec->fax[ml_idx].n_data_ind = 1
   ENDIF
   IF (((curqual < 1) OR ((m_rec->fax[ml_idx].n_data_ind=0))) )
    CALL echo(concat("Data not found for event_id: ",trim(cnvtstring(m_rec->fax[ml_idx].f_event_id)))
     )
   ENDIF
   IF (ms_mode="APC"
    AND size(m_rec->fax[ml_idx].recip,5) > 0)
    CALL echo("APC - try to match up recipients")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(m_rec->fax[ml_idx].recip,5))),
      prsnl p
     PLAN (d)
      JOIN (p
      WHERE replace(p.name_full_formatted," ","")=replace(m_rec->fax[ml_idx].recip[d.seq].s_phys_name,
       " ","")
       AND p.active_ind=1
       AND p.end_effective_dt_tm > sysdate
       AND  NOT (p.username IN ("TERM*", "NA*")))
     HEAD p.person_id
      m_rec->fax[ml_idx].recip[d.seq].f_phys_id = p.person_id, m_rec->fax[ml_idx].recip[d.seq].
      s_phys_username = trim(p.username)
      IF (p.username IN ("EN*", "SPNDEN*", "SI*"))
       m_rec->fax[ml_idx].recip[d.seq].n_bmp_phys_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(m_rec->fax[ml_idx].recip,5)=0)
    CALL echo("no recipients found")
   ELSEIF (size(m_rec->fax[ml_idx].recip,5) > 0)
    CALL echo(concat("recipient count: ",trim(cnvtstring(size(m_rec->fax[ml_idx].recip,5)))))
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
        IF (textlen(trim(ms_fin_nbr)) > 11)
         SET ms_fin_nbr = substring(1,11,ms_fin_nbr)
        ENDIF
        SET ms_filename_prefix = trim(cnvtstring(m_rec->fax[ml_idx].f_event_id,20))
        IF (ms_mode="PCP")
         IF (mn_test=0)
          SET ms_filename_prefix = concat("fax1_",ms_filename_prefix,"_")
         ELSE
          SET ms_filename_prefix = concat("fax1t_",ms_filename_prefix,"_")
         ENDIF
        ELSEIF (ms_mode="APC")
         IF (mn_test=0)
          SET ms_filename_prefix = concat("fax2_",ms_filename_prefix,"_")
         ELSE
          SET ms_filename_prefix = concat("fax2t_",ms_filename_prefix,"_")
         ENDIF
        ENDIF
        SET ms_note_filename = concat(ms_filename_prefix,ms_fin_nbr,".dat")
        SET m_rec->fax[ml_idx].recip[ml_recip_cnt].s_file_name = ms_note_filename
       ELSE
        SET ms_filename_prefix = trim(cnvtstring(m_rec->fax[ml_idx].f_event_id,20))
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
        IF (mn_test=0)
         EXECUTE bhs_sys_send_fax ms_note_filename, trim(cnvtstring(m_rec->fax[ml_idx].recip[
           ml_recip_cnt].f_phys_id)), mf_output_dest_cd,
         trim(m_rec->fax[ml_idx].recip[ml_recip_cnt].s_fax_nbr)
        ELSE
         CALL echo("test mode - fax status set to S")
         SET fax_reply->status_data.status = "S"
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
         SET ml_sent_cnt += 1
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
       AND m_rec->fax[ml_idx].recip[ml_recip_cnt].n_bmp_phys_ind)
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
       IF (mn_test=0)
        SET stat = tdbexecute(0,967100,967503,"REC",inboxrequest,
         "REC",inboxreply)
       ELSE
        CALL echo("test mode - inbox status set to S")
        SET inboxreply->status_data[1].status = "S"
       ENDIF
       IF ((inboxreply->status_data[1].status="S"))
        SET ml_sent_cnt += 1
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
         "Note Info",concat("Note Title: ",m_rec->fax[ml_idx].s_note_title," Note Type: ",m_rec->fax[
          ml_idx].s_note_type),"F")
       ENDIF
      ELSEIF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_exclude_ind=1))
       SET ml_sent_cnt += 1
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
       CALL bhs_sbr_log("log","",m_rec->fax[ml_idx].recip[ml_recip_cnt].l_log_grp_cnt,"prsnl_id",
        m_rec->fax[ml_idx].recip[ml_recip_cnt].f_phys_id,
        "Fail","Does not qualify for fax or fwd","F")
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
       IF (mn_test=0)
        SET stat = tdbexecute(0,967100,967503,"REC",inboxrequest,
         "REC",inboxreply)
       ELSE
        CALL echo("test mode - inbox status set to S")
        SET inboxreply->status_data[1].status = "S"
       ENDIF
      ENDIF
      FOR (ml_recip_cnt = 1 TO size(m_rec->fax[ml_idx].recip,5))
        IF ((m_rec->fax[ml_idx].recip[ml_recip_cnt].n_fax_stat=0)
         AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_inbox_stat=0)
         AND (m_rec->fax[ml_idx].recip[ml_recip_cnt].n_exclude_ind=0))
         CALL echo(concat("log docmgr inbox, recipient: ",m_rec->fax[ml_idx].recip[ml_recip_cnt].
           s_phys_name))
         IF ((inboxreply->status_data[1].status="S"))
          SET ml_sent_cnt += 1
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
  CALL echoxml(m_rec,ms_xml_filename)
  SELECT INTO value(ms_csv_filename)
   FROM (dummyt d1  WITH seq = value(size(m_rec->fax,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->fax[d1.seq].recip,5)))
    JOIN (d2)
   HEAD REPORT
    ms_tmp = concat(
     "recip_name,patient_name,note_type,note_title,fax_nbr,fax_nbr_ind,exclude_ind,fax_stat,inbox_stat,",
     "docmgr_stat,bmp_ind,event_id,patient_id,encntr_id,admit_dt_tm,fin,mrn,disch_dt_tm,nurse_unit,facility,",
     "signing_phys,signing_phys_prsnl_id,contr_sys_cd,contr_sys,cep_action_dt_tm,data_ind,note_qual_dt_tm,",
     "recip_username,recip_prsnl_id,log_grp_cnt,fax_file_name,fax_file_found,sort,tot_recipients"),
    col 0, ms_tmp
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
     '"',trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].n_bmp_phys_ind)),'",','"',trim(cnvtstring(
       m_rec->fax[d1.seq].f_event_id)),
     '",','"',trim(cnvtstring(m_rec->fax[d1.seq].f_person_id)),'",','"',
     trim(cnvtstring(m_rec->fax[d1.seq].f_encntr_id)),'",','"',trim(m_rec->fax[d1.seq].s_admit_dt),
     '",',
     '"',trim(m_rec->fax[d1.seq].s_acct_nbr),'",','"',trim(m_rec->fax[d1.seq].s_mrn_nbr),
     '",','"',trim(m_rec->fax[d1.seq].s_disch_dt),'",','"',
     trim(m_rec->fax[d1.seq].s_nurse_unit),'",','"',trim(m_rec->fax[d1.seq].s_facility),'",',
     '"',trim(m_rec->fax[d1.seq].s_sign_phys_name),'",','"',trim(cnvtstring(m_rec->fax[d1.seq].
       f_sign_phys_id)),
     '",','"',trim(cnvtstring(m_rec->fax[d1.seq].f_contr_sys_cd)),'",','"',
     trim(m_rec->fax[d1.seq].s_contr_sys),'",','"',trim(m_rec->fax[d1.seq].s_cep_action_dt_tm),'",',
     '"',trim(cnvtstring(m_rec->fax[d1.seq].n_data_ind)),'",','"',trim(m_rec->fax[d1.seq].
      s_qual_dt_tm),
     '",','"',trim(m_rec->fax[d1.seq].recip[d2.seq].s_phys_username),'",','"',
     trim(cnvtstring(m_rec->fax[d1.seq].recip[d2.seq].f_phys_id)),'",','"',trim(cnvtstring(m_rec->
       fax[d1.seq].recip[d2.seq].l_log_grp_cnt)),'",',
     '"',trim(m_rec->fax[d1.seq].recip[d2.seq].s_file_name),'",','"',trim(cnvtstring(m_rec->fax[d1
       .seq].recip[d2.seq].n_file_found)),
     '",','"',trim(cnvtstring(m_rec->fax[d1.seq].l_sort)),'",','"',
     trim(cnvtstring(size(m_rec->fax[d1.seq].recip,5))),'"'), col 0,
    ms_tmp
   WITH nocounter, maxcol = 2000
  ;end select
  IF (curqual > 0)
   CALL bhs_sbr_log("log","",0,concat("BHS_OPS_FAX_POWERNOTES_",ms_mode),0.0,
    "",concat("CSV file generated: ",ms_csv_filename),"R")
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat(ms_mode," BHS_OPS_FAX_POWERNOTES ",ms_beg_dt_tm," - ",ms_end_dt_tm)
   CALL emailfile(value(ms_csv_filename),ms_csv_filename,ms_recipients,ms_tmp,1)
   CALL emailfile(value(ms_xml_filename),ms_xml_filename,ms_recipients,ms_tmp,1)
  ELSE
   IF (ms_recipients="FTP")
    SELECT INTO value(ms_csv_filename)
     FROM dummyt d
     HEAD REPORT
      col 0, "no data found"
     WITH nocounter
    ;end select
   ELSE
    CALL uar_send_mail(nullterm(ms_recipients),nullterm(concat(ms_mode," NOTES FAXING OPS ",trim(
        format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(concat(ms_mode,
       " - No notes found for this job")),nullterm(curnode),1,
     nullterm("IPM.NOTE"))
   ENDIF
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
 IF (gl_bhs_prod_flag=1)
  CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat(ms_mode," NOTES FAXING OPS FAIL ",
     trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_tmp),nullterm(concat(ms_mode,
     "NOTES FAXING OPS JOB ",curnode)),1,
   nullterm("IPM.NOTE"))
  CALL uar_send_mail(nullterm("94556@epage.bhs.org"),nullterm("NOTES FAXING FAIL"),nullterm(concat(
     ms_mode," NOTES FAXING OPS FAIL - see CORE inbox ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),
   nullterm(concat(ms_mode," NOTES FAXING OPS JOB")),1,
   nullterm("IPM.NOTE"))
 ENDIF
#exit_script
 IF (mn_test=1)
  SET ms_msg = concat("TESTRUN: ",ms_msg)
 ENDIF
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
 SUBROUTINE (sbr_get_fax_nbrs(ml_rec_idx=i4) =null)
   DECLARE ms_tmp_phone = vc WITH protect, noconstant(" ")
   DECLARE ms_area = vc WITH protect, noconstant(" ")
   DECLARE ms_prefix = vc WITH protect, noconstant(" ")
   DECLARE ms_suffix = vc WITH protect, noconstant(" ")
   DECLARE ms_adj_nbr = vc WITH protect, noconstant(" ")
   CALL echo("look up recipient in hnauser")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(m_rec->fax[ml_rec_idx].recip,5))),
     phone p
    PLAN (d
     WHERE (m_rec->fax[ml_rec_idx].recip[d.seq].n_fax_nbr_ind=0)
      AND (m_rec->fax[ml_rec_idx].recip[d.seq].n_bmp_phys_ind=0))
     JOIN (p
     WHERE (p.parent_entity_id=m_rec->fax[ml_rec_idx].recip[d.seq].f_phys_id)
      AND p.phone_type_cd=mf_fax_bus_cd
      AND p.active_ind=1
      AND p.end_effective_dt_tm > sysdate)
    HEAD REPORT
     pl_len = 0
    HEAD p.phone_id
     ms_tmp_phone = "", ms_area = "", ms_prefix = "",
     ms_suffix = "", ms_adj_nbr = "", ms_tmp_phone = trim(p.phone_num_key)
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
     ms_adj_nbr = concat("5551",ms_area,ms_prefix,ms_suffix), m_rec->fax[ml_rec_idx].recip[d.seq].
     s_fax_nbr = ms_adj_nbr, m_rec->fax[ml_rec_idx].recip[d.seq].n_fax_nbr_ind = 1
    WITH nocounter
   ;end select
   CALL echo("look up recipient in RRD")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(m_rec->fax[ml_rec_idx].recip,5))),
     device_xref dx,
     remote_device rd
    PLAN (d
     WHERE (m_rec->fax[ml_rec_idx].recip[d.seq].f_phys_id > 0)
      AND (m_rec->fax[ml_rec_idx].recip[d.seq].n_fax_nbr_ind=0)
      AND (m_rec->fax[ml_rec_idx].recip[d.seq].n_bmp_phys_ind=0))
     JOIN (dx
     WHERE (dx.parent_entity_id=m_rec->fax[ml_rec_idx].recip[d.seq].f_phys_id)
      AND dx.parent_entity_name="PRSNL"
      AND dx.usage_type_cd=mf_fax_cd)
     JOIN (rd
     WHERE rd.device_cd=dx.device_cd
      AND  NOT (trim(rd.phone_suffix) IN (null, "", " ")))
    DETAIL
     ms_area = "", ms_prefix = "", ms_suffix = "",
     ms_adj_nbr = "", ms_area = trim(rd.area_code)
     IF (textlen(ms_area)=0)
      ms_area = "413"
     ENDIF
     ms_prefix = trim(rd.exchange), ms_suffix = trim(rd.phone_suffix), ms_adj_nbr = concat("5551",
      ms_area,ms_prefix,ms_suffix),
     m_rec->fax[ml_rec_idx].recip[d.seq].s_fax_nbr = trim(ms_adj_nbr), m_rec->fax[ml_rec_idx].recip[d
     .seq].n_fax_nbr_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(m_rec->fax[ml_rec_idx].recip,5))),
     bhs_physician_fax_list b
    PLAN (d
     WHERE (m_rec->fax[ml_rec_idx].recip[d.seq].f_phys_id > 0))
     JOIN (b
     WHERE (b.person_id=m_rec->fax[ml_rec_idx].recip[d.seq].f_phys_id)
      AND b.fax="EXCLUDE")
    DETAIL
     m_rec->fax[ml_rec_idx].recip[d.seq].n_exclude_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (sbr_upd_dm_info(ms_stop_dt_tm=vc) =null)
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
  FOR (x = 1 TO size(m_rec->fax,5))
    FOR (y = 1 TO size(m_rec->fax[x].recip,5))
      CALL echo(m_rec->fax[x].recip[y].s_fax_nbr)
    ENDFOR
  ENDFOR
  SET x = 1
 ENDIF
 FREE RECORD m_rec
END GO
