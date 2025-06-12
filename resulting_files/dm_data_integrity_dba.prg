CREATE PROGRAM dm_data_integrity:dba
 PAINT
#menu
#init_variables
#dm_menu
 SET parser_buf = fillstring(132," ")
 EXECUTE FROM menu_screen TO menu_screen_exit
#menu_accept
 CALL text(24,02,"Select Menu Item Number (1-21) or Zero (0) to Quit: ")
 CALL accept(24,54,"99;S",0
  WHERE cnvtint(curaccept) BETWEEN 0 AND 21)
 IF (cnvtint(curaccept)=0)
  GO TO end_program
 ENDIF
 CALL clear(24,1)
 SET dem_blank_line = fillstring(78," ")
 CASE (cnvtint(curaccept))
  OF 1:
   CALL clear(24,1)
   CALL text(24,02,"Enter table name: ")
   CALL accept(24,20,"P(30);CUS")
   IF (curaccept > "")
    SET tbl_name = curaccept
    CALL text(24,01,dem_blank_line)
    CALL text(05,33,"<EXECUTING on")
    CALL text(05,47,substring(1,15,tbl_name))
    EXECUTE dm_validate_code_values value(trim(tbl_name))
    CALL video(br)
    CALL text(05,33,"<COMPLETED>")
   ENDIF
  OF 2:
   CALL clear(24,1)
   CALL text(24,02,"Enter table name: ")
   CALL accept(24,20,"P(30);CUS")
   IF (curaccept > "")
    SET tbl_name = curaccept
    CALL text(24,01,dem_blank_line)
    CALL text(06,33,"<EXECUTING on")
    CALL text(06,47,substring(1,15,tbl_name))
    EXECUTE dm_invalid_codes_rpt value(trim(tbl_name))
    EXECUTE FROM menu_screen TO menu_screen_exit
    CALL video(br)
    CALL text(06,33,"<COMPLETED>          ")
   ENDIF
  OF 3:
   SELECT INTO "nl:"
    d.*
    FROM dm_invalid_table_value d
    WITH maxqual(d,1), nocounter
   ;end select
   IF (curqual > 0)
    FOR (x = 9 TO 18)
      CALL clear(x,40,51)
    ENDFOR
    CALL box(9,40,18,90)
    CALL video(r)
    CALL text(10,41,"  **              EXISTING ROWS              **  ")
    CALL video(n)
    CALL text(12,41,"   Rows exist in the DM_INVALID_TABLE_VALUE       ")
    CALL text(13,41,"   table.  If you continue this table will be    ")
    CALL text(14,41,"   rebuilt.                                      ")
    CALL text(15,41,"                                                 ")
    CALL video(r)
    CALL text(17,41,"  **  Enter <C> to Continue or <Q> to Quit   **  ")
    CALL video(n)
    CALL accept(17,84,"p;CDU","Q"
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="C")
     DELETE  FROM dm_invalid_table_value
      WHERE 1=1
     ;end delete
     COMMIT
     FOR (x = 9 TO 18)
       CALL clear(x,40,51)
     ENDFOR
    ELSE
     GO TO 0100_start
    ENDIF
   ENDIF
  OF 4:
   CALL clear(24,1)
   CALL text(24,02,"Enter table name: ")
   CALL accept(24,20,"P(30);CUS")
   IF (curaccept > "")
    SET tbl_name = curaccept
    CALL text(24,01,dem_blank_line)
    CALL text(08,33,"<EXECUTING on")
    CALL text(08,47,substring(1,15,tbl_name))
    EXECUTE dm_purge_invalid_cd_keys value(trim(tbl_name))
    EXECUTE FROM menu_screen TO menu_screen_exit
    CALL video(br)
    CALL text(08,33,"<COMPLETED>          ")
   ENDIF
  OF 5:
   CALL clear(24,1)
   CALL text(24,02,"Enter table name: ")
   CALL accept(24,20,"P(30);CUS")
   IF (curaccept > "")
    SET tbl_name = curaccept
    CALL text(24,01,dem_blank_line)
    CALL text(09,33,"<EXECUTING on")
    CALL text(09,47,substring(1,15,tbl_name))
    EXECUTE dm_zero_invalid_codes value(trim(tbl_name))
    EXECUTE FROM menu_screen TO menu_screen_exit
    CALL video(br)
    CALL text(09,33,"<COMPLETED>          ")
   ENDIF
  OF 6:
   CALL clear(24,1)
   CALL text(24,02,"Enter table name: ")
   CALL accept(24,20,"P(30);CUS")
   IF (curaccept > "")
    SET tbl_name = curaccept
    CALL text(24,01,dem_blank_line)
    CALL text(10,33,"<EXECUTING on")
    CALL text(10,47,substring(1,15,tbl_name))
    EXECUTE dm_find_code_sets value("DM_FIND_CODE_SETS"), value(trim(tbl_name))
    EXECUTE FROM menu_screen TO menu_screen_exit
    CALL video(br)
    CALL text(10,33,"<COMPLETED>          ")
   ENDIF
  OF 8:
   GO TO process_screen8
  OF 9:
   GO TO process_screen9
  OF 10:
   GO TO process_screen10
  OF 11:
   GO TO process_screen11
  OF 12:
   GO TO process_screen12
  OF 13:
   GO TO process_screen13
  OF 14:
   GO TO process_screen14
  OF 15:
   GO TO process_screen15
  OF 16:
   GO TO process_screen16
  OF 17:
   GO TO process_screen17
  OF 18:
   GO TO process_screen18
  OF 19:
   GO TO process_screen19
  OF 20:
   GO TO process_screen20
  ELSE
   GO TO dm_menu
 ENDCASE
 CALL video(n)
 CALL accept(24,75,"P;CUS"," ")
 GO TO dm_menu
