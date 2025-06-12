CREATE PROGRAM cclprogsearch:dba
 PROMPT
  "Enter output report name : " = "MINE",
  "Enter program name : " = "*",
  "Enter search string1 : " = "*ORAHINT*INDEX*(*XIE2PRSNL*)*"
 RECORD rec(
   1 buf = c500000
 )
 SELECT INTO trim( $1)
  d.object, d.object_name, bin = cnvtupper(check(d.datarec))
  FROM dcompile d
  WHERE ((d.object="E") OR (d.object="P"))
   AND d.object_name=patstring(cnvtupper( $2))
   AND d.group=0
  HEAD d.object_name
   pos = 1, cnt = 0, rec->buf = ""
  DETAIL
   IF (((pos+ 800) < size(rec->buf)))
    cnt += 1, stat = movestring(bin,1,rec->buf,pos,800), pos += 800
   ENDIF
  FOOT  d.object_name
   IF ((rec->buf= $3))
    ">>>", d.object, col + 1,
    d.object_name, col + 1, d.group,
    row + 1
   ENDIF
  WITH counter
 ;end select
END GO
