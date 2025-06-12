CREATE PROGRAM ct_rpt_prot_activation_date_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Activation Date Qualification" = 0,
  "Start Date" = curdate,
  "End Date" = curdate,
  "Order By" = 1,
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
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 init_activation_date = dq8
     2 amd_activation_date = dq8
     2 cur_amd_id = f8
     2 cur_amd_nbr = i4
     2 cur_revision_nbr_txt = vc
     2 cur_revision_ind = i2
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 prot_status_desc = c60
     2 prot_status_mean = c12
     2 primary_sponsor = c100
     2 amendments[*]
       3 prot_amendment_id = f8
       3 amd_activation_date = dq8
       3 amendment_nbr = i4
       3 revision_nbr_txt = vc
       3 revision_ind = i2
       3 revision_seq = i4
       3 amd_status_cd = f8
       3 amd_status_disp = c40
       3 amd_status_desc = c60
       3 amd_status_mean = c12
       3 primary_sponsor = c100
 )
 RECORD reportlist(
   1 date_qual = i2
   1 start_date = dq8
   1 end_date = dq8
   1 sort_by = vc
 )
 RECORD label(
   1 report_title = vc
   1 report_date_title = vc
   1 report_sort_title = vc
   1 init_act_header = vc
   1 prot_mnemonic_header = vc
   1 cur_prot_status_header = vc
   1 amendment = vc
   1 amd_act_date_header = vc
   1 amd_status_header = vc
   1 amd_sponsor_header = vc
   1 total_prots = vc
   1 total_new_prots = vc
   1 total_amds = vc
   1 total_revs = vc
   1 end_of_rpt = vc
   1 revision = vc
   1 end_before_start = vc
   1 no_prot = vc
   1 rep_exec_time = vc
   1 init_prot = vc
   1 rpt_page = vc
 )
 EXECUTE ct_rpt_prot_activation_date:dba "NL:",  $DATEQUAL,  $STARTDATE,
  $ENDDATE,  $ORDERBY,  $SORTORDER,
  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_protocol_data(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection_formatted(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection_formattedabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection_formatted(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection_formattedabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
 f8 WITH protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _reminit_act_date = i4 WITH noconstant(1), protect
 DECLARE _remprot_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _remcur_prot_status = i4 WITH noconstant(1), protect
 DECLARE _remamendment = i4 WITH noconstant(1), protect
 DECLARE _remamd_act_date = i4 WITH noconstant(1), protect
 DECLARE _remamd_status = i4 WITH noconstant(1), protect
 DECLARE _remamd_spon = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection_formatted = i2 WITH noconstant(0), protect
 DECLARE _remprimary_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _remprotocols_init_activation_date = i4 WITH noconstant(1), protect
 DECLARE _remprotocols_prot_status_disp = i4 WITH noconstant(1), protect
 DECLARE _remprotocols_cur_amd_nbr = i4 WITH noconstant(1), protect
 DECLARE _remtmp_sponsor = i4 WITH noconstant(1), protect
 DECLARE _remtmp_status = i4 WITH noconstant(1), protect
 DECLARE _remtmp_act_date = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection_formatted = i2 WITH noconstant(0), protect
 DECLARE _remlabel_total_prots = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total_new_prots = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total_amds = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total_revs = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _courier10b0 = i4 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _courier12b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE primary_mnemonic = vc WITH public
 DECLARE amd_cnt = i4 WITH protect
 DECLARE rev_cnt = i4 WITH protect
 DECLARE new_cnt = i4 WITH protect
 DECLARE prot_mnemonic = vc WITH protect
 DECLARE prot_id = f8 WITH protect
 DECLARE tmp_init_act_date = vc WITH protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_amd_desc = vc WITH protect
 DECLARE tmp_act_date = vc WITH protect
 DECLARE tmp_sponsor = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE tmp_prot_status = vc WITH protect
 DECLARE prot_cnt = i2 WITH protect
 DECLARE tempstr = vc WITH protect
 SUBROUTINE get_protocol_data(dummy)
   SELECT
    IF (( $SORTORDER=0))
     protocols_prot_master_id = results->protocols[d.seq].prot_master_id, protocols_primary_mnemonic
      = cnvtlower(results->protocols[d.seq].primary_mnemonic), protocols_init_activation_date =
     results->protocols[d.seq].init_activation_date,
     protocols_amd_activation_date = results->protocols[d.seq].amd_activation_date,
     protocols_cur_amd_id = results->protocols[d.seq].cur_amd_id, protocols_cur_amd_nbr = results->
     protocols[d.seq].cur_amd_nbr,
     protocols_cur_revision_nbr_txt = substring(1,30,results->protocols[d.seq].cur_revision_nbr_txt),
     protocols_prot_status_disp = results->protocols[d.seq].prot_status_disp,
     protocols_prot_status_desc = results->protocols[d.seq].prot_status_desc,
     protocols_primary_sponsor = results->protocols[d.seq].primary_sponsor, reportlist_sort_by =
     parser(reportlist->sort_by)
     FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
     PLAN (d)
     ORDER BY reportlist_sort_by, protocols_prot_master_id
     WITH nocounter, separator = " ", format
    ELSE
     protocols_prot_master_id = results->protocols[d.seq].prot_master_id, protocols_primary_mnemonic
      = cnvtlower(results->protocols[d.seq].primary_mnemonic), protocols_init_activation_date =
     results->protocols[d.seq].init_activation_date,
     protocols_amd_activation_date = results->protocols[d.seq].amd_activation_date,
     protocols_cur_amd_id = results->protocols[d.seq].cur_amd_id, protocols_cur_amd_nbr = results->
     protocols[d.seq].cur_amd_nbr,
     protocols_cur_revision_nbr_txt = substring(1,30,results->protocols[d.seq].cur_revision_nbr_txt),
     protocols_prot_status_disp = results->protocols[d.seq].prot_status_disp,
     protocols_prot_status_desc = results->protocols[d.seq].prot_status_desc,
     protocols_primary_sponsor = results->protocols[d.seq].primary_sponsor, reportlist_sort_by =
     parser(reportlist->sort_by)
     FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
     PLAN (d)
     ORDER BY reportlist_sort_by DESC, protocols_prot_master_id
     WITH nocounter, separator = " ", format
    ENDIF
    protocols_prot_master_id = results->protocols[d.seq].prot_master_id, protocols_primary_mnemonic
     = cnvtlower(results->protocols[d.seq].primary_mnemonic), protocols_init_activation_date =
    results->protocols[d.seq].init_activation_date,
    protocols_amd_activation_date = results->protocols[d.seq].amd_activation_date,
    protocols_cur_amd_id = results->protocols[d.seq].cur_amd_id, protocols_cur_amd_nbr = results->
    protocols[d.seq].cur_amd_nbr,
    protocols_cur_revision_nbr_txt = substring(1,30,results->protocols[d.seq].cur_revision_nbr_txt),
    protocols_prot_status_disp = results->protocols[d.seq].prot_status_disp,
    protocols_prot_status_desc = results->protocols[d.seq].prot_status_desc,
    protocols_primary_sponsor = results->protocols[d.seq].primary_sponsor, reportlist_sort_by =
    parser(reportlist->sort_by)
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY reportlist_sort_by, protocols_prot_master_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _fenddetail = (_fenddetail
      - footpagesection(rpt_calcheight))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection_formatted = 0, dummy_val = headpagesection_formatted(rpt_render,((
      rptreport->m_pagewidth - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection_formatted
      ), dummy_val = headpagesection(rpt_render)
    HEAD reportlist_sort_by
     row + 0
    HEAD protocols_prot_master_id
     prot_cnt = (prot_cnt+ 1)
     IF (((row+ size(results->protocols[d.seq].amendments,5)) > 53)
      AND size(results->protocols[d.seq].amendments,5) < 53)
      BREAK
     ENDIF
     tmp_prot = results->protocols[d.seq].primary_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = "--"
     ENDIF
     tmp_prot_status = results->protocols[d.seq].prot_status_disp
     IF ((((reportlist->date_qual=0)
      AND (results->protocols[d.seq].init_activation_date < cnvtdatetime(reportlist->start_date)))
      OR ((((reportlist->date_qual=1)
      AND (results->protocols[d.seq].init_activation_date > cnvtdatetime(reportlist->start_date)))
      OR ((reportlist->date_qual=2)
      AND (results->protocols[d.seq].init_activation_date > cnvtdatetime(reportlist->start_date))
      AND (results->protocols[d.seq].init_activation_date < cnvtdatetime(reportlist->end_date)))) ))
     )
      new_cnt = (new_cnt+ 1)
     ENDIF
    DETAIL
     FOR (idx = 1 TO size(results->protocols[d.seq].amendments,5))
       IF (idx > 1)
        tmp_prot = "", tmp_init_act_date = "", tmp_prot_status = ""
       ENDIF
       tmp_status = results->protocols[d.seq].amendments[idx].amd_status_disp
       IF ((results->protocols[d.seq].amendments[idx].amendment_nbr > 0))
        tmp_amd_desc = concat(label->amendment," ",trim(cnvtstring(results->protocols[d.seq].
           amendments[idx].amendment_nbr)))
       ELSE
        tmp_amd_desc = label->init_prot
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].revision_ind=1))
        tmp_amd_desc = concat(tmp_amd_desc,"- ",label->revision," ",results->protocols[d.seq].
         amendments[idx].revision_nbr_txt), rev_cnt = (rev_cnt+ 1)
       ELSE
        amd_cnt = (amd_cnt+ 1)
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].amd_activation_date < cnvtdatetime(
        "31-DEC-2100 00:00:00"))
        AND (results->protocols[d.seq].amendments[idx].amd_activation_date > 0))
        tmp_act_date = format(results->protocols[d.seq].amendments[idx].amd_activation_date,
         "@SHORTDATE")
       ELSE
        tmp_act_date = "--"
       ENDIF
       IF ( NOT ((results->protocols[d.seq].amendments[idx].primary_sponsor IN ("", " ", null))))
        tmp_sponsor = results->protocols[d.seq].amendments[idx].primary_sponsor
       ELSE
        tmp_sponsor = "--"
       ENDIF
       _bcontdetailsection_formatted = 0, bfirsttime = 1
       WHILE (((_bcontdetailsection_formatted=1) OR (bfirsttime=1)) )
         _bholdcontinue = _bcontdetailsection_formatted, _fdrawheight = detailsection_formatted(
          rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
         IF (((_yoffset+ _fdrawheight) > _fenddetail))
          BREAK
         ELSEIF (_bholdcontinue=1
          AND _bcontdetailsection_formatted=0)
          BREAK
         ENDIF
         dummy_val = detailsection_formatted(rpt_render,(_fenddetail - _yoffset),
          _bcontdetailsection_formatted), bfirsttime = 0
       ENDWHILE
     ENDFOR
    FOOT  protocols_prot_master_id
     row + 0
    FOOT  reportlist_sort_by
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, tempstr = concat(label->rpt_page," ",trim(cnvtstring(
        curpage),3)),
     dummy_val = footpagesection(rpt_render), _yoffset = _yhold
    FOOT REPORT
     _bcontfootreportsection = 0, bfirsttime = 1
     WHILE (((_bcontfootreportsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontfootreportsection, _fdrawheight = footreportsection(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
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
 SUBROUTINE headpagesection_formatted(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_formattedabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection_formattedabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_init_act_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_prot_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cur_prot_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amendment = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amd_act_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amd_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_amd_spon = f8 WITH noconstant(0.0), private
   DECLARE __report_title = vc WITH noconstant(build2(label->report_title,char(0))), protect
   DECLARE __report_date = vc WITH noconstant(build2(label->report_date_title,char(0))), protect
   DECLARE __report_sort = vc WITH noconstant(build2(label->report_sort_title,char(0))), protect
   DECLARE __init_act_date = vc WITH noconstant(build2(label->init_act_header,char(0))), protect
   DECLARE __prot_mnemonic = vc WITH noconstant(build2(label->prot_mnemonic_header,char(0))), protect
   DECLARE __cur_prot_status = vc WITH noconstant(build2(label->cur_prot_status_header,char(0))),
   protect
   DECLARE __amendment = vc WITH noconstant(build2(label->amendment,char(0))), protect
   DECLARE __amd_act_date = vc WITH noconstant(build2(label->amd_act_date_header,char(0))), protect
   DECLARE __amd_status = vc WITH noconstant(build2(label->amd_status_header,char(0))), protect
   DECLARE __amd_spon = vc WITH noconstant(build2(label->amd_sponsor_header,char(0))), protect
   IF (bcontinue=0)
    SET _reminit_act_date = 1
    SET _remprot_mnemonic = 1
    SET _remcur_prot_status = 1
    SET _remamendment = 1
    SET _remamd_act_date = 1
    SET _remamd_status = 1
    SET _remamd_spon = 1
   ENDIF
   SET rptsd->m_flags = 1045
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.740
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdreminit_act_date = _reminit_act_date
   IF (_reminit_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminit_act_date,((size(
        __init_act_date) - _reminit_act_date)+ 1),__init_act_date)))
    SET drawheight_init_act_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminit_act_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminit_act_date,((size(__init_act_date)
        - _reminit_act_date)+ 1),__init_act_date)))))
     SET _reminit_act_date = (_reminit_act_date+ rptsd->m_drawlength)
    ELSE
     SET _reminit_act_date = 0
    ENDIF
    SET growsum = (growsum+ _reminit_act_date)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.740)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprot_mnemonic = _remprot_mnemonic
   IF (_remprot_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprot_mnemonic,((size(
        __prot_mnemonic) - _remprot_mnemonic)+ 1),__prot_mnemonic)))
    SET drawheight_prot_mnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprot_mnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprot_mnemonic,((size(__prot_mnemonic)
        - _remprot_mnemonic)+ 1),__prot_mnemonic)))))
     SET _remprot_mnemonic = (_remprot_mnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remprot_mnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remprot_mnemonic)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcur_prot_status = _remcur_prot_status
   IF (_remcur_prot_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcur_prot_status,((size
       (__cur_prot_status) - _remcur_prot_status)+ 1),__cur_prot_status)))
    SET drawheight_cur_prot_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcur_prot_status = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcur_prot_status,((size(
        __cur_prot_status) - _remcur_prot_status)+ 1),__cur_prot_status)))))
     SET _remcur_prot_status = (_remcur_prot_status+ rptsd->m_drawlength)
    ELSE
     SET _remcur_prot_status = 0
    ENDIF
    SET growsum = (growsum+ _remcur_prot_status)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.875)
   SET rptsd->m_width = 1.500
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
   SET rptsd->m_flags = 1045
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremamd_act_date = _remamd_act_date
   IF (_remamd_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remamd_act_date,((size(
        __amd_act_date) - _remamd_act_date)+ 1),__amd_act_date)))
    SET drawheight_amd_act_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remamd_act_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remamd_act_date,((size(__amd_act_date) -
       _remamd_act_date)+ 1),__amd_act_date)))))
     SET _remamd_act_date = (_remamd_act_date+ rptsd->m_drawlength)
    ELSE
     SET _remamd_act_date = 0
    ENDIF
    SET growsum = (growsum+ _remamd_act_date)
   ENDIF
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.125)
   SET rptsd->m_width = 1.500
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
   SET rptsd->m_flags = 1029
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremamd_spon = _remamd_spon
   IF (_remamd_spon > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remamd_spon,((size(
        __amd_spon) - _remamd_spon)+ 1),__amd_spon)))
    SET drawheight_amd_spon = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remamd_spon = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remamd_spon,((size(__amd_spon) -
       _remamd_spon)+ 1),__amd_spon)))))
     SET _remamd_spon = (_remamd_spon+ rptsd->m_drawlength)
    ELSE
     SET _remamd_spon = 0
    ENDIF
    SET growsum = (growsum+ _remamd_spon)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_courier12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__report_title)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_courier80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__report_date)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.438)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = 0.188
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__report_sort)
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.740
   SET rptsd->m_height = drawheight_init_act_date
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdreminit_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminit_act_date,((
       size(__init_act_date) - _holdreminit_act_date)+ 1),__init_act_date)))
   ELSE
    SET _reminit_act_date = _holdreminit_act_date
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.740)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = drawheight_prot_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprot_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_mnemonic,((
       size(__prot_mnemonic) - _holdremprot_mnemonic)+ 1),__prot_mnemonic)))
   ELSE
    SET _remprot_mnemonic = _holdremprot_mnemonic
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_cur_prot_status
   IF (ncalc=rpt_render
    AND _holdremcur_prot_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcur_prot_status,((
       size(__cur_prot_status) - _holdremcur_prot_status)+ 1),__cur_prot_status)))
   ELSE
    SET _remcur_prot_status = _holdremcur_prot_status
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_amendment
   IF (ncalc=rpt_render
    AND _holdremamendment > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamendment,((size(
        __amendment) - _holdremamendment)+ 1),__amendment)))
   ELSE
    SET _remamendment = _holdremamendment
   ENDIF
   SET rptsd->m_flags = 1044
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_amd_act_date
   IF (ncalc=rpt_render
    AND _holdremamd_act_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamd_act_date,((
       size(__amd_act_date) - _holdremamd_act_date)+ 1),__amd_act_date)))
   ELSE
    SET _remamd_act_date = _holdremamd_act_date
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.125)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_amd_status
   IF (ncalc=rpt_render
    AND _holdremamd_status > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamd_status,((size(
        __amd_status) - _holdremamd_status)+ 1),__amd_status)))
   ELSE
    SET _remamd_status = _holdremamd_status
   ENDIF
   SET rptsd->m_flags = 1028
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_amd_spon
   IF (ncalc=rpt_render
    AND _holdremamd_spon > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremamd_spon,((size(
        __amd_spon) - _holdremamd_spon)+ 1),__amd_spon)))
   ELSE
    SET _remamd_spon = _holdremamd_spon
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
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 0.032),(offsetx+ 10.521),(offsety
     + 0.032))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection_formatted(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_formattedabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsection_formattedabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_primary_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_protocols_init_activation_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_protocols_prot_status_disp = f8 WITH noconstant(0.0), private
   DECLARE drawheight_protocols_cur_amd_nbr = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_sponsor = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tmp_act_date = f8 WITH noconstant(0.0), private
   DECLARE __primary_mnemonic = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __protocols_init_activation_date = vc WITH noconstant(build2(tmp_init_act_date,char(0))),
   protect
   DECLARE __protocols_prot_status_disp = vc WITH noconstant(build2(trim(tmp_prot_status,3),char(0))),
   protect
   DECLARE __protocols_cur_amd_nbr = vc WITH noconstant(build2(trim(tmp_amd_desc,3),char(0))),
   protect
   DECLARE __tmp_sponsor = vc WITH noconstant(build2(tmp_sponsor,char(0))), protect
   DECLARE __tmp_status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __tmp_act_date = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   IF (bcontinue=0)
    SET _remprimary_mnemonic = 1
    SET _remprotocols_init_activation_date = 1
    SET _remprotocols_prot_status_disp = 1
    SET _remprotocols_cur_amd_nbr = 1
    SET _remtmp_sponsor = 1
    SET _remtmp_status = 1
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
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprimary_mnemonic = _remprimary_mnemonic
   IF (_remprimary_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprimary_mnemonic,((
       size(__primary_mnemonic) - _remprimary_mnemonic)+ 1),__primary_mnemonic)))
    SET drawheight_primary_mnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprimary_mnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprimary_mnemonic,((size(
        __primary_mnemonic) - _remprimary_mnemonic)+ 1),__primary_mnemonic)))))
     SET _remprimary_mnemonic = (_remprimary_mnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remprimary_mnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remprimary_mnemonic)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprotocols_init_activation_date = _remprotocols_init_activation_date
   IF (_remprotocols_init_activation_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remprotocols_init_activation_date,((size(__protocols_init_activation_date) -
       _remprotocols_init_activation_date)+ 1),__protocols_init_activation_date)))
    SET drawheight_protocols_init_activation_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprotocols_init_activation_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprotocols_init_activation_date,((size(
        __protocols_init_activation_date) - _remprotocols_init_activation_date)+ 1),
       __protocols_init_activation_date)))))
     SET _remprotocols_init_activation_date = (_remprotocols_init_activation_date+ rptsd->
     m_drawlength)
    ELSE
     SET _remprotocols_init_activation_date = 0
    ENDIF
    SET growsum = (growsum+ _remprotocols_init_activation_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprotocols_prot_status_disp = _remprotocols_prot_status_disp
   IF (_remprotocols_prot_status_disp > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remprotocols_prot_status_disp,((size(__protocols_prot_status_disp) -
       _remprotocols_prot_status_disp)+ 1),__protocols_prot_status_disp)))
    SET drawheight_protocols_prot_status_disp = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprotocols_prot_status_disp = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprotocols_prot_status_disp,((size(
        __protocols_prot_status_disp) - _remprotocols_prot_status_disp)+ 1),
       __protocols_prot_status_disp)))))
     SET _remprotocols_prot_status_disp = (_remprotocols_prot_status_disp+ rptsd->m_drawlength)
    ELSE
     SET _remprotocols_prot_status_disp = 0
    ENDIF
    SET growsum = (growsum+ _remprotocols_prot_status_disp)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprotocols_cur_amd_nbr = _remprotocols_cur_amd_nbr
   IF (_remprotocols_cur_amd_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprotocols_cur_amd_nbr,
       ((size(__protocols_cur_amd_nbr) - _remprotocols_cur_amd_nbr)+ 1),__protocols_cur_amd_nbr)))
    SET drawheight_protocols_cur_amd_nbr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprotocols_cur_amd_nbr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprotocols_cur_amd_nbr,((size(
        __protocols_cur_amd_nbr) - _remprotocols_cur_amd_nbr)+ 1),__protocols_cur_amd_nbr)))))
     SET _remprotocols_cur_amd_nbr = (_remprotocols_cur_amd_nbr+ rptsd->m_drawlength)
    ELSE
     SET _remprotocols_cur_amd_nbr = 0
    ENDIF
    SET growsum = (growsum+ _remprotocols_cur_amd_nbr)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 1.750
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.125)
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
   SET rptsd->m_x = (offsetx+ 5.469)
   SET rptsd->m_width = 1.531
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
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_primary_mnemonic
   IF (ncalc=rpt_render
    AND _holdremprimary_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprimary_mnemonic,(
       (size(__primary_mnemonic) - _holdremprimary_mnemonic)+ 1),__primary_mnemonic)))
   ELSE
    SET _remprimary_mnemonic = _holdremprimary_mnemonic
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_protocols_init_activation_date
   IF (ncalc=rpt_render
    AND _holdremprotocols_init_activation_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremprotocols_init_activation_date,((size(__protocols_init_activation_date) -
       _holdremprotocols_init_activation_date)+ 1),__protocols_init_activation_date)))
   ELSE
    SET _remprotocols_init_activation_date = _holdremprotocols_init_activation_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_protocols_prot_status_disp
   IF (ncalc=rpt_render
    AND _holdremprotocols_prot_status_disp > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremprotocols_prot_status_disp,((size(__protocols_prot_status_disp) -
       _holdremprotocols_prot_status_disp)+ 1),__protocols_prot_status_disp)))
   ELSE
    SET _remprotocols_prot_status_disp = _holdremprotocols_prot_status_disp
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.875)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_protocols_cur_amd_nbr
   IF (ncalc=rpt_render
    AND _holdremprotocols_cur_amd_nbr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremprotocols_cur_amd_nbr,((size(__protocols_cur_amd_nbr) - _holdremprotocols_cur_amd_nbr)
       + 1),__protocols_cur_amd_nbr)))
   ELSE
    SET _remprotocols_cur_amd_nbr = _holdremprotocols_cur_amd_nbr
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.750)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = drawheight_tmp_sponsor
   IF (ncalc=rpt_render
    AND _holdremtmp_sponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtmp_sponsor,((size
       (__tmp_sponsor) - _holdremtmp_sponsor)+ 1),__tmp_sponsor)))
   ELSE
    SET _remtmp_sponsor = _holdremtmp_sponsor
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.125)
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
   SET rptsd->m_x = (offsetx+ 5.469)
   SET rptsd->m_width = 1.531
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
 SUBROUTINE footpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.690000), private
   DECLARE __label_rep_exec_time = vc WITH noconstant(build2(label->rep_exec_time,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.500
    SET rptsd->m_height = 0.125
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label_rep_exec_time)
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.500
    SET rptsd->m_height = 0.135
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tempstr,char(0)))
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
   DECLARE sectionheight = f8 WITH noconstant(1.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_total_prots = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total_new_prots = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total_amds = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total_revs = f8 WITH noconstant(0.0), private
   DECLARE __label_total_prots = vc WITH noconstant(build2(concat(label->total_prots," ",cnvtstring(
       prot_cnt)),char(0))), protect
   DECLARE __label_total_new_prots = vc WITH noconstant(build2(concat(label->total_new_prots," ",
      cnvtstring(new_cnt)),char(0))), protect
   DECLARE __label_total_amds = vc WITH noconstant(build2(concat(label->total_amds," ",cnvtstring(
       amd_cnt)),char(0))), protect
   DECLARE __label_total_revs = vc WITH noconstant(build2(concat(label->total_revs," ",cnvtstring(
       rev_cnt)),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_total_prots = 1
    SET _remlabel_total_new_prots = 1
    SET _remlabel_total_amds = 1
    SET _remlabel_total_revs = 1
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
   SET _oldfont = uar_rptsetfont(_hreport,_courier10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_total_prots = _remlabel_total_prots
   IF (_remlabel_total_prots > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_prots,((
       size(__label_total_prots) - _remlabel_total_prots)+ 1),__label_total_prots)))
    SET drawheight_label_total_prots = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_prots = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_prots,((size(
        __label_total_prots) - _remlabel_total_prots)+ 1),__label_total_prots)))))
     SET _remlabel_total_prots = (_remlabel_total_prots+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_prots = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_prots)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_total_new_prots = _remlabel_total_new_prots
   IF (_remlabel_total_new_prots > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_new_prots,
       ((size(__label_total_new_prots) - _remlabel_total_new_prots)+ 1),__label_total_new_prots)))
    SET drawheight_label_total_new_prots = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_new_prots = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_new_prots,((size(
        __label_total_new_prots) - _remlabel_total_new_prots)+ 1),__label_total_new_prots)))))
     SET _remlabel_total_new_prots = (_remlabel_total_new_prots+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_new_prots = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_new_prots)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.625)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_total_amds = _remlabel_total_amds
   IF (_remlabel_total_amds > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_amds,((
       size(__label_total_amds) - _remlabel_total_amds)+ 1),__label_total_amds)))
    SET drawheight_label_total_amds = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_amds = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_amds,((size(
        __label_total_amds) - _remlabel_total_amds)+ 1),__label_total_amds)))))
     SET _remlabel_total_amds = (_remlabel_total_amds+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_amds = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_amds)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_total_revs = _remlabel_total_revs
   IF (_remlabel_total_revs > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total_revs,((
       size(__label_total_revs) - _remlabel_total_revs)+ 1),__label_total_revs)))
    SET drawheight_label_total_revs = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total_revs = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total_revs,((size(
        __label_total_revs) - _remlabel_total_revs)+ 1),__label_total_revs)))))
     SET _remlabel_total_revs = (_remlabel_total_revs+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_total_revs = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_total_revs)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_prots
   IF (ncalc=rpt_render
    AND _holdremlabel_total_prots > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total_prots,
       ((size(__label_total_prots) - _holdremlabel_total_prots)+ 1),__label_total_prots)))
   ELSE
    SET _remlabel_total_prots = _holdremlabel_total_prots
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.438)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_new_prots
   IF (ncalc=rpt_render
    AND _holdremlabel_total_new_prots > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_total_new_prots,((size(__label_total_new_prots) - _holdremlabel_total_new_prots)
       + 1),__label_total_new_prots)))
   ELSE
    SET _remlabel_total_new_prots = _holdremlabel_total_new_prots
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.625)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_amds
   IF (ncalc=rpt_render
    AND _holdremlabel_total_amds > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total_amds,(
       (size(__label_total_amds) - _holdremlabel_total_amds)+ 1),__label_total_amds)))
   ELSE
    SET _remlabel_total_amds = _holdremlabel_total_amds
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.500
   SET rptsd->m_height = drawheight_label_total_revs
   IF (ncalc=rpt_render
    AND _holdremlabel_total_revs > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total_revs,(
       (size(__label_total_revs) - _holdremlabel_total_revs)+ 1),__label_total_revs)))
   ELSE
    SET _remlabel_total_revs = _holdremlabel_total_revs
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
   SET rptreport->m_reportname = "CT_RPT_PROT_ACTIVATION_DATE_LO"
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
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_on
   SET _courier8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _courier12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _courier80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _courier10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (size(results->protocols,5)=0)
  IF (size(label->end_before_start,1) > 0)
   SET tmp_status = label->end_before_start
  ELSE
   SET tmp_status = label->no_prot
  ENDIF
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 1, label->report_title, row + 1,
    col 1, label->rep_exec_time, row + 2,
    col 1, tmp_status, row + 2,
    col 1, label->report_date_title, row + 1
   WITH nocounter
  ;end select
 ELSEIF (( $OUT_TYPE=1))
  IF (( $SORTORDER=0))
   SELECT INTO  $OUTDEV
    prot_mnemonic = results->protocols[d.seq].primary_mnemonic, prot_id = results->protocols[d.seq].
    prot_master_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    ORDER BY parser(reportlist->sort_by)
    HEAD REPORT
     prot_cnt = 0, amd_cnt = 0, rev_cnt = 0,
     new_cnt = 0, col 0, label->report_title,
     row + 1, col 0, label->report_date_title,
     row + 1, col 0, label->report_sort_title,
     row + 1, col 0, label->rep_exec_time,
     row + 1, tempstr = concat(label->init_act_header, $DELIMITER,label->prot_mnemonic_header,
       $DELIMITER,label->cur_prot_status_header,
       $DELIMITER,label->amendment, $DELIMITER,label->amd_act_date_header, $DELIMITER,
      label->amd_status_header, $DELIMITER,label->amd_sponsor_header), col 0,
     tempstr, row + 1
    HEAD prot_id
     prot_cnt = (prot_cnt+ 1), tmp_prot = results->protocols[d.seq].primary_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = ""
     ENDIF
     tmp_prot_status = results->protocols[d.seq].prot_status_disp
     IF (((( $DATEQUAL=0)
      AND (results->protocols[d.seq].init_activation_date < cnvtdatetime(reportlist->start_date)))
      OR (((( $DATEQUAL=1)
      AND (results->protocols[d.seq].init_activation_date > cnvtdatetime(reportlist->start_date)))
      OR (( $DATEQUAL=2)
      AND (results->protocols[d.seq].init_activation_date > cnvtdatetime(reportlist->start_date))
      AND (results->protocols[d.seq].init_activation_date < cnvtdatetime(reportlist->end_date)))) ))
     )
      new_cnt = (new_cnt+ 1)
     ENDIF
     tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_init_act_date = concat('"',trim(
       tmp_init_act_date,3),'"'), tmp_prot_status = concat('"',trim(tmp_prot_status,3),'"')
    DETAIL
     FOR (idx = 1 TO size(results->protocols[d.seq].amendments,5))
       tmp_status = results->protocols[d.seq].amendments[idx].amd_status_disp
       IF ((results->protocols[d.seq].amendments[idx].amendment_nbr > 0))
        tmp_amd_desc = concat(label->amendment," ",trim(cnvtstring(results->protocols[d.seq].
           amendments[idx].amendment_nbr)))
       ELSE
        tmp_amd_desc = label->init_prot
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].revision_ind=1))
        tmp_amd_desc = concat(tmp_amd_desc," - ",label->revision," ",results->protocols[d.seq].
         amendments[idx].revision_nbr_txt), rev_cnt = (rev_cnt+ 1)
       ELSE
        amd_cnt = (amd_cnt+ 1)
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].amd_activation_date < cnvtdatetime(
        "31-DEC-2100 00:00:00"))
        AND (results->protocols[d.seq].amendments[idx].amd_activation_date > 0))
        tmp_act_date = format(results->protocols[d.seq].amendments[idx].amd_activation_date,
         "@SHORTDATE")
       ELSE
        tmp_act_date = ""
       ENDIF
       IF ( NOT ((results->protocols[d.seq].amendments[idx].primary_sponsor IN ("", " ", null))))
        tmp_sponsor = results->protocols[d.seq].amendments[idx].primary_sponsor
       ELSE
        tmp_sponsor = ""
       ENDIF
       tmp_amd_desc = concat('"',trim(tmp_amd_desc,3),'"'), tmp_act_date = concat('"',trim(
         tmp_act_date,3),'"'), tmp_status = concat('"',trim(tmp_status,3),'"'),
       tmp_sponsor = concat('"',trim(tmp_sponsor,3),'"'), tempstr = concat(tmp_init_act_date,
         $DELIMITER,tmp_prot, $DELIMITER,tmp_prot_status,
         $DELIMITER,tmp_amd_desc, $DELIMITER,tmp_act_date, $DELIMITER,
        tmp_status, $DELIMITER,tmp_sponsor), col 0,
       tempstr, row + 1
     ENDFOR
    FOOT REPORT
     tempstr = concat(label->total_prots," ",trim(cnvtstring(size(results->protocols,5),3))), row + 1,
     col 0,
     tempstr, tempstr = concat(label->total_new_prots," ",trim(cnvtstring(new_cnt,3))), row + 1,
     col 0, tempstr, tempstr = concat(label->total_amds," ",trim(cnvtstring(amd_cnt,3))),
     row + 1, col 0, tempstr,
     tempstr = concat(label->total_revs," ",trim(cnvtstring(rev_cnt,3))), row + 1, col 0,
     tempstr, row + 2, col 0,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    prot_mnemonic = results->protocols[d.seq].primary_mnemonic, prot_id = results->protocols[d.seq].
    prot_master_id
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    ORDER BY parser(reportlist->sort_by) DESC
    HEAD REPORT
     prot_cnt = 0, amd_cnt = 0, rev_cnt = 0,
     new_cnt = 0, col 0, label->report_title,
     row + 1, col 0, label->report_date_title,
     row + 1, col 0, label->report_sort_title,
     row + 1, col 0, label->rep_exec_time,
     row + 1, tempstr = concat(label->init_act_header, $DELIMITER,label->prot_mnemonic_header,
       $DELIMITER,label->cur_prot_status_header,
       $DELIMITER,label->amendment, $DELIMITER,label->amd_act_date_header, $DELIMITER,
      label->amd_status_header, $DELIMITER,label->amd_sponsor_header), col 0,
     tempstr, row + 1
    HEAD prot_id
     prot_cnt = (prot_cnt+ 1), tmp_prot = results->protocols[d.seq].primary_mnemonic
     IF ((results->protocols[d.seq].init_activation_date < cnvtdatetime("31-DEC-2100 00:00:00"))
      AND (results->protocols[d.seq].init_activation_date > 0))
      tmp_init_act_date = format(results->protocols[d.seq].init_activation_date,"@SHORTDATE")
     ELSE
      tmp_init_act_date = ""
     ENDIF
     tmp_prot_status = results->protocols[d.seq].prot_status_disp
     IF (((( $DATEQUAL=0)
      AND (results->protocols[d.seq].init_activation_date < cnvtdatetime(reportlist->start_date)))
      OR (((( $DATEQUAL=1)
      AND (results->protocols[d.seq].init_activation_date > cnvtdatetime(reportlist->start_date)))
      OR (( $DATEQUAL=2)
      AND (results->protocols[d.seq].init_activation_date > cnvtdatetime(reportlist->start_date))
      AND (results->protocols[d.seq].init_activation_date < cnvtdatetime(reportlist->end_date)))) ))
     )
      new_cnt = (new_cnt+ 1)
     ENDIF
     tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_init_act_date = concat('"',trim(
       tmp_init_act_date,3),'"'), tmp_prot_status = concat('"',trim(tmp_prot_status,3),'"')
    DETAIL
     FOR (idx = 1 TO size(results->protocols[d.seq].amendments,5))
       tmp_status = results->protocols[d.seq].amendments[idx].amd_status_disp
       IF ((results->protocols[d.seq].amendments[idx].amendment_nbr > 0))
        tmp_amd_desc = concat(label->amendment," ",trim(cnvtstring(results->protocols[d.seq].
           amendments[idx].amendment_nbr)))
       ELSE
        tmp_amd_desc = label->init_prot
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].revision_ind=1))
        tmp_amd_desc = concat(tmp_amd_desc," - ",label->revision," ",results->protocols[d.seq].
         amendments[idx].revision_nbr_txt), rev_cnt = (rev_cnt+ 1)
       ELSE
        amd_cnt = (amd_cnt+ 1)
       ENDIF
       IF ((results->protocols[d.seq].amendments[idx].amd_activation_date < cnvtdatetime(
        "31-DEC-2100 00:00:00"))
        AND (results->protocols[d.seq].amendments[idx].amd_activation_date > 0))
        tmp_act_date = format(results->protocols[d.seq].amendments[idx].amd_activation_date,
         "@SHORTDATE")
       ELSE
        tmp_act_date = ""
       ENDIF
       IF ( NOT ((results->protocols[d.seq].amendments[idx].primary_sponsor IN ("", " ", null))))
        tmp_sponsor = results->protocols[d.seq].amendments[idx].primary_sponsor
       ELSE
        tmp_sponsor = ""
       ENDIF
       tmp_amd_desc = concat('"',trim(tmp_amd_desc,3),'"'), tmp_act_date = concat('"',trim(
         tmp_act_date,3),'"'), tmp_status = concat('"',trim(tmp_status,3),'"'),
       tmp_sponsor = concat('"',trim(tmp_sponsor,3),'"'), tempstr = concat(tmp_init_act_date,
         $DELIMITER,tmp_prot, $DELIMITER,tmp_prot_status,
         $DELIMITER,tmp_amd_desc, $DELIMITER,tmp_act_date, $DELIMITER,
        tmp_status, $DELIMITER,tmp_sponsor), col 0,
       tempstr, row + 1
     ENDFOR
    FOOT REPORT
     tempstr = concat(label->total_prots," ",trim(cnvtstring(size(results->protocols,5),3))), row + 1,
     col 0,
     tempstr, tempstr = concat(label->total_new_prots," ",trim(cnvtstring(new_cnt,3))), row + 1,
     col 0, tempstr, tempstr = concat(label->total_amds," ",trim(cnvtstring(amd_cnt,3))),
     row + 1, col 0, tempstr,
     tempstr = concat(label->total_revs," ",trim(cnvtstring(rev_cnt,3))), row + 1, col 0,
     tempstr, row + 2, col 0,
     label->end_of_rpt
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ENDIF
 ELSE
  CALL initializereport(0)
  SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom)
  SET _fholdenddetail = _fenddetail
  CALL get_protocol_data(0)
  SET _fenddetail = _fholdenddetail
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "MAR,24 2016"
END GO
