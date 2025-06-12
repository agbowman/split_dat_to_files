CREATE PROGRAM dm_delete_all_rows:dba
 PAINT
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  WITH nocounter
 ;end select
 IF (curqual)
  CALL text(4,1,"*** Cannot run this script in the Engineering Domains ***")
  CALL text(5,1,"")
  CALL text(6,1,"")
  GO TO end_program
 ENDIF
 CALL text(2,1,"***** This program will DELETE ALL ROWS IN ALL TABLES!!! *****")
 CALL text(3,1,"***** This program will DELETE ALL ROWS IN ALL TABLES!!! *****")
 CALL text(4,1,"***** This program will DELETE ALL ROWS IN ALL TABLES!!! *****")
 CALL text(5,1,"***** This program will DELETE ALL ROWS IN ALL TABLES!!! *****")
 CALL text(6,1,"***** This program will DELETE ALL ROWS IN ALL TABLES!!! *****")
#display
 CALL text(8,1,"Are you sure you want to DELETE ALL ROWS in All Tables (Y/N): N")
 SET validate = 0
 CALL accept(8,63,"A;cu","N")
 IF (curaccept != "N"
  AND curaccept != "Y")
  GO TO display
 ELSEIF (curaccept="N")
  GO TO end_program
 ENDIF
#display2
 CALL text(10,1,"Are you REALLY SURE you want to DELETE ALL ROWS (Y/N): N")
 SET validate = 0
 CALL accept(10,56,"A;cu","N")
 IF (curaccept != "N"
  AND curaccept != "Y")
  GO TO display2
 ELSEIF (curaccept="N")
  GO TO end_program
 ENDIF
 SET message = nowindow
 FREE RECORD cons_lst
 RECORD cons_lst(
   1 cnt = i4
   1 qual[*]
     2 cons_tbl_name = vc
     2 cons_name = vc
 )
 SET cons_lst->cnt = 0
 SET stat = alterlist(cons_lst->qual,cons_lst->cnt)
 SELECT INTO "nl:"
  u.table_name, u.constraint_name
  FROM user_constraints u
  WHERE u.constraint_type="R"
   AND u.status="ENABLED"
  DETAIL
   cons_lst->cnt = (cons_lst->cnt+ 1), stat = alterlist(cons_lst->qual,cons_lst->cnt), cons_lst->
   qual[cons_lst->cnt].cons_tbl_name = trim(u.table_name),
   cons_lst->qual[cons_lst->cnt].cons_name = trim(u.constraint_name)
  WITH counter
 ;end select
 CALL echo("*** Disable FK Constraints ***")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 FOR (xj = 1 TO value(cons_lst->cnt))
   CALL echo(build("Disable FK: ",format(xj,"####")," of ",format(cons_lst->cnt,"####"),"::",
     cons_lst->qual[xj].cons_name))
   SET cons_buff = fillstring(300," ")
   SET cons_buff = concat("RDB ALTER TABLE ",cons_lst->qual[xj].cons_tbl_name," DISABLE CONSTRAINT ",
    cons_lst->qual[xj].cons_name," GO ")
   CALL parser(cons_buff)
 ENDFOR
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("*** All FK's Disabled ***")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 FREE RECORD tbl_lst
 RECORD tbl_lst(
   1 cnt = i4
   1 qual[*]
     2 table_name = vc
 )
 SET tbl_lst->cnt = 0
 SET stat = alterlist(tbl_lst->qual,tbl_lst->cnt)
 SELECT INTO "nl:"
  u.table_name
  FROM user_tables u
  DETAIL
   tbl_lst->cnt = (tbl_lst->cnt+ 1), stat = alterlist(tbl_lst->qual,tbl_lst->cnt), tbl_lst->qual[
   tbl_lst->cnt].table_name = trim(u.table_name)
  WITH counter
 ;end select
 CALL echo("*** Deleting All Rows In Process ***")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 FOR (xi = 1 TO value(tbl_lst->cnt))
   CALL echo(build("Table: ",format(xi,"####")," of ",format(tbl_lst->cnt,"#### "),"::",
     tbl_lst->qual[xi].table_name))
   SET del_buff = fillstring(300," ")
   SET del_buff = concat("rdb truncate table ",tbl_lst->qual[xi].table_name," reuse storage go ")
   CALL parser(del_buff)
 ENDFOR
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("*** All Rows Deleted Complete ***")
 CALL echo("")
 CALL echo("")
 CALL echo("")
#end_program
 SET help = off
 SET message = nowindow
END GO
