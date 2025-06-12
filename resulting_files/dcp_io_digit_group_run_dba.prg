CREATE PROGRAM dcp_io_digit_group_run:dba
 DECLARE checksupportedlocale(null) = i2 WITH protect
 SUBROUTINE checksupportedlocale(null)
   DECLARE current_locale = vc WITH protect, noconstant("")
   SET current_locale = cnvtupper(logical("CCL_LANG"))
   IF (current_locale="")
    SET current_locale = cnvtupper(logical("LANG"))
   ENDIF
   IF (current_locale IN ("EN_US", "EN_UK", "EN_AUS", "EN_US.*", "EN_UK.*",
   "EN_AUS.*"))
    RETURN(1)
   ENDIF
   CALL echo(logical("CCL_LANG"))
   CALL echo(logical("LANG"))
   CALL echo(
    "The current back-end configuration is not compatible, please contact your system administrator")
   RETURN(0)
 END ;Subroutine
 DECLARE continue_ind = i2 WITH protect, noconstant(1)
 DECLARE spaces = c78 WITH protect, constant(fillstring(78," "))
 DECLARE option_disp = vc WITH protect, noconstant(" ")
 DECLARE displayscreen(title=vc,x_pos=i2) = i2 WITH protect
 DECLARE checkprocedure(name=vc,type=vc) = i2 WITH protect
 SUBROUTINE displayscreen(title,x_pos)
   CALL clear(01,01)
   CALL video(r)
   CALL box(01,01,05,80)
   CALL text(02,02,spaces)
   CALL text(02,27,"IO DIGIT GROUPING CORRECTION")
   CALL text(03,02,spaces)
   CALL text(04,02,spaces)
   IF (textlen(trim(title,3)) > 0
    AND x_pos > 0)
    CALL video(u)
    CALL text(04,x_pos,title)
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE checkprocedure(name,type)
  EXECUTE dm_readme_include_sql_chk cnvtupper(value(name)), value(type)
  IF ((dm_sql_reply->status="F"))
   CALL echo(concat("FAILED TO CREATE SQL FUNCTION: ",name))
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SET message = window
 SET width = 80
 IF (checksupportedlocale(null)=0)
  GO TO exit_program
 ENDIF
 EXECUTE dm_readme_include_sql "cer_install:dcp_copy_io_results_procedures.sql"
 EXECUTE dm_readme_include_sql "cer_install:dcp_copy_io_results_functions.sql"
 CALL checkprocedure("dcp_parse_numeric_string","function")
 CALL checkprocedure("dcp_parse_numeric_string_c","procedure")
 CALL displayscreen(" ",0)
 WHILE (continue_ind)
   CALL displayscreen("SETUP MENU",35)
   CALL text(07,05,"SELECT AN OPTION TO DETECT OR UPDATE THE AFFECTED IO DATA")
   CALL text(10,08,"(1) DETECT AFFECTED IO DATA")
   CALL text(11,08,"(2) UPDATE AFFECTED IO DATA")
   CALL text(20,05,"YOUR CHOICE(0 TO EXIT):")
   CALL accept(20,29,"9;",0
    WHERE curaccept IN (0, 1, 2))
   CASE (curaccept)
    OF 0:
     SET continue_ind = 0
     CALL text(24,02,spaces)
     SET message = nowindow
     GO TO exit_program
    OF 1:
     SET continue_ind = 0
     SET option_disp = "DETECT DATA"
     SET message = nowindow
     EXECUTE dcp_io_digit_group_detection
     GO TO exit_program
    OF 2:
     SET continue_ind = 0
     SET option_disp = "UPDATE DATA"
     SET message = nowindow
     EXECUTE dcp_io_digit_group_correction
     GO TO exit_program
   ENDCASE
 ENDWHILE
#exit_program
 CALL parser("rdb drop procedure dcp_parse_numeric_string_c go")
 CALL parser("rdb drop function dcp_parse_numeric_string go")
 CALL echo("THIS SESSION HAS COMPLETED SUCCESSFULLY")
END GO
