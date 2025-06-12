CREATE PROGRAM dba_rebuild_idx_tablespace:dba
 PAINT
 SET cnt = 0
 SET width = 132
 RECORD ts_req(
   1 qual[1]
     2 owner = vc
     2 index_name = vc
     2 tablespace_name = vc
     2 initial_extent = i4
     2 initial_units = c2
     2 max_extents = i4
     2 next_units = c2
     2 next_extent = i4
     2 min_extents = i4
     2 pct_free = i4
     2 ini_trans = i4
     2 max_trans = i4
     2 freelists = i4
     2 freelist_groups = i4
     2 pct_increase = i4
     2 type = i1
     2 continue = c2
     2 valid_tablespace = i4
     2 original_ts = vc
     2 default = vc
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
 )
 SET database_name2 = fillstring(132," ")
 SET valid_tablespace2 = 0
 SET tablespace_name2 = fillstring(50," ")
 SET file_name1 = fillstring(132," ")
 SET tablespace_count2 = 0
 SET continue2 = fillstring(1," ")
 SET parser_buffer[1] = fillstring(132," ")
 SET index_name2 = fillstring(132," ")
 SET text2 = fillstring(132," ")
 SET xx = 0
 SET temp_owner = fillstring(132," ")
 SET user_practice = fillstring(30," ")
 SET pwd_practice = fillstring(30," ")
 RECORD misc(
   1 position = i4
   1 text = vc
   1 row_count2 = i4
   1 indx = i4
   1 file_name2 = vc
   1 pwd = vc
   1 user_name = vc
   1 unrecoverable = vc
 )
 SET string = fillstring(100," ")
 SET misc->user_name = fillstring(30," ")
 SET misc->row_count2 = 1
 SET misc->pwd = fillstring(30," ")
 SET misc->unrecoverable = "N"
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
  SET ts_req->qual[cnt].index_name = fillstring(30," ")
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
  SET ts_req->qual[cnt].freelists = 0
  SET ts_req->qual[cnt].freelist_groups = 0
  SET ts_req->qual[cnt].type = 0
  SET ts_req->qual[cnt].default = fillstring(1," ")
 ENDIF
