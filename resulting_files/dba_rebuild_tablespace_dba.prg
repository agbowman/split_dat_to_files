CREATE PROGRAM dba_rebuild_tablespace:dba
 PAINT
 SET cnt = 0
 SET width = 132
 RECORD ts_req(
   1 qual[1]
     2 owner = vc
     2 table_name = vc
     2 tablespace_name = vc
     2 initial_extent = i4
     2 initial_units = c2
     2 max_extents = i4
     2 next_units = c2
     2 next_extent = i4
     2 min_extents = i4
     2 pct_used = i4
     2 pct_free = i4
     2 ini_trans = i4
     2 max_trans = i4
     2 freelists = i4
     2 freelist_groups = i4
     2 degree = vc
     2 instances = vc
     2 cache = vc
     2 pct_increase = i4
     2 continue = c2
     2 valid_tablespace = i4
     2 original_ts = vc
     2 default = vc
     2 extent_management = vc
 )
 RECORD default(
   1 owner = vc
   1 tablespace_name = vc
   1 initial_extent = i4
   1 initial_units = c2
   1 max_extents = i4
   1 next_units = c2
   1 next_extent = i4
   1 min_extents = i4
   1 pct_used = i4
   1 pct_free = i4
   1 ini_trans = i4
   1 max_trans = i4
   1 freelists = i4
   1 freelist_groups = i4
   1 degree = vc
   1 instances = vc
   1 cache = vc
   1 pct_increase = i4
   1 continue = c2
   1 valid_tablespace = i4
   1 original_ts = vc
   1 defs_set = vc
   1 extent_management = vc
 )
 RECORD lob_col(
   1 external_ts_ind = i2
   1 table_cnt = i4
   1 lob_tables[*]
     2 table_name = vc
     2 column_name = vc
     2 chunk = f8
     2 pctversion = f8
     2 cache = vc
     2 logging = vc
     2 in_row = vc
     2 pct_increase = f8
     2 buffer_pool = vc
 )
 SET lob_col->table_cnt = 0
 SET lob_col->external_ts_ind = 0
 DECLARE col_list[255] = c40
 SET database_name2 = fillstring(132," ")
 SET valid_tablespace2 = 0
 SET tablespace_name2 = fillstring(50," ")
 SET file_name1 = fillstring(132," ")
 SET tablespace_count2 = 0
 SET continue2 = fillstring(1," ")
 SET parser_buffer[1] = fillstring(132," ")
 SET table_name2 = fillstring(132," ")
 SET text2 = fillstring(132," ")
 SET xx = 0
 SET temp_owner = fillstring(132," ")
 SET user_practice = fillstring(30," ")
 SET pwd_practice = fillstring(30," ")
 SET nullable = "Y"
 SET oracle_version = 7
 CALL get_oracle_version(1)
 RECORD misc(
   1 position = i4
   1 text = vc
   1 row_count2 = i4
   1 indx = i4
   1 file_name2 = vc
   1 pwd = vc
   1 user_name = vc
   1 unrecoverable = vc
   1 not_null_cons = c1
 )
 SET string = fillstring(100," ")
 SET misc->user_name = fillstring(30," ")
 SET misc->row_count2 = 1
 SET misc->pwd = fillstring(30," ")
 SET misc->unrecoverable = "N"
 IF (oracle_version=7)
  SET misc->not_null_cons = "N"
 ELSE
  SET misc->not_null_cons = "Y"
 ENDIF
 SET default->defs_set = "N"
 CALL accept_userid_pwd(13)
 GO TO tablespace_main_screen
#tablespace_main_screen
 SELECT INTO "nl:"
  b.name
  FROM v$database b
  DETAIL
   database_name2 = b.name
  WITH nocounter
 ;end select
 CALL clear(1,1)
 CALL display_tablespace_screen(1)
 IF (valid_tablespace2=0)
  SET ts_req->qual[cnt].owner = fillstring(30," ")
  SET ts_req->qual[cnt].table_name = fillstring(30," ")
  SET ts_req->qual[cnt].tablespace_name = fillstring(30," ")
  SET ts_req->qual[cnt].original_ts = fillstring(30," ")
  SET ts_req->qual[cnt].next_extent = 0
  SET ts_req->qual[cnt].initial_units = fillstring(2," ")
  SET ts_req->qual[cnt].initial_extent = 0
  SET ts_req->qual[cnt].next_units = fillstring(2," ")
  SET ts_req->qual[cnt].pct_increase = 0
  SET ts_req->qual[cnt].min_extents = 0
  SET ts_req->qual[cnt].max_extents = 0
  SET ts_req->qual[cnt].ini_trans = 0
  SET ts_req->qual[cnt].max_trans = 0
  SET ts_req->qual[cnt].pct_free = 0
  SET ts_req->qual[cnt].pct_used = 0
  SET ts_req->qual[cnt].freelists = 0
  SET ts_req->qual[cnt].freelist_groups = 0
  SET ts_req->qual[cnt].degree = fillstring(10," ")
  SET ts_req->qual[cnt].instances = fillstring(10," ")
  SET ts_req->qual[cnt].cache = fillstring(5," ")
  SET ts_req->qual[cnt].default = fillstring(1," ")
 ENDIF
#enter_tablespace_name
 IF (valid_tablespace2=0)
  CALL clear(23,05,74)
  CALL clear(24,05,74)
  SET tablespace_count2 = 0
  SET init_loop = 1
  SET lob_col->table_cnt = 0
  SET lob_col->external_ts_ind = 0
  SET stat = alterlist(lob_col->lob_tables,0)
  WHILE (((tablespace_count2=0) OR (init_loop=1)) )
    IF (init_loop=1)
     SET init_loop = 0
    ENDIF
    CALL clear(23,05,74)
    CALL text(23,05,"HELP: Press <SHIFT><F5> ")
    SET help =
    SELECT INTO "nl:"
     a.tablespace_name
     FROM dba_tablespaces a
     WHERE a.tablespace_name="D_*"
     ORDER BY a.tablespace_name
     WITH nocounter
    ;end select
    CALL accept(08,23,"P(30);CUS","                      ")
    SET tablespace_name2 = curaccept
    SET help = off
    SELECT INTO "nl:"
     a.table_name, a.initial_extent, a.max_extents,
     a.min_extents, a.pct_increase, a.next_extent,
     a.pct_free, a.pct_used, a.ini_trans,
     a.freelists, a.freelist_groups, a.degree,
     a.instances, a.cache, a.max_trans,
     a.owner
     FROM dba_tables a
     WHERE a.tablespace_name=patstring(tablespace_name2)
     HEAD REPORT
      misc->row_count2 = 1
     DETAIL
      IF ((misc->row_count2 > 1))
       stat = alter(ts_req->qual,(misc->row_count2+ 5))
      ENDIF
      ts_req->qual[misc->row_count2].table_name = a.table_name, ts_req->qual[misc->row_count2].
      initial_extent = a.initial_extent, ts_req->qual[misc->row_count2].max_extents = a.max_extents,
      ts_req->qual[misc->row_count2].next_extent = a.next_extent, ts_req->qual[misc->row_count2].
      min_extents = a.min_extents, ts_req->qual[misc->row_count2].pct_increase = a.pct_increase,
      ts_req->qual[misc->row_count2].ini_trans = a.ini_trans, ts_req->qual[misc->row_count2].
      max_trans = a.max_trans, ts_req->qual[misc->row_count2].pct_free = a.pct_free,
      ts_req->qual[misc->row_count2].pct_used = a.pct_used, ts_req->qual[misc->row_count2].freelists
       = a.freelists, ts_req->qual[misc->row_count2].freelist_groups = a.freelist_groups,
      ts_req->qual[misc->row_count2].degree = a.degree, ts_req->qual[misc->row_count2].instances = a
      .instances, ts_req->qual[misc->row_count2].cache = a.cache,
      ts_req->qual[misc->row_count2].original_ts = tablespace_name2, ts_req->qual[misc->row_count2].
      tablespace_name = tablespace_name2, ts_req->qual[misc->row_count2].owner = a.owner,
      ts_req->qual[misc->row_count2].default = "N", misc->row_count2 = (misc->row_count2+ 1)
     WITH nocounter
    ;end select
    SET tablespace_count2 = curqual
    SET misc->row_count2 = (misc->row_count2 - 1)
    IF (tablespace_count2=0)
     CALL clear(23,05,74)
     CALL clear(24,05,74)
     IF (tablespace_name2="             ")
      CALL text(23,05,"Tablespace name required...")
     ELSE
      IF (cnt=0)
       SET ts_cnt = 0
       SELECT INTO "nl:"
        tablespace_name
        FROM dba_tablespaces
        WHERE tablespace_name=tablespace_name2
        DETAIL
         ts_cnt = (ts_cnt+ 1)
        WITH nocounter
       ;end select
       IF (ts_cnt=0)
        CALL text(23,05,"Tablespace not found...")
       ELSE
        CALL text(23,05,"Tablespace contains no objects...")
       ENDIF
      ENDIF
     ENDIF
     CALL ask_tablespace_continue(1)
     IF (continue2="Y")
      GO TO enter_tablespace_name
     ELSE
      GO TO end_program
     ENDIF
    ELSE
     SELECT INTO "nl:"
      ul.column_name, ul.chunk, ul.pctversion,
      ul.cache, ul.logging, ul.in_row,
      us.pct_increase, us.buffer_pool
      FROM user_lobs ul,
       user_segments us,
       (dummyt d  WITH seq = misc->row_count2)
      PLAN (d)
       JOIN (ul
       WHERE (ul.table_name=ts_req->qual[d.seq].table_name))
       JOIN (us
       WHERE us.segment_type="LOBSEGMENT"
        AND us.segment_name=ul.segment_name)
      DETAIL
       lob_col->table_cnt = (lob_col->table_cnt+ 1)
       IF (mod(lob_col->table_cnt,10)=1)
        stat = alterlist(lob_col->lob_tables,(lob_col->table_cnt+ 9))
       ENDIF
       IF (us.tablespace_name != tablespace_name2)
        lob_col->external_ts_ind = 1
       ELSE
        lob_col->lob_tables[lob_col->table_cnt].table_name = ul.table_name, lob_col->lob_tables[
        lob_col->table_cnt].column_name = ul.column_name, lob_col->lob_tables[lob_col->table_cnt].
        chunk = ul.chunk,
        lob_col->lob_tables[lob_col->table_cnt].pctversion = ul.pctversion, lob_col->lob_tables[
        lob_col->table_cnt].cache = ul.cache, lob_col->lob_tables[lob_col->table_cnt].logging = ul
        .logging,
        lob_col->lob_tables[lob_col->table_cnt].in_row = ul.in_row, lob_col->lob_tables[lob_col->
        table_cnt].pct_increase = us.pct_increase, lob_col->lob_tables[lob_col->table_cnt].
        buffer_pool = us.buffer_pool
       ENDIF
      WITH nocounter
     ;end select
     IF ((lob_col->external_ts_ind=1))
      SET valid_tablespace = 0
      CALL text(12,05,"One or more tables in this tablespace contain a LOB column that is stored")
      CALL text(13,05,"on a separate tablespace.  This configuration is not yet supported.")
      CALL text(23,05,"Cannot rebuild tablespace...")
      CALL ask_tablespace_continue(1)
      IF (continue2="Y")
       CALL clear(12,05,74)
       CALL clear(13,05,74)
       GO TO enter_tablespace_name
      ELSE
       GO TO end_program
      ENDIF
     ENDIF
     SET valid_tablespace = 1
     CALL clear(23,05,74)
    ENDIF
  ENDWHILE
 ENDIF
