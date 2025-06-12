CREATE PROGRAM di_get_mon_devs:dba
 RECORD reply(
   1 devlist[*]
     2 monitored_device_id = f8
     2 device_cd = f8
     2 device_disp = c40
     2 device_desc = c60
     2 device_mean = c12
     2 device_alias = c40
     2 strt_model_cd = f8
     2 strt_model_disp = c40
     2 strt_model_desc = c60
     2 strt_model_mean = c12
     2 mobile_ind = i2
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 resource_loc_cd = f8
     2 resource_loc_disp = c40
     2 resource_loc_desc = c60
     2 resource_loc_mean = c12
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM bmdi_monitored_device dmd,
   strt_model sm
  PLAN (dmd)
   JOIN (sm
   WHERE sm.strt_model_id=dmd.strt_model_id)
  ORDER BY dmd.device_alias
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->devlist,(cnt+ 9))
   ENDIF
   reply->devlist[cnt].monitored_device_id = dmd.monitored_device_id, reply->devlist[cnt].
   device_alias = dmd.device_alias, reply->devlist[cnt].device_cd = dmd.device_cd,
   reply->devlist[cnt].device_disp = uar_get_code_display(dmd.device_cd), reply->devlist[cnt].
   device_desc = uar_get_code_description(dmd.device_cd), reply->devlist[cnt].device_mean =
   uar_get_code_meaning(dmd.device_cd),
   reply->devlist[cnt].strt_model_cd = sm.strt_model_cd, reply->devlist[cnt].strt_model_disp =
   uar_get_code_display(sm.strt_model_cd), reply->devlist[cnt].strt_model_desc =
   uar_get_code_description(sm.strt_model_cd),
   reply->devlist[cnt].strt_model_mean = uar_get_code_meaning(sm.strt_model_cd), reply->devlist[cnt].
   location_cd = dmd.location_cd, reply->devlist[cnt].location_disp = uar_get_code_display(dmd
    .location_cd),
   reply->devlist[cnt].location_desc = uar_get_code_description(dmd.location_cd), reply->devlist[cnt]
   .location_mean = uar_get_code_meaning(dmd.location_cd), reply->devlist[cnt].resource_loc_cd = dmd
   .resource_loc_cd,
   reply->devlist[cnt].resource_loc_disp = uar_get_code_display(dmd.resource_loc_cd), reply->devlist[
   cnt].resource_loc_desc = uar_get_code_description(dmd.resource_loc_cd), reply->devlist[cnt].
   resource_loc_mean = uar_get_code_meaning(dmd.resource_loc_cd),
   reply->devlist[cnt].mobile_ind = dmd.mobile_ind, reply->devlist[cnt].active_ind = 1
  FOOT REPORT
   stat = alterlist(reply->devlist,cnt)
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "di_get_mon_devs"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "di_get_mon_devs"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 GO TO exit_script
#no_valid_ids
 IF (sfailed="I")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "di_get_mon_devs"
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
