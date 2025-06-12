CREATE PROGRAM cclsecloginf:dba
 SET xloginck = validate(xxcclseclogin->loggedin,99)
 IF (xloginck=1)
  SET xxcclseclogin->loggedin = 0
 ENDIF
 EXECUTE cclseclogin
END GO
