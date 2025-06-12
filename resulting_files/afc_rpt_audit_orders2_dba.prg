CREATE PROGRAM afc_rpt_audit_orders2:dba
 PROMPT
  "Start date (MMDDYY): ",
  "  End date (MMDDYY): "
 SET beg_date_time = build(format(cnvtdate( $1),"DD-MMM-YYYY;;D")," 00:00:00.00")
 SET end_date_time = build(format(cnvtdate( $2),"DD-MMM-YYYY;;D")," 23:59:59.99")
 EXECUTE FROM 1000_initialize TO 1999_iniitialize_exit
 EXECUTE FROM 2000_ordered TO 2999_ordered_exit
 EXECUTE FROM 3000_collected TO 3999_collected_exit
 EXECUTE FROM 4000_completed TO 4999_completed_exit
 EXECUTE FROM 5000_person TO 5999_person_exit
 EXECUTE FROM 6000_accession TO 6999_accession_exit
 EXECUTE FROM 7000_report TO 7999_report_exit
 GO TO 9999_exit_program
#1000_initialize
 SET oe_ordered_status_cd = 0.0
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=6004
   AND c.cdf_meaning="ORDERED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   oe_ordered_status_cd = c.code_value
  WITH nocounter
 ;end select
 SET oe_completed_status_cd = 0.0
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=6004
   AND c.cdf_meaning="COMPLETED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   oe_completed_status_cd = c.code_value
  WITH nocounter
 ;end select
 SET afc_ordered_status_cd = 0.0
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=13029
   AND c.cdf_meaning="ORDERED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   afc_ordered_status_cd = c.code_value
  WITH nocounter
 ;end select
 SET afc_collected_status_cd = 0.0
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=13029
   AND c.cdf_meaning="COLLECTED"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   afc_collected_status_cd = c.code_value
  WITH nocounter
 ;end select
 SET afc_completed_status_cd = 0.0
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=13029
   AND c.cdf_meaning="COMPLETE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   afc_completed_status_cd = c.code_value
  WITH nocounter
 ;end select
 RECORD orders(
   1 orders[*]
     2 order_id = f8
     2 order_mnemonic = c25
     2 person_id = f8
     2 person_name = c25
     2 person_last_name = c25
     2 accession = c18
     2 updt_dt_tm = dq8
     2 activity_type = c25
     2 afc_ordered = i2
     2 oe_collected = i2
     2 afc_collected = i2
     2 oe_completed = i2
     2 afc_completed = i2
 )
#1999_initialize_exit
#2000_ordered
 SET total = 0
 SELECT INTO "nl:"
  o.seq
  FROM orders o,
   code_value c
  PLAN (o
   WHERE o.updt_dt_tm >= cnvtdatetime(beg_date_time)
    AND o.updt_dt_tm <= cnvtdatetime(end_date_time)
    AND ((o.order_status_cd=oe_ordered_status_cd) OR (o.order_status_cd=oe_completed_status_cd)) )
   JOIN (c
   WHERE c.code_value=o.activity_type_cd)
  DETAIL
   total = (total+ 1), stat = alterlist(orders->orders,total), orders->orders[total].order_id = o
   .order_id,
   orders->orders[total].order_mnemonic = o.order_mnemonic, orders->orders[total].person_id = o
   .person_id, orders->orders[total].activity_type = c.display,
   orders->orders[total].updt_dt_tm = o.updt_dt_tm
   IF (o.order_status_cd=oe_completed_status_cd)
    orders->orders[total].oe_completed = 1
   ENDIF
 ;end select
 SELECT INTO "nl:"
  c.seq
  FROM charge_event c,
   charge_event_act a,
   (dummyt d  WITH seq = value(total))
  PLAN (d)
   JOIN (c
   WHERE (c.ext_m_event_id=orders->orders[d.seq].order_id)
    AND (c.ext_i_event_id=orders->orders[d.seq].order_id))
   JOIN (a
   WHERE c.charge_event_id=a.charge_event_id
    AND a.cea_type_cd=afc_ordered_status_cd)
  DETAIL
   IF (a.charge_event_act_id > 0)
    orders->orders[d.seq].afc_ordered = 1
   ENDIF
  WITH nocounter
 ;end select
#2999_ordered_exit
#3000_collected
 SELECT INTO "nl:"
  o.collection_status_flag
  FROM order_container_r o,
   (dummyt d  WITH seq = value(total))
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=orders->orders[d.seq].order_id))
  DETAIL
   IF (o.collection_status_flag=1)
    orders->orders[d.seq].oe_collected = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM charge_event c,
   charge_event_act a,
   (dummyt d  WITH seq = value(total))
  PLAN (d
   WHERE (orders->orders[d.seq].oe_collected=1))
   JOIN (c
   WHERE (c.ext_m_event_id=orders->orders[d.seq].order_id)
    AND (c.ext_i_event_id=orders->orders[d.seq].order_id))
   JOIN (a
   WHERE c.charge_event_id=a.charge_event_id
    AND a.cea_type_cd=afc_collected_status_cd)
  DETAIL
   IF (a.charge_event_act_id > 0)
    orders->orders[d.seq].afc_collected = 1
   ENDIF
  WITH nocounter
 ;end select
