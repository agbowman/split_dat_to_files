CREATE PROGRAM ct_rpt_milestone_pending_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Completed Activity" = 0.000000,
  "Pending Activities" = 0.000000,
  "Committees" = 0,
  "Organizations" = 0,
  "Roles" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, comp_act,
  pending_act, committees, orgs,
  roles, out_type, delimiter
 EXECUTE reportrtl
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 comp_activity_cd = f8
   1 pending_activity_cd = f8
   1 all_committees_ind = i2
   1 committee_cnt = i4
   1 committees[*]
     2 committee_id = f8
   1 all_organizations_ind = i2
   1 organization_cnt = i4
   1 organizations[*]
     2 organization_id = f8
   1 all_roles_ind = i2
   1 role_cnt = i4
   1 roles[*]
     2 role_cd = f8
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 init_activation_date = dq8
     2 amendments[*]
       3 prot_amendment_id = f8
       3 amendment_nbr = i4
       3 revision_nbr_txt = vc
       3 revision_ind = i2
       3 amd_status_cd = f8
       3 activities[*]
         4 activity_cd = f8
         4 sequence_nbr = i4
         4 entity_type_flag = i2
         4 responsible_party = c100
         4 completed_dt_tm = dq8
 )
 RECORD label(
   1 prot_mnemonic_header = vc
   1 amendment = vc
   1 amd_status_header = vc
   1 activity_header = vc
   1 completed_date_header = vc
   1 total_prots = vc
   1 end_of_rpt = vc
   1 revision = vc
   1 init_prot = vc
   1 not_specified = vc
   1 rpt_title = vc
   1 completed_activity = vc
   1 pending_activity = vc
   1 rep_exec_time = vc
   1 at_least_one_prot = vc
   1 at_least_one_c_o_r = vc
   1 unable_to_exec = vc
   1 no_prots = vc
   1 seperator = vc
   1 rpt_page = vc
 )
 EXECUTE ct_rpt_milestone_pending:dba "NL:",  $PROTOCOLS,  $COMP_ACT,
  $PENDING_ACT,  $COMMITTEES,  $ORGS,
  $ROLES,  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_milestone_pending_protocols(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection_line(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footreportsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
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
 DECLARE _remlabel_completed_activity = i4 WITH noconstant(1), protect
 DECLARE _remlabel_pending_activity = i4 WITH noconstant(1), protect
 DECLARE _remlabel_prot_mnemonic_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_amendment = i4 WITH noconstant(1), protect
 DECLARE _remlabel_amd_status_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_activity_header = i4 WITH noconstant(1), protect
 DECLARE _remlabel_completed_date_header = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remtmp_prot = i4 WITH noconstant(1), protect
 DECLARE _remtmp_amd_desc = i4 WITH noconstant(1), protect
 DECLARE _remtmp_status = i4 WITH noconstant(1), protect
 DECLARE _remtmp_activity = i4 WITH noconstant(1), protect
 DECLARE _remtmp_act_date = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rep_exec_time = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remtempstr = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _courier12b0 = i4 WITH noconstant(0), protect
 DECLARE _courier9b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE tempstr = vc WITH protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE tmp_activity = vc WITH protect
 DECLARE tmp_act_date = vc WITH protect
 DECLARE tmp_amd_desc = vc WITH protect
 DECLARE prot_cnt = i4 WITH protect
 SUBROUTINE get_milestone_pending_protocols(dummy)
   SELECT
    protocols_prot_master_id = results->protocols[d.seq].prot_master_id, protocols_primary_mnemonic
     = cnvtlower(results->protocols[d.seq].primary_mnemonic)
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY protocols_primary_mnemonic, protocols_prot_master_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _bholdcontinue = 0,
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight,((rptreport->m_pagewidth - rptreport
      ->m_marginbottom) - _yoffset),_bholdcontinue))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), dummy_val = headpagesection_line
     (rpt_render)
    HEAD protocols_primary_mnemonic
     row + 0
    HEAD protocols_prot_master_id
     prot_cnt = (prot_cnt+ 1)
     IF (((row+ size(results->protocols[d.seq].amendments,5)) > 53)
      AND size(results->protocols[d.seq].amendments,5) < 53)
      BREAK
     ENDIF
     tmp_prot = results->protocols[d.seq].primary_mnemonic
    DETAIL
     FOR (idx = 1 TO size(results->protocols[d.seq].amendments,5))
       IF ((results->protocols[d.seq].amendments[idx].amendment_nbr > 0))
        tmp_amd_desc = concat(label->amendment," ",trim(cnvtstring(results->protocols[d.seq].
           amendments[idx].amendment_nbr)))
       ELSE
        tmp_amd_desc = label->init_prot
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].revision_ind=1))
        tmp_amd_desc = concat(tmp_amd_desc," - ",label->revision," ",results->protocols[d.seq].
         amendments[idx].revision_nbr_txt)
       ENDIF
       tmp_status = uar_get_code_display(results->protocols[d.seq].amendments[idx].amd_status_cd)
       FOR (parmidx = 1 TO size(results->protocols[d.seq].amendments[idx].activities,5))
         tmp_activity = concat(trim(uar_get_code_display(results->protocols[d.seq].amendments[idx].
            activities[parmidx].activity_cd))," ",results->protocols[d.seq].amendments[idx].
          activities[parmidx].responsible_party)
         IF ((results->protocols[d.seq].amendments[idx].activities[parmidx].completed_dt_tm <
         cnvtdatetime("31-DEC-2100 00:00:00"))
          AND (results->protocols[d.seq].amendments[idx].activities[parmidx].completed_dt_tm > 0))
          tmp_act_date = format(results->protocols[d.seq].amendments[idx].activities[parmidx].
           completed_dt_tm,"@SHORTDATE")
         ELSE
          tmp_act_date = "--"
         ENDIF
         IF (idx > 1)
          tmp_prot = ""
         ENDIF
         IF (parmidx > 1)
          tmp_prot = "", tmp_amd_desc = "", tmp_status = ""
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
     ENDFOR
    FOOT  protocols_prot_master_id
     row + 0
    FOOT  protocols_primary_mnemonic
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
     dummy_val = footpagesection(rpt_render,((rptreport->m_pagewidth - rptreport->m_marginbottom) -
      _yoffset),_bcontfootpagesection), _yoffset = _yhold
    FOOT REPORT
     tempstr = concat(label->total_prots," ",trim(cnvtstring(prot_cnt,3))), _bcontfootreportsection
      = 0, bfirsttime = 1
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
   DECLARE sectionheight = f8 WITH noconstant(1.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_completed_activity = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_pending_activity = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_prot_mnemonic_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_amendment = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_amd_status_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_activity_header = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_completed_date_header = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_title = vc WITH noconstant(build2(label->rpt_title,char(0))), protect
   DECLARE __label_completed_activity = vc WITH noconstant(build2(label->completed_activity,char(0))),
   protect
   DECLARE __label_pending_activity = vc WITH noconstant(build2(label->pending_activity,char(0))),
   protect
   DECLARE __label_prot_mnemonic_header = vc WITH noconstant(build2(label->prot_mnemonic_header,char(
      0))), protect
   DECLARE __label_amendment = vc WITH noconstant(build2(label->amendment,char(0))), protect
   DECLARE __label_amd_status_header = vc WITH noconstant(build2(label->amd_status_header,char(0))),
   protect
   DECLARE __label_activity_header = vc WITH noconstant(build2(label->activity_header,char(0))),
   protect
   DECLARE __label_completed_date_header = vc WITH noconstant(build2(label->completed_date_header,
     char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_title = 1
    SET _remlabel_completed_activity = 1
    SET _remlabel_pending_activity = 1
    SET _remlabel_prot_mnemonic_header = 1
    SET _remlabel_amendment = 1
    SET _remlabel_amd_status_header = 1
    SET _remlabel_activity_header = 1
    SET _remlabel_completed_date_header = 1
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
   SET _holdremlabel_completed_activity = _remlabel_completed_activity
   IF (_remlabel_completed_activity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_completed_activity,((size(__label_completed_activity) - _remlabel_completed_activity
       )+ 1),__label_completed_activity)))
    SET drawheight_label_completed_activity = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_completed_activity = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_completed_activity,((size(
        __label_completed_activity) - _remlabel_completed_activity)+ 1),__label_completed_activity)))
    ))
     SET _remlabel_completed_activity = (_remlabel_completed_activity+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_completed_activity = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_completed_activity)
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
   SET _holdremlabel_pending_activity = _remlabel_pending_activity
   IF (_remlabel_pending_activity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_pending_activity,
       ((size(__label_pending_activity) - _remlabel_pending_activity)+ 1),__label_pending_activity)))
    SET drawheight_label_pending_activity = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_pending_activity = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_pending_activity,((size(
        __label_pending_activity) - _remlabel_pending_activity)+ 1),__label_pending_activity)))))
     SET _remlabel_pending_activity = (_remlabel_pending_activity+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_pending_activity = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_pending_activity)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.750
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
     SET _remlabel_prot_mnemonic_header = (_remlabel_prot_mnemonic_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_prot_mnemonic_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_prot_mnemonic_header)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_amendment = _remlabel_amendment
   IF (_remlabel_amendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_amendment,((size
       (__label_amendment) - _remlabel_amendment)+ 1),__label_amendment)))
    SET drawheight_label_amendment = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_amendment = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_amendment,((size(
        __label_amendment) - _remlabel_amendment)+ 1),__label_amendment)))))
     SET _remlabel_amendment = (_remlabel_amendment+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_amendment = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_amendment)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_amd_status_header = _remlabel_amd_status_header
   IF (_remlabel_amd_status_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_amd_status_header,((size(__label_amd_status_header) - _remlabel_amd_status_header)+
       1),__label_amd_status_header)))
    SET drawheight_label_amd_status_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_amd_status_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_amd_status_header,((size(
        __label_amd_status_header) - _remlabel_amd_status_header)+ 1),__label_amd_status_header)))))
     SET _remlabel_amd_status_header = (_remlabel_amd_status_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_amd_status_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_amd_status_header)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.000)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_activity_header = _remlabel_activity_header
   IF (_remlabel_activity_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_activity_header,
       ((size(__label_activity_header) - _remlabel_activity_header)+ 1),__label_activity_header)))
    SET drawheight_label_activity_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_activity_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_activity_header,((size(
        __label_activity_header) - _remlabel_activity_header)+ 1),__label_activity_header)))))
     SET _remlabel_activity_header = (_remlabel_activity_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_activity_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_activity_header)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_completed_date_header = _remlabel_completed_date_header
   IF (_remlabel_completed_date_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_completed_date_header,((size(__label_completed_date_header) -
       _remlabel_completed_date_header)+ 1),__label_completed_date_header)))
    SET drawheight_label_completed_date_header = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_completed_date_header = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_completed_date_header,((size(
        __label_completed_date_header) - _remlabel_completed_date_header)+ 1),
       __label_completed_date_header)))))
     SET _remlabel_completed_date_header = (_remlabel_completed_date_header+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_completed_date_header = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_completed_date_header)
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
   SET rptsd->m_height = drawheight_label_completed_activity
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremlabel_completed_activity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_completed_activity,((size(__label_completed_activity) -
       _holdremlabel_completed_activity)+ 1),__label_completed_activity)))
   ELSE
    SET _remlabel_completed_activity = _holdremlabel_completed_activity
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_pending_activity
   IF (ncalc=rpt_render
    AND _holdremlabel_pending_activity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_pending_activity,((size(__label_pending_activity) -
       _holdremlabel_pending_activity)+ 1),__label_pending_activity)))
   ELSE
    SET _remlabel_pending_activity = _holdremlabel_pending_activity
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.750
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
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_label_amendment
   IF (ncalc=rpt_render
    AND _holdremlabel_amendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_amendment,((
       size(__label_amendment) - _holdremlabel_amendment)+ 1),__label_amendment)))
   ELSE
    SET _remlabel_amendment = _holdremlabel_amendment
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = drawheight_label_amd_status_header
   IF (ncalc=rpt_render
    AND _holdremlabel_amd_status_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_amd_status_header,((size(__label_amd_status_header) -
       _holdremlabel_amd_status_header)+ 1),__label_amd_status_header)))
   ELSE
    SET _remlabel_amd_status_header = _holdremlabel_amd_status_header
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.000)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = drawheight_label_activity_header
   IF (ncalc=rpt_render
    AND _holdremlabel_activity_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_activity_header,((size(__label_activity_header) - _holdremlabel_activity_header)
       + 1),__label_activity_header)))
   ELSE
    SET _remlabel_activity_header = _holdremlabel_activity_header
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_completed_date_header
   IF (ncalc=rpt_render
    AND _holdremlabel_completed_date_header > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_completed_date_header,((size(__label_completed_date_header) -
       _holdremlabel_completed_date_header)+ 1),__label_completed_date_header)))
   ELSE
    SET _remlabel_completed_date_header = _holdremlabel_completed_date_header
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
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 0.032),(offsetx+ 10.521),(offsety
     + 0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_tmp_prot = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_amd_desc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_activity = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_act_date = f8 WITH noconstant(0.0), private
   DECLARE __tmp_prot = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __tmp_amd_desc = vc WITH noconstant(build2(tmp_amd_desc,char(0))), protect
   DECLARE __tmp_status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __tmp_activity = vc WITH noconstant(build2(tmp_activity,char(0))), protect
   DECLARE __tmp_act_date = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   IF (bcontinue=0)
    SET _remtmp_prot = 1
    SET _remtmp_amd_desc = 1
    SET _remtmp_status = 1
    SET _remtmp_activity = 1
    SET _remtmp_act_date = 1
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.750
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.125
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.000)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtmp_activity = _remtmp_activity
   IF (_remtmp_activity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtmp_activity,((size(
        __tmp_activity) - _remtmp_activity)+ 1),__tmp_activity)))
    SET drawheight_tmp_activity = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtmp_activity = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtmp_activity,((size(__tmp_activity) -
       _remtmp_activity)+ 1),__tmp_activity)))))
     SET _remtmp_activity = (_remtmp_activity+ rptsd->m_drawlength)
    ELSE
     SET _remtmp_activity = 0
    ENDIF
    SET growsum = (growsum+ _remtmp_activity)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.000
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
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_tmp_amd_desc
   IF (ncalc=rpt_render
    AND _holdremtmp_amd_desc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_amd_desc,((
       size(__tmp_amd_desc) - _holdremtmp_amd_desc)+ 1),__tmp_amd_desc)))
   ELSE
    SET _remtmp_amd_desc = _holdremtmp_amd_desc
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = drawheight_tmp_status
   IF (ncalc=rpt_render
    AND _holdremtmp_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_status,((size(
        __tmp_status) - _holdremtmp_status)+ 1),__tmp_status)))
   ELSE
    SET _remtmp_status = _holdremtmp_status
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.000)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = drawheight_tmp_activity
   IF (ncalc=rpt_render
    AND _holdremtmp_activity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_activity,((
       size(__tmp_activity) - _holdremtmp_activity)+ 1),__tmp_activity)))
   ELSE
    SET _remtmp_activity = _holdremtmp_activity
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_tmp_act_date
   IF (ncalc=rpt_render
    AND _holdremtmp_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_act_date,((
       size(__tmp_act_date) - _holdremtmp_act_date)+ 1),__tmp_act_date)))
   ELSE
    SET _remtmp_act_date = _holdremtmp_act_date
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
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
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
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_tempstr = f8 WITH noconstant(0.0), private
   DECLARE __tempstr = vc WITH noconstant(build2(tempstr,char(0))), protect
   IF (bcontinue=0)
    SET _remtempstr = 1
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
   SET _holdremtempstr = _remtempstr
   IF (_remtempstr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtempstr,((size(
        __tempstr) - _remtempstr)+ 1),__tempstr)))
    SET drawheight_tempstr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtempstr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtempstr,((size(__tempstr) -
       _remtempstr)+ 1),__tempstr)))))
     SET _remtempstr = (_remtempstr+ rptsd->m_drawlength)
    ELSE
     SET _remtempstr = 0
    ENDIF
    SET growsum = (growsum+ _remtempstr)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_tempstr
   IF (ncalc=rpt_render
    AND _holdremtempstr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtempstr,((size(
        __tempstr) - _holdremtempstr)+ 1),__tempstr)))
   ELSE
    SET _remtempstr = _holdremtempstr
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
   SET rptreport->m_reportname = "CT_RPT_MILESTONE_PENDING_LO"
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
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _courier80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _courier12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_on
   SET _courier8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET rptfont->m_bold = rpt_off
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
 IF (((size(results->protocols,5)=0) OR (size(results->messages,5) > 0)) )
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, label->rpt_title, row + 1,
    col 0, label->completed_activity, row + 1,
    col 0, label->pending_activity, row + 1,
    col 0, label->rep_exec_time
    IF (size(results->messages,5) > 0)
     row + 2, col 0, label->unable_to_exec
     FOR (idx = 1 TO size(results->messages,5))
       tempstr = results->messages[idx].text, row + 1, col 0,
       tempstr
     ENDFOR
    ELSE
     row + 2, col 0, label->no_prots
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (( $OUT_TYPE=1))
  SELECT INTO  $OUTDEV
   prot_mnemonic = cnvtlower(results->protocols[d.seq].primary_mnemonic), prot_id = results->
   protocols[d.seq].prot_master_id
   FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
   ORDER BY prot_mnemonic
   HEAD REPORT
    prot_cnt = 0, col 0, label->rpt_title,
    row + 1, col 0, label->completed_activity,
    row + 1, col 0, label->pending_activity,
    row + 1, col 0, label->rep_exec_time,
    row + 1, tempstr = concat(label->prot_mnemonic_header, $DELIMITER,label->amendment, $DELIMITER,
     label->amd_status_header,
      $DELIMITER,label->activity_header, $DELIMITER,label->completed_date_header), col 0,
    tempstr, row + 1
   HEAD prot_id
    prot_cnt = (prot_cnt+ 1), tmp_prot = results->protocols[d.seq].primary_mnemonic, tmp_prot =
    concat('"',trim(tmp_prot,3),'"')
   DETAIL
    FOR (idx = 1 TO size(results->protocols[d.seq].amendments,5))
      IF ((results->protocols[d.seq].amendments[idx].amendment_nbr > 0))
       tmp_amd_desc = concat(label->amendment,cnvtstring(results->protocols[d.seq].amendments[idx].
         amendment_nbr))
      ELSE
       tmp_amd_desc = label->init_prot
      ENDIF
      IF ((results->protocols[d.seq].amendments[idx].revision_ind=1))
       tmp_amd_desc = concat(tmp_amd_desc," ",label->seperator," ",label->revision,
        " ",results->protocols[d.seq].amendments[idx].revision_nbr_txt)
      ENDIF
      tmp_status = uar_get_code_display(results->protocols[d.seq].amendments[idx].amd_status_cd),
      tmp_amd_desc = concat('"',trim(tmp_amd_desc,3),'"'), tmp_status = concat('"',trim(tmp_status,3),
       '"')
      FOR (parmidx = 1 TO size(results->protocols[d.seq].amendments[idx].activities,5))
        tmp_activity = concat(trim(uar_get_code_display(results->protocols[d.seq].amendments[idx].
           activities[parmidx].activity_cd))," ",results->protocols[d.seq].amendments[idx].
         activities[parmidx].responsible_party)
        IF ((results->protocols[d.seq].amendments[idx].activities[parmidx].completed_dt_tm <
        cnvtdatetime("31-DEC-2100 00:00:00"))
         AND (results->protocols[d.seq].amendments[idx].activities[parmidx].completed_dt_tm > 0))
         tmp_act_date = format(results->protocols[d.seq].amendments[idx].activities[parmidx].
          completed_dt_tm,"@SHORTDATE")
        ELSE
         tmp_act_date = ""
        ENDIF
        tmp_activity = concat('"',trim(tmp_activity,3),'"'), tmp_act_date = concat('"',trim(
          tmp_act_date,3),'"'), tempstr = concat(tmp_prot, $DELIMITER,tmp_amd_desc, $DELIMITER,
         tmp_status,
          $DELIMITER,tmp_activity, $DELIMITER,tmp_act_date),
        col 0, tempstr, row + 1
      ENDFOR
    ENDFOR
   FOOT REPORT
    row + 1, tempstr = concat(label->total_prots," ",trim(cnvtstring(prot_cnt))), col 0,
    tempstr, row + 2, col 0,
    label->end_of_rpt
   WITH format = crstream, formfeed = none, maxcol = 1500,
    nocounter
  ;end select
 ELSE
  CALL initializereport(0)
  CALL get_milestone_pending_protocols(0)
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "APR,04 2016"
END GO
