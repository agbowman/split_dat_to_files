CREATE PROGRAM dcp_io_data_flag_run:dba
 DECLARE continue_ind = i2 WITH protect, noconstant(1)
 DECLARE spaces = c78 WITH protect, constant(fillstring(78," "))
 DECLARE option_disp = vc WITH protect, noconstant(" ")
 DECLARE display_screen(title=vc,x_pos=i2) = i2 WITH protect
 SET message = window
 SET width = 80
 CALL display_screen(" ",0)
 WHILE (continue_ind)
   CALL display_screen("SETUP MENU",36)
   CALL text(07,05,"SELECT THE CORRECT OPTION FOR THE I&O DATA MODEL TO USE")
   CALL text(08,05,"UNTIL I&O2G FLOWSHEET PRE-BUILD IS COMPLETED")
   CALL text(10,05,"NOTE:")
   CALL text(11,05,"IF YOU ARE CURRENTLY USING ORIGINAL I&O FLOWSHEET, AND")
   CALL text(12,05,"IF YOU ARE GOING TO LAUNCH DCP_COPY_IO_RESULTS IMMEDIATELY THEN SET OPTION 3")
   CALL text(13,05,"AFTER THE COPY SCRIPT IS COMPLETED, SET THIS TO 2 WHEN YOU ARE READY")
   CALL text(14,05,"TO START USING I&O2G.")
   CALL text(16,08,"(1)  USE ORIGINAL IO DATA MODEL")
   CALL text(17,08,"(2)  USE I&O2G DATA MODEL")
   CALL text(18,08,"(3)  READ USING IO DATA MODEL AND WRITE USING I&O2G DATA MODEL")
   CALL text(20,05,"YOUR CHOICE(0 TO EXIT):")
   CALL accept(20,29,"9;",0
    WHERE curaccept IN (0, 1, 2, 3))
   CASE (curaccept)
    OF 0:
     SET continue_ind = 0
     CALL text(24,02,spaces)
     SET message = nowindow
     GO TO exit_program
    OF 1:
     SET continue_ind = 0
     SET option_disp = "CREATE FLAG"
     SET message = nowindow
     EXECUTE dcp_create_io_data_flag
     EXECUTE dcp_remove_io2g_data_flag
     GO TO exit_program
    OF 2:
     SET continue_ind = 0
     SET option_disp = "REMOVE FLAG"
     SET message = nowindow
     EXECUTE dcp_remove_io_data_flag
     EXECUTE dcp_remove_io2g_data_flag
     GO TO exit_program
    OF 3:
     SET continue_ind = 0
     SET option_disp = "CREATE CONVT FLAG"
     SET message = nowindow
     EXECUTE dcp_create_io_data_flag
     EXECUTE dcp_create_io2g_data_flag
     GO TO exit_program
   ENDCASE
 ENDWHILE
 SUBROUTINE display_screen(title,x_pos)
   CALL clear(01,01)
   CALL video(r)
   CALL box(01,01,05,80)
   CALL text(02,02,spaces)
   CALL text(02,33,"  IO DATA FLAG")
   CALL text(03,02,spaces)
   CALL text(04,02,spaces)
   IF (textlen(trim(title,3)) > 0
    AND x_pos > 0)
    CALL video(u)
    CALL text(04,x_pos,title)
   ENDIF
   CALL video(n)
 END ;Subroutine
#exit_program
 CALL echo("THIS SESSION HAS COMPLETED SUCCESSFULLY")
END GO
