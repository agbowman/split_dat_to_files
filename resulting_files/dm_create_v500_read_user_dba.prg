CREATE PROGRAM dm_create_v500_read_user:dba
 IF (currdb="DB2UDB")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dba_users
  WHERE username="V500_READ"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***********************")
  CALL echo("Creating V500_READ user")
  CALL echo("***********************")
  CALL parser("rdb create user v500_read")
  CALL parser("identified by v500_read")
  CALL parser("default tablespace misc")
  CALL parser("temporary tablespace temp go")
  CALL parser("rdb grant create session, select any table to v500_read go")
  SELECT INTO "nl:"
   FROM dba_users
   WHERE username="V500_READ"
   WITH nocounter
  ;end select
  IF (curqual=1)
   CALL echo("************************************")
   CALL echo("Creating V500_READ user - Successful")
   CALL echo("************************************")
  ENDIF
 ELSE
  CALL echo("*********************************")
  CALL echo("V500_READ user already exists !!!")
  CALL echo("*********************************")
 ENDIF
#exit_script
END GO
