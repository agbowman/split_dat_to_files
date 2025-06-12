CREATE PROGRAM dms_upd_profile_service:dba
 CALL echo("<==================== Entering DMS_UPD_PROFILE_SERVICE Script ====================>")
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
 DECLARE numservice = i4 WITH noconstant(size(request->service,5))
 FREE RECORD updateservice
 RECORD updateservice(
   1 service[*]
     2 dms_profile_service_id = f8
 )
 FREE RECORD allservice
 RECORD allservice(
   1 qual[*]
     2 id = f8
 )
 FREE RECORD addrequest
 RECORD addrequest(
   1 dms_profile_id = f8
   1 content_type = vc
   1 service_name = vc
   1 from_position_cd = f8
   1 from_prsnl_id = f8
   1 servicedetail[*]
     2 name = vc
     2 value = vc
 )
 FREE RECORD addreply
 RECORD addreply(
   1 dms_profile_service_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD updatedetailreq
 RECORD updatedetailreq(
   1 dms_profile_service_id = f8
   1 servicedetail[*]
     2 name = vc
     2 value = vc
 )
 FREE RECORD delrequest
 RECORD delrequest(
   1 qual[*]
     2 dms_profile_service_id = f8
 )
 RECORD tempreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(updateservice->service,numservice)
 FOR (i = 1 TO numservice)
   FREE SET contenttypeid
   DECLARE contenttypeid = f8 WITH noconstant(0.0)
   IF (trim(request->service[i].content_type) != "")
    SELECT INTO "nl:"
     dct.*
     FROM dms_content_type dct
     WHERE (dct.content_type_key=request->service[i].content_type)
     DETAIL
      contenttypeid = dct.dms_content_type_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.subeventstatus.operationname = "SELECT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "DMS_CONTENT_TYPE"
     SET reply->status_data.subeventstatus.targetobjectvalue = request->content_type
     GO TO end_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dps.*
    FROM dms_profile_service dps
    WHERE (dps.service_name=request->service[i].service_name)
     AND dps.dms_content_type_id=contenttypeid
     AND (dps.dms_profile_id=request->dms_profile_id)
    DETAIL
     request->service[i].dms_profile_service_id = dps.dms_profile_service_id
    WITH nocounter
   ;end select
   IF ((request->service[i].dms_profile_service_id <= 0))
    FREE SET numadddetail
    DECLARE numadddetail = i4 WITH noconstant(0)
    SET numadddetail = size(request->service[i].servicedetail,5)
    SET addrequest->dms_profile_id = request->dms_profile_id
    SET addrequest->content_type = request->service[i].content_type
    SET addrequest->service_name = request->service[i].service_name
    SET addrequest->from_position_cd = request->service[i].from_position_cd
    SET addrequest->from_prsnl_id = request->service[i].from_prsnl_id
    SET stat = alterlist(addrequest->servicedetail,numadddetail)
    FOR (x = 1 TO numadddetail)
     SET addrequest->servicedetail[x].name = request->service[i].servicedetail[x].name
     SET addrequest->servicedetail[x].value = request->service[i].servicedetail[x].value
    ENDFOR
    EXECUTE dms_add_profile_service  WITH replace("REQUEST",addrequest), replace("REPLY",addreply)
    IF ((addreply->status_data.status="S"))
     SET updateservice->service[i].dms_profile_service_id = addreply->dms_profile_service_id
    ELSE
     SET reply->status_data.status = addreply->status_data.status
     SET reply->status_data.subeventstatus.operationname = addreply->status_data.subeventstatus.
     operationname
     SET reply->status_data.subeventstatus.operationstatus = addreply->status_data.subeventstatus.
     operationstatus
     SET reply->status_data.subeventstatus.targetobjectname = addreply->status_data.subeventstatus.
     targetobjectname
     SET reply->status_data.subeventstatus.targetobjectvalue = addreply->status_data.subeventstatus.
     targetobjectvalue
     GO TO end_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dms_profile_service dps
     WHERE (dps.dms_profile_service_id=request->service[i].dms_profile_service_id)
     WITH nocounter, forupdate(dps)
    ;end select
    IF (curqual <= 0)
     SET reply->status_data.subeventstatus.operationname = "SELECT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "DMS_PROFILE_SERVICE"
     SET reply->status_data.subeventstatus.targetobjectvalue = build(request->service[i].
      dms_profile_service_id)
     GO TO end_script
    ENDIF
    UPDATE  FROM dms_profile_service dps
     SET dps.dms_content_type_id = contenttypeid, dps.dms_profile_id = request->dms_profile_id, dps
      .service_name = request->service[i].service_name,
      dps.from_position_cd = request->service[i].from_position_cd, dps.from_prsnl_id = request->
      service[i].from_prsnl_id, dps.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dps.updt_id = reqinfo->updt_id, dps.updt_task = reqinfo->updt_task, dps.updt_cnt = (dps
      .updt_cnt+ 1),
      dps.updt_applctx = reqinfo->updt_applctx
     WHERE (dps.dms_profile_service_id=request->service[i].dms_profile_service_id)
     WITH nocounter
    ;end update
    SET updateservice->service[i].dms_profile_service_id = request->service[i].dms_profile_service_id
    SET updatedetailreq->dms_profile_service_id = request->service[i].dms_profile_service_id
    FREE SET numdetailupdate
    DECLARE numdetailupdate = i4 WITH noconstant(size(request->service[i].servicedetail,5))
    SET stat = alterlist(updatedetailreq->servicedetail,numdetailupdate)
    FOR (d = 1 TO numdetailupdate)
     SET updatedetailreq->servicedetail[d].name = request->service[i].servicedetail[d].name
     SET updatedetailreq->servicedetail[d].value = request->service[i].servicedetail[d].value
    ENDFOR
    EXECUTE dms_upd_profile_details  WITH replace("REQUEST",updatedetailreq), replace("REPLY",
     tempreply)
    IF ((tempreply->status_data.status != "S"))
     SET reply->status_data.status = tempreply->status_data.status
     SET reply->status_data.subeventstatus.operationname = tempreply->status_data.subeventstatus.
     operationname
     SET reply->status_data.subeventstatus.operationstatus = tempreply->status_data.subeventstatus.
     operationstatus
     SET reply->status_data.subeventstatus.targetobjectname = tempreply->status_data.subeventstatus.
     targetobjectname
     SET reply->status_data.subeventstatus.targetobjectvalue = tempreply->status_data.subeventstatus.
     targetobjectvalue
     GO TO end_script
    ENDIF
   ENDIF
 ENDFOR
 FREE SET totservices
 DECLARE totservices = i4 WITH noconstant(0)
 SET stat = alterlist(allservice->qual,0)
 SELECT INTO "nl:"
  dps.dms_profile_service_id
  FROM dms_profile_service dps
  WHERE (request->dms_profile_id=dps.dms_profile_id)
  DETAIL
   totservices = (totservices+ 1)
   IF (mod(totservices,10)=1)
    stat = alterlist(allservice->qual,(totservices+ 9))
   ENDIF
   allservice->qual[totservices].id = dps.dms_profile_service_id
  WITH nocounter
 ;end select
 SET stat = alterlist(allservice->qual,totservices)
 FREE SET numdelete
 DECLARE numdelete = i4 WITH noconstant(0)
 FOR (l = 1 TO totservices)
   SET bfound = 0
   SET count = 0
   WHILE (count < numservice)
    SET count = (count+ 1)
    IF ((allservice->qual[l].id=updateservice->service[count].dms_profile_service_id))
     SET bfound = 1
     SET count = numservice
    ENDIF
   ENDWHILE
   IF ( NOT (bfound))
    SET numdelete = (numdelete+ 1)
    SET stat = alterlist(delrequest->qual,numdelete)
    SET delrequest->qual[numdelete].dms_profile_service_id = allservice->qual[l].id
   ENDIF
 ENDFOR
 IF (0 < numdelete)
  EXECUTE dms_del_profile_service  WITH replace("REQUEST",delrequest), replace("REPLY",tempreply)
  IF ((tempreply->status_data.status != "S"))
   GO TO end_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_UPD_PROFILE_SERVICE Script ====================>")
END GO
