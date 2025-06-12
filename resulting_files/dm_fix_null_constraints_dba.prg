CREATE PROGRAM dm_fix_null_constraints:dba
 SET tbl_name = table_list->table_name[ $1].tname
 SET process_flg = table_list->table_name[ $1].process_flg
 SET file2 = table_list->table_name[ $1].output2_filename
 SET file3 = table_list->table_name[ $1].output3_filename
 SET file4 = table_list->table_name[ $1].output4_filename
 SET file_sql = table_list->table_name[ $1].output2sql_filename
 SET file3_sql = table_list->table_name[ $1].output3sql_filename
 SET file2d = table_list->table_name[ $1].output2d_filename
 SET file3d = table_list->table_name[ $1].output3d_filename
 SET file4d = table_list->table_name[ $1].output4d_filename
 SET default_value = fillstring(40," ")
 SET tempstr = fillstring(110," ")
 SET errstr = fillstring(110," ")
 RECORD str(
   1 str = vc
 )
 IF (process_flg=3)
  SET filename = file2d
  SET err_filename = file3d
 ELSE
  SET filename = file2
  SET err_filename = file3
 ENDIF
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
  dc.table_name, dc.data_type, utc.data_type,
  dc.column_name, dc.nullable, utc.nullable,
  dc.data_default, utc.data_default, utc.data_length,
  dc.data_length, default_is_null = nullind(dc.data_default)
  FROM dm_user_tab_cols utc,
   dm_columns dc
  PLAN (dc
   WHERE dc.table_name=tbl_name
    AND dc.schema_date=cnvtdatetime( $2))
   JOIN (utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name
    AND ((utc.data_type=dc.data_type) OR (((utc.data_type="NUMBER"
    AND dc.data_type="FLOAT") OR (((utc.data_type="VARCHAR2"
    AND dc.data_type="CHAR") OR (utc.data_type="CHAR"
    AND dc.data_type="VARCHAR2")) )) ))
    AND utc.nullable="Y"
    AND dc.nullable="N")
  DETAIL
   IF (((default_is_null=1) OR (((cnvtupper(dc.data_default)="NULL") OR (((dc.data_default="' '") OR
   (dc.data_default='" "')) )) )) )
    IF (((dc.data_type="FLOAT") OR (dc.data_type="NUMBER")) )
     default_value = "0"
    ELSEIF (dc.data_type="DATE")
     default_value = "to_date('1/1/1900','MM/DD/YYYY')"
    ELSE
     default_value = "' '"
    ENDIF
   ELSE
    default_value = dc.data_default
   ENDIF
   cols->knt = (cols->knt+ 1), stat = alterlist(cols->qual,cols->knt), cols->qual[cols->knt].
   column_name = dc.column_name,
   cols->qual[cols->knt].data_default = default_value, cols->qual[cols->knt].data_type = dc.data_type,
   cols->qual[cols->knt].nullable = dc.nullable
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dc.seq, dc.table_name, dc.column_name,
  dc.data_type, dc.data_length, dc.data_default,
  dc.nullable, default_is_null = nullind(dc.data_default)
  FROM dm_columns dc
  WHERE dc.schema_date=cnvtdatetime( $2)
   AND dc.table_name=tbl_name
   AND dc.nullable="N"
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_user_tab_cols utc
   WHERE utc.table_name=dc.table_name
    AND utc.column_name=dc.column_name)))
  DETAIL
   IF (((default_is_null=1) OR (((cnvtupper(dc.data_default)="NULL") OR (((dc.data_default="' '") OR
   (dc.data_default='" "')) )) )) )
    IF (((dc.data_type="FLOAT") OR (dc.data_type="NUMBER")) )
     default_value = "0"
    ELSEIF (dc.data_type="DATE")
     default_value = "to_date('1/1/1900','MM/DD/YYYY')"
    ELSE
     default_value = "' '"
    ENDIF
   ELSE
    default_value = dc.data_default
   ENDIF
   cols->knt = (cols->knt+ 1), stat = alterlist(cols->qual,cols->knt), cols->qual[cols->knt].
   column_name = dc.column_name,
   cols->qual[cols->knt].data_default = default_value, cols->qual[cols->knt].data_type = dc.data_type,
   cols->qual[cols->knt].nullable = dc.nullable
  WITH nocounter
 ;end select
 IF ((cols->knt > 0))
  SELECT INTO value(file_sql)
   FROM (dummyt d  WITH seq = value(cols->knt))
   HEAD REPORT
    "declare", row + 1, "cursor c1 is",
    row + 1, "select rowid ", row + 1,
    str->str = build('from "',tbl_name,'"'), str->str, cnum = 0
   DETAIL
    cnum = (cnum+ 1), row + 1
    IF (cnum=1)
     " where "
    ELSE
     " or "
    ENDIF
    cols->qual[d.seq].column_name, " is null "
   FOOT REPORT
    ";", row + 1, " finished number:=0;",
    row + 1, " err_num number;", row + 1,
    "begin", row + 1, "while (finished=0) loop",
    row + 1, "  finished:=1;", row + 1,
    "  begin", row + 1, "  for c1rec in c1 loop",
    row + 1, str->str = build('    update "',tbl_name,'"'), str->str
    FOR (i = 1 TO cols->knt)
      IF (i=1)
       "set "
      ELSE
       ","
      ENDIF
      row + 1, cols->qual[i].column_name, " = nvl(",
      cols->qual[i].column_name, ", ", cols->qual[i].data_default,
      ")"
    ENDFOR
    "    where rowid = c1rec.rowid;", row + 1, "    commit;",
    row + 1, "  end loop;", row + 1,
    "  exception when others then", row + 1, "    err_num:=sqlcode;",
    row + 1, "    if (err_num=-1555 or err_num=1555) then       ", row + 1,
    "      finished:=0;", row + 1, "    end if;       ",
    row + 1, "  end;", row + 1,
    "end loop;", row + 1, "end;",
    row + 1, "/", row + 1
   WITH nocounter, format = variable, noheading,
    formfeed = none, maxcol = 512, maxrow = 1,
    append
  ;end select
  SELECT INTO value(filename)
   FROM (dummyt d  WITH seq = value(cols->knt))
   DETAIL
    row + 1, "dm_clear_errors go", row + 1,
    row + 1, "rdb alter table ", tbl_name,
    row + 1, "modify (", cols->qual[d.seq].column_name,
    " NOT NULL) go", row + 1, row + 1,
    "set msgnum=error(msg,1) go", row + 1, errstr = build("alter table:",tbl_name,
     " modify columns not null"),
    "execute dm_log_errors ", row + 1, ' "',
    err_filename, '", ', row + 1,
    ' "", ', row + 1, ' "", ',
    row + 1, ' "', errstr,
    '",', row + 1, " msg, msgnum go",
    row + 2, reset_error = 1
   WITH nocounter, format = variable, noheading,
    formfeed = none, maxcol = 512, maxrow = 1,
    append
  ;end select
 ENDIF
#end_program
END GO
