CREATE PROGRAM bhs_ma_physician_sign_orders2:dba
 PROMPT
  "Enter Output Device (Default is MINE(SCREEN)):" = "MINE",
  "Enter Physician Name:" = "",
  "# of Days to lookback (Default is 15):" = "15"
  WITH outdev, physician_id, daysback
 DECLARE doctor_name = vc
 DECLARE days_back = i2
 DECLARE physician_id = f8
 SET physician_id = cnvtreal( $PHYSICIAN_ID)
 SET days_back = (cnvtint( $DAYSBACK) * - (1))
 SET temp_beg_dt = datetimeadd(cnvtdatetime(curdate,0),days_back)
 SET beg_dt = cnvtdate(temp_beg_dt,"MMDDYYYY;;D")
 SET end_dt = curdate
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 RECORD physician(
   1 physician_name = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET linelen = 0
 SUBROUTINE calclinelen(txt,maxlength)
   SET c = maxlength
   SET linelen = maxlength
   WHILE ((c > (maxlength - 10)))
     SET tempchar = substring(c,1,txt)
     IF (((tempchar=" ") OR (((tempchar=",") OR (tempchar=";")) )) )
      SET linelen = c
      SET c = 0
     ENDIF
     SET c = (c - 1)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE parse_text(txt,maxlength)
   SET holdstr = txt
   SET pt->line_cnt = 0
   WHILE (textlen(trim(holdstr)) > 0)
     SET pt->line_cnt = (pt->line_cnt+ 1)
     SET stat = alterlist(pt->lns,pt->line_cnt)
     CALL calclinelen(holdstr,maxlength)
     SET pt->lns[pt->line_cnt].line = trim(substring(1,linelen,holdstr),3)
     SET holdstr = substring((linelen+ 1),(textlen(holdstr) - linelen),holdstr)
   ENDWHILE
 END ;Subroutine
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE pl.person_id=physician_id
  DETAIL
   physician->physician_name = pl.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  orw.review_personnel_id, order_display_line = o.clinical_display_line, order_id = cnvtstring(
   cnvtint(o.order_id)),
  patient_name = substring(1,25,p.name_full_formatted), fin = cnvtalias(ea.alias,ea.alias_pool_cd)
  "#############", order_dt = o.orig_order_dt_tm,
  order_mnemonic = substring(1,30,o.order_mnemonic)
  FROM order_review orw,
   orders o,
   person p,
   encntr_alias ea
  PLAN (orw
   WHERE orw.review_personnel_id=physician_id
    AND orw.review_type_flag=2
    AND orw.reviewed_status_flag=1
    AND orw.review_dt_tm BETWEEN cnvtdatetime(beg_dt,0) AND cnvtdatetime(end_dt,235959))
   JOIN (o
   WHERE o.order_id=orw.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(o.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin_cd)
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.active_ind=outerjoin(1))
  ORDER BY order_dt, patient_name, order_id,
   orw.action_sequence DESC
  HEAD REPORT
   disp_line = fillstring(131," "), line1 = fillstring(131,"-")
  HEAD PAGE
   col 1,
   CALL center("Physician Signed Orders",1,131), row + 1,
   disp_line = concat("Physician:  ",physician->physician_name), col 1,
   CALL center(trim(disp_line,3),1,131),
   row + 1, disp_line = concat("Days Back:  ",cnvtstring((days_back * - (1)))), col 1,
   CALL center(trim(disp_line,3),1,131), row + 2, col 1,
   "Patient Name", col 26, "FIN",
   col 37, "Order ID", col 48,
   "Order Mnemonic", col 80, "Clinical Display Line",
   row + 1, col 0, line1,
   row + 1
  HEAD order_id
   col 1, patient_name, col 26,
   fin, col 37, order_id,
   col 48., order_mnemonic,
   CALL parse_text(order_display_line,50)
   FOR (x = 1 TO pt->line_cnt)
     col 80, pt->lns[x].line, row + 1
   ENDFOR
  FOOT REPORT
   row + 2,
   CALL center("**** END OF REPORT ****",1,131)
  WITH nocounter, nullreport
 ;end select
 FREE RECORD physician
END GO
