CREATE PROGRAM ccloratab:dba
 PAINT
 CALL video(r)
 CALL box(1,1,14,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLORATAB")
 CALL clear(3,2,78)
 CALL text(03,05,"Report to view table definition for ORACLE table.")
 CALL video(n)
 CALL text(06,05,"ORACLE SYSTEM TABLES (Y/N)")
 CALL text(08,05,"DATABASE NAME")
 CALL text(10,05,"TABLE NAME")
 CALL text(11,05,"OWNER NAME")
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
 CALL accept(11,40,"P(31);CU","V500")
 SET p_owner = curaccept
 CALL clear(1,1)
 EXECUTE ccloradef "MINE", p1, 0,
 p2, "*", p3,
 p_owner
END GO
