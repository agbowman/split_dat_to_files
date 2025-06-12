CREATE PROGRAM dm_create_ddl:dba
 FREE RECORD txt
 RECORD txt(
   1 txt = vc
   1 dlen = vc
   1 errstr = vc
   1 col_name = vc
 )
 FREE RECORD ih_fk
 RECORD ih_fk(
   1 parent_col_cnt = i2
   1 pcols[*]
     2 col_name = vc
     2 col_position = i2
   1 fk_cnt = i4
   1 fk[*]
     2 build_ind = i2
     2 tbl_name = vc
     2 cons_name = vc
     2 col_cnt = i2
     2 cols[*]
       3 col_name = vc
       3 col_position = i2
 )
 SET ih_fk->parent_col_cnt = 0
 SET ih_fk->fk_cnt = 0
 FREE RECORD dcl_str
 RECORD dcl_str(
   1 str = vc
 )
 SET fprefix = cnvtlower(fs_proc->file_prefix)
 FREE RECORD files
 RECORD files(
   1 uptime_ddl_file = vc
   1 downtime_ddl_file = vc
   1 uptime_err_file = vc
   1 downtime_err_file = vc
 )
 FOR (cnt2 = 1 TO rfiles->fcnt)
   CALL init_files(cnt2)
 ENDFOR
 SET routine_idx = 0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(rfiles->fcnt))
  PLAN (d
   WHERE (rfiles->qual[d.seq].fname="*routine*"))
  DETAIL
   routine_idx = d.seq
  WITH nocounter
 ;end select
 IF (routine_idx > 0)
  CALL echo("looking for sequences to create")
  FREE RECORD dseq
  RECORD dseq(
    1 cnt = i4
    1 s[*]
      2 sequence_name = vc
  )
  SET dseq->cnt = 0
  SET stat = alterlist(dseq->s,0)
  SELECT INTO "nl:"
   ds.sequence_name
   FROM dm_sequences ds,
    user_sequences us,
    dummyt d
   PLAN (ds
    WHERE ds.sequence_name > " ")
    JOIN (d)
    JOIN (us
    WHERE ds.sequence_name=us.sequence_name)
   ORDER BY ds.sequence_name
   DETAIL
    dseq->cnt = (dseq->cnt+ 1), stat = alterlist(dseq->s,dseq->cnt), dseq->s[dseq->cnt].sequence_name
     = ds.sequence_name
   WITH outerjoin = d, dontexist
  ;end select
  FOR (ts = 1 TO dseq->cnt)
    IF ((fs_proc->inhouse_ind=0))
     SET dm_schema_log->operation = "CREATE SEQUENCE"
     SET dm_schema_log->file_name = rfiles->qual[routine_idx].file2
     SET dm_schema_log->table_name = dseq->s[ts].sequence_name
     SET dm_schema_log->object_name = dseq->s[ts].sequence_name
     EXECUTE dm_schema_estimate_op_log
    ENDIF
    SELECT INTO value(rfiles->qual[routine_idx].file2)
     FROM dm_sequences ds
     WHERE (ds.sequence_name=dseq->s[ts].sequence_name)
     DETAIL
      row + 1, "dm_clear_errors2 go", min_value = cnvtstring(ds.min_value),
      max_value = cnvtstring(ds.max_value), cache_value = cnvtstring(ds.cache), row + 1,
      "; Creating sequence ", ds.sequence_name, row + 1,
      "rdb CREATE SEQUENCE ", ds.sequence_name, row + 1,
      "  INCREMENT BY ", ds.increment_by
      IF (ds.increment_by > 0)
       IF (ds.max_value < 10000000000.0)
        row + 1, "  MAXVALUE ", max_value
       ENDIF
       IF (ds.min_value != 1.0)
        row + 1, "  MINVALUE ", min_value
       ENDIF
      ENDIF
      IF (ds.increment_by < 0)
       IF ((ds.min_value > - (1000000000.0)))
        row + 1, "  MINVALUE ", min_value
       ENDIF
       IF ((ds.max_value != - (1.0)))
        row + 1, "  MAXVALUE ", max_value
       ENDIF
      ENDIF
      IF (ds.cycle="Y")
       row + 1, "  CYCLE"
      ENDIF
      IF (ds.cache > 0.0)
       row + 1, "  CACHE ", cache_value
      ENDIF
      row + 1, "go", txt->errstr = substring(1,110,concat("create sequence ",ds.sequence_name)),
      row + 1, "set msgnum=error(msg,1) go", row + 1,
      " dm_log_errors2 ", row + 1, ' "',
      rfiles->qual[routine_idx].file3, '", ', row + 1,
      ' "', txt->errstr, '",',
      row + 1, " msg, msgnum go"
     WITH format = variable, noheading, append,
      maxrow = 1, formfeed = none, maxcol = 512
    ;end select
    IF ((fs_proc->inhouse_ind=0))
     EXECUTE dm_schema_estimate_op_log
    ENDIF
    IF ((dseq->cnt > 0))
     SELECT INTO value(rfiles->qual[routine_idx].file2)
      FROM dual
      DETAIL
       row + 1, "dm_user_last_updt go"
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 FOR (tcnt1 = 1 TO tgtdb->tbl_cnt)
   SET fidx = tgtdb->tbl[tcnt1].file_idx
   SET files->uptime_ddl_file = rfiles->qual[fidx].file2
   SET files->downtime_ddl_file = rfiles->qual[fidx].file2d
   SET files->uptime_err_file = rfiles->qual[fidx].file3
   SET files->downtime_err_file = rfiles->qual[fidx].file3d
   IF ((tgtdb->tbl[tcnt1].combine_ind=1))
    SET files->uptime_ddl_file = files->downtime_ddl_file
    SET files->uptime_err_file = files->downtime_err_file
   ENDIF
   IF ((tgtdb->tbl[tcnt1].new_ind=1))
    CALL echo("create new table")
    IF ((fs_proc->inhouse_ind=0))
     SET dm_schema_log->operation = "CREATE TABLE"
     SET dm_schema_log->file_name = files->uptime_ddl_file
     SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
     SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_name
     EXECUTE dm_schema_estimate_op_log
    ENDIF
    SELECT INTO value(files->uptime_ddl_file)
     FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].tbl_col_cnt))
     PLAN (d)
     HEAD REPORT
      row + 1, " dm_clear_errors2 go", row + 1,
      "RDB CREATE TABLE ", tgtdb->tbl[tcnt1].tbl_name, "("
     DETAIL
      IF (d.seq=1)
       txt->txt = " "
      ELSE
       txt->txt = ","
      ENDIF
      txt->txt = concat(txt->txt,tgtdb->tbl[tcnt1].tbl_col[d.seq].col_name), txt->txt = concat(txt->
       txt," ",tgtdb->tbl[tcnt1].tbl_col[d.seq].data_type)
      IF ((((tgtdb->tbl[tcnt1].tbl_col[d.seq].data_type="VARCHAR")) OR ((((tgtdb->tbl[tcnt1].tbl_col[
      d.seq].data_type="VARCHAR2")) OR ((((tgtdb->tbl[tcnt1].tbl_col[d.seq].data_type="CHAR")) OR ((
      tgtdb->tbl[tcnt1].tbl_col[d.seq].data_type="RAW"))) )) )) )
       txt->dlen = cnvtstring(tgtdb->tbl[tcnt1].tbl_col[d.seq].data_length,0), txt->txt = concat(txt
        ->txt,"(",txt->dlen,")")
      ENDIF
      IF ((tgtdb->tbl[tcnt1].tbl_col[d.seq].data_default != "NULL"))
       txt->txt = concat(txt->txt," DEFAULT ",tgtdb->tbl[tcnt1].tbl_col[d.seq].data_default)
      ENDIF
      IF ((tgtdb->tbl[tcnt1].tbl_col[d.seq].nullable="Y"))
       txt->txt = concat(txt->txt," NULL")
      ELSE
       txt->txt = concat(txt->txt," NOT NULL")
      ENDIF
      row + 1, txt->txt
     FOOT REPORT
      row + 1, ")"
      IF ((tgtdb->tbl[tcnt1].pct_free > 0)
       AND (tgtdb->tbl[tcnt1].pct_used > 0))
       row + 1, "PCTFREE ", tgtdb->tbl[tcnt1].pct_free,
       row + 1, "PCTUSED ", tgtdb->tbl[tcnt1].pct_used
      ENDIF
      IF ((tgtdb->tbl[tcnt1].init_ext > 0)
       AND (tgtdb->tbl[tcnt1].next_ext > 0))
       init_extent = ceil((tgtdb->tbl[tcnt1].init_ext/ 1024)), next_extent = ceil((tgtdb->tbl[tcnt1].
        next_ext/ 1024)), row + 1,
       "STORAGE (INITIAL ", init_extent, "K NEXT ",
       next_extent, "K )"
      ENDIF
      row + 1, "TABLESPACE ", tgtdb->tbl[tcnt1].tspace_name,
      " go", txt->errstr = substring(1,110,concat("create table ",tgtdb->tbl[tcnt1].tbl_name)), row
       + 1,
      "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 ",
      row + 1, ' "', files->uptime_err_file,
      '", ', row + 1, ' "',
      txt->errstr, '",', row + 1,
      " msg, msgnum go", row + 1, " dm_user_last_updt go",
      row + 1, " oragen3 '", tgtdb->tbl[tcnt1].tbl_name,
      "' go", row + 2
      IF ((tgtdb->tbl[tcnt1].combine_ind=1))
       rfiles->qual[fidx].ddl_dn_ind = 1
      ELSE
       rfiles->qual[fidx].ddl_up_ind = 1
      ENDIF
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
    IF ((fs_proc->inhouse_ind=0))
     EXECUTE dm_schema_estimate_op_log
    ENDIF
   ELSEIF ((tgtdb->tbl[tcnt1].diff_ind=1))
    CALL echo("looking for column changes to existing table")
    SET oragen_ind = 0
    FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
      SET user_updt_ind = 0
      IF ((tgtdb->tbl[tcnt1].tbl_col[tc].new_ind=1))
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "ADD COLUMN"
        SET dm_schema_log->file_name = files->uptime_ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log
       ENDIF
       SELECT INTO value(files->uptime_ddl_file)
        FROM dual
        DETAIL
         row + 1, " dm_clear_errors2 go", row + 1,
         "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
         "ADD ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, txt->txt = tgtdb->tbl[tcnt1].tbl_col[tc].
         data_type
         IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="VARCHAR")) OR ((((tgtdb->tbl[tcnt1].tbl_col[
         tc].data_type="VARCHAR2")) OR ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="CHAR")) OR ((
         tgtdb->tbl[tcnt1].tbl_col[tc].data_type="RAW"))) )) )) )
          txt->dlen = cnvtstring(tgtdb->tbl[tcnt1].tbl_col[tc].data_length,0), txt->txt = concat(txt
           ->txt,"(",txt->dlen,")")
         ENDIF
         txt->txt = concat(txt->txt," NULL go"), row + 1, txt->txt,
         txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
           " add column ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name)), row + 1,
         "set msgnum=error(msg,1) go",
         row + 1, " dm_log_errors2 ", row + 1,
         ' "', files->uptime_err_file, '", ',
         row + 1, ' "', txt->errstr,
         '",', row + 1, " msg, msgnum go",
         row + 1, row + 1
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET oragen_ind = 1
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log
       ENDIF
      ENDIF
      IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].diff_dtype_ind=1)) OR ((tgtdb->tbl[tcnt1].tbl_col[tc].
      diff_dlength_ind=1))) )
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "MODIFY COLUMN DATA TYPE"
        SET dm_schema_log->file_name = files->uptime_ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log
       ENDIF
       SELECT INTO value(files->uptime_ddl_file)
        FROM dual
        DETAIL
         row + 1, " dm_clear_errors2 go", row + 1,
         "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
         "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, txt->txt = concat(tgtdb->tbl[tcnt1].
          tbl_col[tc].data_type)
         IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="VARCHAR")) OR ((((tgtdb->tbl[tcnt1].tbl_col[
         tc].data_type="VARCHAR2")) OR ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="CHAR")) OR ((
         tgtdb->tbl[tcnt1].tbl_col[tc].data_type="RAW"))) )) )) )
          txt->dlen = cnvtstring(tgtdb->tbl[tcnt1].tbl_col[tc].data_length,0), txt->txt = concat(txt
           ->txt,"(",txt->dlen,")")
         ENDIF
         txt->txt = concat(txt->txt," go"), row + 1, txt->txt,
         txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
           " modify column ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," data type/length")), row + 1,
         "set msgnum=error(msg,1) go",
         row + 1, " dm_log_errors2 ", row + 1,
         ' "', files->uptime_err_file, '", ',
         row + 1, ' "', txt->errstr,
         '",', row + 1, " msg, msgnum go",
         row + 1, row + 1
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET oragen_ind = 1
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log
       ENDIF
      ENDIF
      IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].diff_default_ind=1)) OR ((tgtdb->tbl[tcnt1].tbl_col[tc].
      new_ind=1))) )
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "ADD DEFAULT VALUE"
        SET dm_schema_log->file_name = files->uptime_ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log
       ENDIF
       SELECT INTO value(files->uptime_ddl_file)
        FROM dual
        DETAIL
         row + 1, " dm_clear_errors2 go", row + 1,
         "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
         "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, row + 1,
         "DEFAULT ", tgtdb->tbl[tcnt1].tbl_col[tc].data_default, " go",
         txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
           " modify column ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," default value")), row + 1,
         "set msgnum=error(msg,1) go",
         row + 1, " dm_log_errors2 ", row + 1,
         ' "', files->uptime_err_file, '", ',
         row + 1, ' "', txt->errstr,
         '",', row + 1, " msg, msgnum go",
         row + 1, row + 1
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log
       ENDIF
      ENDIF
      IF (user_updt_ind=1)
       SELECT INTO value(files->uptime_ddl_file)
        FROM dual
        DETAIL
         row + 1, "dm_user_last_updt go"
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
    ENDFOR
    IF (oragen_ind=1)
     SELECT INTO value(files->uptime_ddl_file)
      FROM dual
      DETAIL
       row + 1, "oragen3 '", tgtdb->tbl[tcnt1].tbl_name,
       "' go"
       IF ((tgtdb->tbl[tcnt1].combine_ind=1))
        rfiles->qual[fidx].ddl_dn_ind = 1
       ELSE
        rfiles->qual[fidx].ddl_up_ind = 1
       ENDIF
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("write compile all objects command")
 FOR (fi = 1 TO rfiles->fcnt)
   CALL dis_write_compile_objects(fi)
 ENDFOR
 FOR (tcnt1 = 1 TO tgtdb->tbl_cnt)
   SET fidx = tgtdb->tbl[tcnt1].file_idx
   SET files->uptime_ddl_file = rfiles->qual[fidx].file2
   SET files->downtime_ddl_file = rfiles->qual[fidx].file2d
   SET files->uptime_err_file = rfiles->qual[fidx].file3
   SET files->downtime_err_file = rfiles->qual[fidx].file3d
   IF ((tgtdb->tbl[tcnt1].combine_ind=1))
    SET files->uptime_ddl_file = files->downtime_ddl_file
    SET files->uptime_err_file = files->downtime_err_file
   ENDIF
   IF ((((tgtdb->tbl[tcnt1].diff_ind=1)) OR ((tgtdb->tbl[tcnt1].new_ind=1))) )
    CALL echo("looking for sql cursor to create")
    SET sql_cursor_ind = 0
    FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
      IF ((tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=1))
       SET sql_cursor_ind = 1
       SET tc = tgtdb->tbl[tcnt1].tbl_col_cnt
      ENDIF
    ENDFOR
    IF (sql_cursor_ind=1)
     IF ((fs_proc->inhouse_ind=0))
      SET dm_schema_log->operation = "POPULATE DEFAULT VALUE"
      SET dm_schema_log->file_name = files->uptime_ddl_file
      SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
      SET dm_schema_log->object_name = "SQL CURSOR"
      SET dm_schema_log->column_name = ""
      EXECUTE dm_schema_estimate_op_log
     ENDIF
     SELECT INTO value(files->uptime_ddl_file)
      d.seq
      FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].tbl_col_cnt))
      PLAN (d
       WHERE (tgtdb->tbl[tcnt1].tbl_col[d.seq].null_to_notnull_ind=1))
      HEAD REPORT
       row + 1, " dm_clear_errors2 go", row + 1,
       "rdb asis('declare')", row + 1, "asis('cursor c1 is')",
       row + 1, "asis('select rowid') ", row + 1,
       txt->txt = build('from "',tgtdb->tbl[tcnt1].tbl_name,'"'), "asis('", txt->txt,
       "')", cnum = 0
      DETAIL
       cnum = (cnum+ 1), row + 1
       IF (cnum=1)
        "asis(' where "
       ELSE
        "asis(' or "
       ENDIF
       tgtdb->tbl[tcnt1].tbl_col[d.seq].col_name, " is null') "
      FOOT REPORT
       "asis (';')", row + 1, "asis(' finished number:=0;')",
       row + 1, "asis(' snapshot_too_old EXCEPTION;')", row + 1,
       "asis(' pragma exception_init(snapshot_too_old, -1555);')", row + 1, "asis('begin')",
       row + 1, "asis('while (finished=0) loop')", row + 1,
       "asis('  finished:=1;')", row + 1, "asis('  begin')",
       row + 1, "asis('  for c1rec in c1 loop')", row + 1,
       txt->txt = build('    update "',tgtdb->tbl[tcnt1].tbl_name,'"'), "asis('", txt->txt,
       " set')", first_col = 0
       FOR (col_i = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
         IF ((tgtdb->tbl[tcnt1].tbl_col[col_i].null_to_notnull_ind=1))
          row + 1
          IF (first_col=0)
           "asis(^  "
          ELSE
           "asis(^, "
          ENDIF
          tgtdb->tbl[tcnt1].tbl_col[col_i].col_name, " = nvl(", tgtdb->tbl[tcnt1].tbl_col[col_i].
          col_name,
          ", ", tgtdb->tbl[tcnt1].tbl_col[col_i].data_default, ")^)",
          first_col = 1
         ENDIF
       ENDFOR
       row + 1, "asis('    where rowid = c1rec.rowid;')", row + 1,
       "asis('    commit;')", row + 1, "asis('  end loop;')",
       row + 1, "asis('  exception when snapshot_too_old then')", row + 1,
       "asis('    finished:=0;')", row + 1, "asis('  end;')",
       row + 1, "asis('end loop;')", row + 1,
       "asis('end;')", row + 1, "go",
       row + 1, txt->errstr = substring(1,110,concat(
         "sql cursor to populate columns that will be made ","not null on table ",tgtdb->tbl[tcnt1].
         tbl_name)), row + 1,
       "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 ",
       row + 1, ' "', files->uptime_err_file,
       '", ', row + 1, ' "',
       txt->errstr, '",', row + 1,
       " msg, msgnum go", row + 2
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
     IF ((fs_proc->inhouse_ind=0))
      EXECUTE dm_schema_estimate_op_log
     ENDIF
    ENDIF
    CALL echo("looking for column nullability changes - uptime changes")
    SET user_updt_ind = 0
    FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
     IF ((tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=0)
      AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=1))
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "ADD NOT NULL CONSTRAINT"
       SET dm_schema_log->file_name = files->uptime_ddl_file
       SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
       SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
       SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
       EXECUTE dm_schema_estimate_op_log
      ENDIF
      SELECT INTO value(files->uptime_ddl_file)
       FROM dual
       DETAIL
        row + 1, "dm_clear_errors2 go", row + 1,
        "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
        "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, " NOT NULL go",
        txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name," modify ",
          tgtdb->tbl[tcnt1].tbl_col[tc].col_name," not null")), row + 1, "set msgnum=error(msg,1) go",
        row + 1, " dm_log_errors2 ", row + 1,
        ' "', files->uptime_err_file, '", ',
        row + 1, ' "', txt->errstr,
        '",', row + 1, " msg, msgnum go"
        IF ((tgtdb->tbl[tcnt1].combine_ind=1))
         rfiles->qual[fidx].ddl_dn_ind = 1
        ELSE
         rfiles->qual[fidx].ddl_up_ind = 1
        ENDIF
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      SET user_updt_ind = 1
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log
      ENDIF
     ENDIF
     IF ((tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=0)
      AND (tgtdb->tbl[tcnt1].tbl_col[tc].diff_nullable_ind=1)
      AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=0))
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "DROP CONSTRAINT"
       SET dm_schema_log->file_name = files->uptime_ddl_file
       SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
       SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
       SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
       EXECUTE dm_schema_estimate_op_log
      ENDIF
      SELECT INTO value(files->uptime_ddl_file)
       FROM dual
       DETAIL
        row + 1, "dm_clear_errors2 go", row + 1,
        "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
        "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, " NULL go",
        txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name," modify ",
          tgtdb->tbl[tcnt1].tbl_col[tc].col_name," null")), row + 1, "set msgnum=error(msg,1) go",
        row + 1, " dm_log_errors2 ", row + 1,
        ' "', files->uptime_err_file, '", ',
        row + 1, ' "', txt->errstr,
        '",', row + 1, " msg, msgnum go"
        IF ((tgtdb->tbl[tcnt1].combine_ind=1))
         rfiles->qual[fidx].ddl_dn_ind = 1
        ELSE
         rfiles->qual[fidx].ddl_up_ind = 1
        ENDIF
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      SET user_updt_ind = 1
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log
      ENDIF
     ENDIF
    ENDFOR
    IF (user_updt_ind=1)
     SELECT INTO value(files->uptime_ddl_file)
      FROM dual
      DETAIL
       row + 1, "dm_user_last_updt go"
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
    IF ((tgtdb->tbl[tcnt1].diff_ind=1))
     CALL echo("looking for column changes (null to NOT NULL) - downtime changes")
     SET user_updt_ind = 0
     FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
       IF ((tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=1)
        AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=1))
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "ADD NOT NULL CONSTRAINT"
         SET dm_schema_log->file_name = files->downtime_ddl_file
         SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
         SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         EXECUTE dm_schema_estimate_op_log
        ENDIF
        SELECT INTO value(files->downtime_ddl_file)
         FROM dual
         DETAIL
          row + 1, "dm_clear_errors2 go", row + 1,
          "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
          "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, " NOT NULL go",
          txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name," modify ",
            tgtdb->tbl[tcnt1].tbl_col[tc].col_name," not null")), row + 1,
          "set msgnum=error(msg,1) go",
          row + 1, " dm_log_errors2 ", row + 1,
          ' "', files->uptime_err_file, '", ',
          row + 1, ' "', txt->errstr,
          '",', row + 1, " msg, msgnum go",
          rfiles->qual[fidx].ddl_dn_ind = 1
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        SET user_updt_ind = 1
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log
        ENDIF
       ENDIF
     ENDFOR
     IF (user_updt_ind=1)
      SELECT INTO value(files->downtime_ddl_file)
       FROM dual
       DETAIL
        row + 1, "dm_user_last_updt go"
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
     ENDIF
     SET cdb_idx = 0
     SELECT INTO "nl:"
      d.seq
      FROM (dummyt d  WITH seq = value(curdb->tbl_cnt))
      PLAN (d
       WHERE (curdb->tbl[d.seq].tbl_name=tgtdb->tbl[tcnt1].tbl_name))
      DETAIL
       cdb_idx = d.seq
      WITH nocounter
     ;end select
     SET ih_fk->parent_col_cnt = 0
     FOR (ccnt1 = 1 TO curdb->tbl[cdb_idx].cons_cnt)
       IF ((curdb->tbl[cdb_idx].cons[ccnt1].drop_ind=1))
        CALL echo("drop constraints")
        IF ((((fs_proc->inhouse_ind=1)) OR ((fs_proc->ocd_ind=1)))
         AND (curdb->tbl[cdb_idx].cons[ccnt1].cons_type="P"))
         FOR (ccol_cnt1 = 1 TO curdb->tbl[cdb_idx].cons[ccnt1].cons_col_cnt)
           SET ih_fk->parent_col_cnt = (ih_fk->parent_col_cnt+ 1)
           SET pc_cnt = ih_fk->parent_col_cnt
           SET stat = alterlist(ih_fk->pcols,pc_cnt)
           SET ih_fk->pcols[pc_cnt].col_name = curdb->tbl[cdb_idx].cons[ccnt1].cons_col[ccol_cnt1].
           col_name
           SET ih_fk->pcols[pc_cnt].col_position = curdb->tbl[cdb_idx].cons[ccnt1].cons_col[ccol_cnt1
           ].col_position
         ENDFOR
         SET subcnt1 = 0
         SET subcnt2 = 0
         SELECT INTO "nl:"
          ucc.constraint_name
          FROM user_constraints uc,
           user_cons_columns ucc
          WHERE uc.constraint_type="R"
           AND (uc.r_constraint_name=curdb->tbl[cdb_idx].cons[ccnt1].cons_name)
           AND uc.owner=currdbuser
           AND ucc.constraint_name=uc.constraint_name
           AND ucc.table_name=uc.table_name
           AND ucc.owner=uc.owner
          ORDER BY ucc.table_name, ucc.constraint_name, ucc.position
          HEAD ucc.constraint_name
           ih_fk->fk_cnt = (ih_fk->fk_cnt+ 1), subcnt1 = ih_fk->fk_cnt, stat = alterlist(ih_fk->fk,
            subcnt1),
           ih_fk->fk[subcnt1].cons_name = ucc.constraint_name, ih_fk->fk[subcnt1].tbl_name = ucc
           .table_name, ih_fk->fk[subcnt1].col_cnt = 0
           FOR (ttbl1 = 1 TO tgtdb->tbl_cnt)
             IF ((tgtdb->tbl[ttbl1].tbl_name=ucc.table_name))
              FOR (tcons1 = 1 TO tgtdb->tbl[ttbl1].cons_cnt)
                IF ((tgtdb->tbl[ttbl1].cons[tcons1].cons_name=ucc.constraint_name)
                 AND (tgtdb->tbl[ttbl1].cons[tcons1].cons_type=uc.constraint_type))
                 ih_fk->fk[subcnt1].build_ind = 0, tcons1 = tgtdb->tbl[ttbl1].cons_cnt, ttbl1 = tgtdb
                 ->tbl_cnt
                ELSE
                 ih_fk->fk[subcnt1].build_ind = 1
                ENDIF
              ENDFOR
             ELSE
              ih_fk->fk[subcnt1].build_ind = 1
             ENDIF
           ENDFOR
          DETAIL
           ih_fk->fk[subcnt1].col_cnt = (ih_fk->fk[subcnt1].col_cnt+ 1), subcnt2 = ih_fk->fk[subcnt1]
           .col_cnt, stat = alterlist(ih_fk->fk[subcnt1].cols,subcnt2),
           ih_fk->fk[subcnt1].cols[subcnt2].col_name = ucc.column_name, ih_fk->fk[subcnt1].cols[
           subcnt2].col_position = ucc.position
          WITH nocounter
         ;end select
         FOR (ifk = 1 TO ih_fk->fk_cnt)
           IF ((ih_fk->fk[ifk].build_ind=1))
            IF ((fs_proc->inhouse_ind=0))
             SET dm_schema_log->operation = "DROP CONSTRAINT"
             SET dm_schema_log->file_name = files->uptime_ddl_file
             SET dm_schema_log->table_name = ih_fk->fk[ifk].tbl_name
             SET dm_schema_log->object_name = ih_fk->fk[ifk].cons_name
             SET dm_schema_log->column_name = ""
             EXECUTE dm_schema_estimate_op_log
            ENDIF
            SELECT INTO value(files->uptime_ddl_file)
             FROM dual
             DETAIL
              row + 1, "dm_clear_errors2 go", row + 1,
              ";drop related foreign key - inhouse or OCD mode", row + 1, "RDB ALTER TABLE ",
              ih_fk->fk[ifk].tbl_name, row + 1, "DROP CONSTRAINT ",
              ih_fk->fk[ifk].cons_name, " GO", row + 1,
              txt->errstr = substring(1,110,concat("alter table ",ih_fk->fk[ifk].tbl_name,
                " drop constraint ",ih_fk->fk[ifk].cons_name)), row + 1, "set msgnum=error(msg,1) go",
              row + 1, " dm_log_errors2 ", row + 1,
              ' "', files->uptime_err_file, '", ',
              row + 1, ' "', txt->errstr,
              '",', row + 1, " msg, msgnum go"
              IF ((tgtdb->tbl[tcnt1].combine_ind=1))
               rfiles->qual[fidx].ddl_dn_ind = 1
              ELSE
               rfiles->qual[fidx].ddl_up_ind = 1
              ENDIF
             WITH format = variable, noheading, formfeed = none,
              maxcol = 512, maxrow = 1, append
            ;end select
            IF ((fs_proc->inhouse_ind=0))
             EXECUTE dm_schema_estimate_op_log
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
        FOR (ifk = 1 TO curdb->tbl[cdb_idx].cons[ccnt1].fk_cnt)
          IF ((fs_proc->inhouse_ind=0))
           SET dm_schema_log->operation = "DROP CONSTRAINT"
           IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=1))
            SET dm_schema_log->file_name = files->downtime_ddl_file
           ELSE
            SET dm_schema_log->file_name = files->uptime_ddl_file
           ENDIF
           SET dm_schema_log->table_name = curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].tbl_name
           SET dm_schema_log->object_name = curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].tbl_name
           SET dm_schema_log->column_name = ""
           EXECUTE dm_schema_estimate_op_log
          ENDIF
          SELECT
           IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=0))INTO value(files->uptime_ddl_file)
           ELSEIF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=1))INTO value(files->
             downtime_ddl_file)
           ELSE
           ENDIF
           FROM dual
           DETAIL
            row + 1, "dm_clear_errors2 go", row + 1,
            "RDB ALTER TABLE ", curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].tbl_name, row + 1,
            "DROP CONSTRAINT ", curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].cons_name, " GO",
            row + 1, txt->errstr = substring(1,110,concat("alter table ",curdb->tbl[cdb_idx].cons[
              ccnt1].fk[ifk].tbl_name," drop constraint ",curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].
              cons_name)), row + 1,
            "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 "
            IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=0))
             row + 1, ' "', files->uptime_err_file,
             '", '
            ELSE
             row + 1, ' "', files->downtime_err_file,
             '", '
            ENDIF
            row + 1, ' "', txt->errstr,
            '",', row + 1, " msg, msgnum go"
           WITH format = variable, noheading, formfeed = none,
            maxcol = 512, maxrow = 1, append
          ;end select
          IF ((fs_proc->inhouse_ind=0))
           EXECUTE dm_schema_estimate_op_log
          ENDIF
        ENDFOR
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP CONSTRAINT"
         IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=1))
          SET dm_schema_log->file_name = files->downtime_ddl_file
         ELSE
          SET dm_schema_log->file_name = files->uptime_ddl_file
         ENDIF
         SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
         SET dm_schema_log->object_name = curdb->tbl[cdb_idx].cons[ccnt1].cons_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log
        ENDIF
        SELECT
         IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=0))INTO value(files->uptime_ddl_file)
         ELSEIF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=1))INTO value(files->downtime_ddl_file
           )
         ELSE
         ENDIF
         FROM dual
         DETAIL
          row + 1, "dm_clear_errors2 go", row + 1,
          "RDB ALTER TABLE ", curdb->tbl[cdb_idx].tbl_name, row + 1,
          "DROP CONSTRAINT ", curdb->tbl[cdb_idx].cons[ccnt1].cons_name, row + 1,
          " GO", txt->errstr = substring(1,110,concat("alter table ",curdb->tbl[cdb_idx].tbl_name,
            " drop constraint ",curdb->tbl[cdb_idx].cons[ccnt1].cons_name)), row + 1,
          "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 "
          IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=0))
           row + 1, ' "', files->uptime_err_file,
           '", '
          ELSE
           row + 1, ' "', files->downtime_err_file,
           '", '
          ENDIF
          row + 1, ' "', txt->errstr,
          '",', row + 1, " msg, msgnum go",
          row + 1, " dm_user_last_updt go"
          IF ((tgtdb->tbl[tcnt1].combine_ind=1))
           rfiles->qual[fidx].ddl_dn_ind = 1
          ELSE
           IF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=0))
            rfiles->qual[fidx].ddl_up_ind = 1
           ELSEIF ((curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind=1))
            rfiles->qual[fidx].ddl_dn_ind = 1
           ENDIF
          ENDIF
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log
        ENDIF
       ENDIF
     ENDFOR
     FREE RECORD ind_tspace
     RECORD ind_tspace(
       1 downtime_ind = i2
       1 cnt = i4
       1 t[*]
         2 tspace_name = vc
     )
     SET ind_tspace->downtime_ind = 0
     SET ind_tspace->cnt = 0
     SET stat = alterlist(ind_tspace->t,0)
     FOR (icnt1 = 1 TO curdb->tbl[cdb_idx].ind_cnt)
       IF ((curdb->tbl[cdb_idx].ind[icnt1].drop_ind=1))
        CALL echo("drop indexes")
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP INDEX"
         IF ((curdb->tbl[cdb_idx].ind[icnt1].downtime_ind=1))
          SET dm_schema_log->file_name = files->downtime_ddl_file
         ELSE
          SET dm_schema_log->file_name = files->uptime_ddl_file
         ENDIF
         SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
         SET dm_schema_log->object_name = curdb->tbl[cdb_idx].ind[icnt1].ind_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log
        ENDIF
        SELECT
         IF ((curdb->tbl[cdb_idx].ind[icnt1].downtime_ind=0))INTO value(files->uptime_ddl_file)
         ELSEIF ((curdb->tbl[cdb_idx].ind[icnt1].downtime_ind=1))INTO value(files->downtime_ddl_file)
         ELSE
         ENDIF
         d.seq
         FROM (dummyt d  WITH seq = 1)
         PLAN (d)
         DETAIL
          row + 1, "dm_clear_errors2 go", row + 1,
          "RDB DROP INDEX ", curdb->tbl[cdb_idx].ind[icnt1].ind_name, " GO",
          txt->errstr = substring(1,110,concat("drop index ",curdb->tbl[cdb_idx].ind[icnt1].ind_name)
           ), row + 1, "set msgnum=error(msg,1) go",
          row + 1, " dm_log_errors2 "
          IF ((curdb->tbl[cdb_idx].ind[icnt1].downtime_ind=0))
           row + 1, ' "', files->uptime_err_file,
           '", '
          ELSE
           row + 1, ' "', files->downtime_err_file,
           '", '
          ENDIF
          row + 1, ' "', txt->errstr,
          '",', row + 1, " msg, msgnum go",
          row + 1, tsp_found = 0
          FOR (tsp = 1 TO ind_tspace->cnt)
            IF ((ind_tspace->t[tsp].tspace_name=curdb->tbl[cdb_idx].ind[icnt1].tspace_name))
             tsp_found = tsp, tsp = ind_tspace->cnt
            ENDIF
          ENDFOR
          IF (tsp_found=0)
           ind_tspace->cnt = (ind_tspace->cnt+ 1), stat = alterlist(ind_tspace->t,ind_tspace->cnt),
           ind_tspace->t[ind_tspace->cnt].tspace_name = curdb->tbl[cdb_idx].ind[icnt1].tspace_name,
           ind_tspace->downtime_ind = curdb->tbl[cdb_idx].ind[icnt1].downtime_ind
          ENDIF
          IF ((tgtdb->tbl[tcnt1].combine_ind=1))
           rfiles->qual[fidx].ddl_dn_ind = 1
          ELSE
           IF ((curdb->tbl[cdb_idx].ind[icnt1].downtime_ind=0))
            rfiles->qual[fidx].ddl_up_ind = 1
           ELSEIF ((curdb->tbl[cdb_idx].ind[icnt1].downtime_ind=1))
            rfiles->qual[fidx].ddl_dn_ind = 1
           ENDIF
          ENDIF
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log
        ENDIF
       ENDIF
     ENDFOR
     FOR (tsp = 1 TO ind_tspace->cnt)
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "COALESCE TABLESPACE"
        IF ((ind_tspace->downtime_ind=1))
         SET dm_schema_log->file_name = files->downtime_ddl_file
        ELSE
         SET dm_schema_log->file_name = files->uptime_ddl_file
        ENDIF
        SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
        SET dm_schema_log->object_name = ind_tspace->t[tsp].tspace_name
        SET dm_schema_log->column_name = ""
        EXECUTE dm_schema_estimate_op_log
       ENDIF
       SELECT
        IF ((ind_tspace->downtime_ind=0))INTO value(files->uptime_ddl_file)
        ELSEIF ((ind_tspace->downtime_ind=1))INTO value(files->downtime_ddl_file)
        ELSE
        ENDIF
        FROM dual
        DETAIL
         row + 1, "RDB ALTER TABLESPACE ", ind_tspace->t[tsp].tspace_name,
         row + 1, "COALESCE GO"
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log
       ENDIF
     ENDFOR
     CALL echo("looking for column changes (NOT NULL to null) - downtime changes")
     SET user_updt_ind = 0
     FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
       IF ((tgtdb->tbl[tcnt1].tbl_col[tc].diff_nullable_ind=1)
        AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=0)
        AND (tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=1))
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP CONSTRAINT"
         SET dm_schema_log->file_name = files->downtime_ddl_file
         SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
         SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         EXECUTE dm_schema_estimate_op_log
        ENDIF
        SELECT INTO value(files->downtime_ddl_file)
         FROM dual
         DETAIL
          row + 1, "dm_clear_errors2 go", row + 1,
          "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name, row + 1,
          "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name, " NULL go",
          txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name," modify ",
            tgtdb->tbl[tcnt1].tbl_col[tc].col_name," null")), row + 1, "set msgnum=error(msg,1) go",
          row + 1, "dm_log_errors2 ", row + 1,
          ' "', files->downtime_err_file, '", ',
          row + 1, ' "', txt->errstr,
          '",', row + 1, " msg, msgnum go",
          row + 1, rfiles->qual[fidx].ddl_dn_ind = 1
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        SET user_updt_ind = 1
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log
        ENDIF
       ENDIF
     ENDFOR
     IF (user_updt_ind=1)
      SELECT INTO value(files->downtime_ddl_file)
       FROM dual
       DETAIL
        row + 1, "dm_user_last_updt go"
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
     ENDIF
    ENDIF
    FREE RECORD ind_tspace
    RECORD ind_tspace(
      1 downtime_ind = i2
      1 cnt = i4
      1 t[*]
        2 tspace_name = vc
    )
    SET ind_tspace->downtime_ind = 0
    SET ind_tspace->cnt = 0
    SET stat = alterlist(ind_tspace->t,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].ind_cnt))
     PLAN (d
      WHERE (tgtdb->tbl[tcnt1].ind[d.seq].build_ind=1))
     DETAIL
      tsp_found = 0
      FOR (tsp = 1 TO ind_tspace->cnt)
        IF ((ind_tspace->t[tsp].tspace_name=tgtdb->tbl[tcnt1].ind[d.seq].tspace_name))
         tsp_found = tsp, tsp = ind_tspace->cnt
        ENDIF
      ENDFOR
      IF (tsp_found=0)
       ind_tspace->cnt = (ind_tspace->cnt+ 1), stat = alterlist(ind_tspace->t,ind_tspace->cnt),
       ind_tspace->t[ind_tspace->cnt].tspace_name = tgtdb->tbl[tcnt1].ind[d.seq].tspace_name,
       ind_tspace->downtime_ind = tgtdb->tbl[tcnt1].ind[d.seq].downtime_ind
      ENDIF
     WITH nocounter
    ;end select
    FOR (tsp = 1 TO ind_tspace->cnt)
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "COALESCE TABLESPACE"
       IF ((ind_tspace->downtime_ind=1))
        SET dm_schema_log->file_name = files->downtime_ddl_file
       ELSE
        SET dm_schema_log->file_name = files->uptime_ddl_file
       ENDIF
       SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
       SET dm_schema_log->object_name = ind_tspace->t[tsp].tspace_name
       SET dm_schema_log->column_name = ""
       EXECUTE dm_schema_estimate_op_log
      ENDIF
      SELECT
       IF ((ind_tspace->downtime_ind=0))INTO value(files->uptime_ddl_file)
       ELSEIF ((ind_tspace->downtime_ind=1))INTO value(files->downtime_ddl_file)
       ELSE
       ENDIF
       FROM dual
       DETAIL
        row + 1, "RDB ALTER TABLESPACE ", ind_tspace->t[tsp].tspace_name,
        row + 1, "COALESCE GO"
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log
      ENDIF
    ENDFOR
    FOR (icnt1 = 1 TO tgtdb->tbl[tcnt1].ind_cnt)
      IF ((tgtdb->tbl[tcnt1].ind[icnt1].build_ind=1))
       CALL echo("build indexes")
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "CREATE INDEX"
        IF ((tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind=1))
         SET dm_schema_log->file_name = files->downtime_ddl_file
        ELSE
         SET dm_schema_log->file_name = files->uptime_ddl_file
        ENDIF
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].ind[icnt1].ind_name
        SET dm_schema_log->column_name = ""
        EXECUTE dm_schema_estimate_op_log
       ENDIF
       SELECT
        IF ((tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind=0))INTO value(files->uptime_ddl_file)
        ELSEIF ((tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind=1))INTO value(files->downtime_ddl_file)
        ELSE
        ENDIF
        d.seq
        FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].ind[icnt1].ind_col_cnt))
        PLAN (d)
        ORDER BY tgtdb->tbl[tcnt1].ind[icnt1].ind_col[d.seq].col_position
        HEAD REPORT
         row + 1, "dm_clear_errors2 go", row + 1,
         "RDB CREATE"
         IF ((tgtdb->tbl[tcnt1].ind[icnt1].unique_ind=1))
          " UNIQUE"
         ENDIF
         " INDEX ", row + 1, tgtdb->tbl[tcnt1].ind[icnt1].ind_name,
         " ON ", tgtdb->tbl[tcnt1].tbl_name, " ("
        DETAIL
         IF ((tgtdb->tbl[tcnt1].ind[icnt1].ind_col[d.seq].col_position > 1))
          ", "
         ENDIF
         row + 1, tgtdb->tbl[tcnt1].ind[icnt1].ind_col[d.seq].col_name
        FOOT REPORT
         row + 1, ")"
         IF ((tgtdb->tbl[tcnt1].ind[icnt1].init_ext > 0)
          AND (tgtdb->tbl[tcnt1].ind[icnt1].next_ext > 0))
          init_extent = ceil((tgtdb->tbl[tcnt1].ind[icnt1].init_ext/ 1024)), next_extent = ceil((
           tgtdb->tbl[tcnt1].ind[icnt1].next_ext/ 1024)), row + 1,
          "STORAGE ( INITIAL ", init_extent, "K NEXT ",
          next_extent, "K )"
         ENDIF
         row + 1, "UNRECOVERABLE ", row + 1,
         "TABLESPACE ", tgtdb->tbl[tcnt1].ind[icnt1].tspace_name, row + 1,
         "go", txt->errstr = substring(1,110,concat("create index ",tgtdb->tbl[tcnt1].ind[icnt1].
           ind_name)), row + 1,
         "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 "
         IF ((tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind=0))
          row + 1, ' "', files->uptime_err_file,
          '", '
         ELSE
          row + 1, ' "', files->downtime_err_file,
          '", '
         ENDIF
         row + 1, ' "', txt->errstr,
         '",', row + 1, " msg, msgnum go",
         row + 1, " dm_user_last_updt go", row + 2
         IF ((tgtdb->tbl[tcnt1].combine_ind=1))
          rfiles->qual[fidx].ddl_dn_ind = 1
         ELSE
          IF ((tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind=0))
           rfiles->qual[fidx].ddl_up_ind = 1
          ELSEIF ((tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind=1))
           rfiles->qual[fidx].ddl_dn_ind = 1
          ENDIF
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log
       ENDIF
      ENDIF
    ENDFOR
    FOR (ccnt1 = 1 TO tgtdb->tbl[tcnt1].cons_cnt)
      IF ((tgtdb->tbl[tcnt1].cons[ccnt1].build_ind=1))
       CALL echo("build constraints")
       CALL create_cons(tcnt1,ccnt1,fidx)
       IF ((tgtdb->tbl[tcnt1].cons[ccnt1].cons_type="P")
        AND (tgtdb->tbl[tcnt1].cons[ccnt1].fk_cnt > 0))
        FOR (fkcnt1 = 1 TO tgtdb->tbl[tcnt1].cons[ccnt1].fk_cnt)
         CALL echo("build related fk constraints")
         CALL create_cons(tgtdb->tbl[tcnt1].cons[ccnt1].fk[fkcnt1].tbl_ndx,tgtdb->tbl[tcnt1].cons[
          ccnt1].fk[fkcnt1].cons_ndx,fidx)
        ENDFOR
       ENDIF
      ELSEIF ((tgtdb->tbl[tcnt1].cons[ccnt1].diff_status_ind=1))
       CALL echo("change constraint status")
       SELECT
        IF ((tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind=0))INTO value(files->uptime_ddl_file)
        ELSEIF ((tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind=1))INTO value(files->downtime_ddl_file)
        ELSE
        ENDIF
        FROM dual
        DETAIL
         row + 1, "dm_clear_errors2 go", row + 1,
         "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name
         IF ((tgtdb->tbl[tcnt1].cons[ccnt1].status_ind=1))
          " ENABLE ", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
            " enable ",tgtdb->tbl[tcnt1].cons[ccnt1].cons_name))
         ELSE
          " DISABLE ", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
            " disable ",tgtdb->tbl[tcnt1].cons[ccnt1].cons_name))
         ENDIF
         row + 1, "CONSTRAINT ", tgtdb->tbl[tcnt1].cons[ccnt1].cons_name,
         " go", row + 1, "set msgnum=error(msg,1) go",
         row + 1, " dm_log_errors2 "
         IF ((tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind=0))
          row + 1, ' "', files->uptime_err_file,
          '", '
         ELSE
          row + 1, ' "', files->downtime_err_file,
          '", '
         ENDIF
         row + 1, ' "', txt->errstr,
         '",', row + 1, " msg, msgnum go",
         row + 1, " dm_user_last_updt go", row + 2
         IF ((tgtdb->tbl[tcnt1].combine_ind=1))
          rfiles->qual[fidx].ddl_dn_ind = 1
         ELSE
          IF ((tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind=0))
           rfiles->qual[fidx].ddl_up_ind = 1
          ELSEIF ((tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind=1))
           rfiles->qual[fidx].ddl_dn_ind = 1
          ENDIF
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
    ENDFOR
    IF ((((fs_proc->inhouse_ind=1)) OR ((fs_proc->ocd_ind=1)))
     AND (ih_fk->fk_cnt > 0))
     FOR (ih_cnt = 1 TO ih_fk->fk_cnt)
       IF ((ih_fk->fk[ih_cnt].build_ind=1))
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "ADD FOREIGN KEY CONSTRAINT"
         SET dm_schema_log->file_name = files->uptime_ddl_file
         SET dm_schema_log->table_name = ih_fk->fk[ih_cnt].tbl_name
         SET dm_schema_log->object_name = ih_fk->fk[ih_cnt].cons_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log
        ENDIF
        SELECT INTO value(files->uptime_ddl_file)
         d.seq
         FROM (dummyt d  WITH seq = value(ih_fk->fk[ih_cnt].col_cnt))
         PLAN (d)
         HEAD REPORT
          row + 1, "dm_clear_errors2 go", row + 1,
          "RDB ALTER TABLE ", ih_fk->fk[ih_cnt].tbl_name, row + 1,
          "ADD CONSTRAINT ", ih_fk->fk[ih_cnt].cons_name, row + 1,
          "FOREIGN KEY"
         DETAIL
          IF ((ih_fk->fk[ih_cnt].cols[d.seq].col_position=1))
           row + 1, "  (", ih_fk->fk[ih_cnt].cols[d.seq].col_name
          ELSE
           row + 1, "  ,", ih_fk->fk[ih_cnt].cols[d.seq].col_name
          ENDIF
         FOOT REPORT
          ") references ", tgtdb->tbl[tcnt1].tbl_name, row + 1
          FOR (par_col_cnt = 1 TO ih_fk->parent_col_cnt)
            IF (par_col_cnt=1)
             row + 1, "  (", ih_fk->pcols[par_col_cnt].col_name
            ELSE
             row + 1, "  ,", ih_fk->pcols[par_col_cnt].col_name
            ENDIF
          ENDFOR
          ")", row + 1, "disable go",
          txt->errstr = substring(1,110,concat("alter table ",ih_fk->fk[ih_cnt].tbl_name,
            " add constraint ",ih_fk->fk[ih_cnt].cons_name)), row + 1, "set msgnum=error(msg,1) go",
          row + 1, " dm_log_errors2 ", row + 1,
          ' "', files->uptime_err_file, '", ',
          row + 1, ' "', txt->errstr,
          '",', row + 1, " msg, msgnum go"
          IF ((tgtdb->tbl[tcnt1].combine_ind=1))
           rfiles->qual[fidx].ddl_dn_ind = 1
          ELSE
           rfiles->qual[fidx].ddl_up_ind = 1
          ENDIF
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("write compile all objects command")
 FOR (fi = 1 TO rfiles->fcnt)
   CALL dis_write_compile_objects(fi)
 ENDFOR
 SET dmsteps_idx = 0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(rfiles->fcnt))
  PLAN (d
   WHERE (rfiles->qual[d.seq].fname="*dmsteps*"))
  DETAIL
   dmsteps_idx = d.seq
  WITH nocounter
 ;end select
 IF (dmsteps_idx > 0)
  CALL echo("writing global DM steps")
  SELECT INTO value(rfiles->qual[dmsteps_idx].file2d)
   FROM (dummyt t  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (t
    WHERE t.seq > 0)
   HEAD REPORT
    ";Now compile all invalid objects", row + 1, "execute dm_compile_all_objects go",
    row + 1, row + 1
   DETAIL
    IF ((tgtdb->tbl[t.seq].zero_row_ind=1))
     txt->txt = build('"',tgtdb->tbl[t.seq].tbl_name,'"'), "dm_clear_errors2 go", row + 1,
     row + 1, ";Execute Add Zero Row step", row + 1,
     "execute dm_add_zero_rows ", txt->txt, " go",
     row + 1, row + 1, txt->errstr = substring(1,110,concat("add zero row to table ",trim(tgtdb->tbl[
        t.seq].tbl_name))),
     "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 ",
     row + 1, ' "', rfiles->qual[dmsteps_idx].file3d,
     '", ', row + 1, ' "',
     txt->errstr, '",', row + 1,
     " msg, msgnum go", row + 1, row + 1
    ENDIF
    IF ((tgtdb->tbl[t.seq].active_trigger_ind=1))
     txt->txt = build('"',tgtdb->tbl[t.seq].tbl_name,'"'), "dm_clear_errors2 go", row + 1,
     row + 1, ";Execute Active_ind Trigger step", row + 1,
     "execute dm_create_active_trigger ", txt->txt, " go",
     row + 1, row + 1, txt->errstr = substring(1,110,concat("create active_ind trigger on table ",
       trim(tgtdb->tbl[t.seq].tbl_name))),
     "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 ",
     row + 1, ' "', rfiles->qual[dmsteps_idx].file3d,
     '", ', row + 1, ' "',
     txt->errstr, '",', row + 1,
     " msg, msgnum go", row + 1, row + 1
    ENDIF
    IF ((tgtdb->tbl[t.seq].synonym_ind=1))
     txt->txt = build('"',tgtdb->tbl[t.seq].tbl_name,'"'), "dm_clear_errors2 go", row + 1,
     row + 1, ";Execute Public Synonym step", row + 1,
     "execute dm_create_object_synonym ", txt->txt, ', "TABLE" go',
     row + 1, row + 1, txt->errstr = substring(1,110,concat("create public synonym for table ",trim(
        tgtdb->tbl[t.seq].tbl_name))),
     "set msgnum=error(msg,1) go", row + 1, " dm_log_errors2 ",
     row + 1, ' "', rfiles->qual[dmsteps_idx].file3d,
     '", ', row + 1, ' "',
     txt->errstr, '",', row + 1,
     " msg, msgnum go", row + 1, row + 1
    ENDIF
   WITH format = variable, formfeed = none, noheading,
    maxrow = 1, maxcol = 512, append
  ;end select
 ENDIF
 FOR (cnt2 = 1 TO rfiles->fcnt)
   CALL term_files(cnt2)
 ENDFOR
 SUBROUTINE dis_write_compile_objects(file_idx)
   IF ((rfiles->qual[file_idx].ddl_up_ind=1))
    SELECT INTO value(rfiles->qual[file_idx].file2)
     FROM dual
     DETAIL
      ";Now compile all invalid objects", row + 1
      IF ((fs_proc->ocd_ind=1))
       "execute dm_ocd_compile_objects ", fs_proc->ocd_number, " go",
       row + 1
      ELSE
       "execute dm_compile_all_objects go", row + 1
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      noheading, maxrow = 1, maxcol = 512,
      append
    ;end select
    SET rfiles->qual[file_idx].ddl_up_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE init_files(idx1)
   SELECT INTO value(rfiles->qual[idx1].file2)
    *
    FROM dual
    DETAIL
     IF ((fs_proc->ocd_ind=0)
      AND (fs_proc->inhouse_ind=0))
      "%o  ", rfiles->qual[idx1].file4, row + 1
     ENDIF
     "%d echo on", row + 1, "set message 0 go",
     row + 1, row + 1, "; This file is generated by the fix schema process for uptime changes",
     row + 1, "; Started at ", curdate"DD-MMM-YYYY;;D",
     " ", curtime"HH:MM:SS;;M", row + 1,
     row + 1, "set msg=fillstring(132,' ') go", row + 1,
     "set filename3='", rfiles->qual[idx1].file3, "' go",
     row + 1, row + 1, "set trace symbol mark go",
     row + 1, row + 1, "select into value(filename3) * from dual",
     row + 1, "detail", row + 1,
     "  '; Fix schema uptime Error Logging file generated after running',row+1", row + 1,
     "  '; fix schema commands in the ",
     rfiles->qual[idx1].file2, "', row+1", row + 1,
     "  '; file.', row+1", row + 1,
     "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
     ", row+1, row+1", row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1 go",
     row + 1
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   IF ((fs_proc->ocd_ind=0)
    AND (fs_proc->inhouse_ind=0))
    SELECT INTO value(rfiles->qual[idx1].file1com)
     *
     FROM dual
     DETAIL
      IF ((fs_proc->env[1].oper_sys="VMS"))
       row + 1, "$! This file is generated by the fix schema process", row + 1,
       "$! It can be submitted as a job ", row + 1, "$! Generated on ",
       curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
       row + 1, "$!", row + 1,
       "$set verify", row + 1, '$define sys$output "ccluserdir:',
       rfiles->qual[idx1].file1log, '"', row + 1,
       '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1, "$CCL"
      ELSE
       col 0, "#!/usr/bin/ksh", row + 1,
       ". $cer_mgr/.user_setup ", fs_proc->env[1].envset_str, row + 1,
       "# This file is generated by the fix schema process", row + 1,
       "# It can be submitted as a job ",
       row + 1, "# Generated on ", curdate"DD-MMM-YYYY ;;D",
       " ", curtime"HH:MM:SS;;M", row + 1,
       "ccl <<!"
      ENDIF
      row + 1, "%i ccluserdir:", rfiles->qual[idx1].file2,
      row + 1, "exit"
      IF ((fs_proc->env[1].oper_sys="VMS"))
       row + 1, col 0, "$!",
       row + 1, col 0, "$set nover",
       row + 1, col 0, "$deassign sys$output"
      ENDIF
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
    SELECT INTO value(rfiles->qual[idx1].file1dcom)
     *
     FROM dual
     DETAIL
      IF ((fs_proc->env[1].oper_sys="VMS"))
       row + 1, "$! This file is generated by the fix schema process", row + 1,
       "$! It can be submitted as a job ", row + 1, "$! Generated on ",
       curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
       row + 1, "$!", row + 1,
       "$set verify", row + 1, '$define sys$output "ccluserdir:',
       rfiles->qual[idx1].file1dlog, '"', row + 1,
       '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1, "$CCL"
      ELSE
       col 0, "#!/usr/bin/ksh", row + 1,
       ". $cer_mgr/.user_setup ", fs_proc->env[1].envset_str, row + 1,
       "# This file is generated by the fix schema process", row + 1,
       "# It can be submitted as a job ",
       row + 1, "# Generated on ", curdate"DD-MMM-YYYY ;;D",
       " ", curtime"HH:MM:SS;;M", row + 1,
       "ccl <<!"
      ENDIF
      row + 1, "%i ccluserdir:", rfiles->qual[idx1].file2d,
      row + 1, "exit"
      IF ((fs_proc->env[1].oper_sys="VMS"))
       row + 1, col 0, "$!",
       row + 1, col 0, "$set nover",
       row + 1, col 0, "$deassign sys$output"
      ENDIF
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
   ENDIF
   IF ((fs_proc->ocd_ind=0)
    AND (fs_proc->inhouse_ind=0))
    SELECT INTO value(rfiles->qual[idx1].file2d)
     *
     FROM dual
     DETAIL
      "%o  ", rfiles->qual[idx1].file4d, row + 2,
      "%d echo on", row + 1, "set message 0 go",
      row + 1, row + 1, "; This file is generated by the fix schema process for downtime changes",
      row + 1, "; Started at ", curdate"DD-MMM-YYYY ;;D",
      " ", curtime"HH:MM:SS;;M", row + 1,
      row + 1, "set msg=fillstring(132,' ') go", row + 1,
      "set filename3='", rfiles->qual[idx1].file3d, "' go",
      row + 1, row + 1, "set trace symbol mark go",
      row + 1, row + 1, "select into value(filename3) * from dual",
      row + 1, "detail", row + 1,
      "  '; Fix schema downtime Error Logging file generated after running'", ", row+1", row + 1,
      "  '; fix schema commands in the ", rfiles->qual[idx1].file2d, " file', row+1",
      row + 1, "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
      ", row+1, row+1",
      row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1 go", row + 2
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
    SELECT INTO value(rfiles->qual[idx1].file3d)
     *
     FROM dual
     DETAIL
      " ", row + 1
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
   ENDIF
   SELECT INTO value(rfiles->qual[idx1].file3)
    *
    FROM dual
    DETAIL
     " ", row + 1
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_cons(idx3,idx4,idx5)
   IF ((fs_proc->inhouse_ind=0))
    IF ((tgtdb->tbl[idx3].cons[idx4].cons_type="P"))
     SET dm_schema_log->operation = "ADD PRIMARY KEY CONSTRAINT"
    ELSEIF ((tgtdb->tbl[idx3].cons[idx4].cons_type="R"))
     SET dm_schema_log->operation = "ADD FOREIGN KEY CONSTRAINT"
    ELSEIF ((tgtdb->tbl[idx3].cons[idx4].cons_type="U"))
     SET dm_schema_log->operation = "ADD PRIMARY KEY CONSTRAINT"
    ENDIF
    IF ((tgtdb->tbl[idx3].cons[idx4].downtime_ind=1))
     SET dm_schema_log->file_name = files->downtime_ddl_file
    ELSE
     SET dm_schema_log->file_name = files->uptime_ddl_file
    ENDIF
    SET dm_schema_log->table_name = tgtdb->tbl[idx3].tbl_name
    SET dm_schema_log->object_name = tgtdb->tbl[idx3].cons[idx4].cons_name
    SET dm_schema_log->column_name = ""
    EXECUTE dm_schema_estimate_op_log
   ENDIF
   SELECT
    IF ((tgtdb->tbl[idx3].cons[idx4].downtime_ind=0))INTO value(files->uptime_ddl_file)
    ELSEIF ((tgtdb->tbl[idx3].cons[idx4].downtime_ind=1))INTO value(files->downtime_ddl_file)
    ELSE
    ENDIF
    d.seq
    FROM (dummyt d  WITH seq = value(tgtdb->tbl[idx3].cons[idx4].cons_col_cnt))
    PLAN (d)
    ORDER BY tgtdb->tbl[idx3].cons[idx4].cons_col[d.seq].col_position
    HEAD REPORT
     row + 1, "dm_clear_errors2 go", row + 1,
     "rdb ALTER TABLE ", tgtdb->tbl[idx3].tbl_name, row + 1,
     "add constraint ", tgtdb->tbl[idx3].cons[idx4].cons_name
     IF ((tgtdb->tbl[idx3].cons[idx4].cons_type="R"))
      " FOREIGN KEY"
     ELSEIF ((tgtdb->tbl[idx3].cons[idx4].cons_type="P"))
      " PRIMARY KEY"
     ELSE
      " UNIQUE"
     ENDIF
    DETAIL
     IF ((tgtdb->tbl[idx3].cons[idx4].cons_col[d.seq].col_position=1))
      row + 1, "  (", tgtdb->tbl[idx3].cons[idx4].cons_col[d.seq].col_name
     ELSE
      row + 1, "  ,", tgtdb->tbl[idx3].cons[idx4].cons_col[d.seq].col_name
     ENDIF
    FOOT REPORT
     IF ((tgtdb->tbl[idx3].cons[idx4].cons_type="R"))
      ") references ", tgtdb->tbl[idx3].cons[idx4].parent_table, row + 1,
      len = size(trim(tgtdb->tbl[idx3].cons[idx4].parent_table_columns)), cons_i = 1, found =
      findstring(",",tgtdb->tbl[idx3].cons[idx4].parent_table_columns,cons_i)
      IF (found > 0)
       WHILE (found > 0)
         txt->col_name = substring(cons_i,(found - cons_i),tgtdb->tbl[idx3].cons[idx4].
          parent_table_columns)
         IF (cons_i=1)
          txt->txt = concat("(",txt->col_name)
         ELSE
          txt->txt = concat(",",txt->col_name)
         ENDIF
         "    ", txt->txt, row + 1,
         cons_i = (found+ 1), found = findstring(",",tgtdb->tbl[idx3].cons[idx4].parent_table_columns,
          cons_i)
       ENDWHILE
       txt->col_name = substring(cons_i,len,tgtdb->tbl[idx3].cons[idx4].parent_table_columns), txt->
       txt = concat(",",txt->col_name,")"), "    ",
       txt->txt, row + 1
      ELSE
       txt->txt = concat("(",tgtdb->tbl[idx3].cons[idx4].parent_table_columns,")"), "    ", txt->txt,
       row + 1
      ENDIF
     ELSE
      "  )", row + 1
     ENDIF
     IF ((((tgtdb->tbl[idx3].cons[idx4].status_ind=0)) OR ((tgtdb->tbl[idx3].cons[idx4].cons_type="R"
     ))) )
      "  disable "
     ENDIF
     " go", row + 2, txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[idx3].tbl_name,
       " add constraint ",tgtdb->tbl[idx3].cons[idx4].cons_name)),
     row + 1, "set msgnum=error(msg,1) go", row + 1,
     " dm_log_errors2 "
     IF ((tgtdb->tbl[idx3].cons[idx4].downtime_ind=0))
      row + 1, ' "', files->uptime_err_file,
      '", '
     ELSE
      row + 1, ' "', files->downtime_err_file,
      '", '
     ENDIF
     row + 1, ' "', txt->errstr,
     '",', row + 1, " msg, msgnum go",
     row + 1, " dm_user_last_updt go", row + 2
     IF ((tgtdb->tbl[tcnt1].combine_ind=1))
      rfiles->qual[fidx].ddl_dn_ind = 1
     ELSE
      IF ((tgtdb->tbl[idx3].cons[idx4].downtime_ind=0))
       rfiles->qual[idx5].ddl_up_ind = 1
      ELSEIF ((tgtdb->tbl[idx3].cons[idx4].downtime_ind=1))
       rfiles->qual[idx5].ddl_dn_ind = 1
      ENDIF
     ENDIF
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   IF ((fs_proc->inhouse_ind=0))
    EXECUTE dm_schema_estimate_op_log
   ENDIF
 END ;Subroutine
 SUBROUTINE term_files(idx1)
  SELECT INTO value(rfiles->qual[idx1].file2)
   *
   FROM dual
   DETAIL
    "execute dm_user_last_updt go", row + 1, "select into value(filename3) * from dual",
    row + 1, "detail", row + 1,
    "  '; End of Uptime Error Logging file generated after running',row+1", row + 1,
    "  '; fix schema output file ",
    rfiles->qual[idx1].file2, "', row+1", row + 1,
    "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", row + 1,
    "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go",
    row + 1
    IF ((fs_proc->ocd_ind=0)
     AND (fs_proc->inhouse_ind=0))
     row + 1, row + 1, row + 1,
     "; End of file", row + 1, "; Ended at ",
     curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
     row + 1, "%o"
    ENDIF
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  IF ((fs_proc->ocd_ind=0)
   AND (fs_proc->inhouse_ind=0))
   SELECT INTO value(rfiles->qual[idx1].file2d)
    *
    FROM dual
    DETAIL
     "execute dm_user_last_updt go", row + 1, "select into value(filename3) * from dual",
     row + 1, "detail", row + 1,
     "  '; End of Downtime Error Logging file generated after running',row+1", row + 1,
     "  '; fix schema output file ",
     rfiles->qual[idx1].file2d, "', row+1", row + 1,
     "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", row + 1,
     "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go",
     row + 1, row + 1, row + 1,
     row + 1, "; End of file", row + 1,
     "; Ended at ", curdate"DD-MMM-YYYY ;;D", " ",
     curtime"HH:MM:SS;;M", row + 1, "%o"
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
  ENDIF
 END ;Subroutine
END GO
