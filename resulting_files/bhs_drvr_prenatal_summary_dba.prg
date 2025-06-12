CREATE PROGRAM bhs_drvr_prenatal_summary:dba
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.00)
 DECLARE ms_outdev_prmpt = vc WITH protect, noconstant("")
 DECLARE ms_person_id_prmpt = vc WITH protect, noconstant("")
 DECLARE ms_edd_prmpt = vc WITH protect, noconstant("")
 DECLARE ms_prsn_full = vc WITH protect, noconstant("")
 DECLARE ms_mrn = vc WITH protect, noconstant("")
 DECLARE ms_message = vc WITH protect, noconstant(" ")
 DECLARE mn_print_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_file = vc WITH protect, noconstant("")
 DECLARE ms_requestjson = vc WITH protect, noconstant("")
 DECLARE ms_address = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_body = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_dcllen = i4 WITH protect, noconstant(0)
 DECLARE ml_dclstatus = i4 WITH protect, noconstant(0)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times20b0 = i4 WITH noconstant(0), protect
 DECLARE _pen50s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = h WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:bayst_health_logo.jpg")
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
 SUBROUTINE (reportheader(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = reportheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (reportheaderabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.570000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 5.334
    SET rptsd->m_height = 0.438
    SET _oldfont = uar_rptsetfont(_hreport,_times20b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prenatal Summary",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed On:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 3.563)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen50s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.463),(offsetx+ 7.313),(offsety+
     1.463))
    SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:bayst_health_logo.jpg")
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 1.125),(offsety+ 0.000),5.209,
     0.813,1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.261
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curtime,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("@",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (patientdemographic(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientdemographicabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (patientdemographicabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.060000), private
   DECLARE __patientfullname = vc WITH noconstant(build2(ms_prsn_full,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.376
    SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.438)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_mrn,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientfullname)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Message:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 6.688
    SET rptsd->m_height = 1.563
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_message,char(0)))
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
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.407
    SET rptsd->m_height = 0.303
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("End of Report",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_DRVR_PRENATAL_SUMMARY"
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
   SET _stat = _loadimages(0)
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
   SET rptfont->m_pointsize = 20
   SET rptfont->m_bold = rpt_on
   SET _times20b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.050
   SET _pen50s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (size(request->visit,5) > 0)
  IF ((request->visit[1].encntr_id > 0.00))
   CALL echo(build2("****** VISIT ******"))
   SET mf_encntr_id = request->visit[1].encntr_id
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE e.encntr_id=mf_encntr_id)
    HEAD REPORT
     mf_person_id = e.person_id
    WITH nocounter
   ;end select
  ELSE
   SET mn_print_ind = 0
   GO TO exit_script
  ENDIF
 ELSEIF (size(request->person,5) > 0)
  IF ((request->person[1].person_id > 0.00))
   CALL echo(build2("****** PERSON ******"))
   SET mf_person_id = request->person[1].person_id
  ELSE
   SET mn_print_ind = 0
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->output_device > " "))
  SET ms_outdev_prmpt = request->output_device
 ELSE
  SET mn_print_ind = 0
  GO TO exit_script
 ENDIF
 CALL echo(build2("mf_mrn_cd: ",build(mf_mrn_cd)))
 CALL echo(build2("mf_person_id: ",build(mf_person_id)))
 SELECT DISTINCT INTO "nl:"
  FROM person p,
   person_alias mrn
  PLAN (p
   WHERE p.person_id=mf_person_id)
   JOIN (mrn
   WHERE mrn.person_id=p.person_id
    AND mrn.person_alias_type_cd=mf_mrn_cd
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   ms_prsn_full = trim(p.name_full_formatted), ms_mrn = trim(mrn.alias)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pregnancy_instance pi,
   pregnancy_estimate pe
  PLAN (pi
   WHERE pi.person_id=mf_person_id)
   JOIN (pe
   WHERE pe.pregnancy_id=pi.pregnancy_id)
  ORDER BY pi.preg_start_dt_tm DESC
  HEAD REPORT
   ms_edd_prmpt = format(pe.est_delivery_dt_tm,"DD-MMM-YYYY;;D"), ms_person_id_prmpt = concat(
    "VALUE(",build(cnvtint(pi.person_id)),")")
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET mn_print_ind = 1
  SET ms_message = "No active pregnancy found for selected person."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa
  PLAN (dfr
   WHERE trim(dfr.definition,3) IN ("OB Intake - BHS", "OB Ambulatory Visit - BHS",
   "Prenatal Education and Counseling - BHS")
    AND dfr.active_ind=1
    AND dfr.end_effective_dt_tm > sysdate)
   JOIN (dfa
   WHERE dfa.person_id=mf_person_id
    AND dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.flags > 0
    AND dfa.form_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
  HEAD REPORT
   mf_forms_id = dfa.dcp_forms_activity_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET mn_print_ind = 1
  SET ms_message = "No OB Powerform found for selected person."
  GO TO exit_script
 ENDIF
 IF (ms_outdev_prmpt > " "
  AND ms_person_id_prmpt > " "
  AND ms_edd_prmpt > " ")
  SET mn_print_ind = 0
  EXECUTE bhs_rpt_prenatal_summary value(ms_outdev_prmpt), value(ms_person_id_prmpt), value(
   ms_edd_prmpt),
  value(ms_outdev_prmpt)
 ENDIF
#exit_script
 CALL echo(build2("mn_print_ind: ",build(mn_print_ind)))
 IF (mn_print_ind=1)
  CALL echo(build2("ms_outdev_prmpt: ",ms_outdev_prmpt))
  CALL echo(build2("ms_prsn_full: ",ms_prsn_full))
  CALL echo(build2("ms_mrn: ",ms_mrn))
  CALL echo(build2("ms_message: ",ms_message))
  SET d0 = initializereport(0)
  CALL echo("****** InitializeReport(0) ******")
  SET page_size = 9.5
  SET d0 = reportheader(rpt_render)
  CALL echo("****** ReportHeader(Rpt_render) ******")
  SET d0 = patientdemographic(rpt_render)
  CALL echo("****** PatientDemographic(Rpt_render) ******")
  SET _yoffset = page_size
  SET d0 = footreportsection(rpt_render)
  CALL echo("****** FootReportSection(Rpt_render) ******")
  SET d0 = finalizereport(ms_outdev_prmpt)
  CALL echo("****** FinalizeReport(ms_outdev_prmpt) ******")
 ENDIF
END GO
