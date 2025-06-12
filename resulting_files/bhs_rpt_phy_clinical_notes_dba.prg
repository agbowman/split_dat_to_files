CREATE PROGRAM bhs_rpt_phy_clinical_notes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Provide Last Name" = ""
  WITH outdev, s_person_id
 FREE RECORD rec_str
 RECORD rec_str(
   1 date[*]
     2 s_date = vc
     2 patient[*]
       3 s_patient_name = vc
       3 f_person_id = f8
       3 s_mrn = vc
       3 notes[*]
         4 s_note_event = vc
         4 s_performed_tm = vc
         4 s_note = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE ml_date_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_notes_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_page_brk = i4 WITH protect, noconstant(0)
 DECLARE ms_provider_name = vc WITH protect, noconstant("")
 DECLARE mf_phy_person_id = f8
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreport(ncalc=i2) = f8 WITH protect
 DECLARE headreportabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientdetails(ncalc=i2) = f8 WITH protect
 DECLARE patientdetailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientnotes(ncalc=i2) = f8 WITH protect
 DECLARE patientnotesabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientseperator(ncalc=i2) = f8 WITH protect
 DECLARE patientseperatorabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times10i0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s1c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE headreport(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.120000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 0.818),(offsetx+ 7.500),(offsety+
     0.818))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.015),(offsetx+ 7.500),(offsety+
     1.015))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 6.563)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 6.563)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physician Clinical Notes",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.010
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Printed:",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Page Number:",char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.844)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.833
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date",char(0)))
    SET rptsd->m_y = (offsety+ 0.844)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.844)
    SET rptsd->m_x = (offsetx+ 3.844)
    SET rptsd->m_width = 1.094
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN#",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_provider_name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Program Name:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientdetails(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientdetailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patientdetailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   DECLARE __date_s_date = vc WITH noconstant(build2(rec_str->date[ml_date_cnt].s_date,char(0))),
   protect
   DECLARE __patient_s_patient_name = vc WITH noconstant(build2(rec_str->date[ml_date_cnt].patient[
     ml_pat_cnt].s_patient_name,char(0))), protect
   DECLARE __patient_s_mrn = vc WITH noconstant(build2(rec_str->date[ml_date_cnt].patient[ml_pat_cnt]
     .s_mrn,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_s_date)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_s_patient_name)
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_s_mrn)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.635)
    SET rptsd->m_width = 6.865
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Note",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientnotes(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientnotesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patientnotesabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __notes_s_performed_tm = vc WITH noconstant(build2(rec_str->date[ml_date_cnt].patient[
     ml_pat_cnt].notes[ml_notes_cnt].s_performed_tm,char(0))), protect
   DECLARE __notes_s_note = vc WITH noconstant(build2(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].
     notes[ml_notes_cnt].s_note,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__notes_s_performed_tm)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 6.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__notes_s_note)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientseperator(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientseperatorabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patientseperatorabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s1c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.031),(offsety+ 0.032),(offsetx+ 7.500),(offsety+
     0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "BHS_RPT_PHY_CLINICAL_NOTES"
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
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_on
   SET _times10i0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 1
   SET _pen14s1c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   s_username = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.person_id=cnvtreal( $S_PERSON_ID)
  DETAIL
   ms_provider_name = trim(p.name_full_formatted), mf_phy_person_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  performed_dt = format(c.performed_dt_tm,"MM/DD/YYYY;;q")
  FROM prsnl pr,
   clinical_event c,
   note_type n,
   person p
  PLAN (pr
   WHERE pr.person_id=cnvtreal(mf_phy_person_id)
    AND pr.active_ind=1)
   JOIN (c
   WHERE c.performed_prsnl_id=pr.person_id
    AND c.clinsig_updt_dt_tm > cnvtlookbehind("2,Y")
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (n
   WHERE n.event_cd=c.event_cd
    AND n.data_status_ind=1)
   JOIN (p
   WHERE p.person_id=c.person_id
    AND p.active_ind=1)
  ORDER BY c.performed_dt_tm, p.person_id, c.encntr_id,
   c.event_cd, c.event_end_dt_tm DESC
  HEAD REPORT
   ml_date_cnt = 0, ml_pat_cnt = 0, ml_encntr_cnt = 0,
   ml_notes_cnt = 0
  HEAD performed_dt
   ml_pat_cnt = 0, ml_notes_cnt = 0, ml_date_cnt = (ml_date_cnt+ 1),
   stat = alterlist(rec_str->date,ml_date_cnt), rec_str->date[ml_date_cnt].s_date = performed_dt
  HEAD p.person_id
   ml_pat_cnt = (ml_pat_cnt+ 1), ml_notes_cnt = 0, stat = alterlist(rec_str->date[ml_date_cnt].
    patient,ml_pat_cnt),
   rec_str->date[ml_date_cnt].patient[ml_pat_cnt].f_person_id = p.person_id, rec_str->date[
   ml_date_cnt].patient[ml_pat_cnt].s_patient_name = substring(1,25,p.name_full_formatted)
  HEAD c.encntr_id
   ml_encntr_cnt = 0
  HEAD c.event_cd
   ml_notes_cnt = (ml_notes_cnt+ 1), stat = alterlist(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].
    notes,ml_notes_cnt), rec_str->date[ml_date_cnt].patient[ml_pat_cnt].notes[ml_notes_cnt].
   s_note_event = uar_get_code_display(c.event_cd),
   rec_str->date[ml_date_cnt].patient[ml_pat_cnt].notes[ml_notes_cnt].s_note = build(
    uar_get_code_display(c.event_cd),"(",c.event_title_text,")"), rec_str->date[ml_date_cnt].patient[
   ml_pat_cnt].notes[ml_notes_cnt].s_performed_tm = format(c.performed_dt_tm,"hh:mm;;q")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->date,5))),
   dummyt d2,
   person_alias pa
  PLAN (d1
   WHERE maxrec(d2,size(rec_str->date[d1.seq].patient,5)))
   JOIN (d2)
   JOIN (pa
   WHERE (pa.person_id=rec_str->date[d1.seq].patient[d2.seq].f_person_id)
    AND pa.person_alias_type_cd=mf_mrn_cd)
  DETAIL
   rec_str->date[d1.seq].patient[d2.seq].s_mrn = trim(pa.alias)
  WITH nocounter
 ;end select
 SET d0 = headreport(rpt_render)
 FOR (ml_date_cnt = 1 TO size(rec_str->date,5))
   FOR (ml_pat_cnt = 1 TO size(rec_str->date[ml_date_cnt].patient,5))
     SET d0 = patientdetails(rpt_render)
     IF (_yoffset > 11
      AND ml_page_brk=0)
      SET d0 = pagebreak(0)
      SET d0 = headreport(rpt_render)
     ENDIF
     FOR (ml_notes_cnt = 1 TO size(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].notes,5))
       CALL echo(rec_str->date[ml_date_cnt].s_date)
       CALL echo(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].s_patient_name)
       CALL echo(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].s_mrn)
       CALL echo(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].notes[ml_notes_cnt].s_note)
       CALL echo(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].notes[ml_notes_cnt].s_note_event)
       CALL echo(rec_str->date[ml_date_cnt].patient[ml_pat_cnt].notes[ml_notes_cnt].s_performed_tm)
       SET d0 = patientnotes(rpt_render)
       IF (_yoffset > 11)
        SET d0 = pagebreak(0)
        SET d0 = headreport(rpt_render)
        SET ml_page_brk = 1
       ENDIF
     ENDFOR
     IF (ml_page_brk != 1)
      SET d0 = patientseperator(rpt_render)
     ENDIF
     SET ml_page_brk = 0
   ENDFOR
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
#exit_script
END GO
