CREATE PROGRAM ct_sub_prescreen_num_lo:dba
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
   1 rpt_prescreen_page = vc
   1 rpt_prescreen_prot_page = vc
   1 rpt_total_prescreen = vc
   1 rpt_total_pt_prescreen = vc
   1 rpt_total_prot_prescreen = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE ct_get_prescreen_prot(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection1(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headprotsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headprotsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footprotsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footprotsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footreportsection(ncalc=i2) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _remn_title = i4 WITH noconstant(1), protect
 DECLARE _remn_screenername = i4 WITH noconstant(1), protect
 DECLARE _remn_protocolname = i4 WITH noconstant(1), protect
 DECLARE _remn_initiatingserv = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remprot_name = i4 WITH noconstant(1), protect
 DECLARE _reminit_service = i4 WITH noconstant(1), protect
 DECLARE _bcontheadprotsection = i2 WITH noconstant(0), protect
 DECLARE _remtotal_prescreen_pt = i4 WITH noconstant(1), protect
 DECLARE _bcontfootprotsection = i2 WITH noconstant(0), protect
 DECLARE _remn_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE prim_mnemonic = vc WITH protect
 DECLARE init_service = vc WITH protect
 DECLARE totallinestr = vc WITH protect
 DECLARE str = vc WITH protect
 DECLARE label = vc WITH protect
 DECLARE prot_count = i2 WITH protect
 DECLARE datestr = vc WITH protect
 SUBROUTINE ct_get_prescreen_prot(dummy)
   SELECT
    prot = substring(1,200,report_info->prot_list[d1.seq].primary_mnemonic)
    FROM (dummyt d1  WITH seq = value(size(report_info->prot_list,5)))
    PLAN (d1)
    ORDER BY prot
    HEAD REPORT
     _d0 = prot, _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _bholdcontinue
      = 0,
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight,((rptreport->m_pagewidth - rptreport
      ->m_marginbottom) - _yoffset),_bholdcontinue))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     datestr = trim(format(cnvtdatetime(report_info->screened_dt_tm),"@LONGDATETIME;t(3);q"),7),
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection),
     dummy_val = headpagesection1(rpt_render)
    HEAD prot
     IF (size(report_info->prot_list,5) > 0)
      IF (prot_count > 0)
       prim_mnemonic = report_info->prot_list[d1.seq].primary_mnemonic, init_service = substring(1,40,
        uar_get_code_display(report_info->prot_list[d1.seq].init_service_cd))
      ENDIF
     ENDIF
     _bcontheadprotsection = 0, bfirsttime = 1
     WHILE (((_bcontheadprotsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadprotsection, _fdrawheight = headprotsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadprotsection=0)
        BREAK
       ENDIF
       dummy_val = headprotsection(rpt_render,(_fenddetail - _yoffset),_bcontheadprotsection),
       bfirsttime = 0
     ENDWHILE
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  prot
     str = cnvtstring(report_info->prot_list[d1.seq].qualified_num), totallinestr =
     uar_i18nbuildmessage(i18nhandle,"TOTAL_PRESCREEN_RPT","Total Potential Patients: %1","i",
      report_info->prot_list[d1.seq].qualified_num), _bcontfootprotsection = 0,
     bfirsttime = 1
     WHILE (((_bcontfootprotsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootprotsection, _fdrawheight = footprotsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfootprotsection=0)
        BREAK
       ENDIF
       dummy_val = footprotsection(rpt_render,(_fenddetail - _yoffset),_bcontfootprotsection),
       bfirsttime = 0
     ENDWHILE
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, label = uar_i18nbuildmessage(i18nhandle,
      "PAGE_PRESCREEN_RPT","Page: %1","i",curpage),
     _bcontfootpagesection = 0, dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontfootpagesection), _yoffset = _yhold
    FOOT REPORT
     _fdrawheight = footreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportsection(rpt_render)
    WITH nocounter, separator = "  ", format
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
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_screenername = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_protocolname = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_initiatingserv = f8 WITH noconstant(0.0), private
   DECLARE __n_title = vc WITH noconstant(build2(report_labels->rpt_test_screen,char(0))), protect
   DECLARE __n_protview = vc WITH noconstant(build2(report_labels->rpt_prot_view,char(0))), protect
   DECLARE __n_screenername = vc WITH noconstant(build2(report_info->screener_name,char(0))), protect
   DECLARE __n_protocolname = vc WITH noconstant(build2(report_labels->rpt_protocol,char(0))),
   protect
   DECLARE __n_initiatingserv = vc WITH noconstant(build2(report_labels->rpt_init_service,char(0))),
   protect
   IF (bcontinue=0)
    SET _remn_title = 1
    SET _remn_screenername = 1
    SET _remn_protocolname = 1
    SET _remn_initiatingserv = 1
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_title = _remn_title
   IF (_remn_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_title,((size(
        __n_title) - _remn_title)+ 1),__n_title)))
    SET drawheight_n_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_title,((size(__n_title) -
       _remn_title)+ 1),__n_title)))))
     SET _remn_title = (_remn_title+ rptsd->m_drawlength)
    ELSE
     SET _remn_title = 0
    ENDIF
    SET growsum = (growsum+ _remn_title)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_screenername = _remn_screenername
   IF (_remn_screenername > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_screenername,((size(
        __n_screenername) - _remn_screenername)+ 1),__n_screenername)))
    SET drawheight_n_screenername = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_screenername = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_screenername,((size(__n_screenername
        ) - _remn_screenername)+ 1),__n_screenername)))))
     SET _remn_screenername = (_remn_screenername+ rptsd->m_drawlength)
    ELSE
     SET _remn_screenername = 0
    ENDIF
    SET growsum = (growsum+ _remn_screenername)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.625)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_protocolname = _remn_protocolname
   IF (_remn_protocolname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_protocolname,((size(
        __n_protocolname) - _remn_protocolname)+ 1),__n_protocolname)))
    SET drawheight_n_protocolname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_protocolname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_protocolname,((size(__n_protocolname
        ) - _remn_protocolname)+ 1),__n_protocolname)))))
     SET _remn_protocolname = (_remn_protocolname+ rptsd->m_drawlength)
    ELSE
     SET _remn_protocolname = 0
    ENDIF
    SET growsum = (growsum+ _remn_protocolname)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.625)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_initiatingserv = _remn_initiatingserv
   IF (_remn_initiatingserv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_initiatingserv,((
       size(__n_initiatingserv) - _remn_initiatingserv)+ 1),__n_initiatingserv)))
    SET drawheight_n_initiatingserv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_initiatingserv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_initiatingserv,((size(
        __n_initiatingserv) - _remn_initiatingserv)+ 1),__n_initiatingserv)))))
     SET _remn_initiatingserv = (_remn_initiatingserv+ rptsd->m_drawlength)
    ELSE
     SET _remn_initiatingserv = 0
    ENDIF
    SET growsum = (growsum+ _remn_initiatingserv)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_n_title
   IF (ncalc=rpt_render
    AND _holdremn_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_title,((size(
        __n_title) - _holdremn_title)+ 1),__n_title)))
   ELSE
    SET _remn_title = _holdremn_title
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.313)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__n_protview)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_n_screenername
   IF (ncalc=rpt_render
    AND _holdremn_screenername > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_screenername,((
       size(__n_screenername) - _holdremn_screenername)+ 1),__n_screenername)))
   ELSE
    SET _remn_screenername = _holdremn_screenername
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.313)
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = 0.188
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(datestr,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.625)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = drawheight_n_protocolname
   IF (ncalc=rpt_render
    AND _holdremn_protocolname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_protocolname,((
       size(__n_protocolname) - _holdremn_protocolname)+ 1),__n_protocolname)))
   ELSE
    SET _remn_protocolname = _holdremn_protocolname
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.625)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = drawheight_n_initiatingserv
   IF (ncalc=rpt_render
    AND _holdremn_initiatingserv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_initiatingserv,(
       (size(__n_initiatingserv) - _holdremn_initiatingserv)+ 1),__n_initiatingserv)))
   ELSE
    SET _remn_initiatingserv = _holdremn_initiatingserv
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.563),(offsetx+ 10.000),(offsety
     + 0.563))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.531),(offsetx+ 10.000),(offsety
     + 0.531))
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
 SUBROUTINE headpagesection1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.156),(offsetx+ 10.000),(offsety
     + 0.156))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.125),(offsetx+ 10.000),(offsety
     + 0.125))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headprotsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprotsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headprotsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prot_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_init_service = f8 WITH noconstant(0.0), private
   DECLARE __prot_name = vc WITH noconstant(build2(prim_mnemonic,char(0))), protect
   DECLARE __init_service = vc WITH noconstant(build2(init_service,char(0))), protect
   IF (bcontinue=0)
    SET _remprot_name = 1
    SET _reminit_service = 1
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprot_name = _remprot_name
   IF (_remprot_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_name,((size(
        __prot_name) - _remprot_name)+ 1),__prot_name)))
    SET drawheight_prot_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_name,((size(__prot_name) -
       _remprot_name)+ 1),__prot_name)))))
     SET _remprot_name = (_remprot_name+ rptsd->m_drawlength)
    ELSE
     SET _remprot_name = 0
    ENDIF
    SET growsum = (growsum+ _remprot_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdreminit_service = _reminit_service
   IF (_reminit_service > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminit_service,((size(
        __init_service) - _reminit_service)+ 1),__init_service)))
    SET drawheight_init_service = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminit_service = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminit_service,((size(__init_service) -
       _reminit_service)+ 1),__init_service)))))
     SET _reminit_service = (_reminit_service+ rptsd->m_drawlength)
    ELSE
     SET _reminit_service = 0
    ENDIF
    SET growsum = (growsum+ _reminit_service)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_prot_name
   IF (ncalc=rpt_render
    AND _holdremprot_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_name,((size(
        __prot_name) - _holdremprot_name)+ 1),__prot_name)))
   ELSE
    SET _remprot_name = _holdremprot_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_init_service
   IF (ncalc=rpt_render
    AND _holdreminit_service > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminit_service,((
       size(__init_service) - _holdreminit_service)+ 1),__init_service)))
   ELSE
    SET _reminit_service = _holdreminit_service
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
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footprotsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footprotsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footprotsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_total_prescreen_pt = f8 WITH noconstant(0.0), private
   DECLARE __total_prescreen_pt = vc WITH noconstant(build2(totallinestr,char(0))), protect
   IF (bcontinue=0)
    SET _remtotal_prescreen_pt = 1
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.375)
   SET rptsd->m_width = 8.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtotal_prescreen_pt = _remtotal_prescreen_pt
   IF (_remtotal_prescreen_pt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_prescreen_pt,((
       size(__total_prescreen_pt) - _remtotal_prescreen_pt)+ 1),__total_prescreen_pt)))
    SET drawheight_total_prescreen_pt = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_prescreen_pt = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_prescreen_pt,((size(
        __total_prescreen_pt) - _remtotal_prescreen_pt)+ 1),__total_prescreen_pt)))))
     SET _remtotal_prescreen_pt = (_remtotal_prescreen_pt+ rptsd->m_drawlength)
    ELSE
     SET _remtotal_prescreen_pt = 0
    ENDIF
    SET growsum = (growsum+ _remtotal_prescreen_pt)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.375)
   SET rptsd->m_width = 8.375
   SET rptsd->m_height = drawheight_total_prescreen_pt
   IF (ncalc=rpt_render
    AND _holdremtotal_prescreen_pt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_prescreen_pt,
       ((size(__total_prescreen_pt) - _holdremtotal_prescreen_pt)+ 1),__total_prescreen_pt)))
   ELSE
    SET _remtotal_prescreen_pt = _holdremtotal_prescreen_pt
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
 SUBROUTINE footpagesection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_page = f8 WITH noconstant(0.0), private
   DECLARE __n_page = vc WITH noconstant(build2(label,char(0))), protect
   IF (bcontinue=0)
    SET _remn_page = 1
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
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_page = _remn_page
   IF (_remn_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_page,((size(__n_page
        ) - _remn_page)+ 1),__n_page)))
    SET drawheight_n_page = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_page = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_page,((size(__n_page) - _remn_page)
       + 1),__n_page)))))
     SET _remn_page = (_remn_page+ rptsd->m_drawlength)
    ELSE
     SET _remn_page = 0
    ENDIF
    SET growsum = (growsum+ _remn_page)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = drawheight_n_page
   IF (ncalc=rpt_render
    AND _holdremn_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_page,((size(
        __n_page) - _holdremn_page)+ 1),__n_page)))
   ELSE
    SET _remn_page = _holdremn_page
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
 SUBROUTINE footreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 0.083),(offsetx+ 10.000),(offsety
     + 0.083))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.115),(offsetx+ 10.000),(offsety
     + 0.115))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "CT_SUB_PRESCREEN_NUM_LO"
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
   SET rptfont->m_pointsize = 8
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
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
 CALL initializereport(0)
 CALL ct_get_prescreen_prot(0)
 CALL finalizereport(_sendto)
 SET last_mod = "001"
 SET mod_date = "Mar 10, 2017"
END GO
