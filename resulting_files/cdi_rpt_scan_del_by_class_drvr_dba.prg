CREATE PROGRAM cdi_rpt_scan_del_by_class_drvr:dba
 PROMPT
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Batch Class" = ""
  WITH begindate, enddate, batchclass
 DECLARE vcstartdate = vc WITH noconstant(""), protect
 DECLARE vcenddate = vc WITH noconstant(""), protect
 SET vcstartdate = build(substring(1,2, $BEGINDATE),substring(4,2, $BEGINDATE),substring(7,2,
    $BEGINDATE))
 SET vcenddate = build(substring(1,2, $ENDDATE),substring(4,2, $ENDDATE),substring(7,2, $ENDDATE))
 SELECT INTO "nl:"
  l.username, m.pagesscanned, m.pagesdeleted,
  m.startdatetime"@SHORTDATE;;D"
  FROM cdi_ac_batch b,
   cdi_ac_batchmodule m,
   cdi_ac_module_launch l
  PLAN (b
   WHERE cnvtupper(b.batchclass)=cnvtupper( $BATCHCLASS))
   JOIN (m
   WHERE b.cdi_ac_batch_id=m.cdi_ac_batch_id
    AND b.cdi_ac_batch_id != 0
    AND m.startdatetime >= cnvtdatetime(cnvtdate(vcstartdate),0)
    AND m.startdatetime <= cnvtdatetime(cnvtdate(vcenddate),235959))
   JOIN (l
   WHERE l.modulelaunchid=m.modulelaunchid)
  ORDER BY l.username, m.startdatetime
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD l.username
   row_cnt = row_cnt
  HEAD m.startdatetime
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].username = l.username, batch_lyt->batch_details[row_cnt].
   startdatetime = m.startdatetime
  DETAIL
   batch_lyt->batch_details[row_cnt].pagesscanned = (m.pagesscanned+ batch_lyt->batch_details[row_cnt
   ].pagesscanned), batch_lyt->batch_details[row_cnt].pagesdeleted = (m.pagesdeleted+ batch_lyt->
   batch_details[row_cnt].pagesdeleted)
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
