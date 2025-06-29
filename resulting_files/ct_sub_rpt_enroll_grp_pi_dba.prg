CREATE PROGRAM ct_sub_rpt_enroll_grp_pi:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocol" = 0,
  "Enrolling Institution" = 0,
  "Principal Investigator" = 0,
  "Initiating Service" = 0,
  "Group By" = 0,
  "Order groups by" = 2,
  "Output Type" = 0,
  "Delimiter" = ","
  WITH outdev, protocol, org,
  person, init_svc, groupby,
  orderby, out_type, delimiter
 EXECUTE reportrtl
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_organizations_ind = i2
   1 organization_cnt = i4
   1 organizations[*]
     2 organization_id = f8
   1 all_persons_ind = i2
   1 person_cnt = i4
   1 persons[*]
     2 person_id = f8
   1 all_init_services_ind = i2
   1 init_service_cnt = i4
   1 init_services[*]
     2 init_service_cd = f8
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 pis[*]
     2 prot_master_id = f8
     2 pi_id = f8
     2 prot_role_id = f8
     2 pi_name_full = c100
   1 enrollments[*]
     2 person_id = f8
     2 prot_master_id = f8
     2 primary_mnemonic = c255
     2 initiating_service_cd = f8
     2 therapeutic_ind = i2
     2 enroll_org_id = f8
     2 enroll_org_name = c100
     2 enroll_org_coord_inst_ind = i2
     2 on_study_ind = i2
     2 off_tx_ind = i2
     2 off_study_ind = i2
 )
 RECORD countlist(
   1 prot_pis[*]
     2 pi_id = f8
     2 pi_name_full = c100
   1 pis[*]
     2 pi_id = f8
   1 init_services[*]
     2 initiating_service_cd = f8
   1 protocols[*]
     2 prot_master_id = f8
   1 enroll_orgs[*]
     2 enroll_org_id = f8
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_order_by_title = vc
   1 rep_exec_time = vc
   1 enroll_inst_header = vc
   1 prot_mnemonic_header = vc
   1 pri_investigator_header = vc
   1 init_serv_header = vc
   1 cur_on_study_header = vc
   1 cur_off_treat_header = vc
   1 cur_off_study_header = vc
   1 total_enrolled_header = vc
   1 total_sites = vc
   1 total_init = vc
   1 total_pi = vc
   1 total_prot = vc
   1 end_of_rpt = vc
   1 no_prot_found = vc
   1 unable_to_exec = vc
   1 comma = vc
   1 at_least_one_prot = vc
   1 at_least_one_org = vc
   1 at_least_one_pi = vc
   1 at_least_one_init = vc
   1 represents = vc
   1 on_the_prot = vc
   1 semi = vc
   1 rpt_page = vc
 )
 RECORD reportlist(
   1 order_by_1 = vc
   1 order_by_2 = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_enroll_site(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 DECLARE _remlabel_rpt_title = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_order_by_title = i4 WITH noconstant(1), protect
 DECLARE _remlabel_prot_mnemonic_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_cur_on_study_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_cur_off_treat_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_cur_off_study_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total_enrolled_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_enroll_inst_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_init_serv_header = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remprin_inv = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpi_idsection = i2 WITH noconstant(0), protect
 DECLARE _remprot_name = i4 WITH noconstant(1), protect
 DECLARE _remenrolling_site = i4 WITH noconstant(1), protect
 DECLARE _remon_study_date = i4 WITH noconstant(1), protect
 DECLARE _remoff_treat_date = i4 WITH noconstant(1), protect
 DECLARE _remoff_study_date = i4 WITH noconstant(1), protect
 DECLARE _remtotal_count = i4 WITH noconstant(1), protect
 DECLARE _reminit_serv = i4 WITH noconstant(1), protect
 DECLARE _bcontfootsite_idsection = i2 WITH noconstant(0), protect
 DECLARE _rembackground_color = i4 WITH noconstant(1), protect
 DECLARE _remprot_count = i4 WITH noconstant(1), protect
 DECLARE _remenrl_site_count = i4 WITH noconstant(1), protect
 DECLARE _remon_study_date = i4 WITH noconstant(1), protect
 DECLARE _remoff_treat_date = i4 WITH noconstant(1), protect
 DECLARE _remoff_study_date = i4 WITH noconstant(1), protect
 DECLARE _remtotal_count = i4 WITH noconstant(1), protect
 DECLARE _reminit_serv_count = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpi_idsection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rep_exec_time = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remtotal_prin_inv = i4 WITH noconstant(1), protect
 DECLARE _remlabel_end_of_rpt = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _courier10b0 = i4 WITH noconstant(0), protect
 DECLARE _courier12b0 = i4 WITH noconstant(0), protect
 DECLARE _courier9b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE get_enroll_site(dummy)
   SELECT
    IF (( $GROUPBY=2))
     site_id = results->enrollments[d.seq].enroll_org_id, tmp_prot = substring(1,20,results->
      enrollments[d.seq].primary_mnemonic), prot_id = results->enrollments[d.seq].prot_master_id,
     init_service_cd = results->enrollments[d.seq].initiating_service_cd, pi_id = results->pis[d2.seq
     ].pi_id, person_id = results->enrollments[d.seq].person_id,
     reportlist_order_by_1 = parser(reportlist->order_by_1), reportlist_order_by_2 = parser(
      reportlist->order_by_2)
     FROM (dummyt d  WITH seq = value(size(results->enrollments,5))),
      (dummyt d2  WITH seq = value(size(results->pis,5)))
     PLAN (d)
      JOIN (d2
      WHERE (results->pis[d2.seq].prot_master_id=results->enrollments[d.seq].prot_master_id))
     ORDER BY cnvtlower(results->pis[d2.seq].pi_name_full), reportlist_order_by_1,
      reportlist_order_by_2
     WITH nocounter, separator = " ", format
    ELSE
    ENDIF
    site_id = results->enrollments[d.seq].enroll_org_id, tmp_prot = substring(1,20,results->
     enrollments[d.seq].primary_mnemonic), prot_id = results->enrollments[d.seq].prot_master_id,
    init_service_cd = results->enrollments[d.seq].initiating_service_cd, pi_id = results->pis[d2.seq]
    .pi_id, person_id = results->enrollments[d.seq].person_id,
    reportlist_order_by_1 = parser(reportlist->order_by_1), reportlist_order_by_2 = parser(reportlist
     ->order_by_2)
    FROM (dummyt d  WITH seq = value(size(results->enrollments,5))),
     (dummyt d2  WITH seq = value(size(results->pis,5)))
    PLAN (d)
     JOIN (d2
     WHERE (results->pis[d2.seq].prot_master_id=results->enrollments[d.seq].prot_master_id))
    ORDER BY pi_id, prot_id, site_id,
     person_id
    HEAD REPORT
     _d0 = tmp_prot, _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom),
     _bholdcontinue = 0,
     _fenddetail -= footpagesection(rpt_calcheight,((rptreport->m_pagewidth - rptreport->
      m_marginbottom) - _yoffset),_bholdcontinue)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), dummy_val = headpagesection_line
     (rpt_render)
    HEAD pi_id
     on_study_total = 0, off_tx_total = 0, off_study_total = 0,
     enroll_total = 0, pi_cnt += 1, stat = alterlist(countlist->init_services,0),
     init_svc_cnt = 0, stat = alterlist(countlist->enroll_orgs,0), site_cnt = 0,
     stat = alterlist(countlist->protocols,0), prot_cnt = 0, tmp_pi = trim(results->pis[d2.seq].
      pi_name_full),
     _bcontheadpi_idsection = 0, bfirsttime = 1
     WHILE (((_bcontheadpi_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadpi_idsection, _fdrawheight = headpi_idsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight += headpi_idsection_line(rpt_calcheight)
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadpi_idsection=0)
        BREAK
       ENDIF
       dummy_val = headpi_idsection(rpt_render,(_fenddetail - _yoffset),_bcontheadpi_idsection),
       bfirsttime = 0
     ENDWHILE
     _fdrawheight = headpi_idsection_line(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headpi_idsection_line(rpt_render)
    HEAD prot_id
     rec_pos = locateval(num,1,size(countlist->protocols,5),prot_id,countlist->protocols[num].
      prot_master_id)
     IF (rec_pos=0)
      prot_cnt += 1
      IF (mod(prot_cnt,10)=1)
       stat = alterlist(countlist->protocols,(prot_cnt+ 9))
      ENDIF
      countlist->protocols[prot_cnt].prot_master_id = prot_id
     ENDIF
     rec_pos = locateval(num,1,size(countlist->init_services,5),init_service_cd,countlist->
      init_services[num].initiating_service_cd)
     IF (rec_pos=0)
      init_svc_cnt += 1
      IF (mod(init_svc_cnt,10)=1)
       stat = alterlist(countlist->init_services,(init_svc_cnt+ 9))
      ENDIF
      countlist->init_services[init_svc_cnt].initiating_service_cd = init_service_cd
     ENDIF
    HEAD site_id
     on_study_cnt = 0, off_tx_cnt = 0, off_study_cnt = 0,
     total_cnt = 0, prot_pi_cnt = 0, rec_pos = locateval(num,1,size(countlist->enroll_orgs,5),site_id,
      countlist->enroll_orgs[num].enroll_org_id)
     IF (rec_pos=0)
      site_cnt += 1
      IF (mod(site_cnt,10)=1)
       stat = alterlist(countlist->enroll_orgs,(site_cnt+ 9))
      ENDIF
      countlist->enroll_orgs[site_cnt].enroll_org_id = site_id
     ENDIF
    HEAD person_id
     IF ((results->enrollments[d.seq].off_study_ind=1))
      off_study_cnt += 1
     ELSEIF ((results->enrollments[d.seq].off_tx_ind=1))
      off_tx_cnt += 1
     ELSE
      on_study_cnt += 1
     ENDIF
    DETAIL
     row + 0
    FOOT  person_id
     row + 0
    FOOT  site_id
     total_cnt = ((on_study_cnt+ off_tx_cnt)+ off_study_cnt)
     IF ((results->enrollments[d.seq].therapeutic_ind=1))
      off_tx_str = format(off_tx_cnt,"##########")
     ELSE
      off_tx_str = "-"
     ENDIF
     tmp_prot = trim(results->enrollments[d.seq].primary_mnemonic), tmp_site = trim(results->
      enrollments[d.seq].enroll_org_name), tmp_init_svc = trim(uar_get_code_display(results->
       enrollments[d.seq].initiating_service_cd)),
     on_study_total += on_study_cnt, off_study_total += off_study_cnt, off_tx_total += off_tx_cnt,
     enroll_total += total_cnt, _bcontfootsite_idsection = 0, bfirsttime = 1
     WHILE (((_bcontfootsite_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootsite_idsection, _fdrawheight = footsite_idsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfootsite_idsection=0)
        BREAK
       ENDIF
       dummy_val = footsite_idsection(rpt_render,(_fenddetail - _yoffset),_bcontfootsite_idsection),
       bfirsttime = 0
     ENDWHILE
    FOOT  prot_id
     row + 0
    FOOT  pi_id
     _bcontfootpi_idsection = 0, bfirsttime = 1
     WHILE (((_bcontfootpi_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootpi_idsection, _fdrawheight = footpi_idsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfootpi_idsection=0)
        BREAK
       ENDIF
       dummy_val = footpi_idsection(rpt_render,(_fenddetail - _yoffset),_bcontfootpi_idsection),
       bfirsttime = 0
     ENDWHILE
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
     dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
      _yoffset),_bcontfootpagesection), _yoffset = _yhold
    FOOT REPORT
     tempstr = concat(label->total_pi," ",trim(cnvtstring(pi_cnt,3))), _bcontfootreportsection = 0,
     bfirsttime = 1
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
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
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
      SET _errcnt += 1
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
   ENDIF
 END ;Subroutine
 SUBROUTINE (headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_order_by_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_prot_mnemonic_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_cur_on_study_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_cur_off_treat_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_cur_off_study_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total_enrolled_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_enroll_inst_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_init_serv_header = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_title = vc WITH noconstant(build2(label->rpt_title,char(0))), protect
   DECLARE __label_rpt_order_by_title = vc WITH noconstant(build2(label->rpt_order_by_title,char(0))),
   protect
   DECLARE __label_prot_mnemonic_header = vc WITH noconstant(build2(label->prot_mnemonic_header,char(
      0))), protect
   DECLARE __label_cur_on_study_header = vc WITH noconstant(build2(label->cur_on_study_header,char(0)
     )), protect
   DECLARE __label_cur_off_treat_header = vc WITH noconstant(build2(label->cur_off_treat_header,char(
      0))), protect
   DECLARE __label_cur_off_study_header = vc WITH noconstant(build2(label->cur_off_study_header,char(
      0))), protect
   DECLARE __label_total_enrolled_header = vc WITH noconstant(build2(label->total_enrolled_header,
     char(0))), protect
   DECLARE __label_enroll_inst_header = vc WITH noconstant(build2(label->enroll_inst_header,char(0))),
   protect
   DECLARE __label_init_serv_header = vc WITH noconstant(build2(label->init_serv_header,char(0))),
   protect
   IF (bcontinue=0)
    SET _remlabel_rpt_title = 1
    SET _remlabel_rpt_order_by_title = 1
    SET _remlabel_prot_mnemonic_header = 1
    SET _remlabel_cur_on_study_header = 1
    SET _remlabel_cur_off_treat_header = 1
    SET _remlabel_cur_off_study_header = 1
    SET _remlabel_total_enrolled_header = 1
    SET _remlabel_enroll_inst_header = 1
    SET _remlabel_init_serv_header = 1
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
   SET rptsd->m_x = (offsetx+ - (0.062))
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
     SET _remlabel_rpt_title += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_title = 0
    ENDIF
    SET growsum += _remlabel_rpt_title
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
   SET _holdremlabel_rpt_order_by_title = _remlabel_rpt_order_by_title
   IF (_remlabel_rpt_order_by_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_rpt_order_by_title,((size(__label_rpt_order_by_title) - _remlabel_rpt_order_by_title
       )+ 1),__label_rpt_order_by_title)))
    SET drawheight_label_rpt_order_by_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_order_by_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_order_by_title,((size(
        __label_rpt_order_by_title) - _remlabel_rpt_order_by_title)+ 1),__label_rpt_order_by_title)))
    ))
     SET _remlabel_rpt_order_by_title += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_order_by_title = 0
    ENDIF
    SET growsum += _remlabel_rpt_order_by_title
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
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
     SET _remlabel_prot_mnemonic_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_prot_mnemonic_header = 0
    ENDIF
    SET growsum += _remlabel_prot_mnemonic_header
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_cur_on_study_header = _remlabel_cur_on_study_header
   IF (_remlabel_cur_on_study_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_cur_on_study_header,((size(__label_cur_on_study_header) -
       _remlabel_cur_on_study_header)+ 1),__label_cur_on_study_header)))
    SET drawheight_label_cur_on_study_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_cur_on_study_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_cur_on_study_header,((size(
        __label_cur_on_study_header) - _remlabel_cur_on_study_header)+ 1),__label_cur_on_study_header
       )))))
     SET _remlabel_cur_on_study_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_cur_on_study_header = 0
    ENDIF
    SET growsum += _remlabel_cur_on_study_header
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_cur_off_treat_header = _remlabel_cur_off_treat_header
   IF (_remlabel_cur_off_treat_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_cur_off_treat_header,((size(__label_cur_off_treat_header) -
       _remlabel_cur_off_treat_header)+ 1),__label_cur_off_treat_header)))
    SET drawheight_label_cur_off_treat_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_cur_off_treat_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_cur_off_treat_header,((size(
        __label_cur_off_treat_header) - _remlabel_cur_off_treat_header)+ 1),
       __label_cur_off_treat_header)))))
     SET _remlabel_cur_off_treat_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_cur_off_treat_header = 0
    ENDIF
    SET growsum += _remlabel_cur_off_treat_header
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.500)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_cur_off_study_header = _remlabel_cur_off_study_header
   IF (_remlabel_cur_off_study_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_cur_off_study_header,((size(__label_cur_off_study_header) -
       _remlabel_cur_off_study_header)+ 1),__label_cur_off_study_header)))
    SET drawheight_label_cur_off_study_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_cur_off_study_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_cur_off_study_header,((size(
        __label_cur_off_study_header) - _remlabel_cur_off_study_header)+ 1),
       __label_cur_off_study_header)))))
     SET _remlabel_cur_off_study_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_cur_off_study_header = 0
    ENDIF
    SET growsum += _remlabel_cur_off_study_header
   ENDIF
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.875)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_total_enrolled_header = _remlabel_total_enrolled_header
   IF (_remlabel_total_enrolled_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_total_enrolled_header,((size(__label_total_enrolled_header) -
       _remlabel_total_enrolled_header)+ 1),__label_total_enrolled_header)))
    SET drawheight_label_total_enrolled_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_enrolled_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_enrolled_header,((size(
        __label_total_enrolled_header) - _remlabel_total_enrolled_header)+ 1),
       __label_total_enrolled_header)))))
     SET _remlabel_total_enrolled_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_total_enrolled_header = 0
    ENDIF
    SET growsum += _remlabel_total_enrolled_header
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier9b0)
   SET _holdremlabel_enroll_inst_header = _remlabel_enroll_inst_header
   IF (_remlabel_enroll_inst_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_enroll_inst_header,((size(__label_enroll_inst_header) - _remlabel_enroll_inst_header
       )+ 1),__label_enroll_inst_header)))
    SET drawheight_label_enroll_inst_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_enroll_inst_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_enroll_inst_header,((size(
        __label_enroll_inst_header) - _remlabel_enroll_inst_header)+ 1),__label_enroll_inst_header)))
    ))
     SET _remlabel_enroll_inst_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_enroll_inst_header = 0
    ENDIF
    SET growsum += _remlabel_enroll_inst_header
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
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
     SET _remlabel_init_serv_header += rptsd->m_drawlength
    ELSE
     SET _remlabel_init_serv_header = 0
    ENDIF
    SET growsum += _remlabel_init_serv_header
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ - (0.062))
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
   SET rptsd->m_height = drawheight_label_rpt_order_by_title
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_order_by_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rpt_order_by_title,((size(__label_rpt_order_by_title) -
       _holdremlabel_rpt_order_by_title)+ 1),__label_rpt_order_by_title)))
   ELSE
    SET _remlabel_rpt_order_by_title = _holdremlabel_rpt_order_by_title
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_prot_mnemonic_header
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
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
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_cur_on_study_header
   IF (ncalc=rpt_render
    AND _holdremlabel_cur_on_study_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_cur_on_study_header,((size(__label_cur_on_study_header) -
       _holdremlabel_cur_on_study_header)+ 1),__label_cur_on_study_header)))
   ELSE
    SET _remlabel_cur_on_study_header = _holdremlabel_cur_on_study_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_cur_off_treat_header
   IF (ncalc=rpt_render
    AND _holdremlabel_cur_off_treat_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_cur_off_treat_header,((size(__label_cur_off_treat_header) -
       _holdremlabel_cur_off_treat_header)+ 1),__label_cur_off_treat_header)))
   ELSE
    SET _remlabel_cur_off_treat_header = _holdremlabel_cur_off_treat_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.500)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_cur_off_study_header
   IF (ncalc=rpt_render
    AND _holdremlabel_cur_off_study_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_cur_off_study_header,((size(__label_cur_off_study_header) -
       _holdremlabel_cur_off_study_header)+ 1),__label_cur_off_study_header)))
   ELSE
    SET _remlabel_cur_off_study_header = _holdremlabel_cur_off_study_header
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.875)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = drawheight_label_total_enrolled_header
   IF (ncalc=rpt_render
    AND _holdremlabel_total_enrolled_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_total_enrolled_header,((size(__label_total_enrolled_header) -
       _holdremlabel_total_enrolled_header)+ 1),__label_total_enrolled_header)))
   ELSE
    SET _remlabel_total_enrolled_header = _holdremlabel_total_enrolled_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = drawheight_label_enroll_inst_header
   SET _dummyfont = uar_rptsetfont(_hreport,_courier9b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_enroll_inst_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_enroll_inst_header,((size(__label_enroll_inst_header) -
       _holdremlabel_enroll_inst_header)+ 1),__label_enroll_inst_header)))
   ELSE
    SET _remlabel_enroll_inst_header = _holdremlabel_enroll_inst_header
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_label_init_serv_header
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_init_serv_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_init_serv_header,((size(__label_init_serv_header) -
       _holdremlabel_init_serv_header)+ 1),__label_init_serv_header)))
   ELSE
    SET _remlabel_init_serv_header = _holdremlabel_init_serv_header
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
 SUBROUTINE (headpagesection_line(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_lineabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 10.500),(offsety
     + 0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpi_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpi_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpi_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.650000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prin_inv = f8 WITH noconstant(0.0), private
   DECLARE __prin_inv = vc WITH noconstant(build2(tmp_pi,char(0))), protect
   IF (bcontinue=0)
    SET _remprin_inv = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.020
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprin_inv = _remprin_inv
   IF (_remprin_inv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprin_inv,((size(
        __prin_inv) - _remprin_inv)+ 1),__prin_inv)))
    SET drawheight_prin_inv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprin_inv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprin_inv,((size(__prin_inv) -
       _remprin_inv)+ 1),__prin_inv)))))
     SET _remprin_inv += rptsd->m_drawlength
    ELSE
     SET _remprin_inv = 0
    ENDIF
    SET growsum += _remprin_inv
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = drawheight_prin_inv
   IF (ncalc=rpt_render
    AND _holdremprin_inv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprin_inv,((size(
        __prin_inv) - _holdremprin_inv)+ 1),__prin_inv)))
   ELSE
    SET _remprin_inv = _holdremprin_inv
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
 SUBROUTINE (headpi_idsection_line(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpi_idsection_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpi_idsection_lineabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.032),(offsetx+ 10.510),(offsety
     + 0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footsite_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsite_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footsite_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.150000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prot_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_enrolling_site = f8 WITH noconstant(0.0), private
   DECLARE drawheight_on_study_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_off_treat_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_off_study_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_total_count = f8 WITH noconstant(0.0), private
   DECLARE drawheight_init_serv = f8 WITH noconstant(0.0), private
   DECLARE __prot_name = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __enrolling_site = vc WITH noconstant(build2(tmp_site,char(0))), protect
   DECLARE __on_study_date = vc WITH noconstant(build2(trim(cnvtstring(on_study_cnt),3),char(0))),
   protect
   DECLARE __off_treat_date = vc WITH noconstant(build2(trim(off_tx_str,3),char(0))), protect
   DECLARE __off_study_date = vc WITH noconstant(build2(trim(cnvtstring(off_study_cnt),3),char(0))),
   protect
   DECLARE __total_count = vc WITH noconstant(build2(trim(cnvtstring(total_cnt),3),char(0))), protect
   DECLARE __init_serv = vc WITH noconstant(build2(tmp_init_svc,char(0))), protect
   IF (bcontinue=0)
    SET _remprot_name = 1
    SET _remenrolling_site = 1
    SET _remon_study_date = 1
    SET _remoff_treat_date = 1
    SET _remoff_study_date = 1
    SET _remtotal_count = 1
    SET _reminit_serv = 1
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
     SET _remprot_name += rptsd->m_drawlength
    ELSE
     SET _remprot_name = 0
    ENDIF
    SET growsum += _remprot_name
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.344)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremenrolling_site = _remenrolling_site
   IF (_remenrolling_site > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remenrolling_site,((size(
        __enrolling_site) - _remenrolling_site)+ 1),__enrolling_site)))
    SET drawheight_enrolling_site = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remenrolling_site = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remenrolling_site,((size(__enrolling_site
        ) - _remenrolling_site)+ 1),__enrolling_site)))))
     SET _remenrolling_site += rptsd->m_drawlength
    ELSE
     SET _remenrolling_site = 0
    ENDIF
    SET growsum += _remenrolling_site
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.740)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremon_study_date = _remon_study_date
   IF (_remon_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remon_study_date,((size(
        __on_study_date) - _remon_study_date)+ 1),__on_study_date)))
    SET drawheight_on_study_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remon_study_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remon_study_date,((size(__on_study_date)
        - _remon_study_date)+ 1),__on_study_date)))))
     SET _remon_study_date += rptsd->m_drawlength
    ELSE
     SET _remon_study_date = 0
    ENDIF
    SET growsum += _remon_study_date
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremoff_treat_date = _remoff_treat_date
   IF (_remoff_treat_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remoff_treat_date,((size(
        __off_treat_date) - _remoff_treat_date)+ 1),__off_treat_date)))
    SET drawheight_off_treat_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remoff_treat_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remoff_treat_date,((size(__off_treat_date
        ) - _remoff_treat_date)+ 1),__off_treat_date)))))
     SET _remoff_treat_date += rptsd->m_drawlength
    ELSE
     SET _remoff_treat_date = 0
    ENDIF
    SET growsum += _remoff_treat_date
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.531)
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremoff_study_date = _remoff_study_date
   IF (_remoff_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remoff_study_date,((size(
        __off_study_date) - _remoff_study_date)+ 1),__off_study_date)))
    SET drawheight_off_study_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remoff_study_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remoff_study_date,((size(__off_study_date
        ) - _remoff_study_date)+ 1),__off_study_date)))))
     SET _remoff_study_date += rptsd->m_drawlength
    ELSE
     SET _remoff_study_date = 0
    ENDIF
    SET growsum += _remoff_study_date
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.917)
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtotal_count = _remtotal_count
   IF (_remtotal_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_count,((size(
        __total_count) - _remtotal_count)+ 1),__total_count)))
    SET drawheight_total_count = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_count = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_count,((size(__total_count) -
       _remtotal_count)+ 1),__total_count)))))
     SET _remtotal_count += rptsd->m_drawlength
    ELSE
     SET _remtotal_count = 0
    ENDIF
    SET growsum += _remtotal_count
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdreminit_serv = _reminit_serv
   IF (_reminit_serv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminit_serv,((size(
        __init_serv) - _reminit_serv)+ 1),__init_serv)))
    SET drawheight_init_serv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminit_serv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminit_serv,((size(__init_serv) -
       _reminit_serv)+ 1),__init_serv)))))
     SET _reminit_serv += rptsd->m_drawlength
    ELSE
     SET _reminit_serv = 0
    ENDIF
    SET growsum += _reminit_serv
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
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
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.344)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = drawheight_enrolling_site
   IF (ncalc=rpt_render
    AND _holdremenrolling_site > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremenrolling_site,((
       size(__enrolling_site) - _holdremenrolling_site)+ 1),__enrolling_site)))
   ELSE
    SET _remenrolling_site = _holdremenrolling_site
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.740)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = drawheight_on_study_date
   IF (ncalc=rpt_render
    AND _holdremon_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremon_study_date,((
       size(__on_study_date) - _holdremon_study_date)+ 1),__on_study_date)))
   ELSE
    SET _remon_study_date = _holdremon_study_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = drawheight_off_treat_date
   IF (ncalc=rpt_render
    AND _holdremoff_treat_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremoff_treat_date,((
       size(__off_treat_date) - _holdremoff_treat_date)+ 1),__off_treat_date)))
   ELSE
    SET _remoff_treat_date = _holdremoff_treat_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.531)
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = drawheight_off_study_date
   IF (ncalc=rpt_render
    AND _holdremoff_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremoff_study_date,((
       size(__off_study_date) - _holdremoff_study_date)+ 1),__off_study_date)))
   ELSE
    SET _remoff_study_date = _holdremoff_study_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.917)
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = drawheight_total_count
   IF (ncalc=rpt_render
    AND _holdremtotal_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_count,((size
       (__total_count) - _holdremtotal_count)+ 1),__total_count)))
   ELSE
    SET _remtotal_count = _holdremtotal_count
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = drawheight_init_serv
   IF (ncalc=rpt_render
    AND _holdreminit_serv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminit_serv,((size(
        __init_serv) - _holdreminit_serv)+ 1),__init_serv)))
   ELSE
    SET _reminit_serv = _holdreminit_serv
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
 SUBROUTINE (footpi_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpi_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpi_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_background_color = f8 WITH noconstant(0.0), private
   DECLARE drawheight_prot_count = f8 WITH noconstant(0.0), private
   DECLARE drawheight_enrl_site_count = f8 WITH noconstant(0.0), private
   DECLARE drawheight_on_study_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_off_treat_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_off_study_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_total_count = f8 WITH noconstant(0.0), private
   DECLARE drawheight_init_serv_count = f8 WITH noconstant(0.0), private
   DECLARE __background_color = vc WITH noconstant(build2(" ",char(0))), protect
   DECLARE __prot_count = vc WITH noconstant(build2(trim(cnvtstring(prot_cnt),3),char(0))), protect
   DECLARE __enrl_site_count = vc WITH noconstant(build2(trim(cnvtstring(site_cnt),3),char(0))),
   protect
   DECLARE __on_study_date = vc WITH noconstant(build2(trim(cnvtstring(on_study_total),3),char(0))),
   protect
   DECLARE __off_treat_date = vc WITH noconstant(build2(trim(cnvtstring(off_tx_total),3),char(0))),
   protect
   DECLARE __off_study_date = vc WITH noconstant(build2(trim(cnvtstring(off_study_total),3),char(0))),
   protect
   DECLARE __total_count = vc WITH noconstant(build2(trim(cnvtstring(enroll_total),3),char(0))),
   protect
   DECLARE __init_serv_count = vc WITH noconstant(build2(trim(cnvtstring(init_svc_cnt),3),char(0))),
   protect
   IF (bcontinue=0)
    SET _rembackground_color = 1
    SET _remprot_count = 1
    SET _remenrl_site_count = 1
    SET _remon_study_date = 1
    SET _remoff_treat_date = 1
    SET _remoff_study_date = 1
    SET _remtotal_count = 1
    SET _reminit_serv_count = 1
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
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrembackground_color = _rembackground_color
   IF (_rembackground_color > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rembackground_color,((
       size(__background_color) - _rembackground_color)+ 1),__background_color)))
    SET drawheight_background_color = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rembackground_color = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rembackground_color,((size(
        __background_color) - _rembackground_color)+ 1),__background_color)))))
     SET _rembackground_color += rptsd->m_drawlength
    ELSE
     SET _rembackground_color = 0
    ENDIF
    SET growsum += _rembackground_color
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(221,221,221))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _holdremprot_count = _remprot_count
   IF (_remprot_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_count,((size(
        __prot_count) - _remprot_count)+ 1),__prot_count)))
    SET drawheight_prot_count = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_count = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_count,((size(__prot_count) -
       _remprot_count)+ 1),__prot_count)))))
     SET _remprot_count += rptsd->m_drawlength
    ELSE
     SET _remprot_count = 0
    ENDIF
    SET growsum += _remprot_count
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremenrl_site_count = _remenrl_site_count
   IF (_remenrl_site_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remenrl_site_count,((size
       (__enrl_site_count) - _remenrl_site_count)+ 1),__enrl_site_count)))
    SET drawheight_enrl_site_count = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remenrl_site_count = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remenrl_site_count,((size(
        __enrl_site_count) - _remenrl_site_count)+ 1),__enrl_site_count)))))
     SET _remenrl_site_count += rptsd->m_drawlength
    ELSE
     SET _remenrl_site_count = 0
    ENDIF
    SET growsum += _remenrl_site_count
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.740)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremon_study_date = _remon_study_date
   IF (_remon_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remon_study_date,((size(
        __on_study_date) - _remon_study_date)+ 1),__on_study_date)))
    SET drawheight_on_study_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remon_study_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remon_study_date,((size(__on_study_date)
        - _remon_study_date)+ 1),__on_study_date)))))
     SET _remon_study_date += rptsd->m_drawlength
    ELSE
     SET _remon_study_date = 0
    ENDIF
    SET growsum += _remon_study_date
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremoff_treat_date = _remoff_treat_date
   IF (_remoff_treat_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remoff_treat_date,((size(
        __off_treat_date) - _remoff_treat_date)+ 1),__off_treat_date)))
    SET drawheight_off_treat_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remoff_treat_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remoff_treat_date,((size(__off_treat_date
        ) - _remoff_treat_date)+ 1),__off_treat_date)))))
     SET _remoff_treat_date += rptsd->m_drawlength
    ELSE
     SET _remoff_treat_date = 0
    ENDIF
    SET growsum += _remoff_treat_date
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.531)
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremoff_study_date = _remoff_study_date
   IF (_remoff_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remoff_study_date,((size(
        __off_study_date) - _remoff_study_date)+ 1),__off_study_date)))
    SET drawheight_off_study_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remoff_study_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remoff_study_date,((size(__off_study_date
        ) - _remoff_study_date)+ 1),__off_study_date)))))
     SET _remoff_study_date += rptsd->m_drawlength
    ELSE
     SET _remoff_study_date = 0
    ENDIF
    SET growsum += _remoff_study_date
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.917)
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtotal_count = _remtotal_count
   IF (_remtotal_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_count,((size(
        __total_count) - _remtotal_count)+ 1),__total_count)))
    SET drawheight_total_count = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_count = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_count,((size(__total_count) -
       _remtotal_count)+ 1),__total_count)))))
     SET _remtotal_count += rptsd->m_drawlength
    ELSE
     SET _remtotal_count = 0
    ENDIF
    SET growsum += _remtotal_count
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdreminit_serv_count = _reminit_serv_count
   IF (_reminit_serv_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminit_serv_count,((size
       (__init_serv_count) - _reminit_serv_count)+ 1),__init_serv_count)))
    SET drawheight_init_serv_count = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminit_serv_count = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminit_serv_count,((size(
        __init_serv_count) - _reminit_serv_count)+ 1),__init_serv_count)))))
     SET _reminit_serv_count += rptsd->m_drawlength
    ELSE
     SET _reminit_serv_count = 0
    ENDIF
    SET growsum += _reminit_serv_count
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 10.500),(offsety
     + 0.032))
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_background_color
   SET _dummyfont = uar_rptsetfont(_hreport,_courier80)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(221,221,221))
   IF (ncalc=rpt_render
    AND _holdrembackground_color > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrembackground_color,(
       (size(__background_color) - _holdrembackground_color)+ 1),__background_color)))
   ELSE
    SET _rembackground_color = _holdrembackground_color
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_prot_count
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremprot_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_count,((size(
        __prot_count) - _holdremprot_count)+ 1),__prot_count)))
   ELSE
    SET _remprot_count = _holdremprot_count
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.375)
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = drawheight_enrl_site_count
   IF (ncalc=rpt_render
    AND _holdremenrl_site_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremenrl_site_count,((
       size(__enrl_site_count) - _holdremenrl_site_count)+ 1),__enrl_site_count)))
   ELSE
    SET _remenrl_site_count = _holdremenrl_site_count
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.740)
   SET rptsd->m_width = 1.260
   SET rptsd->m_height = drawheight_on_study_date
   IF (ncalc=rpt_render
    AND _holdremon_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremon_study_date,((
       size(__on_study_date) - _holdremon_study_date)+ 1),__on_study_date)))
   ELSE
    SET _remon_study_date = _holdremon_study_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_off_treat_date
   IF (ncalc=rpt_render
    AND _holdremoff_treat_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremoff_treat_date,((
       size(__off_treat_date) - _holdremoff_treat_date)+ 1),__off_treat_date)))
   ELSE
    SET _remoff_treat_date = _holdremoff_treat_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.531)
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = drawheight_off_study_date
   IF (ncalc=rpt_render
    AND _holdremoff_study_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremoff_study_date,((
       size(__off_study_date) - _holdremoff_study_date)+ 1),__off_study_date)))
   ELSE
    SET _remoff_study_date = _holdremoff_study_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.917)
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = drawheight_total_count
   IF (ncalc=rpt_render
    AND _holdremtotal_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_count,((size
       (__total_count) - _holdremtotal_count)+ 1),__total_count)))
   ELSE
    SET _remtotal_count = _holdremtotal_count
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.125)
   SET rptsd->m_width = 1.510
   SET rptsd->m_height = drawheight_init_serv_count
   IF (ncalc=rpt_render
    AND _holdreminit_serv_count > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminit_serv_count,((
       size(__init_serv_count) - _holdreminit_serv_count)+ 1),__init_serv_count)))
   ELSE
    SET _reminit_serv_count = _holdreminit_serv_count
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
 SUBROUTINE (footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_page = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rep_exec_time = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_page = vc WITH noconstant(build2(concat(label->rpt_page," ",trim(cnvtstring(
        curpage),3)),char(0))), protect
   DECLARE __label_rep_exec_time = vc WITH noconstant(build2(label->rep_exec_time,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_page = 1
    SET _remlabel_rep_exec_time = 1
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
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
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
     SET _remlabel_rpt_page += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_page = 0
    ENDIF
    SET growsum += _remlabel_rpt_page
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
     SET _remlabel_rep_exec_time += rptsd->m_drawlength
    ELSE
     SET _remlabel_rep_exec_time = 0
    ENDIF
    SET growsum += _remlabel_rep_exec_time
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
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
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
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
 SUBROUTINE (footreportsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_total_prin_inv = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_end_of_rpt = f8 WITH noconstant(0.0), private
   DECLARE __total_prin_inv = vc WITH noconstant(build2(tempstr,char(0))), protect
   DECLARE __label_end_of_rpt = vc WITH noconstant(build2(label->end_of_rpt,char(0))), protect
   IF (bcontinue=0)
    SET _remtotal_prin_inv = 1
    SET _remlabel_end_of_rpt = 1
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
   SET _holdremtotal_prin_inv = _remtotal_prin_inv
   IF (_remtotal_prin_inv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_prin_inv,((size(
        __total_prin_inv) - _remtotal_prin_inv)+ 1),__total_prin_inv)))
    SET drawheight_total_prin_inv = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_prin_inv = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_prin_inv,((size(__total_prin_inv
        ) - _remtotal_prin_inv)+ 1),__total_prin_inv)))))
     SET _remtotal_prin_inv += rptsd->m_drawlength
    ELSE
     SET _remtotal_prin_inv = 0
    ENDIF
    SET growsum += _remtotal_prin_inv
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier10b0)
   SET _holdremlabel_end_of_rpt = _remlabel_end_of_rpt
   IF (_remlabel_end_of_rpt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_end_of_rpt,((
       size(__label_end_of_rpt) - _remlabel_end_of_rpt)+ 1),__label_end_of_rpt)))
    SET drawheight_label_end_of_rpt = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_end_of_rpt = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_end_of_rpt,((size(
        __label_end_of_rpt) - _remlabel_end_of_rpt)+ 1),__label_end_of_rpt)))))
     SET _remlabel_end_of_rpt += rptsd->m_drawlength
    ELSE
     SET _remlabel_end_of_rpt = 0
    ENDIF
    SET growsum += _remlabel_end_of_rpt
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_total_prin_inv
   SET _dummyfont = uar_rptsetfont(_hreport,_courier9b0)
   IF (ncalc=rpt_render
    AND _holdremtotal_prin_inv > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_prin_inv,((
       size(__total_prin_inv) - _holdremtotal_prin_inv)+ 1),__total_prin_inv)))
   ELSE
    SET _remtotal_prin_inv = _holdremtotal_prin_inv
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_end_of_rpt
   SET _dummyfont = uar_rptsetfont(_hreport,_courier10b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_end_of_rpt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_end_of_rpt,(
       (size(__label_end_of_rpt) - _holdremlabel_end_of_rpt)+ 1),__label_end_of_rpt)))
   ELSE
    SET _remlabel_end_of_rpt = _holdremlabel_end_of_rpt
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
    SET rptreport->m_reportname = "CT_SUB_RPT_ENROLL_GRP_PI"
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
   SET rptfont->m_pointsize = 9
   SET _courier9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _courier10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _courier80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_org = vc WITH protect, noconstant("")
 DECLARE tmp_pi = vc WITH protect, noconstant("")
 DECLARE tmp_init_svc = vc WITH protect, noconstant("")
 DECLARE tmp_site = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE pi_cnt = i4 WITH protect, noconstant(0)
 DECLARE enroll_cnt = i4 WITH protect, noconstant(0)
 DECLARE init_svc_cnt = i4 WITH protect, noconstant(0)
 DECLARE msg_cnt = i4 WITH protect, noconstant(0)
 DECLARE site_cnt = i4 WITH protect, noconstant(0)
 DECLARE rec_pos = i4 WITH protect, noconstant(0)
 DECLARE on_study_cnt = i4 WITH protect, noconstant(0)
 DECLARE off_study_cnt = i4 WITH protect, noconstant(0)
 DECLARE off_tx_cnt = i4 WITH protect, noconstant(0)
 DECLARE total_cnt = i4 WITH protect, noconstant(0)
 DECLARE on_study_total = i4 WITH protect, noconstant(0)
 DECLARE off_study_total = i4 WITH protect, noconstant(0)
 DECLARE off_tx_total = i4 WITH protect, noconstant(0)
 DECLARE enroll_total = i4 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE new_line_ind = i2 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE pi_cd = f8 WITH protect, noconstant(0.0)
 DECLARE coord_inst_cd = f8 WITH protect, noconstant(0.0)
 DECLARE therapeutic_cd = f8 WITH protect, noconstant(0.0)
 CALL initializereport(0)
 CALL get_enroll_site(0)
 CALL finalizereport(_sendto)
 SET last_mod = "001"
 SET mod_date = "March 02, 2023"
END GO
