CREATE PROGRAM cv_frpt_proc_type_clinical
 PROMPT
  "output to file/printer/mine" = "MINE",
  "Starting Date" = "CURDATE",
  "Ending Date" = "CURDATE",
  "Section Display (i.e Procedure Info,Vital Signs)" = "",
  "Field Name (i.e TEE Indication, Scale type)" = "",
  "Organization" = 0.0
  WITH outdev, start_date, end_date,
  ce1_text, ce2_text, org_id
 EXECUTE reportrtl
 RECORD reply_obj(
   1 cv_list[*]
     2 rpl_full_name = vc
     2 rpl_catalog_disp = vc
     2 rpl_descriptor = vc
     2 rpl_proc_cnt = f8
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
 EXECUTE cv_frpt_proc_type_clinical_drv "NL:",  $START_DATE,  $END_DATE,
  $CE1_TEXT,  $CE2_TEXT,  $ORG_ID
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_reply_obj(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headfullnamesection(ncalc=i2) = f8 WITH protect
 DECLARE headfullnamesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headcatalogdispsection(ncalc=i2) = f8 WITH protect
 DECLARE headcatalogdispsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headdescriptorsection(ncalc=i2) = f8 WITH protect
 DECLARE headdescriptorsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footdescriptorsection(ncalc=i2) = f8 WITH protect
 DECLARE footdescriptorsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footcatalogdispsection(ncalc=i2) = f8 WITH protect
 DECLARE footcatalogdispsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footfullnamesection(ncalc=i2) = f8 WITH protect
 DECLARE footfullnamesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportsection(ncalc=i2) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE nodatasection(ncalc=i2) = f8 WITH protect
 DECLARE nodatasectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE getorgname(dummy) = null WITH protect
 DECLARE _hi18nhandle = i4 WITH noconstant(0), protect
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
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10255 = i4 WITH noconstant(0), protect
 DECLARE _times18b128 = i4 WITH noconstant(0), protect
 DECLARE _times1010485760 = i4 WITH noconstant(0), protect
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
   cv_list_rpl_full_name = substring(1,30,reply_obj->cv_list[d1.seq].rpl_full_name),
   cv_list_rpl_catalog_disp = substring(1,30,reply_obj->cv_list[d1.seq].rpl_catalog_disp),
   cv_list_rpl_descriptor = substring(1,30,reply_obj->cv_list[d1.seq].rpl_descriptor),
   cv_list_rpl_proc_cnt = reply_obj->cv_list[d1.seq].rpl_proc_cnt
   FROM (dummyt d1  WITH seq = value(size(reply_obj->cv_list,5)))
   PLAN (d1)
   ORDER BY cv_list_rpl_full_name, cv_list_rpl_catalog_disp, cv_list_rpl_descriptor
   HEAD REPORT
    _d0 = cv_list_rpl_full_name, _d1 = cv_list_rpl_catalog_disp, _d2 = cv_list_rpl_descriptor,
    _d3 = cv_list_rpl_proc_cnt, sdate = format(cnvtdatetime( $START_DATE),"@SHORTDATE;;Q"), edate =
    format(cnvtdatetime( $END_DATE),"@SHORTDATE;;Q"),
    gtotal_cnt = 0, total = 0, tgraph = 0,
    max_tgraph = 0, graph_max = 0, noffsetvar = 0,
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
    dummy_val = nodatasection(rpt_render)
   HEAD PAGE
    IF (curpage > 1)
     dummy_val = pagebreak(0)
    ENDIF
    dummy_val = headpagesection(rpt_render)
   HEAD cv_list_rpl_full_name
    _fdrawheight = headfullnamesection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headfullnamesection(rpt_render)
   HEAD cv_list_rpl_catalog_disp
    _fdrawheight = headcatalogdispsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headcatalogdispsection(rpt_render)
   HEAD cv_list_rpl_descriptor
    _fdrawheight = headdescriptorsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = headdescriptorsection(rpt_render)
   DETAIL
    _fdrawheight = detailsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = detailsection(rpt_render)
   FOOT  cv_list_rpl_descriptor
    total = count(cv_list_rpl_descriptor), _fdrawheight = footdescriptorsection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footdescriptorsection(rpt_render)
   FOOT  cv_list_rpl_catalog_disp
    gtotal_cnt = (gtotal_cnt+ cv_list_rpl_proc_cnt), _fdrawheight = footcatalogdispsection(
     rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footcatalogdispsection(rpt_render)
   FOOT  cv_list_rpl_full_name
    _fdrawheight = footfullnamesection(rpt_calcheight)
    IF (((_yoffset+ _fdrawheight) > _fenddetail))
     BREAK
    ENDIF
    dummy_val = footfullnamesection(rpt_render)
   FOOT PAGE
    _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
    _yoffset = _yhold
   FOOT REPORT
    max_tgraph = max(tgraph), graph_max = cv_graphindex(max_tgraph), _fdrawheight = footreportsection
    (rpt_calcheight)
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
   DECLARE sectionheight = f8 WITH noconstant(1.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times18b128)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "PROCEDURECLINICAL","Types of Procedures from Clinical Events")),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),(offsety+ 1.130),(offsetx+ 7.250),(offsety+
     1.130))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "GENERATEDON","Generated on:")," ",format(curdate,"@SHORTDATE")," ",format(curtime,"hh:mm;;s"
        ),
       " ",stimezone),char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "GENERATEDBY","Generated by:")," ",cv_username),char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 0.850)
    SET rptsd->m_width = 2.719
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "FROM","From")," ",sdate,uar_i18ngetmessage(_hi18nhandle,"TO"," To")," ",
       edate),char(0)))
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 4.195)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "ORGANIZATION","Organization: "),sorgname),char(0)))
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
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.400)
    SET rptsd->m_width = 1.300
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "PROCEDURES","Procedures"),char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.850)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DETAILS","Details"),char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.240)
    SET rptsd->m_width = 2.860
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "PROVIDER NAME","Provider Name"),char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "TOTAL","Total"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headfullnamesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headfullnamesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headfullnamesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
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
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10255)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      IF (trim(cv_list_rpl_full_name)=null) "No Person Entered"
      ENDIF
      ,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      IF (trim(cv_list_rpl_full_name) != null) cv_list_rpl_full_name
      ENDIF
      ,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headcatalogdispsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headcatalogdispsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headcatalogdispsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
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
    SET rptsd->m_x = (offsetx+ 3.400)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cv_list_rpl_catalog_disp,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headdescriptorsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headdescriptorsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headdescriptorsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
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
    SET rptsd->m_x = (offsetx+ 5.350)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.208
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cv_list_rpl_descriptor,char(0)))
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
  DECLARE sectionheight = f8 WITH noconstant(0.060000), private
  RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footdescriptorsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footdescriptorsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footdescriptorsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
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
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.198
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(trim(cnvtstring(total)),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footcatalogdispsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footcatalogdispsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footcatalogdispsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
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
    SET rptsd->m_x = (offsetx+ 0.438)
    SET rptsd->m_width = 5.813
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times1010485760)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "TOTALPROCEDUREPERFORMED","Total")," ",trim(cv_list_rpl_catalog_disp)," ",uar_i18ngetmessage(
        _hi18nhandle,"PERFORMEDBY","performed by "),
       " ",trim(cv_list_rpl_full_name)," ",trim(cnvtstring(cv_list_rpl_proc_cnt))),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footfullnamesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footfullnamesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footfullnamesectionabs(ncalc,offsetx,offsety)
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
    SET rptsd->m_x = (offsetx+ 3.000)
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
   DECLARE sectionheight = f8 WITH noconstant(1.120000), private
   IF ( NOT (size(reply_obj->cv_list,5) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "END OF REPORT","*** End of Report ***"),char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(uar_i18ngetmessage(_hi18nhandle,
        "TOTAL PROCEDURES PERFORMED","Total Number of Procedures Performed: "),cnvtstring(gtotal_cnt)
       ),char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),(offsety+ 0.131),(offsetx+ 7.250),(offsety+
     0.131))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
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
   DECLARE sectionheight = f8 WITH noconstant(1.170000), private
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
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times16b255)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "NO DATA FOUND","No data found! Try modifying starting/ending dates!"),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CV_FRPT_PROC_TYPE_CLINICAL"
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
   SET rptfont->m_rgbcolor = rpt_red
   SET _times10255 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = uar_rptencodecolor(0,0,160)
   SET _times1010485760 = uar_rptcreatefont(_hreport,rptfont)
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
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 CALL get_reply_obj(0)
 CALL finalizereport(_sendto)
END GO
