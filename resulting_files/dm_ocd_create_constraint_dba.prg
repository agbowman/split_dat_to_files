CREATE PROGRAM dm_ocd_create_constraint:dba
 SET tbl_name = fillstring(30," ")
 SET d_tbl_ptr =  $1
 SET d_ptr =  $2
 SET tbl_name = bn_ocd->tbl[d_tbl_ptr].tbl_name
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 IF (( $3=0))
  SELECT
   IF (( $1 > 0))
    t_name = bn_ocd->tbl[d_tbl_ptr].tbl_name, c_name = bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_name,
    c_type = bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_type,
    c_status = bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].status_ind, pt_name = bn_ocd->tbl[d_tbl_ptr].cons[
    d_ptr].parent_table, pt_cols = bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].parent_table_columns,
    cc_name = bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_name, cc_pos = bn_ocd->tbl[
    d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_position
    FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col_cnt))
    ORDER BY bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_col[d.seq].col_position
   ELSE
    t_name = d_cons->cons[ $2].tbl_name, c_name = d_cons->cons[ $2].cons_name, c_type = d_cons->cons[
     $2].cons_type,
    c_status = d_cons->cons[ $2].status_ind, pt_name = d_cons->cons[ $2].parent_table, pt_cols =
    d_cons->cons[ $2].parent_table_columns,
    cc_name = d_cons->cons[ $2].cons_col[d.seq].col_name, cc_pos = d_cons->cons[ $2].cons_col[d.seq].
    col_position
    FROM (dummyt d  WITH seq = value(d_cons->cons[ $2].cons_col_cnt))
    ORDER BY d_cons->cons[ $2].cons_col[d.seq].col_position
   ENDIF
   INTO value(filename2)
   HEAD REPORT
    str->str = "", 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
    "set error_reported = 0 go", row + 1, row + 1,
    "rdb alter table ", t_name, row + 1,
    "add constraint ", c_name
    IF (c_type="R")
     " foreign key (", errstr = concat("add foreign key constraint ",trim(c_name))
    ELSEIF (c_type="P")
     " primary key (", errstr = concat("add primary key constraint ",trim(c_name))
    ELSE
     " unique (", errstr = concat("add unique constraint ",trim(c_name))
    ENDIF
   DETAIL
    IF (cc_pos > 1)
     ","
    ENDIF
    row + 1, "  ", cc_name
   FOOT REPORT
    row + 1
    IF (c_type="R")
     ") references ", pt_name, len = size(trim(pt_cols)),
     i = 1, found = findstring(",",pt_cols,i)
     IF (found > 0)
      WHILE (found > 0)
        col_name = substring(i,(found - i),pt_cols)
        IF (i=1)
         str->str = concat("(",trim(col_name))
        ELSE
         str->str = concat(" ",trim(col_name))
        ENDIF
        IF (i > 1)
         ","
        ENDIF
        row + 1, "    ", str->str,
        i = (found+ 1), found = findstring(",",pt_cols,i)
      ENDWHILE
      col_name = substring(i,len,pt_cols), str->str = concat(" ",trim(col_name),")")
      IF (i > 1)
       ","
      ENDIF
      row + 1, "    ", str->str,
      row + 1
     ELSE
      row + 1, str->str = concat("(",trim(pt_cols),")"), "    ",
      str->str, row + 1
     ENDIF
    ELSE
     ")", row + 1
    ENDIF
    IF (((c_status=0) OR (c_type="R")) )
     "disable "
    ENDIF
    "go", row + 1, row + 1,
    'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1, str->str = concat(
     '"alter table ',trim(t_name)," ",trim(errstr),'" go'),
    "set error_msg= ", str->str, row + 1,
    'set rstring = "" go', row + 1, 'set rstring1 = "" go',
    row + 1, "execute dm_check_errors go", row + 1,
    row + 1, reset_error = 1
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  IF (( $1 > 0))
   FOR (k = 1 TO d_cons->cons_cnt)
     IF ((bn_ocd->tbl[d_tbl_ptr].cons[d_ptr].cons_name=d_cons->cons[k].cons_name))
      SET d_cons->cons[k].create_ind = 0
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  FOR (tcnt = 1 TO bn_ocd->tbl_cnt)
    FOR (ccnt = 1 TO bn_ocd->tbl[tcnt].cons_cnt)
      IF ((bn_ocd->tbl[tcnt].cons[ccnt].cons_type="R")
       AND (bn_ocd->tbl[tcnt].cons[ccnt].r_constraint_name=bn_ocd->tbl[tcnt].cons[d_ptr].cons_name))
       SELECT INTO value(filename2)
        FROM (dummyt d  WITH seq = value(bn_ocd->tbl[tcnt].cons[ccnt].cons_col_cnt))
        ORDER BY bn_ocd->tbl[tcnt].cons[ccnt].cons_col[d.seq].col_position
        HEAD REPORT
         str->str = "", 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
         "set error_reported = 0 go", row + 1, row + 1,
         "rdb alter table ", bn_ocd->tbl[tcnt].tbl_name, row + 1,
         "add constraint ", bn_ocd->tbl[tcnt].cons[ccnt].cons_name" foreign key (", errstr = concat(
          "add foreign key constraint ",trim(bn_ocd->tbl[tcnt].cons[ccnt].cons_name))
        DETAIL
         IF ((bn_ocd->tbl[tcnt].cons[ccnt].cons_col[d.seq].col_position > 1))
          ","
         ENDIF
         row + 1, "  ", bn_ocd->tbl[tcnt].cons[ccnt].cons_col[d.seq].col_name
        FOOT REPORT
         row + 1, ") references ", bn_ocd->tbl[tcnt].cons[ccnt].parent_table,
         len = size(trim(bn_ocd->tbl[tcnt].cons[ccnt].parent_table_columns)), i = 1, found =
         findstring(",",bn_ocd->tbl[tcnt].cons[ccnt].parent_table_columns,i)
         IF (found > 0)
          WHILE (found > 0)
            col_name = substring(i,(found - i),bn_ocd->tbl[tcnt].cons[ccnt].parent_table_columns)
            IF (i=1)
             str->str = concat("(",trim(col_name))
            ELSE
             str->str = concat(" ",trim(col_name))
            ENDIF
            IF (i > 1)
             ","
            ENDIF
            row + 1, "    ", str->str,
            i = (found+ 1), found = findstring(",",bn_ocd->tbl[tcnt].cons[ccnt].parent_table_columns,
             i)
          ENDWHILE
          col_name = substring(i,len,bn_ocd->tbl[tcnt].cons[ccnt].parent_table_columns), str->str =
          concat(" ",trim(col_name),")")
          IF (i > 1)
           ","
          ENDIF
          row + 1, "    ", str->str,
          row + 1
         ELSE
          row + 1, str->str = concat("(",trim(bn_ocd->tbl[tcnt].cons[ccnt].parent_table_columns),")"),
          "    ",
          str->str, row + 1
         ENDIF
         "disable ", "go", row + 1,
         row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
         str->str = concat('"alter table ',trim(bn_ocd->tbl[tcnt].tbl_name)," ",trim(errstr),'" go'),
         "set error_msg= ", str->str,
         row + 1, 'set rstring = "" go', row + 1,
         'set rstring1 = "" go', row + 1, "execute dm_check_errors go",
         row + 1, row + 1, reset_error = 1
        WITH format = variable, noheading, formfeed = none,
         maxcol = 512, maxrow = 1, append
       ;end select
       FOR (k = 1 TO d_cons->cons_cnt)
         IF ((bn_ocd->tbl[tcnt].cons[ccnt].cons_name=d_cons->cons[k].cons_name))
          SET d_cons->cons[k].create_ind = 0
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
END GO
