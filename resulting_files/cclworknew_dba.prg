CREATE PROGRAM cclworknew:dba
 PROMPT
  "Enter work database name  (PACKET)     : " = "PACKET",
  "Enter work directory name (CCLUSERDIR) : " = "CCLUSERDIR"
 SET reclen = 0
 SELECT INTO "NL:"
  FROM dfile f
  WHERE (f.file_name= $1)
  DETAIL
   reclen = f.max_reclen
  WITH nocounter, maxrow = 1, noformfeed
 ;end select
 SELECT INTO concat(trim( $2),":", $1)
  rec = fillstring(value(reclen)," ")
  FROM dummyt
  WITH nocounter, size = value(reclen)
 ;end select
END GO
