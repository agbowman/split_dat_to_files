CREATE PROGRAM bhs_rpt_foley_nurs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Nurse Unit:" = 0,
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm  :" = "SYSDATE"
  WITH outdev, mf_facility, mf_nurseunit,
  ms_begin_date, ms_end_date
 FREE RECORD request_foley
 RECORD request_foley(
   1 f_facility_cd = f8
   1 f_nurse_unit_cd = f8
   1 d_start_dt_tm = dq8
   1 d_end_dt_tm = dq8
 ) WITH protect
 FREE RECORD reply_foley
 RECORD reply_foley(
   1 c_status = c1
   1 cath_cnt = i4
   1 caths[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 encntr_id = f8
     2 fin = vc
     2 admit_dt_tm = dq8
     2 loc_nurse_unit = c40
     2 loc_when_cath_ordered = c40
     2 cath_type_str = vc
     2 cath_order_dt_tm = dq8
     2 cath_insertion_dt_tm = dq8
     2 cath_removal_dt_tm = dq8
     2 cath_remove_ind = c5
     2 cath_indication_str = vc
     2 ordering_provider_name = vc
     2 order_indication_str = vc
     2 physician_notified_name = vc
 ) WITH protect
 SET reply_foley->c_status = "F"
 SUBROUTINE pgbreak(dummy)
   SET d0 = pagebreak(dummy)
   SET d0 = headpagesection2(rpt_render)
   SET d0 = columnheadersection(rpt_render)
 END ;Subroutine
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_time = vc WITH protect, constant(concat(format(cnvtdatetime( $MS_BEGIN_DATE),
    "DD-MMM-YYYY HH:MM;;D")," to ",format(cnvtdatetime( $MS_END_DATE),"DD-MMM-YYYY HH:MM;;D")))
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE pdaterange = vc WITH protect, noconstant(" ")
 DECLARE pfacility = vc WITH protect, noconstant(" ")
 DECLARE pnurseunit = vc WITH protect, noconstant(" ")
 DECLARE plocnurseunit = vc WITH protect, noconstant(" ")
 DECLARE pnamefullformatted = vc WITH protect, noconstant(" ")
 DECLARE pfin = vc WITH protect, noconstant(" ")
 DECLARE padmitdttm = vc WITH protect, noconstant(" ")
 DECLARE plocwhencathordered = vc WITH protect, noconstant(" ")
 DECLARE pcathorderdttm = vc WITH protect, noconstant(" ")
 DECLARE pcathtypestr = vc WITH protect, noconstant(" ")
 DECLARE pcathinsertiondttm = vc WITH protect, noconstant(" ")
 DECLARE pcathindicationstr = vc WITH protect, noconstant(" ")
 DECLARE pcathremoveind = vc WITH protect, noconstant(" ")
 DECLARE pcathremovaldttm = vc WITH protect, noconstant(" ")
 DECLARE mn_encntr_cnt = i4 WITH protect, noconstant(0)
 IF (((( $MS_BEGIN_DATE="")) OR (( $MS_END_DATE=""))) )
  SET ms_error = concat(ms_error,"Begin Date and End Date are required.")
  GO TO exit_script
 ELSEIF (cnvtdatetime( $MS_BEGIN_DATE) > cnvtdatetime( $MS_END_DATE))
  SET ms_error = concat(ms_error,"Begin Date must be earlier than End Date")
  GO TO exit_script
 ENDIF
 IF (textlen(trim( $MF_FACILITY)) <= 0)
  SET ms_error = concat(ms_error,"Please select a facility.")
  GO TO exit_script
 ELSEIF (( $MF_FACILITY=char(42)))
  SET request_foley->f_facility_cd = 0
 ELSE
  SET request_foley->f_facility_cd =  $MF_FACILITY
 ENDIF
 IF (textlen(trim( $MF_NURSEUNIT)) <= 0)
  SET ms_error = concat(ms_error,"Please select a nurse unit/s.")
  GO TO exit_script
 ELSEIF (( $MF_NURSEUNIT=char(42)))
  SET request_foley->f_nurse_unit_cd = 0
 ELSE
  SET request_foley->f_nurse_unit_cd =  $MF_NURSEUNIT
 ENDIF
 SET request_foley->d_start_dt_tm = cnvtdatetime( $MS_BEGIN_DATE)
 SET request_foley->d_end_dt_tm = cnvtdatetime( $MS_END_DATE)
 EXECUTE bhs_foley_audit
 IF ((reply_foley->c_status="F"))
  SET ms_error = concat(ms_error,"Bhs_rpt_foley_audit did not return success. ")
  GO TO exit_script
 ENDIF
 SET reply_foley->c_status = "F"
 EXECUTE reportrtl
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times180 = i4 WITH noconstant(0), protect
 DECLARE _times60 = i4 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times110 = i4 WITH noconstant(0), protect
 DECLARE _times11b0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (headpagesection2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 9.240)
    SET rptsd->m_width = 0.323
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Page",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 9.563)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curpage,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 2.677
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times180)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Foley Catheter Report",char(0)))
    SET rptsd->m_flags = 576
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 6.156
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pdaterange,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.354
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pnurseunit,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Facility:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.354
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pfacility,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (columnheadersection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = columnheadersectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (columnheadersectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.920000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1028
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.813
    SET _oldfont = uar_rptsetfont(_hreport,_times110)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Location",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.813
    SET _dummyfont = uar_rptsetfont(_hreport,_times11b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.813
    SET _dummyfont = uar_rptsetfont(_hreport,_times110)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct No.",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date/Time",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.063)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Location when Order Placed",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Urinary Catheter Order Date/Time",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Insert Catheter Date/Time",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Indication for Urinary Catheter",char
      (0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.875)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Remove Catheter",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 9.438)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Remove Catheter Date/Time",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.845),(offsetx+ 10.010),(offsety
     + 0.845))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.813
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type of    Urinary Catheter",char(0))
     )
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (columnsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = columnsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (columnsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.125
    SET _oldfont = uar_rptsetfont(_hreport,_times60)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(plocnurseunit,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pnamefullformatted,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pfin,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(padmitdttm,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.063)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(plocwhencathordered,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pcathorderdttm,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pcathinsertiondttm,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pcathindicationstr,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pcathremoveind,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 9.438)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.125
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pcathremovaldttm,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pcathtypestr,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_FOLEY_NURS"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
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
   SET rptfont->m_pointsize = 6
   SET _times60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 18
   SET _times180 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 11
   SET _times110 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times11b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET pdaterange = concat("Date range: ",format(cnvtdatetime( $MS_BEGIN_DATE),"DD-MMM-YYYY HH:MM;;D"),
  " to ",format(cnvtdatetime( $MS_END_DATE),"DD-MMM-YYYY HH:MM;;D"))
 IF ((request_foley->f_facility_cd=0))
  SET pfacility = "<all>"
 ELSE
  SET pfacility = uar_get_code_display(cnvtreal( $MF_FACILITY))
 ENDIF
 IF ((request_foley->f_nurse_unit_cd=0))
  SET pnurseunit = "<all>"
 ELSE
  SET pnurseunit = uar_get_code_display(cnvtreal( $MF_NURSEUNIT))
 ENDIF
 SET d0 = headpagesection2(rpt_render)
 SET d0 = headreportsection(rpt_render)
 SET d0 = columnheadersection(rpt_render)
 FOR (mn_encntr_cnt = 1 TO value(reply_foley->cath_cnt))
   SET plocnurseunit = reply_foley->caths[mn_encntr_cnt].loc_nurse_unit
   SET pnamefullformatted = reply_foley->caths[mn_encntr_cnt].name_full_formatted
   SET pfin = reply_foley->caths[mn_encntr_cnt].fin
   SET padmitdttm = format(reply_foley->caths[mn_encntr_cnt].admit_dt_tm,"MM/DD/YY HH:MM;;D")
   SET plocwhencathordered = reply_foley->caths[mn_encntr_cnt].loc_when_cath_ordered
   SET pcathorderdttm = format(reply_foley->caths[mn_encntr_cnt].cath_order_dt_tm,"MM/DD/YY HH:MM;;D"
    )
   SET pcathtypestr = reply_foley->caths[mn_encntr_cnt].cath_type_str
   SET pcathinsertiondttm = format(reply_foley->caths[mn_encntr_cnt].cath_insertion_dt_tm,
    "MM/DD/YY HH:MM;;D")
   SET pcathindicationstr = reply_foley->caths[mn_encntr_cnt].cath_indication_str
   SET pcathremoveind = reply_foley->caths[mn_encntr_cnt].cath_remove_ind
   SET pcathremovaldttm = format(reply_foley->caths[mn_encntr_cnt].cath_removal_dt_tm,
    "MM/DD/YY HH:MM;;D")
   IF (((_yoffset+ columnsection(rpt_calcheight)) > 7.5))
    SET d0 = pgbreak(1)
   ENDIF
   SET d0 = columnsection(rpt_render)
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
 SET reply_foley->c_status = "S"
#exit_script
 IF ((reply_foley->c_status != "S"))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "Foley Catheter Report", "{F/1}{CPI/14}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
END GO
