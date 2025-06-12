CREATE PROGRAM bmdi_get_adt_by_resourceloccd:dba
 RECORD reply(
   1 list[*]
     2 device_alias = c40
     2 device_cd = f8
     2 location_cd = f8
     2 resource_loc_cd = f8
     2 association_id = f8
     2 association_dt_tm = dq8
     2 dis_association_dt_tm = dq8
     2 person_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 active_ind = i2
     2 device_ind = i2
     2 mobile_ind = i2
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
 IF ((request->resource_loc_cd <= 0))
  SET sfailed = "I"
  GO TO no_valid_ids
 ENDIF
 RECORD rep_servres_child(
   1 qual[*]
     2 level = i2
     2 parent_service_resource_cd = f8
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
     2 service_resource_mean = c12
     2 sequence = i4
 )
 SET stat = alterlist(rep_servres_child->qual,1)
 SET rep_servres_child->qual[1].level = 0
 SET rep_servres_child->qual[1].parent_service_resource_cd = 0
 SET rep_servres_child->qual[1].service_resource_cd = request->resource_loc_cd
 DECLARE seg_start = i2 WITH noconstant(0)
 DECLARE seg_end = i2 WITH noconstant(1)
 DECLARE level = i2 WITH noconstant(0)
 DECLARE parent_cnt = i2 WITH noconstant(1)
 DECLARE children_cnt = i2 WITH noconstant(0)
 DECLARE child_index = i2 WITH noconstant(0)
 DECLARE num = i2 WITH noconstant(0)
 WHILE (parent_cnt > 0)
   SET level = (level+ 1)
   SELECT INTO "nl:"
    FROM resource_group rg,
     code_value c
    PLAN (rg
     WHERE expand(num,1,parent_cnt,rg.parent_service_resource_cd,rep_servres_child->qual[(num+
      seg_start)].service_resource_cd)
      AND ((rg.root_service_resource_cd+ 0)=0)
      AND rg.active_ind=1)
     JOIN (c
     WHERE c.code_value=rg.child_service_resource_cd
      AND c.active_ind=1)
    HEAD REPORT
     children_cnt = 0
    DETAIL
     children_cnt = (children_cnt+ 1)
     IF (mod(children_cnt,20)=1)
      stat = alterlist(rep_servres_child->qual,((seg_end+ children_cnt)+ 19))
     ENDIF
     child_index = (seg_end+ children_cnt), rep_servres_child->qual[child_index].level = level,
     rep_servres_child->qual[child_index].parent_service_resource_cd = rg.parent_service_resource_cd,
     rep_servres_child->qual[child_index].service_resource_cd = rg.child_service_resource_cd,
     rep_servres_child->qual[child_index].sequence = rg.sequence
    FOOT REPORT
     stat = alterlist(rep_servres_child->qual,child_index)
    WITH nocounter
   ;end select
   SET seg_start = seg_end
   SET seg_end = (seg_end+ children_cnt)
   SET parent_cnt = children_cnt
   SET children_cnt = 0
 ENDWHILE
 CALL echorecord(rep_servres_child)
 SELECT INTO "nl:"
  FROM bmdi_acquired_data_track badt,
   bmdi_monitored_device bmd,
   (dummyt d  WITH seq = value(size(rep_servres_child->qual,5)))
  PLAN (d)
   JOIN (badt
   WHERE (((badt.resource_loc_cd=rep_servres_child->qual[d.seq].service_resource_cd)
    AND badt.active_ind=1) OR ((badt.resource_loc_cd=rep_servres_child->qual[d.seq].
   service_resource_cd)
    AND badt.person_id=0
    AND badt.parent_entity_id=0)) )
   JOIN (bmd
   WHERE bmd.resource_loc_cd=badt.resource_loc_cd)
  HEAD REPORT
   cnt = 0, skip = 0
  DETAIL
   IF ((badt.resource_loc_cd != request->resource_loc_cd)
    AND bmd.mobile_ind=1)
    skip = 1
   ENDIF
   IF (skip=0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->list,(cnt+ 9))
    ENDIF
    reply->list[cnt].device_alias = bmd.device_alias, reply->list[cnt].device_ind = bmd.device_ind,
    reply->list[cnt].mobile_ind = bmd.mobile_ind,
    reply->list[cnt].device_cd = badt.device_cd, reply->list[cnt].location_cd = badt.location_cd,
    reply->list[cnt].resource_loc_cd = badt.resource_loc_cd,
    reply->list[cnt].association_id = badt.association_id, reply->list[cnt].association_dt_tm = badt
    .association_dt_tm, reply->list[cnt].person_id = badt.person_id,
    reply->list[cnt].parent_entity_name = badt.parent_entity_name, reply->list[cnt].parent_entity_id
     = badt.parent_entity_id, reply->list[cnt].dis_association_dt_tm = badt.dis_association_dt_tm,
    reply->list[cnt].active_ind = badt.active_ind
   ENDIF
   skip = 0
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_resourceloccd"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_adt_by_resourceloccd"
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_resourceloccd"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ELSEIF (sfailed="N")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_resourceloccd"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unit code in request is NOT a nurseunit"
  GO TO exit_script
 ENDIF
#unsupported_option
 IF (sfailed="U")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_adt_by_resourceloccd"
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
