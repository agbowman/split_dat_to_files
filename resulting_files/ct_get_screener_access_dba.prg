CREATE PROGRAM ct_get_screener_access:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 RECORD calling_protlist(
   1 skip = i2
   1 org_security_ind = i2
   1 org_security_fnd = i2
   1 protocol_list[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 SET calling_protlist->skip = 1
 SET calling_protlist->org_security_fnd = 0
 EXECUTE ct_get_protocol_access request->mode_ind WITH replace("PROTLIST","CALLING_PROTLIST")
 SET prot_cnt = size(calling_protlist->protocol_list,5)
 IF (prot_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "April 21, 2010"
END GO
