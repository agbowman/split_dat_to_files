CREATE PROGRAM cdi_rpt_prod_by_user_drvr:dba
 PROMPT
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "User Name" = ""
  WITH begindate, enddate, username
 DECLARE vcstartdate = vc WITH noconstant(""), protect
 DECLARE vcenddate = vc WITH noconstant(""), protect
 SET vcstartdate = build(substring(1,2, $BEGINDATE),substring(4,2, $BEGINDATE),substring(7,2,
    $BEGINDATE))
 SET vcenddate = build(substring(1,2, $ENDDATE),substring(4,2, $ENDDATE),substring(7,2, $ENDDATE))
 SELECT INTO "nl:"
  m.username, b.startdatetime"@SHORTDATE", m.modulename,
  f.documents, f.pages
  FROM cdi_ac_module_launch m,
   cdi_ac_batchmodule b,
   cdi_ac_formtype f
  PLAN (m
   WHERE cnvtupper(m.username)=cnvtupper( $USERNAME))
   JOIN (b
   WHERE m.modulelaunchid=b.modulelaunchid
    AND b.startdatetime >= cnvtdatetime(cnvtdate(vcstartdate),0)
    AND b.startdatetime <= cnvtdatetime(cnvtdate(vcenddate),235959))
   JOIN (f
   WHERE f.batchmoduleid=b.batchmoduleid)
  ORDER BY b.startdatetime, m.modulename
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD b.startdatetime
   row_cnt = row_cnt
  HEAD m.modulename
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].modulename = trim(m.modulename), batch_lyt->batch_details[
   row_cnt].startdate = cnvtdate(b.startdatetime,"@SHORTDATE")
  DETAIL
   batch_lyt->batch_details[row_cnt].documents = (f.documents+ batch_lyt->batch_details[row_cnt].
   documents), batch_lyt->batch_details[row_cnt].pages = (f.pages+ batch_lyt->batch_details[row_cnt].
   pages)
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
