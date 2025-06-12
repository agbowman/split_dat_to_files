CREATE PROGRAM dm_ocd_fix_indexes:dba
 SET tbl_name = fillstring(30," ")
 SET d_tbl_ptr =  $1
 SET u_tbl_ptr =  $2
 SET tbl_name = bn_ocd->tbl[d_tbl_ptr].tbl_name
 SET d_ptr = 0
 SET u_ptr = 0
 SET match_cols = 0
 FREE RECORD ind
 RECORD ind(
   1 cnt = i4
   1 qual[*]
     2 u_ptr = i4
     2 create_ind = i2
 )
 SET ind->cnt = 0
 SET stat = alterlist(ind->qual,bn_ocd->tbl[d_tbl_ptr].ind_cnt)
 SET errstr = fillstring(110," ")
 SET tempstr = fillstring(110," ")
 FOR (icnt = 1 TO bn_ocd->tbl[d_tbl_ptr].ind_cnt)
   SET d_ptr = icnt
   SET u_ptr = 0
   SET ind->qual[d_ptr].create_ind = 0
   SET ind->qual[d_ptr].u_ptr = 0
   FOR (i = 1 TO curdb->tbl[u_tbl_ptr].ind_cnt)
     IF ((curdb->tbl[u_tbl_ptr].ind[i].ind_name=bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_name))
      SET u_ptr = i
      SET i = curdb->tbl[u_tbl_ptr].ind_cnt
     ENDIF
   ENDFOR
   IF (u_ptr=0)
    FOR (i = 1 TO curdb->tbl[u_tbl_ptr].ind_cnt)
      SET match_cols = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt)),
        (dummyt u  WITH seq = value(curdb->tbl[u_tbl_ptr].ind[i].ind_col_cnt))
       WHERE (bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position=curdb->tbl[u_tbl_ptr].
       ind[i].ind_col[u.seq].col_position)
       ORDER BY bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position
       DETAIL
        IF ((bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].ind[i].
        ind_col[u.seq].col_name))
         match_cols = (match_cols+ 1)
        ENDIF
       WITH nocounter
      ;end select
      IF ((match_cols=bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt)
       AND (match_cols=curdb->tbl[u_tbl_ptr].ind[i].ind_col_cnt))
       SET u_ptr = i
       SET i = curdb->tbl[u_tbl_ptr].ind_cnt
      ENDIF
    ENDFOR
   ENDIF
   IF (u_ptr=0)
    SET ind->qual[d_ptr].create_ind = 1
   ELSE
    SET ind->qual[d_ptr].u_ptr = u_ptr
    SET match_cols = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt)),
      (dummyt u  WITH seq = value(curdb->tbl[u_tbl_ptr].ind[u_ptr].ind_col_cnt))
     WHERE (bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position=curdb->tbl[u_tbl_ptr].ind[
     u_ptr].ind_col[u.seq].col_position)
     ORDER BY bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position
     DETAIL
      IF ((bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].ind[u_ptr]
      .ind_col[u.seq].col_name))
       match_cols = (match_cols+ 1)
      ENDIF
     WITH nocounter
    ;end select
    IF ((((bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_name != curdb->tbl[u_tbl_ptr].ind[u_ptr].ind_name))
     OR ((((bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].unique_ind != curdb->tbl[u_tbl_ptr].ind[u_ptr].
    unique_ind)) OR (((substring(1,2,curdb->tbl[u_tbl_ptr].ind[u_ptr].tspace_name) != "I_") OR ((((
    curdb->tbl[u_tbl_ptr].ind[u_ptr].unique_ind=1)
     AND (bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt != curdb->tbl[u_tbl_ptr].ind[u_ptr].
    ind_col_cnt)
     AND (bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt != match_cols)) OR ((curdb->tbl[u_tbl_ptr].
    ind[u_ptr].unique_ind=0)
     AND (bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt > curdb->tbl[u_tbl_ptr].ind[u_ptr].
    ind_col_cnt)
     AND (bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt > match_cols))) )) )) )) )
     SET ind->qual[d_ptr].create_ind = 1
     SET found_pk = 0
     SET pk_name = fillstring(30," ")
     SELECT INTO "nl:"
      uc.constraint_name, uc.constraint_type
      FROM dm_user_constraints uc
      WHERE (uc.table_name=curdb->tbl[u_tbl_ptr].tbl_name)
       AND (uc.constraint_name=curdb->tbl[u_tbl_ptr].ind[u_ptr].ind_name)
       AND uc.constraint_type="P"
      DETAIL
       found_pk = 1, pk_name = uc.constraint_name
      WITH nocounter
     ;end select
     IF (found_pk=0)
      SELECT INTO "nl:"
       ucc.table_name, ucc.constraint_name
       FROM dm_user_cons_columns ucc,
        dm_user_ind_columns uic
       PLAN (uic
        WHERE (uic.table_name=curdb->tbl[u_tbl_ptr].tbl_name)
         AND (uic.index_name=curdb->tbl[u_tbl_ptr].ind[u_ptr].ind_name))
        JOIN (ucc
        WHERE ucc.table_name=uic.table_name
         AND ucc.constraint_type="P"
         AND ucc.position=uic.column_position
         AND ucc.column_name=uic.column_name)
       GROUP BY ucc.constraint_name, ucc.table_name
       DETAIL
        found_pk = 1, pk_name = ucc.constraint_name
       WITH nocounter
      ;end select
     ENDIF
     IF (found_pk > 0)
      SELECT INTO "nl:"
       ucc.*
       FROM dm_user_cons_columns ucc
       WHERE (ucc.table_name=curdb->tbl[u_tbl_ptr].tbl_name)
        AND ucc.constraint_name=pk_name
        AND ucc.constraint_type="P"
       ORDER BY ucc.table_name, ucc.constraint_name, ucc.position
       HEAD ucc.constraint_name
        d_cons->cons_cnt = (d_cons->cons_cnt+ 1), knt = d_cons->cnt, stat = alterlist(d_cons->cons,
         d_cons->cons_cnt),
        d_cons->cons[knt].cons_name = ucc.constraint_name, d_cons->cons[knt].create_ind = 1, d_cons->
        cons[knt].tbl_name = ucc.table_name,
        d_cons->cons[knt].cons_type = ucc.constraint_type, d_cons->cons[knt].parent_table = ucc
        .parent_table_name, d_cons->cons[knt].parent_table_columns = "",
        d_cons->cons[knt].r_constraint_name = ucc.r_constraint_name, d_cons->cons[knt].status_ind =
        ucc.status_ind, d_cons->cons[knt].cons_col_cnt = 0,
        cknt = 0
       DETAIL
        cknt = (cknt+ 1), d_cons->cons[knt].cons_col_cnt = cknt, stat = alterlist(d_cons->cons[knt].
         cons_col,cknt),
        d_cons->cons[knt].cons_col[cknt].col_name = ucc.column_name, d_cons->cons[knt].cons_col[cknt]
        .col_position = ucc.position
        IF (cknt=1)
         d_cons->cons[knt].parent_table_columns = concat(trim(ucc.column_name))
        ELSE
         d_cons->cons[knt].parent_table_columns = concat(d_cons->cons[knt].parent_table_columns,",",
          trim(ucc.column_name))
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO value(filename2)
       ucc.*
       FROM dm_user_cons_columns ucc
       WHERE ucc.r_constraint_name=pk_name
        AND ucc.constraint_type="R"
       ORDER BY ucc.table_name, ucc.constraint_name, ucc.position
       HEAD ucc.constraint_name
        "rdb alter table ", ucc.table_name, row + 1,
        "  drop constraint ", ucc.constraint_name, row + 1,
        "go", row + 1, row + 1,
        d_cons->cons_cnt = (d_cons->cons_cnt+ 1), knt = d_cons->cnt, stat = alterlist(d_cons->cons,
         d_cons->cons_cnt),
        d_cons->cons[knt].cons_name = ucc.constraint_name, d_cons->cons[knt].create_ind = 1, d_cons->
        cons[knt].tbl_name = ucc.table_name,
        d_cons->cons[knt].cons_type = ucc.constraint_type, d_cons->cons[knt].parent_table = ucc
        .parent_table_name, d_cons->cons[knt].parent_table_columns = "",
        d_cons->cons[knt].r_constraint_name = ucc.r_constraint_name, d_cons->cons[knt].status_ind =
        ucc.status_ind, d_cons->cons[knt].cons_col_cnt = 0,
        cknt = 0
       DETAIL
        cknt = (cknt+ 1), d_cons->cons[knt].cons_col_cnt = cknt, stat = alterlist(d_cons->cons[knt].
         cons_col,cknt),
        d_cons->cons[knt].cons_col[cknt].col_name = ucc.column_name, d_cons->cons[knt].cons_col[cknt]
        .col_position = ucc.position
        IF (cknt=1)
         d_cons->cons[knt].parent_table_columns = concat(trim(ucc.column_name))
        ELSE
         d_cons->cons[knt].parent_table_columns = concat(d_cons->cons[knt].parent_table_columns,",",
          trim(ucc.column_name))
        ENDIF
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      SELECT INTO value(filename2)
       FROM dual
       DETAIL
        "rdb alter table ", curdb->tbl[u_tbl_ptr].tbl_name, row + 1,
        "  drop constraint ", pk_name, row + 1,
        "go", row + 1, row + 1
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
     ENDIF
     SELECT INTO value(filename2)
      FROM dual
      DETAIL
       "rdb drop index ", curdb->tbl[u_tbl_ptr].ind[u_ptr].ind_name, row + 1,
       "go", row + 1, row + 1,
       "rdb alter tablespace ", curdb->tbl[u_tbl_ptr].ind[u_ptr].tspace_name, row + 1,
       "  coalesce go", row + 1, row + 1
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 FOR (icnt = 1 TO bn_ocd->tbl[d_tbl_ptr].ind_cnt)
   SET d_ptr = icnt
   SET u_ptr = ind->qual[d_ptr].u_ptr
   IF ((ind->qual[d_ptr].create_ind=1))
    SET initial_extent = (2 * 8192)
    SET next_extent = (2 * 8192)
    IF ((space_summary->rseq > 0))
     SELECT INTO "nl:"
      a.segment_name, a.total_space, a.free_space
      FROM space_objects a
      WHERE (a.segment_name=bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_name)
       AND (a.report_seq=space_summary->rseq)
      DETAIL
       initial_extent = (((a.total_space - a.free_space) * 8192)/ 10), next_extent = (((a.total_space
        - a.free_space) * 8192)/ 10)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET number_of_rows = 0.0
      SELECT INTO "nl:"
       a.segment_name, a.total_space, a.free_space,
       a.row_count
       FROM space_objects a
       WHERE (a.segment_name=bn_ocd->tbl[d_tbl_ptr].tbl_name)
        AND (a.report_seq=space_summary->rseq)
       DETAIL
        number_of_rows = a.row_count
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET initial_extent = (2 * 8192)
       SET next_extent = (2 * 8192)
      ELSE
       SET ind_size = 0.0
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt)),
         (dummyt c  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt))
        PLAN (d)
         JOIN (c
         WHERE (bn_ocd->tbl[d_tbl_ptr].tbl_col[c.seq].col_name=bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].
         ind_col[d.seq].col_name))
        ORDER BY bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position
        DETAIL
         ind_size = (ind_size+ bn_ocd->tbl[d_tbl_ptr].tbl_col[c.seq].data_length)
        WITH nocounter
       ;end select
       SET initial_extent = (ceil((((number_of_rows * ind_size)/ 10)/ 8192)) * 8192)
       SET next_extent = (ceil((((number_of_rows * ind_size)/ 10)/ 8192)) * 8192)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO value(filename2)
     FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col_cnt))
     ORDER BY bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position
     HEAD REPORT
      "set msgnum=error(msg,1) go", row + 1, "set error_reported = 0 go",
      row + 1, row + 1, "rdb create "
      IF ((bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].unique_ind=1))
       "unique"
      ENDIF
      " index ", bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_name, row + 1,
      "on ", bn_ocd->tbl[d_tbl_ptr].tbl_name, " ("
     DETAIL
      IF ((bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_position > 1))
       ","
      ENDIF
      row + 1, "  ", bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_col[d.seq].col_name
     FOOT REPORT
      row + 1
      IF ((initial_extent < (2 * 8192)))
       initial_extent = (2 * 8192)
      ENDIF
      IF (next_extent < 8192)
       next_extent = 8192
      ENDIF
      initial_extent = ceil((initial_extent/ 1024)), next_extent = ceil((next_extent/ 1024)),
      ") storage ( initial ",
      initial_extent, "K next ", next_extent,
      "K)", row + 1, "unrecoverable",
      row + 1, "tablespace ", bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].tspace_name,
      row + 1, "go", row + 1,
      row + 1, "set msgnum=error(msg,1) go", row + 1,
      errstr = concat('"create index ',trim(bn_ocd->tbl[d_tbl_ptr].ind[d_ptr].ind_name)," on table ",
       trim(bn_ocd->tbl[d_tbl_ptr].tbl_name),'" go'), "set error_msg= ", errstr,
      row + 1, 'set rstring = "" go', row + 1,
      'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
      row + 2, reset_error = 1
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
   ENDIF
 ENDFOR
END GO
