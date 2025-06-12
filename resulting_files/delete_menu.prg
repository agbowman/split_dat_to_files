CREATE PROGRAM delete_menu
 PAINT
 SET width = 132
 SET modify = system
 SET delete_status = 0
#0100_start
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Database Delete Menu",w)
 CALL text(5,5," 1  Maintain Delete Control Table")
 CALL text(7,5," 2  Maintain Delete Table List")
 CALL text(9,5," 3  Build Foriegn Key Table")
 CALL text(11,5," 4  Execute/Start Delete")
 CALL text(13,5," 5  Exit")
 CALL text(24,1,"Select Option ? ")
 CALL accept(24,17,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CALL clear(24,1)
 SET choice = curaccept
 CASE (choice)
  OF 1:
   EXECUTE delete_control
  OF 2:
   EXECUTE delete_table_list
  OF 3:
   EXECUTE FROM 1000_tblfk TO 1000_tblfk_exit
  OF 4:
   SELECT INTO "nl:"
    a.delete_status_ind
    FROM dm_env_del_control a
    WHERE a.control_name="DELETE_CONTROL"
    DETAIL
     delete_status = a.delete_status_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL video(n)
    SET accept = change
    CALL clear(24,1)
    CALL text(24,2,"Delete Control not found - use # 1 to establish")
    CALL accept(24,50,"p;cu")
    CALL clear(24,1)
    GO TO 0100_start
   ENDIF
   IF (delete_status != 0)
    CALL video(n)
    SET accept = change
    CALL clear(24,1)
    CALL text(24,2,"Delete Control Status not 0 - use # 1 to review")
    CALL accept(24,50,"p;cu")
    CALL clear(24,1)
    GO TO 0100_start
   ENDIF
   SELECT INTO "nl:"
    d.*
    FROM dm_env_del_tbl_fk d
    WITH maxqual(d,1), nocounter
   ;end select
   IF (curqual=0)
    CALL video(n)
    SET accept = change
    CALL clear(24,1)
    CALL text(24,2,"Foreign Key Table not found - use # 3 to build")
    CALL accept(24,50,"p;cu")
    CALL clear(24,1)
    GO TO 0100_start
   ENDIF
   CALL video(bi)
   CALL text(11,50," ** Delete Executing **")
   RDB asis ( "Begin DATABASE_DELETE; End;" )
   END ;Rdb
   SELECT INTO "nl:"
    a.delete_status_ind
    FROM dm_env_del_control a
    WHERE a.control_name="DELETE_CONTROL"
    DETAIL
     delete_status = a.delete_status_ind
    WITH nocounter
   ;end select
   CALL video(bi)
   SET accept = change
   CALL clear(24,1)
   IF (delete_status=1)
    CALL text(24,2,"Delete Completed Successfully")
   ELSE
    CALL text(24,2,"Delete Completed with Error - check Delete Audit")
   ENDIF
   CALL accept(24,50,"p;cu")
   CALL video(n)
   CALL clear(24,1)
  OF 5:
   GO TO 9999_end
 ENDCASE
 GO TO 0100_start
#0199_start_exit
#1000_tblfk
 SELECT INTO "nl:"
  d.*
  FROM dm_env_del_tbl_fk d
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
  CALL text(12,41,"   Rows currently exist in the DM_ENV_DEL_TBK_FK ")
  CALL text(13,41,"   table.  If you continue this table will be    ")
  CALL text(14,41,"   rebuilt.                                      ")
  CALL text(15,41,"                                                 ")
  CALL video(r)
  CALL text(17,41,"  **  Enter <C> to Continue or <Q> to Quit   **  ")
  CALL video(n)
  CALL accept(17,84,"p;CDU","Q"
   WHERE curaccept IN ("C", "Q"))
  IF (curaccept="C")
   EXECUTE FROM 9000_delete_dm_env_del_tbl_fk TO 9099_delete_dm_env_del_tbl_fk_exit
   FOR (x = 9 TO 18)
     CALL clear(x,40,51)
   ENDFOR
  ELSE
   GO TO 0100_start
  ENDIF
 ENDIF
 CALL video(bi)
 CALL text(9,50," ** Building Foreign Key Table **")
 INSERT  FROM dm_env_del_tbl_fk
  (child_table, child_col_name, parent_table,
  parent_col_name)(SELECT
   b.table_name, c.column_name, a.table_name,
   d.column_name
   FROM user_constraints a,
    user_cons_columns c,
    user_cons_columns d,
    user_constraints b
   WHERE b.constraint_type="R"
    AND b.r_constraint_name=a.constraint_name
    AND b.constraint_name=c.constraint_name
    AND a.owner=b.owner
    AND a.constraint_name=d.constraint_name
    AND a.table_name != b.table_name
    AND a.owner=user)
 ;end insert
 COMMIT
#1000_tblfk_exit
#9000_delete_dm_env_del_tbl_fk
 DELETE  FROM dm_env_del_tbl_fk
  WHERE 1=1
 ;end delete
 COMMIT
#9099_delete_dm_env_del_tbl_fk_exit
#9999_end
END GO
