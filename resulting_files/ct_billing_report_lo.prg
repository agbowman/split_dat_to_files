CREATE PROGRAM ct_billing_report_lo
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Execution Mode" = 0,
  "Initiating Service" = 0,
  "Protocols" = 0,
  "Research Account" = "",
  "Output Mode" = 0
  WITH outdev, execmode, initservice,
  protocol, resacc, outmode
 EXECUTE reportrtl
 DECLARE iravalue = i4 WITH private
 RECORD label(
   1 rpt_title = vc
   1 rpt_exec_mode = vc
   1 prot_mnemonic_header = vc
   1 prot_status = vc
   1 principal_investigator = vc
   1 res_acc = vc
   1 prot_alias = vc
   1 prot_sponsor = vc
   1 enroll_id = vc
   1 encntr_type = vc
   1 order_name = vc
   1 order_type = vc
   1 order_id = vc
   1 action_date = vc
   1 powerplan_name = vc
   1 rpt_page = vc
   1 patient_name = vc
   1 mrn_no = vc
   1 date_of_birth = vc
   1 standard_of_care_label = vc
   1 order_status = vc
   1 order_placed_date = vc
   1 protocol_order_id = vc
   1 not_applicable = vc
 )
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_researchacc_ind = i2
   1 researchacc_cnt = i4
   1 research_accounts[*]
     2 research_acc_name = vc
 )
 RECORD sub_report(
   1 prot_iden_id = i4
   1 prot_deiden_id = i4
   1 ra_iden_id = i4
   1 ra_deiden_id = i4
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant(0), protect
 DECLARE _hreport = h WITH noconstant(0), protect
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
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF ( NOT (( $EXECMODE=- (1))))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_BILLING_REPORT_LO"
   SET rptreport->m_pagewidth = 9.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
   SET rptreport->m_margintop = 0.25
   SET rptreport->m_marginbottom = 0.25
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
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i4 WITH public, noconstant(0)
 DECLARE patient_cnt = i4 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE data = i2 WITH public, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET qual_list->all_protocols_ind = 0
 SET parmidx = 4
 IF (( $EXECMODE=0)
  AND reflect(parameter(parmidx,0))="I4")
  SET data = 0
 ELSEIF (( $EXECMODE=0))
  SET data = 1
  IF (reflect(parameter(parmidx,0))="C1")
   SET cnt = 0
   SET qual_list->all_protocols_ind = 1
  ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
   SET cnt = 1
   WHILE (reflect(parameter(parmidx,cnt)) > " ")
     IF (mod(cnt,10)=1)
      SET stat = alterlist(qual_list->protocols,(cnt+ 9))
     ENDIF
     SET qual_list->protocols[cnt].prot_master_id = cnvtreal(parameter(parmidx,cnt))
     SET cnt += 1
   ENDWHILE
   SET cnt -= 1
   SET qual_list->protocol_cnt = cnt
   SET stat = alterlist(qual_list->protocols,cnt)
  ELSEIF (reflect(parameter(parmidx,0))="F8")
   IF (cnvtreal(parameter(parmidx,1))=0.0)
    SET cnt = 0
    SET qual_list->all_protocols_ind = 1
   ELSE
    SET stat = alterlist(qual_list->protocols,1)
    SET qual_list->protocols[1].prot_master_id = cnvtreal(parameter(parmidx,1))
    SET qual_list->protocol_cnt = 1
   ENDIF
  ENDIF
 ENDIF
 SET qual_list->all_researchacc_ind = 0
 SET parmidx = 5
 SET iravalue = ichar( $RESACC)
 CALL echo(reflect(parameter(parmidx,0)))
 IF (( $EXECMODE=1)
  AND iravalue=0)
  SET data = 0
 ELSEIF (( $EXECMODE=1))
  SET data = 1
  IF (reflect(parameter(parmidx,0))="C1")
   SET cnt = 0
   SET qual_list->all_researchacc_ind = 1
  ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
   SET cnt = 1
   WHILE (reflect(parameter(parmidx,cnt)) > " ")
     IF (mod(cnt,10)=1)
      SET stat = alterlist(qual_list->research_accounts,(cnt+ 9))
     ENDIF
     SET qual_list->research_accounts[cnt].research_acc_name = parameter(parmidx,cnt)
     SET cnt += 1
   ENDWHILE
   SET cnt -= 1
   SET qual_list->researchacc_cnt = cnt
   SET stat = alterlist(qual_list->research_accounts,cnt)
  ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="C")
   SET stat = alterlist(qual_list->research_accounts,1)
   SET qual_list->research_accounts[1].research_acc_name = parameter(parmidx,cnt)
   SET qual_list->researchacc_cnt = 1
  ENDIF
 ENDIF
 CALL echorecord(qual_list)
 IF (( $EXECMODE=0)
  AND ( $OUTMODE=0))
  SET sub_report->prot_iden_id = 1
 ELSEIF (( $EXECMODE=0)
  AND ( $OUTMODE=1))
  SET sub_report->prot_deiden_id = 1
 ELSEIF (( $EXECMODE=1)
  AND ( $OUTMODE=0))
  SET sub_report->ra_iden_id = 1
 ELSEIF (( $EXECMODE=1)
  AND ( $OUTMODE=1))
  SET sub_report->ra_deiden_id = 1
 ENDIF
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"BILLING_RPORT","Billing Report")
 IF (( $EXECMODE=0))
  SET label->rpt_exec_mode = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Filtered by Protocol")
 ELSE
  SET label->rpt_exec_mode = uar_i18ngetmessage(i18nhandle,"FILT_RES_ACC",
   "Filtered by Research Account")
 ENDIF
 SET label->patient_name = uar_i18ngetmessage(i18nhandle,"PAT_NAME","Patient Name:")
 SET label->mrn_no = uar_i18ngetmessage(i18nhandle,"MRN_NO","MRN:")
 SET label->date_of_birth = uar_i18ngetmessage(i18nhandle,"DOB_DT","Date of Birth:")
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEM","Protocol Mnemonic:")
 SET label->prot_status = uar_i18ngetmessage(i18nhandle,"PROT_STAT","Protocol Status:")
 SET label->principal_investigator = uar_i18ngetmessage(i18nhandle,"PRIN_INV",
  "Principal Investigator:")
 SET label->prot_alias = uar_i18ngetmessage(i18nhandle,"PROT_ALIAS","Protocol Alias:")
 SET label->prot_sponsor = uar_i18ngetmessage(i18nhandle,"SPONS","Sponsor:")
 SET label->res_acc = uar_i18ngetmessage(i18nhandle,"RES_ACC","Billing Type")
 SET label->enroll_id = uar_i18ngetmessage(i18nhandle,"ENROLLMENT_ID","Enrollment ID:")
 SET label->encntr_type = uar_i18ngetmessage(i18nhandle,"ENCOUNTER_TYPE","Encounter Type")
 SET label->order_name = uar_i18ngetmessage(i18nhandle,"ORD_NAME","Order Name")
 SET label->order_type = uar_i18ngetmessage(i18nhandle,"ORD_TYPE","Order Type")
 SET label->order_id = uar_i18ngetmessage(i18nhandle,"ORD_ID","Order ID")
 SET label->action_date = uar_i18ngetmessage(i18nhandle,"ACTION_DATE","Action Date")
 SET label->powerplan_name = uar_i18ngetmessage(i18nhandle,"PP_NAME","PowerPlan Name")
 SET label->order_placed_date = uar_i18ngetmessage(i18nhandle,"OD_PLACED_DATE","Order Placed Date")
 SET label->order_status = uar_i18ngetmessage(i18nhandle,"OD_STAT","Order Status")
 SET label->standard_of_care_label = uar_i18ngetmessage(i18nhandle,"SOC_Lab","Standard of Care")
 SET label->protocol_order_id = uar_i18ngetmessage(i18nhandle,"PROT_OD_ID","Protocol Order ID:")
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 IF ((sub_report->prot_iden_id=1)
  AND data=1)
  SET _bsubreport = 1
  EXECUTE ct_sub_rpt_billing_rep_prot  $OUTDEV,  $EXECMODE,  $INITSERVICE,
   $PROTOCOL,  $RESACC,  $OUTMODE WITH replace("qual_list","qual_list")
  SET _bsubreport = 0
 ENDIF
 IF ((sub_report->prot_deiden_id=1)
  AND data=1)
  SET _bsubreport = 1
  EXECUTE ct_sub_rpt_di_billing_rep_prot  $OUTDEV,  $EXECMODE,  $INITSERVICE,
   $PROTOCOL,  $RESACC,  $OUTMODE WITH replace("qual_list","qual_list")
  SET _bsubreport = 0
 ENDIF
 IF ((sub_report->ra_iden_id=1)
  AND data=1)
  SET _bsubreport = 1
  EXECUTE ct_sub_rpt_billing_rep_ra  $OUTDEV,  $EXECMODE,  $INITSERVICE,
   $PROTOCOL,  $RESACC,  $OUTMODE WITH replace("qual_list","qual_list")
  SET _bsubreport = 0
 ENDIF
 IF ((sub_report->ra_deiden_id=1)
  AND data=1)
  SET _bsubreport = 1
  EXECUTE ct_sub_rpt_di_billing_rep_ra  $OUTDEV,  $EXECMODE,  $INITSERVICE,
   $PROTOCOL,  $RESACC,  $OUTMODE WITH replace("qual_list","qual_list")
  SET _bsubreport = 0
 ENDIF
 CALL finalizereport(_sendto)
 IF (data=0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    row + 1, outline = uar_i18ngetmessage(i18nhandle,"NO_RESULTS",
     "No results found for the selected parameters."), col 5,
    outline
   WITH nocounter
  ;end select
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Jul 21, 2019"
END GO
