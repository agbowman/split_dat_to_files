CREATE PROGRAM ct_rpt_amd_enrollment_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Order By" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, orderby,
  out_type, delimiter
 EXECUTE reportrtl
 RECORD protlist(
   1 protocols[*]
     2 protocol_id = f8
   1 accrual_numbers = i2
   1 order_by = i2
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 cur_amd_id = f8
     2 parent_prot_master_id = f8
     2 init_activation_date = dq8
     2 cur_accrual = i4
     2 amendments[*]
       3 prot_amendment_id = f8
       3 amenmdent_status_cd = f8
       3 amendment_nbr = i4
       3 revision_ind = i2
       3 revision_nbr_txt = vc
       3 amd_accural = i4
 )
 RECORD report_labels(
   1 m_s_rpt_title = vc
   1 m_s_rep_exec_time = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_init_act_date_header = vc
   1 m_s_cur_accrual_header = vc
   1 m_s_amd_accrual_header = vc
   1 m_s_amd_rev_header = vc
   1 m_s_amd_status_header = vc
   1 m_s_total_prots = vc
   1 m_s_end_of_rpt = vc
   1 m_s_init_prot = vc
   1 m_s_amendment = vc
   1 m_s_revision = vc
   1 m_s_unable_to_exec = vc
   1 m_s_no_prot_found = vc
   1 m_s_one_prot = vc
   1 m_s_order_by_date = vc
   1 m_s_order_by_prot = vc
   1 m_s_seperator = vc
   1 m_s_page = vc
   1 sorting_field = vc
   1 output_type = i2
   1 delimiter_output = vc
   1 execution_timestamp = vc
   1 sorted_by = vc
 )
 RECORD accrual_request(
   1 collab_site_ind = i2
   1 parent_prot_master_id = f8
   1 active_parent_amend_id = f8
   1 prot_amendment_id = f8
   1 prot_master_id = f8
   1 requiredaccrualcd = f8
   1 person_id = f8
   1 participation_type_cd = f8
   1 application_nbr = i4
   1 pref_domain = vc
   1 pref_section = vc
   1 pref_name = vc
 )
 RECORD accrual_reply(
   1 grouptargetaccrual = i2
   1 grouptargetaccrued = i2
   1 targetaccrual = i2
   1 totalaccrued = i2
   1 excludedpersonind = i2
   1 bfound = i2
   1 active_parent_amend_id = f8
   1 active_parent_amend_dt_tm = dq8
   1 group_target_accrual = i2
   1 participation_type_cd = f8
   1 prot_accrual = i2
   1 group_accrual = i2
   1 track_tw_accrual = i2
   1 collab_ind = i2
   1 is_parent = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request(
   1 patientid = f8
   1 protocolid = f8
   1 ptqualifier = i2
   1 protocols[*]
     2 protocolid = f8
   1 orgsecurity = i2
 )
 RECORD pt_reply(
   1 curdate = dq8
   1 tara = i4
   1 groupwidetara = i4
   1 prot_status_cd = f8
   1 prot_status_disp = vc
   1 prot_status_desc = vc
   1 prot_status_mean = c12
   1 as[*]
     2 amendstatus_cd = f8
     2 amendstatus_disp = vc
     2 amendstatus_desc = vc
     2 amendstatus_mean = c12
     2 datebegactive = dq8
     2 dateendactive = dq8
     2 datebegsusp = dq8
     2 nbr = i4
     2 id = f8
     2 revisionnbrtxt = c30
     2 revisionind = i2
   1 activeamendid = f8
   1 activeamendnbr = f8
   1 activedttm = dq8
   1 activerevisionind = i2
   1 activerevisionnbrtxt = c30
   1 highestamendid = f8
   1 highestamendnbr = f8
   1 registry_only_ind = i2
   1 enrolls[*]
     2 prot_master_id = f8
     2 prot_status_cd = f8
     2 prot_status_disp = vc
     2 prot_status_desc = vc
     2 prot_status_mean = c12
     2 prot_type_cd = f8
     2 prot_type_disp = vc
     2 prot_type_desc = vc
     2 prot_type_mean = c12
     2 cur_dateamendassignstart = dq8
     2 cur_dateamendassignend = dq8
     2 cur_protamendid = f8
     2 cur_amendmentnbr = i4
     2 cur_revisionnbrtxt = c30
     2 cur_revisionind = i2
     2 first_dateamendassignstart = dq8
     2 first_dateamendassignend = dq8
     2 first_protamendid = f8
     2 elig_protamendid = f8
     2 ptprotregid = f8
     2 regid = f8
     2 eligid = f8
     2 protalias = vc
     2 nomenclatureid = f8
     2 removalorgid = f8
     2 removalorgname = vc
     2 removalperid = f8
     2 removalpername = vc
     2 protaccessionnbr = vc
     2 dateonstudy = dq8
     2 dateoffstudy = dq8
     2 dateontherapy = dq8
     2 dateofftherapy = dq8
     2 datefirstpdfail = dq8
     2 firstdisrelevent_cd = f8
     2 firstdisrelevent_disp = vc
     2 firstdisrelevent_desc = vc
     2 firstdisrelevent_mean = c12
     2 enrollingorgid = f8
     2 enrollingorgname = vc
     2 protarmid = f8
     2 diagtype_cd = f8
     2 diagtype_disp = vc
     2 diagtype_desc = vc
     2 diagtype_mean = c12
     2 bestresp_cd = f8
     2 bestresp_disp = vc
     2 bestresp_desc = vc
     2 bestresp_mean = c12
     2 datefirstpd = dq8
     2 datefirstcr = dq8
     2 regupdtcnt = i4
     2 personid = f8
     2 lastname = vc
     2 firstname = vc
     2 namefullformatted = vc
     2 stratumlabel = vc
     2 follow_up_status_cd = f8
     2 follow_up_status_disp = vc
     2 txremovalorgid = f8
     2 txremovalorgname = vc
     2 txremovalperid = f8
     2 txremovalpername = vc
     2 txremovalreason_cd = f8
     2 txremovalreason_disp = vc
     2 txremovalreason_desc = vc
     2 txremovalreason_mean = c12
     2 txremovalreason = c255
     2 removalreason_cd = f8
     2 removalreason_disp = vc
     2 removalreason_desc = vc
     2 removalreason_mean = c12
     2 removalreason = c255
     2 episode_id = f8
     2 cohort_label = c30
     2 mrns[*]
       3 mrn = vc
       3 orgid = f8
       3 orgname = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = vc
       3 alias_pool_desc = vc
       3 alias_pool_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 EXECUTE ct_rpt_amd_enrollment:dba "NL:",  $PROTOCOLS,  $ORDERBY,
  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE ct_get_amd(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 DECLARE _remntitle1 = i4 WITH noconstant(1), protect
 DECLARE _remntitle2 = i4 WITH noconstant(1), protect
 DECLARE _remnprotocolmnemonic = i4 WITH noconstant(1), protect
 DECLARE _remninitialactivationdate = i4 WITH noconstant(1), protect
 DECLARE _remncurrentacc = i4 WITH noconstant(1), protect
 DECLARE _remnamdaccrual = i4 WITH noconstant(1), protect
 DECLARE _remnamdrev = i4 WITH noconstant(1), protect
 DECLARE _remnamendmentstatus = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remprotocol_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _reminitial_activation_date = i4 WITH noconstant(1), protect
 DECLARE _remcurrent_accrual = i4 WITH noconstant(1), protect
 DECLARE _remamend_accrual = i4 WITH noconstant(1), protect
 DECLARE _remamd_rev = i4 WITH noconstant(1), protect
 DECLARE _remamd_status = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remnexecutiontime = i4 WITH noconstant(1), protect
 DECLARE _remnpage = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remntotalprotocols = i4 WITH noconstant(1), protect
 DECLARE _remntotals = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _pen20s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_act_date = vc WITH protect
 DECLARE tmp_amd_acc = vc WITH protect
 DECLARE tmp_cur_acc = vc WITH protect
 DECLARE tmp_amd = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE prot_cnt = i2 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE pamd_idx = i4 WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE amd_cnt = i2 WITH protect
 DECLARE prot_id = f8 WITH protect
 DECLARE label_page = vc WITH protect
 SUBROUTINE ct_get_amd(dummy)
   SELECT
    protocols_prot_master_id = results->protocols[d.seq].prot_master_id, report_sortingfield = parser
    (report_labels->sorting_field)
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY report_sortingfield, protocols_prot_master_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _bholdcontinue = 0,
     _fenddetail -= footpagesection(rpt_calcheight,((rptreport->m_pagewidth - rptreport->
      m_marginbottom) - _yoffset),_bholdcontinue),
     prot_cnt = 0, _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), dummy_val = headpagesection1(
      rpt_render)
    HEAD report_sortingfield
     row + 0
    HEAD protocols_prot_master_id
     prot_cnt += 1
    DETAIL
     amd_cnt = size(results->protocols[d.seq].amendments,5)
     FOR (aidx = 1 TO amd_cnt)
       IF ((results->protocols[d.seq].amendments[aidx].amd_accural < 0))
        tmp_amd_acc = "   --"
       ELSE
        tmp_amd_acc = format(results->protocols[d.seq].amendments[aidx].amd_accural,"#####")
       ENDIF
       IF ((results->protocols[d.seq].amendments[aidx].amendment_nbr=0))
        tmp_amd = report_labels->m_s_init_prot
       ELSE
        tmp_amd = concat(report_labels->m_s_amendment," ",cnvtstring(results->protocols[d.seq].
          amendments[aidx].amendment_nbr))
       ENDIF
       IF ((results->protocols[d.seq].amendments[aidx].revision_ind=1))
        tmp_amd = concat(tmp_amd," - Rev ",results->protocols[d.seq].amendments[aidx].
         revision_nbr_txt)
       ENDIF
       tmp_status = uar_get_code_display(results->protocols[d.seq].amendments[aidx].
        amenmdent_status_cd)
       IF (aidx=1)
        tmp_prot = results->protocols[d.seq].primary_mnemonic, tmp_act_date = format(results->
         protocols[d.seq].init_activation_date,"@SHORTDATE")
        IF ((results->protocols[d.seq].cur_accrual < 0))
         tmp_cur_acc = "   --"
        ELSE
         tmp_cur_acc = format(results->protocols[d.seq].cur_accrual,"#####")
        ENDIF
       ELSE
        tmp_prot = "", tmp_act_date = "", tmp_cur_acc = ""
       ENDIF
       _bcontdetailsection = 0, bfirsttime = 1
       WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
         _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(
          _fenddetail - _yoffset),_bholdcontinue)
         IF (((_yoffset+ _fdrawheight) > _fenddetail))
          BREAK
         ELSEIF (_bholdcontinue=1
          AND _bcontdetailsection=0)
          BREAK
         ENDIF
         dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection),
         bfirsttime = 0
       ENDWHILE
     ENDFOR
    FOOT  protocols_prot_master_id
     row + 0
    FOOT  report_sortingfield
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, label_page = concat(build2(report_labels->m_s_page,
       trim(cnvtstring(curpage),3))),
     _bcontfootpagesection = 0, dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontfootpagesection), _yoffset = _yhold
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
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_ntitle1 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ntitle2 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nprotocolmnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ninitialactivationdate = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ncurrentacc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_namdaccrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_namdrev = f8 WITH noconstant(0.0), private
   DECLARE drawheight_namendmentstatus = f8 WITH noconstant(0.0), private
   DECLARE __ntitle1 = vc WITH noconstant(build2(report_labels->m_s_rpt_title,char(0))), protect
   DECLARE __ntitle2 = vc WITH noconstant(build2(report_labels->sorted_by,char(0))), protect
   DECLARE __nprotocolmnemonic = vc WITH noconstant(build2(report_labels->m_s_prot_mnemonic_header,
     char(0))), protect
   DECLARE __ninitialactivationdate = vc WITH noconstant(build2(report_labels->
     m_s_init_act_date_header,char(0))), protect
   DECLARE __ncurrentacc = vc WITH noconstant(build2(report_labels->m_s_cur_accrual_header,char(0))),
   protect
   DECLARE __namdaccrual = vc WITH noconstant(build2(report_labels->m_s_amd_accrual_header,char(0))),
   protect
   DECLARE __namdrev = vc WITH noconstant(build2(report_labels->m_s_amd_rev_header,char(0))), protect
   DECLARE __namendmentstatus = vc WITH noconstant(build2(report_labels->m_s_amd_status_header,char(0
      ))), protect
   IF (bcontinue=0)
    SET _remntitle1 = 1
    SET _remntitle2 = 1
    SET _remnprotocolmnemonic = 1
    SET _remninitialactivationdate = 1
    SET _remncurrentacc = 1
    SET _remnamdaccrual = 1
    SET _remnamdrev = 1
    SET _remnamendmentstatus = 1
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremntitle1 = _remntitle1
   IF (_remntitle1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remntitle1,((size(
        __ntitle1) - _remntitle1)+ 1),__ntitle1)))
    SET drawheight_ntitle1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remntitle1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remntitle1,((size(__ntitle1) -
       _remntitle1)+ 1),__ntitle1)))))
     SET _remntitle1 += rptsd->m_drawlength
    ELSE
     SET _remntitle1 = 0
    ENDIF
    SET growsum += _remntitle1
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _holdremntitle2 = _remntitle2
   IF (_remntitle2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remntitle2,((size(
        __ntitle2) - _remntitle2)+ 1),__ntitle2)))
    SET drawheight_ntitle2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remntitle2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remntitle2,((size(__ntitle2) -
       _remntitle2)+ 1),__ntitle2)))))
     SET _remntitle2 += rptsd->m_drawlength
    ELSE
     SET _remntitle2 = 0
    ENDIF
    SET growsum += _remntitle2
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   SET _holdremnprotocolmnemonic = _remnprotocolmnemonic
   IF (_remnprotocolmnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnprotocolmnemonic,((
       size(__nprotocolmnemonic) - _remnprotocolmnemonic)+ 1),__nprotocolmnemonic)))
    SET drawheight_nprotocolmnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnprotocolmnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnprotocolmnemonic,((size(
        __nprotocolmnemonic) - _remnprotocolmnemonic)+ 1),__nprotocolmnemonic)))))
     SET _remnprotocolmnemonic += rptsd->m_drawlength
    ELSE
     SET _remnprotocolmnemonic = 0
    ENDIF
    SET growsum += _remnprotocolmnemonic
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 0.792
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremninitialactivationdate = _remninitialactivationdate
   IF (_remninitialactivationdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remninitialactivationdate,
       ((size(__ninitialactivationdate) - _remninitialactivationdate)+ 1),__ninitialactivationdate)))
    SET drawheight_ninitialactivationdate = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remninitialactivationdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remninitialactivationdate,((size(
        __ninitialactivationdate) - _remninitialactivationdate)+ 1),__ninitialactivationdate)))))
     SET _remninitialactivationdate += rptsd->m_drawlength
    ELSE
     SET _remninitialactivationdate = 0
    ENDIF
    SET growsum += _remninitialactivationdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremncurrentacc = _remncurrentacc
   IF (_remncurrentacc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remncurrentacc,((size(
        __ncurrentacc) - _remncurrentacc)+ 1),__ncurrentacc)))
    SET drawheight_ncurrentacc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remncurrentacc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remncurrentacc,((size(__ncurrentacc) -
       _remncurrentacc)+ 1),__ncurrentacc)))))
     SET _remncurrentacc += rptsd->m_drawlength
    ELSE
     SET _remncurrentacc = 0
    ENDIF
    SET growsum += _remncurrentacc
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.438)
   SET rptsd->m_width = 1.052
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnamdaccrual = _remnamdaccrual
   IF (_remnamdaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnamdaccrual,((size(
        __namdaccrual) - _remnamdaccrual)+ 1),__namdaccrual)))
    SET drawheight_namdaccrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnamdaccrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnamdaccrual,((size(__namdaccrual) -
       _remnamdaccrual)+ 1),__namdaccrual)))))
     SET _remnamdaccrual += rptsd->m_drawlength
    ELSE
     SET _remnamdaccrual = 0
    ENDIF
    SET growsum += _remnamdaccrual
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.792
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnamdrev = _remnamdrev
   IF (_remnamdrev > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnamdrev,((size(
        __namdrev) - _remnamdrev)+ 1),__namdrev)))
    SET drawheight_namdrev = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnamdrev = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnamdrev,((size(__namdrev) -
       _remnamdrev)+ 1),__namdrev)))))
     SET _remnamdrev += rptsd->m_drawlength
    ELSE
     SET _remnamdrev = 0
    ENDIF
    SET growsum += _remnamdrev
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnamendmentstatus = _remnamendmentstatus
   IF (_remnamendmentstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnamendmentstatus,((
       size(__namendmentstatus) - _remnamendmentstatus)+ 1),__namendmentstatus)))
    SET drawheight_namendmentstatus = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnamendmentstatus = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnamendmentstatus,((size(
        __namendmentstatus) - _remnamendmentstatus)+ 1),__namendmentstatus)))))
     SET _remnamendmentstatus += rptsd->m_drawlength
    ELSE
     SET _remnamendmentstatus = 0
    ENDIF
    SET growsum += _remnamendmentstatus
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = drawheight_ntitle1
   IF (ncalc=rpt_render
    AND _holdremntitle1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntitle1,((size(
        __ntitle1) - _holdremntitle1)+ 1),__ntitle1)))
   ELSE
    SET _remntitle1 = _holdremntitle1
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.313)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = drawheight_ntitle2
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremntitle2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntitle2,((size(
        __ntitle2) - _holdremntitle2)+ 1),__ntitle2)))
   ELSE
    SET _remntitle2 = _holdremntitle2
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = drawheight_nprotocolmnemonic
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND _holdremnprotocolmnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnprotocolmnemonic,
       ((size(__nprotocolmnemonic) - _holdremnprotocolmnemonic)+ 1),__nprotocolmnemonic)))
   ELSE
    SET _remnprotocolmnemonic = _holdremnprotocolmnemonic
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 0.792
   SET rptsd->m_height = drawheight_ninitialactivationdate
   IF (ncalc=rpt_render
    AND _holdremninitialactivationdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremninitialactivationdate,((size(__ninitialactivationdate) -
       _holdremninitialactivationdate)+ 1),__ninitialactivationdate)))
   ELSE
    SET _remninitialactivationdate = _holdremninitialactivationdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_ncurrentacc
   IF (ncalc=rpt_render
    AND _holdremncurrentacc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremncurrentacc,((size
       (__ncurrentacc) - _holdremncurrentacc)+ 1),__ncurrentacc)))
   ELSE
    SET _remncurrentacc = _holdremncurrentacc
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.438)
   SET rptsd->m_width = 1.052
   SET rptsd->m_height = drawheight_namdaccrual
   IF (ncalc=rpt_render
    AND _holdremnamdaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnamdaccrual,((size
       (__namdaccrual) - _holdremnamdaccrual)+ 1),__namdaccrual)))
   ELSE
    SET _remnamdaccrual = _holdremnamdaccrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.792
   SET rptsd->m_height = drawheight_namdrev
   IF (ncalc=rpt_render
    AND _holdremnamdrev > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnamdrev,((size(
        __namdrev) - _holdremnamdrev)+ 1),__namdrev)))
   ELSE
    SET _remnamdrev = _holdremnamdrev
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.688)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = drawheight_namendmentstatus
   IF (ncalc=rpt_render
    AND _holdremnamendmentstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnamendmentstatus,(
       (size(__namendmentstatus) - _holdremnamendmentstatus)+ 1),__namendmentstatus)))
   ELSE
    SET _remnamendmentstatus = _holdremnamendmentstatus
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
 SUBROUTINE (headreport_labels_sorting_fieldsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreport_labels_sorting_fieldsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreport_labels_sorting_fieldsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headprotocols_prot_master_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprotocols_prot_master_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headprotocols_prot_master_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen20s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.131),(offsetx+ 9.969),(offsety+
     0.131))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.470000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_protocol_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_initial_activation_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_current_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amend_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amd_rev = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amd_status = f8 WITH noconstant(0.0), private
   DECLARE __protocol_mnemonic = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __initial_activation_date = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   DECLARE __current_accrual = vc WITH noconstant(build2(tmp_cur_acc,char(0))), protect
   DECLARE __amend_accrual = vc WITH noconstant(build2(tmp_amd_acc,char(0))), protect
   DECLARE __amd_rev = vc WITH noconstant(build2(tmp_amd,char(0))), protect
   DECLARE __amd_status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   IF (bcontinue=0)
    SET _remprotocol_mnemonic = 1
    SET _reminitial_activation_date = 1
    SET _remcurrent_accrual = 1
    SET _remamend_accrual = 1
    SET _remamd_rev = 1
    SET _remamd_status = 1
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
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
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
     SET _remprotocol_mnemonic += rptsd->m_drawlength
    ELSE
     SET _remprotocol_mnemonic = 0
    ENDIF
    SET growsum += _remprotocol_mnemonic
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdreminitial_activation_date = _reminitial_activation_date
   IF (_reminitial_activation_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _reminitial_activation_date,((size(__initial_activation_date) - _reminitial_activation_date)+
       1),__initial_activation_date)))
    SET drawheight_initial_activation_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminitial_activation_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminitial_activation_date,((size(
        __initial_activation_date) - _reminitial_activation_date)+ 1),__initial_activation_date)))))
     SET _reminitial_activation_date += rptsd->m_drawlength
    ELSE
     SET _reminitial_activation_date = 0
    ENDIF
    SET growsum += _reminitial_activation_date
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcurrent_accrual = _remcurrent_accrual
   IF (_remcurrent_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcurrent_accrual,((size
       (__current_accrual) - _remcurrent_accrual)+ 1),__current_accrual)))
    SET drawheight_current_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcurrent_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcurrent_accrual,((size(
        __current_accrual) - _remcurrent_accrual)+ 1),__current_accrual)))))
     SET _remcurrent_accrual += rptsd->m_drawlength
    ELSE
     SET _remcurrent_accrual = 0
    ENDIF
    SET growsum += _remcurrent_accrual
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.438)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremamend_accrual = _remamend_accrual
   IF (_remamend_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remamend_accrual,((size(
        __amend_accrual) - _remamend_accrual)+ 1),__amend_accrual)))
    SET drawheight_amend_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remamend_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remamend_accrual,((size(__amend_accrual)
        - _remamend_accrual)+ 1),__amend_accrual)))))
     SET _remamend_accrual += rptsd->m_drawlength
    ELSE
     SET _remamend_accrual = 0
    ENDIF
    SET growsum += _remamend_accrual
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremamd_rev = _remamd_rev
   IF (_remamd_rev > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remamd_rev,((size(
        __amd_rev) - _remamd_rev)+ 1),__amd_rev)))
    SET drawheight_amd_rev = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remamd_rev = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remamd_rev,((size(__amd_rev) -
       _remamd_rev)+ 1),__amd_rev)))))
     SET _remamd_rev += rptsd->m_drawlength
    ELSE
     SET _remamd_rev = 0
    ENDIF
    SET growsum += _remamd_rev
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremamd_status = _remamd_status
   IF (_remamd_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remamd_status,((size(
        __amd_status) - _remamd_status)+ 1),__amd_status)))
    SET drawheight_amd_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remamd_status = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remamd_status,((size(__amd_status) -
       _remamd_status)+ 1),__amd_status)))))
     SET _remamd_status += rptsd->m_drawlength
    ELSE
     SET _remamd_status = 0
    ENDIF
    SET growsum += _remamd_status
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.188)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_protocol_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprotocol_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprotocol_mnemonic,
       ((size(__protocol_mnemonic) - _holdremprotocol_mnemonic)+ 1),__protocol_mnemonic)))
   ELSE
    SET _remprotocol_mnemonic = _holdremprotocol_mnemonic
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = drawheight_initial_activation_date
   IF (ncalc=rpt_render
    AND _holdreminitial_activation_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdreminitial_activation_date,((size(__initial_activation_date) -
       _holdreminitial_activation_date)+ 1),__initial_activation_date)))
   ELSE
    SET _reminitial_activation_date = _holdreminitial_activation_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_current_accrual
   IF (ncalc=rpt_render
    AND _holdremcurrent_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcurrent_accrual,((
       size(__current_accrual) - _holdremcurrent_accrual)+ 1),__current_accrual)))
   ELSE
    SET _remcurrent_accrual = _holdremcurrent_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.438)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_amend_accrual
   IF (ncalc=rpt_render
    AND _holdremamend_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamend_accrual,((
       size(__amend_accrual) - _holdremamend_accrual)+ 1),__amend_accrual)))
   ELSE
    SET _remamend_accrual = _holdremamend_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_amd_rev
   IF (ncalc=rpt_render
    AND _holdremamd_rev > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamd_rev,((size(
        __amd_rev) - _holdremamd_rev)+ 1),__amd_rev)))
   ELSE
    SET _remamd_rev = _holdremamd_rev
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = drawheight_amd_status
   IF (ncalc=rpt_render
    AND _holdremamd_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamd_status,((size(
        __amd_status) - _holdremamd_status)+ 1),__amd_status)))
   ELSE
    SET _remamd_status = _holdremamd_status
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
 SUBROUTINE (footreport_labels_sorting_fieldsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreport_labels_sorting_fieldsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreport_labels_sorting_fieldsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footprotocols_prot_master_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footprotocols_prot_master_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footprotocols_prot_master_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
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
   DECLARE sectionheight = f8 WITH noconstant(0.700000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_nexecutiontime = f8 WITH noconstant(0.0), private
   DECLARE drawheight_npage = f8 WITH noconstant(0.0), private
   DECLARE __nexecutiontime = vc WITH noconstant(build2(report_labels->execution_timestamp,char(0))),
   protect
   DECLARE __npage = vc WITH noconstant(build2(label_page,char(0))), protect
   IF (bcontinue=0)
    SET _remnexecutiontime = 1
    SET _remnpage = 1
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
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremnexecutiontime = _remnexecutiontime
   IF (_remnexecutiontime > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnexecutiontime,((size(
        __nexecutiontime) - _remnexecutiontime)+ 1),__nexecutiontime)))
    SET drawheight_nexecutiontime = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnexecutiontime = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnexecutiontime,((size(__nexecutiontime
        ) - _remnexecutiontime)+ 1),__nexecutiontime)))))
     SET _remnexecutiontime += rptsd->m_drawlength
    ELSE
     SET _remnexecutiontime = 0
    ENDIF
    SET growsum += _remnexecutiontime
   ENDIF
   SET rptsd->m_flags = 37
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.604)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnpage = _remnpage
   IF (_remnpage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnpage,((size(__npage)
        - _remnpage)+ 1),__npage)))
    SET drawheight_npage = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnpage = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnpage,((size(__npage) - _remnpage)+ 1),
       __npage)))))
     SET _remnpage += rptsd->m_drawlength
    ELSE
     SET _remnpage = 0
    ENDIF
    SET growsum += _remnpage
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = drawheight_nexecutiontime
   IF (ncalc=rpt_render
    AND _holdremnexecutiontime > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnexecutiontime,((
       size(__nexecutiontime) - _holdremnexecutiontime)+ 1),__nexecutiontime)))
   ELSE
    SET _remnexecutiontime = _holdremnexecutiontime
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.375)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.604)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_npage
   IF (ncalc=rpt_render
    AND _holdremnpage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnpage,((size(
        __npage) - _holdremnpage)+ 1),__npage)))
   ELSE
    SET _remnpage = _holdremnpage
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
   DECLARE sectionheight = f8 WITH noconstant(0.590000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_ntotalprotocols = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ntotals = f8 WITH noconstant(0.0), private
   DECLARE __ntotalprotocols = vc WITH noconstant(build2(report_labels->m_s_total_prots,char(0))),
   protect
   DECLARE __ntotals = vc WITH noconstant(build2(prot_cnt,char(0))), protect
   IF (bcontinue=0)
    SET _remntotalprotocols = 1
    SET _remntotals = 1
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
    SET rptsd->m_y = (offsety+ 0.219)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremntotalprotocols = _remntotalprotocols
   IF (_remntotalprotocols > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remntotalprotocols,((size
       (__ntotalprotocols) - _remntotalprotocols)+ 1),__ntotalprotocols)))
    SET drawheight_ntotalprotocols = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remntotalprotocols = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remntotalprotocols,((size(
        __ntotalprotocols) - _remntotalprotocols)+ 1),__ntotalprotocols)))))
     SET _remntotalprotocols += rptsd->m_drawlength
    ELSE
     SET _remntotalprotocols = 0
    ENDIF
    SET growsum += _remntotalprotocols
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.219)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.094)
   SET rptsd->m_width = 1.031
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _holdremntotals = _remntotals
   IF (_remntotals > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remntotals,((size(
        __ntotals) - _remntotals)+ 1),__ntotals)))
    SET drawheight_ntotals = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remntotals = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remntotals,((size(__ntotals) -
       _remntotals)+ 1),__ntotals)))))
     SET _remntotals += rptsd->m_drawlength
    ELSE
     SET _remntotals = 0
    ENDIF
    SET growsum += _remntotals
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.219)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = drawheight_ntotalprotocols
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND _holdremntotalprotocols > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntotalprotocols,((
       size(__ntotalprotocols) - _holdremntotalprotocols)+ 1),__ntotalprotocols)))
   ELSE
    SET _remntotalprotocols = _holdremntotalprotocols
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.219)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.094)
   SET rptsd->m_width = 1.031
   SET rptsd->m_height = drawheight_ntotals
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremntotals > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntotals,((size(
        __ntotals) - _holdremntotals)+ 1),__ntotals)))
   ELSE
    SET _remntotals = _holdremntotals
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
   SET rptreport->m_reportname = "CT_RPT_AMD_ENROLLMENT_LO"
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
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.020
   SET _pen20s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (((size(results->protocols,5)=0) OR (size(results->messages,5) > 0)) )
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, report_labels->m_s_rpt_title, row + 1,
    col 0, report_labels->execution_timestamp
    IF (size(results->messages,5) > 0)
     row + 2, col 0, report_labels->m_s_unable_to_exec
     FOR (idx = 1 TO size(results->messages,5))
       tempstr = results->messages[idx].text, row + 1, col 0,
       tempstr
     ENDFOR
    ELSE
     row + 2, col 0, report_labels->m_s_no_prot_found
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((report_labels->output_type=1))
  SELECT INTO  $OUTDEV
   prot_id = results->protocols[d.seq].prot_master_id
   FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
   ORDER BY parser(report_labels->sorting_field)
   HEAD REPORT
    prot_cnt = 0, col 0, report_labels->m_s_rpt_title,
    row + 1, col 0, report_labels->sorted_by,
    row + 1, col 0, report_labels->execution_timestamp,
    row + 1, tempstr = concat(report_labels->m_s_prot_mnemonic_header,report_labels->delimiter_output,
     report_labels->m_s_init_act_date_header,report_labels->delimiter_output,report_labels->
     m_s_cur_accrual_header,
     report_labels->delimiter_output,report_labels->m_s_amd_accrual_header,report_labels->
     delimiter_output,report_labels->m_s_amd_rev_header,report_labels->delimiter_output,
     report_labels->m_s_amd_status_header), col 0,
    tempstr, row + 1
   HEAD prot_id
    prot_cnt += 1
   DETAIL
    amd_cnt = size(results->protocols[d.seq].amendments,5)
    FOR (aidx = 1 TO amd_cnt)
      IF ((results->protocols[d.seq].amendments[aidx].amd_accural < 0))
       tmp_amd_acc = ""
      ELSE
       tmp_amd_acc = cnvtstring(results->protocols[d.seq].amendments[aidx].amd_accural)
      ENDIF
      IF ((results->protocols[d.seq].amendments[aidx].amendment_nbr=0))
       tmp_amd = report_labels->m_s_init_prot
      ELSE
       tmp_amd = concat(report_labels->m_s_amendment," ",cnvtstring(results->protocols[d.seq].
         amendments[aidx].amendment_nbr))
      ENDIF
      IF ((results->protocols[d.seq].amendments[aidx].revision_ind=1))
       tmp_amd = concat(tmp_amd," ",report_labels->m_s_seperator," ",report_labels->m_s_revision,
        " ",results->protocols[d.seq].amendments[aidx].revision_nbr_txt)
      ENDIF
      tmp_status = uar_get_code_display(results->protocols[d.seq].amendments[aidx].
       amenmdent_status_cd), tmp_prot = results->protocols[d.seq].primary_mnemonic, tmp_act_date =
      format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
      IF ((results->protocols[d.seq].cur_accrual < 0))
       tmp_cur_acc = ""
      ELSE
       tmp_cur_acc = cnvtstring(results->protocols[d.seq].cur_accrual)
      ENDIF
      tempstr = concat(concat('"',trim(tmp_prot,3),'"'),report_labels->delimiter_output,concat('"',
        trim(tmp_act_date,3),'"'),report_labels->delimiter_output,concat('"',trim(tmp_cur_acc,3),'"'),
       report_labels->delimiter_output,concat('"',trim(tmp_amd_acc,3),'"'),report_labels->
       delimiter_output,concat('"',trim(tmp_amd,3),'"'),report_labels->delimiter_output,
       concat('"',trim(tmp_status,3),'"')), col 0, tempstr,
      row + 1
    ENDFOR
   FOOT REPORT
    row + 1, tempstr = concat(report_labels->m_s_total_prots," ",trim(cnvtstring(prot_cnt))), col 0,
    tempstr, row + 2, col 0,
    report_labels->m_s_end_of_rpt
   WITH format = crstream, formfeed = none, maxcol = 1500,
    nocounter
  ;end select
 ELSE
  CALL initializereport(0)
  CALL ct_get_amd(0)
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "April 25, 2016"
END GO
