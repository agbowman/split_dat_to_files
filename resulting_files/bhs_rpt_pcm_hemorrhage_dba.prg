CREATE PROGRAM bhs_rpt_pcm_hemorrhage:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Facility:" = 999999
  WITH outdev, ms_start_date, ms_end_date,
  mf_facility_cd
 DECLARE mf_cs72_deliverycomplications_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DELIVERYCOMPLICATIONS"))
 DECLARE mf_cs72_deliveryphysician_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYPHYSICIAN"))
 DECLARE mf_cs72_deliverycnm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,
   "DELIVERYCNM"))
 DECLARE mf_cs72_deliverytype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Delivery Type:"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs16769_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "COMPLETED"))
 DECLARE mf_cs16769_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"ORDERED")
  )
 DECLARE mf_cs16769_started_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"STARTED")
  )
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD nurs_loc
 RECORD nurs_loc(
   1 l_mom_cnt = i4
   1 mom_unit[*]
     2 f_code_value = f8
     2 s_display = vc
   1 l_icu_cnt = i4
   1 icu_unit[*]
     2 f_code_value = f8
     2 s_display = vc
 ) WITH protect
 FREE RECORD m_enc
 RECORD m_enc(
   1 l_tot_dcompl = i4
   1 l_tot_dtype = i4
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_delivery_physician = vc
     2 s_delivery_cnm = vc
     2 s_delivery_type = vc
     2 s_delivery_complications = vc
     2 l_dtype_ind = i4
     2 l_dcompl_ind = i4
     2 l_pcat_ind = i4
     2 s_pat_name = vc
     2 s_pat_mrn = vc
 )
 IF (( $MF_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSE
  SET ms_facility_p = build("nu.loc_facility_cd = ", $MF_FACILITY_CD)
 ENDIF
 IF (ms_outdev="OPS")
  SET ml_ops_ind = 1
  SET mf_end_dt_tm = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
  SET mf_beg_dt_tm = cnvtlookbehind("1 M",cnvtdatetime(mf_end_dt_tm))
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_START_DATE,"DD-MMM-YYYY"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),235959)
  DECLARE _createfonts(dummy) = null WITH protect
  DECLARE _createpens(dummy) = null WITH protect
  DECLARE pagebreak(dummy) = null WITH protect
  DECLARE initializereport(dummy) = null WITH protect
  DECLARE _hreport = h WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  DECLARE rpt_render = i2 WITH constant(0), protect
  DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
  DECLARE rpt_calcheight = i2 WITH constant(1), protect
  DECLARE _yshift = f8 WITH noconstant(0.0), protect
  DECLARE _xshift = f8 WITH noconstant(0.0), protect
  DECLARE _sendto = vc WITH noconstant(""), protect
  DECLARE _rpterr = i2 WITH noconstant(0), protect
  DECLARE _rptstat = i2 WITH noconstant(0), protect
  DECLARE _oldfont = i4 WITH noconstant(0), protect
  DECLARE _oldpen = i4 WITH noconstant(0), protect
  DECLARE _dummyfont = i4 WITH noconstant(0), protect
  DECLARE _dummypen = i4 WITH noconstant(0), protect
  DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
  DECLARE _rptpage = h WITH noconstant(0), protect
  DECLARE _diotype = i2 WITH noconstant(8), protect
  DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _times12b0 = i4 WITH noconstant(0), protect
  DECLARE _times14b0 = i4 WITH noconstant(0), protect
  DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
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
  SUBROUTINE (sec_summary(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = sec_summaryabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (sec_summaryabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.790000), private
    DECLARE __fld_prcnt_hem = vc WITH noconstant(build2(
      IF ((m_enc->l_tot_dtype=0)) "0%"
      ELSE concat(trim(cnvtstring(((cnvtreal(m_enc->l_tot_dcompl)/ cnvtreal(m_enc->l_tot_dtype)) *
          100.00),20,2),3),"%")
      ENDIF
      ,char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 0.063)
     SET rptsd->m_width = 1.698
     SET rptsd->m_height = 0.303
     SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("SUMMARY:",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.521)
     SET rptsd->m_x = (offsetx+ 0.042)
     SET rptsd->m_width = 2.521
     SET rptsd->m_height = 0.230
     SET _dummyfont = uar_rptsetfont(_hreport,_times100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "% of deliveries with postpartum hemorrhage",char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 2.667)
     SET rptsd->m_width = 1.646
     SET rptsd->m_height = 0.209
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fld_prcnt_hem)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (sec_det_head(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = sec_det_headabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (sec_det_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.790000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 0.063)
     SET rptsd->m_width = 1.698
     SET rptsd->m_height = 0.303
     SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DETAILS:",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.480)
     SET rptsd->m_x = (offsetx+ 0.042)
     SET rptsd->m_width = 1.084
     SET rptsd->m_height = 0.261
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 4.625)
     SET rptsd->m_width = 2.126
     SET rptsd->m_height = 0.261
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Delivering Provider",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 2.813)
     SET rptsd->m_width = 1.084
     SET rptsd->m_height = 0.261
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.746),(offsetx+ 7.543),(offsety
      + 0.746))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (sec_detail(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = sec_detailabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (sec_detailabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.270000), private
    DECLARE __fld_pat_name = vc WITH noconstant(build2(m_enc->qual[ml_idx1].s_pat_name,char(0))),
    protect
    DECLARE __fld_pat_mrn = vc WITH noconstant(build2(m_enc->qual[ml_idx1].s_pat_mrn,char(0))),
    protect
    DECLARE __fld_pat_doc = vc WITH noconstant(build2(
      IF (size(m_enc->qual[ml_idx1].s_delivery_physician) > 0) m_enc->qual[ml_idx1].
       s_delivery_physician
      ELSE m_enc->qual[ml_idx1].s_delivery_cnm
      ENDIF
      ,char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.605
     SET rptsd->m_height = 0.261
     SET _oldfont = uar_rptsetfont(_hreport,_times100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fld_pat_name)
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 2.751)
     SET rptsd->m_width = 1.750
     SET rptsd->m_height = 0.261
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fld_pat_mrn)
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 4.625)
     SET rptsd->m_width = 2.813
     SET rptsd->m_height = 0.261
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fld_pat_doc)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (sec_footer(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = sec_footerabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (sec_footerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.290000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 2.313)
     SET rptsd->m_width = 2.136
     SET rptsd->m_height = 0.261
     SET _oldfont = uar_rptsetfont(_hreport,_times100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "BHS_RPT_PCM_HEMORRHAGE"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
    SET rptreport->m_marginleft = 0.50
    SET rptreport->m_marginright = 0.50
    SET rptreport->m_margintop = 0.50
    SET rptreport->m_marginbottom = 0.50
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET rptreport->m_dioflag = 0
    SET rptreport->m_needsnotonaskharabic = 0
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
    SET rptfont->m_recsize = 62
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET rptfont->m_underline = rpt_off
    SET rptfont->m_strikethrough = rpt_off
    SET rptfont->m_rgbcolor = rpt_black
    SET _times100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 14
    SET rptfont->m_bold = rpt_on
    SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 12
    SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  SET d0 = initializereport(0)
 ENDIF
 CALL echo(format(cnvtdatetime(mf_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(mf_end_dt_tm),";;q"))
 SELECT INTO "nl:"
  FROM code_value cv,
   nurse_unit nu
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key IN ("WIN2", "WETU1", "OBGN", "LDRPA", "LDRPB",
   "LDRPC")
    AND cv.active_ind=1)
   JOIN (nu
   WHERE nu.location_cd=cv.code_value
    AND parser(ms_facility_p))
  HEAD REPORT
   nurs_loc->l_mom_cnt = 0
  DETAIL
   nurs_loc->l_mom_cnt += 1, stat = alterlist(nurs_loc->mom_unit,nurs_loc->l_mom_cnt), nurs_loc->
   mom_unit[nurs_loc->l_mom_cnt].f_code_value = cv.code_value,
   nurs_loc->mom_unit[nurs_loc->l_mom_cnt].s_display = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_loc_hist elh,
   person p
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND expand(ml_idx1,1,nurs_loc->l_mom_cnt,elh.loc_nurse_unit_cd,nurs_loc->mom_unit[ml_idx1].
    f_code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->l_cnt += 1, stat = alterlist(m_enc->qual,m_enc->l_cnt), m_enc->qual[m_enc->l_cnt].
   f_encntr_id = e.encntr_id,
   m_enc->qual[m_enc->l_cnt].f_person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_coded_result ccr,
   nomenclature n
  PLAN (ce
   WHERE expand(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_auth_cd, mf_cs8_altered_cd,
   mf_cs8_modified_cd)
    AND ce.event_cd IN (mf_cs72_deliverycomplications_cd, mf_cs72_deliverytype_cd,
   mf_cs72_deliveryphysician_cd, mf_cs72_deliverycnm_cd))
   JOIN (ccr
   WHERE (ccr.event_id= Outerjoin(ce.event_id))
    AND (ccr.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(ccr.nomenclature_id)) )
  ORDER BY ce.encntr_id, ce.event_cd, ce.performed_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,ce.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs72_deliveryphysician_cd)
    m_enc->qual[ml_idx2].s_delivery_physician = ce.result_val
   ENDIF
   IF (ce.event_cd=mf_cs72_deliverycnm_cd)
    m_enc->qual[ml_idx2].s_delivery_cnm = ce.result_val
   ENDIF
   IF (ce.event_cd=mf_cs72_deliverycomplications_cd)
    m_enc->qual[ml_idx2].s_delivery_complications = ce.result_val
   ENDIF
   IF (ce.event_cd=mf_cs72_deliverytype_cd)
    m_enc->qual[ml_idx2].s_delivery_type = ce.result_val
   ENDIF
  DETAIL
   IF (ce.event_cd=mf_cs72_deliverycomplications_cd)
    IF (trim(n.source_string,3)="Hemorrhage, peripartum or postpartum")
     m_enc->qual[ml_idx2].l_dcompl_ind = 1
    ENDIF
   ELSEIF (ce.event_cd=mf_cs72_deliverytype_cd)
    IF (trim(n.source_string,3) IN ("Vaginal", "Vaginal, forcep and vacuum", "Vaginal, forcep assist",
    "Vaginal, vacuum assist", "VBAC",
    "C-section, indicated", "C-Section, classical", "C-Section, low transverse",
    "C-Section, forcep and vacuum", "C-Section, forcep assist",
    "C-Section, J incision", "C-Section, low vertical", "C-Section, other", "C-Section, T incision",
    "C-Section, vacuum assist",
    "Placenta only"))
     m_enc->qual[ml_idx2].l_dtype_ind = 1
    ENDIF
   ENDIF
  FOOT  ce.encntr_id
   IF ((m_enc->qual[ml_idx2].l_dcompl_ind=1))
    m_enc->l_tot_dcompl += 1
   ENDIF
   IF ((m_enc->qual[ml_idx2].l_dtype_ind=1))
    m_enc->l_tot_dtype += 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_enc->l_cnt),
   encounter e,
   person p,
   encntr_alias ea
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=m_enc->qual[d1.seq].f_encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_mrn_cd)) )
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_enc->qual[d1.seq].s_pat_name = trim(p.name_full_formatted), m_enc->qual[d1.seq].s_pat_mrn = trim
   (ea.alias,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway pth,
   pathway_catalog pc
  PLAN (pth
   WHERE expand(ml_idx1,1,m_enc->l_cnt,pth.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
    AND pth.pw_status_cd IN (mf_cs16769_started_cd, mf_cs16769_ordered_cd, mf_cs16769_completed_cd)
    AND pth.active_ind=1
    AND pth.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pc
   WHERE pc.pathway_catalog_id=pth.pathway_catalog_id
    AND pc.description_key="OB - POSTPARTUM HEMORRHAGE"
    AND pc.type_mean="CAREPLAN")
  ORDER BY pth.encntr_id
  HEAD pth.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_enc->l_cnt,pth.encntr_id,m_enc->qual[ml_idx1].f_encntr_id)
   IF (ml_idx2 > 0)
    m_enc->qual[ml_idx2].l_pcat_ind = 1
    IF ((m_enc->qual[ml_idx2].l_dcompl_ind=0))
     m_enc->l_tot_dcompl += 1
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (ms_outdev="OPS")
  SET frec->file_name = concat("bhs_rpt_pcm_hemorrhage_",format(sysdate,"MMDDYYYY;;q"),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"SUMMARY:"',char(13))
  SET stat = cclio("WRITE",frec)
  SET frec->file_buf = concat(char(13),'"% of deliveries with postpartum hemorrhage",')
  IF ((m_enc->l_tot_dtype=0))
   SET frec->file_buf = concat(frec->file_buf,'"0%"',char(13))
  ELSE
   SET frec->file_buf = concat(frec->file_buf,'"',trim(cnvtstring(((cnvtreal(m_enc->l_tot_dcompl)/
      cnvtreal(m_enc->l_tot_dtype)) * 100.00),20,2),3),'%"',char(13))
  ENDIF
  SET stat = cclio("WRITE",frec)
  SET frec->file_buf = build(char(13),'"DETAILS:"',char(13),char(13))
  SET stat = cclio("WRITE",frec)
  SET frec->file_buf = build('"Patient Name",','"MRN",','"Delivering Provider"',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_enc->l_cnt)
    IF ((((m_enc->qual[ml_idx1].l_dcompl_ind > 0)) OR ((m_enc->qual[ml_idx1].l_pcat_ind > 0))) )
     SET frec->file_buf = build('"',m_enc->qual[ml_idx1].s_pat_name,'","',m_enc->qual[ml_idx1].
      s_pat_mrn)
     IF (size(m_enc->qual[ml_idx1].s_delivery_physician) > 0)
      SET frec->file_buf = build(frec->file_buf,'","',m_enc->qual[ml_idx1].s_delivery_physician)
     ELSE
      SET frec->file_buf = build(frec->file_buf,'","',m_enc->qual[ml_idx1].s_delivery_cnm)
     ENDIF
     SET frec->file_buf = build(frec->file_buf,'"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  DECLARE ms_tmp = vc WITH protect, noconstant("")
  DECLARE ms_email = vc WITH protect, constant("obqualityandsafetyleadership@bhs.org")
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("PCM Hemorrhage Report: ",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ELSE
  DECLARE mf_page_size = f8 WITH protect, constant(10.25)
  DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
  DECLARE ml_chg_pg = i4 WITH protect, noconstant(0)
  EXECUTE reportrtl
  SET d0 = sec_summary(rpt_render)
  SET d0 = sec_det_head(rpt_render)
  FOR (ml_idx1 = 1 TO m_enc->l_cnt)
    IF ((((m_enc->qual[ml_idx1].l_dcompl_ind > 0)) OR ((m_enc->qual[ml_idx1].l_pcat_ind > 0))) )
     SET mf_rem_space = (mf_page_size - (_yoffset+ sec_detail(rpt_calcheight)))
     IF (mf_rem_space <= 0.25)
      SET _yoffset = 10.18
      SET d0 = sec_footer(rpt_render)
      SET d0 = pagebreak(0)
     ENDIF
     SET d0 = sec_detail(rpt_render)
    ENDIF
  ENDFOR
  SET _yoffset = 10.18
  SET d0 = sec_footer(rpt_render)
  SET d0 = finalizereport(value( $OUTDEV))
 ENDIF
#exit_script
END GO
