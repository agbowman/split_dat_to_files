CREATE PROGRAM afc_rpt_audit_mic_results:dba
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
 RECORD results(
   1 result_qual = i4
   1 results[*]
     2 order_id = f8
     2 order_mnem = c15
     2 result_id = f8
     2 mnemonic = c15
     2 perform_dt_tm = dq8
     2 person_id = f8
     2 person_name = c25
     2 activity_type_cd = f8
     2 activity_type_disp = c15
     2 accession = c18
     2 result_status_cd = f8
     2 perform_result_status_cd = f8
     2 performed_flag = i2
     2 ordered_flag = i2
     2 verified_flag = i2
     2 charge_event_id = f8
     2 ce_performed_flag = i2
     2 ce_ordered_flag = i2
     2 ce_verified_flag = i2
 )
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 1901
 SET code_value = 0.0
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET result_verified = code_value
 SET code_set = 13029
 SET code_value = 0.0
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET ce_verified = code_value
 SET code_set = 1901
 SET code_value = 0.0
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET result_ordered = code_value
 SET code_set = 13029
 SET code_value = 0.0
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ce_ordered = code_value
 SET count1 = 0
 SELECT INTO "nl:"
  r.order_id, r.task_log_id, r.task_status_cd,
  o.person_id, o.order_mnemonic, m.mnemonic,
  o.activity_type_cd, cv.display
  FROM mic_task_log r,
   mic_task m,
   orders o,
   code_value cv
  PLAN (r
   WHERE r.task_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND ((r.task_class_flag=3
    AND r.task_type_flag=3) OR (((r.task_class_flag=4
    AND r.task_type_flag=5) OR (r.task_class_flag=5
    AND r.task_type_flag=1)) )) )
   JOIN (m
   WHERE m.task_assay_cd=r.task_cd)
   JOIN (o
   WHERE o.order_id=r.order_id)
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(results->results,count1), results->results[count1].order_id
    = r.order_id,
   results->results[count1].order_mnem = o.order_mnemonic, results->results[count1].result_id = r
   .task_log_id, results->results[count1].mnemonic = m.mnemonic,
   results->results[count1].perform_dt_tm = r.task_dt_tm, results->results[count1].person_id = o
   .person_id, results->results[count1].activity_type_cd = o.activity_type_cd,
   results->results[count1].activity_type_disp = cv.display, results->results[count1].
   result_status_cd = r.task_status_cd, results->results[count1].verified_flag =
   IF ((results->results[count1].result_status_cd=result_verified)) 1
   ENDIF
   ,
   results->results[count1].ordered_flag =
   IF ((results->results[count1].result_status_cd=result_ordered)
    AND r.task_class_flag=4
    AND r.task_type_flag=5) 1
   ENDIF
  WITH nocounter
 ;end select
 SET results->result_qual = count1
 CALL text(8,10,"result_qual: ")
 CALL text(8,23,cnvtstring(results->result_qual))
 SELECT INTO "nl:"
  cea.charge_event_act_id
  FROM (dummyt d1  WITH seq = value(results->result_qual)),
   charge_event c,
   charge_event_act cea
  PLAN (d1
   WHERE (((results->results[d1.seq].verified_flag=1)) OR ((results->results[d1.seq].ordered_flag=1)
   )) )
   JOIN (c
   WHERE (c.ext_m_event_id=results->results[d1.seq].order_id)
    AND (c.ext_i_event_id=results->results[d1.seq].result_id))
   JOIN (cea
   WHERE cea.charge_event_id=c.charge_event_id
    AND ((cea.cea_type_cd=ce_verified) OR (cea.cea_type_cd=ce_ordered)) )
  DETAIL
   IF (cea.cea_type_cd=ce_verified
    AND cea.charge_event_act_id != 0)
    results->results[d1.seq].ce_verified_flag = 1
   ENDIF
   IF (cea.cea_type_cd=ce_ordered
    AND cea.charge_event_act_id != 0)
    results->results[d1.seq].ce_ordered_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SET dashline = fillstring(130,"-")
 CALL text(9,10,"Retrieving Patient Info...")
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(results->result_qual)),
   person p
  PLAN (d1
   WHERE (((results->results[d1.seq].verified_flag=1)
    AND (results->results[d1.seq].ce_verified_flag=0)) OR ((results->results[d1.seq].ordered_flag=1)
    AND (results->results[d1.seq].ce_ordered_flag=0))) )
   JOIN (p
   WHERE (p.person_id=results->results[d1.seq].person_id))
  DETAIL
   results->results[d1.seq].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL text(10,10,"Retrieving Accession Numbers...")
 SELECT INTO "nl:"
  a.accession
  FROM (dummyt d1  WITH seq = value(results->result_qual)),
   accession_order_r r,
   accession a
  PLAN (d1
   WHERE (((results->results[d1.seq].verified_flag=1)
    AND (results->results[d1.seq].ce_verified_flag=0)) OR ((results->results[d1.seq].ordered_flag=1)
    AND (results->results[d1.seq].ce_ordered_flag=0))) )
   JOIN (r
   WHERE (r.order_id=results->results[d1.seq].order_id))
   JOIN (a
   WHERE a.accession_id=r.accession_id)
  DETAIL
   results->results[d1.seq].accession = a.accession
  WITH nocounter
 ;end select
 CALL text(11,10,"Preparing Report...")
 SET ordercol = 17
 SET ceacol = 24
 SET labelcol = 5
 SET qualcnt = 0
 SELECT
  dt = format(results->results[d1.seq].perform_dt_tm,"ddmmmYYyy;;D"), tm = format(results->results[d1
   .seq].perform_dt_tm,"HHMM;;M")
  FROM (dummyt d1  WITH seq = value(results->result_qual))
  PLAN (d1
   WHERE (((results->results[d1.seq].verified_flag=1)
    AND (results->results[d1.seq].ce_verified_flag=0)) OR ((results->results[d1.seq].ordered_flag=1)
    AND (results->results[d1.seq].ce_ordered_flag=0))) )
  ORDER BY results->results[d1.seq].mnemonic, results->results[d1.seq].perform_dt_tm
  HEAD REPORT
   col 40, " ** Microbiology Results Charge Event Exception Report ** ", row + 1
  HEAD PAGE
   col 01, "Date: ", col 10,
   curdate, col 20, curtime,
   row + 1, col 100, "Page:",
   col 110, curpage, row + 1,
   col 01, "Ord Id", col 10,
   "Res Id", col 19, "Date/Time",
   col 34, "Order Mnem", col 51,
   "Mnem", col 68, "Activity Type",
   col 85, "Accession", col 105,
   "Person Name", row + 1, col 01,
   dashline, row + 1
  DETAIL
   col 01, results->results[d1.seq].order_id"########", col 10,
   results->results[d1.seq].result_id"########", col 19, dt,
   col 29, tm, col 34,
   results->results[d1.seq].order_mnem, col 51, results->results[d1.seq].mnemonic,
   col 68, results->results[d1.seq].activity_type_disp, col 85,
   results->results[d1.seq].accession, col 105, results->results[d1.seq].person_name,
   row + 1, col ordercol, "RESULT",
   col ceacol, "CEA"
   IF ((results->results[d1.seq].ordered_flag=1))
    row + 1, col labelcol, "Ordered: ",
    call reportmove('COL',(ordercol+ 2),0), results->results[d1.seq].ordered_flag"#",
    call reportmove('COL',(ceacol+ 1),0),
    results->results[d1.seq].ce_ordered_flag"#"
   ENDIF
   IF ((results->results[d1.seq].verified_flag=1))
    row + 1, col labelcol, "Verified: ",
    call reportmove('COL',(ordercol+ 2),0), results->results[d1.seq].verified_flag"#",
    call reportmove('COL',(ceacol+ 1),0),
    results->results[d1.seq].ce_verified_flag"#"
   ENDIF
   row + 2, qualcnt = (qualcnt+ 1)
  FOOT REPORT
   col 01, "Records Qualified: ", col 25,
   qualcnt"########"
  WITH nocounter
 ;end select
 FREE SET results
END GO
