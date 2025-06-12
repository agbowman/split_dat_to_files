CREATE PROGRAM bmdi_get_mon_dev_categ:dba
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
     2 strt_model_id = f8
     2 strt_model_child_id = f8
     2 mobile_ind = i2
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 device_category_cd = f8
     2 device_category_disp = c40
     2 device_category_desc = c60
     2 device_category_mean = c12
     2 device_category_type_cd = f8
     2 device_category_type_disp = c40
     2 device_category_type_desc = c60
     2 device_category_type_mean = c12
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
 DECLARE child_ind = i2 WITH noconstant(1)
 SELECT INTO "nl:"
  FROM bmdi_monitored_device dmd,
   strt_model sm
  PLAN (dmd)
   JOIN (sm
   WHERE sm.strt_model_id=evaluate(dmd.strt_model_child_id,0.0,dmd.strt_model_id,dmd
    .strt_model_child_id))
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
   reply->devlist[cnt].strt_model_cd = sm.strt_model_cd, reply->devlist[cnt].strt_model_id = dmd
   .strt_model_id, reply->devlist[cnt].strt_model_child_id = dmd.strt_model_child_id,
   reply->devlist[cnt].location_cd = dmd.location_cd, reply->devlist[cnt].mobile_ind = dmd.mobile_ind,
   reply->devlist[cnt].device_category_cd = sm.device_category_cd,
   reply->devlist[cnt].device_category_type_cd = sm.device_category_type_cd
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_mon_dev_categ"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_mon_dev_categ"
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_mon_dev_categ"
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
