CREATE PROGRAM cdi_rpt_rejected_docs_lyt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "",
  "End Date" = "",
  "Doc UID" = "",
  "Contributor System" = ""
  WITH outdev, startdate, enddate,
  referencenbr, contribsys
 EXECUTE reportrtl
 RECORD reject_lyt(
   1 reject_details[*]
     2 contributor_system = vc
     2 reference_nbr = vc
     2 reject_user_name = vc
     2 reject_dt_tm = dq8
     2 reject_fin = vc
     2 reject_patient_name = vc
     2 reject_birth_dt_tm = dq8
     2 reject_mrn = vc
     2 reject_doc_type = vc
     2 reject_subject = vc
     2 reject_updt_dt_tm = dq8
     2 reject_status = vc
     2 reject_service_dt_tm = dq8
     2 reject_provider = vc
     2 match_fin = vc
     2 match_patient_name = vc
     2 match_birth_dt_tm = dq8
     2 match_mrn = vc
     2 match_doc_type = vc
     2 match_subject = vc
     2 match_updt_dt_tm = dq8
     2 match_status = vc
     2 match_service_dt_tm = dq8
     2 match_provider = vc
     2 match_blob_handle = vc
 )
 EXECUTE cdi_rpt_rejected_docs_drvr  $STARTDATE,  $ENDDATE,  $REFERENCENBR,
  $CONTRIBSYS
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE reject_query(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times10u0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE reject_query(dummy)
   SELECT INTO "NL:"
    reject_details_contributor_system = substring(1,40,reject_lyt->reject_details[dtrs1.seq].
     contributor_system), reject_details_reference_nbr = substring(1,30,reject_lyt->reject_details[
     dtrs1.seq].reference_nbr), reject_details_reject_user_name = substring(1,30,reject_lyt->
     reject_details[dtrs1.seq].reject_user_name),
    reject_details_reject_dt_tm = reject_lyt->reject_details[dtrs1.seq].reject_dt_tm,
    reject_details_reject_fin = substring(1,30,reject_lyt->reject_details[dtrs1.seq].reject_fin),
    reject_details_reject_patient_name = substring(1,30,reject_lyt->reject_details[dtrs1.seq].
     reject_patient_name),
    reject_details_reject_birth_dt_tm = format(reject_lyt->reject_details[dtrs1.seq].
     reject_birth_dt_tm,";;Q"), reject_details_reject_mrn = substring(1,30,reject_lyt->
     reject_details[dtrs1.seq].reject_mrn), reject_details_reject_doc_type = substring(1,30,
     reject_lyt->reject_details[dtrs1.seq].reject_doc_type),
    reject_details_reject_subject = substring(1,30,reject_lyt->reject_details[dtrs1.seq].
     reject_subject), reject_details_reject_updt_dt_tm = format(reject_lyt->reject_details[dtrs1.seq]
     .reject_updt_dt_tm,";;Q"), reject_details_reject_status = substring(1,30,reject_lyt->
     reject_details[dtrs1.seq].reject_status),
    reject_details_reject_service_dt_tm = format(reject_lyt->reject_details[dtrs1.seq].
     reject_service_dt_tm,";;Q"), reject_details_reject_provider = substring(1,30,reject_lyt->
     reject_details[dtrs1.seq].reject_provider), reject_details_match_fin = substring(1,30,reject_lyt
     ->reject_details[dtrs1.seq].match_fin),
    reject_details_match_patient_name = substring(1,30,reject_lyt->reject_details[dtrs1.seq].
     match_patient_name), reject_details_match_birth_dt_tm = format(reject_lyt->reject_details[dtrs1
     .seq].match_birth_dt_tm,";;Q"), reject_details_match_mrn = substring(1,30,reject_lyt->
     reject_details[dtrs1.seq].match_mrn),
    reject_details_match_doc_type = substring(1,30,reject_lyt->reject_details[dtrs1.seq].
     match_doc_type), reject_details_match_subject = substring(1,30,reject_lyt->reject_details[dtrs1
     .seq].match_subject), reject_details_match_updt_dt_tm = format(reject_lyt->reject_details[dtrs1
     .seq].match_updt_dt_tm,";;Q"),
    reject_details_match_status = substring(1,30,reject_lyt->reject_details[dtrs1.seq].match_status),
    reject_details_match_service_dt_tm = format(reject_lyt->reject_details[dtrs1.seq].
     match_service_dt_tm,";;Q"), reject_details_match_provider = substring(1,30,reject_lyt->
     reject_details[dtrs1.seq].match_provider),
    reject_details_match_blob_handle = substring(1,30,reject_lyt->reject_details[dtrs1.seq].
     match_blob_handle), reject_details_reject_dt_tm_form = format(reject_lyt->reject_details[dtrs1
     .seq].reject_dt_tm,";;Q")
    FROM (dummyt dtrs1  WITH seq = value(size(reject_lyt->reject_details,5)))
    PLAN (dtrs1)
    ORDER BY reject_details_reject_dt_tm
    HEAD REPORT
     _d0 = reject_details_contributor_system, _d1 = reject_details_reference_nbr, _d2 =
     reject_details_reject_user_name,
     _d3 = reject_details_reject_dt_tm, _d4 = reject_details_reject_fin, _d5 =
     reject_details_reject_patient_name,
     _d6 = reject_details_reject_birth_dt_tm, _d7 = reject_details_reject_mrn, _d8 =
     reject_details_reject_doc_type,
     _d9 = reject_details_reject_subject, _d10 = reject_details_reject_updt_dt_tm, _d11 =
     reject_details_reject_status,
     _d12 = reject_details_reject_service_dt_tm, _d13 = reject_details_reject_provider, _d14 =
     reject_details_match_fin,
     _d15 = reject_details_match_patient_name, _d16 = reject_details_match_birth_dt_tm, _d17 =
     reject_details_match_mrn,
     _d18 = reject_details_match_doc_type, _d19 = reject_details_match_subject, _d20 =
     reject_details_match_updt_dt_tm,
     _d21 = reject_details_match_status, _d22 = reject_details_match_service_dt_tm, _d23 =
     reject_details_match_provider,
     _d24 = reject_details_match_blob_handle, _d25 = reject_details_reject_dt_tm_form, _fenddetail =
     (rptreport->m_pageheight - rptreport->m_marginbottom)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headpagesection(rpt_render)
    DETAIL
     _fdrawheight = headreportsection(rpt_calcheight)
     IF ((_fenddetail > (_yoffset+ _fdrawheight)))
      _fdrawheight = (_fdrawheight+ detailsection(rpt_calcheight))
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headreportsection(rpt_render), _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
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
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.060000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.440000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Contributor System:   ",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Document UID:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Rejection User Name: ",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Rejection Date/Time:",char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("REJECTED DOCUMENT:",char(0)))
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MATCHING DOCUMENT:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Encounter Number:   ",char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Birth Date:",char(0)))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Document Type:",char(0)))
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subject:",char(0)))
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Update Date/Time:",char(0)))
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status:",char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Service Date/Time:",char(0)))
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_contributor_system,char
      (0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reference_nbr,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_user_name,char(0
       )))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_dt_tm_form,char(
       0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_fin,char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_patient_name,
      char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_birth_dt_tm,char
      (0)))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_mrn,char(0)))
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_subject,char(0))
     )
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_doc_type,char(0)
      ))
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_updt_dt_tm,char(
       0)))
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_status,char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_service_dt_tm,
      char(0)))
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_reject_provider,char(0)
      ))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Encounter Number:   ",char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Birth Date:",char(0)))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Document Type:",char(0)))
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Subject:",char(0)))
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Update Date/Time:",char(0)))
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status:",char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Service Date/Time:",char(0)))
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_fin,char(0)))
    SET rptsd->m_y = (offsety+ 1.188)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_patient_name,char
      (0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_birth_dt_tm,char(
       0)))
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_mrn,char(0)))
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_subject,char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_doc_type,char(0))
     )
    SET rptsd->m_y = (offsety+ 2.125)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_updt_dt_tm,char(0
       )))
    SET rptsd->m_y = (offsety+ 2.313)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_status,char(0)))
    SET rptsd->m_y = (offsety+ 2.500)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_service_dt_tm,
      char(0)))
    SET rptsd->m_y = (offsety+ 2.688)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_provider,char(0))
     )
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.875)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blob UID:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 2.875)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 2.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(reject_details_match_blob_handle,char(
       0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 3.250),(offsetx+ 7.500),(offsety+
     3.250))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.790000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.438
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat("ProVision Document Imaging",
       _crlf,"Versioning Failure Report"),char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.621),(offsetx+ 7.500),(offsety+
     0.621))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CDI_RPT_REJECTED_DOCS_LYT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
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
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _times10u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_off
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL reject_query(0)
 CALL finalizereport(_sendto)
END GO
