CREATE PROGRAM ct_rpt_prescreen_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order report by:" = 0,
  "Prescreen Job:" = 0
  WITH outdev, orderby, jobid
 EXECUTE reportrtl
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD report_info(
   1 job_id = f8
   1 report_type_flag = i2
   1 screener_name = vc
   1 screened_dt_tm = dq8
   1 prot_list[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 init_service_cd = f8
     2 person_list[*]
       3 person_id = f8
       3 last_name = vc
       3 first_name = vc
       3 mrn_list[*]
         4 mrn = vc
         4 alias_pool_disp = vc
     2 qualified_num = i4
   1 pt_list[*]
     2 person_id = f8
     2 last_name = vc
     2 first_name = vc
     2 mrn_list[*]
       3 mrn = vc
       3 alias_pool_disp = vc
     2 prot_cnt = i2
     2 prot_list[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
       3 init_service_cd = f8
       3 qualified_num = i4
 )
 RECORD report_labels(
   1 rpt_test_screen = vc
   1 rpt_screen = vc
   1 rpt_prot_view = vc
   1 rpt_pt_view = vc
   1 rpt_protocol = vc
   1 rpt_init_service = vc
   1 rpt_last_name = vc
   1 rpt_first_name = vc
   1 rpt_mrn = vc
   1 rpt_pot_prots = vc
   1 rpt_pot_pts = vc
 )
 EXECUTE ct_rpt_prescreen_results:dba "NL:",  $ORDERBY,  $JOBID
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant(0), protect
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
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_PRESCREEN_LO"
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
   SET rptfont->m_recsize = 60
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom)
 IF ((report_info->report_type_flag=0))
  SET _bsubreport = 1
  EXECUTE ct_sub_prescreen_num_lo  $OUTDEV,  $ORDERBY,  $JOBID
  SET _bsubreport = 0
 ENDIF
 IF ((report_info->report_type_flag > 0)
  AND ( $ORDERBY=0))
  SET _bsubreport = 1
  EXECUTE ct_sub_prescreen_pt_lo  $OUTDEV,  $ORDERBY,  $JOBID
  SET _bsubreport = 0
 ENDIF
 IF ((report_info->report_type_flag > 0)
  AND ( $ORDERBY=1))
  SET _bsubreport = 1
  EXECUTE ct_sub_prescreen_person_lo  $OUTDEV,  $ORDERBY,  $JOBID
  SET _bsubreport = 0
 ENDIF
 CALL finalizereport(_sendto)
 SET last_mod = "000"
 SET mod_date = "Apr 18, 2016"
END GO
