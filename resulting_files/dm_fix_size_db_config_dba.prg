CREATE PROGRAM dm_fix_size_db_config:dba
 UPDATE  FROM dm_size_db_config
  SET value = "9999999999"
  WHERE config_parm="log_checkpoint_interval"
   AND value="999999999999"
  WITH nocounter
 ;end update
 COMMIT
 DELETE  FROM dm_size_db_config
  WHERE db_version > 800
   AND config_parm IN ("db_block_lru_statistics", "log_small_entry_max_size",
  "sequence_cache_entries", "sort_direct_writes", "sort_write_buffers")
  WITH nocounter
 ;end delete
 COMMIT
END GO
