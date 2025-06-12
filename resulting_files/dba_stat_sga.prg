CREATE PROGRAM dba_stat_sga
 SELECT
  name, value
  FROM v$sga s
  HEAD REPORT
   col 10, "System Global Area Summary", row + 2
  HEAD PAGE
   col 10, "SGA Component Name", col + 1,
   "Size In Bytes", row + 2
  DETAIL
   col 10, s.name, col + 1,
   s.value, row + 1
 ;end select
END GO
