CREATE PROGRAM cclexport
 SET reclen = 0
 SELECT INTO  $2
  a.table_name, l.attr_name
  FROM dtableattr a,
   dtableattrl l
  WHERE (a.table_name= $1)
   AND l.structtype="F"
  HEAD a.table_name
   reclen = 0, "select into table ",
   CALL print( $6),
   row + 1, sep = " "
  DETAIL
   IF ((l.len >  $5))
    reclen +=  $5,
    CALL print(build(sep,l.attr_name,"=substring(1,", $5,",X.",
     l.attr_name,")"))
   ELSE
    reclen += l.len,
    CALL print(build(sep,"X.",l.attr_name))
   ENDIF
   row + 1, sep = ","
  FOOT  a.table_name
   "from ",  $1, " X ",
   row + 1, "WHERE 1=1", row + 1,
   "with nocounter, MAXQUAL(X,",
   CALL print( $4), ")",
   row + 1
  FOOT REPORT
   "GO", row + 1
  WITH nocounter, maxrow = 1, noformfeed,
   format = variable
 ;end select
 CALL compile(build( $2,".DAT"))
 SELECT INTO trim( $3)
  a.table_name, l.attr_name, l.type,
  l.len, l.stat
  FROM dtableattr a,
   dtableattrl l
  WHERE (a.table_name= $6)
  HEAD REPORT
   "DROP DATABASE ", a.table_name, " WITH DEPS_DELETED GO",
   row + 1, "CREATE DATABASE ", a.table_name,
   row + 1, "ORGANIZATION(SEQUENTIAL)", row + 1,
   "FORMAT(FIXED)", row + 1,
   CALL print(build("SIZE(",reclen,")")),
   row + 1, "TYPE(U)", row + 1,
   "GO", row + 1, "DROP DDLRECORD ",
   a.table_name, " FROM DATABASE ", a.table_name,
   " WITH DEPS_DELETED GO", row + 1, "CREATE DDLRECORD ",
   a.table_name, " FROM DATABASE ", a.table_name,
   row + 1, "TABLE ", a.table_name,
   row + 1
  DETAIL
   "1 ", l.attr_name, " = ",
   CALL print(build(l.type,l.len)), "  ccl(", l.attr_name,
   ")", row + 1
  FOOT REPORT
   "END TABLE ", a.table_name, row + 1,
   "GO", row + 1
  WITH nocounter, maxrow = 1, noformfeed,
   format = variable
 ;end select
 CALL compile(build( $3,".DAT"))
END GO
