CREATE PROGRAM ct_sub_prescreen_person_lo:dba
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
 DECLARE ct_get_prescreen_pat(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection1(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpersonidsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpersonidsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpersonidsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footpersonidsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footreportsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
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
 DECLARE _remn_reporttitle = i4 WITH noconstant(1), protect
 DECLARE _rempatient_view = i4 WITH noconstant(1), protect
 DECLARE _remscreener_name = i4 WITH noconstant(1), protect
 DECLARE _remscreener_date = i4 WITH noconstant(1), protect
 DECLARE _remlast_name = i4 WITH noconstant(1), protect
 DECLARE _remfirst_name = i4 WITH noconstant(1), protect
 DECLARE _remn_mrn = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlast_name = i4 WITH noconstant(1), protect
 DECLARE _remfirst_name = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpersonidsection = i2 WITH noconstant(0), protect
 DECLARE _remn_mrnpool = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remn_total = i4 WITH noconstant(1), protect
 DECLARE _remprotocol_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpersonidsection = i2 WITH noconstant(0), protect
 DECLARE _remn_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remn_total_pt_prescreen = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE match_count = i4 WITH protect
 DECLARE lname = vc WITH protect
 DECLARE fname = vc WITH protect
 DECLARE bfound = i2 WITH protect
 DECLARE mrn_count = i4 WITH protect
 DECLARE tmp_apool = vc WITH protect
 DECLARE tmp_mrn = vc WITH protect
 DECLARE tmp_mrn_pool = vc WITH protect
 DECLARE mrn_pool = vc WITH protect
 DECLARE label = vc WITH protect
 DECLARE prot_mnemonic = vc WITH protect
 DECLARE count = i4 WITH protect
 DECLARE prot_cnt = i4 WITH protect
 DECLARE str = vc WITH protect
 SUBROUTINE ct_get_prescreen_pat(dummy)
   SELECT
    lastnm = substring(1,100,report_info->pt_list[d1.seq].last_name), lastnmsort = cnvtlower(
     substring(1,100,report_info->pt_list[d1.seq].last_name)), personid = report_info->pt_list[d1.seq
    ].person_id
    FROM (dummyt d1  WITH seq = size(report_info->pt_list,5))
    PLAN (d1)
    ORDER BY personid, lastnmsort
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _bholdcontinue = 0,
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
    HEAD personid
     bfound = 0
     IF (size(report_info->pt_list[d1.seq].prot_list,5) > 0)
      lname = substring(1,20,report_info->pt_list[d1.seq].last_name), fname = substring(1,20,
       report_info->pt_list[d1.seq].first_name), bfound = 1,
      match_count = (match_count+ 1)
     ENDIF
     count = 0, mrn_count = 0, _bcontheadpersonidsection = 0,
     bfirsttime = 1
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
    HEAD lastnmsort
     row + 0
    DETAIL
     IF (bfound=1)
      mrn_count = size(report_info->pt_list[d1.seq].mrn_list,5)
      FOR (z = 1 TO mrn_count)
        tmp_apool = substring(1,10,report_info->pt_list[d1.seq].mrn_list[z].alias_pool_disp), tmp_mrn
         = substring(1,20,report_info->pt_list[d1.seq].mrn_list[z].mrn), tmp_mrn_pool = concat(
         tmp_apool," - ",tmp_mrn),
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
    FOOT  lastnmsort
     row + 0
    FOOT  personid
     FOR (i = 1 TO report_info->pt_list[d1.seq].prot_cnt)
      prot_mnemonic = report_info->pt_list[d1.seq].prot_list[i].primary_mnemonic,count = (count+ 1)
     ENDFOR
     _bcontfootpersonidsection = 0, bfirsttime = 1
     WHILE (((_bcontfootpersonidsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootpersonidsection, _fdrawheight = footpersonidsection(rpt_calcheight,
        (_fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfootpersonidsection=0)
        BREAK
       ENDIF
       dummy_val = footpersonidsection(rpt_render,(_fenddetail - _yoffset),_bcontfootpersonidsection),
       bfirsttime = 0
     ENDWHILE
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, label = uar_i18nbuildmessage(i18nhandle,
      "PAGE_PRESCREEN_RPT","Page: %1","i",curpage),
     _bcontfootpagesection = 0, dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontfootpagesection), _yoffset = _yhold
    FOOT REPORT
     str = uar_i18nbuildmessage(i18nhandle,"TOTAL_PT_PRESCREEN_RPT","TOTAL PATIENTS: %1","i",
      match_count), _bcontfootreportsection = 0, bfirsttime = 1
     WHILE (((_bcontfootreportsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootreportsection, _fdrawheight = footreportsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        CALL pagebreak(0)
       ELSEIF (_bholdcontinue=1
        AND _bcontfootreportsection=0)
        CALL pagebreak(0)
       ENDIF
       dummy_val = footreportsection(rpt_render,(_fenddetail - _yoffset),_bcontfootreportsection),
       bfirsttime = 0
     ENDWHILE
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
   DECLARE sectionheight = f8 WITH noconstant(1.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_reporttitle = f8 WITH noconstant(0.0), private
   DECLARE drawheight_patient_view = f8 WITH noconstant(0.0), private
   DECLARE drawheight_screener_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_screener_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_last_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_first_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_n_mrn = f8 WITH noconstant(0.0), private
   DECLARE __n_reporttitle = vc WITH noconstant(build2(report_labels->rpt_screen,char(0))), protect
   DECLARE __patient_view = vc WITH noconstant(build2(report_labels->rpt_pt_view,char(0))), protect
   DECLARE __screener_name = vc WITH noconstant(build2(report_info->screener_name,char(0))), protect
   DECLARE __screener_date = vc WITH noconstant(build2(datestr,char(0))), protect
   DECLARE __last_name = vc WITH noconstant(build2(report_labels->rpt_last_name,char(0))), protect
   DECLARE __first_name = vc WITH noconstant(build2(report_labels->rpt_first_name,char(0))), protect
   DECLARE __n_mrn = vc WITH noconstant(build2(report_labels->rpt_mrn,char(0))), protect
   IF (bcontinue=0)
    SET _remn_reporttitle = 1
    SET _rempatient_view = 1
    SET _remscreener_name = 1
    SET _remscreener_date = 1
    SET _remlast_name = 1
    SET _remfirst_name = 1
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_reporttitle = _remn_reporttitle
   IF (_remn_reporttitle > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_reporttitle,((size(
        __n_reporttitle) - _remn_reporttitle)+ 1),__n_reporttitle)))
    SET drawheight_n_reporttitle = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_reporttitle = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_reporttitle,((size(__n_reporttitle)
        - _remn_reporttitle)+ 1),__n_reporttitle)))))
     SET _remn_reporttitle = (_remn_reporttitle+ rptsd->m_drawlength)
    ELSE
     SET _remn_reporttitle = 0
    ENDIF
    SET growsum = (growsum+ _remn_reporttitle)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempatient_view = _rempatient_view
   IF (_rempatient_view > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatient_view,((size(
        __patient_view) - _rempatient_view)+ 1),__patient_view)))
    SET drawheight_patient_view = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatient_view = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatient_view,((size(__patient_view) -
       _rempatient_view)+ 1),__patient_view)))))
     SET _rempatient_view = (_rempatient_view+ rptsd->m_drawlength)
    ELSE
     SET _rempatient_view = 0
    ENDIF
    SET growsum = (growsum+ _rempatient_view)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 2.188
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
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 2.375
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
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlast_name = _remlast_name
   IF (_remlast_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlast_name,((size(
        __last_name) - _remlast_name)+ 1),__last_name)))
    SET drawheight_last_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlast_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlast_name,((size(__last_name) -
       _remlast_name)+ 1),__last_name)))))
     SET _remlast_name = (_remlast_name+ rptsd->m_drawlength)
    ELSE
     SET _remlast_name = 0
    ENDIF
    SET growsum = (growsum+ _remlast_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfirst_name = _remfirst_name
   IF (_remfirst_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfirst_name,((size(
        __first_name) - _remfirst_name)+ 1),__first_name)))
    SET drawheight_first_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfirst_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfirst_name,((size(__first_name) -
       _remfirst_name)+ 1),__first_name)))))
     SET _remfirst_name = (_remfirst_name+ rptsd->m_drawlength)
    ELSE
     SET _remfirst_name = 0
    ENDIF
    SET growsum = (growsum+ _remfirst_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_n_reporttitle
   IF (ncalc=rpt_render
    AND _holdremn_reporttitle > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_reporttitle,((
       size(__n_reporttitle) - _holdremn_reporttitle)+ 1),__n_reporttitle)))
   ELSE
    SET _remn_reporttitle = _holdremn_reporttitle
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_patient_view
   IF (ncalc=rpt_render
    AND _holdrempatient_view > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatient_view,((
       size(__patient_view) - _holdrempatient_view)+ 1),__patient_view)))
   ELSE
    SET _rempatient_view = _holdrempatient_view
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 2.188
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
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 2.375
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
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = drawheight_last_name
   IF (ncalc=rpt_render
    AND _holdremlast_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlast_name,((size(
        __last_name) - _holdremlast_name)+ 1),__last_name)))
   ELSE
    SET _remlast_name = _holdremlast_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_first_name
   IF (ncalc=rpt_render
    AND _holdremfirst_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfirst_name,((size(
        __first_name) - _holdremfirst_name)+ 1),__first_name)))
   ELSE
    SET _remfirst_name = _holdremfirst_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_n_mrn
   IF (ncalc=rpt_render
    AND _holdremn_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_mrn,((size(
        __n_mrn) - _holdremn_mrn)+ 1),__n_mrn)))
   ELSE
    SET _remn_mrn = _holdremn_mrn
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.656),(offsetx+ 10.052),(offsety
     + 0.656))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.625),(offsetx+ 10.042),(offsety
     + 0.625))
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
   DECLARE sectionheight = f8 WITH noconstant(0.150000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.115),(offsetx+ 10.000),(offsety
     + 0.115))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.083),(offsetx+ 10.000),(offsety
     + 0.083))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpersonidsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpersonidsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpersonidsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_last_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_first_name = f8 WITH noconstant(0.0), private
   DECLARE __last_name = vc WITH noconstant(build2(lname,char(0))), protect
   DECLARE __first_name = vc WITH noconstant(build2(fname,char(0))), protect
   IF (bcontinue=0)
    SET _remlast_name = 1
    SET _remfirst_name = 1
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
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlast_name = _remlast_name
   IF (_remlast_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlast_name,((size(
        __last_name) - _remlast_name)+ 1),__last_name)))
    SET drawheight_last_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlast_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlast_name,((size(__last_name) -
       _remlast_name)+ 1),__last_name)))))
     SET _remlast_name = (_remlast_name+ rptsd->m_drawlength)
    ELSE
     SET _remlast_name = 0
    ENDIF
    SET growsum = (growsum+ _remlast_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.813)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfirst_name = _remfirst_name
   IF (_remfirst_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfirst_name,((size(
        __first_name) - _remfirst_name)+ 1),__first_name)))
    SET drawheight_first_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfirst_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfirst_name,((size(__first_name) -
       _remfirst_name)+ 1),__first_name)))))
     SET _remfirst_name = (_remfirst_name+ rptsd->m_drawlength)
    ELSE
     SET _remfirst_name = 0
    ENDIF
    SET growsum = (growsum+ _remfirst_name)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_last_name
   IF (ncalc=rpt_render
    AND _holdremlast_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlast_name,((size(
        __last_name) - _holdremlast_name)+ 1),__last_name)))
   ELSE
    SET _remlast_name = _holdremlast_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.813)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_first_name
   IF (ncalc=rpt_render
    AND _holdremfirst_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfirst_name,((size(
        __first_name) - _holdremfirst_name)+ 1),__first_name)))
   ELSE
    SET _remfirst_name = _holdremfirst_name
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.073),(offsetx+ 10.000),(offsety
     + 0.073))
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
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_mrnpool = f8 WITH noconstant(0.0), private
   DECLARE __n_mrnpool = vc WITH noconstant(build2(mrn_pool,char(0))), protect
   IF (bcontinue=0)
    SET _remn_mrnpool = 1
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
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_mrnpool = _remn_mrnpool
   IF (_remn_mrnpool > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_mrnpool,((size(
        __n_mrnpool) - _remn_mrnpool)+ 1),__n_mrnpool)))
    SET drawheight_n_mrnpool = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_mrnpool = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_mrnpool,((size(__n_mrnpool) -
       _remn_mrnpool)+ 1),__n_mrnpool)))))
     SET _remn_mrnpool = (_remn_mrnpool+ rptsd->m_drawlength)
    ELSE
     SET _remn_mrnpool = 0
    ENDIF
    SET growsum = (growsum+ _remn_mrnpool)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.031)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_n_mrnpool
   IF (ncalc=rpt_render
    AND _holdremn_mrnpool > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_mrnpool,((size(
        __n_mrnpool) - _holdremn_mrnpool)+ 1),__n_mrnpool)))
   ELSE
    SET _remn_mrnpool = _holdremn_mrnpool
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
 SUBROUTINE footpersonidsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpersonidsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpersonidsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_total = f8 WITH noconstant(0.0), private
   DECLARE drawheight_protocol_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE __n_total = vc WITH noconstant(build2(report_labels->rpt_pot_prots,char(0))), protect
   DECLARE __protocol_mnemonic = vc WITH noconstant(build2(prot_mnemonic,char(0))), protect
   IF (bcontinue=0)
    SET _remn_total = 1
    SET _remprotocol_mnemonic = 1
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
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_total = _remn_total
   IF (_remn_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_total,((size(
        __n_total) - _remn_total)+ 1),__n_total)))
    SET drawheight_n_total = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_total = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_total,((size(__n_total) -
       _remn_total)+ 1),__n_total)))))
     SET _remn_total = (_remn_total+ rptsd->m_drawlength)
    ELSE
     SET _remn_total = 0
    ENDIF
    SET growsum = (growsum+ _remn_total)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.438)
   SET rptsd->m_width = 3.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprotocol_mnemonic = _remprotocol_mnemonic
   IF (_remprotocol_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprotocol_mnemonic,((
       size(__protocol_mnemonic) - _remprotocol_mnemonic)+ 1),__protocol_mnemonic)))
    SET drawheight_protocol_mnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprotocol_mnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprotocol_mnemonic,((size(
        __protocol_mnemonic) - _remprotocol_mnemonic)+ 1),__protocol_mnemonic)))))
     SET _remprotocol_mnemonic = (_remprotocol_mnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remprotocol_mnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remprotocol_mnemonic)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_n_total
   IF (ncalc=rpt_render
    AND _holdremn_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremn_total,((size(
        __n_total) - _holdremn_total)+ 1),__n_total)))
   ELSE
    SET _remn_total = _holdremn_total
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.438)
   SET rptsd->m_width = 3.438
   SET rptsd->m_height = drawheight_protocol_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprotocol_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprotocol_mnemonic,
       ((size(__protocol_mnemonic) - _holdremprotocol_mnemonic)+ 1),__protocol_mnemonic)))
   ELSE
    SET _remprotocol_mnemonic = _holdremprotocol_mnemonic
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
   SET rptsd->m_width = 6.250
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
   SET rptsd->m_width = 6.250
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
 SUBROUTINE footreportsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_n_total_pt_prescreen = f8 WITH noconstant(0.0), private
   DECLARE __n_total_pt_prescreen = vc WITH noconstant(build2(str,char(0))), protect
   IF (bcontinue=0)
    SET _remn_total_pt_prescreen = 1
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
    SET rptsd->m_y = (offsety+ 0.229)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.438)
   SET rptsd->m_width = 4.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremn_total_pt_prescreen = _remn_total_pt_prescreen
   IF (_remn_total_pt_prescreen > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remn_total_pt_prescreen,(
       (size(__n_total_pt_prescreen) - _remn_total_pt_prescreen)+ 1),__n_total_pt_prescreen)))
    SET drawheight_n_total_pt_prescreen = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remn_total_pt_prescreen = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remn_total_pt_prescreen,((size(
        __n_total_pt_prescreen) - _remn_total_pt_prescreen)+ 1),__n_total_pt_prescreen)))))
     SET _remn_total_pt_prescreen = (_remn_total_pt_prescreen+ rptsd->m_drawlength)
    ELSE
     SET _remn_total_pt_prescreen = 0
    ENDIF
    SET growsum = (growsum+ _remn_total_pt_prescreen)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.083),(offsetx+ 10.000),(offsety
     + 0.083))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.115),(offsetx+ 10.010),(offsety
     + 0.115))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.229)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.438)
   SET rptsd->m_width = 4.875
   SET rptsd->m_height = drawheight_n_total_pt_prescreen
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremn_total_pt_prescreen > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremn_total_pt_prescreen,((size(__n_total_pt_prescreen) - _holdremn_total_pt_prescreen)+ 1
       ),__n_total_pt_prescreen)))
   ELSE
    SET _remn_total_pt_prescreen = _holdremn_total_pt_prescreen
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
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "CT_SUB_PRESCREEN_PERSON_LO"
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
 CALL ct_get_prescreen_pat(0)
 CALL finalizereport(_sendto)
 SET last_mod = "001"
 SET mod_date = "Mar 10, 2017"
END GO
