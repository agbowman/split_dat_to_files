CREATE PROGRAM ccloralongs:dba
 PAINT
  video(r), box(1,1,14,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLORADEF"), clear(3,2,78),
  text(03,05,"Report to generate ccl definition for ORACLE dictionary."), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"ORACLE SYSTEM TABLES (Y/N/X)"), text(07,05,"MAX TABLE LENGTH"), text(08,05,
   "CCL DATABASE NAME"),
  text(09,05,"TABLESPACE"), text(10,05,"START TABLE NAME"), text(011,05,"END   TABLE NAME"),
  text(012,05,"OWNER NAME"), accept(05,40,"P(40);CU","MINE"), accept(06,40,"A;CU","N"
   WHERE curaccept IN ("N", "Y", "X")),
  accept(07,40,"999999",35000), accept(08,40,"P(31);CU"), accept(09,40,"P(31);CU",char(42)),
  accept(10,40,"P(31);CU","AA"), accept(11,40,"P(31);CU","ZZ"), accept(12,40,"P(31);CU",char(42)),
  clear(1,1)
 SET p_result =  $1
 SET p_system =  $2
 SET p_maxlen =  $3
 SET p_long_maxlen = minval(32000, $3)
 SET p_database =  $4
 SET p_tablespace =  $5
 SET p_table1 =  $6
 SET p_table2 =  $7
 SET p_owner =  $8
 RECORD rec1(
   1 alloc = i4
   1 cnt = i4
   1 seg[10]
     2 table_name = c31
 )
 SET rec1->cnt = 0
 SET rec1->alloc = 10
 SET message = nowindow
 DEFINE oraclesystem
 SELECT
  IF (p_system="Y")
   FROM all_tab_columns c,
    dictionary d
   PLAN (d
    WHERE d.table_name != "*$"
     AND d.table_name BETWEEN trim(p_table1) AND trim(p_table2))
    JOIN (c
    WHERE d.table_name=c.table_name
     AND c.owner="SYS"
     AND c.column_name != "*#")
   WITH noformfeed, format = variable, maxrow = 1,
    noformfeed
  ELSEIF (p_system="N")
   FROM all_tab_columns c,
    all_objects t,
    all_tables a,
    all_tab_columns at
   PLAN (at
    WHERE at.data_type="LONG*")
    JOIN (t
    WHERE at.table_name=t.object_name
     AND t.object_name != "*$"
     AND t.owner != "SYS*"
     AND t.owner=patstring(trim(p_owner))
     AND t.object_type IN ("TABLE", "VIEW"))
    JOIN (c
    WHERE t.object_name=c.table_name
     AND t.owner=c.owner
     AND c.column_name != "*#")
    JOIN (a
    WHERE t.object_name=a.table_name
     AND t.owner=a.owner
     AND a.tablespace_name=patstring(trim(p_tablespace)))
   WITH noformfeed, format = variable, maxrow = 1,
    noformfeed
  ELSEIF (p_system="X")
   FROM all_tab_columns c,
    all_objects t,
    all_tables a
   PLAN (t
    WHERE t.object_name BETWEEN trim(p_table1) AND trim(p_table2)
     AND t.object_name != "*$"
     AND t.owner=patstring(trim(p_owner))
     AND t.object_type IN ("TABLE", "VIEW"))
    JOIN (c
    WHERE t.object_name=c.table_name
     AND t.owner=c.owner
     AND c.column_name != "*#")
    JOIN (a
    WHERE t.object_name=a.table_name
     AND t.owner=a.owner
     AND a.tablespace_name=patstring(trim(p_tablespace)))
   WITH noformfeed, format = variable, maxrow = 1,
    noformfeed
  ELSE
  ENDIF
  INTO trim(p_result)
  tablespace_name = validate(a.tablespace_name,"SYSTEM"), owner_name = c.owner, rel_name = c
  .table_name,
  attr_name = c.column_name, type = c.data_type, len = c.data_length,
  scale = c.data_scale, precision = c.data_precision, attr_id = c.column_id,
  nullable = c.nullable
  ORDER BY c.table_name, c.column_id
  HEAD REPORT
   nbuff = fillstring(20," "), save_version = 0, table_name = fillstring(30," "),
   ";FD", p_database, ".DEF",
   row + 1
   IF (p_table1 != p_table2
    AND p_maxlen > 0
    AND size(trim(p_tablespace))=1)
    "DROP DATABASE ", p_database, " WITH DEPS_DELETED GO",
    row + 1, "CREATE DATABASE ", p_database,
    row + 1, "   ORGANIZATION(ORACLE)", row + 1,
    "   FORMAT(UNDEFINED)", row + 1, "   SIZE(",
    p_maxlen, ")", row + 1,
    "   TYPE(S)", row + 1, "   SCHEMA(",
    p_database, ")", row + 1,
    "GO", row + 1
   ENDIF
  HEAD rel_name
   table_name = rel_name, row + 1, ";OWNER= ",
   owner_name, " TABLESPACE= ", tablespace_name,
   row + 1
   IF (((p_table1=p_table2) OR (size(trim(p_tablespace)) > 1)) )
    "DROP TABLE ", table_name, " GO",
    row + 1, "DROP DDLRECORD ", rel_name,
    " FROM DATABASE ", p_database, " WITH DEPS_DELETED GO",
    row + 1
   ENDIF
   "CREATE DDLRECORD ", rel_name, " FROM DATABASE ",
   p_database, row + 1, "TABLE ",
   table_name, row + 1, nlen = 0
   IF (((rec1->cnt+ 1)=rec1->alloc))
    rec1->alloc += 10, stat = alter(rec1->seg,rec1->alloc)
   ENDIF
   rec1->cnt += 1, rec1->seg[rec1->cnt].table_name = table_name
  DETAIL
   col 5, "1  ", attr_name,
   col 40
   CASE (type)
    OF "CHAR":
     IF (len=1
      AND attr_name IN ("*_IND"))
      "= I1"
     ELSE
      "= C", len"#####;L"
     ENDIF
     ,col 51,"CCL(",attr_name,
     ") ;",type
    OF "VARCHAR":
     IF (len < 50)
      "= C", len"#####;L"
     ELSE
      "= VC", len"#####;L"
     ENDIF
     ,col 51,"CCL(",attr_name,
     ") ;",type
    OF "VARCHAR2":
     IF (len < 50)
      "= C", len"#####;L"
     ELSE
      "= VC", len"#####;L"
     ENDIF
     ,col 51,"CCL(",attr_name,
     ") ;",type
    OF "NUMBER":
     IF (attr_name IN ("*_IND", "*_FLAG"))
      "= I2"
     ELSEIF (scale=0
      AND  NOT (attr_name IN ("*_COMPL", "*_VALUE", "*_CD", "*_ID")))
      "= I4"
     ELSE
      "= F8"
     ENDIF
     ,col 51,"CCL(",attr_name,
     ") ;",type,"(LEN:",
     len"##;L"," PREC:",precision"##;L",
     " SCALE:",scale"###;L",")"
    OF "FLOAT":
     "=F8",col 51,"CCL(",
     attr_name,") ;",type,
     "(LEN:",len"##;L"," PREC:",
     precision"##;L"," SCALE:",scale"###;L",
     ")"
    OF "MLSLABEL":
     "= C4",col 51,"CCL(",
     attr_name,") ;",type
    OF "RAW MLSLABEL":
     "= GI4",col 51,"CCL(",
     attr_name,") ;",type
    OF "LONG":
     "= VC",p_long_maxlen"#####;L",col 51,
     "CCL(",attr_name,") ;",
     type
    OF "ROWID":
     "= C18",col 51,"CCL(",
     attr_name,") ;",type
    OF "DATE":
     "= DI8",col 51,"CCL(",
     attr_name,") ;",type
    OF "RAW":
     "= GC",len"#####;L",col 51,
     "CCL(",attr_name,") ;",
     type
    OF "LONG RAW":
     "= VGC",p_long_maxlen"#####;L",col 51,
     "CCL(",attr_name,") ;",
     type
    ELSE
     col 51," ;UNSUPPORTED TYPE "
   ENDCASE
   row + 1
  FOOT  rel_name
   col 5, "1  rowid", col 50,
   "CCL(rowid) ;ROWID", row + 1, col 5,
   "   2  rowid_fld", col 40, "= C18",
   row + 1, "END TABLE ", table_name,
   row + 1, "GO", row + 1
  FOOT REPORT
   IF (p_table1 != p_table2)
    col 5, "CREATE GENLINK FD", p_database,
    " FROM DATABASE ", p_database, row + 1,
    sep = " "
    FOR (num = 1 TO rec1->cnt)
      col 5, sep, rec1->seg[num].table_name,
      row + 1, sep = ","
    ENDFOR
    col 5, "GO", row + 1
   ENDIF
 ;end select
END GO
