CREATE PROGRAM dm_afd_fix_schema:dba
 EXECUTE dm_temp_check
 CALL parser("rdb alter session set nls_sort = BINARY go",1)
 FREE SET dropped_cons_list
 RECORD dropped_cons_list(
   1 cons_name[*]
     2 cname = c32
   1 cons_count = i4
 )
 SET filename2 = "dm_afd_fix_schema2"
 SET filename3 = "dm_afd_fix_schema3"
 SET filename4 = "dm_afd_fix_schema4.dat"
 SET envid = 0
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   envid = d.environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Name")
  GO TO end_program
 ENDIF
 SET loopcount = 0
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "%o  ", filename4, row + 2,
   "set filename3='", filename3, "' go",
   row + 1, "set trace symbol mark go", row + 2
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename3)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SET reset_error = 1
 FREE SET table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = c32
     2 created_flg = i2
   1 table_count = i4
 )
 SET stat = alterlist(table_list->table_name,10)
 SET table_list->table_count = 0
 SELECT INTO "nl:"
  FROM dm_afd_tables dtl,
   dm_alpha_features_env da
  WHERE (dtl.alpha_feature_nbr=request->afdnumber)
   AND dtl.alpha_feature_nbr=da.alpha_feature_nbr
   AND da.status != "SUCCESS"
   AND da.environment_id=envid
  ORDER BY dtl.table_name
  DETAIL
   table_list->table_count = (table_list->table_count+ 1)
   IF (mod(table_list->table_count,10)=1
    AND (table_list->table_count != 1))
    stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
   ENDIF
   table_list->table_name[table_list->table_count].tname = dtl.table_name, table_list->table_name[
   table_list->table_count].created_flg = 0
  WITH nocounter
 ;end select
 SET tname = fillstring(32," ")
 FOR (loopcount = 1 TO table_list->table_count)
   SET tname = cnvtupper(table_list->table_name[loopcount].tname)
   SELECT INTO value(filename2)
    *
    FROM dual
    DETAIL
     IF (reset_error=1)
      "set error_msg=fillstring(255,' ') go", row + 1, "set msg=fillstring(255,' ') go",
      row + 1, "set rstring=fillstring(155,' ') go", row + 1,
      "set rstring1=fillstring(155,' ') go", row + 1, "set msgnum=0 go",
      row + 1, reset_error = 0
     ENDIF
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   SELECT INTO "nl:"
    FROM dm_afd_tables dt
    WHERE dt.table_name=tname
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_user_tab_cols ut
     WHERE ut.table_name=dt.table_name)))
    WITH nocounter
   ;end select
   IF (curqual=1)
    SET x = 1
    EXECUTE dm_afd_create_tables tname
    SELECT INTO "nl:"
     FROM dual
     DETAIL
      table_list->table_name[loopcount].created_flg = 1
     WITH format = stream, noheading, append,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
   ENDIF
 ENDFOR
 SET tname = fillstring(32," ")
 FOR (loopcount = 1 TO table_list->table_count)
   SET tname = cnvtupper(table_list->table_name[loopcount].tname)
   SELECT INTO value(filename2)
    *
    FROM dual
    DETAIL
     IF (reset_error=1)
      "set error_msg=fillstring(255,' ') go", row + 1, "set msg=fillstring(255,' ') go",
      row + 1, "set rstring=fillstring(155,' ') go", row + 1,
      "set rstring1=fillstring(155,' ') go", row + 1, "set msgnum=0 go",
      row + 1, reset_error = 0
     ENDIF
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   SET stat = alterlist(dropped_cons_list->cons_name,0)
   SET dropped_cons_list->cons_count = 0
   IF ((table_list->table_name[loopcount].created_flg != 1))
    SET x = 2
    EXECUTE dm_afd_fix_columns tname
   ENDIF
   SET x = 3
   EXECUTE dm_afd_fix_indexes tname, table_list->table_name[loopcount].created_flg, envid
   SET x = 4
   EXECUTE dm_afd_fix_constraints tname, table_list->table_name[loopcount].created_flg
   SELECT INTO value(filename2)
    *
    FROM dual
    DETAIL
     "execute dm_user_last_updt go", row + 2
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 ENDFOR
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "%o", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#end_program
END GO
