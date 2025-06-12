CREATE PROGRAM dms_get_profile:dba
 CALL echo("<==================== Entering DMS_GET_PROFILE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 ENDIF
 SET reply->status_data.status = "F"
 FREE SET numentity
 DECLARE numentity = i4 WITH noconstant(size(request->entity,5))
 FREE SET requestsubset
 RECORD requestsubset(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
 )
 FREE SET replysubset
 RECORD replysubset(
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
 FREE SET numrules
 DECLARE numrules = i4 WITH noconstant(0)
 FREE SET numdetail
 DECLARE numdetail = i4 WITH noconstant(0)
 SET stat = alterlist(reply->profile,numentity)
 FOR (i = 1 TO numentity)
   IF ((((request->entity[i].parent_entity_name="LOCATION")) OR ((request->entity[i].
   parent_entity_name="SERVICE_RESOURCE"))) )
    SET requestsubset->parent_entity_id = request->entity[i].parent_entity_id
    SET requestsubset->parent_entity_name = request->entity[i].parent_entity_name
    IF ((request->entity[i].parent_entity_name="SERVICE_RESOURCE"))
     EXECUTE dms_get_serv_res_profile  WITH replace("REQUEST",requestsubset), replace("REPLY",
      replysubset)
    ELSE
     EXECUTE dms_get_location_profile  WITH replace("REQUEST",requestsubset), replace("REPLY",
      replysubset)
    ENDIF
    IF ((replysubset->status_data.status="S"))
     SET reply->profile[i].dms_profile_id = replysubset->dms_profile_id
     SET reply->profile[i].parent_entity_id = replysubset->parent_entity_id
     SET reply->profile[i].parent_entity_name = replysubset->parent_entity_name
     SET reply->profile[i].parent_entity_display = replysubset->parent_entity_display
    ELSE
     SET reply->status_data.status = replysubset->status_data.status
     SET reply->status_data.subeventstatus.operationname = replysubset->status_data.subeventstatus.
     operationname
     SET reply->status_data.subeventstatus.operationstatus = replysubset->status_data.subeventstatus.
     operationstatus
     SET reply->status_data.subeventstatus.targetobjectname = replysubset->status_data.subeventstatus
     .targetobjectname
     SET reply->status_data.subeventstatus.targetobjectvalue = replysubset->status_data.
     subeventstatus.targetobjectvalue
     GO TO end_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     dp.parent_entity_id, dp.parent_entity_name
     FROM dms_profile dp
     WHERE (dp.parent_entity_id=request->entity[i].parent_entity_id)
      AND (dp.parent_entity_name=request->entity[i].parent_entity_name)
     DETAIL
      reply->profile[i].dms_profile_id = dp.dms_profile_id, reply->profile[i].parent_entity_id = dp
      .parent_entity_id, reply->profile[i].parent_entity_name = dp.parent_entity_name
     WITH nocounter
    ;end select
    IF ((reply->profile[i].dms_profile_id <= 0.0))
     SET reply->status_data.status = "Z"
     SET reply->status_data.subeventstatus.operationname = "SELECT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
     SET reply->status_data.subeventstatus.targetobjectvalue = build(request->entity[i].
      parent_entity_id,"/",request->entity[i].parent_entity_name)
     GO TO end_script
    ENDIF
    IF ((request->entity[i].parent_entity_name="PERSON"))
     SELECT INTO "nl:"
      p.person_id, p.username
      FROM prsnl p
      WHERE (p.person_id=reply->profile[i].parent_entity_id)
      DETAIL
       reply->profile[i].parent_entity_display = p.name_full_formatted
      WITH nocounter
     ;end select
    ELSEIF ((request->entity[i].parent_entity_name="ORGANIZATION"))
     SELECT INTO "nl:"
      o.organization_id, o.org_name
      FROM organization o
      WHERE (o.organization_id=reply->profile[i].parent_entity_id)
      DETAIL
       reply->profile[i].parent_entity_display = o.org_name
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET numrules = 0
   SELECT INTO "nl:"
    d.*, dct.*, dpd.*
    FROM dms_profile_service d,
     dms_content_type dct,
     dms_profile_detail dpd
    PLAN (d
     WHERE (d.dms_profile_id=reply->profile[i].dms_profile_id))
     JOIN (dct
     WHERE dct.dms_content_type_id=outerjoin(d.dms_content_type_id))
     JOIN (dpd
     WHERE dpd.dms_profile_service_id=outerjoin(d.dms_profile_service_id))
    ORDER BY d.dms_profile_service_id
    HEAD d.dms_profile_service_id
     numrules = (numrules+ 1)
     IF (mod(numrules,10)=1)
      stat = alterlist(reply->profile[i].rules,(numrules+ 9))
     ENDIF
     reply->profile[i].rules[numrules].dms_profile_service_id = d.dms_profile_service_id, reply->
     profile[i].rules[numrules].dms_content_type_id = dct.dms_content_type_id, reply->profile[i].
     rules[numrules].content_type = dct.content_type_key,
     reply->profile[i].rules[numrules].service_name = d.service_name, reply->profile[i].rules[
     numrules].from_position_cd = d.from_position_cd, reply->profile[i].rules[numrules].from_prsnl_id
      = d.from_prsnl_id,
     numdetail = 0
    DETAIL
     IF (0 < dpd.dms_profile_detail_id)
      numdetail = (numdetail+ 1)
      IF (mod(numdetail,10)=1)
       stat = alterlist(reply->profile[i].rules[numrules].details,(numdetail+ 9))
      ENDIF
      reply->profile[i].rules[numrules].details[numdetail].detail_name = dpd.detail_name, reply->
      profile[i].rules[numrules].details[numdetail].detail_value = dpd.detail_value
     ENDIF
    FOOT  d.dms_profile_service_id
     stat = alterlist(reply->profile[i].rules[numrules].details,numdetail)
    FOOT REPORT
     stat = alterlist(reply->profile[i].rules,numrules)
    WITH nocounter
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 FREE RECORD requestsubset
 FREE RECORD replysubset
 CALL echo("<==================== Exiting DMS_GET_PROFILE Script ====================>")
END GO
