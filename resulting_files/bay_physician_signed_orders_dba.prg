CREATE PROGRAM bay_physician_signed_orders:dba
 PROMPT
  "Enter Output Device (Default is MINE(SCREEN)): " = "MINE",
  "Enter Physician Name: " = "Enter Physician Name Here",
  "Enter Physician Id (Default is 0): " = "0",
  "# of Days to lookback (Default is 15):" = "15"
 DECLARE doctor_name = vc
 DECLARE days_back = i2
 SET days_back = (cnvtint( $4) * - (1))
 SET temp_beg_dt = datetimeadd(cnvtdatetime(curdate,0),days_back)
 SET beg_dt = cnvtdate(temp_beg_dt,"MMDDYYYY;;D")
 SET end_dt = curdate
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 RECORD physician(
   1 pcnt = i2
   1 qual[*]
     2 person_id = f8
     2 physician_name = vc
 )
 IF (cnvtint( $3)=0)
  SET doctor_name = cnvtupper(concat("'*", $2,"*'"))
  SELECT INTO "nl:"
   pn.person_id
   FROM prsnl pn
   PLAN (pn
    WHERE cnvtupper(pn.name_full_formatted)=parser(doctor_name)
     AND pn.physician_ind=1
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND pn.active_ind=1)
   HEAD REPORT
    pcnt = 0
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(physician->qual,pcnt), physician->qual[pcnt].person_id = pn
    .person_id,
    physician->qual[pcnt].physician_name = pn.name_full_formatted
   FOOT REPORT
    physician->pcnt = pcnt
   WITH nocounter
  ;end select
 ELSE
  SET physician->pcnt = 1
  SET stat = alterlist(physician->qual,physician->pcnt)
  SET physician->qual[1].person_id = cnvtreal( $3)
  SELECT INTO "nl:"
   FROM prsnl pl
   WHERE (pl.person_id=physician->qual[1].person_id)
   DETAIL
    physician->qual[1].physician_name = pl.name_full_formatted
  ;end select
 ENDIF
 IF ((physician->pcnt != 1))
  SELECT INTO value( $1)
   d.seq
   FROM (dummyt d  WITH seq = size(physician->qual,5))
   PLAN (d)
   ORDER BY d.seq
   HEAD REPORT
    line1 = fillstring(120,"-"), line2 = fillstring(120,"=")
   HEAD PAGE
    row 1,
    CALL center("*** Multiple Physicians Found ***",1,120), row + 1,
    CALL center("Please Choose The Appropriate Person Id and rerun the report",1,120), row + 2, col 1,
    "Person Id", col 25, "Physician  Name",
    row + 1
   HEAD d.seq
    col 1, physician->qual[d.seq].person_id";l", col 25,
    physician->qual[d.seq].physician_name, row + 1
   FOOT REPORT
    row + 1,
    CALL center("END OF REPORT",1,120)
   WITH nocounter, nullreport
  ;end select
 ENDIF
 IF ((physician->pcnt=1))
  SELECT
   order_display_line = substring(1,60,o.clinical_display_line), order_id = cnvtstring(cnvtint(o
     .order_id)), patient_name = substring(1,25,p.name_full_formatted),
   fin = cnvtalias(ea.alias,ea.alias_pool_cd)"#############", order_dt = o.orig_order_dt_tm
   FROM order_review orw,
    orders o,
    person p,
    encntr_alias ea
   PLAN (orw
    WHERE (orw.review_personnel_id=physician->qual[1].person_id)
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
   ORDER BY order_dt, patient_name
   HEAD REPORT
    disp_line = fillstring(131," "), line1 = fillstring(131,"-")
   HEAD PAGE
    col 1,
    CALL center("Physician Signed Orders",1,131), row + 1,
    disp_line = concat("Physician:  ",physician->qual[1].physician_name), col 1,
    CALL center(trim(disp_line,3),1,131),
    row + 1, disp_line = concat("Days Back:  ",cnvtstring((days_back * - (1)))), col 1,
    CALL center(trim(disp_line,3),1,131), row + 2, col 1,
    "Patient Name", col 28, "FIN",
    col 42, "Order ID", col 55,
    "Clinical Display Line", row + 1, col 0,
    line1, row + 1
   DETAIL
    col 1, patient_name, col 28,
    fin, col 42, order_id,
    col 55, order_display_line
   FOOT REPORT
    row + 2,
    CALL center("**** END OF REPORT ****",1,131)
   WITH nocounter, nullreport
  ;end select
 ENDIF
END GO
