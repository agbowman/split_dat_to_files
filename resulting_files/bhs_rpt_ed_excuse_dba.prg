CREATE PROGRAM bhs_rpt_ed_excuse:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_patient_name = vc
   1 s_visit_date = vc
   1 f_event_id = f8
   1 s_dob = vc
   1 s_fin_nbr = vc
   1 s_disch_phys = vc
   1 s_disch_nurse = vc
   1 s_note = vc
   1 addendums[*]
     2 s_title = vc
     2 s_text = vc
 ) WITH protect
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE report_head(ncalc=i2) = f8 WITH protect
 DECLARE report_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_divider1(ncalc=i2) = f8 WITH protect
 DECLARE section_divider1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE phys_info(ncalc=i2) = f8 WITH protect
 DECLARE phys_infoabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_divider2(ncalc=i2) = f8 WITH protect
 DECLARE section_divider2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE excuse_header(ncalc=i2) = f8 WITH protect
 DECLARE excuse_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE excuse_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE excuse_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE section_space(ncalc=i2) = f8 WITH protect
 DECLARE section_spaceabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE addendum_header(ncalc=i2) = f8 WITH protect
 DECLARE addendum_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE addendum_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE addendum_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remnotes = i2 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontexcuse_detail = i2 WITH noconstant(0), protect
 DECLARE _rems_text = i2 WITH noconstant(1), protect
 DECLARE _bcontaddendum_detail = i2 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen21s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE report_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE report_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.820000), private
   DECLARE __visit_date = vc WITH noconstant(build2(m_info->s_visit_date,char(0))), protect
   DECLARE __patient_name = vc WITH noconstant(build2(m_info->s_patient_name,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(m_info->s_dob,char(0))), protect
   DECLARE __acct_num = vc WITH noconstant(build2(m_info->s_fin_nbr,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Emergency Department Medical Excuse Note",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__visit_date)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Medical Center",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "759 Chestnut Street Springfield, MA 01199",char(0)))
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("413-794-0000",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Visit:",char(0)))
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ - (0.062))
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ED Account Number:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 5.813)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 5.813)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct_num)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_divider1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_divider1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_divider1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.150000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.073),(offsetx+ 7.500),(offsety+
     0.073))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE phys_info(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = phys_infoabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE phys_infoabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE __md_name = vc WITH noconstant(build2(m_info->s_disch_phys,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.906
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ED Clinician:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 5.635
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__md_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_divider2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_divider2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_divider2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.150000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen21s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.073),(offsetx+ 7.500),(offsety+
     0.073))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE excuse_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = excuse_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE excuse_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medical Excuse Note",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE excuse_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = excuse_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE excuse_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_notes = f8 WITH noconstant(0.0), private
   DECLARE __notes = vc WITH noconstant(build2(m_info->s_note,char(0))), protect
   IF (bcontinue=0)
    SET _remnotes = 1
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
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremnotes = _remnotes
   IF (_remnotes > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnotes,((size(__notes)
        - _remnotes)+ 1),__notes)))
    SET drawheight_notes = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnotes = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnotes,((size(__notes) - _remnotes)+ 1),
       __notes)))))
     SET _remnotes = (_remnotes+ rptsd->m_drawlength)
    ELSE
     SET _remnotes = 0
    ENDIF
    SET growsum = (growsum+ _remnotes)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_notes
   IF (ncalc=rpt_render
    AND _holdremnotes > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnotes,((size(
        __notes) - _holdremnotes)+ 1),__notes)))
   ELSE
    SET _remnotes = _holdremnotes
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
 SUBROUTINE section_space(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_spaceabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_spaceabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE addendum_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = addendum_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE addendum_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __addendum_title = vc WITH noconstant(build2(m_info->addendums[ml_loop_cnt].s_title,char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__addendum_title)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE addendum_detail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = addendum_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE addendum_detailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_s_text = f8 WITH noconstant(0.0), private
   DECLARE __s_text = vc WITH noconstant(build2(m_info->addendums[ml_loop_cnt].s_text,char(0))),
   protect
   IF (bcontinue=0)
    SET _rems_text = 1
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
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrems_text = _rems_text
   IF (_rems_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rems_text,((size(__s_text
        ) - _rems_text)+ 1),__s_text)))
    SET drawheight_s_text = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rems_text = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rems_text,((size(__s_text) - _rems_text)
       + 1),__s_text)))))
     SET _rems_text = (_rems_text+ rptsd->m_drawlength)
    ELSE
     SET _rems_text = 0
    ENDIF
    SET growsum = (growsum+ _rems_text)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_s_text
   IF (ncalc=rpt_render
    AND _holdrems_text > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrems_text,((size(
        __s_text) - _holdrems_text)+ 1),__s_text)))
   ELSE
    SET _rems_text = _holdrems_text
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "bhs_rpt_ed_excuse"
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
   SET rptfont->m_bold = rpt_on
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.021
   SET _pen21s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 DECLARE mf_signed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",15750,"SIGNED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_sign_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_printer_name = vc WITH protect, noconstant(" ")
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE ml_cont_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_blob = vc WITH protect, noconstant(" ")
 DECLARE ms_string = vc WITH protect, noconstant(" ")
 DECLARE sbr_pagebreak(x=i2) = null
 DECLARE sbr_process_blob(s_blob_in=vc,f_comp_cd=f8) = vc
 IF (validate(request->visit,"Z") != "Z")
  SET ms_printer_name = request->output_device
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSEIF (cnvtreal( $F_ENCNTR_ID) > 0.0)
  SET ms_printer_name =  $OUTDEV
  SET mf_encntr_id = cnvtreal( $F_ENCNTR_ID)
 ELSE
  GO TO exit_script
 ENDIF
 SELECT
  ss.title, ce.event_title_text, ce.result_val
  FROM scd_story ss,
   scd_story_pattern ssp,
   scr_pattern sp,
   encounter e,
   encntr_alias ea,
   person p,
   clinical_event ce,
   ce_event_prsnl cep,
   prsnl pr,
   ce_blob cb
  PLAN (ss
   WHERE ss.encounter_id=mf_encntr_id
    AND ss.story_completion_status_cd=mf_signed_cd)
   JOIN (ssp
   WHERE ssp.scd_story_id=ss.scd_story_id)
   JOIN (sp
   WHERE ssp.scr_pattern_id=sp.scr_pattern_id
    AND sp.cki_source="BHS_MA"
    AND sp.cki_identifier="EP BHS ED MEDICAL EXCUSE NOTE")
   JOIN (e
   WHERE ss.encounter_id=e.encntr_id)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (ce
   WHERE ss.event_id=ce.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
   JOIN (cep
   WHERE ce.event_id=cep.event_id
    AND cep.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((cep.action_type_cd+ 0)=mf_sign_cd)
    AND ((cep.action_status_cd+ 0)=mf_completed_cd))
   JOIN (pr
   WHERE cep.action_prsnl_id=pr.person_id)
   JOIN (cb
   WHERE cb.event_id=ss.event_id
    AND cb.valid_until_dt_tm > sysdate)
  ORDER BY ss.active_status_dt_tm DESC, ss.scd_story_id, cep.action_dt_tm,
   pr.person_id, ce.valid_from_dt_tm DESC
  HEAD REPORT
   pn_cnt = 0, pn_story_id = 0, pn_det_cnt = 0,
   pl_beg_pos = 0, pl_end_pos = 0
  HEAD ss.scd_story_id
   pn_cnt = (pn_cnt+ 1),
   CALL echo(build("head cnt: ",pn_cnt))
   IF (pn_cnt=1)
    pn_story_id = ss.scd_story_id, m_info->s_patient_name = trim(p.name_full_formatted), m_info->
    s_dob = trim(format(p.birth_dt_tm,"mm-dd-yyyy;;d")),
    m_info->s_fin_nbr = trim(ea.alias), m_info->s_visit_date = trim(format(e.active_status_dt_tm,
      "mm-dd-yyyy;;d"))
   ENDIF
   IF (ss.scd_story_id=pn_story_id)
    IF (trim(m_info->s_disch_phys) <= " "
     AND pr.physician_ind=1)
     m_info->s_disch_phys = trim(pr.name_full_formatted)
    ENDIF
    IF (trim(m_info->s_disch_nurse,3) <= " "
     AND pr.physician_ind=0)
     m_info->s_disch_nurse = trim(pr.name_full_formatted,3)
    ENDIF
   ENDIF
  DETAIL
   pn_det_cnt = (pn_det_cnt+ 1),
   CALL echo(" "),
   CALL echo(build("det cnt: ",pn_det_cnt)),
   CALL echo(build("valid from: ",trim(format(ce.valid_from_dt_tm,"mm-dd-yyyy hh:mm;;d"))))
   IF (pn_det_cnt=1)
    IF (textlen(trim(cb.blob_contents)) > 0)
     ms_blob = trim(sbr_process_blob(cb.blob_contents,cb.compression_cd),3), pl_beg_pos = findstring(
      "MEDICAL EXCUSE NOTE",cnvtupper(ms_blob))
     IF (pl_beg_pos > 0)
      pl_beg_pos = (pl_beg_pos+ 20), pl_end_pos = textlen(ms_blob), ms_string = trim(substring(
        pl_beg_pos,((pl_end_pos - pl_beg_pos)+ 1),ms_blob),3)
      IF (substring(1,1,ms_string)=" ")
       ms_string = substring(2,(textlen(ms_string) - 1),ms_string)
      ENDIF
      IF (substring(textlen(ms_string),1,ms_string) != ".")
       ms_string = concat(ms_string,".")
      ENDIF
      m_info->s_note = ms_string,
      CALL echo(build("note: ",ms_string))
     ENDIF
    ENDIF
    m_info->f_event_id = ss.event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_blob cb
  PLAN (ce
   WHERE (ce.parent_event_id=m_info->f_event_id)
    AND ce.parent_event_id != ce.event_id
    AND ce.valid_until_dt_tm >= sysdate)
   JOIN (cb
   WHERE cb.event_id=ce.event_id
    AND cb.valid_until_dt_tm >= sysdate)
  ORDER BY ce.event_end_dt_tm
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->addendums,5))
    stat = alterlist(m_info->addendums,(pn_cnt+ 10))
   ENDIF
   m_info->addendums[pn_cnt].s_title = "Additional Information", m_info->addendums[pn_cnt].s_text =
   sbr_process_blob(cb.blob_contents,cb.compression_cd)
  FOOT REPORT
   stat = alterlist(m_info->addendums,pn_cnt)
  WITH nocounter
 ;end select
 IF (trim(m_info->s_disch_phys)=""
  AND trim(m_info->s_disch_nurse) > " ")
  SET m_info->s_disch_phys = trim(m_info->s_disch_nurse)
 ENDIF
 SET d0 = report_head(rpt_render)
 SET d0 = section_divider1(rpt_render)
 SET d0 = phys_info(rpt_render)
 SET d0 = section_divider2(rpt_render)
 IF (textlen(trim(m_info->s_note)) > 0)
  SET d0 = excuse_header(rpt_render)
  SET mf_rem_space = (mf_page_size - _yoffset)
  SET d0 = excuse_detail(rpt_render,mf_rem_space,ml_cont_ind)
  WHILE (ml_cont_ind=1)
   CALL sbr_pagebreak(0)
   SET d0 = excuse_detail(rpt_render,mf_rem_space,ml_cont_ind)
  ENDWHILE
 ENDIF
 IF (size(m_info->addendums,5) > 0)
  FOR (ml_loop_cnt = 1 TO size(m_info->addendums,5))
    SET d0 = section_space(rpt_render)
    SET mf_rem_space = (mf_page_size - _yoffset)
    IF (mf_rem_space < 0.22)
     CALL sbr_pagebreak(0)
    ENDIF
    SET d0 = addendum_header(rpt_render)
    SET d0 = addendum_detail(rpt_render,mf_rem_space,ml_cont_ind)
    WHILE (ml_cont_ind=1)
     CALL sbr_pagebreak(0)
     SET d0 = addendum_detail(rpt_render,mf_rem_space,ml_cont_ind)
    ENDWHILE
  ENDFOR
 ENDIF
 SET d0 = finalizereport(value(ms_printer_name))
 SUBROUTINE sbr_pagebreak(x)
  SET d0 = pagebreak(0)
  SET mf_rem_space = mf_page_size
 END ;Subroutine
 SUBROUTINE sbr_process_blob(s_blob_in,f_comp_cd)
   DECLARE ml_blob_ret_len = i4 WITH protect, noconstant(0)
   DECLARE ml_blob_ret_len2 = i4 WITH protect, noconstant(0)
   SET ms_blob_comp_trimmed = fillstring(64000," ")
   SET ms_blob_uncomp = fillstring(64000," ")
   SET ms_blob_rtf = fillstring(64000," ")
   SET ms_blob_out = fillstring(64000," ")
   SET ms_blob_comp_trimmed = trim(s_blob_in)
   IF (f_comp_cd=mf_comp_cd)
    CALL uar_ocf_uncompress(ms_blob_comp_trimmed,size(ms_blob_comp_trimmed),ms_blob_uncomp,size(
      ms_blob_uncomp),ml_blob_ret_len)
    CALL uar_rtf2(ms_blob_uncomp,ml_blob_ret_len,ms_blob_rtf,size(ms_blob_rtf),ml_blob_ret_len2,
     1)
    SET ms_blob_out = trim(ms_blob_rtf,3)
   ELSEIF (f_comp_cd=mf_no_comp_cd)
    SET ms_blob_out = trim(s_blob_in)
    IF (findstring("rtf",ms_blob_out) > 0)
     CALL uar_rtf2(ms_blob_out,textlen(ms_blob_out),ms_blob_rtf,size(ms_blob_rtf),ml_blob_ret_len2,
      1)
     SET ms_blob_out = trim(ms_blob_rtf,3)
    ENDIF
    IF (findstring("ocf_blob",ms_blob_out) > 0)
     SET ms_blob_out = trim(substring(1,(findstring("ocf_blob",ms_blob_out) - 1),ms_blob_out))
    ENDIF
   ENDIF
   CALL echo(concat("ms_blob_out: ",ms_blob_out))
   RETURN(ms_blob_out)
 END ;Subroutine
#exit_script
 CALL echorecord(m_info)
END GO
