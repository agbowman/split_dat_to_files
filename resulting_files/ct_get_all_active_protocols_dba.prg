CREATE PROGRAM ct_get_all_active_protocols:dba
 RECORD reply(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE search_for_prots_error = i2 WITH private, constant(1)
 SELECT INTO "nl:"
  pm.prot_master_id
  FROM prot_master pm
  WHERE pm.prot_master_id > 0.00
   AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND (pm.logical_domain_id=domain_reply->logical_domain_id)
  ORDER BY pm.primary_mnemonic
  DETAIL
   prot_cnt += 1
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(reply->protocols,(prot_cnt+ 9))
   ENDIF
   reply->protocols[prot_cnt].prot_master_id = pm.prot_master_id, reply->protocols[prot_cnt].
   primary_mnemonic = pm.primary_mnemonic
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->protocols,prot_cnt)
 CALL echo(build("Protocols found: ",prot_cnt))
 IF (prot_cnt > 0)
  IF (curqual=0)
   SET fail_flag = search_for_prots_error
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF search_for_prots_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Searching for protocols by role and person"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
 SET last_mod = "003"
 SET mod_date = "May 7, 2019"
END GO
