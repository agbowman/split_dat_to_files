CREATE PROGRAM bmdi_get_adt_by_personid:dba
 RECORD reply(
   1 list[*]
     2 device_cd = f8
     2 location_cd = f8
     2 association_id = f8
     2 association_dt_tm = dq8
     2 dis_association_dt_tm = dq8
     2 person_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
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
 IF ((request->person_id <= 0))
  SET sfailed = "I"
  GO TO no_valid_ids
 ENDIF
 SELECT INTO "nl:"
  FROM bmdi_acquired_data_track badt
  WHERE (badt.person_id=request->person_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->list,(cnt+ 9))
   ENDIF
   reply->list[cnt].device_cd = badt.device_cd, reply->list[cnt].location_cd = badt.location_cd,
   reply->list[cnt].association_id = badt.association_id,
   reply->list[cnt].association_dt_tm = badt.association_dt_tm, reply->list[cnt].person_id = badt
   .person_id, reply->list[cnt].parent_entity_name = badt.parent_entity_name,
   reply->list[cnt].parent_entity_id = badt.parent_entity_id, reply->list[cnt].dis_association_dt_tm
    = badt.dis_association_dt_tm, reply->list[cnt].active_ind = badt.active_ind
  FOOT REPORT
   stat = alterlist(reply->list,cnt)
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_personid"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_adt_by_personid"
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_personid"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ELSEIF (sfailed="N")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_personid"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unit code in request is NOT a nurseunit"
  GO TO exit_script
 ENDIF
#unsupported_option
 IF (sfailed="U")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_personid"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Combination of Request Attribute values unsupported"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (((sfailed="I") OR (((sfailed="U") OR (sfailed="N")) )) )
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
