CREATE PROGRAM ct_rpt_enrollment_rep_lo:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Accrual numbers" = 0,
  "Order By" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, accrual,
  orderby, out_type, delimiter
 EXECUTE reportrtl
 RECORD protlist(
   1 protocols[*]
     2 protocol_id = f8
     2 prot_mnemonic = vc
   1 accrual_numbers = i2
   1 order_by = i2
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 prot_mnemonic = vc
     2 collab_site_ind = i2
     2 parent_prot_master_id = f8
     2 activation_date = dq8
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 prot_status_desc = c60
     2 prot_status_mean = c12
     2 trialwide_cur_accrual = i2
     2 trialwide_targeted = i2
     2 trialwide_percent = c10
     2 trialwide_prj_accrual = i2
     2 site_cur_accrual = i2
     2 site_targeted = i2
     2 site_percent = c10
     2 site_prj_accrual = i2
     2 primary_sponsor = c100
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
 RECORD report_labels(
   1 m_s_trial_wide_title = vc
   1 m_s_site_title = vc
   1 m_s_trial_and_site_title = vc
   1 m_s_rpt_exec_time = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_act_date_header = vc
   1 m_s_status_header = vc
   1 m_s_trial_cur_accrual_header = vc
   1 m_s_percent_trial_header = vc
   1 m_s_site_cur_accrual_header = vc
   1 m_s_projected_accrual_header = vc
   1 m_s_trial_target_accrual_header = vc
   1 m_s_site_target_accrual_header = vc
   1 m_s_percent_site_header = vc
   1 m_s_percent_header = vc
   1 m_s_sponsor_header = vc
   1 m_s_total_prots_selected = vc
   1 m_s_total_pts_accrued = vc
   1 m_s_total_site_pts_accrued = vc
   1 m_s_end_of_rpt = vc
   1 m_s_order_by_date = vc
   1 m_s_order_by_status = vc
   1 m_s_order_by_sponsor = vc
   1 m_s_order_by_prot = vc
   1 m_s_no_prot_found = vc
   1 execution_timestamp = vc
   1 m_s_page = vc
   1 sorting_field = vc
   1 sorted_by = vc
   1 report_title = vc
   1 accrual_type = i2
   1 output_type = i2
   1 delimiter_output = vc
   1 total_prot = vc
   1 total_patients = vc
   1 total_site_pt_accrued = vc
 )
 EXECUTE ct_rpt_enrollment_report:dba "NL:",  $PROTOCOLS,  $ACCRUAL,
  $ORDERBY,  $OUT_TYPE,  $DELIMITER
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE ct_get_rpt_enrollment(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE headpagesection2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE headreport_sorting_fieldsection(ncalc=i2) = f8 WITH protect
 DECLARE headreport_sorting_fieldsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headprot_idsection(ncalc=i2) = f8 WITH protect
 DECLARE headprot_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE detailsection2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE detailsection1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
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
 DECLARE _remnprotocolmnemonic = i4 WITH noconstant(1), protect
 DECLARE _remnactivationdate = i4 WITH noconstant(1), protect
 DECLARE _remnstatus = i4 WITH noconstant(1), protect
 DECLARE _remntrialwideaccrual = i4 WITH noconstant(1), protect
 DECLARE _remnprojectedaccrual = i4 WITH noconstant(1), protect
 DECLARE _remtargetaccrual = i4 WITH noconstant(1), protect
 DECLARE _remntotalpercent = i4 WITH noconstant(1), protect
 DECLARE _remnsponsor = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remnpro_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _remnact_date = i4 WITH noconstant(1), protect
 DECLARE _remstatus = i4 WITH noconstant(1), protect
 DECLARE _remsite_wide_accrual = i4 WITH noconstant(1), protect
 DECLARE _remprojected_accrual = i4 WITH noconstant(1), protect
 DECLARE _remtarget_accrual = i4 WITH noconstant(1), protect
 DECLARE _remtotal_percent = i4 WITH noconstant(1), protect
 DECLARE _remsponsor = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection1 = i2 WITH noconstant(0), protect
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname3 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname4 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname5 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname6 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname7 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname8 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname9 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname10 = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection2 = i2 WITH noconstant(0), protect
 DECLARE _remprotocol_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _remactivation_date = i4 WITH noconstant(1), protect
 DECLARE _remstatus = i4 WITH noconstant(1), protect
 DECLARE _remtrialaccrual = i4 WITH noconstant(1), protect
 DECLARE _remproj_accrual = i4 WITH noconstant(1), protect
 DECLARE _remtarget_accrual = i4 WITH noconstant(1), protect
 DECLARE _remtotal_percent = i4 WITH noconstant(1), protect
 DECLARE _remsponsor = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname2 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname3 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname4 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname5 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname6 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname7 = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection2 = i2 WITH noconstant(0), protect
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname2 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname3 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname5 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname6 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname7 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname8 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname9 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname4 = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection1 = i2 WITH noconstant(0), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE tmp_prot = vc WITH protect
 DECLARE tmp_status = vc WITH protect
 DECLARE tmp_sponsor = vc WITH protect
 DECLARE tmp_prj_acc = vc WITH protect
 DECLARE tmp_site_prj_acc = vc WITH protect
 DECLARE tmp_tw_targ = vc WITH protect
 DECLARE tmp_tw_cur_acc = vc WITH protect
 DECLARE tmp_tw_percent = vc WITH protect
 DECLARE tmp_site_targ = vc WITH protect
 DECLARE tmp_site_cur_acc = vc WITH protect
 DECLARE tmp_site_percent = vc WITH protect
 DECLARE tmp_act_date = vc WITH protect
 DECLARE temp_row = i4 WITH protect
 DECLARE site_cur_accrual_sum = i4 WITH protect
 DECLARE tw_cur_accrual_sum = i4 WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE m_s_blank_percent = vc WITH protect
 DECLARE label_page = vc WITH protect
 SUBROUTINE ct_get_rpt_enrollment(dummy)
   SELECT
    tmp_prot = results->protocols[d.seq].prot_mnemonic, prot_id = results->protocols[d.seq].
    prot_master_id, report_sorting_field = parser(report_labels->sorting_field)
    FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
    PLAN (d)
    ORDER BY report_sorting_field, prot_id
    HEAD REPORT
     _d0 = tmp_prot, _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom), _fenddetail
      = (_fenddetail - footpagesection(rpt_calcheight)),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pagewidth - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render), tw_cur_accrual_sum = 0, site_cur_accrual_sum = 0
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     IF ((report_labels->accrual_type=0))
      _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pagewidth -
       rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection)
     ELSEIF ((report_labels->accrual_type=1))
      _bcontheadpagesection1 = 0, dummy_val = headpagesection1(rpt_render,((rptreport->m_pagewidth -
       rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection1)
     ELSE
      _bcontheadpagesection2 = 0, dummy_val = headpagesection2(rpt_render,((rptreport->m_pagewidth -
       rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection2)
     ENDIF
    HEAD report_sorting_field
     row + 0
    HEAD prot_id
     IF ((results->protocols[d.seq].trialwide_cur_accrual > 0))
      tw_cur_accrual_sum = (tw_cur_accrual_sum+ results->protocols[d.seq].trialwide_cur_accrual)
     ENDIF
     IF ((results->protocols[d.seq].site_cur_accrual > 0))
      site_cur_accrual_sum = (site_cur_accrual_sum+ results->protocols[d.seq].site_cur_accrual)
     ENDIF
    DETAIL
     tmp_prot = results->protocols[d.seq].prot_mnemonic, tmp_act_date = format(results->protocols[d
      .seq].activation_date,"@SHORTDATE"), tmp_status = results->protocols[d.seq].prot_status_disp
     IF ((results->protocols[d.seq].trialwide_cur_accrual < 0))
      tmp_tw_cur_acc = "   --"
     ELSE
      tmp_tw_cur_acc = format(results->protocols[d.seq].trialwide_cur_accrual,"#####")
     ENDIF
     IF ((results->protocols[d.seq].trialwide_targeted < 0))
      tmp_tw_targ = "   --"
     ELSE
      tmp_tw_targ = format(results->protocols[d.seq].trialwide_targeted,"#####")
     ENDIF
     tmp_tw_percent = format(results->protocols[d.seq].trialwide_percent,";I;f")
     IF ((results->protocols[d.seq].trialwide_prj_accrual < 0))
      tmp_prj_acc = "   --"
     ELSE
      tmp_prj_acc = format(results->protocols[d.seq].trialwide_prj_accrual,"#####")
     ENDIF
     IF ((results->protocols[d.seq].site_prj_accrual < 0))
      tmp_site_prj_acc = "   --"
     ELSE
      tmp_site_prj_acc = format(results->protocols[d.seq].site_prj_accrual,"#####")
     ENDIF
     IF ((results->protocols[d.seq].site_cur_accrual < 0))
      tmp_site_cur_acc = "   --"
     ELSE
      tmp_site_cur_acc = format(results->protocols[d.seq].site_cur_accrual,"#####")
     ENDIF
     IF ((results->protocols[d.seq].site_targeted < 0))
      tmp_site_targ = "   --"
     ELSE
      tmp_site_targ = format(results->protocols[d.seq].site_targeted,"#####")
     ENDIF
     tmp_site_percent = format(results->protocols[d.seq].site_percent,";I;f")
     IF ( NOT ((results->protocols[d.seq].primary_sponsor IN ("", " ", null))))
      tmp_sponsor = results->protocols[d.seq].primary_sponsor
     ELSE
      tmp_sponsor = "--"
     ENDIF
     IF ((report_labels->accrual_type=0))
      _bcontdetailsection = 0, bfirsttime = 1
      WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(
         _fenddetail - _yoffset),_bholdcontinue)
        IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ detailsection2(rpt_calcheight,((
           _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
          IF (_bholdcontinue=1)
           _fdrawheight = (_fenddetail+ 1)
          ENDIF
         ENDIF
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ detailsection1(rpt_calcheight,((
           _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
          IF (_bholdcontinue=1)
           _fdrawheight = (_fenddetail+ 1)
          ENDIF
         ENDIF
        ENDIF
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         BREAK
        ELSEIF (_bholdcontinue=1
         AND _bcontdetailsection=0)
         BREAK
        ENDIF
        dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection),
        bfirsttime = 0
      ENDWHILE
     ELSEIF ((report_labels->accrual_type=1))
      _bcontdetailsection2 = 0, bfirsttime = 1
      WHILE (((_bcontdetailsection2=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontdetailsection2, _fdrawheight = detailsection2(rpt_calcheight,(
         _fenddetail - _yoffset),_bholdcontinue)
        IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
         IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
          _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ detailsection1(rpt_calcheight,((
           _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
          IF (_bholdcontinue=1)
           _fdrawheight = (_fenddetail+ 1)
          ENDIF
         ENDIF
        ENDIF
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         BREAK
        ELSEIF (_bholdcontinue=1
         AND _bcontdetailsection2=0)
         BREAK
        ENDIF
        dummy_val = detailsection2(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection2),
        bfirsttime = 0
      ENDWHILE
     ELSE
      _bcontdetailsection1 = 0, bfirsttime = 1
      WHILE (((_bcontdetailsection1=1) OR (bfirsttime=1)) )
        _bholdcontinue = _bcontdetailsection1, _fdrawheight = detailsection1(rpt_calcheight,(
         _fenddetail - _yoffset),_bholdcontinue)
        IF (((_yoffset+ _fdrawheight) > _fenddetail))
         BREAK
        ELSEIF (_bholdcontinue=1
         AND _bcontdetailsection1=0)
         BREAK
        ENDIF
        dummy_val = detailsection1(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection1),
        bfirsttime = 0
      ENDWHILE
     ENDIF
    FOOT  prot_id
     row + 0
    FOOT  report_sorting_field
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, label_page = concat(build2(report_labels->m_s_page,
       trim(cnvtstring(curpage),3))),
     dummy_val = footpagesection(rpt_render), _yoffset = _yhold
    FOOT REPORT
     report_labels->total_prot = build2(report_labels->m_s_total_prots_selected,trim(cnvtstring(size(
         protlist->protocols,5),3)))
     IF ((((report_labels->accrual_type=0)) OR ((report_labels->accrual_type=2))) )
      report_labels->total_patients = build2(report_labels->m_s_total_pts_accrued,trim(cnvtstring(
         tw_cur_accrual_sum,3)))
     ENDIF
     IF ((((report_labels->accrual_type=1)) OR ((report_labels->accrual_type=2))) )
      report_labels->total_site_pt_accrued = build2(report_labels->m_s_total_site_pts_accrued,trim(
        cnvtstring(site_cur_accrual_sum),3))
     ENDIF
     _fdrawheight = footreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportsection(rpt_render)
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
   DECLARE sectionheight = f8 WITH noconstant(1.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_nprotocolmnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nactivationdate = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nstatus = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ntrialwideaccrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nprojectedaccrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_targetaccrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ntotalpercent = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nsponsor = f8 WITH noconstant(0.0), private
   DECLARE __ntitle2 = vc WITH noconstant(build2(report_labels->sorted_by,char(0))), protect
   DECLARE __nprotocolmnemonic = vc WITH noconstant(build2(report_labels->m_s_prot_mnemonic_header,
     char(0))), protect
   DECLARE __nactivationdate = vc WITH noconstant(build2(report_labels->m_s_act_date_header,char(0))),
   protect
   DECLARE __nstatus = vc WITH noconstant(build2(report_labels->m_s_status_header,char(0))), protect
   DECLARE __ntrialwideaccrual = vc WITH noconstant(build2(report_labels->
     m_s_trial_cur_accrual_header,char(0))), protect
   DECLARE __nprojectedaccrual = vc WITH noconstant(build2(report_labels->
     m_s_projected_accrual_header,char(0))), protect
   DECLARE __targetaccrual = vc WITH noconstant(build2(report_labels->m_s_trial_target_accrual_header,
     char(0))), protect
   DECLARE __ntotalpercent = vc WITH noconstant(build2(report_labels->m_s_percent_header,char(0))),
   protect
   DECLARE __nsponsor = vc WITH noconstant(build2(report_labels->m_s_sponsor_header,char(0))),
   protect
   DECLARE __title1 = vc WITH noconstant(build2(report_labels->report_title,char(0))), protect
   IF (bcontinue=0)
    SET _remnprotocolmnemonic = 1
    SET _remnactivationdate = 1
    SET _remnstatus = 1
    SET _remntrialwideaccrual = 1
    SET _remnprojectedaccrual = 1
    SET _remtargetaccrual = 1
    SET _remntotalpercent = 1
    SET _remnsponsor = 1
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
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
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
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnactivationdate = _remnactivationdate
   IF (_remnactivationdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnactivationdate,((size
       (__nactivationdate) - _remnactivationdate)+ 1),__nactivationdate)))
    SET drawheight_nactivationdate = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnactivationdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnactivationdate,((size(
        __nactivationdate) - _remnactivationdate)+ 1),__nactivationdate)))))
     SET _remnactivationdate = (_remnactivationdate+ rptsd->m_drawlength)
    ELSE
     SET _remnactivationdate = 0
    ENDIF
    SET growsum = (growsum+ _remnactivationdate)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.813)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnstatus = _remnstatus
   IF (_remnstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnstatus,((size(
        __nstatus) - _remnstatus)+ 1),__nstatus)))
    SET drawheight_nstatus = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnstatus = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnstatus,((size(__nstatus) -
       _remnstatus)+ 1),__nstatus)))))
     SET _remnstatus = (_remnstatus+ rptsd->m_drawlength)
    ELSE
     SET _remnstatus = 0
    ENDIF
    SET growsum = (growsum+ _remnstatus)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.063)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremntrialwideaccrual = _remntrialwideaccrual
   IF (_remntrialwideaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remntrialwideaccrual,((
       size(__ntrialwideaccrual) - _remntrialwideaccrual)+ 1),__ntrialwideaccrual)))
    SET drawheight_ntrialwideaccrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remntrialwideaccrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remntrialwideaccrual,((size(
        __ntrialwideaccrual) - _remntrialwideaccrual)+ 1),__ntrialwideaccrual)))))
     SET _remntrialwideaccrual = (_remntrialwideaccrual+ rptsd->m_drawlength)
    ELSE
     SET _remntrialwideaccrual = 0
    ENDIF
    SET growsum = (growsum+ _remntrialwideaccrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.323)
   SET rptsd->m_width = 0.990
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnprojectedaccrual = _remnprojectedaccrual
   IF (_remnprojectedaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnprojectedaccrual,((
       size(__nprojectedaccrual) - _remnprojectedaccrual)+ 1),__nprojectedaccrual)))
    SET drawheight_nprojectedaccrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnprojectedaccrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnprojectedaccrual,((size(
        __nprojectedaccrual) - _remnprojectedaccrual)+ 1),__nprojectedaccrual)))))
     SET _remnprojectedaccrual = (_remnprojectedaccrual+ rptsd->m_drawlength)
    ELSE
     SET _remnprojectedaccrual = 0
    ENDIF
    SET growsum = (growsum+ _remnprojectedaccrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.865
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtargetaccrual = _remtargetaccrual
   IF (_remtargetaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtargetaccrual,((size(
        __targetaccrual) - _remtargetaccrual)+ 1),__targetaccrual)))
    SET drawheight_targetaccrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtargetaccrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtargetaccrual,((size(__targetaccrual)
        - _remtargetaccrual)+ 1),__targetaccrual)))))
     SET _remtargetaccrual = (_remtargetaccrual+ rptsd->m_drawlength)
    ELSE
     SET _remtargetaccrual = 0
    ENDIF
    SET growsum = (growsum+ _remtargetaccrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremntotalpercent = _remntotalpercent
   IF (_remntotalpercent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remntotalpercent,((size(
        __ntotalpercent) - _remntotalpercent)+ 1),__ntotalpercent)))
    SET drawheight_ntotalpercent = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remntotalpercent = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remntotalpercent,((size(__ntotalpercent)
        - _remntotalpercent)+ 1),__ntotalpercent)))))
     SET _remntotalpercent = (_remntotalpercent+ rptsd->m_drawlength)
    ELSE
     SET _remntotalpercent = 0
    ENDIF
    SET growsum = (growsum+ _remntotalpercent)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.719
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnsponsor = _remnsponsor
   IF (_remnsponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnsponsor,((size(
        __nsponsor) - _remnsponsor)+ 1),__nsponsor)))
    SET drawheight_nsponsor = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnsponsor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnsponsor,((size(__nsponsor) -
       _remnsponsor)+ 1),__nsponsor)))))
     SET _remnsponsor = (_remnsponsor+ rptsd->m_drawlength)
    ELSE
     SET _remnsponsor = 0
    ENDIF
    SET growsum = (growsum+ _remnsponsor)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.375)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 4.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ntitle2)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = drawheight_nprotocolmnemonic
   SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
   IF (ncalc=rpt_render
    AND _holdremnprotocolmnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnprotocolmnemonic,
       ((size(__nprotocolmnemonic) - _holdremnprotocolmnemonic)+ 1),__nprotocolmnemonic)))
   ELSE
    SET _remnprotocolmnemonic = _holdremnprotocolmnemonic
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.265),(offsetx+ 9.979),(offsety+
     1.265))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = drawheight_nactivationdate
   IF (ncalc=rpt_render
    AND _holdremnactivationdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnactivationdate,((
       size(__nactivationdate) - _holdremnactivationdate)+ 1),__nactivationdate)))
   ELSE
    SET _remnactivationdate = _holdremnactivationdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.813)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = drawheight_nstatus
   IF (ncalc=rpt_render
    AND _holdremnstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnstatus,((size(
        __nstatus) - _holdremnstatus)+ 1),__nstatus)))
   ELSE
    SET _remnstatus = _holdremnstatus
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.063)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = drawheight_ntrialwideaccrual
   IF (ncalc=rpt_render
    AND _holdremntrialwideaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntrialwideaccrual,
       ((size(__ntrialwideaccrual) - _holdremntrialwideaccrual)+ 1),__ntrialwideaccrual)))
   ELSE
    SET _remntrialwideaccrual = _holdremntrialwideaccrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.323)
   SET rptsd->m_width = 0.990
   SET rptsd->m_height = drawheight_nprojectedaccrual
   IF (ncalc=rpt_render
    AND _holdremnprojectedaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnprojectedaccrual,
       ((size(__nprojectedaccrual) - _holdremnprojectedaccrual)+ 1),__nprojectedaccrual)))
   ELSE
    SET _remnprojectedaccrual = _holdremnprojectedaccrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.865
   SET rptsd->m_height = drawheight_targetaccrual
   IF (ncalc=rpt_render
    AND _holdremtargetaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtargetaccrual,((
       size(__targetaccrual) - _holdremtargetaccrual)+ 1),__targetaccrual)))
   ELSE
    SET _remtargetaccrual = _holdremtargetaccrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = drawheight_ntotalpercent
   IF (ncalc=rpt_render
    AND _holdremntotalpercent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremntotalpercent,((
       size(__ntotalpercent) - _holdremntotalpercent)+ 1),__ntotalpercent)))
   ELSE
    SET _remntotalpercent = _holdremntotalpercent
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.719
   SET rptsd->m_height = drawheight_nsponsor
   IF (ncalc=rpt_render
    AND _holdremnsponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnsponsor,((size(
        __nsponsor) - _holdremnsponsor)+ 1),__nsponsor)))
   ELSE
    SET _remnsponsor = _holdremnsponsor
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.021)
   SET rptsd->m_x = (offsetx+ 3.042)
   SET rptsd->m_width = 4.458
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__title1)
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
 SUBROUTINE headpagesection1(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection1abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.400000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_npro_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_nact_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_site_wide_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_projected_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_target_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_total_percent = f8 WITH noconstant(0.0), private
   DECLARE drawheight_sponsor = f8 WITH noconstant(0.0), private
   DECLARE __npro_mnemonic = vc WITH noconstant(build2(report_labels->m_s_prot_mnemonic_header,char(0
      ))), protect
   DECLARE __nact_date = vc WITH noconstant(build2(report_labels->m_s_act_date_header,char(0))),
   protect
   DECLARE __status = vc WITH noconstant(build2(report_labels->m_s_status_header,char(0))), protect
   DECLARE __site_wide_accrual = vc WITH noconstant(build2(report_labels->
     m_s_site_target_accrual_header,char(0))), protect
   DECLARE __projected_accrual = vc WITH noconstant(build2(report_labels->
     m_s_projected_accrual_header,char(0))), protect
   DECLARE __target_accrual = vc WITH noconstant(build2(report_labels->m_s_site_target_accrual_header,
     char(0))), protect
   DECLARE __total_percent = vc WITH noconstant(build2(report_labels->m_s_percent_site_header,char(0)
     )), protect
   DECLARE __sponsor = vc WITH noconstant(build2(report_labels->m_s_sponsor_header,char(0))), protect
   DECLARE __fieldname9 = vc WITH noconstant(build2(report_labels->report_title,char(0))), protect
   DECLARE __fieldname10 = vc WITH noconstant(build2(report_labels->sorted_by,char(0))), protect
   IF (bcontinue=0)
    SET _remnpro_mnemonic = 1
    SET _remnact_date = 1
    SET _remstatus = 1
    SET _remsite_wide_accrual = 1
    SET _remprojected_accrual = 1
    SET _remtarget_accrual = 1
    SET _remtotal_percent = 1
    SET _remsponsor = 1
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
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremnpro_mnemonic = _remnpro_mnemonic
   IF (_remnpro_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnpro_mnemonic,((size(
        __npro_mnemonic) - _remnpro_mnemonic)+ 1),__npro_mnemonic)))
    SET drawheight_npro_mnemonic = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnpro_mnemonic = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnpro_mnemonic,((size(__npro_mnemonic)
        - _remnpro_mnemonic)+ 1),__npro_mnemonic)))))
     SET _remnpro_mnemonic = (_remnpro_mnemonic+ rptsd->m_drawlength)
    ELSE
     SET _remnpro_mnemonic = 0
    ENDIF
    SET growsum = (growsum+ _remnpro_mnemonic)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnact_date = _remnact_date
   IF (_remnact_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnact_date,((size(
        __nact_date) - _remnact_date)+ 1),__nact_date)))
    SET drawheight_nact_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnact_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnact_date,((size(__nact_date) -
       _remnact_date)+ 1),__nact_date)))))
     SET _remnact_date = (_remnact_date+ rptsd->m_drawlength)
    ELSE
     SET _remnact_date = 0
    ENDIF
    SET growsum = (growsum+ _remnact_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.688)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremstatus = _remstatus
   IF (_remstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remstatus,((size(__status
        ) - _remstatus)+ 1),__status)))
    SET drawheight_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remstatus = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remstatus,((size(__status) - _remstatus)
       + 1),__status)))))
     SET _remstatus = (_remstatus+ rptsd->m_drawlength)
    ELSE
     SET _remstatus = 0
    ENDIF
    SET growsum = (growsum+ _remstatus)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.938)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremsite_wide_accrual = _remsite_wide_accrual
   IF (_remsite_wide_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsite_wide_accrual,((
       size(__site_wide_accrual) - _remsite_wide_accrual)+ 1),__site_wide_accrual)))
    SET drawheight_site_wide_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsite_wide_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsite_wide_accrual,((size(
        __site_wide_accrual) - _remsite_wide_accrual)+ 1),__site_wide_accrual)))))
     SET _remsite_wide_accrual = (_remsite_wide_accrual+ rptsd->m_drawlength)
    ELSE
     SET _remsite_wide_accrual = 0
    ENDIF
    SET growsum = (growsum+ _remsite_wide_accrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 0.906
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremprojected_accrual = _remprojected_accrual
   IF (_remprojected_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprojected_accrual,((
       size(__projected_accrual) - _remprojected_accrual)+ 1),__projected_accrual)))
    SET drawheight_projected_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprojected_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprojected_accrual,((size(
        __projected_accrual) - _remprojected_accrual)+ 1),__projected_accrual)))))
     SET _remprojected_accrual = (_remprojected_accrual+ rptsd->m_drawlength)
    ELSE
     SET _remprojected_accrual = 0
    ENDIF
    SET growsum = (growsum+ _remprojected_accrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.688)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtarget_accrual = _remtarget_accrual
   IF (_remtarget_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtarget_accrual,((size(
        __target_accrual) - _remtarget_accrual)+ 1),__target_accrual)))
    SET drawheight_target_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtarget_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtarget_accrual,((size(__target_accrual
        ) - _remtarget_accrual)+ 1),__target_accrual)))))
     SET _remtarget_accrual = (_remtarget_accrual+ rptsd->m_drawlength)
    ELSE
     SET _remtarget_accrual = 0
    ENDIF
    SET growsum = (growsum+ _remtarget_accrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.063)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtotal_percent = _remtotal_percent
   IF (_remtotal_percent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_percent,((size(
        __total_percent) - _remtotal_percent)+ 1),__total_percent)))
    SET drawheight_total_percent = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_percent = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_percent,((size(__total_percent)
        - _remtotal_percent)+ 1),__total_percent)))))
     SET _remtotal_percent = (_remtotal_percent+ rptsd->m_drawlength)
    ELSE
     SET _remtotal_percent = 0
    ENDIF
    SET growsum = (growsum+ _remtotal_percent)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.063)
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremsponsor = _remsponsor
   IF (_remsponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsponsor,((size(
        __sponsor) - _remsponsor)+ 1),__sponsor)))
    SET drawheight_sponsor = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsponsor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsponsor,((size(__sponsor) -
       _remsponsor)+ 1),__sponsor)))))
     SET _remsponsor = (_remsponsor+ rptsd->m_drawlength)
    ELSE
     SET _remsponsor = 0
    ENDIF
    SET growsum = (growsum+ _remsponsor)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = drawheight_npro_mnemonic
   IF (ncalc=rpt_render
    AND _holdremnpro_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnpro_mnemonic,((
       size(__npro_mnemonic) - _holdremnpro_mnemonic)+ 1),__npro_mnemonic)))
   ELSE
    SET _remnpro_mnemonic = _holdremnpro_mnemonic
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_nact_date
   IF (ncalc=rpt_render
    AND _holdremnact_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnact_date,((size(
        __nact_date) - _holdremnact_date)+ 1),__nact_date)))
   ELSE
    SET _remnact_date = _holdremnact_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.688)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = drawheight_status
   IF (ncalc=rpt_render
    AND _holdremstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremstatus,((size(
        __status) - _holdremstatus)+ 1),__status)))
   ELSE
    SET _remstatus = _holdremstatus
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.938)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_site_wide_accrual
   IF (ncalc=rpt_render
    AND _holdremsite_wide_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsite_wide_accrual,
       ((size(__site_wide_accrual) - _holdremsite_wide_accrual)+ 1),__site_wide_accrual)))
   ELSE
    SET _remsite_wide_accrual = _holdremsite_wide_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 0.906
   SET rptsd->m_height = drawheight_projected_accrual
   IF (ncalc=rpt_render
    AND _holdremprojected_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprojected_accrual,
       ((size(__projected_accrual) - _holdremprojected_accrual)+ 1),__projected_accrual)))
   ELSE
    SET _remprojected_accrual = _holdremprojected_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.688)
   SET rptsd->m_width = 0.844
   SET rptsd->m_height = drawheight_target_accrual
   IF (ncalc=rpt_render
    AND _holdremtarget_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtarget_accrual,((
       size(__target_accrual) - _holdremtarget_accrual)+ 1),__target_accrual)))
   ELSE
    SET _remtarget_accrual = _holdremtarget_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.063)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = drawheight_total_percent
   IF (ncalc=rpt_render
    AND _holdremtotal_percent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_percent,((
       size(__total_percent) - _holdremtotal_percent)+ 1),__total_percent)))
   ELSE
    SET _remtotal_percent = _holdremtotal_percent
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.063)
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = drawheight_sponsor
   IF (ncalc=rpt_render
    AND _holdremsponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsponsor,((size(
        __sponsor) - _holdremsponsor)+ 1),__sponsor)))
   ELSE
    SET _remsponsor = _holdremsponsor
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.255),(offsetx+ 10.000),(offsety
     + 1.255))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.063)
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 4.760
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname9)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.438)
   SET rptsd->m_x = (offsetx+ 2.938)
   SET rptsd->m_width = 4.906
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
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
 SUBROUTINE headpagesection2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.590000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname3 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname4 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname5 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname6 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname7 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname8 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname9 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname10 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(report_labels->m_s_act_date_header,char(0))),
   protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(report_labels->m_s_status_header,char(0))),
   protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(report_labels->m_s_trial_cur_accrual_header,char(
      0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(report_labels->m_s_trial_target_accrual_header,
     char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(report_labels->m_s_percent_trial_header,char(0))),
   protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(report_labels->m_s_site_target_accrual_header,
     char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2(report_labels->m_s_prot_mnemonic_header,char(0))),
   protect
   DECLARE __fieldname8 = vc WITH noconstant(build2(report_labels->m_s_percent_site_header,char(0))),
   protect
   DECLARE __fieldname9 = vc WITH noconstant(build2(report_labels->m_s_sponsor_header,char(0))),
   protect
   DECLARE __fieldname10 = vc WITH noconstant(build2(report_labels->m_s_site_cur_accrual_header,char(
      0))), protect
   DECLARE __fieldname12 = vc WITH noconstant(build2(report_labels->report_title,char(0))), protect
   DECLARE __fieldname13 = vc WITH noconstant(build2(report_labels->sorted_by,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
    SET _remfieldname1 = 1
    SET _remfieldname3 = 1
    SET _remfieldname4 = 1
    SET _remfieldname5 = 1
    SET _remfieldname6 = 1
    SET _remfieldname7 = 1
    SET _remfieldname8 = 1
    SET _remfieldname9 = 1
    SET _remfieldname10 = 1
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
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.604
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname0 = _remfieldname0
   IF (_remfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
        __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
    SET drawheight_fieldname0 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
       _remfieldname0)+ 1),__fieldname0)))))
     SET _remfieldname0 = (_remfieldname0+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname0 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname0)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.562)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname3 = _remfieldname3
   IF (_remfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname3,((size(
        __fieldname3) - _remfieldname3)+ 1),__fieldname3)))
    SET drawheight_fieldname3 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname3 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname3,((size(__fieldname3) -
       _remfieldname3)+ 1),__fieldname3)))))
     SET _remfieldname3 = (_remfieldname3+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname3 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname3)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname4 = _remfieldname4
   IF (_remfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname4,((size(
        __fieldname4) - _remfieldname4)+ 1),__fieldname4)))
    SET drawheight_fieldname4 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname4,((size(__fieldname4) -
       _remfieldname4)+ 1),__fieldname4)))))
     SET _remfieldname4 = (_remfieldname4+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname4 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname4)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname5 = _remfieldname5
   IF (_remfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname5,((size(
        __fieldname5) - _remfieldname5)+ 1),__fieldname5)))
    SET drawheight_fieldname5 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname5 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname5,((size(__fieldname5) -
       _remfieldname5)+ 1),__fieldname5)))))
     SET _remfieldname5 = (_remfieldname5+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname5 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname5)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname6 = _remfieldname6
   IF (_remfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname6,((size(
        __fieldname6) - _remfieldname6)+ 1),__fieldname6)))
    SET drawheight_fieldname6 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname6,((size(__fieldname6) -
       _remfieldname6)+ 1),__fieldname6)))))
     SET _remfieldname6 = (_remfieldname6+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname6 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname6)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.729
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname7 = _remfieldname7
   IF (_remfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname7,((size(
        __fieldname7) - _remfieldname7)+ 1),__fieldname7)))
    SET drawheight_fieldname7 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname7 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname7,((size(__fieldname7) -
       _remfieldname7)+ 1),__fieldname7)))))
     SET _remfieldname7 = (_remfieldname7+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname7 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname7)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 0.646
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname8 = _remfieldname8
   IF (_remfieldname8 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname8,((size(
        __fieldname8) - _remfieldname8)+ 1),__fieldname8)))
    SET drawheight_fieldname8 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname8 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname8,((size(__fieldname8) -
       _remfieldname8)+ 1),__fieldname8)))))
     SET _remfieldname8 = (_remfieldname8+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname8 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname8)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.063)
   SET rptsd->m_width = 0.677
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname9 = _remfieldname9
   IF (_remfieldname9 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname9,((size(
        __fieldname9) - _remfieldname9)+ 1),__fieldname9)))
    SET drawheight_fieldname9 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname9 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname9,((size(__fieldname9) -
       _remfieldname9)+ 1),__fieldname9)))))
     SET _remfieldname9 = (_remfieldname9+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname9 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname9)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname10 = _remfieldname10
   IF (_remfieldname10 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname10,((size(
        __fieldname10) - _remfieldname10)+ 1),__fieldname10)))
    SET drawheight_fieldname10 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname10 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname10,((size(__fieldname10) -
       _remfieldname10)+ 1),__fieldname10)))))
     SET _remfieldname10 = (_remfieldname10+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname10 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname10)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.563)
   SET rptsd->m_width = 0.604
   SET rptsd->m_height = drawheight_fieldname0
   IF (ncalc=rpt_render
    AND _holdremfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size(
        __fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
   ELSE
    SET _remfieldname0 = _holdremfieldname0
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.563)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.562)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_fieldname3
   IF (ncalc=rpt_render
    AND _holdremfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname3,((size(
        __fieldname3) - _holdremfieldname3)+ 1),__fieldname3)))
   ELSE
    SET _remfieldname3 = _holdremfieldname3
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = drawheight_fieldname4
   IF (ncalc=rpt_render
    AND _holdremfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname4,((size(
        __fieldname4) - _holdremfieldname4)+ 1),__fieldname4)))
   ELSE
    SET _remfieldname4 = _holdremfieldname4
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = drawheight_fieldname5
   IF (ncalc=rpt_render
    AND _holdremfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname5,((size(
        __fieldname5) - _holdremfieldname5)+ 1),__fieldname5)))
   ELSE
    SET _remfieldname5 = _holdremfieldname5
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = drawheight_fieldname6
   IF (ncalc=rpt_render
    AND _holdremfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname6,((size(
        __fieldname6) - _holdremfieldname6)+ 1),__fieldname6)))
   ELSE
    SET _remfieldname6 = _holdremfieldname6
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.729
   SET rptsd->m_height = drawheight_fieldname7
   IF (ncalc=rpt_render
    AND _holdremfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname7,((size(
        __fieldname7) - _holdremfieldname7)+ 1),__fieldname7)))
   ELSE
    SET _remfieldname7 = _holdremfieldname7
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 0.646
   SET rptsd->m_height = drawheight_fieldname8
   IF (ncalc=rpt_render
    AND _holdremfieldname8 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname8,((size(
        __fieldname8) - _holdremfieldname8)+ 1),__fieldname8)))
   ELSE
    SET _remfieldname8 = _holdremfieldname8
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.063)
   SET rptsd->m_width = 0.677
   SET rptsd->m_height = drawheight_fieldname9
   IF (ncalc=rpt_render
    AND _holdremfieldname9 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname9,((size(
        __fieldname9) - _holdremfieldname9)+ 1),__fieldname9)))
   ELSE
    SET _remfieldname9 = _holdremfieldname9
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.813)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = drawheight_fieldname10
   IF (ncalc=rpt_render
    AND _holdremfieldname10 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname10,((size
       (__fieldname10) - _holdremfieldname10)+ 1),__fieldname10)))
   ELSE
    SET _remfieldname10 = _holdremfieldname10
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.505),(offsetx+ 9.938),(offsety+
     1.505))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.063)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname12)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.375)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 10.000
   SET rptsd->m_height = 0.281
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname13)
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
 SUBROUTINE headreport_sorting_fieldsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreport_sorting_fieldsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreport_sorting_fieldsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headprot_idsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headprot_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headprot_idsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.090000), private
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
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_protocol_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE drawheight_activation_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_status = f8 WITH noconstant(0.0), private
   DECLARE drawheight_trialaccrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_proj_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_target_accrual = f8 WITH noconstant(0.0), private
   DECLARE drawheight_total_percent = f8 WITH noconstant(0.0), private
   DECLARE drawheight_sponsor = f8 WITH noconstant(0.0), private
   DECLARE __protocol_mnemonic = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __activation_date = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   DECLARE __status = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __trialaccrual = vc WITH noconstant(build2(tmp_tw_cur_acc,char(0))), protect
   DECLARE __proj_accrual = vc WITH noconstant(build2(tmp_prj_acc,char(0))), protect
   DECLARE __target_accrual = vc WITH noconstant(build2(tmp_tw_targ,char(0))), protect
   DECLARE __total_percent = vc WITH noconstant(build2(tmp_tw_percent,char(0))), protect
   DECLARE __sponsor = vc WITH noconstant(build2(tmp_sponsor,char(0))), protect
   IF (bcontinue=0)
    SET _remprotocol_mnemonic = 1
    SET _remactivation_date = 1
    SET _remstatus = 1
    SET _remtrialaccrual = 1
    SET _remproj_accrual = 1
    SET _remtarget_accrual = 1
    SET _remtotal_percent = 1
    SET _remsponsor = 1
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
   SET rptsd->m_x = (offsetx+ 0.125)
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremactivation_date = _remactivation_date
   IF (_remactivation_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remactivation_date,((size
       (__activation_date) - _remactivation_date)+ 1),__activation_date)))
    SET drawheight_activation_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remactivation_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remactivation_date,((size(
        __activation_date) - _remactivation_date)+ 1),__activation_date)))))
     SET _remactivation_date = (_remactivation_date+ rptsd->m_drawlength)
    ELSE
     SET _remactivation_date = 0
    ENDIF
    SET growsum = (growsum+ _remactivation_date)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.813)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremstatus = _remstatus
   IF (_remstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remstatus,((size(__status
        ) - _remstatus)+ 1),__status)))
    SET drawheight_status = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remstatus = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remstatus,((size(__status) - _remstatus)
       + 1),__status)))))
     SET _remstatus = (_remstatus+ rptsd->m_drawlength)
    ELSE
     SET _remstatus = 0
    ENDIF
    SET growsum = (growsum+ _remstatus)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.073)
   SET rptsd->m_width = 0.865
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtrialaccrual = _remtrialaccrual
   IF (_remtrialaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtrialaccrual,((size(
        __trialaccrual) - _remtrialaccrual)+ 1),__trialaccrual)))
    SET drawheight_trialaccrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtrialaccrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtrialaccrual,((size(__trialaccrual) -
       _remtrialaccrual)+ 1),__trialaccrual)))))
     SET _remtrialaccrual = (_remtrialaccrual+ rptsd->m_drawlength)
    ELSE
     SET _remtrialaccrual = 0
    ENDIF
    SET growsum = (growsum+ _remtrialaccrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 0.906
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremproj_accrual = _remproj_accrual
   IF (_remproj_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remproj_accrual,((size(
        __proj_accrual) - _remproj_accrual)+ 1),__proj_accrual)))
    SET drawheight_proj_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remproj_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remproj_accrual,((size(__proj_accrual) -
       _remproj_accrual)+ 1),__proj_accrual)))))
     SET _remproj_accrual = (_remproj_accrual+ rptsd->m_drawlength)
    ELSE
     SET _remproj_accrual = 0
    ENDIF
    SET growsum = (growsum+ _remproj_accrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtarget_accrual = _remtarget_accrual
   IF (_remtarget_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtarget_accrual,((size(
        __target_accrual) - _remtarget_accrual)+ 1),__target_accrual)))
    SET drawheight_target_accrual = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtarget_accrual = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtarget_accrual,((size(__target_accrual
        ) - _remtarget_accrual)+ 1),__target_accrual)))))
     SET _remtarget_accrual = (_remtarget_accrual+ rptsd->m_drawlength)
    ELSE
     SET _remtarget_accrual = 0
    ENDIF
    SET growsum = (growsum+ _remtarget_accrual)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 0.833
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtotal_percent = _remtotal_percent
   IF (_remtotal_percent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_percent,((size(
        __total_percent) - _remtotal_percent)+ 1),__total_percent)))
    SET drawheight_total_percent = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_percent = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_percent,((size(__total_percent)
        - _remtotal_percent)+ 1),__total_percent)))))
     SET _remtotal_percent = (_remtotal_percent+ rptsd->m_drawlength)
    ELSE
     SET _remtotal_percent = 0
    ENDIF
    SET growsum = (growsum+ _remtotal_percent)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremsponsor = _remsponsor
   IF (_remsponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsponsor,((size(
        __sponsor) - _remsponsor)+ 1),__sponsor)))
    SET drawheight_sponsor = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsponsor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsponsor,((size(__sponsor) -
       _remsponsor)+ 1),__sponsor)))))
     SET _remsponsor = (_remsponsor+ rptsd->m_drawlength)
    ELSE
     SET _remsponsor = 0
    ENDIF
    SET growsum = (growsum+ _remsponsor)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.938
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
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = drawheight_activation_date
   IF (ncalc=rpt_render
    AND _holdremactivation_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremactivation_date,((
       size(__activation_date) - _holdremactivation_date)+ 1),__activation_date)))
   ELSE
    SET _remactivation_date = _holdremactivation_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.813)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = drawheight_status
   IF (ncalc=rpt_render
    AND _holdremstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremstatus,((size(
        __status) - _holdremstatus)+ 1),__status)))
   ELSE
    SET _remstatus = _holdremstatus
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.073)
   SET rptsd->m_width = 0.865
   SET rptsd->m_height = drawheight_trialaccrual
   IF (ncalc=rpt_render
    AND _holdremtrialaccrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtrialaccrual,((
       size(__trialaccrual) - _holdremtrialaccrual)+ 1),__trialaccrual)))
   ELSE
    SET _remtrialaccrual = _holdremtrialaccrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 0.906
   SET rptsd->m_height = drawheight_proj_accrual
   IF (ncalc=rpt_render
    AND _holdremproj_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremproj_accrual,((
       size(__proj_accrual) - _holdremproj_accrual)+ 1),__proj_accrual)))
   ELSE
    SET _remproj_accrual = _holdremproj_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.875)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = drawheight_target_accrual
   IF (ncalc=rpt_render
    AND _holdremtarget_accrual > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtarget_accrual,((
       size(__target_accrual) - _holdremtarget_accrual)+ 1),__target_accrual)))
   ELSE
    SET _remtarget_accrual = _holdremtarget_accrual
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 0.833
   SET rptsd->m_height = drawheight_total_percent
   IF (ncalc=rpt_render
    AND _holdremtotal_percent > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_percent,((
       size(__total_percent) - _holdremtotal_percent)+ 1),__total_percent)))
   ELSE
    SET _remtotal_percent = _holdremtotal_percent
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = drawheight_sponsor
   IF (ncalc=rpt_render
    AND _holdremsponsor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsponsor,((size(
        __sponsor) - _holdremsponsor)+ 1),__sponsor)))
   ELSE
    SET _remsponsor = _holdremsponsor
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
 SUBROUTINE detailsection2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsection2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname2 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname3 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname4 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname5 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname6 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname7 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(tmp_site_cur_acc,char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(tmp_site_prj_acc,char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(tmp_site_targ,char(0))), protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(tmp_site_percent,char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2(tmp_sponsor,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
    SET _remfieldname1 = 1
    SET _remfieldname2 = 1
    SET _remfieldname3 = 1
    SET _remfieldname4 = 1
    SET _remfieldname5 = 1
    SET _remfieldname6 = 1
    SET _remfieldname7 = 1
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
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname0 = _remfieldname0
   IF (_remfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
        __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
    SET drawheight_fieldname0 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
       _remfieldname0)+ 1),__fieldname0)))))
     SET _remfieldname0 = (_remfieldname0+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname0 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname0)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname2 = _remfieldname2
   IF (_remfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname2,((size(
        __fieldname2) - _remfieldname2)+ 1),__fieldname2)))
    SET drawheight_fieldname2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname2,((size(__fieldname2) -
       _remfieldname2)+ 1),__fieldname2)))))
     SET _remfieldname2 = (_remfieldname2+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname2 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname2)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname3 = _remfieldname3
   IF (_remfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname3,((size(
        __fieldname3) - _remfieldname3)+ 1),__fieldname3)))
    SET drawheight_fieldname3 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname3 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname3,((size(__fieldname3) -
       _remfieldname3)+ 1),__fieldname3)))))
     SET _remfieldname3 = (_remfieldname3+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname3 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname3)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.833
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname4 = _remfieldname4
   IF (_remfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname4,((size(
        __fieldname4) - _remfieldname4)+ 1),__fieldname4)))
    SET drawheight_fieldname4 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname4,((size(__fieldname4) -
       _remfieldname4)+ 1),__fieldname4)))))
     SET _remfieldname4 = (_remfieldname4+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname4 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname4)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname5 = _remfieldname5
   IF (_remfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname5,((size(
        __fieldname5) - _remfieldname5)+ 1),__fieldname5)))
    SET drawheight_fieldname5 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname5 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname5,((size(__fieldname5) -
       _remfieldname5)+ 1),__fieldname5)))))
     SET _remfieldname5 = (_remfieldname5+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname5 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname5)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname6 = _remfieldname6
   IF (_remfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname6,((size(
        __fieldname6) - _remfieldname6)+ 1),__fieldname6)))
    SET drawheight_fieldname6 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname6,((size(__fieldname6) -
       _remfieldname6)+ 1),__fieldname6)))))
     SET _remfieldname6 = (_remfieldname6+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname6 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname6)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.646
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname7 = _remfieldname7
   IF (_remfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname7,((size(
        __fieldname7) - _remfieldname7)+ 1),__fieldname7)))
    SET drawheight_fieldname7 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname7 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname7,((size(__fieldname7) -
       _remfieldname7)+ 1),__fieldname7)))))
     SET _remfieldname7 = (_remfieldname7+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname7 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname7)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_fieldname0
   IF (ncalc=rpt_render
    AND _holdremfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size(
        __fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
   ELSE
    SET _remfieldname0 = _holdremfieldname0
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_fieldname2
   IF (ncalc=rpt_render
    AND _holdremfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname2,((size(
        __fieldname2) - _holdremfieldname2)+ 1),__fieldname2)))
   ELSE
    SET _remfieldname2 = _holdremfieldname2
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_fieldname3
   IF (ncalc=rpt_render
    AND _holdremfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname3,((size(
        __fieldname3) - _holdremfieldname3)+ 1),__fieldname3)))
   ELSE
    SET _remfieldname3 = _holdremfieldname3
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.313)
   SET rptsd->m_width = 0.833
   SET rptsd->m_height = drawheight_fieldname4
   IF (ncalc=rpt_render
    AND _holdremfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname4,((size(
        __fieldname4) - _holdremfieldname4)+ 1),__fieldname4)))
   ELSE
    SET _remfieldname4 = _holdremfieldname4
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_fieldname5
   IF (ncalc=rpt_render
    AND _holdremfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname5,((size(
        __fieldname5) - _holdremfieldname5)+ 1),__fieldname5)))
   ELSE
    SET _remfieldname5 = _holdremfieldname5
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_fieldname6
   IF (ncalc=rpt_render
    AND _holdremfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname6,((size(
        __fieldname6) - _holdremfieldname6)+ 1),__fieldname6)))
   ELSE
    SET _remfieldname6 = _holdremfieldname6
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.646
   SET rptsd->m_height = drawheight_fieldname7
   IF (ncalc=rpt_render
    AND _holdremfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname7,((size(
        __fieldname7) - _holdremfieldname7)+ 1),__fieldname7)))
   ELSE
    SET _remfieldname7 = _holdremfieldname7
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
 SUBROUTINE detailsection1(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsection1abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname2 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname3 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname5 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname6 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname7 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname8 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname9 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname4 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(tmp_prot,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(tmp_act_date,char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(tmp_status,char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(tmp_tw_cur_acc,char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(tmp_tw_percent,char(0))), protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(tmp_site_cur_acc,char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2(tmp_site_targ,char(0))), protect
   DECLARE __fieldname8 = vc WITH noconstant(build2(tmp_site_percent,char(0))), protect
   DECLARE __fieldname9 = vc WITH noconstant(build2(tmp_sponsor,char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(tmp_tw_targ,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
    SET _remfieldname1 = 1
    SET _remfieldname2 = 1
    SET _remfieldname3 = 1
    SET _remfieldname5 = 1
    SET _remfieldname6 = 1
    SET _remfieldname7 = 1
    SET _remfieldname8 = 1
    SET _remfieldname9 = 1
    SET _remfieldname4 = 1
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
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname0 = _remfieldname0
   IF (_remfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
        __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
    SET drawheight_fieldname0 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
       _remfieldname0)+ 1),__fieldname0)))))
     SET _remfieldname0 = (_remfieldname0+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname0 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname0)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname2 = _remfieldname2
   IF (_remfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname2,((size(
        __fieldname2) - _remfieldname2)+ 1),__fieldname2)))
    SET drawheight_fieldname2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname2,((size(__fieldname2) -
       _remfieldname2)+ 1),__fieldname2)))))
     SET _remfieldname2 = (_remfieldname2+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname2 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname2)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.562)
   SET rptsd->m_width = 0.708
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname3 = _remfieldname3
   IF (_remfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname3,((size(
        __fieldname3) - _remfieldname3)+ 1),__fieldname3)))
    SET drawheight_fieldname3 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname3 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname3,((size(__fieldname3) -
       _remfieldname3)+ 1),__fieldname3)))))
     SET _remfieldname3 = (_remfieldname3+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname3 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname3)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname5 = _remfieldname5
   IF (_remfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname5,((size(
        __fieldname5) - _remfieldname5)+ 1),__fieldname5)))
    SET drawheight_fieldname5 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname5 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname5,((size(__fieldname5) -
       _remfieldname5)+ 1),__fieldname5)))))
     SET _remfieldname5 = (_remfieldname5+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname5 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname5)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 0.573
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname6 = _remfieldname6
   IF (_remfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname6,((size(
        __fieldname6) - _remfieldname6)+ 1),__fieldname6)))
    SET drawheight_fieldname6 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname6,((size(__fieldname6) -
       _remfieldname6)+ 1),__fieldname6)))))
     SET _remfieldname6 = (_remfieldname6+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname6 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname6)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.656
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname7 = _remfieldname7
   IF (_remfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname7,((size(
        __fieldname7) - _remfieldname7)+ 1),__fieldname7)))
    SET drawheight_fieldname7 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname7 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname7,((size(__fieldname7) -
       _remfieldname7)+ 1),__fieldname7)))))
     SET _remfieldname7 = (_remfieldname7+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname7 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname7)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 0.604
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname8 = _remfieldname8
   IF (_remfieldname8 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname8,((size(
        __fieldname8) - _remfieldname8)+ 1),__fieldname8)))
    SET drawheight_fieldname8 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname8 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname8,((size(__fieldname8) -
       _remfieldname8)+ 1),__fieldname8)))))
     SET _remfieldname8 = (_remfieldname8+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname8 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname8)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname9 = _remfieldname9
   IF (_remfieldname9 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname9,((size(
        __fieldname9) - _remfieldname9)+ 1),__fieldname9)))
    SET drawheight_fieldname9 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname9 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname9,((size(__fieldname9) -
       _remfieldname9)+ 1),__fieldname9)))))
     SET _remfieldname9 = (_remfieldname9+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname9 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname9)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 0.823
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname4 = _remfieldname4
   IF (_remfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname4,((size(
        __fieldname4) - _remfieldname4)+ 1),__fieldname4)))
    SET drawheight_fieldname4 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname4,((size(__fieldname4) -
       _remfieldname4)+ 1),__fieldname4)))))
     SET _remfieldname4 = (_remfieldname4+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname4 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname4)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.125)
   SET rptsd->m_width = 0.771
   SET rptsd->m_height = drawheight_fieldname0
   IF (ncalc=rpt_render
    AND _holdremfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size(
        __fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
   ELSE
    SET _remfieldname0 = _holdremfieldname0
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_fieldname2
   IF (ncalc=rpt_render
    AND _holdremfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname2,((size(
        __fieldname2) - _holdremfieldname2)+ 1),__fieldname2)))
   ELSE
    SET _remfieldname2 = _holdremfieldname2
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.562)
   SET rptsd->m_width = 0.708
   SET rptsd->m_height = drawheight_fieldname3
   IF (ncalc=rpt_render
    AND _holdremfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname3,((size(
        __fieldname3) - _holdremfieldname3)+ 1),__fieldname3)))
   ELSE
    SET _remfieldname3 = _holdremfieldname3
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.500)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = drawheight_fieldname5
   IF (ncalc=rpt_render
    AND _holdremfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname5,((size(
        __fieldname5) - _holdremfieldname5)+ 1),__fieldname5)))
   ELSE
    SET _remfieldname5 = _holdremfieldname5
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 0.573
   SET rptsd->m_height = drawheight_fieldname6
   IF (ncalc=rpt_render
    AND _holdremfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname6,((size(
        __fieldname6) - _holdremfieldname6)+ 1),__fieldname6)))
   ELSE
    SET _remfieldname6 = _holdremfieldname6
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.250)
   SET rptsd->m_width = 0.656
   SET rptsd->m_height = drawheight_fieldname7
   IF (ncalc=rpt_render
    AND _holdremfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname7,((size(
        __fieldname7) - _holdremfieldname7)+ 1),__fieldname7)))
   ELSE
    SET _remfieldname7 = _holdremfieldname7
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 0.604
   SET rptsd->m_height = drawheight_fieldname8
   IF (ncalc=rpt_render
    AND _holdremfieldname8 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname8,((size(
        __fieldname8) - _holdremfieldname8)+ 1),__fieldname8)))
   ELSE
    SET _remfieldname8 = _holdremfieldname8
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 9.125)
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = drawheight_fieldname9
   IF (ncalc=rpt_render
    AND _holdremfieldname9 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname9,((size(
        __fieldname9) - _holdremfieldname9)+ 1),__fieldname9)))
   ELSE
    SET _remfieldname9 = _holdremfieldname9
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.063)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 0.823
   SET rptsd->m_height = drawheight_fieldname4
   IF (ncalc=rpt_render
    AND _holdremfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname4,((size(
        __fieldname4) - _holdremfieldname4)+ 1),__fieldname4)))
   ELSE
    SET _remfieldname4 = _holdremfieldname4
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
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE __nexecutiontime = vc WITH noconstant(build2(report_labels->execution_timestamp,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.104)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 2.760
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nexecutiontime)
    SET rptsd->m_y = (offsety+ 0.104)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.188
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
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __totalprots = vc WITH noconstant(build2(report_labels->total_prot,char(0))), protect
   IF ((((report_labels->accrual_type=0)) OR ((report_labels->accrual_type=2))) )
    DECLARE __selected_patients = vc WITH noconstant(build2(report_labels->total_patients,char(0))),
    protect
   ENDIF
   IF ((((report_labels->accrual_type=1)) OR ((report_labels->accrual_type=2))) )
    DECLARE __fieldname4 = vc WITH noconstant(build2(report_labels->total_site_pt_accrued,char(0))),
    protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 3.625
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__totalprots)
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 3.813
    SET rptsd->m_height = 0.188
    IF ((((report_labels->accrual_type=0)) OR ((report_labels->accrual_type=2))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__selected_patients)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.188
    IF ((((report_labels->accrual_type=1)) OR ((report_labels->accrual_type=2))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_ENROLLMENT_REP_LO"
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
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_on
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
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
 IF (size(results->protocols,5)=0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    col 0, report_labels->report_title, row + 1,
    col 0, report_labels->execution_timestamp, row + 2,
    col 0, report_labels->m_s_no_prot_found
   WITH nocounter
  ;end select
 ELSEIF ((report_labels->output_type=1))
  SELECT INTO  $OUTDEV
   prot_id = results->protocols[d.seq].prot_master_id
   FROM (dummyt d  WITH seq = value(size(results->protocols,5)))
   ORDER BY parser(report_labels->sorting_field)
   HEAD REPORT
    tw_cur_accrual_sum = 0, site_cur_accrual_sum = 0, col 0,
    report_labels->report_title, row + 1, col 0,
    report_labels->sorted_by, row + 1, col 0,
    report_labels->execution_timestamp, row + 1
    IF (( $ACCRUAL=0))
     tempstr = concat(report_labels->m_s_prot_mnemonic_header,report_labels->delimiter_output,
      report_labels->m_s_act_date_header,report_labels->delimiter_output,report_labels->
      m_s_status_header,
      report_labels->delimiter_output,report_labels->m_s_trial_cur_accrual_header,report_labels->
      delimiter_output,report_labels->m_s_projected_accrual_header,report_labels->delimiter_output,
      report_labels->m_s_trial_target_accrual_header,report_labels->delimiter_output,report_labels->
      m_s_percent_header,report_labels->delimiter_output,report_labels->m_s_sponsor_header)
    ELSEIF (( $ACCRUAL=1))
     tempstr = concat(report_labels->m_s_prot_mnemonic_header,report_labels->delimiter_output,
      report_labels->m_s_act_date_header,report_labels->delimiter_output,report_labels->
      m_s_status_header,
      report_labels->delimiter_output,report_labels->m_s_site_cur_accrual_header,report_labels->
      delimiter_output,report_labels->m_s_projected_accrual_header,report_labels->delimiter_output,
      report_labels->m_s_site_target_accrual_header,report_labels->delimiter_output,report_labels->
      m_s_percent_header,report_labels->delimiter_output,report_labels->m_s_sponsor_header)
    ELSE
     tempstr = concat(report_labels->m_s_prot_mnemonic_header,report_labels->delimiter_output,
      report_labels->m_s_act_date_header,report_labels->delimiter_output,report_labels->
      m_s_status_header,
      report_labels->delimiter_output,report_labels->m_s_trial_cur_accrual_header,report_labels->
      delimiter_output,report_labels->m_s_trial_target_accrual_header,report_labels->delimiter_output,
      report_labels->m_s_percent_trial_header,report_labels->delimiter_output,report_labels->
      m_s_site_cur_accrual_header,report_labels->delimiter_output,report_labels->
      m_s_site_target_accrual_header,
      report_labels->delimiter_output,report_labels->m_s_percent_trial_header,report_labels->
      delimiter_output,report_labels->m_s_sponsor_header)
    ENDIF
    col 0, tempstr, row + 1
   HEAD prot_id
    IF ((results->protocols[d.seq].trialwide_cur_accrual > 0))
     tw_cur_accrual_sum = (tw_cur_accrual_sum+ results->protocols[d.seq].trialwide_cur_accrual)
    ENDIF
    IF ((results->protocols[d.seq].site_cur_accrual > 0))
     site_cur_accrual_sum = (site_cur_accrual_sum+ results->protocols[d.seq].site_cur_accrual)
    ENDIF
   DETAIL
    tmp_prot = results->protocols[d.seq].prot_mnemonic, tmp_act_date = format(results->protocols[d
     .seq].activation_date,"@SHORTDATE"), tmp_status = results->protocols[d.seq].prot_status_disp
    IF ((results->protocols[d.seq].trialwide_cur_accrual < 0))
     tmp_tw_cur_acc = ""
    ELSE
     tmp_tw_cur_acc = cnvtstring(results->protocols[d.seq].trialwide_cur_accrual)
    ENDIF
    IF ((results->protocols[d.seq].trialwide_targeted < 0))
     tmp_tw_targ = ""
    ELSE
     tmp_tw_targ = cnvtstring(results->protocols[d.seq].trialwide_targeted)
    ENDIF
    IF ((results->protocols[d.seq].trialwide_percent=m_s_blank_percent))
     tmp_tw_percent = ""
    ELSE
     tmp_tw_percent = format(results->protocols[d.seq].trialwide_percent,";I;f")
    ENDIF
    IF ((results->protocols[d.seq].trialwide_prj_accrual < 0))
     tmp_prj_acc = ""
    ELSE
     tmp_prj_acc = cnvtstring(results->protocols[d.seq].trialwide_prj_accrual)
    ENDIF
    IF ((results->protocols[d.seq].site_prj_accrual < 0))
     tmp_site_prj_acc = ""
    ELSE
     tmp_site_prj_acc = cnvtstring(results->protocols[d.seq].site_prj_accrual)
    ENDIF
    IF ((results->protocols[d.seq].site_cur_accrual < 0))
     tmp_site_cur_acc = ""
    ELSE
     tmp_site_cur_acc = cnvtstring(results->protocols[d.seq].site_cur_accrual)
    ENDIF
    IF ((results->protocols[d.seq].site_targeted < 0))
     tmp_site_targ = ""
    ELSE
     tmp_site_targ = cnvtstring(results->protocols[d.seq].site_targeted)
    ENDIF
    IF ((results->protocols[d.seq].site_percent=m_s_blank_percent))
     tmp_site_percent = ""
    ELSE
     tmp_site_percent = format(results->protocols[d.seq].site_percent,";I;f")
    ENDIF
    IF ( NOT ((results->protocols[d.seq].primary_sponsor IN ("", " ", null))))
     tmp_sponsor = results->protocols[d.seq].primary_sponsor
    ELSE
     tmp_sponsor = ""
    ENDIF
    tmp_prot = concat('"',trim(tmp_prot,3),'"'), tmp_act_date = concat('"',trim(tmp_act_date,3),'"'),
    tmp_status = concat('"',trim(tmp_status,3),'"'),
    tmp_tw_cur_acc = concat('"',trim(tmp_tw_cur_acc,3),'"'), tmp_prj_acc = concat('"',trim(
      tmp_prj_acc,3),'"'), tmp_tw_targ = concat('"',trim(tmp_tw_targ,3),'"'),
    tmp_tw_percent = concat('"',trim(tmp_tw_percent,3),'"'), tmp_sponsor = concat('"',trim(
      tmp_sponsor,3),'"'), tmp_site_cur_acc = concat('"',trim(tmp_site_cur_acc,3),'"'),
    tmp_site_prj_acc = concat('"',trim(tmp_site_prj_acc,3),'"'), tmp_site_targ = concat('"',trim(
      tmp_site_targ,3),'"'), tmp_site_percent = concat('"',trim(tmp_site_percent,3),'"'),
    tempstr = concat(tmp_prot,report_labels->delimiter_output,tmp_act_date,report_labels->
     delimiter_output,tmp_status)
    IF (( $ACCRUAL=0))
     tempstr = concat(tempstr,report_labels->delimiter_output,tmp_tw_cur_acc,report_labels->
      delimiter_output,tmp_prj_acc,
      report_labels->delimiter_output,tmp_tw_targ,report_labels->delimiter_output,tmp_tw_percent,
      report_labels->delimiter_output,
      tmp_sponsor)
    ELSEIF (( $ACCRUAL=1))
     tempstr = concat(tempstr,report_labels->delimiter_output,tmp_site_cur_acc,report_labels->
      delimiter_output,tmp_site_prj_acc,
      report_labels->delimiter_output,tmp_site_targ,report_labels->delimiter_output,tmp_site_percent,
      report_labels->delimiter_output,
      tmp_sponsor)
    ELSE
     tempstr = concat(tempstr,report_labels->delimiter_output,tmp_tw_cur_acc,report_labels->
      delimiter_output,tmp_tw_targ,
      report_labels->delimiter_output,tmp_tw_percent,report_labels->delimiter_output,tmp_site_cur_acc,
      report_labels->delimiter_output,
      tmp_site_targ,report_labels->delimiter_output,tmp_site_percent,report_labels->delimiter_output,
      tmp_sponsor)
    ENDIF
    col 0, tempstr, row + 1
   FOOT REPORT
    row + 1, tempstr = concat(report_labels->m_s_total_prots_selected," ",trim(cnvtstring(size(
        protlist->protocols,5)))), col 0,
    tempstr
    IF (((( $ACCRUAL=0)) OR (( $ACCRUAL=2))) )
     row + 1, tempstr = concat(report_labels->m_s_total_pts_accrued," ",trim(cnvtstring(
        tw_cur_accrual_sum))), col 0,
     tempstr
    ENDIF
    IF (((( $ACCRUAL=1)) OR (( $ACCRUAL=2))) )
     row + 1, tempstr = concat(report_labels->m_s_total_site_pts_accrued," ",trim(cnvtstring(
        site_cur_accrual_sum))), col 0,
     tempstr
    ENDIF
    row + 2, col 0, report_labels->m_s_end_of_rpt
   WITH format = crstream, formfeed = none, maxcol = 1500,
    nocounter
  ;end select
 ELSE
  CALL initializereport(0)
  CALL ct_get_rpt_enrollment(0)
  CALL finalizereport(_sendto)
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Apr 21, 2016"
END GO
