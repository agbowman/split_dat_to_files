CREATE PROGRAM cv_frpt_outsd_proc
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
     2 rpl_provider_name = vc
     2 rpl_status_disp = vc
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
 SUBROUTINE (cv_graphindex(p_graph_max=i4) =i4)
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
 EXECUTE cv_frpt_outsd_proc_drv "NL:",  $START_DATE,  $END_DATE,
  $ORG_ID
 EXECUTE ccl_rptapi_graphrec
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_reply_obj(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE getorgname(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _hi18nhandle = i4 WITH noconstant(0), protect
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
 DECLARE _times10b8404992 = i4 WITH noconstant(0), protect
 DECLARE _times20b13209 = i4 WITH noconstant(0), protect
 DECLARE _times16b255 = i4 WITH noconstant(0), protect
 DECLARE _times12bu0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10255 = i4 WITH noconstant(0), protect
 DECLARE _pen10s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s2c0 = i4 WITH noconstant(0), protect
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
   cv_list_rpl_catalog_disp = substring(1,50,reply_obj->cv_list[d1.seq].rpl_catalog_disp),
   cv_list_rpl_provider_name = substring(1,30,reply_obj->cv_list[d1.seq].rpl_provider_name),
   cv_list_rpl_status_disp = substring(1,30,reply_obj->cv_list[d1.seq].rpl_status_disp)
   FROM (dummyt d1  WITH seq = value(size(reply_obj->cv_list,5)))
   PLAN (d1)
   ORDER BY cv_list_rpl_provider_name, cv_list_rpl_catalog_disp, cv_list_rpl_status_disp
   HEAD REPORT
    _d0 = cv_list_rpl_catalog_disp, _d1 = cv_list_rpl_provider_name, _d2 = cv_list_rpl_status_disp,
    sdate = format(cnvtdatetime(cnvtdate2( $START_DATE,"DD-MMM-YYYY"),0),"@SHORTDATE"), edate =
    format(cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),235959),"@SHORTDATE"), i18nhandle = 0,
    noffsetvar = 0, ndaylightvar = 0, stimezone = datetimezonebyindex(curtimezoneapp,noffsetvar,
     ndaylightvar,7,cnvtdatetime(curdate,curtime)),
    total_cnt = 0, gtotal_cnt = 0, tgraph_cnt = 0,
    graph_max = 0, tprovider = 0, proc_cnt = 0,
    tgraph = 0, max_tgraph = 0, graph_max = 0,
    p_curr = 0, p_max = 0, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom),
    _fenddetail -= footpagesection(rpt_calcheight), _fdrawheight = headreportsection(rpt_calcheight)
    IF ((_fenddetail > (_yoffset+ _fdrawheight)))
     _fdrawheight += nodatasection(rpt_calcheight)
    ENDIF
    IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
     CALL pagebreak(0)
    ENDIF
    dummy_val = headreportsection(rpt_render), _fdrawheight = nodatasection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
     CALL pagebreak(0)
    ENDIF
    dummy_val = nodatasection(rpt_render), stat = alterlist(rptgraphrec->m_series,1), rptgraphrec->
    m_series[1].name = "Graph",
    rptgraphrec->m_series[1].color = uar_rptencodecolor(0,0,255), _nfieldscnt = 1
   HEAD PAGE
    IF (curpage > 1)
     dummy_val = pagebreak(0)
    ENDIF
    dummy_val = headpagesection(rpt_render)
   HEAD cv_list_rpl_provider_name
    _fdrawheight = headprovidername(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headprovidername(rpt_render)
   HEAD cv_list_rpl_catalog_disp
    _fdrawheight = headcatalogdispsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headcatalogdispsection(rpt_render)
   HEAD cv_list_rpl_status_disp
    _fdrawheight = headcatalogstatusdispsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headcatalogstatusdispsection(rpt_render)
   DETAIL
    total_cnt += 1, _fdrawheight = detailsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = detailsection(rpt_render)
   FOOT  cv_list_rpl_status_disp
    proc_cnt = total_cnt, gtotal_cnt += total_cnt, tprovider += total_cnt,
    tgraph_cnt = (total_cnt+ tgraph_cnt), _fdrawheight = footcatalogstatusdispsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footcatalogstatusdispsection(rpt_render), total_cnt = 0, proc_cnt = 0
   FOOT  cv_list_rpl_catalog_disp
    _fdrawheight = footcatalogdispsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footcatalogdispsection(rpt_render)
   FOOT  cv_list_rpl_provider_name
    tgraph = tgraph_cnt, p_curr = tgraph_cnt
    IF (p_curr >= p_max)
     p_max = p_curr
    ENDIF
    _fdrawheight = footprovidername(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footprovidername(rpt_render), tgraph_cnt = 0, tprovider = 0,
    stat = alterlist(rptgraphrec->m_labels,_nfieldscnt), rptgraphrec->m_labels[_nfieldscnt].label =
    build2(
     IF (trim(cv_list_rpl_provider_name)=null) "No Provider Entered"
     ELSE cv_list_rpl_provider_name
     ENDIF
     ,char(0)), stat = alterlist(rptgraphrec->m_series[1].y_values,_nfieldscnt),
    rptgraphrec->m_series[1].y_values[_nfieldscnt].y_f8 = tgraph, _nfieldscnt += 1
   FOOT PAGE
    _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
    _yoffset = _yhold
   FOOT REPORT
    max_tgraph = p_max, graph_max = cv_graphindex(max_tgraph), _fdrawheight = graphsection(
     rpt_calcheight)
    IF ((_fenddetail > (_yoffset+ _fdrawheight)))
     _fdrawheight += footreportsection(rpt_calcheight)
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.400000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),(offsety+ 1.318),(offsetx+ 7.000),(offsety+
     1.318))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 0.788)
    SET rptsd->m_width = 2.719
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "FROM","From")," ",sdate,uar_i18ngetmessage(_hi18nhandle,"TO"," To")," ",
       edate),char(0)))
    SET rptsd->m_y = (offsety+ 1.063)
    SET rptsd->m_x = (offsetx+ 4.195)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "ORGANIZATION","Organization: "),sorgname),char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 3.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "GENERATEDON","Generated on:")," ",format(curdate,"@SHORTDATE")," ",format(curtime,"hh:mm;;s"
        ),
       " ",stimezone),char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 3.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "GENERATEDBY","Generated by: ")," ",cv_username),char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.344
    SET _oldfont = uar_rptsetfont(_hreport,_times20b13209)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "OUTSTANDINGPROCEDURES","Outstanding Procedures")),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
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
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.405
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times12bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "PROVIDER","Provider"),char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.800)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "PROCEDURE","Procedure"),char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.238
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "PROCEDURESTATUS","Procedure Status"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headprovidername(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprovidernameabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headprovidernameabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
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
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.450
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10255)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      IF (trim(cv_list_rpl_provider_name)=null) uar_i18ngetmessage(_hi18nhandle,"NOPROVIDER",
        "No Provider Found")
      ENDIF
      ,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      IF (trim(cv_list_rpl_provider_name) != null) cv_list_rpl_provider_name
      ENDIF
      ,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headcatalogdispsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headcatalogdispsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headcatalogdispsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.070000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headcatalogstatusdispsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headcatalogstatusdispsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headcatalogstatusdispsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
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
    SET rptsd->m_x = (offsetx+ 2.800)
    SET rptsd->m_width = 2.938
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cv_list_rpl_catalog_disp,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.656
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(cv_list_rpl_status_disp),char(0))
     )
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF ( NOT (( $START_DATE <=  $END_DATE)
    AND ((( $U_VIEW=1)) OR (( $U_VIEW=3))) ))
    RETURN(0.0)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footcatalogstatusdispsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footcatalogstatusdispsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footcatalogstatusdispsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
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
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(cnvtstring(proc_cnt)),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footcatalogdispsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footcatalogdispsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footcatalogdispsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF ( NOT (((( $U_VIEW=1)) OR (( $U_VIEW=3)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footprovidername(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footprovidernameabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footprovidernameabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
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
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.438)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b8404992)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(cnvtstring(tprovider)),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.000),(offsety+ 0.063),(offsetx+ 7.000),(offsety+
     0.063))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "TOTAL","Total"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 2.045
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.070000), private
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
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 5.104
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "TOTALPROCEDURES","Total number of outstanding procedures:  "),trim(cnvtstring(gtotal_cnt))),
      char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.750),(offsety+ 0.193),(offsetx+ 6.500),(offsety+
     0.193))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 3.188)
    SET rptsd->m_width = 1.594
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "ENDREPORT","*** End of Report ***"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (graphsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = graphsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (graphsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(3.320000), private
   IF ( NOT (((( $U_VIEW=3)) OR (( $U_VIEW=2)))
    AND size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
    SET rptgraphrec->m_ntype = 2
    SET rptgraphrec->m_fleft = (0.250000+ offsetx)
    SET rptgraphrec->m_ftop = (0.250000+ offsety)
    SET rptgraphrec->m_fwidth = 6.250000
    SET rptgraphrec->m_fheight = 3.063000
    SET rptgraphrec->m_stitle = ""
    SET rptgraphrec->m_ssubtitle = ""
    SET rptgraphrec->m_sxtitle = ""
    SET rptgraphrec->m_sytitle = uar_i18ngetmessage(_hi18nhandle,"OUTSTANDINGDPROCSGRAPH",
     "Outstanding procedures")
    SET rptgraphrec->m_lstytitle.m_sfontname = rpt_times
    SET rptgraphrec->m_lstytitle.m_nfontsize = 10
    SET rptgraphrec->m_lstytitle.m_bold = rpt_off
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
    SET rptgraphrec->m_nlegendpos = 0
    SET rptgraphrec->m_lstlegend.m_sfontname = rpt_times
    SET rptgraphrec->m_lstlegend.m_nfontsize = 10
    SET rptgraphrec->m_lstlegend.m_bold = rpt_off
    SET rptgraphrec->m_lstlegend.m_italic = rpt_off
    SET rptgraphrec->m_lstlegend.m_underline = rpt_off
    SET rptgraphrec->m_lstlegend.m_strikethrough = rpt_off
    SET rptgraphrec->m_lstlegend.m_nbackmode = 0
    SET rptgraphrec->m_lstlegend.m_rgbbackcolor = rpt_white
    SET rptgraphrec->m_lstlegend.m_rgbfontcolor = rpt_black
    SET rptgraphrec->m_nlegendbkmode = 1
    SET rptgraphrec->m_rgblegendbkcolor = rpt_white
    SET rptgraphrec->m_nbkmode = 0
    SET rptgraphrec->m_rgbbkcolor = rpt_white
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
 SUBROUTINE (nodatasection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = nodatasectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (nodatasectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF ( NOT (size(reply_obj->cv_list,5) <= 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.406
    SET _oldfont = uar_rptsetfont(_hreport,_times16b255)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "NODATAFOUND","No data found! Try modifying Start/End dates!"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CV_FRPT_OUTSD_PROC"
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
   SET rptfont->m_pointsize = 20
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_rgbcolor = uar_rptencodecolor(153,51,0)
   SET _times20b13209 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_underline = rpt_on
   SET rptfont->m_rgbcolor = rpt_black
   SET _times12bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_rgbcolor = rpt_red
   SET _times10255 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_rgbcolor = uar_rptencodecolor(0,64,128)
   SET _times10b8404992 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = rpt_black
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET rptfont->m_rgbcolor = rpt_red
   SET _times16b255 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 2
   SET _pen14s2c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.010
   SET rptpen->m_penstyle = 0
   SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 CALL get_reply_obj(0)
 CALL finalizereport(_sendto)
END GO
