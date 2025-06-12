CREATE PROGRAM cclcheckload
 SET message = window
 SET message = 0
 CALL clear(1,1)
 CALL box(1,1,14,80)
 CALL text(2,30,"CCLCHECKLOAD PROGRAM")
 CALL line(3,1,80,xhor)
 CALL text(5,5,"PRINTER/MINE/FILE")
 CALL text(6,5,"CCL program to check missing fields: ")
 CALL accept(5,45,"PPPPPPPPPPPPPPPPPPPP;CUP","MINE")
 SET printer = curaccept
 CALL accept(6,45,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUP")
 SET prog = curaccept
 DECLARE emsg = c250
 DECLARE cnt2 = i4 WITH noconstant(0)
 RECORD rec(
   1 qual[*]
     2 pname = vc
     2 group = i1
   1 qual2[*]
     2 pname = vc
     2 errmsg = vc
     2 group = i1
 )
 CALL text(10,5,"STEP1")
 SET pblk = 5
 SET pcnt = 0
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
 CALL text(11,5,"STEP2")
 FOR (i = 1 TO pcnt)
   IF (mod(i,100)=0)
    CALL text(11,25,rec->qual[i].pname)
    CALL text(11,60,cnvtstring(i))
   ENDIF
   EXECUTE cclchecktran "NL:", rec->qual[i].pname, 1,
   rec->qual[i].group
   SET stat = 1
   WHILE (stat)
    SET stat = error(emsg,0)
    IF (stat)
     SET cnt2 = (cnt2+ 1)
     SET stat2 = alterlist(rec->qual2,cnt2)
     SET rec->qual2[cnt2].pname = rec->qual[i].pname
     SET rec->qual2[cnt2].errmsg = emsg
     SET rec->qual2[cnt2].group = group
    ENDIF
   ENDWHILE
   SET stat = error(emsg,1)
 ENDFOR
 CALL text(12,5,"STEP3")
 SELECT INTO trim(printer)
  pname = substring(1,31,rec->qual2[d.seq].pname), grp = rec->qual2[d.seq].group"###", errmsg =
  substring(1,132,rec->qual2[d.seq].errmsg)
  FROM (dummyt d  WITH seq = value(size(rec->qual2,5)))
  WITH nocounter
 ;end select
;#end
END GO
