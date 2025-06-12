CREATE PROGRAM cclrecdef:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLRECDEF"), clear(3,2,78),
  text(03,05,"Report to get info for a record definition"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"DICTIONARY FILE   NAME(pattern match allowed)"), text(07,05,
   "DICTIONARY RECORD NAME(pattern match allowed)"), accept(05,30,"X(31);CU","MINE"),
  accept(06,50,"P(12);CU","*"), accept(07,50,"P(31);CU","*")
 SELECT INTO  $1
  f.dimension, r.file_name, r.rectype_name,
  f.level, f.field_name, type =
  IF (f.type=" ") "S"
  ELSE f.type
  ENDIF
  ,
  len =
  IF (f.len=0) r.max_reclen
  ELSE f.len
  ENDIF
  , prec = f.precision, f.offset,
  r.max_reclen
  FROM drectyp r,
   drectypfld f
  WHERE (r.file_name= $2)
   AND (r.rectype_name= $3)
   AND f.level > 0
  HEAD REPORT
   line = fillstring(90,"_")
  HEAD r.file_name
   col 1, "FILE NAME:   ", r.file_name
  HEAD r.rectype_name
   col + 2, "RECORD NAME: ", r.rectype_name,
   col + 2, "RECORD LENGTH: ", r.max_reclen,
   row + 1, "(S)structure (C)character (N)numeric (P)packed (I)integer (F)float", row + 1,
   "(A)access    (B)user      (D)date    (T)time   (R)reversed (U)nsigned", row + 1, line,
   row + 1
  DETAIL
   call reportmove('COL',(02+ (f.level * 2)),0), f.level, col + 1,
   f.field_name
   IF (f.dimension > 1)
    "[", f.dimension"####", "] "
   ELSE
    col + 7
   ENDIF
   IF (type="I"
    AND btest(f.stat,0)=0)
    "U"
   ENDIF
   IF (btest(f.stat,09)=1)
    "A"
   ENDIF
   IF (btest(f.stat,10)=1)
    "B"
   ENDIF
   IF (btest(f.stat,07)=1)
    "R"
   ENDIF
   IF (btest(f.stat,05)=1)
    "T"
   ENDIF
   IF (btest(f.stat,06)=1)
    "D"
   ENDIF
   CALL print(build(type,len,".",prec)), col 65, ";offset = ",
   f.offset"######", row + 1
  FOOT  r.rectype_name
   BREAK
 ;end select
END GO
