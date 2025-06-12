CREATE PROGRAM afc_rpt_audit_spec_coll:dba
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
 RECORD specs(
   1 spec_qual = i4
   1 specs[*]
     2 specimen_id = f8
     2 specimen_type_cd = f8
     2 drawn_dt_tm = dq8
     2 collection_method_cd = f8
     2 order_id = f8
     2 order_mnemonic = c25
     2 orig_order_dt_tm = dq8
     2 person_id = f8
     2 person_name = c25
     2 activity_type_cd = f8
     2 activity_type_disp = c20
     2 accession = c18
     2 order_status_cd = f8
     2 collected_flag = i2
     2 charge_event_id = f8
     2 ce_ordered_flag = i2
     2 ce_collected_flag = i2
     2 ce_completed_flag = i2
 )
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 13029
 SET code_value = 0.0
 SET cdf_meaning = "COLLECTED"
 EXECUTE cpm_get_cd_for_cdf
 SET ce_collected = code_value
 SET count1 = 0
 SET lastspecid = 0.0
 SELECT INTO "nl:"
  s.specimen_id, s.specimen_type_cd, s.collection_method_cd,
  s.drawn_dt_tm, o.order_id, o.person_id,
  o.order_mnemonic, o.orig_order_dt_tm, o.activity_type_cd,
  o.order_status_cd, cv.display
  FROM v500_specimen s,
   container c,
   order_container_r ocr,
   orders o,
   code_value cv
  PLAN (s
   WHERE s.drawn_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate))
   JOIN (c
   WHERE c.specimen_id=s.specimen_id)
   JOIN (ocr
   WHERE ocr.container_id=c.container_id)
   JOIN (o
   WHERE o.order_id=ocr.order_id)
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
  DETAIL
   IF (lastspecid != s.specimen_id)
    lastspecid = s.specimen_id, count1 = (count1+ 1), stat = alterlist(specs->specs,count1),
    specs->specs[count1].specimen_id = s.specimen_id, specs->specs[count1].specimen_type_cd = s
    .specimen_type_cd, specs->specs[count1].drawn_dt_tm = s.drawn_dt_tm,
    specs->specs[count1].collection_method_cd = c.collection_method_cd, specs->specs[count1].order_id
     = o.order_id, specs->specs[count1].order_mnemonic = o.order_mnemonic,
    specs->specs[count1].orig_order_dt_tm = o.orig_order_dt_tm, specs->specs[count1].person_id = o
    .person_id, specs->specs[count1].activity_type_cd = o.activity_type_cd,
    specs->specs[count1].activity_type_disp = cv.display, specs->specs[count1].order_status_cd = o
    .order_status_cd, specs->specs[count1].collected_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SET specs->spec_qual = count1
 CALL text(8,10,"spec_qual: ")
 CALL text(8,22,cnvtstring(specs->spec_qual))
 SELECT INTO "nl:"
  cea.charge_event_act_id, specs->specs[d1.seq].specimen_id
  FROM (dummyt d1  WITH seq = value(specs->spec_qual)),
   charge_event c,
   charge_event_act cea
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1))
   JOIN (c
   WHERE (c.ext_m_event_id=specs->specs[d1.seq].specimen_id)
    AND (c.ext_i_reference_id=specs->specs[d1.seq].collection_method_cd))
   JOIN (cea
   WHERE cea.charge_event_id=c.charge_event_id
    AND cea.cea_type_cd=ce_collected)
  DETAIL
   IF (cea.charge_event_act_id != 0)
    specs->specs[d1.seq].ce_collected_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SET dashline = fillstring(130,"-")
 CALL text(9,10,"Retrieving Patient Info...")
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(specs->spec_qual)),
   person p
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1)
    AND (specs->specs[d1.seq].ce_collected_flag=0))
   JOIN (p
   WHERE (p.person_id=specs->specs[d1.seq].person_id))
  DETAIL
   specs->specs[d1.seq].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL text(10,10,"Retrieving Accession Numbers...")
 SELECT INTO "nl:"
  a.accession
  FROM (dummyt d1  WITH seq = value(specs->spec_qual)),
   accession_order_r r,
   accession a
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1)
    AND (specs->specs[d1.seq].ce_collected_flag=0))
   JOIN (r
   WHERE (r.order_id=specs->specs[d1.seq].order_id))
   JOIN (a
   WHERE a.accession_id=r.accession_id)
  DETAIL
   specs->specs[d1.seq].accession = a.accession
  WITH nocounter
 ;end select
 CALL text(11,10,"Preparing Report...")
 SET ordercol = 17
 SET ceacol = 24
 SET labelcol = 5
 SET qualcnt = 0
 SELECT
  dt = format(specs->specs[d1.seq].drawn_dt_tm,"dd-mmm-yyyy;;D"), tm = format(specs->specs[d1.seq].
   drawn_dt_tm,"HHMM;;M")
  FROM (dummyt d1  WITH seq = value(specs->spec_qual))
  PLAN (d1
   WHERE (specs->specs[d1.seq].collected_flag=1)
    AND (specs->specs[d1.seq].ce_collected_flag=0))
  ORDER BY specs->specs[d1.seq].person_id
  HEAD REPORT
   col 01, "Date: ", col 10,
   curdate, col 20, curtime,
   col 45, " ** Specimen Collection Exception Report ** ", row + 1
  HEAD PAGE
   row + 1, col 01, "Spec Id",
   col 10, "Date", col 30,
   "Order Mnemonic", col 60, "Activity Type",
   col 80, "Accession", col 100,
   "Person Name", row + 1, col 01,
   dashline, row + 1
  DETAIL
   col 01, specs->specs[d1.seq].specimen_id"########", col 10,
   dt, col 22, tm,
   col 30, specs->specs[d1.seq].order_mnemonic, col 60,
   specs->specs[d1.seq].activity_type_disp, col 80, specs->specs[d1.seq].accession,
   col 100, specs->specs[d1.seq].person_name, row + 1,
   col ordercol, "SPEC", col ceacol,
   "CEA", row + 1, col labelcol,
   "Collected: ", call reportmove('COL',(ordercol+ 2),0), specs->specs[d1.seq].collected_flag"#",
   call reportmove('COL',(ceacol+ 1),0), specs->specs[d1.seq].ce_collected_flag"#", row + 2,
   qualcnt = (qualcnt+ 1)
  FOOT PAGE
   col 100, "Page:", col 110,
   curpage
  FOOT REPORT
   col 01, "Qualifying Records: ", col 25,
   qualcnt"########"
  WITH nocounter
 ;end select
 FREE SET specs
END GO
