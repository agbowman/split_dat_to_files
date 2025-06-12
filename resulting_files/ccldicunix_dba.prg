CREATE PROGRAM ccldicunix:dba
 PROMPT
  "(C)check (R)rebuild (X)xrebuild (M)move Dictionary: " = "C"
 IF (cursys="AIX")
  CALL echo("Ccldicunix utility has been obsoleted and replace by ccldicunixreorg")
  CALL echo("Use bcheck or cclisamcheck to check index")
 ELSE
  CALL echo("Ccldicunix utility is only valid on unix")
 ENDIF
END GO
