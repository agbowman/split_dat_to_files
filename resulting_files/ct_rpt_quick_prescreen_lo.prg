CREATE PROGRAM ct_rpt_quick_prescreen_lo
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Evaluation Start Date" = "CURDATE",
  "Evaluation End Date" = "CURDATE",
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Sex" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Race" = 0.000000,
  "Ethnicity" = 0.000000,
  "Terminology Codes" = "0.000000",
  "Codes" = "",
  "Evaluation by:" = 0,
  "triggerID" = 0,
  "icd10DefaultHidden" = ""
  WITH outdev, startdate, enddate,
  encntrtypecd, facilitycd, sex,
  qualifier, age1, age2,
  race, ethnicity, terminology,
  codes, evalby, triggerid,
  icd10defaulthidden
 EXECUTE reportrtl
 RECORD badcodes(
   1 list[*]
     2 code = vc
 )
 RECORD uniquevalues(
   1 list[*]
     2 value = vc
 )
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(3.020000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.688
    SET rptsd->m_height = 1.063
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "==================================================================================================",
       _crlf,
       "Your prescreening job has started. The status of the job can be monitored in the Prescreened Patients view.",
       _crlf,
       "=================================================================================================="
       ),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.323
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Quick Prescreening",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.136
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(cnvtdatetime(sysdate),";;q"),
      char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_QUICK_PRESCREEN_LO"
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_bold = rpt_on
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
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
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
   1 pref_value = i4
   1 pref_values[*]
     2 values = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE startdttm = dq8 WITH public
 DECLARE enddttm = dq8 WITH public
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE etypecnt = i4 WITH public
 DECLARE eparse = c20 WITH public
 DECLARE bset = i2 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE faccnt = i4 WITH public, noconstant(0)
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE terminologycd = f8 WITH public, noconstant(0.0)
 DECLARE dxcodelist = vc WITH public, noconstant("")
 DECLARE dxcodecnt = i4 WITH public, noconstant(0)
 DECLARE date_err = i4 WITH public, noconstant(0)
 DECLARE code_err = i4 WITH public, noconstant(0)
 DECLARE badcode = vc WITH public
 DECLARE not_found = vc WITH public, constant("<next_piece_not_found>")
 DECLARE max_date_range = i4 WITH public, noconstant(0)
 SET ct_get_pref_request->pref_entry = "prescreen_max_date_range"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
  "CT_GET_PREF_REPLY")
 SET max_date_range = ct_get_pref_reply->pref_value
 IF (( $STARTDATE=null))
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    row + 1, outline = uar_i18ngetmessage(i18nhandle,"NO_PT_PRESCREEN_RPT",
     "Evaluation Start Date is required. Enter an evaluation start date to continue."), col 5,
    outline
   WITH nocounter
  ;end select
  GO TO endprogram
 ELSEIF (( $ENDDATE=null))
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    row + 1, outline = uar_i18ngetmessage(i18nhandle,"NO_PT_PRESCREEN_RPT",
     "Evaluation End Date is required. Enter an evaluation end date to continue."), col 5,
    outline
   WITH nocounter
  ;end select
  GO TO endprogram
 ELSEIF (datetimediff(cnvtdatetime( $STARTDATE),cnvtdatetime( $ENDDATE)) > 0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    row + 1, outline = uar_i18ngetmessage(i18nhandle,"NO_PT_PRESCREEN_RPT",
     "Evaluation Start Date cannot be after Evaluation End Date."), col 5,
    outline
   WITH nocounter
  ;end select
  GO TO endprogram
 ELSEIF (datetimediff(cnvtdatetime( $ENDDATE),cnvtdatetime( $STARTDATE),1) > max_date_range
  AND max_date_range != 0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    row + 1, outline = uar_i18ngetmessage(i18nhandle,"NO_PT_PRESCREEN_RPT",
     "Pre-screening cannot be initiated. Date range selected exceeds the prescreen_max_date_range preference value."
     ), col 5,
    outline, row + 1, outline = uar_i18ngetmessage(i18nhandle,"NO_PT_PRESCREEN_RPT",
     "Please select a more limited date range and run pre-screening again."),
    col 5, outline
   WITH nocounter
  ;end select
  GO TO endprogram
 ENDIF
 SET terminologycd = cnvtreal( $TERMINOLOGY)
 SET dxcodelist = trim( $CODES,4)
 SET dxcodelist = replace(dxcodelist,'"',"",0)
 SET dxcodelist = replace(dxcodelist,"'","",0)
 SET dxcodelist = cleancsvlist(dxcodelist)
 IF (dxcodelist != "")
  CALL verifydiagnosiscodes(terminologycd,dxcodelist)
 ENDIF
 IF (date_err != 1
  AND code_err != 1)
  EXECUTE ct_quick_prescreen:dba  $OUTDEV,  $STARTDATE,  $ENDDATE,
   $ENCNTRTYPECD,  $FACILITYCD,  $SEX,
   $QUALIFIER,  $AGE1,  $AGE2,
   $RACE,  $ETHNICITY,  $TERMINOLOGY,
   $CODES,  $EVALBY,  $TRIGGERID
 ENDIF
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET _fdrawheight = detailsection(rpt_calcheight)
 IF (((_yoffset+ _fdrawheight) > _fenddetail))
  CALL pagebreak(0)
 ENDIF
 SET dummy_val = detailsection(rpt_render)
 CALL finalizereport(_sendto)
 SUBROUTINE verifydiagnosiscodes(sourcecd,diagnosislist)
   IF (sourcecd > 0
    AND size(diagnosislist) > 0)
    DECLARE tmp = vc WITH protect, noconstant("")
    DECLARE pieceidx = i4 WITH protect, noconstant(1)
    DECLARE badcnt = i4 WITH protect, noconstant(0)
    WHILE (tmp != not_found
     AND pieceidx < 100)
      SET tmp = piece(diagnosislist,",",pieceidx,not_found)
      SET pieceidx += 1
      IF (tmp != not_found)
       SELECT DISTINCT
        n.source_identifier
        FROM nomenclature n
        WHERE n.source_vocabulary_cd=sourcecd
         AND n.active_ind=1
         AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
         AND n.source_identifier=tmp
        WITH nocounter, time = 5
       ;end select
       IF (curqual=0)
        SET badcnt += 1
        IF (mod(badcnt,10)=1)
         SET stat = alterlist(badcodes->list,(badcnt+ 9))
        ENDIF
        SET badcodes->list[badcnt].code = tmp
       ENDIF
      ENDIF
    ENDWHILE
    IF (badcnt > 0)
     SET stat = alterlist(badcodes->list,badcnt)
     SELECT INTO  $OUTDEV
      FROM (dummyt d  WITH seq = badcnt)
      HEAD REPORT
       row + 1, outline = uar_i18ngetmessage(i18nhandle,"DX_CODE_ERROR_1",
        "The following codes are invalid:"), col 5,
       outline
      DETAIL
       row + 1, col 10, badcodes->list[d.seq].code
      FOOT REPORT
       row + 2, outline = uar_i18ngetmessage(i18nhandle,"DX_CODE_ERROR_2",
        "Please correct the codes and try again."), col 5,
       outline
      WITH nocounter
     ;end select
     GO TO endprogram
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE cleancsvlist(csvlist)
   DECLARE cleanedlist = vc WITH protect, noconstant("")
   IF (size(csvlist) > 0)
    DECLARE tmp = vc WITH protect, noconstant("")
    DECLARE pieceidx = i4 WITH protect, noconstant(1)
    DECLARE uniquecnt = i4 WITH protect, noconstant(0)
    DECLARE found = i2 WITH protect, noconstant(0)
    WHILE (tmp != not_found
     AND pieceidx < 100)
      SET tmp = piece(csvlist,",",pieceidx,not_found)
      SET pieceidx += 1
      IF (tmp != not_found
       AND textlen(tmp) > 0)
       SET found = 0
       IF (uniquecnt > 0)
        FOR (i = 1 TO uniquecnt)
          IF ((uniquevalues->list[i].value=tmp))
           SET found = 1
          ENDIF
        ENDFOR
       ENDIF
       IF (found=0)
        SET uniquecnt += 1
        IF (mod(uniquecnt,10)=1)
         SET stat = alterlist(uniquevalues->list,(uniquecnt+ 9))
        ENDIF
        SET uniquevalues->list[uniquecnt].value = tmp
       ENDIF
      ENDIF
    ENDWHILE
    IF (uniquecnt > 0)
     SET stat = alterlist(uniquevalues->list,uniquecnt)
     FOR (i = 1 TO uniquecnt)
       IF (i=1)
        SET cleanedlist = uniquevalues->list[i].value
       ELSE
        SET cleanedlist = build(cleanedlist,",",uniquevalues->list[i].value)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(cleanedlist)
 END ;Subroutine
#endprogram
END GO
