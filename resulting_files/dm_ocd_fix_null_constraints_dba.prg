CREATE PROGRAM dm_ocd_fix_null_constraints:dba
 SET tbl_name = fillstring(30," ")
 SET d_tbl_ptr =  $1
 SET u_tbl_ptr =  $2
 SET tbl_name = bn_ocd->tbl[d_tbl_ptr].tbl_name
 SET d_ptr = 0
 SET u_ptr = 0
 SET default_value = fillstring(40," ")
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 FREE RECORD str
 RECORD str(
   1 str = vc
 )
 FREE RECORD cols
 RECORD cols(
   1 knt = i2
   1 qual[*]
     2 column_name = vc
     2 data_default = vc
     2 data_type = vc
     2 nullable = c1
     2 fix_nullable = i2
 )
 SET cols->knt = 0
 SET stat = alterlist(cols->qual,10)
 SELECT INTO "nl:"
  t_name = bn_ocd->tbl[d_tbl_ptr].tbl_name, c_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
  c_type = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type,
  c_nullable = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable, c_default = bn_ocd->tbl[d_tbl_ptr].
  tbl_col[d.seq].data_default, utc.data_type,
  utc.nullable, utc.data_default
  FROM dm_user_tab_cols utc,
   (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt))
  PLAN (d)
   JOIN (utc
   WHERE (utc.table_name=bn_ocd->tbl[d_tbl_ptr].tbl_name)
    AND (utc.column_name=bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name)
    AND (((utc.data_type=bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type)) OR (((utc.data_type=
   "NUMBER"
    AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="FLOAT")) OR (((utc.data_type="VARCHAR2"
    AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="CHAR")) OR (utc.data_type="CHAR"
    AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="VARCHAR2"))) )) )) )
  DETAIL
   IF (utc.nullable="Y"
    AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable="N"))
    IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default="")) OR (cnvtupper(bn_ocd->tbl[
     d_tbl_ptr].tbl_col[d.seq].data_default)="NULL")) )
     IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="FLOAT")) OR ((bn_ocd->tbl[d_tbl_ptr].
     tbl_col[d.seq].data_type="NUMBER"))) )
      default_value = "0"
     ELSEIF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="DATE"))
      default_value = "to_date('1/1/1900','MM/DD/YYYY')"
     ELSE
      default_value = "' '"
     ENDIF
    ELSE
     default_value = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default
    ENDIF
    cols->knt = (cols->knt+ 1), stat = alterlist(cols->qual,cols->knt), cols->qual[cols->knt].
    column_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
    cols->qual[cols->knt].data_default = default_value, cols->qual[cols->knt].data_type = bn_ocd->
    tbl[d_tbl_ptr].tbl_col[d.seq].data_type, cols->qual[cols->knt].nullable = bn_ocd->tbl[d_tbl_ptr].
    tbl_col[d.seq].nullable,
    cols->qual[cols->knt].fix_nullable = 1
   ELSEIF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default != utc.data_default)
    AND (bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default != "")
    AND cnvtupper(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default) != "NULL")
    cols->knt = (cols->knt+ 1), stat = alterlist(cols->qual,cols->knt), cols->qual[cols->knt].
    column_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
    cols->qual[cols->knt].data_default = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default, cols->
    qual[cols->knt].data_type = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type, cols->qual[cols->knt
    ].nullable = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable,
    cols->qual[cols->knt].fix_nullable = 0
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo(build("*** For table:",bn_ocd->tbl[d_tbl_ptr].tbl_name))
 CALL echo(build("*** size of cols:",cols->knt))
 CALL echo("***")
 SELECT INTO "nl:"
  d.seq, t_name = bn_ocd->tbl[d_tbl_ptr].tbl_name, c_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].
  col_name,
  c_type = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type, c_nullable = bn_ocd->tbl[d_tbl_ptr].
  tbl_col[d.seq].nullable, c_default = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default
  FROM (dummyt d  WITH seq = value(bn_ocd->tbl[d_tbl_ptr].tbl_col_cnt)),
   dummyt o,
   dm_user_tab_cols u
  PLAN (d)
   JOIN (o)
   JOIN (u
   WHERE (u.table_name=bn_ocd->tbl[d_tbl_ptr].tbl_name)
    AND (u.column_name=bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name))
  DETAIL
   IF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable="N"))
    IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default="")) OR (cnvtupper(bn_ocd->tbl[
     d_tbl_ptr].tbl_col[d.seq].data_default)="NULL")) )
     IF ((((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="FLOAT")) OR ((bn_ocd->tbl[d_tbl_ptr].
     tbl_col[d.seq].data_type="NUMBER"))) )
      default_value = "0"
     ELSEIF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type="DATE"))
      default_value = "to_date('1/1/1900','MM/DD/YYYY')"
     ELSE
      default_value = "' '"
     ENDIF
    ELSE
     default_value = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default
    ENDIF
    cols->knt = (cols->knt+ 1), stat = alterlist(cols->qual,cols->knt), cols->qual[cols->knt].
    column_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
    cols->qual[cols->knt].data_default = default_value, cols->qual[cols->knt].data_type = bn_ocd->
    tbl[d_tbl_ptr].tbl_col[d.seq].data_type, cols->qual[cols->knt].nullable = bn_ocd->tbl[d_tbl_ptr].
    tbl_col[d.seq].nullable,
    cols->qual[cols->knt].fix_nullable = 1
   ELSEIF ((bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default != "")
    AND cnvtupper(bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default) != "NULL")
    cols->knt = (cols->knt+ 1), stat = alterlist(cols->qual,cols->knt), cols->qual[cols->knt].
    column_name = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].col_name,
    cols->qual[cols->knt].data_default = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_default, cols->
    qual[cols->knt].data_type = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].data_type, cols->qual[cols->knt
    ].nullable = bn_ocd->tbl[d_tbl_ptr].tbl_col[d.seq].nullable,
    cols->qual[cols->knt].fix_nullable = 0
   ENDIF
  WITH nocounter, outerjoin = o, dontexist
 ;end select
 CALL echo("***")
 CALL echo(build("*** size of cols:",cols->knt))
 CALL echo("***")
 IF ((cols->knt > 0))
  SELECT INTO value(sqlfile2)
   FROM (dummyt d  WITH seq = value(cols->knt))
   HEAD REPORT
    "declare", row + 1, "cursor c1 is",
    row + 1, "  select rowid ", row + 1,
    str->str = build('  from "',tbl_name,'"'), str->str, cnum = 0
   DETAIL
    cnum = (cnum+ 1), row + 1
    IF (cnum=1)
     "  where "
    ELSE
     "     or "
    ENDIF
    cols->qual[d.seq].column_name, " is null "
   FOOT REPORT
    ";", row + 1, "  finished number:=0;",
    row + 1, "  err_num number;", row + 1,
    "begin", row + 1, "while (finished=0) loop",
    row + 1, "  finished:=1;", row + 1,
    "  begin", row + 1, "  for c1rec in c1 loop",
    row + 1, str->str = build('    update "',tbl_name,'"'), str->str
    FOR (i = 1 TO cols->knt)
      IF (i=1)
       " set "
      ELSE
       ","
      ENDIF
      row + 1, "      ", cols->qual[i].column_name,
      " = nvl(", cols->qual[i].column_name, ", ",
      cols->qual[i].data_default, ")"
    ENDFOR
    row + 1, "    where rowid = c1rec.rowid;", row + 1,
    "    commit;", row + 1, "  end loop;",
    row + 1, "  exception when others then", row + 1,
    "    err_num:=sqlcode;", row + 1, "    if (err_num=-1555 or err_num=1555) then       ",
    row + 1, "      finished:=0;", row + 1,
    "    end if;       ", row + 1, "  end;",
    row + 1, "end loop;", row + 1,
    "end;", row + 1, "/",
    row + 1
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
  SELECT INTO value(filename2)
   FROM (dummyt d  WITH seq = value(cols->knt))
   WHERE (cols->qual[d.seq].nullable="N")
    AND (cols->qual[d.seq].fix_nullable=1)
   DETAIL
    row + 1, 'select into "nl:" msgnum=error(msg,1) with nocounter go', row + 1,
    "set error_reported = 0 go", row + 1, row + 1,
    "rdb alter table ", tbl_name, row + 1,
    "modify (", cols->qual[d.seq].column_name, " NOT NULL) go",
    row + 1, row + 1, "set msgnum=error(msg,1) go",
    row + 1, errstr = concat('"alter table ',trim(tbl_name)," modify column ",trim(cols->qual[d.seq].
      column_name),' NOT NULL" go'), "set error_msg= ",
    errstr, row + 1, 'set rstring = "" go',
    row + 1, 'set rstring1 = "" go', row + 1,
    "execute dm_check_errors go", row + 1, row + 1,
    reset_error = 1
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1, append
  ;end select
 ENDIF
END GO
