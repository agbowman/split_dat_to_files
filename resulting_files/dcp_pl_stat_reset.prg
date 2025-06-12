CREATE PROGRAM dcp_pl_stat_reset
 DELETE  FROM dcp_pl_statistics stat
  WHERE 1=1
  WITH nocounter
 ;end delete
 COMMIT
END GO
