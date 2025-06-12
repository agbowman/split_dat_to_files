CREATE PROGRAM dl_error
 PROMPT
  "PRINTER" = "MINE"
 SET error = error_label
 SELECT INTO  $1
  a = curtime
  FROM xyz
  DETAIL
   a, row + 1
  WITH nocounter
 ;end select
#error_label
 CALL echo("there was an error")
 SELECT INTO  $1
  a = "errir"
  FROM dummyt
  DETAIL
   a, row + 1
  WITH nocounter
 ;end select
END GO
