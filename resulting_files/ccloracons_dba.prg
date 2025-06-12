CREATE PROGRAM ccloracons:dba
 PAINT
 CALL video(r)
 CALL box(1,1,14,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLORACONS")
 CALL clear(3,2,78)
 CALL text(03,05,"Report to view table constraints for ORACLE table.")
 CALL video(n)
 CALL text(06,05,"ORACLE SYSTEM TABLES (Y/N)")
 CALL text(08,05,"DATABASE NAME")
 CALL text(10,05,"TABLE NAME")
 CALL text(12,05,"CONSTRAINT TYPE (V/C/P/U/R)")
 CALL text(13,05,"OWNER NAME")
 CALL accept(06,40,"A;CU","N"
  WHERE curaccept IN ("N", "Y"))
 SET p1 = curaccept
 IF (p1="Y")
  CALL accept(08,40,"P(31);cu","ORACLESYSTEM")
 ELSE
  CALL accept(08,40,"P(31);cu","V500")
 ENDIF
 SET p2 = curaccept
 SET accept = nopatcheck
 CALL accept(10,40,"P(31);CU",char(42))
 SET p3 = curaccept
 CALL accept(12,40,"P;cu",char(42))
 SET p4 = curaccept
 CALL accept(13,40,"P(31);CU","V500")
 SET p_owner = curaccept
 CALL clear(1,1)
 CALL echo(build("jcm=",p1))
 CALL echo(concat("textlen(p3)= ",build(textlen(p3))))
 IF (textlen(trim(p3)) < 3)
  SELECT
   FROM dummyt
   DETAIL
    col 0,
    "Failed to read constraints. Table name must be minimum of three characters with wildcard."
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 SELECT
  IF (currdb="DB2UDB"
   AND p1="Y")
   FROM dm_tables_doc doc,
    dba_constraints a,
    dba_cons_columns b,
    (dummyt d  WITH seq = 1)
   PLAN (doc
    WHERE doc.table_name=patstring(p3))
    JOIN (a
    WHERE doc.suffixed_table_name=a.table_name
     AND a.constraint_type=patstring(p4)
     AND a.owner=patstring(p_owner))
    JOIN (d)
    JOIN (b
    WHERE a.owner=b.owner
     AND a.constraint_name=b.constraint_name
     AND a.table_name=b.table_name)
  ELSEIF (currdb="DB2UDB"
   AND p1 != "Y")
   FROM dm_tables_doc doc,
    dba_constraints a,
    dba_cons_columns b,
    dummyt d
   PLAN (doc
    WHERE doc.table_name=patstring(p3))
    JOIN (a
    WHERE doc.suffixed_table_name=a.table_name
     AND a.constraint_type=patstring(p4)
     AND a.owner=patstring(p_owner))
    JOIN (d)
    JOIN (b
    WHERE a.owner=b.owner
     AND a.constraint_name=b.constraint_name
     AND a.table_name=b.table_name)
  ELSEIF (p1="Y")
   FROM dba_constraints a,
    dba_cons_columns b,
    (dummyt d  WITH seq = 1)
   PLAN (a
    WHERE a.table_name=patstring(p3)
     AND a.constraint_type=patstring(p4)
     AND a.owner=patstring(p_owner))
    JOIN (d)
    JOIN (b
    WHERE a.owner=b.owner
     AND a.constraint_name=b.constraint_name
     AND a.table_name=b.table_name)
  ELSE
   FROM user_constraints a,
    user_cons_columns b,
    dummyt d
   PLAN (a
    WHERE a.table_name=patstring(p3)
     AND a.constraint_type=patstring(p4)
     AND a.owner=patstring(p_owner))
    JOIN (d)
    JOIN (b
    WHERE a.owner=b.owner
     AND a.constraint_name=b.constraint_name
     AND a.table_name=b.table_name)
  ENDIF
  tname = substring(1,30,a.table_name), colname = substring(1,30,b.column_name), owner = substring(1,
   30,concat("(",trim(a.owner),")")),
  cname = substring(1,30,a.constraint_name), status =
  IF (a.status="DISABLED") "Y"
  ELSE "N"
  ENDIF
  , delete_rule = a.delete_rule,
  type =
  IF (a.constraint_type="C") "Check      "
  ELSEIF (a.constraint_type="P") "Primary Key"
  ELSEIF (a.constraint_type="U") "Unique Key "
  ELSEIF (a.constraint_type="R") "Referential"
  ELSEIF (a.constraint_type="V") "View       "
  ENDIF
  , condition =
  IF (a.constraint_type="C") substring(1,50,a.search_condition)
  ELSEIF (a.constraint_type="P") substring(1,50,build(b.table_name,".",substring(1,30,b.column_name))
    )
  ELSEIF (a.constraint_type="U") substring(1,50,build(b.table_name,".",substring(1,30,b.column_name))
    )
  ELSEIF (a.constraint_type="R") substring(1,50,build(a.r_constraint_name,"=",b.table_name,".",
     substring(1,30,b.column_name)))
  ELSEIF (a.constraint_type="V") substring(1,50,build(b.table_name,".",substring(1,30,b.column_name))
    )
  ENDIF
  HEAD REPORT
   line = fillstring(130,"_")
  HEAD PAGE
   col 0, "Table_name (Owner)", col 30,
   "Constraint Name", col 65, "Type",
   col 76, "Disabled", col 85,
   "Rule", col 95, "Condition/Index Col/Referential Col",
   row + 1, line, row + 1
  HEAD a.table_name
   tname, row + 1, owner,
   row- (1), cnt = 0
  DETAIL
   col 30, cname, col 65,
   type, col 78, status,
   col 85, delete_rule, col 95,
   condition, row + 1, cnt += 1
  FOOT  a.table_name
   IF (((row+ 5) > maxrow))
    BREAK
   ELSEIF (cnt > 2)
    row + 1
   ELSE
    cnt = (3 - cnt), row + cnt
   ENDIF
  WITH counter, maxcol = 200, format = variable,
   outerjoin = d
 ;end select
#end_program
END GO
