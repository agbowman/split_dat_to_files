CREATE PROGRAM bhs_rpt_dasa_iv_lo
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_start_date, s_end_date
 EXECUTE reportrtl
 RECORD dasaiv(
   1 m_cnt_pat = i4
   1 m_pt_total = i4
   1 f_per_hightot = f8
   1 f_per_medtot = f8
   1 f_per_lowtot = f8
   1 m_cnthightot = i4
   1 m_cntmediumtot = i4
   1 m_cntlowtot = i4
   1 pats[*]
     2 m_cntres = i4
     2 f_pat_tot_score = f8
     2 s_pat = vc
     2 f_avg = f8
     2 m_cnthigh = i4
     2 m_cntmedium = i4
     2 m_cntlow = i4
     2 m_pt_total = i4
     2 f_per_high = f8
     2 f_per_med = f8
     2 f_per_low = f8
     2 det[*]
       3 d_charted = dq8
       3 s_mrn = vc
       3 f_score = f8
   1 m_cnttot_results = i4
   1 runby = vc
   1 facility = vc
   1 unit = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
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
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
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
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT
    pats_s_pat = substring(1,30,dasaiv->pats[d1.seq].s_pat), det_s_mrn = substring(1,30,dasaiv->pats[
     d1.seq].det[d2.seq].s_mrn), det_d_charted = dasaiv->pats[d1.seq].det[d2.seq].d_charted,
    det_f_score = dasaiv->pats[d1.seq].det[d2.seq].f_score, pats_f_avg = dasaiv->pats[d1.seq].f_avg,
    pats_m_cnthigh = dasaiv->pats[d1.seq].m_cnthigh,
    pats_m_cntmedium = dasaiv->pats[d1.seq].m_cntmedium, pats_m_cntlow = dasaiv->pats[d1.seq].
    m_cntlow
    FROM (dummyt d1  WITH seq = size(dasaiv->pats,5)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(dasaiv->pats[d1.seq].det,5)))
     JOIN (d2)
    HEAD REPORT
     _d0 = d1.seq, _d1 = d2.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headpagesection(rpt_render)
    DETAIL
     _fdrawheight = detailsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection(rpt_render)
    FOOT REPORT
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
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE __unit = vc WITH noconstant(build2(concat("Nurse Unit: ",dasaiv->unit),char(0))), protect
   DECLARE __facilty = vc WITH noconstant(build2(concat("Facility: ",dasaiv->facility),char(0))),
   protect
   DECLARE __date_range = vc WITH noconstant(build2(concat("Date Range :",format(cnvtdatetime(
         $S_START_DATE),"@SHORTDATE4YR")," - ",format(cnvtdatetime( $S_END_DATE),"@SHORTDATE4YR")),
     char(0))), protect
   DECLARE __run_by_per = vc WITH noconstant(build2(concat("Run By : ",dasaiv->runby),char(0))),
   protect
   DECLARE __rundate = vc WITH noconstant(build2(concat("Run Date : ",format(cnvtdatetime(sysdate),
       "MM/dd/yyyy HH:mm;3;d")),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.480)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 4.938
    SET rptsd->m_height = 0.271
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DASA Patient Score Report",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__unit)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__facilty)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_range)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__run_by_per)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.261
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rundate)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.820000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.438
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Time of Score",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DASA Score",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.376
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("High Scores > 3",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medium Scores 2-3",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Low Scores 0-1",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.740),(offsetx+ 7.501),(offsety+
     0.740))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 1.261
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Average DASA Score",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __patient_name = vc WITH noconstant(build2(dasaiv->pats[d1.seq].s_pat,char(0))), protect
   DECLARE __date_charted = vc WITH noconstant(build2(format(dasaiv->pats[d1.seq].det[d2.seq].
      d_charted,"MM/DD/yyyy HH:mm;3;D"),char(0))), protect
   DECLARE __score = vc WITH noconstant(build2(format(dasaiv->pats[d1.seq].det[d2.seq].f_score,"###"),
     char(0))), protect
   IF (d2.seq=1)
    DECLARE __high_scores = vc WITH noconstant(build2(dasaiv->pats[d1.seq].m_cnthigh,char(0))),
    protect
   ENDIF
   IF (d2.seq=1)
    DECLARE __medium = vc WITH noconstant(build2(dasaiv->pats[d1.seq].m_cntmedium,char(0))), protect
   ENDIF
   IF (d2.seq=1)
    DECLARE __low = vc WITH noconstant(build2(dasaiv->pats[d1.seq].m_cntlow,char(0))), protect
   ENDIF
   DECLARE __mrn = vc WITH noconstant(build2(dasaiv->pats[d1.seq].det[d2.seq].s_mrn,char(0))),
   protect
   IF (d2.seq=1)
    DECLARE __average = vc WITH noconstant(build2(format(dasaiv->pats[d1.seq].f_avg,"###.#"),char(0))
     ), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_charted)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__score)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    IF (d2.seq=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__high_scores)
    ENDIF
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    IF (d2.seq=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__medium)
    ENDIF
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    IF (d2.seq=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__low)
    ENDIF
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s1c0)
    IF (d2.seq=1)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.021),(offsetx+ 7.501),(offsety
      + 0.021))
    ENDIF
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (d2.seq=1)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__average)
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.410000), private
   DECLARE __percent_high = vc WITH noconstant(build2(format(dasaiv->f_per_hightot,"###%"),char(0))),
   protect
   DECLARE __number_results = vc WITH noconstant(build2(format(cnvtreal(dasaiv->m_cnttot_results),
      "###"),char(0))), protect
   DECLARE __percent_med = vc WITH noconstant(build2(format(dasaiv->f_per_medtot,"###%"),char(0))),
   protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(format(dasaiv->f_per_lowtot,"###%"),char(0))),
   protect
   DECLARE __total_patients_with_score = vc WITH noconstant(build2(build("Total Patients: ",dasaiv->
      m_cnt_pat),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__percent_high)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__number_results)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__percent_med)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.011),(offsety+ 0.021),(offsetx+ 7.501),(offsety+
     0.021))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.084),(offsetx+ 7.491),(offsety+
     0.084))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Totals/Averages",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 0.834
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Results:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 1.740
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__total_patients_with_score)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_DASA_IV_LO"
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
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 1
   SET _pen14s1c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
