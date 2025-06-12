CREATE PROGRAM dm_fix_indexes:dba
 SET tbl_name = table_list->table_name[ $1].tname
 SET process_flg = table_list->table_name[ $1].process_flg
 SET file2 = table_list->table_name[ $1].output2_filename
 SET file3 = table_list->table_name[ $1].output3_filename
 SET file4 = table_list->table_name[ $1].output4_filename
 SET file_sql = table_list->table_name[ $1].output2sql_filename
 SET file2d = table_list->table_name[ $1].output2d_filename
 SET file3d = table_list->table_name[ $1].output3d_filename
 SET file4d = table_list->table_name[ $1].output4d_filename
 SET created_flg = table_list->table_name[ $1].created_flg
 SET envid = cnvtint( $3)
 CALL echo(build("Environment id:",envid))
 SET errstr = fillstring(110," ")
 SET tempstr = fillstring(110," ")
 FREE SET index_list
 RECORD index_list(
   1 index_name[*]
     2 iname = c32
     2 dm_tname = c32
     2 dm_unique_ind = i4
     2 dm_col_cnt = i4
     2 dm_tspace = c32
     2 u_tname = c32
     2 u_unique_ind = i4
     2 u_col_cnt = i4
     2 u_tspace = c32
     2 identical_col_cnt = i4
   1 index_count = i4
 )
 SET stat = alterlist(index_list->index_name,10)
 SET index_list->index_count = 0
 SELECT INTO "nl:"
  ui.index_name, ui.table_name, ui.tablespace_name,
  ui.uniqueness, y = count(*)
  FROM dm_user_ind_columns ui
  WHERE ui.table_name=tbl_name
  GROUP BY ui.index_name, ui.table_name, ui.tablespace_name,
   ui.uniqueness
  DETAIL
   index_list->index_count = (index_list->index_count+ 1)
   IF (mod(index_list->index_count,10)=1
    AND (index_list->index_count != 1))
    stat = alterlist(index_list->index_name,(index_list->index_count+ 9))
   ENDIF
   index_list->index_name[index_list->index_count].iname = ui.index_name, index_list->index_name[
   index_list->index_count].u_tname = ui.table_name
   IF (ui.uniqueness="UNIQUE")
    index_list->index_name[index_list->index_count].u_unique_ind = 1
   ELSE
    index_list->index_name[index_list->index_count].u_unique_ind = 0
   ENDIF
   index_list->index_name[index_list->index_count].u_tspace = ui.tablespace_name, index_list->
   index_name[index_list->index_count].u_col_cnt = y, index_list->index_name[index_list->index_count]
   .dm_tname = "",
   index_list->index_name[index_list->index_count].dm_unique_ind = 0, index_list->index_name[
   index_list->index_count].dm_tspace = "", index_list->index_name[index_list->index_count].
   dm_col_cnt = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.index_name, di.table_name, di.tablespace_name,
  di.unique_ind, y = count(*)
  FROM dm_index_columns dic,
   dm_indexes di
  WHERE di.index_name=dic.index_name
   AND di.table_name=dic.table_name
   AND di.schema_date=cnvtdatetime( $2)
   AND di.schema_date=dic.schema_date
   AND tbl_name=di.table_name
  GROUP BY di.index_name, di.table_name, di.tablespace_name,
   di.unique_ind
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO index_list->index_count)
     IF ((index_list->index_name[loop_cnt].iname=di.index_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   IF (found_it=0
    AND created_flg != 1)
    index_list->index_count = (index_list->index_count+ 1)
    IF (mod(index_list->index_count,10)=1
     AND (index_list->index_count != 1))
     stat = alterlist(index_list->index_name,(index_list->index_count+ 9))
    ENDIF
    found_it = index_list->index_count, index_list->index_name[found_it].u_tname = "", index_list->
    index_name[found_it].u_unique_ind = 0,
    index_list->index_name[found_it].u_tspace = "", index_list->index_name[found_it].u_col_cnt = 0
   ENDIF
   index_list->index_name[found_it].iname = di.index_name, index_list->index_name[found_it].dm_tname
    = di.table_name, index_list->index_name[found_it].dm_unique_ind = di.unique_ind,
   index_list->index_name[found_it].dm_tspace = di.tablespace_name, index_list->index_name[found_it].
   dm_col_cnt = y
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dic.index_name, dic.table_name, y = count(*)
  FROM dm_user_ind_columns uic,
   dm_index_columns dic
  WHERE uic.index_name=dic.index_name
   AND uic.table_name=dic.table_name
   AND uic.column_name=dic.column_name
   AND uic.column_position=dic.column_position
   AND dic.schema_date=cnvtdatetime( $2)
   AND tbl_name=dic.table_name
  GROUP BY dic.index_name, dic.table_name
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO index_list->index_count)
     IF ((index_list->index_name[loop_cnt].iname=dic.index_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   IF (found_it > 0)
    index_list->index_name[found_it].identical_col_cnt = y
   ENDIF
  WITH nocounter
 ;end select
 IF (process_flg=3)
  SET filename = file2d
  SET err_filename = file3d
 ELSE
  SET filename = file2
  SET err_filename = file3
 ENDIF
 FOR (loop_count = 1 TO index_list->index_count)
   IF ((((index_list->index_name[loop_count].dm_tname != index_list->index_name[loop_count].u_tname))
    OR (((substring(1,2,index_list->index_name[loop_count].u_tspace) != "I_") OR ((((index_list->
   index_name[loop_count].dm_unique_ind != index_list->index_name[loop_count].u_unique_ind)) OR ((((
   index_list->index_name[loop_count].dm_col_cnt != index_list->index_name[loop_count].u_col_cnt))
    OR ((index_list->index_name[loop_count].dm_col_cnt != index_list->index_name[loop_count].
   identical_col_cnt))) )) )) )) )
    SELECT INTO value(filename)
     uc.table_name, uc.constraint_name
     FROM dm_user_constraints uc
     WHERE uc.constraint_type="R"
      AND (uc.r_constraint_name=index_list->index_name[loop_count].iname)
     DETAIL
      "rdb ALTER TABLE ", uc.table_name, row + 1,
      "  drop constraint ", uc.constraint_name, " go",
      row + 1, dropped_cons_list->cons_count = (dropped_cons_list->cons_count+ 1), stat = alterlist(
       dropped_cons_list->cons_name,dropped_cons_list->cons_count),
      dropped_cons_list->cons_name[dropped_cons_list->cons_count].cname = uc.constraint_name
     WITH format = variable, noheading, append,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
    SELECT INTO value(filename)
     uc.table_name
     FROM dm_user_constraints uc
     WHERE uc.constraint_type="P"
      AND (uc.constraint_name=index_list->index_name[loop_count].iname)
     DETAIL
      "rdb ALTER TABLE ", uc.table_name, row + 1,
      "  drop constraint ", index_list->index_name[loop_count].iname, " go",
      row + 1, dropped_cons_list->cons_count = (dropped_cons_list->cons_count+ 1), stat = alterlist(
       dropped_cons_list->cons_name,dropped_cons_list->cons_count),
      dropped_cons_list->cons_name[dropped_cons_list->cons_count].cname = uc.constraint_name
     WITH format = variable, noheading, append,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
    IF (curqual=0)
     SELECT INTO value(filename)
      ucc.table_name, ucc.constraint_name
      FROM dm_user_cons_columns ucc,
       dm_user_ind_columns uic
      PLAN (uic
       WHERE uic.table_name=tbl_name
        AND (uic.index_name=index_list->index_name[loop_count].iname))
       JOIN (ucc
       WHERE ucc.table_name=uic.table_name
        AND ucc.constraint_type="P"
        AND ucc.position=uic.column_position
        AND ucc.column_name=uic.column_name)
      GROUP BY ucc.constraint_name, ucc.table_name
      DETAIL
       "rdb ALTER TABLE ", ucc.table_name, row + 1,
       "  drop constraint ", ucc.constraint_name, " go",
       row + 1, dropped_cons_list->cons_count = (dropped_cons_list->cons_count+ 1), stat = alterlist(
        dropped_cons_list->cons_name,dropped_cons_list->cons_count),
       dropped_cons_list->cons_name[dropped_cons_list->cons_count].cname = ucc.constraint_name
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
    ENDIF
    IF ((index_list->index_name[loop_count].u_col_cnt != 0))
     SELECT INTO value(filename)
      *
      FROM dual
      DETAIL
       "rdb DROP INDEX ", index_list->index_name[loop_count].iname, " go",
       row + 1, "rdb ALTER TABLESPACE ", index_list->index_name[loop_count].u_tspace,
       " coalesce go ", row + 1
      WITH format = variable, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 FOR (loop_count = 1 TO index_list->index_count)
   IF ((((index_list->index_name[loop_count].dm_tname != index_list->index_name[loop_count].u_tname))
    OR (((substring(1,2,index_list->index_name[loop_count].u_tspace) != "I_") OR ((((index_list->
   index_name[loop_count].dm_unique_ind != index_list->index_name[loop_count].u_unique_ind)) OR ((((
   index_list->index_name[loop_count].dm_col_cnt != index_list->index_name[loop_count].u_col_cnt))
    OR ((index_list->index_name[loop_count].dm_col_cnt != index_list->index_name[loop_count].
   identical_col_cnt))) )) )) )) )
    IF ((validate(space_summary->rseq,- (1))=- (1)))
     RECORD space_summary(
       1 rdate = dq8
       1 rseq = i4
     ) WITH persist
     CALL echo(envid)
     SELECT INTO "nl:"
      rseq = max(a.report_seq), y = max(a.begin_date)
      FROM ref_report_log a,
       ref_report_parms_log b,
       ref_instance_id c
      WHERE a.report_seq=b.report_seq
       AND b.parm_cd=1
       AND a.report_cd=1
       AND a.end_date IS NOT null
       AND b.parm_value=cnvtstring(c.instance_cd)
       AND c.environment_id=envid
      DETAIL
       space_summary->rdate = y, space_summary->rseq = rseq
      WITH nocounter
     ;end select
     CALL echo(concat("Space summary report used ",cnvtstring(space_summary->rseq)))
    ENDIF
    SET initial_extent = (2 * 8192)
    SET next_extent = (2 * 8192)
    SELECT INTO "nl:"
     a.segment_name, a.total_space, a.free_space
     FROM space_objects a
     WHERE (a.segment_name=index_list->index_name[loop_count].iname)
      AND (a.report_seq=space_summary->rseq)
     DETAIL
      initial_extent = (((a.total_space - a.free_space) * 8192)/ 10), next_extent = (((a.total_space
       - a.free_space) * 8192)/ 10)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo(concat("No sizing info found for ",index_list->index_name[loop_count].iname))
     SET number_of_rows = 0.0
     SELECT INTO "nl:"
      a.segment_name, a.total_space, a.free_space,
      a.row_count
      FROM space_objects a
      WHERE a.segment_name=tbl_name
       AND (a.report_seq=space_summary->rseq)
      DETAIL
       number_of_rows = a.row_count
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL echo(concat("No sizing info found on the table for ",index_list->index_name[loop_count].
        iname))
      SET initial_extent = (2 * 8192)
      SET next_extent = (2 * 8192)
     ELSE
      CALL echo(concat("Using sizing info found on the table for ",index_list->index_name[loop_count]
        .iname))
      SET ind_size = 0.0
      SELECT INTO "nl:"
       FROM dm_index_columns dic,
        dm_columns dc
       PLAN (dic
        WHERE (dic.index_name=index_list->index_name[loop_count].iname)
         AND dic.schema_date=cnvtdatetime( $2))
        JOIN (dc
        WHERE dic.column_name=dc.column_name
         AND dic.schema_date=dc.schema_date
         AND dic.table_name=dc.table_name)
       DETAIL
        ind_size = (ind_size+ dc.data_length)
       WITH nocounter
      ;end select
      SET initial_extent = (ceil((((number_of_rows * ind_size)/ 10)/ 8192)) * 8192)
      SET next_extent = (ceil((((number_of_rows * ind_size)/ 10)/ 8192)) * 8192)
     ENDIF
    ENDIF
    SELECT INTO value(filename)
     dic.column_name, dic.column_position, di.table_name,
     di.index_name, di.tablespace_name, di.unique_ind
     FROM dm_index_columns dic,
      dm_indexes di
     WHERE (di.index_name=index_list->index_name[loop_count].iname)
      AND di.schema_date=cnvtdatetime( $2)
      AND di.index_name=dic.index_name
      AND di.schema_date=dic.schema_date
     ORDER BY di.index_name, dic.column_position
     HEAD di.index_name
      "dm_clear_errors go", row + 2, "rdb ALTER TABLESPACE ",
      index_list->index_name[loop_count].dm_tspace, " coalesce go ", row + 1,
      "rdb CREATE "
      IF (di.unique_ind=1)
       "UNIQUE"
      ENDIF
      " INDEX ", tempstr = build(di.index_name," ON"), tempstr,
      row + 1, tempstr = build(di.table_name," ("), tempstr,
      row + 1, col_sum = 0, ind_tot = 0
     DETAIL
      IF (dic.column_position > 1)
       ","
      ENDIF
      row + 1, "    ", dic.column_name
     FOOT  di.index_name
      row + 1, "  )", row + 1
      IF ((initial_extent < (2 * 8192)))
       initial_extent = (2 * 8192)
      ENDIF
      IF (next_extent < 8192)
       next_extent = 8192
      ENDIF
      initial_extent = ceil((initial_extent/ 1024)), next_extent = ceil((next_extent/ 1024)),
      "  STORAGE ( INITIAL ",
      initial_extent, "K NEXT ", next_extent,
      "K )", row + 1, "  UNRECOVERABLE ",
      row + 1, "  TABLESPACE ", di.tablespace_name,
      row + 1, "go", row + 2,
      "set msgnum=error(msg,1) go", row + 1, errstr = concat("create index ",trim(di.index_name),
       " on ",trim(di.table_name)),
      "execute dm_log_errors ", row + 1, ' "',
      err_filename, '", ', row + 1,
      ' "", ', row + 1, ' "", ',
      row + 1, ' "', errstr,
      '",', row + 1, " msg, msgnum go",
      row + 2, reset_error = 1
     WITH format = variable, noheading, append,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
   ENDIF
 ENDFOR
#end_program
END GO
