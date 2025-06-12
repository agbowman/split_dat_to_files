CREATE PROGRAM cdi_rpt_daily_prod_drvr:dba
 PROMPT
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH begindate, enddate
 DECLARE vcstartdate = vc WITH noconstant(""), protect
 DECLARE vcenddate = vc WITH noconstant(""), protect
 SET vcstartdate = build(substring(1,2, $BEGINDATE),substring(4,2, $BEGINDATE),substring(7,2,
    $BEGINDATE))
 SET vcenddate = build(substring(1,2, $ENDDATE),substring(4,2, $ENDDATE),substring(7,2, $ENDDATE))
 SELECT INTO "nl:"
  b.startdatetime"@SHORTDATE;;D", b.documentscreated, b.pagesscanned
  FROM cdi_ac_batchmodule b
  WHERE b.startdatetime >= cnvtdatetime(cnvtdate(vcstartdate),0)
   AND b.startdatetime <= cnvtdatetime(cnvtdate(vcenddate),235959)
  ORDER BY b.startdatetime
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD b.startdatetime
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].startdatetime = b.startdatetime, batch_lyt->batch_details[
   row_cnt].documentscreated = 0, batch_lyt->batch_details[row_cnt].pagesscanned = 0
  DETAIL
   batch_lyt->batch_details[row_cnt].documentscreated = (b.documentscreated+ batch_lyt->
   batch_details[row_cnt].documentscreated), batch_lyt->batch_details[row_cnt].pagesscanned = (b
   .pagesscanned+ batch_lyt->batch_details[row_cnt].pagesscanned)
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
