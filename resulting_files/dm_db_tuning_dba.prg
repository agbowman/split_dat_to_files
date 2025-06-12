CREATE PROGRAM dm_db_tuning:dba
 SET x = 0.0
 SET y = 0.0
 SET z = 0.0
 SET hr = 0.0
 SELECT
  *
  FROM v$sga
 ;end select
 SELECT
  executions = sum(pins), cache_misses = sum(reloads)
  FROM v$librarycache
  HEAD REPORT
   "Library Cache Statistics", row + 1, "Ratio should be < 1.0",
   row + 1, "Executions", col 23,
   "Cache Misses", col 39, "Ratio",
   row + 1
  DETAIL
   executions, cache_misses
   IF (executions > 0)
    x = (cache_misses/ executions)
   ELSE
    x = 0.0
   ENDIF
   x, row + 1
   IF (x > 1.0)
    "TUNE LIBRARY CACHE", row + 1
   ELSE
    "LIBRARY CACHE Looks Peachy", row + 1
   ENDIF
  WITH nocounter, formfeed = none
 ;end select
 SELECT
  gets = sum(gets), gets_misses = sum(getmisses)
  FROM v$rowcache
  HEAD REPORT
   "Data Dictionary Cache Statistics", row + 1, "Gets",
   col 23, "Cache Misses", col 39,
   "Ratio", row + 1
  DETAIL
   gets, gets_misses
   IF (gets > 0)
    x = (gets_misses/ gets)
   ELSE
    x = 0.0
   ENDIF
   x, row + 1
   IF (x > 15.0)
    "TUNE DATA DICTIONARY CACHE", row + 1
   ENDIF
  WITH nocounter, formfeed = none
 ;end select
 SELECT
  vs.name, vs.value
  FROM v$sysstat vs
  WHERE name IN ("db block gets", "consistent gets", "physical reads")
  HEAD REPORT
   "Data Buffer Cache Statistics", row + 1, "Block Gets",
   col 20, "Consistent Gets", col 40,
   "Physical Reads", col 60, "Buffer Cache Hit Ratio",
   row + 1
  DETAIL
   IF (vs.name="db block gets")
    x = vs.value
   ENDIF
   IF (vs.name="consistent gets")
    y = vs.value
   ENDIF
   IF (vs.name="physical reads")
    z = vs.value
   ENDIF
  FOOT REPORT
   IF (((x > 0.0) OR (y > 0.0)) )
    hr = ((1 - (z/ (x+ y))) * 100.0)
   ELSE
    hr = 0.0
   ENDIF
   x, col 20, y,
   col 40, z, col 60,
   hr, row + 1
   IF (hr < 90.0)
    "TUNE DATA BUFFERS CACHE", row + 1
   ENDIF
  WITH nocounter, formfeed = none
 ;end select
 SELECT
  df.file_name, fs.phywrts, fs.phyrds,
  df.tablespace_name
  FROM dba_data_files df,
   v$filestat fs
  WHERE sqlpassthru("df.file_id = fs.file#")
  ORDER BY (fs.phyrds+ fs.phywrts) DESC
  HEAD REPORT
   "Disk I/O Statistics", row + 1, "Physical Reads",
   col 20, "Physical Writes", col 40,
   "Tablespace", col 70, "File Name",
   row + 1
  DETAIL
   fs.phyrds, col 20, fs.phywrts,
   col 40, df.tablespace_name, col 70,
   df.file_name, row + 1
  WITH nocounter, formfeed = none, maxcol = 512
 ;end select
END GO
