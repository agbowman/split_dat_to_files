CREATE PROGRAM daf_migrator_get_env_info:dba
 RECORD reply(
   1 environment_id = f8
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 DECLARE envid = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   envid = di.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->environment_id = 0
  SET reply->message = "No environment_id could be found"
 ELSE
  IF (envid=0)
   SET reply->status_data.status = "F"
   SET reply->environment_id = 0
   SET reply->message = "The environment_id was set to zero"
  ELSE
   SET reply->status_data.status = "S"
   SET reply->environment_id = envid
   SET reply->message = "Found all required environment information"
  ENDIF
 ENDIF
END GO
