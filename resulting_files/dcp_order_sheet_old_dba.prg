CREATE PROGRAM dcp_order_sheet_old:dba
 RECORD request(
   1 person_id = f8
   1 encntr_id = f8
   1 conversation_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
   1 printer_name = c50
 )
 SET count1 = size(request->order_qual,5)
 RECORD body_record(
   1 body[count1]
     2 break_ind = c1
     2 order_type = c1
     2 order_name = c50
     2 details = c110
     2 detail2_ind = c1
     2 details2 = c110
     2 detail3_ind = c1
     2 details3 = c32
     2 comments1_ind = c1
     2 comment_cnt = i2
     2 com_qual[*]
       3 comments1 = c90
 )
 SET target_id = 0.0
 SET mrn_alias_cd = 0.0
 SET admit_doc_cd = 0.0
 SET finnbr_cd = 0.0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET line = fillstring(100,"_")
 SET eod_flag = 0
 SET page_num = 0
 SET x = 1
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET row_cnt = 6
 SET page_cnt = 1
 SET defaults_filled = "F"
 SET b_person_id = 0
 SET b_encntr_id = 0
 SET b_order_provider_id = 0
 SET b_order_locn_cd = 0
 SET b_action_personnel_id = 0
 SET b_tmp_comment = fillstring(90," ")
 SET b_action_dt_tm = cnvtdatetime(curdate,curtime)
 SET b_linefeed = concat(char(10))
 SET b_cc = 0
 SET b_s = 1
 SET b_len = 0
 SET b_e = 0
 FOR (x = 1 TO size(request->order_qual,5))
  SELECT INTO "NL:"
   o.order_mnemonic, o.order_detail_display_line, oa.action_type_cd
   FROM orders o,
    order_action oa
   PLAN (o
    WHERE (o.order_id=request->order_qual[x].order_id))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND (oa.order_conversation_id=request->conversation_id))
   HEAD REPORT
    IF (defaults_filled="F")
     defaults_filled = "T", b_person_id = o.person_id, b_encntr_id = o.encntr_id,
     b_order_provider_id = oa.order_provider_id, b_order_locn_cd = oa.order_locn_cd,
     b_action_personnel_id = oa.action_personnel_id,
     b_action_dt_tm = datetimezone(oa.action_dt_tm,oa.action_tz)
    ENDIF
    row_cnt = (row_cnt+ 2), body_record->body[x].order_type = substring(1,1,uar_get_code_display(oa
      .action_type_cd)), body_record->body[x].order_name = substring(1,50,o.order_mnemonic),
    row_cnt = (row_cnt+ 1), body_record->body[x].details = substring(1,110,o
     .order_detail_display_line), body_record->body[x].details2 = substring(111,110,o
     .order_detail_display_line)
    IF ((body_record->body[x].details2 > " "))
     body_record->body[x].detail2_ind = "T", row_cnt = (row_cnt+ 1), body_record->body[x].details3 =
     substring(211,30,o.order_detail_display_line)
     IF ((body_record->body[x].details3 > " "))
      body_record->body[x].detail3_ind = "T", row_cnt = (row_cnt+ 1)
     ENDIF
    ENDIF
    body_record->body[x].comment_cnt = 0
    IF (o.order_comment_ind=1)
     body_record->body[x].comments1_ind = "T"
    ELSE
     body_record->body[x].comments1_ind = "F"
    ENDIF
    IF (row_cnt > 57)
     body_record->body[x].break_ind = "T", row_cnt = 6, page_cnt = (page_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
  IF ((body_record->body[x].comments1_ind="T"))
   SELECT INTO "nl:"
    lt.long_text
    FROM long_text lt,
     order_comment oc
    PLAN (oc
     WHERE (oc.order_id=request->order_qual[x].order_id))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    DETAIL
     b_cc = 1, body_record->body[x].comment_cnt = 0, b_s = 1
     WHILE (b_cc)
       b_tmp_comment = substring(b_s,90,lt.long_text), b_e = findstring(b_linefeed,b_tmp_comment,1)
       IF (b_e)
        body_record->body[x].comment_cnt = (body_record->body[x].comment_cnt+ 1), tmp_var =
        body_record->body[x].comment_cnt, stat = alterlist(body_record->body[x].com_qual,tmp_var),
        body_record->body[x].com_qual[tmp_var].comments1 = substring(1,b_e,b_tmp_comment), b_s = (b_s
        + b_e), row_cnt = (row_cnt+ 1)
       ELSE
        IF (b_tmp_comment > " ")
         body_record->body[x].comment_cnt = (body_record->body[x].comment_cnt+ 1), tmp_var =
         body_record->body[x].comment_cnt, stat = alterlist(body_record->body[x].com_qual,tmp_var),
         body_record->body[x].com_qual[tmp_var].comments1 = b_tmp_comment, b_s = (b_s+ 90), row_cnt
          = (row_cnt+ 1)
        ELSE
         b_cc = 0
        ENDIF
       ENDIF
     ENDWHILE
     IF (row_cnt > 58)
      body_record->body[x].break_ind = "T", row_cnt = 6, page_cnt = (page_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#start_script
 SET print_person = fillstring(50," ")
 IF ((request->print_prsnl_id > 0))
  SET target_id = request->print_prsnl_id
  SELECT INTO "nl:"
   pl.name_full_formatted
   FROM prsnl pl
   WHERE pl.person_id=target_id
   DETAIL
    print_person = substring(1,50,pl.name_full_formatted)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO request->printer_name
  p.name_full_formatted, p.birth_dt_tm, p.beg_effective_dt_tm,
  pl.name_full_formatted, pl2.name_full_formatted, pl3.name_full_formatted,
  e.reg_dt_tm, e.disch_dt_tm, ea.alias,
  pa.alias
  FROM person p,
   (dummyt d1  WITH seq = 1),
   dummyt d2,
   dummyt d4,
   dummyt d5,
   dummyt d10,
   dummyt d11,
   dummyt d13,
   encounter e,
   encntr_prsnl_reltn epr,
   prsnl pl,
   prsnl pl2,
   prsnl pl3,
   encntr_alias ea,
   person_alias pa
  PLAN (p
   WHERE p.person_id=b_person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d13)
   JOIN (pl2
   WHERE pl2.person_id=b_order_provider_id)
   JOIN (d10)
   JOIN (e
   WHERE e.encntr_id=b_encntr_id)
   JOIN (d11)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd
    AND ea.active_ind=1)
   JOIN (d4)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=admit_doc_cd)
   JOIN (d5)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
   JOIN (d2)
   JOIN (pl3
   WHERE pl3.person_id=b_action_personnel_id)
  HEAD REPORT
   age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"MM/DD/YYYY;;D"),"MM/DD/YYYY"),cnvtint(format(p
      .birth_dt_tm,"HHMM;;M"))), sex = substring(1,1,uar_get_code_display(p.sex_cd)), room =
   substring(1,5,uar_get_code_display(e.loc_room_cd)),
   med_rec_num = substring(1,20,pa.alias), admit_dr = substring(1,24,pl.name_full_formatted),
   order_dr = substring(1,24,pl2.name_full_formatted),
   patientname = substring(1,20,p.name_full_formatted), pat_type = substring(1,1,uar_get_code_display
    (e.encntr_type_cd)), financial_num = substring(1,20,ea.alias),
   bed = substring(1,8,uar_get_code_display(e.loc_bed_cd)), location = substring(1,8,
    uar_get_code_display(e.location_cd)), orders_entered = substring(1,50,pl3.name_full_formatted)
  HEAD PAGE
   row + 1, col 0, "{font/13}",
   row + 1, col 0, "{CPI/5}{B}",
   col 65, "ORDER SHEET", "{CPI/11}{ENDB}",
   row + 1, col 0, line,
   row + 2, col 2, "Order Entry D/T:  ",
   b_action_dt_tm"MM/DD/YY  HH:MM;;Q", col 84, "Orders Entered By:   ",
   orders_entered, row + 1, col 109,
   "Ordering MD:   ", order_dr, row + 1,
   col 0, line
  HEAD p.name_full_formatted
   FOR (x = 1 TO size(body_record->body,5))
     IF ((body_record->body[x].break_ind="T"))
      BREAK
     ENDIF
     row + 2, col 1, "{CPI/10}",
     "{B}", body_record->body[x].order_type, col + 0,
     "{ENDB}", col + 3, "{B}",
     body_record->body[x].order_name, col + 0, "{cpi/11}{endb}",
     row + 1, col 10, body_record->body[x].details
     IF ((body_record->body[x].detail2_ind="T"))
      row + 1, col 13, body_record->body[x].details2
      IF ((body_record->body[x].detail3_ind="T"))
       row + 1, col 13, body_record->body[x].details3
      ENDIF
     ENDIF
     IF ((body_record->body[x].comment_cnt > 0))
      FOR (w = 1 TO body_record->body[x].comment_cnt)
       row + 1,
       IF (w=1)
        col 10, "Order comments: ", body_record->body[x].com_qual[w].comments1
       ELSE
        col 36, body_record->body[x].com_qual[w].comments1
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  FOOT PAGE
   page_num = (page_num+ 1), xcol = 0,
   CALL print(calcpos(xcol,ycol)),
   line, row + 2, xcol = 18,
   CALL print(calcpos(xcol,ycol)), "Pt. Name:   {B}", patientname,
   "{endb}", xcol = 390,
   CALL print(calcpos(xcol,ycol)),
   "{font/10} {b} Baystate Health System", "{endb} {font/13}", row + 1,
   xcol = 9,
   CALL print(calcpos(xcol,ycol)), "{endb}D.O.B./Sex:   ",
   p.birth_dt_tm, "     ", sex,
   xcol = 390,
   CALL print(calcpos(xcol,ycol)), "{b}",
   "Baystate Medical Center", "{endb}", row + 1,
   xcol = 9,
   CALL print(calcpos(xcol,ycol)), "Med Rec #:   ",
   "{B}", med_rec_num, "{endb}",
   xcol = 255,
   CALL print(calcpos(xcol,ycol)), "{b}",
   "Order Sheet", "{endb}", xcol = 390,
   CALL print(calcpos(xcol,ycol)), "759 Chestnut Street, Springfield, MA 01197", "{endb}",
   row + 1, xcol = 18,
   CALL print(calcpos(xcol,ycol)),
   "Admitting MD:   ", admit_dr, xcol = 390,
   CALL print(calcpos(xcol,ycol)), "Print ID:  "
   IF (print_person > " ")
    print_person
   ELSE
    orders_entered
   ENDIF
   row + 1, xcol = 12,
   CALL print(calcpos(xcol,ycol)),
   "Account #:   ", financial_num, xcol = 390,
   CALL print(calcpos(xcol,ycol)), "Print Date/Time:   ", curdate,
   "  ", curtime, row + 1,
   xcol = 22,
   CALL print(calcpos(xcol,ycol)), "Pt. Type:   ",
   pat_type, row + 1, xcol = 14,
   CALL print(calcpos(xcol,ycol)), "Room/Bed:   ", "{b}",
   room, "/", bed,
   "{endb}", row + 1, xcol = 4,
   CALL print(calcpos(xcol,ycol)), "Admit/Disch:   "
   IF (e.disch_dt_tm=null)
    e.reg_dt_tm, " - 00/00/00"
   ELSE
    e.reg_dt_tm, " - ", e.disch_dt_tm
   ENDIF
   xcol = 255,
   CALL print(calcpos(xcol,ycol)), "Page ",
   page_num"#", " of ", page_cnt"#"
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 750
 ;end select
#exit_script
END GO
