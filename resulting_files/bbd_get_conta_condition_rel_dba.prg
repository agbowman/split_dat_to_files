CREATE PROGRAM bbd_get_conta_condition_rel:dba
 RECORD reply(
   1 container_condition_id = f8
   1 container_temperature = f8
   1 container_temperature_degree_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->container_condition_id = 0
 SELECT INTO "nl:"
  c.*
  FROM container_condition_r c
  WHERE (c.container_type_cd=request->container_cd)
   AND (c.condition_cd=request->condition_cd)
   AND c.active_ind=1
  DETAIL
   IF (c.container_condition_id > 0)
    reply->container_condition_id = c.container_condition_id, reply->container_temperature = c
    .cntnr_temperature_value, reply->container_temperature_degree_cd = c.cntnr_temperature_degree_cd
   ELSE
    reply->container_condition_id = 0
   ENDIF
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
