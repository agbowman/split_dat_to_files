CREATE PROGRAM bhs_rpt_amb_dt_ops
 EXECUTE bhs_rptamb "MINE", "zb361cntr1m20", cnvtdatetime2(curdate,0),
 cnvtdatetime2(curdate,235959), 59804587.0, 59821631.0
END GO
