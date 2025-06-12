CREATE PROGRAM cclutil_findpat1
 SET rec->fnd = 0
 CASE ( $3)
  OF "E":
   TRANSLATE INTO  $1 EKMODULE  $2  WITH xml
  OF "P":
   TRANSLATE INTO  $1 PROGRAM  $2  WITH xml
  OF "V":
   TRANSLATE INTO  $1 VIEW  $2  WITH xml
 ENDCASE
 FREE DEFINE rtl
 DEFINE rtl  $1
 SELECT INTO nl
  r.line
  FROM rtlt r
  HEAD REPORT
   state = 1, posend = 0, pos[10] = 0,
   stat = initarray(pos,0)
  DETAIL
   IF (state BETWEEN 2 AND 3)
    posend = findstring("</TABLE.",r.line)
    IF ((posend=pos[1]))
     state = 1
    ENDIF
   ENDIF
   CASE (state)
    OF 1:
     pos[state] = findstring("<TABLE.",r.line),
     IF ((pos[state] > 0))
      state += 1
     ENDIF
    OF 2:
     pos[state] = findstring("<Z_SELECT.",r.line),
     IF ((pos[state] > pos[(state - 1)]))
      state += 1
     ENDIF
    OF 3:
     pos[state] = findstring("<ORDER.",r.line),
     IF ((pos[state] > pos[2]))
      state += 1
     ENDIF
   ENDCASE
  FOOT REPORT
   IF (state=4)
    rec->fnd = 1
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 SET stat = remove( $1)
END GO
