CREATE PROGRAM dm_create_ddl2:dba
 SET init_extent = 0.0
 SET next_extent = 0.0
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
 SET current_op_id = 0
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
   1 ddl_file = vc
   1 err_file = vc
 )
 DECLARE dcd_cursor_commit_cnt = i4
 SET dcd_cursor_commit_cnt = 10000
 SELECT INTO "nl:"
  di.info_char
  FROM dm_info di
  WHERE di.info_domain="DM2_ORACLE_DB_OPTION"
   AND info_name="CURSOR_COMMIT_CNT"
  DETAIL
   IF (di.info_char != "CERNER_DEFAULT"
    AND cnvtint(di.info_char) > 0)
    dcd_cursor_commit_cnt = cnvtint(di.info_char)
   ENDIF
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  INSERT  FROM dm_info
   SET info_domain = "DM2_ORACLE_DB_OPTION", info_name = "CURSOR_COMMIT_CNT", info_char =
    "CERNER_DEFAULT",
    info_number = 0
   WITH nocounter
  ;end insert
 ENDIF
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
 FOR (tcnt1 = 1 TO tgtdb->tbl_cnt)
   SET fidx = tgtdb->tbl[tcnt1].file_idx
   IF ((((tgtdb->tbl[tcnt1].uptime_ind=1)) OR ((fs_proc->online_ind=1))) )
    CALL dcd_init_up_file(tgtdb->tbl[tcnt1].file_idx)
   ENDIF
   IF ((tgtdb->tbl[tcnt1].downtime_ind=1)
    AND (fs_proc->online_ind=0))
    CALL dcd_init_dn_file(tgtdb->tbl[tcnt1].file_idx)
   ENDIF
 ENDFOR
 IF (routine_idx > 0)
  CALL dcd_init_up_file(routine_idx)
  CALL dcd_init_dn_file(routine_idx)
 ENDIF
 IF (dmsteps_idx > 0)
  CALL dcd_init_dn_file(dmsteps_idx)
 ENDIF
 IF ((fs_proc->ocd_ind=0)
  AND (fs_proc->inhouse_ind=0)
  AND (fs_proc->online_ind=0))
  IF (routine_idx > 0)
   CALL echo("looking for sequences to create")
   FOR (ts = 1 TO tgtdb->sequence_cnt)
     IF ((tgtdb->sequence[ts].build_ind=1))
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "CREATE SEQUENCE"
       SET dm_schema_log->file_name = rfiles->qual[routine_idx].file2
       SET dm_schema_log->table_name = tgtdb->sequence[ts].seq_name
       SET dm_schema_log->object_name = tgtdb->sequence[ts].seq_name
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
      SELECT INTO value(rfiles->qual[routine_idx].file2)
       FROM dm_sequences ds
       WHERE (ds.sequence_name=tgtdb->sequence[ts].seq_name)
       HEAD REPORT
        SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
          row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
          'set ddl_log->cmd_str = "', dwl_cmd, '" go',
          row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
          " go"
        END ;Subroutine report
       DETAIL
        min_value = cnvtstring(ds.min_value), max_value = cnvtstring(ds.max_value), cache_value =
        cnvtstring(ds.cache),
        row + 1, "; Creating sequence ", ds.sequence_name,
        row + 1, "rdb CREATE SEQUENCE ", ds.sequence_name,
        row + 1, "  INCREMENT BY ", ds.increment_by
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
        CALL dcd_write_log(txt->errstr,0)
       WITH format = variable, noheading, append,
        maxrow = 1, formfeed = none, maxcol = 512
      ;end select
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
     ENDIF
   ENDFOR
   IF ((tgtdb->sequence_cnt > 0))
    IF ((fs_proc->online_ind=0))
     SELECT INTO value(rfiles->qual[routine_idx].file2)
      FROM dual
      DETAIL
       row + 1, "dm_user_last_updt go"
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 FOR (tcnt1 = 1 TO tgtdb->tbl_cnt)
   SET fidx = tgtdb->tbl[tcnt1].file_idx
   IF ((tgtdb->tbl[tcnt1].new_ind=1))
    CALL echo("create new table")
    SET files->ddl_file = dcd_get_ddl_filename(tcnt1,0)
    SET files->err_file = dcd_get_err_filename(tcnt1,0)
    IF ((fs_proc->inhouse_ind=0))
     SET dm_schema_log->operation = "CREATE TABLE"
     SET dm_schema_log->file_name = files->ddl_file
     SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
     SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_name
     EXECUTE dm_schema_estimate_op_log2
    ENDIF
    SELECT INTO value(files->ddl_file)
     FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].tbl_col_cnt))
     PLAN (d)
     HEAD REPORT
      SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
        row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
        'set ddl_log->cmd_str = "', dwl_cmd, '" go',
        row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
        " go"
      END ;Subroutine report
      IF ((fs_proc->inhouse_ind=1))
       "dm_schema_actual_start2 0 go", row + 1
      ENDIF
      row + 1, "RDB CREATE TABLE ", tgtdb->tbl[tcnt1].tbl_name,
      "("
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
       init_extent = ceil((tgtdb->tbl[tcnt1].init_ext/ 1024.0)), next_extent = ceil((tgtdb->tbl[tcnt1
        ].next_ext/ 1024.0))
       IF ((fs_proc->freelist_groups > 0))
        row + 1, "STORAGE (INITIAL ", init_extent";;I",
        "K NEXT ", next_extent";;I", "K",
        row + 1, "FREELIST GROUPS ", fs_proc->freelist_groups";L;I",
        ")"
       ELSE
        row + 1, "STORAGE (INITIAL ", init_extent";;I",
        "K NEXT ", next_extent";;I", "K )"
       ENDIF
      ENDIF
      row + 1, "TABLESPACE ", tgtdb->tbl[tcnt1].tspace_name,
      " go", txt->errstr = substring(1,110,concat("create table ",tgtdb->tbl[tcnt1].tbl_name)),
      CALL dcd_write_log(txt->errstr,0)
      IF ((fs_proc->inhouse_ind=1))
       "dm_schema_actual_stop2 0 go", row + 1
      ENDIF
      IF ((fs_proc->online_ind=0))
       row + 1, " dm_user_last_updt go"
      ENDIF
      row + 1, " oragen3 '", tgtdb->tbl[tcnt1].tbl_name,
      "' go", row + 2
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1, append
    ;end select
    IF ((fs_proc->inhouse_ind=0))
     EXECUTE dm_schema_estimate_op_log2
    ENDIF
   ELSEIF ((tgtdb->tbl[tcnt1].diff_ind=1))
    CALL echo("looking for column changes to existing table")
    SET oragen_ind = 0
    FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
      SET user_updt_ind = 0
      IF ((tgtdb->tbl[tcnt1].tbl_col[tc].new_ind=1))
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,0)
       SET files->err_file = dcd_get_err_filename(tcnt1,0)
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "ADD COLUMN"
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        FROM dual
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
         row + 1, "ADD ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
         txt->txt = tgtdb->tbl[tcnt1].tbl_col[tc].data_type
         IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="VARCHAR")) OR ((((tgtdb->tbl[tcnt1].tbl_col[
         tc].data_type="VARCHAR2")) OR ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="CHAR")) OR ((
         tgtdb->tbl[tcnt1].tbl_col[tc].data_type="RAW"))) )) )) )
          txt->dlen = cnvtstring(tgtdb->tbl[tcnt1].tbl_col[tc].data_length,0), txt->txt = concat(txt
           ->txt,"(",txt->dlen,")")
         ENDIF
         txt->txt = concat(txt->txt," NULL go"), row + 1, txt->txt,
         txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
           " add column ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name)),
         CALL dcd_write_log(txt->errstr,0)
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_stop2 0 go", row + 1
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET oragen_ind = 1
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
      ENDIF
      IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].diff_dtype_ind=1)) OR ((tgtdb->tbl[tcnt1].tbl_col[tc].
      diff_dlength_ind=1))) )
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
       SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "MODIFY COLUMN DATA TYPE"
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        FROM dual
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         IF ((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="FLOAT"))
          txt->txt = concat('dm2_nbr_to_float_updt "',trim(tgtdb->tbl[tcnt1].tbl_name),'", "',trim(
            tgtdb->tbl[tcnt1].tbl_col[tc].col_name),'" go'), txt->txt, row + 1,
          txt->errstr = substring(1,110,concat("dm2_nbr_to_float_updt '",trim(tgtdb->tbl[tcnt1].
             tbl_name),"', '",trim(tgtdb->tbl[tcnt1].tbl_col[tc].col_name),"' go")),
          CALL dcd_write_log(txt->errstr,0)
         ELSE
          row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
          row + 1, "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
          txt->txt = concat(tgtdb->tbl[tcnt1].tbl_col[tc].data_type)
          IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="VARCHAR")) OR ((((tgtdb->tbl[tcnt1].
          tbl_col[tc].data_type="VARCHAR2")) OR ((((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="CHAR"))
           OR ((tgtdb->tbl[tcnt1].tbl_col[tc].data_type="RAW"))) )) )) )
           txt->dlen = cnvtstring(tgtdb->tbl[tcnt1].tbl_col[tc].data_length,0), txt->txt = concat(txt
            ->txt,"(",txt->dlen,")")
          ENDIF
          txt->txt = concat(txt->txt," go"), row + 1, txt->txt,
          txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
            " modify column ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," data type/length")),
          CALL dcd_write_log(txt->errstr,0)
         ENDIF
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_stop2 0 go", row + 1
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET oragen_ind = 1
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
      ENDIF
      IF ((((tgtdb->tbl[tcnt1].tbl_col[tc].diff_default_ind=1)) OR ((tgtdb->tbl[tcnt1].tbl_col[tc].
      new_ind=1))) )
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,0)
       SET files->err_file = dcd_get_err_filename(tcnt1,0)
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "ADD DEFAULT VALUE"
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        FROM dual
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
         row + 1, "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
         row + 1, "DEFAULT ", tgtdb->tbl[tcnt1].tbl_col[tc].data_default,
         " go", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
           " modify column ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," default value")),
         CALL dcd_write_log(txt->errstr,0)
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_stop2 0 go", row + 1
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
      ENDIF
      IF (user_updt_ind=1)
       IF ((fs_proc->online_ind=0))
        SELECT INTO value(files->ddl_file)
         FROM dual
         DETAIL
          row + 1, "dm_user_last_updt go"
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
       ENDIF
      ENDIF
    ENDFOR
    IF (oragen_ind=1)
     SELECT INTO value(files->ddl_file)
      FROM dual
      DETAIL
       row + 1, "oragen3 '", tgtdb->tbl[tcnt1].tbl_name,
       "' go"
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
   ENDIF
   CALL dis_write_compile_table_objects(tcnt1)
 ENDFOR
 FOR (tcnt1 = 1 TO tgtdb->tbl_cnt)
   SET fidx = tgtdb->tbl[tcnt1].file_idx
   SET cdb_idx = 0
   IF ((((tgtdb->tbl[tcnt1].diff_ind=1)) OR ((tgtdb->tbl[tcnt1].new_ind=1))) )
    CALL echo("looking for sql cursor to create")
    IF ((tgtdb->tbl[tcnt1].sql_cursor_ind=1))
     SET files->ddl_file = dcd_get_ddl_filename(tcnt1,0)
     SET files->err_file = dcd_get_err_filename(tcnt1,0)
     SET rfiles->qual[tgtdb->tbl[tcnt1].file_idx].ddl_up_ind = 0
     IF ((fs_proc->inhouse_ind=0))
      SET dm_schema_log->operation = "POPULATE DEFAULT VALUE"
      SET dm_schema_log->file_name = files->ddl_file
      SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
      SET dm_schema_log->object_name = "SQL CURSOR"
      SET dm_schema_log->column_name = ""
      EXECUTE dm_schema_estimate_op_log2
     ENDIF
     SELECT INTO value(files->ddl_file)
      d.seq
      FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].tbl_col_cnt))
      PLAN (d
       WHERE (tgtdb->tbl[tcnt1].tbl_col[d.seq].null_to_notnull_ind=1))
      HEAD REPORT
       SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
         row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
         'set ddl_log->cmd_str = "', dwl_cmd, '" go',
         row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
         " go"
       END ;Subroutine report
       , row + 1
       IF ((fs_proc->inhouse_ind=1))
        "dm_schema_actual_start2 0 go", row + 1
       ENDIF
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
       "asis (';')", row + 1, "asis(' finished number:=0; commit_cnt number:=0;')",
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
       "asis('    commit_cnt := commit_cnt+1;')", row + 1, "asis('    if (commit_cnt >=",
       dcd_cursor_commit_cnt, ") then ')", row + 1,
       "asis('      commit;')", row + 1, "asis('      commit_cnt := 0;')",
       row + 1, "asis('    end if;')", row + 1,
       "asis('  end loop;')", row + 1, "asis('  exception when snapshot_too_old then')",
       row + 1, "asis('    finished:=0;')", row + 1,
       "asis('  end;')", row + 1, "asis('end loop;')",
       row + 1, "asis('if (commit_cnt > 0) then')", row + 1,
       "asis('  commit;')", row + 1, "asis('end if;')",
       row + 1, "asis('end;')", row + 1,
       "go", row + 1, txt->errstr = substring(1,110,concat(
         "sql cursor to populate columns that will be made ","not null on table ",tgtdb->tbl[tcnt1].
         tbl_name)),
       CALL dcd_write_log(txt->errstr,0)
       IF ((fs_proc->inhouse_ind=1))
        "dm_schema_actual_stop2 0 go", row + 1
       ENDIF
       row + 2
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
     IF ((fs_proc->inhouse_ind=0))
      SET current_op_id = dm_schema_log->op_id
      EXECUTE dm_schema_estimate_op_log2
     ENDIF
     SELECT INTO value(files->ddl_file)
      d.seq
      FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].tbl_col_cnt))
      PLAN (d
       WHERE (tgtdb->tbl[tcnt1].tbl_col[d.seq].null_to_notnull_ind=1))
      DETAIL
       txt->txt = concat("execute dm_schema_log_info ",trim(cnvtstring(current_op_id)),', "',trim(
         tgtdb->tbl[tcnt1].tbl_name),'", "',
        trim(tgtdb->tbl[tcnt1].tbl_col[d.seq].col_name),'" go'), txt->txt, row + 1
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
    CALL echo("looking for column nullability changes - uptime changes")
    SET user_updt_ind = 0
    FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
     IF ((tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=0)
      AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=1))
      SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
      SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
      IF ((fs_proc->col_novalidate="Y"))
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->operation = "ADD NOT NULL CONSTRAINT NOVALIDATE"
        EXECUTE dm_schema_estimate_op_log2
        SET op_id1 = dm_schema_log->op_id
        SET dm_schema_log->op_id = 0
        SET dm_schema_log->operation = "GET NOT NULL CONSTRAINT NAME"
        EXECUTE dm_schema_estimate_op_log2
        SET op_id2 = dm_schema_log->op_id
        SET dm_schema_log->op_id = 0
        SET dm_schema_log->operation = "ENABLE NOT NULL CONSTRAINT"
        EXECUTE dm_schema_estimate_op_log2
        SET op_id3 = dm_schema_log->op_id
        SET dm_schema_log->op_id = 0
       ENDIF
       SELECT INTO value(files->ddl_file)
        FROM dual
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_create_notnull_cons '", tgtdb->tbl[tcnt1].tbl_name, "', '",
          tgtdb->tbl[tcnt1].tbl_col[tc].col_name, "', 0, 0, 0 go", row + 1
         ELSE
          "dm_create_notnull_cons '", tgtdb->tbl[tcnt1].tbl_name, "', '",
          tgtdb->tbl[tcnt1].tbl_col[tc].col_name, "', ", op_id1,
          ", ", op_id2, ", ",
          op_id3, " go", row + 1
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ELSE
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "ADD NOT NULL CONSTRAINT"
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        FROM dual
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
         row + 1, "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
         " NOT NULL go", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].
           tbl_name," modify ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," not null")),
         CALL dcd_write_log(txt->errstr,0)
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_stop2 0 go", row + 1
         ENDIF
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       SET user_updt_ind = 1
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
      ENDIF
     ENDIF
     IF ((tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=0)
      AND (tgtdb->tbl[tcnt1].tbl_col[tc].diff_nullable_ind=1)
      AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=0))
      SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
      SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "DROP CONSTRAINT"
       SET dm_schema_log->file_name = files->ddl_file
       SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
       SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
       SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
      SELECT INTO value(files->ddl_file)
       FROM dual
       HEAD REPORT
        SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
          row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
          'set ddl_log->cmd_str = "', dwl_cmd, '" go',
          row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
          " go"
        END ;Subroutine report
       DETAIL
        row + 1
        IF ((fs_proc->inhouse_ind=1))
         "dm_schema_actual_start2 0 go", row + 1
        ENDIF
        row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
        row + 1, "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
        " NULL go", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
          " modify ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," null")),
        CALL dcd_write_log(txt->errstr,0)
        IF ((fs_proc->inhouse_ind=1))
         "dm_schema_actual_stop2 0 go", row + 1
        ENDIF
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      SET user_updt_ind = 1
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
     ENDIF
    ENDFOR
    IF (user_updt_ind=1)
     IF ((fs_proc->online_ind=0))
      SELECT INTO value(files->ddl_file)
       FROM dual
       DETAIL
        row + 1, "dm_user_last_updt go"
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
     ENDIF
    ENDIF
    IF ((tgtdb->tbl[tcnt1].diff_ind=1))
     CALL echo("looking for column changes (null to NOT NULL) - downtime changes")
     SET user_updt_ind = 0
     FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
       IF ((tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=1)
        AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=1))
        SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
        SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "ADD NOT NULL CONSTRAINT"
         SET dm_schema_log->file_name = files->ddl_file
         SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
         SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
        SELECT INTO value(files->ddl_file)
         FROM dual
         HEAD REPORT
          SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
            row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
            'set ddl_log->cmd_str = "', dwl_cmd, '" go',
            row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
            " go"
          END ;Subroutine report
         DETAIL
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_start2 0 go", row + 1
          ENDIF
          row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
          row + 1, "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
          " NOT NULL go", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].
            tbl_name," modify ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," not null")),
          CALL dcd_write_log(txt->errstr,0)
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_stop2 0 go", row + 1
          ENDIF
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        SET user_updt_ind = 1
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
       ENDIF
     ENDFOR
     IF (user_updt_ind=1)
      IF ((fs_proc->online_ind=0))
       SELECT INTO value(files->ddl_file)
        FROM dual
        DETAIL
         row + 1, "dm_user_last_updt go"
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
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
        SET files->ddl_file = dcd_get_ddl_filename(tcnt1,curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind
         )
        SET files->err_file = dcd_get_err_filename(tcnt1,curdb->tbl[cdb_idx].cons[ccnt1].downtime_ind
         )
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
             SET dm_schema_log->file_name = files->ddl_file
             SET dm_schema_log->table_name = ih_fk->fk[ifk].tbl_name
             SET dm_schema_log->object_name = ih_fk->fk[ifk].cons_name
             SET dm_schema_log->column_name = ""
             EXECUTE dm_schema_estimate_op_log2
            ENDIF
            SELECT INTO value(files->ddl_file)
             FROM dual
             HEAD REPORT
              SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
                row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
                'set ddl_log->cmd_str = "', dwl_cmd, '" go',
                row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
                " go"
              END ;Subroutine report
             DETAIL
              IF ((fs_proc->inhouse_ind=1))
               "dm_schema_actual_start2 0 go", row + 1
              ENDIF
              row + 1, ";drop related foreign key - inhouse or OCD mode", row + 1,
              "RDB ALTER TABLE ", ih_fk->fk[ifk].tbl_name, row + 1,
              "DROP CONSTRAINT ", ih_fk->fk[ifk].cons_name, " GO",
              row + 1, txt->errstr = substring(1,110,concat("alter table ",ih_fk->fk[ifk].tbl_name,
                " drop constraint ",ih_fk->fk[ifk].cons_name)),
              CALL dcd_write_log(txt->errstr,0)
              IF ((fs_proc->inhouse_ind=1))
               "dm_schema_actual_stop2 0 go", row + 1
              ENDIF
             WITH format = variable, noheading, formfeed = none,
              maxcol = 512, maxrow = 1, append
            ;end select
            IF ((fs_proc->inhouse_ind=0))
             EXECUTE dm_schema_estimate_op_log2
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
        FOR (ifk = 1 TO curdb->tbl[cdb_idx].cons[ccnt1].fk_cnt)
          IF ((fs_proc->inhouse_ind=0))
           SET dm_schema_log->operation = "DROP CONSTRAINT"
           SET dm_schema_log->file_name = files->ddl_file
           SET dm_schema_log->table_name = curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].tbl_name
           SET dm_schema_log->object_name = curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].cons_name
           SET dm_schema_log->column_name = ""
           EXECUTE dm_schema_estimate_op_log2
          ENDIF
          SELECT INTO value(files->ddl_file)
           FROM dual
           HEAD REPORT
            SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
              row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
              'set ddl_log->cmd_str = "', dwl_cmd, '" go',
              row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
              " go"
            END ;Subroutine report
           DETAIL
            IF ((fs_proc->inhouse_ind=1))
             "dm_schema_actual_start2 0 go", row + 1
            ENDIF
            row + 1, "RDB ALTER TABLE ", curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].tbl_name,
            row + 1, "DROP CONSTRAINT ", curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk].cons_name,
            " GO", row + 1, txt->errstr = substring(1,110,concat("alter table ",curdb->tbl[cdb_idx].
              cons[ccnt1].fk[ifk].tbl_name," drop constraint ",curdb->tbl[cdb_idx].cons[ccnt1].fk[ifk
              ].cons_name)),
            CALL dcd_write_log(txt->errstr,0)
            IF ((fs_proc->inhouse_ind=1))
             "dm_schema_actual_stop2 0 go", row + 1
            ENDIF
           WITH format = variable, noheading, formfeed = none,
            maxcol = 512, maxrow = 1, append
          ;end select
          IF ((fs_proc->inhouse_ind=0))
           EXECUTE dm_schema_estimate_op_log2
          ENDIF
        ENDFOR
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP CONSTRAINT"
         SET dm_schema_log->file_name = files->ddl_file
         SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
         SET dm_schema_log->object_name = curdb->tbl[cdb_idx].cons[ccnt1].cons_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
        SELECT INTO value(files->ddl_file)
         FROM dual
         HEAD REPORT
          SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
            row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
            'set ddl_log->cmd_str = "', dwl_cmd, '" go',
            row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
            " go"
          END ;Subroutine report
         DETAIL
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_start2 0 go", row + 1
          ENDIF
          row + 1, "RDB ALTER TABLE ", curdb->tbl[cdb_idx].tbl_name,
          row + 1, "DROP CONSTRAINT ", curdb->tbl[cdb_idx].cons[ccnt1].cons_name,
          row + 1, " GO", txt->errstr = substring(1,110,concat("alter table ",curdb->tbl[cdb_idx].
            tbl_name," drop constraint ",curdb->tbl[cdb_idx].cons[ccnt1].cons_name)),
          CALL dcd_write_log(txt->errstr,0)
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_stop2 0 go", row + 1
          ENDIF
          IF ((fs_proc->online_ind=0))
           row + 1, " dm_user_last_updt go"
          ENDIF
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
       ENDIF
     ENDFOR
     FOR (icnt1 = 1 TO curdb->tbl[cdb_idx].ind_cnt)
       IF ((curdb->tbl[cdb_idx].ind[icnt1].rename_ind=1))
        SET files->ddl_file = dcd_get_ddl_filename(tcnt1,curdb->tbl[cdb_idx].ind[icnt1].downtime_ind)
        SET files->err_file = dcd_get_err_filename(tcnt1,curdb->tbl[cdb_idx].ind[icnt1].downtime_ind)
        CALL echo("rename indexes: orig to temp")
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "RENAME INDEX"
         SET dm_schema_log->file_name = files->ddl_file
         SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
         SET dm_schema_log->object_name = curdb->tbl[cdb_idx].ind[icnt1].ind_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
        SELECT INTO value(files->ddl_file)
         d.seq
         FROM (dummyt d  WITH seq = 1)
         PLAN (d)
         HEAD REPORT
          SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
            row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
            'set ddl_log->cmd_str = "', dwl_cmd, '" go',
            row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
            " go"
          END ;Subroutine report
         DETAIL
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_start2 0 go", row + 1
          ENDIF
          row + 1, "RDB ALTER INDEX ", curdb->tbl[cdb_idx].ind[icnt1].ind_name,
          row + 1, "  rename to ", curdb->tbl[cdb_idx].ind[icnt1].temp_name,
          " GO", row + 1, txt->errstr = substring(1,110,concat("rename index ",curdb->tbl[cdb_idx].
            ind[icnt1].ind_name)),
          CALL dcd_write_log(txt->errstr,0)
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_stop2 0 go", row + 1
          ENDIF
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log2
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
       IF ((curdb->tbl[cdb_idx].ind[icnt1].drop_ind=1)
        AND (curdb->tbl[cdb_idx].ind[icnt1].rename_ind=0))
        SET files->ddl_file = dcd_get_ddl_filename(tcnt1,curdb->tbl[cdb_idx].ind[icnt1].downtime_ind)
        SET files->err_file = dcd_get_err_filename(tcnt1,curdb->tbl[cdb_idx].ind[icnt1].downtime_ind)
        CALL echo("drop indexes")
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP INDEX"
         SET dm_schema_log->file_name = files->ddl_file
         SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
         SET dm_schema_log->object_name = curdb->tbl[cdb_idx].ind[icnt1].ind_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
        SELECT INTO value(files->ddl_file)
         d.seq
         FROM (dummyt d  WITH seq = 1)
         PLAN (d)
         HEAD REPORT
          SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
            row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
            'set ddl_log->cmd_str = "', dwl_cmd, '" go',
            row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
            " go"
          END ;Subroutine report
         DETAIL
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_start2 0 go", row + 1
          ENDIF
          row + 1, "RDB DROP INDEX ", curdb->tbl[cdb_idx].ind[icnt1].ind_name,
          " GO", txt->errstr = substring(1,110,concat("drop index ",curdb->tbl[cdb_idx].ind[icnt1].
            ind_name)),
          CALL dcd_write_log(txt->errstr,0)
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_stop2 0 go", row + 1
          ENDIF
          tsp_found = 0
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
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
       ENDIF
     ENDFOR
     FOR (tsp = 1 TO ind_tspace->cnt)
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "COALESCE TABLESPACE"
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
        SET dm_schema_log->object_name = ind_tspace->t[tsp].tspace_name
        SET dm_schema_log->column_name = ""
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        FROM dual
        DETAIL
         row + 1, "RDB ALTER TABLESPACE ", ind_tspace->t[tsp].tspace_name,
         row + 1, "COALESCE GO"
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
     ENDFOR
     CALL echo("looking for column changes (NOT NULL to null) - downtime changes")
     SET user_updt_ind = 0
     FOR (tc = 1 TO tgtdb->tbl[tcnt1].tbl_col_cnt)
       IF ((tgtdb->tbl[tcnt1].tbl_col[tc].diff_nullable_ind=1)
        AND (tgtdb->tbl[tcnt1].tbl_col[tc].null_to_notnull_ind=0)
        AND (tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind=1))
        SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
        SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].tbl_col[tc].downtime_ind)
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP CONSTRAINT"
         SET dm_schema_log->file_name = files->ddl_file
         SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
         SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         SET dm_schema_log->column_name = tgtdb->tbl[tcnt1].tbl_col[tc].col_name
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
        SELECT INTO value(files->ddl_file)
         FROM dual
         HEAD REPORT
          SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
            row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
            'set ddl_log->cmd_str = "', dwl_cmd, '" go',
            row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
            " go"
          END ;Subroutine report
         DETAIL
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_start2 0 go", row + 1
          ENDIF
          row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name,
          row + 1, "MODIFY ", tgtdb->tbl[tcnt1].tbl_col[tc].col_name,
          " NULL go", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
            " modify ",tgtdb->tbl[tcnt1].tbl_col[tc].col_name," null")),
          CALL dcd_write_log(txt->errstr,0)
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_stop2 0 go", row + 1
          ENDIF
          row + 1
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        SET user_updt_ind = 1
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
       ENDIF
     ENDFOR
     IF (user_updt_ind=1)
      IF ((fs_proc->online_ind=0))
       SELECT INTO value(files->ddl_file)
        FROM dual
        DETAIL
         row + 1, "dm_user_last_updt go"
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
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
      SET files->ddl_file = dcd_get_ddl_filename(tcnt1,ind_tspace->downtime_ind)
      SET files->err_file = dcd_get_err_filename(tcnt1,ind_tspace->downtime_ind)
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "COALESCE TABLESPACE"
       SET dm_schema_log->file_name = files->ddl_file
       SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
       SET dm_schema_log->object_name = ind_tspace->t[tsp].tspace_name
       SET dm_schema_log->column_name = ""
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
      SELECT INTO value(files->ddl_file)
       FROM dual
       DETAIL
        row + 1, "RDB ALTER TABLESPACE ", ind_tspace->t[tsp].tspace_name,
        row + 1, "COALESCE GO"
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
    ENDFOR
    FOR (icnt1 = 1 TO tgtdb->tbl[tcnt1].ind_cnt)
      IF ((tgtdb->tbl[tcnt1].ind[icnt1].build_ind=1))
       CALL echo("build indexes")
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind)
       SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind)
       IF ((fs_proc->inhouse_ind=0))
        IF ((tgtdb->tbl[tcnt1].ind[icnt1].unique_ind=1))
         IF ((fs_proc->index_online="Y"))
          SET dm_schema_log->operation = "CREATE UNIQUE INDEX ONLINE"
         ELSE
          SET dm_schema_log->operation = "CREATE UNIQUE INDEX"
         ENDIF
        ELSEIF ((fs_proc->index_online="Y"))
         SET dm_schema_log->operation = "CREATE INDEX ONLINE"
        ELSE
         SET dm_schema_log->operation = "CREATE INDEX"
        ENDIF
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].ind[icnt1].ind_name
        SET dm_schema_log->column_name = ""
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        d.seq
        FROM (dummyt d  WITH seq = value(tgtdb->tbl[tcnt1].ind[icnt1].ind_col_cnt))
        PLAN (d)
        ORDER BY tgtdb->tbl[tcnt1].ind[icnt1].ind_col[d.seq].col_position
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         row + 1, "RDB CREATE"
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
          init_extent = ceil((tgtdb->tbl[tcnt1].ind[icnt1].init_ext/ 1024.0)), next_extent = ceil((
           tgtdb->tbl[tcnt1].ind[icnt1].next_ext/ 1024.0))
          IF ((fs_proc->freelist_groups > 0))
           row + 1, "STORAGE (INITIAL ", init_extent";;I",
           "K NEXT ", next_extent";;I", "K",
           row + 1, "FREELIST GROUPS ", fs_proc->freelist_groups";L;I",
           ")"
          ELSE
           row + 1, "STORAGE ( INITIAL ", init_extent";;I",
           "K NEXT ", next_extent";;I", "K )"
          ENDIF
         ENDIF
         IF ((fs_proc->ora_version=7))
          IF ((fs_proc->ind_unrecover="Y"))
           row + 1, "UNRECOVERABLE "
          ENDIF
         ELSEIF ((fs_proc->ora_version=8))
          IF ((fs_proc->ind_unrecover="Y"))
           row + 1, "NOLOGGING"
          ENDIF
         ENDIF
         IF ((fs_proc->index_online="Y"))
          row + 1, "ONLINE"
         ENDIF
         row + 1, "TABLESPACE ", tgtdb->tbl[tcnt1].ind[icnt1].tspace_name,
         row + 1, "go", txt->errstr = substring(1,110,concat("create index ",tgtdb->tbl[tcnt1].ind[
           icnt1].ind_name)),
         CALL dcd_write_log(txt->errstr,0)
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_stop2 0 go", row + 1
         ENDIF
         IF ((fs_proc->online_ind=0))
          row + 1, " dm_user_last_updt go"
         ENDIF
         row + 2
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
      ENDIF
    ENDFOR
    FOR (icnt1 = 1 TO tgtdb->tbl[tcnt1].ind_cnt)
      IF ((tgtdb->tbl[tcnt1].ind[icnt1].rename_ind=1))
       CALL echo("rename indexes: temp to orig")
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind)
       SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].ind[icnt1].downtime_ind)
       IF ((fs_proc->inhouse_ind=0))
        SET dm_schema_log->operation = "RENAME INDEX"
        SET dm_schema_log->file_name = files->ddl_file
        SET dm_schema_log->table_name = tgtdb->tbl[tcnt1].tbl_name
        SET dm_schema_log->object_name = tgtdb->tbl[tcnt1].ind[icnt1].ind_name
        SET dm_schema_log->column_name = ""
        EXECUTE dm_schema_estimate_op_log2
       ENDIF
       SELECT INTO value(files->ddl_file)
        d.seq
        FROM (dummyt d  WITH seq = 1)
        PLAN (d)
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         row + 1, "RDB ALTER INDEX ", tgtdb->tbl[tcnt1].ind[icnt1].temp_name,
         row + 1, "  rename to ", tgtdb->tbl[tcnt1].ind[icnt1].ind_name,
         " GO", row + 1, txt->errstr = substring(1,110,concat("rename index ",tgtdb->tbl[tcnt1].ind[
           icnt1].ind_name)),
         CALL dcd_write_log(txt->errstr,0)
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_stop2 0 go", row + 1
         ENDIF
         IF ((fs_proc->online_ind=0))
          row + 1, " dm_user_last_updt go"
         ENDIF
         row + 2
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       IF ((fs_proc->inhouse_ind=0))
        EXECUTE dm_schema_estimate_op_log2
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
    IF (cdb_idx > 0)
     FOR (icnt1 = 1 TO curdb->tbl[cdb_idx].ind_cnt)
       IF ((curdb->tbl[cdb_idx].ind[icnt1].drop_ind=1)
        AND (curdb->tbl[cdb_idx].ind[icnt1].rename_ind=1))
        SET files->ddl_file = dcd_get_ddl_filename(tcnt1,curdb->tbl[cdb_idx].ind[icnt1].downtime_ind)
        SET files->err_file = dcd_get_err_filename(tcnt1,curdb->tbl[cdb_idx].ind[icnt1].downtime_ind)
        CALL echo("drop renamed indexes")
        IF ((fs_proc->inhouse_ind=0))
         SET dm_schema_log->operation = "DROP INDEX"
         SET dm_schema_log->file_name = files->ddl_file
         SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
         SET dm_schema_log->object_name = curdb->tbl[cdb_idx].ind[icnt1].ind_name
         SET dm_schema_log->column_name = ""
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
        SELECT INTO value(files->ddl_file)
         d.seq
         FROM (dummyt d  WITH seq = 1)
         PLAN (d)
         HEAD REPORT
          SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
            row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
            'set ddl_log->cmd_str = "', dwl_cmd, '" go',
            row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
            " go"
          END ;Subroutine report
         DETAIL
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_start2 0 go", row + 1
          ENDIF
          row + 1, "RDB DROP INDEX ", curdb->tbl[cdb_idx].ind[icnt1].temp_name,
          " GO", txt->errstr = substring(1,110,concat("drop index ",curdb->tbl[cdb_idx].ind[icnt1].
            temp_name)),
          CALL dcd_write_log(txt->errstr,0)
          IF ((fs_proc->inhouse_ind=1))
           "dm_schema_actual_stop2 0 go", row + 1
          ENDIF
          tsp_found = 0
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
         WITH format = variable, noheading, formfeed = none,
          maxcol = 512, maxrow = 1, append
        ;end select
        IF ((fs_proc->inhouse_ind=0))
         EXECUTE dm_schema_estimate_op_log2
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    FOR (tsp = 1 TO ind_tspace->cnt)
      IF ((fs_proc->inhouse_ind=0))
       SET dm_schema_log->operation = "COALESCE TABLESPACE"
       SET dm_schema_log->file_name = files->ddl_file
       SET dm_schema_log->table_name = curdb->tbl[cdb_idx].tbl_name
       SET dm_schema_log->object_name = ind_tspace->t[tsp].tspace_name
       SET dm_schema_log->column_name = ""
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
      SELECT INTO value(files->ddl_file)
       FROM dual
       DETAIL
        row + 1, "RDB ALTER TABLESPACE ", ind_tspace->t[tsp].tspace_name,
        row + 1, "COALESCE GO"
       WITH format = variable, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
      IF ((fs_proc->inhouse_ind=0))
       EXECUTE dm_schema_estimate_op_log2
      ENDIF
    ENDFOR
    FOR (ccnt1 = 1 TO tgtdb->tbl[tcnt1].cons_cnt)
      IF ((tgtdb->tbl[tcnt1].cons[ccnt1].build_ind=1))
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind)
       SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind)
       CALL echo("build constraints")
       CALL create_cons(tcnt1,ccnt1,fidx)
       IF ((tgtdb->tbl[tcnt1].cons[ccnt1].cons_type="P"))
        IF ((tgtdb->tbl[tcnt1].cons[ccnt1].fk_cnt > 0))
         FOR (fkcnt1 = 1 TO tgtdb->tbl[tcnt1].cons[ccnt1].fk_cnt)
          CALL echo("build related fk constraints")
          CALL create_cons(tgtdb->tbl[tcnt1].cons[ccnt1].fk[fkcnt1].tbl_ndx,tgtdb->tbl[tcnt1].cons[
           ccnt1].fk[fkcnt1].cons_ndx,fidx)
         ENDFOR
        ENDIF
        IF ((((fs_proc->inhouse_ind=1)) OR ((fs_proc->ocd_ind=1)))
         AND (ih_fk->fk_cnt > 0))
         FOR (ih_cnt = 1 TO ih_fk->fk_cnt)
           IF ((ih_fk->fk[ih_cnt].build_ind=1))
            IF ((fs_proc->inhouse_ind=0))
             SET dm_schema_log->operation = "ADD FOREIGN KEY CONSTRAINT"
             SET dm_schema_log->file_name = files->ddl_file
             SET dm_schema_log->table_name = ih_fk->fk[ih_cnt].tbl_name
             SET dm_schema_log->object_name = ih_fk->fk[ih_cnt].cons_name
             SET dm_schema_log->column_name = ""
             EXECUTE dm_schema_estimate_op_log2
            ENDIF
            SELECT INTO value(files->ddl_file)
             d.seq
             FROM (dummyt d  WITH seq = value(ih_fk->fk[ih_cnt].col_cnt))
             PLAN (d)
             HEAD REPORT
              SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
                row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
                'set ddl_log->cmd_str = "', dwl_cmd, '" go',
                row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
                " go"
              END ;Subroutine report
              IF ((fs_proc->inhouse_ind=1))
               "dm_schema_actual_start2 0 go", row + 1
              ENDIF
              row + 1, "RDB ALTER TABLE ", ih_fk->fk[ih_cnt].tbl_name,
              row + 1, "ADD CONSTRAINT ", ih_fk->fk[ih_cnt].cons_name,
              row + 1, "FOREIGN KEY"
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
                " add constraint ",ih_fk->fk[ih_cnt].cons_name)),
              CALL dcd_write_log(txt->errstr,0)
              IF ((fs_proc->inhouse_ind=1))
               "dm_schema_actual_stop2 0 go", row + 1
              ENDIF
             WITH format = variable, noheading, formfeed = none,
              maxcol = 512, maxrow = 1, append
            ;end select
            IF ((fs_proc->inhouse_ind=0))
             EXECUTE dm_schema_estimate_op_log2
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ELSEIF ((tgtdb->tbl[tcnt1].cons[ccnt1].diff_status_ind=1))
       SET files->ddl_file = dcd_get_ddl_filename(tcnt1,tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind)
       SET files->err_file = dcd_get_err_filename(tcnt1,tgtdb->tbl[tcnt1].cons[ccnt1].downtime_ind)
       CALL echo("change constraint status")
       SELECT INTO value(files->ddl_file)
        FROM dual
        HEAD REPORT
         SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
           row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
           'set ddl_log->cmd_str = "', dwl_cmd, '" go',
           row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
           " go"
         END ;Subroutine report
        DETAIL
         IF ((fs_proc->inhouse_ind=1))
          "dm_schema_actual_start2 0 go", row + 1
         ENDIF
         row + 1, "dm_schema_actual_start2 0 go", row + 1,
         row + 1, "RDB ALTER TABLE ", tgtdb->tbl[tcnt1].tbl_name
         IF ((tgtdb->tbl[tcnt1].cons[ccnt1].status_ind=1))
          " ENABLE ", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
            " enable ",tgtdb->tbl[tcnt1].cons[ccnt1].cons_name))
         ELSE
          " DISABLE ", txt->errstr = substring(1,110,concat("alter table ",tgtdb->tbl[tcnt1].tbl_name,
            " disable ",tgtdb->tbl[tcnt1].cons[ccnt1].cons_name))
         ENDIF
         row + 1, "CONSTRAINT ", tgtdb->tbl[tcnt1].cons[ccnt1].cons_name,
         " go",
         CALL dcd_write_log(txt->errstr,0), row + 1,
         "dm_schema_actual_stop2 0 go", row + 1
         IF ((fs_proc->online_ind=0))
          row + 1, " dm_user_last_updt go"
         ENDIF
         row + 2
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
    ENDFOR
   ENDIF
   CALL dis_write_compile_table_objects(tcnt1)
 ENDFOR
 IF (dmsteps_idx > 0)
  CALL echo("writing global DM steps")
  SELECT INTO value(rfiles->qual[dmsteps_idx].file2d)
   FROM (dummyt t  WITH seq = value(tgtdb->tbl_cnt))
   PLAN (t
    WHERE t.seq > 0)
   HEAD REPORT
    SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
      row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
      'set ddl_log->cmd_str = "', dwl_cmd, '" go',
      row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
      " go"
    END ;Subroutine report
    , ";Now compile all invalid objects", row + 1,
    "execute dm_compile_all_objects go", row + 1, row + 1
   DETAIL
    IF ((tgtdb->tbl[t.seq].zero_row_ind=1))
     txt->txt = build('"',tgtdb->tbl[t.seq].tbl_name,'"'), "dm_schema_actual_start2 0 go", row + 1,
     row + 1, ";Execute Add Zero Row step", row + 1,
     "execute dm2_add_default_rows ", txt->txt, " go",
     row + 1, row + 1, txt->errstr = substring(1,110,concat("add zero row to table ",trim(tgtdb->tbl[
        t.seq].tbl_name))),
     CALL dcd_write_log(txt->errstr,0), row + 1, "dm_schema_actual_stop2 0 go",
     row + 1, row + 1
    ENDIF
    IF ((tgtdb->tbl[t.seq].active_trigger_ind=1))
     txt->txt = build('"',tgtdb->tbl[t.seq].tbl_name,'"'), "dm_schema_actual_start2 0 go", row + 1,
     row + 1, ";Execute Active_ind Trigger step", row + 1,
     "execute dm_create_active_trigger ", txt->txt, " go",
     row + 1, row + 1, txt->errstr = substring(1,110,concat("create active_ind trigger on table ",
       trim(tgtdb->tbl[t.seq].tbl_name))),
     CALL dcd_write_log(txt->errstr,0), row + 1, "dm_schema_actual_stop2 0 go",
     row + 1, row + 1
    ENDIF
    IF ((tgtdb->tbl[t.seq].synonym_ind=1))
     txt->txt = build('"',tgtdb->tbl[t.seq].tbl_name,'"'), "dm_schema_actual_start2 0 go", row + 1,
     row + 1, ";Execute Public Synonym step", row + 1,
     "execute dm_create_object_synonym ", txt->txt, ', "TABLE" go',
     row + 1, row + 1, txt->errstr = substring(1,110,concat("create public synonym for table ",trim(
        tgtdb->tbl[t.seq].tbl_name))),
     CALL dcd_write_log(txt->errstr,0), row + 1, "dm_schema_actual_stop2 0 go",
     row + 1, row + 1
    ENDIF
   WITH format = variable, formfeed = none, noheading,
    maxrow = 1, maxcol = 512, append
  ;end select
  SELECT INTO value(rfiles->qual[dmsteps_idx].file2d)
   FROM (dummyt t  WITH seq = value(curdb->tbl_cnt)),
    (dummyt ti  WITH seq = 50)
   PLAN (t
    WHERE t.seq > 0)
    JOIN (ti
    WHERE (ti.seq <= curdb->tbl[t.seq].ind_cnt))
   HEAD REPORT
    SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
      row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
      'set ddl_log->cmd_str = "', dwl_cmd, '" go',
      row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
      " go"
    END ;Subroutine report
    , ";Drop temp indexes from current schema.", row + 1
   DETAIL
    IF ((curdb->tbl[t.seq].ind[ti.seq].ind_name="TMP*"))
     "dm_schema_actual_start2 0 go", row + 1, row + 1,
     "RDB DROP INDEX ", curdb->tbl[t.seq].ind[ti.seq].ind_name, " GO",
     txt->errstr = substring(1,110,concat("drop index ",curdb->tbl[t.seq].ind[ti.seq].ind_name)),
     CALL dcd_write_log(txt->errstr,0), row + 1,
     "dm_schema_actual_stop2 0 go", row + 1, row + 1
    ENDIF
    IF ((curdb->tbl[t.seq].ind[ti.seq].temp_name="TMP*"))
     "dm_schema_actual_start2 0 go", row + 1, row + 1,
     "RDB DROP INDEX ", curdb->tbl[t.seq].ind[ti.seq].temp_name, " GO",
     txt->errstr = substring(1,110,concat("drop index ",curdb->tbl[t.seq].ind[ti.seq].temp_name)),
     CALL dcd_write_log(txt->errstr,0), row + 1,
     "dm_schema_actual_stop2 0 go", row + 1, row + 1
    ENDIF
   WITH format = variable, formfeed = none, noheading,
    maxrow = 1, maxcol = 512, append
  ;end select
 ENDIF
 FOR (cnt2 = 1 TO rfiles->fcnt)
  CALL dcd_term_up_file(cnt2)
  CALL dcd_term_dn_file(cnt2)
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
 SUBROUTINE dis_write_compile_table_objects(cto_tbl_idx)
  SET cto_file_idx = tgtdb->tbl[cto_tbl_idx].file_idx
  IF ((rfiles->qual[cto_file_idx].ddl_up_ind=1))
   SELECT INTO value(rfiles->qual[cto_file_idx].file2)
    FROM dual
    DETAIL
     ";Now compile invalid objects", row + 1, "execute dm_compile_objects '",
     tgtdb->tbl[cto_tbl_idx].tbl_name, "', 'TABLE' go", row + 1,
     row + 1
    WITH nocounter, format = variable, formfeed = none,
     noheading, maxrow = 1, maxcol = 512,
     append
   ;end select
   SET rfiles->qual[cto_file_idx].ddl_up_ind = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE dcd_init_up_file(iuf_file_idx)
   IF ((rfiles->qual[iuf_file_idx].init_up_ind=0))
    SELECT INTO value(rfiles->qual[iuf_file_idx].file2)
     *
     FROM dual
     DETAIL
      IF ((fs_proc->ocd_ind=0)
       AND (fs_proc->inhouse_ind=0)
       AND (fs_proc->online_ind=0))
       "%o  ", rfiles->qual[iuf_file_idx].file4, row + 1
      ENDIF
      "; This file is generated by the install schema process for uptime changes", row + 1,
      "; Started at ",
      curdate"DD-MMM-YYYY;;D", " ", curtime"HH:MM:SS;;M",
      row + 1, row + 1, "free record ddl_log go",
      row + 1, "record ddl_log (", row + 1,
      "  1 ddl_file = vc", row + 1, "  1 err_file = vc",
      row + 1, "  1 cmd_str = vc", row + 1,
      "  1 err_str = c132", row + 1, "  1 err_code = i4",
      row + 1, "  1 ignore_ind = i2", row + 1,
      "  1 env_id = f8", row + 1, "  1 ocd = i4",
      row + 1, "  1 cons_name = vc", row + 1,
      ") go", row + 1, "set ddl_log->ddl_file = '",
      rfiles->qual[iuf_file_idx].file2, "' go", row + 1,
      "set ddl_log->err_file = '", rfiles->qual[iuf_file_idx].file3, "' go",
      row + 1, "set ddl_log->cmd_str = '' go", row + 1,
      "set ddl_log->err_str = '' go", row + 1, "set ddl_log->err_code = 0 go",
      row + 1, "set ddl_log->ignore_ind = 0 go", row + 1,
      ";Store the environment id and OCD number", row + 1, "set ddl_log->env_id = ",
      fs_proc->env[1].id, " go", row + 1,
      "set ddl_log->ocd = ", fs_proc->ocd_number, " go",
      row + 1
      IF ((fs_proc->install_mode IN ("UPTIME", "DOWNTIME")))
       "execute dm_schema_file_start go", row + 1
      ENDIF
      row + 1, row + 1, "select into value(ddl_log->err_file) * from dual",
      row + 1, "detail", row + 1,
      "  '; Install schema uptime Error Logging file generated after running',row+1", row + 1,
      "  '; ddl commands in the ",
      rfiles->qual[iuf_file_idx].file2, "', row+1", row + 1,
      "  '; file.', row+1", row + 1,
      "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
      ", row+1, row+1", row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1 go",
      row + 1
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
    IF ((fs_proc->ocd_ind=0)
     AND (fs_proc->inhouse_ind=0)
     AND (fs_proc->online_ind=0))
     SELECT INTO value(rfiles->qual[iuf_file_idx].file1com)
      *
      FROM dual
      DETAIL
       IF ((fs_proc->env[1].oper_sys="VMS"))
        row + 1, "$! This file is generated by the install schema process", row + 1,
        "$! It can be submitted as a job ", row + 1, "$! Generated on ",
        curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
        row + 1, "$!", row + 1,
        "$set verify", row + 1, '$define sys$output "ccluserdir:',
        rfiles->qual[iuf_file_idx].file1log, '"', row + 1,
        '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1, "$CCL"
       ELSE
        col 0, "#!/usr/bin/ksh", row + 1,
        ". $cer_mgr/.user_setup ", fs_proc->env[1].envset_str, row + 1,
        "# This file is generated by the install schema process", row + 1,
        "# It can be submitted as a job ",
        row + 1, "# Generated on ", curdate"DD-MMM-YYYY ;;D",
        " ", curtime"HH:MM:SS;;M", row + 1,
        "ccl <<!"
       ENDIF
       row + 1, "%i ccluserdir:", rfiles->qual[iuf_file_idx].file2,
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
    SET rfiles->qual[iuf_file_idx].init_up_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE dcd_init_dn_file(idf_file_idx)
   IF ((rfiles->qual[idf_file_idx].init_dn_ind=0))
    SELECT INTO value(rfiles->qual[idf_file_idx].file2d)
     *
     FROM dual
     DETAIL
      IF ((fs_proc->ocd_ind=0)
       AND (fs_proc->inhouse_ind=0)
       AND (fs_proc->online_ind=0))
       "%o  ", rfiles->qual[idf_file_idx].file4d, row + 2
      ENDIF
      "; This file is generated by the install schema process for downtime changes", row + 1,
      "; Started at ",
      curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
      row + 1, row + 1, "free record ddl_log go",
      row + 1, "record ddl_log (", row + 1,
      "  1 ddl_file = vc", row + 1, "  1 err_file = vc",
      row + 1, "  1 cmd_str = vc", row + 1,
      "  1 err_str = c132", row + 1, "  1 err_code = i4",
      row + 1, "  1 ignore_ind = i2", row + 1,
      "  1 env_id = f8", row + 1, "  1 ocd = i4",
      row + 1, ") go", row + 1,
      "set ddl_log->ddl_file = '", rfiles->qual[idf_file_idx].file2d, "' go",
      row + 1, "set ddl_log->err_file = '", rfiles->qual[idf_file_idx].file3d,
      "' go", row + 1, "set ddl_log->cmd_str = '' go",
      row + 1, "set ddl_log->err_str = '' go", row + 1,
      "set ddl_log->err_code = 0 go", row + 1, "set ddl_log->ignore_ind = 0 go",
      row + 1, ";Store the environment id and OCD number", row + 1,
      "set ddl_log->env_id = ", fs_proc->env[1].id, " go",
      row + 1, "set ddl_log->ocd = ", fs_proc->ocd_number,
      " go", row + 1
      IF ((fs_proc->install_mode IN ("UPTIME", "DOWNTIME")))
       "execute dm_schema_file_start go", row + 1
      ENDIF
      row + 1, row + 1, "select into value(ddl_log->err_file) * from dual",
      row + 1, "detail", row + 1,
      "  '; Install schema downtime Error Logging file generated after running'", ", row+1", row + 1,
      "  '; ddl schema commands in the ", rfiles->qual[idf_file_idx].file2d, " file', row+1",
      row + 1, "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
      ", row+1, row+1",
      row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1 go", row + 2
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
    IF ((fs_proc->ocd_ind=0)
     AND (fs_proc->inhouse_ind=0)
     AND (fs_proc->online_ind=0))
     SELECT INTO value(rfiles->qual[idf_file_idx].file1dcom)
      *
      FROM dual
      DETAIL
       IF ((fs_proc->env[1].oper_sys="VMS"))
        row + 1, "$! This file is generated by the install schema process", row + 1,
        "$! It can be submitted as a job ", row + 1, "$! Generated on ",
        curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
        row + 1, "$!", row + 1,
        "$set verify", row + 1, '$define sys$output "ccluserdir:',
        rfiles->qual[idf_file_idx].file1dlog, '"', row + 1,
        '$CCL :== "$CER_EXE:CCLORA.EXE"', row + 1, "$CCL"
       ELSE
        col 0, "#!/usr/bin/ksh", row + 1,
        ". $cer_mgr/.user_setup ", fs_proc->env[1].envset_str, row + 1,
        "# This file is generated by the install schema process", row + 1,
        "# It can be submitted as a job ",
        row + 1, "# Generated on ", curdate"DD-MMM-YYYY ;;D",
        " ", curtime"HH:MM:SS;;M", row + 1,
        "ccl <<!"
       ENDIF
       row + 1, "%i ccluserdir:", rfiles->qual[idf_file_idx].file2d,
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
    SET rfiles->qual[idf_file_idx].init_dn_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE dcd_term_up_file(tuf_file_idx)
   IF ((rfiles->qual[tuf_file_idx].init_up_ind=1))
    SELECT INTO value(rfiles->qual[tuf_file_idx].file2)
     *
     FROM dual
     DETAIL
      IF ((fs_proc->online_ind=0))
       "execute dm_user_last_updt go", row + 1
      ENDIF
      "select into value(ddl_log->err_file) * from dual", row + 1, "detail",
      row + 1, "  '; End of Uptime Error Logging file generated after running',row+1", row + 1,
      "  '; ddl schema output file ", rfiles->qual[tuf_file_idx].file2, "', row+1",
      row + 1, "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", row + 1,
      "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1
      IF ((fs_proc->install_mode IN ("UPTIME", "DOWNTIME")))
       "execute dm_schema_file_stop go", row + 1
      ENDIF
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
   ENDIF
 END ;Subroutine
 SUBROUTINE dcd_term_dn_file(tdf_file_idx)
   IF ((fs_proc->inhouse_ind=0)
    AND (fs_proc->online_ind=0))
    IF ((rfiles->qual[tdf_file_idx].init_dn_ind=1))
     SELECT INTO value(rfiles->qual[tdf_file_idx].file2d)
      *
      FROM dual
      DETAIL
       IF ((fs_proc->online_ind=0))
        "execute dm_user_last_updt go", row + 1
       ENDIF
       "select into value(ddl_log->err_file) * from dual", row + 1, "detail",
       row + 1, "  '; End of Downtime Error Logging file generated after running',row+1", row + 1,
       "  '; ddl schema output file ", rfiles->qual[tdf_file_idx].file2d, "', row+1",
       row + 1, "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", row + 1,
       "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1
       IF ((fs_proc->install_mode IN ("UPTIME", "DOWNTIME")))
        "execute dm_schema_file_stop go", row + 1
       ENDIF
       IF ((fs_proc->ocd_ind=0))
        row + 1, row + 1, row + 1,
        "; End of file", row + 1, "; Ended at ",
        curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
        row + 1, "%o"
       ENDIF
      WITH format = variable, noheading, formfeed = none,
       maxcol = 512, maxrow = 1, append
     ;end select
    ENDIF
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
     row + 1, "free record ddl_log go", row + 1,
     "record ddl_log (", row + 1, "  1 ddl_file = vc",
     row + 1, "  1 err_file = vc", row + 1,
     "  1 cmd_str = vc", row + 1, "  1 err_str = c132",
     row + 1, "  1 err_code = i4", row + 1,
     "  1 ignore_ind = i2", row + 1, "  1 env_id = f8",
     row + 1, "  1 ocd = i4", row + 1,
     ") go", row + 1, "set ddl_log->ddl_file = '",
     rfiles->qual[idx1].file2, "' go", row + 1,
     "set ddl_log->err_file = '", rfiles->qual[idx1].file3, "' go",
     row + 1, "set ddl_log->cmd_str = '' go", row + 1,
     "set ddl_log->err_str = '' go", row + 1, "set ddl_log->err_code = 0 go",
     row + 1, "set ddl_log->ignore_ind = 0 go", row + 1,
     ";Store the environment id and OCD number", row + 1, "set ddl_log->env_id = ",
     fs_proc->env[1].id, " go", row + 1,
     "set ddl_log->ocd = ", fs_proc->ocd_number, " go",
     row + 1, "execute dm_schema_file_start go", row + 1,
     row + 1, row + 1, "select into value(ddl_log->err_file) * from dual",
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
   IF ((fs_proc->inhouse_ind=0)
    AND (fs_proc->online_ind=0))
    SELECT INTO value(rfiles->qual[idx1].file2d)
     *
     FROM dual
     DETAIL
      IF ((fs_proc->ocd_ind=0))
       "%o  ", rfiles->qual[idx1].file4d, row + 2
      ENDIF
      "; This file is generated by the fix schema process for downtime changes", row + 1,
      "; Started at ",
      curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
      row + 1, row + 1, "free record ddl_log go",
      row + 1, "record ddl_log (", row + 1,
      "  1 ddl_file = vc", row + 1, "  1 err_file = vc",
      row + 1, "  1 cmd_str = vc", row + 1,
      "  1 err_str = c132", row + 1, "  1 err_code = i4",
      row + 1, "  1 ignore_ind = i2", row + 1,
      "  1 env_id = f8", row + 1, "  1 ocd = i4",
      row + 1, ") go", row + 1,
      "set ddl_log->ddl_file = '", rfiles->qual[idx1].file2d, "' go",
      row + 1, "set ddl_log->err_file = '", rfiles->qual[idx1].file3d,
      "' go", row + 1, "set ddl_log->cmd_str = '' go",
      row + 1, "set ddl_log->err_str = '' go", row + 1,
      "set ddl_log->err_code = 0 go", row + 1, "set ddl_log->ignore_ind = 0 go",
      row + 1, ";Store the environment id and OCD number", row + 1,
      "set ddl_log->env_id = ", fs_proc->env[1].id, " go",
      row + 1, "set ddl_log->ocd = ", fs_proc->ocd_number,
      " go", row + 1
      IF ((fs_proc->install_mode IN ("UPTIME", "DOWNTIME")))
       "execute dm_schema_file_start go", row + 1
      ENDIF
      row + 1, row + 1, "select into value(ddl_log->err_file) * from dual",
      row + 1, "detail", row + 1,
      "  '; Fix schema downtime Error Logging file generated after running'", ", row+1", row + 1,
      "  '; fix schema commands in the ", rfiles->qual[idx1].file2d, " file', row+1",
      row + 1, "  '; Started at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'",
      ", row+1, row+1",
      row + 1, "with format=variable, formfeed=none, maxcol=512, maxrow=1 go", row + 2
     WITH format = variable, noheading, formfeed = none,
      maxcol = 512, maxrow = 1
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE term_files(idx1)
  SELECT INTO value(rfiles->qual[idx1].file2)
   *
   FROM dual
   DETAIL
    IF ((fs_proc->online_ind=0))
     "execute dm_user_last_updt go", row + 1
    ENDIF
    "select into value(ddl_log->err_file) * from dual", row + 1, "detail",
    row + 1, "  '; End of Uptime Error Logging file generated after running',row+1", row + 1,
    "  '; fix schema output file ", rfiles->qual[idx1].file2, "', row+1",
    row + 1, "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", row + 1,
    "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1, "%d noecho",
    row + 1, "execute dm_schema_file_stop go", row + 1
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
  IF ((fs_proc->inhouse_ind=0)
   AND (fs_proc->online_ind=0))
   SELECT INTO value(rfiles->qual[idx1].file2d)
    *
    FROM dual
    DETAIL
     IF ((fs_proc->online_ind=0))
      "execute dm_user_last_updt go", row + 1
     ENDIF
     "select into value(ddl_log->err_file) * from dual", row + 1, "detail",
     row + 1, "  '; End of Downtime Error Logging file generated after running',row+1", row + 1,
     "  '; fix schema output file ", rfiles->qual[idx1].file2d, "', row+1",
     row + 1, "  '; Ended at ',curdate 'DD-MMM-YYYY;;D',' ',curtime 'HH:MM:SS;;M'", row + 1,
     "with format=variable, formfeed=none, maxcol=512, maxrow=1, append go", row + 1, "%d noecho",
     row + 1, "execute dm_schema_file_stop go", row + 1
     IF ((fs_proc->ocd_ind=0))
      row + 1, row + 1, row + 1,
      "; End of file", row + 1, "; Ended at ",
      curdate"DD-MMM-YYYY ;;D", " ", curtime"HH:MM:SS;;M",
      row + 1, "%o"
     ENDIF
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
  ENDIF
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
    SET dm_schema_log->file_name = files->ddl_file
    SET dm_schema_log->table_name = tgtdb->tbl[idx3].tbl_name
    SET dm_schema_log->object_name = tgtdb->tbl[idx3].cons[idx4].cons_name
    SET dm_schema_log->column_name = ""
    EXECUTE dm_schema_estimate_op_log2
   ENDIF
   SELECT INTO value(files->ddl_file)
    d.seq
    FROM (dummyt d  WITH seq = value(tgtdb->tbl[idx3].cons[idx4].cons_col_cnt))
    PLAN (d)
    ORDER BY tgtdb->tbl[idx3].cons[idx4].cons_col[d.seq].col_position
    HEAD REPORT
     SUBROUTINE dcd_write_log(dwl_cmd,dwl_ignore)
       row + 1, "set ddl_log->err_code = error(ddl_log->err_str,1) go", row + 1,
       'set ddl_log->cmd_str = "', dwl_cmd, '" go',
       row + 1, "set ddl_log->ignore_ind = ", dwl_ignore,
       " go"
     END ;Subroutine report
     IF ((fs_proc->inhouse_ind=1))
      "dm_schema_actual_start2 0 go", row + 1
     ENDIF
     row + 1, "rdb ALTER TABLE ", tgtdb->tbl[idx3].tbl_name,
     row + 1, "add constraint ", tgtdb->tbl[idx3].cons[idx4].cons_name
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
     CALL dcd_write_log(txt->errstr,0)
     IF ((fs_proc->inhouse_ind=1))
      "dm_schema_actual_stop2 0 go", row + 1
     ENDIF
     IF ((fs_proc->online_ind=0))
      row + 1, " dm_user_last_updt go"
     ENDIF
     row + 2
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
   IF ((fs_proc->inhouse_ind=0))
    EXECUTE dm_schema_estimate_op_log2
   ENDIF
 END ;Subroutine
 SUBROUTINE dcd_get_ddl_filename(dcd_tbl_idx,dcd_down_ind)
  SET dcd_file_idx = 0
  IF (dcd_tbl_idx > 0)
   SET dcd_file_idx = tgtdb->tbl[dcd_tbl_idx].file_idx
   IF (dcd_down_ind=1)
    SET rfiles->qual[dcd_file_idx].ddl_dn_ind = 1
    RETURN(rfiles->qual[dcd_file_idx].file2d)
   ELSE
    SET rfiles->qual[dcd_file_idx].ddl_up_ind = 1
    RETURN(rfiles->qual[dcd_file_idx].file2)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dcd_get_err_filename(dcd_tbl_idx,dcd_down_ind)
  SET dcd_file_idx = 0
  IF (dcd_tbl_idx > 0)
   SET dcd_file_idx = tgtdb->tbl[dcd_tbl_idx].file_idx
   IF (dcd_down_ind=1)
    RETURN(rfiles->qual[dcd_file_idx].file3d)
   ELSE
    RETURN(rfiles->qual[dcd_file_idx].file3)
   ENDIF
  ENDIF
 END ;Subroutine
END GO
