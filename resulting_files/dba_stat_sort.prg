CREATE PROGRAM dba_stat_sort
 SELECT
  vs.name, vs.value
  FROM v$sysstat vs
  WHERE vs.name IN ("sorts (memory)", "sorts (disk)")
  HEAD REPORT
   col 10, "Sort Cache Statistics", row + 2,
   "Hit Ratio should be > 90.0", row + 2
  HEAD PAGE
   col 10, "Memory Sorts", col 30,
   "Disk Sorts", col 50, "Hit Ratio",
   row + 1
  DETAIL
   IF (vs.name="sorts (memory)")
    x = vs.value
   ENDIF
   IF (vs.name="sorts (disk)")
    y = vs.value
   ENDIF
  FOOT REPORT
   IF (((x > 0.0) OR (y > 0.0)) )
    hr = ((x/ (x+ y)) * 100.0)
   ELSE
    hr = 0.0
   ENDIF
   col 8, x, col 26,
   y, col 45, hr,
   row + 2
   IF (hr < 90.0)
    "RECOMMEND INCREASING INIT.ORA PARAMETER SORT_AREA_SIZE"
   ELSE
    "SORT CACHE - Within Acceptable Range"
   ENDIF
 ;end select
END GO
