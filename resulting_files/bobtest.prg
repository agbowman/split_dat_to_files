CREATE PROGRAM bobtest
 SET asdf = "123"
 IF (asdf="0*")
  CALL echo("YES")
 ELSE
  CALL echo("NO")
 ENDIF
END GO
