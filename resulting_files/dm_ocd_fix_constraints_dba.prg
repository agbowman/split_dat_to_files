CREATE PROGRAM dm_ocd_fix_constraints:dba
 SET tbl_name = fillstring(30," ")
 SET d_tbl_ptr =  $1
 SET u_tbl_ptr =  $2
 SET cons_type =  $3
 SET tbl_name = bn_ocd->tbl[d_tbl_ptr].tbl_name
 SET d_ptr = 0
 SET u_ptr = 0
 SET match_cols = 0
 FREE RECORD cons
 RECORD cons(
   1 cnt = i4
   1 qual[*]
     2 u_ptr = i4
     2 create_ind = i2
 )
 SET cons->cnt = 0
 SET stat = alterlist(cons->qual,bn_ocd->tbl[d_tbl_ptr].cons_cnt)
 SET errstr = fillstring(110," ")
 FOR (ccnt = 1 TO bn_ocd->tbl[d_tbl_ptr].cons_cnt)
   IF ((bn_ocd->tbl[d_tbl_ptr].cons[ccnt].cons_type=cons_type))
    SET d_ptr = ccnt
    SET u_ptr = 0
    SET cons->qual[d_ptr].create_ind = 0
    SET cons->qual[d_ptr].u_ptr = 0
    IF (u_tbl_ptr > 0)
     FOR (i = 1 TO curdb->tbl[u_tbl_ptr].cons_cnt)
       IF ((curdb->tbl[u_tbl_ptr].cons[i].cons_name=bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_name)
        AND (curdb->tbl[u_tbl_ptr].cons[i].cons_type=bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_type))
        SET u_ptr = i
        SET i = curdb->tbl[u_tbl_ptr].cons_cnt
       ENDIF
     ENDFOR
     IF (u_ptr=0)
      FOR (i = 1 TO curdb->tbl[u_tbl_ptr].cons_cnt)
        IF ((curdb->tbl[u_tbl_ptr].cons[i].cons_type=cons_type))
         SET match_cols = 0
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col_cnt)),
           (dummyt u  WITH seq = value(curdb->tbl[u_tbl_ptr].cons[i].cons_col_cnt))
          WHERE (bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_position=curdb->tbl[u_tbl_ptr
          ].cons[i].cons_col[u.seq].col_position)
          ORDER BY bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_position
          DETAIL
           IF ((bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].
           cons[i].cons_col[u.seq].col_name))
            match_cols = (match_cols+ 1)
           ENDIF
          WITH nocounter
         ;end select
         IF ((match_cols=bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col_cnt)
          AND (match_cols=curdb->tbl[u_tbl_ptr].cons[i].cons_col_cnt))
          SET u_ptr = i
          SET i = curdb->tbl[u_tbl_ptr].cons_cnt
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    IF (u_ptr=0)
     SET cons->qual[d_ptr].create_ind = 1
    ELSE
     CALL echo(build("Found cons:",curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name))
     CALL echo("***")
     SET cons->qual[d_ptr].u_ptr = u_ptr
     SET match_cols = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col_cnt)),
       (dummyt u  WITH seq = value(curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_col_cnt))
      WHERE (bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_position=curdb->tbl[u_tbl_ptr].
      cons[u_ptr].cons_col[u.seq].col_position)
      ORDER BY bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_position
      DETAIL
       IF ((bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].cons[
       u_ptr].cons_col[u.seq].col_name))
        match_cols = (match_cols+ 1)
       ENDIF
      WITH nocounter
     ;end select
     CALL echo(build("match_cols=",match_cols))
     CALL echo("***")
     IF ((((bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_name != curdb->tbl[u_tbl_ptr].cons[u_ptr].
     cons_name)) OR ((bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col_cnt != match_cols))) )
      SET cons->qual[d_ptr].create_ind = 1
      SELECT INTO value(filename2)
       *
       FROM dual
       DETAIL
        "rdb alter table ", curdb->tbl[u_tbl_ptr].tbl_name, row + 1,
        "  drop constraint ", curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name, row + 1,
        "go", row + 1
       WITH format = stream, noheading, formfeed = none,
        maxcol = 512, maxrow = 1, append
      ;end select
     ELSEIF ((curdb->tbl[u_tbl_ptr].cons[u_ptr].status_ind=0)
      AND cons_type="P")
      SET dropped_ind = 0
      FOR (k = 1 TO d_cons->cons_cnt)
        IF ((curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name=d_cons->cons[k].cons_name))
         SET dropped_ind = 1
         SET k = d_cons->cons_cnt
        ENDIF
      ENDFOR
      IF (dropped_ind=0)
       SET cons->qual[d_ptr].create_ind = 0
       SELECT INTO value(filename2)
        *
        FROM dual
        DETAIL
         "set msgnum=error(msg,1) go", row + 1, "set error_reported = 0 go",
         row + 1, row + 1, "rdb alter table ",
         curdb->tbl[u_tbl_ptr].tbl_name, row + 1, "enable constraint ",
         curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name, row + 1, "go",
         row + 1, row + 1, "set msgnum=error(msg,1) go",
         row + 1, errstr = concat('"alter table ',trim(curdb->tbl[u_tbl_ptr].tbl_name),
          " enable constraint ",trim(curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name),'" go'),
         "set error_msg= ",
         errstr, row + 1, 'set rstring = "" go',
         row + 1, 'set rstring1 = "" go', row + 1,
         "execute dm_check_errors go", row + 2, reset_error = 1
        WITH format = stream, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
     ELSEIF ((curdb->tbl[u_tbl_ptr].cons[u_ptr].status_ind=1)
      AND cons_type="R")
      SET dropped_ind = 0
      FOR (k = 1 TO d_cons->cons_cnt)
        IF ((curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name=d_cons->cons[k].cons_name))
         SET dropped_ind = 1
         SET k = d_cons->cons_cnt
        ENDIF
      ENDFOR
      IF (dropped_ind=0)
       SET cons->qual[d_ptr].create_ind = 0
       SELECT INTO value(filename2)
        *
        FROM dual
        DETAIL
         "set msgnum=error(msg,1) go", row + 1, "set error_reported = 0 go",
         row + 1, row + 1, "rdb alter table ",
         curdb->tbl[u_tbl_ptr].tbl_name, row + 1, "disable constraint ",
         curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name, row + 1, "go",
         row + 1, "set msgnum=error(msg,1) go", row + 1,
         errstr = concat('"alter table ',trim(curdb->tbl[u_tbl_ptr].tbl_name)," disable constraint ",
          trim(curdb->tbl[u_tbl_ptr].cons[u_ptr].cons_name),'" go'), "set error_msg= ", errstr,
         row + 1, 'set rstring = "" go', row + 1,
         'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
         row + 2, reset_error = 1
        WITH format = stream, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (ccnt = 1 TO bn_ocd->tbl[d_tbl_ptr].cons_cnt)
   IF ((bn_ocd->tbl[d_tbl_ptr].cons[ccnt].cons_type=cons_type))
    SET d_ptr = ccnt
    SET u_ptr = cons->qual[d_ptr].u_ptr
    IF ((cons->qual[d_ptr].create_ind=1))
     EXECUTE dm_ocd_create_constraint d_tbl_ptr, d_ptr, 0
     IF (cons_type="P")
      EXECUTE dm_ocd_create_constraint d_tbl_ptr, d_ptr, 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
END GO
