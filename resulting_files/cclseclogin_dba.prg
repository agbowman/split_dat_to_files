CREATE PROGRAM cclseclogin:dba
 PAINT
 IF (curenv=0)
  SET xloginck = validate(xxcclseclogin->loggedin,99)
  IF (xloginck != 1)
   RECORD xxcclseclogin(
     1 loggedin = i4
   ) WITH persist
   SET valid = 0
   WHILE (valid=0)
     CALL text(1,1,"V500 UserName")
     CALL text(2,1,"V500 Domain")
     CALL text(3,1,"V500 Password")
     CALL text(4,1,"(Hit PF3 or RETURN to skip security login; this will disable Uar functions)")
     CALL accept(1,20,"p(30);c"," ")
     SET p1 = curaccept
     IF (p1=" ")
      RETURN
     ENDIF
     CALL accept(2,20,"p(30);c"," ")
     SET p2 = curaccept
     SET p3 = fillstring(30," ")
     SET accept = nopatstring
     CALL accept(3,20,"p(30);ce"," ")
     SET p3 = curaccept
     SET stat = 0
     DECLARE _environment = vc
     DECLARE _environment2 = vc
     SET _environment = cnvtupper(logical("environment"))
     CALL text(6,1,_environment)
     IF (cnvtupper(p2) != _environment)
      DECLARE nfind = i2
      SET nfind = findstring("_",p2,1)
      IF (nfind > 0)
       SET _environment2 = substring(1,(nfind - 1),cnvtupper(p2))
      ENDIF
     ENDIF
     IF (((cnvtupper(p2)=_environment) OR (_environment=_environment2)) )
      EXECUTE cclseclogin2 p1, p2, p3
      IF ((xxcclseclogin->loggedin=1))
       CALL clear(6,1)
       CALL text(6,1,"V500 SECURITY LOGIN SUCCESS")
       SET valid = 1
      ELSEIF (stat=11)
       EXECUTE cclsec_passwd p1, p2, p3
       SET valid = 1
      ELSE
       CALL text(6,1,build("V500 SECURITY LOGIN FAILURE (Security context disabled) status=",stat))
       SET valid = 0
      ENDIF
      CALL text(7,1,"Enter Y to continue")
      CALL accept(7,25,"p;cu","Y")
      IF (curaccept != "Y")
       SET valid = 1
      ENDIF
     ELSE
      CALL text(6,1,build("V500 SECURITY LOGIN WARNING! (DOMAIN= ",cnvtupper(p2),
        " does not match current ENVIRONMENT= ",_environment,". Security context disabled)"))
      SET valid = 0
      CALL text(7,1,"Retry (Y/N) ")
      CALL accept(7,25,"p;cu","Y")
      IF (curaccept != "Y")
       SET valid = 1
      ENDIF
     ENDIF
   ENDWHILE
   CALL clear(1,1)
  ENDIF
 ENDIF
END GO
