CREATE PROGRAM ccl_rdb_connectex:dba
 PROMPT
  "Enter Oracle userid: " = "v500",
  "Enter connect mode (RAC): " = ""
 DECLARE rdbmslocal_connect = vc WITH persist
 DECLARE rac_ind = i2 WITH noconstant(0)
 DECLARE sconnectid = vc WITH noconstant(" ")
 DECLARE debug_ind = i2 WITH noconstant(0)
 IF (validate(debug_connect_ind,0)=1)
  SET debug_ind = 1
 ENDIF
 IF (textlen(trim(currdbhandle)) > 0)
  CALL echo(
   "CCL_RDB_CONNECT: Database connection already exists. Use FREE DEFINE ORACLESYSTEM GO to reconnect."
   )
  GO TO end_program
 ENDIF
 SET sconnectid = trim(cnvtupper( $2))
 CALL echo(build("sConnectId= ",sconnectid))
 IF (((cnvtupper(sconnectid)="RAC") OR (cnvtupper(sconnectid)="RAC A/A/A")) )
  CALL echo("Execute ccl_rdb_get_connect for RAC A/A/A mode..")
  EXECUTE ccl_rdb_get_connect:group1  $1, value(debug_ind), "RAC"
 ELSE
  EXECUTE ccl_rdb_get_connect  $1, value(debug_ind), ""
 ENDIF
 IF (rdbmslocal_connect > "")
  SET _rdb_connect = concat("define oraclesystem '",rdbmslocal_connect,"' go")
  CALL parser(_rdb_connect)
 ENDIF
 IF (debug_ind=1)
  CALL echo(concat("CCL_RDB_CONNECT: CURRDBUSER= ",trim(currdbuser),", CURRDBLINK= ",trim(currdblink),
    ", CURRDBSYS= ",
    trim(currdbsys)))
 ENDIF
#end_program
END GO
