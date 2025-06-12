CREATE PROGRAM afc_del_dup_price_sched:dba
 RECORD holdrec(
   1 holdrec_qual = i2
   1 hold[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
     2 active_ind = i2
     2 pharm_ind = i2
 )
 RECORD duphold(
   1 duphold_qual = i2
   1 dup[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
     2 active_ind = i2
 )
 SET count1 = 0
 SET stat = alterlist(holdrec->hold,0)
 SET readme = 0
 IF (validate(request->setup_proc[1].success_ind,999) != 999)
  SET readme = 1
  EXECUTE oragen3 "PRICE_SCHED"
  EXECUTE oragen3 "CHARGE"
  EXECUTE oragen3 "PRICE_SCHED_ITEMS"
  EXECUTE oragen3 "PRICE_RANGE"
 ENDIF
 SET file_name = fillstring(20," ")
 IF (readme=1)
  SET file_name = concat("del_dup_ps",format(curdate,"MMDDYY;;d"),".dat")
 ELSE
  SET file_name = "MINE"
 ENDIF
 SELECT INTO "nl:"
  p.price_sched_id, p.active_ind, p.pharm_ind,
  p.price_sched_desc
  FROM price_sched p
  WHERE p.price_sched_id > 0
  ORDER BY p.price_sched_desc, p.active_ind, p.pharm_ind
  DETAIL
   count1 = (count1+ 1), stat = alterlist(holdrec->hold,count1), holdrec->hold[count1].price_sched_id
    = p.price_sched_id,
   holdrec->hold[count1].price_sched_desc = p.price_sched_desc, holdrec->hold[count1].active_ind = p
   .active_ind, holdrec->hold[count1].pharm_ind = p.pharm_ind
  WITH nocounter
 ;end select
 SET holdrec->holdrec_qual = count1
 SET count2 = 0
 SET stat = alterlist(duphold->dup,0)
 CALL echo("Looping through holdrec...")
 FOR (i = 1 TO holdrec->holdrec_qual)
   IF (((i+ 1) <= holdrec->holdrec_qual))
    IF ((holdrec->hold[i].price_sched_desc=holdrec->hold[(i+ 1)].price_sched_desc)
     AND (holdrec->hold[i].active_ind=holdrec->hold[(i+ 1)].active_ind)
     AND (holdrec->hold[i].pharm_ind=holdrec->hold[(i+ 1)].pharm_ind))
     SET count2 = (count2+ 1)
     CALL echo(concat("dup found ",holdrec->hold[i].price_sched_desc," ",cnvtstring(holdrec->hold[i].
        price_sched_id,17,2)))
     SET stat = alterlist(duphold->dup,count2)
     SET duphold->dup[count2].price_sched_id = holdrec->hold[i].price_sched_id
     SET duphold->dup[count2].price_sched_desc = holdrec->hold[i].price_sched_desc
     SET duphold->dup[count2].active_ind = holdrec->hold[i].active_ind
     SET duphold->duphold_qual = count2
    ENDIF
   ENDIF
 ENDFOR
 SET underline = fillstring(130,"_")
 CALL echo("Generating report...")
 SELECT INTO value(file_name)
  pi.price_sched_items_id, pi.price_sched_id, pi.price,
  pi.beg_effective_dt_tm, pi.end_effective_dt_tm, b.bill_item_id,
  b.ext_description
  FROM (dummyt d1  WITH seq = value(duphold->duphold_qual)),
   price_sched_items pi,
   bill_item b
  PLAN (d1
   WHERE (duphold->dup[d1.seq].active_ind=1))
   JOIN (pi
   WHERE (pi.price_sched_id=duphold->dup[d1.seq].price_sched_id)
    AND pi.active_ind=1)
   JOIN (b
   WHERE b.bill_item_id=pi.bill_item_id)
  HEAD REPORT
   col 1, "Report of Deleted Price Schedules", row + 2
  HEAD PAGE
   col 110, "Page: ", col 115,
   curpage, col 1, "Price Schedule",
   col 82, "Price Sched ID", row + 1,
   col 15, "Bill Item ID", col 30,
   "Bill Item", col 60, "Price",
   col 103, "Effective Date Range", row + 1,
   col 1, underline, row + 2
  HEAD pi.price_sched_id
   col 1, duphold->dup[d1.seq].price_sched_desc, col 80,
   duphold->dup[d1.seq].price_sched_id, row + 1
  DETAIL
   col 10, b.bill_item_id, col 30,
   b.ext_description"####################", col 50, pi.price,
   col 103, pi.beg_effective_dt_tm, col 111,
   " - ", col 114, pi.end_effective_dt_tm,
   row + 1
  WITH nocounter
 ;end select
 CALL echo("Updating charge record...")
 FOR (x = 1 TO duphold->duphold_qual)
   UPDATE  FROM charge c
    SET c.active_ind = 0
    WHERE (c.price_sched_id=duphold->dup[x].price_sched_id)
   ;end update
 ENDFOR
 CALL echo("Deleting price_sched_item...")
 FOR (x = 1 TO duphold->duphold_qual)
   DELETE  FROM price_sched_items pi
    WHERE (pi.price_sched_id=duphold->dup[x].price_sched_id)
   ;end delete
 ENDFOR
 CALL echo("Deleting price_range...")
 FOR (x = 1 TO duphold->duphold_qual)
   DELETE  FROM price_range p
    WHERE (p.price_sched_id=duphold->dup[x].price_sched_id)
   ;end delete
 ENDFOR
 CALL echo("Deleting price_schedule...")
 FOR (x = 1 TO duphold->duphold_qual)
   DELETE  FROM price_sched p
    WHERE (p.price_sched_id=duphold->dup[x].price_sched_id)
   ;end delete
 ENDFOR
 CALL echo("Doing final clean up...")
 SET count1 = 0
 SET stat = alterlist(holdrec->hold,count1)
 SELECT INTO "nl:"
  p.price_sched_id, p.active_ind, p.pharm_ind,
  p.price_sched_desc
  FROM price_sched p
  WHERE p.price_sched_id > 0
  ORDER BY p.price_sched_desc, p.active_ind, p.pharm_ind
  DETAIL
   count1 = (count1+ 1), stat = alterlist(holdrec->hold,count1), holdrec->hold[count1].price_sched_id
    = p.price_sched_id,
   holdrec->hold[count1].price_sched_desc = p.price_sched_desc, holdrec->hold[count1].active_ind = p
   .active_ind, holdrec->hold[count1].pharm_ind = p.pharm_ind
  WITH nocounter
 ;end select
 SET holdrec->holdrec_qual = count1
 SET count2 = 0
 SET stat = alterlist(duphold->dup,0)
 CALL echo("Looping through holdrec...")
 FOR (i = 1 TO holdrec->holdrec_qual)
   IF (((i+ 1) <= holdrec->holdrec_qual))
    IF ((holdrec->hold[i].price_sched_desc=holdrec->hold[(i+ 1)].price_sched_desc)
     AND (holdrec->hold[i].pharm_ind=holdrec->hold[(i+ 1)].pharm_ind))
     SET count2 = (count2+ 1)
     CALL echo(concat("dup found ",holdrec->hold[i].price_sched_desc," ",cnvtstring(holdrec->hold[i].
        price_sched_id,17,2)))
     SET stat = alterlist(duphold->dup,count2)
     IF ((holdrec->hold[i].active_ind=0))
      CALL echo(concat("chose this ",holdrec->hold[i].price_sched_desc," ",cnvtstring(holdrec->hold[i
         ].price_sched_id,17,2)))
      SET duphold->dup[count2].price_sched_id = holdrec->hold[i].price_sched_id
      SET duphold->dup[count2].price_sched_desc = holdrec->hold[i].price_sched_desc
      SET duphold->dup[count2].active_ind = holdrec->hold[i].active_ind
      SET duphold->duphold_qual = count2
     ELSE
      SET duphold->dup[count2].price_sched_id = holdrec->hold[(i+ 1)].price_sched_id
      SET duphold->dup[count2].price_sched_desc = holdrec->hold[(i+ 1)].price_sched_desc
      SET duphold->dup[count2].active_ind = holdrec->hold[(i+ 1)].active_ind
      SET duphold->duphold_qual = count2
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("Updating charge record...")
 FOR (x = 1 TO duphold->duphold_qual)
   UPDATE  FROM charge c
    SET c.active_ind = 0
    WHERE (c.price_sched_id=duphold->dup[x].price_sched_id)
   ;end update
 ENDFOR
 CALL echo("Deleting price_sched_item...")
 FOR (x = 1 TO duphold->duphold_qual)
   DELETE  FROM price_sched_items pi
    WHERE (pi.price_sched_id=duphold->dup[x].price_sched_id)
   ;end delete
 ENDFOR
 CALL echo("Deleting price_range...")
 FOR (x = 1 TO duphold->duphold_qual)
   DELETE  FROM price_range p
    WHERE (p.price_sched_id=duphold->dup[x].price_sched_id)
   ;end delete
 ENDFOR
 CALL echo("Deleting price_schedule...")
 FOR (x = 1 TO duphold->duphold_qual)
   DELETE  FROM price_sched p
    WHERE (p.price_sched_id=duphold->dup[x].price_sched_id)
   ;end delete
 ENDFOR
 IF (readme=1)
  CALL echo("Done. Commit")
  COMMIT
 ELSE
  CALL echo("Done.  Type 'commit go' to save changes.")
 ENDIF
 FREE SET holdrec
 FREE SET duphold
END GO
