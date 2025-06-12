CREATE PROGRAM cdi_rpt_scan_del_by_user_drvr:dba
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
  m.username, b.pagesscanned, b.pagesdeleted,
  b.startdatetime"@SHORTDATE;;D"
  FROM cdi_ac_batchmodule b,
   cdi_ac_module_launch m
  PLAN (b
   WHERE b.startdatetime BETWEEN cnvtdatetime(cnvtdate(vcstartdate),0) AND cnvtdatetime(cnvtdate(
     vcenddate),235959))
   JOIN (m
   WHERE m.modulelaunchid=b.modulelaunchid)
  ORDER BY m.username, b.startdatetime
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD m.username
   row_cnt = row_cnt
  HEAD b.startdatetime
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].username = m.username, batch_lyt->batch_details[row_cnt].
   startdatetime = b.startdatetime
  DETAIL
   batch_lyt->batch_details[row_cnt].pagesscanned = (b.pagesscanned+ batch_lyt->batch_details[row_cnt
   ].pagesscanned), batch_lyt->batch_details[row_cnt].pagesdeleted = (b.pagesdeleted+ batch_lyt->
   batch_details[row_cnt].pagesdeleted)
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
