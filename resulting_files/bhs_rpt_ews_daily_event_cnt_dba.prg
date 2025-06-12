CREATE PROGRAM bhs_rpt_ews_daily_event_cnt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD cnt1(
   1 avg = f8
   1 qual[*]
     2 encntr_id = f8
     2 cnt = i4
 )
 DECLARE tot = f8
 DECLARE cnt = i4
 SELECT INTO "NL:"
  encntr_id, b.insert_dt_tm
  FROM bhs_early_warning b
  WHERE b.insert_dt_tm >= cnvtdatetime((curdate - 2),0)
   AND b.insert_dt_tm <= cnvtdatetime((curdate - 1),0)
  ORDER BY b.encntr_id, b.insert_dt_tm DESC
  HEAD b.encntr_id
   cnt = (cnt+ 1), stat = alterlist(cnt1->qual,cnt), cnt1->qual[cnt].encntr_id = b.encntr_id
  HEAD b.insert_dt_tm
   cnt1->qual[cnt].cnt = (cnt1->qual[cnt].cnt+ 1), tot = (tot+ 1)
  WITH nocounter
 ;end select
 SET cnt1->avg = (tot/ cnt)
 SELECT INTO  $OUTDEV
  avg = cnt1->avg, encntr = cnt1->qual[d.seq].encntr_id, cnt = cnt1->qual[d.seq].cnt
  FROM (dummyt d  WITH seq = cnt)
  PLAN (d)
  WITH format, separator = " "
 ;end select
END GO
