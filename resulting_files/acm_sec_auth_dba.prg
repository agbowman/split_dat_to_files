CREATE PROGRAM acm_sec_auth:dba
 IF (validate(acm_sec_auth_def,999)=999)
  CALL echo("Declaring methods for using the Auth Server")
  DECLARE acm_sec_auth_def = i2 WITH persist, constant(1)
  EXECUTE srvrtl
  EXECUTE dpsrtl
  DECLARE nsuccess = i4 WITH persist, constant(1)
  DECLARE nfail = i4 WITH persist, constant(0)
  DECLARE eauthok = i2 WITH persist, constant(0)
  DECLARE eauthinvalid = i2 WITH persist, constant(1)
  DECLARE eauthexists = i2 WITH persist, constant(2)
  DECLARE eauthfailure = i2 WITH persist, constant(3)
  DECLARE eauthnoaccess = i2 WITH persist, constant(4)
  DECLARE eauthdoesnotexist = i2 WITH persist, constant(5)
  DECLARE auth_adduser = i4 WITH persist, constant(0)
  DECLARE auth_modifyuser = i4 WITH persist, constant(1)
  DECLARE auth_removeuser = i4 WITH persist, constant(2)
  DECLARE auth_enumuser = i4 WITH persist, constant(3)
  DECLARE auth_queryuser = i4 WITH persist, constant(4)
  DECLARE auth_enumprivilege = i4 WITH persist, constant(5)
  DECLARE auth_enumrestriction = i4 WITH persist, constant(6)
  DECLARE mhauth = i4 WITH persist, noconstant(0)
  DECLARE mhmsg = i4 WITH persist, noconstant(0)
  DECLARE mhrequest = i4 WITH persist, noconstant(0)
  DECLARE mhreply = i4 WITH persist, noconstant(0)
  SUBROUTINE (beginauth(laction=i4(val)) =i4 WITH persist)
    SET mhauth = uar_authcreate()
    IF (mhauth=0)
     RETURN(nfail)
    ENDIF
    SET mhmsg = uar_authselect(mhauth,laction)
    IF (mhmsg=0)
     CALL uar_authdestroy(mhauth)
     RETURN(nfail)
    ENDIF
    SET mhrequest = uar_srvcreaterequest(mhmsg)
    IF (mhrequest=0)
     CALL uar_authdestroy(mhauth)
     RETURN(nfail)
    ENDIF
    SET mhreply = uar_srvcreatereply(mhmsg)
    IF (mhreply=0)
     CALL uar_srvdestroyinstance(mhrequest)
     CALL uar_authdestroy(mhauth)
     RETURN(nfail)
    ENDIF
    RETURN(nsuccess)
  END ;Subroutine
  DECLARE endauth(null) = null WITH persist
  SUBROUTINE endauth(null)
    CALL uar_srvdestroyinstance(mhreply)
    CALL uar_srvdestroyinstance(mhrequest)
    CALL uar_authdestroy(mhauth)
    SET mhauth = 0
    SET mhrequest = 0
    SET mhreply = 0
  END ;Subroutine
  DECLARE performauth(null) = i4 WITH persist
  SUBROUTINE performauth(null)
    DECLARE status = i2 WITH protect, noconstant
    SET status = uar_srvexecute(mhmsg,mhrequest,mhreply)
    IF (status=eauthok)
     RETURN(nsuccess)
    ELSE
     CALL endauth(null)
     RETURN(nfail)
    ENDIF
  END ;Subroutine
 ENDIF
END GO
