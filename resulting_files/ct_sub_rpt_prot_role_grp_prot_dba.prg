CREATE PROGRAM ct_sub_rpt_prot_role_grp_prot:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Roles" = 0,
  "Person" = 0,
  "Organization" = 0,
  "Role Type" = value(*),
  "Amendment Detail" = 0,
  "Order groups by" = 1,
  "Group By" = 0,
  "Position" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, roles,
  person, organization, roletype,
  amd_detail, orderby, groupby,
  position, out_type, delimiter
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
   1 all_roles_ind = i2
   1 rcnt = i4
   1 roles[*]
     2 role_cd = f8
   1 all_persons_ind = i2
   1 person_cnt = i4
   1 persons[*]
     2 person_id = f8
   1 all_roletypes_ind = i2
   1 roletype_cnt = i4
   1 roletypes[*]
     2 roletype_cd = f8
   1 all_positions_ind = i2
   1 position_cnt = i4
   1 positions[*]
     2 position_cd = f8
   1 amd_detail_ind = i2
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 prot_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 prot_amendment_id = f8
     2 amd_activation_date = dq8
     2 amendment_nbr = i4
     2 revision_nbr_txt = vc
     2 revision_ind = i2
     2 revision_seq = i4
     2 amd_status_cd = f8
     2 amd_status_disp = c40
     2 role_cd = f8
     2 role_disp = c40
     2 role_type_cd = f8
     2 role_type_disp = c40
     2 primary_contact_ind = i2
     2 org_name = c100
     2 person_full_name = c100
     2 position_cd = f8
     2 position_disp = c40
     2 role_activated_date = dq8
     2 role_inactivated_date = dq8
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_order_by_title = vc
   1 rep_exec_time = vc
   1 prot_mnemonic_header = vc
   1 role_header = vc
   1 person_header = vc
   1 position_header = vc
   1 status_header = vc
   1 organization_header = vc
   1 prot_contact_header = vc
   1 total_prot = vc
   1 total_roles = vc
   1 total_roles_for = vc
   1 total_roles_for_colon = vc
   1 end_of_rpt = vc
   1 no_prot_found = vc
   1 unable_to_exec = vc
   1 amendment = vc
   1 init_prot = vc
   1 revision = vc
   1 at_least_one_prot = vc
   1 at_least_one_role = vc
   1 at_least_one_prsn = vc
   1 at_least_one_org = vc
   1 at_least_one_role_type = vc
   1 at_least_one_position = vc
   1 seperator = vc
   1 mark = vc
   1 date_added = vc
   1 date_removed = vc
   1 rpt_page = vc
 )
 RECORD reportlist(
   1 order_by = vc
   1 order_by_prot_mnemonic = vc
   1 order_by_amd_nbr = vc
   1 order_by_rev_seq = vc
   1 order_by_role_disp = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_protocol_role(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection_line(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headprotocols_prot_master_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headprotocols_prot_master_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue
  =i2(ref)) = f8 WITH protect
 DECLARE headprotocols_prot_amendment_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headprotocols_prot_amendment_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,
  bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footprotocols_prot_amendment_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footprotocols_prot_amendment_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,
  bcontinue=i2(ref)) = f8 WITH protect
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
 DECLARE _remlabel_rpt_title = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_order_by_title = i4 WITH noconstant(1), protect
 DECLARE _remlabel_role_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_person_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_position_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_organization_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_prot_contact_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_date_added = i4 WITH noconstant(1), protect
 DECLARE _remlabel_date_removed = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remprotocols_primary_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _bcontheadprotocols_prot_master_idsection = i2 WITH noconstant(0), protect
 DECLARE _remprot_status = i4 WITH noconstant(1), protect
 DECLARE _bcontheadprotocols_prot_amendment_idsection = i2 WITH noconstant(0), protect
 DECLARE _remrole = i4 WITH noconstant(1), protect
 DECLARE _remperson_name = i4 WITH noconstant(1), protect
 DECLARE _remposition = i4 WITH noconstant(1), protect
 DECLARE _remorg = i4 WITH noconstant(1), protect
 DECLARE _remprot_contact = i4 WITH noconstant(1), protect
 DECLARE _remact_date = i4 WITH noconstant(1), protect
 DECLARE _reminact_date = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remtotal_roles = i4 WITH noconstant(1), protect
 DECLARE _bcontfootprotocols_prot_amendment_idsection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rep_exec_time = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_total_prot = i4 WITH noconstant(1), protect
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
 SUBROUTINE get_protocol_role(dummy)
   SELECT
    IF (( $GROUPBY=0))
     protocols_primary_mnemonic = results->protocols[d.seq].primary_mnemonic,
     protocols_prot_master_id = results->protocols[d.seq].prot_master_id, protocols_prot_amendment_id
      = results->protocols[d.seq].prot_amendment_id,
     protocols_person_full_name = results->protocols[d.seq].person_full_name, reportlist_order_by =
     parser(reportlist->order_by), protocols_role_cd = results->protocols[d.seq].role_cd,
     reportlist_order_by_prot_mnemonic = parser(reportlist->order_by_prot_mnemonic),
     reportlist_order_by_amd_nbr = parser(reportlist->order_by_amd_nbr), reportlist_order_by_rev_seq
      = parser(reportlist->order_by_rev_seq)
     FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
     PLAN (d)
     ORDER BY reportlist_order_by_prot_mnemonic, reportlist_order_by_amd_nbr,
      reportlist_order_by_rev_seq,
      reportlist_order_by
     WITH nocounter, separator = " ", format
    ELSE
    ENDIF
    protocols_primary_mnemonic = results->protocols[d.seq].primary_mnemonic, protocols_prot_master_id
     = results->protocols[d.seq].prot_master_id, protocols_prot_amendment_id = results->protocols[d
    .seq].prot_amendment_id,
    protocols_person_full_name = results->protocols[d.seq].person_full_name, reportlist_order_by =
    parser(reportlist->order_by), protocols_role_cd = results->protocols[d.seq].role_cd,
    reportlist_order_by_prot_mnemonic = parser(reportlist->order_by_prot_mnemonic),
    reportlist_order_by_amd_nbr = parser(reportlist->order_by_amd_nbr), reportlist_order_by_rev_seq
     = parser(reportlist->order_by_rev_seq)
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY protocols_prot_master_id, protocols_prot_amendment_id, protocols_person_full_name
    HEAD REPORT
     _d0 = protocols_primary_mnemonic, _fenddetail = (rptreport->m_pagewidth - rptreport->
     m_marginbottom), _bholdcontinue = 0,
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight,((rptreport->m_pagewidth - rptreport
      ->m_marginbottom) - _yoffset),_bholdcontinue))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), dummy_val = headpagesection_line
     (rpt_render)
    HEAD protocols_prot_master_id
     temp_prot = results->protocols[d.seq].primary_mnemonic,
     _bcontheadprotocols_prot_master_idsection = 0, bfirsttime = 1
     WHILE (((_bcontheadprotocols_prot_master_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadprotocols_prot_master_idsection, _fdrawheight =
       headprotocols_prot_master_idsection(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadprotocols_prot_master_idsection=0)
        BREAK
       ENDIF
       dummy_val = headprotocols_prot_master_idsection(rpt_render,(_fenddetail - _yoffset),
        _bcontheadprotocols_prot_master_idsection), bfirsttime = 0
     ENDWHILE
    HEAD protocols_prot_amendment_id
     person_count = 0, stat = person_map("D")
     IF ((results->protocols[d.seq].amendment_nbr=0))
      tempstr = label->init_prot
     ELSE
      tempstr = concat(label->amendment," ",cnvtstring(results->protocols[d.seq].amendment_nbr))
     ENDIF
     IF ((results->protocols[d.seq].revision_ind=1))
      tempstr = concat(tempstr," ",label->seperator," ",label->revision,
       " ",results->protocols[d.seq].revision_nbr_txt)
     ENDIF
     tempstr = concat(tempstr," (",trim(results->protocols[d.seq].amd_status_disp),")"),
     _bcontheadprotocols_prot_amendment_idsection = 0, bfirsttime = 1
     WHILE (((_bcontheadprotocols_prot_amendment_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadprotocols_prot_amendment_idsection, _fdrawheight =
       headprotocols_prot_amendment_idsection(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadprotocols_prot_amendment_idsection=0)
        BREAK
       ENDIF
       dummy_val = headprotocols_prot_amendment_idsection(rpt_render,(_fenddetail - _yoffset),
        _bcontheadprotocols_prot_amendment_idsection), bfirsttime = 0
     ENDWHILE
    HEAD protocols_person_full_name
     IF (( $ORDERBY=2))
      IF ((results->protocols[d.seq].person_full_name != " "))
       stat = person_map("A",results->protocols[d.seq].person_full_name,results->protocols[d.seq].
        person_full_name)
      ENDIF
     ELSEIF ((results->protocols[d.seq].person_full_name != " "))
      person_count = (person_count+ 1)
     ENDIF
    DETAIL
     IF ((results->protocols[d.seq].primary_contact_ind=1))
      tmp_cont = label->mark
     ELSE
      tmp_cont = " "
     ENDIF
     IF ((results->protocols[d.seq].role_inactivated_date <= cnvtdatetime(curdate,curtime3)))
      tmp_inactivated_date = format(results->protocols[d.seq].role_inactivated_date,"@SHORTDATE")
     ELSE
      tmp_inactivated_date = label->seperator
     ENDIF
     tmp_role = results->protocols[d.seq].role_disp, tmp_name = results->protocols[d.seq].
     person_full_name, tmp_position = results->protocols[d.seq].position_disp,
     tmp_org = results->protocols[d.seq].org_name, tmp_activated_date = format(results->protocols[d
      .seq].role_activated_date,"@SHORTDATE"), _bcontdetailsection = 0,
     bfirsttime = 1
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
    FOOT  protocols_person_full_name
     row + 0
    FOOT  protocols_prot_amendment_id
     IF (( $ORDERBY=2))
      tempstr = concat(label->total_roles_for," ",trim(results->protocols[d.seq].primary_mnemonic),
       label->total_roles_for_colon," ",
       cnvtstring(person_map("C")))
     ELSE
      tempstr = concat(label->total_roles_for," ",trim(results->protocols[d.seq].primary_mnemonic),
       label->total_roles_for_colon," ",
       cnvtstring(person_count))
     ENDIF
     _bcontfootprotocols_prot_amendment_idsection = 0, bfirsttime = 1
     WHILE (((_bcontfootprotocols_prot_amendment_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootprotocols_prot_amendment_idsection, _fdrawheight =
       footprotocols_prot_amendment_idsection(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontfootprotocols_prot_amendment_idsection=0)
        BREAK
       ENDIF
       dummy_val = footprotocols_prot_amendment_idsection(rpt_render,(_fenddetail - _yoffset),
        _bcontfootprotocols_prot_amendment_idsection), bfirsttime = 0
     ENDWHILE
    FOOT  protocols_prot_master_id
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
   DECLARE drawheight_label_rpt_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_order_by_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_role_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_person_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_position_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_organization_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_prot_contact_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_date_added = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_date_removed = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_title = vc WITH noconstant(build2(label->rpt_title,char(0))), protect
   DECLARE __label_rpt_order_by_title = vc WITH noconstant(build2(label->rpt_order_by_title,char(0))),
   protect
   DECLARE __label_role_header = vc WITH noconstant(build2(label->role_header,char(0))), protect
   DECLARE __label_person_header = vc WITH noconstant(build2(label->person_header,char(0))), protect
   DECLARE __label_position_header = vc WITH noconstant(build2(label->position_header,char(0))),
   protect
   DECLARE __label_organization_header = vc WITH noconstant(build2(label->organization_header,char(0)
     )), protect
   DECLARE __label_prot_contact_header = vc WITH noconstant(build2(label->prot_contact_header,char(0)
     )), protect
   DECLARE __label_date_added = vc WITH noconstant(build2(label->date_added,char(0))), protect
   DECLARE __label_date_removed = vc WITH noconstant(build2(label->date_removed,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_title = 1
    SET _remlabel_rpt_order_by_title = 1
    SET _remlabel_role_header = 1
    SET _remlabel_person_header = 1
    SET _remlabel_position_header = 1
    SET _remlabel_organization_header = 1
    SET _remlabel_prot_contact_header = 1
    SET _remlabel_date_added = 1
    SET _remlabel_date_removed = 1
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
     SET _remlabel_rpt_order_by_title = (_remlabel_rpt_order_by_title+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_order_by_title = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_order_by_title)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _holdremlabel_role_header = _remlabel_role_header
   IF (_remlabel_role_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_role_header,((
       size(__label_role_header) - _remlabel_role_header)+ 1),__label_role_header)))
    SET drawheight_label_role_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_role_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_role_header,((size(
        __label_role_header) - _remlabel_role_header)+ 1),__label_role_header)))))
     SET _remlabel_role_header = (_remlabel_role_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_role_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_role_header)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_person_header = _remlabel_person_header
   IF (_remlabel_person_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_person_header,((
       size(__label_person_header) - _remlabel_person_header)+ 1),__label_person_header)))
    SET drawheight_label_person_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_person_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_person_header,((size(
        __label_person_header) - _remlabel_person_header)+ 1),__label_person_header)))))
     SET _remlabel_person_header = (_remlabel_person_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_person_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_person_header)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_position_header = _remlabel_position_header
   IF (_remlabel_position_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_position_header,
       ((size(__label_position_header) - _remlabel_position_header)+ 1),__label_position_header)))
    SET drawheight_label_position_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_position_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_position_header,((size(
        __label_position_header) - _remlabel_position_header)+ 1),__label_position_header)))))
     SET _remlabel_position_header = (_remlabel_position_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_position_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_position_header)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_organization_header = _remlabel_organization_header
   IF (_remlabel_organization_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_organization_header,((size(__label_organization_header) -
       _remlabel_organization_header)+ 1),__label_organization_header)))
    SET drawheight_label_organization_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_organization_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_organization_header,((size(
        __label_organization_header) - _remlabel_organization_header)+ 1),__label_organization_header
       )))))
     SET _remlabel_organization_header = (_remlabel_organization_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_organization_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_organization_header)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_prot_contact_header = _remlabel_prot_contact_header
   IF (_remlabel_prot_contact_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_prot_contact_header,((size(__label_prot_contact_header) -
       _remlabel_prot_contact_header)+ 1),__label_prot_contact_header)))
    SET drawheight_label_prot_contact_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_prot_contact_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_prot_contact_header,((size(
        __label_prot_contact_header) - _remlabel_prot_contact_header)+ 1),__label_prot_contact_header
       )))))
     SET _remlabel_prot_contact_header = (_remlabel_prot_contact_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_prot_contact_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_prot_contact_header)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_date_added = _remlabel_date_added
   IF (_remlabel_date_added > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_date_added,((
       size(__label_date_added) - _remlabel_date_added)+ 1),__label_date_added)))
    SET drawheight_label_date_added = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_date_added = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_date_added,((size(
        __label_date_added) - _remlabel_date_added)+ 1),__label_date_added)))))
     SET _remlabel_date_added = (_remlabel_date_added+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_date_added = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_date_added)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_date_removed = _remlabel_date_removed
   IF (_remlabel_date_removed > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_date_removed,((
       size(__label_date_removed) - _remlabel_date_removed)+ 1),__label_date_removed)))
    SET drawheight_label_date_removed = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_date_removed = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_date_removed,((size(
        __label_date_removed) - _remlabel_date_removed)+ 1),__label_date_removed)))))
     SET _remlabel_date_removed = (_remlabel_date_removed+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_date_removed = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_date_removed)
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
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_label_role_header
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_role_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_role_header,
       ((size(__label_role_header) - _holdremlabel_role_header)+ 1),__label_role_header)))
   ELSE
    SET _remlabel_role_header = _holdremlabel_role_header
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_label_person_header
   IF (ncalc=rpt_render
    AND _holdremlabel_person_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_person_header,((size(__label_person_header) - _holdremlabel_person_header)+ 1),
       __label_person_header)))
   ELSE
    SET _remlabel_person_header = _holdremlabel_person_header
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_label_position_header
   IF (ncalc=rpt_render
    AND _holdremlabel_position_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_position_header,((size(__label_position_header) - _holdremlabel_position_header)
       + 1),__label_position_header)))
   ELSE
    SET _remlabel_position_header = _holdremlabel_position_header
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_label_organization_header
   IF (ncalc=rpt_render
    AND _holdremlabel_organization_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_organization_header,((size(__label_organization_header) -
       _holdremlabel_organization_header)+ 1),__label_organization_header)))
   ELSE
    SET _remlabel_organization_header = _holdremlabel_organization_header
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_prot_contact_header
   IF (ncalc=rpt_render
    AND _holdremlabel_prot_contact_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_prot_contact_header,((size(__label_prot_contact_header) -
       _holdremlabel_prot_contact_header)+ 1),__label_prot_contact_header)))
   ELSE
    SET _remlabel_prot_contact_header = _holdremlabel_prot_contact_header
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_date_added
   IF (ncalc=rpt_render
    AND _holdremlabel_date_added > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_date_added,(
       (size(__label_date_added) - _holdremlabel_date_added)+ 1),__label_date_added)))
   ELSE
    SET _remlabel_date_added = _holdremlabel_date_added
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = drawheight_label_date_removed
   IF (ncalc=rpt_render
    AND _holdremlabel_date_removed > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_date_removed,
       ((size(__label_date_removed) - _holdremlabel_date_removed)+ 1),__label_date_removed)))
   ELSE
    SET _remlabel_date_removed = _holdremlabel_date_removed
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 10.500),(offsety
     + 0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headprotocols_prot_master_idsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprotocols_prot_master_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headprotocols_prot_master_idsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_protocols_primary_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE __protocols_primary_mnemonic = vc WITH noconstant(build2(protocols_primary_mnemonic,char(0
      ))), protect
   IF (bcontinue=0)
    SET _remprotocols_primary_mnemonic = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.010
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprotocols_primary_mnemonic = _remprotocols_primary_mnemonic
   IF (_remprotocols_primary_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remprotocols_primary_mnemonic,((size(__protocols_primary_mnemonic) -
       _remprotocols_primary_mnemonic)+ 1),__protocols_primary_mnemonic)))
    SET drawheight_protocols_primary_mnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprotocols_primary_mnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprotocols_primary_mnemonic,((size(
        __protocols_primary_mnemonic) - _remprotocols_primary_mnemonic)+ 1),
       __protocols_primary_mnemonic)))))
     SET _remprotocols_primary_mnemonic = (_remprotocols_primary_mnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remprotocols_primary_mnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remprotocols_primary_mnemonic)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = drawheight_protocols_primary_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprotocols_primary_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremprotocols_primary_mnemonic,((size(__protocols_primary_mnemonic) -
       _holdremprotocols_primary_mnemonic)+ 1),__protocols_primary_mnemonic)))
   ELSE
    SET _remprotocols_primary_mnemonic = _holdremprotocols_primary_mnemonic
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
 SUBROUTINE headprotocols_prot_amendment_idsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprotocols_prot_amendment_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headprotocols_prot_amendment_idsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_prot_status = f8 WITH noconstant(0.0), private
   DECLARE __prot_status = vc WITH noconstant(build2(tempstr,char(0))), protect
   IF (bcontinue=0)
    SET _remprot_status = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_oneandahalf
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.021)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier9b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprot_status = _remprot_status
   IF (_remprot_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_status,((size(
        __prot_status) - _remprot_status)+ 1),__prot_status)))
    SET drawheight_prot_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_status = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_status,((size(__prot_status) -
       _remprot_status)+ 1),__prot_status)))))
     SET _remprot_status = (_remprot_status+ rptsd->m_drawlength)
    ELSE
     SET _remprot_status = 0
    ENDIF
    SET growsum = (growsum+ _remprot_status)
   ENDIF
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(221,221,221))
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.021)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_prot_status
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(221,221,221))
   IF (ncalc=rpt_render
    AND _holdremprot_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_status,((size
       (__prot_status) - _holdremprot_status)+ 1),__prot_status)))
   ELSE
    SET _remprot_status = _holdremprot_status
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
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
   DECLARE sectionheight = f8 WITH noconstant(0.150000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_role = f8 WITH noconstant(0.0), private
   DECLARE drawheight_person_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_position = f8 WITH noconstant(0.0), private
   DECLARE drawheight_org = f8 WITH noconstant(0.0), private
   DECLARE drawheight_prot_contact = f8 WITH noconstant(0.0), private
   DECLARE drawheight_act_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_inact_date = f8 WITH noconstant(0.0), private
   DECLARE __role = vc WITH noconstant(build2(tmp_role,char(0))), protect
   DECLARE __person_name = vc WITH noconstant(build2(tmp_name,char(0))), protect
   DECLARE __position = vc WITH noconstant(build2(tmp_position,char(0))), protect
   DECLARE __org = vc WITH noconstant(build2(tmp_org,char(0))), protect
   DECLARE __prot_contact = vc WITH noconstant(build2(tmp_cont,char(0))), protect
   DECLARE __act_date = vc WITH noconstant(build2(tmp_activated_date,char(0))), protect
   DECLARE __inact_date = vc WITH noconstant(build2(tmp_inactivated_date,char(0))), protect
   IF (bcontinue=0)
    SET _remrole = 1
    SET _remperson_name = 1
    SET _remposition = 1
    SET _remorg = 1
    SET _remprot_contact = 1
    SET _remact_date = 1
    SET _reminact_date = 1
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
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremrole = _remrole
   IF (_remrole > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remrole,((size(__role) -
       _remrole)+ 1),__role)))
    SET drawheight_role = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remrole = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remrole,((size(__role) - _remrole)+ 1),
       __role)))))
     SET _remrole = (_remrole+ rptsd->m_drawlength)
    ELSE
     SET _remrole = 0
    ENDIF
    SET growsum = (growsum+ _remrole)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremperson_name = _remperson_name
   IF (_remperson_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remperson_name,((size(
        __person_name) - _remperson_name)+ 1),__person_name)))
    SET drawheight_person_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remperson_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remperson_name,((size(__person_name) -
       _remperson_name)+ 1),__person_name)))))
     SET _remperson_name = (_remperson_name+ rptsd->m_drawlength)
    ELSE
     SET _remperson_name = 0
    ENDIF
    SET growsum = (growsum+ _remperson_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremposition = _remposition
   IF (_remposition > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remposition,((size(
        __position) - _remposition)+ 1),__position)))
    SET drawheight_position = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remposition = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remposition,((size(__position) -
       _remposition)+ 1),__position)))))
     SET _remposition = (_remposition+ rptsd->m_drawlength)
    ELSE
     SET _remposition = 0
    ENDIF
    SET growsum = (growsum+ _remposition)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremorg = _remorg
   IF (_remorg > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorg,((size(__org) -
       _remorg)+ 1),__org)))
    SET drawheight_org = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorg = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorg,((size(__org) - _remorg)+ 1),__org
       )))))
     SET _remorg = (_remorg+ rptsd->m_drawlength)
    ELSE
     SET _remorg = 0
    ENDIF
    SET growsum = (growsum+ _remorg)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprot_contact = _remprot_contact
   IF (_remprot_contact > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_contact,((size(
        __prot_contact) - _remprot_contact)+ 1),__prot_contact)))
    SET drawheight_prot_contact = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_contact = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_contact,((size(__prot_contact) -
       _remprot_contact)+ 1),__prot_contact)))))
     SET _remprot_contact = (_remprot_contact+ rptsd->m_drawlength)
    ELSE
     SET _remprot_contact = 0
    ENDIF
    SET growsum = (growsum+ _remprot_contact)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremact_date = _remact_date
   IF (_remact_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remact_date,((size(
        __act_date) - _remact_date)+ 1),__act_date)))
    SET drawheight_act_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remact_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remact_date,((size(__act_date) -
       _remact_date)+ 1),__act_date)))))
     SET _remact_date = (_remact_date+ rptsd->m_drawlength)
    ELSE
     SET _remact_date = 0
    ENDIF
    SET growsum = (growsum+ _remact_date)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.010
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdreminact_date = _reminact_date
   IF (_reminact_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminact_date,((size(
        __inact_date) - _reminact_date)+ 1),__inact_date)))
    SET drawheight_inact_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminact_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminact_date,((size(__inact_date) -
       _reminact_date)+ 1),__inact_date)))))
     SET _reminact_date = (_reminact_date+ rptsd->m_drawlength)
    ELSE
     SET _reminact_date = 0
    ENDIF
    SET growsum = (growsum+ _reminact_date)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_role
   IF (ncalc=rpt_render
    AND _holdremrole > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremrole,((size(__role
        ) - _holdremrole)+ 1),__role)))
   ELSE
    SET _remrole = _holdremrole
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_person_name
   IF (ncalc=rpt_render
    AND _holdremperson_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremperson_name,((size
       (__person_name) - _holdremperson_name)+ 1),__person_name)))
   ELSE
    SET _remperson_name = _holdremperson_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_position
   IF (ncalc=rpt_render
    AND _holdremposition > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremposition,((size(
        __position) - _holdremposition)+ 1),__position)))
   ELSE
    SET _remposition = _holdremposition
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_org
   IF (ncalc=rpt_render
    AND _holdremorg > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorg,((size(__org)
        - _holdremorg)+ 1),__org)))
   ELSE
    SET _remorg = _holdremorg
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_prot_contact
   IF (ncalc=rpt_render
    AND _holdremprot_contact > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_contact,((
       size(__prot_contact) - _holdremprot_contact)+ 1),__prot_contact)))
   ELSE
    SET _remprot_contact = _holdremprot_contact
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_act_date
   IF (ncalc=rpt_render
    AND _holdremact_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremact_date,((size(
        __act_date) - _holdremact_date)+ 1),__act_date)))
   ELSE
    SET _remact_date = _holdremact_date
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.010
   SET rptsd->m_height = drawheight_inact_date
   IF (ncalc=rpt_render
    AND _holdreminact_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminact_date,((size(
        __inact_date) - _holdreminact_date)+ 1),__inact_date)))
   ELSE
    SET _reminact_date = _holdreminact_date
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
 SUBROUTINE footprotocols_prot_amendment_idsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footprotocols_prot_amendment_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footprotocols_prot_amendment_idsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_total_roles = f8 WITH noconstant(0.0), private
   DECLARE __total_roles = vc WITH noconstant(build2(tempstr,char(0))), protect
   IF (bcontinue=0)
    SET _remtotal_roles = 1
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
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtotal_roles = _remtotal_roles
   IF (_remtotal_roles > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_roles,((size(
        __total_roles) - _remtotal_roles)+ 1),__total_roles)))
    SET drawheight_total_roles = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_roles = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_roles,((size(__total_roles) -
       _remtotal_roles)+ 1),__total_roles)))))
     SET _remtotal_roles = (_remtotal_roles+ rptsd->m_drawlength)
    ELSE
     SET _remtotal_roles = 0
    ENDIF
    SET growsum = (growsum+ _remtotal_roles)
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 10.500),(offsety
     + 0.032))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_total_roles
   IF (ncalc=rpt_render
    AND _holdremtotal_roles > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_roles,((size
       (__total_roles) - _holdremtotal_roles)+ 1),__total_roles)))
   ELSE
    SET _remtotal_roles = _holdremtotal_roles
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
   DECLARE sectionheight = f8 WITH noconstant(0.560000), private
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
    SET rptsd->m_y = (offsety+ 0.375)
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
     SET _remlabel_rpt_page = (_remlabel_rpt_page+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rpt_page = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rpt_page)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
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
     SET _remlabel_rep_exec_time = (_remlabel_rep_exec_time+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_rep_exec_time = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_rep_exec_time)
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_total_prot = f8 WITH noconstant(0.0), private
   DECLARE __label_total_prot = vc WITH noconstant(build2(concat(label->total_prot," ",trim(
       cnvtstring(results->prot_cnt,3))),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_total_prot = 1
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
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
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
    SET rptreport->m_reportname = "CT_SUB_RPT_PROT_ROLE_GRP_PROT"
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
   SET rptfont->m_pointsize = 10
   SET _courier10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _courier9b0 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE tmp_prot = vc WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE tmp_amd_desc = vc WITH protect
 DECLARE tmp_role = vc WITH protect
 DECLARE orderby_role = vc WITH protect
 DECLARE orderby_prot = vc WITH protect
 DECLARE person_name = vc WITH protect
 DECLARE tmp_amd = vc WITH protect
 DECLARE tmp_amd_status = vc WITH protect
 DECLARE tmp_name = vc WITH protect
 DECLARE tmp_position = vc WITH protect
 DECLARE tmp_org = vc WITH protect
 DECLARE tmp_inactivated_date = vc WITH protect
 DECLARE tmp_activated_date = vc WITH protect
 DECLARE tmp_cont = vc WITH protect
 DECLARE num = i2 WITH protect
 DECLARE skip_amd = i2 WITH protect
 DECLARE parmidx = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE prot_cnt = i4 WITH protect
 DECLARE acnt = i4 WITH protect
 DECLARE rcnt = i4 WITH protect
 DECLARE msg_cnt = i4 WITH protect
 DECLARE prot_id = f8 WITH noconstant(0,0), protect
 DECLARE amd_id = f8 WITH noconstant(0,0), protect
 DECLARE role_cd = f8 WITH noconstant(0,0), protect
 DECLARE person_count = f8 WITH noconstant(0,0), protect
 DECLARE person_map(mode=vc,mapkey=vc,mapval=vc) = i4 WITH map = "HASH"
 CALL initializereport(0)
 CALL get_protocol_role(0)
 CALL finalizereport(_sendto)
 SET last_mod = "000"
 SET mod_date = "April 05, 2016"
END GO
