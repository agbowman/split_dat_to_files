CREATE PROGRAM cls_test:dba
 DECLARE psid = c7
 SELECT INTO "MINE"
  psid = format(cnvtstring(p1.person_id),"#######;rp0"), p1.person_id, newfield = substring(1,25,p
   .name_last),
  p.name_full_formatted
  FROM prsnl p1,
   person p
  PLAN (p1
   WHERE p1.physician_ind=1)
   JOIN (p
   WHERE p.person_id=p1.person_id)
  ORDER BY p.name_last
  HEAD REPORT
   cnt = 0, date_stamp = format(curdate,"mm/dd/yyyy;;d"), time_stamp = format(curtime3,"hh:mm;;m"),
   bigline = fillstring(108,"="), col 0,
   CALL center("DFR Report Header",1,108),
   row + 1, col 0, bigline,
   row + 1
  HEAD PAGE
   col 0,
   CALL center("DFR Page Header",1,108), row + 1,
   page_stamp = format(curpage,"###;P0"), col 1, date_stamp,
   " ", time_stamp, col 48,
   CALL center(curprog,1,108), col 100, "PAGE ",
   page_stamp, row + 1
  DETAIL
   col 1, psid, col 15,
   p1.person_id, col 30, newfield,
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
 ;end select
END GO
