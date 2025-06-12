CREATE PROGRAM dms_get_location_profile:dba
 CALL echo("<==================== Entering DMS_GET_LOCATION_PROFILE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dms_profile_id = f8
    1 parent_entity_id = f8
    1 parent_entity_name = vc
    1 parent_entity_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE SET numlocations
 DECLARE numlocations = i4 WITH noconstant(0)
 FREE RECORD locations
 RECORD locations(
   1 qual[*]
     2 locationcd = f8
 )
 FREE SET numparents
 DECLARE numparents = i4 WITH noconstant(0)
 FREE RECORD parents
 RECORD parents(
   1 qual[*]
     2 locationcd = f8
 )
 SET numlocations = 1
 SET stat = alterlist(locations->qual,numlocations)
 SET locations->qual[numlocations].locationcd = request->parent_entity_id
 FREE SET done
 DECLARE done = i2 WITH noconstant(0)
 WHILE ( NOT (done))
   CALL echo("while ...")
   CALL echorecord(locations)
   SELECT INTO "nl:"
    dp.parent_entity_id, dp.parent_entity_name
    FROM (dummyt d  WITH seq = value(numlocations)),
     dms_profile dp
    PLAN (d)
     JOIN (dp
     WHERE (dp.parent_entity_id=locations->qual[d.seq].locationcd)
      AND dp.parent_entity_name="LOCATION")
    ORDER BY d.seq
    DETAIL
     reply->dms_profile_id = dp.dms_profile_id, reply->parent_entity_id = dp.parent_entity_id, reply
     ->parent_entity_name = dp.parent_entity_name,
     reply->parent_entity_display = uar_get_code_display(dp.parent_entity_id)
    WITH maxqual(dp,1)
   ;end select
   IF ((0.0 < reply->dms_profile_id))
    SET reply->status_data.status = "S"
    SET done = 1
   ELSE
    SET numparents = 0
    SET stat = alterlist(parents->qual,0)
    SELECT DISTINCT INTO "nl:"
     d.seq, lg.parent_loc_cd
     FROM (dummyt d  WITH seq = value(numlocations)),
      location_group lg,
      location l
     PLAN (d)
      JOIN (lg
      WHERE (lg.child_loc_cd=locations->qual[d.seq].locationcd)
       AND lg.child_loc_cd != lg.root_loc_cd
       AND lg.location_group_type_cd > 0
       AND lg.view_type_cd=0
       AND lg.active_ind=1
       AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l
      WHERE l.location_cd=lg.parent_loc_cd
       AND l.location_type_cd > 0.0
       AND l.organization_id > 0.0
       AND l.active_ind=1
       AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     ORDER BY d.seq, lg.parent_loc_cd
     DETAIL
      numparents = (numparents+ 1)
      IF (mod(numparents,10)=1)
       stat = alterlist(parents->qual,(numparents+ 9))
      ENDIF
      parents->qual[numparents].locationcd = l.location_cd
     FOOT REPORT
      stat = alterlist(parents->qual,numparents)
     WITH nocounter
    ;end select
    IF (0 < numparents)
     SET numlocations = numparents
     SET stat = alterlist(locations->qual,numparents)
     FOR (i = 1 TO numparents)
       SET locations->qual[i].locationcd = parents->qual[i].locationcd
     ENDFOR
    ELSE
     SET reply->status_data.status = "Z"
     SET reply->status_data.subeventstatus.operationname = "SELECT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
     SET reply->status_data.subeventstatus.targetobjectvalue = build(request->parent_entity_id,"/",
      request->parent_entity_name)
     SET done = 1
    ENDIF
   ENDIF
 ENDWHILE
 FREE RECORD locations
 FREE RECORD parents
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_LOCATION_PROFILE Script ====================>")
END GO
