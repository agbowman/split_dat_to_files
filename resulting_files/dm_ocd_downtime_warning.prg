CREATE PROGRAM dm_ocd_downtime_warning
 PAINT
 CALL clear(1,1)
 CALL text(2,1,"Some of the schema changes on this OCD require downtime to implement.")
 CALL text(3,1,"You may continue the installation now or continue at a later time.")
 CALL text(4,1,"Enter 'C' to continue or 'Q' to continue later. (C or Q).")
 SET done = 0
 WHILE (done=0)
   CALL accept(4,60,"A;cu","Q")
   SET choice = curaccept
   IF (((choice="Q") OR (choice="C")) )
    SET done = 1
   ENDIF
   IF (choice="Q")
    SET docd_reply->status = "Q"
   ELSE
    SET docd_reply->status = "D"
   ENDIF
 ENDWHILE
END GO
