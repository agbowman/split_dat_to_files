CREATE PROGRAM ccloraused
 PAINT
  video(r), box(1,1,14,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLORAUSED"), clear(3,2,78),
  text(03,05,"Report to generate list of unique fields used by ccl program"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(07,05,"USER PROGRAMS (Y/N)"), text(09,05,"CCL PROGRAM (CCL* EXCLUDED)"), text(11,05,
   "FIELDS TO SEARCH FOR"),
  accept(05,40,"P(20);CU","MINE"), accept(07,40,"A;CU","Y"), accept(09,40,"P(12);CU","*"),
  accept(11,40,"P(31);CU","*"), clear(1,1)
 IF (( $2="Y"))
  SET exclude_name = "CCL*"
 ELSE
  SET exclude_name = " "
 ENDIF
 SET cnt = 0
 SET progs[1000] = fillstring(30," ")
 SELECT INTO "NL:"
  p.object_name
  FROM dprotect p
  WHERE (p.object_name= $3)
   AND p.object="P"
   AND p.object_name != patstring(exclude_name)
  DETAIL
   IF (cnt < 1000)
    cnt += 1, progs[cnt] = p.object_name
   ENDIF
  WITH nocounter, maxrow = 1
 ;end select
 IF (cnt=0)
  GO TO last
 ENDIF
 CALL clear(1,1)
 FREE DEFINE rtl
 SET stat = remove("CCLCHECK1.CCL")
 SET trow = 0
 SET tcol = 0
 FOR (cnt2 = 1 TO cnt)
   EXECUTE ccloraused2 progs[cnt2]
   SET trow += 1
   IF (mod((cnt2 - 1),20)=0)
    SET trow = 1
    IF (tcol=0)
     SET tcol = 1
    ELSEIF (tcol > 30)
     CALL clear(1,1)
     SET tcol = 1
    ELSE
     SET tcol += 32
    ENDIF
   ENDIF
   CALL text(trow,tcol,progs[cnt2])
 ENDFOR
 DEFINE rtl "CCLCHECK1.CCL"
 SELECT DISTINCT INTO  $1
  progname = substring(1,30,r.line), tabname = substring(32,30,r.line), attrname = substring((1+
   findstring(".",r.line)),31,r.line)
  FROM rtlt r
  WHERE (substring((1+ findstring(".",r.line)),31,r.line)= $4)
  ORDER BY progname, tabname, attrname
  HEAD REPORT
   line = fillstring(70,"=")
  HEAD PAGE
   CALL center("CCLORAUSED Where Used Fields Report",1,75), row + 1, col 0,
   "Program Name", col 20, "Table Name",
   col 40, "Attribute Name", row + 1,
   line, row + 1
  HEAD progname
   col 0, progname
  HEAD tabname
   col 20, tabname, cnt = 0
  DETAIL
   cnt += 1, col 35, cnt"####;R",
   col 40, attrname, row + 1
  WITH maxcol = 75
 ;end select
#last
END GO
