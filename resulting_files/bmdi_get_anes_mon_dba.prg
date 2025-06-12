CREATE PROGRAM bmdi_get_anes_mon:dba
 RECORD reply(
   1 list[*]
     2 device_cd = f8
     2 device_alias = vc
     2 association_id = f8
     2 name_full_formatted = vc
     2 location_cd = f8
     2 person_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 association_dt_tm = dq8
     2 dis_association_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE custom_options = vc
 DECLARE mcount = i4
 SET mcount = 0
 SET reply->status_data.status = "Z"
 CALL echorecord(request)
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
   SELECT INTO "nl:"
    FROM bmdi_acquired_data_track badt,
     bmdi_monitored_device bmd,
     prsnl p
    PLAN (bmd
     WHERE bmd.device_cd > 0)
     JOIN (badt
     WHERE (badt.parent_entity_id=request->parent_entity_id)
      AND (badt.parent_entity_name=request->parent_entity_name)
      AND badt.active_ind=1
      AND bmd.monitored_device_id=badt.monitored_device_id)
     JOIN (p
     WHERE p.person_id=badt.assoc_prsnl_id)
    DETAIL
     mcount = (mcount+ 1), stat = alterlist(reply->list,mcount), reply->list[mcount].device_alias =
     bmd.device_alias,
     reply->list[mcount].location_cd = bmd.monitored_device_id, reply->list[mcount].device_cd = badt
     .device_cd, reply->list[mcount].association_id = badt.association_id,
     reply->list[mcount].parent_entity_id = badt.parent_entity_id, reply->list[mcount].
     parent_entity_name = badt.parent_entity_name, reply->list[mcount].association_dt_tm = badt
     .association_dt_tm,
     reply->list[mcount].dis_association_dt_tm = badt.dis_association_dt_tm, reply->list[mcount].
     active_ind = badt.active_ind, reply->list[mcount].person_id = p.person_id,
     reply->list[mcount].name_full_formatted = p.name_full_formatted
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (mcount >= 1)
  CALL echo("Done")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
