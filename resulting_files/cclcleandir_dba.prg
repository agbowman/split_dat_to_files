CREATE PROGRAM cclcleandir:dba
 PROMPT
  "enter file spec to remove in ccluserdir : " = "xxx"
 IF (cursys="AXP")
  SET com = concat("delete ccluserdir:",trim( $1))
 ELSE
  SET com = concat('find $CCLUSERDIR -name "',trim( $1),'" -exec rm {} \;')
 ENDIF
 CALL echo(com)
 CALL dcl(com,size(com),0)
END GO
