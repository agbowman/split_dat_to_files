CREATE PROGRAM afc_master_exceptions:dba
 PAINT
 SET width = 132
 SET modify = system
 SET count1 = 0
 SET count2 = 0
 SET loop_counter = 0
 SET start = 1
#now_start
 IF (start=0)
  FREE SET reply
 ENDIF
 SET start = 0
 RECORD reply(
   1 charge_event_qual = i2
   1 charge_event[*]
     2 ext_m_event_id = f8
     2 charge_priced = i2
     2 accession = c18
     2 id = i4
     2 short_desc = c15
     2 desc = c20
     2 event_qual = i2
     2 person_id = f8
     2 person_name = c25
     2 order_status_cd = f8
     2 order_status_disp = c15
     2 order_dt_tm = dq8
 )
 SET stat = alterlist(reply->charge_event,10)
 SET master_id = 0
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET myaccept = fillstring(20," ")
 SET dashline = fillstring(130,"-")
#accept_dates
 CALL text(10,1,"Beginning Date: ")
 CALL text(11,1,"Ending Date   : ")
 CALL accept(10,20,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET begdate = concat(curaccept," 00:00:00.00")
 CALL accept(11,20,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET enddate = concat(curaccept," 23:59:59.99")
 CALL text(24,1,"Correct? (Y/N/Q): ")
 CALL accept(24,20,"X;C","Y"
  WHERE curaccept IN ("Y", "N", "Q", "y", "n",
  "q"))
 IF (cnvtupper(curaccept)="Q")
  GO TO now_exit
 ELSEIF (cnvtupper(curaccept)="N")
  GO TO accept_dates
 ENDIF
 CALL text(12,1,"PROCESSING")
 SELECT INTO "nl:"
  c.charge_event_id, c.ext_m_reference_id, c.ext_m_event_id,
  b.ext_parent_reference_id, c.ext_i_reference_id, b.ext_child_reference_id,
  accession = substring(1,20,c.accession_nbr), id = cnvtint(c.charge_event_id), desc = substring(1,30,
   b.ext_description),
  short_desc = substring(1,10,b.ext_short_desc)
  FROM charge_event c,
   bill_item b,
   encounter e
  PLAN (c
   WHERE c.ext_m_event_id != 0
    AND c.ext_p_event_id=0
    AND c.ext_i_event_id != 0
    AND c.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate))
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND e.loc_nurse_unit_cd=713604)
   JOIN (b
   WHERE ((b.bill_item_id=c.bill_item_id
    AND c.bill_item_id != 0) OR (((b.ext_parent_reference_id=c.ext_i_reference_id
    AND b.ext_parent_contributor_cd=c.ext_i_reference_cont_cd
    AND b.ext_child_reference_id=0) OR (b.ext_child_reference_id=c.ext_m_reference_id
    AND b.ext_child_contributor_cd=c.ext_i_reference_cont_cd
    AND b.ext_parent_reference_id=0)) )) )
  ORDER BY c.ext_i_reference_id, c.ext_m_event_id
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->charge_event,(count1+ 10))
   ENDIF
   reply->charge_event[count1].ext_m_event_id = c.ext_m_event_id, reply->charge_event[count1].id =
   cnvtint(c.charge_event_id), reply->charge_event[count1].accession = c.accession_nbr,
   reply->charge_event[count1].short_desc = b.ext_short_desc, reply->charge_event[count1].desc = b
   .ext_description, reply->charge_event[count1].person_id = c.person_id,
   reply->charge_event[count1].order_status_disp = "not found"
  WITH nocounter
 ;end select
 SET reply->charge_event_qual = count1
 SET stat = alterlist(reply->charge_event,count1)
 CALL text(13,1,build("Read: ",reply->charge_event_qual))
 SELECT INTO "nl:"
  c.charge_item_id
  FROM (dummyt d1  WITH seq = value(reply->charge_event_qual)),
   charge_event ce,
   charge c
  PLAN (d1)
   JOIN (ce
   WHERE (ce.ext_m_event_id=reply->charge_event[d1.seq].ext_m_event_id))
   JOIN (c
   WHERE c.charge_event_id=ce.charge_event_id)
  DETAIL
   IF (c.charge_item_id != 0)
    reply->charge_event[d1.seq].charge_priced = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM (dummyt d1  WITH seq = value(reply->charge_event_qual)),
   orders o,
   code_value cv
  PLAN (d1
   WHERE (reply->charge_event[d1.seq].charge_priced=0))
   JOIN (o
   WHERE (o.order_id=reply->charge_event[d1.seq].ext_m_event_id))
   JOIN (cv
   WHERE cv.code_value=o.order_status_cd)
  DETAIL
   reply->charge_event[d1.seq].order_status_cd = o.order_status_cd, reply->charge_event[d1.seq].
   order_status_disp = cv.display, reply->charge_event[d1.seq].order_dt_tm = o.orig_order_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_id
  FROM (dummyt d1  WITH seq = value(count1)),
   person p
  PLAN (d1
   WHERE (reply->charge_event[d1.seq].charge_priced=0))
   JOIN (p
   WHERE (p.person_id=reply->charge_event[d1.seq].person_id))
  DETAIL
   reply->charge_event[d1.seq].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT
  dt = format(reply->charge_event[d1.seq].order_dt_tm,"ddmmmyyyy;;D"), tm = format(reply->
   charge_event[d1.seq].order_dt_tm,"HHMM;;M")
  FROM (dummyt d1  WITH seq = value(reply->charge_event_qual))
  PLAN (d1
   WHERE (reply->charge_event[d1.seq].charge_priced=0))
  HEAD REPORT
   col 01, "PREPARED: ", col 12,
   curdate, " ", curtime,
   col 80, "CHARGE EVENT EXCEPTION REPORT", row + 1,
   col 01, "RANGE: ", begdate,
   " TO ", enddate, row + 1
  HEAD PAGE
   col 115, "PAGE: ", col 125,
   curpage"####", row + 1, col 01,
   "M_E_ID", col 10, "CE ID",
   col 20, "ACCESSION", col 39,
   "SHORT DESC", col 55, "DESCRIPTION",
   col 77, "PATIENT", col 105,
   "ORDER STATUS", col 120, "Order Date",
   row + 1, col 01, dashline,
   row + 1
  DETAIL
   count1 = (count1+ 1), col 01, reply->charge_event[d1.seq].ext_m_event_id"########",
   col 10, reply->charge_event[d1.seq].id"########", col 20,
   reply->charge_event[d1.seq].accession, col 39, reply->charge_event[d1.seq].short_desc,
   col 55, reply->charge_event[d1.seq].desc, col 77,
   reply->charge_event[d1.seq].person_name, col 105, reply->charge_event[d1.seq].order_status_disp,
   col 118, dt, col 127,
   tm, row + 1
  FOOT REPORT
   col 01, "TOTAL: ", col 10,
   count1"########"
  WITH nocounter
 ;end select
 GO TO now_start
#now_exit
END GO
