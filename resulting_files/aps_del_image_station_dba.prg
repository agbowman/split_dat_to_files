CREATE PROGRAM aps_del_image_station:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DELETE  FROM ap_prefix_station_r apsr
  PLAN (apsr
   WHERE (apsr.station_id=request->station_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
   station_id)
 ENDIF
 DELETE  FROM ap_image_station ais
  PLAN (ais
   WHERE (ais.station_id=request->station_id))
  WITH nocounter
 ;end delete
 IF (curqual != 1)
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "AP_IMAGE_STATION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
   station_id)
  ROLLBACK
  GO TO exit_script
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
