CREATE PROGRAM cclcheck2
 PROMPT
  "Input file name from cclcheck : " = " ",
  "Onput file name               : " = "MINE"
 DEFINE rtl  $1
 SELECT DISTINCT INTO  $2
  tblname = substring(32,31,r.line), attrname = substring(63,31,r.line)
  FROM rtlt r
  WHERE r.line != "PRGNAME *"
  ORDER BY tblname, attrname
  WITH counter
 ;end select
 FREE DEFINE rtl
;#end
END GO
