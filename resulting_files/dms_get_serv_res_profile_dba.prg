CREATE PROGRAM dms_get_serv_res_profile:dba
 CALL echo("<==================== Entering DMS_GET_SERV_RES_PROFILE Script ====================>")
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
 FREE SET numresources
 DECLARE numresources = i4 WITH noconstant(0)
 FREE RECORD resources
 RECORD resources(
   1 qual[*]
     2 serviceresourcecd = f8
 )
 FREE SET numparents
 DECLARE numparents = i4 WITH noconstant(0)
 FREE RECORD parents
 RECORD parents(
   1 qual[*]
     2 serviceresourcecd = f8
 )
 SET numresources = 1
 SET stat = alterlist(resources->qual,numresources)
 SET resources->qual[numresources].serviceresourcecd = request->parent_entity_id
 FREE SET done
 DECLARE done = i2 WITH noconstant(0)
 WHILE ( NOT (done))
   CALL echo("while ...")
   CALL echorecord(resources)
   SELECT INTO "nl:"
    dp.parent_entity_id, dp.parent_entity_name
    FROM (dummyt d  WITH seq = value(numresources)),
     dms_profile dp
    PLAN (d)
     JOIN (dp
     WHERE (dp.parent_entity_id=resources->qual[d.seq].serviceresourcecd)
      AND dp.parent_entity_name="SERVICE_RESOURCE")
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
     d.seq, rg.parent_service_resource_cd
     FROM (dummyt d  WITH seq = value(numresources)),
      resource_group rg,
      service_resource sr
     PLAN (d)
      JOIN (rg
      WHERE (rg.child_service_resource_cd=resources->qual[d.seq].serviceresourcecd)
       AND rg.child_service_resource_cd != rg.root_service_resource_cd
       AND rg.resource_group_type_cd > 0
       AND rg.view_type_cd=0
       AND rg.active_ind=1
       AND rg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND rg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (sr
      WHERE sr.service_resource_cd=rg.parent_service_resource_cd
       AND sr.service_resource_type_cd > 0.0
       AND sr.organization_id > 0.0
       AND sr.active_ind=1
       AND sr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND sr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     ORDER BY d.seq, rg.parent_service_resource_cd
     DETAIL
      numparents = (numparents+ 1)
      IF (mod(numparents,10)=1)
       stat = alterlist(parents->qual,(numparents+ 9))
      ENDIF
      parents->qual[numparents].serviceresourcecd = sr.service_resource_cd
     FOOT REPORT
      stat = alterlist(parents->qual,numparents)
     WITH nocounter
    ;end select
    IF (0 < numparents)
     SET numresources = numparents
     SET stat = alterlist(resources->qual,numparents)
     FOR (i = 1 TO numparents)
       SET resources->qual[i].serviceresourcecd = parents->qual[i].serviceresourcecd
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
 FREE RECORD resources
 FREE RECORD parents
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_SERV_RES_PROFILE Script ====================>")
END GO
