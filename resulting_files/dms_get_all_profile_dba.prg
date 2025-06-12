CREATE PROGRAM dms_get_all_profile:dba
 CALL echo("<==================== Entering DMS_GET_ALL_PROFILE Script ====================>")
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
 FREE SET numprofile
 DECLARE numprofile = i4 WITH noconstant(0)
 IF ((((request->parent_entity_name="LOCATION")) OR ((request->parent_entity_name="SERVICE_RESOURCE")
 )) )
  IF ((request->parent_entity_name="LOCATION")
   AND (request->parent_entity_id > 0))
   EXECUTE dms_get_location_desc_profile
   GO TO end_script
  ELSEIF ((request->parent_entity_name="SERVICE_RESOURCE")
   AND (request->parent_entity_id > 0))
   EXECUTE dms_get_serv_res_desc_profile
   GO TO end_script
  ELSEIF ((request->parent_entity_id=0))
   SELECT INTO "nl:"
    dp.parent_entity_id, dp.parent_entity_name
    FROM dms_profile dp
    WHERE (dp.parent_entity_name=request->parent_entity_name)
    ORDER BY dp.dms_profile_id
    DETAIL
     IF (size(request->parent_entity_type) > 0)
      IF ((request->parent_entity_type=uar_get_code_meaning(dp.parent_entity_id)))
       numprofile = (numprofile+ 1)
       IF (mod(numprofile,10)=1)
        stat = alterlist(reply->profile,(numprofile+ 9))
       ENDIF
       reply->profile[numprofile].dms_profile_id = dp.dms_profile_id, reply->profile[numprofile].
       parent_entity_id = dp.parent_entity_id, reply->profile[numprofile].parent_entity_name = dp
       .parent_entity_name,
       reply->profile[numprofile].parent_entity_display = uar_get_code_display(dp.parent_entity_id)
      ENDIF
     ELSE
      numprofile = (numprofile+ 1)
      IF (mod(numprofile,10)=1)
       stat = alterlist(reply->profile,(numprofile+ 9))
      ENDIF
      reply->profile[numprofile].dms_profile_id = dp.dms_profile_id, reply->profile[numprofile].
      parent_entity_id = dp.parent_entity_id, reply->profile[numprofile].parent_entity_name = dp
      .parent_entity_name,
      reply->profile[numprofile].parent_entity_display = uar_get_code_display(dp.parent_entity_id)
     ENDIF
    WITH nocounter
   ;end select
   GO TO get_rules
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.operationname = "SELECT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
   SET reply->status_data.subeventstatus.targetobjectvalue = build("Invalid entity id",request->
    parent_entity_name,":entity_name","/",request->parent_entity_id,
    ":entity_id")
   GO TO end_script
  ENDIF
 ENDIF
 IF ((request->parent_entity_name="PERSON"))
  SELECT INTO "nl:"
   dp.parent_entity_id, dp.parent_entity_name, p.person_id,
   p.name_full_formatted
   FROM dms_profile dp,
    prsnl p
   PLAN (dp
    WHERE (dp.parent_entity_name=request->parent_entity_name)
     AND dp.parent_entity_id > 0)
    JOIN (p
    WHERE p.person_id=dp.parent_entity_id)
   ORDER BY dp.dms_profile_id
   DETAIL
    numprofile = (numprofile+ 1)
    IF (mod(numprofile,10)=1)
     stat = alterlist(reply->profile,(numprofile+ 9))
    ENDIF
    reply->profile[numprofile].dms_profile_id = dp.dms_profile_id, reply->profile[numprofile].
    parent_entity_id = dp.parent_entity_id, reply->profile[numprofile].parent_entity_name = dp
    .parent_entity_name,
    reply->profile[numprofile].parent_entity_display = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSEIF ((request->parent_entity_name="ORGANIZATION"))
  SELECT INTO "nl:"
   dp.parent_entity_id, dp.parent_entity_name, o.organization_id,
   o.org_name
   FROM dms_profile dp,
    organization o
   PLAN (dp
    WHERE (dp.parent_entity_name=request->parent_entity_name)
     AND dp.parent_entity_id > 0)
    JOIN (o
    WHERE o.organization_id=dp.parent_entity_id)
   ORDER BY dp.dms_profile_id
   DETAIL
    numprofile = (numprofile+ 1)
    IF (mod(numprofile,10)=1)
     stat = alterlist(reply->profile,(numprofile+ 9))
    ENDIF
    reply->profile[numprofile].dms_profile_id = dp.dms_profile_id, reply->profile[numprofile].
    parent_entity_id = dp.parent_entity_id, reply->profile[numprofile].parent_entity_name = dp
    .parent_entity_name,
    reply->profile[numprofile].parent_entity_display = o.org_name
   WITH nocounter
  ;end select
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->parent_entity_name,
   ":entity_name","/",request->parent_entity_id,":entity_id")
  GO TO end_script
 ENDIF
#get_rules
 SET stat = alterlist(reply->profile,numprofile)
 IF (0 < numprofile)
  FREE SET numrules
  DECLARE numrules = i4 WITH noconstant(0)
  FREE SET numdetail
  DECLARE numdetail = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   dps.*, dct.*, dpd.*
   FROM (dummyt d  WITH seq = value(numprofile)),
    dms_profile_service dps,
    dms_content_type dct,
    dms_profile_detail dpd
   PLAN (d)
    JOIN (dps
    WHERE (dps.dms_profile_id=reply->profile[d.seq].dms_profile_id))
    JOIN (dct
    WHERE dct.dms_content_type_id=outerjoin(dps.dms_content_type_id))
    JOIN (dpd
    WHERE dpd.dms_profile_service_id=outerjoin(dps.dms_profile_service_id))
   ORDER BY dps.dms_profile_service_id, dpd.dms_profile_detail_id
   HEAD dps.dms_profile_id
    numrules = 0
   HEAD dps.dms_profile_service_id
    numrules = (numrules+ 1)
    IF (mod(numrules,10)=1)
     stat = alterlist(reply->profile[d.seq].rules,(numrules+ 9))
    ENDIF
    reply->profile[d.seq].rules[numrules].dms_profile_service_id = dps.dms_profile_service_id, reply
    ->profile[d.seq].rules[numrules].dms_content_type_id = dct.dms_content_type_id, reply->profile[d
    .seq].rules[numrules].content_type = dct.content_type_key,
    reply->profile[d.seq].rules[numrules].service_name = dps.service_name, reply->profile[d.seq].
    rules[numrules].from_position_cd = dps.from_position_cd, reply->profile[d.seq].rules[numrules].
    from_prsnl_id = dps.from_prsnl_id,
    numdetail = 0
   DETAIL
    IF (dpd.dms_profile_detail_id > 0)
     numdetail = (numdetail+ 1)
     IF (mod(numdetail,10)=1)
      stat = alterlist(reply->profile[d.seq].rules[numrules].details,(numdetail+ 9))
     ENDIF
     reply->profile[d.seq].rules[numrules].details[numdetail].detail_name = dpd.detail_name, reply->
     profile[d.seq].rules[numrules].details[numdetail].detail_value = dpd.detail_value
    ENDIF
   FOOT  dps.dms_profile_service_id
    stat = alterlist(reply->profile[d.seq].rules[numrules].details,numdetail)
   FOOT  dps.dms_profile_id
    stat = alterlist(reply->profile[d.seq].rules,numrules)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_ALL_PROFILE Script ====================>")
END GO
