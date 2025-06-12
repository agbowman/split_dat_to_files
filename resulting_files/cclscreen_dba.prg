CREATE PROGRAM cclscreen:dba
 PAINT
 SET message = - (1)
 CALL box(3,1,23,80)
 CALL video(r)
 CALL clear(1,1,80)
 CALL clear(2,1,80)
 CALL text(2,10,"CCLSCREEN PROGRAM",wide)
 CALL video(n)
 CALL text(4,10,"Wait(Y/N)")
 CALL text(5,10,"Begin gr screen#")
 CALL text(5,35,"End  gr screen#")
 CALL accept(4,20,"P;CU","Y")
 SET p_wait = curaccept
 CALL accept(5,30,"9(4)")
 SET p_start = curaccept
 CALL accept(5,60,"9(4)")
 SET p_end = curaccept
 SET num = p_start
 WHILE (num <= p_end)
   CALL clear(1,1)
   CALL screen(num)
   CALL text(24,1,format(num,"SCREEN #### NEXT?"))
   IF (p_wait="Y")
    CALL accept(24,25,"P;C","Y")
   ENDIF
   SET num = (num+ 1)
 ENDWHILE
END GO
