CREATE PROGRAM db_ap_ten
 SELECT
  pg.group_name, pg.group_desc, pg.reset_yearly_ind,
  pg.manual_assign_ind, ap.prefix_name, ap.prefix_desc,
  oc.description, oc2.description, oc3.description
  FROM (dummyt d1  WITH seq = 1),
   prefix_group pg,
   ap_prefix ap,
   order_catalog oc,
   prefix_report_r prr,
   order_catalog oc2,
   ap_prefix_auto_task apat,
   order_catalog oc3
  PLAN (pg)
   JOIN (ap
   WHERE pg.group_id=ap.group_id)
   JOIN (oc
   WHERE ap.order_catalog_cd=oc.catalog_cd)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (prr
   WHERE ap.prefix_id=prr.prefix_id)
   JOIN (apat
   WHERE ap.prefix_id=apat.prefix_id)
   JOIN (oc2
   WHERE prr.catalog_cd=oc2.catalog_cd)
   JOIN (oc3
   WHERE apat.catalog_cd=oc3.catalog_cd)
  HEAD REPORT
   full_line = fillstring(130,"-"), pg = 0, temp = fillstring(30," "),
   aloop = 0, loop = 0, rpt[100] = fillstring(40," "),
   atask[100] = fillstring(40," ")
  HEAD PAGE
   pg += 1, col 1, "Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Prefixes",
   col 90, "Printed ", curdate,
   " ", curtime, row + 1,
   col 1, "Cerner", row + 2
  HEAD pg.group_name
   IF (((row+ 6) > 54))
    BREAK
   ENDIF
   col 1, "GROUP: ", pg.group_name,
   col 30, pg.group_desc, col 90,
   "RESET YEARLY: "
   IF (pg.reset_yearly_ind=1)
    "Yes"
   ELSE
    "No"
   ENDIF
   col 115, "MANUAL: "
   IF (pg.manual_assign_ind=1)
    "Yes"
   ELSE
    "No"
   ENDIF
   row + 1, col 1, full_line,
   row + 1
  HEAD ap.prefix_name
   aloop = 1, xx = initarray(rpt," "), xx = initarray(atask," "),
   col 10, "PREFIX: ", ap.prefix_name,
   col 25, ap.prefix_desc, temp = substring(1,30,oc.description),
   col 80, "INITIATING ORDER: ", temp,
   row + 2
  HEAD oc3.description
   loop = 1, xx = initarray(rpt," "), atask[aloop] = oc3.description
  DETAIL
   rpt[loop] = oc2.description, loop += 1
  FOOT  oc3.description
   aloop += 1
  FOOT  ap.prefix_name
   col 30, "ELGIBLE REPORTS", col 75,
   "AUTO TASKS", row + 1, col 30,
   "---------------", col 75, "__________",
   row + 1, loop = 1
   WHILE (loop < 101)
     IF ((rpt[loop] != " "))
      col 30, rpt[loop]
     ENDIF
     IF ((atask[loop] != " "))
      col 75, atask[loop]
     ENDIF
     IF ((((rpt[loop] > " ")) OR ((atask[loop] > " "))) )
      row + 1
     ENDIF
     loop += 1
   ENDWHILE
  FOOT  pg.group_name
   row + 3
  WITH outerjoin = d1, dontcare = prr
 ;end select
END GO
