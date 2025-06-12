CREATE PROGRAM bhs_ma_saved_powernote2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Begin Date" = curdate,
  "Enter End Date" = curdate,
  "Spreadsheet view:" = 1
  WITH outdev, date1, date2,
  spreadview
 DECLARE dischargedttm = vc WITH noconstant(" ")
 DECLARE mrn = vc WITH noconstant(" ")
 DECLARE fin = vc WITH noconstant(" ")
 DECLARE savedttm = vc WITH noconstant(" ")
 DECLARE notetype = vc WITH noconstant(" ")
 DECLARE saveddttm = vc WITH noconstant(" ")
 DECLARE mdname = vc WITH noconstant(" ")
 DECLARE ptname = vc WITH noconstant(" ")
 DECLARE scdstorytype = vc WITH noconstant(" ")
 DECLARE encntrtype = vc WITH noconstant(" ")
 DECLARE saveddttm = vc WITH noconstant(" ")
 SET v_acct_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET v_mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headsec(ncalc=i2) = f8 WITH protect
 DECLARE headsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsec(ncalc=i2) = f8 WITH protect
 DECLARE detailsecabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE headsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE __fieldname2 = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime3),
      "MM/DD/YYYY HH:MM:SS;;q"),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SAVED POWERNOTES REPORT",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 7.510
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.062)),(offsety+ 0.375),(offsetx+ 7.448),(
     offsety+ 0.375))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.990
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsecabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.610000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mdname,char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mrn,char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ptname,char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(dischargedttm,char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 5.125)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fin,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(scdstorytype,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physician:",char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Disch:",char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(encntrtype,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 2.771)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Encntr:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(saveddttm,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Saved:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_MA_SAVED_POWERNOTE2"
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
   SET rptfont->m_pointsize = 12
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
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
 SET d0 = initializereport(0)
 IF (( $SPREADVIEW=0))
  SELECT INTO  $OUTDEV
   p.name_full_formatted, patient = substring(1,30,pe.name_full_formatted)
   FROM scd_story s,
    scd_story_pattern ssp,
    scr_pattern sp,
    clinical_event ce,
    encounter e,
    prsnl p,
    person pe,
    encntr_alias ea,
    encntr_alias ea1
   PLAN (s
    WHERE s.story_completion_status_cd=10395
     AND s.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE1),0) AND cnvtdatetime(cnvtdate( $DATE2),
     235959))
    JOIN (ssp
    WHERE ssp.scd_story_id=s.scd_story_id)
    JOIN (sp
    WHERE sp.scr_pattern_id=ssp.scr_pattern_id
     AND sp.active_ind=1)
    JOIN (ce
    WHERE ce.event_id=s.event_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (e
    WHERE e.encntr_id=s.encounter_id
     AND e.disch_dt_tm IS NOT null)
    JOIN (p
    WHERE p.person_id=s.author_id)
    JOIN (pe
    WHERE pe.person_id=s.person_id)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ((ea.encntr_alias_type_cd+ 0)=outerjoin(v_mrn_cd)))
    JOIN (ea1
    WHERE ea1.encntr_id=outerjoin(e.encntr_id)
     AND ((ea1.encntr_alias_type_cd+ 0)=outerjoin(v_acct_cd)))
   ORDER BY p.name_full_formatted, patient
   HEAD PAGE
    d0 = headsec(rpt_render)
   DETAIL
    scdstorytype = trim(sp.display,3), mrn = trim(ea.alias,3), fin = trim(ea1.alias,3),
    mdname = substring(1,30,p.name_full_formatted), ptname = substring(1,30,pe.name_full_formatted),
    dischargedttm = format(cnvtdatetime(e.disch_dt_tm),"MM/DD/YYYY HH:MM:SS;;q"),
    encntrtype = trim(uar_get_code_display(e.encntr_class_cd),3), saveddttm = format(cnvtdatetime(ce
      .event_end_dt_tm),"MM/DD/YYYY HH:MM:SS;;q"),
    CALL echo(e.disch_dt_tm)
    IF (((_yoffset+ detailsec(rpt_calcheight)) > 10))
     d0 = pagebreak(0), d0 = headsec(rpt_render)
    ENDIF
    do = detailsec(rpt_render)
   WITH nocounter, maxcol = 130
  ;end select
  SET d0 = finalizereport( $OUTDEV)
 ELSE
  SELECT INTO  $OUTDEV
   mdname = substring(1,30,p.name_full_formatted), ptname = substring(1,30,pe.name_full_formatted),
   notetype = substring(1,40,trim(sp.display,3)),
   encntrtype = substring(1,20,trim(uar_get_code_display(e.encntr_class_cd),3)), mrn = substring(1,10,
    trim(ea.alias,3)), fin = substring(1,11,trim(ea1.alias,3)),
   dischargedttm = format(cnvtdatetime(e.disch_dt_tm),"MM/DD/YYYY HH:MM:SS;;q"), saveddttm = format(
    cnvtdatetime(ce.event_end_dt_tm),"MM/DD/YYYY HH:MM:SS;;q")
   FROM scd_story s,
    scd_story_pattern ssp,
    scr_pattern sp,
    clinical_event ce,
    encounter e,
    prsnl p,
    person pe,
    encntr_alias ea,
    encntr_alias ea1
   PLAN (s
    WHERE s.story_completion_status_cd=10395
     AND s.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $DATE1),0) AND cnvtdatetime(cnvtdate( $DATE2),
     235959))
    JOIN (ssp
    WHERE ssp.scd_story_id=s.scd_story_id)
    JOIN (sp
    WHERE sp.scr_pattern_id=ssp.scr_pattern_id
     AND sp.active_ind=1)
    JOIN (ce
    WHERE ce.event_id=s.event_id
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (e
    WHERE e.encntr_id=s.encounter_id
     AND e.disch_dt_tm IS NOT null)
    JOIN (p
    WHERE p.person_id=s.author_id)
    JOIN (pe
    WHERE pe.person_id=s.person_id)
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ((ea.encntr_alias_type_cd+ 0)=outerjoin(v_mrn_cd)))
    JOIN (ea1
    WHERE ea1.encntr_id=outerjoin(e.encntr_id)
     AND ((ea1.encntr_alias_type_cd+ 0)=outerjoin(v_acct_cd)))
   ORDER BY mdname, ptname
   WITH format
  ;end select
 ENDIF
END GO
