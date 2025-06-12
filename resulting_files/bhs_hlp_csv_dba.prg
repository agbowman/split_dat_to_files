CREATE PROGRAM bhs_hlp_csv:dba
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 IF (ml_debug_flag >= 10)
  CALL echo(concat(curprog," helper script executed."))
  IF (ml_debug_flag >= 50)
   CALL echo("  Subroutine getCsvColumnAtIndex declared.")
  ENDIF
 ENDIF
 DECLARE getcsvcolumnatindex(p_line=vc(val),p_index=i4(val),p_value=vc(ref),p_delimiter=c1(val),
  p_wrapper=c1(val)) = i2 WITH persistscript
 SUBROUTINE getcsvcolumnatindex(p_line,p_index,p_value,p_delimiter,p_wrapper)
   DECLARE delim = i4 WITH protect, noconstant(0)
   DECLARE colstart = i4 WITH protect, noconstant(0)
   DECLARE length = i4 WITH protect, noconstant(0)
   DECLARE loop_cnt = i4 WITH protect, noconstant(0)
   FOR (loop_cnt = 1 TO (p_index - 1))
    IF (substring((delim+ 1),1,p_line)=p_wrapper)
     SET delim = (findstring(concat(p_wrapper,p_delimiter),p_line,(delim+ 1))+ 1)
    ELSE
     SET delim = findstring(p_delimiter,p_line,(delim+ 1))
    ENDIF
    IF (delim=0)
     RETURN(0)
    ENDIF
   ENDFOR
   IF (substring((delim+ 1),1,p_line)=p_wrapper)
    SET colstart = (delim+ 2)
    SET delim = findstring(concat(p_wrapper,p_delimiter),p_line,(delim+ 1))
   ELSE
    SET colstart = (delim+ 1)
    SET delim = findstring(p_delimiter,p_line,(delim+ 1))
   ENDIF
   IF (delim > 0)
    SET length = (delim - colstart)
   ELSE
    SET length = ((textlen(p_line) - colstart)+ 1)
   ENDIF
   SET p_value = substring(colstart,length,p_line)
   RETURN(1)
 END ;Subroutine
END GO
