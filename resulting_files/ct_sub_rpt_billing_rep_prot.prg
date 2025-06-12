CREATE PROGRAM ct_sub_rpt_billing_rep_prot
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Execution Mode" = 0,
  "Initiating Service" = 0,
  "Protocols" = 0,
  "Research Account" = 0,
  "Output Mode" = 0
  WITH outdev, execmode, initservice,
  protocol, resacc, outmode
 EXECUTE reportrtl
 DECLARE encounter_type_display = vc WITH protect
 DECLARE empty_str_value = vc WITH constant("- -"), public
 RECORD label(
   1 rpt_title = vc
   1 rpt_exec_mode = vc
   1 prot_mnemonic_header = vc
   1 prot_status = vc
   1 principal_investigator = vc
   1 res_acc = vc
   1 prot_alias = vc
   1 prot_sponsor = vc
   1 enroll_id = vc
   1 encntr_type = vc
   1 order_name = vc
   1 order_type = vc
   1 order_id = vc
   1 action_date = vc
   1 powerplan_name = vc
   1 rpt_page = vc
   1 patient_name = vc
   1 mrn_no = vc
   1 date_of_birth = vc
   1 standard_of_care_label = vc
   1 order_status = vc
   1 order_placed_date = vc
   1 protocol_order_id = vc
   1 not_applicable = vc
 )
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_researchacc_ind = i2
   1 researchacc_cnt = i4
   1 research_accounts[*]
     2 research_acc_name = vc
 )
 DECLARE processed_order_status = vc WITH protect
 DECLARE protocol_order_id_text = vc WITH protect
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE layout_query(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 IF (validate(_bsubreport) != 1)
  DECLARE _bsubreport = i1 WITH noconstant(0), protect
 ENDIF
 IF (_bsubreport=0)
  DECLARE _hreport = h WITH noconstant(0), protect
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
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _times1016711680 = i4 WITH noconstant(0), protect
 DECLARE _times10b16711680 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE layout_query(dummy)
   SELECT DISTINCT
    pm.primary_mnemonic, uar_get_code_display(pm.prot_status_cd), odd.oe_field_display_value,
    odd.oe_field_meaning, ppr.prot_accession_nbr, uar_get_code_display(e.encntr_type_cd),
    o.order_mnemonic, uar_get_code_display(o.catalog_type_cd), o.order_id,
    o.protocol_order_id, o.orig_ord_as_flag, pw.description,
    p.name_full_formatted, p.birth_dt_tm, pa.alias,
    org.org_name, o.orig_order_dt_tm, oa.action_dt_tm,
    oa_order_status_disp = uar_get_code_display(o.order_status_cd), ps.name_full_formatted,
    uar_get_code_display(pr.prot_role_cd),
    paa.alias_id, o.ordered_as_mnemonic
    FROM pw_pt_reltn rel,
     prot_master pm,
     pathway_catalog pw,
     orders o,
     encounter e,
     pt_prot_reg ppr,
     order_detail odd,
     person p,
     person_alias pa,
     organization org,
     order_action oa,
     prot_role pr,
     prot_amendment ppa,
     prsnl ps,
     prot_alias paa
    WHERE (((qual_list->all_protocols_ind=1)) OR (expand(num,1,qual_list->protocol_cnt,rel
     .prot_master_id,qual_list->protocols[num].prot_master_id)))
     AND rel.active_ind=1
     AND rel.pathway_catalog_id > 0
     AND rel.prot_master_id=pm.prot_master_id
     AND (pm.logical_domain_id=domain_reply->logical_domain_id)
     AND rel.pathway_catalog_id=pw.pathway_catalog_id
     AND pw.pathway_catalog_id=o.pathway_catalog_id
     AND (odd.order_id= Outerjoin(o.order_id))
     AND ppr.prot_master_id=rel.prot_master_id
     AND ppr.person_id=o.person_id
     AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND p.person_id=ppr.person_id
     AND e.encntr_id=o.encntr_id
     AND o.template_order_id=0
     AND o.order_id=oa.order_id
     AND oa.inactive_flag=0
     AND o.order_status_cd IN (ord_cd, comp_cd, susp_cd, discon_cd)
     AND (pa.person_id= Outerjoin(p.person_id))
     AND pa.person_alias_type_cd=mrn_cd
     AND (pa.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (pa.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate)))
     AND org.organization_id=pm.research_sponsor_org_id
     AND pa.person_id=ppr.person_id
     AND ppa.prot_master_id=pm.prot_master_id
     AND pr.prot_amendment_id=ppa.prot_amendment_id
     AND pr.prot_role_cd=pi_cd
     AND pr.person_id=ps.person_id
     AND (paa.prot_master_id= Outerjoin(pm.prot_master_id))
    ORDER BY pm.primary_mnemonic, pw.description, o.person_id,
     o.order_mnemonic, o.encntr_id, o.protocol_order_id,
     o.order_id
    HEAD REPORT
     _d0 = pm.primary_mnemonic, _d1 = ppr.prot_accession_nbr, _d2 = o.order_id,
     _d3 = pw.description, _d4 = p.name_full_formatted, _d5 = p.birth_dt_tm,
     _d6 = pa.alias, _d7 = o.orig_order_dt_tm, _d8 = oa.action_dt_tm,
     _d9 = ps.name_full_formatted, _d10 = o.ordered_as_mnemonic, _fenddetail = (rptreport->
     m_pageheight - rptreport->m_marginbottom),
     _bholdcontinue = 0, _fenddetail -= footpagesection(rpt_calcheight,((rptreport->m_pageheight -
      rptreport->m_marginbottom) - _yoffset),_bholdcontinue), _fdrawheight = headreportsection(
      rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    HEAD pm.primary_mnemonic
     IF (paa.alias_id > 0)
      prot_alias_id = cnvtstring(paa.alias_id)
     ELSE
      prot_alias_id = "- -"
     ENDIF
     IF (org.org_name=" ")
      sponsor_org = "- -"
     ELSE
      sponsor_org = cnvtstring(org.org_name)
     ENDIF
     _fdrawheight = headpm_primary_mnemonicsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headpm_primary_mnemonicsection(rpt_render)
    HEAD pw.description
     row + 0
    HEAD o.person_id
     _fdrawheight = heado_person_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = heado_person_idsection(rpt_render)
    HEAD o.order_mnemonic
     _fdrawheight = heado_order_mnemonicsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = heado_order_mnemonicsection(rpt_render)
    HEAD o.encntr_id
     row + 0
    HEAD o.protocol_order_id
     IF (o.protocol_order_id > 0)
      data = 1, protocol_order_id_text = cnvtstring(o.protocol_order_id)
     ELSE
      data = 1, protocol_order_id_text = label->not_applicable
     ENDIF
     _fdrawheight = heado_protocol_order_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = heado_protocol_order_idsection(rpt_render)
    HEAD o.order_id
     res_ind = 0, _fdrawheight = heado_order_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = heado_order_idsection(rpt_render)
    DETAIL
     IF (odd.oe_field_meaning="RSRCHACCT")
      order_detail_field = odd.oe_field_display_value, res_ind = 1
     ENDIF
     IF (o.orig_ord_as_flag=1
      AND o.order_status_cd=ord_cd)
      processed_order_status = prescribed_str
     ELSE
      processed_order_status = oa_order_status_disp
     ENDIF
    FOOT  o.order_id
     IF (res_ind=0)
      order_detail_field = label->standard_of_care_label
     ENDIF
     encounter_type_display = uar_get_code_display(e.encntr_type_cd)
     IF (trim(encounter_type_display)="")
      encounter_type_display = empty_str_value
     ENDIF
     _fdrawheight = footo_order_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = footo_order_idsection(rpt_render)
    FOOT  o.protocol_order_id
     row + 0
    FOOT  o.encntr_id
     row + 0
    FOOT  o.order_mnemonic
     row + 0
    FOOT  o.person_id
     _fdrawheight = footo_person_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = footo_person_idsection(rpt_render)
    FOOT  pw.description
     row + 0
    FOOT  pm.primary_mnemonic
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
     dummy_val = footpagesection(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
      _yoffset),_bcontfootpagesection), _yoffset = _yhold
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
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.670000), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(label->rpt_title,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(label->rpt_exec_mode,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.365
    SET _oldfont = uar_rptsetfont(_hreport,_times16b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 8.501
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpm_primary_mnemonicsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpm_primary_mnemonicsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpm_primary_mnemonicsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.170000), private
   DECLARE __fieldname1 = vc WITH noconstant(build2(label->prot_mnemonic_header,char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(label->prot_status,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(label->principal_investigator,char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(label->prot_alias,char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(label->prot_sponsor,char(0))), protect
   DECLARE __fieldname8 = vc WITH noconstant(build2(uar_get_code_display(pm.prot_status_cd),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 0.094),(offsetx+ 8.501),(offsety+
     0.094))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.636
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.636
    SET rptsd->m_height = 0.365
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.521
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.521
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pm.primary_mnemonic,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname8)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ps.name_full_formatted,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.098),(offsetx+ 8.501),(offsety+
     1.098))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.365
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sponsor_org,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.230
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prot_alias_id,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpw_descriptionsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpw_descriptionsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpw_descriptionsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.389000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (heado_person_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = heado_person_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (heado_person_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.560000), private
   DECLARE __fieldname1 = vc WITH noconstant(build2(label->patient_name,char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(label->date_of_birth,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(label->mrn_no,char(0))), protect
   DECLARE __fieldname18 = vc WITH noconstant(build2(label->enroll_id,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.303
    SET _oldfont = uar_rptsetfont(_hreport,_times10b16711680)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.303
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.303
    SET _dummyfont = uar_rptsetfont(_hreport,_times1016711680)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.birth_dt_tm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pa.alias,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.303
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.name_full_formatted,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ppr.prot_accession_nbr,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.271
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b16711680)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname18)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (heado_order_mnemonicsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = heado_order_mnemonicsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (heado_order_mnemonicsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __fieldname20 = vc WITH noconstant(build2(label->order_name,char(0))), protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(label->action_date,char(0))), protect
   DECLARE __fieldname23 = vc WITH noconstant(build2(label->powerplan_name,char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(uar_get_code_display(o.catalog_type_cd),char(0))),
   protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(label->res_acc,char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(label->order_id,char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2(label->order_placed_date,char(0))), protect
   DECLARE __fieldname8 = vc WITH noconstant(build2(label->order_status,char(0))), protect
   DECLARE __encntr_type_label = vc WITH noconstant(build2(label->encntr_type,char(0))), protect
   DECLARE __fieldname21 = vc WITH noconstant(build2(label->order_type,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname20)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.553)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.396
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname23)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(o.ordered_as_mnemonic,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pw.description,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.553)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.396
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.553)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.396
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.553)
    SET rptsd->m_x = (offsetx+ 1.626)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.396
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.553)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.396
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname8)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__encntr_type_label)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname21)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (heado_order_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = heado_order_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (heado_order_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.042000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.000000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (heado_protocol_order_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = heado_protocol_order_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (heado_protocol_order_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __protocol_order_id = vc WITH noconstant(build2(label->protocol_order_id,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.751
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__protocol_order_id)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(protocol_order_id_text,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footo_order_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footo_order_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footo_order_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.700000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.688
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(order_detail_field,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.688
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(o.order_id,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.688
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(oa.action_dt_tm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.688
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(o.orig_order_dt_tm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.688
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(processed_order_status,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.688
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(encounter_type_display,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footo_order_mnemonicsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footo_order_mnemonicsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footo_order_mnemonicsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.014000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footo_person_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footo_person_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footo_person_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 8.480),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
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
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_page = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_page = vc WITH noconstant(build2(uar_i18nbuildmessage(i18nhandle,
      "PAGE_PRESCREEN_RPT","Page: %1","i",curpage),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_page = 1
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
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 9.001
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
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 9.001
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
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "CT_SUB_RPT_BILLING_REP_PROT"
    SET rptreport->m_pagewidth = 9.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
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
   ENDIF
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
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_rgbcolor = rpt_blue
   SET _times10b16711680 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times1016711680 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 7
   SET rptfont->m_rgbcolor = rpt_black
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i4 WITH public, noconstant(0)
 DECLARE patient_cnt = i4 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE res_ind = i2 WITH public, noconstant(0)
 DECLARE pi_cd = f8 WITH public, noconstant(0.0)
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE ord_cd = f8 WITH public, noconstant(0.0)
 DECLARE comp_cd = f8 WITH public, noconstant(0.0)
 DECLARE susp_cd = f8 WITH public, noconstant(0.0)
 DECLARE discon_cd = f8 WITH public, noconstant(0.0)
 DECLARE prescribed_str = vc WITH public
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET ord_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET comp_cd = uar_get_code_by("MEANING",6004,"COMPLETED")
 SET susp_cd = uar_get_code_by("MEANING",6004,"SUSPENDED")
 SET discon_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
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
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"BILLING_RPORT","Billing Report")
 IF (( $EXECMODE=0))
  SET label->rpt_exec_mode = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Filtered by Protocol")
 ELSE
  SET label->rpt_exec_mode = uar_i18ngetmessage(i18nhandle,"FILT_RES_ACC",
   "Filtered by Research Account")
 ENDIF
 SET label->patient_name = uar_i18ngetmessage(i18nhandle,"PAT_NAME","Patient Name:")
 SET label->mrn_no = uar_i18ngetmessage(i18nhandle,"MRN_NO","MRN:")
 SET label->date_of_birth = uar_i18ngetmessage(i18nhandle,"DOB_DT","Date of Birth:")
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEM","Protocol Mnemonic:")
 SET label->prot_status = uar_i18ngetmessage(i18nhandle,"PROT_STAT","Protocol Status:")
 SET label->principal_investigator = uar_i18ngetmessage(i18nhandle,"PRIN_INV",
  "Principal Investigator:")
 SET label->prot_alias = uar_i18ngetmessage(i18nhandle,"PROT_ALIAS","Protocol Alias:")
 SET label->prot_sponsor = uar_i18ngetmessage(i18nhandle,"SPONS","Sponsor:")
 SET label->res_acc = uar_i18ngetmessage(i18nhandle,"RES_ACC","Billing Type")
 SET label->enroll_id = uar_i18ngetmessage(i18nhandle,"ENROLLMENT_ID","Enrollment ID:")
 SET label->encntr_type = uar_i18ngetmessage(i18nhandle,"ENCOUNTER_TYPE","Encounter Type")
 SET label->order_name = uar_i18ngetmessage(i18nhandle,"ORD_NAME","Order Name")
 SET label->order_type = uar_i18ngetmessage(i18nhandle,"ORD_TYPE","Order Type")
 SET label->order_id = uar_i18ngetmessage(i18nhandle,"ORD_ID","Order ID")
 SET label->action_date = uar_i18ngetmessage(i18nhandle,"ACTION_DATE","Action Date")
 SET label->powerplan_name = uar_i18ngetmessage(i18nhandle,"PP_NAME","PowerPlan Name")
 SET label->order_placed_date = uar_i18ngetmessage(i18nhandle,"OD_PLACED_DATE","Order Placed Date")
 SET label->order_status = uar_i18ngetmessage(i18nhandle,"OD_STAT","Order Status")
 SET label->standard_of_care_label = uar_i18ngetmessage(i18nhandle,"SOC_Lab","Standard of Care")
 SET label->protocol_order_id = uar_i18ngetmessage(i18nhandle,"PROT_OD_ID","Protocol Order ID:")
 SET label->not_applicable = uar_i18ngetmessage(i18nhandle,"NOT_APPLICABLE","Not Applicable")
 SET prescribed_str = uar_i18ngetmessage(i18nhandle,"PRESCRIBED","Prescribed")
 CALL initializereport(0)
 CALL layout_query(0)
 CALL finalizereport(_sendto)
 CALL echo(build("curqual",curqual,"curqual"))
 IF (curqual < 1)
  SET data = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Jul 21, 2019"
 SET last_mod = "001"
 SET mod_date = "Nov 25, 2019"
END GO
