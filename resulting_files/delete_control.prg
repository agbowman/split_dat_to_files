CREATE PROGRAM delete_control
 PAINT
 SET width = 132
 SET modify = system
#0100_start
 SET updt_id = 0
 SET updt_task = 0
 SET updt_applctx = 0
 SET blanks = fillstring(120," ")
 SET control_name = fillstring(40," ")
 SET delete_ind = 0
 SET delete_status_ind = 0
 SET updt_cnt = 0
 SET updt_dt_tm = curdate
 CALL clear(1,1)
 CALL text(2,1,"Maintain Delete Control Table",w)
 CALL box(3,1,5,132)
 CALL box(14,1,23,132)
 CALL video(n)
 CALL text(4,4,"                                                                             ")
 CALL text(4,4,"Control Name: DELETE_CONTROL")
 CALL video(ul)
#control_name
 CALL video(n)
 SET accept = nochange
 CALL clear(24,1)
 SET help = off
 SELECT INTO "nl:"
  a.control_name, a.delete_ind, a.delete_status_ind
  FROM dm_env_del_control a
  WHERE a.control_name="DELETE_CONTROL"
  DETAIL
   control_name = a.control_name, delete_ind = a.delete_ind, delete_status_ind = a.delete_status_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET control_name = "DELETE_CONTROL"
  SET delete_ind = 1
  SET delete_status_ind = 1
  INSERT  FROM dm_env_del_control a
   SET a.control_name = control_name, a.delete_ind = delete_ind, a.delete_status_ind =
    delete_status_ind
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 EXECUTE FROM display_screen TO display_screen_values_end
#control_name_end
#accept_screen_function
 CALL video(n)
 CALL clear(24,1)
 CALL text(24,1,"Modify/Quit (M/Q)?")
 SET screen_function = " "
 SET accept = nochange
 CALL accept(24,42,"p;cus","M"
  WHERE curaccept IN ("M", "Q"))
 SET screen_function = curaccept
 CASE (curaccept)
  OF "M":
   GO TO modify_control
  ELSE
   GO TO 9999_end
 ENDCASE
 CALL clear(24,1)
 GO TO accept_screen_function
#modify_control
 EXECUTE FROM display_screen_values TO display_screen_values_end
 EXECUTE FROM accept_screen_fields TO accept_screen_fields_end
 SET updt_id = 2218
 SET updt_task = 2218
 SET updt_applctx = 2218
 UPDATE  FROM dm_env_del_control a
  SET a.delete_ind = delete_ind, a.delete_status_ind = delete_status_ind
  WHERE a.control_name=control_name
  WITH nocounter
 ;end update
 COMMIT
 GO TO accept_screen_function
#display_screen
 CALL video(n)
 CALL text(15,4,"01 Delete Ind     : ")
 CALL text(16,4,"02 Delete Status Ind : ")
#display_screen_end
#display_screen_values
 CALL video(n)
 CALL video(l)
 CALL text(15,25,format(delete_ind,"###"))
 CALL text(16,28,format(delete_status_ind,"###"))
 CASE (delete_ind)
  OF 0:
   CALL text(15,32,"No Delete                      ")
  OF 1:
   CALL text(15,32,"Commit Delete                  ")
  ELSE
   CALL text(15,32,"Unknown Status                  ")
 ENDCASE
 CASE (delete_status_ind)
  OF 0:
   CALL text(16,32,"Ready to Start                 ")
  OF 1:
   CALL text(16,32,"Completed Successfully         ")
  OF 2:
   CALL text(16,32,"Currently Running              ")
  OF 3:
   CALL text(16,32,"Completed With Execution Errors")
  OF 4:
   CALL text(16,32,"Errored-bad lookup of control  ")
  OF 5:
   CALL text(16,32,"Errored-bad insert into audit  ")
  ELSE
   CALL text(16,32,"Unknown Status                  ")
 ENDCASE
 CALL video(ul)
 CALL video(n)
#display_screen_values_end
#accept_screen_fields
 CALL video(n)
 SET accept = change
#accept_screen_01
 SET help = fix("0,1,2,3")
 CALL accept(15,25,"9(3);DS"
  WHERE curaccept IN (0, 1))
 CASE (curscroll)
  OF 0:
   SET delete_ind = curaccept
   CALL text(15,25,format(delete_ind,"###"))
   CASE (delete_ind)
    OF 0:
     CALL text(15,32,"No Delete                      ")
    OF 1:
     CALL text(15,32,"Commit Delete                  ")
    ELSE
     CALL text(15,32,"Unknown Status                  ")
   ENDCASE
  OF 2:
   CALL text(15,25,format(delete_ind,"###"))
   GO TO accept_screen_02
  OF 3:
   CALL text(15,25,format(delete_ind,"###"))
   GO TO accept_screen_03
  ELSE
   CALL text(15,25,format(delete_ind,"###"))
   GO TO accept_screen_03
 ENDCASE
#accept_screen_02
 CALL accept(16,28,"9(3);DS"
  WHERE curaccept IN (0, 1, 2, 3, 4,
  5))
 CASE (curscroll)
  OF 0:
   SET delete_status_ind = curaccept
   CALL text(16,28,format(delete_status_ind,"###"))
   CASE (delete_status_ind)
    OF 0:
     CALL text(16,32,"Ready to Start                 ")
    OF 1:
     CALL text(16,32,"Completed Successfully         ")
    OF 2:
     CALL text(16,32,"Currently Running              ")
    OF 3:
     CALL text(16,32,"Completed With Execution Errors")
    OF 4:
     CALL text(16,32,"Errored-bad lookup of control  ")
    OF 5:
     CALL text(16,32,"Errored-bad insert into audit  ")
    ELSE
     CALL text(16,32,"Unknown Status                  ")
   ENDCASE
  OF 2:
   CALL text(16,25,format(delete_status_ind,"###"))
   GO TO accept_screen_03
  OF 3:
   CALL text(16,28,format(delete_status_ind,"###"))
   GO TO accept_screen_04
  ELSE
   CALL text(16,28,format(delete_status_ind,"###"))
   GO TO accept_screen_line_nbr
 ENDCASE
#accept_screen_end
#accept_screen_line_nbr
 CALL video(n)
 CALL clear(24,1)
 CALL text(24,1,"Line")
 CALL video(lu)
 SET accept = nochange
 CALL accept(24,15,"9;",0
  WHERE curaccept >= 0
   AND curaccept <= 2)
 CALL clear(24,1)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO accept_screen_fields_end
  OF 1:
   GO TO accept_screen_01
  OF 2:
   GO TO accept_screen_02
  ELSE
   GO TO accept_screen_line_nbr
 ENDCASE
#accept_screen_fields_end
#9999_end
END GO