#enter_tablespace_name
 IF (valid_tablespace2=0)
  CALL clear(23,05,74)
  CALL clear(24,05,74)
  SET tablespace_count2 = 0
  SET init_loop = 1
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
     WHERE a.tablespace_name="I_*"
     ORDER BY a.tablespace_name
     WITH nocounter
    ;end select
    CALL accept(08,23,"P(30);CUS","                      ")
    SET tablespace_name2 = curaccept
    SET help = off
    SELECT INTO "nl:"
     o.name, i.name, ts.name,
     ind.pctfree$, s.iniexts, s.extsize,
     ts.blocksize, u.name, s.minexts,
     s.maxexts, s.extpct, ind.initrans,
     ind.maxtrans
     FROM (sys.ind$ ind),
      (sys.ts$ ts),
      (sys.seg$ s),
      (sys.obj$ i),
      (sys.obj$ o),
      dummyt d,
      (sys.con$ con),
      (sys.user$ u),
      (sys.cdef$ cdef)
     PLAN (ts
      WHERE ts.name=tablespace_name2)
      JOIN (ind
      WHERE ind.ts#=ts.ts#)
      JOIN (i
      WHERE i.obj#=ind.obj#)
      JOIN (o
      WHERE o.obj#=ind.bo#)
      JOIN (u
      WHERE u.user#=i.owner#)
      JOIN (s
      WHERE s.file#=ind.file#
       AND s.block#=ind.block#)
      JOIN (d)
      JOIN (con
      WHERE con.name=i.name)
      JOIN (cdef
      WHERE cdef.con#=con.con#
       AND ((cdef.type=2) OR (cdef.type=3)) )
     ORDER BY i.name
     HEAD REPORT
      misc->row_count2 = 1
     DETAIL
      IF ((misc->row_count2 > 1))
       stat = alter(ts_req->qual,misc->row_count2)
      ENDIF
      ts_req->qual[misc->row_count2].index_name = i.name, ts_req->qual[misc->row_count2].
      initial_extent = (s.iniexts * ts.blocksize), ts_req->qual[misc->row_count2].max_extents = s
      .maxexts,
      ts_req->qual[misc->row_count2].next_extent = (s.extsize * ts.blocksize), ts_req->qual[misc->
      row_count2].min_extents = s.minexts, ts_req->qual[misc->row_count2].pct_increase = s.extpct,
      ts_req->qual[misc->row_count2].ini_trans = ind.initrans, ts_req->qual[misc->row_count2].
      max_trans = ind.maxtrans, ts_req->qual[misc->row_count2].pct_free = ind.pctfree$
      IF (s.lists=0)
       ts_req->qual[misc->row_count2].freelists = 1
      ELSE
       ts_req->qual[misc->row_count2].freelists = s.lists
      ENDIF
      IF (s.groups=0)
       ts_req->qual[misc->row_count2].freelist_groups = 1
      ELSE
       ts_req->qual[misc->row_count2].freelist_groups = s.groups
      ENDIF
      ts_req->qual[misc->row_count2].original_ts = tablespace_name2, ts_req->qual[misc->row_count2].
      tablespace_name = tablespace_name2, ts_req->qual[misc->row_count2].owner = u.name,
      ts_req->qual[misc->row_count2].default = "N", misc->row_count2 = (misc->row_count2+ 1)
     WITH outerjoin = d, dontexist, nocounter
    ;end select
    SET tablespace_count2 = curqual
    SELECT INTO "nl:"
     o.name, i.name, ts.name,
     ind.pctfree$, cdef.type, s.iniexts,
     s.extsize, ts.blocksize, u.name,
     s.minexts, s.maxexts, s.extpct,
     ind.initrans, ind.maxtrans
     FROM (sys.ind$ ind),
      (sys.ts$ ts),
      (sys.seg$ s),
      (sys.obj$ i),
      (sys.obj$ o),
      (sys.con$ con),
      (sys.user$ u),
      (sys.cdef$ cdef)
     PLAN (ts
      WHERE ts.name=tablespace_name2)
      JOIN (ind
      WHERE ind.ts#=ts.ts#)
      JOIN (i
      WHERE i.obj#=ind.obj#)
      JOIN (o
      WHERE o.obj#=ind.bo#)
      JOIN (u
      WHERE u.user#=i.owner#)
      JOIN (s
      WHERE s.file#=ind.file#
       AND s.block#=ind.block#)
      JOIN (con
      WHERE con.name=i.name)
      JOIN (cdef
      WHERE cdef.con#=con.con#
       AND ((cdef.type=2) OR (cdef.type=3)) )
     ORDER BY i.name
     DETAIL
      IF ((misc->row_count2 > 1))
       stat = alter(ts_req->qual,misc->row_count2)
      ENDIF
      ts_req->qual[misc->row_count2].index_name = i.name, ts_req->qual[misc->row_count2].
      initial_extent = (s.iniexts * ts.blocksize), ts_req->qual[misc->row_count2].max_extents = s
      .maxexts,
      ts_req->qual[misc->row_count2].next_extent = (s.extsize * ts.blocksize), ts_req->qual[misc->
      row_count2].min_extents = s.minexts, ts_req->qual[misc->row_count2].pct_increase = s.extpct,
      ts_req->qual[misc->row_count2].ini_trans = ind.initrans, ts_req->qual[misc->row_count2].
      max_trans = ind.maxtrans, ts_req->qual[misc->row_count2].pct_free = ind.pctfree$
      IF (s.lists=0)
       ts_req->qual[misc->row_count2].freelists = 1
      ELSE
       ts_req->qual[misc->row_count2].freelists = s.lists
      ENDIF
      IF (s.groups=0)
       ts_req->qual[misc->row_count2].freelist_groups = 1
      ELSE
       ts_req->qual[misc->row_count2].freelist_groups = s.groups
      ENDIF
      ts_req->qual[misc->row_count2].type = cdef.type, ts_req->qual[misc->row_count2].original_ts =
      tablespace_name2, ts_req->qual[misc->row_count2].tablespace_name = tablespace_name2,
      ts_req->qual[misc->row_count2].owner = u.name, ts_req->qual[misc->row_count2].default = "N",
      misc->row_count2 = (misc->row_count2+ 1)
     WITH nocounter
    ;end select
    SET tablespace_count2 = (tablespace_count2+ curqual)
    SET misc->row_count2 = (misc->row_count2 - 1)
    IF (tablespace_count2=0)
     CALL clear(23,05,74)
     CALL clear(24,05,74)
     IF (tablespace_name2="             ")
      CALL text(23,05,"Tablespace name required...")
     ELSE
      CALL text(23,05,"Tablespace not found...")
     ENDIF
     CALL ask_tablespace_continue(1)
     IF (continue2="Y")
      GO TO enter_tablespace_name
     ELSE
      GO TO end_program
     ENDIF
    ELSE
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
 CALL text(2,16,"***** HNA MILLENNIUM REBUILD INDEX TABLESPACE *****")
 CALL clear(05,03,70)
 CALL clear(07,03,70)
 CALL text(04,03,"DATABASE: ")
 CALL text(04,14,trim(database_name2))
 CALL text(04,35,"Tablespace Name:")
 CALL text(04,53,trim(tablespace_name2))
 CALL text(12,15,"1. View index storage/extent information")
 CALL text(14,15,"2. Modify parameters of a index")
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
   GO TO choose_index_loop
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
#choose_index_loop
 CALL choose_index(4)
 CALL ask_tablespace_continue(1)
 IF (continue2="N")
  GO TO choose_index_loop
 ENDIF
 CALL get_subscript(index_name2)
#ask_defaults
 CALL clear(23,60,19)
 CALL show_index_info2(6)
 IF ((ts_req->qual[misc->indx].default="N"))
  CALL enter_index_storage_info2(7)
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
   SET filename2 = concat(cnvtlower(misc->file_name2),"2.ccl")
   SET filename3 = concat(cnvtlower(misc->file_name2),"3.ccl")
   CALL initialize_files(1)
   FOR (cnt = 1 TO misc->row_count2)
     IF ((ts_req->qual[cnt].type=0))
      CALL drop_indexes(ts_req->qual[cnt].index_name,ts_req->qual[cnt].owner)
      CALL create_indexes_tablespace(ts_req->qual[cnt].index_name,ts_req->qual[cnt].owner)
     ELSE
      CALL drop_primary_unique_key(ts_req->qual[cnt].index_name,ts_req->qual[cnt].owner)
      CALL create_primary_unique_key(ts_req->qual[cnt].index_name,ts_req->qual[cnt].owner)
      CALL create_foreign_keys(ts_req->qual[cnt].index_name,ts_req->qual[cnt].owner)
     ENDIF
   ENDFOR
   CALL coalesce_tablespace(tablespace_name2)
   CALL write_run_file(1)
 END ;Subroutine
 SUBROUTINE drop_indexes(index_name5,owner5)
   SELECT INTO value(filename1)
    " "
    FROM dual
    DETAIL
     row + 1, "RDB DROP INDEX ", owner5,
     ".", index_name5, row + 1,
     "GO", row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE drop_primary_unique_key(index_name5,owner5)
   SELECT INTO value(filename1)
    t.name, tu.name
    FROM (sys.obj$ t),
     (sys.cdef$ cdef),
     (sys.con$ con),
     (sys.user$ tu)
    WHERE con.name=index_name5
     AND cdef.con#=con.con#
     AND t.obj#=cdef.obj#
     AND tu.user#=t.owner#
    DETAIL
     row + 1, "RDB ALTER TABLE ", tu.name,
     ".", t.name, row + 1,
     "DROP CONSTRAINT ", index_name5, row + 1,
     " CASCADE", row + 1, "GO",
     row + 1
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
 END ;Subroutine
 SUBROUTINE coalesce_tablespace(tablespace_name3)
   SELECT INTO value(filename1)
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
 SUBROUTINE create_indexes_tablespace(index_name6,owner6)
   SELECT INTO value(filename2)
    col1.name, icol.pos#, o.name,
    ind.unique$, ou.name, iu.name
    FROM (sys.ind$ ind),
     (sys.icol$ icol),
     (sys.col$ col1),
     (sys.obj$ i),
     (sys.obj$ o),
     (sys.user$ iu),
     (sys.user$ ou)
    PLAN (i
     WHERE i.name=index_name6)
     JOIN (ind
     WHERE ind.obj#=i.obj#)
     JOIN (o
     WHERE o.obj#=ind.bo#)
     JOIN (iu
     WHERE iu.user#=i.owner#
      AND iu.name=owner6)
     JOIN (ou
     WHERE ou.user#=o.owner#)
     JOIN (icol
     WHERE icol.obj#=ind.obj#)
     JOIN (col1
     WHERE col1.col#=icol.col#
      AND col1.obj#=icol.bo#)
    ORDER BY icol.pos#
    HEAD REPORT
     row + 1, namei = concat(trim(iu.name),".",trim(i.name)), nameo = concat(trim(ou.name),".",trim(o
       .name))
    HEAD i.name
     row + 1, "RDB CREATE "
     IF (ind.unique$=1)
      "UNIQUE "
     ENDIF
     "INDEX ", namei, row + 1,
     col 20, "ON ", nameo,
     row + 1, col 30, "("
    DETAIL
     IF (icol.pos# > 1)
      ","
     ENDIF
     row + 1, col 30, col1.name
    FOOT  i.name
     row + 1, col 30, ")",
     row + 1
     IF ((ts_req->qual[cnt].default="N"))
      col 2, "TABLESPACE ", ts_req->qual[cnt].tablespace_name,
      row + 1, col 2, "STORAGE (INITIAL ",
      col 19, ts_req->qual[cnt].initial_extent, col 41,
      "NEXT ", col 47, ts_req->qual[cnt].next_extent,
      row + 1, col 2, "MINEXTENTS ",
      col 13, ts_req->qual[cnt].min_extents, col 29,
      "MAXEXTENTS ", col 41, ts_req->qual[cnt].max_extents,
      row + 1, col 2, "PCTINCREASE ",
      col 15, ts_req->qual[cnt].pct_increase, col 29,
      "FREELISTS ", col 38, ts_req->qual[cnt].freelists,
      row + 1, col 2, "FREELIST GROUPS ",
      col 17, ts_req->qual[cnt].freelist_groups, row + 1,
      col 2, ")", row + 1,
      col 2, "PCTFREE ", col 11,
      ts_req->qual[cnt].pct_free, col 29, "INITRANS ",
      col 38, ts_req->qual[cnt].ini_trans, row + 1,
      col 2, "MAXTRANS ", col 11,
      ts_req->qual[cnt].max_trans, row + 1
     ELSE
      col 2, "TABLESPACE ", default->tablespace_name,
      row + 1, col 2, "STORAGE (INITIAL ",
      col 19, default->initial_extent, col 41,
      "NEXT ", col 47, default->next_extent,
      row + 1, col 2, "MINEXTENTS ",
      col 13, default->min_extents, col 29,
      "MAXEXTENTS ", col 41, default->max_extents,
      row + 1, col 2, "PCTINCREASE ",
      col 15, default->pct_increase, col 29,
      "FREELISTS ", col 38, default->freelists,
      row + 1, col 2, "FREELIST GROUPS ",
      col 17, default->freelist_groups, row + 1,
      col 2, ")", row + 1,
      col 2, "PCTFREE ", col 11,
      default->pct_free, col 29, "INITRANS ",
      col 38, default->ini_trans, row + 1,
      col 2, "MAXTRANS ", col 11,
      default->max_trans, row + 1
     ENDIF
     row + 1
     IF ((misc->unrecoverable="Y"))
      col 2, "UNRECOVERABLE", row + 1
     ENDIF
     row + 1, "go", row + 2,
     "execute oragen3 '", ts_req->qual[cnt].index_name, "' GO"
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_primary_unique_key(index_name8,owner8)
   SELECT INTO value(filename2)
    t.name, col1.name, ccol.pos#,
    tu.name
    FROM (sys.obj$ t),
     (sys.cdef$ cdef),
     (sys.col$ col1),
     (sys.ccol$ ccol),
     (sys.con$ con),
     (sys.user$ tu)
    WHERE con.name=index_name8
     AND ccol.con#=con.con#
     AND cdef.con#=con.con#
     AND t.obj#=cdef.obj#
     AND tu.user#=t.owner#
     AND col1.obj#=ccol.obj#
     AND col1.col#=ccol.col#
    ORDER BY t.name, ccol.pos#
    HEAD REPORT
     row + 1, namet = concat(trim(tu.name),".",trim(t.name))
    HEAD t.name
     "RDB ALTER TABLE ", col 20, namet,
     row + 1, col 5, " ADD CONSTRAINT ",
     index_name8, row + 1
     IF ((ts_req->qual[cnt].type=2))
      col 10, " PRIMARY KEY ("
     ELSE
      col 10, " UNIQUE ("
     ENDIF
    DETAIL
     IF (ccol.pos# > 1)
      ","
     ENDIF
     row + 1, col 10, col1.name
    FOOT  t.name
     row + 1, col 10, ")",
     row + 1
     IF ((ts_req->qual[cnt].default="N"))
      col 10, " USING INDEX TABLESPACE ", ts_req->qual[cnt].tablespace_name,
      " ", row + 1, col 2,
      "PCTFREE ", col 15, ts_req->qual[cnt].pct_free,
      row + 1, col 2, "INITRANS ",
      col 15, ts_req->qual[cnt].ini_trans, row + 1,
      col 2, "MAXTRANS ", col 15,
      ts_req->qual[cnt].max_trans, row + 1, col 2,
      "STORAGE (INITIAL ", col 19, ts_req->qual[cnt].initial_extent";;i",
      row + 1, col 11, "NEXT ",
      col 17, ts_req->qual[cnt].next_extent";;i", row + 1,
      col 11, "MINEXTENTS ", col 23,
      ts_req->qual[cnt].min_extents";;i", row + 1, col 11,
      "MAXEXTENTS ", col 23, ts_req->qual[cnt].max_extents";;i",
      row + 1, col 11, "PCTINCREASE ",
      col 22, ts_req->qual[cnt].pct_increase";;i"
     ELSE
      col 10, " USING INDEX TABLESPACE ", default->tablespace_name,
      " ", row + 1, col 2,
      "PCTFREE ", col 15, default->pct_free,
      row + 1, col 2, "INITRANS ",
      col 15, default->ini_trans, row + 1,
      col 2, "MAXTRANS ", col 15,
      default->max_trans, row + 1, col 2,
      "STORAGE (INITIAL ", col 19, default->initial_extent";;i",
      row + 1, col 11, "NEXT ",
      col 17, default->next_extent";;i", row + 1,
      col 11, "MINEXTENTS ", col 23,
      default->min_extents";;i", row + 1, col 11,
      "MAXEXTENTS ", col 23, default->max_extents";;i",
      row + 1, col 11, "PCTINCREASE ",
      col 22, default->pct_increase";;i"
     ENDIF
     row + 1, col 10, ")",
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE create_foreign_keys(index_name19,owner19)
   SELECT INTO value(filename3)
    col1.name, ccol.pos#, t.name,
    fcon.name, cdef.enabled, ta.name,
    tu.name, tau.name
    FROM (sys.ccol$ ccol),
     (sys.col$ col1),
     (sys.con$ fcon),
     (sys.con$ pcon),
     (sys.obj$ t),
     (sys.cdef$ cdef),
     (sys.obj$ ta),
     (sys.user$ tu),
     (sys.user$ tau)
    WHERE pcon.name=index_name19
     AND cdef.rcon#=pcon.con#
     AND fcon.con#=cdef.con#
     AND ta.obj#=cdef.robj#
     AND t.obj#=cdef.obj#
     AND tau.user#=ta.owner#
     AND tu.user#=t.owner#
     AND ccol.con#=cdef.con#
     AND col1.obj#=ccol.obj#
     AND col1.col#=ccol.col#
    ORDER BY fcon.name, ccol.pos#
    HEAD REPORT
     ";****************************************************************************", row + 1,
     ";this section rebuilds the foreign key constraint referencing the target index",
     row + 1, ";****************************************************************************", row +
     1
    HEAD fcon.name
     namet = concat(trim(tu.name),".",trim(t.name)), nameta = concat(trim(tau.name),".",trim(ta.name)
      ), "RDB ALTER TABLE ",
     col 20, namet, row + 1,
     col 20, " ADD CONSTRAINT ", fcon.name,
     row + 1, col 30, " FOREIGN KEY ("
    DETAIL
     IF (ccol.pos# > 1)
      ","
     ENDIF
     row + 1, col 10, col1.name
    FOOT  fcon.name
     row + 1, col 10, ")",
     row + 1, col 10, " REFERENCES ",
     nameta
     IF (cdef.enabled=null)
      "DISABLE"
     ENDIF
     row + 1, "go", row + 1
    WITH format = stream, noheading, append,
     formfeed = none, maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE get_subscript(index_name3)
   FOR (cnt = 1 TO misc->row_count2)
     IF ((ts_req->qual[cnt].index_name=index_name2))
      SET misc->indx = cnt
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE show_index_info2(u)
   CALL clear(05,03,70)
   CALL clear(07,03,70)
   CALL text(04,03,"DATABASE: ")
   CALL text(04,14,trim(database_name2))
   CALL text(04,35,"Tablespace Name:")
   CALL text(04,53,trim(tablespace_name2))
   CALL text(06,03,concat("INDEX: ",index_name2))
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
    CALL text(10,3,concat("FREELISTS: ",cnvtstring(ts_req->qual[misc->indx].freelists)))
    CALL text(10,24,concat("FREELIST GROUPS: ",cnvtstring(ts_req->qual[misc->indx].freelist_groups)))
    CALL text(11,3,concat("INI TRANS: ",cnvtstring(ts_req->qual[misc->indx].ini_trans)))
    CALL text(11,24,concat("MAX TRANS: ",cnvtstring(ts_req->qual[misc->indx].max_trans)))
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
    CALL text(10,3,concat("FREELISTS: ",cnvtstring(default->freelists)))
    CALL text(10,24,concat("FREELIST GROUPS: ",cnvtstring(default->freelist_groups)))
    CALL text(11,3,concat("INI TRANS: ",cnvtstring(default->ini_trans)))
    CALL text(11,24,concat("MAX TRANS: ",cnvtstring(default->max_trans)))
   ENDIF
 END ;Subroutine
 SUBROUTINE enter_index_storage_info2(eisi)
   SET temp_ts = fillstring(30," ")
   SET ts_count = 0
   SET temp_initial = 0
   SET temp_next = 0
   CALL text(13,15,"Use default storage parameters:")
   CALL text(14,3,"Enter new values for the index:")
   CALL text(15,3,"TABLESPACE: ")
   CALL text(16,3,"INITIAL: ")
   CALL text(16,24,"B/K/M")
   CALL text(16,45,"NEXT: ")
   CALL text(16,63,"B/K/M")
   CALL text(17,3,"MIN EXTENTS: ")
   CALL text(17,24,"MAX EXTENTS: ")
   CALL text(18,3,"PCTINCREASE: ")
   CALL text(18,24,"PCT FREE: ")
   CALL text(19,3,"FREELISTS: ")
   CALL text(19,24,"FREELIST GROUPS: ")
   CALL text(20,3,"INI TRANS: ")
   CALL text(20,24,"MAX TRANS: ")
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
     CALL text(15,20,"applying them to indexes.")
     CALL ask_tablespace_continue(1)
     IF (continue2="N")
      GO TO screen_5
     ELSE
      CALL clear(5,2,70)
      GO TO screen_5
     ENDIF
    ENDIF
   ENDIF
   SET done = "N"
   WHILE (done="N")
     CALL clear(23,60,19)
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL text(23,05,"HELP: Press <SHIFT><F5> ")
       SET help =
       SELECT INTO "nl:"
        a.tablespace_name
        FROM user_tablespaces a
        WHERE a.tablespace_name="I_*"
        ORDER BY a.tablespace_name
        WITH nocounter
       ;end select
       CALL accept(15,16,"PPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS",ts_req->qual[misc->indx].original_ts)
       SET ts_req->qual[misc->indx].tablespace_name = curaccept
       IF ((ts_req->qual[misc->indx].tablespace_name="          "))
        CALL clear(24,5,74)
        CALL text(24,5,"Tablespace name required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     CALL clear(23,60,19)
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(16,12,"9999999999",ts_req->qual[misc->indx].initial_extent)
       SET temp_initial = curaccept
       IF (temp_initial <= 0)
        CALL clear(24,05,74)
        CALL text(24,05,"Initial extent size required...")
       ELSE
        CALL clear(24,05,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
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
       IF (temp_next=0)
        CALL clear(24,5,74)
        CALL text(24,5,"Next extent size required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
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
       IF ((ts_req->qual[misc->indx].min_extents <= 0))
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
        IF (text2 != "UNLIMITED")
         CALL clear(24,5,74)
         CALL text(24,5,"Max extents should be > 0 or UNLIMITED...")
        ELSE
         CALL clear(24,5,74)
         SET continue2 = "Y"
         SET ts_req->qual[misc->indx].max_extents = 2147483645
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
       IF ((ts_req->qual[misc->indx].pct_free <= 0))
        CALL clear(24,5,74)
        CALL text(24,5,"Pct Free parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(19,14,"999999999",ts_req->qual[misc->indx].freelists)
       SET ts_req->qual[misc->indx].freelists = curaccept
       IF ((ts_req->qual[misc->indx].freelists <= 0))
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
       IF ((ts_req->qual[misc->indx].freelist_groups <= 0))
        CALL clear(24,5,74)
        CALL text(24,5,"Freelist Groups parameter required...")
       ELSE
        CALL clear(24,5,74)
        SET continue2 = "Y"
       ENDIF
     ENDWHILE
     SET continue2 = "N"
     WHILE (continue2="N")
       CALL accept(20,14,"999999999",ts_req->qual[misc->indx].ini_trans)
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
       CALL accept(20,35,"999999999",ts_req->qual[misc->indx].max_trans)
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
      CALL enter_index_storage_info2(12)
     ELSE
      SET done = "Y"
      CALL clear(5,2,70)
      GO TO screen_5
     ENDIF
     CALL pause(5)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE choose_index(ci)
   CALL box(1,1,22,80)
   CALL box(1,1,03,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD INDEX TABLESPACE  *** ")
   CALL text(04,03,"DATABASE: ")
   CALL text(04,14,trim(database_name2))
   CALL text(04,35,"Tablespace Name:")
   CALL text(04,53,trim(tablespace_name2))
   CALL text(07,03,"Index Name: ")
   CALL clear(23,05,74)
   CALL text(23,05,"HELP: PRESS <SHIFT><F5> ")
   SET help =
   SELECT INTO "nl:"
    c.index_name
    FROM dba_indexes c
    WHERE c.tablespace_name=tablespace_name2
    ORDER BY c.index_name
    WITH nocounter
   ;end select
   SET validate =
   SELECT INTO "nl:"
    c.index_name
    FROM dba_indexes c
    WHERE c.tablespace_name=tablespace_name2
     AND c.index_name=curaccept
    WITH nocounter
   ;end select
   SET validate = 1
   CALL accept(07,16,"P(30);CUS","            ")
   SET index_name2 = curaccept
   CALL clear(23,05,74)
   SET help = off
   SET validate = off
 END ;Subroutine
 SUBROUTINE display_tablespace_screen(dts)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,3,80)
   CALL clear(2,2,78)
   CALL text(02,19," ***  DBA  REBUILD INDEX TABLESPACE  *** ")
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
   CALL text(02,19," ***  DBA  REBUILD INDEX TABLESPACE  *** ")
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
    b.index_name, b.initial_extent, b.next_extent,
    b.tablespace_name, b.min_extents, b.max_extents,
    b.pct_increase, b.ini_trans, b.max_trans,
    b.pct_free, b.freelists, b.freelist_groups
    FROM dba_segments a,
     dba_indexes b
    WHERE b.tablespace_name=a.tablespace_name
     AND a.tablespace_name=tablespace_name2
     AND b.index_name=a.segment_name
    ORDER BY b.index_name
    HEAD REPORT
     line = fillstring(80,"=")
    HEAD PAGE
     col 2, "Index Name", col 35,
     "Grand totals for the tablespace are at the bottom", row + 1
    DETAIL
     col 2, b.index_name, row + 1,
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
     "Total# of Blocks", col + 4, a.blocks,
     row + 1, col 10, "Min:",
     col 30, b.min_extents"########", col 55,
     "Free lists:", col 72, b.freelists"########",
     col 85, "Total # of Extents:", col + 1,
     a.extents, row + 1, max = (b.max_extents/ 1024),
     col 10, "Max (KB):", col 30,
     max"########", col 55, "Free list groups:",
     col 72, b.freelist_groups"########", row + 1,
     col 10, "Pct Incr:", col 30,
     b.pct_increase"########", row + 1, col 10,
     "Pct Free:", col 30, b.pct_free,
     row + 2
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
   SELECT INTO value(filename1)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section drops all objects in the ts and coalesces the ts",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename2)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section recreates the indexes and primary keys in the ts",
     row + 1, "***************************************************************/"
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
   SELECT INTO value(filename3)
    " "
    FROM dual
    DETAIL
     "/***************************************************************", row + 1,
     ";this section recreates the foreign keys referencing the ts",
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
   CALL accept(10,21,"X(30);C","   ")
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
   SET filename2 = concat(cnvtlower(misc->file_name2),"2")
   SET filename3 = concat(cnvtlower(misc->file_name2),"3")
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,3,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  REBUILD INDEX TABLESPACE  *** ")
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
   CALL text(8,35,"---> Drop indexes and coalesce tablespace")
   CALL text(9,08,concat(filename2,".CCL"))
   CALL text(9,35,"---> Recreate indexes")
   CALL text(10,08,concat(filename3,".CCL"))
   CALL text(10,35,"---> Recreate foreign keys on indexes")
   CALL text(11,08,concat(filenamerun,".CCL"))
   CALL text(11,35,"---> Master run file")
   CALL video(b)
   CALL text(19,25,"Scripts have been generated!")
   CALL video(n)
   CALL text(21,4,concat("NOTE:Include master run file to execute (CCL>%i ",filenamerun,".CCL)"))
   CALL clear(23,04,50)
   CALL ask_tablespace_continue(23)
   IF (continue2="Y")
    GO TO end_program
   ELSE
    GO TO end_program
   ENDIF
 END ;Subroutine
 SUBROUTINE ask_unrecoverable(aunr)
   CALL clear(12,15,50)
   CALL clear(14,15,50)
   CALL clear(16,15,50)
   CALL clear(18,15,50)
   CALL clear(20,15,50)
   CALL clear(23,15,50)
   CALL text(18,15,"Would you like indexes built unrecoverable?")
   CALL text(23,15,"Your selection: ")
   CALL accept(23,32,"P;CUS","N"
    WHERE curaccept IN ("Y", "N"))
   SET continue2 = curaccept
   IF (continue2="Y")
    SET misc->unrecoverable = "Y"
   ENDIF
 END ;Subroutine
#enter_defaults_label
 SUBROUTINE ask_default_values(sadv)
   SET default->owner = fillstring(30," ")
   SET default->tablespace_name = fillstring(30," ")
   SET default->original_ts = tablespace_name2
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
   SET default->freelists = 0
   SET default->freelist_groups = 0
   CALL box(1,1,22,80)
   CALL box(1,1,03,80)
   CALL clear(2,2,78)
   CALL text(02,19," ***  DBA  REBUILD INDEX TABLESPACE  *** ")
   CALL text(04,03,"DATABASE: ")
   CALL text(04,14,trim(database_name2))
   CALL text(04,35,"Tablespace Name:")
   CALL text(04,53,trim(tablespace_name2))
   CALL text(07,20,"Please set the default parameters:")
   CALL text(08,20,"These parameters can be applied to any or")
   CALL text(09,20,"all of the indexes in the tablespace.")
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
   CALL text(19,3,"FREELISTS: ")
   CALL text(19,24,"FREELIST GROUPS: ")
   CALL text(20,3,"INI TRANS: ")
   CALL text(20,24,"MAX TRANS: ")
   CALL clear(23,60,19)
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL text(23,05,"HELP: Press <SHIFT><F5> ")
     SET help =
     SELECT INTO "nl:"
      a.tablespace_name
      FROM user_tablespaces a
      WHERE a.tablespace_name != "SYSTEM"
       AND a.tablespace_name != "MISC"
       AND a.tablespace_name != "TEMP"
       AND a.tablespace_name != "RB*"
      ORDER BY a.tablespace_name
      WITH nocounter
     ;end select
     CALL accept(15,16,"PPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS",default->original_ts)
     SET default->tablespace_name = curaccept
     IF ((default->tablespace_name="          "))
      CALL clear(24,5,74)
      CALL text(24,5,"Tablespace name required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   CALL clear(23,60,19)
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(16,12,"9999999999",default->initial_extent)
     SET temp_initial = curaccept
     IF (temp_initial <= 0)
      CALL clear(24,05,74)
      CALL text(24,05,"Initial extent size required...")
     ELSE
      CALL clear(24,05,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(16,30,"P;CUS",default->initial_units)
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
     CALL accept(16,51,"99999999999",default->next_extent)
     SET temp_next = curaccept
     IF (temp_next=0)
      CALL clear(24,5,74)
      CALL text(24,5,"Next extent size required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(16,69,"P;CUS",default->next_units)
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
     CALL accept(17,16,"999",default->min_extents)
     SET default->min_extents = curaccept
     IF ((default->min_extents <= 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Min extents parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   SET text2 = cnvtstring(default->max_extents)
   WHILE (continue2="N")
     CALL accept(17,37,"PPPPPPPPP;CUS",text2)
     SET text2 = curaccept
     IF (cnvtint(text2) <= 0)
      IF (text2 != "UNLIMITED")
       CALL clear(24,5,74)
       CALL text(24,5,"Max extents should be > 0 or UNLIMITED...")
      ELSE
       CALL clear(24,5,74)
       SET continue2 = "Y"
       SET default->max_extents = 2147483645
      ENDIF
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
      SET default->max_extents = cnvtint(text2)
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(18,16,"999",default->pct_increase)
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
     CALL accept(18,34,"999",default->pct_free)
     SET default->pct_free = curaccept
     IF ((default->pct_free <= 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Pct Free parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(19,14,"999999999",default->freelists)
     SET default->freelists = curaccept
     IF ((default->freelists <= 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Freelists parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(19,41,"999999999",default->freelist_groups)
     SET default->freelist_groups = curaccept
     IF ((default->freelist_groups <= 0))
      CALL clear(24,5,74)
      CALL text(24,5,"Freelist Groups parameter required...")
     ELSE
      CALL clear(24,5,74)
      SET continue2 = "Y"
     ENDIF
   ENDWHILE
   SET continue2 = "N"
   WHILE (continue2="N")
     CALL accept(20,14,"999999999",default->ini_trans)
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
     CALL accept(20,35,"999999999",default->max_trans)
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
   CALL text(13,24,"Apply defaults to all indexes:")
   CALL accept(13,54,"P;CUS","N"
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
 SUBROUTINE write_run_file(wrf)
   SELECT INTO value(filenamerun)
    " "
    FROM dual
    DETAIL
     "%i ", filename1, row + 1,
     "%i ", filename2, row + 1,
     "%i ", filename3
    WITH format = stream, noheading, formfeed = none,
     maxcol = 512, maxrow = 1
   ;end select
 END ;Subroutine
#end_program
 CALL clear(1,1)
END GO
