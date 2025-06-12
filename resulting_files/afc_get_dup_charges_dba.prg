CREATE PROGRAM afc_get_dup_charges:dba
 PAINT
 CALL text(5,10,"Beginning Date	:")
 CALL text(6,10,"Ending Date	:")
 CALL accept(5,30,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET begdate = concat(curaccept," 00:00:00.00")
 CALL accept(6,30,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET enddate = concat(curaccept," 23:59:59.99")
 CALL text(7,10,"PROCESSING...")
 RECORD event(
   1 event_qual = i2
   1 events[*]
     2 charge_event_id = f8
     2 charge_item_id = f8
     2 charge_event = f8
     2 payor_id = f8
     2 bill_item_id = f8
     2 description = c50
     2 charge_dt_tm = dq8
     2 accession = c18
 )
 SET count1 = 0
 SET count2 = 0
 SET lastce_id = - (1.0)
 SET lastci_id = 0
 SET newid = 0
 SET detcnt = 0
 SELECT INTO "nl:"
  ce.charge_event_id, c.charge_item_id, c.charge_event_act_id,
  c.charge_event_id, c.payor_id, c.bill_item_id
  FROM charge_event ce,
   charge c
  PLAN (ce
   WHERE ce.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate))
   JOIN (c
   WHERE c.charge_event_id=ce.charge_event_id
    AND c.charge_event_act_id != 0)
  ORDER BY ce.charge_event_id, c.charge_item_id
  HEAD ce.charge_event_id
   newid = 1, detcnt = 0
  DETAIL
   detcnt = (detcnt+ 1)
   IF (((lastce_id=ce.charge_event_id) OR (newid=1)) )
    count1 = (count1+ 1), stat = alterlist(event->events,count1), event->events[count1].
    charge_event_id = ce.charge_event_id,
    event->events[count1].charge_item_id = c.charge_item_id, event->events[count1].charge_event = c
    .charge_event_id, event->events[count1].payor_id = c.payor_id,
    event->events[count1].bill_item_id = c.bill_item_id, event->events[count1].description = c
    .charge_description, event->events[count1].charge_dt_tm = c.service_dt_tm,
    event->events[count1].accession = ce.accession_nbr
   ENDIF
   lastce_id = ce.charge_event_id, newid = 0
  FOOT  ce.charge_event_id
   IF (detcnt=1)
    count1 = (count1 - 1)
   ENDIF
  WITH nocounter
 ;end select
 SET event->event_qual = count1
 SET lastce_id = 0.0
 SET dashline = fillstring(130,"-")
 SET dupcnt = 0
 SET totdup = 0
 SELECT
  dt = format(event->events[d1.seq].charge_dt_tm,"ddmmmyyyy;;d"), tm = format(event->events[d1.seq].
   charge_dt_tm,"hhmm;;s")
  FROM (dummyt d1  WITH seq = value(event->event_qual))
  PLAN (d1)
  HEAD REPORT
   col 01, "Duplicate Charges Report", row + 1,
   col 01, curdate, " ",
   curtime, row + 2
  HEAD PAGE
   col 01, "ce.ce_id", col 10,
   "c.ci_id", col 20, "c.ce_id",
   col 30, "c.payor", col 40,
   "c.bi_id", col 50, "Charge Description",
   col 80, "service date time", col 100,
   "accession number", row + 1, col 01,
   dashline, row + 1
  DETAIL
   IF ((event->events[d1.seq].charge_event_id != lastce_id)
    AND dupcnt > 0)
    col 01, "dup count: ", dupcnt,
    row + 2, totdup = (totdup+ dupcnt), dupcnt = 0
   ENDIF
   dupcnt = (dupcnt+ 1), col 01, event->events[d1.seq].charge_event_id"########",
   col 10, event->events[d1.seq].charge_item_id"########", col 20,
   event->events[d1.seq].charge_event"########", col 30, event->events[d1.seq].payor_id"########",
   col 40, event->events[d1.seq].bill_item_id"########", col 50,
   event->events[d1.seq].description, col 80, dt,
   col 90, tm, col 100,
   event->events[d1.seq].accession, row + 1, lastce_id = event->events[d1.seq].charge_event_id
  FOOT REPORT
   col 01, "dup count: ", dupcnt,
   totdup = (totdup+ dupcnt), dupcnt = 0, row + 2,
   col 01, "Total Duplicates: ", totdup
  WITH nocounter
 ;end select
 FREE SET event
END GO
