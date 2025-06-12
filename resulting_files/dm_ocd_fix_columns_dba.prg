CREATE PROGRAM dm_ocd_fix_columns:dba
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
 SELECT INTO value(filename2)
  cname = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt)),
   (dummyt u  WITH seq = value(curdb->tbl[u_tbl_ptr].tbl_col_cnt))
  WHERE (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].tbl_col[u.seq].col_name
  )
  DETAIL
   IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type != curdb->tbl[u_tbl_ptr].tbl_col[u.seq].
   data_type))
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, row + 1, "rdb alter table ",
    tbl_name, row + 1, str->str = concat("  modify (",trim(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].
      col_name)),
    str->str, " "
    IF ((curdb->tbl[u_tbl_ptr].tbl_col[u.seq].data_type="NUMBER")
     AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="FLOAT"))
     " FLOAT)", row + 1
    ELSE
     len = greatest(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_length,curdb->tbl[u_tbl_ptr].tbl_col[u
      .seq].data_length), str->str = build(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type,"(",len,
      "))"), str->str,
     row + 1
    ENDIF
    "go", row + 1, row + 1,
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, errstr = concat(
     '"alter table ',trim(tbl_name)," modify column ",trim(cname),'" go'),
    "set error_msg= ", errstr, row + 1,
    'set rstring = "" go', row + 1, 'set rstring1 = "" go',
    row + 1, "execute dm_check_errors go", row + 1,
    row + 1, reset_error = 1
   ENDIF
   IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_length > curdb->tbl[u_tbl_ptr].tbl_col[u.seq].
   data_length)
    AND (((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="VARCHAR2")) OR ((((bn_ocd->tbl[d_tbl_ptr]
   .tbl_col[d.seq].data_type="VARCHAR")) OR ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="CHAR")
   )) )) )
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
    row + 1, row + 1, "rdb alter table ",
    tbl_name, row + 1, str->str = concat("  modify (",trim(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].
      col_name)),
    str->str, " ", str->str = build(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type,"(",bn_ocd->tbl[
     d_tbl_ptr].tbl_col[d.seq].data_length,"))"),
    str->str, row + 1, "go",
    row + 1, row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go',
    row + 1, errstr = concat('"alter table ',trim(tbl_name)," modify column ",trim(cname),'" go'),
    "set error_msg= ",
    errstr, row + 1, 'set rstring = "" go',
    row + 1, 'set rstring1 = "" go', row + 1,
    "execute dm_check_errors go", row + 1, row + 1,
    reset_error = 1
   ENDIF
  WITH format = variable, formfeed = none, noheading,
   maxrow = 1, maxcol = 512, append
 ;end select
 FREE RECORD col_list
 RECORD col_list(
   1 qual[*]
     2 col_name = vc
   1 knt = i2
 )
 SET col_list->knt = 0
 SET stat = alterlist(col_list->qual,0)
 SELECT INTO value(filename2)
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt))
  HEAD REPORT
   col_list->knt = 0, stat = alterlist(col_list->qual,10)
  DETAIL
   found = 0
   FOR (i = 1 TO curdb->tbl[u_tbl_ptr].tbl_col_cnt)
     IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name=curdb->tbl[u_tbl_ptr].tbl_col[i].col_name))
      found = i, i = curdb->tbl[u_tbl_ptr].tbl_col_cnt
     ENDIF
   ENDFOR
   IF (found=0)
    col_list->knt = (col_list->knt+ 1), stat = alterlist(col_list->qual,col_list->knt), col_list->
    qual[col_list->knt].col_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name
    IF ((col_list->knt=1))
     'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
     row + 1, row + 1, "rdb alter table ",
     tbl_name, row + 1, "  add ("
    ENDIF
    IF ((col_list->knt > 1))
     ","
    ENDIF
    row + 1, col 5, bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
    col 45, bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type
    IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="VARCHAR2")) OR ((((bn_ocd->tbl[d_tbl_ptr]
    .tbl_col[d.seq].data_type="CHAR")) OR ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="VARCHAR"
    ))) )) )
     col 55, "(", col 56,
     bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_length"####;;I", col 61, ")"
    ENDIF
   ENDIF
  FOOT REPORT
   IF ((col_list->knt > 0))
    row + 1, ") go", row + 1,
    row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
    errstr = concat('"alter table ',trim(tbl_name),' add columns" go'), "set error_msg= ", errstr,
    row + 1, 'set rstring = "" go', row + 1,
    'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
    row + 1, row + 1, reset_error = 1
   ENDIF
  WITH format = variable, formfeed = none, noheading,
   maxrow = 1, maxcol = 512, append
 ;end select
 FREE RECORD dvalue
 RECORD dvalue(
   1 default = vc
 )
 SELECT INTO value(filename2)
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt))
  ORDER BY bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_seq
  HEAD REPORT
   cnt = 0
  DETAIL
   new_default = 0, u_ptr = 0
   FOR (i = 1 TO col_list->knt)
     IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name=col_list->qual[i].col_name))
      new_default = i, i = col_list->knt
     ENDIF
   ENDFOR
   IF (new_default > 0)
    IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default="")) OR ((bn_ocd->tbl[d_tbl_ptr].
    tbl_col[d.seq].data_default="NULL"))) )
     IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable="N"))
      IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="FLOAT")) OR ((bn_ocd->tbl[d_tbl_ptr].
      tbl_col[d.seq].data_type="NUMBER"))) )
       dvalue->default = "0"
      ELSEIF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="DATE"))
       dvalue->default = "to_date('1/1/1900','MM/DD/YYYY')"
      ELSE
       dvalue->default = "' '"
      ENDIF
     ELSE
      dvalue->default = "NULL"
     ENDIF
    ELSE
     dvalue->default = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default
    ENDIF
   ELSE
    FOR (i = 1 TO curdb->tbl[u_tbl_ptr].tbl_col_cnt)
      IF ((curdb->tbl[u_tbl_ptr].tbl_col[i].col_name=bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name))
       u_ptr = i, i = curdb->tbl[u_tbl_ptr].tbl_col_cnt
      ENDIF
    ENDFOR
    IF (u_ptr > 0)
     IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default != curdb->tbl[u_tbl_ptr].tbl_col[u_ptr
     ].data_default)
      AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default != "")
      AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default != "NULL")) OR ((bn_ocd->tbl[d_tbl_ptr]
     .tbl_col[d.seq].nullable="N")
      AND (curdb->tbl[u_tbl_ptr].tbl_col[u_ptr].nullable="Y"))) )
      new_default = u_ptr
      IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default="")) OR ((bn_ocd->tbl[d_tbl_ptr].
      tbl_col[d.seq].data_default="NULL"))) )
       IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable="N"))
        IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="FLOAT")) OR ((bn_ocd->tbl[d_tbl_ptr].
        tbl_col[d.seq].data_type="NUMBER"))) )
         dvalue->default = "0"
        ELSEIF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="DATE"))
         dvalue->default = "to_date('1/1/1900','MM/DD/YYYY')"
        ELSE
         dvalue->default = "' '"
        ENDIF
       ELSEIF ((((curdb->tbl[u_tbl_ptr].tbl_col[u_ptr].data_default != "")) OR ((curdb->tbl[u_tbl_ptr
       ].tbl_col[u_ptr].data_default != "NULL"))) )
        dvalue->default = curdb->tbl[u_tbl_ptr].tbl_col[u_ptr].data_default
       ELSE
        dvalue->default = "NULL"
       ENDIF
      ELSE
       dvalue->default = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (new_default > 0)
    cnt = (cnt+ 1)
    IF (cnt=1)
     'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, "set error_reported = 0 go",
     row + 1, row + 1, "rdb alter table ",
     tbl_name, row + 1, "  modify ("
    ENDIF
    IF (cnt > 1)
     ","
    ENDIF
    row + 1, col 5, bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
    col 45, " DEFAULT ", dvalue->default
   ENDIF
  FOOT REPORT
   IF (cnt > 0)
    row + 1, ") go", row + 1,
    row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
    errstr = concat('"alter table ',trim(tbl_name),' modify default values" go'), "set error_msg= ",
    errstr,
    row + 1, 'set rstring = "" go', row + 1,
    'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
    row + 1, row + 1, reset_error = 1
   ENDIF
  WITH format = variable, formfeed = none, noheading,
   maxrow = 1, maxcol = 512, append
 ;end select
END GO
