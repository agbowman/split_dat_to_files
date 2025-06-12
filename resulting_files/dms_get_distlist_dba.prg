CREATE PROGRAM dms_get_distlist:dba
 CALL echo("<==================== Entering DMS_GET_DISTLIST Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 dms_distlist_id = f8
      2 name = vc
      2 description = vc
      2 owner_id = f8
      2 private_ind = i2
      2 created_by_id = f8
      2 created_dt_tm = dq8
      2 members[*]
        3 dms_distlist_member_id = f8
        3 service_name = vc
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
 FREE SET numlist
 DECLARE numlist = i4 WITH noconstant(size(request->listids,5))
 FREE SET nummember
 DECLARE nummember = i4 WITH noconstant(0)
 FREE SET tempstring
 DECLARE tempstring = vc
 FREE SET stat
 DECLARE stat = i4 WITH noconstant(0)
 IF (0 < numlist)
  SET stat = alterlist(reply->qual,numlist)
  SELECT INTO "nl:"
   ddl.*, dlm.*
   FROM dms_distlist ddl,
    dms_distlist_member dlm,
    (dummyt d  WITH seq = value(numlist))
   PLAN (d)
    JOIN (ddl
    WHERE (ddl.dms_distlist_id=request->listids[d.seq].list_id))
    JOIN (dlm
    WHERE dlm.dms_distlist_id=outerjoin(ddl.dms_distlist_id))
   ORDER BY ddl.dms_distlist_id
   HEAD ddl.dms_distlist_id
    reply->qual[d.seq].dms_distlist_id = ddl.dms_distlist_id, reply->qual[d.seq].name = ddl.name,
    reply->qual[d.seq].description = ddl.description,
    reply->qual[d.seq].owner_id = ddl.owner_id, reply->qual[d.seq].private_ind = ddl.private_ind,
    reply->qual[d.seq].created_by_id = ddl.created_by_id,
    reply->qual[d.seq].created_dt_tm = ddl.created_dt_tm, nummember = 0
   DETAIL
    IF (0 < dlm.dms_distlist_member_id)
     nummember = (nummember+ 1)
     IF (mod(nummember,10)=1)
      stat = alterlist(reply->qual[d.seq].members,(nummember+ 9))
     ENDIF
     reply->qual[d.seq].members[nummember].dms_distlist_member_id = dlm.dms_distlist_member_id, reply
     ->qual[d.seq].members[nummember].service_name = dlm.service_name
    ENDIF
   FOOT  ddl.dms_distlist_id
    stat = alterlist(reply->qual[d.seq].members,nummember)
   WITH nocounter
  ;end select
 ELSE
  IF ((request->owner_id <= 0))
   SET request->owner_id = reqinfo->updt_id
  ENDIF
  IF (trim(request->name)="")
   SET request->name = "*"
  ENDIF
  IF ((request->public_ind=1))
   SELECT INTO "nl:"
    ddl.*, dlm.*
    FROM dms_distlist ddl,
     dms_distlist_member dlm
    PLAN (ddl
     WHERE ddl.name=patstring(request->name)
      AND ddl.private_ind=0
      AND ddl.dms_distlist_id > 0)
     JOIN (dlm
     WHERE dlm.dms_distlist_id=outerjoin(ddl.dms_distlist_id))
    ORDER BY ddl.dms_distlist_id
    HEAD ddl.dms_distlist_id
     numlist = (numlist+ 1)
     IF (mod(numlist,10)=1)
      stat = alterlist(reply->qual,(numlist+ 9))
     ENDIF
     reply->qual[numlist].dms_distlist_id = ddl.dms_distlist_id, reply->qual[numlist].name = ddl.name,
     reply->qual[numlist].description = ddl.description,
     reply->qual[numlist].owner_id = ddl.owner_id, reply->qual[numlist].private_ind = ddl.private_ind,
     reply->qual[numlist].created_by_id = ddl.created_by_id,
     reply->qual[numlist].created_dt_tm = ddl.created_dt_tm, nummember = 0
    DETAIL
     IF (0 < dlm.dms_distlist_member_id)
      nummember = (nummember+ 1)
      IF (mod(nummember,10)=1)
       stat = alterlist(reply->qual[numlist].members,(nummember+ 9))
      ENDIF
      reply->qual[numlist].members[nummember].dms_distlist_member_id = dlm.dms_distlist_member_id,
      reply->qual[numlist].members[nummember].service_name = dlm.service_name
     ENDIF
    FOOT  ddl.dms_distlist_id
     stat = alterlist(reply->qual[numlist].members,nummember)
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->private_ind=1))
   IF ((request->private_dl_read_ind=1))
    SELECT INTO "nl:"
     ddl.*, dlm.*
     FROM dms_distlist ddl,
      dms_distlist_member dlm
     PLAN (ddl
      WHERE ddl.name=patstring(request->name)
       AND ddl.private_ind=1)
      JOIN (dlm
      WHERE dlm.dms_distlist_id=outerjoin(ddl.dms_distlist_id))
     ORDER BY ddl.dms_distlist_id
     HEAD ddl.dms_distlist_id
      numlist = (numlist+ 1)
      IF (mod(numlist,10)=1)
       stat = alterlist(reply->qual,(numlist+ 9))
      ENDIF
      reply->qual[numlist].dms_distlist_id = ddl.dms_distlist_id, reply->qual[numlist].name = ddl
      .name, reply->qual[numlist].description = ddl.description,
      reply->qual[numlist].owner_id = ddl.owner_id, reply->qual[numlist].private_ind = ddl
      .private_ind, reply->qual[numlist].created_by_id = ddl.created_by_id,
      reply->qual[numlist].created_dt_tm = ddl.created_dt_tm, nummember = 0
     DETAIL
      IF (0 < dlm.dms_distlist_member_id)
       nummember = (nummember+ 1)
       IF (mod(nummember,10)=1)
        stat = alterlist(reply->qual[numlist].members,(nummember+ 9))
       ENDIF
       reply->qual[numlist].members[nummember].dms_distlist_member_id = dlm.dms_distlist_member_id,
       reply->qual[numlist].members[nummember].service_name = dlm.service_name
      ENDIF
     FOOT  ddl.dms_distlist_id
      stat = alterlist(reply->qual[numlist].members,nummember)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     ddl.*, dlm.*
     FROM dms_distlist ddl,
      dms_distlist_member dlm
     PLAN (ddl
      WHERE (ddl.owner_id=request->owner_id)
       AND ddl.name=patstring(request->name)
       AND ddl.private_ind=1)
      JOIN (dlm
      WHERE dlm.dms_distlist_id=outerjoin(ddl.dms_distlist_id))
     ORDER BY ddl.dms_distlist_id
     HEAD ddl.dms_distlist_id
      numlist = (numlist+ 1)
      IF (mod(numlist,10)=1)
       stat = alterlist(reply->qual,(numlist+ 9))
      ENDIF
      reply->qual[numlist].dms_distlist_id = ddl.dms_distlist_id, reply->qual[numlist].name = ddl
      .name, reply->qual[numlist].description = ddl.description,
      reply->qual[numlist].owner_id = ddl.owner_id, reply->qual[numlist].private_ind = ddl
      .private_ind, reply->qual[numlist].created_by_id = ddl.created_by_id,
      reply->qual[numlist].created_dt_tm = ddl.created_dt_tm, nummember = 0
     DETAIL
      IF (0 < dlm.dms_distlist_member_id)
       nummember = (nummember+ 1)
       IF (mod(nummember,10)=1)
        stat = alterlist(reply->qual[numlist].members,(nummember+ 9))
       ENDIF
       reply->qual[numlist].members[nummember].dms_distlist_member_id = dlm.dms_distlist_member_id,
       reply->qual[numlist].members[nummember].service_name = dlm.service_name
      ENDIF
     FOOT  ddl.dms_distlist_id
      stat = alterlist(reply->qual[numlist].members,nummember)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (numlist > 0)
  SET stat = alterlist(reply->qual,numlist)
 ENDIF
 IF (numlist <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "DMS_DISTLIST"
  SET reply->status_data.subeventstatus.targetobjectvalue = build(request->owner_id,"/",request->name
   )
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_DISTLIST Script ====================>")
END GO
