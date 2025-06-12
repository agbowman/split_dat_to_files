CREATE PROGRAM bhs_rpt_sch_appt_daily:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Scheduled Date:" = "CURDATE"
  WITH outdev, ms_start_dt
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_patient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE mf_action_schedule_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14232,"SCHEDULE"
   ))
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc1 = i4 WITH protect, noconstant(0)
 FREE RECORD m_sched
 RECORD m_sched(
   1 l_cnt = i4
   1 qual[*]
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_appt_date = vc
     2 s_appt_type = vc
     2 s_appt_loc = vc
     2 s_sched_user = vc
 ) WITH protect
 FREE RECORD m_loc
 RECORD m_loc(
   1 l_cnt = i4
   1 qual[*]
     2 f_code_value = f8
     2 s_display = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_header(ncalc=i2) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_detail(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_detailabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE sec_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.260417), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.618
   SET rptsd->m_height = 0.253
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.681
   SET rptsd->m_height = 0.253
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.320)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.253
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.070)
   SET rptsd->m_width = 1.930
   SET rptsd->m_height = 0.253
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.253
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.695)
   SET rptsd->m_width = 0.805
   SET rptsd->m_height = 0.253
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.313),offsety,(offsetx+ 2.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.063),offsety,(offsetx+ 3.063),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.688),offsety,(offsetx+ 6.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __start_date = vc WITH noconstant(build2( $MS_START_DT,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 5.854
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Daily Booked Access QA Report for Date Scheduled :",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__start_date)
    SET _yoffset = (offsety+ 0.625)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.625)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.208
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Scheduler",char(0)))
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 5.063)
    SET rptsd->m_width = 1.208
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Department Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.667)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Type",char(0)))
    SET rptsd->m_y = (offsety+ 0.677)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Date",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.677)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pt DOB",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_detail(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.618
   SET rptsd->m_height = 0.181
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.632)
   SET rptsd->m_width = 0.681
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.320)
   SET rptsd->m_width = 0.743
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.070)
   SET rptsd->m_width = 1.930
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.695)
   SET rptsd->m_width = 0.805
   SET rptsd->m_height = 0.181
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.625),offsety,(offsetx+ 1.625),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.313),offsety,(offsetx+ 2.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.063),offsety,(offsetx+ 3.063),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),offsety,(offsetx+ 5.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.688),offsety,(offsetx+ 6.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.500),offsety,(offsetx+ 7.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 7.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 7.500),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_detailabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __s_patname = vc WITH noconstant(build2(m_sched->qual[ml_cnt1].s_pat_name,char(0))),
   protect
   DECLARE __s_depname = vc WITH noconstant(build2(m_sched->qual[ml_cnt1].s_appt_loc,char(0))),
   protect
   DECLARE __s_appttype = vc WITH noconstant(build2(m_sched->qual[ml_cnt1].s_appt_type,char(0))),
   protect
   DECLARE __s_apptdate = vc WITH noconstant(build2(m_sched->qual[ml_cnt1].s_appt_date,char(0))),
   protect
   DECLARE __s_patdob = vc WITH noconstant(build2(m_sched->qual[ml_cnt1].s_pat_dob,char(0))), protect
   DECLARE __s_scheduler = vc WITH noconstant(build2(m_sched->qual[ml_cnt1].s_sched_user,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow1(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_patname)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.031)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_depname)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.104)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_appttype)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 0.656
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_apptdate)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 0.583
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_patdob)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.708)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__s_scheduler)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_SCH_APPT_DAILY"
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
   SET rptfont->m_recsize = 52
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
   SET rptfont->m_pointsize = 8
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.cdf_meaning="AMBULATORY"
   AND cv.display_key IN ("ANESTHESIAREMOTESITES", "BFMCINTERVENTIONALRADIOLOGY",
  "BWHENDOSCOPYSPECIALPROCEDURES", "BAYSTATEORTHOPEDICSURGICALCENTER", "BFMCLABORANDDELIVERY",
  "BFMCPAINCLINIC", "BFMCSURGICALSERVICES", "BMCENDOSCOPY", "BMCENDOSCOPYCENTER",
  "BMLHENDOSCOPYANDSPECIALPROCEDURES",
  "BMLHSURGICALSERVICES", "BWHSURGICALSERVICES", "CARDIACCATHLAB", "CHESTNUTSURGERYCENTER",
  "DALYSURGERY",
  "ELECTROPHYSIOLOGY", "HEARTANDVASCULAROR", "INTERVENTIONALRADIOLOGY", "NONINVASIVECARDIOLOGY",
  "PEDIATRICPROCEDUREUNIT",
  "BRIEASTLONG", "BRIENFIELD", "BRINORTHAMPTON", "BRISOUTHHAD", "BMCRAD",
  "3300RAD", "BBWCRAD", "BFMCRAD", "BMLHRAD", "BWHRADIOLOGY",
  "BMLORAD")
  HEAD REPORT
   m_loc->l_cnt = 0
  DETAIL
   m_loc->l_cnt = (m_loc->l_cnt+ 1), stat = alterlist(m_loc->qual,m_loc->l_cnt), m_loc->qual[m_loc->
   l_cnt].f_code_value = cv.code_value,
   m_loc->qual[m_loc->l_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   sch_event_action sea,
   person per,
   prsnl pr
  PLAN (sea
   WHERE sea.action_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND sea.sch_action_cd=mf_action_schedule_cd
    AND sea.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sea.action_prsnl_id != 12437405.0)
   JOIN (se
   WHERE se.sch_event_id=sea.sch_event_id
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (sa
   WHERE sa.sch_event_id=se.sch_event_id
    AND expand(ml_loc1,1,m_loc->l_cnt,sa.appt_location_cd,m_loc->qual[ml_loc1].f_code_value)
    AND sa.sch_role_cd=mf_patient_cd
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (per
   WHERE per.person_id=sa.person_id)
   JOIN (pr
   WHERE pr.person_id=outerjoin(sea.action_prsnl_id))
  ORDER BY uar_get_code_display(sa.appt_location_cd), per.name_full_formatted, format(sa.beg_dt_tm,
    "MM/DD/YYYY;;q")
  HEAD REPORT
   m_sched->l_cnt = 0
  DETAIL
   m_sched->l_cnt = (m_sched->l_cnt+ 1), stat = alterlist(m_sched->qual,m_sched->l_cnt), m_sched->
   qual[m_sched->l_cnt].s_pat_name = trim(per.name_full_formatted,3),
   m_sched->qual[m_sched->l_cnt].s_pat_dob = format(per.birth_dt_tm,"MM/DD/YYYY;;q"), m_sched->qual[
   m_sched->l_cnt].s_appt_date = format(sa.beg_dt_tm,"MM/DD/YYYY;;q"), m_sched->qual[m_sched->l_cnt].
   s_appt_type = trim(uar_get_code_display(se.appt_type_cd),3),
   m_sched->qual[m_sched->l_cnt].s_appt_loc = trim(uar_get_code_display(sa.appt_location_cd),3),
   m_sched->qual[m_sched->l_cnt].s_sched_user = trim(pr.username,3)
  WITH nocounter, separator = " ", format
 ;end select
 CALL echorecord(m_sched)
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 EXECUTE reportrtl
 SET d0 = sec_header(rpt_render)
 FOR (ml_cnt1 = 1 TO m_sched->l_cnt)
   SET mf_rem_space = (mf_page_size - (_yoffset+ sec_detail(rpt_calcheight)))
   IF (mf_rem_space <= 0.25)
    SET _yoffset = 10.18
    SET d0 = pagebreak(0)
   ENDIF
   SET d0 = sec_detail(rpt_render)
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
END GO
