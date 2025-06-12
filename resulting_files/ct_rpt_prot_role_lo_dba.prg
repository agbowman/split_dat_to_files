CREATE PROGRAM ct_rpt_prot_role_lo:dba
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
 EXECUTE ct_rpt_prot_role:dba "NL:",  $PROTOCOLS,  $ROLES,
  $PERSON,  $ORGANIZATION,  $ROLETYPE,
  $AMD_DETAIL,  $ORDERBY,  $GROUPBY,
  $POSITION,  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant(0), protect
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
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_PROT_ROLE_LO"
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
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE assignenddate(verifydate=dq8,enddate=dq8) = vc
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE person_map(mode=vc,mapkey=vc,mapval=vc) = i4 WITH map = "HASH"
 DECLARE tmp_role_activated = vc WITH noconstant("")
 DECLARE tmp_role_inactivated = vc WITH noconstant("")
 IF (((size(results->protocols,5)=0) OR (size(results->messages,5) > 0)) )
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, label->rpt_title, row + 1,
    col 0, label->rpt_order_by_title, row + 1,
    col 0, label->rep_exec_time
    IF (size(results->messages,5) > 0)
     row + 2, col 0, label->unable_to_exec
     FOR (idx = 1 TO size(results->messages,5))
       tempstr = results->messages[idx].text, row + 1, col 0,
       tempstr
     ENDFOR
    ELSE
     row + 2, col 0, label->no_prot_found
    ENDIF
   WITH format = crstream, formfeed = none, maxcol = 1500,
    nocounter
  ;end select
 ELSEIF (( $OUT_TYPE=1))
  IF (( $GROUPBY=0))
   SELECT INTO  $OUTDEV
    tmp_prot = substring(1,32,results->protocols[d.seq].primary_mnemonic), prot_id = results->
    protocols[d.seq].prot_master_id, amd_id = results->protocols[d.seq].prot_amendment_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    ORDER BY substring(1,25,results->protocols[d.seq].primary_mnemonic), results->protocols[d.seq].
     amendment_nbr, results->protocols[d.seq].revision_seq,
     parser(reportlist->order_by)
    HEAD REPORT
     col 0, label->rpt_title, row + 1,
     col 0, label->rpt_order_by_title, row + 1,
     col 0, label->rep_exec_time, tempstr = concat(label->prot_mnemonic_header, $DELIMITER,label->
      amendment, $DELIMITER,label->status_header,
       $DELIMITER,label->role_header, $DELIMITER,label->person_header, $DELIMITER,
      label->position_header, $DELIMITER,label->organization_header, $DELIMITER,label->
      prot_contact_header,
       $DELIMITER,label->date_added, $DELIMITER,label->date_removed),
     row + 1, col 0, tempstr,
     row + 1
    HEAD prot_id
     tmp_prot = results->protocols[d.seq].primary_mnemonic, tmp_prot = concat('"',trim(tmp_prot,3),
      '"')
    HEAD amd_id
     IF ((results->protocols[d.seq].amendment_nbr=0))
      tempstr = label->init_prot
     ELSE
      tempstr = concat(label->amendment," ",cnvtstring(results->protocols[d.seq].amendment_nbr))
     ENDIF
     IF ((results->protocols[d.seq].revision_ind=1))
      tempstr = concat(tempstr," ",label->seperator," ",label->revision,
       " ",results->protocols[d.seq].revision_nbr_txt)
     ENDIF
     tmp_amd = tempstr, tmp_amd = concat('"',trim(tmp_amd,3),'"'), tmp_amd_status = results->
     protocols[d.seq].amd_status_disp,
     tmp_amd_status = concat('"',trim(tmp_amd_status,3),'"')
    DETAIL
     IF ((results->protocols[d.seq].primary_contact_ind=1))
      tmp_cont = label->mark
     ELSE
      tmp_cont = ""
     ENDIF
     tmp_role = results->protocols[d.seq].role_disp, tmp_name = results->protocols[d.seq].
     person_full_name, tmp_role_activated = format(results->protocols[d.seq].role_activated_date,
      "@SHORTDATE"),
     tmp_role_inactivated = assignenddate(results->protocols[d.seq].role_inactivated_date,
      cnvtdatetime(curdate,curtime3)), tmp_position = results->protocols[d.seq].position_disp,
     tmp_org = results->protocols[d.seq].org_name,
     tmp_role = concat('"',trim(tmp_role,3),'"'), tmp_name = concat('"',trim(tmp_name,3),'"'),
     tmp_role_activated = concat('"',trim(tmp_role_activated,3),'"'),
     tmp_role_inactivated = concat('"',trim(tmp_role_inactivated,3),'"'), tmp_position = concat('"',
      trim(tmp_position,3),'"'), tmp_org = concat('"',trim(tmp_org,3),'"'),
     tmp_cont = concat('"',trim(tmp_cont,3),'"'), tempstr = concat(tmp_prot, $DELIMITER,tmp_amd,
       $DELIMITER,tmp_amd_status,
       $DELIMITER,tmp_role, $DELIMITER,tmp_name, $DELIMITER,
      tmp_position, $DELIMITER,tmp_org, $DELIMITER,tmp_cont,
       $DELIMITER,tmp_role_activated, $DELIMITER,tmp_role_inactivated), col 0,
     tempstr, row + 1
    FOOT REPORT
     row + 1, tempstr = concat(label->total_prot," ",trim(cnvtstring(results->prot_cnt,3))), col 0,
     tempstr, row + 2, col 0,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    role_cd = results->protocols[d.seq].role_cd, tmp_prot = results->protocols[d.seq].
    primary_mnemonic, prot_id = results->protocols[d.seq].prot_master_id,
    amd_id = results->protocols[d.seq].prot_amendment_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    ORDER BY substring(1,35,cnvtlower(results->protocols[d.seq].role_disp)), parser(reportlist->
      order_by), substring(1,25,cnvtlower(results->protocols[d.seq].primary_mnemonic)),
     results->protocols[d.seq].amendment_nbr, results->protocols[d.seq].revision_seq
    HEAD REPORT
     rcnt = 0, col 0, label->rpt_title,
     row + 1, col 0, label->rpt_order_by_title,
     row + 1, col 0, label->rep_exec_time,
     tempstr = concat(label->role_header, $DELIMITER,label->person_header, $DELIMITER,label->
      position_header,
       $DELIMITER,label->prot_mnemonic_header, $DELIMITER,label->amendment, $DELIMITER,
      label->status_header, $DELIMITER,label->organization_header, $DELIMITER,label->
      prot_contact_header,
       $DELIMITER,label->date_added, $DELIMITER,label->date_removed), row + 1, col 0,
     tempstr
    HEAD role_cd
     tmp_role = results->protocols[d.seq].role_disp, tmp_role = concat('"',trim(tmp_role,3),'"')
    DETAIL
     IF ((results->protocols[d.seq].role_inactivated_date > cnvtdatetime(curdate,curtime3)))
      rcnt = (rcnt+ 1)
     ENDIF
     IF ((results->protocols[d.seq].primary_contact_ind=1))
      tmp_cont = label->mark
     ELSE
      tmp_cont = ""
     ENDIF
     IF ((results->protocols[d.seq].amendment_nbr=0))
      tmp_amd = label->init_prot
     ELSE
      tmp_amd = concat(label->amendment," ",cnvtstring(results->protocols[d.seq].amendment_nbr))
     ENDIF
     IF ((results->protocols[d.seq].revision_ind=1))
      tmp_amd = concat(tmp_amd," ",label->seperator," ",label->revision,
       " ",trim(results->protocols[d.seq].revision_nbr_txt))
     ENDIF
     tmp_name = results->protocols[d.seq].person_full_name, tmp_role_activated = format(results->
      protocols[d.seq].role_activated_date,"@SHORTDATE"), tmp_role_inactivated = assignenddate(
      results->protocols[d.seq].role_inactivated_date,cnvtdatetime(curdate,curtime3)),
     tmp_position = results->protocols[d.seq].position_disp, tmp_prot = results->protocols[d.seq].
     primary_mnemonic, tmp_amd_status = results->protocols[d.seq].amd_status_disp,
     tmp_org = results->protocols[d.seq].org_name, tmp_name = concat('"',trim(tmp_name,3),'"'),
     tmp_position = concat('"',trim(tmp_position,3),'"'),
     tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_amd = concat('"',trim(tmp_amd,3),'"'),
     tmp_amd_status = concat('"',trim(tmp_amd_status,3),'"'),
     tmp_org = concat('"',trim(tmp_org,3),'"'), tmp_cont = concat('"',trim(tmp_cont,3),'"'),
     tmp_role_activated = concat('"',trim(tmp_role_activated,3),'"'),
     tmp_role_inactivated = concat('"',trim(tmp_role_inactivated,3),'"'), tempstr = concat(tmp_role,
       $DELIMITER,tmp_name, $DELIMITER,tmp_position,
       $DELIMITER,tmp_prot, $DELIMITER,tmp_amd, $DELIMITER,
      tmp_amd_status, $DELIMITER,tmp_org, $DELIMITER,tmp_cont,
       $DELIMITER,tmp_role_activated, $DELIMITER,tmp_role_inactivated), row + 1,
     col 0, tempstr
    FOOT REPORT
     row + 2, tempstr = concat(label->total_roles," ",trim(cnvtstring(rcnt,3))), col 0,
     tempstr, row + 2, col 0,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ENDIF
 ELSE
  CALL initializereport(0)
  SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom)
  IF (( $GROUPBY=0))
   SET _bsubreport = 1
   EXECUTE ct_sub_rpt_prot_role_grp_prot:dba  $OUTDEV,  $PROTOCOLS,  $ROLES,
    $PERSON,  $ORGANIZATION,  $ROLETYPE,
    $AMD_DETAIL,  $ORDERBY,  $GROUPBY,
    $POSITION,  $OUT_TYPE,  $DELIMITER
   SET _bsubreport = 0
  ENDIF
  IF (( $GROUPBY=1))
   SET _bsubreport = 1
   EXECUTE ct_sub_rpt_prot_role_grp_role:dba  $OUTDEV,  $PROTOCOLS,  $ROLES,
    $PERSON,  $ORGANIZATION,  $ROLETYPE,
    $AMD_DETAIL,  $ORDERBY,  $GROUPBY,
    $POSITION,  $OUT_TYPE,  $DELIMITER
   SET _bsubreport = 0
  ENDIF
  CALL finalizereport(_sendto)
 ENDIF
 SUBROUTINE assignenddate(verifydate,enddate)
   IF (verifydate <= enddate)
    RETURN(format(verifydate,"@SHORTDATE"))
   ELSE
    RETURN(label->seperator)
   ENDIF
 END ;Subroutine
 SET last_mod = "000"
 SET mod_date = "April 05, 2016"
END GO
