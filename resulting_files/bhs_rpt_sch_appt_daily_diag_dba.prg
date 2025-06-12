CREATE PROGRAM bhs_rpt_sch_appt_daily_diag:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Appointment Location:" = 0,
  "Email Spreadsheet:" = ""
  WITH outdev, ms_start_dt, ms_end_dt,
  mf_appt_loc, ms_spreadsheet_email
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DT,"DD-MMM-YYYY"),
   235959))
 DECLARE ms_email = vc WITH protect, constant(trim( $MS_SPREADSHEET_EMAIL,3))
 DECLARE mf_patient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE mf_action_schedule_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14232,"SCHEDULE"
   ))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ms_file_name = vc WITH protect, constant("bhs_appt_qa_diag_rpt.csv")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE ndx = i4 WITH protect, noconstant(0)
 DECLARE ndx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_appt_loc_p = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (sec_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.360000), private
   DECLARE __scheddate = vc WITH noconstant(build2( $MS_START_DT,char(0))), protect
   DECLARE __scheddate1 = vc WITH noconstant(build2( $MS_END_DT,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 1.407
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__scheddate)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.282
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointments scheduled between :",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason for Visit",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Scheduler",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 8.063)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hospital Serv Code",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Location",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 4.313)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Duration",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 3.438)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Date",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pt DOB",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CMRN",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.062)),(offsety+ 2.282),(offsetx+ 9.928),(
     offsety+ 2.282))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appt Type",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Scheduling Comment",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Encounter",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Auth Number",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Insurance",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Secondary Insurance",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Referring Provider",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.282
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("AND",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 1.407
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__scheddate1)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 7.751)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Resource",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (sec_detail(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_detailabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (sec_detailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.610000), private
   DECLARE __patname = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_pat_name,char(0))), protect
   DECLARE __reason = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_reason_for_visit,char(0))),
   protect
   DECLARE __sched = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_sched_user,char(0))), protect
   DECLARE __hospserv = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_med_service,char(0))),
   protect
   DECLARE __duration = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_appt_dur,char(0))), protect
   DECLARE __appttime = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_appt_time,char(0))), protect
   DECLARE __ptdob = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_pat_dob,char(0))), protect
   DECLARE __cmrn = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_cmrn,char(0))), protect
   DECLARE __apptloc = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_appt_loc,char(0))), protect
   DECLARE __appttype = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_appt_type,char(0))), protect
   DECLARE __schcomm = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_sched_comm,char(0))), protect
   DECLARE __encntrid = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].f_encntr_id,char(0))), protect
   DECLARE __authnum = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_auth_nbr,char(0))), protect
   DECLARE __primaryinsnum = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_prim_ins_num,char(0))),
   protect
   DECLARE __primaryinsname = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_prim_ins_name,char(0))
    ), protect
   DECLARE __secondaryinsnum = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_second_ins_num,char(0
      ))), protect
   DECLARE __secondaryinsname = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_second_ins_name,char
     (0))), protect
   DECLARE __referringprovider = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_referring_provider,
     char(0))), protect
   DECLARE __resource = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_resource,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(m_pat->qual[ml_cnt1].s_age,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.771
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 9.126
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reason)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sched)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 8.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hospserv)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__duration)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.376)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__appttime)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ptdob)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cmrn)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 2.532),(offsetx+ 9.991),(offsety+
     2.532))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__apptloc)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__appttype)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 9.126
    SET rptsd->m_height = 0.938
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__schcomm)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encntrid)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__authnum)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primaryinsnum)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primaryinsname)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__secondaryinsnum)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 3.001
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__secondaryinsname)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__referringprovider)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 7.751)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__resource)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_SCH_APPT_DAILY_DIAG"
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
   SET rptfont->m_bold = rpt_on
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
 FREE RECORD m_pat
 RECORD m_pat(
   1 l_cnt = i4
   1 qual[*]
     2 s_pat_name = vc
     2 s_cmrn = vc
     2 s_pat_dob = vc
     2 s_appt_time = vc
     2 s_appt_type = vc
     2 s_appt_dur = vc
     2 s_appt_loc = vc
     2 s_facility = vc
     2 s_nurs_unit = vc
     2 s_med_service = vc
     2 s_sched_user = vc
     2 s_reason_for_visit = vc
     2 s_sched_comm = vc
     2 s_sched_comm2 = vc
     2 f_encntr_id = f8
     2 s_auth_nbr = vc
     2 s_prim_ins_name = vc
     2 s_prim_ins_num = vc
     2 s_second_ins_name = vc
     2 s_second_ins_num = vc
     2 s_referring_provider = vc
     2 s_resource = vc
     2 s_age = vc
     2 s_fin_nbr = vc
     2 s_spec_instruct = vc
 ) WITH protect
 IF (mf_begin_dt_tm > mf_end_dt_tm)
  SET ms_log = " Invalid dates - begin date must be a date prior to end date."
  GO TO exit_script
 ENDIF
 IF (datetimediff(mf_end_dt_tm,mf_begin_dt_tm) > 31)
  SET ms_log = " Invalid dates - begin and end dates must be within 31 days of each other."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(4,0))
 IF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    IF (i=1)
     SET ms_appt_loc_p = build2("sa.appt_location_cd in (",parameter(4,i))
    ELSE
     SET ms_appt_loc_p = build2(ms_appt_loc_p,",",parameter(4,i))
    ENDIF
  ENDFOR
  SET ms_appt_loc_p = concat(ms_appt_loc_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_appt_loc_p = build2("sa.appt_location_cd = ",parameter(4,0))
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   sch_event_action sea,
   sch_event_comm sec,
   sch_event_attach seatt,
   order_detail od,
   order_comment oc,
   long_text l,
   long_text l2,
   encounter e,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   person per,
   person_alias pera,
   prsnl pr,
   prsnl pr2
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
    AND parser(ms_appt_loc_p)
    AND sa.sch_role_cd=mf_patient_cd
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (sec
   WHERE (sec.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sec.text_type_meaning= Outerjoin("COMMENT"))
    AND (sec.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (seatt
   WHERE (seatt.sch_event_id= Outerjoin(se.sch_event_id)) )
   JOIN (od
   WHERE (od.order_id= Outerjoin(seatt.order_id))
    AND (od.oe_field_meaning= Outerjoin("SPECINX")) )
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(od.order_id))
    AND (oc.updt_id!= Outerjoin(1.0)) )
   JOIN (l
   WHERE (l.long_text_id= Outerjoin(oc.long_text_id)) )
   JOIN (l2
   WHERE (l2.long_text_id= Outerjoin(sec.text_id)) )
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(sa.encntr_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(sa.encntr_id)) )
   JOIN (per
   WHERE per.person_id=sa.person_id)
   JOIN (pera
   WHERE (pera.person_id= Outerjoin(per.person_id))
    AND (pera.active_ind= Outerjoin(1))
    AND (pera.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (pera.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(sea.action_prsnl_id)) )
   JOIN (pr2
   WHERE (pr2.person_id= Outerjoin(epr.prsnl_person_id)) )
  ORDER BY per.name_full_formatted, e.encntr_id, sea.sch_event_id
  HEAD REPORT
   m_pat->l_cnt = 0
  HEAD sea.sch_event_id
   m_pat->l_cnt += 1, stat = alterlist(m_pat->qual,m_pat->l_cnt), m_pat->qual[m_pat->l_cnt].
   s_pat_name = trim(per.name_full_formatted,3),
   m_pat->qual[m_pat->l_cnt].s_cmrn = trim(pera.alias,3), m_pat->qual[m_pat->l_cnt].s_pat_dob =
   format(per.birth_dt_tm,"MM/DD/YYYY;;q"), m_pat->qual[m_pat->l_cnt].s_age = trim(cnvtage(per
     .birth_dt_tm),3),
   m_pat->qual[m_pat->l_cnt].s_appt_time = format(sa.beg_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_pat->qual[
   m_pat->l_cnt].s_resource = trim(uar_get_code_display(sa.resource_cd),3), m_pat->qual[m_pat->l_cnt]
   .s_appt_type = trim(uar_get_code_display(se.appt_type_cd),3),
   m_pat->qual[m_pat->l_cnt].s_appt_dur = trim(cnvtstring(sa.duration),3), m_pat->qual[m_pat->l_cnt].
   s_appt_loc = trim(uar_get_code_display(sa.appt_location_cd),3), m_pat->qual[m_pat->l_cnt].
   s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_pat->qual[m_pat->l_cnt].s_nurs_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_pat->
   qual[m_pat->l_cnt].s_med_service = trim(uar_get_code_display(e.med_service_cd),3), m_pat->qual[
   m_pat->l_cnt].s_sched_user = trim(pr.name_full_formatted,3),
   m_pat->qual[m_pat->l_cnt].s_reason_for_visit = trim(e.reason_for_visit,3), m_pat->qual[m_pat->
   l_cnt].s_sched_comm = trim(replace(replace(l.long_text,char(13)," "),char(10)," "),3), m_pat->
   qual[m_pat->l_cnt].s_sched_comm2 = trim(replace(replace(l2.long_text,char(13)," "),char(10)," "),3
    ),
   m_pat->qual[m_pat->l_cnt].s_spec_instruct = od.oe_field_display_value, m_pat->qual[m_pat->l_cnt].
   f_encntr_id = e.encntr_id, m_pat->qual[m_pat->l_cnt].s_referring_provider = trim(pr2
    .name_full_formatted,3),
   m_pat->qual[m_pat->l_cnt].s_fin_nbr = trim(ea.alias,3)
  WITH nocounter, maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM encntr_plan_reltn epr,
   encntr_plan_auth_r epa,
   authorization a,
   health_plan hp
  PLAN (epr
   WHERE expand(ndx,1,m_pat->l_cnt,epr.encntr_id,m_pat->qual[ndx].f_encntr_id)
    AND epr.priority_seq IN (1, 2)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (epa
   WHERE epa.encntr_plan_reltn_id=epr.encntr_plan_reltn_id
    AND epa.active_ind=1)
   JOIN (a
   WHERE a.authorization_id=epa.authorization_id
    AND a.active_ind=1)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > sysdate)
  HEAD REPORT
   temp_pos = 0
  DETAIL
   temp_pos = locateval(ndx2,1,m_pat->l_cnt,epr.encntr_id,m_pat->qual[ndx2].f_encntr_id)
   IF (epr.priority_seq=1)
    m_pat->qual[temp_pos].s_prim_ins_name = hp.plan_name, m_pat->qual[temp_pos].s_prim_ins_num = epr
    .member_nbr
   ELSEIF (epr.priority_seq=2)
    m_pat->qual[temp_pos].s_second_ins_name = hp.plan_name, m_pat->qual[temp_pos].s_second_ins_num =
    epr.member_nbr
   ENDIF
   m_pat->qual[temp_pos].s_auth_nbr = trim(a.auth_nbr,3)
  WITH nocounter
 ;end select
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 EXECUTE reportrtl
 SET d0 = sec_header(rpt_render)
 FOR (ml_cnt1 = 1 TO m_pat->l_cnt)
   SET mf_rem_space = (mf_page_size - (_yoffset+ sec_detail(rpt_calcheight)))
   IF (mf_rem_space <= 0.25)
    SET _yoffset = 10.18
    SET d0 = pagebreak(0)
   ENDIF
   SET d0 = sec_detail(rpt_render)
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
 IF (textlen(ms_email) > 0)
  IF (findstring("@bhs.org",cnvtlower(ms_email))=0
   AND findstring("@baystatehealth.org",cnvtlower(ms_email))=0)
   SET ms_log = " Email is invalid - must be a valid '@bhs.org' or '@baystatehealth.org' address."
   GO TO exit_script
  ENDIF
  SELECT INTO value(ms_file_name)
   FROM (dummyt d  WITH seq = value(m_pat->l_cnt))
   PLAN (d)
   HEAD REPORT
    ms_temp = concat("scheduler,","patient_name,","cmrn,","patient_dob,","age,",
     "reason_for_visit,","appt_date,","referring_provider,","CCR_scheduling_comment,",
     "special_instructions,",
     "OD_scheduling_comment,","auth_number,","primary_insurance,","primary_ins_num,",
     "secondary_insurance,",
     "secondary_ins_num,","appt_type,","duration,","med_service,","encounter,",
     "fin_nbr,","appt_location,","facility,","nurs_unit,","resource,"), col 0, ms_temp
   DETAIL
    row + 1, ms_temp = build2('"',m_pat->qual[d.seq].s_sched_user,'",','"',m_pat->qual[d.seq].
     s_pat_name,
     '",','"',m_pat->qual[d.seq].s_cmrn,'",','"',
     m_pat->qual[d.seq].s_pat_dob,'",','"',m_pat->qual[d.seq].s_age,'",',
     '"',m_pat->qual[d.seq].s_reason_for_visit,'",','"',m_pat->qual[d.seq].s_appt_time,
     '",','"',m_pat->qual[d.seq].s_referring_provider,'",','"',
     m_pat->qual[d.seq].s_sched_comm2,'",','"',m_pat->qual[d.seq].s_spec_instruct,'",',
     '"',m_pat->qual[d.seq].s_sched_comm,'",','"',m_pat->qual[d.seq].s_auth_nbr,
     '",','"',m_pat->qual[d.seq].s_prim_ins_name,'",','"',
     m_pat->qual[d.seq].s_prim_ins_num,'",','"',m_pat->qual[d.seq].s_second_ins_name,'",',
     '"',m_pat->qual[d.seq].s_second_ins_num,'",','"',m_pat->qual[d.seq].s_appt_type,
     '",','"',m_pat->qual[d.seq].s_appt_dur,'",','"',
     m_pat->qual[d.seq].s_med_service,'",','"',m_pat->qual[d.seq].f_encntr_id,'",',
     '"',m_pat->qual[d.seq].s_fin_nbr,'",','"',m_pat->qual[d.seq].s_appt_loc,
     '",','"',m_pat->qual[d.seq].s_facility,'",','"',
     m_pat->qual[d.seq].s_nurs_unit,'",','"',m_pat->qual[d.seq].s_resource,'",'), col 0,
    ms_temp
   WITH nocounter, format = variable, maxrow = 1,
    maxcol = 5000
  ;end select
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_file_name,ms_file_name,ms_email,"BHS Appointment QA Diagnostic Report",1)
 ENDIF
#exit_script
 IF (textlen(ms_log) > 1)
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    col 0, ms_log, row + 1
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_pat
END GO
