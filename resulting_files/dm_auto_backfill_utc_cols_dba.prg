CREATE PROGRAM dm_auto_backfill_utc_cols:dba
 EXECUTE dm_dbimport "cer_install:dm_backfill_utc_cols.csv", "dm_backfill_utc_cols", 1000
END GO
