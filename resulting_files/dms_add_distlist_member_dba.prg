CREATE PROGRAM dms_add_distlist_member:dba
 CALL echo("<==================== Entering DMS_ADD_DISTLIST_MEMBER Script ====================>")
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
 FREE SET nummembers
 DECLARE nummembers = i4 WITH noconstant(size(request->members,5))
 FREE SET stat
 DECLARE stat = i4 WITH noconstant
 SELECT INTO "nl:"
  dlm.*
  FROM dms_distlist_member dlm,
   (dummyt d  WITH seq = value(nummembers))
  PLAN (d)
   JOIN (dlm
   WHERE (dlm.service_name=request->members[d.seq].service_name)
    AND (dlm.dms_distlist_id=request->dms_distlist_id))
  WITH nocounter
 ;end select
 IF (0 < curqual)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST_MEMBER"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_distlist_id,"/",
   "service already exists")
  GO TO end_script
 ENDIF
 FREE SET numids
 DECLARE numids = i4 WITH noconstant(0)
 FREE SET nummemberstocheck
 DECLARE nummemberstocheck = i4 WITH noconstant(0)
 FREE SET idlength
 DECLARE idlength = i4 WITH noconstant(0)
 FREE SET tempid
 DECLARE tempid = f8 WITH noconstant(0.0)
 FREE SET bdone
 DECLARE bdone = i4 WITH noconstant(0)
 FREE RECORD memberlist
 RECORD memberlist(
   1 qual[*]
     2 service_name = vc
     2 list_id = f8
 )
 FREE RECORD idlist
 RECORD idlist(
   1 qual[*]
     2 list_id = f8
 )
 SET stat = alterlist(memberlist->qual,nummembers)
 SET nummemberstocheck = nummembers
 FOR (m = 1 TO nummemberstocheck)
  SET memberlist->qual[m].service_name = request->members[m].service_name
  SET memberlist->qual[m].list_id = request->dms_distlist_id
 ENDFOR
 WHILE ( NOT (bdone))
   FOR (i = 1 TO nummemberstocheck)
     SET idlength = findstring("@DMS_DISTLIST@LIST",memberlist->qual[i].service_name,0)
     SET idlength = (idlength - 1)
     IF (0 < idlength)
      SET tempid = cnvtreal(substring(0,idlength,memberlist->qual[i].service_name))
      IF ((tempid=request->dms_distlist_id))
       SET reply->status_data.subeventstatus.operationname = "SELECT"
       SET reply->status_data.subeventstatus.operationstatus = "F"
       SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST_MEMBER"
       SET reply->status_data.subeventstatus.targetobjectvalue = build(memberlist->qual[i].
        service_name,"/",memberlist->qual[i].list_id,"-DMS_DISTLIST_ID",
        "-Member contains parent LIST")
       GO TO end_script
      ELSE
       SET numids = (numids+ 1)
       IF (mod(numids,10)=1)
        SET stat = alterlist(idlist->qual,(numids+ 9))
       ENDIF
       SET idlist->qual[numids].list_id = tempid
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(idlist->qual,numids)
   SET nummemberstocheck = 0
   IF (0 < numids)
    SELECT INTO "nl:"
     dlm.*
     FROM dms_distlist_member dlm,
      (dummyt d  WITH seq = value(numids))
     PLAN (d)
      JOIN (dlm
      WHERE (dlm.dms_distlist_id=idlist->qual[d.seq].list_id))
     DETAIL
      nummemberstocheck = (nummemberstocheck+ 1)
      IF (mod(nummemberstocheck,10)=1)
       stat = alterlist(memberlist->qual,(nummemberstocheck+ 9))
      ENDIF
      memberlist->qual[nummemberstocheck].service_name = dlm.service_name, memberlist->qual[
      nummemberstocheck].list_id = dlm.dms_distlist_id
     WITH nocounter
    ;end select
    SET stat = alterlist(memberlist->qual,nummemberstocheck)
    SET numids = 0
   ELSE
    SET bdone = 1
   ENDIF
 ENDWHILE
 INSERT  FROM dms_distlist_member dlm,
   (dummyt d  WITH seq = value(nummembers))
  SET dlm.dms_distlist_member_id = seq(dms_seq,nextval), dlm.dms_distlist_id = request->
   dms_distlist_id, dlm.service_name = request->members[d.seq].service_name,
   dlm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dlm.updt_id = reqinfo->updt_id, dlm.updt_task =
   reqinfo->updt_task,
   dlm.updt_cnt = 0, dlm.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (dlm)
  WITH nocounter
 ;end insert
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus.operationname = "INSERT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST_MEMBER"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->dms_distlist_id,"/",
   "dms_distlist_id")
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
 FREE RECORD idlist
 FREE RECORD memberlist
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_ADD_DISTLIST_MEMBER Script ====================>")
END GO
