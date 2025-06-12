CREATE PROGRAM dm_prompt_for_admin
 PAINT
 CALL clear(1,1)
 IF (errcode != 0)
  CALL text(2,1,"Successful connection to ADMIN not made.")
  CALL text(3,1,errmsg)
  CALL text(4,1,"Please retry.")
 ENDIF
 CALL text(5,1,"Please enter the ADMIN database username: ")
 CALL text(6,1,"Please enter the ADMIN database password: ")
 CALL text(7,1,"Please enter the ADMIN database connect string: ")
 CALL text(8,1,"Enter 'C' to continue or 'Q' to continue later. (C or Q).")
 CALL accept(5,42,"P(20);cu",u_name)
 SET u_name = curaccept
 CALL accept(6,42,"P(20);cu",p_word)
 SET p_word = curaccept
 CALL accept(7,50,"P(20);cu",adm_link)
 SET adm_link = curaccept
 SET fini = 0
 WHILE (fini=0)
   CALL accept(8,60,"A;cu","C")
   SET choice = curaccept
   IF (((choice="Q") OR (choice="C")) )
    SET fini = 1
   ENDIF
 ENDWHILE
 IF (choice="Q")
  SET u_name = "QUIT"
  SET p_word = "QUIT"
  SET adm_link = "QUIT"
 ENDIF
 SET message = nowindow
 CALL echo(u_name)
 CALL echo(p_word)
 CALL echo(adm_link)
END GO