#3999_collected_exit
#4000_completed
 SELECT INTO "nl:"
  c.seq
  FROM charge_event c,
   charge_event_act a,
   (dummyt d  WITH seq = value(total))
  PLAN (d
   WHERE (orders->orders[d.seq].oe_completed=1))
   JOIN (c
   WHERE (c.ext_m_event_id=orders->orders[d.seq].order_id)
    AND (c.ext_i_event_id=orders->orders[d.seq].order_id))
   JOIN (a
   WHERE c.charge_event_id=a.charge_event_id
    AND a.cea_type_cd=afc_completed_status_cd)
  DETAIL
   IF (a.charge_event_act_id > 0)
    orders->orders[d.seq].afc_collected = 1
   ENDIF
  WITH nocounter
 ;end select
#4999_completed_exit
#5000_person
 SELECT INTO "nl:"
  p.seq
  FROM person p,
   (dummyt d  WITH seq = value(total))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=orders->orders[d.seq].person_id))
  DETAIL
   orders->orders[d.seq].person_name = p.name_full_formatted, orders->orders[d.seq].person_last_name
    = p.name_last_key
  WITH nocounter
 ;end select
#5999_person_exit
#6000_accession
 SELECT INTO "nl:"
  a.seq
  FROM accession a,
   accession_order_r r,
   (dummyt d  WITH seq = value(total))
  PLAN (d)
   JOIN (r
   WHERE (r.order_id=orders->orders[d.seq].order_id))
   JOIN (a
   WHERE a.accession_id=r.accession_id)
  DETAIL
   orders->orders[d.seq].accession = a.accession
  WITH nocounter
 ;end select
#6999_accession_exit
#7000_report
 SET count = 0
 SET dashline = fillstring(130,"-")
 SET ordercol = 17
 SET ceacol = 24
 SET labelcol = 5
 SELECT
  dt = format(orders->orders[d.seq].updt_dt_tm,"MM/DD/YY;;D"), tm = format(orders->orders[d.seq].
   updt_dt_tm,"HHMM;;M")
  FROM (dummyt d  WITH seq = value(total))
  PLAN (d
   WHERE (((orders->orders[d.seq].afc_ordered=0)) OR ((((orders->orders[d.seq].oe_collected=1)
    AND (orders->orders[d.seq].afc_collected=0)) OR ((orders->orders[d.seq].oe_completed=1)
    AND (orders->orders[d.seq].afc_completed=0))) ))
    AND (orders->orders[d.seq].person_last_name != "TEST")
    AND trim(orders->orders[d.seq].person_name) > " ")
  ORDER BY orders->orders[d.seq].person_name
  HEAD REPORT
   count = 0
  HEAD PAGE
   col 01, curdate, col 10,
   curtime, col 01, "Order Id",
   col 10, "Date", col 30,
   "Order Mnemonic", col 60, "Activity Type",
   col 80, "Accession", col 100,
   "Person Name", row + 1, col 01,
   dashline, row + 1
  DETAIL
   count = (count+ 1), col 01, orders->orders[d.seq].order_id"########",
   col 10, dt, col 22,
   tm, col 30, orders->orders[d.seq].order_mnemonic,
   col 60, orders->orders[d.seq].activity_type, col 80,
   orders->orders[d.seq].accession, col 100, orders->orders[d.seq].person_name,
   row + 1, col ordercol, "ORDER",
   col ceacol, "CEA", row + 1,
   col labelcol, "Ordered: ", call reportmove('COL',(ordercol+ 2),0),
   "1", call reportmove('COL',(ceacol+ 1),0), orders->orders[d.seq].afc_ordered"#",
   row + 1, col labelcol, "Collected: ",
   call reportmove('COL',(ordercol+ 2),0), orders->orders[d.seq].oe_collected"#", call reportmove(
   'COL',(ceacol+ 1),0),
   orders->orders[d.seq].afc_collected"#", row + 1, col labelcol,
   "Completed: ", call reportmove('COL',(ordercol+ 2),0), orders->orders[d.seq].oe_completed"#",
   call reportmove('COL',(ceacol+ 1),0), orders->orders[d.seq].afc_completed"#", row + 2
  FOOT PAGE
   col 100, "Page:", col 110,
   curpage
  FOOT REPORT
   row + 2, col 2, "Total Orders: ",
   col 16, count
  WITH nocounter
 ;end select
#7999_report_exit
#9999_exit_program
 FREE SET orders
END GO
