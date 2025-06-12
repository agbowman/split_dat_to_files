CREATE PROGRAM cps_outstanding_orders:dba
 FREE SET reply
 RECORD reply(
   1 out_orders_qual = i4
   1 out_orders[*]
     2 order_id = i8
     2 physician = c22
     2 patient = c22
     2 provider = c22
     2 test_name = c15
     2 priority = c15
     2 ordered_dt_tm = dq8
     2 ordered_tz = i4
   1 output_file = vc
   1 format_type = vc
   1 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->out_orders_qual = 0
 SET stat = alterlist(reply->out_orders,10)
 FREE SET print
 RECORD print(
   1 out_orders_qual = i4
   1 out_orders[*]
     2 order_id = i8
     2 physician = c22
     2 patient = c22
     2 provider = c22
     2 test_name = c15
     2 priority = c15
     2 ordered_dt_tm = dq8
 )
 SET print->out_orders_qual = 0
 SET stat = alterlist(print->out_orders,10)
 SET days_back = 0
 SET hours_back = 0
 SET days_back_hold = 0
 SET hours_back_hold = 0
 SET days_back_hold = value((cnvtint(request->hours_since)/ 24))
 SET hours_back_hold = value(mod(cnvtint(request->hours_since),24))
 IF (hours_back_hold > hour(curtime))
  SET days_back_hold = (days_back_hold+ 1)
  SET hours_back_hold = (hours_back_hold - hour(curtime))
 ENDIF
 SET days_back = (curdate - days_back_hold)
 SET hour_temp = 0
 SET minute_temp = 0
 SET hour_temp = hour(curtime)
 SET minute_temp = minute(curtime)
 SET hour_temp = (hour_temp - hours_back_hold)
 SET hours_back = cnvtint(build(format(hour_temp,"##;p0"),format(minute_temp,"##;p0")))
 DECLARE get_cvtext(p1) = c40
 SET count1 = 0
 SET cdf_meaning = fillstring(12," ")
 SET active_status_cd = 0.0
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 SELECT DISTINCT INTO "NL:"
  o.order_id, name_last_key = substring(1,50,p.name_last_key), name_last_key2 = substring(1,50,p
   .name_last_key),
  catalog_type = substring(1,25,uar_get_code_meaning(o.catalog_type_cd))
  FROM orders o,
   order_action oa,
   order_detail od,
   oe_field_meaning oe,
   person p,
   person p2,
   (dummyt d  WITH seq = value(request->test_category_qual)),
   (dummyt d2  WITH seq = value(request->priority_qual)),
   code_value cv
  PLAN (d)
   JOIN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(days_back,hours_back)
    AND o.active_status_cd=active_status_cd)
   JOIN (cv
   WHERE cv.code_value=o.catalog_type_cd
    AND cv.cdf_meaning=cnvtupper(request->test_category[d.seq].test_category_meaning))
   JOIN (oa
   WHERE o.order_id=oa.order_id)
   JOIN (od
   WHERE o.order_id=od.order_id)
   JOIN (d2)
   JOIN (oe
   WHERE oe.oe_field_meaning_id=od.oe_field_meaning_id
    AND ((od.oe_field_meaning IN ("PRIORITY", "REPPRI")
    AND (od.oe_field_display_value=request->priority_type[d2.seq].priority_type_meaning)) OR (od
   .oe_field_meaning="PERFORMLOC"
    AND ((od.oe_field_display_value=patstring(request->service_provider)) OR (od
   .oe_field_display_value >= " ")) )) )
   JOIN (p
   WHERE o.person_id=p.person_id)
   JOIN (p2
   WHERE oa.order_provider_id=p2.person_id
    AND p2.name_last_key >= patstring(cnvtupper(request->ordering_physician)))
  ORDER BY name_last_key2, name_last_key, o.order_mnemonic,
   o.order_id, catalog_type
  HEAD o.order_id
   count1 = (count1+ 1)
   IF (count1 <= size(reply->out_orders,5))
    stat = alterlist(reply->out_orders,(count1+ 9))
   ENDIF
   reply->out_orders[count1].order_id = o.order_id, reply->out_orders[count1].patient = p
   .name_full_formatted, reply->out_orders[count1].physician = p2.name_full_formatted,
   reply->out_orders[count1].test_name = o.order_mnemonic, reply->out_orders[count1].ordered_dt_tm =
   cnvtdatetime(o.orig_order_dt_tm), reply->out_orders[count1].ordered_tz = o.orig_order_tz
  DETAIL
   IF (od.oe_field_meaning="PERFORMLOC")
    reply->out_orders[count1].provider = od.oe_field_display_value
   ELSE
    reply->out_orders[count1].priority = od.oe_field_display_value
   ENDIF
  WITH check, nullreport, nocounter
 ;end select
 SET stat = alterlist(reply->out_orders,count1)
 SET reply->out_orders_qual = size(reply->out_orders,5)
 SET org_name = fillstring(50," ")
 SELECT INTO "nl:"
  o.org_name
  FROM person p,
   person_org_reltn po,
   organization o
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
   JOIN (po
   WHERE p.person_id=po.person_id)
   JOIN (o
   WHERE po.organization_id=o.organization_id)
  DETAIL
   org_name = o.org_name
  WITH check, nocounter
 ;end select
 SET nbr_physicians = 0
 SELECT INTO "NL:"
  physician = reply->out_orders[d.seq].physician
  FROM (dummyt d  WITH seq = value(reply->out_orders_qual))
  PLAN (d
   WHERE (reply->out_orders[d.seq].order_id > 0))
  ORDER BY reply->out_orders[d.seq].physician, reply->out_orders[d.seq].patient, reply->out_orders[d
   .seq].provider,
   reply->out_orders[d.seq].ordered_dt_tm, reply->out_orders[d.seq].ordered_tz
  HEAD REPORT
   nbr_physicians = 0, count1 = 0
  HEAD physician
   count1 = (count1+ 1)
  DETAIL
   x = 1
  FOOT REPORT
   nbr_physicians = count1
  WITH check, nocounter
 ;end select
 SET physician = fillstring(25," ")
 SET patient = fillstring(25," ")
 SET provider = fillstring(25," ")
 SET test_name = fillstring(15," ")
 SET hold_physician = fillstring(25," ")
 SET hold_patient = fillstring(25," ")
 SET hold_provider = fillstring(25," ")
 IF ((request->output_file=" "))
  SET request->output_file = "cps_out_orders"
 ENDIF
 SELECT INTO trim(request->output_file)
  order_id = reply->out_orders[d.seq].order_id, physician = reply->out_orders[d.seq].physician,
  patient = reply->out_orders[d.seq].patient,
  provider = reply->out_orders[d.seq].provider, test_name = reply->out_orders[d.seq].test_name,
  ordered_dt_tm = cnvtdatetime(reply->out_orders[d.seq].ordered_dt_tm),
  priority = reply->out_orders[d.seq].priority
  FROM (dummyt d  WITH seq = value(reply->out_orders_qual))
  PLAN (d
   WHERE (reply->out_orders[d.seq].order_id > 0))
  ORDER BY reply->out_orders[d.seq].physician, reply->out_orders[d.seq].patient, reply->out_orders[d
   .seq].provider,
   reply->out_orders[d.seq].ordered_dt_tm
  HEAD REPORT
   total_hours_old = 0,
   MACRO (build_report_line)
    print_cnt = 50, str_cnt = 25, hold_print_line = print_line
    WHILE (print_cnt > 0
     AND substring(print_cnt,1,print_line)=" ")
      print_cnt = (print_cnt - 1)
    ENDWHILE
    WHILE (str_cnt > 0
     AND substring(str_cnt,1,print_field)=" ")
      str_cnt = (str_cnt - 1)
    ENDWHILE
    str_cnt = (str_cnt+ 1), hold_print_line = concat(substring(1,print_cnt,print_line),substring(1,
      str_cnt,print_field)), print_line = hold_print_line
   ENDMACRO
   ,
   MACRO (print_overlay)
    "{f/0/1}{cpi/14^}{lpi/8}", row + 1, "{color/31/1}",
    "{pos/065/20}{box/093/5/1}", row + 1, "{color/30/1}",
    "{pos/095/74}{box/080/3/1}", row + 1, "{color/31/1}",
    "{pos/095/74}{box/080/3/1}", row + 1, "{color/30/1}",
    "{pos/035/120}{box/103/1/1}", row + 1, "{color/31/1}",
    "{pos/035/120}{box/103/1/1}", row + 1
    IF (last_page="Y")
     "{color/31/1}", "{pos/035/120}{box/19/61/1}", row + 1,
     "{pos/138/120}{box/19/61/1}", row + 1, "{pos/241/120}{box/19/61/1}",
     row + 1, "{pos/344/120}{box/14/61/1}", row + 1,
     "{pos/421/120}{box/16/61/1}", row + 1, "{pos/508/120}{box/11/61/1}",
     row + 1, "{color/31/1}", "{pos/065/690}{box/093/5/1}",
     row + 1
    ELSE
     "{color/31/1}", "{pos/035/120}{box/19/68/1}", row + 1,
     "{pos/138/120}{box/19/68/1}", row + 1, "{pos/241/120}{box/19/68/1}",
     row + 1, "{pos/344/120}{box/14/68/1}", row + 1,
     "{pos/421/120}{box/16/68/1}", row + 1, "{pos/508/120}{box/11/68/1}",
     row + 1
    ENDIF
    "{f/5/1}{cpi/5^}{lpi/3}", "{pos/000/10}", row + 1,
    col 31, "Outstanding Orders", row + 1,
    "{pos/000/42}", "{f/6/1}{cpi/8^}{lpi/6}", row + 1,
    col 39, "Incomplete Orders Placed Over ", request->hours_since"####;c",
    " Hours Ago", row + 1, col 46,
    "As of ", days_back"mmmmmmmmm dd, yyyy;;d", " @ ",
    cur_time = fillstring(05," ")
    IF (hour(hours_back)=12)
     cur_time = format(hours_back,"##:##;p0"), cur_time, " p.m."
    ELSE
     IF (hour(hours_back)=24)
      cur_time = format(build((hour(hours_back) - 12),minute(hours_back)),"##:##;p0"), cur_time,
      " a.m."
     ELSE
      IF (hour(hours_back) < 12)
       cur_time = format(hours_back,"##:##;p0"), cur_time, " a.m."
      ELSE
       cur_time = format(build(format((hour(hours_back) - 12),"##;p0"),format(minute(hours_back),
          "##;p0")),"##:##;p0"), cur_time, " p.m."
      ENDIF
     ENDIF
    ENDIF
    row + 1
    IF (last_page="Y")
     "{f/5/1}{cpi/10^}{lpi/6}", "{pos/001/690}", row + 1,
     col 22, "Summary Statistics", row + 1
    ENDIF
    "{f/0/1}{cpi/16^}{lpi/6}", row + 1, "{pos/000/067}",
    row + 1, col 20, "Organization:   ",
    org_name, col 70, "Physicians:       "
    IF ((request->ordering_physician="\*"))
     "All"
    ELSE
     request->ordering_physician
    ENDIF
    row + 1, col 20, "Test Category:  "
    IF ((request->test_category[1].test_category_meaning="\*"))
     "All"
    ELSE
     print_line = fillstring(50," "), print_field = trim(request->test_category[1].
      test_category_meaning), build_report_line
     FOR (index = 2 TO value(size(request->test_category,5)))
      print_field = concat(", ",trim(request->test_category[index].test_category_meaning)),
      build_report_line
     ENDFOR
     print_line
    ENDIF
    col 69, " Service Provider: "
    IF ((request->service_provider="\*"))
     "All"
    ELSE
     request->service_provider
    ENDIF
    row + 1, col 20, "Date Range:     ",
    days_back"mm/dd/yy;;d", " - ", curdate"mm/dd/yy;;d",
    col 70, "Priority:         "
    IF ((request->priority_type[1].priority_type_meaning="\*"))
     "All"
    ELSE
     print_line = fillstring(50," "), print_field = trim(request->priority_type[1].
      priority_type_meaning), build_report_line
     FOR (index = 2 TO value(size(request->priority_type,5)))
      print_field = concat(", ",trim(request->priority_type[index].priority_type_meaning)),
      build_report_line
     ENDFOR
     print_line
    ENDIF
    row + 1, "{pos/000/115}", row + 1,
    col 007, "Ordering Physician", col 032,
    "Patient Name", col 053, "Service Provider",
    col 077, "Test Name", col 092,
    "Date/Time Ordered", col 113, "Priority",
    row + 1, "{pos/000/131}", row + 1
   ENDMACRO
   ,
   MACRO (print_footer)
    IF (last_page="Y")
     "{pos/000/705}", row + 1, col 029,
     "Total Number of Outstanding Orders:"
     IF (total_orders > 0)
      col 070, total_orders"#####;l"
     ELSE
      col 070, "0"
     ENDIF
     row + 1, col 029, "Average Overdue Time (Hours):",
     hour_average = (total_hours_old/ total_orders), col 070, hour_average"#####;l",
     row + 1
    ENDIF
    "{pos/000/740}", row + 1, cur_date = format(curdate,"mm/dd/yy;;d"),
    col 14, cur_date, " - "
    IF (hour(curtime)=12)
     cur_time = format(curtime,"##:##;p0"), cur_time, " PM"
    ELSE
     IF (hour(curtime)=24)
      cur_time = format((curtime - 1200),"##:##;p0"), cur_time, " AM"
     ELSE
      IF (hour(curtime) < 12)
       cur_time = format(curtime,"##:##;p0"), cur_time, " AM"
      ELSE
       cur_time = format((curtime - 1200),"##:##;p0"), cur_time, " PM"
      ENDIF
     ENDIF
    ENDIF
    col 100, "Page  ", page_nbr"###;c",
    " of ", total_page"###;c"
    IF (page_nbr < total_page)
     col 58, "(continued)"
    ELSE
     col 58, "(end of report)"
    ENDIF
    row + 1, page_nbr = (page_nbr+ 1)
   ENDMACRO
   ,
   MACRO (find_total_page)
    total_page = 0, total_extra = 0, hold_total_orders = 0,
    total_orders = value(size(reply->out_orders,5)), hold_total_orders = (total_orders+
    nbr_physicians)
    WHILE (hold_total_orders >= 50)
     hold_total_orders = (hold_total_orders - 50),total_page = (total_page+ 1)
    ENDWHILE
    IF (((hold_total_orders > 45) OR (hold_total_orders=0))
     AND total_orders != 0)
     stat = alterlist(reply->out_orders,(total_orders+ 10))
     FOR (i = (total_orders+ 1) TO (total_orders+ 10))
      reply->out_orders[i].physician = "zzzzzzzzzz",reply->out_orders[i].order_id = 9999999999
     ENDFOR
     total_page = 0, total_orders = (value(size(reply->out_orders,5)) - 1), hold_total_orders = (
     total_orders+ nbr_physicians)
     WHILE (hold_total_orders >= 50)
      hold_total_orders = (hold_total_orders - 50),total_page = (total_page+ 1)
     ENDWHILE
    ENDIF
    IF (hold_total_orders > 0)
     total_page = (total_page+ (hold_total_orders/ 45)), total_extra = mod(hold_total_orders,45)
    ENDIF
    IF (((total_extra > 0) OR (total_page=0)) )
     total_page = (total_page+ 1)
    ENDIF
   ENDMACRO
   , find_total_page,
   page_nbr = 1, last_page = fillstring(01,"Y"), page_break = fillstring(01,"N")
  HEAD PAGE
   row_count = 0
   IF (page_nbr=total_page)
    last_page = "Y", max_row = 45
   ELSE
    last_page = "N", max_row = 50
   ENDIF
   print_overlay
  DETAIL
   IF (value(size(reply->out_orders,5)) > 0)
    IF ((reply->out_orders[d.seq].physician != "zzzzzzzzzz"))
     IF ((hold_physician != reply->out_orders[d.seq].physician))
      IF (hold_physician > " "
       AND page_break="N")
       "{hb/119/6}", row + 1, row_count = (row_count+ 1)
      ENDIF
      hold_physician = reply->out_orders[d.seq].physician, hold_patient = fillstring(25," "),
      hold_provider = fillstring(25," "),
      col 006, reply->out_orders[d.seq].physician
     ELSEIF (page_break="Y")
      col 006, reply->out_orders[d.seq].physician
     ENDIF
     IF ((hold_patient != reply->out_orders[d.seq].patient))
      hold_patient = reply->out_orders[d.seq].patient, hold_provider = fillstring(25," "), col 029,
      reply->out_orders[d.seq].patient
     ELSEIF (page_break="Y")
      col 029, reply->out_orders[d.seq].patient
     ENDIF
     col 052, reply->out_orders[d.seq].provider, col 075,
     reply->out_orders[d.seq].test_name, col 093, reply->out_orders[d.seq].ordered_dt_tm
     "mm/dd/yy  hh:mm;;q",
     col 112, reply->out_orders[d.seq].priority, row_count = (row_count+ 1),
     row + 1
     IF (physician != "zzzzzzzzzz")
      order_hours_old = 0, days_old = 0, hours_old = 0,
      minutes_old = 0, hours_extra = 0
      IF (curdate > cnvtdate(ordered_dt_tm))
       days_old = (curdate - cnvtdate(ordered_dt_tm))
      ENDIF
      IF (curtime > cnvtint(format(ordered_dt_tm,"hhmm;;m")))
       hours_old = (hour(curtime) - cnvtint(format(ordered_dt_tm,"hh;;m")))
      ELSE
       days_old = (days_old - 1), hours_old = (24 - (hour(cnvtint(format(ordered_dt_tm,"hhmm;;m")))
        - hour(curtime)))
      ENDIF
      IF (minute(curtime) < minute(cnvtint(format(ordered_dt_tm,"hhmm;;m"))))
       hours_old = (hours_old - 1), minutes_old = (minute(cnvtint(format(ordered_dt_tm,"hhmm;;m")))
        - minute(curtime))
       IF (minutes_old <= 30)
        hours_extra = 1
       ENDIF
      ENDIF
      order_hours_old = (((days_old * 24)+ hours_old)+ hours_extra), total_hours_old = (
      total_hours_old+ order_hours_old)
      IF (row_count >= max_row)
       print_footer, BREAK, page_break = "Y"
      ELSE
       page_break = "N"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   print_footer
  WITH check, nocounter, nullreport,
   maxrow = 90, maxcol = 150, dio = postscript
 ;end select
 SET reply->status_data.status = "S"
 SET reply->output_file = concat("ccluserdir:",trim(request->output_file),".dat")
 SET reply->format_type = "application/postscript"
 SET reply->node = curnode
 SET cps_script_v = "002 06/13/03 SF3151"
END GO
