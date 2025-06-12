CREATE PROGRAM dba_stat_menu
 SET message = window
#menu1
 CALL video(r)
 CALL clear(1,1)
 CALL box(3,5,20,75)
 CALL box(3,5,5,75)
 CALL text(4,6,"     ****           PERFORMANCE STATS FROM STARTUP          ****     ")
 CALL video(n)
 CALL text(8,9,"1. Data Buffer Cache")
 CALL text(10,9,"2. Lib. Cache")
 CALL text(12,9,"3. Data Dict. Cache")
 CALL text(14,9,"4. Redo Buffer Cache")
 CALL text(16,9,"5. Sort Cache")
 CALL text(8,45,"6. Disk I/O")
 CALL text(10,45,"7. Rollback Stats")
 CALL text(12,45,"8. SGA")
 CALL text(18,9,"Your Selection(0 to exit)")
 CALL accept(18,35,"p"
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 0))
 SET option = curaccept
 CASE (option)
  OF 1:
   GO TO lbl_sysstat
  OF 2:
   GO TO lbl_lib
  OF 3:
   GO TO lbl_row
  OF 4:
   GO TO lbl_latch
  OF 5:
   GO TO lbl_sort
  OF 6:
   GO TO lbl_filestat
  OF 7:
   GO TO lbl_roll
  OF 8:
   GO TO lbl_sga
  OF 0:
   GO TO lbl_exit
 ENDCASE
#lbl_sysstat
 EXECUTE dba_stat_sysstat
 GO TO menu1
#lbl_lib
 EXECUTE dba_stat_lib
 GO TO menu1
#lbl_row
 EXECUTE dba_stat_row
 GO TO menu1
#lbl_latch
 EXECUTE dba_stat_latch
 GO TO menu1
#lbl_sort
 EXECUTE dba_stat_sort
 GO TO menu1
#lbl_filestat
 EXECUTE dba_stat_filestat
 GO TO menu1
#lbl_roll
 EXECUTE dba_stat_roll
 GO TO menu1
#lbl_sga
 EXECUTE dba_stat_sga
 GO TO menu1
#lbl_exit
END GO
