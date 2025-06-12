CREATE PROGRAM ct_rpt_activation_summary_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Activation Date Qualification" = 0,
  "Start Date" = curdate,
  "End Date" = "CURDATE",
  "Order By" = 0,
  "Sort Order" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, datequal, startdate,
  enddate, orderby, sortorder,
  out_type, delimiter
 EXECUTE reportrtl
 RECORD protlist(
   1 protocol_cnt = i2
   1 protocols[*]
     2 prot_master_id = f8
 )
 RECORD report_labels(
   1 m_s_rpt_title = vc
   1 m_s_before_date = vc
   1 m_s_after_date = vc
   1 m_s_between_date = vc
   1 m_s_sorted_by_init_date = vc
   1 m_s_sorted_by_amd_cnt = vc
   1 m_s_sorted_by_rev_cnt = vc
   1 m_s_sorted_by_totals = vc
   1 m_s_sorted_by_prot = vc
   1 m_s_rep_exec_time = vc
   1 m_s_init_act_header = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_new_prot_header = vc
   1 m_s_new_amds_header = vc
   1 m_s_new_revs_header = vc
   1 m_s_totals_per_prot_header = vc
   1 m_s_totals = vc
   1 m_s_end_of_rpt = vc
   1 m_s_criteria_not_met = vc
   1 m_s_yes = vc
   1 m_s_no = vc
   1 m_s_sorted_by = vc
   1 m_s_date_title = vc
   1 date_format = vc
   1 m_s_page = vc
   1 execution_timestamp = vc
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 init_activation_date = dq8
     2 new_protocol_ind = i2
     2 new_amd_cnt = i4
     2 new_rev_cnt = i4
     2 totals_per_protocol = i4
 )
 RECORD reportlist(
   1 date_qual = i2
   1 start_date = dq8
   1 end_date = dq8
   1 sort_order = i2
   1 sorting_field = vc
   1 output_type = i2
   1 delimiter_output = vc
 )
 EXECUTE ct_rpt_prot_activation_summary "NL:",  $DATEQUAL,  $STARTDATE,
  $ENDDATE,  $ORDERBY,  $SORTORDER,
  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE ct_get_report_protactivation(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreport_labels_sortingfieldsection(ncalc=i2) = f8 WITH protect
 DECLARE footreport_labels_sortingfieldsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportsection(ncalc=i2) = f8 WITH protect
 DECLARE footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _remninitialactivationdate = i4 WITH noconstant(1), protect
 DECLARE _remnprotocolmnemonic = i4 WITH noconstant(1), protect
 DECLARE _remnnewprotocol = i4 WITH noconstant(1), protect
 DECLARE _remnnewamendments = i4 WITH noconstant(1), protect
 DECLARE _remnnewrevisions = i4 WITH noconstant(1), protect
 DECLARE _remntotals = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _pen20s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c255 = i4 WITH noconstant(0), protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_init_act_date = vc WITH protect
 DECLARE new_prot_total = i4 WITH protect
 DECLARE tmp_new_prot = vc WITH protect
 DECLARE tmp_new_amds = vc WITH protect
 DECLARE tmp_new_revs = vc WITH protect
 DECLARE tmp_totals = vc WITH protect
 DECLARE new_amd_total = i4 WITH protect
 DECLARE new_rev_total = i4 WITH protect
 DECLARE count = i4 WITH protect
 DECLARE prot_cnt = i2 WITH protect
 DECLARE label_page = vc WITH protect
 SUBROUTINE ct_get_report_protactivation(dummy)
   SELECT
    IF ((reportlist->sort_order=0))
     reportlist_date_qual = reportlist->date_qual, reportlist_start_date = reportlist->start_date,
     reportlist_end_date = reportlist->end_date,
     protocols_primary_mnemonic = results->protocols[d.seq].primary_mnemonic,
     protocols_init_activation_date = results->protocols[d.seq].init_activation_date,
     protocols_new_protocol_ind = results->protocols[d.seq].new_protocol_ind,
     protocols_new_amd_cnt = results->protocols[d.seq].new_amd_cnt, protocols_new_rev_cnt = results->
     protocols[d.seq].new_rev_cnt, protocols_totals_per_protocol = results->protocols[d.seq].
     totals_per_protocol,
     report_labels_sortingfield = parser(reportlist->sorting_field), protocols_prot_master_id =
     results->protocols[d.seq].prot_master_id
     FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
     PLAN (d)
     ORDER BY report_labels_sortingfield, protocols_prot_master_id
    ELSE
     reportlist_date_qual = reportlist->date_qual, reportlist_start_date = reportlist->start_date,
     reportlist_end_date = reportlist->end_date,
     protocols_primary_mnemonic = results->protocols[d.seq].primary_mnemonic,
     protocols_init_activation_date = results->protocols[d.seq].init_activation_date,
     protocols_new_protocol_ind = results->protocols[d.seq].new_protocol_ind,
     protocols_new_amd_cnt = results->protocols[d.seq].new_amd_cnt, protocols_new_rev_cnt = results->
     protocols[d.seq].new_rev_cnt, protocols_totals_per_protocol = results->protocols[d.seq].
     totals_per_protocol,
     report_labels_sortingfield = parser(reportlist->sorting_field), protocols_prot_master_id =
     results->protocols[d.seq].prot_master_id
     FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
     PLAN (d)
     ORDER BY report_labels_sortingfield DESC, protocols_prot_master_id
    ENDIF
    reportlist_date_qual = reportlist->date_qual, reportlist_start_date = reportlist->start_date,
    reportlist_end_date = reportlist->end_date,
    protocols_primary_mnemonic = results->protocols[d.seq].primary_mnemonic,
    protocols_init_activation_date = results->protocols[d.seq].init_activation_date,
    protocols_new_protocol_ind = results->protocols[d.seq].new_protocol_ind,
    protocols_new_amd_cnt = results->protocols[d.seq].new_amd_cnt, protocols_new_rev_cnt = results->
    protocols[d.seq].new_rev_cnt, protocols_totals_per_protocol = results->protocols[d.seq].
    totals_per_protocol,
    report_labels_sortingfield = parser(reportlist->sorting_field), protocols_prot_master_id =
    results->protocols[d.seq].prot_master_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY report_labels_sortingfield, protocols_prot_master_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _fenddetail = (_fenddetail
      - footpagesection(rpt_calcheight)), _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render), prot_cnt = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection)
    HEAD report_labels_sortingfield
     row + 0
    HEAD protocols_prot_master_id
     prot_cnt = (prot_cnt+ 1)
    DETAIL
     tmp_prot = results->protocols[d.seq].primary_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = "   --"
     ENDIF
     IF ((results->protocols[d.seq].new_protocol_ind=1))
      new_prot_total = (new_prot_total+ 1), tmp_new_prot = report_labels->m_s_yes
     ELSE
      tmp_new_prot = report_labels->m_s_no
     ENDIF
     tmp_new_amds = format(results->protocols[d.seq].new_amd_cnt,"#####"), tmp_new_revs = format(
      results->protocols[d.seq].new_rev_cnt,"#####"), tmp_totals = format(results->protocols[d.seq].
      totals_per_protocol,"#####"),
     new_amd_total = (new_amd_total+ results->protocols[d.seq].new_amd_cnt), new_rev_total = (
     new_rev_total+ results->protocols[d.seq].new_rev_cnt), _fdrawheight = detailsection(
      rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  protocols_prot_master_id
     row + 0
    FOOT  report_labels_sortingfield
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, label_page = concat(build2(report_labels->m_s_page,
       trim(cnvtstring(curpage),3))),
     dummy_val = footpagesection(rpt_render), _yoffset = _yhold
    FOOT REPORT
     _fdrawheight = footreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportsection(rpt_render), tmp_prot = format(size(results->protocols,5),"#####"),
     tmp_new_prot = format(new_prot_total,"#####"),
     tmp_new_amds = format(new_amd_total,"#####"), tmp_new_revs = format(new_rev_total,"#####"),
     tempstr = report_labels->m_s_totals
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
   DECLARE sectionheight = f8 WITH noconstant(1.690000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_ninitialactivationdate = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nprotocolmnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nnewprotocol = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nnewamendments = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nnewrevisions = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ntotals = f8 WITH noconstant(0.0), private
   DECLARE __ninitialactivationdate = vc WITH noconstant(build2(report_labels->m_s_init_act_header,
     char(0))), protect
   DECLARE __nprotocolmnemonic = vc WITH noconstant(build2(report_labels->m_s_prot_mnemonic_header,
     char(0))), protect
   DECLARE __nnewprotocol = vc WITH noconstant(build2(report_labels->m_s_new_prot_header,char(0))),
   protect
   DECLARE __nnewamendments = vc WITH noconstant(build2(report_labels->m_s_new_amds_header,char(0))),
   protect
   DECLARE __nnewrevisions = vc WITH noconstant(build2(report_labels->m_s_new_revs_header,char(0))),
   protect
   DECLARE __ntotals = vc WITH noconstant(build2(report_labels->m_s_totals_per_prot_header,char(0))),
   protect
   DECLARE __nsortedtitle = vc WITH noconstant(build2(report_labels->m_s_sorted_by,char(0))), protect
   DECLARE __nreporttitle = vc WITH noconstant(build2(report_labels->m_s_rpt_title,char(0))), protect
   DECLARE __ndatetitle = vc WITH noconstant(build2(report_labels->m_s_date_title,char(0))), protect
   IF (bcontinue=0)
    SET _remninitialactivationdate = 1
    SET _remnprotocolmnemonic = 1
    SET _remnnewprotocol = 1
    SET _remnnewamendments = 1
    SET _remnnewrevisions = 1
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
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.375)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
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
     SET _remninitialactivationdate = (_remninitialactivationdate+ rptsd->m_drawlength)
    ELSE
     SET _remninitialactivationdate = 0
    ENDIF
    SET growsum = (growsum+ _remninitialactivationdate)
   ENDIF
   SET rptsd->m_flags = 37
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.063)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.813)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnnewprotocol = _remnnewprotocol
   IF (_remnnewprotocol > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnnewprotocol,((size(
        __nnewprotocol) - _remnnewprotocol)+ 1),__nnewprotocol)))
    SET drawheight_nnewprotocol = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnnewprotocol = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnnewprotocol,((size(__nnewprotocol) -
       _remnnewprotocol)+ 1),__nnewprotocol)))))
     SET _remnnewprotocol = (_remnnewprotocol+ rptsd->m_drawlength)
    ELSE
     SET _remnnewprotocol = 0
    ENDIF
    SET growsum = (growsum+ _remnnewprotocol)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnnewamendments = _remnnewamendments
   IF (_remnnewamendments > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnnewamendments,((size(
        __nnewamendments) - _remnnewamendments)+ 1),__nnewamendments)))
    SET drawheight_nnewamendments = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnnewamendments = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnnewamendments,((size(__nnewamendments
        ) - _remnnewamendments)+ 1),__nnewamendments)))))
     SET _remnnewamendments = (_remnnewamendments+ rptsd->m_drawlength)
    ELSE
     SET _remnnewamendments = 0
    ENDIF
    SET growsum = (growsum+ _remnnewamendments)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.188)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnnewrevisions = _remnnewrevisions
   IF (_remnnewrevisions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnnewrevisions,((size(
        __nnewrevisions) - _remnnewrevisions)+ 1),__nnewrevisions)))
    SET drawheight_nnewrevisions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnnewrevisions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnnewrevisions,((size(__nnewrevisions)
        - _remnnewrevisions)+ 1),__nnewrevisions)))))
     SET _remnnewrevisions = (_remnnewrevisions+ rptsd->m_drawlength)
    ELSE
     SET _remnnewrevisions = 0
    ENDIF
    SET growsum = (growsum+ _remnnewrevisions)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
     SET _remntotals = (_remntotals+ rptsd->m_drawlength)
    ELSE
     SET _remntotals = 0
    ENDIF
    SET growsum = (growsum+ _remntotals)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.375)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = drawheight_ninitialactivationdate
   IF (ncalc=rpt_render
    AND _holdremninitialactivationdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremninitialactivationdate,((size(__ninitialactivationdate) -
       _holdremninitialactivationdate)+ 1),__ninitialactivationdate)))
   ELSE
    SET _remninitialactivationdate = _holdremninitialactivationdate
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.063)
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
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.813)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = drawheight_nnewprotocol
   IF (ncalc=rpt_render
    AND _holdremnnewprotocol > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnnewprotocol,((
       size(__nnewprotocol) - _holdremnnewprotocol)+ 1),__nnewprotocol)))
   ELSE
    SET _remnnewprotocol = _holdremnnewprotocol
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_nnewamendments
   IF (ncalc=rpt_render
    AND _holdremnnewamendments > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnnewamendments,((
       size(__nnewamendments) - _holdremnnewamendments)+ 1),__nnewamendments)))
   ELSE
    SET _remnnewamendments = _holdremnnewamendments
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.188)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = drawheight_nnewrevisions
   IF (ncalc=rpt_render
    AND _holdremnnewrevisions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnnewrevisions,((
       size(__nnewrevisions) - _holdremnnewrevisions)+ 1),__nnewrevisions)))
   ELSE
    SET _remnnewrevisions = _holdremnnewrevisions
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 1.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = drawheight_ntotals
   IF (ncalc=rpt_render
    AND _holdremntotals > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntotals,((size(
        __ntotals) - _holdremntotals)+ 1),__ntotals)))
   ELSE
    SET _remntotals = _holdremntotals
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.625)
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nsortedtitle)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nreporttitle)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.313)
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 5.000
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ndatetitle)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen20s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.625),(offsetx+ 10.000),(offsety
     + 1.625))
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
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c255)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_init_act_date,char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_prot,char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_new_prot,char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_new_amds,char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 7.188)
    SET rptsd->m_width = 0.844
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_new_revs,char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 8.750)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_totals,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreport_labels_sortingfieldsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreport_labels_sortingfieldsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreport_labels_sortingfieldsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   DECLARE __nreporttimestamp = vc WITH noconstant(build2(report_labels->execution_timestamp,char(0))
    ), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 10.500
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nreporttimestamp)
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(label_page,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.770000), private
   DECLARE __ntotals = vc WITH noconstant(build2(report_labels->m_s_totals,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ntotals)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prot_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(new_prot_total,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(new_amd_total,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 7.188)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(new_rev_total,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.255),(offsetx+ 10.000),(offsety
     + 0.255))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_ACTIVATION_SUMMARY_LO"
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
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
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
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_rgbcolor = rpt_red
   SET _pen14s0c255 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (size(results->protocols,5)=0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, report_labels->m_s_rpt_title, row + 1,
    col 0, report_labels->execution_timestamp, row + 2,
    col 0, report_labels->m_s_criteria_not_met, row + 2,
    col 0, report_labels->m_s_date_title, row + 2
   WITH nocounter
  ;end select
 ELSEIF ((reportlist->output_type=1))
  IF ((reportlist->sort_order=0))
   SELECT INTO  $OUTDEV
    prot_mnemonic = substring(1,200,results->protocols[d.seq].primary_mnemonic), prot_id = results->
    protocols[d.seq].prot_master_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    ORDER BY parser(reportlist->sorting_field)
    HEAD REPORT
     col 0, report_labels->m_s_rpt_title, row + 1,
     col 0, report_labels->m_s_date_title, row + 1,
     col 0, report_labels->m_s_sorted_by, row + 1,
     col 0, report_labels->execution_timestamp, row + 1,
     tempstr = concat(report_labels->m_s_init_act_header,reportlist->delimiter_output,report_labels->
      m_s_prot_mnemonic_header,reportlist->delimiter_output,report_labels->m_s_new_prot_header,
      reportlist->delimiter_output,report_labels->m_s_new_amds_header,reportlist->delimiter_output,
      report_labels->m_s_new_revs_header,reportlist->delimiter_output,
      report_labels->m_s_totals_per_prot_header), col 0, tempstr,
     row + 1, new_prot_total = 0, new_amd_total = 0,
     new_rev_total = 0, prot_cnt = 0
    HEAD prot_id
     prot_cnt = (prot_cnt+ 1)
    DETAIL
     tmp_prot = results->protocols[d.seq].primary_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = ""
     ENDIF
     IF ((results->protocols[d.seq].new_protocol_ind=1))
      new_prot_total = (new_prot_total+ 1), tmp_new_prot = report_labels->m_s_yes
     ELSE
      tmp_new_prot = report_labels->m_s_no
     ENDIF
     tmp_new_amds = trim(cnvtstring(results->protocols[d.seq].new_amd_cnt),3), tmp_new_revs = trim(
      cnvtstring(results->protocols[d.seq].new_rev_cnt),3), tmp_totals = trim(cnvtstring(results->
       protocols[d.seq].totals_per_protocol),3),
     new_amd_total = (new_amd_total+ results->protocols[d.seq].new_amd_cnt), new_rev_total = (
     new_rev_total+ results->protocols[d.seq].new_rev_cnt), tmp_init_act_date = concat('"',trim(
       tmp_init_act_date,3),'"'),
     tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_new_prot = concat('"',trim(tmp_new_prot,3),'"'),
     tmp_new_amds = concat('"',trim(tmp_new_amds,3),'"'),
     tmp_new_revs = concat('"',trim(tmp_new_revs,3),'"'), tmp_totals = concat('"',trim(tmp_totals,3),
      '"'), tempstr = concat(tmp_init_act_date,reportlist->delimiter_output,tmp_prot,reportlist->
      delimiter_output,tmp_new_prot,
      reportlist->delimiter_output,tmp_new_amds,reportlist->delimiter_output,tmp_new_revs,reportlist
      ->delimiter_output,
      tmp_totals),
     col 0, tempstr, row + 1
    FOOT REPORT
     row + 1, tmp_prot = concat('"',trim(cnvtstring(size(results->protocols,5)),3),'"'), tmp_new_prot
      = concat('"',trim(cnvtstring(new_prot_total),3),'"'),
     tmp_new_amds = concat('"',trim(cnvtstring(new_amd_total),3),'"'), tmp_new_revs = concat('"',trim
      (cnvtstring(new_rev_total),3),'"'), tempstr = concat('"',report_labels->m_s_totals,'"'),
     tempstr = concat(tempstr,reportlist->delimiter_output,tmp_prot,reportlist->delimiter_output,
      tmp_new_prot,
      reportlist->delimiter_output,tmp_new_amds,reportlist->delimiter_output,tmp_new_revs), col 0,
     tempstr,
     row + 2, col 0, report_labels->m_s_end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    prot_mnemonic = results->protocols[d.seq].primary_mnemonic, prot_id = results->protocols[d.seq].
    prot_master_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    ORDER BY reportlist->sorting_field DESC
    HEAD REPORT
     col 0, report_labels->m_s_rpt_title, row + 1,
     col 0, report_labels->m_s_date_title, row + 1,
     col 0, report_labels->m_s_sorted_by, row + 1,
     col 0, report_labels->execution_timestamp, row + 1,
     tempstr = concat(report_labels->m_s_init_act_header,reportlist->delimiter_output,report_labels->
      m_s_prot_mnemonic_header,reportlist->delimiter_output,report_labels->m_s_new_prot_header,
      reportlist->delimiter_output,report_labels->m_s_new_amds_header,reportlist->delimiter_output,
      report_labels->m_s_new_revs_header,reportlist->delimiter_output,
      report_labels->m_s_totals_per_prot_header), col 0, tempstr,
     row + 1, new_prot_total = 0, new_amd_total = 0,
     new_rev_total = 0, prot_cnt = 0
    HEAD prot_id
     prot_cnt = (prot_cnt+ 1)
    DETAIL
     tmp_prot = results->protocols[d.seq].primary_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = ""
     ENDIF
     IF ((results->protocols[d.seq].new_protocol_ind=1))
      new_prot_total = (new_prot_total+ 1), tmp_new_prot = report_labels->m_s_yes
     ELSE
      tmp_new_prot = report_labels->m_s_no
     ENDIF
     tmp_new_amds = trim(cnvtstring(results->protocols[d.seq].new_amd_cnt),3), tmp_new_revs = trim(
      cnvtstring(results->protocols[d.seq].new_rev_cnt),3), tmp_totals = trim(cnvtstring(results->
       protocols[d.seq].totals_per_protocol),3),
     new_amd_total = (new_amd_total+ results->protocols[d.seq].new_amd_cnt), new_rev_total = (
     new_rev_total+ results->protocols[d.seq].new_rev_cnt), tmp_init_act_date = concat('"',trim(
       tmp_init_act_date,3),'"'),
     tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_new_prot = concat('"',trim(tmp_new_prot,3),'"'),
     tmp_new_amds = concat('"',trim(tmp_new_amds,3),'"'),
     tmp_new_revs = concat('"',trim(tmp_new_revs,3),'"'), tmp_totals = concat('"',trim(tmp_totals,3),
      '"'), tempstr = concat(tmp_init_act_date,reportlist->delimiter_output,tmp_prot,reportlist->
      delimiter_output,tmp_new_prot,
      reportlist->delimiter_output,tmp_new_amds,reportlist->delimiter_output,tmp_new_revs,reportlist
      ->delimiter_output,
      tmp_totals),
     col 0, tempstr, row + 1
    FOOT REPORT
     row + 1, tmp_prot = concat('"',trim(cnvtstring(size(results->protocols,5)),3),'"'), tmp_new_prot
      = concat('"',trim(cnvtstring(new_prot_total),3),'"'),
     tmp_new_amds = concat('"',trim(cnvtstring(new_amd_total),3),'"'), tmp_new_revs = concat('"',trim
      (cnvtstring(new_rev_total),3),'"'), tempstr = concat('"',report_labels->m_s_totals,'"'),
     tempstr = concat(tempstr,reportlist->delimiter_output,tmp_prot,reportlist->delimiter_output,
      tmp_new_prot,
      reportlist->delimiter_output,tmp_new_amds,reportlist->delimiter_output,tmp_new_revs), col 0,
     tempstr,
     row + 2, col 0, report_labels->m_s_end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ENDIF
 ELSE
  CALL initializereport(0)
  SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom)
  SET _fholdenddetail = _fenddetail
  CALL ct_get_report_protactivation(0)
  SET _fenddetail = _fholdenddetail
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "April 11, 2016"
END GO
