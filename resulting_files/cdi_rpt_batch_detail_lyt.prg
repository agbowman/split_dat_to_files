CREATE PROGRAM cdi_rpt_batch_detail_lyt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Batch Name:" = ""
  WITH outdev, batchname
 EXECUTE reportrtl
 RECORD batch_lyt(
   1 batch_class = vc
   1 cover_pgs_rmvd = i4
   1 docs_combined = i4
   1 ai_nonmatch = i4
   1 created_in_man = i4
   1 batch_name = vc
   1 docs_in_auto = i4
   1 create_dt_tm = dq8
   1 del_in_man = i4
   1 scanned_pgs = i4
   1 docs_from_ac = i4
   1 total_docs = i4
   1 completed_docs = i4
   1 ac_rel_dt_tm = dq8
   1 batch_details[*]
     2 blob_handle = vc
     2 next_module = vc
     2 patient_name = vc
     2 financial_nbr = vc
     2 mrn = vc
     2 encntr_id = f8
     2 ax_appid = i4
     2 ax_docid = i4
     2 action_type = vc
     2 person_id = f8
     2 action_dt_tm = dq8
     2 page_cnt = i4
     2 cdi_queue_cd = f8
     2 blob_ref_id = f8
     2 blob_type = vc
     2 perf_prsnl_name = vc
     2 external_batch_ident = f8
     2 doc_type = vc
     2 doc_alias = vc
     2 doc_subtype = vc
     2 subject = vc
     2 doc_type_alias = vc
     2 parent_aliases[*]
       3 name_1 = vc
       3 value_1 = vc
       3 name_2 = vc
       3 value_2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cdi_rpt_batch_detail_drvr  $BATCHNAME
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE batch_query(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_batch_namesection(ncalc=i2) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_batch_namesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 protect
 DECLARE headbatch_lyt_batch_details_blob_handlesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8
  WITH protect
 DECLARE headbatch_lyt_batch_details_blob_handlesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=
  f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headparent_alias_rowsection(ncalc=i2) = f8 WITH protect
 DECLARE headparent_alias_rowsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_blob_ref_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8
  WITH protect
 DECLARE headbatch_lyt_batch_details_blob_ref_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=
  f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footbatch_lyt_batch_details_blob_handlesection(ncalc=i2) = f8 WITH protect
 DECLARE footbatch_lyt_batch_details_blob_handlesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 protect
 DECLARE footpagesection(ncalc=i2) = f8 WITH protect
 DECLARE footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _hi18nhandle = i4 WITH noconstant(0), protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _rempatient_name = i2 WITH noconstant(1), protect
 DECLARE _remblob_type = i2 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadbatch_lyt_batch_details_blob_handlesection = i2 WITH noconstant(0), protect
 DECLARE _remperf_prsnl_name = i2 WITH noconstant(1), protect
 DECLARE _remaction_dt_tm = i2 WITH noconstant(1), protect
 DECLARE _remcdi_queue_cd_disp = i2 WITH noconstant(1), protect
 DECLARE _remaction_type = i2 WITH noconstant(1), protect
 DECLARE _remdoc_type = i2 WITH noconstant(1), protect
 DECLARE _bcontheadbatch_lyt_batch_details_blob_ref_idsection = i2 WITH noconstant(0), protect
 DECLARE _times10bi0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times16bi0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c12632256 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE batch_query(dummy)
   SELECT INTO outdev
    batch_lyt_batch_details_blob_handle = substring(1,55,batch_lyt->batch_details[dtrs1.seq].
     blob_handle), batch_lyt_batch_details_batch_name = substring(1,30,batch_lyt->batch_name),
    batch_lyt_batch_details_batch_class = substring(1,30,batch_lyt->batch_class),
    batch_lyt_batch_details_cov_pgs_removed = batch_lyt->cover_pgs_rmvd,
    batch_lyt_batch_details_docs_combined = batch_lyt->docs_combined,
    batch_lyt_batch_details_ai_nonmatch = batch_lyt->ai_nonmatch,
    batch_lyt_batch_details_created_in_man = batch_lyt->created_in_man,
    batch_lyt_batch_details_deleted_in_man = batch_lyt->del_in_man,
    batch_lyt_batch_details_create_dt_tm = batch_lyt->create_dt_tm,
    batch_lyt_batch_details_scanned_pgs = batch_lyt->scanned_pgs,
    batch_lyt_batch_details_docs_from_ac = batch_lyt->docs_from_ac,
    batch_lyt_batch_details_total_docs = batch_lyt->total_docs,
    batch_lyt_batch_details_completed_docs = batch_lyt->completed_docs,
    batch_lyt_batch_details_ac_rel_dt_tm = batch_lyt->ac_rel_dt_tm,
    batch_lyt_batch_details_docs_in_auto = batch_lyt->docs_in_auto,
    batch_lyt_batch_details_patient_name = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     patient_name), batch_lyt_batch_details_financial_nbr = substring(1,30,batch_lyt->batch_details[
     dtrs1.seq].financial_nbr), batch_lyt_batch_details_mrn = substring(1,30,batch_lyt->
     batch_details[dtrs1.seq].mrn),
    batch_lyt_batch_details_encntr_id = batch_lyt->batch_details[dtrs1.seq].encntr_id,
    batch_lyt_batch_details_ax_appid = batch_lyt->batch_details[dtrs1.seq].ax_appid,
    batch_lyt_batch_details_ax_docid = batch_lyt->batch_details[dtrs1.seq].ax_docid,
    batch_lyt_batch_details_action_type = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     action_type), batch_lyt_batch_details_person_id = batch_lyt->batch_details[dtrs1.seq].person_id,
    batch_lyt_batch_details_action_dt_tm = batch_lyt->batch_details[dtrs1.seq].action_dt_tm,
    batch_lyt_batch_details_page_cnt = batch_lyt->batch_details[dtrs1.seq].page_cnt,
    batch_lyt_batch_details_cdi_queue_cd = batch_lyt->batch_details[dtrs1.seq].cdi_queue_cd,
    batch_lyt_batch_details_blob_ref_id = batch_lyt->batch_details[dtrs1.seq].blob_ref_id,
    batch_lyt_batch_details_blob_type = substring(1,30,batch_lyt->batch_details[dtrs1.seq].blob_type),
    batch_lyt_batch_details_perf_prsnl_name = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     perf_prsnl_name), batch_lyt_batch_details_external_batch_ident = batch_lyt->batch_details[dtrs1
    .seq].external_batch_ident,
    batch_lyt_batch_details_doc_type = substring(1,30,batch_lyt->batch_details[dtrs1.seq].doc_type),
    batch_lyt_batch_details_doc_type_alias = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     doc_type_alias), batch_lyt_batch_details_subject = substring(1,30,batch_lyt->batch_details[dtrs1
     .seq].subject),
    parent_alias_name_1 = substring(1,30,batch_lyt->batch_details[dtrs1.seq].parent_aliases[d2.seq].
     name_1), parent_alias_value_1 = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     parent_aliases[d2.seq].value_1), parent_alias_name_2 = substring(1,30,batch_lyt->batch_details[
     dtrs1.seq].parent_aliases[d2.seq].name_2),
    parent_alias_value_2 = substring(1,30,batch_lyt->batch_details[dtrs1.seq].parent_aliases[d2.seq].
     value_2), parent_alias_row = d2.seq, max_parent_alias_row = size(batch_lyt->batch_details[dtrs1
     .seq].parent_aliases,5)
    FROM (dummyt dtrs1  WITH seq = value(size(batch_lyt->batch_details,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (dtrs1
     WHERE maxrec(d2,size(batch_lyt->batch_details[dtrs1.seq].parent_aliases,5)))
     JOIN (d2)
    ORDER BY batch_lyt_batch_details_batch_name, batch_lyt_batch_details_patient_name,
     batch_lyt_batch_details_blob_handle,
     batch_lyt_batch_details_blob_type, parent_alias_row, batch_lyt_batch_details_blob_ref_id,
     batch_lyt_batch_details_external_batch_ident, batch_lyt_batch_details_action_dt_tm
    HEAD REPORT
     _d0 = batch_lyt_batch_details_blob_handle, _d1 = batch_lyt_batch_details_batch_name, _d2 =
     batch_lyt_batch_details_batch_class,
     _d3 = batch_lyt_batch_details_cov_pgs_removed, _d4 = batch_lyt_batch_details_docs_combined, _d5
      = batch_lyt_batch_details_ai_nonmatch,
     _d6 = batch_lyt_batch_details_created_in_man, _d7 = batch_lyt_batch_details_deleted_in_man, _d8
      = batch_lyt_batch_details_create_dt_tm,
     _d9 = batch_lyt_batch_details_scanned_pgs, _d10 = batch_lyt_batch_details_docs_from_ac, _d11 =
     batch_lyt_batch_details_total_docs,
     _d12 = batch_lyt_batch_details_completed_docs, _d13 = batch_lyt_batch_details_ac_rel_dt_tm, _d14
      = batch_lyt_batch_details_docs_in_auto,
     _d15 = batch_lyt_batch_details_patient_name, _d16 = batch_lyt_batch_details_ax_appid, _d17 =
     batch_lyt_batch_details_ax_docid,
     _d18 = batch_lyt_batch_details_action_type, _d19 = batch_lyt_batch_details_action_dt_tm, _d20 =
     batch_lyt_batch_details_page_cnt,
     _d21 = batch_lyt_batch_details_cdi_queue_cd, _d22 = batch_lyt_batch_details_blob_ref_id, _d23 =
     batch_lyt_batch_details_blob_type,
     _d24 = batch_lyt_batch_details_perf_prsnl_name, _d25 = batch_lyt_batch_details_doc_type, _d26 =
     batch_lyt_batch_details_doc_type_alias,
     _d27 = batch_lyt_batch_details_subject, _d28 = parent_alias_name_1, _d29 = parent_alias_value_1,
     _d30 = parent_alias_name_2, _d31 = parent_alias_value_2, _d32 = parent_alias_row,
     _d33 = max_parent_alias_row, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom),
     _fenddetail = (_fenddetail - footpagesection(rpt_calcheight)),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    HEAD batch_lyt_batch_details_batch_name
     _fdrawheight = headbatch_lyt_batch_details_batch_namesection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headbatch_lyt_batch_details_batch_namesection(rpt_render), previous_parent = 0
    HEAD batch_lyt_batch_details_patient_name
     row + 0
    HEAD batch_lyt_batch_details_blob_handle
     _bcontheadbatch_lyt_batch_details_blob_handlesection = 0, bfirsttime = 1
     WHILE (((_bcontheadbatch_lyt_batch_details_blob_handlesection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadbatch_lyt_batch_details_blob_handlesection, _fdrawheight =
       headbatch_lyt_batch_details_blob_handlesection(rpt_calcheight,(_fenddetail - _yoffset),
        _bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadbatch_lyt_batch_details_blob_handlesection=0)
        BREAK
       ENDIF
       dummy_val = headbatch_lyt_batch_details_blob_handlesection(rpt_render,(_fenddetail - _yoffset),
        _bcontheadbatch_lyt_batch_details_blob_handlesection), bfirsttime = 0
     ENDWHILE
    HEAD batch_lyt_batch_details_blob_type
     row + 0
    HEAD parent_alias_row
     _fdrawheight = headparent_alias_rowsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headparent_alias_rowsection(rpt_render)
    HEAD batch_lyt_batch_details_blob_ref_id
     _bcontheadbatch_lyt_batch_details_blob_ref_idsection = 0, bfirsttime = 1
     WHILE (((_bcontheadbatch_lyt_batch_details_blob_ref_idsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontheadbatch_lyt_batch_details_blob_ref_idsection, _fdrawheight =
       headbatch_lyt_batch_details_blob_ref_idsection(rpt_calcheight,(_fenddetail - _yoffset),
        _bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontheadbatch_lyt_batch_details_blob_ref_idsection=0)
        BREAK
       ENDIF
       dummy_val = headbatch_lyt_batch_details_blob_ref_idsection(rpt_render,(_fenddetail - _yoffset),
        _bcontheadbatch_lyt_batch_details_blob_ref_idsection), bfirsttime = 0
     ENDWHILE
     IF (parent_alias_row=max_parent_alias_row)
      previous_parent = batch_lyt_batch_details_blob_ref_id
     ENDIF
    HEAD batch_lyt_batch_details_external_batch_ident
     row + 0
    HEAD batch_lyt_batch_details_action_dt_tm
     row + 0
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  batch_lyt_batch_details_action_dt_tm
     row + 0
    FOOT  batch_lyt_batch_details_external_batch_ident
     row + 0
    FOOT  batch_lyt_batch_details_blob_ref_id
     row + 0
    FOOT  parent_alias_row
     row + 0
    FOOT  batch_lyt_batch_details_blob_type
     row + 0
    FOOT  batch_lyt_batch_details_blob_handle
     _fdrawheight = footbatch_lyt_batch_details_blob_handlesection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = footbatch_lyt_batch_details_blob_handlesection(rpt_render)
    FOOT  batch_lyt_batch_details_patient_name
     row + 0
    FOOT  batch_lyt_batch_details_batch_name
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
     _yoffset = _yhold
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
   DECLARE sectionheight = f8 WITH noconstant(0.770000), private
   DECLARE __forbatchname = vc WITH noconstant(build2(build2('for Batch Name "', $BATCHNAME,'"'),char
     (0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.573
    SET _oldfont = uar_rptsetfont(_hreport,_times16bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadReportSection_title",build2(concat("ProVision Document Imaging",_crlf,
         "Batch Details Report"),char(0))),char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__forbatchname)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_batch_namesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbatch_lyt_batch_details_batch_namesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_batch_namesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.750000), private
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __batch_class = vc WITH noconstant(build2(trim(batch_lyt_batch_details_batch_class),char(
       0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __cov_pgs_removed = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_cov_pgs_removed)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __docs_combined = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_docs_combined)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __ai_nonmatch = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_ai_nonmatch)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __created_in_man_index = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_created_in_man)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __deleted_in_man_index = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_deleted_in_man)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __docs_in_auto = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_docs_in_auto)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __create_dt_tm = vc WITH noconstant(build2(format(batch_lyt_batch_details_create_dt_tm,
       "@SHORTDATETIME;;D"),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __scanned_pgs = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_scanned_pgs)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __docs_from_ac = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_docs_from_ac)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __total_docs = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_total_docs)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __completed_docs = vc WITH noconstant(build2(trim(cnvtstring(
        batch_lyt_batch_details_completed_docs)),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __ac_rel_dt_tm = vc WITH noconstant(build2(format(batch_lyt_batch_details_ac_rel_dt_tm,
       "@SHORTDATETIME;;D"),char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 516
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.250
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_batch_name,
       char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colBatchName",build2("Batch Name: ",char(0))),
       char(0)))
    ENDIF
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.229
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name)="")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_FieldName3",build2("NO RECORDS FOUND",char(0))
        ),char(0)))
    ENDIF
    SET rptsd->m_flags = 516
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colBatchClass",build2("Batch Class: ",char(0))
        ),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__batch_class)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colCovPagesRem",build2("Cover Pages Removed: ",
         char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cov_pgs_removed)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colDocsComb",build2(
         "Documents Removed by Combine: ",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__docs_combined)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colAINonMatch",build2("Auto Index Non-Match: ",
         char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ai_nonmatch)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colCreatedinManIndex",build2(
         "Created in Manual Indexing: ",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colDeletedinManIndex",build2(
         "Deleted in Manual Indexing: ",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colDocsInAuto",build2("Documents in Auto: ",
         char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colBatchCreateDtTm",build2(
         "Create Date/Time: ",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colScannedPgs",build2("Scanned Pages: ",char(0
          ))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colRelFromAC",build2(
         "Documents Released from AC: ",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colTotalDocs",build2("Total Documents: ",char(
          0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colCompDocs",build2("Completed Documents: ",
         char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BATCH_NAMESection_colRelDtTm",build2("AC Release Date/Time: ",
         char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__created_in_man_index)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.490)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__deleted_in_man_index)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__docs_in_auto)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__create_dt_tm)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__scanned_pgs)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__docs_from_ac)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__total_docs)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__completed_docs)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ac_rel_dt_tm)
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_blob_handlesection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbatch_lyt_batch_details_blob_handlesectionabs(ncalc,_xoffset,_yoffset,maxheight,
    bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_blob_handlesectionabs(ncalc,offsetx,offsety,maxheight,
  bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_patient_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_blob_type = f8 WITH noconstant(0.0), private
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __patient_name = vc WITH noconstant(build2(batch_lyt_batch_details_patient_name,char(0))),
    protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __blob_type = vc WITH noconstant(build2(trim(batch_lyt_batch_details_blob_type),char(0))),
    protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __blob_ref_id = vc WITH noconstant(build2(cnvtstring(batch_lyt_batch_details_blob_ref_id),
      char(0))), protect
   ENDIF
   IF ( NOT (((batch_lyt_batch_details_blob_ref_id=0) OR (previous_parent !=
   batch_lyt_batch_details_blob_ref_id)) ))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _rempatient_name = 1
    SET _remblob_type = 1
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
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatient_name = _rempatient_name
   IF (_rempatient_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatient_name,((size(
        __patient_name) - _rempatient_name)+ 1),__patient_name)))
    SET drawheight_patient_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatient_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatient_name,((size(__patient_name) -
       _rempatient_name)+ 1),__patient_name)))))
     SET _rempatient_name = (_rempatient_name+ rptsd->m_drawlength)
    ELSE
     SET _rempatient_name = 0
    ENDIF
    SET growsum = (growsum+ _rempatient_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremblob_type = _remblob_type
   IF (_remblob_type > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remblob_type,((size(
        __blob_type) - _remblob_type)+ 1),__blob_type)))
    SET drawheight_blob_type = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remblob_type = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remblob_type,((size(__blob_type) -
       _remblob_type)+ 1),__blob_type)))))
     SET _remblob_type = (_remblob_type+ rptsd->m_drawlength)
    ELSE
     SET _remblob_type = 0
    ENDIF
    SET growsum = (growsum+ _remblob_type)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c12632256)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.000),7.500,0.500,
      rpt_fill,uar_rptencodecolor(192,192,192))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = drawheight_patient_name
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdrempatient_name > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatient_name,((
        size(__patient_name) - _holdrempatient_name)+ 1),__patient_name)))
    ENDIF
   ELSE
    SET _rempatient_name = _holdrempatient_name
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.823
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BLOB_HANDLESection_colBatchName124",build2("Parent Type: ",char(
          0))),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = drawheight_blob_type
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremblob_type > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremblob_type,((size(
         __blob_type) - _holdremblob_type)+ 1),__blob_type)))
    ENDIF
   ELSE
    SET _remblob_type = _holdremblob_type
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.240)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BLOB_HANDLESection_colBatchName123",build2("Parent ID: ",char(0)
         )),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.240)
   SET rptsd->m_x = (offsetx+ 4.500)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__blob_ref_id)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_BLOB_HANDLESection_colPatientNamex0",build2("Patient Name: ",
         char(0))),char(0)))
    ENDIF
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE headparent_alias_rowsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headparent_alias_rowsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headparent_alias_rowsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (size(trim(parent_alias_name_1)) > 1)
    DECLARE __parent_aliases_alias_name1 = vc WITH noconstant(build2(build(parent_alias_name_1,":"),
      char(0))), protect
   ENDIF
   IF (size(trim(parent_alias_name_2)) > 1)
    DECLARE __parent_aliases_alias_name2 = vc WITH noconstant(build2(build(parent_alias_name_2,":"),
      char(0))), protect
   ENDIF
   IF ( NOT (((batch_lyt_batch_details_blob_ref_id=0) OR (previous_parent !=
   batch_lyt_batch_details_blob_ref_id)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c12632256)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.000),(offsety+ 0.000),7.500,0.250,
     rpt_fill,uar_rptencodecolor(192,192,192))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (size(trim(parent_alias_name_1)) > 1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__parent_aliases_alias_name1)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(parent_alias_value_1,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (size(trim(parent_alias_name_2)) > 1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__parent_aliases_alias_name2)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(parent_alias_value_2,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_blob_ref_idsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbatch_lyt_batch_details_blob_ref_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,
    bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_blob_ref_idsectionabs(ncalc,offsetx,offsety,maxheight,
  bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(1.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_perf_prsnl_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_action_dt_tm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_cdi_queue_cd_disp = f8 WITH noconstant(0.0), private
   DECLARE drawheight_action_type = f8 WITH noconstant(0.0), private
   DECLARE drawheight_doc_type = f8 WITH noconstant(0.0), private
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __ax_appid = vc WITH noconstant(build2(cnvtstring(batch_lyt_batch_details_ax_appid),char(
       0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __perf_prsnl_name = vc WITH noconstant(build2(trim(
       batch_lyt_batch_details_perf_prsnl_name),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __action_dt_tm = vc WITH noconstant(build2(format(batch_lyt_batch_details_action_dt_tm,
       "@SHORTDATETIME;;D"),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __ax_docid = vc WITH noconstant(build2(cnvtstring(batch_lyt_batch_details_ax_docid),char(
       0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __cdi_queue_cd_disp = vc WITH noconstant(build2(uar_get_code_display(
       batch_lyt_batch_details_cdi_queue_cd),char(0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __action_type = vc WITH noconstant(build2(trim(batch_lyt_batch_details_action_type),char(
       0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __page_cnt = vc WITH noconstant(build2(cnvtstring(batch_lyt_batch_details_page_cnt),char(
       0))), protect
   ENDIF
   IF (trim(batch_lyt_batch_details_batch_name) != "")
    DECLARE __doc_type = vc WITH noconstant(build2(batch_lyt_batch_details_doc_type,char(0))),
    protect
   ENDIF
   IF ( NOT (parent_alias_row=max_parent_alias_row))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remperf_prsnl_name = 1
    SET _remaction_dt_tm = 1
    SET _remcdi_queue_cd_disp = 1
    SET _remaction_type = 1
    SET _remdoc_type = 1
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
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremperf_prsnl_name = _remperf_prsnl_name
   IF (_remperf_prsnl_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remperf_prsnl_name,((size
       (__perf_prsnl_name) - _remperf_prsnl_name)+ 1),__perf_prsnl_name)))
    SET drawheight_perf_prsnl_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remperf_prsnl_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remperf_prsnl_name,((size(
        __perf_prsnl_name) - _remperf_prsnl_name)+ 1),__perf_prsnl_name)))))
     SET _remperf_prsnl_name = (_remperf_prsnl_name+ rptsd->m_drawlength)
    ELSE
     SET _remperf_prsnl_name = 0
    ENDIF
    SET growsum = (growsum+ _remperf_prsnl_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremaction_dt_tm = _remaction_dt_tm
   IF (_remaction_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remaction_dt_tm,((size(
        __action_dt_tm) - _remaction_dt_tm)+ 1),__action_dt_tm)))
    SET drawheight_action_dt_tm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remaction_dt_tm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remaction_dt_tm,((size(__action_dt_tm) -
       _remaction_dt_tm)+ 1),__action_dt_tm)))))
     SET _remaction_dt_tm = (_remaction_dt_tm+ rptsd->m_drawlength)
    ELSE
     SET _remaction_dt_tm = 0
    ENDIF
    SET growsum = (growsum+ _remaction_dt_tm)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcdi_queue_cd_disp = _remcdi_queue_cd_disp
   IF (_remcdi_queue_cd_disp > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcdi_queue_cd_disp,((
       size(__cdi_queue_cd_disp) - _remcdi_queue_cd_disp)+ 1),__cdi_queue_cd_disp)))
    SET drawheight_cdi_queue_cd_disp = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcdi_queue_cd_disp = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcdi_queue_cd_disp,((size(
        __cdi_queue_cd_disp) - _remcdi_queue_cd_disp)+ 1),__cdi_queue_cd_disp)))))
     SET _remcdi_queue_cd_disp = (_remcdi_queue_cd_disp+ rptsd->m_drawlength)
    ELSE
     SET _remcdi_queue_cd_disp = 0
    ENDIF
    SET growsum = (growsum+ _remcdi_queue_cd_disp)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremaction_type = _remaction_type
   IF (_remaction_type > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remaction_type,((size(
        __action_type) - _remaction_type)+ 1),__action_type)))
    SET drawheight_action_type = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remaction_type = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remaction_type,((size(__action_type) -
       _remaction_type)+ 1),__action_type)))))
     SET _remaction_type = (_remaction_type+ rptsd->m_drawlength)
    ELSE
     SET _remaction_type = 0
    ENDIF
    SET growsum = (growsum+ _remaction_type)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdoc_type = _remdoc_type
   IF (_remdoc_type > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdoc_type,((size(
        __doc_type) - _remdoc_type)+ 1),__doc_type)))
    SET drawheight_doc_type = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y))
     AND trim(batch_lyt_batch_details_batch_name) != "")
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdoc_type = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdoc_type,((size(__doc_type) -
       _remdoc_type)+ 1),__doc_type)))))
     SET _remdoc_type = (_remdoc_type+ rptsd->m_drawlength)
    ELSE
     SET _remdoc_type = 0
    ENDIF
    SET growsum = (growsum+ _remdoc_type)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 3.625
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_blob_handle,
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.750)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ax_appid)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = drawheight_perf_prsnl_name
   IF (ncalc=rpt_render
    AND _holdremperf_prsnl_name > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremperf_prsnl_name,(
        (size(__perf_prsnl_name) - _holdremperf_prsnl_name)+ 1),__perf_prsnl_name)))
    ENDIF
   ELSE
    SET _remperf_prsnl_name = _holdremperf_prsnl_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = drawheight_action_dt_tm
   IF (ncalc=rpt_render
    AND _holdremaction_dt_tm > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremaction_dt_tm,((
        size(__action_dt_tm) - _holdremaction_dt_tm)+ 1),__action_dt_tm)))
    ENDIF
   ELSE
    SET _remaction_dt_tm = _holdremaction_dt_tm
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.750)
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ax_docid)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = drawheight_cdi_queue_cd_disp
   IF (ncalc=rpt_render
    AND _holdremcdi_queue_cd_disp > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcdi_queue_cd_disp,
        ((size(__cdi_queue_cd_disp) - _holdremcdi_queue_cd_disp)+ 1),__cdi_queue_cd_disp)))
    ENDIF
   ELSE
    SET _remcdi_queue_cd_disp = _holdremcdi_queue_cd_disp
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = drawheight_action_type
   IF (ncalc=rpt_render
    AND _holdremaction_type > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremaction_type,((
        size(__action_type) - _holdremaction_type)+ 1),__action_type)))
    ENDIF
   ELSE
    SET _remaction_type = _holdremaction_type
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.990)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__page_cnt)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.823
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName0",build2("Blob Handle: ",char(0)
         )),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName1",build2("Location: ",char(0))),
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.750)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName12",build2("AX App: ",char(0))),
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName122",build2("Page Count: ",char(0
          ))),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.500)
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName125",build2("Action Date/Time: ",
         char(0))),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName126",build2("User: ",char(0))),
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.500)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName127",build2("Action: ",char(0))),
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.750)
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colBatchName128",build2("AX Doc ID: ",char(0)
         )),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colDocType",build2("Document Type: ",char(0))
        ),char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.000)
   SET rptsd->m_x = (offsetx+ 4.563)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colAlias",build2("Doc Type Alias: ",char(0))),
       char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_blob_ref_idSection_colSubject",build2("Subject: ",char(0))),char
       (0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.990)
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       batch_lyt_batch_details_doc_type_alias,char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.240)
   SET rptsd->m_x = (offsetx+ 0.875)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_subject,char(
        0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = drawheight_doc_type
   IF (ncalc=rpt_render
    AND _holdremdoc_type > 0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdoc_type,((size(
         __doc_type) - _holdremdoc_type)+ 1),__doc_type)))
    ENDIF
   ELSE
    SET _remdoc_type = _holdremdoc_type
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF ( NOT (parent_alias_row=max_parent_alias_row))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footbatch_lyt_batch_details_blob_handlesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footbatch_lyt_batch_details_blob_handlesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footbatch_lyt_batch_details_blob_handlesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.070000), private
   IF ( NOT (parent_alias_row=max_parent_alias_row))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c12632256)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.036),(offsetx+ 7.500),(offsety
      + 0.036))
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __rptdate = vc WITH noconstant(build2(build(format(sysdate,"@WEEKDAYNAME;;D"),",",format(
       sysdate,"@LONGDATE;;D")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rptdate)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CDI_RPT_BATCH_DETAIL_LYT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
    FROM output_dest o,
     device d,
     printer p
    PLAN (o
     WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
     JOIN (d
     WHERE d.device_cd=o.device_cd)
     JOIN (p
     WHERE p.device_cd=d.device_cd)
    DETAIL
     CASE (cnvtint(p_printer_type_cdf))
      OF 8:
      OF 26:
      OF 29:
       _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
      OF 16:
      OF 20:
      OF 24:
       _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
      OF 42:
       _outputtype = rpt_zebra300,_xdiv = 300,_ydiv = 300
      OF 43:
       _outputtype = rpt_zebra600,_xdiv = 600,_ydiv = 600
      OF 32:
      OF 18:
      OF 19:
      OF 27:
      OF 31:
       _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
      ELSE
       _xdiv = 1,_ydiv = 1
     ENDCASE
     _diotype = cnvtint(p_printer_type_cdf), _sendto = d.name
     IF (_xdiv > 1)
      rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
     ENDIF
     IF (_xdiv > 1)
      rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
     ENDIF
    WITH nocounter
   ;end select
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
   SET rptfont->m_recsize = 50
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
   SET rptfont->m_italic = rpt_on
   SET _times16bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_italic = rpt_off
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_rgbcolor = uar_rptencodecolor(192,192,192)
   SET _pen14s0c12632256 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 CALL batch_query(0)
 CALL finalizereport(_sendto)
END GO
