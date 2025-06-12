CREATE PROGRAM ccloradef:dba
 PAINT
  video(r), box(1,1,14,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLORADEF"), clear(3,2,78),
  text(03,05,"Report to generate ccl definition for ORACLE dictionary."), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"ORACLE SYSTEM TABLES (Y/N/Z)"), text(07,05,"MAX TABLE LENGTH"), text(08,05,
   "CCL DATABASE NAME"),
  text(09,05,"TABLESPACE"), text(10,05,"TABLE NAME"), text(11,05,"OWNER NAME"),
  accept(05,40,"P(40);CU","MINE"), accept(06,40,"A;CU","N"
   WHERE curaccept IN ("N", "Y", "Z")), accept(07,40,"999999",55000),
  accept(08,40,"P(31);CU","V500"), accept(09,40,"P(31);CU",char(42)), accept(10,40,"P(31);CU"," "),
  accept(11,40,"P(31);CU","V500"), clear(1,1)
 DECLARE oracle_version = i4 WITH constant(cnvtint(piece(substring(5,25,currdbsys),".",1," ")))
 SET p_result =  $1
 SET p_system =  $2
 SET p_maxlen =  $3
 SET p_maxlen =  $3
 IF (p_system="Y")
  SET p_long_maxlen = minval(2000, $3)
  SET p_long_maxlen2 = minval(2000, $3)
  SET p_maxlen = 8000
  SET p_database =  $4
  SET p_database2 = "ORACLESYSTEM"
 ELSE
  SET p_long_maxlen = minval(32000, $3)
  SET p_long_maxlen2 = minval(32768, $3)
  SET p_database =  $4
  SET p_database2 =  $4
 ENDIF
 SET p_tablespace =  $5
 SET p_table =  $6
 SET p_owner =  $7
 SET p_tableall = 0
 IF (ichar(substring(1,1,p_table))=42)
  SET p_tableall = 1
 ENDIF
 RECORD rec1(
   1 alloc = i4
   1 cnt = i4
   1 seg[10]
     2 table_name = c31
 )
 SET rec1->cnt = 0
 SET rec1->alloc = 10
 SET dic_table_name = fillstring(31," ")
 SET message = nowindow
 SELECT
  IF (p_system="Y")
   owner_name = c.owner, rel_name = substring(1,31,c.table_name), attr_name = substring(1,30,c
    .column_name),
   type = substring(1,9,c.data_type), len =
   IF (c.column_name="COLUMN_NAME"
    AND c.data_length >= 4000) 30
   ELSE c.data_length
   ENDIF
   , scale = c.data_scale,
   precision = c.data_precision, attr_id = c.column_id, nullable = c.nullable,
   nlsflag = " ", dateabsflag = " "
   FROM dba_tab_columns c
   PLAN (c
    WHERE c.table_name=patstring(p_table)
     AND c.owner="SYS*")
   ORDER BY rel_name, c.table_name, c.column_id
   WITH noformfeed, format = variable, maxrow = 1,
    noformfeed
  ELSEIF (p_system="Z")
   owner_name = c.owner, rel_name = substring(1,31,c.table_name), attr_name = substring(1,30,c
    .column_name),
   type = substring(1,9,c.data_type), len =
   IF (c.column_name="COLUMN_NAME"
    AND c.data_length >= 4000) 30
   ELSE c.data_length
   ENDIF
   , scale = c.data_scale,
   precision = c.data_precision, attr_id = c.column_id, nullable = c.nullable,
   nlsflag = " ", dateabsflag = " "
   FROM dba_tab_columns c
   PLAN (c
    WHERE c.table_name=patstring(p_table)
     AND c.owner=patstring(p_owner))
   ORDER BY rel_name, c.table_name, c.column_id
   WITH noformfeed, format = variable, maxrow = 1,
    noformfeed
  ELSEIF (p_system="N")
   owner_name = c.owner, rel_name = substring(1,31,s.synonym_name), attr_name = substring(1,30,c
    .column_name),
   type = substring(1,9,c.data_type), len = c.data_length, scale = c.data_scale,
   precision = c.data_precision, attr_id = c.column_id, nullable = c.nullable,
   nlsflag =
   IF (c2.column_name="*_NLS") "L"
   ELSE " "
   ENDIF
   , dateabsflag =
   IF (c.column_name=di.info_char) "S"
   ELSE " "
   ENDIF
   FROM dba_tab_columns c,
    dummyt d1,
    dba_tab_columns c2,
    dm_info di,
    dba_synonyms s
   PLAN (s
    WHERE s.table_owner=patstring(p_owner)
     AND s.synonym_name=patstring(p_table))
    JOIN (c
    WHERE c.table_name=s.table_name
     AND c.owner != "SYS*"
     AND c.owner=s.table_owner)
    JOIN (d1)
    JOIN (((c2
    WHERE c.table_name=c2.table_name
     AND c.owner=c2.owner
     AND concat(trim(c.column_name),"_NLS")=c2.column_name)
    ) ORJOIN ((di
    WHERE c.table_name=di.info_name
     AND c.column_name=di.info_char
     AND di.info_domain="ABSOLUTE DATE")
    ))
   ORDER BY rel_name, c.table_name, c.column_id
   WITH noformfeed, format = variable, maxrow = 1,
    noformfeed, outerjoin = d1
  ELSE
  ENDIF
  INTO trim(p_result)
  HEAD REPORT
   nbuff = fillstring(20," "), save_version = 0, table_name = fillstring(30," "),
   ";", p_result, row + 1
   IF (p_system="Z"
    AND p_database2 != "V500")
    "DROP DATABASE ", p_database2, " WITH DEPS_DELETED GO",
    row + 1, "CREATE DATABASE ", p_database2,
    row + 1, "   ORGANIZATION(ORACLE)", row + 1,
    "   FORMAT(UNDEFINED)", row + 1, "   SIZE(",
    p_maxlen, ")", row + 1,
    "   TYPE(S)", row + 1, "   SCHEMA(",
    p_database2, ")", row + 1,
    "GO", row + 1
   ELSEIF (p_tableall
    AND p_maxlen > 0
    AND size(trim(p_tablespace))=1
    AND p_system != "Z")
    "DROP DATABASE ORASYS WITH DEPS_DELETED GO", row + 1, "DROP DATABASE ",
    p_database2, " WITH DEPS_DELETED GO", row + 1,
    "CREATE DATABASE ", p_database2, row + 1,
    "   ORGANIZATION(ORACLE)", row + 1, "   FORMAT(UNDEFINED)",
    row + 1, "   SIZE(", p_maxlen,
    ")", row + 1, "   TYPE(S)",
    row + 1, "   SCHEMA(", p_database2,
    ")", row + 1, "GO",
    row + 1
   ENDIF
  HEAD rel_name
   table_name = rel_name, row + 1,
   CALL print(build(";OWNER=",owner_name)),
   row + 1, "DROP TABLE ", table_name,
   " GO", row + 1, "DROP DDLRECORD ",
   rel_name, " FROM DATABASE ", p_database,
   " WITH DEPS_DELETED GO", row + 1, "CREATE DDLRECORD ",
   rel_name, " FROM DATABASE ", p_database,
   row + 1, "TABLE ", table_name,
   row + 1, nlen = 0
   IF (((rec1->cnt+ 1)=rec1->alloc))
    rec1->alloc += 10, stat = alter(rec1->seg,rec1->alloc)
   ENDIF
   rec1->cnt += 1, rec1->seg[rec1->cnt].table_name = table_name
  DETAIL
   col 5, "1  ", attr_name,
   col 40
   CASE (type)
    OF "CHARACTER":
    OF "CHAR":
     IF (len=1
      AND attr_name IN ("*_IND")
      AND table_name != "ICD9*")
      "= I1"
     ELSE
      "=", nlsflag, "C",
      len"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "VARCHAR":
     IF (len < 50
      AND oracle_version < 11)
      "=", nlsflag, "C",
      len"#####;L"
     ELSE
      "=", nlsflag, "VC",
      len"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "VARCHAR2":
     IF (len < 50
      AND oracle_version < 11)
      "=", nlsflag, "C",
      len"#####;L"
     ELSE
      "=", nlsflag, "VC",
      len"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "SMALLINT":
    OF "BIGINT":
    OF "INTEGER":
    OF "DOUBLE":
    OF "NUMBER":
     IF (owner_name="SYS*")
      "= F8"
     ELSEIF (attr_name="UPDT_APPLCTX")
      "= F8"
     ELSEIF (scale=0
      AND attr_name IN ("*_FLAG", "*_IND"))
      "= I2"
     ELSEIF (scale=0
      AND  NOT (attr_name IN ("*_COMPL", "*_VALUE", "*_CD", "*_ID")))
      "= I4"
     ELSE
      "= F8"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "DECIMAL":
    OF "FLOAT":
     "= F8",col 52,"CCL(",
     attr_name,") ;",type
    OF "MLSLABEL":
     "= C4",col 52,"CCL(",
     attr_name,") ;",type
    OF "RAW MLSLABEL":
     "= GI4",col 52,"CCL(",
     attr_name,") ;",type
    OF "LONG":
     IF (attr_name="*BLOB*")
      "= VC", p_long_maxlen2"#####;L"
     ELSE
      "= VC", p_long_maxlen"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "CLOB":
     IF (attr_name="*BLOB*")
      "= ZVC", p_long_maxlen2"#####;L"
     ELSE
      "= ZVC", p_long_maxlen"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "ROWID":
     "= C18",col 52,"CCL(",
     attr_name,") ;",type
    OF "TIMESTAMP":
    OF "DATE":
     IF (dateabsflag="S")
      "= SDI8"
     ELSE
      "= DI8"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "RAW":
     "= GC",len"#####;L",col 52,
     "CCL(",attr_name,") ;",
     type
    OF "LONG RAW":
     IF (attr_name="*BLOB*")
      "= GVC", p_long_maxlen2"#####;L"
     ELSE
      "= GVC", p_long_maxlen"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    OF "BLOB":
     IF (attr_name="*BLOB*")
      "= ZGVC", p_long_maxlen2"#####;L"
     ELSE
      "= ZGVC", p_long_maxlen"#####;L"
     ENDIF
     ,col 52,"CCL(",attr_name,
     ") ;",type
    ELSE
     col 50," ;UNSUPPORTED TYPE "
   ENDCASE
   " NULL=", nullable, " PREC:",
   precision"###;L", " LEN:", len"#####;L",
   row + 1
  FOOT  rel_name
   col 5, "1  rowid", col 52,
   "CCL(rowid                         ) ;ROWID", row + 1, col 5,
   "   2  rowid_fld", col 40, "= C18",
   row + 1, "END TABLE ", table_name,
   row + 1, "GO", row + 1
  FOOT REPORT
   IF (p_tableall)
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