#menu_screen
 CALL video(r)
 SET width = 132
 CALL clear(1,1)
 CALL box(2,1,23,132)
 CALL text(1,1,"DM Data Integrity Menu",w)
 CALL video(n)
 CALL text(04,03,"CODE VALUE VALIDATION")
 CALL text(05,03," 1 Invalid Code Value Capture ")
 CALL text(06,03," 2 Invalid Code Value Report  ")
 CALL text(07,03," 3 Initialize Work Table      ")
 CALL text(08,03," 4 Purge Invalid Rows         ")
 CALL text(09,03," 5 Zero Fill Invalid Columns  ")
 CALL text(10,03," 6 Table Code Sets Report     ")
 CALL text(11,03,"                             ")
 CALL text(12,03,"CHECK CODE_SETS/CODE VALUES FOR")
 CALL text(13,03," 8 No Dup Indicators Set ")
 CALL text(14,03," 9 Duplicate Alias Value Violation ")
 CALL text(15,03,"10 Cdf_Meaning Value Violation ")
 CALL text(16,03,"11 Display Value Violation  ")
 CALL text(17,03,"12 Display Key Value Violation ")
 CALL text(18,03,"13 Duplicate Values")
 CALL text(19,03,"14 Active Dup Ind Set Violation")
 CALL text(20,03,"15 Alias Dup Ind Set Violation")
 CALL text(04,63,"FOREIGN KEY CONSTRAINT VALIDATION")
 CALL text(05,63,"16 Clear Exceptions Table")
 CALL text(06,63,"17 Enable Foreign Keys ")
 CALL text(07,63,"18 Generate a Report")
 CALL text(08,63,"19 Delete the Orphan Rows ")
 CALL text(09,63,"20 Check the Delete Log Table ")
