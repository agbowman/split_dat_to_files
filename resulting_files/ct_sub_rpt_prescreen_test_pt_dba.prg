CREATE PROGRAM ct_sub_rpt_prescreen_test_pt:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Execution Mode:" = "",
  "Evaluation Start Date" = curdate,
  "Evaluation End Date" = curdate,
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Protocols to be Considered:" = "",
  "For Report Order By:" = 0,
  "Gender" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Evaluation By:" = 0
  WITH outdev, execmode, startdate,
  enddate, encntrtypecd, facilitycd,
  triggername, orderby, gender,
  qualifier, age1, age2,
  evalby
 EXECUTE reportrtl
 RECORD paramlists(
   1 etypecnt = i4
   1 eanyflag = i2
   1 equal[*]
     2 etypecd = f8
   1 faccnt = i4
   1 fanyflag = i2
   1 fqual[*]
     2 faccd = f8
   1 protcnt = i4
   1 pqual[*]
     2 primary_mnemonic = vc
 )
 RECORD protlist(
   1 protqual[*]
     2 primary_mnemonic = vc
     2 init_service = vc
     2 prot_master_id = f8
     2 personcnt = i4
     2 personqual[*]
       3 person_id = f8
       3 comment = vc
 )
 RECORD eksctrequest(
   1 opsind = i2
   1 execmodeflag = i2
   1 screenerid = f8
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
     2 currentct[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 checkct[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD eksctreply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_prescreen_results(dummy) = null WITH protect
 DECLARE updatequeryforevaluationby(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footreportsection_opsind_0(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footreportsection_opsind_0abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE footreportsection_ops_ind_0_line(ncalc=i2) = f8 WITH protect
 DECLARE footreportsection_ops_ind_0_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportsection_opsind_1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footreportsection_opsind_1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE footreportsection_opsind_1_line(ncalc=i2) = f8 WITH protect
 DECLARE footreportsection_opsind_1_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 IF (validate(_bsubreport) != 1)
  DECLARE _bsubreport = i1 WITH noconstant(0), protect
 ENDIF
 IF (_bsubreport=0)
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 ENDIF
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
 DECLARE _remlabel_rpt_pt_inquiry_rpt = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_total = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection_opsind_0 = i2 WITH noconstant(0), protect
 DECLARE _remlabel_title = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection_opsind_1 = i2 WITH noconstant(0), protect
 DECLARE _courier12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE evaluationbywherestring = vc WITH protect, noconstant("")
 DECLARE appointmentwherestring = vc WITH protect, noconstant("")
 DECLARE active_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE active_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 SUBROUTINE updatequeryforevaluationby(dummy)
  SET appointmentwherestring = "1=1"
  IF (( $EVALBY=0))
   SET evaluationbywherestring =
   "e.reg_dt_tm BETWEEN cnvtdatetime(startDtTm) and cnvtdatetime(endDtTm)"
  ELSEIF (( $EVALBY=1))
   SET evaluationbywherestring =
"((e.active_ind = 1 and e.active_status_cd = ACTIVE_CD                           and e.encntr_status_cd = ACTIVE_ENCNTR_CD)\
 OR (e.disch_dt_tm > cnvtdatetime(startDtTm)                           and e.reg_dt_tm < cnvtdatetime(endDtTm)))\
"
  ELSEIF (( $EVALBY=2))
   SET evaluationbywherestring = "e.encntr_id > 0.0"
   SET appointmentwherestring =
"sa.active_ind = 1 AND sa.encntr_id = e.encntr_id 			AND sa.beg_dt_tm BETWEEN cnvtdatetime(startDtTm) AND cnvtdatetime(endD\
tTm) 			AND sa.state_meaning in ('SCHEDULED', 'RESCHEDULED','CHECKED IN','CHECKED OUT','CONFIRMED')\
"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_prescreen_results(dummy)
   SELECT
    IF (( $EVALBY < 2))DISTINCT
     e.person_id, e.encntr_id, p.sex_cd,
     p.birth_dt_tm
     FROM encounter e,
      person p
     PLAN (e
      WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
       paramlists->equal[num].etypecd)))
       AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
       paramlists->fqual[num2].faccd)))
       AND parser(evaluationbywherestring))
      JOIN (p
      WHERE e.person_id=p.person_id
       AND parser(genderqual))
     ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
      p.person_id, e.reg_dt_tm DESC
    ELSE DISTINCT
     e.person_id, e.encntr_id, p.sex_cd,
     p.birth_dt_tm
     FROM encounter e,
      person p,
      sch_appt sa
     PLAN (e
      WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
       paramlists->equal[num].etypecd)))
       AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
       paramlists->fqual[num2].faccd)))
       AND parser(evaluationbywherestring))
      JOIN (p
      WHERE p.person_id=e.person_id
       AND parser(genderqual))
      JOIN (sa
      WHERE parser(appointmentwherestring))
     ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
      p.person_id, e.reg_dt_tm DESC
    ENDIF
    ORDER BY p.person_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), cnt = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     IF ((eksctrequest->opsind < 1))
      _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pageheight -
       rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection)
     ENDIF
     personage = (datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm,1)/ 365.25)
    HEAD p.person_id
     bfound = 0
     IF (age_qual != "1=1")
      IF (parser(age_qual))
       bfound = 1
      ELSE
       bfound = 0
      ENDIF
     ELSE
      bfound = 1
     ENDIF
     IF (bfound=1)
      interest = " ", cnt = (cnt+ 1)
     ENDIF
    DETAIL
     row + 0
    FOOT  p.person_id
     row + 0
    FOOT REPORT
     IF ((eksctrequest->opsind < 1))
      tmp_total = uar_i18nbuildmessage(i18nhandle,"TOTAL_PRESCREEN_RPT",
       "Total of %1 patient(s) found from %2 to %3.","iss",cnt,
       nullterm(trim(format(startdttm,"@LONGDATE;t(3);q"),3)),nullterm(trim(format(enddttm,
          "@LONGDATE;t(3);q"),3))), _bcontfootreportsection_opsind_0 = 0, bfirsttime = 1
      WHILE (((_bcontfootreportsection_opsind_0=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontfootreportsection_opsind_0, _fdrawheight = footreportsection_opsind_0(
         rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
        IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _fdrawheight = (_fdrawheight+ footreportsection_ops_ind_0_line(rpt_calcheight))
         ENDIF
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ footreportsection_opsind_1(rpt_calcheight,
           ((_fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
          IF (_bholdcontinue=1)
           _fdrawheight = (_fenddetail+ 1)
          ENDIF
         ENDIF
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _fdrawheight = (_fdrawheight+ footreportsection_opsind_1_line(rpt_calcheight))
         ENDIF
        ENDIF
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         CALL pagebreak(0)
        ELSEIF (_bholdcontinue=1
         AND _bcontfootreportsection_opsind_0=0)
         CALL pagebreak(0)
        ENDIF
        dummy_val = footreportsection_opsind_0(rpt_render,(_fenddetail - _yoffset),
         _bcontfootreportsection_opsind_0), bfirsttime = 0
      ENDWHILE
      _fdrawheight = footreportsection_ops_ind_0_line(rpt_calcheight)
      IF (_fdrawheight > 0)
       IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
        _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ footreportsection_opsind_1(rpt_calcheight,(
         (_fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
        IF (_bholdcontinue=1)
         _fdrawheight = (_fenddetail+ 1)
        ENDIF
       ENDIF
       IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
        _fdrawheight = (_fdrawheight+ footreportsection_opsind_1_line(rpt_calcheight))
       ENDIF
      ENDIF
      IF (((_yoffset+ _fdrawheight) > _fenddetail))
       CALL pagebreak(0)
      ENDIF
      dummy_val = footreportsection_ops_ind_0_line(rpt_render)
     ELSE
      tmp_total = uar_i18nbuildmessage(i18nhandle,"TOTAL_OPS_PRESCREEN_RPT",
       "Total of %1 patient(s) found from %2 to %3 will be evaluated for this test screening job.",
       "iss",cnt,
       nullterm(trim(format(startdttm,"@LONGDATE;t(3);q"),3)),nullterm(trim(format(enddttm,
          "@LONGDATE;t(3);q"),3))), _bcontfootreportsection_opsind_1 = 0, bfirsttime = 1
      WHILE (((_bcontfootreportsection_opsind_1=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontfootreportsection_opsind_1, _fdrawheight = footreportsection_opsind_1(
         rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
        IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _fdrawheight = (_fdrawheight+ footreportsection_opsind_1_line(rpt_calcheight))
         ENDIF
        ENDIF
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         CALL pagebreak(0)
        ELSEIF (_bholdcontinue=1
         AND _bcontfootreportsection_opsind_1=0)
         CALL pagebreak(0)
        ENDIF
        dummy_val = footreportsection_opsind_1(rpt_render,(_fenddetail - _yoffset),
         _bcontfootreportsection_opsind_1), bfirsttime = 0
      ENDWHILE
      _fdrawheight = footreportsection_opsind_1_line(rpt_calcheight)
      IF (((_yoffset+ _fdrawheight) > _fenddetail))
       CALL pagebreak(0)
      ENDIF
      dummy_val = footreportsection_opsind_1_line(rpt_render)
     ENDIF
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   IF (_bsubreport=0)
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
   ENDIF
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.520000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_pt_inquiry_rpt = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_pt_inquiry_rpt = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "PT_INQUIRY_RPT","Patient Inquiry Report"),char(0))), protect
   DECLARE __date = vc WITH noconstant(build2(trim(datestr),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_pt_inquiry_rpt = 1
    SET _remdate = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_pt_inquiry_rpt = _remlabel_rpt_pt_inquiry_rpt
   IF (_remlabel_rpt_pt_inquiry_rpt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_rpt_pt_inquiry_rpt,((size(__label_rpt_pt_inquiry_rpt) - _remlabel_rpt_pt_inquiry_rpt
       )+ 1),__label_rpt_pt_inquiry_rpt)))
    SET drawheight_label_rpt_pt_inquiry_rpt = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_pt_inquiry_rpt = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_pt_inquiry_rpt,((size(
        __label_rpt_pt_inquiry_rpt) - _remlabel_rpt_pt_inquiry_rpt)+ 1),__label_rpt_pt_inquiry_rpt)))
    ))
     SET _remlabel_rpt_pt_inquiry_rpt = (_remlabel_rpt_pt_inquiry_rpt+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_pt_inquiry_rpt = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_pt_inquiry_rpt)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate = (_remdate+ rptsd->m_drawlength)
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum = (growsum+ _remdate)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_rpt_pt_inquiry_rpt
   SET _dummyfont = uar_rptsetfont(_hreport,_courier12b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_pt_inquiry_rpt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rpt_pt_inquiry_rpt,((size(__label_rpt_pt_inquiry_rpt) -
       _holdremlabel_rpt_pt_inquiry_rpt)+ 1),__label_rpt_pt_inquiry_rpt)))
   ELSE
    SET _remlabel_rpt_pt_inquiry_rpt = _holdremlabel_rpt_pt_inquiry_rpt
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_date
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection_opsind_0(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection_opsind_0abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsection_opsind_0abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_total = f8 WITH noconstant(0.0), private
   DECLARE __label_total = vc WITH noconstant(build2(tmp_total,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_total = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_total = _remlabel_total
   IF (_remlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total,((size(
        __label_total) - _remlabel_total)+ 1),__label_total)))
    SET drawheight_label_total = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total,((size(__label_total) -
       _remlabel_total)+ 1),__label_total)))))
     SET _remlabel_total = (_remlabel_total+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_total
   IF (ncalc=rpt_render
    AND _holdremlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total,((size
       (__label_total) - _holdremlabel_total)+ 1),__label_total)))
   ELSE
    SET _remlabel_total = _holdremlabel_total
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.156),(offsetx+ 8.000),(offsety+
     0.156))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.219),(offsetx+ 8.000),(offsety+
     0.219))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection_ops_ind_0_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection_ops_ind_0_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsection_ops_ind_0_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection_opsind_1(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection_opsind_1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsection_opsind_1abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total = f8 WITH noconstant(0.0), private
   DECLARE __label_title = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,"TEST_SCREEN",
      "Pre-screen Test Report"),char(0))), protect
   DECLARE __date = vc WITH noconstant(build2(trim(datestr),char(0))), protect
   DECLARE __label_total = vc WITH noconstant(build2(tmp_total,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_title = 1
    SET _remdate = 1
    SET _remlabel_total = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_title = _remlabel_title
   IF (_remlabel_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_title,((size(
        __label_title) - _remlabel_title)+ 1),__label_title)))
    SET drawheight_label_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_title,((size(__label_title) -
       _remlabel_title)+ 1),__label_title)))))
     SET _remlabel_title = (_remlabel_title+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_title = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_title)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate = (_remdate+ rptsd->m_drawlength)
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum = (growsum+ _remdate)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _holdremlabel_total = _remlabel_total
   IF (_remlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total,((size(
        __label_total) - _remlabel_total)+ 1),__label_total)))
    SET drawheight_label_total = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total,((size(__label_total) -
       _remlabel_total)+ 1),__label_total)))))
     SET _remlabel_total = (_remlabel_total+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_title
   SET _dummyfont = uar_rptsetfont(_hreport,_courier12b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_title,((size
       (__label_title) - _holdremlabel_title)+ 1),__label_title)))
   ELSE
    SET _remlabel_title = _holdremlabel_title
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_date
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_total
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total,((size
       (__label_total) - _holdremlabel_total)+ 1),__label_total)))
   ELSE
    SET _remlabel_total = _holdremlabel_total
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.656),(offsetx+ 8.000),(offsety+
     0.656))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.720),(offsetx+ 8.000),(offsety+
     0.720))
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection_opsind_1_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection_opsind_1_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsection_opsind_1_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "CT_SUB_RPT_PRESCREEN_TEST_PT"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
    SET rptreport->m_marginleft = 0.25
    SET rptreport->m_marginright = 0.25
    SET rptreport->m_margintop = 0.25
    SET rptreport->m_marginbottom = 0.25
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
   ENDIF
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
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _courier12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_on
   SET _courier8b0 = uar_rptcreatefont(_hreport,rptfont)
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
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 CALL updatequeryforevaluationby(0)
 CALL get_prescreen_results(0)
 CALL finalizereport(_sendto)
 SET last_mod = "003"
 SET mod_date = "Dec 14, 2017"
END GO
