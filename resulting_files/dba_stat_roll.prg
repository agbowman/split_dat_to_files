CREATE PROGRAM dba_stat_roll
 SELECT
  rn.usn, rname = substring(1,10,rn.name), dr.segment_id,
  tname = substring(1,10,dr.tablespace_name), dr.status, r.usn,
  r.extents, r.writes, r.gets,
  r.waits, r.shrinks, r.wraps,
  r.extends
  FROM v$rollname rn,
   dba_rollback_segs dr,
   v$rollstat r
  PLAN (r)
   JOIN (dr
   WHERE dr.segment_id=r.usn
    AND dr.tablespace_name != "SYSTEM")
   JOIN (rn
   WHERE r.usn=rn.usn)
  ORDER BY dr.tablespace_name, dr.segment_id
  HEAD REPORT
   col 10, "Rollback Stats", row + 2,
   col 1, "W/G ratio should be < 5%", row + 2,
   col 0, "Tlbspace", col 10,
   "RB Seg Name", col 24, "Extents",
   col 45, "Writes", col 62,
   "Gets", col 75, "Waits",
   col 85, "W/G ratio", col 101,
   "Shrinks", col 117, "Wraps",
   row + 1
  DETAIL
   IF (r.waits > 0)
    x = ((r.waits/ r.gets) * 100)
   ELSE
    x = 0
   ENDIF
   col 0, tname, col 10,
   rname, col 17, r.extents,
   col 37, r.writes, col 52,
   r.gets, col 66, r.waits,
   col 80, x, col 94,
   r.shrinks, col 108, r.wraps,
   row + 1
  FOOT REPORT
   row + 1
   IF (x > 5.0)
    "RECOMMEND ADDING ROLLBACK SEGMENT"
   ELSE
    "ROLLBACK SEGMENTS -OK-"
   ENDIF
  WITH maxcol = 512
 ;end select
END GO
