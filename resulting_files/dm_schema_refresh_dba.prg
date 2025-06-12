CREATE PROGRAM dm_schema_refresh:dba
 CALL parser("rdb alter session set nls_sort = BINARY go",1)
 SET filename1 = concat( $1,"1")
 SET filename2 = concat( $1,"2")
 SET filename3 = concat( $1,"3")
 SET filename4 = concat( $1,"4.dat")
 RECORD reply(
   1 request_id = i4
   1 ops_event = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET loopcount = 0
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "%o  ", filename4, row + 1,
   "set message 0 go", row + 2
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO value(filename3)
  *
  FROM dual
  DETAIL
   " ", row + 1
  WITH format = stream, noheading, maxcol = 512,
   maxrow = 1, formfeed = none
 ;end select
 EXECUTE dm_temp_check
 IF (currdbuser="CDBA")
  SELECT INTO "nl:"
   a.table_name
   FROM dm_user_tab_cols a
   WHERE a.table_name="DM_TABLES"
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   a.table_name
   FROM dm_user_tab_cols a
   WHERE a.table_name="CODE_VALUE"
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SELECT INTO value(filename3)
   *
   FROM dual
   DETAIL
    "The table dm_user_tab_cols is not built  or does not have a CCL definition.Refresh failed.", row
     + 1
   WITH format = stream, noheading, maxcol = 512,
    append, formfeed = none, maxrow = 1
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO value(filename1)
  ds.sequence_name, ds.min_value, ds.max_value,
  ds.increment_by, ds.cycle
  FROM dm_sequences ds
  ORDER BY ds.sequence_name
  DETAIL
   row + 1, ";****************************************************************************", row + 1,
   ";", ds.sequence_name, row + 1,
   ";****************************************************************************", row + 1,
   "rdb CREATE SEQUENCE ",
   ds.sequence_name, " INCREMENT BY ", ds.increment_by,
   " START WITH ", min_value = cnvtstring(ds.min_value), min_value
   IF (ds.cycle="Y")
    row + 1, max_value = cnvtstring(ds.max_value), "MAXVALUE ",
    max_value, " CYCLE"
   ENDIF
   row + 1, "go", ";",
   row + 1
  WITH format = stream, noheading, maxrow = 1,
   formfeed = none
 ;end select
 FREE SET rec_schema_date
 RECORD rec_schema_date(
   1 v_schema_date = dq8
 )
 FREE SET table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = c32
     2 schema_date = dq8
     2 backout_ind = i4
   1 table_count = i4
 )
 SET stat = alterlist(table_list->table_name,10)
 SET table_list->table_count = 0
 IF (( $3 > 0))
  SET nbr_tables = 0
  SET nbr_tables = size(feature_table_list->table_name,5)
  IF (nbr_tables=0)
   CALL echo("No table in the table list")
   GO TO exit_script
  ELSE
   FOR (i = 1 TO nbr_tables)
     IF (trim(feature_table_list->table_name[i].tname) != ""
      AND (feature_table_list->table_name[i].schema_dt_tm != 0)
      AND (feature_table_list->table_name[i].fill_status=0)
      AND (feature_table_list->table_name[i].error_flag > 0))
      SET feature_table_list->table_name[i].refreshed = 1
      SET table_list->table_count = (table_list->table_count+ 1)
      IF (mod(table_list->table_count,10)=1
       AND (table_list->table_count != 1))
       SET stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
      ENDIF
      SET table_list->table_name[table_list->table_count].tname = feature_table_list->table_name[i].
      tname
      SET table_list->table_name[table_list->table_count].schema_date = feature_table_list->
      table_name[i].schema_dt_tm
      SET table_list->table_name[table_list->table_count].backout_ind = feature_table_list->
      table_name[i].backout_ind
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SELECT INTO "nl:"
   dtl.table_name
   FROM dm_table_list dtl
   WHERE process_flg=2
   ORDER BY dtl.table_name
   DETAIL
    table_list->table_count = (table_list->table_count+ 1)
    IF (mod(table_list->table_count,10)=1
     AND (table_list->table_count != 1))
     stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
    ENDIF
    table_list->table_name[table_list->table_count].tname = dtl.table_name
   WITH nocounter
  ;end select
 ENDIF
 SET tname = fillstring(32," ")
 SET temp_tname = fillstring(32," ")
 SET source_table = fillstring(30," ")
 SET target_table = fillstring(30," ")
 SET from_column[500] = fillstring(80," ")
 SET to_column[500] = fillstring(80," ")
 SET old_base_data_type = fillstring(1," ")
 SET new_base_data_type = fillstring(1," ")
 FOR (loopcount = 1 TO table_list->table_count)
   IF (( $3 > 0))
    SET rec_schema_date->v_schema_date = table_list->table_name[loopcount].schema_date
   ELSE
    SET rec_schema_date->v_schema_date = cnvtdatetime( $2)
   ENDIF
   SET tname = cnvtupper(table_list->table_name[loopcount].tname)
   SET temp_tname = substring(1,29,concat("TEMP_",cnvtupper(table_list->table_name[loopcount].tname))
    )
   SELECT INTO value(filename2)
    *
    FROM dual
    DETAIL
     IF (( $3=0))
      "free set all go", row + 1
     ENDIF
     "set trace symbol mark go", row + 1, "set error_msg=fillstring(255,' ') go",
     row + 1, "set msg=fillstring(255,' ') go", row + 1,
     "set rstring=fillstring(155,' ') go", row + 1, "set rstring1=fillstring(155,' ') go",
     row + 1, "set msgnum=0 go ", row + 1,
     "set filename3 = '", filename3, "' go ",
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   SET temp_file_exists = 0
   SELECT INTO value(filename2)
    ut.*
    FROM user_tables ut
    WHERE ut.table_name=trim(temp_tname)
    DETAIL
     temp_file_exists = 1, 'set error_msg= concat("TEMP file ', temp_tname,
     " exists for ", tname, '.",',
     row + 1, '    "This table will not be refreshed.") go', row + 1,
     "set msgnum=100 go", row + 1, "set error_reported = 0 go",
     row + 1, 'set msg= concat("This table, ', temp_tname,
     ', must be removed before refreshing. ",', row + 1, '    "Ensure that data exists in table ',
     tname, '") go', row + 1,
     'set rstring = "" go', row + 1, 'set rstring1 = "" go',
     row + 1, "execute dm_check_errors go", row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   IF (temp_file_exists=0)
    SET deleted_table = 1
    SELECT
     IF (( $3=0))
      FROM dm_tables dt
     ELSE
      FROM dm_adm_tables dt
     ENDIF
     INTO "nl:"
     table_name
     WHERE dt.table_name=tname
      AND dt.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
     DETAIL
      deleted_table = 0
     WITH nocounter
    ;end select
    SET renamed_table = 0
    IF (deleted_table=1)
     SELECT INTO "nl:"
      old_table_name
      FROM dm_renamed_tbls dt
      WHERE dt.old_table_name=tname
      DETAIL
       renamed_table = 1
      WITH nocounter
     ;end select
    ENDIF
    IF (((renamed_table=0
     AND deleted_table=1) OR ((table_list->table_name[loopcount].backout_ind=1))) )
     SELECT INTO value(filename3)
      *
      FROM dual
      DETAIL
       IF ((table_list->table_name[loopcount].backout_ind=1))
        "The table ", tname, "belongs only to a feature",
        row + 1, "that was backed out and will be dropped.", row + 1,
        row + 1
       ELSE
        "The table ", tname, "does not exist",
        row + 1, "and will be dropped.", row + 1,
        row + 1
       ENDIF
      WITH format = stream, noheading, maxcol = 512,
       append, formfeed = none, maxrow = 1
     ;end select
     SELECT INTO value(filename2)
      *
      FROM dual
      DETAIL
       "RDB DROP TABLE ", tname, " CASCADE CONSTRAINTS GO",
       row + 1, "DROP TABLE ", tname,
       " GO", row + 1
      WITH format = stream, noheading, formfeed = none,
       maxcol = 512, append, maxrow = 1
     ;end select
    ELSEIF (renamed_table=0)
     SET source_table = tname
     SET target_table = tname
     SELECT INTO value(filename2)
      dt.old_table_name, dt.new_table_name
      FROM user_tables ut,
       dm_renamed_tbls dt
      WHERE dt.new_table_name=tname
       AND dt.old_table_name=ut.table_name
      DETAIL
       source_table = dt.old_table_name, target_table = dt.new_table_name, "RDB RENAME ",
       dt.old_table_name, " TO ", dt.new_table_name,
       " GO", row + 1, "execute oragen3 '",
       dt.new_table_name, "' GO"
      WITH format = stream, noheading, formfeed = none,
       maxcol = 512, append, maxrow = 1
     ;end select
     SET source_table_exists = 0
     SELECT INTO "nl:"
      table_name
      FROM user_tables dt
      WHERE dt.table_name=source_table
      DETAIL
       source_table_exists = 1
      WITH nocounter
     ;end select
     SET initial_extent = 0
     SET next_extent = 0
     SET bytes = 0
     IF (source_table_exists=1)
      SELECT INTO value(filename2)
       b.table_name, b.constraint_name, c.table_name
       FROM dm_user_constraints b,
        dm_user_constraints c
       WHERE c.constraint_type IN ("P", "U")
        AND b.r_constraint_name=c.constraint_name
        AND c.table_name=tname
        AND c.owner=currdbuser
       ORDER BY b.table_name, b.constraint_name
       DETAIL
        "RDB ALTER TABLE ", b.table_name, " DROP CONSTRAINT ",
        b.constraint_name, " GO", row + 1
       WITH format = stream, noheading, append,
        formfeed = none, maxcol = 512, maxrow = 1
      ;end select
      SELECT
       IF (( $3=0))
        FROM dm_constraints b
       ELSE
        FROM dm_adm_constraints b
       ENDIF
       INTO value(filename2)
       b.table_name, b.constraint_name, b.parent_table_name,
       b.status_ind
       WHERE b.constraint_type="R"
        AND b.parent_table_name=tname
        AND b.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
        AND b.table_name != b.parent_table_name
       ORDER BY b.table_name, b.constraint_name
       DETAIL
        "RDB ALTER TABLE ", b.table_name, row + 1,
        "DROP CONSTRAINT ", b.constraint_name, " go",
        row + 1
       WITH format = stream, noheading, append,
        formfeed = none, maxcol = 512, maxrow = 1
      ;end select
      SELECT INTO value(filename2)
       *
       FROM dual
       DETAIL
        "RDB RENAME ", tname, " TO ",
        temp_tname, " GO", row + 1,
        "RDB ALTER TABLE ", temp_tname, " DROP PRIMARY KEY GO",
        row + 1, "execute oragen3 '", temp_tname,
        "' GO"
       WITH format = stream, noheading, formfeed = none,
        maxcol = 512, append, maxrow = 1
      ;end select
      SELECT INTO "nl:"
       us.bytes, us.next_extent, us.initial_extent,
       us.extents
       FROM dm_segments us
       WHERE segment_name=tname
        AND segment_type="TABLE"
       DETAIL
        IF (us.extents < 10)
         bytes = us.initial_extent
         IF (bytes > 10240)
          initial_extent = (us.initial_extent/ 1024), next_extent = (us.next_extent/ 1024)
         ELSE
          initial_extent = us.initial_extent, next_extent = us.next_extent
         ENDIF
        ELSE
         bytes = us.bytes
         IF (us.bytes > 10240)
          initial_extent = (us.bytes/ 5120), next_extent = (us.bytes/ 5120)
         ELSE
          initial_extent = (us.bytes/ 2), next_extent = (us.bytes/ 2)
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     SELECT
      IF (( $3=0))
       FROM dm_columns uic,
        dm_tables uc
      ELSE
       FROM dm_adm_columns uic,
        dm_adm_tables uc
      ENDIF
      INTO value(filename2)
      uic.column_name, uic.data_type, uic.data_length,
      uic.nullable, uic.column_seq, uc.tablespace_name,
      uc.table_name, default_value = substring(1,150,uic.data_default)
      WHERE uc.table_name=tname
       AND uc.table_name=uic.table_name
       AND uc.schema_date=uic.schema_date
       AND uc.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
      ORDER BY uc.table_name, uic.column_seq
      HEAD uc.table_name
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       "set error_reported = 0 go",
       row + 1, "rdb CREATE TABLE ", uc.table_name,
       row + 1, col 10, "("
      DETAIL
       IF (uic.column_seq > 1)
        ","
       ENDIF
       row + 1, col 10, uic.column_name,
       col 50, uic.data_type
       IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
        col 60, "(", col 61,
        uic.data_length"####;;I", col 66, ")"
       ENDIF
       IF (default_value != fillstring(70," "))
        " DEFAULT ", default_value
       ENDIF
       IF (uic.nullable="N")
        " NOT NULL"
       ENDIF
      FOOT  uc.table_name
       row + 1, col 10, ")",
       row + 1
       IF (initial_extent > 0)
        IF (bytes > 10240)
         " STORAGE ( INITIAL ", initial_extent, "K NEXT ",
         next_extent, "K)", row + 1
        ELSE
         " STORAGE ( INITIAL ", initial_extent, " NEXT ",
         next_extent, ")", row + 1
        ENDIF
       ENDIF
       col 10, " TABLESPACE ", uc.tablespace_name,
       row + 1, "go", row + 1,
       "set error_reported = 0 go", row + 1,
       'select into "nl:" msgnum=error(msg,1) with nocounter go',
       row + 1, 'set error_msg= "', "create table ",
       uc.table_name, '" go', row + 1,
       'set rstring = "rdb rename ', temp_tname, " to ",
       tname, ' go" go', row + 1,
       'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
       row + 1, "execute oragen3 '", uc.table_name,
       "' GO", row + 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
     SET column_count = 0
     IF (source_table_exists=1)
      SET long_column_to_copy = 0
      SELECT
       IF (( $3=0))
        FROM dm_columns dc
       ELSE
        FROM dm_adm_columns dc
       ENDIF
       INTO "nl:"
       dc.data_type
       WHERE dc.table_name=tname
        AND ((dc.data_type="LONG*") OR (dc.data_type="RAW*"))
        AND dc.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
       DETAIL
        long_column_to_copy = 1
       WITH nocounter
      ;end select
      IF (long_column_to_copy=0)
       SELECT
        IF (( $3=0))
         FROM dm_user_tab_cols uic,
          dm_columns dc
        ELSE
         FROM dm_user_tab_cols uic,
          dm_adm_columns dc
        ENDIF
        INTO "nl:"
        uic.column_name, uic.table_name, uic.column_id,
        uic.data_type, dc.data_type, dc.nullable,
        dc.data_length
        WHERE dc.table_name=tname
         AND uic.column_name=dc.column_name
         AND uic.table_name=trim(source_table)
         AND dc.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
        ORDER BY uic.column_id
        DETAIL
         IF (((uic.data_type="NUMBER   ") OR (uic.data_type="FLOAT    ")) )
          old_base_data_type = "N"
         ELSEIF (((uic.data_type="CHAR     ") OR (((uic.data_type="VARCHAR2 ") OR (uic.data_type=
         "VARCHAR  ")) )) )
          old_base_data_type = "C"
         ELSE
          old_base_data_type = "D"
         ENDIF
         IF (((dc.data_type="NUMBER   ") OR (dc.data_type="FLOAT    ")) )
          new_base_data_type = "N"
         ELSEIF (((dc.data_type="CHAR     ") OR (((dc.data_type="VARCHAR2 ") OR (dc.data_type=
         "VARCHAR  ")) )) )
          new_base_data_type = "C"
         ELSE
          new_base_data_type = "D"
         ENDIF
         IF (new_base_data_type=old_base_data_type)
          column_count = (column_count+ 1), to_column[column_count] = uic.column_name
          IF (dc.nullable != "Y")
           IF (((uic.data_type="NUMBER   ") OR (uic.data_type="FLOAT    ")) )
            from_column[column_count] = concat("nvl(",uic.column_name,",0)")
           ELSEIF (uic.data_type="DATE     ")
            from_column[column_count] = concat("nvl(",uic.column_name,",SYSDATE)")
           ELSE
            from_column[column_count] = concat("nvl(substr(",uic.column_name,",1,",cnvtstring(dc
              .data_length),"),'NULL')")
           ENDIF
          ELSE
           IF (new_base_data_type="C")
            from_column[column_count] = concat("substr(",uic.column_name,",1,",cnvtstring(dc
              .data_length),")")
           ELSE
            from_column[column_count] = uic.column_name
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       SELECT
        IF (( $3=0))
         FROM dm_user_tab_cols utc,
          dm_columns uic,
          dm_renamed_cols dc
        ELSE
         FROM dm_user_tab_cols utc,
          dm_adm_columns uic,
          dm_renamed_cols dc
        ENDIF
        INTO "nl:"
        dc.old_col_name, dc.new_col_name, dc.table_name,
        uic.data_type, uic.data_length, uic.nullable
        WHERE dc.table_name=tname
         AND dc.table_name=uic.table_name
         AND dc.new_col_name=uic.column_name
         AND utc.data_type=uic.data_type
         AND uic.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
         AND dc.old_col_name=utc.column_name
         AND dc.table_name=utc.table_name
        DETAIL
         found_it = 0, cnt = 0
         FOR (cnt = 1 TO column_count)
           IF ((to_column[cnt]=dc.new_col_name))
            found_it = 1
           ENDIF
         ENDFOR
         IF (found_it=0)
          column_count = (column_count+ 1), to_column[column_count] = dc.new_col_name
          IF (uic.nullable != "Y")
           IF (((uic.data_type="NUMBER   ") OR (uic.data_type="FLOAT    ")) )
            from_column[column_count] = concat("nvl(",dc.old_col_name,",0)")
           ELSEIF (uic.data_type="DATE     ")
            from_column[column_count] = concat("nvl(",dc.old_col_name,",SYSDATE)")
           ELSE
            from_column[column_count] = concat("nvl(substr(",dc.old_col_name,",1,",cnvtstring(uic
              .data_length),"),'NULL')")
           ENDIF
          ELSE
           IF (((uic.data_type="CHAR     ") OR (((uic.data_type="VARCHAR2 ") OR (uic.data_type=
           "VARCHAR  ")) )) )
            from_column[column_count] = concat("substr(",dc.old_col_name,",1,",cnvtstring(uic
              .data_length),")")
           ELSE
            from_column[column_count] = dc.old_col_name
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       SELECT
        IF (( $3=0))
         FROM dm_columns dc
        ELSE
         FROM dm_adm_columns dc
        ENDIF
        INTO "nl:"
        dc.column_name, dc.table_name, dc.column_seq,
        dc.data_type, dc.nullable
        WHERE dc.table_name=tname
         AND dc.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
         AND dc.nullable="N"
        DETAIL
         found_it = 0, cnt = 0
         FOR (cnt = 1 TO column_count)
           IF ((to_column[cnt]=dc.column_name))
            found_it = 1
           ENDIF
         ENDFOR
         IF (found_it=0)
          column_count = (column_count+ 1), to_column[column_count] = dc.column_name
          IF (((dc.data_type="NUMBER   ") OR (dc.data_type="FLOAT    ")) )
           from_column[column_count] = "0"
          ELSEIF (dc.data_type="DATE     ")
           from_column[column_count] = "SYSDATE"
          ELSE
           from_column[column_count] = "'NULL'"
          ENDIF
         ENDIF
        WITH noheading
       ;end select
       SET cnt = 0
       SELECT INTO value(filename2)
        *
        FROM dual
        DETAIL
         'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "RDB INSERT INTO ",
         tname, row + 1, "("
         FOR (cnt = 1 TO column_count)
          IF (cnt > 1)
           ",", row + 1
          ENDIF
          ,to_column[cnt]
         ENDFOR
         row + 1, ")", row + 1,
         "select "
         FOR (cnt = 1 TO column_count)
          IF (cnt > 1)
           ",", row + 1
          ENDIF
          ,from_column[cnt]
         ENDFOR
         row + 1, "from ", temp_tname,
         row + 1, "go", row + 1,
         "commit go", row + 1, "set error_reported = 0 go",
         row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
         'set error_msg= "', "copying data from-  ", temp_tname,
         " to- ", tname, '" go',
         row + 1, 'set rstring = " " go', row + 1,
         'set rstring1 = " " go', row + 2, btemp = fillstring(132," "),
         'select into "nl:" from user_tables u', row + 1, btemp = build('where u.table_name = "',
          temp_tname,'"'),
         btemp, row + 1, "detail",
         row + 1, 'rstring = "rdb drop table ', tname,
         ' cascade constraints go"', row + 1, 'rstring1 = "rdb rename ',
         temp_tname, " to ", tname,
         ' go"', row + 1, "with nocounter go",
         row + 2, "execute dm_check_errors go", row + 1
        WITH format = stream, noheading, append,
         formfeed = none, maxcol = 512, maxrow = 1
       ;end select
      ELSE
       SET vix = format(rec_schema_date->v_schema_date,"DD-MMM-YYYY HH:MM;;D")
       SET vix2 = cnvtstring( $3)
       SELECT INTO value(filename2)
        *
        FROM dual
        DETAIL
         'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "execute dm_copy_rows '",
         temp_tname, "','", tname,
         "','", vix, "',",
         vix2, " go", row + 1,
         "set error_reported = 0 go", row + 1, 'set error_msg= "',
         "copying data from-  ", temp_tname, " to- ",
         tname, '" go', row + 1,
         'set rstring = "rdb drop table ', tname, ' cascade constraints go" go',
         row + 1, 'set rstring1 = "rdb rename ', temp_tname,
         " to ", tname, ' go" go',
         row + 1, "execute dm_check_errors go", row + 1
        WITH format = stream, noheading, append,
         formfeed = none, maxcol = 512, maxrow = 1
       ;end select
      ENDIF
     ENDIF
     SELECT
      IF (( $3=0))
       FROM dm_segments us,
        dm_index_columns dic,
        dm_indexes di
      ELSE
       FROM dm_segments us,
        dm_adm_index_columns dic,
        dm_adm_indexes di
      ENDIF
      INTO value(filename2)
      dic.column_name, dic.column_position, di.table_name,
      di.index_name, di.tablespace_name, di.unique_ind,
      us.bytes, us.next_extent, us.initial_extent,
      us.extents
      PLAN (di
       WHERE di.table_name=tname
        AND di.schema_date=cnvtdatetime(rec_schema_date->v_schema_date))
       JOIN (dic
       WHERE di.index_name=dic.index_name
        AND di.schema_date=dic.schema_date)
       JOIN (us
       WHERE outerjoin(di.index_name)=us.segment_name
        AND outerjoin("INDEX")=us.segment_type)
      ORDER BY di.index_name, dic.column_position
      HEAD di.index_name
       "RDB DROP INDEX ", di.index_name, " GO",
       row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       "RDB CREATE "
       IF (di.unique_ind=1)
        "UNIQUE"
       ENDIF
       " INDEX ", di.index_name, row + 1,
       col 20, "ON ", di.table_name,
       row + 1, col 30, "("
      DETAIL
       IF (dic.column_position > 1)
        ","
       ENDIF
       row + 1, col 30, dic.column_name
      FOOT  di.index_name
       IF (us.extents < 10)
        bytes = us.initial_extent
        IF (bytes > 10240)
         initial_extent = (us.initial_extent/ 1024), next_extent = (us.next_extent/ 1024)
        ELSE
         initial_extent = us.initial_extent, next_extent = us.next_extent
        ENDIF
       ELSE
        bytes = us.bytes
        IF (us.bytes > 10240)
         initial_extent = (us.bytes/ 5120), next_extent = (us.bytes/ 5120)
        ELSE
         initial_extent = (us.bytes/ 2), next_extent = (us.bytes/ 2)
        ENDIF
       ENDIF
       row + 1, col 30, ")",
       row + 1
       IF (initial_extent > 0)
        IF (bytes > 10240)
         " STORAGE ( INITIAL ", initial_extent, "K NEXT ",
         next_extent, "K)", row + 1
        ELSE
         " STORAGE ( INITIAL ", initial_extent, " NEXT ",
         next_extent, ")", row + 1
        ENDIF
       ENDIF
       col 20, " TABLESPACE ", di.tablespace_name,
       row + 1, "go", row + 1,
       "set error_reported = 0 go", row + 1,
       'select into "nl:" msgnum=error(msg,1) with nocounter go',
       row + 1, 'set error_msg= "', "create index-",
       di.index_name, " on- ", di.table_name,
       '" go', row + 1, 'set rstring = "" go',
       row + 1, 'set rstring1 = "" go', row + 1,
       "execute dm_check_errors go", row + 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
     SELECT
      IF (( $3=0))
       FROM dm_cons_columns ucc,
        dm_constraints uc
      ELSE
       FROM dm_adm_cons_columns ucc,
        dm_adm_constraints uc
      ENDIF
      INTO value(filename2)
      uc.constraint_name, uc.table_name, ucc.column_name,
      ucc.position, uc.status_ind
      WHERE ucc.constraint_name=uc.constraint_name
       AND ucc.table_name=uc.table_name
       AND uc.table_name=tname
       AND uc.constraint_type="P"
       AND uc.schema_date=ucc.schema_date
       AND uc.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
      ORDER BY uc.constraint_name, ucc.position
      HEAD uc.table_name
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "RDB ALTER TABLE ",
       col 20, uc.table_name, row + 1,
       col 20, " ADD CONSTRAINT ", uc.constraint_name,
       row + 1, col 30, " PRIMARY KEY ("
      DETAIL
       IF (ucc.position > 1)
        ","
       ENDIF
       row + 1, col 10, ucc.column_name
      FOOT  uc.table_name
       row + 1, col 10, ")",
       row + 1
       IF (uc.status_ind=0)
        "DISABLE"
       ENDIF
       row + 1, "go", row + 1,
       "set error_reported = 0 go", row + 1,
       'select into "nl:" msgnum=error(msg,1) with nocounter go',
       row + 1, 'set error_msg= "', "create primary key constraint for- ",
       uc.table_name, '" go', row + 1,
       'set rstring = "" go', row + 1, 'set rstring1 = "" go',
       row + 1, "execute dm_check_errors go", row + 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
     SELECT
      IF (( $3=0))
       FROM dm_cons_columns ucc,
        dm_constraints uc
      ELSE
       FROM dm_adm_cons_columns ucc,
        dm_adm_constraints uc
      ENDIF
      INTO value(filename2)
      uc.constraint_name, uc.table_name, ucc.column_name,
      ucc.position, uc.status_ind
      WHERE ucc.constraint_name=uc.constraint_name
       AND ucc.table_name=uc.table_name
       AND uc.table_name=tname
       AND uc.constraint_type="U"
       AND uc.schema_date=ucc.schema_date
       AND uc.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
      ORDER BY uc.constraint_name, ucc.position
      HEAD uc.table_name
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "RDB ALTER TABLE ",
       col 20, uc.table_name, row + 1,
       col 20, " ADD CONSTRAINT ", uc.constraint_name,
       row + 1, col 30, " UNIQUE ("
      DETAIL
       IF (ucc.position > 1)
        ","
       ENDIF
       row + 1, col 10, ucc.column_name
      FOOT  uc.table_name
       row + 1, col 10, ")",
       row + 1
       IF (uc.status_ind=0)
        "DISABLE"
       ENDIF
       row + 1, "go", row + 1,
       "set error_reported = 0 go", row + 1,
       'select into "nl:" msgnum=error(msg,1) with nocounter go',
       row + 1, 'set error_msg= "', "create unique key constraint for- ",
       uc.table_name, '" go', row + 1,
       'set rstring = "" go', row + 1, 'set rstring1 = "" go',
       row + 1, "execute dm_check_errors go", row + 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
     SELECT
      IF (( $3=0))
       FROM dm_cons_columns c,
        dm_constraints b
      ELSE
       FROM dm_adm_cons_columns c,
        dm_adm_constraints b
      ENDIF
      INTO value(filename2)
      c.column_name, c.position, b.table_name,
      c.constraint_name, b.parent_table_name, b.parent_table_columns,
      b.status_ind
      WHERE b.constraint_type="R"
       AND b.constraint_name=c.constraint_name
       AND b.table_name=tname
       AND b.table_name=c.table_name
       AND b.schema_date=c.schema_date
       AND b.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
      ORDER BY c.constraint_name, c.position
      HEAD c.constraint_name
       "rdb alter table ", temp_tname, " drop constraint ",
       c.constraint_name, " go", row + 1,
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "RDB ALTER TABLE ",
       col 20, b.table_name, row + 1,
       col 20, " ADD CONSTRAINT ", c.constraint_name,
       row + 1, col 30, " FOREIGN KEY ("
      DETAIL
       IF (c.position > 1)
        ","
       ENDIF
       row + 1, col 10, c.column_name
      FOOT  c.constraint_name
       row + 1, col 10, ")",
       row + 1, col 10, " REFERENCES ",
       b.parent_table_name, " (", b.parent_table_columns,
       ") ", "DISABLE", row + 1,
       "go", row + 1, "set error_reported = 0 go",
       row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       'set error_msg= "', "create foreign key constraint ", c.constraint_name,
       " on ", b.table_name, '" go',
       row + 1, 'set rstring = "" go', row + 1,
       'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
       row + 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
     SELECT
      IF (( $3=0))
       FROM dm_cons_columns c,
        dm_constraints b
      ELSE
       FROM dm_adm_cons_columns c,
        dm_adm_constraints b
      ENDIF
      INTO value(filename2)
      c.column_name, c.position, b.table_name,
      c.constraint_name, b.parent_table_name, b.parent_table_columns,
      b.status_ind
      WHERE b.constraint_type="R"
       AND b.constraint_name=c.constraint_name
       AND b.parent_table_name=tname
       AND b.table_name=c.table_name
       AND b.schema_date=c.schema_date
       AND b.schema_date=cnvtdatetime(rec_schema_date->v_schema_date)
       AND b.table_name != b.parent_table_name
      ORDER BY c.constraint_name, c.position
      HEAD c.constraint_name
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "RDB ALTER TABLE ",
       col 20, b.table_name, row + 1,
       col 20, " ADD CONSTRAINT ", c.constraint_name,
       row + 1, col 30, " FOREIGN KEY ("
      DETAIL
       IF (c.position > 1)
        ","
       ENDIF
       row + 1, col 10, c.column_name
      FOOT  c.constraint_name
       row + 1, col 10, ")",
       row + 1, col 10, " REFERENCES ",
       b.parent_table_name, " (", b.parent_table_columns,
       ") ", "DISABLE", row + 1,
       "go", row + 1, "set error_reported = 0 go",
       row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       'set error_msg= "', "create foreign key constraint ", c.constraint_name,
       " on ", b.table_name, '" go',
       row + 1, 'set rstring = "" go', row + 1,
       'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
       row + 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
     SELECT INTO value(filename2)
      count(*)
      FROM dual
      DETAIL
       IF (source_table_exists=1)
        "RDB DROP TABLE ", temp_tname, "cascade constraints GO",
        row + 1, "DROP TABLE ", temp_tname,
        " GO", row + 1
        IF (( $3 > 0))
         'execute oragen3 "', tname, '" go',
         row + 1
        ENDIF
       ELSE
        'execute oragen3 "', tname, '" go',
        row + 1
       ENDIF
       "update INTO dm_tables_doc set SCHEMA_REFRESH_DT_TM = cnvtdatetime(curdate,curtime3)", row + 1,
       'where table_name = "',
       tname, '" go', row + 1
      WITH format = stream, noheading, formfeed = none,
       maxcol = 512, append, maxrow = 1
     ;end select
    ENDIF
   ENDIF
   SELECT INTO value(filename2)
    count(*)
    FROM dual
    DETAIL
     "set trace symbol  go", row + 2
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, append, maxrow = 1
   ;end select
   SELECT INTO value(filename2)
    *
    FROM dual
    DETAIL
     "execute dm_user_last_updt go", row + 2
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 ENDFOR
 IF (( $3=1))
  SELECT INTO value(filename2)
   *
   FROM (dummyt d  WITH seq = value(feature_table_list->table_count))
   DETAIL
    IF ((feature_table_list->table_name[d.seq].feature_status=dom_name)
     AND (feature_table_list->table_name[d.seq].error_flag > 0))
     "set trace symbol mark go", row + 1, err_str = concat('DM_SCHEMA_COMP "A", "',trim(
       feature_table_list->table_name[d.seq].tname),'", "',format(feature_table_list->table_name[d
       .seq].schema_dt_tm,"DD-MMM-YYYY HH:MM;;D"),'" go'),
     err_str, row + 1, err_str1 = concat("set feature_table_list->table_name[",trim(cnvtstring(d.seq)
       ),"]->p_error = feature_table_list->param_error go"),
     err_str1, row + 1, err_str2 = concat("set feature_table_list->table_name[",trim(cnvtstring(d.seq
        )),"]->error_flag = feature_table_list->nbr_errors go"),
     err_str2, row + 1, "set feature_table_list->param_error = 0 go",
     row + 1, "set feature_table_list->nbr_errors = 0 go", row + 1,
     "set trace symbol go", row + 1
    ENDIF
   WITH format = stream, noheading, append,
    formfeed = none, maxcol = 512, maxrow = 1
  ;end select
  SELECT INTO value(filename2)
   *
   FROM dual
   DETAIL
    "update into dm_feature_tables_env a, ", row + 1,
    "(dummyt d with seq = value(feature_table_list->table_count)), ",
    row + 1, "(dummyt d2 with seq = value(feature_list->feature_count)) ", row + 1,
    "set a.table_env_status = ", row + 1,
    "if (feature_table_list->table_name[d.seq]->error_flag = 0) ",
    row + 1, "'1' ", row + 1,
    "else ", row + 1, "'0' ",
    row + 1, "endif ", row + 1,
    "plan d where feature_table_list->table_name[d.seq]->refreshed = 1 ", row + 1, "join d2 ",
    row + 1, "join a where a.feature_number = ", row + 1,
    "feature_list->feature_number[d2.seq]->feature_nbr ", row + 1, "and a.table_name = ",
    row + 1, "feature_table_list->table_name[d.seq]->tname ", row + 1,
    "and a.environment = env ", row + 1, "and a.schema_dt_tm <= ",
    row + 1, "cnvtdatetime(feature_table_list->table_name[d.seq]->schema_dt_tm) ", row + 1,
    "with nocounter go ", row + 1, "commit go",
    row + 1
   WITH format = stream, noheading, append,
    formfeed = none, maxcol = 512, maxrow = 1
  ;end select
 ENDIF
 SELECT INTO value(filename2)
  *
  FROM dual
  DETAIL
   "%o", row + 1, row + 1,
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1, append
 ;end select
#exit_script
END GO
