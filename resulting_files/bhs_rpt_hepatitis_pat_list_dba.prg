CREATE PROGRAM bhs_rpt_hepatitis_pat_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD rec_str
 RECORD rec_str(
   1 patients[*]
     2 s_patient_name = vc
     2 f_person_id = f8
     2 s_mrn = vc
     2 s_unique = vc
     2 s_birth_dt_tm = vc
     2 encntr[*]
       3 f_encntr_id = f8
       3 f_pcp_person_id = f8
       3 s_pcp_name_full = vc
       3 s_full_location = vc
       3 s_result = vc
       3 s_unit = vc
       3 s_comp_result = vc
       3 s_end_dt_tm = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_hepatitis_event_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISCRNAPCRQUANTITATIVE"))
 DECLARE ml_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_username = vc WITH protect, noconstant("")
 DECLARE ms_report_title = vc WITH protect, noconstant("")
 DECLARE ms_date_printed = vc WITH protect, noconstant("")
 DECLARE ms_page_number = vc WITH protect, noconstant("")
 DECLARE ms_report_name = vc WITH protect, noconstant("")
 DECLARE ms_patient_name = vc WITH protect, noconstant("")
 DECLARE ms_mrn = vc WITH protect, noconstant("")
 DECLARE ms_location = vc WITH protect, noconstant("")
 DECLARE ms_result = vc WITH protect, noconstant("")
 DECLARE ms_pcp_name = vc WITH protect, noconstant("")
 DECLARE ms_event_dt_tm = vc WITH protect, noconstant("")
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpage(ncalc=i2) = f8 WITH protect
 DECLARE headpageabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE details(ncalc=i2) = f8 WITH protect
 DECLARE detailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpage(ncalc=i2) = f8 WITH protect
 DECLARE footpageabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE headpage(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpageabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.200000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.052)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.323
    SET _oldfont = uar_rptsetfont(_hreport,_times16b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_report_title,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_date_printed,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 7.010)
    SET rptsd->m_width = 2.990
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_report_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.969
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_patient_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_mrn,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_location,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_result,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_pcp_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 8.875)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_event_dt_tm,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.068),(offsetx+ 10.031),(offsety
     + 1.068))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curtime,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE details(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __patients_s_patient_name = vc WITH noconstant(build2(rec_str->patients[ml_pat_cnt].
     s_patient_name,char(0))), protect
   DECLARE __patients_s_mrn = vc WITH noconstant(build2(rec_str->patients[ml_pat_cnt].s_mrn,char(0))),
   protect
   DECLARE __encntr_s_full_location = vc WITH noconstant(build2(rec_str->patients[ml_pat_cnt].encntr[
     ml_encntr_cnt].s_full_location,char(0))), protect
   DECLARE __encntr_s_comp_result = vc WITH noconstant(build2(rec_str->patients[ml_pat_cnt].encntr[
     ml_encntr_cnt].s_comp_result,char(0))), protect
   DECLARE __encntr_s_pcp_name_full = vc WITH noconstant(build2(rec_str->patients[ml_pat_cnt].encntr[
     ml_encntr_cnt].s_pcp_name_full,char(0))), protect
   DECLARE __encntr_s_end_dt_tm = vc WITH noconstant(build2(rec_str->patients[ml_pat_cnt].encntr[
     ml_encntr_cnt].s_end_dt_tm,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patients_s_patient_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patients_s_mrn)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encntr_s_full_location)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encntr_s_comp_result)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.438)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encntr_s_pcp_name_full)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.875)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encntr_s_end_dt_tm)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpage(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpageabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 9.188)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "BHS_RPT_HEPATITIS_PAT_LIST"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
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
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET ms_report_title = "Hepatitis Patient List"
 SET ms_date_printed = "Date Printed:"
 SET ms_page_number = "Page Number:"
 SET ms_report_name = concat("Program Name: ",curprog)
 SET ms_patient_name = "Patient Name"
 SET ms_mrn = "MRN#"
 SET ms_location = "Location"
 SET ms_result = "Result"
 SET ms_pcp_name = "PCP Name"
 SET ms_event_dt_tm = "Event Date Time"
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   ms_username = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM encounter e,
   clinical_event ce,
   person p,
   diagnosis d,
   nomenclature n
  PLAN (e
   WHERE e.location_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE display_key="PALMERINFECTIOUSDISEASE"
     AND cdf_meaning="AMBULATORY"))
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_cd=mf_hepatitis_event_cd
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (d
   WHERE d.person_id=p.person_id)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_identifier="B18.2"
    AND n.source_vocabulary_cd > 0)
  ORDER BY p.person_id, e.encntr_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   pat_cnt = 0, encntr_cnt = 0
  HEAD p.person_id
   encntr_cnt = 0, pat_cnt = (pat_cnt+ 1), stat = alterlist(rec_str->patients,pat_cnt),
   rec_str->patients[pat_cnt].f_person_id = p.person_id, rec_str->patients[pat_cnt].s_patient_name =
   substring(1,25,trim(p.name_full_formatted)), rec_str->patients[pat_cnt].s_birth_dt_tm = trim(
    format(p.birth_dt_tm,"MM/DD/YY hh:mm;;q"))
  HEAD e.encntr_id
   encntr_cnt = (encntr_cnt+ 1), stat = alterlist(rec_str->patients[pat_cnt].encntr,encntr_cnt),
   rec_str->patients[pat_cnt].encntr[encntr_cnt].f_encntr_id = e.encntr_id,
   rec_str->patients[pat_cnt].encntr[encntr_cnt].s_result = ce.result_val, rec_str->patients[pat_cnt]
   .encntr[encntr_cnt].s_unit = uar_get_code_display(ce.result_units_cd), rec_str->patients[pat_cnt].
   encntr[encntr_cnt].s_comp_result = build2(trim(ce.result_val)," ",trim(uar_get_code_display(ce
      .result_units_cd))),
   rec_str->patients[pat_cnt].encntr[encntr_cnt].s_end_dt_tm = trim(format(ce.event_end_dt_tm,
     "MM/DD/YY hh:mm;;q")), rec_str->patients[pat_cnt].encntr[encntr_cnt].f_pcp_person_id = ce
   .performed_prsnl_id, rec_str->patients[pat_cnt].encntr[encntr_cnt].s_full_location =
   uar_get_code_description(e.location_cd)
  FOOT  p.person_id
   stat = alterlist(rec_str->patients[pat_cnt].encntr,encntr_cnt)
  FOOT REPORT
   stat = alterlist(rec_str->patients,pat_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rec_str->patients,5))),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=rec_str->patients[d.seq].f_person_id)
    AND pa.person_alias_type_cd=mf_mrn_cd)
  DETAIL
   rec_str->patients[d.seq].s_mrn = pa.alias, rec_str->patients[d.seq].s_unique = build2(trim(rec_str
     ->patients[d.seq].s_patient_name)," ",trim(pa.alias))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  name_full_formatted = trim(p1.name_full_formatted)
  FROM (dummyt d1  WITH seq = value(size(rec_str->patients,5))),
   dummyt d2,
   person p1
  PLAN (d1
   WHERE maxrec(d2,size(rec_str->patients[d1.seq].encntr,5)))
   JOIN (d2)
   JOIN (p1
   WHERE (p1.person_id=rec_str->patients[d1.seq].encntr[d2.seq].f_pcp_person_id))
  DETAIL
   rec_str->patients[d1.seq].encntr[d2.seq].s_pcp_name_full = substring(1,30,name_full_formatted)
  WITH nocounter
 ;end select
 SET d0 = headpage(rpt_render)
 FOR (ml_pat_cnt = 1 TO size(rec_str->patients,5))
   FOR (ml_encntr_cnt = 1 TO size(rec_str->patients[ml_pat_cnt].encntr,5))
     CALL echo(rec_str->patients[ml_pat_cnt].s_patient_name)
     CALL echo(rec_str->patients[ml_pat_cnt].s_mrn)
     CALL echo(rec_str->patients[ml_pat_cnt].encntr[ml_encntr_cnt].s_full_location)
     CALL echo(rec_str->patients[ml_pat_cnt].encntr[ml_encntr_cnt].s_comp_result)
     CALL echo(rec_str->patients[ml_pat_cnt].encntr[ml_encntr_cnt].s_pcp_name_full)
     CALL echo(rec_str->patients[ml_pat_cnt].encntr[ml_encntr_cnt].s_end_dt_tm)
     SET d0 = details(rpt_render)
     IF (_yoffset > 7.5)
      SET d0 = footpage(rpt_render)
      SET d0 = pagebreak(0)
      SET d0 = headpage(rpt_render)
     ENDIF
   ENDFOR
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
#exit_script
END GO
