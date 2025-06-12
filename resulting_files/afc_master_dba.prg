CREATE PROGRAM afc_master:dba
 PAINT
 EXECUTE cclseclogin
 DECLARE masterchoice = i2
 DECLARE masterquit = c1
 SET masterchoice = 0
 SET masterquit = "N"
 WHILE (masterquit="N")
   CALL box(3,1,23,80)
   CALL text(2,1,"AFC MASTER",w)
   CALL text(06,10," 1) Afc Master Report")
   CALL text(08,10," 2) Server Diagnostics Report")
   CALL text(10,10," 3) ")
   CALL video(r)
   CALL text(10,14,"Exit")
   CALL video(n)
   CALL text(24,2,"Select Option (1,2,3...)")
   CALL accept(24,36,"9;",3
    WHERE curaccept IN (1, 2, 3))
   SET masterchoice = curaccept
   CALL clear(24,1)
   CALL clear(1,1)
   IF (masterchoice > 0
    AND masterchoice < 3)
    EXECUTE cs_master_menu masterchoice
   ELSE
    SET masterquit = "Y"
   ENDIF
 ENDWHILE
 CALL clear(24,1)
 CALL clear(1,1)
END GO
