CREATE PROGRAM cclverattr1:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "enter table name:            " = "*",
  "Enter database name:         " = "*"
 SELECT DISTINCT INTO  $1
  a.table_name, l.offset, attr1 = substring(1,20,l.attr_name),
  attr2 = substring(1,20,l2.attr_name), type1 = concat(l.type,cnvtstring(l.len,2),".",cnvtstring(l
    .precision,2)), type2 = concat(l2.type,cnvtstring(l2.len,2),".",cnvtstring(l2.precision,2)),
  stat1 = band(l.stat,((2** 11) - 1)), stat2 = band(l2.stat,((2** 11) - 1))
  FROM dtable t,
   dtableattr a,
   dtableattr a2,
   dtableattrl l,
   dtableattrl l2
  PLAN (t
   WHERE (t.table_name= $2)
    AND (t.file_name= $3)
    AND t.platform="H0000")
   JOIN (a
   WHERE "H0000"=a.platform
    AND t.table_name=a.table_name)
   JOIN (l
   WHERE l.structtype="F")
   JOIN (a2
   WHERE a.table_name=a2.table_name
    AND "T0000"=a2.platform)
   JOIN (l2
   WHERE l.attr_name=l2.attr_name)
  ORDER BY a.table_name, attr1, attr2
  HEAD REPORT
   MACRO (m1)
    attr1, col 25
    IF (attr2=" ")
     "<NOT FOUND>"
    ELSE
     attr2
    ENDIF
    col 50, bnum = 0
    WHILE (bnum < 11)
     CASE (bnum)
      OF 0:
       IF (btest(stat1,bnum)=1)
        "s"
       ENDIF
      OF 1:
       IF (btest(stat1,bnum)=1)
        "l"
       ENDIF
      OF 2:
       IF (btest(stat1,bnum)=1)
        "p"
       ENDIF
      OF 3:
       IF (btest(stat1,bnum)=1)
        "x"
       ENDIF
      OF 4:
       IF (btest(stat1,bnum)=1)
        "f"
       ENDIF
      OF 5:
       IF (btest(stat1,bnum)=1)
        "t"
       ENDIF
      OF 6:
       IF (btest(stat1,bnum)=1)
        "d"
       ENDIF
      OF 7:
       IF (btest(stat1,bnum)=1)
        "r"
       ENDIF
      OF 8:
       IF (btest(stat1,bnum)=1)
        "e"
       ENDIF
      OF 9:
       IF (btest(stat1,bnum)=1)
        "a"
       ENDIF
      OF 10:
       IF (btest(stat1,bnum)=1)
        "b"
       ENDIF
     ENDCASE
     ,bnum += 1
    ENDWHILE
    type1, col 65, bnum = 0
    WHILE (bnum < 11)
     CASE (bnum)
      OF 0:
       IF (btest(stat2,bnum)=1)
        "s"
       ENDIF
      OF 1:
       IF (btest(stat2,bnum)=1)
        "l"
       ENDIF
      OF 2:
       IF (btest(stat2,bnum)=1)
        "p"
       ENDIF
      OF 3:
       IF (btest(stat2,bnum)=1)
        "x"
       ENDIF
      OF 4:
       IF (btest(stat2,bnum)=1)
        "f"
       ENDIF
      OF 5:
       IF (btest(stat2,bnum)=1)
        "t"
       ENDIF
      OF 6:
       IF (btest(stat2,bnum)=1)
        "d"
       ENDIF
      OF 7:
       IF (btest(stat2,bnum)=1)
        "r"
       ENDIF
      OF 8:
       IF (btest(stat2,bnum)=1)
        "e"
       ENDIF
      OF 9:
       IF (btest(stat2,bnum)=1)
        "a"
       ENDIF
      OF 10:
       IF (btest(stat2,bnum)=1)
        "b"
       ENDIF
     ENDCASE
     ,bnum += 1
    ENDWHILE
    type2, row + 1
   ENDMACRO
   , line = fillstring(80,"=")
  HEAD PAGE
   "TYPE CODE: s=SIGN  p=SEPARATE x=INDEXED f=FOREIGN t=TIME ", row + 1,
   "           d=DATE  r=REV  e=EVEN     a=RCODE   b=USER           ",
   row + 1, "ATTR_OLD", col 25,
   "ATTR_NEW", col 50, "TYPE_OLD",
   col 65, "TYPE_NEW", row + 1,
   line, row + 1
  HEAD a.table_name
   row + 1, "<TABLE_NAME: ", a.table_name,
   ">", row + 1
  DETAIL
   IF (((attr2=" ") OR (((type1 != type2) OR (stat1 != stat2)) )) )
    m1
   ENDIF
  WITH outerjoin = l, maxcol = 100
 ;end select
END GO