#enter_file_name
 CALL accept(10,24,"P(22);cus","                         ")
 SET misc->file_name2 = curaccept
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 IF ((misc->file_name2="                "))
  CALL text(23,05,"File name required...")
  CALL ask_tablespace_continue(1)
  IF (continue2="Y")
   CALL clear(23,05,74)
   GO TO enter_file_name
  ELSE
   GO TO end_program
  ENDIF
 ENDIF
 CALL ask_tablespace_continue(1)
 IF (continue2="Y")
  CALL clear(23,05,74)
  GO TO screen_5
 ELSE
  CALL clear(10,17,30)
  GO TO enter_tablespace_name
 ENDIF
#screen_5
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL box(1,1,3,80)
 CALL clear(2,2,78)
 CALL text(2,16,"***** HNA MILLENNIUM REBUILD TABLESPACE/TABLE *****")
 CALL clear(05,03,70)
 CALL clear(07,03,70)
 CALL text(04,03,"DATABASE: ")
 CALL text(04,14,trim(database_name2))
 CALL text(04,35,"Tablespace Name:")
 CALL text(04,53,trim(tablespace_name2))
 CALL text(12,15,"1. View table storage/extent information")
 CALL text(14,15,"2. Modify parameters of a table")
 CALL text(16,15,"3. Generate scripts to rebuild tablespace")
 CALL text(18,15,"4. Set default storage parameters")
 CALL text(20,15,"9. Exit")
 CALL text(23,15,"Your selection: ")
 CALL accept(23,32,"9",0)
 CASE (curaccept)
  OF 1:
   CALL tablespace_storage(3)
   GO TO screen_5
  OF 2:
   CALL clear(1,1)
   GO TO choose_table_loop
  OF 3:
   CALL ask_unrecoverable(124)
   CALL build_tablespace_script(123)
   CALL end_program(1)
  OF 4:
   CALL clear(1,1)
   CALL display_tablespace(126)
   CALL ask_default_values(125)
  OF 9:
   GO TO end_program
  ELSE
   CALL clear(23,05,74)
   CALL text(23,05,"Invalid selection...")
   GO TO screen_5
 ENDCASE
#choose_table_loop
 CALL choose_table(4)
 CALL ask_tablespace_continue(1)
 IF (continue2="N")
  GO TO choose_table_loop
 ENDIF
 CALL get_subscript(table_name2)
