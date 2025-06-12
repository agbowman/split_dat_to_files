CREATE PROGRAM dms_del_distlist:dba
 CALL echo("<==================== Entering DMS_DEL_DISTLIST Script ====================>")
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
 FREE SET nummember
 DECLARE nummember = i4 WITH noconstant(0)
 FREE RECORD delmember
 RECORD delmember(
   1 qual[*]
     2 dms_distlist_member_id = f8
 )
 SELECT INTO "nl:"
  FROM dms_distlist_member dlm
  WHERE (dlm.dms_distlist_id=request->dms_distlist_id)
  HEAD REPORT
   nummember = 0
  DETAIL
   nummember = (nummember+ 1)
   IF (mod(nummember,10)=1)
    stat = alterlist(delmember->qual,(nummember+ 9))
   ENDIF
   delmember->qual[nummember].dms_distlist_member_id = dlm.dms_distlist_member_id
  FOOT REPORT
   stat = alterlist(delmember->qual,nummember)
  WITH nocounter
 ;end select
 IF (0 < nummember)
  EXECUTE dms_del_distlist_member  WITH replace("REQUEST","DELMEMBER")
  IF ((reply->status_data.status != "S"))
   GO TO end_script
  ENDIF
 ENDIF
 DELETE  FROM dms_distlist ddl
  WHERE (ddl.dms_distlist_id=request->dms_distlist_id)
  WITH nocounter
 ;end delete
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "DELETE"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_distlist_id)
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 FREE RECORD delmember
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_DEL_DISTLIST Script ====================>")
END GO
