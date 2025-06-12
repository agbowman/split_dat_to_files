CREATE PROGRAM dts_get_org_security:dba
 RECORD reply(
   1 org_security_on = i2
   1 confid_security_on = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->org_security_on = 0
 SET reply->confid_security_on = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain="SECURITY"
    AND dm.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
  DETAIL
   IF (dm.info_name="SEC_ORG_RELTN"
    AND dm.info_number=1)
    reply->org_security_on = 1
   ELSEIF (dm.info_name="SEC_CONFID"
    AND dm.info_number=1)
    reply->confid_security_on = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
