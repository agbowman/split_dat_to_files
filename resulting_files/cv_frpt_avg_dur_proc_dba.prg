CREATE PROGRAM cv_frpt_avg_dur_proc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "I want to view" = 1,
  "Organization" = 0.0
  WITH outdev, start_date, end_date,
  u_view, org_id
 EXECUTE reportrtl
 RECORD reply_obj(
   1 cv_list[*]
     2 rpl_catalog_disp = vc
     2 rpl_full_name = vc
     2 rpl_dur_min = f8
     2 rpl_mth_yr = dq8
     2 rpl_day = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cv_username = vc
 DECLARE ccl_username(null) = null
 CALL ccl_username(0)
 SUBROUTINE ccl_username(dummy)
   IF ((reqinfo->updt_id=0))
    SET cv_username = curuser
   ELSE
    SELECT INTO "NL:"
     p.name_full_formatted
     FROM prsnl p
     WHERE (p.person_id=reqinfo->updt_id)
     DETAIL
      cv_username = substring(1,25,p.name_full_formatted)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 DECLARE cv_graphindex(p_graph_max=i4) = i4
 SUBROUTINE cv_graphindex(p_graph_max)
   IF (p_graph_max > 10000)
    RETURN((2000 * (((p_graph_max - 1)/ 2000)+ 1)))
   ELSEIF (p_graph_max > 2000)
    RETURN((500 * (((p_graph_max - 1)/ 500)+ 1)))
   ELSEIF (p_graph_max > 500)
    RETURN((100 * (((p_graph_max - 1)/ 100)+ 1)))
   ELSEIF (p_graph_max > 100)
    RETURN((20 * (((p_graph_max - 1)/ 20)+ 1)))
   ELSEIF (p_graph_max > 20)
    RETURN((5 * (((p_graph_max - 1)/ 5)+ 1)))
   ELSEIF (p_graph_max > 10)
    RETURN((2 * (((p_graph_max - 1)/ 2)+ 1)))
   ELSE
    RETURN(10)
   ENDIF
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
 DECLARE _hi18nhandle = i4 WITH public, noconstant(0)
 SET _hi18nhandle = 0
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 EXECUTE cv_frpt_avg_dur_drv "NL:",  $START_DATE,  $END_DATE,
  $ORG_ID
 EXECUTE ccl_rptapi_graphrec
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_reply_obj(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headyearsection(ncalc=i2) = f8 WITH protect
 DECLARE headyearsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headmonthsection(ncalc=i2) = f8 WITH protect
 DECLARE headmonthsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headdaysection(ncalc=i2) = f8 WITH protect
 DECLARE headdaysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footdaysection(ncalc=i2) = f8 WITH protect
 DECLARE footdaysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footmonthsection(ncalc=i2) = f8 WITH protect
 DECLARE footmonthsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footyearsection(ncalc=i2) = f8 WITH protect
 DECLARE footyearsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportsection(ncalc=i2) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE graphsection(ncalc=i2) = f8 WITH protect
 DECLARE graphsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE nodatasection(ncalc=i2) = f8 WITH protect
 DECLARE nodatasectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE getorgname(dummy) = null WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times10i0 = i4 WITH noconstant(0), protect
 DECLARE _times16b255 = i4 WITH noconstant(0), protect
 DECLARE _times12bu0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times108388608 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times18b128 = i4 WITH noconstant(0), protect
 DECLARE _pen10s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE sorgname = vc WITH protect
 SUBROUTINE getorgname(dummy)
   SELECT INTO "nl:"
    o.org_name
    FROM organization o
    WHERE (o.organization_id= $ORG_ID)
    DETAIL
     sorgname = o.org_name
   ;end select
 END ;Subroutine
 SUBROUTINE get_reply_obj(dummy)
  IF (( $ORG_ID=0.0))
   SET sorgname = uar_i18ngetmessage(_hi18nhandle,"ALL","All")
  ELSE
   CALL getorgname(0)
  ENDIF
  SELECT
   cv_year = year(reply_obj->cv_list[d1.seq].rpl_mth_yr), cv_month = month(reply_obj->cv_list[d1.seq]
    .rpl_mth_yr), cv_day = day(reply_obj->cv_list[d1.seq].rpl_day),
   cv_list_rpl_catalog_disp = substring(1,30,reply_obj->cv_list[d1.seq].rpl_catalog_disp),
   cv_list_rpl_full_name = substring(1,30,reply_obj->cv_list[d1.seq].rpl_full_name),
   cv_list_rpl_dur_min = reply_obj->cv_list[d1.seq].rpl_dur_min,
   cv_list_rpl_mth_yr = reply_obj->cv_list[d1.seq].rpl_mth_yr, cv_list_rpl_day = reply_obj->cv_list[
   d1.seq].rpl_day
   FROM (dummyt d1  WITH seq = value(size(reply_obj->cv_list,5)))
   PLAN (d1)
   ORDER BY cv_year, cv_month, cv_day
   HEAD REPORT
    _d0 = cv_list_rpl_day, sdate = format(cnvtdatetime( $START_DATE),"@SHORTDATE;;D"), edate = format
    (cnvtdatetime( $END_DATE),"@SHORTDATE;;D"),
    gtotal_avg = 0, total_cnt = 0, total_avg = 0,
    tday_avg = 0, tmonth_avg = 0, month_avg = 0,
    month_cnt = 0, tproc_performed = 0, proc_performed = 0,
    tgraph = 0, max_tgraph = 0, graph_max = 0,
    p_curr = 0, p_max = 0, noffsetvar = 0,
    ndaylightvar = 0, stimezone = datetimezonebyindex(curtimezoneapp,noffsetvar,ndaylightvar,7,
     cnvtdatetime(curdate,curtime)), _fenddetail = (rptreport->m_pageheight - rptreport->
    m_marginbottom),
    _fenddetail = (_fenddetail - footpagesection(rpt_calcheight)), _fdrawheight = headreportsection(
     rpt_calcheight)
    IF ((_fenddetail > (_yoffset+ _fdrawheight)))
     _fdrawheight = (_fdrawheight+ nodatasection(rpt_calcheight))
    ENDIF
    IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
     CALL pagebreak(0)
    ENDIF
    dummy_val = headreportsection(rpt_render), _fdrawheight = nodatasection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
     CALL pagebreak(0)
    ENDIF
    dummy_val = nodatasection(rpt_render), stat = alterlist(rptgraphrec->m_series,1), rptgraphrec->
    m_series[1].name = "Month Avg",
    rptgraphrec->m_series[1].color = uar_rptencodecolor(0,0,255), _nfieldscnt = 1
   HEAD PAGE
    IF (curpage > 1)
     dummy_val = pagebreak(0)
    ENDIF
    dummy_val = headpagesection(rpt_render)
   HEAD cv_year
    _fdrawheight = headyearsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headyearsection(rpt_render)
   HEAD cv_month
    cur_year = format(year(cv_list_rpl_mth_yr),"####"), cur_month = format(cv_list_rpl_mth_yr,
     "MMMMMMMMM;;D"), tmonth_avg = 0,
    month_avg = 0, month_cnt = 0, _fdrawheight = headmonthsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headmonthsection(rpt_render)
   HEAD cv_day
    _fdrawheight = headdaysection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headdaysection(rpt_render)
   DETAIL
    total_avg = (total_avg+ cv_list_rpl_dur_min), total_cnt = (total_cnt+ 1), month_avg = (month_avg
    + cv_list_rpl_dur_min),
    month_cnt = (month_cnt+ 1), proc_performed = (proc_performed+ 1), _fdrawheight = detailsection(
     rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = detailsection(rpt_render)
   FOOT  cv_day
    tday_avg = avg(cv_list_rpl_dur_min), tproc_performed = (proc_performed+ tproc_performed),
    _fdrawheight = footdaysection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footdaysection(rpt_render), proc_performed = 0
   FOOT  cv_month
    tmonth_avg = (month_avg/ month_cnt), tgraph = tmonth_avg, p_curr = tmonth_avg
    IF (p_curr >= p_max)
     p_max = p_curr
    ENDIF
    _fdrawheight = footmonthsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footmonthsection(rpt_render), tproc_performed = 0, stat = alterlist(rptgraphrec->
     m_labels,_nfieldscnt),
    rptgraphrec->m_labels[_nfieldscnt].label = build2(concat(cur_month,"-",cur_year),char(0)), stat
     = alterlist(rptgraphrec->m_series[1].y_values,_nfieldscnt), rptgraphrec->m_series[1].y_values[
    _nfieldscnt].y_f8 = tgraph,
    _nfieldscnt = (_nfieldscnt+ 1)
   FOOT  cv_year
    _fdrawheight = footyearsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footyearsection(rpt_render)
   FOOT PAGE
    _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
    _yoffset = _yhold
   FOOT REPORT
    gtotal_avg = (total_avg/ total_cnt), max_tgraph = p_max, graph_max = cv_graphindex(max_tgraph),
    _fdrawheight = graphsection(rpt_calcheight)
    IF ((_fenddetail > (_yoffset+ _fdrawheight)))
     _fdrawheight = (_fdrawheight+ footreportsection(rpt_calcheight))
    ENDIF
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     CALL pagebreak(0)
    ENDIF
    dummy_val = graphsection(rpt_render), _fdrawheight = footreportsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     CALL pagebreak(0)
    ENDIF
    dummy_val = footreportsection(rpt_render)
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 4.875
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times18b128)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadReportSection_FieldName0","Average Duration of Procedures"),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.313),(offsety+ 1.255),(offsetx+ 6.605),(offsety+
     1.255))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 0.838)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "FROM","From")," ",sdate,uar_i18ngetmessage(_hi18nhandle,"TO"," To")," ",
       edate),char(0)))
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 4.195)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "ORGANIZATION","Organization: "),sorgname),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "GENERATEDON","Generated on:")," ",format(curdate,"@SHORTDATE")," ",format(curtime,"hh:mm;;s"
        ),
       " ",stimezone),char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "GENERATEDBY","Generated by:")," ",cv_username),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.438)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times12bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadPageSection_FieldName0","Month-Year"),char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 2.413
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadPageSection_FieldName1","Procedure Start Date"),char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadPageSection_FieldName3","Average duration (min)"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headyearsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headyearsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headyearsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headmonthsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headmonthsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headmonthsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(cur_month," - ",cur_year),char(
       0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headdaysection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headdaysectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headdaysectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.177
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (day(cv_list_rpl_day) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(day(cv_list_rpl_day)),char
       (0)))
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
  DECLARE sectionheight = f8 WITH noconstant(0.070000), private
  RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footdaysection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footdaysectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footdaysectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.177
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(cnvtstring(tday_avg)),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footmonthsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footmonthsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footmonthsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 128
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 4.000
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times108388608)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(trim(cnvtstring(tproc_performed
         )),uar_i18ngetmessage(_hi18nhandle,"PROCEDURESPERFORMED"," Procedure(s) performed in  ")," ",
       trim(cur_month,3),uar_i18ngetmessage(_hi18nhandle,"AVERAGING",", averaging:")),char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(cnvtstring(tmonth_avg)),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.000),(offsety+ 0.032),(offsetx+ 7.188),(offsety+
     0.032))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footyearsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footyearsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footyearsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
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
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.563)
    SET rptsd->m_width = 2.045
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "FootReportSection_FieldName2","*** End of Report ***"),char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(trim(cnvtstring(total_cnt)),
       uar_i18ngetmessage(_hi18nhandle,"PROCEDURESAVERAGE",
        "Procedures performed with a monthly average of:  "),trim(cnvtstring(gtotal_avg)),
       uar_i18ngetmessage(_hi18nhandle,"MIN"," min")),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.313),(offsety+ 0.131),(offsetx+ 7.188),(offsety+
     0.131))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE graphsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = graphsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE graphsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.420000), private
   IF ( NOT (((( $U_VIEW=2)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
    SET rptgraphrec->m_ntype = 2
    SET rptgraphrec->m_fleft = (1.000000+ offsetx)
    SET rptgraphrec->m_ftop = (0.063000+ offsety)
    SET rptgraphrec->m_fwidth = 5.375000
    SET rptgraphrec->m_fheight = 3.250000
    SET rptgraphrec->m_stitle = ""
    SET rptgraphrec->m_ssubtitle = ""
    SET rptgraphrec->m_sxtitle = uar_i18ngetmessage(_hi18nhandle,"MONYEAR","Month-Year")
    SET rptgraphrec->m_lstxtitle.m_sfontname = rpt_times
    SET rptgraphrec->m_lstxtitle.m_nfontsize = 10
    SET rptgraphrec->m_lstxtitle.m_bold = rpt_on
    SET rptgraphrec->m_lstxtitle.m_italic = rpt_off
    SET rptgraphrec->m_lstxtitle.m_underline = rpt_off
    SET rptgraphrec->m_lstxtitle.m_strikethrough = rpt_off
    SET rptgraphrec->m_lstxtitle.m_nbackmode = 0
    SET rptgraphrec->m_lstxtitle.m_rgbbackcolor = rpt_white
    SET rptgraphrec->m_lstxtitle.m_rgbfontcolor = rpt_black
    SET rptgraphrec->m_sytitle = uar_i18ngetmessage(_hi18nhandle,"PROCAVERAGE","Procedure's average")
    SET rptgraphrec->m_lstytitle.m_sfontname = rpt_times
    SET rptgraphrec->m_lstytitle.m_nfontsize = 10
    SET rptgraphrec->m_lstytitle.m_bold = rpt_on
    SET rptgraphrec->m_lstytitle.m_italic = rpt_off
    SET rptgraphrec->m_lstytitle.m_underline = rpt_off
    SET rptgraphrec->m_lstytitle.m_strikethrough = rpt_off
    SET rptgraphrec->m_lstytitle.m_nbackmode = 0
    SET rptgraphrec->m_lstytitle.m_rgbbackcolor = rpt_white
    SET rptgraphrec->m_lstytitle.m_rgbfontcolor = rpt_black
    SET rptgraphrec->m_bxgrid = 0
    SET rptgraphrec->m_bygrid = 1
    SET rptgraphrec->m_nytype = 1
    SET rptgraphrec->m_syformat = ""
    SET rptgraphrec->m_syformat = ""
    SET rptgraphrec->m_fyindex = 0
    SET rptgraphrec->m_bymin = 1
    SET rptgraphrec->m_fymin = 0
    SET rptgraphrec->m_bymax = 1
    SET rptgraphrec->m_fymax = ((1+ graph_max) - 1)
    SET rptgraphrec->m_blegend = 0
    SET rptgraphrec->m_nlegendpos = 1
    SET rptgraphrec->m_lstlegend.m_sfontname = rpt_times
    SET rptgraphrec->m_lstlegend.m_nfontsize = 10
    SET rptgraphrec->m_lstlegend.m_bold = rpt_off
    SET rptgraphrec->m_lstlegend.m_italic = rpt_off
    SET rptgraphrec->m_lstlegend.m_underline = rpt_off
    SET rptgraphrec->m_lstlegend.m_strikethrough = rpt_off
    SET rptgraphrec->m_lstlegend.m_nbackmode = 0
    SET rptgraphrec->m_lstlegend.m_rgbbackcolor = rpt_white
    SET rptgraphrec->m_lstlegend.m_rgbfontcolor = rpt_black
    SET rptgraphrec->m_nlegendbkmode = 0
    SET rptgraphrec->m_rgblegendbkcolor = uar_rptencodecolor(192,192,192)
    SET rptgraphrec->m_nbkmode = 0
    SET rptgraphrec->m_rgbbkcolor = uar_rptencodecolor(192,192,192)
    SET rptgraphrec->m_fbordersize = 0.010
    SET rptgraphrec->m_rgbbordercolor = rpt_black
    SET rptgraphrec->m_nborderstyle = 0
    SET rptgraphrec->m_bshadow = 0
    SET rptgraphrec->m_ngridbkmode = 1
    SET rptgraphrec->m_rgbgridbkcolor = uar_rptencodecolor(192,192,192)
    SET rptgraphrec->m_rgbgridcolor = rpt_black
    SET rptgraphrec->m_fgridsize = 0.01
    SET rptgraphrec->m_ngridstyle = 0
    SET rptgraphrec->m_lstxgrid.m_sfontname = rpt_times
    SET rptgraphrec->m_lstxgrid.m_nfontsize = 10
    SET rptgraphrec->m_lstxgrid.m_bold = rpt_off
    SET rptgraphrec->m_lstxgrid.m_italic = rpt_off
    SET rptgraphrec->m_lstxgrid.m_underline = rpt_off
    SET rptgraphrec->m_lstxgrid.m_strikethrough = rpt_off
    SET rptgraphrec->m_lstxgrid.m_nbackmode = 0
    SET rptgraphrec->m_lstxgrid.m_rgbbackcolor = rpt_white
    SET rptgraphrec->m_lstxgrid.m_rgbfontcolor = rpt_black
    SET rptgraphrec->m_lstygrid.m_sfontname = rpt_times
    SET rptgraphrec->m_lstygrid.m_nfontsize = 10
    SET rptgraphrec->m_lstygrid.m_bold = rpt_off
    SET rptgraphrec->m_lstygrid.m_italic = rpt_off
    SET rptgraphrec->m_lstygrid.m_underline = rpt_off
    SET rptgraphrec->m_lstygrid.m_strikethrough = rpt_off
    SET rptgraphrec->m_lstygrid.m_nbackmode = 0
    SET rptgraphrec->m_lstygrid.m_rgbbackcolor = rpt_white
    SET rptgraphrec->m_lstygrid.m_rgbfontcolor = rpt_black
    SET rptgraphrec->m_ncontrollimits = 0
    EXECUTE ccl_rptapi_graph
    SET stat = initrec(rptgraphrec)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE nodatasection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = nodatasectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE nodatasectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.240000), private
   IF ( NOT (size(reply_obj->cv_list,5) <= 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times16b255)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "NoDataSection_FieldName0","No data found! Try modifying starting/ending dates!"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CV_FRPT_AVG_DUR_PROC"
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
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 18
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_rgbcolor = rpt_maroon
   SET _times18b128 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_on
   SET rptfont->m_rgbcolor = rpt_black
   SET _times10i0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_on
   SET _times12bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_rgbcolor = rpt_navy
   SET _times108388608 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_rgbcolor = rpt_black
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 14
   SET rptfont->m_rgbcolor = rpt_red
   SET _times16b255 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 3
   SET _pen14s3c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010
   SET rptpen->m_penstyle = 0
   SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL get_reply_obj(0)
 CALL finalizereport(_sendto)
END GO
