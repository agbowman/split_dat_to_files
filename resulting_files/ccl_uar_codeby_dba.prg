CREATE PROGRAM ccl_uar_codeby:dba
 PROMPT
  "Output device (MINE): " = "MINE",
  "Enter code set (optional): " = 0,
  "Enter displaykey: " = "*",
  "Enter #loops: " = 10
  WITH outdev, codeset, dispkey,
  loops
 FOR (i = 1 TO  $LOOPS)
  CALL echo(uar_get_code_by("DISPLAYKEY", $CODESET,nullterm(trim( $DISPKEY))))
  CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 ENDFOR
END GO
