CREATE PROGRAM dl_uar_test
 CALL echo(concat("Begin time: ",format(curtime3,"hh:mm:ss ;;m")))
 FOR (i = 1 TO 100)
  SET jjj = uar_get_code_by("DISPLAYKEY",72,"TRANSFUSED")
  CALL echo(jjj)
 ENDFOR
 CALL echo(concat("End time  : ",format(curtime3,"hh:mm:ss ;;m")))
END GO
