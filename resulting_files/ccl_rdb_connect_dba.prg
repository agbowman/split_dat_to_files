CREATE PROGRAM ccl_rdb_connect:dba
 PROMPT
  "Enter Oracle userid: " = "v500",
  "Enable debugging (0)= " = 0
 DECLARE rdbmslocal_connect = vc WITH persist
 IF (textlen(trim(currdbhandle)) > 0)
  CALL echo(
   "CCL_RDB_CONNECT: Database connection already exists. Use FREE DEFINE ORACLESYSTEM GO to reconnect."
   )
  GO TO end_program
 ENDIF
 EXECUTE ccl_rdb_get_connect  $1,  $2, ""
 SET _rdb_connect = concat("define oraclesystem '",rdbmslocal_connect,"' go")
 CALL parser(_rdb_connect)
 CALL echo(concat("CCL_RDB_CONNECT: CURRDBUSER= ",trim(currdbuser),", CURRDBLINK= ",trim(currdblink),
   ", CURRDBSYS= ",
   trim(currdbsys)))
#end_program
END GO
