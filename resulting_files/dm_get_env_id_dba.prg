CREATE PROGRAM dm_get_env_id:dba
 RECORD reply(
   1 env_src_id = f8
   1 env_src_name = c30
   1 env_trgt_id = f8
   1 env_trgt_name = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  dil.info_number, di.info_number, dm.environment_name,
  dme.environment_name
  FROM dm_info di,
   dm_info@loc_mrg_link dil,
   dm_environment dm,
   dm_environment dme
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
   AND di.info_name=dil.info_name
   AND di.info_domain=dil.info_domain
   AND dm.environment_id=dil.info_number
   AND dme.environment_id=di.info_number
  DETAIL
   reply->env_src_id = dil.info_number, reply->env_src_name = dm.environment_name, reply->env_trgt_id
    = di.info_number,
   reply->env_trgt_name = dme.environment_name
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
