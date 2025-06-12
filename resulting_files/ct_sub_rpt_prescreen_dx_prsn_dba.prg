CREATE PROGRAM ct_sub_rpt_prescreen_dx_prsn:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Execution Mode:" = "",
  "Evaluation Start Date" = curdate,
  "Evaluation End Date" = curdate,
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Protocols to be Considered:" = "",
  "For Report Order By:" = 0,
  "Gender" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Race" = 0.000000,
  "Ethnicity" = 0.000000,
  "Terminology Codes" = "0.000000",
  "Codes" = "",
  "icd9DefaultHidden" = 0,
  "testOnlyHidden" = 0,
  "Evaluation By:" = 0
  WITH outdev, execmode, startdate,
  enddate, encntrtypecd, facilitycd,
  triggername, orderby, gender,
  qualifier, age1, age2,
  race, ethnicity, terminology,
  codes, icd9defaulthidden, testonlyhidden,
  evalby
 EXECUTE reportrtl
 RECORD paramlists(
   1 etypecnt = i4
   1 eanyflag = i2
   1 equal[*]
     2 etypecd = f8
   1 faccnt = i4
   1 fanyflag = i2
   1 fqual[*]
     2 faccd = f8
   1 protcnt = i4
   1 pqual[*]
     2 primary_mnemonic = vc
 )
 RECORD protlist(
   1 protqual[*]
     2 primary_mnemonic = vc
     2 init_service = vc
     2 prot_master_id = f8
     2 personcnt = i4
     2 personqual[*]
       3 person_id = f8
       3 comment = vc
 )
 RECORD eksctrequest(
   1 opsind = i2
   1 execmodeflag = i2
   1 screenerid = f8
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
     2 currentct[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 checkct[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD eksctreply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_prescreen_results(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE headpagesection1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE headpagesection2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headpagesection2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE headpagesection3(ncalc=i2) = f8 WITH protect
 DECLARE headpagesection3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headp_person_idsection(ncalc=i2) = f8 WITH protect
 DECLARE headp_person_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footp_person_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footp_person_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =
 f8 WITH protect
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
 DECLARE _remscreenerstr = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_patient_view = i4 WITH noconstant(1), protect
 DECLARE _remdate_time = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection1 = i2 WITH noconstant(0), protect
 DECLARE _remlabel_last_name = i4 WITH noconstant(1), protect
 DECLARE _remlabel_first_name = i4 WITH noconstant(1), protect
 DECLARE _remlabel_mrn = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection2 = i2 WITH noconstant(0), protect
 DECLARE _remlast_name = i4 WITH noconstant(1), protect
 DECLARE _remmrn = i4 WITH noconstant(1), protect
 DECLARE _remfirst_name = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_potential_prot = i4 WITH noconstant(1), protect
 DECLARE _remprot_mnemonic = i4 WITH noconstant(1), protect
 DECLARE _bcontfootp_person_idsection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remtotal_patient = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _courier10b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE get_prescreen_results(dummy)
   SELECT
    IF (1=1)
     FROM (dummyt d1  WITH seq = size(eksctreply->qual,5)),
      person p,
      person_alias pa
     PLAN (d1)
      JOIN (p
      WHERE (p.person_id=eksctreply->qual[d1.seq].person_id))
      JOIN (pa
      WHERE pa.person_id=outerjoin(p.person_id)
       AND pa.person_alias_type_cd=outerjoin(mrn_cd)
       AND pa.active_ind=outerjoin(1)
       AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
     ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
      p.person_id
    ELSE
    ENDIF
    ORDER BY p.person_id
    HEAD REPORT
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _bholdcontinue = 0,
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight,((rptreport->m_pageheight -
      rptreport->m_marginbottom) - _yoffset),_bholdcontinue))
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pageheight -
      rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection), _bcontheadpagesection1 = 0,
     dummy_val = headpagesection1(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom)
       - _yoffset),_bcontheadpagesection1), _bcontheadpagesection2 = 0, dummy_val = headpagesection2(
      rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) - _yoffset),
      _bcontheadpagesection2),
     dummy_val = headpagesection3(rpt_render)
    HEAD p.person_id
     bfound = 0
     IF (size(eksctreply->qual[d1.seq].ctqual,5) > 0)
      IF (match_count > 0)
       _fdrawheight = headp_person_idsection(rpt_calcheight)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ENDIF
       dummy_val = headp_person_idsection(rpt_render)
      ENDIF
      tmp_last = p.name_last, tmp_first = p.name_first, bfound = 1,
      match_count = (match_count+ 1)
     ENDIF
     count = 0, mrn_count = 0
    DETAIL
     IF (bfound=1)
      IF (mrn_count > 0)
       tmp_last = " ", tmp_first = " "
      ENDIF
      mrn_count = (mrn_count+ 1), pooldisp = uar_get_code_display(pa.alias_pool_cd)
      IF (size(trim(pooldisp))=0)
       tmp_mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
      ELSE
       tmp_mrn = concat(pooldisp," - ",trim(cnvtalias(pa.alias,pa.alias_pool_cd)))
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
     ENDIF
    FOOT  p.person_id
     FOR (i = 1 TO size(eksctreply->qual[d1.seq].ctqual,5))
       IF (count=0)
        tmp_label = uar_i18ngetmessage(i18nhandle,"POTENTIAL_PRESCREEN_RPT","Potential Protocols: ")
       ELSE
        tmp_label = " "
       ENDIF
       _bcontfootp_person_idsection = 0, bfirsttime = 1
       WHILE (((_bcontfootp_person_idsection=1) OR (bfirsttime=1)) )
         _bholdcontinue = _bcontfootp_person_idsection, _fdrawheight = footp_person_idsection(
          rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
         IF (((_yoffset+ _fdrawheight) > _fenddetail))
          BREAK
         ELSEIF (_bholdcontinue=1
          AND _bcontfootp_person_idsection=0)
          BREAK
         ENDIF
         dummy_val = footp_person_idsection(rpt_render,(_fenddetail - _yoffset),
          _bcontfootp_person_idsection), bfirsttime = 0
       ENDWHILE
       count = (count+ 1)
     ENDFOR
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
     dummy_val = footpagesection(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom) -
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_screenerstr = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_title = vc WITH noconstant(build2(title,char(0))), protect
   DECLARE __screenerstr = vc WITH noconstant(build2(screenerstr,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_title = 1
    SET _remscreenerstr = 1
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
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier10b0)
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
   SET rptsd->m_flags = 69
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremscreenerstr = _remscreenerstr
   IF (_remscreenerstr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remscreenerstr,((size(
        __screenerstr) - _remscreenerstr)+ 1),__screenerstr)))
    SET drawheight_screenerstr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remscreenerstr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remscreenerstr,((size(__screenerstr) -
       _remscreenerstr)+ 1),__screenerstr)))))
     SET _remscreenerstr = (_remscreenerstr+ rptsd->m_drawlength)
    ELSE
     SET _remscreenerstr = 0
    ENDIF
    SET growsum = (growsum+ _remscreenerstr)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = drawheight_label_rpt_title
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_title,((
       size(__label_rpt_title) - _holdremlabel_rpt_title)+ 1),__label_rpt_title)))
   ELSE
    SET _remlabel_rpt_title = _holdremlabel_rpt_title
   ENDIF
   SET rptsd->m_flags = 68
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = drawheight_screenerstr
   IF (ncalc=rpt_render
    AND _holdremscreenerstr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremscreenerstr,((size
       (__screenerstr) - _holdremscreenerstr)+ 1),__screenerstr)))
   ELSE
    SET _remscreenerstr = _holdremscreenerstr
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_patient_view = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date_time = f8 WITH noconstant(0.0), private
   DECLARE __label_patient_view = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "PT_VIEW_PRESCREEN_RPT","Patient View"),char(0))), protect
   DECLARE __date_time = vc WITH noconstant(build2(datestr,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_patient_view = 1
    SET _remdate_time = 1
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
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier10b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_patient_view = _remlabel_patient_view
   IF (_remlabel_patient_view > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_patient_view,((
       size(__label_patient_view) - _remlabel_patient_view)+ 1),__label_patient_view)))
    SET drawheight_label_patient_view = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_patient_view = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_patient_view,((size(
        __label_patient_view) - _remlabel_patient_view)+ 1),__label_patient_view)))))
     SET _remlabel_patient_view = (_remlabel_patient_view+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_patient_view = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_patient_view)
   ENDIF
   SET rptsd->m_flags = 69
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdate_time = _remdate_time
   IF (_remdate_time > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate_time,((size(
        __date_time) - _remdate_time)+ 1),__date_time)))
    SET drawheight_date_time = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate_time = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate_time,((size(__date_time) -
       _remdate_time)+ 1),__date_time)))))
     SET _remdate_time = (_remdate_time+ rptsd->m_drawlength)
    ELSE
     SET _remdate_time = 0
    ENDIF
    SET growsum = (growsum+ _remdate_time)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = drawheight_label_patient_view
   IF (ncalc=rpt_render
    AND _holdremlabel_patient_view > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_patient_view,
       ((size(__label_patient_view) - _holdremlabel_patient_view)+ 1),__label_patient_view)))
   ELSE
    SET _remlabel_patient_view = _holdremlabel_patient_view
   ENDIF
   SET rptsd->m_flags = 68
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = drawheight_date_time
   IF (ncalc=rpt_render
    AND _holdremdate_time > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate_time,((size(
        __date_time) - _holdremdate_time)+ 1),__date_time)))
   ELSE
    SET _remdate_time = _holdremdate_time
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
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_last_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_first_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_mrn = f8 WITH noconstant(0.0), private
   DECLARE __label_last_name = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "LAST_NAME_PRESCREEN_RPT","Last Name"),char(0))), protect
   DECLARE __label_first_name = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "FIRST_NAME_PRESCREEN_RPT","First Name"),char(0))), protect
   DECLARE __label_mrn = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,"MRN_PRESCREEN_RPT",
      "MRN"),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_last_name = 1
    SET _remlabel_first_name = 1
    SET _remlabel_mrn = 1
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
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_last_name = _remlabel_last_name
   IF (_remlabel_last_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_last_name,((size
       (__label_last_name) - _remlabel_last_name)+ 1),__label_last_name)))
    SET drawheight_label_last_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_last_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_last_name,((size(
        __label_last_name) - _remlabel_last_name)+ 1),__label_last_name)))))
     SET _remlabel_last_name = (_remlabel_last_name+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_last_name = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_last_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_first_name = _remlabel_first_name
   IF (_remlabel_first_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_first_name,((
       size(__label_first_name) - _remlabel_first_name)+ 1),__label_first_name)))
    SET drawheight_label_first_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_first_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_first_name,((size(
        __label_first_name) - _remlabel_first_name)+ 1),__label_first_name)))))
     SET _remlabel_first_name = (_remlabel_first_name+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_first_name = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_first_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 3.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_mrn = _remlabel_mrn
   IF (_remlabel_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_mrn,((size(
        __label_mrn) - _remlabel_mrn)+ 1),__label_mrn)))
    SET drawheight_label_mrn = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_mrn = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_mrn,((size(__label_mrn) -
       _remlabel_mrn)+ 1),__label_mrn)))))
     SET _remlabel_mrn = (_remlabel_mrn+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_mrn = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_mrn)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_label_last_name
   IF (ncalc=rpt_render
    AND _holdremlabel_last_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_last_name,((
       size(__label_last_name) - _holdremlabel_last_name)+ 1),__label_last_name)))
   ELSE
    SET _remlabel_last_name = _holdremlabel_last_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_label_first_name
   IF (ncalc=rpt_render
    AND _holdremlabel_first_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_first_name,(
       (size(__label_first_name) - _holdremlabel_first_name)+ 1),__label_first_name)))
   ELSE
    SET _remlabel_first_name = _holdremlabel_first_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 3.750
   SET rptsd->m_height = drawheight_label_mrn
   IF (ncalc=rpt_render
    AND _holdremlabel_mrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_mrn,((size(
        __label_mrn) - _holdremlabel_mrn)+ 1),__label_mrn)))
   ELSE
    SET _remlabel_mrn = _holdremlabel_mrn
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.156),(offsetx+ 8.000),(offsety+
     0.156))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.219),(offsetx+ 8.000),(offsety+
     0.219))
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
 SUBROUTINE headpagesection3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesection3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headp_person_idsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headp_person_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headp_person_idsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
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
   DECLARE drawheight_last_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_mrn = f8 WITH noconstant(0.0), private
   DECLARE drawheight_first_name = f8 WITH noconstant(0.0), private
   DECLARE __last_name = vc WITH noconstant(build2(tmp_last,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(tmp_mrn,char(0))), protect
   DECLARE __first_name = vc WITH noconstant(build2(tmp_first,char(0))), protect
   IF (bcontinue=0)
    SET _remlast_name = 1
    SET _remmrn = 1
    SET _remfirst_name = 1
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
   SET _holdremlast_name = _remlast_name
   IF (_remlast_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlast_name,((size(
        __last_name) - _remlast_name)+ 1),__last_name)))
    SET drawheight_last_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlast_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlast_name,((size(__last_name) -
       _remlast_name)+ 1),__last_name)))))
     SET _remlast_name = (_remlast_name+ rptsd->m_drawlength)
    ELSE
     SET _remlast_name = 0
    ENDIF
    SET growsum = (growsum+ _remlast_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 3.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmrn = _remmrn
   IF (_remmrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmrn,((size(__mrn) -
       _remmrn)+ 1),__mrn)))
    SET drawheight_mrn = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmrn = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmrn,((size(__mrn) - _remmrn)+ 1),__mrn
       )))))
     SET _remmrn = (_remmrn+ rptsd->m_drawlength)
    ELSE
     SET _remmrn = 0
    ENDIF
    SET growsum = (growsum+ _remmrn)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfirst_name = _remfirst_name
   IF (_remfirst_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfirst_name,((size(
        __first_name) - _remfirst_name)+ 1),__first_name)))
    SET drawheight_first_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfirst_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfirst_name,((size(__first_name) -
       _remfirst_name)+ 1),__first_name)))))
     SET _remfirst_name = (_remfirst_name+ rptsd->m_drawlength)
    ELSE
     SET _remfirst_name = 0
    ENDIF
    SET growsum = (growsum+ _remfirst_name)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_last_name
   IF (ncalc=rpt_render
    AND _holdremlast_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlast_name,((size(
        __last_name) - _holdremlast_name)+ 1),__last_name)))
   ELSE
    SET _remlast_name = _holdremlast_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 3.750
   SET rptsd->m_height = drawheight_mrn
   IF (ncalc=rpt_render
    AND _holdremmrn > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmrn,((size(__mrn)
        - _holdremmrn)+ 1),__mrn)))
   ELSE
    SET _remmrn = _holdremmrn
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.000)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = drawheight_first_name
   IF (ncalc=rpt_render
    AND _holdremfirst_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfirst_name,((size(
        __first_name) - _holdremfirst_name)+ 1),__first_name)))
   ELSE
    SET _remfirst_name = _holdremfirst_name
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
 SUBROUTINE footp_person_idsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footp_person_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footp_person_idsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_potential_prot = f8 WITH noconstant(0.0), private
   DECLARE drawheight_prot_mnemonic = f8 WITH noconstant(0.0), private
   DECLARE __label_potential_prot = vc WITH noconstant(build2(tmp_label,char(0))), protect
   DECLARE __prot_mnemonic = vc WITH noconstant(build2(eksctreply->qual[d1.seq].ctqual[i].
     primary_mnemonic,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_potential_prot = 1
    SET _remprot_mnemonic = 1
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
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_potential_prot = _remlabel_potential_prot
   IF (_remlabel_potential_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_potential_prot,(
       (size(__label_potential_prot) - _remlabel_potential_prot)+ 1),__label_potential_prot)))
    SET drawheight_label_potential_prot = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_potential_prot = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_potential_prot,((size(
        __label_potential_prot) - _remlabel_potential_prot)+ 1),__label_potential_prot)))))
     SET _remlabel_potential_prot = (_remlabel_potential_prot+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_potential_prot = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_potential_prot)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 4.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier80)
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
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = drawheight_label_potential_prot
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_potential_prot > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_potential_prot,((size(__label_potential_prot) - _holdremlabel_potential_prot)+ 1
       ),__label_potential_prot)))
   ELSE
    SET _remlabel_potential_prot = _holdremlabel_potential_prot
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 4.750
   SET rptsd->m_height = drawheight_prot_mnemonic
   SET _dummyfont = uar_rptsetfont(_hreport,_courier80)
   IF (ncalc=rpt_render
    AND _holdremprot_mnemonic > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprot_mnemonic,((
       size(__prot_mnemonic) - _holdremprot_mnemonic)+ 1),__prot_mnemonic)))
   ELSE
    SET _remprot_mnemonic = _holdremprot_mnemonic
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
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
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
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
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
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
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
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_total_patient = f8 WITH noconstant(0.0), private
   DECLARE __total_patient = vc WITH noconstant(build2(uar_i18nbuildmessage(i18nhandle,
      "TOTAL_PT_PRESCREEN_RPT","TOTAL PATIENTS: %1","i",match_count),char(0))), protect
   IF (bcontinue=0)
    SET _remtotal_patient = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.125
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
   SET _holdremtotal_patient = _remtotal_patient
   IF (_remtotal_patient > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtotal_patient,((size(
        __total_patient) - _remtotal_patient)+ 1),__total_patient)))
    SET drawheight_total_patient = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtotal_patient = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtotal_patient,((size(__total_patient)
        - _remtotal_patient)+ 1),__total_patient)))))
     SET _remtotal_patient = (_remtotal_patient+ rptsd->m_drawlength)
    ELSE
     SET _remtotal_patient = 0
    ENDIF
    SET growsum = (growsum+ _remtotal_patient)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.125)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_total_patient
   IF (ncalc=rpt_render
    AND _holdremtotal_patient > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtotal_patient,((
       size(__total_patient) - _holdremtotal_patient)+ 1),__total_patient)))
   ELSE
    SET _remtotal_patient = _holdremtotal_patient
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
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
    SET rptreport->m_reportname = "CT_SUB_RPT_PRESCREEN_DX_PRSN"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
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
   SET rptfont->m_bold = rpt_on
   SET _courier10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _courier8b0 = uar_rptcreatefont(_hreport,rptfont)
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
   SET rptpen->m_penstyle = 3
   SET _pen14s3c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET match_count = 0
 CALL initializereport(0)
 CALL get_prescreen_results(0)
 CALL finalizereport(_sendto)
 SET last_mod = "003"
 SET mod_date = "Feb 26, 2018"
END GO
