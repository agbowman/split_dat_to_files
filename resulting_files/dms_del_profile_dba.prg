CREATE PROGRAM dms_del_profile:dba
 CALL echo("<==================== Entering DMS_DEL_PROFILE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
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
 SET reqinfo->commit_ind = 0
 FREE SET numservice
 DECLARE numservice = i4 WITH noconstant(0)
 FREE RECORD delservice
 RECORD delservice(
   1 qual[*]
     2 dms_profile_service_id = f8
 )
 SELECT INTO "nl:"
  FROM dms_profile_service dps
  WHERE (dps.dms_profile_id=request->dms_profile_id)
  HEAD REPORT
   numservice = 0
  DETAIL
   numservice = (numservice+ 1)
   IF (mod(numservice,10)=1)
    stat = alterlist(delservice->qual,(numservice+ 9))
   ENDIF
   delservice->qual[numservice].dms_profile_service_id = dps.dms_profile_service_id
  FOOT REPORT
   stat = alterlist(delservice->qual,numservice)
  WITH nocounter
 ;end select
 IF (0 < numservice)
  EXECUTE dms_del_profile_service  WITH replace("REQUEST","DELSERVICE")
  IF ((reply->status_data.status != "S"))
   GO TO end_script
  ENDIF
 ENDIF
 DELETE  FROM dms_profile dp
  WHERE (dp.dms_profile_id=request->dms_profile_id)
  WITH nocounter
 ;end delete
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "DELETE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_profile_id)
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 FREE RECORD delservice
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_DEL_PROFILE Script ====================>")
END GO
