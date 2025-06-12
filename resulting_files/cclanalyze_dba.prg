CREATE PROGRAM cclanalyze:dba
 PROMPT
  "Enter output name for report (MINE): " = "MINE",
  "Enter program name               (): " = "X"
 DECLARE progname = c31
 DECLARE rptname = c80
 SET progname = cnvtupper( $2)
 IF (size(trim( $2)) > 25)
  SET rptname = concat("cclanalyze",curuser)
 ELSE
  SET rptname = trim(cnvtlower( $2))
 ENDIF
 EXECUTE cclanalyze2 value(progname)
 FREE DEFINE rtl
 DEFINE rtl build(rptname,".tmp")
 SELECT INTO trim( $1)
  FROM rtlt r
  WHERE r.line != " "
  HEAD REPORT
   line = fillstring(130,"="), "CCLANALYZE of select, insert, update, delete commands for program: ",
    $2,
   row + 1, "<SELECT:query_num.query_sub_num><from><target><where><group><having><order><end>", row
    + 1,
   "<INSERT|DELETE|UPDATE:query_num.query_sub_num><from><set><values><where><end>", row + 1, line,
   row + 1
  DETAIL
   r.line, row + 1
  WITH format = variable, maxrow = 1, maxcol = 140,
   noformfeed
 ;end select
 FREE DEFINE rtl
 SET stat = 1
 WHILE (stat)
   SET stat = remove(build(rptname,".tmp"))
 ENDWHILE
END GO
