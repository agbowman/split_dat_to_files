CREATE PROGRAM bhs_rpt_pmr_note_orders:dba
 PROMPT
  "send message to screen" = "MINE",
  "Select Facility" = value(673936.00),
  "Order Date From" = "SYSDATE",
  "Order date to" = "SYSDATE",
  "Order Status" = value(2543.000000,2550.000000),
  "Show Summary Only" = 0,
  "Send file to file share" = 0,
  "Run Previous Month" = 0,
  "Output to File/Printer/MINE" = "MINE"
  WITH printmessagetoscreen, facility, order_date_from,
  ord_date_to, order_statuses, summary,
  ftpfiles, run_prevous_month, outdev
 EXECUTE bhs_check_domain
 DECLARE md_start_date = dq8 WITH protect
 DECLARE md_end_date = dq8 WITH protect
 DECLARE ms_year = vc WITH protect
 DECLARE ms_day = i4 WITH protect
 DECLARE ms_name_fac = vc WITH protect
 DECLARE ms_month = i4 WITH protect
 DECLARE d_prt = i4 WITH protect
 DECLARE ms_time = vc WITH protect
 DECLARE ms_var_outpmr = vc WITH protect
 DECLARE ms_fileprefix = vc WITH protect
 DECLARE mf_per_ontime = vc WITH protect
 DECLARE mf_per_disch = vc WITH protect
 DECLARE mf_per_notdue = vc WITH protect
 DECLARE mf_per_notdone = vc WITH protect
 DECLARE mf_per_inprogress = vc WITH protect
 DECLARE mf_completed = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")), protect
 DECLARE md_note_due_date = dq8 WITH noconstant(0), protect
 DECLARE mf_inprogress = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"INPROGRESS")), protect
 DECLARE mf_authverified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_discontinued = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED")),
 protect
 DECLARE mf_voidedwithresults = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,
   "VOIDEDWITHRESULTS")), protect
 DECLARE mf_deleted = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE mf_canceled = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED")), protect
 DECLARE mf_consultrehabmed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTREHABILITATIONMEDICINE")), protect
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE mf_page_size = f8 WITH noconstant(0), protect
 DECLARE mf_remain_space = f8 WITH noconstant(0), protect
 DECLARE micnt_note = i4 WITH noconstant(0), protect
 DECLARE mi_found = i4 WITH noconstant(0), protect
 DECLARE micnt_order = i4 WITH noconstant(0), protect
 DECLARE mf_signed = f8 WITH constant(uar_get_code_by("MEANING",15750,"SIGNED")), protect
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15750,"ACTIVE")), protect
 DECLARE ms_name_id = vc WITH noconstant(" "), protect
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 RECORD pmr_note(
   1 total_done_24hrs = i4
   1 print_requested_by = vc
   1 date_range = vc
   1 total_orders = i4
   1 total_over_24 = i4
   1 on_time = i4
   1 discharge_before = i4
   1 inprogress = i4
   1 not_done = i4
   1 not_due = i4
   1 pmr_order[*]
     2 encntr_id = f8
     2 order_id = f8
     2 order_status = vc
     2 story_id = f8
     2 author_id = f8
     2 update_id = f8
     2 author_name = vc
     2 ce_result_status_cd = f8
     2 ce_result_status_txt = vc
     2 note_status_cd = f8
     2 note_status_vc = vc
     2 note_status_txt = vc
     2 note_cnt = i4
     2 ce1_status = vc
     2 fin = vc
     2 signed_dt_tm = dq8
     2 order_dtttm = dq8
     2 order_status_dt_tm = dq8
     2 due_date = dq8
     2 pat_los = f8
     2 pat_reg_dttm = dq8
     2 pat_disch_dttm = dq8
     2 time_to_sign = f8
     2 status = vc
 )
 IF (datetimediff(cnvtdatetime( $ORD_DATE_TO),cnvtdatetime( $ORDER_DATE_FROM)) > 60.0)
  SET ms_var_outpmr =  $PRINTMESSAGETOSCREEN
  SET out_of_range = 1
  SELECT INTO  $PRINTMESSAGETOSCREEN
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Greater than Sixty days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $ORD_DATE_TO),cnvtdatetime( $ORDER_DATE_FROM)) < 0.0)
  SET out_of_range = 1
  SELECT INTO  $PRINTMESSAGETOSCREEN
   FROM dummyt
   HEAD REPORT
    msg1 = "Your Start date is greater the End date.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ENDIF
 SET md_start_date = cnvtdatetime( $ORDER_DATE_FROM)
 SET md_end_date = cnvtdatetime( $ORD_DATE_TO)
 IF (( $RUN_PREVOUS_MONTH=1))
  SET md_start_date = cnvtdatetime(format(datetimefind(cnvtlookbehind("1M",cnvtdatetime(curdate,0)),
     "M","B","B"),";;Q"))
  SET md_end_date = cnvtdatetime(format(datetimefind(cnvtlookbehind("1M",cnvtdatetime(curdate,0)),"M",
     "E","E"),";;Q"))
 ENDIF
 SET pmr_note->date_range = concat(format(cnvtdatetime(md_start_date),"mm/dd/yy;3;D"),"...",format(
   cnvtdatetime(md_end_date),"mm/dd/yy;3;D"))
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  ORDER BY p.person_id
  HEAD p.person_id
   pmr_note->print_requested_by = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
  FOOT  p.person_id
   null
  WITH nocounter
 ;end select
 IF (( $FTPFILES=1))
  SET emailind = 1
  SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
  SET ms_day = day(curdate)
  SET ms_name_fac = cnvtlower(substring(1,6,replace(trim(uar_get_code_display(cnvtreal( $FACILITY))),
     " ","_",0)))
  SET ms_month = month(curdate)
  SET ms_time = format(curtime,"HHMM;;M")
  IF (( $SUMMARY=1))
   SET ms_fileprefix = "pmr_sum"
  ELSE
   SET ms_fileprefix = "pmr_det"
  ENDIF
  SET ms_var_outpmr = build(logical("bhscust"),"/ftp/bhs_rpt_pmr_note_orders/",ms_name_fac,
   ms_fileprefix,"_",
   ms_month,"_",ms_day,"_",ms_time,
   "_",ms_year,".pdf")
  IF (( $RUN_PREVOUS_MONTH=1))
   SET ms_var_outpmr = build(logical("bhscust"),"/ftp/bhs_rpt_pmr_note_orders/",cnvtlower(format(
      cnvtdatetime(md_start_date),"MMM;;D")),"_",format(cnvtdatetime(md_start_date),"YY;;D"),
    "_",ms_var_outpmr)
  ENDIF
 ELSE
  IF (( $OUTDEV="MINE"))
   SET ms_var_outpmr =  $PRINTMESSAGETOSCREEN
  ELSE
   CALL echo(build("Report sent to printer ", $OUTDEV))
   SET ms_var_outpmr =  $OUTDEV
   SELECT INTO  $PRINTMESSAGETOSCREEN
    FROM dummyt
    HEAD REPORT
     msg1 = concat("Report sent to printer ", $OUTDEV), col 0, y_pos = 18,
     row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))),
     msg1, row + 1
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ms_name_id = trim(build(p.name_last,p.name_first,p.person_id),3), o.encntr_id, o.orig_order_dt_tm,
  ce.authentic_flag, ce.event_end_dt_tm
  FROM orders o,
   encounter e,
   scd_story ss,
   clinical_event ce,
   encntr_alias ea,
   person p,
   prsnl pr
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(md_start_date) AND cnvtdatetime(md_end_date)
    AND o.catalog_cd=mf_consultrehabmed
    AND o.person_id > 0
    AND (o.order_status_cd= $ORDER_STATUSES))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND (e.loc_facility_cd= $FACILITY))
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_finnbr)
   JOIN (ss
   WHERE (ss.encounter_id= Outerjoin(o.encntr_id))
    AND (ss.active_status_dt_tm>= Outerjoin(o.orig_order_dt_tm))
    AND (cnvtupper(ss.title)= Outerjoin("PM*")) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(ss.author_id)) )
   JOIN (ce
   WHERE (ce.event_id= Outerjoin(ss.event_id)) )
  ORDER BY ms_name_id, o.encntr_id, o.order_id,
   ce.event_end_dt_tm
  HEAD REPORT
   stat = alterlist(pmr_note->pmr_order,10), mi_found = 0, mi_found = 0
  HEAD o.order_id
   micnt_order += 1
   IF (mod(micnt_order,10)=1)
    stat = alterlist(pmr_note->pmr_order,(micnt_order+ 9))
   ENDIF
   pmr_note->pmr_order[micnt_order].fin = ea.alias, pmr_note->pmr_order[micnt_order].order_id = o
   .order_id, pmr_note->pmr_order[micnt_order].order_status = trim(uar_get_code_display(o
     .order_status_cd),3),
   pmr_note->pmr_order[micnt_order].order_dtttm = o.orig_order_dt_tm
   IF (o.orig_order_dt_tm < cnvtdatetime(cnvtdate(o.orig_order_dt_tm),160000))
    pmr_note->pmr_order[micnt_order].due_date = cnvtdatetime((cnvtdate(o.orig_order_dt_tm)+ 1),000000
     )
   ELSE
    pmr_note->pmr_order[micnt_order].due_date = cnvtdatetime((cnvtdate(o.orig_order_dt_tm)+ 2),000000
     )
   ENDIF
   pmr_note->pmr_order[micnt_order].pat_disch_dttm = e.disch_dt_tm, pmr_note->pmr_order[micnt_order].
   pat_reg_dttm = e.reg_dt_tm, pmr_note->pmr_order[micnt_order].note_status_txt = "Not Started",
   pmr_note->pmr_order[micnt_order].time_to_sign = datetimediff(cnvtdatetime(curdate,curtime),o
    .orig_order_dt_tm,3)
   IF (e.disch_dt_tm != null)
    pmr_note->pmr_order[micnt_order].time_to_sign = datetimediff(e.disch_dt_tm,o.orig_order_dt_tm,3)
   ENDIF
  DETAIL
   IF (((cnvtupper(trim(ss.title,3))="PM&R*") OR (cnvtupper(trim(ss.title,3))="PMR*")) )
    micnt_note += 1, pmr_note->pmr_order[micnt_order].note_cnt = micnt_note
    IF (((micnt_note=1) OR (mi_found=0)) )
     pmr_note->pmr_order[micnt_order].story_id = ss.scd_story_id, pmr_note->pmr_order[micnt_order].
     author_name = pr.name_full_formatted, pmr_note->pmr_order[micnt_order].note_status_cd = ss
     .story_completion_status_cd,
     pmr_note->pmr_order[micnt_order].note_status_vc = uar_get_code_display(ss
      .story_completion_status_cd), pmr_note->pmr_order[micnt_order].ce1_status =
     uar_get_code_display(ce.result_status_cd)
     IF (ce.result_status_cd=mf_authverified)
      pmr_note->pmr_order[micnt_order].note_status_txt = trim(uar_get_code_display(ss
        .story_completion_status_cd),3), pmr_note->pmr_order[micnt_order].time_to_sign = datetimediff
      (ce.event_end_dt_tm,o.orig_order_dt_tm,3), pmr_note->pmr_order[micnt_order].note_status_txt =
      "Signed",
      mi_found = 1
     ELSEIF (ce.result_status_cd=mf_inprogress)
      pmr_note->pmr_order[micnt_order].note_status_txt = trim(uar_get_code_display(ce
        .result_status_cd),3)
      IF ((pmr_note->pmr_order[micnt_order].pat_disch_dttm != 0))
       pmr_note->pmr_order[micnt_order].time_to_sign = datetimediff(e.disch_dt_tm,o.orig_order_dt_tm,
        3)
      ELSE
       pmr_note->pmr_order[micnt_order].time_to_sign = datetimediff(cnvtdatetime(curdate,curtime),o
        .orig_order_dt_tm,3)
      ENDIF
      pmr_note->pmr_order[micnt_order].note_status_txt = "In Progress"
     ENDIF
     pmr_note->pmr_order[micnt_order].signed_dt_tm = ce.event_end_dt_tm
    ENDIF
   ENDIF
  FOOT  o.order_id
   IF (cnvtdatetime(pmr_note->pmr_order[micnt_order].due_date) > cnvtdatetime(pmr_note->pmr_order[
    micnt_order].signed_dt_tm)
    AND (pmr_note->pmr_order[micnt_order].signed_dt_tm != 0))
    pmr_note->on_time += 1, pmr_note->pmr_order[micnt_order].status = "Done"
   ELSEIF ((pmr_note->pmr_order[micnt_order].pat_disch_dttm != 0)
    AND cnvtdatetime(pmr_note->pmr_order[micnt_order].pat_disch_dttm) < cnvtdatetime(pmr_note->
    pmr_order[micnt_order].due_date))
    pmr_note->discharge_before += 1, pmr_note->pmr_order[micnt_order].status = "Discharged"
   ELSEIF (cnvtdatetime(curdate,curtime) < cnvtdatetime(pmr_note->pmr_order[micnt_order].due_date))
    pmr_note->not_due += 1, pmr_note->pmr_order[micnt_order].status = "Not Due"
   ELSEIF (((trim(pmr_note->pmr_order[micnt_order].note_status_txt,3)=trim("In Progress",3)) OR (trim
   (pmr_note->pmr_order[micnt_order].note_status_txt,3)=trim("Signed",3))) )
    pmr_note->inprogress += 1, pmr_note->pmr_order[micnt_order].status = "Late"
   ELSE
    pmr_note->not_done += 1, pmr_note->pmr_order[micnt_order].status = "Not Started"
   ENDIF
   micnt_note = 0, mi_found = 0
   IF ((pmr_note->pmr_order[micnt_order].time_to_sign > 24))
    pmr_note->total_over_24 += 1
   ENDIF
  FOOT REPORT
   pmr_note->total_orders = micnt_order, stat = alterlist(pmr_note->pmr_order,micnt_order),
   micnt_order = 0
  WITH nocounter
 ;end select
 CALL echorecord(pmr_note)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
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
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remtime_to_sign_pmr = i4 WITH noconstant(1), protect
 DECLARE _remorder_dt_tm = i4 WITH noconstant(1), protect
 DECLARE _remnote_status_cd = i4 WITH noconstant(1), protect
 DECLARE _remaccountnum = i4 WITH noconstant(1), protect
 DECLARE _remauthor = i4 WITH noconstant(1), protect
 DECLARE _remsign_date = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpmr_detail = i2 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
 SUBROUTINE (report_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = report_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (report_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   DECLARE __print_requestor = vc WITH noconstant(build2(pmr_note->print_requested_by,char(0))),
   protect
   DECLARE __date_range = vc WITH noconstant(build2(pmr_note->date_range,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PM&R Report",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reqested By:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.167
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__print_requestor)
    SET rptsd->m_y = (offsety+ 0.573)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_range)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.573)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 0.781
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Range:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.797),(offsetx+ 7.500),(offsety+
     0.797))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pmr_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pmr_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pmr_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Time",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct#",char(0)))
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.188)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Author",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("On time Status",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Signed",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 0.656
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Note Status",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.240),(offsetx+ 7.500),(offsety+
     0.240))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Discharge Date",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pmr_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pmr_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pmr_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8 WITH
  protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_time_to_sign_pmr = f8 WITH noconstant(0.0), private
   DECLARE drawheight_order_dt_tm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_note_status_cd = f8 WITH noconstant(0.0), private
   DECLARE drawheight_accountnum = f8 WITH noconstant(0.0), private
   DECLARE drawheight_author = f8 WITH noconstant(0.0), private
   DECLARE drawheight_sign_date = f8 WITH noconstant(0.0), private
   DECLARE __time_to_sign_pmr = vc WITH noconstant(build2(pmr_note->pmr_order[d_prt].status,char(0))),
   protect
   DECLARE __order_dt_tm = vc WITH noconstant(build2(format(pmr_note->pmr_order[d_prt].order_dtttm,
      "mm/dd/yy hh:mm;3;Q"),char(0))), protect
   DECLARE __note_status_cd = vc WITH noconstant(build2(pmr_note->pmr_order[d_prt].note_status_txt,
     char(0))), protect
   DECLARE __accountnum = vc WITH noconstant(build2(pmr_note->pmr_order[d_prt].fin,char(0))), protect
   DECLARE __author = vc WITH noconstant(build2(pmr_note->pmr_order[d_prt].author_name,char(0))),
   protect
   DECLARE __sign_date = vc WITH noconstant(build2(format(pmr_note->pmr_order[d_prt].signed_dt_tm,
      "mm/dd/yy hh:mm;3;Q"),char(0))), protect
   DECLARE __order_stat = vc WITH noconstant(build2(pmr_note->pmr_order[d_prt].order_status,char(0))),
   protect
   DECLARE __disch_date = vc WITH noconstant(build2(pmr_note->pmr_order[d_prt].pat_disch_dttm,char(0)
     )), protect
   IF (bcontinue=0)
    SET _remtime_to_sign_pmr = 1
    SET _remorder_dt_tm = 1
    SET _remnote_status_cd = 1
    SET _remaccountnum = 1
    SET _remauthor = 1
    SET _remsign_date = 1
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
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtime_to_sign_pmr = _remtime_to_sign_pmr
   IF (_remtime_to_sign_pmr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtime_to_sign_pmr,((
       size(__time_to_sign_pmr) - _remtime_to_sign_pmr)+ 1),__time_to_sign_pmr)))
    SET drawheight_time_to_sign_pmr = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtime_to_sign_pmr = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtime_to_sign_pmr,((size(
        __time_to_sign_pmr) - _remtime_to_sign_pmr)+ 1),__time_to_sign_pmr)))))
     SET _remtime_to_sign_pmr += rptsd->m_drawlength
    ELSE
     SET _remtime_to_sign_pmr = 0
    ENDIF
    SET growsum += _remtime_to_sign_pmr
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
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
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremnote_status_cd = _remnote_status_cd
   IF (_remnote_status_cd > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remnote_status_cd,((size(
        __note_status_cd) - _remnote_status_cd)+ 1),__note_status_cd)))
    SET drawheight_note_status_cd = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remnote_status_cd = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remnote_status_cd,((size(__note_status_cd
        ) - _remnote_status_cd)+ 1),__note_status_cd)))))
     SET _remnote_status_cd += rptsd->m_drawlength
    ELSE
     SET _remnote_status_cd = 0
    ENDIF
    SET growsum += _remnote_status_cd
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.635
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
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremauthor = _remauthor
   IF (_remauthor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remauthor,((size(__author
        ) - _remauthor)+ 1),__author)))
    SET drawheight_author = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remauthor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remauthor,((size(__author) - _remauthor)
       + 1),__author)))))
     SET _remauthor += rptsd->m_drawlength
    ELSE
     SET _remauthor = 0
    ENDIF
    SET growsum += _remauthor
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.740
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremsign_date = _remsign_date
   IF (_remsign_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsign_date,((size(
        __sign_date) - _remsign_date)+ 1),__sign_date)))
    SET drawheight_sign_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsign_date = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsign_date,((size(__sign_date) -
       _remsign_date)+ 1),__sign_date)))))
     SET _remsign_date += rptsd->m_drawlength
    ELSE
     SET _remsign_date = 0
    ENDIF
    SET growsum += _remsign_date
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = drawheight_time_to_sign_pmr
   IF (ncalc=rpt_render
    AND _holdremtime_to_sign_pmr > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtime_to_sign_pmr,(
       (size(__time_to_sign_pmr) - _holdremtime_to_sign_pmr)+ 1),__time_to_sign_pmr)))
   ELSE
    SET _remtime_to_sign_pmr = _holdremtime_to_sign_pmr
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = drawheight_order_dt_tm
   IF (ncalc=rpt_render
    AND _holdremorder_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_dt_tm,((size
       (__order_dt_tm) - _holdremorder_dt_tm)+ 1),__order_dt_tm)))
   ELSE
    SET _remorder_dt_tm = _holdremorder_dt_tm
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_note_status_cd
   IF (ncalc=rpt_render
    AND _holdremnote_status_cd > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremnote_status_cd,((
       size(__note_status_cd) - _holdremnote_status_cd)+ 1),__note_status_cd)))
   ELSE
    SET _remnote_status_cd = _holdremnote_status_cd
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.635
   SET rptsd->m_height = drawheight_accountnum
   IF (ncalc=rpt_render
    AND _holdremaccountnum > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremaccountnum,((size(
        __accountnum) - _holdremaccountnum)+ 1),__accountnum)))
   ELSE
    SET _remaccountnum = _holdremaccountnum
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = drawheight_author
   IF (ncalc=rpt_render
    AND _holdremauthor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremauthor,((size(
        __author) - _holdremauthor)+ 1),__author)))
   ELSE
    SET _remauthor = _holdremauthor
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.740
   SET rptsd->m_height = drawheight_sign_date
   IF (ncalc=rpt_render
    AND _holdremsign_date > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsign_date,((size(
        __sign_date) - _holdremsign_date)+ 1),__sign_date)))
   ELSE
    SET _remsign_date = _holdremsign_date
   ENDIF
   SET rptsd->m_flags = 12
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_stat)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.688)
   SET rptsd->m_width = 0.677
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__disch_date)
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
 SUBROUTINE (pmr_foot(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pmr_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pmr_footabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 1.583
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Page:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.083),(offsetx+ 7.500),(offsety+
     0.083))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pmr_summary(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pmr_summaryabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.364583), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.358
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Status",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.358
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Amount",char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.358
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Percent of Total Orders",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
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
   DECLARE sectionheight = f8 WITH noconstant(0.364583), private
   DECLARE __on_time = vc WITH noconstant(build(pmr_note->on_time,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.358
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Signed onTime",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.358
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__on_time)
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.358
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(mf_per_ontime,char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
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
   DECLARE sectionheight = f8 WITH noconstant(0.364582), private
   DECLARE __before_disch = vc WITH noconstant(build(pmr_note->discharge_before,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.358
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Discharged before Note Due",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.358
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__before_disch)
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.358
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(mf_per_disch,char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow3(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.343750), private
   DECLARE __not_due = vc WITH noconstant(build(pmr_note->not_due,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.337
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Not Due",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.337
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__not_due)
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.337
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(mf_per_notdue,char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow4(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.354167), private
   DECLARE __inprogress = vc WITH noconstant(build(pmr_note->inprogress,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.347
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Late",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.347
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__inprogress)
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.347
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(mf_per_inprogress,char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
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
   DECLARE sectionheight = f8 WITH noconstant(0.354168), private
   DECLARE __not_done = vc WITH noconstant(build(pmr_note->not_done,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.347
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Not Done",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.347
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__not_done)
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.347
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(mf_per_notdone,char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
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
   DECLARE sectionheight = f8 WITH noconstant(0.354167), private
   DECLARE __total_orders = vc WITH noconstant(build(pmr_note->total_orders,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.194)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.347
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Total Orders",char(0)))
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.851)
   SET rptsd->m_width = 1.649
   SET rptsd->m_height = 0.347
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__total_orders)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.507)
   SET rptsd->m_width = 1.639
   SET rptsd->m_height = 0.347
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),offsety,(offsetx+ 1.188),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.844),offsety,(offsetx+ 2.844),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.500),offsety,(offsetx+ 4.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.146),offsety,(offsetx+ 6.146),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ 0.000),(offsetx+ 6.146),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.188),(offsety+ sectionheight),(offsetx+ 6.146),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pmr_summaryabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.590000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
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
     SET holdheight += tablerow3(rpt_render)
     SET holdheight += tablerow4(rpt_render)
     SET holdheight += tablerow5(rpt_render)
     SET holdheight += tablerow6(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "BHS_RPT_PMR_NOTE_ORDERS"
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
 SET d0 = initializereport(0)
 SET page_size = 10.40
 SET becont = 0
 SET d0 = report_header(rpt_render)
 IF (( $SUMMARY=0))
  FOR (d_prt = 1 TO size(pmr_note->pmr_order,5))
    IF (d_prt=1)
     SET d0 = pmr_head(rpt_render)
     CALL echo(build("curendreport1 = ",curendreport))
    ENDIF
    SET remain_space = (page_size - _yoffset)
    IF ((((_yoffset+ pmr_detail(rpt_calcheight,remain_space,becont))+ pmr_foot(rpt_calcheight)) >
    page_size))
     SET _yoffset = page_size
     SET d0 = pmr_foot(rpt_render)
     SET d0 = pagebreak(0)
     SET d0 = pmr_head(rpt_render)
     SET continued = "(continued)"
     SET continued = ""
     CALL echo(build("curendreport2 = ",curendreport))
     CALL echo(build("curpage = ",curpage))
    ENDIF
    WHILE (becont=1)
      SET _yoffset = page_size
      SET d0 = pmr_foot(rpt_render)
      SET d0 = pagebreak(0)
      SET continued = "(continued)"
      SET d0 = pmr_head(rpt_render)
      SET continued = ""
      SET remain_space = (page_size - _yoffset)
      SET becont = 0
      CALL echo("while loop")
      CALL echo(build("curpage = ",curpage))
    ENDWHILE
    SET remain_space = (page_size - _yoffset)
    SET d0 = pmr_detail(rpt_render,remain_space,becont)
  ENDFOR
  IF ((((_yoffset+ pmr_foot(rpt_calcheight))+ pmr_summary(rpt_calcheight)) > page_size))
   SET _yoffset = page_size
   SET d0 = pmr_foot(rpt_render)
   SET d0 = pagebreak(0)
   SET d0 = pmr_head(rpt_render)
   SET continued = "(continued)"
  ENDIF
 ENDIF
 IF (( $SUMMARY=0))
  SET _yoffset = (page_size - pmr_summary(rpt_calcheight))
 ENDIF
 IF (curendreport=1)
  SET mf_per_ontime = format(round(((cnvtreal(pmr_note->on_time)/ cnvtreal(pmr_note->total_orders))
     * 100),2),"##.##;p0")
  SET mf_per_disch = format(round(((cnvtreal(pmr_note->discharge_before)/ cnvtreal(pmr_note->
     total_orders)) * 100),2),"##.##;p0")
  SET mf_per_notdue = format(round(((cnvtreal(pmr_note->not_due)/ cnvtreal(pmr_note->total_orders))
     * 100),2),"##.##;p0")
  SET mf_per_inprogress = format(round(((cnvtreal(pmr_note->inprogress)/ cnvtreal(pmr_note->
     total_orders)) * 100),2),"##.##;p0")
  SET mf_per_notdone = format(round(((cnvtreal(pmr_note->not_done)/ cnvtreal(pmr_note->total_orders))
     * 100),2),"##.##;p0")
  SET d0 = pmr_summary(rpt_render)
 ENDIF
 SET d0 = pmr_foot(rpt_render)
 CALL echo(build("ms_var_outpmr(finalize)  = ",ms_var_outpmr))
 SET d0 = finalizereport(ms_var_outpmr)
 CALL echo(build("$ftpfiles = ", $FTPFILES))
 IF (( $FTPFILES=1))
  SELECT INTO  $PRINTMESSAGETOSCREEN
   FROM dummyt
   HEAD REPORT
    msg1 = concat("Files have been send  to share "), col 0, "{PS/792 0}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
 CALL echo(build("ms_var_outpmr =",ms_var_outpmr))
#exit_prg
END GO
