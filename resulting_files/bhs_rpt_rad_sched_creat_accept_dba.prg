CREATE PROGRAM bhs_rpt_rad_sched_creat_accept:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Order Type" = 0,
  "Appointment Location:" = 0,
  "Click Search to open the person search window" = 0
  WITH outdev, ms_start_date, ms_end_date,
  mf_ord_type, mf_appt_loc, lstperson
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DATE,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_outpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE mf_onetimeop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE mf_recurringop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"RECURRINGOP")
  )
 DECLARE mf_preadmitdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREADMITDAYSTAY"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_preoutpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOUTPT"))
 DECLARE mf_triage_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"TRIAGE"))
 DECLARE mf_officevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT")
  )
 DECLARE mf_preofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREOFFICEVISIT"))
 DECLARE mf_outpatientonetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE mf_prerecurofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PRERECUROFFICEVISIT"))
 DECLARE mf_recurofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "RECUROFFICEVISIT"))
 DECLARE mf_outpatientrecurring_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTRECURRING"))
 DECLARE mf_preoutpatientonetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREOUTPATIENTONETIME"))
 DECLARE mf_creatinine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CREATININE"))
 DECLARE mf_creat_blood_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Creatinine-Blood"))
 DECLARE mf_gfrafricanamerican_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRAFRICANAMERICAN"))
 DECLARE mf_gfrnonafricanamerican_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRNONAFRICANAMERICAN"))
 DECLARE mf_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE ms_title_text = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_pat_search = vc WITH protect, noconstant("")
 DECLARE ml_ord_result = i4 WITH protect, noconstant(0)
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_head(ncalc=i2) = f8 WITH protect
 DECLARE sec_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_patinfo_ct(ncalc=i2) = f8 WITH protect
 DECLARE tablerow16(ncalc=i2) = f8 WITH protect
 DECLARE tablerow16abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow3(ncalc=i2) = f8 WITH protect
 DECLARE tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow4(ncalc=i2) = f8 WITH protect
 DECLARE tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow8(ncalc=i2) = f8 WITH protect
 DECLARE tablerow8abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow6(ncalc=i2) = f8 WITH protect
 DECLARE tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow7(ncalc=i2) = f8 WITH protect
 DECLARE tablerow7abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_patinfo_ctabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_patinfo_mri(ncalc=i2) = f8 WITH protect
 DECLARE tablerow15(ncalc=i2) = f8 WITH protect
 DECLARE tablerow15abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow20(ncalc=i2) = f8 WITH protect
 DECLARE tablerow20abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow21(ncalc=i2) = f8 WITH protect
 DECLARE tablerow21abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow22(ncalc=i2) = f8 WITH protect
 DECLARE tablerow22abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow23(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow24(ncalc=i2) = f8 WITH protect
 DECLARE tablerow24abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow26(ncalc=i2) = f8 WITH protect
 DECLARE tablerow26abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow27(ncalc=i2) = f8 WITH protect
 DECLARE tablerow27abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow28(ncalc=i2) = f8 WITH protect
 DECLARE tablerow28abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_patinfo_mriabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_body_mri(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow29(ncalc=i2) = f8 WITH protect
 DECLARE tablerow29abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow30(ncalc=i2) = f8 WITH protect
 DECLARE tablerow30abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow31(ncalc=i2) = f8 WITH protect
 DECLARE tablerow31abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow32(ncalc=i2) = f8 WITH protect
 DECLARE tablerow32abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow33(ncalc=i2) = f8 WITH protect
 DECLARE tablerow33abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow36(ncalc=i2) = f8 WITH protect
 DECLARE tablerow36abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow34(ncalc=i2) = f8 WITH protect
 DECLARE tablerow34abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow35(ncalc=i2) = f8 WITH protect
 DECLARE tablerow35abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow39(ncalc=i2) = f8 WITH protect
 DECLARE tablerow39abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow40(ncalc=i2) = f8 WITH protect
 DECLARE tablerow40abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow37(ncalc=i2) = f8 WITH protect
 DECLARE tablerow37abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow42(ncalc=i2) = f8 WITH protect
 DECLARE tablerow42abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow45(ncalc=i2) = f8 WITH protect
 DECLARE tablerow45abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow46(ncalc=i2) = f8 WITH protect
 DECLARE tablerow46abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow50(ncalc=i2) = f8 WITH protect
 DECLARE tablerow50abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow43(ncalc=i2) = f8 WITH protect
 DECLARE tablerow43abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_body_mriabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_body_ct(ncalc=i2) = f8 WITH protect
 DECLARE tablerow9(ncalc=i2) = f8 WITH protect
 DECLARE tablerow9abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow10(ncalc=i2) = f8 WITH protect
 DECLARE tablerow10abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow11(ncalc=i2) = f8 WITH protect
 DECLARE tablerow11abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow12(ncalc=i2) = f8 WITH protect
 DECLARE tablerow12abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow13(ncalc=i2) = f8 WITH protect
 DECLARE tablerow13abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow14(ncalc=i2) = f8 WITH protect
 DECLARE tablerow14abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow18(ncalc=i2) = f8 WITH protect
 DECLARE tablerow18abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow38(ncalc=i2) = f8 WITH protect
 DECLARE tablerow38abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow44(ncalc=i2) = f8 WITH protect
 DECLARE tablerow44abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow47(ncalc=i2) = f8 WITH protect
 DECLARE tablerow47abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow48(ncalc=i2) = f8 WITH protect
 DECLARE tablerow48abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow49(ncalc=i2) = f8 WITH protect
 DECLARE tablerow49abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow17(ncalc=i2) = f8 WITH protect
 DECLARE tablerow17abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_body_ctabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_comment_mri(ncalc=i2) = f8 WITH protect
 DECLARE sec_comment_mriabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_comment_ct(ncalc=i2) = f8 WITH protect
 DECLARE sec_comment_ctabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_foot(ncalc=i2) = f8 WITH protect
 DECLARE sec_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
 SUBROUTINE sec_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 528
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 3.396
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_title_text,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_patinfo_ct(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_patinfo_ctabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow16(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow16abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow16abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow4(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow4abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow8(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow8abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow8abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.242489), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.235
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.235
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow6(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow6abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.293009), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.286
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.286
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 3.753
   SET rptsd->m_height = 0.286
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
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
 SUBROUTINE tablerow7(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow7abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow7abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.363738), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.357
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.357
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 3.753
   SET rptsd->m_height = 0.357
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
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
 SUBROUTINE sec_patinfo_ctabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.700000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __patname = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_person_name_full,char(0))),
   protect
   DECLARE __relevantpreviousfilms = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_rel_prev_films,
     char(0))), protect
   DECLARE __examname = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_appt_type,char(0))),
   protect
   DECLARE __apptdate = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_appt_date,char(0))),
   protect
   DECLARE __orderingprovider = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_order_prov,char(0))
    ), protect
   DECLARE __patweight = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_person_weight,char(0))),
   protect
   DECLARE __orderdeliverymethod = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_order_delivery,
     char(0))), protect
   DECLARE __preauth = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_preauth,char(0))), protect
   DECLARE __pregnant = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_pregnant,char(0))), protect
   DECLARE __examreason = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_reason_for_exam,char(0))),
   protect
   DECLARE __appttime = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_appt_time,char(0))),
   protect
   DECLARE __dob = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_person_dob,char(0))), protect
   DECLARE __fin = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_fin,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_mrn,char(0))), protect
   DECLARE __orderingproviderphone = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_order_prov_phone,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient/Exam Information",char(0)))
    SET _yoffset = (offsety+ 0.250)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.250)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow16(rpt_render))
     SET holdheight = (holdheight+ tablerow(rpt_render))
     SET holdheight = (holdheight+ tablerow1(rpt_render))
     SET holdheight = (holdheight+ tablerow2(rpt_render))
     SET holdheight = (holdheight+ tablerow3(rpt_render))
     SET holdheight = (holdheight+ tablerow4(rpt_render))
     SET holdheight = (holdheight+ tablerow8(rpt_render))
     SET holdheight = (holdheight+ tablerow6(rpt_render))
     SET holdheight = (holdheight+ tablerow7(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Communication Type:",char(0)))
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relevant Previous Films?",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Exam Name:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointment Date:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Provider:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__relevantpreviousfilms)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__examname)
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__apptdate)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderingprovider)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patweight)
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderdeliverymethod)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Preauth obtained:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.688)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__preauth)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason for Exam:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointment Time:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Pregnant ?",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.688)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pregnant)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__examreason)
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__appttime)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Account Number:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderingproviderphone)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_patinfo_mri(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_patinfo_mriabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow15(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow15abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow15abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248983), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.242
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow20(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow20abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow20abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248983), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.242
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow21(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow21abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248983), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.242
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow22(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow22abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow22abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248983), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.242
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow23(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow23abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow23abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.248983), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.242
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.242
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow24(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow24abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow24abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.238610), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.232
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.232
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 1.191
   SET rptsd->m_height = 0.232
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.944)
   SET rptsd->m_width = 2.556
   SET rptsd->m_height = 0.232
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.937),offsety,(offsetx+ 4.937),(offsety+
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
 SUBROUTINE tablerow26(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow26abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow26abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.318143), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.311
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.311
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 3.753
   SET rptsd->m_height = 0.311
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
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
 SUBROUTINE tablerow27(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow27abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow27abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.297623), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.291
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.291
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 3.753
   SET rptsd->m_height = 0.291
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
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
 SUBROUTINE tablerow28(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow28abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow28abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.369458), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.362
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.045
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.747)
   SET rptsd->m_width = 3.753
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.740),offsety,(offsetx+ 3.740),(offsety+
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
 SUBROUTINE sec_patinfo_mriabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.790000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __patname = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_person_name_full,char(0))),
   protect
   DECLARE __relevantpreviousfilms = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_rel_prev_films,
     char(0))), protect
   DECLARE __prevsurg = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_prev_surg,char(0))),
   protect
   DECLARE __examname = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_appt_type,char(0))),
   protect
   DECLARE __apptdate = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_appt_date,char(0))),
   protect
   DECLARE __orderingprovider = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_order_prov,char(0))
    ), protect
   DECLARE __patweight = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_person_weight,char(0))),
   protect
   DECLARE __orderdeliverymethod = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_order_delivery,
     char(0))), protect
   DECLARE __examreason = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_reason_for_exam,char(0))),
   protect
   DECLARE __appttime = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_appt_time,char(0))),
   protect
   DECLARE __dob = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_person_dob,char(0))), protect
   DECLARE __patheight = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_height,char(0))), protect
   DECLARE __fin = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_fin,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_mrn,char(0))), protect
   DECLARE __orderingproviderphone = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_order_prov_phone,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient/Exam Information",char(0)))
    SET _yoffset = (offsety+ 0.250)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.250)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow15(rpt_render))
     SET holdheight = (holdheight+ tablerow20(rpt_render))
     SET holdheight = (holdheight+ tablerow21(rpt_render))
     SET holdheight = (holdheight+ tablerow22(rpt_render))
     SET holdheight = (holdheight+ tablerow23(rpt_render))
     SET holdheight = (holdheight+ tablerow24(rpt_render))
     SET holdheight = (holdheight+ tablerow26(rpt_render))
     SET holdheight = (holdheight+ tablerow27(rpt_render))
     SET holdheight = (holdheight+ tablerow28(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 2.354)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Communication Type:",char(0)))
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Relevant Previous Films?",char(0)))
    SET rptsd->m_y = (offsety+ 1.729)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Has Patient had any previous Surgery?",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Exam Name:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointment Date:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Provider:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET rptsd->m_y = (offsety+ 2.042)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__relevantpreviousfilms)
    SET rptsd->m_y = (offsety+ 1.729)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prevsurg)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__examname)
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__apptdate)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderingprovider)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patweight)
    SET rptsd->m_y = (offsety+ 2.354)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderdeliverymethod)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reason for Exam:",char(0)))
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appointment Time:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider Phone:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Height:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth:",char(0)))
    SET rptsd->m_y = (offsety+ 2.042)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.333
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__examreason)
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__appttime)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.229
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patheight)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Account Number:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderingproviderphone)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_body_mri(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_body_mriabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow25(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow25abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow25abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow29(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow29abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow29abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow30(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow30abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow30abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow31(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow31abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow31abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow32(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow32abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow32abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow33(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow33abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow33abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow36(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow36abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow36abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.309758), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.303
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.819)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.303
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.812),offsety,(offsetx+ 3.812),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow34(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow34abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow34abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.269187), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.262
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.262
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.819)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.262
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.262
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.812),offsety,(offsetx+ 3.812),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow35(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow35abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow35abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290483), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.283
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.283
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow39(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow39abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow39abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.312416), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.305
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.305
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.305
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.305
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow40(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow40abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow40abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.334589), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.328
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 2.118
   SET rptsd->m_height = 0.328
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.328
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.328
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow37(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow37abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow37abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.562514), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.556
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 5.806
   SET rptsd->m_height = 0.556
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
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
 SUBROUTINE tablerow42(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow42abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow42abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.375002), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.681
   SET rptsd->m_height = 0.368
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.695)
   SET rptsd->m_width = 1.180
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.882)
   SET rptsd->m_width = 1.431
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.319)
   SET rptsd->m_width = 1.306
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.368
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),offsety,(offsetx+ 1.688),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.313),offsety,(offsetx+ 4.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow45(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow45abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow45abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249760), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.587
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.601)
   SET rptsd->m_width = 2.899
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.594),offsety,(offsetx+ 4.594),(offsety+
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
 SUBROUTINE tablerow46(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow46abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow46abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249760), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.587
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.601)
   SET rptsd->m_width = 2.899
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.594),offsety,(offsetx+ 4.594),(offsety+
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
 SUBROUTINE tablerow50(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow50abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow50abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249760), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.587
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.601)
   SET rptsd->m_width = 2.899
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.594),offsety,(offsetx+ 4.594),(offsety+
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
 SUBROUTINE tablerow43(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow43abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow43abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.386143), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.587
   SET rptsd->m_height = 0.379
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.601)
   SET rptsd->m_width = 2.899
   SET rptsd->m_height = 0.379
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.594),offsety,(offsetx+ 4.594),(offsety+
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
 SUBROUTINE sec_body_mriabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(5.790000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __comment = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_comment,char(0))), protect
   DECLARE __holdstill = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_hold_still,char(0))),
   protect
   DECLARE __insulinpump = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_insulin_pump,char(0))),
   protect
   DECLARE __shunt = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_shunt,char(0))), protect
   DECLARE __pacemaker = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_pacemaker,char(0))),
   protect
   DECLARE __metallicforeign = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_metallic_foreign_body,char(0))), protect
   DECLARE __aorticstent = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_stent,char(0))), protect
   DECLARE __cerebralaneurysmclips = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_cerebral_clip,
     char(0))), protect
   DECLARE __diabetestreated = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diabetic,char(0))),
   protect
   DECLARE __kidneydisease = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_kidney_disease,char(0)
     )), protect
   DECLARE __sheetmetal = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_steel_metal_worker,char(0
      ))), protect
   DECLARE __hypertensiontreated = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_hypertension,
     char(0))), protect
   DECLARE __pregnant = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_pregnant,char(0))), protect
   DECLARE __claustrophobic = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_claustrophobic,char(0
      ))), protect
   DECLARE __lifesupport = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_life_support,char(0))),
   protect
   DECLARE __eyeprosthesis = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_prosthesis,char(0))),
   protect
   DECLARE __neurostimulator = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_neurostimulator,char
     (0))), protect
   DECLARE __pacemakermri = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_pacemaker_compatible,
     char(0))), protect
   DECLARE __diabetesresult = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diabetic_lab_result,
     char(0))), protect
   DECLARE __hypertensionresult = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_hypertension_lab_result,char(0))), protect
   DECLARE __kidneydiseaseresult = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_kidney_lab_result,char(0))), protect
   DECLARE __prob_kidney_disease = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diag_prob_kidney,
     char(0))), protect
   DECLARE __prob_hypertension = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_diag_prob_hypertension,char(0))), protect
   DECLARE __prob_diabetes = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diag_prob_diabetes,
     char(0))), protect
   DECLARE __allergy = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_allergy,char(0))), protect
   DECLARE __creat_ord_status = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_creat_order_status,
     char(0))), protect
   DECLARE __creat_ord_date = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_creat_order_dt,char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.250)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.250)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow25(rpt_render))
     SET holdheight = (holdheight+ tablerow29(rpt_render))
     SET holdheight = (holdheight+ tablerow30(rpt_render))
     SET holdheight = (holdheight+ tablerow31(rpt_render))
     SET holdheight = (holdheight+ tablerow32(rpt_render))
     SET holdheight = (holdheight+ tablerow33(rpt_render))
     SET holdheight = (holdheight+ tablerow36(rpt_render))
     SET holdheight = (holdheight+ tablerow34(rpt_render))
     SET holdheight = (holdheight+ tablerow35(rpt_render))
     SET holdheight = (holdheight+ tablerow39(rpt_render))
     SET holdheight = (holdheight+ tablerow40(rpt_render))
     SET holdheight = (holdheight+ tablerow37(rpt_render))
     SET holdheight = (holdheight+ tablerow42(rpt_render))
     SET holdheight = (holdheight+ tablerow45(rpt_render))
     SET holdheight = (holdheight+ tablerow46(rpt_render))
     SET holdheight = (holdheight+ tablerow50(rpt_render))
     SET holdheight = (holdheight+ tablerow43(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Precautions/Contraindications",char(0
       )))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have implanted aortic stent?",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have an internal insulin pump?",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is patient a sheet metal worker ?",
      char(0)))
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Can patient hold still for 30 minutes?",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is patient pregnant ?",char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have a reprogrammable shunt?",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Does patient have a pacemaker?",char(
       0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Any metallic foreign/body present?",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have cerebral aneurysm clips?",char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("If Yes: ",char(0)))
    SET rptsd->m_y = (offsety+ 3.625)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Special Comments :",char(0)))
    SET rptsd->m_y = (offsety+ 3.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is patient treated for diabetes?",
      char(0)))
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is patient treated for hypertension?",
      char(0)))
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Does patient have kidney disease ?",
      char(0)))
    SET rptsd->m_y = (offsety+ 3.625)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 5.688
    SET rptsd->m_height = 0.563
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__comment)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__holdstill)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__insulinpump)
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__shunt)
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pacemaker)
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__metallicforeign)
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__aorticstent)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cerebralaneurysmclips)
    SET rptsd->m_y = (offsety+ 3.313)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__diabetestreated)
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kidneydisease)
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sheetmetal)
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hypertensiontreated)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pregnant)
    SET rptsd->m_y = (offsety+ 2.438)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__claustrophobic)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is patient claustrophobic?",char(0)))
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("If Yes, Date/Lab results",char(0)))
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("If Yes, Date/Lab results",char(0)))
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is Life support system required?",
      char(0)))
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Any prosthesis of eye, ear or orthopedic?",char(0)))
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Does patient have a neurostimulator?",
      char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is Pacemaker MRI compatible?",char(0)
      ))
    SET rptsd->m_y = (offsety+ 3.313)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("If Yes, Date/Lab results",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lifesupport)
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__eyeprosthesis)
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__neurostimulator)
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pacemakermri)
    SET rptsd->m_y = (offsety+ 3.313)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__diabetesresult)
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hypertensionresult)
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kidneydiseaseresult)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 5.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have any problem and/or diagnosis indicative of kidney disease?",char(0)))
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have any problem and/or diagnosis indicative of hypertension ?",char(0)))
    SET rptsd->m_y = (offsety+ 4.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have any problem and/or diagnosis indicative of diabetes ?",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 5.063)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prob_kidney_disease)
    SET rptsd->m_y = (offsety+ 4.813)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prob_hypertension)
    SET rptsd->m_y = (offsety+ 4.563)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prob_diabetes)
    SET rptsd->m_y = (offsety+ 5.375)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__allergy)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 5.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.438
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Does patient have an allergy to one of the following : Contrast Dye, contrast media (gadolinium-based), contras",
       "t media (iron oxide-based), contrast media (perfluorocarbon-based) ?"),char(0)))
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Creatinine :",char(0)))
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Date:",char(0)))
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Status:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__creat_ord_status)
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 2.875)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__creat_ord_date)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_body_ct(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_body_ctabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow9(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow9abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow9abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.312501), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.306
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.306
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.306
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.306
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow10(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow10abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow10abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250001), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow11(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow11abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow11abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250001), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.243
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow12(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow12abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.504604), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.498
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.498
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.498
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.498
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow13(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow13abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow13abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.363536), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.357
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.357
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.357
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.357
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow14(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow14abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow14abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.256865), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow18(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow18abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow18abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.260416), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.253
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 2.055
   SET rptsd->m_height = 0.253
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.820)
   SET rptsd->m_width = 1.806
   SET rptsd->m_height = 0.253
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.253
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.813),offsety,(offsetx+ 3.813),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow38(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow38abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow38abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.573858), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.567
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 5.743
   SET rptsd->m_height = 0.567
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
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
 SUBROUTINE tablerow44(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow44abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow44abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.353219), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 1.743
   SET rptsd->m_height = 0.346
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.757)
   SET rptsd->m_width = 1.118
   SET rptsd->m_height = 0.346
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.882)
   SET rptsd->m_width = 1.431
   SET rptsd->m_height = 0.346
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.319)
   SET rptsd->m_width = 1.305
   SET rptsd->m_height = 0.346
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.632)
   SET rptsd->m_width = 1.868
   SET rptsd->m_height = 0.346
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.750),offsety,(offsetx+ 1.750),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.875),offsety,(offsetx+ 2.875),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.313),offsety,(offsetx+ 4.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.625),offsety,(offsetx+ 5.625),(offsety+
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
 SUBROUTINE tablerow47(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow47abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow47abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.269713), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.618
   SET rptsd->m_height = 0.263
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 2.868
   SET rptsd->m_height = 0.263
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
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
 SUBROUTINE tablerow48(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow48abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow48abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.269713), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.618
   SET rptsd->m_height = 0.263
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 2.868
   SET rptsd->m_height = 0.263
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
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
 SUBROUTINE tablerow49(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow49abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow49abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.269713), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.618
   SET rptsd->m_height = 0.263
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 2.868
   SET rptsd->m_height = 0.263
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
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
 SUBROUTINE tablerow17(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow17abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow17abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.482529), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 4.618
   SET rptsd->m_height = 0.476
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.632)
   SET rptsd->m_width = 2.868
   SET rptsd->m_height = 0.476
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),offsety,(offsetx+ 4.625),(offsety+
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
 SUBROUTINE sec_body_ctabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(4.840000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __labs = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_labs_where,char(0))), protect
   DECLARE __singlekidney = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_single_kidney,char(0))),
   protect
   DECLARE __hypertensionmed = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_hypertension_med_req,
     char(0))), protect
   DECLARE __diabetic = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diabetic,char(0))), protect
   DECLARE __over65 = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_over_65,char(0))), protect
   DECLARE __dialysis = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_dialysis,char(0))), protect
   DECLARE __pastreactioncontrast = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_past_reaction_contrast,char(0))), protect
   DECLARE __kidneydisease = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_kidney_disease,char(0)
     )), protect
   DECLARE __glucophagemeds = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_glucophage,char(0))),
   protect
   DECLARE __kidneyurine = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_kidney_urine,char(0))),
   protect
   DECLARE __contrastreaction = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_past_reaction_contrast_expl,char(0))), protect
   DECLARE __comment = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_comment,char(0))), protect
   DECLARE __prob_kidney_disease = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diag_prob_kidney,
     char(0))), protect
   DECLARE __prob_hypertension = vc WITH noconstant(build2(schdata->qual[ml_cnt].
     s_diag_prob_hypertension,char(0))), protect
   DECLARE __prob_diabetes = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_diag_prob_diabetes,
     char(0))), protect
   DECLARE __allergy = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_allergy,char(0))), protect
   DECLARE __creat_ord_status = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_creat_order_status,
     char(0))), protect
   DECLARE __creat_ord_date = vc WITH noconstant(build2(schdata->qual[ml_cnt].s_creat_order_dt,char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.313)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.313)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow9(rpt_render))
     SET holdheight = (holdheight+ tablerow10(rpt_render))
     SET holdheight = (holdheight+ tablerow11(rpt_render))
     SET holdheight = (holdheight+ tablerow12(rpt_render))
     SET holdheight = (holdheight+ tablerow13(rpt_render))
     SET holdheight = (holdheight+ tablerow14(rpt_render))
     SET holdheight = (holdheight+ tablerow18(rpt_render))
     SET holdheight = (holdheight+ tablerow38(rpt_render))
     SET holdheight = (holdheight+ tablerow44(rpt_render))
     SET holdheight = (holdheight+ tablerow47(rpt_render))
     SET holdheight = (holdheight+ tablerow48(rpt_render))
     SET holdheight = (holdheight+ tablerow49(rpt_render))
     SET holdheight = (holdheight+ tablerow17(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Precautions/Contraindications",char(0
       )))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Kidney disease?",char(0)))
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Hypertension requiring treatment with medication?",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Taking Glucophage or any metformin containing medications?",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Kidneys Producing Urine?",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("What was reaction:",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Is patient diabetic?",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Over 60?",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient on dialysis?",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Past Reaction to IV contrast?",char(0
       )))
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Labs drawn when where?",char(0)))
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Single Kidney?",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.250)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__labs)
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__singlekidney)
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hypertensionmed)
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__diabetic)
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__over65)
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dialysis)
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pastreactioncontrast)
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kidneydisease)
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__glucophagemeds)
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__kidneyurine)
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__contrastreaction)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.521)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Special Comments :",char(0)))
    SET rptsd->m_y = (offsety+ 2.521)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 5.688
    SET rptsd->m_height = 0.563
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__comment)
    SET rptsd->m_y = (offsety+ 4.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have any problem and/or diagnosis indicative of kidney disease?",char(0)))
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have any problem and/or diagnosis indicative of hypertension ?",char(0)))
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Does patient have any problem and/or diagnosis indicative of diabetes ?",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 4.000)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prob_kidney_disease)
    SET rptsd->m_y = (offsety+ 3.750)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prob_hypertension)
    SET rptsd->m_y = (offsety+ 3.438)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__prob_diabetes)
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__allergy)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Does patient have an allergy to one of the following : Contrast Dye, contrast media (gadolinium-based), contras",
       "t media (iron oxide-based), contrast media (perfluorocarbon-based) ?"),char(0)))
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Creatinine :",char(0)))
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Date:",char(0)))
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Status:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__creat_ord_status)
    SET rptsd->m_y = (offsety+ 3.125)
    SET rptsd->m_x = (offsetx+ 2.875)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__creat_ord_date)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_comment_mri(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_comment_mriabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_comment_mriabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.820000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.688
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Exam Cancelled or Rescheduled:____________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Protocoling MD Initials:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 5.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Protocol:____________________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Comment :___________________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Initials:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 3.562)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date:_____________",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_comment_ct(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_comment_ctabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_comment_ctabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.650000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CT Technologist Initials: ________",
      char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Protocoling MD Initials:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 5.125
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Protocol:______________________________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Comment 3:___________________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Comment 2:___________________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Comment 1:___________________________________________________",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Initials:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Initials:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Initials:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 3.562)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time:_____________",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date:_____________",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.563)
    SET rptsd->m_width = 2.021
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "BHS_RPT_RAD_SCHED_CREAT_ACCEPT"
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
   SET rptfont->m_pointsize = 8
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
 FREE RECORD schdata
 RECORD schdata(
   1 l_cnt = i4
   1 qual[*]
     2 f_sch_appt_id = f8
     2 f_sch_event_id = f8
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_appt_type = vc
     2 s_appt_date = vc
     2 s_appt_time = vc
     2 f_appt_beg_dt = dq8
     2 f_appt_end_dt = dq8
     2 s_person_name_full = vc
     2 s_person_dob = vc
     2 s_person_weight = vc
     2 s_person_height = vc
     2 s_order_prov = vc
     2 s_order_prov_phone = vc
     2 s_reason_for_exam = vc
     2 s_preauth = vc
     2 s_pregnant = vc
     2 s_labs_where = vc
     2 s_prev_surgery = vc
     2 s_rel_prev_films = vc
     2 s_order_delivery = vc
     2 s_past_reaction_contrast = vc
     2 s_past_reaction_contrast_expl = vc
     2 s_dialysis = vc
     2 s_kidney_urine = vc
     2 s_over_65 = vc
     2 s_diabetic = vc
     2 s_glucophage = vc
     2 s_hypertension_med_req = vc
     2 s_kidney_disease = vc
     2 s_dif_breathing_med_req = vc
     2 s_comment = vc
     2 s_metallic_foreign_body = vc
     2 s_steel_metal_worker = vc
     2 s_neurostimulator = vc
     2 s_prosthesis = vc
     2 s_claustrophobic = vc
     2 s_height = vc
     2 s_prev_surg = vc
     2 s_prev_surg_info = vc
     2 s_cerebral_clip = vc
     2 s_pacemaker = vc
     2 s_pacemaker_compatible = vc
     2 s_shunt = vc
     2 s_insulin_pump = vc
     2 s_life_support = vc
     2 s_hold_still = vc
     2 s_stent = vc
     2 s_single_kidney = vc
     2 s_kidney_lab_result = vc
     2 s_hypertension = vc
     2 s_hypertension_lab_result = vc
     2 s_diabetic_lab_result = vc
     2 s_relevant_imaging_where = vc
     2 f_creat_lab_dt = f8
     2 s_creat_lab_dt = vc
     2 s_creat_result = vc
     2 f_gfrafrican_lab_dt = f8
     2 s_gfrafrican_lab_dt = vc
     2 s_gfrafrican_result = vc
     2 f_gfrnonafrican_lab_dt = f8
     2 s_gfrnonafrican_lab_dt = vc
     2 s_gfrnonafrican_result = vc
     2 s_creat_compl_ord_dt = vc
     2 s_creat_compl_status = vc
     2 f_creat_compl_status_dt = f8
     2 s_creat_order_dt = vc
     2 f_creat_order_dt = f8
     2 s_creat_order_status = vc
     2 s_diag_prob_diabetes = vc
     2 s_diag_prob_kidney = vc
     2 s_diag_prob_hypertension = vc
     2 s_allergy = vc
 ) WITH protect
 FREE RECORD per
 RECORD per(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
 )
 IF (( $MF_ORD_TYPE=1))
  SET ms_title_text = "Baystate Health CT Data Sheet"
 ELSEIF (( $MF_ORD_TYPE=2))
  SET ms_title_text = "Baystate Health MRI Data Sheet"
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id= $LSTPERSON)
   AND p.person_id != 0
  HEAD REPORT
   per->l_cnt = 0
  DETAIL
   per->l_cnt = (per->l_cnt+ 1), stat = alterlist(per->qual,per->l_cnt), per->qual[per->l_cnt].
   f_person_id = p.person_id
  WITH nocounter
 ;end select
 IF ((per->l_cnt=0))
  SET ms_pat_search = " 1 = 1 "
 ELSE
  SET ms_pat_search = " expand(ml_cnt, 1, per->l_cnt, sa.person_id, per->qual[ml_cnt].f_person_id)"
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt sa,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   sch_event se,
   code_value cv,
   sch_event_detail sed,
   order_entry_fields oef,
   person p,
   sch_event_comm sec,
   long_text ltx,
   phone ph
  PLAN (sa
   WHERE (sa.appt_location_cd= $MF_APPT_LOC)
    AND sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND sa.role_meaning="PATIENT"
    AND sa.state_meaning IN ("CONFIRMED", "CHECKED IN", "CHECKED OUT", "SCHEDULED", "PENDING")
    AND sa.sch_event_id != 0
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.active_ind=1
    AND parser(ms_pat_search))
   JOIN (p
   WHERE p.person_id=sa.person_id
    AND p.person_id != 0)
   JOIN (e
   WHERE e.encntr_id=sa.encntr_id
    AND e.encntr_type_cd IN (mf_outpatient_cd, mf_onetimeop_cd, mf_recurringop_cd,
   mf_preadmitdaystay_cd, mf_daystay_cd,
   mf_preoutpt_cd, mf_triage_cd, mf_officevisit_cd, mf_preofficevisit_cd, mf_outpatientonetime_cd,
   mf_prerecurofficevisit_cd, mf_recurofficevisit_cd, mf_outpatientrecurring_cd,
   mf_preoutpatientonetime_cd))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_ea_mrn_cd)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_ea_fin_cd)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id)
   JOIN (cv
   WHERE cv.code_value=se.appt_type_cd
    AND cnvtupper(cv.display) IN ("CT*", "MRA*", "MRI*"))
   JOIN (sed
   WHERE sed.sch_event_id=se.sch_event_id
    AND sed.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sed.active_ind=1)
   JOIN (oef
   WHERE oef.oe_field_id=sed.oe_field_id)
   JOIN (sec
   WHERE sec.sch_event_id=outerjoin(se.sch_event_id)
    AND sec.active_ind=outerjoin(1)
    AND sec.version_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (ltx
   WHERE ltx.long_text_id=outerjoin(sec.text_id))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(sed.oe_field_value)
    AND ph.parent_entity_name=outerjoin("PERSON")
    AND ph.active_ind=outerjoin(1)
    AND ph.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND ph.phone_type_seq=outerjoin(1)
    AND ph.phone_type_cd=outerjoin(mf_business_cd))
  ORDER BY sa.sch_appt_id
  HEAD REPORT
   schdata->l_cnt = 0
  HEAD sa.sch_appt_id
   schdata->l_cnt = (schdata->l_cnt+ 1), stat = alterlist(schdata->qual,schdata->l_cnt), schdata->
   qual[schdata->l_cnt].f_sch_appt_id = sa.sch_appt_id,
   schdata->qual[schdata->l_cnt].f_sch_event_id = se.sch_event_id, schdata->qual[schdata->l_cnt].
   f_encntr_id = sa.encntr_id, schdata->qual[schdata->l_cnt].f_person_id = p.person_id,
   schdata->qual[schdata->l_cnt].f_appt_beg_dt = sa.beg_dt_tm, schdata->qual[schdata->l_cnt].
   s_appt_date = format(sa.beg_dt_tm,"MM/DD/YYYY;;q"), schdata->qual[schdata->l_cnt].s_appt_time =
   format(sa.beg_dt_tm,"HH:MM:SS;;q"),
   schdata->qual[schdata->l_cnt].f_appt_end_dt = sa.end_dt_tm, schdata->qual[schdata->l_cnt].
   s_appt_type = uar_get_code_display(se.appt_type_cd), schdata->qual[schdata->l_cnt].
   s_person_name_full = p.name_full_formatted,
   schdata->qual[schdata->l_cnt].s_person_dob = format(p.birth_dt_tm,"MM/DD/YYYY;;q"), schdata->qual[
   schdata->l_cnt].s_comment = ltx.long_text, schdata->qual[schdata->l_cnt].s_mrn = trim(ea1.alias,3),
   schdata->qual[schdata->l_cnt].s_fin = trim(ea2.alias,3)
  DETAIL
   CALL echo(oef.description)
   IF (trim(oef.description,3) IN ("Pregnant", "Scheduling Pregnant", "SCH Pregnant"))
    schdata->qual[schdata->l_cnt].s_pregnant = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="Reason For Exam")
    schdata->qual[schdata->l_cnt].s_reason_for_exam = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3) IN ("Attending MD", "Scheduling Ordering Physician"))
    schdata->qual[schdata->l_cnt].s_order_prov = sed.oe_field_display_value, schdata->qual[schdata->
    l_cnt].s_order_prov_phone = ph.phone_num
   ELSEIF (trim(oef.description,3) IN ("SCH How order arrive", "Scheduling Order Type"))
    schdata->qual[schdata->l_cnt].s_order_delivery = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3) IN ("Scheduling Weight (lbs)", "SCH Weight"))
    schdata->qual[schdata->l_cnt].s_person_weight = trim(sed.oe_field_display_value,3)
   ELSEIF (trim(oef.description,3)="SCH Hypertension requiring medication")
    schdata->qual[schdata->l_cnt].s_hypertension_med_req = sed.oe_field_display_value, schdata->qual[
    schdata->l_cnt].s_hypertension = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Previous Imaging Where")
    schdata->qual[schdata->l_cnt].s_rel_prev_films = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Kidney Disease")
    schdata->qual[schdata->l_cnt].s_kidney_disease = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Diabetic")
    schdata->qual[schdata->l_cnt].s_diabetic = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Kidneys producing urine")
    schdata->qual[schdata->l_cnt].s_kidney_urine = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Patient over 65")
    schdata->qual[schdata->l_cnt].s_over_65 = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Reaction to IV Contrast")
    schdata->qual[schdata->l_cnt].s_past_reaction_contrast = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Contrast reaction")
    schdata->qual[schdata->l_cnt].s_past_reaction_contrast_expl = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Pre-Auth")
    schdata->qual[schdata->l_cnt].s_preauth = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3) IN ("SCH Dialysis", "SCH Diaylsis"))
    schdata->qual[schdata->l_cnt].s_dialysis = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Diabetic Metformin Meds")
    schdata->qual[schdata->l_cnt].s_glucophage = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Labs drawn when where")
    schdata->qual[schdata->l_cnt].s_labs_where = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Comment")
    schdata->qual[schdata->l_cnt].s_comment = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="Metallic Foreign Body")
    schdata->qual[schdata->l_cnt].s_metallic_foreign_body = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="Steel/Sheet Metal Worker")
    schdata->qual[schdata->l_cnt].s_steel_metal_worker = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Neurostimulator")
    schdata->qual[schdata->l_cnt].s_neurostimulator = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Eye, Ear , Orthopedic Prothesis")
    schdata->qual[schdata->l_cnt].s_prosthesis = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Claustrophobic")
    schdata->qual[schdata->l_cnt].s_claustrophobic = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3) IN ("Scheduling Height", "SCH Height"))
    schdata->qual[schdata->l_cnt].s_height = trim(sed.oe_field_display_value,3)
   ELSEIF (trim(oef.description,3) IN ("SCH Previous Surgery", "SCH PREVIOUS SURGERY"))
    schdata->qual[schdata->l_cnt].s_prev_surg = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3) IN ("SCH Previous Surgery Info", "SCH PREVIOUS SURGERY INFO"))
    schdata->qual[schdata->l_cnt].s_prev_surg_info = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Cerebral Aneurysm Clip")
    schdata->qual[schdata->l_cnt].s_cerebral_clip = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Pacemaker")
    schdata->qual[schdata->l_cnt].s_pacemaker = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Pacemaker MRI Compatible")
    schdata->qual[schdata->l_cnt].s_pacemaker_compatible = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Re-programable shunt")
    schdata->qual[schdata->l_cnt].s_shunt = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Internal Insulin Pump")
    schdata->qual[schdata->l_cnt].s_insulin_pump = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Requires Support")
    schdata->qual[schdata->l_cnt].s_life_support = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Can patient hold still for 30 minutes")
    schdata->qual[schdata->l_cnt].s_hold_still = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Implanted Zenith Aortic Stent")
    schdata->qual[schdata->l_cnt].s_stent = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Kidney Disease Lab Results")
    schdata->qual[schdata->l_cnt].s_kidney_lab_result = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Hypertension")
    schdata->qual[schdata->l_cnt].s_hypertension = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Hypertension Lab Results")
    schdata->qual[schdata->l_cnt].s_hypertension_lab_result = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Diabetic Lab Results")
    schdata->qual[schdata->l_cnt].s_diabetic_lab_result = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Relevant Imaging - Where")
    schdata->qual[schdata->l_cnt].s_relevant_imaging_where = sed.oe_field_display_value
   ELSEIF (trim(oef.description,3)="SCH Single Kidney")
    schdata->qual[schdata->l_cnt].s_single_kidney = sed.oe_field_display_value
   ENDIF
  WITH nocounter
 ;end select
 FOR (ml_cnt = 1 TO schdata->l_cnt)
   SET schdata->qual[ml_cnt].s_creat_order_status = "No Order"
   SET schdata->qual[ml_cnt].s_creat_order_dt = "N/A"
   SELECT INTO "nl:"
    FROM orders o,
     clinical_event ce,
     dummyt d1
    PLAN (o
     WHERE (o.person_id=schdata->qual[ml_cnt].f_person_id)
      AND o.catalog_cd=mf_creatinine_cd
      AND o.orig_order_dt_tm >= cnvtdatetime((curdate - 30),curtime3))
     JOIN (d1)
     JOIN (ce
     WHERE ce.order_id=o.order_id
      AND ce.event_cd IN (mf_creat_blood_cd, mf_gfrafricanamerican_cd, mf_gfrnonafricanamerican_cd)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    ORDER BY o.order_id
    HEAD o.order_id
     IF (o.order_status_cd != mf_completed_cd
      AND (((o.orig_order_dt_tm > schdata->qual[ml_cnt].f_creat_order_dt)) OR ((schdata->qual[ml_cnt]
     .f_creat_order_dt=0.0))) )
      schdata->qual[ml_cnt].f_creat_order_dt = o.orig_order_dt_tm, schdata->qual[ml_cnt].
      s_creat_order_dt = format(o.orig_order_dt_tm,";;q"), schdata->qual[ml_cnt].s_creat_order_status
       = uar_get_code_display(o.order_status_cd)
     ENDIF
     IF (o.order_status_cd=mf_completed_cd
      AND ce.event_cd IS NOT null
      AND (((o.status_dt_tm > schdata->qual[ml_cnt].f_creat_compl_status_dt)) OR ((schdata->qual[
     ml_cnt].f_creat_compl_status_dt=0.0))) )
      schdata->qual[ml_cnt].s_creat_compl_ord_dt = format(o.orig_order_dt_tm,";;q"), schdata->qual[
      ml_cnt].f_creat_compl_status_dt = o.status_dt_tm, schdata->qual[ml_cnt].s_creat_compl_status =
      uar_get_code_display(o.order_status_cd),
      ml_ord_result = 1
     ENDIF
    DETAIL
     IF (ml_ord_result=1)
      IF (ce.event_cd=mf_creat_blood_cd)
       schdata->qual[ml_cnt].f_creat_lab_dt = ce.valid_from_dt_tm, schdata->qual[ml_cnt].
       s_creat_lab_dt = format(ce.valid_from_dt_tm,";;q"), schdata->qual[ml_cnt].s_creat_result = ce
       .result_val
      ENDIF
      IF (ce.event_cd=mf_gfrafricanamerican_cd)
       schdata->qual[ml_cnt].f_gfrafrican_lab_dt = ce.valid_from_dt_tm, schdata->qual[ml_cnt].
       s_gfrafrican_lab_dt = format(ce.valid_from_dt_tm,";;q"), schdata->qual[ml_cnt].
       s_gfrafrican_result = ce.result_val
      ENDIF
      IF (ce.event_cd=mf_gfrnonafricanamerican_cd)
       schdata->qual[ml_cnt].f_gfrnonafrican_lab_dt = ce.valid_from_dt_tm, schdata->qual[ml_cnt].
       s_gfrnonafrican_lab_dt = format(ce.valid_from_dt_tm,";;q"), schdata->qual[ml_cnt].
       s_gfrnonafrican_result = ce.result_val
      ENDIF
     ENDIF
    FOOT  o.order_id
     ml_ord_result = 0
    WITH nocounter, outerjoin = d1
   ;end select
   SET schdata->qual[ml_cnt].s_diag_prob_diabetes = "No"
   SET schdata->qual[ml_cnt].s_diag_prob_hypertension = "No"
   SET schdata->qual[ml_cnt].s_diag_prob_kidney = "No"
   SET schdata->qual[ml_cnt].s_allergy = "No"
   SELECT INTO "nl:"
    FROM problem p,
     bhs_nomen_list bnl
    PLAN (p
     WHERE (p.person_id=schdata->qual[ml_cnt].f_person_id)
      AND p.active_ind=1
      AND p.end_effective_dt_tm > sysdate)
     JOIN (bnl
     WHERE bnl.nomenclature_id=p.nomenclature_id
      AND bnl.nomen_list_key IN ("RAD_DIABETES", "RAD_KIDNEY_DISEASE", "RAD_HYPERTENSION")
      AND bnl.active_ind=1)
    ORDER BY bnl.nomen_list_key
    HEAD bnl.nomen_list_key
     IF (bnl.nomen_list_key="RAD_HYPERTENSION")
      schdata->qual[ml_cnt].s_diag_prob_hypertension = "Yes"
     ELSEIF (bnl.nomen_list_key="RAD_DIABETES")
      schdata->qual[ml_cnt].s_diag_prob_diabetes = "Yes"
     ELSEIF (bnl.nomen_list_key="RAD_KIDNEY_DISEASE")
      schdata->qual[ml_cnt].s_diag_prob_kidney = "Yes"
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM diagnosis d,
     bhs_nomen_list bnl
    PLAN (d
     WHERE (d.person_id=schdata->qual[ml_cnt].f_person_id)
      AND d.active_ind=1
      AND d.end_effective_dt_tm > sysdate)
     JOIN (bnl
     WHERE bnl.nomenclature_id=d.nomenclature_id
      AND bnl.nomen_list_key IN ("RAD_DIABETES", "RAD_KIDNEY_DISEASE", "RAD_HYPERTENSION")
      AND bnl.active_ind=1)
    ORDER BY bnl.nomen_list_key
    HEAD bnl.nomen_list_key
     IF (bnl.nomen_list_key="RAD_HYPERTENSION")
      schdata->qual[ml_cnt].s_diag_prob_hypertension = "Yes"
     ELSEIF (bnl.nomen_list_key="RAD_DIABETES")
      schdata->qual[ml_cnt].s_diag_prob_diabetes = "Yes"
     ELSEIF (bnl.nomen_list_key="RAD_KIDNEY_DISEASE")
      schdata->qual[ml_cnt].s_diag_prob_kidney = "Yes"
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM allergy a,
     bhs_nomen_list bnl
    PLAN (a
     WHERE (a.person_id=schdata->qual[ml_cnt].f_person_id)
      AND a.active_ind=1
      AND a.end_effective_dt_tm > sysdate)
     JOIN (bnl
     WHERE bnl.nomen_list_key IN ("RAD_ALLERGY_CT", "RAD_ALLERGY_MRI")
      AND bnl.nomenclature_id=a.substance_nom_id
      AND bnl.active_ind=1)
    DETAIL
     IF (substring(1,2,trim(schdata->qual[ml_cnt].s_appt_type,3))="CT"
      AND bnl.nomen_list_key="RAD_ALLERGY_CT")
      schdata->qual[ml_cnt].s_allergy = "Yes"
     ENDIF
     IF (substring(1,3,trim(schdata->qual[ml_cnt].s_appt_type,3)) IN ("MRI", "MRA")
      AND bnl.nomen_list_key="RAD_ALLERGY_MRI")
      schdata->qual[ml_cnt].s_allergy = "Yes"
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 EXECUTE reportrtl
 FOR (ml_cnt = 1 TO schdata->l_cnt)
  IF (( $MF_ORD_TYPE=1)
   AND (schdata->qual[ml_cnt].s_appt_type="CT*")
   AND size(trim(schdata->qual[ml_cnt].s_past_reaction_contrast,3)) != 0
   AND size(trim(schdata->qual[ml_cnt].s_creat_compl_status,3))=0)
   CALL echo(schdata->qual[ml_cnt].s_person_name_full)
   CALL echo(schdata->qual[ml_cnt].s_person_weight)
   CALL echo(schdata->qual[ml_cnt].s_order_prov)
   CALL echo(schdata->qual[ml_cnt].s_appt_date)
   CALL echo(schdata->qual[ml_cnt].s_appt_time)
   CALL echo(schdata->qual[ml_cnt].s_appt_type)
   CALL echo(schdata->qual[ml_cnt].s_preauth)
   CALL echo(schdata->qual[ml_cnt].s_prev_surgery)
   CALL echo(schdata->qual[ml_cnt].s_rel_prev_films)
   CALL echo(schdata->qual[ml_cnt].s_order_delivery)
   SET d0 = sec_head(rpt_render)
   SET d0 = sec_patinfo_ct(rpt_render)
   SET d0 = sec_body_ct(rpt_render)
   SET d0 = sec_comment_ct(rpt_render)
   SET _yoffset = 10.18
   SET d0 = sec_foot(rpt_render)
   IF ((ml_cnt != schdata->l_cnt))
    SET d0 = pagebreak(0)
   ENDIF
  ENDIF
  IF (( $MF_ORD_TYPE=2)
   AND (schdata->qual[ml_cnt].s_appt_type IN ("MRI*", "MRA*"))
   AND size(trim(schdata->qual[ml_cnt].s_creat_compl_status,3))=0)
   CALL echo(schdata->qual[ml_cnt].s_person_name_full)
   CALL echo(schdata->qual[ml_cnt].s_person_weight)
   CALL echo(schdata->qual[ml_cnt].s_order_prov)
   CALL echo(schdata->qual[ml_cnt].s_appt_date)
   CALL echo(schdata->qual[ml_cnt].s_appt_time)
   CALL echo(schdata->qual[ml_cnt].s_appt_type)
   CALL echo(schdata->qual[ml_cnt].s_preauth)
   CALL echo(schdata->qual[ml_cnt].s_prev_surgery)
   CALL echo(schdata->qual[ml_cnt].s_rel_prev_films)
   CALL echo(schdata->qual[ml_cnt].s_order_delivery)
   SET d0 = sec_head(rpt_render)
   SET d0 = sec_patinfo_mri(rpt_render)
   SET d0 = sec_body_mri(rpt_render)
   SET d0 = sec_comment_mri(rpt_render)
   SET _yoffset = 10.35
   SET d0 = sec_foot(rpt_render)
   IF ((ml_cnt != schdata->l_cnt))
    SET d0 = pagebreak(0)
   ENDIF
  ENDIF
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
 CALL echorecord(schdata)
END GO
