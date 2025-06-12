CREATE PROGRAM bed_get_org_security:dba
 FREE SET reply
 RECORD reply(
   1 org_security_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="SECURITY"
    AND d.info_name="SEC_ORG_RELTN")
  DETAIL
   IF (d.info_number=0)
    reply->org_security_ind = 0
   ELSE
    reply->org_security_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
