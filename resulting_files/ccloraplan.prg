CREATE PROGRAM ccloraplan
 PAINT
  video(r), box(1,1,14,80), box(1,1,4,80),
  clear(2,2,78), text(02,10,"CCL PROGRAM CCLORAPLAN"), clear(3,2,78),
  text(03,05,"Report to generate ORACLE plan for a ORACLE statement"), video(n), text(05,05,
   "MINE/CRT/printer/file"),
  text(06,05,"DELETE(D) SELECT(S/X/Y/Z)"), text(07,05,"PLAN ID"), accept(05,35,"P(20);CU","MINE"),
  accept(06,35,"A;CU","S"
   WHERE curaccept IN ("D", "S", "X", "Y", "Z")), accept(07,35,"P(31);CU",concat(curuser,"*")), clear
  (1,1)
 RECORD rec(
   1 qual[*]
     2 level = i4
 )
 SET rec_cnt = 100
 SET stat = alterlist(rec->qual,rec_cnt)
 IF (( $2="D"))
  DELETE  FROM plan_table p
   WHERE p.statement_id=patstring( $3)
  ;end delete
 ELSEIF (( $2="X"))
  CALL parser("RDB SELECT p.statement_id,SUBSTR(LEVEL-1,1,6) LEV, SUBSTR(TO_CHAR(P.ID),1,6) ID,")
  CALL parser("SUBSTR(TO_CHAR(P.PARENT_ID),1,6) PARENT_ID,")
  CALL parser(
   "P.OPERATION, SUBSTR(P.OPTIONS,1,30) OPTIONS,P.OBJECT_NAME,SUBSTR(P.OPTIMIZER,1,30) OPTIMIZER")
  CALL parser("FROM PLAN_TABLE P ")
  CALL parser("WHERE   P.STATEMENT_ID LIKE ")
  CALL parser(build("'",patstring( $3,1),"'"))
  CALL parser("CONNECT BY PRIOR P.ID = P.PARENT_ID AND P.STATEMENT_ID LIKE ")
  CALL parser(build("'",patstring( $3,1),"'"))
  CALL parser(" START   WITH P.ID = 0 ")
  CALL parser(" ORDER BY P.STATEMENT_ID, P.ID ")
  CALL parser(" END GO ")
