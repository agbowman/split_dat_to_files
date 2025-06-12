CREATE PROGRAM bhs_ma_event_set:dba
 PROMPT
  "Printer" = "MINE"
 DECLARE allocfeventsets_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",93,
   "ALLOCFEVENTSETS"))
 CALL echo(allocfeventsets_cd)
 SELECT INTO  $1
  FROM v500_event_set_canon e1,
   v500_event_set_canon e2,
   v500_event_set_canon e3,
   v500_event_set_canon e4,
   v500_event_set_canon e5,
   v500_event_set_canon e6,
   v500_event_set_canon e7
  PLAN (e1
   WHERE e1.parent_event_set_cd=allocfeventsets_cd)
   JOIN (e2
   WHERE e2.parent_event_set_cd=outerjoin(e1.event_set_cd)
    AND e2.event_set_cd=1450842)
   JOIN (e3
   WHERE e3.parent_event_set_cd=outerjoin(e2.event_set_cd))
   JOIN (e4
   WHERE e4.parent_event_set_cd=outerjoin(e3.event_set_cd))
   JOIN (e5
   WHERE e5.parent_event_set_cd=outerjoin(e4.event_set_cd))
   JOIN (e6
   WHERE e6.parent_event_set_cd=outerjoin(e5.event_set_cd))
   JOIN (e7
   WHERE e7.parent_event_set_cd=outerjoin(e6.event_set_cd))
  ORDER BY e1.parent_event_set_cd, e1.event_set_collating_seq, e2.event_set_collating_seq,
   e3.event_set_collating_seq, e4.event_set_collating_seq, e5.event_set_collating_seq,
   e6.event_set_collating_seq, e7.event_set_collating_seq
  HEAD REPORT
   chkflag4 = 0, chkflag5 = 0, chkflag6 = 0,
   chkflag7 = 0, col1 = 0, es1 = fillstring(30," "),
   es1_1 = es1, es2 = es1, es3 = es1,
   es4 = es1, es5 = es1, es6 = es1
  HEAD PAGE
   col 1, es1, row + 1,
   col 5, es1_1, e1.event_set_cd,
   row + 1, col 10, es2,
   e2.event_set_cd, row + 1, col 15,
   es3, e3.event_set_cd, row + 1,
   col 20, es4, row + 1,
   col 25, es5, row + 1,
   col 30, es6, row + 1,
   "_________________________________________________________", row + 1
  HEAD e1.parent_event_set_cd
   es1 = uar_get_code_display(e1.parent_event_set_cd), col 1, es1,
   row + 1
  HEAD e1.event_set_collating_seq
   es1_1 = uar_get_code_display(e1.event_set_cd), col1 = 5, col col1,
   "1 ", es1_1, row + 1
  HEAD e2.event_set_cd
   es2 = uar_get_code_display(e2.event_set_cd), col1 = 10, col col1,
   "2 ", es2, row + 1
  HEAD e3.event_set_collating_seq
   es3 = uar_get_code_display(e3.event_set_cd), col1 = 15, col col1,
   "3 ", es3, row + 1
  HEAD e4.event_set_collating_seq
   es4 = uar_get_code_display(e4.event_set_cd), col1 = 20
   IF (e4.event_set_cd > 0)
    chkflag4 = 4, col col1, es4,
    row + 1
   ENDIF
  HEAD e5.event_set_collating_seq
   es5 = uar_get_code_display(e5.event_set_cd), col1 = 25
   IF (e5.event_set_cd > 0)
    chkflag5 = 5, col col1, es5,
    row + 1
   ENDIF
  HEAD e6.event_set_collating_seq
   es6 = uar_get_code_display(e6.event_set_cd)
   IF (e6.event_set_cd > 0)
    chkflag6 = 6, col1 = 30, col col1,
    "6 ", es6, row + 1
   ENDIF
  HEAD e7.event_set_collating_seq
   es7 = uar_get_code_display(e7.event_set_cd)
   IF (e7.event_set_cd > 0)
    chkflag7 = 7, col1 = 35, col col1,
    es7, row + 1
   ENDIF
  FOOT REPORT
   col + 1
  WITH nocounter
 ;end select
END GO
