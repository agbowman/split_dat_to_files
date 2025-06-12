CREATE PROGRAM dba_stat_latch
 SELECT
  waitgets = sum(l.gets), waitmisses = sum(l.misses), immedgets = sum(l.immediate_gets),
  immedmisses = sum(l.immediate_misses)
  FROM v$latch l
  WHERE name IN ("redo allocation", "redo copy")
  HEAD REPORT
   col 10, "Redo Buffer Cache Statistics", row + 2,
   "Hit Ratio shoud be > 99.0", row + 2, col 15,
   "Wait Gets", col 33, "Wait Misses",
   col 54, "Immed Gets", col 72,
   "Immed Misses", col 95, "Hit Ratio",
   row + 1
  DETAIL
   col 10, waitgets, col 30,
   waitmisses, col 50, immedgets,
   col 70, immedmisses, x = (((waitgets+ immedgets)/ (((waitgets+ immedgets)+ waitmisses)+
   immedmisses)) * 100),
   col 90, x, row + 2
   IF (x < 99.0)
    "RECOMMEND INCREASING INIT.ORA PARAMETER LOG_BUFFER"
   ELSE
    "REDO BUFFER CACHE - Within Acceptable Range"
   ENDIF
 ;end select
END GO
