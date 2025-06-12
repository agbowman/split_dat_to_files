CREATE PROGRAM dm_disable_fk_cons:dba
 PAINT
 CALL text(2,1,"***** This program will disable all *****")
 CALL text(3,1,"***** foreign key constraints.      *****")
#display
 CALL text(6,1,"Enter C)ontinue, Q)uit:      ")
 CALL accept(6,26,"A;cu","Q")
 IF (curaccept != "C"
  AND curaccept != "Q")
  GO TO display
 ELSE
  IF (curaccept="Q")
   GO TO end_program
  ENDIF
 ENDIF
 SET cons_name[5000] = fillstring(30," ")
 SET cons_table_name[5000] = fillstring(30," ")
 SET cons_cnt = 0
 SELECT INTO "nl:"
  u.table_name, u.constraint_name
  FROM user_constraints u
  WHERE u.constraint_type="R"
   AND u.status="ENABLED"
  DETAIL
   cons_cnt = (cons_cnt+ 1), cons_table_name[cons_cnt] = u.table_name, cons_name[cons_cnt] = u
   .constraint_name
  WITH nocounter
 ;end select
 CALL text(8,1,"*** Disable FK Constraints ***")
 FOR (x = 1 TO cons_cnt)
   SET cons_buff = fillstring(300," ")
   SET cons_buff = concat("RDB ALTER TABLE ",trim(cons_table_name[x])," DISABLE CONSTRAINT ",trim(
     cons_name[x])," GO ")
   CALL text(8,1,substring(1,75,cons_buff))
   CALL parser(cons_buff,1)
 ENDFOR
#end_program
END GO
