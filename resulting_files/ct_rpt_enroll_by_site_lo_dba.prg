CREATE PROGRAM ct_rpt_enroll_by_site_lo:dba
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
   1 unhandled_grp = vc
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
 EXECUTE ct_rpt_enroll_by_site:dba "NL:",  $PROTOCOL,  $ORG,
  $PERSON,  $INIT_SVC,  $GROUPBY,
  $ORDERBY,  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_ENROLL_BY_SITE_LO"
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 IF (((size(results->enrollments,5)=0) OR (size(results->messages,5) > 0)) )
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 1, label->rpt_title, row + 1,
    col 1, label->rpt_order_by_title, row + 1,
    col 1, label->rep_exec_time
    IF (size(results->messages,5) > 0)
     row + 2, col 1, label->unable_to_exec
     FOR (idx = 1 TO size(results->messages,5))
       tempstr = results->messages[idx].text, row + 1, col 1,
       tempstr
     ENDFOR
    ELSE
     row + 2, col 1, label->no_prot_found
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (( $OUT_TYPE=1))
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
  IF (( $GROUPBY=0))
   SELECT INTO  $OUTDEV
    site_id = results->enrollments[d.seq].enroll_org_id, tmp_prot = substring(1,20,results->
     enrollments[d.seq].primary_mnemonic), prot_id = results->enrollments[d.seq].prot_master_id,
    init_service_cd = results->enrollments[d.seq].initiating_service_cd, pi_id = results->pis[d2.seq]
    .pi_id, person_id = results->enrollments[d.seq].person_id
    FROM (dummyt d  WITH seq = value(size(results->enrollments,5))),
     (dummyt d2  WITH seq = value(size(results->pis,5)))
    PLAN (d)
     JOIN (d2
     WHERE (results->pis[d2.seq].prot_master_id=results->enrollments[d.seq].prot_master_id))
    ORDER BY substring(1,35,cnvtlower(results->enrollments[d.seq].enroll_org_name)), parser(
      reportlist->order_by_1), parser(reportlist->order_by_2)
    HEAD REPORT
     site_cnt = 0, offset = 0, row + 1,
     col offset, label->rpt_title, row + 1,
     col offset, label->rpt_order_by_title, row + 1,
     col offset, label->rep_exec_time, row + 1,
     tempstr = concat(label->enroll_inst_header, $DELIMITER,label->prot_mnemonic_header, $DELIMITER,
      label->pri_investigator_header,
       $DELIMITER,label->init_serv_header, $DELIMITER,label->cur_on_study_header, $DELIMITER,
      label->cur_off_treat_header, $DELIMITER,label->cur_off_study_header, $DELIMITER,label->
      total_enrolled_header), col offset, tempstr,
     row + 1
    HEAD site_id
     site_cnt += 1, prot_cnt = 0, on_study_total = 0,
     off_tx_total = 0, off_study_total = 0, enroll_total = 0,
     stat = alterlist(countlist->init_services,0), init_svc_cnt = 0, stat = alterlist(countlist->pis,
      0),
     pi_cnt = 0
     IF ((results->enrollments[d.seq].enroll_org_coord_inst_ind=1)
      AND ( $GROUPBY=3))
      tmp_site = concat("*",trim(results->enrollments[d.seq].enroll_org_name))
     ELSE
      tmp_site = trim(results->enrollments[d.seq].enroll_org_name)
     ENDIF
    HEAD prot_id
     prot_cnt += 1, on_study_cnt = 0, off_tx_cnt = 0,
     off_study_cnt = 0, total_cnt = 0, prot_pi_cnt = 0
    HEAD person_id
     IF ((results->enrollments[d.seq].off_study_ind=1))
      off_study_cnt += 1
     ELSEIF ((results->enrollments[d.seq].off_tx_ind=1))
      off_tx_cnt += 1
     ELSE
      on_study_cnt += 1
     ENDIF
    HEAD pi_id
     rec_pos = locateval(num,1,size(countlist->prot_pis,5),pi_id,countlist->prot_pis[num].pi_id)
     IF (rec_pos=0)
      prot_pi_cnt += 1
      IF (mod(prot_pi_cnt,10)=1)
       stat = alterlist(countlist->prot_pis,(prot_pi_cnt+ 9))
      ENDIF
      countlist->prot_pis[prot_pi_cnt].pi_id = pi_id, countlist->prot_pis[prot_pi_cnt].pi_name_full
       = results->pis[d2.seq].pi_name_full
     ENDIF
    FOOT  prot_id
     total_cnt = ((on_study_cnt+ off_tx_cnt)+ off_study_cnt)
     IF ((results->enrollments[d.seq].therapeutic_ind=1))
      off_tx_str = cnvtstring(off_tx_cnt)
     ELSE
      off_tx_str = "-"
     ENDIF
     FOR (idx = 1 TO prot_pi_cnt)
       IF (idx > 1)
        tmp_pi = concat(tmp_pi,label->semi," ",trim(countlist->prot_pis[idx].pi_name_full))
       ELSE
        tmp_pi = trim(countlist->prot_pis[idx].pi_name_full)
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(tmp_site),'"'), $DELIMITER,concat('"',trim(results->
        enrollments[d.seq].primary_mnemonic),'"'), $DELIMITER,concat('"',trim(tmp_pi),'"'),
       $DELIMITER,concat('"',trim(uar_get_code_display(results->enrollments[d.seq].
         initiating_service_cd)),'"'), $DELIMITER,concat('"',trim(cnvtstring(on_study_cnt)),'"'),
       $DELIMITER,
      concat('"',trim(off_tx_str),'"'), $DELIMITER,concat('"',trim(cnvtstring(off_study_cnt)),'"'),
       $DELIMITER,concat('"',trim(cnvtstring(total_cnt)),'"')), col offset, tempstr,
     row + 1, on_study_total += on_study_cnt, off_study_total += off_study_cnt,
     off_tx_total += off_tx_cnt, enroll_total += total_cnt, stat = alterlist(countlist->prot_pis,0),
     prot_pi_cnt = 0
    FOOT REPORT
     row + 1, tempstr = concat(label->total_sites," ",trim(cnvtstring(site_cnt,3))), col offset,
     tempstr, row + 2, col offset,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSEIF (( $GROUPBY=1))
   SELECT INTO  $OUTDEV
    site_id = results->enrollments[d.seq].enroll_org_id, prot_id = results->enrollments[d.seq].
    prot_master_id, init_service_cd = results->enrollments[d.seq].initiating_service_cd,
    pi_id = results->pis[d2.seq].pi_id, person_id = results->enrollments[d.seq].person_id
    FROM (dummyt d  WITH seq = value(size(results->enrollments,5))),
     (dummyt d2  WITH seq = value(size(results->pis,5)))
    PLAN (d)
     JOIN (d2
     WHERE (results->pis[d2.seq].prot_master_id=results->enrollments[d.seq].prot_master_id))
    ORDER BY substring(1,35,cnvtlower(uar_get_code_display(results->enrollments[d.seq].
        initiating_service_cd))), parser(reportlist->order_by_1), parser(reportlist->order_by_2)
    HEAD REPORT
     site_cnt = 0, row + 1, col offset,
     label->rpt_title, row + 1, col offset,
     label->rpt_order_by_title, row + 1, col offset,
     label->rep_exec_time, row + 1, tempstr = concat(label->init_serv_header, $DELIMITER,label->
      prot_mnemonic_header, $DELIMITER,label->enroll_inst_header,
       $DELIMITER,label->pri_investigator_header, $DELIMITER,label->cur_on_study_header, $DELIMITER,
      label->cur_off_treat_header, $DELIMITER,label->cur_off_study_header, $DELIMITER,label->
      total_enrolled_header),
     col offset, tempstr, row + 1
    HEAD init_service_cd
     init_svc_cnt += 1, on_study_total = 0, off_tx_total = 0,
     off_study_total = 0, enroll_total = 0, tmp_init_svc = trim(uar_get_code_display(results->
       enrollments[d.seq].initiating_service_cd))
    HEAD prot_id
     prot_cnt += 1
    HEAD site_id
     on_study_cnt = 0, off_tx_cnt = 0, off_study_cnt = 0,
     total_cnt = 0, prot_pi_cnt = 0
     IF ((results->enrollments[d.seq].enroll_org_coord_inst_ind=1))
      tmp_site = concat("*",trim(results->enrollments[d.seq].enroll_org_name))
     ELSE
      tmp_site = trim(results->enrollments[d.seq].enroll_org_name)
     ENDIF
    HEAD person_id
     IF ((results->enrollments[d.seq].off_study_ind=1))
      off_study_cnt += 1
     ELSEIF ((results->enrollments[d.seq].off_tx_ind=1))
      off_tx_cnt += 1
     ELSE
      on_study_cnt += 1
     ENDIF
    HEAD pi_id
     rec_pos = locateval(num,1,size(countlist->prot_pis,5),pi_id,countlist->prot_pis[num].pi_id)
     IF (rec_pos=0)
      prot_pi_cnt += 1
      IF (mod(prot_pi_cnt,10)=1)
       stat = alterlist(countlist->prot_pis,(prot_pi_cnt+ 9))
      ENDIF
      countlist->prot_pis[prot_pi_cnt].pi_id = pi_id, countlist->prot_pis[prot_pi_cnt].pi_name_full
       = results->pis[d2.seq].pi_name_full
     ENDIF
    FOOT  site_id
     total_cnt = ((on_study_cnt+ off_tx_cnt)+ off_study_cnt)
     IF ((results->enrollments[d.seq].therapeutic_ind=1))
      off_tx_str = cnvtstring(off_tx_cnt)
     ELSE
      off_tx_str = "-"
     ENDIF
     FOR (idx = 1 TO prot_pi_cnt)
       IF (idx > 1)
        tmp_pi = concat(tmp_pi,label->semi," ",trim(countlist->prot_pis[idx].pi_name_full))
       ELSE
        tmp_pi = trim(countlist->prot_pis[idx].pi_name_full)
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(uar_get_code_display(results->enrollments[d.seq].
         initiating_service_cd)),'"'), $DELIMITER,concat('"',trim(results->enrollments[d.seq].
        primary_mnemonic),'"'), $DELIMITER,concat('"',trim(tmp_site),'"'),
       $DELIMITER,concat('"',trim(tmp_pi),'"'), $DELIMITER,concat('"',trim(cnvtstring(on_study_cnt)),
       '"'), $DELIMITER,
      concat('"',trim(off_tx_str),'"'), $DELIMITER,concat('"',trim(cnvtstring(off_study_cnt)),'"'),
       $DELIMITER,concat('"',trim(cnvtstring(total_cnt)),'"')), col offset, tempstr,
     row + 1, stat = alterlist(countlist->prot_pis,0), prot_pi_cnt = 0
    FOOT REPORT
     row + 1, tempstr = concat(label->total_init," ",trim(cnvtstring(init_svc_cnt,3))), col offset,
     tempstr, row + 2, col offset,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSEIF (( $GROUPBY=2))
   SELECT INTO  $OUTDEV
    site_id = results->enrollments[d.seq].enroll_org_id, tmp_prot = substring(1,20,results->
     enrollments[d.seq].primary_mnemonic), prot_id = results->enrollments[d.seq].prot_master_id,
    init_service_cd = results->enrollments[d.seq].initiating_service_cd, pi_id = results->pis[d2.seq]
    .pi_id, person_id = results->enrollments[d.seq].person_id
    FROM (dummyt d  WITH seq = value(size(results->enrollments,5))),
     (dummyt d2  WITH seq = value(size(results->pis,5)))
    PLAN (d)
     JOIN (d2
     WHERE (results->pis[d2.seq].prot_master_id=results->enrollments[d.seq].prot_master_id))
    ORDER BY substring(1,35,cnvtlower(results->pis[d2.seq].pi_name_full)), parser(reportlist->
      order_by_1), parser(reportlist->order_by_2)
    HEAD REPORT
     pi_cnt = 0, offset = 0, row + 1,
     col offset, label->rpt_title, row + 1,
     col offset, label->rpt_order_by_title, row + 1,
     col offset, label->rep_exec_time, row + 1,
     tempstr = concat(label->pri_investigator_header, $DELIMITER,label->prot_mnemonic_header,
       $DELIMITER,label->enroll_inst_header,
       $DELIMITER,label->init_serv_header, $DELIMITER,label->cur_on_study_header, $DELIMITER,
      label->cur_off_treat_header, $DELIMITER,label->cur_off_study_header, $DELIMITER,label->
      total_enrolled_header), col offset, tempstr,
     row + 1
    HEAD pi_id
     on_study_total = 0, off_tx_total = 0, off_study_total = 0,
     enroll_total = 0, pi_cnt += 1, tmp_pi = trim(results->pis[d2.seq].pi_name_full)
    HEAD prot_id
     prot_cnt += 1
    HEAD site_id
     on_study_cnt = 0, off_tx_cnt = 0, off_study_cnt = 0,
     total_cnt = 0, prot_pi_cnt = 0
     IF ((results->enrollments[d.seq].enroll_org_coord_inst_ind=1))
      tmp_site = concat("*",trim(results->enrollments[d.seq].enroll_org_name))
     ELSE
      tmp_site = trim(results->enrollments[d.seq].enroll_org_name)
     ENDIF
    HEAD person_id
     IF ((results->enrollments[d.seq].off_study_ind=1))
      off_study_cnt += 1
     ELSEIF ((results->enrollments[d.seq].off_tx_ind=1))
      off_tx_cnt += 1
     ELSE
      on_study_cnt += 1
     ENDIF
    FOOT  site_id
     total_cnt = ((on_study_cnt+ off_tx_cnt)+ off_study_cnt)
     IF ((results->enrollments[d.seq].therapeutic_ind=1))
      off_tx_str = cnvtstring(off_tx_cnt)
     ELSE
      off_tx_str = "-"
     ENDIF
     tempstr = concat(concat('"',trim(tmp_pi),'"'), $DELIMITER,concat('"',trim(results->enrollments[d
        .seq].primary_mnemonic),'"'), $DELIMITER,concat('"',trim(tmp_site),'"'),
       $DELIMITER,concat('"',trim(uar_get_code_display(results->enrollments[d.seq].
         initiating_service_cd)),'"'), $DELIMITER,concat('"',trim(cnvtstring(on_study_cnt)),'"'),
       $DELIMITER,
      concat('"',trim(off_tx_str),'"'), $DELIMITER,concat('"',trim(cnvtstring(off_study_cnt)),'"'),
       $DELIMITER,concat('"',trim(cnvtstring(total_cnt)),'"')), col offset, tempstr,
     row + 1
    FOOT REPORT
     row + 1, tempstr = concat(label->total_pi," ",trim(cnvtstring(pi_cnt,3))), col offset,
     tempstr, row + 2, col offset,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSEIF (( $GROUPBY=3))
   SELECT INTO  $OUTDEV
    site_id = results->enrollments[d.seq].enroll_org_id, tmp_prot = substring(1,20,results->
     enrollments[d.seq].primary_mnemonic), prot_id = results->enrollments[d.seq].prot_master_id,
    init_service_cd = results->enrollments[d.seq].initiating_service_cd, pi_id = results->pis[d2.seq]
    .pi_id, person_id = results->enrollments[d.seq].person_id
    FROM (dummyt d  WITH seq = value(size(results->enrollments,5))),
     (dummyt d2  WITH seq = value(size(results->pis,5)))
    PLAN (d)
     JOIN (d2
     WHERE (results->pis[d2.seq].prot_master_id=results->enrollments[d.seq].prot_master_id))
    ORDER BY substring(1,35,cnvtlower(results->enrollments[d.seq].primary_mnemonic)), parser(
      reportlist->order_by_1), parser(reportlist->order_by_2)
    HEAD REPORT
     site_cnt = 0, offset = 0, row + 1,
     col offset, label->rpt_title, row + 1,
     col offset, label->rpt_order_by_title, row + 1,
     col offset, label->rep_exec_time, row + 1,
     tempstr = concat(label->prot_mnemonic_header, $DELIMITER,label->enroll_inst_header, $DELIMITER,
      label->pri_investigator_header,
       $DELIMITER,label->init_serv_header, $DELIMITER,label->cur_on_study_header, $DELIMITER,
      label->cur_off_treat_header, $DELIMITER,label->cur_off_study_header, $DELIMITER,label->
      total_enrolled_header), col offset, tempstr,
     row + 1
    HEAD prot_id
     prot_cnt += 1, site_cnt = 0, on_study_total = 0,
     off_tx_total = 0, off_study_total = 0, enroll_total = 0,
     tmp_prot = trim(results->enrollments[d.seq].primary_mnemonic)
    HEAD site_id
     site_cnt += 1, on_study_cnt = 0, off_tx_cnt = 0,
     off_study_cnt = 0, total_cnt = 0, prot_pi_cnt = 0
    HEAD person_id
     IF ((results->enrollments[d.seq].off_study_ind=1))
      off_study_cnt += 1
     ELSEIF ((results->enrollments[d.seq].off_tx_ind=1))
      off_tx_cnt += 1
     ELSE
      on_study_cnt += 1
     ENDIF
    HEAD pi_id
     rec_pos = locateval(num,1,size(countlist->prot_pis,5),pi_id,countlist->prot_pis[num].pi_id)
     IF (rec_pos=0)
      prot_pi_cnt += 1
      IF (mod(prot_pi_cnt,10)=1)
       stat = alterlist(countlist->prot_pis,(prot_pi_cnt+ 9))
      ENDIF
      countlist->prot_pis[prot_pi_cnt].pi_id = pi_id, countlist->prot_pis[prot_pi_cnt].pi_name_full
       = results->pis[d2.seq].pi_name_full
     ENDIF
    FOOT  site_id
     total_cnt = ((on_study_cnt+ off_tx_cnt)+ off_study_cnt)
     IF ((results->enrollments[d.seq].enroll_org_coord_inst_ind=1))
      tmp_site = concat("*",trim(results->enrollments[d.seq].enroll_org_name))
     ELSE
      tmp_site = trim(results->enrollments[d.seq].enroll_org_name)
     ENDIF
     IF ((results->enrollments[d.seq].therapeutic_ind=1))
      off_tx_str = cnvtstring(off_tx_cnt)
     ELSE
      off_tx_str = "-"
     ENDIF
     FOR (idx = 1 TO prot_pi_cnt)
       IF (idx > 1)
        tmp_pi = concat(tmp_pi,label->semi," ",trim(countlist->prot_pis[idx].pi_name_full))
       ELSE
        tmp_pi = trim(countlist->prot_pis[idx].pi_name_full)
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(results->enrollments[d.seq].primary_mnemonic),'"'), $DELIMITER,
      concat('"',trim(tmp_site),'"'), $DELIMITER,concat('"',trim(tmp_pi),'"'),
       $DELIMITER,concat('"',trim(uar_get_code_display(results->enrollments[d.seq].
         initiating_service_cd)),'"'), $DELIMITER,concat('"',trim(cnvtstring(on_study_cnt)),'"'),
       $DELIMITER,
      concat('"',trim(off_tx_str),'"'), $DELIMITER,concat('"',trim(cnvtstring(off_study_cnt)),'"'),
       $DELIMITER,concat('"',trim(cnvtstring(total_cnt)),'"')), col offset, tempstr,
     row + 1, stat = alterlist(countlist->prot_pis,0), prot_pi_cnt = 0
    FOOT REPORT
     row + 1, tempstr = concat(label->total_prot," ",trim(cnvtstring(prot_cnt,3))), col offset,
     tempstr, row + 1, tempstr = concat(label->represents," ",trim(uar_get_code_display(coord_inst_cd
        ))," ",label->on_the_prot),
     col offset, tempstr, row + 1,
     tempstr = label->end_of_rpt, col offset, tempstr
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    WHERE 1=1
    DETAIL
     col 1, label->rpt_title, row + 1,
     col 1, label->rpt_order_by_title, row + 1,
     col 1, label->rep_exec_time, row + 2,
     col 1, label->unhandled_grp
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  CALL initializereport(0)
  SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom)
  IF (( $GROUPBY=0))
   SET _bsubreport = 1
   EXECUTE ct_sub_rpt_enroll_grp_site:dba  $OUTDEV,  $PROTOCOL,  $ORG,
    $PERSON,  $INIT_SVC,  $GROUPBY,
    $ORDERBY,  $OUT_TYPE,  $DELIMITER
   SET _bsubreport = 0
  ENDIF
  IF (( $GROUPBY=1))
   SET _bsubreport = 1
   EXECUTE ct_sub_rpt_enroll_grp_init_srv:dba  $OUTDEV,  $PROTOCOL,  $ORG,
    $PERSON,  $INIT_SVC,  $GROUPBY,
    $ORDERBY,  $OUT_TYPE,  $DELIMITER
   SET _bsubreport = 0
  ENDIF
  IF (( $GROUPBY=2))
   SET _bsubreport = 1
   EXECUTE ct_sub_rpt_enroll_grp_pi:dba  $OUTDEV,  $PROTOCOL,  $ORG,
    $PERSON,  $INIT_SVC,  $GROUPBY,
    $ORDERBY,  $OUT_TYPE,  $DELIMITER
   SET _bsubreport = 0
  ENDIF
  IF (( $GROUPBY=3))
   SET _bsubreport = 1
   EXECUTE ct_sub_rpt_enroll_grp_prot:dba  $OUTDEV,  $PROTOCOL,  $ORG,
    $PERSON,  $INIT_SVC,  $GROUPBY,
    $ORDERBY,  $OUT_TYPE,  $DELIMITER
   SET _bsubreport = 0
  ENDIF
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Apr 06, 2016"
END GO
