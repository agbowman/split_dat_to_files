CREATE PROGRAM dm_ocd_incl_file:dba
 SET errormsg = fillstring(132," ")
 SET error_check = 0
 SET error_check = error(errormsg,1)
 CALL compile( $1)
 IF (error_check != 0)
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = errormsg
 ELSE
  SET docd_reply->status = "S"
  SET docd_reply->err_msg = " "
 ENDIF
END GO
