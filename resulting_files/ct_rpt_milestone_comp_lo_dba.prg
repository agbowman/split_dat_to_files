CREATE PROGRAM ct_rpt_milestone_comp_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Protocol Status" = 0,
  "Milestone Activity" = 0.000000,
  "Committee" = 0,
  "Organization" = 0,
  "Role" = 0.000000,
  "Start Date (Optional)" = curdate,
  "End Date (Optional)" = curdate,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, protstatus,
  activity, committee, org,
  role, startdate, enddate,
  out_type, delimiter
 EXECUTE reportrtl
 RECORD qual_list(
   1 last_activity_ind = i2
   1 entity_type_flag = i2
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_statuses_ind = i2
   1 status_cnt = i4
   1 statuses[*]
     2 status_cd = f8
   1 activity_cd = f8
   1 responsible_party = vc
   1 committee_id = f8
   1 organization_id = f8
   1 role_cd = f8
   1 start_date = dq8
   1 end_date = dq8
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
       3 revision_seq = i2
       3 amd_status_cd = f8
       3 activity_cd = f8
       3 sequence_nbr = i4
       3 entity_type_flag = i2
       3 responsible_party = c100
       3 completed_dt_tm = dq8
 )
 RECORD report_labels(
   1 m_s_end_before_start = vc
   1 m_s_start_date_must = vc
   1 m_s_end_date_must = vc
   1 m_s_at_least_one_c_o_r = vc
   1 m_s_only_one = vc
   1 m_s_at_least_one_status = vc
   1 m_s_at_least_one_prot = vc
   1 m_s_activity = vc
   1 m_s_prot_by_last_comp = vc
   1 m_s_prot_by_activity = vc
   1 m_s_between = vc
   1 m_s_rep_exec_time = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_amendment = vc
   1 m_s_amd_status_header = vc
   1 m_s_activity_header = vc
   1 m_s_completed_date_header = vc
   1 m_s_total_prots = vc
   1 m_s_end_of_rpt = vc
   1 m_s_revision = vc
   1 m_s_init_prot = vc
   1 m_s_unable_to_exec = vc
   1 m_s_no_prots = vc
   1 m_s_seperator = vc
   1 m_s_page = vc
   1 execution_timestamp = vc
   1 report_title = vc
   1 activity_title = vc
   1 date_title = vc
   1 delimiter_output = vc
   1 output_type = i4
 )
 EXECUTE ct_rpt_milestone_comp:dba "NL:",  $PROTOCOLS,  $PROTSTATUS,
  $ACTIVITY,  $COMMITTEE,  $ORG,
  $ROLE,  $STARTDATE,  $ENDDATE,
  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE ct_get_milestone_comp(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headprot_idsection(ncalc=i2) = f8 WITH protect
 DECLARE headprot_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection1(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headamd_idsection(ncalc=i2) = f8 WITH protect
 DECLARE headamd_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _remnprotocolmnemonic = i4 WITH noconstant(1), protect
 DECLARE _remnamendment = i4 WITH noconstant(1), protect
 DECLARE _remnamendmentstatus = i4 WITH noconstant(1), protect
 DECLARE _remnactivity = i4 WITH noconstant(1), protect
 DECLARE _remncompleteddate = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remprotocol_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _remamendment = i4 WITH noconstant(1), protect
 DECLARE _remamd_status = i4 WITH noconstant(1), protect
 DECLARE _remactivity = i4 WITH noconstant(1), protect
 DECLARE _remcompleted_date = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remntotalprotocols = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE tmp_activity = vc WITH protect
 DECLARE tmp_act_date = vc WITH protect
 DECLARE tmp_amd_desc = vc WITH protect
 DECLARE p_amendment_status_disp = vc WITH protect
 DECLARE p_prot_role_disp = vc WITH protect
 DECLARE p_activity_disp = vc WITH protect
 DECLARE prim_mnemonic = vc WITH protect
 DECLARE amd_cnt = i4 WITH protect
 DECLARE amd_id = f8 WITH protect
 DECLARE prot_cnt = i4 WITH protect
 DECLARE label_page = vc WITH protect
 SUBROUTINE ct_get_milestone_comp(dummy)
   SELECT
    prot_id = results->protocols[d.seq].prot_master_id, prim_mnemonic = substring(1,20,results->
     protocols[d.seq].primary_mnemonic), amd_id = results->protocols[d.seq].amendments[d1.seq].
    prot_amendment_id,
    amd_nbr = results->protocols[d.seq].amendments[d1.seq].amendment_nbr, rev_seq = results->
    protocols[d.seq].amendments[d1.seq].revision_seq
    FROM (dummyt d  WITH seq = value(size(results->protocols,5))),
     (dummyt d1  WITH seq = 1)
    PLAN (d
     WHERE maxrec(d1,size(results->protocols[d.seq].amendments,5)))
     JOIN (d1)
    ORDER BY prim_mnemonic, prot_id, amd_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _fenddetail = (_fenddetail
      - footpagesection(rpt_calcheight)), prot_cnt = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), dummy_val = headpagesection1(
      rpt_render)
    HEAD prim_mnemonic
     row + 0
    HEAD prot_id
     prot_cnt = (prot_cnt+ 1), amd_cnt = 0
     IF (((row+ size(results->protocols[d.seq].amendments,5)) > 53)
      AND size(results->protocols[d.seq].amendments,5) < 53)
      BREAK
     ENDIF
     tmp_prot = substring(1,20,results->protocols[d.seq].primary_mnemonic)
    HEAD amd_id
     IF ((results->protocols[d.seq].amendments[d1.seq].amendment_nbr > 0))
      tmp_amd_desc = concat(report_labels->m_s_amendment,trim(cnvtstring(results->protocols[d.seq].
         amendments[d1.seq].amendment_nbr)))
     ELSE
      tmp_amd_desc = report_labels->m_s_init_prot
     ENDIF
     IF ((results->protocols[d.seq].amendments[d1.seq].revision_ind=1))
      tmp_amd_desc = substring(1,22,concat(tmp_amd_desc," - Rev ",results->protocols[d.seq].
        amendments[d1.seq].revision_nbr_txt))
     ENDIF
     tmp_status = uar_get_code_display(results->protocols[d.seq].amendments[d1.seq].amd_status_cd)
    DETAIL
     amd_cnt = (amd_cnt+ 1), amd_id = 0, tmp_activity = concat(trim(uar_get_code_display(results->
        protocols[d.seq].amendments[d1.seq].activity_cd))," ",results->protocols[d.seq].amendments[d1
      .seq].responsible_party)
     IF ((results->protocols[d.seq].amendments[d1.seq].completed_dt_tm < cnvtdatetime(
      "31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].amendments[d1.seq].completed_dt_tm > 0))
      tmp_act_date = format(results->protocols[d.seq].amendments[d1.seq].completed_dt_tm,"@SHORTDATE"
       )
     ELSE
      tmp_act_date = "   --"
     ENDIF
     IF ((amd_id=results->protocols[d.seq].amendments[d1.seq].prot_amendment_id))
      tmp_amd_desc = "", tmp_status = ""
     ELSE
      amd_id = results->protocols[d.seq].amendments[d1.seq].prot_amendment_id
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
    FOOT  amd_id
     row + 0
    FOOT  prot_id
     row + 0
    FOOT  prim_mnemonic
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, label_page = concat(build2(report_labels->m_s_page,
       trim(cnvtstring(curpage),3))),
     dummy_val = footpagesection(rpt_render), _yoffset = _yhold
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
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.600000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_nprotocolmnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_namendment = f8 WITH noconstant(0.0), private
   DECLARE drawheight_namendmentstatus = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nactivity = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ncompleteddate = f8 WITH noconstant(0.0), private
   DECLARE __ntitle1 = vc WITH noconstant(build2(report_labels->report_title,char(0))), protect
   DECLARE __nprotocolmnemonic = vc WITH noconstant(build2(report_labels->m_s_prot_mnemonic_header,
     char(0))), protect
   DECLARE __namendment = vc WITH noconstant(build2(report_labels->m_s_amendment,char(0))), protect
   DECLARE __namendmentstatus = vc WITH noconstant(build2(report_labels->m_s_amd_status_header,char(0
      ))), protect
   DECLARE __nactivity = vc WITH noconstant(build2(report_labels->m_s_activity_header,char(0))),
   protect
   DECLARE __ncompleteddate = vc WITH noconstant(build2(report_labels->m_s_completed_date_header,char
     (0))), protect
   DECLARE __nactivity_by = vc WITH noconstant(build2(report_labels->activity_title,char(0))),
   protect
   DECLARE __ndate_title = vc WITH noconstant(build2(report_labels->date_title,char(0))), protect
   IF (bcontinue=0)
    SET _remnprotocolmnemonic = 1
    SET _remnamendment = 1
    SET _remnamendmentstatus = 1
    SET _remnactivity = 1
    SET _remncompleteddate = 1
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
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
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
     SET _remnprotocolmnemonic = (_remnprotocolmnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remnprotocolmnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remnprotocolmnemonic)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnamendment = _remnamendment
   IF (_remnamendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnamendment,((size(
        __namendment) - _remnamendment)+ 1),__namendment)))
    SET drawheight_namendment = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnamendment = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnamendment,((size(__namendment) -
       _remnamendment)+ 1),__namendment)))))
     SET _remnamendment = (_remnamendment+ rptsd->m_drawlength)
    ELSE
     SET _remnamendment = 0
    ENDIF
    SET growsum = (growsum+ _remnamendment)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.052
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
     SET _remnamendmentstatus = (_remnamendmentstatus+ rptsd->m_drawlength)
    ELSE
     SET _remnamendmentstatus = 0
    ENDIF
    SET growsum = (growsum+ _remnamendmentstatus)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnactivity = _remnactivity
   IF (_remnactivity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnactivity,((size(
        __nactivity) - _remnactivity)+ 1),__nactivity)))
    SET drawheight_nactivity = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnactivity = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnactivity,((size(__nactivity) -
       _remnactivity)+ 1),__nactivity)))))
     SET _remnactivity = (_remnactivity+ rptsd->m_drawlength)
    ELSE
     SET _remnactivity = 0
    ENDIF
    SET growsum = (growsum+ _remnactivity)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremncompleteddate = _remncompleteddate
   IF (_remncompleteddate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remncompleteddate,((size(
        __ncompleteddate) - _remncompleteddate)+ 1),__ncompleteddate)))
    SET drawheight_ncompleteddate = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remncompleteddate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remncompleteddate,((size(__ncompleteddate
        ) - _remncompleteddate)+ 1),__ncompleteddate)))))
     SET _remncompleteddate = (_remncompleteddate+ rptsd->m_drawlength)
    ELSE
     SET _remncompleteddate = 0
    ENDIF
    SET growsum = (growsum+ _remncompleteddate)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ntitle1)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = drawheight_nprotocolmnemonic
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
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.125)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = drawheight_namendment
   IF (ncalc=rpt_render
    AND _holdremnamendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnamendment,((size(
        __namendment) - _holdremnamendment)+ 1),__namendment)))
   ELSE
    SET _remnamendment = _holdremnamendment
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.052
   SET rptsd->m_height = drawheight_namendmentstatus
   IF (ncalc=rpt_render
    AND _holdremnamendmentstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnamendmentstatus,(
       (size(__namendmentstatus) - _holdremnamendmentstatus)+ 1),__namendmentstatus)))
   ELSE
    SET _remnamendmentstatus = _holdremnamendmentstatus
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = drawheight_nactivity
   IF (ncalc=rpt_render
    AND _holdremnactivity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnactivity,((size(
        __nactivity) - _holdremnactivity)+ 1),__nactivity)))
   ELSE
    SET _remnactivity = _holdremnactivity
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = drawheight_ncompleteddate
   IF (ncalc=rpt_render
    AND _holdremncompleteddate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremncompleteddate,((
       size(__ncompleteddate) - _holdremncompleteddate)+ 1),__ncompleteddate)))
   ELSE
    SET _remncompleteddate = _holdremncompleteddate
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.344)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.219
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nactivity_by)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.563)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ndate_title)
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
 SUBROUTINE headprot_idsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprot_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headprot_idsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.180000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.110),(offsetx+ 10.000),(offsety
     + 0.110))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headamd_idsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headamd_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headamd_idsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
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
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_protocol_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amendment = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amd_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_activity = f8 WITH noconstant(0.0), private
   DECLARE drawheight_completed_date = f8 WITH noconstant(0.0), private
   DECLARE __protocol_mnemonic = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __amendment = vc WITH noconstant(build2(tmp_amd_desc,char(0))), protect
   DECLARE __amd_status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __activity = vc WITH noconstant(build2(tmp_activity,char(0))), protect
   DECLARE __completed_date = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   IF (bcontinue=0)
    SET _remprotocol_mnemonic = 1
    SET _remamendment = 1
    SET _remamd_status = 1
    SET _remactivity = 1
    SET _remcompleted_date = 1
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
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 0.938
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
     SET _remprotocol_mnemonic = (_remprotocol_mnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remprotocol_mnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remprotocol_mnemonic)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.813)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremamendment = _remamendment
   IF (_remamendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remamendment,((size(
        __amendment) - _remamendment)+ 1),__amendment)))
    SET drawheight_amendment = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remamendment = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remamendment,((size(__amendment) -
       _remamendment)+ 1),__amendment)))))
     SET _remamendment = (_remamendment+ rptsd->m_drawlength)
    ELSE
     SET _remamendment = 0
    ENDIF
    SET growsum = (growsum+ _remamendment)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.563
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
     SET _remamd_status = (_remamd_status+ rptsd->m_drawlength)
    ELSE
     SET _remamd_status = 0
    ENDIF
    SET growsum = (growsum+ _remamd_status)
   ENDIF
   SET rptsd->m_flags = 37
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremactivity = _remactivity
   IF (_remactivity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remactivity,((size(
        __activity) - _remactivity)+ 1),__activity)))
    SET drawheight_activity = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remactivity = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remactivity,((size(__activity) -
       _remactivity)+ 1),__activity)))))
     SET _remactivity = (_remactivity+ rptsd->m_drawlength)
    ELSE
     SET _remactivity = 0
    ENDIF
    SET growsum = (growsum+ _remactivity)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcompleted_date = _remcompleted_date
   IF (_remcompleted_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcompleted_date,((size(
        __completed_date) - _remcompleted_date)+ 1),__completed_date)))
    SET drawheight_completed_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcompleted_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcompleted_date,((size(__completed_date
        ) - _remcompleted_date)+ 1),__completed_date)))))
     SET _remcompleted_date = (_remcompleted_date+ rptsd->m_drawlength)
    ELSE
     SET _remcompleted_date = 0
    ENDIF
    SET growsum = (growsum+ _remcompleted_date)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = drawheight_protocol_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprotocol_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprotocol_mnemonic,
       ((size(__protocol_mnemonic) - _holdremprotocol_mnemonic)+ 1),__protocol_mnemonic)))
   ELSE
    SET _remprotocol_mnemonic = _holdremprotocol_mnemonic
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.813)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = drawheight_amendment
   IF (ncalc=rpt_render
    AND _holdremamendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamendment,((size(
        __amendment) - _holdremamendment)+ 1),__amendment)))
   ELSE
    SET _remamendment = _holdremamendment
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = drawheight_amd_status
   IF (ncalc=rpt_render
    AND _holdremamd_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamd_status,((size(
        __amd_status) - _holdremamd_status)+ 1),__amd_status)))
   ELSE
    SET _remamd_status = _holdremamd_status
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.250)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = drawheight_activity
   IF (ncalc=rpt_render
    AND _holdremactivity > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremactivity,((size(
        __activity) - _holdremactivity)+ 1),__activity)))
   ELSE
    SET _remactivity = _holdremactivity
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_completed_date
   IF (ncalc=rpt_render
    AND _holdremcompleted_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcompleted_date,((
       size(__completed_date) - _holdremcompleted_date)+ 1),__completed_date)))
   ELSE
    SET _remcompleted_date = _holdremcompleted_date
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
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.560000), private
   DECLARE __execution_time = vc WITH noconstant(build2(report_labels->execution_timestamp,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 10.500
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__execution_time)
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.438)
    SET rptsd->m_width = 1.302
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(label_page,char(0)))
    SET _yoffset = (offsety+ sectionheight)
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
   DECLARE drawheight_ntotalprotocols = f8 WITH noconstant(0.0), private
   DECLARE __ntotalprotocols = vc WITH noconstant(build2(report_labels->m_s_total_prots,char(0))),
   protect
   IF (bcontinue=0)
    SET _remntotalprotocols = 1
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
    SET rptsd->m_y = (offsety+ 0.198)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 1.125
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
     SET _remntotalprotocols = (_remntotalprotocols+ rptsd->m_drawlength)
    ELSE
     SET _remntotalprotocols = 0
    ENDIF
    SET growsum = (growsum+ _remntotalprotocols)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.198)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_ntotalprotocols
   IF (ncalc=rpt_render
    AND _holdremntotalprotocols > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntotalprotocols,((
       size(__ntotalprotocols) - _holdremntotalprotocols)+ 1),__ntotalprotocols)))
   ELSE
    SET _remntotalprotocols = _holdremntotalprotocols
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.198)
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.271
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prot_cnt,char(0)))
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
   SET rptreport->m_reportname = "CT_RPT_MILESTONE_COMP_LO"
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
 END ;Subroutine
 IF (((size(results->protocols,5)=0) OR (size(results->messages,5) > 0)) )
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, report_labels->report_title, row + 1,
    col 0, report_labels->activity_title, row + 1,
    col 0, report_labels->execution_timestamp
    IF (size(results->messages,5) > 0)
     row + 2, col 0, report_labels->m_s_unable_to_exec
     FOR (idx = 1 TO size(results->messages,5))
       tempstr = results->messages[idx].text, row + 1, col 0,
       tempstr
     ENDFOR
    ELSE
     row + 2, col 0, report_labels->m_s_no_prots
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((report_labels->output_type=1))
  SELECT INTO  $OUTDEV
   prot_id = results->protocols[d.seq].prot_master_id, prim_mnemonic = substring(1,20,results->
    protocols[d.seq].primary_mnemonic), amd_id = results->protocols[d.seq].amendments[d1.seq].
   prot_amendment_id,
   amd_nbr = results->protocols[d.seq].amendments[d1.seq].amendment_nbr, rev_seq = results->
   protocols[d.seq].amendments[d1.seq].revision_seq
   FROM (dummyt d  WITH seq = value(size(results->protocols,5))),
    (dummyt d1  WITH seq = 1)
   PLAN (d
    WHERE maxrec(d1,size(results->protocols[d.seq].amendments,5)))
    JOIN (d1)
   ORDER BY amd_nbr, rev_seq
   HEAD REPORT
    col 0, report_labels->report_title, row + 1,
    col 0, report_labels->activity_title, row + 1,
    col 0, report_labels->date_title, row + 1,
    col 0, report_labels->execution_timestamp, row + 1,
    tempstr = concat(report_labels->m_s_prot_mnemonic_header,report_labels->delimiter_output,
     report_labels->m_s_amendment,report_labels->delimiter_output,report_labels->
     m_s_amd_status_header,
     report_labels->delimiter_output,report_labels->m_s_activity_header,report_labels->
     delimiter_output,report_labels->m_s_completed_date_header), col 0, tempstr,
    row + 1, prot_cnt = 0
   HEAD prot_id
    prot_cnt = (prot_cnt+ 1), tmp_prot = results->protocols[d.seq].primary_mnemonic, tmp_prot =
    concat('"',trim(tmp_prot,3),'"')
   HEAD amd_id
    IF ((results->protocols[d.seq].amendments[d1.seq].amendment_nbr > 0))
     tmp_amd_desc = concat(report_labels->m_s_amendment," ",trim(cnvtstring(results->protocols[d.seq]
        .amendments[d1.seq].amendment_nbr)))
    ELSE
     tmp_amd_desc = report_labels->m_s_init_prot
    ENDIF
    IF ((results->protocols[d.seq].amendments[d1.seq].revision_ind=1))
     tmp_amd_desc = concat(tmp_amd_desc," ",report_labels->m_s_seperator," ",report_labels->
      m_s_revision,
      " ",results->protocols[d.seq].amendments[d1.seq].revision_nbr_txt)
    ENDIF
    tmp_status = uar_get_code_display(results->protocols[d.seq].amendments[d1.seq].amd_status_cd),
    tmp_amd_desc = concat('"',trim(tmp_amd_desc,3),'"'), tmp_status = concat('"',trim(tmp_status,3),
     '"')
   DETAIL
    amd_cnt = (amd_cnt+ 1), amd_id = 0, tmp_activity = concat(trim(uar_get_code_display(results->
       protocols[d.seq].amendments[d1.seq].activity_cd))," ",results->protocols[d.seq].amendments[d1
     .seq].responsible_party)
    IF ((results->protocols[d.seq].amendments[d1.seq].completed_dt_tm < cnvtdatetime(
     "31-DEC-2100 00:00:00"))
     AND (results->protocols[d.seq].amendments[d1.seq].completed_dt_tm > 0))
     tmp_act_date = format(results->protocols[d.seq].amendments[d1.seq].completed_dt_tm,"@SHORTDATE")
    ELSE
     tmp_act_date = ""
    ENDIF
    tmp_activity = concat('"',trim(tmp_activity,3),'"'), tmp_act_date = concat('"',trim(tmp_act_date,
      3),'"'), tempstr = concat(tmp_prot,report_labels->delimiter_output,tmp_amd_desc,report_labels->
     delimiter_output,tmp_status,
     report_labels->delimiter_output,tmp_activity,report_labels->delimiter_output,tmp_act_date),
    col 0, tempstr, row + 1
   FOOT REPORT
    row + 1, tempstr = concat(report_labels->m_s_total_prots," ",trim(cnvtstring(prot_cnt))), col 0,
    tempstr, row + 2, col 0,
    report_labels->m_s_end_of_rpt
   WITH format = crstream, formfeed = none, maxcol = 1500,
    nocounter
  ;end select
 ELSE
  CALL initializereport(0)
  CALL ct_get_milestone_comp(0)
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "001"
 SET mod_date = "December 14, 2017"
END GO
