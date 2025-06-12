CREATE PROGRAM bmdi_get_acquired_data_track:dba
 RECORD reply(
   1 device_cd = f8
   1 location_cd = f8
   1 resource_loc_cd = f8
   1 association_id = f8
   1 association_dt_tm = dq8
   1 dis_association_dt_tm = dq8
   1 person_id = f8
   1 parent_entity_name = c32
   1 parent_entity_id = f8
   1 active_ind = i2
   1 monitored_device_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE custom_options = vc
 DECLARE mon_device_key = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM strt_model_custom smc
  WHERE smc.strt_model_id=0
   AND smc.strt_config_id=1282105
   AND process_flag=10
  DETAIL
   custom_options = smc.custom_option
  WITH nocounter
 ;end select
 IF (curqual=1)
  IF (substring(1,1,custom_options)="1")
   SET mon_device_key = "T"
  ELSE
   SET mon_device_key = "F"
  ENDIF
 ENDIF
 SELECT
  IF (mon_device_key="T")INTO "nl:"
   FROM bmdi_acquired_data_track badt
   WHERE (badt.monitored_device_id=request->monitored_device_id)
    AND badt.active_ind=1
  ELSE INTO "nl:"
   FROM bmdi_acquired_data_track badt
   WHERE (badt.device_cd=request->device_cd)
    AND (badt.location_cd=request->location_cd)
    AND (badt.resource_loc_cd=request->resource_loc_cd)
    AND badt.active_ind=1
  ENDIF
  DETAIL
   reply->device_cd = badt.device_cd, reply->location_cd = badt.location_cd, reply->resource_loc_cd
    = badt.resource_loc_cd,
   reply->association_id = badt.association_id, reply->association_dt_tm = badt.association_dt_tm,
   reply->person_id = badt.person_id,
   reply->parent_entity_name = badt.parent_entity_name, reply->parent_entity_id = badt
   .parent_entity_id, reply->dis_association_dt_tm = badt.dis_association_dt_tm,
   reply->active_ind = badt.active_ind, reply->monitored_device_id = badt.monitored_device_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  SET sfailed = "T"
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Retrieval failed!"
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No data matching request"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_acquired_data_track"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_acquired_data_track"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
 ENDIF
 GO TO exit_script
#no_valid_ids
 IF (sfailed="I")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_acquired_data_track"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (sfailed="I")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
