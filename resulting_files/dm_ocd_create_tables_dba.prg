CREATE PROGRAM dm_ocd_create_tables:dba
 SET tbl_name = fillstring(30," ")
 SET d_tbl_ptr =  $1
 SET tbl_name = bn_ocd->tbl[d_tbl_ptr].tbl_name
 SET errstr = fillstring(110," ")
 SET tempstr = fillstring(110," ")
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 SET source_table = fillstring(30," ")
 SET target_table = fillstring(30," ")
 SET from_column[100] = fillstring(80," ")
 SET to_column[100] = fillstring(80," ")
 SET old_base_data_type = fillstring(1," ")
 SET new_base_data_type = fillstring(1," ")
 SET initial_extent = 0
 SET next_extent = 0
 SET bytes = 0
 SELECT INTO value(filename2)
  FROM (dummyt dc  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt))
  ORDER BY bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].col_seq
  HEAD REPORT
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
   row + 1, row + 1, "rdb create table ",
   tbl_name, row + 1, "("
  DETAIL
   IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].col_seq > 1))
    ","
   ENDIF
   row + 1, col 5, bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].col_name,
   col 45, bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].data_type
   IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].data_type="VARCHAR2")) OR ((((bn_ocd->tbl[d_tbl_ptr]
   .tbl_col[dc.seq].data_type="CHAR")) OR ((bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].data_type=
   "VARCHAR"))) )) )
    col 55, "(", col 56,
    bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].data_length"####;;I", col 61, ")"
   ENDIF
   IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].data_default != ""))
    str->str = concat(" DEFAULT ",trim(bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].data_default)), str->
    str
   ENDIF
   IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[dc.seq].nullable="N"))
    " NOT NULL"
   ENDIF
  FOOT REPORT
   row + 1, ") tablespace ", bn_ocd->tbl[d_tbl_ptr].tspace_name,
   row + 1, "go", row + 1,
   row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
   errstr = concat('"create table ',trim(tbl_name),'" go'), "set error_msg = ", errstr,
   row + 1, 'set rstring = "rdb create table ', tbl_name,
   ' go" go', row + 1, 'set rstring1 = "" go',
   row + 1, "execute dm_check_errors go", row + 1,
   row + 1, reset_error = 1, "execute dm_user_last_updt go",
   row + 1, row + 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SET max_cols = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].ind_cnt))
  DETAIL
   max_cols = greatest(max_cols,bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_col_cnt)
  WITH nocounter
 ;end select
 IF (max_cols > 0)
  SELECT INTO value(filename2)
   iname = bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_name
   FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].ind_cnt)),
    (dummyt dc  WITH seq = value(max_cols))
   PLAN (d)
    JOIN (dc
    WHERE (dc.seq <= bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_col_cnt))
   ORDER BY bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_name, bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_col[dc
    .seq].col_position
   HEAD iname
    "rdb drop index ", bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_name, row + 1,
    "go", row + 1, row + 1,
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, row + 1, "rdb create "
    IF ((bn_ocd->tbl[d_tbl_ptr].ind[d.seq].unique_ind=1))
     "UNIQUE"
    ENDIF
    " index ", bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_name, row + 1,
    col 5, "ON ", tbl_name,
    row + 1, col 5, "("
   DETAIL
    IF ((bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_col[dc.seq].col_position > 1))
     ","
    ENDIF
    row + 1, col 10, bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_col[dc.seq].col_name
   FOOT  iname
    row + 1, col 5, ") storage (initial 16k next 8k)",
    row + 1, "unrecoverable", row + 1,
    "tablespace ", bn_ocd->tbl[d_tbl_ptr].ind[d.seq].tspace_name, row + 1,
    "go", row + 1, row + 1,
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
     '"create index ',trim(bn_ocd->tbl[d_tbl_ptr].ind[d.seq].ind_name)," on table ",trim(tbl_name),
     '" go'),
    "set error_msg = ", errstr, row + 1,
    'set rstring = "" go', row + 1, 'set rstring1 = "" go',
    row + 1, "execute dm_check_errors go", row + 1,
    row + 1, reset_error = 1, "execute dm_user_last_updt go",
    row + 1, row + 1
   WITH format = stream, noheading, append,
    formfeed = none, maxcol = 512, maxrow = 1
  ;end select
 ENDIF
 SET max_cols = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].cons_cnt))
  DETAIL
   max_cols = greatest(max_cols,bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_col_cnt)
  WITH nocounter
 ;end select
 IF (max_cols > 0)
  SELECT INTO value(filename2)
   cname = bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_name
   FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].cons_cnt)),
    (dummyt dc  WITH seq = value(max_cols))
   PLAN (d
    WHERE (((bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_type="P")) OR ((bn_ocd->tbl[d_tbl_ptr].cons[d
    .seq].cons_type="U"))) )
    JOIN (dc
    WHERE (dc.seq <= bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_col_cnt))
   ORDER BY bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_name, bn_ocd->tbl[d_tbl_ptr].cons[d.seq].
    cons_col[dc.seq].col_position
   HEAD cname
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, row + 1, "rdb alter table ",
    tbl_name, row + 1, "  add constraint ",
    bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_name, row + 1
    CASE (bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_type)
     OF "P":
      "  primary key ("
     OF "U":
      "  unique ("
    ENDCASE
   DETAIL
    IF ((bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_col[dc.seq].col_position > 1))
     ","
    ENDIF
    row + 1, col 10, bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_col[dc.seq].col_name
   FOOT  cname
    row + 1, "  )"
    IF ((bn_ocd->tbl[d_tbl_ptr].cons[d.seq].status_ind=0))
     " DISABLE"
    ENDIF
    row + 1, "go", row + 1,
    row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1
    CASE (bn_ocd->tbl[d_tbl_ptr].cons[d.seq].cons_type)
     OF "P":
      errstr = concat('"alter table ',trim(tbl_name)," add primary constraint ",trim(bn_ocd->tbl[
        d_tbl_ptr].cons[d.seq].cons_name),'" go')
     OF "U":
      errstr = concat('"alter table ',trim(tbl_name)," add unique constraint ",trim(bn_ocd->tbl[
        d_tbl_ptr].cons[d.seq].cons_name),'" go')
    ENDCASE
    "set error_msg = ", errstr, row + 1,
    'set rstring = "" go', row + 1, 'set rstring1 = "" go',
    row + 1, "execute dm_check_errors go", row + 1,
    row + 1, reset_error = 1, "execute dm_user_last_updt go",
    row + 1, row + 1
   WITH format = stream, noheading, append,
    formfeed = none, maxcol = 512, maxrow = 1
  ;end select
 ENDIF
 SELECT INTO value(filename2)
  FROM dual
  DETAIL
   'execute oragen3 "', tbl_name, '" go',
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, append, maxrow = 1
 ;end select
END GO
