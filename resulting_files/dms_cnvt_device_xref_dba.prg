CREATE PROGRAM dms_cnvt_device_xref:dba
 SET modify = predeclare
 CALL echo("<==================== Entering DMS_CNVT_DEVICE_XREF Script ====================>")
 FREE RECORD reply
 RECORD reply(
   1 profile[*]
     2 dms_profile_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 service[*]
       3 device_cd = f8
       3 dms_service_id = f8
       3 service_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD getprofilerequest
 RECORD getprofilerequest(
   1 entity[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 FREE RECORD getprofilereply
 RECORD getprofilereply(
   1 profile[*]
     2 dms_profile_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 parent_entity_display = vc
     2 rules[*]
       3 dms_profile_service_id = f8
       3 dms_content_type_id = f8
       3 content_type = vc
       3 service_name = vc
       3 from_position_cd = f8
       3 from_prsnl_id = f8
       3 details[*]
         4 detail_name = vc
         4 detail_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD addprofilerequest
 RECORD addprofilerequest(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
 )
 FREE RECORD addprofilereply
 RECORD addprofilereply(
   1 dms_profile_id = f8
   1 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD servicenames
 RECORD servicenames(
   1 profile[*]
     2 service[*]
       3 service_name = vc
 )
 FREE RECORD updateprofilerequest
 RECORD updateprofilerequest(
   1 dms_profile_id = f8
   1 service[*]
     2 dms_profile_service_id = f8
     2 content_type = vc
     2 service_name = vc
     2 from_position_cd = f8
     2 from_prsnl_id = f8
     2 servicedetail[*]
       3 name = vc
       3 value = vc
 )
 FREE RECORD updateprofilereply
 RECORD updateprofilereply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET profilecount
 DECLARE profilecount = i4 WITH noconstant(0)
 FREE SET servicecount
 DECLARE servicecount = i4 WITH noconstant(0)
 FREE SET isprofilerule
 DECLARE isprofilerule = i2 WITH noconstant(0)
 FREE SET rulecnt
 DECLARE rulecnt = i4 WITH noconstant(0)
 FREE SET cntr1
 DECLARE cntr1 = i4 WITH noconstant(0)
 FREE SET cntr2
 DECLARE cntr2 = i4 WITH noconstant(0)
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  profile = build(dx.parent_entity_name,dx.parent_entity_id), dx.*, d.*,
  ds.*
  FROM device_xref dx,
   device d,
   dms_service ds
  PLAN (dx
   WHERE dx.parent_entity_name IN ("ORGANIZATION", "LOCATION", "SERVICE_RESOURCE", "PRSNL"))
   JOIN (d
   WHERE d.device_cd=dx.device_cd
    AND d.dms_service_id > 0.0)
   JOIN (ds
   WHERE ds.dms_service_id=d.dms_service_id
    AND ds.dms_service_id > 0)
  ORDER BY profile
  HEAD REPORT
   profilecount = 0, servicecount = 0
  HEAD profile
   profilecount = (profilecount+ 1)
   IF (mod(profilecount,10)=1)
    stat = alterlist(reply->profile,(profilecount+ 9)), stat = alterlist(servicenames->profile,(
     profilecount+ 9))
   ENDIF
   IF (dx.parent_entity_name="PRSNL")
    reply->profile[profilecount].parent_entity_name = "PERSON"
   ELSE
    reply->profile[profilecount].parent_entity_name = dx.parent_entity_name
   ENDIF
   reply->profile[profilecount].parent_entity_id = dx.parent_entity_id, servicecount = 0
  DETAIL
   servicecount = (servicecount+ 1)
   IF (mod(servicecount,10)=1)
    stat = alterlist(reply->profile[profilecount].service,(servicecount+ 9)), stat = alterlist(
     servicenames->profile[profilecount].service,(servicecount+ 9))
   ENDIF
   reply->profile[profilecount].service[servicecount].device_cd = d.device_cd, reply->profile[
   profilecount].service[servicecount].dms_service_id = ds.dms_service_id, reply->profile[
   profilecount].service[servicecount].service_name = ds.service_name,
   servicenames->profile[profilecount].service[servicecount].service_name = ds.service_name
  FOOT  profile
   stat = alterlist(reply->profile[profilecount].service,servicecount), stat = alterlist(servicenames
    ->profile[profilecount].service,servicecount)
  FOOT REPORT
   stat = alterlist(reply->profile,profilecount), stat = alterlist(reply->profile[profilecount].
    service,servicecount), stat = alterlist(servicenames->profile,profilecount),
   stat = alterlist(servicenames->profile[profilecount].service,servicecount)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.subeventstatus.targetobjectname = "DEVICE_XREF, DEVICE"
  SET reply->status_data.subeventstatus.targetobjectvalue = "zero qualified"
  GO TO end_script
 ENDIF
 FOR (cntr1 = 1 TO profilecount)
   SET stat = alterlist(getprofilerequest->entity,1)
   SET getprofilerequest->entity[1].parent_entity_id = reply->profile[cntr1].parent_entity_id
   SET getprofilerequest->entity[1].parent_entity_name = reply->profile[cntr1].parent_entity_name
   EXECUTE dms_get_profile  WITH replace("REQUEST","GETPROFILEREQUEST"), replace("REPLY",
    "GETPROFILEREPLY")
   IF ((getprofilereply->status_data.status="Z"))
    SET addprofilerequest->parent_entity_id = reply->profile[cntr1].parent_entity_id
    SET addprofilerequest->parent_entity_name = reply->profile[cntr1].parent_entity_name
    EXECUTE dms_add_profile  WITH replace("REQUEST","ADDPROFILEREQUEST"), replace("REPLY",
     "ADDPROFILEREPLY")
    IF ((addprofilereply->status_data.status="S"))
     SET reply->profile[cntr1].dms_profile_id = addprofilereply->dms_profile_id
     SET updateprofilerequest->dms_profile_id = addprofilereply->dms_profile_id
     FOR (cntr2 = 1 TO size(servicenames->profile[cntr1].service,5))
      IF (mod(cntr2,10)=1)
       SET stat = alterlist(updateprofilerequest->service,(cntr2+ 9))
      ENDIF
      SET updateprofilerequest->service[cntr2].service_name = servicenames->profile[cntr1].service[
      cntr2].service_name
     ENDFOR
     SET stat = alterlist(updateprofilerequest->service,size(servicenames->profile[cntr1].service,5))
     EXECUTE dms_upd_profile_service  WITH replace("REQUEST","UPDATEPROFILEREQUEST"), replace("REPLY",
      "UPDATEPROFILEREPLY")
     IF ((updateprofilereply->status_data.status="F"))
      SET reply->status_data.subeventstatus.operationname = updateprofilereply->status_data.
      subeventstatus.operationname
      SET reply->status_data.subeventstatus.operationstatus = updateprofilereply->status_data.
      subeventstatus.operationstatus
      SET reply->status_data.subeventstatus.targetobjectname = updateprofilereply->status_data.
      subeventstatus.targetobjectname
      SET reply->status_data.subeventstatus.targetobjectvalue = updateprofilereply->status_data.
      subeventstatus.targetobjectvalue
      GO TO end_script
     ENDIF
    ELSE
     SET reply->status_data.subeventstatus.operationname = addprofilereply->status_data.
     subeventstatus.operationname
     SET reply->status_data.subeventstatus.operationstatus = addprofilereply->status_data.
     subeventstatus.operationstatus
     SET reply->status_data.subeventstatus.targetobjectname = addprofilereply->status_data.
     subeventstatus.targetobjectname
     SET reply->status_data.subeventstatus.targetobjectvalue = addprofilereply->status_data.
     subeventstatus.targetobjectvalue
     GO TO end_script
    ENDIF
   ELSEIF ((getprofilereply->status_data.status="S"))
    SET reply->profile[cntr1].dms_profile_id = getprofilereply->profile[1].dms_profile_id
    SET isprofilerule = 0
    FOR (rulecnt = 1 TO size(getprofilereply->profile[1].rules,5))
      IF ((getprofilereply->profile[1].rules[rulecnt].dms_content_type_id=0.0)
       AND (getprofilereply->profile[1].rules[rulecnt].from_position_cd=0.0)
       AND (getprofilereply->profile[1].rules[rulecnt].from_prsnl_id=0.0))
       SET isprofilerule = 1
      ENDIF
    ENDFOR
    IF (isprofilerule=0)
     SET updateprofilerequest->dms_profile_id = getprofilereply->profile[1].dms_profile_id
     FOR (cntr2 = 1 TO size(servicenames->profile[cntr1].service,5))
      IF (mod(cntr2,10)=1)
       SET stat = alterlist(updateprofilerequest->service,(cntr2+ 9))
      ENDIF
      SET updateprofilerequest->service[cntr2].service_name = servicenames->profile[cntr1].service[
      cntr2].service_name
     ENDFOR
     SET stat = alterlist(updateprofilerequest->service,size(servicenames->profile[cntr1].service,5))
     EXECUTE dms_upd_profile_service  WITH replace("REQUEST","UPDATEPROFILEREQUEST"), replace("REPLY",
      "UPDATEPROFILEREPLY")
     IF ((updateprofilereply->status_data.status="F"))
      SET reply->status_data.subeventstatus.operationname = updateprofilereply->status_data.
      subeventstatus.operationname
      SET reply->status_data.subeventstatus.operationstatus = updateprofilereply->status_data.
      subeventstatus.operationstatus
      SET reply->status_data.subeventstatus.targetobjectname = updateprofilereply->status_data.
      subeventstatus.targetobjectname
      SET reply->status_data.subeventstatus.targetobjectvalue = updateprofilereply->status_data.
      subeventstatus.targetobjectvalue
      GO TO end_script
     ENDIF
    ENDIF
   ELSE
    SET reply->status_data.subeventstatus.operationname = getprofilereply->status_data.subeventstatus
    .operationname
    SET reply->status_data.subeventstatus.operationstatus = getprofilereply->status_data.
    subeventstatus.operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = getprofilereply->status_data.
    subeventstatus.targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = getprofilereply->status_data.
    subeventstatus.targetobjectvalue
    GO TO end_script
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 FREE RECORD reply
 FREE RECORD getprofilerequest
 FREE RECORD getprofilereply
 FREE RECORD addprofilerequest
 FREE RECORD addprofilereply
 FREE RECORD updateprofilerequest
 FREE RECORD updateprofilereply
 CALL echo("<==================== Exiting DMS_CNVT_DEVICE_XREF Script ====================>")
END GO
