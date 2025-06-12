CREATE PROGRAM ccl_createcpc:dba
 DECLARE filename = vc
 SET filename =  $1
 CALL echo(filename)
 FREE SET cpc_file
 SET logical cpc_file value(filename)
 IF (findfile(filename)=0)
  CALL echo(filename)
  SELECT INTO "CPC_FILE"
   d.*
   FROM dummyt
   DETAIL
    "DIO(00)COMP(1)LAND(0)"
   WITH format = variable
  ;end select
 ENDIF
END GO
