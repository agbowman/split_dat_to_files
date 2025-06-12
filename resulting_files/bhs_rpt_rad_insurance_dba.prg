CREATE PROGRAM bhs_rpt_rad_insurance:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Appt Start Date:" = "CURDATE",
  "Appt End Date:" = "CURDATE",
  "Appointment Location" = 0
  WITH outdev, ms_start_date, ms_end_date,
  mf_appt_loc
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DATE,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD s_data
 RECORD s_data(
   1 l_cnt = i4
   1 qual[*]
     2 f_sch_event_id = f8
     2 f_appt_id = f8
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_appt_date = f8
     2 s_appt_status = vc
     2 s_pat_name = vc
     2 f_pat_dob = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_appt_type = vc
     2 s_appt_loc = vc
     2 l_ocnt = i4
     2 oqual[*]
       3 f_order_id = f8
       3 f_catalog_cd = f8
       3 s_order_disp = vc
       3 s_order_appt_status = vc
       3 s_order_status = vc
       3 f_order_dt = f8
       3 s_provider_name = vc
     2 l_icnt = i4
     2 iqual[*]
       3 f_health_plan_id = f8
       3 s_plan_name = vc
       3 s_priority = vc
 ) WITH protect
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 DECLARE _times90 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times9b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (sec_title(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_titleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_titleabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 3.552
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Radiology Insurance Report",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_appt_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_appt_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_appt_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times9b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Date",char(0)))
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Location",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.322),(offsetx+ 7.479),(offsety+
     0.322))
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Status",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Type",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_appt_detail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_appt_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_appt_detailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE __sad_patname = vc WITH noconstant(build2(s_data->qual[ml_idx].s_pat_name,char(0))),
   protect
   DECLARE __sad_mrn = vc WITH noconstant(build2(s_data->qual[ml_idx].s_mrn,char(0))), protect
   DECLARE __sad_apptdate = vc WITH noconstant(build2(format(s_data->qual[ml_idx].f_appt_date,
      "MM/DD/YY;;q"),char(0))), protect
   DECLARE __sad_apptloc = vc WITH noconstant(build2(s_data->qual[ml_idx].s_appt_loc,char(0))),
   protect
   DECLARE __sad_apptstat = vc WITH noconstant(build2(s_data->qual[ml_idx].s_appt_status,char(0))),
   protect
   DECLARE __sad_appttype = vc WITH noconstant(build2(s_data->qual[ml_idx].s_appt_type,char(0))),
   protect
   DECLARE __sad_apptdate1 = vc WITH noconstant(build2(format(s_data->qual[ml_idx].f_pat_dob,
      "MM/DD/YY;;q"),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.073)
    SET rptsd->m_width = 1.740
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_patname)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_mrn)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_apptdate)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_apptloc)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 0.313),(offsetx+ 7.532),(offsety+
     0.313))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_apptstat)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.125)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_appttype)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_apptdate1)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_order_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_order_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_order_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times9b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 0.958
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Provider",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Date",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.375),(offsety+ 0.322),(offsetx+ 7.417),(offsety+
     0.322))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Status",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_order_detail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_order_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_order_detailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __sad_order_name = vc WITH noconstant(build2(s_data->qual[ml_idx].oqual[ml_idx1].
     s_order_disp,char(0))), protect
   DECLARE __sad_order_provider = vc WITH noconstant(build2(s_data->qual[ml_idx].oqual[ml_idx1].
     s_provider_name,char(0))), protect
   DECLARE __sad_order_status = vc WITH noconstant(build2(s_data->qual[ml_idx].oqual[ml_idx1].
     s_order_status,char(0))), protect
   DECLARE __sad_order_date = vc WITH noconstant(build2(format(s_data->qual[ml_idx].oqual[ml_idx1].
      f_order_dt,"MM/DD/YY;;q"),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.438)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_order_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_order_provider)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_order_status)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sad_order_date)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.313),(offsety+ 0.208),(offsetx+ 7.407),(offsety+
     0.208))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_ins_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_ins_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_ins_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times9b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insurance Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 0.958
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Priority",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.375),(offsety+ 0.322),(offsetx+ 7.417),(offsety+
     0.322))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_ins_detail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_ins_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_ins_detailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __sid_ins_name = vc WITH noconstant(build2(s_data->qual[ml_idx].iqual[ml_idx1].s_plan_name,
     char(0))), protect
   DECLARE __sid_ins_priority = vc WITH noconstant(build2(s_data->qual[ml_idx].iqual[ml_idx1].
     s_priority,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sid_ins_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sid_ins_priority)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),(offsety+ 0.219),(offsetx+ 7.344),(offsety+
     0.219))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_RAD_INSURANCE"
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
   SET rptfont->m_pointsize = 12
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_on
   SET _times9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times90 = uar_rptcreatefont(_hreport,rptfont)
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
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   encntr_alias ea1,
   encntr_alias ea2,
   sch_event_attach sea,
   orders ord,
   person p,
   order_action oa,
   prsnl pr
  PLAN (sa
   WHERE (sa.appt_location_cd= $MF_APPT_LOC)
    AND sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND sa.role_meaning="PATIENT"
    AND sa.state_meaning IN ("CONFIRMED", "CHECKED IN", "CHECKED OUT", "SCHEDULED", "PENDING")
    AND sa.sch_event_id != 0
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.active_ind=1)
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(sa.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_ea_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(sa.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (sea
   WHERE (sea.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sea.attach_type_meaning= Outerjoin("ORDER")) )
   JOIN (ord
   WHERE (ord.order_id= Outerjoin(sea.order_id)) )
   JOIN (p
   WHERE p.person_id=sa.person_id)
   JOIN (oa
   WHERE (oa.order_id= Outerjoin(ord.order_id))
    AND (oa.action_sequence= Outerjoin(1)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(oa.order_provider_id)) )
  ORDER BY sa.beg_dt_tm, sa.sch_event_id, ord.order_id
  HEAD REPORT
   s_data->l_cnt = 0
  HEAD sa.sch_event_id
   s_data->l_cnt += 1, stat = alterlist(s_data->qual,s_data->l_cnt), s_data->qual[s_data->l_cnt].
   f_appt_id = sa.sch_appt_id,
   s_data->qual[s_data->l_cnt].f_encntr_id = sa.encntr_id, s_data->qual[s_data->l_cnt].f_person_id =
   sa.person_id, s_data->qual[s_data->l_cnt].f_pat_dob = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
     .birth_tz),1),
   s_data->qual[s_data->l_cnt].f_sch_event_id = sa.sch_event_id, s_data->qual[s_data->l_cnt].
   s_appt_loc = uar_get_code_display(sa.appt_location_cd), s_data->qual[s_data->l_cnt].s_appt_type =
   uar_get_code_display(se.appt_type_cd),
   s_data->qual[s_data->l_cnt].s_fin = trim(ea2.alias,3), s_data->qual[s_data->l_cnt].s_mrn = trim(
    ea1.alias,3), s_data->qual[s_data->l_cnt].s_appt_status = uar_get_code_display(se.sch_state_cd),
   s_data->qual[s_data->l_cnt].s_pat_name = p.name_full_formatted, s_data->qual[s_data->l_cnt].
   f_appt_date = sa.beg_dt_tm, s_data->qual[s_data->l_cnt].l_ocnt = 0
  HEAD ord.order_id
   s_data->qual[s_data->l_cnt].l_ocnt += 1, stat = alterlist(s_data->qual[s_data->l_cnt].oqual,s_data
    ->qual[s_data->l_cnt].l_ocnt), s_data->qual[s_data->l_cnt].oqual[s_data->qual[s_data->l_cnt].
   l_ocnt].f_order_id = ord.order_id,
   s_data->qual[s_data->l_cnt].oqual[s_data->qual[s_data->l_cnt].l_ocnt].f_catalog_cd = ord
   .catalog_cd, s_data->qual[s_data->l_cnt].oqual[s_data->qual[s_data->l_cnt].l_ocnt].s_order_disp =
   trim(ord.order_mnemonic,3), s_data->qual[s_data->l_cnt].oqual[s_data->qual[s_data->l_cnt].l_ocnt].
   s_order_appt_status = sea.order_status_meaning,
   s_data->qual[s_data->l_cnt].oqual[s_data->qual[s_data->l_cnt].l_ocnt].s_order_status =
   uar_get_code_display(ord.order_status_cd), s_data->qual[s_data->l_cnt].oqual[s_data->qual[s_data->
   l_cnt].l_ocnt].f_order_dt = ord.orig_order_dt_tm, s_data->qual[s_data->l_cnt].oqual[s_data->qual[
   s_data->l_cnt].l_ocnt].s_provider_name = trim(pr.name_full_formatted,3)
  WITH nocounter
 ;end select
 IF ((s_data->l_cnt > 0))
  FOR (ml_idx = 1 TO s_data->l_cnt)
    SELECT INTO "nl:"
     FROM encntr_plan_reltn epr,
      health_plan hp
     PLAN (epr
      WHERE (epr.encntr_id=s_data->qual[ml_idx].f_encntr_id)
       AND (epr.person_id=s_data->qual[ml_idx].f_person_id)
       AND epr.active_ind=1
       AND epr.end_effective_dt_tm > sysdate)
      JOIN (hp
      WHERE hp.health_plan_id=epr.health_plan_id)
     ORDER BY epr.priority_seq
     HEAD REPORT
      s_data->qual[ml_idx].l_icnt = 0
     DETAIL
      s_data->qual[ml_idx].l_icnt += 1, stat = alterlist(s_data->qual[ml_idx].iqual,s_data->qual[
       ml_idx].l_icnt), s_data->qual[ml_idx].iqual[s_data->qual[ml_idx].l_icnt].f_health_plan_id =
      epr.health_plan_id,
      s_data->qual[ml_idx].iqual[s_data->qual[ml_idx].l_icnt].s_plan_name = hp.plan_name, s_data->
      qual[ml_idx].iqual[s_data->qual[ml_idx].l_icnt].s_priority = trim(cnvtstring(epr.priority_seq),
       3)
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 EXECUTE reportrtl
 SET d0 = sec_title(rpt_render)
 IF ((s_data->l_cnt > 0))
  SET d0 = sec_appt_header(rpt_render)
  FOR (ml_idx = 1 TO s_data->l_cnt)
    SET mf_rem_space = (mf_page_size - (_yoffset+ sec_appt_header(rpt_calcheight)))
    IF (mf_rem_space <= 0.25)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
    ENDIF
    SET d0 = sec_appt_header(rpt_render)
    SET mf_rem_space = (mf_page_size - (_yoffset+ sec_appt_detail(rpt_calcheight)))
    IF (mf_rem_space <= 0.25)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
    ENDIF
    SET d0 = sec_appt_detail(rpt_render)
    SET mf_rem_space = (mf_page_size - (_yoffset+ sec_order_header(rpt_calcheight)))
    IF (mf_rem_space <= 0.25)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
    ENDIF
    SET d0 = sec_order_header(rpt_render)
    IF ((s_data->qual[ml_idx].l_ocnt > 0))
     FOR (ml_idx1 = 1 TO s_data->qual[ml_idx].l_ocnt)
       SET mf_rem_space = (mf_page_size - (_yoffset+ sec_order_detail(rpt_calcheight)))
       IF (mf_rem_space <= 0.25)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
       ENDIF
       SET d0 = sec_order_detail(rpt_render)
     ENDFOR
    ENDIF
    SET mf_rem_space = (mf_page_size - (_yoffset+ sec_ins_header(rpt_calcheight)))
    IF (mf_rem_space <= 0.25)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
    ENDIF
    SET d0 = sec_ins_header(rpt_render)
    IF ((s_data->qual[ml_idx].l_icnt > 0))
     FOR (ml_idx1 = 1 TO s_data->qual[ml_idx].l_icnt)
       SET mf_rem_space = (mf_page_size - (_yoffset+ sec_ins_detail(rpt_calcheight)))
       IF (mf_rem_space <= 0.25)
        SET _yoffset = 10.18
        SET d0 = pagebreak(0)
       ENDIF
       SET d0 = sec_ins_detail(rpt_render)
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET d0 = finalizereport(value( $OUTDEV))
#exit_program
END GO
