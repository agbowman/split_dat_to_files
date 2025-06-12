CREATE PROGRAM dms_del_distlist_member:dba
 CALL echo("<==================== Entering DMS_DEL_DISTLIST_MEMBER Script ====================>")
 SET modify = predeclare
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
 DELETE  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   dms_distlist_member dlm
  SET dlm.seq = 1
  PLAN (d)
   JOIN (dlm
   WHERE (dlm.dms_distlist_member_id=request->qual[d.seq].dms_distlist_member_id))
  WITH nocounter
 ;end delete
 IF (curqual != value(size(request->qual,5)))
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "DELETE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST_MEMBER"
  SET reply->status_data.subeventstatus.targetobjectvalue = ""
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_DEL_DISTLIST_MEMBER Script ====================>")
END GO
