CREATE PROGRAM cdi_rpt_module_access_drvr:dba
 PROMPT
  "Date" = "SYSDATE"
  WITH begindate
 DECLARE vcstartdate = vc WITH noconstant(""), protect
 DECLARE currentdt = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 SET vcstartdate = build(substring(1,2, $BEGINDATE),substring(4,2, $BEGINDATE),substring(7,2,
    $BEGINDATE))
 SELECT INTO "nl:"
  m.username, m.modulename, m.startdatetime,
  m.enddatetime
  FROM cdi_ac_module_launch m
  WHERE m.startdatetime >= cnvtdatetime(cnvtdate(vcstartdate),0)
   AND m.startdatetime <= cnvtdatetime(cnvtdate(vcstartdate),235959)
  ORDER BY m.username, m.modulename
  HEAD REPORT
   row_cnt = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD m.username
   row_cnt = row_cnt
  HEAD m.modulename
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].username = m.username, batch_lyt->batch_details[row_cnt].
   modulename = m.modulename, batch_lyt->batch_details[row_cnt].totaltime = 0,
   batch_lyt->batch_details[row_cnt].accesscount = 0
  DETAIL
   IF (m.enddatetime > cnvtdatetime(curdate,curtime))
    batch_lyt->batch_details[row_cnt].totaltime = (datetimediff(cnvtdatetime(curdate,curtime),m
     .startdatetime,5)+ batch_lyt->batch_details[row_cnt].totaltime)
   ELSE
    batch_lyt->batch_details[row_cnt].totaltime = (datetimediff(m.enddatetime,m.startdatetime,5)+
    batch_lyt->batch_details[row_cnt].totaltime)
   ENDIF
   batch_lyt->batch_details[row_cnt].accesscount = (1+ batch_lyt->batch_details[row_cnt].accesscount)
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
