CREATE PROGRAM bhs_rpt_consult_orders_lo
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = value(673936.00),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Orders" = 0,
  "Select Output" = "",
  "s_create_files" = 0,
  "Date Range" = "",
  "Enter Email" = ""
  WITH outdev, facility, s_start_date,
  s_end_date, f_orders, output_type,
  s_create_files, s_range, s_emails
 EXECUTE reportrtl
 RECORD consult(
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
     2 consult_order[*]
       3 encntr_id = f8
       3 order_id = f8
       3 order_status = vc
       3 order_name = vc
       3 encntr_type = vc
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
 DECLARE _remorder_dt_tm = i4 WITH noconstant(1), protect
 DECLARE _remon_time_12pm = i4 WITH noconstant(1), protect
 DECLARE _remaccountnum = i4 WITH noconstant(1), protect
 DECLARE _remcompletedby = i4 WITH noconstant(1), protect
 DECLARE _remcompleted_date = i4 WITH noconstant(1), protect
 DECLARE _remorder_dt_tm0 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times200 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT
    consult_per_on_time1 = substring(1,30,consult->per_on_time1), prsnl_total_orders = consult->
    prsnl[d1.seq].total_orders, prsnl_toton_time1 = consult->prsnl[d1.seq].toton_time1,
    consult_order_encntr_id = consult->prsnl[d1.seq].consult_order[d2.seq].encntr_id,
    consult_order_order_id = consult->prsnl[d1.seq].consult_order[d2.seq].order_id,
    consult_order_order_status = substring(1,30,consult->prsnl[d1.seq].consult_order[d2.seq].
     order_status),
    consult_order_order_name = substring(1,30,consult->prsnl[d1.seq].consult_order[d2.seq].order_name
     ), consult_order_encntr_type = substring(1,30,consult->prsnl[d1.seq].consult_order[d2.seq].
     encntr_type), consult_order_comp_prsnl_id = consult->prsnl[d1.seq].consult_order[d2.seq].
    comp_prsnl_id,
    consult_order_fin = substring(1,30,consult->prsnl[d1.seq].consult_order[d2.seq].fin),
    consult_order_completed_dt_tm = consult->prsnl[d1.seq].consult_order[d2.seq].completed_dt_tm
    FROM (dummyt d1  WITH seq = size(consult->prsnl,5)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(consult->prsnl[d1.seq].consult_order,5)))
     JOIN (d2)
    HEAD REPORT
     _d0 = d1.seq, _d1 = d2.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom),
     _fenddetail -= footpagesection(rpt_calcheight), _fdrawheight = headreportsection(rpt_calcheight)
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
     _bcontdetailsection = 0, bfirsttime = 1
     WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontdetailsection=0)
        BREAK
       ENDIF
       dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection), bfirsttime
        = 0
     ENDWHILE
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
   DECLARE __print_requestor = vc WITH noconstant(build2(consult->print_requested_by,char(0))),
   protect
   DECLARE __date_range = vc WITH noconstant(build2(consult->date_range,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
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
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 7.511
    SET rptsd->m_height = 0.376
    SET _dummyfont = uar_rptsetfont(_hreport,_times200)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_report_name,char(0)))
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
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF ( NOT (((( $OUTPUT_TYPE="DETAIL")) OR (( $OUTPUT_TYPE="DETSUM"))) ))
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
    SET rptsd->m_x = (offsetx+ 0.698)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct#",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.688)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Completed By",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("On time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Competed",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.063)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.031)),(offsety+ 0.240),(offsetx+ 7.459),(
     offsety+ 0.240))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.563)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Discharge Date",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Name",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order_dt_tm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_on_time_12pm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_accountnum = f8 WITH noconstant(0.0), private
   DECLARE drawheight_completedby = f8 WITH noconstant(0.0), private
   DECLARE drawheight_completed_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_order_dt_tm0 = f8 WITH noconstant(0.0), private
   DECLARE __order_dt_tm = vc WITH noconstant(build2(format(consult->prsnl[d1.seq].consult_order[d2
      .seq].order_dtttm,"mm/dd/yy hh:mm;3;Q"),char(0))), protect
   DECLARE __on_time_12pm = vc WITH noconstant(build2(consult->prsnl[d1.seq].consult_order[d2.seq].
     done_on_time1,char(0))), protect
   DECLARE __accountnum = vc WITH noconstant(build2(consult->prsnl[d1.seq].consult_order[d2.seq].fin,
     char(0))), protect
   DECLARE __completedby = vc WITH noconstant(build2(substring(1,100,consult->prsnl[d1.seq].
      completed_name),char(0))), protect
   DECLARE __completed_date = vc WITH noconstant(build2(format(consult->prsnl[d1.seq].consult_order[
      d2.seq].completed_dt_tm,"mm/dd/yyyy hh:mm;3;Q"),char(0))), protect
   DECLARE __order_stat = vc WITH noconstant(build2(consult->prsnl[d1.seq].consult_order[d2.seq].
     order_status,char(0))), protect
   DECLARE __disch_date = vc WITH noconstant(build2(format(consult->prsnl[d1.seq].consult_order[d2
      .seq].pat_disch_dttm,"mm/dd/yyyy hh:mm;;d"),char(0))), protect
   DECLARE __order_dt_tm0 = vc WITH noconstant(build2(consult->prsnl[d1.seq].consult_order[d2.seq].
     order_name,char(0))), protect
   IF ( NOT (((( $OUTPUT_TYPE="DETAIL")) OR (( $OUTPUT_TYPE="DETSUM"))) ))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remorder_dt_tm = 1
    SET _remon_time_12pm = 1
    SET _remaccountnum = 1
    SET _remcompletedby = 1
    SET _remcompleted_date = 1
    SET _remorder_dt_tm0 = 1
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
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.688)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremorder_dt_tm = _remorder_dt_tm
   IF (_remorder_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_dt_tm,((size(
        __order_dt_tm) - _remorder_dt_tm)+ 1),__order_dt_tm)))
    SET drawheight_order_dt_tm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_dt_tm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_dt_tm,((size(__order_dt_tm) -
       _remorder_dt_tm)+ 1),__order_dt_tm)))))
     SET _remorder_dt_tm += rptsd->m_drawlength
    ELSE
     SET _remorder_dt_tm = 0
    ENDIF
    SET growsum += _remorder_dt_tm
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 0.376
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremon_time_12pm = _remon_time_12pm
   IF (_remon_time_12pm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remon_time_12pm,((size(
        __on_time_12pm) - _remon_time_12pm)+ 1),__on_time_12pm)))
    SET drawheight_on_time_12pm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remon_time_12pm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remon_time_12pm,((size(__on_time_12pm) -
       _remon_time_12pm)+ 1),__on_time_12pm)))))
     SET _remon_time_12pm += rptsd->m_drawlength
    ELSE
     SET _remon_time_12pm = 0
    ENDIF
    SET growsum += _remon_time_12pm
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.636
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremaccountnum = _remaccountnum
   IF (_remaccountnum > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remaccountnum,((size(
        __accountnum) - _remaccountnum)+ 1),__accountnum)))
    SET drawheight_accountnum = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remaccountnum = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remaccountnum,((size(__accountnum) -
       _remaccountnum)+ 1),__accountnum)))))
     SET _remaccountnum += rptsd->m_drawlength
    ELSE
     SET _remaccountnum = 0
    ENDIF
    SET growsum += _remaccountnum
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcompletedby = _remcompletedby
   IF (_remcompletedby > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcompletedby,((size(
        __completedby) - _remcompletedby)+ 1),__completedby)))
    SET drawheight_completedby = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcompletedby = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcompletedby,((size(__completedby) -
       _remcompletedby)+ 1),__completedby)))))
     SET _remcompletedby += rptsd->m_drawlength
    ELSE
     SET _remcompletedby = 0
    ENDIF
    SET growsum += _remcompletedby
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.188)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcompleted_date = _remcompleted_date
   IF (_remcompleted_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcompleted_date,((size(
        __completed_date) - _remcompleted_date)+ 1),__completed_date)))
    SET drawheight_completed_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcompleted_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcompleted_date,((size(__completed_date
        ) - _remcompleted_date)+ 1),__completed_date)))))
     SET _remcompleted_date += rptsd->m_drawlength
    ELSE
     SET _remcompleted_date = 0
    ENDIF
    SET growsum += _remcompleted_date
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremorder_dt_tm0 = _remorder_dt_tm0
   IF (_remorder_dt_tm0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_dt_tm0,((size(
        __order_dt_tm0) - _remorder_dt_tm0)+ 1),__order_dt_tm0)))
    SET drawheight_order_dt_tm0 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_dt_tm0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_dt_tm0,((size(__order_dt_tm0) -
       _remorder_dt_tm0)+ 1),__order_dt_tm0)))))
     SET _remorder_dt_tm0 += rptsd->m_drawlength
    ELSE
     SET _remorder_dt_tm0 = 0
    ENDIF
    SET growsum += _remorder_dt_tm0
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.688)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = drawheight_order_dt_tm
   IF (ncalc=rpt_render
    AND _holdremorder_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_dt_tm,((size
       (__order_dt_tm) - _holdremorder_dt_tm)+ 1),__order_dt_tm)))
   ELSE
    SET _remorder_dt_tm = _holdremorder_dt_tm
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 0.376
   SET rptsd->m_height = drawheight_on_time_12pm
   IF (ncalc=rpt_render
    AND _holdremon_time_12pm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremon_time_12pm,((
       size(__on_time_12pm) - _holdremon_time_12pm)+ 1),__on_time_12pm)))
   ELSE
    SET _remon_time_12pm = _holdremon_time_12pm
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.636
   SET rptsd->m_height = drawheight_accountnum
   IF (ncalc=rpt_render
    AND _holdremaccountnum > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremaccountnum,((size(
        __accountnum) - _holdremaccountnum)+ 1),__accountnum)))
   ELSE
    SET _remaccountnum = _holdremaccountnum
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.688)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_completedby
   IF (ncalc=rpt_render
    AND _holdremcompletedby > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcompletedby,((size
       (__completedby) - _holdremcompletedby)+ 1),__completedby)))
   ELSE
    SET _remcompletedby = _holdremcompletedby
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.188)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_completed_date
   IF (ncalc=rpt_render
    AND _holdremcompleted_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcompleted_date,((
       size(__completed_date) - _holdremcompleted_date)+ 1),__completed_date)))
   ELSE
    SET _remcompleted_date = _holdremcompleted_date
   ENDIF
   SET rptsd->m_flags = 12
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.938)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.251
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_stat)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.563)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.251
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__disch_date)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.438)
   SET rptsd->m_width = 1.313
   SET rptsd->m_height = drawheight_order_dt_tm0
   IF (ncalc=rpt_render
    AND _holdremorder_dt_tm0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_dt_tm0,((
       size(__order_dt_tm0) - _holdremorder_dt_tm0)+ 1),__order_dt_tm0)))
   ELSE
    SET _remorder_dt_tm0 = _holdremorder_dt_tm0
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
    SET rptsd->m_x = (offsetx+ 5.250)
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
   DECLARE sectionheight = f8 WITH noconstant(0.372509), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.366
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
   SET rptsd->m_height = 0.366
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Amount",char(0)))
   ENDIF
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.366
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Percent of Total Completed Orders",
      char(0)))
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
   DECLARE sectionheight = f8 WITH noconstant(0.372509), private
   DECLARE __consult_on_time1 = vc WITH noconstant(build(consult->on_time1,char(0))), protect
   DECLARE __build_consult_per_on_time1 = vc WITH noconstant(build(build(consult->per_on_time1," %"),
     char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.366
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Completed OnTime",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.650
   SET rptsd->m_height = 0.366
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__consult_on_time1)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.366
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__build_consult_per_on_time1)
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
   DECLARE sectionheight = f8 WITH noconstant(0.361866), private
   DECLARE __consult_total_comp = vc WITH noconstant(build(consult->total_comp,char(0))), protect
   DECLARE __cellname0 = vc WITH noconstant(build(concat(format(round(((cnvtreal(consult->total_comp)
        / cnvtreal(consult->total_comp)) * 100),2),"###.##;p0")," %"),char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.355
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
   SET rptsd->m_height = 0.355
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__consult_total_comp)
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.355
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
   DECLARE sectionheight = f8 WITH noconstant(0.361866), private
   DECLARE __consult_total_orders = vc WITH noconstant(build(consult->total_orders,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.132)
   SET rptsd->m_width = 1.712
   SET rptsd->m_height = 0.355
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
   SET rptsd->m_height = 0.355
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__consult_total_orders)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.355
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
   DECLARE sectionheight = f8 WITH noconstant(1.520000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (((( $OUTPUT_TYPE="SUMMARY")) OR (( $OUTPUT_TYPE="DETSUM"))) ))
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
   SET rptreport->m_reportname = "BHS_RPT_CONSULT_ORDERS_LO"
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
   SET rptfont->m_pointsize = 20
   SET _times200 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
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
