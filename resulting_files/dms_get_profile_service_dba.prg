CREATE PROGRAM dms_get_profile_service:dba
 CALL echo("<==================== Entering DMS_GET_PROFILE_SERVICE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 service[*]
      2 dms_profile_service_id = f8
      2 dms_content_type_id = f8
      2 content_type = vc
      2 service_name = vc
      2 service_type_flag = i2
      2 from_position_cd = f8
      2 from_prsnl_id = f8
      2 servicedetail[*]
        3 dms_profile_detail_id = f8
        3 detail_name = vc
        3 detail_value = vc
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
 FREE SET dmscontenttypeid
 DECLARE dmscontenttypeid = f8 WITH noconstant(0.0)
 IF ("" < trim(request->content_type))
  SELECT INTO "nl:"
   dct.*
   FROM dms_content_type dct
   WHERE (dct.content_type_key=request->content_type)
   DETAIL
    dmscontenttypeid = dct.dms_content_type_id
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.operationname = "SELECT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "DMS_CONTENT_TYPE"
   SET reply->status_data.subeventstatus.targetobjectvalue = request->content_type
   GO TO end_script
  ENDIF
 ENDIF
 FREE SET numservice
 DECLARE numservice = i4 WITH noconstant(0)
 FREE SET highestrank
 DECLARE highestrank = i2 WITH noconstant(- (1))
 RECORD allservices(
   1 service[*]
     2 rank = i2
     2 dms_profile_service_id = f8
 )
 SELECT INTO "nl:"
  dps.*
  FROM dms_profile_service dps
  WHERE (dps.dms_profile_id=request->dms_profile_id)
   AND ((dps.dms_content_type_id=dmscontenttypeid) OR (dps.dms_content_type_id=0.0))
   AND (((dps.from_prsnl_id=request->from_prsnl_id)) OR (dps.from_prsnl_id=0.0))
   AND (((dps.from_position_cd=request->from_position_cd)) OR (dps.from_position_cd=0.0))
  ORDER BY dps.dms_profile_service_id
  HEAD REPORT
   numservice = 0
  DETAIL
   numservice = (numservice+ 1)
   IF (mod(numservice,10)=1)
    stat = alterlist(allservices->service,(numservice+ 9))
   ENDIF
   allservices->service[numservice].rank = 0, allservices->service[numservice].dms_profile_service_id
    = dps.dms_profile_service_id
   IF (dps.dms_content_type_id=dmscontenttypeid)
    allservices->service[numservice].rank = (allservices->service[numservice].rank+ 4)
   ENDIF
   IF ((dps.from_prsnl_id=request->from_prsnl_id))
    allservices->service[numservice].rank = (allservices->service[numservice].rank+ 2)
   ENDIF
   IF ((dps.from_position_cd=request->from_position_cd))
    allservices->service[numservice].rank = (allservices->service[numservice].rank+ 1)
   ENDIF
   IF ((highestrank < allservices->service[numservice].rank))
    highestrank = allservices->service[numservice].rank
   ENDIF
  FOOT REPORT
   stat = alterlist(allservices->service,numservice)
  WITH nocounter
 ;end select
 CALL echorecord(allservices)
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE_SERVICE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_profile_id)
  GO TO end_script
 ENDIF
 IF (highestrank < 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE_SERVICE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_profile_id,"/",request
   ->content_type,"/",request->from_position_cd,
   "/",request->from_prsnl_id)
  GO TO end_script
 ENDIF
 CALL echo(build("highestRank=",highestrank))
 FREE SET nummatch
 DECLARE nummatch = i4 WITH noconstant(0)
 FREE SET numdetail
 DECLARE numdetail = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  dps.*, dct.*, dpd.*
  FROM (dummyt d  WITH seq = value(numservice)),
   dms_profile_service dps,
   dms_content_type dct,
   dms_profile_detail dpd
  PLAN (d
   WHERE (allservices->service[d.seq].rank=highestrank))
   JOIN (dps
   WHERE (dps.dms_profile_service_id=allservices->service[d.seq].dms_profile_service_id))
   JOIN (dct
   WHERE dct.dms_content_type_id=dps.dms_content_type_id)
   JOIN (dpd
   WHERE dpd.dms_profile_service_id=outerjoin(dps.dms_profile_service_id))
  ORDER BY d.seq, dpd.dms_profile_detail_id
  HEAD REPORT
   nummatch = 0
  HEAD d.seq
   nummatch = (nummatch+ 1)
   IF (mod(nummatch,10)=1)
    stat = alterlist(reply->service,(nummatch+ 9))
   ENDIF
   reply->service[nummatch].dms_profile_service_id = allservices->service[d.seq].
   dms_profile_service_id, reply->service[nummatch].dms_content_type_id = dct.dms_content_type_id,
   reply->service[nummatch].content_type = dct.content_type_key,
   reply->service[nummatch].service_name = dps.service_name, reply->service[nummatch].
   service_type_flag = dps.service_type_flag, reply->service[nummatch].from_position_cd = dps
   .from_position_cd,
   reply->service[nummatch].from_prsnl_id = dps.from_prsnl_id, numdetail = 0
  DETAIL
   IF (0 < dpd.dms_profile_detail_id)
    numdetail = (numdetail+ 1)
    IF (mod(numdetail,10)=1)
     stat = alterlist(reply->service[nummatch].servicedetail,(numdetail+ 9))
    ENDIF
    reply->service[nummatch].servicedetail[numdetail].dms_profile_detail_id = dpd
    .dms_profile_detail_id, reply->service[nummatch].servicedetail[numdetail].detail_name = dpd
    .detail_name, reply->service[nummatch].servicedetail[numdetail].detail_value = dpd.detail_value
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->service[nummatch].servicedetail,numdetail)
  FOOT REPORT
   stat = alterlist(reply->service,nummatch)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE_SERVICE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_profile_id)
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_PROFILE_SERVICE Script ====================>")
END GO
