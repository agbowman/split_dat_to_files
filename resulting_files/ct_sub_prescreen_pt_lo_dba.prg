CREATE PROGRAM ct_sub_prescreen_pt_lo:dba
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
 DECLARE ct_get_prescreen_patients(dummy) = null WITH protect
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
 DECLARE headpersonidsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpersonidsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
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
 DECLARE _remprot_view_title = i4 WITH noconstant(1), protect
 DECLARE _remscreener_name = i4 WITH noconstant(1), protect
 DECLARE _remscreener_date = i4 WITH noconstant(1), protect
 DECLARE _remn_prot_name = i4 WITH noconstant(1), protect
 DECLARE _remn_init_service = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remprot_name = i4 WITH noconstant(1), protect
 DECLARE _reminit_service = i4 WITH noconstant(1), protect
 DECLARE _remn_total_potential_pts = i4 WITH noconstant(1), protect
 DECLARE _bcontheadprotsection = i2 WITH noconstant(0), protect
 DECLARE _remn_lastname = i4 WITH noconstant(1), protect
 DECLARE _remn_firstname = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpersonidsection = i2 WITH noconstant(0), protect
 DECLARE _remn_mrn = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remtotal_prot = i4 WITH noconstant(1), protect
 DECLARE _bcontfootprotsection = i2 WITH noconstant(0), protect
 DECLARE _rempage_num = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE init_service = vc WITH protect
 DECLARE prim_mnemonic = vc WITH protect
 DECLARE lname = vc WITH protect
 DECLARE fname = vc WITH protect
 DECLARE mrn_count = i4 WITH protect
 DECLARE tmp_apool = vc WITH protect
 DECLARE tmp_mrn = vc WITH protect
 DECLARE tmp_mrn_pool = vc WITH protect
 DECLARE bfound = i2 WITH protect
 DECLARE totallinestr = vc WITH protect
 DECLARE label = vc WITH protect
 DECLARE prot_count = i2 WITH protect
 DECLARE datestr = vc WITH protect
 DECLARE mrn_pool = vc WITH protect
 DECLARE person_mrn_size = i4 WITH protect
 SUBROUTINE ct_get_prescreen_patients(dummy)
   SELECT
    prot = substring(1,200,report_info->prot_list[d1.seq].primary_mnemonic), lastnm = substring(1,100,
     report_info->prot_list[d1.seq].person_list[d2.seq].last_name), lastnmsort = cnvtlower(substring(
      1,100,report_info->prot_list[d1.seq].person_list[d2.seq].last_name)),
    personid = report_info->prot_list[d1.seq].person_list[d2.seq].person_id
    FROM (dummyt d1  WITH seq = size(report_info->prot_list,5)),
     (dummyt d2  WITH seq = report_info->prot_list[d1.seq].qualified_num)
    PLAN (d1
     WHERE maxrec(d2,maxval(1,report_info->prot_list[d1.seq].qualified_num)))
     JOIN (d2)
    ORDER BY prot, lastnmsort, personid
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
      prot_count = (prot_count+ 1), prim_mnemonic = substring(1,20,report_info->prot_list[d1.seq].
       primary_mnemonic), init_service = substring(1,40,uar_get_code_display(report_info->prot_list[
        d1.seq].init_service_cd))
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
    HEAD lastnmsort
     row + 0
    HEAD personid
     bfound = 0
     IF (size(report_info->prot_list[d1.seq].person_list,5) > 0)
      person_mrn_size = size(report_info->prot_list[d1.seq].person_list[d2.seq].mrn_list,5), lname =
      report_info->prot_list[d1.seq].person_list[d2.seq].last_name, fname = report_info->prot_list[d1
      .seq].person_list[d2.seq].first_name,
      bfound = 1
     ENDIF
     mrn_count = 0, _bcontheadpersonidsection = 0, bfirsttime = 1
     WHILE (((_bcontheadpersonidsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadpersonidsection, _fdrawheight = headpersonidsection(rpt_calcheight,
        (_fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadpersonidsection=0)
        BREAK
       ENDIF
       dummy_val = headpersonidsection(rpt_render,(_fenddetail - _yoffset),_bcontheadpersonidsection),
       bfirsttime = 0
     ENDWHILE
    DETAIL
     IF (bfound=1)
      mrn_count = size(report_info->prot_list[d1.seq].person_list[d2.seq].mrn_list,5)
      FOR (z = 1 TO mrn_count)
        tmp_apool = substring(1,10,report_info->prot_list[d1.seq].person_list[d2.seq].mrn_list[z].
         alias_pool_disp), tmp_mrn = substring(1,20,report_info->prot_list[d1.seq].person_list[d2.seq
         ].mrn_list[z].mrn), tmp_mrn_pool = concat(tmp_apool," - ",tmp_mrn),
        mrn_pool = substring(1,40,tmp_mrn_pool)
      ENDFOR
     ENDIF
     _bcontdetailsection = 0, bfirsttime = 1
     WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontdetailsection=0)
        BREAK
       ENDIF
       dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection), bfirsttime
        = 0
     ENDWHILE
    FOOT  personid
     row + 0
    FOOT  lastnmsort
     row + 0
    FOOT  prot
     totallinestr = uar_i18nbuildmessage(i18nhandle,"PROT_TOTAL_PRESCREEN_RPT","%1 Total: %2","si",
      nullterm(report_info->prot_list[d1.seq].primary_mnemonic),
      report_info->prot_list[d1.seq].qualified_num), _bcontfootprotsection = 0, bfirsttime = 1
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
      "PROT_PAGE_PRESCREEN_RPT","Page: %1","i",curpage),
     _bcontfootpagesection = 0, dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontfootpagesection), _yoffset = _yhold
    FOOT REPORT
     _fdrawheight = footreportsection(rpt_calcheight)
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
   DECLARE drawheight_prot_view_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_screener_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_screener_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_prot_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_init_service = f8 WITH noconstant(0.0), private
   DECLARE __n_title = vc WITH noconstant(build2(report_labels->rpt_test_screen,char(0))), protect
   DECLARE __prot_view_title = vc WITH noconstant(build2(report_labels->rpt_prot_view,char(0))),
   protect
   DECLARE __screener_name = vc WITH noconstant(build2(report_info->screener_name,char(0))), protect
   DECLARE __screener_date = vc WITH noconstant(build2(datestr,char(0))), protect
   DECLARE __n_prot_name = vc WITH noconstant(build2(report_labels->rpt_protocol,char(0))), protect
   DECLARE __n_init_service = vc WITH noconstant(build2(report_labels->rpt_init_service,char(0))),
   protect
   IF (bcontinue=0)
    SET _remn_title = 1
    SET _remprot_view_title = 1
    SET _remscreener_name = 1
    SET _remscreener_date = 1
    SET _remn_prot_name = 1
    SET _remn_init_service = 1
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
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 3.188
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
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprot_view_title = _remprot_view_title
   IF (_remprot_view_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_view_title,((size
       (__prot_view_title) - _remprot_view_title)+ 1),__prot_view_title)))
    SET drawheight_prot_view_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_view_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_view_title,((size(
        __prot_view_title) - _remprot_view_title)+ 1),__prot_view_title)))))
     SET _remprot_view_title = (_remprot_view_title+ rptsd->m_drawlength)
    ELSE
     SET _remprot_view_title = 0
    ENDIF
    SET growsum = (growsum+ _remprot_view_title)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremscreener_name = _remscreener_name
   IF (_remscreener_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remscreener_name,((size(
        __screener_name) - _remscreener_name)+ 1),__screener_name)))
    SET drawheight_screener_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remscreener_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remscreener_name,((size(__screener_name)
        - _remscreener_name)+ 1),__screener_name)))))
     SET _remscreener_name = (_remscreener_name+ rptsd->m_drawlength)
    ELSE
     SET _remscreener_name = 0
    ENDIF
    SET growsum = (growsum+ _remscreener_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremscreener_date = _remscreener_date
   IF (_remscreener_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remscreener_date,((size(
        __screener_date) - _remscreener_date)+ 1),__screener_date)))
    SET drawheight_screener_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remscreener_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remscreener_date,((size(__screener_date)
        - _remscreener_date)+ 1),__screener_date)))))
     SET _remscreener_date = (_remscreener_date+ rptsd->m_drawlength)
    ELSE
     SET _remscreener_date = 0
    ENDIF
    SET growsum = (growsum+ _remscreener_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_prot_name = _remn_prot_name
   IF (_remn_prot_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_prot_name,((size(
        __n_prot_name) - _remn_prot_name)+ 1),__n_prot_name)))
    SET drawheight_n_prot_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_prot_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_prot_name,((size(__n_prot_name) -
       _remn_prot_name)+ 1),__n_prot_name)))))
     SET _remn_prot_name = (_remn_prot_name+ rptsd->m_drawlength)
    ELSE
     SET _remn_prot_name = 0
    ENDIF
    SET growsum = (growsum+ _remn_prot_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_init_service = _remn_init_service
   IF (_remn_init_service > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_init_service,((size(
        __n_init_service) - _remn_init_service)+ 1),__n_init_service)))
    SET drawheight_n_init_service = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_init_service = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_init_service,((size(__n_init_service
        ) - _remn_init_service)+ 1),__n_init_service)))))
     SET _remn_init_service = (_remn_init_service+ rptsd->m_drawlength)
    ELSE
     SET _remn_init_service = 0
    ENDIF
    SET growsum = (growsum+ _remn_init_service)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = drawheight_n_title
   IF (ncalc=rpt_render
    AND _holdremn_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_title,((size(
        __n_title) - _holdremn_title)+ 1),__n_title)))
   ELSE
    SET _remn_title = _holdremn_title
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 3.188
   SET rptsd->m_height = drawheight_prot_view_title
   IF (ncalc=rpt_render
    AND _holdremprot_view_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_view_title,((
       size(__prot_view_title) - _holdremprot_view_title)+ 1),__prot_view_title)))
   ELSE
    SET _remprot_view_title = _holdremprot_view_title
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = drawheight_screener_name
   IF (ncalc=rpt_render
    AND _holdremscreener_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremscreener_name,((
       size(__screener_name) - _holdremscreener_name)+ 1),__screener_name)))
   ELSE
    SET _remscreener_name = _holdremscreener_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_screener_date
   IF (ncalc=rpt_render
    AND _holdremscreener_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremscreener_date,((
       size(__screener_date) - _holdremscreener_date)+ 1),__screener_date)))
   ELSE
    SET _remscreener_date = _holdremscreener_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_n_prot_name
   IF (ncalc=rpt_render
    AND _holdremn_prot_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_prot_name,((size
       (__n_prot_name) - _holdremn_prot_name)+ 1),__n_prot_name)))
   ELSE
    SET _remn_prot_name = _holdremn_prot_name
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.563),(offsetx+ 10.000),(offsety
     + 0.563))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.594),(offsetx+ 10.000),(offsety
     + 0.594))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = drawheight_n_init_service
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremn_init_service > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_init_service,((
       size(__n_init_service) - _holdremn_init_service)+ 1),__n_init_service)))
   ELSE
    SET _remn_init_service = _holdremn_init_service
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
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.089),(offsetx+ 9.969),(offsety+
     0.089))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.115),(offsetx+ 9.979),(offsety+
     0.115))
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
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prot_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_init_service = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_total_potential_pts = f8 WITH noconstant(0.0), private
   DECLARE __prot_name = vc WITH noconstant(build2(prim_mnemonic,char(0))), protect
   DECLARE __init_service = vc WITH noconstant(build2(init_service,char(0))), protect
   DECLARE __n_total_potential_pts = vc WITH noconstant(build2(report_labels->rpt_pot_pts,char(0))),
   protect
   IF (bcontinue=0)
    SET _remprot_name = 1
    SET _reminit_service = 1
    SET _remn_total_potential_pts = 1
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
    SET rptsd->m_y = (offsety+ 0.146)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
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
    SET rptsd->m_y = (offsety+ 0.146)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.500
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_total_potential_pts = _remn_total_potential_pts
   IF (_remn_total_potential_pts > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_total_potential_pts,
       ((size(__n_total_potential_pts) - _remn_total_potential_pts)+ 1),__n_total_potential_pts)))
    SET drawheight_n_total_potential_pts = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_total_potential_pts = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_total_potential_pts,((size(
        __n_total_potential_pts) - _remn_total_potential_pts)+ 1),__n_total_potential_pts)))))
     SET _remn_total_potential_pts = (_remn_total_potential_pts+ rptsd->m_drawlength)
    ELSE
     SET _remn_total_potential_pts = 0
    ENDIF
    SET growsum = (growsum+ _remn_total_potential_pts)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.146)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.250
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
    SET rptsd->m_y = (offsety+ 0.146)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_init_service
   IF (ncalc=rpt_render
    AND _holdreminit_service > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminit_service,((
       size(__init_service) - _holdreminit_service)+ 1),__init_service)))
   ELSE
    SET _reminit_service = _holdreminit_service
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = drawheight_n_total_potential_pts
   IF (ncalc=rpt_render
    AND _holdremn_total_potential_pts > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremn_total_potential_pts,((size(__n_total_potential_pts) - _holdremn_total_potential_pts)
       + 1),__n_total_potential_pts)))
   ELSE
    SET _remn_total_potential_pts = _holdremn_total_potential_pts
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 9.938),(offsety+
     0.095))
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
 SUBROUTINE headpersonidsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpersonidsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpersonidsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_lastname = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_firstname = f8 WITH noconstant(0.0), private
   DECLARE __n_lastname = vc WITH noconstant(build2(lname,char(0))), protect
   DECLARE __n_firstname = vc WITH noconstant(build2(fname,char(0))), protect
   IF (bcontinue=0)
    SET _remn_lastname = 1
    SET _remn_firstname = 1
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
    SET rptsd->m_y = (offsety+ 0.042)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_lastname = _remn_lastname
   IF (_remn_lastname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_lastname,((size(
        __n_lastname) - _remn_lastname)+ 1),__n_lastname)))
    SET drawheight_n_lastname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_lastname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_lastname,((size(__n_lastname) -
       _remn_lastname)+ 1),__n_lastname)))))
     SET _remn_lastname = (_remn_lastname+ rptsd->m_drawlength)
    ELSE
     SET _remn_lastname = 0
    ENDIF
    SET growsum = (growsum+ _remn_lastname)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.042)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremn_firstname = _remn_firstname
   IF (_remn_firstname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_firstname,((size(
        __n_firstname) - _remn_firstname)+ 1),__n_firstname)))
    SET drawheight_n_firstname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_firstname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_firstname,((size(__n_firstname) -
       _remn_firstname)+ 1),__n_firstname)))))
     SET _remn_firstname = (_remn_firstname+ rptsd->m_drawlength)
    ELSE
     SET _remn_firstname = 0
    ENDIF
    SET growsum = (growsum+ _remn_firstname)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.042)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_n_lastname
   IF (ncalc=rpt_render
    AND _holdremn_lastname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_lastname,((size(
        __n_lastname) - _holdremn_lastname)+ 1),__n_lastname)))
   ELSE
    SET _remn_lastname = _holdremn_lastname
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.042)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_n_firstname
   IF (ncalc=rpt_render
    AND _holdremn_firstname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_firstname,((size
       (__n_firstname) - _holdremn_firstname)+ 1),__n_firstname)))
   ELSE
    SET _remn_firstname = _holdremn_firstname
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
 SUBROUTINE detailsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_mrn = f8 WITH noconstant(0.0), private
   DECLARE __n_mrn = vc WITH noconstant(build2(mrn_pool,char(0))), protect
   IF (bcontinue=0)
    SET _remn_mrn = 1
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
    SET rptsd->m_y = (offsety+ 0.031)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_mrn = _remn_mrn
   IF (_remn_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_mrn,((size(__n_mrn)
        - _remn_mrn)+ 1),__n_mrn)))
    SET drawheight_n_mrn = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_mrn = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_mrn,((size(__n_mrn) - _remn_mrn)+ 1),
       __n_mrn)))))
     SET _remn_mrn = (_remn_mrn+ rptsd->m_drawlength)
    ELSE
     SET _remn_mrn = 0
    ENDIF
    SET growsum = (growsum+ _remn_mrn)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.031)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = drawheight_n_mrn
   IF (ncalc=rpt_render
    AND _holdremn_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_mrn,((size(
        __n_mrn) - _holdremn_mrn)+ 1),__n_mrn)))
   ELSE
    SET _remn_mrn = _holdremn_mrn
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
 SUBROUTINE footprotsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footprotsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footprotsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_total_prot = f8 WITH noconstant(0.0), private
   DECLARE __total_prot = vc WITH noconstant(build2(totallinestr,char(0))), protect
   IF (bcontinue=0)
    SET _remtotal_prot = 1
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
    SET rptsd->m_y = (offsety+ 0.135)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 6.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtotal_prot = _remtotal_prot
   IF (_remtotal_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_prot,((size(
        __total_prot) - _remtotal_prot)+ 1),__total_prot)))
    SET drawheight_total_prot = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_prot = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_prot,((size(__total_prot) -
       _remtotal_prot)+ 1),__total_prot)))))
     SET _remtotal_prot = (_remtotal_prot+ rptsd->m_drawlength)
    ELSE
     SET _remtotal_prot = 0
    ENDIF
    SET growsum = (growsum+ _remtotal_prot)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.135)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 6.625
   SET rptsd->m_height = drawheight_total_prot
   IF (ncalc=rpt_render
    AND _holdremtotal_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_prot,((size(
        __total_prot) - _holdremtotal_prot)+ 1),__total_prot)))
   ELSE
    SET _remtotal_prot = _holdremtotal_prot
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 0.063),(offsetx+ 10.000),(offsety
     + 0.063))
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
   DECLARE drawheight_page_num = f8 WITH noconstant(0.0), private
   DECLARE __page_num = vc WITH noconstant(build2(label,char(0))), protect
   IF (bcontinue=0)
    SET _rempage_num = 1
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
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempage_num = _rempage_num
   IF (_rempage_num > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempage_num,((size(
        __page_num) - _rempage_num)+ 1),__page_num)))
    SET drawheight_page_num = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempage_num = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempage_num,((size(__page_num) -
       _rempage_num)+ 1),__page_num)))))
     SET _rempage_num = (_rempage_num+ rptsd->m_drawlength)
    ELSE
     SET _rempage_num = 0
    ENDIF
    SET growsum = (growsum+ _rempage_num)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = drawheight_page_num
   IF (ncalc=rpt_render
    AND _holdrempage_num > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempage_num,((size(
        __page_num) - _holdrempage_num)+ 1),__page_num)))
   ELSE
    SET _rempage_num = _holdrempage_num
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
   DECLARE sectionheight = f8 WITH noconstant(0.150000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.072),(offsetx+ 10.000),(offsety
     + 0.072))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.104),(offsetx+ 10.000),(offsety
     + 0.104))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "CT_SUB_PRESCREEN_PT_LO"
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
 CALL ct_get_prescreen_patients(0)
 CALL finalizereport(_sendto)
 SET last_mod = "001"
 SET mod_date = "Mar 10, 2017"
END GO
