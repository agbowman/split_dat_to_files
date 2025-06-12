CREATE PROGRAM ct_rpt_prot_init_srv_status_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Initiating Service/Department" = value(0.000000),
  "Protocol Status" = value(0.000000),
  "Order By" = 1,
  "Level of detail" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, initiatingservices, status,
  orderby, detaillevel, out_type,
  delimiter
 EXECUTE reportrtl
 RECORD reportlist(
   1 all_init_services = i2
   1 init_service_cnt = i2
   1 init_services[*]
     2 init_service_cd = f8
   1 all_statuses = i2
   1 status_cnt = i2
   1 statuses[*]
     2 status_cd = f8
   1 order_by = vc
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 parent_prot_master_id = f8
     2 collab_site_ind = i2
     2 prot_mnemonic = vc
     2 init_service_cd = f8
     2 init_service_disp = c40
     2 init_service_desc = c60
     2 init_service_mean = c12
     2 init_activation_date = dq8
     2 amd_description = c40
     2 amd_nbr = i4
     2 active_amd_id = f8
     2 revision_nbr_txt = c60
     2 revision_ind = i2
     2 amd_activation_date = dq8
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 prot_status_desc = c60
     2 prot_status_mean = c12
     2 cur_accrual = i4
     2 primary_sponsor = c100
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_sorted_title = vc
   1 rpt_serv_stat_title = vc
   1 rep_exec_time = vc
   1 prot_mnemonic_header = vc
   1 init_act_header = vc
   1 init_serv_header = vc
   1 status_header = vc
   1 cur_amd_header = vc
   1 amd_act_date_header = vc
   1 cur_acc_header = vc
   1 sponsor_header = vc
   1 total_prot = vc
   1 total_init_serv = vc
   1 total_statuses = vc
   1 end_of_rpt = vc
   1 criteria_not_met = vc
   1 amendment = vc
   1 init_prot = vc
   1 revision = vc
   1 rpt_page = vc
 )
 RECORD statuslist(
   1 statuses[*]
     2 prot_status_cd = f8
 )
 RECORD init_servicelist(
   1 init_services[*]
     2 init_service_cd = f8
 )
 EXECUTE ct_rpt_prot_init_srv_status:dba "NL:",  $INITIATINGSERVICES,  $STATUS,
  $ORDERBY,  $DETAILLEVEL,  $OUT_TYPE,
  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_protocol_init_srv_status(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection_amd(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection_amdabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE headpagesection_no_amd(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection_no_amdabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
 f8 WITH protect
 DECLARE headpagesection_line(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection_amd(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection_amdabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE detailsection_no_amd(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection_no_amdabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footreportsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
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
 DECLARE _remlabel_rpt_title = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_sorted_title = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_serv_stat_title = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_prot_mnemonic_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_init_act_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_init_serv_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_status_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_cur_amd_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_amd_act_date_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_cur_acc_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_sponsor_header = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_amd = i2 WITH noconstant(0), protect
 DECLARE _remlabel_prot_mnemonic_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_init_act_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_init_serv_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_status_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_cur_acc_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_sponsor_header = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection_no_amd = i2 WITH noconstant(0), protect
 DECLARE _remtmp_prot = i4 WITH noconstant(1), protect
 DECLARE _remtmp_init_act_date = i4 WITH noconstant(1), protect
 DECLARE _remtmp_init_srv = i4 WITH noconstant(1), protect
 DECLARE _remtmp_status = i4 WITH noconstant(1), protect
 DECLARE _remtmp_cur_acc = i4 WITH noconstant(1), protect
 DECLARE _remtmp_amd_desc = i4 WITH noconstant(1), protect
 DECLARE _remtmp_act_date = i4 WITH noconstant(1), protect
 DECLARE _remtmp_sponsor = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection_amd = i2 WITH noconstant(0), protect
 DECLARE _remtmp_prot = i4 WITH noconstant(1), protect
 DECLARE _remtmp_init_act_date = i4 WITH noconstant(1), protect
 DECLARE _remtmp_init_srv = i4 WITH noconstant(1), protect
 DECLARE _remtmp_status = i4 WITH noconstant(1), protect
 DECLARE _remtmp_cur_acc = i4 WITH noconstant(1), protect
 DECLARE _remtmp_sponsor = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection_no_amd = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rep_exec_time = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_total_prot = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total_init_serv = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total_statuses = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _courier12b0 = i4 WITH noconstant(0), protect
 DECLARE _courier9b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE tmp_sponsor = vc WITH protect
 DECLARE tmp_amd_desc = vc WITH protect
 DECLARE tmp_init_srv = vc WITH protect
 DECLARE tmp_act_date = vc WITH protect
 DECLARE tmp_init_act_date = vc WITH protect
 DECLARE tmp_cur_acc = vc WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE init_service_cnt = i4 WITH protect
 DECLARE status_cnt = i4 WITH protect
 DECLARE status_pos = i4 WITH protect
 DECLARE num = i4 WITH protect
 SUBROUTINE get_protocol_init_srv_status(dummy)
   SELECT
    protocols_prot_mnemonic = substring(1,30,results->protocols[d.seq].prot_mnemonic),
    protocols_prot_master_id = results->protocols[d.seq].prot_master_id, protocols_init_service_cd =
    results->protocols[d.seq].init_service_cd,
    protocols_prot_status_cd = results->protocols[d.seq].prot_status_cd, reportlist_order_by = parser
    (reportlist->order_by)
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY reportlist_order_by
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _bholdcontinue = 0,
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight,((rptreport->m_pagewidth - rptreport
      ->m_marginbottom) - _yoffset),_bholdcontinue)),
     init_service_cnt = 0, status_cnt = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), _bcontheadpagesection_amd = 0,
     dummy_val = headpagesection_amd(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom)
       - _yoffset),_bcontheadpagesection_amd), _bcontheadpagesection_no_amd = 0, dummy_val =
     headpagesection_no_amd(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
      _yoffset),_bcontheadpagesection_no_amd),
     dummy_val = headpagesection_line(rpt_render)
    HEAD reportlist_order_by
     row + 0
    DETAIL
     tmp_prot = results->protocols[d.seq].prot_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = "--"
     ENDIF
     tmp_init_srv = results->protocols[d.seq].init_service_disp, tmp_status = results->protocols[d
     .seq].prot_status_disp, tmp_cur_acc = trim(cnvtstring(results->protocols[d.seq].cur_accrual),3)
     IF ( NOT ((results->protocols[d.seq].primary_sponsor IN ("", " ", null))))
      tmp_sponsor = substring(1,30,results->protocols[d.seq].primary_sponsor)
     ELSE
      tmp_sponsor = "--"
     ENDIF
     IF (( $DETAILLEVEL=1))
      IF ((results->protocols[d.seq].amd_nbr > 0))
       tmp_amd_desc = concat(label->amendment," ",trim(cnvtstring(results->protocols[d.seq].amd_nbr))
        )
      ELSE
       tmp_amd_desc = label->init_prot
      ENDIF
      IF ((results->protocols[d.seq].amd_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
       AND (results->protocols[d.seq].amd_activation_date > 0))
       tmp_act_date = format(results->protocols[d.seq].amd_activation_date,"@SHORTDATE")
      ELSE
       tmp_act_date = "--"
      ENDIF
      IF ((results->protocols[d.seq].revision_ind=1))
       tmp_amd_desc = concat(tmp_amd_desc," - ",label->revision," ",results->protocols[d.seq].
        revision_nbr_txt)
      ENDIF
      _bcontdetailsection_amd = 0, bfirsttime = 1
      WHILE (((_bcontdetailsection_amd=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontdetailsection_amd, _fdrawheight = detailsection_amd(rpt_calcheight,(
         _fenddetail - _yoffset),_bholdcontinue)
        IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ detailsection_no_amd(rpt_calcheight,((
           _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
          IF (_bholdcontinue=1)
           _fdrawheight = (_fenddetail+ 1)
          ENDIF
         ENDIF
        ENDIF
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         BREAK
        ELSEIF (_bholdcontinue=1
         AND _bcontdetailsection_amd=0)
         BREAK
        ENDIF
        dummy_val = detailsection_amd(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection_amd),
        bfirsttime = 0
      ENDWHILE
     ELSE
      _bcontdetailsection_no_amd = 0, bfirsttime = 1
      WHILE (((_bcontdetailsection_no_amd=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontdetailsection_no_amd, _fdrawheight = detailsection_no_amd(
         rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         BREAK
        ELSEIF (_bholdcontinue=1
         AND _bcontdetailsection_no_amd=0)
         BREAK
        ENDIF
        dummy_val = detailsection_no_amd(rpt_render,(_fenddetail - _yoffset),
         _bcontdetailsection_no_amd), bfirsttime = 0
      ENDWHILE
     ENDIF
     status_pos = locateval(num,1,size(statuslist->statuses,5),results->protocols[d.seq].
      prot_status_cd,statuslist->statuses[num].prot_status_cd)
     IF (status_pos=0)
      status_cnt = (status_cnt+ 1)
      IF (mod(status_cnt,10)=1)
       stat = alterlist(statuslist->statuses,(status_cnt+ 9))
      ENDIF
      statuslist->statuses[status_cnt].prot_status_cd = results->protocols[d.seq].prot_status_cd
     ENDIF
     status_pos = locateval(num,1,size(init_servicelist->init_services,5),results->protocols[d.seq].
      init_service_cd,init_servicelist->init_services[num].init_service_cd)
     IF (status_pos=0)
      init_service_cnt = (init_service_cnt+ 1)
      IF (mod(init_service_cnt,10)=1)
       stat = alterlist(init_servicelist->init_services,(init_service_cnt+ 9))
      ENDIF
      init_servicelist->init_services[init_service_cnt].init_service_cd = results->protocols[d.seq].
      init_service_cd
     ENDIF
    FOOT  reportlist_order_by
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
     dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
      _yoffset),_bcontfootpagesection), _yoffset = _yhold
    FOOT REPORT
     _bcontfootreportsection = 0, bfirsttime = 1
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
 SUBROUTINE headpagesection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.740000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_sorted_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_serv_stat_title = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_title = vc WITH noconstant(build2(label->rpt_title,char(0))), protect
   DECLARE __label_rpt_sorted_title = vc WITH noconstant(build2(label->rpt_sorted_title,char(0))),
   protect
   DECLARE __label_rpt_serv_stat_title = vc WITH noconstant(build2(label->rpt_serv_stat_title,char(0)
     )), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_title = 1
    SET _remlabel_rpt_sorted_title = 1
    SET _remlabel_rpt_serv_stat_title = 1
   ENDIF
   SET rptsd->m_flags = 21
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
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_title = _remlabel_rpt_title
   IF (_remlabel_rpt_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_title,((size
       (__label_rpt_title) - _remlabel_rpt_title)+ 1),__label_rpt_title)))
    SET drawheight_label_rpt_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_title,((size(
        __label_rpt_title) - _remlabel_rpt_title)+ 1),__label_rpt_title)))))
     SET _remlabel_rpt_title = (_remlabel_rpt_title+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_title = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_title)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   SET _holdremlabel_rpt_sorted_title = _remlabel_rpt_sorted_title
   IF (_remlabel_rpt_sorted_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_sorted_title,
       ((size(__label_rpt_sorted_title) - _remlabel_rpt_sorted_title)+ 1),__label_rpt_sorted_title)))
    SET drawheight_label_rpt_sorted_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_sorted_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_sorted_title,((size(
        __label_rpt_sorted_title) - _remlabel_rpt_sorted_title)+ 1),__label_rpt_sorted_title)))))
     SET _remlabel_rpt_sorted_title = (_remlabel_rpt_sorted_title+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_sorted_title = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_sorted_title)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_serv_stat_title = _remlabel_rpt_serv_stat_title
   IF (_remlabel_rpt_serv_stat_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_rpt_serv_stat_title,((size(__label_rpt_serv_stat_title) -
       _remlabel_rpt_serv_stat_title)+ 1),__label_rpt_serv_stat_title)))
    SET drawheight_label_rpt_serv_stat_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_serv_stat_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_serv_stat_title,((size(
        __label_rpt_serv_stat_title) - _remlabel_rpt_serv_stat_title)+ 1),__label_rpt_serv_stat_title
       )))))
     SET _remlabel_rpt_serv_stat_title = (_remlabel_rpt_serv_stat_title+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_serv_stat_title = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_serv_stat_title)
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_rpt_title
   SET _dummyfont = uar_rptsetfont(_hreport,_courier12b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_title,((
       size(__label_rpt_title) - _holdremlabel_rpt_title)+ 1),__label_rpt_title)))
   ELSE
    SET _remlabel_rpt_title = _holdremlabel_rpt_title
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_rpt_sorted_title
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_sorted_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rpt_sorted_title,((size(__label_rpt_sorted_title) -
       _holdremlabel_rpt_sorted_title)+ 1),__label_rpt_sorted_title)))
   ELSE
    SET _remlabel_rpt_sorted_title = _holdremlabel_rpt_sorted_title
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_rpt_serv_stat_title
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_serv_stat_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rpt_serv_stat_title,((size(__label_rpt_serv_stat_title) -
       _holdremlabel_rpt_serv_stat_title)+ 1),__label_rpt_serv_stat_title)))
   ELSE
    SET _remlabel_rpt_serv_stat_title = _holdremlabel_rpt_serv_stat_title
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
 SUBROUTINE headpagesection_amd(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_amdabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection_amdabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_prot_mnemonic_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_init_act_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_init_serv_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_status_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_cur_amd_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_amd_act_date_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_cur_acc_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_sponsor_header = f8 WITH noconstant(0.0), private
   DECLARE __label_prot_mnemonic_header = vc WITH noconstant(build2(label->prot_mnemonic_header,char(
      0))), protect
   DECLARE __label_init_act_header = vc WITH noconstant(build2(label->init_act_header,char(0))),
   protect
   DECLARE __label_init_serv_header = vc WITH noconstant(build2(label->init_serv_header,char(0))),
   protect
   DECLARE __label_status_header = vc WITH noconstant(build2(label->status_header,char(0))), protect
   DECLARE __label_cur_amd_header = vc WITH noconstant(build2(label->cur_amd_header,char(0))),
   protect
   DECLARE __label_amd_act_date_header = vc WITH noconstant(build2(label->amd_act_date_header,char(0)
     )), protect
   DECLARE __label_cur_acc_header = vc WITH noconstant(build2(label->cur_acc_header,char(0))),
   protect
   DECLARE __label_sponsor_header = vc WITH noconstant(build2(label->sponsor_header,char(0))),
   protect
   IF ( NOT (( $DETAILLEVEL=1)))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_prot_mnemonic_header = 1
    SET _remlabel_init_act_header = 1
    SET _remlabel_init_serv_header = 1
    SET _remlabel_status_header = 1
    SET _remlabel_cur_amd_header = 1
    SET _remlabel_amd_act_date_header = 1
    SET _remlabel_cur_acc_header = 1
    SET _remlabel_sponsor_header = 1
   ENDIF
   SET rptsd->m_flags = 1029
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
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_prot_mnemonic_header = _remlabel_prot_mnemonic_header
   IF (_remlabel_prot_mnemonic_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_prot_mnemonic_header,((size(__label_prot_mnemonic_header) -
       _remlabel_prot_mnemonic_header)+ 1),__label_prot_mnemonic_header)))
    SET drawheight_label_prot_mnemonic_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_prot_mnemonic_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_prot_mnemonic_header,((size(
        __label_prot_mnemonic_header) - _remlabel_prot_mnemonic_header)+ 1),
       __label_prot_mnemonic_header)))))
     SET _remlabel_prot_mnemonic_header = (_remlabel_prot_mnemonic_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_prot_mnemonic_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_prot_mnemonic_header)
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_init_act_header = _remlabel_init_act_header
   IF (_remlabel_init_act_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_init_act_header,
       ((size(__label_init_act_header) - _remlabel_init_act_header)+ 1),__label_init_act_header)))
    SET drawheight_label_init_act_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_init_act_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_init_act_header,((size(
        __label_init_act_header) - _remlabel_init_act_header)+ 1),__label_init_act_header)))))
     SET _remlabel_init_act_header = (_remlabel_init_act_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_init_act_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_init_act_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_init_serv_header = _remlabel_init_serv_header
   IF (_remlabel_init_serv_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_init_serv_header,
       ((size(__label_init_serv_header) - _remlabel_init_serv_header)+ 1),__label_init_serv_header)))
    SET drawheight_label_init_serv_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_init_serv_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_init_serv_header,((size(
        __label_init_serv_header) - _remlabel_init_serv_header)+ 1),__label_init_serv_header)))))
     SET _remlabel_init_serv_header = (_remlabel_init_serv_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_init_serv_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_init_serv_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_status_header = _remlabel_status_header
   IF (_remlabel_status_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_status_header,((
       size(__label_status_header) - _remlabel_status_header)+ 1),__label_status_header)))
    SET drawheight_label_status_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_status_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_status_header,((size(
        __label_status_header) - _remlabel_status_header)+ 1),__label_status_header)))))
     SET _remlabel_status_header = (_remlabel_status_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_status_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_status_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_cur_amd_header = _remlabel_cur_amd_header
   IF (_remlabel_cur_amd_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_cur_amd_header,(
       (size(__label_cur_amd_header) - _remlabel_cur_amd_header)+ 1),__label_cur_amd_header)))
    SET drawheight_label_cur_amd_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_cur_amd_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_cur_amd_header,((size(
        __label_cur_amd_header) - _remlabel_cur_amd_header)+ 1),__label_cur_amd_header)))))
     SET _remlabel_cur_amd_header = (_remlabel_cur_amd_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_cur_amd_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_cur_amd_header)
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.625)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_amd_act_date_header = _remlabel_amd_act_date_header
   IF (_remlabel_amd_act_date_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_amd_act_date_header,((size(__label_amd_act_date_header) -
       _remlabel_amd_act_date_header)+ 1),__label_amd_act_date_header)))
    SET drawheight_label_amd_act_date_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_amd_act_date_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_amd_act_date_header,((size(
        __label_amd_act_date_header) - _remlabel_amd_act_date_header)+ 1),__label_amd_act_date_header
       )))))
     SET _remlabel_amd_act_date_header = (_remlabel_amd_act_date_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_amd_act_date_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_amd_act_date_header)
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_cur_acc_header = _remlabel_cur_acc_header
   IF (_remlabel_cur_acc_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_cur_acc_header,(
       (size(__label_cur_acc_header) - _remlabel_cur_acc_header)+ 1),__label_cur_acc_header)))
    SET drawheight_label_cur_acc_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_cur_acc_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_cur_acc_header,((size(
        __label_cur_acc_header) - _remlabel_cur_acc_header)+ 1),__label_cur_acc_header)))))
     SET _remlabel_cur_acc_header = (_remlabel_cur_acc_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_cur_acc_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_cur_acc_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_sponsor_header = _remlabel_sponsor_header
   IF (_remlabel_sponsor_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_sponsor_header,(
       (size(__label_sponsor_header) - _remlabel_sponsor_header)+ 1),__label_sponsor_header)))
    SET drawheight_label_sponsor_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_sponsor_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_sponsor_header,((size(
        __label_sponsor_header) - _remlabel_sponsor_header)+ 1),__label_sponsor_header)))))
     SET _remlabel_sponsor_header = (_remlabel_sponsor_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_sponsor_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_sponsor_header)
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_prot_mnemonic_header
   IF (ncalc=rpt_render
    AND _holdremlabel_prot_mnemonic_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_prot_mnemonic_header,((size(__label_prot_mnemonic_header) -
       _holdremlabel_prot_mnemonic_header)+ 1),__label_prot_mnemonic_header)))
   ELSE
    SET _remlabel_prot_mnemonic_header = _holdremlabel_prot_mnemonic_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_init_act_header
   IF (ncalc=rpt_render
    AND _holdremlabel_init_act_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_init_act_header,((size(__label_init_act_header) - _holdremlabel_init_act_header)
       + 1),__label_init_act_header)))
   ELSE
    SET _remlabel_init_act_header = _holdremlabel_init_act_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_init_serv_header
   IF (ncalc=rpt_render
    AND _holdremlabel_init_serv_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_init_serv_header,((size(__label_init_serv_header) -
       _holdremlabel_init_serv_header)+ 1),__label_init_serv_header)))
   ELSE
    SET _remlabel_init_serv_header = _holdremlabel_init_serv_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_status_header
   IF (ncalc=rpt_render
    AND _holdremlabel_status_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_status_header,((size(__label_status_header) - _holdremlabel_status_header)+ 1),
       __label_status_header)))
   ELSE
    SET _remlabel_status_header = _holdremlabel_status_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_cur_amd_header
   IF (ncalc=rpt_render
    AND _holdremlabel_cur_amd_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_cur_amd_header,((size(__label_cur_amd_header) - _holdremlabel_cur_amd_header)+ 1
       ),__label_cur_amd_header)))
   ELSE
    SET _remlabel_cur_amd_header = _holdremlabel_cur_amd_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.625)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_amd_act_date_header
   IF (ncalc=rpt_render
    AND _holdremlabel_amd_act_date_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_amd_act_date_header,((size(__label_amd_act_date_header) -
       _holdremlabel_amd_act_date_header)+ 1),__label_amd_act_date_header)))
   ELSE
    SET _remlabel_amd_act_date_header = _holdremlabel_amd_act_date_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_cur_acc_header
   IF (ncalc=rpt_render
    AND _holdremlabel_cur_acc_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_cur_acc_header,((size(__label_cur_acc_header) - _holdremlabel_cur_acc_header)+ 1
       ),__label_cur_acc_header)))
   ELSE
    SET _remlabel_cur_acc_header = _holdremlabel_cur_acc_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = drawheight_label_sponsor_header
   IF (ncalc=rpt_render
    AND _holdremlabel_sponsor_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_sponsor_header,((size(__label_sponsor_header) - _holdremlabel_sponsor_header)+ 1
       ),__label_sponsor_header)))
   ELSE
    SET _remlabel_sponsor_header = _holdremlabel_sponsor_header
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
 SUBROUTINE headpagesection_no_amd(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_no_amdabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection_no_amdabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_prot_mnemonic_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_init_act_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_init_serv_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_status_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_cur_acc_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_sponsor_header = f8 WITH noconstant(0.0), private
   DECLARE __label_prot_mnemonic_header = vc WITH noconstant(build2(label->prot_mnemonic_header,char(
      0))), protect
   DECLARE __label_init_act_header = vc WITH noconstant(build2(label->init_act_header,char(0))),
   protect
   DECLARE __label_init_serv_header = vc WITH noconstant(build2(label->init_serv_header,char(0))),
   protect
   DECLARE __label_status_header = vc WITH noconstant(build2(label->status_header,char(0))), protect
   DECLARE __label_cur_acc_header = vc WITH noconstant(build2(label->cur_acc_header,char(0))),
   protect
   DECLARE __label_sponsor_header = vc WITH noconstant(build2(label->sponsor_header,char(0))),
   protect
   IF ( NOT (( $DETAILLEVEL=0)))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_prot_mnemonic_header = 1
    SET _remlabel_init_act_header = 1
    SET _remlabel_init_serv_header = 1
    SET _remlabel_status_header = 1
    SET _remlabel_cur_acc_header = 1
    SET _remlabel_sponsor_header = 1
   ENDIF
   SET rptsd->m_flags = 1029
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
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_prot_mnemonic_header = _remlabel_prot_mnemonic_header
   IF (_remlabel_prot_mnemonic_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_prot_mnemonic_header,((size(__label_prot_mnemonic_header) -
       _remlabel_prot_mnemonic_header)+ 1),__label_prot_mnemonic_header)))
    SET drawheight_label_prot_mnemonic_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_prot_mnemonic_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_prot_mnemonic_header,((size(
        __label_prot_mnemonic_header) - _remlabel_prot_mnemonic_header)+ 1),
       __label_prot_mnemonic_header)))))
     SET _remlabel_prot_mnemonic_header = (_remlabel_prot_mnemonic_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_prot_mnemonic_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_prot_mnemonic_header)
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_init_act_header = _remlabel_init_act_header
   IF (_remlabel_init_act_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_init_act_header,
       ((size(__label_init_act_header) - _remlabel_init_act_header)+ 1),__label_init_act_header)))
    SET drawheight_label_init_act_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_init_act_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_init_act_header,((size(
        __label_init_act_header) - _remlabel_init_act_header)+ 1),__label_init_act_header)))))
     SET _remlabel_init_act_header = (_remlabel_init_act_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_init_act_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_init_act_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_init_serv_header = _remlabel_init_serv_header
   IF (_remlabel_init_serv_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_init_serv_header,
       ((size(__label_init_serv_header) - _remlabel_init_serv_header)+ 1),__label_init_serv_header)))
    SET drawheight_label_init_serv_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_init_serv_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_init_serv_header,((size(
        __label_init_serv_header) - _remlabel_init_serv_header)+ 1),__label_init_serv_header)))))
     SET _remlabel_init_serv_header = (_remlabel_init_serv_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_init_serv_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_init_serv_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_status_header = _remlabel_status_header
   IF (_remlabel_status_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_status_header,((
       size(__label_status_header) - _remlabel_status_header)+ 1),__label_status_header)))
    SET drawheight_label_status_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_status_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_status_header,((size(
        __label_status_header) - _remlabel_status_header)+ 1),__label_status_header)))))
     SET _remlabel_status_header = (_remlabel_status_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_status_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_status_header)
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_cur_acc_header = _remlabel_cur_acc_header
   IF (_remlabel_cur_acc_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_cur_acc_header,(
       (size(__label_cur_acc_header) - _remlabel_cur_acc_header)+ 1),__label_cur_acc_header)))
    SET drawheight_label_cur_acc_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_cur_acc_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_cur_acc_header,((size(
        __label_cur_acc_header) - _remlabel_cur_acc_header)+ 1),__label_cur_acc_header)))))
     SET _remlabel_cur_acc_header = (_remlabel_cur_acc_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_cur_acc_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_cur_acc_header)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_sponsor_header = _remlabel_sponsor_header
   IF (_remlabel_sponsor_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_sponsor_header,(
       (size(__label_sponsor_header) - _remlabel_sponsor_header)+ 1),__label_sponsor_header)))
    SET drawheight_label_sponsor_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_sponsor_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_sponsor_header,((size(
        __label_sponsor_header) - _remlabel_sponsor_header)+ 1),__label_sponsor_header)))))
     SET _remlabel_sponsor_header = (_remlabel_sponsor_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_sponsor_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_sponsor_header)
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_label_prot_mnemonic_header
   IF (ncalc=rpt_render
    AND _holdremlabel_prot_mnemonic_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_prot_mnemonic_header,((size(__label_prot_mnemonic_header) -
       _holdremlabel_prot_mnemonic_header)+ 1),__label_prot_mnemonic_header)))
   ELSE
    SET _remlabel_prot_mnemonic_header = _holdremlabel_prot_mnemonic_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_label_init_act_header
   IF (ncalc=rpt_render
    AND _holdremlabel_init_act_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_init_act_header,((size(__label_init_act_header) - _holdremlabel_init_act_header)
       + 1),__label_init_act_header)))
   ELSE
    SET _remlabel_init_act_header = _holdremlabel_init_act_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_label_init_serv_header
   IF (ncalc=rpt_render
    AND _holdremlabel_init_serv_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_init_serv_header,((size(__label_init_serv_header) -
       _holdremlabel_init_serv_header)+ 1),__label_init_serv_header)))
   ELSE
    SET _remlabel_init_serv_header = _holdremlabel_init_serv_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_label_status_header
   IF (ncalc=rpt_render
    AND _holdremlabel_status_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_status_header,((size(__label_status_header) - _holdremlabel_status_header)+ 1),
       __label_status_header)))
   ELSE
    SET _remlabel_status_header = _holdremlabel_status_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_cur_acc_header
   IF (ncalc=rpt_render
    AND _holdremlabel_cur_acc_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_cur_acc_header,((size(__label_cur_acc_header) - _holdremlabel_cur_acc_header)+ 1
       ),__label_cur_acc_header)))
   ELSE
    SET _remlabel_cur_acc_header = _holdremlabel_cur_acc_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = drawheight_label_sponsor_header
   IF (ncalc=rpt_render
    AND _holdremlabel_sponsor_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_sponsor_header,((size(__label_sponsor_header) - _holdremlabel_sponsor_header)+ 1
       ),__label_sponsor_header)))
   ELSE
    SET _remlabel_sponsor_header = _holdremlabel_sponsor_header
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
 SUBROUTINE headpagesection_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 10.479),(offsety
     + 0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection_amd(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_amdabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsection_amdabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_tmp_prot = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_init_act_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_init_srv = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_cur_acc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_amd_desc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_act_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_sponsor = f8 WITH noconstant(0.0), private
   DECLARE __tmp_prot = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __tmp_init_act_date = vc WITH noconstant(build2(tmp_init_act_date,char(0))), protect
   DECLARE __tmp_init_srv = vc WITH noconstant(build2(tmp_init_srv,char(0))), protect
   DECLARE __tmp_status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __tmp_cur_acc = vc WITH noconstant(build2(tmp_cur_acc,char(0))), protect
   DECLARE __tmp_amd_desc = vc WITH noconstant(build2(tmp_amd_desc,char(0))), protect
   DECLARE __tmp_act_date = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   DECLARE __tmp_sponsor = vc WITH noconstant(build2(tmp_sponsor,char(0))), protect
   IF (bcontinue=0)
    SET _remtmp_prot = 1
    SET _remtmp_init_act_date = 1
    SET _remtmp_init_srv = 1
    SET _remtmp_status = 1
    SET _remtmp_cur_acc = 1
    SET _remtmp_amd_desc = 1
    SET _remtmp_act_date = 1
    SET _remtmp_sponsor = 1
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
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtmp_prot = _remtmp_prot
   IF (_remtmp_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_prot,((size(
        __tmp_prot) - _remtmp_prot)+ 1),__tmp_prot)))
    SET drawheight_tmp_prot = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_prot = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_prot,((size(__tmp_prot) -
       _remtmp_prot)+ 1),__tmp_prot)))))
     SET _remtmp_prot = (_remtmp_prot+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_prot = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_prot)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_init_act_date = _remtmp_init_act_date
   IF (_remtmp_init_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_init_act_date,((
       size(__tmp_init_act_date) - _remtmp_init_act_date)+ 1),__tmp_init_act_date)))
    SET drawheight_tmp_init_act_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_init_act_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_init_act_date,((size(
        __tmp_init_act_date) - _remtmp_init_act_date)+ 1),__tmp_init_act_date)))))
     SET _remtmp_init_act_date = (_remtmp_init_act_date+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_init_act_date = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_init_act_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_init_srv = _remtmp_init_srv
   IF (_remtmp_init_srv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_init_srv,((size(
        __tmp_init_srv) - _remtmp_init_srv)+ 1),__tmp_init_srv)))
    SET drawheight_tmp_init_srv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_init_srv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_init_srv,((size(__tmp_init_srv) -
       _remtmp_init_srv)+ 1),__tmp_init_srv)))))
     SET _remtmp_init_srv = (_remtmp_init_srv+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_init_srv = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_init_srv)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_status = _remtmp_status
   IF (_remtmp_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_status,((size(
        __tmp_status) - _remtmp_status)+ 1),__tmp_status)))
    SET drawheight_tmp_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_status = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_status,((size(__tmp_status) -
       _remtmp_status)+ 1),__tmp_status)))))
     SET _remtmp_status = (_remtmp_status+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_status = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_status)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_cur_acc = _remtmp_cur_acc
   IF (_remtmp_cur_acc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_cur_acc,((size(
        __tmp_cur_acc) - _remtmp_cur_acc)+ 1),__tmp_cur_acc)))
    SET drawheight_tmp_cur_acc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_cur_acc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_cur_acc,((size(__tmp_cur_acc) -
       _remtmp_cur_acc)+ 1),__tmp_cur_acc)))))
     SET _remtmp_cur_acc = (_remtmp_cur_acc+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_cur_acc = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_cur_acc)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_amd_desc = _remtmp_amd_desc
   IF (_remtmp_amd_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_amd_desc,((size(
        __tmp_amd_desc) - _remtmp_amd_desc)+ 1),__tmp_amd_desc)))
    SET drawheight_tmp_amd_desc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_amd_desc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_amd_desc,((size(__tmp_amd_desc) -
       _remtmp_amd_desc)+ 1),__tmp_amd_desc)))))
     SET _remtmp_amd_desc = (_remtmp_amd_desc+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_amd_desc = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_amd_desc)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.625)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_act_date = _remtmp_act_date
   IF (_remtmp_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_act_date,((size(
        __tmp_act_date) - _remtmp_act_date)+ 1),__tmp_act_date)))
    SET drawheight_tmp_act_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_act_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_act_date,((size(__tmp_act_date) -
       _remtmp_act_date)+ 1),__tmp_act_date)))))
     SET _remtmp_act_date = (_remtmp_act_date+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_act_date = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_act_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_sponsor = _remtmp_sponsor
   IF (_remtmp_sponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_sponsor,((size(
        __tmp_sponsor) - _remtmp_sponsor)+ 1),__tmp_sponsor)))
    SET drawheight_tmp_sponsor = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_sponsor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_sponsor,((size(__tmp_sponsor) -
       _remtmp_sponsor)+ 1),__tmp_sponsor)))))
     SET _remtmp_sponsor = (_remtmp_sponsor+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_sponsor = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_sponsor)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_tmp_prot
   IF (ncalc=rpt_render
    AND _holdremtmp_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_prot,((size(
        __tmp_prot) - _holdremtmp_prot)+ 1),__tmp_prot)))
   ELSE
    SET _remtmp_prot = _holdremtmp_prot
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_tmp_init_act_date
   IF (ncalc=rpt_render
    AND _holdremtmp_init_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_init_act_date,
       ((size(__tmp_init_act_date) - _holdremtmp_init_act_date)+ 1),__tmp_init_act_date)))
   ELSE
    SET _remtmp_init_act_date = _holdremtmp_init_act_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_tmp_init_srv
   IF (ncalc=rpt_render
    AND _holdremtmp_init_srv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_init_srv,((
       size(__tmp_init_srv) - _holdremtmp_init_srv)+ 1),__tmp_init_srv)))
   ELSE
    SET _remtmp_init_srv = _holdremtmp_init_srv
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.125)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_tmp_status
   IF (ncalc=rpt_render
    AND _holdremtmp_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_status,((size(
        __tmp_status) - _holdremtmp_status)+ 1),__tmp_status)))
   ELSE
    SET _remtmp_status = _holdremtmp_status
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_tmp_cur_acc
   IF (ncalc=rpt_render
    AND _holdremtmp_cur_acc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_cur_acc,((size
       (__tmp_cur_acc) - _holdremtmp_cur_acc)+ 1),__tmp_cur_acc)))
   ELSE
    SET _remtmp_cur_acc = _holdremtmp_cur_acc
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_tmp_amd_desc
   IF (ncalc=rpt_render
    AND _holdremtmp_amd_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_amd_desc,((
       size(__tmp_amd_desc) - _holdremtmp_amd_desc)+ 1),__tmp_amd_desc)))
   ELSE
    SET _remtmp_amd_desc = _holdremtmp_amd_desc
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.625)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_tmp_act_date
   IF (ncalc=rpt_render
    AND _holdremtmp_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_act_date,((
       size(__tmp_act_date) - _holdremtmp_act_date)+ 1),__tmp_act_date)))
   ELSE
    SET _remtmp_act_date = _holdremtmp_act_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = drawheight_tmp_sponsor
   IF (ncalc=rpt_render
    AND _holdremtmp_sponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_sponsor,((size
       (__tmp_sponsor) - _holdremtmp_sponsor)+ 1),__tmp_sponsor)))
   ELSE
    SET _remtmp_sponsor = _holdremtmp_sponsor
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
 SUBROUTINE detailsection_no_amd(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_no_amdabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsection_no_amdabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_tmp_prot = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_init_act_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_init_srv = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_cur_acc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_sponsor = f8 WITH noconstant(0.0), private
   DECLARE __tmp_prot = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __tmp_init_act_date = vc WITH noconstant(build2(tmp_init_act_date,char(0))), protect
   DECLARE __tmp_init_srv = vc WITH noconstant(build2(tmp_init_srv,char(0))), protect
   DECLARE __tmp_status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __tmp_cur_acc = vc WITH noconstant(build2(tmp_cur_acc,char(0))), protect
   DECLARE __tmp_sponsor = vc WITH noconstant(build2(tmp_sponsor,char(0))), protect
   IF (bcontinue=0)
    SET _remtmp_prot = 1
    SET _remtmp_init_act_date = 1
    SET _remtmp_init_srv = 1
    SET _remtmp_status = 1
    SET _remtmp_cur_acc = 1
    SET _remtmp_sponsor = 1
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
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtmp_prot = _remtmp_prot
   IF (_remtmp_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_prot,((size(
        __tmp_prot) - _remtmp_prot)+ 1),__tmp_prot)))
    SET drawheight_tmp_prot = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_prot = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_prot,((size(__tmp_prot) -
       _remtmp_prot)+ 1),__tmp_prot)))))
     SET _remtmp_prot = (_remtmp_prot+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_prot = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_prot)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_init_act_date = _remtmp_init_act_date
   IF (_remtmp_init_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_init_act_date,((
       size(__tmp_init_act_date) - _remtmp_init_act_date)+ 1),__tmp_init_act_date)))
    SET drawheight_tmp_init_act_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_init_act_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_init_act_date,((size(
        __tmp_init_act_date) - _remtmp_init_act_date)+ 1),__tmp_init_act_date)))))
     SET _remtmp_init_act_date = (_remtmp_init_act_date+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_init_act_date = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_init_act_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_init_srv = _remtmp_init_srv
   IF (_remtmp_init_srv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_init_srv,((size(
        __tmp_init_srv) - _remtmp_init_srv)+ 1),__tmp_init_srv)))
    SET drawheight_tmp_init_srv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_init_srv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_init_srv,((size(__tmp_init_srv) -
       _remtmp_init_srv)+ 1),__tmp_init_srv)))))
     SET _remtmp_init_srv = (_remtmp_init_srv+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_init_srv = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_init_srv)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_status = _remtmp_status
   IF (_remtmp_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_status,((size(
        __tmp_status) - _remtmp_status)+ 1),__tmp_status)))
    SET drawheight_tmp_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_status = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_status,((size(__tmp_status) -
       _remtmp_status)+ 1),__tmp_status)))))
     SET _remtmp_status = (_remtmp_status+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_status = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_status)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_cur_acc = _remtmp_cur_acc
   IF (_remtmp_cur_acc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_cur_acc,((size(
        __tmp_cur_acc) - _remtmp_cur_acc)+ 1),__tmp_cur_acc)))
    SET drawheight_tmp_cur_acc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_cur_acc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_cur_acc,((size(__tmp_cur_acc) -
       _remtmp_cur_acc)+ 1),__tmp_cur_acc)))))
     SET _remtmp_cur_acc = (_remtmp_cur_acc+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_cur_acc = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_cur_acc)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_sponsor = _remtmp_sponsor
   IF (_remtmp_sponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_sponsor,((size(
        __tmp_sponsor) - _remtmp_sponsor)+ 1),__tmp_sponsor)))
    SET drawheight_tmp_sponsor = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_sponsor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_sponsor,((size(__tmp_sponsor) -
       _remtmp_sponsor)+ 1),__tmp_sponsor)))))
     SET _remtmp_sponsor = (_remtmp_sponsor+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_sponsor = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_sponsor)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_tmp_prot
   IF (ncalc=rpt_render
    AND _holdremtmp_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_prot,((size(
        __tmp_prot) - _holdremtmp_prot)+ 1),__tmp_prot)))
   ELSE
    SET _remtmp_prot = _holdremtmp_prot
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_tmp_init_act_date
   IF (ncalc=rpt_render
    AND _holdremtmp_init_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_init_act_date,
       ((size(__tmp_init_act_date) - _holdremtmp_init_act_date)+ 1),__tmp_init_act_date)))
   ELSE
    SET _remtmp_init_act_date = _holdremtmp_init_act_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_tmp_init_srv
   IF (ncalc=rpt_render
    AND _holdremtmp_init_srv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_init_srv,((
       size(__tmp_init_srv) - _holdremtmp_init_srv)+ 1),__tmp_init_srv)))
   ELSE
    SET _remtmp_init_srv = _holdremtmp_init_srv
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_tmp_status
   IF (ncalc=rpt_render
    AND _holdremtmp_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_status,((size(
        __tmp_status) - _holdremtmp_status)+ 1),__tmp_status)))
   ELSE
    SET _remtmp_status = _holdremtmp_status
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_tmp_cur_acc
   IF (ncalc=rpt_render
    AND _holdremtmp_cur_acc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_cur_acc,((size
       (__tmp_cur_acc) - _holdremtmp_cur_acc)+ 1),__tmp_cur_acc)))
   ELSE
    SET _remtmp_cur_acc = _holdremtmp_cur_acc
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = drawheight_tmp_sponsor
   IF (ncalc=rpt_render
    AND _holdremtmp_sponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_sponsor,((size
       (__tmp_sponsor) - _holdremtmp_sponsor)+ 1),__tmp_sponsor)))
   ELSE
    SET _remtmp_sponsor = _holdremtmp_sponsor
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
   DECLARE sectionheight = f8 WITH noconstant(0.520000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rep_exec_time = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_page = f8 WITH noconstant(0.0), private
   DECLARE __label_rep_exec_time = vc WITH noconstant(build2(label->rep_exec_time,char(0))), protect
   DECLARE __label_rpt_page = vc WITH noconstant(build2(concat(label->rpt_page," ",trim(cnvtstring(
        curpage),3)),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rep_exec_time = 1
    SET _remlabel_rpt_page = 1
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
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rep_exec_time = _remlabel_rep_exec_time
   IF (_remlabel_rep_exec_time > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rep_exec_time,((
       size(__label_rep_exec_time) - _remlabel_rep_exec_time)+ 1),__label_rep_exec_time)))
    SET drawheight_label_rep_exec_time = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rep_exec_time = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rep_exec_time,((size(
        __label_rep_exec_time) - _remlabel_rep_exec_time)+ 1),__label_rep_exec_time)))))
     SET _remlabel_rep_exec_time = (_remlabel_rep_exec_time+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rep_exec_time = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rep_exec_time)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_page = _remlabel_rpt_page
   IF (_remlabel_rpt_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_page,((size(
        __label_rpt_page) - _remlabel_rpt_page)+ 1),__label_rpt_page)))
    SET drawheight_label_rpt_page = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_page = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_page,((size(__label_rpt_page
        ) - _remlabel_rpt_page)+ 1),__label_rpt_page)))))
     SET _remlabel_rpt_page = (_remlabel_rpt_page+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_page = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_page)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_rep_exec_time
   IF (ncalc=rpt_render
    AND _holdremlabel_rep_exec_time > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rep_exec_time,((size(__label_rep_exec_time) - _holdremlabel_rep_exec_time)+ 1),
       __label_rep_exec_time)))
   ELSE
    SET _remlabel_rep_exec_time = _holdremlabel_rep_exec_time
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_rpt_page
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_page,((
       size(__label_rpt_page) - _holdremlabel_rpt_page)+ 1),__label_rpt_page)))
   ELSE
    SET _remlabel_rpt_page = _holdremlabel_rpt_page
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
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_total_prot = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total_init_serv = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total_statuses = f8 WITH noconstant(0.0), private
   DECLARE __label_total_prot = vc WITH noconstant(build2(concat(label->total_prot," ",trim(
       cnvtstring(size(results->protocols,5),3))),char(0))), protect
   DECLARE __label_total_init_serv = vc WITH noconstant(build2(concat(label->total_init_serv," ",trim
      (cnvtstring(init_service_cnt,3))),char(0))), protect
   DECLARE __label_total_statuses = vc WITH noconstant(build2(concat(label->total_statuses," ",trim(
       cnvtstring(status_cnt,3))),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_total_prot = 1
    SET _remlabel_total_init_serv = 1
    SET _remlabel_total_statuses = 1
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
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier9b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_total_prot = _remlabel_total_prot
   IF (_remlabel_total_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_prot,((
       size(__label_total_prot) - _remlabel_total_prot)+ 1),__label_total_prot)))
    SET drawheight_label_total_prot = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_prot = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_prot,((size(
        __label_total_prot) - _remlabel_total_prot)+ 1),__label_total_prot)))))
     SET _remlabel_total_prot = (_remlabel_total_prot+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_prot = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_prot)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_total_init_serv = _remlabel_total_init_serv
   IF (_remlabel_total_init_serv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_init_serv,
       ((size(__label_total_init_serv) - _remlabel_total_init_serv)+ 1),__label_total_init_serv)))
    SET drawheight_label_total_init_serv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_init_serv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_init_serv,((size(
        __label_total_init_serv) - _remlabel_total_init_serv)+ 1),__label_total_init_serv)))))
     SET _remlabel_total_init_serv = (_remlabel_total_init_serv+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_init_serv = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_init_serv)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_total_statuses = _remlabel_total_statuses
   IF (_remlabel_total_statuses > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_statuses,(
       (size(__label_total_statuses) - _remlabel_total_statuses)+ 1),__label_total_statuses)))
    SET drawheight_label_total_statuses = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_statuses = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_statuses,((size(
        __label_total_statuses) - _remlabel_total_statuses)+ 1),__label_total_statuses)))))
     SET _remlabel_total_statuses = (_remlabel_total_statuses+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_statuses = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_statuses)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_prot
   IF (ncalc=rpt_render
    AND _holdremlabel_total_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total_prot,(
       (size(__label_total_prot) - _holdremlabel_total_prot)+ 1),__label_total_prot)))
   ELSE
    SET _remlabel_total_prot = _holdremlabel_total_prot
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_init_serv
   IF (ncalc=rpt_render
    AND _holdremlabel_total_init_serv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_total_init_serv,((size(__label_total_init_serv) - _holdremlabel_total_init_serv)
       + 1),__label_total_init_serv)))
   ELSE
    SET _remlabel_total_init_serv = _holdremlabel_total_init_serv
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_statuses
   IF (ncalc=rpt_render
    AND _holdremlabel_total_statuses > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_total_statuses,((size(__label_total_statuses) - _holdremlabel_total_statuses)+ 1
       ),__label_total_statuses)))
   ELSE
    SET _remlabel_total_statuses = _holdremlabel_total_statuses
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
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_PROT_INIT_SRV_STATUS_LO"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
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
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 60
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _courier12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _courier8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _courier80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_on
   SET _courier9b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 IF (size(results->protocols,5)=0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, label->rpt_title, row + 1,
    col 0, label->rep_exec_time, row + 2,
    col 0, label->criteria_not_met
   WITH nocounter
  ;end select
 ELSEIF (( $OUT_TYPE=1))
  SELECT INTO  $OUTDEV
   prot_mnemonic = results->protocols[d.seq].prot_mnemonic, prot_id = results->protocols[d.seq].
   prot_master_id, init_service_cd = results->protocols[d.seq].init_service_cd,
   status_cd = results->protocols[d.seq].prot_status_cd
   FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
   ORDER BY parser(reportlist->order_by)
   HEAD REPORT
    col 0, label->rpt_title, row + 1,
    col 0, label->rpt_sorted_title, row + 1
    IF ((((reportlist->all_init_services=1)) OR ((reportlist->all_statuses=1))) )
     col 0, label->rpt_serv_stat_title, row + 1
    ENDIF
    col 0, label->rep_exec_time, row + 1,
    init_service_cnt = 0, status_cnt = 0
    IF (( $DETAILLEVEL=1))
     tempstr = concat(label->prot_mnemonic_header, $DELIMITER,label->init_act_header, $DELIMITER,
      label->init_serv_header,
       $DELIMITER,label->status_header, $DELIMITER,label->cur_amd_header, $DELIMITER,
      label->amd_act_date_header, $DELIMITER,label->cur_acc_header, $DELIMITER,label->sponsor_header),
     col 0, tempstr,
     row + 1
    ELSE
     tempstr = concat(label->prot_mnemonic_header, $DELIMITER,label->init_act_header, $DELIMITER,
      label->init_serv_header,
       $DELIMITER,label->status_header, $DELIMITER,label->cur_acc_header, $DELIMITER,
      label->sponsor_header), col 0, tempstr,
     row + 1
    ENDIF
   DETAIL
    tmp_prot = results->protocols[d.seq].prot_mnemonic
    IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
     AND (results->protocols[d.seq].init_activation_date > 0))
     tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
    ELSE
     tmp_init_act_date = ""
    ENDIF
    tmp_init_srv = results->protocols[d.seq].init_service_disp, tmp_status = results->protocols[d.seq
    ].prot_status_disp, tmp_cur_acc = trim(cnvtstring(results->protocols[d.seq].cur_accrual),3)
    IF ( NOT ((results->protocols[d.seq].primary_sponsor IN ("", " ", null))))
     tmp_sponsor = results->protocols[d.seq].primary_sponsor
    ELSE
     tmp_sponsor = ""
    ENDIF
    tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_init_act_date = concat('"',trim(
      tmp_init_act_date,3),'"'), tmp_init_srv = concat('"',trim(tmp_init_srv,3),'"'),
    tmp_status = concat('"',trim(tmp_status,3),'"'), tempstr = concat(tmp_prot, $DELIMITER,
     tmp_init_act_date, $DELIMITER,tmp_init_srv,
      $DELIMITER,tmp_status)
    IF (( $DETAILLEVEL=1))
     IF ((results->protocols[d.seq].amd_nbr > 0))
      tmp_amd_desc = concat(label->amendment," ",trim(cnvtstring(results->protocols[d.seq].amd_nbr)))
     ELSE
      tmp_amd_desc = label->init_prot
     ENDIF
     IF ((results->protocols[d.seq].amd_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].amd_activation_date > 0))
      tmp_act_date = format(results->protocols[d.seq].amd_activation_date,"@SHORTDATE")
     ELSE
      tmp_act_date = ""
     ENDIF
     IF ((results->protocols[d.seq].revision_ind=1))
      tmp_amd_desc = concat(tmp_amd_desc," - ",label->revision," ",results->protocols[d.seq].
       revision_nbr_txt)
     ENDIF
     tmp_amd_desc = concat('"',trim(tmp_amd_desc,3),'"'), tmp_act_date = concat('"',trim(tmp_act_date,
       3),'"'), tempstr = concat(tempstr, $DELIMITER,tmp_amd_desc, $DELIMITER,tmp_act_date)
    ENDIF
    tmp_cur_acc = concat('"',trim(tmp_cur_acc,3),'"'), tmp_sponsor = concat('"',trim(tmp_sponsor,3),
     '"'), tempstr = concat(tempstr, $DELIMITER,tmp_cur_acc, $DELIMITER,tmp_sponsor),
    status_pos = locateval(num,1,size(statuslist->statuses,5),results->protocols[d.seq].
     prot_status_cd,statuslist->statuses[num].prot_status_cd)
    IF (status_pos=0)
     status_cnt = (status_cnt+ 1)
     IF (mod(status_cnt,10)=1)
      stat = alterlist(statuslist->statuses,(status_cnt+ 9))
     ENDIF
     statuslist->statuses[status_cnt].prot_status_cd = results->protocols[d.seq].prot_status_cd
    ENDIF
    status_pos = locateval(num,1,size(init_servicelist->init_services,5),results->protocols[d.seq].
     init_service_cd,init_servicelist->init_services[num].init_service_cd)
    IF (status_pos=0)
     init_service_cnt = (init_service_cnt+ 1)
     IF (mod(init_service_cnt,10)=1)
      stat = alterlist(init_servicelist->init_services,(init_service_cnt+ 9))
     ENDIF
     init_servicelist->init_services[init_service_cnt].init_service_cd = results->protocols[d.seq].
     init_service_cd
    ENDIF
    col 0, tempstr, row + 1
   FOOT REPORT
    stat = alterlist(statuslist->statuses,status_cnt), stat = alterlist(init_servicelist->
     init_services,init_service_cnt), row + 1,
    tempstr = concat(label->total_prot," ",trim(cnvtstring(size(results->protocols,5),3))), col 0,
    tempstr,
    row + 1, tempstr = concat(label->total_init_serv," ",trim(cnvtstring(size(init_servicelist->
        init_services,5),3))), col 0,
    tempstr, row + 1, tempstr = concat(label->total_statuses," ",trim(cnvtstring(size(statuslist->
        statuses,5),3))),
    col 0, tempstr, row + 2,
    col 0, label->end_of_rpt
   WITH format = crstream, formfeed = none, maxcol = 1500,
    nocounter
  ;end select
 ELSE
  CALL initializereport(0)
  CALL get_protocol_init_srv_status(0)
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "APR 04, 2016"
END GO
