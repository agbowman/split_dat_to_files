CREATE PROGRAM delete_table_list
 PAINT
 SET width = 132
 SET modify = system
#0100_start
 SET updt_id = 0
 SET updt_task = 0
 SET updt_applctx = 0
 SET first_add = " "
 SET blanks = fillstring(120," ")
 SET table_name = fillstring(40," ")
 SET restrict_clause = fillstring(500," ")
 SET sequence = 0
 SET updt_cnt = 0
 SET updt_dt_tm = curdate
 SET text1 = fillstring(70," ")
 SET text2 = fillstring(70," ")
 SET text3 = fillstring(70," ")
 SET text4 = fillstring(70," ")
 SET text5 = fillstring(70," ")
 CALL clear(1,1)
 CALL text(2,1,"Delete Table List",w)
 CALL box(3,1,5,132)
 CALL box(14,1,23,132)
 CALL video(n)
 CALL text(4,4,"                                                                             ")
 CALL text(4,4,"Table Name: ")
 CALL video(ul)
#accept_screen_function
 CALL video(n)
 CALL clear(24,1)
 CALL text(24,1,"Add/Delete/Modify/Insertdefault/Quit (A/D/M/I/Q)?")
 SET screen_function = " "
 CALL accept(24,51,"p;cus","M"
  WHERE curaccept IN ("A", "D", "M", "Q", "I"))
 SET screen_function = curaccept
 CASE (curaccept)
  OF "A":
   GO TO add_table
  OF "M":
   GO TO modify_table
  OF "D":
   GO TO delete_table
  OF "I":
   GO TO insert_default_entry
  ELSE
   GO TO 9999_end
 ENDCASE
 CALL clear(24,1)
 GO TO accept_screen_function
#add_table
 SET first_add = "Y"
 EXECUTE FROM clear_screen TO clear_screen_end
 EXECUTE FROM table_name_accept TO table_name_accept_end
 EXECUTE FROM accept_screen_fields TO accept_screen_fields_end
 SET updt_id = 2218
 SET updt_task = 2218
 SET updt_applctx = 2218
 SET restrict_clause = concat(text1,text2,text3,text4,text5)
 INSERT  FROM dm_env_del_tbl_lst a
  SET a.table_name = table_name, a.restrict_clause1 = substring(1,255,restrict_clause), a
   .restrict_clause2 = substring(256,255,restrict_clause),
   a.sequence = sequence
  WITH nocounter
 ;end insert
 COMMIT
 GO TO accept_screen_function
