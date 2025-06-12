CREATE PROGRAM bhs_rpt_bed_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Nurse Unit" = 0
  WITH outdev, f_facility_cd, f_nurse_unit_cd
 FREE RECORD m_rec
 RECORD m_rec(
   1 bed[*]
     2 s_nurse_unit = vc
     2 s_room_loc = vc
     2 s_loc = vc
     2 f_bed_location_code = f8
     2 s_patient_name = vc
     2 s_patient_dob = vc
     2 s_admit_date = vc
     2 s_mrn = vc
     2 s_fin_number = vc
     2 s_attend_doc = vc
     2 s_pcp = vc
     2 f_encounter_id = f8
     2 f_person_id = f8
     2 s_reason = vc
     2 s_encounter_type = vc
     2 n_days = i2
     2 s_patient_age = vc
     2 n_diag_count = i2
     2 diagnosis[*]
       3 s_source_string = vc
 )
 DECLARE mf_active_bed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_attend_doc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_nbr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_working_diag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",17,"WORKING"))
 DECLARE mf_reason_for_visit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",17,
   "REASONFORVISIT"))
 DECLARE mf_admit_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITINPATIENTSERVICE"))
 DECLARE mf_assign_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ASSIGNOBSERVATIONSTATUS"))
 DECLARE mf_select_admit_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTADMITINPATIENTSERVICE"))
 DECLARE mf_select_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTOBSERVATIONSTATUS"))
 DECLARE mf_change_patient_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSCHANGEPATIENTTYPETO"))
 DECLARE mf_status_daystay_patient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSDAYSTAYPATIENT"))
 DECLARE mf_status_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSINPATIENT"))
 DECLARE mf_observation_patient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSOBSERVATIONPATIENT"))
 DECLARE ml_index = i4 WITH protect, noconstant(0)
 DECLARE ml_bed_count = i4 WITH protect, noconstant(0)
 DECLARE mn_diag_count = i2 WITH protect, noconstant(0)
 DECLARE ms_username = vc WITH protect, noconstant(" ")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE diagnosissection(ncalc=i2) = f8 WITH protect
 DECLARE diagnosissectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE emptyspacesection(ncalc=i2) = f8 WITH protect
 DECLARE emptyspacesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE nobedsection(ncalc=i2) = f8 WITH protect
 DECLARE nobedsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica8b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen14s2c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __username = vc WITH noconstant(build2(concat("For: ",ms_username),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.552
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.073)
    SET rptsd->m_width = 0.354
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.802)
    SET rptsd->m_width = 0.510
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.427)
    SET rptsd->m_width = 0.479
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct#",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.177)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.677)
    SET rptsd->m_width = 0.490
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Day",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.552)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.552)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.052)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__username)
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
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE __location = vc WITH noconstant(build2(concat(trim(m_rec->bed[ml_bed_count].s_nurse_unit),
      " ",trim(m_rec->bed[ml_bed_count].s_room_loc),"- ",trim(m_rec->bed[ml_bed_count].s_loc)),char(0
      ))), protect
   DECLARE __name = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_patient_name,char(0))),
   protect
   DECLARE __mrn = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_mrn,char(0))), protect
   DECLARE __acctnum = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_fin_number,char(0))),
   protect
   DECLARE __dob = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_patient_dob,char(0))),
   protect
   DECLARE __admit_date = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_admit_date,char(0))),
   protect
   DECLARE __attend_doc = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_attend_doc,char(0))),
   protect
   IF ((m_rec->bed[ml_bed_count].s_pcp != null))
    DECLARE __pcp = vc WITH noconstant(build2(concat("PCP: ",m_rec->bed[ml_bed_count].s_pcp),char(0))
     ), protect
   ENDIF
   IF ((m_rec->bed[ml_bed_count].s_admit_date != null))
    DECLARE __day = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].n_days,char(0))), protect
   ENDIF
   IF ((m_rec->bed[ml_bed_count].s_patient_dob != null))
    DECLARE __age = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_patient_age,char(0))),
    protect
   ENDIF
   IF ((m_rec->bed[ml_bed_count].f_person_id != null))
    DECLARE __encounter_type = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_encounter_type,
      char(0))), protect
   ENDIF
   IF ((m_rec->bed[ml_bed_count].f_person_id != null))
    DECLARE __reason_for_visit = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].s_reason,char(0))
     ), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.500),(offsety+
     0.058))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica8b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__location)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 0.740
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acctnum)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_date)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attend_doc)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.198
    IF ((m_rec->bed[ml_bed_count].s_pcp != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp)
    ENDIF
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.438)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.313
    IF ((m_rec->bed[ml_bed_count].s_admit_date != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__day)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.260
    IF ((m_rec->bed[ml_bed_count].s_patient_dob != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    IF ((m_rec->bed[ml_bed_count].f_person_id != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encounter_type)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 4.521
    SET rptsd->m_height = 0.146
    IF ((m_rec->bed[ml_bed_count].f_person_id != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reason_for_visit)
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE diagnosissection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = diagnosissectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE diagnosissectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ((m_rec->bed[ml_bed_count].f_person_id != null)
    AND size(m_rec->bed[ml_bed_count].diagnosis,5) >= 1)
    DECLARE __diagnosis = vc WITH noconstant(build2(m_rec->bed[ml_bed_count].diagnosis[mn_diag_count]
      .s_source_string,char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 5.438
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF ((m_rec->bed[ml_bed_count].f_person_id != null)
     AND size(m_rec->bed[ml_bed_count].diagnosis,5) >= 1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__diagnosis)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.167
    IF ((m_rec->bed[ml_bed_count].f_person_id != null)
     AND size(m_rec->bed[ml_bed_count].diagnosis,5) >= 1
     AND mn_diag_count=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Working Diagnosis:",char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE emptyspacesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = emptyspacesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE emptyspacesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __pageno = vc WITH noconstant(build2(concat(rpt_pageofpage," ",format(cnvtdatetime(curdate,
        curtime),"mm/dd/yyyy hh:mm;;q")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pageno)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE nobedsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = nobedsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE nobedsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.271
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Sorry, no beds were found in the selected nurse units.",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_BED_REPORT"
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
   SET rptfont->m_fontname = rpt_helvetica
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_on
   SET _helvetica8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 2
   SET _pen14s2c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SELECT
  IF (( $F_NURSE_UNIT_CD=0))
   PLAN (nu
    WHERE nu.location_cd > 0
     AND (nu.loc_facility_cd= $F_FACILITY_CD)
     AND nu.active_ind=1
     AND nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (r
    WHERE r.loc_nurse_unit_cd=nu.location_cd
     AND r.active_ind=1
     AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (b
    WHERE b.loc_room_cd=r.location_cd
     AND b.active_status_cd=mf_active_bed_cd
     AND b.active_ind=1
     AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ELSE
  ENDIF
  INTO "nl:"
  room = uar_get_code_display(r.location_cd)
  FROM nurse_unit nu,
   room r,
   bed b
  PLAN (nu
   WHERE (nu.location_cd= $F_NURSE_UNIT_CD)
    AND (nu.loc_facility_cd= $F_FACILITY_CD)
    AND nu.active_ind=1
    AND nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (r
   WHERE r.loc_nurse_unit_cd=nu.location_cd
    AND r.active_ind=1
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (b
   WHERE b.loc_room_cd=r.location_cd
    AND b.active_status_cd=mf_active_bed_cd
    AND b.active_ind=1
    AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY nu.location_cd DESC, room
  HEAD REPORT
   ml_bed_count = 0
  HEAD b.location_cd
   ml_bed_count = (ml_bed_count+ 1), stat = alterlist(m_rec->bed,ml_bed_count), m_rec->bed[
   ml_bed_count].s_nurse_unit = uar_get_code_display(nu.location_cd),
   m_rec->bed[ml_bed_count].s_room_loc = uar_get_code_display(b.loc_room_cd), m_rec->bed[ml_bed_count
   ].s_loc = uar_get_code_display(b.location_cd), m_rec->bed[ml_bed_count].f_bed_location_code = b
   .location_cd
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET d0 = nobedsection(rpt_render)
  SET d0 = finalizereport( $OUTDEV)
  GO TO exit_script
 ENDIF
 SELECT INTO "n1:"
  FROM encounter e
  PLAN (e
   WHERE expand(ml_bed_count,1,size(m_rec->bed,5),e.location_cd,m_rec->bed[ml_bed_count].
    f_bed_location_code)
    AND e.active_ind=1
    AND e.reg_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.disch_dt_tm = null)
  HEAD REPORT
   ml_index = 0, ml_bed_count = 0
  DETAIL
   ml_index = locateval(ml_bed_count,1,size(m_rec->bed,5),e.location_cd,m_rec->bed[ml_bed_count].
    f_bed_location_code), m_rec->bed[ml_bed_count].f_encounter_id = e.encntr_id, m_rec->bed[
   ml_bed_count].f_person_id = e.person_id,
   m_rec->bed[ml_bed_count].s_encounter_type = uar_get_code_display(e.encntr_type_cd)
 ;end select
 SELECT INTO "n1:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_bed_count,1,size(m_rec->bed,5),o.encntr_id,m_rec->bed[ml_bed_count].f_encounter_id
    )
    AND o.catalog_cd IN (mf_admit_inpatient_cd, mf_assign_observation_cd,
   mf_select_admit_inpatient_cd, mf_select_observation_cd, mf_change_patient_type_cd,
   mf_status_daystay_patient_cd, mf_status_inpatient_cd, mf_observation_patient_cd))
  ORDER BY o.encntr_id, o.orig_order_dt_tm
  HEAD REPORT
   ml_index = 0, ml_bed_count = 0
  HEAD o.encntr_id
   ml_index = locateval(ml_bed_count,1,size(m_rec->bed,5),o.encntr_id,m_rec->bed[ml_bed_count].
    f_encounter_id), m_rec->bed[ml_index].s_encounter_type = concat(trim(m_rec->bed[ml_index].
     s_encounter_type,3)," ",trim(format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q"),3))
  WITH nocounter
 ;end select
 SELECT INTO "n1:"
  FROM encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   encntr_prsnl_reltn epr,
   person_prsnl_reltn ppr,
   prsnl pl,
   prsnl pl2
  PLAN (e
   WHERE expand(ml_bed_count,1,size(m_rec->bed,5),e.encntr_id,m_rec->bed[ml_bed_count].f_encounter_id
    ))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_nbr_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_mrn_cd
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null))
    AND epr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ppr
   WHERE ppr.person_id=e.person_id
    AND ppr.person_prsnl_r_cd=mf_pcp_cd
    AND ppr.beg_effective_dt_tm <= cnvtdatetime((curdate+ 1),curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ppr.active_ind=1)
   JOIN (pl
   WHERE epr.prsnl_person_id=pl.person_id)
   JOIN (pl2
   WHERE ppr.prsnl_person_id=pl2.person_id)
  HEAD REPORT
   ml_index = 0, ml_bed_count = 0
  DETAIL
   ml_index = locateval(ml_bed_count,1,size(m_rec->bed,5),e.encntr_id,m_rec->bed[ml_bed_count].
    f_encounter_id), m_rec->bed[ml_index].s_patient_name = p.name_full_formatted, m_rec->bed[ml_index
   ].s_patient_dob = format(p.birth_dt_tm,"mm/dd/yy ;;q"),
   m_rec->bed[ml_index].s_admit_date = format(e.reg_dt_tm,"mm/dd/yy hh:mm ;;q"), m_rec->bed[ml_index]
   .s_fin_number = ea.alias, m_rec->bed[ml_index].s_mrn = ea2.alias,
   m_rec->bed[ml_index].s_attend_doc = pl.name_full_formatted, m_rec->bed[ml_index].s_pcp = pl2
   .name_full_formatted, m_rec->bed[ml_index].n_days = (datetimediff(cnvtdatetime(curdate,curtime),e
    .reg_dt_tm)+ 1),
   m_rec->bed[ml_index].s_patient_age = cnvtage(p.birth_dt_tm), m_rec->bed[ml_index].s_reason =
   concat("Chief Complaint: ",e.reason_for_visit)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_bed_count,1,size(m_rec->bed,5),d.encntr_id,m_rec->bed[ml_bed_count].f_encounter_id
    )
    AND d.diag_type_cd=mf_reason_for_visit_cd
    AND d.active_ind=1
    AND d.nomenclature_id != 22257033.00)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.active_ind=1)
  ORDER BY d.encntr_id, n.source_string
  HEAD REPORT
   ml_index = 0, ml_bed_count = 0
  HEAD d.encntr_id
   ml_index = locateval(ml_bed_count,1,size(m_rec->bed,5),d.encntr_id,m_rec->bed[ml_bed_count].
    f_encounter_id), m_rec->bed[ml_index].s_reason = ""
  DETAIL
   IF (size(trim(m_rec->bed[ml_index].s_reason,3))=0)
    m_rec->bed[ml_index].s_reason = concat("Reason for Visit: ",n.source_string)
   ELSE
    m_rec->bed[ml_index].s_reason = concat(m_rec->bed[ml_index].s_reason,", ",n.source_string)
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE expand(ml_bed_count,1,size(m_rec->bed,5),d.encntr_id,m_rec->bed[ml_bed_count].f_encounter_id
    )
    AND d.diag_type_cd=mf_working_diag_cd
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id)
    AND n.active_ind=outerjoin(1))
  ORDER BY d.encntr_id, d.diag_dt_tm DESC
  HEAD REPORT
   ml_index = 0, ml_bed_count = 0
  HEAD d.encntr_id
   ml_index = locateval(ml_bed_count,1,size(m_rec->bed,5),d.encntr_id,m_rec->bed[ml_bed_count].
    f_encounter_id), m_rec->bed[ml_index].n_diag_count = 0
  DETAIL
   m_rec->bed[ml_index].n_diag_count = (m_rec->bed[ml_index].n_diag_count+ 1), stat = alterlist(m_rec
    ->bed[ml_index].diagnosis,m_rec->bed[ml_index].n_diag_count), m_rec->bed[ml_index].diagnosis[
   m_rec->bed[ml_index].n_diag_count].s_source_string = n.source_string
   IF ((m_rec->bed[ml_index].s_reason="Chief Complaint:*"))
    m_rec->bed[ml_index].s_reason = ""
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   ms_username = p.name_full_formatted
  WITH nocounter
 ;end select
 SET d0 = headpagesection(rpt_render)
 FOR (ml_bed_count = 1 TO size(m_rec->bed,5))
   SET mn_diag_count = 1
   IF ((((((_yoffset+ detailsection(rpt_calcheight))+ (diagnosissection(rpt_calcheight) * m_rec->bed[
   ml_bed_count].n_diag_count))+ emptyspacesection(rpt_calcheight))+ footpagesection(rpt_calcheight))
    > 10.5))
    SET d0 = footpagesection(rpt_render)
    SET d0 = pagebreak(0)
    SET d0 = headpagesection(rpt_render)
   ENDIF
   SET d0 = detailsection(rpt_render)
   FOR (mn_diag_count = 1 TO size(m_rec->bed[ml_bed_count].diagnosis,5))
    IF ((((_yoffset+ diagnosissection(rpt_calcheight))+ footpagesection(rpt_calcheight)) > 10.5))
     SET d0 = footpagesection(rpt_render)
     SET d0 = pagebreak(0)
     SET d0 = headpagesection(rpt_render)
    ENDIF
    SET d0 = diagnosissection(rpt_render)
   ENDFOR
   SET d0 = emptyspacesection(rpt_render)
 ENDFOR
 SET d0 = finalizereport( $OUTDEV)
#exit_script
 FREE RECORD m_rec
END GO
