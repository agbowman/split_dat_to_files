CREATE PROGRAM cclprog:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLPROG"), clear(3,2,78),
  text(03,05,"Report to get list of CCL object(s)."), video(n), text(05,05,"MINE/CRT/printer/file"),
  text(06,05,"OBJECT NAME TYPE(pattern match allowed)"), text(07,05,
   "    D=DATABASE M=MENU P=PROGRAM T=TABLE V=VIEW *=ALL"), text(08,05,
   "OBJECT NAME(pattern match allowed)"),
  accept(05,30,"X(31);CU","MINE"), accept(06,45,"P;CU","P"), accept(08,45,"P(30);CU","*")
 SELECT INTO  $1
  d.object, object_name = d.object_name, group = d.group,
  objgrp = concat(d.object,cnvtstring(d.group))
  FROM dprotect d
  WHERE (d.object= $2)
   AND (d.object_name= $3)
  ORDER BY objgrp
  HEAD objgrp
   row + 1
   CASE (d.object)
    OF "D":
     "CCL DATABASE"
    OF "M":
     "CCL MENU"
    OF "P":
     "CCL PROGRAM"
    OF "T":
     "CCL TABLE"
    OF "V":
     "CCL VIEW"
    ELSE
     "CCL OBJECT"
   ENDCASE
   " OWNED BY "
   IF (group > 0)
    "GROUP", group"##;l"
   ELSE
    "DBA    "
   ENDIF
   row + 1, "----------------------------------------", "----------------------------------------",
   "----------------------------------------", num = 0
  DETAIL
   IF (mod(num,4)=0)
    row + 1, col 5, object_name,
    num = 1
   ELSE
    col + 2, object_name, num += 1
   ENDIF
  FOOT  objgrp
   BREAK
  WITH format, counter, separator = " "
 ;end select
END GO
