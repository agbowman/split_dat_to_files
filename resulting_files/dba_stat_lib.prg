CREATE PROGRAM dba_stat_lib
 SELECT
  executions = sum(l.pins), cache_misses = sum(l.reloads)
  FROM v$librarycache l
  HEAD REPORT
   col 10, "Library Cache Statistics", row + 2,
   "Hit Ratio should be > 99.0", row + 2
  HEAD PAGE
   col 10, "Executions", col 30,
   "Cache Misses", col 50, "Hit Ratio",
   row + 1
  DETAIL
   col 6, executions, col 28,
   cache_misses
   IF (executions > 0)
    x = ((1 - (cache_misses/ executions)) * 100)
   ELSE
    x = 0.0
   ENDIF
   col 45, x, row + 2
   IF (x < 99.0)
    "RECOMMEND INCREASING INIT.ORA PARAMETER SHARED_POOL_SIZE"
   ELSE
    "LIBRARY CACHE - Within Acceptable Range"
   ENDIF
 ;end select
END GO
