CREATE PROGRAM cv_utl_create_erwin:dba
 RECORD tables(
   1 slist[*]
     2 section = vc
     2 tlist[*]
       3 table_name = vc
       3 schema_date = dq8
 )
 SET scnt = 0
 SET tcnt = 0
 SET tabcnt = 0
 SELECT INTO "nl:"
  FROM all_tables at,
   dm_tables_doc d,
   dm_columns dc
  WHERE at.table_name="PC_*"
   AND d.table_name=at.table_name
   AND d.table_name=dc.table_name
  ORDER BY d.data_model_section, d.table_name, dc.schema_date DESC
  HEAD d.data_model_section
   tcnt = 0, scnt = (scnt+ 1), stat = alterlist(tables->slist,scnt),
   tables->slist[scnt].section = d.data_model_section,
   CALL echo(d.data_model_section)
  HEAD d.table_name
   tabcnt = (tabcnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(tables->slist[scnt].tlist,tcnt),
   tables->slist[scnt].tlist[tcnt].table_name = d.table_name, tables->slist[scnt].tlist[tcnt].
   schema_date = cnvtdatetime(dc.schema_date)
  DETAIL
   col + 0
  WITH nocounter
 ;end select
 CALL echo(build("section count:",scnt,",table count:",tabcnt))
 SELECT
  FROM (dummyt d  WITH seq = value(scnt))
  HEAD REPORT
   col 0, "section count: ", scnt,
   " table count: ", tabcnt, row + 2
  DETAIL
   col 0, d.seq"##", "   ",
   tables->slist[d.seq].section, tcount = size(tables->slist[d.seq].tlist,5), col 40,
   "count: ", tcount"####", row + 1
   FOR (x = 1 TO size(tables->slist[d.seq].tlist,5))
     col 10, tables->slist[d.seq].tlist[x].table_name, col 60,
     tables->slist[d.seq].tlist[x].schema_date"mm/dd/yy;;d", row + 1
   ENDFOR
  WITH nocounter, noformfeed
 ;end select
 FOR (l1 = 1 TO scnt)
  SET filename = concat("erwin_",trim(cnvtstring(l1)),".sql")
  FOR (l2 = 1 TO size(tables->slist[l1].tlist,5))
   CALL echo(build(l1,"->",tables->slist[l1].section,",",filename,
     ":",tables->slist[l1].tlist[l2].table_name))
   CALL create_erwin(tables->slist[l1].tlist[l2].table_name,tables->slist[l1].tlist[l2].schema_date)
  ENDFOR
 ENDFOR
 SUBROUTINE create_erwin(param_table_name,param_release_date)
   SET tablename = cnvtupper(param_table_name)
   SET output = "ccluserdir:cver.sql"
   SET release = param_release_date
   SELECT INTO value(output)
    FROM dm_columns d
    WHERE d.table_name=patstring(tablename)
     AND d.schema_date=cnvtdatetime(release)
    HEAD d.table_name
     col 0, "create table ", d.table_name,
     " ( ", row + 1
    DETAIL
     row + 1, col 10, d.column_name,
     " ", d.data_type
     IF (d.data_type="VARCHAR*")
      "(", d.data_length"####", ") "
     ENDIF
     ","
    FOOT  d.table_name
     col 10, d.column_name, " ",
     d.data_type
     IF (d.data_type="VARCHAR*")
      "(", d.data_length"####", ") "
     ENDIF
     "             ", row + 1, col 0,
     ") ;", row + 1
    WITH noformat, noformfeed, append,
     maxrow = 1
   ;end select
   SELECT INTO value(output)
    ak1 = concat("XPK",d.table_name), ak2 = concat("XPK_",d.table_name), size1 = size(concat("XPK",d
      .table_name)),
    size2 = size(concat("XPK_",d.table_name))
    FROM dm_index_columns d
    WHERE d.table_name=patstring(tablename)
     AND d.schema_date=cnvtdatetime(release)
    ORDER BY d.table_name, d.index_name, d.column_position,
     d.schema_date
    HEAD d.index_name
     IF (((substring(1,size1,d.index_name)=ak1) OR (substring(1,size2,d.index_name)=ak2)) )
      col 0, "alter table ", d.table_name,
      " add (primary key ( "
     ELSE
      col 0, "create index ", d.index_name,
      " on ", d.table_name, " ("
     ENDIF
     row + 1
    HEAD d.column_name
     col + 0
    DETAIL
     col + 0
    FOOT  d.column_name
     row + 1, col 0, d.column_name,
     " ,"
    FOOT  d.index_name
     col 0, d.column_name, "         ",
     row + 1
     IF (((substring(1,size1,d.index_name)=ak1) OR (substring(1,size2,d.index_name)=ak2)) )
      col 0, "));"
     ELSE
      col 0, " ) ; "
     ENDIF
     row + 1
    WITH noformat, noformfeed, append,
     maxrow = 1
   ;end select
   SELECT INTO value(output)
    FROM dm_constraints dc,
     dm_index_columns dic
    WHERE dc.table_name=patstring(tablename)
     AND dc.schema_date=cnvtdatetime(release)
     AND dc.constraint_type="R"
     AND dc.r_constraint_name=dic.index_name
    ORDER BY dic.index_name, dic.column_name, dc.schema_date
    HEAD dic.index_name
     col 0, "alter table ", dc.table_name,
     "add ( foreign key ( ", row + 1
    HEAD dic.column_name
     col + 0
    DETAIL
     col + 0
    FOOT  dic.column_name
     row + 1, col 0, dic.column_name,
     " ,"
    FOOT  dic.index_name
     col 0, dic.column_name, "    ",
     row + 1, col 0, ") references ",
     dic.table_name, " ) ;", row + 1
    WITH noformat, noformfeed, append,
     maxrow = 1
   ;end select
 END ;Subroutine
END GO
