CREATE PROGRAM cclsqldef
 PROMPT
  "System tables (Y/N) (N): " = "N",
  "Table name (*): " = "*",
  "Dictionary database (SQLUSER): " = "SQLUSER"
 IF (cnvtupper( $1)="Y")
  SET p_type = "S"
  SET p_db = "SQLSYSTEM"
  SET p_output = "FDSQLSYSTEM"
  SET p_long_maxlen = 2000
  SET p_long_maxlen2 = 2000
  SET p_maxlen = 8000
 ELSE
  SET p_type = "U"
  SET p_db = "SQLUSER"
  SET p_output = "FDSQLUSER"
  SET p_long_maxlen = 32000
  SET p_long_maxlen2 = 32768
  SET p_maxlen = 40000
 ENDIF
 SELECT
  IF (p_type="S")
   WHERE s.id=c.id
    AND s.type="S"
    AND (s.name= $2)
    AND c.name != "page"
  ELSE
   WHERE s.id=c.id
    AND s.type="U"
    AND (s.name= $2)
    AND c.name != "page"
  ENDIF
  INTO trim(p_output)
  s.name, c.name, c.type,
  c.length
  FROM sysobjects s,
   syscolumns c
  HEAD REPORT
   ";", p_output, row + 1
   IF (( $2=char(0)))
    "drop database ", p_db, " with deps_deleted go",
    row + 1, "create database ", p_db,
    row + 1, "  organization(oracle)", row + 1,
    "  format(undefined)", row + 1, "  size(",
    p_maxlen"#####", ")", row + 1,
    "  type(s)", row + 1, "  schema(sqlsystem)",
    row + 1, "go", row + 1
   ENDIF
   row + 1
  HEAD s.name
   "drop table ", s.name, " go",
   row + 1
   IF (( $2 != char(0)))
    "drop ddlrecord ", s.name, " from database ",
    p_db, " with deps_deleted go", row + 1
   ENDIF
   "create ddlrecord ", s.name, " from database ",
   p_db, row + 1, "table ",
   s.name, row + 1
  DETAIL
   col 3, "1 ", c.name,
   col 38
   CASE (c.type)
    OF 34:
     IF (c.name="*BLOB*")
      " = vgc", p_long_maxlen2"#####;L"
     ELSE
      " = vgc", p_long_maxlen"#####;L"
     ENDIF
     ,col 50,"ccl(",
     CALL print(trim(c.name))")",col 90," ;image"
    OF 35:
     IF (c.name="*BLOB*")
      " = vc", p_long_maxlen2"#####;L"
     ELSE
      " = vc", p_long_maxlen"#####;L"
     ENDIF
     ,col 50,"ccl(",
     CALL print(trim(c.name))")",col 90," ;text"
    OF 37:
     " = gvc",
     CALL print(cnvtstring(abs(c.length)))col 50,
     "ccl(",
     CALL print(trim(c.name))")",
     col 90," ;varbinary"
    OF 38:
     " = i",c.length"#",col 50,
     "ccl(",
     CALL print(trim(c.name))")",
     col 90," ;intn"
    OF 39:
     IF (c.length=0)
      " = vc128"
     ELSE
      " = vc",
      CALL print(cnvtstring(abs(c.length)))
     ENDIF
     ,col 50,"ccl(",
     CALL print(trim(c.name))")",col 90," ;varchar"
    OF 45:
     " = gc",
     CALL print(cnvtstring(abs(c.length)))col 50,
     "ccl(",
     CALL print(trim(c.name))")",
     col 90," ;binary"
    OF 47:
     " = c",
     CALL print(cnvtstring(abs(c.length)))col 50,
     "ccl(",
     CALL print(trim(c.name))")",
     col 90," ;char"
    OF 48:
     " = i1",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;tinyint"
    OF 50:
     " = i",c.length"#",col 50,
     "ccl(",
     CALL print(trim(c.name))")",
     col 90," ;bit"
    OF 52:
     " = i2",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;smallint"
    OF 56:
     " = i4",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;int"
    OF 59:
     " = f4",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;real"
    OF 61:
     " = dq8",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;datetime"
    OF 62:
     " = f8",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;float"
    OF 109:
     " = f",c.length"#",col 50,
     "ccl(",
     CALL print(trim(c.name))")",
     col 90," ;floatn"
    OF 111:
     " = dq8",col 50,"ccl(",
     CALL print(trim(c.name))")",col 90,
     " ;datetime"
    OF 39:
     col 90," ;sysname ignore"
    OF 58:
     col 90," ;smalldatetime ignore"
    OF 60:
     col 90," ;money ignore"
    OF 110:
     col 90," ;moneyn ignore"
    OF 122:
     col 90," ;smallmoney ignore"
    ELSE
     col 90," ;unknown ignore"
   ENDCASE
   col 115,
   CALL print(build("type:",c.type,",len:",c.length)), row + 1
  FOOT  s.name
   "end table ", s.name, row + 1,
   "go ", row + 1
  WITH noformfeed, maxrow = 1
 ;end select
 CALL echo(" ",1)
 CALL echo(" ",1)
 CALL echo(concat("Created file ccluserdir:",p_output),1)
 CALL echo(" ",1)
END GO
