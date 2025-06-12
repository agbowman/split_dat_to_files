CREATE PROGRAM dm_ocd_fix_columns_null:dba
 SET tbl_name = fillstring(30," ")
 SET d_tbl_ptr =  $1
 SET u_tbl_ptr =  $2
 SET tbl_name = bn_ocd->tbl[d_tbl_ptr].tbl_name
 SET d_ptr = 0
 SET u_ptr = 0
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 SET default_value = fillstring(40," ")
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 SELECT INTO value(filename2)
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt)),
   (dummyt u  WITH seq = value(curdb->tbl[u_tbl_ptr].tbl_col_cnt))
  PLAN (d
   WHERE (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable="Y"))
   JOIN (u
   WHERE (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].tbl_col[u.seq].
   col_name)
    AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable != curdb->tbl[u_tbl_ptr].tbl_col[u.seq].
   nullable))
  ORDER BY bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name
  HEAD REPORT
   'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
   row + 1, row + 1, "rdb alter table ",
   bn_ocd->tbl[d_tbl_ptr].tbl_name, row + 1, "modify (",
   cnum = 0
  DETAIL
   cnum = (cnum+ 1)
   IF (cnum > 1)
    ","
   ENDIF
   row + 1, bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name, " NULL"
  FOOT REPORT
   row + 1, ") go", row + 1,
   row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
   errstr = concat('"alter table ',trim(bn_ocd->tbl[d_tbl_ptr].tbl_name),
    ' modify columns to NULLable" go'), "set error_msg= ", errstr,
   row + 1, 'set rstring = "" go', row + 1,
   'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
   row + 2, reset_error = 1
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 150, maxrow = 1, append
 ;end select
END GO
