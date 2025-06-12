CREATE PROGRAM dcp_get_security_settings:dba
 RECORD reply(
   1 encounter_security_enabled = i2
   1 confidentiality_enabled = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->encounter_security_enabled = 0
 SET reply->confidentiality_enabled = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="SECURITY"
   AND dm.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
  DETAIL
   IF (dm.info_name="SEC_ORG_RELTN")
    reply->encounter_security_enabled = dm.info_number
   ELSE
    reply->confidentiality_enabled = dm.info_number
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
