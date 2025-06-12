CREATE PROGRAM cdi_rpt_qc_prod_drvr:dba
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
  m.username, b.startdatetime"@SHORTDATE;;D", f.completeddocs,
  f.completedpages
  FROM cdi_ac_batchmodule b,
   cdi_ac_module_launch m,
   cdi_ac_formtype f
  PLAN (b
   WHERE b.startdatetime >= cnvtdatetime(cnvtdate(vcstartdate),0)
    AND b.startdatetime <= cnvtdatetime(cnvtdate(vcenddate),235959))
   JOIN (m
   WHERE m.modulelaunchid=b.modulelaunchid
    AND cnvtupper(m.modulename)="QUALITY CONTROL")
   JOIN (f
   WHERE f.batchmoduleid=b.batchmoduleid)
  ORDER BY m.username
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD m.username
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].username = m.username
  DETAIL
   batch_lyt->batch_details[row_cnt].processeddocs = (f.completeddocs+ batch_lyt->batch_details[
   row_cnt].processeddocs), batch_lyt->batch_details[row_cnt].processedpages = (f.completedpages+
   batch_lyt->batch_details[row_cnt].processedpages), batch_lyt->totalprocesseddocs = (f
   .completeddocs+ batch_lyt->totalprocesseddocs),
   batch_lyt->totalprocessedpages = (f.completedpages+ batch_lyt->totalprocessedpages)
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
