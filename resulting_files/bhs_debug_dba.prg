CREATE PROGRAM bhs_debug:dba
 PROMPT
  "Debug Level: " = 100,
  "RDBDEBUG [y/n]" = "y",
  "RDBBIND  [y/n]" = "y"
 IF (validate(bhs_debug_flag)=0)
  DECLARE bhs_debug_flag = i4 WITH public, persist, noconstant(0)
 ENDIF
 SET bhs_debug_flag =  $1
 IF (cnvtupper( $2)="Y")
  SET trace = rdbdebug
 ELSE
  SET trace = nordbdebug
 ENDIF
 IF (cnvtupper( $3)="Y")
  SET trace = rdbbind
 ELSE
  SET trace = nordbbind
 ENDIF
 IF (( $1 < 0))
  SET trace = nordbdebug
  SET trace = nordbbind
 ENDIF
END GO
