CREATE PROGRAM cclexport2
 SET reclen = 0
 SET fctr = 0
 RECORD f(
   1 fld[100]
     2 fieldname = c31
     2 fieldtype = c1
 )
 SELECT INTO "nl:"
  a.table_name, l.attr_name, l.type
  FROM dtableattr a,
   dtableattrl l
  WHERE (a.table_name= $1)
  DETAIL
   fctr += 1, f->fld[fctr].fieldname = l.attr_name, f->fld[fctr].fieldtype = l.type
  WITH noheading, nocounter
 ;end select
 SET sep = "SET "
 SET fieldvalue = " "
 SELECT INTO  $2
  *
  FROM ( $1 t)
  DETAIL
   row + 1, "insert into ",
   CALL print(build( $1))
   FOR (x = 1 TO ftr)
     fieldvalue = value(build("T.",f->fld[x].fieldname)), row + 1
     IF ((f->fld[x].fieldtype="C"))
      CALL print(build(sep,f->fld[x].fieldname," = ^",fieldvalue,"^"))
     ELSE
      CALL print(build(sep,f->fld[x].fieldname," = ",fieldvalue))
     ENDIF
   ENDFOR
   sep = ","
  WITH nocounter, noheading
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
