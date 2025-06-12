CREATE PROGRAM ccluserlogin:dba
 DECLARE fname = c80
 SET fname = cnvtlower(build("login_",curuser,".ccl"))
 IF (findfile(fname)=0)
  SET fname = cnvtlower(build("login_default.ccl"))
 ENDIF
 CALL compile(fname)
END GO
