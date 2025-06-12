CREATE PROGRAM dms_get_location_desc_profile:dba
 CALL echo(
  "<==================== Entering DMS_GET_LOCATION_DESC_PROFILE Script ====================>")
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
 FREE SET numlocations
 DECLARE numlocations = i4 WITH noconstant(0)
 FREE RECORD locations
 RECORD locations(
   1 qual[*]
     2 locationcd = f8
 )
 FREE SET numchildren
 DECLARE numchildren = i4 WITH noconstant(0)
 FREE RECORD children
 RECORD children(
   1 qual[*]
     2 locationcd = f8
 )
 SET numlocations = 1
 SET stat = alterlist(locations->qual,numlocations)
 SET locations->qual[numlocations].locationcd = request->parent_entity_id
 FREE SET numprofiles
 DECLARE numprofiles = i4 WITH noconstant(0)
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
     numprofiles = (numprofiles+ 1)
     IF (mod(numprofiles,10)=1)
      stat = alterlist(reply->profile,(numprofiles+ 9))
     ENDIF
     reply->profile[numprofiles].dms_profile_id = dp.dms_profile_id, reply->profile[numprofiles].
     parent_entity_id = dp.parent_entity_id, reply->profile[numprofiles].parent_entity_name = dp
     .parent_entity_name,
     reply->profile[numprofiles].parent_entity_display = uar_get_code_display(dp.parent_entity_id)
    WITH nocounter
   ;end select
   SET numchildren = 0
   SET stat = alterlist(children->qual,0)
   SELECT DISTINCT INTO "nl:"
    d.seq, lg.child_loc_cd
    FROM (dummyt d  WITH seq = value(numlocations)),
     location_group lg,
     location l
    PLAN (d)
     JOIN (lg
     WHERE (lg.parent_loc_cd=locations->qual[d.seq].locationcd)
      AND lg.location_group_type_cd > 0
      AND lg.view_type_cd=0
      AND lg.active_ind=1
      AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (l
     WHERE l.location_cd=lg.child_loc_cd
      AND l.location_type_cd > 0.0
      AND l.organization_id > 0.0
      AND l.active_ind=1
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY d.seq, lg.child_loc_cd
    DETAIL
     numchildren = (numchildren+ 1)
     IF (mod(numchildren,10)=1)
      stat = alterlist(children->qual,(numchildren+ 9))
     ENDIF
     children->qual[numchildren].locationcd = l.location_cd
    FOOT REPORT
     stat = alterlist(children->qual,numchildren)
    WITH nocounter
   ;end select
   IF (0 < numchildren)
    SET numlocations = numchildren
    SET stat = alterlist(locations->qual,numchildren)
    FOR (i = 1 TO numchildren)
      SET locations->qual[i].locationcd = children->qual[i].locationcd
    ENDFOR
   ELSE
    SET done = 1
    IF (numprofiles < 0)
     SET reply->status_data.status = "Z"
     SET reply->status_data.subeventstatus.operationname = "SELECT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
     SET reply->status_data.subeventstatus.targetobjectvalue = build(request->parent_entity_id,"/",
      request->parent_entity_name)
     GO TO end_script
    ENDIF
   ENDIF
 ENDWHILE
 SET stat = alterlist(reply->profile,numprofiles)
 IF (0 < numprofiles)
  FREE SET numrules
  DECLARE numrules = i4 WITH noconstant(0)
  FREE SET numdetail
  DECLARE numdetail = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   dps.*, dct.*, dpd.*
   FROM (dummyt d  WITH seq = value(numprofiles)),
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
   HEAD d.seq
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
   FOOT  d.seq
    stat = alterlist(reply->profile[d.seq].rules,numrules)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 FREE RECORD children
 FREE RECORD locations
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_LOCATION_DESC_PROFILE Script ====================>"
  )
END GO
