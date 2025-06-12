CREATE PROGRAM dba_stat_sysstat
 SELECT
  vs.name, vs.value
  FROM v$sysstat vs
  WHERE vs.name IN ("db block gets", "consistent gets", "physical reads")
  HEAD REPORT
   col 10, "Data Buffer Cache Statistic", row + 2,
   "Hit Ratio should be > 90.0", row + 2, col 10,
   "Block Gets", col 30, "Consistent Gets",
   col 50, "Physical Reads", col 70,
   "Hit Ratio", row + 1
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
   col 6, x, col 31,
   y, col 50, z,
   col 65, hr, row + 2
   IF (hr < 90.0)
    "RECOMMEND INCREASING INIT.ORA PARAMETER DB_BLOCK_BUFFERS"
   ELSE
    "DATA BUFFER CACHE - Within Acceptable Range"
   ENDIF
 ;end select
END GO
