CREATE PROGRAM audits_maint:dba
 PAINT
 EXECUTE cclseclogin
 DECLARE vr_no_save = i4
 SET vr_no_save = 0 WITH persist
#00_menu
 CALL video(n)
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET num = 1
 WHILE (num <= 21)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL video(r)
 CALL box(1,1,3,80)
 CALL clear(2,2,78)
 CALL text(2,3,"  Cerner Custom Audits Menu Maintenance  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL video(nl)
 CALL text(5,7," 1.  Code Set Creation")
 CALL text(6,7," 2.  Code Value Creation")
 CALL text(7,7," 3.  Program Creation")
 CALL text(8,7," 4.  ")
 CALL text(9,7," 5.  ")
 CALL text(10,7," 6.  ")
 CALL text(11,7," 7.  ")
 CALL text(12,7," 8.  ")
 CALL text(13,7," 9.  ")
 CALL text(21,7,"99.  Exit")
 CALL text(23,3,"Enter your choice : ")
 IF (vr_no_save=1)
  CALL video(b)
  CALL text(20,15,"NOTHING SAVED")
  CALL video(nl)
 ENDIF
 GO TO 00_prompt
#00_prompt
 CALL video(n)
 CALL accept(23,23,"99")
 CASE (curaccept)
  OF 00:
   GO TO 00_menu
  OF 01:
   EXECUTE jm_ins_code_set
  OF 02:
   EXECUTE jm_ins_code_value
  OF 03:
   EXECUTE jm_ins_prog
  OF 99:
   GO TO the_end
  ELSE
   CALL video(b)
   CALL text(20,15,"SELECTION NOT IN USE, TRY AGAIN")
   GO TO 00_prompt
 ENDCASE
 GO TO 00_menu
#the_end
 CALL clear(1,1)
 CALL video(hb)
 CALL line(10,1,80,hor)
 CALL clear(11,1,80)
 CALL text(11,20," G O O D B Y E ,  A U D I T   M A S T E R ! ! ! !")
 CALL line(12,1,80,hor)
 CALL video(nl)
END GO
