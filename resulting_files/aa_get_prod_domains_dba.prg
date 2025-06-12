CREATE PROGRAM aa_get_prod_domains:dba
 RECORD reply(
   1 qual[*]
     2 domain = vc
     2 value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE numdomains = i2 WITH noconstant(0)
 DECLARE returnsize = i2 WITH noconstant(10)
 DECLARE error_check = i2 WITH noconstant(0)
 DECLARE error_message = c132 WITH noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  env.production_ind, env.environment_name
  FROM dm_environment env
  WHERE env.production_ind=1
  DETAIL
   numdomains = (numdomains+ 1)
   IF (mod(numdomains,10)=1)
    stat = alterlist(reply->qual,(numdomains+ 9))
   ENDIF
   reply->qual[numdomains].domain = env.environment_name
  FOOT REPORT
   stat = alterlist(reply->qual,numdomains)
  WITH nocounter
 ;end select
 SET error_check = error(error_message,0)
 IF (error_check=0)
  IF (numdomains=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "AA_Get_Prod_Domains"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DM_ENVIRONMENT SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_message
 ENDIF
END GO
