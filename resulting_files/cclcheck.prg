CREATE PROGRAM cclcheck
 SET message = window
 SET message = 0
 CALL clear(1,1)
 CALL box(1,1,14,80)
 CALL text(2,30,"CCLCHECK PROGRAM")
 CALL line(3,1,80,xhor)
 CALL text(5,5,"PRINTER/MINE/FILE")
 CALL text(6,5,"CCL program to check missing fields: ")
 CALL accept(5,45,"PPPPPPPPPPPPPPPPPPPP;CUP","MINE")
 SET printer = curaccept
 CALL accept(6,45,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUP")
 SET prog = curaccept
 SET pblk = 5
 SET pcnt = 0
 RECORD rec(
   1 qual[*]
     2 pname = vc
     2 group = i1
 )
 CALL text(10,5,"STEP1")
 SELECT INTO "NL:"
  p.object_name
  FROM dprotect p
  WHERE p.object="P"
   AND p.group BETWEEN 0 AND 98
   AND p.object_name=patstring(prog)
  DETAIL
   IF (mod(pcnt,10)=0)
    stat = alterlist(rec->qual,(pcnt+ 10))
   ENDIF
   pcnt = (pcnt+ 1), rec->qual[pcnt].pname = p.object_name, rec->qual[pcnt].group = p.group
  WITH nocounter
 ;end select
 CALL text(10,60,cnvtstring(pcnt))
 CALL text(11,5,"STEP2")
 FOR (i = 1 TO pcnt)
  IF (mod(i,100)=0)
   CALL text(11,25,rec->qual[i].pname)
   CALL text(11,60,build(i))
  ENDIF
  EXECUTE cclchecktran "cclcheck1.dat", rec->qual[i].pname, evaluate(i,1,2,3),
  rec->qual[i].group
 ENDFOR
 IF (pcnt=0)
  RETURN
 ENDIF
 CALL text(12,5,"STEP3")
 FREE DEFINE rtl
 DEFINE rtl "cclcheck1.dat"
 SELECT DISTINCT INTO "cclcheck2.dat"
  prgname = substring(01,30,r.line), tblname = substring(32,30,r.line), attrname = substring(63,30,r
   .line)
  FROM rtlt r
  WHERE  NOT (substring(63,30,r.line) IN ("SEQ", "\*"))
  ORDER BY substring(1,93,r.line)
  WITH noheading, counter
 ;end select
 IF (curqual)
  CALL text(13,5,"STEP4")
  FREE DEFINE rtl
  DEFINE rtl "cclcheck2.dat"
  SELECT INTO value(printer)
   prgname = substring(01,30,r.line), tblname = substring(32,30,r.line), attrname = substring(63,30,r
    .line),
   flag = decode(l.seq,"Found    ","Not Found")
   FROM rtlt r,
    dtableattr a,
    dtableattrl l
   WHERE substring(32,30,r.line)=a.table_name
    AND substring(63,30,r.line)=l.attr_name
   WITH noheading, counter, outerjoin = r
  ;end select
 ENDIF
 FREE DEFINE rtl
 SET stat = remove("cclcheck1.dat")
 SET stat = remove("cclcheck2.dat")
;#end
END GO