#menu_screen_exit
#process_screen8
 CALL clear(1,1)
 CALL video(br)
 CALL text(5,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_no_dup_set
 CALL text(5,20,"<COMPLETED>")
#process_screen8_exit
 GO TO return_from_screens
#process_screen9
 CALL clear(1,1)
 CALL video(br)
 CALL text(5,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_code_alias_test
 CALL text(5,20,"<COMPLETED>")
#process_screen9_exit
 GO TO return_from_screens
#process_screen10
 CALL clear(1,1)
 CALL video(br)
 CALL video(n)
 CALL text(5,20,"<EXECUTING>")
 EXECUTE dm_cdf_meaning_value
 CALL text(5,20,"<COMPLETED>")
#process_screen10_exit
 GO TO return_from_screens
#process_screen11
 CALL clear(1,1)
 CALL video(br)
 CALL text(4,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_disp_value
 CALL text(5,20,"<COMPLETED>")
#process_screen11_exit
 GO TO return_from_screens
#process_screen12
 CALL clear(1,1)
 CALL video(br)
 CALL text(4,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_dispkey_value
 CALL text(5,20,"<COMPLETED>")
#process_screen12_exit
 GO TO return_from_screens
#process_screen13
 CALL clear(1,1)
 CALL video(br)
 CALL text(4,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_code_dup_viol
 CALL text(5,20,"<COMPLETED>")
 SELECT
  d.code_set, d.display, d.display_key,
  d.cdf_meaning
  FROM dm_code_dup_lst d
  HEAD REPORT
   line = fillstring(120,"="), page_nbr = 0
  HEAD PAGE
   col 0, "Page : ", page_nbr = (page_nbr+ 1),
   page_nbr" ####", col 35, "DUPLICATE VALUES VIOLATION",
   col 80, "Date :", curdate"dd-mmm-yyyy;;d",
   row + 1, col 20, "The following code sets have duplicate settings of the dup indicators",
   row + 1, col 0, line,
   row + 1, col 5, "CODE SET",
   col 20, "DISPLAY", col 40,
   "DISPLAY KEY", col 80, "CDF_MEANING",
   row + 1, col 0, line,
   row + 1
  DETAIL
   col 0, d.code_set, col 15,
   d.display, col 40, d.display_key,
   col 80,
   CALL print(trim(d.cdf_meaning)), row + 1
  WITH format, nocounter
 ;end select
#process_screen13_exit
 GO TO return_from_screens
#process_screen14
 CALL clear(1,1)
 CALL video(br)
 CALL text(4,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_only_active_ind
 CALL text(5,20,"<COMPLETED>")
#process_screen14_exit
 GO TO return_from_screens
#process_screen15
 CALL clear(1,1)
 CALL video(br)
 CALL text(4,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_alias_other_dup
 CALL text(5,20,"<COMPLETED>")
#process_screen15_exit
 GO TO return_from_screens
#process_screen16
 CALL clear(1,1)
 CALL box(1,1,7,80)
 CALL text(3,5,"Enter C to continue to clear the DM_FOR_KEY_EXCEPT table")
 CALL text(4,5,"or Q to quit: ")
 CALL accept(4,20,"P;CU","Q"
  WHERE curaccept IN ("C", "Q"))
 IF (curaccept="Q")
  GO TO process_screen16_exit
 ELSEIF (curaccept="C")
  CALL video(br)
  CALL text(4,20,"<EXECUTING>")
  CALL video(n)
  EXECUTE dm_del_dmfk_exp
 ENDIF
 CALL text(5,20,"<COMPLETED>")
#process_screen16_exit
 GO TO return_from_screens
#process_screen17
 CALL clear(1,1)
 CALL box(2,1,7,80)
 CALL text(4,2,"Enter the table name (Options :Tablename, Tablename with wildcard, All )")
 CALL text(5,2,"or Q to quit: ")
 CALL accept(5,20,"P(30);CU")
 IF (curaccept="Q")
  GO TO process_screen17_exit
 ENDIF
 SET t_name = fillstring(40," ")
 SET t_name = curaccept
 CALL video(br)
 CALL text(5,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_enb_fkeys value(t_name)
 CALL text(5,20,"<COMPLETED>")
#process_screen17_exit
 GO TO return_from_screens
#process_screen18
 CALL clear(1,1)
 CALL box(2,1,7,80)
 CALL text(4,2,"Enter the table name (Options: Tablename, Tablename with wildcard, All)")
 CALL text(5,2,"or Q to quit: ")
 CALL accept(5,20,"P(30);CU")
 IF (curaccept="Q")
  GO TO process_screen18_exit
 ENDIF
 SET tb_name = fillstring(40," ")
 SET tb_name = curaccept
 CALL video(br)
 CALL text(5,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_rpt_tables value(tb_name)
 CALL text(5,20,"<COMPLETED>")
#process_screen18_exit
 GO TO return_from_screens
#process_screen19
 CALL clear(1,1)
 CALL box(2,1,7,80)
 CALL text(4,2,"Enter the table name (Options: Tablename, Tablename with wildcard, All)")
 CALL text(5,2,"or Q to quit: ")
 CALL accept(5,20,"P(30);CU")
 IF (curaccept="Q")
  GO TO process_screen19_exit
 ENDIF
 SET tbl_name = fillstring(40," ")
 SET tbl_name = curaccept
 CALL video(br)
 CALL text(5,20,"<EXECUTING>")
 CALL video(n)
 EXECUTE dm_del_orphrows value(tbl_name)
 CALL text(5,20,"<COMPLETED>")
#process_screen19_exit
 GO TO return_from_screens
#process_screen20
 CALL clear(1,1)
 CALL box(1,1,7,80)
 CALL text(3,5,"Enter C to continue to check the delete log table")
 CALL text(4,5,"or Q to quit: ")
 CALL accept(4,20,"P;CU","Q"
  WHERE curaccept IN ("C", "Q"))
 IF (curaccept="Q")
  GO TO process_screen20_exit
 ELSEIF (curaccept="C")
  SELECT
   *
   FROM pa_audit
  ;end select
 ENDIF
 CALL clear(1,1)
#process_screen20_exit
 GO TO return_from_screens
#return_from_screens
 GO TO menu
#end_program
 CALL clear(1,1)
END GO
