CREATE PROGRAM db_backup_stats_del:dba
 DELETE  FROM dba_bkup_stats_beg
  WHERE 1=1
 ;end delete
 DELETE  FROM dba_bkup_stats_end
  WHERE 1=1
 ;end delete
 DELETE  FROM dba_bkup_stats
  WHERE 1=1
 ;end delete
 COMMIT
END GO
