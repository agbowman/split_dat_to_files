CREATE PROGRAM bhs_rpt_pmr_ordersmd_lo
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = value(673936.00),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Output" = "",
  "Send file to file share" = 0,
  "Date Range" = ""
  WITH outdev, facility, s_start_date,
  s_end_date, output_type, ftpfiles,
  s_range
 EXECUTE reportrtl
 RECORD pmr_consult(
   1 total_done_24hrs = i4
   1 print_requested_by = vc
   1 date_range = vc
   1 total_orders = i4
   1 total_comp = i4
   1 on_time1 = i4
   1 per_on_time1 = vc
   1 per_on_time2 = vc
   1 not_on_time1 = i4
   1 on_time2 = i4
   1 not_on_time2 = i4
   1 cnt_p = i4
   1 discharge_before = i4
   1 prsnl[*]
     2 total_orders = i4
     2 total_comp = i4
     2 toton_time1 = i4
     2 toton_time2 = i4
     2 per_on_time1 = vc
     2 per_on_time2 = vc
     2 totnot_on_time1 = i4
     2 totnot_on_time2 = i4
     2 completed_name = vc
     2 pmr_order[*]
       3 encntr_id = f8
       3 order_id = f8
       3 order_status = vc
       3 comp_prsnl_id = f8
       3 fin = vc
       3 completed_dt_tm = dq8
       3 order_dtttm = dq8
       3 order_status_dt_tm = dq8
       3 due_date1 = dq8
       3 due_date2 = dq8
       3 before_4pm = vc
       3 before_12pm = vc
       3 pat_reg_dttm = dq8
       3 pat_disch_dttm = dq8
       3 done_on_time1 = vc
       3 done_on_time2 = vc
       3 discharge_b4_due1 = vc
       3 discharge_b4_due2 = vc
       3 status = vc
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT
    prsnl_total_orders = pmr_consult->prsnl[d1.seq].total_orders, prsnl_total_comp = pmr_consult->
    prsnl[d1.seq].total_comp, prsnl_toton_time1 = pmr_consult->prsnl[d1.seq].toton_time1,
    prsnl_toton_time2 = pmr_consult->prsnl[d1.seq].toton_time2, prsnl_per_on_time1 = substring(1,30,
     pmr_consult->prsnl[d1.seq].per_on_time1), prsnl_per_on_time2 = substring(1,30,pmr_consult->
     prsnl[d1.seq].per_on_time2),
    prsnl_totnot_on_time1 = pmr_consult->prsnl[d1.seq].totnot_on_time1, prsnl_totnot_on_time2 =
    pmr_consult->prsnl[d1.seq].totnot_on_time2, prsnl_completed_name = substring(1,30,pmr_consult->
     prsnl[d1.seq].completed_name)
    FROM (dummyt d1  WITH seq = size(pmr_consult->prsnl,5))
    PLAN (d1)
    HEAD REPORT
     _d0 = d1.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fenddetail
      -= footpagesection(rpt_calcheight),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     dummy_val = headpagesection_md_summary(rpt_render)
    DETAIL
     _fdrawheight = detailsection_md_summary(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = detailsection_md_summary(rpt_render)
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
     _yoffset = _yhold
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
   DECLARE sectionheight = f8 WITH noconstant(0.840000), private
   DECLARE __print_requestor = vc WITH noconstant(build2(pmr_consult->print_requested_by,char(0))),
   protect
   DECLARE __date_range = vc WITH noconstant(build2(pmr_consult->date_range,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.376
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PM&R Report",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reqested By:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.167
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__print_requestor)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.573)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_range)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.573)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.782
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Range:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.011),(offsety+ 0.797),(offsetx+ 7.501),(offsety+
     0.797))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection_md_summary(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection_md_summaryabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection_md_summaryabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   IF ( NOT (( $OUTPUT_TYPE IN ("MDSUMMARY", "MDSUMTOT"))))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 0.980
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Complete By",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.365),(offsetx+ 7.491),(offsety+
     0.365))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Orders 12pm On Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Orders",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Orders 4pm On Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.126)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Orders 12pm % On Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Orders 4pm % On Time",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection_md_summary(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection_md_summaryabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsection_md_summaryabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __completeby = vc WITH noconstant(build2(pmr_consult->prsnl[d1.seq].completed_name,char(0)
     )), protect
   DECLARE __md_total_orders = vc WITH noconstant(build2(pmr_consult->prsnl[d1.seq].total_orders,char
     (0))), protect
   DECLARE __order_on_time1 = vc WITH noconstant(build2(pmr_consult->prsnl[d1.seq].toton_time1,char(0
      ))), protect
   DECLARE __per_ontime1 = vc WITH noconstant(build2(concat(format(round(((cnvtreal(pmr_consult->
         prsnl[d1.seq].toton_time1)/ cnvtreal(pmr_consult->prsnl[d1.seq].total_comp)) * 100),2),
       "###.##;p0")," %"),char(0))), protect
   DECLARE __per_ontime3 = vc WITH noconstant(build2(concat(format(round(((cnvtreal(pmr_consult->
         prsnl[d1.seq].toton_time2)/ cnvtreal(pmr_consult->prsnl[d1.seq].total_comp)) * 100),2),
       "###.##;p0")," %"),char(0))), protect
   DECLARE __order_on_time2 = vc WITH noconstant(build2(pmr_consult->prsnl[d1.seq].toton_time2,char(0
      ))), protect
   IF ( NOT (( $OUTPUT_TYPE IN ("MDSUMMARY", "MDSUMTOT"))))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.011)
    SET rptsd->m_width = 0.928
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__completeby)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.011)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__md_total_orders)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_on_time1)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.126)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__per_ontime1)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__per_ontime3)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_on_time2)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 1.584
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Page:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.052),(offsetx+ 7.501),(offsety+
     0.052))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.368798), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.362
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Description",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.650
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Amount",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Percent of Total Orders",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ 0.000),(offsetx+ 6.147),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ sectionheight),(offsetx+ 6.147),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.368798), private
   DECLARE __on_time1 = vc WITH noconstant(build(pmr_consult->on_time1,char(0))), protect
   DECLARE __ontime1_percent = vc WITH noconstant(build(build(pmr_consult->per_on_time1," %"),char(0
      ))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.362
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Completed OnTime 12 pm",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.650
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__on_time1)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ontime1_percent)
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ 0.000),(offsetx+ 6.147),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ sectionheight),(offsetx+ 6.147),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.368798), private
   DECLARE __on_time2 = vc WITH noconstant(build(pmr_consult->on_time2,char(0))), protect
   DECLARE __ontime2_percent = vc WITH noconstant(build(build(pmr_consult->per_on_time2," %"),char(0
      ))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.362
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Completed On Time 4 pm",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.650
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__on_time2)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.362
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ontime2_percent)
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ 0.000),(offsetx+ 6.147),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ sectionheight),(offsetx+ 6.147),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow5(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.358261), private
   DECLARE __completed = vc WITH noconstant(build(pmr_consult->total_comp,char(0))), protect
   DECLARE __cellname0 = vc WITH noconstant(build(concat(format(round(((cnvtreal(pmr_consult->
         total_comp)/ cnvtreal(pmr_consult->total_comp)) * 100),2),"###.##;p0")," %"),char(0))),
   protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.352
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Completed Orders",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.650
   SET rptsd->m_height = 0.352
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__completed)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.352
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname0)
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ 0.000),(offsetx+ 6.147),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ sectionheight),(offsetx+ 6.147),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow6(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.358261), private
   DECLARE __total_orders = vc WITH noconstant(build(pmr_consult->total_orders,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.352
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Total Orders",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.650
   SET rptsd->m_height = 0.352
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__total_orders)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.352
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),offsety,(offsetx+ 1.125),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ 0.000),(offsetx+ 6.147),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.125),(offsety+ sectionheight),(offsetx+ 6.147),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (( $OUTPUT_TYPE IN ("MDSUMTOT"))))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight += tablerow(rpt_render)
     SET holdheight += tablerow1(rpt_render)
     SET holdheight += tablerow2(rpt_render)
     SET holdheight += tablerow5(rpt_render)
     SET holdheight += tablerow6(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_PMR_ORDERSMD_LO"
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
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