#delete_table
 EXECUTE FROM clear_screen TO clear_screen_end
 EXECUTE FROM table_name_accept TO table_name_accept_end
 EXECUTE FROM display_screen_values TO display_screen_values_end
 CALL video(n)
 CALL clear(24,1)
 CALL text(24,1,"Delete - (Y/N)?")
 SET accept = nochange
 CALL accept(24,17,"p;cud","Y"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   DELETE  FROM dm_env_del_tbl_lst a
    WHERE a.table_name=table_name
     AND a.sequence=sequence
    WITH nocounter
   ;end delete
   COMMIT
   GO TO accept_screen_function
  OF "N":
   GO TO accept_screen_function
  ELSE
   GO TO delete_table_name
 ENDCASE
 GO TO accept_screen_function
#modify_table
 SET first_add = "Y"
 EXECUTE FROM clear_screen TO clear_screen_end
 EXECUTE FROM table_name_accept TO table_name_accept_end
 EXECUTE FROM display_screen_values TO display_screen_values_end
 EXECUTE FROM accept_screen_fields TO accept_screen_fields_end
 SET updt_id = 2218
 SET updt_task = 2218
 SET updt_applctx = 2218
 SET restrict_clause = concat(text1,text2,text3,text4,text5)
 UPDATE  FROM dm_env_del_tbl_lst a
  SET a.restrict_clause1 = substring(1,255,restrict_clause), a.restrict_clause2 = substring(256,255,
    restrict_clause), a.sequence = sequence
  WHERE a.table_name=table_name
   AND a.sequence=sequence
  WITH nocounter
 ;end update
 COMMIT
 GO TO accept_screen_function
#insert_default_entry
 SET first_add = "Y"
 EXECUTE FROM clear_screen TO clear_screen_end
 CALL video(n)
 SET accept = nochange
 CALL clear(24,1)
 CALL text(24,1,"** Warning all current entries will be deleted - Continue (Y/N)?")
 CALL accept(24,66,"p;cu","N"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   SET table_name = "PERSON"
  OF "N":
   GO TO accept_screen_function
  ELSE
   GO TO accept_screen_function
 ENDCASE
 DELETE  FROM dm_env_del_tbl_lst a
  WHERE a.table_name > " "
  WITH nocounter
 ;end delete
 COMMIT
 SET sequence = 1
 SET restrict_clause = "NOT EXISTS(SELECT PERSON_ID FROM PRSNL WHERE PERSON.PERSON_ID = PERSON_ID"
 SET text1 = substring(1,70,restrict_clause)
 SET text2 = substring(71,70,restrict_clause)
 SET text3 = substring(141,70,restrict_clause)
 SET text4 = substring(211,70,restrict_clause)
 SET text5 = substring(281,70,restrict_clause)
 EXECUTE FROM display_screen_values TO display_screen_values_end
 EXECUTE FROM accept_screen_fields TO accept_screen_fields_end
 INSERT  FROM dm_env_del_tbl_lst a
  SET a.table_name = table_name, a.restrict_clause1 = substring(1,255,restrict_clause), a
   .restrict_clause2 = substring(256,255,restrict_clause),
   a.sequence = sequence
  WITH nocounter
 ;end insert
 COMMIT
 GO TO accept_screen_function
#table_name_accept
 CALL video(n)
 CALL text(4,4,"                                                                             ")
 CALL text(4,4,"Table Name: ")
 CALL video(ul)
 SET accept = nochange
 SET validate = 2
 SET help =
 SELECT INTO "NL:"
  a.table_name
  FROM dm_env_del_tbl_lst a
  WHERE a.table_name >= curaccept
  ORDER BY a.table_name
  WITH nocounter
 ;end select
 CALL accept(4,17,"P(40);pcu")
 SET table_name = curaccept
 CALL clear(24,1)
 SET help = off
 IF (curaccept=" ")
  GO TO accept_screen_function
 ENDIF
 SELECT INTO "nl:"
  b.table_name
  FROM user_tables b
  WHERE b.table_name=table_name
  DETAIL
   table_name = b.table_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(n)
  CALL text(24,2,"Invalid table name, select again")
  GO TO table_name_accept
 ENDIF
 SELECT INTO "nl:"
  a.table_name, a.sequence, a.restrict_clause1,
  a.restrict_clause2
  FROM dm_env_del_tbl_lst a
  WHERE a.table_name=table_name
  DETAIL
   table_name = a.table_name, sequence = a.sequence, restrict_clause = concat(a.restrict_clause1,a
    .restrict_clause2)
  WITH nocounter
 ;end select
 IF (curqual=0
  AND screen_function != "A")
  CALL video(n)
  CALL text(24,2,"Table not found, select again")
  GO TO table_name_accept
 ENDIF
 IF (curqual=1
  AND screen_function="A")
  CALL video(n)
  CALL text(24,2,"Table already exists, select again")
  GO TO table_name_accept
 ENDIF
 SET text1 = substring(1,70,restrict_clause)
 SET text2 = substring(71,70,restrict_clause)
 SET text3 = substring(141,70,restrict_clause)
 SET text4 = substring(211,70,restrict_clause)
 SET text5 = substring(281,70,restrict_clause)
 EXECUTE FROM display_screen TO display_screen_end
#table_name_accept_end
#clear_screen
 CALL video(n)
 CALL text(15,4,blanks)
 CALL text(16,4,blanks)
 CALL text(17,4,blanks)
 CALL text(18,4,blanks)
 CALL text(19,4,blanks)
 CALL text(20,4,blanks)
#clear_screen_end
#display_screen_values
 CALL video(n)
 CALL video(l)
 CALL text(4,17,table_name)
 CALL text(15,25,format(sequence,"###"))
 CALL video(ul)
 CALL text(16,25,text1)
 CALL text(17,25,text2)
 CALL text(18,25,text3)
 CALL text(19,25,text4)
 CALL text(20,25,text5)
 CALL video(n)
#display_screen_values_end
#display_screen
 CALL video(n)
 CALL text(15,4,"01 Sequence        : ")
 CALL text(16,4,"02 Restrict Clause : ")
#display_screen_end
#accept_screen_fields
 IF (screen_function="A"
  AND first_add="Y")
  SET first_add = "N"
  GO TO accept_add
 ENDIF
 IF (screen_function="M"
  AND first_add="Y")
  SET first_add = "N"
  GO TO accept_screen_line_nbr
 ENDIF
 CALL video(n)
 SET accept = nochange
 CALL clear(24,1)
 CALL text(24,1,"Correct (Y/N/Q)?")
 CALL accept(24,18,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   GO TO accept_screen_fields_end
  OF "N":
   GO TO accept_screen_line_nbr
  OF "Q":
   GO TO menu
  ELSE
   GO TO accept_screen_fields
 ENDCASE
#accept_add
 CALL video(lu)
 SET accept = change
#accept_screen_01
 CALL accept(15,25,"9(3);DS")
 CASE (curscroll)
  OF 0:
   SET sequence = curaccept
   CALL text(15,25,format(sequence,"###"))
  OF 2:
   CALL text(15,25,format(sequence,"###"))
   GO TO accept_screen_01
  OF 3:
   CALL text(15,25,format(sequence,"###"))
   GO TO accept_screen_end
  ELSE
   GO TO accept_screen_02
 ENDCASE
#accept_screen_02
 CALL accept(16,25,"P(70);cdu")
 CASE (curscroll)
  OF 0:
   SET text1 = curaccept
   CALL text(16,25,text1)
  OF 2:
   CALL text(16,25,text1)
   GO TO accept_screen_01
  OF 3:
   CALL text(16,25,test1)
   GO TO accept_screen_03
  ELSE
   GO TO accept_screen_end
 ENDCASE
#accept_screen_03
 CALL accept(17,25,"P(70);cdu")
 CASE (curscroll)
  OF 0:
   SET text2 = curaccept
   CALL text(17,25,text2)
  OF 2:
   CALL text(17,25,text2)
   GO TO accept_screen_02
  OF 3:
   CALL text(17,25,text2)
   GO TO accept_screen_03
  ELSE
   GO TO accept_screen_end
 ENDCASE
#accept_screen_04
 CALL accept(18,25,"P(70);cdu")
 CASE (curscroll)
  OF 0:
   SET text3 = curaccept
   CALL text(18,25,text3)
  OF 2:
   CALL text(18,25,text3)
   GO TO accept_screen_03
  OF 3:
   CALL text(18,25,text3)
   GO TO accept_screen_05
  ELSE
   GO TO accept_screen_end
 ENDCASE
#accept_screen_05
 CALL accept(19,25,"P(70);cdu")
 CASE (curscroll)
  OF 0:
   SET text4 = curaccept
   CALL text(19,25,text4)
  OF 2:
   CALL text(19,25,text4)
   GO TO accept_screen_04
  OF 3:
   CALL text(19,25,text4)
   GO TO accept_screen_06
  ELSE
   GO TO accept_screen_end
 ENDCASE
#accept_screen_06
 CALL accept(20,25,"P(70);cdu")
 CASE (curscroll)
  OF 0:
   SET text5 = curaccept
   CALL text(20,25,text5)
  OF 2:
   CALL text(20,25,text5)
   GO TO accept_screen_05
  OF 3:
   CALL text(20,25,text5)
   GO TO accept_screen_end
  ELSE
   GO TO accept_screen_end
 ENDCASE
#accept_screen_end
 GO TO accept_screen_fields
#accept_screen_line_nbr
 CALL video(n)
 CALL clear(24,1)
 CALL text(24,1,"Line")
 CALL video(lu)
 SET accept = nochange
 CALL accept(24,15,"99;",0
  WHERE curaccept >= 0
   AND curaccept < 7)
 CALL clear(24,1)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO accept_screen_fields
  OF 1:
   GO TO accept_screen_01
  OF 2:
   GO TO accept_screen_02
  OF 3:
   GO TO accept_screen_03
  OF 4:
   GO TO accept_screen_04
  OF 5:
   GO TO accept_screen_05
  OF 6:
   GO TO accept_screen_06
  ELSE
   GO TO accept_screen_line_nbr
 ENDCASE
#accept_screen_fields_end
#9999_end
END GO
