CREATE PROGRAM dba_stat_row
 SELECT
  entries = sum(r.count), valid_entries = sum(r.usage), gets = sum(r.gets),
  gets_misses = sum(r.getmisses), scans = sum(r.scans), scan_misses = sum(r.scanmisses),
  mods = sum(r.modifications), flush = sum(r.flushes)
  FROM v$rowcache r
  HEAD REPORT
   col 10, "Data Dictionary Cache Statistics", row + 2,
   "Request Hit Ratio should be > 85.0", row + 2
  DETAIL
   col 11, "Cashe Entries", col 30,
   "Valid Cache Entries", col 63, "Valid Ratio",
   row + 1, col 10, entries,
   col 35, valid_entries
   IF (entries > 0)
    a = ((valid_entries/ entries) * 100)
   ELSE
    a = 0.0
   ENDIF
   col 60, a, row + 2,
   col 16, "Requests", col 34,
   "Missed Requests", col 57, "Request Hit Ratio",
   row + 1, col 10, gets,
   col 35, gets_misses
   IF (gets > 0)
    b = ((1 - (gets_misses/ gets)) * 100)
   ELSE
    b = 0.0
   ENDIF
   col 60, b, row + 2,
   col 17, "# Scans", col 35,
   "# Missed Scans", col 60, "Scan Hit Ratio",
   row + 1, col 10, scans,
   col 35, scan_misses
   IF (scans > 0)
    c = ((1 - (scan_misses/ scans)) * 100)
   ELSE
    c = 0.0
   ENDIF
   col 60, c, row + 2,
   col 9, "# Modifications", col 36,
   "Times Flushed", row + 1, col 10,
   mods, col 35, flush,
   row + 2
   IF (b < 85.0)
    "RECOMMEND INCREASING INIT.ORA PARAMETER SHARED_POOL_SIZE"
   ELSE
    "DATA DICTIONARY CACHE - Within Acceptable Range"
   ENDIF
 ;end select
END GO
