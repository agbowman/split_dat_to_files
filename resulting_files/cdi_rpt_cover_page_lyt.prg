CREATE PROGRAM cdi_rpt_cover_page_lyt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 RECORD cover_page_lyt(
   1 cover_page_name = vc
   1 pages[*]
     2 sortby[3]
       3 value = vc
     2 person_id = f8
     2 encounter_id = f8
     2 facility_name = vc
     2 org_name = vc
     2 patient_name = vc
     2 birth_dt_tm = dq8
     2 patient_location = vc
     2 admit_dt_tm = dq8
     2 discharge_dt_tm = dq8
     2 parent_alias_cnt = i2
     2 parent_aliases[*]
       3 alias_name = vc
       3 alias_value = vc
 )
 EXECUTE cdi_rpt_cover_page_drvr
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpages_page_nbrsection(ncalc=i2) = f8 WITH protect
 DECLARE headpages_page_nbrsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpages_page_nbrsection(ncalc=i2) = f8 WITH protect
 DECLARE footpages_page_nbrsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT
    cover_page_lyt_cover_page_name = trim(substring(1,30,cover_page_lyt->cover_page_name)),
    pages_facility_name = substring(1,30,cover_page_lyt->pages[d2.seq].facility_name), pages_org_name
     = substring(1,30,cover_page_lyt->pages[d2.seq].org_name),
    pages_person_id = cnvtstring(cover_page_lyt->pages[d2.seq].person_id), pages_encounter_id =
    cnvtstring(cover_page_lyt->pages[d2.seq].encounter_id), pages_patient_name = substring(1,30,
     cover_page_lyt->pages[d2.seq].patient_name),
    pages_birth_dt_tm = trim(format(cover_page_lyt->pages[d2.seq].birth_dt_tm,"@LONGDATETIME;;Q"),3),
    parent_alias_cnt = size(cover_page_lyt->pages[d2.seq].parent_aliases,5), pages_patient_location
     = substring(1,30,cover_page_lyt->pages[d2.seq].patient_location),
    pages_admit_dt_tm = trim(format(cover_page_lyt->pages[d2.seq].admit_dt_tm,"@LONGDATETIME;;Q"),3),
    pages_discharge_dt_tm = trim(format(cover_page_lyt->pages[d2.seq].discharge_dt_tm,
      "@LONGDATETIME;;Q"),3), pages_sort_val_1 = substring(1,30,cover_page_lyt->pages[d2.seq].sortby[
     1].value),
    pages_sort_val_2 = substring(1,30,cover_page_lyt->pages[d2.seq].sortby[2].value),
    pages_sort_val_3 = substring(1,30,cover_page_lyt->pages[d2.seq].sortby[3].value)
    FROM (dummyt d2  WITH seq = value(size(cover_page_lyt->pages,5)))
    PLAN (d2)
    ORDER BY pages_sort_val_1, pages_sort_val_2, pages_sort_val_3
    HEAD REPORT
     _d0 = d2.seq, _d1 = cover_page_lyt_cover_page_name, _d2 = pages_facility_name,
     _d3 = pages_org_name, _d4 = pages_person_id, _d5 = pages_encounter_id,
     _d6 = pages_patient_name, _d7 = pages_birth_dt_tm, _d8 = parent_alias_cnt,
     _d9 = pages_patient_location, _d10 = pages_admit_dt_tm, _d11 = pages_discharge_dt_tm,
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    HEAD pages_sort_val_1
     row + 0
    HEAD pages_sort_val_2
     row + 0
    HEAD pages_sort_val_3
     row + 0
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  pages_sort_val_3
     row + 0
    FOOT  pages_sort_val_2
     row + 0
    FOOT  pages_sort_val_1
     row + 0
    WITH nocounter, separator = " ", format
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
 SUBROUTINE headpages_page_nbrsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpages_page_nbrsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpages_page_nbrsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(8.690000), private
   DECLARE __txtdateofbirth = vc WITH noconstant(build2(trim(pages_birth_dt_tm),char(0))), protect
   DECLARE __patientname = vc WITH noconstant(build2(trim(pages_patient_name),char(0))), protect
   DECLARE __txtadmitdate = vc WITH noconstant(build2(trim(pages_admit_dt_tm),char(0))), protect
   DECLARE __txtdischargedate = vc WITH noconstant(build2(trim(pages_discharge_dt_tm),char(0))),
   protect
   DECLARE __txtfield01 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 0) cover_page_lyt->pages[d2.seq].parent_aliases[1].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield01 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 0) build(cover_page_lyt->pages[d2.seq].parent_aliases[1].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield04 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 3) cover_page_lyt->pages[d2.seq].parent_aliases[4].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield04 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 3) build(cover_page_lyt->pages[d2.seq].parent_aliases[4].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield03 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 2) cover_page_lyt->pages[d2.seq].parent_aliases[3].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield03 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 2) build(cover_page_lyt->pages[d2.seq].parent_aliases[3].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield02 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 1) cover_page_lyt->pages[d2.seq].parent_aliases[2].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield02 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 1) build(cover_page_lyt->pages[d2.seq].parent_aliases[2].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield05 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 4) cover_page_lyt->pages[d2.seq].parent_aliases[5].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield05 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 4) build(cover_page_lyt->pages[d2.seq].parent_aliases[5].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield06 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 5) cover_page_lyt->pages[d2.seq].parent_aliases[6].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield06 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 5) build(cover_page_lyt->pages[d2.seq].parent_aliases[6].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield07 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 6) cover_page_lyt->pages[d2.seq].parent_aliases[7].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield07 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 6) build(cover_page_lyt->pages[d2.seq].parent_aliases[7].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield08 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 7) cover_page_lyt->pages[d2.seq].parent_aliases[8].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield08 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 7) build(cover_page_lyt->pages[d2.seq].parent_aliases[8].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield09 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 8) cover_page_lyt->pages[d2.seq].parent_aliases[9].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield09 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 8) build(cover_page_lyt->pages[d2.seq].parent_aliases[9].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __txtfield10 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 9) cover_page_lyt->pages[d2.seq].parent_aliases[10].alias_value
     ELSE " "
     ENDIF
     ,char(0))), protect
   DECLARE __lblfield10 = vc WITH noconstant(build2(
     IF (parent_alias_cnt > 9) build(cover_page_lyt->pages[d2.seq].parent_aliases[10].alias_name,":")
     ELSE " "
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Encounter Cover Page",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (pages_encounter_id != "0")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code39,(offsetx+ 0.000),(offsety+ 2.625))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 3.88
     SET rptbce->m_height = 0.38
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(build("*",pages_encounter_id,"*"),char(0)
       ))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (pages_encounter_id != "0")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pages_encounter_id,char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (pages_encounter_id != "0")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Encounter ID:",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pages_org_name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Organization:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtdateofbirth)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.313
    SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientname)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pages_facility_name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Facility Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pages_patient_location,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtadmitdate)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtdischargedate)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Discharge Date:",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code39,(offsetx+ 0.000),(offsety+ 5.125))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 3.88
    SET rptbce->m_height = 0.38
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bprintinterp = 0
    SET rptbce->m_startchar = "*"
    SET rptbce->m_endchar = "*"
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(build("*",pages_person_id,"*"),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pages_person_id,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 4.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Person ID:",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code39,(offsetx+ 0.000),(offsety+ 1.375))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 3.88
    SET rptbce->m_height = 0.38
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bprintinterp = 0
    SET rptbce->m_startchar = "*"
    SET rptbce->m_endchar = "*"
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(build("*",cover_page_lyt_cover_page_name,
       "*"),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cover_page_lyt_cover_page_name,char(0)
      ))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cover Page Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield01)
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield01)
    SET rptsd->m_y = (offsety+ 5.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield04)
    SET rptsd->m_y = (offsety+ 5.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield04)
    SET rptsd->m_y = (offsety+ 4.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield03)
    SET rptsd->m_y = (offsety+ 4.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield03)
    SET rptsd->m_y = (offsety+ 4.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield02)
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield02)
    SET rptsd->m_y = (offsety+ 5.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield05)
    SET rptsd->m_y = (offsety+ 5.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield05)
    SET rptsd->m_y = (offsety+ 6.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield06)
    SET rptsd->m_y = (offsety+ 6.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield06)
    SET rptsd->m_y = (offsety+ 6.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield07)
    SET rptsd->m_y = (offsety+ 6.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield07)
    SET rptsd->m_y = (offsety+ 7.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield08)
    SET rptsd->m_y = (offsety+ 7.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield08)
    SET rptsd->m_y = (offsety+ 7.938)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield09)
    SET rptsd->m_y = (offsety+ 7.750)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield09)
    SET rptsd->m_y = (offsety+ 8.438)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtfield10)
    SET rptsd->m_y = (offsety+ 8.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lblfield10)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpages_page_nbrsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpages_page_nbrsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpages_page_nbrsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CDI_RPT_COVER_PAGE_LYT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
    FROM output_dest o,
     device d,
     printer p
    PLAN (o
     WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
     JOIN (d
     WHERE d.device_cd=o.device_cd)
     JOIN (p
     WHERE p.device_cd=d.device_cd)
    DETAIL
     CASE (cnvtint(p_printer_type_cdf))
      OF 8:
      OF 26:
      OF 29:
       _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
      OF 16:
      OF 20:
      OF 24:
       _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
      OF 42:
       _outputtype = rpt_zebra300,_xdiv = 300,_ydiv = 300
      OF 43:
       _outputtype = rpt_zebra600,_xdiv = 600,_ydiv = 600
      OF 32:
      OF 18:
      OF 19:
      OF 27:
      OF 31:
       _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
      ELSE
       _xdiv = 1,_ydiv = 1
     ENDCASE
     _diotype = cnvtint(p_printer_type_cdf), _sendto = d.name
     IF (_xdiv > 1)
      rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
     ENDIF
     IF (_xdiv > 1)
      rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
     ENDIF
    WITH nocounter
   ;end select
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
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