#ask_defaults
 CALL clear(23,60,19)
 CALL show_table_info2(6)
 IF ((ts_req->qual[misc->indx].default="N"))
  CALL enter_table_storage_info2(7)
 ELSE
  CALL clear(13,46,2)
  CALL text(13,15,"Use default storage parameters:")
  CALL accept(13,47,"P;CUS","Y"
   WHERE curaccept IN ("Y", "N"))
  SET continue2 = curaccept
  IF (continue2="N")
   SET ts_req->qual[misc->indx].default = "N"
   GO TO ask_defaults
  ENDIF
 ENDIF
 CALL ask_tablespace_continue(1)
 IF (continue2="N")
  CALL clear(15,3)
  CALL box(14,1,22,80)
  CALL clear(14,2,78)
  GO TO ask_defaults
 ELSE
  CALL clear(5,2,70)
  GO TO screen_5
 ENDIF
 SUBROUTINE build_tablespace_script(bts)
   CALL clear(21,20,45)
   CALL video(b)
   CALL text(21,35,"Working...")
   CALL video(n)
   SET filenamerun = concat(cnvtlower(misc->file_name2),"run.ccl")
   SET filename1 = concat(cnvtlower(misc->file_name2),"1.ccl")
   SET filename2a = concat(cnvtlower(misc->file_name2),"2a.ccl")
   SET filename2b = concat(cnvtlower(misc->file_name2),"2b.ccl")
   SET filename2c = concat(cnvtlower(misc->file_name2),"2c.ccl")
   SET filename2d = concat(cnvtlower(misc->file_name2),"2d.ccl")
   SET filename3a = concat(cnvtlower(misc->file_name2),"3a.ccl")
   SET filename3b = concat(cnvtlower(misc->file_name2),"3b.ccl")
   SET filename3c = concat(cnvtlower(misc->file_name2),"3c.ccl")
   SET filename3d = concat(cnvtlower(misc->file_name2),"3d.ccl")
   SET filename3e = concat(cnvtlower(misc->file_name2),"3e.ccl")
   SET exp_pfile = concat(cnvtlower(misc->file_name2),"_exp.prm")
   SET imp_pfile = concat(cnvtlower(misc->file_name2),"_imp.prm")
   CALL initialize_files(1)
   CALL build_tablespace_exp_parm(1)
   CALL export_tables_for_tablespace(19)
   FOR (cnt = 1 TO misc->row_count2)
     CALL drop_child_fk_constraints(ts_req->qual[cnt].table_name)
   ENDFOR
   FOR (cnt = 1 TO misc->row_count2)
     CALL drop_tables(ts_req->qual[cnt].table_name,ts_req->qual[cnt].owner)
   ENDFOR
   CALL coalesce_tablespace(tablespace_name2)
   CALL coalesce_idx_tablespaces(tablespace_name2)
   FOR (cnt = 1 TO misc->row_count2)
     CALL create_tables_tablespace(ts_req->qual[cnt].table_name)
   ENDFOR
   IF (oracle_version=7)
    FOR (cnt = 1 TO misc->row_count2)
      CALL create_idx_7(ts_req->qual[cnt].table_name)
    ENDFOR
   ELSE
    FOR (cnt = 1 TO misc->row_count2)
      CALL create_idx_8(ts_req->qual[cnt].table_name)
    ENDFOR
   ENDIF
   FOR (cnt = 1 TO misc->row_count2)
     CALL create_primary_key(ts_req->qual[cnt].table_name)
   ENDFOR
   IF (oracle_version=7)
    FOR (cnt = 1 TO misc->row_count2)
      CALL create_foreign_key_7(ts_req->qual[cnt].table_name)
    ENDFOR
   ELSE
    FOR (cnt = 1 TO misc->row_count2)
      CALL create_foreign_key_8(ts_req->qual[cnt].table_name)
    ENDFOR
   ENDIF
   CALL build_imp_tablespace_parm(17)
   CALL import_tables_for_tablespace(18)
   IF (oracle_version=7)
    FOR (cnt = 1 TO misc->row_count2)
      CALL create_child_fk_7(ts_req->qual[cnt].table_name)
    ENDFOR
   ELSE
    FOR (cnt = 1 TO misc->row_count2)
      CALL create_child_fk_8(ts_req->qual[cnt].table_name)
    ENDFOR
   ENDIF
   FOR (cnt = 1 TO misc->row_count2)
     CALL create_unique(ts_req->qual[cnt].table_name)
   ENDFOR
   CALL write_run_file(1)
 END ;Subroutine
 SUBROUTINE build_tablespace_exp_parm(btep)
  SET fn = cnvtlower(misc->file_name2)
  SELECT INTO value(exp_pfile)
   " "
   FROM dual
   FOOT REPORT
    col 2, "userid=", string,
    row + 1, "buffer=1000000", row + 1,
    "file=", fn, ".dmp",
    row + 1, "indexes=n", row + 1,
    "constraints=n", row + 1, "compress=n",
    row + 1, "tables=(", ts_req->qual[1].owner,
    ".", ts_req->qual[1].table_name, row + 1
    FOR (cnt = 2 TO misc->row_count2)
      ", ", ts_req->qual[cnt].owner, ".",
      ts_req->qual[cnt].table_name, row + 1
    ENDFOR
    ")", row + 1, "log=",
    fn, "_exp.log"
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
 END ;Subroutine
 SUBROUTINE export_tables_for_tablespace(etft)
   SELECT INTO value(filename1)
    " "
    FROM dual
    HEAD REPORT
     ";******************************************************", row + 1,
     ";******************************************************",
     row + 1
     IF (cursys="AIX")
      "set com2 = '$ORACLE_HOME/bin/exp parfile=", exp_pfile, "'"
     ELSE
      "set com2 = 'exp parfile=", exp_pfile, "'"
     ENDIF
     row + 1, "go", row + 1,
     "call dcl(com2,size(com2),0)", row + 1, "go",
     row + 1, "reset"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drop_child_fk_constraints(table_name4)
   SELECT INTO value(filename2a)
    b.owner, b.table_name, b.constraint_name,
    " GO"
    FROM dba_constraints a,
     dba_constraints b
    WHERE b.constraint_type="R"
     AND b.r_constraint_name=a.constraint_name
     AND a.table_name=table_name4
     AND b.table_name != table_name4
     AND a.owner=b.owner
    ORDER BY b.table_name
    HEAD REPORT
     row + 1
    DETAIL
     x = concat(trim(b.owner),".",trim(b.table_name)), "RDB ALTER TABLE ", x,
     row + 1, col 20, "DROP CONSTRAINT ",
     b.constraint_name, row + 1, "GO",
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE drop_tables(table_name5,owner5)
   SELECT INTO value(filename2b)
    " "
    FROM dual
    DETAIL
     row + 1, "RDB DROP TABLE ", owner5,
     ".", table_name5, " CASCADE CONSTRAINTS",
     row + 1, "GO", row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE coalesce_tablespace(tablespace_name3)
   SELECT INTO value(filename2b)
    " "
    FROM dual
    DETAIL
     FOR (num = 1 TO 8)
       row + 1, "RDB ALTER TABLESPACE ", row + 1,
       col 10, tablespace_name3, " COALESCE",
       row + 1, "GO"
     ENDFOR
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE create_tables_tablespace(table_name6)
   SET message = nowindow
   DECLARE ctl_ts_storage_ind = i2 WITH public, noconstant(0)
   DECLARE ctl_df_storage_ind = i2 WITH public, noconstant(0)
   DECLARE ctl_lob_idx = i4 WITH public, noconstant(0)
   DECLARE ctl_cnt = i4 WITH public, noconstant(0)
   IF ((((ts_req->qual[cnt].initial_extent != null)
    AND (ts_req->qual[cnt].initial_extent != 0)) OR ((((ts_req->qual[cnt].next_extent != null)
    AND (ts_req->qual[cnt].next_extent != 0)) OR ((((ts_req->qual[cnt].min_extents != null)
    AND (ts_req->qual[cnt].min_extents != 0)) OR ((((ts_req->qual[cnt].max_extents != null)
    AND (ts_req->qual[cnt].max_extents != 0)) OR ((((ts_req->qual[cnt].pct_increase != null)
    AND (ts_req->qual[cnt].pct_increase >= 0)) OR ((((ts_req->qual[cnt].freelists != null)
    AND (ts_req->qual[cnt].freelists != 0)) OR ((ts_req->qual[cnt].freelist_groups != null)
    AND (ts_req->qual[cnt].freelist_groups != 0))) )) )) )) )) )) )
    SET ctl_ts_storage_ind = 1
   ENDIF
   IF ((((default->initial_extent != null)
    AND (default->initial_extent != 0)) OR ((((default->next_extent != null)
    AND (default->next_extent != 0)) OR ((((default->min_extents != null)
    AND (default->min_extents != 0)) OR ((((default->max_extents != null)
    AND (default->max_extents != 0)) OR ((((default->pct_increase != null)
    AND (default->pct_increase >= 0)) OR ((((default->freelists != null)
    AND (default->freelists != 0)) OR ((default->freelist_groups != null)
    AND (default->freelist_groups != 0))) )) )) )) )) )) )
    SET ctl_df_storage_ind = 1
   ENDIF
   SET x1 = 0
   SET x1 = initarray(col_list," ")
   IF (x1=0)
    GO TO endprogram
   ENDIF
   IF (oracle_version=8)
    SET k = 0
    SELECT INTO "nl:"
     ucc.column_name, condition = replace(replace(cdef.condition,'"',"",0),"'","",0)
     FROM (sys.cdef$ cdef),
      (sys.con$ con),
      user_cons_columns ucc
     WHERE ucc.table_name=patstring(table_name6)
      AND ucc.constraint_name=con.name
      AND con.con#=cdef.con#
      AND ((cdef.type#=7) OR (cdef.type#=1))
     DETAIL
      pos = findstring("NULL",condition), pos1 = findstring("NOT",condition)
      IF (pos > 0
       AND pos1 > 0)
       k = (k+ 1), col_list[k] = ucc.column_name
      ENDIF
     WITH nocounter, maxrec = 100
    ;end select
   ELSE
    SET k = 0
    SELECT INTO "nl:"
     ucc.column_name, cdef.condition
     FROM (sys.cdef$ cdef),
      (sys.con$ con),
      user_cons_columns ucc
     WHERE ucc.table_name=patstring(table_name6)
      AND ucc.constraint_name=con.name
      AND con.con#=cdef.con#
      AND ((cdef.type=7) OR (cdef.type=1))
     DETAIL
      pos = findstring("NULL",cdef.condition), pos1 = findstring("NOT",cdef.condition)
      IF (pos > 0
       AND pos1 > 0)
       k = (k+ 1), col_list[k] = ucc.column_name
      ENDIF
     WITH nocounter, maxrec = 100
    ;end select
   ENDIF
   SELECT INTO value(filename2c)
    uic.column_name, dr_data_type = substring(1,10,uic.data_type), uic.data_length,
    uic.nullable, uic.column_id, uc.tablespace_name,
    uc.table_name, uc.owner, default_value = substring(1,110,trim(uic.data_default))
    FROM dba_tab_columns uic,
     dba_tables uc
    WHERE uc.table_name=table_name6
     AND uc.table_name=uic.table_name
    ORDER BY uc.table_name, uic.column_id
    HEAD uc.table_name
     row + 1, x = concat(trim(uc.owner),".",trim(table_name6)), "RDB CREATE TABLE ",
     x, row + 1, col 2,
     "("
    DETAIL
     IF (uic.column_id > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,uic.column_name),
     col 2, col_name, nullable = "Y",
     col 42, dr_data_type
     IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
      col 60, "(", col 61,
      uic.data_length"####;;I", col 66, ")"
     ENDIF
     IF (default_value != " ")
      row + 1, " DEFAULT ", tempstr = build(default_value),
      tempstr, row + 1
     ENDIF
     IF ((misc->not_null_cons="Y"))
      CALL search_not_null(col_name)
     ENDIF
     IF (((uic.nullable="N") OR (nullable="N"
      AND (misc->not_null_cons="Y"))) )
      " NOT NULL "
     ENDIF
    FOOT  uc.table_name
     row + 1, col 2, ")",
     row + 1
     IF ((ts_req->qual[cnt].default="N"))
      col 2, "TABLESPACE ", ts_req->qual[cnt].tablespace_name,
      row + 1
      IF (ctl_ts_storage_ind=1)
       col 2, "STORAGE (", row + 1
      ENDIF
      IF ((ts_req->qual[cnt].initial_extent != null)
       AND (ts_req->qual[cnt].initial_extent != 0))
       col 11, "INITIAL ", ts_req->qual[cnt].initial_extent,
       row + 1
      ENDIF
      IF ((ts_req->qual[cnt].next_extent != null)
       AND (ts_req->qual[cnt].next_extent != 0))
       col 11, "NEXT ", ts_req->qual[cnt].next_extent,
       row + 1
      ENDIF
      IF ((ts_req->qual[cnt].min_extents != null)
       AND (ts_req->qual[cnt].min_extents != 0))
       col 11, "MINEXTENTS ", ts_req->qual[cnt].min_extents,
       row + 1
      ENDIF
      IF ((ts_req->qual[cnt].max_extents != null)
       AND (ts_req->qual[cnt].max_extents != 0))
       col 11, "MAXEXTENTS ", ts_req->qual[cnt].max_extents,
       row + 1
      ENDIF
      IF ((ts_req->qual[cnt].pct_increase != null)
       AND (ts_req->qual[cnt].pct_increase >= 0))
       col 11, "PCTINCREASE ", ts_req->qual[cnt].pct_increase,
       row + 1
      ENDIF
      IF ((ts_req->qual[cnt].freelists != null)
       AND (ts_req->qual[cnt].freelists != 0))
       col 11, "FREELISTS ", ts_req->qual[cnt].freelists,
       row + 1
      ENDIF
      IF ((ts_req->qual[cnt].freelist_groups != null)
       AND (ts_req->qual[cnt].freelist_groups != 0))
       col 11, "FREELIST GROUPS ", ts_req->qual[cnt].freelist_groups,
       row + 1
      ENDIF
      IF (ctl_ts_storage_ind=1)
       col 2, ")", row + 1
      ENDIF
      col 2, "PCTFREE ", col 11,
      ts_req->qual[cnt].pct_free, col 29, "INITRANS ",
      col 38, ts_req->qual[cnt].ini_trans, row + 1,
      col 2, "MAXTRANS ", col 11,
      ts_req->qual[cnt].max_trans, row + 1, col 2,
      "PCTUSED ", col 13, ts_req->qual[cnt].pct_used,
      row + 1
     ELSE
      col 2, "TABLESPACE ", default->tablespace_name,
      row + 1
      IF (ctl_df_storage_ind=1)
       col 2, "STORAGE (", row + 1
      ENDIF
      IF ((default->initial_extent != null)
       AND (default->initial_extent != 0))
       col 11, "INITIAL ", default->initial_extent,
       row + 1
      ENDIF
      IF ((default->next_extent != null)
       AND (default->next_extent != 0))
       col 11, "NEXT ", default->next_extent,
       row + 1
      ENDIF
      IF ((default->min_extents != null)
       AND (default->min_extents != 0))
       col 11, "MINEXTENTS ", default->min_extents,
       row + 1
      ENDIF
      IF ((default->max_extents != null)
       AND (default->max_extents != 0))
       col 11, "MAXEXTENTS ", default->max_extents,
       row + 1
      ENDIF
      IF ((default->pct_increase != null)
       AND (default->pct_increase >= 0))
       col 11, "PCTINCREASE ", default->pct_increase,
       row + 1
      ENDIF
      IF ((default->freelists != null)
       AND (default->freelists != 0))
       col 11, "FREELISTS ", default->freelists,
       row + 1
      ENDIF
      IF ((default->freelist_groups != null)
       AND (default->freelist_groups != 0))
       col 11, "FREELIST GROUPS ", default->freelist_groups,
       row + 1
      ENDIF
      IF (ctl_df_storage_ind=1)
       col 2, ")", row + 1
      ENDIF
      col 2, "PCTFREE ", col 11,
      default->pct_free, col 29, "INITRANS ",
      col 38, default->ini_trans, row + 1,
      col 2, "MAXTRANS ", col 11,
      default->max_trans, row + 1, col 2,
      "PCTUSED ", col 13, default->pct_used,
      row + 1
     ENDIF
     row + 1
     IF ((lob_col->table_cnt > 0))
      ctl_cnt = locateval(ctl_lob_idx,1,lob_col->table_cnt,ts_req->qual[cnt].table_name,lob_col->
       lob_tables[ctl_lob_idx].table_name)
      IF (ctl_cnt > 0)
       col 2, "LOB (", lob_col->lob_tables[ctl_cnt].column_name,
       ") STORE AS (TABLESPACE "
       IF ((ts_req->qual[cnt].default="N"))
        col + 2, ts_req->qual[cnt].tablespace_name
       ELSE
        col + 2, default->tablespace_name
       ENDIF
       IF ((lob_col->lob_tables[ctl_cnt].in_row="YES"))
        col + 2, " ENABLE STORAGE IN ROW"
       ELSE
        col + 2, " DISABLE STORAGE IN ROW"
       ENDIF
       row + 1, col 2, "STORAGE(PCTINCREASE ",
       lob_col->lob_tables[ctl_cnt].pct_increase, " BUFFER_POOL ", lob_col->lob_tables[ctl_cnt].
       buffer_pool,
       ")", row + 1, col 2,
       "CHUNK ", lob_col->lob_tables[ctl_cnt].chunk, " PCTVERSION ",
       lob_col->lob_tables[ctl_cnt].pctversion, " "
       IF ((lob_col->lob_tables[ctl_cnt].cache="YES"))
        col + 2, "CACHE"
       ELSE
        col + 2, "NOCACHE"
        IF ((lob_col->lob_tables[ctl_cnt].logging="YES"))
         col + 2, "LOGGING"
        ENDIF
       ENDIF
       col + 2, ")", row + 1
      ENDIF
     ENDIF
     row + 1, "go", row + 2,
     "execute oragen3 '", ts_req->qual[cnt].table_name, "' GO"
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
   SET message = window
 END ;Subroutine
 SUBROUTINE create_primary_key(table_name8)
   SELECT INTO value(filename2d)
    uc.constraint_name, uc.table_name, ucc.column_name,
    ucc.position, uc.status, uc.owner
    FROM dba_cons_columns ucc,
     dba_constraints uc
    WHERE uc.owner=ucc.owner
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.table_name=uc.table_name
     AND uc.table_name=table_name8
     AND uc.constraint_type="P"
    ORDER BY uc.table_name, ucc.position
    HEAD REPORT
     x = concat(trim(uc.owner),".",trim(uc.table_name)), row + 1
    HEAD uc.table_name
     "RDB ALTER TABLE ", col 20, x,
     row + 1, col 5, " ADD CONSTRAINT ",
     uc.constraint_name, row + 1, col 10,
     " PRIMARY KEY ("
    DETAIL
     IF (ucc.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,ucc.column_name),
     col 10, col_name
    FOOT  uc.table_name
     row + 1, col 10, ")",
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_foreign_key_7(table_name9)
   SELECT INTO value(filename3b)
    col1.name, ccol.pos#, op.name,
    con.name, oc.name, cdef.enabled,
    uc.name, up.name
    FROM (sys.ccol$ ccol),
     (sys.col$ col1),
     (sys.con$ con),
     (sys.obj$ op),
     (sys.obj$ oc),
     (sys.cdef$ cdef),
     (sys.user$ up),
     (sys.user$ uc)
    WHERE cdef.type=4
     AND oc.obj#=cdef.obj#
     AND op.obj#=cdef.robj#
     AND ccol.con#=cdef.con#
     AND col1.col#=ccol.col#
     AND con.con#=cdef.con#
     AND col1.obj#=oc.obj#
     AND oc.name=table_name9
     AND uc.user#=oc.owner#
     AND up.user#=op.owner#
    ORDER BY con.name, ccol.pos#
    HEAD REPORT
     row + 1
    HEAD con.name
     namec = concat(trim(uc.name),".",trim(oc.name)), namep = concat(trim(up.name),".",trim(op.name)),
     "RDB ALTER TABLE ",
     col 20, namec, row + 1,
     col 20, " ADD CONSTRAINT ", con.name,
     row + 1, col 30, " FOREIGN KEY ("
    DETAIL
     IF (ccol.pos# > 1)
      ","
     ENDIF
     row + 1, col 10, col1.name
    FOOT  con.name
     row + 1, col 10, ")",
     row + 1, col 10, " REFERENCES ",
     namep, " "
     IF (cdef.enabled=null)
      "DISABLE"
     ENDIF
     row + 1, "GO", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_foreign_key_8(table_name9)
   SELECT INTO value(filename3b)
    col1.name, ccol.pos#, op.name,
    con.name, oc.name, cdef.enabled,
    uc.name, up.name
    FROM (sys.ccol$ ccol),
     (sys.col$ col1),
     (sys.con$ con),
     (sys.obj$ op),
     (sys.obj$ oc),
     (sys.cdef$ cdef),
     (sys.user$ up),
     (sys.user$ uc)
    WHERE cdef.type#=4
     AND oc.obj#=cdef.obj#
     AND op.obj#=cdef.robj#
     AND ccol.con#=cdef.con#
     AND col1.col#=ccol.col#
     AND con.con#=cdef.con#
     AND col1.obj#=oc.obj#
     AND oc.name=table_name9
     AND uc.user#=oc.owner#
     AND up.user#=op.owner#
    ORDER BY con.name, ccol.pos#
    HEAD REPORT
     row + 1
    HEAD con.name
     namec = concat(trim(uc.name),".",trim(oc.name)), namep = concat(trim(up.name),".",trim(op.name)),
     "RDB ALTER TABLE ",
     col 20, namec, row + 1,
     col 20, " ADD CONSTRAINT ", con.name,
     row + 1, col 30, " FOREIGN KEY ("
    DETAIL
     IF (ccol.pos# > 1)
      ","
     ENDIF
     row + 1, col 10, col1.name
    FOOT  con.name
     row + 1, col 10, ")",
     row + 1, col 10, " REFERENCES ",
     namep, " "
     IF (cdef.enabled=null)
      "DISABLE"
     ENDIF
     row + 1, "GO", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_idx_7(table_name10)
   SELECT INTO value(filename2d)
    col1.name, icol.pos#, o.name,
    i.name, ts.name, ind.unique$,
    s.iniexts, s.extsize, ts.blocksize,
    s.minexts, s.maxexts, s.extpct,
    ind.initrans, ind.maxtrans, ui.name,
    uo.name
    FROM (sys.ind$ ind),
     (sys.icol$ icol),
     (sys.col$ col1),
     (sys.ts$ ts),
     (sys.user$ ui),
     (sys.user$ uo),
     (sys.seg$ s),
     (sys.obj$ i),
     (sys.obj$ o)
    PLAN (o
     WHERE o.name=table_name10)
     JOIN (ind
     WHERE ind.bo#=o.obj#)
     JOIN (ts
     WHERE ts.ts#=ind.ts#)
     JOIN (i
     WHERE i.obj#=ind.obj#)
     JOIN (icol
     WHERE icol.obj#=ind.obj#)
     JOIN (ui
     WHERE ui.user#=i.owner#)
     JOIN (uo
     WHERE uo.user#=o.owner#)
     JOIN (col1
     WHERE col1.col#=icol.col#
      AND col1.obj#=icol.bo#)
     JOIN (s
     WHERE s.file#=ind.file#
      AND s.block#=ind.block#)
    ORDER BY i.name, icol.pos#
    HEAD REPORT
     row + 1
    HEAD i.name
     x = concat(trim(ui.name),".",trim(i.name)), y = concat(trim(uo.name),".",trim(o.name)), row + 1,
     "RDB CREATE "
     IF (ind.unique$=1)
      "UNIQUE "
     ENDIF
     row + 1, "INDEX ", row + 1,
     x, row + 1, col 20,
     "ON ", y, row + 1,
     col 30, "("
    DETAIL
     IF (icol.pos# > 1)
      ","
     ENDIF
     row + 1, col 30, col1.name
    FOOT  i.name
     row + 1, col 30, ")",
     row + 1, col 10, " TABLESPACE ",
     ts.name, row + 1, col 2,
     "STORAGE (INITIAL ", initext = (s.iniexts * ts.blocksize), col 19,
     initext";;i", row + 1, col 11,
     "NEXT ", nextext = (s.extsize * ts.blocksize), col 17,
     nextext";;i", row + 1, col 11,
     "MINEXTENTS ", col 23, s.minexts";;i",
     row + 1, col 11, "MAXEXTENTS ",
     col 23, s.maxexts";;i", row + 1,
     col 11, "PCTINCREASE ", col 22,
     s.extpct";;i", row + 1, col 10,
     ")", row + 1
     IF ((misc->unrecoverable="Y"))
      col 2, "UNRECOVERABLE", row + 1
     ENDIF
     "go", row + 2
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_idx_8(table_name10)
   SET message = nowindow
   DECLARE ci8_storage_ind = i2 WITH public, noconstant(0)
   SELECT INTO value(filename2d)
    col1.name, icol.pos#, o.name,
    i.name, ts.name, ind.property,
    s.iniexts, s.extsize, ts.blocksize,
    s.minexts, s.maxexts, s.extpct,
    ind.initrans, ind.maxtrans, ui.name,
    uo.name
    FROM (sys.ind$ ind),
     (sys.icol$ icol),
     (sys.col$ col1),
     (sys.ts$ ts),
     (sys.user$ ui),
     (sys.user$ uo),
     (sys.seg$ s),
     (sys.obj$ i),
     (sys.obj$ o)
    PLAN (o
     WHERE o.name=table_name10)
     JOIN (ind
     WHERE ind.bo#=o.obj#)
     JOIN (ts
     WHERE ts.ts#=ind.ts#)
     JOIN (i
     WHERE i.obj#=ind.obj#)
     JOIN (icol
     WHERE icol.obj#=ind.obj#)
     JOIN (ui
     WHERE ui.user#=i.owner#)
     JOIN (uo
     WHERE uo.user#=o.owner#)
     JOIN (col1
     WHERE col1.col#=icol.col#
      AND col1.obj#=icol.bo#)
     JOIN (s
     WHERE s.file#=ind.file#
      AND s.block#=ind.block#)
    ORDER BY i.name, icol.pos#
    HEAD REPORT
     row + 1
    HEAD i.name
     ci8_storage_ind = 0
     IF (((s.iniexts != null
      AND s.iniexts != 0) OR (((s.extsize != null
      AND s.extsize != 0) OR (((s.minexts != null
      AND s.minexts != 0) OR (((s.maxexts != null
      AND s.maxexts != 0) OR (s.extpct != null
      AND s.extpct >= 0)) )) )) )) )
      ci8_storage_ind = 1
     ENDIF
     x = concat(trim(ui.name),".",trim(i.name)), y = concat(trim(uo.name),".",trim(o.name)), row + 1,
     "RDB CREATE "
     IF (band(cnvtint(ind.property),1)=1)
      "UNIQUE "
     ENDIF
     row + 1, "INDEX ", row + 1,
     x, row + 1, col 20,
     "ON ", y, row + 1,
     col 30, "("
    DETAIL
     IF (icol.pos# > 1)
      ","
     ENDIF
     row + 1, col 30, col1.name
    FOOT  i.name
     row + 1, col 30, ")",
     row + 1, col 10, " TABLESPACE ",
     ts.name, row + 1
     IF (ci8_storage_ind=1)
      col 2, "STORAGE (", row + 1
     ENDIF
     IF (s.iniexts != null
      AND s.iniexts != 0)
      initext = (s.iniexts * ts.blocksize), col 11, "INITIAL ",
      initext";;i", row + 1
     ENDIF
     IF (s.extsize != null
      AND s.extsize != 0)
      nextext = (s.extsize * ts.blocksize), col 11, "NEXT ",
      nextext";;i", row + 1
     ENDIF
     IF (s.minexts != null
      AND s.minexts != 0)
      col 11, "MINEXTENTS ", s.minexts";;i",
      row + 1
     ENDIF
     IF (s.maxexts != null
      AND s.maxexts != 0)
      col 11, "MAXEXTENTS ", s.maxexts";;i",
      row + 1
     ENDIF
     IF (s.extpct != null
      AND s.extpct >= 0)
      col 11, "PCTINCREASE ", s.extpct";;i",
      row + 1
     ENDIF
     IF (ci8_storage_ind=1)
      col 2, ")", row + 1
     ENDIF
     IF ((misc->unrecoverable="Y"))
      col 2, "UNRECOVERABLE", row + 1
     ENDIF
     "go", row + 2
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
   SET message = window
 END ;Subroutine
 SUBROUTINE build_imp_tablespace_parm(bip)
  SET fn = cnvtlower(misc->file_name2)
  SELECT INTO value(imp_pfile)
   " "
   FROM dual
   FOOT REPORT
    col 2, "userid=", string,
    row + 1, "buffer=1000000", row + 1,
    "file=", fn, ".dmp",
    row + 1, "ignore=y", row + 1,
    "full=y", row + 1, row + 1,
    "commit=y", row + 1, "log=",
    fn, "_imp.log"
   WITH format = stream, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
 END ;Subroutine
 SUBROUTINE import_tables_for_tablespace(table_name11)
   SELECT INTO value(filename3a)
    " "
    FROM dual
    HEAD REPORT
     ";***************************************************************************************", row
      + 1, "; Import the table ",
     row + 1,
     ";***************************************************************************************", row
      + 1
     IF (cursys="AIX")
      "set com2 = '$ORACLE_HOME/bin/imp parfile=", imp_pfile, "'"
     ELSE
      "set com2 = 'imp parfile=", imp_pfile, "'"
     ENDIF
     row + 1, "go", row + 1,
     "call dcl(com2,size(com2),0)", row + 1, "go"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_child_fk_7(table_name19)
   SELECT INTO value(filename3d)
    col1.name, ccol.pos#, op.name,
    con.name, oc.name, cdef.enabled,
    up.name, uc.name
    FROM (sys.ccol$ ccol),
     (sys.col$ col1),
     (sys.con$ con),
     (sys.tab$ tc),
     (sys.obj$ op),
     (sys.obj$ oc),
     (sys.cdef$ cdef),
     (sys.tab$ tp),
     (sys.user$ up),
     (sys.user$ uc)
    WHERE cdef.type=4
     AND oc.obj#=cdef.obj#
     AND cdef.robj#=op.obj#
     AND ccol.con#=cdef.con#
     AND col1.col#=ccol.col#
     AND con.con#=cdef.con#
     AND col1.obj#=oc.obj#
     AND op.name=table_name19
     AND tc.obj#=oc.obj#
     AND tp.obj#=op.obj#
     AND tp.ts# != tc.ts#
     AND uc.user#=oc.owner#
     AND up.user#=op.owner#
    ORDER BY con.name, ccol.pos#
    HEAD con.name
     namec = concat(trim(uc.name),".",trim(oc.name)), "RDB ALTER TABLE ", namec,
     row + 1, col 20, " ADD CONSTRAINT ",
     con.name, row + 1, col 30,
     " FOREIGN KEY ("
    DETAIL
     IF (ccol.pos# > 1)
      ","
     ENDIF
     row + 1, col 10, col1.name
    FOOT  con.name
     namep = concat(trim(up.name),".",trim(op.name)), row + 1, col 10,
     ")", row + 1, col 10,
     " REFERENCES ", namep, " "
     IF (cdef.enabled=null)
      "DISABLE"
     ENDIF
     row + 1, "go", row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE create_child_fk_8(table_name19)
   SELECT INTO value(filename3d)
    col1.name, ccol.pos#, op.name,
    con.name, oc.name, cdef.enabled,
    up.name, uc.name
    FROM (sys.ccol$ ccol),
     (sys.col$ col1),
     (sys.con$ con),
     (sys.tab$ tc),
     (sys.obj$ op),
     (sys.obj$ oc),
     (sys.cdef$ cdef),
     (sys.tab$ tp),
     (sys.user$ up),
     (sys.user$ uc)
    WHERE cdef.type#=4
     AND oc.obj#=cdef.obj#
     AND cdef.robj#=op.obj#
     AND ccol.con#=cdef.con#
     AND col1.col#=ccol.col#
     AND con.con#=cdef.con#
     AND col1.obj#=oc.obj#
     AND op.name=table_name19
     AND tc.obj#=oc.obj#
     AND tp.obj#=op.obj#
     AND tp.ts# != tc.ts#
     AND uc.user#=oc.owner#
     AND up.user#=op.owner#
    ORDER BY con.name, ccol.pos#
    HEAD con.name
     namec = concat(trim(uc.name),".",trim(oc.name)), "RDB ALTER TABLE ", namec,
     row + 1, col 20, " ADD CONSTRAINT ",
     con.name, row + 1, col 30,
     " FOREIGN KEY ("
    DETAIL
     IF (ccol.pos# > 1)
      ","
     ENDIF
     row + 1, col 10, col1.name
    FOOT  con.name
     namep = concat(trim(up.name),".",trim(op.name)), row + 1, col 10,
     ")", row + 1, col 10,
     " REFERENCES ", namep, " "
     IF (cdef.enabled=null)
      "DISABLE"
     ENDIF
     row + 1, "go", row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE create_unique(table_name21)
   SELECT INTO value(filename3c)
    uc.constraint_name, uc.table_name, ucc.column_name,
    ucc.position, uc.status, uc.owner
    FROM dba_cons_columns ucc,
     dba_constraints uc
    WHERE uc.owner=ucc.owner
     AND ucc.constraint_name=uc.constraint_name
     AND ucc.table_name=uc.table_name
     AND uc.table_name=table_name21
     AND uc.constraint_type="U"
    ORDER BY uc.table_name, ucc.position
    HEAD REPORT
     x = concat(trim(uc.owner),".",trim(uc.table_name)), row + 1
    HEAD uc.constraint_name
     "RDB ALTER TABLE ", col 20, x,
     row + 1, col 5, " ADD CONSTRAINT ",
     uc.constraint_name, row + 1, col 10,
     " UNIQUE ("
    DETAIL
     IF (ucc.position > 1)
      ","
     ENDIF
     row + 1, col_name = fillstring(40," "), col_name = substring(1,40,ucc.column_name),
     col 10, col_name
    FOOT  uc.table_name
     row + 1, col 10, ")",
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_check_7(table_name23)
   SELECT INTO value(filename3e)
    t.name, u.name, con.name,
    cdef.condition
    FROM (sys.obj$ t),
     (sys.user$ u),
     (sys.con$ con),
     (sys.cdef$ cdef)
    WHERE t.name=table_name23
     AND ((cdef.type=1) OR (cdef.type=7))
     AND cdef.obj#=t.obj#
     AND con.con#=cdef.con#
     AND u.user#=t.owner#
    ORDER BY con.name
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section rebuilds the check and not null constraints",
     row + 1, ";****************************************************************************", row +
     1,
     namet = concat(trim(u.name),".",trim(t.name))
    HEAD con.name
     "RDB ALTER TABLE ", namet, row + 1,
     " ADD CONSTRAINT ", con.name, row + 1,
     " CHECK ", row + 1, "(",
     row + 1, cdef.condition, row + 1,
     ")", row + 1, "go",
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 32010, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE create_check_8(table_name23)
   SELECT INTO value(filename3e)
    t.name, u.name, con.name,
    condition = replace(replace(cdef.condition,'"',"",0),"'","",0)
    FROM (sys.obj$ t),
     (sys.user$ u),
     (sys.con$ con),
     (sys.cdef$ cdef)
    WHERE t.name=table_name23
     AND ((cdef.type#=1) OR (cdef.type#=7))
     AND cdef.obj#=t.obj#
     AND con.con#=cdef.con#
     AND u.user#=t.owner#
    ORDER BY con.name
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section rebuilds the check and not null constraints",
     row + 1, ";****************************************************************************", row +
     1,
     namet = concat(trim(u.name),".",trim(t.name))
    HEAD con.name
     "RDB ALTER TABLE ", namet, row + 1,
     " ADD CONSTRAINT ", con.name, row + 1,
     " CHECK ", row + 1, "(",
     row + 1, condition, row + 1,
     ")", row + 1, "go",
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 32010, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE get_subscript(table_name3)
   FOR (cnt = 1 TO misc->row_count2)
     IF ((ts_req->qual[cnt].table_name=table_name2))
      SET misc->indx = cnt
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE show_table_info2(u)
   CALL clear(05,03,70)
   CALL clear(07,03,70)
   CALL text(04,03,"DATABASE: ")
   CALL text(04,14,trim(database_name2))
   CALL text(04,35,"Tablespace Name:")
   CALL text(04,53,trim(tablespace_name2))
   CALL text(06,03,concat("TABLE: ",table_name2))
   IF ((ts_req->qual[misc->indx].default="N"))
    SET misc->text = cnvtstring((ts_req->qual[misc->indx].initial_extent/ 1024))
    CALL text(7,3,concat("INITIAL: ",misc->text))
    SET misc->position = (((3+ 9)+ size(misc->text))+ 1)
    CALL text(7,misc->position,"K")
    SET misc->text = cnvtstring((ts_req->qual[misc->indx].next_extent/ 1024))
    CALL text(7,24,concat("Next: ",misc->text))
    SET misc->position = (((24+ 6)+ size(misc->text))+ 1)
    CALL text(7,misc->position,"K")
    CALL text(8,3,concat("MIN EXTENTS: ",cnvtstring(ts_req->qual[misc->indx].min_extents)))
    CALL text(8,24,concat("MAX EXTENTS: ",cnvtstring(ts_req->qual[misc->indx].max_extents)))
    CALL text(9,3,concat("PCT INCREASE: ",cnvtstring(ts_req->qual[misc->indx].pct_increase)))
    CALL text(9,24,concat("PCT FREE: ",cnvtstring(ts_req->qual[misc->indx].pct_free)))
    CALL text(9,45,concat("PCT USED: ",cnvtstring(ts_req->qual[misc->indx].pct_used)))
    CALL text(10,3,concat("FREELISTS: ",cnvtstring(ts_req->qual[misc->indx].freelists)))
    CALL text(10,24,concat("FREELIST GROUPS: ",cnvtstring(ts_req->qual[misc->indx].freelist_groups)))
    CALL text(11,3,concat("DEGREE: ",trim(ts_req->qual[misc->indx].degree,2)))
    CALL text(11,24,concat("INSTANCES: ",trim(ts_req->qual[misc->indx].instances,2)))
    CALL text(11,45,concat("CACHE: ",trim(ts_req->qual[misc->indx].cache,2)))
    CALL text(12,3,concat("INI TRANS: ",cnvtstring(ts_req->qual[misc->indx].ini_trans)))
    CALL text(12,24,concat("MAX TRANS: ",cnvtstring(ts_req->qual[misc->indx].max_trans)))
   ELSE
    SET misc->text = cnvtstring((default->initial_extent/ 1024))
    CALL text(7,3,concat("INITIAL: ",misc->text))
    SET misc->position = (((3+ 9)+ size(misc->text))+ 1)
    CALL text(7,misc->position,"K")
    SET misc->text = cnvtstring((default->next_extent/ 1024))
    CALL text(7,24,concat("Next: ",misc->text))
    SET misc->position = (((24+ 6)+ size(misc->text))+ 1)
    CALL text(7,misc->position,"K")
    CALL text(8,3,concat("MIN EXTENTS: ",cnvtstring(default->min_extents)))
    CALL text(8,24,concat("MAX EXTENTS: ",cnvtstring(default->max_extents)))
    CALL text(9,3,concat("PCT INCREASE: ",cnvtstring(default->pct_increase)))
    CALL text(9,24,concat("PCT FREE: ",cnvtstring(default->pct_free)))
    CALL text(9,45,concat("PCT USED: ",cnvtstring(default->pct_used)))
    CALL text(10,3,concat("FREELISTS: ",cnvtstring(default->freelists)))
    CALL text(10,24,concat("FREELIST GROUPS:",cnvtstring(default->freelist_groups)))
    CALL text(11,3,concat("DEGREE: ",trim(default->degree,2)))
    CALL text(11,24,concat("INSTANCES: ",trim(default->instances,2)))
    CALL text(11,45,concat("CACHE: ",trim(default->cache,2)))
    CALL text(12,3,concat("INI TRANS: ",cnvtstring(default->ini_trans)))
    CALL text(12,24,concat("MAX TRANS: ",cnvtstring(default->max_trans)))
   ENDIF
 END ;Subroutine
 SUBROUTINE enter_table_storage_info2(etsi)
   SET temp_ts = fillstring(30," ")
   SET ts_count = 0
   SET temp_initial = 0
   SET temp_next = 0
   SET done = "N"
   WHILE (done="N")
     CALL text(13,15,"Use default storage parameters:")
     CALL text(14,3,"Enter new values for the table:")
     CALL text(15,3,"TABLESPACE: ")
     CALL text(16,3,"INITIAL: ")
     CALL text(16,24,"B/K/M")
     CALL text(16,45,"NEXT: ")
     CALL text(16,63,"B/K/M")
     CALL text(17,3,"MIN EXTENTS: ")
     CALL text(17,24,"MAX EXTENTS: ")
     CALL text(18,3,"PCTINCREASE: ")
     CALL text(18,24,"PCT FREE: ")
     CALL text(18,45,"PCT USED: ")
     CALL text(19,3,"FREELISTS: ")
     CALL text(19,24,"FREELIST GROUPS: ")
     CALL text(20,3,"DEGREE: ")
     CALL text(20,24,"INSTANCES: ")
     CALL text(20,45,"CACHE: ")
     CALL text(21,3,"INI TRANS: ")
     CALL text(21,24,"MAX TRANS: ")
     CALL clear(13,46,2)
     CALL accept(13,47,"P;CUS","N"
      WHERE curaccept IN ("Y", "N"))
     SET continue2 = curaccept
     IF (continue2="Y")
      IF ((default->defs_set="Y"))
       SET ts_req->qual[misc->indx].default = "Y"
       SET num = 14
       WHILE (num <= 21)
        CALL clear(num,2,70)
        SET num = (num+ 1)
       ENDWHILE
       GO TO ask_defaults
      ELSE
       SET num = 5
       WHILE (num <= 21)
        CALL clear(num,2,70)
        SET num = (num+ 1)
       ENDWHILE
       CALL text(13,20,"Default values have not been set.")
       CALL text(14,20,"You must set default values before")
       CALL text(15,20,"applying them to tables.")
       CALL ask_tablespace_continue(1)
       IF (continue2="N")
        GO TO screen_5
       ELSE
        CALL clear(5,2,70)
        GO TO screen_5
       ENDIF
      ENDIF
     ENDIF
     CALL clear(23,60,19)
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL text(23,05,"HELP: Press <SHIFT><F5> ")
       SET help =
       SELECT INTO "nl:"
        a.tablespace_name
        FROM dba_tablespaces a
        WHERE a.tablespace_name != "SYSTEM"
         AND a.tablespace_name != "MISC"
         AND a.tablespace_name != "TEMP"
         AND a.tablespace_name != "RB*"
        ORDER BY a.tablespace_name
        WITH nocounter
       ;end select
       CALL accept(15,16,"PPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS",ts_req->qual[misc->indx].original_ts)
       SET ts_req->qual[misc->indx].tablespace_name = curaccept
       SET help = off
       CALL clear(23,01,74)
       IF ((ts_req->qual[misc->indx].tablespace_name="          "))
        CALL clear(24,5,74)
        CALL text(24,5,"Tablespace name required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SELECT INTO "nl:"
      ts.extent_management
      FROM dba_tablespaces ts
      WHERE (ts.tablespace_name=ts_req->qual[misc->indx].tablespace_name)
      DETAIL
       ts_req->qual[misc->indx].extent_management = trim(ts.extent_management,3)
      WITH nocounter
     ;end select
     CALL clear(23,60,19)
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(16,12,"9999999999",ts_req->qual[misc->indx].initial_extent)
       SET temp_initial = curaccept
       IF (((temp_initial < 0) OR (temp_initial=0
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,05,74)
        CALL text(24,05,"Initial extent size required...")
       ELSE
        CALL clear(24,05,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       SET ts_req->qual[misc->indx].initial_units = "B"
       CALL accept(16,30,"P;CUS",ts_req->qual[misc->indx].initial_units)
       SET ts_req->qual[misc->indx].initial_units = curaccept
       IF ( NOT ((ts_req->qual[misc->indx].initial_units IN ("B", "M", "K"))))
        CALL clear(24,5,74)
        CALL text(24,5,"Initial units must be B, K, or M...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
        IF ((ts_req->qual[misc->indx].initial_units="B"))
         SET ts_req->qual[misc->indx].initial_extent = temp_initial
        ELSEIF ((ts_req->qual[misc->indx].initial_units="K"))
         SET ts_req->qual[misc->indx].initial_extent = (temp_initial * 1024)
        ELSE
         SET ts_req->qual[misc->indx].initial_extent = ((temp_initial * 1024) * 1024)
        ENDIF
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(16,51,"99999999999",ts_req->qual[misc->indx].next_extent)
       SET temp_next = curaccept
       IF (((temp_next < 0) OR (temp_next=0
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,5,74)
        CALL text(24,5,"Next extent size required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       SET ts_req->qual[misc->indx].next_units = "B"
       CALL accept(16,69,"P;CUS",ts_req->qual[misc->indx].next_units)
       SET ts_req->qual[misc->indx].next_units = curaccept
       IF ( NOT ((ts_req->qual[misc->indx].next_units IN ("B", "M", "K"))))
        CALL clear(24,5,74)
        CALL text(24,5,"Next units must be B, K, or M...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
        IF ((ts_req->qual[misc->indx].next_units="B"))
         SET ts_req->qual[misc->indx].next_extent = temp_next
        ELSEIF ((ts_req->qual[misc->indx].next_units="K"))
         SET ts_req->qual[misc->indx].next_extent = (temp_next * 1024)
        ELSE
         SET ts_req->qual[misc->indx].next_extent = ((temp_next * 1024) * 1024)
        ENDIF
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(17,16,"999",ts_req->qual[misc->indx].min_extents)
       SET ts_req->qual[misc->indx].min_extents = curaccept
       IF ((((ts_req->qual[misc->indx].min_extents < 0)) OR ((ts_req->qual[misc->indx].min_extents=0)
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,5,74)
        CALL text(24,5,"Min extents parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     SET text2 = cnvtstring(ts_req->qual[misc->indx].max_extents)
     WHILE (continue2="N")
       CALL accept(17,37,"PPPPPPPPP;CUS",text2)
       SET text2 = curaccept
       IF (cnvtint(text2) <= 0)
        IF (text2="UNLIMITED")
         CALL clear(24,5,74)
         SET continue2 = "Y"
         SET ts_req->qual[misc->indx].max_extents = 2147483645
        ELSEIF ((ts_req->qual[misc->indx].extent_management="LOCAL")
         AND isnumeric(text2) > 0
         AND cnvtint(text2)=0)
         CALL clear(24,5,74)
         SET continue2 = "Y"
         SET ts_req->qual[misc->indx].max_extents = cnvtint(text2)
        ELSE
         CALL clear(24,5,74)
         IF ((ts_req->qual[misc->indx].extent_management="LOCAL"))
          CALL text(24,5,"Max extents should be 0 or greater, or UNLIMITED...")
         ELSE
          CALL text(24,5,"Max extents should be greater than 0, or UNLIMITED...")
         ENDIF
        ENDIF
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
        SET ts_req->qual[misc->indx].max_extents = cnvtint(text2)
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(18,16,"999",ts_req->qual[misc->indx].pct_increase)
       SET ts_req->qual[misc->indx].pct_increase = curaccept
       IF ((ts_req->qual[misc->indx].pct_increase < 0))
        CALL clear(24,5,74)
        CALL text(24,5,"Pct Increase parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(18,34,"999",ts_req->qual[misc->indx].pct_free)
       SET ts_req->qual[misc->indx].pct_free = curaccept
       IF ((((ts_req->qual[misc->indx].pct_free < 0)) OR ((ts_req->qual[misc->indx].pct_free=0)
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,5,74)
        CALL text(24,5,"Pct Free parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(18,55,"999",ts_req->qual[misc->indx].pct_used)
       SET ts_req->qual[misc->indx].pct_used = curaccept
       IF ((((ts_req->qual[misc->indx].pct_used < 0)) OR ((ts_req->qual[misc->indx].pct_used=0)
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,5,74)
        CALL text(24,5,"Pct Used parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(19,14,"999999999",ts_req->qual[misc->indx].freelists)
       SET ts_req->qual[misc->indx].freelists = curaccept
       IF ((((ts_req->qual[misc->indx].freelists < 0)) OR ((ts_req->qual[misc->indx].freelists=0)
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,5,74)
        CALL text(24,5,"Freelists parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(19,41,"999999999",ts_req->qual[misc->indx].freelist_groups)
       SET ts_req->qual[misc->indx].freelist_groups = curaccept
       IF ((((ts_req->qual[misc->indx].freelist_groups < 0)) OR ((ts_req->qual[misc->indx].
       freelist_groups=0)
        AND (ts_req->qual[misc->indx].extent_management != "LOCAL"))) )
        CALL clear(24,5,74)
        CALL text(24,5,"Freelist Groups parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     CALL accept(20,11,"PPPPPPPPP;CUS",trim(ts_req->qual[misc->indx].degree,2))
     CALL accept(20,35,"PPPPPPPPP;CUS",trim(ts_req->qual[misc->indx].instances,2))
     CALL accept(20,52,"PPPPP;CUS",trim(ts_req->qual[misc->indx].cache,2))
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(21,14,"999999999",ts_req->qual[misc->indx].ini_trans)
       SET ts_req->qual[misc->indx].ini_trans = curaccept
       IF ((ts_req->qual[misc->indx].ini_trans <= 0))
        CALL clear(24,5,74)
        CALL text(24,5,"Ini Trans parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(21,35,"999999999",ts_req->qual[misc->indx].max_trans)
       SET ts_req->qual[misc->indx].max_trans = curaccept
       IF ((ts_req->qual[misc->indx].max_trans <= 0))
        CALL clear(24,5,74)
        CALL text(24,5,"Max Trans parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     CALL ask_tablespace_continue(1)
     IF (continue2="N")
      CALL clear(15,3)
      CALL box(14,1,22,80)
      CALL clear(14,2,78)
     ELSE
      SET done = "Y"
      CALL clear(5,2,70)
      GO TO screen_5
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE choose_table(ct)
   CALL box(1,1,22,80)
   CALL box(1,1,03,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD TABLESPACE  *** ")
   CALL text(04,03,"DATABASE: ")
   CALL text(04,14,trim(database_name2))
   CALL text(04,35,"Tablespace Name:")
   CALL text(04,53,trim(tablespace_name2))
   CALL text(07,03,"Table Name: ")
   CALL clear(23,05,74)
   CALL text(23,05,"HELP: PRESS <SHIFT><F5> ")
   SET help =
   SELECT INTO "nl:"
    c.table_name
    FROM dba_tables c
    WHERE c.tablespace_name=tablespace_name2
    ORDER BY c.table_name
    WITH nocounter
   ;end select
   SET validate =
   SELECT INTO "nl:"
    c.table_name
    FROM dba_tables c
    WHERE c.tablespace_name=tablespace_name2
     AND c.table_name=curaccept
    WITH nocounter
   ;end select
   SET validate = 1
   CALL accept(07,16,"P(30);CUS","            ")
   SET table_name2 = curaccept
   CALL clear(23,05,74)
   SET help = off
   SET validate = off
 END ;Subroutine
 SUBROUTINE display_tablespace_screen(dts)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,3,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD TABLESPACE  *** ")
   CALL video(n)
   CALL text(06,05,"DATABASE: ")
   CALL text(06,16,trim(database_name2))
   CALL text(08,05,"Tablespace Name:")
   CALL text(10,05,"Output File Name:")
 END ;Subroutine
 SUBROUTINE display_tablespace(dss)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,3,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD TABLESPACE  *** ")
   CALL video(n)
 END ;Subroutine
 SUBROUTINE ask_tablespace_continue(g)
   CALL text(23,60,"Continue(Y/N)?")
   CALL accept(23,75,"P;CUS","N"
    WHERE curaccept IN ("Y", "N"))
   SET continue2 = curaccept
 END ;Subroutine
 SUBROUTINE tablespace_storage(d)
   SELECT DISTINCT
    a.bytes, a.blocks, a.extents,
    b.table_name, b.initial_extent, b.next_extent,
    b.tablespace_name, b.min_extents, b.max_extents,
    b.pct_increase, b.ini_trans, b.max_trans,
    b.pct_free, b.pct_used, b.freelists,
    b.freelist_groups, b.degree, b.instances,
    b.cache
    FROM dba_segments a,
     dba_tables b
    WHERE b.tablespace_name=a.tablespace_name
     AND a.tablespace_name=tablespace_name2
     AND b.table_name=a.segment_name
    ORDER BY b.table_name
    HEAD REPORT
     line = fillstring(80,"=")
    HEAD PAGE
     col 2, "Table Name", col 35,
     "Grand totals for the tablespace are at the bottom", row + 1
    DETAIL
     col 2, b.table_name, row + 1,
     col 6, "Storage Info:", col 79,
     "Extent Info:", row + 1, kbytes = (a.bytes/ 1024),
     initial = (b.initial_extent/ 1024), col 10, "Initial (Kbytes:)",
     col 30, initial"########", col 55,
     "Ini_trans:", col 72, b.ini_trans,
     col 85, "Total Kbytes:", col + 7,
     kbytes, row + 1, col 10,
     "Next:", next = (b.next_extent/ 1024), col 30,
     next"########", col 55, "Max Trans: ",
     col 72, b.max_trans"########", col 85,
     "Total# of Blocks", col + 4, b.blocks,
     row + 1, col 10, "Min:",
     col 30, b.min_extents"########", col 55,
     "Free lists:", col 72, b.freelists"########",
     col 85, "Total # of Extents:", col + 1,
     a.extents, row + 1, max = (b.max_extents/ 1024),
     col 10, "Max (KB):", col 30,
     max"########", col 55, "Free list groups:",
     col 72, b.freelist_groups"########", row + 1,
     col 10, "Pct Incr:", col 30,
     b.pct_increase"########", col 55, "Degree:",
     col 72, b.degree, col 10,
     "Pct Used:", col 30, b.pct_used"########",
     col 55, "Instances:", col 72,
     b.instances, row + 1, col 10,
     "Pct Free:", col 30, b.pct_free,
     col 55, "Cache:", col 72,
     b.cache"########", row + 2
    FOOT REPORT
     col 48, "Grand totals for", col + 1,
     b.tablespace_name, row + 1, col 60,
     "Kbytes:", col + 2, sum((a.bytes/ 1024)),
     row + 1, col 60, "Blocks:",
     col + 2, sum(a.blocks), row + 1,
     col 60, "Extents:", col + 1,
     sum(a.extents)
   ;end select
 END ;Subroutine
 SUBROUTINE initialize_files(ini)
   SELECT INTO value(filename2a)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section deletes the foreign keys on the child tables",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename2b)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section drops and coalesces the target table",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename2c)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section recreates the target table",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename2d)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section recreates indexes and primary key ",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename3b)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";creates parent foreign keys ",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename3c)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";creates unique constraints",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename3d)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";This script rebuilds child FK constraints",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename3e)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";creates check and not null constraints",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE accept_userid_pwd(aup)
   CALL clear(1,1)
   CALL display_tablespace_screen(12)
   CALL clear(06,05,50)
   CALL clear(08,05,50)
   CALL clear(10,05,50)
   CALL text(08,10,"USERNAME: ")
   CALL text(10,10,"PASSWORD: ")
   CALL text(15,5,"Username and password are used for the export and import process")
   CALL accept(08,21,"P(30);C","   ")
   SET misc->user_name = curaccept
   CALL accept(10,21,"P(30);C","   ")
   SET misc->pwd = curaccept
   SET string = concat(misc->user_name,"/",misc->pwd)
   CALL ask_tablespace_continue(13)
   IF (continue2="N")
    GO TO end_program
   ENDIF
 END ;Subroutine
 SUBROUTINE end_program(ep)
   SET filenamerun = concat(cnvtlower(misc->file_name2),"run")
   SET filename1 = concat(cnvtlower(misc->file_name2),"1")
   SET filename2a = concat(cnvtlower(misc->file_name2),"2a")
   SET filename2b = concat(cnvtlower(misc->file_name2),"2b")
   SET filename2c = concat(cnvtlower(misc->file_name2),"2c")
   SET filename2d = concat(cnvtlower(misc->file_name2),"2d")
   SET filename3a = concat(cnvtlower(misc->file_name2),"3a")
   SET filename3b = concat(cnvtlower(misc->file_name2),"3b")
   SET filename3c = concat(cnvtlower(misc->file_name2),"3c")
   SET filename3d = concat(cnvtlower(misc->file_name2),"3d")
   SET filename3e = concat(cnvtlower(misc->file_name2),"3e")
   SET exp_pfile = concat(cnvtlower(misc->file_name2),"_exp.prm")
   SET imp_pfile = concat(cnvtlower(misc->file_name2),"_imp.prm")
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,3,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD TABLESPACE  *** ")
   CALL video(n)
   CALL clear(12,08,50)
   CALL clear(14,08,50)
   CALL clear(15,08,50)
   CALL clear(16,08,50)
   CALL clear(04,02,30)
   CALL clear(18,15,50)
   CALL text(04,05,"DATABASE: ")
   CALL text(04,16,trim(database_name2))
   CALL text(6,4,"Directory: [CCLUSERDIR]")
   CALL text(7,8,"OUTPUT FILE:")
   CALL text(7,35,"CONTENTS:")
   CALL text(8,08,concat(filename1,".CCL"))
   CALL text(8,35,"---> Export File")
   CALL text(9,08,concat(filename2a,".CCL"))
   CALL text(9,35,"---> Drops child foreign keys")
   CALL text(10,08,concat(filename2b,".CCL"))
   CALL text(10,35,"---> Drops tables and coalesces tablespace")
   CALL text(11,08,concat(filename2c,".CCL"))
   CALL text(11,35,"---> Creates tables")
   CALL text(12,08,concat(filename2d,".CCL"))
   CALL text(12,35,"---> Creates indexes and PK constraints")
   CALL text(13,08,concat(filename3a,".CCL"))
   CALL text(13,35,"---> Import File")
   CALL text(14,08,concat(filename3b,".CCL"))
   CALL text(14,35,"---> Creates parent foreign key constraints")
   CALL text(15,08,concat(filename3c,".CCL"))
   CALL text(15,35,"---> Create unique keys")
   CALL text(16,08,exp_pfile)
   CALL text(16,35,"---> Export parameter file")
   CALL text(17,08,imp_pfile)
   CALL text(17,35,"---> Import parameter file")
   CALL text(18,08,concat(filenamerun,".CCL"))
   CALL text(18,35,"---> Master run file.")
   CALL video(b)
   CALL text(19,25,"Scripts have been generated!")
   CALL video(n)
   CALL text(20,4,concat(
     "Include export file, then check to make sure export was successful, then include"))
   CALL text(21,4,concat("the master run file to execute remaining scripts (CCL>%i ",filenamerun,
     ".CCL)"))
   CALL clear(23,04,50)
   CALL ask_tablespace_continue(23)
   IF (continue2="Y")
    GO TO end_program
   ELSE
    GO TO end_program
   ENDIF
 END ;Subroutine
 SUBROUTINE ask_unrecoverable(aunr)
   CALL clear(12,10,55)
   CALL clear(14,10,55)
   CALL clear(16,10,55)
   CALL clear(18,10,55)
   CALL clear(20,10,55)
   CALL clear(23,10,55)
   CALL text(18,10,"Would you like indexes built unrecoverable?")
   IF (oracle_version=7)
    CALL text(20,10,"Build NOT NULL check constraints from any defined constraints :")
   ENDIF
   CALL accept(18,55,"P;CUS","N"
    WHERE curaccept IN ("Y", "N"))
   SET continue2 = curaccept
   IF (continue2="Y")
    SET misc->unrecoverable = "Y"
   ENDIF
   IF (oracle_version=7)
    CALL accept(20,74,"P;CUS","N"
     WHERE curaccept IN ("Y", "N"))
    SET continue2 = curaccept
    IF (continue2="Y")
     SET misc->not_null_cons = "Y"
    ENDIF
   ENDIF
 END ;Subroutine
#enter_defaults_label
 SUBROUTINE ask_default_values(sadv)
   SET default->owner = fillstring(30," ")
   SET default->tablespace_name = fillstring(30," ")
   SET default->original_ts = fillstring(30," ")
   SET default->next_extent = 0
   SET default->initial_units = fillstring(2," ")
   SET default->initial_extent = 0
   SET default->next_units = fillstring(2," ")
   SET default->pct_increase = 0
   SET default->min_extents = 0
   SET default->max_extents = 0
   SET default->ini_trans = 0
   SET default->max_trans = 0
   SET default->pct_free = 0
   SET default->pct_used = 0
   SET default->freelists = 0
   SET default->freelist_groups = 0
   SET default->degree = fillstring(10," ")
   SET default->instances = fillstring(10," ")
   SET default->cache = fillstring(5," ")
   CALL box(1,1,22,80)
   CALL box(1,1,03,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD TABLESPACE  *** ")
   CALL text(04,03,"DATABASE: ")
   CALL text(04,14,trim(database_name2))
   CALL text(04,35,"Tablespace Name:")
   CALL text(04,53,trim(tablespace_name2))
   CALL text(07,20,"Please set the default parameters:")
   CALL text(08,20,"These parameters can be applied to any or")
   CALL text(09,20,"all of the tables in within the tablespace.")
   CALL text(13,26,"ENTER DEFAULT PARAMETERS:")
   CALL text(15,3,"TABLESPACE: ")
   CALL text(16,3,"INITIAL: ")
   CALL text(16,24,"B/K/M")
   CALL text(16,45,"NEXT: ")
   CALL text(16,63,"B/K/M")
   CALL text(17,3,"MIN EXTENTS: ")
   CALL text(17,24,"MAX EXTENTS: ")
   CALL text(18,3,"PCTINCREASE: ")
   CALL text(18,24,"PCT FREE: ")
   CALL text(18,45,"PCT USED: ")
   CALL text(19,3,"FREELISTS: ")
   CALL text(19,24,"FREELIST GROUPS: ")
   CALL text(20,3,"DEGREE: ")
   CALL text(20,24,"INSTANCES: ")
   CALL text(20,45,"CACHE: ")
   CALL text(21,3,"INI TRANS: ")
   CALL text(21,24,"MAX TRANS: ")
   CALL clear(23,60,19)
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL text(23,05,"HELP: Press <SHIFT><F5> ")
     SET help =
     SELECT INTO "nl:"
      a.tablespace_name
      FROM dba_tablespaces a
      WHERE a.tablespace_name != "SYSTEM"
       AND a.tablespace_name != "MISC"
       AND a.tablespace_name != "TEMP"
       AND a.tablespace_name != "RB*"
      ORDER BY a.tablespace_name
      WITH nocounter
     ;end select
     CALL accept(15,16,"PPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS",ts_req->qual[1].original_ts)
     SET default->tablespace_name = curaccept
     SET help = off
     CALL clear(23,01,74)
     IF ((default->tablespace_name="          "))
      CALL clear(24,5,74)
      CALL text(24,5,"Tablespace name required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SELECT INTO "nl:"
    ts.extent_management
    FROM dba_tablespaces ts
    WHERE (ts.tablespace_name=default->tablespace_name)
    DETAIL
     default->extent_management = trim(ts.extent_management,3)
    WITH nocounter
   ;end select
   CALL clear(23,60,19)
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(16,12,"9999999999",ts_req->qual[1].initial_extent)
     SET temp_initial = curaccept
     IF (((temp_initial < 0) OR (temp_initial=0
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,05,74)
      CALL text(24,05,"Initial extent size required...")
     ELSE
      CALL clear(24,05,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     SET ts_req->qual[1].initial_units = "B"
     CALL accept(16,30,"P;CUS",ts_req->qual[1].initial_units)
     SET default->initial_units = curaccept
     IF ( NOT ((default->initial_units IN ("B", "M", "K"))))
      CALL clear(24,5,74)
      CALL text(24,5,"Initial units must be B, K, or M...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
      IF ((default->initial_units="B"))
       SET default->initial_extent = temp_initial
      ELSEIF ((default->initial_units="K"))
       SET default->initial_extent = (temp_initial * 1024)
      ELSE
       SET default->initial_extent = ((temp_initial * 1024) * 1024)
      ENDIF
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(16,51,"99999999999",ts_req->qual[1].next_extent)
     SET temp_next = curaccept
     IF (((temp_next < 0) OR (temp_next=0
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,5,74)
      CALL text(24,5,"Next extent size required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     SET ts_req->qual[1].next_units = "B"
     CALL accept(16,69,"P;CUS",ts_req->qual[1].next_units)
     SET default->next_units = curaccept
     IF ( NOT ((default->next_units IN ("B", "M", "K"))))
      CALL clear(24,5,74)
      CALL text(24,5,"Next units must be B, K, or M...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
      IF ((default->next_units="B"))
       SET default->next_extent = temp_next
      ELSEIF ((default->next_units="K"))
       SET default->next_extent = (temp_next * 1024)
      ELSE
       SET default->next_extent = ((temp_next * 1024) * 1024)
      ENDIF
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(17,16,"999",ts_req->qual[1].min_extents)
     SET default->min_extents = curaccept
     IF ((((default->min_extents < 0)) OR ((default->min_extents=0)
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,5,74)
      CALL text(24,5,"Min extents parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   SET text2 = cnvtstring(ts_req->qual[1].max_extents)
   WHILE (continue2="N")
     CALL accept(17,37,"PPPPPPPPPPPP;CUS",text2)
     SET text2 = curaccept
     IF (cnvtint(text2) <= 0)
      IF (text2="UNLIMITED")
       CALL clear(24,5,74)
       SET continue2 = "Y"
       SET default->max_extents = 2147483645
      ELSEIF (trim(default->extent_management,3)="LOCAL"
       AND isnumeric(text2) > 0
       AND cnvtint(text2)=0)
       CALL clear(24,5,74)
       SET continue2 = "Y"
       SET default->max_extents = cnvtint(text2)
      ELSE
       CALL clear(24,5,74)
       IF ((default->extent_management="LOCAL"))
        CALL text(24,5,"Max extents should be 0 or greater, or UNLIMITED...")
       ELSE
        CALL text(24,5,"Max extents should be greater than 0 or UNLIMITED...")
       ENDIF
      ENDIF
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
      SET default->max_extents = cnvtint(text2)
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(18,16,"999",ts_req->qual[1].pct_increase)
     SET default->pct_increase = curaccept
     IF ((default->pct_increase < 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Pct Increase parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(18,34,"999",ts_req->qual[1].pct_free)
     SET default->pct_free = curaccept
     IF ((((default->pct_free < 0)) OR ((default->pct_free=0)
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,5,74)
      CALL text(24,5,"Pct Free parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(18,55,"999",ts_req->qual[1].pct_used)
     SET default->pct_used = curaccept
     IF ((((default->pct_used < 0)) OR ((default->pct_used=0)
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,5,74)
      CALL text(24,5,"Pct Used parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(19,14,"999999999",ts_req->qual[1].freelists)
     SET default->freelists = curaccept
     IF ((((default->freelists < 0)) OR ((default->freelists=0)
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,5,74)
      CALL text(24,5,"Freelists parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(19,41,"999999999",ts_req->qual[1].freelist_groups)
     SET default->freelist_groups = curaccept
     IF ((((default->freelist_groups < 0)) OR ((default->freelist_groups=0)
      AND (default->extent_management != "LOCAL"))) )
      CALL clear(24,5,74)
      CALL text(24,5,"Freelist Groups parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   CALL accept(20,11,"PPPPPPPPP;CUS",trim(ts_req->qual[1].degree,2))
   CALL accept(20,35,"PPPPPPPPP;CUS",trim(ts_req->qual[1].instances,2))
   CALL accept(20,52,"PPPPP;CUS",trim(ts_req->qual[1].cache,2))
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(21,14,"999999999",ts_req->qual[1].ini_trans)
     SET default->ini_trans = curaccept
     IF ((default->ini_trans <= 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Ini Trans parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(21,35,"999999999",ts_req->qual[1].max_trans)
     SET default->max_trans = curaccept
     IF ((default->max_trans <= 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Max Trans parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET num = 5
   WHILE (num <= 21)
    CALL clear(num,2,70)
    SET num = (num+ 1)
   ENDWHILE
   CALL text(13,24,"Apply defaults to all tables:")
   CALL accept(13,54,"P;CUS","Y"
    WHERE curaccept IN ("Y", "N"))
   SET continue2 = curaccept
   IF (continue2="Y")
    FOR (cnt = 1 TO misc->row_count2)
      SET ts_req->qual[cnt].default = "Y"
    ENDFOR
   ENDIF
   CALL ask_tablespace_continue(1)
   IF (continue2="N")
    GO TO screen_5
    FOR (cnt = 1 TO misc->row_count2)
      SET ts_req->qual[cnt].default = "N"
    ENDFOR
   ELSE
    SET default->defs_set = "Y"
    CALL clear(5,2,70)
    GO TO screen_5
   ENDIF
 END ;Subroutine
 SUBROUTINE coalesce_idx_tablespaces(cits)
   SELECT DISTINCT INTO value(filename2b)
    its.name
    FROM (sys.ind$ ind),
     (sys.tab$ tab),
     (sys.ts$ its),
     (sys.ts$ ots)
    WHERE ots.name=tablespace_name2
     AND ots.ts#=tab.ts#
     AND ind.bo#=tab.obj#
     AND its.ts#=ind.ts#
    DETAIL
     FOR (num = 1 TO 8)
       row + 1, "RDB ALTER TABLESPACE ", row + 1,
       col 10, its.name, " COALESCE",
       row + 1, "GO"
     ENDFOR
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE search_not_null(col_name1)
   SET j = 1
   SET found = 0
   WHILE ((col_list[j] != " ")
    AND j < 255
    AND found=0)
    IF ((col_list[j]=col_name1))
     SET nullable = "N"
     SET found = 1
    ENDIF
    SET j = (j+ 1)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE get_oracle_version(g)
  SELECT INTO "nl:"
   *
   FROM product_component_version
   WHERE product="Oracle7 Server*"
  ;end select
  IF (curqual=0)
   SET oracle_version = 8
  ENDIF
 END ;Subroutine
 SUBROUTINE write_run_file(wrf)
   SELECT INTO value(filenamerun)
    " "
    FROM dual
    DETAIL
     row + 1, "%i ", filename2a,
     row + 1, "%i ", filename2b,
     row + 1, "%i ", filename2c,
     row + 1, "%i ", filename2d,
     row + 1, "%i ", filename3a,
     row + 1, "%i ", filename3b,
     row + 1, "%i ", filename3c,
     row + 1, "%i ", filename3d,
     row + 1, "%i ", filename3e,
     row + 1, "reset"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
#end_program
 CALL clear(1,1)
END GO
