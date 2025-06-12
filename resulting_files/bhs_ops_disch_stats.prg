CREATE PROGRAM bhs_ops_disch_stats
 SET action_dt_tm = datetimeadd(sysdate,- (25))
 SET beg_date = datetimefind(action_dt_tm,"M","B","B")
 SET end_date = datetimefind(action_dt_tm,"M","E","E")
 EXECUTE bhs_rpt_disch_order_stats_v2 "ahmp_stats_worksheet",
 "donna.borah@bhs.org;naser.sanjar@bhs.org;Mariellen.Szczebak@baystatehealth.org", value(beg_date),
 value(end_date), "AHMP", 0
 EXECUTE bhs_rpt_disch_order_stats_v2 "chmp_stats_worksheet",
 "donna.borah@bhs.org;naser.sanjar@bhs.org;Mariellen.Szczebak@baystatehealth.org", value(beg_date),
 value(end_date), "CHMP", 0
END GO
