CREATE PROGRAM cclparam:dba
 DECLARE par = c20
 SET lnum = 0
 SET num = 1
 SET cnt = 0
 SET cnt2 = 0
 WHILE (num > 0)
  SET par = reflect(parameter(num,0))
  IF (par=" ")
   SET cnt = (num - 1)
   SET num = 0
  ELSE
   IF (substring(1,1,par)="L")
    CALL echo(build("$",num,":",par))
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(num,lnum))
     IF (par=" ")
      SET cnt2 = (lnum - 1)
      SET lnum = 0
     ELSE
      CALL echo(build("$",num,".",lnum,":",
        par,"=",parameter(num,lnum)))
      SET lnum += 1
     ENDIF
    ENDWHILE
   ELSE
    CALL echo(build("$",num,":",par,"=",
      parameter(num,lnum)))
   ENDIF
   SET num += 1
  ENDIF
 ENDWHILE
 CALL echo(build("num param=",cnt))
END GO
