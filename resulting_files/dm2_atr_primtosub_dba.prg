CREATE PROGRAM dm2_atr_primtosub:dba
 IF (validate(docd_reply->status,"2") != "2"
  AND validate(docd_reply->status,"3") != "3")
  SET docd_reply->status = "S"
 ENDIF
END GO
