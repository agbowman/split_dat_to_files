CREATE PROGRAM ccldirectory:dba
 PROMPT
  "enter file spec to list in ccluserdir: " = "xxx"
 IF (cursys="AXP")
  SET com = concat("dir/date ccluserdir:",trim( $1))
 ELSE
  SET com = concat('find $CCLUSERDIR -name "',trim( $1),'" -exec ls -l {} \;')
 ENDIF
 CALL echo(com)
 CALL dcl(com,size(com),0)
END GO
