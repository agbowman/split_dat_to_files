CREATE PROGRAM dba_mod6_db_ver
 SET old_dbver = request->old_dbver
 SET t_size = 0.0
 SET cr_size = 0.0
 SET mcore_size = 0.0
 SELECT INTO "nl:"
  sum_fsize = sum(d.file_size)
  FROM dm_size_db_ts d
  WHERE d.db_version=old_dbver
  GROUP BY d.db_version
  DETAIL
   t_size = sum_fsize, col 5, t_size
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sum_fsize = (c.file_size+ r.log_size), c.*, r.*
  FROM dm_size_db_redo_logs r,
   dm_size_db_cntl_files c
  WHERE c.db_version=old_dbver
   AND r.db_version=old_dbver
  DETAIL
   cr_size = sum_fsize, col 5, cr_size
  WITH nocounter
 ;end select
 SET mcore_size = (t_size+ cr_size)
 UPDATE  FROM dm_size_db_version d
  SET d.core_size = mcore_size
  WHERE db_version=old_dbver
  WITH nocounter
 ;end update
 COMMIT
END GO
