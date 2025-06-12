CREATE PROGRAM cdi_rpt_batch_list_lyt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Begin Time" = "CURTIME",
  "End Time" = "CURTIME",
  "Batch Class" = "",
  "All Batch Classes" = "0"
  WITH outdev, begin_date, end_date,
  begin_time, end_time, batch_class,
  all_batch_classes
 EXECUTE reportrtl
 RECORD batch_lyt(
   1 batch_classes = vc
   1 total_batches = i4
   1 total_pages = i4
   1 total_docs = i4
   1 total_ip_docs = i4
   1 total_completed_docs = i4
   1 batch_details[*]
     2 batch_name = vc
     2 batch_class = vc
     2 index_nonmatch_cnt = i4
     2 scanned_pgs_cnt = i4
     2 totaldocs = i4
     2 ecp_cnt = i4
     2 combined_cnt = i4
     2 cur_auto_cnt = i4
     2 cur_man_cnt = i4
     2 man_create_cnt = i4
     2 man_del_cnt = i4
     2 complete_cnt = i4
     2 avgautotime = f8
     2 avgmantime = f8
     2 avgpreptime = f8
     2 create_dt_tm = dq8
     2 docsinac = i4
     2 nextacmodule = vc
     2 ac_rel_dt_tm = dq8
     2 totalactime = dq8
     2 ac_rel_cnt = i4
     2 ac_qc_time = f8
     2 ac_rec_time = f8
     2 ac_rel_time = f8
     2 ac_scan_time = f8
     2 ac_valid_time = f8
     2 ac_verify_time = f8
     2 external_batch_ident = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD batch_class(
   1 qual[*]
     2 bcname = vc
     2 bccount = i4
 )
 EXECUTE cdi_rpt_batch_list_drvr  $BEGIN_DATE,  $END_DATE,  $BEGIN_TIME,
  $END_TIME,  $BATCH_CLASS,  $ALL_BATCH_CLASSES
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE batch_query(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_batch_classsection(ncalc=i2) = f8 WITH protect
 DECLARE headbatch_lyt_batch_details_batch_classsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH
 protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times10bi0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times16bi0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c12632256 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE batch_query(dummy)
   SELECT INTO "NL:"
    batch_lyt_batch_details_batch_classes = substring(1,30,batch_lyt->batch_classes),
    batch_lyt_batch_details_batch_name = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     batch_name), batch_lyt_batch_details_totaldocs = batch_lyt->batch_details[dtrs1.seq].totaldocs,
    batch_lyt_batch_details_batch_class = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     batch_class), batch_lyt_batch_details_index_nonmatch_cnt = batch_lyt->batch_details[dtrs1.seq].
    index_nonmatch_cnt, batch_lyt_batch_details_scanned_pgs_cnt = batch_lyt->batch_details[dtrs1.seq]
    .scanned_pgs_cnt,
    batch_lyt_batch_details_ecp_cnt = batch_lyt->batch_details[dtrs1.seq].ecp_cnt,
    batch_lyt_batch_details_combined_cnt = batch_lyt->batch_details[dtrs1.seq].combined_cnt,
    batch_lyt_batch_details_cur_auto_cnt = batch_lyt->batch_details[dtrs1.seq].cur_auto_cnt,
    batch_lyt_batch_details_cur_man_cnt = batch_lyt->batch_details[dtrs1.seq].cur_man_cnt,
    batch_lyt_batch_details_man_create_cnt = batch_lyt->batch_details[dtrs1.seq].man_create_cnt,
    batch_lyt_batch_details_man_del_cnt = batch_lyt->batch_details[dtrs1.seq].man_del_cnt,
    batch_lyt_batch_details_complete_cnt = batch_lyt->batch_details[dtrs1.seq].complete_cnt,
    batch_lyt_batch_details_avgautotime = batch_lyt->batch_details[dtrs1.seq].avgautotime,
    batch_lyt_batch_details_avgmantime = batch_lyt->batch_details[dtrs1.seq].avgmantime,
    batch_lyt_batch_details_avgpreptime = batch_lyt->batch_details[dtrs1.seq].avgpreptime,
    batch_lyt_batch_details_create_dt_tm = batch_lyt->batch_details[dtrs1.seq].create_dt_tm,
    batch_lyt_batch_details_docsinac = batch_lyt->batch_details[dtrs1.seq].docsinac,
    batch_lyt_batch_details_nextacmodule = substring(1,30,batch_lyt->batch_details[dtrs1.seq].
     nextacmodule), batch_lyt_batch_details_ac_rel_dt_tm = batch_lyt->batch_details[dtrs1.seq].
    ac_rel_dt_tm, batch_lyt_batch_details_totalactime = batch_lyt->batch_details[dtrs1.seq].
    totalactime,
    batch_lyt_batch_details_ac_rel_cnt = batch_lyt->batch_details[dtrs1.seq].ac_rel_cnt,
    batch_lyt_batch_details_ac_qc_time = batch_lyt->batch_details[dtrs1.seq].ac_qc_time,
    batch_lyt_batch_details_ac_rec_time = batch_lyt->batch_details[dtrs1.seq].ac_rec_time,
    batch_lyt_batch_details_ac_rel_time = batch_lyt->batch_details[dtrs1.seq].ac_rel_time,
    batch_lyt_batch_details_ac_scan_time = batch_lyt->batch_details[dtrs1.seq].ac_scan_time,
    batch_lyt_batch_details_ac_valid_time = batch_lyt->batch_details[dtrs1.seq].ac_valid_time,
    batch_lyt_batch_details_ac_verify_time = batch_lyt->batch_details[dtrs1.seq].ac_verify_time,
    batch_lyt_batch_details_external_batch_ident = batch_lyt->batch_details[dtrs1.seq].
    external_batch_ident
    FROM (dummyt dtrs1  WITH seq = value(size(batch_lyt->batch_details,5)))
    ORDER BY batch_lyt_batch_details_batch_class, batch_lyt_batch_details_create_dt_tm,
     batch_lyt_batch_details_batch_name,
     batch_lyt_batch_details_external_batch_ident
    HEAD REPORT
     _d0 = batch_lyt_batch_details_batch_name, _d1 = batch_lyt_batch_details_totaldocs, _d2 =
     batch_lyt_batch_details_batch_class,
     _d3 = batch_lyt_batch_details_index_nonmatch_cnt, _d4 = batch_lyt_batch_details_scanned_pgs_cnt,
     _d5 = batch_lyt_batch_details_ecp_cnt,
     _d6 = batch_lyt_batch_details_combined_cnt, _d7 = batch_lyt_batch_details_cur_auto_cnt, _d8 =
     batch_lyt_batch_details_man_create_cnt,
     _d9 = batch_lyt_batch_details_man_del_cnt, _d10 = batch_lyt_batch_details_complete_cnt, _d11 =
     batch_lyt_batch_details_create_dt_tm,
     _d12 = batch_lyt_batch_details_nextacmodule, _d13 = batch_lyt_batch_details_ac_rel_dt_tm, _d14
      = batch_lyt_batch_details_ac_rel_cnt,
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fenddetail = (_fenddetail
      - footpagesection(rpt_calcheight)), _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    HEAD batch_lyt_batch_details_batch_class
     FOR (i = 1 TO size(batch_class->qual,5))
       IF ((batch_class->qual[i].bcname=batch_lyt_batch_details_batch_class))
        bctotalval = batch_class->qual[i].bccount
       ENDIF
     ENDFOR
     _fdrawheight = headbatch_lyt_batch_details_batch_classsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headbatch_lyt_batch_details_batch_classsection(rpt_render)
    HEAD batch_lyt_batch_details_create_dt_tm
     row + 0
    HEAD batch_lyt_batch_details_batch_name
     row + 0
    HEAD batch_lyt_batch_details_external_batch_ident
     row + 0
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT  batch_lyt_batch_details_external_batch_ident
     row + 0
    FOOT  batch_lyt_batch_details_batch_name
     row + 0
    FOOT  batch_lyt_batch_details_create_dt_tm
     row + 0
    FOOT  batch_lyt_batch_details_batch_class
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
   DECLARE sectionheight = f8 WITH noconstant(2.610000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.750)
    SET rptsd->m_width = 4.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build2(format(cnvtdatetime(cnvtdate2(
           $BEGIN_DATE,"DD-MMM-YYYY"),cnvttime2( $BEGIN_TIME,"HH:MM")),"@MEDIUMDATETIME")," - ",
       format(cnvtdatetime(cnvtdate2( $END_DATE,"DD-MMM-YYYY"),cnvttime2( $END_TIME,"HH:MM")),
        "@MEDIUMDATETIME")),char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.323
    SET _dummyfont = uar_rptsetfont(_hreport,_times16bi0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadReportSection_FieldName0",build2("ProVision Document Imaging",char(0))),char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.500
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "HeadReportSection_FieldName1",build2("Batch List Report",char(0))),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadReportSection_TotalBatches",build2("Total Batches:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadReportSection_TotalPages",build2("Total Pages:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadReportSection_TotalDocuments",build2("Total Documents:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadReportSection_TotalIPDocs",build2("Total In-Progress Documents:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "HeadReportSection_TotalCompDocs",build2("Total Completed Documents:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt->batch_classes,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt->total_batches,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt->total_pages,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.813)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt->total_docs,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt->total_ip_docs,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 2.365
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt->total_completed_docs,char(
        0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_batch_classsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbatch_lyt_batch_details_batch_classsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headbatch_lyt_batch_details_batch_classsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_batch_classSection_BatchClassHeader",build2("Batch Class:",char(
          0))),char(0)))
    ENDIF
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 2.979
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_batch_class,
       char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "Headbatch_lyt_batch_details_batch_classSection_TotBatches",build2("Total Batches:",char(0))),
       char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(bctotalval,char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.070000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_ac_rel_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(
        batch_lyt_batch_details_ac_rel_dt_tm,"@SHORTDATETIME;;Q"),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_batch_name,
       char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_combined_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_complete_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(
        batch_lyt_batch_details_create_dt_tm,"@SHORTDATETIME;;Q"),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_cur_auto_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_ecp_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_man_create_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_man_del_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_nextacmodule,
       char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_totaldocs),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2331",build2("Create Date/Time:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2332",build2("Completed Documents:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2333",build2("Documents Removed by Combine:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2334",build2("Batch Name:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2342",build2("AC Release Date/Time:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2343",build2("Documents Released from AC:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2345",build2("Total Documents:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2347",build2("Next AC Module:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2348",build2("Deleted in Manual Indexing:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2349",build2("Created in Manual Indexing:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2350",build2("Cover Pages Removed:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName2353",build2("Documents in Auto:",char(0))),char(0)))
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c12632256)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 2.036),(offsetx+ 7.500),(offsety
      + 2.036))
    ENDIF
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.281
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (trim(batch_lyt_batch_details_batch_name)="")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldName3",build2("NO RECORDS FOUND",char(0))),char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldNameBatchClass",build2("Batch Class:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(batch_lyt_batch_details_batch_class,
       char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldNameAutoNonMatch",build2("Auto Index Non-Match:",char(0))),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_index_nonmatch_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cnvtstring(
        batch_lyt_batch_details_scanned_pgs_cnt),char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    IF (trim(batch_lyt_batch_details_batch_name) != "")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
        "DetailSection_FieldNameScanPages",build2("Scanned Pages:",char(0))),char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
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
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times10bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(build(format(sysdate,"@WEEKDAYNAME;;D"
        ),",",format(sysdate,"@LONGDATE;;D")),char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CDI_RPT_BATCH_LIST_LYT"
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
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_warning)
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
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET rptfont->m_italic = rpt_on
   SET _times16bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10bi0 = uar_rptcreatefont(_hreport,rptfont)
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
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET _fholdenddetail = _fenddetail
 CALL batch_query(0)
 SET _fenddetail = _fholdenddetail
 CALL finalizereport(_sendto)
END GO
