CREATE PROGRAM dm_afd_fix_indexes:dba
 SET filename2 = "dm_afd_fix_schema2"
 SET filename3 = "dm_afd_fix_schema3"
 SET tbl_name =  $1
 SET created_flg =  $2
 SET envid =  $3
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
  FROM dm_afd_index_columns dic,
   dm_afd_indexes di
  WHERE di.index_name=dic.index_name
   AND di.table_name=dic.table_name
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
   dm_afd_index_columns dic
  WHERE uic.index_name=dic.index_name
   AND uic.table_name=dic.table_name
   AND uic.column_name=dic.column_name
   AND uic.column_position=dic.column_position
   AND tbl_name=dic.table_name
  GROUP BY dic.index_name, dic.table_name
  DETAIL
   found_it = 0
   FOR (loop_cnt = 1 TO index_list->index_count)
     IF ((index_list->index_name[loop_cnt].iname=dic.index_name))
      found_it = loop_cnt
     ENDIF
   ENDFOR
   index_list->index_name[found_it].identical_col_cnt = y
  WITH nocounter
 ;end select
 FOR (loop_count = 1 TO index_list->index_count)
   IF ((((index_list->index_name[loop_count].dm_tname != index_list->index_name[loop_count].u_tname))
    OR ((((index_list->index_name[loop_count].dm_tspace != index_list->index_name[loop_count].
   u_tspace)) OR ((((index_list->index_name[loop_count].dm_unique_ind != index_list->index_name[
   loop_count].u_unique_ind)) OR ((((index_list->index_name[loop_count].dm_col_cnt != index_list->
   index_name[loop_count].u_col_cnt)) OR ((index_list->index_name[loop_count].dm_col_cnt !=
   index_list->index_name[loop_count].identical_col_cnt))) )) )) )) )
    SELECT INTO value(filename2)
     uc.table_name, uc.constraint_name
     FROM dm_user_constraints uc
     WHERE uc.constraint_type="R"
      AND (uc.r_constraint_name=index_list->index_name[loop_count].iname)
     DETAIL
      "rdb ALTER TABLE ", uc.table_name, " drop constraint ",
      uc.constraint_name, " go", row + 2,
      dropped_cons_list->cons_count = (dropped_cons_list->cons_count+ 1), stat = alterlist(
       dropped_cons_list->cons_name,dropped_cons_list->cons_count), dropped_cons_list->cons_name[
      dropped_cons_list->cons_count].cname = uc.constraint_name
     WITH format = stream, noheading, append,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
    SELECT INTO value(filename2)
     uc.table_name
     FROM dm_user_constraints uc
     WHERE uc.constraint_type="P"
      AND (uc.constraint_name=index_list->index_name[loop_count].iname)
     DETAIL
      "rdb ALTER TABLE ", uc.table_name, " drop constraint ",
      index_list->index_name[loop_count].iname, " go", row + 1,
      dropped_cons_list->cons_count = (dropped_cons_list->cons_count+ 1), stat = alterlist(
       dropped_cons_list->cons_name,dropped_cons_list->cons_count), dropped_cons_list->cons_name[
      dropped_cons_list->cons_count].cname = uc.constraint_name
     WITH format = stream, noheading, append,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
    IF ((index_list->index_name[loop_count].u_col_cnt != 0))
     SELECT INTO value(filename2)
      *
      FROM dual
      DETAIL
       "rdb DROP INDEX ", index_list->index_name[loop_count].iname, " go",
       row + 2
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
    ENDIF
    SET rdate = 0
    SET rseq = 0
    SELECT INTO "nl:"
     a.report_seq, a.begin_date
     FROM ref_report_log a,
      ref_report_parms_log b
     WHERE a.report_seq=b.report_seq
      AND b.parm_cd=1
      AND b.parm_value=cnvtstring(envid)
     ORDER BY a.begin_date
     DETAIL
      IF (a.begin_date > rdate)
       rdate = a.begin_date, rseq = a.report_seq
      ENDIF
     WITH nocounter
    ;end select
    CALL echo(build("Curqual :",curqual))
    IF (rseq > 0)
     SELECT INTO value(filename2)
      dic.column_name, dic.column_position, di.table_name,
      di.index_name, di.tablespace_name, di.unique_ind,
      dc.column_position, so.row_count, s.total_space,
      s.free_space
      FROM space_objects s,
       (dummyt t2  WITH seq = 1),
       dm_afd_index_columns dic,
       dm_afd_indexes di,
       dm_afd_columns dc,
       space_objects so
      PLAN (di
       WHERE (di.index_name=index_list->index_name[loop_count].iname))
       JOIN (dic
       WHERE di.index_name=dic.index_name)
       JOIN (dc
       WHERE dic.column_name=dc.column_name)
       JOIN (t2)
       JOIN (s
       WHERE s.segment_name=di.index_name
        AND s.report_seq=rseq
        AND s.instance_cd=envid)
       JOIN (so
       WHERE so.segment_name=di.table_name
        AND so.report_seq=rseq
        AND so.instance_cd=envid)
      ORDER BY di.index_name, dic.column_position
      HEAD di.index_name
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       "set error_reported = 0 go",
       row + 1, "rdb CREATE "
       IF (di.unique_ind=1)
        "UNIQUE"
       ENDIF
       " INDEX ", tempstr = build(di.index_name," ON"), tempstr,
       row + 1, tempstr = build(di.table_name," ("), tempstr,
       row + 1, col_sum = 0, ind_tot = 0
      DETAIL
       col_sum = (col_sum+ dc.data_length)
       IF (dic.column_position > 1)
        ","
       ENDIF
       row + 1, dic.column_name
      FOOT  di.index_name
       row + 1, ")", row + 1
       IF ((index_list->index_name[loop_count].u_col_cnt=0))
        ind_tot = (col_sum * so.row_count), initial_extent = (ind_tot/ 10), next_extent = (ind_tot/
        10)
        IF (initial_extent > 1024)
         initial_extent = ceil((initial_extent/ 1024)), next_extent = ceil((next_extent/ 1024)),
         " STORAGE ( INITIAL ",
         initial_extent, "K NEXT ", next_extent,
         "K )", row + 1
        ELSE
         " STORAGE ( INITIAL ", initial_extent, " NEXT ",
         next_extent, ")", row + 1
        ENDIF
       ELSE
        used_tot = ((s.total_space - s.free_space) * 8192), initial_extent = (used_tot/ 10),
        next_extent = (used_tot/ 10)
        IF (initial_extent > 1024)
         initial_extent = ceil((initial_extent/ 1024)), next_extent = ceil((next_extent/ 1024)),
         " STORAGE ( INITIAL ",
         initial_extent, "K NEXT ", next_extent,
         "K )", row + 1
        ELSE
         " STORAGE ( INITIAL ", initial_extent, " NEXT ",
         next_extent, ")", row + 1
        ENDIF
       ENDIF
       col 20, " TABLESPACE ", di.tablespace_name,
       row + 1, "go", row + 2,
       'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
        '"create index ',trim(di.index_name)," on ",trim(di.table_name),'" go'),
       "set error_msg= ", errstr, row + 1,
       'set rstring = "" go', row + 1, 'set rstring1 = "" go',
       row + 1, "execute dm_check_errors go", row + 2,
       reset_error = 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, outerjoin = di,
       maxrow = 1
     ;end select
    ELSE
     SELECT INTO value(filename2)
      dic.column_name, dic.column_position, di.table_name,
      di.index_name, di.tablespace_name, di.unique_ind
      FROM dm_afd_index_columns dic,
       dm_afd_indexes di
      PLAN (di
       WHERE di.table_name=tbl_name)
       JOIN (dic
       WHERE di.index_name=dic.index_name)
      ORDER BY di.index_name, dic.column_position
      HEAD di.index_name
       "rdb DROP INDEX ", di.index_name, " go",
       row + 2, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       "set error_reported = 0 go", row + 1, "rdb CREATE "
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
       row + 1, col 30, ")",
       row + 1, col 20, " TABLESPACE ",
       di.tablespace_name, row + 1, "go",
       row + 2, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
       errstr = concat('"create index ',trim(di.index_name)," on table",trim(di.table_name),'" go'),
       "set error_msg = ", errstr,
       row + 1, 'set rstring = "" go', row + 1,
       'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
       row + 1, reset_error = 1
      WITH format = stream, noheading, append,
       formfeed = none, maxcol = 512, maxrow = 1
     ;end select
    ENDIF
   ENDIF
 ENDFOR
END GO
