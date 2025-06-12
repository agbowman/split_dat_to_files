CREATE PROGRAM bhs_ops_disch_stats_medsurgped
 SET action_dt_tm = datetimeadd(sysdate,- (25))
 SET beg_date = cnvtdatetime(cnvtdate(10012008),0)
 SET end_date = cnvtdatetime(cnvtdate(10012009),0)
 EXECUTE bhs_rpt_disch_order_stats_v2 "medsurgpeds_stats_worksheet", "naser.sanjar@bhs.org", value(
  beg_date),
 value(end_date), "bhscust:medsurgpedlist.txt ", 0
END GO
