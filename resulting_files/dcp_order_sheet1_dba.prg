CREATE PROGRAM dcp_order_sheet1:dba
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
     2 ord_stat_disp = c40
     2 ord_mnem = c100
     2 details = c255
     2 ord_comment_ind = i1
     2 ord_comment = vc
 )
 DECLARE 333_admitdoc = f8 WITH constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE 319_fin_nbr = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE 4_mrn = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE b_person_id = f8
 DECLARE b_encntr_id = f8
 DECLARE b_order_provider_id = f8
 DECLARE b_order_locn_id = f8
 DECLARE b_action_personnel_id = f8
 DECLARE od_line_len = i2
 DECLARE oc_line_len = i2
 DECLARE doc_max_row = i4
 DECLARE end_msg_len = i4
 DECLARE cntr = i4
 SET cntr = 0
 SET od_line_len = 100
 SET oc_line_len = 100
 SET doc_max_row = 85
 SET end_msg = "  *** Excessive comment length.  View entire comment online. ***"
 SET end_msg_len = size(trim(end_msg,3))
 SET target_id = 0.0
 SET line = fillstring(130,"_")
 SET eod_flag = 0
 SET page_num = 0
 SET x = 1
 SET row_cnt = 6
 SET page_cnt = 1
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
    o.order_mnemonic, o.clinical_display_line, o.order_status_cd,
    o.order_comment_ind, oc.long_text_id, lt.long_text
    FROM orders o,
     order_action oa,
     order_comment oc,
     long_text lt,
     (dummyt d1  WITH seq = 1)
    PLAN (o
     WHERE (o.order_id=request->order_qual[x].order_id)
      AND o.template_order_id=0)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND (oa.order_conversation_id=request->conversation_id))
     JOIN (d1)
     JOIN (oc
     WHERE oa.order_id=oc.order_id
      AND oa.action_sequence=oc.action_sequence)
     JOIN (lt
     WHERE oc.long_text_id=lt.long_text_id)
    DETAIL
     b_person_id = o.person_id, b_encntr_id = o.encntr_id, b_order_provider_id = oa.order_provider_id,
     b_order_locn_cd = oa.order_locn_cd, b_action_personnel_id = oa.action_personnel_id,
     b_action_dt_tm = datetimezone(oa.action_dt_tm,oa.action_tz),
     body_record->body[x].ord_stat_disp = uar_get_code_display(o.order_status_cd), body_record->body[
     x].ord_mnem = o.order_mnemonic, body_record->body[x].details = o.clinical_display_line,
     body_record->body[x].ord_comment_ind = o.order_comment_ind, body_record->body[x].ord_comment =
     trim(lt.long_text,3)
    WITH outerjoin = d1
   ;end select
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
    AND pa.person_alias_type_cd=4_mrn
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
    AND ea.encntr_alias_type_cd=319_fin_nbr
    AND ea.active_ind=1)
   JOIN (d4)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=333_admitdoc)
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
   patientname = substring(1,20,p.name_full_formatted), pat_type = substring(1,10,
    uar_get_code_display(e.encntr_type_cd)), financial_num = substring(1,20,ea.alias),
   bed = substring(1,8,uar_get_code_display(e.loc_bed_cd)), location = substring(1,8,
    uar_get_code_display(e.location_cd)), orders_entered = substring(1,50,pl3.name_full_formatted)
  HEAD PAGE
   row + 2, col 055, "{font/9}{CPI/4}",
   "NEW ORDERS", "{CPI/11}{f/24}", row + 1,
   col 000, line, row + 2,
   col 005, "Order Entry D/T:", "{ht/20}",
   b_action_dt_tm"MM/DD/YY - HH:MM;;Q", col 000, "{ht/50}",
   "Orders Entered By:", "{ht/70}", orders_entered,
   row + 1, col 000, "{ht/50}",
   "Ordering Physician:", "{ht/71}", order_dr,
   row + 1, col 000, line
  HEAD p.name_full_formatted
   FOR (x = 1 TO size(body_record->body,5))
     row + 2, col 001, "{CPI/9}{f/9}",
     CALL print(trim(body_record->body[x].ord_mnem,3)), "{CPI/11}{f/24}", "  -  ",
     CALL print(trim(body_record->body[x].ord_stat_disp,3)), row + 1, col 010,
     "{f/24}{cpi/11}", row + 1, source_str = trim(body_record->body[x].details,3),
     line_len = od_line_len, last_time = 0, curr_line_end = 0,
     last_source_str_brk_pos = 0
     IF (source_str="")
      row + 1
     ELSE
      WHILE (last_time < 1)
        last_source_str_brk_pos = ((curr_line_end+ 1)+ last_source_str_brk_pos), curr_srch_str = trim
        (substring(last_source_str_brk_pos,line_len,source_str),3)
        IF (((line_len+ (last_source_str_brk_pos - 1)) < size(trim(source_str,3),1)))
         IF (cntr=10)
          curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), prnt_line = fillstring(100,
           " "), prnt_line = trim(concat(substring(last_source_str_brk_pos,(curr_line_end -
             end_msg_len),source_str),"{f/27}",end_msg,"{f/24}"),3),
          col 010,
          CALL print(prnt_line), row + 1,
          last_time = 1, cntr = (cntr+ 1)
         ELSE
          curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), prnt_line = fillstring(100,
           " "), prnt_line = trim(substring(last_source_str_brk_pos,curr_line_end,source_str),3),
          col 010,
          CALL print(prnt_line), row + 1,
          last_time = 0, cntr = (cntr+ 1)
         ENDIF
        ELSE
         IF (size(trim(source_str,3),1) > 253)
          curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), prnt_line = fillstring(100,
           " "), prnt_line = trim(substring(last_source_str_brk_pos,curr_line_end,source_str),3),
          col 010,
          CALL print(prnt_line), row + 1,
          col 010, "{f/27}",
          CALL print("*** Not all order details displayed.  Check online for full order details. ***"
          ),
          "{f/24}", row + 1, last_time = 1,
          cntr = (cntr+ 1)
         ELSE
          prnt_line = fillstring(100," "), curr_line_end = size(trim(curr_srch_str,3),1), prnt_line
           = substring(last_source_str_brk_pos,(curr_line_end+ last_source_str_brk_pos),source_str),
          col 010,
          CALL print(prnt_line), row + 1,
          last_time = 1
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     row + 1, source_str = ""
     IF ((body_record->body[x].ord_comment_ind=1))
      col 010, "{cpi/11}{u}", "Order Comment:",
      "{endu}", row + 1, source_str_vc = trim(body_record->body[x].ord_comment,3),
      line_len = oc_line_len, curr_line_end = 0, last_time = 0,
      last_source_str_brk_pos = 0
      IF (source_str_vc="")
       row + 1
      ELSE
       WHILE (last_time < 1)
         last_source_str_brk_pos = ((curr_line_end+ 1)+ last_source_str_brk_pos), curr_srch_str =
         trim(substring(last_source_str_brk_pos,line_len,source_str_vc),3)
         IF (((line_len+ (last_source_str_brk_pos - 1)) < size(trim(source_str_vc,3),1)))
          IF (cntr=20)
           curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), prnt_line = fillstring(
            100," "), prnt_line = trim(concat(substring(last_source_str_brk_pos,(cnvtint(
               curr_line_end) - cnvtint(end_msg_len)),source_str_vc),"{f/27}",end_msg,"{f/24}"),3),
           col 010,
           CALL print(prnt_line), row + 1,
           last_time = 1, cntr = (cntr+ 1)
          ELSE
           curr_line_end = (findstring(" ",trim(curr_srch_str,3),1,1) - 1), prnt_line = fillstring(
            100," "), prnt_line = trim(substring(last_source_str_brk_pos,curr_line_end,source_str_vc),
            3),
           col 010,
           CALL print(prnt_line), row + 1,
           last_time = 0, cntr = (cntr+ 1)
          ENDIF
         ELSE
          prnt_line = fillstring(100," "), curr_line_end = size(trim(curr_srch_str,3),1), prnt_line
           = substring(last_source_str_brk_pos,(curr_line_end+ last_source_str_brk_pos),source_str_vc
           ),
          col 010,
          CALL print(prnt_line), row + 1,
          last_time = 1
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
   ENDFOR
  FOOT PAGE
   page_num = (page_num+ 1), ycol = 640, xcol = 0,
   CALL print(calcpos(xcol,ycol)), line, row + 2,
   ycol = 670, xcol = 18,
   CALL print(calcpos(xcol,ycol)),
   "Pt. Name:   {B}", patientname, "{endb}",
   xcol = 370,
   CALL print(calcpos(xcol,ycol)), "{b}Baystate Health System",
   "{endb}", row + 1, xcol = 18,
   ycol = 680,
   CALL print(calcpos(xcol,ycol)), "{endb}D.O.B./Sex:   ",
   p.birth_dt_tm, "     ", sex,
   xcol = 370,
   CALL print(calcpos(xcol,ycol)), "{b}",
   "Baystate Medical Center", "{endb}", row + 1,
   xcol = 18, ycol = 690,
   CALL print(calcpos(xcol,ycol)),
   "Med Rec #:   ", "{B}", med_rec_num,
   "{endb}", xcol = 255,
   CALL print(calcpos(xcol,ycol)),
   "{b}", "Order Sheet", "{endb}",
   xcol = 370,
   CALL print(calcpos(xcol,ycol)), "759 Chestnut Street, Springfield, MA 01197",
   "{endb}", row + 1, xcol = 18,
   ycol = 700,
   CALL print(calcpos(xcol,ycol)), "Admitting MD:   ",
   admit_dr, xcol = 370,
   CALL print(calcpos(xcol,ycol)),
   "Print ID:  "
   IF (print_person > " ")
    print_person
   ELSE
    orders_entered
   ENDIF
   row + 1, xcol = 18, ycol = 710,
   CALL print(calcpos(xcol,ycol)), "Financial #:   ", financial_num,
   xcol = 370,
   CALL print(calcpos(xcol,ycol)), "Print Date/Time:   ",
   curdate, "  ", curtime,
   row + 1, xcol = 18, ycol = 720,
   CALL print(calcpos(xcol,ycol)), "Pt. Type:   ", pat_type,
   row + 1, xcol = 18, ycol = 730,
   CALL print(calcpos(xcol,ycol)), "Room/Bed:   ", "{b}",
   room, "/", bed,
   "{endb}", row + 1, xcol = 18,
   ycol = 740,
   CALL print(calcpos(xcol,ycol)), "Admit/Disch:   "
   IF (e.disch_dt_tm=null)
    e.reg_dt_tm, " - 00/00/00"
   ELSE
    e.reg_dt_tm, " - ", e.disch_dt_tm
   ENDIF
   xcol = 255,
   CALL print(calcpos(xcol,ycol)), "Page ",
   page_num"#", " of ", page_cnt"#"
  WITH counter, outerjoin = d1, outerjoin = d2,
   outerjoin = d4, outerjoin = d5, outerjoin = d10,
   outerjoin = d11, outerjoin = d13, dontcare = e,
   dontcare = epr, dontcare = pl, dontcare = pl2,
   dontcare = ea, dontcare = pa, dontcare = pl4,
   dio = 08, maxrow = value(doc_max_row), maxcol = 1200
 ;end select
#exit_script
END GO
