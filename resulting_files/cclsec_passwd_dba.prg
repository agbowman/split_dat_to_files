CREATE PROGRAM cclsec_passwd:dba
 PAINT
 DECLARE username = vc WITH noconstant(" ")
 DECLARE domainname = vc WITH noconstant(" ")
 DECLARE pwdcurrent = vc WITH noconstant(" ")
 DECLARE pwdnew1 = vc
 DECLARE pwdnew2 = vc
 DECLARE errormsg = vc WITH private
 DECLARE error2msg = vc WITH private
 DECLARE expiry = i2 WITH private, noconstant(0)
 DECLARE usernamelen = i4 WITH private, noconstant(uar_secgetusernamelen())
 IF (curenv != 0)
  GO TO exit_now
 ENDIF
 IF (substring(1,1,reflect(parameter(3,0)))="C")
  SET username = parameter(1,0)
  SET domainname = parameter(2,0)
  SET pwdcurrent = parameter(3,0)
  SET expiry = 1
  SET usernamelen = size(username,1)
 ELSEIF (usernamelen > 0)
  SET username = fillstring(30,"X")
  SET domainname = fillstring(30,"X")
  SET stat = uar_secgetusername(username,30)
  SET stat = uar_secgetdomainname(domainname,30)
 ENDIF
#enter_secinfo
 CALL clear(1,1)
 SET error2msg = " "
 IF (expiry=1)
  CALL text(1,1,"Your password has expired and must be changed.")
 ELSE
  CALL text(1,1,"Changing Millennium password")
  CALL text(4,1,"Current V500 Password:")
  IF (usernamelen < 1)
   CALL text(7,1,"(Hit PF3 or RETURN to abort password change)")
  ENDIF
 ENDIF
 CALL text(2,1,"V500 Username:")
 CALL text(3,1,"V500 Domain:")
 CALL text(5,1,"New V500 Password:")
 CALL text(6,1,"Repeat New Password:")
 SET accept = nopatstring
 IF (usernamelen > 0)
  CALL text(2,30,cnvtupper(username))
  CALL text(3,30,cnvtupper(domainname))
 ENDIF
 IF (expiry != 1)
  IF (usernamelen < 1)
   CALL accept(2,30,"P(30);C"," ")
   IF (curaccept=" ")
    GO TO exit_now
   ELSE
    SET username = curaccept
   ENDIF
   CALL accept(3,30,"P(30);C"," ")
   SET domainname = curaccept
  ENDIF
  CALL accept(4,30,"P(30);CHE","")
  SET pwdcurrent = curaccept
 ENDIF
 CALL accept(5,30,"P(30);CHE","")
 SET pwdnew1 = curaccept
 CALL accept(6,30,"P(30);CHE","")
 SET pwdnew2 = curaccept
 IF (pwdnew1 != pwdnew2)
  SET stat = - (99)
  SET errormsg = "ERROR: The passwords do not match!"
 ELSE
  SET stat = uar_secchangepassword(nullterm(username),nullterm(domainname),nullterm(pwdcurrent),
   nullterm(pwdnew1))
  SET errormsg = build("V500 CHANGE PASSWORD FAILURE (status=",stat,")")
  CASE (stat)
   OF 2:
    SET error2msg = "You provided an incorrect current password."
   OF 16:
    SET error2msg = "This account cannot change its password."
   OF 17:
    SET error2msg = "The system will not allow old passwords to be reused."
   OF 18:
    SET error2msg = "The system will not allow that new password."
   OF 19:
    SET error2msg = "The system will not allow that new password."
  ENDCASE
 ENDIF
 IF (stat=0)
  CALL clear(1,1)
  CALL text(3,1,"V500 CHANGE PASSWORD SUCCESS")
  IF (expiry=1)
   EXECUTE cclseclogin2 username, domainname, pwdnew1
   IF ((xxcclseclogin->loggedin=1))
    CALL text(5,1,"V500 SECURITY LOGIN SUCCESS")
   ELSE
    CALL text(5,1,build("V500 SECURITY LOGIN FAILURE (Uar functions disabled) status=",stat))
   ENDIF
  ENDIF
  GO TO exit_now
 ELSE
  CALL clear(7,1)
  CALL text(8,1,errormsg)
  CALL text(9,8,error2msg)
  CALL text(10,1,"Enter Y to try again, or N to cancel:")
  CALL accept(10,39,"A;CU","Y")
  IF (curaccept="Y")
   GO TO enter_secinfo
  ELSE
   CALL clear(1,1)
   IF (expiry=1)
    CALL text(5,1,"V500 CHANGE PASSWORD CANCELED")
   ENDIF
   GO TO exit_now
  ENDIF
 ENDIF
#exit_now
END GO
